## Dropping and Renaming Tables/Columns


### Dropping Tables

Permanently removes a table and all its data.

**Basic DROP TABLE:**

```sql
DROP TABLE employees;
```

**With IF EXISTS:**

```sql
DROP TABLE IF EXISTS temporary_data;
```

**Considerations:**

- Cannot be undone
- Foreign key constraints may prevent dropping referenced tables
- Triggers and indexes associated with the table are also dropped

### Renaming Tables

Changes the name of an existing table.

**Basic RENAME:**

```sql
ALTER TABLE employees RENAME TO staff_members;
```

**Example workflow:**

```sql
-- Check if table exists first
SELECT name FROM sqlite_master WHERE type='table' AND name='old_name';

-- Rename the table
ALTER TABLE old_name RENAME TO new_name;
```

### Renaming Columns

Available in SQLite 3.25.0 and later.

**Basic column rename:**

```sql
ALTER TABLE employees RENAME COLUMN phone TO phone_number;
```

**Example:**

```sql
-- Rename multiple columns (requires multiple statements)
ALTER TABLE products RENAME COLUMN desc TO description;
ALTER TABLE products RENAME COLUMN qty TO quantity;
```

### Dropping Columns

Available in SQLite 3.35.0 and later.

**Basic column drop:**

```sql
ALTER TABLE employees DROP COLUMN middle_name;
```

**Restrictions:**

- Cannot drop primary key columns
- Cannot drop columns that are part of a foreign key constraint
- Cannot drop columns if the table has triggers or views that reference the column

### Recreating Tables (for older SQLite versions)

For versions before 3.35.0, modifying table structure requires recreation:

```sql
-- Step 1: Create new table with desired structure
CREATE TABLE employees_new (
    employee_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    -- 'middle_name' column removed
    email TEXT,
    hire_date TEXT
);

-- Step 2: Copy data from old table
INSERT INTO employees_new 
SELECT employee_id, first_name, last_name, email, hire_date 
FROM employees;

-- Step 3: Drop old table
DROP TABLE employees;

-- Step 4: Rename new table
ALTER TABLE employees_new RENAME TO employees;

-- Step 5: Recreate indexes, triggers, and views if any
```

### Schema Information Queries

SQLite stores schema information in the `sqlite_master` table.

**View all tables:**

```sql
SELECT name FROM sqlite_master WHERE type='table';
```

**View table structure:**

```sql
PRAGMA table_info(employees);
```

**View foreign keys:**

```sql
PRAGMA foreign_key_list(orders);
```

**View indexes:**

```sql
PRAGMA index_list(employees);
```

**Get CREATE TABLE statement:**

```sql
SELECT sql FROM sqlite_master WHERE type='table' AND name='employees';
```

### Transaction Control with DDL

DDL statements in SQLite are transactional and can be rolled back:

```sql
BEGIN TRANSACTION;

CREATE TABLE test_table (
    id INTEGER PRIMARY KEY,
    data TEXT
);

-- If something goes wrong
ROLLBACK;  -- Table creation is undone

-- Or if everything is fine
COMMIT;  -- Table creation is finalized
```

**Key points:**

- Multiple DDL operations can be grouped in a single transaction
- Improves performance for bulk schema changes
- Provides atomicity for related schema modifications

**Example:**

```sql
BEGIN TRANSACTION;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE INDEX idx_customer_orders ON orders(customer_id);

COMMIT;
```

---

**Important related topics:** Data Manipulation Language (DML) for working with data in these tables, Indexes for optimizing query performance, Views for creating virtual tables, Triggers for automating responses to data changes, and Database normalization principles for effective schema design.

---

