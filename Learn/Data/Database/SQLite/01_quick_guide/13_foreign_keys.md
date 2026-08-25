## Foreign Keys


Foreign key enforcement is **off by default** in SQLite and must be enabled per connection:

```sql
PRAGMA foreign_keys = ON;
```

### Defining Foreign Keys

```sql
CREATE TABLE orders (
    id      INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE
);
```

### ON DELETE and ON UPDATE Actions

|Action|Behavior|
|---|---|
|`NO ACTION`|Default; violation raises an error|
|`RESTRICT`|Similar to NO ACTION but checked immediately|
|`CASCADE`|Propagate delete/update to child rows|
|`SET NULL`|Set child column to NULL|
|`SET DEFAULT`|Set child column to its default value|

---

