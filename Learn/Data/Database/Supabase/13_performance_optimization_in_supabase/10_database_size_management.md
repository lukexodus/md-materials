## Database Size Management


Managing database size is crucial for performance, cost control, and operational efficiency.

### Monitoring Database Size

```sql
-- Overall database size
SELECT 
  pg_database.datname,
  pg_size_pretty(pg_database_size(pg_database.datname)) as size
FROM pg_database
ORDER BY pg_database_size(pg_database.datname) DESC;

-- Table sizes with indexes
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size,
  pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as table_size,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - 
                 pg_relation_size(schemaname||'.'||tablename)) as indexes_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Largest tables
SELECT 
  tablename,
  pg_size_pretty(pg_total_relation_size(tablename::regclass)) as size,
  pg_total_relation_size(tablename::regclass) as bytes
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(tablename::regclass) DESC
LIMIT 20;

-- Largest indexes
SELECT 
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC
LIMIT 20;
```

### Table Bloat

Table bloat occurs when tables contain dead rows not yet reclaimed by VACUUM:

```sql
-- Detect table bloat
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
  n_dead_tup as dead_rows,
  n_live_tup as live_rows,
  ROUND(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) as bloat_pct
FROM pg_stat_user_tables
WHERE n_live_tup > 0
ORDER BY n_dead_tup DESC;

-- Manual vacuum to reclaim space
VACUUM FULL users;  -- Rewrites entire table, locks table
VACUUM users;       -- Marks space as reusable, doesn't return to OS
```

### Index Bloat

```sql
-- Estimate index bloat
SELECT 
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) as size,
  idx_scan as scans,
  idx_tup_read as tuples_read,
  idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;

-- Rebuild bloated indexes
REINDEX TABLE users;
REINDEX INDEX idx_users_email;
```

### Data Archival Strategies

**Time-based partitioning for archival:**
```sql
-- Create partitioned table
CREATE TABLE logs (
  id bigserial,
  message text,
  created_at timestamptz NOT NULL
) PARTITION BY RANGE (created_at);

-- Create partitions
CREATE TABLE logs_2024_01 PARTITION OF logs
  FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE logs_2024_02 PARTITION OF logs
  FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Archive old partitions
-- Detach partition
ALTER TABLE logs DETACH PARTITION logs_2024_01;

-- Export to archive
COPY logs_2024_01 TO '/archive/logs_2024_01.csv' WITH CSV HEADER;

-- Drop old partition
DROP TABLE logs_2024_01;
```

**Soft delete for data retention:**
```sql
-- Add deleted_at column
ALTER TABLE users ADD COLUMN deleted_at timestamptz;

-- Create index for active records
CREATE INDEX idx_users_active ON users(id) WHERE deleted_at IS NULL;

-- Soft delete
UPDATE users SET deleted_at = NOW() WHERE id = 'user-id';

-- Periodically hard delete old soft-deleted records
DELETE FROM users 
WHERE deleted_at < NOW() - INTERVAL '90 days';
```

### Compression

**TOAST compression:**
PostgreSQL automatically compresses large values using TOAST (The Oversized-Attribute Storage Technique):

```sql
-- Check TOAST settings
SELECT 
  relname,
  reltoastrelid,
  pg_size_pretty(pg_total_relation_size(reltoastrelid)) as toast_size
FROM pg_class
WHERE reltoastrelid <> 0
ORDER BY pg_total_relation_size(reltoastrelid) DESC;

-- Modify column storage
ALTER TABLE documents ALTER COLUMN content SET STORAGE EXTENDED;  -- Compress + move to TOAST
ALTER TABLE documents ALTER COLUMN content SET STORAGE EXTERNAL;  -- Move to TOAST, no compression
ALTER TABLE documents ALTER COLUMN content SET STORAGE MAIN;      -- Keep inline, compress if needed
```

**Column-level compression (PostgreSQL 14+):**
```sql
-- Use compression for specific column
ALTER TABLE documents ALTER COLUMN content SET COMPRESSION lz4;

-- Check compression method
SELECT 
  attname,
  attcompression
FROM pg_attribute
WHERE attrelid = 'documents'::regclass
  AND attnum > 0;
```

### Data Retention Policies

```sql
-- Create function for data cleanup
CREATE OR REPLACE FUNCTION cleanup_old_data()
RETURNS void AS $$
BEGIN
  -- Delete old logs
  DELETE FROM logs WHERE created_at < NOW() - INTERVAL '30 days';
  
  -- Delete old sessions
  DELETE FROM sessions WHERE expires_at < NOW();
  
  -- Archive old orders
  INSERT INTO archived_orders
  SELECT * FROM orders 
  WHERE created_at < NOW() - INTERVAL '2 years';
  
  DELETE FROM orders 
  WHERE created_at < NOW() - INTERVAL '2 years';
  
  -- Log cleanup activity
  INSERT INTO maintenance_log (activity, executed_at)
  VALUES ('data_cleanup', NOW());
END;
$$ LANGUAGE plpgsql;

-- Schedule cleanup (using pg_cron if available)
-- SELECT cron.schedule('nightly-cleanup', '0 2 * * *', 'SELECT cleanup_old_data()');
```

### Monitoring Growth Trends

```sql
-- Create table to track size over time
CREATE TABLE database_size_history (
  id serial PRIMARY KEY,
  table_name text,
  table_size bigint,
  index_size bigint,
  total_size bigint,
  recorded_at timestamptz DEFAULT NOW()
);

-- Function to record sizes
CREATE OR REPLACE FUNCTION record_table_sizes()
RETURNS void AS $$
BEGIN
  INSERT INTO database_size_history (table_name, table_size, index_size, total_size)
  SELECT 
    tablename,
    pg_relation_size(schemaname||'.'||tablename),
    pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename),
    pg_total_relation_size(schemaname||'.'||tablename)
  FROM pg_tables
  WHERE schemaname = 'public';
END;
$$ LANGUAGE plpgsql;

-- Query growth trends
SELECT 
  table_name,
  pg_size_pretty(MAX(total_size) FILTER (WHERE recorded_at > NOW() - INTERVAL '1 day')) as current_size,
  pg_size_pretty(MAX(total_size) FILTER (WHERE recorded_at > NOW() - INTERVAL '8 days' AND recorded_at < NOW() - INTERVAL '7 days')) as week_ago,
  pg_size_pretty(MAX(total_size) - MIN(total_size)) as growth
FROM database_size_history
WHERE recorded_at > NOW() - INTERVAL '8 days'
GROUP BY table_name
ORDER BY MAX(total_size) DESC;
```

### Storage Optimization Best Practices

**Choose appropriate data types:**
```sql
-- Bad: Wastes space
CREATE TABLE products (
  id text,                    -- UUID as text: 36 bytes
  price numeric(20, 10),      -- Overly precise
  in_stock boolean            -- 1 byte but aligned
);

-- Good: Optimized
CREATE TABLE products (
  id uuid,                    -- UUID type: 16 bytes
  price integer,              -- Cents as integer: 4 bytes
  in_stock boolean
);
```

**Normalize appropriately:**
```sql
-- Denormalized: Repeated data
CREATE TABLE orders (
  id uuid PRIMARY KEY,
  customer_email text,
  customer_name text,
  customer_address text
  -- Customer data repeated in every order
);

-- Normalized: Reference data
CREATE TABLE customers (
  id uuid PRIMARY KEY,
  email text,
  name text,
  address text
);

CREATE TABLE orders (
  id uuid PRIMARY KEY,
  customer_id uuid REFERENCES customers(id)
  -- Reference instead of duplication
);
```

**Use appropriate indexes:**
```sql
-- Remove redundant indexes
-- If you have idx_users_email_name(email, name)
-- Then idx_users_email(email) is redundant

-- Find duplicate indexes
SELECT 
  pg_size_pretty(SUM(pg_relation_size(idx))::bigint) as size,
  (array_agg(idx))[1] as idx1,
  (array_agg(idx))[2] as idx2
FROM (
  SELECT 
    indexrelid::regclass as idx,
    indrelid,
    indkey::text
  FROM pg_index
) sub
GROUP BY indrelid, indkey
HAVING COUNT(*) > 1;
```

**Important related topics:**
- **Vacuum strategies and configuration** - Fine-tuning autovacuum for your workload
- **Query optimization techniques** - Advanced strategies beyond basic indexing
- **Monitoring and alerting setup** - Building comprehensive performance monitoring
- **Connection pool tuning** - Optimizing pool parameters for your specific needs
- **Performance testing methodologies** - Load testing and benchmarking approaches

---

