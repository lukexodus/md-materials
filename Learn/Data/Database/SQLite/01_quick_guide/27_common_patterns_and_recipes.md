## Common Patterns and Recipes


### Upsert (Insert or Update)

```sql
INSERT INTO users (id, username, email)
VALUES (1, 'alice', 'alice@example.com')
ON CONFLICT(id) DO UPDATE SET
    email = excluded.email;
```

### Pagination

```sql
-- Page 3, 20 rows per page
SELECT * FROM users ORDER BY id LIMIT 20 OFFSET 40;
```

### Pivot / Conditional Aggregation

```sql
SELECT
    month,
    SUM(CASE WHEN category = 'A' THEN amount ELSE 0 END) AS cat_a,
    SUM(CASE WHEN category = 'B' THEN amount ELSE 0 END) AS cat_b
FROM sales
GROUP BY month;
```

### Deduplication

```sql
-- Keep the row with the highest id for each email
DELETE FROM users
WHERE id NOT IN (
    SELECT MAX(id) FROM users GROUP BY email
);
```

### Generating Rows Without a Table

```sql
SELECT 1 AS n
UNION ALL SELECT 2
UNION ALL SELECT 3;
```

---

