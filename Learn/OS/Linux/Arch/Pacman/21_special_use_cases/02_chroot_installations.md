## Chroot Installations


### Overview

Chroot installations allow building and installing Arch Linux systems in isolated environments without affecting the running system. This is essential for system installation, recovery, testing, and creating customized system images.

### Understanding Chroot for Installation

#### What Makes Chroot Installation Useful

**Installation scenarios:**
- Initial system installation from live USB
- Installing to new partition or disk
- System recovery and repair
- Building custom system images
- Testing package combinations
- Creating containerized environments

**Key difference from running system:**
- Isolated filesystem root
- Separate package database
- Independent systemd services
- Own configuration files
- Isolated networking (optional)

### Prerequisite: Prepare Filesystems

#### Partition the Disk

**List available disks:**
```bash
lsblk
fdisk -l
```

**Create partitions:**
```bash
# Using fdisk
sudo fdisk /dev/sda

# Or using parted
sudo parted /dev/sda

# Or automated (dangerous - use carefully)
sudo cfdisk /dev/sda
```

**Typical partition layout:**
```
/dev/sda1  512MB   EFI partition (if UEFI)
/dev/sda2  50GB    Root partition
/dev/sda3  Rest    Home partition (optional)
```

#### Format Filesystems

**Format EFI partition (if UEFI):**
```bash
sudo mkfs.fat -F32 /dev/sda1
```

**Format root partition:**
```bash
sudo mkfs.ext4 /dev/sda2
```

**Format home partition (optional):**
```bash
sudo mkfs.ext4 /dev/sda3
```

#### Mount Filesystems

**Mount for installation:**
```bash
# Create mount point
sudo mkdir -p /mnt/arch-install
cd /mnt/arch-install

# Mount root
sudo mount /dev/sda2 .

# Create and mount boot
sudo mkdir -p boot
sudo mount /dev/sda1 boot

# Create and mount home (optional)
sudo mkdir -p home
sudo mount /dev/sda3 home
```

**Verify mounts:**
```bash
mount | grep /mnt/arch-install
```

### Bootstrap: Install Base System

#### Download and Verify Bootstrap Tarball

**On any Linux system:**
```bash
# Download bootstrap
wget https://archive.archlinux.org/iso/latest/arch/x86_64/archlinux-bootstrap-latest-x86_64.tar.zst

# Verify (optional but recommended)
wget https://archive.archlinux.org/iso/latest/arch/x86_64/archlinux-bootstrap-latest-x86_64.tar.zst.sha256
sha256sum -c archlinux-bootstrap-latest-x86_64.tar.zst.sha256
```

#### Extract Bootstrap

**Extract to mounted filesystem:**
```bash
sudo tar -xzf archlinux-bootstrap-latest-x86_64.tar.zst -C /mnt/arch-install/

# This creates /mnt/arch-install/root.x86_64/
```

#### Enter Bootstrap Environment

**Chroot into bootstrap:**
```bash
sudo /mnt/arch-install/root.x86_64/bin/arch-chroot /mnt/arch-install/root.x86_64/
```

**You're now inside the chroot environment:**
```
[root@archiso /]#
```

### Installing Base System

#### Initialize Pacman Keys

**Inside chroot:**
```bash
pacman-key --init
pacman-key --populate archlinux
```

This sets up GPG keys for package signature verification.

#### Update Pacman Database

```bash
pacman -Sy
```

#### Install Base System Packages

**Core installation:**
```bash
pacman -S base linux linux-firmware
```

**Recommended additions:**
```bash
pacman -S base linux linux-firmware \
          base-devel \
          grub efibootmgr \
          sudo nano vim \
          dhcpcd networkmanager
```

**Full desktop installation:**
```bash
pacman -S base linux linux-firmware \
          base-devel \
          grub efibootmgr \
          xorg-server plasma kde-applications \
          dhcpcd networkmanager \
          firefox
```

#### Generate Fstab

**Exit chroot temporarily:**
```bash
exit
```

**Generate fstab from mounted filesystems:**
```bash
sudo genfstab -U /mnt/arch-install/ >> /mnt/arch-install/etc/fstab
```

**Verify fstab:**
```bash
cat /mnt/arch-install/etc/fstab
```

**Re-enter chroot:**
```bash
sudo arch-chroot /mnt/arch-install/
```

### System Configuration

#### Set Timezone

**Inside chroot:**
```bash
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
```

#### Set Hostname

```bash
echo "my-hostname" > /etc/hostname
```

**Configure hosts file:**
```bash
cat >> /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   my-hostname
EOF
```

#### Configure Locale

**Edit locale configuration:**
```bash
nano /etc/locale.gen
```

**Uncomment desired locales:**
```
en_US.UTF-8 UTF-8
en_GB.UTF-8 UTF-8
```

**Generate locales:**
```bash
locale-gen
```

**Set default locale:**
```bash
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

#### Configure Network

**Using DHCP:**
```bash
systemctl enable dhcpcd
```

**Using NetworkManager:**
```bash
systemctl enable NetworkManager
```

**Or static IP:**
```bash
cat > /etc/systemd/network/20-static.network << EOF
[Match]
Name=eth0

[Network]
Address=192.168.1.100/24
Gateway=192.168.1.1
DNS=8.8.8.8
EOF

systemctl enable systemd-networkd
```

#### Create Root User Password

```bash
passwd
# Enter password twice
```

#### Create Regular User

```bash
useradd -m -G wheel -s /bin/bash username
passwd username

# Allow wheel group sudo access
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
```

### Install and Configure Bootloader

#### GRUB (BIOS/UEFI)

**Install GRUB:**
```bash
pacman -S grub efibootmgr
```

**For BIOS:**
```bash
grub-install --target=i386-pc /dev/sda
```

**For UEFI:**
```bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
```

**Generate configuration:**
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

#### Systemd-boot (UEFI only)

**Install:**
```bash
bootctl install
```

**Create boot entries:**
```bash
mkdir -p /boot/loader/entries

cat > /boot/loader/entries/arch.conf << 'EOF'
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=/dev/sda2 rw
EOF
```

**Configure loader:**
```bash
cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
EOF
```

### Rebuild Initramfs

```bash
mkinitcpio -P
```

This creates initial ramdisk images for kernel boot.

### Exit and Unmount

#### Exit Chroot

```bash
exit
```

#### Unmount Filesystems

```bash
# Unmount in reverse order
sudo umount -R /mnt/arch-install/

# Verify unmounted
mount | grep /mnt/arch-install
# Should return nothing
```

### Boot Into New System

#### Reboot

```bash
sudo reboot
```

#### Select New System

- BIOS: Select drive/partition from boot menu
- UEFI: Select GRUB or systemd-boot from firmware menu
- Live USB: Remove USB, boot from new system drive

#### First Boot

**Login:**
```
Arch Linux 6.x.x-arch1-1 (tty1)
my-hostname login: username
Password: [enter password]
```

**Verify system:**
```bash
uname -a
pacman -Q
systemctl status
```

### Chroot Installation for Recovery

#### Scenario: Broken System Recovery

**Boot from live USB:**
```bash
# Mount existing system
sudo mount /dev/sda2 /mnt

# If EFI
sudo mount /dev/sda1 /mnt/boot/efi

# Enter chroot
arch-chroot /mnt
```

**Repair operations:**
```bash
# Reinstall packages
pacman -S base linux

# Rebuild bootloader
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Rebuild initramfs
mkinitcpio -P

# Exit and reboot
exit
sudo reboot
```

### Custom System Images via Chroot

#### Create Minimal Image

**Build in chroot:**
```bash
# Setup directories
mkdir -p /mnt/custom-image/root
cd /mnt/custom-image

# Bootstrap
sudo tar -xzf archlinux-bootstrap-*.tar.zst

# Enter chroot
sudo arch-chroot root.x86_64/

# Install minimal packages
pacman -S base linux

# Exit
exit
```

**Create distributable image:**
```bash
tar -czf minimal-arch-image.tar.gz -C /mnt/custom-image root.x86_64/
```

#### Pre-Configure System in Chroot

**Install and configure applications:**
```bash
# Inside chroot
pacman -S firefox chromium vlc

# Configure services
systemctl enable NetworkManager
systemctl enable sshd

# Add users
useradd -m admin
```

**Create image with pre-configuration:**
```bash
# Exit and archive
exit
tar -czf preconfigured-image.tar.gz -C /mnt/custom-image root.x86_64/
```

### Troubleshooting Chroot Installations

#### Chroot Fails to Enter

**Error:**
```
bash: /mnt/arch-install/bin/bash: No such file or directory
```

**Solution:**
- Verify mount points are correct
- Check bootstrap tarball was extracted properly
- Use `arch-chroot` wrapper instead of plain `chroot`

#### Packages Won't Install

**Error:**
```
error: failed to prepare transaction
```

**Inside chroot:**
```bash
# Reinitialize keys
pacman-key --init
pacman-key --populate archlinux

# Refresh databases
pacman -Syy
```

#### Network Unavailable in Chroot

**Check networking:**
```bash
ping -c 3 archlinux.org
```

**If fails:**
```bash
# Configure DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Or enable network in chroot setup
# When entering: arch-chroot -N /mnt/arch-install/
```

#### Bootloader Won't Install

**For UEFI systems:**
```bash
# Verify EFI partition is mounted
mount | grep efi

# Verify UEFI variables are available
ls -la /sys/firmware/efi/efivars/

# Re-attempt installation
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
```

### Best Practices

**Preparation:**
- Backup existing data
- Have recovery media available
- Document system configuration
- Test in VM first if possible

**During installation:**
- Don't skip key generation
- Use strong passwords
- Configure all necessary services
- Verify network connectivity

**Documentation:**
- Record hostname and users created
- Document custom configurations
- Keep PKGBUILD copies if using AUR
- Note any special settings

**Testing:**
- Verify bootloader works
- Test all configured services
- Check package installation
- Test user accounts

**Recovery:**
- Keep live USB updated
- Document recovery procedures
- Test recovery process periodically
- Maintain system backups

Chroot installations provide complete control over system creation and recovery, essential for Arch Linux administration and deployment.

