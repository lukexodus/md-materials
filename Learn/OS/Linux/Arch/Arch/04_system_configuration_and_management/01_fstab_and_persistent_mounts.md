## fstab and Persistent Mounts


### fstab Overview

**Purpose**: The `/etc/fstab` (filesystem table) file defines how disk partitions, block devices, and remote filesystems are automatically mounted at system boot. Each line represents one filesystem entry, enabling persistent mount configuration across reboots.[1][2]

**Importance**: Without fstab entries, mounted filesystems would require manual mounting after each reboot. Fstab ensures consistent system state initialization.[1]

### File Structure

**Entry Format**: Each fstab line contains six tab or space-separated fields:[1]

```
[device] [mount_point] [type] [options] [dump] [fsck]
```

**Field Definitions**:[1]

1. **`<device>`**: Device identifier specifying the filesystem to mount. Options include:[1]
   - Device path: `/dev/sda1`[1]
   - UUID: `UUID=a1b2c3d4-e5f6-7890-abcd-ef1234567890`[1]
   - LABEL: `LABEL=MyDrive`[1]
   - Network path: `//server/share` for NFS/CIFS[1]

2. **`<mount_point>`**: Directory where the filesystem attaches in the hierarchy. Must exist before mounting. Common mount points include `/`, `/home`, `/boot`, `/var`, `/tmp`.[1]

3. **`<type>`**: Filesystem format type. Examples include:[1]
   - `ext4`: Standard Linux filesystem[1]
   - `btrfs`: Modern copy-on-write filesystem[1]
   - `vfat`: FAT32 for boot partitions[1]
   - `swap`: Swap space[1]
   - `nfs`: Network filesystem[1]
   - `tmpfs`: Temporary filesystem in RAM[1]

4. **`<options>`**: Mount behavior flags controlling read/write permissions, user privileges, and special features. Multiple options are comma-separated:[1]
   - `defaults`: Standard options (`rw`, `suid`, `dev`, `exec`, `auto`, `nouser`, `async`)[1]
   - `rw`: Read-write mounting[1]
   - `ro`: Read-only mounting[1]
   - `noatime`: Disables access time updates for performance[1]
   - `nosuid`: Disables SUID bit execution[1]
   - `nodev`: Prevents device file interpretation[1]
   - `noexec`: Prevents executable files from running[1]
   - `auto`: Automatically mounts at boot[1]
   - `noauto`: Requires manual mounting[1]
   - `user`: Allows non-root users to mount/unmount[1]
   - `nouser`: Only root can mount/unmount[1]

5. **`<dump>`**: Backup flag for backup utilities. Values:[1]
   - `0`: Do not back up[1]
   - `1`: Include in backups[1]

6. **`<fsck>`**: Filesystem check order at boot. Values:[1]
   - `0`: No automatic check[1]
   - `1`: Check first (root filesystem)[1]
   - `2`: Check second (other filesystems)[1]

### Practical fstab Examples

**Typical Root Filesystem**:[1]
```
UUID=0a3407de-014b-458b-b5c1-848e92a327a3 / ext4 defaults 0 1
```

**Home Partition**:[1]
```
UUID=f9fe0b69-a280-415d-a03a-a32752370dee /home ext4 defaults,nodev,nosuid 0 2
```

**Boot Partition (UEFI)**:[1]
```
UUID=CBB6-24F2 /boot vfat defaults,nodev,nosuid,noexec,fmask=0177,dmask=0077 0 2
```

**Swap Space**:[1]
```
UUID=8f9fe0b69-a280-415d-a03a-a3275237fd10 none swap defaults 0 0
```

**Temporary RAM Filesystem**:[1]
```
tmpfs /run tmpfs defaults,nodev,noexec,nosuid 0 0
```

### Device Identification

**Why UUIDs Matter**: Device names like `/dev/sda1` can change if hardware configuration is altered, breaking fstab entries. UUIDs uniquely identify partitions regardless of physical position.[1]

**Retrieve UUIDs**: `blkid` displays all block devices with their identifiers.[1]

**Output Format**:
```
/dev/sda1: UUID="c1e41a6b-5381-42de-87e3-c3ff32d97aac" TYPE="ext4"
/dev/sda2: UUID="8de82e10-6d96-4319-91e5-f7de8ecb8b2e" TYPE="ext4"
```

**In fstab**: Use the UUID format with the `UUID=` prefix.[1]

### Generating fstab from Mounted Filesystems

**Automated Generation**: The `genfstab` utility automatically generates fstab entries from currently mounted partitions.[3][4]

**Command**: `genfstab -U /mnt >> /mnt/etc/fstab`.[4][3]

**Parameters**:[3]
*   **`-U`**: Specifies UUID-based device identification for reliability[3]
*   **`/mnt`**: Target directory containing the installed system[3]
*   **`>>`**: Appends generated content to the existing fstab file[3]

**Usage Context**: Execute this command during Arch installation after mounting all partitions and before chrooting.[4][3]

### EFI Boot Partition Mount Options

**Security Hardening**:[1]

```
UUID=CBB6-24F2 /boot vfat defaults,nodev,nosuid,noexec,fmask=0177,dmask=0077 0 2
```

**Option Explanations**:[1]
*   `nodev`: Prevents device special files from functioning
*   `nosuid`: Disables SUID bit execution for security
*   `noexec`: Prevents direct executable execution
*   `fmask=0177`: Restricts file permissions to root-only access
*   `dmask=0077`: Restricts directory permissions to root-only access

### Special Filesystems

**Swap**: Requires special handling; use `type=swap` with `none` as mount point.[1]

**tmpfs**: In-memory filesystems useful for temporary data; no device needed.[1]

**Bind Mounts**: Attach one directory to another location without duplication:[1]
```
/source /destination none defaults,bind 0 0
```

### Btrfs Subvolume Mounting

**Subvolume Specification**: Btrfs filesystems with subvolumes require the `subvol=` option:[3]

```
UUID=a1b2c3d4-e5f6-7890-abcd-ef1234567890 / btrfs defaults,subvol=@ 0 0
UUID=a1b2c3d4-e5f6-7890-abcd-ef1234567890 /home btrfs defaults,subvol=@home 0 0
UUID=a1b2c3d4-e5f6-7890-abcd-ef1234567890 /var/log btrfs defaults,subvol=@var_log 0 0
```

### Testing fstab Configuration

**Mount All Filesystems**: `mount -a` mounts all filesystems listed in fstab.[1]

**Purpose**: Verify fstab syntax and mount configuration without requiring reboot.[1]

**Error Detection**: Invalid entries produce error messages identifying problematic lines.[1]

**Dry Run**: Before using `mount -a`, manually verify critical entries are correct.[1]

### Troubleshooting Common Issues

**Missing Mount Point**: Create directories with `mkdir` before mounting.[1]

**Incorrect UUID**: Retrieve correct UUID with `blkid` and update fstab.[1]

**Permission Denied**: Check mount options; `rw` enables write permissions.[1]

**Filesystem Not Recognized**: Verify `<type>` field matches actual filesystem format; use `blkid` to identify.[1]

**Boot Failures**: Comment problematic lines with `#` to boot; then fix and uncomment.[1]

### Best Practices

**Use UUIDs**: Always use `UUID=` format for device identification.[1]

**Restrictive Boot Options**: Apply security-focused options to EFI boot partitions.[1]

**Backup Before Changes**: Save current fstab before modifications.[1]

**Test Changes**: Use `mount -a` to validate before rebooting.[1]

**Logical Organization**: List root first, then other partitions in logical order.[1]

Sources
[1] fstab - ArchWiki https://wiki.archlinux.org/title/Fstab
[2] Arch Linux Drive Mounting Made Easy (fstab Guide) https://www.youtube.com/watch?v=4pXWkczHBB8
[3] BTRFS, XFS and EXT4 Arch Linux Install Guide https://gist.github.com/dante-robinson/fdc55726991d3f17e0dbef1701d343ef
[4] Arch Linux Installation: Easy Step-by-Step Guide https://linuxconfig.org/arch-linux-installation-easy-step-by-step-guide

