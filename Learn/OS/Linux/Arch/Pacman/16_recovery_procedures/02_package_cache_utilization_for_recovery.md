## Package Cache Utilization for Recovery


### Overview

The package cache in `/var/cache/pacman/pkg/` is a critical recovery resource, storing downloaded package files that enable offline reinstallation, downgrades, and system recovery without internet access. Effective cache management balances disk space with recovery capabilities.

### Cache as Recovery Tool

#### Why Cache Matters for Recovery

**Offline reinstallation:**
- Reinstall packages without internet
- Repair broken installations
- Restore accidentally removed packages

**Downgrade capability:**
- Roll back problematic updates
- Restore system to working state
- Test different package versions

**System recovery:**
- Fix corrupted installations
- Rebuild package database
- Recover from failed updates

**Emergency operations:**
- Critical when mirrors are unavailable
- Essential during network outages
- Vital for isolated systems

### Cache Location and Structure

#### Default Cache Directory

```
/var/cache/pacman/pkg/
```

**Package file format:**
```
package-name-version-release-architecture.pkg.tar.zst
```

**Example:**
```
linux-6.6.1.arch1-1-x86_64.pkg.tar.zst
firefox-120.0-1-x86_64.pkg.tar.zst
```

#### Multiple Cache Directories

Configure additional cache locations in `/etc/pacman.conf`:

```
[options]
CacheDir = /var/cache/pacman/pkg/
CacheDir = /mnt/external/cache/
CacheDir = /mnt/backup/pkg-archive/
```

Pacman searches all directories when looking for cached packages.

### Using Cache for Recovery

#### Reinstalling from Cache

**Basic reinstallation:**
```
sudo pacman -U /var/cache/pacman/pkg/package-name-version.pkg.tar.zst
```

Reinstalls from cached file without downloading.

**Reinstall with dependency resolution:**
```
sudo pacman -U /var/cache/pacman/pkg/package-name-*.pkg.tar.zst
```

Uses wildcard to match current version in cache.

**Force reinstallation over existing files:**
```
sudo pacman -U --overwrite '*' /var/cache/pacman/pkg/package-name-*.pkg.tar.zst
```

Overwrites conflicting files during reinstallation.

#### Downgrading Packages

**Find available versions:**
```
ls /var/cache/pacman/pkg/package-name-*
```

**Output example:**
```
package-name-1.0-1-x86_64.pkg.tar.zst
package-name-1.1-1-x86_64.pkg.tar.zst
package-name-1.2-1-x86_64.pkg.tar.zst
```

**Downgrade to specific version:**
```
sudo pacman -U /var/cache/pacman/pkg/package-name-1.0-1-x86_64.pkg.tar.zst
```

**Prevent automatic upgrade:**
Add to `/etc/pacman.conf`:
```
IgnorePkg = package-name
```

#### Mass Reinstallation

**Reinstall all cached packages:**
```
sudo pacman -U /var/cache/pacman/pkg/*.pkg.tar.zst
```

**Warning:** This reinstalls everything in cache; use selectively.

**Reinstall specific package family:**
```
sudo pacman -U /var/cache/pacman/pkg/kde-*
```

Reinstalls all KDE-related packages from cache.

### Recovery Scenarios Using Cache

#### Scenario 1: Broken Package After Update

**Problem:** Package updated but doesn't work.

**Solution using cache:**

**1. Identify previous version:**
```
ls -lt /var/cache/pacman/pkg/package-name-* | head -5
```

**2. Downgrade:**
```
sudo pacman -U /var/cache/pacman/pkg/package-name-old-version.pkg.tar.zst
```

**3. Hold package:**
```
# Add to /etc/pacman.conf
IgnorePkg = package-name
```

**4. Report issue and wait for fix**

#### Scenario 2: Critical Package Corrupted

**Problem:** Essential package files corrupted, system unstable.

**Solution using cache:**

**1. Check cache for current version:**
```
pacman -Q package-name
ls /var/cache/pacman/pkg/package-name-$(pacman -Q package-name | awk '{print $2}')*
```

**2. Reinstall from cache:**
```
sudo pacman -U --overwrite '*' /var/cache/pacman/pkg/package-name-current-version.pkg.tar.zst
```

**3. Verify integrity:**
```
pacman -Qkk package-name
```

#### Scenario 3: Network Unavailable During Recovery

**Problem:** Need to reinstall packages but no internet.

**Solution using cache:**

**1. List what's available in cache:**
```
ls /var/cache/pacman/pkg/ | grep package-name
```

**2. Install from cache:**
```
sudo pacman -U /var/cache/pacman/pkg/package-*.pkg.tar.zst
```

**3. Satisfy dependencies from cache:**
```
# Install dependency chain
sudo pacman -U /var/cache/pacman/pkg/dep1-*.pkg.tar.zst \
               /var/cache/pacman/pkg/dep2-*.pkg.tar.zst \
               /var/cache/pacman/pkg/package-*.pkg.tar.zst
```

#### Scenario 4: Database Corruption

**Problem:** Pacman database corrupted, need to rebuild.

**Solution using cache:**

**1. Backup corrupted database:**
```
sudo cp -a /var/lib/pacman /var/lib/pacman.bak
```

**2. Reinstall all packages from cache to rebuild database:**
```
# Create list of installed packages
pacman -Qq > /tmp/installed-list.txt

# Reinstall each from cache
for pkg in $(cat /tmp/installed-list.txt); do
    PKG_FILE=$(ls /var/cache/pacman/pkg/${pkg}-*.pkg.tar.zst 2>/dev/null | tail -1)
    if [ -f "$PKG_FILE" ]; then
        sudo pacman -U --dbonly "$PKG_FILE"
    fi
done
```

**3. Verify and fix:**
```
sudo pacman -Dk
sudo pacman -Syu
```

#### Scenario 5: Kernel Boot Failure

**Problem:** New kernel doesn't boot, need to restore old kernel.

**Solution using cache:**

**1. Boot from live USB and chroot**

**2. Find previous kernel in cache:**
```
ls -lt /mnt/var/cache/pacman/pkg/linux-* | grep -v headers | head -5
```

**3. Install old kernel from cache:**
```
pacman -U --root /mnt /mnt/var/cache/pacman/pkg/linux-old-version.pkg.tar.zst
pacman -U --root /mnt /mnt/var/cache/pacman/pkg/linux-headers-old-version.pkg.tar.zst
```

**4. Rebuild initramfs:**
```
arch-chroot /mnt mkinitcpio -P
```

**5. Update bootloader:**
```
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
```

**6. Reboot**

### Cache Preservation Strategies

#### Retain Critical Package Versions

**Keep multiple versions of important packages:**
```
sudo paccache -rk5
```

Keeps 5 versions instead of default 3.

**Selective retention for critical packages:**
```bash
#!/bin/bash
# Aggressive general cleanup but preserve kernel versions

# Remove uninstalled packages
paccache -ruk0

# Keep 1 version for most packages
paccache -rk1

# Manually preserve more kernel versions
# (Don't delete from cache)
echo "Kernel versions preserved:"
ls /var/cache/pacman/pkg/linux-[0-9]* | tail -10
```

#### Archive Old Versions

**Move old packages to archive instead of deleting:**
```
sudo mkdir -p /var/cache/pacman/archive/
sudo paccache -m /var/cache/pacman/archive/ -rk1
```

The `-m` flag moves packages instead of deleting them.

**Organize by date:**
```
ARCHIVE_DIR="/var/cache/pacman/archive/$(date +%Y%m%d)"
sudo mkdir -p "$ARCHIVE_DIR"
sudo paccache -m "$ARCHIVE_DIR" -rk1
```

#### External Backup of Cache

**Backup cache to external storage:**
```
sudo rsync -av --progress /var/cache/pacman/pkg/ /mnt/external/pkg-backup/
```

**Periodic automated backup:**
```bash
#!/bin/bash
# /usr/local/bin/backup-pkg-cache

BACKUP_DIR="/mnt/external/pkg-backup/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

rsync -av --delete /var/cache/pacman/pkg/ "$BACKUP_DIR/"

# Keep only last 6 months of backups
find /mnt/external/pkg-backup/ -maxdepth 1 -type d -mtime +180 -exec rm -rf {} \;
```

**Schedule with cron:**
```
0 2 * * 0 /usr/local/bin/backup-pkg-cache
```

Runs weekly on Sunday at 2 AM.

### Creating Local Repository from Cache

#### Convert Cache to Local Repository

**Create repository database:**
```
cd /var/cache/pacman/pkg/
sudo repo-add custom.db.tar.gz *.pkg.tar.zst
```

**Add to `/etc/pacman.conf`:**
```
[custom]
SigLevel = Optional TrustAll
Server = file:///var/cache/pacman/pkg
```

**Synchronize:**
```
sudo pacman -Sy
```

**Benefits:**
- Packages appear in repository listings
- Easier searching with `pacman -Ss`
- Dependency resolution from local packages
- Useful for offline installations

#### Maintain Local Repository

**Update when adding packages:**
```
sudo repo-add /var/cache/pacman/pkg/custom.db.tar.gz /var/cache/pacman/pkg/new-package.pkg.tar.zst
```

**Rebuild entire database:**
```
cd /var/cache/pacman/pkg/
sudo rm custom.db*
sudo repo-add custom.db.tar.gz *.pkg.tar.zst
```

### Cache Sharing for Multiple Systems

#### Network-Shared Cache

**Server setup (NFS example):**
```
# Install NFS server
sudo pacman -S nfs-utils

# Export cache directory
# Add to /etc/exports:
/var/cache/pacman/pkg 192.168.1.0/24(ro,sync,no_subtree_check)

# Start NFS server
sudo systemctl enable --now nfs-server
```

**Client setup:**
```
# Mount shared cache
sudo mount server:/var/cache/pacman/pkg /mnt/shared-cache

# Configure pacman to use shared cache
# Add to /etc/pacman.conf:
CacheDir = /mnt/shared-cache
CacheDir = /var/cache/pacman/pkg
```

**Benefits:**
- Reduces redundant downloads across network
- Centralized cache management
- All systems benefit from any download

### Cache Verification and Maintenance

#### Verify Cache Integrity

**Check for corrupted packages:**
```bash
#!/bin/bash
# Verify all cached packages

for pkg in /var/cache/pacman/pkg/*.pkg.tar.zst; do
    if ! tar -tzf "$pkg" &>/dev/null; then
        echo "Corrupted: $pkg"
    fi
done
```

**Remove corrupted packages:**
```bash
#!/bin/bash
# Remove corrupted packages from cache

for pkg in /var/cache/pacman/pkg/*.pkg.tar.zst; do
    if ! tar -tzf "$pkg" &>/dev/null; then
        echo "Removing corrupted: $pkg"
        rm "$pkg"
    fi
done
```

#### Remove Duplicate Versions

Sometimes multiple downloads create duplicates:

```bash
#!/bin/bash
# Keep only newest file for each package version

cd /var/cache/pacman/pkg/
for pkg in *.pkg.tar.zst; do
    BASE="${pkg%.pkg.tar.zst}"
    # Find duplicates
    DUPES=$(ls "${BASE}"*.pkg.tar.zst 2>/dev/null | wc -l)
    if [ $DUPES -gt 1 ]; then
        # Keep newest, remove others
        ls -t "${BASE}"*.pkg.tar.zst | tail -n +2 | xargs rm
    fi
done
```

### Best Practices for Recovery-Focused Cache Management

#### Balanced Retention Policy

**Conservative approach (recommended):**
```
sudo paccache -rk3      # Keep 3 versions of installed
sudo paccache -ruk1     # Keep 1 version of uninstalled
```

Provides downgrade capability while managing space.

**Aggressive approach (limited space):**
```
sudo paccache -rk1      # Keep 1 version of installed
sudo paccache -ruk0     # Remove all uninstalled
```

Minimal space usage, limited recovery options.

**Archival approach (ample space):**
```
# Don't use paccache; keep everything
# Or keep many versions:
sudo paccache -rk10
```

Maximum recovery capability, high space usage.

#### Critical Package Preservation

**Never delete critical package versions:**
- Current and previous kernel
- Current bootloader
- Current and previous glibc
- Current systemd

**Exclude from automatic cleaning:**
```bash
#!/bin/bash
# Custom cache cleaning preserving critical packages

CRITICAL_PKGS="linux linux-headers glibc systemd grub"

# Clean normally
paccache -rk1

# Restore critical packages (keep 5 versions)
for pkg in $CRITICAL_PKGS; do
    # Restore from archive or don't delete in first place
    echo "Preserved: $pkg"
done
```

#### Regular Cache Audits

**Monthly cache review:**
```
# Check cache size
du -sh /var/cache/pacman/pkg/

# Count packages
ls /var/cache/pacman/pkg/*.pkg.tar.zst | wc -l

# Identify largest packages
du -h /var/cache/pacman/pkg/*.pkg.tar.zst | sort -rh | head -20

# Clean based on findings
sudo paccache -rk3
```

### Emergency Recovery Procedures

#### Using Cache in Chroot

**From live USB:**
```
# Mount system
mount /dev/sdXn /mnt
arch-chroot /mnt

# Cache is available at standard location
ls /var/cache/pacman/pkg/

# Reinstall from cache
pacman -U /var/cache/pacman/pkg/package-*.pkg.tar.zst
```

#### Restoring from Archived Cache

**If you moved cache to archive:**
```
# Copy needed packages back
sudo cp /var/cache/pacman/archive/package-*.pkg.tar.zst /var/cache/pacman/pkg/

# Install
sudo pacman -U /var/cache/pacman/pkg/package-*.pkg.tar.zst
```

### Documentation and Tracking

#### Cache Inventory

**Maintain list of cached packages:**
```bash
#!/bin/bash
# Generate cache inventory

ls /var/cache/pacman/pkg/*.pkg.tar.zst | \
    sed 's|/var/cache/pacman/pkg/||' | \
    sed 's|\.pkg\.tar\.zst||' > /var/cache/pacman/inventory-$(date +%Y%m%d).txt
```

**Benefits:**
- Know what's available for recovery
- Plan cache cleaning decisions
- Track cache growth over time

The package cache is your safety net for system recovery, enabling downgrades, offline operations, and rebuilding without internet access. Proper cache management preserves recovery capability while controlling disk usage.

