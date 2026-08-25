## DELETE Operations in SQLite


---

### Basic Syntax

The `DELETE` statement removes rows from a table.

```sql
DELETE FROM table_name
WHERE condition;
```

**Key Points:**

- Only rows are removed — the table structure, indexes, and triggers remain intact
- `WHERE` is optional; omitting it removes **every row** in the table
- `DELETE` does not reset `AUTOINCREMENT` counters — the next inserted row continues from the last known max `rowid`
- Removed rows cannot be recovered without a transaction rollback or backup

---

### Delete a Single Row

```sql
DELETE FROM employees
WHERE id = 5;
```

---

### Delete with Multiple Conditions

```sql
DELETE FROM employees
WHERE dept = 'Marketing'
  AND salary < 60000.00;
```

```sql
DELETE FROM employees
WHERE dept IN ('Temp', 'Contractor')
   OR salary IS NULL;
```

**Key Points:**

- All `WHERE` clause patterns from `SELECT` apply: `AND`, `OR`, `IN`, `BETWEEN`, `LIKE`, `IS NULL`
- Parentheses are recommended when mixing `AND` and `OR` to avoid precedence errors

---

### Delete All Rows

```sql
DELETE FROM employees;
```

**Key Points:**

- Removes every row but preserves the table definition
- The `rowid` sequence is **not** reset — [Inference] this differs from `TRUNCATE` in other databases; SQLite has no `TRUNCATE` statement
- If resetting the sequence is required alongside clearing rows, `DROP TABLE` and recreate, or manually reset the `sqlite_sequence` table (for `AUTOINCREMENT` tables):

```sql
-- Reset AUTOINCREMENT counter (only applies to AUTOINCREMENT tables)
DELETE FROM sqlite_sequence WHERE name = 'employees';
```

**Key Points on sqlite_sequence:**

- `sqlite_sequence` only exists if at least one table was created with `AUTOINCREMENT`
- Modifying it directly is supported but should be done carefully — [Inference] inserting after a manual reset may produce IDs that conflict with previously deleted rows if those rows still exist elsewhere (e.g., in foreign key references)

---

### DELETE with RETURNING

Available in SQLite 3.35.0+. Returns data from the rows that were deleted.

```sql
DELETE FROM employees
WHERE dept = 'Temp'
RETURNING id, name, salary;
```

**Output:**

```
7  | Frank  | 52000.00
11 | Judy   | 48000.00
```

**Key Points:**

- `RETURNING *` returns all columns of the deleted rows
- Row values are returned as they existed **before** deletion
- Useful for logging, auditing, or feeding deleted data into another operation without a prior `SELECT`
- Requires SQLite 3.35.0+ — verify with `SELECT SQLITE_VERSION();`

---

### DELETE with Subquery in WHERE

```sql
DELETE FROM employees
WHERE id IN (
    SELECT id FROM employees
    WHERE salary < (SELECT AVG(salary) FROM employees)
      AND dept = 'Operations'
);
```

**Key Points:**

- Subqueries in `DELETE` follow the same rules as in `SELECT`
- The subquery is evaluated before deletion begins — [Inference] rows matching the subquery at evaluation time are the rows deleted; modifications mid-statement do not alter the target set, but this should be tested in your environment
- Correlated subqueries are supported

---

### DELETE with FROM Clause (Join-Style)

SQLite does not support `DELETE ... JOIN` directly. A join can be expressed via subquery or, in SQLite 3.33.0+, via a `FROM` clause.

#### Using Subquery (all versions):

```sql
DELETE FROM employees
WHERE id IN (
    SELECT e.id
    FROM employees e
    JOIN departments d ON e.dept = d.name
    WHERE d.status = 'dissolved'
);
```

#### Using FROM clause (SQLite 3.33.0+):

```sql
DELETE FROM employees
WHERE employees.dept = departments.name
  AND departments.status = 'dissolved';
```

Wait — the `FROM` clause form for `DELETE` requires explicit syntax:

```sql
DELETE FROM employees
WHERE EXISTS (
    SELECT 1 FROM departments
    WHERE departments.name = employees.dept
      AND departments.status = 'dissolved'
);
```

**Key Points:**

- SQLite's `DELETE` does not support a standalone `FROM` join clause the way `UPDATE` does in 3.33.0+ — use `EXISTS` or `IN` subqueries for join-style filtering
- `EXISTS` can be more readable when checking related table conditions
- [Inference] `EXISTS` may perform differently than `IN` depending on indexes — use `EXPLAIN QUERY PLAN` to compare

---

### DELETE with EXISTS

```sql
DELETE FROM employees
WHERE EXISTS (
    SELECT 1 FROM terminations
    WHERE terminations.employee_id = employees.id
      AND terminations.effective_date <= DATE('now')
);
```

**Key Points:**

- `EXISTS` returns true if the subquery produces at least one row
- The `SELECT 1` convention is standard — the actual selected value is irrelevant; only row existence matters
- Correlated via `employees.id` — evaluated per row in the outer table

---

### DELETE with CTE

```sql
WITH low_performers AS (
    SELECT id FROM employees
    WHERE salary < 50000.00
      AND dept = 'Operations'
)
DELETE FROM employees
WHERE id IN (SELECT id FROM low_performers);
```

**Key Points:**

- CTE support in `DELETE` requires SQLite 3.35.0+
- The CTE is read-only — it supplies row identifiers; the actual deletion targets the main table
- Useful when the filter logic is complex enough to benefit from named decomposition

---

### Conflict Resolution in DELETE

`DELETE` supports `OR` conflict resolution clauses, though they are less commonly applicable than in `INSERT` or `UPDATE`.

```sql
DELETE OR IGNORE FROM employees WHERE id = 99;
DELETE OR ROLLBACK FROM employees WHERE id = 1;
```

**Key Points:**

- Conflicts during `DELETE` most commonly arise from triggers that perform inserts or updates on constrained columns
- The same conflict variants apply: `OR ABORT` (default), `OR FAIL`, `OR IGNORE`, `OR REPLACE`, `OR ROLLBACK`
- In practice, `OR IGNORE` is the most useful variant for `DELETE` — it suppresses errors from constraint violations triggered by the deletion

---

### Cascade Deletes via Foreign Keys

SQLite supports `ON DELETE CASCADE` when foreign keys are enabled.

```sql
PRAGMA foreign_keys = ON;

CREATE TABLE departments (
    id   INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE employees (
    id      INTEGER PRIMARY KEY,
    name    TEXT,
    dept_id INTEGER REFERENCES departments(id) ON DELETE CASCADE
);

-- Deleting a department removes all linked employees
DELETE FROM departments WHERE id = 3;
```

**Key Points:**

- Foreign key enforcement is **disabled by default** in SQLite — `PRAGMA foreign_keys = ON;` must be set per connection
- `ON DELETE CASCADE` removes child rows automatically when the parent row is deleted
- Other options: `ON DELETE SET NULL`, `ON DELETE SET DEFAULT`, `ON DELETE RESTRICT`, `ON DELETE NO ACTION`
- [Inference] Cascade behavior is not triggered if foreign keys are off — deletions may leave orphaned rows silently; always verify `PRAGMA foreign_keys;` returns `1` before relying on cascade behavior

---

### PRAGMA foreign_keys Behavior

```sql
-- Check current state
PRAGMA foreign_keys;
-- 0 = disabled (default), 1 = enabled

-- Enable for current connection
PRAGMA foreign_keys = ON;
```

**Key Points:**

- Must be set after every new connection — it does not persist
- Has no effect inside a transaction — set it before `BEGIN`
- [Unverified] Some SQLite builds or wrapper libraries may enable this automatically — verify in your environment

---

### Verifying Deletions with changes()

```sql
DELETE FROM employees
WHERE dept = 'Temp';

SELECT changes();
```

**Output:**

```
4
```

**Key Points:**

- Returns the row count affected by the most recent `INSERT`, `UPDATE`, or `DELETE`
- Returns `0` if no rows matched the `WHERE` condition — useful for detecting no-op deletes
- Does not count rows removed by cascading foreign key actions — use `total_changes()` for that
- Scoped to the current connection

---

### TRUNCATE Equivalent

SQLite has no `TRUNCATE` statement. The closest equivalent is:

```sql
DELETE FROM employees;
```

Or, for full reset including `rowid` sequence:

```sql
DROP TABLE employees;
CREATE TABLE employees ( ... );
```

**Key Points:**

- `DELETE FROM table` without `WHERE` is a full-table delete but does not reclaim disk space immediately
- Run `VACUUM` afterward to reclaim space if needed:

```sql
VACUUM;
```

- [Inference] `VACUUM` rewrites the entire database file — on large databases this can be slow and temporarily doubles disk usage; run outside of peak usage windows

---

### DELETE with LIMIT and ORDER BY

Available only in SQLite builds compiled with `SQLITE_ENABLE_UPDATE_DELETE_LIMIT`.

```sql
DELETE FROM employees
ORDER BY salary ASC
LIMIT 3;
```

**Key Points:**

- Deletes only the first N rows matching the sort order
- `ORDER BY` is required when `LIMIT` is used in `DELETE`
- Not available in all distributions — check with:

```sql
PRAGMA compile_options;
-- Look for: ENABLE_UPDATE_DELETE_LIMIT
```

- [Unverified] Do not assume this feature is present without confirming compile options in your environment

---

### Safe DELETE Practices

Always verify which rows will be affected before deleting.

```sql
-- Step 1: Preview affected rows
SELECT * FROM employees
WHERE dept = 'Temp' AND salary < 55000.00;

-- Step 2: If correct, delete within a transaction
BEGIN;

DELETE FROM employees
WHERE dept = 'Temp' AND salary < 55000.00;

SELECT changes(); -- Confirm row count

COMMIT;

-- Or roll back if result is unexpected:
-- ROLLBACK;
```

**Key Points:**

- The `SELECT` preview uses the identical `WHERE` clause — copy-paste to avoid divergence
- Wrapping in `BEGIN ... COMMIT` allows inspection and rollback before finalizing
- `changes()` inside the transaction confirms the count before `COMMIT`
- [Inference] In application code, using parameterized queries reduces the risk of accidental full-table deletes from malformed `WHERE` clauses — behavior depends on the driver and how queries are constructed

---

### Soft Delete Pattern

A common alternative to physical deletion — mark rows as inactive instead of removing them.

```sql
ALTER TABLE employees ADD COLUMN deleted_at TEXT DEFAULT NULL;

-- Soft delete
UPDATE employees
SET deleted_at = DATETIME('now')
WHERE id = 7;

-- Query only active rows
SELECT * FROM employees
WHERE deleted_at IS NULL;

-- Restore
UPDATE employees
SET deleted_at = NULL
WHERE id = 7;
```

**Key Points:**

- Preserves history and allows recovery without a backup
- Requires all queries to include `WHERE deleted_at IS NULL` to exclude deleted rows — a partial index helps:

```sql
CREATE INDEX idx_employees_active
ON employees (dept, salary)
WHERE deleted_at IS NULL;
```

- [Inference] The partial index is only used by queries that include the matching `WHERE deleted_at IS NULL` condition — query plans should be verified with `EXPLAIN QUERY PLAN`
- Disk usage grows over time — periodic archival or purging of soft-deleted rows may be needed

---

**Conclusion:** SQLite's `DELETE` ranges from simple single-row removals to subquery-driven bulk deletions and cascade operations. Key behaviors to internalize: foreign keys are off by default and must be enabled per connection; `AUTOINCREMENT` sequences are not reset by `DELETE`; `RETURNING` and CTE support require SQLite 3.35.0+. Wrapping destructive operations in transactions and previewing with `SELECT` first are the most reliable safeguards against unintended data loss.

**Next Steps:**

- Transactions and savepoints
- Foreign key constraints and referential integrity
- Triggers (which can fire on `DELETE` events)
- Indexes and their effect on DELETE performance

---

