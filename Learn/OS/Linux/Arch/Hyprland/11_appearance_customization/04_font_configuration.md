## Font Configuration


### Installing Fonts

- Install additional fonts from the Arch repositories with:
  ```
  sudo pacman -S ttf-<fontname>
  ```
  Examples: `ttf-nerd-fonts-symbols`, `ttf-dejavu`, `ttf-fira-sans`, `ttf-roboto`.[1][2]

### System-Wide Font Configuration

- Font rendering, fallback, and specific preferences can be set globally in `/etc/fonts/local.conf`, or per-user in `~/.config/fontconfig/fonts.conf`.[3]
- Fontconfig controls antialiasing, hinting, and subpixel rendering; presets can be enabled in `/etc/fonts/conf.d/` with symlinks to `/usr/share/fontconfig/conf.avail` (e.g., for RGB subpixel rendering).[3][1]

### GTK and Qt Application Fonts

- Use `nwg-look` (GTK) or `qt5ct`/`qt6ct` (Qt) to set default and UI fonts per toolkit.[4][5]
- For GTK3/GTK4, manually edit `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini`:
  ```
  [Settings]
  gtk-font-name=Fira Sans 11
  ```
- For Qt5/Qt6, use the configuration tool and the GUI to select your preferred font; settings are stored in `~/.config/qt5ct/qt5ct.conf` or `~/.config/qt6ct/qt6ct.conf`.[5][4]

### Per-Application Configuration

- Terminal emulators (Kitty, Alacritty, Foot) and status bars (Waybar) set fonts via their individual config files:
  - `kitty`: `~/.config/kitty/kitty.conf`
  - `alacritty`: `~/.config/alacritty/alacritty.toml`
  - `foot`: `~/.config/foot/foot.ini`
  - `waybar`: `~/.config/waybar/styles/` or the specific bar configuration file.[6][4]

### Font Fallback and Multilingual

- Fontconfig enables the order and fallback for different scripts; customize fallback in `fonts.conf` as exemplified for multilingual needs.[1]
- Use `fc-match` and `fc-list` to test and debug font config and fallback behavior.[1]

### Tips for Best Appearance

- Set scaling and adjust font sizes via toolkit tools (`nwg-look`, `qt5ct`) for HiDPI/4K monitors.[4]
- If font rendering appears poor, enable LCD filtering and tune hinting/antialiasing settings in Fontconfig.[7][3]
- Always log out/log in or restart Hyprland after major changes to ensure all applications pick up the new configuration and render correctly.[3][4]

***

Related topics: Nerd font integration, GDK/GTK/Qt toolkit settings, HiDPI scaling, and troubleshooting font rendering on Wayland.

Sources
[1] Fonts - ArchWiki https://wiki.archlinux.org/title/Fonts
[2] How to Install Arch Linux and Hyprland (Part 2 of 2) - John Ling https://www.johnling.me/blog/Hyprland-Guide
[3] Font configuration - ArchWiki https://wiki.archlinux.org/title/Font_configuration
[4] FAQ_Themes_and_Decorations · JaKooLit/Hyprland-Dots Wiki https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ_Themes_and_Decorations
[5] KDE theming and styling in Hyprland - Lorenzo Bettini https://www.lorenzobettini.it/2024/06/kde-theming-and-styling-in-hyprland/
[6] Hyprland https://wiki.archcraft.io/docs/wayland-compositors/hyprland/
[7] Bad fonts and font rendering - Newbie https://forum.endeavouros.com/t/bad-fonts-and-font-rendering/50510
[8] Can't change the font of Hyprland https://www.reddit.com/r/hyprland/comments/1cn6nfp/cant_change_the_font_of_hyprland/
[9] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[10] Installation https://wiki.hypr.land/Getting-Started/Installation/
[11] fonts are slightly off everywhere #11918 https://github.com/hyprwm/Hyprland/discussions/11918
[12] Configuring https://wiki.hypr.land/Configuring/
[13] THE FRESH ARCH LINUX HYPRLAND SETUP 2025 (Ft. ... https://www.youtube.com/watch?v=OnxU419vnts
[14] Terrible native font rendering under Hyprland for GTK4 and Electron ... https://www.reddit.com/r/hyprland/comments/194br8s/terrible_native_font_rendering_under_hyprland_for/
[15] Master tutorial https://wiki.hypr.land/Getting-Started/Master-Tutorial/
[16] [SOLVED] How to change arch default fonts? https://bbs.archlinux.org/viewtopic.php?id=265441
[17] Font is not antialiased with GTK apps on wayland #2861 - GitHub https://github.com/flatpak/flatpak/issues/2861
[18] Hyprland on Arch — Minimal Setup Guide https://www.tonybtw.com/tutorial/hyprland/
[19] How to Massively Improve Font Rendering on Hyprland - YouTube https://www.youtube.com/watch?v=G_3P_PApDK0
[20] Hyprland: getting started (part 1) - Lorenzo Bettini https://www.lorenzobettini.it/2023/07/hyprland-getting-started-part-1/

