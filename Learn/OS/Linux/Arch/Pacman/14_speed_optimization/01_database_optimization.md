## Database Optimization


### Overview

Pacman's database stores information about installed packages, available packages, and file lists. Over time, the database can become fragmented or contain obsolete data. Regular optimization improves pacman's performance, reduces disk space usage, and maintains database integrity.

### Database Locations

#### Local Package Database

Contains information about installed packages:

```
/var/lib/pacman/local/
```

**Structure:**
```
/var/lib/pacman/local/
├── package-name-version/
│   ├── desc          # Package description
│   ├── files         # Installed files list
│   └── mtree         # File integrity data
└── ALPM_DB_VERSION   # Database version
```

#### Sync Databases

Contains information about repository packages:

```
/var/lib/pacman/sync/
```

**Files:**
```
/var/lib/pacman/sync/
├── core.db
├── extra.db
└── multilib.db
```

These are symlinks to versioned database files downloaded from mirrors.

### Database Size Analysis

#### Check Database Size

**Local database:**
```
du -sh /var/lib/pacman/local/
```

Typical size: 30-100 MB depending on installed packages.

**Sync databases:**
```
du -sh /var/lib/pacman/sync/
```

Typical size: 10-50 MB.

**Total database size:**
```
du -sh /var/lib/pacman/
```

#### Identify Large Package Entries

```
du -sh /var/lib/pacman/local/* | sort -h | tail -20
```

Shows the 20 largest package database entries.

### Optimizing the Local Database

#### Remove Orphaned Package Data

Sometimes package database entries remain after improper removal:

**Identify orphaned directories:**
```
for dir in /var/lib/pacman/local/*/; do
    pkg=$(basename "$dir")
    if ! pacman -Qq | grep -q "^${pkg%-*-*}$"; then
        echo "Orphaned: $pkg"
    fi
done
```

**Manual cleanup (use with extreme caution):**
```
sudo rm -rf /var/lib/pacman/local/orphaned-package-version/
```

**Warning:** Only remove confirmed orphaned entries; incorrect removal can break pacman.

#### Rebuild Database from Scratch

If the database is corrupted or severely fragmented:

**List all installed packages:**
```
pacman -Qq > /tmp/installed-packages.txt
```

**Reinstall all packages (rebuilds database):**
```
sudo pacman -S $(cat /tmp/installed-packages.txt) --overwrite '*'
```

**Warning:** This is time-consuming and should only be done if database corruption is severe.

### Optimizing Sync Databases

#### Clean Unused Repository Databases

Remove databases for disabled repositories:

```
sudo pacman -Sc
```

Prompts to remove unused repository databases.

**Force removal:**
```
sudo rm /var/lib/pacman/sync/unused-repo.db*
```

Only remove if you're certain the repository is no longer used.

#### Refresh Databases

Ensure databases are current and not corrupted:

**Standard refresh:**
```
sudo pacman -Sy
```

**Force complete refresh:**
```
sudo pacman -Syy
```

The double `-yy` re-downloads all databases, replacing potentially corrupted files.

### Database Integrity Verification

#### Check Database Consistency

Verify the integrity of the local package database:

```
sudo pacman -Dk
```

Reports missing or corrupted database entries.

#### Verify Package Files

Check if installed files match database records:

```
pacman -Qk
```

Basic file presence check.

```
pacman -Qkk
```

Thorough integrity check including file attributes.

#### Advanced Verification with paccheck

Install `pacutils`:
```
sudo pacman -S pacutils
```

**Comprehensive integrity check:**
```
paccheck --md5sum --sha256sum --file-properties --quiet
```

Reports packages with integrity issues.

### Database Upgrade

#### Upgrade Database Format

When pacman updates introduce new database formats:

```
sudo pacman-db-upgrade
```

This updates the local database structure to match the current pacman version.

**When to use:**
- After major pacman upgrades
- If database version mismatches occur
- Database initialization errors

#### Automatic Upgrade

Pacman typically handles database upgrades automatically during installation or system updates. Manual intervention is rarely needed.

### Optimizing Database Performance

#### Filesystem Considerations

**Use appropriate filesystem:** ext4, btrfs, and XFS all perform well with pacman databases.

**Enable compression (btrfs):**
```
sudo btrfs property set /var/lib/pacman/ compression zstd
```

Reduces database storage size.

**Disable access time updates:**

Add to `/etc/fstab`:
```
/dev/sdXn  /  ext4  defaults,noatime  0  1
```

Reduces unnecessary disk writes during database operations.

#### SSD Optimization

For SSD systems:

**Enable TRIM:**
```
sudo systemctl enable fstab-trim.timer
```

**Verify TRIM support:**
```
sudo fstrim -v /
```

Regular TRIM operations improve SSD performance, benefiting database operations.

### Cleaning Database-Related Files

#### Remove .SRCINFO Files

Build directories sometimes leave source info files:

```
find ~/.cache/yay ~/.cache/paru -name ".SRCINFO" -delete
```

Cleans AUR helper build caches.

#### Clean Old Database Locks

Stale lock files can accumulate:

**Check for lock file:**
```
ls -la /var/lib/pacman/db.lck
```

**Remove if pacman isn't running:**
```
sudo rm /var/lib/pacman/db.lck
```

**Warning:** Only remove if you're certain pacman isn't running.

### Optimizing Files Database

#### Files Database Location

```
/var/lib/pacman/sync/*.files
```

Contains comprehensive file listings for repository packages.

#### Refresh Files Database

Update the files database:

```
sudo pacman -Fy
```

This synchronizes the files database, enabling file searches with `pacman -F`.

#### Automate Files Database Updates

Enable automatic weekly updates:

```
sudo systemctl enable --now pacman-filesdb-refresh.timer
```

Keeps the files database current for accurate file queries.

#### Clean Outdated Files Databases

Remove files databases for disabled repositories:

```
sudo rm /var/lib/pacman/sync/unused-repo.files*
```

### Monitoring Database Performance

#### Measure Query Performance

**Time package queries:**
```
time pacman -Ss firefox
time pacman -Qi firefox
time pacman -Ql firefox
```

Compare times before and after optimization.

#### Database Size Trends

Track database growth over time:

```bash
#!/bin/bash
# /usr/local/bin/track-pacman-db-size

DATE=$(date +%Y-%m-%d)
SIZE=$(du -sb /var/lib/pacman/ | cut -f1)

echo "$DATE,$SIZE" >> /var/log/pacman-db-size.log
```

Schedule with cron to monitor long-term trends.

### Automation and Maintenance

#### Automatic Database Maintenance Script

Create a comprehensive maintenance script:

```bash
#!/bin/bash
# /usr/local/bin/pacman-db-optimize

echo "Starting pacman database optimization..."

# Refresh databases
echo "Refreshing sync databases..."
pacman -Sy

# Remove unused databases
echo "Cleaning unused databases..."
pacman -Sc --noconfirm

# Verify database integrity
echo "Verifying database integrity..."
pacman -Dk

# Update files database
echo "Updating files database..."
pacman -Fy

# Report final size
echo "Database size:"
du -sh /var/lib/pacman/

echo "Optimization complete!"
```

**Make executable:**
```
sudo chmod +x /usr/local/bin/pacman-db-optimize
```

**Run monthly:**
```
sudo crontab -e
```

Add:
```
0 3 1 * * /usr/local/bin/pacman-db-optimize
```

#### Pacman Hook for Database Optimization

Automatically optimize after major operations:

```
# /etc/pacman.d/hooks/database-optimize.hook
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Optimizing package database...
When = PostTransaction
Exec = /bin/sh -c "pacman -Dk && pacman -Sc --noconfirm"
```

**Warning:** This runs after every transaction; may slow down frequent operations.

### Troubleshooting Database Issues

#### Database Corruption

**Symptoms:**
```
error: could not open file /var/lib/pacman/local/package-name/desc
error: failed to prepare transaction (database is not valid)
```

**Solutions:**

**1. Verify and fix permissions:**
```
sudo chown -R root:root /var/lib/pacman/
sudo chmod -R 755 /var/lib/pacman/
```

**2. Reinstall affected package:**
```
sudo pacman -S package-name --overwrite '*'
```

**3. Rebuild database for package:**
```
sudo pacman -S --dbonly package-name
```

**4. Complete database rebuild (last resort):**
```
sudo pacman -S $(pacman -Qq) --overwrite '*'
```

#### Slow Database Operations

**Symptoms:**
- Package queries take excessive time
- Installation/removal operations lag

**Solutions:**

**1. Check disk I/O:**
```
sudo iotop
```

**2. Verify filesystem health:**
```
sudo fsck /dev/sdXn  # Unmounted partition only
```

**3. Optimize filesystem:**
```
sudo e4defrag /var/lib/pacman/  # For ext4
```

**4. Consider SSD upgrade:** Database operations benefit significantly from SSD performance.

### Best Practices

**Regular refreshes:** Run `pacman -Sy` regularly to keep sync databases current.

**Periodic verification:** Check database integrity monthly with `pacman -Dk`.

**Clean orphaned ** Remove orphaned package entries cautiously.

**Monitor size growth:** Track database size to identify unusual growth.

**Maintain backups:** Include `/var/lib/pacman/` in system backups.

**Use SSD when possible:** Database operations benefit from fast storage.

**Avoid manual modifications:** Don't manually edit database files; use pacman commands.

**Update files database:** Keep files database current with `pacman -Fy`.

**Clean unused repositories:** Remove databases for disabled repos.

**Automate maintenance:** Use hooks or cron for regular optimization.

Proper database optimization ensures pacman operates efficiently, with fast queries and reliable package management operations.

