## Offline Package Management


### Overview

Offline package management allows installing, updating, and managing packages without internet access. This is essential for systems without connectivity, air-gapped networks, organizational deployments, and emergency recovery situations.

### Preparation: Building Offline Resources

#### Collect Packages for Offline Use

**On system with internet:**
```bash
# Download packages without installing
pacman -Syuw
```

This syncs databases and downloads all available updates to cache without installing.

**Verify downloads:**
```bash
ls /var/cache/pacman/pkg/ | wc -l
```

#### Export Package Cache

**Create portable storage:**
```bash
# Create archive of cached packages
tar -czf arch-packages-$(date +%Y%m%d).tar.gz /var/cache/pacman/pkg/

# Or copy to removable media
cp -r /var/cache/pacman/pkg /mnt/usb-drive/pacman-cache
```

**Size consideration:**
```bash
# Check total size
du -sh /var/cache/pacman/pkg/
```

#### Create Offline Repository

**Best method for offline systems:**
```bash
# Setup as described in "Local Repository Setup"
mkdir -p ~/offline-repo
cp /var/cache/pacman/pkg/*.pkg.tar.zst ~/offline-repo/

# Create repository database
cd ~/offline-repo
repo-add offline.db.tar.gz *.pkg.tar.zst

# Create portable archive
tar -czf offline-repo.tar.gz ~/offline-repo/
```

### Transferring Packages to Offline System

#### USB Drive Transfer

**Prepare on online system:**
```bash
# Format USB drive
sudo mkfs.ext4 /dev/sdX1

# Mount USB
sudo mkdir -p /mnt/usb
sudo mount /dev/sdX1 /mnt/usb

# Copy packages
cp -r /var/cache/pacman/pkg /mnt/usb/

# Unmount
sudo umount /mnt/usb
```

**On offline system:**
```bash
# Mount USB
sudo mkdir -p /mnt/usb
sudo mount /dev/sdX1 /mnt/usb

# Verify packages
ls /mnt/usb/pkg/ | head -20
```

#### Network Transfer Before Disconnection

**Before going offline, download packages:**
```bash
# Download specific packages
pacman -Sw firefox vlc gimp

# Download with dependencies
pacman -Sw base-devel

# These are saved to /var/cache/pacman/pkg/
```

#### External Hard Drive

**Backup entire package cache:**
```bash
# On online system
rsync -av /var/cache/pacman/pkg/ /mnt/external-drive/pacman-pkg/

# Transfer to offline system
rsync -av /mnt/external-drive/pacman-pkg/ /var/cache/pacman/pkg/
```

### Installing from Local Cache

#### Using Pacman with Local Packages

**Install from cache:**
```bash
sudo pacman -U /var/cache/pacman/pkg/firefox-120.0-1-x86_64.pkg.tar.zst
```

**Install multiple packages:**
```bash
sudo pacman -U /var/cache/pacman/pkg/firefox-*.pkg.tar.zst \
                /var/cache/pacman/pkg/vlc-*.pkg.tar.zst
```

**Install all cached packages:**
```bash
sudo pacman -U /var/cache/pacman/pkg/*.pkg.tar.zst
```

**Wildcard caution:**
```bash
# This installs everything in cache
# May include multiple versions of same package
# Be selective when possible
```

#### Installing from Directory

**Copy packages to system:**
```bash
# Create offline packages directory
mkdir -p ~/offline-packages
cd ~/offline-packages

# Extract from USB
cp /mnt/usb/pkg/*.pkg.tar.zst .
```

**Install from directory:**
```bash
sudo pacman -U ~/offline-packages/*.pkg.tar.zst
```

### Using Offline Repository

#### Setup Offline Repository on Target System

**Extract repository archive:**
```bash
tar -xzf offline-repo.tar.gz -C ~
```

**Configure pacman:**
```bash
sudo nano /etc/pacman.conf
```

**Add offline repository:**
```ini
[offline]
SigLevel = Optional TrustAll
Server = file:///home/username/offline-repo
```

**Sync offline repository:**
```bash
pacman -Sy
```

**Verify repository:**
```bash
pacman -Sl offline
```

**Install from offline repository:**
```bash
sudo pacman -S offline/firefox offline/vlc
```

### Offline System Recovery

#### Recovery Scenario: No Internet During Update Failure

**Problem:** Update failed, internet unavailable for recovery.

**Solution:**

**1. Restore from cache:**
```bash
# Check what's in cache
ls /var/cache/pacman/pkg/

# Reinstall last known working version
sudo pacman -U /var/cache/pacman/pkg/broken-package-old-version.pkg.tar.zst
```

**2. If cache is empty:**
```bash
# Restore from USB with packages
sudo mount /dev/usb /mnt/usb
sudo pacman -U /mnt/usb/pkg/broken-package-*.pkg.tar.zst
```

**3. Use chroot recovery:**
```bash
# From live USB with packages
mount /dev/sda2 /mnt
mount /dev/usb /mnt/usb

# Setup offline repository in mounted system
cp /mnt/usb/pkg/*.pkg.tar.zst /mnt/var/cache/pacman/pkg/

# Chroot and recover
arch-chroot /mnt
pacman -U /var/cache/pacman/pkg/broken-package-*.pkg.tar.zst
```

### Offline Backup Strategy

#### Create Complete Offline System Backup

**Backup script:**
```bash
#!/bin/bash
# offline-backup.sh - Create complete offline backup

BACKUP_DIR="/mnt/backup"
DATE=$(date +%Y%m%d)

# 1. Backup package cache
echo "Backing up package cache..."
rsync -av /var/cache/pacman/pkg/ "$BACKUP_DIR/pacman-pkg/"

# 2. Create repository database
echo "Creating offline repository..."
cd "$BACKUP_DIR/pacman-pkg"
repo-add offline.db.tar.gz *.pkg.tar.zst

# 3. Backup system configuration
echo "Backing up system configuration..."
tar -czf "$BACKUP_DIR/etc-$DATE.tar.gz" /etc

# 4. Backup installed package list
echo "Backing up package list..."
pacman -Q > "$BACKUP_DIR/installed-packages-$DATE.txt"
pacman -Qe > "$BACKUP_DIR/explicit-packages-$DATE.txt"

# 5. Create recovery USB if path exists
if [ -d "/mnt/usb" ]; then
    echo "Creating recovery media..."
    cp -r "$BACKUP_DIR" /mnt/usb/system-backup-$DATE
fi

echo "Backup complete"
```

#### Backup PKGBUILD Files

**Keep AUR source files:**
```bash
# Archive all AUR build directories
tar -czf aur-sources-$(date +%Y%m%d).tar.gz ~/aur/

# Or specific packages
tar -czf critical-aur.tar.gz ~/aur/package1 ~/aur/package2
```

**Benefits:**
- Rebuild packages offline if needed
- Keep version history
- Reference for customizations

### Offline Dependency Resolution

#### Manual Dependency Analysis

**Find all dependencies for package:**
```bash
pacman -Si firefox | grep "Depends On"
```

**Create dependency list:**
```bash
#!/bin/bash
# get-deps.sh - Get all dependencies for package

get_all_deps() {
    local pkg="$1"
    pacman -Si "$pkg" | grep "Depends On" | sed 's/Depends On[[:space:]]*//'
}

# Usage
get_all_deps firefox | tr ' ' '\n' | while read dep; do
    echo "Package: $dep"
    get_all_deps "$dep"
done
```

**Download package and all dependencies:**
```bash
pacman -Sw firefox
# pacman automatically downloads all dependencies
```

#### Pre-Calculate Offline Installations

**Script to prepare packages:**
```bash
#!/bin/bash
# prepare-offline.sh - Prepare packages for offline installation

PACKAGES=(
    "base"
    "base-devel"
    "firefox"
    "vlc"
    "git"
)

OFFLINE_DIR="$HOME/offline-complete"
mkdir -p "$OFFLINE_DIR"

for pkg in "${PACKAGES[@]}"; do
    echo "Analyzing $pkg..."
    
    # Get package and all dependencies
    pacman -Sw "$pkg" --noconfirm 2>/dev/null
done

# Copy everything to offline directory
cp /var/cache/pacman/pkg/* "$OFFLINE_DIR/"

# Create repository
cd "$OFFLINE_DIR"
repo-add complete.db.tar.gz *.pkg.tar.zst

echo "Offline packages ready in $OFFLINE_DIR"
```

### Offline Updates

#### Plan Updates Offline

**Before going offline:**
```bash
# Check for available updates
checkupdates > ~/available-updates.txt

# Download all updates
pacman -Syu --print 2>/dev/null | while read line; do
    pacman -Sw "$line" --noconfirm 2>/dev/null
done
```

**Offline:**
```bash
# Install downloaded updates
sudo pacman -U /var/cache/pacman/pkg/*.pkg.tar.zst
```

#### Staged Offline Updates

**Create update packages by category:**
```bash
mkdir -p ~/offline-updates/{system,development,multimedia}

# Download by category
pacman -Sw base systemd linux > /dev/null
mv /var/cache/pacman/pkg/base*.pkg.tar.zst ~/offline-updates/system/

pacman -Sw gcc base-devel > /dev/null
mv /var/cache/pacman/pkg/{gcc,base-devel}*.pkg.tar.zst ~/offline-updates/development/

pacman -Sw vlc ffmpeg > /dev/null
mv /var/cache/pacman/pkg/{vlc,ffmpeg}*.pkg.tar.zst ~/offline-updates/multimedia/
```

### Documentation for Offline Environments

#### Create Reference Documentation

**System documentation:**
```bash
#!/bin/bash
# create-offline-docs.sh

DOCS_DIR="$HOME/offline-docs"
mkdir -p "$DOCS_DIR"

# 1. Pacman cheat sheet
cat > "$DOCS_DIR/pacman-commands.txt" << 'EOF'
# Offline Pacman Commands
pacman -U /path/to/package.pkg.tar.zst    # Install from file
pacman -Q                                  # List installed packages
pacman -Ql package                        # List package files
pacman -Qi package                        # Get package info
pacman -Qk package                        # Verify package files
pacman -Rns package                       # Remove package
EOF

# 2. Installed packages list
pacman -Q > "$DOCS_DIR/installed-packages.txt"

# 3. AUR package list
pacman -Qm > "$DOCS_DIR/aur-packages.txt"

# 4. System info
uname -a > "$DOCS_DIR/system-info.txt"
lsb_release -a >> "$DOCS_DIR/system-info.txt"

# 5. Package cache info
du -sh /var/cache/pacman/pkg/ > "$DOCS_DIR/cache-size.txt"

echo "Documentation created in $DOCS_DIR"
```

#### Recovery Procedures Document

```
OFFLINE RECOVERY PROCEDURES
===========================

1. No Network Access During Update Failure
   - Check /var/cache/pacman/pkg for previous versions
   - Use pacman -U to install from cache
   - Or restore from USB backup

2. Missing Package Dependencies
   - Download all dependencies from connected system
   - Copy to /var/cache/pacman/pkg
   - Install with pacman -U

3. Complete System Reinstall Offline
   - Boot from offline media with pacman
   - Extract package cache
   - Use pacman to install base system
   - Restore configuration from backup

4. AUR Package Rebuild Offline
   - Keep PKGBUILD files on backup media
   - Extract and modify PKGBUILD as needed
   - Run makepkg -si offline
```

### Automation Scripts

#### Offline Package Manager Wrapper

```bash
#!/bin/bash
# /usr/local/bin/offline-pac
# Wrapper for pacman in offline environments

# Check internet connectivity
is_online() {
    ping -c 1 -W 2 archlinux.org &>/dev/null
}

# Redirect to offline repo if no internet
main() {
    if ! is_online; then
        echo "No internet detected. Using offline mode."
        
        # Configure offline repository if needed
        if ! grep -q "\[offline\]" /etc/pacman.conf; then
            echo "Warning: No offline repository configured"
            echo "Use: offline-setup to configure"
        fi
    fi
    
    # Pass through to pacman
    pacman "$@"
}

main "$@"
```

### Best Practices

**Preparation:**
- Download packages regularly
- Maintain offline repository
- Backup PKGBUILD files
- Document system state

**Storage:**
- Use external hard drives for large caches
- Keep multiple USB backups
- Store in safe location
- Verify integrity periodically

**Recovery:**
- Test recovery procedures before needed
- Keep recovery media updated
- Document all procedures
- Train on offline operations

**Organization:**
- Organize packages by category
- Label backup media clearly
- Date all backups
- Maintain inventory

**Security:**
- Encrypt sensitive backups
- Verify package signatures when possible
- Secure backup storage
- Document access procedures

Offline package management ensures system maintenance capability even without internet access, critical for air-gapped systems, remote locations, and disaster recovery scenarios.

