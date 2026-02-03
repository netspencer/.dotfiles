# ~/.dotfiles/tools/delta.nu
# Better git diffs with delta
#
# Requires one-time git config (run setup.sh or manually):
#   git config --global core.pager delta
#   git config --global interactive.diffFilter 'delta --color-only'
#   git config --global delta.navigate true
#   git config --global delta.side-by-side true
#   git config --global delta.line-numbers true
#
# Once configured, all git diff/log/show commands use delta automatically.

# Guard: only load if delta is installed
if (which delta | is-empty) { return }

# Aliases for common diff operations
alias gdd = git diff            # delta makes this side-by-side
alias gdds = git diff --staged  # staged changes
alias gdw = git diff --word-diff=color  # word-level diff
