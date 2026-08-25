## Hypridle (Idle Management)


Hypridle is Hyprland's native idle daemon monitoring user inactivity and triggering actions like screen locking, display blanking, and system suspension. It replaces external idle managers with tight compositor integration for efficient resource usage.[1][2]

### Installation and Setup

Install Hypridle on Arch Linux with `sudo pacman -S hypridle`. Start automatically on Hyprland launch by adding to `hyprland.conf`:[1]
```
exec-once = hypridle
```


### Configuration File

Hypridle uses `~/.config/hypridle/hypridle.conf` for configuration. Create this file if it doesn't exist.[1]

### General Settings

```
general {
  lock_cmd = hyprlock
  unlock_cmd = notify-send "Unlocked"
  before_sleep_cmd = notify-send "Going to sleep"
  after_sleep_cmd = notify-send "Waking up"
  ignore_systemd_inhibit = false
}
```


**lock_cmd** specifies the command to run when locking (typically `hyprlock`). **unlock_cmd** runs after unlock (optional, useful for notifications). **before_sleep_cmd** runs before system sleep via systemd suspend/hibernate. **after_sleep_cmd** runs after system wakes up. **ignore_systemd_inhibit** when true, ignores systemd sleep inhibitors (applications preventing sleep), defaulting to false (respects inhibitors).[1]

### Idle Listeners

Define timeout-based actions with `listener` blocks:[1]

```
listener {
  timeout = 300
  on-timeout = notify-send "Idle for 5 minutes"
  on-resume = notify-send "User active"
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


**timeout** is inactivity duration in seconds before triggering (300 = 5 minutes). **on-timeout** command runs after timeout expires. **on-resume** (optional) runs when user becomes active again after idle.[1]

### Lock Screen Actions

Lock the screen after inactivity:[1]
```
listener {
  timeout = 600
  on-timeout = hyprlock
}
```


This locks after 10 minutes of inactivity.[1]

### Display Blanking

Turn off displays using DPMS (Display Power Management Signaling):[2][1]
```
listener {
  timeout = 600
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}
```


**dpms off** disables displays (saves power). **dpms on** re-enables displays when activity resumes. This activates before locking for efficiency.[1]

### System Suspension and Hibernation

Suspend the system after extended inactivity:[1]
```
listener {
  timeout = 1200
  on-timeout = systemctl suspend
}

listener {
  timeout = 1800
  on-timeout = systemctl hibernate
}
```


The first suspends after 20 minutes, the second hibernates after 30 minutes. Adjust timeouts based on power management preferences.[1]

### Notifications and Warnings

Provide user warnings before major actions:[1]
```
listener {
  timeout = 540
  on-timeout = notify-send --urgency=critical "Lock screen in 60 seconds"
}

listener {
  timeout = 600
  on-timeout = hyprlock
}

listener {
  timeout = 840
  on-timeout = notify-send --urgency=critical "System suspending in 60 seconds"
}

listener {
  timeout = 900
  on-timeout = systemctl suspend
}
```


These warn at 9 and 14 minutes before locking and suspending at 10 and 15 minutes respectively.[1]

### Inhibiting Sleep for Specific Applications

Applications can request sleep inhibition via systemd; Hypridle respects these by default. Video players and other long-running tasks automatically prevent sleep.[1]

Override inhibition with `ignore_systemd_inhibit = true` to force sleep regardless:[1]
```
general {
  ignore_systemd_inhibit = true
}
```


### Resume Commands

Execute commands when user becomes active:[1]
```
listener {
  timeout = 600
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on && notify-send "Screen reactivated"
}
```


### Multi-Command Actions

Execute multiple commands by chaining with `&&` or using scripts:[1]
```
listener {
  timeout = 600
  on-timeout = hyprctl dispatch dpms off && notify-send "Entering sleep mode"
}
```


Or reference shell scripts:[1]
```
listener {
  timeout = 600
  on-timeout = ~/.config/hypridle/scripts/sleep.sh
}
```


### Debugging and Logging

Check Hypridle status with `systemctl --user status hypridle`. View logs with `journalctl --user -u hypridle -f`.[1]

Enable verbose logging by modifying the configuration or restarting with debug flags (if supported).[1]

### Integration with Hyprlock and Display Management

Typical workflow combines multiple actions:[1]
```
listener {
  timeout = 120
  on-timeout = notify-send "Idle warning"
  on-resume = notify-send "Activity detected"
}

listener {
  timeout = 300
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}

listener {
  timeout = 600
  on-timeout = hyprlock
}

listener {
  timeout = 1200
  on-timeout = systemctl suspend
}
```


This provides warnings, dims displays after 5 minutes, locks after 10 minutes, and suspends after 20 minutes.[1]

### Example Comprehensive Hypridle Configuration

```
general {
  lock_cmd = hyprlock
  unlock_cmd = notify-send "Unlocked successfully"
  before_sleep_cmd = notify-send "Suspending..."
  after_sleep_cmd = notify-send "Resuming..."
  ignore_systemd_inhibit = false
}

# Warning notification
listener {
  timeout = 540
  on-timeout = notify-send --urgency=critical --expire-time=60000 "Locking screen in 60 seconds"
}

# Lock screen
listener {
  timeout = 600
  on-timeout = hyprlock
}

# Display off (before suspension warning)
listener {
  timeout = 840
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}

# Suspension warning
listener {
  timeout = 840
  on-timeout = notify-send --urgency=critical "System suspending in 60 seconds"
}

# System suspend
listener {
  timeout = 900
  on-timeout = systemctl suspend
}

# System hibernate (optional)
listener {
  timeout = 1800
  on-timeout = systemctl hibernate
}
```


Add to `hyprland.conf`:
```
exec-once = hypridle
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

