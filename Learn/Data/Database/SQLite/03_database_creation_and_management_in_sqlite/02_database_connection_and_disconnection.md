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

