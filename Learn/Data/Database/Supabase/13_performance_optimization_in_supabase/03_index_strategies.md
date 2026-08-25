## Index Strategies


Indexes are data structures that improve query performance by allowing rapid data lookup. Proper indexing is critical for database performance.

### When to Create Indexes

**Create indexes for:**

- Columns frequently used in WHERE clauses
- Foreign key columns used in JOINs
- Columns used in ORDER BY or GROUP BY
- Columns with high cardinality (many distinct values)

**Avoid indexes for:**

- Small tables (under a few thousand rows)
- Columns with low cardinality (few distinct values like boolean fields)
- Columns rarely queried
- Tables with frequent writes and rare reads

### B-tree Indexes (Default)

Standard index type for most operations: equality, range queries, sorting.

```sql
-- Single column index
CREATE INDEX idx_users_email ON users(email);

-- Composite index (column order matters)
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at);

-- Partial index (indexes subset of rows)
CREATE INDEX idx_active_users ON users(email) 
WHERE is_active = true AND deleted_at IS NULL;

-- Expression index
CREATE INDEX idx_users_lower_email ON users(LOWER(email));

-- Index with sort order
CREATE INDEX idx_posts_published_desc ON posts(published_at DESC);
```

### Composite Index Column Order

Column order in composite indexes significantly impacts effectiveness:

```sql
-- Good: Most selective column first
CREATE INDEX idx_orders_status_user_date ON orders(user_id, status, created_at);

-- This index efficiently supports:
SELECT * FROM orders WHERE user_id = 123;  -- Uses index
SELECT * FROM orders WHERE user_id = 123 AND status = 'pending';  -- Uses index
SELECT * FROM orders WHERE user_id = 123 AND status = 'pending' AND created_at > '2024-01-01';  -- Uses index

-- But NOT:
SELECT * FROM orders WHERE status = 'pending';  -- Cannot use index efficiently
SELECT * FROM orders WHERE created_at > '2024-01-01';  -- Cannot use index efficiently
```

**Rule of thumb:** Order columns by selectivity (most selective first) and query pattern frequency.

### Specialized Index Types

**GIN (Generalized Inverted Index)**

For full-text search, JSONB, arrays:

```sql
-- JSONB index
CREATE INDEX idx_users_metadata ON users USING GIN(metadata);

-- Query
SELECT * FROM users WHERE metadata @> '{"role": "admin"}';

-- Array index
CREATE INDEX idx_tags ON posts USING GIN(tags);

-- Query
SELECT * FROM posts WHERE tags @> ARRAY['postgresql', 'database'];

-- Full-text search
CREATE INDEX idx_posts_search ON posts USING GIN(to_tsvector('english', title || ' ' || content));

-- Query
SELECT * FROM posts 
WHERE to_tsvector('english', title || ' ' || content) @@ to_tsquery('postgresql & performance');
```

**GiST (Generalized Search Tree)**

For geometric data, full-text search, range types:

```sql
-- Range types
CREATE INDEX idx_event_timerange ON events USING GIST(time_range);

-- Query
SELECT * FROM events 
WHERE time_range && tstzrange('2024-01-01', '2024-01-31');

-- Geometric data
CREATE INDEX idx_locations_point ON locations USING GIST(coordinates);
```

**BRIN (Block Range Index)**

For very large tables with naturally ordered data:

```sql
-- Efficient for time-series or sequential data
CREATE INDEX idx_logs_timestamp ON logs USING BRIN(created_at);

-- Much smaller than B-tree but less precise
-- Good for append-only tables with hundreds of millions of rows
```

**Hash Indexes**

For equality comparisons only (rarely used):

```sql
-- Only supports = operator
CREATE INDEX idx_hash_user_id ON sessions USING HASH(user_id);
```

[Unverified] Hash indexes may have limitations compared to B-tree indexes in terms of recovery and replication in some PostgreSQL configurations.

### Index Maintenance

```sql
-- View index usage statistics
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan as index_scans,
  idx_tup_read as tuples_read,
  idx_tup_fetch as tuples_fetched,
  pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

-- Find unused indexes
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,
  pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexname NOT LIKE 'pg_toast%'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Check index bloat
SELECT 
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;

-- Rebuild bloated index
REINDEX INDEX idx_name;

-- Rebuild all indexes on a table
REINDEX TABLE table_name;
```

### Covering Indexes

Include additional columns to enable index-only scans:

```sql
-- Without covering
CREATE INDEX idx_orders_user ON orders(user_id);
SELECT user_id, total FROM orders WHERE user_id = 123;
-- Requires table access for 'total'

-- With covering (INCLUDE clause)
CREATE INDEX idx_orders_user_covering ON orders(user_id) INCLUDE (total, created_at);
SELECT user_id, total, created_at FROM orders WHERE user_id = 123;
-- Index-only scan possible
```

### Partial Indexes

Index only relevant rows to save space and improve performance:

```sql
-- Index only active users
CREATE INDEX idx_active_users_email ON users(email) 
WHERE is_active = true;

-- Index only recent orders
CREATE INDEX idx_recent_orders ON orders(user_id, created_at)
WHERE created_at > NOW() - INTERVAL '90 days';

-- Index only unpaid invoices
CREATE INDEX idx_unpaid_invoices ON invoices(user_id)
WHERE status = 'unpaid';
```

### Index Monitoring Best Practices

```sql
-- Create monitoring query for regular execution
WITH index_stats AS (
  SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    pg_size_pretty(pg_relation_size(indexrelid)) as size,
    pg_relation_size(indexrelid) as size_bytes
  FROM pg_stat_user_indexes
)
SELECT 
  *,
  CASE 
    WHEN idx_scan = 0 THEN 'UNUSED'
    WHEN idx_scan < 100 THEN 'RARELY_USED'
    ELSE 'ACTIVE'
  END as usage_category
FROM index_stats
WHERE size_bytes > 1000000  -- Larger than 1MB
ORDER BY idx_scan ASC, size_bytes DESC;
```

