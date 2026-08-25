## Screen Brightness


### Primary Tools and Methods

- Brightness is typically managed with the `brightnessctl` utility, compatible with most laptops on Hyprland and Arch Linux.[1][2][3]
- Common usage:
  ```
  brightnessctl --list
  brightnessctl info
  brightnessctl set 50%
  brightnessctl set +5%
  brightnessctl set 5%-
  ```
  - Use `--device=backlight` if you have multiple backlight devices or want to target a specific screen.

### Sysfs Manual Option

- Advanced users may directly write values to sysfs for supported devices:
  ```
  echo VALUE | sudo tee /sys/class/backlight/intel_backlight/brightness
  cat /sys/class/backlight/intel_backlight/max_brightness  # to find max value
  ```
  - Replace `intel_backlight` with actual device name.[1]

### Hyprland Keybinding Integration

- Configure hardware keys in `~/.config/hypr/hyprland.conf` (or fragments):
  ```
  bind = XF86MonBrightnessUp, exec, brightnessctl set +5%
  bind = XF86MonBrightnessDown, exec, brightnessctl set 5%-
  ```
  - Media keys (XF86MonBrightnessUp/Down) map to brightness if supported by hardware and kernel input drivers.[2][3][4]
  - Use `evtest` or `showkey` to identify key codes if necessary.

### Notification Feedback

- For instant feedback, stack a notification:
  ```
  bind = XF86MonBrightnessUp, exec, brightnessctl set +5% && notify-send "Brightness Increased"
  ```
  - Mako works well for notifications.[2]

### Notes & Troubleshooting

- If brightness control does not work:
  - Ensure user is in the necessary groups (`video`, sometimes `input`).
  - Try different device names in `/sys/class/backlight/` or with `brightnessctl --list`.
  - Some desktop monitors do not support software brightness control; use hardware buttons.[1]

- For advanced hardware (HDR, multi-backlight setups, OLED): consult manufacturer-specific utilities or kernel modules—`brightnessctl` is for standard ACPI/backlight compliant screens.[1]

***

Related topics: Auto brightness scripts, hardware button mapping, notification integration, multi-monitor brightness with DPMS.

Sources
[1] Backlight - ArchWiki https://wiki.archlinux.org/title/Backlight
[2] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[3] How to Rice Hyprland (Part 2) | Brightness, Volume and ... https://www.youtube.com/watch?v=EajYMqfdAEo
[4] volume and brightness controls (arch) : r/hyprland https://www.reddit.com/r/hyprland/comments/1cdumym/volume_and_brightness_controls_arch/

