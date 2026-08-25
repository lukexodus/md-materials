## Kernel Rollbacks and Downgrade Strategies


### Kernel Update Issues

**Symptoms Requiring Rollback**:[1][2][3]
- Kernel panic on boot[1]
- Hardware incompatibility[1]
- Performance degradation[1]
- Feature regression[1]
- System instability[1]

**Occurrence**: Rare but possible with rolling release.[1]

**Prevention**: Test updates carefully; maintain backups.[1]

### Understanding Kernel Versions

#### Version Numbering

**Format**: `kernel-version-release`.[3]

**Example**: `6.8.5-arch1-1`:[3]
- `6.8.5`: Upstream kernel version[3]
- `arch1`: Arch patchset number[3]
- `1`: Arch package release[3]

**Current Kernel**: `uname -r` displays running version.[3]

**Installed Kernel**: `pacman -Q linux` shows installed version.[3]

### Kernel Cache and Availability

#### Package Cache Storage

**Location**: `/var/cache/pacman/pkg/`.[2][1]

**Cached Versions**: Old kernel packages typically available.[1]

**Naming**: `linux-kernel_version-arch.pkg.tar.zst`.[2]

**Example Files**:[2]

```
linux-6.8.5-arch1-1-x86_64.pkg.tar.zst
linux-6.8.4-arch1-1-x86_64.pkg.tar.zst
linux-6.8.3-arch1-1-x86_64.pkg.tar.zst
```

#### Checking Available Versions

**List Cached**:[2][1]

```bash
ls -lh /var/cache/pacman/pkg/linux-*.pkg.tar.zst
```

**Sort by Date**:[1]

```bash
ls -lt /var/cache/pacman/pkg/linux-*.pkg.tar.zst
```

### Downgrading via Cache

#### Identify Target Version

**Review Cached Versions**:[2][1]

```bash
ls -lh /var/cache/pacman/pkg/linux-*.pkg.tar.zst | head -10
```

**Selection Criteria**:[1]
- Most recent stable version before problem[1]
- Known working version[1]
- Sufficient time since release[1]

#### Downgrade Process

**Boot to Fallback**: If current kernel doesn't boot:[4]
1. Select fallback initramfs in bootloader[4]
2. System boots with all modules[4]
3. Proceed with downgrade[1]

**Downgrade Command**:[2][1]

```bash
sudo pacman -U /var/cache/pacman/pkg/linux-6.8.4-arch1-1-x86_64.pkg.tar.zst
```

**Regenerate Initramfs**: After downgrade:[2][1]

```bash
sudo mkinitcpio -P
```

**Reboot**: Test new kernel:[2]

```bash
sudo reboot
```

#### Related Package Downgrades

**Headers Downgrade**: Linux-headers must match kernel version:[1]

```bash
sudo pacman -U /var/cache/pacman/pkg/linux-headers-6.8.4-arch1-1-x86_64.pkg.tar.zst
```

**Firmware Update**: Typically not affected.[1]

**Microcode Update**: Keep current for security.[1]

### Using downgrade Tool

#### Installation

**Install from AUR**:[3][1]

```bash
yay -S downgrade
```

**Alternative**: Manual installation:[1]

```bash
git clone https://aur.archlinux.org/downgrade.git
cd downgrade
makepkg -si
```

#### Interactive Downgrade

**Simple Usage**:[3][1]

```bash
sudo downgrade linux
```

**Interactive Menu**:[1]
1. Lists available versions[1]
2. User selects version[1]
3. Automatically downloads and installs[1]

**Example Selection**:[1]

```
Select a package by entering its number
1) linux-6.8.5-arch1-1 (current)
2) linux-6.8.4-arch1-1
3) linux-6.8.3-arch1-1
4) linux-6.8.2-arch1-1
Enter selection:
```

#### Arch Archive Source

**Automatic Download**: If not in local cache:[1]

```bash
downgrade linux
```

**Downloads From**: archive.archlinux.org.[1]

**Internet Required**: Fetches older packages from archive.[1]

### Preventing Future Issues

#### Pre-Update Backup

**Current Kernel Backup**:[1]

```bash
cp /boot/vmlinuz-linux /boot/vmlinuz-linux.bak
cp /boot/initramfs-linux.img /boot/initramfs-linux.img.bak
```

**Boot Entry Backup**: Create fallback boot entry:[1]

```
title Arch Linux (Backup)
linux /vmlinuz-linux.bak
initrd /initramfs-linux.img.bak
options root=PARTUUID=... rw
```

#### Staging Updates

**Test in Virtual Machine**:[1]
1. Create VM snapshot[1]
2. Install update[1]
3. Verify stability[1]
4. Apply to production[1]

**Update Groups**: Install kernel updates separately from other packages:[1]

```bash
sudo pacman -Syu --ignore=linux,linux-headers
# Verify system stable
sudo pacman -S linux linux-headers
sudo reboot
```

### Multiple Kernel Installation

#### Parallel Kernels

**Install Alternative**: Keep multiple kernels:[5][1]

```bash
sudo pacman -S linux-lts
```

**Boot Menu**: Both kernels appear in bootloader.[1]

**Easy Switching**: Select kernel at boot time.[1]

**Advantages**:[5][1]
- Quick fallback if main kernel fails[1]
- Test new kernels safely[1]
- No downgrade necessary[1]

#### LTS Kernel Strategy

**Long-Term Support**: Stable, conservative updates.[1]

**Installation**:[5][1]

```bash
sudo pacman -S linux-lts linux-lts-headers
```

**Boot Entry**: Create `/boot/loader/entries/arch-lts.conf`:[1]

```
title Arch Linux LTS
linux /vmlinuz-linux-lts
initrd /initramfs-linux-lts.img
options root=PARTUUID=... rw
```

**Cross-Upgrade**: Switch between kernels:[5]

```bash
# Remove main kernel, keep LTS
sudo pacman -R linux linux-headers
```

### Kernel-Related Downgrades

#### linux-firmware Compatibility

**Usually Independent**: Firmware typically backwards compatible.[1]

**Version Matching**: For specific hardware:[1]

```bash
sudo pacman -U /var/cache/pacman/pkg/linux-firmware-VERSION.pkg.tar.zst
```

**Not Recommended**: Unless specific hardware issue.[1]

#### Graphics Driver Considerations

**NVIDIA Drivers**: May need matching kernel version:[1]

```bash
pacman -Qi nvidia
```

**Mesa**: Generally compatible across kernel versions.[1]

**Fallback Graphics**: Use VESA drivers if graphical issues.[1]

### Emergency Boot Recovery

#### Boot Failures

**Symptoms**: Kernel panic, unable to boot.[2][1]

**Recovery Steps**:[1]
1. Boot fallback initramfs[4]
2. Verify filesystem integrity[1]
3. Downgrade kernel if needed[2]
4. Reboot[1]

**Fallback Boot**: Boot menu selection:[4]
- Select "Arch Linux (Fallback Initramfs)"[4]
- System boots with all modules loaded[4]

#### chroot Repair

**If Fallback Unavailable**: Boot from live USB:[1]

```bash
# From live environment
sudo mount /dev/sdX# /mnt
sudo arch-chroot /mnt
pacman -U /var/cache/pacman/pkg/linux-oldversion.pkg.tar.zst
mkinitcpio -P
exit
sudo umount -R /mnt
reboot
```

### Kernel Configuration Recovery

#### Kernel cmdline Issues

**Bootloader Modification**: Fallback if kernel parameters wrong.[1]

**Systemd-boot Editing**:[1]
1. At boot menu, press `e` to edit[1]
2. Modify kernel parameters[1]
3. Press Ctrl+X to boot[1]

**Example Fixes**:[1]
- Add `nomodeset` for graphics issues[1]
- Add `acpi=off` for ACPI problems[1]
- Add `mem=512M` to limit memory[1]

#### Persistent Parameter Fix

**systemd-boot Edit**:[1]

```bash
sudo nano /boot/loader/entries/arch.conf
# Modify options line
```

**GRUB Edit**:[1]

```bash
sudo nano /etc/default/grub
# Modify GRUB_CMDLINE_LINUX
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Kernel Module Issues

#### Module Loading Problems

**Symptom**: Hardware not recognized.[1]

**Check Loaded Modules**:[1]

```bash
lsmod | grep module_name
```

**Load Missing Module**:[1]

```bash
sudo modprobe module_name
```

**Permanent Loading**:[1]

Create `/etc/modprobe.d/load.conf`:

```
install module_name /sbin/modprobe --ignore-install module_name
```

### Performance and Stability Trade-offs

#### Performance vs Stability

**Latest Kernel**: Maximum features, potential issues.[1]

**LTS Kernel**: Conservative updates, proven stability.[1]

**Hybrid Approach**:[1]
- Use LTS for production systems[1]
- Test latest on secondary machine[1]
- Switch when latest proven stable[1]

#### Custom Kernel Compilation

**Advanced Option**: Compile with specific optimizations.[1]

**AUR Packages**: Pre-configured alternatives:[1]

```bash
yay -S linux-zen  # Community kernel
yay -S linux-hardened  # Security-focused
```

### Best Practices

**Monitor Stability**: Test after kernel updates.[1]

**Keep Cache**: Maintain package cache for quick rollback.[2][1]

**Multiple Kernels**: Install alternative kernel as backup.[1]

**Document Issues**: Record when problems occur.[1]

**Test Thoroughly**: Verify fixes before permanent commitment.[1]

**Backup Bootloader Config**: Save working configurations.[1]

**Read Arch News**: Check for kernel-related announcements.[1]

**Report Issues**: File bugs if problems with latest kernel.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Kernel or mkinitcpio update: do i have to reboot? ... https://bbs.archlinux.org/viewtopic.php?id=295811
[3] Upgrade Kernel on Arch Linux https://linuxhint.com/upgrade-kernel-on-arch-linux/
[4] mkinitcpio - ArchWiki https://wiki.archlinux.org/title/Mkinitcpio
[5] pacstrap linux-lts without ever installing 'linux' package ... https://bbs.archlinux.org/viewtopic.php?id=170660

