## Joins and Subqueries 


### Introduction to Joins and Subqueries

Joins and subqueries are powerful SQL features that allow you to combine data from multiple tables and execute complex queries. PostgreSQL provides robust support for various join types and sophisticated subquery operations that can help solve complex data retrieval challenges.

**Key Points**:

- Joins combine rows from two or more tables based on a related column
- Subqueries are queries nested inside a larger query
- Both features are essential for advanced data retrieval and analysis
- PostgreSQL offers extended functionality for joins and subqueries beyond the SQL standard

### Join Operations 

Joins allow you to combine rows from two or more tables based on a related column between them. PostgreSQL supports all standard SQL join types and some additional features.

#### INNER JOIN

The INNER JOIN returns records that have matching values in both tables.

```sql
SELECT employees.name, departments.department_name
FROM employees
INNER JOIN departments ON employees.department_id = departments.department_id;
```

**Example**:

```sql
SELECT o.order_id, c.customer_name, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= '2023-01-01';
```

#### LEFT JOIN (LEFT OUTER JOIN)

Returns all records from the left table and the matched records from the right table. The result is NULL on the right side when there is no match.

```sql
SELECT customers.customer_name, orders.order_id
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id;
```

**Example**:

```sql
SELECT p.product_name, o.order_id
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE p.category = 'Electronics';
```

#### RIGHT JOIN (RIGHT OUTER JOIN)

Returns all records from the right table and the matched records from the left table. The result is NULL on the left side when there is no match.

```sql
SELECT employees.name, departments.department_name
FROM employees
RIGHT JOIN departments ON employees.department_id = departments.department_id;
```

**Example**:

```sql
SELECT e.employee_name, d.department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id
ORDER BY d.department_name;
```

#### FULL JOIN (FULL OUTER JOIN)

Returns all records when there is a match in either left or right table. NULL values are used to fill the gaps.

```sql
SELECT students.name, courses.course_name
FROM students
FULL JOIN enrollments ON students.student_id = enrollments.student_id
FULL JOIN courses ON enrollments.course_id = courses.course_id;
```

**Example**:

```sql
SELECT s.supplier_name, p.product_name
FROM suppliers s
FULL JOIN products p ON s.supplier_id = p.supplier_id
ORDER BY s.supplier_name, p.product_name;
```

#### CROSS JOIN

Returns the Cartesian product of the two tables (all possible combinations of rows).

```sql
SELECT products.product_name, price_ranges.range_name
FROM products
CROSS JOIN price_ranges;
```

**Example**:

```sql
SELECT p.product_name, c.color_name
FROM products p
CROSS JOIN colors c
WHERE p.category = 'Clothing';
```

#### SELF JOIN

A join of a table to itself.

```sql
SELECT e1.name AS employee, e2.name AS manager
FROM employees e1
JOIN employees e2 ON e1.manager_id = e2.employee_id;
```

**Example**:

```sql
SELECT p1.product_name AS product, p2.product_name AS related_product
FROM products p1
JOIN products p2 ON p1.category = p2.category AND p1.product_id != p2.product_id
WHERE p1.category = 'Books';
```

#### NATURAL JOIN

Join based on all columns with the same name.

```sql
SELECT *
FROM employees
NATURAL JOIN departments;
```

**Example**:

```sql
SELECT customer_id, name, order_id, order_date
FROM customers
NATURAL JOIN orders;
```

### Advanced Join Techniques

#### Using Multiple Joins

```sql
SELECT o.order_id, c.customer_name, p.product_name, oi.quantity
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_date BETWEEN '2023-01-01' AND '2023-12-31';
```

#### USING Clause

Alternative to ON clause when the column names are identical.

```sql
SELECT employees.name, departments.department_name
FROM employees
JOIN departments USING (department_id);
```

#### Lateral Joins (PostgreSQL Specific)

Allows the right-hand table to reference columns from the left-hand table.

```sql
SELECT c.customer_name, o.order_id
FROM customers c
LEFT JOIN LATERAL (
    SELECT order_id, order_date
    FROM orders
    WHERE customer_id = c.customer_id
    ORDER BY order_date DESC
    LIMIT 3
) o ON true;
```

### Subqueries 

Subqueries are queries nested within another query. They can appear in different parts of an SQL statement and serve various purposes.

#### Subqueries in WHERE Clause

```sql
SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);
```

**Example**:

```sql
SELECT employee_name, salary
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location = 'New York'
);
```

#### Subqueries in FROM Clause

```sql
SELECT dept_stats.department_name, dept_stats.avg_salary
FROM (
    SELECT d.department_name, AVG(e.salary) as avg_salary
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    GROUP BY d.department_name
) dept_stats
WHERE dept_stats.avg_salary > 50000;
```

#### Subqueries in SELECT Clause

```sql
SELECT 
    department_name,
    (SELECT COUNT(*) FROM employees WHERE department_id = d.department_id) AS employee_count
FROM departments d;
```

#### Correlated Subqueries

Subqueries that reference columns from the outer query.

```sql
SELECT e.employee_name, e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id = e.department_id
);
```

**Example**:

```sql
SELECT p.product_name, p.price
FROM products p
WHERE p.price > (
    SELECT AVG(price) * 1.5
    FROM products
    WHERE category = p.category
);
```

### Combining Joins and Subqueries

#### Using Subqueries in JOIN Conditions

```sql
SELECT c.customer_name, o.order_id
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IN (
    SELECT order_id
    FROM order_items
    WHERE product_id IN (
        SELECT product_id
        FROM products
        WHERE category = 'Electronics'
    )
);
```

#### Common Table Expressions (CTEs)

CTEs provide a way to write more readable queries by creating temporary result sets.

```sql
WITH high_value_products AS (
    SELECT product_id, product_name, price
    FROM products
    WHERE price > 1000
),
product_sales AS (
    SELECT p.product_id, p.product_name, SUM(oi.quantity) as total_sold
    FROM order_items oi
    JOIN high_value_products p ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT product_name, price, total_sold, price * total_sold as revenue
FROM high_value_products hvp
JOIN product_sales ps ON hvp.product_id = ps.product_id
ORDER BY revenue DESC;
```

### Advanced Subquery Techniques

#### EXISTS and NOT EXISTS

Check for the existence of rows in a subquery.

```sql
SELECT c.customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
    AND o.order_date >= '2023-01-01'
);
```

**Example**:

```sql
SELECT p.product_name
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.product_id
);
```

#### ANY, SOME, and ALL Operators

Compare values with the result of a subquery.

```sql
-- Products more expensive than ANY product in the 'Books' category
SELECT product_name, price
FROM products
WHERE price > ANY (
    SELECT price
    FROM products
    WHERE category = 'Books'
);

-- Products more expensive than ALL products in the 'Books' category
SELECT product_name, price
FROM products
WHERE price > ALL (
    SELECT price
    FROM products
    WHERE category = 'Books'
);
```

#### Scalar Subqueries

Return a single value and can be used anywhere an expression is expected.

```sql
SELECT 
    product_name,
    price,
    (SELECT AVG(price) FROM products) AS avg_price,
    price - (SELECT AVG(price) FROM products) AS price_diff
FROM products;
```

### Performance Optimization for Joins and Subqueries

#### Indexing for Joins

```sql
-- Create indexes on join columns
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

#### Rewriting Subqueries as Joins

Sometimes joins perform better than subqueries.

```sql
-- Subquery version
SELECT product_name, price
FROM products
WHERE product_id IN (
    SELECT product_id
    FROM order_items
    WHERE order_id IN (
        SELECT order_id
        FROM orders
        WHERE customer_id = 42
    )
);

-- Join version (potentially faster)
SELECT DISTINCT p.product_name, p.price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.customer_id = 42;
```

#### Using EXPLAIN ANALYZE

```sql
EXPLAIN ANALYZE
SELECT c.customer_name, o.order_id
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date >= '2023-01-01';
```

#### Materializing Subqueries

```sql
-- Using CTE to materialize intermediate results
WITH filtered_orders AS MATERIALIZED (
    SELECT order_id, customer_id
    FROM orders
    WHERE order_date >= '2023-01-01'
)
SELECT c.customer_name, o.order_id
FROM customers c
JOIN filtered_orders o ON c.customer_id = o.customer_id;
```

### Common Use Cases for Joins and Subqueries

#### Hierarchical Data Queries

```sql
-- Recursive CTE for organization hierarchy
WITH RECURSIVE org_hierarchy AS (
    -- Base case: select top-level employees (no manager)
    SELECT employee_id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: join with employees who have the current employee as manager
    SELECT e.employee_id, e.name, e.manager_id, oh.level + 1
    FROM employees e
    JOIN org_hierarchy oh ON e.manager_id = oh.employee_id
)
SELECT 
    REPEAT(' ', level * 2) || name AS employee_hierarchy,
    level
FROM org_hierarchy
ORDER BY level, name;
```

#### Reporting and Analytics

```sql
WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_date) AS year,
        EXTRACT(MONTH FROM o.order_date) AS month,
        SUM(oi.quantity * oi.unit_price) AS total_sales
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date)
),
yearly_avg AS (
    SELECT 
        year,
        AVG(total_sales) AS avg_monthly_sales
    FROM monthly_sales
    GROUP BY year
)
SELECT 
    ms.year,
    ms.month,
    ms.total_sales,
    ya.avg_monthly_sales,
    ROUND((ms.total_sales - ya.avg_monthly_sales) / ya.avg_monthly_sales * 100, 2) AS percent_diff
FROM monthly_sales ms
JOIN yearly_avg ya ON ms.year = ya.year
ORDER BY ms.year, ms.month;
```

#### Finding Duplicate Records

```sql
SELECT email, COUNT(*)
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- With details of duplicate records
WITH duplicate_emails AS (
    SELECT email
    FROM customers
    GROUP BY email
    HAVING COUNT(*) > 1
)
SELECT c.*
FROM customers c
JOIN duplicate_emails de ON c.email = de.email
ORDER BY c.email;
```

#### Gap Analysis

```sql
-- Find dates with no sales
WITH date_series AS (
    SELECT generate_series(
        '2023-01-01'::date,
        '2023-12-31'::date,
        '1 day'::interval
    )::date AS sales_date
),
daily_sales AS (
    SELECT 
        order_date::date AS sales_date,
        SUM(total) AS total_sales
    FROM orders
    WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31'
    GROUP BY order_date::date
)
SELECT 
    ds.sales_date,
    COALESCE(s.total_sales, 0) AS total_sales
FROM date_series ds
LEFT JOIN daily_sales s ON ds.sales_date = s.sales_date
WHERE s.total_sales IS NULL OR s.total_sales = 0
ORDER BY ds.sales_date;
```

### PostgreSQL-Specific Features

#### LATERAL Joins

```sql
-- Get each customer with their 3 most recent orders
SELECT c.customer_name, o.order_id, o.order_date
FROM customers c
LEFT JOIN LATERAL (
    SELECT order_id, order_date
    FROM orders
    WHERE customer_id = c.customer_id
    ORDER BY order_date DESC
    LIMIT 3
) o ON true;
```

#### JSON Aggregation with Joins

```sql
-- Aggregate related order items into a JSON array
SELECT 
    o.order_id,
    o.order_date,
    c.customer_name,
    jsonb_agg(
        jsonb_build_object(
            'product_id', p.product_id,
            'product_name', p.product_name,
            'quantity', oi.quantity,
            'unit_price', oi.unit_price
        )
    ) AS order_items
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id, o.order_date, c.customer_name
ORDER BY o.order_date DESC;
```

#### Table Inheritance with Joins

```sql
-- Create a parent table
CREATE TABLE logs (
    log_id SERIAL PRIMARY KEY,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    log_level TEXT
);

-- Create child tables that inherit from logs
CREATE TABLE error_logs (
    error_code TEXT,
    stack_trace TEXT
) INHERITS (logs);

CREATE TABLE access_logs (
    user_id INTEGER,
    page_accessed TEXT
) INHERITS (logs);

-- Query across all log tables
SELECT * FROM logs
WHERE log_time >= CURRENT_DATE - INTERVAL '7 days';

-- Join with inheritance
SELECT l.log_id, l.log_time, l.log_level, u.username
FROM logs l
LEFT JOIN users u ON 
    (l.tableoid = 'access_logs'::regclass::oid AND 
     ((access_logs)l).user_id = u.user_id)
WHERE l.log_level = 'ERROR';
```

### Common Pitfalls and Solutions

#### Cartesian Product (Unintended CROSS JOIN)

```sql
-- Problem: Missing join condition
SELECT * FROM orders, customers;

-- Solution: Add proper join condition
SELECT * FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;
```

#### NULL Values in Joins

```sql
-- Problem: NULL values don't match in standard joins
SELECT * FROM table_a a
JOIN table_b b ON a.nullable_col = b.nullable_col;

-- Solution: Use COALESCE or IS NOT DISTINCT FROM
SELECT * FROM table_a a
JOIN table_b b ON COALESCE(a.nullable_col, '') = COALESCE(b.nullable_col, '');

-- Alternative solution
SELECT * FROM table_a a
JOIN table_b b ON a.nullable_col IS NOT DISTINCT FROM b.nullable_col;
```

#### N+1 Query Problem

```sql
-- Problem: Executing one query per customer to find their orders
-- Pseudocode: 
-- customers = SELECT * FROM customers
-- for each customer in customers:
--     orders = SELECT * FROM orders WHERE customer_id = customer.id

-- Solution: Use a join to get all data in one query
SELECT c.customer_id, c.customer_name, 
       ARRAY_AGG(o.order_id) as order_ids
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;
```

#### Slow Subqueries

```sql
-- Problem: Correlated subquery executed for each row
SELECT p.product_name,
       (SELECT COUNT(*) FROM order_items oi WHERE oi.product_id = p.product_id) as times_ordered
FROM products p;

-- Solution: Use a LEFT JOIN with GROUP BY
SELECT p.product_name, COUNT(oi.order_id) as times_ordered
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;
```

### Best Practices

#### Write Joins and Subqueries for Readability

```sql
-- Hard to read
SELECT a.col1, b.col2, c.col3, d.col4
FROM table_a a, table_b b, table_c c, table_d d
WHERE a.id = b.a_id AND b.id = c.b_id AND c.id = d.c_id;

-- Better readability with explicit joins
SELECT a.col1, b.col2, c.col3, d.col4
FROM table_a a
JOIN table_b b ON a.id = b.a_id
JOIN table_c c ON b.id = c.b_id
JOIN table_d d ON c.id = d.c_id;
```

#### Use Table Aliases Consistently

```sql
SELECT e.employee_name, d.department_name, p.project_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN employee_projects ep ON e.employee_id = ep.employee_id
JOIN projects p ON ep.project_id = p.project_id;
```

#### Leverage CTEs for Complex Queries

```sql
WITH active_customers AS (
    SELECT customer_id, customer_name
    FROM customers
    WHERE status = 'active'
),
recent_orders AS (
    SELECT customer_id, COUNT(*) as order_count
    FROM orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY customer_id
),
customer_items AS (
    SELECT o.customer_id, SUM(oi.quantity) as total_items
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY o.customer_id
)
SELECT 
    ac.customer_name,
    COALESCE(ro.order_count, 0) as recent_orders,
    COALESCE(ci.total_items, 0) as items_purchased
FROM active_customers ac
LEFT JOIN recent_orders ro ON ac.customer_id = ro.customer_id
LEFT JOIN customer_items ci ON ac.customer_id = ci.customer_id
ORDER BY items_purchased DESC;
```

### Related Topics

- Window functions in PostgreSQL
- Materialized views for query optimization
- Row-level security with joins
- Using EXPLAIN to analyze join performance
- Partitioning large tables and its effect on joins
- Advanced PostgreSQL indexing techniques

---

