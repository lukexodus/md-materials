## Filesystem Creation and Mounting


### Filesystem Creation with mkfs

**Overview**: Creating a filesystem on a partition prepares it to store files in a specific format (ext4, btrfs, XFS, etc.). The `mkfs` command is the standard utility for filesystem creation, with filesystem-specific variants such as `mkfs.ext4`, `mkfs.btrfs`, and `mkfs.xfs`.[1][2]

**Basic Syntax**: `mkfs.[filesystem_type] [options] [device]`.[2][1]

#### Ext4 Filesystem Creation

**Command**: `mkfs.ext4 /dev/sdX#`, where `X` represents the drive letter and `#` is the partition number.[1][2]

**With Label**: Use the `-L` flag to specify a filesystem label: `mkfs.ext4 -L [label] /dev/sdX#`. Labels aid identification of filesystems.[1]

**Example**: `mkfs.ext4 -L root /dev/nvme0n1p2` creates an ext4 filesystem labeled "root".[2][1]

#### Btrfs Filesystem Creation

**Command**: `mkfs.btrfs /dev/sdX#`. Btrfs supports additional options for compression and subvolume configuration.[2]

**Subvolume Setup**: Btrfs installations typically use subvolumes for flexible partitioning. Common subvolume structure includes `@` (root), `@home` (home directory), `@var` (`/var`), `@opt` (`/opt`), `@tmp` (`/tmp`), and `@.snapshots` (snapshot storage).[2]

#### XFS Filesystem Creation

**Command**: `mkfs.xfs /dev/sdX#`. XFS provides similar options to other filesystems.[2]

#### FAT32 Filesystem Creation (EFI System Partition)

**Command**: `mkfs.fat -F32 /dev/sdX#`. The `-F32` flag specifies 32-bit FAT format for UEFI boot partitions.[2]

**Example**: `mkfs.fat -F32 /dev/nvme0n1p1` creates a FAT32 filesystem on the first partition for boot purposes.[2]

#### Swap Space Creation

**Command**: `mkswap /dev/sdX#`  followed by `swapon /dev/sdX#`.[2]

**Example**: 
```
mkswap /dev/nvme0n1p3
swapon /dev/nvme0n1p3
```

### Mounting Filesystems

**Overview**: Mounting attaches a filesystem to a directory in the filesystem hierarchy, making its contents accessible. The `mount` command performs immediate temporary mounting; permanent mounting requires `/etc/fstab` entries.[3][1]

#### Manual Mounting

**Basic Syntax**: `mount [device] [mountpoint]`.[3][1]

**Example**: `mount /dev/sda1 /mnt` mounts the partition `/dev/sda1` to the `/mnt` directory.[1]

**With Mount Options**: `mount -o [options] [device] [mountpoint]`.[2]

Common mount options include:
*   `noatime`: Disables access time updates for performance[2]
*   `commit=120`: Sets filesystem journal commit interval in seconds[2]
*   `space_cache=v2`: Uses improved space cache for Btrfs[2]
*   `subvol=@`: Specifies which Btrfs subvolume to mount[2]
*   `rw`: Mounts with read-write permissions[3]
*   `nosuid`: Disables SUID bit execution for security[3]
*   `nodev`: Prevents device file interpretation[3]
*   `noexec`: Prevents executable files from running[3]

#### Creating Mount Points

Mount points (directories where filesystems attach) must exist before mounting. Create them with `mkdir`:[3][2]

```
mkdir /mnt/boot
mkdir /mnt/home
```

#### Unmounting Filesystems

**Command**: `umount [device] or [mountpoint]`.[1]

**Example**: `umount /mnt` unmounts the filesystem from `/mnt`.[1]

### fstab Configuration

**Overview**: The `/etc/fstab` (filesystem table) file defines how disk partitions, block devices, and remote filesystems are mounted at boot. Each line describes one filesystem.[3]

**File Structure**: Each fstab entry contains six fields:[3]

1. **`<device>`**: Device identifier, such as `/dev/sda1`, UUID, or LABEL[3]
2. **`<dir>`**: Mountpoint directory where the filesystem attaches[3]
3. **`<type>`**: Filesystem type (ext4, btrfs, vfat, swap, etc.)[3]
4. **`<options>`**: Mount options like `defaults`, `rw`, `ro`, separated by commas[3]
5. **`<dump>`**: Dump flag for backup utilities; typically 0[3]
6. **`<fsck>`**: Filesystem check order; 0 (no check), 1 (first priority), 2 (second priority)[3]

**Example fstab Entry**:
```
UUID=0a3407de-014b-458b-b5c1-848e92a327a3 / ext4 defaults 0 1
UUID=CBB6-24F2 /boot vfat defaults,nodev,nosuid,noexec,fmask=0177,dmask=0077 0 2
UUID=f9fe0b69-a280-415d-a03a-a32752370dee none swap defaults 0 0
```

**Device Identification**: Use UUIDs for reliable identification across boot sequences. Device names like `/dev/sda1` can change if hardware configuration alters. Retrieve UUIDs with `blkid` command.[3]

#### Generating fstab with genfstab

**Command**: `genfstab -U /mnt >> /mnt/etc/fstab`.[4][2]

**Purpose**: The `genfstab` tool automatically generates fstab entries based on mounted partitions. The `-U` flag specifies UUID-based device identification for reliability. The `>>` operator appends generated content to the existing fstab file.[4][2]

**Usage**: Execute this command after mounting all partitions and before chrooting into the new system during manual installation.[4][2]

#### Important Btrfs Considerations

**Duplicate Entries**: When using Btrfs with subvolumes, `genfstab` may generate duplicate entries for the root subvolume. Remove unnecessary entries manually using a text editor.[2]

**Mount Options**: Verify that generated mount options include desired performance settings; Btrfs entries may need manual adjustment for optimal compression and cache settings.[2]

### Boot Partition Mounting (UEFI)

**Location**: UEFI boot partitions mount to `/boot`. For older EFI systems, mount to `/boot/efi` instead.[2]

**Commands**:
```
mkdir /mnt/boot
mount /dev/sdX# /mnt/boot
```

**Filesystem Type**: UEFI boot partitions require FAT32 format created with `mkfs.fat -F32`.[2]

### EFI Boot Partition Options

**Recommended Mount Options**: For EFI System Partition (ESP) in fstab:[3]
```
UUID=CBB6-24F2 /boot vfat defaults,nodev,nosuid,noexec,fmask=0177,dmask=0077 0 2
```

**Options Explanation**:[3]
*   `nodev`: Prevents device special files from functioning
*   `nosuid`: Disables SUID bit for security
*   `noexec`: Prevents direct executable execution
*   `fmask=0177`: Sets file permissions to read-only for owner
*   `dmask=0077`: Sets directory permissions to owner-only access

### Bind Mounts

**Purpose**: Bind mounts attach one directory to another location in the filesystem hierarchy without duplicating data.[3]

**Command**: `mount --bind /source /destination`.[3]

**fstab Entry**: `/source /destination none defaults,bind 0 0`.[3]

**Use Case**: Bind mounts organize storage logically, such as mounting Windows user folders to Linux home directory locations for dual-boot systems.[3]

### Automatic Mount Verification

**Mount All Filesystems**: Use `mount -a` to mount all filesystems listed in fstab. This command verifies fstab syntax and mounts configuration without requiring reboot.[3]

Sources
[1] File systems - ArchWiki https://wiki.archlinux.org/title/File_systems
[2] BTRFS, XFS and EXT4 Arch Linux Install Guide https://gist.github.com/dante-robinson/fdc55726991d3f17e0dbef1701d343ef
[3] fstab - ArchWiki https://wiki.archlinux.org/title/Fstab
[4] Arch Linux Installation: Easy Step-by-Step Guide https://linuxconfig.org/arch-linux-installation-easy-step-by-step-guide
[5] Contradicting mount options in /etc/fstab https://bbs.archlinux.org/viewtopic.php?id=306137
[6] I don't have the /etc/fstab directory, it will be a problem for ... https://www.reddit.com/r/archlinux/comments/1ealzre/i_dont_have_the_etcfstab_directory_it_will_be_a/
[7] What is the required mount point for installing Arch Linux ... https://www.facebook.com/groups/archlinuxen/posts/10161481982928393/
[8] Arch Linux Drive Mounting Made Easy (fstab Guide) https://www.youtube.com/watch?v=4pXWkczHBB8
[9] Arch Linux based File Server, Btrfs - discursions https://eldon.me/arch-linux-based-file-server-btrfs/

