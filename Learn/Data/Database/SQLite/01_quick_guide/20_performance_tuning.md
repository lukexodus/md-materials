## Performance Tuning


### Use Transactions for Bulk Writes

Wrapping many inserts in a single transaction is one of the highest-impact optimizations available. Without a transaction, each insert is its own transaction and triggers an fsync.

```sql
BEGIN;
-- thousands of inserts
COMMIT;
```

### Tune Synchronous Mode

```sql
PRAGMA synchronous = NORMAL;
```

`FULL` (default) calls fsync after every transaction. `NORMAL` reduces fsync frequency. `OFF` disables fsync entirely — fast but data can be corrupted on a power loss.

### Increase Cache Size

```sql
PRAGMA cache_size = -128000;  -- 128 MB page cache
```

### Use Prepared Statements

In application code, prepare a statement once and bind parameters repeatedly rather than building SQL strings dynamically. This avoids repeated parsing overhead.

### ANALYZE

```sql
ANALYZE;
```

This gathers statistics about table and index sizes, helping the query planner make better decisions. Run it after bulk data loads or significant schema changes.

### VACUUM

```sql
VACUUM;
```

Rebuilds the database file, reclaiming space from deleted rows and defragmenting. Can significantly reduce file size after heavy deletions.

```sql
-- Incremental vacuum (requires auto_vacuum = INCREMENTAL set before data is written)
PRAGMA auto_vacuum = INCREMENTAL;
PRAGMA incremental_vacuum(100);  -- Reclaim 100 pages
```

---

