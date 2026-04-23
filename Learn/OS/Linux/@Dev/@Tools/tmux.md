# tmux

A terminal multiplexer: run multiple terminal sessions inside a single window, detach them, and reattach from anywhere. Sessions persist even when your connection drops.

---

## Core Concepts

tmux has a three-level hierarchy:

- **Session** — the outermost container. Survives disconnection. Named or numbered.
- **Window** — like a browser tab. Each fills the full terminal.
- **Pane** — a split view inside a window. Each pane is an independent shell.

**The Prefix Key — `Ctrl+b`** Every tmux keybinding starts with the prefix, then a second key — pressed _sequentially_, not simultaneously. Example: to split horizontally, press `Ctrl+b`, release, then press `%`. The prefix can be rebound (many users prefer `Ctrl+a`).

**Detach vs Exit** Detaching (`Ctrl+b d`) leaves the session running in the background — you can reattach later. Typing `exit` in every pane terminates the session permanently.

---

## Sessions

Sessions are the outermost container. They persist independently of your terminal window or SSH connection.

**From the shell:**

|Command|Action|
|---|---|
|`tmux`|Start a new unnamed session|
|`tmux new -s <name>`|Start a named session|
|`tmux attach`|Attach to the most recent session|
|`tmux attach -t <name>`|Attach to a specific session|
|`tmux ls`|List all sessions|
|`tmux kill-session -t <name>`|Kill a specific session|
|`tmux kill-server`|Kill all sessions and the tmux server|

**Inside tmux (all require prefix first):**

|Keybind|Action|
|---|---|
|`Ctrl+b d`|Detach from session|
|`Ctrl+b $`|Rename current session|
|`Ctrl+b s`|Interactive session switcher|
|`Ctrl+b (`|Switch to previous session|
|`Ctrl+b )`|Switch to next session|

---

## Windows

Windows are like browser tabs. The status bar at the bottom shows all windows in the current session.

|Keybind|Action|
|---|---|
|`Ctrl+b c`|Create a new window|
|`Ctrl+b ,`|Rename current window|
|`Ctrl+b &`|Close current window (with confirmation)|
|`Ctrl+b 0–9`|Switch to window by number|
|`Ctrl+b p`|Go to previous window|
|`Ctrl+b n`|Go to next window|
|`Ctrl+b w`|Interactive window chooser (tree view)|
|`Ctrl+b f`|Search windows by name|
|`Ctrl+b l`|Jump to last (previously used) window|

---

## Panes

Panes split a window into multiple terminal areas. Each pane is fully independent — different directories, different processes.

|Keybind|Action|
|---|---|
|`Ctrl+b %`|Split vertically (left/right)|
|`Ctrl+b "`|Split horizontally (top/bottom)|
|`Ctrl+b x`|Close current pane (with confirmation)|
|`Ctrl+b z`|Zoom pane to full window (toggle)|
|`Ctrl+b !`|Break pane out into its own window|
|`Ctrl+b q`|Show pane numbers (press number to jump)|
|`Ctrl+b {`|Move pane left|
|`Ctrl+b }`|Move pane right|
|`Ctrl+b Space`|Cycle through pane layouts|

**Resizing:**

|Keybind|Action|
|---|---|
|`Ctrl+b Alt+↑↓←→`|Resize pane by 5 cells|
|`Ctrl+b Ctrl+↑↓←→`|Resize pane by 1 cell|

---

## Navigation Between Panes

|Keybind|Action|
|---|---|
|`Ctrl+b ↑↓←→`|Move to pane in that direction|
|`Ctrl+b o`|Cycle to next pane|
|`Ctrl+b ;`|Jump to last active pane|

**Command mode** — `Ctrl+b :` opens the tmux command prompt for direct commands:

```
:select-pane -t 2          # jump to pane 2
:swap-pane -s 1 -t 2       # swap pane positions
:join-pane -s :1.0 -t :2   # move pane from window 1 into window 2
```

---

## Copy Mode & Scrollback

Copy mode lets you scroll through terminal output, search it, and copy text without a mouse.

|Keybind|Action|
|---|---|
|`Ctrl+b [`|Enter copy mode|
|`q` or `Esc`|Exit copy mode|
|`Ctrl+b ]`|Paste from tmux buffer|

**While in copy mode (vi keys):**

|Key|Action|
|---|---|
|`↑↓` / `j k`|Scroll line by line|
|`Ctrl+u` / `Ctrl+d`|Scroll half-page up/down|
|`g` / `G`|Jump to top / bottom of scrollback|
|`/` then type|Search forward|
|`?` then type|Search backward|
|`n` / `N`|Next / previous search match|
|`Space`|Start selection|
|`Enter`|Copy selection to tmux buffer|

To enable mouse scrolling, add `set -g mouse on` to your config.

---

## Configuration

Config file lives at `~/.tmux.conf`. Reload it with `tmux source ~/.tmux.conf` or `Ctrl+b :` then `source-file ~/.tmux.conf`.

```bash
# Change prefix to Ctrl+a
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Enable mouse support
set -g mouse on

# More intuitive splits, open in current directory
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Vim-style pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Larger scrollback buffer
set -g history-limit 50000

# Vi keys in copy mode
setw -g mode-keys vi

# Reload config with prefix + r
bind r source-file ~/.tmux.conf \; display-message "Config reloaded"

# 256 color support
set -g default-terminal "screen-256color"
```

---

## Common Workflows

**Starting a dev session:**

1. `tmux new -s dev` — start a named session
2. `Ctrl+b c` — create windows (editor, server, git, etc.)
3. `Ctrl+b ,` — rename each window
4. `Ctrl+b %` or `Ctrl+b "` — split your editor window for a side terminal
5. `Ctrl+b d` — detach; come back anytime with `tmux attach -t dev`

**Surviving an SSH disconnect:**

1. SSH into the remote server
2. `tmux new -s work` — start all your work inside tmux
3. Connection drops — your processes keep running on the server
4. SSH back in → `tmux attach -t work` — everything as you left it

---

## Tips & Tricks

**Synchronized input to all panes** — run the same command on all panes simultaneously:

```
:setw synchronize-panes on
```

**Named clipboard buffers** — tmux has multiple buffers. View them with `:list-buffers`, choose one with `:choose-buffer`.

**Plugins via TPM (Tmux Plugin Manager)** — popular plugins include `tmux-resurrect` (save/restore sessions across reboots), `tmux-sensible` (sane defaults), and `tmux-yank` (system clipboard integration).

**Preset layouts** — `Ctrl+b Space` cycles through: even-horizontal, even-vertical, main-horizontal, main-vertical, tiled.

**Show a clock** — `Ctrl+b t` shows a large clock. Any key dismisses it.

**List all keybindings** — `Ctrl+b ?`

**Tmuxinator / tmuxp** — YAML-based tools to define and restore full session layouts (windows, panes, starting commands) with a single command.

---

## Installation

|OS|Command|
|---|---|
|macOS|`brew install tmux`|
|Ubuntu/Debian|`sudo apt install tmux`|
|Fedora/RHEL|`sudo dnf install tmux`|
|Arch|`sudo pacman -S tmux`|