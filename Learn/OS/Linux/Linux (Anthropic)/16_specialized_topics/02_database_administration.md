## Database Administration


### MySQL/MariaDB Basics

MySQL and MariaDB are relational database management systems, with MariaDB serving as a community-developed fork of MySQL. Both systems share common administrative commands and configuration approaches, though MariaDB includes additional features and storage engines.

**Installation and Initial Setup:**

```bash
# MySQL installation (Ubuntu/Debian)
apt update
apt install mysql-server

# MariaDB installation
apt install mariadb-server

# Secure installation script
mysql_secure_installation
```

**Key Points:**

- MySQL uses InnoDB as the default storage engine for ACID compliance and foreign key support
- MariaDB includes additional storage engines like Aria, TokuDB, and Spider
- Both systems support multiple authentication plugins including native password and caching_sha2_password
- Configuration files typically located at /etc/mysql/ or /etc/my.cnf

**Basic Administration Commands:**

```sql
-- Connect to database
mysql -u root -p

-- Show databases and tables
SHOW DATABASES;
USE database_name;
SHOW TABLES;

-- User management
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON database_name.* TO 'username'@'localhost';
FLUSH PRIVILEGES;

-- Database operations
CREATE DATABASE app_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
DROP DATABASE database_name;
```

**Storage Engines:** InnoDB provides row-level locking, foreign key constraints, and crash recovery. MyISAM offers faster reads but lacks transaction support. [Inference] InnoDB generally performs better for applications requiring concurrent writes and data integrity.

**Configuration Management:** Primary configuration occurs through my.cnf or my.ini files. Critical parameters include:

```ini
[mysqld]
innodb_buffer_pool_size = 1G
max_connections = 200
query_cache_size = 64M
tmp_table_size = 64M
max_heap_table_size = 64M
```

**Example Database Creation:**

```sql
CREATE DATABASE ecommerce 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE ecommerce;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

**Monitoring and Logs:** MySQL/MariaDB generate several log types including error logs, slow query logs, and binary logs. Enable slow query logging to identify performance bottlenecks:

```sql
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;
SET GLOBAL log_queries_not_using_indexes = 'ON';
```

### PostgreSQL Introduction

PostgreSQL is an advanced open-source relational database system emphasizing extensibility and SQL compliance. It supports complex data types, full-text search, and advanced indexing mechanisms.

**Installation and Initial Configuration:**

```bash
# PostgreSQL installation (Ubuntu/Debian)
apt update
apt install postgresql postgresql-contrib

# Switch to postgres user
sudo -u postgres psql

# Create database and user
CREATE DATABASE appdb;
CREATE USER appuser WITH ENCRYPTED PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;
```

**Key Points:**

- PostgreSQL uses MVCC (Multi-Version Concurrency Control) for transaction isolation
- Supports advanced data types including JSON, arrays, and custom types
- Includes built-in full-text search capabilities
- Offers extensive indexing options: B-tree, Hash, GiST, SP-GiST, GIN, BRIN

**Database Architecture:** PostgreSQL operates with a multi-process architecture where each client connection spawns a separate backend process. The postmaster process manages connections and coordinates with background processes including the background writer, WAL writer, and autovacuum daemon.

**Basic Administration:**

```sql
-- Connect to specific database
\c database_name

-- List databases and tables
\l
\dt

-- User and role management
CREATE ROLE developer WITH LOGIN PASSWORD 'dev_password';
ALTER ROLE developer CREATEDB;

-- Schema management
CREATE SCHEMA application;
SET search_path TO application, public;
```

**Configuration Files:**

- **postgresql.conf**: Main configuration file containing server parameters
- **pg_hba.conf**: Host-based authentication configuration
- **pg_ident.conf**: User name mapping configuration

**Example Configuration Settings:**

```ini
# postgresql.conf
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.7
wal_buffers = 16MB
default_statistics_target = 100
```

**Advanced Features:** PostgreSQL supports table inheritance, allowing child tables to inherit columns from parent tables. Partitioning enables distributing large tables across multiple physical tables for improved performance and maintenance.

**Example Advanced Usage:**

```sql
-- Create partitioned table
CREATE TABLE sales (
    id SERIAL,
    sale_date DATE,
    amount DECIMAL(10,2)
) PARTITION BY RANGE (sale_date);

-- Create partitions
CREATE TABLE sales_2023 PARTITION OF sales
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

-- JSON operations
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    data JSONB
);

INSERT INTO products (data) VALUES 
('{"name": "Laptop", "price": 999.99, "specs": {"ram": "16GB", "storage": "512GB"}}');

SELECT data->>'name' as product_name 
FROM products 
WHERE data->'specs'->>'ram' = '16GB';
```

**Extensions and Procedural Languages:** PostgreSQL supports extensions like PostGIS for geographic data, pg_stat_statements for query statistics, and multiple procedural languages including PL/pgSQL, PL/Python, and PL/Perl.

### Database Backup/Restore

Database backup and restore procedures ensure data protection and business continuity. Different backup strategies serve various recovery scenarios and operational requirements.

**MySQL/MariaDB Backup Methods:**

**Logical Backups with mysqldump:**

```bash
# Full database backup
mysqldump -u root -p --single-transaction --routines --triggers database_name > backup.sql

# All databases backup
mysqldump -u root -p --all-databases --single-transaction > full_backup.sql

# Specific tables backup
mysqldump -u root -p database_name table1 table2 > tables_backup.sql

# Compressed backup
mysqldump -u root -p database_name | gzip > backup.sql.gz
```

**Key Points:**

- --single-transaction ensures consistent backup for InnoDB tables
- --routines includes stored procedures and functions
- --triggers preserves trigger definitions
- Binary logs enable point-in-time recovery when combined with full backups

**Physical Backups with MySQL Enterprise Backup or Percona XtraBackup:**

```bash
# Percona XtraBackup full backup
xtrabackup --backup --target-dir=/backup/full --user=backup_user --password=password

# Incremental backup
xtrabackup --backup --target-dir=/backup/inc1 --incremental-basedir=/backup/full

# Prepare backup for restore
xtrabackup --prepare --target-dir=/backup/full
```

**PostgreSQL Backup Methods:**

**Logical Backups with pg_dump:**

```bash
# Database backup
pg_dump -U postgres -h localhost -d database_name > backup.sql

# Custom format backup (compressed)
pg_dump -U postgres -F c -d database_name > backup.dump

# Directory format for parallel processing
pg_dump -U postgres -F d -j 4 -f backup_dir database_name

# All databases backup
pg_dumpall -U postgres > all_databases.sql
```

**Physical Backups with pg_basebackup:**

```bash
# Base backup for standby server
pg_basebackup -D /backup/base -U replication_user -v -P -W

# Compressed base backup
pg_basebackup -D - -F t -z | split -b 1G - backup.tar.gz.
```

**Restore Operations:**

**MySQL/MariaDB Restore:**

```bash
# Restore from logical backup
mysql -u root -p database_name < backup.sql

# Restore all databases
mysql -u root -p < full_backup.sql

# Restore compressed backup
gunzip < backup.sql.gz | mysql -u root -p database_name
```

**PostgreSQL Restore:**

```bash
# Restore from SQL dump
psql -U postgres -d database_name < backup.sql

# Restore from custom format
pg_restore -U postgres -d database_name backup.dump

# Parallel restore from directory format
pg_restore -U postgres -d database_name -j 4 backup_dir
```

**Point-in-Time Recovery:** MySQL uses binary logs for point-in-time recovery:

```bash
# Extract specific time range from binary logs
mysqlbinlog --start-datetime="2023-12-01 10:00:00" \
           --stop-datetime="2023-12-01 11:00:00" \
           mysql-bin.000001 > recovery.sql
```

PostgreSQL uses WAL (Write-Ahead Logging):

```bash
# Configure recovery in postgresql.conf
restore_command = 'cp /archive/%f %p'
recovery_target_time = '2023-12-01 10:30:00'
```

**Backup Automation and Monitoring:**

```bash
#!/bin/bash
# Automated backup script
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/mysql"
DB_NAME="production"

mysqldump -u backup_user -p$MYSQL_PASSWORD \
  --single-transaction \
  --routines \
  --triggers \
  $DB_NAME | gzip > $BACKUP_DIR/backup_${DB_NAME}_${DATE}.sql.gz

# Cleanup old backups (keep 7 days)
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete
```

### Performance Tuning

Database performance tuning involves optimizing configuration parameters, query execution, indexing strategies, and system resources to achieve optimal throughput and response times.

**MySQL/MariaDB Performance Tuning:**

**Configuration Optimization:** Critical parameters affecting performance include buffer pool size, query cache, and connection handling:

```ini
[mysqld]
# InnoDB settings
innodb_buffer_pool_size = 70%_of_RAM
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = 1

# Query cache (MySQL 5.7 and earlier)
query_cache_type = 1
query_cache_size = 128M

# Connection settings
max_connections = 200
thread_cache_size = 16
table_open_cache = 2000
```

**Key Points:**

- InnoDB buffer pool should typically be 70-80% of available RAM on dedicated database servers
- Query cache is deprecated in MySQL 8.0 and removed entirely
- [Unverified] Setting innodb_flush_log_at_trx_commit = 2 improves performance but slightly reduces durability
- Thread pool plugins can improve connection handling under high concurrency

**Query Optimization:**

```sql
-- Analyze query execution plans
EXPLAIN SELECT * FROM users WHERE email = 'user@example.com';
EXPLAIN FORMAT=JSON SELECT * FROM users u JOIN orders o ON u.id = o.user_id;

-- Index optimization
CREATE INDEX idx_email ON users(email);
CREATE INDEX idx_user_date ON orders(user_id, order_date);

-- Query optimization examples
-- Bad: SELECT * FROM large_table WHERE function(column) = value;
-- Good: SELECT * FROM large_table WHERE column = inverse_function(value);

-- Use covering indexes
CREATE INDEX idx_covering ON orders(user_id, order_date, status, total_amount);
```

**PostgreSQL Performance Tuning:**

**Configuration Parameters:**

```ini
# Memory settings
shared_buffers = 25%_of_RAM
effective_cache_size = 75%_of_RAM
work_mem = 4MB
maintenance_work_mem = 256MB

# WAL settings
wal_buffers = 16MB
checkpoint_completion_target = 0.7
max_wal_size = 1GB

# Planner settings
random_page_cost = 1.1
effective_io_concurrency = 200
```

**Query Analysis and Optimization:**

```sql
-- Enable query statistics collection
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Analyze query performance
SELECT query, calls, total_time, mean_time, rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Detailed execution plans
EXPLAIN (ANALYZE, BUFFERS) 
SELECT u.username, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username;

-- Index usage analysis
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

**Indexing Strategies:**

**B-tree Indexes:** Most common index type, suitable for equality and range queries:

```sql
-- Single column index
CREATE INDEX idx_lastname ON users(lastname);

-- Composite index (order matters)
CREATE INDEX idx_user_status_date ON orders(user_id, status, order_date);

-- Partial index
CREATE INDEX idx_active_users ON users(email) WHERE status = 'active';
```

**PostgreSQL Advanced Indexes:**

```sql
-- GIN index for full-text search
CREATE INDEX idx_content_search ON articles USING gin(to_tsvector('english', content));

-- BRIN index for large tables with natural ordering
CREATE INDEX idx_timestamp_brin ON logs USING brin(timestamp);

-- Hash index for equality comparisons
CREATE INDEX idx_user_hash ON sessions USING hash(user_id);
```

**System-Level Optimization:**

**Operating System Tuning:**

```bash
# Increase file descriptor limits
echo "mysql soft nofile 65536" >> /etc/security/limits.conf
echo "mysql hard nofile 65536" >> /etc/security/limits.conf

# Optimize I/O scheduler
echo noop > /sys/block/sda/queue/scheduler

# Configure swappiness
echo "vm.swappiness = 1" >> /etc/sysctl.conf
```

**Storage Optimization:**

- Place transaction logs on separate fast storage devices
- Use SSD storage for databases with high I/O requirements
- Configure appropriate RAID levels (RAID 10 for balanced performance and redundancy)
- [Inference] Separating data and log files typically improves performance by reducing I/O contention

**Monitoring and Profiling:**

**MySQL Performance Monitoring:**

```sql
-- Show current processes
SHOW PROCESSLIST;

-- InnoDB status information
SHOW ENGINE INNODB STATUS;

-- Query statistics
SELECT schema_name, digest_text, count_star, avg_timer_wait
FROM performance_schema.events_statements_summary_by_digest
ORDER BY avg_timer_wait DESC;
```

**PostgreSQL Monitoring:**

```sql
-- Current activity
SELECT pid, usename, application_name, state, query
FROM pg_stat_activity
WHERE state = 'active';

-- Table statistics
SELECT schemaname, tablename, n_tup_ins, n_tup_upd, n_tup_del, n_live_tup
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC;

-- Lock monitoring
SELECT mode, locktype, database, relation, page, tuple, pid
FROM pg_locks;
```

**Automated Performance Analysis:** Tools like MySQLTuner, pt-query-digest (Percona Toolkit), and pgBadger provide automated analysis and recommendations for database performance optimization.

**Output:** Database performance tuning requires continuous monitoring and iterative optimization based on workload patterns, query analysis, and system resource utilization. Regular performance audits help identify bottlenecks and optimization opportunities.

---

