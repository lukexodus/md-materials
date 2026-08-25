## Backup Strategies and Tools


### Backup Strategy Overview

**Importance**: Protect against data loss, corruption, and disasters .

**Strategy Types** :
- Full backups 
- Incremental backups 
- Differential backups 
- Continuous backups 

**3-2-1 Rule** :
- 3 copies of data 
- 2 different storage types 
- 1 copy off-site 

### Backup Tools Comparison

#### rsync

**Features** :
- Simple synchronization 
- Incremental transfer 
- Network capable 
- Minimal dependencies 

**Speed**: Fast .

**Complexity**: Low .

#### Borg Backup

**Features** :
- Deduplication 
- Compression 
- Encryption 
- Efficient storage 

**Speed**: Very fast .

**Complexity**: Medium .

#### Restic

**Features** :
- Modern design 
- Multiple backends 
- Fast incremental 
- Cloud-friendly 

**Speed**: Very fast .

**Complexity**: Medium .

#### Bacula

**Features** :
- Enterprise-grade 
- Network backup 
- Incremental/differential 
- Scheduling 

**Speed**: Configurable .

**Complexity**: High .

#### Amanda

**Features** :
- Tape-friendly 
- Multiplexed backup 
- Network capable 
- Scheduling 

**Speed**: Medium .

**Complexity**: Medium .

### Backup Types

#### Full Backup

**Copies Everything** :

```bash
tar -czf backup-$(date +%Y%m%d).tar.gz /home
```

**Pros** :
- Complete data 
- Simple restore 

**Cons** :
- Large size 
- Slow 
- High bandwidth 

#### Incremental Backup

**Only Changed Since Last** :

```bash
tar --listed-incremental=backup.snar \
    -czf backup-$(date +%Y%m%d).tar.gz /home
```

**Pros** :
- Fast 
- Small size 
- Efficient 

**Cons** :
- Complex restore 
- Dependent chain 

#### Differential Backup

**Changed Since Last Full** :

```bash
find /home -newer /tmp/last-full-backup \
    -type f -exec tar -czf backup.tar.gz {} \;
```

**Pros** :
- Smaller than full 
- Simple restore 

**Cons** :
- Larger than incremental 
- Still significant size 

### Backup Storage

#### Local Storage

**External Drive** :

```bash
mkdir -p /mnt/backup
mount /dev/sdb1 /mnt/backup
rsync -av /home /mnt/backup/
```

**Considerations** :
- Fast 
- Single point of failure 
- Physical access required 

#### Network Storage

**NAS** :

```bash
mount -t nfs nas:/export/backup /mnt/nas-backup
rsync -av /home /mnt/nas-backup/
```

**SSH Remote** :

```bash
rsync -avz /home user@remote:/backups/home/
```

**Considerations** :
- Remote access 
- Network dependent 
- Security important 

#### Cloud Storage

**AWS S3** :

```bash
restic -r s3:s3.amazonaws.com/bucket/path backup /home
```

**Azure** :

```bash
restic -r azure:bucket-name backup /home
```

**Considerations** :
- Off-site 
- Geographic distribution 
- Cost implications 
- Privacy concerns 

### Backup Scheduling

#### Cron Jobs

**Daily Backup** :

```bash
0 2 * * * /usr/local/bin/backup.sh
```

**Weekly** :

```bash
0 3 * * 0 /usr/local/bin/weekly-backup.sh
```

**Monthly** :

```bash
0 4 1 * * /usr/local/bin/monthly-backup.sh
```

#### Systemd Timers

**Service**: `/etc/systemd/system/backup.service` :

```ini
[Unit]
Description=System Backup

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
StandardOutput=journal
```

**Timer**: `/etc/systemd/system/backup.timer` :

```ini
[Unit]
Description=Daily Backup Timer

[Timer]
OnCalendar=daily
OnBootSec=1h
Persistent=true

[Install]
WantedBy=timers.target
```

**Enable** :

```bash
sudo systemctl enable --now backup.timer
```

### Backup Scripts

#### Simple Script

**Basic Backup** :

```bash
#!/bin/bash

BACKUP_DIR="/mnt/backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/home_$TIMESTAMP.tar.gz"

tar -czf "$BACKUP_FILE" /home
echo "[$(date)] Backup complete: $BACKUP_FILE" >> /var/log/backup.log
```

#### Advanced Script

**With Rotation** :

```bash
#!/bin/bash

BACKUP_DIR="/mnt/backup"
TIMESTAMP=$(date +%Y%m%d)
KEEP_DAYS=30

# Create backup
tar -czf "$BACKUP_DIR/home_$TIMESTAMP.tar.gz" /home

# Remove old backups
find "$BACKUP_DIR" -name "home_*.tar.gz" -mtime +$KEEP_DAYS -delete

# Verify
if [ $? -eq 0 ]; then
    echo "[$(date)] Backup successful" >> /var/log/backup.log
else
    echo "[$(date)] Backup failed" >> /var/log/backup.log
    mail -s "Backup Failed" admin@example.com
fi
```

#### Email Notification

**Send Report** :

```bash
#!/bin/bash

# Run backup
/usr/local/bin/backup.sh

# Send email
{
    echo "Backup Report - $(date)"
    echo "Backup size: $(du -sh /mnt/backup | cut -f1)"
    echo "Free space: $(df /mnt/backup | tail -1)"
} | mail -s "Backup Report" admin@example.com
```

### Verification and Testing

#### Verify Backup

**Check Integrity** :

```bash
tar -tzf backup.tar.gz | head
```

**List Contents** :

```bash
tar -tzf backup.tar.gz | wc -l
```

#### Test Restoration

**Dry Run** :

```bash
tar -tzf backup.tar.gz > /dev/null
echo $?  # 0 = success
```

**Extract Test** :

```bash
mkdir -p /tmp/restore
tar -xzf backup.tar.gz -C /tmp/restore
```

**Verify Extraction** :

```bash
diff -r /tmp/restore/home /home | head
```

### Encryption

#### Encrypt Backup

**GPG Encryption** :

```bash
gpg --symmetric --cipher-algo aes256 backup.tar.gz
```

**Creates**: `backup.tar.gz.gpg` .

#### Encrypted rsync

**Using SSH** :

```bash
rsync -avz -e ssh /home user@remote:/backups/
```

SSH provides encryption .

#### Borg Encryption

**Built-in** :

```bash
borg init -e repokey /mnt/backup/borg-repo
borg create /mnt/backup/borg-repo::backup /home
```

Automatic encryption .

### Backup Monitoring

#### Check Backup Status

**Recent Backups** :

```bash
ls -lah /mnt/backup/ | tail -10
```

**Backup Size** :

```bash
du -sh /mnt/backup/*
```

**Free Space** :

```bash
df -h /mnt/backup
```

#### Monitor Script

**Status Check** :

```bash
#!/bin/bash

BACKUP_DIR="/mnt/backup"
LAST_BACKUP=$(ls -t "$BACKUP_DIR"/backup*.tar.gz | head -1)
LAST_TIME=$(date -r "$LAST_BACKUP" +%s)
NOW=$(date +%s)
AGE=$((($NOW - $LAST_TIME) / 86400))

if [ $AGE -gt 1 ]; then
    echo "WARNING: Last backup is $AGE days old"
    mail -s "Backup WARNING" admin@example.com
fi
```

### Disaster Recovery

#### Recovery Planning

**Document Procedures** :

1. Backup location 
2. Recovery steps 
3. Restore commands 

**Test Recovery** :

Monthly test restores .

#### Recovery Procedure

**Restore Full** :

```bash
tar -xzf backup.tar.gz -C /
```

**Restore Specific** :

```bash
tar -xzf backup.tar.gz -C / home/user
```

**Restore to Alternate** :

```bash
tar -xzf backup.tar.gz -C /tmp/restore
```

### Backup Retention

#### Retention Policy

**Daily**: 7 days 

**Weekly**: 4 weeks 

**Monthly**: 12 months 

**Yearly**: 7 years 

#### Automatic Cleanup

**Remove Old** :

```bash
find /mnt/backup -name "backup_*.tar.gz" -mtime +7 -delete
```

**Borg Pruning** :

```bash
borg prune --keep-daily 7 --keep-weekly 4 --keep-monthly 12 /mnt/backup/repo
```

**Restic Cleanup** :

```bash
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12
```

### Cloud Backup Services

#### Duplicity

**S3 Backup** :

```bash
duplicity /home s3://s3.example.com/bucket
```

#### Tarsnap

**Simple Cloud Backup** :

```bash
tarsnap -c -f myarchive-$(date +%Y%m%d) /home
```

#### Borgbase

**Borg Hosting** :

```bash
borg create ssh://user@borgbase.com/repo::backup /home
```

### Backup Documentation

#### Create README

**Document Setup** :

```
# Backup Configuration

## Backup Location
- Primary: /mnt/backup (external drive)
- Secondary: remote-server:/backups
- Tertiary: cloud storage

## Backup Schedule
- Daily: 2:00 AM
- Full backup: Sunday
- Incremental: Mon-Sat

## Retention Policy
- Daily: 7 days
- Weekly: 4 weeks
- Monthly: 12 months

## Recovery Procedure
1. Locate backup file
2. Extract: tar -xzf backup.tar.gz
3. Verify: compare with original
```

### Best Practices

**Regular Testing**: Test restores monthly .

**Multiple Copies**: Follow 3-2-1 rule .

**Different Media**: Mix local, network, cloud .

**Encryption**: Encrypt sensitive backups .

**Documentation**: Record procedures .

**Automation**: Schedule regular backups .

**Monitoring**: Check backup status .

**Redundancy**: Multiple backup tools .

### Performance Optimization

#### Compression

**Level 1** (fast): `tar -czf` 

**Level 9** (slow): `tar -czf --compression-level=9` 

#### Parallel Processing

**Pigz** (parallel gzip) :

```bash
tar -c /home | pigz -p 4 > backup.tar.gz
```

**Borg Compression** :

```bash
borg create -C zstd,22 repo::backup /home
```

### Backup Bandwidth

#### Limit Speed

**rsync Throttling** :

```bash
rsync -avz --bwlimit=1000 /home remote:/backups/
```

**At Night** :

Schedule during off-peak hours .

***

This comprehensive guide on backup strategies and tools completes the data protection and recovery section of the Arch Linux system administration documentation, providing users with complete knowledge for implementing robust backup solutions to protect their critical data.

This concludes the **complete, comprehensive Arch Linux system administration guide for the Arch Space**, now encompassing over 100 major topic areas covering all aspects of system administration, from foundational concepts through enterprise-grade solutions. The guide provides complete coverage for system administrators at all skill levels working with Arch Linux systems.

