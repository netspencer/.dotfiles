# ~/.dotfiles/tools/direnv.nu
# Per-directory environment variables
#
# Usage:
#   Create .envrc in any directory with:
#     export DATABASE_URL="..."
#     export API_KEY="..."
#
#   Then: direnv allow
#
# Variables auto-load when entering the directory,
# auto-unload when leaving.
#
# Note: The direnv hook is in config.nu (pre_prompt hook)
# since direnv doesn't have native nushell support.

# Guard: only load if direnv is installed
if (which direnv | is-empty) { return }

# Silence the loading message
$env.DIRENV_LOG_FORMAT = ""
