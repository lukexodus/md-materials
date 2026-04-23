# fd

A fast, user-friendly alternative to `find`. Written in Rust by David Peter.

> `fd` calls the filesystem directly and respects `.gitignore` by default. It is not a drop-in replacement for `find` — the syntax differs intentionally.

**Official repo:** `github.com/sharkdp/fd`

---

## Table of Contents

1. [What is fd?](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#what-is-fd)
2. [Installation](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#installation)
3. [Basic Usage](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#basic-usage)
4. [Pattern Matching](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#pattern-matching)
5. [Filtering by Type](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#filtering-by-type)
6. [Filtering by Extension](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#filtering-by-extension)
7. [Filtering by Size](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#filtering-by-size)
8. [Filtering by Time](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#filtering-by-time)
9. [Filtering by Owner & Permissions](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#filtering-by-owner--permissions)
10. [Hidden & Ignored Files](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#hidden--ignored-files)
11. [Search Depth](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#search-depth)
12. [Executing Commands](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#executing-commands)
13. [Excluding Paths](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#excluding-paths)
14. [Output Options](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#output-options)
15. [Configuration](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#configuration)
16. [Practical Examples](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#practical-examples)
17. [fd vs find Comparison](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#fd-vs-find-comparison)
18. [Quick Cheatsheet](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#quick-cheatsheet)

---

## What is fd?

`fd` is a fast alternative to the Unix `find` command. Key differences from `find`:

- Patterns are **regular expressions** by default (not globs)
- Searches the **current directory** by default
- **Ignores hidden files** and `.gitignore`-listed paths by default
- Output is **colorized** and sorted
- Syntax is simpler: `fd PATTERN [PATH]` instead of `find PATH -name PATTERN`
- Significantly faster on large directory trees (parallel directory traversal)

---

## Installation

### macOS

```sh
brew install fd
```

### Linux

```sh
# Ubuntu / Debian
sudo apt install fd-find
# Note: binary is named 'fdfind' on Debian/Ubuntu — alias it:
alias fd=fdfind

# Arch Linux
sudo pacman -S fd

# Fedora
sudo dnf install fd-find

# Nix
nix-env -iA nixpkgs.fd
```

### Windows

```sh
# Scoop
scoop install fd

# Winget
winget install sharkdp.fd

# Chocolatey
choco install fd
```

### Cargo (from source)

```sh
cargo install fd-find
```

Verify: `fd --version`

> **Note:** On Debian/Ubuntu the binary is installed as `fdfind` to avoid conflict with the existing `fd` package (a finite-domain constraint solver). Add `alias fd=fdfind` to your shell config.

---

## Basic Usage

```sh
fd                          # list all non-hidden files recursively from .
fd PATTERN                  # search current directory recursively
fd PATTERN /path/to/dir     # search a specific directory
fd PATTERN ~ /tmp           # search multiple directories
```

The pattern is matched against the **filename only** (not the full path) by default.

```sh
fd report                   # matches: report.md, monthly_report.csv, report_final.txt
fd '^report'                # matches only filenames starting with 'report'
fd '\.log$'                 # matches only filenames ending with .log
```

---

## Pattern Matching

fd uses **regular expressions** by default. Use `-g` / `--glob` to switch to glob patterns.

### Regex (default)

```sh
fd 'foo.*bar'               # matches foobar, foo_anything_bar, etc.
fd '\d{4}-\d{2}-\d{2}'     # matches date-like filenames: 2024-01-15.log
fd '(test|spec)'            # matches filenames containing 'test' or 'spec'
```

### Glob patterns

```sh
fd -g '*.log'               # glob: all .log files
fd -g 'report_*_final.*'    # glob: report_<anything>_final.<any extension>
fd -g '**/*.rs'             # glob: all .rs files anywhere (** = any depth)
```

### Case sensitivity

```sh
fd -i PATTERN               # case-insensitive (overrides smart-case)
fd -s PATTERN               # case-sensitive (overrides smart-case)
```

By default, fd uses **smart-case**: case-insensitive if the pattern is all lowercase, case-sensitive if it contains any uppercase.

```sh
fd readme                   # matches README.md, readme.txt, Readme (smart-case)
fd README                   # matches README.md only (has uppercase → case-sensitive)
```

### Full path matching

```sh
fd -p 'src/.*\.rs'          # match against full path, not just filename
fd --full-path 'test/unit'  # match files inside test/unit directories
```

---

## Filtering by Type

```sh
fd -t f PATTERN             # files only
fd -t d PATTERN             # directories only
fd -t l PATTERN             # symbolic links only
fd -t x PATTERN             # executables only
fd -t e PATTERN             # empty files and directories
fd -t s PATTERN             # sockets
fd -t p PATTERN             # pipes (named pipes / FIFOs)
```

Multiple types can be combined:

```sh
fd -t f -t l PATTERN        # files and symlinks
```

---

## Filtering by Extension

```sh
fd -e rs                    # all .rs files
fd -e js -e ts              # all .js and .ts files
fd PATTERN -e md            # pattern AND .md extension
```

`-e` / `--extension` is a shorthand that matches the file extension regardless of case and does not require a dot.

---

## Filtering by Size

```sh
fd -S +1M                   # files larger than 1 megabyte
fd -S -100k                 # files smaller than 100 kilobytes
fd -S +1G                   # files larger than 1 gigabyte
fd -S +500k -S -10M         # files between 500KB and 10MB
```

### Size units

|Suffix|Unit|
|---|---|
|`b`|Bytes|
|`k`|Kilobytes (1000)|
|`ki`|Kibibytes (1024)|
|`m`|Megabytes|
|`mi`|Mebibytes|
|`g`|Gigabytes|
|`gi`|Gibibytes|

---

## Filtering by Time

Filter by **modification time** (`--changed-within` / `--changed-before`):

```sh
fd --changed-within 1d      # modified in the last 1 day
fd --changed-within 2h      # modified in the last 2 hours
fd --changed-within 1week   # modified in the last week
fd --changed-before 2024-01-01   # modified before Jan 1 2024
fd --changed-before 30min   # modified more than 30 minutes ago
```

### Time units accepted

`second`, `minute`, `hour`, `day`, `week`, `month`, `year` (and their plurals and abbreviations: `s`, `m`, `h`, `d`, `w`).

---

## Filtering by Owner & Permissions

```sh
fd -o alice                 # files owned by user 'alice'
fd -o alice:staff           # owned by user alice, group staff
fd -o :staff                # any user, group staff

fd --mode 644 PATTERN       # exact permission match
```

> **Note:** `--mode` and `-o` / `--owner` are available on Unix systems. Behavior may vary.

---

## Hidden & Ignored Files

By default, fd **excludes**:

- Hidden files and directories (names starting with `.`)
- Files and directories listed in `.gitignore`, `.fdignore`, `.ignore`

```sh
fd -H PATTERN               # include hidden files
fd -I PATTERN               # include ignored files (don't respect .gitignore)
fd -HI PATTERN              # include both hidden and ignored files
fd -u PATTERN               # unrestricted: same as -HI (alias: --unrestricted)
fd -uu PATTERN              # also ignore .fdignore files
```

### `.fdignore`

You can create a `.fdignore` file (same syntax as `.gitignore`) that fd respects even in non-Git directories:

```gitignore
# .fdignore
node_modules/
*.pyc
.DS_Store
build/
dist/
```

---

## Search Depth

```sh
fd -d 1 PATTERN             # search current directory only (depth 1)
fd -d 2 PATTERN             # current directory + one level of subdirectories
fd --max-depth 3 PATTERN    # alias for -d
fd --min-depth 2 PATTERN    # skip files at depth less than 2
fd --exact-depth 3 PATTERN  # only files at exactly depth 3
```

---

## Executing Commands

This is one of fd's most powerful features. Found files can be passed to a command via `-x` or `-X`.

### `-x` / `--exec` — run once per file

The placeholder `{}` represents the current file path. Additional placeholders:

|Placeholder|Meaning|
|---|---|
|`{}`|Full path|
|`{/}`|Filename only|
|`{//}`|Parent directory|
|`{.}`|Full path without extension|
|`{/.}`|Filename without extension|

```sh
fd -e png -x convert {} {.}.jpg        # convert every PNG to JPG
fd -e log -x rm {}                     # delete all .log files
fd -t d -x chmod 755 {}               # chmod all directories to 755
fd -e py -x wc -l {}                  # count lines in each Python file
```

### `-X` / `--exec-batch` — run once with all files as arguments

```sh
fd -e rs -X vim                        # open all .rs files in vim at once
fd -e md -X grep -l 'TODO'            # grep for TODO across all .md files
fd -t f -e jpg -X zip photos.zip      # zip all JPGs into one archive
```

### With `xargs`

```sh
fd -e tmp -0 | xargs -0 rm            # safely handle filenames with spaces
```

Use `-0` / `--print0` to separate results with null bytes (safer for piping to `xargs -0`).

---

## Excluding Paths

```sh
fd PATTERN -E '*.bak'             # exclude .bak files
fd PATTERN -E node_modules        # exclude node_modules directory
fd PATTERN -E '.git' -E 'dist'    # exclude multiple paths
fd PATTERN --exclude '*.min.js'   # long form
```

You can also add permanent exclusions to `.fdignore` or `.gitignore`.

---

## Output Options

```sh
fd PATTERN -l                     # long listing (like ls -l)
fd PATTERN --list-details         # alias for -l
fd PATTERN -0                     # null-separated output (for xargs -0)
fd PATTERN --print0               # alias for -0
fd PATTERN -a                     # print absolute paths
fd PATTERN --absolute-path        # alias for -a
fd PATTERN -c never               # no color output
fd PATTERN -c always              # always colorize (even when piped)
fd PATTERN --color auto           # default: colorize only if terminal
```

### Counting results

```sh
fd -e log | wc -l                 # count matching files
```

### Sorting

Results are not guaranteed to be sorted in any particular order by default (parallel traversal). Use `--max-results` to limit:

```sh
fd PATTERN --max-results 10       # stop after 10 results
fd PATTERN -1                     # return only the first result (shorthand)
```

---

## Configuration

fd reads a config file from:

- **macOS / Linux:** `~/.config/fd/ignore` (global ignore rules, gitignore syntax)
- Environment variable: `FD_OPTIONS` for default flags

### `FD_OPTIONS`

Add default flags so you don't have to type them every time:

```sh
# In ~/.bashrc or ~/.zshrc
export FD_OPTIONS="--hidden --follow --exclude .git --exclude node_modules"
```

### Global ignore file

`~/.config/fd/ignore` uses `.gitignore` syntax and is always respected:

```gitignore
node_modules/
.DS_Store
*.pyc
__pycache__/
.cache/
```

### Shell completions

```sh
# Bash
fd --gen-completions bash >> ~/.bash_completion

# Zsh
fd --gen-completions zsh > ~/.zfunc/_fd
# Add to .zshrc: fpath+=~/.zfunc && autoload -Uz compinit && compinit

# Fish
fd --gen-completions fish > ~/.config/fish/completions/fd.fish
```

---

## Practical Examples

### Find and delete

```sh
# Delete all .DS_Store files recursively
fd -H -t f '.DS_Store' -X rm

# Delete all __pycache__ directories
fd -t d '__pycache__' -X rm -rf

# Delete all .log files older than 7 days
fd -e log --changed-before 7d -X rm
```

### Find and edit

```sh
# Open all TODO files in your editor
fd 'TODO' -X $EDITOR

# Find all config files and view them
fd -e yml -e yaml -e toml -X bat

# Find files containing a word (combining fd + grep)
fd -e py -X grep -l 'deprecated'
```

### Bulk rename

```sh
# Preview: show what would be renamed
fd -e jpeg -x echo mv {} {//}/{/.}.jpg

# Execute: rename all .jpeg to .jpg
fd -e jpeg -x mv {} {//}/{/.}.jpg
```

### Find large files

```sh
fd -t f -S +100M            # files over 100MB
fd -t f -S +1G -l           # files over 1GB, long listing
```

### Find recently modified files

```sh
fd --changed-within 24h -t f          # all files modified in the last day
fd --changed-within 1h -e py          # Python files changed in last hour
```

### Find empty files or directories

```sh
fd -t e                     # all empty files and directories
fd -t f -t e                # empty files only
fd -t d -t e                # empty directories only
```

### Integration with fzf

```sh
# Fuzzy-find a file and open it
fd -t f | fzf | xargs $EDITOR

# Fuzzy-find a directory and cd into it
cd $(fd -t d | fzf)
```

### Integration with ripgrep

```sh
# Find files, then search contents
fd -e md | xargs rg 'TODO'

# Or: use rg directly (it has its own file filtering)
# fd and rg complement each other — fd for file finding, rg for content search
```

---

## fd vs find Comparison

|Task|`find`|`fd`|
|---|---|---|
|Find by name|`find . -name '*.rs'`|`fd -e rs`|
|Find files only|`find . -type f -name 'foo'`|`fd -t f foo`|
|Find dirs only|`find . -type d -name 'src'`|`fd -t d src`|
|Case-insensitive|`find . -iname 'readme*'`|`fd -i readme`|
|Execute per file|`find . -name '*.png' -exec cmd {} \;`|`fd -e png -x cmd {}`|
|Execute batch|`find . -name '*.png' \| xargs cmd`|`fd -e png -X cmd`|
|Limit depth|`find . -maxdepth 2 -name 'foo'`|`fd -d 2 foo`|
|Modified recently|`find . -mtime -1`|`fd --changed-within 1d`|
|Larger than 1MB|`find . -size +1M`|`fd -S +1M`|
|Exclude path|`find . -not -path '*/node_modules/*'`|`fd -E node_modules`|
|Include hidden|`find . -name '.env'`|`fd -H '\.env'`|
|Null-separated output|`find . -print0`|`fd -0`|

---

## Quick Cheatsheet

### Core syntax

```
fd [OPTIONS] [PATTERN] [PATH...]
```

### Filtering

|Flag|Meaning|
|---|---|
|`-t f`|Files only|
|`-t d`|Directories only|
|`-t l`|Symlinks only|
|`-t x`|Executables only|
|`-t e`|Empty files/dirs|
|`-e EXT`|By extension|
|`-S +1M`|Larger than 1MB|
|`-S -100k`|Smaller than 100KB|
|`--changed-within 1d`|Modified in last day|
|`--changed-before 7d`|Modified more than 7 days ago|
|`-o USER`|Owned by user|

### Pattern options

|Flag|Meaning|
|---|---|
|`-g`|Glob mode|
|`-i`|Case-insensitive|
|`-s`|Case-sensitive|
|`-p`|Match full path|
|`-F`|Literal string (no regex)|

### Hidden / ignored

|Flag|Meaning|
|---|---|
|`-H`|Include hidden|
|`-I`|Include gitignored|
|`-u`|Include both (`-HI`)|
|`-E PATTERN`|Exclude pattern|

### Execution

|Flag|Meaning|
|---|---|
|`-x CMD`|Run CMD once per file|
|`-X CMD`|Run CMD with all files|
|`-0`|Null-separated output|
|`-l`|Long listing|
|`-a`|Absolute paths|
|`-d N`|Max depth N|
|`--max-results N`|Limit to N results|
|`-1`|Return first result only|

### Placeholders (for `-x`)

|Placeholder|Value|
|---|---|
|`{}`|Full path|
|`{/}`|Filename|
|`{//}`|Parent directory|
|`{.}`|Path without extension|
|`{/.}`|Filename without extension|

---

_Source: [fd GitHub repository](https://github.com/sharkdp/fd) and `fd --help`. Always consult `fd --help` or the official docs for your installed version, as flags may differ across releases._