## Hyprsunset (Blue Light Filter)


Hyprsunset is Hyprland's native blue light filter daemon providing automatic color temperature adjustment based on time of day or manual control. It reduces eye strain during evening use by shifting display colors toward warmer tones.[1][2]

### Installation and Startup

Install Hyprsunset on Arch Linux with `sudo pacman -S hyprsunset`. Start automatically on Hyprland launch by adding to `hyprland.conf`:[1]
```
exec-once = hyprsunset
```


### Configuration File

Hyprsunset uses `~/.config/hyprsunset/hyprsunset.conf` for configuration, though it can operate with sensible defaults without explicit configuration.[2][1]

### Basic Configuration

Create `~/.config/hyprsunset/hyprsunset.conf` with time-based temperature settings:[1]
```
general {
  temp_day = 6500
  temp_night = 3500
  sunrise = 6:00
  sunset = 18:00
}
```


**temp_day** sets daytime color temperature in Kelvin (default 6500K, neutral white). **temp_night** sets nighttime temperature (default 3500K, warm orange). **sunrise** specifies sunrise time for temperature transition (default 6:00 AM). **sunset** specifies sunset time (default 6:00 PM).[1]

### Temperature Adjustment

Adjust temperature manually at runtime using keybinds with the `hyprsunset-util` command:[1]
```
bind = , XF86MonBrightnessUp, exec, hyprsunset-util -t +100
bind = , XF86MonBrightnessDown, exec, hyprsunset-util -t -100
```


This increases/decreases color temperature by 100K on media keys.[1]

### Toggle and Reset

Enable/disable the filter with keybinds:[1]
```
bind = SUPER, B, exec, hyprsunset-util -t 6500  # Reset to day temperature
bind = SUPER+SHIFT, B, exec, hyprsunset-util -t 3500  # Force night temperature
```


Toggle between enabled/disabled states:[1]
```
bind = SUPER, N, exec, hyprsunset-util -toggle
```


### Specific Temperature Setting

Set exact temperature:[1]
```
bind = , XF86Sleep, exec, hyprsunset-util -t 2700
```


This sets an extremely warm tone (2700K) useful for very late-night use.[1]

### Geolocation-Based Sunrise/Sunset

Hyprsunset can determine sunrise/sunset times based on geographic location. Configure in hyprsunset.conf:[1]
```
general {
  latitude = 40.7128
  longitude = -74.0060
}
```


This automatically calculates sunrise/sunset for New York City coordinates. Locate your coordinates using online tools or `curl -s "https://ipinfo.io/loc"`.[1]

### Per-Monitor Configuration

Apply different temperatures to multiple monitors:[1]
```
monitor {
  name = DP-1
  temp_day = 6500
  temp_night = 3500
}

monitor {
  name = HDMI-1
  temp_day = 5500
  temp_night = 2700
}
```


### Transition Speed

Configure smooth temperature transitions with `transition_speed`:[1]
```
general {
  transition_speed = 2
}
```


Higher values transition faster; lower values provide gradual changes.[1]

### Disabling Hyprsunset

Temporarily disable without stopping the daemon:[1]
```
hyprsunset-util -off
hyprsunset-util -on
```


Permanently disable by removing `exec-once = hyprsunset` from `hyprland.conf` and restarting.[1]

### Integration with Other Tools

Combine with other Hyprland utilities for comprehensive eye care:[1]
```
# Autostart everything
exec-once = hypridle
exec-once = hyprsunset
exec-once = dunst  # Notifications

# Keybinds
bind = SUPER, B, exec, hyprsunset-util -t 3500  # Enable night mode
bind = SUPER+SHIFT, B, exec, hyprsunset-util -t 6500  # Enable day mode
bind = ALT, B, exec, hyprsunset-util -toggle  # Toggle
```


### Typical Temperature Values

**6500K (Day):** Neutral white, full brightness, suitable for daytime use[1]
**5500K (Afternoon):** Slightly warmer, transitional temperature[1]
**4000K (Evening):** Warm, reducing eye strain[1]
**3500K (Night):** Orange-warm, significant blue light reduction[1]
**2700K (Late Night):** Very warm, maximum eye comfort[1]

### Troubleshooting

**Filter not applying:** Verify Hyprsunset is running with `systemctl --user status hyprsunset` or `pgrep hyprsunset`. Check configuration syntax in hyprsunset.conf.[1]

**Temperature not changing at scheduled times:** Verify system time is correct with `date`. Ensure sunrise/sunset times match your timezone.[1]

**Monitor-specific temperatures not working:** Verify monitor names match output from `hyprctl monitors`. Use exact names including port identifiers.[1]

**Hyprsunset conflicts with other tools:** Disable other color temperature tools (f.lux, Redshift) to avoid conflicts.[1]

### Example Comprehensive Hyprsunset Configuration

```
general {
  temp_day = 6500
  temp_night = 3500
  sunrise = 6:00
  sunset = 18:00
  transition_speed = 2
  latitude = 40.7128
  longitude = -74.0060
}

monitor {
  name = DP-1
  temp_day = 6500
  temp_night = 3500
}

monitor {
  name = HDMI-1
  temp_day = 5500
  temp_night = 2700
}
```


Add to `hyprland.conf`:
```
exec-once = hyprsunset

# Temperature adjustment keybinds
bind = , XF86MonBrightnessUp, exec, hyprsunset-util -t +100
bind = , XF86MonBrightnessDown, exec, hyprsunset-util -t -100

# Manual mode keybinds
bind = SUPER, B, exec, hyprsunset-util -t 6500
bind = SUPER+SHIFT, B, exec, hyprsunset-util -t 3500
bind = ALT, B, exec, hyprsunset-util -toggle
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

