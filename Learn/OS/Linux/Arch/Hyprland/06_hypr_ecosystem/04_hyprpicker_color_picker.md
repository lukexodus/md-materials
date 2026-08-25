## Hyprpicker (Color Picker)


Hyprpicker is Hyprland's native GPU-accelerated color picker utility for quickly grabbing colors from the screen. It operates as a standalone command-line tool with minimal dependencies and no external configuration required.[1][3][4]

### Installation

Install Hyprpicker on Arch Linux with `sudo pacman -S hyprpicker`. The application is available in most distribution repositories and can be built from source if needed.[4][5]

### Basic Usage

Launch Hyprpicker by executing the command:[4]
```bash
hyprpicker
```


When launched, the screen freezes displaying a magnified view of your cursor area. Click on the desired color and it outputs to stdout. The tool closes automatically after picking.[1][4]

### Output Formats

Specify output format with the `-f` or `--format` flag:[1]

**Hexadecimal (default):**
```bash
hyprpicker -f hex
```


Outputs: `#a1b2c3`[1]

**RGB:**
```bash
hyprpicker -f rgb
```


Outputs: `rgb(161, 178, 195)`[1]

**HSL:**
```bash
hyprpicker -f hsl
```


Outputs: `hsl(210, 9%, 70%)`[1]

**HSV:**
```bash
hyprpicker -f hsv
```


Outputs: `hsv(210, 9%, 76%)`[1]

**CMYK:**
```bash
hyprpicker -f cmyk
```


Outputs: `cmyk(18, 9, 0, 24)`[1]

### Automatic Clipboard Copy

Automatically copy the picked color to clipboard with the `-a` or `--autocopy` flag (requires `wl-clipboard`):[1]
```bash
hyprpicker -a
```


Combine with format flag:[1]
```bash
hyprpicker -a -f hex
```


### Visual Options

**Disable zoom lens:** Remove the magnified display area with `-z` or `--no-zoom`:[1]
```bash
hyprpicker -z
```


**Render inactive displays:** Freeze all displays including secondary monitors with `-r` or `--render-inactive`:[1]
```bash
hyprpicker -r
```


**Disable hex preview:** Remove the live hex code display with `-d` or `--disable-hex-preview`:[1]
```bash
hyprpicker -d
```


**Lowercase hex:** Output hexadecimal in lowercase with `-l` or `--lowercase-hex`:[1]
```bash
hyprpicker -l
```


Outputs: `#a1b2c3` instead of `#A1B2C3`[1]

**Disable colored output:** Remove fancy colored terminal output with `-n` or `--no-fancy`:[1]
```bash
hyprpicker -n
```


### Quiet Mode

Suppress informational logs while preserving errors with `-q` or `--quiet`:[1]
```bash
hyprpicker -q
```


### Keybind Integration

Bind Hyprpicker to keybinds for quick access:[5]
```
bind = SUPER, P, exec, hyprpicker -a -f hex
```


This launches the picker with automatic clipboard copy in hexadecimal format.[5]

### Shell Script Integration

Capture color output in shell scripts:[1]
```bash
#!/bin/bash
COLOR=$(hyprpicker -a -f hex)
echo "Picked color: $COLOR"
notify-send "Color picked" "$COLOR"
```


This picks a color, copies it, and sends a notification.[1]

### Waybar Integration

Display recently picked colors in Waybar status bar. Create a Waybar module that calls Hyprpicker and maintains color history.[2]

### Advanced: Fuzzel-based Color Picker

Enhance Hyprpicker with a Fuzzel-based GUI wrapper maintaining color history and keyboard navigation. Scripts like `fuzzel-hyprpicker.sh` provide persistent history and easy color selection.[6]

### Limitations and Notes

**Display freeze:** Hyprpicker freezes displays while picking color to provide accurate sampling. This is expected behavior and necessary for reliable color detection.[4][1]

**No GUI:** Hyprpicker is CLI-only; third-party GUIs like Fuzzel wrappers are needed for traditional point-and-click interfaces.[3][6]

**Wayland requirement:** Works exclusively on Wayland; X11 is not supported.[4][1]

### Example Comprehensive Usage

**Complex script with multiple formats:**
```bash
#!/bin/bash
echo "Pick a color..."
HEX=$(hyprpicker -f hex)
RGB=$(hyprpicker -f rgb)
HSL=$(hyprpicker -f hsl)

echo "Hex: $HEX"
echo "RGB: $RGB"
echo "HSL: $HSL"

echo "$HEX" | wl-copy
notify-send "Color Picker" "Hex color copied: $HEX"
```


**Keybind with notifications:**
```
bind = SUPER, C, exec, hyprpicker -a -f hex && notify-send "Color copied to clipboard"
```


**Format cycling:**
```
bind = SUPER, C, exec, hyprpicker -a -f hex
bind = SUPER+SHIFT, C, exec, hyprpicker -a -f rgb
bind = ALT, C, exec, hyprpicker -a -f hsl
```

Sources
[1] hyprpicker https://wiki.hypr.land/Hypr-Ecosystem/hyprpicker/
[2] Sip color picker for Hyprland https://www.reddit.com/r/hyprland/comments/1iziy03/sip_color_picker_for_hyprland/
[3] Color pickers https://wiki.hypr.land/Useful-Utilities/Color-Pickers/
[4] hyprwm/hyprpicker: A wlroots-compatible Wayland color ... https://github.com/hyprwm/hyprpicker
[5] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[6] Fuzzel Colour Picker https://wimpysworld.com/posts/fuzzel-hyprpicker/
[7] 3217 Hyprland - hyprpicker - look up colors and change them https://www.youtube.com/watch?v=U3VwvbM8SEA
[8] Here's How You Can Customize Linux Desktop ... https://itsfoss.com/hyprland-halloween-customization/
[9] x11/hyprpicker: Color picker and magnifier for Wayland https://www.freshports.org/x11/hyprpicker
[10] hyprpicker/README.md at v0.4.0 https://code.hyprland.org/hyprwm/hyprpicker/src/tag/v0.4.0/README.md?display=source

