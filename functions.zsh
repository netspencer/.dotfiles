#!/usr/bin/env zsh
# ~/.dotfiles/functions.zsh
# Reusable shell functions

# ─────────────────────────────────────────────────────────────
# Directory operations
# ─────────────────────────────────────────────────────────────

# Create directory and cd into it
mkd() {
  mkdir -p "$@" && cd "$_"
}

# cd into whatever is in the frontmost Finder window
cdf() {
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

# ─────────────────────────────────────────────────────────────
# File utilities
# ─────────────────────────────────────────────────────────────

# Quick file size
fs() {
  if [[ -n "$1" ]]; then
    du -sh "$@"
  else
    du -sh ./*
  fi
}

# Extract any archive
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.tar.xz)  tar xJf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ─────────────────────────────────────────────────────────────
# Development
# ─────────────────────────────────────────────────────────────

# Quick HTTP server in current directory
serve() {
  local port="${1:-8000}"
  echo "Serving on http://localhost:$port"
  python3 -m http.server "$port"
}

# Open GitHub repo in browser (from current directory)
gh-open() {
  local url
  url=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
  if [[ -n "$url" ]]; then
    open "$url"
  else
    echo "Not a git repo or no origin remote"
  fi
}

# ─────────────────────────────────────────────────────────────
# Search & Find
# ─────────────────────────────────────────────────────────────

# Find file by name
ff() {
  find . -type f -iname "*$1*"
}

# Find directory by name
# Named fdir to avoid conflict with fd command
fdir() {
  find . -type d -iname "*$1*"
}

# Search file contents (grep with context)
search() {
  grep -rn --color=auto "$1" "${2:-.}"
}

# ─────────────────────────────────────────────────────────────
# Utilities
# ─────────────────────────────────────────────────────────────

# Quick notes - append to a notes file
note() {
  local notes_file="$HOME/notes.md"
  if [[ -n "$1" ]]; then
    echo "- $(date '+%Y-%m-%d %H:%M'): $*" >> "$notes_file"
    echo "Added note"
  else
    ${EDITOR:-vim} "$notes_file"
  fi
}

# Weather
weather() {
  curl -s "wttr.in/${1:-}"
}

# Cheatsheet
cheat() {
  curl -s "cheat.sh/$1"
}
