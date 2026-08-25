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

