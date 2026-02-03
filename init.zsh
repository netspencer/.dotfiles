#!/usr/bin/env zsh
# ~/.dotfiles/init.zsh
# Source of truth - this loads everything
#
# Structure:
#   path.zsh       - PATH and environment variables
#   aliases.zsh    - Short commands and shortcuts
#   functions.zsh  - Reusable shell functions
#   tools/         - Standalone tools (ssm, etc.)
#   completions/   - Custom tab completions
#   prompt.zsh     - Prompt (starship)

DOTFILES="$HOME/.dotfiles"

# Load in order
source "$DOTFILES/path.zsh"
source "$DOTFILES/aliases.zsh"
source "$DOTFILES/functions.zsh"
source "$DOTFILES/plugins.zsh"

# Load all tools
for tool in "$DOTFILES/tools/"*.zsh(N); do
  source "$tool"
done

# Load completions
for comp in "$DOTFILES/completions/"*.zsh(N); do
  source "$comp"
done

# Prompt last
source "$DOTFILES/prompt.zsh"
