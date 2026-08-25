## Custom Repository Creation


### Overview

A custom repository is a collection of Arch Linux packages organized as a repository that pacman can install from. Custom repositories enable sharing packages within a team, organization, or across personal systems, and can contain official packages, AUR packages, or custom-built software.

### Repository Types

#### Local Repository

**Location:** Single machine's filesystem
**Use cases:** Personal package testing, offline installation, local package management

#### Network Repository

**Location:** Network-accessible server (HTTP, HTTPS, NFS)
**Use cases:** Team sharing, organization-wide distribution, package mirroring

#### Remote Repository

**Location:** Internet-hosted (GitHub, custom server)
**Use cases:** Public package distribution, open-source projects, community repositories

### Creating a Local Repository

#### Step 1: Create Repository Directory

```bash
# Create directory for packages
mkdir -p ~/my-repo
cd ~/my-repo
```

#### Step 2: Add Packages

**Copy pre-built packages:**
```bash
# Copy from cache
cp /var/cache/pacman/pkg/my-package-1.0-1-x86_64.pkg.tar.zst .

# Copy AUR packages you built
cp ~/aur/my-aur-package/my-aur-package-1.0-1-x86_64.pkg.tar.zst .
```

**Build packages directly:**
```bash
# Build and place in repository
cd ~/aur/my-package
makepkg -s
mv my-package-1.0-1-x86_64.pkg.tar.zst ~/my-repo/
```

**Example directory structure:**
```
~/my-repo/
├── custom-package-1.0-1-x86_64.pkg.tar.zst
├── another-package-2.0-1-x86_64.pkg.tar.zst
└── my-app-3.5-2-x86_64.pkg.tar.zst
```

#### Step 3: Create Repository Database

**Initialize database:**
```bash
cd ~/my-repo
repo-add custom.db.tar.gz *.pkg.tar.zst
```

**Output:**
```
Creating database...
Adding custom-package...
Adding another-package...
Adding my-app...
```

**Files created:**
```
custom.db.tar.gz       # Main database (symlink)
custom.db             # Extracted database
custom.files.tar.gz   # File index (symlink)
custom.files          # Extracted file index
```

#### Step 4: Configure Pacman

**Edit `/etc/pacman.conf`:**
```bash
sudo nano /etc/pacman.conf
```

**Add repository section:**
```ini
[custom]
SigLevel = Optional TrustAll
Server = file:///home/user/my-repo
```

**For different locations:**
```ini
# Local absolute path
Server = file:///home/user/my-repo

# Relative to home
Server = file://$HOME/my-repo

# Current directory
Server = file://.
```

#### Step 5: Synchronize

**Update package databases:**
```bash
pacman -Sy
```

**Verify repository is registered:**
```bash
pacman -Sl custom
```

**Output:**
```
custom custom-package 1.0-1
custom another-package 2.0-1
custom my-app 3.5-2
```

#### Step 6: Install Packages

**Install from custom repository:**
```bash
pacman -S custom/custom-package
```

**Or without specifying repository (if no conflicts):**
```bash
pacman -S custom-package
```

### Managing Repository Packages

#### Adding New Packages

**Build and add:**
```bash
cd ~/aur/new-package
makepkg -s
mv new-package-*.pkg.tar.zst ~/my-repo/

# Rebuild database
cd ~/my-repo
repo-add custom.db.tar.gz *.pkg.tar.zst
```

**Refresh in pacman:**
```bash
pacman -Sy
```

#### Removing Packages

**Delete package file:**
```bash
cd ~/my-repo
rm old-package-*.pkg.tar.zst

# Rebuild database
repo-add custom.db.tar.gz *.pkg.tar.zst
```

#### Updating Packages

**Rebuild package:**
```bash
cd ~/aur/my-package
makepkg -si  # Update version in PKGBUILD first
mv my-package-*.pkg.tar.zst ~/my-repo/
```

**Update database:**
```bash
cd ~/my-repo
repo-add custom.db.tar.gz *.pkg.tar.zst
```

### Network Repository

#### HTTP/HTTPS Repository

**Setup web server:**
```bash
# Install web server
sudo pacman -S nginx
# or
sudo pacman -S apache

# Create directory
sudo mkdir -p /srv/http/arch-repo
sudo chown http:http /srv/http/arch-repo

# Copy packages
sudo cp ~/my-repo/*.pkg.tar.zst /srv/http/arch-repo/
sudo cp ~/my-repo/custom.db* /srv/http/arch-repo/
```

**Nginx configuration:**
```nginx
server {
    listen 80;
    server_name repo.example.com;
    
    root /srv/http;
    
    location /arch-repo/ {
        autoindex on;
        types {
            application/x-tar.zst zst;
        }
    }
}
```

**Enable and start Nginx:**
```bash
sudo systemctl enable --now nginx
```

**Configure on client:**
```ini
# /etc/pacman.conf
[custom]
SigLevel = Optional TrustAll
Server = http://repo.example.com/arch-repo
```

#### NFS Repository

**Server setup:**
```bash
# Install NFS
sudo pacman -S nfs-utils

# Create export
sudo mkdir -p /srv/arch-repo
sudo cp ~/my-repo/* /srv/arch-repo/

# Export in /etc/exports
/srv/arch-repo 192.168.1.0/24(ro,sync,no_subtree_check)

# Start NFS
sudo systemctl enable --now nfs-server
```

**Client setup:**
```bash
# Mount repository
sudo mkdir -p /mnt/arch-repo
sudo mount -t nfs server:/srv/arch-repo /mnt/arch-repo

# Configure pacman
# /etc/pacman.conf
[custom]
SigLevel = Optional TrustAll
Server = file:///mnt/arch-repo
```

### Repository with Package Signing

#### Generate GPG Key

**Create key (if not already done):**
```bash
gpg --gen-key
```

**List keys:**
```bash
gpg --list-keys
```

#### Sign Packages

**Sign individual package:**
```bash
cd ~/my-repo
gpg --detach-sign --armor custom-package-1.0-1-x86_64.pkg.tar.zst
```

Creates `custom-package-1.0-1-x86_64.pkg.tar.zst.asc`.

**Sign repository database:**
```bash
gpg --detach-sign --armor custom.db.tar.gz
gpg --detach-sign --armor custom.files.tar.gz
```

#### Configure Signed Repository

**Update pacman.conf:**
```ini
[custom]
SigLevel = Required
Server = file:///home/user/my-repo
```

**Import public key on client:**
```bash
gpg --recv-keys YOUR_KEY_ID
# or manually
gpg --import /path/to/public-key.asc
```

### Repository Automation

#### Auto-Build and Update Script

```bash
#!/bin/bash
# /usr/local/bin/update-custom-repo
# Automatically build and add packages to repository

REPO_DIR="$HOME/my-repo"
AUR_DIR="$HOME/aur"
REPO_NAME="custom"

# Configuration
PACKAGES=(
    "package1"
    "package2"
    "my-aur-package"
)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Build packages
for pkg in "${PACKAGES[@]}"; do
    if [ -d "$AUR_DIR/$pkg" ]; then
        log "Building $pkg..."
        
        cd "$AUR_DIR/$pkg"
        git pull
        
        # Check if update is needed
        CURRENT_VERSION=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}' || echo "none")
        AVAILABLE_VERSION=$(grep "^pkgver=" PKGBUILD | cut -d= -f2)
        
        if [ "$CURRENT_VERSION" != "$AVAILABLE_VERSION" ]; then
            log "Version change detected: $CURRENT_VERSION -> $AVAILABLE_VERSION"
            
            # Clean and build
            makepkg -Ccis --noconfirm
            
            # Move to repo
            mv *.pkg.tar.zst "$REPO_DIR/" 2>/dev/null || true
            
            log "Built and moved $pkg"
        else
            log "$pkg is up to date"
        fi
    fi
done

# Update repository database
log "Updating repository database..."
cd "$REPO_DIR"
repo-add "$REPO_NAME.db.tar.gz" *.pkg.tar.zst

# Verify
log "Repository contents:"
pacman -Sl "$REPO_NAME"

log "Done"
```

**Usage:**
```bash
chmod +x /usr/local/bin/update-custom-repo
./update-custom-repo
```

#### Scheduled Update with Cron

```cron
# /etc/cron.d/update-custom-repo
# Update custom repository daily at 2 AM

0 2 * * * user /usr/local/bin/update-custom-repo
```

### Repository Maintenance

#### Clean Old Packages

```bash
#!/bin/bash
# clean-old-packages.sh - Remove old package versions from repository

REPO_DIR="~/my-repo"
KEEP_VERSIONS=3  # Keep this many recent versions

cd "$REPO_DIR"

# Group packages by name and remove old versions
for pkg_base in $(ls *.pkg.tar.zst | sed 's/-[^-]*-[^-]*-[^-]*\.pkg\.tar\.zst$//' | sort -u); do
    # Get all versions of this package
    versions=$(ls "${pkg_base}"-*.pkg.tar.zst 2>/dev/null | sort -V)
    
    # Count versions
    count=$(echo "$versions" | wc -l)
    
    if [ $count -gt $KEEP_VERSIONS ]; then
        # Remove all but the newest KEEP_VERSIONS
        echo "$versions" | head -n $((count - KEEP_VERSIONS)) | while read old_pkg; do
            echo "Removing old version: $old_pkg"
            rm "$old_pkg"
        done
    fi
done

# Rebuild database
repo-add custom.db.tar.gz *.pkg.tar.zst
```

#### Verify Repository Integrity

```bash
#!/bin/bash
# verify-repo.sh - Verify repository integrity

REPO_DIR="~/my-repo"

cd "$REPO_DIR"

echo "Verifying repository integrity..."

# Check all packages can be read
for pkg in *.pkg.tar.zst; do
    if tar -tzf "$pkg" &>/dev/null; then
        echo "✓ $pkg"
    else
        echo "✗ $pkg - CORRUPTED"
    fi
done

# Verify database
if tar -tzf custom.db.tar.gz &>/dev/null; then
    echo "✓ Database is valid"
else
    echo "✗ Database is corrupted"
fi
```

### Repository Sharing

#### Using GitHub

**Create repository on GitHub and push packages:**
```bash
git init ~/my-repo
cd ~/my-repo

# Add and commit
git add .
git commit -m "Initial custom repository"

# Add remote and push
git remote add origin https://github.com/username/arch-repo.git
git push -u origin master
```

**Configure on client:**
```ini
# /etc/pacman.conf
[custom]
SigLevel = Optional TrustAll
Server = https://raw.githubusercontent.com/username/arch-repo/master
```

#### Using Archive Server

**Create archive with packages:**
```bash
tar -czf custom-repo.tar.gz ~/my-repo/
scp custom-repo.tar.gz user@archive.example.com:/srv/archives/
```

**Extract on target:**
```bash
tar -xzf custom-repo.tar.gz -C /opt/
```

### Troubleshooting

#### Package Not Found After Adding

**Refresh database:**
```bash
pacman -Sy
```

**Verify repository is registered:**
```bash
pacman -Sl custom
```

**Check pacman.conf syntax:**
```bash
pacman -T
```

#### Signature Verification Errors

**Verify package signature is present:**
```bash
ls ~/my-repo/*.asc
```

**Import key on client:**
```bash
gpg --import ~/.config/pacman/gnupg/trusted.gpg
gpg --import /path/to/your-public-key.asc
```

#### Database Corruption

**Rebuild database:**
```bash
cd ~/my-repo
rm custom.db*
repo-add custom.db.tar.gz *.pkg.tar.zst
```

### Best Practices

**Backup repository:** Regularly backup package files and database.

**Version control:** Use git to track PKGBUILD changes and metadata.

**Organize packages:** Group related packages in subdirectories.

**Document packages:** Maintain README with package descriptions and dependencies.

**Test thoroughly:** Test packages before adding to repository.

**Sign packages:** Use GPG signatures for security and authenticity.

**Monitor size:** Keep eye on repository size, archive old versions.

**Automate updates:** Use scripts to keep repository current.

**Documentation:** Provide setup instructions for clients.

**Access control:** Restrict write access to authorized users.

Custom repositories provide powerful package distribution and management capabilities, enabling centralized package management across systems and organizations.

