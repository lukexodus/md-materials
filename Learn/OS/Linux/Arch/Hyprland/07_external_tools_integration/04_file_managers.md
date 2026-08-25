## File Managers


File managers provide graphical interfaces for browsing, organizing, and manipulating files within Hyprland. Wayland-native options offer seamless integration, while X11-based managers work through XWayland compatibility.[1][2]

### Thunar (Lightweight GTK)

**Thunar** is a lightweight, feature-rich file manager with minimal dependencies. Install on Arch Linux with `sudo pacman -S thunar`.[1]

Launch with keybind:[1]
```
bind = SUPER, E, exec, thunar
```


Configure in `~/.config/Thunar/thunarrc`:[1]
```ini
[View]
ShowHidden=TRUE
SortFoldersFist=TRUE
DateStyle=ISO
ListViewZoom=THUNAR_ZOOM_LEVEL_100
```


### Nautilus (GNOME Files)

**Nautilus** is the GNOME file manager with modern design and search integration. Install with `sudo pacman -S nautilus`.[1]

Launch with keybind:[1]
```
bind = SUPER, E, exec, nautilus --new-window
```


Modern but heavier than Thunar; includes features like tagging and network browsing.[1]

### Dolphin (KDE Plasma)

**Dolphin** is the KDE file manager with dual-pane support and extensive customization. Install with `sudo pacman -S dolphin`.[1]

Launch with keybind:[1]
```
bind = SUPER, E, exec, dolphin
```


Feature-rich but requires KDE/Qt dependencies.[1]

### PCManFM-Qt (Lightweight)

**PCManFM-Qt** is a minimal file manager using Qt framework. Install with `sudo pacman -S pcmanfm-qt`.[1]

Launch with keybind:[1]
```
bind = SUPER, E, exec, pcmanfm-qt
```


Lightweight alternative to Dolphin with basic functionality.[1]

### Spacefm (Advanced)

**Spacefm** is an advanced, highly customizable file manager with scripting support. Install from AUR with `yay -S spacefm`.[1]

Launch with keybind:[1]
```
bind = SUPER, E, exec, spacefm
```


### Ranger (Terminal-Based)

**Ranger** is a terminal-based file manager for command-line workflows. Install with `sudo pacman -S ranger`.[1]

Launch in terminal:[1]
```
bind = SUPER, E, exec, kitty ranger
```


Keyboard-driven, efficient for developers.[1]

### Nnn (Minimal Terminal)

**Nnn** is an extremely minimal terminal file manager emphasizing speed. Install with `sudo pacman -S nnn`.[1]

Launch in terminal:[1]
```
bind = SUPER, E, exec, foot nnn
```


Lightweight, fast, minimal dependencies.[1]

### File Manager Features Comparison

| Manager | Type | GTK/Qt | Dual-Pane | Tagging | Network | Speed |
|---|---|---|---|---|---|---|
| Thunar | GUI | GTK | ✗ No | ~ Basic | ~ Yes | Excellent |
| Nautilus | GUI | GTK | ✗ No | ✓ Yes | ✓ Yes | Good |
| Dolphin | GUI | Qt | ✓ Yes | ✓ Yes | ✓ Yes | Good |
| PCManFM-Qt | GUI | Qt | ~ Basic | ✗ No | ~ Basic | Excellent |
| Spacefm | GUI | GTK | ✓ Yes | ✓ Yes | ✓ Yes | Good |
| Ranger | TUI | N/A | ✓ Yes | ~ Basic | ✗ No | Excellent |
| Nnn | TUI | N/A | ✓ Yes | ✗ No | ✗ No | Excellent |

[2][1]

### Archiving and Compression

GUI file managers integrate with archive handlers:[1]

Install archive utilities:[1]
```bash
sudo pacman -S xarchiver bzip2 gzip p7zip unrar
```


File managers automatically handle extraction and compression through context menus.[1]

### Custom Actions and Scripts

Create custom context menu actions in Thunar:[1]

**~/.local/share/Thunar/sendto/custom-action.desktop:**
```ini
[Desktop Entry]
Type=Action
Name=Open Terminal Here
Icon=utilities-terminal
Exec=kitty --working-directory %f
MimeTypes=inode/directory;
```


### Thumbnail Support

Enable thumbnail generation for images:[1]

**Thunar:**
```ini
[View]
ShowThumbnails=TRUE
ThumbnailSize=THUNAR_THUMBNAIL_SIZE_128
```


### Trash and Safety

Configure trash functionality instead of permanent deletion:[1]

Most GUI file managers support trash by default; terminal managers require `trash-cli`:[1]
```bash
sudo pacman -S trash-cli
```


Use `trash-put filename` instead of `rm filename`.[1]

### Bookmarks and Quick Access

Create bookmarks for frequently accessed directories:[1]

Most GUI managers support dragging directories to a sidebar. Create manual bookmarks:[1]
```bash
# Thunar
mkdir -p ~/.config/Thunar
echo /home/user/Projects > ~/.config/Thunar/bookmarks
```


### Remote/Network Access

Access remote servers through file managers:[1]

**Via SSH/SFTP:**
Most managers support `sftp://user@host/path` URIs.[1]

**Manual mounting:**
```bash
sudo pacman -S gvfs
# Enables automatic mounting in GUI file managers
```


### Integration with Hyprland

**Preview pane in Ranger:**
Configure image preview in terminal:[1]
```bash
ranger --confdir ~/.config/ranger
```


**File manager as dialog:**
Use file managers for open/save dialogs via XDG Desktop Portal:[1]
```
exec-once = /usr/libexec/xdg-desktop-portal-hyprland
```


### Example Comprehensive File Manager Configuration

Add to `hyprland.conf`:
```
# Primary file manager (Thunar)
bind = SUPER, E, exec, thunar

# Alternative file managers
bind = SUPER+SHIFT, E, exec, nautilus --new-window
bind = SUPER+ALT, E, exec, dolphin

# Terminal file managers
bind = SUPER+CTRL, E, exec, kitty ranger
bind = SUPER+CTRL+ALT, E, exec, foot nnn

# XDG Desktop Portal for file dialogs
exec-once = /usr/libexec/xdg-desktop-portal-hyprland
```


Configure Thunar in `~/.config/Thunar/thunarrc`:
```ini
[View]
ShowHidden=TRUE
SortFoldersFist=TRUE
DateStyle=ISO
ListViewZoom=THUNAR_ZOOM_LEVEL_100

[Misc]
UseTabbed=TRUE
MiscConfirmClose=TRUE
MiscShowAboutDialogs=TRUE
```


Thunar is recommended for Hyprland as a lightweight, feature-complete GUI file manager requiring minimal dependencies.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

