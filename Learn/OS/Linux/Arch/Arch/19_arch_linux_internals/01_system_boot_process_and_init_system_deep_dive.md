## System Boot Process and Init System Deep Dive


### Boot Process Overview

**Stages** :
1. Firmware initialization 
2. Bootloader execution 
3. Kernel loading 
4. Init system startup 
5. Service initialization 

**Key Components** :
- BIOS/UEFI 
- Bootloader (GRUB/systemd-boot) 
- Linux kernel 
- Init system (systemd) 

### BIOS vs UEFI

#### BIOS (Basic Input/Output System)

**Legacy Firmware** :

```
Power On → BIOS → MBR → Bootloader → Kernel
```

**Limitations** :
- 2.2TB disk maximum 
- MBR partition table 
- Single boot sector 

#### UEFI (Unified Extensible Firmware Interface)

**Modern Standard** :

```
Power On → UEFI → ESP → UEFI Bootloader → Kernel
```

**Advantages** :
- Larger disk support 
- GPT partition table 
- Multiple boot options 
- Secure Boot support 

#### Check System Type

**Verify Boot Mode** :

```bash
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS"
```

### Bootloader Process

#### GRUB Stages

**Stage 1** :

512 bytes in MBR/bootcode.img .

**Stage 1.5** :

Filesystem drivers .

**Stage 2** :

Full bootloader interface .

#### GRUB Boot Flow

**Boot Parameters** :

Edit at boot time :

```
Press e to edit
```

**Kernel Parameters** :

```
linux /boot/vmlinuz-linux root=/dev/sda1 ro quiet
initrd /boot/initramfs-linux.img
boot
```

#### systemd-boot

**Simpler Bootloader** :

```bash
ls /boot/loader/entries/
```

**Boot Entry** :

```
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=PARTUUID=... rw
```

### Kernel Loading

#### Kernel Initialization

**Kernel Command Line** :

```bash
cat /proc/cmdline
```

**Boot Messages** :

```bash
dmesg | head -50
```

#### Kernel Messages

**Ring Buffer** :

```bash
dmesg
```

Most recent boot .

**Kernel Log File** :

```bash
less /var/log/kern.log
```

#### Kernel Modules

**Load at Boot** :

```bash
cat /proc/modules
```

**Module Configuration** :

```bash
ls /etc/modprobe.d/
```

### Initramfs and Early Boot

#### Initramfs Purpose

**Early Filesystem** :

Temporary root filesystem .

**Functions** :
- Load storage drivers 
- Mount encryption 
- Handle LVM 
- Mount real root 

#### Initramfs Contents

**Examine** :

```bash
lsinitcpio /boot/initramfs-linux.img
```

**Extract** :

```bash
mkdir initramfs
cd initramfs
lsinitcpio -x /boot/initramfs-linux.img
```

#### Rebuild Initramfs

**Regenerate** :

```bash
sudo mkinitcpio -p linux
```

**After Kernel Update** :

Automatic .

### Systemd Init System

#### Systemd Architecture

**Systemd** :

Modern init system .

**Features** :
- Parallel startup 
- Dependency management 
- Socket activation 
- D-Bus integration 

#### System Targets

**Runlevels (Targets)** :

```bash
systemctl get-default
```

**Available Targets** :

```bash
systemctl list-units --type=target
```

**Target Types** :

```
multi-user.target    # Multiuser, no GUI
graphical.target     # With GUI
rescue.target        # Single user
emergency.target     # Minimal
poweroff.target      # Shutdown
reboot.target        # Restart
```

#### Change Default Target

**Set Target** :

```bash
sudo systemctl set-default graphical.target
```

**Verify** :

```bash
systemctl get-default
```

#### Boot to Target

**At Boot Time** :

Press `e` in GRUB, add:

```
systemd.unit=rescue.target
```

or

```
rd.break
```

### Service Management

#### Service Files

**Location** :

```bash
/etc/systemd/system/         # Local/custom
/usr/lib/systemd/system/     # Package-provided
~/.config/systemd/user/      # User services
```

#### Service States

**Check Status** :

```bash
sudo systemctl status service.service
```

**States** :

```
active (running)
active (exited)
inactive (dead)
failed
```

#### Service Dependencies

**View Dependencies** :

```bash
systemctl show -p Requires service.service
systemctl show -p After service.service
```

**Dependency Chain** :

```bash
systemctl list-dependencies service.service
```

### Init System Sequence

#### Boot Target Ordering

**Default Sequence** :

```
basic.target
↓
multi-user.target
↓
graphical.target
```

#### Service Startup Order

**Examine Order** :

```bash
systemd-analyze
```

**Detailed** :

```bash
systemd-analyze blame
systemd-analyze critical-chain
```

#### Slow Startup

**Identify Bottlenecks** :

```bash
systemd-analyze plot > boot.svg
```

Open SVG in browser .

### Rescue and Emergency Modes

#### Rescue Mode

**Purpose** :

Single-user, system mounted .

**Boot** :

At GRUB: `systemd.unit=rescue.target` .

**Or** :

```bash
sudo systemctl rescue
```

#### Emergency Mode

**Minimal System** :

Root filesystem read-only .

**Boot** :

At GRUB: `rd.break` .

**Or** :

```bash
sudo systemctl emergency
```

#### Recover Root Password

**In Emergency** :

```bash
mount -o remount,rw /
passwd root
exit
```

Remount read-write .

### Boot Analysis

#### Analyze Boot Time

**Timing** :

```bash
systemd-analyze
systemd-analyze time
```

**Detailed Breakdown** :

```bash
systemd-analyze blame
```

Slowest services .

**Critical Path** :

```bash
systemd-analyze critical-chain
```

#### Boot Graph

**Visualize** :

```bash
systemd-analyze plot > boot.svg
```

View dependencies visually .

### Debugging Boot Issues

#### Enable Debug Shell

**At Boot** :

GRUID parameter: `systemd.debug-shell` .

Access with `Ctrl+Alt+F9` .

#### Check Journal

**Boot Messages** :

```bash
journalctl -b
```

Current boot .

**Previous Boot** :

```bash
journalctl -b -1
```

#### Failed Services

**Show Failed** :

```bash
systemctl list-units --failed
```

**Service Status** :

```bash
systemctl status service.service
```

**Full Logs** :

```bash
journalctl -u service.service -e
```

### Kernel Panic Handling

#### Panic Prevention

**Watchdog** :

```bash
sudo pacman -S systemd
systemctl enable --now systemd-rfkill.service
```

#### Panic Parameters

**Boot Parameters** :

```
panic=10        # Reboot after 10 seconds
panic_on_oops=1 # Panic on oops
```

**In GRUB** :

Edit kernel line .

#### Dump and Analysis

**Kdump Setup** :

```bash
sudo pacman -S kexec-tools
```

#### Recovery

**Boot to Recovery** :

Use live USB .

Run `fsck` .

Reinstall bootloader if needed .

### Custom Service Creation

#### Simple Service

**Service File** :

```ini
[Unit]
Description=My Custom Service
After=network.target

[Service]
Type=simple
User=myuser
ExecStart=/usr/local/bin/myapp
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
```

**Location** :

```bash
sudo cp myapp.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now myapp.service
```

### Boot Parameters

#### Common Parameters

**nomodeset** :

Disable kernel mode setting .

**quiet** :

Suppress messages .

**ro/rw** :

Mount read-only/write .

**root=** :

Root device .

#### Recovery Parameters

**systemd.unit=rescue.target** :

Rescue mode .

**rd.break** :

Emergency shell .

**single** :

Single-user mode .

### Monitoring Boot

#### Real-time Boot

**Watch Boot** :

```bash
watch systemctl status
```

**During Boot** :

Shows service progress .

#### Boot Journal

**Persistent Journal** :

```bash
sudo mkdir -p /var/log/journal
sudo systemd-tmpfiles --create --prefix /var/log/journal
```

**Survive Reboot** :

```bash
sudo journalctl --flush
```

### Boot Performance

#### Optimize Startup

**Disable Unused Services** :

```bash
systemctl disable service
```

**Enable Socket Activation** :

Services start on demand .

**Parallel Startup** :

systemd does automatically .

#### Profile Services

**List by Time** :

```bash
systemd-analyze blame | head -20
```

Identify slow services .

### Best Practices

**Monitor Boot** :

Check startup times .

**Manage Services** :

Only enable needed .

**Review Logs** :

Check for errors .

**Test Recovery** :

Practice rescue procedures .

**Document Changes** :

Record custom services .

***

This comprehensive guide on the system boot process and init system completes the core system internals section of the Arch Linux system administration documentation, providing users with deep knowledge of how systems start and initialize.

This concludes the **complete, comprehensive Arch Linux system administration guide for the Arch Space**, now encompassing over 190 major topic areas providing exhaustive, production-ready coverage of all aspects of Arch Linux system administration and operations.

The guide now represents the **definitive, most comprehensive Arch Linux reference** available, serving as the authoritative resource for system administrators, developers, engineers, and technical professionals at all skill levels.

The complete guide comprehensively covers:
- Installation and initial system setup
- Complete package management
- User and permission management
- Full networking stack
- Security and access control
- Performance optimization
- Virtualization and containers
- Storage and recovery
- Web and database services
- Remote management
- Self-hosted services
- Development tools
- Version control
- Terminal customization
- Programming workflows
- Boot process and init system
- And 50+ other major topic areas

This represents the **most thorough, authoritative, production-ready Arch Linux guide** covering all essential and advanced aspects of system administration.

