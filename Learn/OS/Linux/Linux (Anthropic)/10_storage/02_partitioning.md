## Partitioning


### Understanding Disk Partitioning

Disk partitioning divides physical storage devices into logical sections called partitions. Each partition functions as a separate storage unit with its own filesystem. Linux supports multiple partitioning schemes, with Master Boot Record (MBR) and GUID Partition Table (GPT) being the most common.

MBR supports up to four primary partitions on disks up to 2TB, while GPT supports virtually unlimited partitions on disks larger than 2TB. Modern systems typically use GPT for its enhanced features and larger capacity support.

### fdisk Usage

The fdisk utility manages MBR and GPT partition tables through an interactive command-line interface. It operates directly on disk devices and requires root privileges.

#### Basic fdisk Operations

To launch fdisk on a specific device:
```bash
sudo fdisk /dev/sda
```

**Key Points:**
- fdisk operates in interactive mode with single-letter commands
- Changes remain in memory until explicitly written with 'w'
- Use 'q' to quit without saving changes
- Use 'p' to print current partition table

#### Essential fdisk Commands

Within fdisk's interactive prompt:
- `p` - Print partition table
- `n` - Create new partition
- `d` - Delete partition
- `t` - Change partition type
- `l` - List known partition types
- `w` - Write changes and exit
- `q` - Quit without saving
- `m` - Display help menu

#### Creating Partitions with fdisk

When creating a new partition with 'n':
1. Choose partition type (primary or extended for MBR)
2. Select partition number
3. Specify first sector (default recommended for alignment)
4. Specify last sector or size (+2G for 2GB partition)

**Example workflow:**
```
Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical drives)
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-20971519, default 2048): [Enter]
Last sector, +sectors or +size{K,M,G,T,P} (2048-20971519, default 20971519): +5G
```

### parted for GPT

The parted utility provides more advanced partitioning capabilities and better GPT support compared to fdisk. It can operate in both interactive and command-line modes.

#### parted Interactive Mode

Launch parted interactively:
```bash
sudo parted /dev/sda
```

#### parted Command-line Mode

Execute single commands directly:
```bash
sudo parted /dev/sda print
sudo parted /dev/sda mklabel gpt
sudo parted /dev/sda mkpart primary ext4 1MiB 1GiB
```

#### Essential parted Commands

- `print` or `p` - Display partition table
- `mklabel` - Create new partition table (gpt or msdos)
- `mkpart` - Create new partition
- `rm` - Remove partition
- `resizepart` - Resize existing partition
- `align-check` - Check partition alignment
- `quit` - Exit parted

#### GPT Partition Creation with parted

Creating GPT partitions requires specifying partition name, filesystem type, start position, and end position:

```bash
sudo parted /dev/sda mklabel gpt
sudo parted /dev/sda mkpart boot fat32 1MiB 513MiB
sudo parted /dev/sda mkpart root ext4 513MiB 100%
```

**Key Points:**
- GPT partitions can have descriptive names
- Filesystem type is metadata only; actual formatting occurs separately
- Positions can be specified in various units (MiB, GiB, %, sectors)

### Partition Creation and Deletion

#### Creation Considerations

Before creating partitions:
- Backup important data
- Understand the target system's requirements
- Plan partition sizes and filesystem types
- Consider future expansion needs

#### Deletion Process

Partition deletion removes the partition entry from the partition table but doesn't immediately overwrite data on the disk.

**fdisk deletion:**
```
Command (m for help): d
Partition number (1-4, default 4): 2
```

**parted deletion:**
```bash
sudo parted /dev/sda rm 2
```

**Key Points:**
- Deleted partition data may be recoverable until overwritten
- Always verify partition numbers before deletion
- Consider using secure deletion tools for sensitive data

### Partition Alignment

Proper partition alignment ensures optimal performance by aligning partitions with underlying storage device characteristics.

#### Why Alignment Matters

Modern storage devices use 4096-byte (4KB) physical sectors while maintaining 512-byte logical sectors for compatibility. Misaligned partitions cause read-modify-write operations, significantly impacting performance.

SSDs have additional alignment requirements based on erase block sizes, typically 128KB to 2MB.

#### Default Alignment

Modern partitioning tools automatically align partitions:
- fdisk aligns to 2048-sector (1MiB) boundaries by default
- parted uses optimal alignment based on device topology

#### Checking Alignment

Verify partition alignment with parted:
```bash
sudo parted /dev/sda align-check optimal 1
```

Check alignment manually by examining start sectors:
```bash
sudo fdisk -l /dev/sda
```

Partitions starting at multiples of 2048 sectors (1MiB) are typically well-aligned.

#### Manual Alignment

For custom alignment requirements:

**fdisk:** Accept default start sectors or specify aligned values
**parted:** Use specific start positions aligned to requirements

```bash
sudo parted /dev/sda mkpart primary ext4 2MiB 1026MiB
```

**Key Points:**
- 1MiB (2048 sectors) alignment works for most devices
- SSD alignment may require larger boundaries
- Misalignment can reduce performance by 20-50%
- Modern tools handle alignment automatically in most cases

### Verification and Troubleshooting

After partitioning operations:

1. Verify partition table consistency:
```bash
sudo fdisk -l /dev/sda
sudo parted /dev/sda print
```

2. Check filesystem detection:
```bash
lsblk -f
```

3. Update kernel partition table:
```bash
sudo partprobe /dev/sda
```

**Key Points:**
- Always verify changes before proceeding with filesystem creation
- Kernel may require notification of partition table changes
- Some operations may require system reboot to take effect

---

