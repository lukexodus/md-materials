## Gestures & Touchpad


### Touchpad Gestures Configuration

Hyprland supports gesture-based input through the `gestures` section, enabling multi-finger swipes and taps for navigation and window control. Gestures work on touchpads and touchscreens, providing alternative input methods to keyboard and mouse.[1]

### Swipe Gestures

**Workspace swiping** cycles between workspaces using horizontal swipes. Configure with:[1]
```
gestures {
  workspace_swipe = true
  workspace_swipe_fingers = 3
  workspace_swipe_distance = 300
  workspace_swipe_invert = false
  workspace_swipe_min_speed_to_force = 30
  workspace_swipe_cancel_ratio = 0.5
}
```


**workspace_swipe** enables/disables the feature (default false). **workspace_swipe_fingers** sets the required number of fingers (typically 3 or 4, default 3). **workspace_swipe_distance** is the minimum swipe distance in pixels before triggering workspace change (default 300). **workspace_swipe_invert** reverses swipe direction when true (default false).[1]

**workspace_swipe_min_speed_to_force** sets minimum swipe speed (pixels/ms) to bypass the cancel ratio check, forcing workspace switch even if incomplete (default 30). **workspace_swipe_cancel_ratio** determines the swipe completion threshold—swipes below this ratio (0.0-1.0) cancel and return to original workspace (default 0.5 = 50%).[1]

**workspace_swipe_create_new** creates new workspaces when swiping beyond the final workspace instead of wrapping around (default true).[1]

### Tap Gestures

Touchpad tap-to-click converts finger taps into button clicks:[1]
```
input {
  touchpad {
    tap-to-click = true
    tap_button_map = lrm
    clickfinger_behavior = true
    drag-lock = false
  }
}
```


**tap-to-click** enables tapping as left-click (default true). **tap_button_map** maps multi-finger taps: `lrm` = left/right/middle, `lmr` = left/middle/right (default lrm). **clickfinger_behavior** maps multi-finger physical clicks instead of taps (default false).[1]

### Drag and Drag-Lock

**tap-and-drag** enables dragging by tapping and holding without re-tapping (default true). **drag-lock** prevents dropping items on finger lift: 0 (disabled), 1 (timeout-based), 2 (sticky mode) (default 0).[1]

**drag_3fg** enables three-finger drag for special operations: 0 (disabled), 1 (three fingers), 2 (four fingers) (default 0). This allows alternative drag triggering without tap-and-drag.[1]

### Multi-Finger Scroll

**natural_scroll** inverts scroll direction for touchpads (default false). **scroll_factor** multiplies scroll speed (default 1.0). **middle_button_emulation** interprets simultaneous left+right click as middle-click (default false).[1]

### Edge Scrolling

**scroll_method** determines scrolling interpretation:[1]
- `2fg` - Two-finger scrolling (default for modern touchpads)
- `edge` - Edge scrolling (legacy touchpads)
- `on_button_down` - Button-initiated scrolling
- `no_scroll` - Scrolling disabled

[1]

### Touchscreen-Specific Configuration

The `input:touchdevice` subcategory configures touchscreen input separately from touchpads:[1]
```
input:touchdevice {
  output = DP-1
  transform = -1
  enabled = true
}
```


**output** binds touch input to a specific monitor (default auto-detection). **transform** rotates touch input like monitor rotation, with -1 meaning use monitor's rotation value (default -1). **enabled** toggles touchscreen input (default true).[1]

### Gesture Dispatcher Integration

While Hyprland doesn't provide explicit gesture dispatchers, gestures trigger standard dispatchers through touchpad events. Combine gesture configuration with keyboard bindings for comprehensive gesture support. For example, `workspace_swipe = true` directly triggers `workspace` dispatchers based on swipe direction.[1]

### Advanced Gesture Workflows

**Pinch-to-zoom** simulation combines `scroll_factor` with gesture detection—pinch gestures are interpreted as scroll events on modern touchpads, allowing zoom functionality in compatible applications.[1]

**Window resize on touchscreen** maps touch drag to window resize using `movewindow` or `resizewindow` dispatchers triggered by pointer events.[1]

### Example Comprehensive Touchpad Configuration

```
gestures {
  workspace_swipe = true
  workspace_swipe_fingers = 3
  workspace_swipe_distance = 300
  workspace_swipe_invert = false
  workspace_swipe_min_speed_to_force = 30
  workspace_swipe_cancel_ratio = 0.5
  workspace_swipe_create_new = true
}

input:touchpad {
  disable_while_typing = true
  natural_scroll = false
  tap-to-click = true
  tap_button_map = lrm
  clickfinger_behavior = false
  middle_button_emulation = false
  drag_lock = 0
  tap-and-drag = true
  drag_3fg = 0
  scroll_factor = 1.0
  scroll_method = 2fg
}

input:touchdevice {
  output = DP-1
  transform = -1
  enabled = true
}
```

Sources
[1] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

