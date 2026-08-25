## Data Migrations


Data migrations transform or move data within databases, distinct from schema migrations that alter structure. They handle data cleanup, format changes, and bulk updates.

**Simple data updates:**

```sql
-- Update existing records to new format
UPDATE users 
SET email = LOWER(TRIM(email))
WHERE email != LOWER(TRIM(email));

-- Populate new column from existing data
UPDATE products
SET slug = LOWER(REGEXP_REPLACE(name, '[^a-zA-Z0-9]+', '-', 'g'))
WHERE slug IS NULL;
```

**Conditional data migrations:**

```sql
-- Migrate data only for specific conditions
UPDATE orders
SET shipping_cost = 0
WHERE total_amount > 100 AND shipping_cost IS NULL;

-- Set default values based on existing data
UPDATE users
SET subscription_tier = CASE
  WHEN total_purchases > 1000 THEN 'premium'
  WHEN total_purchases > 100 THEN 'standard'
  ELSE 'basic'
END
WHERE subscription_tier IS NULL;
```

**Batch processing for large datasets:**

```sql
-- Process data in batches to avoid long locks
DO $$
DECLARE
  batch_size INTEGER := 1000;
  processed INTEGER := 0;
  total INTEGER;
BEGIN
  SELECT COUNT(*) INTO total FROM users WHERE legacy_field IS NOT NULL;
  
  LOOP
    UPDATE users
    SET new_field = TRANSFORM_FUNCTION(legacy_field)
    WHERE id IN (
      SELECT id FROM users 
      WHERE legacy_field IS NOT NULL 
      LIMIT batch_size
    );
    
    processed := processed + batch_size;
    
    EXIT WHEN NOT FOUND OR processed >= total;
    
    -- Add delay between batches to reduce load
    PERFORM pg_sleep(0.1);
  END LOOP;
END $$;
```

**Moving data between tables:**

```sql
-- Migrate data to new normalized structure
INSERT INTO addresses (user_id, street, city, country)
SELECT 
  id,
  address_street,
  address_city,
  address_country
FROM users
WHERE address_street IS NOT NULL;

-- Update foreign key references
UPDATE users u
SET address_id = a.id
FROM addresses a
WHERE a.user_id = u.id;
```

**Data transformation migrations:**

```sql
-- Convert JSON column to separate fields
ALTER TABLE products ADD COLUMN price DECIMAL(10,2);
ALTER TABLE products ADD COLUMN currency TEXT;

UPDATE products
SET 
  price = (metadata->>'price')::DECIMAL,
  currency = metadata->>'currency'
WHERE metadata IS NOT NULL;
```

**Aggregating data:**

```sql
-- Create summary records from detailed data
INSERT INTO monthly_sales_summary (year, month, total_revenue, order_count)
SELECT 
  EXTRACT(YEAR FROM created_at) AS year,
  EXTRACT(MONTH FROM created_at) AS month,
  SUM(total_amount) AS total_revenue,
  COUNT(*) AS order_count
FROM orders
WHERE created_at >= '2024-01-01'
GROUP BY EXTRACT(YEAR FROM created_at), EXTRACT(MONTH FROM created_at)
ON CONFLICT (year, month) DO UPDATE SET
  total_revenue = EXCLUDED.total_revenue,
  order_count = EXCLUDED.order_count;
```

**Deduplication migrations:**

```sql
-- Remove duplicate records, keeping the newest
DELETE FROM products
WHERE id NOT IN (
  SELECT DISTINCT ON (sku) id
  FROM products
  ORDER BY sku, created_at DESC
);

-- Or using window functions
DELETE FROM products
WHERE id IN (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY sku ORDER BY created_at DESC) AS rn
    FROM products
  ) t
  WHERE rn > 1
);
```

**Data validation after migration:**

```sql
-- Verify migration results
DO $$
DECLARE
  invalid_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO invalid_count
  FROM users
  WHERE email NOT LIKE '%@%';
  
  IF invalid_count > 0 THEN
    RAISE EXCEPTION 'Data migration failed: % invalid emails found', invalid_count;
  END IF;
END $$;
```

**Backfilling with data enrichment:**

```sql
-- Enrich existing records with calculated values
UPDATE products
SET 
  search_vector = to_tsvector('english', name || ' ' || COALESCE(description, '')),
  popularity_score = (
    SELECT COUNT(*) FROM order_items WHERE product_id = products.id
  )
WHERE search_vector IS NULL;
```

**Safe data removal:**

```sql
-- Soft delete before hard delete
UPDATE users 
SET deleted_at = NOW()
WHERE last_login < NOW() - INTERVAL '2 years'
  AND deleted_at IS NULL;

-- After verification period, hard delete
DELETE FROM users
WHERE deleted_at < NOW() - INTERVAL '90 days';
```

