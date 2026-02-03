# ~/.dotfiles/config.nu
# Source of truth - this loads everything
#
# Structure:
#   env.nu         - PATH and environment variables (loaded before this)
#   aliases.nu     - Short commands and shortcuts
#   functions.nu   - Reusable shell functions
#   tools/         - Standalone tools (zoxide, delta, etc.)
#   completions/   - Custom tab completions

# ─────────────────────────────────────────────────────────────
# Nushell Configuration
# ─────────────────────────────────────────────────────────────
$env.config = {
    show_banner: false

    # Completions
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"  # Built-in fuzzy matching (replaces fzf for completions)
    }

    # History
    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "sqlite"  # Better history with sqlite
    }

    # Appearance
    cursor_shape: {
        emacs: line
        vi_insert: line
        vi_normal: block
    }

    # Edit mode
    edit_mode: emacs

    # Hooks
    hooks: {
        pre_prompt: [{||
            # Direnv hook - load/unload env vars on directory change
            if (which direnv | is-not-empty) {
                let direnv_result = (direnv export json | complete)
                if $direnv_result.exit_code == 0 and ($direnv_result.stdout | str trim | is-not-empty) {
                    let changes = ($direnv_result.stdout | from json)
                    $changes | transpose key value | each { |row|
                        if ($row.value == null) {
                            hide-env $row.key
                        } else {
                            load-env { ($row.key): $row.value }
                        }
                    }
                }
            }
        }]
        pre_execution: []
        env_change: {
            PWD: [{||
                # Auto-update terminal title to current directory
                if ($env.DISABLE_AUTO_TITLE? | is-empty) {
                    print -n $"\e]1;(pwd | path basename)\a"
                }
            }]
        }
    }
}

# ─────────────────────────────────────────────────────────────
# Load modules
# ─────────────────────────────────────────────────────────────
source ~/.dotfiles/aliases.nu
source ~/.dotfiles/functions.nu

# Load all tools
source ~/.dotfiles/tools/delta.nu
source ~/.dotfiles/tools/direnv.nu
source ~/.dotfiles/tools/fzf.nu
source ~/.dotfiles/tools/ssm.nu
source ~/.dotfiles/tools/zoxide.nu

# ─────────────────────────────────────────────────────────────
# Conditional Aliases (modern tool replacements)
# ─────────────────────────────────────────────────────────────

# bat: better cat
if (which bat | is-not-empty) {
    alias cat = bat --paging=never
}

# eza: better ls
if (which eza | is-not-empty) {
    alias ls = eza
    alias ll = eza -la --git
    alias la = eza -a
    alias l = eza -F
    alias tree = eza --tree
}

# fd: better find
if (which fd | is-not-empty) {
    alias find = fd
}

# ripgrep: better grep
if (which rg | is-not-empty) {
    alias grep = rg
}

# btop: better top
if (which btop | is-not-empty) {
    alias top = btop
}

# dust: better du
if (which dust | is-not-empty) {
    alias du = dust
}

# ─────────────────────────────────────────────────────────────
# Prompt (Starship)
# ─────────────────────────────────────────────────────────────
# Load cached starship init for fast startup
# Run setup.sh to regenerate: starship init nu > ~/.cache/starship.nu
let starship_cache = ($env.HOME | path join ".cache/starship.nu")
if ($starship_cache | path exists) {
    source ~/.cache/starship.nu
}
