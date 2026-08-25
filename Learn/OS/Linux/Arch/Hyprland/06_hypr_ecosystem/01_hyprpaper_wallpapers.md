## Hyprpaper (Wallpapers)


Hyprpaper is Hyprland's native wallpaper manager providing efficient, GPU-accelerated wallpaper rendering with multi-monitor support, animated wallpapers, and dynamic configuration. It integrates seamlessly with Hyprland and avoids the overhead of separate wallpaper daemons.[1][2]

### Installation and Startup

Install Hyprpaper on Arch Linux with `sudo pacman -S hyprpaper`. Start automatically on Hyprland launch by adding to `hyprland.conf`:[1]
```
exec-once = hyprpaper
```


### Configuration File

Hyprpaper uses `~/.config/hypr/hyprpaper.conf` for configuration. Create this file if it doesn't exist.[1]

### Basic Wallpaper Setup

Set wallpapers per-monitor using the `preload` directive to cache images and `wallpaper` to assign:[2][1]
```
preload = ~/Pictures/wallpaper1.png
preload = ~/Pictures/wallpaper2.png
preload = ~/Pictures/wallpaper3.png

wallpaper = DP-1,~/Pictures/wallpaper1.png
wallpaper = HDMI-1,~/Pictures/wallpaper2.png
wallpaper = eDP-1,~/Pictures/wallpaper3.png
```


Preload loads images into memory and GPU for instant switching; wallpaper assignments apply specific images to monitors identified by their port names.[1][2]

### Dynamic Wallpaper Switching

Change wallpapers at runtime using `hyprctl hyprpaper switchwall`:[2][1]
```bash
hyprctl hyprpaper switchwall
```


This cycles through preloaded wallpapers. Create keybinds for easy wallpaper rotation:[2][1]
```
bind = SUPER, W, exec, hyprctl hyprpaper switchwall
```


### Sorting and Layout

**Sorting behavior:** Hyprpaper sorts wallpapers alphabetically when using `switchwall`. Name wallpapers numerically (01.png, 02.png, etc.) for predictable cycling order.[1]

**Monitor assignment:** Specify wallpapers for all connected monitors; omitted monitors use the previous wallpaper. Use monitor descriptions for device-agnostic configuration:[1]
```
wallpaper = desc:Chimei Innolux Corporation 0x150C,~/Pictures/wallpaper.png
```


### Animated Wallpapers

Hyprpaper supports animated GIFs and video files:[1]
```
preload = ~/Pictures/animated.gif
wallpaper = DP-1,~/Pictures/animated.gif
```


For video wallpapers, ensure the file format is supported (typically MP4 or WebM).[1]

### Wallpaper Scaling and Positioning

Hyprpaper automatically scales wallpapers to fill monitor resolution. Wallpapers stretch or shrink to match aspect ratio; no explicit scaling configuration exists.[1]

### Memory and Performance

**Preload optimization:** Preload images only if they'll be used; unnecessary preloads consume VRAM. Typical wallpapers use 10-50MB VRAM depending on resolution.[1]

**Format recommendations:** Use PNG for lossless quality and smaller file sizes than JPEG; JPEG acceptable for photographs. Avoid very large resolutions; 2560x1440 or 3840x2160 are typical limits.[1]

### Hyprpaper Commands

**Query current wallpaper:** `hyprctl hyprpaper listcurpaper` displays currently assigned wallpapers.[1]

**List preloaded:** `hyprctl hyprpaper listloaded` shows cached wallpapers.[1]

**Switch wallpaper:** `hyprctl hyprpaper switchwall` cycles to next wallpaper.[1]

**Set specific wallpaper:** `hyprctl hyprpaper wallpaper DP-1,~/Pictures/specific.png` assigns to specific monitor.[1]

### Alternative: swaybg

**swaybg** is a simpler lightweight alternative for static wallpapers:[1]
```
exec-once = swaybg -i ~/Pictures/wallpaper.png
```


Swaybg supports only static images and single wallpaper (same for all monitors), but uses less overhead than Hyprpaper. Good for minimal setups.[1]

### Alternative: mpvpaper

**mpvpaper** enables animated and video wallpapers using mpv player:[1]
```
exec-once = mpvpaper --auto-pause -z zoom eDP-1 ~/Videos/wallpaper.mp4
```


Mpvpaper supports any format mpv handles (MP4, WebM, GIF, etc.) but uses more CPU/GPU than Hyprpaper.[1]

### Wallpaper Collections and Themes

Organize wallpapers in subdirectories:[1]
```
~/Pictures/wallpapers/
  ├── dark/
  ├── light/
  └── animated/
```


Switch themes by changing preload directives or creating multiple configuration files.[1]

### Dynamic Wallpaper Switching Scripts

Create scripts for themed wallpaper switching:[1]

**`~/.config/hypr/scripts/wallpaper-dark.sh`:**
```bash
#!/bin/bash
hyprctl hyprpaper preload ~/Pictures/wallpapers/dark/1.png
hyprctl hyprpaper preload ~/Pictures/wallpapers/dark/2.png
hyprctl hyprpaper wallpaper DP-1,~/Pictures/wallpapers/dark/1.png
hyprctl hyprpaper wallpaper HDMI-1,~/Pictures/wallpapers/dark/2.png
```


Bind to keybinds:[1]
```
bind = SUPER, D, exec, ~/.config/hypr/scripts/wallpaper-dark.sh
bind = SUPER, L, exec, ~/.config/hypr/scripts/wallpaper-light.sh
```


### Example Hyprpaper Configuration

```
# Preload wallpapers
preload = ~/Pictures/wallpapers/01.png
preload = ~/Pictures/wallpapers/02.png
preload = ~/Pictures/wallpapers/03.png
preload = ~/Pictures/wallpapers/animated.gif

# Assign to monitors
wallpaper = DP-1,~/Pictures/wallpapers/01.png
wallpaper = HDMI-1,~/Pictures/wallpapers/02.png
wallpaper = eDP-1,~/Pictures/wallpapers/animated.gif

# ipc = off   # Disable IPC for security (optional)
```


Add to `hyprland.conf`:
```
exec-once = hyprpaper

bind = SUPER, W, exec, hyprctl hyprpaper switchwall
bind = SUPER+SHIFT, W, exec, ~/.config/hypr/scripts/wallpaper-random.sh
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

