## Read Replicas


[Unverified] Read replicas are available in Supabase's Pro and Enterprise plans. They provide horizontally scaled read capacity by replicating data from the primary database to one or more replica databases.

### Read Replica Benefits

- Distribute read load across multiple databases
- Reduce load on primary database
- Improve query performance for read-heavy workloads
- Geographic distribution for lower latency
- Dedicated resources for analytics or reporting

### Using Read Replicas

```javascript
// Primary connection (reads and writes)
const supabasePrimary = createClient(PRIMARY_URL, ANON_KEY)

// Read replica connection (reads only)
const supabaseReplica = createClient(REPLICA_URL, ANON_KEY)

// Write to primary
await supabasePrimary
  .from('users')
  .insert({ email: 'new@example.com' })

// Read from replica
const { data } = await supabaseReplica
  .from('users')
  .select('*')
  .limit(100)
```

### Replication Lag Considerations

[Inference] Read replicas operate asynchronously, meaning there's typically a small delay (replication lag) between writes to primary and visibility on replicas:

```javascript
// Handle replication lag
async function createAndVerify(data) {
  // Write to primary
  const { data: created } = await supabasePrimary
    .from('users')
    .insert(data)
    .select()
    .single()
  
  // Read from primary immediately after write
  // to avoid replication lag issues
  const { data: verified } = await supabasePrimary
    .from('users')
    .select('*')
    .eq('id', created.id)
    .single()
  
  return verified
}

// For non-critical reads, use replica
async function getUsers(filters) {
  return await supabaseReplica
    .from('users')
    .select('*')
    .match(filters)
}
```

### Read Replica Patterns

**Pattern 1: Route by operation type**
```javascript
class DatabaseRouter {
  constructor(primary, replica) {
    this.primary = primary
    this.replica = replica
  }
  
  async read(table, query) {
    return await this.replica.from(table).select(query)
  }
  
  async write(table, data) {
    return await this.primary.from(table).insert(data)
  }
  
  async update(table, id, data) {
    return await this.primary.from(table).update(data).eq('id', id)
  }
}
```

**Pattern 2: Dedicated analytics queries**
```javascript
// Heavy analytics on replica to avoid affecting primary
async function getAnalyticsReport() {
  const { data } = await supabaseReplica.rpc('generate_sales_report', {
    start_date: '2024-01-01',
    end_date: '2024-12-31'
  })
  
  return data
}
```

**Pattern 3: Geographic distribution**
```javascript
// Use replica closest to user
const getUserRegion = (userLocation) => {
  // Determine nearest replica based on user location
}

const replicaUrl = getUserRegion(userLocation)
const supabase = createClient(replicaUrl, ANON_KEY)
```

### Monitoring Replication

```sql
-- Check replication lag (on primary)
SELECT 
  client_addr,
  state,
  sent_lsn,
  write_lsn,
  flush_lsn,
  replay_lsn,
  sync_state,
  pg_wal_lsn_diff(sent_lsn, replay_lsn) as lag_bytes
FROM pg_stat_replication;

-- Monitor replication slots
SELECT 
  slot_name,
  slot_type,
  active,
  pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) as retained_bytes
FROM pg_replication_slots;
```

