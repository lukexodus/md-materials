## CRUD Operations 


### Introduction to CRUD Operations

Database management systems like PostgreSQL are designed to perform four fundamental operations: Create, Read, Update, and Delete (CRUD). These operations form the backbone of data manipulation in relational databases. PostgreSQL, as an advanced open-source relational database, provides robust support for these operations through SQL (Structured Query Language).

**Key Points**:

- CRUD stands for Create, Read, Update, and Delete
- These operations are essential for database management
- PostgreSQL implements CRUD through SQL syntax
- Understanding CRUD operations is fundamental to database development

### CREATE Operations

CREATE operations in PostgreSQL allow you to add new records to tables. The primary SQL command used for this purpose is `INSERT`.

#### Basic INSERT Syntax

```sql
INSERT INTO table_name(column1, column2, ...)
VALUES (value1, value2, ...);
```

#### INSERT with All Columns

```sql
INSERT INTO users
VALUES (1, 'John Doe', 'john@example.com', '2023-01-15');
```

#### INSERT with Specific Columns

```sql
INSERT INTO users(name, email)
VALUES ('Jane Smith', 'jane@example.com');
```

#### INSERT Multiple Rows

```sql
INSERT INTO products(name, price, category)
VALUES 
    ('Laptop', 1200.00, 'Electronics'),
    ('Desk Chair', 199.99, 'Furniture'),
    ('Coffee Mug', 12.50, 'Kitchen');
```

#### INSERT with Returning Data

```sql
INSERT INTO orders(customer_id, order_date, total)
VALUES (42, CURRENT_DATE, 125.99)
RETURNING order_id, order_date;
```

### READ Operations

READ operations retrieve data from the database. The `SELECT` statement is used for this purpose and offers extensive flexibility in terms of filtering, sorting, and joining data.

#### Basic SELECT Syntax

```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

#### Select All Columns and Rows

```sql
SELECT * FROM customers;
```

#### Select Specific Columns

```sql
SELECT first_name, last_name, email FROM customers;
```

#### Filtering with WHERE Clause

```sql
SELECT * FROM products
WHERE price > 100 AND category = 'Electronics';
```

#### Sorting Results

```sql
SELECT * FROM orders
ORDER BY order_date DESC;
```

#### Limiting Results

```sql
SELECT * FROM transactions
LIMIT 10 OFFSET 20;
```

#### Aggregation Functions

```sql
SELECT 
    category,
    COUNT(*) as total_products,
    AVG(price) as average_price,
    MAX(price) as highest_price
FROM products
GROUP BY category
HAVING COUNT(*) > 5;
```

#### Joining Tables

```sql
SELECT 
    o.order_id,
    c.name as customer_name,
    o.order_date,
    o.total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= '2023-01-01';
```

### UPDATE Operations

UPDATE operations modify existing records in the database. PostgreSQL provides the `UPDATE` statement for this purpose.

#### Basic UPDATE Syntax

```sql
UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition;
```

#### Update Single Row

```sql
UPDATE customers
SET email = 'newemail@example.com'
WHERE customer_id = 5;
```

#### Update Multiple Rows

```sql
UPDATE products
SET price = price * 1.1
WHERE category = 'Electronics';
```

#### Update with Returning Data

```sql
UPDATE inventory
SET stock_level = stock_level - 5
WHERE product_id = 101
RETURNING product_id, stock_level AS new_stock_level;
```

#### Update with Subquery

```sql
UPDATE employees
SET salary = salary * 1.05
WHERE department_id IN (
    SELECT department_id FROM departments
    WHERE performance_rating > 8
);
```

#### Update with JOINs

```sql
UPDATE orders o
SET status = 'SHIPPED'
FROM shipping s
WHERE o.order_id = s.order_id
AND s.ship_date = CURRENT_DATE;
```

### DELETE Operations

DELETE operations remove records from the database. PostgreSQL uses the `DELETE` statement for this purpose.

#### Basic DELETE Syntax

```sql
DELETE FROM table_name
WHERE condition;
```

#### Delete Specific Rows

```sql
DELETE FROM sessions
WHERE last_activity < NOW() - INTERVAL '30 days';
```

#### Delete All Rows

```sql
DELETE FROM temp_logs;
```

#### Delete with Returning Data

```sql
DELETE FROM cart_items
WHERE user_id = 42
RETURNING item_id, quantity;
```

#### Delete with Subquery

```sql
DELETE FROM products
WHERE product_id IN (
    SELECT product_id FROM inventory
    WHERE expired_date < CURRENT_DATE
);
```

### Advanced CRUD Techniques

#### UPSERT Operations (INSERT ON CONFLICT)

Upsert combines INSERT and UPDATE operations, allowing you to either insert a new row or update an existing one if there's a conflict.

```sql
INSERT INTO products(product_id, name, price)
VALUES (101, 'Smartphone', 699.99)
ON CONFLICT (product_id)
DO UPDATE SET price = EXCLUDED.price;
```

#### Bulk Operations

PostgreSQL allows efficient bulk operations for better performance when working with large datasets.

```sql
-- Bulk insert from CSV
COPY customers(name, email, join_date)
FROM '/path/to/customers.csv'
WITH (FORMAT CSV, HEADER TRUE);

-- Bulk update
UPDATE products
SET discontinued = TRUE
WHERE product_id BETWEEN 1000 AND 1999;
```

#### Transactions

Wrap CRUD operations in transactions to ensure data integrity.

```sql
BEGIN;

INSERT INTO orders(customer_id, order_date, total)
VALUES (42, CURRENT_DATE, 125.99)
RETURNING order_id INTO order_id_var;

INSERT INTO order_items(order_id, product_id, quantity, price)
VALUES
    (order_id_var, 101, 2, 49.99),
    (order_id_var, 203, 1, 26.01);

UPDATE inventory
SET stock_level = stock_level - 2
WHERE product_id = 101;

UPDATE inventory
SET stock_level = stock_level - 1
WHERE product_id = 203;

COMMIT;
```

### Best Practices for CRUD Operations

#### Use Parameterized Queries

Avoid SQL injection by using parameterized queries:

```sql
-- Using prepare statements
PREPARE user_insert(text, text) AS
INSERT INTO users(name, email) VALUES($1, $2);

EXECUTE user_insert('John Smith', 'john@example.com');
```

#### Implement Data Validation

Validate data before performing CRUD operations:

```sql
-- Using CHECK constraints
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    price DECIMAL(10,2) CHECK (price > 0),
    stock INTEGER CHECK (stock >= 0)
);
```

#### Use Appropriate Indexes

Optimize read operations with proper indexes:

```sql
-- Create an index for frequently queried columns
CREATE INDEX idx_products_category ON products(category);
```

#### Implement Soft Deletes

Consider using soft deletes for sensitive data:

```sql
-- Instead of DELETE FROM users WHERE user_id = 5;
UPDATE users
SET is_deleted = TRUE, deleted_at = CURRENT_TIMESTAMP
WHERE user_id = 5;
```

#### Utilize Database Constraints

Enforce data integrity with constraints:

```sql
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total DECIMAL(10,2) NOT NULL CHECK (total >= 0)
);
```

### Common CRUD Operation Use Cases

#### User Management System

```sql
-- Create a user
INSERT INTO users(username, email, password_hash, created_at)
VALUES ('newuser', 'user@example.com', 'hashed_password', CURRENT_TIMESTAMP);

-- Read user profile
SELECT username, email, profile_pic, created_at
FROM users
WHERE user_id = 42;

-- Update user profile
UPDATE users
SET email = 'newemail@example.com', last_login = CURRENT_TIMESTAMP
WHERE user_id = 42;

-- Delete user account
DELETE FROM users
WHERE user_id = 42;
```

#### E-commerce Order Processing

```sql
-- Create new order
BEGIN;
INSERT INTO orders(customer_id, shipping_address, order_date)
VALUES (123, '123 Main St, Anytown', CURRENT_DATE)
RETURNING order_id INTO new_order_id;

INSERT INTO order_items(order_id, product_id, quantity, unit_price)
VALUES
    (new_order_id, 456, 2, 45.99),
    (new_order_id, 789, 1, 129.00);

UPDATE inventory
SET stock = stock - 2
WHERE product_id = 456;

UPDATE inventory
SET stock = stock - 1
WHERE product_id = 789;
COMMIT;

-- Read order details
SELECT 
    o.order_id, 
    c.name as customer_name,
    o.order_date,
    SUM(oi.quantity * oi.unit_price) as total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_id = new_order_id
GROUP BY o.order_id, c.name, o.order_date;

-- Update order status
UPDATE orders
SET status = 'SHIPPED', shipped_date = CURRENT_DATE
WHERE order_id = new_order_id;
```

### Troubleshooting CRUD Operations

#### Common Issues and Solutions

1. **Handling Constraint Violations**

```sql
-- Try to insert with unique constraint
BEGIN;
INSERT INTO users(email, username)
VALUES ('user@example.com', 'newuser')
ON CONFLICT (email) DO NOTHING;
-- Check if insertion succeeded
SELECT * FROM users WHERE email = 'user@example.com';
COMMIT;
```

2. **Dealing with Foreign Key Constraints**

```sql
-- Check foreign key references before deletion
SELECT table_name, constraint_name
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY' 
AND constraint_schema = 'public';

-- Find records that would be affected by deletion
SELECT o.* FROM orders o
WHERE o.customer_id = 42;
```

3. **Troubleshooting Slow Queries**

```sql
-- Analyze slow SELECT query
EXPLAIN ANALYZE
SELECT * FROM products
WHERE category = 'Electronics'
ORDER BY price DESC;
```

### Performance Considerations

#### Query Optimization

```sql
-- Use EXPLAIN ANALYZE to check query execution plan
EXPLAIN ANALYZE
SELECT c.name, SUM(o.total) as total_purchases
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date > '2023-01-01'
GROUP BY c.name
HAVING SUM(o.total) > 1000;
```

#### Batching Operations

Instead of individual INSERTs or UPDATEs, use batch operations:

```sql
-- Batch insert
INSERT INTO log_entries(user_id, action, timestamp)
VALUES
    (101, 'LOGIN', CURRENT_TIMESTAMP),
    (102, 'PURCHASE', CURRENT_TIMESTAMP),
    (103, 'LOGOUT', CURRENT_TIMESTAMP);
```

#### Connection Pooling

Use connection pooling to manage database connections efficiently, reducing the overhead of establishing connections for each CRUD operation.

### Security Considerations

#### Role-Based Access Control

```sql
-- Create roles with specific privileges
CREATE ROLE app_read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read_only;

CREATE ROLE app_writer;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO app_writer;
```

#### Row-Level Security

```sql
-- Enable row-level security on a table
ALTER TABLE customer_data ENABLE ROW LEVEL SECURITY;

-- Create policy that restricts access to own data
CREATE POLICY customer_data_access ON customer_data
    USING (user_id = current_user_id());
```

### Integration with Application Code

#### Example with Node.js and pg Library

```javascript
const { Pool } = require('pg');
const pool = new Pool({
  user: 'dbuser',
  host: 'localhost',
  database: 'myapp',
  password: 'password',
  port: 5432,
});

// CREATE operation
async function createUser(name, email) {
  const query = 'INSERT INTO users(name, email) VALUES($1, $2) RETURNING user_id';
  const values = [name, email];
  const result = await pool.query(query, values);
  return result.rows[0];
}

// READ operation
async function getUserById(userId) {
  const query = 'SELECT * FROM users WHERE user_id = $1';
  const result = await pool.query(query, [userId]);
  return result.rows[0];
}

// UPDATE operation
async function updateUserEmail(userId, newEmail) {
  const query = 'UPDATE users SET email = $2 WHERE user_id = $1 RETURNING *';
  const result = await pool.query(query, [userId, newEmail]);
  return result.rows[0];
}

// DELETE operation
async function deleteUser(userId) {
  const query = 'DELETE FROM users WHERE user_id = $1 RETURNING *';
  const result = await pool.query(query, [userId]);
  return result.rows[0];
}
```

#### Example with Python and psycopg2

```python
import psycopg2
from psycopg2 import pool

connection_pool = psycopg2.pool.SimpleConnectionPool(
    1, 20,
    user="postgres",
    password="password",
    host="localhost",
    port="5432",
    database="myapp"
)

# CREATE operation
def create_product(name, price, category):
    conn = connection_pool.getconn()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO products(name, price, category) VALUES (%s, %s, %s) RETURNING product_id",
                (name, price, category)
            )
            product_id = cur.fetchone()[0]
            conn.commit()
            return product_id
    finally:
        connection_pool.putconn(conn)

# READ operation
def get_products_by_category(category):
    conn = connection_pool.getconn()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT * FROM products WHERE category = %s ORDER BY price",
                (category,)
            )
            return cur.fetchall()
    finally:
        connection_pool.putconn(conn)

# UPDATE operation
def update_product_price(product_id, new_price):
    conn = connection_pool.getconn()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE products SET price = %s WHERE product_id = %s RETURNING *",
                (new_price, product_id)
            )
            conn.commit()
            return cur.fetchone()
    finally:
        connection_pool.putconn(conn)

# DELETE operation
def delete_product(product_id):
    conn = connection_pool.getconn()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "DELETE FROM products WHERE product_id = %s RETURNING *",
                (product_id,)
            )
            conn.commit()
            return cur.fetchone()
    finally:
        connection_pool.putconn(conn)
```

### Related Topics

- Database normalization and schema design
- PostgreSQL indexing strategies
- Transaction isolation levels
- Query performance optimization
- Database backup and recovery strategies
- PostgreSQL replication and high availability

---

