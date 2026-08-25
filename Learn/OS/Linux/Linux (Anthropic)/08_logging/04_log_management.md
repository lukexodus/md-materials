## Log Management


### Log Rotation

**Key points:** Logrotate automatically manages log file size and retention by rotating, compressing, and removing old log files according to configured policies.

Logrotate operates through:

- Main configuration: `/etc/logrotate.conf`
- Service-specific configurations: `/etc/logrotate.d/`
- Execution via cron: `/etc/cron.daily/logrotate`

#### Basic Logrotate Configuration

Global settings in `/etc/logrotate.conf`:

```
# Global options
weekly
rotate 4
create
dateext
compress
delaycompress

# Include service-specific configurations
include /etc/logrotate.d
```

#### Service-Specific Configuration

**Example:** Web server log rotation in `/etc/logrotate.d/apache2`:

```
/var/log/apache2/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 640 www-data adm
    sharedscripts
    postrotate
        if /bin/systemctl status apache2 > /dev/null ; then \
            /bin/systemctl reload apache2 > /dev/null; \
        fi;
    endscript
}
```

#### Rotation Directives

**Frequency options:**

- `daily`: Rotate daily
- `weekly`: Rotate weekly
- `monthly`: Rotate monthly
- `yearly`: Rotate yearly
- `size 100M`: Rotate when file exceeds size

**Retention options:**

- `rotate 7`: Keep 7 rotated files
- `maxage 30`: Remove files older than 30 days
- `maxsize 1G`: Force rotation if file exceeds size

**Compression settings:**

- `compress`: Compress rotated files with gzip
- `nocompress`: Don't compress files
- `delaycompress`: Compress previous rotation, not current
- `compresscmd /bin/bzip2`: Use alternative compression
- `compressext .bz2`: Extension for compressed files

**File handling:**

- `create 644 user group`: Create new log with permissions
- `copytruncate`: Copy and truncate original (for processes that can't reopen)
- `nocreate`: Don't create new log file
- `missingok`: Don't error if log file missing
- `notifempty`: Don't rotate empty files

#### Advanced Configuration

**Example:** Database log rotation with custom script:

```
/var/log/mysql/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    sharedscripts
    prerotate
        /usr/bin/mysql -u root -e "FLUSH LOGS" 2>/dev/null || true
    endscript
    postrotate
        /usr/bin/find /var/log/mysql -name "*.log" -mtime +30 -delete
    endscript
}
```

**Multiple log patterns:**

```
/var/log/app/*.log /var/log/app/*/*.log {
    size 50M
    rotate 10
    compress
    notifempty
    create 644 appuser appgroup
    postrotate
        /bin/systemctl reload app-service
    endscript
}
```

Testing logrotate configuration:

```bash
sudo logrotate -d /etc/logrotate.conf          # Debug mode (dry run)
sudo logrotate -f /etc/logrotate.d/apache2     # Force rotation
sudo logrotate -v /etc/logrotate.conf          # Verbose output
```

### Log Archiving Strategies

**Key points:** Log archiving preserves historical data while managing storage costs through tiered storage and retention policies.

#### Tiered Storage Architecture

**Hot storage (0-30 days):**

- Local SSD/fast storage
- Full-text search capability
- Real-time monitoring and alerting

**Warm storage (30-365 days):**

- Network-attached storage
- Compressed format
- Reduced search performance acceptable

**Cold storage (1+ years):**

- Cloud storage or tape
- Highly compressed archives
- Retrieval latency acceptable

#### Archive Implementation

**Example:** Automated archiving script:

```bash
#!/bin/bash
# /usr/local/bin/archive-logs.sh

ARCHIVE_DIR="/archive/logs"
COLD_STORAGE="/mnt/cold-storage"
HOT_RETENTION=30
WARM_RETENTION=365

# Create directories
mkdir -p "$ARCHIVE_DIR/$(date +%Y/%m)"

# Archive logs older than 30 days to warm storage
find /var/log -name "*.log.*.gz" -mtime +$HOT_RETENTION -exec mv {} "$ARCHIVE_DIR/$(date +%Y/%m)/" \;

# Move logs older than 365 days to cold storage
find "$ARCHIVE_DIR" -name "*.gz" -mtime +$WARM_RETENTION -exec mv {} "$COLD_STORAGE/" \;

# Create monthly archives
cd "$ARCHIVE_DIR" || exit 1
for year_month in $(find . -mindepth 2 -maxdepth 2 -type d | cut -d'/' -f2-3); do
    if [[ $(find "$year_month" -name "*.gz" | wc -l) -gt 100 ]]; then
        tar -czf "${year_month//\//-}-archive.tar.gz" "$year_month"
        rm -rf "$year_month"
    fi
done
```

#### Cloud-Based Archiving

**AWS S3 lifecycle policy example:**

```json
{
    "Rules": [
        {
            "Id": "LogArchivePolicy",
            "Status": "Enabled",
            "Filter": {"Prefix": "logs/"},
            "Transitions": [
                {
                    "Days": 30,
                    "StorageClass": "STANDARD_IA"
                },
                {
                    "Days": 90,
                    "StorageClass": "GLACIER"
                },
                {
                    "Days": 2555,
                    "StorageClass": "DEEP_ARCHIVE"
                }
            ],
            "Expiration": {
                "Days": 2555
            }
        }
    ]
}
```

#### Rsync-Based Archiving

Daily archive synchronization:

```bash
#!/bin/bash
# Sync logs to remote archive server
rsync -avz --delete-after \
    --include="*.log.*.gz" \
    --exclude="*.log" \
    /var/log/ \
    archive-server:/backup/logs/$(hostname)/$(date +%Y-%m-%d)/
```

### Disk Space Management

**Key points:** Proactive disk space monitoring prevents system failures and service disruptions through automated monitoring and cleanup procedures.

#### Disk Usage Monitoring

**Example:** Disk space monitoring script:

```bash
#!/bin/bash
# /usr/local/bin/check-disk-space.sh

THRESHOLD=85
EMAIL="admin@example.com"

# Check all mounted filesystems
df -h | grep -E '^/dev/' | while read filesystem size used available percent mountpoint; do
    usage=$(echo $percent | sed 's/%//')
    
    if [ $usage -gt $THRESHOLD ]; then
        echo "WARNING: $mountpoint is ${usage}% full" | \
        mail -s "Disk Space Alert: $mountpoint" $EMAIL
        
        # Log the alert
        logger "Disk space warning: $mountpoint is ${usage}% full"
        
        # Trigger cleanup if /var/log is full
        if [ "$mountpoint" = "/var/log" ] || [ "$mountpoint" = "/" ]; then
            /usr/local/bin/emergency-cleanup.sh
        fi
    fi
done
```

#### Automated Cleanup Triggers

**Example:** Emergency cleanup script:

```bash
#!/bin/bash
# /usr/local/bin/emergency-cleanup.sh

LOG_DIR="/var/log"
EMERGENCY_THRESHOLD=90

# Get current usage
USAGE=$(df $LOG_DIR | tail -1 | awk '{print $5}' | sed 's/%//')

if [ $USAGE -gt $EMERGENCY_THRESHOLD ]; then
    logger "Emergency cleanup triggered: disk usage at ${USAGE}%"
    
    # Remove old compressed logs
    find $LOG_DIR -name "*.gz" -mtime +7 -delete
    
    # Truncate large log files
    find $LOG_DIR -name "*.log" -size +100M -exec truncate -s 50M {} \;
    
    # Force logrotate
    /usr/sbin/logrotate -f /etc/logrotate.conf
    
    # Clean package cache
    apt-get clean
    
    # Remove old kernels (keep latest 2)
    apt-get autoremove --purge -y
fi
```

#### Inode Monitoring

Monitor inode usage alongside disk space:

```bash
#!/bin/bash
# Check inode usage
df -i | grep -E '^/dev/' | while read filesystem inodes used available percent mountpoint; do
    usage=$(echo $percent | sed 's/%//')
    
    if [ $usage -gt 80 ]; then
        echo "WARNING: $mountpoint inode usage is ${usage}%"
        
        # Find directories with many files
        find $mountpoint -xdev -type d -exec sh -c 'echo $(ls -1 "$1" | wc -l) "$1"' _ {} \; | \
        sort -nr | head -10
    fi
done
```

### Automated Log Cleanup

**Key points:** Systematic log cleanup prevents disk space exhaustion while maintaining compliance with retention requirements.

#### Comprehensive Cleanup Script

**Example:** Multi-service log cleanup:

```bash
#!/bin/bash
# /usr/local/bin/log-cleanup.sh

# Configuration
RETENTION_DAYS=30
LARGE_FILE_THRESHOLD="100M"
LOG_DIRS=("/var/log" "/opt/*/logs" "/home/*/logs")

# Function to clean directory
cleanup_directory() {
    local dir="$1"
    local retention="$2"
    
    if [ ! -d "$dir" ]; then
        return
    fi
    
    echo "Cleaning directory: $dir"
    
    # Remove old compressed logs
    find "$dir" -name "*.gz" -mtime +$retention -delete
    find "$dir" -name "*.bz2" -mtime +$retention -delete
    
    # Remove old numbered logs
    find "$dir" -name "*.log.[0-9]*" -mtime +$retention -delete
    
    # Truncate large current logs
    find "$dir" -name "*.log" -size +$LARGE_FILE_THRESHOLD -exec sh -c '
        echo "Truncating large file: $1 ($(du -h "$1" | cut -f1))"
        tail -n 1000 "$1" > "$1.tmp" && mv "$1.tmp" "$1"
    ' _ {} \;
    
    # Clean empty directories
    find "$dir" -type d -empty -delete 2>/dev/null
}

# Application-specific cleanup
cleanup_application_logs() {
    # Apache/Nginx access logs older than 7 days
    find /var/log/{apache2,nginx} -name "access.log.*" -mtime +7 -delete 2>/dev/null
    
    # System logs older than retention period
    journalctl --vacuum-time=${RETENTION_DAYS}d
    
    # Docker logs cleanup
    if command -v docker &> /dev/null; then
        docker system prune -f --filter "until=24h"
    fi
    
    # Application-specific cleanup
    find /var/log/mysql -name "mysql-bin.[0-9]*" -mtime +7 -delete 2>/dev/null
    find /var/log/postgresql -name "postgresql-*.log" -mtime +14 -delete 2>/dev/null
}

# Main execution
main() {
    echo "Starting log cleanup at $(date)"
    
    # Clean configured directories
    for pattern in "${LOG_DIRS[@]}"; do
        for dir in $pattern; do
            cleanup_directory "$dir" "$RETENTION_DAYS"
        done
    done
    
    # Application-specific cleanup
    cleanup_application_logs
    
    # Report disk usage after cleanup
    echo "Disk usage after cleanup:"
    df -h | grep -E '(Filesystem|/dev/)'
    
    echo "Log cleanup completed at $(date)"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

#### Cron Scheduling

**Example:** Comprehensive cron schedule in `/etc/crontab`:

```bash
# Log management cron jobs
0  2  * * *   root    /usr/local/bin/log-cleanup.sh >> /var/log/log-cleanup.log 2>&1
15 */6 * * *  root    /usr/local/bin/check-disk-space.sh
0  3  * * 0   root    /usr/local/bin/archive-logs.sh
30 1  1 * *   root    /usr/local/bin/monthly-log-archive.sh
```

#### Service-Specific Cleanup

**Example:** Systemd service for log cleanup:

```ini
# /etc/systemd/system/log-cleanup.service
[Unit]
Description=Log Cleanup Service
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/log-cleanup.sh
User=root
StandardOutput=journal
StandardError=journal
```

```ini
# /etc/systemd/system/log-cleanup.timer
[Unit]
Description=Run log cleanup daily
Requires=log-cleanup.service

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=1800

[Install]
WantedBy=timers.target
```

#### Monitoring and Alerting

**Example:** Integration with monitoring systems:

```bash
#!/bin/bash
# Send metrics to monitoring system

HOSTNAME=$(hostname)
TIMESTAMP=$(date +%s)

# Collect disk usage metrics
df -h | grep -E '^/dev/' | while read filesystem size used available percent mountpoint; do
    usage=$(echo $percent | sed 's/%//')
    
    # Send to monitoring system (example: InfluxDB)
    curl -XPOST "http://monitoring:8086/write?db=system" \
        --data-binary "disk_usage,host=$HOSTNAME,mount=$mountpoint value=$usage $TIMESTAMP"
done

# Collect log file counts
LOG_COUNT=$(find /var/log -name "*.log" | wc -l)
COMPRESSED_COUNT=$(find /var/log -name "*.gz" | wc -l)

curl -XPOST "http://monitoring:8086/write?db=system" \
    --data-binary "log_files,host=$HOSTNAME,type=active value=$LOG_COUNT $TIMESTAMP"
curl -XPOST "http://monitoring:8086/write?db=system" \
    --data-binary "log_files,host=$HOSTNAME,type=compressed value=$COMPRESSED_COUNT $TIMESTAMP"
```

**Best practices:**

- Implement multiple cleanup thresholds (warning, critical, emergency)
- Test cleanup scripts in non-production environments
- Maintain cleanup logs for audit purposes
- Coordinate cleanup with backup schedules
- Monitor cleanup effectiveness through metrics
- Document retention policies for compliance requirements

**Conclusion:** Effective log management requires coordinated rotation, archiving, and cleanup strategies. Automated systems prevent disk space issues while maintaining data accessibility and compliance requirements. Regular monitoring and alerting ensure proactive management of log storage resources.

---

