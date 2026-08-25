## DPMS Control


DPMS ("Display Power Management Signaling") enables Hyprland to manage the power state of monitors, allowing automated or manual screen blanking to save energy and extend display lifespan. DPMS actions can be triggered by idle daemons, keybinds, or scripts for flexible workflows.[1]

### Manual DPMS Toggle

Use the `dpms` dispatcher for immediate control:
```
hyprctl dispatch dpms off       # Turns off all monitors (blanks screens)
hyprctl dispatch dpms on        # Turns all monitors back on
hyprctl dispatch dpms toggle    # Toggles current state
```


Bind directly in `hyprland.conf`:
```
bind = SUPER, F8, exec, hyprctl dispatch dpms off
bind = SUPER+SHIFT, F8, exec, hyprctl dispatch dpms on
bind = SUPER, F9, exec, hyprctl dispatch dpms toggle
```
- Useful for temporarily blanking the screen (privacy, quick sleep).

### Per-Monitor DPMS

Control DPMS by monitor (Hyprland v0.38+):
```
hyprctl dispatch dpms off HDMI-1
hyprctl dispatch dpms on DP-1
```
- Specify output port name as listed by `hyprctl monitors` for targeted power control.[1]

### DPMS via Hypridle (Idle Daemon)

Automate DPMS with inactivity listeners:
```
listener {
  timeout = 600        # 10 minutes
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}
```
- Screen blanks after 10 minutes, resumes on input event.[1]

### DPMS and Session Lock

Combine with screen lock daemon for security:
```
listener {
  timeout = 660        # 11 minutes
  on-timeout = hyprlock
}
listener {
  timeout = 600        # 10 minutes
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}
```
- Blank monitors just before lock; input reactivates and triggers lock-screen for password.[1]

### Scripting DPMS

Quick scripts for more advanced DPMS:
**Toggle only external displays:**
```bash
for MON in $(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .name'); do
  hyprctl dispatch dpms off $MON
done
```
Bind to a key or call from Hyprland automation.[1]

### DPMS for All Monitors

Use `auto` keyword:
```
hyprctl dispatch dpms off auto
hyprctl dispatch dpms on auto
```


### DPMS Troubleshooting

- **DPMS not working:** Verify output names and kernel driver support; not all HDMI or DisplayPort adapters support DPMS under Wayland.[1]
- **Delayed resume:** If monitors take long to power on, check display firmware and connection quality.[1]
- **Screens do not blank:** Ensure DPMS is enabled and that user input (mouse, touchpad, keyboard) does not interfere with the idle timeout.

### Example DPMS Integration

Add to `hyprland.conf` and `hypridle.conf`:
```
# Immediate DPMS control
bind = SUPER, F8, exec, hyprctl dispatch dpms off
bind = SUPER, F9, exec, hyprctl dispatch dpms toggle

# Per-monitor control
bind = SUPER+SHIFT, F8, exec, hyprctl dispatch dpms off DP-1
bind = SUPER+SHIFT, F9, exec, hyprctl dispatch dpms on HDMI-1

# Idle daemon automation
listener {
  timeout = 600
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}
```


DPMS controls in Hyprland provide robust and granular power management that can be automated or manually triggered, essential for both desktop and laptop workflows.

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland

