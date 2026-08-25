## Filesystem Types and Partitioning Schemes


### Filesystem Types

#### Ext4

**Overview**: Ext4 is a journaling filesystem known for its performance and reliability, featuring added metadata and checksums. It is an extent-based filesystem that describes long, physically contiguous files in a single inode pointer entry, reducing pointer numbers and minimizing fragmentation.[1]

**Key Features**:

*   Extent-based structure for efficient file storage[1]
*   Delayed allocation allowing filesystem to collect data before allocating disk space[1]
*   Journaling for data integrity protection[1]
*   Added metadata and checksums for reliability[1]
*   Backward compatibility with older ext3 and ext2 filesystems[1]

**Advantages**: Ext4 is simpler than modern alternatives, more performant in many scenarios, and well-tested across countless systems. It requires minimal configuration and provides predictable behavior.[2][3][4]

**Limitations**: Lacks advanced features such as snapshots, dynamic multidevice management, copy-on-write optimization, and deduplication. Data recovery mechanisms are limited compared to newer filesystems.[2][1]

**Ideal Use Cases**: General-purpose systems prioritizing stability and performance, systems requiring minimal filesystem management, and users preferring proven, straightforward solutions.[3][4]

#### Btrfs

**Overview**: Btrfs (B-tree filesystem) is a modern, copy-on-write (COW) filesystem focusing on ease of repair and administration. It uses B-trees for internal file structure storage enabling efficient file processing. Btrfs eliminates data corruption risks through checksums and integrity mechanisms.[5][1]

**Key Features**:

*   Copy-on-write architecture for data integrity[1]
*   Dynamic inode allocation allowing unlimited files until storage exhaustion[1]
*   Subvolumes providing flexible, non-fixed-size filesystem divisions[6]
*   Snapshots enabling filesystem state captures for each subvolume independently[6][2]
*   Multi-device management supporting RAID-like configurations[2]
*   File compression capabilities[1]
*   Deduplication for removing duplicate data[1]
*   Checksums and built-in error detection preventing data corruption[1]
*   Enormous file size support up to 2^64 bytes[1]

**Subvolumes**: Unlike partitions with fixed sizes, subvolumes are flexible and can be snapshotted individually. Common subvolume arrangements for Arch include `@` (root), `@home` (home directory), `@var_log` (`/var/log`), `@var_pkg` (`/var/cache/pacman/pkg`), and `@.snapshots` for storing snapshots.[6]

**Advantages**: Btrfs offers advanced features including snapshots, multidevice support, compression, and superior error detection. Administrators gain powerful tools for system management and recovery.[3][5][2][1]

**Limitations**: Btrfs requires learning complex feature management. All features must be individually enabled and configured; the filesystem does not automatically use capabilities like compression or deduplication without explicit configuration. Stability concerns existed in earlier development stages, though recent versions have matured considerably.[3][2]

**Ideal Use Cases**: Systems requiring snapshots for system backups, advanced storage management with multiple devices, data deduplication scenarios, and users willing to invest time learning advanced features.[4][2][3]

#### XFS

**Overview**: XFS is a high-performance, 64-bit journaling filesystem originally developed by Silicon Graphics. It supports large files and filesystems.[4]

**Key Features**: Extent-based allocation similar to ext4, journaling for metadata integrity, and support for large files and partitions.[4]

**Use Cases**: Enterprise systems, high-performance environments, and systems processing large files.[4]

### Partitioning Schemes

#### Master Boot Record (MBR)

**Definition**: MBR is an older partitioning scheme consisting of information to load the operating system and locate storage partitions. It represents the first sector of the storage medium and uses 32-bit logical block addressing.[7]

**Characteristics**:

*   **Disk Capacity**: Limited to 2 TB maximum[8][7]
*   **Partition Support**: Up to 4 primary partitions (or 3 primary plus 1 extended, requiring extended partitions for more partitions)[7][8]
*   **Boot Mechanism**: Master Boot Program stored in the first sector[7]
*   **Data Integrity**: No built-in error detection mechanism, increasing corruption risk[8][7]
*   **Firmware Compatibility**: Compatible with legacy BIOS systems[8][7]

**Limitations**: The 2 TB size limitation makes MBR unsuitable for modern large storage devices. Limited partition support requires workarounds through extended partitions. Absence of error detection leaves systems vulnerable to data corruption.[7][8]

**Use Cases**: Legacy systems without UEFI support, small drives under 2 TB, and simple configurations requiring three or fewer partitions.[8]

#### GUID Partition Table (GPT)

**Definition**: GPT is a modern partitioning scheme using 64-bit logical block addressing supporting partitions of 128 bytes per unit, enabling handling of storage beyond 2 TB. It uses a special EFI partition for operating system loading.[7]

**Characteristics**:

*   **Disk Capacity**: Theoretically supports up to 9.4 zettabytes[8][7]
*   **Partition Support**: Up to 128 primary partitions (OS-dependent) without extended partition requirements[7][8]
*   **Boot Mechanism**: Special EFI partition for OS loading[7]
*   **Data Integrity**: Built-in CRC-32 error detection mechanism[8][7]
*   **Redundancy**: Backup partition table stored at disk end enabling recovery from corruption[8][7]
*   **Firmware Compatibility**: Fully supports UEFI-based modern systems[7][8]

**Advantages**: GPT's 64-bit addressing handles massive storage devices, supports numerous partitions without extended partition workarounds, provides robust error detection through CRC checks, and includes partition table redundancy for recovery. Modern systems universally support GPT.[8][7]

**Use Cases**: UEFI-based modern hardware, storage devices exceeding 2 TB, systems requiring many partitions, and scenarios prioritizing data protection.[8]

### Filesystem and Partitioning Selection

| Aspect | Ext4 | Btrfs | XFS |
|--------|------|-------|-----|
| **Type** | Journaling [1] | Copy-on-Write [1] | Journaling [4] |
| **Complexity** | Simple [3] | Complex [3] | Moderate [4] |
| **Snapshots** | No [2] | Yes [2] | Limited [4] |
| **Deduplication** | No [1] | Yes [1] | No [4] |
| **Multi-device** | No [2] | Yes [2] | No [4] |
| **Performance** | Excellent [2] | Good [2] | Excellent [4] |
| **Learning Curve** | Minimal [3] | Steep [3] | Moderate [4] |

| Aspect | MBR | GPT |
|--------|-----|-----|
| **Maximum Size** | 2 TB [7] | 9.4 ZB [7] |
| **Partitions** | 4 primary [8] | 128 primary [8] |
| **Error Detection** | None [7] | CRC-32 [7] |
| **UEFI Support** | Limited [8] | Full [8] |
| **Firmware** | Legacy BIOS [7] | UEFI [7] |

**Recommendation for Arch**: Modern Arch installations should use GPT for partitioning. For filesystems, ext4 provides stability for straightforward setups, while Btrfs offers advanced features for users investing time in learning its capabilities.[3][4][7][8]

Sources
[1] Difference Between Ext4 VS Btrfs Filesystems in Linux https://www.geeksforgeeks.org/linux-unix/difference-between-ext4-vs-btrfs-filesystems-in-linux/
[2] BTRFS or Ext4? : r/archlinux https://www.reddit.com/r/archlinux/comments/1ahhom8/btrfs_or_ext4/
[3] Is btrfs better than ext4 and is it good to use it with Arch ... https://bbs.archlinux.org/viewtopic.php?id=262895
[4] BTRFS, XFS and EXT4 Arch Linux Install Guide https://gist.github.com/dante-robinson/fdc55726991d3f17e0dbef1701d343ef
[5] BTRFS or EXT4? - Issues & Assistance https://forum.garudalinux.org/t/btrfs-or-ext4/36978
[6] How to Setup Arch Linux With Btrfs and (almost) Full Disk ... https://veprogames.github.io/posts/how-to-setup-arch-linux-with-btrfs-and-fde/
[7] MBR v/s GPT Partition in OS https://www.geeksforgeeks.org/operating-systems/mbr-vs-gpt-partition-in-os/
[8] MBR vs GPT: Understanding Disk Partitioning Schemes https://codefinity.com/blog/MBR-vs-GPT:-Understanding-Disk-Partitioning-Schemes
[9] File systems - ArchWiki https://wiki.archlinux.org/title/File_systems
[10] should i choose mbr or gpt when installing ubuntu https://www.reddit.com/r/linux4noobs/comments/nltav1/should_i_choose_mbr_or_gpt_when_installing_ubuntu/

