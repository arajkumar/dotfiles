#!/usr/bin/env bash
# Minimal bootstrap for vim config. Idempotent: safe to re-run.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Symlink vimrc so Neovim finds it
ln -sfn "$DOTFILES/vimrc" "$HOME/.config/nvim/init.vim"

# 2. System dependencies (brew)
brew install neovim tree-sitter-cli git
brew install --cask font-fira-code 2>/dev/null || true

# 3. LSP servers (configure only the ones you use)
brew install gopls ccls
cargo install rust-analyzer || true
npm install -g pyright typescript-language-server || true

# 4. Open Neovim once to bootstrap plugins and treesitter parsers
nvim +PlugInstall +qa

echo "Done. Restart your shell if LSP servers were just installed."
