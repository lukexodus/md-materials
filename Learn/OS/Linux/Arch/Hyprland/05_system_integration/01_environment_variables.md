## Environment Variables


Environment variables in Hyprland configure system-level behavior, application compatibility, and Wayland protocol settings. They are set in `hyprland.conf` using the `env` keyword and persist throughout the Hyprland session.[1]

### Setting Environment Variables

The syntax is `env = VARIABLE_NAME,value`. Unlike standard shell syntax, Hyprland uses commas instead of equals signs to separate variable and value. Values can contain spaces without quoting:[1]
```
env = QT_QPA_PLATFORMTHEME,qt5ct
env = LIBVA_DRIVER_NAME,nvidia
env = GDK_SCALE,1.5
```


### Wayland and Display Protocol

**WAYLAND_DISPLAY** sets the Wayland socket path (automatically set by Hyprland, typically `wayland-0`). **DISPLAY** specifies X11 display for XWayland compatibility (automatically configured).[1]

**XDG_CURRENT_DESKTOP** identifies the running desktop environment; set to `Hyprland` for compatibility:[1]
```
env = XDG_CURRENT_DESKTOP,Hyprland
```


**XDG_SESSION_TYPE** specifies session type; set to `wayland` for Wayland-native behavior:[1]
```
env = XDG_SESSION_TYPE,wayland
```


### NVIDIA GPU Configuration

**LIBVA_DRIVER_NAME** sets video acceleration driver for NVIDIA (required for hardware video decoding):[2][1]
```
env = LIBVA_DRIVER_NAME,nvidia
```


**__GLX_VENDOR_LIBRARY_NAME** configures OpenGL vendor library for NVIDIA:[2]
```
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
```


**ELECTRON_OZONE_PLATFORM_HINT** enables Wayland support in Electron applications (Firefox, Chromium, VS Code):[2][1]
```
env = ELECTRON_OZONE_PLATFORM_HINT,auto
```


**AQ_DRM_DEVICES** specifies primary GPU for multi-GPU systems (NVIDIA-specific, rarely needed):[2]
```
env = AQ_DRM_DEVICES,/dev/dri/card0
```


**AQ_FORCE_LINEAR_BLIT** disables linear modifier forcing on multi-GPU buffers when set to 0 (NVIDIA-specific, may reduce performance on secondary monitors):[2]
```
env = AQ_FORCE_LINEAR_BLIT,0
```


### Cursor Configuration

**XCURSOR_THEME** sets XCursor theme name for applications not supporting hyprcursor:[3][4]
```
env = XCURSOR_THEME,Adwaita
```


**XCURSOR_SIZE** sets XCursor size in pixels (multiply by HiDPI scale factor for scaled displays):[4][3]
```
env = XCURSOR_SIZE,24
```


**HYPRCURSOR_THEME** sets hyprcursor theme (native Wayland cursor):[3]
```
env = HYPRCURSOR_THEME,Bibata-Modern-Classic
```


**HYPRCURSOR_SIZE** sets hyprcursor size (does not multiply by scale factor):[3]
```
env = HYPRCURSOR_SIZE,24
```


### Qt and GTK Configuration

**QT_QPA_PLATFORMTHEME** configures Qt5/Qt6 platform theme for consistent styling:[1]
```
env = QT_QPA_PLATFORMTHEME,qt5ct
```


**QT_SCALE_FACTOR** sets Qt application scaling for HiDPI (alternative to monitor scaling):[1]
```
env = QT_SCALE_FACTOR,1.5
```


**GDK_SCALE** sets GTK application scaling (integer values only, 1 or 2 typically):[1]
```
env = GDK_SCALE,2
```


**GTK_USE_PORTAL** enables XDG Desktop Portal for GTK file dialogs and other services:[1]
```
env = GTK_USE_PORTAL,1
```


### Locale and Language

**LANG** sets system language and locale:[1]
```
env = LANG,en_US.UTF-8
```


**LC_ALL** overrides all locale settings (rarely needed):[1]
```
env = LC_ALL,en_US.UTF-8
```


### Input Method (IME)

**XMODIFIERS** configures X11 input method for legacy applications:[1]
```
env = XMODIFIERS,@im=fcitx
```


**GTK_IM_MODULE** sets GTK input method engine:[1]
```
env = GTK_IM_MODULE,fcitx
```


**QT_IM_MODULE** sets Qt input method engine:[1]
```
env = QT_IM_MODULE,fcitx
```


### Application-Specific Variables

**ELECTRON_ENABLE_FEATURES** enables experimental Electron features (Wayland, etc.):[1]
```
env = ELECTRON_ENABLE_FEATURES,WaylandWindowDecorations
```


**CLUTTER_BACKEND** forces Clutter (used by some applications) to use Wayland instead of X11:[1]
```
env = CLUTTER_BACKEND,wayland
```


**SDL_VIDEODRIVER** configures SDL applications (games, some tools) to use Wayland:[1]
```
env = SDL_VIDEODRIVER,wayland
```


**JAVA_TOOL_OPTIONS** configures Java application scaling and Wayland support:[1]
```
env = JAVA_TOOL_OPTIONS,-Dswing.defaultlaf=javax.swing.plaf.gtk.GTKLookAndFeel
```


### Debugging and Development

**HYPRLAND_DEBUG** enables debug logging (rarely needed for end users):[1]
```
env = HYPRLAND_DEBUG,1
```


**VK_INSTANCE_LAYERS** enables Vulkan validation layers for debugging (development only):[1]
```
env = VK_INSTANCE_LAYERS,VK_LAYER_KHRONOS_validation
```


### GPU Driver Selection

**WLR_DRM_DEVICES** manually selects GPU devices on multi-GPU systems:[5][6]
```
env = WLR_DRM_DEVICES,/dev/dri/card1
```


This forces Hyprland to use card1 instead of auto-detection, useful for hybrid Intel/AMD or Intel/NVIDIA systems.[5]

### Example Comprehensive Environment Configuration

```
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = WAYLAND_DISPLAY,wayland-0

# Qt and GTK
env = QT_QPA_PLATFORMTHEME,qt5ct
env = QT_SCALE_FACTOR,1.5
env = GDK_SCALE,1
env = GTK_USE_PORTAL,1

# Cursor
env = XCURSOR_THEME,Adwaita
env = XCURSOR_SIZE,24
env = HYPRCURSOR_THEME,Bibata-Modern-Classic
env = HYPRCURSOR_SIZE,24

# Input method
env = XMODIFIERS,@im=fcitx
env = GTK_IM_MODULE,fcitx
env = QT_IM_MODULE,fcitx

# Application compatibility
env = ELECTRON_OZONE_PLATFORM_HINT,auto
env = SDL_VIDEODRIVER,wayland
env = CLUTTER_BACKEND,wayland

# NVIDIA-specific (if applicable)
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia

# Locale
env = LANG,en_US.UTF-8
```

Sources
[1] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/
[2] NVidia https://wiki.hypr.land/Nvidia/
[3] hyprcursor https://wiki.hypr.land/Hypr-Ecosystem/hyprcursor/
[4] Inconsistent cursor themes on GTK apps / Applications & ... https://bbs.archlinux.org/viewtopic.php?id=292763
[5] Run on Intel Integrated Graphics? : r/hyprland - Reddit https://www.reddit.com/r/hyprland/comments/178jldh/run_on_intel_integrated_graphics/
[6] Problem with Intel/AMD hybrid GPU in Hyprland - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=289555
[7] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland

