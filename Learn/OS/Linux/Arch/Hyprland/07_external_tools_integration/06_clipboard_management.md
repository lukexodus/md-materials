## Clipboard Management


Clipboard management on Wayland requires specialized tools to handle text, images, and clipboard history since Wayland's security model isolates clipboard access. Hyprland supports multiple clipboard solutions for different workflows.[1][2]

### Wl-Clipboard (Core Utility)

**wl-clipboard** is the fundamental clipboard utility for Wayland, providing command-line access to clipboard functions. Install on Arch Linux with `sudo pacman -S wl-clipboard`.[2][1]

Copy to clipboard:[1]
```bash
echo "text" | wl-copy
```


Paste from clipboard:[1]
```bash
wl-paste
```


### Clipboard History with Cliphist

**Cliphist** maintains clipboard history for both text and images. Install with `sudo pacman -S cliphist`.[2][1]

Start clipboard history daemon on Hyprland launch:[1]
```
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
```


The first watches text clipboard changes, the second watches image clipboard changes.[1]

### Accessing Clipboard History

Display history with Rofi/Wofi menu:[1]
```bash
cliphist list | rofi -dmenu | cliphist decode | wl-copy
cliphist list | wofi --dmenu | cliphist decode | wl-copy
```


Bind to keybinds:[1]
```
bind = SUPER, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy
```


This opens a menu showing previous clipboard entries.[1]

### Clearing Clipboard History

Delete all clipboard history:[1]
```bash
cliphist wipe
```


Delete specific entry by selecting in menu:[1]
```bash
cliphist list | wofi --dmenu | cliphist delete
```


### Alternative: Clipse (TUI)

**Clipse** is a terminal-based clipboard manager with simpler functionality. Install from AUR with `yay -S clipse`.[1]

Start daemon:[1]
```
exec-once = clipse
```


Access history in terminal:[1]
```bash
clipse
```


### Clipboard for X11 Applications (XWayland)

Wayland clipboard does not automatically sync with X11 clipboard; XWayland applications require bridge utilities.[1]

Install `xclip` or `xsel` for X11 clipboard access:[1]
```bash
sudo pacman -S xclip xsel
```


XWayland applications can use these utilities directly.[1]

### Integrating wl-clipboard with Shell

Add shell aliases for convenience:[1]
```bash
# ~/.bashrc or ~/.zshrc
alias pbcopy='wl-copy'
alias pbpaste='wl-paste'
```


Enables macOS-style clipboard commands.[1]

### Primary and Clipboard Selections

Wayland supports primary selection (middle-click paste) and clipboard selection:[1]

Copy to primary selection:[1]
```bash
echo "text" | wl-copy -p
```


Paste from primary selection:[1]
```bash
wl-paste -p
```


### Clipboard with Images

Handle image clipboard operations:[1]

Copy image to clipboard:[1]
```bash
wl-copy < image.png
```


Paste image from clipboard:[1]
```bash
wl-paste > image.png
```


View clipboard image types:[1]
```bash
wl-paste --list-types
```


### Script Integration

Use clipboard in shell scripts:[1]
```bash
#!/bin/bash
# Get current date and copy to clipboard
DATE=$(date "+%Y-%m-%d %H:%M:%S")
echo "$DATE" | wl-copy
notify-send "Clipboard" "Date copied: $DATE"
```


Bind to keybinds:[1]
```
bind = SUPER, C, exec, ~/.config/hypr/scripts/clipboard-date.sh
```


### QR Code Clipboard

Generate QR code from clipboard content:[1]
```bash
#!/bin/bash
CONTENT=$(wl-paste)
echo "$CONTENT" | qrencode -o - | wl-copy
notify-send "QR Code" "Generated from clipboard"
```


### Password Manager Integration

Access passwords through clipboard managers like `pass`:[1]
```bash
# Copy password to clipboard with timeout
pass show -c "password/path"
```


Integrate with launcher:[1]
```
bind = SUPER+CTRL, P, exec, pass show -c $(pass ls -1 | wofi --dmenu)
```


### Clipboard Monitoring for Security

Monitor clipboard activity for debugging or security:[1]
```bash
#!/bin/bash
while true; do
  CURRENT=$(wl-paste)
  echo "Clipboard: $CURRENT" >> ~/.local/share/clipboard.log
  sleep 5
done
```


### Example Comprehensive Clipboard Configuration

Add to `hyprland.conf`:
```
# Clipboard history daemon
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store

# Keybinds
bind = SUPER, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy
bind = SUPER+SHIFT, V, exec, cliphist list | wofi --dmenu | cliphist delete
bind = SUPER+CTRL, V, exec, cliphist wipe && notify-send "Clipboard cleared"

# Copy utilities
bind = SUPER, C, exec, date "+%Y-%m-%d %H:%M:%S" | wl-copy && notify-send "Date copied"
bind = SUPER+SHIFT, C, exec, pass show -c $(pass ls -1 | wofi --dmenu)
```


Create `~/.config/hypr/scripts/clipboard-menu.sh`:
```bash
#!/bin/bash
case $1 in
  show)
    cliphist list | wofi --dmenu | cliphist decode | wl-copy
    ;;
  delete)
    cliphist list | wofi --dmenu | cliphist delete
    ;;
  clear)
    cliphist wipe
    notify-send "Clipboard history cleared"
    ;;
esac
```


Cliphist with Wofi provides the most comprehensive Wayland-native clipboard management for Hyprland.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

