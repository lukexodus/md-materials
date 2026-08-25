## Primary Keys and Foreign Keys


### Primary Keys

A primary key uniquely identifies each row in a table. In SQLite, primary keys create an implicit UNIQUE constraint and NOT NULL constraint.

**Single column primary key:**

```sql
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);
```

**Composite primary key:**

```sql
CREATE TABLE order_items (
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id)
);
```

### INTEGER PRIMARY KEY and ROWID

When a column is declared as `INTEGER PRIMARY KEY`, it becomes an alias for SQLite's internal ROWID:

```sql
CREATE TABLE logs (
    log_id INTEGER PRIMARY KEY,  -- alias for ROWID
    message TEXT,
    timestamp TEXT
);
```

**Key characteristics:**

- Automatically assigned sequential values if not provided
- More efficient for lookups and joins
- Uses less storage than non-integer primary keys

### Foreign Keys

Foreign keys establish relationships between tables and enforce referential integrity.

**Enabling foreign key constraints** (required in SQLite):

```sql
PRAGMA foreign_keys = ON;
```

**Basic foreign key:**

```sql
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

**Foreign key with actions:**

```sql
CREATE TABLE order_details (
    detail_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT
);
```

**Referential actions:**

- **NO ACTION**: Prevents deletion/update if referenced (default)
- **RESTRICT**: Same as NO ACTION but cannot be deferred
- **CASCADE**: Propagates changes to child rows
- **SET NULL**: Sets foreign key to NULL
- **SET DEFAULT**: Sets foreign key to default value

