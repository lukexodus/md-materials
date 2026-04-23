# bat

`bat` is a `cat` replacement written in Rust. It adds syntax highlighting, line numbers, Git integration, and automatic paging — while remaining fully compatible with `cat` in scripts and pipelines.

---

## Installation

```bash
# Debian / Ubuntu
sudo apt install bat

# Arch / Manjaro
sudo pacman -S bat

# Fedora
sudo dnf install bat

# macOS
brew install bat

# Windows (Scoop)
scoop install bat

# Windows (winget)
winget install sharkdp.bat

# Cargo (Rust)
cargo install bat
```

> **Note (Debian/Ubuntu):** The binary may be installed as `batcat` instead of `bat` to avoid a naming conflict with another package. Verify with `which bat` or `which batcat`. To fix:
> 
> ```bash
> mkdir -p ~/.local/bin
> ln -s /usr/bin/batcat ~/.local/bin/bat
> ```
> 
> Then ensure `~/.local/bin` is on your `$PATH`.

---

## Basic Usage

```bash
bat file.txt                    # view a file with syntax highlighting
bat file1.txt file2.txt         # view multiple files (with headers)
bat -n file.txt                 # show line numbers only (no other decorations)
bat -A file.txt                 # show all non-printable characters
bat -p file.txt                 # plain output (no line numbers, no frame)
bat -r 10:30 file.txt           # show only lines 10 to 30
bat -r 50: file.txt             # show from line 50 to end
bat -r :20 file.txt             # show first 20 lines
bat --line-range 10:30 file.txt # same as -r, long form
```

---

## Syntax Highlighting

bat auto-detects the language from the file extension or shebang line.

```bash
bat script.py                   # Python
bat config.yaml                 # YAML
bat Makefile                    # Makefile
bat -l json file.txt            # force JSON highlighting on a .txt file
bat -l rust file                # force Rust highlighting
bat --list-languages            # list all supported languages
bat --list-themes               # list all available themes
```

### Force a language

```bash
bat -l markdown README
bat -l sh deploy           # treat 'deploy' as a shell script
```

---

## Themes

```bash
bat --theme=TwoDark file.py          # use a specific theme
bat --theme=GitHub file.py           # light theme
bat --theme="Solarized (dark)" file.py
bat --list-themes                    # list all available themes

# Preview all themes on a file
bat --list-themes | fzf --preview="bat --theme={} --color=always file.py"
```

### Set a default theme

```bash
# Add to ~/.bashrc or ~/.zshrc
export BAT_THEME="TwoDark"
```

### Built-in themes (selection)

|Theme|Style|
|---|---|
|`TwoDark`|Dark, popular default|
|`GitHub`|Light, GitHub-style|
|`Monokai Extended`|Dark, vibrant|
|`Solarized (dark)`|Dark|
|`Solarized (light)`|Light|
|`gruvbox-dark`|Warm dark|
|`Nord`|Cool blue-dark|
|`ansi`|Uses terminal's ANSI colors|
|`base16`|Minimal base16|

---

## Git Integration

bat shows Git change indicators in the gutter (left margin) for files tracked by Git:

|Symbol|Meaning|
|---|---|
|`+`|Added line|
|`~`|Modified line|
|`-`|Removed line (shown at position of removal)|

This works automatically when viewing files inside a Git repository. No extra flags needed.

```bash
bat src/main.rs          # shows git diff markers if file has uncommitted changes
bat --diff src/main.rs   # show only changed lines + context (like git diff but highlighted)
```

> **[Inference]** Git diff markers appear based on the working tree vs. the last commit. They will not appear on files outside a Git repo or on untracked files.

---

## Paging

bat pipes output through a pager (defaults to `less`) when output is taller than the terminal.

```bash
bat --paging=always file.txt    # always use pager
bat --paging=never file.txt     # never use pager (behave like cat)
bat --paging=auto file.txt      # default: use pager only when output overflows

# Set a custom pager
bat --pager="less -RF" file.txt

# Set default pager via env
export BAT_PAGER="less -RF"
```

---

## Decorations (Line Numbers, Frame, Git Gutter)

```bash
bat --style=full file.txt           # all decorations (default)
bat --style=plain file.txt          # no decorations at all (same as -p)
bat --style=numbers file.txt        # line numbers only
bat --style=grid file.txt           # header + grid lines, no numbers
bat --style=header file.txt         # filename header only
bat --style=changes file.txt        # git change markers only
bat --style=numbers,changes file.txt  # combine styles with commas
```

### Style components

|Component|What it shows|
|---|---|
|`header`|Filename bar at the top|
|`header-filename`|Just the filename in the header|
|`header-filesize`|File size in the header|
|`grid`|Horizontal lines above/below content|
|`numbers`|Line numbers in the gutter|
|`changes`|Git change markers in the gutter|
|`snip`|Separator when using `-r` with gaps|
|`full`|All of the above|
|`plain`|None of the above|

```bash
# Set default style via env
export BAT_STYLE="numbers,changes,grid"
```

---

## Using bat as a man Pager

bat can syntax-highlight man pages:

```bash
# Add to ~/.bashrc or ~/.zshrc
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Or with bat's built-in man support (newer versions)
export MANPAGER="bat -l man -p"
```

Then just run `man ls`, `man git`, etc. as normal.

---

## Using bat in Pipelines

When stdout is not a terminal (e.g. in a pipe), bat automatically disables colors and paging — behaving like `cat`. You can override this:

```bash
# Pass highlighted output to another command
bat -p --color=always file.py | less -R

# Use with grep (keep colors)
bat --color=always file.py | grep "def "

# Use with fzf preview
fzf --preview 'bat --color=always --style=numbers {}'

# Pipe into bat from another command
curl -s https://example.com/script.sh | bat -l sh
```

---

## bat with fzf (Preview Integration)

A common and powerful combination:

```bash
# File picker with bat preview
fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'

# Add to ~/.bashrc as a function
preview() {
  fzf --preview 'bat --color=always --style=numbers {}'
}
```

---

## Configuration File

bat reads a config file where you can set persistent defaults.

```bash
# Find the config file location on your system
bat --config-file

# Typical locations:
# Linux:   ~/.config/bat/config
# macOS:   ~/.config/bat/config
# Windows: %APPDATA%\bat\config
```

### Example config file

```
# ~/.config/bat/config

--theme="TwoDark"
--style="numbers,changes,grid"
--pager="less -RF"
--map-syntax="*.conf:INI"
--map-syntax="Dockerfile*:Dockerfile"
--italic-text=always
```

Each line is one flag (without the `--` syntax requiring quoting — just write the flag as you would on the command line).

---

## Mapping Custom File Extensions

```bash
# Force a syntax for a pattern
bat --map-syntax="*.conf:INI" file.conf
bat --map-syntax="*.env:Bash" .env
bat --map-syntax="Jenkinsfile:Groovy" Jenkinsfile

# Put these in your config file to make them permanent
```

---

## Adding Custom Syntax Themes

```bash
# Find the custom themes directory
bat --config-dir
# e.g. ~/.config/bat/

# Create the themes directory and add a .tmTheme file
mkdir -p "$(bat --config-dir)/themes"
cp MyTheme.tmTheme "$(bat --config-dir)/themes/"

# Rebuild the theme cache
bat cache --build

# Verify
bat --list-themes | grep MyTheme
```

bat uses TextMate `.tmTheme` format for custom themes.

---

## Adding Custom Syntax Definitions

```bash
# Create the syntaxes directory
mkdir -p "$(bat --config-dir)/syntaxes"

# Add a .sublime-syntax file
cp MySyntax.sublime-syntax "$(bat --config-dir)/syntaxes/"

# Rebuild the syntax cache
bat cache --build

# Verify
bat --list-languages | grep MySyntax
```

bat uses Sublime Text `.sublime-syntax` format.

---

## Useful Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc

# Replace cat with bat (plain output for scripts, highlighted for terminal)
alias cat='bat'

# Or a softer alias that keeps plain output
alias b='bat'

# View with no decorations
alias batp='bat -p'

# Quick diff of a file vs last commit
alias batd='bat --diff'
```

---

## Common Flag Reference

|Flag|Short|Description|
|---|---|---|
|`--language`|`-l`|Force a syntax language|
|`--theme`||Set color theme|
|`--style`||Control decorations|
|`--plain`|`-p`|No decorations, no pager|
|`--number`|`-n`|Line numbers only|
|`--show-all`|`-A`|Show non-printable characters|
|`--line-range`|`-r`|Show a range of lines|
|`--diff`|`-d`|Show only changed lines|
|`--paging`||Control pager behavior|
|`--color`||`always` / `never` / `auto`|
|`--wrap`||`auto` / `never` / `character`|
|`--tabs`||Set tab width (e.g. `--tabs=2`)|
|`--italic-text`||`always` / `never`|
|`--map-syntax`||Map file pattern to syntax|
|`--list-languages`||List all supported languages|
|`--list-themes`||List all available themes|
|`--config-file`||Print config file path|
|`--config-dir`||Print config directory path|
|`--cache --build`||Rebuild syntax/theme cache|

---

## Environment Variables

|Variable|Effect|
|---|---|
|`BAT_THEME`|Default theme|
|`BAT_STYLE`|Default style|
|`BAT_PAGER`|Default pager command|
|`BAT_OPTS`|Additional default flags|
|`MANPAGER`|Use bat to highlight man pages|

---

## Practical Tips

**Don't alias `cat` unconditionally.** Some scripts rely on `cat` producing plain output. If you alias it to `bat`, add `--paging=never` at minimum, or use `bat -p` so it behaves like cat in pipelines. bat already auto-detects pipes and disables color/paging in that context, but being explicit avoids surprises.

**Use `-r` for large files.** Instead of opening a 10,000-line file and scrolling, jump directly to the area of interest with `bat -r 200:250 file.py`.

**`--diff` is underused.** `bat --diff file.py` shows only the lines that changed since the last commit, with surrounding context and full syntax highlighting — faster than reading `git diff` output for a quick check.

**bat + fzf is one of the most useful combos on the command line.** Add the fzf preview alias to your shell config and you get a fuzzy file finder with a fully syntax-highlighted preview pane.

> **[Inference]** bat's behavior in pipelines (auto-disabling color/paging) is based on TTY detection. Some edge cases (e.g. running inside certain terminal multiplexers or CI environments) may produce unexpected results. Use `--color=always` or `--paging=never` explicitly when behavior needs to be predictable.