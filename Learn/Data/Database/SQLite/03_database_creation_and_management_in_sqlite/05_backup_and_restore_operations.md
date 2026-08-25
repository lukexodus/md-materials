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

