## Monitoring PostgreSQL Performance


### Understanding PostgreSQL Performance Monitoring

Effective monitoring of PostgreSQL performance is essential for maintaining optimal database operations, identifying bottlenecks, and planning capacity. PostgreSQL provides several built-in tools and extensions that, when combined with third-party utilities, create a comprehensive monitoring ecosystem.

**Key Points**:

- Performance monitoring helps identify bottlenecks, predict capacity issues, and optimize queries
- PostgreSQL offers built-in statistics views and extensions like pg_stat_statements
- Tools like pgBadger allow for detailed log analysis and visualization
- A comprehensive monitoring strategy combines real-time metrics with historical analysis

### PostgreSQL Statistics System

#### Core Statistics Views

PostgreSQL maintains various statistics views that provide insights into database activity:

```sql
-- Database-wide statistics
SELECT * FROM pg_stat_database WHERE datname = current_database();

-- Table statistics
SELECT schemaname, relname, seq_scan, seq_tup_read, 
       idx_scan, idx_tup_fetch, n_tup_ins, n_tup_upd, n_tup_del
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;

-- Index usage statistics
SELECT schemaname, relname, indexrelname, idx_scan, 
       idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Backend process activity
SELECT pid, usename, application_name, state, query_start, 
       backend_start, xact_start, wait_event_type, wait_event
FROM pg_stat_activity
WHERE state != 'idle';
```

#### Resetting Statistics Counters

```sql
-- Reset a specific statistics counter
SELECT pg_stat_reset_single_table_counters('pg_class'::regclass);

-- Reset all statistics counters
SELECT pg_stat_reset();
```

### Setting Up pg_stat_statements

pg_stat_statements is a powerful extension that tracks execution statistics for all SQL statements executed by the server.

#### Installation and Configuration

```sql
-- Add to shared_preload_libraries in postgresql.conf
-- shared_preload_libraries = 'pg_stat_statements'

-- After restarting PostgreSQL, create the extension
CREATE EXTENSION pg_stat_statements;

-- Configure in postgresql.conf
-- pg_stat_statements.max = 10000
-- pg_stat_statements.track = all
-- pg_stat_statements.track_utility = on
-- pg_stat_statements.save = on
```

#### Basic Usage

```sql
-- View top queries by total execution time
SELECT query, calls, total_exec_time, rows, 
       mean_exec_time, min_exec_time, max_exec_time,
       stddev_exec_time, total_exec_time / calls as avg_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- View top queries by average execution time
SELECT query, calls, total_exec_time, rows, mean_exec_time
FROM pg_stat_statements
WHERE calls > 100  -- Focus on frequently called queries
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Reset statistics
SELECT pg_stat_statements_reset();
```

#### Advanced Analysis with pg_stat_statements

```sql
-- Find queries with high variance in execution time
SELECT query, calls, mean_exec_time, stddev_exec_time,
       stddev_exec_time / mean_exec_time as variability_ratio
FROM pg_stat_statements 
WHERE calls > 10
ORDER BY variability_ratio DESC
LIMIT 10;

-- Queries with high buffer usage
SELECT query, calls, shared_blks_hit, shared_blks_read,
       local_blks_hit, local_blks_read, temp_blks_read, temp_blks_written
FROM pg_stat_statements
ORDER BY shared_blks_read + shared_blks_hit DESC
LIMIT 10;

-- Calculate cache hit ratio for queries
SELECT query, calls,
       shared_blks_hit, shared_blks_read,
       CASE WHEN shared_blks_hit + shared_blks_read > 0
            THEN shared_blks_hit::float / (shared_blks_hit + shared_blks_read)
            ELSE NULL END as hit_ratio
FROM pg_stat_statements
WHERE shared_blks_read + shared_blks_hit > 1000
ORDER BY hit_ratio ASC
LIMIT 10;
```

### Setting Up PostgreSQL Logging for pgBadger

pgBadger is an advanced PostgreSQL log analyzer that generates detailed HTML reports.

#### Log Configuration for pgBadger

In postgresql.conf:

```
# Essential logging parameters for pgBadger
log_destination = 'csvlog'
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB

# What to log
log_min_duration_statement = 100  # Log statements running >= 100ms
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on
log_temp_files = 0

# Log content and format
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_statement = 'none'  # Options: none, ddl, mod, all
```

#### Installing and Running pgBadger

```bash
# Install pgBadger (Debian/Ubuntu)
apt-get install pgbadger

# Install pgBadger (macOS with Homebrew)
brew install pgbadger

# Basic usage
pgbadger /var/log/postgresql/postgresql-2023-05-01_*.log

# Generate report for a specific time period
pgbadger --begin "2023-05-01 10:00:00" --end "2023-05-01 11:00:00" \
  /var/log/postgresql/postgresql-2023-05-01_*.log
  
# Incremental report generation
pgbadger -I -O /var/www/html/pgbadger --prefix pgbadger_report \
  /var/log/postgresql/postgresql-*.log
```

#### Automating pgBadger Reports

```bash
#!/bin/bash
# daily_pgbadger.sh

LOG_DIR="/var/log/postgresql"
OUTPUT_DIR="/var/www/html/pgbadger"
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)

# Create directory for this day if it doesnt exist
mkdir -p "${OUTPUT_DIR}/${YESTERDAY}"

# Generate report for yesterday's logs
pgbadger -q -o "${OUTPUT_DIR}/${YESTERDAY}/index.html" \
  ${LOG_DIR}/postgresql-${YESTERDAY}_*.log

# Generate incremental report
pgbadger -I -q -O "${OUTPUT_DIR}" --prefix "pgbadger_report" \
  ${LOG_DIR}/postgresql-${YESTERDAY}_*.log

# Update latest report symlink
ln -sf "${OUTPUT_DIR}/${YESTERDAY}" "${OUTPUT_DIR}/latest"
```

Add to crontab:

```
0 1 * * * /path/to/daily_pgbadger.sh
```

### Real-time Performance Monitoring

#### Tracking Active Queries

```sql
-- Show currently running queries
SELECT pid, usename, application_name, 
       now() - query_start AS duration,
       wait_event_type, wait_event, state, query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC;

-- Find blocked queries
SELECT blocked_activity.pid AS blocked_pid,
       blocked_activity.query AS blocked_query,
       blocking_activity.pid AS blocking_pid,
       blocking_activity.query AS blocking_query
FROM pg_catalog.pg_locks AS blocked_locks
JOIN pg_catalog.pg_stat_activity AS blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks AS blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
    AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
    AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
    AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
    AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
    AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
    AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
    AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
    AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
    AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
    AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity AS blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;
```

#### Monitoring Transaction IDs and Wraparound

```sql
-- Check transaction wraparound status
SELECT datname, age(datfrozenxid) AS xid_age,
       round(100*(2147483647-age(datfrozenxid))/2147483647.0, 4) AS percent_remaining
FROM pg_database
ORDER BY xid_age DESC;

-- Find tables at risk of wraparound
SELECT c.oid::regclass as table_name,
       greatest(age(c.relfrozenxid),age(t.relfrozenxid)) as max_age
FROM pg_class c
LEFT JOIN pg_class t ON c.reltoastrelid = t.oid
WHERE c.relkind IN ('r', 'm')
ORDER BY max_age DESC
LIMIT 50;
```

#### Identifying Index Bloat

```sql
-- Simple index bloat estimate
SELECT schemaname, tablename, reltuples::bigint, relpages::bigint, 
       otta,
       ROUND(CASE WHEN otta=0 THEN 0.0 ELSE sml.relpages/otta::numeric END,1) AS ibloat,
       CASE WHEN relpages < otta THEN 0 ELSE relpages::bigint - otta END AS wastedpages,
       CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::bigint END AS wastedbytes
FROM (
    SELECT schemaname, tablename, cc.reltuples, cc.relpages, bs,
        CEIL((cc.reltuples*datahdr + page_hdr)/(bs-20::float)) AS otta
    FROM (
        SELECT ma.nspname AS schemaname, ma.relname AS tablename,
            ma.reltuples, ma.relpages, bs,
            (datawidth+(hdr+ma.ma_tid))::float AS datahdr,
            page_hdr
        FROM (
            SELECT ns.nspname, i.relname, i.reltuples, i.relpages,
                pg_catalog.current_setting('block_size')::numeric AS bs,
                CASE WHEN version() ~ 'mingw32' OR version() ~ '64-bit' THEN 8 ELSE 4 END AS hdr,
                20 AS ma_tid,
                24 AS page_hdr
            FROM pg_index i
            JOIN pg_class c ON i.indexrelid = c.oid
            JOIN pg_namespace ns ON c.relnamespace = ns.oid
            WHERE NOT i.indisunique AND i.indisvalid AND c.relkind = 'i' AND i.indexprs IS NULL
        ) AS ma
    ) AS cc
) AS sml
ORDER BY wastedbytes DESC LIMIT 10;
```

### Memory and I/O Monitoring

#### Tracking Buffer Cache Usage

```sql
-- Check buffer cache hit ratio
SELECT datname,
       blks_hit::float/(blks_hit+blks_read) AS cache_hit_ratio,
       blks_hit, blks_read
FROM pg_stat_database
WHERE blks_read > 0
ORDER BY cache_hit_ratio ASC;

-- Buffer cache usage by table
SELECT c.relname, count(*) AS buffers
FROM pg_buffercache b
INNER JOIN pg_class c ON b.relfilenode = pg_relation_filenode(c.oid) 
    AND b.reldatabase IN (0, (SELECT oid FROM pg_database WHERE datname = current_database()))
GROUP BY c.relname
ORDER BY 2 DESC
LIMIT 20;
```

Remember to:

```sql
-- Install the extension if needed
CREATE EXTENSION pg_buffercache;
```

#### Tracking I/O Timing

```sql
-- Enable I/O timing (in postgresql.conf)
-- track_io_timing = on

-- Check I/O timing statistics
SELECT datname,
       temp_files, temp_bytes,
       blk_read_time, blk_write_time
FROM pg_stat_database
WHERE datname = current_database();

-- Check I/O timing for tables
SELECT schemaname, relname,
       heap_blks_read, heap_blks_hit,
       idx_blks_read, idx_blks_hit,
       toast_blks_read, toast_blks_hit,
       tidx_blks_read, tidx_blks_hit
FROM pg_statio_user_tables
ORDER BY heap_blks_read + idx_blks_read DESC
LIMIT 20;
```

### Query Performance Analysis

#### EXPLAIN and EXPLAIN ANALYZE

```sql
-- Basic query plan
EXPLAIN
SELECT * FROM orders
JOIN customers ON orders.customer_id = customers.id
WHERE orders.order_date > '2023-01-01';

-- Analyze actual execution
EXPLAIN ANALYZE
SELECT * FROM orders
JOIN customers ON orders.customer_id = customers.id
WHERE orders.order_date > '2023-01-01';

-- With buffer and timing information
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT * FROM orders
JOIN customers ON orders.customer_id = customers.id
WHERE orders.order_date > '2023-01-01';
```

#### Finding Slow Queries with pg_stat_statements

```sql
-- Queries with highest total time
SELECT substring(query, 1, 100) as query_snippet,
       round(total_exec_time::numeric, 2) as total_time,
       calls, 
       round(mean_exec_time::numeric, 2) as avg_time,
       round((100 * total_exec_time / sum(total_exec_time) OVER ())::numeric, 2) as percent
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- Queries with highest average time
SELECT substring(query, 1, 100) as query_snippet,
       round(mean_exec_time::numeric, 2) as avg_time,
       calls,
       round(total_exec_time::numeric, 2) as total_time
FROM pg_stat_statements
WHERE calls > 10  -- Ignore rarely called queries
ORDER BY mean_exec_time DESC
LIMIT 20;
```

### Developing a Dashboard with pg_stat_statements

Creating a dashboard view for quick performance assessment:

```sql
CREATE OR REPLACE VIEW pg_stat_dashboard AS
WITH totals AS (
    SELECT sum(total_exec_time) as total_time,
           sum(calls) as total_calls,
           sum(shared_blks_read) as total_reads,
           sum(shared_blks_hit) as total_hits
    FROM pg_stat_statements
)
SELECT 
    substring(s.query, 1, 80) as query_snippet,
    s.calls,
    round(s.mean_exec_time::numeric, 2) as avg_ms,
    round(s.total_exec_time::numeric, 2) as total_ms,
    round((s.total_exec_time * 100 / t.total_time)::numeric, 2) as time_percent,
    s.rows,
    round((s.shared_blks_hit * 100 / (s.shared_blks_hit + s.shared_blks_read))::numeric, 2) as cache_hit_ratio,
    s.shared_blks_read as disk_reads,
    s.shared_blks_hit as cache_hits,
    s.shared_blks_dirtied as blocks_dirtied,
    s.shared_blks_written as blocks_written,
    s.temp_blks_read + s.temp_blks_written as temp_blocks,
    s.calls - s.shared_blks_written as writes_saved
FROM pg_stat_statements s, totals t
ORDER BY s.total_exec_time DESC
LIMIT 20;
```

### Setting Up Daily Performance Snapshots

Creating a snapshot system to track performance trends over time:

```sql
-- Create snapshot schema and tables
CREATE SCHEMA IF NOT EXISTS monitoring;

CREATE TABLE IF NOT EXISTS monitoring.stat_statements_snapshot (
    snapshot_time timestamptz DEFAULT now(),
    dbid oid,
    userid oid,
    queryid bigint,
    query text,
    calls bigint,
    total_time double precision,
    min_time double precision,
    max_time double precision,
    mean_time double precision,
    stddev_time double precision,
    rows bigint,
    shared_blks_hit bigint,
    shared_blks_read bigint,
    shared_blks_dirtied bigint,
    shared_blks_written bigint,
    local_blks_hit bigint,
    local_blks_read bigint,
    local_blks_dirtied bigint,
    local_blks_written bigint,
    temp_blks_read bigint,
    temp_blks_written bigint,
    blk_read_time double precision,
    blk_write_time double precision
);

-- Function to take a snapshot
CREATE OR REPLACE FUNCTION monitoring.take_stat_statements_snapshot()
RETURNS void AS $$
BEGIN
    INSERT INTO monitoring.stat_statements_snapshot
    SELECT now(), dbid, userid, queryid, query, calls, 
           total_exec_time, min_exec_time, max_exec_time, mean_exec_time, stddev_exec_time,
           rows, shared_blks_hit, shared_blks_read, shared_blks_dirtied, shared_blks_written,
           local_blks_hit, local_blks_read, local_blks_dirtied, local_blks_written,
           temp_blks_read, temp_blks_written, blk_read_time, blk_write_time
    FROM pg_stat_statements;
    
    -- Reset after snapshot for clean interval data
    PERFORM pg_stat_statements_reset();
END;
$$ LANGUAGE plpgsql;
```

Set up a cron job to run this function:

```bash
# As postgres user, create script
echo "psql -c 'SELECT monitoring.take_stat_statements_snapshot();'" > /var/lib/postgresql/take_snapshot.sh
chmod +x /var/lib/postgresql/take_snapshot.sh

# Add to crontab
crontab -e
# Add line: 0 * * * * /var/lib/postgresql/take_snapshot.sh
```

### Implementing Automated Alerting

Create functions to check for performance issues:

```sql
CREATE OR REPLACE FUNCTION monitoring.check_long_running_queries()
RETURNS TABLE(pid int, username text, duration interval, query text) AS $$
BEGIN
    RETURN QUERY
    SELECT pg_stat_activity.pid::int, 
           pg_stat_activity.usename::text,
           now() - pg_stat_activity.query_start AS duration,
           pg_stat_activity.query::text
    FROM pg_stat_activity
    WHERE state != 'idle'
      AND now() - pg_stat_activity.query_start > interval '5 minutes'
    ORDER BY duration DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION monitoring.check_database_health()
RETURNS TABLE(check_name text, status text, details text) AS $$
DECLARE
    cache_hit_ratio float;
    xid_consumption float;
    dead_tuple_ratio float;
BEGIN
    -- Check cache hit ratio
    SELECT sum(blks_hit)::float / (sum(blks_hit) + sum(blks_read)) INTO cache_hit_ratio
    FROM pg_stat_database
    WHERE datname = current_database();
    
    IF cache_hit_ratio < 0.9 THEN
        check_name := 'Cache Hit Ratio';
        status := 'WARNING';
        details := 'Cache hit ratio is ' || round(cache_hit_ratio * 100, 2) || '%, below 90% threshold';
        RETURN NEXT;
    END IF;
    
    -- Check transaction ID wraparound
    SELECT max(age(datfrozenxid)) / 2147483647.0 INTO xid_consumption
    FROM pg_database;
    
    IF xid_consumption > 0.5 THEN
        check_name := 'XID Consumption';
        status := 'WARNING';
        details := 'Transaction ID consumption at ' || round(xid_consumption * 100, 2) || '% of capacity';
        RETURN NEXT;
    END IF;
    
    -- Check for tables needing vacuum
    FOR check_name, status, details IN
        SELECT 'Table Bloat' as check_name,
               'WARNING' as status,
               relname || ' has ' || round(n_dead_tup::numeric / n_live_tup::numeric * 100, 2) || 
               '% dead tuples (' || n_dead_tup || ' of ' || n_live_tup || ')' as details
        FROM pg_stat_user_tables
        WHERE n_live_tup > 0
          AND n_dead_tup > 0
          AND n_dead_tup::float / n_live_tup > 0.2  -- 20% dead tuples
    LOOP
        RETURN NEXT;
    END LOOP;
    
    -- Return a positive message if no issues found
    IF NOT FOUND THEN
        check_name := 'Overall Health';
        status := 'OK';
        details := 'No major issues detected';
        RETURN NEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
```

Create a simple alerting script:

```bash
#!/bin/bash
# check_pg_health.sh

PGHOST=localhost
PGUSER=postgres
PGDATABASE=mydb
EMAIL_RECIPIENT="dba@example.com"

# Run health checks
HEALTH_OUTPUT=$(psql -t -h $PGHOST -U $PGUSER -d $PGDATABASE -c "SELECT * FROM monitoring.check_database_health()" 2>&1)
LONG_QUERIES=$(psql -t -h $PGHOST -U $PGUSER -d $PGDATABASE -c "SELECT * FROM monitoring.check_long_running_queries()" 2>&1)

# Check if there are issues to report
if echo "$HEALTH_OUTPUT" | grep -q "WARNING"; then
    echo "PostgreSQL Health Warnings" > /tmp/pg_alert.txt
    echo "=========================" >> /tmp/pg_alert.txt
    echo "$HEALTH_OUTPUT" >> /tmp/pg_alert.txt
    echo -e "\n\nLong Running Queries:" >> /tmp/pg_alert.txt
    echo "===================" >> /tmp/pg_alert.txt
    echo "$LONG_QUERIES" >> /tmp/pg_alert.txt
    
    # Send email alert
    cat /tmp/pg_alert.txt | mail -s "PostgreSQL Health Alert" $EMAIL_RECIPIENT
fi
```

### Integrating with External Monitoring Tools

#### Prometheus Integration with pg_exporter

```bash
# Install pg_exporter
docker run -d \
  --name postgres_exporter \
  -p 9187:9187 \
  -e DATA_SOURCE_NAME="postgresql://postgres:password@db:5432/postgres?sslmode=disable" \
  quay.io/prometheuscommunity/postgres-exporter
```

Sample Prometheus queries for PostgreSQL:

```
# Query rate
rate(pg_stat_database_xact_commit{datname="mydb"}[5m]) + rate(pg_stat_database_xact_rollback{datname="mydb"}[5m])

# Cache hit ratio
sum(pg_stat_database_blks_hit{datname="mydb"}) / (sum(pg_stat_database_blks_hit{datname="mydb"}) + sum(pg_stat_database_blks_read{datname="mydb"}))

# Active connections
pg_stat_activity_count{datname="mydb",state="active"}
```

#### Grafana Dashboard for PostgreSQL

Create a comprehensive Grafana dashboard with panels:

1. Overview Panel:
    
    - Active connections
    - Transaction rate (commits + rollbacks)
    - Cache hit ratio
    - TPS (Transactions Per Second)
2. Query Performance Panel:
    
    - Top queries by execution time
    - Query execution distribution
    - Query latency trends
3. Resource Usage Panel:
    
    - CPU usage per database
    - Memory usage
    - Disk I/O
4. Table/Index Statistics Panel:
    
    - Table scan vs. index scan ratio
    - Table growth rate
    - Index usage statistics

### Specialized Monitoring Techniques

#### Monitoring Replication Lag

```sql
-- On primary server
SELECT client_addr, state, sent_lsn, write_lsn, 
       flush_lsn, replay_lsn,
       pg_wal_lsn_diff(sent_lsn, replay_lsn) AS byte_lag
FROM pg_stat_replication;

-- On standby server
SELECT now() - pg_last_xact_replay_timestamp() AS replication_delay;
```

#### Monitoring Connection Pooling

For PgBouncer:

```bash
# Check PgBouncer statistics
psql -p 6432 -d pgbouncer -U pgbouncer -c "SHOW STATS"
psql -p 6432 -d pgbouncer -U pgbouncer -c "SHOW POOLS"
```

#### Monitoring Vacuum Progress

```sql
-- Track vacuum progress
SELECT datname, relid::regclass as table_name,
       phase, heap_blks_total, heap_blks_scanned, heap_blks_vacuumed,
       index_vacuum_count, max_dead_tuples, num_dead_tuples
FROM pg_stat_progress_vacuum;

-- Track autovacuum activity
SELECT relname, last_vacuum, last_autovacuum,
       vacuum_count, autovacuum_count,
       n_dead_tup, n_live_tup,
       n_dead_tup::float / n_live_tup as dead_ratio
FROM pg_stat_user_tables
ORDER BY dead_ratio DESC NULLS LAST;
```

**Conclusion**

Effective PostgreSQL performance monitoring combines built-in tools like pg_stat_statements with external utilities like pgBadger to provide comprehensive insights into database operation. By implementing a multi-layered monitoring approach that includes real-time metrics, historical analysis, and automated alerting, database administrators can proactively identify performance issues, optimize workloads, and ensure reliable database operation. Regular performance analysis should be integrated into your database maintenance routines to maintain optimal performance as your data and workloads evolve.

### Recommended Related Topics

- Query Optimization Techniques for PostgreSQL
- Index Design and Management
- Vacuum and Autovacuum Tuning
- PostgreSQL High Availability Monitoring

---

