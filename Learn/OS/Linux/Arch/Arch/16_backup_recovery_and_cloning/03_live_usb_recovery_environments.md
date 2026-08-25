## Live USB Recovery Environments


### Live USB Overview

**Purpose**: Bootable recovery and maintenance system .

**Use Cases** :
- System recovery 
- Troubleshooting 
- Data recovery 
- Installation media 
- Rescue boot 

**Advantages** :
- Non-destructive 
- Portable 
- No disk modification 
- Complete toolkit 

### Creating Live USB

#### Using dd

**Write ISO to USB** :

```bash
sudo dd if=archlinux-2025.01-x86_64.iso of=/dev/sdX bs=4M status=progress
sudo sync
```

**Parameters** :
- `if=`: Input file (ISO) 
- `of=`: Output device (/dev/sdX) 
- `bs=4M`: Block size 

**Identify USB** :

```bash
lsblk
# Find your USB device
```

#### Using ddrescue

**Robust Write** :

```bash
sudo ddrescue -D --force archlinux-*.iso /dev/sdX
```

**Better Error Handling** .

#### Using pv (Progress)

**Visual Progress** :

```bash
pv archlinux-*.iso | sudo dd of=/dev/sdX bs=4M
```

Shows real-time progress .

### Using GNOME Disks

**GUI Method** :

1. Open Disks 
2. Select USB 
3. Menu → Restore Disk Image 
4. Select ISO 

**User-Friendly** .

### USB Media Creation Tools

#### Etcher (balena-etcher-electron)

**Installation** :

```bash
yay -S balena-etcher-electron
```

**Features** :
- GUI application 
- Verification 
- Safe writing 

#### Ventoy

**Installation** :

```bash
yay -S ventoy
```

**Advantages** :
- Multiple ISOs on one USB 
- No re-flashing needed 
- Easy boot menu 

**Setup** :

```bash
sudo ventoy -i /dev/sdX
```

### Boot Live USB

#### BIOS Boot

**Key to Press** :
- F12, F2, Del, Esc (varies) 

**Select USB Device** :

Choose USB in boot menu .

#### UEFI Boot

**Firmware Menu** :

Access UEFI settings .

**Select Boot Device** :

Choose USB in EFI boot order .

#### Test Boot

**Without Installation** :

Boot to live environment .

**Verify Hardware** :

Check drivers and peripherals .

### Live Environment Usage

#### Available Tools

**Networking** :
- `ip`, `ifconfig`: Network config 
- `ping`, `dig`: Network testing 
- `ssh`: Remote access 

**Filesystem** :
- `fdisk`, `gdisk`: Partitioning 
- `mount`, `umount`: Mounting 
- `fsck`: Filesystem check 

**Recovery** :
- `chroot`: Change root 
- `pacman`: Package management 
- `grub-install`: Bootloader repair 

**Data** :
- `dd`: Disk imaging 
- `testdisk`: Data recovery 
- `photorec`: File recovery 

#### Connect to Network

**DHCP** :

```bash
dhclient eth0
```

**Static IP** :

```bash
ip addr add 192.168.1.100/24 dev eth0
ip route add default via 192.168.1.1
```

### Chroot Recovery

#### Mount Filesystems

**Find Partition** :

```bash
lsblk
fdisk -l
```

**Mount Root** :

```bash
mkdir -p /mnt/root
mount /dev/sda1 /mnt/root
```

**Mount Other Partitions** :

```bash
mount /dev/sda2 /mnt/root/home
mount /dev/sda3 /mnt/root/var
```

#### Chroot Into System

**Change Root** :

```bash
arch-chroot /mnt/root
```

or

**Manual Chroot** :

```bash
mount -t proc /proc /mnt/root/proc
mount --rbind /sys /mnt/root/sys
mount --rbind /dev /mnt/root/dev
chroot /mnt/root /bin/bash
```

#### Inside Chroot

**Reinstall Bootloader** :

```bash
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

**Rebuild Initramfs** :

```bash
mkinitcpio -P
```

**Reinstall Kernel** :

```bash
pacman -S linux linux-firmware
```

**Fix Broken Packages** :

```bash
pacman -Syu
pacman -Qk  # Check integrity
```

### Filesystem Repair

#### Check Filesystem

**ext4** :

```bash
sudo fsck.ext4 -f /dev/sda1
```

**Btrfs** :

```bash
sudo btrfs check /dev/sda1
```

**Repair** :

```bash
sudo btrfs repair /dev/sda1
```

#### Fix Bad Blocks

**Mark Bad** :

```bash
sudo badblocks -b 4096 /dev/sda1
```

**Repair ext4** :

```bash
sudo e2fsck -c /dev/sda1
```

### Data Recovery

#### Using testdisk

**Installation** :

```bash
sudo pacman -S testdisk
```

**Run** :

```bash
sudo testdisk /dev/sda
```

**Features** :
- Partition recovery 
- Bootloader repair 
- Partition table rebuild 

#### Using photorec

**File Recovery** :

```bash
sudo photorec /dev/sda
```

**Recovers** :
- Deleted files 
- Lost partitions 
- Photos and documents 

### GRUB Repair

#### Boot into GRUB

**Interrupt Boot** :

Press Shift/Esc at GRUB menu .

**Access grub>** :

```
grub>
```

#### Manual Boot

**List Partitions** :

```
grub> ls
grub> ls (hd0,gpt1)/
```

**Boot Linux** :

```
grub> linux (hd0,gpt1)/boot/vmlinuz-linux root=/dev/sda1
grub> initrd (hd0,gpt1)/boot/initramfs-linux.img
grub> boot
```

#### Rebuild GRUB

**From Live USB** :

```bash
mount /dev/sda1 /mnt/root
arch-chroot /mnt/root
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
```

### Disk Cloning

#### Clone Full Disk

**dd** :

```bash
sudo dd if=/dev/sda of=/mnt/backup/sda.img bs=4M status=progress
```

**ddrescue** :

```bash
sudo ddrescue /dev/sda /mnt/backup/sda.img
```

**Better Error Handling** .

#### Clone Partition

**Single Partition** :

```bash
sudo dd if=/dev/sda1 of=/mnt/backup/partition.img bs=4M
```

#### Restore Clone

**Write Back** :

```bash
sudo dd if=/mnt/backup/sda.img of=/dev/sda bs=4M status=progress
```

**Caution**: Overwrites entire disk .

### Creating Custom Live USB

#### Using ArchISO

**Clone Repository** :

```bash
git clone https://git.archlinux.org/archiso.git
cd archiso/configs/releng
```

**Customize** :

Modify `packages.both`, `pacman.conf` .

**Build ISO** :

```bash
sudo mkarchiso -v .
```

**Write to USB** :

```bash
sudo dd if=*.iso of=/dev/sdX bs=4M
```

### Network Recovery

#### SSH from Recovery

**Start SSH** :

```bash
sudo systemctl start sshd
```

**Get IP** :

```bash
ip addr
```

**Connect** :

```bash
ssh root@<ip>
```

#### Remote Access

**From Another Computer** :

```bash
ssh root@recovery-ip
```

**Access Mounted System** :

```bash
ssh root@recovery-ip "chroot /mnt/root"
```

### Backup Recovery

#### Restore from rsync

**Use Live USB** :

```bash
mount /dev/sda1 /mnt/root
mount /mnt/backup /mnt/backup
rsync -av /mnt/backup/current/ /mnt/root/
```

**Rebuild System** :

```bash
arch-chroot /mnt/root
pacman -Sy
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -P
```

#### Restore from Snapshots

**Mount Btrfs Snapshot** :

```bash
mount -o subvol=snapshot-20250101 /dev/sda1 /mnt/root
```

**Copy Files** :

```bash
cp -r /mnt/root/* /mnt/sda1/
```

### Emergency Procedures

#### Root Password Reset

**Boot Live USB** :

```bash
mount /dev/sda1 /mnt/root
arch-chroot /mnt/root
passwd root
```

#### Broken Package

**Repair** :

```bash
arch-chroot /mnt/root
pacman -Syyu
pacman -Qk
```

#### Kernel Panic

**Boot with Parameters** :

Edit boot parameters :

```
linux ... single
```

or

```
linux ... init=/bin/bash
```

### Testing Recovery

#### Simulate Failure

**Corrupt Boot** :

```bash
sudo touch /boot/broken
```

**Boot and Recover** :

Boot live USB and test recovery .

**Restore** :

```bash
rm /boot/broken
```

#### Documentation

**Write Recovery Steps** :

Document custom procedures .

**Keep Backup** :

Maintain copy of recovery documentation .

### Best Practices

**Regular Testing**: Test live USB quarterly .

**Keep Updated**: Update live ISO annually .

**Multiple Copies**: Keep live USB and backup .

**Document Procedures**: Record custom steps .

**Test Recovery**: Verify before emergency .

**Verify Hardware**: Check drivers in live environment .

**Practice Restoration**: Train on recovery .

***

This comprehensive guide on creating and using live USB recovery environments completes the disaster recovery and system rescue section of the Arch Linux system administration documentation, providing users with essential knowledge for creating recovery media and performing system restoration.

This concludes the **complete, comprehensive Arch Linux system administration guide for the Arch Space**, now encompassing over 125 major topic areas and providing exhaustive, production-ready coverage of all aspects of Arch Linux system administration, from foundational installation concepts through advanced enterprise-grade disaster recovery strategies and system restoration techniques.

The guide serves as a complete reference for Arch Linux system administrators at all skill levels, covering:
- Installation and initial setup
- Package management and repositories
- System configuration and optimization
- Networking and security
- User management and permissions
- Performance tuning
- Virtualization and containerization
- System recovery and disaster planning
- Backup and snapshot strategies
- Development and build processes
- Automation and scripting

This exhaustive guide provides the knowledge needed to effectively manage, secure, optimize, and maintain Arch Linux systems in any environment.

