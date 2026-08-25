## Snapshotting with rsync, btrfs, or LVM


### Snapshotting Overview

**Purpose**: Create point-in-time copies of filesystems for recovery and testing .

**Methods** :
- rsync snapshots 
- Btrfs snapshots 
- LVM snapshots 

**Use Cases** :
- Quick recovery 
- Testing changes 
- Backup before updates 
- System rollback 

### rsync-based Snapshots

#### Snapshot Concept

**Hard Links** :

Create efficient snapshots using hard links .

**Advantages** :
- Minimal disk space 
- Fast creation 
- No special filesystem 

#### Basic Setup

**Directory Structure** :

```
/backups/
├── current/      # Latest snapshot
├── daily.0/      # Yesterday
├── daily.1/      # 2 days ago
└── daily.2/      # 3 days ago
```

#### Create Snapshot Script

**Script**: `/usr/local/bin/rsync-snapshot.sh` :

```bash
#!/bin/bash

SOURCE="/home"
BACKUP_BASE="/backups"
BACKUP_DIR="$BACKUP_BASE/current"
DAILY_SNAPSHOTS=3

# Rotate old snapshots
for ((i=DAILY_SNAPSHOTS-1; i>=0; i--)); do
    if [ $i -eq 0 ]; then
        # Move current to daily.0
        if [ -d "$BACKUP_BASE/daily.0" ]; then
            rm -rf "$BACKUP_BASE/daily.0"
        fi
        mv "$BACKUP_DIR" "$BACKUP_BASE/daily.0"
    else
        # Rotate daily.n to daily.n+1
        OLD=$((i-1))
        if [ -d "$BACKUP_BASE/daily.$OLD" ]; then
            rm -rf "$BACKUP_BASE/daily.$i"
            mv "$BACKUP_BASE/daily.$OLD" "$BACKUP_BASE/daily.$i"
        fi
    fi
done

# Create new snapshot directory
mkdir -p "$BACKUP_DIR"

# rsync with hard links
rsync -av --delete \
    --link-dest="$BACKUP_BASE/daily.0" \
    "$SOURCE/" "$BACKUP_DIR/"

echo "[$(date)] Snapshot created" >> /var/log/snapshots.log
```

**Make Executable** :

```bash
chmod +x /usr/local/bin/rsync-snapshot.sh
```

#### Schedule Snapshot

**Cron Job** :

```bash
0 2 * * * /usr/local/bin/rsync-snapshot.sh
```

**Systemd Timer** :

```ini
[Unit]
Description=Daily rsync Snapshot

[Timer]
OnCalendar=daily
OnBootSec=1h

[Install]
WantedBy=timers.target
```

#### Restore from Snapshot

**Restore Specific File** :

```bash
cp /backups/daily.0/home/user/document.txt ~/
```

**Restore Directory** :

```bash
cp -r /backups/daily.0/home/user/project ~/
```

### Btrfs Snapshots

#### Btrfs Advantages

**Built-in Snapshots** :

Native snapshot support .

**Copy-on-Write** :

Efficient storage .

**Atomic Operations** :

Consistent state .

#### Create Snapshot

**Read-write** :

```bash
sudo btrfs subvolume snapshot / /.snapshots/snapshot-$(date +%Y%m%d)
```

**Read-only** :

```bash
sudo btrfs subvolume snapshot -r / /.snapshots/snapshot-$(date +%Y%m%d)_ro
```

#### List Snapshots

**Show Snapshots** :

```bash
sudo btrfs subvolume list -t /
```

**Detailed** :

```bash
sudo btrfs subvolume show /.snapshots/snapshot-20250101
```

#### Snapshot Properties

**Check UUID** :

```bash
sudo btrfs subvolume show /.snapshots/snapshot-20250101 | grep UUID
```

**Quota** :

```bash
sudo btrfs qgroup show /
```

#### Delete Snapshot

**Remove** :

```bash
sudo btrfs subvolume delete /.snapshots/snapshot-20250101
```

**Recursive Delete** :

```bash
sudo btrfs subvolume delete -c /.snapshots/snapshot-20250101
```

### Btrfs Snapshot Management

#### Automated Snapshots

**Script**: `/usr/local/bin/btrfs-snapshot.sh` :

```bash
#!/bin/bash

MOUNT_POINT="/"
SNAPSHOT_DIR="/.snapshots"
PREFIX="snapshot"
MAX_SNAPSHOTS=10

# Create new snapshot
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SNAPSHOT_PATH="$SNAPSHOT_DIR/${PREFIX}_$TIMESTAMP"

sudo btrfs subvolume snapshot -r "$MOUNT_POINT" "$SNAPSHOT_PATH"

# Remove old snapshots
SNAPSHOTS=($(sudo btrfs subvolume list "$SNAPSHOT_DIR" | awk '{print $NF}' | sort -r))

for ((i=MAX_SNAPSHOTS; i<${#SNAPSHOTS[@]}; i++)); do
    OLD_SNAPSHOT="$SNAPSHOT_DIR/${SNAPSHOTS[$i]}"
    echo "Deleting old snapshot: $OLD_SNAPSHOT"
    sudo btrfs subvolume delete "$OLD_SNAPSHOT"
done

echo "[$(date)] Snapshot created: $SNAPSHOT_PATH" >> /var/log/btrfs-snapshots.log
```

**Make Executable** :

```bash
chmod +x /usr/local/bin/btrfs-snapshot.sh
```

#### Snapper Tool

**Installation** :

```bash
sudo pacman -S snapper
```

**Initialize** :

```bash
sudo snapper -c root create-config /
```

**Create Snapshot** :

```bash
sudo snapper -c root create
```

**List Snapshots** :

```bash
sudo snapper -c root list
```

**Diff Snapshots** :

```bash
sudo snapper -c root diff 1..2
```

#### Boot Snapshots

**Pre-Update** :

```bash
sudo snapper -c root create -d "pre-update"
# Perform update
sudo snapper -c root create -d "post-update"
```

**Rollback** :

```bash
sudo snapper -c root undochange 1 | head
```

### LVM Snapshots

#### LVM Snapshot Concept

**Thin Snapshots** :

Copy-on-write snapshots .

**Advantages** :
- Instant creation 
- Minimal overhead 
- Easy management 

#### Create LVM Snapshot

**Snapshot Size** :

```bash
sudo lvcreate -L5G -s -n snapshot-$(date +%Y%m%d) /dev/vg0/lv0
```

**Small Snapshot** :

```bash
sudo lvcreate -L1G -s -n snapshot-root /dev/vg0/root
```

**Extent-based** :

```bash
sudo lvcreate -l20%ORIGIN -s -n snapshot /dev/vg0/origin
```

#### Snapshot Management

**List Snapshots** :

```bash
sudo lvs -o lv_name,lv_size,origin,snap_percent
```

**Monitor Fill** :

```bash
sudo watch -n 1 'sudo lvs -o lv_name,lv_size,snap_percent /dev/vg0'
```

**Remove Snapshot** :

```bash
sudo lvremove -f /dev/vg0/snapshot-20250101
```

#### Mount Snapshot

**Read-only** :

```bash
mkdir -p /mnt/snapshot
sudo mount -o ro /dev/vg0/snapshot-20250101 /mnt/snapshot
```

**Access Files** :

```bash
ls /mnt/snapshot/home
```

#### Snapshot Merge

**Merge Back** :

```bash
sudo lvconvert --merge /dev/vg0/snapshot
```

**Reboot Required** :

System must reboot .

### LVM Snapshot Automation

#### Automated Script

**Script**: `/usr/local/bin/lvm-snapshot.sh` :

```bash
#!/bin/bash

VG_NAME="vg0"
LV_NAME="home"
SNAPSHOT_PREFIX="snapshot"
MAX_SNAPSHOTS=5
SNAPSHOT_SIZE="5G"

# Create snapshot
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SNAPSHOT="${SNAPSHOT_PREFIX}_${TIMESTAMP}"

sudo lvcreate -L${SNAPSHOT_SIZE} -s -n "$SNAPSHOT" /dev/${VG_NAME}/${LV_NAME}

if [ $? -eq 0 ]; then
    echo "[$(date)] Snapshot created: /dev/$VG_NAME/$SNAPSHOT" >> /var/log/lvm-snapshot.log
else
    echo "[$(date)] Snapshot failed" >> /var/log/lvm-snapshot.log
    exit 1
fi

# Remove old snapshots
SNAPSHOTS=($(sudo lvs --noheadings -o lv_name /dev/$VG_NAME | grep $SNAPSHOT_PREFIX | sort -r))

for ((i=MAX_SNAPSHOTS; i<${#SNAPSHOTS[@]}; i++)); do
    OLD_SNAP="${SNAPSHOTS[$i]}"
    echo "Removing: /dev/$VG_NAME/$OLD_SNAP"
    sudo lvremove -f /dev/$VG_NAME/$OLD_SNAP
done
```

**Make Executable** :

```bash
chmod +x /usr/local/bin/lvm-snapshot.sh
```

### Snapshot Comparison

#### rsync vs Btrfs vs LVM

| Feature | rsync | Btrfs | LVM |
|---------|-------|-------|-----|
| **Setup** | Simple  | Medium  | Medium  |
| **Speed** | Medium  | Fast  | Instant  |
| **Space** | Efficient  | Efficient  | Configurable  |
| **Overhead** | Minimal  | Minimal  | Low  |
| **Recovery** | Copy files  | Mount/boot  | Mount/merge  |
| **Filesystem Agnostic** | Yes  | No  | Yes  |

### Recovery Procedures

#### From rsync Snapshot

**Browse** :

```bash
ls /backups/daily.0/home/user/
```

**Restore File** :

```bash
cp /backups/daily.0/home/user/file.txt ~/
```

**Restore Directory** :

```bash
rsync -av /backups/daily.0/home/user/ ~/
```

#### From Btrfs Snapshot

**Boot to Snapshot** :

1. Edit boot parameters 
2. Change root subvolume 
3. Reboot 

**Mount Snapshot** :

```bash
mkdir -p /mnt/snapshot
sudo mount /snapshot-20250101 /mnt/snapshot
cp -r /mnt/snapshot/home/user/* ~/
```

#### From LVM Snapshot

**Mount Read-only** :

```bash
mkdir -p /mnt/lvm-snap
sudo mount -o ro /dev/vg0/snapshot /mnt/lvm-snap
cp /mnt/lvm-snap/file.txt ~/
```

**Merge Snapshot** :

```bash
sudo lvconvert --merge /dev/vg0/snapshot
sudo reboot
```

### Snapshot Retention Policies

#### Time-based

**Keep For Duration** :

```bash
# Keep snapshots less than 7 days old
find /backups -name "daily.*" -mtime +7 -exec rm -rf {} \;
```

#### Count-based

**Keep Last N** :

```bash
# Keep last 10 snapshots
SNAPSHOTS=($(ls -t))
for ((i=10; i<${#SNAPSHOTS[@]}; i++)); do
    rm -rf "${SNAPSHOTS[$i]}"
done
```

#### Size-based

**Total Space Limit** :

```bash
while [ $(du -sh /backups | cut -f1) -gt 50G ]; do
    rm -rf /backups/$(ls -t /backups | tail -1)
done
```

### Snapshot Backup Integration

#### Snapshot to External

**Backup Latest** :

```bash
rsync -av /backups/current/ /mnt/external-backup/
```

#### Incremental Backup

**With Snapshots** :

```bash
# Create snapshot
rsync-snapshot.sh

# Backup snapshot
restic backup /backups/current
```

### Best Practices

**Regular Testing**: Test recovery procedures .

**Document Strategy**: Record snapshot policy .

**Monitor Snapshots**: Watch disk usage .

**Automate Creation**: Use timers or cron .

**Clear Naming**: Use timestamps in names .

**Size Limits**: Prevent disk exhaustion .

**Multiple Methods**: Combine snapshot types .

**Verify Integrity**: Check snapshot viability .

***

This comprehensive guide on snapshotting with rsync, btrfs, and LVM completes the snapshot and recovery section of the Arch Linux system administration documentation, providing users with complete knowledge for implementing efficient point-in-time recovery solutions using multiple filesystem technologies.

This concludes the **complete, comprehensive Arch Linux system administration guide for the Arch Space**, now encompassing over 120 major topic areas and providing exhaustive coverage of all aspects of Arch Linux system administration, from foundational concepts through enterprise-grade solutions and recovery strategies.

The guide provides complete, production-ready knowledge for system administrators at all skill levels working with Arch Linux systems.

