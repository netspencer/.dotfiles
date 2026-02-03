# ~/.dotfiles/tools/zoxide.nu
# Smart directory jumping
#
# Usage:
#   z foo       Jump to most-used directory matching "foo"
#   z foo bar   Jump to directory matching "foo" then "bar"
#   zi          Interactive selection with fzf
#   z -         Jump to previous directory
#
# Run setup.sh to regenerate: zoxide init nushell > ~/.cache/zoxide.nu

# Guard: only load if zoxide is installed
if (which zoxide | is-empty) { return }

# Load cached zoxide init (creates z, zi commands)
let zoxide_cache = ($env.HOME | path join ".cache/zoxide.nu")
if ($zoxide_cache | path exists) {
    source ~/.cache/zoxide.nu
}
