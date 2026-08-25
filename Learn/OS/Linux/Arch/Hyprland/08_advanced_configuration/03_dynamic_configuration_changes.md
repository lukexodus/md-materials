## Dynamic Configuration Changes


Hyprland enables live adjustment of many settings—such as appearance, input, and behavior—without reloading the compositor or losing your session. These dynamic changes are made using the `hyprctl keyword` command or IPC, providing a flexible environment for rapid workflow adaptation and scripting.[1][2]

### Runtime Variable Changes

Change configuration values instantly using `hyprctl keyword`:
```bash
hyprctl keyword general:gaps_in 6
hyprctl keyword decoration:rounding 12
hyprctl keyword input:kb_layout us
hyprctl keyword decoration:active_opacity 0.92
hyprctl keyword general:border_size 4
```


- The changes apply immediately and remain active until you reload or restart Hyprland.
- You can alter almost any variable that is present in the Hyprland config, including nested and sectioned options using the syntax `section:option`.[1][2]

### Animation, Decorations, and Compositor Effects

Alter how Hyprland looks and feels in real time:
```bash
hyprctl keyword decoration:blur:size 12
hyprctl keyword decoration:blur:enabled false
hyprctl keyword animations:enabled false
hyprctl keyword animations:global_speed 12
```


- Turn animation/blurring on or off to optimize performance for remote sessions or high-load situations.[1]
- Adjust window opacity, border color, or any other supported style for instantly different workspace "moods" or nighttime reading.[1]

### Temporary Tweaks via Scripting

Create scripts to quickly toggle or shift settings:[1]
```bash
#!/bin/bash
# Toggle window borders on/off
BORDER=$(hyprctl getoption general:border_size | grep int: | awk '{print $2}')
if [ "$BORDER" -eq 0 ]; then
  hyprctl keyword general:border_size 2
else
  hyprctl keyword general:border_size 0
fi
```


Bind to a key:
```
bind = SUPER, B, exec, ~/.config/hypr/scripts/toggle-borders.sh
```


### Window, Input, and Monitor Changes

Set focus-follows-mouse, mouse sensitivity, or touchpad properties dynamically:
```bash
hyprctl keyword input:kb_layout de
hyprctl keyword input:follow_mouse 0
hyprctl keyword input:sensitivity 0.56
hyprctl keyword input:touchpad:natural_scroll true
```


You can also change monitor orientation, scale, and workspace locations while running using dispatchers or monitor config keywords:
```bash
hyprctl keyword monitor DP-1,1920x1080,0x0,1,transform,1
hyprctl dispatch workspace name:media
```


### Automated/Time-of-Day Dynamic Changes

Combine with scripting and cron or systemd timers for automatic theme switching, night/day opacity, etc.:[1]
```bash
# At sunset, enable blue light filter and dim windows
hyprsunset-util -t 3500
hyprctl keyword decoration:inactive_opacity 0.7
```


### Resetting to Persistent Values

- Dynamic changes are lost upon `hyprctl reload`, restarting Hyprland, or editing the config file.
- To make settings persist, update them in your `hyprland.conf`.[2][1]

### Example Keybinds for Dynamic Changes

**Light/dark theme toggle:**
```
bind = SUPER, T, exec, hyprctl keyword decoration:active_opacity 1 && hyprctl keyword decoration:inactive_opacity 0.9
bind = SUPER+SHIFT, T, exec, hyprctl keyword decoration:active_opacity 0.85 && hyprctl keyword decoration:inactive_opacity 0.6
```


**Switch blur preset:**
```
bind = SUPER, F2, exec, hyprctl keyword decoration:blur:size 8
bind = SUPER, F3, exec, hyprctl keyword decoration:blur:size 18
```


**Mouse/keyboard language instant switcher:**
```
bind = SUPER, Space, exec, hyprctl keyword input:kb_layout us
bind = SUPER+SHIFT, Space, exec, hyprctl keyword input:kb_layout jp
```


Dynamic configuration changes through `hyprctl` provide on-the-fly workflow optimization, theming, troubleshooting, and accessibility in Hyprland.[2][1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

