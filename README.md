# dotfiles

A minimal, intentional shell configuration using [Nushell](https://www.nushell.sh/). Fast startup. No magic. Every line earns its place.

## Philosophy

**Do one thing well.** These dotfiles follow the Unix philosophy: small, composable tools that work together. No frameworks. No plugin managers. Just nushell scripts that source other scripts.

**Fail gracefully.** Every tool is guarded. Missing `eza`? You get standard `ls`. Missing `bat`? You get `cat`. The config works on a fresh Mac or a fully-loaded dev machine.

**Stay fast.** Shell startup should be imperceptible (~10ms) thanks to cached tool initialization.

## Why Nushell?

- **Structured data** - Pipelines work with tables, not text. No more `awk '{print $2}'`.
- **Built-in features** - Autosuggestions, syntax highlighting, fuzzy completion. No plugins needed.
- **Better scripting** - Real types, proper error handling, match expressions.
- **Fast startup** - Cached tool initialization means instant shell.

## Structure

```
~/.dotfiles/
├── env.nu            # PATH and environment variables
├── config.nu         # Entry point - sources everything, shell settings
├── aliases.nu        # Short commands (guarded for modern tools)
├── functions.nu      # Reusable shell functions
├── tools/
│   ├── fzf.nu        # Fuzzy finder config
│   ├── zoxide.nu     # Smart directory jumping
│   ├── direnv.nu     # Per-directory environments
│   ├── delta.nu      # Better git diffs
│   └── ssm.nu        # AWS Session Manager shortcuts
├── completions/      # Custom tab completions
├── Brewfile          # Homebrew dependencies
└── setup.sh          # Bootstrap for fresh machines
```

## Installation

```bash
git clone https://github.com/YOU/dotfiles ~/.dotfiles
cd ~/.dotfiles
./setup.sh
chsh -s $(which nu)
```

The setup script handles both macOS and Linux, creating symlinks in the correct location:
- **macOS**: `~/Library/Application Support/nushell/`
- **Linux**: `~/.config/nushell/`

### Terminal Setup (Ghostty)

If using [Ghostty](https://ghostty.org/), add to `~/.config/ghostty/config`:

```
command = /opt/homebrew/bin/nu --login
```

The `--login` flag ensures `env.nu` is sourced properly.

## The Tools

Modern replacements for classic Unix commands. Each one respects the spirit of the original while adding thoughtful improvements.

| Classic | Modern | Why |
|---------|--------|-----|
| `cat` | [bat](https://github.com/sharkdp/bat) | Syntax highlighting, line numbers, git integration |
| `ls` | [eza](https://github.com/eza-community/eza) | Colors, icons, git status, tree view |
| `find` | [fd](https://github.com/sharkdp/fd) | Faster, respects `.gitignore`, sane defaults |
| `grep` | [ripgrep](https://github.com/BurntSushi/ripgrep) | Faster, respects `.gitignore`, better UX |
| `cd` | [zoxide](https://github.com/ajeetdsouza/zoxide) | Learns your habits, jump anywhere with `z foo` |
| `diff` | [delta](https://github.com/dandavison/delta) | Side-by-side, syntax highlighting, word-level diffs |
| `pyenv` | [mise](https://mise.jdx.dev/) | Multi-language version manager with native nushell support |

### Environment Management (direnv)

[direnv](https://direnv.net/) loads environment variables when you enter a directory.

```bash
# In any project directory
echo 'export DATABASE_URL="postgres://..."' > .envrc
direnv allow
```

Variables load automatically when you `cd` in, unload when you leave.

## Built-in Features

Nushell includes what zsh needed plugins for:

| Feature | Nushell | zsh |
|---------|---------|-----|
| Autosuggestions | Built-in | zsh-autosuggestions plugin |
| Syntax highlighting | Built-in | zsh-syntax-highlighting plugin |
| Fuzzy completion | `completions.algorithm: "fuzzy"` | fzf integration |
| Structured history | SQLite-backed | text file |

## Aliases

```bash
# Navigation
d           # cd ~/Developer/delphi/delphi
dot         # cd ~/.dotfiles

# Git
gs          # git status
gd          # git diff (with delta)
glog        # git log --oneline --graph -20

# Modern tools (when installed)
cat         # bat --paging=never
ls          # eza
ll          # eza -la --git
tree        # eza --tree
find        # fd
grep        # rg
```

## Functions

```nu
mkd foo      # mkdir foo && cd foo
extract x    # Extract any archive format
serve        # Python HTTP server in current directory
z foo        # Jump to most-used directory matching "foo"
zi           # Interactive directory picker
ff foo       # Find files matching "foo"
fdir foo     # Find directories matching "foo"
activate     # Activate Python venv (nushell-native)
deactivate   # Deactivate Python venv
flushdns     # Flush macOS DNS cache
weather      # Show weather
cheat topic  # Cheatsheet for any topic
ai "query"   # Generate bash command from natural language
ssm <name>   # AWS SSM Session Manager shortcuts
```

## Python Virtual Environments

Unlike bash/zsh, nushell can't `source .venv/bin/activate` (that's a bash script). Instead, use the built-in functions:

```nu
python -m venv .venv  # Create venv
activate              # Activate it (or: activate .venv)
deactivate            # Deactivate
```

## Customization

### Adding a new tool

1. Create `tools/mytool.nu`
2. Guard it: `if (which mytool | is-empty) { return }`
3. Add `source ~/.dotfiles/tools/mytool.nu` to `config.nu`

> **Note:** Nushell's `source` requires parse-time constant paths, so tools can't be auto-discovered with glob patterns. Each tool file must be explicitly listed in `config.nu`.

### Adding aliases

Edit `aliases.nu` for static aliases, or `config.nu` for conditional ones (that check if a tool exists).

**Gotchas:**
- Use `^command` to call external commands (e.g., `^open` for macOS open vs nushell's `open`)
- Can't use `;` in aliases—use a function instead for multi-command sequences

### Adding completions

Create a `.nu` file in `completions/` and add a source line to `config.nu`.

## Debugging

```nu
# Check startup time
timeit { nu -c "exit" }

# Check environment
$env.PATH | to text

# Check if a tool is in PATH
which claude

# Regenerate tool caches (starship, zoxide, mise)
~/.dotfiles/setup.sh

# Test config for errors
nu -c 'source ~/.dotfiles/config.nu'
```

## Nushell Quirks

Things that work differently from bash/zsh:

| bash/zsh | nushell |
|----------|---------|
| `export VAR=val` | `$env.VAR = val` |
| `alias name="cmd"` | `alias name = cmd` |
| `alias foo="a; b"` | Use a function (`;` runs at parse time) |
| `open file.txt` | `^open file.txt` (prefix `^` for external commands) |
| `source .venv/bin/activate` | `activate` function |
| `$HOME/path` | `($env.HOME \| path join "path")` or `~/path` |
| Dynamic source paths | Must be parse-time constants (use `~` not `$env.HOME`) |

## Principles

1. **Explicit over implicit.** Read `config.nu` to see exactly what runs.

2. **Guard everything.** `if (which foo | is-empty) { return }` before tool-specific config.

3. **One file, one purpose.** Environment in `env.nu`. Aliases in `aliases.nu`. No mixing.

4. **Cache for speed.** Tool init scripts are pre-generated, not run on every shell start.

5. **Optimize for reading.** You write this once. You read it every time something breaks.

---

*"Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away."*
— Antoine de Saint-Exupéry
