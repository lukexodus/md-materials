## Qt Configuration


### Required Packages

- Install `qt5ct` and `qt6ct` to manage Qt5/Qt6 application theming.
- For native Wayland support, install `qt5-wayland` and `qt6-wayland`.
- For advanced SVG-based themes, add Kvantum (`kvantum-qt5`, `kvantum-qt6`, and desired theme packs).[1][2][3]

### Environment Variable Setup

Add these lines to your Hyprland configuration (`~/.config/hypr/hyprland.conf`) under the appropriate section:

```
env = QT_QPA_PLATFORM,wayland
env = QT_QPA_PLATFORMTHEME,qt5ct
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = QT_AUTO_SCREEN_SCALE_FACTOR,1
env = QT_STYLE_OVERRIDE,kvantum
```
- Use `qt5ct` for Qt5 and `qt6ct` for Qt6. Qt6 apps automatically use qt6ct if installed.[2][4][1]

### Theming & Appearance

- Set styles, colors, and icons in `qt5ct` or `qt6ct` GUI apps. Open `qt6ct`, choose a theme (such as Breeze or Kvantum), click "Apply," and restart your Qt apps.[3][2]
- For Kvantum themes, use Kvantum Manager to select and apply preferred SVG-based themes, then set `QT_STYLE_OVERRIDE=kvantum` for consistency.[1][3]

### Flatpak Applications

- Ensure Flatpak Qt apps use matching Kvantum and Platform versions (`org.kde.KStyle.Kvantum` with corresponding `org.kde.Platform`) for consistent theming.[1]

### Troubleshooting

- If scaling or theme does not apply correctly, confirm variables are present and only set in one location (prefer Hyprland config over `/etc/environment` for session control).[5]
- For broken scaling, verify `QT_AUTO_SCREEN_SCALE_FACTOR=1` is set for HiDPI screens.[1]
- If using mixed GTK/Qt environments, follow the integration guide for uniform appearance.[6]

***

Related topics: Consistent dark mode across toolkits, Wayland session variables, Kvantum and advanced theme management.

Sources
[1] QT theming on Hyprland - Reddit https://www.reddit.com/r/hyprland/comments/19cspxf/qt_theming_on_hyprland/
[2] Better KDE theming and styling in Hyprland | Lorenzo Bettini https://www.lorenzobettini.it/2024/08/better-kde-theming-and-styling-in-hyprland/
[3] How to Customize Qt and GTK Themes on Arch Linux | Siberoloji https://www.siberoloji.com/how-to-customize-qt-and-gtk-themes-on-arch-linux/
[4] Environment variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Environment-variables/
[5] Qt5ct and qt Themes! : r/hyprland - Reddit https://www.reddit.com/r/hyprland/comments/14k0qjx/qt5ct_and_qt_themes/
[6] Uniform look for Qt and GTK applications - ArchWiki https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
[7] How to set dark mode? · hyprwm Hyprland · Discussion #5867 https://github.com/hyprwm/Hyprland/discussions/5867
[8] xdg-desktop-portal-hyprland https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[9] How to Install Arch Linux and Hyprland (Part 2 of 2) - John Ling https://www.johnling.me/blog/Hyprland-Guide
[10] Hyprland Desktop Portal https://wiki.hyprland.org/0.41.0/Useful-Utilities/xdg-desktop-portal-hyprland/
[11] Master tutorial - Hyprland Wiki https://wiki.hypr.land/Getting-Started/Master-Tutorial/
[12] Master tutorial - Hyprland Wiki https://wiki.hyprland.org/0.41.0/Getting-Started/Master-Tutorial/
[13] XDG Desktop Portal https://wiki.archlinux.org/title/XDG_Desktop_Portal
[14] [SOLVED]Incorrect themeing after updating system / Applications ... https://bbs.archlinux.org/viewtopic.php?id=304893
[15] Getting errors when trying to launch qt5ct and lxappearance #1812 https://github.com/hyprwm/Hyprland/discussions/1812
[16] Weird xdg-desktop-portal Rendering Issue on Hyprland ... https://www.reddit.com/r/hyprland/comments/1jr4zf7/weird_xdgdesktopportal_rendering_issue_on/
[17] How To Theme Qt Apps To Get a Uniform Look - YouTube https://www.youtube.com/watch?v=VC4ecxd6dn8&vl=en
[18] Guide to installing qt theme - NixOS Discourse https://discourse.nixos.org/t/guide-to-installing-qt-theme/35523
[19] Issue #145 · hyprwm/xdg-desktop-portal-hyprland https://github.com/hyprwm/xdg-desktop-portal-hyprland/issues/145
[20] Master tutorial - Hyprland Wiki https://wiki.hyprland.org/0.47.0/Getting-Started/Master-Tutorial/

