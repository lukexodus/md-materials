## Boot Modes (BIOS/UEFI) and Implications


### BIOS (Basic Input/Output System)

**Overview**: BIOS is the older firmware interface that has been the primary boot mechanism for decades, dating back to 1975. It performs system initialization and loads the operating system during the boot process. BIOS stores system initialization information in a dedicated chip on the motherboard.[5][6]

**Operating Mode**: BIOS operates in **16-bit mode**, which was designed for older hardware. This legacy architecture creates inherent limitations in modern computing environments.[2][5]

**Key Characteristics**:

*   **Partitioning**: Uses 32-bit entries in its partition table, supporting up to 4 primary partitions. Partition size is limited to 2.2 TB, making BIOS unsuitable for modern large-capacity drives.[7][2][5]
*   **User Interface**: Text-based interface with keyboard-only navigation. The interface is daft and text-based, appearing less convenient for contemporary users.[6][5]
*   **Performance**: Boot times are longer due to 1MB space constraint for operation. The bootloader must be loaded separately as a distinct program before the OS loads.[5]
*   **Security**: Password protection allows system access only to authorized users. However, this protection mechanism is considered less robust than modern alternatives.[6][5]

**Storage Mechanism**: Unlike UEFI, BIOS stores boot information in firmware ROM on the motherboard, making firmware updates difficult.[2]

**Use Cases**: Legacy systems without UEFI support, older hardware, systems requiring maximum compatibility with pre-2000s infrastructure.[7][6]

### UEFI (Unified Extensible Firmware Interface)

**Overview**: UEFI is a modern firmware developed in 2002 to overcome BIOS limitations and provide better performance, security, and scalability. It stores all data about device initialization and startup in a `.efi` file kept on a special disk partition called the EFI System Partition (ESP). The ESP also contains the bootloader, making the boot process more efficient.[5][6]

**Operating Mode**: UEFI operates in **32-bit or 64-bit mode**, enabling modern computational capabilities. This advanced architecture supports contemporary hardware features and larger datasets.[2][5]

**Key Characteristics**:

*   **Partitioning**: Uses the GPT (GUID Partition Table) with 64-bit entries, supporting up to 128 physical partitions. Bootable drive size limit exceeds 9 zettabytes theoretically (~18.8 million terabytes), accommodating massive modern storage devices.[7][2][5]
*   **User Interface**: Graphical user interface (GUI) with mouse and keyboard support. The GUI provides system state overviews through graphs and charts, significantly improving user experience.[6][2][5]
*   **Performance**: Significantly faster boot times due to direct OS loading rather than separate bootloader execution. Streamlined boot process makes startup more efficient.[5][6]
*   **Security**: **Secure Boot** feature prevents computer booting from unauthorized or unsigned applications. UEFI checks signatures of boot software, drivers, and OS components to verify authenticity. This enhanced security prevents rootkits but may complicate dual-booting scenarios.[2][6][5]

**Driver Support**: UEFI provides discrete driver support with drivers stored separately from firmware, enabling easier firmware updates compared to BIOS.[2]

**Storage Mechanism**: Boot information stored in `.efi` files on the hard drive ESP partition rather than motherboard firmware, simplifying updates and modifications.[5]

### Implications for Arch Linux Installation

**Partitioning Alignment**: UEFI installations must use GPT partitioning, while BIOS installations traditionally use MBR. Arch Linux documentation recommends UEFI for modern systems.[10][7]

**Bootloader Selection**: The bootloader choice depends on the boot mode. UEFI systems typically use **systemd-boot** or **GRUB with EFI support**, while BIOS systems use **GRUB in legacy mode**. Each bootloader requires distinct installation procedures and configuration approaches.[4][10]

**EFI System Partition**: UEFI installations require a dedicated EFI System Partition (ESP) formatted with FAT32, typically mounted at `/boot` or `/efi`. BIOS installations lack this requirement, simplifying partitioning schemes.[4][7]

**Secure Boot Consideration**: UEFI's Secure Boot can prevent unsigned operating systems from booting, including Arch Linux if not properly configured. Users may need to disable Secure Boot during initial installation or configure custom certificates.[4][2][5]

**Multi-OS Compatibility**: BIOS allows straightforward multi-OS configurations without signature verification complications. UEFI Secure Boot may treat other operating systems as unauthorized applications, potentially blocking boot attempts. Disabling Secure Boot resolves this limitation.[4][6][2]

### Selection Criteria

| Aspect | BIOS | UEFI |
|--------|------|------|
| **Release Date** | 1975 [5] | 2002 [5] |
| **Operating Mode** | 16-bit [5] | 32-bit/64-bit [5] |
| **Partitioning** | MBR with 4 partitions max [5] | GPT with 128 partitions [5] |
| **Disk Size Limit** | 2.2 TB [5] | 18.8 million TB [5] |
| **Boot Time** | Longer [6] | Faster [6] |
| **User Interface** | Text-based keyboard [5] | GUI with mouse [5] |
| **Security** | Password protection [5] | Secure Boot [5] |
| **Future-Proofing** | Limited [6] | Future-forward [6] |
| **Hardware Target** | Legacy systems [7] | Modern systems [7] |

**Recommendation**: Modern Arch Linux installations should target **UEFI boot mode** to leverage contemporary hardware capabilities, improved performance, superior security features, and future compatibility. BIOS remains viable only for legacy hardware lacking UEFI support.[6][7]

Sources
[1] Can you help me understand UEFI vs. BIOS? I don't plan to ... https://www.reddit.com/r/linux4noobs/comments/ajf18w/can_you_help_me_understand_uefi_vs_bios_i_dont/
[2] UEFI vs BIOS: What's the Difference? https://www.freecodecamp.org/news/uefi-vs-bios/
[3] What is UEFI? Understanding Your PC's Core Technology https://www.hp.com/hk-en/shop/tech-takes/post/what-is-uefi
[4] Boot to UEFI Mode or Legacy BIOS mode https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/boot-to-uefi-mode-or-legacy-bios-mode?view=windows-11
[5] UEFI vs. BIOS: How Do They Differ? https://phoenixnap.com/kb/uefi-vs-bios
[6] Difference Between Basic Input/Output System (BIOS) and ... https://www.geeksforgeeks.org/computer-organization-architecture/difference-between-basic-input-output-system-bios-and-unified-extensible-firmware-interface-uefi/
[7] UEFI vs BIOS: What's the Difference? https://ultahost.com/blog/uefi-vs-bios/
[8] BIOS vs UEFI Difference | User Guide and Settings (Official ... https://www.youtube.com/watch?v=VY3flvge2X0
[9] UEFI vs Legacy BIOS: How to Choose the Best Mode for ... https://www.linkedin.com/advice/0/what-differences-between-uefi-legacy-bios-modes-skills-pc-building
[10] Installation guide - ArchWiki https://wiki.archlinux.org/title/Installation_guide


