
## What They Are

**fzf** is a general-purpose interactive fuzzy finder for the terminal. It reads lines from stdin and lets you filter/select them using a fuzzy search interface.

**ripgrep (rg)** is a fast line-oriented search tool that searches file contents using regular expressions. It respects `.gitignore` by default and skips binary files.

Used together: `rg` finds content inside files at speed; `fzf` provides the interactive selection layer on top.

---

## Installation

### fzf

```bash
# macOS
brew install fzf
$(brew --prefix)/opt/fzf/install  # installs shell keybindings + completions

# Debian/Ubuntu
sudo apt install fzf

# From source
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### ripgrep

```bash
# macOS
brew install ripgrep

# Debian/Ubuntu
sudo apt install ripgrep

# Arch
sudo pacman -S ripgrep
```

---

## fzf: Core Concepts

### Basic Usage

```bash
# Pipe anything into fzf
ls | fzf
cat /etc/hosts | fzf
history | fzf
```

### Fuzzy Matching

Type characters in any order — fzf matches lines that contain those characters (not necessarily contiguous):

```
> srv cfg     # matches "server-config.yaml", "srv-cfg.json", etc.
```

### Search Syntax

|Pattern|Meaning|
|---|---|
|`foo`|Fuzzy match: foo|
|`'foo`|Exact match: foo|
|`^foo`|Prefix match: starts with foo|
|`foo$`|Suffix match: ends with foo|
|`!foo`|Negate: does NOT contain foo|
|`foo bar`|AND: matches both|
|`foo \| bar`|OR: matches either|

### Key Bindings (default)

|Key|Action|
|---|---|
|`↑` / `↓`|Navigate results|
|`Enter`|Select|
|`Tab`|Mark for multi-select|
|`Shift+Tab`|Unmark|
|`Ctrl+C` / `Esc`|Cancel|
|`Ctrl+/`|Toggle preview window|

### Important Flags

```bash
--multi (-m)          # allow selecting multiple items (Tab to mark)
--height=40%          # render inline, not fullscreen
--reverse             # put input at top
--border              # draw border around fzf
--prompt="Search> "   # customize prompt text
--header="title"      # static header line
--preview="cmd {}"    # run command on highlighted item, show output
--preview-window=right:60%  # position and size of preview
--bind "key:action"   # customize keybindings
--query="initial"     # pre-fill search query
--select-1            # auto-select if only one result
--exit-0              # exit immediately if no results
--filter="query"      # non-interactive: filter and print matches
```

---

## ripgrep: Core Concepts

### Basic Usage

```bash
rg "pattern"                  # search current directory recursively
rg "pattern" path/to/dir      # search specific directory
rg "pattern" file.txt         # search specific file
```

### Important Flags

```bash
-i                    # case-insensitive
-w                    # whole word only
-l                    # print filenames only (no line content)
-n                    # show line numbers (default: on)
-N                    # suppress line numbers
-c                    # count matches per file
-v                    # invert match (lines NOT matching)
-t py                 # search only Python files
-T py                 # exclude Python files
-g "*.md"             # glob: search only .md files
-g "!*.min.js"        # glob: exclude .min.js files
--hidden              # include hidden files/directories
--no-ignore           # ignore .gitignore rules
-A 3                  # show 3 lines after match
-B 3                  # show 3 lines before match
-C 3                  # show 3 lines context (before + after)
--json                # output as JSON
-0                    # null-separated output (useful for xargs)
--max-depth 2         # limit directory recursion depth
--follow              # follow symlinks
--fixed-strings (-F)  # treat pattern as literal string, not regex
```

---

## Combining fzf + ripgrep

### Pattern 1: Interactive Grep — Search File Contents

Find files by their content, interactively:

```bash
rg --line-number --no-heading --color=always "" | fzf --ansi
```

Better version with preview:

```bash
rg --line-number --no-heading --color=always "" \
  | fzf --ansi \
        --delimiter=: \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up:60%:border-bottom:+{2}+3/3:~3'
```

- `{1}` = first field (filename), `{2}` = second field (line number)
- `bat` is a `cat` alternative with syntax highlighting (install separately)

### Pattern 2: Live Interactive Grep (Reload on Query Change)

```bash
rg_fzf() {
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case"
  INITIAL_QUERY="${*:-}"
  fzf --ansi --disabled \
      --query "$INITIAL_QUERY" \
      --bind "start:reload:$RG_PREFIX {q}" \
      --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
      --delimiter : \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-window 'right,60%,border-left,+{2}+3/3,~3'
}
```

`--disabled` turns off fzf's own fuzzy matching — fzf just displays results; rg does the actual filtering. As you type, rg reruns with your query.

### Pattern 3: File Finder (Like Ctrl+P in VSCode)

Find files by name using fd or find, open in editor:

```bash
# Using fd (a modern find replacement)
fd --type f | fzf --preview 'bat --color=always {}' | xargs $EDITOR

# Using find
find . -type f | fzf --preview 'cat {}' | xargs $EDITOR
```

### Pattern 4: Open Grep Results in Editor

```bash
# Search for a pattern, pick a result, open at that line in vim
rg --line-number "TODO" \
  | fzf --delimiter=: \
        --preview 'bat --color=always --highlight-line {2} {1}' \
  | awk -F: '{print "+" $2 " " $1}' \
  | xargs -o vim
```

For neovim:

```bash
  | awk -F: '{print $1 " +" $2}' \
  | xargs -o nvim
```

### Pattern 5: Search + Copy to Clipboard

```bash
rg "pattern" | fzf | pbcopy           # macOS
rg "pattern" | fzf | xclip -selection clipboard  # Linux
```

---

## Shell Integration (fzf builtins)

After running `fzf --install`, these keybindings are available in bash/zsh:

|Keybinding|Action|
|---|---|
|`Ctrl+R`|Search shell history interactively|
|`Ctrl+T`|Paste selected file path into command line|
|`Alt+C`|cd into selected directory|

### Fuzzy Completion with `**`

```bash
vim **<Tab>           # fuzzy pick file to open
cd **<Tab>            # fuzzy pick directory to cd into
kill -9 **<Tab>       # fuzzy pick process to kill
ssh **<Tab>           # fuzzy pick from ~/.ssh/config hosts
export **<Tab>        # fuzzy pick env variable
unset **<Tab>
```

---

## Useful Shell Functions

Add these to your `.bashrc` / `.zshrc`:

### `fif` — Find In File (interactive grep → open in editor)

```bash
fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" \
    | fzf --preview "highlight -O ansi -l {} 2> /dev/null \
           | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' \
           || rg --ignore-case --pretty --context 10 '$1' {}"
}
```

### `fcd` — Fuzzy cd

```bash
fcd() {
  local dir
  dir=$(find ${1:-.} -type d 2>/dev/null | fzf +m) && cd "$dir"
}
```

### `fkill` — Fuzzy kill process

```bash
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  [ -n "$pid" ] && echo "$pid" | xargs kill -${1:-9}
}
```

### `fh` — Fuzzy history execute

```bash
fh() {
  eval $(history | fzf +s --tac | sed 's/ *[0-9]* *//')
}
```

---

## Environment Variables (fzf)

Set in your shell config to apply globally:

```bash
# Default command fzf uses to list files (override with fd for speed + .gitignore respect)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Default options applied to every fzf invocation
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --preview-window=right:50%
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
'

# Ctrl+T behavior
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}'"

# Alt+C behavior
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -50'"
```

---

## ripgrep Configuration File

Create `~/.ripgreprc`:

```
# Always show line numbers
--line-number

# Smart case (case-insensitive unless pattern has uppercase)
--smart-case

# Follow symlinks
--follow

# Max columns to show (avoids huge minified lines)
--max-columns=150
--max-columns-preview

# Glob exclusions
--glob=!.git
--glob=!node_modules
--glob=!*.lock
--glob=!dist
```

Then set in shell config:

```bash
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
```

---

## Advanced Patterns

### Search, Select Multiple, Batch Edit

```bash
rg -l "old_function" \
  | fzf --multi \
  | xargs sed -i 's/old_function/new_function/g'
```

### Browse Git Log with Preview

```bash
git log --oneline \
  | fzf --preview 'git show --stat --color=always {1}' \
  | awk '{print $1}' \
  | xargs git show
```

### Switch Git Branch

```bash
git branch | fzf | xargs git checkout
```

### Search Only Staged Files

```bash
git diff --cached --name-only | fzf --preview 'git diff --cached --color=always {}'
```

### Docker: Attach to Container

```bash
docker ps | fzf | awk '{print $1}' | xargs docker exec -it sh
```

---

## Tips & Gotchas

- **rg skips binary files and `.git` by default** — use `--no-ignore` and `--hidden` to override
- **fzf reads from stdin only** — it doesn't run subprocesses itself; chain with pipes
- **`--disabled` in fzf** turns off fuzzy matching so an external tool (rg) does filtering
- **`{q}` in `--bind` or `--preview`** refers to the current query string typed in fzf
- **`{}` in `--preview`** refers to the currently highlighted line
- **`bat`** is optional but highly recommended for previews; fall back to `cat` if not installed
- **Performance**: rg is fast enough that live reload (`change:reload`) is generally usable even on large codebases
- **`.gitignore` inheritance**: rg respects ignore files at every parent directory level, not just the project root

---

## Quick Reference Card

```
rg "pattern"                        Basic search
rg -l "pattern"                     Files only
rg -i "pattern"                     Case-insensitive
rg "pattern" -g "*.js"              Limit to JS files
rg "pattern" --hidden --no-ignore   Include everything

fzf                                 Fuzzy pick from stdin
fzf -m                              Multi-select
fzf --preview 'cat {}'              Preview selected item
fzf --height 40% --reverse          Compact inline mode

rg "" | fzf --ansi                  Interactive grep (basic)
fd | fzf                            Interactive file picker
git branch | fzf | xargs git checkout   Fuzzy branch switch
```