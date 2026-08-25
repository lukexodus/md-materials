## Keyboard Bindings


### Keybinding Syntax

Keybindings are defined in `hyprland.conf` (commonly split into a separate `keybindings.conf` file) using the format:
```
bind = MODS, KEY, dispatcher, params
```
Modifers include `SUPER` (Windows/Command key), `SHIFT`, `CTRL`, `ALT`, and combinations thereof (e.g., `SUPERSHIFT`, `SUPERALT`). The key can be any valid key name, mouse button (e.g., `mouse:272` for left mouse), or event such as `mouse_up`. Dispatcher chooses the action, with optional parameters.[1][6][7][8]

### Examples of Basic Bindings

- Launch terminal: `bind = SUPER, RETURN, exec, kitty`
- Close window: `bind = SUPER, Q, killactive`
- Toggle floating mode: `bind = SUPER, SPACE, togglefloating`
- Focus next window: `bind = SUPER, Tab, cyclenext`
- Move window to workspace 2: `bind = SUPER+SHIFT, 2, movetoworkspace, 2`
- Switch to workspace 2: `bind = SUPER, 2, workspace, 2`
- Launch file manager: `bind = SUPER, E, exec, thunar`
- Toggle fullscreen: `bind = SUPER, F, fullscreen`

### Advanced Modifiers and Formats

- Mouse buttons: `bind = SUPER, mouse:272, exec, appname`
- Mouse wheel: `bind = SUPER, mouse_down, workspace, e-1` (with configurable scroll delay)
- Lock events: `bindl = , switch:[switch name], exec, swaylock`
- Only modifiers: `bindr = SUPERALT, Alt_L, exec, amongus`
- Multiple actions for one key: Assign multiple binds for a single key combination; actions execute top to bottom.[6][1]

### Keybinding Flags

- `l` (locked): Dispatcher only runs when Hyprland is locked.[6]
- `r` (release): Runs on key release rather than press.

### Global Keybinds

Global keybinds pass shortcuts or mouse events directly to applications (OBS, Discord, Firefox) using `pass` or `sendshortcut`. Example:[1][6]
```
bind = SUPER, F10, pass, class:^(com\\.obsproject\\.Studio)$
```
For push-to-talk: 
```
bind=, mouse:276, pass, class:^(TeamSpeak 3)$
```
For custom shortcuts:
```
bind = SUPER, F10, sendshortcut, SUPER, F4, class:^(com\\.obsproject\\.Studio)$
```

### DBus/XDG Desktop Portal Shortcuts

Some apps register shortcuts in the GlobalShortcuts portal. List them with `hyprctl globalshortcuts`, and bind using the `global` dispatcher:
```
bind = SUPERSHIFT, A, global, coolApp:myToggle
```
Works only with XDG Desktop Portal.[1][6]

### Default and Customization

Default Hyprland keybinds include launching the terminal, toggling floating windows, moving focus, launching the app launcher (rofi/wofi), closing windows, workspace switching, toggling groups, and toggling fullscreen.[4][7]

Mod key is typically set to SUPER, but can be changed in the config. Keybinds for workspace assignment, application launch, layout cycling, and advanced behaviors are highly customizable and can be split into modular configuration files as needed.[5][7][8]

### Keybinds Section Example

```
# Terminal
bind = SUPER, RETURN, exec, kitty

# Window control
bind = SUPER, Q, killactive
bind = SUPER, SPACE, togglefloating
bind = SUPER, F, fullscreen

# Workspace
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER+SHIFT, 2, movetoworkspace, 2

# App Launcher
bind = SUPER, D, exec, rofi -show drun

# Grouping
bind = SUPER, G, togglegroup
bind = SUPER, Tab, changegroupactive, f

# Multimedia
bind = SUPER, P, exec, playerctl play-pause

# Monitor and system
bind = SUPER, L, exec, swaylock

# Global shortcut
bind = SUPER, F10, pass, class:^(com\\.obsproject\\.Studio)$
```

Sources
[1] Binds https://wiki.hypr.land/Configuring/Binds/
[2] Keybind List : r/hyprland https://www.reddit.com/r/hyprland/comments/1d0hkyq/keybind_list/
[3] A Noobs Guide to Hyprland | EP:4 - Configuring Keybinds https://www.youtube.com/watch?v=j6Kmru4ldh4
[4] Hyprland Cheatsheet https://wiki.garudalinux.org/en/hyprland-cheatsheet
[5] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[6] Binds | Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Configuring/Binds/
[7] Keybinds · JaKooLit/Hyprland-Dots Wiki https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds
[8] Hyprland https://wiki.cachyos.org/configuration/desktop_environments/hyprland/
[9] Configuring Hyprland https://wiki.hyprland.org/0.41.2/Configuring/Configuring-Hyprland/

