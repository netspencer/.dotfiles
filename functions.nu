# ~/.dotfiles/functions.nu
# Reusable shell functions

# ─────────────────────────────────────────────────────────────
# Directory operations
# ─────────────────────────────────────────────────────────────

# Create directory and cd into it
# Note: --env is required to change the parent shell's directory
def --env mkd [dir: path] {
    mkdir $dir
    cd $dir
}

# cd into whatever is in the frontmost Finder window
def --env cdf [] {
    let dir = (osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)' | str trim)
    cd $dir
}

# ─────────────────────────────────────────────────────────────
# File utilities
# ─────────────────────────────────────────────────────────────

# Quick file size
def fs [...paths: path] {
    if ($paths | is-empty) {
        ls | select name size
    } else {
        $paths | each { |p| ls $p | select name size } | flatten
    }
}

# Extract any archive
def extract [file: path] {
    if not ($file | path exists) {
        print $"'($file)' is not a valid file"
        return
    }

    match ($file | str downcase) {
        $f if ($f | str ends-with ".tar.bz2") => { tar xjf $file }
        $f if ($f | str ends-with ".tar.gz") => { tar xzf $file }
        $f if ($f | str ends-with ".tar.xz") => { tar xJf $file }
        $f if ($f | str ends-with ".bz2") => { bunzip2 $file }
        $f if ($f | str ends-with ".rar") => { unrar x $file }
        $f if ($f | str ends-with ".gz") => { gunzip $file }
        $f if ($f | str ends-with ".tar") => { tar xf $file }
        $f if ($f | str ends-with ".tbz2") => { tar xjf $file }
        $f if ($f | str ends-with ".tgz") => { tar xzf $file }
        $f if ($f | str ends-with ".zip") => { unzip $file }
        $f if ($f | str ends-with ".Z") => { uncompress $file }
        $f if ($f | str ends-with ".7z") => { 7z x $file }
        _ => { print $"'($file)' cannot be extracted" }
    }
}

# ─────────────────────────────────────────────────────────────
# macOS utilities
# ─────────────────────────────────────────────────────────────

# Flush DNS cache
def flushdns [] {
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    print "DNS cache flushed"
}

# ─────────────────────────────────────────────────────────────
# Development
# ─────────────────────────────────────────────────────────────

# Quick HTTP server in current directory
def serve [port?: int] {
    let p = ($port | default 8000)
    print $"Serving on http://localhost:($p)"
    python3 -m http.server $p
}

# Open GitHub repo in browser (from current directory)
def gh-open [] {
    let url = (git remote get-url origin
        | str replace "git@github.com:" "https://github.com/"
        | str replace ".git" ""
        | str trim)

    if ($url | is-empty) {
        print "Not a git repo or no origin remote"
    } else {
        open $url
    }
}

# ─────────────────────────────────────────────────────────────
# Search & Find
# ─────────────────────────────────────────────────────────────

# Find file by name
def ff [pattern: string] {
    glob $"**/*($pattern)*" | where { |p| ($p | path type) == "file" }
}

# Find directory by name
def fdir [pattern: string] {
    glob $"**/*($pattern)*" | where { |p| ($p | path type) == "dir" }
}

# Search file contents (grep with context)
def search [pattern: string, path?: path] {
    let search_path = ($path | default ".")
    grep -rn --color=auto $pattern $search_path
}

# ─────────────────────────────────────────────────────────────
# Utilities
# ─────────────────────────────────────────────────────────────

# Quick notes - append to a notes file
def note [...text: string] {
    let notes_file = ($env.HOME | path join "notes.md")

    if ($text | is-empty) {
        run-external ($env.EDITOR? | default "vim") $notes_file
    } else {
        let entry = $"- (date now | format date '%Y-%m-%d %H:%M'): ($text | str join ' ')"
        $entry | save --append $notes_file
        print "Added note"
    }
}

# Weather
def weather [location?: string] {
    let loc = ($location | default "")
    curl -s $"wttr.in/($loc)"
}

# Cheatsheet
def cheat [topic: string] {
    curl -s $"cheat.sh/($topic)"
}

# Reload shell configuration
def reload [] {
    exec nu
}

# Copy pwd to clipboard
def cpwd [] {
    pwd | pbcopy
    print "Copied to clipboard"
}

# Get public IP
def ip [] {
    curl -s ifconfig.me
}

# ─────────────────────────────────────────────────────────────
# Terminal Tab Titles
# ─────────────────────────────────────────────────────────────

# Set terminal tab title
# Usage: title "My Project" or just "title" to reset to current directory
def title [name?: string] {
    if ($name | is-empty) {
        # Reset to show current directory
        $env.DISABLE_AUTO_TITLE = null
        print -n $"\e]1;(pwd | path basename)\a"
    } else {
        # Set custom title and disable auto-title
        $env.DISABLE_AUTO_TITLE = true
        print -n $"\e]1;($name)\a"
    }
}

# Set window title
def wtitle [name: string] {
    print -n $"\e]2;($name)\a"
}

# ─────────────────────────────────────────────────────────────
# Python Virtual Environment
# ─────────────────────────────────────────────────────────────

# Activate Python virtual environment (nushell-native)
# Unlike bash's source .venv/bin/activate, nushell needs to modify env directly
def --env activate [venv_path?: path] {
    let venv = ($venv_path | default ".venv")

    if not ($venv | path exists) {
        print $"Virtual environment not found: ($venv)"
        print "Create one with: python -m venv .venv"
        return
    }

    let bin_path = ($venv | path join "bin")

    # Store original PATH for deactivate
    $env.VIRTUAL_ENV_ORIGINAL_PATH = $env.PATH
    $env.VIRTUAL_ENV = ($venv | path expand)

    # Prepend venv bin to PATH
    $env.PATH = ($env.PATH | prepend $bin_path)

    print $"Activated: ($env.VIRTUAL_ENV)"
}

# Deactivate Python virtual environment
def --env deactivate [] {
    if ($env.VIRTUAL_ENV? | is-empty) {
        print "No virtual environment active"
        return
    }

    # Restore original PATH
    if ($env.VIRTUAL_ENV_ORIGINAL_PATH? | is-not-empty) {
        $env.PATH = $env.VIRTUAL_ENV_ORIGINAL_PATH
    }

    let venv = $env.VIRTUAL_ENV
    $env.VIRTUAL_ENV = null
    $env.VIRTUAL_ENV_ORIGINAL_PATH = null

    print $"Deactivated: ($venv)"
}

# ─────────────────────────────────────────────────────────────
# LLM Bash Helper
# ─────────────────────────────────────────────────────────────

# Quick bash command from natural language
# Usage: ai "find all large files" or ai "compress this folder"
# Note: Simplified from zsh version (no edit option - nushell has no print -z equivalent)
def ai [...description: string] {
    if (which llm | is-empty) {
        print "llm not found. Install with: uv tool install llm"
        return
    }

    if ($description | is-empty) {
        print "Usage: ai <description>"
        print "Example: ai 'find files larger than 100MB'"
        return
    }

    let prompt = $"You are a bash command generator. Output ONLY the command, no explanation, no markdown, no backticks. The user wants: ($description | str join ' ')"
    let cmd = (llm -s $prompt | str trim)

    if ($cmd | is-empty) {
        print "Failed to generate command"
        return
    }

    print $"\e[1;34m→\e[0m ($cmd)"
    let choice = (input $"\e[90m[r]un, [c]opy, [q]uit:\e[0m " | str trim | str downcase)

    match $choice {
        "r" | "" => { nu -c $cmd }
        "c" => {
            $cmd | pbcopy
            print "Copied to clipboard"
        }
        _ => { print "Cancelled" }
    }
}

# ─────────────────────────────────────────────────────────────
# macOS
# ─────────────────────────────────────────────────────────────

# Show/hide hidden files in Finder
def showfiles [] {
    defaults write com.apple.finder AppleShowAllFiles -bool true
    killall Finder
}

def hidefiles [] {
    defaults write com.apple.finder AppleShowAllFiles -bool false
    killall Finder
}
