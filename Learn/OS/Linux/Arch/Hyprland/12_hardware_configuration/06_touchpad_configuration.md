## Touchpad Configuration


### Basic Setup

- Hyprland uses libinput for touchpad management; most configuration is done in the `input` block of `~/.config/hypr/hyprland.conf`.[1][2]
- Example:
  ```
  input {
    touchpad {
      natural_scroll = yes
      tap-to-click = yes
      clickfinger_behavior = yes
      scroll_factor = 1.0
      sensitivity = 0.0
    }
  }
  ```
  - Boolean options accept `yes/no`, `true/false`, or `1/0`.[3]

### Common Touchpad Options

| Option                | Effect                                |
|-----------------------|---------------------------------------|
| `natural_scroll`      | Scroll direction (yes for "natural")  |
| `tap-to-click`        | Enable tap-to-click                   |
| `clickfinger_behavior`| Multi-finger tap as right click       |
| `scroll_factor`       | Pointer speed for scrolling           |
| `sensitivity`         | Touchpad sensitivity (-1.0 to 1.0)    |
| `tap-and-drag`        | Enable tap-and-drag (default: yes)    |
| `flip_x/flip_y`       | Reverse axes if needed                |
| `enabled`             | Enable/disable touchpad               |

- Example for disabling:
  ```
  input {
    touchpad {
      enabled = false
    }
  }
  ```
  Or dynamically:
  ```
  hyprctl keyword "device[YOUR_TOUCHPAD]:enabled" false
  ```

### Per-Device Customization

- Find your device name:
  ```
  hyprctl devices
  ```
- Configure specific devices:
  ```
  device {
    name = YOUR_TOUCHPAD
    sensitivity = -0.3
    scroll_factor = 0.9
  }
  ```
  - Per-device configs override input block settings for that hardware.[4]

### Advanced Gestures

- For more gestures, use the community tool `libinput-gestures` with custom scripts or bindings for actions like multi-finger swipes. Hyprland’s built-in gesture support is limited; expand with external utilities as needed.[5][6]

### Troubleshooting

- If touchpad isn’t detected, confirm device appears in `hyprctl devices` or `libinput list-devices`. Check for kernel/driver issues with system logs.[7][8][9]
- Synaptics-specific options require the legacy Xorg driver; prefer libinput for Wayland setups.[10]
- Change pointer speed with `sensitivity`, or use `xinput` for Xorg fallback if necessary (not recommended for Hyprland/Wayland).[11][12]

***

Related topics: Multi-monitor pointer mapping, gesture integration, disabling/enabling on the fly, hardware quirks, libinput documentation.

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables https://wiki.hypr.land/Configuring/Variables/
[3] Two finger right click · hyprwm Hyprland · Discussion #921 https://github.com/hyprwm/Hyprland/discussions/921
[4] Keywords https://wiki.hyprland.org/0.45.0/Configuring/Keywords/
[5] Recommendations for multitouch gestures in Hyprland on NixOS? https://discourse.nixos.org/t/recommendations-for-multitouch-gestures-in-hyprland-on-nixos/46880
[6] Linux Cookbook #2: Hyprland - Bahadır Aydın https://bahadiraydin.com/blog/linux-cookbook-hyprland
[7] Touchpad not working on Hyprland - Reddit https://www.reddit.com/r/hyprland/comments/1hymuxy/touchpad_not_working_on_hyprland/
[8] Why doesn't hyprland see the touchpad? - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=297947
[9] How to Install and Configure Hyprland (Wayland) on Arch Linux https://www.siberoloji.com/arch-linux-howtos-install-and-configure-hyprland-wayland/
[10] Touchpad Synaptics - ArchWiki https://wiki.archlinux.org/title/Touchpad_Synaptics
[11] How to increase touchpad speed permanantly on hyprland? - Newbie https://forum.endeavouros.com/t/how-to-increase-touchpad-speed-permanantly-on-hyprland/50159
[12] Change Touchpad Speed : r/hyprland https://www.reddit.com/r/hyprland/comments/1e26nok/change_touchpad_speed/
[13] How to disable touchpad on hyprland - Newbie - EndeavourOS Forum https://forum.endeavouros.com/t/how-to-disable-touchpad-on-hyprland/50134
[14] How to configure libinput under gnome wayland? - Reddit https://www.reddit.com/r/linuxquestions/comments/asanqt/how_to_configure_libinput_under_gnome_wayland/
[15] Change touchpad sensitivity · Issue #4457 · hyprwm/Hyprland - GitHub https://github.com/hyprwm/Hyprland/issues/4457
[16] any one here have good config for laptop touchpad https://www.reddit.com/r/hyprland/comments/1etnrzt/any_one_here_have_good_config_for_laptop_touchpad/
[17] Touchpad Disable · hyprwm Hyprland · Discussion #6900 - GitHub https://github.com/hyprwm/Hyprland/discussions/6900
[18] Ability to disable libinput Tapping Drag enabled · Issue #2179 - GitHub https://github.com/hyprwm/Hyprland/issues/2179
[19] Setting up touchpad gestures on Arch Linux - YouTube https://www.youtube.com/watch?v=RovI4g-x5d4
[20] Customizing Hyprland to Your Liking - It's FOSS https://itsfoss.com/configuring-hyprland/

