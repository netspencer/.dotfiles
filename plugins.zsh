#!/usr/bin/env zsh
# ~/.dotfiles/plugins.zsh
# Zsh plugins - load order matters!
#
# autosuggestions MUST load before syntax-highlighting

# Use HOMEBREW_PREFIX for Apple Silicon compatibility
# Falls back to Intel path if not set
: ${HOMEBREW_PREFIX:=/usr/local}

# zsh-autosuggestions
if [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  # Subtle suggestion color (comment gray)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"
  # Accept suggestion with right arrow or end
  ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(end-of-line vi-end-of-line vi-forward-char forward-char)
fi

# zsh-syntax-highlighting (must be last)
if [[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
