## Display & Monitors


Monitor configuration uses the `monitor` keyword with the basic syntax `monitor = name, resolution, position, scale`. List available monitors using `hyprctl monitors all` to get exact names and capabilities. The position is calculated in pixels from the virtual layout's top-left corner.[1]

### Resolution and Refresh Rate

Resolution follows the format `WIDTHxHEIGHT@REFRESH`, where refresh rate in Hz is optional. A common configuration:[1]
```
monitor = DP-1, 1920x1080@144, 0x0, 1
```


This creates a 1920x1080 display at 144Hz positioned at (0,0) with 1x scale. Special resolution keywords include `preferred` (display's default resolution and refresh), `highres` (highest supported resolution), `highrr` (highest supported refresh rate), and `maxwidth` (widest supported resolution).[2][1]

### Display Positioning

Position coordinates define the monitor's location within Hyprland's virtual layout, calculated from the top-left corner. For two monitors side-by-side:[1]
```
monitor = DP-1, 1920x1080, 0x0, 1
monitor = DP-2, 1920x1080, 1920x0, 1
```


This places DP-1 on the left and DP-2 on the right. Hyprland uses an inverse Y coordinate system where negative Y places monitors higher and positive Y places them lower.[1]

For vertical stacking:
```
monitor = DP-1, 1920x1080, 0x0, 1
monitor = DP-2, 1920x1080, 0x1080, 1
```


Position calculations account for scaled resolutions—a 4K monitor with scale 2 has effective positioning at half its resolution. No monitors can overlap; overlapping configurations generate warnings.[1]

### Auto-Positioning

Special position values automate layout:[1]

**Basic Auto:** `auto` lets Hyprland decide, defaulting to placing each new monitor to the right of existing ones. **Directional Auto:** `auto-right`, `auto-left`, `auto-up`, `auto-down` position monitors in specified directions from existing ones. **Center-based Auto:** `auto-center-right`, `auto-center-left`, `auto-center-up`, `auto-center-down` position from each monitor's center rather than its corner.[1]

Quick multi-monitor catch-all:
```
monitor = , preferred, auto, 1
```


This configures any unspecified monitor with its preferred resolution, auto-positioned, at 1x scale.[1]

### Scaling (DPI)

Scale is a multiplier determining logical vs physical resolution. Scale 1 shows pixels 1:1, scale 1.5 creates a 50% DPI scaling for HiDPI displays, and scale 2 creates 100% scaling. Auto-scaling uses `auto` as the scale value, letting Hyprland determine appropriate scaling based on PPI.[1]

Scaling affects positioning calculations—a scaled monitor's position uses its effective dimensions.[1]

### Rotation and Mirroring

Add `, transform, X` to rotate monitors, where X is:[1]

- `0` - Normal (no rotation)
- `1` - 90 degrees
- `2` - 180 degrees
- `3` - 270 degrees
- `4` - Flipped
- `5` - Flipped + 90 degrees
- `6` - Flipped + 180 degrees
- `7` - Flipped + 270 degrees

[1]

Mirror displays with `, mirror, MONITOR_NAME`. Note that mirroring does not re-render content for the mirrored resolution—a 1080p screen mirrored to 4K remains 1080p. Aspect ratio mismatches cause stretching/squishing.[1]

### Advanced Display Features

**10-bit Support:** Add `, bitdepth, 10` to enable 10-bit color depth. Colors defined in Hyprland (borders, etc.) do not support 10-bit. Some applications cannot capture with 10-bit enabled.[1]

**Color Management:** Use `, cm, X` to set color management presets. Options include `srgb` (default), `dcip3`, `dp3`, `adobe`, `wide` (BT2020), `edid` (from display EDID), and `hdr` (experimental, requires wide color gamut). For HDR, use `, sdrbrightness, B, sdrsaturation, S` to adjust SDR brightness and saturation (default 1.0).[1]

**VRR (Variable Refresh Rate):** Add `, vrr, X` where X is a mode from the variables page.[1]

### Disabling Monitors

Disable monitors with `monitor = name, disable`. This removes the monitor from layout, moving all windows and workspaces to remaining displays. To power-off a monitor without disabling it, use the `dpms` dispatcher.[1]

### Monitor Description Matching

Use monitor descriptions for device-agnostic configuration. Get descriptions from `hyprctl monitors` output, removing the port name:[1]
```
monitor = desc:Chimei Innolux Corporation 0x150C, preferred, auto, 1.5
```


This configuration applies to any monitor with that description regardless of connection port.[1]

### Custom Reserved Area

Add workspace gaps without tiling windows by using:[1]
```
monitor = name, addreserved, TOP, BOTTOM, LEFT, RIGHT
```


Where TOP, BOTTOM, LEFT, RIGHT are pixel values. This stacks with existing reserved areas like bars.[1]

### Alternative Monitor v2 Syntax

Verbose syntax using `monitorv2` blocks provides equivalent configuration:[1]
```
monitorv2 {
  output = DP-1
  mode = 1920x1080@144
  position = 0x0
  scale = 1
  transform = 2
}
```

Sources
[1] Monitors https://wiki.hypr.land/Configuring/Monitors/
[2] I need help with Refresh rate · hyprwm Hyprland https://github.com/hyprwm/Hyprland/discussions/3706
[3] Refresh rate : r/hyprland https://www.reddit.com/r/hyprland/comments/17577rf/refresh_rate/
[4] Monitors https://wiki.hyprland.org/0.46.0/Configuring/Monitors/
[5] A Noobs Guide to Hyprland | EP:3 - Monitor Setup https://www.youtube.com/watch?v=FSL8uPPC8V8
[6] Hyprland workspace configuration - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=298652
[7] My scaling changes to 1.5 anytime I update hyprland.conf https://www.reddit.com/r/hyprland/comments/1ebe6hp/my_scaling_changes_to_15_anytime_i_update/
[8] Resolution and refresh rate for a headless output #5415 https://github.com/hyprwm/Hyprland/issues/5415
[9] Monitors - Hyprland Wiki https://wiki.hyprland.org/0.41.2/Configuring/Monitors/
[10] erans/hyprmon: TUI monitor configuration tool for Hyprland ... https://github.com/erans/hyprmon

