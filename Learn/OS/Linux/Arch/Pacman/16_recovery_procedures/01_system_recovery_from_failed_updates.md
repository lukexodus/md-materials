## System Recovery from Failed Updates


### Overview

Failed updates can leave Arch Linux systems in various states of dysfunction, from minor package issues to complete boot failures. Systematic recovery procedures restore functionality while preserving data and system configuration.

### Assessment and Triage

#### Determine System State

**System boots normally:**
- Minor issues, easiest to fix
- Full pacman access available
- Recovery from running system

**System boots to terminal (no GUI):**
- Display manager or desktop environment broken
- Can use command line
- Most tools available

**System boots to emergency/rescue mode:**
- Critical system components damaged
- Limited functionality
- May need chroot recovery

**System doesn't boot:**
- Most severe situation
- Requires live USB recovery
- Full chroot procedure needed

### Recovery from Running System

#### Step 1: Gather Information

**Check pacman log for what failed:**
```
tail -n 100 /var/log/pacman.log
grep "error:" /var/log/pacman.log | tail -20
grep "warning:" /var/log/pacman.log | tail -20
```

**Check system journal:**
```
journalctl -b -p err
journalctl -xb | grep -i error
```

**Identify last successful operation:**
```
grep "starting full system upgrade" /var/log/pacman.log | tail -1
grep "transaction completed" /var/log/pacman.log | tail -1
```

#### Step 2: Remove Lock File

If update was interrupted:
```
sudo rm /var/lib/pacman/db.lck
```

Only after verifying no pacman process is running:
```
ps aux | grep pacman
```

#### Step 3: Clean Corrupted Cache

Remove potentially corrupted downloads:
```
sudo pacman -Scc
```

Confirm removal of all cached packages, forcing fresh downloads.

#### Step 4: Refresh Databases

Force complete database refresh:
```
sudo pacman -Syy
```

#### Step 5: Update Keyring

Outdated keys often cause failures:
```
sudo pacman -Sy archlinux-keyring
sudo pacman-key --populate archlinux
```

#### Step 6: Complete the Update

Attempt to finish the upgrade:
```
sudo pacman -Syu
```

Watch for errors and address them as they appear.

#### Step 7: Fix Broken Packages

**Reinstall packages with errors:**
```
sudo pacman -S package-name --overwrite '*'
```

**Check for broken dependencies:**
```
sudo pacman -Dk
```

**Verify file integrity:**
```
pacman -Qkk | grep -v "0 altered files"
```

### Recovery from Terminal-Only Boot

#### Display Manager Won't Start

**Common symptoms:**
- System boots to TTY login
- startx or display manager fails
- GUI completely unavailable

**Diagnosis:**
```
sudo systemctl status display-manager
journalctl -u display-manager -b
```

**Solutions:**

**1. Reinstall display manager:**
```
sudo pacman -S gdm  # or sddm, lightdm, etc.
```

**2. Reinstall graphics drivers:**
```
# For NVIDIA
sudo pacman -S nvidia nvidia-utils

# For AMD
sudo pacman -S xf86-video-amdgpu

# For Intel
sudo pacman -S xf86-video-intel
```

**3. Reinstall Xorg:**
```
sudo pacman -S xorg-server xorg-xinit
```

**4. Rebuild initramfs:**
```
sudo mkinitcpio -P
```

**5. Reboot:**
```
sudo reboot
```

#### Desktop Environment Broken

**KDE Plasma:**
```
sudo pacman -S plasma-meta kde-applications-meta
```

**GNOME:**
```
sudo pacman -S gnome gnome-extra
```

**Xfce:**
```
sudo pacman -S xfce4 xfce4-goodies
```

### Recovery from Emergency/Rescue Mode

#### Boot Options

**Access GRUB menu:**
Press `e` at GRUB to edit boot parameters.

**Add to kernel line:**
```
systemd.unit=rescue.target
```

Or:
```
systemd.unit=emergency.target
```

**Boot in single-user mode:**
```
single
```

Or:
```
init=/bin/bash
```

#### Remount Root Filesystem

Emergency mode often mounts root read-only:
```
mount -o remount,rw /
```

#### Basic Recovery Steps

**1. Remove lock file:**
```
rm /var/lib/pacman/db.lck
```

**2. Check network connectivity:**
```
ping -c 3 archlinux.org
```

If network is down:
```
systemctl start NetworkManager
# or
dhcpcd
```

**3. Attempt update:**
```
pacman -Syu
```

**4. Fix critical packages:**
```
pacman -S systemd glibc bash coreutils
```

**5. Reboot:**
```
systemctl reboot
```

### Recovery Using Live USB

#### Preparation

**Boot from Arch installation media:**
- Create bootable USB with latest Arch ISO
- Boot system from USB
- Wait for live environment prompt

#### Mount System Partitions

**Identify partitions:**
```
lsblk
fdisk -l
```

**Mount root partition:**
```
mount /dev/sdXn /mnt
```

**Mount boot partition (if separate):**
```
mount /dev/sdXn /mnt/boot
```

**Mount EFI partition (if UEFI):**
```
mount /dev/sdXn /mnt/boot/efi
```

**Mount other partitions:**
```
mount /dev/sdXn /mnt/home
```

#### Chroot into System

**Mount virtual filesystems:**
```
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /run /mnt/run
```

**Or use arch-chroot (easier):**
```
arch-chroot /mnt
```

This automatically handles all virtual filesystem mounts.

#### Recovery Operations in Chroot

**1. Remove lock file:**
```
rm /var/lib/pacman/db.lck
```

**2. Configure network (if needed):**
```
# Copy DNS settings from live environment
cp /etc/resolv.conf /mnt/etc/resolv.conf
```

**3. Refresh databases:**
```
pacman -Syy
```

**4. Update keyring:**
```
pacman -S archlinux-keyring
```

**5. Complete update:**
```
pacman -Syu
```

**6. Reinstall critical packages:**
```
pacman -S linux linux-headers base base-devel
```

**7. Rebuild initramfs:**
```
mkinitcpio -P
```

**8. Reinstall bootloader:**

**For GRUB:**
```
grub-install /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg
```

**For systemd-boot:**
```
bootctl install
bootctl update
```

**9. Exit and reboot:**
```
exit
umount -R /mnt
reboot
```

### Specific Recovery Scenarios

#### Kernel Update Failed

**Symptoms:**
- System won't boot
- Kernel panic
- Missing kernel modules

**Recovery:**

**1. Boot from live USB and chroot**

**2. Reinstall kernel:**
```
pacman -S linux linux-headers
```

**Or install LTS kernel for stability:**
```
pacman -S linux-lts linux-lts-headers
```

**3. Rebuild initramfs:**
```
mkinitcpio -P
```

**4. Update bootloader:**
```
grub-mkconfig -o /boot/grub/grub.cfg
```

**5. Reboot**

#### Bootloader Broken

**GRUB not found or errors:**

**Recovery:**
```
# From chroot
pacman -S grub
grub-install /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg
```

**systemd-boot missing:**
```
# From chroot
bootctl install
mkdir -p /boot/loader/entries
# Recreate boot entries
```

#### Critical System Libraries Broken

**glibc, systemd, or bash corrupted:**

**Recovery:**
```
# From chroot or using pacman-static
pacman -S glibc systemd bash coreutils --overwrite '*'
```

#### Database Completely Corrupted

**Extreme case - rebuild entire database:**

**1. List installed packages from log:**
```
grep "installed" /var/log/pacman.log | awk '{print $4}' | sort -u > /tmp/installed.txt
```

**2. Reinstall all packages:**
```
pacman -S $(cat /tmp/installed.txt) --overwrite '*'
```

**Warning:** This is time-consuming and a last resort.

### Rollback Strategies

#### Downgrade to Previous Versions

**From cache:**
```
cd /var/cache/pacman/pkg/
sudo pacman -U package-name-old-version.pkg.tar.zst
```

**Downgrade multiple packages:**
```
sudo pacman -U /var/cache/pacman/pkg/package1-old.pkg.tar.zst \
               /var/cache/pacman/pkg/package2-old.pkg.tar.zst
```

**From Arch Archive:**
```
# Visit https://archive.archlinux.org/
wget https://archive.archlinux.org/packages/p/package-name/package-name-version.pkg.tar.zst
sudo pacman -U package-name-version.pkg.tar.zst
```

**Hold packages to prevent re-upgrade:**
```
# Add to /etc/pacman.conf
IgnorePkg = package-name package-name2
```

#### Snapshot Rollback

**Using Btrfs snapshots:**
```
# Boot from live USB
mount /dev/sdXn /mnt
btrfs subvolume list /mnt
btrfs subvolume delete /mnt/@
btrfs subvolume snapshot /mnt/@snapshots/snapshot-name /mnt/@
reboot
```

**Using Timeshift:**
```
# Boot from live USB
timeshift --restore
# Follow prompts to select snapshot
```

**Using LVM snapshots:**
```
# From live USB
lvconvert --merge /dev/vg/snapshot
reboot
```

### Preventive Measures

#### Pre-Update Preparations

**1. Read Arch news:**
```
https://archlinux.org/news/
```

Check for manual intervention requirements.

**2. Create snapshot:**
```
sudo timeshift --create --comments "Before $(date +%Y%m%d) update"
```

Or Btrfs:
```
sudo btrfs subvolume snapshot / /.snapshots/$(date +%Y%m%d)-pre-update
```

**3. Backup critical **
```
sudo rsync -av /etc /backup/etc-$(date +%Y%m%d)
sudo rsync -av /home /backup/home-$(date +%Y%m%d)
```

**4. Ensure adequate disk space:**
```
df -h /
```

Keep at least 20% free.

**5. Update keyring first:**
```
sudo pacman -Sy archlinux-keyring
```

#### Safe Update Practices

**Full system updates only:**
```
sudo pacman -Syu  # Good
```

**Never partial upgrades:**
```
sudo pacman -Sy package-name  # Bad - causes breakage
```

**Monitor update process:**
- Watch for warnings
- Note which packages are updating
- Don't interrupt critical operations

**Test after updates:**
```
# Verify boot
sudo journalctl -b -p err

# Check services
systemctl --failed

# Test critical applications
```

### Recovery Toolkit

#### Essential Tools to Keep Available

**Live USB with latest Arch ISO:**
- Keep updated monthly
- Test that it boots

**Package cache:**
- Don't delete with `pacman -Scc` too frequently
- Keep at least 2-3 versions with `paccache -rk3`

**Documentation:**
- Save this guide offline
- Keep Arch Wiki pages saved

**External backups:**
- Regular system snapshots
- Critical data backups

### Best Practices

**Update regularly:** Small frequent updates are safer than large infrequent ones.

**Read before updating:** Check Arch news for manual interventions.

**Create snapshots:** Snapshot before every major update.

**Keep rescue tools ready:** Bootable USB and recovery knowledge.

**Document your system:** Know what's installed and why.

**Test in stages:** Update non-critical systems first.

**Maintain backups:** Regular backups of critical data and configs.

**Don't panic:** Systematic recovery usually succeeds.

**Learn from failures:** Understand what went wrong to prevent recurrence.

**Ask for help:** Arch forums and IRC are helpful when stuck.

System recovery from failed updates is usually successful with methodical troubleshooting and the right recovery tools. Preparation and prevention are the best strategies.

