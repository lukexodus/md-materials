## Hyprctl & IPC


Hyprctl is the command-line interface for interacting with Hyprland, enabling runtime configuration changes, querying compositor state, and triggering dispatchers without reloading the entire session. IPC (Inter-Process Communication) provides programmatic access to Hyprland's state and events.[1][2]

### Hyprctl Basic Usage

Query Hyprland state with `hyprctl`:[1]
```bash
hyprctl monitors        # List connected monitors and their properties
hyprctl clients         # List open windows with details
hyprctl workspaces      # List workspaces and their status
hyprctl dispatch        # Execute dispatchers
hyprctl keyword         # Modify config variables at runtime
```


### Querying Monitors

Display connected monitors with configuration:[1]
```bash
hyprctl monitors
```


Output example:[1]
```
Monitor DP-1 (ID 0)
	1920x1080@144.00 at 0x0
	Description: Dell Inc. DELL S2721DGF
	Active workspace: 1
	Special workspace: (empty)
```


Query specific monitor properties:[1]
```bash
hyprctl monitors all     # Includes disabled monitors
hyprctl monitors -j      # JSON output for scripting
```


### Querying Windows and Clients

List all open windows:[1]
```bash
hyprctl clients
```


Output shows window ID, class, title, and properties.[1]

Get focused window information:[1]
```bash
hyprctl activewindow
```


Query specific client:[1]
```bash
hyprctl clients | grep -A 5 "class: Firefox"
```


### Querying Workspaces

List all workspaces:[1]
```bash
hyprctl workspaces
```


Output includes workspace ID, name, and monitor assignment.[1]

Get active workspace:[1]
```bash
hyprctl activeworkspace
```


### Dispatchers via Hyprctl

Execute window management commands:[1]
```bash
hyprctl dispatch workspace 1      # Switch to workspace 1
hyprctl dispatch movewindow u     # Move window up
hyprctl dispatch togglefloating   # Toggle floating mode
hyprctl dispatch killactive       # Close focused window
```


### Runtime Configuration Changes

Modify variables without reloading config:[1]
```bash
hyprctl keyword general:gaps_in 10
hyprctl keyword general:gaps_out 20
hyprctl keyword decoration:rounding 15
hyprctl keyword input:kb_layout us
```


Changes persist until next reload or config modification.[1]

### JSON Output for Scripting

Query state in JSON format for programmatic access:[1]
```bash
hyprctl monitors -j | jq '.[] | {name: .name, width: .width, height: .height}'
hyprctl workspaces -j | jq '.[] | {id: .id, name: .name, windows: .windows}'
hyprctl clients -j | jq '.[] | {title: .title, class: .class, workspace: .workspace}'
```


### IPC Socket Location

Hyprland creates an IPC socket at:[1]
```
$XDG_RUNTIME_DIR/hyprland/$HYPRLAND_INSTANCE_SIGNATURE
```


Default: `/run/user/1000/hyprland/instance1`.[1]

### Socket-Based IPC Communication

Send commands directly to IPC socket:[1]
```bash
echo "dispatch workspace 2" | socat - UNIX-CONNECT:$XDG_RUNTIME_DIR/hyprland/$HYPRLAND_INSTANCE_SIGNATURE
```


Use `socat` for raw socket communication.[1]

### Scripting with Hyprctl

Create scripts using hyprctl output:[1]

**~/.config/hypr/scripts/window-counter.sh:**
```bash
#!/bin/bash
TOTAL=$(hyprctl clients -j | jq 'length')
echo "Open windows: $TOTAL"
```


Make executable and bind to keybind:[1]
```
bind = SUPER, W, exec, ~/.config/hypr/scripts/window-counter.sh
```


### Monitor-Based Workspace Switching

Script workspace navigation per monitor:[1]
```bash
#!/bin/bash
MONITOR=$(hyprctl activemonitor -j | jq -r '.name')
echo "Active monitor: $MONITOR"
# Implement monitor-specific workspace logic
```


### Conditional Dispatchers

Execute dispatcher based on window properties:[1]
```bash
#!/bin/bash
FOCUSED=$(hyprctl activewindow -j | jq -r '.class')
if [[ $FOCUSED == "firefox" ]]; then
  hyprctl dispatch movetoworkspace 2
else
  hyprctl dispatch movetoworkspace 1
fi
```


### Cursor Position and Pointer

Query mouse cursor position:[1]
```bash
hyprctl cursorpos
```


Output: `1920, 1080`.[1]

### Hyprctl Batch Operations

Execute multiple commands:[1]
```bash
hyprctl dispatch workspace 1
hyprctl dispatch movewindow l
hyprctl dispatch resizewindow exact 800 600
```


Or combine in single call:[1]
```bash
hyprctl --batch "dispatch workspace 1 ; dispatch movewindow l ; dispatch resizewindow exact 800 600"
```


### Event Monitoring with Socat

Monitor Hyprland events in real-time:[1]
```bash
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hyprland/$HYPRLAND_INSTANCE_SIGNATURE
```


Events stream when windows open/close, focus changes, etc..[1]

### Examples: Practical Scripts

**Window Counter Notification:**
```bash
#!/bin/bash
COUNT=$(hyprctl clients -j | jq 'length')
notify-send "Windows" "Currently open: $COUNT"
```


Bind to keybind:[1]
```
bind = SUPER, I, exec, ~/.config/hypr/scripts/window-count.sh
```


**Workspace Info Display:**
```bash
#!/bin/bash
WORKSPACE=$(hyprctl activeworkspace -j | jq '.id')
WINDOWS=$(hyprctl clients -j | jq "map(select(.workspace.id == $WORKSPACE)) | length")
notify-send "Workspace $WORKSPACE" "Contains $WINDOWS windows"
```


**Focus Automation:**
```bash
#!/bin/bash
# Switch to workspace with Firefox if open
WORKSPACE=$(hyprctl clients -j | jq -r '.[] | select(.class == "firefox") | .workspace.id' | head -1)
if [ -n "$WORKSPACE" ]; then
  hyprctl dispatch workspace $WORKSPACE
else
  notify-send "Firefox" "Not running"
fi
```


### Hyprctl Help and Documentation

View all available commands:[1]
```bash
hyprctl help
hyprctl help dispatchers
hyprctl help keywords
```


List all available keywords and dispatchers.[1]

### Example Comprehensive Hyprctl Configuration

Add to `hyprland.conf`:
```
# Keybinds using hyprctl scripts
bind = SUPER, I, exec, ~/.config/hypr/scripts/window-info.sh
bind = SUPER+SHIFT, I, exec, ~/.config/hypr/scripts/workspace-info.sh
bind = ALT, Tab, exec, ~/.config/hypr/scripts/smart-focus.sh

# Runtime config changes
bind = SUPER+CTRL, G, exec, hyprctl keyword general:gaps_in 5 && notify-send "Gaps set to 5"
bind = SUPER+CTRL+SHIFT, G, exec, hyprctl keyword general:gaps_in 0 && notify-send "Gaps disabled"

# Monitor info
bind = SUPER, M, exec, hyprctl monitors | wofi --dmenu --prompt "Monitors"
```


Create `~/.config/hypr/scripts/window-info.sh`:
```bash
#!/bin/bash
hyprctl clients -j | jq -r '.[] | "\(.title) (\(.class))"' | wofi --dmenu --prompt "Windows"
```


Hyprctl enables powerful automation and runtime customization without reloading Hyprland, making it essential for advanced workflows.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

