## Cache Strategies


### Overview

Pacman's package cache stores downloaded package files, enabling offline reinstallation, quick downgrades, and recovery without re-downloading. Effective cache strategies balance disk space usage against the benefits of retained packages.

### Cache Location and Structure

#### Default Cache Directory

```
/var/cache/pacman/pkg/
```

All downloaded packages are stored here by default.

#### Cache File Format

Package files use the naming convention:

```
package-name-version-release-architecture.pkg.tar.zst
```

**Examples:**
```
firefox-120.0-1-x86_64.pkg.tar.zst
linux-6.6.1.arch1-1-x86_64.pkg.tar.zst
glibc-2.38-1-x86_64.pkg.tar.zst
```

### Cache Size Management

#### Check Cache Size

View total cache size:

```
du -sh /var/cache/pacman/pkg/
```

Typical sizes range from 5-50 GB depending on system age and cleaning frequency.

#### Count Cached Packages

Count package files:

```
ls /var/cache/pacman/pkg/ | wc -l
```

Shows total number of cached package files.

#### Identify Largest Cached Packages

Find packages consuming the most space:

```
du -h /var/cache/pacman/pkg/* | sort -rh | head -20
```

Shows the 20 largest cached packages.

### Manual Cache Cleaning

#### Using Pacman

**Remove uninstalled packages from cache:**
```
sudo pacman -Sc
```

Removes all cached packages not currently installed. Keeps only packages currently on your system.

**Remove all cached packages:**
```
sudo pacman -Scc
```

Empties the entire cache, removing all package files including currently installed versions.

**Warning:** After `-Scc`, you cannot downgrade or reinstall offline.

### Intelligent Cache Cleaning with Paccache

#### Installing paccache

Paccache is part of `pacman-contrib`:

```
sudo pacman -S pacman-contrib
```

#### Basic Paccache Usage

**Keep 3 most recent versions (default):**
```
sudo paccache -r
```

Removes all cached versions except the three most recent for each package.

**Keep 1 version:**
```
sudo paccache -rk1
```

Keeps only the most recent version of each installed package.

**Keep 2 versions:**
```
sudo paccache -rk2
```

**Keep 5 versions:**
```
sudo paccache -rk5
```

#### Target Uninstalled Packages

**Remove all uninstalled package versions:**
```
sudo paccache -ruk0
```

The `-u` flag targets uninstalled packages; `-k0` keeps zero versions (removes all).

**Keep 1 version of uninstalled packages:**
```
sudo paccache -ruk1
```

Preserves one version of previously installed packages for easy reinstallation.

#### Dry Run Mode

Preview what would be removed without deleting:

```
paccache -dk3
```

Shows files that would be removed when keeping 3 versions.

#### Verbose Output

See detailed information about removed packages:

```
sudo paccache -rvk2
```

Displays each package file as it's removed.

### Cache Retention Strategies

#### Conservative Strategy (3-5 versions)

**Rationale:** Provides multiple downgrade options while managing space reasonably.

```
sudo paccache -rk3
```

**Benefits:**
- Multiple downgrade points
- Good balance of space and utility
- Handles most package issues

**When to use:** Default for most users; good general-purpose strategy.

#### Minimal Strategy (1 version)

**Rationale:** Keeps only the current version, maximizing space savings.

```
sudo paccache -rk1
```

**Benefits:**
- Minimal disk space usage
- Fast cache operations
- Still allows offline reinstall

**When to use:** Limited disk space; regular updates; rarely downgrade.

#### Aggressive Uninstalled Cleanup

**Rationale:** Remove all uninstalled packages but keep multiple versions of installed.

```
sudo paccache -ruk0 && sudo paccache -rk3
```

**Benefits:**
- Removes packages you don't use
- Retains history for current packages
- Significant space savings

**When to use:** Standard recommendation for most users.

#### Archival Strategy (unlimited versions)

**Rationale:** Never remove packages; maintain complete history.

```
# Don't run paccache; keep everything
```

**Benefits:**
- Complete downgrade history
- Maximum recovery options
- Useful for testing/development

**When to use:** Ample disk space; frequent testing; package development.

### Automated Cache Cleaning

#### Systemd Timer (Recommended)

Enable automatic weekly cache cleaning:

```
sudo systemctl enable --now paccache.timer
```

**Default behavior:** Runs `paccache -r` weekly, keeping 3 versions.

#### Configure Timer Behavior

Edit the timer arguments:

```
sudo nano /etc/conf.d/pacman-contrib
```

**Example configurations:**

**Keep only 1 version:**
```
PACCACHE_ARGS='-k1'
```

**Remove uninstalled packages:**
```
PACCACHE_ARGS='-uk0'
```

**Combined strategy:**
```
PACCACHE_ARGS='-rk2 && paccache -ruk0'
```

**Restart timer after changes:**
```
sudo systemctl restart paccache.timer
```

#### Check Timer Status

View timer schedule and last run:

```
systemctl status paccache.timer
systemctl list-timers paccache.timer
```

#### Pacman Hook for Cache Cleaning

Automatically clean cache after package operations:

```
# /etc/pacman.d/hooks/clean-cache.hook
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleaning package cache...
When = PostTransaction
Exec = /usr/bin/paccache -rk2
```

**Benefits:**
- Automatic maintenance
- No manual intervention
- Always clean cache

**Drawback:** Runs after every operation; may slow frequent updates.

### Multiple Cache Directories

#### Configure Additional Cache Locations

In `/etc/pacman.conf`:

```
[options]
CacheDir = /var/cache/pacman/pkg/
CacheDir = /mnt/external/cache/
```

Pacman searches both directories for cached packages.

#### Use Cases

**External storage:** Use large external drive for primary cache:
```
CacheDir = /mnt/external/cache/
CacheDir = /var/cache/pacman/pkg/
```

**Network cache:** Shared cache for multiple systems:
```
CacheDir = /mnt/nfs-share/arch-cache/
CacheDir = /var/cache/pacman/pkg/
```

#### Clean Multiple Cache Directories

Paccache supports multiple directories:

```
sudo paccache -rk3 --cachedir /var/cache/pacman/pkg/ --cachedir /mnt/external/cache/
```

### Archive and Backup Strategies

#### Move Old Packages to Archive

Instead of deleting, archive old packages:

```
sudo mkdir -p /var/cache/pacman/archive/
sudo paccache -m /var/cache/pacman/archive/ -rk1
```

The `-m` flag moves packages to the specified directory instead of deleting.

**Benefits:**
- Preserves old packages
- Clears active cache
- Allows later recovery

#### Selective Archival

**Archive only specific packages:**
```bash
#!/bin/bash
# Archive important packages before cleaning

mkdir -p /backup/important-packages/

for pkg in linux firefox chromium; do
    cp /var/cache/pacman/pkg/${pkg}-*.pkg.tar.zst /backup/important-packages/ 2>/dev/null
done

sudo paccache -rk1
```

### Local Repository from Cache

#### Create Local Repository

Use cache as a local repository for offline installs:

**Create repository database:**
```
cd /var/cache/pacman/pkg/
repo-add /var/cache/pacman/pkg/custom.db.tar.gz *.pkg.tar.zst
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

Now packages in cache are available as a repository.

### Cache Sharing Between Systems

#### Network Cache Setup

Share cache across multiple systems:

**Server side (NFS example):**
```
# /etc/exports
/var/cache/pacman/pkg 192.168.1.0/24(ro,sync,no_subtree_check)
```

**Client side:**
```
# Mount shared cache
sudo mount server:/var/cache/pacman/pkg /mnt/shared-cache

# Configure pacman
CacheDir = /mnt/shared-cache
CacheDir = /var/cache/pacman/pkg
```

**Benefits:**
- Reduces redundant downloads
- Saves bandwidth
- Faster updates across network

### Monitoring and Maintenance

#### Cache Growth Tracking

Track cache size over time:

```bash
#!/bin/bash
# /usr/local/bin/track-cache-size

DATE=$(date +%Y-%m-%d)
SIZE=$(du -sb /var/cache/pacman/pkg/ | cut -f1)
COUNT=$(ls /var/cache/pacman/pkg/ | wc -l)

echo "$DATE,$SIZE,$COUNT" >> /var/log/pacman-cache-stats.log
```

**Schedule with cron:**
```
0 0 * * * /usr/local/bin/track-cache-size
```

#### Cache Health Check

Verify cache integrity:

```bash
#!/bin/bash
# Check for corrupted packages in cache

for pkg in /var/cache/pacman/pkg/*.pkg.tar.zst; do
    if ! tar -tzf "$pkg" &>/dev/null; then
        echo "Corrupted: $pkg"
    fi
done
```

Remove corrupted packages:
```
sudo rm /var/cache/pacman/pkg/corrupted-package.pkg.tar.zst
```

### Best Practices

**Regular cleaning:** Clean cache monthly or quarterly depending on disk space.

**Balanced retention:** Keep 2-3 versions for downgrade capability.

**Automate maintenance:** Use paccache.timer for hands-off management.

**Remove uninstalled aggressively:** Uninstalled packages rarely need retention.

**Monitor space usage:** Track cache growth to adjust strategy.

**Consider SSD space:** SSDs may warrant more aggressive cleaning.

**Archive critical packages:** Backup important package versions before cleaning.

**Clean before major upgrades:** Free space before large system updates.

**Document strategy:** Record retention policy for consistency.

**Test downgrade needs:** Adjust retention based on actual downgrade frequency.

### Example Cache Management Scripts

#### Comprehensive Cleanup Script

```bash
#!/bin/bash
# /usr/local/bin/cache-cleanup

echo "Starting cache cleanup..."

# Remove uninstalled packages
echo "Removing uninstalled packages..."
paccache -ruk0

# Keep 2 versions of installed
echo "Keeping 2 versions of installed packages..."
paccache -rk2

# Report results
echo "Cache size: $(du -sh /var/cache/pacman/pkg/ | cut -f1)"
echo "Package count: $(ls /var/cache/pacman/pkg/ | wc -l)"

echo "Cleanup complete!"
```

#### Conditional Cleanup Based on Space

```bash
#!/bin/bash
# Clean cache if below 5GB free space

FREE_SPACE=$(df /var/cache/pacman/pkg/ | tail -1 | awk '{print $4}')
THRESHOLD=$((5 * 1024 * 1024))  # 5GB in KB

if [ $FREE_SPACE -lt $THRESHOLD ]; then
    echo "Low disk space detected. Cleaning cache..."
    paccache -ruk0
    paccache -rk1
else
    echo "Sufficient disk space. Keeping cache."
fi
```

Effective cache strategies ensure optimal disk space usage while maintaining the ability to downgrade, reinstall offline, and recover from issues.

