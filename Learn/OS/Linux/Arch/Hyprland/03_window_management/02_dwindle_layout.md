## Dwindle Layout


### Overview

The dwindle layout in Hyprland is a dynamic, tiling window arrangement that recursively splits the screen into smaller sections as new windows are opened, following a binary tree model. It is designed to optimize screen space and maintain an organized, efficient environment, making it popular among tiling window manager users and especially those familiar with layouts like i3 or Sway but seeking Hyprland’s enhanced features.

### How Dwindle Layout Works

- **Binary Tree Splitting:** Each new window splits the current “active” window area either vertically or horizontally, alternating directions for each subsequent split.
- **Responsive Resizing:** Resizing one window can propagate size changes to others, similar to a tree of splits, maintaining balance and screen efficiency.
- **Floating and Tiling:** Windows can be set to float or tile dynamically; the dwindle layout only manages tiled windows.
- **Customizable Behavior:** Splitting style (vertical/horizontal), gap size, margins, and specific rules for applications can be configured to suit workflow needs.

### Configuration Example

Typical configuration options for the dwindle layout in Hyprland are set in the `~/.config/hypr/hyprland.conf` file:

```ini
# Activate dwindle by default
general {
    layout = dwindle
}

# Dwindle-specific configurations
dwindle {
    pseudotile = true           # Allows floating windows to tile if possible
    preserve_split = true       # Preserves splits after closing a window
    force_split = 0             # 0: alternate, 1: vertical, 2: horizontal
    use_active_split = true     # Split based on currently active container
    smart_resizing = true       # Intelligent resizing for complex trees
}
```
- `pseudotile = true`: Allows windows that do not fully support tiling to still fit within the dwindle layout.
- `preserve_split = true`: Prevents the tree from recombining split areas when a window closes, keeping layout structure predictable.
- `force_split`: Controls split direction (0 for alternating, 1 for vertical only, 2 for horizontal only).
- `smart_resizing`: Enhanced resizing behavior for more complex arrangements.

### Key Features and Benefits

- **Space Efficiency:** Maximizes usable screen area by eliminating gaps and overlaps between windows.
- **Structured Organization:** Maintains a logical grouping, making multitasking easier and more visually intuitive.
- **Dynamic:** Adapts as windows are added or removed; supports cycling to other layouts or floating as needed.
- **Powerful Customization:** Granular control over window behavior, layout rules, and aesthetics through Hyprland’s config file.

### Example: Workflow

**Example:**  
If you open three terminal windows in dwindle layout, the screen will be split first vertically, then the next window will split one of those areas horizontally, resulting in a balanced stacked arrangement. Additional windows continue to split the available space recursively, in either direction, creating a visually distinct and optimally spaced environment.

### Output

- Activate the layout:  
  `hyprctl dispatch layoutmsg dwindle`  
- Open new windows to see them tile in the recursive dwindle pattern.

**Key Points**  
- Binary tree split tiling
- Efficient space usage  
- Highly customizable
- Configuration via `hyprland.conf`

Sources


