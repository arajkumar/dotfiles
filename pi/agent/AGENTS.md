# CLAUDE.md / AGENTS.md

Behavioral guidelines to reduce common LLM coding mistakes.

## Writing Style

Use ASD-STE100 Simplified Technical English (STE) for all text you write: responses, code comments, docs, commit messages, and PR text. Approved words only. Max 20 words per sentence in instructions, 25 in descriptions. Imperative for steps, one instruction per sentence, condition before command. Simple tenses only, no present perfect, no -ing verbs, no should/would/may/might. Active voice. One word per meaning, no synonym rotation. No contractions, keep articles and "that". Delete filler: simply, robust, seamlessly, leverage. Code and identifiers stay exact.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

Use skill /ponytail:ponytail to simplify your thoughts and code

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't add verbose and obvious comments
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When committing changes to git or creating PRs on github:
- Never run `git push` in any form (`git push`, `git push -f`, `--push`, etc.). Do not push to remotes. Leave pushing to the user. If a task seems to require pushing, stop and ask.
- Commits must be incremental. One logical change = one commit. Make separate commits as you go; do not stage everything into one commit at the end.
- Don't add Claude as Co-Author to git commits.
- Branch name: `arajkumar/<brief-problem>` or `arajkumar/<ticket-id>-<brief-problem>` (kebab-case).
- Commit/PR title and body: human tone, no em-dashes.
- Use `gh` CLI to manipulate github PR/issue title/description or inspecting actions run failures.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
