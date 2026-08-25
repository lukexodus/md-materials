## Basic SQL Syntax


### Introduction to SQL

SQL (Structured Query Language) is the standard language for interacting with relational database management systems like PostgreSQL. SQL allows you to create, read, update, and delete data, as well as manage database structures.

### SQL Statement Structure

SQL statements typically follow this pattern:

```sql
COMMAND argument1, argument2, ...
FROM source
WHERE conditions
ORDER BY column1, column2;
```

All SQL statements end with a semicolon (`;`).

### Data Query Language (DQL)

#### SELECT Statement

The SELECT statement retrieves data from a database:

```sql
SELECT column1, column2
FROM table_name
WHERE condition;
```

Example:

```sql
SELECT first_name, last_name, email
FROM customers
WHERE country = 'USA';
```

#### Common SELECT Clauses

```sql
-- Select all columns
SELECT * FROM employees;

-- Filter rows with WHERE
SELECT product_name, unit_price, units_in_stock
FROM products
WHERE category_id = 1 AND unit_price > 20;

-- Sort results
SELECT product_name, unit_price
FROM products
ORDER BY unit_price DESC, product_name ASC;

-- Limit results
SELECT product_name, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 10;

-- Skip rows (PostgreSQL)
SELECT product_name, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 10 OFFSET 20;
```

#### Aggregate Functions

```sql
-- Count, sum, average, min, max
SELECT 
    COUNT(*) AS total_products,
    SUM(units_in_stock) AS total_stock,
    AVG(unit_price) AS average_price,
    MIN(unit_price) AS lowest_price,
    MAX(unit_price) AS highest_price
FROM products;
```

#### GROUP BY and HAVING

```sql
-- Group results
SELECT category_id, COUNT(*) AS product_count
FROM products
GROUP BY category_id;

-- Filter groups
SELECT category_id, COUNT(*) AS product_count
FROM products
GROUP BY category_id
HAVING COUNT(*) > 10;
```

### Data Manipulation Language (DML)

#### INSERT Statement

Add new rows to a table:

```sql
INSERT INTO table_name (column1, column2, column3)
VALUES 
    (value1, value2, value3),
    (value4, value5, value6);
```

Example:

```sql
INSERT INTO customers (first_name, last_name, email)
VALUES 
    ('John', 'Smith', 'john.smith@example.com'),
    ('Jane', 'Doe', 'jane.doe@example.com');
```

#### UPDATE Statement

Modify existing data:

```sql
UPDATE table_name
SET column1 = value1, column2 = value2
WHERE condition;
```

Example:

```sql
UPDATE products
SET unit_price = unit_price * 1.10
WHERE category_id = 1;
```

#### DELETE Statement

Remove rows from a table:

```sql
DELETE FROM table_name
WHERE condition;
```

Example:

```sql
DELETE FROM order_details
WHERE order_id = 10248;
```

### Data Definition Language (DDL)

#### CREATE TABLE

Define a new table:

```sql
CREATE TABLE table_name (
    column1 data_type constraints,
    column2 data_type constraints,
    ...
    table_constraints
);
```

Example:

```sql
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    supplier_id INTEGER REFERENCES suppliers(supplier_id),
    category_id INTEGER REFERENCES categories(category_id),
    unit_price DECIMAL(10, 2) DEFAULT 0,
    discontinued BOOLEAN DEFAULT FALSE
);
```

#### ALTER TABLE

Modify an existing table:

```sql
-- Add column
ALTER TABLE table_name
ADD COLUMN column_name data_type constraints;

-- Drop column
ALTER TABLE table_name
DROP COLUMN column_name;

-- Rename column
ALTER TABLE table_name
RENAME COLUMN old_name TO new_name;

-- Change data type
ALTER TABLE table_name
ALTER COLUMN column_name TYPE new_data_type;

-- Add constraint
ALTER TABLE table_name
ADD CONSTRAINT constraint_name constraint_definition;
```

Example:

```sql
ALTER TABLE customers
ADD COLUMN last_login_date TIMESTAMP;

ALTER TABLE products
ADD CONSTRAINT price_check CHECK (unit_price >= 0);
```

#### DROP TABLE

Remove an existing table:

```sql
DROP TABLE table_name;

-- Safe version (only if exists)
DROP TABLE IF EXISTS table_name;
```

### Table Joins

#### INNER JOIN

Returns rows when there is a match in both tables:

```sql
SELECT table1.column1, table2.column2
FROM table1
INNER JOIN table2 ON table1.common_field = table2.common_field;
```

Example:

```sql
SELECT o.order_id, c.customer_name, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;
```

#### LEFT JOIN (LEFT OUTER JOIN)

Returns all rows from the left table and matched rows from the right table:

```sql
SELECT table1.column1, table2.column2
FROM table1
LEFT JOIN table2 ON table1.common_field = table2.common_field;
```

Example:

```sql
SELECT c.customer_name, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;
```

#### RIGHT JOIN (RIGHT OUTER JOIN)

Returns all rows from the right table and matched rows from the left table:

```sql
SELECT table1.column1, table2.column2
FROM table1
RIGHT JOIN table2 ON table1.common_field = table2.common_field;
```

#### FULL JOIN (FULL OUTER JOIN)

Returns rows when there is a match in one of the tables:

```sql
SELECT table1.column1, table2.column2
FROM table1
FULL JOIN table2 ON table1.common_field = table2.common_field;
```

#### CROSS JOIN

Returns the Cartesian product of both tables:

```sql
SELECT table1.column1, table2.column2
FROM table1
CROSS JOIN table2;
```

### Subqueries

#### IN Subquery

```sql
SELECT product_name, unit_price
FROM products
WHERE category_id IN (
    SELECT category_id 
    FROM categories 
    WHERE category_name LIKE 'Sea%'
);
```

#### EXISTS Subquery

```sql
SELECT supplier_name
FROM suppliers s
WHERE EXISTS (
    SELECT 1 
    FROM products p 
    WHERE p.supplier_id = s.supplier_id AND p.units_in_stock = 0
);
```

#### FROM Subquery

```sql
SELECT category_name, avg_price
FROM (
    SELECT 
        c.category_name, 
        AVG(p.unit_price) as avg_price
    FROM products p
    JOIN categories c ON p.category_id = c.category_id
    GROUP BY c.category_name
) as category_averages
WHERE avg_price > 25;
```

**Comparing EXISTS and FROM Subquery**

How do EXISTS and FROM subqueries differ in their purpose? Can you think of a situation where one might be more appropriate than the other?

**Key points**:

- EXISTS is for checking row existence, often in WHERE clauses, and doesn’t retrieve data.
- FROM subqueries produce a result set to be used as a table, often for further joins or calculations.
- EXISTS is typically faster for existence checks; FROM subqueries are better for data transformation.

### Common Table Expressions (CTEs)

```sql
WITH regional_sales AS (
    SELECT 
        region, 
        SUM(amount) as total_sales
    FROM orders
    GROUP BY region
),
top_regions AS (
    SELECT region
    FROM regional_sales
    ORDER BY total_sales DESC
    LIMIT 3
)
SELECT region, product, SUM(quantity) as product_units
FROM orders
WHERE region IN (SELECT region FROM top_regions)
GROUP BY region, product;
```

### String Functions

```sql
-- Concatenation
SELECT first_name || ' ' || last_name AS full_name FROM employees;

-- Uppercase/Lowercase
SELECT UPPER(first_name), LOWER(last_name) FROM employees;

-- Substring
SELECT SUBSTRING(product_name FROM 1 FOR 10) FROM products;

-- Trim
SELECT TRIM(BOTH ' ' FROM '  product name  ');

-- String replacement
SELECT REPLACE(phone_number, '-', '') FROM customers;
```

### Date and Time Functions

```sql
-- Current date/time
SELECT CURRENT_DATE, CURRENT_TIME, CURRENT_TIMESTAMP;

-- Extract parts
SELECT EXTRACT(YEAR FROM order_date) AS year,
       EXTRACT(MONTH FROM order_date) AS month
FROM orders;

-- Date arithmetic
SELECT order_date, order_date + INTERVAL '30 days' AS due_date
FROM orders;

-- Format date
SELECT TO_CHAR(order_date, 'YYYY-MM-DD') FROM orders;
```

### Mathematical Functions

```sql
-- Basic arithmetic
SELECT product_name, unit_price, units_in_stock, 
       unit_price * units_in_stock AS inventory_value
FROM products;

-- Rounding
SELECT ROUND(unit_price, 2) FROM products;

-- Absolute value, power, square root
SELECT ABS(-15), POWER(2, 3), SQRT(16);
```

### Transaction Control

```sql
-- Begin a transaction
BEGIN;

-- Make changes
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;

-- Commit changes
COMMIT;

-- Or roll back in case of error
ROLLBACK;
```

### Views

```sql
-- Create a view
CREATE VIEW product_details AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    s.supplier_name,
    p.unit_price,
    p.units_in_stock
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers s ON p.supplier_id = s.supplier_id;

-- Use the view
SELECT * FROM product_details WHERE units_in_stock < 10;
```

**Conclusion**

SQL syntax forms the foundation for interacting with relational databases like PostgreSQL. Starting with basic SELECT queries and progressing through data manipulation, table creation, and more advanced features like joins and subqueries, these fundamental SQL concepts enable effective database interaction. As you become more comfortable with these basics, you can explore PostgreSQL-specific extensions and advanced features that build upon this standard SQL syntax.

---

