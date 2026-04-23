# lazygit

A terminal UI for Git. Navigate repos, stage hunks, rebase interactively, and manage branches without typing raw Git commands.

> lazygit calls Git under the hood — it does not replace it. You can view the exact Git command each action runs by pressing `@` to open the command log.

---

## Table of Contents

1. [What is lazygit?](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#what-is-lazygit)
2. [Installation](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#installation)
3. [Launching lazygit](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#launching-lazygit)
4. [The UI — Five Panels](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#the-ui--five-panels)
5. [Navigation Basics](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#navigation-basics)
6. [Staging & Committing](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#staging--committing)
7. [Branch Management](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#branch-management)
8. [Commit History](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#commit-history)
9. [Rebase & Cherry-pick](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#rebase--cherry-pick)
10. [Remotes, Push & Pull](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#remotes-push--pull)
11. [Stashing](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#stashing)
12. [Configuration](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#configuration)
13. [Power Tips](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#power-tips)
14. [Quick Cheatsheet](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#quick-cheatsheet)

---

## What is lazygit?

lazygit is an open-source terminal UI written in Go by Jesse Duffield. It wraps Git operations in a keyboard-driven interface so you can stage hunks, reorder commits, cherry-pick, and manage branches visually.

**Official repo:** `github.com/jesseduffield/lazygit`

What you can do with it:

- Stage individual files, hunks, or lines
- Write commits, amend, fixup, reword
- Manage branches, tags, and remotes
- Interactive rebase with visual reordering
- Cherry-pick commits across branches
- Resolve merge conflicts
- Stash management
- Inline diff viewing

---

## Installation

lazygit requires Git to be installed separately.

### macOS

```sh
# Homebrew (recommended)
brew install lazygit

# MacPorts
sudo port install lazygit
```

### Linux

```sh
# Ubuntu / Debian — via PPA
sudo add-apt-repository ppa:lazygit-team/release
sudo apt-get update
sudo apt-get install lazygit

# Arch Linux
sudo pacman -S lazygit

# Fedora via Copr
sudo dnf copr enable atim/lazygit
sudo dnf install lazygit

# Nix
nix-env -iA nixpkgs.lazygit
```

### Windows

```sh
# Scoop
scoop install lazygit

# Winget
winget install JesseDuffield.lazygit

# Chocolatey
choco install lazygit
```

### Go (manual)

```sh
go install github.com/jesseduffield/lazygit@latest
```

Verify: `lazygit --version`

---

## Launching lazygit

```sh
# From inside any Git repo
lazygit

# Common alias — add to .bashrc / .zshrc
alias lg=lazygit

# Open a specific repo path
lazygit -p /path/to/repo
```

lazygit must be run inside a Git-initialized directory, or with a valid `-p` path.

---

## The UI — Five Panels

```
┌─────────────┬────────────────────────────────────┐
│ ① Status    │                                    │
├─────────────┤   ⑤ Main (diff / preview)          │
│ ② Files     │                                    │
├─────────────┤                                    │
│ ③ Branches  │                                    │
│ ④ Commits   ├────────────────────────────────────┤
│    Stash    │ command log / status bar           │
└─────────────┴────────────────────────────────────┘
```

|Panel|Focus key|Purpose|
|---|---|---|
|Status|`1`|Repo overview, branch info|
|Files|`2`|Working tree — unstaged & staged changes|
|Branches|`3`|Local and remote branches|
|Commits|`4`|Commit log for the current branch|
|Stash|`5`|Stash entries|
|Main|(auto)|Diff / preview of the selected item|

Press `?` in any panel for context-sensitive keybindings.

---

## Navigation Basics

|Key|Action|
|---|---|
|`↑` / `↓`|Move up / down in a panel|
|`←` / `→`|Switch between left-side panels|
|`1`–`5`|Jump directly to a panel|
|`h` / `l`|Navigate sub-tabs within a panel|
|`[` / `]`|Alternate tab navigation|
|`?`|Show help (context-sensitive)|
|`q`|Quit lazygit / close popup|
|`Esc`|Cancel / go back|
|`x`|Open context menu for selected item|
|`@`|Show command log (raw Git commands)|
|`:`|Run a custom shell command|
|`+` / `_`|Resize the main panel|

---

## Staging & Committing

Work in the **Files panel** (`2`). Unstaged and staged changes are listed separately.

### Staging files

|Key|Action|
|---|---|
|`Space`|Toggle stage / unstage selected file|
|`a`|Stage all changed files|
|`Enter`|Enter hunk / line view for the file|

### Staging individual hunks or lines

Press `Enter` on a file to enter its diff. Inside the hunk view:

|Key|Action|
|---|---|
|`Space`|Stage the highlighted hunk|
|`v` then `Space`|Select a line range, then stage it|
|`d`|Discard the selected hunk (destructive — not recoverable)|
|`Esc`|Return to file list|

> **Warning:** Discarding hunks or files removes working-tree changes permanently. Git cannot recover them.

### Committing

|Key|Action|
|---|---|
|`c`|Commit — opens inline message editor|
|`C`|Commit — opens `$EDITOR`|
|`A`|Amend last commit with staged changes|
|`w`|Commit without running pre-commit hooks|

### Typical workflow

1. Press `2` → Files panel
2. Navigate with `↑↓` — diff shows in main panel automatically
3. `Space` per file, or `Enter` → `Space` per hunk to stage selectively
4. Press `c`, type commit message, press `Enter`

---

## Branch Management

Access with `3`. Remote branches appear in a sub-tab inside this panel.

|Key|Action|
|---|---|
|`Space`|Checkout selected branch|
|`n`|Create new branch from current HEAD|
|`d`|Delete local branch (safe — blocked if unmerged)|
|`D`|Force delete (even if unmerged)|
|`M`|Merge selected branch into current|
|`r`|Rebase current branch onto selected|
|`R`|Rename selected branch|
|`f`|Fast-forward branch from its upstream|
|`g`|Reset current branch to a commit|
|`c`|Checkout a branch by typing its name|

---

## Commit History

Access with `4`. Selecting a commit shows its diff in the main panel.

|Key|Action|
|---|---|
|`r`|Reword commit message (inline)|
|`R`|Reword using `$EDITOR`|
|`d`|Drop (delete) commit|
|`e`|Edit — stop rebase at this commit to amend|
|`f`|Fixup — squash into parent, discard message|
|`s`|Squash into parent, combine messages|
|`ctrl+j`|Move commit down|
|`ctrl+k`|Move commit up|
|`c`|Mark commit for cherry-pick|
|`t`|Create a tag at this commit|
|`ctrl+r`|Create a revert commit|
|`y`|Copy commit SHA to clipboard|

> **Note:** Drop, squash, fixup, and reorder rewrite history via interactive rebase. Avoid using these on commits already pushed to a shared remote unless force-push is agreed upon with your team.

---

## Rebase & Cherry-pick

### Interactive rebase

1. Press `4` → Commits panel
2. Navigate to the oldest commit you want to act on
3. Press `e` to begin editing — commits above become editable
4. Use `d`, `s`, `f`, `ctrl+j/k` to drop, squash, fixup, or reorder
5. Press `m` to apply the rebase

### Cherry-picking commits

1. Navigate to the **source branch** (the branch with commits you want)
2. Press `c` on each commit to mark it — use `v` for multi-select
3. Switch to the **target branch** (checkout it via Branches panel)
4. Press `V` in the Commits panel to apply (paste) the cherry-picked commits

### Resolving merge conflicts

When a rebase or merge produces conflicts, conflicted files appear in the Files panel marked with `UU`. Press `Enter` on a conflicted file to open the conflict resolution view:

|Key|Action|
|---|---|
|`↑` / `↓`|Move between conflict markers|
|`Space`|Pick the highlighted side (ours or theirs)|
|`b`|Pick both sides|
|`Z`|Undo last pick|

After resolving all conflicts, stage the file (`Space`) and continue the rebase or merge.

---

## Remotes, Push & Pull

Manage remotes in the **Branches panel** under the Remotes sub-tab.

### In the Files / Status area

|Key|Action|
|---|---|
|`P`|Push current branch to its upstream|
|`p`|Pull (fetch + merge/rebase, per config)|
|`f`|Fetch all remotes|

### In the Branches panel

|Key|Action|
|---|---|
|`f`|Fetch the selected remote branch|
|`Space`|Checkout a remote branch (creates local tracking branch)|
|`d`|Delete a remote branch|
|`n`|Add a new remote|

### Force pushing

Press `P` — if a force push is needed (e.g., after a rebase), lazygit will ask for confirmation before using `--force-with-lease`.

---

## Stashing

Access with `5`. Stash entries are listed newest-first.

|Key|Action|
|---|---|
|`s` (in Files panel)|Stash all changes|
|`S`|Stash with options (message, keep staged, etc.)|
|`Space` (in Stash panel)|Apply selected stash (keep entry)|
|`g`|Pop selected stash (apply and remove)|
|`d`|Drop (delete) selected stash|
|`Enter`|Preview stash diff in main panel|

---

## Configuration

lazygit stores its config at:

- **macOS / Linux:** `~/.config/lazygit/config.yml`
- **Windows:** `%APPDATA%\lazygit\config.yml`

Run `lazygit --print-config-dir` to confirm the location on your system.

### Useful config options

```yaml
gui:
  theme:
    activeBorderColor:
      - green
      - bold
  showIcons: true          # requires a Nerd Font
  nerdFontsVersion: "3"

git:
  paging:
    colorArg: always
    pager: delta           # use delta for diffs (install separately)
  merging:
    manualCommit: false

keybinding:
  universal:
    quit: q
```

### Using delta as a pager

[delta](https://github.com/dandavison/delta) improves diff display significantly. Install it, then add to config:

```yaml
git:
  paging:
    colorArg: always
    pager: delta --dark --paging=never
```

### Custom commands

You can bind shell commands to keys:

```yaml
customCommands:
  - key: '<c-f>'
    command: 'git fetch --all --prune'
    context: 'global'
    description: 'Fetch all remotes and prune'
```

---

## Power Tips

**Open the command log** — press `@` to see every Git command lazygit ran. Useful for learning what it's doing under the hood.

**Filter lists** — press `/` in any panel to filter by text. Press `Esc` to clear.

**Multi-select** — press `v` to enter range-selection mode in any list, then act on all selected items at once.

**Jump to recent repos** — from the Status panel, press `space` to open a recent repositories list.

**Edit any file in your editor** — in the Files panel, press `o` to open the selected file in `$EDITOR`.

**Undo** — press `z` to undo the last lazygit action (uses Git's reflog where possible). This is a best-effort undo; not all operations are reversible.

**Diff any two branches** — in the Branches panel, select a branch and press `Enter` to view its commits. Use `d` to compare with another ref.

**Bisect** — lazygit supports `git bisect`. In the Commits panel, press `b` to start bisecting and mark commits as good/bad.

---

## Quick Cheatsheet

### Global

|Key|Action|
|---|---|
|`1`–`5`|Switch panels|
|`?`|Help|
|`q`|Quit|
|`@`|Command log|
|`:`|Run shell command|
|`/`|Filter|
|`z`|Undo|

### Files panel

|Key|Action|
|---|---|
|`Space`|Stage / unstage|
|`a`|Stage all|
|`Enter`|Hunk view|
|`c`|Commit|
|`A`|Amend|
|`s`|Stash|
|`d`|Discard|
|`o`|Open in editor|

### Branches panel

|Key|Action|
|---|---|
|`Space`|Checkout|
|`n`|New branch|
|`d` / `D`|Delete / force delete|
|`M`|Merge into current|
|`r`|Rebase current onto selected|
|`f`|Fast-forward|
|`P`|Push|
|`p`|Pull|

### Commits panel

|Key|Action|
|---|---|
|`r` / `R`|Reword|
|`d`|Drop|
|`s`|Squash|
|`f`|Fixup|
|`e`|Edit (stop rebase here)|
|`ctrl+j/k`|Move commit down / up|
|`c`|Mark for cherry-pick|
|`V`|Paste cherry-picked commits|
|`ctrl+r`|Revert|
|`y`|Copy SHA|

---

_Source: [lazygit GitHub repository](https://github.com/jesseduffield/lazygit) — always refer to the official docs and `?` in-app help for the most current keybindings, as they may differ across versions._

---

# 15 Lazygit Features

_Based on a video walkthrough by Jesse, the creator of Lazygit._

---

## 1. Staging Files Quickly

Navigate to a file using the arrow keys and press `Space` to stage it. To stage all files at once, press `A`.

## 2. Staging Individual Lines

Press `Enter` on a file to open the diff view. From there, press `Space` on individual lines to add them to the index. Use `V` to begin a range selection, then `Space` again to apply it. Press `Tab` to switch panels, and `D` to unstage a specific line or delete it from the working tree.

## 3. Cherry-Picking Commits

Navigate to the commits panel and press `C` on a commit to mark it for cherry-pick. Switch to the target branch, then press `V` to paste the cherry-picked commits.

## 4. Discarding Changes

Press `D` on a file to discard all changes to it (the file itself is not deleted). Press `Shift+D` for additional reset options, including a soft reset or a full nuke of the working tree — useful when you want to discard everything in one step.

## 5. Interactive Rebasing

Navigate to the commits panel using the left and right arrow keys, then press `E` to begin an interactive rebase. From there:

- `E` — mark a commit as **edit**
- `S` — **squash** into the commit below
- `F` — **fixup** (squash without keeping the message)
- `D` — **drop** a commit

Press `M` to access rebase options, then choose **Continue** to apply.

## 6. Reordering Commits

While in an interactive rebase, use `Ctrl+J` and `Ctrl+K` to move commits up and down.

## 7. Amending a Commit

Stage the changes you want to add, navigate to the target commit, and press `Shift+A` to amend it directly.

## 8. Fixup Commits

Stage a change and press `Shift+F` on the commit you want to fix up. This creates a fixup commit targeting that specific commit. To apply all pending fixup commits, press `Shift+S` and confirm — Lazygit performs the squash automatically.

## 9. Opening a Pull Request

Press `Shift+P` to push the current branch. Once pushed, Lazygit can open a pull request in the browser directly from the interface.

## 10. Reverting a Commit

Navigate to a commit and press `T` to revert it. This creates a new revert commit, making it suitable for use on shared or protected branches.

## 11. Selective Stashing

Press `S` to stash everything. Press `Shift+S` to stash only staged changes, leaving unstaged files untouched. This is useful when you want to set aside specific work without stashing the entire working tree.

## 12. Moving a Patch Between Commits

Open a commit with `Enter`, then open a file within it with `Enter` again. Use the arrow keys to select specific lines, which adds them to a custom patch. Press `Escape` to return, navigate to the destination commit, and press `Ctrl+P` to move the patch to that commit.

## 13. Removing a Patch from a Commit

Select lines in a commit file to build a patch, then choose the option to remove the patch. Lazygit performs an interactive rebase behind the scenes. If removing the lines causes a merge conflict in a later commit, it will pause and let you resolve the conflict manually before continuing.

## 14. Rebasing onto origin/master

Press `F` on the master branch to fetch the latest changes from the remote. Then press `R` to rebase the current branch onto it. If conflicts arise, resolve them in the working tree and continue as normal.

## 15. Switching Branches with Uncommitted Changes

When switching branches with a dirty working tree, Lazygit offers to stash and restore your changes automatically. If no merge conflict would actually result, it handles the switch without requiring any manual stash management.

---

## 16. Customizing the Color Theme

Lazygit supports color theme customization through its configuration. Active and inactive UI elements can be assigned different colors and styles (e.g., bold, yellow, red), allowing for a personalized terminal appearance independent of the underlying Git workflow.