#!/usr/bin/env bash
# ~/.dotfiles/setup.sh
# Bootstrap script for fresh installs
#
# Usage: cd ~/.dotfiles && ./setup.sh

set -e

DOTFILES="$HOME/.dotfiles"
CACHE_DIR="$HOME/.cache"

# Nushell config path differs by OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  NUSHELL_CONFIG="$HOME/Library/Application Support/nushell"
else
  NUSHELL_CONFIG="$HOME/.config/nushell"
fi

echo "═══════════════════════════════════════════════════════════"
echo " Dotfiles Setup (Nushell)"
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
# Link Nushell config
# ─────────────────────────────────────────────────────────────
echo ""
echo "→ Setting up Nushell configuration..."
mkdir -p "$NUSHELL_CONFIG"

# Link env.nu
if [[ -L "$NUSHELL_CONFIG/env.nu" ]]; then
  echo "✓ env.nu already linked"
elif [[ -f "$NUSHELL_CONFIG/env.nu" ]]; then
  echo "→ Backing up existing env.nu"
  mv "$NUSHELL_CONFIG/env.nu" "$NUSHELL_CONFIG/env.nu.backup"
  ln -s "$DOTFILES/env.nu" "$NUSHELL_CONFIG/env.nu"
else
  ln -s "$DOTFILES/env.nu" "$NUSHELL_CONFIG/env.nu"
fi

# Link config.nu
if [[ -L "$NUSHELL_CONFIG/config.nu" ]]; then
  echo "✓ config.nu already linked"
elif [[ -f "$NUSHELL_CONFIG/config.nu" ]]; then
  echo "→ Backing up existing config.nu"
  mv "$NUSHELL_CONFIG/config.nu" "$NUSHELL_CONFIG/config.nu.backup"
  ln -s "$DOTFILES/config.nu" "$NUSHELL_CONFIG/config.nu"
else
  ln -s "$DOTFILES/config.nu" "$NUSHELL_CONFIG/config.nu"
fi

echo "✓ Nushell config linked"

# ─────────────────────────────────────────────────────────────
# Generate cached tool init scripts (for fast startup)
# ─────────────────────────────────────────────────────────────
echo ""
echo "→ Generating tool init caches..."
mkdir -p "$CACHE_DIR"

# Starship prompt
if command -v starship &>/dev/null; then
  starship init nu > "$CACHE_DIR/starship.nu"
  echo "  ✓ starship.nu"
fi

# Zoxide (smart cd)
if command -v zoxide &>/dev/null; then
  zoxide init nushell > "$CACHE_DIR/zoxide.nu"
  echo "  ✓ zoxide.nu"
fi

# Direnv: no cache needed - handled natively in config.nu
# (direnv doesn't have native nushell support)
if command -v direnv &>/dev/null; then
  echo "  ✓ direnv (native hook in config.nu)"
fi

# Mise (version manager - replaces pyenv)
if command -v mise &>/dev/null; then
  mise activate nu > "$CACHE_DIR/mise.nu"
  echo "  ✓ mise.nu"
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
# Set default shell (optional)
# ─────────────────────────────────────────────────────────────
echo ""
NU_PATH=$(which nu)
if [[ -n "$NU_PATH" ]]; then
  if ! grep -q "$NU_PATH" /etc/shells; then
    echo "→ Adding nushell to /etc/shells (requires sudo)..."
    echo "$NU_PATH" | sudo tee -a /etc/shells
  fi

  if [[ "$SHELL" != "$NU_PATH" ]]; then
    echo ""
    echo "To make nushell your default shell, run:"
    echo "  chsh -s $NU_PATH"
  else
    echo "✓ Nushell is already your default shell"
  fi
fi

# ─────────────────────────────────────────────────────────────
# Migrate Python versions from pyenv to mise (if applicable)
# ─────────────────────────────────────────────────────────────
if command -v mise &>/dev/null && [[ -d "$HOME/.pyenv/versions" ]]; then
  echo ""
  echo "Note: You have pyenv Python versions installed."
  echo "To migrate to mise, run:"
  echo "  mise use python@<version>  # for each version you need"
  echo ""
  echo "Check available versions with: mise ls-remote python"
fi

# ─────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════"
echo " Setup complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Start nushell with: nu"
echo ""
echo "Or make it your default shell:"
echo "  chsh -s $(which nu)"
echo ""
echo "Then test:"
echo "  z        → smart cd (learns from usage)"
echo "  ls       → eza with colors"
echo "  cat      → bat with syntax highlighting"
echo "  git diff → delta side-by-side"
echo ""
echo "Nushell built-in features (no plugins needed):"
echo "  Tab      → fuzzy completion"
echo "  ↑        → history with autosuggestions"
echo "  Syntax   → automatic highlighting"
echo ""
