## SQL Database Connectivity


Go's database connectivity model uses a driver-based architecture where database-specific drivers implement standardized interfaces defined in the `database/sql` package. This design provides database portability while maintaining type safety and performance.

**Driver Architecture** The `database/sql` package defines interfaces that database drivers must implement:

- `driver.Driver` - main driver interface
- `driver.Conn` - database connection interface
- `driver.Stmt` - prepared statement interface
- `driver.Tx` - transaction interface
- `driver.Rows` - result set interface

**Popular Database Drivers**

- PostgreSQL: `github.com/lib/pq`, `github.com/jackc/pgx`
- MySQL: `github.com/go-sql-driver/mysql`
- SQLite: `github.com/mattn/go-sqlite3`, `modernc.org/sqlite`
- SQL Server: `github.com/denisenkom/go-mssqldb`
- Oracle: `github.com/godror/godror`

**Connection String Formats** Each driver uses specific connection string formats:

```go
// PostgreSQL
"postgres://user:password@localhost/dbname?sslmode=disable"

// MySQL  
"user:password@tcp(localhost:3306)/dbname"

// SQLite
"file:test.db?cache=shared&mode=rwc"
```

**Driver Registration** Drivers typically register themselves using blank imports:

```go
import (
    "database/sql"
    _ "github.com/lib/pq" // PostgreSQL driver
)
```

