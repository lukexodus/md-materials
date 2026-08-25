## GTK Theming


### Theme Installation and Management

- Install desired GTK themes (and icon/cursor packs) into either `/usr/share/themes` for system-wide or `~/.themes` for user-specific use.[1][2]
- Use a graphical tool like `nwg-look` or `lxappearance` to manage themes, icons, and cursors in Hyprland; these ensure proper environment variables are set and that changes persist across Wayland sessions.[3][4][5]

### Setting Themes for GTK3/GTK4 Apps

- For GTK3 apps, set the theme using:
  ```
  gsettings set org.gnome.desktop.interface gtk-theme "YourThemeName"
  ```
- For GTK4 apps, enforce dark mode with:
  ```
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
  ```
  Add these lines to your Hyprland start/exec configuration if you want a global effect.[6][5]

### Environment Variables

- Alternatively, set the environment variable in your Hyprland config:
  ```
  env = GTK_THEME,YourThemeName:dark
  ```
  - Particularly useful for apps (like Nautilus) that ignore gsettings changes.[7][8][9]

### Portal Integration for Theming

- Ensure `xdg-desktop-portal-gtk` is installed; it provides proper themed dialogs for sandboxed/flatpak applications as well as some system dialogs.[10][11]
- It's safe and recommended to run both `xdg-desktop-portal-gtk` and `xdg-desktop-portal-hyprland`; the GTK portal will handle themed dialogs, while the Hyprland portal covers screensharing/global shortcuts.[10]

### Troubleshooting

- If themes don’t apply, check configuration with `gsettings` and ensure environment variables are set before any GTK applications launch.[12][7]
- If apps display in a default or Adwaita theme, verify `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini` have the correct theme name.
  - Example entry:
    ```
    [Settings]
    gtk-theme-name=YourThemeName
    ```
- Log out and back in or restart session after changes to ensure full propagation.[7][12]

***

Related topics: Uniform look for Qt and GTK apps, icon/cursor theming, Flatpak dialog integration, dark mode consistency.

Sources
[1] How to install gtk themes on Hyprland https://www.youtube.com/watch?v=T4dyQqu1Fo0
[2] How to Rice Hyprland (Part 3) | GTK Theme https://www.youtube.com/watch?v=FVZ-8EtwXBY
[3] How to Set GTK themes on Hyprland with a GUI | nwg-look https://www.youtube.com/watch?v=F9dl2r_Htu0
[4] Master tutorial https://wiki.hypr.land/Getting-Started/Master-Tutorial/
[5] FAQ https://wiki.hyprland.org/0.46.0/FAQ/
[6] How to set dark mode? · hyprwm Hyprland https://github.com/hyprwm/Hyprland/discussions/5867
[7] How to apply gtk themes on hyprland https://www.reddit.com/r/hyprland/comments/17swxzh/how_to_apply_gtk_themes_on_hyprland/
[8] Gtk theme in garuda_hyprland - Hyprland https://forum.garudalinux.org/t/gtk-theme-in-garuda-hyprland/38120
[9] Environment variables https://wiki.hyprland.org/0.41.0/Configuring/Environment-variables/
[10] Issue #145 · hyprwm/xdg-desktop-portal-hyprland https://github.com/hyprwm/xdg-desktop-portal-hyprland/issues/145
[11] GTK apps not following theme? : r/hyprland https://www.reddit.com/r/hyprland/comments/1akc4ec/gtk_apps_not_following_theme/
[12] Problem with gtk theme doesn't change appearance https://forum.garudalinux.org/t/problem-with-gtk-theme-doesnt-change-appearance/41034
[13] How do I configure GTK in Arch, Wayland? https://bbs.archlinux.org/viewtopic.php?id=273974
[14] xdg-desktop-portal-hyprland https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[15] Uniform look for Qt and GTK applications https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
[16] FAQ https://wiki.hypr.land/FAQ/
[17] Hyprland https://wiki.archcraft.io/docs/wayland-compositors/hyprland/
[18] Hyprland Desktop Portal https://wiki.hyprland.org/0.41.0/Useful-Utilities/xdg-desktop-portal-hyprland/
[19] Setting prefered xdg-desktop-portal in gnome, to fix titlebars https://discourse.nixos.org/t/setting-prefered-xdg-desktop-portal-in-gnome-to-fix-titlebars/66149
[20] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland

