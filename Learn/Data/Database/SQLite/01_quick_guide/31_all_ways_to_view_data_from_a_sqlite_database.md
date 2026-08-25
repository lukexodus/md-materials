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

