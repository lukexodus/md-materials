## System Targets


### Target Concepts (Runlevels)

System targets in modern Linux distributions are the systemd equivalent of traditional SysV runlevels. They define different operational states of the system, determining which services and processes should be running at any given time.

**Key points:**

- Targets are systemd units that group other units together
- They replace the traditional runlevel system used in SysV init
- Multiple targets can be active simultaneously
- Targets have dependencies and can be chained together

#### Traditional Runlevels vs Modern Targets

Traditional SysV runlevels were numbered 0-6, each representing a specific system state:

- Runlevel 0: Halt/shutdown
- Runlevel 1: Single-user mode (rescue)
- Runlevel 2: Multi-user mode without networking
- Runlevel 3: Multi-user mode with networking
- Runlevel 4: Unused/custom
- Runlevel 5: Multi-user mode with GUI
- Runlevel 6: Reboot

Modern systemd targets provide more flexibility and descriptive names:

- `poweroff.target` (equivalent to runlevel 0)
- `rescue.target` (equivalent to runlevel 1)
- `multi-user.target` (equivalent to runlevel 3)
- `graphical.target` (equivalent to runlevel 5)
- `reboot.target` (equivalent to runlevel 6)

#### Target Types and Structure

**Basic Target Categories:**

- **System State Targets**: Define overall system operational modes
- **Device Targets**: Represent hardware devices and their availability
- **Mount Targets**: Handle filesystem mounting operations
- **Network Targets**: Manage network-related services
- **Timer Targets**: Control scheduled tasks and timers

**Target Dependencies:** Targets use `Wants`, `Requires`, `After`, and `Before` directives to establish relationships:

- `Wants`: Soft dependency (preferred but not mandatory)
- `Requires`: Hard dependency (must be satisfied)
- `After`: Ordering dependency (start after specified units)
- `Before`: Ordering dependency (start before specified units)

### Target Switching

Target switching allows administrators to change the system's operational state without rebooting, providing dynamic control over system services and functionality.

#### Switching Methods

**Immediate Target Changes:**

```bash
# Switch to rescue mode
sudo systemctl isolate rescue.target

# Switch to multi-user mode (no GUI)
sudo systemctl isolate multi-user.target

# Switch to graphical mode
sudo systemctl isolate graphical.target
```

**Setting Default Targets:**

```bash
# Set default target for next boot
sudo systemctl set-default multi-user.target

# Check current default target
systemctl get-default
```

**Emergency Switching:**

```bash
# Emergency mode (minimal services)
sudo systemctl isolate emergency.target

# Rescue mode (single-user with more services)
sudo systemctl isolate rescue.target
```

#### Target Investigation Commands

**Viewing Target Information:**

```bash
# List all available targets
systemctl list-units --type=target

# Show target dependencies
systemctl list-dependencies graphical.target

# Check target status
systemctl status multi-user.target

# Show what's included in a target
systemctl show -p Wants,Requires graphical.target
```

#### Custom Target Creation

Administrators can create custom targets for specific operational scenarios:

**Example:** Creating a maintenance target

```bash
# Create custom target file
sudo nano /etc/systemd/system/maintenance.target

# Target file content:
[Unit]
Description=Maintenance Mode
Requires=multi-user.target
Wants=sshd.service
After=multi-user.target
AllowIsolate=yes

[Install]
WantedBy=multi-user.target
```

### Boot Process Understanding

The Linux boot process with systemd involves multiple stages, each with specific targets that coordinate the initialization of system components.

#### Boot Sequence Stages

**Firmware Stage:**

- BIOS/UEFI initialization
- Hardware detection and POST
- Bootloader location and execution

**Bootloader Stage:**

- GRUB or other bootloader loads kernel
- Kernel parameters passed from bootloader
- Initial RAM disk (initrd/initramfs) loaded

**Kernel Stage:**

- Kernel decompression and initialization
- Hardware driver loading
- Root filesystem mounting
- systemd (PID 1) process start

**Systemd Initialization:**

- `default.target` determination
- Dependency resolution and parallel service startup
- Target achievement and system readiness

#### Key Boot Targets

**Early Boot Targets:**

- `sysinit.target`: Basic system initialization
- `basic.target`: Fundamental system services
- `local-fs.target`: Local filesystem mounting
- `network.target`: Network interface availability

**Main Boot Targets:**

- `multi-user.target`: Multi-user system without GUI
- `graphical.target`: Full desktop environment
- `default.target`: Symlink to desired default target

#### Boot Analysis Tools

**Analyzing Boot Performance:**

```bash
# Boot time analysis
systemd-analyze

# Service startup times
systemd-analyze blame

# Critical chain analysis
systemd-analyze critical-chain

# Boot process visualization
systemd-analyze plot > boot.svg
```

**Boot Logging:**

```bash
# View boot messages
journalctl -b

# Show boot process details
journalctl -b -u systemd

# Emergency shell messages
journalctl -b -p err
```

### Recovery Modes

Recovery modes provide different levels of system access when normal boot fails or maintenance is required.

#### Recovery Mode Types

**Single-User Mode (Rescue Target):**

- Root filesystem mounted read-write
- Network services disabled
- Minimal service set running
- Root access without password [Inference based on traditional behavior]
- Access via: `systemctl isolate rescue.target`

**Emergency Mode:**

- Root filesystem mounted read-only
- Absolute minimum services
- Manual filesystem remounting required
- Access via: `systemctl isolate emergency.target`

**Recovery Boot Options:** Boot parameters can be modified at GRUB to enter recovery modes:

- `systemd.unit=rescue.target`: Boot to rescue mode
- `systemd.unit=emergency.target`: Boot to emergency mode
- `init=/bin/bash`: Direct shell access [Unverified - behavior may vary by distribution]

#### Emergency Access Methods

**GRUB Emergency Boot:**

1. Access GRUB menu during boot
2. Edit boot entry (usually 'e' key)
3. Add recovery parameters to kernel line
4. Boot with modified parameters

**Password Recovery Process:**

1. Boot to single-user mode
2. Remount root filesystem as read-write
3. Change root password with `passwd`
4. Sync and reboot

**Filesystem Recovery:**

```bash
# Check filesystem integrity
fsck /dev/sdX

# Mount filesystem read-write
mount -o remount,rw /

# Repair package database
rpm --rebuilddb  # RPM systems
dpkg --configure -a  # Debian systems
```

#### Advanced Recovery Techniques

**chroot Recovery:**

- Boot from live media
- Mount damaged system's root filesystem
- Use chroot to access installed system
- Perform repairs within chrooted environment

**Systemd Service Recovery:**

```bash
# Disable problematic service
systemctl disable problematic.service

# Mask service to prevent activation
systemctl mask problematic.service

# Reset failed services
systemctl reset-failed
```

**Configuration Recovery:**

- Backup and restore `/etc` directory contents
- Reset systemd configuration: `systemctl daemon-reload`
- Restore from system snapshots if available

**Key points:**

- Recovery modes provide progressively minimal system states
- Emergency mode requires manual intervention for most operations
- Boot parameter modification offers immediate recovery access
- Service masking prevents problematic units from starting

**Conclusion:** System targets provide flexible system state management replacing traditional runlevels. Understanding target switching, boot processes, and recovery modes enables effective Linux system administration and troubleshooting. The systemd target system offers granular control over system services while maintaining clear operational states for different use scenarios.

---

