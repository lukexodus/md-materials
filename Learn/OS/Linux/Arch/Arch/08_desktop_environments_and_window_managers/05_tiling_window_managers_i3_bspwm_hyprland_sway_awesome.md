## Tiling Window Managers (i3, bspwm, Hyprland, Sway, Awesome)


### Tiling Window Manager Overview

**Concept**: Automatically arrange windows in non-overlapping layouts.[1][2]

**Contrast to Stacking**: Traditional window managers stack overlapping windows.[2]

**Keyboard-Driven**: Primarily controlled via keyboard shortcuts.[2]

**Philosophy**: Maximize screen real estate and minimize mouse usage.[2]

**Learning Curve**: Steeper than traditional desktop environments.[2]

### i3 Window Manager

**Language**: C.[2]

**Type**: X11-only tiling window manager.[2]

**Installation**: `sudo pacman -S i3-wm i3status i3lock`.[1][2]

#### Features[2]

**Dynamic Tiling**:[2]
- Automatic window arrangement[2]
- Multiple layout modes[2]
- Container-based organization[2]

**Keyboard-First**:[2]
- All operations via keyboard[2]
- Customizable shortcuts[2]
- Minimal mouse dependency[2]

**Configuration**:[2]
- Plain text config file[2]
- Simple, readable syntax[2]
- Easy to understand[2]

#### Configuration

**Config Location**: `~/.config/i3/config`.[1][2]

**Basic Layout**:[1]

```
# Define modkey
set $mod Mod1  # Alt key

# Window borders
new_window pixel 2

# Workspaces
workspace 1 output HDMI-1
workspace 2 output HDMI-2

# Keybindings
bindsym $mod+Return exec i3-sensible-terminal
bindsym $mod+d exec dmenu_run
bindsym $mod+Shift+e exit
```

**Status Bar**: i3status displays system information.[2]

**Lock Screen**: i3lock prevents unauthorized access.[2]

#### Target Users

**Power Users**: Keyboard efficiency.[2]

**Developers**: Minimalist focus.[2]

**Linux Enthusiasts**.[2]

### bspwm (Binary Space Partitioning Window Manager)

**Language**: C.[2]

**Type**: X11 tiling window manager.[2]

**Installation**: `sudo pacman -S bspwm sxhkd`.[2]

**Separation**: Window manager and hotkey daemon separate.[2]

#### Features[2]

**Binary Space Partitioning**:[2]
- Recursive partitioning layout[2]
- Intuitive spatial organization[2]
- Flexible window arrangement[2]

**Responsive**:[2]
- Event-driven operation[2]
- Client-server architecture[2]
- External control via bspc[2]

**Scriptable**:[2]
- System messages sent to external handler[2]
- Powerful automation potential[2]

#### Configuration

**Main Config**: `~/.config/bspwm/bspwmrc`:[2]

```bash
#!/bin/bash
bspc config border_width 2
bspc config window_gap 12
bspc monitor -d 1 2 3 4 5 6 7 8 9 10
bspc config split_ratio 0.52
```

**Hotkeys**: `~/.config/sxhkd/sxhkdrc`:[2]

```
super + Return
    alacritty

super + d
    rofi -show run

super + shift + e
    bspc quit
```

#### Target Users

**Minimalists**: Core functionality.[2]

**Scripters**: Programmable.[2]

**Advanced Users**.[2]

### Sway Window Manager

**Language**: C.[2]

**Type**: Wayland tiling window manager.[2]

**Installation**: `sudo pacman -S sway`.[2]

**Replaces i3**: Drop-in replacement for Wayland.[2]

#### Features[2]

**Wayland Native**:[2]
- Modern display protocol[2]
- Better security model[2]
- Future-proof[2]

**i3 Compatible**:[2]
- Similar configuration[2]
- Familiar keybindings[2]
- Easier migration from i3[2]

**Tiling**:[2]
- Automatic window arrangement[2]
- Keyboard-driven[2]

#### Configuration

**Config Location**: `~/.config/sway/config`.[2]

**Similar to i3**:[2]

```
set $mod Mod1

output HDMI-1 resolution 1920x1080 position 0,0

workspace 1 output HDMI-1
workspace 2 output HDMI-2

bindsym $mod+Return exec alacritty
bindsym $mod+d exec wofi
```

**Status Bar**: Waybar (Wayland equivalent).[2]

#### Target Users

**Wayland Users**: Modern display server.[2]

**i3 Migrators**: Familiar interface.[2]

**Seeking Modern Solution**.[2]

### Hyprland

**Language**: C++.[2]

**Type**: Wayland window manager.[2]

**Installation**: `sudo pacman -S hyprland`.[2]

**Modern Alternative**: Feature-rich Wayland WM.[2]

#### Features[2]

**Animated**:[2]
- Smooth window animations[2]
- Visual effects[2]
- Modern aesthetics[2]

**High Performance**:[2]
- GPU-accelerated rendering[2]
- Optimized for modern systems[2]

**Advanced Configuration**:[2]
- Complex customization[2]
- Extensive options[2]
- Powerful scripting[2]

#### Configuration

**Config Location**: `~/.config/hypr/hyprland.conf`.[2]

**Hyprland Syntax**:[2]

```
monitor=HDMI-1,1920x1080@60,0x0,1
monitor=HDMI-2,1920x1080@60,1920x0,1

$mod = SUPER

bind = $mod, RETURN, exec, alacritty
bind = $mod, D, exec, rofi -show drun
bind = $mod SHIFT, E, exit
```

**Gap and Border Configuration**:[2]

```
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
}
```

#### Target Users

**Modern Systems**: Cutting-edge features.[2]

**Wayland Enthusiasts**: Native Wayland.[2]

**Visual Customization**.[2]

### Awesome Window Manager

**Language**: Lua.[2]

**Type**: X11 dynamic window manager.[2]

**Installation**: `sudo pacman -S awesome`.[2]

**Philosophy**: Highly customizable through scripting.[2]

#### Features[2]

**Lua Scripting**:[2]
- Entire configuration in Lua[2]
- Powerful customization[2]
- Dynamic behavior[2]

**Dynamic Tiling**:[2]
- Multiple layout modes[2]
- Automatic arrangement[2]

**Built-in Utilities**:[2]
- Status bar (wibox)[2]
- Widget framework[2]

#### Configuration

**Config Location**: `~/.config/awesome/rc.lua`.[2]

**Lua Configuration**:[2]

```lua
-- Define modkey
local modkey = "Mod1"

-- Create wibox (status bar)
screen.connect_signal("request::desktop_decoration", function(s)
    -- Create widgets
end)

-- Keybindings
awful.key({ modkey }, "Return", function() awful.spawn("alacritty") end)
awful.key({ modkey }, "d", function() awful.spawn("rofi -show run") end)
```

**Widget Creation**: Built-in widget framework.[2]

#### Target Users

**Programmers**: Lua scripting.[2]

**Advanced Customization**: Powerful configuration.[2]

**Willing to Code**.[2]

### Comparison Table

| WM | Protocol | Language | Config | Complexity | Features | Keyboard |
|----|----------|----------|--------|-----------|----------|----------|
| **i3** | X11 [2] | C [2] | Text [2] | Low [2] | Basic [2] | Yes [2] |
| **bspwm** | X11 [2] | C [2] | Script [2] | Medium [2] | Advanced [2] | Yes [2] |
| **Sway** | Wayland [2] | C [2] | Text [2] | Low [2] | Moderate [2] | Yes [2] |
| **Hyprland** | Wayland [2] | C++ [2] | Text [2] | Medium [2] | High [2] | Yes [2] |
| **Awesome** | X11 [2] | Lua [2] | Lua [2] | High [2] | Extensive [2] | Yes [2] |

### Installation and Setup

#### Basic Installation

**i3 Setup**:[1][2]

```bash
sudo pacman -S i3-wm i3status i3lock dmenu
```

**Start X Session**: Add to `~/.xinitrc`:[1]

```bash
exec i3
```

**Launch**: `startx` from TTY.[1]

#### First Run Configuration

**Auto-Generate**: i3 creates default config on first run.[2]

**Location**: `~/.config/i3/config`.[2]

**Modify Defaults**: Edit for personal preferences.[2]

#### Display Manager Integration

**Session Available**: Many display managers recognize WM.[2]

**Session Selection**: Choose at login.[2]

**Manual Alternative**: Start from TTY with `startx`.[1]

### Configuration Best Practices

**Start Minimal**: Begin with default config.[2]

**Incremental Changes**: Add one customization at a time.[2]

**Documentation**: Comment all changes.[1][2]

**Testing**: Reload config frequently.[2]

**Backup Original**: Keep default configuration.[1]

### Accessories and Tools

#### Launchers

**dmenu**: Minimal launcher for X11.[2]

**rofi**: Feature-rich launcher.[2]

**wofi**: Wayland alternative.[2]

#### Status Bars

**i3status**: Lightweight X11.[2]

**polybar**: Feature-rich.[2]

**waybar**: Wayland-native.[2]

#### Terminal Emulators

**alacritty**: GPU-accelerated.[2]

**kitty**: Feature-rich.[2]

**urxvt**: Lightweight.[2]

### Workflow Advantages

**Speed**: Keyboard-driven efficiency.[2]

**Screen Space**: No wasted window frame space.[2]

**Organization**: Workspaces for task separation.[2]

**Focus**: Minimalist distractions.[2]

### Learning Path

**Start with i3**: Most accessible.[2]

**Move to Sway**: When ready for Wayland.[2]

**Advanced**: bspwm or Awesome for deep customization.[2]

### Best Practices

**Learn Keybindings**: Master keyboard shortcuts.[2]

**Invest Time**: Payoff increases with practice.[2]

**Community Resources**: Consult wikis and forums.[2]

**Experiment**: Try different configurations.[2]

**Documentation**: Document your setup.[2]

### Not for Everyone

**GUI Preference**: Tiling WMs heavily keyboard-focused.[2]

**Learning Curve**: Steeper than desktop environments.[2]

**Niche Community**: Smaller user base than GNOME/KDE.[2]

**Support**: Fewer built-in utilities.[2]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

