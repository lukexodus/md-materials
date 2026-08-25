## database/sql Package Usage


The `database/sql` package provides the standard interface for SQL database operations in Go, emphasizing connection pooling, prepared statements, and proper resource management.

**Database Connection**

```go
db, err := sql.Open("postgres", connectionString)
if err != nil {
    return fmt.Errorf("failed to connect: %w", err)
}
defer db.Close()

// Verify connection
if err := db.Ping(); err != nil {
    return fmt.Errorf("failed to ping: %w", err)
}
```

**Query Execution Methods**

- `Query()` - returns multiple rows
- `QueryRow()` - returns single row
- `Exec()` - executes statements without returning rows
- `Prepare()` - creates prepared statements

**Row Scanning** The `Rows` and `Row` types provide scanning methods:

```go
rows, err := db.Query("SELECT id, name, email FROM users WHERE age > $1", 18)
if err != nil {
    return err
}
defer rows.Close()

for rows.Next() {
    var id int
    var name, email string
    if err := rows.Scan(&id, &name, &email); err != nil {
        return err
    }
    // Process row data
}

if err := rows.Err(); err != nil {
    return err
}
```

**Null Value Handling** The package provides nullable types for handling NULL database values:

- `sql.NullString`
- `sql.NullInt64`, `sql.NullInt32`
- `sql.NullFloat64`
- `sql.NullBool`
- `sql.NullTime`

**Prepared Statements** Prepared statements improve performance and security:

```go
stmt, err := db.Prepare("INSERT INTO users (name, email) VALUES ($1, $2)")
if err != nil {
    return err
}
defer stmt.Close()

result, err := stmt.Exec("John Doe", "john@example.com")
if err != nil {
    return err
}
```

**Context Support** All major operations support context cancellation:

```go
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

rows, err := db.QueryContext(ctx, "SELECT * FROM large_table")
```

