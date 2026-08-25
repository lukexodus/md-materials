## Input Devices


The `input` section contains keyboard and mouse configuration settings controlling how input devices behave. This section manages keyboard layout, repeat rates, mouse sensitivity, and device-specific behavior.[1]

### Keyboard Configuration

**kb_layout** sets the keyboard layout using XKB codes, defaulting to US (`us`). Common values include `us`, `de`, `fr`, `gb`, `jp`. **kb_variant** specifies layout variants like `dvorak`, `colemak`, `qwerty` for layouts supporting variants, defaulting to empty (standard variant).[1]

**kb_model** sets the keyboard model according to XKB specifications, defaulting to empty. **kb_options** applies XKB options like `grp:shifts_toggle` for layout switching, defaulting to empty. **kb_rules** specifies XKB rules files, defaulting to empty.[1]

You can use `localectl list-x11-keymap-variants` and `localectl list-x11-keymap-layouts` to discover available options on your system.[1]

**kb_file** accepts a custom XKB file path, allowing complete custom keyboard definitions when set. **numlock_by_default** enables Numlock on startup when set to true, defaulting to false.[1]

**repeat_rate** controls how many times per second a held-down key repeats, defaulting to 25 repeats per second. **repeat_delay** sets the delay before repetition begins in milliseconds, defaulting to 600ms.[1]

### Mouse and Cursor Sensitivity

**sensitivity** sets mouse input sensitivity as a float between -1.0 and 1.0 (default 0.0). Positive values increase speed, negative values decrease it, and 0.0 uses the default system setting.[1]

**accel_profile** selects the cursor acceleration profile from `adaptive` (default curves with acceleration), `flat` (linear 1:1 movement), or `custom` (user-defined via `scroll_points`). Leave empty to use libinput's default profile. **force_no_accel** bypasses acceleration entirely when true, providing raw cursor input but risking desynchronization.[1]

**left_handed** swaps right and left mouse buttons when true, defaulting to false.[1]

### Scrolling Configuration

**scroll_method** determines how scrolling is interpreted, accepting `2fg` (two-finger touchpad scroll), `edge` (edge scrolling), `on_button_down` (button-initiated scrolling), or `no_scroll` (disabled). **scroll_button** sets which mouse button triggers scrolling (0 for default). **scroll_button_lock** prevents holding the button—pressing toggles scroll mode instead.[1]

**scroll_factor** multiplies scroll movement, defaulting to 1.0. **natural_scroll** inverts scrolling direction when true, making content move with your fingers rather than scrolling a scrollbar.[1]

### Focus and Warping

**follow_mouse** controls cursor focus behavior: 0 (cursor doesn't focus windows), 1 (cursor always focuses window under it, default), 2 (clicking focuses, cursor movement doesn't), 3 (complete separation between cursor and keyboard focus).[1]

**follow_mouse_threshold** sets minimum mouse movement in pixels before focusing, only working with `follow_mouse=1`, defaulting to 0. **focus_on_close** determines focus when a window closes: 0 (shift to next window), 1 (focus window under cursor).[1]

**mouse_refocus** prevents focus-switching unless the cursor crosses a window boundary when `follow_mouse=1`, defaulting to true. **float_switch_override_focus** changes focus behavior when switching between tiling and floating: 0 (no change), 1 (follow cursor, default), 2 (follow cursor on all floating switches).[1]

**resolve_binds_by_sym** determines keybind resolution with multiple keyboard layouts: false (always use first layout), true (keybinds use current layout symbols).[1]

### Advanced Cursor Control

**off_window_axis_events** handles scroll events at window edges: 0 (ignore), 1 (send out-of-bound coordinates), 2 (fake coordinates to closest inside point), 3 (warp cursor inside).[1]

**emulate_discrete_scroll** emulates discrete scrolling from high-resolution events: 0 (disable), 1 (only non-standard), 2 (force all). **rotation** rotates input device orientation in degrees (0-359), defaulting to 0.[1]

### Touchpad-Specific Settings

The `input:touchpad` subcategory controls touchpad behavior separately from mice. **disable_while_typing** disables the touchpad while typing to prevent accidental input, defaulting to true. **natural_scroll** inverts touchpad scrolling when true.[1]

**tap-to-click** enables tap-based button emulation: 1 finger = left-click, 2 fingers = right-click, 3 fingers = middle-click, defaulting to true. **clickfinger_behavior** enables the same multi-finger mapping as tap-to-click but for physical clicks.[1]

**middle_button_emulation** interprets simultaneous left and right clicks as middle-click when true. **drag_lock** prevents item drops when lifting fingers: 0 (disabled), 1 (timeout-based), 2 (sticky mode).[1]

**tap-and-drag** enables dragging by tapping and holding without re-tapping, defaulting to true. **tap_button_map** selects tap-to-button mapping: `lrm` (left, right, middle), `lmr` (left, middle, right).[1]

**flip_x** and **flip_y** invert horizontal and vertical touchpad movement respectively, both defaulting to false. **scroll_factor** multiplies touchpad scroll movement separately from mice. **drag_3fg** enables three-finger drag: 0 (disabled), 1 (three fingers), 2 (four fingers).[1]

### Per-Device Configuration

The `device` keyword allows per-device overrides targeting specific input devices by name. Use `hyprctl devices` to list connected devices, then create device sections:[1]
```
device:name {
  sensitivity = 0.5
  accel_profile = flat
}
```


Settings in `device` sections override global `input` settings for matching devices.[1]

### Touch Devices

The `input:touchdevice` subcategory configures touchscreen-specific behavior. **output** binds touch input to a specific monitor (e.g., for dual-monitor tablet users), defaulting to auto-detection. **transform** rotates touch input like monitors, with -1 meaning unset (uses monitor rotation). **enabled** toggles touch input when false.[1]

### Tablet Configuration

The `input:tablet` subcategory handles graphics tablet input. **output** binds the tablet to a specific monitor or `current` for active monitor. **relative_input** switches between absolute positioning and relative cursor movement.[1]

**region_size** and **region_position** define a mapped input area on the tablet that corresponds to the output screen. **active_area_size** and **active_area_position** specify the tablet's physical active area dimensions in millimeters. **left_handed** rotates the tablet 180 degrees for left-handed use.[1]

Sources
[1] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

