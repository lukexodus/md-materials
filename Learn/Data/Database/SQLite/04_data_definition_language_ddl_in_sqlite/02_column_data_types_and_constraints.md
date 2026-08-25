## Column Data Types and Constraints


### Storage Classes

SQLite uses dynamic typing with five storage classes:

- **NULL**: The value is a NULL value
- **INTEGER**: Signed integer (1, 2, 3, 4, 6, or 8 bytes)
- **REAL**: Floating point value (8-byte IEEE floating point)
- **TEXT**: Text string (UTF-8, UTF-16BE, or UTF-16LE)
- **BLOB**: Binary Large Object, stored exactly as input

### Type Affinity

SQLite uses type affinity rules to determine which storage class to use for a value. Common type affinities:

- **TEXT**: TEXT, CHAR, VARCHAR, CLOB
- **NUMERIC**: NUMERIC, DECIMAL, BOOLEAN, DATE, DATETIME
- **INTEGER**: INT, INTEGER, BIGINT, SMALLINT
- **REAL**: REAL, DOUBLE, FLOAT
- **BLOB**: BLOB (no affinity declared)

**Example:**

```sql
CREATE TABLE products (
    product_id INTEGER,
    product_name TEXT,
    price REAL,
    in_stock BOOLEAN,  -- stored as INTEGER (0 or 1)
    description TEXT,
    image BLOB
);
```

### Column Constraints

Constraints enforce rules on column data:

**NOT NULL**: Ensures column cannot contain NULL values

```sql
CREATE TABLE users (
    username TEXT NOT NULL,
    password TEXT NOT NULL
);
```

**UNIQUE**: Ensures all values in column are distinct

```sql
CREATE TABLE accounts (
    account_id INTEGER,
    email TEXT UNIQUE
);
```

**CHECK**: Validates values against a condition

```sql
CREATE TABLE products (
    product_id INTEGER,
    price REAL CHECK(price > 0),
    quantity INTEGER CHECK(quantity >= 0)
);
```

**DEFAULT**: Provides default value when none specified

```sql
CREATE TABLE orders (
    order_id INTEGER,
    order_date TEXT DEFAULT CURRENT_TIMESTAMP,
    status TEXT DEFAULT 'pending'
);
```

**COLLATE**: Defines text comparison rules

```sql
CREATE TABLE names (
    name TEXT COLLATE NOCASE  -- case-insensitive comparisons
);
```

