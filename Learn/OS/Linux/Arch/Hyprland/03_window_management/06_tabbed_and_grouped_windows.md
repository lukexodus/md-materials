## Tabbed and Grouped Windows


Tabbed and grouped windows organize multiple windows into single tiles, cycling through them without occupying additional space. Groups create container-like structures where windows share one tile while remaining independently manageable.[1]

### Creating Groups

Use the `togglegroup` dispatcher to create or join groups. The focused window and all its recursive children form a new group on first activation. Pressing `togglegroup` again while in a group removes the focused window from the group.[1]

```
bind = SUPER, G, togglegroup
```


### Cycling Through Group Members

Navigate between grouped windows using `changegroupactive` dispatcher with `f` (forward) or `b` (backward) direction:[1]

```
bind = SUPER, Tab, changegroupactive, f
bind = SUPER+SHIFT, Tab, changegroupactive, b
```


Pressing these keybinds cycles focus through group members while maintaining the group's tile position.[1]

### Group Styling

Group border colors match individual window borders initially but can be customized via `col.group_border` (unfocused) and `col.group_border_active` (focused) in the `general` section:[1]

```
general {
  col.group_border = 0xff89b482
  col.group_border_active = 0xffa6e3a1
}
```


### Group Behavior with Window Operations

When creating a group, Hyprland organizes the focused window's subtree—the focused window and all its children become the group. Closing windows within groups is permitted; if a closure removes the original parent, the group breaks back into dwindle form and expands the remaining children.[1]

Groups respect dwindle tiling rules—if you remove a group's parent through closure, child windows resume independent tiles. Moving windows in/out of groups uses standard focus and movement dispatchers.[1]

### Window Rule Integration

Apply window rules to group-specific behavior:[2]

```
windowrulev2 = group new, class:alacritty
```


This automatically places new alacritty windows in a fresh group.[2]

### Group Limitations

Groups do not support nesting—a group cannot contain another group. Attempting to create a group containing windows already in a group will fail. Groups are workspace-specific; switching workspaces breaks group organization temporarily until returning to the original workspace.[1]

### Alternative: Tabbed Mode (Plugin)

Third-party plugins like `hy3` provide tabbed window management with visual tabs, offering an alternative to group cycling. While not built-in, hy3 provides traditional tab bar interfaces similar to i3-gaps with plugins.[1]

### Pseudo-Tabbed Workflow

Create a pseudo-tabbed effect by grouping related windows and using workspace isolation. Dedicate workspaces to application families (e.g., workspace "browsers" groups Firefox and Chrome, workspace "terminals" groups shell windows), then use `workspace` dispatchers to switch between entire groups.[3][1]

```
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, name:browsers
bind = SUPER, 3, workspace, name:terminals

windowrulev2 = workspace name:browsers, class:(firefox|chromium)
windowrulev2 = workspace name:terminals, class:(alacritty|kitty)
```


This configuration automatically routes applications to designated workspaces, effectively creating workspace-level tabbing.[3]

### Group Dispatcher Summary

**togglegroup** creates a new group with the focused window and its children, or removes focused window from existing group.[1]

**changegroupactive [f/b]** cycles focus through group members forward or backward.[1]

**movewindowtogroupid [GROUP_ID]** moves focused window to a specific group (requires group ID from debugging).[1]

Sources
[1] Dwindle Layout https://wiki.hypr.land/Configuring/Dwindle-Layout/
[2] Window Rules https://wiki.hypr.land/Configuring/Window-Rules/
[3] Hyprland workspace configuration - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=298652

