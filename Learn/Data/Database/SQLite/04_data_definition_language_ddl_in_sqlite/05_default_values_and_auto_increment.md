## Default Values and Auto-increment


### Default Values

Provides values when INSERT statement doesn't specify them.

**Literal defaults:**

```sql
CREATE TABLE articles (
    article_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    status TEXT DEFAULT 'draft',
    view_count INTEGER DEFAULT 0,
    is_published INTEGER DEFAULT 0
);
```

**Expression defaults:**

```sql
CREATE TABLE events (
    event_id INTEGER PRIMARY KEY,
    event_name TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

**Using functions as defaults:**

```sql
CREATE TABLE sessions (
    session_id TEXT DEFAULT (lower(hex(randomblob(16)))),
    user_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

### Auto-increment

SQLite provides automatic incrementing for INTEGER PRIMARY KEY columns.

**Basic auto-increment:**

```sql
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,  -- auto-increments automatically
    customer_id INTEGER,
    order_date TEXT
);
```

**AUTOINCREMENT keyword:**

```sql
CREATE TABLE invoices (
    invoice_id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount REAL,
    issue_date TEXT
);
```

**Difference between with and without AUTOINCREMENT:**

- Without AUTOINCREMENT: SQLite reuses deleted ROWID values
- With AUTOINCREMENT: SQLite never reuses deleted values (maintains monotonic increase)
- AUTOINCREMENT uses additional storage and is slightly slower

[Inference] AUTOINCREMENT is typically only needed when ROWID reuse would cause problems, such as when IDs are used as permanent references outside the database.

**Example with INSERT:**

```sql
-- Auto-increment in action
INSERT INTO orders (customer_id, order_date) 
VALUES (101, '2025-10-04');
-- order_id is automatically assigned
```

