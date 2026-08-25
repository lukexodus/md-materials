## UPDATE Operations in SQLite


---

### Basic Syntax

The `UPDATE` statement modifies existing rows in a table.

```sql
UPDATE table_name
SET column1 = value1, column2 = value2
WHERE condition;
```

**Key Points:**

- `SET` accepts one or more column assignments, comma-separated
- `WHERE` is optional but omitting it updates **every row** in the table
- SQLite processes the `WHERE` filter before applying `SET` assignments
- No rows are added or removed — only existing row values change

---

### Single Column Update

```sql
UPDATE employees
SET salary = 105000.00
WHERE id = 1;
```

---

### Multiple Column Update

```sql
UPDATE employees
SET salary = 105000.00,
    dept   = 'Senior Engineering'
WHERE id = 1;
```

**Key Points:**

- All assignments in a single `SET` clause are applied atomically to each matching row
- Column order in `SET` does not matter
- [Inference] Assignments do not chain within the same `SET` — each right-hand side expression is evaluated using the row's _original_ values before any updates in that statement take effect; behavior should be tested in your environment

---

### Updating All Rows

Omitting `WHERE` applies the change to every row.

```sql
UPDATE employees
SET salary = salary * 1.05;
```

**Key Points:**

- This is valid and intentional in some cases (e.g., applying a universal raise)
- There is no confirmation prompt — execute with care
- [Inference] Wrapping in a transaction allows rollback if the result is not as intended

---

### UPDATE with Expressions

The right-hand side of `SET` can be any valid expression.

```sql
-- Percentage increase
UPDATE employees
SET salary = salary * 1.10
WHERE dept = 'Engineering';

-- String update with concatenation
UPDATE employees
SET name = name || ' (Contractor)'
WHERE dept = 'IT';

-- Conditional assignment using CASE
UPDATE employees
SET salary = CASE
    WHEN dept = 'Engineering' THEN salary * 1.10
    WHEN dept = 'Design'      THEN salary * 1.07
    ELSE                           salary * 1.03
END;
```

**Key Points:**

- Expressions can reference the column being updated (e.g., `salary = salary * 1.1`)
- `CASE` in `SET` allows row-by-row conditional logic without multiple statements
- String, numeric, and date functions are all valid in `SET` expressions

---

### UPDATE with WHERE and Multiple Conditions

```sql
UPDATE employees
SET salary = 95000.00
WHERE dept = 'Marketing'
  AND salary < 80000.00;
```

```sql
UPDATE employees
SET dept = 'General'
WHERE dept IS NULL;
```

**Key Points:**

- All `WHERE` clauses from `SELECT` apply here: `AND`, `OR`, `IN`, `BETWEEN`, `LIKE`, `IS NULL`
- `NULL` assignments require `= NULL` in `SET` (unlike `WHERE`, where you must use `IS NULL`)

**Example — setting a column to NULL:**

```sql
UPDATE employees
SET dept = NULL
WHERE id = 5;
```

---

### UPDATE with RETURNING

Available in SQLite 3.35.0+. Returns data from the rows that were modified.

```sql
UPDATE employees
SET salary = salary * 1.10
WHERE dept = 'Engineering'
RETURNING id, name, salary;
```

**Output:**

```
1 | Alice | 104500.00
4 | David | 111100.00
```

**Key Points:**

- `RETURNING *` returns all columns of the updated rows
- Useful for retrieving new computed values without a follow-up `SELECT`
- Returns the row values **after** the update is applied
- Behavior depends on SQLite version — verify `SQLITE_VERSION()` in your environment

---

### UPDATE with Subquery in SET

A subquery can supply the new value for a column.

```sql
UPDATE employees
SET salary = (
    SELECT AVG(salary)
    FROM employees
    WHERE dept = 'Engineering'
)
WHERE dept = 'Engineering'
  AND salary < 70000.00;
```

**Key Points:**

- The subquery must return a single value (scalar subquery)
- If the subquery returns no rows, the column is set to `NULL`
- [Inference] The subquery is evaluated once per updated row in SQLite's default behavior — test with your data to confirm expected results

---

### UPDATE with Subquery in WHERE

Filter rows to update based on a subquery result.

```sql
UPDATE employees
SET salary = salary * 1.05
WHERE id IN (
    SELECT id FROM employees
    WHERE dept = 'Engineering'
      AND salary < (SELECT AVG(salary) FROM employees)
);
```

**Key Points:**

- Subqueries in `WHERE` follow the same rules as in `SELECT` statements
- Correlated subqueries are supported but [Inference] may be slower on large tables without appropriate indexes — verify with `EXPLAIN QUERY PLAN`

---

### UPDATE with JOIN (via Subquery)

SQLite does not support `UPDATE ... JOIN` syntax directly. Joins are expressed using subqueries or the `FROM` clause (added in SQLite 3.33.0).

#### Using a Subquery (all versions):

```sql
UPDATE employees
SET salary = salary * 1.08
WHERE id IN (
    SELECT e.id
    FROM employees e
    JOIN departments d ON e.dept = d.name
    WHERE d.budget_tier = 'high'
);
```

#### Using FROM clause (SQLite 3.33.0+):

```sql
UPDATE employees
SET salary = employees.salary * 1.08
FROM departments
WHERE employees.dept = departments.name
  AND departments.budget_tier = 'high';
```

**Key Points:**

- The `FROM` clause form is more readable and closer to PostgreSQL syntax
- Both achieve the same logical result — [Inference] performance may differ depending on indexes and query plan; use `EXPLAIN QUERY PLAN` to compare
- Always qualify column names with table names when using `FROM` to avoid ambiguity

---

### UPDATE with CTE (Common Table Expression)

```sql
WITH engineering_avg AS (
    SELECT AVG(salary) AS avg_sal
    FROM employees
    WHERE dept = 'Engineering'
)
UPDATE employees
SET salary = (SELECT avg_sal FROM engineering_avg)
WHERE dept = 'Engineering'
  AND salary < (SELECT avg_sal FROM engineering_avg);
```

**Key Points:**

- CTEs in `UPDATE` are supported in SQLite 3.35.0+
- The CTE is referenced like a subquery in both `SET` and `WHERE`
- Useful for readability when the same derived value is needed in multiple places

---

### Conflict Resolution in UPDATE

Like `INSERT`, `UPDATE` supports `OR` conflict resolution clauses.

```sql
UPDATE OR IGNORE employees
SET id = 99
WHERE name = 'Alice';

UPDATE OR REPLACE employees
SET id = 99
WHERE name = 'Alice';

UPDATE OR ROLLBACK employees
SET id = 99
WHERE name = 'Alice';
```

| Variant                | On Constraint Violation                                  |
| ---------------------- | -------------------------------------------------------- |
| `OR ABORT` _(default)_ | Rolls back the statement, not the transaction            |
| `OR FAIL`              | Stops at the failing row; prior rows in statement remain |
| `OR IGNORE`            | Skips the conflicting row silently                       |
| `OR REPLACE`           | Deletes the conflicting row, then applies the update     |
| `OR ROLLBACK`          | Rolls back the entire transaction                        |

**Key Points:**

- These mirror the `INSERT OR ...` variants in behavior
- `OR REPLACE` in an `UPDATE` context deletes the _other_ row that conflicts, then proceeds — not the row being updated
- Trigger behavior during conflict resolution may vary — test in your environment

---

### Verifying Updates with changes()

`changes()` returns the number of rows affected by the most recent `INSERT`, `UPDATE`, or `DELETE`.

```sql
UPDATE employees
SET salary = 75000.00
WHERE dept = 'HR';

SELECT changes();
```

**Output:**

```
3
```

**Key Points:**

- Returns `0` if no rows matched the `WHERE` condition
- Scoped to the current database connection
- Does not reflect rows changed by triggers — for that, use `total_changes()`

---

### Safe UPDATE Practices

**Key Points:**

- Always run a `SELECT` with the same `WHERE` clause before executing an `UPDATE` to verify which rows will be affected
- Wrap updates in a transaction to allow rollback:

```sql
BEGIN;

UPDATE employees
SET dept = 'Restructured'
WHERE dept = 'Operations';

-- Verify
SELECT * FROM employees WHERE dept = 'Restructured';

-- If correct:
COMMIT;

-- If not:
-- ROLLBACK;
```

- Use `LIMIT` in `UPDATE` to cap the number of rows affected (requires SQLite compiled with `SQLITE_ENABLE_UPDATE_DELETE_LIMIT`):

```sql
UPDATE employees
SET salary = 80000.00
WHERE dept = 'Marketing'
ORDER BY salary ASC
LIMIT 3;
```

**Key Points on LIMIT in UPDATE:**

- Not available in all SQLite builds — check with `PRAGMA compile_options;`
- `ORDER BY` must accompany `LIMIT` in `UPDATE` to define which rows are selected
- [Unverified] availability depends on compile-time flags; do not assume this is present without verification

---

### Checking for Unintended Full-Table Updates

SQLite does not warn before a full-table update. [Inference] It is good practice to check `WHERE` clause presence before executing in scripts or applications — some database wrappers or ORMs may offer safeguards, but SQLite itself does not.

```sql
-- Dangerous: no WHERE clause
UPDATE employees SET dept = 'Unknown';

-- Safer pattern: always verify row count first
SELECT COUNT(*) FROM employees WHERE dept IS NULL;
UPDATE employees SET dept = 'Unknown' WHERE dept IS NULL;
```

---

**Conclusion:** SQLite's `UPDATE` supports a range of patterns from simple single-column changes to conditional `CASE` expressions, subquery-driven updates, and conflict-aware variants. The `FROM` clause and `RETURNING` clause extend its capabilities in newer versions. For safety, wrapping updates in transactions, verifying row counts beforehand, and using `changes()` to confirm results are recommended practices. Always verify version-dependent features like `RETURNING`, `FROM`, and `LIMIT` against your environment.

**Next Steps:**

- DELETE operations and safe deletion patterns
- Transactions and savepoints
- Triggers (which fire on `UPDATE` events)
- Indexes and their effect on UPDATE performance

---

