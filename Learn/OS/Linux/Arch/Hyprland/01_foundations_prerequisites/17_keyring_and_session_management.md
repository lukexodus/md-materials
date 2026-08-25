## Keyring and Session Management


### Gnome Keyring Unlocking

When using TTY launch without a display manager, manually configure keyring unlocking by editing `/etc/pam.d/login`:[7]

```
auth optional pam_gnome_keyring.so
session optional pam_gnome_keyring.so auto_start
```


Add to `~/.profile`:
```bash
if [ -n "$DESKTOP_SESSION" ];then
  eval $(gnome-keyring-daemon --start --components=secrets)
  export SSH_AUTH_SOCK
fi
```


Add to Hyprland config:
```
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
```


### Alternative: Hyprlock as Login Screen

Some users configure greetd with autologin and launch `hyprlock` via `exec-once` in Hyprland config, effectively using hyprlock as a pseudo-login manager. This method works for basic use cases but does not replace proper display manager functionality and has security implications—there's a timeframe where Hyprland accepts input before hyprlock activates.[8][2]

Sources
[1] Master tutorial https://wiki.hypr.land/Getting-Started/Master-Tutorial/
[2] Proper way to launch Hyprland - Reddit https://www.reddit.com/r/hyprland/comments/1e5qgoj/proper_way_to_launch_hyprland/
[3] Which loginmanager to use? : r/hyprland https://www.reddit.com/r/hyprland/comments/14voff7/which_loginmanager_to_use/
[4] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[5] Master tutorial - Hyprland Wiki https://wiki.hyprland.org/0.41.0/Getting-Started/Master-Tutorial/
[6] FAQ_Login_Managers · JaKooLit/Hyprland-Dots Wiki https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ_Login_Managers
[7] Configuring - Hyprland Wiki https://wiki.hyprland.org/0.41.2/Configuring/Configuring-Hyprland/
[8] Documentation on "How can I use Hyprlock as a login ... https://github.com/hyprwm/hyprlock/issues/564
[9] Set Display Manager on Startup (Hyprland) : r/archlinux https://www.reddit.com/r/archlinux/comments/1dxnr7a/set_display_manager_on_startup_hyprland/
[10] How to enable login screen and start hyperland after login https://discourse.nixos.org/t/how-to-enable-login-screen-and-start-hyperland-after-login/37775
[11] A Noobs Guide to Hyprland | Customizing SDDM Display ... https://www.youtube.com/watch?v=9RLl9VyeTBo

