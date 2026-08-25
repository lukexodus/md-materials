## Typematic Delay & Rate


### Hyprland Configuration

- Hyprland provides direct options to set keyboard repeat rate (characters per second) and delay (milliseconds before repeat starts) in the `input` block of your `~/.config/hypr/hyprland.conf` file.[1][2][3][4]
- Example configuration:
  ```
  input {
      repeat_rate = 35     # Repeats per second
      repeat_delay = 200   # Delay in milliseconds before repeat starts
  }
  ```
- These values replace the old `xset r rate` settings used on Xorg and are handled natively by the Wayland compositor (Hyprland).[5][6]

### Per-Device Configuration

- For multiple keyboards, you may override repeat rate/delay per device in the same config as:
  ```
  input {
      kb_file = /dev/input/by-id/your-keyboard
      repeat_rate = 50
      repeat_delay = 500
  }
  ```
  - Default/global settings are overridden by specific device blocks.[7][8]

### Changes and Troubleshooting

- Save your configuration and then reload Hyprland (or restart your session) for changes to take effect.
- If you want to experiment, lowering `repeat_delay` makes repeats start faster, and increasing `repeat_rate` increases the speed of repeat events.[2][3]
- These settings are effective across all applications run in your Wayland session; apps do not typically need or override their own repeat rates unless managed through the compositor.[3]

***
Related topics: Per-keyboard settings, repeat and binding flags, compatibility with scripts and automated configuration.

Sources
[1] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/
[2] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[3] Hyprland on Arch — Minimal Setup Guide - Tony, btw. https://www.tonybtw.com/tutorial/hyprland/
[4] Variables - Hyprland Wiki https://wiki.hyprland.org/0.45.0/Configuring/Variables/
[5] is there a way to change the key repeat rate? - hyprland - Reddit https://www.reddit.com/r/hyprland/comments/134qtko/is_there_a_way_to_change_the_key_repeat_rate/
[6] Basic Config · hyprwm/Hyprland Wiki - GitHub https://github.com/hyprwm/Hyprland/wiki/Basic-Config/b1bd6a563aa109de0918b1573e3e8a52d4413990
[7] Keywords - Hyprland Wiki https://wiki.hyprland.org/0.48.0/Configuring/Keywords/
[8] Keywords https://wiki.hyprland.org/0.41.0/Configuring/Keywords/
[9] How to set keyboard delay/repeat rate in Wayland? - NixOS Discourse https://discourse.nixos.org/t/how-to-set-keyboard-delay-repeat-rate-in-wayland/56982
[10] Remapping keys and setting repeat rate under Sway/Wayland #5207 https://github.com/swaywm/sway/issues/5207
[11] Key repeat not working for raise/lower volume · Issue #1231 https://github.com/hyprwm/Hyprland/issues/1231
[12] hyprland-wiki/pages/Configuring/Variables.md at hyprpm https://code.hyprland.org/hyprwm/hyprland-wiki/src/branch/hyprpm/pages/Configuring/Variables.md
[13] Make the key repeat timer use the keyboard that triggered ... https://github.com/hyprwm/Hyprland/issues/10978
[14] hyprwm/Hyprland https://code.hyprland.org/hyprwm/Hyprland/commits/tag/v0.20.0beta?page=40
[15] Binds https://wiki.hypr.land/Configuring/Binds/
[16] hyprwm/Hyprland https://code.hyprland.org/hyprwm/Hyprland/commits/tag/v0.20.0beta/src?page=31
[17] Your OS' Keyboard Repeat Delay and Rate Settings Are ... - YouTube https://www.youtube.com/watch?v=4UnmzovK_eM
[18] Binds | Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Configuring/Binds/

