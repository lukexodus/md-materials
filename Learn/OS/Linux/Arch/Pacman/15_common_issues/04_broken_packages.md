## Broken Packages


### Overview

Broken packages are packages that fail to function correctly due to missing files, corrupted data, unsatisfied dependencies, or installation errors. Identifying and repairing broken packages is essential for maintaining a stable Arch Linux system.

### Identifying Broken Packages

#### File Integrity Checks

**Basic file presence check:**
```
pacman -Qk
```

Shows packages with missing files.

**Comprehensive integrity check:**
```
pacman -Qkk
```

Checks file presence, sizes, permissions, and modification times.

**Output interpretation:**
```
warning: package-name: /usr/bin/program (Size mismatch)
warning: package-name: /etc/config (Modification time mismatch)
```

#### Advanced Checking with paccheck

**Install pacutils:**
```
sudo pacman -S pacutils
```

**Check dependencies:**
```
paccheck --depends
```

Reports packages with unsatisfied dependencies.

**Check file integrity:**
```
paccheck --file-properties
```

Verifies file ownership, permissions, and types.

**Check checksums:**
```
paccheck --sha256sum
```

Validates file content integrity using checksums.

**Comprehensive check:**
```
paccheck --depends --file-properties --sha256sum --quiet
```

Shows only packages with issues.

#### Dependency Verification

**Check for broken dependencies:**
```
pacman -Dk
```

Verifies database consistency.

**Find packages with missing dependencies:**
```
pactree -d1 package-name
```

Shows direct dependencies; errors indicate broken deps.

### Common Causes of Broken Packages

#### Interrupted Installations

**Symptoms:**
- Ctrl+C during package installation
- System crash during upgrade
- Power failure mid-transaction

**Results:**
- Partially extracted files
- Incomplete database entries
- Missing executables or libraries

**Solution:**
```
sudo pacman -S package-name --overwrite '*'
```

Reinstalls and completes the installation.

#### Filesystem Corruption

**Symptoms:**
- Corrupted files after disk errors
- Bad sectors causing data loss
- Filesystem inconsistencies

**Detection:**
```
sudo fsck /dev/sdXn  # Run on unmounted partition
```

**Solution:**
Fix filesystem first, then reinstall affected packages:
```
sudo pacman -S $(pacman -Qkk 2>&1 | grep -v "0 altered files" | cut -d: -f1 | sort -u)
```

#### Manual File Modifications

**Symptoms:**
- User edited system files
- Manually deleted package files
- Changed file permissions

**Detection:**
```
pacman -Qkk package-name
```

**Solution:**
Reinstall to restore original files:
```
sudo pacman -S package-name
```

#### Library Incompatibilities

**Symptoms:**
```
error while loading shared libraries: libfoo.so.5: cannot open shared object file
```

**Cause:** Missing or incompatible library after upgrade.

**Detection:**
```
ldd /usr/bin/program
```

Shows missing libraries.

**Solution:**
```
sudo pacman -Syu  # Full system upgrade
```

Or rebuild AUR packages:
```
yay -S package-name --rebuild
```

#### AUR Build Issues

**Symptoms:**
- Package installs but doesn't work
- Missing dependencies not in repos
- Incorrect file paths

**Solution:**
```
cd ~/.cache/yay/package-name  # or paru cache
git pull
makepkg -Ccsi
```

Clean rebuild from updated source.

### Repairing Broken Packages

#### Reinstallation

**Simple reinstall:**
```
sudo pacman -S package-name
```

Reinstalls the package, replacing corrupted or missing files.

**Force reinstall:**
```
sudo pacman -S --overwrite '*' package-name
```

Overwrites all files, including modified ones.

**Reinstall with dependencies:**
```
sudo pacman -S --needed package-name
```

Ensures all dependencies are present.

#### Downgrading Broken Packages

**From cache:**
```
sudo pacman -U /var/cache/pacman/pkg/package-name-old-version.pkg.tar.zst
```

**From Arch Archive:**
```
# Visit https://archive.archlinux.org/packages/p/package-name/
wget https://archive.archlinux.org/packages/p/package-name/package-name-version.pkg.tar.zst
sudo pacman -U package-name-version.pkg.tar.zst
```

**Hold the downgraded version:**
```
# Add to /etc/pacman.conf
IgnorePkg = package-name
```

#### Database-Only Reinstallation

**Update database without touching files:**
```
sudo pacman -S --dbonly package-name
```

Useful when files are correct but database entry is corrupted.

**Warning:** Only use if files are actually present and correct.

### Fixing Missing Libraries

#### Identifying Missing Libraries

**Check program dependencies:**
```
ldd /usr/bin/program
```

**Output:**
```
libfoo.so.5 => not found
libbar.so.2 => /usr/lib/libbar.so.2 (0x00007f...)
```

"not found" indicates missing library.

#### Finding Which Package Provides Library

**Search files database:**
```
pacman -F libfoo.so.5
```

Shows which package provides the library.

**If files database is outdated:**
```
sudo pacman -Fy
pacman -F libfoo.so.5
```

**Install providing package:**
```
sudo pacman -S package-providing-lib
```

#### Symlink Missing Libraries (Temporary)

**If library exists with different version:**
```
ls /usr/lib/libfoo.so*
# Shows: libfoo.so.6

sudo ln -s /usr/lib/libfoo.so.6 /usr/lib/libfoo.so.5
```

**Warning:** This is a temporary workaround. Proper solution is updating or rebuilding the dependent package.

### Rebuilding AUR Packages

#### When to Rebuild

**After system library updates:**
- New glibc version
- Major Python/Perl version changes
- Updated shared libraries

**Symptoms of needing rebuild:**
```
error while loading shared libraries
segmentation fault
undefined symbol errors
```

#### Rebuild Process

**Using yay:**
```
yay -S package-name --rebuild
```

**Using paru:**
```
paru -S package-name --rebuild
```

**Manual rebuild:**
```
cd ~/.cache/yay/package-name
makepkg -Ccsi
```

The `-C` flag cleans previous build artifacts.

#### Rebuild All Foreign Packages

**Rebuild all AUR packages:**
```
yay -S $(pacman -Qmq) --rebuild
```

**Warning:** Time-consuming; only necessary after major system changes.

### Database Corruption Recovery

#### Symptoms

```
error: could not open file /var/lib/pacman/local/package-name/desc
error: failed to prepare transaction (database is not valid)
```

#### Step-by-Step Recovery

**1. Check database integrity:**
```
sudo pacman -Dk
```

**2. Backup database:**
```
sudo cp -a /var/lib/pacman /var/lib/pacman.bak
```

**3. Refresh sync databases:**
```
sudo pacman -Syy
```

**4. Reinstall broken package:**
```
sudo pacman -S package-name --overwrite '*'
```

**5. If widespread corruption, rebuild database:**
```
sudo pacman -S $(pacman -Qq) --overwrite '*'
```

**Warning:** Last resort; reinstalls all packages.

### Fixing Specific Breakage Scenarios

#### Broken Python Packages

**Symptom:**
```
ModuleNotFoundError: No module named 'module_name'
```

**Cause:** Python version upgrade broke site-packages.

**Solution:**
```
sudo pacman -S python
pip list --user  # Check user-installed packages
pip install --user --force-reinstall package-name
```

**For system packages:**
```
sudo pacman -S python-package-name
```

#### Broken Kernel Modules

**Symptom:**
```
modprobe: FATAL: Module not found
```

**Cause:** Kernel upgrade without rebuilding DKMS modules.

**Solution:**
```
sudo dkms autoinstall
sudo mkinitcpio -P
```

Or reinstall module packages:
```
sudo pacman -S nvidia-dkms virtualbox-host-dkms
```

#### Broken Bootloader

**Symptom:**
System won't boot after upgrade.

**Solution (from live USB):**
```
# Mount and chroot
mount /dev/sdXn /mnt
arch-chroot /mnt

# Reinstall bootloader
pacman -S grub
grub-install /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg

# Or for systemd-boot
bootctl install
```

#### Broken Initramfs

**Symptom:**
Kernel panic, can't find root filesystem.

**Solution (from live USB):**
```
arch-chroot /mnt
mkinitcpio -P
```

### Preventive Measures

#### Regular Integrity Checks

**Weekly verification:**
```
#!/bin/bash
# /usr/local/bin/check-package-integrity

BROKEN=$(paccheck --sha256sum --quiet 2>&1)

if [ -n "$BROKEN" ]; then
    echo "Broken packages detected:"
    echo "$BROKEN"
    exit 1
else
    echo "All packages OK"
fi
```

**Schedule with cron:**
```
0 3 * * 0 /usr/local/bin/check-package-integrity
```

#### Pacman Hooks for Automatic Checks

```
# /etc/pacman.d/hooks/check-integrity.hook
[Trigger]
Operation = Upgrade
Operation = Install
Type = Package
Target = *

[Action]
Description = Verifying package integrity...
When = PostTransaction
Exec = /usr/bin/pacman -Dk
```

#### Maintain Package Cache

**Keep recent versions for downgrading:**
```
sudo paccache -rk3
```

Retains 3 versions for easy rollback.

#### System Snapshots

**Using Btrfs snapshots:**
```
sudo btrfs subvolume snapshot / /.snapshots/$(date +%Y%m%d)
```

**Using Timeshift:**
```
sudo pacman -S timeshift
sudo timeshift --create --comments "Before upgrade"
```

### Recovery Tools

#### Using pacman-static

When pacman itself is broken:
```
wget https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod +x pacman-static
sudo ./pacman-static -Syu pacman
```

Static binary works without library dependencies.

#### Emergency Recovery Script

```bash
#!/bin/bash
# Emergency package repair script

echo "=== Emergency Package Repair ==="

# Remove lock file
rm -f /var/lib/pacman/db.lck

# Refresh databases
pacman -Syy

# Check for broken packages
echo "Checking for broken packages..."
BROKEN=$(pacman -Qkk 2>&1 | grep -v "0 altered files" | cut -d: -f1 | sort -u)

if [ -n "$BROKEN" ]; then
    echo "Reinstalling broken packages..."
    pacman -S $BROKEN --overwrite '*' --noconfirm
else
    echo "No broken packages found"
fi

# Verify integrity
pacman -Dk

echo "=== Repair Complete ==="
```

### Best Practices

**Regular updates:** Keep system current to avoid compatibility issues.

**Read upgrade notes:** Check Arch news before major upgrades.

**Test before committing:** Review package lists before confirming installation.

**Verify after upgrades:** Run integrity checks after major updates.

**Maintain backups:** Keep system snapshots for quick recovery.

**Document issues:** Note what caused breakage and how you fixed it.

**Don't force solutions:** Understand root cause before using --overwrite or --nodeps.

**Rebuild AUR packages:** Update AUR packages after system library changes.

**Check logs:** Review `/var/log/pacman.log` for clues about breakage.

**Ask for help:** Consult forums/wiki when encountering unfamiliar breakage.

Proper diagnosis and repair of broken packages prevents system instability and ensures reliable operation of your Arch Linux installation

