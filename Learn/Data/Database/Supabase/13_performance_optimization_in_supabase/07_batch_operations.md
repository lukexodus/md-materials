## Batch Operations


Batch operations process multiple records in single queries, dramatically improving performance over iterative operations.

### Batch Inserts

```javascript
// BAD: Individual inserts
for (const user of users) {
  await supabase
    .from('users')
    .insert({ email: user.email, name: user.name })
}

// GOOD: Batch insert
await supabase
  .from('users')
  .insert(users.map(u => ({ email: u.email, name: u.name })))
```

```sql
-- SQL batch insert
INSERT INTO users (email, name, role)
VALUES 
  ('user1@example.com', 'User One', 'member'),
  ('user2@example.com', 'User Two', 'member'),
  ('user3@example.com', 'User Three', 'admin')
ON CONFLICT (email) DO UPDATE
SET name = EXCLUDED.name, role = EXCLUDED.role;
```

### Batch Updates

```javascript
// BAD: Individual updates
for (const orderId of orderIds) {
  await supabase
    .from('orders')
    .update({ status: 'shipped' })
    .eq('id', orderId)
}

// GOOD: Batch update
await supabase
  .from('orders')
  .update({ status: 'shipped' })
  .in('id', orderIds)
```

```sql
-- SQL batch update with CASE
UPDATE products
SET price = CASE id
  WHEN '550e8400-e29b-41d4-a716-446655440001' THEN 99.99
  WHEN '550e8400-e29b-41d4-a716-446655440002' THEN 149.99
  WHEN '550e8400-e29b-41d4-a716-446655440003' THEN 199.99
END
WHERE id IN (
  '550e8400-e29b-41d4-a716-446655440001',
  '550e8400-e29b-41d4-a716-446655440002',
  '550e8400-e29b-41d4-a716-446655440003'
);

-- Update from temporary table
CREATE TEMP TABLE price_updates (
  product_id uuid,
  new_price numeric
);

INSERT INTO price_updates VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 99.99),
  ('550e8400-e29b-41d4-a716-446655440002', 149.99);

UPDATE products p
SET price = pu.new_price
FROM price_updates pu
WHERE p.id = pu.product_id;
```

### Batch Deletes

```javascript
// BAD: Individual deletes
for (const id of idsToDelete) {
  await supabase
    .from('old_records')
    .delete()
    .eq('id', id)
}

// GOOD: Batch delete
await supabase
  .from('old_records')
  .delete()
  .in('id', idsToDelete)
```

```sql
-- SQL batch delete
DELETE FROM logs
WHERE created_at < NOW() - INTERVAL '90 days';

-- Batch delete with JOIN
DELETE FROM order_items oi
USING orders o
WHERE oi.order_id = o.id
  AND o.status = 'cancelled'
  AND o.created_at < NOW() - INTERVAL '30 days';
```

### COPY for Bulk Data Loading

```sql
-- Most efficient for large data imports
COPY users (email, name, created_at)
FROM '/path/to/users.csv'
WITH (FORMAT csv, HEADER true);

-- Or from program
COPY users (email, name)
FROM STDIN
WITH (FORMAT csv);
```

```javascript
// Using node-postgres COPY
import { pipeline } from 'stream'
import { from as copyFrom } from 'pg-copy-streams'

const client = await pool.connect()
const stream = client.query(copyFrom('COPY users (email, name) FROM STDIN CSV'))

const dataStream = /* your data source stream */
await pipeline(dataStream, stream)
client.release()
```

### Batch Processing Patterns

**Chunked processing:**
```javascript
// Process large dataset in chunks
async function processBatchInChunks(items, chunkSize = 1000) {
  for (let i = 0; i < items.length; i += chunkSize) {
    const chunk = items.slice(i, i + chunkSize)
    
    await supabase
      .from('table')
      .insert(chunk)
    
    console.log(`Processed ${i + chunk.length} of ${items.length}`)
  }
}
```

**Parallel batch operations:**
```javascript
// Process multiple batches concurrently
async function parallelBatchProcess(items, batchSize = 1000, concurrency = 5) {
  const batches = []
  for (let i = 0; i < items.length; i += batchSize) {
    batches.push(items.slice(i, i + batchSize))
  }
  
  // Process batches with limited concurrency
  for (let i = 0; i < batches.length; i += concurrency) {
    const batchGroup = batches.slice(i, i + concurrency)
    
    await Promise.all(
      batchGroup.map(batch =>
        supabase.from('table').insert(batch)
      )
    )
    
    console.log(`Completed ${Math.min(i + concurrency, batches.length)} of ${batches.length} batches`)
  }
}
```

### Batch Upsert (Insert or Update)

```javascript
// Supabase batch upsert
await supabase
  .from('products')
  .upsert(
    products.map(p => ({
      id: p.id,
      name: p.name,
      price: p.price,
      updated_at: new Date().toISOString()
    })),
    { onConflict: 'id' }
  )
```

```sql
-- SQL upsert with DO UPDATE
INSERT INTO products (id, name, price, stock)
VALUES 
  ('prod-1', 'Product 1', 99.99, 100),
  ('prod-2', 'Product 2', 149.99, 50)
ON CONFLICT (id) DO UPDATE
SET 
  name = EXCLUDED.name,
  price = EXCLUDED.price,
  stock = products.stock + EXCLUDED.stock,
  updated_at = NOW();
```

### Using UNNEST for Batch Operations

```sql
-- Batch insert using UNNEST
INSERT INTO users (email, name, role)
SELECT * FROM UNNEST(
  ARRAY['user1@example.com', 'user2@example.com', 'user3@example.com'],
  ARRAY['User One', 'User Two', 'User Three'],
  ARRAY['member', 'member', 'admin']
) AS t(email, name, role);

-- Batch update using UNNEST
UPDATE products p
SET price = u.new_price
FROM UNNEST(
  ARRAY['prod-1', 'prod-2', 'prod-3']::uuid[],
  ARRAY[99.99, 149.99, 199.99]::numeric[]
) AS u(product_id, new_price)
WHERE p.id = u.product_id;
```

### Batch Performance Comparison

```sql
-- Measure batch vs individual operations
DO $$
DECLARE
  start_time timestamp;
  end_time timestamp;
  i integer;
BEGIN
  -- Individual inserts
  start_time := clock_timestamp();
  FOR i IN 1..1000 LOOP
    INSERT INTO test_table (value) VALUES (i);
  END LOOP;
  end_time := clock_timestamp();
  RAISE NOTICE 'Individual inserts: %', end_time - start_time;
  
  -- Batch insert
  start_time := clock_timestamp();
  INSERT INTO test_table (value)
  SELECT generate_series(1001, 2000);
  end_time := clock_timestamp();
  RAISE NOTICE 'Batch insert: %', end_time - start_time;
END $$;
```

[Inference] Batch operations are typically 10-100x faster than individual operations, depending on network latency, transaction overhead, and data size.

