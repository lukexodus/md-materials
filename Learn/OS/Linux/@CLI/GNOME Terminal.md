# GNOME Terminal — Comprehensive Productivity Guide

> Context: GNOME Terminal as shipped with Arch Linux (via `gnome-terminal` package). Some behaviors depend on your shell (bash/zsh/fish) and installed plugins. Shell-specific features are labeled accordingly.

---

## Keyboard Shortcuts — Terminal Window & Tabs

### Window Management

|Action|Shortcut|
|---|---|
|New window|`Ctrl + Shift + N`|
|Close window|`Ctrl + Shift + Q` (or close all tabs)|
|Full screen|`F11`|
|Zoom in (font size)|`Ctrl + +`|
|Zoom out|`Ctrl + -`|
|Reset zoom|`Ctrl + 0`|

### Tab Management

| Action          | Shortcut                   |
| --------------- | -------------------------- |
| New tab         | `Ctrl + Shift + T`         |
| Close tab       | `Ctrl + Shift + W`         |
| Next tab        | `Ctrl + Page Down`         |
| Previous tab    | `Ctrl + Page Up`           |
| Move tab right  | `Ctrl + Shift + Page Down` |
| Move tab left   | `Ctrl + Shift + Page Up`   |
| Switch to tab N | `Alt + N` (N = 1–9)        |

### Copy, Paste, Search

|Action|Shortcut|
|---|---|
|Copy|`Ctrl + Shift + C`|
|Paste|`Ctrl + Shift + V`|
|Find (search scrollback)|`Ctrl + Shift + F`|
|Find next|`Ctrl + Shift + H` (or `G`)|
|Find previous|`Ctrl + Shift + J` (or `Shift + G`)|

> Note: `Ctrl + C` sends SIGINT (interrupt), not copy. Always use `Ctrl + Shift + C` to copy text.

---

## Keyboard Shortcuts — Shell (Bash/Zsh)

These work at the shell prompt, not just GNOME Terminal — they are readline/zsh line-editor shortcuts.

### Cursor Movement

|Action|Shortcut|
|---|---|
|Move to beginning of line|`Ctrl + A`|
|Move to end of line|`Ctrl + E`|
|Move one word left|`Alt + B`|
|Move one word right|`Alt + F`|
|Move one character left|`Ctrl + B`|
|Move one character right|`Ctrl + F`|

### Editing

|Action|Shortcut|
|---|---|
|Delete char under cursor|`Ctrl + D` (also closes terminal if line is empty)|
|Delete char before cursor|`Ctrl + H` or `Backspace`|
|Delete word before cursor|`Ctrl + W`|
|Delete word after cursor|`Alt + D`|
|Delete from cursor to end|`Ctrl + K`|
|Delete from cursor to start|`Ctrl + U`|
|Paste killed (cut) text|`Ctrl + Y`|
|Rotate through killed text|`Alt + Y` (after `Ctrl + Y`)|
|Transpose chars|`Ctrl + T`|
|Transpose words|`Alt + T`|
|Uppercase word|`Alt + U`|
|Lowercase word|`Alt + L`|
|Capitalize word|`Alt + C`|

### History Navigation

|Action|Shortcut|
|---|---|
|Previous command|`Ctrl + P` or `↑`|
|Next command|`Ctrl + N` or `↓`|
|Search history backward|`Ctrl + R`|
|Search history forward|`Ctrl + S` (may need `stty -ixon` in `.bashrc`)|
|Accept current history match|`Enter` or `Ctrl + J`|
|Cancel history search|`Ctrl + G`|
|First command in history|`Alt + <`|
|Last command in history|`Alt + >`|
|Run last command|`!!`|
|Run last command as root|`sudo !!`|
|Last argument of prev cmd|`Alt + .` or `!$`|
|Nth argument of prev cmd|`!:N` (e.g., `!:2`)|
|All args of previous cmd|`!*`|

### Process Control

|Action|Shortcut|
|---|---|
|Interrupt (SIGINT)|`Ctrl + C`|
|Suspend (SIGTSTP)|`Ctrl + Z`|
|Resume suspended job|`fg`|
|Resume in background|`bg`|
|End of file / logout|`Ctrl + D`|
|Clear screen|`Ctrl + L`|
|Redraw line|`Ctrl + R` then `Ctrl + C` (or `Ctrl + L`)|

### Terminal Flow Control

|Action|Shortcut|
|---|---|
|Pause output (XOFF)|`Ctrl + S`|
|Resume output (XON)|`Ctrl + Q`|

> If `Ctrl + S` freezes your terminal, press `Ctrl + Q` to unfreeze. To disable this entirely, add `stty -ixon` to your `.bashrc`/`.zshrc`.

---

## Scrollback & Output Navigation

|Action|Shortcut / Method|
|---|---|
|Scroll up|`Shift + Page Up`|
|Scroll down|`Shift + Page Down`|
|Scroll to top|`Shift + Home`|
|Scroll to bottom|`Shift + End`|
|Scroll one line up|`Shift + ↑`|
|Scroll one line down|`Shift + ↓`|
|Search scrollback buffer|`Ctrl + Shift + F`|

Scrollback line limit is configurable: **Edit → Preferences → [Profile] → Scrolling**. Set to unlimited for long log work, or a high number (e.g., 50,000) for memory efficiency.

---

## Profiles

Profiles let you maintain different terminal environments (e.g., dark theme for coding, light for writing, different fonts for presentations).

### Creating and Using Profiles

- Go to **Edit → Preferences → Profiles → +**
- Set name, colors, font, cursor style, scrollback, transparency per profile
- Open a new terminal/tab with a specific profile: **File → Open Tab** → select profile

### Profile CLI Flag

```bash
gnome-terminal --profile="ProfileName"
```

Useful for `.desktop` launchers or scripts that open a terminal in a specific context.

### Per-Profile Custom Commands

In **Profile → Command**, enable "Run a custom command instead of my shell" to launch a specific shell, SSH session, or tool (e.g., `tmux`, `fish`, `htop`) automatically when that profile opens.

---

## Custom Title and Tab Naming

### Manually Set Tab Title

```bash
echo -ne "\033]0;My Custom Title\007"
```

Add this to a script or alias to label long-running tasks in tabs.

### Dynamic Title in Bash

Add to `~/.bashrc`:

```bash
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
```

### Dynamic Title in Zsh

Add to `~/.zshrc`:

```bash
precmd() { print -Pn "\e]0;%n@%m: %~\a" }
```

---

## Color and Appearance

### Built-in Color Scheme Access

**Edit → Preferences → [Profile] → Colors**

- Disable "Use colors from system theme" to use custom palettes
- Choose from built-in schemes or set each of the 16 ANSI colors manually

### Transparency

**Edit → Preferences → [Profile] → General → Transparency slider**

Requires a compositor to be active (GNOME's Mutter handles this by default on a standard GNOME session).

### Font

**Edit → Preferences → [Profile] → General → Custom font**

Recommended monospace fonts for terminal use: JetBrains Mono, Fira Code, Hack, Cascadia Code (all support ligatures if your terminal renders them, though GNOME Terminal has [Unverified] limited or no ligature support natively).

### Cursor Style

Options: Block, I-Beam, Underline — each can be set to blink or static. Configured per profile.

---

## Custom Keyboard Shortcuts

**Edit → Preferences → Shortcuts**

You can remap any default shortcut here — useful for resolving conflicts with shell shortcuts or matching muscle memory from other terminals.

> Note: Shortcuts defined here affect only GNOME Terminal, not the shell inside it.

---

## Working with Multiple Tabs Efficiently

### Opening Many Tabs at Launch

```bash
gnome-terminal \
  --tab --title="Server" -- bash -c "ssh user@server; exec bash" \
  --tab --title="Logs" -- bash -c "tail -f /var/log/syslog; exec bash" \
  --tab --title="Shell"
```

### Named Tabs via Script

```bash
#!/bin/bash
gnome-terminal \
  --tab --title="Dev" \
  --tab --title="Git" \
  --tab --title="Monitor" -- htop
```

### Broadcast Input to All Tabs

GNOME Terminal does not natively support broadcasting input to all tabs (unlike Terminator or iTerm2). Use `tmux` or `tmuxinator` for this workflow.

---

## Integration with tmux (Highly Recommended)

`tmux` runs inside GNOME Terminal and adds session persistence, pane splitting, and window management that GNOME Terminal lacks natively.

### Essential tmux Shortcuts (default prefix: `Ctrl + B`)

|Action|Shortcut|
|---|---|
|New window|`Ctrl + B` then `C`|
|Split horizontally|`Ctrl + B` then `"`|
|Split vertically|`Ctrl + B` then `%`|
|Navigate panes|`Ctrl + B` then arrow keys|
|Resize pane|`Ctrl + B` then `Ctrl + arrow`|
|Detach session|`Ctrl + B` then `D`|
|Re-attach session|`tmux attach` or `tmux a`|
|List sessions|`tmux ls`|
|Name window|`Ctrl + B` then `,`|

### Auto-launch tmux on Terminal Open

Add to `~/.bashrc` or `~/.zshrc`:

```bash
if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
  tmux attach 2>/dev/null || tmux new-session
fi
```

---

## Shell Productivity (Bash)

### History Configuration

Add to `~/.bashrc`:

```bash
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoredups:erasedups
HISTTIMEFORMAT="%F %T "
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
```

This keeps a large, timestamped, deduplicated history synced across sessions.

### Useful Bash Options

```bash
shopt -s autocd        # type dir name to cd into it
shopt -s cdspell       # fix minor typos in cd
shopt -s dirspell      # fix minor typos in directory completion
shopt -s globstar      # ** matches directories recursively
shopt -s checkwinsize  # update LINES/COLUMNS after each command
```

### Aliases Worth Adding

```bash
alias ll='ls -lah --color=auto'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
```

### Quick Navigation with `pushd`/`popd`

```bash
pushd /some/path    # go there and save current dir to stack
popd                # return to previous dir
dirs -v             # list directory stack
```

### `cd -` — Toggle Last Directory

```bash
cd /etc
cd /var/log
cd -        # goes back to /etc
```

---

## Shell Productivity (Zsh)

### Recommended Plugins (oh-my-zsh or manual)

- `zsh-autosuggestions` — suggests commands from history as you type; accept with `→`
- `zsh-syntax-highlighting` — colors valid commands green, invalid red
- `fzf` — fuzzy history search, file finder (replaces `Ctrl + R` with an interactive picker)
- `z` or `zoxide` — jump to frecent directories by partial name

### Zsh-Specific Features

```bash
# Glob qualifiers
ls **/*.log          # recursive glob (requires globstar in bash; native in zsh)
ls *(.)              # only regular files
ls *(/)              # only directories
ls *(.om)            # regular files, sorted by modification time

# Inline glob expansion
echo /usr/*/bin      # expands inline

# Extended history search
fc -l -10            # list last 10 commands with line numbers
```

---

## Useful CLI Tools That Enhance Terminal Productivity

These are standard or commonly available tools on Arch Linux. Install via `pacman` or `yay`.

### File Navigation

- `ranger` — vim-keyed TUI file manager
- `lf` — minimalist TUI file manager
- `nnn` — fast, lightweight file manager
- `broot` — fuzzy tree navigation

### Search & Find

- `fzf` — fuzzy finder for files, history, anything
- `fd` — faster, friendlier alternative to `find`
- `ripgrep` (`rg`) — fast recursive grep
- `ag` (the silver searcher) — similar to ripgrep

### File Viewing

- `bat` — `cat` with syntax highlighting and line numbers
- `less` — built-in pager; use `less -R` for color, `less +F` to follow files
- `most` — alternative pager

### System Monitoring

- `htop` — interactive process viewer
- `btop` — modern, full-featured resource monitor
- `glances` — system overview in one screen
- `iotop` — disk I/O per process
- `nethogs` — network usage per process

### Text Processing at Command Line

- `awk` — column-based text processing
- `sed` — stream editor for find/replace
- `cut`, `sort`, `uniq`, `tr`, `wc` — coreutils staples
- `jq` — JSON processor and pretty-printer
- `yq` — YAML processor

### Productivity Utilities

- `tldr` — simplified man pages with practical examples
- `zoxide` — smarter `cd` that tracks frecency
- `direnv` — auto-load/unload env vars per directory
- `entr` — re-run a command when files change
- `watch` — repeat a command on an interval (`watch -n 2 df -h`)
- `parallel` — run commands in parallel across inputs

---

## Scripting & Automation Tips

### Run Command in Background, Log Output

```bash
nohup long-running-command > output.log 2>&1 &
```

### Redirect Both stdout and stderr

```bash
command > all.log 2>&1
command &> all.log       # bash shorthand
```

### Tee — Write to File and See Output

```bash
command | tee output.log
command | tee -a output.log   # append
```

### Run After Logout — `disown`

```bash
command &
disown %1
```

Or use `nohup`.

### Repeat Until Success

```bash
until command; do sleep 5; done
```

### Run Command on Schedule Without Cron — `systemd-run`

```bash
systemd-run --on-active=10m /path/to/script.sh
```

### Quick Benchmark

```bash
time command
```

---

## Environment Variables

### View All

```bash
env
printenv
```

### Set Temporarily (current session)

```bash
export VAR=value
```

### Set Permanently

Add to `~/.bashrc`, `~/.zshrc`, or `~/.profile`:

```bash
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nvim
export PAGER=less
```

### Unset Variable

```bash
unset VAR
```

---

## File Descriptor & Redirection Tricks

```bash
# Discard output
command > /dev/null

# Discard both stdout and stderr
command > /dev/null 2>&1

# Read from a string (here string)
cat <<< "some text"

# Here document
cat << EOF
line 1
line 2
EOF

# Process substitution (bash/zsh)
diff <(ls dir1) <(ls dir2)
```

---

## SSH Productivity in Terminal

### Reuse Connections (Multiplexing)

Add to `~/.ssh/config`:

```
Host *
  ControlMaster auto
  ControlPath ~/.ssh/sockets/%r@%h:%p
  ControlPersist 600
```

Then `mkdir -p ~/.ssh/sockets`. Subsequent SSH connections to the same host reuse the existing socket.

### Jump Host

```
Host internal
  HostName 10.0.0.5
  User admin
  ProxyJump user@bastion.example.com
```

Then simply: `ssh internal`

### SSH Alias

```bash
alias prod='ssh -i ~/.ssh/prod_key user@prod.example.com'
```

---

## Useful One-Liners

```bash
# Find largest files in current dir
du -ah . | sort -rh | head -20

# Find files modified in last 24h
find . -mtime -1 -type f

# Count lines in all .py files
find . -name "*.py" | xargs wc -l | sort -n

# Monitor a log file
tail -f /var/log/syslog

# Watch disk usage change
watch -n 5 df -h

# Show listening ports
ss -tlnp

# Kill all processes by name
pkill -f process_name

# Extract any archive (requires atool or manual handling)
tar -xf file.tar.gz
unzip file.zip
7z x file.7z

# Recursive find and replace in files
find . -type f -name "*.txt" -exec sed -i 's/old/new/g' {} +

# Check what's using a port
lsof -i :8080
ss -tlnp | grep 8080

# Run previous command, replace word
^old^new

# Quickly create and enter a directory
mkdir -p project/src && cd $_

# Open last edited file in editor
$EDITOR $(ls -t | head -1)
```

---

## GNOME Terminal Settings via `gsettings`

GNOME Terminal stores settings in GSettings (dconf). You can script these.

```bash
# List all gnome-terminal schemas
gsettings list-schemas | grep gnome-terminal

# List profiles
dconf list /org/gnome/terminal/legacy/profiles:/

# Read a value (replace UUID with your profile UUID)
dconf read /org/gnome/terminal/legacy/profiles:/:UUID:/font

# Set font
dconf write /org/gnome/terminal/legacy/profiles:/:UUID:/font "'JetBrains Mono 12'"

# Enable custom font
dconf write /org/gnome/terminal/legacy/profiles:/:UUID:/use-system-font false
```

Get your profile UUID from:

```bash
dconf list /org/gnome/terminal/legacy/profiles:/
```

---

## Troubleshooting Common Issues

### Terminal Freezes on Ctrl + S

Cause: XON/XOFF flow control. Fix:

```bash
stty -ixon
```

Add to `~/.bashrc` to make permanent.

### Colors Not Showing Correctly

Ensure `TERM` is set correctly:

```bash
echo $TERM    # should be xterm-256color or similar
export TERM=xterm-256color
```

Add to `~/.bashrc` if needed.

### Backspace Not Working in Some Apps

```bash
stty erase ^?
```

Or set `TERM` correctly as above.

### Unicode / Emoji Not Displaying

Ensure a font with Unicode coverage is set in the profile. Noto fonts or a Nerd Font variant covers most Unicode ranges.

### Locale Issues (Garbled Characters)

```bash
locale          # check current locale
localectl list-locales | grep UTF
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

Set permanently in `/etc/locale.conf` on Arch.

---

## Opening GNOME Terminal from Keyboard / Launcher

On a standard GNOME session, you can bind a keyboard shortcut:

**Settings → Keyboard → View and Customize Shortcuts → Custom Shortcuts → +**

Command: `gnome-terminal` Shortcut: e.g., `Super + T`

---

## Accessibility Features

- **Increase font size temporarily**: `Ctrl + +` / `Ctrl + -` / `Ctrl + 0` (zoom, not persistent)
- **Bold text for readability**: Enable in profile under **Colors → Bold color**
- **High contrast**: Use a high-contrast profile palette; or use GNOME's built-in accessibility settings which propagate to the terminal
- **Screen reader**: GNOME Terminal works with Orca (`orca` package); start with `orca -r`

---

## Quick Reference Card

```
NEW TAB            Ctrl+Shift+T
CLOSE TAB          Ctrl+Shift+W
NEXT TAB           Ctrl+Page Down
PREV TAB           Ctrl+Page Up
NEW WINDOW         Ctrl+Shift+N
COPY               Ctrl+Shift+C
PASTE              Ctrl+Shift+V
SEARCH SCROLLBACK  Ctrl+Shift+F
ZOOM IN            Ctrl++
ZOOM OUT           Ctrl+-
ZOOM RESET         Ctrl+0
FULLSCREEN         F11

MOVE LINE START    Ctrl+A
MOVE LINE END      Ctrl+E
MOVE WORD LEFT     Alt+B
MOVE WORD RIGHT    Alt+F
DELETE TO END      Ctrl+K
DELETE TO START    Ctrl+U
DELETE WORD LEFT   Ctrl+W
PASTE CUT TEXT     Ctrl+Y
CLEAR SCREEN       Ctrl+L
SEARCH HISTORY     Ctrl+R
INTERRUPT          Ctrl+C
SUSPEND            Ctrl+Z
```