# Ghostty: A Comprehensive Guide

Ghostty is a fast, feature-rich, cross-platform terminal emulator that uses platform-native UI and GPU acceleration. It was created by Mitchell Hashimoto (co-founder of HashiCorp, creator of Terraform and Vagrant) and is written primarily in the Zig programming language. Its 1.0 release arrived in late 2024 and quickly drew significant attention in the developer community. The current stable release as of May 2026 is 1.3.1.

The core philosophy behind Ghostty is rejecting the trade-off that most terminal emulators force: speed, features, or a native UI — pick two. Ghostty attempts to provide all three simultaneously.

## What Makes Ghostty Different

Most terminal emulators in the same performance tier as Ghostty (Alacritty, for example) achieve speed by sacrificing features or native feel. Others with rich feature sets (like iTerm2) lag behind on raw performance. Ghostty's architecture is designed so that neither compromise is necessary.

A few distinguishing characteristics:

**Written in Zig.** Zig is a systems-level language without a garbage collector, giving Ghostty predictable memory behavior and low-level performance control. The Zig codebase allows fine-grained control over allocations and avoids hidden runtime overhead.

**Platform-native UI, not cross-platform chrome.** On macOS, Ghostty is built using Swift, AppKit, and SwiftUI. It uses real native macOS components: native tabs, native splits, native window management, and a native menu bar. On Linux, it uses GTK4. The result is that Ghostty does not feel like an Electron app or a cross-platform widget toolkit masquerading as a native application.

**GPU-accelerated rendering throughout.** Ghostty uses Metal on macOS and OpenGL on Linux. Crucially, it is (at time of writing) the only Metal-based terminal emulator that supports ligatures without falling back to CPU rendering for them.

**Zero configuration required to start.** Ghostty ships with an embedded default font (JetBrains Mono), built-in Nerd Font support, and sensible defaults, so it works immediately on installation with no config file needed.

**libghostty.** Ghostty also ships a cross-platform, zero-dependency C and Zig library called `libghostty` that allows anyone to embed a terminal into their own application.

## Architecture and Performance

Ghostty uses a multi-threaded architecture with a dedicated read thread, write thread, and render thread per terminal surface. Its read thread includes a heavily optimized terminal parser that uses CPU-specific SIMD instructions.

In benchmark comparisons, Ghostty and Alacritty are generally within a few percentage points of each other on various workloads, and both are dramatically faster than `Terminal.app` and iTerm2. In a practical demonstration using `htop` at a 10Hz refresh rate, `Terminal.app` itself consumed more CPU time displaying the htop output than htop used to run. In Ghostty, htop itself used more CPU — meaning the rendering overhead was negligible.

Real-world differences between fast terminals are small, and actual performance varies based on fonts, shaders, background opacity, and the workload being tested.

## Installation

### macOS

Ghostty provides a universal binary for macOS (runs natively on both x86-64 and Arm64). The recommended methods are:

```sh
# Homebrew
brew install ghostty

# Or download the .app directly from
# https://ghostty.org/download
```

On macOS, Ghostty supports auto-update as of version 1.3.0, including delta patching to keep update sizes small.

### Linux

On Linux, packages are available for major distributions. Some examples:

```sh
# Arch Linux (official repository)
pacman -S ghostty

# Fedora (COPR)
sudo dnf copr enable scottames/ghostty
sudo dnf install ghostty

# Ubuntu: unofficial user-maintained deb packages are available
# from the releases page: https://github.com/ghostty-org/ghostty/releases
```

Building from source is also supported:

```sh
# Install dependencies (Ubuntu/Debian example)
sudo apt install zig libgtk-3-dev libsoup-3.0-dev glib-2.0-dev

# Clone and build
git clone https://github.com/ghostty-org/ghostty
cd ghostty
zig build -p zig-out -Doptimize=ReleaseFast
```

## Configuration

### Zero-Configuration Philosophy

Ghostty is explicitly designed so that a configuration file is never required. The project actively works to eliminate any _necessary_ configuration — if you find yourself configuring something that you think should be a default, the official docs encourage opening a discussion on GitHub.

That said, extensive customization is available for users who want it.

### Config File Location

The configuration file is named `config.ghostty` (or `config` for versions before 1.2.3). It is looked up in the following locations:

- `$XDG_CONFIG_HOME/ghostty/config.ghostty` (defaults to `~/.config/ghostty/config.ghostty`)
- On macOS additionally: `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`

If both locations exist, they are both loaded, with later files taking precedence on conflicts. If no file is found, Ghostty uses its built-in defaults.

### Syntax

Ghostty uses a simple `key = value` format:

```ini
# Comments start with #, on their own line only
background = 282c34
foreground = ffffff

# Whitespace around = is optional
font-family = JetBrains Mono
font-size = 14

# Empty values reset a key to its default
font-family =
```

Keys are case-sensitive and always lowercase. Values can be quoted or unquoted — `font-family = "JetBrains Mono"` and `font-family = JetBrains Mono` are equivalent.

Every configuration key is also a valid CLI flag:

```sh
ghostty --background=282c34 --font-family="JetBrains Mono"
```

### Splitting Config Into Multiple Files

Use `config-file` to modularize your configuration:

```ini
config-file = some/relative/sub/config
config-file = ?optional/platform-specific/config   # ? = ignore if missing
config-file = /absolute/path/to/another/config
```

`config-file` entries are processed at the end of the current file. Relative paths are relative to the file containing the directive.

### Reloading Configuration

Press `Ctrl+Shift+,` on Linux or `Cmd+Shift+,` on macOS to reload the config at runtime without restarting. Some options only apply to newly created surfaces, and a few cannot be changed at runtime at all — check individual option documentation for details.

### Exploring Available Options

Three ways to browse all available options:

```sh
# Full default config with inline documentation (pipe to a pager)
ghostty +show-config --default --docs | less

# View man pages
man ghostty

# Online reference
# https://ghostty.org/docs/config/reference
```

## Windows, Tabs, and Splits

Ghostty supports multiple windows, each containing tabs, each tab containing splits. All are rendered using native UI components on both platforms.

### Windows

New windows can be opened via the menu or the `new_window` keybind action. On macOS, windows behave exactly like native macOS windows. On Linux (GTK4), window chrome matches the system theme.

### Tabs

Tabs on macOS use the native macOS tab bar — they look and behave like tabs in Safari or Finder, including drag-to-reorder. A tab overview is available that shows all open tabs by name (automatically named from the last command run) and is searchable.

### Splits

Splits allow multiple terminal surfaces within a single tab. You can create splits horizontally or vertically. This works similarly to Kitty's split system and provides a reasonable alternative to a multiplexer like tmux for many workflows.

Common split actions (as config `keybind` values):

|Action|Description|
|---|---|
|`new_split:right`|Create a new split to the right|
|`new_split:down`|Create a new split below|
|`new_split:auto`|Split along the larger dimension|
|`goto_split:left/right/top/bottom`|Focus a split by direction|
|`goto_split:previous` / `goto_split:next`|Focus by creation order|
|`toggle_split_zoom`|Temporarily maximize the focused split|

Unfocused splits can be given a dimmed opacity with:

```ini
unfocused-split-opacity = 0.7
unfocused-split-fill = 000000
```

### Tab Overview

The tab overview provides a visual, searchable grid of all open tabs including their automatically assigned names. It is available from the UI button on the tab bar or via a configurable keybind action (`open_tab_overview`).

## Default Keybindings

Ghostty ships with a comprehensive set of default keybindings. The tables below cover the most commonly used ones. All defaults can be overridden or unbound.

Run `ghostty +list-keybinds --default` to see the full current list.

### macOS Defaults

|Shortcut|Action|
|---|---|
|`Cmd+T`|New tab|
|`Cmd+W`|Close current tab or split|
|`Cmd+D`|New split (right)|
|`Cmd+Shift+D`|New split (down)|
|`Cmd+Shift+Enter`|Toggle split zoom|
|`Cmd+Up` / `Cmd+Down`|Jump to previous/next prompt (requires shell integration)|
|`Cmd+N`|New window|
|`Cmd+Enter`|Toggle fullscreen|
|`Cmd+,`|Open configuration file|
|`Cmd+Shift+,`|Reload configuration|
|`Cmd+C` / `Cmd+V`|Copy / Paste|
|`Cmd+F`|Scrollback search (added in 1.3.0)|
|`Cmd+K`|Clear screen|
|`Cmd+[` / `Cmd+]`|Previous / Next tab|

### Linux Defaults

On Linux, most `Cmd` shortcuts map to `Ctrl+Shift`. For example:

|Shortcut|Action|
|---|---|
|`Ctrl+Shift+T`|New tab|
|`Ctrl+Shift+W`|Close surface|
|`Ctrl+Shift+D`|New split|
|`Ctrl+Shift+F`|Scrollback search (1.3.0+)|
|`Ctrl+Shift+,`|Reload config|
|`Ctrl+Shift+C` / `Ctrl+Shift+V`|Copy / Paste|

## Custom Keybindings

### Basic Syntax

```ini
keybind = trigger=action
keybind = ctrl+shift+r=reload_config
keybind = cmd+d=new_split:right
```

### Modifiers

Valid modifier keys: `shift`, `ctrl` (alias: `control`), `alt` (aliases: `opt`, `option`), `super` (aliases: `cmd`, `command`).

The `fn` / "globe" key is not supported as a modifier due to OS/toolkit limitations.

### Key Sequences (Trigger Sequences)

Ghostty supports multi-key sequences using `>` as a separator, similar to Vim leader keys or Emacs bindings:

```ini
# Press Ctrl+A then N to open a new window
keybind = ctrl+a>n=new_window

# Emacs-style splits
keybind = ctrl+x>2=new_split:right
keybind = ctrl+x>3=new_split:down
```

As of Ghostty 1.3.0, keybind chains are also available.

### Trigger Prefixes

Prefixes modify keybind behavior and are written before the trigger:

- `all:` — applies the action to all terminal surfaces, not just the focused one
- `global:` — makes the keybind system-wide, active even when Ghostty is not focused (macOS only; requires Accessibility permissions)
- `unconsumed:` — triggers the action but still passes the keypress through to the running program
- `performable:` — only consumes the input if the action can currently be performed

Example using `performable` for context-sensitive copy:

```ini
# Copies if text is selected; otherwise sends Ctrl+C (interrupt)
keybind = performable:ctrl+c=copy_to_clipboard
```

Example of a global Quick Terminal toggle:

```ini
keybind = global:cmd+grave_accent=toggle_quick_terminal
```

### Key Tables (Modal Input)

Named key tables allow modal keybinding (like Vim or tmux prefix modes). Defined with `<table>/<binding>` syntax and activated via the `push_key_table` action:

```ini
my_mode/ctrl+h=goto_split:left
my_mode/ctrl+l=goto_split:right
keybind = ctrl+a=push_key_table:my_mode
```

### Unbinding

To remove a default binding and pass the key through to the terminal:

```ini
keybind = cmd+t=unbind
```

To silently swallow a key (no action, no passthrough):

```ini
keybind = ctrl+q=ignore
```

## Themes

### Built-in Themes

Ghostty ships with hundreds of built-in themes sourced from the iterm2-color-schemes project, updated weekly. To apply one:

```ini
theme = Catppuccin Frappe
```

List all available themes:

```sh
ghostty +list-themes
```

### Separate Light and Dark Themes

Ghostty can automatically switch between a light and dark theme based on system appearance:

```ini
theme = dark:Catppuccin Frappe,light:Catppuccin Latte
```

### Custom Themes

Theme files are standard Ghostty config files that set color options. The key options are `background`, `foreground`, `cursor-color`, `selection-foreground`, `selection-background`, and the 16-color `palette` entries (indexed 0–15).

Place custom themes in `$XDG_CONFIG_HOME/ghostty/themes/` and reference by filename:

```ini
theme = my-custom-theme
```

Or reference by absolute path:

```ini
theme = /path/to/my-theme
```

Example theme file:

```ini
background = #303446
foreground = #c6d0f5
cursor-color = #f2d5cf
selection-background = #626880
selection-foreground = #c6d0f5
palette = 0=#51576d
palette = 1=#e78284
palette = 2=#a6d189
# ... continue for palette indices 3–15
```

Note: Themes are loaded _before_ user config, so any conflicting options in your main config file take precedence over the theme.

## Fonts

Ghostty has its own font rendering code. It correctly handles ligatures, complex scripts, multi-codepoint emoji, right-to-left text (Arabic, Hebrew), and Nerd Font glyphs — all without falling back to CPU rendering.

### Font Configuration

```ini
font-family = JetBrains Mono
font-size = 14
font-style = Regular        # Regular, Bold, Italic, Bold Italic
font-style-bold = Bold
font-style-italic = Italic
font-style-bold-italic = Bold Italic
```

Ghostty also supports enabling or disabling specific OpenType font features:

```ini
font-feature = +liga       # Enable ligatures
font-feature = -calt       # Disable contextual alternates
```

### Nerd Fonts

Ghostty has built-in Nerd Font support, meaning glyph icons from tools like Starship, lsd, or exa render correctly without any manual font patching. You can still install and configure a Nerd Font variant if you prefer a specific one.

## Shell Integration

Ghostty provides automatic shell integration for bash, elvish, fish, nushell, and zsh. No manual setup is required for these shells in typical installations.

### What Shell Integration Enables

- Cursor changes to a bar shape when at a prompt, block otherwise
- New terminals open in the working directory of the previously focused terminal
- Complex multi-line prompts resize correctly on window resize (prompt is redrawn rather than reflowed)
- `Ctrl+triple-click` (Linux) or `Cmd+triple-click` (macOS) selects the output of the last command
- `jump_to_prompt` keybind scrolls forward and backward through shell prompts in scrollback
- `Alt+click` / `Option+click` moves the cursor to the click location when at a prompt
- Close confirmation is skipped for terminals where the shell is idle at a prompt

### How It Works

Ghostty detects your shell from the basename of the command it launches and automatically injects integration code. To force a specific shell (e.g. if yours has a non-standard name):

```ini
shell-integration = fish
```

To disable shell integration entirely:

```ini
shell-integration = none
```

To verify shell integration is active, look for this in the Ghostty log output:

```
info(io_exec): shell integration automatically injected shell=termio.shell_integration.Shell.zsh
```

### Manual Integration

If automatic injection doesn't work (e.g. macOS system bash, or when switching shells inside Ghostty), source the integration script manually. Add this at the top of `~/.bashrc` for bash:

```bash
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi
```

Shell integration files are located under `$GHOSTTY_RESOURCES_DIR/shell-integration/<shell>/`.

### SSH Integration

Ghostty uses `xterm-ghostty` as its `$TERM` value. Many remote hosts do not yet have this terminfo entry, which can cause rendering issues over SSH.

Two shell integration features address this, both disabled by default:

```ini
shell-integration-features = ssh-env,ssh-terminfo
```

- `ssh-env` — sets `TERM=xterm-256color` for remote sessions and forwards `COLORTERM`, `TERM_PROGRAM`, and `TERM_PROGRAM_VERSION` via `SendEnv`
- `ssh-terminfo` — attempts to install Ghostty's terminfo entry on the remote host on first connection using `infocmp` locally and `tic` remotely; caches successful installs

Both features work by wrapping the `ssh` shell command with a function. This means they apply to interactive `ssh` calls only — not to SSH invocations made by scripts, `Makefile` recipes, tools like `mosh` or `rsync -e ssh`, or `git` over SSH.

For broader coverage, configure `~/.ssh/config` directly:

```ssh-config
Host example.com
  SetEnv TERM=xterm-256color
  SendEnv COLORTERM TERM_PROGRAM TERM_PROGRAM_VERSION
```

A workaround requiring no shell integration for SSH is to set the `TERM` in your config for all sessions:

```ini
# In Ghostty config — overrides TERM for all sessions including SSH
term = xterm-256color
```

## Scrollback and Search

Ghostty maintains a configurable scrollback buffer. The default size is set with:

```ini
scrollback-limit = 10000   # Number of lines
```

### Scrollback Search

Added in version 1.3.0: scrollback search lets you search terminal history with all matches highlighted and arrow-key navigation. Trigger it with `Cmd+F` on macOS or `Ctrl+Shift+F` on Linux. On macOS, the search bar can be dragged to any corner of the window.

### Scrolling Keybinds

You can assign scroll actions to keybinds:

```ini
keybind = alt+up=scroll_page_lines:-2
keybind = alt+down=scroll_page_lines:2
```

## Quick Terminal

The Quick Terminal (sometimes called the dropdown terminal) is a Ghostty-specific feature that provides a terminal overlay that slides in from the top of the screen — similar to Guake on Linux or iTerm2's hotkey window. It appears on demand over whatever application is currently in focus.

To set it up with a global keybind:

```ini
keybind = global:cmd+grave_accent=toggle_quick_terminal
```

On macOS, enabling `global:` keybinds requires granting Ghostty Accessibility permissions under System Settings > Privacy & Security > Accessibility.

The Quick Terminal's appearance, size, and animation can be configured with options such as:

```ini
quick-terminal-position = top          # top, bottom, left, right, center
quick-terminal-screen = main           # main, mouse, macos-menu-bar
quick-terminal-animation-duration = 0.2
```

## Image Protocol Support

Ghostty implements the Kitty Graphics Protocol (also called the Kitty Image Protocol), allowing terminal applications to render images inline in the terminal. This is useful for tools that preview images, display plots, or show visual output directly in the terminal.

No configuration is required to enable this — it is supported by default.

## Terminal Inspector and Debugging

Ghostty includes a built-in Terminal Inspector, accessible from the menu or via a keybind, that shows real-time debug information including keypress events, render timings, and active control sequences. This is useful for diagnosing keybinding issues, inspecting what a program is sending to the terminal, or understanding rendering behavior.

To enable debug logging more broadly, launch Ghostty with:

```sh
GHOSTTY_LOG=debug ghostty
```

## macOS-Specific Features

Because Ghostty uses native macOS frameworks, it supports several features specific to macOS:

- **AppleScript automation** — Ghostty has a built-in AppleScript dictionary for scripting windows, tabs, terminals, layouts, and input events. As of version 1.3.0, this was significantly expanded. Example use: automatically opening a multi-pane layout when starting your workday.
- **Proxy Icon** — the title bar includes a proxy icon representing the current working directory. You can drag it to Finder, other apps, or the Dock.
- **Quick Look** — three-finger tap or force touch on text to invoke macOS Quick Look for definitions, web searches, and more.
- **Secure Keyboard Entry** — Ghostty automatically detects password prompts, or you can manually enable secure keyboard entry. An animated lock icon in the top-right corner indicates when it is active.
- **Non-native fullscreen** — faster fullscreen that skips macOS animation:
    
    ```ini
    fullscreen = non-native
    ```
    
- **Auto-update** — available from 1.3.0, Ghostty can update itself without Homebrew or manual download, using delta patches.

## Linux-Specific Notes

Ghostty on Linux is built with GTK4 and integrates with the GNOME desktop environment. It uses standard GTK window chrome including titlebars and close buttons.

On some Linux setups (notably certain tiling window managers or minimal desktop environments), window decorations such as close buttons or menu bars may be absent or behave differently. This is a known area of variation depending on the desktop environment.

For Arch Linux users, Ghostty is in the official repositories:

```sh
pacman -S ghostty
```

For NixOS users, Ghostty is available in nixpkgs and can be managed declaratively.

## Useful Configuration Examples

### Common Aesthetic Settings

```ini
background-opacity = 0.95
background-blur-radius = 20
font-family = Zed Mono
font-size = 13
theme = dark:Tokyo Night,light:GitHub Light
window-padding-x = 8
window-padding-y = 8
mouse-hide-while-typing = true
```

### tmux Integration

```ini
# Send tmux save-buffer (Ctrl+A then S)
keybind = cmd+s=text:\x01\x73

# Toggle zoom on current tmux pane (Ctrl+A then Z)
keybind = cmd+b=text:\x01\x7a
```

### Vim-style Split Navigation

```ini
keybind = ctrl+h=goto_split:left
keybind = ctrl+l=goto_split:right
keybind = ctrl+k=goto_split:top
keybind = ctrl+j=goto_split:bottom
```

### Emacs-style Split Creation

```ini
keybind = ctrl+x>2=new_split:right
keybind = ctrl+x>3=new_split:down
```

### SSH Compatibility

```ini
# Use this if remote hosts don't have xterm-ghostty terminfo
shell-integration-features = ssh-env,ssh-terminfo
```

Or, to override `TERM` globally for all sessions (simpler but less precise):

```ini
term = xterm-256color
```

## Version History Highlights

|Version|Notable Changes|
|---|---|
|1.0|Initial public stable release; macOS and Linux support|
|1.1|Performable keybinds|
|1.2|Config file renamed to `config.ghostty`; config-file splitting improvements|
|1.3.0|Scrollback search, AppleScript expansion, auto-update on macOS, keybind chains, SSH integration improvements, security fix CVE-2026-26982|
|1.3.1|Patch release; security fix applied|

## Further Resources

- Official documentation: `https://ghostty.org/docs`
- Configuration option reference: `https://ghostty.org/docs/config/reference`
- Keybind action reference: `https://ghostty.org/docs/config/keybind/reference`
- Theme list (iterm2-color-schemes): `https://iterm2colorschemes.com`
- GitHub repository: `https://github.com/ghostty-org/ghostty`
- Community Discord: listed at `https://ghostty.org/docs`
- Offline config docs: `ghostty +show-config --default --docs | less`
- List all keybinds: `ghostty +list-keybinds --default`
- List all themes: `ghostty +list-themes`