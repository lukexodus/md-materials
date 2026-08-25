## EXPLAIN and Query Plans


EXPLAIN shows how PostgreSQL executes queries, revealing the query planner's strategy and helping identify optimization opportunities.

### Basic EXPLAIN

```sql
-- Show query plan
EXPLAIN 
SELECT u.email, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at > '2024-01-01'
GROUP BY u.email;
```

**Example output interpretation:**

```
HashAggregate  (cost=1234.56..1456.78 rows=1000 width=40)
  Group Key: u.email
  ->  Hash Left Join  (cost=123.45..234.56 rows=5000 width=32)
        Hash Cond: (u.id = o.user_id)
        ->  Seq Scan on users u  (cost=0.00..100.00 rows=1000 width=24)
              Filter: (created_at > '2024-01-01'::date)
        ->  Hash  (cost=100.00..100.00 rows=10000 width=16)
              ->  Seq Scan on orders o  (cost=0.00..100.00 rows=10000 width=16)
```

### EXPLAIN ANALYZE

EXPLAIN ANALYZE executes the query and provides actual runtime statistics:

```sql
EXPLAIN ANALYZE
SELECT * FROM products 
WHERE category_id = 5 
AND price > 100
ORDER BY created_at DESC
LIMIT 10;
```

**Key metrics:**

- **Planning Time**: Time spent planning the query
- **Execution Time**: Actual time to execute
- **Actual rows vs Estimated rows**: Shows estimation accuracy
- **Buffers**: Shows disk I/O activity

```sql
-- Include buffer information
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM large_table WHERE indexed_column = 'value';
```

### Understanding Query Plan Nodes

**Seq Scan (Sequential Scan)**

```sql
EXPLAIN SELECT * FROM users WHERE email LIKE '%@example.com';
-- Shows: Seq Scan on users
```

Reads entire table. Appropriate for small tables or when most rows match. Consider indexing if filtering on specific columns.

**Index Scan**

```sql
CREATE INDEX idx_users_email ON users(email);
EXPLAIN SELECT * FROM users WHERE email = 'user@example.com';
-- Shows: Index Scan using idx_users_email on users
```

Uses index to find specific rows. Efficient for selective queries.

**Index Only Scan**

```sql
CREATE INDEX idx_users_email_created ON users(email, created_at);
EXPLAIN SELECT email, created_at FROM users WHERE email = 'user@example.com';
-- Shows: Index Only Scan using idx_users_email_created on users
```

Retrieves all data from index without accessing table. Most efficient when possible.

**Bitmap Index Scan**

```sql
EXPLAIN SELECT * FROM users WHERE age > 25 AND age < 35;
-- May show: Bitmap Index Scan on idx_users_age
```

[Inference] Used when multiple rows match or combining multiple indexes. Builds bitmap of matching pages before fetching.

**Nested Loop Join**

```sql
EXPLAIN 
SELECT * FROM orders o
JOIN users u ON o.user_id = u.id
WHERE u.id = 123;
-- May show: Nested Loop
```

Iterates through one table and looks up matches in another. Efficient for small result sets.

**Hash Join**

```sql
EXPLAIN 
SELECT * FROM orders o
JOIN products p ON o.product_id = p.id;
-- May show: Hash Join
```

Builds hash table of one side, probes with other. Good for larger joins.

**Merge Join**

```sql
EXPLAIN 
SELECT * FROM table1 t1
JOIN table2 t2 ON t1.sorted_col = t2.sorted_col;
-- May show: Merge Join
```

Requires both sides sorted. Efficient for large sorted datasets.

### Analyzing Specific Issues

```sql
-- Check if indexes are being used
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders 
WHERE user_id = 'abc123' 
AND created_at > NOW() - INTERVAL '7 days';

-- Look for:
-- - "Seq Scan" when index expected
-- - High "actual time" values
-- - "Buffers: shared read=" indicating disk I/O
-- - Large difference between estimated and actual rows

-- Check join performance
EXPLAIN (ANALYZE, BUFFERS)
SELECT u.email, o.total
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.status = 'pending';
```

### Query Plan Visualization

[Inference] Various tools can visualize EXPLAIN output for easier analysis:

- pgAdmin's graphical explain
- Online tools like explain.dalibo.com or explain.depesz.com
- PostgreSQL extensions for visual query plans

