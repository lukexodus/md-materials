# git-delta

A syntax-highlighting pager for `git diff`, `git show`, `git log`, and `grep` output. Replaces the default diff display with side-by-side views, word-level diffing, line numbers, and theme support.

---

## Installation

|OS|Command|
|---|---|
|macOS|`brew install git-delta`|
|Ubuntu/Debian|`sudo apt install git-delta`|
|Fedora/RHEL|`sudo dnf install git-delta`|
|Arch|`sudo pacman -S git-delta`|
|Cargo (any)|`cargo install git-delta`|
|Binary|GitHub releases: `github.com/dandavison/delta`|

The binary is called `delta`, not `git-delta`.

---

## Setup

delta works as git's pager. Add it to `~/.gitconfig`:

```ini
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true        # use n/N to move between diff sections
    light = false          # set to true if using a light terminal theme
    side-by-side = true    # show diffs side by side

[merge]
    conflictstyle = diff3

[diff]
    colorMoved = default
```

Or set it from the command line:

```bash
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
```

---

## Basic Usage

Once configured, delta works transparently — you just use git normally:

```bash
git diff
git show
git log -p
git stash show -p
```

delta intercepts the output automatically. No change to your git commands needed.

You can also run delta directly:

```bash
delta file_a.txt file_b.txt         # diff two files
diff -u file_a file_b | delta       # pipe any unified diff to delta
```

---

## Core Features

### Syntax Highlighting

delta highlights code using the same themes as `bat`. Every language supported by bat is supported by delta.

```ini
[delta]
    syntax-theme = Dracula
```

List all available themes:

```bash
delta --list-syntax-themes
```

Preview all themes against a sample diff:

```bash
delta --show-syntax-themes
```

### Side-by-Side View

```ini
[delta]
    side-by-side = true
```

Or toggle per-command:

```bash
git diff | delta --side-by-side
git diff | delta --side-by-side=false    # force off
```

Side-by-side shows old on the left, new on the right. Lines that don't fit the terminal width wrap automatically.

### Word-Level Diffing

delta highlights the exact words that changed within a line, not just the whole line. This is on by default. To control it:

```ini
[delta]
    word-diff-regex = \S+         # default: any non-whitespace token
```

```bash
# More granular — character level
git diff | delta --word-diff-regex="."
```

### Line Numbers

```ini
[delta]
    line-numbers = true
```

Line numbers appear in the gutter. In side-by-side mode, each side gets its own line numbers.

---

## Navigation

With `navigate = true` in config, you can jump between files/sections in the diff:

|Key|Action|
|---|---|
|`n`|Next diff section / file|
|`N`|Previous diff section / file|
|`Space`|Page down|
|`b`|Page up|
|`q`|Quit|
|`/`|Search|
|`?`|Help|

---

## Configuration Reference

All options go under `[delta]` in `~/.gitconfig`.

### Display

```ini
[delta]
    side-by-side = true
    line-numbers = true
    navigate = true
    syntax-theme = Dracula

    # Width of side-by-side panels (default: terminal width / 2)
    width = 120

    # Wrap long lines rather than truncating
    wrap-max-lines = 2

    # Show file modification indicators in header
    file-modified-label = "modified:"
    file-added-label = "added:"
    file-removed-label = "removed:"
    file-renamed-label = "renamed:"
```

### Colors & Styling

```ini
[delta]
    # Plus/minus colors (added/removed lines)
    plus-color = "#1a3a1a"
    minus-color = "#3a1a1a"

    # Word-level highlight colors
    plus-emph-color = "#2a5a2a"
    minus-emph-color = "#5a2a2a"

    # Line number colors
    line-numbers-plus-style = green
    line-numbers-minus-style = red
    line-numbers-zero-style = "#555555"

    # File header style
    file-style = bold yellow
    file-decoration-style = yellow ul
```

Colors accept: named colors (`red`, `green`), hex (`#rrggbb`), or `normal`.

### Hunk Headers

The hunk header is the `@@ -x,y +x,y @@` line showing function/class context.

```ini
[delta]
    hunk-header-style = file line-number syntax
    hunk-header-decoration-style = blue box
    hunk-header-file-style = red
    hunk-header-line-number-style = "#888888"
```

### Diff Options

```ini
[delta]
    # Ignore whitespace-only changes
    whitespace-error-style = 22 reverse

    # Number of context lines (default: 3)
    # Set in [diff] section, not [delta]
```

```ini
[diff]
    context = 5
```

---

## Merge Conflicts

delta can display merge conflicts with better formatting. With `conflictstyle = diff3` in `[merge]`, delta shows the base version alongside both sides:

```ini
[merge]
    conflictstyle = diff3
```

To view conflicts in a file:

```bash
delta --show-whitespace-error path/to/conflicted-file
```

---

## Named Profiles (Features)

delta supports named feature blocks you can compose:

```ini
[delta "my-theme"]
    side-by-side = true
    line-numbers = true
    syntax-theme = Nord
    navigate = true

[delta "minimal"]
    side-by-side = false
    line-numbers = false

[delta]
    features = my-theme       # activate a named feature block
```

Switch profiles:

```bash
git diff | delta --features minimal
```

This lets you maintain multiple styles and switch between them easily.

---

## Using with Other Tools

### grep

```bash
grep -n "pattern" file.rs | delta
```

### diff

```bash
diff -u old.py new.py | delta
```

### git log

```bash
git log -p --follow -- path/to/file    # delta activates automatically
```

### tig

Add to `~/.tigrc`:

```
color diff-header	yellow	default
```

Or configure tig to use delta as its diff pager.

### bat integration

delta uses bat's theme list — any theme that works in bat works in delta:

```bash
bat --list-themes        # same themes available in delta
```

---

## Practical Examples

**Try delta without changing your git config:**

```bash
GIT_PAGER="delta" git diff
GIT_PAGER="delta --side-by-side" git diff HEAD~3
```

**One-shot side-by-side for a specific commit:**

```bash
git show abc1234 | delta --side-by-side
```

**Diff two branches with full context:**

```bash
git diff main..feature | delta --line-numbers
```

**Preview all available syntax themes:**

```bash
delta --show-syntax-themes | less -R
```

**Disable delta temporarily (fallback to standard diff):**

```bash
git --no-pager diff
GIT_PAGER=cat git diff
```

---

## Comparison with Alternatives

|Tool|Syntax highlight|Side-by-side|Word diff|Git integration|
|---|---|---|---|---|
|`delta`|Yes|Yes|Yes|Via pager config|
|`diff-so-fancy`|Partial|No|Yes|Via pager config|
|`difftastic`|Yes|Yes|Structural|Via difftool|
|built-in `git diff`|No|No|`--word-diff`|Native|

difftastic does structural/AST-aware diffing (understands code structure, not just lines) and is worth knowing about. delta and difftastic solve slightly different problems — delta is a better pager, difftastic is a smarter differ.

---

## Tips

**`navigate = true` is essential** — without it, jumping between changed files in a large diff requires manual scrolling. It's one of the most useful settings.

**Side-by-side needs a wide terminal** — below ~80 columns it becomes cramped. delta auto-adjusts but a wider terminal (160+) is where side-by-side really shines.

**`--color-only` for interactive mode** — the `interactive.diffFilter` setting uses `--color-only` so that `git add -p` still works correctly. Without it, delta's output can confuse the patch staging logic.

**Theme consistency** — if you use `bat`, set both to the same theme for a consistent terminal aesthetic across file viewing and diffing.

**`diff.colorMoved = default`** — this git setting highlights moved blocks distinctly from added/removed lines. delta renders it well and it meaningfully reduces noise when code is reorganized rather than changed.