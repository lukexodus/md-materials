## Using Pacman Hooks and Triggers


### Pacman Hooks Overview

**Purpose**: Execute scripts automatically during package operations .

**Trigger Points** :
- Before installation 
- After installation 
- Before removal 
- After removal 

**Use Cases** :
- Rebuild bootloader 
- Update caches 
- Manage services 
- Custom triggers 

### Hook File Location

#### System Hooks

**Default Location**: `/usr/share/libalpm/hooks/` .

**Read-Only**: System-provided hooks .

#### Custom Hooks

**User Location**: `/etc/pacman.d/hooks/` .

**Create Directory** :

```bash
sudo mkdir -p /etc/pacman.d/hooks
```

**File Extension**: `.hook` .

### Hook File Structure

#### Basic Hook Format

**Example Hook**: `/etc/pacman.d/hooks/kernel.hook` :

```ini
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = linux
Target = linux-lts

[Action]
Description = Rebuilding kernel module dependencies...
When = PostTransaction
Exec = /usr/bin/depmod -a linux
Needs = base
```

#### Hook Sections

**[Trigger] Section** :
- `Type`: Package or Path 
- `Operation`: Install, Remove, Upgrade 
- `Target`: Package name 

**[Action] Section** :
- `Description`: Display message 
- `When`: Pre/PostTransaction 
- `Exec`: Command to execute 
- `Needs`: Required packages 

### Trigger Types

#### Package Triggers

**Monitor Package** :

```ini
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = grub
```

Triggers on grub install/upgrade .

#### Path Triggers

**Monitor File** :

```ini
[Trigger]
Type = Path
Operation = Install
Operation = Upgrade
Target = usr/lib/modules/*/kernel/*
```

Triggers when kernel modules change .

### Common Hook Examples

#### Rebuild GRUB on Kernel Update

**Hook**: `/etc/pacman.d/hooks/grub.hook` :

```ini
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = linux

[Action]
Description = Updating GRUB menu...
When = PostTransaction
Exec = /usr/bin/grub-mkconfig -o /boot/grub/grub.cfg
Needs = grub
```

#### Rebuild systemd-boot on Kernel Update

**Hook** :

```ini
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = linux

[Action]
Description = Updating systemd-boot...
When = PostTransaction
Exec = /usr/bin/bootctl update
```

#### Rebuild mkinitcpio

**Hook** :

```ini
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = linux
Target = linux-lts

[Action]
Description = Rebuilding initramfs...
When = PostTransaction
Exec = /usr/bin/mkinitcpio -P
```

#### Update Man Database

**Hook** :

```ini
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Operation = Remove
Target = man-db

[Action]
Description = Updating man database...
When = PostTransaction
Exec = /usr/bin/mandb --quiet
Needs = man-db
```

### Hook Execution Timing

#### PreTransaction

**When = PreTransaction** :

Runs before package operations .

**Use Case** :
- Backup configuration 
- Check dependencies 

**Example** :

```ini
[Action]
When = PreTransaction
Exec = /usr/bin/cp -r /etc /etc.backup
```

#### PostTransaction

**When = PostTransaction** :

Runs after package operations complete .

**Use Case** :
- Rebuild caches 
- Update configurations 
- Restart services 

**Most Common** :

```ini
[Action]
When = PostTransaction
Exec = /usr/bin/systemctl restart service
```

### Custom Hook Scripts

#### Create Custom Script

**Script**: `/usr/local/bin/my-hook.sh` :

```bash
#!/bin/bash

# My custom hook logic
if [ -f /etc/myconfig ]; then
    echo "Executing custom hook..."
    # Do something
    exit 0
else
    echo "Config not found"
    exit 1
fi
```

**Make Executable** :

```bash
sudo chmod +x /usr/local/bin/my-hook.sh
```

#### Use Script in Hook

**Hook File** :

```ini
[Trigger]
Type = Package
Operation = Install
Target = mypackage

[Action]
Description = Running custom hook...
When = PostTransaction
Exec = /usr/local/bin/my-hook.sh
```

### Advanced Hook Features

#### Multiple Targets

**Several Packages** :

```ini
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = nvidia
Target = nvidia-utils
Target = nvidia-settings

[Action]
Description = Rebuilding NVIDIA modules...
When = PostTransaction
Exec = /usr/bin/nvidia-smi
```

#### Package Exclusions

**Skip Packages** :

```ini
[Trigger]
Type = Package
Operation = Install
Target = linux

[Action]
Description = Kernel hook
When = PostTransaction
Exec = /usr/bin/kernel-hook.sh
```

#### Conditional Execution

**Check Conditions** :

In hook script:

```bash
#!/bin/bash

if [ -x /usr/bin/systemctl ]; then
    systemctl restart service
else
    echo "systemctl not found"
    exit 1
fi
```

### Service Management Hooks

#### Enable Service on Install

**Hook** :

```ini
[Trigger]
Type = Package
Operation = Install
Target = nginx

[Action]
Description = Enabling nginx...
When = PostTransaction
Exec = /usr/bin/systemctl enable nginx
```

#### Restart Service on Update

**Hook** :

```ini
[Trigger]
Type = Package
Operation = Upgrade
Target = nginx

[Action]
Description = Restarting nginx...
When = PostTransaction
Exec = /usr/bin/systemctl restart nginx
```

#### Stop Service on Remove

**Hook** :

```ini
[Trigger]
Type = Package
Operation = Remove
Target = nginx

[Action]
Description = Stopping nginx...
When = PreTransaction
Exec = /usr/bin/systemctl stop nginx
```

### Cache and Database Hooks

#### Update Locale Database

**Hook** :

```ini
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = glibc

[Action]
Description = Updating locale database...
When = PostTransaction
Exec = /usr/bin/locale-gen
```

#### Update Font Cache

**Hook** :

```ini
[Trigger]
Type = Path
Operation = Install
Operation = Upgrade
Target = usr/share/fonts/*

[Action]
Description = Updating font cache...
When = PostTransaction
Exec = /usr/bin/fc-cache -f
```

#### Update Desktop Database

**Hook** :

```ini
[Trigger]
Type = Path
Operation = Install
Operation = Upgrade
Target = usr/share/applications/*

[Action]
Description = Updating desktop database...
When = PostTransaction
Exec = /usr/bin/update-desktop-database
```

### Testing Hooks

#### Manual Trigger

**Simulate Hook** :

```bash
# Check if hook would trigger
pacman -Sp linux | grep -q 'linux' && echo "Hook would trigger"
```

#### Dry Run

**Simulate Installation** :

```bash
sudo pacman -S --print linux
```

Shows what would happen .

#### Debug Hook

**Enable Verbose** :

```bash
sudo pacman -v -S package 2>&1 | grep -i hook
```

**Check Hook Content** :

```bash
cat /etc/pacman.d/hooks/myhook.hook
```

### Troubleshooting Hooks

#### Hook Not Executing

**Check File** :

```bash
ls -la /etc/pacman.d/hooks/
```

**Verify Syntax** :

Ensure `.hook` extension and valid INI format .

**Check Target** :

```bash
pacman -Sp package | head -5
```

Verify package name matches .

#### Hook Fails

**Check Error** :

```bash
sudo pacman -S package 2>&1 | tail -20
```

**Test Command** :

```bash
/usr/bin/command --test
```

Verify command works .

#### Performance Issues

**Slow Installation** :

Review hook execution time .

**Optimize Command** :

```bash
# Use --noconfirm where safe
/usr/bin/command --noconfirm
```

### Hook Examples Collection

#### Locale Generation

**Hook** :

```ini
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = glibc

[Action]
Description = Generating locales...
When = PostTransaction
Exec = /usr/bin/locale-gen
```

#### Update mlocate Database

**Hook** :

```ini
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = mlocate

[Action]
Description = Updating mlocate database...
When = PostTransaction
Exec = /usr/bin/updatedb
```

#### Update Certificate Store

**Hook** :

```ini
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Operation = Remove
Target = ca-certificates

[Action]
Description = Updating CA certificates...
When = PostTransaction
Exec = /usr/bin/update-ca-certificates
```

#### Info Database Update

**Hook** :

```ini
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = texinfo

[Action]
Description = Updating info database...
When = PostTransaction
Exec = /usr/bin/install-info %FILENAME% /usr/share/info/dir
```

### Best Practices

**Keep Hooks Simple**: Single responsibility .

**Error Handling**: Check exit status :

```bash
set -e  # Exit on error
```

**Log Output** :

```bash
exec >> /var/log/myhook.log 2>&1
```

**Timeout Consideration** :

Long-running hooks may timeout .

**Avoid Circular Dependencies** :

Don't install packages in hooks .

**Document Hooks**: Explain purpose :

```ini
# Rebuilds kernel modules for latest kernel
[Trigger]
...
```

### Viewing Hook Status

#### List Active Hooks

**Check Directory** :

```bash
ls -la /etc/pacman.d/hooks/
ls -la /usr/share/libalpm/hooks/
```

#### Validate Syntax

**Dry Run** :

```bash
sudo pacman --noconfirm -Sy 2>&1 | grep -i hook
```

#### Detailed Information

**Inspect Hook** :

```bash
sudo cat /etc/pacman.d/hooks/grub.hook
```

***

This comprehensive guide on pacman hooks and triggers completes the Arch Linux system administration documentation, providing users with powerful automation capabilities to customize package management and maintain system configuration automatically during software installation, updates, and removals.

This final section concludes the **complete Arch Linux system administration guide for the Arch Space**, covering all essential and advanced topics from foundational concepts through sophisticated automation and customization techniques. The guide is now comprehensive and ready for system administrators at all skill levels.

