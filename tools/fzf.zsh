#!/usr/bin/env zsh
# ~/.dotfiles/tools/fzf.zsh
# Fuzzy finder configuration
#
# Keybindings:
#   Ctrl-R  - Search command history
#   Ctrl-T  - Search files, insert path
#   Alt-C   - Search directories, cd into selection

command -v fzf >/dev/null || return

# Use fd for file listing (faster, respects .gitignore)
if command -v fd >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Default options
export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border
  --info=inline
  --marker='✓'
  --pointer='▶'
  --prompt='❯ '
"

# Preview with bat for files
if command -v bat >/dev/null; then
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}'"
fi

# Preview with eza for directories
if command -v eza >/dev/null; then
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"
fi

# Better history search
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window down:3:wrap
"

# Load fzf keybindings and completion
# Homebrew installs these to different locations based on architecture
: ${HOMEBREW_PREFIX:=/usr/local}

[[ -f "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]] && \
  source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"

[[ -f "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh" ]] && \
  source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
