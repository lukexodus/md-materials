## Automating Updates and Maintenance


### Automated Update Overview

**Purpose**: Keep system current without manual intervention .

**Benefits** :
- Security patches applied promptly 
- Reduced manual effort 
- Consistent maintenance schedule 
- Improved system stability 

**Considerations** :
- Test before full automation 
- Archive pacman logs 
- Monitor for issues 

### Pacman Automatic Updates

#### Systemd Timer for Updates

**Create Service**: `/etc/systemd/system/pacman-update.service` :

```ini
[Unit]
Description=Pacman Update
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/pacman -Syu --noconfirm
StandardOutput=journal
StandardError=journal
```

**Create Timer**: `/etc/systemd/system/pacman-update.timer` :

```ini
[Unit]
Description=Daily Pacman Update
Requires=pacman-update.service

[Timer]
OnCalendar=daily
OnBootSec=5min
Persistent=true

[Install]
WantedBy=timers.target
```

**Enable** :

```bash
sudo systemctl enable --now pacman-update.timer
```

**Verify** :

```bash
sudo systemctl list-timers pacman-update.timer
```

#### Cron-Based Updates

**Add to Crontab** :

```bash
sudo crontab -e
```

**Update Daily at 3 AM** :

```
0 3 * * * /usr/bin/pacman -Syu --noconfirm >> /var/log/pacman-update.log 2>&1
```

**Update Weekly** :

```
0 3 * * 0 /usr/bin/pacman -Syu --noconfirm
```

### Email Notifications

#### Configure Postfix

**Install Postfix**: `sudo pacman -S postfix` :

```bash
sudo systemctl enable --now postfix.service
```

#### Notification Script

**Create Script**: `/usr/local/bin/pacman-notify.sh` :

```bash
#!/bin/bash

# Run update
OUTPUT=$(pacman -Syu --noconfirm 2>&1)
STATUS=$?

# Send email
{
    echo "Pacman Update Report - $(date)"
    echo "Exit Code: $STATUS"
    echo ""
    echo "$OUTPUT"
} | mail -s "System Update Report" admin@example.com

# Log update
echo "[$(date)] Pacman update completed with status $STATUS" >> /var/log/pacman-updates.log
```

**Make Executable** :

```bash
sudo chmod +x /usr/local/bin/pacman-notify.sh
```

**Systemd Service** :

```ini
[Unit]
Description=Pacman Update with Notification

[Service]
Type=oneshot
ExecStart=/usr/local/bin/pacman-notify.sh
```

### Automatic Security Updates

#### Security-Only Updates

**Selective Updates**: Only security patches :

```bash
pacman -S $(pacman -Qu | grep -i 'security\|crit\|vulner' | awk '{print $1}')
```

**Script** :

```bash
#!/bin/bash
# Only update critical/security packages

CRITICAL_PACKAGES="linux glibc openssl curl"

for pkg in $CRITICAL_PACKAGES; do
    pacman -S --needed --noconfirm $pkg
done
```

#### Arch Security Team

**Follow Announcements** :

Subscribe to archlinux-announce mailing list .

**Check Security** :

```bash
curl https://security.archlinux.org/json
```

### System Maintenance Tasks

#### Automated Cleanup

**Orphaned Packages**: `/etc/systemd/system/orphan-cleanup.service` :

```ini
[Unit]
Description=Remove Orphaned Packages

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'pacman -Qdtq | pacman -Rns --noconfirm -'
```

**Journal Vacuum** :

```ini
[Unit]
Description=Vacuum Journal

[Service]
Type=oneshot
ExecStart=/usr/bin/journalctl --vacuum-time=30d
```

**Cache Cleaning** :

```ini
[Unit]
Description=Clean Pacman Cache

[Service]
Type=oneshot
ExecStart=/usr/bin/pacman -Sc --noconfirm
```

#### Scheduled Cleanup

**Weekly Timer** :

```ini
[Timer]
OnCalendar=weekly
OnBootSec=10min
Persistent=true
```

**Enable All** :

```bash
sudo systemctl enable --now orphan-cleanup.timer
sudo systemctl enable --now journal-vacuum.timer
sudo systemctl enable --now pacman-clean.timer
```

### AUR Helper Updates

#### yay Automatic Updates

**Configure yay** :

Create `/usr/local/bin/yay-update.sh`:

```bash
#!/bin/bash
cd /tmp
yay -Syu --noconfirm --cleanafter 2>&1 | tee -a /var/log/yay-updates.log
```

**Schedule** :

```
0 4 * * * /usr/local/bin/yay-update.sh
```

#### paru Automatic Updates

**Similar to yay** :

```bash
#!/bin/bash
paru -Syu --noconfirm 2>&1 | tee -a /var/log/paru-updates.log
```

### Kernel and Bootloader Updates

#### Kernel Update Handling

**Track Kernel Version** :

```bash
#!/bin/bash
CURRENT=$(uname -r)
INSTALLED=$(pacman -Q linux | awk '{print $2}')

if [ "$CURRENT" != "$INSTALLED" ]; then
    echo "Kernel update available: $CURRENT -> $INSTALLED"
    echo "Please reboot to apply update"
fi
```

#### Bootloader Maintenance

**Regenerate GRUB Config** :

```bash
#!/bin/bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**Schedule After Updates** :

Hook after pacman updates .

### System Backup Automation

#### Automated Backups

**Daily Backup Script**: `/usr/local/bin/backup.sh` :

```bash
#!/bin/bash

BACKUP_DIR="/mnt/backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/system_$TIMESTAMP.tar.gz"

# Create backup
tar --exclude=/proc --exclude=/sys --exclude=/dev \
    -czf "$BACKUP_FILE" / 2>/dev/null

# Keep only last 7 backups
find "$BACKUP_DIR" -name "system_*.tar.gz" -mtime +7 -delete

# Log result
echo "[$(date)] Backup to $BACKUP_FILE completed" >> /var/log/backup.log
```

**Systemd Service** :

```ini
[Unit]
Description=System Backup

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
```

**Timer** :

```ini
[Timer]
OnCalendar=daily
OnBootSec=1h
Persistent=true
```

#### Selective Backups

**Home Directory Only** :

```bash
#!/bin/bash
BACKUP_DATE=$(date +%Y%m%d)
tar -czf /backup/home_$BACKUP_DATE.tar.gz /home
```

**Configuration Files** :

```bash
#!/bin/bash
tar -czf /backup/etc_backup.tar.gz /etc
```

### Monitoring and Logging

#### Update Logs

**Log Location** :

```bash
tail -f /var/log/pacman.log
```

**Parsed Logs** :

```bash
grep "Installed\|Upgraded\|Removed" /var/log/pacman.log | tail -20
```

#### System Health Check

**Status Script**: `/usr/local/bin/health-check.sh` :

```bash
#!/bin/bash

echo "=== System Health Report ==="
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Disk Usage:"
df -h | tail -5
echo ""
echo "Failed Services:"
systemctl list-units --failed
echo ""
echo "Recent Errors:"
journalctl -p err -n 5
```

**Scheduled Check** :

```bash
0 6 * * * /usr/local/bin/health-check.sh | mail -s "System Health Report" admin@example.com
```

### Update Rollback Automation

#### Snapshot Before Updates

**Pre-Update Snapshot** :

```bash
#!/bin/bash
# For Btrfs
sudo btrfs subvolume snapshot / /.snapshots/pre-update-$(date +%Y%m%d)
```

#### Automatic Rollback

**Rollback Script** :

```bash
#!/bin/bash

# If boot fails, suggest rollback
CURRENT_KERNEL=$(cat /proc/cmdline | grep -o 'vmlinuz-[^ ]*')
INSTALLED_KERNEL=$(pacman -Q linux | awk '{print $2}')

if [ "$CURRENT_KERNEL" != "$INSTALLED_KERNEL" ]; then
    echo "Kernel mismatch detected"
    echo "Consider: sudo pacman -U /var/cache/pacman/pkg/linux-old-version.pkg.tar.zst"
fi
```

### Unattended Upgrades

#### Automatic Degradation Handling

**Safe Update** :

```bash
#!/bin/bash
set -e

echo "Starting system update..."

# Backup before update
cp -r /etc /etc.backup.$(date +%s)

# Perform update
pacman -Syu --noconfirm

# Verify critical services
systemctl status sshd || {
    echo "SSH failed to start"
    exit 1
}

echo "Update completed successfully"
```

### Maintenance Windows

#### Scheduled Maintenance

**Off-Peak Updates** :

Configure timer to run during low-usage hours :

```ini
[Timer]
OnCalendar=*-*-* 02:00:00
OnCalendar=*-*-* 14:00:00
```

**Maintenance Notification** :

```bash
#!/bin/bash
wall "System maintenance will start in 10 minutes"
sleep 600
systemctl start pacman-update.service
```

### Best Practices

**Test First**: Try on non-critical system .

**Monitor Logs**: Review update history regularly .

**Backup Before Updates**: Protect against failures .

**Notify Users**: Warn of maintenance windows .

**Document Process**: Record automation setup .

**Have Rollback Plan**: Be ready to revert .

**Gradual Rollout**: Start with non-critical servers .

**Review Changes**: Monitor for unexpected behavior .

### Monitoring Tools

#### Check-update Service

**Periodic Check** :

```bash
sudo pacman -Qu
```

**Automated Notification** :

```bash
#!/bin/bash
UPDATES=$(pacman -Qu | wc -l)
if [ $UPDATES -gt 0 ]; then
    echo "$UPDATES package updates available" | wall
fi
```

#### Log Rotation

**Logrotate Configuration**: `/etc/logrotate.d/pacman-updates` :

```
/var/log/pacman-update.log {
    daily
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 root root
}
```

***

This comprehensive guide on automating updates and maintenance completes the Arch Linux system administration documentation, providing users with the knowledge to maintain their systems automatically while ensuring security, stability, and minimal manual intervention.

