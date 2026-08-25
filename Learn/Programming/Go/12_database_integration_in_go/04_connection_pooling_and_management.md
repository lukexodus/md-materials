## Connection Pooling and Management


Go's `database/sql` package includes built-in connection pooling that manages database connections efficiently across concurrent operations.

**Pool Configuration**

```go
db.SetMaxOpenConns(25)    // Maximum number of open connections
db.SetMaxIdleConns(25)    // Maximum number of idle connections  
db.SetConnMaxLifetime(5 * time.Minute) // Maximum connection lifetime
db.SetConnMaxIdleTime(30 * time.Second) // Maximum idle time
```

**Connection Pool Behavior**

- Connections are created on-demand up to MaxOpenConns
- Idle connections are maintained up to MaxIdleConns
- Connections exceeding MaxConnLifetime are closed
- Pool handles connection validation and cleanup

**Pool Monitoring**

```go
stats := db.Stats()
fmt.Printf("Open connections: %d\n", stats.OpenConnections)
fmt.Printf("In use: %d\n", stats.InUse)  
fmt.Printf("Idle: %d\n", stats.Idle)
fmt.Printf("Wait count: %d\n", stats.WaitCount)
fmt.Printf("Wait duration: %v\n", stats.WaitDuration)
```

**Connection Health** The pool automatically validates connections:

- Pings connections before reuse if they've been idle
- Removes broken connections from the pool
- Handles connection timeouts and cancellations

**Best Practices**

- Set MaxOpenConns based on database capacity and application load
- Monitor pool statistics to identify bottlenecks
- Use context timeouts to prevent connection leaks
- Consider connection lifetime for load balancers

