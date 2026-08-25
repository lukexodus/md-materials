## General Settings


The `general` section contains the foundational behavior and visual appearance settings for Hyprland. This section is wrapped in braces and controls window sizing, gaps, borders, colors, and the default tiling layout.[1][2]

### Window Borders and Sizing

**border_size** sets the thickness of window borders in logical pixels, with a default of 1. Set to 0 to disable borders entirely. **no_border_on_floating** disables borders specifically for floating windows while preserving them on tiled windows, defaulting to false.[2]

**resize_on_border** enables resizing windows by clicking and dragging on borders and gaps when set to true. This allows direct border manipulation instead of requiring a modifier key plus mouse drag. **extend_border_grab_area** expands the clickable resize area around borders by the specified number of logical pixels (default 15), making resizing easier on smaller borders. **hover_icon_on_border** displays a cursor resize icon when hovering over resizable borders, only active when `resize_on_border` is enabled.[2]

**resize_corner** forces floating windows to resize from a specific corner (1=top-left, 2=top-right, 3=bottom-right, 4=bottom-left, 0=disabled). This prevents corner-dependent resizing conflicts.[1][2]

### Gaps and Workspace Spacing

**gaps_in** controls the spacing between adjacent tiled windows, defaulting to 5 pixels. Supports CSS-style specifications with four values for top, right, bottom, and left individually (e.g., `5,10,15,20`).[2]

**gaps_out** controls the spacing between windows and monitor edges, defaulting to 20 pixels. Also supports CSS-style gap specifications. **float_gaps** controls gaps for floating windows independently, defaulting to 0 (use standard gaps), and can be set to -1 to inherit from gaps_in and gaps_out. **gaps_workspaces** adds additional gaps between virtual workspaces, stacking with gaps_out.[2]

### Border Colors

**col.active_border** sets the border color for the currently focused window, supporting gradient definitions, defaulting to white (0xffffffff). **col.inactive_border** sets the border color for non-focused windows, defaulting to dark gray (0xff444444).[2]

**col.nogroup_border** and **col.nogroup_border_active** control border colors for windows that cannot be added to groups, with distinct colors for inactive and active states. Colors accept multiple formats: rgba (e.g., `rgba(b3ff1aee)`), rgb (e.g., `rgb(b3ff1a)`), or legacy ARGB (e.g., `0xeeb3ff1a`).[2]

### Layout Configuration

**layout** selects the default tiling algorithm for the workspace, accepting either `dwindle` (default) or `master`. This determines how new windows automatically partition available screen space.[2]

### Focus and Navigation

**no_focus_fallback** prevents focus from shifting to the next available window when moving in a direction with no window present, defaulting to false. When true, focus remains unchanged if the direction is empty.[2]

### Advanced Window Behavior

**allow_tearing** enables screen tearing when set to true, reducing latency for fast-moving content in supported scenarios. This is a master switch—individual per-application tearings are controlled separately.[2]

**snap** is a subcategory controlling floating window snapping behavior. **enabled** toggles snapping functionality. **window_gap** sets the minimum pixel distance between windows before snapping engages (default 10). **monitor_gap** sets minimum distance between a window and monitor edges before snapping (default 10). **border_overlap** makes windows snap such that only one border's worth of space separates them when true. **respect_gaps** honors gaps_in when snapping if enabled.[2]

### Example Configuration

A basic general section setup:
```
general {
  border_size = 2
  gaps_in = 5
  gaps_out = 10
  col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
  col.inactive_border = rgba(595959aa)
  layout = dwindle
  resize_on_border = true
  extend_border_grab_area = 15
  
  snap {
    enabled = true
    window_gap = 10
    monitor_gap = 10
  }
}
```

Sources
[1] Customizing Hyprland to Your Liking - It's FOSS https://itsfoss.com/configuring-hyprland/
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/
[3] Configuring - Hyprland Wiki https://wiki.hypr.land/Configuring/
[4] Configuring - Hyprland Wiki https://wiki.hyprland.org/0.41.0/Configuring/Configuring-Hyprland/
[5] Configuring Hyprland - GitHub https://github.com/hyprwm/Hyprland/wiki/Configuring-Hyprland/4366ee62f37b7be41b372a69408f55dc4cd7d7b7
[6] Help I really like Hyprland, but the general documentation and ... https://www.reddit.com/r/hyprland/comments/15cl3pc/help_i_really_like_hyprland_but_the_general/
[7] Hyprland windows gaps - Issues & Assistance - CachyOS Forum https://discuss.cachyos.org/t/hyprland-windows-gaps/8533
[8] [Feature Request]: Setting on Hyprland.conf to change mouse speed https://github.com/prasanthrangan/hyprdots/issues/907
[9] Variables - Hyprland Wiki https://wiki.hyprland.org/0.45.0/Configuring/Variables/
[10] Basic Config · hyprwm/Hyprland Wiki - GitHub https://github.com/hyprwm/Hyprland/wiki/Basic-Config/b1bd6a563aa109de0918b1573e3e8a52d4413990

