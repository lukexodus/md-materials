## LIMIT and OFFSET for Pagination in SQLite


---

### Purpose

`LIMIT` restricts how many rows a query returns. `OFFSET` skips a number of rows before returning results. Together they are the foundation of offset-based pagination.

```sql
SELECT column1, column2
FROM table_name
ORDER BY column1
LIMIT n OFFSET m;
```

**Key Points:**

- `LIMIT` and `OFFSET` are evaluated last in the logical processing order — after `WHERE`, `GROUP BY`, `HAVING`, `SELECT`, `DISTINCT`, and `ORDER BY`
- `ORDER BY` is required for pagination to be deterministic — without it, the rows returned per page are undefined
- Both accept integer expressions or bound parameters — negative values for `LIMIT` are treated as no limit in SQLite; negative `OFFSET` produces an error in most contexts

---

### LIMIT

Returns at most N rows.

```sql
-- Return first 10 rows by salary
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 10;
```

**Key Points:**

- Returns fewer than N rows if the result set contains fewer
- `LIMIT 0` returns no rows — valid; occasionally useful for checking query structure without fetching data
- `LIMIT -1` returns all rows — SQLite-specific behavior; not portable

---

### OFFSET

Skips M rows before returning results.

```sql
-- Skip first 10 rows, return next 10
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 10 OFFSET 10;
```

**Key Points:**

- `OFFSET 0` is the same as no offset
- Offset is zero-based — `OFFSET 10` skips rows 1 through 10 and returns from row 11
- `OFFSET` without `LIMIT` is not valid in SQLite — `LIMIT` must be present

---

### Comma Syntax (Alternative Form)

SQLite supports a legacy two-argument `LIMIT` form.

```sql
-- LIMIT offset, count  (comma syntax)
SELECT name, salary FROM employees ORDER BY salary DESC LIMIT 10, 10;
-- Equivalent to: LIMIT 10 OFFSET 10
```

**Key Points:**

- Argument order is `offset, count` — the **opposite** of the `LIMIT count OFFSET offset` form
- [Inference] This is a common source of errors — the keyword form (`LIMIT n OFFSET m`) is clearer and less error-prone
- Comma syntax is a SQLite/MySQL convention — not standard SQL; avoid if portability matters

---

### Basic Pagination Pattern

Page size of 10, navigating through pages.

```sql
-- Page 1 (rows 1–10)
SELECT name, dept, salary FROM employees
ORDER BY id ASC
LIMIT 10 OFFSET 0;

-- Page 2 (rows 11–20)
SELECT name, dept, salary FROM employees
ORDER BY id ASC
LIMIT 10 OFFSET 10;

-- Page 3 (rows 21–30)
SELECT name, dept, salary FROM employees
ORDER BY id ASC
LIMIT 10 OFFSET 20;
```

**Formula:**

```
OFFSET = (page_number - 1) * page_size
```

**Parameterized form:**

```sql
SELECT name, dept, salary FROM employees
ORDER BY id ASC
LIMIT :page_size OFFSET :offset;
```

```python
page_size = 10
page_number = 3
offset = (page_number - 1) * page_size

conn.execute(
    'SELECT name, dept, salary FROM employees ORDER BY id ASC LIMIT ? OFFSET ?',
    (page_size, offset)
)
```

---

### Getting Total Row Count for Pagination

To compute total pages, a separate count query is needed.

```sql
SELECT COUNT(*) AS total FROM employees WHERE dept = 'Engineering';
```

```python
total = conn.execute(
    'SELECT COUNT(*) FROM employees WHERE dept = ?', ('Engineering',)
).fetchone()[0]

total_pages = (total + page_size - 1) // page_size  # ceiling division
```

**Key Points:**

- The `COUNT(*)` query must use the same `WHERE` conditions as the data query
- [Inference] Running two queries (count + data) per page request is the standard approach — there is no single SQLite statement that returns both the count and the page simultaneously
- For large tables with complex `WHERE` clauses, the count query may be slow — caching the count or using approximate counts may be appropriate depending on use case

---

### The OFFSET Performance Problem

`OFFSET` works by scanning and discarding rows up to the offset value.

```sql
-- SQLite scans and discards 90,000 rows, then returns 10
SELECT name, salary FROM employees
ORDER BY salary DESC
LIMIT 10 OFFSET 90000;
```

**Key Points:**

- SQLite does not jump directly to the offset position — it reads through all preceding rows
- [Inference] Query time increases approximately linearly with offset size for unsorted or unindexed data; on indexed sorts the cost may be lower but is still present
- For small tables or modest page depths, offset pagination is typically acceptable
- For large tables or deep pages, keyset pagination is the recommended alternative

---

### Keyset Pagination (Seek Method)

Instead of skipping rows, keyset pagination filters from the last seen value.

#### Simple keyset on a unique column:

```sql
-- First page
SELECT id, name, salary
FROM employees
ORDER BY id ASC
LIMIT 10;

-- Next page: pass the last seen id from the previous page
SELECT id, name, salary
FROM employees
WHERE id > :last_id
ORDER BY id ASC
LIMIT 10;
```

**Key Points:**

- No rows are scanned and discarded — the `WHERE` clause jumps directly to the next set
- [Inference] Requires an index on the sort/filter column — without one, performance may not improve over offset; verify with `EXPLAIN QUERY PLAN`
- Does not support arbitrary page jumps — only sequential forward (and, with modification, backward) navigation
- The sort column must be unique, or a composite tiebreaker must be added to ensure stable page boundaries

---

### Keyset Pagination with Non-Unique Sort Column

When sorting by a non-unique column (e.g., `salary`), ties must be broken with a unique column.

```sql
-- First page
SELECT id, name, salary
FROM employees
ORDER BY salary DESC, id ASC
LIMIT 10;

-- Next page: use both last_salary and last_id as the boundary
SELECT id, name, salary
FROM employees
WHERE salary < :last_salary
   OR (salary = :last_salary AND id > :last_id)
ORDER BY salary DESC, id ASC
LIMIT 10;
```

**Key Points:**

- The `OR` condition handles rows with the same salary as the last row on the previous page
- Both conditions together define an unambiguous page boundary
- [Inference] The `OR` may limit index use on some query planners — an alternative using a composite key or row value comparison may be more index-friendly; verify with `EXPLAIN QUERY PLAN`
- Cannot jump to an arbitrary page by number — keyset pagination is inherently sequential

---

### Keyset Pagination — Backward Navigation

```sql
-- Previous page: reverse the comparison and sort, then re-reverse the result
SELECT id, name, salary FROM (
    SELECT id, name, salary
    FROM employees
    WHERE salary > :last_salary
       OR (salary = :last_salary AND id < :last_id)
    ORDER BY salary ASC, id DESC
    LIMIT 10
) sub
ORDER BY salary DESC, id ASC;
```

**Key Points:**

- Reverses the sort direction in the inner query to collect the preceding page
- The outer query re-applies the original sort order for consistent presentation
- [Inference] More complex to implement and test than forward-only pagination — ensure boundary conditions are covered in testing

---

### Offset vs. Keyset Comparison

|Characteristic|Offset Pagination|Keyset Pagination|
|---|---|---|
|Arbitrary page jump|✅ Supported|❌ Sequential only|
|Performance at depth|Degrades with offset|Consistent|
|Implementation complexity|Simple|Moderate|
|Requires unique sort key|No|Yes (or composite)|
|Row skip on insert/delete|✅ Can occur|❌ Stable boundaries|
|Index dependency|Optional|Required for performance|
|Total page count|Easy (COUNT query)|Requires separate count|

---

### Row Skipping and Duplication with Offset

A known hazard of offset pagination: concurrent inserts or deletes shift row positions.

```sql
-- Page 1 returns rows 1–10
-- A new row is inserted at position 5 before page 2 is fetched
-- Page 2 (OFFSET 10) now starts at what was row 11 — row 10 is skipped
```

**Key Points:**

- Row insertion before the current offset causes a row to be skipped on the next page
- Row deletion before the current offset causes a row to be duplicated (seen on two pages)
- [Inference] In read-heavy or static datasets this is rarely a problem — in high-write environments it is a significant hazard
- Keyset pagination is not affected by this problem — the `WHERE` clause anchors to values, not positions

---

### LIMIT in Subqueries

`LIMIT` inside a subquery restricts the subquery's result independently.

```sql
-- Get the top 3 earners per department
SELECT e.name, e.dept, e.salary
FROM employees e
WHERE e.id IN (
    SELECT id FROM employees
    WHERE dept = e.dept
    ORDER BY salary DESC
    LIMIT 3
);
```

**Key Points:**

- `LIMIT` in a correlated subquery applies per outer row evaluation — [Inference] may be slow on large tables; a window function (`ROW_NUMBER()`) is often more efficient for top-N-per-group queries in SQLite 3.25.0+
- `LIMIT` in a non-correlated subquery limits the subquery result set once

```sql
-- Limit source rows for an INSERT
INSERT INTO top_earners (name, salary)
SELECT name, salary FROM employees
ORDER BY salary DESC
LIMIT 10;
```

---

### LIMIT with Aggregate Queries

```sql
-- Top 3 departments by average salary
SELECT dept, AVG(salary) AS avg_sal
FROM employees
GROUP BY dept
ORDER BY avg_sal DESC
LIMIT 3;
```

**Key Points:**

- `LIMIT` applies to the grouped result — after `GROUP BY` and `HAVING`
- Useful for top-N group queries

---

### Window Function Alternative for Top-N

For top-N rows per group, `ROW_NUMBER()` is cleaner than correlated subqueries with `LIMIT`. Requires SQLite 3.25.0+.

```sql
SELECT name, dept, salary
FROM (
    SELECT
        name, dept, salary,
        ROW_NUMBER() OVER (
            PARTITION BY dept ORDER BY salary DESC
        ) AS rn
    FROM employees
)
WHERE rn <= 3;
```

**Key Points:**

- Assigns a sequential number within each department partition, ordered by salary
- Outer `WHERE rn <= 3` returns only the top 3 per department
- [Inference] Generally more efficient than a correlated subquery with `LIMIT` for this pattern — avoids re-scanning the table per department; verify with `EXPLAIN QUERY PLAN`
- Requires SQLite 3.25.0+ — verify with `SELECT SQLITE_VERSION();`

---

### Using LIMIT for Existence Checks

`LIMIT 1` is an efficient pattern for checking whether any row matches a condition.

```sql
-- Check if any engineer earns above 100k
SELECT 1 FROM employees
WHERE dept = 'Engineering' AND salary > 100000
LIMIT 1;
```

```python
exists = conn.execute(
    'SELECT 1 FROM employees WHERE dept = ? AND salary > ? LIMIT 1',
    ('Engineering', 100000)
).fetchone() is not None
```

**Key Points:**

- Returns at most one row — SQLite stops scanning after finding the first match
- [Inference] More efficient than `COUNT(*) > 0` for existence checks — avoids counting all matching rows; actual difference depends on indexes and data distribution
- `EXISTS (SELECT 1 ...)` in a subquery context achieves the same effect

---

### LIMIT 0 — Schema Inspection Without Data

```sql
SELECT * FROM employees LIMIT 0;
```

**Key Points:**

- Returns no rows but provides column metadata (names and types) via the cursor
- Useful in application code to inspect result shape without fetching data:

```python
cursor = conn.execute('SELECT * FROM employees LIMIT 0')
columns = [desc[0] for desc in cursor.description]
```

---

### Parameterized LIMIT and OFFSET

Always use parameters when `LIMIT` and `OFFSET` values come from user input.

```python
# Safe: parameterized
conn.execute(
    'SELECT * FROM employees ORDER BY id LIMIT ? OFFSET ?',
    (page_size, offset)
)

# Unsafe: string interpolation — avoid
conn.execute(
    f'SELECT * FROM employees ORDER BY id LIMIT {page_size} OFFSET {offset}'
)
```

**Key Points:**

- [Inference] SQLite parameters for `LIMIT` and `OFFSET` accept integer values — passing non-integer types may cause errors or unexpected behavior depending on the driver; validate input before binding
- String interpolation of user-supplied values introduces SQL injection risk even for numeric inputs — parameterization is always safer

---

### Pagination with Filtering and Sorting

Real pagination queries combine `WHERE`, `ORDER BY`, `LIMIT`, and `OFFSET`.

```sql
SELECT id, name, dept, salary
FROM employees
WHERE dept = :dept
  AND salary >= :min_salary
ORDER BY salary DESC, id ASC
LIMIT :page_size OFFSET :offset;
```

```python
def get_page(conn, dept, min_salary, page_number, page_size=10):
    offset = (page_number - 1) * page_size
    rows = conn.execute(
        '''
        SELECT id, name, dept, salary
        FROM employees
        WHERE dept = ? AND salary >= ?
        ORDER BY salary DESC, id ASC
        LIMIT ? OFFSET ?
        ''',
        (dept, min_salary, page_size, offset)
    ).fetchall()
    return rows
```

**Key Points:**

- The `id ASC` tiebreaker ensures deterministic ordering when salaries are equal
- All filter parameters are bound — avoids injection risk
- The same `WHERE` clause should be used in a companion `COUNT(*)` query for total page calculation

---

### Index Support for LIMIT Queries

An index on the `ORDER BY` column(s) allows SQLite to stop scanning early when `LIMIT` is small.

```sql
CREATE INDEX idx_salary_id ON employees (salary DESC, id ASC);

-- With LIMIT, SQLite reads only as many index entries as needed
SELECT id, name, salary
FROM employees
ORDER BY salary DESC, id ASC
LIMIT 10;
```

**Key Points:**

- Without an index, SQLite sorts the entire result set then returns the first N rows
- With a matching index, SQLite reads only the first N entries from the index — [Inference] dramatically faster for small `LIMIT` values on large tables; verify with `EXPLAIN QUERY PLAN`
- The index direction (`DESC`/`ASC`) should match the `ORDER BY` direction for optimal use
- Look for absence of `USE TEMP B-TREE FOR ORDER BY` in `EXPLAIN QUERY PLAN` output as confirmation

```sql
EXPLAIN QUERY PLAN
SELECT id, name, salary FROM employees
ORDER BY salary DESC, id ASC
LIMIT 10;
```

**Good output:**

```
SCAN employees USING INDEX idx_salary_id
```

**Output indicating a sort step:**

```
SCAN employees
USE TEMP B-TREE FOR ORDER BY
```

---

### LIMIT and OFFSET in CTEs

```sql
WITH ranked AS (
    SELECT id, name, dept, salary
    FROM employees
    WHERE dept = 'Engineering'
    ORDER BY salary DESC
    LIMIT 10 OFFSET 0
)
SELECT * FROM ranked;
```

**Key Points:**

- `LIMIT` and `OFFSET` inside a CTE apply to the CTE's result independently
- [Inference] The outer query cannot further rely on the CTE's internal order — apply `ORDER BY` in the outer query if order of the final result matters
- CTEs with `LIMIT` are useful for pre-filtering large tables before joining or further processing

---

### Common LIMIT / OFFSET Mistakes

#### Missing ORDER BY:

```sql
-- Non-deterministic — different pages may return overlapping or missing rows
SELECT * FROM employees LIMIT 10 OFFSET 10;

-- Correct
SELECT * FROM employees ORDER BY id ASC LIMIT 10 OFFSET 10;
```

#### Confusing comma syntax argument order:

```sql
-- Returns 20 rows starting at offset 10 — NOT 10 rows at offset 20
SELECT * FROM employees ORDER BY id LIMIT 10, 20;

-- Clearer equivalent
SELECT * FROM employees ORDER BY id LIMIT 20 OFFSET 10;
```

#### Offset pagination on a volatile table:

```sql
-- Rows inserted or deleted between page requests shift positions
-- Use keyset pagination for write-heavy tables
```

#### Not filtering NULL in sort column for keyset:

```sql
-- If salary can be NULL, boundary comparison may behave unexpectedly
WHERE salary < :last_salary  -- NULL salaries excluded unpredictably

-- Safer: exclude NULLs or handle explicitly
WHERE salary < :last_salary AND salary IS NOT NULL
```

---

### Quick Reference

```sql
-- First N rows
SELECT ... ORDER BY col LIMIT N;

-- Page P with page size N (1-based page number)
SELECT ... ORDER BY col LIMIT N OFFSET (P - 1) * N;

-- Existence check
SELECT 1 FROM ... WHERE ... LIMIT 1;

-- Top N per group (window function)
SELECT ... FROM (
    SELECT ..., ROW_NUMBER() OVER (PARTITION BY group_col ORDER BY sort_col DESC) AS rn
    FROM ...
) WHERE rn <= N;

-- Keyset next page
SELECT ... FROM ... WHERE sort_col < :last_val ORDER BY sort_col DESC LIMIT N;

-- Schema inspection, no data
SELECT * FROM table LIMIT 0;
```

---

**Conclusion:** `LIMIT` and `OFFSET` cover most pagination needs in SQLite, but carry a well-known performance cost at depth and a data consistency hazard in write-heavy environments. For small tables or shallow pagination, offset-based pagination is straightforward and acceptable. For large datasets, deep pages, or high-write scenarios, keyset pagination provides consistent performance and stable boundaries. Regardless of approach, `ORDER BY` with a unique tiebreaker is required for reliable results, and an index on the sort column is the most impactful performance optimization.

**Next Steps:**

- Window functions — ROW_NUMBER, RANK, DENSE_RANK
- Indexes — covering indexes for sort and pagination queries
- Query optimization and EXPLAIN QUERY PLAN
- Joins and filtered pagination across multiple tables

---

