## Dynamic Tiling Fundamentals


Dynamic tiling in Hyprland automatically arranges windows based on preset algorithms rather than requiring manual configuration. When new windows open or existing ones close, the compositor recalculates dimensions and repositions all affected windows to maintain full screen coverage.[1][2][3]

### Binary Space Partitioning (Dwindle)

Dwindle is the default layout implementing binary space partitioning (BSP), where every window belongs to a binary tree structure. Each node represents either a window or a container of two child nodes. New windows recursively subdivide the currently focused window's space, creating nested splits.[4][5]

**Dynamic Splitting:** Splits adjust based on the parent container's width-to-height ratio. If width exceeds height (landscape), new windows split side-by-side horizontally; if height exceeds width (portrait), they split vertically top-and-bottom. This ratio-based behavior means split orientation changes automatically when resizing containers, adapting to display geometry.[4]

**Permanent vs Dynamic Splits:** By default, splits recalculate dynamically as containers are resized or windows close. Enable `preserve_split` in the dwindle section to make splits permanent—once a side-by-side or top-bottom split exists, it remains that way regardless of subsequent resizing.[4]

### Controlling Split Direction

**force_split** controls where new windows appear relative to the focused window:[4]
- `0` (default) - Split direction follows mouse position: cursor on right/bottom creates right/bottom splits, cursor on left/top creates left/top splits[4]
- `1` - Always split left (horizontal) or top (vertical), new windows always appear on the left or above[4]
- `2` - Always split right or bottom, new windows always appear on the right or below[4]

**smart_split** provides precise directional control by dividing the focused window into four triangles. The cursor's triangle determines split direction—cursor in top-left triangle creates top/left split, top-right creates top/right split, etc.. Smart_split automatically enables `preserve_split`.[4]

**preselect** provides one-time direction overrides using the `layoutmsg preselect l/r/u/d` dispatcher, affecting only the next window opened. Enabling `permanent_direction_override` makes preselect persist until explicitly changed.[4]

### Window Grouping

Windows can form **groups** (similar to i3wm's tabbed containers) that occupy a single tile but cycle through members. Create groups with `togglegroup` dispatcher, cycle through members with `changegroupactive f/b` (forward/backward).[5][4]

When creating a group, the focused window and all its recursive children form the group; the group's border colors are configurable with `col.group_border` (inactive) and `col.group_border_active` (active). Closing windows within groups is allowed; if a closure causes the original parent to be removed, the group breaks back into dwindle form.[5][4]

### Pseudotiling

Enable `pseudotile = true` in the dwindle section to activate pseudotiling, where tiled windows retain their floating size but participate in tiling layout. A 500x300px window remains that size while fitting into the tiling tree rather than expanding to fill its tile. This combines tiling organization with floating window dimensions.[4]

### Advanced Dwindle Options

**smart_resizing** (default true) determines resize direction based on mouse position—cursor nearest to which corner controls resize direction. When false, resize direction is based on tiling position within the split.[4]

**split_width_multiplier** scales automatic splits for wide monitors where window width exceeds height even after multiple splits, allowing finer-grained split ratios (default 1.0).[4]

**use_active_for_splits** determines whether splits use the active window or mouse position (default true, uses active window).[4]

**default_split_ratio** sets the initial split ratio: 1.0 = 50/50 split, values 0.1-1.9 allow unequal splits.[4]

**split_bias** determines which window receives the split ratio when opening new windows: 0 = directional window (top/left), 1 = current focused window.[4]

**single_window_aspect_ratio** adds padding around solitary windows to maintain specified aspect ratios (e.g., `4 3` for 4:3 on 16:9 display). **single_window_aspect_ratio_tolerance** prevents padding if it's smaller than the specified tolerance fraction (default 0.1).[4]

### Layout Message Dispatchers

**togglesplit** swaps split orientation (horizontal ↔ vertical) when `preserve_split` is enabled, only functioning on the active window.[4]

**swapsplit** exchanges the two halves of the current window's split.[4]

**movetoroot** relocates the active window to the workspace tree root, maximizing it within its current subtree by default; adding `unstable` swaps it with the other subtree instead.[4]

Sources
[1] Hyprland – An independent, dynamic tiling Wayland ... https://news.ycombinator.com/item?id=44854508
[2] I switched to Hyprland https://uncomfyhalomacro.pl/blog/9/
[3] Hyprland https://wiki.archcraft.io/docs/wayland-compositors/hyprland/
[4] Dwindle Layout https://wiki.hypr.land/Configuring/Dwindle-Layout/
[5] Dwindle Layout · hyprwm/Hyprland Wiki https://github.com/hyprwm/Hyprland/wiki/Dwindle-Layout/1f579b1a40c45d1b4d46542f93329cc58d857d4c
[6] Changing layout dynamically with a keybind? Pseudo tiling ... https://www.reddit.com/r/hyprland/comments/1ggy9kf/changing_layout_dynamically_with_a_keybind_pseudo/
[7] Window Rules https://wiki.hyprland.org/0.45.0/Configuring/Window-Rules/
[8] Master Layout https://wiki.hyprland.org/0.46.0/Configuring/Master-Layout/
[9] Reviewing & Customizing Hyprland Window Manager Live! https://www.youtube.com/watch?v=S_zT92xS3jY
[10] spikespaz-contrib/hyprland https://github.com/spikespaz/hyprland

