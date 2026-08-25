## Keyboard Layout & Variants


### Configuration in Hyprland

- Hyprland uses XKB for keyboard layout management, with settings placed in the `input` block of `~/.config/hypr/hyprland.conf` (or your custom config fragments).[1][2][3][4]
- To set multiple layouts and a switch key, use:

  ```
  input {
    kb_layout = us,ru   # Specify layouts: US and Russian
    kb_variant = ,      # Variant per layout, empty means default
    kb_options = grp:alt_shift_toggle # Alt+Shift toggles layout
  }
  ```
  - Replace layouts and options for your needs (e.g., add Arabic, German, French etc.).[5][3]

### Switch Keys & Options

- Popular toggles: `grp:alt_shift_toggle`, `grp:win_space_toggle`, etc.
- Example to switch with Super+Space:
  ```
  kb_options = grp:win_space_toggle
  ```
  Find all available toggles using:
  ```
  grep "grp:.*toggle" /usr/share/X11/xkb/rules/base.lst
  ```
  For layout codes and variants:
  ```
  grep -i 'NAME' /usr/share/X11/xkb/rules/base.lst
  ```
  where NAME is your language or variant.[6][1]

### On-the-Fly Switching

- You can switch layouts instantly (e.g., from scripts or binds) using:
  ```
  hyprctl switchxkblayout <layout-index>
  ```
  - Create binds for layout index changes, e.g.:
    ```
    bind = SUPER, x, exec, hyprctl switchxkblayout 1 # Switch to layout at index 1
    bind = SUPER, z, exec, hyprctl switchxkblayout 0 # Switch to layout at index 0
    ```
 .[7][3][8]

### Per-Device Config and Persistence

- If you have multiple keyboards or special devices, you can set layouts per device with:
  ```
  input {
      kb_file = <device-path> # For specific hardware
      kb_layout = us,de
      kb_variant = ,nodeadkeys
  }
  ```
  - Find device path via `ls /dev/input/by-id/`.[1]
- Restart Hyprland (logout/login) after modifying layout configs for full effect.[3][7][5]

### Additional Resources

- Reference: `/usr/share/X11/xkb/rules/base.lst`—full list of models, layouts, variants, options.[6]
- Changing console layout: Set `KEYMAP=us` in `/etc/vconsole.conf` for TTY, but this does not affect graphical sessions in Wayland/Hyprland.[9][10]

***

Related topics: Per-window layout manager, special language variants, troubleshooting dead keys or intl layouts.[11][12]

Sources
[1] Uncommon tips & tricks https://wiki.hypr.land/Configuring/Uncommon-tips--tricks/
[2] Keyboard layout in wayland - how to change - General https://discuss.cachyos.org/t/keyboard-layout-in-wayland-how-to-change/4120
[3] Change Keyboard Layout · end-4 dots-hyprland https://github.com/end-4/dots-hyprland/discussions/1448
[4] How to change keyboard variant? #2372 - hyprwm Hyprland https://github.com/hyprwm/Hyprland/discussions/2372
[5] [Bug]: After update can't change keyboard layout (language ... https://github.com/prasanthrangan/hyprdots/issues/1339
[6] Variables https://wiki.hypr.land/Configuring/Variables/
[7] Keyboard layout changing / Newbie Corner ... https://bbs.archlinux.org/viewtopic.php?id=293939
[8] Hyprland bind for switching all keyboard layouts, handling ... https://gist.github.com/martinkozle/6f622e36e5686751ef6ef90db33f4c36
[9] Arch Linux with Hyprland (2025 edition) - Richard Grundy https://rich.grundy.io/blog/arch-linux-with-hyprland-2025-edition/
[10] [SOLVED] Unable to type "ç" or "Ç" using ' + c on Wayland ... https://bbs.archlinux.org/viewtopic.php?id=301265
[11] Hyprland Per-Window Keyboard Layout Manager https://crates.io/crates/hyprland-per-window-layout
[12] Arch Linux + Hyprland-uwsm and Keyboard layout: US + ... https://github.com/ghostty-org/ghostty/discussions/8877
[13] ELI5: how do i change keyboard layout in hyprland https://www.reddit.com/r/hyprland/comments/xtxmv8/eli5_how_do_i_change_keyboard_layout_in_hyprland/
[14] How to Configure Keyboard Layout on Arch Linux https://www.siberoloji.com/how-to-configure-keyboard-layout-on-arch-linux/
[15] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[16] Switch US keyboard variant from 'intl' to 'default' in Xorg ... https://gist.github.com/datsfilipe/0f67bdf0a0ae4bba4080097ed8a79c6c
[17] Hyprland keyboard layout issue https://forum.garudalinux.org/t/hyprland-keyboard-layout-issue/33473
[18] How I change keyboard layout? - Issues & Assistance https://discuss.cachyos.org/t/how-i-change-keyboard-layout/15038
[19] Installing Arch Linux & Hyprland. My Development ... https://www.youtube.com/watch?v=iykD_ELku7g
[20] Master tutorial https://wiki.hypr.land/Getting-Started/Master-Tutorial/

