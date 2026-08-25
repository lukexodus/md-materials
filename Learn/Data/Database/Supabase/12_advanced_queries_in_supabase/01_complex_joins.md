## Complex Joins


Joins combine data from multiple tables based on related columns. Supabase supports all PostgreSQL join types through both the JavaScript client and direct SQL.

### Inner Joins

```javascript
const { data, error } = await supabase
  .from('orders')
  .select(`
    id,
    total,
    customers (
      name,
      email
    )
  `)
```

### Multiple Table Joins

```javascript
const { data, error } = await supabase
  .from('order_items')
  .select(`
    quantity,
    orders (
      id,
      order_date,
      customers (
        name
      )
    ),
    products (
      name,
      price
    )
  `)
```

### Left/Right Joins via RPC

```sql
CREATE OR REPLACE FUNCTION get_all_customers_with_orders()
RETURNS TABLE (
  customer_id bigint,
  customer_name text,
  order_count bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    COUNT(o.id) as order_count
  FROM customers c
  LEFT JOIN orders o ON c.id = o.customer_id
  GROUP BY c.id, c.name;
END;
$$ LANGUAGE plpgsql;
```

```javascript
const { data, error } = await supabase.rpc('get_all_customers_with_orders')
```

