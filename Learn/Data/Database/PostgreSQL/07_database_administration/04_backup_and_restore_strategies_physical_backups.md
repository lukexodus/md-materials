## Backup and Restore Strategies: Physical Backups


### Introduction to PostgreSQL Physical Backups

Physical backups in PostgreSQL involve copying the actual database files and transaction logs rather than extracting data through SQL commands. These backups capture the binary state of the database cluster, enabling efficient full system recovery with minimal data loss.

**Key Points**:

- Physical backups copy database files at the filesystem level
- They provide faster backup and recovery for large databases
- Point-in-time recovery is possible with WAL archiving
- Physical backups require similar PostgreSQL versions for restore

### Understanding PostgreSQL File Structure

Before implementing physical backups, understanding the PostgreSQL file structure is essential:

```
$PGDATA/
├── base/               # Database files
├── global/             # Cluster-wide tables
├── pg_wal/             # Write-Ahead Log files
├── pg_xact/            # Transaction commit status
├── postgresql.conf     # Configuration file
├── pg_hba.conf         # Authentication configuration
└── ...                 # Other configuration and system files
```

To locate your data directory:

```sql
SHOW data_directory;
```

### Using pg_basebackup

`pg_basebackup` is PostgreSQL's native utility for creating consistent physical backups of a running PostgreSQL cluster.

#### Basic pg_basebackup Usage

```bash
# Simple backup to a directory
pg_basebackup -h localhost -U postgres -D /backup/base -Ft -z -P

# Parameters explained:
# -h: hostname
# -U: username
# -D: destination directory
# -Ft: format tar
# -z: compress
# -P: show progress
```

#### Creating Backup in Custom Format

```bash
# Create a backup in custom format with compression
pg_basebackup -h localhost -U postgres -D /backup/custom -Ft -z -P -X stream
```

#### Streaming WAL During Backup

```bash
# Stream WAL during backup (reduces risk of data loss)
pg_basebackup -h localhost -U postgres -D /backup/base -Ft -z -P -X stream
```

#### Configuring Server for pg_basebackup

For pg_basebackup to work, proper permissions and configurations are required:

```sql
-- Create a dedicated backup user
CREATE ROLE backup_user WITH REPLICATION LOGIN PASSWORD 'secure_password';

-- In pg_hba.conf, add:
host    replication     backup_user     10.0.0.0/24            scram-sha-256

-- In postgresql.conf:
max_wal_senders = 10    # Ensure adequate WAL senders
wal_level = replica     # Minimum level for backup
```

### WAL Archiving for Point-in-Time Recovery

WAL (Write-Ahead Log) archiving enables continuous backup of transaction logs, supporting point-in-time recovery (PITR) capabilities.

#### Configuring WAL Archiving

In postgresql.conf:

```
wal_level = replica  # Minimum for WAL archiving
archive_mode = on    # Enable WAL archiving
archive_command = 'cp %p /archive/%f'  # Command to archive WAL segments
```

A more robust archive command:

```
archive_command = 'test ! -f /archive/%f && cp %p /archive/%f && chmod 600 /archive/%f'
```

#### Creating Archiving Scripts

For enhanced archiving with verification and compression:

```bash
#!/bin/bash
# archive_wal.sh
set -e

# Variables
WAL_FILE=$1
ARCHIVE_DIR="/path/to/archive"
ARCHIVE_FILE="${ARCHIVE_DIR}/$2"

# Ensure archive directory exists
mkdir -p "${ARCHIVE_DIR}"

# Copy file with validation
cp "${WAL_FILE}" "${ARCHIVE_FILE}.tmp"

# Verify file integrity
if [ "$(md5sum "${WAL_FILE}" | cut -d' ' -f1)" = "$(md5sum "${ARCHIVE_FILE}.tmp" | cut -d' ' -f1)" ]; then
    # Atomically rename to final name
    mv "${ARCHIVE_FILE}.tmp" "${ARCHIVE_FILE}"
    chmod 600 "${ARCHIVE_FILE}"
    
    # Optional: compress file
    gzip "${ARCHIVE_FILE}" &
    
    exit 0
else
    echo "ERROR: Corrupt WAL segment detected during archiving" >&2
    exit 1
fi
```

Then in postgresql.conf:

```
archive_command = '/path/to/archive_wal.sh %p %f'
```

### Managing WAL Retention

Implementing policies to manage archived WAL files is crucial:

```bash
#!/bin/bash
# manage_wal_retention.sh
# Keep 7 days of WAL files

ARCHIVE_DIR="/path/to/archive"
RETENTION_DAYS=7

# Remove WAL files older than retention period
find "${ARCHIVE_DIR}" -name "*.gz" -type f -mtime +${RETENTION_DAYS} -delete

# Optional: Keep at least one file for each day in the last month
# using naming convention to identify dates
```

### Continuous Archiving Backup Strategy

A comprehensive strategy combining base backup with continuous WAL archiving:

```bash
#!/bin/bash
# continuous_backup.sh

# Variables
BACKUP_DIR="/path/to/backups"
BACKUP_NAME="pg_backup_$(date +%Y%m%d_%H%M%S)"
RETENTION_DAYS=7

# Create base backup
pg_basebackup -h localhost -U backup_user -D "${BACKUP_DIR}/${BACKUP_NAME}" -Ft -z -P -X stream

# Create recovery.conf template for this backup
cat > "${BACKUP_DIR}/${BACKUP_NAME}/recovery.conf.template" << EOF
restore_command = 'cp /path/to/archive/%f %p'
recovery_target_timeline = 'latest'
EOF

# Remove old backups
find "${BACKUP_DIR}" -maxdepth 1 -name "pg_backup_*" -type d -mtime +${RETENTION_DAYS} -exec rm -rf {} \;

# Log backup completion
echo "Backup completed: ${BACKUP_NAME}" >> "${BACKUP_DIR}/backup.log"
```

### Point-in-Time Recovery (PITR)

PITR allows restoring the database to any point in time since the base backup was taken.

#### Recovery Configuration (PostgreSQL 12 and earlier)

Create a recovery.conf file in the restored data directory:

```
restore_command = 'cp /path/to/archive/%f %p'
recovery_target_time = '2023-03-15 08:30:00 UTC'
recovery_target_inclusive = true
```

#### Recovery Configuration (PostgreSQL 13+)

In PostgreSQL 13 and later, recovery configuration is in postgresql.conf with a standby.signal file:

```
# Create standby.signal in data directory
touch /path/to/data/standby.signal

# In postgresql.conf
restore_command = 'cp /path/to/archive/%f %p'
recovery_target_time = '2023-03-15 08:30:00 UTC'
recovery_target_inclusive = true
```

#### Performing PITR Recovery

```bash
#!/bin/bash
# pitr_restore.sh

# Variables
BACKUP_DIR="/path/to/backups/pg_backup_20230314_120000"
ARCHIVE_DIR="/path/to/archive"
RESTORE_DIR="/path/to/restore"
RECOVERY_TIME="2023-03-15 08:30:00 UTC"

# Ensure PostgreSQL is stopped
systemctl stop postgresql

# Clear restore directory
rm -rf "${RESTORE_DIR}"/*

# Extract base backup
tar -xzf "${BACKUP_DIR}/base.tar.gz" -C "${RESTORE_DIR}"

# For PostgreSQL 12 and earlier
cat > "${RESTORE_DIR}/recovery.conf" << EOF
restore_command = 'cp ${ARCHIVE_DIR}/%f %p'
recovery_target_time = '${RECOVERY_TIME}'
recovery_target_inclusive = true
recovery_target_timeline = 'latest'
EOF

# For PostgreSQL 13+
touch "${RESTORE_DIR}/standby.signal"
cat > "${RESTORE_DIR}/postgresql.auto.conf" << EOF
restore_command = 'cp ${ARCHIVE_DIR}/%f %p'
recovery_target_time = '${RECOVERY_TIME}'
recovery_target_inclusive = true
recovery_target_timeline = 'latest'
EOF

# Set proper permissions
chown -R postgres:postgres "${RESTORE_DIR}"
chmod 700 "${RESTORE_DIR}"

# Start PostgreSQL
systemctl start postgresql

# Monitor recovery progress
tail -f /var/log/postgresql/postgresql-13-main.log
```

### Backup Validation and Testing

Regular validation of backups is essential for ensuring reliable disaster recovery.

#### Testing Physical Backup Integrity

```bash
#!/bin/bash
# test_backup.sh

# Variables
BACKUP_DIR="/path/to/backups/pg_backup_20230314_120000"
TEST_DIR="/path/to/test_restore"

# Extract backup to test directory
mkdir -p "${TEST_DIR}"
tar -xzf "${BACKUP_DIR}/base.tar.gz" -C "${TEST_DIR}"

# Configure for recovery check
touch "${TEST_DIR}/recovery.signal"
cat > "${TEST_DIR}/postgresql.auto.conf" << EOF
restore_command = 'echo skipping %f'
recovery_target = 'immediate'
EOF

# Run PostgreSQL with check option
pg_ctl -D "${TEST_DIR}" start -o "-c config_file=${TEST_DIR}/postgresql.conf"

# Wait for startup
sleep 10

# Check for successful start
if pg_isready -h localhost -p 5433; then
    echo "Backup validation successful"
    pg_ctl -D "${TEST_DIR}" stop
else
    echo "Backup validation FAILED"
    pg_ctl -D "${TEST_DIR}" stop -m immediate
    exit 1
fi
```

### Automating Backup Verification

Regular automated verification can be scheduled:

```bash
# Add to Cron
0 3 * * * /path/to/scripts/test_backup.sh >> /var/log/postgres/backup_validation.log 2>&1
```

### Replication-Based Backup Strategies

Using standby servers for backup can reduce load on the primary server.

#### Setting Up a Standby for Backup

Configure a standby server with streaming replication:

```
# In postgresql.conf on primary
wal_level = replica
max_wal_senders = 10

# In pg_hba.conf on primary
host    replication     repl_user       10.0.0.0/24            scram-sha-256

# On standby, create postgresql.conf with:
primary_conninfo = 'host=primary_host port=5432 user=repl_user password=secure_password'
```

Create pg_basebackup from the standby instead of primary:

```bash
pg_basebackup -h standby_host -U backup_user -D /backup/base -Ft -z -P
```

### Cloud-Optimized Backup Strategies

For cloud deployments, physical backups can be optimized for cloud storage.

#### AWS S3 Backup Strategy

```bash
#!/bin/bash
# s3_backup.sh

# Variables
BACKUP_NAME="pg_backup_$(date +%Y%m%d_%H%M%S)"
TEMP_DIR="/tmp/${BACKUP_NAME}"
S3_BUCKET="my-pg-backups"
S3_PREFIX="daily-backups"

# Create base backup
mkdir -p "${TEMP_DIR}"
pg_basebackup -h localhost -U backup_user -D "${TEMP_DIR}" -Ft -z -P -X stream

# Upload to S3
aws s3 cp "${TEMP_DIR}" "s3://${S3_BUCKET}/${S3_PREFIX}/${BACKUP_NAME}" --recursive

# Configure lifecycle policy to manage retention (through AWS console or CLI)

# Clean up temp files
rm -rf "${TEMP_DIR}"
```

#### WAL Archiving to S3

```
# In postgresql.conf
archive_command = 'aws s3 cp %p s3://my-pg-backups/wal-archive/%f && touch /var/lib/postgresql/archive_success/%f'
```

### High-Performance Backup Strategies

For minimal impact on production systems:

#### Parallel Compression and Transfer

```bash
# Using pigz for parallel compression
pg_basebackup -h localhost -U backup_user -D - -Ft -X stream | pigz -c > /backup/base.tar.gz

# Using GNU Parallel for multiple files
pg_basebackup -h localhost -U backup_user -D /backup/raw -Fp -X stream
find /backup/raw -type f | parallel gzip {}
```

#### Throttling Backup I/O

```bash
# Using ionice to reduce I/O priority
ionice -c2 -n7 pg_basebackup -h localhost -U backup_user -D /backup/base -Ft -z -P -X stream

# With bandwidth limiting using pv
pg_basebackup -h localhost -U backup_user -D - -Ft -X stream | pv -L 10M > /backup/base.tar
```

### Monitoring Backup Operations

Implementing monitoring ensures the backup process functions correctly:

```bash
#!/bin/bash
# monitor_backups.sh

# Check age of latest backup
LATEST_BACKUP=$(find /path/to/backups -maxdepth 1 -name "pg_backup_*" -type d | sort -r | head -n1)
BACKUP_AGE=$(($(date +%s) - $(date -r "${LATEST_BACKUP}" +%s)))

# Check WAL archiving status
ARCHIVE_STATUS=$(psql -t -c "SELECT pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() AS synced;")

# Alert if backup is too old (> 24h)
if [ $BACKUP_AGE -gt 86400 ]; then
    echo "ALERT: Latest backup is $(($BACKUP_AGE / 3600)) hours old"
    # Send notification
fi

# Alert if WAL archiving is falling behind
if ! echo "$ARCHIVE_STATUS" | grep -q "t"; then
    echo "ALERT: WAL archiving is not synchronized"
    # Send notification
fi
```

**Conclusion**

Physical backups with pg_basebackup and WAL archiving provide a robust strategy for PostgreSQL data protection. By implementing continuous archiving with regular base backups, organizations can achieve minimal data loss in disaster scenarios while maintaining the ability to perform point-in-time recovery. Regular testing and validation of backups, along with appropriate monitoring, ensure that recovery will be possible when needed.

### Recommended Related Topics

- Logical Backup Strategies with pg_dump
- Hybrid Backup Approaches (Physical and Logical)
- Disaster Recovery Planning for PostgreSQL
- High Availability Configurations with Streaming Replication

---

