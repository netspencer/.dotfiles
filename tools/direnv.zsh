#!/usr/bin/env zsh
# ~/.dotfiles/tools/direnv.zsh
# Per-directory environment variables
#
# Usage:
#   Create .envrc in any directory with:
#     export DATABASE_URL="..."
#     export API_KEY="..."
#
#   Then: direnv allow
#
# Variables auto-load when entering the directory,
# auto-unload when leaving.

command -v direnv >/dev/null || return

# Hook direnv into zsh
eval "$(direnv hook zsh)"

# Silence the loading message (optional, comment out if you want verbosity)
export DIRENV_LOG_FORMAT=""
