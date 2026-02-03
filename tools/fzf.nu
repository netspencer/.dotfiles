# ~/.dotfiles/tools/fzf.nu
# Fuzzy finder configuration
#
# Note: Nushell has built-in fuzzy completion (completions.algorithm: "fuzzy")
# These env vars configure fzf when invoked directly or by other tools.

# Guard: only load if fzf is installed
if (which fzf | is-empty) { return }

# Use fd for file listing (faster, respects .gitignore)
if (which fd | is-not-empty) {
    $env.FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
    $env.FZF_CTRL_T_COMMAND = $env.FZF_DEFAULT_COMMAND
    $env.FZF_ALT_C_COMMAND = 'fd --type d --hidden --follow --exclude .git'
}

# Default options
$env.FZF_DEFAULT_OPTS = "
  --height 40%
  --layout=reverse
  --border
  --info=inline
  --marker='✓'
  --pointer='▶'
  --prompt='❯ '
"

# Preview with bat for files
if (which bat | is-not-empty) {
    $env.FZF_CTRL_T_OPTS = "--preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}'"
}

# Preview with eza for directories
if (which eza | is-not-empty) {
    $env.FZF_ALT_C_OPTS = "--preview 'eza --tree --level=2 --color=always {}'"
}

# Better history search
$env.FZF_CTRL_R_OPTS = "
  --preview 'echo {}'
  --preview-window down:3:wrap
"
