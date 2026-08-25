## Autostart Configuration


Autostart configuration executes commands automatically when Hyprland launches, useful for starting applications, services, daemons, and system initialization tasks. Hyprland provides two execution keywords: `exec-once` for one-time startup and `exec` for reload-time execution.[1][2]

### exec-once Keyword

**exec-once** runs commands only once per Hyprland session, regardless of configuration reloads. Use this for applications that should start once and continue running, services that error on restart, or system initialization tasks:[2][1]
```
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = dunst
exec-once = hyprpaper
exec-once = waybar
```


The first example starts the KDE authentication agent (essential for password prompts), the second initializes D-Bus for application compatibility, the third starts a notification daemon, the fourth launches a wallpaper manager, and the fifth starts a status bar.[1]

### exec Keyword

**exec** runs commands every time the configuration reloads, whether on startup or manual reload via `hyprctl reload`. Use this sparingly for commands that tolerate repeated execution or must rerun after config changes:[2][1]
```
exec = hyprctl setcursor Bibata-Modern-Classic 24
exec = pkill waybar; waybar
```


The first resets the cursor theme on reload, the second kills and restarts waybar to apply any changed configuration.[1]

### Application Launching

Start desktop applications with `exec-once`:[1]
```
exec-once = firefox
exec-once = spotify
exec-once = discord
exec-once = slack
exec-once = element-desktop
```


These applications start automatically on session launch. Delay startup with `sleep` if other services must initialize first:[1]
```
exec-once = sleep 2 && discord
```


### System Services and Daemons

Initialize critical system services on startup:[2][1]
```
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user start graphical-session-pre.target graphical-session.target graphical-session.target
```


These start polkit agents (required for privilege elevation), update D-Bus environment, and initialize systemd user session targets.[2][1]

### Notification Daemon

Start notification daemons for desktop notifications:[1]
```
exec-once = mako
exec-once = dunst
exec-once = swaync
```


Only one notification daemon should run; choose based on preferred configuration and features.[2][1]

### Wallpaper and Desktop

Set wallpapers and desktop backgrounds:[2][1]
```
exec-once = hyprpaper
exec-once = swaybg -i ~/Pictures/wallpaper.png
exec-once = mpvpaper --auto-pause eDP-1 ~/Videos/wallpaper.mp4
```


Hyprpaper manages multiple wallpapers and scaling; swaybg is simpler for single images; mpvpaper enables animated wallpapers.[1]

### Status Bar and System Tray

Initialize UI elements:[1]
```
exec-once = waybar
exec-once = polybar main
exec-once = eww daemon && eww open bar
```


Waybar is Wayland-native and Hyprland-compatible; polybar requires workarounds; eww (ElKowars wacky widgets) is minimal and highly configurable.[1]

### Clipboard Manager

Start clipboard managers for history and synchronization:[2][1]
```
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
exec-once = clipse
```


The first two start cliphist with text and image history; clipse provides a simpler alternative.[1]

### Input Method (IME)

Initialize input method engines for non-Latin languages:[2][1]
```
exec-once = fcitx5 -d
exec-once = ibus daemon --xim
```


Fcitx5 is modern and recommended; ibus is a legacy alternative.[1]

### XDG Desktop Portal

Start desktop portal for file dialogs and system integration:[2][1]
```
exec-once = /usr/libexec/xdg-desktop-portal-wlr
exec-once = /usr/libexec/xdg-desktop-portal-hyprland
exec-once = /usr/libexec/xdg-desktop-portal-gnome
```


Hyprland has a dedicated portal (`xdg-desktop-portal-hyprland`); wlr and gnome portals are alternatives.[1]

### Screen Locking and Idle Management

Configure lock screens and idle behavior:[2][1]
```
exec-once = swayidle -w before-sleep 'swaylock -f'
exec-once = hypridle
```


Swayidle locks the screen before system sleep; hypridle is Hyprland-specific and offers more features.[1]

### Custom Scripts

Execute custom initialization scripts:[2][1]
```
exec-once = ~/.config/hypr/scripts/startup.sh
exec-once = bash ~/.config/hypr/scripts/monitor-setup.sh
```


Place scripts in `~/.config/hypr/scripts/` and ensure they're executable (`chmod +x script.sh`).[1]

### Conditional Execution

Use shell conditionals for platform-specific or hardware-specific startup:[2][1]
```
exec-once = [[ $(hostname) == "laptop" ]] && hyprctl keyword input:touchpad:disable_while_typing true
exec-once = [[ -f /usr/bin/nvidia-smi ]] && echo "NVIDIA GPU detected"
```


### Error Handling and Logging

Redirect output to logs for debugging failed autostart commands:[2][1]
```
exec-once = waybar > ~/.config/hypr/logs/waybar.log 2>&1
exec-once = dunst > ~/.config/hypr/logs/dunst.log 2>&1 &
```


The `&` background operator prevents blocking Hyprland startup if a command hangs.[1]

### Example Comprehensive Autostart Configuration

```
# Authentication and D-Bus
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Wallpaper
exec-once = hyprpaper

# Notification daemon
exec-once = dunst

# Status bar
exec-once = waybar

# Clipboard manager
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store

# Input method
exec-once = fcitx5 -d

# XDG Desktop Portal
exec-once = /usr/libexec/xdg-desktop-portal-hyprland

# Idle and lock
exec-once = hypridle

# Applications
exec-once = discord
exec-once = spotify
exec-once = firefox

# Custom scripts
exec-once = ~/.config/hypr/scripts/startup.sh
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/
[3] Variables https://wiki.hyprland.org/0.46.0/Configuring/Variables/

