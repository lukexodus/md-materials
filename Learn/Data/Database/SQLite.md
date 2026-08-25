# Syllabus

## Module 1: SQLite Fundamentals

- SQLite architecture and design principles
- Installation and setup across platforms
- SQLite command-line interface (sqlite3)
- Database files and storage format
- SQLite vs other database systems
- Use cases and limitations

## Module 2: Database Creation and Management

- Creating databases
- Database connection and disconnection
- Database metadata and information schema
- Database integrity checking
- Backup and restore operations
- Database encryption (SEE - SQLite Encryption Extension)

## Module 3: Data Definition Language (DDL)

- Table creation and modification
- Column data types and constraints
- Primary keys and foreign keys
- Unique constraints and check constraints
- Default values and auto-increment
- Dropping and renaming tables/columns

## Module 4: Basic SQL Operations (DML)

- INSERT statements and variations
- SELECT statements and basic queries
- UPDATE operations
- DELETE operations
- Data import and export
- Bulk operations

## Module 5: Advanced Querying

- WHERE clauses and filtering
- Sorting with ORDER BY
- LIMIT and OFFSET for pagination
- Aggregate functions (COUNT, SUM, AVG, MIN, MAX)
- GROUP BY and HAVING clauses
- Subqueries and nested queries
- Common Table Expressions (CTEs)

## Module 6: Joins and Relationships

- Inner joins
- Left and right outer joins
- Full outer joins (workarounds)
- Cross joins
- Self-joins
- Multi-table relationships
- Join optimization strategies

## Module 7: Indexes and Performance

- Index creation and types
- Clustered vs non-clustered indexes
- Composite indexes
- Partial indexes
- Index maintenance
- Query execution plans (EXPLAIN QUERY PLAN)
- Performance optimization techniques

## Module 8: SQLite Functions

- Built-in scalar functions
- String manipulation functions
- Date and time functions
- Mathematical functions
- Type conversion functions
- Custom user-defined functions
- Aggregate functions

## Module 9: Advanced Data Types and Features

- JSON support and JSON functions
- BLOB handling
- Full-text search (FTS3, FTS4, FTS5)
- Spatial data with SpatiaLite extension
- Generated columns
- Stored generated columns vs virtual columns

## Module 10: Transactions and Concurrency

- Transaction concepts (ACID properties)
- BEGIN, COMMIT, ROLLBACK
- Savepoints and nested transactions
- Isolation levels
- Locking mechanisms
- WAL mode (Write-Ahead Logging)
- Concurrent access patterns

## Module 11: Triggers and Automation

- Creating triggers (BEFORE, AFTER, INSTEAD OF)
- Trigger events (INSERT, UPDATE, DELETE)
- Trigger design patterns
- Recursive triggers
- Trigger debugging and troubleshooting
- Performance considerations

## Module 12: Views and Virtual Tables

- Creating and managing views
- Updatable views
- Virtual tables concept
- Creating virtual table modules
- Built-in virtual tables (sqlite_master, etc.)
- Performance implications

## Module 13: Security and Access Control

- Database file permissions
- SQL injection prevention
- Parameter binding and prepared statements
- Row-level security patterns
- Audit logging strategies
- Data privacy considerations

## Module 14: SQLite Extensions

- Loading and using extensions
- Popular extensions (SpatiaLite, SQLCipher)
- Creating custom extensions
- Extension distribution and deployment
- Version compatibility

## Module 15: Programming Language Integration

- Python sqlite3 module
- C/C++ SQLite API
- Java JDBC drivers
- JavaScript (Node.js) integration
- Other language bindings
- Connection pooling strategies

## Module 16: Advanced Administration

- Database analysis and statistics
- Vacuum and optimize operations
- Memory management and cache tuning
- Configuration options and pragmas
- Logging and monitoring
- Migration strategies

## Module 17: Testing and Quality Assurance

- Unit testing database operations
- Test data generation
- Schema validation
- Performance testing
- Regression testing
- Continuous integration with databases

## Module 18: Deployment and Production

- Production deployment strategies
- Replication and synchronization
- Backup automation
- Monitoring and alerting
- Capacity planning
- Disaster recovery

## Module 19: Advanced Topics

- Custom collation sequences
- Recursive queries and hierarchical data
- Graph data modeling
- Time series data handling
- Data warehousing patterns
- Migration from other databases

## Module 20: Troubleshooting and Optimization

- Common error diagnosis
- Performance bottleneck identification
- Query optimization techniques
- Schema design best practices
- Debugging tools and techniques
- Maintenance procedures

## Module 21: Real-World Projects

- Desktop application database design
- Mobile app data layer
- Web application backend
- Data analysis and reporting
- ETL processes with SQLite
- Embedded systems integration

---

# Quick Guide

## What Is SQLite

SQLite is a self-contained, serverless, zero-configuration, transactional SQL database engine. Unlike client-server database systems such as PostgreSQL or MySQL, SQLite reads and writes directly to ordinary files on disk. The entire database — schema, tables, indexes, and data — lives in a single `.db` (or `.sqlite`) file.

It is the most widely deployed database engine in the world, embedded in browsers, operating systems, mobile devices, and countless applications.

---

## Key Characteristics

- **Serverless.** No separate server process. The application reads and writes the database file directly.
- **Zero configuration.** No installation, no user accounts, no daemon to start or stop.
- **Single file.** The entire database is one cross-platform file.
- **Self-contained.** Minimal external dependencies.
- **ACID-compliant.** Atomicity, Consistency, Isolation, and Durability are supported.
- **Cross-platform.** Database files are portable across architectures and operating systems.

---

## When to Use SQLite

SQLite is appropriate when:

- The application is the only process writing to the database.
- You need a local data store without network overhead.
- You are building an embedded system, mobile app, desktop app, or CLI tool.
- You want a fast, lightweight alternative to flat files (CSV, JSON) with query capabilities.
- You are prototyping before moving to a larger database.

SQLite is **not** ideal when:

- Many clients need concurrent write access over a network.
- You need fine-grained user-level access control.
- Your dataset is many hundreds of gigabytes and write throughput is critical.
- You need replication or high-availability clustering out of the box.

---

## Installation and Access

### Command-Line Shell

Most systems include SQLite or make it easily available.

```bash
# Debian/Ubuntu
sudo apt install sqlite3

# macOS (Homebrew)
brew install sqlite

# Windows
# Download the precompiled binaries from sqlite.org
```

Start an interactive session:

```bash
sqlite3 mydata.db
```

If the file does not exist, SQLite creates it on first write.

### In-Memory Databases

```bash
sqlite3 :memory:
```

An in-memory database is destroyed when the connection closes. Useful for testing or temporary work.

---

## The SQLite Shell

Once inside the shell, you use two categories of commands:

- **Dot commands** — shell-level directives prefixed with `.`
- **SQL statements** — standard SQL terminated with `;`

### Common Dot Commands

```
.help               List all dot commands
.databases          Show attached databases
.tables             List all tables
.schema tablename   Show CREATE statement for a table
.mode column        Set output to aligned columns
.headers on         Show column headers in output
.output file.txt    Redirect output to a file
.read file.sql      Execute SQL from a file
.quit               Exit the shell
```

---

## Data Types and Type Affinity

SQLite uses a flexible **type affinity** system rather than strict column types.

### Storage Classes

Every value stored belongs to one of five storage classes:

|Storage Class|Description|
|---|---|
|NULL|The null value|
|INTEGER|Signed integer, 1–8 bytes depending on magnitude|
|REAL|8-byte IEEE 754 floating-point number|
|TEXT|UTF-8, UTF-16BE, or UTF-16LE string|
|BLOB|Binary data, stored exactly as input|

### Type Affinity

Column type declarations are advisory. SQLite maps declared types to one of five affinities: `TEXT`, `NUMERIC`, `INTEGER`, `REAL`, `BLOB`. This means you can insert a string into an `INTEGER` column without an error — though this is generally a bad practice.

### Strict Tables (SQLite 3.37+)

If you want enforced types, use `STRICT`:

```sql
CREATE TABLE measurements (
    id    INTEGER PRIMARY KEY,
    value REAL NOT NULL
) STRICT;
```

In a `STRICT` table, only the declared type is accepted.

---

## Creating and Managing Databases

### Creating a Database

A database is created implicitly when you open a file that does not exist:

```sql
-- Nothing special needed; the file is created on first write
```

### Attaching Additional Databases

```sql
ATTACH DATABASE 'archive.db' AS archive;

-- Query across both
SELECT * FROM main.orders
UNION ALL
SELECT * FROM archive.orders;

DETACH DATABASE archive;
```

---

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

## Querying

### Filtering

```sql
-- Comparison operators
WHERE age > 18
WHERE status != 'banned'
WHERE score BETWEEN 50 AND 100

-- Pattern matching
WHERE username LIKE 'a%'      -- starts with 'a'
WHERE email LIKE '%@gmail.com'

-- NULL checks
WHERE phone IS NULL
WHERE phone IS NOT NULL

-- IN list
WHERE country IN ('PH', 'SG', 'MY')

-- Logical operators
WHERE active = 1 AND age >= 18
WHERE role = 'admin' OR role = 'moderator'
```

### Aggregation

```sql
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM users WHERE active = 1;
SELECT AVG(score), MAX(score), MIN(score) FROM results;
SELECT country, COUNT(*) AS total FROM users GROUP BY country;
SELECT country, COUNT(*) AS total FROM users GROUP BY country HAVING total > 100;
```

### Joins

```sql
-- Inner join
SELECT u.username, o.amount
FROM users u
JOIN orders o ON u.id = o.user_id;

-- Left join (keeps all users, even those with no orders)
SELECT u.username, o.amount
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;

-- Self join
SELECT a.username AS employee, b.username AS manager
FROM users a
JOIN users b ON a.manager_id = b.id;
```

### Subqueries

```sql
-- Scalar subquery
SELECT username FROM users
WHERE id = (SELECT user_id FROM orders ORDER BY amount DESC LIMIT 1);

-- IN subquery
SELECT username FROM users
WHERE id IN (SELECT DISTINCT user_id FROM orders WHERE amount > 500);
```

### Common Table Expressions (CTEs)

```sql
WITH active_users AS (
    SELECT * FROM users WHERE active = 1
),
high_spenders AS (
    SELECT user_id FROM orders GROUP BY user_id HAVING SUM(amount) > 1000
)
SELECT u.username
FROM active_users u
JOIN high_spenders h ON u.id = h.user_id;
```

### Recursive CTEs

```sql
-- Generate a sequence of numbers 1 through 10
WITH RECURSIVE nums(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 10
)
SELECT n FROM nums;

-- Traverse a tree/hierarchy
WITH RECURSIVE subordinates(id, username, level) AS (
    SELECT id, username, 0 FROM users WHERE manager_id IS NULL
    UNION ALL
    SELECT u.id, u.username, s.level + 1
    FROM users u
    JOIN subordinates s ON u.manager_id = s.id
)
SELECT * FROM subordinates;
```

### Window Functions

```sql
-- Row number per partition
SELECT username, country,
       ROW_NUMBER() OVER (PARTITION BY country ORDER BY created_at) AS rn
FROM users;

-- Running total
SELECT id, amount,
       SUM(amount) OVER (ORDER BY id) AS running_total
FROM orders;

-- Ranking
SELECT username, score,
       RANK()       OVER (ORDER BY score DESC) AS rank,
       DENSE_RANK() OVER (ORDER BY score DESC) AS dense_rank
FROM results;

-- Lag and lead
SELECT id, amount,
       LAG(amount, 1, 0) OVER (ORDER BY id) AS prev_amount
FROM orders;
```

---

## Indexes

### Why Indexes Matter

Without an index, SQLite performs a full table scan for every query. Indexes trade storage and write performance for faster reads.

### Creating Indexes

```sql
-- Basic index
CREATE INDEX idx_users_email ON users(email);

-- Unique index
CREATE UNIQUE INDEX idx_users_username ON users(username);

-- Composite index
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at);

-- Partial index (only indexes rows matching the condition)
CREATE INDEX idx_active_users ON users(username) WHERE active = 1;
```

### Dropping Indexes

```sql
DROP INDEX idx_users_email;
```

### Choosing What to Index

General guidance:

- Index columns used frequently in `WHERE`, `JOIN ON`, and `ORDER BY` clauses.
- Composite indexes are most effective when the leftmost columns match your query's filter.
- Avoid indexing columns with very low cardinality (e.g., a boolean column with only two values) unless combined with higher-cardinality columns or used as partial indexes.
- Every index costs time on `INSERT`, `UPDATE`, and `DELETE`.

### EXPLAIN QUERY PLAN

```sql
EXPLAIN QUERY PLAN
SELECT * FROM users WHERE email = 'alice@example.com';
```

The output shows whether SQLite uses an index (`SEARCH`) or a full scan (`SCAN`). Use this to verify that indexes are being used as expected.

---

## Transactions

SQLite wraps every statement in an implicit transaction. For batched work, use explicit transactions.

```sql
BEGIN;

INSERT INTO orders (user_id, amount) VALUES (1, 99.99);
INSERT INTO order_items (order_id, product_id, quantity) VALUES (last_insert_rowid(), 7, 2);

COMMIT;
```

If something goes wrong:

```sql
ROLLBACK;
```

### Savepoints

```sql
BEGIN;
SAVEPOINT before_update;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;

-- Something went wrong
ROLLBACK TO before_update;

COMMIT;
```

### Transaction Modes

SQLite supports three modes started with:

```sql
BEGIN DEFERRED;    -- Default: lock acquired on first read or write
BEGIN IMMEDIATE;   -- Write lock acquired immediately
BEGIN EXCLUSIVE;   -- Exclusive lock; no other connection can read or write
```

---

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

## Views

A view is a saved SELECT query that acts like a read-only table.

```sql
CREATE VIEW active_users_view AS
SELECT id, username, email
FROM users
WHERE active = 1;

SELECT * FROM active_users_view WHERE username LIKE 'a%';

DROP VIEW active_users_view;
```

---

## Triggers

Triggers execute SQL automatically in response to `INSERT`, `UPDATE`, or `DELETE` events.

```sql
-- Log deletions
CREATE TABLE deleted_users_log (
    user_id  INTEGER,
    username TEXT,
    deleted_at TEXT DEFAULT (datetime('now'))
);

CREATE TRIGGER log_deleted_user
AFTER DELETE ON users
FOR EACH ROW
BEGIN
    INSERT INTO deleted_users_log (user_id, username)
    VALUES (OLD.id, OLD.username);
END;
```

### Trigger Timing

|Timing|Meaning|
|---|---|
|`BEFORE`|Fires before the operation|
|`AFTER`|Fires after the operation|
|`INSTEAD OF`|Fires in place of the operation (views only)|

### NEW and OLD References

- `NEW.column` — the incoming value (INSERT and UPDATE)
- `OLD.column` — the existing value (DELETE and UPDATE)

---

## Full-Text Search

SQLite includes the FTS5 extension for full-text search.

```sql
-- Create a virtual FTS5 table
CREATE VIRTUAL TABLE articles_fts USING fts5(title, body);

-- Populate it
INSERT INTO articles_fts SELECT title, body FROM articles;

-- Query it
SELECT * FROM articles_fts WHERE articles_fts MATCH 'sqlite database';

-- Ranked results
SELECT *, rank FROM articles_fts WHERE articles_fts MATCH 'sqlite' ORDER BY rank;
```

FTS5 supports boolean operators (`AND`, `OR`, `NOT`), phrase queries (`"exact phrase"`), and prefix queries (`sqlite*`).

---

## JSON Support

SQLite includes built-in JSON functions (available since 3.9.0, significantly extended since).

```sql
-- Extract a value
SELECT json_extract('{"name":"Alice","age":30}', '$.name');  -- 'Alice'

-- Store JSON in a column and query it
CREATE TABLE events (id INTEGER PRIMARY KEY, data TEXT);

INSERT INTO events (data) VALUES ('{"type":"login","user":"alice"}');

SELECT json_extract(data, '$.user')
FROM events
WHERE json_extract(data, '$.type') = 'login';

-- Build JSON
SELECT json_object('id', id, 'name', username) FROM users;

-- JSON array
SELECT json_array(1, 2, 3);  -- '[1,2,3]'
```

---

## PRAGMAs

PRAGMAs are SQLite-specific commands that control behavior or retrieve metadata.

### Commonly Used PRAGMAs

```sql
-- Enable foreign key enforcement
PRAGMA foreign_keys = ON;

-- Check and set page size (must be set before any tables exist)
PRAGMA page_size = 4096;

-- WAL mode for better concurrent read performance
PRAGMA journal_mode = WAL;

-- Control synchronization (faster but less durable at lower settings)
PRAGMA synchronous = NORMAL;   -- Default is FULL

-- Cache size (negative = kilobytes, positive = pages)
PRAGMA cache_size = -64000;    -- 64 MB

-- Retrieve table info
PRAGMA table_info(users);

-- Check database integrity
PRAGMA integrity_check;

-- Get list of all tables
PRAGMA database_list;
```

---

## WAL Mode

Write-Ahead Logging (WAL) is an alternative journaling mode that improves concurrency.

```sql
PRAGMA journal_mode = WAL;
```

In WAL mode:

- Readers do not block writers, and writers do not block readers.
- Multiple readers can coexist with one writer.
- Performance for write-heavy workloads is generally better.
- The database consists of the main file plus `-wal` and `-shm` sidecar files while WAL mode is active.

WAL mode persists across connections and survives restarts. To return to the default:

```sql
PRAGMA journal_mode = DELETE;
```

---

## Performance Tuning

### Use Transactions for Bulk Writes

Wrapping many inserts in a single transaction is one of the highest-impact optimizations available. Without a transaction, each insert is its own transaction and triggers an fsync.

```sql
BEGIN;
-- thousands of inserts
COMMIT;
```

### Tune Synchronous Mode

```sql
PRAGMA synchronous = NORMAL;
```

`FULL` (default) calls fsync after every transaction. `NORMAL` reduces fsync frequency. `OFF` disables fsync entirely — fast but data can be corrupted on a power loss.

### Increase Cache Size

```sql
PRAGMA cache_size = -128000;  -- 128 MB page cache
```

### Use Prepared Statements

In application code, prepare a statement once and bind parameters repeatedly rather than building SQL strings dynamically. This avoids repeated parsing overhead.

### ANALYZE

```sql
ANALYZE;
```

This gathers statistics about table and index sizes, helping the query planner make better decisions. Run it after bulk data loads or significant schema changes.

### VACUUM

```sql
VACUUM;
```

Rebuilds the database file, reclaiming space from deleted rows and defragmenting. Can significantly reduce file size after heavy deletions.

```sql
-- Incremental vacuum (requires auto_vacuum = INCREMENTAL set before data is written)
PRAGMA auto_vacuum = INCREMENTAL;
PRAGMA incremental_vacuum(100);  -- Reclaim 100 pages
```

---

## Concurrency and Locking

SQLite supports one writer at a time. The locking hierarchy is:

1. **UNLOCKED** — No lock held.
2. **SHARED** — Reading; multiple connections can hold this simultaneously.
3. **RESERVED** — One connection intends to write; others can still read.
4. **PENDING** — Waiting for existing readers to finish.
5. **EXCLUSIVE** — Writing; no other connection can read or write.

In WAL mode, this model is relaxed: readers and a single writer can coexist.

For applications that genuinely need many concurrent writers, a client-server database (PostgreSQL, MySQL) is more appropriate.

---

## Backup and Restore

### File Copy (Offline)

When no connection is writing, simply copy the `.db` file.

```bash
cp mydata.db mydata.backup.db
```

### SQLite Online Backup API

The Online Backup API (accessible via the CLI or language bindings) safely copies a live database without stopping writes.

```bash
sqlite3 mydata.db ".backup mydata.backup.db"
```

### Dump to SQL

```bash
sqlite3 mydata.db .dump > mydata.sql
```

### Restore from SQL Dump

```bash
sqlite3 newdata.db < mydata.sql
```

---

## Security Considerations

- **No built-in user authentication.** Access control is at the OS file permission level.
- **Encryption.** The open-source SQLite does not include encryption. The commercial SQLite Encryption Extension (SEE) adds this. Third-party open-source options such as SQLCipher also exist.
- **SQL injection.** Always use parameterized queries or prepared statements in application code. Never construct SQL by concatenating user-supplied strings.
- **File permissions.** Protect database files with appropriate OS-level permissions, since anyone who can read the file has access to all data.

---

## Using SQLite in Application Code

### Python

```python
import sqlite3

con = sqlite3.connect("mydata.db")
cur = con.cursor()

# Create table
cur.execute("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)")

# Insert with parameters (always use ? placeholders, never f-strings with user input)
cur.execute("INSERT INTO users (name) VALUES (?)", ("Alice",))
con.commit()

# Query
for row in cur.execute("SELECT id, name FROM users"):
    print(row)

con.close()
```

### Node.js (better-sqlite3)

```javascript
const Database = require('better-sqlite3');
const db = new Database('mydata.db');

db.prepare("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)").run();

const insert = db.prepare("INSERT INTO users (name) VALUES (?)");
insert.run("Alice");

const rows = db.prepare("SELECT * FROM users").all();
console.log(rows);

db.close();
```

### Go (database/sql + mattn/go-sqlite3)

```go
import (
    "database/sql"
    _ "github.com/mattn/go-sqlite3"
)

db, _ := sql.Open("sqlite3", "./mydata.db")
defer db.Close()

db.Exec("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)")
db.Exec("INSERT INTO users (name) VALUES (?)", "Alice")

rows, _ := db.Query("SELECT id, name FROM users")
defer rows.Close()
for rows.Next() {
    var id int
    var name string
    rows.Scan(&id, &name)
}
```

---

## Virtual Tables

Virtual tables let external data sources appear as SQLite tables. Beyond FTS5, useful built-in and commonly available virtual tables include:

- **rtree** — R-Tree spatial index, useful for geographic bounding-box queries.
- **dbstat** — Exposes internal database statistics as a table.
- **pragma_*** — Many PRAGMAs are queryable as virtual tables (e.g., `pragma_table_info('users')`).

---

## Useful Built-In Functions

### String Functions

```sql
LENGTH(str)
UPPER(str) / LOWER(str)
SUBSTR(str, start, length)
TRIM(str) / LTRIM(str) / RTRIM(str)
REPLACE(str, old, new)
INSTR(str, substr)
PRINTF(format, ...)   -- or FORMAT() in 3.38+
```

### Numeric Functions

```sql
ABS(x)
ROUND(x, digits)
MAX(x, y) / MIN(x, y)   -- scalar versions, not aggregate
RANDOM()                  -- random integer in [-9223372036854775808, 9223372036854775807]
```

### Date and Time Functions

```sql
date('now')                      -- '2026-06-01'
time('now')                      -- current UTC time
datetime('now')                  -- '2026-06-01 HH:MM:SS'
datetime('now', 'localtime')     -- adjusted to local time
strftime('%Y-%m', 'now')         -- custom format
julianday('now')                 -- Julian day number
```

Modifiers can be chained:

```sql
datetime('now', '+7 days', 'start of month')
```

### Aggregate Functions

```sql
COUNT(*) / COUNT(col)
SUM(col)
AVG(col)
MAX(col) / MIN(col)
GROUP_CONCAT(col, separator)
```

---

## Common Patterns and Recipes

### Upsert (Insert or Update)

```sql
INSERT INTO users (id, username, email)
VALUES (1, 'alice', 'alice@example.com')
ON CONFLICT(id) DO UPDATE SET
    email = excluded.email;
```

### Pagination

```sql
-- Page 3, 20 rows per page
SELECT * FROM users ORDER BY id LIMIT 20 OFFSET 40;
```

### Pivot / Conditional Aggregation

```sql
SELECT
    month,
    SUM(CASE WHEN category = 'A' THEN amount ELSE 0 END) AS cat_a,
    SUM(CASE WHEN category = 'B' THEN amount ELSE 0 END) AS cat_b
FROM sales
GROUP BY month;
```

### Deduplication

```sql
-- Keep the row with the highest id for each email
DELETE FROM users
WHERE id NOT IN (
    SELECT MAX(id) FROM users GROUP BY email
);
```

### Generating Rows Without a Table

```sql
SELECT 1 AS n
UNION ALL SELECT 2
UNION ALL SELECT 3;
```

---

## File Format Notes

- The default page size is 4096 bytes (changed from 1024 in SQLite 3.12.0).
- The maximum database size is 281 terabytes (with the default page size).
- The maximum number of columns in a table is 2000 by default (configurable at compile time up to 32767).
- The maximum length of a string or BLOB is 1 billion bytes by default.
- The SQLite file format is stable and documented; Anthropic describes it as one of the recommended archival formats for long-term data storage. [Inference: this is based on SQLite's own documentation and widespread institutional use — the specific recommendation should be verified against your organization's standards.]

---

## Diagnostic Queries

```sql
-- List all tables
SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name;

-- List all indexes
SELECT name, tbl_name FROM sqlite_master WHERE type = 'index';

-- Show schema for a specific table
SELECT sql FROM sqlite_master WHERE name = 'users';

-- Count rows in every table (requires scripting or a loop in application code for dynamic use)
SELECT COUNT(*) FROM users;

-- Check for integrity issues
PRAGMA integrity_check;

-- Quick consistency check (faster, catches most issues)
PRAGMA quick_check;
```

---

## Summary of Key Limits

| Property                 | Default Limit                          |
| ------------------------ | -------------------------------------- |
| Max database size        | ~281 TB                                |
| Max columns per table    | 2,000                                  |
| Max tables per database  | No hard limit (practical limit varies) |
| Max string/BLOB length   | ~1 billion bytes                       |
| Max SQL statement length | ~1 billion bytes                       |
| Max attached databases   | 10                                     |
| Concurrent writers       | 1                                      |

---

## All Ways to View Data from a SQLite Database

### Command-Line Shell

#### Using `sqlite3` CLI

The most direct method for ad-hoc inspection.

```bash
sqlite3 mydata.db
```

Once inside the shell, use SQL queries:

```sql
SELECT * FROM users;
SELECT id, name, email FROM users WHERE active = 1;
```

#### Output Modes

The shell supports multiple output formats controlled by `.mode`:

```
.mode list          -- Comma-separated (default)
.mode csv           -- CSV format with proper escaping
.mode tsv           -- Tab-separated values
.mode column        -- Aligned columns with headers
.mode line          -- One column per line
.mode json          -- JSON array of objects
.mode quote         -- SQL-quoted strings
.mode box           -- ASCII box drawing
.mode markdown      -- Markdown table
```

Example:

```bash
sqlite3 -csv mydata.db "SELECT * FROM users;" > users.csv
sqlite3 -json mydata.db "SELECT * FROM users;" > users.json
```

#### One-Liner Queries

```bash
sqlite3 mydata.db "SELECT COUNT(*) FROM users;"
sqlite3 mydata.db "SELECT * FROM users WHERE id = 1;"
```

#### Headers and Column Names

```sql
.headers on         -- Show column names
.headers off        -- Hide column names
```

#### Separator Control

```sql
.separator ","      -- Set output separator
.separator "|"      -- Pipe-delimited
```

#### Viewing with Limits

```bash
sqlite3 mydata.db "SELECT * FROM users LIMIT 10;"
```

---

### Programming Language APIs

#### Python (sqlite3 Built-In)

```python
import sqlite3

con = sqlite3.connect("mydata.db")
cur = con.cursor()

## Fetch all rows
rows = cur.execute("SELECT * FROM users").fetchall()
for row in rows:
    print(row)

## Fetch one row
one_row = cur.execute("SELECT * FROM users WHERE id = 1").fetchone()
print(one_row)

## Fetch with column names
con.row_factory = sqlite3.Row
row = cur.execute("SELECT * FROM users WHERE id = 1").fetchone()
print(f"Name: {row['name']}, Email: {row['email']}")

## Iterate over rows lazily (memory-efficient for large datasets)
for row in cur.execute("SELECT * FROM users"):
    print(row)

con.close()
```

#### Python (pandas)

```python
import pandas as pd
import sqlite3

con = sqlite3.connect("mydata.db")

## Load entire table
df = pd.read_sql_query("SELECT * FROM users", con)
print(df)

## Query with filtering
df = pd.read_sql_query("SELECT id, name, email FROM users WHERE active = 1", con)
print(df.head(10))

con.close()
```

#### Node.js (better-sqlite3)

```javascript
const Database = require('better-sqlite3');
const db = new Database('mydata.db');

// Fetch all rows
const rows = db.prepare("SELECT * FROM users").all();
console.log(rows);

// Fetch one row
const row = db.prepare("SELECT * FROM users WHERE id = 1").get();
console.log(row);

// Iterate (more memory-efficient)
const stmt = db.prepare("SELECT * FROM users");
for (const row of stmt.iterate()) {
    console.log(row);
}

db.close();
```

#### Node.js (sql.js - In-Memory or File-Based)

```javascript
const initSqlJs = require('sql.js');

const SQL = await initSqlJs();
const db = new SQL.Database(fileData);  // Or omit fileData for in-memory

const result = db.exec("SELECT * FROM users");
console.log(result[0].values);  // Array of rows

db.close();
```

#### JavaScript (Browser - sql.js)

```javascript
// Load database from a file
const response = await fetch('mydata.db');
const buffer = await response.arrayBuffer();

const initSqlJs = require('sql.js');
const SQL = await initSqlJs();
const db = new SQL.Database(new Uint8Array(buffer));

const result = db.exec("SELECT * FROM users");
result[0].columns;  // Column names
result[0].values;   // Rows
```

#### Go (database/sql)

```go
import (
    "database/sql"
    _ "github.com/mattn/go-sqlite3"
)

db, err := sql.Open("sqlite3", "./mydata.db")
defer db.Close()

// Query multiple rows
rows, err := db.Query("SELECT id, name, email FROM users")
defer rows.Close()

for rows.Next() {
    var id int
    var name, email string
    rows.Scan(&id, &name, &email)
    fmt.Println(id, name, email)
}

// Query single row
var name, email string
err := db.QueryRow("SELECT name, email FROM users WHERE id = 1").
    Scan(&name, &email)
```

#### Ruby

```ruby
require 'sqlite3'

db = SQLite3::Database.new 'mydata.db'
db.results_as_hash = true  ## Get rows as hashes

## Fetch all rows
db.execute("SELECT * FROM users") do |row|
    puts row.inspect
end

## Fetch with fetch_hash
db.execute("SELECT * FROM users") do |row|
    puts "#{row['name']}: #{row['email']}"
end

db.close
```

#### Java (JDBC)

```java
import java.sql.*;

String url = "jdbc:sqlite:mydata.db";
try (Connection conn = DriverManager.getConnection(url)) {
    String sql = "SELECT * FROM users";
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery(sql);

    while (rs.next()) {
        int id = rs.getInt("id");
        String name = rs.getString("name");
        System.out.println(id + ": " + name);
    }
}
```

#### C / C++

Using the official SQLite C API:

```c
#include <sqlite3.h>
#include <stdio.h>

int main() {
    sqlite3 *db;
    sqlite3_stmt *stmt;
    int rc = sqlite3_open("mydata.db", &db);

    const char *sql = "SELECT id, name FROM users";
    rc = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);

    while (sqlite3_step(stmt) == SQLITE_ROW) {
        int id = sqlite3_column_int(stmt, 0);
        const char *name = (const char *)sqlite3_column_text(stmt, 1);
        printf("%d: %s\n", id, name);
    }

    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return 0;
}
```

---

### GUI Tools

#### SQLite Browser (DB Browser for SQLite)

A visual, cross-platform tool with a full GUI for browsing tables, running queries, and editing data.

- Download from [sqlitebrowser.org](https://sqlitebrowser.org)
- Features: table browser, SQL editor, data editing, schema inspection, export to CSV/JSON.

#### DBeaver

A feature-rich database client supporting SQLite and many other databases.

- Download from [dbeaver.io](https://dbeaver.io)
- Features: query editor, data grid, ER diagrams, import/export, scripting.

#### Datagrip (JetBrains)

Commercial IDE with first-class SQLite support.

- Part of the JetBrains suite or standalone.
- Features: intelligent query editor, data inspector, version control integration.

#### TablePlus

Lightweight macOS/Windows tool for database inspection and queries.

- Download from [tableplus.com](https://tableplus.com)

#### SQLiteOnline

Browser-based tool for viewing SQLite databases without installation.

- Access at [sqliteonline.com](https://sqliteonline.com)
- Upload `.db` file or use the in-memory demo.

#### VS Code Extensions

- **SQLite** (by alexcvzz) — Query SQLite files directly in VS Code.
- **Better SQLite3** — If using the Node.js library.

---

### Export Formats

#### CSV

```bash
sqlite3 -csv mydata.db "SELECT * FROM users;" > users.csv
```

Or within the shell:

```sql
.mode csv
.output users.csv
SELECT * FROM users;
.output stdout
```

#### JSON

```bash
sqlite3 -json mydata.db "SELECT * FROM users;" > users.json
```

#### SQL Dump (Full Database)

```bash
sqlite3 mydata.db .dump > backup.sql
```

Then restore:

```bash
sqlite3 newdb.db < backup.sql
```

#### TSV (Tab-Separated)

```bash
sqlite3 -tsv mydata.db "SELECT * FROM users;" > users.tsv
```

#### Markdown Table

```sql
.mode markdown
SELECT * FROM users;
```

#### Pipe-Delimited

```bash
sqlite3 -separator "|" mydata.db "SELECT * FROM users;"
```

---

### Programmatic Export

#### Python (to CSV)

```python
import sqlite3
import csv

con = sqlite3.connect("mydata.db")
cur = con.cursor()
cur.execute("SELECT * FROM users")

with open("users.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow([description[0] for description in cur.description])
    writer.writerows(cur.fetchall())

con.close()
```

#### Python (to JSON)

```python
import sqlite3
import json

con = sqlite3.connect("mydata.db")
con.row_factory = sqlite3.Row
cur = con.cursor()

rows = cur.execute("SELECT * FROM users").fetchall()
data = [dict(row) for row in rows]

with open("users.json", "w") as f:
    json.dump(data, f, indent=2)

con.close()
```

#### Node.js (to JSON)

```javascript
const Database = require('better-sqlite3');
const fs = require('fs');

const db = new Database('mydata.db');
const rows = db.prepare("SELECT * FROM users").all();

fs.writeFileSync('users.json', JSON.stringify(rows, null, 2));
db.close();
```

---

### Metadata and Schema Inspection

#### View All Tables

```bash
sqlite3 mydata.db ".tables"
```

Or via SQL:

```sql
SELECT name FROM sqlite_master WHERE type = 'table';
```

#### View Table Schema

```bash
sqlite3 mydata.db ".schema users"
```

Or via SQL:

```sql
SELECT sql FROM sqlite_master WHERE name = 'users';
PRAGMA table_info(users);
```

#### View All Indexes

```bash
sqlite3 mydata.db ".indexes"
```

Or via SQL:

```sql
SELECT name FROM sqlite_master WHERE type = 'index';
```

#### View Triggers

```sql
SELECT name FROM sqlite_master WHERE type = 'trigger';
SELECT sql FROM sqlite_master WHERE type = 'trigger' AND tbl_name = 'users';
```

---

### Large Dataset Inspection

#### Limit Results

```bash
sqlite3 mydata.db "SELECT * FROM large_table LIMIT 100;"
```

#### Pagination

```bash
sqlite3 mydata.db "SELECT * FROM users LIMIT 50 OFFSET 100;"  -- Page 3, 50 per page
```

#### Statistics

```sql
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM users WHERE active = 1;
```

#### Streaming Large Datasets (Python)

```python
import sqlite3

con = sqlite3.connect("mydata.db")
cur = con.cursor()

## Process rows one at a time without loading all into memory
for row in cur.execute("SELECT * FROM large_table"):
    print(row)

con.close()
```

#### Chunking (pandas)

```python
import pandas as pd

con = sqlite3.connect("mydata.db")

## Read in chunks
for chunk in pd.read_sql_query("SELECT * FROM large_table", con, chunksize=1000):
    process(chunk)

con.close()
```

---

### Real-Time Monitoring

#### Watch Changes (Shell Loop)

```bash
while true; do
    clear
    sqlite3 mydata.db "SELECT COUNT(*) as users FROM users;"
    sleep 2
done
```

#### Query with Timestamp

```bash
watch -n 2 "sqlite3 mydata.db \"SELECT COUNT(*) FROM users WHERE created_at > datetime('now', '-1 hour');\""
```

---

### Visualization

#### Plot Results (Python + Matplotlib)

```python
import sqlite3
import pandas as pd
import matplotlib.pyplot as plt

con = sqlite3.connect("mydata.db")
df = pd.read_sql_query(
    "SELECT date, SUM(amount) as total FROM orders GROUP BY date",
    con
)

plt.plot(df['date'], df['total'])
plt.show()
```

#### Interactive Dashboards (Python + Streamlit)

```python
import streamlit as st
import sqlite3
import pandas as pd

con = sqlite3.connect("mydata.db")
df = pd.read_sql_query("SELECT * FROM users", con)

st.dataframe(df)
st.bar_chart(df.groupby('country').size())
```

---

### Summary Table

| Method                 | Best For                      | Installation                           |
| ---------------------- | ----------------------------- | -------------------------------------- |
| `sqlite3` CLI          | Quick queries, one-liners     | Pre-installed or `apt install sqlite3` |
| Python sqlite3         | Scripts, automation           | Built-in                               |
| pandas                 | Data analysis, transformation | `pip install pandas`                   |
| Node.js better-sqlite3 | JavaScript backends           | `npm install better-sqlite3`           |
| DB Browser for SQLite  | Visual exploration, editing   | Download GUI app                       |
| DBeaver                | Enterprise-grade browsing     | Download GUI app                       |
| sql.js                 | Browser-based (no server)     | `npm install sql.js`                   |
| CSV/JSON export        | Sharing, reporting            | Built into shell                       |

---

## Connecting DBeaver to SQLite by Host or URL

### Important: SQLite Doesn't Work Over Network by Default

SQLite is **not a network database**. It reads and writes directly to local files. You **cannot** connect to SQLite over HTTP, TCP, or any network protocol using standard SQLite.

However, there are workarounds depending on your setup.

---

### Option 1: Remote File Access via SSH (Recommended)

If the `syllabot.db` file is on a remote machine, access it via SSH tunneling.

#### Setup SSH Tunnel in DBeaver

1. **File** → **New** → **Database Connection**
2. Select **SQLite**
3. **Path:** Enter the remote file path (e.g., `/home/user/syllabot.db`)
4. Click the **SSH** tab
5. Enable **Use SSH Tunnel**
6. Fill in:
   - **Host:** Your remote server hostname or IP
   - **Port:** 22 (default SSH)
   - **Username:** Your SSH username
   - **Authentication:** Password or public key
7. **Test Connection**
8. **Finish**

DBeaver tunnels the file access over SSH, and you interact with it as if it were local.

---

### Option 2: SCP/SFTP to Pull File Locally

If you just need to work with the file once:

```bash
## Download from remote host
scp user@remote-host:/path/to/syllabot.db ./syllabot.db

## Then open locally in DBeaver as usual
dbeaver &
```

After you're done, upload changes back:

```bash
scp ./syllabot.db user@remote-host:/path/to/syllabot.db
```

---

### Option 3: Mount Remote Filesystem (SSHFS)

Mount the remote directory locally, then access it like a normal file.

```bash
## Install sshfs (if not already installed)
sudo pacman -S sshfs

## Create mount point
mkdir -p ~/mnt/remote

## Mount remote filesystem
sshfs user@remote-host:/path/to/dir ~/mnt/remote

## Open in DBeaver
dbeaver &
## Then browse to ~/mnt/remote/syllabot.db

## Unmount when done
fusermount -u ~/mnt/remote
```

---

### Option 4: SQLite Server Wrapper (Advanced)

If you need true remote access, wrap SQLite with a lightweight HTTP or TCP server.

#### Using `sqlite-web` (Python)

Install:

```bash
pip install sqlite-web
```

On the remote machine, start the server:

```bash
sqlite_web syllabot.db --port 8080 --host 0.0.0.0
```

Then access in your browser:

```
http://remote-host:8080
```

Or use an API:

```bash
curl "http://remote-host:8080/api/query" \
  -H "Content-Type: application/json" \
  -d '{"sql": "SELECT * FROM users LIMIT 10"}'
```

**Note:** DBeaver cannot directly connect to `sqlite-web`. You'd use the web interface or a script.

---

### Option 5: PostgreSQL/MySQL Proxy (Overkill)

If you need full database client support, convert to a real network database:

1. Export SQLite to PostgreSQL:
   ```bash
   pgloader sqlite:///path/to/syllabot.db postgresql://user:pass@localhost/syllabot
   ```

2. Connect DBeaver to PostgreSQL normally by host/port.

This is rarely necessary for SQLite unless you need multi-user write access.

---

### Option 6: Docker Container with Shared Volume

If the database is in a Docker container:

```bash
## Run container with volume mount
docker run -v /path/to/syllabot.db:/data/syllabot.db my-app

## On host, DBeaver connects to the mounted file
## Path: /path/to/syllabot.db
```

---

### Quick Comparison

| Method | Pros | Cons |
|---|---|---|
| **SSH Tunnel** | Secure, transparent, no file copy | Slightly more setup |
| **SCP/SFTP** | Simple, one-time access | Manual sync, no real-time updates |
| **SSHFS Mount** | Behaves like local filesystem | Network latency, mount/unmount needed |
| **sqlite-web** | Web interface, REST API | DBeaver can't use it directly |
| **Proxy to PG** | Full network DB features | Overkill, adds complexity |

---

### Most Practical: SSH Tunnel Setup Step-by-Step

1. **Verify SSH access works:**
   ```bash
   ssh user@remote-host "ls -l /path/to/syllabot.db"
   ```

2. **In DBeaver:**
   - **File** → **New** → **Database Connection**
   - **SQLite**
   - **Path:** `/path/to/syllabot.db` (remote path)
   - **SSH** tab → **Use SSH Tunnel** ✓
   - **Host:** `remote-host`
   - **Port:** `22`
   - **Username:** `user`
   - **Auth:** Password or key
   - **Test Connection**

3. Done. You now interact with the remote file as if it were local.

---

### If You Have a URL (Web-Hosted SQLite)

If someone gave you a **URL** like `http://example.com/download/syllabot.db`:

```bash
## Download the file
wget http://example.com/download/syllabot.db

## Or
curl -O http://example.com/download/syllabot.db

## Then open locally in DBeaver
```

DBeaver cannot directly open URLs — SQLite files must be on disk (local or mounted).

---

## Using DBeaver with syllabot.db on Your Local Machine

Since the file is already on your machine, this is straightforward.

### Quick Setup

1. **Launch DBeaver**
   ```bash
   dbeaver &
   ```

2. **Create a New Connection**
   - Click **File** → **New** → **Database Connection**
   - Select **SQLite**
   - Click **Next**

3. **Browse to Your File**
   - Click the folder icon next to **Path**
   - Navigate to `syllabot.db`
   - Select it and click **Open**
   - Or paste the full path directly:
     ```
     /home/yourusername/path/to/syllabot.db
     ```

4. **Test and Connect**
   - Click **Test Connection** (optional but recommended)
   - Click **Finish**

The database now appears in the left sidebar.

---

### Finding Your File

If you're not sure where `syllabot.db` is:

```bash
## Search for it
find ~ -name "syllabot.db" 2>/dev/null

## Or check current directory
ls -lh syllabot.db
```

Once you have the full path, use it in DBeaver's path field.

---

### Next Steps (Same as Before)

Once connected:

- **Expand the database** in the left sidebar
- **Double-click any table** to view data
- **Ctrl+Alt+N** to open a new SQL editor
- Run queries like:
  ```sql
  SELECT * FROM users LIMIT 10;
  PRAGMA table_info(messages);
  SELECT COUNT(*) FROM messages;
  ```

---

# SQLite Fundamentals

SQLite is a self-contained, serverless, zero-configuration, transactional SQL database engine. Unlike traditional database systems that operate as separate server processes, SQLite reads and writes directly to ordinary disk files, making it one of the most widely deployed database engines in the world.

## SQLite Architecture and Design Principles

SQLite follows a unique architectural approach that distinguishes it from client-server database systems. The entire database engine is embedded within the application that uses it, eliminating the need for a separate database server process.

**Core architectural components:**

The SQLite architecture consists of several layers working together. The interface layer handles SQL command strings and database connections. The SQL compiler transforms SQL statements into bytecode through tokenization, parsing, and code generation. The virtual machine (VDBE - Virtual Database Engine) executes the bytecode instructions. The B-tree module manages the organization of database pages, handling both table B-trees and index B-trees. The pager module manages the reading and writing of database pages, implementing transaction control and crash recovery. The OS interface provides a portable abstraction layer for operating system calls.

**Design principles:**

SQLite prioritizes simplicity and reliability over raw performance. The library is designed to be completely self-contained with minimal external dependencies. It requires zero configuration - no setup procedures, no server processes to manage, and no configuration files. The entire database exists as a single cross-platform file that can be freely copied between 32-bit and 64-bit systems or between big-endian and little-endian architectures.

Atomicity, Consistency, Isolation, and Durability (ACID) properties are fully supported. Transactions are atomic even if interrupted by system crashes or power failures. SQLite implements serializable isolation by default, though it also supports read uncommitted and write-ahead logging modes.

The design emphasizes backward compatibility. Database files created by SQLite version 3.0.0 (released in 2004) can still be read and written by current versions. The library maintains a stable, well-documented file format that is guaranteed to be supported through at least the year 2050.

## Installation and Setup Across Platforms

SQLite requires minimal installation effort since it's a library rather than a standalone application. The database engine comes pre-installed on many systems and is embedded in numerous applications.

**Windows:**

SQLite is not pre-installed on Windows. To use the command-line tools, download the precompiled binaries from the official SQLite website. The sqlite-tools package contains sqlite3.exe, which is the command-line interface. Extract the zip file to a directory, optionally adding it to your system PATH for convenient access from any location. No installation wizard or registry modifications are required.

For development purposes, download the appropriate DLL (sqlite3.dll) and header files (sqlite3.h) from the amalgamation package. Many programming languages include SQLite bindings that handle the library automatically.

**macOS:**

SQLite comes pre-installed on macOS systems. The sqlite3 command-line tool is immediately available from the Terminal. To verify installation, run `sqlite3 --version`. The pre-installed version may not be the latest release. For the newest version, install through Homebrew using `brew install sqlite3`, or download binaries directly from the SQLite website.

**Linux:**

Most Linux distributions include SQLite by default. On Debian-based systems (Ubuntu, Mint), install or update using `sudo apt-get install sqlite3`. On Red Hat-based systems (Fedora, CentOS), use `sudo yum install sqlite` or `sudo dnf install sqlite`. On Arch Linux, use `sudo pacman -S sqlite`.

For development, install the development package that includes header files. On Debian-based systems, this is `libsqlite3-dev`. On Red Hat-based systems, use `sqlite-devel`.

**Mobile platforms:**

Both iOS and Android include SQLite as part of their core system libraries. On iOS, SQLite is available through the libsqlite3 library. On Android, SQLite is accessible through the android.database.sqlite package. Applications can use SQLite without additional installation or bundling.

**Verification:**

After installation, verify SQLite is working by opening a terminal or command prompt and typing `sqlite3 --version`. This displays the version number and compilation options. To test basic functionality, create a temporary in-memory database by typing `sqlite3 :memory:` followed by a simple SQL command like `SELECT sqlite_version();`.

## SQLite Command-Line Interface (sqlite3)

The sqlite3 command-line program is a powerful tool for interacting with SQLite databases. It provides an interactive shell for executing SQL statements, managing databases, and performing administrative tasks.

**Starting the shell:**

Launch the SQLite shell by typing `sqlite3` followed optionally by a database filename. If no filename is provided, SQLite creates a temporary in-memory database. If a filename is specified but doesn't exist, SQLite creates a new database file. To open an existing database, provide its path: `sqlite3 /path/to/database.db`.

**Basic SQL execution:**

Once in the shell, execute SQL statements by typing them and ending with a semicolon. Multi-line statements are supported - the shell continues accepting input until it encounters a semicolon. Statements can be interrupted using Ctrl+C. The shell displays query results in a default column mode with headers.

**Dot commands:**

The shell includes special meta-commands that begin with a period. These commands control shell behavior and perform administrative functions. Unlike SQL statements, dot commands don't require a semicolon.

`.help` displays a list of all available dot commands with brief descriptions. `.databases` shows all attached databases with their file paths. `.tables` lists all tables in the current database, optionally filtered by pattern. `.schema` displays the CREATE statements for tables and indexes, showing the database structure. `.schema tablename` shows the schema for a specific table.

`.mode` changes the output format. Available modes include csv, column, html, insert, json, line, list, quote, and tabs. The column mode displays results in aligned columns. The csv mode produces comma-separated values suitable for spreadsheet import. The json mode outputs results as JSON arrays.

`.headers on` or `.headers off` controls whether column names appear in query results. `.separator` changes the delimiter for list and csv modes. `.width` sets column widths for column mode output.

`.import FILE TABLE` reads data from a CSV file into a table. `.output FILE` redirects subsequent query output to a file instead of the screen. `.output stdout` returns output to the terminal. `.once FILE` redirects only the next query's output to a file.

`.dump` generates SQL statements that recreate the entire database. `.dump tablename` dumps only a specific table. This creates a backup in SQL format that can be restored by piping it back to sqlite3. `.backup FILE` creates a binary backup of the database to a file.

`.read FILE` executes SQL statements from a file. This is useful for running scripts or restoring database dumps. `.open FILE` closes the current database and opens a different one.

`.exit` or `.quit` terminates the shell session. Ctrl+D also exits on Unix-like systems.

**Configuration:**

The shell reads commands from a .sqliterc file in the user's home directory at startup. This file can contain dot commands to customize the shell environment. Common customizations include setting output mode, enabling headers, and adjusting column widths.

**Performance analysis:**

`.timer on` displays execution time for each SQL statement, useful for performance analysis. `.explain` changes the output mode to display VDBE bytecode instructions. `.eqp on` shows query execution plans before displaying results.

## Database Files and Storage Format

SQLite stores an entire database in a single ordinary disk file. This design choice provides numerous advantages including simplicity of backup, ease of transfer between systems, and straightforward database management.

**File structure:**

The SQLite database file is organized into fixed-size pages. The default page size is 4096 bytes, though values from 512 to 65536 bytes are supported (must be powers of 2). The page size is set when the database is created and cannot be changed afterward without recreating the database, though the VACUUM INTO command can create a copy with a different page size.

The first 100 bytes of the database file comprise the database header. This header contains critical information including a magic header string that identifies the file as an SQLite database, the database page size, file format version numbers, the database size in pages, and various flags controlling database behavior.

Following the header, the remainder of the file consists entirely of fixed-size pages. The first page contains both the database header and the root page of the schema table. Pages are typed according to their function: b-tree interior pages, b-tree leaf pages, freelist pages, overflow pages, and pointer map pages.

**B-tree organization:**

SQLite uses B-tree data structures to organize both tables and indexes. Each table has its own B-tree with integer row IDs (rowid) as keys. The actual data is stored in the leaf pages of this B-tree. Tables without an explicit INTEGER PRIMARY KEY receive an automatically generated rowid.

Indexes are also implemented as B-trees, with the indexed column values as keys and the corresponding rowid values as data. This allows SQLite to quickly locate rows based on indexed columns.

**Storage of data types:**

SQLite uses a dynamic type system. Rather than declaring column types strictly, SQLite uses storage classes: NULL, INTEGER (1, 2, 3, 4, 6, or 8 bytes depending on value), REAL (8-byte IEEE floating point), TEXT (UTF-8, UTF-16BE, or UTF-16LE), and BLOB (stored exactly as input).

Text and BLOB values are stored inline if they fit within the B-tree page. If a value is too large, SQLite chains it across multiple overflow pages. Large values are broken into chunks distributed across overflow pages linked together.

**Journal files and transactions:**

During transactions, SQLite creates temporary journal files. The rollback journal (database-journal) preserves the original content of modified pages, enabling recovery if a transaction is rolled back or interrupted. Write-ahead logging (WAL mode) creates a separate WAL file (database-wal) that records changes without modifying the original database file immediately.

The rollback journal provides atomicity and durability. Before modifying any page, SQLite writes the original page content to the journal. If the transaction commits, the journal is deleted. If the transaction rolls back or the system crashes, SQLite uses the journal to restore the database to its previous state.

WAL mode provides better concurrency. Writes append to the WAL file while reads access the original database file. Readers and writers don't block each other. Periodically, changes from the WAL file are transferred back to the main database file through a checkpoint operation.

**Locking and concurrency:**

SQLite implements file-level locking to manage concurrent access. Five lock states exist: UNLOCKED (no locks held), SHARED (reading allowed, writing blocked), RESERVED (intent to write, others can read), PENDING (waiting for readers to finish), and EXCLUSIVE (reading and writing blocked for others).

Multiple processes can hold SHARED locks simultaneously, allowing concurrent reads. Only one process can hold a RESERVED, PENDING, or EXCLUSIVE lock. This locking protocol ensures ACID properties but limits write concurrency - only one writer can modify the database at a time.

WAL mode improves concurrency by allowing one writer and multiple readers to operate simultaneously. Readers access database snapshots while the writer appends to the WAL file.

**File format stability:**

The SQLite file format is extraordinarily stable. The developers guarantee that database files created by SQLite 3.0.0 (2004) remain readable and writable by all future versions of SQLite 3. The file format is fully documented and intended to remain compatible through at least 2050. This stability makes SQLite suitable for long-term data storage and archival purposes.

## SQLite vs Other Database Systems

SQLite occupies a unique position in the database ecosystem. Understanding how it compares to other database systems helps identify when SQLite is the appropriate choice.

**SQLite vs client-server databases (PostgreSQL, MySQL, SQL Server):**

The fundamental architectural difference is that SQLite is serverless. Traditional databases operate as separate server processes that clients connect to over a network or local socket. SQLite is a library that applications link against, reading and writing database files directly.

This serverless architecture eliminates network latency and the overhead of inter-process communication. SQLite queries execute faster for simple operations since there's no client-server handshake. However, client-server databases excel at handling multiple concurrent writers across different machines.

SQLite implements a simpler concurrency model. Only one process can write to a SQLite database at a time (though WAL mode allows concurrent reads during writes). PostgreSQL and MySQL support multiple simultaneous writers through row-level locking and multi-version concurrency control (MVCC). For applications with many concurrent write operations, client-server databases provide better throughput.

Configuration requirements differ drastically. Client-server databases require installation, configuration, user management, backup strategies, and ongoing maintenance. SQLite requires none of this - the entire database is a single file with no configuration files, no server processes to monitor, and no user accounts to manage.

Resource usage varies significantly. Client-server databases consume substantial memory and CPU resources even when idle because they maintain persistent server processes. SQLite consumes no resources when not in use. The library loads only when the application needs it and uses minimal memory.

Data integrity guarantees are equally strong. Both SQLite and major client-server databases provide full ACID compliance. SQLite's transaction mechanism ensures atomicity and durability even during power failures or system crashes.

Query capabilities differ in sophistication. PostgreSQL and MySQL support advanced features like stored procedures, triggers with full procedural logic, complex user-defined functions, and sophisticated query optimization. SQLite provides basic trigger support and limited functions but lacks stored procedures and many advanced SQL features.

**SQLite vs embedded databases (Berkeley DB, LevelDB):**

Berkeley DB and LevelDB are key-value stores, not relational databases. They don't support SQL, tables, or relationships. Applications must handle data organization and querying logic themselves. SQLite provides full SQL support with tables, indexes, joins, and complex queries.

Berkeley DB offers higher write performance for key-value operations since it doesn't parse SQL or maintain relational structure. However, SQLite's SQL interface dramatically reduces development time for applications that need relational data organization.

LevelDB excels at sequential writes and range scans. It's optimized for write-heavy workloads. SQLite provides better read performance for complex queries involving multiple tables and indexes.

**SQLite vs NoSQL databases (MongoDB, Redis):**

MongoDB and Redis follow different data models. MongoDB uses document storage with JSON-like documents. Redis is an in-memory data structure store. SQLite adheres to the relational model with tables and rows.

For applications that need relational data with foreign keys and complex queries joining multiple tables, SQLite's SQL interface provides significant advantages. NoSQL databases require application code to maintain relationships and often denormalize data.

Redis operates entirely in memory, providing extremely fast operations but limited by available RAM. MongoDB can handle larger datasets but requires a running server process. SQLite balances these extremes with disk-based storage and zero server overhead.

**SQLite vs file formats (CSV, JSON, XML):**

Many applications use CSV, JSON, or XML files for data storage. SQLite offers substantial advantages for structured data. Querying JSON or CSV files requires loading the entire file into memory and parsing it. SQLite allows indexed queries that read only the necessary data.

Concurrent access to CSV or JSON files is problematic. Multiple processes modifying these files risk corruption. SQLite provides proper locking and transaction support.

SQLite files are often smaller than equivalent JSON representations since they use binary storage and don't repeat field names for each record. CSV files may be smaller for simple tabular data but lack type information and structure.

## Use Cases and Limitations

SQLite excels in specific scenarios while being unsuitable for others. Understanding these boundaries helps architects make informed decisions.

**Ideal use cases:**

Embedded applications represent SQLite's primary domain. Mobile apps on iOS and Android universally use SQLite for local data storage. Desktop applications use SQLite for preferences, caches, and application data. Web browsers use SQLite extensively - Firefox and Chrome store bookmarks, history, cookies, and cache metadata in SQLite databases.

IoT and edge devices benefit from SQLite's minimal resource footprint. Sensors, industrial equipment, and embedded systems use SQLite to collect and store data locally before transmission to central servers. The zero-configuration requirement is crucial when deploying thousands of devices.

Development and testing environments leverage SQLite's simplicity. Developers can create test databases instantly without setting up database servers. Test suites run faster since they don't wait for network communication. Each test can use a fresh in-memory database that disappears when the test completes.

Data analysis and scientific computing use SQLite as an application file format. Researchers distribute datasets as SQLite databases rather than CSV files. Recipients can immediately query the data using SQL without writing parsing code. The single-file format simplifies data sharing and archival.

Configuration and small data stores are perfect for SQLite. Applications that need structured storage for settings, logs, or cached data avoid the complexity of setting up a database server. The database file can reside in the application directory without special permissions or administrative setup.

Internal/temporary databases serve as intermediate storage during complex operations. Applications can create SQLite databases to sort large datasets, deduplicate records, or perform multi-step transformations that would be difficult with in-memory data structures.

**Appropriate scale:**

SQLite handles databases up to 281 terabytes in theory, though practical limits are lower. Databases in the hundreds of gigabytes work well if queries are indexed appropriately. The single-file design means the filesystem must support large files.

Read-heavy workloads scale excellently. Multiple processes can read simultaneously without interference. A single SQLite database can serve thousands of concurrent readers efficiently.

Write throughput becomes the limiting factor. Without WAL mode, writes are serialized and can create a bottleneck. With WAL mode, one writer can operate while readers continue, but applications needing multiple concurrent writers should consider client-server databases.

**Limitations and antipatterns:**

High-concurrency write workloads don't fit SQLite's design. Applications with many simultaneous writers across multiple machines should use PostgreSQL, MySQL, or other client-server databases. The file-level locking means writes serialize, creating contention.

Client-server applications generally shouldn't use SQLite. If the database and application run on separate machines, SQLite is inappropriate. Network filesystems (NFS, SMB) introduce locking problems and corruption risks. [Inference: SQLite's documentation explicitly warns against using it on network filesystems due to locking mechanism incompatibilities.]

Large enterprise applications with complex access control requirements exceed SQLite's capabilities. SQLite has minimal user management - all database access depends on file system permissions. PostgreSQL and MySQL provide sophisticated role-based access control, audit logging, and security features.

Applications requiring advanced SQL features may find SQLite limiting. Features not supported include RIGHT and FULL OUTER JOIN, stored procedures, user-defined aggregate functions in some contexts, and various PostgreSQL or MySQL-specific extensions.

Very high write throughput applications need different solutions. While SQLite handles typical application write loads easily, applications inserting millions of rows per second should consider specialized databases or streaming platforms.

**Key points:**

SQLite is a library, not a server. This architectural choice defines its strengths (simplicity, zero configuration, embedded use) and limitations (write concurrency, networked access). The entire database exists as a single cross-platform file that provides ACID transactions with minimal overhead. It's ideally suited for embedded systems, mobile apps, desktop software, development environments, and any application needing local structured storage without administrative burden. Applications requiring multiple concurrent writers, networked database access, or enterprise-scale user management should use client-server databases instead.

**Related topics to explore:**

WAL (Write-Ahead Logging) mode and its performance implications, SQLite's full-text search capabilities (FTS5), backup strategies and best practices, optimizing SQLite performance through proper indexing and query design, SQLite extensions and loadable modules, using SQLite with various programming languages (Python, Java, C/C++, JavaScript), migration strategies between SQLite and client-server databases.

---

# Database Creation and Management in SQLite

## Creating Databases

SQLite databases are created automatically when you attempt to connect to a database file that doesn't exist. Unlike traditional database management systems, SQLite doesn't require a separate server process or explicit CREATE DATABASE command.

**Key points:**

- A database is simply a single file on disk with a `.db`, `.sqlite`, `.sqlite3`, or any custom extension
- The file is created when you first connect to it using SQLite's API or command-line interface
- If you connect to an existing file, SQLite opens it; if the file doesn't exist, SQLite creates it
- An in-memory database can be created using the special filename `:memory:` which exists only in RAM and is destroyed when the connection closes
- Temporary databases can be created using an empty string `""` as the filename

**Example:**

```python
import sqlite3

# Creates a new database file or opens existing one
conn = sqlite3.connect('mydatabase.db')

# Creates an in-memory database
memory_conn = sqlite3.connect(':memory:')

# Creates a temporary database
temp_conn = sqlite3.connect('')
```

## Database Connection and Disconnection

Connection management is fundamental to working with SQLite databases. Proper connection handling ensures data integrity and resource cleanup.

**Key points:**

- Connections are established using language-specific APIs (sqlite3 module in Python, sqlite3 gem in Ruby, etc.)
- Multiple connections to the same database file are supported with appropriate locking mechanisms
- SQLite uses file-level locking to handle concurrent access
- Connections should always be properly closed to ensure pending transactions are committed and resources are released
- Connection pooling is less critical for SQLite than for client-server databases, but can still improve performance in multi-threaded applications
- Shared cache mode can be enabled to allow multiple connections to share the same page cache
- WAL (Write-Ahead Logging) mode improves concurrency by allowing readers to access the database while a writer is writing

**Example:**

```python
import sqlite3

# Opening a connection
conn = sqlite3.connect('example.db')

# Creating a cursor for executing SQL
cursor = conn.cursor()

# Executing queries
cursor.execute('CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)')

# Committing changes
conn.commit()

# Closing the connection
conn.close()

# Using context manager (automatically handles closing)
with sqlite3.connect('example.db') as conn:
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM users')
```

## Database Metadata and Information Schema

SQLite provides special tables and PRAGMA commands to query database metadata and schema information.

**Key points:**

- The `sqlite_master` table (or `sqlite_schema` in newer versions) contains schema information for all database objects
- Each database has its own `sqlite_master` table storing CREATE statements for tables, indexes, triggers, and views
- The `sqlite_temp_master` table contains schema information for temporary objects
- PRAGMA commands provide access to various database settings and metadata
- The `table_info` pragma returns column information for a specific table
- The `database_list` pragma shows all attached databases
- The `sqlite_stat1` and `sqlite_stat4` tables store index statistics used by the query optimizer

**Example:**

```sql
-- Query all tables in the database
SELECT name, type, sql FROM sqlite_master WHERE type='table';

-- Get column information for a specific table
PRAGMA table_info(users);

-- List all indexes
SELECT name, tbl_name FROM sqlite_master WHERE type='index';

-- Get database file information
PRAGMA database_list;

-- Get foreign key list for a table
PRAGMA foreign_key_list(orders);

-- Get index information
PRAGMA index_list(users);

-- Get table schema
SELECT sql FROM sqlite_master WHERE name='users';
```

## Database Integrity Checking

SQLite provides built-in mechanisms to verify database integrity and detect corruption.

**Key points:**

- The `PRAGMA integrity_check` command performs a comprehensive integrity check of the entire database
- The `PRAGMA quick_check` performs a faster but less thorough integrity check
- Integrity checks verify B-tree structures, check for orphaned pages, and validate internal consistency
- The `integrity_check` pragma can be limited to specific tables by providing table names as arguments
- Regular integrity checks are recommended, especially after system crashes or storage failures
- The `foreign_key_check` pragma verifies foreign key constraints without checking overall database integrity
- Integrity checks do not repair corruption; they only detect it

**Example:**

```sql
-- Full integrity check (returns 'ok' if no issues found)
PRAGMA integrity_check;

-- Quick integrity check (faster, less thorough)
PRAGMA quick_check;

-- Check integrity of specific tables
PRAGMA integrity_check(users, orders);

-- Check foreign key constraints
PRAGMA foreign_key_check;

-- Check foreign keys for specific table
PRAGMA foreign_key_check(orders);
```

**Output:**

For a healthy database, `integrity_check` returns a single row with the value "ok". If issues are found, it returns descriptive error messages indicating the nature and location of corruption.

## Backup and Restore Operations

SQLite offers multiple methods for backing up and restoring databases, ranging from simple file copying to online backup APIs.

**Key points:**

- The simplest backup method is copying the database file when no connections are active
- The `.backup` command in the SQLite CLI creates a consistent backup even while the database is in use
- The SQLite Backup API allows programmatic online backups without locking the database
- Online backups copy data page-by-page, allowing other connections to continue working
- The VACUUM command can create a compacted copy of the database in a new file
- For databases using WAL mode, both the database file and WAL file should be considered during backup
- The backup API handles transaction consistency automatically
- Incremental backups are not natively supported; each backup is a full copy

**Example:**

```bash
# Using SQLite CLI
sqlite3 original.db ".backup backup.db"

# Restore from backup
sqlite3 restored.db ".restore backup.db"
```

```python
import sqlite3

# Python backup example using backup API
source = sqlite3.connect('original.db')
backup = sqlite3.connect('backup.db')

# Perform the backup
source.backup(backup)

backup.close()
source.close()

# Backup with progress tracking
def progress(status, remaining, total):
    print(f'Copied {total-remaining} of {total} pages...')

source = sqlite3.connect('original.db')
backup = sqlite3.connect('backup.db')
source.backup(backup, pages=10, progress=progress)
```

**Alternative methods:**

```sql
-- Using VACUUM to create a compacted copy
VACUUM INTO 'backup.db';

-- Attach and copy method
ATTACH DATABASE 'backup.db' AS backup;
CREATE TABLE backup.users AS SELECT * FROM main.users;
DETACH DATABASE backup;
```

## Database Encryption (SEE - SQLite Encryption Extension)

[Unverified] SQLite Encryption Extension (SEE) is a commercial extension that provides transparent database encryption. The following information is based on publicly available documentation, but specific implementation details and behavior may vary.

**Key points:**

- SEE is a proprietary, paid extension to SQLite (not included in the free, open-source version)
- SEE provides 256-bit AES encryption for the entire database file
- Encryption and decryption occur transparently at the pager level
- The encryption key must be provided when opening the database connection
- Without the correct key, the database file appears as random data
- Third-party alternatives include SQLCipher (open-source), wxSQLite3, and others
- Encryption adds performance overhead due to encryption/decryption operations
- The database file size remains approximately the same after encryption
- Changing the encryption key requires re-encrypting the entire database

**Example (SEE):**

[Unverified] The exact API may vary by implementation:

```python
# Example pattern - actual implementation depends on the extension used
import sqlite3

# Opening an encrypted database with SEE
conn = sqlite3.connect('encrypted.db')
conn.execute("PRAGMA key='your-encryption-key'")

# Creating a new encrypted database
conn = sqlite3.connect('new_encrypted.db')
conn.execute("PRAGMA key='your-encryption-key'")
conn.execute('CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)')
```

**Example (SQLCipher - open-source alternative):**

```python
from pysqlcipher3 import dbapi2 as sqlite

# Opening encrypted database with SQLCipher
conn = sqlite.connect('encrypted.db')
conn.execute("PRAGMA key='your-passphrase'")

# Re-keying (changing the encryption key)
conn.execute("PRAGMA rekey='new-passphrase'")
```

**Important considerations:**

- Encryption is applied at rest (to the database file); data in memory is unencrypted
- Connection strings or key management must be handled securely in application code
- Performance impact varies based on workload characteristics and hardware
- Encrypted databases cannot be opened or examined without the correct key
- Key loss results in permanent data loss with no recovery option
- Some SQLite tools and utilities may not support encrypted databases

---

**Related topics you may want to explore:** Transaction management and ACID properties, SQLite journal modes (DELETE, WAL, MEMORY), Performance optimization and query planning, Concurrency control and locking mechanisms, Attached databases and cross-database queries

---

# Data Definition Language (DDL) in SQLite

Data Definition Language (DDL) consists of SQL commands used to define, modify, and remove database structures. In SQLite, DDL operations handle the schema of your database—creating tables, defining relationships, setting constraints, and managing the overall structure of your data storage.

## Table Creation and Modification

### Creating Tables

The `CREATE TABLE` statement defines a new table with specified columns and their properties.

**Basic syntax:**

```sql
CREATE TABLE table_name (
    column1 datatype constraints,
    column2 datatype constraints,
    ...
    table_constraints
);
```

**Example:**

```sql
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    hire_date TEXT,
    salary REAL
);
```

### IF NOT EXISTS Clause

Prevents errors when creating tables that might already exist:

```sql
CREATE TABLE IF NOT EXISTS departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL
);
```

### Temporary Tables

Tables that exist only for the duration of the database connection:

```sql
CREATE TEMP TABLE session_data (
    session_id TEXT,
    user_id INTEGER,
    login_time TEXT
);
```

### Modifying Tables with ALTER TABLE

SQLite supports limited `ALTER TABLE` operations compared to other database systems.

**Adding columns:**

```sql
ALTER TABLE employees ADD COLUMN department_id INTEGER;
```

**Renaming tables:**

```sql
ALTER TABLE employees RENAME TO staff;
```

**Renaming columns** (SQLite 3.25.0+):

```sql
ALTER TABLE employees RENAME COLUMN email TO email_address;
```

**Dropping columns** (SQLite 3.35.0+):

```sql
ALTER TABLE employees DROP COLUMN middle_name;
```

[Inference] For SQLite versions before 3.35.0, dropping columns requires recreating the table without the unwanted column, copying data, dropping the old table, and renaming the new table.

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

## Unique Constraints and Check Constraints

### Unique Constraints

Ensures all values in a column or combination of columns are distinct.

**Column-level unique:**

```sql
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    username TEXT UNIQUE,
    email TEXT UNIQUE
);
```

**Table-level unique (composite):**

```sql
CREATE TABLE enrollments (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date TEXT,
    UNIQUE(student_id, course_id)
);
```

**Named unique constraint:**

```sql
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    sku TEXT,
    CONSTRAINT unique_sku UNIQUE(sku)
);
```

### Check Constraints

Validates data based on a boolean expression.

**Column-level check:**

```sql
CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    age INTEGER CHECK(age >= 18 AND age <= 100),
    salary REAL CHECK(salary > 0)
);
```

**Table-level check:**

```sql
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    cost_price REAL,
    selling_price REAL,
    CHECK(selling_price >= cost_price)
);
```

**Named check constraint:**

```sql
CREATE TABLE accounts (
    account_id INTEGER PRIMARY KEY,
    balance REAL,
    CONSTRAINT positive_balance CHECK(balance >= 0)
);
```

**Complex check with multiple conditions:**

```sql
CREATE TABLE appointments (
    appointment_id INTEGER PRIMARY KEY,
    start_time TEXT,
    end_time TEXT,
    status TEXT,
    CHECK(status IN ('scheduled', 'completed', 'cancelled')),
    CHECK(end_time > start_time)
);
```

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

# Basic SQL Operations (DML)

## INSERT Statements and Variations in SQLite

---

### Basic Syntax

The `INSERT` statement adds one or more rows to a table.

```sql
INSERT INTO table_name (column1, column2, column3)
VALUES (value1, value2, value3);
```

**Key Points:**

- Column list is optional if you supply values for _all_ columns in defined order
- Omitting a column uses its `DEFAULT` value or `NULL` if none is defined
- SQLite is dynamically typed; column affinity applies but is not strictly enforced

**Example:**

```sql
CREATE TABLE employees (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name    TEXT NOT NULL,
    dept    TEXT,
    salary  REAL DEFAULT 0.0
);

INSERT INTO employees (name, dept, salary)
VALUES ('Alice', 'Engineering', 95000.00);
```

---

### Omitting the Column List

```sql
INSERT INTO employees
VALUES (NULL, 'Bob', 'Marketing', 72000.00);
```

**Key Points:**

- `NULL` is passed for the `id` column so `AUTOINCREMENT` can assign the next value
- Column order must exactly match the table's defined schema
- Generally considered fragile — schema changes can silently break this form

---

### Multi-Row INSERT

SQLite supports inserting multiple rows in a single statement (since SQLite 3.7.11).

```sql
INSERT INTO employees (name, dept, salary)
VALUES
    ('Carol', 'Design',      68000.00),
    ('David', 'Engineering', 101000.00),
    ('Eve',   'HR',          61000.00);
```

**Key Points:**

- Reduces round-trips compared to individual inserts
- All rows are inserted atomically within the statement
- [Inference] Likely more efficient than looped single-row inserts for bulk data, though actual performance depends on transaction context and hardware

---

### INSERT OR REPLACE

Attempts an insert; if a `UNIQUE` or `PRIMARY KEY` constraint is violated, the conflicting row is **deleted** and re-inserted.

```sql
INSERT OR REPLACE INTO employees (id, name, dept, salary)
VALUES (1, 'Alice', 'Engineering', 99000.00);
```

**Key Points:**

- The old row is fully removed, then a new row is written — this means the `rowid` changes
- Any columns not supplied receive their default values, not the old row's values
- Triggers for `DELETE` and `INSERT` may fire; `UPDATE` triggers do **not**
- Behavior may vary depending on trigger configuration — test in your environment

---

### INSERT OR IGNORE

Skips the insert silently if a constraint violation would occur.

```sql
INSERT OR IGNORE INTO employees (id, name, dept, salary)
VALUES (1, 'Alice', 'Engineering', 99000.00);
```

**Key Points:**

- No error is raised; the conflicting row is left untouched
- Useful for idempotent seed scripts or deduplication scenarios
- Does **not** update the existing row — if an update is needed, use `INSERT OR REPLACE` or `UPSERT`

---

### INSERT OR FAIL

Raises an error and aborts the current statement if a constraint is violated, but does **not** roll back any prior changes in the same transaction.

```sql
INSERT OR FAIL INTO employees (name, dept, salary)
VALUES ('Frank', 'Legal', 85000.00);
```

---

### INSERT OR ABORT _(default behavior)_

Aborts the current statement and rolls back changes made by that statement only. This is the default conflict resolution strategy.

```sql
INSERT OR ABORT INTO employees (name, dept, salary)
VALUES ('Grace', 'Finance', 79000.00);
```

---

### INSERT OR ROLLBACK

Aborts the current statement **and** rolls back the entire current transaction on conflict.

```sql
BEGIN;
INSERT OR ROLLBACK INTO employees (name, dept, salary)
VALUES ('Hank', 'Operations', 67000.00);
COMMIT;
```

**Key Points:**

- Strongest conflict response among the `OR` variants
- Useful when partial transaction state is considered invalid

---

### Conflict Resolution Summary Table

|Variant|On Conflict: Aborts Statement|Rolls Back Transaction|Existing Row Affected|
|---|---|---|---|
|`OR ABORT` _(default)_|✅|❌|Untouched|
|`OR FAIL`|✅|❌|Untouched|
|`OR IGNORE`|❌ (skips)|❌|Untouched|
|`OR REPLACE`|✅ (deletes + re-inserts)|❌|Deleted|
|`OR ROLLBACK`|✅|✅|Untouched|

---

### INSERT INTO ... SELECT

Inserts rows derived from a query result.

```sql
INSERT INTO employees (name, dept, salary)
SELECT name, dept, salary
FROM contractors
WHERE contract_end < DATE('now');
```

**Key Points:**

- Column count and compatible types must align between `SELECT` output and target table
- The `SELECT` can include joins, subqueries, filters, and expressions
- No `VALUES` clause is used with this form

**Example — copying a table:**

```sql
INSERT INTO employees_backup
SELECT * FROM employees;
```

---

### UPSERT (INSERT ... ON CONFLICT)

Introduced in SQLite 3.24.0. Allows conditional update logic when a conflict occurs, without deleting the existing row.

```sql
INSERT INTO employees (id, name, dept, salary)
VALUES (1, 'Alice', 'Engineering', 99000.00)
ON CONFLICT(id) DO UPDATE SET
    salary = excluded.salary,
    dept   = excluded.dept;
```

**Key Points:**

- `excluded` refers to the row that _would have been_ inserted
- The existing row's `rowid` is preserved (unlike `OR REPLACE`)
- `UPDATE` triggers fire instead of `DELETE`/`INSERT` triggers
- You may add a `WHERE` clause to the `DO UPDATE` to conditionally apply the update:

```sql
ON CONFLICT(id) DO UPDATE SET
    salary = excluded.salary
WHERE excluded.salary > employees.salary;
```

- To explicitly do nothing on conflict:

```sql
ON CONFLICT(id) DO NOTHING;
```

---

### INSERT with DEFAULT VALUES

Inserts a single row using all column defaults.

```sql
INSERT INTO employees DEFAULT VALUES;
```

**Key Points:**

- Every column must have a `DEFAULT` defined, or be nullable — otherwise an error occurs
- Rarely used in practice but valid syntax

---

### INSERT with a WITH Clause (CTE)

A Common Table Expression can precede an `INSERT ... SELECT`.

```sql
WITH high_earners AS (
    SELECT name, dept, salary
    FROM contractors
    WHERE salary > 90000.00
)
INSERT INTO employees (name, dept, salary)
SELECT name, dept, salary
FROM high_earners;
```

**Key Points:**

- CTE is evaluated first, then the result is fed to the `INSERT`
- Multiple CTEs can be chained with commas

---

### Retrieving the Last Inserted Row ID

```sql
INSERT INTO employees (name, dept, salary)
VALUES ('Ivan', 'IT', 74000.00);

SELECT last_insert_rowid();
```

**Key Points:**

- `last_insert_rowid()` returns the `rowid` of the most recent successful insert in the current connection
- Behavior is connection-scoped, not global — [Inference] concurrent connections should not interfere, but this depends on your application's connection management
- Returns `0` if no insert has occurred in the session

---

### Performance Considerations

**Key Points:**

- Wrapping many inserts in an explicit `BEGIN ... COMMIT` transaction significantly reduces I/O overhead — [Inference] each auto-committed insert writes to disk individually, which can be orders of magnitude slower for bulk loads (behavior may vary by OS and storage)
- `PRAGMA journal_mode = WAL;` may improve concurrent write throughput — verify in your environment
- `PRAGMA synchronous = NORMAL;` or `OFF` can reduce fsync calls at the cost of durability guarantees — use with caution

**Example — bulk insert with transaction:**

```sql
BEGIN;
INSERT INTO employees (name, dept, salary) VALUES ('J1', 'Dept', 50000);
INSERT INTO employees (name, dept, salary) VALUES ('J2', 'Dept', 51000);
-- ... more rows
COMMIT;
```

---

**Conclusion:** SQLite's `INSERT` covers a wide range of use cases — from basic single-row inserts to conflict-aware upserts and bulk `SELECT`-driven loads. Choosing the right variation depends on your conflict handling needs, whether row identity must be preserved, and performance requirements. Always verify behavior in your specific SQLite version, as features like `UPSERT` have minimum version requirements.

---

## SELECT Statements and Basic Queries in SQLite

---

### Basic Syntax

The `SELECT` statement retrieves rows from one or more tables.

```sql
SELECT column1, column2
FROM table_name;
```

**Key Points:**

- `SELECT` does not modify data
- Column list can be explicit or use `*` to return all columns
- SQLite processes clauses in a defined logical order (covered below)

---

### Selecting All Columns

```sql
SELECT * FROM employees;
```

**Key Points:**

- Returns every column in the table's defined order
- Generally discouraged in production code — schema changes silently alter result shape
- Acceptable for exploration and quick debugging

---

### Selecting Specific Columns

```sql
SELECT name, dept, salary
FROM employees;
```

**Key Points:**

- Only the listed columns are returned
- Column order in the result follows the order listed in the query, not the table schema

---

### Column Aliases

Rename a column in the result set using `AS`.

```sql
SELECT name AS employee_name, salary AS annual_salary
FROM employees;
```

**Key Points:**

- `AS` is optional — `name employee_name` is valid but less readable
- Aliases can be used in `ORDER BY` but **not** in `WHERE` (SQLite processes `WHERE` before alias resolution)
- Aliases defined in `SELECT` are available in `ORDER BY` and `HAVING`

---

### Expressions in SELECT

You can compute values directly in the column list.

```sql
SELECT
    name,
    salary,
    salary * 0.10        AS bonus,
    salary + salary * 0.10 AS total_compensation
FROM employees;
```

**Key Points:**

- Arithmetic operators: `+`, `-`, `*`, `/`, `%`
- String concatenation uses `||`
- Expression results are not stored — they are computed per query

**Example — string expression:**

```sql
SELECT name || ' (' || dept || ')' AS label
FROM employees;
```

**Output:**

```
Alice (Engineering)
Bob (Marketing)
```

---

### DISTINCT

Removes duplicate rows from the result.

```sql
SELECT DISTINCT dept
FROM employees;
```

**Key Points:**

- `DISTINCT` applies to the entire row, not a single column
- When multiple columns are selected, uniqueness is evaluated across the combination
- [Inference] May involve a sort or hash operation internally — can be slower on large, unindexed datasets

```sql
SELECT DISTINCT dept, salary
FROM employees;
-- Returns unique (dept, salary) pairs, not unique depts alone
```

---

### WHERE Clause

Filters rows based on a condition.

```sql
SELECT name, salary
FROM employees
WHERE dept = 'Engineering';
```

#### Comparison Operators

|Operator|Meaning|
|---|---|
|`=`|Equal|
|`!=` or `<>`|Not equal|
|`<`, `>`|Less / greater than|
|`<=`, `>=`|Less / greater than or equal|

#### Logical Operators

```sql
-- AND
SELECT name FROM employees
WHERE dept = 'Engineering' AND salary > 90000;

-- OR
SELECT name FROM employees
WHERE dept = 'Engineering' OR dept = 'Design';

-- NOT
SELECT name FROM employees
WHERE NOT dept = 'HR';
```

**Key Points:**

- `AND` has higher precedence than `OR` — use parentheses to clarify complex conditions
- SQLite evaluates `WHERE` before `SELECT` expressions

---

### NULL Handling in WHERE

`NULL` comparisons require `IS NULL` or `IS NOT NULL`.

```sql
SELECT name FROM employees WHERE dept IS NULL;
SELECT name FROM employees WHERE dept IS NOT NULL;
```

**Key Points:**

- `WHERE dept = NULL` does **not** work as expected — it always evaluates to false in SQL
- `NULL` is not equal to anything, including itself
- This is standard SQL behavior, not SQLite-specific

---

### BETWEEN

Tests whether a value falls within an inclusive range.

```sql
SELECT name, salary
FROM employees
WHERE salary BETWEEN 60000 AND 90000;
```

**Key Points:**

- Equivalent to `salary >= 60000 AND salary <= 90000`
- Works with numbers, text (lexicographic), and dates stored as text in ISO format

---

### IN and NOT IN

Tests membership in a value list.

```sql
SELECT name FROM employees
WHERE dept IN ('Engineering', 'Design', 'IT');

SELECT name FROM employees
WHERE dept NOT IN ('HR', 'Marketing');
```

**Key Points:**

- `IN` can also accept a subquery (covered in subquery topics)
- `NOT IN` with a list containing `NULL` may produce unexpected results — [Inference] if any value in the list is `NULL`, `NOT IN` can return no rows; always filter `NULL` from `NOT IN` lists when this is a concern
- Behavior may vary depending on data — test with your actual dataset

---

### LIKE

Pattern matching on text values.

|Wildcard|Meaning|
|---|---|
|`%`|Zero or more characters|
|`_`|Exactly one character|

```sql
-- Names starting with 'A'
SELECT name FROM employees WHERE name LIKE 'A%';

-- Names ending with 'e'
SELECT name FROM employees WHERE name LIKE '%e';

-- Names with exactly 3 characters
SELECT name FROM employees WHERE name LIKE '___';

-- Names containing 'ar'
SELECT name FROM employees WHERE name LIKE '%ar%';
```

**Key Points:**

- Case-insensitive by default for ASCII characters in SQLite
- Case sensitivity for Unicode characters depends on the build and any loaded ICU extension — [Unverified] behavior for non-ASCII `LIKE` comparisons should be tested in your environment
- `ESCAPE` clause defines a custom escape character for literal `%` or `_`:

```sql
SELECT * FROM files WHERE path LIKE '50\% done%' ESCAPE '\';
```

---

### GLOB

Similar to `LIKE` but uses Unix-style wildcards and is case-sensitive.

|Wildcard|Meaning|
|---|---|
|`*`|Zero or more characters|
|`?`|Exactly one character|
|`[abc]`|Character class|

```sql
SELECT name FROM employees WHERE name GLOB 'A*';
SELECT name FROM employees WHERE name GLOB '[ABC]*';
```

**Key Points:**

- Always case-sensitive, unlike `LIKE`
- Not part of standard SQL — SQLite-specific

---

### ORDER BY

Sorts the result set.

```sql
SELECT name, salary
FROM employees
ORDER BY salary DESC;
```

```sql
-- Multiple columns
SELECT name, dept, salary
FROM employees
ORDER BY dept ASC, salary DESC;
```

**Key Points:**

- `ASC` is the default and can be omitted
- `NULL` values sort **before** non-null values in `ASC` order and **after** in `DESC` order in SQLite — [Inference] this differs from some other databases; verify if portability matters
- You can order by column position: `ORDER BY 2 DESC` (refers to second column in `SELECT`) — valid but fragile

---

### LIMIT and OFFSET

Controls how many rows are returned.

```sql
-- First 5 rows
SELECT name, salary FROM employees
ORDER BY salary DESC
LIMIT 5;

-- Rows 6–10 (skip first 5)
SELECT name, salary FROM employees
ORDER BY salary DESC
LIMIT 5 OFFSET 5;
```

**Key Points:**

- `LIMIT` without `ORDER BY` returns an arbitrary subset — row order is not guaranteed without explicit sorting
- `OFFSET` is zero-based
- SQLite also supports the shorthand `LIMIT offset, count` (comma syntax) though the `OFFSET` keyword form is clearer
- [Inference] Large `OFFSET` values on big tables can be slow since SQLite scans and discards rows up to the offset — keyset pagination may be preferable for performance

---

### Logical Processing Order

SQLite (and SQL generally) processes clauses in this logical order, regardless of written order:

```
1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT  (expressions, aliases resolved here)
6. DISTINCT
7. ORDER BY
8. LIMIT / OFFSET
```

**Key Points:**

- This explains why `WHERE` cannot reference `SELECT` aliases — aliases don't exist yet at that stage
- `HAVING` can reference aliases defined in `SELECT` in SQLite — [Inference] this is a SQLite-specific extension to standard behavior and may not be portable

---

### SELECT Without a Table

SQLite allows `SELECT` without a `FROM` clause, useful for evaluating expressions.

```sql
SELECT 1 + 1;
SELECT UPPER('hello');
SELECT DATE('now');
SELECT SQLITE_VERSION();
```

**Output:**

```
2
HELLO
2026-05-23
3.x.x
```

---

### Combining Conditions — Practical Example

```sql
SELECT name, dept, salary
FROM employees
WHERE dept IN ('Engineering', 'IT')
  AND salary BETWEEN 70000 AND 110000
  AND name LIKE 'A%'
ORDER BY salary DESC
LIMIT 10;
```

---

### CASE Expression in SELECT

Conditional logic within a query.

```sql
SELECT
    name,
    salary,
    CASE
        WHEN salary >= 90000 THEN 'Senior'
        WHEN salary >= 70000 THEN 'Mid'
        ELSE 'Junior'
    END AS level
FROM employees;
```

**Key Points:**

- `CASE` is an expression, not a statement — it returns a value
- Can be used anywhere an expression is valid: `SELECT`, `WHERE`, `ORDER BY`
- Evaluated top-to-bottom; first matching `WHEN` wins

---

### TYPEOF and Type Introspection

Useful for debugging SQLite's dynamic typing.

```sql
SELECT name, TYPEOF(salary), TYPEOF(name)
FROM employees;
```

**Output:**

```
Alice | real | text
Bob   | real | text
```

**Key Points:**

- Returns the storage class: `null`, `integer`, `real`, `text`, `blob`
- Reflects the actual stored value type, not the declared column affinity

---

**Conclusion:** The `SELECT` statement is the foundation of all data retrieval in SQLite. Core variations — filtering with `WHERE`, sorting with `ORDER BY`, limiting with `LIMIT`, and pattern matching with `LIKE` or `GLOB` — cover most practical querying needs. Understanding logical processing order helps avoid common errors with aliases and filtering. Behavior for edge cases like `NULL` comparisons and Unicode `LIKE` should be verified in your target environment.

**Next Steps:**

- Aggregate functions and `GROUP BY`
- Joins (`INNER`, `LEFT`, `CROSS`)
- Subqueries and CTEs
- Full-text search with FTS5

---

## UPDATE Operations in SQLite

---

### Basic Syntax

The `UPDATE` statement modifies existing rows in a table.

```sql
UPDATE table_name
SET column1 = value1, column2 = value2
WHERE condition;
```

**Key Points:**

- `SET` accepts one or more column assignments, comma-separated
- `WHERE` is optional but omitting it updates **every row** in the table
- SQLite processes the `WHERE` filter before applying `SET` assignments
- No rows are added or removed — only existing row values change

---

### Single Column Update

```sql
UPDATE employees
SET salary = 105000.00
WHERE id = 1;
```

---

### Multiple Column Update

```sql
UPDATE employees
SET salary = 105000.00,
    dept   = 'Senior Engineering'
WHERE id = 1;
```

**Key Points:**

- All assignments in a single `SET` clause are applied atomically to each matching row
- Column order in `SET` does not matter
- [Inference] Assignments do not chain within the same `SET` — each right-hand side expression is evaluated using the row's _original_ values before any updates in that statement take effect; behavior should be tested in your environment

---

### Updating All Rows

Omitting `WHERE` applies the change to every row.

```sql
UPDATE employees
SET salary = salary * 1.05;
```

**Key Points:**

- This is valid and intentional in some cases (e.g., applying a universal raise)
- There is no confirmation prompt — execute with care
- [Inference] Wrapping in a transaction allows rollback if the result is not as intended

---

### UPDATE with Expressions

The right-hand side of `SET` can be any valid expression.

```sql
-- Percentage increase
UPDATE employees
SET salary = salary * 1.10
WHERE dept = 'Engineering';

-- String update with concatenation
UPDATE employees
SET name = name || ' (Contractor)'
WHERE dept = 'IT';

-- Conditional assignment using CASE
UPDATE employees
SET salary = CASE
    WHEN dept = 'Engineering' THEN salary * 1.10
    WHEN dept = 'Design'      THEN salary * 1.07
    ELSE                           salary * 1.03
END;
```

**Key Points:**

- Expressions can reference the column being updated (e.g., `salary = salary * 1.1`)
- `CASE` in `SET` allows row-by-row conditional logic without multiple statements
- String, numeric, and date functions are all valid in `SET` expressions

---

### UPDATE with WHERE and Multiple Conditions

```sql
UPDATE employees
SET salary = 95000.00
WHERE dept = 'Marketing'
  AND salary < 80000.00;
```

```sql
UPDATE employees
SET dept = 'General'
WHERE dept IS NULL;
```

**Key Points:**

- All `WHERE` clauses from `SELECT` apply here: `AND`, `OR`, `IN`, `BETWEEN`, `LIKE`, `IS NULL`
- `NULL` assignments require `= NULL` in `SET` (unlike `WHERE`, where you must use `IS NULL`)

**Example — setting a column to NULL:**

```sql
UPDATE employees
SET dept = NULL
WHERE id = 5;
```

---

### UPDATE with RETURNING

Available in SQLite 3.35.0+. Returns data from the rows that were modified.

```sql
UPDATE employees
SET salary = salary * 1.10
WHERE dept = 'Engineering'
RETURNING id, name, salary;
```

**Output:**

```
1 | Alice | 104500.00
4 | David | 111100.00
```

**Key Points:**

- `RETURNING *` returns all columns of the updated rows
- Useful for retrieving new computed values without a follow-up `SELECT`
- Returns the row values **after** the update is applied
- Behavior depends on SQLite version — verify `SQLITE_VERSION()` in your environment

---

### UPDATE with Subquery in SET

A subquery can supply the new value for a column.

```sql
UPDATE employees
SET salary = (
    SELECT AVG(salary)
    FROM employees
    WHERE dept = 'Engineering'
)
WHERE dept = 'Engineering'
  AND salary < 70000.00;
```

**Key Points:**

- The subquery must return a single value (scalar subquery)
- If the subquery returns no rows, the column is set to `NULL`
- [Inference] The subquery is evaluated once per updated row in SQLite's default behavior — test with your data to confirm expected results

---

### UPDATE with Subquery in WHERE

Filter rows to update based on a subquery result.

```sql
UPDATE employees
SET salary = salary * 1.05
WHERE id IN (
    SELECT id FROM employees
    WHERE dept = 'Engineering'
      AND salary < (SELECT AVG(salary) FROM employees)
);
```

**Key Points:**

- Subqueries in `WHERE` follow the same rules as in `SELECT` statements
- Correlated subqueries are supported but [Inference] may be slower on large tables without appropriate indexes — verify with `EXPLAIN QUERY PLAN`

---

### UPDATE with JOIN (via Subquery)

SQLite does not support `UPDATE ... JOIN` syntax directly. Joins are expressed using subqueries or the `FROM` clause (added in SQLite 3.33.0).

#### Using a Subquery (all versions):

```sql
UPDATE employees
SET salary = salary * 1.08
WHERE id IN (
    SELECT e.id
    FROM employees e
    JOIN departments d ON e.dept = d.name
    WHERE d.budget_tier = 'high'
);
```

#### Using FROM clause (SQLite 3.33.0+):

```sql
UPDATE employees
SET salary = employees.salary * 1.08
FROM departments
WHERE employees.dept = departments.name
  AND departments.budget_tier = 'high';
```

**Key Points:**

- The `FROM` clause form is more readable and closer to PostgreSQL syntax
- Both achieve the same logical result — [Inference] performance may differ depending on indexes and query plan; use `EXPLAIN QUERY PLAN` to compare
- Always qualify column names with table names when using `FROM` to avoid ambiguity

---

### UPDATE with CTE (Common Table Expression)

```sql
WITH engineering_avg AS (
    SELECT AVG(salary) AS avg_sal
    FROM employees
    WHERE dept = 'Engineering'
)
UPDATE employees
SET salary = (SELECT avg_sal FROM engineering_avg)
WHERE dept = 'Engineering'
  AND salary < (SELECT avg_sal FROM engineering_avg);
```

**Key Points:**

- CTEs in `UPDATE` are supported in SQLite 3.35.0+
- The CTE is referenced like a subquery in both `SET` and `WHERE`
- Useful for readability when the same derived value is needed in multiple places

---

### Conflict Resolution in UPDATE

Like `INSERT`, `UPDATE` supports `OR` conflict resolution clauses.

```sql
UPDATE OR IGNORE employees
SET id = 99
WHERE name = 'Alice';

UPDATE OR REPLACE employees
SET id = 99
WHERE name = 'Alice';

UPDATE OR ROLLBACK employees
SET id = 99
WHERE name = 'Alice';
```

| Variant                | On Constraint Violation                                  |
| ---------------------- | -------------------------------------------------------- |
| `OR ABORT` _(default)_ | Rolls back the statement, not the transaction            |
| `OR FAIL`              | Stops at the failing row; prior rows in statement remain |
| `OR IGNORE`            | Skips the conflicting row silently                       |
| `OR REPLACE`           | Deletes the conflicting row, then applies the update     |
| `OR ROLLBACK`          | Rolls back the entire transaction                        |

**Key Points:**

- These mirror the `INSERT OR ...` variants in behavior
- `OR REPLACE` in an `UPDATE` context deletes the _other_ row that conflicts, then proceeds — not the row being updated
- Trigger behavior during conflict resolution may vary — test in your environment

---

### Verifying Updates with changes()

`changes()` returns the number of rows affected by the most recent `INSERT`, `UPDATE`, or `DELETE`.

```sql
UPDATE employees
SET salary = 75000.00
WHERE dept = 'HR';

SELECT changes();
```

**Output:**

```
3
```

**Key Points:**

- Returns `0` if no rows matched the `WHERE` condition
- Scoped to the current database connection
- Does not reflect rows changed by triggers — for that, use `total_changes()`

---

### Safe UPDATE Practices

**Key Points:**

- Always run a `SELECT` with the same `WHERE` clause before executing an `UPDATE` to verify which rows will be affected
- Wrap updates in a transaction to allow rollback:

```sql
BEGIN;

UPDATE employees
SET dept = 'Restructured'
WHERE dept = 'Operations';

-- Verify
SELECT * FROM employees WHERE dept = 'Restructured';

-- If correct:
COMMIT;

-- If not:
-- ROLLBACK;
```

- Use `LIMIT` in `UPDATE` to cap the number of rows affected (requires SQLite compiled with `SQLITE_ENABLE_UPDATE_DELETE_LIMIT`):

```sql
UPDATE employees
SET salary = 80000.00
WHERE dept = 'Marketing'
ORDER BY salary ASC
LIMIT 3;
```

**Key Points on LIMIT in UPDATE:**

- Not available in all SQLite builds — check with `PRAGMA compile_options;`
- `ORDER BY` must accompany `LIMIT` in `UPDATE` to define which rows are selected
- [Unverified] availability depends on compile-time flags; do not assume this is present without verification

---

### Checking for Unintended Full-Table Updates

SQLite does not warn before a full-table update. [Inference] It is good practice to check `WHERE` clause presence before executing in scripts or applications — some database wrappers or ORMs may offer safeguards, but SQLite itself does not.

```sql
-- Dangerous: no WHERE clause
UPDATE employees SET dept = 'Unknown';

-- Safer pattern: always verify row count first
SELECT COUNT(*) FROM employees WHERE dept IS NULL;
UPDATE employees SET dept = 'Unknown' WHERE dept IS NULL;
```

---

**Conclusion:** SQLite's `UPDATE` supports a range of patterns from simple single-column changes to conditional `CASE` expressions, subquery-driven updates, and conflict-aware variants. The `FROM` clause and `RETURNING` clause extend its capabilities in newer versions. For safety, wrapping updates in transactions, verifying row counts beforehand, and using `changes()` to confirm results are recommended practices. Always verify version-dependent features like `RETURNING`, `FROM`, and `LIMIT` against your environment.

**Next Steps:**

- DELETE operations and safe deletion patterns
- Transactions and savepoints
- Triggers (which fire on `UPDATE` events)
- Indexes and their effect on UPDATE performance

---

## DELETE Operations in SQLite

---

### Basic Syntax

The `DELETE` statement removes rows from a table.

```sql
DELETE FROM table_name
WHERE condition;
```

**Key Points:**

- Only rows are removed — the table structure, indexes, and triggers remain intact
- `WHERE` is optional; omitting it removes **every row** in the table
- `DELETE` does not reset `AUTOINCREMENT` counters — the next inserted row continues from the last known max `rowid`
- Removed rows cannot be recovered without a transaction rollback or backup

---

### Delete a Single Row

```sql
DELETE FROM employees
WHERE id = 5;
```

---

### Delete with Multiple Conditions

```sql
DELETE FROM employees
WHERE dept = 'Marketing'
  AND salary < 60000.00;
```

```sql
DELETE FROM employees
WHERE dept IN ('Temp', 'Contractor')
   OR salary IS NULL;
```

**Key Points:**

- All `WHERE` clause patterns from `SELECT` apply: `AND`, `OR`, `IN`, `BETWEEN`, `LIKE`, `IS NULL`
- Parentheses are recommended when mixing `AND` and `OR` to avoid precedence errors

---

### Delete All Rows

```sql
DELETE FROM employees;
```

**Key Points:**

- Removes every row but preserves the table definition
- The `rowid` sequence is **not** reset — [Inference] this differs from `TRUNCATE` in other databases; SQLite has no `TRUNCATE` statement
- If resetting the sequence is required alongside clearing rows, `DROP TABLE` and recreate, or manually reset the `sqlite_sequence` table (for `AUTOINCREMENT` tables):

```sql
-- Reset AUTOINCREMENT counter (only applies to AUTOINCREMENT tables)
DELETE FROM sqlite_sequence WHERE name = 'employees';
```

**Key Points on sqlite_sequence:**

- `sqlite_sequence` only exists if at least one table was created with `AUTOINCREMENT`
- Modifying it directly is supported but should be done carefully — [Inference] inserting after a manual reset may produce IDs that conflict with previously deleted rows if those rows still exist elsewhere (e.g., in foreign key references)

---

### DELETE with RETURNING

Available in SQLite 3.35.0+. Returns data from the rows that were deleted.

```sql
DELETE FROM employees
WHERE dept = 'Temp'
RETURNING id, name, salary;
```

**Output:**

```
7  | Frank  | 52000.00
11 | Judy   | 48000.00
```

**Key Points:**

- `RETURNING *` returns all columns of the deleted rows
- Row values are returned as they existed **before** deletion
- Useful for logging, auditing, or feeding deleted data into another operation without a prior `SELECT`
- Requires SQLite 3.35.0+ — verify with `SELECT SQLITE_VERSION();`

---

### DELETE with Subquery in WHERE

```sql
DELETE FROM employees
WHERE id IN (
    SELECT id FROM employees
    WHERE salary < (SELECT AVG(salary) FROM employees)
      AND dept = 'Operations'
);
```

**Key Points:**

- Subqueries in `DELETE` follow the same rules as in `SELECT`
- The subquery is evaluated before deletion begins — [Inference] rows matching the subquery at evaluation time are the rows deleted; modifications mid-statement do not alter the target set, but this should be tested in your environment
- Correlated subqueries are supported

---

### DELETE with FROM Clause (Join-Style)

SQLite does not support `DELETE ... JOIN` directly. A join can be expressed via subquery or, in SQLite 3.33.0+, via a `FROM` clause.

#### Using Subquery (all versions):

```sql
DELETE FROM employees
WHERE id IN (
    SELECT e.id
    FROM employees e
    JOIN departments d ON e.dept = d.name
    WHERE d.status = 'dissolved'
);
```

#### Using FROM clause (SQLite 3.33.0+):

```sql
DELETE FROM employees
WHERE employees.dept = departments.name
  AND departments.status = 'dissolved';
```

Wait — the `FROM` clause form for `DELETE` requires explicit syntax:

```sql
DELETE FROM employees
WHERE EXISTS (
    SELECT 1 FROM departments
    WHERE departments.name = employees.dept
      AND departments.status = 'dissolved'
);
```

**Key Points:**

- SQLite's `DELETE` does not support a standalone `FROM` join clause the way `UPDATE` does in 3.33.0+ — use `EXISTS` or `IN` subqueries for join-style filtering
- `EXISTS` can be more readable when checking related table conditions
- [Inference] `EXISTS` may perform differently than `IN` depending on indexes — use `EXPLAIN QUERY PLAN` to compare

---

### DELETE with EXISTS

```sql
DELETE FROM employees
WHERE EXISTS (
    SELECT 1 FROM terminations
    WHERE terminations.employee_id = employees.id
      AND terminations.effective_date <= DATE('now')
);
```

**Key Points:**

- `EXISTS` returns true if the subquery produces at least one row
- The `SELECT 1` convention is standard — the actual selected value is irrelevant; only row existence matters
- Correlated via `employees.id` — evaluated per row in the outer table

---

### DELETE with CTE

```sql
WITH low_performers AS (
    SELECT id FROM employees
    WHERE salary < 50000.00
      AND dept = 'Operations'
)
DELETE FROM employees
WHERE id IN (SELECT id FROM low_performers);
```

**Key Points:**

- CTE support in `DELETE` requires SQLite 3.35.0+
- The CTE is read-only — it supplies row identifiers; the actual deletion targets the main table
- Useful when the filter logic is complex enough to benefit from named decomposition

---

### Conflict Resolution in DELETE

`DELETE` supports `OR` conflict resolution clauses, though they are less commonly applicable than in `INSERT` or `UPDATE`.

```sql
DELETE OR IGNORE FROM employees WHERE id = 99;
DELETE OR ROLLBACK FROM employees WHERE id = 1;
```

**Key Points:**

- Conflicts during `DELETE` most commonly arise from triggers that perform inserts or updates on constrained columns
- The same conflict variants apply: `OR ABORT` (default), `OR FAIL`, `OR IGNORE`, `OR REPLACE`, `OR ROLLBACK`
- In practice, `OR IGNORE` is the most useful variant for `DELETE` — it suppresses errors from constraint violations triggered by the deletion

---

### Cascade Deletes via Foreign Keys

SQLite supports `ON DELETE CASCADE` when foreign keys are enabled.

```sql
PRAGMA foreign_keys = ON;

CREATE TABLE departments (
    id   INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE employees (
    id      INTEGER PRIMARY KEY,
    name    TEXT,
    dept_id INTEGER REFERENCES departments(id) ON DELETE CASCADE
);

-- Deleting a department removes all linked employees
DELETE FROM departments WHERE id = 3;
```

**Key Points:**

- Foreign key enforcement is **disabled by default** in SQLite — `PRAGMA foreign_keys = ON;` must be set per connection
- `ON DELETE CASCADE` removes child rows automatically when the parent row is deleted
- Other options: `ON DELETE SET NULL`, `ON DELETE SET DEFAULT`, `ON DELETE RESTRICT`, `ON DELETE NO ACTION`
- [Inference] Cascade behavior is not triggered if foreign keys are off — deletions may leave orphaned rows silently; always verify `PRAGMA foreign_keys;` returns `1` before relying on cascade behavior

---

### PRAGMA foreign_keys Behavior

```sql
-- Check current state
PRAGMA foreign_keys;
-- 0 = disabled (default), 1 = enabled

-- Enable for current connection
PRAGMA foreign_keys = ON;
```

**Key Points:**

- Must be set after every new connection — it does not persist
- Has no effect inside a transaction — set it before `BEGIN`
- [Unverified] Some SQLite builds or wrapper libraries may enable this automatically — verify in your environment

---

### Verifying Deletions with changes()

```sql
DELETE FROM employees
WHERE dept = 'Temp';

SELECT changes();
```

**Output:**

```
4
```

**Key Points:**

- Returns the row count affected by the most recent `INSERT`, `UPDATE`, or `DELETE`
- Returns `0` if no rows matched the `WHERE` condition — useful for detecting no-op deletes
- Does not count rows removed by cascading foreign key actions — use `total_changes()` for that
- Scoped to the current connection

---

### TRUNCATE Equivalent

SQLite has no `TRUNCATE` statement. The closest equivalent is:

```sql
DELETE FROM employees;
```

Or, for full reset including `rowid` sequence:

```sql
DROP TABLE employees;
CREATE TABLE employees ( ... );
```

**Key Points:**

- `DELETE FROM table` without `WHERE` is a full-table delete but does not reclaim disk space immediately
- Run `VACUUM` afterward to reclaim space if needed:

```sql
VACUUM;
```

- [Inference] `VACUUM` rewrites the entire database file — on large databases this can be slow and temporarily doubles disk usage; run outside of peak usage windows

---

### DELETE with LIMIT and ORDER BY

Available only in SQLite builds compiled with `SQLITE_ENABLE_UPDATE_DELETE_LIMIT`.

```sql
DELETE FROM employees
ORDER BY salary ASC
LIMIT 3;
```

**Key Points:**

- Deletes only the first N rows matching the sort order
- `ORDER BY` is required when `LIMIT` is used in `DELETE`
- Not available in all distributions — check with:

```sql
PRAGMA compile_options;
-- Look for: ENABLE_UPDATE_DELETE_LIMIT
```

- [Unverified] Do not assume this feature is present without confirming compile options in your environment

---

### Safe DELETE Practices

Always verify which rows will be affected before deleting.

```sql
-- Step 1: Preview affected rows
SELECT * FROM employees
WHERE dept = 'Temp' AND salary < 55000.00;

-- Step 2: If correct, delete within a transaction
BEGIN;

DELETE FROM employees
WHERE dept = 'Temp' AND salary < 55000.00;

SELECT changes(); -- Confirm row count

COMMIT;

-- Or roll back if result is unexpected:
-- ROLLBACK;
```

**Key Points:**

- The `SELECT` preview uses the identical `WHERE` clause — copy-paste to avoid divergence
- Wrapping in `BEGIN ... COMMIT` allows inspection and rollback before finalizing
- `changes()` inside the transaction confirms the count before `COMMIT`
- [Inference] In application code, using parameterized queries reduces the risk of accidental full-table deletes from malformed `WHERE` clauses — behavior depends on the driver and how queries are constructed

---

### Soft Delete Pattern

A common alternative to physical deletion — mark rows as inactive instead of removing them.

```sql
ALTER TABLE employees ADD COLUMN deleted_at TEXT DEFAULT NULL;

-- Soft delete
UPDATE employees
SET deleted_at = DATETIME('now')
WHERE id = 7;

-- Query only active rows
SELECT * FROM employees
WHERE deleted_at IS NULL;

-- Restore
UPDATE employees
SET deleted_at = NULL
WHERE id = 7;
```

**Key Points:**

- Preserves history and allows recovery without a backup
- Requires all queries to include `WHERE deleted_at IS NULL` to exclude deleted rows — a partial index helps:

```sql
CREATE INDEX idx_employees_active
ON employees (dept, salary)
WHERE deleted_at IS NULL;
```

- [Inference] The partial index is only used by queries that include the matching `WHERE deleted_at IS NULL` condition — query plans should be verified with `EXPLAIN QUERY PLAN`
- Disk usage grows over time — periodic archival or purging of soft-deleted rows may be needed

---

**Conclusion:** SQLite's `DELETE` ranges from simple single-row removals to subquery-driven bulk deletions and cascade operations. Key behaviors to internalize: foreign keys are off by default and must be enabled per connection; `AUTOINCREMENT` sequences are not reset by `DELETE`; `RETURNING` and CTE support require SQLite 3.35.0+. Wrapping destructive operations in transactions and previewing with `SELECT` first are the most reliable safeguards against unintended data loss.

**Next Steps:**

- Transactions and savepoints
- Foreign key constraints and referential integrity
- Triggers (which can fire on `DELETE` events)
- Indexes and their effect on DELETE performance

---

## Data Import and Export in SQLite

---

### Overview

SQLite does not have a built-in network-based import/export server. All import and export operations happen through:

- The SQLite CLI (`.import`, `.output`, `.dump`)
- SQL statements (`ATTACH`, `INSERT INTO ... SELECT`)
- External tools and language libraries
- Direct file operations on the `.db` file itself

**Key Points:**

- The SQLite CLI is the primary built-in tool for file-based import/export
- Behavior of CLI commands may vary slightly across SQLite versions — verify with your installed version
- All paths in CLI commands are relative to the working directory from which the CLI was launched unless absolute paths are given

---

### The SQLite CLI

Launch the CLI against a database file:

```bash
sqlite3 mydatabase.db
```

Or open an in-memory database:

```bash
sqlite3 :memory:
```

Check version:

```bash
sqlite3 --version
```

---

### Exporting Data

---

#### .output and .once

Redirect subsequent query output to a file.

```sql
.output /path/to/results.txt
SELECT * FROM employees;
.output stdout
```

**Key Points:**

- `.output` redirects all subsequent output until changed
- `.once` redirects only the next query's output:

```sql
.once /path/to/single_result.txt
SELECT * FROM employees WHERE dept = 'Engineering';
```

- After `.once`, output returns to stdout automatically
- If the file exists it is overwritten — there is no append mode in `.output`

---

#### Exporting as CSV

```sql
.headers on
.mode csv
.output employees.csv
SELECT * FROM employees;
.output stdout
.mode list
```

**Key Points:**

- `.headers on` includes column names as the first row
- `.mode csv` formats output with comma separators and quotes fields containing commas or newlines
- Restore `.mode list` (default) or another mode after export to avoid affecting subsequent output
- [Inference] Fields containing embedded quotes are escaped by doubling them — this follows RFC 4180 convention but verify compatibility with your target application

**Example output:**

```
id,name,dept,salary
1,Alice,Engineering,95000.0
2,Bob,Marketing,72000.0
```

---

#### Exporting as TSV (Tab-Separated)

```sql
.headers on
.mode tabs
.output employees.tsv
SELECT * FROM employees;
.output stdout
```

---

#### Exporting as JSON

Available in SQLite 3.38.0+.

```sql
.mode json
.output employees.json
SELECT * FROM employees;
.output stdout
```

**Output:**

```json
[
  {"id":1,"name":"Alice","dept":"Engineering","salary":95000.0},
  {"id":2,"name":"Bob","dept":"Marketing","salary":72000.0}
]
```

**Key Points:**

- Produces a JSON array of objects
- Column names become keys
- Requires SQLite 3.38.0+ — verify with `SELECT SQLITE_VERSION();`
- [Inference] NULL values are exported as JSON `null`; BLOB values may not serialize cleanly — test with your data

---

#### Exporting as Insert Statements

```sql
.mode insert employees
.output employees_inserts.sql
SELECT * FROM employees;
.output stdout
```

**Output:**

```sql
INSERT INTO employees VALUES(1,'Alice','Engineering',95000.0);
INSERT INTO employees VALUES(2,'Bob','Marketing',72000.0);
```

**Key Points:**

- Useful for migrating data between SQLite databases
- The table name after `.mode insert` sets the target table name in the output
- Does not include `CREATE TABLE` — combine with `.dump` for a full schema + data export

---

#### Full Database Dump (.dump)

Exports the entire database as SQL statements — schema and data.

```sql
.dump
```

Or from the shell:

```bash
sqlite3 mydatabase.db .dump > backup.sql
```

Dump a single table:

```sql
.dump employees
```

**Key Points:**

- Output includes `CREATE TABLE`, `CREATE INDEX`, `INSERT` statements, and triggers
- Wraps everything in `BEGIN TRANSACTION ... COMMIT` for consistency
- Suitable for backups, version control, and cross-database migration
- Output is plain text SQL — portable to any SQLite installation
- [Inference] For very large databases, `.dump` may produce very large SQL files and take considerable time — consider the `.backup` command or file-level copy for large datasets

---

#### Exporting Schema Only

```sql
.schema
```

Or for a specific table:

```sql
.schema employees
```

From the shell:

```bash
sqlite3 mydatabase.db .schema > schema.sql
```

**Key Points:**

- Outputs only `CREATE` statements — no data
- Includes tables, indexes, views, and triggers

---

### Importing Data

---

#### .import — CSV Import

```sql
.mode csv
.import /path/to/employees.csv employees
```

**Key Points:**

- If the table does not exist, SQLite creates it using the first row as column names with `TEXT` affinity for all columns
- If the table exists, data is appended — no deduplication is performed
- First row is treated as a header by default in SQLite 3.32.0+ when using `.import` with `--skip 1` or when table already exists
- [Inference] Column count in the CSV must match the table's column count — mismatches typically produce errors or malformed rows; verify before importing

**Explicit skip-header import (SQLite 3.32.0+):**

```sql
.import --skip 1 /path/to/employees.csv employees
```

**Key Points:**

- `--skip 1` skips the first row (header) when the table already exists
- Without `--skip 1`, the header row is inserted as a data row if the table pre-exists

---

#### Importing with a Defined Table

Best practice: create the table first with proper types and constraints, then import.

```sql
CREATE TABLE employees (
    id      INTEGER,
    name    TEXT NOT NULL,
    dept    TEXT,
    salary  REAL
);

.mode csv
.import --skip 1 employees.csv employees
```

**Key Points:**

- Pre-creating the table applies column affinity and constraints during import
- `NOT NULL` constraints will cause import to fail if the CSV contains empty values in that column — [Inference] pre-cleaning the CSV or using a staging table with all `TEXT` columns may reduce import errors

---

#### Staging Table Pattern

Import into a permissive staging table, then insert into the real table after validation.

```sql
CREATE TABLE employees_staging (
    id      TEXT,
    name    TEXT,
    dept    TEXT,
    salary  TEXT
);

.mode csv
.import --skip 1 employees.csv employees_staging

-- Validate and transform
INSERT INTO employees (id, name, dept, salary)
SELECT
    CAST(id AS INTEGER),
    TRIM(name),
    NULLIF(TRIM(dept), ''),
    CAST(salary AS REAL)
FROM employees_staging
WHERE name IS NOT NULL AND name != '';

DROP TABLE employees_staging;
```

**Key Points:**

- All columns in the staging table are `TEXT` — avoids type mismatch errors on import
- `CAST`, `TRIM`, `NULLIF` clean and convert data during the final insert
- `NULLIF(value, '')` converts empty strings to `NULL`
- Allows row-level validation before committing to the real table

---

#### Importing SQL Files

Run a `.sql` file containing SQL statements:

```bash
sqlite3 mydatabase.db < backup.sql
```

Or from within the CLI:

```sql
.read /path/to/backup.sql
```

**Key Points:**

- Executes every statement in the file sequentially
- Errors in the file may halt execution depending on CLI error handling settings
- Use `.bail on` to stop on first error:

```sql
.bail on
.read backup.sql
```

---

#### Importing TSV

```sql
.mode tabs
.import employees.tsv employees
```

---

### ATTACH — Cross-Database Operations

`ATTACH` connects a second database file to the current session, enabling cross-database queries and data transfer.

```sql
ATTACH DATABASE '/path/to/other.db' AS other;

-- Copy a table from another database
INSERT INTO employees
SELECT * FROM other.employees;

-- Query across both databases
SELECT e.name, d.budget
FROM employees e
JOIN other.departments d ON e.dept = d.name;

DETACH DATABASE other;
```

**Key Points:**

- Up to 10 databases can be attached simultaneously by default (compile-time limit — [Unverified] may differ in some builds)
- The main database is always accessible as `main`
- Schema is referenced as `database_name.table_name`
- `ATTACH` requires filesystem access to the target file
- Transactions can span attached databases — [Inference] atomicity across databases depends on SQLite's transaction model; this should be tested under your concurrency requirements

---

### Exporting to Other Databases via ATTACH

```sql
ATTACH DATABASE 'archive.db' AS archive;

CREATE TABLE archive.old_employees AS
SELECT * FROM employees WHERE deleted_at IS NOT NULL;

DETACH DATABASE archive;
```

**Key Points:**

- `CREATE TABLE ... AS SELECT` creates and populates a table in one step
- The new table inherits column names and types from the query — no constraints or indexes are copied
- Useful for archiving or partitioning data across database files

---

### File-Level Backup and Restore

For a consistent copy of the entire database, SQLite provides the `.backup` command and the Online Backup API.

#### CLI Backup:

```bash
sqlite3 mydatabase.db ".backup backup.db"
```

Or from within the CLI:

```sql
.backup backup.db
```

#### CLI Restore:

```bash
sqlite3 restored.db ".restore backup.db"
```

**Key Points:**

- `.backup` uses the SQLite Online Backup API — it is safe to run on a live database
- [Inference] A simple file copy (`cp mydatabase.db backup.db`) may produce a corrupt copy if a write is in progress — `.backup` is the safer approach
- `.backup` and `.restore` preserve all indexes, triggers, and views
- WAL mode databases should use `.backup` rather than direct file copy — [Inference] copying just the `.db` file without the `-wal` and `-shm` files may result in an incomplete backup; verify your WAL state before copying

---

### Exporting via Application Libraries

Most SQLite wrappers provide cursor-based access to query results that can be serialized externally.

#### Python (sqlite3 + csv):

```python
import sqlite3
import csv

conn = sqlite3.connect('mydatabase.db')
cursor = conn.execute('SELECT * FROM employees')

with open('employees.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow([desc[0] for desc in cursor.description])  # headers
    writer.writerows(cursor.fetchall())

conn.close()
```

#### Python — Import CSV:

```python
import sqlite3
import csv

conn = sqlite3.connect('mydatabase.db')

with open('employees.csv', newline='') as f:
    reader = csv.DictReader(f)
    rows = [(r['name'], r['dept'], float(r['salary'])) for r in reader]

conn.executemany(
    'INSERT INTO employees (name, dept, salary) VALUES (?, ?, ?)',
    rows
)
conn.commit()
conn.close()
```

**Key Points:**

- Parameterized queries (`?`) avoid SQL injection and handle quoting automatically
- `executemany` is more efficient than looping individual `execute` calls
- [Inference] Wrapping `executemany` in an explicit transaction can significantly improve bulk insert performance — behavior depends on the library's default autocommit mode

---

#### Python — Export to JSON:

```python
import sqlite3
import json

conn = sqlite3.connect('mydatabase.db')
conn.row_factory = sqlite3.Row

rows = conn.execute('SELECT * FROM employees').fetchall()
data = [dict(row) for row in rows]

with open('employees.json', 'w') as f:
    json.dump(data, f, indent=2)

conn.close()
```

---

### Handling BLOBs in Import/Export

BLOBs (binary data) require special handling — they cannot be reliably exported as plain text.

```sql
-- Export BLOB as hex via CLI
SELECT id, hex(avatar) FROM employees;
```

```python
# Python: read BLOB back as bytes
conn = sqlite3.connect('mydatabase.db')
row = conn.execute('SELECT avatar FROM employees WHERE id = 1').fetchone()
blob_data = row[0]  # bytes object in Python
```

**Key Points:**

- `hex()` in SQLite converts BLOB to uppercase hexadecimal text
- Round-tripping BLOBs through CSV is unreliable — binary-safe formats (JSON with base64, or direct DB-to-DB copy) are more appropriate
- [Inference] Large BLOBs stored in SQLite can make `.dump` output very large and slow to re-import — externally stored files with paths in the database is a common alternative pattern

---

### Common Import Errors and Causes

|Error|Likely Cause|
|---|---|
|`expected N columns but found M`|CSV column count doesn't match table|
|`NOT NULL constraint failed`|Empty CSV field mapped to `NOT NULL` column|
|`UNIQUE constraint failed`|Duplicate key in CSV conflicts with existing data|
|`no such table`|Table not created before `.import`|
|`could not open file`|Incorrect path or file permissions|
|Garbled data|File encoding mismatch (UTF-8 vs Latin-1)|

**Key Points:**

- SQLite CLI assumes UTF-8 encoding — files in other encodings should be converted before import
- [Unverified] Encoding behavior may differ across platforms and SQLite builds — verify if importing files from external sources

---

### Mode Reference Table

|`.mode` Value|Format|Notes|
|---|---|---|
|`list`|Pipe-delimited (default)|Default CLI output|
|`csv`|Comma-separated|RFC 4180 conventions|
|`tabs`|Tab-separated|TSV output|
|`json`|JSON array|Requires 3.38.0+|
|`insert <table>`|SQL INSERT statements|Portable SQL|
|`column`|Fixed-width columns|Human-readable|
|`markdown`|Markdown table|Documentation use|
|`box`|Unicode box-drawing|Terminal display|
|`table`|ASCII table|Terminal display|
|`line`|One value per line|Key=Value format|

---

**Conclusion:** SQLite's import and export capabilities center on the CLI's `.import`, `.output`, and `.dump` commands, supplemented by `ATTACH` for cross-database operations and library-level access for programmatic workflows. CSV is the most common interchange format, but type fidelity requires either a pre-created table or a staging-and-transform pattern. For full database backup, `.backup` is safer than raw file copy, particularly with WAL mode. Encoding, column count mismatches, and constraint violations are the most frequent sources of import errors — validate data in a staging table before committing to production tables.

**Next Steps:**

- Transactions and savepoints
- Full-text search with FTS5
- SQLite in Python, Node.js, and other runtimes
- Performance tuning for bulk imports (WAL mode, `PRAGMA synchronous`, transaction batching)

---

## Bulk Operations in SQLite

---

### What Qualifies as a Bulk Operation

Bulk operations involve inserting, updating, deleting, or reading large numbers of rows — typically where performance, atomicity, and efficiency matter more than single-row convenience.

**Key Points:**

- SQLite is file-based; every write that is not wrapped in an explicit transaction incurs a full disk sync by default
- The single most impactful optimization for bulk writes is **explicit transaction batching**
- Other factors: journal mode, synchronous setting, index presence, page size, and statement reuse

---

### Baseline: Why Unbatched Inserts Are Slow

```sql
-- Each statement is its own transaction (autocommit)
INSERT INTO employees (name, dept, salary) VALUES ('Alice', 'Engineering', 95000);
INSERT INTO employees (name, dept, salary) VALUES ('Bob', 'Marketing', 72000);
-- ... repeated thousands of times
```

**Key Points:**

- In autocommit mode, each `INSERT` opens a transaction, writes to disk, and syncs
- [Inference] This can result in hundreds or thousands of fsync calls for bulk data — likely the dominant cost on spinning disk and a significant cost on SSD; actual impact depends on hardware and OS
- Wrapping all inserts in a single transaction reduces this to one sync at `COMMIT`

---

### Transaction Batching

The most effective bulk write optimization.

```sql
BEGIN;

INSERT INTO employees (name, dept, salary) VALUES ('Alice', 'Engineering', 95000);
INSERT INTO employees (name, dept, salary) VALUES ('Bob', 'Marketing', 72000);
INSERT INTO employees (name, dept, salary) VALUES ('Carol', 'Design', 68000);
-- ... thousands more

COMMIT;
```

**Key Points:**

- All writes are buffered in memory and flushed once at `COMMIT`
- If any statement fails, `ROLLBACK` undoes all changes in the batch
- [Inference] Transaction size has practical limits — extremely large transactions consume memory proportional to the number of changed pages; batching in chunks (e.g., 1,000–10,000 rows per transaction) often balances performance and memory usage, though optimal size depends on your environment
- No guaranteed optimal batch size — benchmark with your data and hardware

---

### Chunked Transaction Batching

For very large datasets, commit in chunks rather than one massive transaction.

```python
import sqlite3

conn = sqlite3.connect('mydatabase.db')
CHUNK_SIZE = 5000

rows = [...]  # Large list of tuples

conn.execute('BEGIN')
for i, row in enumerate(rows):
    conn.execute(
        'INSERT INTO employees (name, dept, salary) VALUES (?, ?, ?)',
        row
    )
    if (i + 1) % CHUNK_SIZE == 0:
        conn.execute('COMMIT')
        conn.execute('BEGIN')

conn.execute('COMMIT')
conn.close()
```

**Key Points:**

- Commits every `CHUNK_SIZE` rows, then starts a new transaction
- Reduces peak memory usage compared to a single transaction over millions of rows
- [Inference] Partial failures mid-chunk lose only that chunk's data — consider whether that is acceptable for your use case, or whether full atomicity is required
- Chunk size should be tuned empirically — no universally correct value

---

### Multi-Row INSERT

Insert multiple rows in a single statement.

```sql
INSERT INTO employees (name, dept, salary)
VALUES
    ('Alice', 'Engineering', 95000),
    ('Bob',   'Marketing',   72000),
    ('Carol', 'Design',      68000),
    ('David', 'Engineering', 101000);
```

**Key Points:**

- Supported since SQLite 3.7.11
- [Inference] Reduces statement parsing overhead compared to equivalent single-row inserts — actual performance gain relative to batched single-row inserts within a transaction may be marginal; benchmark to verify
- SQLite has a limit on the number of rows per `VALUES` clause — controlled by `SQLITE_LIMIT_COMPOUND_SELECT` (default 500) — [Unverified] verify this limit in your build:

```sql
SELECT * FROM pragma_compile_options WHERE compile_options LIKE '%LIMIT%';
```

---

### executemany (Python)

Python's `sqlite3` module provides `executemany` for efficient parameterized bulk inserts.

```python
import sqlite3

conn = sqlite3.connect('mydatabase.db')

rows = [
    ('Alice', 'Engineering', 95000.0),
    ('Bob',   'Marketing',   72000.0),
    ('Carol', 'Design',      68000.0),
]

conn.execute('BEGIN')
conn.executemany(
    'INSERT INTO employees (name, dept, salary) VALUES (?, ?, ?)',
    rows
)
conn.execute('COMMIT')
conn.close()
```

**Key Points:**

- `executemany` prepares the statement once and iterates over the data — [Inference] more efficient than calling `execute` in a loop for large datasets; actual gains depend on the driver implementation
- Parameterized queries (`?`) handle quoting and type conversion automatically
- Wrapping in explicit `BEGIN/COMMIT` is still necessary for transaction batching — `executemany` does not automatically batch into a transaction

---

### INSERT INTO ... SELECT (Bulk Copy)

Move or copy large sets of rows between tables in a single statement.

```sql
-- Copy all rows
INSERT INTO employees_backup
SELECT * FROM employees;

-- Filtered copy
INSERT INTO employees_archive
SELECT * FROM employees
WHERE deleted_at IS NOT NULL;

-- Transform on copy
INSERT INTO employees_normalized (name, dept, salary)
SELECT TRIM(UPPER(name)), LOWER(dept), ROUND(salary, 2)
FROM employees_raw;
```

**Key Points:**

- Executes entirely within SQLite — no data leaves the database engine
- [Inference] Significantly faster than read-then-write patterns through application code for large datasets, as it avoids serialization and network/IPC overhead
- The entire operation runs in a single implicit transaction unless inside an explicit one
- Column count and compatible types must align between source and destination

---

### Bulk UPDATE

Update large numbers of rows efficiently.

#### Full-table update (single expression):

```sql
UPDATE employees
SET salary = ROUND(salary * 1.05, 2);
```

#### Conditional bulk update with CASE:

```sql
UPDATE employees
SET salary = CASE
    WHEN dept = 'Engineering' THEN ROUND(salary * 1.10, 2)
    WHEN dept = 'Design'      THEN ROUND(salary * 1.07, 2)
    WHEN dept = 'Marketing'   THEN ROUND(salary * 1.04, 2)
    ELSE                           ROUND(salary * 1.02, 2)
END;
```

**Key Points:**

- A single `UPDATE` with `CASE` is [Inference] more efficient than multiple `UPDATE` statements for different departments — avoids repeated full or partial table scans; verify with `EXPLAIN QUERY PLAN`
- Wrap in a transaction if the update is part of a larger operation

#### Bulk update from another table (via subquery):

```sql
UPDATE employees
SET salary = (
    SELECT new_salary
    FROM salary_adjustments
    WHERE salary_adjustments.employee_id = employees.id
)
WHERE id IN (SELECT employee_id FROM salary_adjustments);
```

**Key Points:**

- The `WHERE id IN (...)` clause avoids setting unmatched rows to `NULL`
- [Inference] An index on `salary_adjustments.employee_id` and `employees.id` likely improves performance here — verify with `EXPLAIN QUERY PLAN`

---

### Bulk DELETE

```sql
-- Delete by condition
DELETE FROM employees
WHERE deleted_at < DATE('now', '-1 year');

-- Delete using subquery
DELETE FROM employees
WHERE id IN (
    SELECT id FROM employees
    ORDER BY created_at ASC
    LIMIT 10000
);
```

**Key Points:**

- Wrap large deletes in a transaction
- [Inference] Deleting large numbers of rows in one statement may cause long write locks — chunked deletes with transactions can reduce lock duration in concurrent environments
- Deleted rows leave free pages in the database file — run `VACUUM` afterward to reclaim space if needed

#### Chunked delete pattern (Python):

```python
import sqlite3

conn = sqlite3.connect('mydatabase.db')

while True:
    conn.execute('BEGIN')
    cursor = conn.execute(
        'DELETE FROM logs WHERE created_at < ? LIMIT 5000',
        ('2024-01-01',)
    )
    conn.execute('COMMIT')
    if cursor.rowcount == 0:
        break

conn.close()
```

**Key Points:**

- Requires `SQLITE_ENABLE_UPDATE_DELETE_LIMIT` compile option — verify before use
- Loops until no more rows match, avoiding a single massive delete

---

### PRAGMA Settings for Bulk Operations

Several PRAGMAs significantly affect write performance. These trade durability or safety for speed and should be evaluated against your requirements.

#### journal_mode

```sql
PRAGMA journal_mode = WAL;
```

|Mode|Description|
|---|---|
|`DELETE`|Default; rollback journal, exclusive write lock|
|`WAL`|Write-Ahead Log; allows concurrent reads during writes|
|`MEMORY`|Journal in memory only; data lost on crash|
|`OFF`|No journal; no rollback on crash|

**Key Points:**

- `WAL` mode is [Inference] generally beneficial for bulk writes with concurrent reads — reduces contention; actual gains depend on workload
- `MEMORY` and `OFF` remove durability guarantees — data may be unrecoverable after a crash
- `WAL` persists across connections — set once per database, not per connection
- [Unverified] Some embedded or read-only environments may not support WAL — verify compatibility

#### synchronous

```sql
PRAGMA synchronous = NORMAL;  -- Default in WAL mode
PRAGMA synchronous = OFF;     -- Maximum speed, minimum durability
PRAGMA synchronous = FULL;    -- Maximum durability (default in DELETE mode)
```

|Setting|Behavior|
|---|---|
|`FULL`|Syncs at every critical point — safest|
|`NORMAL`|Syncs less frequently — safe in WAL mode|
|`OFF`|No OS-level sync — fastest, but data may be lost on OS crash|

**Key Points:**

- `OFF` is appropriate for disposable or reproducible data (e.g., temp processing, test data)
- `NORMAL` with `WAL` is a common production balance — [Inference] reduces sync overhead while maintaining reasonable durability; behavior depends on OS and filesystem
- These settings are per-connection and do not persist

#### cache_size

```sql
PRAGMA cache_size = -65536;  -- 64MB (negative = kilobytes)
PRAGMA cache_size = 10000;   -- 10000 pages
```

**Key Points:**

- Larger cache reduces disk reads during bulk operations that revisit pages
- Default is typically 2MB — [Unverified] exact default depends on SQLite build and page size
- Setting too large may cause memory pressure — tune based on available system memory

#### page_size

```sql
-- Must be set BEFORE the database is created
PRAGMA page_size = 4096;   -- Default
PRAGMA page_size = 16384;  -- Larger pages; may help bulk reads
```

**Key Points:**

- Can only be changed on a new or empty database, or after a `VACUUM`
- [Inference] Larger page sizes may improve sequential bulk read performance at the cost of more wasted space for small rows — actual effect depends on row size and access patterns
- Has no effect if set after data has been written

#### temp_store

```sql
PRAGMA temp_store = MEMORY;
```

**Key Points:**

- Directs temporary tables and indexes used during queries to memory instead of disk
- [Inference] Can improve performance of bulk operations involving large sorts or intermediate results — behavior depends on available memory

---

### Indexes and Bulk Operations

**Key Points:**

- Indexes slow down bulk inserts, updates, and deletes — each write must also update every applicable index
- For large initial data loads, a common pattern is:

```sql
-- 1. Drop indexes before bulk load
DROP INDEX IF EXISTS idx_employees_dept;

-- 2. Perform bulk insert
BEGIN;
INSERT INTO employees ...;
COMMIT;

-- 3. Rebuild indexes after load
CREATE INDEX idx_employees_dept ON employees (dept);
```

- [Inference] This can substantially reduce bulk insert time when multiple indexes exist — gains are proportional to the number and size of indexes; benchmark in your environment
- `ANALYZE` after rebuild updates query planner statistics:

```sql
ANALYZE employees;
```

---

### CREATE TABLE AS SELECT (Bulk Table Creation)

Creates and populates a new table from a query in one operation.

```sql
CREATE TABLE engineering_employees AS
SELECT * FROM employees
WHERE dept = 'Engineering';
```

**Key Points:**

- Column names and types are inferred from the query — no constraints, indexes, or primary keys are copied
- [Inference] Faster than `CREATE TABLE` followed by `INSERT INTO ... SELECT` for large result sets — avoids overhead of constraint checking during insert; verify in your environment
- Useful for temporary analysis tables or archiving subsets

---

### Temporary Tables for Staging

```sql
CREATE TEMPORARY TABLE bulk_staging (
    name   TEXT,
    dept   TEXT,
    salary TEXT
);

-- Load raw data
INSERT INTO bulk_staging VALUES (...);

-- Validate and transform
INSERT INTO employees (name, dept, salary)
SELECT TRIM(name), dept, CAST(salary AS REAL)
FROM bulk_staging
WHERE name IS NOT NULL AND salary != '';

DROP TABLE bulk_staging;
```

**Key Points:**

- `TEMPORARY` tables exist only for the current connection and are automatically dropped on disconnect
- Stored in a separate temp database — [Inference] does not bloat the main database file
- Useful for validating and cleaning data before committing to production tables

---

### WITHOUT ROWID Tables

For certain access patterns, `WITHOUT ROWID` tables can improve bulk read and write performance.

```sql
CREATE TABLE lookup_codes (
    code        TEXT PRIMARY KEY,
    description TEXT
) WITHOUT ROWID;
```

**Key Points:**

- Omits the implicit `rowid` column — data is stored in a B-tree indexed by the primary key
- [Inference] Can improve performance for tables with small rows accessed primarily by primary key — gains depend on access pattern and row size
- Requires an explicit `PRIMARY KEY`
- `last_insert_rowid()` and `AUTOINCREMENT` do not apply
- Not suitable for tables with large or variable-length primary keys — [Inference] may increase page splits and reduce efficiency in those cases

---

### VACUUM After Bulk Delete

```sql
VACUUM;
```

**Key Points:**

- Rewrites the entire database file, reclaiming free pages left by bulk deletes
- [Inference] Temporarily requires up to double the database file's disk space during execution — verify available disk before running on large databases
- Blocks all other connections during execution
- `VACUUM INTO` creates a vacuumed copy without modifying the original:

```sql
VACUUM INTO '/path/to/compacted_backup.db';
```

---

### ANALYZE After Bulk Changes

```sql
ANALYZE;          -- Entire database
ANALYZE employees; -- Single table
```

**Key Points:**

- Updates internal statistics used by the query planner
- After large bulk inserts, updates, or deletes, stale statistics may cause the planner to choose suboptimal query plans
- [Inference] Running `ANALYZE` after significant data changes is good practice — actual impact on query plan quality depends on the queries and data distribution

---

### Bulk Operation PRAGMA Checklist

A reference sequence for maximum bulk write throughput — adjust based on your durability requirements.

```sql
-- Before bulk operation
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = -65536;    -- 64MB
PRAGMA temp_store = MEMORY;

DROP INDEX IF EXISTS idx_employees_dept;  -- Drop indexes if bulk loading

BEGIN;

-- ... bulk inserts, updates, or deletes ...

COMMIT;

-- After bulk operation
CREATE INDEX idx_employees_dept ON employees (dept);
ANALYZE employees;
VACUUM;  -- Only if large amounts of data were deleted
```

**Key Points:**

- Not all settings are appropriate for all environments — `synchronous = NORMAL` or `OFF` reduces durability
- `VACUUM` is expensive on large databases — run only when significant free space needs reclaiming
- These are starting points; benchmark and adjust for your specific workload and hardware
- [Inference] The combination of WAL mode, explicit transactions, and dropped indexes during load typically produces the largest performance gains — individual contributions vary

---

### Performance Comparison Reference

|Approach|Relative Write Speed|Notes|
|---|---|---|
|Autocommit single-row inserts|Very slow|One fsync per row|
|Explicit transaction, single-row inserts|Fast|One fsync at COMMIT|
|Multi-row INSERT in transaction|Fast|Reduced parse overhead|
|`executemany` in transaction|Fast|Prepared once, iterated|
|`INSERT INTO ... SELECT`|Very fast|In-engine; no app layer|
|With indexes dropped during load|Faster|Avoids index writes|
|WAL + synchronous=NORMAL|Faster|Reduced sync frequency|

**Key Points:**

- [Inference] These relative comparisons reflect commonly observed patterns — actual results depend on hardware, OS, row size, index count, and SQLite version; always benchmark with representative data
- No single configuration is optimal for all workloads

---

**Conclusion:** Bulk operation performance in SQLite is primarily governed by transaction batching, journal mode, synchronous settings, and index management. The most impactful single change for bulk writes is wrapping operations in explicit transactions. Beyond that, WAL mode, dropping and rebuilding indexes around large loads, and using `INSERT INTO ... SELECT` for in-database transfers compound the gains. All PRAGMA-based optimizations involve tradeoffs between speed and durability — evaluate against your data's recoverability requirements.

**Next Steps:**

- Indexes — design, types, and performance impact
- Transactions and savepoints in depth
- Query optimization and `EXPLAIN QUERY PLAN`
- WAL mode and concurrency behavior

---

# Advanced Querying

## WHERE Clauses and Filtering in SQLite

---

### Purpose and Placement

The `WHERE` clause restricts which rows are processed by a statement. It applies to `SELECT`, `UPDATE`, `DELETE`, and certain subquery contexts.

```sql
SELECT column1, column2 FROM table_name WHERE condition;
UPDATE table_name SET column = value WHERE condition;
DELETE FROM table_name WHERE condition;
```

**Key Points:**

- `WHERE` is evaluated before `SELECT` expressions — column aliases defined in `SELECT` are not available in `WHERE`
- `WHERE` filters individual rows before any grouping — use `HAVING` to filter after `GROUP BY`
- A missing `WHERE` clause processes every row in the table — intentional in some cases but dangerous in `UPDATE` and `DELETE`

---

### Comparison Operators

```sql
SELECT * FROM employees WHERE salary = 95000;
SELECT * FROM employees WHERE salary != 95000;
SELECT * FROM employees WHERE salary <> 95000;   -- equivalent to !=
SELECT * FROM employees WHERE salary > 80000;
SELECT * FROM employees WHERE salary < 80000;
SELECT * FROM employees WHERE salary >= 80000;
SELECT * FROM employees WHERE salary <= 80000;
```

**Key Points:**

- `!=` and `<>` are equivalent in SQLite
- Comparisons with `NULL` using these operators always return `NULL` (falsy) — use `IS NULL` / `IS NOT NULL` instead
- SQLite uses type affinity for comparisons — a `TEXT` value compared to an `INTEGER` follows affinity rules; results may be unexpected when column types are inconsistent

---

### Logical Operators: AND, OR, NOT

```sql
-- AND: both conditions must be true
SELECT * FROM employees
WHERE dept = 'Engineering' AND salary > 90000;

-- OR: either condition must be true
SELECT * FROM employees
WHERE dept = 'Engineering' OR dept = 'Design';

-- NOT: negates a condition
SELECT * FROM employees
WHERE NOT dept = 'HR';

-- Combined
SELECT * FROM employees
WHERE (dept = 'Engineering' OR dept = 'Design')
  AND salary > 75000
  AND NOT name LIKE '%Temp%';
```

**Key Points:**

- `AND` has higher precedence than `OR` — parentheses are required to override default precedence
- `NOT` has higher precedence than `AND` and `OR`
- Without parentheses, `A OR B AND C` is parsed as `A OR (B AND C)` — always use parentheses in mixed expressions to make intent explicit

---

### NULL Handling

`NULL` represents the absence of a value. Standard comparison operators do not work with `NULL`.

```sql
-- Correct
SELECT * FROM employees WHERE dept IS NULL;
SELECT * FROM employees WHERE dept IS NOT NULL;

-- Wrong — always returns no rows (NULL = NULL is NULL, not TRUE)
SELECT * FROM employees WHERE dept = NULL;
SELECT * FROM employees WHERE dept != NULL;
```

#### NULL in AND / OR

|Expression|Result|
|---|---|
|`NULL AND TRUE`|NULL (falsy)|
|`NULL AND FALSE`|FALSE|
|`NULL OR TRUE`|TRUE|
|`NULL OR FALSE`|NULL (falsy)|
|`NOT NULL`|NULL (falsy)|

**Key Points:**

- `NULL` propagates through most expressions — any arithmetic or comparison involving `NULL` returns `NULL`
- Use `COALESCE` or `IFNULL` to substitute defaults before comparing:

```sql
SELECT * FROM employees
WHERE COALESCE(dept, 'Unknown') = 'Unknown';
```

- `IS` and `IS NOT` are NULL-safe equality operators in SQLite:

```sql
SELECT * FROM employees WHERE dept IS 'Engineering';
-- Equivalent to: WHERE dept = 'Engineering' but NULL-safe
```

---

### BETWEEN

Tests for inclusive range membership.

```sql
SELECT * FROM employees
WHERE salary BETWEEN 60000 AND 90000;

-- Equivalent to:
SELECT * FROM employees
WHERE salary >= 60000 AND salary <= 90000;
```

**Date range example:**

```sql
SELECT * FROM employees
WHERE hire_date BETWEEN '2022-01-01' AND '2023-12-31';
```

**Key Points:**

- Both bounds are **inclusive**
- Works on numeric, text (lexicographic), and ISO-format date strings
- `NOT BETWEEN` excludes the range:

```sql
SELECT * FROM employees WHERE salary NOT BETWEEN 60000 AND 90000;
```

- If the lower bound exceeds the upper bound, no rows are returned — SQLite does not automatically swap bounds

---

### IN and NOT IN

Tests membership in a fixed list.

```sql
SELECT * FROM employees
WHERE dept IN ('Engineering', 'Design', 'IT');

SELECT * FROM employees
WHERE dept NOT IN ('HR', 'Marketing');
```

**Key Points:**

- Equivalent to chained `OR` conditions but more readable
- `IN` with a subquery is covered in the subquery section below
- **`NOT IN` with NULL caveat:** if any value in the list is `NULL`, `NOT IN` returns no rows — even when the column value clearly does not match other list items

```sql
-- Dangerous if dept_list contains NULL
SELECT * FROM employees
WHERE dept NOT IN (SELECT dept FROM excluded_depts);

-- Safer pattern
SELECT * FROM employees
WHERE dept NOT IN (
    SELECT dept FROM excluded_depts WHERE dept IS NOT NULL
);
```

- This behavior is standard SQL, not SQLite-specific — [Inference] any `NOT IN` subquery should explicitly filter `NULL` from the subquery result to avoid silently returning zero rows

---

### LIKE — Pattern Matching

```sql
-- Starts with
SELECT * FROM employees WHERE name LIKE 'A%';

-- Ends with
SELECT * FROM employees WHERE name LIKE '%son';

-- Contains
SELECT * FROM employees WHERE name LIKE '%ar%';

-- Single character wildcard
SELECT * FROM employees WHERE name LIKE '_ob';

-- Combined
SELECT * FROM employees WHERE name LIKE 'J___s';
```

|Wildcard|Matches|
|---|---|
|`%`|Zero or more characters|
|`_`|Exactly one character|

**Key Points:**

- Case-insensitive for ASCII characters by default in SQLite
- Case sensitivity for non-ASCII (Unicode) characters depends on the SQLite build and whether the ICU extension is loaded — [Unverified] do not assume case-insensitive Unicode `LIKE` without verifying your build
- `NOT LIKE` negates the pattern:

```sql
SELECT * FROM employees WHERE name NOT LIKE '%Temp%';
```

#### ESCAPE Clause

Allows literal `%` or `_` to be matched.

```sql
SELECT * FROM files WHERE path LIKE '100\% complete' ESCAPE '\';
```

**Key Points:**

- The character after `ESCAPE` becomes the escape prefix
- `\%` matches a literal `%`; `\_` matches a literal `_`

---

### GLOB — Case-Sensitive Pattern Matching

```sql
SELECT * FROM employees WHERE name GLOB 'A*';
SELECT * FROM employees WHERE name GLOB '[ABC]*';
SELECT * FROM employees WHERE name GLOB '*son';
SELECT * FROM employees WHERE dept GLOB '[A-E]*';
```

|Wildcard|Matches|
|---|---|
|`*`|Zero or more characters|
|`?`|Exactly one character|
|`[abc]`|Any character in set|
|`[a-z]`|Any character in range|
|`[^abc]`|Any character not in set|

**Key Points:**

- Always case-sensitive — unlike `LIKE`
- SQLite-specific — not standard SQL
- `NOT GLOB` is valid:

```sql
SELECT * FROM employees WHERE name NOT GLOB '[A-M]*';
```

---

### REGEXP

SQLite does not include a built-in `REGEXP` implementation. It requires a user-defined function registered at connection time.

```python
import sqlite3
import re

def regexp(pattern, value):
    if value is None:
        return None
    return bool(re.search(pattern, value))

conn = sqlite3.connect('mydatabase.db')
conn.create_function('REGEXP', 2, regexp)

rows = conn.execute(
    "SELECT * FROM employees WHERE name REGEXP '^A.*n$'"
).fetchall()
```

```sql
-- Once registered:
SELECT * FROM employees WHERE name REGEXP '^[A-Z][a-z]+$';
```

**Key Points:**

- `REGEXP` raises an error if no function is registered — it is a placeholder in SQLite's parser
- [Unverified] Some SQLite distributions or extensions may include a built-in `REGEXP` — verify in your environment
- For most pattern needs, `LIKE` or `GLOB` are sufficient without external dependencies

---

### EXISTS and NOT EXISTS

Tests whether a subquery returns any rows.

```sql
-- Rows where a related record exists
SELECT * FROM employees e
WHERE EXISTS (
    SELECT 1 FROM projects p
    WHERE p.lead_id = e.id
);

-- Rows where no related record exists
SELECT * FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM projects p
    WHERE p.lead_id = e.id
);
```

**Key Points:**

- `EXISTS` returns `TRUE` if the subquery produces at least one row — the selected value is irrelevant; `SELECT 1` is conventional
- Short-circuits on the first matching row — [Inference] may be more efficient than `IN` for large subquery results, particularly when the subquery is correlated; verify with `EXPLAIN QUERY PLAN`
- Correlated subqueries reference the outer query's columns — evaluated once per outer row
- `NOT EXISTS` is often safer than `NOT IN` when the subquery may return `NULL` values

---

### Subqueries in WHERE

#### Scalar Subquery

Returns a single value for comparison.

```sql
SELECT * FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

#### IN with Subquery

```sql
SELECT * FROM employees
WHERE dept IN (
    SELECT name FROM departments WHERE budget > 500000
);
```

#### Correlated Subquery

References the outer query per row.

```sql
SELECT * FROM employees e
WHERE salary > (
    SELECT AVG(salary) FROM employees
    WHERE dept = e.dept
);
```

**Key Points:**

- Correlated subqueries are evaluated once per outer row — [Inference] can be slow on large tables without indexes on the correlated columns; use `EXPLAIN QUERY PLAN` to assess
- Scalar subqueries that return more than one row produce an error — use `LIMIT 1` or aggregation to guarantee a single result
- [Inference] In many cases, a `JOIN` can replace a correlated subquery with better performance — verify with your query planner

---

### CASE in WHERE

`CASE` expressions can appear in `WHERE` conditions.

```sql
SELECT * FROM employees
WHERE
    CASE dept
        WHEN 'Engineering' THEN salary > 90000
        WHEN 'Design'      THEN salary > 65000
        ELSE                    salary > 55000
    END;
```

**Key Points:**

- `CASE` returns a value — when used in `WHERE`, a truthy (non-zero, non-null) result passes the row
- Useful for conditional thresholds that vary by category
- [Inference] May prevent index usage on the filtered columns — verify with `EXPLAIN QUERY PLAN`

---

### Filtering on Expressions and Functions

Any expression valid in `SELECT` can appear in `WHERE`.

```sql
-- Function in WHERE
SELECT * FROM employees
WHERE UPPER(dept) = 'ENGINEERING';

-- Arithmetic
SELECT * FROM employees
WHERE salary * 1.10 > 100000;

-- Date function
SELECT * FROM employees
WHERE hire_date >= DATE('now', '-1 year');

-- String length
SELECT * FROM employees
WHERE LENGTH(name) > 10;

-- Type check
SELECT * FROM employees
WHERE TYPEOF(salary) = 'real';
```

**Key Points:**

- Applying functions to columns in `WHERE` typically prevents index use on that column — [Inference] SQLite cannot use an index on `dept` when `UPPER(dept)` is evaluated per row; an expression index can address this:

```sql
CREATE INDEX idx_dept_upper ON employees (UPPER(dept));

-- Now this can use the index:
SELECT * FROM employees WHERE UPPER(dept) = 'ENGINEERING';
```

- Date comparisons work correctly with ISO 8601 strings (`YYYY-MM-DD`) stored as `TEXT` — other formats may not sort or compare correctly

---

### Expression Indexes for WHERE Optimization

When a function or expression is frequently used in `WHERE`, an expression index allows the query planner to use it.

```sql
-- Without index: full scan, UPPER() evaluated per row
SELECT * FROM employees WHERE UPPER(name) = 'ALICE';

-- Create expression index
CREATE INDEX idx_name_upper ON employees (UPPER(name));

-- Now eligible for index lookup
SELECT * FROM employees WHERE UPPER(name) = 'ALICE';
```

**Key Points:**

- Expression must match exactly in both the index definition and the `WHERE` clause
- [Inference] Improves performance when the column has high cardinality and the expression is used frequently — actual gains depend on data size and query frequency
- Increases write overhead — index must be updated on every row change

---

### Filtering NULLs with COALESCE and IFNULL

```sql
-- Treat NULL dept as 'Unassigned'
SELECT * FROM employees
WHERE COALESCE(dept, 'Unassigned') = 'Unassigned';

-- Equivalent using IFNULL
SELECT * FROM employees
WHERE IFNULL(dept, 'Unassigned') = 'Unassigned';

-- Filter where bonus is null or zero
SELECT * FROM employees
WHERE COALESCE(bonus, 0) = 0;
```

**Key Points:**

- `COALESCE(x, y)` returns the first non-NULL argument
- `IFNULL(x, y)` is equivalent to `COALESCE` with two arguments — SQLite-specific shorthand
- Both prevent the NULL-propagation problem in comparisons
- [Inference] Using these functions in `WHERE` may prevent index use on the column — consider restructuring as `WHERE col IS NULL OR col = value` when index performance matters:

```sql
SELECT * FROM employees
WHERE dept IS NULL OR dept = 'Unassigned';
```

---

### Filtering with ROWID

Every SQLite table has an implicit `rowid` unless created as `WITHOUT ROWID`.

```sql
SELECT * FROM employees WHERE rowid = 42;
SELECT * FROM employees WHERE rowid BETWEEN 100 AND 200;
```

**Key Points:**

- `rowid` lookups use the built-in B-tree index — [Inference] typically the fastest possible lookup in SQLite
- Accessible as `rowid`, `oid`, or `_rowid_` unless a column with that name is explicitly defined
- An `INTEGER PRIMARY KEY` column is an alias for `rowid` — lookups on it are equally fast

---

### WHERE with HAVING — Knowing the Difference

```sql
-- WHERE filters before grouping
SELECT dept, AVG(salary) AS avg_sal
FROM employees
WHERE salary > 50000          -- Excludes rows before grouping
GROUP BY dept
HAVING AVG(salary) > 80000;  -- Filters groups after aggregation
```

**Key Points:**

- `WHERE` cannot reference aggregate functions (`COUNT`, `AVG`, `SUM`, etc.) — those are not computed until after grouping
- `HAVING` filters on aggregated results — it can also filter on non-aggregated columns, though `WHERE` is more efficient for that purpose
- Both can appear in the same query — `WHERE` narrows the row set before `GROUP BY` processes it

---

### Filtering in UPDATE and DELETE

All `WHERE` patterns apply equally to `UPDATE` and `DELETE`.

```sql
UPDATE employees
SET salary = salary * 1.10
WHERE dept = 'Engineering'
  AND salary < (SELECT AVG(salary) FROM employees WHERE dept = 'Engineering');

DELETE FROM employees
WHERE hire_date < DATE('now', '-5 years')
  AND dept IN (SELECT name FROM departments WHERE status = 'dissolved');
```

**Key Points:**

- Previewing with a `SELECT` using the identical `WHERE` clause before running `UPDATE` or `DELETE` is strongly recommended
- Subqueries, `EXISTS`, `IN`, and all other `WHERE` patterns work in `UPDATE` and `DELETE` contexts

---

### Common Filtering Mistakes

#### Incorrect NULL comparison:

```sql
-- Wrong
WHERE dept = NULL

-- Correct
WHERE dept IS NULL
```

#### Precedence error with OR and AND:

```sql
-- Unintended: reads as dept='HR' OR (dept='IT' AND salary > 80000)
WHERE dept = 'HR' OR dept = 'IT' AND salary > 80000

-- Intended
WHERE (dept = 'HR' OR dept = 'IT') AND salary > 80000
```

#### NOT IN with nullable subquery:

```sql
-- May return no rows if subquery contains NULL
WHERE id NOT IN (SELECT manager_id FROM departments)

-- Safe version
WHERE id NOT IN (
    SELECT manager_id FROM departments WHERE manager_id IS NOT NULL
)
```

#### Function on column prevents index use:

```sql
-- Index on dept not used
WHERE LOWER(dept) = 'engineering'

-- Index on dept used
WHERE dept = 'Engineering'

-- Or: create expression index for the LOWER() form
CREATE INDEX idx_dept_lower ON employees (LOWER(dept));
```

---

### WHERE Clause Operator Reference

|Operator / Keyword|Purpose|
|---|---|
|`=`, `!=`, `<>`|Equality / inequality|
|`<`, `>`, `<=`, `>=`|Range comparison|
|`IS NULL`, `IS NOT NULL`|NULL checks|
|`IS`, `IS NOT`|NULL-safe equality|
|`BETWEEN ... AND ...`|Inclusive range|
|`IN (...)`|List membership|
|`NOT IN (...)`|List exclusion|
|`LIKE`|Case-insensitive pattern (ASCII)|
|`NOT LIKE`|Negated pattern|
|`GLOB`|Case-sensitive pattern|
|`NOT GLOB`|Negated glob|
|`REGEXP`|Regex (requires UDF)|
|`EXISTS (...)`|Subquery row existence|
|`NOT EXISTS (...)`|Subquery row absence|
|`AND`, `OR`, `NOT`|Logical combination|
|`COALESCE`, `IFNULL`|NULL substitution|

---

**Conclusion:** SQLite's `WHERE` clause supports a full range of filtering patterns — from simple equality checks to correlated subqueries, pattern matching, and expression-based conditions. The most common pitfalls are NULL handling with `NOT IN`, operator precedence with mixed `AND`/`OR`, and inadvertently preventing index use by applying functions to filtered columns. Where performance matters, `EXPLAIN QUERY PLAN` is the definitive tool for verifying whether a given `WHERE` condition uses an index.

**Next Steps:**

- Aggregate functions and GROUP BY
- Joins and multi-table filtering
- Indexes — design and query planner interaction
- EXPLAIN QUERY PLAN in depth

---

## Sorting with ORDER BY in SQLite

---

### Basic Syntax

`ORDER BY` controls the sequence in which rows are returned.

```sql
SELECT column1, column2
FROM table_name
ORDER BY column1 ASC;
```

**Key Points:**

- `ORDER BY` is the only reliable way to guarantee row order — without it, SQLite may return rows in any order, including insertion order, but this is not guaranteed
- `ASC` (ascending) is the default and can be omitted
- `ORDER BY` is evaluated after `WHERE`, `GROUP BY`, and `HAVING`, but before `LIMIT` and `OFFSET`
- Applies to `SELECT` statements only — not directly to `UPDATE` or `DELETE` unless compiled with `SQLITE_ENABLE_UPDATE_DELETE_LIMIT`

---

### ASC and DESC

```sql
-- Ascending (default): lowest to highest
SELECT name, salary FROM employees ORDER BY salary ASC;

-- Descending: highest to lowest
SELECT name, salary FROM employees ORDER BY salary DESC;
```

**Output (DESC):**

```
David  | 101000.0
Alice  | 95000.0
Bob    | 72000.0
Carol  | 68000.0
```

---

### Sorting by Multiple Columns

Columns are sorted left to right — the second column breaks ties in the first.

```sql
SELECT name, dept, salary
FROM employees
ORDER BY dept ASC, salary DESC;
```

**Output:**

```
Carol  | Design      | 68000.0
Alice  | Engineering | 95000.0
David  | Engineering | 101000.0
Bob    | Marketing   | 72000.0
```

**Key Points:**

- Each column in the list can have its own `ASC` or `DESC` direction
- Tie-breaking continues left to right through the column list
- Any number of columns can be listed — [Inference] performance cost increases with each additional sort column on large unsorted datasets

---

### Sorting by Column Position

Columns can be referenced by their position in the `SELECT` list.

```sql
SELECT name, dept, salary
FROM employees
ORDER BY 3 DESC, 2 ASC;
-- Equivalent to: ORDER BY salary DESC, dept ASC
```

**Key Points:**

- Positions are 1-based
- Valid SQL but generally discouraged — position references break silently when `SELECT` columns are reordered
- `ORDER BY 0` or a position exceeding the column count produces an error
- Useful for quick ad hoc queries; avoid in production code or stored views

---

### Sorting by Expression

Any expression valid in `SELECT` can appear in `ORDER BY`.

```sql
-- Sort by computed value
SELECT name, salary
FROM employees
ORDER BY salary * 1.10 DESC;

-- Sort by string length
SELECT name FROM employees
ORDER BY LENGTH(name) ASC;

-- Sort by extracted part of a string
SELECT name, hire_date FROM employees
ORDER BY SUBSTR(hire_date, 1, 4) DESC;  -- Sort by year

-- Sort by CASE expression
SELECT name, dept, salary
FROM employees
ORDER BY
    CASE dept
        WHEN 'Engineering' THEN 1
        WHEN 'Design'      THEN 2
        WHEN 'Marketing'   THEN 3
        ELSE                    4
    END ASC,
    salary DESC;
```

**Key Points:**

- Expressions in `ORDER BY` are evaluated per row — [Inference] applying functions to large result sets without an appropriate index increases sort cost; verify with `EXPLAIN QUERY PLAN`
- The `CASE` pattern above implements a custom sort order — rows are ordered by department priority, then by salary within each department

---

### Sorting by Column Alias

Aliases defined in `SELECT` are available in `ORDER BY`.

```sql
SELECT name, salary * 1.10 AS adjusted_salary
FROM employees
ORDER BY adjusted_salary DESC;
```

**Key Points:**

- SQLite resolves aliases in `ORDER BY` — this is consistent behavior in SQLite but is an extension beyond strict SQL standard in some contexts
- Avoids repeating the expression in both `SELECT` and `ORDER BY`
- Aliases are **not** available in `WHERE` or `HAVING` — only in `ORDER BY`

---

### NULL Ordering

In SQLite, `NULL` values have a defined sort position relative to non-NULL values.

```sql
SELECT name, dept FROM employees ORDER BY dept ASC;
```

|Sort Direction|NULL Position|
|---|---|
|`ASC`|NULLs appear **first** (before all non-NULL values)|
|`DESC`|NULLs appear **last** (after all non-NULL values)|

**Key Points:**

- This is SQLite-specific behavior — other databases (PostgreSQL, Oracle) default to `NULLS LAST` for `ASC`; portability requires explicit handling
- SQLite does not support `NULLS FIRST` / `NULLS LAST` syntax directly (unlike PostgreSQL)
- To control NULL position explicitly, use a `CASE` expression:

```sql
-- Force NULLs to sort last in ASC order
SELECT name, dept
FROM employees
ORDER BY
    CASE WHEN dept IS NULL THEN 1 ELSE 0 END ASC,
    dept ASC;

-- Force NULLs to sort first in DESC order
SELECT name, dept
FROM employees
ORDER BY
    CASE WHEN dept IS NULL THEN 0 ELSE 1 END ASC,
    dept DESC;
```

---

### Sorting Text — Collation

SQLite sorts text using collation sequences that define character comparison rules.

#### Built-in Collations

|Collation|Behavior|
|---|---|
|`BINARY`|Byte-by-byte comparison; case-sensitive; default|
|`NOCASE`|Case-insensitive for ASCII A–Z; Unicode not covered|
|`RTRIM`|Ignores trailing whitespace; otherwise binary|

```sql
-- Case-insensitive sort
SELECT name FROM employees ORDER BY name COLLATE NOCASE ASC;

-- Binary (default): uppercase before lowercase in ASCII order
SELECT name FROM employees ORDER BY name COLLATE BINARY ASC;
```

**Key Points:**

- Without `COLLATE`, the column's defined collation is used — default is `BINARY`
- `NOCASE` only covers ASCII A–Z — [Unverified] behavior for accented or non-Latin characters depends on the SQLite build; ICU extension may be needed for full Unicode collation
- Collation can be specified per `ORDER BY` column, overriding the column's default:

```sql
SELECT name FROM employees
ORDER BY name COLLATE NOCASE ASC, dept COLLATE BINARY DESC;
```

#### Collation on Column Definition

```sql
CREATE TABLE employees (
    name TEXT COLLATE NOCASE,
    dept TEXT
);

-- Uses NOCASE automatically (defined on column)
SELECT * FROM employees ORDER BY name;
```

**Key Points:**

- Column-level collation applies automatically in `ORDER BY`, `WHERE`, and comparisons unless overridden
- Overriding in `ORDER BY` does not change the column's stored collation

---

### Sorting with LIMIT and OFFSET

`ORDER BY` is essential when using `LIMIT` — without it, the returned subset is arbitrary.

```sql
-- Top 5 earners
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 5;

-- Rows 6–10
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 5 OFFSET 5;
```

**Key Points:**

- `LIMIT` without `ORDER BY` returns an unpredictable subset
- `OFFSET` requires a full sort and scan of all preceding rows — [Inference] large offsets on big tables are slow; keyset pagination is more efficient for deep paging:

```sql
-- Keyset pagination: faster than large OFFSET
SELECT name, salary
FROM employees
WHERE salary < :last_salary
   OR (salary = :last_salary AND name > :last_name)
ORDER BY salary DESC, name ASC
LIMIT 10;
```

**Key Points on keyset pagination:**

- Requires a stable, unique sort key (or combination) to define the page boundary
- [Inference] Performance advantage grows as the offset deepens — avoids scanning and discarding rows; behavior depends on index availability

---

### Sorting Across Joins

`ORDER BY` applies to the full joined result.

```sql
SELECT e.name, e.salary, d.budget
FROM employees e
JOIN departments d ON e.dept = d.name
ORDER BY d.budget DESC, e.salary DESC;
```

**Key Points:**

- Any column from any joined table is available in `ORDER BY`
- Qualify column names with table aliases when ambiguity exists
- [Inference] Sort performance depends on whether the sort column is indexed and whether the join result is small enough to sort in memory

---

### Sorting in Subqueries and CTEs

`ORDER BY` in a subquery or CTE does not guarantee order in the outer query.

```sql
-- ORDER BY in subquery has no guaranteed effect on outer result
SELECT * FROM (
    SELECT name, salary FROM employees ORDER BY salary DESC
) sub;
```

**Key Points:**

- SQLite may or may not preserve inner sort order in the outer query — [Inference] this is implementation-dependent and should not be relied upon; always apply `ORDER BY` at the outermost level where order matters
- This is standard SQL behavior — subquery row order is undefined unless the outer query sorts

```sql
-- Correct: sort at the outermost level
SELECT * FROM (
    SELECT name, salary FROM employees WHERE dept = 'Engineering'
) sub
ORDER BY salary DESC;
```

---

### Sorting with DISTINCT

When `DISTINCT` and `ORDER BY` are combined, `ORDER BY` columns must appear in the `SELECT` list.

```sql
-- Valid
SELECT DISTINCT dept FROM employees ORDER BY dept ASC;

-- Invalid in strict mode — salary not in SELECT
SELECT DISTINCT dept FROM employees ORDER BY salary ASC;
```

**Key Points:**

- SQLite may permit ordering by a column not in `SELECT DISTINCT` in some cases — [Inference] this behavior is not guaranteed and may differ across versions; include sort columns in `SELECT` for reliable results
- When `DISTINCT` is present, the sort is applied to the deduplicated result

---

### Sorting with Aggregates and GROUP BY

`ORDER BY` on aggregated queries sorts the grouped result.

```sql
SELECT dept, COUNT(*) AS headcount, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept
ORDER BY avg_salary DESC;
```

```sql
-- Order by aggregate not in SELECT
SELECT dept, COUNT(*) AS headcount
FROM employees
GROUP BY dept
ORDER BY AVG(salary) DESC;
```

**Key Points:**

- Aggregate functions can appear in `ORDER BY` even if not in `SELECT`
- `ORDER BY` is applied after `GROUP BY` and `HAVING`
- Aliases defined in `SELECT` (e.g., `avg_salary`) are available in `ORDER BY`

---

### Stable Sort Behavior

SQLite's sort is not guaranteed to be stable across all versions and configurations.

**Key Points:**

- A stable sort preserves the relative order of rows with equal sort keys
- [Inference] SQLite's sort algorithm may be stable in practice for small result sets but this should not be relied upon — if tie-breaking order matters, include a unique column (e.g., `id`) as the final sort key:

```sql
SELECT name, dept, salary
FROM employees
ORDER BY dept ASC, salary DESC, id ASC;
```

- Adding `id ASC` as the final tiebreaker makes the sort deterministic regardless of internal algorithm behavior

---

### Index Use in ORDER BY

SQLite can use an index to satisfy `ORDER BY` without a separate sort step.

```sql
CREATE INDEX idx_salary ON employees (salary);

-- May use idx_salary to return rows in order without sorting
SELECT name, salary FROM employees ORDER BY salary ASC;
```

**Key Points:**

- When an index covers the sort column(s) in the correct direction, SQLite may scan the index in order — [Inference] eliminates the need for an explicit sort step, which can significantly improve performance on large tables; verify with `EXPLAIN QUERY PLAN`
- Look for `SCAN employees USING INDEX` in the query plan output
- A covering index (includes all `SELECT` columns) further avoids table lookups:

```sql
CREATE INDEX idx_salary_name ON employees (salary, name);

-- Potentially a covering index scan — no table access needed
SELECT name, salary FROM employees ORDER BY salary ASC;
```

- Composite indexes must match the `ORDER BY` column order and direction to be usable — [Inference] an index on `(dept ASC, salary DESC)` may not be used for `ORDER BY dept DESC, salary ASC`; test with `EXPLAIN QUERY PLAN`

---

### EXPLAIN QUERY PLAN for ORDER BY

```sql
EXPLAIN QUERY PLAN
SELECT name, salary FROM employees ORDER BY salary DESC;
```

**Output indicators:**

```
SCAN employees
USE TEMP B-TREE FOR ORDER BY   ← sort performed in memory/temp
```

vs.

```
SCAN employees USING INDEX idx_salary   ← index used; no sort needed
```

**Key Points:**

- `USE TEMP B-TREE FOR ORDER BY` indicates a sort is happening — may be acceptable for small tables, but worth addressing with an index for large ones
- `USING INDEX` in the plan indicates the index is being used for ordering
- [Inference] Index-based ordering avoids materializing and sorting the full result set — likely faster for large tables with selective queries; actual gains depend on row count and hardware

---

### ORDER BY Reference Summary

|Feature|Syntax|Notes|
|---|---|---|
|Ascending|`ORDER BY col ASC`|Default; ASC optional|
|Descending|`ORDER BY col DESC`||
|Multiple columns|`ORDER BY col1 ASC, col2 DESC`|Left to right priority|
|By position|`ORDER BY 2 DESC`|1-based; fragile|
|By alias|`ORDER BY alias DESC`|Alias must be in SELECT|
|By expression|`ORDER BY LENGTH(name)`|Evaluated per row|
|Custom order|`ORDER BY CASE ... END`|Manual priority mapping|
|Collation|`ORDER BY col COLLATE NOCASE`|Overrides column default|
|NULL control|`ORDER BY CASE WHEN col IS NULL ...`|SQLite lacks NULLS FIRST/LAST|
|With LIMIT|`ORDER BY col LIMIT n`|Required for deterministic paging|
|Tiebreaker|`ORDER BY col, id ASC`|Ensures deterministic output|

---

**Conclusion:** `ORDER BY` in SQLite is flexible — supporting column names, aliases, positions, expressions, `CASE` logic, and collation overrides. Key behaviors to internalize: row order without `ORDER BY` is undefined; NULL sort position differs from most other databases; subquery sort order does not propagate to outer queries; and index-backed sorting avoids the `USE TEMP B-TREE` cost for large datasets. For deterministic results, always include a unique tiebreaker as the final sort column.

**Next Steps:**

- LIMIT and OFFSET — pagination patterns
- Indexes — covering indexes and sort optimization
- GROUP BY and aggregate sorting
- EXPLAIN QUERY PLAN in depth

---

## LIMIT and OFFSET for Pagination in SQLite

---

### Purpose

`LIMIT` restricts how many rows a query returns. `OFFSET` skips a number of rows before returning results. Together they are the foundation of offset-based pagination.

```sql
SELECT column1, column2
FROM table_name
ORDER BY column1
LIMIT n OFFSET m;
```

**Key Points:**

- `LIMIT` and `OFFSET` are evaluated last in the logical processing order — after `WHERE`, `GROUP BY`, `HAVING`, `SELECT`, `DISTINCT`, and `ORDER BY`
- `ORDER BY` is required for pagination to be deterministic — without it, the rows returned per page are undefined
- Both accept integer expressions or bound parameters — negative values for `LIMIT` are treated as no limit in SQLite; negative `OFFSET` produces an error in most contexts

---

### LIMIT

Returns at most N rows.

```sql
-- Return first 10 rows by salary
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 10;
```

**Key Points:**

- Returns fewer than N rows if the result set contains fewer
- `LIMIT 0` returns no rows — valid; occasionally useful for checking query structure without fetching data
- `LIMIT -1` returns all rows — SQLite-specific behavior; not portable

---

### OFFSET

Skips M rows before returning results.

```sql
-- Skip first 10 rows, return next 10
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 10 OFFSET 10;
```

**Key Points:**

- `OFFSET 0` is the same as no offset
- Offset is zero-based — `OFFSET 10` skips rows 1 through 10 and returns from row 11
- `OFFSET` without `LIMIT` is not valid in SQLite — `LIMIT` must be present

---

### Comma Syntax (Alternative Form)

SQLite supports a legacy two-argument `LIMIT` form.

```sql
-- LIMIT offset, count  (comma syntax)
SELECT name, salary FROM employees ORDER BY salary DESC LIMIT 10, 10;
-- Equivalent to: LIMIT 10 OFFSET 10
```

**Key Points:**

- Argument order is `offset, count` — the **opposite** of the `LIMIT count OFFSET offset` form
- [Inference] This is a common source of errors — the keyword form (`LIMIT n OFFSET m`) is clearer and less error-prone
- Comma syntax is a SQLite/MySQL convention — not standard SQL; avoid if portability matters

---

### Basic Pagination Pattern

Page size of 10, navigating through pages.

```sql
-- Page 1 (rows 1–10)
SELECT name, dept, salary FROM employees
ORDER BY id ASC
LIMIT 10 OFFSET 0;

-- Page 2 (rows 11–20)
SELECT name, dept, salary FROM employees
ORDER BY id ASC
LIMIT 10 OFFSET 10;

-- Page 3 (rows 21–30)
SELECT name, dept, salary FROM employees
ORDER BY id ASC
LIMIT 10 OFFSET 20;
```

**Formula:**

```
OFFSET = (page_number - 1) * page_size
```

**Parameterized form:**

```sql
SELECT name, dept, salary FROM employees
ORDER BY id ASC
LIMIT :page_size OFFSET :offset;
```

```python
page_size = 10
page_number = 3
offset = (page_number - 1) * page_size

conn.execute(
    'SELECT name, dept, salary FROM employees ORDER BY id ASC LIMIT ? OFFSET ?',
    (page_size, offset)
)
```

---

### Getting Total Row Count for Pagination

To compute total pages, a separate count query is needed.

```sql
SELECT COUNT(*) AS total FROM employees WHERE dept = 'Engineering';
```

```python
total = conn.execute(
    'SELECT COUNT(*) FROM employees WHERE dept = ?', ('Engineering',)
).fetchone()[0]

total_pages = (total + page_size - 1) // page_size  # ceiling division
```

**Key Points:**

- The `COUNT(*)` query must use the same `WHERE` conditions as the data query
- [Inference] Running two queries (count + data) per page request is the standard approach — there is no single SQLite statement that returns both the count and the page simultaneously
- For large tables with complex `WHERE` clauses, the count query may be slow — caching the count or using approximate counts may be appropriate depending on use case

---

### The OFFSET Performance Problem

`OFFSET` works by scanning and discarding rows up to the offset value.

```sql
-- SQLite scans and discards 90,000 rows, then returns 10
SELECT name, salary FROM employees
ORDER BY salary DESC
LIMIT 10 OFFSET 90000;
```

**Key Points:**

- SQLite does not jump directly to the offset position — it reads through all preceding rows
- [Inference] Query time increases approximately linearly with offset size for unsorted or unindexed data; on indexed sorts the cost may be lower but is still present
- For small tables or modest page depths, offset pagination is typically acceptable
- For large tables or deep pages, keyset pagination is the recommended alternative

---

### Keyset Pagination (Seek Method)

Instead of skipping rows, keyset pagination filters from the last seen value.

#### Simple keyset on a unique column:

```sql
-- First page
SELECT id, name, salary
FROM employees
ORDER BY id ASC
LIMIT 10;

-- Next page: pass the last seen id from the previous page
SELECT id, name, salary
FROM employees
WHERE id > :last_id
ORDER BY id ASC
LIMIT 10;
```

**Key Points:**

- No rows are scanned and discarded — the `WHERE` clause jumps directly to the next set
- [Inference] Requires an index on the sort/filter column — without one, performance may not improve over offset; verify with `EXPLAIN QUERY PLAN`
- Does not support arbitrary page jumps — only sequential forward (and, with modification, backward) navigation
- The sort column must be unique, or a composite tiebreaker must be added to ensure stable page boundaries

---

### Keyset Pagination with Non-Unique Sort Column

When sorting by a non-unique column (e.g., `salary`), ties must be broken with a unique column.

```sql
-- First page
SELECT id, name, salary
FROM employees
ORDER BY salary DESC, id ASC
LIMIT 10;

-- Next page: use both last_salary and last_id as the boundary
SELECT id, name, salary
FROM employees
WHERE salary < :last_salary
   OR (salary = :last_salary AND id > :last_id)
ORDER BY salary DESC, id ASC
LIMIT 10;
```

**Key Points:**

- The `OR` condition handles rows with the same salary as the last row on the previous page
- Both conditions together define an unambiguous page boundary
- [Inference] The `OR` may limit index use on some query planners — an alternative using a composite key or row value comparison may be more index-friendly; verify with `EXPLAIN QUERY PLAN`
- Cannot jump to an arbitrary page by number — keyset pagination is inherently sequential

---

### Keyset Pagination — Backward Navigation

```sql
-- Previous page: reverse the comparison and sort, then re-reverse the result
SELECT id, name, salary FROM (
    SELECT id, name, salary
    FROM employees
    WHERE salary > :last_salary
       OR (salary = :last_salary AND id < :last_id)
    ORDER BY salary ASC, id DESC
    LIMIT 10
) sub
ORDER BY salary DESC, id ASC;
```

**Key Points:**

- Reverses the sort direction in the inner query to collect the preceding page
- The outer query re-applies the original sort order for consistent presentation
- [Inference] More complex to implement and test than forward-only pagination — ensure boundary conditions are covered in testing

---

### Offset vs. Keyset Comparison

|Characteristic|Offset Pagination|Keyset Pagination|
|---|---|---|
|Arbitrary page jump|✅ Supported|❌ Sequential only|
|Performance at depth|Degrades with offset|Consistent|
|Implementation complexity|Simple|Moderate|
|Requires unique sort key|No|Yes (or composite)|
|Row skip on insert/delete|✅ Can occur|❌ Stable boundaries|
|Index dependency|Optional|Required for performance|
|Total page count|Easy (COUNT query)|Requires separate count|

---

### Row Skipping and Duplication with Offset

A known hazard of offset pagination: concurrent inserts or deletes shift row positions.

```sql
-- Page 1 returns rows 1–10
-- A new row is inserted at position 5 before page 2 is fetched
-- Page 2 (OFFSET 10) now starts at what was row 11 — row 10 is skipped
```

**Key Points:**

- Row insertion before the current offset causes a row to be skipped on the next page
- Row deletion before the current offset causes a row to be duplicated (seen on two pages)
- [Inference] In read-heavy or static datasets this is rarely a problem — in high-write environments it is a significant hazard
- Keyset pagination is not affected by this problem — the `WHERE` clause anchors to values, not positions

---

### LIMIT in Subqueries

`LIMIT` inside a subquery restricts the subquery's result independently.

```sql
-- Get the top 3 earners per department
SELECT e.name, e.dept, e.salary
FROM employees e
WHERE e.id IN (
    SELECT id FROM employees
    WHERE dept = e.dept
    ORDER BY salary DESC
    LIMIT 3
);
```

**Key Points:**

- `LIMIT` in a correlated subquery applies per outer row evaluation — [Inference] may be slow on large tables; a window function (`ROW_NUMBER()`) is often more efficient for top-N-per-group queries in SQLite 3.25.0+
- `LIMIT` in a non-correlated subquery limits the subquery result set once

```sql
-- Limit source rows for an INSERT
INSERT INTO top_earners (name, salary)
SELECT name, salary FROM employees
ORDER BY salary DESC
LIMIT 10;
```

---

### LIMIT with Aggregate Queries

```sql
-- Top 3 departments by average salary
SELECT dept, AVG(salary) AS avg_sal
FROM employees
GROUP BY dept
ORDER BY avg_sal DESC
LIMIT 3;
```

**Key Points:**

- `LIMIT` applies to the grouped result — after `GROUP BY` and `HAVING`
- Useful for top-N group queries

---

### Window Function Alternative for Top-N

For top-N rows per group, `ROW_NUMBER()` is cleaner than correlated subqueries with `LIMIT`. Requires SQLite 3.25.0+.

```sql
SELECT name, dept, salary
FROM (
    SELECT
        name, dept, salary,
        ROW_NUMBER() OVER (
            PARTITION BY dept ORDER BY salary DESC
        ) AS rn
    FROM employees
)
WHERE rn <= 3;
```

**Key Points:**

- Assigns a sequential number within each department partition, ordered by salary
- Outer `WHERE rn <= 3` returns only the top 3 per department
- [Inference] Generally more efficient than a correlated subquery with `LIMIT` for this pattern — avoids re-scanning the table per department; verify with `EXPLAIN QUERY PLAN`
- Requires SQLite 3.25.0+ — verify with `SELECT SQLITE_VERSION();`

---

### Using LIMIT for Existence Checks

`LIMIT 1` is an efficient pattern for checking whether any row matches a condition.

```sql
-- Check if any engineer earns above 100k
SELECT 1 FROM employees
WHERE dept = 'Engineering' AND salary > 100000
LIMIT 1;
```

```python
exists = conn.execute(
    'SELECT 1 FROM employees WHERE dept = ? AND salary > ? LIMIT 1',
    ('Engineering', 100000)
).fetchone() is not None
```

**Key Points:**

- Returns at most one row — SQLite stops scanning after finding the first match
- [Inference] More efficient than `COUNT(*) > 0` for existence checks — avoids counting all matching rows; actual difference depends on indexes and data distribution
- `EXISTS (SELECT 1 ...)` in a subquery context achieves the same effect

---

### LIMIT 0 — Schema Inspection Without Data

```sql
SELECT * FROM employees LIMIT 0;
```

**Key Points:**

- Returns no rows but provides column metadata (names and types) via the cursor
- Useful in application code to inspect result shape without fetching data:

```python
cursor = conn.execute('SELECT * FROM employees LIMIT 0')
columns = [desc[0] for desc in cursor.description]
```

---

### Parameterized LIMIT and OFFSET

Always use parameters when `LIMIT` and `OFFSET` values come from user input.

```python
# Safe: parameterized
conn.execute(
    'SELECT * FROM employees ORDER BY id LIMIT ? OFFSET ?',
    (page_size, offset)
)

# Unsafe: string interpolation — avoid
conn.execute(
    f'SELECT * FROM employees ORDER BY id LIMIT {page_size} OFFSET {offset}'
)
```

**Key Points:**

- [Inference] SQLite parameters for `LIMIT` and `OFFSET` accept integer values — passing non-integer types may cause errors or unexpected behavior depending on the driver; validate input before binding
- String interpolation of user-supplied values introduces SQL injection risk even for numeric inputs — parameterization is always safer

---

### Pagination with Filtering and Sorting

Real pagination queries combine `WHERE`, `ORDER BY`, `LIMIT`, and `OFFSET`.

```sql
SELECT id, name, dept, salary
FROM employees
WHERE dept = :dept
  AND salary >= :min_salary
ORDER BY salary DESC, id ASC
LIMIT :page_size OFFSET :offset;
```

```python
def get_page(conn, dept, min_salary, page_number, page_size=10):
    offset = (page_number - 1) * page_size
    rows = conn.execute(
        '''
        SELECT id, name, dept, salary
        FROM employees
        WHERE dept = ? AND salary >= ?
        ORDER BY salary DESC, id ASC
        LIMIT ? OFFSET ?
        ''',
        (dept, min_salary, page_size, offset)
    ).fetchall()
    return rows
```

**Key Points:**

- The `id ASC` tiebreaker ensures deterministic ordering when salaries are equal
- All filter parameters are bound — avoids injection risk
- The same `WHERE` clause should be used in a companion `COUNT(*)` query for total page calculation

---

### Index Support for LIMIT Queries

An index on the `ORDER BY` column(s) allows SQLite to stop scanning early when `LIMIT` is small.

```sql
CREATE INDEX idx_salary_id ON employees (salary DESC, id ASC);

-- With LIMIT, SQLite reads only as many index entries as needed
SELECT id, name, salary
FROM employees
ORDER BY salary DESC, id ASC
LIMIT 10;
```

**Key Points:**

- Without an index, SQLite sorts the entire result set then returns the first N rows
- With a matching index, SQLite reads only the first N entries from the index — [Inference] dramatically faster for small `LIMIT` values on large tables; verify with `EXPLAIN QUERY PLAN`
- The index direction (`DESC`/`ASC`) should match the `ORDER BY` direction for optimal use
- Look for absence of `USE TEMP B-TREE FOR ORDER BY` in `EXPLAIN QUERY PLAN` output as confirmation

```sql
EXPLAIN QUERY PLAN
SELECT id, name, salary FROM employees
ORDER BY salary DESC, id ASC
LIMIT 10;
```

**Good output:**

```
SCAN employees USING INDEX idx_salary_id
```

**Output indicating a sort step:**

```
SCAN employees
USE TEMP B-TREE FOR ORDER BY
```

---

### LIMIT and OFFSET in CTEs

```sql
WITH ranked AS (
    SELECT id, name, dept, salary
    FROM employees
    WHERE dept = 'Engineering'
    ORDER BY salary DESC
    LIMIT 10 OFFSET 0
)
SELECT * FROM ranked;
```

**Key Points:**

- `LIMIT` and `OFFSET` inside a CTE apply to the CTE's result independently
- [Inference] The outer query cannot further rely on the CTE's internal order — apply `ORDER BY` in the outer query if order of the final result matters
- CTEs with `LIMIT` are useful for pre-filtering large tables before joining or further processing

---

### Common LIMIT / OFFSET Mistakes

#### Missing ORDER BY:

```sql
-- Non-deterministic — different pages may return overlapping or missing rows
SELECT * FROM employees LIMIT 10 OFFSET 10;

-- Correct
SELECT * FROM employees ORDER BY id ASC LIMIT 10 OFFSET 10;
```

#### Confusing comma syntax argument order:

```sql
-- Returns 20 rows starting at offset 10 — NOT 10 rows at offset 20
SELECT * FROM employees ORDER BY id LIMIT 10, 20;

-- Clearer equivalent
SELECT * FROM employees ORDER BY id LIMIT 20 OFFSET 10;
```

#### Offset pagination on a volatile table:

```sql
-- Rows inserted or deleted between page requests shift positions
-- Use keyset pagination for write-heavy tables
```

#### Not filtering NULL in sort column for keyset:

```sql
-- If salary can be NULL, boundary comparison may behave unexpectedly
WHERE salary < :last_salary  -- NULL salaries excluded unpredictably

-- Safer: exclude NULLs or handle explicitly
WHERE salary < :last_salary AND salary IS NOT NULL
```

---

### Quick Reference

```sql
-- First N rows
SELECT ... ORDER BY col LIMIT N;

-- Page P with page size N (1-based page number)
SELECT ... ORDER BY col LIMIT N OFFSET (P - 1) * N;

-- Existence check
SELECT 1 FROM ... WHERE ... LIMIT 1;

-- Top N per group (window function)
SELECT ... FROM (
    SELECT ..., ROW_NUMBER() OVER (PARTITION BY group_col ORDER BY sort_col DESC) AS rn
    FROM ...
) WHERE rn <= N;

-- Keyset next page
SELECT ... FROM ... WHERE sort_col < :last_val ORDER BY sort_col DESC LIMIT N;

-- Schema inspection, no data
SELECT * FROM table LIMIT 0;
```

---

**Conclusion:** `LIMIT` and `OFFSET` cover most pagination needs in SQLite, but carry a well-known performance cost at depth and a data consistency hazard in write-heavy environments. For small tables or shallow pagination, offset-based pagination is straightforward and acceptable. For large datasets, deep pages, or high-write scenarios, keyset pagination provides consistent performance and stable boundaries. Regardless of approach, `ORDER BY` with a unique tiebreaker is required for reliable results, and an index on the sort column is the most impactful performance optimization.

**Next Steps:**

- Window functions — ROW_NUMBER, RANK, DENSE_RANK
- Indexes — covering indexes for sort and pagination queries
- Query optimization and EXPLAIN QUERY PLAN
- Joins and filtered pagination across multiple tables

---

## Aggregate Functions in SQLite

---

### What Aggregate Functions Do

Aggregate functions compute a single result from a set of rows. They collapse multiple values into one — a count, total, average, or boundary value.

```sql
SELECT COUNT(*), SUM(salary), AVG(salary), MIN(salary), MAX(salary)
FROM employees;
```

**Key Points:**

- Aggregate functions operate on a set of rows — the entire table, or a group defined by `GROUP BY`
- They appear in `SELECT` and `HAVING` clauses — not directly in `WHERE` (aggregates are not yet computed at that stage)
- All built-in aggregates ignore `NULL` values except `COUNT(*)`
- When no rows match the query, `COUNT(*)` returns `0`; all other aggregates return `NULL`

---

### COUNT

Returns the number of rows or non-NULL values in a set.

#### COUNT(*)

```sql
-- Total rows in the table
SELECT COUNT(*) FROM employees;

-- Total rows matching a condition
SELECT COUNT(*) FROM employees WHERE dept = 'Engineering';
```

**Key Points:**

- Counts every row regardless of NULL values in any column
- The fastest form for row counting — does not evaluate column values
- Returns `0` when no rows match — never returns `NULL`

#### COUNT(column)

```sql
-- Count rows where dept is not NULL
SELECT COUNT(dept) FROM employees;
```

**Key Points:**

- Ignores `NULL` values in the specified column
- `COUNT(dept)` < `COUNT(*)` when `dept` contains NULLs
- Useful for counting how many rows have a value in a specific column

#### COUNT(DISTINCT column)

```sql
-- Count unique departments
SELECT COUNT(DISTINCT dept) FROM employees;
```

**Key Points:**

- Counts distinct non-NULL values
- `DISTINCT` applies only within the aggregate — does not affect other columns in the `SELECT`
- [Inference] May be slower than `COUNT(*)` on large tables without an index on the column — verify with `EXPLAIN QUERY PLAN`

#### COUNT Comparison Example

```sql
SELECT
    COUNT(*)           AS total_rows,
    COUNT(dept)        AS rows_with_dept,
    COUNT(DISTINCT dept) AS unique_depts
FROM employees;
```

**Output:**

```
total_rows | rows_with_dept | unique_depts
10         | 8              | 4
```

---

### SUM

Returns the total of all non-NULL values in a numeric column.

```sql
SELECT SUM(salary) FROM employees;

SELECT SUM(salary) FROM employees WHERE dept = 'Engineering';
```

**Key Points:**

- Returns `NULL` if all values in the set are `NULL` or the set is empty
- Use `COALESCE(SUM(col), 0)` to return `0` instead of `NULL` when needed:

```sql
SELECT COALESCE(SUM(salary), 0) AS total_salary FROM employees;
```

- SQLite stores sums as `INTEGER` or `REAL` depending on input types — [Inference] summing large integers may overflow if the result exceeds SQLite's integer range (±2^63); use `CAST` to `REAL` if overflow is a concern

#### SUM with DISTINCT

```sql
-- Sum of unique salary values only
SELECT SUM(DISTINCT salary) FROM employees;
```

**Key Points:**

- Sums each distinct value once — duplicates are excluded
- Rarely used in practice; typically `SUM(DISTINCT ...)` has a specific analytical purpose

---

### AVG

Returns the arithmetic mean of all non-NULL values.

```sql
SELECT AVG(salary) FROM employees;

SELECT AVG(salary) FROM employees WHERE dept = 'Marketing';
```

**Key Points:**

- Returns `NULL` if all values are `NULL` or the set is empty
- Computed as `SUM(col) / COUNT(col)` — only non-NULL values contribute to both numerator and denominator
- Result is always `REAL` in SQLite regardless of input type
- [Inference] Floating-point precision limits apply — results may have minor rounding imprecision for large or fractional values; use `ROUND()` for display:

```sql
SELECT ROUND(AVG(salary), 2) AS avg_salary FROM employees;
```

#### AVG vs Manual Calculation

```sql
-- These produce the same result
SELECT AVG(salary) FROM employees;
SELECT CAST(SUM(salary) AS REAL) / COUNT(salary) FROM employees;
```

**Key Points:**

- Manual calculation makes NULL handling explicit
- `CAST(SUM(...) AS REAL)` avoids integer division when salary is stored as `INTEGER`

---

### MIN

Returns the smallest non-NULL value in the set.

```sql
SELECT MIN(salary) FROM employees;

SELECT MIN(hire_date) FROM employees;  -- Earliest date (ISO format)
```

**Key Points:**

- Returns `NULL` if all values are `NULL` or the set is empty
- Works on numeric, text (lexicographic), and ISO date strings
- For text, comparison is based on the column's collation — default is `BINARY`
- Does not require a sort of the entire result — [Inference] SQLite may use an index to satisfy `MIN` without a full scan; verify with `EXPLAIN QUERY PLAN`

---

### MAX

Returns the largest non-NULL value in the set.

```sql
SELECT MAX(salary) FROM employees;

SELECT MAX(hire_date) FROM employees;  -- Most recent date (ISO format)
```

**Key Points:**

- Returns `NULL` if all values are `NULL` or the set is empty
- Same collation and index behavior as `MIN`
- `MIN` and `MAX` together define the range:

```sql
SELECT MIN(salary) AS floor, MAX(salary) AS ceiling FROM employees;
```

---

### Using Multiple Aggregates Together

```sql
SELECT
    COUNT(*)                    AS headcount,
    COUNT(DISTINCT dept)        AS departments,
    ROUND(AVG(salary), 2)       AS avg_salary,
    SUM(salary)                 AS payroll,
    MIN(salary)                 AS lowest,
    MAX(salary)                 AS highest,
    MAX(salary) - MIN(salary)   AS salary_range
FROM employees;
```

**Output:**

```
headcount | departments | avg_salary | payroll   | lowest  | highest  | salary_range
10        | 4           | 79700.00   | 797000.00 | 52000.0 | 101000.0 | 49000.0
```

---

### GROUP BY with Aggregates

`GROUP BY` partitions rows into groups — aggregates operate on each group independently.

```sql
SELECT dept, COUNT(*) AS headcount, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY dept;
```

**Output:**

```
dept        | headcount | avg_salary
Design      | 2         | 65500.00
Engineering | 3         | 97000.00
HR          | 2         | 61000.00
Marketing   | 3         | 69333.33
```

**Key Points:**

- Every column in `SELECT` must be either in `GROUP BY` or wrapped in an aggregate function
- SQLite is more permissive than standard SQL — it allows non-aggregated, non-grouped columns in `SELECT`, returning an arbitrary value from the group for that column — [Inference] this is a known SQLite quirk; relying on it produces unpredictable results and should be avoided
- `GROUP BY` can reference column aliases defined in `SELECT` in SQLite — [Inference] this is a SQLite extension; not portable to all databases

#### Grouping by Multiple Columns

```sql
SELECT dept, CASE
    WHEN salary >= 90000 THEN 'Senior'
    WHEN salary >= 70000 THEN 'Mid'
    ELSE 'Junior'
END AS level,
COUNT(*) AS headcount
FROM employees
GROUP BY dept, level
ORDER BY dept, level;
```

**Key Points:**

- Groups are defined by the unique combination of all `GROUP BY` columns
- Can group by expressions and `CASE` results, not just column names

---

### HAVING — Filtering Groups

`HAVING` filters groups after aggregation — analogous to `WHERE` for rows.

```sql
-- Departments with more than 2 employees
SELECT dept, COUNT(*) AS headcount
FROM employees
GROUP BY dept
HAVING COUNT(*) > 2;
```

```sql
-- Departments where average salary exceeds 75000
SELECT dept, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY dept
HAVING AVG(salary) > 75000;
```

**Key Points:**

- `HAVING` can reference aggregate functions — `WHERE` cannot
- `HAVING` can reference `SELECT` aliases in SQLite — [Inference] this is SQLite-specific behavior; not guaranteed in other databases
- Non-aggregate conditions are more efficiently placed in `WHERE` (filtered before grouping) than `HAVING` (filtered after):

```sql
-- Efficient: WHERE excludes rows before grouping
SELECT dept, COUNT(*) AS headcount
FROM employees
WHERE salary > 50000        -- Filters rows before GROUP BY
GROUP BY dept
HAVING COUNT(*) > 1;        -- Filters groups after GROUP BY
```

---

### WHERE vs HAVING

```sql
-- WHERE: filters individual rows before aggregation
-- HAVING: filters groups after aggregation

SELECT dept, AVG(salary) AS avg_sal
FROM employees
WHERE hire_date >= '2021-01-01'   -- Exclude rows before grouping
GROUP BY dept
HAVING AVG(salary) > 70000;       -- Exclude groups after aggregation
```

|Clause|When Applied|Can Use Aggregates|Filters|
|---|---|---|---|
|`WHERE`|Before `GROUP BY`|No|Individual rows|
|`HAVING`|After `GROUP BY`|Yes|Groups|

---

### Aggregate Functions with NULL

```sql
-- Setup: one employee with NULL salary
INSERT INTO employees (name, dept, salary) VALUES ('Zara', 'IT', NULL);

SELECT
    COUNT(*)       AS total_rows,     -- Includes Zara
    COUNT(salary)  AS non_null_sal,   -- Excludes Zara
    SUM(salary)    AS total_sal,      -- Excludes Zara's NULL
    AVG(salary)    AS avg_sal,        -- Excludes Zara from both sum and count
    MIN(salary)    AS min_sal,        -- Excludes Zara
    MAX(salary)    AS max_sal         -- Excludes Zara
FROM employees;
```

**Key Points:**

- `COUNT(*)` includes NULLs; all other aggregates exclude them
- `AVG` excluding NULLs means it is not the same as `SUM / COUNT(*)` when NULLs are present:

```sql
-- These differ when salary contains NULLs
SELECT AVG(salary) FROM employees;
SELECT CAST(SUM(salary) AS REAL) / COUNT(*) FROM employees;
```

- To include NULLs as zero in an average:

```sql
SELECT AVG(COALESCE(salary, 0)) FROM employees;
```

---

### Aggregate Functions with DISTINCT

All five aggregates support `DISTINCT`.

```sql
SELECT
    COUNT(DISTINCT dept)    AS unique_depts,
    SUM(DISTINCT salary)    AS sum_unique_salaries,
    AVG(DISTINCT salary)    AS avg_unique_salaries,
    MIN(DISTINCT salary)    AS min_salary,   -- DISTINCT has no effect on MIN
    MAX(DISTINCT salary)    AS max_salary    -- DISTINCT has no effect on MAX
FROM employees;
```

**Key Points:**

- `DISTINCT` is meaningful for `COUNT`, `SUM`, and `AVG` — it changes the result
- `DISTINCT` has no effect on `MIN` or `MAX` — the minimum and maximum are the same whether or not duplicates are removed
- [Inference] `DISTINCT` inside aggregates may increase query cost due to deduplication — assess whether it is actually needed

---

### Conditional Aggregation

Aggregate only rows matching a condition using `CASE` inside the aggregate.

```sql
SELECT
    COUNT(*)                                        AS total,
    COUNT(CASE WHEN dept = 'Engineering' THEN 1 END) AS eng_count,
    SUM(CASE WHEN dept = 'Engineering' THEN salary ELSE 0 END) AS eng_payroll,
    AVG(CASE WHEN salary > 80000 THEN salary END)   AS avg_high_earner_salary
FROM employees;
```

**Key Points:**

- `CASE WHEN condition THEN value END` returns `NULL` when the condition is false — `NULL` is then ignored by the aggregate
- `ELSE 0` in `SUM` treats non-matching rows as zero contributions — useful when you want a sum of zero rather than NULL exclusion
- `ELSE 0` in `COUNT` would count all rows — omit `ELSE` or use `ELSE NULL` to count only matching rows
- This pattern avoids multiple passes or subqueries for multi-condition summaries

#### Pivot-style conditional aggregation:

```sql
SELECT
    SUM(CASE WHEN dept = 'Engineering' THEN salary ELSE 0 END) AS eng_payroll,
    SUM(CASE WHEN dept = 'Marketing'   THEN salary ELSE 0 END) AS mkt_payroll,
    SUM(CASE WHEN dept = 'Design'      THEN salary ELSE 0 END) AS des_payroll,
    SUM(CASE WHEN dept = 'HR'          THEN salary ELSE 0 END) AS hr_payroll
FROM employees;
```

---

### Aggregates in Subqueries

Aggregate results can be used as filter values in outer queries.

```sql
-- Employees earning above the company average
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Employees in departments with above-average headcount
SELECT name, dept
FROM employees
WHERE dept IN (
    SELECT dept FROM employees
    GROUP BY dept
    HAVING COUNT(*) > (SELECT AVG(cnt) FROM (
        SELECT COUNT(*) AS cnt FROM employees GROUP BY dept
    ))
);
```

**Key Points:**

- Scalar aggregate subqueries (returning one value) are the most common form
- Nested subqueries using aggregates are valid but can be difficult to read — CTEs often improve clarity:

```sql
WITH dept_counts AS (
    SELECT dept, COUNT(*) AS cnt FROM employees GROUP BY dept
),
avg_count AS (
    SELECT AVG(cnt) AS avg_cnt FROM dept_counts
)
SELECT e.name, e.dept
FROM employees e
JOIN dept_counts d ON e.dept = d.dept
JOIN avg_count a ON d.cnt > a.avg_cnt;
```

---

### Aggregates with JOINs

```sql
SELECT
    d.name AS dept,
    COUNT(e.id)             AS headcount,
    ROUND(AVG(e.salary), 2) AS avg_salary,
    SUM(e.salary)           AS total_payroll
FROM departments d
LEFT JOIN employees e ON e.dept = d.name
GROUP BY d.name
ORDER BY total_payroll DESC;
```

**Key Points:**

- `LEFT JOIN` includes departments with no employees — their aggregates return `0` for `COUNT(*)` and `NULL` for `SUM`, `AVG`, `MIN`, `MAX`
- `COUNT(e.id)` counts only non-NULL matches — returns `0` for unmatched departments when using `LEFT JOIN`
- `COUNT(*)` would return `1` for unmatched departments (counting the NULL placeholder row) — use `COUNT(column)` with joins for accurate counts

---

### MIN and MAX on Non-Numeric Types

```sql
-- Lexicographic min/max on text
SELECT MIN(name), MAX(name) FROM employees;

-- Earliest and latest dates (ISO format required)
SELECT MIN(hire_date), MAX(hire_date) FROM employees;

-- Works correctly with ISO 8601: YYYY-MM-DD
-- May not work correctly with other date formats stored as TEXT
```

**Key Points:**

- Text comparison uses the column's collation — `BINARY` by default (byte order)
- ISO 8601 dates stored as `TEXT` sort and compare correctly because the format is lexicographically ordered
- Non-ISO date formats (e.g., `MM/DD/YYYY`) do not sort correctly with `MIN`/`MAX` or `ORDER BY`

---

### GROUP BY with ROLLUP (Not Supported)

SQLite does not support `GROUP BY ... WITH ROLLUP` or `GROUPING SETS`.

```sql
-- Not supported in SQLite
SELECT dept, COUNT(*) FROM employees GROUP BY dept WITH ROLLUP;
```

**Workaround using UNION ALL:**

```sql
SELECT dept, COUNT(*) AS headcount
FROM employees
GROUP BY dept

UNION ALL

SELECT 'TOTAL', COUNT(*)
FROM employees;
```

**Output:**

```
Design      | 2
Engineering | 3
HR          | 2
Marketing   | 3
TOTAL       | 10
```

**Key Points:**

- `UNION ALL` appends the total row without deduplication
- [Inference] More verbose than `ROLLUP` but achieves the same result for simple totals — for multi-level subtotals, multiple `UNION ALL` blocks are needed
- Window functions can also produce running totals and subtotals without `ROLLUP`

---

### Performance Considerations

**Key Points:**

- `COUNT(*)` on a table without a `WHERE` clause may use the table's B-tree metadata rather than scanning all rows in some configurations — [Unverified] actual behavior depends on SQLite version and query context; do not assume it is always a metadata-only operation
- `MIN` and `MAX` on an indexed column can be resolved by reading the first or last index entry — [Inference] significantly faster than a full scan when an index exists; verify with `EXPLAIN QUERY PLAN`
- `GROUP BY` without an index on the grouping column may require sorting or hashing the full result set — [Inference] an index on the `GROUP BY` column can reduce this cost; assess with `EXPLAIN QUERY PLAN`
- Conditional aggregation (`CASE` inside aggregate) requires only one table pass — [Inference] more efficient than multiple filtered queries for the same data

```sql
-- One pass
SELECT
    SUM(CASE WHEN dept = 'Engineering' THEN 1 ELSE 0 END),
    SUM(CASE WHEN dept = 'Marketing'   THEN 1 ELSE 0 END)
FROM employees;

-- Two passes — less efficient
SELECT COUNT(*) FROM employees WHERE dept = 'Engineering';
SELECT COUNT(*) FROM employees WHERE dept = 'Marketing';
```

---

### Aggregate Function Reference

|Function|Returns|Ignores NULL|Empty Set Result|
|---|---|---|---|
|`COUNT(*)`|Row count|No|`0`|
|`COUNT(col)`|Non-NULL count|Yes|`0`|
|`COUNT(DISTINCT col)`|Distinct non-NULL count|Yes|`0`|
|`SUM(col)`|Total|Yes|`NULL`|
|`AVG(col)`|Mean|Yes|`NULL`|
|`MIN(col)`|Smallest value|Yes|`NULL`|
|`MAX(col)`|Largest value|Yes|`NULL`|

---

**Conclusion:** SQLite's five core aggregate functions cover the most common data summarization needs. The critical behaviors to internalize are: all aggregates except `COUNT(*)` ignore `NULL`; `GROUP BY` partitions the set before aggregation; `HAVING` filters groups after aggregation while `WHERE` filters rows before; and conditional aggregation with `CASE` enables multi-condition summaries in a single pass. For performance-sensitive queries, indexes on `GROUP BY` columns and sort columns used with `MIN`/`MAX` are the most impactful optimizations.

**Next Steps:**

- GROUP BY in depth — multi-column grouping, grouping expressions
- Window functions — running totals, rankings, moving averages
- Subqueries and CTEs for complex aggregation
- EXPLAIN QUERY PLAN for aggregate query optimization

---
