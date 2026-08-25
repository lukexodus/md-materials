## Handling Initramfs and Kernel Hooks


### Initramfs Overview

**Purpose**: The initramfs (initial RAM filesystem) is a gzip-compressed cpio archive loaded by the boot loader that provides a minimal environment for the kernel to mount the root filesystem. It bridges the gap between the boot loader and the kernel's ability to access the real root filesystem.[1]

**Generation**: Mkinitcpio generates initramfs images automatically when kernel packages install or can be manually regenerated.[2][1]

**File Location**: Initramfs files are stored in `/boot/` with naming convention `initramfs-[kernel_name].img`.[1]

### Initramfs Generation Process

**Mkinitcpio Workflow**: Mkinitcpio processes configuration and generates the initramfs through several stages:[3][1]

1. **Configuration Reading**: Reads `/etc/mkinitcpio.conf` for hooks, modules, and options[1]
2. **Hook Execution**: Executes hooks in specified order[1]
3. **Module Inclusion**: Includes specified kernel modules[1]
4. **Compression**: Compresses the archive using configured compression[1]
5. **File Writing**: Writes initramfs to `/boot/`[1]

### Mkinitcpio Configuration

**Configuration File**: `/etc/mkinitcpio.conf` controls all aspects of initramfs generation.[4][1]

**Structure**:[1]

```
MODULES=(ext4 btrfs)
BINARIES=()
FILES=()
HOOKS=(systemd autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)
COMPRESSION="zstd"
```

#### MODULES Array

**Purpose**: Specifies kernel modules to include in initramfs.[1]

**Common Modules**:[1]
- **`ext4`, `btrfs`, `xfs`**: Filesystem support[1]
- **`dm-crypt`**: Disk encryption support[1]
- **`raid1`, `raid6`**: Software RAID support[1]

**Autodetection**: Using the `autodetect` hook automatically includes needed modules. Manual specification is typically unnecessary for standard setups.[1]

#### HOOKS Array

**Execution Order**: Hooks are executed in the order specified.[1]

**Critical Hooks**:[4][1]
- **`base`**: Provides base utilities (required)[1]
- **`systemd`**: Enables systemd in initramfs[1]
- **`autodetect`**: Auto-detects and includes only necessary modules[1]
- **`microcode`**: Loads CPU microcode updates[4]
- **`modconf`**: Reads `/etc/modprobe.d/` and `/usr/lib/modprobe.d/` configuration[1]
- **`kms`**: Kernel modesetting for graphics[1]
- **`keyboard`**: Keyboard support for encrypted systems[1]
- **`keymap`**: Keymap configuration[1]
- **`consolefont`**: Console font loading[1]
- **`block`**: Block device support[1]
- **`filesystems`**: Filesystem driver support[1]
- **`fsck`**: Filesystem checking[1]

**Encryption Hooks**:[1]
- **`encrypt`**: LUKS encryption support (legacy)[1]
- **`sd-encrypt`**: Systemd-based LUKS support[1]

**LVM Hooks**:[1]
- **`lvm2`**: Logical Volume Manager support[1]

**RAID Hooks**:[1]
- **`mdadm`**: Software RAID detection and assembly[1]

#### COMPRESSION Setting

**Compression Methods**:[1]
- **`gzip`**: Universal but slower[1]
- **`bzip2`**: Better compression, slower[1]
- **`xz`**: Excellent compression, slowest[1]
- **`lz4`**: Fast but less compression[1]
- **`lzop`**: Very fast, minimal compression[1]
- **`zstd`**: Modern default, balanced performance and compression[1]

**Change Compression**: `COMPRESSION="zstd"`.[1]

### Manual Initramfs Regeneration

**Regenerate All**: `sudo mkinitcpio -P` regenerates initramfs for all installed kernels.[2][1]

**Regenerate Specific Kernel**: `sudo mkinitcpio -k linux -g /boot/initramfs-linux.img`.[1]

**Verbose Output**: `sudo mkinitcpio -P -v` displays detailed generation process.[1]

**List Hooks**: `sudo mkinitcpio -H` shows available hooks.[1]

**List Presets**: `sudo mkinitcpio -T` displays detected presets.[1]

**Dry Run**: `sudo mkinitcpio -P -d /tmp/` creates test initramfs in temporary directory.[1]

### Pacman Hooks

**Overview**: Pacman hooks automatically trigger commands during package operations, enabling actions like automatic initramfs regeneration.[4][1]

**Hook Files**: Located in `/etc/pacman.d/hooks/` for custom hooks or `/usr/share/pacman/hooks/` for system hooks.[4]

**Hook Structure**:[4]

```
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = linux
Target = linux-lts

[Action]
When = PostTransaction
Exec = /usr/bin/mkinitcpio -P
```

**Automatic Triggering**: When kernel packages are installed or upgraded, pacman automatically runs mkinitcpio via the hook.[5]

**Disabling Hooks**: Temporarily disable hooks by renaming to `.disabled` extension (e.g., `60-mkinitcpio.hook.disabled`).[4]

### Microcode Hooks

**Traditional Approach**: Older systems required separate microcode initrd lines:[4]

```
initrd /intel-ucode.img
initrd /initramfs-linux.img
```

**Modern Approach**: Recent mkinitcpio includes microcode via the `microcode` hook.[4]

**Configuration**:

```
HOOKS=(systemd autodetect microcode modconf kms ...)
```

**Bootloader Entry** (Simplified):[4]

```
[Boot Entry]
initrd /initramfs-linux.img
```

The microcode is now embedded within the initramfs.[4]

**Update Needed**: After upgrading to mkinitcpio versions supporting the microcode hook, remove separate microcode initrd lines from bootloader entries.[4]

### Encryption Support in Initramfs

**LUKS Configuration**: For encrypted root filesystems, include encryption hooks.[1]

**Systemd-based Encryption**:[1]

```
HOOKS=(systemd autodetect microcode modconf kms keyboard sd-encrypt filesystems fsck)
```

**Kernel Parameters**: Specify encryption device via `sd-luks.cryptdevice=`:[1]

```
options root=PARTUUID=abcd1234 sd-luks.cryptdevice=UUID:root:discard rw
```

**Legacy LUKS**:[1]

```
HOOKS=(base autodetect microcode modconf block encrypt filesystems fsck)
```

### RAID and LVM Support

**Software RAID**:[1]

```
HOOKS=(base autodetect microcode modconf block mdadm filesystems fsck)
```

**Logical Volume Manager**:[1]

```
HOOKS=(base autodetect microcode modconf block lvm2 filesystems fsck)
```

**Combined Setup**:[1]

```
HOOKS=(base autodetect microcode modconf block mdadm lvm2 filesystems fsck)
```

### Troubleshooting Initramfs Issues

**Missing Filesystems**: If root filesystem type is not in HOOKS, system cannot mount root.[1]

**Solution**: Add filesystem hook or enable `autodetect`.[1]

**Encrypted System Won't Boot**: Verify encryption hook is enabled and kernel parameters are correct.[1]

**Boot to Emergency Shell**: If `break=premount` or `break=postmount` parameters are used, emergency shell provides debugging opportunity.[1]

**Manual Check**: Boot from live media and mount system to inspect `/boot/` for corrupted initramfs files.[1]

### Preset Files

**Auto-Generated**: Kernel package installation creates `/etc/mkinitcpio.d/[kernel].preset`.[5][4]

**Preset Content**:[4]

```
# mkinitcpio preset file for the 'linux' package

ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux"
ALL_microcode=(/boot/*-ucode.img)

PRESETS=('default' 'fallback')

#default
default_image="/boot/initramfs-linux.img"
default_options=""

#fallback
fallback_image="/boot/initramfs-linux-fallback.img"
fallback_options="-S autodetect"
```

**Fallback Purpose**: The fallback preset generates a complete initramfs with all modules (no autodetect) for emergency recovery.[4]

**Manual Editing**: After mkinitcpio configuration changes, manually edit presets to match new hook requirements.[4]

### Boot Stages and Initramfs Role

**Stage 1**: Boot loader loads kernel and initramfs into memory.[1]

**Stage 2**: Kernel extracts and executes initramfs.[1]

**Stage 3**: Initramfs mounts root filesystem using loaded drivers and modules.[1]

**Stage 4**: Initramfs pivots to real root and exec's `/sbin/init` (systemd).[1]

**Stage 5**: Systemd continues full system initialization.[1]

### Testing Initramfs Configuration Changes

**Generate Test Image**: `sudo mkinitcpio -P -d /tmp/test/`.[1]

**Inspect Archive**: `cd /tmp/test && file initramfs-linux.img` confirms archive type.[1]

**Boot Test**: Add new boot entry pointing to test initramfs before committing changes.[1]

### Common Issues and Solutions

**Microcode Loading Errors**: After mkinitcpio updates, remove separate microcode initrd lines if using `microcode` hook.[4]

**Hook Not Found**: Verify hook exists with `sudo mkinitcpio -H` and check spelling.[1]

**Module Not Loading**: Ensure module is listed in MODULES array or `autodetect` hook is enabled.[1]

**Compression Method Unsupported**: Verify kernel supports chosen compression; fallback to `gzip` if uncertain.[1]

Sources
[1] mkinitcpio - ArchWiki https://wiki.archlinux.org/title/Mkinitcpio
[2] Kernel updates force me to run Mkinitcpio -P to access my ... https://www.reddit.com/r/archlinux/comments/15xpfg0/kernel_updates_force_me_to_run_mkinitcpio_p_to/
[3] archlinux/mkinitcpio: Arch Linux initramfs generation tools ... https://github.com/archlinux/mkinitcpio
[4] Mkinitcpio update and changes may need some manual ... https://forum.endeavouros.com/t/mkinitcpio-update-and-changes-may-need-some-manual-intervention/51879?page=2
[5] Arch big update caused kernel panic -- help !!!!! https://forums.scotsnewsletter.com/index.php?%2Ftopic%2F97716-arch-big-update-caused-kernel-panic-help%2F

