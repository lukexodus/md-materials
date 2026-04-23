# Alacritty Productivity Guide (Arch / Omarchy)

---

## Table of Contents

- [Config File Location](https://claude.ai/chat/903ac7d6-ad90-4b43-b465-4f9a68514350#config-file-location)
- [Font Configuration](https://claude.ai/chat/903ac7d6-ad90-4b43-b465-4f9a68514350#font-configuration)
- [Window Settings](https://claude.ai/chat/903ac7d6-ad90-4b43-b465-4f9a68514350#window-settings)
- [Scrollback Buffer](https://claude.ai/chat/903ac7d6-ad90-4b43-b465-4f9a68514350#scrollback-buffer)
- [Environment & Shell](https://claude.ai/chat/903ac7d6-ad90-4b43-b465-4f9a68514350#environment--shell)
- [Default Keybinds](https://claude.ai/chat/903ac7d6-ad90-4b43-b465-4f9a68514350#default-keybinds)
- [Custom Keybindings](https://claude.ai/chat/903ac7d6-ad90-4b43-b465-4f9a68514350#custom-keybindings)
- [Vi Mode](https://claude.ai/chat/903ac7d6-ad90-4b43-b465-4f9a68514350#vi-mode)
- [URL Hints](https://claude.ai/chat/903ac7d6-ad90-4b43-b465-4f9a68514350#url-hints)
- [Omarchy-Specific Setup](https://claude.ai/chat/903ac7d6-ad90-4b43-b465-4f9a68514350#omarchy-specific-setup)
- [SSH & Remote Connections](https://claude.ai/chat/903ac7d6-ad90-4b43-b465-4f9a68514350#ssh--remote-connections)
- [Live Reload & IPC](https://claude.ai/chat/903ac7d6-ad90-4b43-b465-4f9a68514350#live-reload--ipc)
- [Limitations](https://claude.ai/chat/903ac7d6-ad90-4b43-b465-4f9a68514350#limitations)

---

## Config File Location

Alacritty searches these paths in order on UNIX/Wayland:

```
$ALACRITTY_CONFIG
$XDG_CONFIG_HOME/alacritty/alacritty.toml
$XDG_CONFIG_HOME/alacritty.toml
~/.config/alacritty/alacritty.toml   ← usual Omarchy location
~/.alacritty.toml
```

> **Omarchy note:** The default config at `~/.config/alacritty/alacritty.toml` imports the active theme from `~/.config/omarchy/current/theme/alacritty.toml`. That file is auto-generated — do not edit it directly. Put your personal overrides in the main config file after the import line.

---

## Font Configuration

```toml
# ~/.config/alacritty/alacritty.toml

[font]
normal  = { family = "CaskaydiaMono Nerd Font", style = "Regular" }
bold    = { family = "CaskaydiaMono Nerd Font", style = "Bold" }
italic  = { family = "CaskaydiaMono Nerd Font", style = "Italic" }
size    = 12.0   # Omarchy default is 9

# Optional: control spacing
[font.offset]
x = 0
y = 0

[font.glyph_offset]
x = 0
y = 0
```

> Changes to font take effect immediately when `live_config_reload` is enabled (default: true).

---

## Window Settings

```toml
[window]
padding         = { x = 14, y = 14 }   # Omarchy default
decorations     = "None"                # borderless on Wayland
opacity         = 0.98                  # slight transparency
blur            = false                 # background blur (compositor-dependent)
dynamic_padding = false

# Start maximized or fullscreen:
startup_mode = "Windowed"  # or "Maximized" | "Fullscreen"

# Optional: fixed dimensions on open
dimensions = { columns = 220, lines = 50 }
```

> **Wayland / Hyprland:** `decorations = "None"` removes title bars. Window positioning is then handled by Hyprland window rules instead.

---

## Scrollback Buffer

```toml
[scrolling]
history    = 10000  # lines; max 100000; 0 = disabled
multiplier = 3      # lines per scroll tick
```

If you use tmux, consider disabling Alacritty's scrollback entirely (`history = 0`) and relying on tmux's scrollback instead to avoid duplication.

---

## Environment & Shell

```toml
[env]
TERM = "xterm-256color"  # Omarchy default; avoids terminfo issues on remote hosts

# Change the shell Alacritty launches (preferred over chsh on Omarchy)
[terminal.shell]
program = "/usr/bin/fish"
args    = ["-l"]
```

> **Why not `chsh`?** Hyprland boots from bash and changing the login shell can break startup scripts. Using `[terminal.shell]` in Alacritty config is safer.

---

## Default Keybinds (Wayland / Hyprland)

|Action|Keybind|
|---|---|
|Copy|`Ctrl+Shift+C`|
|Paste|`Ctrl+Shift+V`|
|Toggle Vi mode|`Ctrl+Shift+Space`|
|Search forward|`Ctrl+Shift+F`|
|Open URL hint|`Ctrl+Shift+O`|
|New instance|`Ctrl+Shift+N`|
|Increase font size|`Ctrl++`|
|Decrease font size|`Ctrl+-`|
|Reset font size|`Ctrl+0`|
|Scroll up one page|`Shift+PageUp`|
|Scroll down one page|`Shift+PageDown`|
|Scroll to top|`Shift+Home`|
|Scroll to bottom|`Shift+End`|
|Toggle fullscreen|`F11` (set by Omarchy default config)|

---

## Custom Keybindings

```toml
[keyboard]
bindings = [
  # Spawn new instance in same working directory
  { key = "Return", mods = "Control|Shift", action = "SpawnNewInstance" },

  # Toggle fullscreen
  { key = "F11", action = "ToggleFullscreen" },

  # Vi mode shortcut
  { key = "Space", mods = "Control|Shift", action = "ToggleViMode" },

  # Run a shell command on keypress
  { key = "T", mods = "Control|Shift",
    command = { program = "bash", args = ["-c", "notify-send hello"] } },
]
```

Available modifiers: `None`, `Shift`, `Control`, `Alt`, `Super`, `Command`. Combine with `|`.

Common actions: `SpawnNewInstance`, `CreateNewWindow`, `ToggleFullscreen`, `ToggleMaximized`, `ToggleViMode`, `SearchForward`, `Copy`, `Paste`, `Quit`, `IncreaseFontSize`, `DecreaseFontSize`, `ResetFontSize`, `ScrollPageUp`, `ScrollPageDown`, `ScrollToTop`, `ScrollToBottom`.

---

## Vi Mode

Vi mode lets you navigate the scrollback buffer and select text using keyboard motions, similar to Vim.

Toggle with `Ctrl+Shift+Space`.

### Navigation

|Action|Key|
|---|---|
|Move left / down / up / right|`h` `j` `k` `l`|
|Word forward|`w`|
|Word backward|`b`|
|Start of line|`0`|
|End of line|`$`|
|Top of screen|`H`|
|Middle of screen|`M`|
|Bottom of screen|`L`|
|Page up|`Ctrl+B`|
|Page down|`Ctrl+F`|
|Go to top of scrollback|`gg`|
|Go to bottom|`G`|

### Selection & Search

|Action|Key|
|---|---|
|Start character selection|`v`|
|Start line selection|`V`|
|Start block selection|`Ctrl+V`|
|Copy selection|`y`|
|Search forward|`/`|
|Search backward|`?`|
|Next match|`n`|
|Previous match|`N`|
|Open URL at cursor|`Enter`|

> Vi mode search operates on the visible viewport. For full scrollback search, use `Ctrl+Shift+F` (works outside Vi mode).

---

## URL Hints

Press `Ctrl+Shift+O` to activate hint mode — all visible URLs are labeled, type the label to open. Customize the program:

```toml
[hints]
[[hints.enabled]]
command    = { program = "firefox" }
binding    = { key = "O", mods = "Control|Shift" }
hyperlinks = true
regex      = "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\u0000-\u001F\u007F-\u009F<>\"\\s{-}\\^⟨⟩`]+"
```

---

## Omarchy-Specific Setup

### How Omarchy manages Alacritty config

The Omarchy default config imports the active theme:

```toml
# ~/.config/alacritty/alacritty.toml (Omarchy default, abridged)

general.import = [
  "~/.config/omarchy/current/theme/alacritty.toml"
]

[env]
TERM = "xterm-256color"

[font]
normal = { family = "CaskaydiaMono Nerd Font", style = "Regular" }
bold   = { family = "CaskaydiaMono Nerd Font", style = "Bold" }
italic = { family = "CaskaydiaMono Nerd Font", style = "Italic" }
size   = 9

[window]
padding     = { x = 14, y = 14 }
decorations = "None"
opacity     = 0.98

[keyboard]
bindings = [
  { key = "F11", action = "ToggleFullscreen" }
]
```

### Theme system (Aether)

Omarchy's Aether app manages colors system-wide. The file that drives everything is:

```
~/.config/omarchy/themes/<your-theme>/colors.toml
```

Editing it regenerates Alacritty's theme file alongside btop, Chromium, Hyprland, Waybar, and more. You can also browse and apply community themes via the app launcher (`Super+Space` → search "Aether").

> For a light mode variant, add an empty file named `light.mode` in the theme root directory.

### Launch shortcut

On Omarchy, `Super+Enter` opens Alacritty. This is a Hyprland binding, not an Alacritty setting. To override:

```
# ~/.config/hypr/bindings.conf
bind = SUPER, Return, exec, alacritty
```

### Clipboard in Omarchy

|Action|Keybind|
|---|---|
|Copy|`Super+C`|
|Paste|`Super+V`|
|Clipboard history|`Super+Ctrl+V`|

Inside Alacritty, the terminal-specific shortcuts also still work: `Ctrl+Shift+C` / `Ctrl+Shift+V`.

---

## SSH & Remote Connections

Remote hosts may not have Alacritty's terminfo entry, which causes broken terminal behavior. Fix it by copying terminfo to the remote:

```bash
# On your local machine
infocmp > alacritty.terminfo
scp alacritty.terminfo user@remote:~/

# On the remote host
tic -x alacritty.terminfo
rm alacritty.terminfo
```

Alternatively, install `ncurses` on the remote:

```bash
# Arch
pacman -S ncurses

# Debian / Ubuntu
apt install ncurses-term
```

> The simplest workaround is to keep `TERM = "xterm-256color"` in your `[env]` block (the Omarchy default). Nearly every server already has this terminfo entry.

---

## Live Reload & IPC

```toml
[general]
live_config_reload = true   # default: true
ipc_socket         = true   # enables alacritty msg
```

With `ipc_socket` enabled, control running instances from the command line:

```bash
# Change config at runtime without restarting
alacritty msg config 'window.opacity=0.9'

# Open a new window from another process
alacritty msg create-window
```

### Migrating old YAML config

```bash
alacritty migrate
```

> Comments are dropped during migration — copy them manually if needed.

---

## Limitations

Alacritty intentionally omits several features by design:

|Feature|Alternative|
|---|---|
|Native tabs|tmux, zellij|
|Native splits|tmux, zellij|
|Image rendering|Kitty, Ghostty|
|Font ligatures|Ghostty|
|Built-in search UI|Vi mode (`/`) or `Ctrl+Shift+F`|

Omarchy fully supports Ghostty and Kitty as drop-in alternatives. Set your default terminal via `Omarchy Menu > Setup > Defaults`, or by editing the UWSM defaults file.

---

_[Inference] Behavior of config options is based on Alacritty's documented TOML spec and known Omarchy defaults as of early 2025. Some defaults may differ depending on your installed Omarchy version. Always verify with `alacritty --help` or the [Alacritty GitHub wiki](https://github.com/alacritty/alacritty/wiki)._