## Universal Wayland Session Manager


UWSM (Universal Wayland Session Manager) provides standardized systemd integration for Wayland compositors, including Hyprland. It manages environment variables, D-Bus, systemd user sessions, and application lifecycle consistently across different Wayland implementations.[1][2]

### UWSM Purpose and Benefits

**Standardization:** UWSM eliminates compositor-specific session management hacks by providing a unified interface. Applications receive consistent environment variables regardless of which Wayland compositor runs.[1]

**systemd Integration:** UWSM properly starts systemd user targets (`graphical-session-pre.target`, `graphical-session.target`) ensuring user services activate correctly. This enables password managers, system daemons, and background services to function reliably.[1]

**D-Bus and Environment:** UWSM updates D-Bus with correct environment variables, enabling inter-process communication for applications requiring it. It imports `DISPLAY`, `WAYLAND_DISPLAY`, `XDG_CURRENT_DESKTOP`, and other critical variables into systemd.[1]

### Installation

Install UWSM on Arch Linux with `sudo pacman -S uwsm` or from AUR with `yay -S uwsm-git` for latest features. Other distributions may have UWSM in official repos or AUR.[1]

### Launching with UWSM

Launch Hyprland through UWSM instead of directly:[1]
```bash
uwsm start hyprland
```


This command starts Hyprland under UWSM management with all environment and session setup handled automatically.[1]

### Display Manager Integration

Configure display managers to launch Hyprland through UWSM. Modify the Hyprland session file at `/usr/share/wayland-sessions/hyprland.desktop` or create a custom version in `~/.local/share/wayland-sessions/`:[1]

```ini
[Desktop Entry]
Name=Hyprland (UWSM)
Comment=Hyprland using Universal Wayland Session Manager
Exec=uwsm start hyprland
Type=Application
```


When this session is selected in a display manager, UWSM launches Hyprland with proper setup.[1]

### TTY Launch with UWSM

Launch from TTY through UWSM by adding to shell profile:[1]
```bash
[[ "$(tty)" == /dev/tty1 ]] && uwsm start hyprland
```


This provides TTY-based launch with UWSM benefits.[1]

### Hyprland Configuration with UWSM

When using UWSM, the Hyprland config no longer needs D-Bus initialization commands since UWSM handles them. Remove or comment out these lines from `hyprland.conf`:[1]
```
# No longer needed with UWSM
# exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
# exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
```


Keep authentication agent startup but UWSM simplifies everything else:[1]
```
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = waybar
exec-once = dunst
```


### UWSM Commands

**Check UWSM status:** `uwsm check` displays current Wayland session status.[1]

**List available compositors:** `uwsm query compositors` shows which compositors UWSM can manage.[1]

**Stop session:** `uwsm stop` cleanly stops the current UWSM-managed session.[1]

**Restart:** `uwsm restart` restarts the compositor (similar to `hyprctl reload` but via systemd).[1]

### Application Integration

Applications automatically receive correct environment variables from UWSM, eliminating the need for manual environment configuration in `hyprland.conf`. Wayland-native applications recognize `WAYLAND_DISPLAY` and `XDG_CURRENT_DESKTOP` automatically.[1]

### Service Management

UWSM manages systemd user services through the graphical session target. Custom user services can depend on `graphical-session.target` and start automatically when UWSM launches a session.[1]

Create `~/.config/systemd/user/my-service.service`:[1]
```ini
[Unit]
Description=My Custom Service
PartOf=graphical-session.target
After=graphical-session-pre.target

[Service]
Type=simple
ExecStart=/usr/bin/my-service
Restart=on-failure

[Install]
WantedBy=graphical-session.target
```


Enable with `systemctl --user enable my-service.service` and it starts automatically with the UWSM session.[1]

### Comparison: UWSM vs Manual Setup

**Manual D-Bus setup:**
```
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user start graphical-session-pre.target graphical-session.target
```


**With UWSM:**
All handled automatically; just launch `uwsm start hyprland`[1]

### When to Use UWSM

**Use UWSM if:**
- Running multiple Wayland compositors and need consistent setup[1]
- Using systemd user services requiring proper session integration[1]
- Requiring portability across different Wayland environments[1]
- Preferring standardized Wayland session management[1]

**Manual setup is acceptable if:**
- Using only Hyprland on a single system[1]
- Preferring simpler configuration without additional tooling[1]
- Running in minimal environments where UWSM adds unnecessary complexity[1]

### Example UWSM-Based Hyprland Configuration

```
# Authentication (still needed with UWSM)
exec-once = /usr/lib/polkit-kde-authentication-agent-1

# XDG Desktop Portal
exec-once = /usr/libexec/xdg-desktop-portal-hyprland

# UI and applications (UWSM handles D-Bus)
exec-once = waybar
exec-once = dunst
exec-once = hypridle

# Desktop services
exec-once = /usr/libexec/xdg-desktop-portal-hyprland

# No D-Bus initialization needed; UWSM handles it
```


Launch with `uwsm start hyprland` or configure display manager to use the UWSM-aware session file.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

