## Mouse Bindings


### Mouse Button Syntax

Mouse bindings follow the same format as keyboard bindings but use mouse button identifiers instead of key names. The syntax is:[1][2]
```
bind = MODS, mouse:BUTTONCODE, dispatcher, params
```

Common mouse button codes:[2][1]
- `mouse:272` - Left mouse button
- `mouse:273` - Right mouse button
- `mouse:274` - Middle mouse button
- `mouse:275` - Side button (back)
- `mouse:276` - Side button (forward)

### Mouse Movement and Scrolling

**Mouse wheel scrolling** uses `mouse_up` and `mouse_down` instead of button codes, with configurable scroll sensitivity:[1][2]
```
bind = SUPER, mouse_down, workspace, e-1
bind = SUPER, mouse_up, workspace, e+1
```

These keybinds cycle workspaces on scroll; `e-1` goes to previous workspace, `e+1` goes to next. **Scroll delay** controls repeat speed between scroll events using `scroll_event_delay` in the `input` section (default 300ms).[2][1]

**Mouse move events** capture cursor movement for custom workflows:
```
bind = SUPER, mouse_move, exec, notify-send "Mouse moved"
```
Though rarely used, this enables mouse tracking for specialized applications.[1]

### Common Mouse Binding Examples

**Window operations:**
```
bind = SUPER, mouse:272, movewindow
bind = SUPER, mouse:273, resizewindow
bind = mouse:274, cyclenext
```

The first focuses and drags windows, the second resizes, the third cycles through windows on middle-click.[2][1]

**Workspace switching:**
```
bind = SUPER, mouse_down, workspace, e-1
bind = SUPER, mouse_up, workspace, e+1
```

These provide quick workspace navigation without keyboard input.[1][2]

**Application launching:**
```
bind = SUPER, mouse:276, exec, rofi -show drun
bind = , mouse:275, exec, pavucontrol
```

The first launches the app menu on forward button with Super held, the second opens audio control on back button alone.[1]

**Window state toggling:**
```
bind = SUPER+SHIFT, mouse:272, togglefloating
bind = SUPER+SHIFT, mouse:273, fullscreen
```

These toggle floating mode and fullscreen on modifier+click combinations.[2][1]

### Mouse Modifiers

Mouse bindings support all keyboard modifiers: `SUPER`, `SHIFT`, `CTRL`, `ALT`, and combinations like `SUPERSHIFT` or `CTRLALT`. Modifiers work identically to keyboard bindings—the mouse action triggers only when the specified modifier keys are held.[2][1]

### Global Mouse Shortcuts

Use `pass` or `sendshortcut` with mouse buttons for application-specific shortcuts:
```
bind = SUPER, mouse:272, pass, class:^(com\\.obsproject\\.Studio)$
bind = SUPER, mouse:273, sendshortcut, SUPER, F4, class:^(OBS)$
```

The first passes mouse clicks directly to OBS without Hyprland interception, the second sends a keyboard shortcut to OBS on right-click.[1][2]

### Advanced Mouse Binding Patterns

**Context-based actions** use multiple bindings for the same button with different modifiers:
```
bind = , mouse:272, cyclenext
bind = SUPER, mouse:272, movewindow
bind = SUPER+SHIFT, mouse:272, resizewindow
bind = ALT, mouse:272, exec, rofi -show window
```

Bare mouse:272 cycles windows, Super+click moves, Super+Shift+click resizes, Alt+click opens window switcher.[2][1]

**Mouse button chording** (sequential presses) is not directly supported in Hyprland; use single-button or modifier combinations for reliable binding.[1]

**Scroll momentum** applies acceleration to wheel scrolling, making rapid scrolls trigger multiple events faster than individual spins—control with scroll_event_delay in the input section.[1]

### Mouse Binding Flags

Mouse bindings support the same flags as keyboard bindings:[1]
- `l` (locked) - Only triggers when Hyprland is locked
- `r` (release) - Triggers on button release instead of press
- `e` - Exact match (rarely used with mouse)

Example locked binding:
```
bindl = , mouse:272, exec, swaylock
```

### Example Comprehensive Mouse Configuration

```
# Window management
bind = SUPER, mouse:272, movewindow
bind = SUPER+SHIFT, mouse:272, resizewindow
bind = SUPER, mouse:273, cyclenext
bind = , mouse:274, cyclenext

# Workspace navigation
bind = SUPER, mouse_down, workspace, e-1
bind = SUPER, mouse_up, workspace, e+1

# Window state
bind = SUPER+SHIFT, mouse:275, togglefloating
bind = SUPER+SHIFT, mouse:276, fullscreen

# Application shortcuts
bind = ALT, mouse:272, exec, rofi -show drun
bind = SUPER, mouse:274, exec, pavucontrol

# Global shortcuts for OBS
bind = SUPER, mouse:276, pass, class:^(com\\.obsproject\\.Studio)$
```

Sources
[1] Binds https://wiki.hypr.land/Configuring/Binds/
[2] Binds | Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Configuring/Binds/
[3] Keybinds · JaKooLit/Hyprland-Dots Wiki https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds

