## Customizing and Scripting Window Managers


### Window Manager Customization Overview

**Configuration Files**: Text or script files controlling WM behavior.[1][2]

**Reload Mechanism**: Most WMs reload config without restart.[2]

**Scripting Capability**: Advanced users can automate workflows.[2]

**Documentation**: Each WM maintains specific configuration syntax.[2]

### i3 Window Manager Customization

#### Configuration File Structure

**Location**: `~/.config/i3/config`.[1][2]

**Format**: Simple key-value syntax.[2]

**Comments**: Lines starting with `#`.[2]

#### Basic Configuration Sections

**Variables**:[2]

```
set $mod Mod1                # Alt key
set $term i3-sensible-terminal
set $menu dmenu_run
```

**Font Settings**:[1]

```
font pango:monospace 10
```

**Gaps and Borders**:[1]

```
gaps inner 10
gaps outer 5
default_border pixel 2
```

#### Keybindings

**Basic Syntax**:[2]

```
bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+Shift+q kill
```

**Modifier Keys**:[2]
- `Mod1`: Alt key[2]
- `Mod4`: Windows/Super key[2]
- `Ctrl`: Control key[2]
- `Shift`: Shift key[2]

**Special Keys**:[1]

```
bindsym $mod+F1 exec firefox
bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
```

#### Workspace Management

**Named Workspaces**:[2]

```
set $ws1 "1:  Web"
set $ws2 "2:  Editor"
set $ws3 "3:  Terminal"

workspace $ws1 output HDMI-1
workspace $ws2 output HDMI-1
workspace $ws3 output HDMI-2
```

**Workspace Switching**:[2]

```
bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2
bindsym $mod+3 workspace number $ws3
```

**Move Windows**:[2]

```
bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
```

#### Window Rules

**Floating Windows**:[1][2]

```
for_window [class="Pavucontrol"] floating enable
for_window [class="Thunar"] floating enable
for_window [window_role="pop-up"] floating enable
```

**Specific Workspaces**:[1]

```
assign [class="Firefox"] → $ws1
assign [class="Thunderbird"] → $ws4
```

**Sticky Windows**:[2]

```
for_window [class="Keepass"] sticky enable
```

#### Launching Applications

**Startup Commands**:[1]

```
exec --no-startup-id nitrogen --restore
exec --no-startup-id picom -b
exec --no-startup-id /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
```

**Delay Execution**:[1]

```
exec --no-startup-id sleep 2 && firefox
```

#### Status Bar Configuration

**i3status Config**: `~/.config/i3status/config`:[2]

```
general {
    colors = true
    interval = 5
}

order += "cpu_usage"
order += "memory"
order += "disk /"
order += "tztime local"

cpu_usage {
    format = "CPU: %usage"
}

memory {
    format = "MEM: %used/%total"
}

tztime local {
    format = "%Y-%m-%d %H:%M:%S"
}
```

**Launch with i3bar**: In i3 config:[2]

```
bar {
    status_command i3status
    position top
    colors {
        background #000000
        statusline #ffffff
    }
}
```

### Bspwm Window Manager Customization

#### Configuration Files

**Main Config**: `~/.config/bspwm/bspwmrc`:[2]

```bash
#!/bin/bash

# Monitor setup
bspc monitor -d 1 2 3 4 5 6 7 8 9 10

# Window configuration
bspc config border_width 2
bspc config window_gap 12
bspc config split_ratio 0.52

# Colors
bspc config normal_border_color "#444444"
bspc config active_border_color "#0066ff"
bspc config focused_border_color "#00ff00"
```

**Make Executable**: `chmod +x ~/.config/bspwm/bspwmrc`.[2]

#### Hotkey Configuration

**Separate Daemon**: `~/.config/sxhkd/sxhkdrc`:[2]

```
# Launcher
super + d
    rofi -show run

# Terminal
super + Return
    alacritty

# Window management
super + w
    bspc node -c

super + s
    bspc node -s largest.window.local

# Workspace switching
super + {1-9,0}
    bspc desktop -f '^{1-9,10}'
```

**Comments**: Lines starting with `#`.[2]

#### Querying and Manipulating

**Query Windows**:[2]

```bash
bspc query -N -n focused
```

**Kill Window**:[2]

```bash
bspc node -c
```

**Swap Windows**:[2]

```bash
bspc node -s next
```

#### Event Handling

**Monitor Changes**: `bspc subscribe` for events:[2]

```bash
bspc subscribe monitor node | while read -r event; do
    # React to events
done
```

### Awesome Window Manager Scripting

#### Lua Configuration

**Location**: `~/.config/awesome/rc.lua`.[2]

**Lua Language**: Full programming language for config.[2]

#### Module Loading

**Basic Setup**:[2]

```lua
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

-- Window management rules
awful.rules.rules = {
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons
        }
    },
    {
        rule = { class = "Firefox" },
        properties = { screen = 1, tag = "1" }
    }
}
```

#### Creating Widgets

**Text Widget**:[2]

```lua
local mytext = wibox.widget.textbox()
mytext:set_text("Hello Awesome!")
```

**System Information**:[2]

```lua
local cpu_widget = wibox.widget.textbox()
gears.timer {
    timeout = 1,
    autostart = true,
    callback = function()
        awful.spawn.easy_async("top -bn1 | grep 'Cpu(s)'", function(out)
            cpu_widget:set_text("CPU: " .. out)
        end)
    end
}
```

#### Signal Handling

**Client Events**:[2]

```lua
client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)
```

### Sway Window Manager Customization

#### Configuration File

**Location**: `~/.config/sway/config`.[2]

**Similar to i3**: Shared syntax heritage:[2]

```
set $mod Mod1
set $left h
set $down j
set $up k
set $right l

output HDMI-1 {
    resolution 1920x1080
    position 0,0
}

workspace 1 output HDMI-1
workspace 2 output HDMI-2
```

#### Wayland-Specific Features

**Output Configuration**:[2]

```
output * background /path/to/wallpaper.png fill
```

**Input Configuration**:[2]

```
input "1:1:AT_Translated_Set_2_keyboard" {
    xkb_layout us
    xkb_options grp:alt_shift_toggle
}
```

#### Waybar Configuration

**Status Bar**: `/etc/xdg/waybar/config` or `~/.config/waybar/config.jsonc`:[2]

```json
{
    "layer": "top",
    "position": "top",
    "modules-left": ["sway/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery"],
    
    "sway/workspaces": {
        "format": "{name}",
        "on-click": "activate"
    },
    
    "clock": {
        "format": "{:%H:%M:%S}",
        "interval": 1
    }
}
```

### Hyprland Customization

#### Configuration Format

**Location**: `~/.config/hypr/hyprland.conf`.[2]

**Custom Syntax**: Hyprland-specific format:[2]

```
$mod = SUPER

# Window rules
windowrulev2 = float,class:^(pavucontrol)$
windowrulev2 = size 800 600,class:^(pavucontrol)$
windowrulev2 = move 100 100,class:^(pavucontrol)$
```

#### Advanced Keybindings

**Complex Binds**:[2]

```
bind = $mod SHIFT, S, exec, grim -g "$(slurp)" - | wl-copy
bind = $mod, PRINT, exec, grim - | wl-copy

# Repeatable binds (hold to repeat)
binde = $mod, left, movefocus, l
binde = $mod, right, movefocus, r
```

#### Monitor and Display Setup

**Multi-Monitor**:[2]

```
monitor = HDMI-1, 1920x1080@60, 0x0, 1
monitor = HDMI-2, 1920x1080@60, 1920x0, 1
monitor = , addreserved, 10, 10, 10, 10
```

### Scripting and Automation

#### Shell Scripts for WMs

**i3 Script Example**:[1]

```bash
#!/bin/bash
# Launch application in specific workspace
TARGET_WORKSPACE="2"

# Switch to workspace
i3-msg "workspace $TARGET_WORKSPACE"

# Launch application
alacritty &

# Move to workspace (might need adjustment)
sleep 0.5
i3-msg "move container to workspace $TARGET_WORKSPACE"
```

#### Python Automation

**i3-py Library**:[1]

```python
import i3

# Get focused window
focused = i3.filter(nodes=i3.get_tree()['nodes'], focused=True)

# Send command
i3.command('focus left')
```

#### Bspwm Scripting

**Event-Driven Script**:[2]

```bash
#!/bin/bash
bspc subscribe desktop_focus | while read line; do
    # Workspace changed
    notify-send "Switched workspace"
done
```

### Reloading Configuration

#### i3 Reload

**Without Restart**:[2]

```bash
i3-msg reload
i3-msg restart  # Full restart if needed
```

**Keyboard Shortcut**: In config:[2]

```
bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart
```

#### Bspwm Reload

**Executable Script**: Changes auto-apply:[2]

```bash
~/.config/bspwm/bspwmrc
```

#### Sway Reload

**Command**:[2]

```bash
swaymsg reload
```

**Keybinding**:[2]

```
bindsym $mod+Shift+c reload
```

### Theme and Color Customization

#### i3 Color Scheme

**In Config File**:[1]

```
# class                 border  backgr. text    indicator child_border
client.focused          #4c7899 #285577 #ffffff #2e9ef4   #285577
client.focused_inactive #333333 #5f676d #ffffff #484e50   #5f676d
client.unfocused        #333333 #222222 #888888 #292d2e   #222222
```

#### Awesome Theme

**Theme File**: `~/.config/awesome/theme.lua`:[2]

```lua
theme = {}
theme.bg_normal     = "#1a1a1a"
theme.bg_focus      = "#006699"
theme.fg_normal     = "#ffffff"
theme.fg_focus      = "#ffffff"
theme.border_width  = 2
theme.border_normal = "#444444"
theme.border_focus  = "#00ff00"
return theme
```

### Best Practices

**Version Control**: Track configs in Git:[1]

```bash
cd ~/.config
git init
git add i3 sxhkd bspwm
git commit -m "Initial WM configuration"
```

**Modular Design**: Split large configs:[1]

```bash
# In i3 config
include ~/.config/i3/bindings
include ~/.config/i3/colors
include ~/.config/i3/windows
```

**Documentation**: Comment configuration extensively.[1]

**Testing**: Reload frequently while editing.[2]

**Backup Originals**: Keep default configurations.[1]

**Incremental Changes**: Modify one setting at a time.[2]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

