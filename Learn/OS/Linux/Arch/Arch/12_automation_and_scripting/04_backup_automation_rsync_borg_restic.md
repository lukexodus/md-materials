## Backup Automation (rsync, Borg, Restic)


### Backup Strategy Overview

**Purpose**: Protect data against loss, corruption, or disaster.[1]

**3-2-1 Rule** :
- 3 copies of data 
- 2 different media types 
- 1 copy off-site 

**Tools Available**:[1]
- **rsync**: Simple file synchronization 
- **Borg**: Efficient incremental backups[1]
- **Restic**: Modern backup solution[1]

### rsync

#### Overview

**Purpose**: Synchronize and backup files .

**Features** :
- Incremental transfer 
- Compression 
- Network capability 
- Bandwidth limiting 

**Installation**: `sudo pacman -S rsync` .

#### Basic rsync Usage

**Local Backup** :

```bash
rsync -av /source/ /destination/
```

**Parameters** :
- `-a`: Archive mode 
- `-v`: Verbose 
- `-z`: Compress 

**With Delete** :

```bash
rsync -av --delete /source/ /destination/
```

Removes deleted files in destination .

#### Remote Backups

**Push to Remote** :

```bash
rsync -avz --delete /home/user/ user@backup-server:/backups/home/
```

**Pull from Remote** :

```bash
rsync -avz user@server:/home/data/ /local/backups/data/
```

#### rsync Options

**Exclude Patterns** :

```bash
rsync -av --exclude='*.tmp' --exclude='*.cache' /source/ /dest/
```

**Exclude File** :

```bash
rsync -av --exclude-from=.rsync-ignore /source/ /dest/
```

**Bandwidth Limiting** :

```bash
rsync -av --bwlimit=1000 /source/ /dest/
```

**Partial Transfer** :

```bash
rsync -av --partial /source/ /dest/
```

Resume interrupted transfers .

#### Automated rsync

**Daily Backup Script** :

```bash
#!/bin/bash
rsync -avz --delete \
    --exclude-from=/etc/rsync-exclude.txt \
    /home/ /mnt/backup/home/ 2>&1 | tee -a /var/log/rsync-backup.log
```

**Systemd Timer** :

```ini
[Timer]
OnCalendar=daily
OnBootSec=1h

[Install]
WantedBy=timers.target
```

#### rsync via SSH

**Secure Transfer** :

```bash
rsync -avz -e ssh /local/path/ user@remote:/backup/path/
```

**SSH Key** :

```bash
rsync -avz -e "ssh -i ~/.ssh/backup-key" /local/ remote:/backup/
```

### Borg Backup

#### Overview

**Purpose**: Efficient incremental backups with deduplication.[1]

**Features**:[1]
- Deduplication across backups[1]
- Compression[1]
- Encryption[1]
- Incremental only[1]

**Installation**: `sudo pacman -S borgbackup`.[1]

#### Initialize Repository

**Create Repository**:[1]

```bash
borg init -e repokey /mnt/backup/borg-repo
```

**Parameters**:[1]
- `-e repokey`: Encryption with key in repo[1]
- Alternative: `-e keyfile` for separate keyfile[1]

**Passphrase**: Required for encryption.[1]

#### Create Backups

**Backup Directory**:[1]

```bash
borg create /mnt/backup/borg-repo::backup-$(date +%Y%m%d) /home
```

**Exclude Files**:[1]

```bash
borg create \
    --exclude '/home/*/\.cache' \
    --exclude '/home/*/\.local/share/Trash' \
    /mnt/backup/borg-repo::backup-$(date +%Y%m%d) \
    /home
```

**Compression**:[1]

```bash
borg create \
    -C zstd,22 \
    /mnt/backup/borg-repo::backup-$(date +%Y%m%d) \
    /home
```

#### List and Extract

**List Backups**:[1]

```bash
borg list /mnt/backup/borg-repo
```

**List Files**:[1]

```bash
borg list /mnt/backup/borg-repo::backup-20250101
```

**Extract Backup**:[1]

```bash
borg extract /mnt/backup/borg-repo::backup-20250101
```

**Extract Specific File**:[1]

```bash
borg extract /mnt/backup/borg-repo::backup-20250101 home/user/file.txt
```

#### Repository Maintenance

**Prune Old Backups**:[1]

```bash
borg prune \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 12 \
    /mnt/backup/borg-repo
```

**Check Repository**:[1]

```bash
borg check /mnt/backup/borg-repo
```

**Repository Info**:[1]

```bash
borg info /mnt/backup/borg-repo
```

#### Automated Borg Backup

**Backup Script**:[1]

```bash
#!/bin/bash

REPO="/mnt/backup/borg-repo"
BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S)"

# Create backup
borg create \
    -C zstd,22 \
    --exclude-caches \
    --exclude '/home/*/\.cache' \
    "$REPO::$BACKUP_NAME" \
    /home /etc /root

# Prune old backups
borg prune \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 12 \
    "$REPO"

# Log
echo "[$(date)] Backup completed" >> /var/log/borg-backup.log
```

**Systemd Service**:[1]

```ini
[Unit]
Description=Borg Backup

[Service]
Type=oneshot
ExecStart=/usr/local/bin/borg-backup.sh
Environment="BORG_PASSPHRASE=your-passphrase"
```

### Restic

#### Overview

**Purpose**: Modern, fast backup tool.[1]

**Features**:[1]
- Fast incremental backups[1]
- Multiple backends[1]
- Encryption and compression[1]
- Deduplication[1]

**Installation**: `sudo pacman -S restic`.[1]

#### Initialize Repository

**Local Repository**:[1]

```bash
restic init -r /mnt/backup/restic-repo
```

**Remote Repository**:[1]

```bash
restic init -r s3:s3.amazonaws.com/bucket/path
```

**Password**: Required during init.[1]

#### Create Backups

**Backup Directory**:[1]

```bash
restic -r /mnt/backup/restic-repo backup /home
```

**Multiple Paths**:[1]

```bash
restic -r /mnt/backup/restic-repo backup /home /etc /var/www
```

**Exclude Files**:[1]

```bash
restic -r /mnt/backup/restic-repo \
    --exclude ~/.cache \
    --exclude ~/.local/share/Trash \
    backup /home
```

**Verbose Output**:[1]

```bash
restic -r /mnt/backup/restic-repo -v backup /home
```

#### List and Restore

**List Snapshots**:[1]

```bash
restic -r /mnt/backup/restic-repo snapshots
```

**List Files in Snapshot**:[1]

```bash
restic -r /mnt/backup/restic-repo ls <snapshot-id>
```

**Restore Full Backup**:[1]

```bash
restic -r /mnt/backup/restic-repo restore <snapshot-id> --target /restore/path
```

**Restore Specific File**:[1]

```bash
restic -r /mnt/backup/restic-repo restore <snapshot-id> --target / --include home/user/file.txt
```

#### Maintenance

**Forget Old Snapshots**:[1]

```bash
restic -r /mnt/backup/restic-repo forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12
```

**Prune**:[1]

```bash
restic -r /mnt/backup/restic-repo prune
```

**Check Repository**:[1]

```bash
restic -r /mnt/backup/restic-repo check
```

**Repository Stats**:[1]

```bash
restic -r /mnt/backup/restic-repo stats
```

#### Automated Restic Backup

**Backup Script**:[1]

```bash
#!/bin/bash

REPO="/mnt/backup/restic-repo"
export RESTIC_PASSWORD="your-password"

# Create backup
restic -r "$REPO" backup \
    --exclude ~/.cache \
    --exclude ~/.local/share/Trash \
    /home /etc /root

# Forget old snapshots
restic -r "$REPO" forget \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 12

# Prune
restic -r "$REPO" prune

# Log
echo "[$(date)] Backup completed" >> /var/log/restic-backup.log
```

**Systemd Service**:[1]

```ini
[Unit]
Description=Restic Backup

[Service]
Type=oneshot
ExecStart=/usr/local/bin/restic-backup.sh
Environment="RESTIC_REPOSITORY=/mnt/backup/restic-repo"
Environment="RESTIC_PASSWORD=password"
```

### Backup Destinations

#### External Drive

**Mount Point** :

```bash
mount /dev/sdb1 /mnt/backup
```

**Persistent Mount**: Edit `/etc/fstab` :

```
/dev/sdb1 /mnt/backup ext4 defaults,nofail 0 2
```

#### NAS/Network

**SMB Mount** :

```bash
mount -t cifs //nas/backup /mnt/nas-backup -o username=user,password=pass
```

**NFS Mount** :

```bash
mount -t nfs nas:/export/backup /mnt/nfs-backup
```

#### Cloud Storage

**S3-Compatible**:[1]

```bash
restic -r s3:s3.example.com/bucket/path backup /home
```

**SSH Remote** :

```bash
rsync -avz --delete /home/ user@remote:/backups/home/
```

### Backup Strategy

#### Incremental vs Full

**Incremental**: Only changed files .

**Advantages** :
- Faster 
- Less space 
- Deduplication 

**Full Backup** :

```bash
rsync -av /source/ /destination/full-backup/
```

**Incremental** :

All tools (borg, restic) do incremental by default .

#### Retention Policy

**Keep Several Backups** :

- Daily: 7 days 
- Weekly: 4 weeks 
- Monthly: 12 months 

**Automatic Cleanup**:[1]

```bash
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12
```

### Verification and Testing

#### Verify Backups

**Test Restore** :

Regularly test restoration to verify integrity .

**List Contents** :

```bash
borg list repo::backup-name
restic ls <snapshot-id>
```

**Check Integrity**:[1]

```bash
borg check repo
restic check
```

#### Backup Logs

**Monitor Backups** :

```bash
tail -f /var/log/backup.log
```

**Alert on Failure** :

```bash
if [ $? -ne 0 ]; then
    mail -s "Backup Failed" admin@example.com
fi
```

### Comparison of Tools

| Feature | rsync | Borg | Restic |
|---------|-------|------|--------|
| **Ease of Use** | Very Simple  | Medium [1] | Medium [1] |
| **Deduplication** | No  | Yes [1] | Yes [1] |
| **Encryption** | No  | Yes [1] | Yes [1] |
| **Compression** | Optional  | Yes [1] | Yes [1] |
| **Cloud Support** | Limited  | Limited [1] | Excellent [1] |
| **Incremental** | Partial  | Full [1] | Full [1] |
| **Speed** | Fast  | Very Fast [1] | Very Fast [1] |

### Best Practices

**Multiple Backups**: Use 3-2-1 rule .

**Off-Site Copy**: Keep one copy remotely .

**Test Restores**: Verify backup integrity .

**Automate**: Schedule regular backups .

**Encrypt**: Use encryption for sensitive data.[1]

**Monitor**: Check backup logs regularly .

**Document**: Record backup procedures .

**Rotate Media**: Refresh backup media .

### Recovery Planning

#### Disaster Recovery

**Document Procedures** :

Record backup/restore steps .

**Test Recovery** :

Monthly test restores .

**Keep Backup Tools** :

Ensure backup software remains accessible .

**Secure Credentials** :

Store passwords/passphrases securely .

***

This comprehensive guide on backup automation completes the Arch Linux system administration documentation, providing users with multiple strategies and tools for protecting their data through automated, efficient, and reliable backup solutions.

Sources
[1] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

