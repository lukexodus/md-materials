## Connection Pooling


Connection pooling manages database connections efficiently by reusing existing connections rather than creating new ones for each request.

### Why Connection Pooling Matters

Each PostgreSQL connection consumes memory and CPU. Creating connections is expensive:

- Connection overhead: ~10-50ms per connection
- Memory per connection: ~2-10MB
- PostgreSQL has connection limits

Without pooling, high-traffic applications quickly exhaust available connections or waste resources constantly creating/destroying connections.

### Supabase Connection Pooling

Supabase provides built-in connection pooling through PgBouncer with two modes:

**Transaction Mode (Recommended)**

```javascript
// Connection string format
const connectionString = 'postgresql://postgres:[PASSWORD]@[PROJECT_REF].pooler.supabase.com:6543/postgres'

// Using with Supabase client
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://[PROJECT_REF].supabase.co',
  '[ANON_KEY]'
)
```

Transaction mode releases connections after each transaction, allowing maximum connection reuse. [Inference] This mode is suitable for most serverless and API applications.

**Session Mode**

```javascript
// Port 5432 for session mode
const connectionString = 'postgresql://postgres:[PASSWORD]@[PROJECT_REF].pooler.supabase.com:5432/postgres'
```

Session mode maintains connection for entire client session. Required for:

- Prepared statements
- Advisory locks
- Listen/Notify
- Temporary tables

### Connection Pool Configuration

```javascript
// Using postgres.js with pooling
import postgres from 'postgres'

const sql = postgres(connectionString, {
  max: 10,                    // Maximum pool size
  idle_timeout: 20,           // Seconds before idle connection closed
  connect_timeout: 10,        // Seconds to wait for connection
  max_lifetime: 60 * 30,      // Maximum connection lifetime (30 min)
})
```

### Pool Size Recommendations

[Inference] Calculate appropriate pool size:

- **Formula**: `connections = ((core_count * 2) + effective_spindle_count)`
- **Serverless**: 1-5 connections per function instance
- **Traditional servers**: 10-20 connections per application server
- **Total**: Sum of all applications should not exceed PostgreSQL's `max_connections`

```sql
-- Check current connection limit
SHOW max_connections;

-- Monitor active connections
SELECT 
  COUNT(*) as total_connections,
  COUNT(*) FILTER (WHERE state = 'active') as active,
  COUNT(*) FILTER (WHERE state = 'idle') as idle,
  COUNT(*) FILTER (WHERE state = 'idle in transaction') as idle_in_transaction
FROM pg_stat_activity
WHERE datname = current_database();

-- View connections by application
SELECT 
  application_name,
  state,
  COUNT(*)
FROM pg_stat_activity
WHERE datname = current_database()
GROUP BY application_name, state
ORDER BY COUNT(*) DESC;
```

### Connection Pooling Anti-patterns

**Avoid:**

```javascript
// BAD: Creating new pool for each request
app.get('/users', async (req, res) => {
  const pool = new Pool({ connectionString })  // Don't do this!
  const result = await pool.query('SELECT * FROM users')
  await pool.end()
  res.json(result.rows)
})

// BAD: Not releasing connections
const client = await pool.connect()
await client.query('SELECT * FROM users')
// Missing: client.release()
```

**Correct approach:**

```javascript
// GOOD: Reuse pool instance
const pool = new Pool({ connectionString })

app.get('/users', async (req, res) => {
  const result = await pool.query('SELECT * FROM users')
  res.json(result.rows)
})

// GOOD: Always release connections
const client = await pool.connect()
try {
  await client.query('BEGIN')
  await client.query('INSERT INTO users ...')
  await client.query('COMMIT')
} catch (e) {
  await client.query('ROLLBACK')
  throw e
} finally {
  client.release()  // Always release
}
```

### Monitoring Connection Pool Health

```sql
-- Create monitoring function
CREATE OR REPLACE FUNCTION get_connection_stats()
RETURNS TABLE(
  total_connections bigint,
  active_connections bigint,
  idle_connections bigint,
  idle_in_transaction bigint,
  waiting_connections bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*),
    COUNT(*) FILTER (WHERE state = 'active'),
    COUNT(*) FILTER (WHERE state = 'idle'),
    COUNT(*) FILTER (WHERE state = 'idle in transaction'),
    COUNT(*) FILTER (WHERE wait_event_type IS NOT NULL)
  FROM pg_stat_activity
  WHERE datname = current_database();
END;
$$ LANGUAGE plpgsql;

-- Check for connection leaks (idle in transaction)
SELECT 
  pid,
  usename,
  application_name,
  state,
  NOW() - state_change as duration,
  query
FROM pg_stat_activity
WHERE state = 'idle in transaction'
  AND NOW() - state_change > INTERVAL '5 minutes';
```

