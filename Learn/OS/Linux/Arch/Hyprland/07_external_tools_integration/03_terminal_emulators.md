## Terminal Emulators


Terminal emulators provide text-based interfaces for shell commands, development, and system administration within Hyprland. Several Wayland-native options offer excellent integration, though X11-based alternatives work through XWayland.[1][2]

### Kitty (Recommended for Hyprland)

**Kitty** is the default terminal in Hyprland, GPU-accelerated with native Wayland support. Install on Arch Linux with `sudo pacman -S kitty`.[2][1]

Launch with keybind:[1]
```
bind = SUPER, RETURN, exec, kitty
```


Configure in `~/.config/kitty/kitty.conf`:[1]
```
font_family monospace
font_size 12
background #1e1e2e
foreground #cdd6f4
cursor #f5e0dc
selection_background #45475a
```


**font_family** - Monospace font (requires installation). **font_size** - Text size in pixels. **background/foreground** - Colors in hex format. **cursor** - Cursor color.[1]

### Alacritty (GPU-Accelerated)

**Alacritty** is a fast, GPU-accelerated terminal with excellent Wayland support. Install with `sudo pacman -S alacritty`.[1]

Launch with keybind:[1]
```
bind = SUPER, T, exec, alacritty
```


Configure in `~/.config/alacritty/alacritty.toml`:[1]
```toml
[window]
opacity = 0.9
padding = { x = 10, y = 10 }

[font]
normal = { family = "Monospace", style = "Regular" }
size = 12

[colors.primary]
background = "#1e1e2e"
foreground = "#cdd6f4"
```


### Foot (Lightweight)

**Foot** is a minimal, fast terminal designed for Wayland. Install with `sudo pacman -S foot`.[1]

Launch with keybind:[1]
```
bind = SUPER, T, exec, foot
```


Configure in `~/.config/foot/foot.ini`:[1]
```
[main]
font=monospace:size=12
pad=10x10

[colors]
background=1e1e2e
foreground=cdd6f4
```


### Wezterm (Feature-Rich)

**Wezterm** is a feature-rich terminal with Lua scripting and GPU rendering. Install with `sudo pacman -S wezterm`.[1]

Configure in `~/.config/wezterm/wezterm.lua`:[1]
```lua
local config = wezterm.config_builder()

config.font = wezterm.font("Monospace")
config.font_size = 12.0
config.color_scheme = "Catppuccin Mocha"

config.window_padding = {
  left = "10pt",
  right = "10pt",
  top = "10pt",
  bottom = "10pt",
}

return config
```


### Ghostty (Modern Alternative)

**Ghostty** is a modern terminal emulator with extensive customization. Install from AUR with `yay -S ghostty-bin`.[1]

Configure in `~/.config/ghostty/config`:[1]
```
font-family = monospace
font-size = 12
background = #1e1e2e
foreground = #cdd6f4
```


### Comparison of Terminals

| Terminal | Native Wayland | GPU Accelerated | Configuration | Speed | Hyprland Fit |
|---|---|---|---|---|---|
| Kitty | ✓ Yes | ✓ Yes | Simple | Excellent | ✓ Excellent |
| Alacritty | ✓ Yes | ✓ Yes | TOML | Excellent | ✓ Excellent |
| Foot | ✓ Yes | ✗ No | INI | Good | ✓ Good |
| Wezterm | ✓ Yes | ✓ Yes | Lua | Good | ~ Decent |
| Ghostty | ✓ Yes | ✓ Yes | Custom | Excellent | ✓ Excellent |
| GNOME Terminal | ~ XWayland | ✗ No | GUI | Adequate | ~ Works |
| Xterm | ✗ X11 only | ✗ No | Resources | Slow | ✗ Poor |

[2][1]

### Transparency and Opacity

Most terminals support transparency:[1]

**Kitty:**
```
background_opacity 0.9
```


**Alacritty:**
```toml
[window]
opacity = 0.9
```


**Foot:**
```
alpha=0.9
```


### Font Configuration

Install preferred monospace fonts:[1]
```bash
sudo pacman -S ttf-fira-code ttf-jetbrains-mono ttf-hack noto-fonts
```


Common choices: Fira Code, JetBrains Mono, Hack, Noto Mono.[1]

### Shell Integration

Configure Hyprland to use specific shells within terminals:[1]

**Use Zsh in Kitty:**
```
bind = SUPER, RETURN, exec, kitty -- zsh
```


**Use Fish in Alacritty:**
```
bind = SUPER, T, exec, alacritty -- fish
```


### Terminal Scrollback and History

Configure scrollback buffer for terminal history:[1]

**Kitty:**
```
scrollback_lines 2000
```


**Alacritty:**
```toml
[scrolling]
lines = 2000
```


### Color Schemes

Popular color schemes for terminals:[1]
- **Catppuccin** - Modern, pleasant pastel colors
- **Dracula** - Dark, saturated colors
- **Nord** - Arctic, bluish palette
- **Solarized** - Optimized contrast
- **Gruvbox** - Retro groove colors

Most terminals include theme support; download schemes from community repositories.[1]

### Example Comprehensive Terminal Configuration

Add to `hyprland.conf`:
```
# Primary terminal (Kitty)
bind = SUPER, RETURN, exec, kitty

# Alternative terminals
bind = SUPER+SHIFT, T, exec, alacritty
bind = SUPER+ALT, T, exec, foot

# Terminal with specific shell
bind = SUPER+CTRL, RETURN, exec, kitty -- fish
```


Create `~/.config/kitty/kitty.conf`:
```
font_family JetBrains Mono
font_size 12
background_opacity 0.95
enable_audio_bell no

# Colors (Catppuccin Mocha)
background #1e1e2e
foreground #cdd6f4
selection_background #45475a
cursor #f5e0dc

# Keyboard shortcuts
map ctrl+c copy_to_clipboard
map ctrl+v paste_from_clipboard
```


Kitty is recommended as the primary terminal for Hyprland due to native Wayland support, excellent performance, and tight compositor integration.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

