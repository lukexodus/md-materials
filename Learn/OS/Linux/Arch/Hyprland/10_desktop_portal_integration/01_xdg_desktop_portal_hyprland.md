## XDG Desktop Portal Hyprland


### Purpose and Features

- `xdg-desktop-portal-hyprland` is the recommended portal backend for full Hyprland and Wayland features such as screen sharing, global shortcuts, and fine-grained window selection.[1][2]
- It integrates closely with Hyprland’s compositor via D-Bus, providing better compatibility than the generic `xdg-desktop-portal-wlr`, especially for window sharing and advanced functionality.[3][2]

### Installation

- Install the necessary packages:
  ```
  sudo pacman -S xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  ```
  - GTK is optional but recommended for proper file dialogs.[4][1]
- Ensure other portal implementations (e.g., `xdg-desktop-portal-wlr`, `xdg-desktop-portal-gnome`) are removed or disabled to avoid conflicts.[5][1]
- For screensharing, ensure `pipewire` and `wireplumber` are installed and running.[6]

### Environment Variable Configuration

- Add the following to your `~/.config/hypr/hyprland.conf` or session start script to set the required environment for portal detection:
  ```
  exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
  ```
  - Set `XDG_CURRENT_DESKTOP=Hyprland` before Hyprland starts for the portal to recognize the session.[7][5]

### Usage and Troubleshooting

- `xdg-desktop-portal-hyprland` should launch automatically with your session.
- Test function by attempting screen sharing in OBS or a browser; a picker dialog will confirm correct operation.[3][6]
- If screensharing or open/save dialogs launch the wrong portal, verify only the Hyprland backend and optionally GTK are installed, and restart necessary services.[5][3]

### Notes and Recommendations

- Prefer the Hyprland portal (`-hyprland`) over the WLR portal for best experience and functionality in Hyprland.[2][3]
- Remove any conflicting portal implementations to ensure stable behavior, especially for screen sharing or security prompts.[8][5]
- Advanced features like individual window sharing are only supported by `xdg-desktop-portal-hyprland` within Hyprland.[2][3]

Sources
[1] xdg-desktop-portal-hyprland https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[2] xdg-desktop-portal-hyprland https://wiki.hyprland.org/0.41.2/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[3] Hyprland Desktop Portal https://wiki.hyprland.org/0.41.0/Useful-Utilities/xdg-desktop-portal-hyprland/
[4] xdg-desktop-portal-hyprland 1.3.11-1 (x86_64) https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-hyprland/
[5] Screen sharing on Hyprland (Arch Linux) https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580?permalink_comment_id=4638574
[6] Screen sharing - Hyprland Wiki https://wiki.hypr.land/Useful-Utilities/Screen-Sharing/
[7] XDG Desktop Portal https://wiki.archlinux.org/title/XDG_Desktop_Portal
[8] wlr installed simultaneously" but xdg-desktop-portal-wlr is ... https://www.reddit.com/r/hyprland/comments/15gr18p/arch_linux_get_notification_that_you_have/
[9] Run xdg-desktop-portal-gnome on hyprland https://www.reddit.com/r/hyprland/comments/1g49k3q/run_xdgdesktopportalgnome_on_hyprland/
[10] Configuring xdg-desktop-portal with Home Manager on ... https://discourse.nixos.org/t/configuring-xdg-desktop-portal-with-home-manager-on-ubuntu-hyprland-via-nixgl/65287
[11] How to Install Arch Linux and Hyprland (Part 2 of 2) - John Ling https://www.johnling.me/blog/Hyprland-Guide
[12] Properly Setting Up `xdg-desktop-portal-hyprland` | Is It ... https://www.reddit.com/r/hyprland/comments/1m9oktp/properly_setting_up_xdgdesktopportalhyprland_is/
[13] Having certain portal implementations together in Hyprland causes ... https://github.com/flatpak/xdg-desktop-portal/issues/969
[14] Issue #64 · hyprwm/xdg-desktop-portal-hyprland - GitHub https://github.com/hyprwm/xdg-desktop-portal-hyprland/issues/64
[15] Installation https://wiki.hyprland.org/0.46.0/Getting-Started/Installation/
[16] hyprwm/xdg-desktop-portal-hyprland https://github.com/hyprwm/xdg-desktop-portal-hyprland
[17] xdg-desktop-portal-hyprland can not start https://bbs.archlinux.org/viewtopic.php?id=306801
[18] home-manager: configuring xdg portal · Issue #409 https://github.com/hyprwm/hyprland-wiki/issues/409
[19] FreshPorts -- x11/xdg-desktop-portal-hyprland https://www.freshports.org/x11/xdg-desktop-portal-hyprland
[20] Hyprland Desktop Portal https://wiki.hypr.land/hyprland-wiki/pages/Useful-Utilities/Hyprland-desktop-portal/

