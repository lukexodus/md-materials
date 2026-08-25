## Query Performance Analysis


Query performance analysis involves identifying slow queries, understanding their execution characteristics, and determining optimization opportunities.

### Identifying Slow Queries

PostgreSQL tracks query statistics through the `pg_stat_statements` extension. In Supabase, you can enable and query this extension to find performance bottlenecks.

```sql
-- Enable pg_stat_statements (may require admin privileges)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Find slowest queries by total time
SELECT 
  query,
  calls,
  total_exec_time,
  mean_exec_time,
  max_exec_time,
  stddev_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- Find queries with highest average execution time
SELECT 
  query,
  calls,
  mean_exec_time,
  total_exec_time
FROM pg_stat_statements
WHERE calls > 100
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Find queries called most frequently
SELECT 
  query,
  calls,
  total_exec_time,
  mean_exec_time
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 20;
```

### Monitoring Query Patterns

```sql
-- Analyze queries by pattern
SELECT 
  LEFT(query, 50) as query_start,
  COUNT(*) as similar_queries,
  SUM(calls) as total_calls,
  AVG(mean_exec_time) as avg_execution_time
FROM pg_stat_statements
GROUP BY LEFT(query, 50)
ORDER BY avg_execution_time DESC;

-- Check cache hit ratio
SELECT 
  SUM(blks_hit) as cache_hits,
  SUM(blks_read) as disk_reads,
  SUM(blks_hit) / NULLIF(SUM(blks_hit) + SUM(blks_read), 0) * 100 as cache_hit_ratio
FROM pg_stat_database
WHERE datname = current_database();
```

### Query Timing

```sql
-- Enable timing for individual queries
\timing on

-- Measure specific query execution
SELECT COUNT(*) FROM users WHERE created_at > NOW() - INTERVAL '30 days';

-- Use pg_stat_statements for aggregate timing
SELECT 
  calls,
  total_exec_time / 1000.0 as total_seconds,
  mean_exec_time as avg_milliseconds,
  query
FROM pg_stat_statements
WHERE query ILIKE '%users%'
ORDER BY total_exec_time DESC;
```

