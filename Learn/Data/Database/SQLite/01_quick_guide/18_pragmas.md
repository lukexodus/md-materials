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

