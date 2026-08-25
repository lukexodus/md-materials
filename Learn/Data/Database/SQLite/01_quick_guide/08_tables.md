## Tables


### Creating Tables

```sql
CREATE TABLE users (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    username   TEXT    NOT NULL UNIQUE,
    email      TEXT    NOT NULL,
    created_at TEXT    DEFAULT (datetime('now')),
    active     INTEGER NOT NULL DEFAULT 1
);
```

### Column Constraints

|Constraint|Meaning|
|---|---|
|`PRIMARY KEY`|Uniquely identifies each row|
|`NOT NULL`|Rejects NULL values|
|`UNIQUE`|Rejects duplicate values|
|`DEFAULT value`|Used when no value is supplied|
|`CHECK(expr)`|Rejects rows where expr is false|
|`REFERENCES`|Foreign key reference|

### Composite Primary Key

```sql
CREATE TABLE order_items (
    order_id   INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity   INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (order_id, product_id)
);
```

### Modifying Tables

SQLite's `ALTER TABLE` is limited compared to other databases. Supported operations:

```sql
ALTER TABLE users ADD COLUMN phone TEXT;
ALTER TABLE users RENAME COLUMN phone TO phone_number;
ALTER TABLE users RENAME TO accounts;
DROP TABLE accounts;
```

To make structural changes not supported by `ALTER TABLE` (such as dropping a column in older versions), the standard approach is:

1. Create a new table with the desired schema.
2. Copy data.
3. Drop the old table.
4. Rename the new table.

SQLite 3.35.0+ added `DROP COLUMN` support for straightforward cases.

---

