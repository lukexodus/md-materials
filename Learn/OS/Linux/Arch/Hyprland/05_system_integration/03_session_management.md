## Session Management


Session management controls Hyprland's startup, shutdown, idle behavior, screen locking, and systemd integration. Proper configuration ensures applications save state, system suspends correctly, and security measures activate when idle.[1][2]

### systemd User Session Integration

Initialize systemd user session targets for proper system integration:[2][1]
```
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user start graphical-session-pre.target graphical-session.target graphical-session.target
```


These commands import environment variables into systemd, enabling user services to access Wayland and desktop information, then start graphical session targets that activate user-level services.[1][2]

### D-Bus and XDG Integration

Update D-Bus environment for application compatibility:[2][1]
```
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
```


This ensures D-Bus services receive correct environment variables, enabling applications like password managers, VPNs, and system daemons to function properly.[1][2]

### Screen Locking and Idle Management

**Hypridle** is the Hyprland-native idle daemon, offering deep integration and performance advantages:[2][1]
```
exec-once = hypridle
```


Configure hypridle with `~/.config/hypridle/hypridle.conf` to define idle timeouts and actions:
```
general {
  lock_cmd = hyprlock
  unlock_cmd = notify-send "Unlock!"
  before_sleep_cmd = notify-send "Before sleep"
  after_sleep_cmd = notify-send "After sleep"
  ignore_systemd_inhibit = false
}

listener {
  timeout = 300
  on-timeout = notify-send "Idle for 5 minutes"
}

listener {
  timeout = 600
  on-timeout = hyprlock
}

listener {
  timeout = 900
  on-timeout = systemctl suspend
}
```


This configuration locks the screen after 10 minutes of inactivity and suspends after 15 minutes.[1]

**Swayidle** is an alternative lightweight idle daemon:[2][1]
```
exec-once = swayidle -w before-sleep 'swaylock -f'
```


This locks the screen before system sleep but provides fewer idle timeout options than hypridle.[1]

### Screen Locking

**Hyprlock** is Hyprland's native lock screen with GPU-accelerated rendering:[2][1]
```
exec-once = hypridle
```


Configure `~/.config/hypr/hyprlock.conf`:
```
background {
  monitor =
  path = ~/Pictures/wallpaper.png
  blur_passes = 3
  blur_size = 8
}

input-field {
  monitor =
  size = 200, 50
  outline_thickness = 3
  dots_size = 0.2
  dots_spacing = 0.2
  outer_color = rgb(151515)
  inner_color = rgb(222222)
  font_color = rgb(10, 10, 10)
  fade_on_empty = false
  font_family = JetBrains Mono
  placeholder = <span foreground="##ffffff">🔒 Enter password</span>
  hide_input = false
  check_color = rgb(204, 136, 34)
  fail_color = rgb(204, 34, 34)
  fail_text = <i>$ATTEMPTS failed</i>
  capslock_color = -1
  numlock_color = -1
  bothlock_color = -1
  invert_numlock = false
  swap_layout_key = Tab
}

label {
  monitor =
  text = $TIME
  text_align = center
  color = rgba(200, 200, 200, 1.0)
  font_size = 55
  font_family = JetBrains Mono
  position = 0, 200
  halign = center
  valign = center
}
```


**Swaylock** is a lightweight alternative lock screen:[1]
```
bind = SUPER, L, exec, swaylock -f -c 000000
```


### Session Save/Restore

Some applications support automatic session saving through XDG session management. Enable session save on exit and restore on startup:[1]
```
bind = SUPER+SHIFT, E, exec, hyprctl dispatch exit 0
```


Applications with session support (GNOME applications, some KDE apps) automatically restore state.[1]

### Power Management

Bind power management commands to keybinds and autostart:[2][1]
```
bind = SUPER, P, exec, systemctl poweroff
bind = SUPER, S, exec, systemctl suspend
bind = SUPER+SHIFT, S, exec, systemctl hibernate
```


Configure sleep and suspend behavior in `/etc/systemd/sleep.conf` for pre-sleep hooks.[1]

### systemd Power Button Handling

Disable Hyprland's default power button handling and let systemd manage it:[2][1]
```
# Remove or comment out power button dispatcher
# bind = , XF86PowerOff, exec, systemctl poweroff
```


Systemd automatically handles power button, sleep button, and lid switch events according to `/etc/systemd/logind.conf`.[2][1]

### Multi-Monitor Session Persistence

Preserve monitor configuration across sessions using `hyprctl monitors all` output:[1]
```
monitor = DP-1, 3440x1440@144, 0x0, 1
monitor = DP-2, 2560x1440@60, 3440x0, 1
```


Hyprland automatically applies monitor configuration on startup if saved in `hyprland.conf`.[1]

### Workspace Persistence

Configure persistent workspaces to maintain layout across sessions:[1]
```
workspace = 1, persistent:true
workspace = 2, persistent:true
workspace = name:code, persistent:true
workspace = name:mail, persistent:true
```


Persistent workspaces remain in the workspace list even when empty, enabling consistent workflow organization.[1]

### systemd User Services for Hyprland

Create custom systemd user services for Hyprland-specific tasks. Example `~/.config/systemd/user/hyprland-startup.service`:[2][1]
```
[Unit]
Description=Hyprland Startup
After=graphical-session-pre.target
PartOf=graphical-session.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=%h/.config/hypr/scripts/startup.sh
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=graphical-session.target
```


Enable with `systemctl --user enable hyprland-startup.service`.[1]

### Example Comprehensive Session Configuration

```
# D-Bus and systemd
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user start graphical-session-pre.target graphical-session.target

# Authentication and portals
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = /usr/libexec/xdg-desktop-portal-hyprland

# Idle and lock
exec-once = hypridle

# UI elements
exec-once = waybar
exec-once = dunst

# Power management
bind = SUPER, P, exec, systemctl poweroff
bind = SUPER, S, exec, systemctl suspend
bind = SUPER, L, exec, hyprlock

# Workspace persistence
workspace = 1, persistent:true
workspace = 2, persistent:true
workspace = name:code, persistent:true
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/
[3] Variables https://wiki.hyprland.org/0.46.0/Configuring/Variables/

