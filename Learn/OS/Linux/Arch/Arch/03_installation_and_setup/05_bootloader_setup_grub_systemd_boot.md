## Bootloader Setup (GRUB, systemd-boot)


### GRUB (GRand Unified Bootloader)

**Overview**: GRUB is the traditional, versatile bootloader supporting both legacy BIOS and UEFI systems. It provides a comprehensive boot menu and configuration system.[1][2]

#### GRUB Installation (UEFI)

**Package Installation**: `pacman -S grub efibootmgr`.[2][1]

**Parameters**:
*   **`grub`**: The bootloader package[1]
*   **`efibootmgr`**: Utility for managing UEFI boot entries[1]

**GRUB Installation Command**: `grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB`.[3][1]

**Parameters**:
*   **`--target=x86_64-efi`**: Specifies UEFI installation for 64-bit x86 systems[1]
*   **`--efi-directory=/boot`**: Location of the EFI System Partition[3][1]
*   **`--bootloader-id=GRUB`**: Identifier for the UEFI boot entry[1]

#### Configuration File Generation

**Generate Configuration**: `grub-mkconfig -o /boot/grub/grub.cfg`.[2][1]

This command automatically detects installed operating systems and generates boot menu entries. Warnings during generation can typically be ignored.[2][1]

#### GRUB Configuration (Optional)

**Configuration File**: `/etc/default/grub` allows customization of GRUB behavior.[3]

Common customizations include:
*   `GRUB_TIMEOUT`: Menu timeout in seconds[3]
*   `GRUB_DEFAULT`: Default boot entry[3]
*   `GRUB_THEME`: Visual theme[3]

After modifying `/etc/default/grub`, regenerate the configuration with `grub-mkconfig -o /boot/grub/grub.cfg`.[3]

#### GRUB Installation (BIOS/Legacy)

**BIOS Installation**: `grub-install --target=i386-pc /dev/sdX`, where `/dev/sdX` is the target disk (not a partition).[1]

### Systemd-boot

**Overview**: Systemd-boot is a modern, UEFI-only bootloader included with systemd. It provides a lightweight, simple boot interface optimized for modern systems. Systemd-boot boots faster than GRUB and requires minimal configuration.[4][5][3]

**Requirements**: Systemd-boot requires UEFI firmware and cannot be used with BIOS systems.[5][4]

#### Installation

**Installation Command**: `bootctl install`.[6][4][5]

This command installs systemd-boot to the EFI System Partition (ESP) and creates necessary directories.[4][5]

**Verification**: Check installation status with `bootctl status`.[4][3]

**UEFI Boot Entry**: After installation, `efibootmgr --verbose` displays boot entries; "Linux Boot Manager" should appear.[3]

#### Loader Configuration

**Main Configuration File**: `/boot/loader/loader.conf`.[6][5]

**Basic Configuration**:
```
default arch
timeout 3
```

**Parameters**:
*   **`default`**: Default boot entry identifier (should match entry filename without `.conf`)[5][6]
*   **`timeout`**: Seconds before default entry auto-boots[6][5]

#### Boot Entries

**Entry Storage**: Boot entries are stored in `/boot/loader/entries/`.[4][6]

**Entry File Format**: Create `arch.conf` with the following structure:[5][6]

```
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root=PARTUUID=<PARTUUID> rw
```

**Entry Parameters**:
*   **`title`**: Display name in boot menu[6]
*   **`linux`**: Kernel image path[6]
*   **`initrd`**: Initial RAM disk files; multiple `initrd` lines specify microcode updates (optional)[5][6]
*   **`options`**: Kernel parameters including `root` partition identifier[5][6]

#### Finding PARTUUID

**Method**: Use `blkid` to identify partition UUIDs.[7][6][5]

`blkid` output displays `PARTUUID=` values for each partition. Alternatively, in vim, use `:r !blkid` to insert output directly into the configuration file.[6][5]

#### Optional Fallback Entry

**Fallback Configuration**: Create `/boot/loader/entries/arch-fallback.conf` for system recovery:[8][7]

```
title Arch Linux (Fallback Initramfs)
linux /vmlinuz-linux
initrd /initramfs-linux-fallback.img
options root=PARTUUID=<PARTUUID> rw
```

This entry boots with a minimal fallback initramfs when the primary entry fails.[8][7]

#### Automated Kernel Entry Management

**Kernel-Install Tool**: The `kernel-install` tool (part of systemd) automates boot entry generation.[8]

**Command**: `kernel-install add KERNEL-VERSION KERNEL-IMAGE`.[8]

**Kernel Parameters File**: Define kernel parameters in `/etc/kernel/cmdline`:[8]

```
echo "root=PARTUUID=<PARTUUID> rw" > /etc/kernel/cmdline
```

**Pacman Hooks**: Install `pacman-hook-kernel-install` from the AUR to automatically update boot entries when kernels are installed or updated. This eliminates manual entry management.[8]

### Comparison and Selection

| Aspect | GRUB | Systemd-boot |
|--------|------|--------------|
| **Firmware** | BIOS and UEFI [1] | UEFI only [4] |
| **Boot Speed** | Slower [5] | Faster [5] |
| **Configuration** | Complex `/etc/default/grub` [1] | Simple text files [5] |
| **Menu Generation** | Automatic via `grub-mkconfig` [1] | Manual entry creation [4] |
| **Flexibility** | Highly configurable [1] | Minimal but sufficient [5] |
| **Learning Curve** | Steep [3] | Minimal [5] |
| **Community Support** | Extensive [1] | Growing [5] |
| **Multi-OS Booting** | Excellent detection [1] | Requires manual entries [4] |
| **Installation Time** | Longer [5] | Quick [5] |
| **Post-Install Changes** | Requires `grub-mkconfig` regeneration [1] | Direct file editing [4] |

### Installation Troubleshooting

**Systemd-boot Boot Issues**: Ensure kernel and initramfs files exist in `/boot` (not subdirectories). Verify `PARTUUID` values in entry files. Use `bootctl status` to diagnose file location problems.[8][6][3]

**GRUB Boot Menu Issues**: Verify EFI partition is mounted at `/boot` or `/boot/efi`. Regenerate configuration with `grub-mkconfig -o /boot/grub/grub.cfg` after changes.[1][3]

**Switching Bootloaders**: Remove the old bootloader package and entries before installing a new one. For example, when switching from GRUB to systemd-boot: `pacman -Rcnsu grub && rm -rf /boot/grub`.[3]

Sources
[1] GRUB - ArchWiki https://wiki.archlinux.org/title/GRUB
[2] ArchLinux Installation Guide https://gist.github.com/varunagrawal/d27eded739f59228eaf3b746907c6a64
[3] Replacing grub by systemd-boot on Arch Linux (efi boot) https://www.hydrus.org.uk/journal/arch-grub.html
[4] systemd-boot - ArchWiki https://wiki.archlinux.org/title/Systemd-boot
[5] Use systemd-boot instead of grub in Arch Linux https://www.tsunderechen.io/2020/05/archlinux-systemd-boot-installation/
[6] [Solved] How-To replace GRUB boot loader with systemd ... https://bbs.archlinux.org/viewtopic.php?id=223909
[7] Setting Up Systemd-Boot on Arch Linux - Hidden Wonders https://hiddenwonders.xyz/setting-up-systemd-boot-on-arch-linux/
[8] Need help Installing Arch with Systemd-boot : r/archlinux https://www.reddit.com/r/archlinux/comments/v0bizx/need_help_installing_arch_with_systemdboot/
[9] Arch Linux Installation: Installing a bootloader - systemd-boot https://www.youtube.com/watch?v=8Lp2EQMsmL4
[10] Arch Linux Installation: Easy Step-by-Step Guide https://linuxconfig.org/arch-linux-installation-easy-step-by-step-guide

