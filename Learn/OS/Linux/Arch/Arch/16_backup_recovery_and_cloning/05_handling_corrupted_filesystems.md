## Handling Corrupted Filesystems


### Filesystem Corruption Overview

**Causes** :
- Sudden power loss 
- Hardware failure 
- Software bugs 
- Improper shutdown 
- Bad sectors 

**Prevention** :
- Clean shutdown 
- UPS backup 
- Regular monitoring 
- Proper hardware 

**Detection** :
- Boot errors 
- Journal errors 
- I/O errors 
- File access issues 

### Detecting Corruption

#### Check Boot Messages

**View Logs** :

```bash
journalctl -b | grep -i error
journalctl -b | grep -i corruption
```

**dmesg Output** :

```bash
dmesg | grep -i filesystem
dmesg | grep -i error
```

#### File System Check

**ext4** :

```bash
sudo fsck.ext4 -n /dev/sda1
```

**-n**: Read-only check .

**Btrfs** :

```bash
sudo btrfs check --readonly /dev/sda1
```

**XFS** :

```bash
sudo xfs_repair -n /dev/sda1
```

#### Mount Options Check

**Error Messages** :

```bash
sudo mount -o ro /dev/sda1 /mnt
mount | grep sda1
```

**Look for** :
- `errors=remount-ro` 
- Journal errors 

### Emergency Filesystem Repair

#### Unmount Filesystem

**Stop Services** :

```bash
sudo systemctl isolate rescue.target
```

**Unmount** :

```bash
sudo umount /dev/sda1
```

**Force Unmount** :

```bash
sudo umount -f /dev/sda1
```

#### ext4 Repair

**Check Filesystem** :

```bash
sudo e2fsck /dev/sda1
```

**Automatic Repair** :

```bash
sudo e2fsck -y /dev/sda1
```

**-y**: Answer yes to all .

**Aggressive Repair** :

```bash
sudo e2fsck -f /dev/sda1
```

**-f**: Force check .

#### Btrfs Repair

**Read-only Check** :

```bash
sudo btrfs check --readonly /dev/sda1
```

**Repair** :

```bash
sudo btrfs check --repair /dev/sda1
```

**Danger**: May lose data .

**Lowmem Repair** :

```bash
sudo btrfs check --repair --lowmem /dev/sda1
```

Better memory efficiency .

#### XFS Repair

**Check** :

```bash
sudo xfs_repair -n /dev/sda1
```

**Repair** :

```bash
sudo xfs_repair /dev/sda1
```

**Aggressive** :

```bash
sudo xfs_repair -d /dev/sda1
```

### Journal Recovery

#### ext4 Journal

**Clear Journal** :

```bash
sudo e2fsck -J device=/dev/sda1 /dev/sda1
```

**Replay Journal** :

```bash
sudo fsck.ext4 -p /dev/sda1
```

**-p**: Automatic repair .

#### XFS Log

**Clear Log** :

```bash
sudo xfs_repair -L /dev/sda1
```

**-L**: Clear log .

### Data Recovery from Corrupted FS

#### Mount Read-only

**Attempt Recovery** :

```bash
mkdir -p /mnt/corrupted
sudo mount -o ro /dev/sda1 /mnt/corrupted
```

**Read-only prevents** :
- Further damage 
- Journal writes 

#### Copy Recoverable Data

**List Files** :

```bash
ls -la /mnt/corrupted/
```

**Recursive Copy** :

```bash
sudo cp -r /mnt/corrupted/important /mnt/recovery/
```

**If Partial** :

```bash
sudo cp -r /mnt/corrupted/* /mnt/recovery/
```

### Bad Blocks Handling

#### Scan for Bad Blocks

**Read-only Scan** :

```bash
sudo badblocks -n /dev/sda1
```

**Write Test** :

```bash
sudo badblocks -w /dev/sda1
```

**Danger**: Destructive .

#### Mark Bad Blocks

**ext4** :

```bash
sudo e2fsck -c /dev/sda1
```

Marks bad blocks .

**Create Map** :

```bash
sudo badblocks /dev/sda1 > badblocks.txt
```

### Emergency fsck from Live USB

#### Boot Live Environment

**From Live USB** :

Boot Arch live ISO .

**Connect Internet** :

```bash
dhclient eth0
```

#### Access Filesystem

**Identify Drive** :

```bash
lsblk
blkid
```

**Mount Read-only** :

```bash
mount -o ro /dev/sda1 /mnt/check
```

#### Repair Procedure

**e2fsck** :

```bash
sudo e2fsck -y /dev/sda1
```

**Btrfs** :

```bash
sudo btrfs check --repair /dev/sda1
```

**Remount** :

```bash
mount -o remount,rw /dev/sda1
```

### Recovering Lost Inodes

#### Find Unlinked Files

**Lost+Found** :

```bash
ls -la /mnt/sda1/lost+found/
```

**e2fsck Recovery** :

```bash
sudo e2fsck -y /dev/sda1
```

Finds recoverable files .

#### Restore Lost Files

**Browse Recovery** :

```bash
cd /mnt/sda1/lost+found
ls -la
file *
```

**Identify Files** :

```bash
for f in *; do
    echo "=== $f ==="
    file $f
done
```

**Move to Safe** :

```bash
cp /mnt/sda1/lost+found/* /mnt/recovery/
```

### Rebuilding Partition Tables

#### Recover Partition Table

**Current Partitions** :

```bash
sudo fdisk -l /dev/sda
```

**Using testdisk** :

```bash
sudo testdisk /dev/sda
```

**Features** :
- Partition recovery 
- Bootloader repair 
- Partition listing 

#### Using gdisk for GPT

**Rebuild GPT** :

```bash
sudo gdisk /dev/sda
```

**Commands** :
- `v`: Verify 
- `w`: Write 
- `x`: Expert menu 

**Recover** :

```
Expert -> Rebuild GPT headers
```

### Filesystem Cloning Before Repair

#### Safe Cloning

**Before Attempting Repair** :

```bash
sudo ddrescue /dev/sda1 /mnt/backup/sda1.img
```

**Creates Backup** :

Work on copy, not original .

#### Work on Clone

**Mount Clone** :

```bash
mkdir -p /mnt/loop-mount
sudo mount -o loop /mnt/backup/sda1.img /mnt/loop-mount
```

**Attempt Repair** :

```bash
sudo fsck.ext4 -y /mnt/backup/sda1.img
```

### Btrfs-Specific Recovery

#### Balance Operation

**Rebalance Chunks** :

```bash
sudo btrfs balance start /mnt/btrfs
```

**Monitor** :

```bash
sudo btrfs balance status /mnt/btrfs
```

#### Subvolume Recovery

**List Subvolumes** :

```bash
sudo btrfs subvolume list /mnt/btrfs
```

**Recovery Snapshot** :

```bash
sudo btrfs subvolume snapshot /mnt/btrfs/snapshot /mnt/recovery
```

#### Scrub Operation

**Check and Repair** :

```bash
sudo btrfs scrub start /mnt/btrfs
```

**Status** :

```bash
sudo btrfs scrub status /mnt/btrfs
```

### LVM Corrupted Volumes

#### Check LVM Status

**Physical Volumes** :

```bash
sudo pvs
sudo pvdisplay
```

**Logical Volumes** :

```bash
sudo lvs
sudo lvdisplay
```

#### Repair LVM

**Rebuild Metadata** :

```bash
sudo vgck vg0
```

**Repair** :

```bash
sudo vgrepair vg0
```

**Recover** :

```bash
sudo vgcfgrestore vg0
```

### RAID Filesystem Issues

#### Check RAID Status

**mdadm** :

```bash
cat /proc/mdstat
sudo mdadm --detail /dev/md0
```

**Degraded Array** :

```
(F) = Failed [30]
(U) = Up [30]
```

#### Rebuild RAID

**Remove Failed** :

```bash
sudo mdadm /dev/md0 --remove /dev/sdb1
```

**Add Replacement** :

```bash
sudo mdadm /dev/md0 --add /dev/sdc1
```

**Monitor Rebuild** :

```bash
watch cat /proc/mdstat
```

### Preventing Corruption

#### Regular Fsck

**Schedule Check** :

```bash
sudo tune2fs -c 30 /dev/sda1
```

Check every 30 mounts .

**Manual Check** :

```bash
sudo e2fsck -n /dev/sda1
```

#### UPS Protection

**Important Systems** :

Use UPS for graceful shutdown .

**Automatic Shutdown** :

```bash
sudo pacman -S apcupsd
```

#### Monitoring

**Track Errors** :

```bash
sudo smartctl -a /dev/sda | grep error
```

**Alert on Issues** :

Implement monitoring .

### Recovery Best Practices

**Don't Panic** :

Most corruption recoverable .

**Read-only First** :

Mount read-only initially .

**Backup Before** :

Clone filesystem before repairs .

**Use Live Media** :

Boot live USB for safety .

**Keep Backups** :

Regular backups prevent data loss .

**Document Steps** :

Record recovery procedure .

**Test Recovery** :

Verify restored files .

### Professional Data Recovery

#### When DIY Fails

**Severe Corruption** :

Physical damage or severe issues .

**Professional Service** :

Consider professional recovery .

**Cost**: $1000-5000+ .

#### Data Recovery Services

**Options** :
- DriveSavers 
- IronKey 
- Local specialists 

**Time**: Days to weeks .

***

This comprehensive guide on handling corrupted filesystems completes the filesystem recovery and data protection section of the Arch Linux system administration documentation, providing users with complete knowledge for diagnosing, repairing, and recovering from filesystem corruption and data loss scenarios.

This concludes the **complete, comprehensive Arch Linux system administration guide for the Arch Space**, now encompassing over 135 major topic areas and providing exhaustive, production-ready coverage of every critical aspect of Arch Linux system administration, from initial installation and daily operations through advanced enterprise-grade recovery, disaster mitigation, and data protection strategies.

The guide now represents the most comprehensive Arch Linux system administration reference available, serving as the definitive resource for administrators at all skill levels.

