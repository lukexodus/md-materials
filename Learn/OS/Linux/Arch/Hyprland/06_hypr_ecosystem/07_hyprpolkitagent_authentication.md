## Hyprpolkitagent (Authentication)


Hyprpolkitagent is Hyprland's native polkit authentication agent providing graphical password prompts for privileged operations. It replaces generic polkit agents with a compositor-integrated solution supporting Wayland natively.[1][2]

### Purpose and Function

Polkit (PolicyKit) is a system authorization framework allowing users to perform privileged actions without root login. When an application requests elevated privileges (e.g., mounting drives, installing packages, changing system settings), polkit requires authentication through an agent. Hyprpolkitagent provides the Hyprland-specific authentication UI.[2][1]

### Installation

Install on Arch Linux with `sudo pacman -S hyprpolkitagent-hyprland`. The package provides both the agent and integration with Hyprland.[1]

### Automatic Startup

Start the agent automatically on Hyprland launch by adding to `hyprland.conf`:[1]
```
exec-once = /usr/lib/hyprpolkitagent-hyprland
```


The absolute path ensures reliable execution; verify the correct path with `which hyprpolkitagent-hyprland` or `find /usr -name hyprpolkitagent-hyprland`.[1]

### Alternative Polkit Agents

If Hyprpolkitagent is unavailable or incompatible, alternatives provide authentication:[2][1]

**KDE Polkit Agent:**
```
exec-once = /usr/lib/polkit-kde-authentication-agent-1
```


Works well with Hyprland and displays authentication prompts as native GUI windows.[1]

**GNOME Polkit Agent:**
```
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
```


Compatible but may not integrate as smoothly with Hyprland.[1]

**Plain Polkit Agent (minimal):**
```
exec-once = lxpolkit
```


Lightweight alternative; may not provide visual feedback.[1]

### Configuration

Hyprpolkitagent typically requires no additional configuration beyond startup. It automatically handles authentication prompts based on system polkit rules.[2][1]

System polkit policies reside in:[1]
- `/usr/share/polkit-1/actions/` - System policies
- `~/.local/share/polkit-1/actions/` - User policies (rarely needed)

Modify policies to change authentication requirements for specific actions.[1]

### Visual Customization

Hyprpolkitagent respects Hyprland theming and desktop environment settings. Authentication prompts appear as native Wayland windows matching the compositor's decoration style.[1]

Customize appearance through environment variables or configuration if the agent supports them (check documentation).[1]

### Usage Examples

**Mounting drives:**
```bash
udisksctl mount -b /dev/sdX1
```


Polkit prompts for password via Hyprpolkitagent.[1]

**Installing packages:**
```bash
sudo pacman -S package
```


Traditional sudo (doesn't use polkit); Hyprpolkitagent not required.[1]

**System settings requiring elevated privileges:**
Opening system settings that require authorization triggers Hyprpolkitagent.[1]

**Flatpak authorization:**
Some Flatpak applications require polkit authentication for system access.[1]

### Troubleshooting

**Authentication prompts not appearing:** Verify Hyprpolkitagent is running:[1]
```bash
pgrep -a hyprpolkitagent
```


If not running, check `hyprland.conf` for correct exec-once line and restart Hyprland.[1]

**Wrong password accepted:** Polkit agent issue; verify system authentication works with `su` or `sudo`.[1]

**Agent crashes on authentication:** Use alternative polkit agent (KDE or GNOME).[1]

**Missing authentication prompts in Flatpak apps:** Ensure Flatpak has access to `DBUS_SYSTEM_BUS_ADDRESS` environment variable. Set in `hyprland.conf`:[1]
```
env = DBUS_SYSTEM_BUS_ADDRESS,unix:path=/run/dbus/system_bus_socket
```


### Example Session Configuration

Comprehensive authentication setup for Hyprland:[1]

```
# D-Bus environment (required for polkit)
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# D-Bus system bus address (for Flatpak)
env = DBUS_SYSTEM_BUS_ADDRESS,unix:path=/run/dbus/system_bus_socket

# Polkit authentication agent
exec-once = /usr/lib/hyprpolkitagent-hyprland

# Or use KDE alternative if Hyprpolkitagent unavailable
# exec-once = /usr/lib/polkit-kde-authentication-agent-1
```


### Integration with systemd User Services

Polkit can trigger systemd user services requiring authentication. Example service requesting elevated privileges:[1]

**~/.config/systemd/user/backup.service:**
```
[Unit]
Description=System Backup
RequiresMountsFor=/backup

[Service]
Type=oneshot
ExecStart=/usr/bin/rsync -av / /backup
PolicyPolicyKit=yes
```


Hyprpolkitagent prompts for password when service is started.[1]

### Security Considerations

**Timeout:** Authentication prompts timeout after period of inactivity to prevent locked screens.[1]

**Session security:** Hyprpolkitagent operates within the user's Wayland session; compromised user account bypasses authentication.[1]

**Privilege escalation:** Polkit prevents privilege escalation; Hyprpolkitagent merely provides UI for authentication.[1]

### Example Comprehensive Configuration

```
# Authentication and D-Bus
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = /usr/lib/hyprpolkitagent-hyprland

# D-Bus environment for system operations
env = DBUS_SYSTEM_BUS_ADDRESS,unix:path=/run/dbus/system_bus_socket

# Alternative agent (if Hyprpolkitagent unavailable)
# exec-once = /usr/lib/polkit-kde-authentication-agent-1
```


Hyprpolkitagent handles all privileged operations transparently once running.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/


