## Lightweight Desktop Optimizations


### Lightweight Philosophy

**Goal**: Maximize performance on limited hardware.[1][2]

**Target Systems**:[2][1]
- Older computers[1]
- Low RAM (< 4GB)[1]
- Netbooks and older laptops[1]
- Virtualized environments[1]

**Balance**: Functionality vs. resource consumption.[2]

### Minimal Desktop Environment Selection

#### XFCE Optimization

**Base Installation**: `sudo pacman -S xfce4`.[2][1]

**Minimal Subset**:[2]

```bash
sudo pacman -S xfwm4 xfdesktop xfpanel-switch xfce4-panel
```

**Remove Unnecessary**: `sudo pacman -R xfce4-appfinder xfce4-settings`.[2]

**Advantages**:[2]
- Lightweight yet functional[2]
- Responsive interface[2]
- Low memory footprint[2]

#### LXQt Optimization

**Installation**: `sudo pacman -S lxqt`.[1][2]

**Minimal**:[2]

```bash
sudo pacman -S lxqt-core
```

**Features**:[2]
- Modern Qt5 codebase[2]
- Lightweight performance[2]
- Actively maintained[2]

#### Window Manager Only

**i3 Tiling**:[1][2]

```bash
sudo pacman -S i3-wm i3status i3lock
```

**Openbox Stacking**:[1]

```bash
sudo pacman -S openbox
```

**dwm (Dynamic)**:[1][2]

```bash
yay -S dwm
```

**Advantages**:[1][2]
- Minimal resource usage[2]
- Full customization[1]
- Maximum performance[2]

### File Manager Optimization

#### Lightweight Managers

**PCManFM**:[1][2]

```bash
sudo pacman -S pcmanfm-gtk3
```

**Lightweight, fast, simple**.[2]

**Thunar**:[1]

```bash
sudo pacman -S thunar
```

**Part of XFCE, more features**.[2]

**SpaceFM**:[1]

```bash
yay -S spacefm
```

**Advanced but lightweight**.[2]

#### Disable Thumbnails

**PCManFM**:[1]

Edit `~/.config/pcmanfm-gtk3/default/pcmanfm-gtk3.conf`:

```ini
[Pcmanfm]
show_thumbnail=false
```

**Reduces Memory**: Especially with large directories.[1]

### Terminal Emulator Optimization

#### Lightweight Options

**xterm**:[1]

```bash
sudo pacman -S xterm
```

**Classic, minimal**.[1]

**urxvt (rxvt-unicode)**:[1]

```bash
sudo pacman -S rxvt-unicode
```

**Lightweight, scriptable**.[1]

**st (Simple Terminal)**:[1]

```bash
yay -S st
```

**Minimal C implementation**.[1]

**Termite**:[1]

```bash
yay -S termite
```

**Simple, fast, modern**.[1]

#### Disable Features

**Disable Scrollback**:[1]

Save memory by limiting history.[1]

**Reduce Colors**:[1]

Use 16-color scheme instead of 256.[1]

### Desktop Wallpaper and Compositor

#### Disable Wallpaper

**Save Memory**: Remove wallpaper.[1]

**Set to Solid Color**:[1]

```bash
xsetroot -solid "#1a1a1a"
```

#### Disable Compositor

**Remove Shadows/Fades**:[1]

In XFCE: Uncheck Window Manager → Compositor.[1]

**Performance Gain**: Especially on older GPUs.[1]

**Alternative**: Use simpler compositor:[1]

```bash
sudo pacman -S picom
# Configure minimal settings
```

### System Tray and Panel

#### Minimal Panel

**Remove Unnecessary Applets**:[1]

- Clock (check with command)[1]
- System monitor (use terminal tools)[1]
- Weather (unnecessary)[1]
- Email notifications (unnecessary)[1]

**Keep Essential**:[1]
- Application menu[1]
- Window list[1]
- Workspace switcher[1]

#### Disable Systray

**Reduces startup time and memory**.[1]

In panel settings, uncheck system tray.[1]

### Application Startup Optimization

#### Disable Autostart

**Autostart Directory**: `~/.config/autostart/`.[1]

**Remove** unnecessary startup scripts:[1]

```bash
rm ~/.config/autostart/unnecessary.desktop
```

**Check What Starts**:[1]

```bash
ls ~/.config/autostart/
systemd-analyze blame | head -20
```

#### Selective Autostart

**Keep Only Essential**:[1]
- Network manager[1]
- SSH agent[1]
- Display manager[1]

**Disable**:[1]
- Bluetooth if not needed[1]
- Pulseaudio daemons if not needed[1]
- Update managers[1]

### Memory Optimization

#### Swap Configuration

**Increase Swappiness**:[1]

```bash
echo "vm.swappiness=60" | sudo tee -a /etc/sysctl.d/99-swappiness.conf
sudo sysctl -p
```

**Allows**: Offload inactive memory to swap.[1]

#### RAM Disk

**tmpfs for Temp Files**:[1]

```bash
sudo mount -t tmpfs -o size=256M tmpfs /tmp
```

**Speeds up**: Temporary file operations.[1]

#### Disable Logging

**Reduce Disk I/O**:[1]

```bash
sudo systemctl mask systemd-journald.socket
```

**Alternative**: Limit journal size:[1]

```bash
echo "SystemMaxUse=50M" | sudo tee -a /etc/systemd/journald.conf
sudo systemctl restart systemd-journald
```

### Graphics Optimization

#### Disable Visual Effects

**XFCE**: Uncheck all effects in Window Manager.[1]

**Openbox**: Minimal decoration.[1]

**Reduce Compositing**:[1]

Disable shadows, fade effects.[1]

#### Use Simple Theme

**Lightweight Theme**:[1]

Choose simple, undecorated theme.[1]

**Examples**:[1]
- Adwaita[1]
- Clearlooks[1]
- Murrine[1]

#### Icon Theme

**Minimal Icon Set**:[1]

Use simple icon themes.[1]

**Examples**:[1]
- Hicolor[1]
- Adwaita[1]
- Elementary[1]

### Desktop Environment Tweaking

#### XFCE Optimization

**Disable Thumbnails**:[1]

File Manager → View → Thumbnails = Off.[1]

**Limit Panel**:[1]

Remove unnecessary applets.[1]

**Minimal Theme**:[1]

Select lightweight theme.[1]

#### Openbox Optimization

**Minimal RC**:[1]

```xml
<!-- ~/.config/openbox/rc.xml -->
<theme>
  <name>Clearlooks</name>
  <titleLayout>NMC</titleLayout>
  <keepBorder>no</keepBorder>
  <animateIconify>no</animateIconify>
</theme>
```

**Disable Animations**.[1]

### Software Selection

#### Alternative Applications

**Instead of**:[1]

- Firefox → Midori, Dillo, w3m[1]
- Gimp → Mtpaint, Pinta[1]
- Libreoffice → Abiword, Gnumeric[1]
- Thunderbird → Mutt, Claws Mail[1]

**Lightweight Alternatives**:[1]

```bash
# Editors
sudo pacman -S geany mousepad leafpad

# Image viewers
sudo pacman -S feh viewnior

# Archive managers
sudo pacman -S xarchiver

# PDF readers
sudo pacman -S mupdf zathura
```

#### Text-Based Tools

**Reduce GUI Overhead**:[1]

Use command-line tools:

```bash
# Web browsing
lynx, w3m, links

# File management
midnight commander (mc)

# Text editing
vim, nano, emacs

# Mail client
mutt, alpine

# Music
mpv, cmus
```

### Boot Optimization

#### Disable Services

**List Active Services**:[1]

```bash
systemctl list-unit-files --state=enabled
```

**Disable Unnecessary**:[1]

```bash
sudo systemctl disable bluetooth.service
sudo systemctl disable cups.service
sudo systemctl disable avahi-daemon.service
```

**Gain**: Seconds faster boot.[1]

#### Reduce Timeout Values

**Default Timeout**: 90 seconds:[1]

Edit `/etc/systemd/system.conf`:

```
DefaultTimeoutStopSec=5
DefaultTimeoutAbortSec=5
```

**Faster Shutdown**.[1]

### Runtime Optimization

#### CPU Frequency Scaling

**Set Governor**:[1]

```bash
echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

**Reduce Power**: Lower heat and consumption.[1]

#### Disable Unnecessary Daemons

**On Demand Loading**:[1]

```bash
sudo systemctl mask sshd.service
sudo systemctl mask avahi-daemon.service
```

**Start When Needed**:[1]

```bash
systemctl start servicename
```

### Benchmark and Monitor

#### Performance Before/After

**Boot Time**:[1]

```bash
systemd-analyze
systemd-analyze blame
```

**Memory Usage**:[1]

```bash
free -h
top
```

**Document Results**.[1]

#### Continuous Monitoring

**Real-time Stats**:[1]

```bash
watch -n 1 'free -h && echo && top -bn1 | head -10'
```

**Identify Bottlenecks**.[1]

### Configuration Storage

#### Minimal .xinitrc

**Start Lightweight Desktop**:[1]

```bash
#!/bin/bash
exec openbox-session
# or
exec i3
# or
exec startxfce4
```

#### Lightweight .bashrc

**Minimal Configuration**:[1]

```bash
alias ll='ls -l'
alias la='ls -A'
PS1='\u@\h:\w\$ '
export EDITOR=nano
```

**Avoid Heavy Functions**.[1]

### Power Management

#### Laptop Optimization

**Enable Power Save**:[1]

```bash
echo "1" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_boost
echo "50" | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct
```

**Extended Battery Life**.[1]

#### Screen Brightness

**Reduce Brightness**:[1]

```bash
xrandr --output HDMI-1 --brightness 0.7
```

**Saves Battery**.[1]

#### DPMS (Display Power Management)

**Auto Screen Off**:[1]

```bash
xset dpms 300 600 900
xset s 900
```

Turns off display after 900 seconds.[1]

### Best Practices

**Profile First**: Identify actual bottlenecks.[1]

**Incremental Changes**: Modify one thing at a time.[1]

**Test Functionality**: Ensure system still usable.[1]

**Document Changes**: Record optimizations.[1]

**Monitor Performance**: Watch for regressions.[1]

**Lightweight Alternatives**: Choose simpler software.[1]

**Disable by Default**: Only enable when needed.[1]

**Balance Usability**: Don't sacrifice too much functionality.[1]

### Performance Targets

**Excellent Boot**: < 10 seconds.[1]

**Good Responsiveness**: Sub-second application launch.[1]

**Memory Footprint**: < 500MB idle.[1]

**CPU Usage**: < 5% at rest.[1]

Achievable on older hardware with optimization.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

