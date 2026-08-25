## Icon Themes


### Installation and Directories

- Download icon theme packs (such as Papirus, Tela, or Qogir) from popular repositories: [GitHub](https://github.com/vinceliuice/Tela-circle-icon-theme) or from theme sharing sites.[1][2]
- Place system-wide icon themes in `/usr/share/icons`, or for per-user access, in `~/.icons`.[3][1]
- Extract any compressed theme archives before placing them into those directories; most themes include instructions.[1]

### Applying Icon Themes

- Use a graphical utility like `nwg-look` or `lxappearance` for easy theme switching and preview.[4][1]
- For GTK apps, icon theme selection can be made through these GUI tools or by editing `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini`:
  ```
  [Settings]
  icon-theme-name=YourIconTheme
  ```
  Apply the same icon theme name in `qt5ct` or `qt6ct` for Qt apps to ensure integration.[5][6]

### Theming Across GTK and Qt

- Most modern icon themes support both GTK and Qt applications. Select the matching icon set in both `nwg-look` and `qt5ct/qt6ct` for uniform appearance.[6][5]
- For KDE apps or if you’re using Kvantum, select icon theme in `qt6ct` or Kvantum Manager.[5]

### Recommendations

- Popular icon themes: Papirus, Tela Circle, Qogir, Fluent, and Nordic.[2][7]
- Fonts and cursors are similarly themed by placing files in `~/.fonts` and `~/.icons` (for cursors).[3]
- Restart your session or apps after theme changes for full effect, especially after modifying configuration files.[1]

### Troubleshooting

- If icons do not show or fallback to defaults:
  - Confirm the folder name matches the value in your config.
  - Check for missing icon sizes or required SVG/PNG formats.
  - Restart your graphical session or run `xfsettingsd` to reapply themes (especially for legacy apps).[4]
- For some notifications or custom widgets (Waybar, Mako), ensure PNG icons are available in their specific config directories, e.g., `~/.config/mako/icons/`.[8]

***

Related topics: Customizing cursors, Nerd font integration, Wayland widget icon usage, scripting theme changes.

Sources
[1] Hyprland theming. everything from getting themes/making ... https://www.reddit.com/r/hyprland/comments/14uk7s3/hyprland_theming_everything_from_getting/
[2] How to Install Arch Linux and Hyprland (Part 2 of 2) - John Ling https://www.johnling.me/blog/Hyprland-Guide
[3] Here's How You Can Customize Linux Desktop ... https://itsfoss.com/hyprland-halloween-customization/
[4] Hyprland https://wiki.archcraft.io/docs/wayland-compositors/hyprland/
[5] KDE theming and styling in Hyprland - Lorenzo Bettini https://www.lorenzobettini.it/2024/06/kde-theming-and-styling-in-hyprland/
[6] Uniform look for Qt and GTK applications https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
[7] Best free icon sets for UI design in 2025 - Adham Dannaway https://www.adhamdannaway.com/blog/icons/free-icon-sets
[8] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[9] How to install themes on Arch Linux with Hyprland and ... https://www.facebook.com/groups/archlinuxen/posts/10160417303713393/
[10] A Noobs Guide to Hyprland EP:11 | Installing Icons, ... https://www.youtube.com/watch?v=6GKMjdAai-Q
[11] Hyprland/Wayland Dynamic Bar With ICONS Using Quickshell https://www.youtube.com/watch?v=YM2FJ_aoGQA
[12] JaKooLit/Arch-Hyprland: For automated installation of ... https://github.com/JaKooLit/Arch-Hyprland
[13] Icons of programs on desktop hyprland : r/archlinux - Reddit https://www.reddit.com/r/archlinux/comments/1gobmzb/icons_of_programs_on_desktop_hyprland/
[14] Whats the best to way theme gtk and qt apps : r/hyprland https://www.reddit.com/r/hyprland/comments/1khhuud/whats_the_best_to_way_theme_gtk_and_qt_apps/
[15] My Hyprland Theme Collection (Best Setups from 2025) - YouTube https://www.youtube.com/watch?v=1D18unIwbmE
[16] How to apply gtk themes on hyprland https://www.reddit.com/r/hyprland/comments/17swxzh/how_to_apply_gtk_themes_on_hyprland/
[17] My Linux Desktop Just Got Scary! 👻 (Hyprland Halloween ... https://www.youtube.com/watch?v=TOTZedtb_d8
[18] Hyprland Made Easy: Preconfigured Beautiful Distros - It's FOSS https://itsfoss.com/hyprland-distros/
[19] I just can't set gtk theme... : r/hyprland https://www.reddit.com/r/hyprland/comments/1ixczr1/i_just_cant_set_gtk_theme/
[20] 3446 Hyprland - How to change the theme, icons and cursor https://www.youtube.com/watch?v=FuWAv2l5Oso

