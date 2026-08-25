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

