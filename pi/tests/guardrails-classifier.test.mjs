import assert from "node:assert/strict";
import { existsSync, mkdtempSync, mkdirSync, readFileSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";
import { after, test } from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";

const agentDir = process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi/agent");
const installRoot = process.env.PI_MANAGED_INSTALL_ROOT || join(agentDir, "install");
const version = readFileSync(join(installRoot, "current-version"), "utf8").trim();
const host = join(installRoot, "releases", version, "node_modules/@earendil-works/pi-coding-agent");
const { loadExtensions } = await import(pathToFileURL(join(host, "dist/core/extensions/loader.js")));
const { ExtensionRunner } = await import(pathToFileURL(join(host, "dist/core/extensions/runner.js")));
const root = mkdtempSync(join(tmpdir(), "pi-guardrails-test-"));
const cwd = join(root, "workspace");
const testAgent = join(root, "agent");
const previousCwd = process.cwd();
const previousAgent = process.env.PI_CODING_AGENT_DIR;
mkdirSync(cwd);
mkdirSync(join(testAgent, "extensions"), { recursive: true });
symlinkSync(join(agentDir, "npm"), join(testAgent, "npm"));
const config = JSON.parse(readFileSync(new URL("../agent/extensions/guardrails.json", import.meta.url), "utf8"));
const guardrails = join(agentDir, "npm/node_modules/@aliou/pi-guardrails");
config.version = JSON.parse(readFileSync(join(guardrails, "package.json"), "utf8")).version;
config.permissionGate.patterns = [{ pattern: "git status", description: "Test prompt for a safe command" }];
writeFileSync(join(testAgent, "extensions/guardrails.json"), JSON.stringify(config));
writeFileSync(join(root, ".env"), "TEST_SECRET=dummy\n");
process.env.PI_CODING_AGENT_DIR = testAgent;
process.chdir(cwd);
after(() => {
  process.chdir(previousCwd);
  if (previousAgent === undefined) delete process.env.PI_CODING_AGENT_DIR;
  else process.env.PI_CODING_AGENT_DIR = previousAgent;
  rmSync(root, { recursive: true, force: true });
});

const adapter = fileURLToPath(new URL("../agent/extensions/guardrails-classifier/index.ts", import.meta.url));
const paths = [join(guardrails, "extensions/guardrails/index.ts")];
if (process.env.GUARDRAILS_BASELINE) {
  paths.push(join(guardrails, "extensions/path-access/index.ts"), join(guardrails, "extensions/permission-gate/index.ts"));
} else {
  assert.ok(existsSync(adapter));
  paths.push(adapter);
}
const loaded = await loadExtensions(paths, cwd);
assert.deepEqual(loaded.errors, []);
const handlers = loaded.extensions.flatMap(extension => extension.handlers.get("tool_call") || []);
assert.ok(handlers.length >= 3);

async function call(toolName, input, options = {}) {
  const prompts = [];
  const requests = [];
  const ctx = {
    cwd: options.cwd ?? cwd,
    hasUI: options.hasUI ?? true,
    signal: options.signal,
    modelRegistry: {
      findOfType: (...args) => options.missingModel ? undefined : { provider: args[1], id: args[2] },
      classify: async (...args) => {
        requests.push(args);
        if (options.error) throw new Error("Classifier unavailable");
        return options.result ?? { stopReason: "stop", answers: { safe: { type: "bool", probability: 0.95 } } };
      },
    },
    ui: {
      custom: async () => {
        prompts.push("custom");
        return options.rpc ? undefined : "deny";
      },
      select: async () => {
        prompts.push("select");
        return "Deny";
      },
      notify: () => {},
    },
  };
  const event = { type: "tool_call", toolCallId: "test", toolName, input };
  let result;
  for (const handler of handlers) {
    result = await handler(event, ctx);
    if (result?.block) break;
  }
  return { result, prompts, requests };
}

test("outside-workspace reads do not prompt", async () => {
  const { result, prompts, requests } = await call("read", { path: join(root, "notes.md") });
  assert.equal(result, undefined);
  assert.deepEqual(prompts, []);
  assert.deepEqual(requests, []);
});

test("a safe shell command bypasses the permission prompt", async () => {
  const { result, prompts, requests } = await call("bash", { command: "git status --short" });
  assert.equal(result, undefined);
  assert.deepEqual(prompts, []);
  assert.equal(requests.length, 1);
  assert.deepEqual(requests[0][0], { provider: "openrouter", id: "~typesafe/jev-latest" });
  assert.deepEqual(requests[0][1].state, { cwd, command: "git status --short" });
  assert.ok(requests[0][2].signal instanceof AbortSignal);
});

test("a safe shell command bypasses all path prompts with one classifier call", async () => {
  const { result, prompts, requests } = await call("bash", { command: "ls /var/log /opt" });
  assert.equal(result, undefined);
  assert.deepEqual(prompts, []);
  assert.equal(requests.length, 1);
});

test("outside-workspace writes retain the prompt without disclosure of file contents", async () => {
  for (const toolName of ["write", "edit"]) {
    const { result, prompts, requests } = await call(toolName, { path: join(root, "notes.md"), content: "private" });
    assert.equal(result?.block, true);
    assert.deepEqual(prompts, ["custom"]);
    assert.deepEqual(requests, []);
  }
});

test("unsafe, uncertain, invalid, and failed classifier results retain the prompt", async () => {
  const results = [
    { stopReason: "error", answers: {} },
    { stopReason: "aborted", answers: {} },
    { stopReason: "stop", answers: {} },
    ...[0, 0.89, 1.1, NaN, "1"].map(probability => ({
      stopReason: "stop", answers: { safe: { type: "bool", probability } },
    })),
    { stopReason: "stop", answers: { safe: { type: "choice", choice: "safe" } } },
  ];
  for (const result of results) {
    for (const command of ["rm -rf ./src", "ls /var/log"]) {
      const response = await call("bash", { command }, { result });
      assert.equal(response.result?.block, true);
      assert.deepEqual(response.prompts, ["custom"]);
    }
  }
  for (const options of [{ error: true }, { missingModel: true }]) {
    const response = await call("bash", { command: "rm -rf ./src" }, options);
    assert.equal(response.result?.block, true);
    assert.deepEqual(response.prompts, ["custom"]);
  }
});

test("explicit command denies do not reach the classifier", async () => {
  const { result, prompts, requests } = await call("bash", { command: "git -C /var/log push origin main; git push origin main" });
  assert.equal(result?.block, true);
  assert.match(result.reason, /git push/);
  assert.deepEqual(prompts, []);
  assert.deepEqual(requests, []);
});

test("secret policies still block outside-workspace reads", async () => {
  const { result, prompts, requests } = await call("read", { path: join(root, ".env") });
  assert.equal(result?.block, true);
  assert.match(result.reason, /secrets/);
  assert.deepEqual(prompts, []);
  assert.deepEqual(requests, []);
});

test("credential and session-token files never reach the classifier or approval UI", async () => {
  const protectedPaths = [
    join(testAgent, "auth.json"),
    join(testAgent, "mcp-auth.json"),
    join(cwd, "auth.json"),
    join(cwd, "credentials.json"),
    join(cwd, "session-tokens.json"),
    join(cwd, "storageState.json"),
    join(cwd, "cookies.sqlite"),
    join(cwd, ".aws/sso/cache/session.json"),
    join(cwd, ".kube/config"),
    join(cwd, ".env.staging"),
    join(cwd, "private.key"),
    join(homedir(), ".ssh/id_ed25519"),
    join(homedir(), ".gnupg/private-keys-v1.d/key"),
    join(homedir(), ".config/gh/hosts.yml"),
    join(homedir(), ".config/gcloud/application_default_credentials.json"),
    join(homedir(), ".azure/msal_token_cache.json"),
    join(homedir(), ".docker/config.json"),
    join(homedir(), ".npmrc"),
    join(homedir(), ".netrc"),
    join(homedir(), ".pgpass"),
    join(homedir(), ".git-credentials"),
    join(homedir(), ".claude/.credentials.json"),
    join(homedir(), ".pi/agent/sessions/project/session.jsonl"),
    join(homedir(), "Library/Keychains/login.keychain-db"),
    join(homedir(), "Library/Application Support/Google/Chrome/Default/Network/Cookies"),
  ];
  for (const path of protectedPaths) {
    for (const toolName of ["read", "grep", "bash"]) {
      const input = toolName === "bash" ? { command: `head -c 100 '${path}'` } : { path };
      const response = await call(toolName, input);
      assert.equal(response.result?.block, true, `${toolName}: ${path}`);
      assert.deepEqual(response.prompts, [], path);
      assert.deepEqual(response.requests, [], path);
    }
  }
});

test("credential directory policies apply inside the current directory", async () => {
  const path = join(homedir(), ".ssh/id_ed25519");
  const response = await call("read", { path }, { cwd: homedir() });
  assert.equal(response.result?.block, true);
  assert.deepEqual(response.prompts, []);
  assert.deepEqual(response.requests, []);
});

test("credential and session-token extraction commands have no approval path", async () => {
  const commands = [
    "env", "env | grep TOKEN", "printenv API_TOKEN", "set", "export -p", "declare -p API_TOKEN",
    "node -p process.env", "python3 -c 'print(os.environ)'", 'printf "%s" "$API_TOKEN"',
    "gh auth token", "gcloud auth print-access-token", "aws configure get aws_secret_access_key",
    "aws sso get-role-credentials", "az account get-access-token", "security find-generic-password -w",
    "kubectl config view --raw", "git credential fill", "docker-credential-osxkeychain get",
    "op read op://vault/item/password", "bw get password item", "vault kv get secret/item",
  ];
  for (const command of commands) {
    const response = await call("bash", { command });
    assert.equal(response.result?.block, true, command);
    assert.deepEqual(response.prompts, [], command);
    assert.deepEqual(response.requests, [], command);
  }
});

test("Git push with global options has no approval path", async () => {
  for (const command of [
    "git -C /work/project push origin main",
    "git --no-pager push origin main",
    "git -c core.hooksPath=/dev/null push --force",
    "git --git-dir=/work/project/.git push origin main",
  ]) {
    const response = await call("bash", { command });
    assert.equal(response.result?.block, true, command);
    assert.deepEqual(response.prompts, [], command);
    assert.deepEqual(response.requests, [], command);
  }
});

test("ECR credential extraction has no approval path", async () => {
  for (const command of [
    "aws ecr get-login-password",
    "aws --region region-value ecr get-login-password",
    "aws ecr --region region-value get-login-password",
    "aws ecr-public get-authorization-token",
  ]) {
    const response = await call("bash", { command });
    assert.equal(response.result?.block, true, command);
    assert.deepEqual(response.prompts, [], command);
    assert.deepEqual(response.requests, [], command);
  }
});

const resultRunner = new ExtensionRunner(loaded.extensions, loaded.runtime, cwd, {}, {});
const resultErrors = [];
resultRunner.onError(error => resultErrors.push(error));
const syntheticJwt = [
  { alg: "HS256", typ: "JWT" },
  { sub: "synthetic-test-subject", exp: 4_000_000_000 },
].map(value => Buffer.from(JSON.stringify(value)).toString("base64url")).concat(
  Buffer.from("synthetic-signature-not-valid").toString("base64url"),
).join(".");

async function toolResult(toolName, text, fields = {}) {
  return resultRunner.emitToolResult({
    type: "tool_result", toolName, toolCallId: "output-test", input: {},
    content: [{ type: "text", text }], isError: false, ...fields,
  });
}

test("token-like output is withheld from file, shell, script, and MCP results", async () => {
  for (const toolName of ["read", "bash", "codemode", "mcp__example__fetch"]) {
    const result = await toolResult(toolName, `Text with a token: ${syntheticJwt}`);
    assert.equal(result?.isError, true, toolName);
    assert.equal(JSON.stringify(result).includes(syntheticJwt), false, toolName);
    assert.match(result.content[0].text, /output blocked/i);
  }
  assert.deepEqual(resultErrors, []);
});

test("credential-like output formats also have no approval path", async () => {
  for (const text of [
    "ghp_" + "A".repeat(36), "sk-" + "A".repeat(40), "xoxb-" + "1".repeat(30),
    "-----BEGIN " + "PRIVATE KEY-----\nsynthetic-test-data",
    JSON.stringify({ password: "synthetic" }),
    JSON.stringify({ apiKey: "synthetic-not-a-real-key" }),
  ]) {
    const result = await toolResult("read", text);
    assert.equal(result?.isError, true);
    assert.equal(JSON.stringify(result).includes(text), false);
  }
  assert.deepEqual(resultErrors, []);
});

test("sensitive structured content and details do not survive an output block", async () => {
  for (const fields of [
    { structuredContent: { access_token: syntheticJwt }, details: { privateData: "synthetic" } },
    { details: { rawResult: syntheticJwt }, structuredContent: { privateData: "synthetic" } },
  ]) {
    const result = await toolResult("mcp__example__fetch", "Complete", fields);
    assert.equal(result?.isError, true);
    assert.deepEqual(result.details, {});
    assert.equal(result.structuredContent, undefined);
    assert.equal(JSON.stringify(result).includes(syntheticJwt), false);
  }
});

test("ordinary tool output stays unchanged", async () => {
  const result = await toolResult("read", "Ordinary source code with no credential values.", { details: { lines: 1 } });
  assert.equal(result, undefined);
  assert.deepEqual(resultErrors, []);
});

test("an output scan error fails closed", async () => {
  const details = {};
  details.circular = details;
  const result = await toolResult("read", "Complete", { details });
  assert.equal(result?.isError, true);
  assert.deepEqual(result.details, {});
  assert.deepEqual(resultErrors, []);
});

test("ordinary source files and shell setup remain available", async () => {
  for (const path of [join(cwd, "src/auth.ts"), join(cwd, "src/credentials.ts"), join(cwd, "README.md")]) {
    const response = await call("read", { path });
    assert.equal(response.result, undefined, path);
  }
  const response = await call("bash", { command: "set -e; pwd" });
  assert.equal(response.result, undefined);
  assert.deepEqual(response.prompts, []);
  assert.deepEqual(response.requests, []);
});

test("non-interactive calls still fail closed", async () => {
  for (const command of ["git status --short", "ls /var/log"]) {
    const { result, prompts, requests } = await call("bash", { command }, { hasUI: false });
    assert.equal(result?.block, true);
    assert.deepEqual(prompts, []);
    assert.deepEqual(requests, []);
  }
});

test("RPC prompts still work when the classifier does not approve", async () => {
  const { result, prompts } = await call("bash", { command: "rm -rf ./src" }, { error: true, rpc: true });
  assert.equal(result?.block, true);
  assert.deepEqual(prompts, ["custom", "select"]);
});

test("an aborted turn cannot receive classifier approval", async () => {
  const signal = AbortSignal.abort();
  const { result } = await call("bash", { command: "git status --short" }, { signal });
  assert.equal(result?.block, true);
});

test("the approval threshold includes valid probabilities from 0.9 through 1", async () => {
  for (const probability of [0.9, 1]) {
    const result = { stopReason: "stop", answers: { safe: { type: "bool", probability } } };
    const response = await call("bash", { command: "git status --short" }, { result });
    assert.equal(response.result, undefined);
    assert.deepEqual(response.prompts, []);
  }
});

test("the adapter leaves Bash and user Bash on the built-in executor", () => {
  const extension = loaded.extensions.find(extension => extension.path === adapter);
  assert.ok(extension);
  assert.equal(extension.tools.size, 0);
  assert.equal(extension.handlers.has("user_bash"), false);
  assert.equal(extension.commands.has("guardrails:approve"), false);
});

test("ordinary scripts and home-directory Bash have no custom command gate", async () => {
  for (const command of ["pwd", "node --version", "bash ./build.sh"]) {
    const response = await call("bash", { command }, { cwd: homedir() });
    assert.equal(response.result, undefined, command);
    assert.deepEqual(response.prompts, [], command);
    assert.deepEqual(response.requests, [], command);
  }
});

test("Git merge-base and a normal inspection batch need no manual command grant", async () => {
  for (const command of [
    "git merge-base HEAD origin/main",
    "pwd; git status --short --branch; git log -3 --oneline; git merge-base HEAD origin/main; ls -la AGENTS.md CLAUDE.md tests/AGENTS.md; rg -n -F -e 'func RunExample' -e 'func TestExample' tests/example_test.go; rg -n -F -e 'OpenExample' -e 'WithOption' src/example.go",
  ]) {
    const response = await call("bash", { command });
    assert.equal(response.result, undefined, command);
    assert.deepEqual(response.prompts, [], command);
  }
});

test("ordinary commands do not call the classifier", async () => {
  const { result, prompts, requests } = await call("bash", { command: "pwd" });
  assert.equal(result, undefined);
  assert.deepEqual(prompts, []);
  assert.deepEqual(requests, []);
});

test("an adapter dependency failure blocks tools", async () => {
  if (process.env.GUARDRAILS_BASELINE) return;
  process.env.PI_CODING_AGENT_DIR = join(root, "missing-agent");
  try {
    const failed = await loadExtensions([adapter], cwd);
    assert.deepEqual(failed.errors, []);
    const [guard] = failed.extensions[0].handlers.get("tool_call");
    const result = await guard({ toolName: "bash", input: { command: "pwd" } }, { cwd });
    assert.equal(result?.block, true);
    assert.match(result.reason, /failed to load/);
  } finally {
    process.env.PI_CODING_AGENT_DIR = testAgent;
  }
});
