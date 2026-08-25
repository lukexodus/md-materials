## Context Package for Cancellation


The context package provides cancellation signals, deadlines, and request-scoped values across API boundaries and goroutines.

**Basic Context Usage:**

```go
func doWork(ctx context.Context) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err() // Returns context.Canceled or context.DeadlineExceeded
        default:
            // Do actual work
            if err := performTask(); err != nil {
                return err
            }
        }
    }
}

// Usage
ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
defer cancel()

if err := doWork(ctx); err != nil {
    log.Printf("Work failed: %v", err)
}
```

**Context with Values:**

```go
type contextKey string

const userIDKey contextKey = "userID"

func withUserID(ctx context.Context, userID string) context.Context {
    return context.WithValue(ctx, userIDKey, userID)
}

func getUserID(ctx context.Context) (string, bool) {
    userID, ok := ctx.Value(userIDKey).(string)
    return userID, ok
}

func authenticatedHandler(ctx context.Context) {
    if userID, ok := getUserID(ctx); ok {
        log.Printf("Processing request for user: %s", userID)
    }
}
```

**Hierarchical Cancellation:**

```go
func coordinatedWork(ctx context.Context) error {
    // Create child contexts for different work streams
    ctx1, cancel1 := context.WithCancel(ctx)
    ctx2, cancel2 := context.WithTimeout(ctx, 10*time.Second)
    ctx3, cancel3 := context.WithDeadline(ctx, time.Now().Add(5*time.Second))
    
    defer cancel1()
    defer cancel2()
    defer cancel3()
    
    errCh := make(chan error, 3)
    
    go func() { errCh <- work1(ctx1) }()
    go func() { errCh <- work2(ctx2) }()
    go func() { errCh <- work3(ctx3) }()
    
    // Wait for first completion or error
    return <-errCh
}
```

