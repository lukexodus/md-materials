## CRUD Operations


### INSERT

```sql
-- Single row
INSERT INTO users (username, email) VALUES ('alice', 'alice@example.com');

-- Multiple rows
INSERT INTO users (username, email) VALUES
    ('bob',   'bob@example.com'),
    ('carol', 'carol@example.com');

-- Insert or ignore on conflict
INSERT OR IGNORE INTO users (username, email) VALUES ('alice', 'alice2@example.com');

-- Insert or replace on conflict
INSERT OR REPLACE INTO users (username, email) VALUES ('alice', 'alice_new@example.com');
```

### SELECT

```sql
-- All rows
SELECT * FROM users;

-- Specific columns with condition
SELECT username, email FROM users WHERE active = 1;

-- Ordering and limiting
SELECT username FROM users ORDER BY created_at DESC LIMIT 10;

-- Aliasing
SELECT username AS name, email AS contact FROM users;
```

### UPDATE

```sql
UPDATE users SET active = 0 WHERE id = 42;

UPDATE users SET email = 'new@example.com', active = 1 WHERE username = 'bob';
```

### DELETE

```sql
DELETE FROM users WHERE active = 0;

-- Delete all rows (table structure remains)
DELETE FROM users;
```

---

