## Disk Partitioning


### Partitioning Tools Overview

Arch Linux provides multiple partitioning tools optimized for different partition table formats and user preferences. Each tool offers distinct user interfaces and capabilities suitable for various use cases.[1][2][3][4]

### fdisk (util-linux)

**Overview**: Fdisk is a dialogue-driven command-line utility that creates and manipulates partition tables and partitions on a hard disk. It is part of the util-linux package, included as a dependency of the base meta package. Fdisk supports both MBR and GPT partition tables since util-linux 2.23.[2]

**User Interface**: Fdisk operates in interactive dialogue mode, displaying a command prompt where users enter single-letter commands. This text-mode interface requires keyboard navigation.[4]

**Key Commands**:

*   **`fdisk -l [device]`**: Lists partition tables and partitions on a specified block device. Example: `fdisk -l /dev/sda`.[2]
*   **`fdisk [device]`**: Launches interactive mode for the specified device.[4]
*   **`m`**: Displays available commands within fdisk.[4]
*   **`n`**: Creates a new partition, prompting for partition number, first sector, and size.[4]
*   **`t`**: Changes a partition's type, such as converting to Linux filesystem or EFI.[4]
*   **`p`**: Prints the current partition table in memory.[4]
*   **`w`**: Writes changes to disk.[4]
*   **`q`**: Quits without saving.[4]

**Backup Capability**: Fdisk allows partition table backup using `sfdisk` utility with the `-d`/`--dump` option. This enables restoring the same partition layout to multiple drives.[2]

**Strengths**: Fdisk is universally available, supports both MBR and GPT, and provides powerful command-line scripting via `sfdisk`.[1][2][4]

**Limitations**: The dialogue-based interface requires command memorization, and changes are held in memory until explicitly written with `w`.[2][4]

### cfdisk

**Overview**: Cfdisk provides a curses-based (terminal UI) interface for partitioning, offering a more user-friendly interactive experience compared to fdisk. It is part of the util-linux package.[1][4]

**User Interface**: Cfdisk displays partitions in a graphical format within the terminal, with menu options at the bottom for operations like creating, deleting, or modifying partitions. Navigation uses arrow keys and keyboard shortcuts.[4]

**Key Features**:

*   Visual representation of partition layout[1][4]
*   Menu-driven interface with bottom-menu guidance[4]
*   Partition type selection through dedicated menu[4]
*   Support for both MBR and GPT[1]
*   No command memorization required[4]

**Strengths**: Cfdisk's curses-based interface is more approachable for users unfamiliar with command-line dialogue systems. Visual partition representation aids understanding of layout.[1][4]

**Limitations**: Cfdisk lacks scripting capabilities compared to sfdisk, and does not provide command-line scripting for automation.[1]

### gdisk (GPT fdisk)

**Overview**: GPT fdisk is a specialized tool for GUID Partition Table (GPT) manipulation, providing gdisk (interactive), cgdisk (curses-based), and sgdisk (command-line scripting) variants. It is specifically designed for modern GPT disks rather than legacy MBR tables.[3][5]

**Key Components**:

*   **gdisk**: Interactive text-mode interface similar to fdisk[5][3]
*   **cgdisk**: Curses-based interface similar to cfdisk[3]
*   **sgdisk**: Command-line utility for scripting partition operations[3]

**Key Commands**:

*   **`gdisk -l [device]`**: Lists GPT partition information on a device.[3]
*   **`gdisk [device]`**: Launches interactive mode.[3]
*   **`sgdisk -p [device]`**: Lists partitions using sgdisk.[3]
*   **`sgdisk --backup=[filename] [device]`**: Creates a binary backup of the GPT partition table.[3]

**Backup and Recovery**: Sgdisk creates comprehensive binary backups consisting of the protective MBR, main GPT header, backup GPT header, and partition table. GPT fdisk can repair damaged GPT data structures and perform MBR-to-GPT conversions.[5][3]

**Advantages**: Gdisk specializes in GPT, providing superior support for modern partitioning schemes. Sgdisk enables automation of partition table modifications through scripting.[5][3]

**Limitations**: Gdisk is GPT-only and does not support legacy MBR partition tables.[3]

### parted

**Overview**: Parted is a disk partitioning and resizing tool that supports both MBR and GPT partition tables. It provides a non-interactive command-line interface suited for scripting.[1][4]

**User Interface**: Parted operates as a command-line utility without interactive dialogue, accepting full commands as arguments.[4]

**Command Syntax**: `parted [device] [command]`.[4]

**Key Features**:

*   Support for both MBR and GPT[1]
*   Non-interactive command-line interface optimized for scripting[1][4]
*   Partition resizing capabilities[1]
*   Logical volume management features[1]

**Strengths**: Parted's non-interactive interface makes it ideal for scripted, automated partitioning workflows. It supports both legacy and modern partition tables.[1]

**Limitations**: Parted's command-line interface is less intuitive for interactive partitioning compared to cfdisk.[4]

### Comparison and Selection

| Feature | fdisk | cfdisk | gdisk | parted |
|---------|-------|--------|-------|--------|
| **Package** | util-linux [2] | util-linux [1] | gptfdisk [1] | parted [1] |
| **MBR Support** | Yes [2] | Yes [1] | No [3] | Yes [1] |
| **GPT Support** | Yes [2] | Yes [1] | Yes [3] | Yes [1] |
| **Interactive Mode** | Dialogue-based [2] | Curses-based [4] | Dialogue-based [3] | Non-interactive [4] |
| **User-Friendly** | Moderate [2] | High [4] | Moderate [3] | Low [4] |
| **Scripting Support** | Via sfdisk [2] | No [1] | Via sgdisk [3] | Yes [1] |
| **Backup/Restore** | Yes [2] | No [1] | Yes [3] | No [1] |
| **Learning Curve** | Moderate [4] | Low [4] | Moderate [3] | Low [4] |

### GUI Alternatives

For users preferring graphical interfaces, several GUI frontends are available:[1]

*   **GParted**: Visual partition editor using parted backend; supports resizing, copying, and moving partitions[1]
*   **GNOME Disks**: GNOME utility using parted backend via udisks2[1]
*   **KDE Partition Manager**: KDE utility using sfdisk backend[1]
*   **blivet-gui**: Graphical storage configuration tool using parted backend[1]

### Practical Usage Recommendations

**Modern Systems (GPT)**: Use gdisk/cgdisk for GPT partitions or cfdisk for broader compatibility. For scripting, use sgdisk.[3][1]

**Legacy Systems (MBR)**: Use fdisk or cfdisk for MBR partitions.[2][1]

**Scripting and Automation**: Use sfdisk with fdisk, sgdisk with gdisk, or parted for non-interactive automation.[2][3][1]

**Interactive Beginner**: Use cfdisk for its visual, menu-driven interface.[4]

**Backup Requirements**: Use fdisk with sfdisk or gdisk with sgdisk for partition table backup and restore capabilities.[2][3]

Sources
[1] Partitioning - ArchWiki https://wiki.archlinux.org/title/Partitioning
[2] fdisk - ArchWiki https://wiki.archlinux.org/title/Fdisk
[3] GPT fdisk - ArchWiki https://wiki.archlinux.org/title/GPT_fdisk
[4] Use fdisk, cfdisk & sfdisk on Linux https://linuxconfig.org/how-to-manipulate-partition-tables-with-fdisk-cfdisk-and-sfdisk-on-linux
[5] gdisk | Kali Linux Tools https://www.kali.org/tools/gdisk/
[6] Do you prefer cfdisk or fdisk, why? : r/archlinux https://www.reddit.com/r/archlinux/comments/1ewuyrv/do_you_prefer_cfdisk_or_fdisk_why/

