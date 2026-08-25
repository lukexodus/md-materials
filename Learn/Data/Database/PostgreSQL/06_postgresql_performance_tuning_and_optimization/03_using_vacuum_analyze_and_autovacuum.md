## Using VACUUM, ANALYZE, and Autovacuum


### Understanding Database Maintenance

Database maintenance operations like VACUUM, ANALYZE, and Autovacuum are essential for optimal PostgreSQL performance. These processes manage dead rows, update statistics, and prevent database bloat, ensuring queries run efficiently and storage remains optimized.

**Key Points**:

- Regular maintenance prevents performance degradation over time
- Improper maintenance can lead to database bloat and query slowdowns
- Understanding these processes helps balance performance and maintenance overhead
- These operations are primarily PostgreSQL-specific, though similar concepts exist in other systems

### The VACUUM Command

VACUUM is a PostgreSQL maintenance operation that reclaims storage occupied by dead tuples (rows that have been deleted or obsoleted by updates) and makes it available for reuse.

#### How PostgreSQL Handles Updates and Deletes

PostgreSQL uses a Multi-Version Concurrency Control (MVCC) system:

- When you update a row, PostgreSQL creates a new version of the row
- When you delete a row, it's marked as no longer visible
- Old versions remain in the table until cleaned up by VACUUM
- This approach enables consistent reads without locking

#### Basic VACUUM Syntax

```sql
VACUUM [table_name];
```

#### VACUUM Options

```sql
-- Standard vacuum (doesn't reclaim space to the OS)
VACUUM customers;

-- Full vacuum (reclaims space to the OS, requires exclusive lock)
VACUUM FULL customers;

-- Verbose output showing statistics
VACUUM VERBOSE customers;

-- Remove dead tuples and update statistics
VACUUM ANALYZE customers;

-- Only process dead tuples above a threshold
VACUUM (THRESHOLD 50000) customers;
```

#### What VACUUM Does

1. Scans tables for dead tuples
2. Makes space occupied by dead tuples available for reuse
3. Updates the visibility map
4. Updates the free space map
5. Freezes old transaction IDs when necessary

**Example**:

```sql
VACUUM VERBOSE orders;
```

**Output**:

```
INFO:  vacuuming "public.orders"
INFO:  "orders": found 1207 removable, 10432 nonremovable row versions in 1546 pages
INFO:  "orders": removed 1207 row versions in 1042 pages
INFO:  "orders": found 205 dead row versions in 205 pages
INFO:  "orders": removed 205 dead row versions in 205 pages
INFO:  CPU: user: 0.09 s, system: 0.00 s, elapsed: 0.16 s
```

### The ANALYZE Command

ANALYZE collects statistics about the distribution of values in table columns, which the query planner uses to create efficient execution plans.

#### Basic ANALYZE Syntax

```sql
ANALYZE [table_name [(column_name [, ...])]]
```

#### What ANALYZE Does

1. Reads a random sample of rows from tables
2. Calculates statistics about data distribution
3. Stores statistics in the pg_statistic system catalog
4. Updates the last_analyze timestamp

**Example**:

```sql
ANALYZE VERBOSE customers;
```

**Output**:

```
INFO:  analyzing "public.customers"
INFO:  "customers": scanned 1000 of 1000 rows (100.00%), 30 dead rows (3.00%) were removed
DETAIL:  1000 rows in table with an estimated 1000 rows, 30 dead rows removed
```

### VACUUM ANALYZE Combined

For efficiency, you can combine both operations:

```sql
VACUUM ANALYZE customers;
```

This reclaims space and updates statistics in a single table scan.

### Autovacuum

Autovacuum is a background daemon that automatically runs VACUUM and ANALYZE on tables when needed, based on activity levels.

#### How Autovacuum Works

1. Monitors table activity
2. Triggers VACUUM when dead tuples exceed thresholds
3. Triggers ANALYZE when table contents change significantly
4. Works incrementally to minimize performance impact

#### Configuring Autovacuum

Key configuration parameters in postgresql.conf:

```
# Enable/disable autovacuum (on by default in modern versions)
autovacuum = on

# Number of worker processes
autovacuum_max_workers = 3

# Vacuum threshold formula: 
# vacuum when dead_tuples > base_threshold + scale_factor * total_tuples
autovacuum_vacuum_threshold = 50
autovacuum_vacuum_scale_factor = 0.2

# Analyze threshold formula:
# analyze when modified_tuples > base_threshold + scale_factor * total_tuples
autovacuum_analyze_threshold = 50
autovacuum_analyze_scale_factor = 0.1

# Sleep time between runs
autovacuum_naptime = 1min

# Maximum runtime per table
autovacuum_vacuum_cost_limit = 200
```

#### Table-Specific Autovacuum Settings

You can configure different settings for specific tables:

```sql
ALTER TABLE large_logging_table SET (
  autovacuum_vacuum_scale_factor = 0.0,
  autovacuum_vacuum_threshold = 10000,
  autovacuum_analyze_scale_factor = 0.0,
  autovacuum_analyze_threshold = 5000
);
```

### Monitoring Vacuum and Analyze Operations

#### Current Autovacuum Activity

```sql
SELECT datname, usename, query
FROM pg_stat_activity
WHERE query LIKE 'autovacuum:%';
```

#### Table-Specific Statistics

```sql
SELECT relname, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze
FROM pg_stat_user_tables
ORDER BY relname;
```

#### Vacuum Progress Monitoring (PostgreSQL 9.6+)

```sql
SELECT * FROM pg_stat_progress_vacuum;
```

### Common Issues and Solutions

#### Bloated Tables

**Symptoms**:

- Growing table/index size without corresponding data growth
- Slowing query performance
- High I/O activity

**Solution**:

```sql
-- Check for bloat
SELECT
  schemaname || '.' || tablename AS table_name,
  pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS total_size,
  pg_size_pretty(pg_relation_size(schemaname || '.' || tablename)) AS table_size,
  round(100 * pg_relation_size(schemaname || '.' || tablename) / 
    NULLIF(pg_total_relation_size(schemaname || '.' || tablename), 0), 2) AS table_percent,
  pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename) - 
    pg_relation_size(schemaname || '.' || tablename)) AS index_size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC
LIMIT 10;

-- Run VACUUM FULL (with caution!) or a more gradual approach with VACUUM
```

#### Transaction ID Wraparound

**Symptoms**:

- Warnings about approaching transaction ID wraparound
- Database freezing when prevention takes place

**Solution**:

```sql
-- Check for old unfrozen XID tables
SELECT c.oid::regclass, age(c.relfrozenxid), pg_size_pretty(pg_table_size(c.oid))
FROM pg_class c
JOIN pg_namespace n ON c.relnamespace = n.oid
WHERE c.relkind = 'r' AND n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY 2 DESC
LIMIT 10;

-- Run VACUUM FREEZE on affected tables
VACUUM FREEZE old_table;
```

#### Ineffective Autovacuum

**Issue**: Autovacuum can't keep up with write-heavy tables

**Solution**:

```sql
-- Identify tables with high dead tuple counts
SELECT relname, n_dead_tup, n_live_tup, 
       round(n_dead_tup * 100.0 / NULLIF(n_live_tup, 0), 2) AS dead_percentage
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC;

-- Adjust autovacuum settings for specific tables
ALTER TABLE high_write_table SET (
  autovacuum_vacuum_scale_factor = 0.0,
  autovacuum_vacuum_threshold = 1000,
  autovacuum_vacuum_cost_delay = 10
);
```

### Best Practices

#### VACUUM Strategies

1. **Regular Maintenance Window Vacuums**
    
    Schedule full database maintenance during low-traffic periods:
    
    ```sql
    -- Script for maintenance window
    VACUUM VERBOSE ANALYZE;
    ```
    
2. **Targeted Vacuums for Busy Tables**
    
    ```sql
    -- Target specific high-churn tables frequently
    VACUUM orders, order_items, audit_logs;
    ```
    
3. **Avoid VACUUM FULL in Production**
    
    ```sql
    -- Better alternative using pg_repack extension
    -- Install pg_repack extension first
    SELECT pg_repack.repack_table('public.large_table');
    ```
    

#### Optimizing Autovacuum

1. **Scale Factor vs. Threshold Strategy**
    
    For large tables (millions of rows):
    
    ```sql
    ALTER TABLE large_table SET (
      autovacuum_vacuum_scale_factor = 0.0,
      autovacuum_vacuum_threshold = 5000
    );
    ```
    
    For small tables:
    
    ```sql
    ALTER TABLE small_table SET (
      autovacuum_vacuum_scale_factor = 0.2,
      autovacuum_vacuum_threshold = 50
    );
    ```
    
2. **Work Memory Allocation**
    
    ```
    -- In postgresql.conf
    maintenance_work_mem = 256MB  -- Adjust based on server resources
    ```
    
3. **Cost-Based Delay**
    
    ```
    -- In postgresql.conf
    autovacuum_vacuum_cost_delay = 2ms  -- Lower for faster processing
    ```
    

### VACUUM FREEZE

Transaction ID wraparound is a critical issue in PostgreSQL. FREEZE addresses this by marking tuples as "always visible" to prevent transaction ID exhaustion.

```sql
-- Check XID age
SELECT datname, age(datfrozenxid) FROM pg_database ORDER BY 2 DESC;

-- Freeze old XIDs
VACUUM FREEZE table_name;
```

### Balancing Maintenance and Performance

#### Impact on Concurrent Operations

- VACUUM runs concurrently with other operations
- VACUUM FULL blocks all other access to the table
- Autovacuum throttles itself based on system activity

**Example Configuration for Busy Systems**:

```
# More workers for large databases
autovacuum_max_workers = 6

# More aggressive cleanup during off-hours
autovacuum_naptime = '5min'
autovacuum_vacuum_cost_delay = '10ms'
autovacuum_vacuum_cost_limit = 500

# During business hours, adjust with ALTER SYSTEM:
ALTER SYSTEM SET autovacuum_vacuum_cost_delay = '20ms';
ALTER SYSTEM SET autovacuum_vacuum_cost_limit = 200;
SELECT pg_reload_conf();
```

### Advanced Topics

#### pg_stat_statements for Targeted Analysis

```sql
-- Identify tables affected by slow queries for targeted ANALYZE
SELECT substring(query, 1, 50) AS short_query,
       calls, total_time, rows,
       100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;
```

#### Manual Statistic Updates

Sometimes you need to adjust statistics manually:

```sql
-- Set higher statistics target for important join columns
ALTER TABLE orders ALTER COLUMN customer_id SET STATISTICS 1000;

-- Then analyze
ANALYZE orders;
```

#### Handling Anti-patterns

1. **Over-indexing**: Too many indexes interfere with VACUUM performance
    
    ```sql
    -- Find redundant indexes
    SELECT pg_size_pretty(sum(pg_relation_size(idx))::bigint) AS size,
           (array_agg(idx))[1] AS idx1, (array_agg(idx))[2] AS idx2,
           (array_agg(idx))[3] AS idx3, (array_agg(idx))[4] AS idx4
    FROM (
        SELECT indexrelid::regclass AS idx, 
               (indrelid::text || E'\n' || indclass::text || E'\n' ||
                indkey::text || E'\n' || coalesce(indexprs::text, '') || E'\n' || 
                coalesce(indpred::text, '')) AS key
        FROM pg_index
    ) sub
    GROUP BY key HAVING count(*) > 1
    ORDER BY sum(pg_relation_size(idx)) DESC;
    ```
    
2. **Never Vacuuming**: Relying solely on autovacuum may not be enough
    
    ```sql
    -- Create a monitoring table for tables needing vacuum
    CREATE TABLE vacuum_monitor AS
    SELECT schemaname, relname, n_dead_tup, last_vacuum, last_autovacuum,
           current_timestamp AS snapshot_time
    FROM pg_stat_user_tables;
    
    -- Check daily/hourly and plan manual vacuums as needed
    ```
    

### VACUUM and ANALYZE in PostgreSQL Versions

#### Version-Specific Features

- **PostgreSQL 12+**: Improved handling of index vacuuming with Index Access Method interface
- **PostgreSQL 13+**: Incremental sorting during ANALYZE for better statistics
- **PostgreSQL 14+**: Better handling of tables with large numbers of partitions
- **PostgreSQL 15+**: Enhanced autovacuum logging and monitoring capabilities

**Example PostgreSQL 15 Configuration**:

```
# Enhanced visibility of autovacuum
log_autovacuum_min_duration = 250ms

# Default visibility statistics are now maintained automatically
vacuum_update_visibility_map = on
```

### Disaster Recovery Planning

Always have a plan for cases where VACUUM FULL is necessary:

```bash
# Clone the problematic table using pg_dump for a clean copy
pg_dump -t problematic_table -f table_dump.sql mydb

# After the VACUUM FULL fails or database crashes
psql -f table_dump.sql mydb
```

**Conclusion**:

VACUUM, ANALYZE, and Autovacuum are critical PostgreSQL maintenance operations that ensure database health and query performance. Understanding when and how to use them allows database administrators to maintain optimal performance while minimizing overhead. Regular monitoring of database statistics, proper configuration of autovacuum parameters, and strategic manual maintenance operations form the foundation of a healthy PostgreSQL environment. By implementing the practices outlined in this guide, you can prevent common issues like table bloat, transaction ID wraparound, and degraded query performance.

### Related Topics

- PostgreSQL table partitioning
- MVCC (Multi-Version Concurrency Control)
- Database replication and vacuum
- pg_repack for online table reorganization
- Optimizing PostgreSQL for specific workloads

---

