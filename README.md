Dotfiles
========

Contains configuration files for various tools like Vim, Mercurial, Git,..

Tools
=====

- vim
- ripgrep / ag
- fzf

Pi agent
========

Run `bash pi/install.sh` to install the Pi config files into `~/.pi`.
Bash and Node.js must be available.
Keep `tiger` on PATH for the Tiger MCP server.
The installer preserves existing files as `.bak` backups.
Run the installer again to check the config without a change.
If a backup exists and the live config differs from the expected config, the installer stops.

`pi/.gitignore` permits only the selected config files and the installer.
Do not add credentials to these files.
Keep credentials in Pi's untracked auth files or environment variables.
Session data, caches, installed packages, and local skill sources remain outside this repository.
Do not commit local audit or research notes.
The MCP OAuth client ID is public metadata, not a secret.

Most config files use symlinks.
For Warden, the installer expands `$HOME` in `pi/agent/pi-warden/config.json` and writes a private local config file.
Warden does not expand environment variables itself.
Edit the tracked template for a permanent change.
Warden commands change the local config, not the tracked template.
If the template changes, preserve the live Warden config.
Move that file aside before you run the installer.

Guardrails
----------

Outside-workspace reads do not require approval. File protection policies still apply.
Outside-workspace writes still require approval.
Known credential files and token stores have fixed `noAccess` policies, inside and outside the workspace.
These policies cover SSH keys, cloud credentials, CLI auth files, browser cookies, keychains, and Pi session files.
Fixed command denies block common token-extraction commands and environment dumps without an approval prompt.
The classifier cannot override these denies.
These tool checks do not provide OS isolation.
Symlink aliases, recursive directory scans, and computed paths can bypass file-path policies.
A strict isolation boundary requires a tool sandbox and restrictions on token variables.

The adapter also blocks final tool output with token-like values before model context.
It checks text, structured results, and result details, including MCP and nested tool results.
A match or scan error replaces the output with an error and removes its structured data and details.
This conservative check also blocks public token examples.
It does not undo tool actions, filter intermediate output events, or inspect images.
The ECR deny blocks registry credential extraction.
The Git push deny also checks common global options.

The local classifier adapter checks shell commands only when Guardrails requests approval.
It uses `openrouter/~typesafe/jev-latest` and the existing OpenRouter credentials.
Only a read-only decision with a probability of at least `0.90` clears the prompt.
That probability is not a safety guarantee.
A classifier error, a five-second timeout, or an uncertain result retains the prompt.
Explicit command denies and file protection policies stay in force.
Classifier approval applies once. It does not save path or command grants.

The classifier sends the current directory and full shell command to OpenRouter.
Inline data in a shell command also leaves the machine.
The adapter does not read files or send file-tool contents or conversation history.
The package entry excludes the original path and command gates because the adapter loads them itself.
Guardrails stays at `0.21.0` because the adapter depends on its prompt result values.
Before a package upgrade, check the adapter and run its tests.
If an adapter dependency fails, the adapter blocks tools until repair.
After an install or a config change, run `/reload` in Pi.

Run `node --test pi/tests/guardrails-classifier.test.mjs` for the focused checks.
The test requires a managed Pi install and its installed Guardrails package.
It uses temporary config files and fake classifier results. It does not execute the test shell commands.
