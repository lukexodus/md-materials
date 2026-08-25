## Hyprcursor (Cursor Themes)


Hyprcursor is Hyprland's native cursor theme system providing GPU-accelerated cursor rendering with superior Wayland support compared to legacy XCursor. It enables fast cursor switching, animations, and consistent rendering across applications.[1][2]

### Architecture and Advantages

Hyprcursor is Wayland-native, avoiding X11 compatibility layers and providing **server-side cursor rendering** directly by the compositor. This contrasts with XCursor where applications render cursors independently, causing inconsistency and lag. Hyprcursor themes load into GPU memory, enabling instant switching without reloading.[2][1]

### Installation and Theme Directories

Install cursor themes in user directories to avoid permission issues:[1][2]
```
~/.local/share/icons/
~/.icons/
```


Do not use `/usr/share/icons` for user-installed themes—system-wide themes should be installed by package managers.[1][2]

### Setting Hyprcursor Theme and Size

Configure in `hyprland.conf` using environment variables:[2][1]
```
env = HYPRCURSOR_THEME,Bibata-Modern-Classic
env = HYPRCURSOR_SIZE,24
```


**HYPRCURSOR_THEME** specifies the theme name (directory name in `~/.local/share/icons/`). **HYPRCURSOR_SIZE** sets cursor size in pixels; use power-of-two values (12, 24, 48, etc.) to avoid scaling artifacts. Hyprcursor automatically scales by compositor zoom factor.[2][1]

### Runtime Cursor Switching

Change cursors without restarting using `hyprctl setcursor`:[1][2]
```bash
hyprctl setcursor Bibata-Modern-Classic 24
```


This immediately applies the new theme and size to all windows.[1][2]

### Available Hyprcursor Themes

Popular hypercursor themes include:[2][1]
- **Bibata-Modern-Classic** - Modern, smooth cursors
- **Bibata-Original-Classic** - Original Bibata design
- **Pointer-Catppuccin** - Catppuccin color scheme
- **macOS** - macOS-style cursors
- **Adwaita** - GNOME Adwaita theme
- **Breeze** - KDE Breeze theme

[1][2]

Install themes with package managers or manually extract to `~/.local/share/icons/`.[2][1]

### Application Support for Hyprcursor

**Full Support:**
- Qt5, Qt6 applications
- Chromium, Electron
- Hyprland ecosystem (waybar, wofi, etc.)
- Most Wayland-native applications

[1][2]

**Limited/No Support:**
- GTK applications (fall back to XCursor)
- Some legacy X11 applications under XWayland

[2][1]

### XCursor Fallback Configuration

For applications not supporting hypercursor, configure XCursor as fallback:[3][1]
```
env = XCURSOR_THEME,Adwaita
env = XCURSOR_SIZE,24
```


GTK applications specifically require additional configuration:[3][1]
```
gsettings set org.gnome.desktop.interface cursor-theme 'ThemeName'
gsettings set org.gnome.desktop.interface cursor-size 24
```


If `gsettings` is unavailable (NixOS, minimal systems), use `dconf`:[1]
```bash
dconf write /org/gnome/desktop/interface/cursor-theme \"'ThemeName'\"
dconf write /org/gnome/desktop/interface/cursor-size 24
```


### Multi-Framework Cursor Configuration

For comprehensive cursor consistency across all applications:[3]

**~/.config/hyprland.conf:**
```
env = XCURSOR_THEME,ThemeName
env = XCURSOR_SIZE,24
env = HYPRCURSOR_THEME,ThemeName
env = HYPRCURSOR_SIZE,24
```


**~/.config/gtk-3.0/settings.ini and ~/.config/gtk-4.0/settings.ini:**
```
gtk-cursor-theme-name=ThemeName
gtk-cursor-theme-size=24
```


**~/.icons/default/index.theme:**
```
[Icon Theme]
Inherits=ThemeName
```


**Qt5/Qt6:** Use `qt5ct` and `qt6ct` GUI tools or set environment variables:[3]
```
env = QT_QPA_PLATFORMTHEME,qt5ct
```


**~/.config/xsettingsd/xsettingsd.conf:**
```
Gtk/CursorThemeName "ThemeName"
Gtk/CursorThemeSize 24
```


### HiDPI Scaling Considerations

On HiDPI displays with fractional scaling (e.g., 1.5x):[4][3]

**Hypercursor:** Set size without multiplying by scale (hypercursor handles scaling automatically):[4][1]
```
env = HYPRCURSOR_SIZE,24
```


**XCursor:** Multiply size by scale factor for displays other than hypercursor users:[4][3]
```
env = XCURSOR_SIZE,36  # 24 × 1.5 for 1.5x scaling
```


### Flatpak Application Support

Flatpak applications require additional filesystem permissions to access cursor themes:[1]
```bash
flatpak override --filesystem=~/.icons:ro --filesystem=~/.local/share/icons:ro --user
```


Copy cursor themes to both locations:[1]
```bash
cp -r ~/.icons/ThemeName ~/.local/share/icons/
```


### Creating Custom Hypercursor Themes

Hypercursor themes are directory-based with specific structure. Modify existing themes by copying and customizing cursor files in the theme directory.[2][1]

Documentation available at official Hypercursor repositories for theme development.[1]

### Cursor Animation

Some hypercursor themes support animated cursors for loading, waiting, and other states. Animation occurs at the compositor level without application overhead.[2][1]

### Example Comprehensive Cursor Configuration

```
# Hypercursor (primary)
env = HYPRCURSOR_THEME,Bibata-Modern-Classic
env = HYPRCURSOR_SIZE,24

# XCursor fallback
env = XCURSOR_THEME,Adwaita
env = XCURSOR_SIZE,24

# Qt configuration
env = QT_QPA_PLATFORMTHEME,qt5ct

# Runtime switching keybind
bind = SUPER+SHIFT, C, exec, hyprctl setcursor Bibata-Modern-Classic 24 && notify-send "Cursor theme changed"
```


### Troubleshooting

**Cursor not changing:** Verify theme name matches directory in `~/.local/share/icons/`; check with `ls ~/.local/share/icons/`. Restart Hyprland if environment variables changed in config.[1]

**GTK applications show XCursor:** GTK falls back to XCursor; ensure GTK cursor settings match hypercursor configuration. Use `gsettings` or `dconf` to configure GTK specifically.[3][1]

**Permission denied:** Ensure icons directory is readable: `chmod 755 ~/.local/share/icons/ThemeName`.[1]

**Flatpak cursors missing:** Add filesystem permissions and copy themes to both standard and Flatpak directories.[1]

Sources
[1] hyprcursor https://wiki.hypr.land/Hypr-Ecosystem/hyprcursor/
[2] Hyprcursor https://wiki.hypr.land/hyprland-wiki/pages/Hypr-Ecosystem/hyprcursor/
[3] Inconsistent cursor themes on GTK apps / Applications & ... https://bbs.archlinux.org/viewtopic.php?id=292763
[4] Cursor size with HiDPi · Issue #2448 · hyprwm/Hyprland https://github.com/hyprwm/Hyprland/issues/2448

