## Transaction Handling


Go provides explicit transaction management through the `database/sql` package, requiring manual transaction lifecycle management.

**Basic Transaction Operations**

```go
tx, err := db.Begin()
if err != nil {
    return err
}
defer tx.Rollback() // Rollback if not committed

// Perform operations
_, err = tx.Exec("INSERT INTO users (name) VALUES ($1)", "Alice")
if err != nil {
    return err // Automatic rollback via defer
}

_, err = tx.Exec("UPDATE accounts SET balance = balance - 100 WHERE id = $1", accountID)
if err != nil {
    return err
}

// Commit transaction
if err = tx.Commit(); err != nil {
    return err
}
```

**Context-Aware Transactions**

```go
ctx := context.Background()
tx, err := db.BeginTx(ctx, &sql.TxOptions{
    Isolation: sql.LevelSerializable,
    ReadOnly:  false,
})
if err != nil {
    return err
}
defer tx.Rollback()

// Use transaction with context
_, err = tx.ExecContext(ctx, "INSERT INTO logs (message) VALUES ($1)", "Transaction started")
```

**Transaction Options**

- `Isolation` - controls transaction isolation level
- `ReadOnly` - marks transaction as read-only for optimization

**Transaction Patterns** Wrapper function for transaction handling:

```go
func withTx(db *sql.DB, fn func(*sql.Tx) error) error {
    tx, err := db.Begin()
    if err != nil {
        return err
    }
    defer tx.Rollback()
    
    if err := fn(tx); err != nil {
        return err
    }
    
    return tx.Commit()
}

// Usage
err := withTx(db, func(tx *sql.Tx) error {
    // Perform transactional operations
    return nil
})
```

**Savepoints** [Inference] Some databases support savepoints for partial rollbacks, though this requires database-specific SQL commands rather than standard library support.

**Nested Transactions** [Inference] Go's standard library doesn't directly support nested transactions; this requires database-specific features or application-level transaction management.

