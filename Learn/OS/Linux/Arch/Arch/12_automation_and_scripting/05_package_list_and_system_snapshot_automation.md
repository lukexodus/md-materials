## Package List and System Snapshot Automation


### System Snapshots Overview

**Purpose**: Capture system state for recovery, comparison, and documentation.[1]

**Benefits** :
- Quick system restore 
- Track changes over time 
- Disaster recovery 
- Documentation 

**Methods** :
- Package lists 
- Filesystem snapshots 
- Configuration backups 

### Package List Management

#### Export Installed Packages

**All Packages** :

```bash
pacman -Q > installed-packages.txt
```

**Native Packages Only** :

```bash
pacman -Qe > native-packages.txt
```

**AUR Packages Only** :

```bash
pacman -Qm > aur-packages.txt
```

**Detailed Format** :

```bash
pacman -Qi | grep "^Name" | awk '{print $3}' > packages.txt
```

#### Create Package Snapshot Script

**Automated Snapshot**: `/usr/local/bin/save-packages.sh` :

```bash
#!/bin/bash

SNAPSHOT_DIR="$HOME/.system-snapshots"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$SNAPSHOT_DIR"

# Save all package lists
pacman -Q > "$SNAPSHOT_DIR/all_packages_$TIMESTAMP.txt"
pacman -Qe > "$SNAPSHOT_DIR/native_packages_$TIMESTAMP.txt"
pacman -Qm > "$SNAPSHOT_DIR/aur_packages_$TIMESTAMP.txt"

# Save with descriptions
pacman -Qi > "$SNAPSHOT_DIR/all_packages_detailed_$TIMESTAMP.txt"

# Save to log
echo "[$(date)] Package snapshot created: $SNAPSHOT_DIR" >> ~/.system-snapshots/snapshot.log
```

**Make Executable** :

```bash
chmod +x /usr/local/bin/save-packages.sh
```

#### Restore from Package List

**Install Packages** :

```bash
pacman -S $(cat native-packages.txt | awk '{print $1}')
```

**Exclude Specific Packages** :

```bash
pacman -S $(grep -v "base\|linux" native-packages.txt | awk '{print $1}')
```

**AUR Packages** :

```bash
yay -S $(cat aur-packages.txt | awk '{print $1}')
```

#### Compare Package Lists

**Differences** :

```bash
diff native-packages-old.txt native-packages-new.txt
```

**Installed vs Archive** :

```bash
comm -23 <(sort current-packages.txt) <(sort archived-packages.txt)
```

Shows packages no longer in archive .

#### Generate Installation Summary

**Package Count** :

```bash
#!/bin/bash
echo "=== Package Summary ==="
echo "Native packages: $(pacman -Qe | wc -l)"
echo "AUR packages: $(pacman -Qm | wc -l)"
echo "Total packages: $(pacman -Q | wc -l)"
```

**By Category** :

```bash
pacman -Qi | grep "^Group" | sort | uniq -c
```

### Filesystem Snapshots

#### Btrfs Snapshots

**Create Snapshot** :

```bash
sudo btrfs subvolume snapshot / /.snapshots/snapshot-$(date +%Y%m%d)
```

**List Snapshots** :

```bash
sudo btrfs subvolume list /
```

**Delete Snapshot** :

```bash
sudo btrfs subvolume delete /.snapshots/snapshot-20250101
```

#### Automated Btrfs Snapshots

**Script**: `/usr/local/bin/btrfs-snapshot.sh` :

```bash
#!/bin/bash

SNAPSHOT_DIR="/.snapshots"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MAX_SNAPSHOTS=10

# Create new snapshot
sudo btrfs subvolume snapshot -r / "$SNAPSHOT_DIR/snapshot_$TIMESTAMP"

# Remove old snapshots (keep latest 10)
SNAPSHOTS=($(sudo btrfs subvolume list "$SNAPSHOT_DIR" | awk '{print $9}' | sort -r))

for ((i=MAX_SNAPSHOTS; i<${#SNAPSHOTS[@]}; i++)); do
    echo "Deleting old snapshot: ${SNAPSHOTS[$i]}"
    sudo btrfs subvolume delete "$SNAPSHOT_DIR/${SNAPSHOTS[$i]}"
done

echo "[$(date)] Snapshot created and old ones pruned" >> /var/log/snapshots.log
```

#### Systemd Timer for Btrfs

**Service**: `/etc/systemd/system/btrfs-snapshot.service` :

```ini
[Unit]
Description=Btrfs Snapshot

[Service]
Type=oneshot
ExecStart=/usr/local/bin/btrfs-snapshot.sh
```

**Timer**: `/etc/systemd/system/btrfs-snapshot.timer` :

```ini
[Unit]
Description=Daily Btrfs Snapshot

[Timer]
OnCalendar=daily
OnBootSec=10min
Persistent=true

[Install]
WantedBy=timers.target
```

**Enable** :

```bash
sudo systemctl enable --now btrfs-snapshot.timer
```

### Configuration Backup

#### Backup System Configuration

**All Configuration** :

```bash
sudo tar -czf /backup/etc_backup_$(date +%Y%m%d).tar.gz /etc
```

**Specific Config** :

```bash
sudo tar -czf config_backup.tar.gz /etc/pacman.conf /etc/systemd/
```

#### Automated Config Backup

**Script**: `/usr/local/bin/backup-config.sh` :

```bash
#!/bin/bash

BACKUP_DIR="/mnt/backup/config"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup critical configs
sudo tar -czf "$BACKUP_DIR/etc_$TIMESTAMP.tar.gz" /etc
sudo tar -czf "$BACKUP_DIR/root_$TIMESTAMP.tar.gz" /root

# Backup user configs
for user in /home/*; do
    if [ -d "$user" ]; then
        USERNAME=$(basename "$user")
        tar -czf "$BACKUP_DIR/${USERNAME}_config_$TIMESTAMP.tar.gz" \
            "$user/.config" "$user/.bashrc" "$user/.bash_profile" 2>/dev/null
    fi
done

echo "[$(date)] Configuration backup completed" >> /var/log/config-backup.log
```

### Comprehensive System Snapshot

#### Full System State

**Combined Snapshot Script** :

```bash
#!/bin/bash

SNAPSHOT_DIR="$HOME/.system-snapshots"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$SNAPSHOT_DIR"

# Create report
{
    echo "=== System Snapshot Report ==="
    echo "Date: $(date)"
    echo ""
    
    echo "=== System Information ==="
    uname -a
    echo ""
    
    echo "=== Kernel Version ==="
    cat /proc/version
    echo ""
    
    echo "=== Installed Packages ==="
    echo "Total: $(pacman -Q | wc -l)"
    echo "Native: $(pacman -Qe | wc -l)"
    echo "AUR: $(pacman -Qm | wc -l)"
    echo ""
    
    echo "=== Systemd Services ==="
    systemctl list-unit-files --type=service | grep enabled
    echo ""
    
    echo "=== Filesystem Usage ==="
    df -h
    echo ""
    
    echo "=== Disk Space ==="
    du -sh /home
    du -sh /var
    du -sh /tmp
    
} > "$SNAPSHOT_DIR/system-report_$TIMESTAMP.txt"

# Save package lists
pacman -Q > "$SNAPSHOT_DIR/packages_$TIMESTAMP.txt"
pacman -Qe > "$SNAPSHOT_DIR/packages_native_$TIMESTAMP.txt"
pacman -Qm > "$SNAPSHOT_DIR/packages_aur_$TIMESTAMP.txt"

# Save systemd state
systemctl list-unit-files > "$SNAPSHOT_DIR/services_$TIMESTAMP.txt"
systemctl list-units --type=service --all >> "$SNAPSHOT_DIR/services_$TIMESTAMP.txt"

# Save network config
ip addr show > "$SNAPSHOT_DIR/network_$TIMESTAMP.txt"
ip route show >> "$SNAPSHOT_DIR/network_$TIMESTAMP.txt"

echo "Snapshot saved to: $SNAPSHOT_DIR"
```

### Version Tracking

#### Track Configuration Changes

**Git for /etc** :

```bash
sudo git init /etc
sudo git -C /etc config user.email "root@example.com"
sudo git -C /etc config user.name "Root"
sudo git -C /etc add -A
sudo git -C /etc commit -m "Initial commit"
```

**Track Changes** :

```bash
sudo git -C /etc diff
```

#### etckeeper Integration

**Installation**: `sudo pacman -S etckeeper` :

```bash
sudo etckeeper init
sudo etckeeper commit "Initial commit"
```

**Automatic Commits** :

```bash
sudo systemctl enable --now etckeeper.timer
```

### Scheduled Snapshots

#### Daily Snapshots

**Systemd Service** :

```ini
[Unit]
Description=Daily System Snapshot

[Service]
Type=oneshot
ExecStart=/usr/local/bin/system-snapshot.sh
StandardOutput=journal
StandardError=journal
```

**Timer** :

```ini
[Unit]
Description=Daily System Snapshot Timer

[Timer]
OnCalendar=daily
OnBootSec=1h
Persistent=true

[Install]
WantedBy=timers.target
```

#### Weekly Full Backup

**Combined with Backup** :

```bash
#!/bin/bash

# Save packages
pacman -Q > /backup/packages_$(date +%Y%m%d).txt

# Create filesystem snapshot
sudo btrfs subvolume snapshot -r / /.snapshots/weekly_$(date +%Y%m%d)

# Full backup
tar -czf /backup/full_$(date +%Y%m%d).tar.gz \
    --exclude=/proc --exclude=/sys --exclude=/dev /
```

### Analyzing System Changes

#### Compare Snapshots

**Package Changes** :

```bash
diff <(sort packages_old.txt | awk '{print $1}') \
     <(sort packages_new.txt | awk '{print $1}')
```

**Shows Added/Removed** .

**Service Changes** :

```bash
diff services_old.txt services_new.txt | grep "^[<>]"
```

#### Generate Change Report

**Change Analysis** :

```bash
#!/bin/bash

OLD_SNAPSHOT=$1
NEW_SNAPSHOT=$2

echo "=== Package Changes ==="
echo "Added:"
comm -13 <(sort $OLD_SNAPSHOT) <(sort $NEW_SNAPSHOT)
echo ""
echo "Removed:"
comm -23 <(sort $OLD_SNAPSHOT) <(sort $NEW_SNAPSHOT)
```

### Snapshot Restoration

#### From Package List

**Restore Minimal System** :

```bash
pacman -S $(awk '{print $1}' packages_snapshot.txt)
```

#### From Filesystem Snapshot

**Mount Snapshot** :

```bash
sudo btrfs subvolume snapshot /.snapshots/snapshot-name /.snapshots/restore
sudo mount -o remount,ro /.snapshots/restore
```

**Extract Files** :

```bash
cp /path/to/snapshot/file /restore/location
```

### Archival and Storage

#### Store Snapshots

**Archive Snapshots** :

```bash
tar -czf snapshots_archive_2025_Q1.tar.gz ~/.system-snapshots/
```

**External Storage** :

```bash
rsync -av ~/.system-snapshots/ /mnt/external-backup/snapshots/
```

#### Retention Policy

**Keep Snapshots** :

- Daily: 7 days 
- Weekly: 4 weeks 
- Monthly: 12 months 

**Cleanup Script** :

```bash
#!/bin/bash

SNAPSHOT_DIR="$HOME/.system-snapshots"
DAYS=7

find "$SNAPSHOT_DIR" -name "*.txt" -mtime +$DAYS -delete
find "$SNAPSHOT_DIR" -name "*.tar.gz" -mtime +30 -delete
```

### Best Practices

**Regular Snapshots**: Schedule daily or weekly .

**Multiple Copies**: Keep on different media .

**Test Restoration**: Verify snapshot usability .

**Document Process**: Record snapshot procedures .

**Automate Cleanup**: Remove old snapshots automatically .

**Monitor Storage**: Watch snapshot size growth .

**Version Control**: Use git for configuration .

**Off-Site Copy**: Maintain remote snapshots .

***

This comprehensive guide on package list and system snapshot automation completes the Arch Linux system administration documentation, providing users with complete strategies for capturing, managing, and utilizing system state information for recovery and documentation purposes.

Sources
[1] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824


