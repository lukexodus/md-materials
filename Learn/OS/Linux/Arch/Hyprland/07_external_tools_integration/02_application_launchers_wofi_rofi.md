## Application Launchers (Wofi/Rofi)


Application launchers provide quick access to installed programs through keyboard shortcuts and search interfaces. Wofi is Wayland-native and recommended for Hyprland, while Rofi works through XWayland compatibility.[1][2]

### Wofi (Wayland-Native)

**Wofi** is the recommended launcher for Hyprland, built specifically for Wayland with full compatibility. Install on Arch Linux with `sudo pacman -S wofi`.[2][1]

Launch with keybind in `hyprland.conf`:[1]
```
bind = SUPER, D, exec, wofi --show drun
```


This opens the app launcher showing installed applications.[1]

### Wofi Configuration

Create `~/.config/wofi/config` for customization:[1]
```
width=600
height=600
location=top_left
show=drun
allow_images=true
image_size=32
insensitive=true
```


**width/height** - Window dimensions in pixels. **location** - Window position: `top_left`, `top_center`, `top_right`, `center`, `bottom_left`, etc.. **show** - Mode: `drun` (applications), `run` (commands). **allow_images** - Display application icons (default true). **image_size** - Icon size in pixels. **insensitive** - Case-insensitive search (default false).[1]

### Wofi Styling

Create `~/.config/wofi/style.css`:[1]
```css
window {
  background-color: #1e1e2e;
  border: 2px solid #45475a;
  border-radius: 8px;
}

#input {
  background-color: #313244;
  color: #cdd6f4;
  padding: 10px;
  border-radius: 4px;
}

#entry {
  padding: 5px;
}

#entry:selected {
  background-color: #89b4fa;
  color: #000000;
}
```


### Rofi (X11-Based Alternative)

**Rofi** works with Hyprland through XWayland but is not native Wayland. Install with `sudo pacman -S rofi`.[2][1]

Launch with keybind:[1]
```
bind = SUPER, D, exec, rofi -show drun -theme ~/.config/rofi/theme.rasi
```


### Rofi Configuration

Create `~/.config/rofi/config.rasi`:[1]
```
configuration {
  modes: "drun,run,window";
  font: "monospace 12";
  width: 50%;
  lines: 15;
  columns: 1;
  location: center;
  window-format: "{w}   {c}   {t}";
  matching: "fuzzy";
}

@theme "~/.config/rofi/theme.rasi"
```


### Rofi Theming

Create `~/.config/rofi/theme.rasi`:[1]
```
* {
  bg0: #1e1e2e;
  fg0: #cdd6f4;
  accent: #89b4fa;
}

window {
  background-color: @bg0;
  border: 2px solid @accent;
  border-radius: 8px;
}

mainbox {
  children: [inputbar, listview];
}

inputbar {
  background-color: #313244;
  padding: 10px;
  children: [entry];
}

entry {
  text-color: @fg0;
  placeholder: "Search applications...";
}

listview {
  lines: 12;
  columns: 1;
}

element {
  padding: 8px;
}

element selected {
  background-color: @accent;
  text-color: @bg0;
  border-radius: 4px;
}
```


### Launcher Modes

**drun** - Launch desktop applications from `.desktop` files:[1]
```
bind = SUPER, D, exec, wofi --show drun
```


**run** - Execute arbitrary shell commands:[1]
```
bind = SUPER+SHIFT, D, exec, wofi --show run
```


**window** (Rofi only) - Switch between open windows:[1]
```
bind = ALT, Tab, exec, rofi -show window
```


### Window Switcher with Wofi

Use `wmctrl` with Wofi for window switching:[1]
```bash
wofi --show window
```


Not native; requires additional setup.[1]

### Custom Launchers

Create custom launcher scripts for specific workflows:[1]

**~/.config/wofi/scripts/launcher.sh:**
```bash
#!/bin/bash
CHOICE=$(cat << EOF | wofi --dmenu --prompt "Launch"
Firefox
Discord
Code
Terminal
EOF
)

case $CHOICE in
  Firefox) firefox ;;
  Discord) discord ;;
  Code) code ;;
  Terminal) kitty ;;
esac
```


Bind to keybind:[1]
```
bind = SUPER, D, exec, ~/.config/wofi/scripts/launcher.sh
```


### Quick Search Integration

Combine launcher with web searches:[1]
```bash
wofi --show drun --lines 5 | xargs -I {} bash -c "
  if [[ '{}' == *'search'* ]]; then
    firefox 'https://google.com/search?q=$(echo {} | sed s/search//)' &
  else
    {} &
  fi
"
```


### Comparison: Wofi vs Rofi

| Feature | Wofi | Rofi |
|---|---|---|
| Wayland Native | ✓ Yes | ✗ XWayland |
| Hyprland Optimized | ✓ Yes | ~ Works |
| Performance | Excellent | Good |
| Configuration | Simple | Complex |
| Theming | CSS | .rasi files |
| Window Switching | Plugin | Built-in |
| Customization | Good | Excellent |

[2][1]

### Example Comprehensive Launcher Setup

Add to `hyprland.conf`:
```
# Application launcher
bind = SUPER, D, exec, wofi --show drun
bind = SUPER+SHIFT, D, exec, wofi --show run

# Alternative: Rofi
# bind = SUPER, D, exec, rofi -show drun
# bind = SUPER+SHIFT, D, exec, rofi -show run

# Window switcher
bind = ALT, Tab, exec, wofi --show window
```


Create `~/.config/wofi/config`:
```
width=600
height=600
location=top_center
show=drun
allow_images=true
image_size=32
insensitive=true
filter_rate=100
accept_submission=true
hide_search=false
parse_search=false
```


Create `~/.config/wofi/style.css`:
```css
window {
  background-color: #1e1e2e;
  border: 2px solid #89b4fa;
  border-radius: 8px;
  font-family: monospace;
  font-size: 14px;
}

#input {
  background-color: #313244;
  color: #cdd6f4;
  padding: 10px;
  border-radius: 4px;
  margin: 5px;
}

#entry {
  padding: 8px;
  color: #cdd6f4;
}

#entry:selected {
  background-color: #89b4fa;
  color: #1e1e2e;
  border-radius: 4px;
}
```


Wofi is recommended as the primary launcher for Hyprland due to native Wayland support and seamless integration.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

