## Window Rules 


### Syntax and Matching

The `windowrulev2` system provides **conditional configuration** applying specific settings to windows matching defined criteria. Rules use regex pattern matching against window properties, evaluated in order from top to bottom. Hyprland v0.46.0 onwards requires full regex matches—partial matches need explicit wildcard patterns like `.*pattern.*`.[1]

The syntax is `windowrulev2 = RULE, CONDITION [, CONDITION ...]`. Multiple conditions combine with commas, all requiring matches for the rule to apply.[1]

### Matching Criteria

**class:[RegEx]** matches window class (case-sensitive), obtained from application metadata[1]. Example: `class:firefox` or `class:(firefox|chromium)`[1].

**initialClass:[RegEx]** matches class at window creation, useful for applications that change their class dynamically.[1]

**title:[RegEx]** matches window title strings. Example: `title:.*Mozilla Firefox.*`.[1]

**initialTitle:[RegEx]** matches title at window creation.[1]

**xwayland** matches only XWayland windows (0 or 1).[1]

**floating:[0/1]** matches window floating state: 0 = tiled, 1 = floating.[1]

**focus:[0/1]** matches currently focused window: 0 = unfocused, 1 = focused.[1]

**workspace:[w]** matches specific workspace by ID or name; `workspace:[^special]` uses regex to exclude special workspaces. **workspacetext:[RegEx]** matches workspace name text.[1]

**fullscreen** matches fullscreen state (can be 0, 1, or 2 for fullscreen modes).[1]

**fullscreenmode** matches fullscreen mode specifically.[1]

**pinned** matches pinned windows.[1]

**modal** matches modal dialogs.[1]

**nofocus** ignores certain application windows when focusing.[1]

**type:[type]** matches window type: `normal`, `dialog`, `splash`, `notification`, `toolbar`.[1]

### Applied Rules

**float** makes matching windows floating. **tile** forces tiling (overrides float). **fullscreen** maximizes windows within their workspace. **fakefullscreen** simulates fullscreen without changing actual state.[1]

**pin** pins windows to all workspaces. **unpin** removes pin status.[1]

**nomaxsize** removes window size restrictions, allowing oversizing beyond screen boundaries. **maxsize W H** restricts window maximum size to W×H pixels. **minsize W H** enforces minimum window size.[1]

**size W H** sets exact window dimensions; useful for screenshots or specific workflows. **move X Y** positions floating windows at absolute screen coordinates; relative coordinates use `+X` or `-X`.[1]

**rounding [0/1]** disables window rounding when 0. **noblur** disables background blur for the window. **noshadow** removes window shadow.[1]

**noborder** removes window borders. **nodefaultsize** prevents automatic sizing from `initialSize` rules.[1]

**animation [NAME] [ONOFF] [SPEED] [CURVE] [STYLE]** applies custom animations; see animation syntax documentation. **noanim** disables animations.[1]

**opaque** makes transparent windows opaque. **forceinput** allows input to pass through certain visual areas (debugging tool).[1]

**center** centers floating windows on screen. **xray [0/1]** applies blur xray effect (see decoration blur settings).[1]

**dimaround** dims background using `dim_around` opacity. **dimmer [OPACITY]** dims window to specified opacity while leaving others normal.[1]

**focusonactivate** focuses window when activated by another client. **keepaspectratio** maintains window aspect ratio during resizing.[1]

**nearestneighbor** disables interpolation during window scaling (for pixel-perfect games).[1]

**group [SET]** assigns window to group when opening; use `SET` keywords like `new` (create new group), `current` (join active group), or group name.[1]

**stayfocused** keeps window focused despite focus-stealing attempts. **nofullscreenrequest** ignores fullscreen requests. **noinitialcursor** ignores cursor hint at window creation.[1]

**immediate** prevents window from requesting immediate focus after opening. **idleinhibit [RULE]** prevents idle state; options: `none`, `always`, `focus` (only when focused).[1]

**workspace [w/name]** moves window to specific workspace: `workspace 2`, `workspace name:myworkspace`, `workspace 1 silent` (silent prevents switching to workspace).[1]

**suppressevent [FLAGS]** suppresses certain events; flags: `maximize`, `activate`.[1]

**initialSize [WIDTH] [HEIGHT]** sets initial window size (Xwayland only). **initialPosition [X] [Y]** sets initial position.[1]

**opaque** forces complete opacity (ignores alpha). **isrendering** marks window as rendering constantly (disables idle detection).[1]

### Special Workspace Rules

**move [x, y]** moves windows within special workspaces. **special:name [w]** creates/targets named special workspaces. Special workspaces are hidden by default, accessed with `togglespecialworkspace`.[1]

### Example Window Rules

```
windowrulev2 = float, class:pavucontrol
windowrulev2 = float, class:nm-connection-editor
windowrulev2 = float, title:^(Open|Save) File

windowrulev2 = fullscreen, class:mpv
windowrulev2 = fullscreen, title:.*YouTube.*

windowrulev2 = move 100 100, class:alacritty
windowrulev2 = size 800 600, class:Thunar

windowrulev2 = workspace 2, class:firefox
windowrulev2 = workspace name:code, class:(code|codium)

windowrulev2 = tile, class:VLC
windowrulev2 = nofullscreenrequest, class:mpv

windowrulev2 = noinitialcursor, class:firefox
windowrulev2 = idleinhibit focus, class:mpv
```

Sources
[1] Window Rules https://wiki.hypr.land/Configuring/Window-Rules/

