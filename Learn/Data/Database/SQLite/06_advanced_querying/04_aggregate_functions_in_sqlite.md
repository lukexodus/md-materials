## Aggregate Functions in SQLite


---

### What Aggregate Functions Do

Aggregate functions compute a single result from a set of rows. They collapse multiple values into one — a count, total, average, or boundary value.

```sql
SELECT COUNT(*), SUM(salary), AVG(salary), MIN(salary), MAX(salary)
FROM employees;
```

**Key Points:**

- Aggregate functions operate on a set of rows — the entire table, or a group defined by `GROUP BY`
- They appear in `SELECT` and `HAVING` clauses — not directly in `WHERE` (aggregates are not yet computed at that stage)
- All built-in aggregates ignore `NULL` values except `COUNT(*)`
- When no rows match the query, `COUNT(*)` returns `0`; all other aggregates return `NULL`

---

### COUNT

Returns the number of rows or non-NULL values in a set.

#### COUNT(*)

```sql
-- Total rows in the table
SELECT COUNT(*) FROM employees;

-- Total rows matching a condition
SELECT COUNT(*) FROM employees WHERE dept = 'Engineering';
```

**Key Points:**

- Counts every row regardless of NULL values in any column
- The fastest form for row counting — does not evaluate column values
- Returns `0` when no rows match — never returns `NULL`

#### COUNT(column)

```sql
-- Count rows where dept is not NULL
SELECT COUNT(dept) FROM employees;
```

**Key Points:**

- Ignores `NULL` values in the specified column
- `COUNT(dept)` < `COUNT(*)` when `dept` contains NULLs
- Useful for counting how many rows have a value in a specific column

#### COUNT(DISTINCT column)

```sql
-- Count unique departments
SELECT COUNT(DISTINCT dept) FROM employees;
```

**Key Points:**

- Counts distinct non-NULL values
- `DISTINCT` applies only within the aggregate — does not affect other columns in the `SELECT`
- [Inference] May be slower than `COUNT(*)` on large tables without an index on the column — verify with `EXPLAIN QUERY PLAN`

#### COUNT Comparison Example

```sql
SELECT
    COUNT(*)           AS total_rows,
    COUNT(dept)        AS rows_with_dept,
    COUNT(DISTINCT dept) AS unique_depts
FROM employees;
```

**Output:**

```
total_rows | rows_with_dept | unique_depts
10         | 8              | 4
```

---

### SUM

Returns the total of all non-NULL values in a numeric column.

```sql
SELECT SUM(salary) FROM employees;

SELECT SUM(salary) FROM employees WHERE dept = 'Engineering';
```

**Key Points:**

- Returns `NULL` if all values in the set are `NULL` or the set is empty
- Use `COALESCE(SUM(col), 0)` to return `0` instead of `NULL` when needed:

```sql
SELECT COALESCE(SUM(salary), 0) AS total_salary FROM employees;
```

- SQLite stores sums as `INTEGER` or `REAL` depending on input types — [Inference] summing large integers may overflow if the result exceeds SQLite's integer range (±2^63); use `CAST` to `REAL` if overflow is a concern

#### SUM with DISTINCT

```sql
-- Sum of unique salary values only
SELECT SUM(DISTINCT salary) FROM employees;
```

**Key Points:**

- Sums each distinct value once — duplicates are excluded
- Rarely used in practice; typically `SUM(DISTINCT ...)` has a specific analytical purpose

---

### AVG

Returns the arithmetic mean of all non-NULL values.

```sql
SELECT AVG(salary) FROM employees;

SELECT AVG(salary) FROM employees WHERE dept = 'Marketing';
```

**Key Points:**

- Returns `NULL` if all values are `NULL` or the set is empty
- Computed as `SUM(col) / COUNT(col)` — only non-NULL values contribute to both numerator and denominator
- Result is always `REAL` in SQLite regardless of input type
- [Inference] Floating-point precision limits apply — results may have minor rounding imprecision for large or fractional values; use `ROUND()` for display:

```sql
SELECT ROUND(AVG(salary), 2) AS avg_salary FROM employees;
```

#### AVG vs Manual Calculation

```sql
-- These produce the same result
SELECT AVG(salary) FROM employees;
SELECT CAST(SUM(salary) AS REAL) / COUNT(salary) FROM employees;
```

**Key Points:**

- Manual calculation makes NULL handling explicit
- `CAST(SUM(...) AS REAL)` avoids integer division when salary is stored as `INTEGER`

---

### MIN

Returns the smallest non-NULL value in the set.

```sql
SELECT MIN(salary) FROM employees;

SELECT MIN(hire_date) FROM employees;  -- Earliest date (ISO format)
```

**Key Points:**

- Returns `NULL` if all values are `NULL` or the set is empty
- Works on numeric, text (lexicographic), and ISO date strings
- For text, comparison is based on the column's collation — default is `BINARY`
- Does not require a sort of the entire result — [Inference] SQLite may use an index to satisfy `MIN` without a full scan; verify with `EXPLAIN QUERY PLAN`

---

### MAX

Returns the largest non-NULL value in the set.

```sql
SELECT MAX(salary) FROM employees;

SELECT MAX(hire_date) FROM employees;  -- Most recent date (ISO format)
```

**Key Points:**

- Returns `NULL` if all values are `NULL` or the set is empty
- Same collation and index behavior as `MIN`
- `MIN` and `MAX` together define the range:

```sql
SELECT MIN(salary) AS floor, MAX(salary) AS ceiling FROM employees;
```

---

### Using Multiple Aggregates Together

```sql
SELECT
    COUNT(*)                    AS headcount,
    COUNT(DISTINCT dept)        AS departments,
    ROUND(AVG(salary), 2)       AS avg_salary,
    SUM(salary)                 AS payroll,
    MIN(salary)                 AS lowest,
    MAX(salary)                 AS highest,
    MAX(salary) - MIN(salary)   AS salary_range
FROM employees;
```

**Output:**

```
headcount | departments | avg_salary | payroll   | lowest  | highest  | salary_range
10        | 4           | 79700.00   | 797000.00 | 52000.0 | 101000.0 | 49000.0
```

---

### GROUP BY with Aggregates

`GROUP BY` partitions rows into groups — aggregates operate on each group independently.

```sql
SELECT dept, COUNT(*) AS headcount, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY dept;
```

**Output:**

```
dept        | headcount | avg_salary
Design      | 2         | 65500.00
Engineering | 3         | 97000.00
HR          | 2         | 61000.00
Marketing   | 3         | 69333.33
```

**Key Points:**

- Every column in `SELECT` must be either in `GROUP BY` or wrapped in an aggregate function
- SQLite is more permissive than standard SQL — it allows non-aggregated, non-grouped columns in `SELECT`, returning an arbitrary value from the group for that column — [Inference] this is a known SQLite quirk; relying on it produces unpredictable results and should be avoided
- `GROUP BY` can reference column aliases defined in `SELECT` in SQLite — [Inference] this is a SQLite extension; not portable to all databases

#### Grouping by Multiple Columns

```sql
SELECT dept, CASE
    WHEN salary >= 90000 THEN 'Senior'
    WHEN salary >= 70000 THEN 'Mid'
    ELSE 'Junior'
END AS level,
COUNT(*) AS headcount
FROM employees
GROUP BY dept, level
ORDER BY dept, level;
```

**Key Points:**

- Groups are defined by the unique combination of all `GROUP BY` columns
- Can group by expressions and `CASE` results, not just column names

---

### HAVING — Filtering Groups

`HAVING` filters groups after aggregation — analogous to `WHERE` for rows.

```sql
-- Departments with more than 2 employees
SELECT dept, COUNT(*) AS headcount
FROM employees
GROUP BY dept
HAVING COUNT(*) > 2;
```

```sql
-- Departments where average salary exceeds 75000
SELECT dept, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY dept
HAVING AVG(salary) > 75000;
```

**Key Points:**

- `HAVING` can reference aggregate functions — `WHERE` cannot
- `HAVING` can reference `SELECT` aliases in SQLite — [Inference] this is SQLite-specific behavior; not guaranteed in other databases
- Non-aggregate conditions are more efficiently placed in `WHERE` (filtered before grouping) than `HAVING` (filtered after):

```sql
-- Efficient: WHERE excludes rows before grouping
SELECT dept, COUNT(*) AS headcount
FROM employees
WHERE salary > 50000        -- Filters rows before GROUP BY
GROUP BY dept
HAVING COUNT(*) > 1;        -- Filters groups after GROUP BY
```

---

### WHERE vs HAVING

```sql
-- WHERE: filters individual rows before aggregation
-- HAVING: filters groups after aggregation

SELECT dept, AVG(salary) AS avg_sal
FROM employees
WHERE hire_date >= '2021-01-01'   -- Exclude rows before grouping
GROUP BY dept
HAVING AVG(salary) > 70000;       -- Exclude groups after aggregation
```

|Clause|When Applied|Can Use Aggregates|Filters|
|---|---|---|---|
|`WHERE`|Before `GROUP BY`|No|Individual rows|
|`HAVING`|After `GROUP BY`|Yes|Groups|

---

### Aggregate Functions with NULL

```sql
-- Setup: one employee with NULL salary
INSERT INTO employees (name, dept, salary) VALUES ('Zara', 'IT', NULL);

SELECT
    COUNT(*)       AS total_rows,     -- Includes Zara
    COUNT(salary)  AS non_null_sal,   -- Excludes Zara
    SUM(salary)    AS total_sal,      -- Excludes Zara's NULL
    AVG(salary)    AS avg_sal,        -- Excludes Zara from both sum and count
    MIN(salary)    AS min_sal,        -- Excludes Zara
    MAX(salary)    AS max_sal         -- Excludes Zara
FROM employees;
```

**Key Points:**

- `COUNT(*)` includes NULLs; all other aggregates exclude them
- `AVG` excluding NULLs means it is not the same as `SUM / COUNT(*)` when NULLs are present:

```sql
-- These differ when salary contains NULLs
SELECT AVG(salary) FROM employees;
SELECT CAST(SUM(salary) AS REAL) / COUNT(*) FROM employees;
```

- To include NULLs as zero in an average:

```sql
SELECT AVG(COALESCE(salary, 0)) FROM employees;
```

---

### Aggregate Functions with DISTINCT

All five aggregates support `DISTINCT`.

```sql
SELECT
    COUNT(DISTINCT dept)    AS unique_depts,
    SUM(DISTINCT salary)    AS sum_unique_salaries,
    AVG(DISTINCT salary)    AS avg_unique_salaries,
    MIN(DISTINCT salary)    AS min_salary,   -- DISTINCT has no effect on MIN
    MAX(DISTINCT salary)    AS max_salary    -- DISTINCT has no effect on MAX
FROM employees;
```

**Key Points:**

- `DISTINCT` is meaningful for `COUNT`, `SUM`, and `AVG` — it changes the result
- `DISTINCT` has no effect on `MIN` or `MAX` — the minimum and maximum are the same whether or not duplicates are removed
- [Inference] `DISTINCT` inside aggregates may increase query cost due to deduplication — assess whether it is actually needed

---

### Conditional Aggregation

Aggregate only rows matching a condition using `CASE` inside the aggregate.

```sql
SELECT
    COUNT(*)                                        AS total,
    COUNT(CASE WHEN dept = 'Engineering' THEN 1 END) AS eng_count,
    SUM(CASE WHEN dept = 'Engineering' THEN salary ELSE 0 END) AS eng_payroll,
    AVG(CASE WHEN salary > 80000 THEN salary END)   AS avg_high_earner_salary
FROM employees;
```

**Key Points:**

- `CASE WHEN condition THEN value END` returns `NULL` when the condition is false — `NULL` is then ignored by the aggregate
- `ELSE 0` in `SUM` treats non-matching rows as zero contributions — useful when you want a sum of zero rather than NULL exclusion
- `ELSE 0` in `COUNT` would count all rows — omit `ELSE` or use `ELSE NULL` to count only matching rows
- This pattern avoids multiple passes or subqueries for multi-condition summaries

#### Pivot-style conditional aggregation:

```sql
SELECT
    SUM(CASE WHEN dept = 'Engineering' THEN salary ELSE 0 END) AS eng_payroll,
    SUM(CASE WHEN dept = 'Marketing'   THEN salary ELSE 0 END) AS mkt_payroll,
    SUM(CASE WHEN dept = 'Design'      THEN salary ELSE 0 END) AS des_payroll,
    SUM(CASE WHEN dept = 'HR'          THEN salary ELSE 0 END) AS hr_payroll
FROM employees;
```

---

### Aggregates in Subqueries

Aggregate results can be used as filter values in outer queries.

```sql
-- Employees earning above the company average
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Employees in departments with above-average headcount
SELECT name, dept
FROM employees
WHERE dept IN (
    SELECT dept FROM employees
    GROUP BY dept
    HAVING COUNT(*) > (SELECT AVG(cnt) FROM (
        SELECT COUNT(*) AS cnt FROM employees GROUP BY dept
    ))
);
```

**Key Points:**

- Scalar aggregate subqueries (returning one value) are the most common form
- Nested subqueries using aggregates are valid but can be difficult to read — CTEs often improve clarity:

```sql
WITH dept_counts AS (
    SELECT dept, COUNT(*) AS cnt FROM employees GROUP BY dept
),
avg_count AS (
    SELECT AVG(cnt) AS avg_cnt FROM dept_counts
)
SELECT e.name, e.dept
FROM employees e
JOIN dept_counts d ON e.dept = d.dept
JOIN avg_count a ON d.cnt > a.avg_cnt;
```

---

### Aggregates with JOINs

```sql
SELECT
    d.name AS dept,
    COUNT(e.id)             AS headcount,
    ROUND(AVG(e.salary), 2) AS avg_salary,
    SUM(e.salary)           AS total_payroll
FROM departments d
LEFT JOIN employees e ON e.dept = d.name
GROUP BY d.name
ORDER BY total_payroll DESC;
```

**Key Points:**

- `LEFT JOIN` includes departments with no employees — their aggregates return `0` for `COUNT(*)` and `NULL` for `SUM`, `AVG`, `MIN`, `MAX`
- `COUNT(e.id)` counts only non-NULL matches — returns `0` for unmatched departments when using `LEFT JOIN`
- `COUNT(*)` would return `1` for unmatched departments (counting the NULL placeholder row) — use `COUNT(column)` with joins for accurate counts

---

### MIN and MAX on Non-Numeric Types

```sql
-- Lexicographic min/max on text
SELECT MIN(name), MAX(name) FROM employees;

-- Earliest and latest dates (ISO format required)
SELECT MIN(hire_date), MAX(hire_date) FROM employees;

-- Works correctly with ISO 8601: YYYY-MM-DD
-- May not work correctly with other date formats stored as TEXT
```

**Key Points:**

- Text comparison uses the column's collation — `BINARY` by default (byte order)
- ISO 8601 dates stored as `TEXT` sort and compare correctly because the format is lexicographically ordered
- Non-ISO date formats (e.g., `MM/DD/YYYY`) do not sort correctly with `MIN`/`MAX` or `ORDER BY`

---

### GROUP BY with ROLLUP (Not Supported)

SQLite does not support `GROUP BY ... WITH ROLLUP` or `GROUPING SETS`.

```sql
-- Not supported in SQLite
SELECT dept, COUNT(*) FROM employees GROUP BY dept WITH ROLLUP;
```

**Workaround using UNION ALL:**

```sql
SELECT dept, COUNT(*) AS headcount
FROM employees
GROUP BY dept

UNION ALL

SELECT 'TOTAL', COUNT(*)
FROM employees;
```

**Output:**

```
Design      | 2
Engineering | 3
HR          | 2
Marketing   | 3
TOTAL       | 10
```

**Key Points:**

- `UNION ALL` appends the total row without deduplication
- [Inference] More verbose than `ROLLUP` but achieves the same result for simple totals — for multi-level subtotals, multiple `UNION ALL` blocks are needed
- Window functions can also produce running totals and subtotals without `ROLLUP`

---

### Performance Considerations

**Key Points:**

- `COUNT(*)` on a table without a `WHERE` clause may use the table's B-tree metadata rather than scanning all rows in some configurations — [Unverified] actual behavior depends on SQLite version and query context; do not assume it is always a metadata-only operation
- `MIN` and `MAX` on an indexed column can be resolved by reading the first or last index entry — [Inference] significantly faster than a full scan when an index exists; verify with `EXPLAIN QUERY PLAN`
- `GROUP BY` without an index on the grouping column may require sorting or hashing the full result set — [Inference] an index on the `GROUP BY` column can reduce this cost; assess with `EXPLAIN QUERY PLAN`
- Conditional aggregation (`CASE` inside aggregate) requires only one table pass — [Inference] more efficient than multiple filtered queries for the same data

```sql
-- One pass
SELECT
    SUM(CASE WHEN dept = 'Engineering' THEN 1 ELSE 0 END),
    SUM(CASE WHEN dept = 'Marketing'   THEN 1 ELSE 0 END)
FROM employees;

-- Two passes — less efficient
SELECT COUNT(*) FROM employees WHERE dept = 'Engineering';
SELECT COUNT(*) FROM employees WHERE dept = 'Marketing';
```

---

### Aggregate Function Reference

|Function|Returns|Ignores NULL|Empty Set Result|
|---|---|---|---|
|`COUNT(*)`|Row count|No|`0`|
|`COUNT(col)`|Non-NULL count|Yes|`0`|
|`COUNT(DISTINCT col)`|Distinct non-NULL count|Yes|`0`|
|`SUM(col)`|Total|Yes|`NULL`|
|`AVG(col)`|Mean|Yes|`NULL`|
|`MIN(col)`|Smallest value|Yes|`NULL`|
|`MAX(col)`|Largest value|Yes|`NULL`|

---

**Conclusion:** SQLite's five core aggregate functions cover the most common data summarization needs. The critical behaviors to internalize are: all aggregates except `COUNT(*)` ignore `NULL`; `GROUP BY` partitions the set before aggregation; `HAVING` filters groups after aggregation while `WHERE` filters rows before; and conditional aggregation with `CASE` enables multi-condition summaries in a single pass. For performance-sensitive queries, indexes on `GROUP BY` columns and sort columns used with `MIN`/`MAX` are the most impactful optimizations.

**Next Steps:**

- GROUP BY in depth — multi-column grouping, grouping expressions
- Window functions — running totals, rankings, moving averages
- Subqueries and CTEs for complex aggregation
- EXPLAIN QUERY PLAN for aggregate query optimization

---
