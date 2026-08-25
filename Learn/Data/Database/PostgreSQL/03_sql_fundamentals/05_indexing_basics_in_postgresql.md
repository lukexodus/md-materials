## Indexing Basics in PostgreSQL


### Introduction to Database Indexing

Indexing is a database optimization technique that significantly improves the speed of data retrieval operations. Similar to how an index in a book helps you find information quickly without reading every page, database indexes allow PostgreSQL to locate rows matching your query criteria without scanning the entire table.

**Key Points**:

- Indexes provide fast access paths to data
- They speed up SELECT queries but can slow down INSERT, UPDATE, and DELETE operations
- Indexes consume additional storage space and memory
- Proper indexing strategy is crucial for database performance

### How Indexes Work in PostgreSQL

PostgreSQL indexes are special data structures that store a subset of a table's data in a form optimized for searching. When you query data using indexed columns, PostgreSQL can use these structures to quickly locate the relevant rows.

#### Index Storage Structure

Most PostgreSQL indexes are implemented as B-tree (Balanced tree) structures, which organize data in a way that enables efficient searches, insertions, and deletions.

```
                   Root Node
                      |
        +-------------+-------------+
        |                           |
    Internal Node               Internal Node
        |                           |
  +-----+-----+             +-------+-------+
  |     |     |             |       |       |
Leaf  Leaf  Leaf          Leaf    Leaf    Leaf
```

#### Data Access Methods

When accessing data, PostgreSQL has several options:

1. **Sequential Scan**: Reading the entire table row by row
2. **Index Scan**: Using an index to find specific rows
3. **Bitmap Index Scan**: Using multiple indexes for complex queries
4. **Index Only Scan**: Retrieving data directly from the index without accessing the table

### Types of Indexes in PostgreSQL

PostgreSQL supports several index types, each optimized for different kinds of data and query patterns.

#### B-tree Indexes (Default)

B-tree is the default index type and works well for most scenarios, especially for equality and range queries.

```sql
-- Basic B-tree index creation
CREATE INDEX idx_customers_last_name ON customers(last_name);

-- Multi-column B-tree index
CREATE INDEX idx_products_category_price ON products(category, price);
```

**Example**:

```sql
-- This query can use the idx_customers_last_name index
SELECT * FROM customers WHERE last_name = 'Smith';

-- This query can use the idx_products_category_price index
SELECT * FROM products WHERE category = 'Electronics' AND price > 500;
```

#### Hash Indexes

Hash indexes are optimized for equality comparisons only. They're not suitable for range queries.

```sql
-- Hash index creation
CREATE INDEX idx_users_email_hash ON users USING HASH (email);
```

**Example**:

```sql
-- This query can use the hash index
SELECT * FROM users WHERE email = 'user@example.com';

-- This query CANNOT use the hash index effectively
SELECT * FROM users WHERE email LIKE 'user%';
```

#### GiST Indexes (Generalized Search Tree)

GiST indexes are useful for indexing geometric data types and full-text search.

```sql
-- GiST index for geometric data
CREATE INDEX idx_locations_position ON locations USING GIST (position);

-- GiST index for text search
CREATE INDEX idx_documents_content_gist ON documents 
USING GIST (to_tsvector('english', content));
```

**Example**:

```sql
-- Using GiST index for geometric queries
SELECT * FROM locations 
WHERE position <@ circle '((0,0),10)';

-- Using GiST index for text search
SELECT * FROM documents 
WHERE to_tsvector('english', content) @@ to_tsquery('postgresql & indexing');
```

#### GIN Indexes (Generalized Inverted Index)

GIN indexes are perfect for indexing array values, jsonb data, and full-text search.

```sql
-- GIN index for array elements
CREATE INDEX idx_products_tags ON products USING GIN (tags);

-- GIN index for JSONB data
CREATE INDEX idx_data_jsonb ON data USING GIN (info);

-- GIN index for text search
CREATE INDEX idx_articles_title_body ON articles 
USING GIN (to_tsvector('english', title || ' ' || body));
```

**Example**:

```sql
-- Query using GIN index on arrays
SELECT * FROM products WHERE tags @> ARRAY['organic', 'vegan'];

-- Query using GIN index on JSONB
SELECT * FROM data WHERE info @> '{"status": "active"}';
```

#### BRIN Indexes (Block Range INdex)

BRIN indexes work well for very large tables with naturally clustered data.

```sql
-- BRIN index for timestamp data
CREATE INDEX idx_logs_timestamp_brin ON logs 
USING BRIN (created_at);
```

**Example**:

```sql
-- Query using BRIN index
SELECT * FROM logs 
WHERE created_at BETWEEN '2023-01-01' AND '2023-01-31';
```

#### SP-GiST Indexes (Space-Partitioned GiST)

SP-GiST indexes support partitioned search trees and are useful for data that can be divided into non-overlapping regions.

```sql
-- SP-GiST index for IP addresses
CREATE INDEX idx_network_ip ON network_data 
USING SPGIST (ip inet_ops);
```

### Creating and Managing Indexes

#### Basic Index Creation

```sql
-- Simple index on a single column
CREATE INDEX idx_name ON table_name(column_name);

-- Index with specific method
CREATE INDEX idx_name ON table_name USING method (column_name);

-- Case-insensitive index
CREATE INDEX idx_users_email_lower ON users(LOWER(email));
```

#### Multi-Column Indexes

Multi-column indexes are useful when queries filter on multiple columns together.

```sql
-- Multi-column index (order matters!)
CREATE INDEX idx_employees_dept_salary ON employees(department_id, salary);
```

**Example**:

```sql
-- This query can effectively use the multi-column index
SELECT * FROM employees 
WHERE department_id = 5 AND salary > 50000;

-- This query can only use the first part of the index
SELECT * FROM employees 
WHERE department_id = 5;

-- This query CANNOT use the index effectively
SELECT * FROM employees 
WHERE salary > 50000;
```

#### Unique Indexes

Unique indexes enforce data uniqueness and improve query performance.

```sql
-- Create a unique index
CREATE UNIQUE INDEX idx_users_email_unique ON users(email);
```

#### Partial Indexes

Partial indexes only index a subset of the table based on a WHERE condition.

```sql
-- Partial index for active products only
CREATE INDEX idx_products_active ON products(product_id) 
WHERE status = 'active';
```

**Example**:

```sql
-- This query can use the partial index
SELECT * FROM products 
WHERE product_id = 123 AND status = 'active';
```

#### Expression Indexes

Expression indexes index the result of expressions rather than simple columns.

```sql
-- Index on a function result
CREATE INDEX idx_users_email_lower ON users(LOWER(email));

-- Index on a calculated value
CREATE INDEX idx_products_total_value ON products((price * stock));
```

**Example**:

```sql
-- This query can use the expression index
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';

-- This query can use the calculated value index
SELECT * FROM products WHERE price * stock > 10000;
```

### Index Maintenance and Management

#### Viewing Indexes

```sql
-- List all indexes in a database
SELECT 
    tablename, 
    indexname, 
    indexdef 
FROM 
    pg_indexes 
WHERE 
    schemaname = 'public' 
ORDER BY 
    tablename, 
    indexname;

-- Check indexes on a specific table
\d table_name
```

#### Rebuilding Indexes

```sql
-- Rebuild an index
REINDEX INDEX index_name;

-- Rebuild all indexes on a table
REINDEX TABLE table_name;

-- Rebuild all indexes in a database
REINDEX DATABASE database_name;
```

#### Removing Indexes

```sql
-- Drop an index
DROP INDEX index_name;
```

#### Monitoring Index Usage

PostgreSQL can track index usage statistics.

```sql
-- Enable statistics collection (needs PostgreSQL 9.1+)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- View index usage statistics
SELECT 
    schemaname, 
    relname, 
    indexrelname, 
    idx_scan, 
    idx_tup_read, 
    idx_tup_fetch 
FROM 
    pg_stat_user_indexes 
ORDER BY 
    idx_scan DESC;
```

### Index Performance Considerations

#### When to Create Indexes

Consider creating indexes in these situations:

1. Columns used in WHERE clauses frequently
2. Columns used in JOIN conditions
3. Columns used in ORDER BY or GROUP BY clauses
4. Foreign key columns
5. Columns that need uniqueness constraints

#### When to Avoid Indexes

Indexes might not be beneficial in these cases:

1. Small tables (few rows)
2. Tables with frequent large batch updates
3. Columns with low cardinality (few distinct values)
4. Columns that are rarely used in queries

#### Index Tuning Guidelines

1. **Index Selectivity**: Higher selectivity (more unique values) makes indexes more effective
2. **Column Order**: Put more selective columns first in multi-column indexes
3. **Index Size**: Consider storage requirements and maintenance overhead
4. **Query Patterns**: Analyze your application's query patterns before indexing

---

