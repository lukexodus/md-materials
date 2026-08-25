## INSERT Statements and Variations in SQLite


---

### Basic Syntax

The `INSERT` statement adds one or more rows to a table.

```sql
INSERT INTO table_name (column1, column2, column3)
VALUES (value1, value2, value3);
```

**Key Points:**

- Column list is optional if you supply values for _all_ columns in defined order
- Omitting a column uses its `DEFAULT` value or `NULL` if none is defined
- SQLite is dynamically typed; column affinity applies but is not strictly enforced

**Example:**

```sql
CREATE TABLE employees (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name    TEXT NOT NULL,
    dept    TEXT,
    salary  REAL DEFAULT 0.0
);

INSERT INTO employees (name, dept, salary)
VALUES ('Alice', 'Engineering', 95000.00);
```

---

### Omitting the Column List

```sql
INSERT INTO employees
VALUES (NULL, 'Bob', 'Marketing', 72000.00);
```

**Key Points:**

- `NULL` is passed for the `id` column so `AUTOINCREMENT` can assign the next value
- Column order must exactly match the table's defined schema
- Generally considered fragile — schema changes can silently break this form

---

### Multi-Row INSERT

SQLite supports inserting multiple rows in a single statement (since SQLite 3.7.11).

```sql
INSERT INTO employees (name, dept, salary)
VALUES
    ('Carol', 'Design',      68000.00),
    ('David', 'Engineering', 101000.00),
    ('Eve',   'HR',          61000.00);
```

**Key Points:**

- Reduces round-trips compared to individual inserts
- All rows are inserted atomically within the statement
- [Inference] Likely more efficient than looped single-row inserts for bulk data, though actual performance depends on transaction context and hardware

---

### INSERT OR REPLACE

Attempts an insert; if a `UNIQUE` or `PRIMARY KEY` constraint is violated, the conflicting row is **deleted** and re-inserted.

```sql
INSERT OR REPLACE INTO employees (id, name, dept, salary)
VALUES (1, 'Alice', 'Engineering', 99000.00);
```

**Key Points:**

- The old row is fully removed, then a new row is written — this means the `rowid` changes
- Any columns not supplied receive their default values, not the old row's values
- Triggers for `DELETE` and `INSERT` may fire; `UPDATE` triggers do **not**
- Behavior may vary depending on trigger configuration — test in your environment

---

### INSERT OR IGNORE

Skips the insert silently if a constraint violation would occur.

```sql
INSERT OR IGNORE INTO employees (id, name, dept, salary)
VALUES (1, 'Alice', 'Engineering', 99000.00);
```

**Key Points:**

- No error is raised; the conflicting row is left untouched
- Useful for idempotent seed scripts or deduplication scenarios
- Does **not** update the existing row — if an update is needed, use `INSERT OR REPLACE` or `UPSERT`

---

### INSERT OR FAIL

Raises an error and aborts the current statement if a constraint is violated, but does **not** roll back any prior changes in the same transaction.

```sql
INSERT OR FAIL INTO employees (name, dept, salary)
VALUES ('Frank', 'Legal', 85000.00);
```

---

### INSERT OR ABORT _(default behavior)_

Aborts the current statement and rolls back changes made by that statement only. This is the default conflict resolution strategy.

```sql
INSERT OR ABORT INTO employees (name, dept, salary)
VALUES ('Grace', 'Finance', 79000.00);
```

---

### INSERT OR ROLLBACK

Aborts the current statement **and** rolls back the entire current transaction on conflict.

```sql
BEGIN;
INSERT OR ROLLBACK INTO employees (name, dept, salary)
VALUES ('Hank', 'Operations', 67000.00);
COMMIT;
```

**Key Points:**

- Strongest conflict response among the `OR` variants
- Useful when partial transaction state is considered invalid

---

### Conflict Resolution Summary Table

|Variant|On Conflict: Aborts Statement|Rolls Back Transaction|Existing Row Affected|
|---|---|---|---|
|`OR ABORT` _(default)_|✅|❌|Untouched|
|`OR FAIL`|✅|❌|Untouched|
|`OR IGNORE`|❌ (skips)|❌|Untouched|
|`OR REPLACE`|✅ (deletes + re-inserts)|❌|Deleted|
|`OR ROLLBACK`|✅|✅|Untouched|

---

### INSERT INTO ... SELECT

Inserts rows derived from a query result.

```sql
INSERT INTO employees (name, dept, salary)
SELECT name, dept, salary
FROM contractors
WHERE contract_end < DATE('now');
```

**Key Points:**

- Column count and compatible types must align between `SELECT` output and target table
- The `SELECT` can include joins, subqueries, filters, and expressions
- No `VALUES` clause is used with this form

**Example — copying a table:**

```sql
INSERT INTO employees_backup
SELECT * FROM employees;
```

---

### UPSERT (INSERT ... ON CONFLICT)

Introduced in SQLite 3.24.0. Allows conditional update logic when a conflict occurs, without deleting the existing row.

```sql
INSERT INTO employees (id, name, dept, salary)
VALUES (1, 'Alice', 'Engineering', 99000.00)
ON CONFLICT(id) DO UPDATE SET
    salary = excluded.salary,
    dept   = excluded.dept;
```

**Key Points:**

- `excluded` refers to the row that _would have been_ inserted
- The existing row's `rowid` is preserved (unlike `OR REPLACE`)
- `UPDATE` triggers fire instead of `DELETE`/`INSERT` triggers
- You may add a `WHERE` clause to the `DO UPDATE` to conditionally apply the update:

```sql
ON CONFLICT(id) DO UPDATE SET
    salary = excluded.salary
WHERE excluded.salary > employees.salary;
```

- To explicitly do nothing on conflict:

```sql
ON CONFLICT(id) DO NOTHING;
```

---

### INSERT with DEFAULT VALUES

Inserts a single row using all column defaults.

```sql
INSERT INTO employees DEFAULT VALUES;
```

**Key Points:**

- Every column must have a `DEFAULT` defined, or be nullable — otherwise an error occurs
- Rarely used in practice but valid syntax

---

### INSERT with a WITH Clause (CTE)

A Common Table Expression can precede an `INSERT ... SELECT`.

```sql
WITH high_earners AS (
    SELECT name, dept, salary
    FROM contractors
    WHERE salary > 90000.00
)
INSERT INTO employees (name, dept, salary)
SELECT name, dept, salary
FROM high_earners;
```

**Key Points:**

- CTE is evaluated first, then the result is fed to the `INSERT`
- Multiple CTEs can be chained with commas

---

### Retrieving the Last Inserted Row ID

```sql
INSERT INTO employees (name, dept, salary)
VALUES ('Ivan', 'IT', 74000.00);

SELECT last_insert_rowid();
```

**Key Points:**

- `last_insert_rowid()` returns the `rowid` of the most recent successful insert in the current connection
- Behavior is connection-scoped, not global — [Inference] concurrent connections should not interfere, but this depends on your application's connection management
- Returns `0` if no insert has occurred in the session

---

### Performance Considerations

**Key Points:**

- Wrapping many inserts in an explicit `BEGIN ... COMMIT` transaction significantly reduces I/O overhead — [Inference] each auto-committed insert writes to disk individually, which can be orders of magnitude slower for bulk loads (behavior may vary by OS and storage)
- `PRAGMA journal_mode = WAL;` may improve concurrent write throughput — verify in your environment
- `PRAGMA synchronous = NORMAL;` or `OFF` can reduce fsync calls at the cost of durability guarantees — use with caution

**Example — bulk insert with transaction:**

```sql
BEGIN;
INSERT INTO employees (name, dept, salary) VALUES ('J1', 'Dept', 50000);
INSERT INTO employees (name, dept, salary) VALUES ('J2', 'Dept', 51000);
-- ... more rows
COMMIT;
```

---

**Conclusion:** SQLite's `INSERT` covers a wide range of use cases — from basic single-row inserts to conflict-aware upserts and bulk `SELECT`-driven loads. Choosing the right variation depends on your conflict handling needs, whether row identity must be preserved, and performance requirements. Always verify behavior in your specific SQLite version, as features like `UPSERT` have minimum version requirements.

---

