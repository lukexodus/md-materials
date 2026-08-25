## Bulk Operations in SQLite


---

### What Qualifies as a Bulk Operation

Bulk operations involve inserting, updating, deleting, or reading large numbers of rows — typically where performance, atomicity, and efficiency matter more than single-row convenience.

**Key Points:**

- SQLite is file-based; every write that is not wrapped in an explicit transaction incurs a full disk sync by default
- The single most impactful optimization for bulk writes is **explicit transaction batching**
- Other factors: journal mode, synchronous setting, index presence, page size, and statement reuse

---

### Baseline: Why Unbatched Inserts Are Slow

```sql
-- Each statement is its own transaction (autocommit)
INSERT INTO employees (name, dept, salary) VALUES ('Alice', 'Engineering', 95000);
INSERT INTO employees (name, dept, salary) VALUES ('Bob', 'Marketing', 72000);
-- ... repeated thousands of times
```

**Key Points:**

- In autocommit mode, each `INSERT` opens a transaction, writes to disk, and syncs
- [Inference] This can result in hundreds or thousands of fsync calls for bulk data — likely the dominant cost on spinning disk and a significant cost on SSD; actual impact depends on hardware and OS
- Wrapping all inserts in a single transaction reduces this to one sync at `COMMIT`

---

### Transaction Batching

The most effective bulk write optimization.

```sql
BEGIN;

INSERT INTO employees (name, dept, salary) VALUES ('Alice', 'Engineering', 95000);
INSERT INTO employees (name, dept, salary) VALUES ('Bob', 'Marketing', 72000);
INSERT INTO employees (name, dept, salary) VALUES ('Carol', 'Design', 68000);
-- ... thousands more

COMMIT;
```

**Key Points:**

- All writes are buffered in memory and flushed once at `COMMIT`
- If any statement fails, `ROLLBACK` undoes all changes in the batch
- [Inference] Transaction size has practical limits — extremely large transactions consume memory proportional to the number of changed pages; batching in chunks (e.g., 1,000–10,000 rows per transaction) often balances performance and memory usage, though optimal size depends on your environment
- No guaranteed optimal batch size — benchmark with your data and hardware

---

### Chunked Transaction Batching

For very large datasets, commit in chunks rather than one massive transaction.

```python
import sqlite3

conn = sqlite3.connect('mydatabase.db')
CHUNK_SIZE = 5000

rows = [...]  # Large list of tuples

conn.execute('BEGIN')
for i, row in enumerate(rows):
    conn.execute(
        'INSERT INTO employees (name, dept, salary) VALUES (?, ?, ?)',
        row
    )
    if (i + 1) % CHUNK_SIZE == 0:
        conn.execute('COMMIT')
        conn.execute('BEGIN')

conn.execute('COMMIT')
conn.close()
```

**Key Points:**

- Commits every `CHUNK_SIZE` rows, then starts a new transaction
- Reduces peak memory usage compared to a single transaction over millions of rows
- [Inference] Partial failures mid-chunk lose only that chunk's data — consider whether that is acceptable for your use case, or whether full atomicity is required
- Chunk size should be tuned empirically — no universally correct value

---

### Multi-Row INSERT

Insert multiple rows in a single statement.

```sql
INSERT INTO employees (name, dept, salary)
VALUES
    ('Alice', 'Engineering', 95000),
    ('Bob',   'Marketing',   72000),
    ('Carol', 'Design',      68000),
    ('David', 'Engineering', 101000);
```

**Key Points:**

- Supported since SQLite 3.7.11
- [Inference] Reduces statement parsing overhead compared to equivalent single-row inserts — actual performance gain relative to batched single-row inserts within a transaction may be marginal; benchmark to verify
- SQLite has a limit on the number of rows per `VALUES` clause — controlled by `SQLITE_LIMIT_COMPOUND_SELECT` (default 500) — [Unverified] verify this limit in your build:

```sql
SELECT * FROM pragma_compile_options WHERE compile_options LIKE '%LIMIT%';
```

---

### executemany (Python)

Python's `sqlite3` module provides `executemany` for efficient parameterized bulk inserts.

```python
import sqlite3

conn = sqlite3.connect('mydatabase.db')

rows = [
    ('Alice', 'Engineering', 95000.0),
    ('Bob',   'Marketing',   72000.0),
    ('Carol', 'Design',      68000.0),
]

conn.execute('BEGIN')
conn.executemany(
    'INSERT INTO employees (name, dept, salary) VALUES (?, ?, ?)',
    rows
)
conn.execute('COMMIT')
conn.close()
```

**Key Points:**

- `executemany` prepares the statement once and iterates over the data — [Inference] more efficient than calling `execute` in a loop for large datasets; actual gains depend on the driver implementation
- Parameterized queries (`?`) handle quoting and type conversion automatically
- Wrapping in explicit `BEGIN/COMMIT` is still necessary for transaction batching — `executemany` does not automatically batch into a transaction

---

### INSERT INTO ... SELECT (Bulk Copy)

Move or copy large sets of rows between tables in a single statement.

```sql
-- Copy all rows
INSERT INTO employees_backup
SELECT * FROM employees;

-- Filtered copy
INSERT INTO employees_archive
SELECT * FROM employees
WHERE deleted_at IS NOT NULL;

-- Transform on copy
INSERT INTO employees_normalized (name, dept, salary)
SELECT TRIM(UPPER(name)), LOWER(dept), ROUND(salary, 2)
FROM employees_raw;
```

**Key Points:**

- Executes entirely within SQLite — no data leaves the database engine
- [Inference] Significantly faster than read-then-write patterns through application code for large datasets, as it avoids serialization and network/IPC overhead
- The entire operation runs in a single implicit transaction unless inside an explicit one
- Column count and compatible types must align between source and destination

---

### Bulk UPDATE

Update large numbers of rows efficiently.

#### Full-table update (single expression):

```sql
UPDATE employees
SET salary = ROUND(salary * 1.05, 2);
```

#### Conditional bulk update with CASE:

```sql
UPDATE employees
SET salary = CASE
    WHEN dept = 'Engineering' THEN ROUND(salary * 1.10, 2)
    WHEN dept = 'Design'      THEN ROUND(salary * 1.07, 2)
    WHEN dept = 'Marketing'   THEN ROUND(salary * 1.04, 2)
    ELSE                           ROUND(salary * 1.02, 2)
END;
```

**Key Points:**

- A single `UPDATE` with `CASE` is [Inference] more efficient than multiple `UPDATE` statements for different departments — avoids repeated full or partial table scans; verify with `EXPLAIN QUERY PLAN`
- Wrap in a transaction if the update is part of a larger operation

#### Bulk update from another table (via subquery):

```sql
UPDATE employees
SET salary = (
    SELECT new_salary
    FROM salary_adjustments
    WHERE salary_adjustments.employee_id = employees.id
)
WHERE id IN (SELECT employee_id FROM salary_adjustments);
```

**Key Points:**

- The `WHERE id IN (...)` clause avoids setting unmatched rows to `NULL`
- [Inference] An index on `salary_adjustments.employee_id` and `employees.id` likely improves performance here — verify with `EXPLAIN QUERY PLAN`

---

### Bulk DELETE

```sql
-- Delete by condition
DELETE FROM employees
WHERE deleted_at < DATE('now', '-1 year');

-- Delete using subquery
DELETE FROM employees
WHERE id IN (
    SELECT id FROM employees
    ORDER BY created_at ASC
    LIMIT 10000
);
```

**Key Points:**

- Wrap large deletes in a transaction
- [Inference] Deleting large numbers of rows in one statement may cause long write locks — chunked deletes with transactions can reduce lock duration in concurrent environments
- Deleted rows leave free pages in the database file — run `VACUUM` afterward to reclaim space if needed

#### Chunked delete pattern (Python):

```python
import sqlite3

conn = sqlite3.connect('mydatabase.db')

while True:
    conn.execute('BEGIN')
    cursor = conn.execute(
        'DELETE FROM logs WHERE created_at < ? LIMIT 5000',
        ('2024-01-01',)
    )
    conn.execute('COMMIT')
    if cursor.rowcount == 0:
        break

conn.close()
```

**Key Points:**

- Requires `SQLITE_ENABLE_UPDATE_DELETE_LIMIT` compile option — verify before use
- Loops until no more rows match, avoiding a single massive delete

---

### PRAGMA Settings for Bulk Operations

Several PRAGMAs significantly affect write performance. These trade durability or safety for speed and should be evaluated against your requirements.

#### journal_mode

```sql
PRAGMA journal_mode = WAL;
```

|Mode|Description|
|---|---|
|`DELETE`|Default; rollback journal, exclusive write lock|
|`WAL`|Write-Ahead Log; allows concurrent reads during writes|
|`MEMORY`|Journal in memory only; data lost on crash|
|`OFF`|No journal; no rollback on crash|

**Key Points:**

- `WAL` mode is [Inference] generally beneficial for bulk writes with concurrent reads — reduces contention; actual gains depend on workload
- `MEMORY` and `OFF` remove durability guarantees — data may be unrecoverable after a crash
- `WAL` persists across connections — set once per database, not per connection
- [Unverified] Some embedded or read-only environments may not support WAL — verify compatibility

#### synchronous

```sql
PRAGMA synchronous = NORMAL;  -- Default in WAL mode
PRAGMA synchronous = OFF;     -- Maximum speed, minimum durability
PRAGMA synchronous = FULL;    -- Maximum durability (default in DELETE mode)
```

|Setting|Behavior|
|---|---|
|`FULL`|Syncs at every critical point — safest|
|`NORMAL`|Syncs less frequently — safe in WAL mode|
|`OFF`|No OS-level sync — fastest, but data may be lost on OS crash|

**Key Points:**

- `OFF` is appropriate for disposable or reproducible data (e.g., temp processing, test data)
- `NORMAL` with `WAL` is a common production balance — [Inference] reduces sync overhead while maintaining reasonable durability; behavior depends on OS and filesystem
- These settings are per-connection and do not persist

#### cache_size

```sql
PRAGMA cache_size = -65536;  -- 64MB (negative = kilobytes)
PRAGMA cache_size = 10000;   -- 10000 pages
```

**Key Points:**

- Larger cache reduces disk reads during bulk operations that revisit pages
- Default is typically 2MB — [Unverified] exact default depends on SQLite build and page size
- Setting too large may cause memory pressure — tune based on available system memory

#### page_size

```sql
-- Must be set BEFORE the database is created
PRAGMA page_size = 4096;   -- Default
PRAGMA page_size = 16384;  -- Larger pages; may help bulk reads
```

**Key Points:**

- Can only be changed on a new or empty database, or after a `VACUUM`
- [Inference] Larger page sizes may improve sequential bulk read performance at the cost of more wasted space for small rows — actual effect depends on row size and access patterns
- Has no effect if set after data has been written

#### temp_store

```sql
PRAGMA temp_store = MEMORY;
```

**Key Points:**

- Directs temporary tables and indexes used during queries to memory instead of disk
- [Inference] Can improve performance of bulk operations involving large sorts or intermediate results — behavior depends on available memory

---

### Indexes and Bulk Operations

**Key Points:**

- Indexes slow down bulk inserts, updates, and deletes — each write must also update every applicable index
- For large initial data loads, a common pattern is:

```sql
-- 1. Drop indexes before bulk load
DROP INDEX IF EXISTS idx_employees_dept;

-- 2. Perform bulk insert
BEGIN;
INSERT INTO employees ...;
COMMIT;

-- 3. Rebuild indexes after load
CREATE INDEX idx_employees_dept ON employees (dept);
```

- [Inference] This can substantially reduce bulk insert time when multiple indexes exist — gains are proportional to the number and size of indexes; benchmark in your environment
- `ANALYZE` after rebuild updates query planner statistics:

```sql
ANALYZE employees;
```

---

### CREATE TABLE AS SELECT (Bulk Table Creation)

Creates and populates a new table from a query in one operation.

```sql
CREATE TABLE engineering_employees AS
SELECT * FROM employees
WHERE dept = 'Engineering';
```

**Key Points:**

- Column names and types are inferred from the query — no constraints, indexes, or primary keys are copied
- [Inference] Faster than `CREATE TABLE` followed by `INSERT INTO ... SELECT` for large result sets — avoids overhead of constraint checking during insert; verify in your environment
- Useful for temporary analysis tables or archiving subsets

---

### Temporary Tables for Staging

```sql
CREATE TEMPORARY TABLE bulk_staging (
    name   TEXT,
    dept   TEXT,
    salary TEXT
);

-- Load raw data
INSERT INTO bulk_staging VALUES (...);

-- Validate and transform
INSERT INTO employees (name, dept, salary)
SELECT TRIM(name), dept, CAST(salary AS REAL)
FROM bulk_staging
WHERE name IS NOT NULL AND salary != '';

DROP TABLE bulk_staging;
```

**Key Points:**

- `TEMPORARY` tables exist only for the current connection and are automatically dropped on disconnect
- Stored in a separate temp database — [Inference] does not bloat the main database file
- Useful for validating and cleaning data before committing to production tables

---

### WITHOUT ROWID Tables

For certain access patterns, `WITHOUT ROWID` tables can improve bulk read and write performance.

```sql
CREATE TABLE lookup_codes (
    code        TEXT PRIMARY KEY,
    description TEXT
) WITHOUT ROWID;
```

**Key Points:**

- Omits the implicit `rowid` column — data is stored in a B-tree indexed by the primary key
- [Inference] Can improve performance for tables with small rows accessed primarily by primary key — gains depend on access pattern and row size
- Requires an explicit `PRIMARY KEY`
- `last_insert_rowid()` and `AUTOINCREMENT` do not apply
- Not suitable for tables with large or variable-length primary keys — [Inference] may increase page splits and reduce efficiency in those cases

---

### VACUUM After Bulk Delete

```sql
VACUUM;
```

**Key Points:**

- Rewrites the entire database file, reclaiming free pages left by bulk deletes
- [Inference] Temporarily requires up to double the database file's disk space during execution — verify available disk before running on large databases
- Blocks all other connections during execution
- `VACUUM INTO` creates a vacuumed copy without modifying the original:

```sql
VACUUM INTO '/path/to/compacted_backup.db';
```

---

### ANALYZE After Bulk Changes

```sql
ANALYZE;          -- Entire database
ANALYZE employees; -- Single table
```

**Key Points:**

- Updates internal statistics used by the query planner
- After large bulk inserts, updates, or deletes, stale statistics may cause the planner to choose suboptimal query plans
- [Inference] Running `ANALYZE` after significant data changes is good practice — actual impact on query plan quality depends on the queries and data distribution

---

### Bulk Operation PRAGMA Checklist

A reference sequence for maximum bulk write throughput — adjust based on your durability requirements.

```sql
-- Before bulk operation
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = -65536;    -- 64MB
PRAGMA temp_store = MEMORY;

DROP INDEX IF EXISTS idx_employees_dept;  -- Drop indexes if bulk loading

BEGIN;

-- ... bulk inserts, updates, or deletes ...

COMMIT;

-- After bulk operation
CREATE INDEX idx_employees_dept ON employees (dept);
ANALYZE employees;
VACUUM;  -- Only if large amounts of data were deleted
```

**Key Points:**

- Not all settings are appropriate for all environments — `synchronous = NORMAL` or `OFF` reduces durability
- `VACUUM` is expensive on large databases — run only when significant free space needs reclaiming
- These are starting points; benchmark and adjust for your specific workload and hardware
- [Inference] The combination of WAL mode, explicit transactions, and dropped indexes during load typically produces the largest performance gains — individual contributions vary

---

### Performance Comparison Reference

|Approach|Relative Write Speed|Notes|
|---|---|---|
|Autocommit single-row inserts|Very slow|One fsync per row|
|Explicit transaction, single-row inserts|Fast|One fsync at COMMIT|
|Multi-row INSERT in transaction|Fast|Reduced parse overhead|
|`executemany` in transaction|Fast|Prepared once, iterated|
|`INSERT INTO ... SELECT`|Very fast|In-engine; no app layer|
|With indexes dropped during load|Faster|Avoids index writes|
|WAL + synchronous=NORMAL|Faster|Reduced sync frequency|

**Key Points:**

- [Inference] These relative comparisons reflect commonly observed patterns — actual results depend on hardware, OS, row size, index count, and SQLite version; always benchmark with representative data
- No single configuration is optimal for all workloads

---

**Conclusion:** Bulk operation performance in SQLite is primarily governed by transaction batching, journal mode, synchronous settings, and index management. The most impactful single change for bulk writes is wrapping operations in explicit transactions. Beyond that, WAL mode, dropping and rebuilding indexes around large loads, and using `INSERT INTO ... SELECT` for in-database transfers compound the gains. All PRAGMA-based optimizations involve tradeoffs between speed and durability — evaluate against your data's recoverability requirements.

**Next Steps:**

- Indexes — design, types, and performance impact
- Transactions and savepoints in depth
- Query optimization and `EXPLAIN QUERY PLAN`
- WAL mode and concurrency behavior

---

