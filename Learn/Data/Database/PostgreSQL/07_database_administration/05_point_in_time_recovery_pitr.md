## Point-in-Time Recovery (PITR)


### Understanding PostgreSQL Point-in-Time Recovery

Point-in-Time Recovery (PITR) is an advanced PostgreSQL recovery technique that allows database administrators to restore a database to a specific moment in time. This capability is crucial for recovering from logical errors such as accidental data deletion, corrupted transactions, or application errors without losing all changes made since the last full backup.

**Key Points**:

- PITR relies on Write-Ahead Log (WAL) archiving and base backups
- Recovery can target a specific timestamp, transaction ID, or recovery point
- Properly configured PITR can minimize data loss to seconds or less
- PITR requires planning and configuration before disaster strikes

### Prerequisites for PITR

#### WAL Archiving Configuration

To enable PITR, WAL archiving must be properly configured in postgresql.conf:

```
# In postgresql.conf
wal_level = replica                   # Minimum for WAL archiving
archive_mode = on                     # Enable WAL archiving
archive_command = 'cp %p /path/to/archive/%f'   # Command to archive WAL segments
archive_timeout = 300                 # Force WAL segment switch every 5 minutes
```

The archive_command can be customized for your environment:

```
# With verification
archive_command = 'test ! -f /path/to/archive/%f && cp %p /path/to/archive/%f && chmod 600 /path/to/archive/%f'

# With compression
archive_command = 'test ! -f /path/to/archive/%f.gz && cp %p - | gzip > /path/to/archive/%f.gz'

# To cloud storage (AWS S3)
archive_command = 'aws s3 cp %p s3://bucket-name/archive/%f'
```

#### Creating Base Backups

PITR requires a base backup as a starting point:

```bash
# Create a base backup
pg_basebackup -h localhost -D /path/to/backup -Ft -z -P -X stream
```

### Recovery Timeline Concepts

PostgreSQL organizes recovery history as a series of timelines:

- **Timeline**: A sequence of WAL records representing the database history
- **Timeline branching**: Occurs when recovery creates a new history diverging from the original

```
Timeline 1: [ Base Backup ] --- [ WAL ] --- [ WAL ] --- [ WAL ] --- X (Disaster)
                                                         |
Timeline 2:                                              +--- [ New WAL ] --- [ New WAL ]
```

### PITR Recovery Targets

PostgreSQL offers several ways to specify the recovery target:

#### Recovery to a Specific Time

```
# PostgreSQL 12 and earlier (in recovery.conf)
recovery_target_time = '2023-05-15 14:30:00 UTC'

# PostgreSQL 13+ (in postgresql.conf or postgresql.auto.conf)
recovery_target_time = '2023-05-15 14:30:00 UTC'
```

#### Recovery to a Transaction ID

```
# Recover up to and including transaction 1234567
recovery_target_xid = '1234567'
recovery_target_inclusive = true
```

#### Recovery to a Named Restore Point

First, create a restore point during normal operation:

```sql
-- Create a named restore point
SELECT pg_create_restore_point('before_major_update');
```

Then, recover to this point:

```
recovery_target_name = 'before_major_update'
```

#### Recovery to LSN (Log Sequence Number)

```
# Recover up to the specified LSN
recovery_target_lsn = '16/B374D848'
```

### Performing PITR Step by Step

#### 1. Prepare Recovery Environment

```bash
#!/bin/bash
# pitr_recovery.sh

# Variables
BACKUP_PATH="/path/to/latest_backup"
ARCHIVE_PATH="/path/to/archive"
DATA_DIR="/var/lib/postgresql/data"
RECOVERY_TARGET="2023-05-15 14:30:00 UTC"  # Or other target type

# Stop PostgreSQL
systemctl stop postgresql

# Clear data directory
rm -rf $DATA_DIR/*

# Extract backup
tar -xzf $BACKUP_PATH/base.tar.gz -C $DATA_DIR
```

#### 2. Configure Recovery (PostgreSQL 12 and earlier)

```bash
# Create recovery.conf in data directory
cat > $DATA_DIR/recovery.conf << EOF
restore_command = 'cp $ARCHIVE_PATH/%f %p'
recovery_target_time = '$RECOVERY_TARGET'
recovery_target_inclusive = true
recovery_target_timeline = 'latest'
EOF
```

#### 3. Configure Recovery (PostgreSQL 13+)

```bash
# Create standby.signal to enter recovery mode
touch $DATA_DIR/standby.signal

# Create recovery configuration in postgresql.auto.conf
cat > $DATA_DIR/postgresql.auto.conf << EOF
restore_command = 'cp $ARCHIVE_PATH/%f %p'
recovery_target_time = '$RECOVERY_TARGET'
recovery_target_inclusive = true
recovery_target_timeline = 'latest'
EOF
```

#### 4. Set Proper Permissions

```bash
# Set ownership
chown -R postgres:postgres $DATA_DIR
chmod 700 $DATA_DIR
```

#### 5. Start PostgreSQL in Recovery Mode

```bash
# Start PostgreSQL
systemctl start postgresql

# Monitor recovery progress
tail -f /var/log/postgresql/postgresql.log
```

#### 6. Promote Server After Recovery (optional)

If recovery is configured with `pause_at_recovery_target = true` (default), PostgreSQL will pause after reaching the target:

```sql
-- After reviewing recovered state, promote to normal operation
SELECT pg_wal_replay_resume();
```

For PostgreSQL 13+, you can automatically promote after recovery by setting:

```
recovery_target_action = 'promote'  # Options: 'pause', 'promote', 'shutdown'
```

### Advanced PITR Techniques

#### Delayed Recovery for Error Detection

Configure a standby server with intentional delay to provide a window for error detection:

```
# In postgresql.conf on standby
recovery_min_apply_delay = '4h'  # 4-hour delay in WAL application
```

#### Continuous Recovery Setup

A server in continuous recovery mode can be quickly promoted to replace a failed primary:

```bash
# Setup a server in continuous recovery
touch $DATA_DIR/standby.signal

cat > $DATA_DIR/postgresql.conf << EOF
primary_conninfo = 'host=primary_server port=5432 user=replication password=secure_password'
restore_command = 'cp $ARCHIVE_PATH/%f %p'
EOF
```

#### Using Multiple Restore Points

Creating strategic restore points allows precise recovery:

```sql
-- Before system upgrade
SELECT pg_create_restore_point('before_system_upgrade');

-- After schema changes
SELECT pg_create_restore_point('after_schema_migration');

-- Before batch processing
SELECT pg_create_restore_point('before_end_of_month_processing');
```

### Implementing Recovery Time Objective (RTO) Strategy

To meet specific RTO requirements:

#### Preparing Recovery Scripts

```bash
#!/bin/bash
# quick_pitr.sh - Optimized for fast recovery

# Variables
BACKUP_DIR="/path/to/backups"
ARCHIVE_DIR="/path/to/archive"
DATA_DIR="/var/lib/postgresql/data"
TARGET_TIME="$1"  # Passed as argument

# Use fastest available disk for recovery
TEMP_RECOVERY_DIR="/fast_disk/recovery"

# 1. Stop PostgreSQL
echo "Stopping PostgreSQL..."
systemctl stop postgresql

# 2. Prepare recovery directory
echo "Preparing recovery environment..."
mkdir -p $TEMP_RECOVERY_DIR
rm -rf $TEMP_RECOVERY_DIR/*

# 3. Find most recent backup before target time
BACKUP_TO_USE=$(find $BACKUP_DIR -name "backup_*" -type d | sort | grep -B1 "backup_$(date -d "$TARGET_TIME" +%Y%m%d)" | head -1)
echo "Using backup: $BACKUP_TO_USE"

# 4. Extract backup with parallel decompression
echo "Extracting backup..."
tar -I "pigz -d" -xf $BACKUP_TO_USE/base.tar.gz -C $TEMP_RECOVERY_DIR

# 5. Setup recovery configuration
echo "Configuring recovery..."
touch $TEMP_RECOVERY_DIR/standby.signal
cat > $TEMP_RECOVERY_DIR/postgresql.auto.conf << EOF
restore_command = 'cp $ARCHIVE_DIR/%f %p'
recovery_target_time = '$TARGET_TIME'
recovery_target_inclusive = true
recovery_target_timeline = 'latest'
recovery_target_action = 'promote'
EOF

# 6. Switch to recovery directory
echo "Switching data directory..."
mv $DATA_DIR ${DATA_DIR}_old
ln -s $TEMP_RECOVERY_DIR $DATA_DIR

# 7. Set permissions
chown -R postgres:postgres $DATA_DIR $TEMP_RECOVERY_DIR

# 8. Start PostgreSQL
echo "Starting PostgreSQL in recovery mode..."
systemctl start postgresql

# 9. Monitor recovery
echo "Monitoring recovery progress..."
tail -f /var/log/postgresql/postgresql-13-main.log
```

### Testing PITR Capability

Regular testing ensures your PITR strategy will work when needed:

```bash
#!/bin/bash
# test_pitr.sh

# Variables
TEST_DIR="/path/to/test_recovery"
TEST_PORT=5433
BACKUP_PATH="/path/to/latest_backup"
ARCHIVE_PATH="/path/to/archive"
TEST_TIME="2023-05-15 14:30:00 UTC"

# Create test directory
mkdir -p $TEST_DIR
rm -rf $TEST_DIR/*

# Extract backup
tar -xzf $BACKUP_PATH/base.tar.gz -C $TEST_DIR

# Configure recovery
touch $TEST_DIR/standby.signal
cat > $TEST_DIR/postgresql.auto.conf << EOF
port = $TEST_PORT
restore_command = 'cp $ARCHIVE_PATH/%f %p'
recovery_target_time = '$TEST_TIME'
recovery_target_inclusive = true
EOF

# Start PostgreSQL instance
pg_ctl -D $TEST_DIR start

# Verify recovery success
if psql -p $TEST_PORT -c "SELECT pg_is_in_recovery();" | grep -q "f"; then
    echo "PITR test successful - recovery completed"
    
    # Run validation queries
    psql -p $TEST_PORT -c "SELECT count(*) FROM important_table;"
else
    echo "PITR test failed or still in progress"
fi

# Clean up
pg_ctl -D $TEST_DIR stop -m immediate
```

### Validating Recovered Data

After PITR, verify data integrity:

```sql
-- Check for expected data
SELECT COUNT(*) FROM critical_table WHERE event_date < '2023-05-15 14:30:00';

-- Verify relationships
SELECT COUNT(*) FROM orders o LEFT JOIN order_items i ON o.id = i.order_id WHERE i.order_id IS NULL;

-- Run application validation queries
SELECT validate_inventory_consistency();

-- Check database integrity
SELECT amname, pg_am_size(oid) FROM pg_am;
```

### Managing WAL Storage for PITR

Efficient WAL management is crucial for long-term PITR capability:

#### Tiered WAL Storage Strategy

```bash
#!/bin/bash
# manage_wal_archives.sh

# Variables
ARCHIVE_DIR="/path/to/archive"
COLDSTORE_DIR="/path/to/cold_archive"
DAYS_HOT=7

# Move older WAL files to cold storage
find $ARCHIVE_DIR -name "*.gz" -type f -mtime +$DAYS_HOT -exec mv {} $COLDSTORE_DIR/ \;

# Compress any uncompressed WAL files
find $ARCHIVE_DIR -name "0*" -type f -not -name "*.gz" -exec gzip {} \;

# Verify archive continuity
previous=""
for wal in $(ls $ARCHIVE_DIR/0* $COLDSTORE_DIR/0* | sort); do
    filename=$(basename $wal | sed 's/.gz$//')
    if [ -n "$previous" ]; then
        # Check for gaps in sequence
        # Complex logic to detect missing WAL segments
    fi
    previous=$filename
done
```

#### WAL Retention Policy Implementation

```bash
#!/bin/bash
# wal_retention.sh

# Variables
ARCHIVE_DIR="/path/to/archive"
RETENTION_DAYS=30
MIN_REQUIRED_SEGMENTS=1000  # Minimum segments to keep regardless of age

# Count total segments
TOTAL_SEGMENTS=$(find $ARCHIVE_DIR -name "*.gz" | wc -l)

# Only delete if we have enough segments
if [ $TOTAL_SEGMENTS -gt $MIN_REQUIRED_SEGMENTS ]; then
    # Delete old segments, ensuring minimum count is maintained
    find $ARCHIVE_DIR -name "*.gz" -type f -mtime +$RETENTION_DAYS |
    sort |
    head -n $(($TOTAL_SEGMENTS - $MIN_REQUIRED_SEGMENTS)) |
    xargs -r rm
fi
```

### Monitoring PITR Readiness

Continuously verify PITR capabilities with monitoring:

```bash
#!/bin/bash
# monitor_pitr_readiness.sh

# Check WAL archiving status
if ! psql -t -c "SELECT pg_walfile_name(pg_current_wal_lsn());" | xargs -I{} test -f "/path/to/archive/{}.gz"; then
    echo "ALERT: Latest WAL segment not properly archived"
    # Send notification
fi

# Check archive directory permissions
if [ "$(stat -c '%a' /path/to/archive)" != "700" ]; then
    echo "ALERT: Archive directory has incorrect permissions"
fi

# Check backup recency
LATEST_BACKUP=$(find /path/to/backups -name "backup_*" -type d | sort -r | head -1)
BACKUP_AGE=$(($(date +%s) - $(stat -c %Y "$LATEST_BACKUP")))
if [ $BACKUP_AGE -gt 86400 ]; then  # Older than 1 day
    echo "ALERT: Latest backup is $(($BACKUP_AGE / 3600)) hours old"
fi

# Check WAL continuity (simplified)
LIST_FILE=$(mktemp)
find /path/to/archive -name "*.gz" | sort > $LIST_FILE
GAPS=$(python3 /path/to/scripts/check_wal_continuity.py $LIST_FILE)
if [ -n "$GAPS" ]; then
    echo "ALERT: WAL continuity broken: $GAPS"
fi
```

### Cloud-Based PITR Strategies

#### AWS RDS for PostgreSQL PITR

```bash
# Restore to point in time using AWS CLI
aws rds restore-db-instance-to-point-in-time \
    --source-db-instance-identifier my-source-instance \
    --target-db-instance-identifier my-restored-instance \
    --restore-time 2023-05-15T14:30:00Z \
    --db-instance-class db.m5.large
```

#### Azure Database for PostgreSQL PITR

```bash
# Restore using Azure CLI
az postgres server restore \
    --resource-group myResourceGroup \
    --name my-restored-server \
    --source-server my-source-server \
    --restore-point-in-time "2023-05-15T14:30:00Z"
```

#### Self-Managed Cloud PITR

```bash
#!/bin/bash
# s3_restore.sh

# Variables
S3_BUCKET="my-pg-backups"
S3_BACKUP_PATH="daily-backups/pg_backup_20230514_000000"
S3_WAL_PATH="wal-archive"
LOCAL_RESTORE_DIR="/var/lib/postgresql/data"
RECOVERY_TIME="2023-05-15 14:30:00 UTC"

# Download latest backup before target time
aws s3 sync s3://$S3_BUCKET/$S3_BACKUP_PATH $LOCAL_RESTORE_DIR

# Create recovery configuration
touch $LOCAL_RESTORE_DIR/standby.signal
cat > $LOCAL_RESTORE_DIR/postgresql.auto.conf << EOF
restore_command = 'aws s3 cp s3://$S3_BUCKET/$S3_WAL_PATH/%f %p || exit 0'
recovery_target_time = '$RECOVERY_TIME'
recovery_target_inclusive = true
recovery_target_action = 'promote'
EOF
```

**Conclusion**

Point-in-Time Recovery is a powerful PostgreSQL feature that provides precise control over database recovery. By properly configuring WAL archiving, maintaining regular base backups, and implementing appropriate monitoring and testing procedures, organizations can achieve robust disaster recovery capabilities with minimal data loss. PITR enables administrators to recover from logical errors, application bugs, or administrative mistakes that might otherwise result in significant data loss or extended downtime.

### Recommended Related Topics

- Continuous Archiving Best Practices
- High Availability with Streaming Replication
- Disaster Recovery Planning for PostgreSQL
- Backup Validation and Testing Strategies

---

