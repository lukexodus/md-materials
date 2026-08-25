## Status Bars (Waybar)


Waybar is the primary Wayland-native status bar for Hyprland, providing system information, application launchers, workspace indicators, and customizable modules. It replaces X11-based status bars with modern Wayland support and deep Hyprland integration.[1][2]

### Installation

Install Waybar on Arch Linux with `sudo pacman -S waybar`. Start automatically on Hyprland launch:[1]
```
exec-once = waybar
```


### Configuration Files

Waybar uses two configuration files in `~/.config/waybar/`:[1]

**config** - Layout and module definitions[1]
**style.css** - Styling and appearance[1]

Create these files with custom configurations.[1]

### Basic Configuration Structure

**~/.config/waybar/config:**
```json
{
  "layer": "top",
  "position": "top",
  "height": 30,
  "modules-left": ["hyprland/workspaces", "hyprland/window"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio", "network", "battery"],
  "hyprland/workspaces": {
    "format": "{name}",
    "on-click": "activate"
  },
  "clock": {
    "format": "{:%H:%M}",
    "timezone": "America/New_York"
  },
  "pulseaudio": {
    "format": "🔊 {volume}%",
    "on-click": "pavucontrol"
  }
}
```


**layer** sets stacking order (`top`, `overlay`, `bottom`); `top` places waybar above windows. **position** places bar at screen edge: `top`, `bottom`, `left`, `right` (default `top`). **height** sets bar height in pixels. **modules-left/center/right** define module placement.[1]

### Essential Modules

**hyprland/workspaces** - Workspace indicator and switcher:[1]
```json
"hyprland/workspaces": {
  "format": "{name}",
  "on-click": "activate",
  "sort-by-number": true,
  "active-only": false
}
```


**hyprland/window** - Current focused window title:[1]
```json
"hyprland/window": {
  "format": "{}",
  "max-length": 50
}
```


**clock** - Date and time display:[1]
```json
"clock": {
  "format": "{:%A, %B %d   %H:%M}",
  "timezone": "UTC"
}
```


**pulseaudio** - Volume control:[1]
```json
"pulseaudio": {
  "format": "🔊 {volume}%",
  "format-muted": "🔇 Muted",
  "on-click": "pavucontrol",
  "on-scroll-up": "pactl set-sink-volume @DEFAULT_SINK@ +5%",
  "on-scroll-down": "pactl set-sink-volume @DEFAULT_SINK@ -5%"
}
```


**network** - Network status:[1]
```json
"network": {
  "format-wifi": "📶 {essid}",
  "format-ethernet": "🌐 Ethernet",
  "format-disconnected": "❌ Disconnected"
}
```


**battery** - Battery status:[1]
```json
"battery": {
  "format": "🔋 {capacity}%",
  "states": {
    "warning": 30,
    "critical": 15
  }
}
```


**backlight** - Display brightness:[1]
```json
"backlight": {
  "format": "☀️ {percent}%",
  "on-scroll-up": "brightnessctl set +5%",
  "on-scroll-down": "brightnessctl set 5%-"
}
```


**tray** - System tray:[1]
```json
"tray": {
  "icon-size": 21,
  "spacing": 10
}
```


### Styling with CSS

**~/.config/waybar/style.css:**
```css
* {
  font-family: monospace;
  font-size: 12px;
  color: #ffffff;
}

window {
  background-color: #1e1e2e;
  border-bottom: 3px solid #45475a;
}

#workspaces button {
  padding: 0 5px;
  background-color: #313244;
  border-radius: 5px;
  margin: 0 3px;
}

#workspaces button.active {
  background-color: #89b4fa;
  color: #000000;
}

#window {
  padding: 0 10px;
  margin-left: 10px;
}

#clock {
  padding: 0 10px;
}

#pulseaudio {
  padding: 0 10px;
  color: #89dceb;
}

#network {
  padding: 0 10px;
  color: #a6e3a1;
}

#battery {
  padding: 0 10px;
  color: #f38ba8;
}
```


### Advanced Module: Custom Scripts

Execute custom scripts as waybar modules:[1]
```json
"custom/weather": {
  "exec": "~/.config/waybar/scripts/weather.sh",
  "interval": 300,
  "format": "🌤️ {}"
}
```


Create `~/.config/waybar/scripts/weather.sh`:[1]
```bash
#!/bin/bash
curl -s "https://wttr.in/?format=3" | cut -d' ' -f1-2
```


### Hyprland Integration

Waybar natively supports Hyprland-specific modules:[1]

**Workspace management:**
```json
"hyprland/workspaces": {
  "format": "{name}",
  "on-click": "activate",
  "persistent-workspaces": {
    "DP-1": [1, 2, 3],
    "HDMI-1": [4, 5, 6]
  }
}
```


This creates persistent workspace configuration per monitor.[1]

### Reload and Update

Restart Waybar after config changes:[1]
```
bind = SUPER+SHIFT, W, exec, killall waybar; waybar
```


Or reload during session:[1]
```bash
killall -SIGUSR2 waybar
```


### Alternative Status Bars

**Eww (ElKowars wacky widgets):**
```
exec-once = eww daemon && eww open bar
```


Highly customizable, minimal overhead; steeper learning curve.[1]

**Polybar:**
```
exec-once = polybar main
```


X11-centric; works under XWayland but not ideal.[1]

**Yambar:**
```
exec-once = yambar
```


Lightweight alternative; limited Hyprland integration.[1]

### Example Comprehensive Waybar Configuration

```json
{
  "layer": "top",
  "position": "top",
  "height": 30,
  "modules-left": ["hyprland/workspaces", "hyprland/window"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio", "backlight", "network", "battery", "tray"],
  
  "hyprland/workspaces": {
    "format": "{name}",
    "on-click": "activate",
    "sort-by-number": true
  },
  
  "hyprland/window": {
    "format": "{}",
    "max-length": 50
  },
  
  "clock": {
    "format": "{:%A, %B %d   %H:%M}",
    "timezone": "UTC"
  },
  
  "pulseaudio": {
    "format": "🔊 {volume}%",
    "format-muted": "🔇",
    "on-click": "pavucontrol",
    "on-scroll-up": "pactl set-sink-volume @DEFAULT_SINK@ +5%",
    "on-scroll-down": "pactl set-sink-volume @DEFAULT_SINK@ -5%"
  },
  
  "backlight": {
    "format": "☀️ {percent}%",
    "on-scroll-up": "brightnessctl set +5%",
    "on-scroll-down": "brightnessctl set 5%-"
  },
  
  "network": {
    "format-wifi": "📶 {essid}",
    "format-ethernet": "🌐",
    "format-disconnected": "❌"
  },
  
  "battery": {
    "format": "🔋 {capacity}%",
    "states": {
      "warning": 30,
      "critical": 15
    }
  },
  
  "tray": {
    "icon-size": 21,
    "spacing": 10
  }
}
```


Add corresponding CSS styling in `~/.config/waybar/style.css`.[1]

Add to `hyprland.conf`:
```
exec-once = waybar
bind = SUPER+SHIFT, W, exec, killall waybar; waybar
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

