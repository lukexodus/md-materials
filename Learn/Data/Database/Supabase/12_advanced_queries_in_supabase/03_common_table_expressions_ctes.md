## Common Table Expressions (CTEs)


CTEs create temporary named result sets that exist only during query execution. They improve readability and enable recursive operations.

### Basic CTE

```sql
CREATE OR REPLACE FUNCTION analyze_sales()
RETURNS TABLE (
  category text,
  total_revenue numeric,
  avg_order_value numeric
) AS $$
BEGIN
  RETURN QUERY
  WITH order_totals AS (
    SELECT 
      p.category,
      o.id as order_id,
      SUM(oi.quantity * oi.price) as order_total
    FROM order_items oi
    JOIN products p ON oi.product_id = p.id
    JOIN orders o ON oi.order_id = o.id
    GROUP BY p.category, o.id
  )
  SELECT 
    category,
    SUM(order_total) as total_revenue,
    AVG(order_total) as avg_order_value
  FROM order_totals
  GROUP BY category;
END;
$$ LANGUAGE plpgsql;
```

### Multiple CTEs

```sql
WITH 
  customer_stats AS (
    SELECT customer_id, COUNT(*) as order_count
    FROM orders
    GROUP BY customer_id
  ),
  revenue_stats AS (
    SELECT customer_id, SUM(total) as total_spent
    FROM orders
    GROUP BY customer_id
  )
SELECT 
  c.name,
  cs.order_count,
  rs.total_spent
FROM customers c
JOIN customer_stats cs ON c.id = cs.customer_id
JOIN revenue_stats rs ON c.id = rs.customer_id;
```

