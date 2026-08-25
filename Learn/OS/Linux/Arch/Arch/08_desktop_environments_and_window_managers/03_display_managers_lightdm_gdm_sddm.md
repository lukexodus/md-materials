## Display Managers (LightDM, GDM, SDDM)


### Display Manager Overview

**Purpose**: Display managers provide graphical login interface, session management, and user authentication.[1][2]

**Distinction from Display Server**: Display managers run before display server starts; they launch the display server after login.[1]

**Function**:[2]
- Provide graphical login prompt[2]
- Manage user sessions[2]
- Handle authentication[2]
- Launch desktop environments[2]

### Common Display Managers

#### GDM (GNOME Display Manager)

**Purpose**: Default for GNOME desktop environment.[2]

**Installation**: `sudo pacman -S gdm`.[1]

**Launch**: `systemctl start gdm`.[1]

**Enable at Boot**: `sudo systemctl enable gdm`.[1][2]

**Features**:[1][2]
- GNOME integration[2]
- Modern appearance[2]
- Accessibility features[2]
- Multi-user session support[2]

**Configuration**: `/etc/gdm/custom.conf`.[1]

**Heavy**: More resource-intensive than alternatives.[2]

#### SDDM (Simple Desktop Display Manager)

**Purpose**: Default for KDE Plasma.[2]

**Installation**: `sudo pacman -S sddm`.[1]

**Launch**: `systemctl start sddm`.[1]

**Enable at Boot**: `sudo systemctl enable sddm`.[1][2]

**Features**:[1][2]
- KDE Plasma integration[2]
- Lightweight[2]
- Qt-based[2]
- Themeable[2]

**Configuration**: `/etc/sddm.conf.d/`.[1]

**Customization**: Extensive theme support.[2]

#### LightDM

**Purpose**: General-purpose lightweight display manager.[2]

**Installation**: `sudo pacman -S lightdm lightdm-gtk-greeter`.[1][2]

**Launch**: `systemctl start lightdm`.[1]

**Enable at Boot**: `sudo systemctl enable lightdm`.[1][2]

**Features**:[1][2]
- Lightweight and fast[2]
- Highly configurable[2]
- Multiple greeter options[2]
- VT switching support[2]

**Configuration**: `/etc/lightdm/lightdm.conf`.[1]

**Flexibility**: Works with any desktop environment.[2]

### Installation and Setup

#### Choose Display Manager

**For GNOME**: Install GDM:[1][2]

```bash
sudo pacman -S gdm
```

**For KDE Plasma**: Install SDDM:[1][2]

```bash
sudo pacman -S sddm
```

**Lightweight Alternative**: Install LightDM:[1][2]

```bash
sudo pacman -S lightdm lightdm-gtk-greeter
```

#### Enable Display Manager

**Systemctl Enable**:[1][2]

```bash
sudo systemctl enable gdm      # GNOME
sudo systemctl enable sddm     # KDE
sudo systemctl enable lightdm  # LightDM
```

**Start Immediately**:[1]

```bash
sudo systemctl start display_manager_name
```

**Disable Conflicting Managers**:[1]

```bash
sudo systemctl disable old_display_manager
```

#### Auto-Start on Boot

**Set Default Target**:[1]

```bash
sudo systemctl set-default graphical.target
```

**Verify**:[1]

```bash
systemctl get-default
```

### Configuration

#### GDM Configuration

**Main Config File**: `/etc/gdm/custom.conf`.[1]

**Common Settings**:[1]

```ini
[daemon]
# Automatic login
AutomaticLoginEnable=true
AutomaticLogin=username

# Session type
Session=gnome

# Wayland or X11
WaylandEnable=true
```

**Enable Automatic Login**:[1]

```bash
sudo nano /etc/gdm/custom.conf
# Uncomment AutomaticLogin lines
```

#### SDDM Configuration

**Config Directory**: `/etc/sddm.conf.d/`.[1]

**Main File**: `kde_settings.conf`.[1]

**Theme Selection**:[1]

```ini
[General]
Session=plasmawayland  # or plasmashell for X11
Theme=Breeze
```

**Font Settings**:[1]

```ini
Font=Noto Sans,10
```

**Automatic Login**:[1]

```ini
[General]
Session=plasmawayland
User=username
Session=plasmawayland
```

#### LightDM Configuration

**Main Config**: `/etc/lightdm/lightdm.conf`.[2][1]

**Session Setting**:[1]

```ini
[Seat:*]
session-wrapper=/etc/lightdm/Xsession
session-type=x11
greeter-session=lightdm-gtk-greeter
```

**User Session**:[1]

```ini
[Seat:*]
user-session=openbox  # or other session
```

**Greeter Configuration**:[2]

```ini
[lightdm-gtk-greeter]
background=/usr/share/pixmaps/wallpaper.png
theme-name=Adwaita
font-name=Noto Sans 11
```

### Switching Display Managers

#### Current Display Manager

**Check Active**:[1]

```bash
systemctl get-default
systemctl status display-manager.service
```

**Alternative Check**:[1]

```bash
ps aux | grep -i "gdm\|sddm\|lightdm"
```

#### Switch Managers

**Stop Current**:[1]

```bash
sudo systemctl stop display-manager.service
```

**Enable New Manager**:[1]

```bash
sudo systemctl enable gdm        # Switch to GDM
sudo systemctl start gdm
```

**Test Before Committing**:[1]
1. Enable new manager[1]
2. Start manually[1]
3. Verify functionality[1]
4. Return to previous if issues[1]

### User Session Management

#### Available Sessions

**GNOME Sessions**: GNOME, GNOME (Wayland).[3][2]

**KDE Sessions**: Plasma, Plasmawayland.[3][2]

**Lightweight**: Openbox, i3, dwm, XFCE.[2]

**Selection at Login**:[2]
1. Enter credentials[2]
2. Click session selector (usually gear icon)[2]
3. Choose preferred session[2]
4. Login[2]

#### Session Persistence

**Default Session**: Display manager remembers last selection.[2][1]

**Manual Override**: Always available at login.[1]

**Per-User Setting**: Each user can have different default.[1]

### Automatic Login

#### Security Implications

**Risk**: Automatic login bypasses authentication.[1]

**Appropriate For**:[1]
- Single-user systems[1]
- Kiosk installations[1]
- Development machines[1]

**Not Recommended For**:[1]
- Multi-user systems[1]
- Sensitive environments[1]
- Public systems[1]

#### Configuration

**GDM Automatic Login**:[1]

```bash
sudo nano /etc/gdm/custom.conf
# Add:
AutomaticLoginEnable=true
AutomaticLogin=username
```

**SDDM Automatic Login**:[1]

```bash
sudo nano /etc/sddm.conf.d/kde_settings.conf
# Add:
User=username
Session=plasmawayland
```

**LightDM Automatic Login**:[1]

```bash
sudo nano /etc/lightdm/lightdm.conf
# Add:
autologin-user=username
autologin-user-timeout=0
```

### Customization

#### GDM Theming

**Limited Customization**: GDM themes restrictive.[2]

**CSS-Based**: Modify `/usr/share/gnome-shell/theme/`.[1]

**Manual Modification**:[1]

```bash
sudo cp /usr/share/gnome-shell/theme/gnome-shell.css /usr/share/gnome-shell/theme/gnome-shell.css.bak
sudo nano /usr/share/gnome-shell/theme/gnome-shell.css
```

#### SDDM Theming

**Theme Selection**: Choose from installed themes.[2]

**Install Themes**:[1]

```bash
sudo pacman -S sddm-themes
```

**Configuration**:[1]

```bash
sudo nano /etc/sddm.conf.d/kde_settings.conf
# Set Theme=theme_name
```

#### LightDM Customization

**Greeter Options**:[2]
- lightdm-gtk-greeter[2]
- lightdm-slick-greeter[2]
- lightdm-webkit2-greeter[2]

**Install Greeter**:[1]

```bash
sudo pacman -S lightdm-gtk-greeter
```

**Configure**:[1]

```bash
sudo nano /etc/lightdm/lightdm-gtk-greeter.conf
```

### Troubleshooting Display Managers

#### Display Manager Won't Start

**Check Status**:[1]

```bash
systemctl status gdm
journalctl -u gdm -n 50
```

**Common Issues**:[1]
- Conflicting services[1]
- Missing dependencies[1]
- Configuration errors[1]

**Reinstall**:[1]

```bash
sudo pacman -S --force gdm
```

#### Login Loop

**Symptoms**: Infinite login loop after password entry.[1]

**Causes**:[1]
- Session configuration incorrect[1]
- Desktop environment not installed[1]
- Permission issues[1]

**Debug**:[1]

```bash
# Boot to TTY
Ctrl+Alt+F2
# Check home directory permissions
ls -la ~/ | head
```

**Fix Permissions**:[1]

```bash
chmod 755 ~/
```

#### Display Manager Service Failed

**Enable Failed**:[1]

```bash
sudo systemctl status display-manager.service
```

**Switch Managers**:[1]

```bash
sudo systemctl disable failed_manager
sudo systemctl enable working_manager
sudo reboot
```

### Performance Comparison

#### Resource Usage

**GDM**:[2]
- Heaviest[2]
- GNOME integration[2]
- More memory[2]

**SDDM**:[2]
- Lightweight[2]
- Qt-based[2]
- Fast startup[2]

**LightDM**:[2]
- Very lightweight[2]
- Minimal dependencies[2]
- Fastest boot[2]

#### Startup Time

**LightDM**: Fastest.[2]

**SDDM**: Fast.[2]

**GDM**: Slower.[2]

### Best Practices

**Match Desktop**: Use recommended manager for environment.[2][1]

**Test First**: Switch managers on working system before production.[1]

**Backup Config**: Save working configurations.[1]

**Security**: Disable automatic login on multi-user systems.[1]

**Updates**: Keep display manager current.[1]

**Documentation**: Record customizations.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824
[3] Wayland vs X11 - YouTube https://www.youtube.com/watch?v=AIxmYKw79HU

