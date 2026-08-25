## Subqueries


Subqueries are nested SELECT statements used within another query. They're useful for filtering, calculations, or complex conditions.

### Scalar Subqueries

```sql
CREATE OR REPLACE FUNCTION get_above_average_products()
RETURNS TABLE (
  id bigint,
  name text,
  price numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT p.id, p.name, p.price
  FROM products p
  WHERE p.price > (SELECT AVG(price) FROM products);
END;
$$ LANGUAGE plpgsql;
```

### Correlated Subqueries

```sql
CREATE OR REPLACE FUNCTION get_customer_latest_orders()
RETURNS TABLE (
  customer_id bigint,
  order_id bigint,
  order_date timestamp
) AS $$
BEGIN
  RETURN QUERY
  SELECT o1.customer_id, o1.id, o1.order_date
  FROM orders o1
  WHERE o1.order_date = (
    SELECT MAX(o2.order_date)
    FROM orders o2
    WHERE o2.customer_id = o1.customer_id
  );
END;
$$ LANGUAGE plpgsql;
```

### EXISTS/NOT EXISTS

```sql
SELECT * FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o 
  WHERE o.customer_id = c.id 
  AND o.total > 1000
);
```

