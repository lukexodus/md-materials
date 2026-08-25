## Local Repository Setup


### Overview

A local repository allows you to host Arch Linux packages on your own system or local network, enabling offline package installation, faster access than remote mirrors, and centralized package management for multiple systems.

### Prerequisites

#### Required Tools

**Install necessary packages:**
```bash
sudo pacman -S pacman-contrib base-devel
```

**pacman-contrib** includes `repo-add` and `repo-remove` utilities.

**Verify installation:**
```bash
which repo-add
which repo-remove
```

### Creating a Basic Local Repository

#### Step 1: Create Repository Directory

**Choose a location:**
```bash
# Option 1: Home directory
mkdir -p ~/arch-repo

# Option 2: System-wide location
sudo mkdir -p /srv/arch-repo
sudo chown $USER:$USER /srv/arch-repo

# Option 3: Separate partition (if mounted)
mkdir -p /mnt/packages/arch-repo
```

**Use home directory for examples:**
```bash
mkdir -p ~/arch-repo
cd ~/arch-repo
```

#### Step 2: Add Packages to Repository

**Copy from package cache:**
```bash
# Copy all cached packages
cp /var/cache/pacman/pkg/*.pkg.tar.zst ~/arch-repo/

# Or copy specific packages
cp /var/cache/pacman/pkg/firefox-*.pkg.tar.zst ~/arch-repo/
cp /var/cache/pacman/pkg/linux-*.pkg.tar.zst ~/arch-repo/
```

**Build and add packages:**
```bash
# Build AUR package
cd ~/aur/my-package
makepkg -s

# Move to repository
mv my-package-*.pkg.tar.zst ~/arch-repo/
```

**Copy pre-built packages:**
```bash
# From another system
scp user@remote-system:/path/to/package.pkg.tar.zst ~/arch-repo/
```

#### Step 3: Initialize Repository Database

**Create database:**
```bash
cd ~/arch-repo
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

**Output:**
```
Creating database...
Adding firefox-120.0-1 (1/5)
Adding linux-6.6.1.arch1-1 (2/5)
Adding ...
```

**Verify database creation:**
```bash
ls -la ~/arch-repo/
```

**Output:**
```
-rw-r--r-- myrepo.db
-rw-r--r-- myrepo.db.tar.gz
-rw-r--r-- myrepo.files
-rw-r--r-- myrepo.files.tar.gz
```

#### Step 4: Configure Pacman

**Edit pacman configuration:**
```bash
sudo nano /etc/pacman.conf
```

**Add repository at the end (before any other custom repos):**
```ini
[myrepo]
SigLevel = Optional TrustAll
Server = file:///home/username/arch-repo
```

**For system-wide location:**
```ini
[myrepo]
SigLevel = Optional TrustAll
Server = file:///srv/arch-repo
```

**Important paths:**
- `file:///` - Absolute path
- `file://$HOME/` - Uses $HOME variable
- Must be three slashes: `file:///`

#### Step 5: Synchronize and Verify

**Sync package databases:**
```bash
pacman -Sy
```

**List repository packages:**
```bash
pacman -Sl myrepo
```

**Output:**
```
myrepo firefox 120.0-1
myrepo linux 6.6.1.arch1-1
myrepo linux-headers 6.6.1.arch1-1
```

**Search repository:**
```bash
pacman -Ss myrepo
```

#### Step 6: Install Packages

**Install from local repository:**
```bash
sudo pacman -S myrepo/firefox
```

**Or install without specifying repository:**
```bash
sudo pacman -S firefox
```

Pacman will prefer the version in your local repository if versions match.

### Repository Maintenance

#### Updating Repository Packages

**Add new packages to existing repository:**
```bash
# Build or obtain package
cd ~/aur/new-package
makepkg -s
mv new-package-*.pkg.tar.zst ~/arch-repo/

# Rebuild database
cd ~/arch-repo
repo-add myrepo.db.tar.gz *.pkg.tar.zst

# Sync on client
pacman -Sy
```

**Update package in repository:**
```bash
# Remove old version
cd ~/arch-repo
rm old-package-1.0-1-*.pkg.tar.zst

# Add new version
cp ~/aur/old-package/old-package-2.0-1-x86_64.pkg.tar.zst .

# Rebuild database
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

#### Removing Packages

**Remove package from repository:**
```bash
cd ~/arch-repo

# Delete package file
rm package-name-*.pkg.tar.zst

# Remove from database
repo-remove myrepo.db.tar.gz package-name

# Or rebuild entire database
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

**Verify removal:**
```bash
pacman -Sy
pacman -Sl myrepo | grep package-name
```

Should show no results.

#### Database Cleanup

**Clear database completely:**
```bash
cd ~/arch-repo
rm myrepo.db*
rm myrepo.files*

# Recreate from scratch
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

### Advanced Repository Setup

#### Multiple Repository Channels

**Organize by purpose:**
```bash
mkdir -p ~/arch-repo/{core,aur,custom,testing}
```

**Create separate databases:**
```bash
# Core packages
repo-add ~/arch-repo/core/core.db.tar.gz ~/arch-repo/core/*.pkg.tar.zst

# AUR packages
repo-add ~/arch-repo/aur/aur.db.tar.gz ~/arch-repo/aur/*.pkg.tar.zst

# Custom builds
repo-add ~/arch-repo/custom/custom.db.tar.gz ~/arch-repo/custom/*.pkg.tar.zst
```

**Configure in pacman.conf:**
```ini
[core-local]
SigLevel = Optional TrustAll
Server = file:///home/username/arch-repo/core

[aur-local]
SigLevel = Optional TrustAll
Server = file:///home/username/arch-repo/aur

[custom-local]
SigLevel = Optional TrustAll
Server = file:///home/username/arch-repo/custom
```

#### Repository with Signatures

**Sign packages:**
```bash
cd ~/arch-repo
gpg --detach-sign --armor *.pkg.tar.zst
```

**Sign database:**
```bash
gpg --detach-sign --armor myrepo.db.tar.gz
gpg --detach-sign --armor myrepo.files.tar.gz
```

**Configure signed repository:**
```ini
[myrepo]
SigLevel = Required
Server = file:///home/username/arch-repo
```

**Client setup:**
```bash
# Import signer's public key
gpg --recv-keys YOUR_KEY_ID

# Trust key
gpg --edit-key YOUR_KEY_ID
# Type: trust
# Select: 5 (I trust ultimately)
# Type: quit
```

### Repository Scripts and Automation

#### Automatic Repository Update Script

```bash
#!/bin/bash
# /usr/local/bin/update-local-repo
# Update local repository with new packages

REPO_DIR="$HOME/arch-repo"
REPO_NAME="myrepo"
LOG_FILE="/tmp/repo-update-$(date +%Y%m%d).log"

{
    echo "=== Local Repository Update ==="
    echo "Started: $(date)"
    echo ""
    
    # Check repository directory
    if [ ! -d "$REPO_DIR" ]; then
        echo "Error: Repository directory not found: $REPO_DIR"
        exit 1
    fi
    
    cd "$REPO_DIR"
    
    # Count packages before
    PKG_BEFORE=$(ls -1 *.pkg.tar.zst 2>/dev/null | wc -l)
    echo "Packages before: $PKG_BEFORE"
    
    # Copy new packages from cache
    echo "Copying new packages from cache..."
    cp /var/cache/pacman/pkg/*.pkg.tar.zst . 2>/dev/null || true
    
    # Count packages after
    PKG_AFTER=$(ls -1 *.pkg.tar.zst 2>/dev/null | wc -l)
    echo "Packages after: $PKG_AFTER"
    echo "New packages added: $((PKG_AFTER - PKG_BEFORE))"
    echo ""
    
    # Rebuild database
    echo "Rebuilding database..."
    repo-add "$REPO_NAME.db.tar.gz" *.pkg.tar.zst
    
    # Verify
    echo ""
    echo "Repository contents:"
    pacman -Sy
    pacman -Sl "$REPO_NAME" | wc -l
    
    echo ""
    echo "Completed: $(date)"
    
} | tee "$LOG_FILE"
```

**Installation:**
```bash
chmod +x /usr/local/bin/update-local-repo
```

**Usage:**
```bash
update-local-repo
```

#### Batch Build and Repository Script

```bash
#!/bin/bash
# /usr/local/bin/build-and-repo
# Build AUR packages and add to local repository

REPO_DIR="$HOME/arch-repo"
REPO_NAME="myrepo"
AUR_DIR="$HOME/aur"

# List of packages to build
PACKAGES=(
    "package1"
    "package2"
    "my-aur-package"
)

main() {
    echo "=== Building packages for local repository ==="
    
    for pkg in "${PACKAGES[@]}"; do
        if [ ! -d "$AUR_DIR/$pkg" ]; then
            echo "✗ $pkg: Directory not found"
            continue
        fi
        
        echo "Building $pkg..."
        
        cd "$AUR_DIR/$pkg"
        
        # Update from AUR
        git pull
        
        # Build package
        if makepkg -s --noconfirm; then
            echo "✓ $pkg: Build successful"
            
            # Move to repository
            mv *.pkg.tar.zst "$REPO_DIR/" 2>/dev/null
            echo "  Added to repository"
        else
            echo "✗ $pkg: Build failed"
        fi
    done
    
    # Update repository database
    echo ""
    echo "Updating repository database..."
    cd "$REPO_DIR"
    repo-add "$REPO_NAME.db.tar.gz" *.pkg.tar.zst
    
    echo "Done"
}

main
```

#### Scheduled Maintenance Script

```bash
#!/bin/bash
# /usr/local/bin/maintain-local-repo
# Maintain local repository (cleanup, verification)

REPO_DIR="$HOME/arch-repo"
REPO_NAME="myrepo"
KEEP_VERSIONS=3

main() {
    echo "=== Local Repository Maintenance ==="
    
    cd "$REPO_DIR"
    
    # Remove old package versions
    echo "Cleaning old package versions..."
    
    for pkg_base in $(ls *.pkg.tar.zst | sed 's/-[^-]*-[^-]*-[^-]*\.pkg\.tar\.zst$//' | sort -u); do
        versions=$(ls "${pkg_base}"-*.pkg.tar.zst 2>/dev/null | sort -V)
        count=$(echo "$versions" | wc -l)
        
        if [ $count -gt $KEEP_VERSIONS ]; then
            echo "$versions" | head -n $((count - KEEP_VERSIONS)) | while read old_pkg; do
                echo "  Removing: $old_pkg"
                rm "$old_pkg"
            done
        fi
    done
    
    # Verify package integrity
    echo ""
    echo "Verifying package integrity..."
    
    for pkg in *.pkg.tar.zst; do
        if tar -tzf "$pkg" &>/dev/null; then
            echo "  ✓ $pkg"
        else
            echo "  ✗ $pkg (CORRUPTED)"
            rm "$pkg"
        fi
    done
    
    # Rebuild database
    echo ""
    echo "Rebuilding database..."
    repo-add "$REPO_NAME.db.tar.gz" *.pkg.tar.zst
    
    # Statistics
    echo ""
    echo "Repository statistics:"
    echo "  Total packages: $(ls -1 *.pkg.tar.zst 2>/dev/null | wc -l)"
    echo "  Repository size: $(du -sh . | cut -f1)"
    
    echo "Done"
}

main
```

### Network Access to Local Repository

#### Share via HTTP (Nginx)

**Setup:**
```bash
sudo mkdir -p /srv/http/arch-repo
sudo cp -r ~/arch-repo/* /srv/http/arch-repo/
sudo chown -R http:http /srv/http/arch-repo
```

**Configure Nginx:**
```nginx
server {
    listen 80;
    server_name localhost;
    
    location /arch-repo/ {
        root /srv/http;
        autoindex on;
    }
}
```

**Reload Nginx:**
```bash
sudo systemctl reload nginx
```

**Configure clients:**
```ini
[myrepo]
SigLevel = Optional TrustAll
Server = http://localhost/arch-repo
```

#### Share via NFS

**Server setup:**
```bash
sudo pacman -S nfs-utils

# Export repository
sudo nano /etc/exports
# Add: /home/user/arch-repo 192.168.1.0/24(ro,sync,no_subtree_check)

sudo systemctl enable --now nfs-server
```

**Client setup:**
```bash
sudo mount -t nfs server-ip:/home/user/arch-repo /mnt/arch-repo

# Configure pacman
# [myrepo]
# Server = file:///mnt/arch-repo
```

### Troubleshooting

#### Repository not showing packages

**Verify configuration:**
```bash
grep -A2 "\[myrepo\]" /etc/pacman.conf
```

**Rebuild database:**
```bash
cd ~/arch-repo
repo-add myrepo.db.tar.gz *.pkg.tar.zst
```

**Refresh pacman:**
```bash
pacman -Sy
```

#### Corrupted database

**Symptoms:**
```
error: failed to prepare transaction (database is not valid)
```

**Solution:**
```bash
cd ~/arch-repo
rm myrepo.db*
rm myrepo.files*
repo-add myrepo.db.tar.gz *.pkg.tar.zst
pacman -Sy
```

#### Permission denied errors

**Fix permissions:**
```bash
chmod 755 ~/arch-repo
chmod 644 ~/arch-repo/*
chmod 644 ~/arch-repo/*.db*
chmod 644 ~/arch-repo/*.files*
```

### Best Practices

**Organize structure:** Use subdirectories by category or purpose.

**Maintain versions:** Keep multiple versions for downgrade capability.

**Automate updates:** Use cron or systemd timers for regular maintenance.

**Backup regularly:** Backup repository directory and database.

**Documentation:** Document repository location and access methods.

**Version control:** Track PKGBUILD and package metadata in git.

**Monitor size:** Keep eye on repository growth.

**Test packages:** Verify packages before adding to repository.

**Security:** Use GPG signing for remote repositories.

**Access control:** Restrict write access to authorized users only.

Local repositories provide convenient package management, faster installation, and offline access while maintaining full Arch Linux compatibility.

