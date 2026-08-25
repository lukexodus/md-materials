## Indexes


### Why Indexes Matter

Without an index, SQLite performs a full table scan for every query. Indexes trade storage and write performance for faster reads.

### Creating Indexes

```sql
-- Basic index
CREATE INDEX idx_users_email ON users(email);

-- Unique index
CREATE UNIQUE INDEX idx_users_username ON users(username);

-- Composite index
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at);

-- Partial index (only indexes rows matching the condition)
CREATE INDEX idx_active_users ON users(username) WHERE active = 1;
```

### Dropping Indexes

```sql
DROP INDEX idx_users_email;
```

### Choosing What to Index

General guidance:

- Index columns used frequently in `WHERE`, `JOIN ON`, and `ORDER BY` clauses.
- Composite indexes are most effective when the leftmost columns match your query's filter.
- Avoid indexing columns with very low cardinality (e.g., a boolean column with only two values) unless combined with higher-cardinality columns or used as partial indexes.
- Every index costs time on `INSERT`, `UPDATE`, and `DELETE`.

### EXPLAIN QUERY PLAN

```sql
EXPLAIN QUERY PLAN
SELECT * FROM users WHERE email = 'alice@example.com';
```

The output shows whether SQLite uses an index (`SEARCH`) or a full scan (`SCAN`). Use this to verify that indexes are being used as expected.

---

