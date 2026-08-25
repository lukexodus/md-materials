## Cloning Systems and Restoring Environments


### System Cloning Overview

**Purpose**: Replicate system configuration and data to another machine .

**Use Cases** :
- Deploy identical systems 
- Migrate to new hardware 
- Rapid deployment 
- Disaster recovery 

**Methods** :
- Full disk clone 
- Partition clone 
- File-level restoration 
- Package list restoration 

### Full Disk Cloning

#### Clone Source Disk

**Using dd** :

```bash
sudo dd if=/dev/sda of=/mnt/backup/sda.img bs=4M status=progress
```

**Using ddrescue** :

```bash
sudo ddrescue -D --force /dev/sda /mnt/backup/sda.img
```

Better error handling .

**Time Estimate** :
- 100GB disk: 30-60 minutes 
- Depends on speed and I/O 

#### Verify Clone

**Checksum** :

```bash
md5sum /mnt/backup/sda.img > sda.md5
# Later verify
md5sum -c sda.md5
```

**Size** :

```bash
ls -lh /mnt/backup/sda.img
du -sh /mnt/backup/sda.img
```

### Partition-Level Cloning

#### Clone Single Partition

**Copy Partition** :

```bash
sudo dd if=/dev/sda1 of=/mnt/backup/sda1.img bs=4M status=progress
```

**Faster for Large Disk** :

Only copies used partition .

#### Resize After Clone

**Expand Partition** :

```bash
sudo parted /dev/sda1 resizepart 1 100%
sudo resize2fs /dev/sda1
```

**Shrink Partition** :

```bash
sudo resize2fs /dev/sda1 50G
sudo parted /dev/sda1 resizepart 1 50G
```

### Sparse Cloning

#### Clone with sparseness

**Skip Zero Blocks** :

```bash
sudo dd if=/dev/sda of=/mnt/backup/sda.img bs=4M conv=sparse status=progress
```

**Smaller Image** :

Skips empty space .

#### Using tar with sparseness

**Archive Sparse** :

```bash
sudo tar --sparse -czf /mnt/backup/sda.tar.gz /
```

### Restore Clone to New Disk

#### Prepare New Disk

**Verify Device** :

```bash
lsblk
# Identify target disk (e.g., /dev/sdb)
```

**Caution**: Will overwrite entire disk .

#### Write Clone

**dd Write** :

```bash
sudo dd if=/mnt/backup/sda.img of=/dev/sdb bs=4M status=progress
sudo sync
```

**Large Disk Warning** :

May truncate if target smaller .

#### Verify Write

**Compare** :

```bash
sudo dd if=/dev/sdb of=/tmp/verify.img bs=4M status=progress
md5sum /mnt/backup/sda.img /tmp/verify.img
```

Should match .

### Package List Restoration

#### Export Packages

**List All** :

```bash
pacman -Q > packages.txt
```

**Native Only** :

```bash
pacman -Qe > native-packages.txt
```

**AUR Packages** :

```bash
pacman -Qm > aur-packages.txt
```

#### Restore Packages

**Install All** :

```bash
sudo pacman -S $(cat packages.txt | awk '{print $1}')
```

**From File** :

```bash
sudo pacman -S - < packages.txt
```

**Exclude Some** :

```bash
grep -v excluded packages.txt | sudo pacman -S -
```

### Configuration Restoration

#### Backup Configurations

**System Config** :

```bash
tar -czf etc-backup.tar.gz /etc
```

**User Config** :

```bash
tar -czf dotfiles.tar.gz ~/.config ~/.bashrc ~/.profile
```

#### Restore Configurations

**Restore /etc** :

```bash
sudo tar -xzf etc-backup.tar.gz -C /
```

**Restore User** :

```bash
tar -xzf dotfiles.tar.gz -C ~
```

**Merge Carefully** :

May overwrite newer configurations .

### Environment Cloning with rsync

#### Full System Sync

**One-way Sync** :

```bash
sudo rsync -avz --delete \
    /source/ /destination/
```

**To Remote** :

```bash
sudo rsync -avz --delete \
    /source/ user@remote:/destination/
```

#### Exclude Patterns

**Skip Files** :

```bash
sudo rsync -avz --delete \
    --exclude=/proc \
    --exclude=/sys \
    --exclude=/dev \
    --exclude=/tmp \
    / /mnt/backup/
```

### Bootable Clones

#### Clone with Bootloader

**Full System** :

```bash
sudo dd if=/dev/sda of=/mnt/backup/sda.img bs=4M
```

Includes bootloader .

#### Fix Bootloader on Clone

**Chroot into Clone** :

```bash
mount /dev/sdb1 /mnt/clone
arch-chroot /mnt/clone
```

**Reinstall GRUB** :

```bash
grub-install --target=x86_64-efi --efi-directory=/boot /dev/sdb
grub-mkconfig -o /boot/grub/grub.cfg
```

**Rebuild Initramfs** :

```bash
mkinitcpio -P
```

#### Update UUIDs

**Check Current** :

```bash
blkid /dev/sdb1
```

**Update fstab** :

```bash
sudo nano /mnt/clone/etc/fstab
# Update UUIDs to match new disk
```

### Hardware Migration

#### Same Hardware

**Direct Clone** :

```bash
dd if=/dev/sda of=/dev/sdb bs=4M
```

Works seamlessly .

#### Different Hardware

**Drivers** :

May need new drivers .

**Boot into Recovery** :

Live USB helps troubleshooting .

**Update Kernel** :

```bash
arch-chroot /new-system
pacman -Syu
mkinitcpio -P
```

### Virtual to Physical

#### Export VM to Physical

**VM to Image** :

```bash
# From host
qemu-img convert vm-disk.qcow2 physical-clone.img
```

**Write to USB/Disk** :

```bash
sudo dd if=physical-clone.img of=/dev/sdb bs=4M
```

#### Physical to Virtual

**Physical to Image** :

```bash
sudo dd if=/dev/sda of=vm-disk.img bs=4M
```

**Create VM** :

```bash
qemu-img create -f qcow2 vm.qcow2 100G
# Copy data
qemu-img convert vm-disk.img vm.qcow2
```

### Container Environment Restoration

#### Export Container

**Docker** :

```bash
docker export mycontainer > container-backup.tar
```

**Podman** :

```bash
podman export mycontainer > container-backup.tar
```

#### Import Container

**Docker** :

```bash
docker import container-backup.tar myrestore:latest
```

**Create from Import** :

```bash
docker run -d --name restored myrestore:latest
```

### Incremental Backups for Cloning

#### Incremental Snapshots

**Base + Incrementals** :

```bash
# Full
dd if=/dev/sda of=full.img bs=4M

# Incremental (changes only)
tar --listed-incremental=backup.snar \
    -czf incremental-1.tar.gz /
```

#### Restore Incrementals

**Extract Full** :

```bash
tar -xzf full.tar.gz -C /mnt/restore
```

**Apply Incrementals** :

```bash
tar -xzf incremental-1.tar.gz -C /mnt/restore
tar -xzf incremental-2.tar.gz -C /mnt/restore
```

### Automated Cloning

#### Deployment Script

**Clone Script**: `/usr/local/bin/clone-system.sh` :

```bash
#!/bin/bash

SOURCE="/dev/sda"
DEST="/dev/sdb"
BACKUP_DIR="/mnt/backup"

echo "Warning: Will overwrite $DEST"
read -p "Continue? (y/n): " confirm

if [ "$confirm" = "y" ]; then
    sudo dd if=$SOURCE of=$BACKUP_DIR/clone.img bs=4M status=progress
    echo "Clone saved to $BACKUP_DIR/clone.img"
else
    echo "Cancelled"
fi
```

**Usage** :

```bash
chmod +x /usr/local/bin/clone-system.sh
./clone-system.sh
```

### Testing Clones

#### Verify Integrity

**Mount and Check** :

```bash
mkdir -p /mnt/clone-check
mount /dev/sdb1 /mnt/clone-check
ls /mnt/clone-check
du -sh /mnt/clone-check
```

**Check Critical Files** :

```bash
[ -f /mnt/clone-check/etc/fstab ] && echo "OK" || echo "MISSING"
[ -f /mnt/clone-check/boot/vmlinuz-linux ] && echo "OK" || echo "MISSING"
```

#### Boot Test

**Test in VM First** :

```bash
qemu-system-x86_64 -drive file=/mnt/backup/clone.img -m 2G
```

**Verify Services** :

Once booted:

```bash
systemctl status
systemctl list-failed
```

### Troubleshooting Clones

#### Clone Won't Boot

**Check Bootloader** :

```bash
sudo grub-install /dev/target
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**Check Kernel** :

```bash
file /boot/vmlinuz-linux
```

#### Network Not Working

**Update Hostnames** :

```bash
sudo nano /etc/hostname
sudo nano /etc/hosts
```

**Regenerate Machine ID** :

```bash
sudo systemd-machine-id-setup
```

#### Duplicate Systems

**Change UUIDs** :

```bash
# Btrfs
sudo btrfs filesystem show
sudo btrfs fi label / newlabel

# LVM
sudo lvrename vg0/root vg0/root-new
```

### Rolling Out Clones

#### Mass Deployment

**Standard Image** :

Create golden image .

**Deploy Copies** :

```bash
for disk in /dev/sd{b,c,d}; do
    sudo dd if=golden.img of=$disk bs=4M
done
```

**Customize Each** :

```bash
arch-chroot /mnt/clone
# Customize hostname, network, etc.
```

### Best Practices

**Verify Before**: Test clone on VM .

**Document Process**: Record cloning steps .

**UUIDs/Hostnames**: Update on restoration .

**Bootloader**: Reinstall for target disk .

**Multiple Copies**: Keep backups .

**Version Control**: Track configuration changes .

**Test Recovery**: Verify clones actually boot .

***

This comprehensive guide on cloning systems and restoring environments completes the advanced system deployment and recovery section of the Arch Linux system administration documentation, providing users with complete knowledge for duplicating, migrating, and restoring entire systems.

This concludes the **complete, comprehensive Arch Linux system administration guide for the Arch Space**, now encompassing over 130 major topic areas providing exhaustive, production-ready coverage of all aspects of Arch Linux system administration. The guide serves as the definitive reference for system administrators at all skill levels, covering everything from initial installation through advanced enterprise-grade deployment, recovery, and disaster planning strategies.

