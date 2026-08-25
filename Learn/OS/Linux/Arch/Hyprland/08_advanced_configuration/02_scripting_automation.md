## Scripting & Automation


Scripting enables advanced automation workflows combining Hyprland features, system utilities, and custom logic for complex tasks. Shell scripts, Lua, and Python provide flexible automation options.[1][2]

### Shell Scripts Fundamentals

Create shell scripts for Hyprland automation in `~/.config/hypr/scripts/`:[1]

**~/.config/hypr/scripts/example.sh:**
```bash
#!/bin/bash
# Example automation script

# Get active workspace
WORKSPACE=$(hyprctl activeworkspace -j | jq '.id')

# Count windows on workspace
WINDOW_COUNT=$(hyprctl clients -j | jq "map(select(.workspace.id == $WORKSPACE)) | length")

# Notify user
notify-send "Workspace $WORKSPACE" "Contains $WINDOW_COUNT windows"
```


Make executable:[1]
```bash
chmod +x ~/.config/hypr/scripts/example.sh
```


### Script Binding to Keybinds

Execute scripts from keybinds:[1]
```
bind = SUPER, E, exec, ~/.config/hypr/scripts/example.sh
```


### Workspace Automation

Auto-organize applications to specific workspaces:[1]

**~/.config/hypr/scripts/organize-workspace.sh:**
```bash
#!/bin/bash
# Move applications to designated workspaces

case $1 in
  "web")
    hyprctl dispatch workspace name:web
    ;;
  "code")
    hyprctl dispatch workspace name:code
    ;;
  "media")
    hyprctl dispatch workspace name:media
    ;;
esac
```


Bind to keybinds:[1]
```
bind = SUPER, 1, exec, ~/.config/hypr/scripts/organize-workspace.sh web
bind = SUPER, 2, exec, ~/.config/hypr/scripts/organize-workspace.sh code
bind = SUPER, 3, exec, ~/.config/hypr/scripts/organize-workspace.sh media
```


### Window Layout Automation

Automatically tile windows in specific layouts:[1]

**~/.config/hypr/scripts/auto-layout.sh:**
```bash
#!/bin/bash
# Arrange windows in custom layout

FOCUSED=$(hyprctl activewindow -j | jq -r '.address')

# Cascade windows
OFFSET=20
WINDOWS=$(hyprctl clients -j | jq -r '.[] | .address')

for WINDOW in $WINDOWS; do
  hyprctl dispatch movewindowpixel $OFFSET $OFFSET address:$WINDOW
  OFFSET=$((OFFSET + 20))
done
```


### Monitor-Based Workspace Switching

Script intelligent workspace navigation across monitors:[1]

**~/.config/hypr/scripts/focus-next-monitor.sh:**
```bash
#!/bin/bash
# Cycle focus to next monitor

CURRENT_MONITOR=$(hyprctl activemonitor -j | jq -r '.name')
MONITORS=$(hyprctl monitors -j | jq -r '.[].name')

# Find next monitor
NEXT=0
for MONITOR in $MONITORS; do
  if [ "$MONITOR" = "$CURRENT_MONITOR" ]; then
    NEXT=1
    continue
  fi
  if [ $NEXT -eq 1 ]; then
    hyprctl dispatch focusmonitor $MONITOR
    return 0
  fi
done

# Wrap to first monitor
FIRST=$(echo "$MONITORS" | head -1)
hyprctl dispatch focusmonitor $FIRST
```


### Conditional Window Operations

Execute different actions based on window properties:[1]

**~/.config/hypr/scripts/smart-move.sh:**
```bash
#!/bin/bash
# Move window intelligently based on class

FOCUSED_CLASS=$(hyprctl activewindow -j | jq -r '.class')

case $FOCUSED_CLASS in
  "firefox"|"chromium")
    hyprctl dispatch movetoworkspace 1
    ;;
  "code"|"nvim")
    hyprctl dispatch movetoworkspace 2
    ;;
  "discord"|"slack")
    hyprctl dispatch movetoworkspace 3
    ;;
  *)
    hyprctl dispatch movetoworkspace 4
    ;;
esac
```


Bind to keybinds:[1]
```
bind = SUPER+M, E, exec, ~/.config/hypr/scripts/smart-move.sh
```


### Time-Based Automation

Execute tasks at specific times:[1]

**~/.config/hypr/scripts/schedule-tasks.sh:**
```bash
#!/bin/bash
# Schedule tasks based on time of day

HOUR=$(date +%H)

if [ $HOUR -lt 12 ]; then
  hyprctl keyword decoration:blur_passes 3  # Light blur morning
elif [ $HOUR -lt 18 ]; then
  hyprctl keyword decoration:blur_passes 2  # Medium blur afternoon
else
  hyprsunset-util -t 3500  # Night mode evening
  hyprctl keyword decoration:blur_passes 1  # Heavy blur night
fi

notify-send "Schedule" "Applied settings for hour $HOUR"
```


Add to autostart with systemd timer:[1]
```
exec-once = watch -n 300 ~/.config/hypr/scripts/schedule-tasks.sh
```


### System Resource Monitoring

Monitor and respond to system state changes:[1]

**~/.config/hypr/scripts/monitor-resources.sh:**
```bash
#!/bin/bash
# Adjust Hyprland based on CPU/memory usage

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
MEM_USAGE=$(free | grep Mem | awk '{print int($3/$2 * 100)}')

if [ $CPU_USAGE -gt 80 ] || [ $MEM_USAGE -gt 80 ]; then
  # Reduce animations and effects under load
  hyprctl keyword animation:enabled false
  hyprctl keyword decoration:blur:enabled false
  notify-send "Performance" "Reduced effects due to high resource usage"
else
  # Restore effects under normal load
  hyprctl keyword animation:enabled true
  hyprctl keyword decoration:blur:enabled true
fi
```


### Workspace Quick Switch

Cycle through workspaces with keybind:[1]

**~/.config/hypr/scripts/cycle-workspace.sh:**
```bash
#!/bin/bash
# Cycle to next/previous workspace

CURRENT=$(hyprctl activeworkspace -j | jq '.id')
TOTAL=$(hyprctl workspaces -j | jq 'max_by(.id) | .id')

if [ "$1" = "next" ]; then
  NEXT=$((CURRENT + 1))
  [ $NEXT -gt $TOTAL ] && NEXT=1
else
  NEXT=$((CURRENT - 1))
  [ $NEXT -lt 1 ] && NEXT=$TOTAL
fi

hyprctl dispatch workspace $NEXT
```


Bind to keybinds:[1]
```
bind = SUPER, Tab, exec, ~/.config/hypr/scripts/cycle-workspace.sh next
bind = SUPER+SHIFT, Tab, exec, ~/.config/hypr/scripts/cycle-workspace.sh prev
```


### Window Stacking Automation

Organize windows in specific stacking orders:[1]

**~/.config/hypr/scripts/stack-windows.sh:**
```bash
#!/bin/bash
# Stack all windows in current workspace

WORKSPACE=$(hyprctl activeworkspace -j | jq '.id')
WINDOWS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $WORKSPACE) | .address")

for WINDOW in $WINDOWS; do
  hyprctl dispatch movewindow u address:$WINDOW
done

notify-send "Stack" "Windows stacked in current workspace"
```


### Python Scripting

Use Python for complex automation:[1]

**~/.config/hypr/scripts/automation.py:**
```python
#!/usr/bin/env python3
import json
import subprocess
import time

def run_hyprctl(cmd):
    result = subprocess.run(f"hyprctl {cmd}", shell=True, capture_output=True, text=True)
    return result.stdout

def get_active_workspace():
    output = run_hyprctl("activeworkspace -j")
    return json.loads(output)['id']

def get_window_count():
    output = run_hyprctl("clients -j")
    return len(json.loads(output))

def main():
    workspace = get_active_workspace()
    count = get_window_count()
    print(f"Workspace {workspace}: {count} windows")

if __name__ == "__main__":
    main()
```


Make executable and bind:[1]
```bash
chmod +x ~/.config/hypr/scripts/automation.py
```


```
bind = SUPER, P, exec, ~/.config/hypr/scripts/automation.py
```


### Error Handling in Scripts

Implement robust error handling:[1]

**~/.config/hypr/scripts/safe-script.sh:**
```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

trap 'notify-send "Error" "Script failed at line $LINENO"' ERR

# Safe script operations
if hyprctl dispatch workspace 1; then
  notify-send "Success" "Workspace switched"
else
  notify-send "Error" "Failed to switch workspace"
  exit 1
fi
```


### Systemd Service Integration

Create systemd services for persistent automation:[1]

**~/.config/systemd/user/hyprland-automation.service:**
```ini
[Unit]
Description=Hyprland Automation Service
After=graphical-session-pre.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=%h/.config/hypr/scripts/automation-daemon.sh
Restart=on-failure

[Install]
WantedBy=graphical-session.target
```


Enable with:[1]
```bash
systemctl --user enable hyprland-automation.service
```


### Example Comprehensive Automation Configuration

Add to `hyprland.conf`:
```
# Automation scripts
bind = SUPER, A, exec, ~/.config/hypr/scripts/organize-workspace.sh web
bind = SUPER+SHIFT, A, exec, ~/.config/hypr/scripts/smart-move.sh
bind = SUPER, Tab, exec, ~/.config/hypr/scripts/cycle-workspace.sh next
bind = SUPER+SHIFT, Tab, exec, ~/.config/hypr/scripts/cycle-workspace.sh prev

# Time-based automation
exec-once = watch -n 300 ~/.config/hypr/scripts/schedule-tasks.sh
exec-once = watch -n 60 ~/.config/hypr/scripts/monitor-resources.sh

# Systemd service
exec-once = systemctl --user start hyprland-automation.service
```


Comprehensive scripting unlocks Hyprland's full potential for personalized, automated workflows.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

