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

