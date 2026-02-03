# ~/.dotfiles/env.nu
# All PATH and environment setup lives here
# This file is sourced before config.nu

# ─────────────────────────────────────────────────────────────
# Dotfiles location
# ─────────────────────────────────────────────────────────────
$env.DOTFILES = ($env.HOME | path join ".dotfiles")

# ─────────────────────────────────────────────────────────────
# Homebrew (Apple Silicon or Intel)
# ─────────────────────────────────────────────────────────────
$env.HOMEBREW_PREFIX = if ("/opt/homebrew" | path exists) {
    "/opt/homebrew"
} else {
    "/usr/local"
}

$env.PATH = ($env.PATH | prepend [
    ($env.HOMEBREW_PREFIX | path join "bin")
    ($env.HOMEBREW_PREFIX | path join "sbin")
])

# ─────────────────────────────────────────────────────────────
# Local binaries
# ─────────────────────────────────────────────────────────────
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".local/bin"))

# ─────────────────────────────────────────────────────────────
# Node / JS
# ─────────────────────────────────────────────────────────────
# pnpm
$env.PNPM_HOME = ($env.HOME | path join "Library/pnpm")
if ($env.PNPM_HOME | path exists) {
    $env.PATH = ($env.PATH | prepend $env.PNPM_HOME)
}

# bun
$env.BUN_INSTALL = ($env.HOME | path join ".bun")
if ($env.BUN_INSTALL | path exists) {
    $env.PATH = ($env.PATH | prepend ($env.BUN_INSTALL | path join "bin"))
}

# ─────────────────────────────────────────────────────────────
# Databases
# ─────────────────────────────────────────────────────────────
let pg_path = "/opt/homebrew/opt/postgresql@15/bin"
if ($pg_path | path exists) {
    $env.PATH = ($env.PATH | prepend $pg_path)
}

# ─────────────────────────────────────────────────────────────
# Version managers (mise)
# ─────────────────────────────────────────────────────────────
# mise replaces pyenv - use cached init for fast startup
# Run setup.sh to regenerate: mise activate nu > ~/.cache/mise.nu
let mise_cache = ($env.HOME | path join ".cache/mise.nu")
if ($mise_cache | path exists) {
    source ~/.cache/mise.nu
}

# ─────────────────────────────────────────────────────────────
# Editor
# ─────────────────────────────────────────────────────────────
$env.EDITOR = "vim"
$env.VISUAL = "vim"
