## Media Keys


### Media Key Codes

Media keys are special function keys for volume, brightness, media playback, and system controls. Hyprland recognizes these keys through XF86 keycodes, allowing direct binding without additional configuration.[1][2]

Common media key codes:[2][1]
- `XF86AudioRaiseVolume` - Volume up
- `XF86AudioLowerVolume` - Volume down
- `XF86AudioMute` - Mute/unmute
- `XF86AudioMicMute` - Microphone mute toggle
- `XF86AudioPlay` - Play/pause
- `XF86AudioNext` - Next track
- `XF86AudioPrev` - Previous track
- `XF86MonBrightnessUp` - Brightness increase
- `XF86MonBrightnessDown` - Brightness decrease
- `XF86Sleep` - Sleep/suspend
- `XF86PowerOff` - Power off
- `XF86WLAN` - Toggle WiFi
- `XF86Bluetooth` - Toggle Bluetooth
- `XF86Calculator` - Launch calculator
- `XF86Mail` - Launch mail client
- `XF86Messenger` - Launch messenger
- `XF86WebCam` - Toggle webcam

[3][4][1][2]

### Volume Control

Bind media keys to volume commands using `amixer`, `pactl`, or `wpctl` (PipeWire):[1][2][3]

**Using pactl (PulseAudio):**
```
bind = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
bind = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
bind = , XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle
```


**Using wpctl (PipeWire):**
```
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
```


**Using amixer (ALSA):**
```
bind = , XF86AudioRaiseVolume, exec, amixer set Master 5%+
bind = , XF86AudioLowerVolume, exec, amixer set Master 5%-
bind = , XF86AudioMute, exec, amixer set Master toggle
```


### Brightness Control

Adjust display brightness using `brightnessctl` or `xbacklight`:[2][3][1]

**Using brightnessctl:**
```
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
```


**Using xbacklight:**
```
bind = , XF86MonBrightnessUp, exec, xbacklight -inc 5
bind = , XF86MonBrightnessDown, exec, xbacklight -dec 5
```


### Media Playback Control

Control music players and media applications using `playerctl`:[3][1][2]
```
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous
```


Playerctl works with MPRIS-compatible players including Spotify, VLC, mpv, and many others.[1][2]

### Keyboard Backlight

Control keyboard backlighting with `brightnessctl`:[2][1]
```
bind = , XF86KbdBrightnessUp, exec, brightnessctl -d kbd_backlight set +10%
bind = , XF86KbdBrightnessDown, exec, brightnessctl -d kbd_backlight set 10%-
```


### System Control Keys

Bind sleep and power management keys:[1][2]
```
bind = , XF86Sleep, exec, systemctl suspend
bind = , XF86PowerOff, exec, systemctl poweroff
bind = , XF86ScreenSaver, exec, swaylock
```


### WiFi and Bluetooth

Toggle wireless interfaces using `nmcli` or `rfkill`:[2][1]

**Using rfkill:**
```
bind = , XF86WLAN, exec, rfkill toggle wifi
bind = , XF86Bluetooth, exec, rfkill toggle bluetooth
```


**Using nmcli:**
```
bind = , XF86WLAN, exec, nmcli radio wifi off
bind = , XF86Bluetooth, exec, nmcli radio bluetooth off
```


### Application Launchers

Launch applications directly from media keys:[3][1][2]
```
bind = , XF86Calculator, exec, gnome-calculator
bind = , XF86Mail, exec, thunderbird
bind = , XF86WebCam, exec, mpv av://v4l2:/dev/video0
```


### Notification Integration

Display on-screen notifications for media key actions using `notify-send`:[3][1][2]
```
bind = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5% && notify-send "Volume" "$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)%"
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5% && notify-send "Brightness" "$(brightnessctl get | awk '{print int($1/$2*100)}')%"
```


### Example Comprehensive Media Key Configuration

```
# Volume
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Brightness
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
bind = , XF86KbdBrightnessUp, exec, brightnessctl -d kbd_backlight set +10%
bind = , XF86KbdBrightnessDown, exec, brightnessctl -d kbd_backlight set 10%-

# Media playback
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# System
bind = , XF86Sleep, exec, systemctl suspend
bind = , XF86ScreenSaver, exec, swaylock

# Wireless
bind = , XF86WLAN, exec, rfkill toggle wifi
bind = , XF86Bluetooth, exec, rfkill toggle bluetooth

# Applications
bind = , XF86Calculator, exec, gnome-calculator
bind = , XF86Mail, exec, thunderbird
```

Sources
[1] Binds https://wiki.hypr.land/Configuring/Binds/
[2] Binds | Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Configuring/Binds/
[3] Keybinds · JaKooLit/Hyprland-Dots Wiki https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds
[4] Hyprland https://wiki.cachyos.org/configuration/desktop_environments/hyprland/

