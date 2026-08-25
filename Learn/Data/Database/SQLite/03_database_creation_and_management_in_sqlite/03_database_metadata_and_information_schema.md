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

