## Hyprlock (Screen Locking)


Hyprlock is Hyprland's native GPU-accelerated screen lock providing visual customization, secure input handling, and tight compositor integration. It replaces traditional X11 lockers with modern Wayland-native functionality.[1][2]

### Installation and Setup

Install Hyprlock on Arch Linux with `sudo pacman -S hyprlock`. Configure with `~/.config/hypr/hyprlock.conf` and start automatically with idle management:[1]
```
exec-once = hypridle
```


Hypridle triggers Hyprlock after idle timeout. Bind manual locking to keybinds:[1]
```
bind = SUPER, L, exec, hyprlock
```


### Configuration Structure

Hyprlock configuration uses nested blocks for layout components:[1]
```
general {
  # General settings
}

background {
  # Wallpaper/background
}

input-field {
  # Password input
}

label {
  # Text labels (time, date, etc.)
}

image {
  # Images and decorations
}
```


### General Settings

```
general {
  no_fade_in = false
  grace = 0
  disable_loading_bar = false
  immediate_render = false
  ignore_empty_input = false
  pam_module = login
  enable_notifications = false
}
```


**no_fade_in** disables fade animation on lock screen appearance (default false). **grace** sets unlock grace period in seconds—lock screen doesn't display if unlocked within grace period (default 0). **disable_loading_bar** hides the loading indicator (default false). **immediate_render** forces immediate rendering without fade effects (default false). **ignore_empty_input** prevents unlock on empty password (default false). **pam_module** sets PAM module for authentication (default "login"). **enable_notifications** shows notifications on lock screen (default false).[1]

### Background Configuration

```
background {
  monitor =
  path = ~/Pictures/wallpaper.png
  blur_passes = 3
  blur_size = 8
  vibrancy = 0.1696
  vibrancy_darkness = 0.0
}
```


**monitor** targets specific monitor; empty applies to all (default empty). **path** specifies background image file. **blur_passes** controls blur strength; higher values increase effect (default 3). **blur_size** sets blur radius in pixels (default 8). **vibrancy** increases color saturation (0.0-1.0, default 0.1696). **vibrancy_darkness** strengthens vibrancy on dark areas (default 0.0).[1]

### Password Input Field

```
input-field {
  monitor =
  size = 200, 50
  outline_thickness = 3
  dots_size = 0.2
  dots_spacing = 0.2
  outer_color = rgb(151515)
  inner_color = rgb(222222)
  font_color = rgb(10, 10, 10)
  fade_on_empty = true
  font_family = JetBrains Mono
  placeholder = <span foreground="##ffffff">🔒 Enter password</span>
  hide_input = false
  check_color = rgb(204, 136, 34)
  fail_color = rgb(204, 34, 34)
  fail_text = <i>$ATTEMPTS failed</i>
  capslock_color = -1
  numlock_color = -1
  bothlock_color = -1
  invert_numlock = false
  swap_layout_key = Tab
  position = 0, -20
  halign = center
  valign = center
}
```


**monitor** targets specific monitor (default empty for all). **size** sets input field dimensions as `WIDTH, HEIGHT`. **outline_thickness** controls border thickness in pixels (default 3). **dots_size** sets password dot size (default 0.2, range 0.0-1.0). **dots_spacing** controls spacing between dots (default 0.2). **outer_color** and **inner_color** set field colors. **font_color** sets text color (default black). **fade_on_empty** fades field when empty (default true). **font_family** specifies font (must be installed). **placeholder** sets prompt text; supports Pango markup. **hide_input** masks password characters (default false, shows dots).[1]

**check_color** highlights field on successful authentication (default green). **fail_color** highlights field on failed attempt (default red). **fail_text** displays after failed unlock; `$ATTEMPTS` shows attempt count (default empty). **capslock_color**, **numlock_color**, **bothlock_color** highlight field when those keys are active; -1 disables (default -1). **invert_numlock** reverses numlock indicator (default false). **swap_layout_key** specifies key for layout switching, typically `Tab` or `Alt_L` (default Tab).[1]

**position** and **halign/valign** control field placement; see label positioning section.[1]

### Text Labels

```
label {
  monitor =
  text = $TIME
  text_align = center
  color = rgba(200, 200, 200, 1.0)
  font_size = 55
  font_family = JetBrains Mono
  position = 0, 200
  halign = center
  valign = center
}
```


**text** content with variable support: `$TIME`, `$DATE`, `$USER`, `$SESSION`. **text_align** controls text alignment: `left`, `center` (default), `right`. **color** sets RGBA text color. **font_size** and **font_family** control typography. **position** sets X,Y offset in pixels; negative values offset from edges. **halign** (horizontal align): `left`, `center` (default), `right`. **valign** (vertical align): `top`, `center`, `bottom` (default).[1]

### Image Elements

```
image {
  monitor =
  path = ~/Pictures/icon.png
  size = 100
  rounding = 10
  border_size = 3
  border_color = rgb(100, 100, 100)
  rotate = 0
  reload_time = 10
  reload_cmd =
  position = 0, -100
  halign = center
  valign = center
}
```


**path** specifies image file. **size** sets image dimensions in pixels (square). **rounding** applies corner radius (default 0). **border_size** and **border_color** add border. **rotate** rotates image in degrees (default 0). **reload_time** reloads image every N seconds (useful for animations). **reload_cmd** executes command before reload (optional).[1]

### Positioning System

Position coordinates use pixel-based layout:[1]
- **Positive X/Y:** Offset from top-left corner
- **Negative X/Y:** Offset from bottom-right corner
- **halign:** Adjusts horizontal alignment (left/center/right)
- **valign:** Adjusts vertical alignment (top/center/bottom)

Example: `position = 0, -100` with `valign = bottom` places element 100 pixels from bottom, centered horizontally.[1]

### Variable Substitution in Labels

**$TIME** displays current time (format configurable with strftime). **$DATE** displays current date. **$USER** displays login username. **$SESSION** displays session name.[1]

### Example Comprehensive Hyprlock Configuration

```
general {
  no_fade_in = false
  grace = 0
  disable_loading_bar = false
  immediate_render = false
  ignore_empty_input = false
  pam_module = login
  enable_notifications = true
}

background {
  monitor =
  path = ~/Pictures/lockscreen.png
  blur_passes = 3
  blur_size = 8
  vibrancy = 0.1696
  vibrancy_darkness = 0.0
}

input-field {
  monitor =
  size = 200, 50
  outline_thickness = 3
  dots_size = 0.2
  dots_spacing = 0.2
  outer_color = rgb(151515)
  inner_color = rgb(222222)
  font_color = rgb(255, 255, 255)
  fade_on_empty = true
  font_family = JetBrains Mono
  placeholder = <span foreground="##ffffff">🔒 Enter password</span>
  hide_input = false
  check_color = rgb(204, 136, 34)
  fail_color = rgb(204, 34, 34)
  fail_text = <i>$ATTEMPTS failed</i>
  capslock_color = -1
  numlock_color = -1
  bothlock_color = -1
  invert_numlock = false
  swap_layout_key = Tab
  position = 0, -20
  halign = center
  valign = center
}

label {
  monitor =
  text = $TIME
  text_align = center
  color = rgba(200, 200, 200, 1.0)
  font_size = 55
  font_family = JetBrains Mono
  position = 0, 200
  halign = center
  valign = center
}

label {
  monitor =
  text = Locked
  text_align = center
  color = rgba(200, 200, 200, 0.7)
  font_size = 20
  font_family = JetBrains Mono
  position = 0, 100
  halign = center
  valign = center
}

image {
  monitor =
  path = ~/Pictures/lock-icon.png
  size = 80
  rounding = 10
  position = 0, -150
  halign = center
  valign = center
}
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

