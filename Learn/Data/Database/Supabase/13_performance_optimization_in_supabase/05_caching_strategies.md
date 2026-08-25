## Caching Strategies


Caching reduces database load by storing frequently accessed data in faster storage layers.

### Application-Level Caching

**In-memory caching with Redis/Upstash:**

```javascript
import { createClient } from '@supabase/supabase-js'
import Redis from 'ioredis'

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)
const redis = new Redis(REDIS_URL)

async function getUser(userId) {
  // Check cache first
  const cached = await redis.get(`user:${userId}`)
  if (cached) {
    return JSON.parse(cached)
  }
  
  // Cache miss: fetch from database
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('id', userId)
    .single()
  
  if (data) {
    // Cache for 5 minutes
    await redis.setex(`user:${userId}`, 300, JSON.stringify(data))
  }
  
  return data
}
```

**Cache invalidation:**

```javascript
// Invalidate on update
async function updateUser(userId, updates) {
  const { data, error } = await supabase
    .from('users')
    .update(updates)
    .eq('id', userId)
    .select()
    .single()
  
  if (data) {
    // Invalidate cache
    await redis.del(`user:${userId}`)
    // Or update cache
    await redis.setex(`user:${userId}`, 300, JSON.stringify(data))
  }
  
  return data
}
```

### Query Result Caching

```javascript
// Cache expensive queries
async function getDashboardStats(userId) {
  const cacheKey = `dashboard:${userId}`
  const cached = await redis.get(cacheKey)
  
  if (cached) return JSON.parse(cached)
  
  // Expensive aggregation query
  const { data } = await supabase.rpc('get_dashboard_stats', { 
    p_user_id: userId 
  })
  
  // Cache for 15 minutes
  await redis.setex(cacheKey, 900, JSON.stringify(data))
  return data
}
```

### PostgreSQL Built-in Caching

PostgreSQL maintains several cache layers automatically:

**Shared Buffer Cache:**

```sql
-- Check cache hit ratio (should be > 99%)
SELECT 
  SUM(heap_blks_read) as heap_read,
  SUM(heap_blks_hit) as heap_hit,
  SUM(heap_blks_hit) / (SUM(heap_blks_hit) + SUM(heap_blks_read)) * 100 as cache_hit_ratio
FROM pg_statio_user_tables;

-- View cached table data
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
  heap_blks_hit,
  heap_blks_read,
  heap_blks_hit::float / NULLIF((heap_blks_hit + heap_blks_read), 0) * 100 as hit_ratio
FROM pg_statio_user_tables
ORDER BY heap_blks_read DESC
LIMIT 20;
```

### Materialized Views

Materialized views cache complex query results:

```sql
-- Create materialized view
CREATE MATERIALIZED VIEW user_order_summary AS
SELECT 
  u.id,
  u.email,
  COUNT(o.id) as total_orders,
  SUM(o.total) as total_spent,
  MAX(o.created_at) as last_order_date,
  AVG(o.total) as avg_order_value
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.email;

-- Create index on materialized view
CREATE INDEX idx_mv_user_order_summary ON user_order_summary(id);

-- Query materialized view (fast)
SELECT * FROM user_order_summary WHERE id = '123';

-- Refresh materialized view
REFRESH MATERIALIZED VIEW user_order_summary;

-- Refresh without locking (allows concurrent reads)
REFRESH MATERIALIZED VIEW CONCURRENTLY user_order_summary;
```

**Automated refresh:**

```sql
-- Create function to refresh materialized view
CREATE OR REPLACE FUNCTION refresh_user_summary()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY user_order_summary;
END;
$$ LANGUAGE plpgsql;

-- Schedule using pg_cron extension (if available)
-- SELECT cron.schedule('refresh-user-summary', '*/30 * * * *', 'SELECT refresh_user_summary()');
```

[Unverified] pg_cron availability may vary depending on Supabase plan and configuration.

### Cache Warming

```sql
-- Preload frequently accessed data into cache
SELECT pg_prewarm('users');
SELECT pg_prewarm('orders');

-- Check what's in cache
SELECT 
  c.relname,
  count(*) AS buffers,
  pg_size_pretty(count(*) * 8192) as size
FROM pg_buffercache b
INNER JOIN pg_class c ON b.relfilenode = pg_relation_filenode(c.oid)
WHERE b.reldatabase IN (0, (SELECT oid FROM pg_database WHERE datname = current_database()))
GROUP BY c.relname
ORDER BY count(*) DESC
LIMIT 20;
```

### Caching Best Practices

**Cache appropriate data:**

- Reference data that changes infrequently
- Expensive computed results
- Frequently accessed user data
- API responses

**Avoid caching:**

- Data requiring real-time accuracy
- User-specific sensitive data (without proper encryption)
- Data that changes frequently relative to cache duration

**Set appropriate TTLs:**

```javascript
const CACHE_DURATIONS = {
  STATIC_DATA: 3600,      // 1 hour
  USER_PROFILE: 300,      // 5 minutes
  DASHBOARD_STATS: 900,   // 15 minutes
  SEARCH_RESULTS: 60,     // 1 minute
}
```

