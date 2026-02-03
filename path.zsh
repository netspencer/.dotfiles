#!/usr/bin/env zsh
# ~/.dotfiles/path.zsh
# All PATH and environment setup lives here

# ─────────────────────────────────────────────────────────────
# Local binaries (claude, etc.)
# ─────────────────────────────────────────────────────────────
. "$HOME/.local/bin/env"

# ─────────────────────────────────────────────────────────────
# Python (pyenv)
# ─────────────────────────────────────────────────────────────
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# ─────────────────────────────────────────────────────────────
# Node / JS
# ─────────────────────────────────────────────────────────────
# pnpm
export PNPM_HOME="/Users/spencer/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/Users/spencer/.bun/_bun" ] && source "/Users/spencer/.bun/_bun"

# ─────────────────────────────────────────────────────────────
# Databases
# ─────────────────────────────────────────────────────────────
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# ─────────────────────────────────────────────────────────────
# Version managers
# ─────────────────────────────────────────────────────────────
# mise (if installed)
command -v mise >/dev/null && eval "$(mise activate zsh)"
