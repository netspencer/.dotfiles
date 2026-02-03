# ~/.dotfiles/aliases.nu
# Keep it tight. If it needs logic, it's a function.
# Conditional aliases (eza, bat, etc.) are in config.nu

# ─────────────────────────────────────────────────────────────
# Navigation
# ─────────────────────────────────────────────────────────────
alias d = cd ~/Developer/delphi/delphi
alias dv = cd ~/Developer
alias dl = cd ~/Downloads
alias dt = cd ~/Desktop
alias dot = cd ~/.dotfiles

# ─────────────────────────────────────────────────────────────
# Files & Directories
# ─────────────────────────────────────────────────────────────
alias md = mkdir

# ─────────────────────────────────────────────────────────────
# Git (the essentials)
# ─────────────────────────────────────────────────────────────
alias g = git
alias gs = git status
alias gd = git diff
alias gds = git diff --staged
alias ga = git add
alias gc = git commit
alias gcm = git commit -m
alias gp = git push
alias gl = git pull
alias gco = git checkout
alias gb = git branch
alias glog = git log --oneline --graph -20

# ─────────────────────────────────────────────────────────────
# Quick actions
# ─────────────────────────────────────────────────────────────
alias c = clear
alias q = exit
alias h = history

# ─────────────────────────────────────────────────────────────
# Python
# ─────────────────────────────────────────────────────────────
alias python = python3
alias pip = pip3
alias venv = python3 -m venv

# ─────────────────────────────────────────────────────────────
# macOS
# ─────────────────────────────────────────────────────────────
# Use ^open to call macOS open command (not nushell's open)
alias finder = ^open -a Finder .
# flushdns is a function in functions.nu (can't use ; in alias)

# ─────────────────────────────────────────────────────────────
# Network
# ─────────────────────────────────────────────────────────────
alias localip = ipconfig getifaddr en0
alias ports = lsof -iTCP -sTCP:LISTEN -P
