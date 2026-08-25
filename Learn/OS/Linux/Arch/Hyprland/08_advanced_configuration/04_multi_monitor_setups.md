## Multi-Monitor Setups


Hyprland offers comprehensive, dynamic multi-monitor support with per-monitor configuration, hotplugging, and layout flexibility. Each monitor can have its own resolution, scale, workspace assignment, and more, all configured via the `monitor` keyword or `monitorv2` blocks.[1][2]

### Static Monitor Configuration

Define monitors in `hyprland.conf`:
```
monitor = DP-1, 3440x1440@144, 0x0, 1
monitor = HDMI-1, 1920x1080@60, 3440x0, 1
monitor = eDP-1, preferred, auto, 1
```
- **First field:** Port name (use `hyprctl monitors` to list exact names, e.g., DP-1, HDMI-A-1, eDP-1).[1]
- **Second:** Resolution and optionally refresh rate (e.g., 1920x1080@60, or preferred).[3][1]
- **Third:** Position in virtual layout (e.g., 0x0 for primary/left, 3440x0 to stack right of a 3440px-wide monitor).[1]
- **Fourth:** Scale factor for HiDPI (e.g., 1.25 for 125% scaling).[1]
- **Extra options:** Transform (rotation), mirror, bitdepth, color management, VRR, etc..[1]

### Dynamic Monitor Hotplugging

- On monitor plug/unplug, Hyprland can automatically configure new outputs by adding catch-all entries:
```
monitor = , preferred, auto, 1
```
This sets all unmapped monitors to preferred resolution, placed automatically with scale 1.[1]

### Layout Customization

Arrange monitors horizontally, vertically, or in grid layouts by adjusting the position field. Example for stacking above:[1]
```
monitor = DP-1, 2560x1440, 0x0, 1
monitor = HDMI-1, 1920x1080, 320x1440, 1  # Below and right (offset origin matched to effective pixels)
```


### Per-Monitor Advanced Options

- **Rotation:** Add a transform: `monitor = eDP-1, preferred, 0x0, 1, transform, 3` (270 degrees).[1]
- **Mirroring:** Mirror a monitor: `monitor = HDMI-1, mirror, DP-1`.[1]
- **Bitdepth:** Set 10-bit color: `monitor = DP-1, preferred, auto, 1, bitdepth, 10`.[1]
- **Color management:** Use wide, srgb, or custom color profiles with `cm`: `monitor = DP-1, preferred, auto, 1, cm, srgb`.[1]
- **HDR:** Enable experimental HDR: `monitor = DP-1, preferred, auto, 1, cm, hdr`.[1]
- **Workspace binding:** Assign workspaces to specific monitors:
  ```
  workspace = 1, monitor:DP-1
  workspace = 2, monitor:HDMI-1
  workspace = name:editor, monitor:eDP-1
  ```


### Auto-Positioning and Catch-all

Auto arrange new monitors using directional flags:
```
monitor = , preferred, auto-right, 1
monitor = , preferred, auto-center-up, 1
```


### Multi-Monitor Workflow Tips

- **Workspaces are independent per monitor** when assigned; switching workspace on one does not affect others.[4][1]
- **Focus follows mouse** or keyboard shortcuts to jump between monitors (`focusmonitor` dispatcher).[2]
  ```
  bind = SUPER, F2, focusmonitor, l
  bind = SUPER, F3, focusmonitor, r
  ```


- **Move windows between monitors** with `movetomonitor`:
  ```
  bind = SUPER+SHIFT, Left, movetomonitor, l
  bind = SUPER+SHIFT, Right, movetomonitor, r
  ```


- **Set scale per monitor** for mixed DPI/HiDPI setups:
  ```
  monitor = eDP-1, preferred, auto, 2
  monitor = DP-1, 1920x1080, auto, 1
  ```


### Alternative Monitorv2 Verbose Block

For maximal flexibility, use structured blocks:
```
monitorv2 {
  output = DP-1
  mode = 2560x1440@144
  position = 0x0
  scale = 1.25
  transform = 3
  color_profile = srgb
}
```


### Reserved Screen Areas

Create reserved (unusable) screen space at screen edges for panels or widgets:
```
monitor = DP-1, 2560x1440, 0x0, 1, addreserved, 40, 0, 0, 0
```
(Top 40px reserved—useful for bars on specific monitors).[1]

### Troubleshooting

- Use `hyprctl monitors all` to debug port names, resolutions, and active mappings.[2]
- If display issues arise (overlapping, black screens), verify that positions and scales do not overlap or conflict.[1]

### Scripts for Multi-Monitor Setups

Hotplug/autorun example:
```bash
#!/bin/bash
# ~/.config/hypr/scripts/switch-monitors.sh
if hyprctl monitors | grep 'HDMI-1'; then
  hyprctl keyword monitor HDMI-1, disable
else
  hyprctl keyword monitor HDMI-1, preferred, auto, 1
fi
```
Bind in `hyprland.conf`:
```
bind = SUPER, F7, exec, ~/.config/hypr/scripts/switch-monitors.sh
```


With flexible monitor configuration keywords and the `monitorv2` block, Hyprland enables robust and fully-scriptable multi-monitor layouts suitable for any mixed-DPI, rotated, mirrored, or hotplug workflow.[4][2][1]

Sources
[1] Monitors https://wiki.hypr.land/Configuring/Monitors/
[2] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[3] I need help with Refresh rate · hyprwm Hyprland https://github.com/hyprwm/Hyprland/discussions/3706
[4] Hyprland workspace configuration - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=298652

