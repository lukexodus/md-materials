## SELECT Statements and Basic Queries in SQLite


---

### Basic Syntax

The `SELECT` statement retrieves rows from one or more tables.

```sql
SELECT column1, column2
FROM table_name;
```

**Key Points:**

- `SELECT` does not modify data
- Column list can be explicit or use `*` to return all columns
- SQLite processes clauses in a defined logical order (covered below)

---

### Selecting All Columns

```sql
SELECT * FROM employees;
```

**Key Points:**

- Returns every column in the table's defined order
- Generally discouraged in production code — schema changes silently alter result shape
- Acceptable for exploration and quick debugging

---

### Selecting Specific Columns

```sql
SELECT name, dept, salary
FROM employees;
```

**Key Points:**

- Only the listed columns are returned
- Column order in the result follows the order listed in the query, not the table schema

---

### Column Aliases

Rename a column in the result set using `AS`.

```sql
SELECT name AS employee_name, salary AS annual_salary
FROM employees;
```

**Key Points:**

- `AS` is optional — `name employee_name` is valid but less readable
- Aliases can be used in `ORDER BY` but **not** in `WHERE` (SQLite processes `WHERE` before alias resolution)
- Aliases defined in `SELECT` are available in `ORDER BY` and `HAVING`

---

### Expressions in SELECT

You can compute values directly in the column list.

```sql
SELECT
    name,
    salary,
    salary * 0.10        AS bonus,
    salary + salary * 0.10 AS total_compensation
FROM employees;
```

**Key Points:**

- Arithmetic operators: `+`, `-`, `*`, `/`, `%`
- String concatenation uses `||`
- Expression results are not stored — they are computed per query

**Example — string expression:**

```sql
SELECT name || ' (' || dept || ')' AS label
FROM employees;
```

**Output:**

```
Alice (Engineering)
Bob (Marketing)
```

---

### DISTINCT

Removes duplicate rows from the result.

```sql
SELECT DISTINCT dept
FROM employees;
```

**Key Points:**

- `DISTINCT` applies to the entire row, not a single column
- When multiple columns are selected, uniqueness is evaluated across the combination
- [Inference] May involve a sort or hash operation internally — can be slower on large, unindexed datasets

```sql
SELECT DISTINCT dept, salary
FROM employees;
-- Returns unique (dept, salary) pairs, not unique depts alone
```

---

### WHERE Clause

Filters rows based on a condition.

```sql
SELECT name, salary
FROM employees
WHERE dept = 'Engineering';
```

#### Comparison Operators

|Operator|Meaning|
|---|---|
|`=`|Equal|
|`!=` or `<>`|Not equal|
|`<`, `>`|Less / greater than|
|`<=`, `>=`|Less / greater than or equal|

#### Logical Operators

```sql
-- AND
SELECT name FROM employees
WHERE dept = 'Engineering' AND salary > 90000;

-- OR
SELECT name FROM employees
WHERE dept = 'Engineering' OR dept = 'Design';

-- NOT
SELECT name FROM employees
WHERE NOT dept = 'HR';
```

**Key Points:**

- `AND` has higher precedence than `OR` — use parentheses to clarify complex conditions
- SQLite evaluates `WHERE` before `SELECT` expressions

---

### NULL Handling in WHERE

`NULL` comparisons require `IS NULL` or `IS NOT NULL`.

```sql
SELECT name FROM employees WHERE dept IS NULL;
SELECT name FROM employees WHERE dept IS NOT NULL;
```

**Key Points:**

- `WHERE dept = NULL` does **not** work as expected — it always evaluates to false in SQL
- `NULL` is not equal to anything, including itself
- This is standard SQL behavior, not SQLite-specific

---

### BETWEEN

Tests whether a value falls within an inclusive range.

```sql
SELECT name, salary
FROM employees
WHERE salary BETWEEN 60000 AND 90000;
```

**Key Points:**

- Equivalent to `salary >= 60000 AND salary <= 90000`
- Works with numbers, text (lexicographic), and dates stored as text in ISO format

---

### IN and NOT IN

Tests membership in a value list.

```sql
SELECT name FROM employees
WHERE dept IN ('Engineering', 'Design', 'IT');

SELECT name FROM employees
WHERE dept NOT IN ('HR', 'Marketing');
```

**Key Points:**

- `IN` can also accept a subquery (covered in subquery topics)
- `NOT IN` with a list containing `NULL` may produce unexpected results — [Inference] if any value in the list is `NULL`, `NOT IN` can return no rows; always filter `NULL` from `NOT IN` lists when this is a concern
- Behavior may vary depending on data — test with your actual dataset

---

### LIKE

Pattern matching on text values.

|Wildcard|Meaning|
|---|---|
|`%`|Zero or more characters|
|`_`|Exactly one character|

```sql
-- Names starting with 'A'
SELECT name FROM employees WHERE name LIKE 'A%';

-- Names ending with 'e'
SELECT name FROM employees WHERE name LIKE '%e';

-- Names with exactly 3 characters
SELECT name FROM employees WHERE name LIKE '___';

-- Names containing 'ar'
SELECT name FROM employees WHERE name LIKE '%ar%';
```

**Key Points:**

- Case-insensitive by default for ASCII characters in SQLite
- Case sensitivity for Unicode characters depends on the build and any loaded ICU extension — [Unverified] behavior for non-ASCII `LIKE` comparisons should be tested in your environment
- `ESCAPE` clause defines a custom escape character for literal `%` or `_`:

```sql
SELECT * FROM files WHERE path LIKE '50\% done%' ESCAPE '\';
```

---

### GLOB

Similar to `LIKE` but uses Unix-style wildcards and is case-sensitive.

|Wildcard|Meaning|
|---|---|
|`*`|Zero or more characters|
|`?`|Exactly one character|
|`[abc]`|Character class|

```sql
SELECT name FROM employees WHERE name GLOB 'A*';
SELECT name FROM employees WHERE name GLOB '[ABC]*';
```

**Key Points:**

- Always case-sensitive, unlike `LIKE`
- Not part of standard SQL — SQLite-specific

---

### ORDER BY

Sorts the result set.

```sql
SELECT name, salary
FROM employees
ORDER BY salary DESC;
```

```sql
-- Multiple columns
SELECT name, dept, salary
FROM employees
ORDER BY dept ASC, salary DESC;
```

**Key Points:**

- `ASC` is the default and can be omitted
- `NULL` values sort **before** non-null values in `ASC` order and **after** in `DESC` order in SQLite — [Inference] this differs from some other databases; verify if portability matters
- You can order by column position: `ORDER BY 2 DESC` (refers to second column in `SELECT`) — valid but fragile

---

### LIMIT and OFFSET

Controls how many rows are returned.

```sql
-- First 5 rows
SELECT name, salary FROM employees
ORDER BY salary DESC
LIMIT 5;

-- Rows 6–10 (skip first 5)
SELECT name, salary FROM employees
ORDER BY salary DESC
LIMIT 5 OFFSET 5;
```

**Key Points:**

- `LIMIT` without `ORDER BY` returns an arbitrary subset — row order is not guaranteed without explicit sorting
- `OFFSET` is zero-based
- SQLite also supports the shorthand `LIMIT offset, count` (comma syntax) though the `OFFSET` keyword form is clearer
- [Inference] Large `OFFSET` values on big tables can be slow since SQLite scans and discards rows up to the offset — keyset pagination may be preferable for performance

---

### Logical Processing Order

SQLite (and SQL generally) processes clauses in this logical order, regardless of written order:

```
1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT  (expressions, aliases resolved here)
6. DISTINCT
7. ORDER BY
8. LIMIT / OFFSET
```

**Key Points:**

- This explains why `WHERE` cannot reference `SELECT` aliases — aliases don't exist yet at that stage
- `HAVING` can reference aliases defined in `SELECT` in SQLite — [Inference] this is a SQLite-specific extension to standard behavior and may not be portable

---

### SELECT Without a Table

SQLite allows `SELECT` without a `FROM` clause, useful for evaluating expressions.

```sql
SELECT 1 + 1;
SELECT UPPER('hello');
SELECT DATE('now');
SELECT SQLITE_VERSION();
```

**Output:**

```
2
HELLO
2026-05-23
3.x.x
```

---

### Combining Conditions — Practical Example

```sql
SELECT name, dept, salary
FROM employees
WHERE dept IN ('Engineering', 'IT')
  AND salary BETWEEN 70000 AND 110000
  AND name LIKE 'A%'
ORDER BY salary DESC
LIMIT 10;
```

---

### CASE Expression in SELECT

Conditional logic within a query.

```sql
SELECT
    name,
    salary,
    CASE
        WHEN salary >= 90000 THEN 'Senior'
        WHEN salary >= 70000 THEN 'Mid'
        ELSE 'Junior'
    END AS level
FROM employees;
```

**Key Points:**

- `CASE` is an expression, not a statement — it returns a value
- Can be used anywhere an expression is valid: `SELECT`, `WHERE`, `ORDER BY`
- Evaluated top-to-bottom; first matching `WHEN` wins

---

### TYPEOF and Type Introspection

Useful for debugging SQLite's dynamic typing.

```sql
SELECT name, TYPEOF(salary), TYPEOF(name)
FROM employees;
```

**Output:**

```
Alice | real | text
Bob   | real | text
```

**Key Points:**

- Returns the storage class: `null`, `integer`, `real`, `text`, `blob`
- Reflects the actual stored value type, not the declared column affinity

---

**Conclusion:** The `SELECT` statement is the foundation of all data retrieval in SQLite. Core variations — filtering with `WHERE`, sorting with `ORDER BY`, limiting with `LIMIT`, and pattern matching with `LIKE` or `GLOB` — cover most practical querying needs. Understanding logical processing order helps avoid common errors with aliases and filtering. Behavior for edge cases like `NULL` comparisons and Unicode `LIKE` should be verified in your target environment.

**Next Steps:**

- Aggregate functions and `GROUP BY`
- Joins (`INNER`, `LEFT`, `CROSS`)
- Subqueries and CTEs
- Full-text search with FTS5

---

