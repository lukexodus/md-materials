## Storage Concepts


### Block Devices vs Files

Linux treats storage through two fundamental abstractions that determine how data is accessed and managed at different system levels.

**Block devices** represent physical or logical storage units that handle data in fixed-size blocks, typically 512 bytes or larger. The kernel communicates with these devices through block-oriented operations, where data transfers occur in chunks rather than individual bytes. Examples include hard drives (/dev/sda), SSDs (/dev/nvme0n1), USB drives (/dev/sdb), and CD-ROMs (/dev/sr0). Block devices support random access, meaning the system can read or write any block without processing preceding blocks sequentially.

**Files** provide the user-space abstraction layer that applications interact with. When a program reads or writes a file, the kernel translates these operations into appropriate block device interactions through the file system layer. This abstraction allows applications to work with named, hierarchical storage without understanding underlying hardware specifics.

The relationship between these concepts involves multiple layers: applications work with files and directories, file systems organize data into logical structures, and block devices provide the physical storage medium. Device mapper and LVM can create additional abstraction layers between file systems and physical devices.

**Key points:**

- Block devices handle raw storage at the hardware level
- Files provide organized, named access to data
- File systems bridge the gap between user-space files and block-level storage
- Both abstractions can coexist - you can access raw block devices directly or through file system interfaces

### Storage Device Identification

Linux employs multiple naming schemes and identification methods to uniquely identify storage devices across system reboots and hardware changes.

**Traditional naming** uses device files in /dev with predictable patterns. SATA and SCSI devices appear as /dev/sd[a-z], where the letter indicates discovery order. NVMe devices use /dev/nvme[0-9]n[0-9] format, with the first number representing the controller and the second the namespace. IDE devices (largely obsolete) used /dev/hd[a-d] naming.

**Persistent identification** addresses the limitation that traditional names can change between boots if hardware configuration changes. The system creates symbolic links in several /dev subdirectories:

- /dev/disk/by-uuid/ contains links using file system UUIDs
- /dev/disk/by-label/ uses file system labels
- /dev/disk/by-id/ employs hardware serial numbers and model information
- /dev/disk/by-path/ reflects the hardware connection path
- /dev/disk/by-partuuid/ uses partition table UUIDs (GPT)

**udev** generates these persistent identifiers by examining device properties and creating appropriate symbolic links. The /etc/fstab file commonly uses UUIDs or labels instead of traditional device names to ensure reliable mounting across hardware changes.

**Examples:**

```
/dev/sda1 → /dev/disk/by-uuid/550e8400-e29b-41d4-a716-446655440000
/dev/nvme0n1p2 → /dev/disk/by-label/root-filesystem
```

**lsblk**, **blkid**, and **fdisk -l** commands provide comprehensive device identification information, showing relationships between physical devices, partitions, and file systems.

### Partition Tables (MBR, GPT)

Partition tables define how storage devices are divided into logical sections, each capable of containing a file system or serving specific purposes.

**Master Boot Record (MBR)** represents the traditional partitioning scheme used since the 1980s. The MBR occupies the first 512 bytes of a storage device, containing both the partition table and boot code. This scheme supports up to four primary partitions, with the option to designate one as an extended partition containing multiple logical partitions. MBR limitations include a maximum addressable storage capacity of 2TB and partition size restrictions that make it unsuitable for modern large drives.

The MBR structure includes:

- 446 bytes of boot code
- 64 bytes for the partition table (4 entries × 16 bytes each)
- 2 bytes for the boot signature (0x55AA)

**GUID Partition Table (GPT)** provides a modern alternative that addresses MBR limitations. GPT supports up to 128 partitions by default (expandable), handles drives larger than 2TB (up to 9.4ZB theoretically), and includes redundancy through backup partition tables. Each partition receives a unique GUID identifier, and GPT includes CRC32 checksums for data integrity verification.

GPT structure spans multiple sectors:

- Protective MBR (sector 0) for backward compatibility
- Primary GPT header (sector 1)
- Partition entry array (sectors 2-33 typically)
- User data partitions
- Backup partition entry array
- Secondary GPT header (last sector)

**UEFI firmware** requires GPT for booting on systems larger than 2TB, while BIOS systems can boot from either MBR or GPT (with BIOS boot partition). The choice between MBR and GPT depends on system requirements, storage capacity, and firmware type.

**Key points:**

- MBR suits smaller drives and older systems with 4-partition limitations
- GPT provides modern features, larger capacity support, and improved reliability
- Protective MBR in GPT prevents older tools from corrupting the partition table
- Conversion between MBR and GPT possible but requires careful planning

### File System Concepts

File systems organize data on storage devices into logical structures that provide naming, hierarchy, permissions, and metadata management.

**Hierarchical organization** forms the foundation of Unix-like file systems, starting from a root directory (/) and branching into subdirectories. This tree structure allows logical organization of files and directories with absolute paths (starting from /) and relative paths (from current location).

**Inodes** serve as the fundamental data structure in most Linux file systems, containing metadata about files and directories including permissions, ownership, timestamps, size, and pointers to data blocks. Each file system has a fixed number of inodes created during formatting, which can limit the total number of files regardless of available space.

**File system types** offer different features and performance characteristics:

**ext4** provides the default file system for many Linux distributions, supporting files up to 16TB, volumes up to 1EB, journaling for crash recovery, and backward compatibility with ext2/ext3. It includes features like delayed allocation, multiblock allocation, and online defragmentation.

**XFS** excels with large files and high-performance requirements, supporting files up to 8EB and volumes up to 8EB. Originally developed by Silicon Graphics, XFS provides excellent scalability for enterprise workloads and handles parallel I/O operations efficiently.

**Btrfs** offers advanced features including built-in RAID, snapshots, compression, and copy-on-write semantics. While feature-rich, Btrfs stability varies across different use cases, with some features considered experimental.

**ZFS** (through OpenZFS) combines file system and volume manager functionality, providing data integrity verification, automatic repair, snapshots, and advanced RAID capabilities. ZFS requires significant RAM for optimal performance.

**File system journaling** protects against data corruption during unexpected shutdowns by logging intended changes before executing them. This allows recovery tools to complete or roll back incomplete operations during system restart.

**Mount points** integrate different file systems into the unified directory hierarchy. The mount command attaches file systems to specific directory locations, while /etc/fstab defines automatic mounting during boot.

**Key points:**

- File systems provide logical organization above raw block storage
- Inode limitations can restrict file count regardless of available space
- Different file systems optimize for various use cases (performance, features, reliability)
- Journaling provides crash recovery but adds overhead
- Mount points allow multiple file systems to appear as one unified hierarchy

**Examples:**

```bash
# View file system usage
df -h

# Show inode usage
df -i

# List file system types
lsblk -f

# Mount a file system
mount /dev/sda1 /mnt/data
```

Understanding these storage concepts enables effective system administration, troubleshooting storage issues, and making informed decisions about partitioning and file system selection based on specific requirements.

---

