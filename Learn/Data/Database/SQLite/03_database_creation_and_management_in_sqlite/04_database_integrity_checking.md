## Database Integrity Checking


SQLite provides built-in mechanisms to verify database integrity and detect corruption.

**Key points:**

- The `PRAGMA integrity_check` command performs a comprehensive integrity check of the entire database
- The `PRAGMA quick_check` performs a faster but less thorough integrity check
- Integrity checks verify B-tree structures, check for orphaned pages, and validate internal consistency
- The `integrity_check` pragma can be limited to specific tables by providing table names as arguments
- Regular integrity checks are recommended, especially after system crashes or storage failures
- The `foreign_key_check` pragma verifies foreign key constraints without checking overall database integrity
- Integrity checks do not repair corruption; they only detect it

**Example:**

```sql
-- Full integrity check (returns 'ok' if no issues found)
PRAGMA integrity_check;

-- Quick integrity check (faster, less thorough)
PRAGMA quick_check;

-- Check integrity of specific tables
PRAGMA integrity_check(users, orders);

-- Check foreign key constraints
PRAGMA foreign_key_check;

-- Check foreign keys for specific table
PRAGMA foreign_key_check(orders);
```

**Output:**

For a healthy database, `integrity_check` returns a single row with the value "ok". If issues are found, it returns descriptive error messages indicating the nature and location of corruption.

