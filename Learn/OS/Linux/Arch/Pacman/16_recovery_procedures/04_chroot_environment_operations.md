## Chroot Environment Operations


### Overview

A chroot (change root) environment allows you to work on an Arch Linux installation from outside the installed system, typically from a live USB. This is essential for system recovery, rescue operations, and advanced maintenance when the system won't boot normally.

### Understanding Chroot

#### What is Chroot?

**Change Root:** Temporarily makes a directory the root filesystem for the current process and its children.

**Use cases:**
- System recovery when system won't boot
- Reinstalling bootloader
- Fixing broken packages
- Completing failed updates
- Repairing corrupted system files

**Limitations:**
- Requires live environment to run from
- Only affects the chrooted process tree
- Virtual filesystems must be manually mounted

### Preparation: Booting Live Environment

#### Boot from Arch Installation Media

**Create bootable USB:**
```
dd if=archlinux.iso of=/dev/sdX bs=4M status=progress
```

**Boot options:**
- Select USB in BIOS/UEFI boot menu
- Wait for live environment prompt
- You'll see a root prompt on the live system

#### Verify Live Environment

```
# Check you're in live environment
uname -a  # Shows Linux kernel
lsblk     # Lists block devices
```

### Mounting the System

#### Identify Partitions

**List all partitions:**
```
lsblk
fdisk -l
```

**Example output:**
```
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0 238.5G  0 disk 
├─sda1   8:1    0   512M  0 part     # EFI partition
├─sda2   8:2    0    20G  0 part     # Root partition
└─sda3   8:3    0   218G  0 part     # Home partition
```

#### Mount Root Filesystem

**Mount root partition:**
```
mount /dev/sda2 /mnt
```

Replace `/dev/sda2` with your actual root partition.

**Verify mount:**
```
ls /mnt
```

Should show root filesystem contents (`bin`, `etc`, `home`, `usr`, etc.).

#### Mount Boot Partition (if separate)

**For separate /boot partition:**
```
mount /dev/sda1 /mnt/boot
```

**For UEFI systems with separate EFI partition:**
```
mount /dev/sda1 /mnt/boot/efi
```

Or wherever your EFI partition is mounted.

#### Mount Other Partitions

**Mount /home if separate:**
```
mount /dev/sda3 /mnt/home
```

**Mount swap (if needed for some operations):**
```
swapon /dev/sdaX
```

### Entering Chroot with arch-chroot

#### Using arch-chroot (Recommended)

**Enter chroot environment:**
```
arch-chroot /mnt
```

`arch-chroot` automatically handles mounting required virtual filesystems.

**What arch-chroot does:**
- Mounts `/dev`, `/dev/pts`, `/proc`, `/sys`, `/run`
- Changes root to specified directory
- Executes shell in chroot environment
- Configures environment properly

**You're now in the chroot:**
```
# Prompt changes to indicate chroot
[root@archiso /]#
```

Commands now operate on the mounted system, not the live environment.

### Manual Chroot (Alternative Method)

#### Mount Virtual Filesystems Manually

If `arch-chroot` isn't available:

```
# Mount virtual filesystems
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
mount -t proc /proc /mnt/proc
mount -t sysfs /sys /mnt/sys
mount -t tmpfs /run /mnt/run
```

**For UEFI systems, also mount:**
```
mount -t efivarfs efivarfs /mnt/sys/firmware/efi/efivars
```

#### Enter Chroot

```
chroot /mnt /bin/bash
```

Or:
```
chroot /mnt
```

**Setup environment:**
```
source /etc/profile
export PS1="(chroot) $PS1"
```

### Essential Operations in Chroot

#### Network Configuration

**Copy DNS configuration from live environment:**
```
cp /etc/resolv.conf /mnt/etc/resolv.conf
```

**Or edit manually in chroot:**
```
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

**Test connectivity:**
```
ping -c 3 archlinux.org
```

**If network isn't working:**
```
# Exit chroot temporarily
exit

# Setup network in live environment
dhcpcd

# Re-enter chroot
arch-chroot /mnt
```

#### Package Operations

**Remove lock file:**
```
rm /var/lib/pacman/db.lck
```

**Refresh databases:**
```
pacman -Syy
```

**Update system:**
```
pacman -Syu
```

**Reinstall packages:**
```
pacman -S package-name --overwrite '*'
```

**Complete failed updates:**
```
pacman -Su
```

#### Kernel Operations

**Reinstall kernel:**
```
pacman -S linux linux-headers
```

**Install LTS kernel:**
```
pacman -S linux-lts linux-lts-headers
```

**Rebuild initramfs:**
```
mkinitcpio -P
```

Or for specific preset:
```
mkinitcpio -p linux
```

#### Bootloader Operations

**GRUB reinstallation:**
```
# Install GRUB package
pacman -S grub

# For BIOS systems
grub-install /dev/sda

# For UEFI systems
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Generate configuration
grub-mkconfig -o /boot/grub/grub.cfg
```

**systemd-boot reinstallation:**
```
bootctl install
bootctl update

# Verify entries
bootctl list
```

**rEFInd reinstallation:**
```
pacman -S refind
refind-install
```

### Common Recovery Scenarios

#### Scenario 1: Failed System Update

**Problem:** Update interrupted, system won't boot.

**Chroot procedure:**
```
# Mount and chroot
mount /dev/sda2 /mnt
mount /dev/sda1 /mnt/boot
arch-chroot /mnt

# Complete update
rm /var/lib/pacman/db.lck
pacman -Syu

# Verify critical packages
pacman -S linux systemd

# Rebuild initramfs
mkinitcpio -P

# Update bootloader
grub-mkconfig -o /boot/grub/grub.cfg

# Exit and reboot
exit
umount -R /mnt
reboot
```

#### Scenario 2: Broken Bootloader

**Problem:** Bootloader corrupted, system won't start.

**Chroot procedure:**
```
# Mount and chroot
mount /dev/sda2 /mnt
mount /dev/sda1 /mnt/boot/efi  # For UEFI
arch-chroot /mnt

# Reinstall GRUB
pacman -S grub efibootmgr  # For UEFI
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Exit and reboot
exit
umount -R /mnt
reboot
```

#### Scenario 3: Corrupted System Files

**Problem:** Critical system files corrupted.

**Chroot procedure:**
```
# Mount and chroot
mount /dev/sda2 /mnt
arch-chroot /mnt

# Reinstall base system
pacman -S base base-devel --overwrite '*'

# Reinstall critical packages
pacman -S linux systemd glibc bash coreutils --overwrite '*'

# Verify integrity
pacman -Qkk | grep -v "0 altered files"

# Exit and reboot
exit
umount -R /mnt
reboot
```

#### Scenario 4: Forgotten Root Password

**Problem:** Can't log in, forgot root password.

**Chroot procedure:**
```
# Mount and chroot
mount /dev/sda2 /mnt
arch-chroot /mnt

# Change root password
passwd

# Create/reset user password
passwd username

# Exit and reboot
exit
umount -R /mnt
reboot
```

#### Scenario 5: Kernel Won't Boot

**Problem:** New kernel causes boot failure.

**Chroot procedure:**
```
# Mount and chroot
mount /dev/sda2 /mnt
mount /dev/sda1 /mnt/boot
arch-chroot /mnt

# Downgrade kernel from cache
pacman -U /var/cache/pacman/pkg/linux-old-version.pkg.tar.zst

# Or install LTS kernel
pacman -S linux-lts linux-lts-headers

# Rebuild initramfs
mkinitcpio -P

# Update bootloader
grub-mkconfig -o /boot/grub/grub.cfg

# Exit and reboot
exit
umount -R /mnt
reboot
```

### Advanced Chroot Operations

#### Working with Encrypted Systems

**For LUKS encryption:**
```
# Open encrypted partition
cryptsetup open /dev/sda2 cryptroot

# Mount decrypted partition
mount /dev/mapper/cryptroot /mnt

# Mount boot
mount /dev/sda1 /mnt/boot

# Chroot
arch-chroot /mnt
```

#### Working with LVM

**For LVM systems:**
```
# Activate volume groups
vgchange -ay

# List volumes
lvs

# Mount logical volumes
mount /dev/volumegroup/root /mnt
mount /dev/volumegroup/home /mnt/home
mount /dev/sda1 /mnt/boot

# Chroot
arch-chroot /mnt
```

#### Working with Btrfs Subvolumes

**For Btrfs with subvolumes:**
```
# Mount root subvolume
mount -o subvol=@ /dev/sda2 /mnt

# Mount other subvolumes
mount -o subvol=@home /dev/sda2 /mnt/home
mount -o subvol=@snapshots /dev/sda2 /mnt/.snapshots

# Mount boot
mount /dev/sda1 /mnt/boot

# Chroot
arch-chroot /mnt
```

### Exiting Chroot

#### Proper Exit Procedure

**Exit chroot shell:**
```
exit
```

**Unmount all filesystems:**
```
umount -R /mnt
```

The `-R` flag recursively unmounts all mounted filesystems under `/mnt`.

**Reboot:**
```
reboot
```

**Or shutdown:**
```
poweroff
```

#### Force Unmount (if needed)

**If unmount fails:**
```
umount -l /mnt  # Lazy unmount
```

Or:
```
fuser -km /mnt  # Kill processes using /mnt
umount -R /mnt
```

### Troubleshooting Chroot

#### Cannot Mount Filesystem

**Error:** `mount: /mnt: can't read superblock`

**Solutions:**

**Check filesystem:**
```
fsck /dev/sda2
```

**Check partition table:**
```
fdisk -l /dev/sda
```

**Try different filesystem type:**
```
mount -t ext4 /dev/sda2 /mnt
```

#### Network Not Working

**DNS issues:**
```
# Copy from live environment
cp /etc/resolv.conf /mnt/etc/resolv.conf
```

**No internet in chroot:**
```
# Setup network in live environment first
dhcpcd
ping archlinux.org

# Then chroot
arch-chroot /mnt
```

#### Pacman Signature Errors

**Invalid signatures:**
```
# In chroot
pacman -Sy archlinux-keyring
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys
```

### Best Practices

**Verify partitions before mounting:** Double-check partition identification with `lsblk`.

**Mount in correct order:** Root first, then boot, then other partitions.

**Use arch-chroot when available:** It handles virtual filesystems automatically.

**Keep live USB updated:** Use recent Arch ISO for compatibility.

**Network setup:** Ensure network works before attempting updates.

**Exit cleanly:** Always exit chroot and unmount properly.

**Document actions:** Keep notes on what you did for future reference.

**Test before rebooting:** Verify critical operations completed successfully.

**Backup first when possible:** If time allows, backup before chroot operations.

**Know your system:** Understand partition layout, encryption, LVM setup, etc.

Chroot operations are powerful recovery tools that enable fixing nearly any Arch Linux system issue without reinstallation, provided the root filesystem is intact.

