## Transactions


SQLite wraps every statement in an implicit transaction. For batched work, use explicit transactions.

```sql
BEGIN;

INSERT INTO orders (user_id, amount) VALUES (1, 99.99);
INSERT INTO order_items (order_id, product_id, quantity) VALUES (last_insert_rowid(), 7, 2);

COMMIT;
```

If something goes wrong:

```sql
ROLLBACK;
```

### Savepoints

```sql
BEGIN;
SAVEPOINT before_update;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;

-- Something went wrong
ROLLBACK TO before_update;

COMMIT;
```

### Transaction Modes

SQLite supports three modes started with:

```sql
BEGIN DEFERRED;    -- Default: lock acquired on first read or write
BEGIN IMMEDIATE;   -- Write lock acquired immediately
BEGIN EXCLUSIVE;   -- Exclusive lock; no other connection can read or write
```

---

