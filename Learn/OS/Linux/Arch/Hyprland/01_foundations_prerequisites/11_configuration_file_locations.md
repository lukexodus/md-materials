## Configuration File Locations


### Primary Configuration File

The main configuration file is located at `~/.config/hypr/hyprland.conf`. When launching Hyprland for the first time, it automatically generates an example config if none exists. The default system-wide template is stored at `/usr/share/hypr/hyprland.conf`. You can specify an alternative configuration file when launching Hyprland using the `--config` or `-c` flag.[1][2][3]

### Configuration Directory Structure

The `~/.config/hypr/` directory serves as the primary location for all Hyprland-related configuration. This directory typically contains:[3][4]

**Core Files:**
- `hyprland.conf` - Main configuration file[2][3]
- `hyprlock.conf` - Screen lock configuration[4]
- `hypridle.conf` - Idle daemon configuration[4]

**Subdirectories:**
- `scripts/` - Custom shell scripts for automation (wallpaper rotation, sunset modes, fixes)[4]
- `sources_example/` or similar - Modular configuration splits when using multi-file setups[4]

### Modular Configuration Structure

Rather than maintaining a single monolithic configuration file, you can split configurations into multiple files and include them using the `source` directive. The syntax is `source = ~/.config/hypr/filename.conf`. This approach creates a more maintainable structure where specific aspects are isolated.[5][6][3]

**Common Modular Splits:**
- `keybindings.conf` - All keyboard shortcuts and binds[5][4]
- `monitors.conf` - Display configuration[5][4]
- `autostart.conf` - Applications launched at startup[5][4]
- `aesthetics.conf` - Visual settings like animations, decorations, borders[5]
- `environment.conf` - Environment variables[5]
- `input.conf` - Keyboard, mouse, touchpad settings[5]
- `rules.conf` or `windowrules.conf` - Window and workspace rules[4][5]
- `variables.conf` - General variables and settings[5]

**Example:**
```
source = ~/.config/hypr/keybindings.conf
source = ~/.config/hypr/monitors.conf
source = ~/.config/hypr/autostart.conf
```


### Related Application Configurations

Additional Wayland and Hyprland ecosystem applications store their configs within `~/.config/` as separate directories:[4]

**Status Bars and Panels:**
- `~/.config/waybar/` - Waybar status bar configuration, styles, and scripts[4]
- `~/.config/eww/` - ElKowars wacky widgets configuration

**Application Launchers:**
- `~/.config/wofi/` - Wofi launcher configuration and styling[4]
- `~/.config/rofi/` - Rofi launcher configuration

**Notification Daemons:**
- `~/.config/mako/config` - Mako notification daemon configuration[3]
- `~/.config/mako/icons/` - PNG format icons for notifications[3]
- `~/.config/swaync/` - SwayNC notification center configuration[4]

**Terminal Emulators:**
- `~/.config/kitty/` - Kitty terminal configuration (default terminal)[4]
- `~/.config/alacritty/` - Alacritty terminal configuration

**Other Tools:**
- `~/.config/xdg-desktop-portal/` - Portal configuration for desktop integration[4]
- `~/.config/electron-flags.conf` - Global Electron app Wayland flags[1]

### Configuration Reload Behavior

Hyprland automatically reloads the configuration the moment you save `hyprland.conf`. You can manually trigger a reload using `hyprctl reload`. Some settings, particularly input device settings, may require restarting your Hyprland session to take effect. Settings can be changed temporarily on-the-fly using `hyprctl` commands, but these changes are not persistent and will be lost on reload.[2][3]

### Global vs User Configuration

Hyprland uses a user-specific configuration model where `~/.config/hypr/hyprland.conf` is the active configuration. Unlike some systems, there is no official global configuration directory like `/etc/xdg/hypr` that applies system-wide defaults. Distribution-specific configurations may place additional files in `/usr/share/` locations, but these are templates rather than active configs.[7][8][2][3]

Sources
[1] Master tutorial https://wiki.hypr.land/Getting-Started/Master-Tutorial/
[2] Configuring - Hyprland Wiki https://wiki.hyprland.org/0.41.2/Configuring/Configuring-Hyprland/
[3] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[4] Firstp1ck/Hyprland-Simple-Setup - GitHub https://github.com/Firstp1ck/Hyprland_simple-minimal_Setup
[5] A Noobs Guide to Hyprland | EP:2 - Configuration Structure https://www.youtube.com/watch?v=zUajubDOGTg
[6] How to easy source multi config files - hyprland https://www.reddit.com/r/hyprland/comments/1ahng0o/how_to_easy_source_multi_config_files/
[7] global config file? · Issue #1040 · hyprwm/Hyprland https://github.com/hyprwm/Hyprland/issues/1040
[8] Configuration Files Garuda Hyprland https://forum.garudalinux.org/t/configuration-files-garuda-hyprland/37672
[9] first time user dealing with config file : r/hyprland https://www.reddit.com/r/hyprland/comments/1cwmwdj/first_time_user_dealing_with_config_file/
[10] Configuring Hyprland https://wiki.hyprland.org/0.41.0/Configuring/Configuring-Hyprland/

