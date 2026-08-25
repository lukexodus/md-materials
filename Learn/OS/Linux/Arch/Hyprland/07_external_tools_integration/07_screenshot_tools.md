## Screenshot Tools


Screenshot and screen recording tools capture display content for sharing, documentation, or recording purposes within Hyprland. Wayland-native options provide seamless compositor integration without X11 compatibility issues.[1][2]

### Grim (Screenshot Utility)

**Grim** is a simple, fast screenshot tool designed for Wayland. Install on Arch Linux with `sudo pacman -S grim`.[2][1]

Capture entire screen:[1]
```bash
grim screenshot.png
```


Capture specific region:[1]
```bash
grim -g "0,0 640x480" screenshot.png
```


Capture specific output/monitor:[1]
```bash
grim -o DP-1 screenshot.png
```


### Slurp (Interactive Selection)

**Slurp** provides interactive region selection for screenshots. Install with `sudo pacman -S slurp`.[2][1]

Select region and capture:[1]
```bash
grim -g "$(slurp)" screenshot.png
```


This opens an interactive selection interface; drag to define capture area.[1]

### Integration: Grim + Slurp + Clipboard

Capture to clipboard directly:[1]
```bash
grim - | wl-copy
```


Capture region to clipboard:[1]
```bash
grim -g "$(slurp)" - | wl-copy
```


### Keybinds for Screenshots

Bind screenshot functions to keybinds in `hyprland.conf`:[1]
```
# Full screenshot to file
bind = , Print, exec, grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png

# Region screenshot to file
bind = SHIFT, Print, exec, grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png

# Full screenshot to clipboard
bind = SUPER, Print, exec, grim - | wl-copy

# Region screenshot to clipboard
bind = SUPER+SHIFT, Print, exec, grim -g "$(slurp)" - | wl-copy
```


### Notification Integration

Notify user after capture:[1]
```bash
grim ~/Pictures/screenshot.png && notify-send "Screenshot saved"
```


Copy to clipboard with notification:[1]
```bash
grim - | wl-copy && notify-send "Screenshot copied to clipboard"
```


### Swappy (Screenshot Editor)

**Swappy** provides screenshot annotation and editing. Install with `sudo pacman -S swappy`.[2][1]

Capture and edit:[1]
```bash
grim - | swappy -f -
```


Draw on screenshots, add text, shapes before saving.[1]

Bind to keybinds:[1]
```
bind = SUPER+SHIFT, S, exec, grim - | swappy -f -
```


### Flameshot (Advanced Screenshots)

**Flameshot** provides GUI-based screenshots with extensive editing. Install with `sudo pacman -S flameshot`.[1]

Launch with keybind:[1]
```
bind = , Print, exec, flameshot gui
```


Flameshot opens interactive selection with annotation tools.[1]

### Screen Recording with Wf-Recorder

**Wf-Recorder** captures screen video for Wayland. Install with `sudo pacman -S wf-recorder`.[2][1]

Record entire screen:[1]
```bash
wf-recorder -o output.mp4
```


Record specific region:[1]
```bash
wf-recorder -g "$(slurp)" -o output.mp4
```


Start recording with keybind:[1]
```
bind = SUPER, R, exec, wf-recorder -o ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4
```


Stop recording (requires separate daemon or keybind to pkill):[1]
```bash
pkill -INT wf-recorder
```


### Screen Recording with OBS Studio

**OBS Studio** provides professional recording with Wayland support via PipeWire. Install with `sudo pacman -S obs-studio`.[1]

Configure PipeWire source:[1]
1. Launch OBS
2. Source → Add → PipeWire Audio/Video Source
3. Configure scene and recording settings

Record with OBS keybind or launcher:[1]
```
bind = SUPER+SHIFT, R, exec, obs --multiprofile=streaming --collection=startup
```


### Screenshot Directory Organization

Create organized screenshot storage:[1]
```bash
mkdir -p ~/Pictures/Screenshots
```


Update capture paths in keybinds:[1]
```
bind = , Print, exec, grim ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png
```


### Automatic Screenshot Naming

Generate descriptive filenames:[1]
```bash
#!/bin/bash
SCREENSHOT_DIR=~/Pictures/Screenshots
FILENAME="$SCREENSHOT_DIR/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
grim -g "$(slurp)" "$FILENAME"
notify-send "Screenshot" "Saved to ${FILENAME##*/}"
```


Save as script and bind to keybinds:[1]
```
bind = SUPER+SHIFT, S, exec, ~/.config/hypr/scripts/screenshot.sh
```


### PipeWire Audio with Recordings

Capture system audio during recording:[1]

**Wf-Recorder with audio:**
```bash
wf-recorder --audio=alsa_output.pci-0000_00_1f.3.analog-stereo -o output.mp4
```


List available audio sources:[1]
```bash
pactl list sources
```


### Example Comprehensive Screenshot Configuration

Add to `hyprland.conf`:
```
# Full screenshot to file
bind = , Print, exec, grim ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send "Screenshot saved"

# Region screenshot to file
bind = SHIFT, Print, exec, grim -g "$(slurp)" ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send "Screenshot saved"

# Full screenshot to clipboard
bind = SUPER, Print, exec, grim - | wl-copy && notify-send "Screenshot copied to clipboard"

# Region screenshot to clipboard
bind = SUPER+SHIFT, Print, exec, grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot copied to clipboard"

# Screenshot with editing (Swappy)
bind = SUPER+CTRL, Print, exec, grim - | swappy -f -

# Screen recording
bind = SUPER, R, exec, wf-recorder -o ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4 && notify-send "Recording started"
bind = SUPER+SHIFT, R, exec, pkill -INT wf-recorder && notify-send "Recording stopped"
```


Create `~/.config/hypr/scripts/screenshot.sh`:
```bash
#!/bin/bash
SCREENSHOT_DIR=~/Pictures/Screenshots
mkdir -p "$SCREENSHOT_DIR"

case $1 in
  full)
    grim "$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
    ;;
  region)
    grim -g "$(slurp)" "$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
    ;;
  clipboard)
    grim - | wl-copy
    ;;
  edit)
    grim - | swappy -f -
    ;;
esac

notify-send "Screenshot" "Saved successfully"
```


Grim and Slurp provide the most efficient Wayland-native screenshot solution for Hyprland with minimal overhead.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

