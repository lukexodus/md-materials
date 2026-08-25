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

