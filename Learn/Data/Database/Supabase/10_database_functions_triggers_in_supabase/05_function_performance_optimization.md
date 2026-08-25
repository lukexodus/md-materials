## Function Performance Optimization


### Use Appropriate Return Types

```sql
-- Inefficient: Returning all data as text
CREATE FUNCTION get_user_inefficient(user_id uuid)
RETURNS text AS $$
  SELECT email::text || ',' || created_at::text FROM users WHERE id = user_id;
$$ LANGUAGE sql;

-- Efficient: Proper return type
CREATE FUNCTION get_user_efficient(user_id uuid)
RETURNS TABLE(email text, created_at timestamptz) AS $$
  SELECT email, created_at FROM users WHERE id = user_id;
$$ LANGUAGE sql;
```

### Minimize Context Switches

```sql
-- Inefficient: Multiple queries in PL/pgSQL
CREATE FUNCTION get_order_summary_slow(order_id uuid)
RETURNS json
LANGUAGE plpgsql AS $$
DECLARE
  user_email text;
  item_count int;
  total numeric;
BEGIN
  SELECT u.email INTO user_email
  FROM orders o JOIN users u ON o.user_id = u.id
  WHERE o.id = order_id;
  
  SELECT COUNT(*) INTO item_count
  FROM order_items WHERE order_items.order_id = get_order_summary_slow.order_id;
  
  SELECT SUM(quantity * price) INTO total
  FROM order_items WHERE order_items.order_id = get_order_summary_slow.order_id;
  
  RETURN json_build_object('email', user_email, 'items', item_count, 'total', total);
END;
$$;

-- Efficient: Single SQL query
CREATE FUNCTION get_order_summary_fast(order_id uuid)
RETURNS json
LANGUAGE sql AS $$
  SELECT json_build_object(
    'email', u.email,
    'items', COUNT(oi.id),
    'total', SUM(oi.quantity * oi.price)
  )
  FROM orders o
  JOIN users u ON o.user_id = u.id
  LEFT JOIN order_items oi ON oi.order_id = o.id
  WHERE o.id = get_order_summary_fast.order_id
  GROUP BY u.email;
$$;
```

### Use SQL Language When Possible

SQL language functions allow better optimization by the query planner compared to PL/pgSQL:

```sql
-- PL/pgSQL version
CREATE FUNCTION get_active_count_plpgsql()
RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE
  result bigint;
BEGIN
  SELECT COUNT(*) INTO result FROM users WHERE is_active = true;
  RETURN result;
END;
$$;

-- Faster SQL version
CREATE FUNCTION get_active_count_sql()
RETURNS bigint
LANGUAGE sql AS $$
  SELECT COUNT(*) FROM users WHERE is_active = true;
$$;
```

### Index Support

Functions can benefit from indexes when used in WHERE clauses:

```sql
-- Create function
CREATE FUNCTION get_user_age(birth_date date)
RETURNS int
LANGUAGE sql
IMMUTABLE AS $$
  SELECT EXTRACT(YEAR FROM AGE(birth_date))::int;
$$;

-- Create index using function
CREATE INDEX idx_user_age ON users(get_user_age(birth_date));

-- Query benefits from index
SELECT * FROM users WHERE get_user_age(birth_date) > 18;
```

### Avoid Dynamic SQL When Static Suffices

```sql
-- Slower: Dynamic SQL
CREATE FUNCTION get_table_count_dynamic(table_name text)
RETURNS bigint
LANGUAGE plpgsql AS $$
DECLARE
  result bigint;
BEGIN
  EXECUTE format('SELECT COUNT(*) FROM %I', table_name) INTO result;
  RETURN result;
END;
$$;

-- Faster: Static SQL (when table is known)
CREATE FUNCTION get_users_count()
RETURNS bigint
LANGUAGE sql AS $$
  SELECT COUNT(*) FROM users;
$$;
```

### Batch Operations

```sql
-- Inefficient: Row-by-row processing
CREATE FUNCTION update_prices_slow()
RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
  product record;
BEGIN
  FOR product IN SELECT * FROM products LOOP
    UPDATE products 
    SET price = price * 1.1 
    WHERE id = product.id;
  END LOOP;
END;
$$;

-- Efficient: Set-based operation
CREATE FUNCTION update_prices_fast()
RETURNS void
LANGUAGE sql AS $$
  UPDATE products SET price = price * 1.1;
$$;
```

### Function Inlining

[Inference] Simple SQL functions may be inlined by the query planner, improving performance:

```sql
-- Likely to be inlined
CREATE FUNCTION is_premium_user(user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE AS $$
  SELECT tier = 'premium' FROM users WHERE id = user_id;
$$;

-- Used in queries efficiently
SELECT * FROM orders WHERE is_premium_user(user_id) AND created_at > NOW() - INTERVAL '30 days';
```

### Monitoring Function Performance

```sql
-- Enable timing for function analysis
EXPLAIN ANALYZE SELECT my_function(param);

-- Check function execution stats
SELECT 
  schemaname,
  funcname,
  calls,
  total_time,
  self_time,
  total_time / calls as avg_time
FROM pg_stat_user_functions
WHERE funcname = 'your_function_name';
```

