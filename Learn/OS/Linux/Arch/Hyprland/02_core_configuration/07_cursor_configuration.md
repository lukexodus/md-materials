## Cursor Configuration


Hyprland supports two cursor systems: the newer **hyprcursor** format and the legacy **XCursor** format. Hyprcursor is the recommended native Wayland cursor system with advantages over XCursor, though not all applications support it yet.[1][2]

### Hyprcursor Configuration

Hyprcursor themes are placed in `~/.local/share/icons` or `~/.icons` (user-installed themes should not use system-wide `/usr/share/icons` due to permission issues).[2][1]

Set the hypercursor theme and size using environment variables in `hyprland.conf`:[1][2]
```
env = HYPRCURSOR_THEME,MyCursor
env = HYPRCURSOR_SIZE,24
```


Alternatively, use the `hyprctl setcursor` command to change cursors at runtime without restarting. Cursor sizes should follow power-of-two scaling (12, 24, 48, etc.) to avoid scaling artifacts.[3][1][2]

### Hypercursor Limitations

Although Qt, Chromium, Electron, and Hyprland ecosystem applications support server-side hypercursors, some applications like GTK do not and fall back to XCursor. This means different cursor systems may appear in different applications.[1][2]

### XCursor Fallback Configuration

For applications not supporting hypercursor, configure XCursor theme and size:[2][1]
```
env = XCURSOR_THEME,YourTheme
env = XCURSOR_SIZE,24
```


For GTK applications specifically, also run:[1][2]
```
gsettings set org.gnome.desktop.interface cursor-theme 'ThemeName'
gsettings set org.gnome.desktop.interface cursor-size 24
```


If `gsettings` schemas are unavailable (e.g., NixOS), use `dconf` instead:[1]
```
dconf write /org/gnome/desktop/interface/cursor-theme \"'ThemeName'\"
dconf write /org/gnome/desktop/interface/cursor-size 24
```


### Multi-Framework Configuration

For comprehensive cursor consistency across all application frameworks, configure all relevant config files:[4]

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


**~/.Xresources and ~/.Xdefaults:**
```
Xcursor.theme: ThemeName
Xcursor.size: 24
```


**Qt5/Qt6 Configuration:** Use `qt5ct` and `qt6ct` GUI tools or set `QT_QPA_PLATFORMTHEME=qt5ct` or `qt6ct` environment variables to configure cursor themes.[4]

**~/.config/xsettingsd/xsettingsd.conf:** Useful for non-GTK/XWayland applications:[4]
```
Gtk/CursorThemeName "ThemeName"
Gtk/CursorThemeSize 24
```


**~/.icons/default/index.theme:**
```
[Icon Theme]
Inherits=ThemeName
```


### HiDPI Scaling Considerations

On HiDPI displays with fractional scaling (e.g., 1.5x), account for the scale factor when setting XCursor size—multiply the desired size by the scale factor (e.g., 30 × 1.5 = 45 for xsettingsd). Hyprcursor handles scaling automatically, so hypercursor sizes should not be multiplied.[5][4]

### Flatpak Applications

For Flatpak applications, override filesystem access and place themes in both user and system directories:[2][1]
```
flatpak override --filesystem=~/.themes:ro --filesystem=~/.icons:ro --user
```


Copy cursor themes to both `~/.icons` and `/usr/share/icons` for Flatpak accessibility.[1]

### No Hypercursor Fallback

If no hypercursor themes are installed, Hyprland automatically falls back to XCursor and uses `XCURSOR_THEME` and `XCURSOR_SIZE` environment variables.[2][1]

Sources
[1] hyprcursor https://wiki.hypr.land/Hypr-Ecosystem/hyprcursor/
[2] Hyprcursor https://wiki.hypr.land/hyprland-wiki/pages/Hypr-Ecosystem/hyprcursor/
[3] How to change mouse cursor #624 https://github.com/HyDE-Project/HyDE/discussions/624
[4] Inconsistent cursor themes on GTK apps / Applications & ... https://bbs.archlinux.org/viewtopic.php?id=292763
[5] Cursor size with HiDPi · Issue #2448 · hyprwm/Hyprland https://github.com/hyprwm/Hyprland/issues/2448
[6] Cursor size smaller on desktop than everywhere else https://www.reddit.com/r/hyprland/comments/1dgmg4w/cursor_size_smaller_on_desktop_than_everywhere/
[7] Variables https://wiki.hyprland.org/0.46.0/Configuring/Variables/
[8] ArcoLinux : 3253 Hyprland - change the cursor size https://www.youtube.com/watch?v=tn0AH9_gjeE
[9] Cursor size in wayland/sway - Help https://discourse.nixos.org/t/cursor-size-in-wayland-sway/25112


