## Installing Display Servers (Xorg, Wayland)


### Display Server Overview

**Purpose**: Display servers manage graphics rendering, window positioning, and user input for graphical environments.[1][2]

**Xorg**: Traditional X11 display server with decades of compatibility.[2][1]

**Wayland**: Modern replacement offering improved security and multi-monitor support.[1][2]

**Desktop Environments**: GNOME and KDE support both; user selects at login.[2]

### Xorg Installation

#### Core Xorg Packages

**Installation**: `sudo pacman -S xorg-server xorg-xinit`.[3]

**Components**:[3]
- **`xorg-server`**: Core Xorg display server[3]
- **`xorg-xinit`**: Startup utilities including `startx`[3]

**Verification**: `Xvfb --version` confirms installation.[3]

#### Input Device Drivers

**Essential Packages**:[3]

```bash
sudo pacman -S xorg-xkill xorg-xprop xorg-xset xorg-xhost
```

**Keyboard and Mouse**:[3]
- Automatically detected in most cases[3]
- Manual configuration rarely needed[3]

#### Graphics Drivers

**AMD/ATI**:[3]

```bash
sudo pacman -S xf86-video-amdgpu
```

**Intel**:[3]

```bash
sudo pacman -S xf86-video-intel
```

**NVIDIA**:[3]

```bash
sudo pacman -S nvidia  # For recent cards
# or
sudo pacman -S nvidia-390xx  # For older cards
```

**Generic/VirtualBox**:[3]

```bash
sudo pacman -S xf86-video-vesa  # Fallback
sudo pacman -S virtualbox-guest-utils  # VirtualBox
```

**Verify Driver**: `lspci | grep -i vga` identifies graphics card [3].

#### Input Device Drivers

**Touchpad Support**:[3]

```bash
sudo pacman -S xf86-input-libinput
```

**Legacy Input**:[3]

```bash
sudo pacman -S xf86-input-evdev
```

#### Complete Xorg Setup

**All-in-One Installation**:[3]

```bash
sudo pacman -S xorg xorg-server xorg-xinit
```

**Includes**: Base server, utilities, and common drivers.[3]

### Xorg Configuration

#### Automatic Configuration

**Modern Systems**: Xorg auto-detects hardware.[3]

**No Manual Config Needed**: Works out-of-box in most cases.[3]

#### Manual Configuration

**Generate Config**: `Xorg -configure` creates template:[3]

```bash
Xorg -configure
```

**Output**: Creates `/root/xorg.conf.new`.[3]

**Review and Copy**:[3]

```bash
sudo cp /root/xorg.conf.new /etc/X11/xorg.conf
```

**Edit If Needed**: `sudo nano /etc/X11/xorg.conf`.[3]

#### Common Configuration Options

**Monitor Settings**:[3]

```
Section "Monitor"
    Identifier "HDMI-1"
    HorizSync 30-83
    VertRefresh 56-75
    Modeline "1920x1080_60" ...
EndSection
```

**Graphics Device**:[3]

```
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    BusID "PCI:1:0:0"
    Option "Coolbits" "28"
EndSection
```

**Screen Configuration**:[3]

```
Section "Screen"
    Identifier "Default Screen"
    Device "NVIDIA Card"
    Monitor "HDMI-1"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080"
    EndSubSection
EndSection
```

### Wayland Installation

#### GNOME with Wayland

**Installation**: `sudo pacman -S gnome` includes Wayland session.[2]

**Default Session**: GNOME defaults to Wayland.[2]

**Login Selection**: Choose "GNOME (Wayland)" at login screen.[2]

#### KDE Plasma with Wayland

**Installation**: `sudo pacman -S plasma-desktop`.[2]

**Wayland Session Available**: Included in KDE.[2]

**Login Selection**: Choose "Plasmawayland" session at login.[2]

### Display Server Selection at Login

#### GNOME Session Selection

**At Login Screen**:[2]
1. Click username[2]
2. Click gear icon (bottom right)[2]
3. Select "GNOME" or "GNOME (Wayland)"[2]
4. Enter password[2]

**Persistent**: Selection remembered for future logins.[2]

#### KDE Plasma Session Selection

**At Login Screen**:[2]
1. Click "Plasma" dropdown (bottom left)[2]
2. Select "Plasma (X11)" or "Plasmawayland"[2]
3. Select user[2]
4. Enter password[2]

**Persistent**: Selection saved.[2]

### Minimal Xorg Setup

#### Bare Xorg Server

**Installation**: `sudo pacman -S xorg-server xorg-xinit`.[3]

**Without Desktop Environment**: Text-based window managers.[3]

**Manual .xinitrc**: Create `~/.xinitrc` to start applications:[3]

```bash
#!/bin/bash
exec openbox  # or i3, dwm, etc.
```

**Start X11**: `startx` from TTY.[3]

### Troubleshooting Display Server Issues

#### No Display on Startup

**Check Xorg Logs**:[3]

```bash
cat ~/.local/share/xorg/Xvfb-99.log
# or
cat /var/log/Xorg.0.log
```

**Common Errors**:[3]
- Missing driver[3]
- Display hardware not detected[3]
- Configuration file errors[3]

**Fallback to VESA Driver**:[3]

```bash
sudo pacman -S xf86-video-vesa
```

#### Wayland Session Won't Start

**Check Logs**:[3]

```bash
journalctl -e | grep -i wayland
```

**Missing Packages**:[3]

```bash
sudo pacman -S wayland wayland-protocols
```

**Compositor Issues**: Verify desktop environment installation.[2]

#### Graphics Driver Conflict

**Remove Old Drivers**:[3]

```bash
sudo pacman -R xf86-video-nouveau  # If using NVIDIA
sudo pacman -S nvidia
```

**Reinstall Current**:[3]

```bash
sudo pacman -S --force xf86-video-intel
```

#### Screen Resolution Issues

**Available Modes**:[3]

```bash
xrandr
```

**Set Resolution**:[3]

```bash
xrandr --output HDMI-1 --mode 1920x1080 --rate 60
```

**Persistent Configuration**: Edit `/etc/X11/xorg.conf`.[3]

### Multi-Head Display Setup

#### Xorg Multi-Monitor

**List Displays**:[3]

```bash
xrandr --listmonitors
```

**Configure Layout**:[3]

```bash
xrandr --output HDMI-1 --mode 1920x1080 --pos 0x0 \
       --output DP-2 --mode 2560x1440 --pos 1920x0
```

**Save Configuration**:[3]

Create startup script or store in desktop environment settings.[3]

#### Wayland Multi-Monitor

**Superior Support**:[4]
- Generally works automatically[4]
- Better scaling across different resolutions[4]

**Configuration**: Through desktop environment settings.[2]

### Performance Optimization

#### Xorg Optimization

**Disable Compositing**: Improve gaming performance:[3]

```bash
# In ~/.xinitrc
exec openbox --replace &
# or through desktop settings
```

**GPU Acceleration**:[3]

For NVIDIA:

```bash
# Add to /etc/X11/xorg.conf
Option "DRI" "true"
```

#### Wayland Optimization

**Compositor Settings**: Through desktop environment.[3]

**Hardware Acceleration**: Usually automatic.[2]

### Security Considerations

#### Xorg Security

**X11 Forwarding Risks**:[1]
- Network transparency enables remote display[1]
- Security implications for SSH X11 forwarding[1]

**Mitigation**:[3]
- Use SSH key authentication[3]
- Enable X11 forwarding only when needed[3]

#### Wayland Security

**Improved Model**:[2]
- Applications cannot spy on each other[2]
- Restricted input access[2]

**Local Only**: No network rendering complicates security but improves safety.[1]

### Hybrid Graphics Setup

#### NVIDIA Optimus

**Installation**:[3]

```bash
sudo pacman -S nvidia bumblebee primus
```

**Run with GPU**: Use discrete GPU when needed:[3]

```bash
primusrun application_name
```

#### AMD Hybrid

**Installation**:[3]

```bash
sudo pacman -S xf86-video-amdgpu
```

**Automatic Switching**: Power management handles switching.[3]

### Headless Server Setup

#### No Display Output

**Installation**: Minimal Xorg:[3]

```bash
sudo pacman -S xvfb xorg-server
```

**Virtual Framebuffer**: For remote access:[3]

```bash
Xvfb :99 -screen 0 1920x1080x24 &
export DISPLAY=:99
```

### Best Practices

**Test Before Committing**: Try Wayland if supported before switching.[2]

**Verify Driver Support**: Ensure graphics driver compatible.[3]

**Keep Fallback**: Install VESA driver as emergency fallback.[3]

**Document Configuration**: Save working xorg.conf.[3]

**Monitor Performance**: Test both for your use case.[5][6]

**Update Regularly**: Keep display server and drivers current.[3]

Sources
[1] What's the deal with X11 and Wayland? - TUXEDO Computers https://www.tuxedocomputers.com/en/Whats-the-deal-with-X11-and-Wayland-_1.tuxedo
[2] Wayland vs X11 - YouTube https://www.youtube.com/watch?v=AIxmYKw79HU
[3] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[4] Revisiting X11 vs Wayland With Multiple Displays - KDE Blogs https://blogs.kde.org/2025/06/02/revisiting-x11-vs-wayland-with-multiple-displays/
[5] Wayland vs X11 on an Nvidia hybrid graphics laptop - Dedoimedo https://www.dedoimedo.com/computers/wayland-vs-x11-performance-nvidia-graphics.html
[6] Wayland vs X11, AMD graphics, KDE neon, 4K and WebGL data https://www.dedoimedo.com/computers/wayland-vs-x11-performance-amd-graphics.html

