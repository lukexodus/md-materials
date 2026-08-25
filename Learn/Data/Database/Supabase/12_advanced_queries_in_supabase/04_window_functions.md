## Window Functions


Window functions perform calculations across sets of rows related to the current row without collapsing the result set like GROUP BY does.

### ROW_NUMBER, RANK, DENSE_RANK

```sql
CREATE OR REPLACE FUNCTION rank_products_by_sales()
RETURNS TABLE (
  product_id bigint,
  product_name text,
  total_quantity bigint,
  sales_rank bigint
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.name,
    SUM(oi.quantity) as total_quantity,
    ROW_NUMBER() OVER (ORDER BY SUM(oi.quantity) DESC) as sales_rank
  FROM products p
  JOIN order_items oi ON p.id = oi.product_id
  GROUP BY p.id, p.name;
END;
$$ LANGUAGE plpgsql;
```

### PARTITION BY

```sql
SELECT 
  customer_id,
  order_date,
  total,
  AVG(total) OVER (PARTITION BY customer_id) as customer_avg,
  total - AVG(total) OVER (PARTITION BY customer_id) as diff_from_avg
FROM orders;
```

### LAG and LEAD

```sql
SELECT 
  product_id,
  sale_date,
  quantity,
  LAG(quantity, 1) OVER (PARTITION BY product_id ORDER BY sale_date) as prev_quantity,
  LEAD(quantity, 1) OVER (PARTITION BY product_id ORDER BY sale_date) as next_quantity
FROM sales;
```

### Running Totals

```sql
SELECT 
  order_date,
  total,
  SUM(total) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_total
FROM orders;
```

