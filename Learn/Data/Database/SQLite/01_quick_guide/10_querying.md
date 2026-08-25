## Querying


### Filtering

```sql
-- Comparison operators
WHERE age > 18
WHERE status != 'banned'
WHERE score BETWEEN 50 AND 100

-- Pattern matching
WHERE username LIKE 'a%'      -- starts with 'a'
WHERE email LIKE '%@gmail.com'

-- NULL checks
WHERE phone IS NULL
WHERE phone IS NOT NULL

-- IN list
WHERE country IN ('PH', 'SG', 'MY')

-- Logical operators
WHERE active = 1 AND age >= 18
WHERE role = 'admin' OR role = 'moderator'
```

### Aggregation

```sql
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM users WHERE active = 1;
SELECT AVG(score), MAX(score), MIN(score) FROM results;
SELECT country, COUNT(*) AS total FROM users GROUP BY country;
SELECT country, COUNT(*) AS total FROM users GROUP BY country HAVING total > 100;
```

### Joins

```sql
-- Inner join
SELECT u.username, o.amount
FROM users u
JOIN orders o ON u.id = o.user_id;

-- Left join (keeps all users, even those with no orders)
SELECT u.username, o.amount
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;

-- Self join
SELECT a.username AS employee, b.username AS manager
FROM users a
JOIN users b ON a.manager_id = b.id;
```

### Subqueries

```sql
-- Scalar subquery
SELECT username FROM users
WHERE id = (SELECT user_id FROM orders ORDER BY amount DESC LIMIT 1);

-- IN subquery
SELECT username FROM users
WHERE id IN (SELECT DISTINCT user_id FROM orders WHERE amount > 500);
```

### Common Table Expressions (CTEs)

```sql
WITH active_users AS (
    SELECT * FROM users WHERE active = 1
),
high_spenders AS (
    SELECT user_id FROM orders GROUP BY user_id HAVING SUM(amount) > 1000
)
SELECT u.username
FROM active_users u
JOIN high_spenders h ON u.id = h.user_id;
```

### Recursive CTEs

```sql
-- Generate a sequence of numbers 1 through 10
WITH RECURSIVE nums(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 10
)
SELECT n FROM nums;

-- Traverse a tree/hierarchy
WITH RECURSIVE subordinates(id, username, level) AS (
    SELECT id, username, 0 FROM users WHERE manager_id IS NULL
    UNION ALL
    SELECT u.id, u.username, s.level + 1
    FROM users u
    JOIN subordinates s ON u.manager_id = s.id
)
SELECT * FROM subordinates;
```

### Window Functions

```sql
-- Row number per partition
SELECT username, country,
       ROW_NUMBER() OVER (PARTITION BY country ORDER BY created_at) AS rn
FROM users;

-- Running total
SELECT id, amount,
       SUM(amount) OVER (ORDER BY id) AS running_total
FROM orders;

-- Ranking
SELECT username, score,
       RANK()       OVER (ORDER BY score DESC) AS rank,
       DENSE_RANK() OVER (ORDER BY score DESC) AS dense_rank
FROM results;

-- Lag and lead
SELECT id, amount,
       LAG(amount, 1, 0) OVER (ORDER BY id) AS prev_amount
FROM orders;
```

---

