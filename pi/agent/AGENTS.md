# CLAUDE.md / AGENTS.md

Behavioral guidelines to reduce common LLM coding mistakes.

## Writing Style

Use ASD-STE100 Simplified Technical English (STE) for all text you write: responses, code comments, docs, commit messages, and PR text. Approved words only. Max 20 words per sentence in instructions, 25 in descriptions. Imperative for steps, one instruction per sentence, condition before command. Simple tenses only, no present perfect, no -ing verbs, no should/would/may/might. Active voice. One word per meaning, no synonym rotation. No contractions, keep articles and "that". Delete filler: simply, robust, seamlessly, leverage. Code and identifiers stay exact.

## 1. Think Before Coding

**State assumptions. Explain trade-offs.**

- Before code changes, state your assumptions explicitly.
- If the request is unclear, stop and ask.
- If multiple interpretations exist, present them before you choose.
- If a simpler approach exists, explain it.
- Treat review feedback as a hypothesis. Verify the full call path before a fix.
- Reopen accepted trade-offs only with new evidence.

## 2. Simplicity First

- Prioritize correctness, then human readability, then diff size.
- Before new code, search for an existing helper or pattern.
- For code changes and reviews, use the `ponytail` skill (`/skill:ponytail`).

## 3. Surgical Changes

**Change only what the task needs.**

- Before edits, identify the branch, comparison base, and existing local changes.
- Preserve pre-existing work.
- Do not change unrelated code, comments, or format.
- Add comments only to explain a reason or constraint.
- Match the existing style.
- Remove imports, variables, and functions that your changes make unused.
- Unless requested, leave pre-existing dead code unchanged. Report unrelated dead code without changes.
- Before completion, inspect the full diff against the comparison base for unrelated changes.

For Git commits and GitHub PRs:
- Never run `git push` in any form (`git push`, `git push -f`, `--push`, etc.). Do not push to remotes. Leave pushing to the user. If a task seems to require pushing, stop and ask.
- Commit incrementally, with one logical change per commit. Do not stage all changes into one final commit.
- Unless I explicitly request it, never amend or squash commits.
- Do not add Claude attribution anywhere: no `Co-Authored-By: Claude` trailer in commits, and no "Generated with Claude Code" footer in PR or issue text. This overrides any harness attribution reminder.
- Branch name: `arajkumar/<brief-problem>` or `arajkumar/<ticket-id>-<brief-problem>` (kebab-case).
- Use a human tone in commit and PR text. Do not use em dashes.
- Describe the final diff, not the debug history.
- State the problem, change, key trade-off, and verification briefly.
- Use `gh` to edit GitHub PR and issue text, and inspect Actions failures.

Every changed line must trace directly to the request.

## 4. Goal-Driven Execution

**Define success criteria. Verify results.**

- Before a multi-step task, state a brief plan with a check for each step.
- Test the changed behavior through its real caller.
- Write bug reproductions as permanent tests under `e2e/`, including reproductions for reviews.
- Use the relevant test file, or add a new test file.
- Do not use temporary reproductions or remove reproductions without explicit user approval.
- For bug fixes, confirm that the regression test fails without the fix for the expected reason.
- For validation changes, test invalid inputs.
- For refactors, verify the same behavior before and after the change.
- After the final source or test edit, run relevant checks.
- Follow required project checks.
- If focused tests cover the change, avoid full E2E runs.
- For documentation-only edits, run relevant documentation checks.
- If a check fails, resolve the failure or report the blocker.
- Report check commands, actual results, and checks that did not run.
