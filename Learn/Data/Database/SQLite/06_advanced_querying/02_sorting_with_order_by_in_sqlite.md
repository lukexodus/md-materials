## Sorting with ORDER BY in SQLite


---

### Basic Syntax

`ORDER BY` controls the sequence in which rows are returned.

```sql
SELECT column1, column2
FROM table_name
ORDER BY column1 ASC;
```

**Key Points:**

- `ORDER BY` is the only reliable way to guarantee row order — without it, SQLite may return rows in any order, including insertion order, but this is not guaranteed
- `ASC` (ascending) is the default and can be omitted
- `ORDER BY` is evaluated after `WHERE`, `GROUP BY`, and `HAVING`, but before `LIMIT` and `OFFSET`
- Applies to `SELECT` statements only — not directly to `UPDATE` or `DELETE` unless compiled with `SQLITE_ENABLE_UPDATE_DELETE_LIMIT`

---

### ASC and DESC

```sql
-- Ascending (default): lowest to highest
SELECT name, salary FROM employees ORDER BY salary ASC;

-- Descending: highest to lowest
SELECT name, salary FROM employees ORDER BY salary DESC;
```

**Output (DESC):**

```
David  | 101000.0
Alice  | 95000.0
Bob    | 72000.0
Carol  | 68000.0
```

---

### Sorting by Multiple Columns

Columns are sorted left to right — the second column breaks ties in the first.

```sql
SELECT name, dept, salary
FROM employees
ORDER BY dept ASC, salary DESC;
```

**Output:**

```
Carol  | Design      | 68000.0
Alice  | Engineering | 95000.0
David  | Engineering | 101000.0
Bob    | Marketing   | 72000.0
```

**Key Points:**

- Each column in the list can have its own `ASC` or `DESC` direction
- Tie-breaking continues left to right through the column list
- Any number of columns can be listed — [Inference] performance cost increases with each additional sort column on large unsorted datasets

---

### Sorting by Column Position

Columns can be referenced by their position in the `SELECT` list.

```sql
SELECT name, dept, salary
FROM employees
ORDER BY 3 DESC, 2 ASC;
-- Equivalent to: ORDER BY salary DESC, dept ASC
```

**Key Points:**

- Positions are 1-based
- Valid SQL but generally discouraged — position references break silently when `SELECT` columns are reordered
- `ORDER BY 0` or a position exceeding the column count produces an error
- Useful for quick ad hoc queries; avoid in production code or stored views

---

### Sorting by Expression

Any expression valid in `SELECT` can appear in `ORDER BY`.

```sql
-- Sort by computed value
SELECT name, salary
FROM employees
ORDER BY salary * 1.10 DESC;

-- Sort by string length
SELECT name FROM employees
ORDER BY LENGTH(name) ASC;

-- Sort by extracted part of a string
SELECT name, hire_date FROM employees
ORDER BY SUBSTR(hire_date, 1, 4) DESC;  -- Sort by year

-- Sort by CASE expression
SELECT name, dept, salary
FROM employees
ORDER BY
    CASE dept
        WHEN 'Engineering' THEN 1
        WHEN 'Design'      THEN 2
        WHEN 'Marketing'   THEN 3
        ELSE                    4
    END ASC,
    salary DESC;
```

**Key Points:**

- Expressions in `ORDER BY` are evaluated per row — [Inference] applying functions to large result sets without an appropriate index increases sort cost; verify with `EXPLAIN QUERY PLAN`
- The `CASE` pattern above implements a custom sort order — rows are ordered by department priority, then by salary within each department

---

### Sorting by Column Alias

Aliases defined in `SELECT` are available in `ORDER BY`.

```sql
SELECT name, salary * 1.10 AS adjusted_salary
FROM employees
ORDER BY adjusted_salary DESC;
```

**Key Points:**

- SQLite resolves aliases in `ORDER BY` — this is consistent behavior in SQLite but is an extension beyond strict SQL standard in some contexts
- Avoids repeating the expression in both `SELECT` and `ORDER BY`
- Aliases are **not** available in `WHERE` or `HAVING` — only in `ORDER BY`

---

### NULL Ordering

In SQLite, `NULL` values have a defined sort position relative to non-NULL values.

```sql
SELECT name, dept FROM employees ORDER BY dept ASC;
```

|Sort Direction|NULL Position|
|---|---|
|`ASC`|NULLs appear **first** (before all non-NULL values)|
|`DESC`|NULLs appear **last** (after all non-NULL values)|

**Key Points:**

- This is SQLite-specific behavior — other databases (PostgreSQL, Oracle) default to `NULLS LAST` for `ASC`; portability requires explicit handling
- SQLite does not support `NULLS FIRST` / `NULLS LAST` syntax directly (unlike PostgreSQL)
- To control NULL position explicitly, use a `CASE` expression:

```sql
-- Force NULLs to sort last in ASC order
SELECT name, dept
FROM employees
ORDER BY
    CASE WHEN dept IS NULL THEN 1 ELSE 0 END ASC,
    dept ASC;

-- Force NULLs to sort first in DESC order
SELECT name, dept
FROM employees
ORDER BY
    CASE WHEN dept IS NULL THEN 0 ELSE 1 END ASC,
    dept DESC;
```

---

### Sorting Text — Collation

SQLite sorts text using collation sequences that define character comparison rules.

#### Built-in Collations

|Collation|Behavior|
|---|---|
|`BINARY`|Byte-by-byte comparison; case-sensitive; default|
|`NOCASE`|Case-insensitive for ASCII A–Z; Unicode not covered|
|`RTRIM`|Ignores trailing whitespace; otherwise binary|

```sql
-- Case-insensitive sort
SELECT name FROM employees ORDER BY name COLLATE NOCASE ASC;

-- Binary (default): uppercase before lowercase in ASCII order
SELECT name FROM employees ORDER BY name COLLATE BINARY ASC;
```

**Key Points:**

- Without `COLLATE`, the column's defined collation is used — default is `BINARY`
- `NOCASE` only covers ASCII A–Z — [Unverified] behavior for accented or non-Latin characters depends on the SQLite build; ICU extension may be needed for full Unicode collation
- Collation can be specified per `ORDER BY` column, overriding the column's default:

```sql
SELECT name FROM employees
ORDER BY name COLLATE NOCASE ASC, dept COLLATE BINARY DESC;
```

#### Collation on Column Definition

```sql
CREATE TABLE employees (
    name TEXT COLLATE NOCASE,
    dept TEXT
);

-- Uses NOCASE automatically (defined on column)
SELECT * FROM employees ORDER BY name;
```

**Key Points:**

- Column-level collation applies automatically in `ORDER BY`, `WHERE`, and comparisons unless overridden
- Overriding in `ORDER BY` does not change the column's stored collation

---

### Sorting with LIMIT and OFFSET

`ORDER BY` is essential when using `LIMIT` — without it, the returned subset is arbitrary.

```sql
-- Top 5 earners
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 5;

-- Rows 6–10
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 5 OFFSET 5;
```

**Key Points:**

- `LIMIT` without `ORDER BY` returns an unpredictable subset
- `OFFSET` requires a full sort and scan of all preceding rows — [Inference] large offsets on big tables are slow; keyset pagination is more efficient for deep paging:

```sql
-- Keyset pagination: faster than large OFFSET
SELECT name, salary
FROM employees
WHERE salary < :last_salary
   OR (salary = :last_salary AND name > :last_name)
ORDER BY salary DESC, name ASC
LIMIT 10;
```

**Key Points on keyset pagination:**

- Requires a stable, unique sort key (or combination) to define the page boundary
- [Inference] Performance advantage grows as the offset deepens — avoids scanning and discarding rows; behavior depends on index availability

---

### Sorting Across Joins

`ORDER BY` applies to the full joined result.

```sql
SELECT e.name, e.salary, d.budget
FROM employees e
JOIN departments d ON e.dept = d.name
ORDER BY d.budget DESC, e.salary DESC;
```

**Key Points:**

- Any column from any joined table is available in `ORDER BY`
- Qualify column names with table aliases when ambiguity exists
- [Inference] Sort performance depends on whether the sort column is indexed and whether the join result is small enough to sort in memory

---

### Sorting in Subqueries and CTEs

`ORDER BY` in a subquery or CTE does not guarantee order in the outer query.

```sql
-- ORDER BY in subquery has no guaranteed effect on outer result
SELECT * FROM (
    SELECT name, salary FROM employees ORDER BY salary DESC
) sub;
```

**Key Points:**

- SQLite may or may not preserve inner sort order in the outer query — [Inference] this is implementation-dependent and should not be relied upon; always apply `ORDER BY` at the outermost level where order matters
- This is standard SQL behavior — subquery row order is undefined unless the outer query sorts

```sql
-- Correct: sort at the outermost level
SELECT * FROM (
    SELECT name, salary FROM employees WHERE dept = 'Engineering'
) sub
ORDER BY salary DESC;
```

---

### Sorting with DISTINCT

When `DISTINCT` and `ORDER BY` are combined, `ORDER BY` columns must appear in the `SELECT` list.

```sql
-- Valid
SELECT DISTINCT dept FROM employees ORDER BY dept ASC;

-- Invalid in strict mode — salary not in SELECT
SELECT DISTINCT dept FROM employees ORDER BY salary ASC;
```

**Key Points:**

- SQLite may permit ordering by a column not in `SELECT DISTINCT` in some cases — [Inference] this behavior is not guaranteed and may differ across versions; include sort columns in `SELECT` for reliable results
- When `DISTINCT` is present, the sort is applied to the deduplicated result

---

### Sorting with Aggregates and GROUP BY

`ORDER BY` on aggregated queries sorts the grouped result.

```sql
SELECT dept, COUNT(*) AS headcount, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept
ORDER BY avg_salary DESC;
```

```sql
-- Order by aggregate not in SELECT
SELECT dept, COUNT(*) AS headcount
FROM employees
GROUP BY dept
ORDER BY AVG(salary) DESC;
```

**Key Points:**

- Aggregate functions can appear in `ORDER BY` even if not in `SELECT`
- `ORDER BY` is applied after `GROUP BY` and `HAVING`
- Aliases defined in `SELECT` (e.g., `avg_salary`) are available in `ORDER BY`

---

### Stable Sort Behavior

SQLite's sort is not guaranteed to be stable across all versions and configurations.

**Key Points:**

- A stable sort preserves the relative order of rows with equal sort keys
- [Inference] SQLite's sort algorithm may be stable in practice for small result sets but this should not be relied upon — if tie-breaking order matters, include a unique column (e.g., `id`) as the final sort key:

```sql
SELECT name, dept, salary
FROM employees
ORDER BY dept ASC, salary DESC, id ASC;
```

- Adding `id ASC` as the final tiebreaker makes the sort deterministic regardless of internal algorithm behavior

---

### Index Use in ORDER BY

SQLite can use an index to satisfy `ORDER BY` without a separate sort step.

```sql
CREATE INDEX idx_salary ON employees (salary);

-- May use idx_salary to return rows in order without sorting
SELECT name, salary FROM employees ORDER BY salary ASC;
```

**Key Points:**

- When an index covers the sort column(s) in the correct direction, SQLite may scan the index in order — [Inference] eliminates the need for an explicit sort step, which can significantly improve performance on large tables; verify with `EXPLAIN QUERY PLAN`
- Look for `SCAN employees USING INDEX` in the query plan output
- A covering index (includes all `SELECT` columns) further avoids table lookups:

```sql
CREATE INDEX idx_salary_name ON employees (salary, name);

-- Potentially a covering index scan — no table access needed
SELECT name, salary FROM employees ORDER BY salary ASC;
```

- Composite indexes must match the `ORDER BY` column order and direction to be usable — [Inference] an index on `(dept ASC, salary DESC)` may not be used for `ORDER BY dept DESC, salary ASC`; test with `EXPLAIN QUERY PLAN`

---

### EXPLAIN QUERY PLAN for ORDER BY

```sql
EXPLAIN QUERY PLAN
SELECT name, salary FROM employees ORDER BY salary DESC;
```

**Output indicators:**

```
SCAN employees
USE TEMP B-TREE FOR ORDER BY   ← sort performed in memory/temp
```

vs.

```
SCAN employees USING INDEX idx_salary   ← index used; no sort needed
```

**Key Points:**

- `USE TEMP B-TREE FOR ORDER BY` indicates a sort is happening — may be acceptable for small tables, but worth addressing with an index for large ones
- `USING INDEX` in the plan indicates the index is being used for ordering
- [Inference] Index-based ordering avoids materializing and sorting the full result set — likely faster for large tables with selective queries; actual gains depend on row count and hardware

---

### ORDER BY Reference Summary

|Feature|Syntax|Notes|
|---|---|---|
|Ascending|`ORDER BY col ASC`|Default; ASC optional|
|Descending|`ORDER BY col DESC`||
|Multiple columns|`ORDER BY col1 ASC, col2 DESC`|Left to right priority|
|By position|`ORDER BY 2 DESC`|1-based; fragile|
|By alias|`ORDER BY alias DESC`|Alias must be in SELECT|
|By expression|`ORDER BY LENGTH(name)`|Evaluated per row|
|Custom order|`ORDER BY CASE ... END`|Manual priority mapping|
|Collation|`ORDER BY col COLLATE NOCASE`|Overrides column default|
|NULL control|`ORDER BY CASE WHEN col IS NULL ...`|SQLite lacks NULLS FIRST/LAST|
|With LIMIT|`ORDER BY col LIMIT n`|Required for deterministic paging|
|Tiebreaker|`ORDER BY col, id ASC`|Ensures deterministic output|

---

**Conclusion:** `ORDER BY` in SQLite is flexible — supporting column names, aliases, positions, expressions, `CASE` logic, and collation overrides. Key behaviors to internalize: row order without `ORDER BY` is undefined; NULL sort position differs from most other databases; subquery sort order does not propagate to outer queries; and index-backed sorting avoids the `USE TEMP B-TREE` cost for large datasets. For deterministic results, always include a unique tiebreaker as the final sort column.

**Next Steps:**

- LIMIT and OFFSET — pagination patterns
- Indexes — covering indexes and sort optimization
- GROUP BY and aggregate sorting
- EXPLAIN QUERY PLAN in depth

---

