## Power Management


Hyprland integrates power management features for battery monitoring, sleep/suspend/hibernate, display blanking, and system resource control, often using Wayland-native daemons and keybinds for full automation.[1]

### System Sleep, Suspend, and Hibernate

Use `systemctl` for system power state changes:
```
bind = SUPER, S, exec, systemctl suspend
bind = SUPER+SHIFT, S, exec, systemctl hibernate
bind = SUPER, P, exec, systemctl poweroff
bind = SUPER+SHIFT, P, exec, systemctl reboot
```
- Sleep (suspend): RAM powered, work resumes instantly.[1]
- Hibernate: RAM saved to disk, powers down completely.[1]
- Poweroff/reboot: Standard system shutdowns.

### Idle and Screen Blank Control

**Hypridle** handles all idle-related power actions with custom listeners:
```
exec-once = hypridle
```
Configure `/~/.config/hypridle/hypridle.conf`:
```
general {
  lock_cmd = hyprlock
  before_sleep_cmd = notify-send "System will sleep"
  after_sleep_cmd = notify-send "System woke up"
}

listener {
  timeout = 600
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}

listener {
  timeout = 1200
  on-timeout = systemctl suspend
}
```
- **DPMS off/on** blanks/unblanks displays after X seconds of inactivity (saves battery).
- System suspends after Y seconds, all via customizable timeouts.

### Battery Status and Monitoring

Waybar battery module displays live battery stats:
```json
"battery": {
  "format": "🔋 {capacity}%",
  "states": { "warning": 25, "critical": 10 },
  "format-charging": "⚡ {capacity}%"
}
```
- Supports notifications and urgent status when battery is low.[1]

Use `upower` for command-line battery info:
```bash
upower -i /org/freedesktop/UPower/devices/battery_BAT0
```
- Automate battery warnings with scripts:
```bash
#!/bin/bash
LEVEL=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}' | tr -d '%')
if [ "$LEVEL" -le 10 ]; then
  notify-send --urgency=critical "Battery Critical" "Plug in your charger!"
fi
```
Bind to periodic task or idle daemon.[1]

### Display Brightness

Adjust using `brightnessctl` and keybinds:
```
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
```
- Works for internal screens, some external monitors, and keyboard backlights.[1]

### Lid Events & Power Button

Systemd handles lid/ACPI/power-button events via `/etc/systemd/logind.conf`:
- `HandleLidSwitch=suspend`
- `HandlePowerKey=poweroff`
No need to configure separately for Hyprland unless overriding system defaults.

### Automatic Dimming/Night Mode

Combine with **Hyprsunset** for blue light reduction:
```
exec-once = hyprsunset
```
Configure color temperature and day/night profiles in `~/.config/hyprsunset/hyprsunset.conf`.

### Swayidle Alternative

`swayidle` is an alternative idle management daemon:
```
exec-once = swayidle -w timeout 900 'systemctl suspend' timeout 600 'hyprctl dispatch dpms off'
```
- Triggers suspend, screen blanking, or lock after inactivity.[1]

### System Resource Control

Reduce compositing load on battery:
```bash
hyprctl keyword animations:enabled false
hyprctl keyword decoration:blur:enabled false
hyprctl keyword general:vsync false
```
Bind to a key or script, or trigger on battery threshold via cron/hypridle.[1]

### Audio Power Saving

PulseAudio/PipeWire can suspend audio sinks on idle:
- Enable module in `/etc/pulse/default.pa` or PipeWire equivalent:
  ```
  load-module module-suspend-on-idle
  ```
Helps reduce battery use on laptops, especially with Bluetooth devices.

### Example Power Management Configuration

```ini
# IDLE/Power management
exec-once = hypridle

bind = SUPER, S, exec, systemctl suspend
bind = SUPER+SHIFT, S, exec, systemctl hibernate
bind = SUPER, P, exec, systemctl poweroff

bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

exec-once = hyprsunset

# Battery warning script integration
exec-once = watch -n 60 ~/.config/hypr/scripts/battery-warning.sh
```


Hyprland supports robust power management through compositing features, systemd, Wayland-native daemons, and full scripting/automation integration for any workflow.

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland

