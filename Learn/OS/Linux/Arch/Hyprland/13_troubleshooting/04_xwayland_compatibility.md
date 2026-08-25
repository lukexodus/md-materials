## XWayland Compatibility


### Overview

- XWayland allows legacy X11 applications to run inside Wayland compositors like Hyprland.[1]
- Most traditional Linux apps that do not have native Wayland support will seamlessly start under XWayland, but with some caveats regarding performance, input lag, and scaling.[2][3]

### Key Issues and Workarounds

- **Scaling and HiDPI**: Fractional scaling is not well supported; XWayland clients often appear blurry unless using integer scaling. Stick to scale factors of 1 or 2 for best quality, and use per-app zoom when available.[4][5]
- **Clipboard and Drag-and-Drop**: Most clipboard managers work with XWayland apps, but advanced features or rich content copying (especially images/formats) may fail intermittently.[6][2]
- **Input Issues**: Some X11 apps (such as older games or Java UIs) may have keyboard, focus, or mouse problems. Window rules and input remapping in `hyprland.conf` can resolve many of these bugs, but certain edge cases may remain.[7][2]
- **VSync and Performance**: XWayland applications can stutter or tear if GPU drivers or compositor settings aren’t tuned, especially with NVIDIA. Tweak `vsync`, `max_fps`, and related Hyprland/GPU env variables for optimal behavior.[8][2]
- **Window Rules**: Popups, dialogs, or special windows in XWayland apps sometimes don’t gain focus or appear behind other windows. Add targeted `windowrule` or `windowrulev2` rules in your config for these cases.[9][2]

### NVIDIA Specifics

- For NVIDIA GPUs, it’s critical to set:
  ```
  env = __GLX_VENDOR_LIBRARY_NAME,nvidia
  ```
  in your config and ensure all other NVIDIA and Wayland variables are set as described in earlier sections, or XWayland may fail to accelerate apps.[10][11][8]

### Testing and Debugging

- Run `xeyes`, `xclock`, or `xterm` to check basic XWayland function.
- For in-depth issues, consult logs in `~/.local/share/hyprland/hyprland.log` and run problematic apps from the terminal to capture XWayland-related errors.[2][7]

### Limitations

- Seamless hybrid GPU offloading, precise DPI scaling, and advanced X11 compositing features are currently limited or not supported.
- Some apps and games may simply not function perfectly outside of Xorg-based sessions; consider using integer scaling or other workarounds.
  
***

Related topics: Window rule configuration, HiDPI issues, input focus startups, running X11-only legacy software, transition strategies to pure Wayland apps.

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] FAQ https://wiki.hypr.land/FAQ/
[3] Wayland - ArchWiki https://wiki.archlinux.org/title/Wayland
[4] Blurry text when using Sway or fractional scaling on Wayland https://intellij-support.jetbrains.com/hc/en-us/articles/4403794663570-Blurry-text-when-using-Sway-or-fractional-scaling-on-Wayland
[5] Wayland/hyprland: incorrect popup scale (reopen) : JBR-8356 https://youtrack.jetbrains.com/projects/JBR/issues/JBR-8356/Wayland-hyprland-incorrect-popup-scale-reopen
[6] Drag and drop does not work in Hyprland (Wayland) #7644 https://github.com/hyprwm/Hyprland/issues/7644
[7] Abnormal Display in JetBrains IDEs · Issue #5942 https://github.com/hyprwm/Hyprland/issues/5942
[8] Nvidia - Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Nvidia/
[9] Intellij is flickering heavily making it hard to work #9355 - GitHub https://github.com/hyprwm/Hyprland/issues/9355
[10] NVidia https://wiki.hyprland.org/0.45.0/Nvidia/
[11] NVidia - Hyprland Wiki https://wiki.hyprland.org/0.41.2/Nvidia/

