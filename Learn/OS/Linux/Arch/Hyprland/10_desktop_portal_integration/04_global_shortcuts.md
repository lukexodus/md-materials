## Global Shortcuts


### Portal Support and Hyprland Methods

- `xdg-desktop-portal-hyprland` provides a portal for registering global keyboard shortcuts, directly supporting applications (including Flatpak and sandboxed apps) to receive input when unfocused.[1][2][3]
- Hyprland implements its own protocol (`hyprland_global_shortcuts_v1`) allowing clients to register triggerable actions as global shortcuts; the compositor manages keybinding and triggers.[4][5]

### Binding Global Shortcuts in Hyprland

- Native Wayland apps (or those using the GlobalShortcuts portal) can receive global shortcuts through the portal mechanism.
- Bind global shortcuts in `~/.config/hypr/hyprland.conf` using the `global` dispatcher, for example:
  ```
  bind = SUPERSHIFT, A, global, coolApp:myToggle
  ```
  - This triggers the `myToggle` action in `coolApp` when `Super+Shift+A` is pressed, even if the app is unfocused.[6][4]
- To see available global shortcuts for running apps, use:
  ```
  hyprctl globalshortcuts
  ```
  - This will list registered shortcuts for applications supporting the protocol.[4]

### Classic Pass/Sendshortcut Binding

- Hyprland allows passing keys to specific windows directly:
  ```
  bind = SUPER, F10, pass, class:^(com\\.obsproject\\.Studio)$
  ```
- Or to trigger a shortcut for an app window:
  ```
  bind = SUPER, F10, sendshortcut, SUPER, F4, class:^(com\\.obsproject\\.Studio)$
  ```
  - Works well for push-to-talk and app-specific actions. Recommended for native Wayland apps; XWayland/sandboxed apps may require portal support.[4]

### Troubleshooting

- Confirm only Hyprland's portal (`xdg-desktop-portal-hyprland`) is running to avoid backend confusion.[3]
- Some desktop environments (KDE, GNOME) have their own portals or limitations; Hyprland’s implementation offers broader application support for Wayland-native and Flatpak apps compared to generic portals.[2][7][8]
- Restart portal services and log out/in if portal registration fails or shortcuts do not work.

***

Related topics: Application/desktop integration, Flatpak sandboxed apps, Wayland protocol details for global shortcuts.

Sources
[1] xdg-desktop-portal-hyprland https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[2] xdg-desktop-portal-wlr VS xdg-desktop-portal-hyprland https://www.reddit.com/r/hyprland/comments/12uvoor/xdgdesktopportalwlr_vs_xdgdesktopportalhyprland/
[3] xdg-desktop-portal-hyprland https://wiki.hyprland.org/0.41.2/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[4] Binds https://wiki.hypr.land/Configuring/Binds/
[5] Hyprland global shortcuts protocol - Wayland Explorer https://wayland.app/protocols/hyprland-global-shortcuts-v1
[6] GlobalShortcut - Quickshell.Hyprland https://quickshell.outfoxxed.me/docs/master/types/Quickshell.Hyprland/GlobalShortcut/
[7] XDG Global Keybinds Portal in GNOME? - Fedora Discussion https://discussion.fedoraproject.org/t/xdg-global-keybinds-portal-in-gnome/121019
[8] Why KDE can't implement global shortcuts on wayland https://www.reddit.com/r/kde/comments/16fmpf5/why_kde_cant_implement_global_shortcuts_on_wayland/
[9] Implement xdg-foreign v1 & v2 protocols · Issue #6884 https://github.com/hyprwm/Hyprland/issues/6884
[10] Wayland global hotkeys (shortcut) is mostly useless https://dec05eba.com/2024/03/29/wayland-global-hotkeys-shortcut-is-mostly-useless/
[11] Add support for wayland global-shortcuts portal https://www.1password.community/discussions/1password/feature-request-add-support-for-wayland-global-shortcuts-portal/110057
[12] globalShortcut https://electronjs.org/docs/latest/api/global-shortcut
[13] XDG Desktop Portal https://wiki.archlinux.org/title/XDG_Desktop_Portal
[14] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[15] Global shortcut portal support · Issue #240 https://github.com/emersion/xdg-desktop-portal-wlr/issues/240
[16] Configuring global keybinds? : r/hyprland - Reddit https://www.reddit.com/r/hyprland/comments/1ehk51y/configuring_global_keybinds/
[17] Unable to update due to xdg-desktop-portal-hyprland-git https://forum.garudalinux.org/t/unable-to-update-due-to-xdg-desktop-portal-hyprland-git/31601
[18] Uncommon tips & tricks - Hyprland Wiki https://wiki.hypr.land/Configuring/Uncommon-tips--tricks/
[19] Global shortcut implementations #134 - flatpak/libportal https://github.com/flatpak/libportal/issues/134
[20] adopt xdg-desktop-portal GlobalShortcuts API · Issue #38288 https://github.com/electron/electron/issues/38288

