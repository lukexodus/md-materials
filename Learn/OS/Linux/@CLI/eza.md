# eza

---

## What It Is

**eza** is a modern replacement for `ls`, written in Rust. It is a maintained fork of the now-unmaintained `exa`. It adds color, icons, Git status, tree views, and better defaults — while staying familiar.

---

## Installation

```bash
# macOS
brew install eza

# Debian/Ubuntu (via apt, newer distros)
sudo apt install eza

# Arch
sudo pacman -S eza

# Cargo
cargo install eza
```

---

## Basic Usage

```bash
eza                   # list current directory
eza path/to/dir       # list specific directory
eza file.txt          # info about a specific file
eza -1                # one file per line
```

---

## Most Useful Flags

### Display

```bash
-l / --long           # long format (permissions, size, date, owner)
-a / --all            # include hidden files (dotfiles)
-A / --almost-all     # hidden files, but exclude . and ..
-1                    # one entry per line
-R / --recurse        # recurse into subdirectories
-T / --tree           # tree view
--level=N             # limit tree/recurse depth to N
-r / --reverse        # reverse sort order
-s / --sort=FIELD     # sort by: name, size, modified, created, ext, none
-X                    # sort by extension
```

### Information Columns

```bash
-h / --header         # print column headers in long view
-H / --links          # show hard link count
-i / --inode          # show inode number
-S / --blocksize      # show block size
-n / --numeric        # show numeric user/group IDs instead of names
-m / --modified       # use modified timestamp
-u / --accessed       # use accessed timestamp
-U / --created        # use created timestamp
--time-style=STYLE    # timestamp style: default, iso, long-iso, full-iso, relative
```

### Icons & Color

```bash
--icons               # show file-type icons (requires Nerd Font)
--icons=auto          # icons only when outputting to terminal
--color=auto          # color only when outputting to terminal (default)
--color=always        # force color (useful in pipes)
--color=never         # disable color
--no-quotes           # don't quote filenames with spaces
```

### Git Integration

```bash
--git                 # show Git status for each file
--git-repos           # show Git status for directories (repo-level)
--git-repos-no-status # show if a dir is a git repo, without full status
```

Git status column codes:

|Code|Meaning|
|---|---|
|`N`|New|
|`M`|Modified|
|`D`|Deleted|
|`R`|Renamed|
|`T`|Type changed|
|`I`|Ignored|
|`-`|Unchanged|
|`?`|Untracked|

### File Classification

```bash
-F / --classify       # append indicator: / for dirs, * for executables, etc.
-D / --only-dirs      # list only directories
-f / --only-files     # list only files
--group-directories-first   # list directories before files
```

### Extended Attributes & Permissions

```bash
-@ / --extended       # show extended attributes (macOS/Linux xattrs)
-o / --octal-permissions   # show permissions as octal (e.g. 755) alongside symbolic
--no-permissions      # hide permissions column
--no-filesize         # hide filesize column
--no-user             # hide user column
--no-time             # hide time column
```

---

## Long Format Explained

```bash
eza -lah --icons --git
```

Output columns (left to right):

```
Permissions  Links  User   Group  Size   Git  Modified      Name
drwxr-xr-x     2   alice  staff  4.0k   -M   3 days ago    src/
.rw-r--r--     1   alice  staff   832    N   just now      main.rs
```

- Permissions use a symbolic `rwx` style; eza colorizes by type
- Size is human-readable by default in long mode
- Git column shows index status + worktree status (two characters)

---

## Tree View

```bash
eza --tree                      # full tree, current dir
eza --tree --level=2            # limit depth
eza --tree --long               # tree + long format combined
eza --tree --icons --git        # tree with icons and git status
eza -T -L 3 src/                # common shorthand
```

---

## Sorting

```bash
eza -s size                     # largest last
eza -s size -r                  # largest first
eza -s modified                 # oldest last
eza -s modified -r              # newest first
eza -s ext                      # group by extension
eza -s name                     # alphabetical (default)
eza -s none                     # no sorting (filesystem order)
eza --group-directories-first   # dirs on top, files below
```

---

## Aliases (Recommended)

Add to `.bashrc` / `.zshrc`:

```bash
alias ls='eza --icons=auto --color=auto'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias lt='eza --tree --level=2 --icons'
alias lta='eza --tree --level=2 --icons --all'
alias lt3='eza --tree --level=3 --icons'
alias ldot='eza -lah --icons | grep "^\."'   # dotfiles only
```

---

## Combining with fzf

```bash
# Fuzzy pick a file from tree view
eza --tree | fzf

# Pick a directory and cd into it
eza -D | fzf | xargs cd

# Long list, fuzzy search, preview with bat
eza -lah --color=always | fzf --ansi --preview 'bat --color=always {-1}'
```

---

## Tips & Gotchas

- **Icons require a Nerd Font** — if you see boxes or question marks, your terminal font doesn't support them. Popular choices: JetBrains Mono Nerd Font, FiraCode Nerd Font, Hack Nerd Font
- **`--color=always` in aliases can break pipes** — prefer `--color=auto` so color codes aren't injected when piping to `grep`, `rg`, etc.
- **eza does not page output** — pipe to `less -R` if needed: `eza -lah | less -R`
- **`--git` adds overhead on large repos** — it runs `git status` internally; can be slow on monorepos
- **macOS extended attributes** (`@` in `ls -l`) are shown with `-@` / `--extended`
- **`--only-files` and `--only-dirs`** are eza-specific; no `ls` equivalent

---

## Quick Reference

```
eza                          Basic list
eza -lah --icons --git       Full detail + hidden + icons + git
eza -T -L 2                  Tree, depth 2
eza -s size -r               Sort by size, largest first
eza --group-directories-first  Dirs before files
eza -lah --octal-permissions  Octal perms in long view
eza -1                       One per line
```