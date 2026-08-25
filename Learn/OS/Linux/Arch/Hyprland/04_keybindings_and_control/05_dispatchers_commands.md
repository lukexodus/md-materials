## Dispatchers & Commands


Dispatchers are actions executed by keybinds, executed through `hyprctl dispatch`, or triggered by other events. They control window behavior, workspace navigation, layout switching, and system integration.[1][2]

### Window Management Dispatchers

**killactive** closes the currently focused window without saving. **closewindow [PID]** closes a specific window by process ID. **togglefloating** switches the focused window between tiling and floating modes. **togglefloating passive** toggles floating without changing focus direction.[2]

**togglesticky** makes floating windows sticky, displaying them on all workspaces. **togglesplit** swaps window split orientation (horizontal/vertical) when `preserve_split` is enabled. **movecursor [X] [Y]** moves the cursor to absolute screen coordinates.[2]

**centerwindow [MODE]** centers floating windows: `0` (default, both axes), `1` (horizontal only), `2` (vertical only).[2]

### Focus and Navigation

**movefocus [DIRECTION]** moves focus in specified direction: `l` (left), `r` (right), `u` (up), `d` (down). **focuswindow [WINDOW_ID]** focuses a specific window by ID. **focusmonitor [DIRECTION/MONITOR]** switches focus to adjacent or named monitor. **cyclenext** focuses the next window in tiling order. **cycleprev** focuses the previous window.[2]

**focuscurrentorlast** focuses most recently active window if current is unfocused, or current window if already focused.[2]

### Window Movement and Resizing

**movewindow [DIRECTION]** moves tiled windows within their container or relocates floating windows. **resizewindow [DIRECTION] [AMOUNT]** resizes floating windows; amount can be absolute pixels or percentage (e.g., `10%`). **swapwindow [DIRECTION/WINDOW_ID]** exchanges positions with adjacent or specified windows.[2]

**swapactive [DIRECTION]** swaps focused window with neighbor without moving focus. **movetoworkspace [WORKSPACE/DIRECTION]** relocates focused window to target workspace. **movetoworkspacesilent** moves window without switching to destination workspace.[2]

**pin** makes windows visible on all workspaces. **unpin** removes pin status.[2]

### Fullscreen and Maximize

**fullscreen [0/1/2/3]** toggles fullscreen modes: `0` (toggle), `1` (fullscreen), `2` (fullscreen without panels), `3` (maximized in-place). **fakefullscreen [0/1]** simulates fullscreen without actual state change.[2]

### Workspace Dispatchers

**workspace [ID/NAME/DIRECTION]** switches to workspace by ID, name, or directional offset (`+1`, `-1`). **workspaceopt [OPTION] [VALUE]** modifies workspace options at runtime. **renameworkspace [ID/NAME] [NEWNAME]** renames workspace. **focusworkspaceoncurrentmonitor [ID/NAME]** switches workspace only on active monitor, respecting bindings.[2]

**movecurrentworkspacetomonitor [DIRECTION/MONITOR]** relocates active workspace to adjacent or named monitor. **swapactiveworkspaces [MONITOR1] [MONITOR2]** exchanges workspaces between monitors.[2]

### Layout and Tiling

**togglesplit** swaps split orientation (dwindle only). **layoutmsg [MESSAGE] [PARAMS]** sends layout-specific messages. Available messages depend on layout: dwindle supports `preselect`, `togglesplit`, `swapsplit`, `movetoroot`; master supports `swapwithmaster`, `focusmaster`, `cyclenext`, `addmaster`, `removemaster`, `orientationleft/right/top/bottom`.[3][4][2]

**togglegroup** creates groups or removes focused window from group. **changegroupactive [f/b]** cycles group members forward or backward. **movewindowtogroupid [ID]** moves window to specific group.[3]

### Input and Binding

**pass [WINDOW_CLASS_REGEX]** sends key/mouse events directly to specified applications without Hyprland processing. **sendshortcut [MOD] [KEY] [WINDOW_CLASS_REGEX]** sends keyboard shortcut to application.[1][2]

### Submap and Mode Switching

**submap enter [NAME]** activates a keybind submap (custom input mode). **submap leave** exits current submap. Submaps allow context-specific keybinds; for example, entering resize mode with unique bindings. **keybind submap** syntax: `bind = MOD, KEY, submap, enter resizeMode` then define bindings within that context.[2]

### Animation and Effects

**ani [ANIMATION_NAME] [SPEED] [CURVE]** animates window properties. **toggleopaque** toggles window opacity between normal and fully opaque.[2]

### Executing External Commands

**exec [COMMAND]** runs shell commands; useful for launching applications, scripts, or system utilities. **execshellcmd [COMMAND]** executes commands with shell expansion. **execonce [COMMAND]** executes command only once per session.[2]

### System Control

**exit** closes Hyprland session. **reload** reloads configuration and restarts compositor. **dpms [on/off/toggle]** controls monitor power state.[2]

### Debugging and Information

**hyprctl** commands query and modify Hyprland state at runtime without reloading config. Examples: `hyprctl dispatch workspace 1`, `hyprctl monitors`, `hyprctl clients`, `hyprctl keyword general:gaps_in 10`.[2]

### Dispatcher Execution Methods

Execute dispatchers through keybinds in config:
```
bind = SUPER, Q, killactive
bind = SUPER, F, fullscreen, 1
```


Execute at runtime via `hyprctl dispatch`:
```bash
hyprctl dispatch workspace 2
hyprctl dispatch movewindow l
hyprctl dispatch exec kitty
```


Execute via shell scripts in `exec-once` or `exec`:
```
exec-once = hyprctl dispatch workspace 1
exec = hyprctl keyword general:gaps_in 15
```


### Example Dispatcher Configuration

```
# Window management
bind = SUPER, Q, killactive
bind = SUPER, SPACE, togglefloating
bind = SUPER, P, pin
bind = SUPER, F, fullscreen, 1

# Focus
bind = SUPER, Left, movefocus, l
bind = SUPER, Right, movefocus, r
bind = SUPER, Up, movefocus, u
bind = SUPER, Down, movefocus, d

# Window movement
bind = SUPER+SHIFT, Left, swapwindow, l
bind = SUPER+SHIFT, Right, swapwindow, r
bind = SUPER+SHIFT, H, resizewindow, l 30
bind = SUPER+SHIFT, L, resizewindow, r 30

# Workspace
bind = SUPER, 1, workspace, 1
bind = SUPER+SHIFT, 1, movetoworkspace, 1
bind = SUPER, Tab, workspace, +1

# Layout
bind = SUPER, E, togglesplit
bind = SUPER, G, togglegroup
bind = SUPER, M, layoutmsg, swapwithmaster

# Applications
bind = SUPER, RETURN, exec, kitty
bind = SUPER, D, exec, rofi -show drun

# System
bind = SUPER, L, exec, swaylock
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
```

Sources
[1] Binds https://wiki.hypr.land/Configuring/Binds/
[2] Dispatchers https://wiki.hyprland.org/0.41.0/Configuring/Dispatchers/
[3] Dwindle Layout https://wiki.hypr.land/Configuring/Dwindle-Layout/
[4] Master Layout https://wiki.hypr.land/Configuring/Master-Layout/
[5] Binds | Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Configuring/Binds/


