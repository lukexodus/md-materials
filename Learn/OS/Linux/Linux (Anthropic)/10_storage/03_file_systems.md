## File Systems


### File System Types

### ext4 (Fourth Extended File System)

Ext4 is the default file system for most Linux distributions and an evolution of the ext family. It provides journaling capabilities and improved performance over its predecessors.

**Key points** for ext4:

- Maximum file size: 16 TiB
- Maximum file system size: 1 EiB
- Supports extents for better large file performance
- Backward compatible with ext2 and ext3
- Delayed allocation for improved performance
- Online defragmentation support

### XFS (eXtended File System)

XFS is a high-performance 64-bit journaling file system originally developed by Silicon Graphics. It excels with large files and file systems.

**Key points** for XFS:

- Maximum file size: 8 EiB
- Maximum file system size: 8 EiB
- Excellent scalability for large systems
- Allocation groups for parallel operations
- Online resizing (growth only)
- Advanced quota management
- Real-time subvolume support

### Btrfs (B-tree File System)

Btrfs is a modern copy-on-write file system with advanced features like snapshots, compression, and built-in RAID capabilities.

**Key points** for Btrfs:

- Copy-on-write semantics
- Built-in snapshots and cloning
- Transparent compression (LZO, ZLIB, ZSTD)
- Self-healing with checksums
- Built-in RAID 0, 1, 5, 6, 10 support
- Online resizing (both grow and shrink)
- Subvolumes for flexible organization

### Other Notable File Systems

- **ZFS**: Advanced features with built-in volume management [Unverified availability on all Linux distributions]
- **ReiserFS**: Efficient for small files, less commonly used
- **JFS**: IBM's journaled file system
- **F2FS**: Flash-friendly file system for SSDs

### File System Creation (mkfs)

### Basic mkfs Usage

The `mkfs` command creates file systems on block devices:

```bash
# General syntax
mkfs.TYPE /dev/device

# Create ext4 file system
mkfs.ext4 /dev/sdb1

# Create XFS file system
mkfs.xfs /dev/sdb1

# Create Btrfs file system
mkfs.btrfs /dev/sdb1
```

### ext4 Creation Options

```bash
# Basic ext4 creation
mkfs.ext4 /dev/sdb1

# With custom label
mkfs.ext4 -L "DataDisk" /dev/sdb1

# Specify block size
mkfs.ext4 -b 4096 /dev/sdb1

# Set reserved blocks percentage
mkfs.ext4 -m 1 /dev/sdb1

# Create with specific inode count
mkfs.ext4 -N 1000000 /dev/sdb1
```

### XFS Creation Options

```bash
# Basic XFS creation
mkfs.xfs /dev/sdb1

# Force creation (overwrites existing)
mkfs.xfs -f /dev/sdb1

# Set block size
mkfs.xfs -b size=4096 /dev/sdb1

# Configure allocation groups
mkfs.xfs -d agcount=8 /dev/sdb1

# Enable real-time subvolume
mkfs.xfs -r rtdev=/dev/sdc1 /dev/sdb1
```

### Btrfs Creation Options

```bash
# Basic Btrfs creation
mkfs.btrfs /dev/sdb1

# Create with label
mkfs.btrfs -L "BtrfsVolume" /dev/sdb1

# Multi-device Btrfs
mkfs.btrfs /dev/sdb1 /dev/sdc1

# RAID configuration
mkfs.btrfs -d raid1 -m raid1 /dev/sdb1 /dev/sdc1

# Set node size
mkfs.btrfs -n 16384 /dev/sdb1
```

### File System Checking (fsck)

### General fsck Usage

File system checking identifies and repairs file system inconsistencies:

```bash
# Check file system automatically
fsck /dev/sdb1

# Force check even if clean
fsck -f /dev/sdb1

# Check without making changes
fsck -n /dev/sdb1

# Automatically repair errors
fsck -y /dev/sdb1
```

### ext4 Checking (e2fsck)

```bash
# Check ext4 file system
e2fsck /dev/sdb1

# Force full check
e2fsck -f /dev/sdb1

# Check and show progress
e2fsck -C 0 /dev/sdb1

# Check bad blocks during scan
e2fsck -c /dev/sdb1

# Comprehensive check with bad block scan
e2fsck -cfv /dev/sdb1
```

### XFS Checking (xfs_check/xfs_repair)

```bash
# Check XFS file system (read-only)
xfs_check /dev/sdb1

# Repair XFS file system
xfs_repair /dev/sdb1

# No-modify mode (check only)
xfs_repair -n /dev/sdb1

# Verbose repair
xfs_repair -v /dev/sdb1

# Force repair even if dirty
xfs_repair -L /dev/sdb1
```

### Btrfs Checking (btrfs check)

```bash
# Check Btrfs file system
btrfs check /dev/sdb1

# Read-only check
btrfs check --readonly /dev/sdb1

# Repair mode (use with caution)
btrfs check --repair /dev/sdb1

# Check and show progress
btrfs check --progress /dev/sdb1
```

### Automated Checking

File systems can be configured for periodic checking:

```bash
# Set maximum mount count for ext4
tune2fs -c 20 /dev/sdb1

# Set check interval
tune2fs -i 30d /dev/sdb1

# View current settings
tune2fs -l /dev/sdb1 | grep -i check
```

### File System Properties

### Viewing File System Information

```bash
# Show file system type
df -T

# Display detailed file system info
lsblk -f

# Show mounted file systems
mount | column -t

# Block device information
blkid /dev/sdb1
```

### ext4 Properties

```bash
# View ext4 properties
tune2fs -l /dev/sdb1

# Key information displayed:
# - Block size and count
# - Inode size and count
# - Reserved blocks
# - Last mount/check times
# - UUID and label
```

**Example** ext4 property output:

```
Block count:              2621440
Block size:               4096
Reserved block count:     131072
Free blocks:              2489256
Free inodes:              655350
```

### XFS Properties

```bash
# Show XFS information
xfs_info /dev/sdb1

# Display XFS statistics
xfs_db -r -c "sb 0" -c "print" /dev/sdb1

# Growth information
xfs_growfs -n /mount/point
```

### Btrfs Properties

```bash
# Show Btrfs file system info
btrfs filesystem show

# Detailed usage statistics
btrfs filesystem usage /mount/point

# Device information
btrfs device stats /mount/point

# Subvolume listing
btrfs subvolume list /mount/point
```

### Performance Properties

### I/O Scheduler Configuration

```bash
# View current I/O scheduler
cat /sys/block/sdb/queue/scheduler

# Change I/O scheduler
echo mq-deadline > /sys/block/sdb/queue/scheduler
```

### Mount Options Impact

Performance-related mount options:

**ext4**:

- `noatime`: Disable access time updates
- `data=writeback`: Fastest journaling mode
- `barrier=0`: Disable write barriers [Inference: May improve performance but reduces data safety]

**XFS**:

- `noatime`: Disable access time updates
- `largeio`: Optimize for large I/O operations
- `swalloc`: Stripe-width allocation

**Btrfs**:

- `compress=zstd`: Enable compression
- `space_cache=v2`: Improved space caching
- `ssd`: SSD optimizations

### Capacity and Usage Properties

```bash
# Show space usage
df -h /mount/point

# Show inode usage
df -i /mount/point

# Detailed directory usage
du -sh /mount/point/*

# Btrfs specific usage
btrfs filesystem df /mount/point
```

### Security Properties

File system security features:

- **Extended Attributes**: Support for SELinux, ACLs
- **Encryption**: [Unverified: Varies by file system and kernel version]
- **Quotas**: User and group disk quotas
- **Permissions**: POSIX permissions and ACLs

### Maintenance Properties

**Key points** for ongoing maintenance:

- **Fragmentation**: ext4 supports online defragmentation with `e4defrag`
- **Resizing**: Online resizing capabilities vary by file system
- **Snapshots**: Btrfs provides built-in snapshot functionality
- **Scrubbing**: Btrfs offers data scrubbing to detect corruption

**Next steps**: Consider exploring advanced topics like LVM integration, RAID configurations, file system encryption, and performance tuning for specific workloads.

---

