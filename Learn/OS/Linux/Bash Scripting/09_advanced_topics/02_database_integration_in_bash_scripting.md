## Database Integration in Bash Scripting


### Connecting to Databases

#### MySQL Connection Methods

The most common approach is using the `mysql` command-line client with connection parameters. You can establish connections using various authentication methods including password prompts, configuration files, or environment variables.

```bash
## Basic connection with password prompt
mysql -h hostname -u username -p database_name

## Connection with inline password (not recommended for production)
mysql -h hostname -u username -ppassword database_name

## Using configuration file
mysql --defaults-file=/path/to/config.cnf database_name

## Using environment variables
export MYSQL_HOST="localhost"
export MYSQL_USER="username"
export MYSQL_PASSWORD="password"
mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD database_name
```

#### PostgreSQL Connection Methods

PostgreSQL uses the `psql` client with similar connection options but different syntax conventions.

```bash
## Basic connection
psql -h hostname -U username -d database_name

## Using connection string
psql "postgresql://username:password@hostname:5432/database_name"

## Using environment variables
export PGHOST="localhost"
export PGUSER="username"
export PGPASSWORD="password"
export PGDATABASE="database_name"
psql
```

#### Secure Connection Handling

For production environments, avoid hardcoding credentials. Use configuration files with restricted permissions or environment variables.

```bash
## Create MySQL configuration file
cat > ~/.my.cnf << EOF
[client]
host=localhost
user=username
password=password
database=database_name
EOF

## Set secure permissions
chmod 600 ~/.my.cnf

## PostgreSQL password file
cat > ~/.pgpass << EOF
hostname:port:database:username:password
EOF

chmod 600 ~/.pgpass
```

### SQL Query Execution from Bash

#### MySQL Query Execution

Execute SQL queries directly from bash scripts using various methods for different use cases.

```bash
#!/bin/bash

## Simple query execution
mysql -u username -p database_name -e "SELECT * FROM users WHERE active = 1;"

## Query with variable substitution
USER_ID=123
mysql -u username -p database_name -e "SELECT * FROM users WHERE id = $USER_ID;"

## Multi-line query
mysql -u username -p database_name << EOF
SELECT u.username, p.profile_name, p.created_date
FROM users u
JOIN profiles p ON u.id = p.user_id
WHERE u.active = 1
ORDER BY p.created_date DESC
LIMIT 10;
EOF

## Storing query results in variables
RESULT=$(mysql -u username -p database_name -se "SELECT COUNT(*) FROM users WHERE active = 1;")
echo "Active users: $RESULT"
```

#### PostgreSQL Query Execution

PostgreSQL offers similar capabilities with `psql` client options.

```bash
#!/bin/bash

## Simple query execution
psql -U username -d database_name -c "SELECT * FROM users WHERE active = true;"

## Query with output formatting
psql -U username -d database_name -t -c "SELECT username FROM users WHERE active = true;"

## Multi-line query with here document
psql -U username -d database_name << EOF
SELECT u.username, p.profile_name, p.created_date
FROM users u
JOIN profiles p ON u.id = p.user_id
WHERE u.active = true
ORDER BY p.created_date DESC
LIMIT 10;
EOF

## Executing SQL files
psql -U username -d database_name -f /path/to/query.sql
```

#### Dynamic Query Building

Build queries dynamically based on script parameters or conditions.

```bash
#!/bin/bash

build_user_query() {
    local status=$1
    local limit=${2:-10}
    
    local query="SELECT id, username, email, created_date FROM users"
    
    if [ "$status" != "all" ]; then
        query="$query WHERE active = $status"
    fi
    
    query="$query ORDER BY created_date DESC LIMIT $limit;"
    
    echo "$query"
}

## Usage
USER_STATUS="true"
LIMIT=25
QUERY=$(build_user_query $USER_STATUS $LIMIT)
psql -U username -d database_name -c "$QUERY"
```

#### Error Handling and Validation

Implement proper error handling for database operations.

```bash
#!/bin/bash

execute_mysql_query() {
    local query=$1
    local result
    
    if ! result=$(mysql -u username -p database_name -se "$query" 2>&1); then
        echo "Error executing query: $result" >&2
        return 1
    fi
    
    echo "$result"
    return 0
}

## Usage with error handling
if execute_mysql_query "SELECT COUNT(*) FROM users;" > /dev/null; then
    echo "Query executed successfully"
else
    echo "Query failed"
    exit 1
fi
```

### Data Backup and Migration Scripts

#### MySQL Backup Scripts

Create comprehensive backup solutions for MySQL databases with various options and scheduling capabilities.

```bash
#!/bin/bash

## Configuration
DB_HOST="localhost"
DB_USER="backup_user"
DB_NAME="production_db"
BACKUP_DIR="/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)

## Full database backup
create_full_backup() {
    local backup_file="$BACKUP_DIR/full_backup_${DB_NAME}_${DATE}.sql"
    
    echo "Creating full backup of $DB_NAME..."
    
    if mysqldump -h $DB_HOST -u $DB_USER -p \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        --hex-blob \
        $DB_NAME > "$backup_file"; then
        
        echo "Backup created: $backup_file"
        
        ## Compress backup
        gzip "$backup_file"
        echo "Backup compressed: ${backup_file}.gz"
        
        return 0
    else
        echo "Backup failed" >&2
        return 1
    fi
}

## Incremental backup using binary logs
create_incremental_backup() {
    local backup_file="$BACKUP_DIR/incremental_${DB_NAME}_${DATE}.sql"
    local last_backup_time=$(cat "$BACKUP_DIR/last_backup_time.txt" 2>/dev/null || echo "1970-01-01 00:00:00")
    
    echo "Creating incremental backup since $last_backup_time..."
    
    mysql -h $DB_HOST -u $DB_USER -p -e "
        SELECT * FROM mysql.general_log 
        WHERE event_time > '$last_backup_time'
        INTO OUTFILE '$backup_file';"
    
    echo "$(date '+%Y-%m-%d %H:%M:%S')" > "$BACKUP_DIR/last_backup_time.txt"
}

## Backup rotation
rotate_backups() {
    local retention_days=7
    
    find "$BACKUP_DIR" -name "*.sql.gz" -type f -mtime +$retention_days -delete
    echo "Old backups cleaned up (retention: $retention_days days)"
}

## Main backup function
main() {
    mkdir -p "$BACKUP_DIR"
    
    if create_full_backup; then
        rotate_backups
    else
        exit 1
    fi
}

main
```

#### PostgreSQL Backup Scripts

Implement PostgreSQL-specific backup strategies with pg_dump and pg_basebackup.

```bash
#!/bin/bash

## Configuration
PG_HOST="localhost"
PG_USER="backup_user"
PG_DB="production_db"
BACKUP_DIR="/backups/postgresql"
DATE=$(date +%Y%m%d_%H%M%S)

## Full database backup
create_pg_backup() {
    local backup_file="$BACKUP_DIR/pg_backup_${PG_DB}_${DATE}.sql"
    
    echo "Creating PostgreSQL backup of $PG_DB..."
    
    if pg_dump -h $PG_HOST -U $PG_USER \
        --verbose \
        --clean \
        --create \
        --if-exists \
        --format=custom \
        --file="$backup_file" \
        $PG_DB; then
        
        echo "Backup created: $backup_file"
        return 0
    else
        echo "Backup failed" >&2
        return 1
    fi
}

## Schema-only backup
create_schema_backup() {
    local schema_file="$BACKUP_DIR/schema_${PG_DB}_${DATE}.sql"
    
    pg_dump -h $PG_HOST -U $PG_USER \
        --schema-only \
        --file="$schema_file" \
        $PG_DB
    
    echo "Schema backup created: $schema_file"
}

## Table-specific backup
backup_table() {
    local table_name=$1
    local table_file="$BACKUP_DIR/table_${table_name}_${DATE}.sql"
    
    pg_dump -h $PG_HOST -U $PG_USER \
        --table="$table_name" \
        --data-only \
        --file="$table_file" \
        $PG_DB
    
    echo "Table backup created: $table_file"
}
```

#### Migration Scripts

Create scripts for database migration between environments.

```bash
#!/bin/bash

## Database migration script
migrate_database() {
    local source_db=$1
    local target_db=$2
    local migration_dir="/tmp/migration_$$"
    
    echo "Starting migration from $source_db to $target_db..."
    
    ## Create temporary directory
    mkdir -p "$migration_dir"
    
    ## Export source database
    echo "Exporting source database..."
    mysqldump -u source_user -p \
        --single-transaction \
        --routines \
        --triggers \
        $source_db > "$migration_dir/source_export.sql"
    
    ## Create target database if it doesn't exist
    mysql -u target_user -p -e "CREATE DATABASE IF NOT EXISTS $target_db;"
    
    ## Import to target database
    echo "Importing to target database..."
    mysql -u target_user -p $target_db < "$migration_dir/source_export.sql"
    
    ## Cleanup
    rm -rf "$migration_dir"
    
    echo "Migration completed successfully"
}

## Data synchronization between databases
sync_tables() {
    local source_table=$1
    local target_table=$2
    
    ## Export specific table data
    mysqldump -u source_user -p \
        --no-create-info \
        --replace \
        source_db $source_table > "/tmp/${source_table}_data.sql"
    
    ## Import to target
    mysql -u target_user -p target_db < "/tmp/${source_table}_data.sql"
    
    rm "/tmp/${source_table}_data.sql"
}
```

### Database Monitoring and Maintenance

#### MySQL Monitoring Scripts

Implement comprehensive monitoring for MySQL database health, performance, and resource usage.

```bash
#!/bin/bash

## MySQL Health Check
check_mysql_health() {
    local host=${1:-localhost}
    local user=${2:-monitor_user}
    
    echo "=== MySQL Health Check Report ==="
    echo "Date: $(date)"
    echo "Host: $host"
    echo ""
    
    ## Check if MySQL is running
    if ! mysqladmin -h $host -u $user ping &>/dev/null; then
        echo "ERROR: MySQL is not responding"
        return 1
    fi
    
    echo "✓ MySQL is running"
    
    ## Check uptime
    local uptime=$(mysql -h $host -u $user -se "SHOW STATUS LIKE 'Uptime';" | awk '{print $2}')
    echo "Uptime: $(($uptime / 86400)) days, $(($uptime % 86400 / 3600)) hours"
    
    ## Check connections
    local max_connections=$(mysql -h $host -u $user -se "SHOW VARIABLES LIKE 'max_connections';" | awk '{print $2}')
    local current_connections=$(mysql -h $host -u $user -se "SHOW STATUS LIKE 'Threads_connected';" | awk '{print $2}')
    local connection_usage=$(echo "scale=2; $current_connections * 100 / $max_connections" | bc)
    
    echo "Connections: $current_connections/$max_connections (${connection_usage}%)"
    
    ## Check slow queries
    local slow_queries=$(mysql -h $host -u $user -se "SHOW STATUS LIKE 'Slow_queries';" | awk '{print $2}')
    echo "Slow queries: $slow_queries"
    
    ## Check table locks
    local table_locks=$(mysql -h $host -u $user -se "SHOW STATUS LIKE 'Table_locks_waited';" | awk '{print $2}')
    echo "Table locks waited: $table_locks"
    
    ## Check InnoDB buffer pool usage
    local buffer_pool_size=$(mysql -h $host -u $user -se "SHOW STATUS LIKE 'Innodb_buffer_pool_pages_total';" | awk '{print $2}')
    local buffer_pool_free=$(mysql -h $host -u $user -se "SHOW STATUS LIKE 'Innodb_buffer_pool_pages_free';" | awk '{print $2}')
    local buffer_usage=$(echo "scale=2; ($buffer_pool_size - $buffer_pool_free) * 100 / $buffer_pool_size" | bc)
    
    echo "InnoDB buffer pool usage: ${buffer_usage}%"
}

## Performance monitoring
monitor_mysql_performance() {
    local host=${1:-localhost}
    local user=${2:-monitor_user}
    local duration=${3:-60}
    
    echo "Monitoring MySQL performance for $duration seconds..."
    
    ## Monitor queries per second
    local queries_start=$(mysql -h $host -u $user -se "SHOW STATUS LIKE 'Queries';" | awk '{print $2}')
    sleep $duration
    local queries_end=$(mysql -h $host -u $user -se "SHOW STATUS LIKE 'Queries';" | awk '{print $2}')
    
    local qps=$(echo "scale=2; ($queries_end - $queries_start) / $duration" | bc)
    echo "Queries per second: $qps"
    
    ## Show current processes
    echo -e "\nCurrent processes:"
    mysql -h $host -u $user -e "SHOW PROCESSLIST;" | head -20
    
    ## Show slow queries
    echo -e "\nRecent slow queries:"
    mysql -h $host -u $user -e "
        SELECT query_time, lock_time, rows_sent, rows_examined, 
               LEFT(sql_text, 100) as query_snippet
        FROM mysql.slow_log 
        ORDER BY start_time DESC 
        LIMIT 10;"
}

## Database size monitoring
check_database_sizes() {
    local host=${1:-localhost}
    local user=${2:-monitor_user}
    
    echo "Database sizes:"
    mysql -h $host -u $user -e "
        SELECT 
            table_schema AS 'Database',
            ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)',
            ROUND(SUM(data_free) / 1024 / 1024, 2) AS 'Free (MB)'
        FROM information_schema.tables 
        GROUP BY table_schema
        ORDER BY SUM(data_length + index_length) DESC;"
}
```

#### PostgreSQL Monitoring Scripts

Develop PostgreSQL-specific monitoring tools for database health and performance tracking.

```bash
#!/bin/bash

## PostgreSQL Health Check
check_postgres_health() {
    local host=${1:-localhost}
    local user=${2:-monitor_user}
    local db=${3:-postgres}
    
    echo "=== PostgreSQL Health Check Report ==="
    echo "Date: $(date)"
    echo "Host: $host"
    echo ""
    
    ## Check if PostgreSQL is running
    if ! psql -h $host -U $user -d $db -c "SELECT 1;" &>/dev/null; then
        echo "ERROR: PostgreSQL is not responding"
        return 1
    fi
    
    echo "✓ PostgreSQL is running"
    
    ## Check version and uptime
    local version=$(psql -h $host -U $user -d $db -t -c "SELECT version();" | head -1)
    echo "Version: $version"
    
    local uptime=$(psql -h $host -U $user -d $db -t -c "SELECT now() - pg_postmaster_start_time();" | xargs)
    echo "Uptime: $uptime"
    
    ## Check connections
    local max_connections=$(psql -h $host -U $user -d $db -t -c "SHOW max_connections;" | xargs)
    local current_connections=$(psql -h $host -U $user -d $db -t -c "SELECT count(*) FROM pg_stat_activity;" | xargs)
    local connection_usage=$(echo "scale=2; $current_connections * 100 / $max_connections" | bc)
    
    echo "Connections: $current_connections/$max_connections (${connection_usage}%)"
    
    ## Check database sizes
    echo -e "\nDatabase sizes:"
    psql -h $host -U $user -d $db -c "
        SELECT datname, 
               pg_size_pretty(pg_database_size(datname)) as size
        FROM pg_database 
        WHERE datistemplate = false
        ORDER BY pg_database_size(datname) DESC;"
    
    ## Check active queries
    local active_queries=$(psql -h $host -U $user -d $db -t -c "
        SELECT count(*) 
        FROM pg_stat_activity 
        WHERE state = 'active' AND query != '<IDLE>';" | xargs)
    
    echo "Active queries: $active_queries"
}

## PostgreSQL performance monitoring
monitor_postgres_performance() {
    local host=${1:-localhost}
    local user=${2:-monitor_user}
    local db=${3:-postgres}
    
    echo "PostgreSQL Performance Metrics:"
    
    ## Show current activity
    psql -h $host -U $user -d $db -c "
        SELECT pid, usename, datname, state, 
               query_start, 
               LEFT(query, 50) as query_snippet
        FROM pg_stat_activity 
        WHERE state != 'idle' 
        ORDER BY query_start DESC
        LIMIT 10;"
    
    ## Show slow queries
    echo -e "\nSlow queries (if pg_stat_statements is enabled):"
    psql -h $host -U $user -d $db -c "
        SELECT query, calls, total_time, mean_time, rows
        FROM pg_stat_statements 
        ORDER BY total_time DESC 
        LIMIT 10;" 2>/dev/null || echo "pg_stat_statements not available"
    
    ## Show table statistics
    echo -e "\nTable statistics:"
    psql -h $host -U $user -d $db -c "
        SELECT schemaname, tablename, 
               n_tup_ins, n_tup_upd, n_tup_del, n_tup_hot_upd,
               n_live_tup, n_dead_tup
        FROM pg_stat_user_tables 
        ORDER BY n_tup_ins + n_tup_upd + n_tup_del DESC 
        LIMIT 10;"
}

## Index monitoring
monitor_postgres_indexes() {
    local host=${1:-localhost}
    local user=${2:-monitor_user}
    local db=${3:-postgres}
    
    echo "Index usage statistics:"
    psql -h $host -U $user -d $db -c "
        SELECT schemaname, tablename, indexname, 
               idx_scan, idx_tup_read, idx_tup_fetch
        FROM pg_stat_user_indexes 
        ORDER BY idx_scan DESC 
        LIMIT 20;"
    
    echo -e "\nUnused indexes:"
    psql -h $host -U $user -d $db -c "
        SELECT schemaname, tablename, indexname, 
               pg_size_pretty(pg_relation_size(indexrelid)) as size
        FROM pg_stat_user_indexes 
        WHERE idx_scan = 0 
        ORDER BY pg_relation_size(indexrelid) DESC;"
}
```

#### Automated Maintenance Scripts

Create comprehensive maintenance routines for database optimization and health.

```bash
#!/bin/bash

## MySQL maintenance script
mysql_maintenance() {
    local host=${1:-localhost}
    local user=${2:-maintenance_user}
    local db=$3
    
    echo "Starting MySQL maintenance for database: $db"
    
    ## Optimize tables
    echo "Optimizing tables..."
    mysql -h $host -u $user -p $db -e "
        SELECT CONCAT('OPTIMIZE TABLE ', table_schema, '.', table_name, ';') 
        FROM information_schema.tables 
        WHERE table_schema = '$db' AND engine = 'MyISAM';" | \
    grep -v CONCAT | mysql -h $host -u $user -p $db
    
    ## Analyze tables
    echo "Analyzing tables..."
    mysql -h $host -u $user -p $db -e "
        SELECT CONCAT('ANALYZE TABLE ', table_schema, '.', table_name, ';') 
        FROM information_schema.tables 
        WHERE table_schema = '$db';" | \
    grep -v CONCAT | mysql -h $host -u $user -p $db
    
    ## Check for corrupted tables
    echo "Checking for corrupted tables..."
    mysql -h $host -u $user -p $db -e "
        SELECT CONCAT('CHECK TABLE ', table_schema, '.', table_name, ';') 
        FROM information_schema.tables 
        WHERE table_schema = '$db';" | \
    grep -v CONCAT | mysql -h $host -u $user -p $db
    
    echo "MySQL maintenance completed"
}

## PostgreSQL maintenance script
postgres_maintenance() {
    local host=${1:-localhost}
    local user=${2:-maintenance_user}
    local db=$3
    
    echo "Starting PostgreSQL maintenance for database: $db"
    
    ## Vacuum and analyze
    echo "Running VACUUM ANALYZE..."
    psql -h $host -U $user -d $db -c "VACUUM ANALYZE;"
    
    ## Reindex
    echo "Reindexing database..."
    psql -h $host -U $user -d $db -c "REINDEX DATABASE $db;"
    
    ## Update statistics
    echo "Updating table statistics..."
    psql -h $host -U $user -d $db -c "ANALYZE;"
    
    echo "PostgreSQL maintenance completed"
}

## Log rotation and cleanup
cleanup_logs() {
    local log_dir=${1:-/var/log/mysql}
    local retention_days=${2:-7}
    
    echo "Cleaning up logs older than $retention_days days..."
    
    ## Rotate MySQL logs
    find "$log_dir" -name "*.log" -type f -mtime +$retention_days -delete
    
    ## Rotate slow query logs
    find "$log_dir" -name "*slow.log*" -type f -mtime +$retention_days -delete
    
    echo "Log cleanup completed"
}
```

**Key points** for database integration in bash:

- Always use secure connection methods and avoid hardcoding credentials
- Implement proper error handling and validation for all database operations
- Use transactions for critical operations to ensure data integrity
- Monitor performance metrics and implement automated maintenance routines
- Create comprehensive backup strategies with proper rotation and testing
- Utilize database-specific tools and features for optimal performance

**Example** of a complete database integration script:

```bash
#!/bin/bash

## Database configuration
DB_TYPE="mysql"
DB_HOST="localhost"
DB_USER="app_user"
DB_NAME="application_db"
BACKUP_DIR="/backups"

## Load configuration
source /etc/db_config.conf

## Main function
main() {
    case $1 in
        "backup")
            create_backup
            ;;
        "monitor")
            run_health_check
            ;;
        "maintain")
            perform_maintenance
            ;;
        "query")
            execute_query "$2"
            ;;
        *)
            echo "Usage: $0 {backup|monitor|maintain|query}"
            exit 1
            ;;
    esac
}

main "$@"
```

**Next steps** for advanced database integration include exploring connection pooling, implementing database sharding scripts, creating automated failover mechanisms, and developing custom monitoring dashboards with real-time metrics.

---

