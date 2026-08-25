## Backup and Restore Strategies: Logical Backups (pg_dump, pg_restore)


### Understanding Logical Backups

Logical backups in PostgreSQL generate SQL commands or archive files that can recreate database objects and data. Unlike physical backups that copy raw data files, logical backups extract database content in a format that is independent of the physical storage details.

**Key Points**:

- Logical backups are SQL statements or archive files containing database structure and data
- They're more flexible than physical backups for partial restoration and version migration
- Tools like pg_dump and pg_restore handle these operations with various customization options
- Logical backups are essential components of a comprehensive database backup strategy

### The pg_dump Utility

pg_dump is PostgreSQL's primary tool for creating logical backups of a single database.

#### Basic Usage

```bash
# Backup a database to a SQL script file
pg_dump dbname > backup.sql

# Backup using custom format (compressed, flexible)
pg_dump -Fc dbname > backup.dump

# Backup specific tables only
pg_dump -t table1 -t table2 dbname > tables_backup.sql

# Backup excluding specific tables
pg_dump -T table_to_exclude dbname > partial_backup.sql
```

#### Output Formats

```bash
# SQL plain text format (-Fp or default)
pg_dump -Fp dbname > backup.sql

# Custom format (-Fc) - compressed, flexible for pg_restore
pg_dump -Fc dbname > backup.dump

# Directory format (-Fd) - multiple files in a directory
pg_dump -Fd dbname -f backup_dir/

# TAR format (-Ft) - suitable for tape devices
pg_dump -Ft dbname > backup.tar
```

#### Connection Parameters

```bash
# Specify host, port, username
pg_dump -h hostname -p 5432 -U username dbname > backup.sql

# Use connection string
pg_dump "postgresql://username:password@hostname:5432/dbname" > backup.sql

# Use environment variables (PGHOST, PGPORT, PGUSER, PGPASSWORD)
export PGHOST=hostname
export PGPORT=5432
export PGUSER=username
export PGPASSWORD=password
pg_dump dbname > backup.sql
```

#### Backup Options

```bash
# Compress output (for plain text format)
pg_dump -Z 9 dbname > backup.sql.gz

# Create a clean backup (with DROP statements)
pg_dump --clean dbname > backup.sql

# Add CREATE DATABASE statement
pg_dump --create dbname > backup.sql

# Backup schema only (no data)
pg_dump --schema-only dbname > schema.sql

# Backup data only (no schema)
pg_dump --data-only dbname > data.sql

# Include table ownership
pg_dump --no-owner dbname > backup.sql

# Exclude privileges/grants
pg_dump --no-acl dbname > backup.sql
```

### The pg_dumpall Utility

While pg_dump handles a single database, pg_dumpall can backup an entire PostgreSQL instance, including all databases and global objects.

```bash
# Backup all databases and global objects
pg_dumpall > full_backup.sql

# Backup only global objects (roles, tablespaces)
pg_dumpall --globals-only > globals.sql

# Backup only roles
pg_dumpall --roles-only > roles.sql

# Backup only tablespaces
pg_dumpall --tablespaces-only > tablespaces.sql
```

### The pg_restore Utility

pg_restore is used to restore databases from non-plaintext formats created by pg_dump.

#### Basic Usage

```bash
# Restore a custom-format backup
pg_restore -d dbname backup.dump

# Restore a directory-format backup
pg_restore -d dbname backup_dir/

# Restore a tar-format backup
pg_restore -d dbname backup.tar
```

#### Restoration Options

```bash
# Restore only schema (no data)
pg_restore --schema-only -d dbname backup.dump

# Restore only data (assuming schema exists)
pg_restore --data-only -d dbname backup.dump

# Clean (drop) database objects before recreating
pg_restore --clean -d dbname backup.dump

# Create the database before restoring
pg_restore --create -d postgres backup.dump

# Don't restore with owner information
pg_restore --no-owner -d dbname backup.dump

# Only restore specific tables
pg_restore -t table1 -t table2 -d dbname backup.dump

# Disable triggers during data restore
pg_restore --disable-triggers -d dbname backup.dump

# Specify number of concurrent jobs (parallel restore)
pg_restore -j 4 -d dbname backup.dump
```

#### Exit Status

```bash
# 0: success
# 1: error with options, like database connection
# 2: one or more problems during restore
# 3: fatal error in restore arguments
echo $?  # Shows exit status of last command
```

### Backing Up Specific Database Objects

#### Schemas

```bash
# Backup specific schemas
pg_dump -n schema1 -n schema2 dbname > schemas_backup.sql

# Exclude specific schemas
pg_dump -N schema_to_exclude dbname > without_schema_backup.sql
```

#### Tables

```bash
# Backup specific tables
pg_dump -t schema1.table1 -t schema2.table2 dbname > tables_backup.sql

# Backup tables matching a pattern
pg_dump -t 'accounts_*' dbname > accounts_tables_backup.sql
```

#### Other Objects

```bash
# Backup only database structure
pg_dump --schema-only dbname > structure.sql

# Backup only sequences
pg_dump --section=pre-data --schema-only dbname > sequences.sql

# Backup only functions
pg_dump --section=pre-data --schema-only -n public dbname | grep -A 20 "CREATE FUNCTION" > functions.sql
```

### Automating Backups

#### Shell Script Example

```bash
#!/bin/bash
# backup_script.sh - PostgreSQL Automated Backup

# Configuration
BACKUP_DIR="/var/backups/postgres"
DB_NAME="production_db"
DB_USER="postgres"
DAYS_TO_KEEP=14
DATE=$(date +%Y-%m-%d_%H-%M)

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Create the backup
pg_dump -U $DB_USER -Fc $DB_NAME > $BACKUP_DIR/$DB_NAME-$DATE.dump

# Set proper permissions
chmod 600 $BACKUP_DIR/$DB_NAME-$DATE.dump

# Delete old backups
find $BACKUP_DIR -name "$DB_NAME-*.dump" -mtime +$DAYS_TO_KEEP -delete

# Log the backup
echo "PostgreSQL backup completed: $DB_NAME-$DATE.dump" >> $BACKUP_DIR/backup_log.txt
```

#### Cron Job Setup

```bash
# Edit crontab
crontab -e

# Add this line to run backup nightly at 2:00 AM
0 2 * * * /path/to/backup_script.sh
```

### Handling Large Databases

Large databases present special challenges for backup and restore operations.

#### Parallel Dump and Restore

```bash
# Parallel dump with jobs option (PostgreSQL 9.3+)
pg_dump -j 4 -Fd dbname -f backup_dir/

# Parallel restore
pg_restore -j 4 -d dbname backup_dir/
```

#### Splitting Backup Tasks

```bash
# Backup schema first
pg_dump --schema-only dbname > schema.sql

# Backup each large table separately
pg_dump -t large_table1 --data-only dbname > large_table1_data.sql
pg_dump -t large_table2 --data-only dbname > large_table2_data.sql

# Backup the rest of the tables
pg_dump -T large_table1 -T large_table2 --data-only dbname > rest_data.sql
```

#### Compressed Custom Format

```bash
# Use maximum compression for large databases
pg_dump -Fc -Z 9 dbname > backup.dump
```

### Handling Special Cases

#### Foreign Keys and Constraints

```bash
# Disable triggers during data restore
pg_restore --disable-triggers -d dbname backup.dump

# For plain SQL backups, add these before/after COPY statements
echo "SET session_replication_role = 'replica';" > restore.sql
cat data_dump.sql >> restore.sql
echo "SET session_replication_role = 'origin';" >> restore.sql
```

#### Selective Restore from Plain SQL

```bash
# Filter a plain SQL dump for specific tables
grep -E '(CREATE TABLE table1|COPY table1|\\.|ALTER TABLE ONLY table1)' backup.sql > table1_restore.sql

# Clean up the file to ensure SQL validity
# Manual editing may be required
```

#### Restoring to a Different Database

```bash
# Restore to a different database
pg_restore -d newdb backup.dump

# For plain SQL with database creation included
sed 's/CREATE DATABASE olddb/CREATE DATABASE newdb/' backup.sql > modified_backup.sql
```

### Routine Backup Strategy Example

#### Daily Incremental Strategy

```bash
#!/bin/bash
# Daily backup rotation script

DB_NAME="production_db"
BACKUP_DIR="/var/backups/postgres"

# Daily backup (keep 7 days)
DAY_OF_WEEK=$(date +%A)
pg_dump -Fc $DB_NAME > $BACKUP_DIR/daily_$DAY_OF_WEEK.dump

# Weekly backup (1st Sunday of the month, keep 4)
if [ $(date +%d) -le 7 ] && [ $DAY_OF_WEEK = "Sunday" ]; then
    WEEK_NUM=$(date +%U)
    WEEK_NUM=$((WEEK_NUM % 4 + 1))
    pg_dump -Fc $DB_NAME > $BACKUP_DIR/weekly_$WEEK_NUM.dump
fi

# Monthly backup (1st of the month, keep 12)
if [ $(date +%d) -eq 1 ]; then
    MONTH=$(date +%B)
    pg_dump -Fc $DB_NAME > $BACKUP_DIR/monthly_$MONTH.dump
fi

# Yearly backup (January 1st)
if [ $(date +%d) -eq 1 ] && [ $(date +%m) -eq 1 ]; then
    YEAR=$(date +%Y)
    pg_dump -Fc $DB_NAME > $BACKUP_DIR/yearly_$YEAR.dump
fi
```

### Best Practices

#### Backup Validation

```bash
# Test restore to a temporary database
createdb test_restore
pg_restore -d test_restore backup.dump

# Verify row counts
psql -c "SELECT COUNT(*) FROM important_table;" production_db
psql -c "SELECT COUNT(*) FROM important_table;" test_restore

# Drop test database when done
dropdb test_restore
```

#### Securing Backup Files

```bash
# Set proper permissions
chmod 600 backup.dump

# Encrypt the backup
pg_dump dbname | gzip | openssl enc -aes-256-cbc -salt -out backup.sql.gz.enc

# Decrypt for restoration
openssl enc -d -aes-256-cbc -in backup.sql.gz.enc | gunzip | psql dbname
```

#### Offsite Storage

```bash
# Copy to remote server
scp backup.dump user@remote-server:/path/to/backup/storage/

# Use rsync for efficient transfers
rsync -avz --progress backup.dump user@remote-server:/path/to/backup/storage/

# Cloud storage (AWS S3 example)
aws s3 cp backup.dump s3://mybucket/postgres-backups/
```

### Monitoring and Logging

#### Log Rotation

```bash
# Configure backup logging with rotation
cat > /etc/logrotate.d/postgres-backup << EOF
/var/log/postgres-backup.log {
    weekly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
    create 0640 postgres postgres
}
EOF
```

#### Email Notifications

```bash
#!/bin/bash
# Add to backup script for email alerts

# Configuration
ADMIN_EMAIL="dba@example.com"
LOG_FILE="/var/log/postgres-backup.log"

# Run backup with logging
pg_dump -Fc dbname > backup.dump 2>> $LOG_FILE

# Check status
if [ $? -eq 0 ]; then
    echo "PostgreSQL backup successful - $(date)" >> $LOG_FILE
else
    echo "PostgreSQL backup FAILED - $(date)" >> $LOG_FILE
    # Send email alert
    mail -s "ALERT: PostgreSQL Backup Failed" $ADMIN_EMAIL < $LOG_FILE
fi
```

### Common Issues and Solutions

#### Permission Problems

```bash
# Ensure backup user has proper permissions
# Create a dedicated backup role
CREATE ROLE backup_user LOGIN PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE dbname TO backup_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO backup_user;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO backup_user;

# For tables created in the future
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO backup_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO backup_user;
```

#### Network Timeout Issues

```bash
# Set statement timeout (client side)
export PGOPTIONS="-c statement_timeout=0"

# Server configuration (postgresql.conf)
statement_timeout = 0  # disable timeout
```

#### Disk Space Issues

```bash
# Check available disk space before backup
FREE_SPACE=$(df -k $BACKUP_DIR | tail -1 | awk '{print $4}')
DB_SIZE=$(psql -t -c "SELECT pg_database_size('$DB_NAME');" | awk '{print $1}')

# Convert to KB for comparison
DB_SIZE_KB=$((DB_SIZE / 1024))

# Ensure sufficient space (with 20% buffer)
if [ $FREE_SPACE -lt $((DB_SIZE_KB * 120 / 100)) ]; then
    echo "Insufficient disk space for backup" | mail -s "Backup Failed - Low Disk" $ADMIN_EMAIL
    exit 1
fi
```

### Version Migration with pg_dump/pg_restore

Logical backups facilitate database migration between PostgreSQL versions.

```bash
# Dump from old PostgreSQL
/usr/lib/postgresql/12/bin/pg_dump -Fc olddb > olddb.dump

# Restore to new PostgreSQL
/usr/lib/postgresql/14/bin/pg_restore -d newdb olddb.dump
```

### Working with pg_dump/pg_restore on Windows

```batch
@REM Windows batch file example
@echo off
set PGPASSWORD=secretpassword
set BACKUP_PATH=C:\PostgreSQL\backups
set DB_NAME=mydb
set TIMESTAMP=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%
set TIMESTAMP=%TIMESTAMP: =0%

"C:\Program Files\PostgreSQL\14\bin\pg_dump.exe" -h localhost -U postgres -Fc %DB_NAME% > "%BACKUP_PATH%\%DB_NAME%_%TIMESTAMP%.dump"

if %ERRORLEVEL% NEQ 0 (
    echo Backup failed with error level %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

echo Backup completed successfully: %DB_NAME%_%TIMESTAMP%.dump
```

### Advanced pg_dump Features

#### Data Transformation During Backup

```bash
# Using COPY format to process data on-the-fly
pg_dump --column-inserts --data-only -t mytable dbname | \
  sed 's/some_value/new_value/g' > transformed_data.sql
```

#### Creating a Template from Existing Database

```bash
# Create a schema-only backup for use as a template
pg_dump --schema-only -n public original_db > template.sql

# Create a new database and apply the template
createdb new_db
psql -d new_db -f template.sql
```

#### Filtering with WHERE Clauses

```bash
# Extract a subset of data using WHERE conditions
pg_dump --table=orders --data-only \
  --column-inserts \
  --where="order_date > '2023-01-01'" dbname > recent_orders.sql
```

### Schema Evolution and Backup Strategies

#### Handling Schema Changes

```bash
# Backup schema separately and frequently
pg_dump --schema-only mydb > schema_$(date +%Y%m%d).sql

# Diff schema changes
diff schema_20230101.sql schema_20230201.sql > schema_changes.diff

# Create schema migration scripts
cat > migration_script.sql << EOF
BEGIN;
-- Add new column
ALTER TABLE products ADD COLUMN discontinued BOOLEAN DEFAULT FALSE;

-- Create new index
CREATE INDEX idx_product_discontinued ON products(discontinued);
COMMIT;
EOF
```

### Using pg_dump with Docker Containers

```bash
# Backup from a PostgreSQL container
docker exec -t my_postgres_container \
  pg_dump -U postgres -Fc mydatabase > backup.dump

# Restore to a PostgreSQL container
cat backup.dump | docker exec -i my_postgres_container \
  pg_restore -U postgres -d mydatabase
```

### Metadata Extraction and Documentation

```bash
# Generate database documentation from schema
pg_dump --schema-only mydb > schema.sql

# Extract table list
pg_dump --schema-only mydb | grep -E "^CREATE TABLE" | \
  sed 's/CREATE TABLE \(.*\) (/\1/' | sort > tables.txt

# Extract function list
pg_dump --schema-only mydb | grep -E "^CREATE FUNCTION" | \
  sed 's/CREATE FUNCTION \(.*\)(/\1/' | sort > functions.txt
```

### Database Comparison Tools

```bash
# Using pgdiff (third-party tool)
pg_dump --schema-only db1 > db1_schema.sql
pg_dump --schema-only db2 > db2_schema.sql
pgdiff db1_schema.sql db2_schema.sql > differences.sql
```

**Conclusion**:

Logical backups using pg_dump and pg_restore are essential tools in PostgreSQL database management. They provide flexibility for partial backups and restores, facilitate version migration, and allow precise control over the backup and restore process. By implementing a comprehensive backup strategy that includes regular logical backups, validation testing, and secure offsite storage, organizations can protect their valuable data from loss and ensure business continuity. Understanding the various options and capabilities of these tools enables database administrators to craft backup solutions tailored to their specific requirements, database size, and operational constraints.

### Related Topics

- Physical backup strategies with pg_basebackup
- Point-in-time recovery using WAL archiving
- Continuous archiving and streaming replication
- Backup compression and encryption techniques
- Disaster recovery planning and testing

---

