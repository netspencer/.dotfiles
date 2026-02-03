#!/usr/bin/env bash
# ~/.dotfiles/setup.sh
# Bootstrap script for fresh installs
#
# Usage: cd ~/.dotfiles && ./setup.sh

set -e

DOTFILES="$HOME/.dotfiles"

echo "═══════════════════════════════════════════════════════════"
echo " Dotfiles Setup"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────
# Homebrew
# ─────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "→ Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for this session
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "✓ Homebrew already installed"
fi

# ─────────────────────────────────────────────────────────────
# Install packages from Brewfile
# ─────────────────────────────────────────────────────────────
echo ""
echo "→ Installing packages from Brewfile..."
brew bundle --file="$DOTFILES/Brewfile"

# ─────────────────────────────────────────────────────────────
# Link .zshrc
# ─────────────────────────────────────────────────────────────
echo ""
if [[ -f "$HOME/.zshrc" ]] && ! grep -q "source.*init.zsh" "$HOME/.zshrc"; then
  echo "→ Backing up existing .zshrc to .zshrc.backup"
  cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi

if ! grep -q "source.*init.zsh" "$HOME/.zshrc" 2>/dev/null; then
  echo "→ Adding dotfiles source to .zshrc"
  echo "" >> "$HOME/.zshrc"
  echo "# Load dotfiles" >> "$HOME/.zshrc"
  echo "source \"\$HOME/.dotfiles/init.zsh\"" >> "$HOME/.zshrc"
else
  echo "✓ .zshrc already sources dotfiles"
fi

# ─────────────────────────────────────────────────────────────
# Configure git-delta
# ─────────────────────────────────────────────────────────────
echo ""
echo "→ Configuring git to use delta..."
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.side-by-side true
git config --global delta.line-numbers true

# ─────────────────────────────────────────────────────────────
# fzf key bindings
# ─────────────────────────────────────────────────────────────
echo ""
echo "→ Installing fzf key bindings..."
if [[ -f "$(brew --prefix)/opt/fzf/install" ]]; then
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

# ─────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════"
echo " Setup complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Run: exec zsh"
echo ""
echo "Then test:"
echo "  Ctrl-R  → fzf history search"
echo "  Ctrl-T  → fzf file picker"
echo "  z       → smart cd (learns from usage)"
echo "  ls      → eza with colors"
echo "  cat     → bat with syntax highlighting"
echo "  git diff → delta side-by-side"
echo ""
