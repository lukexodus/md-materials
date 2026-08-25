## Kernel Management and Updates


### Kernel Overview

**Purpose**: The Linux kernel manages hardware resources and enables application execution. Arch Linux provides multiple kernel options optimized for different use cases, all accessible through pacman.[1]

**Available Kernels**:[2]
- **`linux`**: Default stable kernel with latest features[2]
- **`linux-lts`**: Long-Term Support kernel for stability-focused systems[2]
- **`linux-zen`**: Community-driven kernel with performance optimizations[2]
- **`linux-hardened`**: Security-focused kernel with hardening patches[2]

### Checking Kernel Version

**Current Kernel**: `uname -r` displays the running kernel version.[1]

**Detailed Information**: `uname -a` shows comprehensive kernel details including architecture and hostname.[1]

**Installed Kernels**: `pacman -Q | grep linux` lists all installed kernel packages [1].

### Automatic Kernel Updates

**Update via pacman**: `sudo pacman -Syu` performs system-wide upgrade including kernel packages.[1]

**Automatic Process**: When a kernel package upgrades, pacman automatically triggers mkinitcpio via a hook to regenerate the initramfs.[3][4]

**Output**: The upgrade process displays `==> Building image from linux preset` confirming initramfs regeneration.[1]

### mkinitcpio (Initramfs Generation)

**Overview**: Mkinitcpio is a Bash script creating initramfs (initial RAM disk) images required for kernel startup and root filesystem mounting.[3]

**Purpose**: The initramfs bridges the boot loader and kernel, providing drivers and utilities necessary to mount the root filesystem.[3]

#### Configuration

**Configuration File**: `/etc/mkinitcpio.conf` defines hooks, modules, and options for initramfs generation.[5][3]

**Key Configuration Options**:[3]
- **`MODULES`**: Kernel modules to include in initramfs[3]
- **`HOOKS`**: Initramfs hooks controlling functionality[3]
- **`COMPRESSION`**: Compression method (gzip, bzip2, xz)[3]

**Common HOOKS**:[5][3]
- **`systemd`**: systemd-based boot[3]
- **`autodetect`**: Auto-detect required modules[3]
- **`microcode`**: CPU microcode updates[5]
- **`modconf`**: Module configuration[3]
- **`block`**: Block device support[3]
- **`filesystems`**: Filesystem support[3]
- **`fsck`**: Filesystem checking[3]

#### Manual Regeneration

**Command**: `sudo mkinitcpio -P` regenerates initramfs for all installed kernels.[5][3]

**Individual Kernel**: `sudo mkinitcpio -k linux -g /boot/initramfs-linux.img` regenerates for specific kernel.[3]

**Verbose Output**: `sudo mkinitcpio -P -v` shows detailed regeneration information.[3]

#### Microcode Integration

**Intel Microcode**: `sudo pacman -S intel-ucode` installs Intel processor microcode updates.[6]

**AMD Microcode**: `sudo pacman -S amd-ucode` installs AMD processor microcode updates.[6]

**Modern Approach**: Recent mkinitcpio versions include microcode in the initramfs via the `microcode` hook rather than separate microcode files.[5]

**Configuration**:[5]

```
HOOKS=(systemd autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)
```

**Bootloader Entry**: Modern systemd-boot entries no longer need separate microcode initrd lines when using the `microcode` hook:[5]

```
[Before]
initrd /intel-ucode.img
initrd /initramfs-linux.img

[After]
initrd /initramfs-linux.img
```

### Kernel Modules

**Overview**: Kernel modules are loadable code units extending kernel functionality. They can be loaded or unloaded at runtime without rebooting.[7]

**List Loaded Modules**: `lsmod` displays all currently loaded kernel modules.[7]

**Load Module**: `sudo modprobe [module_name]` dynamically loads a module.[7]

**Unload Module**: `sudo modprobe -r [module_name]` unloads a module.[7]

**Module Parameters**: Modules accept runtime parameters via command line or configuration files.[7]

**Permanent Configuration**: Create files in `/etc/modprobe.d/` to configure module behavior persistently.[7]

### Reboot Requirements

**After Kernel Update**: The system must reboot to use the new kernel. The old kernel continues running until reboot.[1]

**Module Mismatches**: If the new kernel updates but the system does not reboot, attempts to load new modules will fail due to version mismatches between running and installed kernels.[8]

**Avoid Reboots**: Install `linux-preserve-modules` from AUR to allow running kernel and modules to persist safely after updates, deferring reboot until convenient.[8]

**When Rebooting is Unnecessary**: If all required modules are already loaded, technically rebooting is not required; however, this is risky and not recommended.[8]

### Kernel Parameters

**Boot Parameters**: Kernel behavior is controlled via command-line parameters passed by the bootloader.[3]

**Systemd-boot Configuration**:[3]

```
options root=PARTUUID=abcd1234 rw
```

**Common Parameters**:[3]
- **`root=`**: Root filesystem device identifier[3]
- **`ro`**: Read-only root initially[3]
- **`rw`**: Read-write root[3]
- **`quiet`**: Suppress boot messages[3]
- **`vga=`**: Video mode selection[3]

**Debug Parameters**:[3]
- **`break=premount`**: Enter emergency shell before mounting root[3]
- **`break=postmount`**: Enter emergency shell after mounting root[3]

### Kernel Compilation

**From Source**: Arch provides kernel source packages for custom compilation.[1]

**Installation**: `sudo pacman -S linux-headers` provides kernel headers for out-of-tree module compilation.[1]

**Complex Process**: Manual kernel compilation requires understanding kernel configuration, compilation, and module building.[1]

**AUR Kernels**: Pre-configured kernels like `linux-zen` or `linux-hardened` offer customization without full compilation.[2]

### Multiple Kernels

**Install Alternate Kernel**: `sudo pacman -S linux-lts` installs alongside default kernel.[2]

**Boot Selection**: After installation, both kernels appear in bootloader menu.[2]

**Removal**: `sudo pacman -R linux-lts` uninstalls without affecting active kernel.[2]

**Safe Testing**: Install alternate kernels to test stability before switching as default.[2]

### Fallback Initramfs

**Purpose**: Fallback initramfs loads all available modules as contingency.[3]

**Creation**: Mkinitcpio generates both main and fallback images:[3]
- **`initramfs-linux.img`**: Optimized with autodetect[3]
- **`initramfs-linux-fallback.img`**: Full module set[3]

**Boot Entry**: Create fallback boot entry in `/boot/loader/entries/arch-fallback.conf`:[3]

```
title Arch Linux (Fallback Initramfs)
linux /vmlinuz-linux
initrd /initramfs-linux-fallback.img
options root=PARTUUID=abcd1234 rw
```

### Troubleshooting Boot Issues

**Verify Initramfs Generation**: After kernel installation, confirm `/boot/initramfs-*.img` exists.[3]

**Check Boot Mount**: Ensure `/boot` is properly mounted; if unmounted, mkinitcpio cannot write initramfs.[9]

**Manually Regenerate**: Boot from live media and chroot to manually run `sudo mkinitcpio -P`.[3]

**Emergency Recovery**: Use fallback initramfs if primary refuses to boot.[3]

### Kernel Image Location

**Default Location**: Kernel images and initramfs files stored in `/boot/`.[3]

**File Naming Convention**:[3]
- **`vmlinuz-[kernel_name]`**: Compressed kernel image[3]
- **`initramfs-[kernel_name].img`**: Initial RAM disk[3]
- **`[cpu]-ucode.img`**: CPU microcode updates[6]

### Preset Files

**Automatic Generation**: When kernels install, pacman hooks create `/etc/mkinitcpio.d/[kernel].preset`.[4][5]

**Preset Purpose**: Specifies which initramfs images to generate for each kernel.[5]

**Manual Updates**: After mkinitcpio configuration changes, preset files may need manual editing to reflect microcode hook usage.[5]

Sources
[1] Upgrade Kernel on Arch Linux https://linuxhint.com/upgrade-kernel-on-arch-linux/
[2] Installation guide - ArchWiki https://wiki.archlinux.org/title/Installation_guide
[3] mkinitcpio - ArchWiki https://wiki.archlinux.org/title/Mkinitcpio
[4] Arch big update caused kernel panic -- help !!!!! https://forums.scotsnewsletter.com/index.php?%2Ftopic%2F97716-arch-big-update-caused-kernel-panic-help%2F
[5] Mkinitcpio update and changes may need some manual ... https://forum.endeavouros.com/t/mkinitcpio-update-and-changes-may-need-some-manual-intervention/51879?page=2
[6] Microcode - ArchWiki https://wiki.archlinux.org/title/Microcode
[7] Kernel module - ArchWiki https://wiki.archlinux.org/title/Kernel_module
[8] Kernel or mkinitcpio update: do i have to reboot? ... https://bbs.archlinux.org/viewtopic.php?id=295811
[9] Kernel updates force me to run Mkinitcpio -P to access my ... https://www.reddit.com/r/archlinux/comments/15xpfg0/kernel_updates_force_me_to_run_mkinitcpio_p_to/
[10] archlinux/mkinitcpio: Arch Linux initramfs generation tools ... https://github.com/archlinux/mkinitcpio

