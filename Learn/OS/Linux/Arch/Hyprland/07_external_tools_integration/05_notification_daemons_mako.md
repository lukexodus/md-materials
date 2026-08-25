## Notification Daemons (Mako)


Notification daemons display system notifications for events, application alerts, and user feedback within Hyprland. Mako is the recommended Wayland-native notification daemon offering deep integration and minimal overhead.[1][2]

### Mako (Recommended)

**Mako** is a lightweight notification daemon designed specifically for Wayland compositors. Install on Arch Linux with `sudo pacman -S mako`.[2][1]

Start automatically on Hyprland launch:[1]
```
exec-once = mako
```


### Configuration File

Mako uses `~/.config/mako/config` for customization:[1]
```
# Global settings
width=300
height=100
margin=10
padding=10
border-size=2
border-color=#89b4fa
background-color=#1e1e2e
text-color=#cdd6f4
font=monospace 11

# Urgency levels
[urgency=low]
border-color=#a6e3a1
timeout=2000

[urgency=normal]
border-color=#89b4fa
timeout=4000

[urgency=critical]
border-color=#f38ba8
timeout=0
```


**width/height** - Notification dimensions in pixels. **margin** - Space around notifications. **padding** - Internal spacing. **border-size/color** - Border styling. **background-color/text-color** - Colors. **font** - Font family and size.[1]

### Urgency Levels

Configure different behaviors based on notification importance:[1]

**Low urgency (2 second timeout):**
```
[urgency=low]
border-color=#a6e3a1
background-color=#31323400
timeout=2000
```


**Normal urgency (4 second timeout):**
```
[urgency=normal]
border-color=#89b4fa
background-color=#1e1e2e
timeout=4000
```


**Critical urgency (persistent):**
```
[urgency=critical]
border-color=#f38ba8
background-color=#1e1e2e
timeout=0
```


Timeout 0 means notifications persist until manually closed.[1]

### Notification Positioning

**anchor** positions notifications on screen:[1]
```
anchor=top-right
```


Options: `top-left`, `top-center`, `top-right`, `center`, `bottom-left`, `bottom-center`, `bottom-right`.[1]

### Actions and Interactive Elements

Enable action buttons on notifications:[1]
```
[urgency=critical]
actions=true
action-icons=true
```


Applications can define clickable buttons on notifications.[1]

### Icon Support

Display notification icons with icon theme support:[1]

Create `~/.config/mako/icons/` directory for custom icons:[1]
```bash
mkdir -p ~/.config/mako/icons
```


Configure icon theme in `~/.config/mako/config`:[1]
```
icon-path=/usr/share/icons/hicolor
max-icon-size=64
```


### Notification History

View notification history with keybinds:[1]
```
makoctl history pop
```


Bind to retrieve last notification:[1]
```
bind = SUPER, N, exec, makoctl history pop
```


### Dismissing Notifications

Manually close all notifications:[1]
```bash
makoctl dismiss -a
```


Bind for quick dismissal:[1]
```
bind = SUPER+SHIFT, N, exec, makoctl dismiss -a
```


### Testing Notifications

Send test notifications to verify configuration:[1]
```bash
notify-send "Test Notification" "This is a test"
notify-send -u critical "Critical Alert" "Urgent notification"
```


### Alternative Notification Daemons

**Dunst** - Lightweight X11-based daemon (works via XWayland):[1]
```
exec-once = dunst
```


Configure in `~/.config/dunst/dunstrc`.[1]

**SwayNC** - Notification center for Wayland:[1]
```
exec-once = swaync
```


Modern alternative with notification center UI.[1]

### Notification Volume Control

Set notification volume with media keys:[1]
```
bind = , XF86AudioRaiseVolume, exec, notify-send "Volume" "$(pactl get-sink-volume @DEFAULT_SINK@)"
```


### Notification Filtering

Filter notifications by application using `makoctl`:[1]
```bash
# Disable notifications from specific app
makoctl invoke
```


### Integration with Scripts

Send notifications from shell scripts:[1]
```bash
#!/bin/bash
BACKUP_STATUS=$(rsync -avz /source /dest 2>&1)
if [ $? -eq 0 ]; then
  notify-send -u normal "Backup Complete" "Files synchronized successfully"
else
  notify-send -u critical "Backup Failed" "$BACKUP_STATUS"
fi
```


### Example Comprehensive Mako Configuration

Create `~/.config/mako/config`:
```
# Global settings
anchor=top-right
width=300
height=100
margin=10
padding=10
border-size=2
border-radius=8
background-color=#1e1e2e
text-color=#cdd6f4
font=monospace 11
icon-path=/usr/share/icons/hicolor
max-icon-size=64

# Default behavior
progress-color=over #89b4fa
default-timeout=4000

# Low urgency
[urgency=low]
border-color=#a6e3a1
background-color=#1e1e2e
timeout=2000

# Normal urgency
[urgency=normal]
border-color=#89b4fa
background-color=#1e1e2e
timeout=4000

# Critical urgency
[urgency=critical]
border-color=#f38ba8
background-color=#1e1e2e
timeout=0
```


Add to `hyprland.conf`:
```
# Notification daemon
exec-once = mako

# Keybinds
bind = SUPER, N, exec, makoctl history pop
bind = SUPER+SHIFT, N, exec, makoctl dismiss -a
```


Mako is recommended as the primary notification daemon for Hyprland due to native Wayland support, minimal resource usage, and seamless integration.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

