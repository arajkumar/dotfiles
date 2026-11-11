# AGENTS.md

## Scope

This repo contains personal dotfiles for macOS, command-line tools, and Pi.
Changes can affect live tools through symlinks.

- Work on the current branch. This repo does not require a new branch or PR.
- Do not commit unless the user requests a commit.
- Do not push to remotes.
- Before edits, check the current branch, comparison base, and local changes.
- Preserve all pre-existing local changes.

## Work Rules

- Before code changes, state assumptions and the scope of the change.
- If the request is unclear, ask before edits.
- For tasks with multiple steps, state a brief plan with a check for each step.
- For code changes and reviews, use the `ponytail` skill if available.
- Use existing patterns before new code or dependencies.
- Change only what the request needs.
- Match the style of each file.
- Do not change unrelated code, comments, or format.
- Remove only code that your change makes unused.
- Use short, direct sentences in responses, comments, and docs.
- Do not add AI attribution to commits or PR text.

## Repo Map

- `vimrc` and `gvimrc`: Vim and Neovim configuration.
- `tmux.conf` and `tmux-mru`: tmux configuration and window history helper.
- `gitconfig` and `hgrc`: Git and Mercurial configuration.
- `Brewfile`: Homebrew packages.
- `bootstrap.sh`: Neovim setup, system packages, language servers, and plugins.
- `pi/install.sh`: Pi configuration installer.
- `pi/agent/`: Pi configuration, global agent instructions, and the Guardrails adapter.
- `pi/tests/guardrails-classifier.test.mjs`: Focused Guardrails tests.
- `README.md`: Setup instructions, security limits, and test requirements.

## Dotfiles Safety

- Edit tracked source files, not installed copies or symlink targets outside the repo.
- Do not run installers or reload live tools unless the user requests it.
- Do not replace local files, symlinks, or backups without user approval.
- Do not install packages as a check. `bootstrap.sh` changes the host and can download plugins.
- For tests that write configuration, use a temporary home or configuration directory.
- Keep credentials, auth files, session data, caches, and local research notes out of Git.

## Pi Configuration

- Read `README.md` before changes to Pi configuration or Guardrails.
- `pi/agent/AGENTS.md` supplies global Pi instructions, not just rules for this repo.
- Most files from `pi/install.sh` become symlinks under `~/.pi`.
- The installer preserves existing files as `.bak` backups and stops on backup conflicts.
- Warden uses a private local config file, not a symlink.
- Edit `pi/agent/pi-warden/config.json` for permanent Warden changes.
- Preserve the live Warden config before an installer run after a template change.
- For a new tracked Pi file, check the allowlist in `pi/.gitignore`.
- If the installer must deploy that file, update its file list in `pi/install.sh`.
- Preserve explicit denies, file protection policies, and approval checks in Guardrails.
- Before a Guardrails package upgrade, check adapter compatibility and run its focused tests.

## Verification

- For a bug fix, add a permanent regression test and confirm that it fails without the fix.
- Test changed behavior through its actual caller.
- After the final edit, run the relevant checks.
- For shell changes, run `bash -n` on each changed script.
- For Guardrails changes, run `node --test pi/tests/guardrails-classifier.test.mjs`.
- The Guardrails tests require a managed Pi install and its installed Guardrails package.
- Use temporary files and fake classifier results for Guardrails tests, not live credentials or network calls.
- For JSON changes, parse each changed file as JSON.
- For documentation changes, check paths, commands, and whitespace.
- Before completion, inspect the full diff against the comparison base, plus any new files.
- Report changed files, check commands, actual results, and checks that did not run.
