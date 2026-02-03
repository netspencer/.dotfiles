#!/usr/bin/env zsh
# ~/.dotfiles/aliases.zsh
# Keep it tight. If it needs logic, it's a function.

# ─────────────────────────────────────────────────────────────
# Navigation
# ─────────────────────────────────────────────────────────────
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias d="cd ~/Developer/delphi/delphi"
alias dv="cd ~/Developer"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias dot="cd ~/.dotfiles"

# ─────────────────────────────────────────────────────────────
# Files & Directories
# ─────────────────────────────────────────────────────────────
alias ls="ls -G"
alias ll="ls -lah"
alias la="ls -a"
alias l="ls -F"

alias md="mkdir -p"
alias rd="rmdir"

# ─────────────────────────────────────────────────────────────
# Git (the essentials)
# ─────────────────────────────────────────────────────────────
alias g="git"
alias gs="git status"
alias gd="git diff"
alias gds="git diff --staged"
alias ga="git add"
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gl="git pull"
alias gco="git checkout"
alias gb="git branch"
alias glog="git log --oneline --graph -20"

# ─────────────────────────────────────────────────────────────
# Quick actions
# ─────────────────────────────────────────────────────────────
alias c="clear"
alias q="exit"
alias h="history"
alias reload="exec $SHELL -l"

# Copy pwd to clipboard
alias cpwd="pwd | tr -d '\n' | pbcopy && echo 'Copied to clipboard'"

# ─────────────────────────────────────────────────────────────
# Modern replacements (auto-enabled when tools are installed)
# ─────────────────────────────────────────────────────────────
command -v bat >/dev/null && alias cat="bat --paging=never"

if command -v eza >/dev/null; then
  alias ls="eza"
  alias ll="eza -la --git"
  alias la="eza -a"
  alias l="eza -F"
  alias tree="eza --tree"
fi

command -v fd >/dev/null && alias find="fd"
command -v rg >/dev/null && alias grep="rg"
command -v btop >/dev/null && alias top="btop"
command -v dust >/dev/null && alias du="dust"

# ─────────────────────────────────────────────────────────────
# Python
# ─────────────────────────────────────────────────────────────
alias python="python3"
alias pip="pip3"
alias venv="python3 -m venv"
alias activate="source .venv/bin/activate"

# ─────────────────────────────────────────────────────────────
# macOS
# ─────────────────────────────────────────────────────────────
alias finder="open -a Finder ."
alias showfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidefiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
alias flushdns="sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder"

# ─────────────────────────────────────────────────────────────
# Network
# ─────────────────────────────────────────────────────────────
alias ip="curl -s ifconfig.me"
alias localip="ipconfig getifaddr en0"
alias ports="lsof -iTCP -sTCP:LISTEN -P"
