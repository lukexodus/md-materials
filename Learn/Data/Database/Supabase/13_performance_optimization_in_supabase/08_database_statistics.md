## Database Statistics


PostgreSQL maintains statistics about table contents to help the query planner make optimal decisions. Accurate statistics are essential for good query performance.

### Understanding Statistics

```sql
-- View table statistics
SELECT 
  schemaname,
  tablename,
  n_live_tup as live_rows,
  n_dead_tup as dead_rows,
  n_mod_since_analyze as modifications_since_analyze,
  last_vacuum,
  last_autovacuum,
  last_analyze,
  last_autoanalyze
FROM pg_stat_user_tables
ORDER BY n_mod_since_analyze DESC;

-- View column statistics
SELECT 
  tablename,
  attname as column_name,
  n_distinct,
  correlation,
  most_common_vals,
  most_common_freqs
FROM pg_stats
WHERE schemaname = 'public'
  AND tablename = 'users';
```

### Manual Statistics Update

```sql
-- Analyze specific table
ANALYZE users;

-- Analyze specific columns
ANALYZE users (email, created_at);

-- Analyze all tables
ANALYZE;

-- Verbose analyze (shows detailed info)
ANALYZE VERBOSE users;
```

### Autovacuum and Autoanalyze

PostgreSQL automatically runs VACUUM and ANALYZE through the autovacuum daemon:

```sql
-- Check autovacuum settings
SHOW autovacuum;
SHOW autovacuum_analyze_threshold;
SHOW autovacuum_analyze_scale_factor;

-- View autovacuum activity
SELECT 
  schemaname,
  tablename,
  last_autovacuum,
  last_autoanalyze,
  n_dead_tup,
  n_mod_since_analyze
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY last_autoanalyze ASC NULLS FIRST;
```

### Statistics Configuration

```sql
-- Adjust statistics target for specific columns
ALTER TABLE users ALTER COLUMN email SET STATISTICS 1000;
-- Default is 100, higher = more accurate but slower ANALYZE

-- Reset to default
ALTER TABLE users ALTER COLUMN email SET STATISTICS -1;

-- Set statistics target for entire table
ALTER TABLE users SET (autovacuum_analyze_scale_factor = 0.05);
```

### Monitoring Statistics Staleness

```sql
-- Find tables with stale statistics
SELECT 
  schemaname,
  tablename,
  n_live_tup as rows,
  n_mod_since_analyze as changes_since_analyze,
  ROUND(100.0 * n_mod_since_analyze / NULLIF(n_live_tup, 0), 2) as pct_changed,
  last_autoanalyze
FROM pg_stat_user_tables
WHERE n_live_tup > 1000
  AND n_mod_since_analyze > n_live_tup * 0.1
ORDER BY n_mod_since_analyze DESC;
```

### Statistics and Query Planning

```sql
-- See how statistics affect query plans
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM users WHERE created_at > NOW() - INTERVAL '7 days';

-- Check if planner estimates are accurate
-- Compare "rows=X" (estimate) vs "actual rows=Y"

-- If estimates are way off, analyze the table
ANALYZE users;

-- Rerun explain to see improved estimates
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM users WHERE created_at > NOW() - INTERVAL '7 days';
```

### Extended Statistics

For correlated columns, create extended statistics:

```sql
-- Create extended statistics for correlated columns
CREATE STATISTICS users_city_state_stats (dependencies)
ON city, state FROM users;

-- Create multivariate statistics
CREATE STATISTICS products_category_price_stats (ndistinct, dependencies)
ON category_id, price FROM products;

-- Analyze to populate extended statistics
ANALYZE users;
ANALYZE products;

-- View extended statistics
SELECT * FROM pg_statistic_ext;
```

[Inference] Extended statistics help the planner understand correlations between columns, improving estimates for multi-column WHERE clauses.

