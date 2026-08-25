## WHERE Clauses and Filtering in SQLite


---

### Purpose and Placement

The `WHERE` clause restricts which rows are processed by a statement. It applies to `SELECT`, `UPDATE`, `DELETE`, and certain subquery contexts.

```sql
SELECT column1, column2 FROM table_name WHERE condition;
UPDATE table_name SET column = value WHERE condition;
DELETE FROM table_name WHERE condition;
```

**Key Points:**

- `WHERE` is evaluated before `SELECT` expressions — column aliases defined in `SELECT` are not available in `WHERE`
- `WHERE` filters individual rows before any grouping — use `HAVING` to filter after `GROUP BY`
- A missing `WHERE` clause processes every row in the table — intentional in some cases but dangerous in `UPDATE` and `DELETE`

---

### Comparison Operators

```sql
SELECT * FROM employees WHERE salary = 95000;
SELECT * FROM employees WHERE salary != 95000;
SELECT * FROM employees WHERE salary <> 95000;   -- equivalent to !=
SELECT * FROM employees WHERE salary > 80000;
SELECT * FROM employees WHERE salary < 80000;
SELECT * FROM employees WHERE salary >= 80000;
SELECT * FROM employees WHERE salary <= 80000;
```

**Key Points:**

- `!=` and `<>` are equivalent in SQLite
- Comparisons with `NULL` using these operators always return `NULL` (falsy) — use `IS NULL` / `IS NOT NULL` instead
- SQLite uses type affinity for comparisons — a `TEXT` value compared to an `INTEGER` follows affinity rules; results may be unexpected when column types are inconsistent

---

### Logical Operators: AND, OR, NOT

```sql
-- AND: both conditions must be true
SELECT * FROM employees
WHERE dept = 'Engineering' AND salary > 90000;

-- OR: either condition must be true
SELECT * FROM employees
WHERE dept = 'Engineering' OR dept = 'Design';

-- NOT: negates a condition
SELECT * FROM employees
WHERE NOT dept = 'HR';

-- Combined
SELECT * FROM employees
WHERE (dept = 'Engineering' OR dept = 'Design')
  AND salary > 75000
  AND NOT name LIKE '%Temp%';
```

**Key Points:**

- `AND` has higher precedence than `OR` — parentheses are required to override default precedence
- `NOT` has higher precedence than `AND` and `OR`
- Without parentheses, `A OR B AND C` is parsed as `A OR (B AND C)` — always use parentheses in mixed expressions to make intent explicit

---

### NULL Handling

`NULL` represents the absence of a value. Standard comparison operators do not work with `NULL`.

```sql
-- Correct
SELECT * FROM employees WHERE dept IS NULL;
SELECT * FROM employees WHERE dept IS NOT NULL;

-- Wrong — always returns no rows (NULL = NULL is NULL, not TRUE)
SELECT * FROM employees WHERE dept = NULL;
SELECT * FROM employees WHERE dept != NULL;
```

#### NULL in AND / OR

|Expression|Result|
|---|---|
|`NULL AND TRUE`|NULL (falsy)|
|`NULL AND FALSE`|FALSE|
|`NULL OR TRUE`|TRUE|
|`NULL OR FALSE`|NULL (falsy)|
|`NOT NULL`|NULL (falsy)|

**Key Points:**

- `NULL` propagates through most expressions — any arithmetic or comparison involving `NULL` returns `NULL`
- Use `COALESCE` or `IFNULL` to substitute defaults before comparing:

```sql
SELECT * FROM employees
WHERE COALESCE(dept, 'Unknown') = 'Unknown';
```

- `IS` and `IS NOT` are NULL-safe equality operators in SQLite:

```sql
SELECT * FROM employees WHERE dept IS 'Engineering';
-- Equivalent to: WHERE dept = 'Engineering' but NULL-safe
```

---

### BETWEEN

Tests for inclusive range membership.

```sql
SELECT * FROM employees
WHERE salary BETWEEN 60000 AND 90000;

-- Equivalent to:
SELECT * FROM employees
WHERE salary >= 60000 AND salary <= 90000;
```

**Date range example:**

```sql
SELECT * FROM employees
WHERE hire_date BETWEEN '2022-01-01' AND '2023-12-31';
```

**Key Points:**

- Both bounds are **inclusive**
- Works on numeric, text (lexicographic), and ISO-format date strings
- `NOT BETWEEN` excludes the range:

```sql
SELECT * FROM employees WHERE salary NOT BETWEEN 60000 AND 90000;
```

- If the lower bound exceeds the upper bound, no rows are returned — SQLite does not automatically swap bounds

---

### IN and NOT IN

Tests membership in a fixed list.

```sql
SELECT * FROM employees
WHERE dept IN ('Engineering', 'Design', 'IT');

SELECT * FROM employees
WHERE dept NOT IN ('HR', 'Marketing');
```

**Key Points:**

- Equivalent to chained `OR` conditions but more readable
- `IN` with a subquery is covered in the subquery section below
- **`NOT IN` with NULL caveat:** if any value in the list is `NULL`, `NOT IN` returns no rows — even when the column value clearly does not match other list items

```sql
-- Dangerous if dept_list contains NULL
SELECT * FROM employees
WHERE dept NOT IN (SELECT dept FROM excluded_depts);

-- Safer pattern
SELECT * FROM employees
WHERE dept NOT IN (
    SELECT dept FROM excluded_depts WHERE dept IS NOT NULL
);
```

- This behavior is standard SQL, not SQLite-specific — [Inference] any `NOT IN` subquery should explicitly filter `NULL` from the subquery result to avoid silently returning zero rows

---

### LIKE — Pattern Matching

```sql
-- Starts with
SELECT * FROM employees WHERE name LIKE 'A%';

-- Ends with
SELECT * FROM employees WHERE name LIKE '%son';

-- Contains
SELECT * FROM employees WHERE name LIKE '%ar%';

-- Single character wildcard
SELECT * FROM employees WHERE name LIKE '_ob';

-- Combined
SELECT * FROM employees WHERE name LIKE 'J___s';
```

|Wildcard|Matches|
|---|---|
|`%`|Zero or more characters|
|`_`|Exactly one character|

**Key Points:**

- Case-insensitive for ASCII characters by default in SQLite
- Case sensitivity for non-ASCII (Unicode) characters depends on the SQLite build and whether the ICU extension is loaded — [Unverified] do not assume case-insensitive Unicode `LIKE` without verifying your build
- `NOT LIKE` negates the pattern:

```sql
SELECT * FROM employees WHERE name NOT LIKE '%Temp%';
```

#### ESCAPE Clause

Allows literal `%` or `_` to be matched.

```sql
SELECT * FROM files WHERE path LIKE '100\% complete' ESCAPE '\';
```

**Key Points:**

- The character after `ESCAPE` becomes the escape prefix
- `\%` matches a literal `%`; `\_` matches a literal `_`

---

### GLOB — Case-Sensitive Pattern Matching

```sql
SELECT * FROM employees WHERE name GLOB 'A*';
SELECT * FROM employees WHERE name GLOB '[ABC]*';
SELECT * FROM employees WHERE name GLOB '*son';
SELECT * FROM employees WHERE dept GLOB '[A-E]*';
```

|Wildcard|Matches|
|---|---|
|`*`|Zero or more characters|
|`?`|Exactly one character|
|`[abc]`|Any character in set|
|`[a-z]`|Any character in range|
|`[^abc]`|Any character not in set|

**Key Points:**

- Always case-sensitive — unlike `LIKE`
- SQLite-specific — not standard SQL
- `NOT GLOB` is valid:

```sql
SELECT * FROM employees WHERE name NOT GLOB '[A-M]*';
```

---

### REGEXP

SQLite does not include a built-in `REGEXP` implementation. It requires a user-defined function registered at connection time.

```python
import sqlite3
import re

def regexp(pattern, value):
    if value is None:
        return None
    return bool(re.search(pattern, value))

conn = sqlite3.connect('mydatabase.db')
conn.create_function('REGEXP', 2, regexp)

rows = conn.execute(
    "SELECT * FROM employees WHERE name REGEXP '^A.*n$'"
).fetchall()
```

```sql
-- Once registered:
SELECT * FROM employees WHERE name REGEXP '^[A-Z][a-z]+$';
```

**Key Points:**

- `REGEXP` raises an error if no function is registered — it is a placeholder in SQLite's parser
- [Unverified] Some SQLite distributions or extensions may include a built-in `REGEXP` — verify in your environment
- For most pattern needs, `LIKE` or `GLOB` are sufficient without external dependencies

---

### EXISTS and NOT EXISTS

Tests whether a subquery returns any rows.

```sql
-- Rows where a related record exists
SELECT * FROM employees e
WHERE EXISTS (
    SELECT 1 FROM projects p
    WHERE p.lead_id = e.id
);

-- Rows where no related record exists
SELECT * FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM projects p
    WHERE p.lead_id = e.id
);
```

**Key Points:**

- `EXISTS` returns `TRUE` if the subquery produces at least one row — the selected value is irrelevant; `SELECT 1` is conventional
- Short-circuits on the first matching row — [Inference] may be more efficient than `IN` for large subquery results, particularly when the subquery is correlated; verify with `EXPLAIN QUERY PLAN`
- Correlated subqueries reference the outer query's columns — evaluated once per outer row
- `NOT EXISTS` is often safer than `NOT IN` when the subquery may return `NULL` values

---

### Subqueries in WHERE

#### Scalar Subquery

Returns a single value for comparison.

```sql
SELECT * FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

#### IN with Subquery

```sql
SELECT * FROM employees
WHERE dept IN (
    SELECT name FROM departments WHERE budget > 500000
);
```

#### Correlated Subquery

References the outer query per row.

```sql
SELECT * FROM employees e
WHERE salary > (
    SELECT AVG(salary) FROM employees
    WHERE dept = e.dept
);
```

**Key Points:**

- Correlated subqueries are evaluated once per outer row — [Inference] can be slow on large tables without indexes on the correlated columns; use `EXPLAIN QUERY PLAN` to assess
- Scalar subqueries that return more than one row produce an error — use `LIMIT 1` or aggregation to guarantee a single result
- [Inference] In many cases, a `JOIN` can replace a correlated subquery with better performance — verify with your query planner

---

### CASE in WHERE

`CASE` expressions can appear in `WHERE` conditions.

```sql
SELECT * FROM employees
WHERE
    CASE dept
        WHEN 'Engineering' THEN salary > 90000
        WHEN 'Design'      THEN salary > 65000
        ELSE                    salary > 55000
    END;
```

**Key Points:**

- `CASE` returns a value — when used in `WHERE`, a truthy (non-zero, non-null) result passes the row
- Useful for conditional thresholds that vary by category
- [Inference] May prevent index usage on the filtered columns — verify with `EXPLAIN QUERY PLAN`

---

### Filtering on Expressions and Functions

Any expression valid in `SELECT` can appear in `WHERE`.

```sql
-- Function in WHERE
SELECT * FROM employees
WHERE UPPER(dept) = 'ENGINEERING';

-- Arithmetic
SELECT * FROM employees
WHERE salary * 1.10 > 100000;

-- Date function
SELECT * FROM employees
WHERE hire_date >= DATE('now', '-1 year');

-- String length
SELECT * FROM employees
WHERE LENGTH(name) > 10;

-- Type check
SELECT * FROM employees
WHERE TYPEOF(salary) = 'real';
```

**Key Points:**

- Applying functions to columns in `WHERE` typically prevents index use on that column — [Inference] SQLite cannot use an index on `dept` when `UPPER(dept)` is evaluated per row; an expression index can address this:

```sql
CREATE INDEX idx_dept_upper ON employees (UPPER(dept));

-- Now this can use the index:
SELECT * FROM employees WHERE UPPER(dept) = 'ENGINEERING';
```

- Date comparisons work correctly with ISO 8601 strings (`YYYY-MM-DD`) stored as `TEXT` — other formats may not sort or compare correctly

---

### Expression Indexes for WHERE Optimization

When a function or expression is frequently used in `WHERE`, an expression index allows the query planner to use it.

```sql
-- Without index: full scan, UPPER() evaluated per row
SELECT * FROM employees WHERE UPPER(name) = 'ALICE';

-- Create expression index
CREATE INDEX idx_name_upper ON employees (UPPER(name));

-- Now eligible for index lookup
SELECT * FROM employees WHERE UPPER(name) = 'ALICE';
```

**Key Points:**

- Expression must match exactly in both the index definition and the `WHERE` clause
- [Inference] Improves performance when the column has high cardinality and the expression is used frequently — actual gains depend on data size and query frequency
- Increases write overhead — index must be updated on every row change

---

### Filtering NULLs with COALESCE and IFNULL

```sql
-- Treat NULL dept as 'Unassigned'
SELECT * FROM employees
WHERE COALESCE(dept, 'Unassigned') = 'Unassigned';

-- Equivalent using IFNULL
SELECT * FROM employees
WHERE IFNULL(dept, 'Unassigned') = 'Unassigned';

-- Filter where bonus is null or zero
SELECT * FROM employees
WHERE COALESCE(bonus, 0) = 0;
```

**Key Points:**

- `COALESCE(x, y)` returns the first non-NULL argument
- `IFNULL(x, y)` is equivalent to `COALESCE` with two arguments — SQLite-specific shorthand
- Both prevent the NULL-propagation problem in comparisons
- [Inference] Using these functions in `WHERE` may prevent index use on the column — consider restructuring as `WHERE col IS NULL OR col = value` when index performance matters:

```sql
SELECT * FROM employees
WHERE dept IS NULL OR dept = 'Unassigned';
```

---

### Filtering with ROWID

Every SQLite table has an implicit `rowid` unless created as `WITHOUT ROWID`.

```sql
SELECT * FROM employees WHERE rowid = 42;
SELECT * FROM employees WHERE rowid BETWEEN 100 AND 200;
```

**Key Points:**

- `rowid` lookups use the built-in B-tree index — [Inference] typically the fastest possible lookup in SQLite
- Accessible as `rowid`, `oid`, or `_rowid_` unless a column with that name is explicitly defined
- An `INTEGER PRIMARY KEY` column is an alias for `rowid` — lookups on it are equally fast

---

### WHERE with HAVING — Knowing the Difference

```sql
-- WHERE filters before grouping
SELECT dept, AVG(salary) AS avg_sal
FROM employees
WHERE salary > 50000          -- Excludes rows before grouping
GROUP BY dept
HAVING AVG(salary) > 80000;  -- Filters groups after aggregation
```

**Key Points:**

- `WHERE` cannot reference aggregate functions (`COUNT`, `AVG`, `SUM`, etc.) — those are not computed until after grouping
- `HAVING` filters on aggregated results — it can also filter on non-aggregated columns, though `WHERE` is more efficient for that purpose
- Both can appear in the same query — `WHERE` narrows the row set before `GROUP BY` processes it

---

### Filtering in UPDATE and DELETE

All `WHERE` patterns apply equally to `UPDATE` and `DELETE`.

```sql
UPDATE employees
SET salary = salary * 1.10
WHERE dept = 'Engineering'
  AND salary < (SELECT AVG(salary) FROM employees WHERE dept = 'Engineering');

DELETE FROM employees
WHERE hire_date < DATE('now', '-5 years')
  AND dept IN (SELECT name FROM departments WHERE status = 'dissolved');
```

**Key Points:**

- Previewing with a `SELECT` using the identical `WHERE` clause before running `UPDATE` or `DELETE` is strongly recommended
- Subqueries, `EXISTS`, `IN`, and all other `WHERE` patterns work in `UPDATE` and `DELETE` contexts

---

### Common Filtering Mistakes

#### Incorrect NULL comparison:

```sql
-- Wrong
WHERE dept = NULL

-- Correct
WHERE dept IS NULL
```

#### Precedence error with OR and AND:

```sql
-- Unintended: reads as dept='HR' OR (dept='IT' AND salary > 80000)
WHERE dept = 'HR' OR dept = 'IT' AND salary > 80000

-- Intended
WHERE (dept = 'HR' OR dept = 'IT') AND salary > 80000
```

#### NOT IN with nullable subquery:

```sql
-- May return no rows if subquery contains NULL
WHERE id NOT IN (SELECT manager_id FROM departments)

-- Safe version
WHERE id NOT IN (
    SELECT manager_id FROM departments WHERE manager_id IS NOT NULL
)
```

#### Function on column prevents index use:

```sql
-- Index on dept not used
WHERE LOWER(dept) = 'engineering'

-- Index on dept used
WHERE dept = 'Engineering'

-- Or: create expression index for the LOWER() form
CREATE INDEX idx_dept_lower ON employees (LOWER(dept));
```

---

### WHERE Clause Operator Reference

|Operator / Keyword|Purpose|
|---|---|
|`=`, `!=`, `<>`|Equality / inequality|
|`<`, `>`, `<=`, `>=`|Range comparison|
|`IS NULL`, `IS NOT NULL`|NULL checks|
|`IS`, `IS NOT`|NULL-safe equality|
|`BETWEEN ... AND ...`|Inclusive range|
|`IN (...)`|List membership|
|`NOT IN (...)`|List exclusion|
|`LIKE`|Case-insensitive pattern (ASCII)|
|`NOT LIKE`|Negated pattern|
|`GLOB`|Case-sensitive pattern|
|`NOT GLOB`|Negated glob|
|`REGEXP`|Regex (requires UDF)|
|`EXISTS (...)`|Subquery row existence|
|`NOT EXISTS (...)`|Subquery row absence|
|`AND`, `OR`, `NOT`|Logical combination|
|`COALESCE`, `IFNULL`|NULL substitution|

---

**Conclusion:** SQLite's `WHERE` clause supports a full range of filtering patterns — from simple equality checks to correlated subqueries, pattern matching, and expression-based conditions. The most common pitfalls are NULL handling with `NOT IN`, operator precedence with mixed `AND`/`OR`, and inadvertently preventing index use by applying functions to filtered columns. Where performance matters, `EXPLAIN QUERY PLAN` is the definitive tool for verifying whether a given `WHERE` condition uses an index.

**Next Steps:**

- Aggregate functions and GROUP BY
- Joins and multi-table filtering
- Indexes — design and query planner interaction
- EXPLAIN QUERY PLAN in depth

---

