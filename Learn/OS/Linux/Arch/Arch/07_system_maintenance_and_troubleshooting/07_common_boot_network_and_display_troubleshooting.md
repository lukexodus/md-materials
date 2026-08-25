## Common Boot, Network, and Display Troubleshooting


### Boot Issues Overview

**Symptoms**:[1][2]
- System halts at boot[1]
- Kernel panic[1]
- Bootloader not loading[1]
- Filesystem errors[1]

**Diagnosis**: Check logs and boot messages for clues.[2][1]

### Boot Failure Diagnosis

#### No Output at All

**Possible Causes**:[2][1]
- Hardware failure[1]
- BIOS/UEFI misconfiguration[1]
- Power supply issue[1]

**Diagnosis Steps**:[1]
1. Check power supply and connections[1]
2. Verify UEFI/BIOS settings[1]
3. Test with different boot device[1]

#### Bootloader Not Loading

**GRUB Fails**:[3]

```
GRUB Error: No such partition
```

**Solutions**:[3]
1. Boot from live USB[3]
2. Reinstall GRUB:[3]

```bash
sudo arch-chroot /mnt
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
```

**Systemd-boot Fails**:[2]

Reinstall bootloader:

```bash
sudo arch-chroot /mnt
bootctl install
bootctl status
```

#### Kernel Panic

**Message**:[1]

```
Kernel panic - not syncing: ...
```

**Resolution**:[1]
1. Boot fallback initramfs[4]
2. Downgrade kernel if needed[5]
3. Check hardware compatibility[1]

**Boot Parameters**: Add `break=postmount` to investigate:[4]

```
options root=... break=postmount
```

#### Filesystem Errors

**Message**:[1]

```
fsck error: ...
Unable to mount root filesystem
```

**Recovery Steps**:[1]
1. Boot from live USB[1]
2. Check filesystem:[1]

```bash
sudo fsck /dev/sdX# -y
```

3. Repair if needed[1]
4. Reboot[1]

### Emergency Boot Recovery

#### Fallback Initramfs Boot

**Purpose**: Boot with all modules loaded.[4]

**At Boot Menu**:[4]
1. Press arrow keys to select fallback entry[4]
2. Press Enter[4]
3. System boots with complete module set[4]

**After Booting**:[4]
1. Fix underlying issue[1]
2. Regenerate initramfs if needed[4]
3. Reboot normally[4]

#### Single-User Mode

**Kernel Parameter**: Add `break=postmount`:[4]

```
options root=PARTUUID=... break=postmount
```

**Emergency Shell**:[4]
1. Obtain root shell prompt[4]
2. Mount filesystems manually[4]
3. Diagnose and fix issues[4]
4. Type `exit` to continue boot[4]

### Network Issues

#### No Network Connectivity

**Check Interface**:[6][1]

```bash
ip link show
```

**Expected Output**: Interface listed and UP:[6]

```
wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
```

**Enable Interface**:[6]

```bash
sudo ip link set wlan0 up
```

#### Wireless Connection Problems

**Scan Networks**:[6]

```bash
iwctl station wlan0 get-networks
```

**Connect to Network**:[6][1]

```bash
iwctl station wlan0 connect SSID
# Enter password if prompted
```

**Verify Connection**:[6]

```bash
ip addr show wlan0
ping archlinux.org
```

#### DHCP Issues

**Check DHCP**: `dhcpcd` service:[6]

```bash
sudo systemctl status dhcpcd@wlan0
```

**Manually Request IP**:[6]

```bash
sudo dhcpcd wlan0
```

**Static IP Configuration**:[6]

```bash
sudo ip addr add 192.168.1.100/24 dev wlan0
sudo ip route add default via 192.168.1.1
```

#### DNS Resolution Failures

**Test DNS**:[6][1]

```bash
nslookup archlinux.org
```

**Check Resolver**:[1]

```bash
cat /etc/resolv.conf
```

**Configure DNS**:[1]

Edit `/etc/systemd/resolved.conf`:

```
[Resolve]
DNS=1.1.1.1 8.8.8.8
FallbackDNS=9.9.9.9
```

**Restart Service**:[1]

```bash
sudo systemctl restart systemd-resolved
```

#### Network Manager Issues

**Check Status**:[1]

```bash
nmcli device status
nmcli connection show
```

**Reconnect**:[1]

```bash
nmcli connection up connection_name
```

**Troubleshoot**:[1]

```bash
journalctl -u NetworkManager -f
```

### Display and Graphics Issues

#### No Display Output

**Possible Causes**:[1]
- Graphics driver not loaded[1]
- Display output wrong[1]
- Graphics mode unsupported[1]

**Boot with Fallback**:[4]
1. Select fallback initramfs[4]
2. System loads with all modules[4]
3. Try again[1]

**Add Kernel Parameter**:[1]

```
options root=... nomodeset
```

This disables KMS (Kernel Mode Setting).[1]

#### Resolution Issues

**Check Current Resolution**:[1]

```bash
xrandr
```

**Available Resolutions**:[1]

```bash
xrandr --listmonitors
```

**Set Resolution**:[1]

```bash
xrandr --output HDMI-1 --mode 1920x1080
```

#### Corruption and Artifacts

**Update Drivers**:[1]

```bash
sudo pacman -Syu
```

**NVIDIA Issues**:[1]

```bash
sudo pacman -S nvidia
sudo systemctl restart nvidia-persistenced
```

**AMD/Intel Issues**:[1]

```bash
sudo pacman -S mesa
```

**Reboot After Driver Update**:[1]

```bash
sudo reboot
```

#### Multiple Monitor Setup

**List Monitors**:[1]

```bash
xrandr
```

**Configure Multiple**:[1]

```bash
xrandr --output HDMI-1 --mode 1920x1080 --pos 0x0 \
       --output HDMI-2 --mode 1920x1080 --pos 1920x0
```

**Persistent Configuration**: Store in `~/.xinitrc` or display manager config.[1]

### Audio Issues

#### No Sound Output

**Check Audio Devices**:[1]

```bash
aplay -l
```

**Check Volume**:[1]

```bash
amixer
```

**Unmute Output**:[1]

```bash
amixer set Master unmute
amixer set PCM unmute
```

**Increase Volume**:[1]

```bash
amixer set Master 100%
```

#### PulseAudio Issues

**Check Status**:[1]

```bash
systemctl --user status pulseaudio
```

**Restart Service**:[1]

```bash
systemctl --user restart pulseaudio
```

**Check Connections**:[1]

```bash
pactl list
```

### Troubleshooting Workflows

#### Boot Hangs at Specific Point

**Add Debug Parameter**:[1]

```
options root=... debug
```

**Check Logs**:[1]

```bash
journalctl -b -1 | tail -50
```

**Identify Hanging Service**:[1]

```bash
systemctl list-units --state=failed
```

**Disable Service Temporarily**:[1]

```bash
sudo systemctl mask problematic.service
sudo reboot
```

#### Intermittent Crashes

**Enable Coredumps**:[1]

```bash
sudo coredumpctl
coredumpctl info
```

**Review Latest Crash**:[1]

```bash
journalctl -b -1 -p crit
```

**Hardware Test**: Run memtest86 for memory issues.[1]

#### Performance Degradation

**Check System Load**:[1]

```bash
top
htop
```

**Monitor Processes**:[1]

```bash
systemd-cgtop
```

**Check Disk Usage**:[1]

```bash
df -h
du -sh /var/cache/pacman/pkg/
```

**Identify Resource Hogs**:[1]

```bash
journalctl --disk-usage
```

### Recovery Commands Reference

#### From Live Environment

**Mount Filesystems**:[1]

```bash
sudo mount /dev/sdX# /mnt
sudo mount /dev/sdX# /mnt/boot
sudo arch-chroot /mnt
```

**Regenerate Initramfs**:[1]

```bash
mkinitcpio -P
```

**Reinstall Bootloader**:[1]

```bash
# Systemd-boot
bootctl install

# GRUB
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
```

**Check Logs**:[1]

```bash
journalctl -b -1 | grep -i error
```

### Prevention Strategies

**Regular Backups**: Maintain current system backups.[1]

**Test Updates**: Verify kernel updates in VM first.[1]

**Monitor Logs**: Check logs regularly for warnings.[1]

**Update Frequently**: Weekly or biweekly updates prevent large gaps.[1]

**Document System**: Keep notes of custom configurations.[1]

**Keep Live Media**: Always have Arch ISO available.[1]

**Parallel Kernel**: Install LTS kernel as fallback.[1]

### Best Practices

**Read Error Messages**: Carefully examine all error output.[1]

**Check Logs First**: Review journal before making changes.[1]

**Test in VM**: Reproduce issues in virtual machine.[1]

**Gradual Troubleshooting**: Try simplest solutions first.[1]

**Document Process**: Record steps for future reference.[1]

**Ask for Help**: Consult Arch forums with detailed logs.[1]

**Verify Fixes**: Confirm issue resolved completely.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] System time - ArchWiki https://wiki.archlinux.org/title/System_time
[3] GRUB - ArchWiki https://wiki.archlinux.org/title/GRUB
[4] mkinitcpio - ArchWiki https://wiki.archlinux.org/title/Mkinitcpio
[5] Kernel or mkinitcpio update: do i have to reboot? ... https://bbs.archlinux.org/viewtopic.php?id=295811
[6] Network configuration - ArchWiki https://wiki.archlinux.org/title/Network_configuration

