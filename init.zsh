#!/usr/bin/env zsh
# ~/.dotfiles/init.zsh
# Main loader - source this from your .zshrc
#
# Structure:
#   aliases.zsh    - Short commands and shortcuts
#   functions.zsh  - Reusable shell functions
#   tools/         - Standalone tools (ssm, etc.)
#   completions/   - Custom tab completions

DOTFILES="$HOME/.dotfiles"

# Load core files
[[ -f "$DOTFILES/aliases.zsh" ]] && source "$DOTFILES/aliases.zsh"
[[ -f "$DOTFILES/functions.zsh" ]] && source "$DOTFILES/functions.zsh"

# Load all tools
for tool in "$DOTFILES/tools/"*.zsh(N); do
  source "$tool"
done

# Load completions
for comp in "$DOTFILES/completions/"*.zsh(N); do
  source "$comp"
done
