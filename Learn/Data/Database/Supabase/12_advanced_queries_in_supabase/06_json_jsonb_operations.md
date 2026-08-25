## JSON/JSONB Operations


PostgreSQL's JSONB type enables efficient storage and querying of JSON data with indexing support.

### Querying JSON Fields

```javascript
// Select specific JSON field
const { data, error } = await supabase
  .from('users')
  .select('id, metadata->phone')
  .eq('metadata->country', 'US')

// Deep nested access
const { data, error } = await supabase
  .from('products')
  .select('name')
  .eq('specs->dimensions->weight', '500g')
```

### JSON Operators in SQL

```sql
-- Extract field as text
SELECT metadata->>'name' as name FROM users;

-- Extract nested path
SELECT metadata#>>'{address,city}' as city FROM users;

-- Check key existence
SELECT * FROM users WHERE metadata ? 'premium';

-- Check multiple keys
SELECT * FROM users WHERE metadata ?& ARRAY['email', 'phone'];

-- Check any key exists
SELECT * FROM users WHERE metadata ?| ARRAY['email', 'phone'];
```

### JSON Aggregation

```sql
-- Build JSON object
SELECT json_build_object(
  'id', id,
  'name', name,
  'orders', (
    SELECT json_agg(json_build_object('id', id, 'total', total))
    FROM orders
    WHERE customer_id = customers.id
  )
) as customer_data
FROM customers;

-- JSONB aggregation
SELECT 
  category,
  jsonb_agg(jsonb_build_object(
    'name', name,
    'price', price
  )) as products
FROM products
GROUP BY category;
```

### Updating JSONB

```sql
-- Add/update field
UPDATE users 
SET metadata = jsonb_set(metadata, '{last_login}', '"2025-10-04"');

-- Remove field
UPDATE users 
SET metadata = metadata - 'temporary_token';

-- Concatenate
UPDATE users 
SET metadata = metadata || '{"verified": true}'::jsonb;
```

### JSONB Indexing

```sql
-- GIN index for containment operations
CREATE INDEX idx_metadata_gin ON users USING GIN (metadata);

-- Index specific path
CREATE INDEX idx_metadata_country ON users ((metadata->>'country'));
```

