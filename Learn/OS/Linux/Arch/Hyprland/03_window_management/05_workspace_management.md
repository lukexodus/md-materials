## Workspace Management


Workspaces are virtual desktops organizing windows into logical groups independent of physical monitors. Each workspace maintains its own window arrangement, tiling layout, and focus state.[1][2]

### Workspace Creation and Navigation

Hyprland uses dynamic workspaces by default—workspaces are created automatically when first accessed. Empty workspaces disappear automatically when abandoned, maintaining a clean workspace list. Make workspaces persistent using `workspace = ID, persistent:true` in the configuration to prevent automatic cleanup.[2][1]

Access workspaces through numbered IDs (1-10) or custom names using `workspace = name:NAME`. Switch workspaces using dispatchers like `workspace 1`, `workspace name:myspace`, or cycle with `workspace +1/-1`.[1][2]

### Monitor-Workspace Binding

By default, workspaces are global—switching workspaces affects all monitors. Bind workspaces to specific monitors so switching only affects the active monitor:[1]

```
workspace = 1, monitor:DP-1
workspace = 2, monitor:DP-1
workspace = 3, monitor:DP-2
```


This configuration confines workspaces 1-2 to monitor DP-1 and workspace 3 to DP-2. When no binding exists, workspaces appear on the currently active monitor.[1]

### Named Workspaces

Create workspaces with descriptive names instead of numbers:[1]

```
workspace = name:code, monitor:DP-1
workspace = name:browser, monitor:DP-1
workspace = name:media, monitor:DP-2
```


Switch to named workspaces with `workspace name:code`. Mix numbered and named workspaces in the same session.[1]

### Layout Configuration Per-Workspace

Set default layout per-workspace using `layoutopt` rules:[2][1]

```
workspace = 1, layoutopt:dwindle:pseudotile:true
workspace = 2, layoutopt:master:orientation:top
```


This applies dwindle layout with pseudotiling on workspace 1 and master layout with top orientation on workspace 2.[1]

### Special Workspaces

Special workspaces are hidden overlay spaces accessed via `togglespecialworkspace` dispatcher, useful for scratchpad-like workflows. Move windows to special workspaces using `movetoworkspace special` or `movetoworkspace special:name`.[1]

Create named special workspaces:
```
bind = SUPER, S, togglespecialworkspace, magic
```


This creates and toggles a special workspace named "magic".[1]

### Workspace Rules

Apply window rules based on workspace:[3]

```
windowrulev2 = float, workspace:special
windowrulev2 = tile, workspace:1
windowrulev2 = float, workspace:name:floating
```


These rules float all windows in special workspaces, tile workspace 1, and float workspace "floating".[3]

### Gap Configuration Per-Workspace

Control workspace-specific gaps using `addreserved` monitor rules:[4]

```
monitor = DP-1, 1920x1080, 0x0, 1, addreserved, 50, 0, 0, 0
```


This adds 50 pixels top margin on DP-1 for panels or status bars.[4]

### Workspace Swallowing

Configure workspace behavior when windows change states using `nofocus`, `workspace`, and related window rules. When a window opens and swallows its parent, move it explicitly with `workspace rules`.[3]

### Dispatcher Commands

**workspace [ID/name]** switches to workspace by ID or name. **workspace [+/-]N** cycles forward/backward N workspaces. **movetoworkspace [ID/name]** moves focused window to workspace. **movetoworkspacesilent** moves without switching to the destination workspace.[1]

**renameworkspace [ID/name] [NEWNAME]** renames workspace at runtime. **focusworkspaceoncurrentmonitor [ID/name]** switches to workspace only on active monitor (respects monitor bindings).[1]

**movecurrentworkspacetomonitor [direction]** relocates active workspace to adjacent monitor specified by direction (l/r/u/d). **swapactiveworkspaces [MONITOR1] [MONITOR2]** exchanges workspaces between monitors.[1]

### Example Workspace Configuration

```
workspace = 1, monitor:DP-1, layoutopt:dwindle:pseudotile:false
workspace = 2, monitor:DP-1, layoutopt:master:orientation:left
workspace = 3, monitor:DP-2, layoutopt:dwindle:pseudotile:true

workspace = name:mail, monitor:DP-1, persistent:true
workspace = name:media, monitor:DP-2, persistent:true

workspace = special:scratchpad, on-created-empty:foot

bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER+SHIFT, 1, movetoworkspace, 1
bind = SUPER+SHIFT, 2, movetoworkspace, 2
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Hyprland workspace configuration - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=298652
[3] Window Rules https://wiki.hypr.land/Configuring/Window-Rules/
[4] Monitors https://wiki.hypr.land/Configuring/Monitors/

