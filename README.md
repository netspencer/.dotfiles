# dotfiles

A minimal, intentional shell configuration. Fast startup. No magic. Every line earns its place.

## Philosophy

**Do one thing well.** These dotfiles follow the Unix philosophy: small, composable tools that work together. No frameworks. No plugin managers. Just shell scripts that source other shell scripts.

**Fail gracefully.** Every tool is guarded. Missing `eza`? You get standard `ls`. Missing `bat`? You get `cat`. The config works on a fresh Mac or a fully-loaded dev machine.

**Stay fast.** Shell startup should be imperceptible. These dotfiles load in under 200ms, even with all tools installed.

## Structure

```
~/.dotfiles/
├── init.zsh          # Entry point - sources everything in order
├── path.zsh          # PATH and environment variables
├── aliases.zsh       # Short commands (guarded for modern tools)
├── functions.zsh     # Reusable shell functions
├── plugins.zsh       # zsh-autosuggestions + syntax-highlighting
├── prompt.zsh        # Starship prompt
├── tools/
│   ├── fzf.zsh       # Fuzzy finder
│   ├── zoxide.zsh    # Smart directory jumping
│   ├── direnv.zsh    # Per-directory environments
│   ├── delta.zsh     # Better git diffs
│   └── ssm.zsh       # AWS Session Manager shortcuts
├── completions/      # Custom tab completions
├── Brewfile          # Homebrew dependencies
└── setup.sh          # Bootstrap for fresh machines
```

## Installation

```bash
git clone https://github.com/YOU/dotfiles ~/.dotfiles
cd ~/.dotfiles
./setup.sh
exec zsh
```

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

### Fuzzy Finding (fzf)

[fzf](https://github.com/junegunn/fzf) is the glue. It turns any list into an interactive filter.

| Keybinding | Action |
|------------|--------|
| `Ctrl-R` | Search command history |
| `Ctrl-T` | Find files, insert path |
| `Alt-C` | Find directories, cd into selection |

The config uses `fd` for file listing (fast, ignores `.git` and `node_modules`) and `bat`/`eza` for previews.

### Environment Management (direnv)

[direnv](https://direnv.net/) loads environment variables when you enter a directory.

```bash
# In any project directory
echo 'export DATABASE_URL="postgres://..."' > .envrc
direnv allow
```

Variables load automatically when you `cd` in, unload when you leave. No more "forgot to source `.env`".

### Zsh Plugins

Two plugins, loaded in the correct order:

1. **zsh-autosuggestions** - Ghost text from your history as you type
2. **zsh-syntax-highlighting** - Commands turn green when valid, red when not

No plugin manager. They're sourced directly from Homebrew's install location.

## Key Bindings

| Key | Action |
|-----|--------|
| `Ctrl-R` | Fuzzy search history |
| `Ctrl-T` | Fuzzy find files |
| `Alt-C` | Fuzzy cd to directory |
| `→` | Accept autosuggestion |

## Aliases

```bash
# Navigation
..          # cd ..
...         # cd ../..
d           # cd ~/Developer/delphi/delphi

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

```bash
mkd foo     # mkdir -p foo && cd foo
extract x   # Extract any archive format
serve       # Python HTTP server in current directory
z foo       # Jump to most-used directory matching "foo"
zi          # Interactive directory picker
fdir foo    # Find directories matching "foo"
ff foo      # Find files matching "foo"
```

## Customization

### Adding a new tool

1. Create `tools/mytool.zsh`
2. Guard it: `command -v mytool >/dev/null || return`
3. It auto-loads on next shell

### Adding aliases

Edit `aliases.zsh`. Keep it simple. If it needs logic, make it a function.

### Adding completions

Drop a `.zsh` file in `completions/`. It auto-loads.

## Principles

1. **Explicit over implicit.** No "magic" loading. Read `init.zsh` to see exactly what runs.

2. **Guard everything.** `command -v foo >/dev/null &&` before any tool-specific config.

3. **One file, one purpose.** Path config in `path.zsh`. Aliases in `aliases.zsh`. No mixing.

4. **Comments explain why, not what.** The code shows what. Comments explain the non-obvious.

5. **Optimize for reading.** You write this once. You read it every time something breaks.

## Debugging

```bash
# Check startup time
time zsh -i -c exit

# See what's slow (if anything)
zsh -xv 2>&1 | ts -i "%.s" | head -100

# Test a clean load
env -i HOME=$HOME zsh -l
```

## Credits

Standing on the shoulders of giants. These dotfiles are a synthesis of patterns from:

- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
- [Zach Holman](https://github.com/holman/dotfiles)
- [Paul Irish](https://github.com/paulirish/dotfiles)

And countless hours reading `man` pages.

---

*"Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away."*
— Antoine de Saint-Exupéry
