## Screen Sharing


### Requirements

- Ensure `xdg-desktop-portal-hyprland`, `xdg-desktop-portal`, `pipewire`, and `wireplumber` are installed and running for seamless screen sharing in Hyprland.[1][2]
- Remove or disable other portal backends (like `xdg-desktop-portal-wlr` or `gnome`) to prevent conflicts.[2][3]

### Configuration Steps

- Add to your Hyprland or environment configuration:
  ```
  XDG_CURRENT_DESKTOP=Hyprland
  exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
  ```
  This ensures the right portal is selected and signals session type to D-Bus.[3][4][2]

### Browser and App Support

- Modern browsers (e.g., Firefox, Chromium/Chrome) and video conferencing apps (WebRTC-based) work seamlessly, offering both monitor and individual window selection with the Hyprland portal.[1]
- Test screen sharing in browsers or OBS Studio to verify the picker dialog appears and your selected monitor/window can be streamed.[3][1]

### Troubleshooting

- If you get stuck on "loading preview" or see no window/monitor picker:
  - Check only `xdg-desktop-portal-hyprland` is running as a backend.
  - Restart portals and related services:
    ```
    systemctl --user restart pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-hyprland
    ```
  - Ensure `XDG_CURRENT_DESKTOP` is properly set and exported in your startup files.[5][3]
- Check logs in `~/.local/share/xdg-desktop-portal-hyprland.log` or use `journalctl` for deeper diagnostics.[3]

### Features

- Supports full screen, per-monitor, and now individual window sharing through the picker dialog in supported browsers and apps.[5][1]
- Provides better compatibility and performance than generic Wayland solutions when used with Hyprland.[1][5]

***

Related topics: Pipewire setup, Flatpak/portal integration, OBS Studio and browser-based sharing with Wayland.

Sources
[1] Screen sharing - Hyprland Wiki https://wiki.hypr.land/Useful-Utilities/Screen-Sharing/
[2] xdg-desktop-portal-hyprland https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[3] Screen sharing on Hyprland (Arch Linux) https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580?permalink_comment_id=4638574
[4] XDG Desktop Portal https://wiki.archlinux.org/title/XDG_Desktop_Portal
[5] Hyprland Desktop Portal https://wiki.hyprland.org/0.41.0/Useful-Utilities/xdg-desktop-portal-hyprland/

