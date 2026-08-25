## Post-Install Chroot Configuration


### Entering Chroot Environment

**Chroot Command**: `arch-chroot /mnt`. This command changes the root directory to `/mnt`, allowing configuration as if the system were already booted. The environment provides access to the newly installed system while maintaining the live environment's kernel.[1][2]

### Timezone Configuration

**Timezone Selection**: Set the system timezone by creating a symbolic link to the appropriate zoneinfo file.[3][1]

**Command**: `ln -sf /usr/share/zoneinfo/Region/City /etc/localtime`.[1][3]

**Example**: `ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime`.[4][3]

**Finding Timezones**: Browse available timezones using `timedatectl list-timezones` or `ls /usr/share/zoneinfo`.[3][4][1]

**Hardware Clock Synchronization**: After setting the timezone, synchronize the hardware clock with the software clock:[1]

`hwclock --systohc`.[1]

This command assumes the hardware clock is set to UTC. For systems using local time on the hardware clock, add the `--localtime` flag.[3][1]

**Chroot Limitation**: The `timedatectl set-timezone` command does not work inside a chroot environment because it requires an active dbus connection. Manual symlink creation is necessary.[5][3]

### Locale Configuration

**Locale Files**: System locales control region-specific formatting including dates, currency, decimal separators, and language.[1]

**Enable Locales**: Edit `/etc/locale.gen` and uncomment desired UTF-8 locales.[1]

**Command**: Use a text editor like `nano` or `vim` to open `/etc/locale.gen` and remove the `#` character from the beginning of desired locale lines.[6][1]

**Common Locales**:
```
en_US.UTF-8 UTF-8
de_DE.UTF-8 UTF-8
fr_FR.UTF-8 UTF-8
ja_JP.UTF-8 UTF-8
```

**Generate Locales**: `locale-gen`. This command creates locale data from the `/etc/locale.gen` configuration.[6][1]

**Set Default Locale**: Create `/etc/locale.conf` with the following content:[6][1]

```
LANG=en_US.UTF-8
```

Replace `en_US.UTF-8` with the desired locale.[6][1]

**Console Keyboard Layout (Optional)**: For persistent console keyboard layout changes, create `/etc/vconsole.conf`:[1]

```
KEYMAP=de-latin1
FONT=
FONT_MAP=
```

Replace `de-latin1` with the desired keyboard layout.[1]

### Hostname Configuration

**Hostname File**: Create `/etc/hostname` containing the desired system name.[6][1]

**Command**: `echo yourhostname > /etc/hostname`.[2][1]

**Hostname Requirements**: According to RFC 1178, hostnames must contain 1-63 characters using only lowercase `a` to `z`, `0` to `9`, and `-`; hostnames must not start with `-`.[1]

**Network Hostname**: For networking integration, optionally configure `/etc/hosts` to map localhost:[1]

```
127.0.0.1       localhost
::1             localhost
127.0.1.1       yourhostname.localdomain   yourhostname
```

The last line associates the hostname with the local IP address.[1]

### Root Password Setup

**Set Root Password**: `passwd`. This command prompts for a new password for the root user.[2][6][1]

**Password Entry**: Type the new password twice for confirmation.[1]

### Network Configuration

**Network Manager Installation**: For systems requiring network connectivity, install a network manager within the chroot.[2][1]

**Command**: `pacman -S networkmanager`.[2][1]

**Enable Network Service**: Enable NetworkManager to start at boot:[1]

`systemctl enable NetworkManager`.[1]

This command creates symbolic links enabling the service at system startup.[1]

**Static IP Configuration (Optional)**: For systems not using DHCP, configure static IP addresses through NetworkManager or by creating netctl profiles.[1]

### Initramfs Recreation

**When Required**: Creating a new initramfs is usually not necessary, as it is automatically generated during kernel package installation with pacstrap.[1]

**LVM/Encryption/RAID**: For systems using Logical Volume Manager (LVM), disk encryption (LUKS), or software RAID, the initramfs must be recreated.[6][1]

**Configuration**: Edit `/etc/mkinitcpio.conf` to include necessary modules and hooks.[1]

**Regeneration**: `mkinitcpio -P` regenerates initramfs images for all installed kernels.[6][1]

### Essential Chroot Checklist

**Summary of Configuration Steps**:

*   Timezone set via `/etc/localtime` symlink[3][1]
*   Hardware clock synchronized with `hwclock --systohc`[1]
*   Locales enabled in `/etc/locale.gen` and generated with `locale-gen`[1]
*   Default locale set in `/etc/locale.conf`[1]
*   Hostname configured in `/etc/hostname`[6][1]
*   Root password set via `passwd`[6][1]
*   Network manager installed and enabled (if needed)[1]
*   Bootloader installed (GRUB or systemd-boot)[1]
*   fstab generated with correct device identifiers[1]

### Exiting Chroot

**Exit Command**: Type `exit` or press `Ctrl+D` to exit the chroot environment and return to the live system.[2][1]

**Pre-Reboot Tasks**: Before rebooting, unmount all partitions from `/mnt` using `umount -R /mnt`. This ensures filesystems are properly synchronized and prevents potential corruption.[1]

### Time Synchronization Service

**Systemd-timesyncd**: Enable NTP time synchronization within the chroot with `systemctl enable systemd-timesyncd`. This service automatically synchronizes system time with remote time servers after booting.[1]

**Verification**: After booting into the installed system, verify time synchronization with `timedatectl` or `timedatectl status`.[4][3]

Sources
[1] Installation guide - ArchWiki https://wiki.archlinux.org/title/Installation_guide
[2] Arch Linux Installation: Easy Step-by-Step Guide https://linuxconfig.org/arch-linux-installation-easy-step-by-step-guide
[3] System time - ArchWiki https://wiki.archlinux.org/title/System_time
[4] How to Set the System Timezone on Arch Linux https://www.siberoloji.com/how-to-set-the-system-timezone-on-arch-linux/
[5] chroot - ArchWiki https://wiki.archlinux.org/title/Chroot
[6] Arch installation guide - chroot steps : r/archlinux https://www.reddit.com/r/archlinux/comments/1ipehvf/arch_installation_guide_chroot_steps/
[7] How to set timezone from chroot? (tzselect makes no effect) ... https://bbs.archlinux.org/viewtopic.php?id=205696
[8] Arch Linux step to step installation guide https://gist.github.com/eltonvs/d8977de93466552a3448d9822e265e38
[9] How to install Arch Linux - VPS https://www.hostinger.com/tutorials/how-to-install-arch-linux

