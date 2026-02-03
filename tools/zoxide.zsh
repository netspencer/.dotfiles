#!/usr/bin/env zsh
# ~/.dotfiles/tools/zoxide.zsh
# Smart directory jumping
#
# Usage:
#   z foo       Jump to most-used directory matching "foo"
#   z foo bar   Jump to directory matching "foo" then "bar"
#   zi          Interactive selection with fzf
#   z -         Jump to previous directory

command -v zoxide >/dev/null || return

# Initialize zoxide
# Creates: z, zi commands
eval "$(zoxide init zsh)"
