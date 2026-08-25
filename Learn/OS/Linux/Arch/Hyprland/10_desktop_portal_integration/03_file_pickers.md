## File Pickers


### Integration on Hyprland

- File picker dialogs on Wayland/Hyprland depend on `xdg-desktop-portal` and an appropriate backend such as `xdg-desktop-portal-hyprland`.[1][2]
- For best results, also install a graphical backend such as `xdg-desktop-portal-gtk`, which provides the native GTK file picker dialog—essential for Flatpak or sandboxed applications.[3][1]
- For Qt-based apps, `xdg-desktop-portal-qt` can be installed for better file dialog theming and compatibility, but `-gtk` is generally sufficient on most systems.[3]

### Setup & Recommendations

- Install with:
  ```
  sudo pacman -S xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  ```
  - Ensure *only one* backend is active to avoid unpredictable picker behavior (such as wrong dialog showing, or no dialog at all).[2][1]
- `xdg-desktop-portal-hyprland` will manage requests and pass them to the proper backend for dialog display. GTK’s picker remains the default in most cases unless overridden by app configuration.[1]

### File Picker in Flatpak & Sandboxed Apps

- When running a Flatpak app or a sandboxed program, the app requests a file picker via the portal API, and the dialog appears according to the active backend (`-gtk`, `-qt`, etc.).[3]
- Problems with missing or broken file pickers can often be traced to a missing or conflicting portal backend. Check running services with:
  ```
  loginctl user-status
  ```
- Restart and ensure only the Hyprland and one visual backend are running if you have issues.[4]

### Troubleshooting

- If no dialog appears, or the wrong type shows up, check for and remove any conflicting portal implementations (e.g., `xdg-desktop-portal-wlr`, `xdg-desktop-portal-gnome`).[4][1]
- Restart with:
  ```
  systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  ```
  and log out/in if needed to clear issues.[4]

***

Related topics: Flatpak file access, sandbox escapes, portal troubleshooting, theming file dialogs on Hyprland.

Sources
[1] xdg-desktop-portal-hyprland https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[2] Hyprland Desktop Portal https://wiki.hyprland.org/0.41.0/Useful-Utilities/xdg-desktop-portal-hyprland/
[3] XDG Desktop Portal https://wiki.archlinux.org/title/XDG_Desktop_Portal
[4] Screen sharing on Hyprland (Arch Linux) https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580?permalink_comment_id=4638574

