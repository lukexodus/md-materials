## Keyboard Backlight


### Standard Controls (Wayland/Hyprland)

- Use the `brightnessctl` utility for most laptops and supported keyboards:
  - List available devices:  
    ```
    brightnessctl --list
    ```
  - Get keyboard backlight info:
    ```
    brightnessctl --device='*::kbd_backlight' info
    ```
  - Set brightness (50% in this example):
    ```
    brightnessctl --device='*::kbd_backlight' set 50%
    ```
  - Increase (`33%+`) or decrease (`33%-`) with binds in Hyprland config.[1][2]

- Symlinked sysfs:  
  Manually set with:
  ```
  echo LEVEL | sudo tee /sys/class/leds/*::kbd_backlight/brightness
  ```
  Replace `LEVEL` with a number from `0` (off) up to the maximum for your device. Find max with:
  ```
  cat /sys/class/leds/*::kbd_backlight/max_brightness
  ```

### D-Bus & Scripting

- D-Bus interface via UPower works universally and doesn't require direct sysfs access or special permissions. Example Python script using dbus (see [Arch Wiki guide]):[1]
  ```
  #!/usr/bin/env python3
  import dbus
  bus = dbus.SystemBus()
  kbd = bus.get_object('org.freedesktop.UPower', '/org/freedesktop/UPower/KbdBacklight')
  iface = dbus.Interface(kbd, 'org.freedesktop.UPower.KbdBacklight')
  iface.SetBrightness(new_level)
  ```
  - Bind such scripts to keys in your Hyprland config for full integration.[1]

### Hyprland Keybinding Example

- Example Hyprland config for backlight keys:
  ```
  bind = XF86KbdBrightnessUp, exec, brightnessctl --device='*::kbd_backlight' set +1
  bind = XF86KbdBrightnessDown, exec, brightnessctl --device='*::kbd_backlight' set 1-
  ```
  - Modern laptops often register special keys (`XF86KbdBrightnessUp/Down`); use `evtest` or `showkey` to find your keycodes if needed.[2][3]

### Notification Integration

- Add notification support with `notify-send` after changing brightness for visual feedback, or use enhanced notification scripts as outlined in the Hyprland Wiki example.[2]

### Notes and Troubleshooting

- Some custom or RGB keyboards require device-specific tools (e.g., OpenRGB or manufacturer utilities); standard sysfs or brightnessctl controls physical white backlighting on supported models.[4][5]
- Key backlight controls are hardware/vendor-dependent; if not working, check that the relevant `::kbd_backlight` device appears under `/sys/class/leds/` and that your user is in the `video` or appropriate group for permissions.[1]

***

Related topics: OpenRGB for per-key color, Fn/media key binding in Hyprland, integrating keyboard backlight state with system notifications.

Sources
[1] Keyboard backlight - ArchWiki https://wiki.archlinux.org/title/Keyboard_backlight
[2] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[3] Hyprland on Arch — Minimal Setup Guide - Tony, btw. https://www.tonybtw.com/tutorial/hyprland/
[4] Keyboard backlight color/uptime control by any means ... https://bbs.archlinux.org/viewtopic.php?id=284617
[5] Configuring LED Spacers and Keyboard colors on Arch Linux https://community.frame.work/t/configuring-led-spacers-and-keyboard-colors-on-arch-linux/51897
[6] volume and brightness controls (arch) : r/hyprland https://www.reddit.com/r/hyprland/comments/1cdumym/volume_and_brightness_controls_arch/
[7] [SOLVED]brightness button fails to properly map on hyprland https://bbs.archlinux.org/viewtopic.php?id=303898
[8] Backlit of my custom keyboard is not working even after the ... https://github.com/hyprwm/Hyprland/issues/7344
[9] Turn on keyboard backlight/leds on wayland (xset ... https://gist.github.com/ps1dr3x/b15c62eafb388ddf8bb7d3896d1a1cee
[10] A daemon to control my keyboard backlight https://github.com/GambolingPangolin/KbdBacklight
[11] Backlight - ArchWiki https://wiki.archlinux.org/title/Backlight
[12] Turning On Keyboard Backlight in KDE Plasma 6.1 ... https://discuss.kde.org/t/turning-on-keyboard-backlight-in-kde-plasma-6-1-wayland-looking-for-tips/18143
[13] Backlit of my custom keyboard is not working even after the ... https://www.reddit.com/r/archlinux/comments/1esr4ne/backlit_of_my_custom_keyboard_is_not_working_even/
[14] Uncommon tips & tricks https://wiki.hypr.land/Configuring/Uncommon-tips--tricks/
[15] Are there any PERMANENT commands to turn on ... https://www.reddit.com/r/wayland/comments/1aygvrq/are_there_any_permanent_commands_to_turn_on/
[16] How to Rice Hyprland (Part 2) | Brightness, Volume and ... https://www.youtube.com/watch?v=EajYMqfdAEo
[17] How to turn on keyboard led - fedora 39 with Wayland? https://discussion.fedoraproject.org/t/how-to-turn-on-keyboard-led-fedora-39-with-wayland/95892
[18] How do you guys change brightness levels with keys like ... https://www.facebook.com/groups/240120563956894/posts/975733813728895/
[19] Adjusting brightness on Wayland compositors without built- ... https://forums.freebsd.org/threads/adjusting-brightness-on-wayland-compositors-without-built-in-support-for-it.97881/
[20] Keyboard backlight fading on and off - Support https://forum.manjaro.org/t/keyboard-backlight-fading-on-and-off/139411
[21] You're Probably Doing Screen Brightness in Arch Linux ... https://www.youtube.com/watch?v=pGOaSS8nEQA

