## Device Enable/Disable


### Static (Config File) Control

- Devices (touchpad, mouse, keyboard, etc.) can be enabled or disabled in the `~/.config/hypr/hyprland.conf` using the `device` block:
  ```
  device {
    name = <device_name>
    enabled = false
  }
  ```
  - Get accurate device names from:
    ```
    hyprctl devices
    ```
  - Replace `<device_name>` with the string exactly as shown in the output.[1][2]

### Dynamic Control (On-the-Fly)

- You can enable or disable devices during a running session with `hyprctl`:
  ```
  hyprctl keyword "device[<device_name>]:enabled" false
  hyprctl keyword "device[<device_name>]:enabled" true
  ```
  - This takes effect immediately and does not require a restart.[3][4][1]

- Sample Hyprland config for toggling with a keybind:
  ```
  bind = $mainMod, t, exec, hyprctl keyword "device[<device_name>]:enabled" false
  bind = $mainMod Shift, t, exec, hyprctl keyword "device[<device_name>]:enabled" true
  ```
  - Replace `$mainMod` and `<device_name>` as needed.[1]

### Notes and Caveats

- Device names are case-sensitive and must be exact as listed by `hyprctl devices`.[3]
- Previous syntax (`device:<name>:enabled`) is deprecated; always use the square bracket/colon style:
  ```
  hyprctl keyword "device[my-touchpad]:enabled" false
  ```
- Changes via config file require session reload or restart, whereas `hyprctl` changes are instant but not persistent after reboot.[3][1]

***

Related topics: Per-device configuration, batch toggling, hotplugging caveats, scripting with udev rules for event-driven enable/disable.

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Help with disabling a input device - hyprland https://www.reddit.com/r/hyprland/comments/1c09gq0/help_with_disabling_a_input_device/
[3] Dynamically Enable/disable device : r/hyprland https://www.reddit.com/r/hyprland/comments/1bqohmd/dynamically_enabledisable_device/
[4] Cannot disable device as default · Issue #8458 https://github.com/hyprwm/Hyprland/issues/8458
[5] Cannot configure input devices through hyprctl #5195 https://github.com/hyprwm/Hyprland/issues/5195
[6] Monitors https://wiki.hypr.land/Configuring/Monitors/
[7] Hyprctl devices doesn't detect new devices : r/hyprland - Reddit https://www.reddit.com/r/hyprland/comments/13m1olc/hyprctl_devices_doesnt_detect_new_devices/
[8] Using hyprctl https://wiki.hypr.land/Configuring/Using-hyprctl/
[9] Run script on monitor plug in : r/hyprland - Reddit https://www.reddit.com/r/hyprland/comments/19bn9u4/run_script_on_monitor_plug_in/
[10] Disable keyboard with a bind · hyprwm Hyprland https://github.com/hyprwm/Hyprland/discussions/4283
[11] How to disable touchpad on hyprland - Newbie https://forum.endeavouros.com/t/how-to-disable-touchpad-on-hyprland/50134
[12] [SOLVED] udev rule for hotplugging monitor in gnome (wayland ... https://bbs.archlinux.org/viewtopic.php?id=283775
[13] Variables https://wiki.hypr.land/Configuring/Variables/
[14] A Noobs Guide to Hyprland | EP:6 - Devices & Environment https://www.youtube.com/watch?v=TQpUQQP7AuE
[15] Disable hotplug (auto-detect) of input devices, and pre-configure ... https://github.com/hyprwm/Hyprland/issues/9840
[16] Using hyprctl https://wiki.hyprland.org/0.41.0/Configuring/Using-hyprctl/
[17] Variables https://wiki.hyprland.org/0.45.0/Configuring/Variables/
[18] Hyprland Hot-Fixes | Josh's Notes https://notes.joshrnoll.com/notes/hyprland-hot-fixes/
[19] Binds https://wiki.hyprland.org/0.46.0/Configuring/Binds/
[20] Configuring Hyprland to Disable the Laptop Screen when ... https://www.youtube.com/shorts/deZlxPWVuN4

