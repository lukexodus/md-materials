## Display Managers


Display managers provide graphical login screens and session selection for Hyprland. While TTY-based launch is recommended, several display managers offer Hyprland-compatible configurations with varying levels of compatibility and reliability.[1][2][3]

### SDDM (Simple Desktop Display Manager)

**SDDM** is the most reliable display manager for Hyprland, offering excellent compatibility and extensive customization. Install on Arch Linux with `sudo pacman -S sddm` or use `sddm-git` from AUR for latest features.[4][5][1]

**Important:** Install SDDM version 0.20.0 or later to avoid bug 1476 causing 90-second shutdowns on exit. Verify version with `sddm --version`.[5][1]

Enable SDDM with `sudo systemctl enable sddm.service`. Configure SDDM theme in `/etc/sddm.conf.d/kde_settings.conf` under `[general]` section:[2][5]
```
[general]
Session=hyprland
Theme=sugar-candy
```


Install additional themes with `yay -S sddm-theme-sugar-candy` or other theme packages. SDDM automatically detects Hyprland and displays it in the session menu once installed.[3][5]

### GDM (GNOME Display Manager)

**GDM** works but exhibits reliability issues specific to Hyprland. GDM crashes on first Hyprland launch, requiring manual intervention or restarting. Some users report persistent issues making GDM unsuitable for production use.[1][4]

Install with `sudo pacman -S gdm` and enable with `sudo systemctl enable gdm.service`. GDM requires no additional Hyprland configuration but may not reliably boot into Hyprland.[4][1]

### greetd with ReGreet

**greetd** is a minimal Wayland-native greeter offering excellent Hyprland integration. Install with `sudo pacman -S greetd greetd-regreet`.[6][1][4]

Configure `/etc/greetd/config.toml`:[6]
```toml
[default_session]
session = hyprland

[terminal]
vt = 2

[default_session_script]
command = "hyprland"
```


For autologin (skip login screen), configure:[6]
```toml
[default_session]
session = greetd
```


greetd can autologin automatically, bypassing the login screen entirely while maintaining systemd integration.[4][6]

### ly (TUI Login Manager)

**ly** is a lightweight text-based login manager offering simplicity and reliability. Install with `sudo pacman -S ly` or from AUR.[1][4]

Enable with `sudo systemctl enable ly.service` and configure `/etc/ly/config.ini` for keyring and display settings. ly works flawlessly with Hyprland and resolves common keyring and compatibility issues.[4]

### lemurs

**lemurs** is a minimal, user-friendly login manager written in Rust. Install from AUR with `yay -S lemurs-git`. lemurs solves common keyring unlocking and compatibility issues while maintaining simplicity.[4]

### Session Selection

When using a display manager, select "Hyprland" from the session menu at login. The exact menu location varies by display manager but typically appears as a dropdown or separate window.[3]

If Hyprland doesn't appear in the session list, the installation is incomplete. Verify by checking install logs and re-running the installation script.[3]

### Hyprland Session Files

Display managers locate sessions through XDG session desktop files. Hyprland installs session files at:[3]
- `/usr/share/wayland-sessions/hyprland.desktop`
- `/usr/share/xsessions/hyprland.desktop` (legacy X11 compatibility)

If these files are missing, reinstall Hyprland completely.[3]

### Virtual Machine Setup

Running Hyprland through a display manager in a VM requires 3D acceleration enabled. Configure VirtualBox or KVM with 3D support before launching. Without 3D acceleration, Hyprland fails to start regardless of display manager.[1][3]

### Display Manager Troubleshooting

**Login loop:** The display manager returns to the login screen after attempting to log in. Check Hyprland installation logs in the display manager's log directory. Common causes: missing Hyprland packages, 3D acceleration disabled in VMs, or incomplete installation.[3]

**Session not appearing:** Hyprland not listed in session menu means session files are missing or corrupted. Reinstall Hyprland and verify session files exist.[3]

**Keyboard/mouse not working:** Some display managers require additional input configuration. ly and lemurs have built-in configuration options; greetd requires manual configuration.[4]

**Hang on logout:** SDDM versions before 0.20.0 hang for 90 seconds on exit due to bug 1476. Update to the latest version.[5][1]

### TTY Launch Alternative

Avoid display managers entirely by launching from TTY:[1][6]

Add to `~/.bash_profile` or `~/.zprofile`:
```bash
[[ "$(tty)" == /dev/tty1 ]] && Hyprland
```


Log into TTY1 and Hyprland launches automatically. This eliminates display manager complications and provides the most reliable Hyprland session.[7][1][6]

### Comparison Table

| Display Manager | Compatibility | Complexity | Reliability | Recommended |
|---|---|---|---|---|
| SDDM | Excellent | Medium | Excellent | ✓ Yes |
| GDM | Fair | Low | Poor | No |
| greetd | Excellent | Low | Excellent | ✓ Yes |
| ly | Excellent | Low | Excellent | ✓ Yes |
| lemurs | Excellent | Low | Excellent | ✓

Sources
[1] Master tutorial https://wiki.hypr.land/Getting-Started/Master-Tutorial/
[2] Set Display Manager on Startup (Hyprland) : r/archlinux https://www.reddit.com/r/archlinux/comments/1dxnr7a/set_display_manager_on_startup_hyprland/
[3] FAQ_Login_Managers · JaKooLit/Hyprland-Dots Wiki https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ_Login_Managers
[4] Which loginmanager to use? : r/hyprland https://www.reddit.com/r/hyprland/comments/14voff7/which_loginmanager_to_use/
[5] A Noobs Guide to Hyprland | Customizing SDDM Display ... https://www.youtube.com/watch?v=9RLl9VyeTBo
[6] Proper way to launch Hyprland - Reddit https://www.reddit.com/r/hyprland/comments/1e5qgoj/proper_way_to_launch_hyprland/
[7] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland

