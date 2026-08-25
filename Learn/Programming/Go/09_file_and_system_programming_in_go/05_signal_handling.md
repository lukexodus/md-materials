## Signal Handling


Signal handling allows programs to respond gracefully to system signals like interruption requests, termination signals, and user-defined signals.

**Key Points:**

- `os/signal` package provides signal handling capabilities
- `signal.Notify` registers channels to receive specific signals
- Common signals include `SIGINT`, `SIGTERM`, `SIGUSR1`, and `SIGUSR2`
- Signal handling enables graceful shutdown and resource cleanup
- Signal handlers should be non-blocking and perform minimal work

**Example:**

```go
package main

import (
    "context"
    "fmt"
    "os"
    "os/signal"
    "sync"
    "syscall"
    "time"
)

func main() {
    // Create a context that can be cancelled
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()

    // Set up signal handling
    sigCh := make(chan os.Signal, 1)
    signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM, syscall.SIGUSR1)

    var wg sync.WaitGroup

    // Start background worker
    wg.Add(1)
    go worker(ctx, &wg)

    // Start signal handler
    wg.Add(1)
    go func() {
        defer wg.Done()
        handleSignals(sigCh, cancel)
    }()

    fmt.Println("Application started. Press Ctrl+C to stop or send SIGUSR1 for status.")
    wg.Wait()
    fmt.Println("Application stopped.")
}

func worker(ctx context.Context, wg *sync.WaitGroup) {
    defer wg.Done()
    ticker := time.NewTicker(2 * time.Second)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            fmt.Println("Worker: Shutting down...")
            return
        case <-ticker.C:
            fmt.Println("Worker: Processing...")
        }
    }
}

func handleSignals(sigCh <-chan os.Signal, cancel context.CancelFunc) {
    for sig := range sigCh {
        switch sig {
        case syscall.SIGINT, syscall.SIGTERM:
            fmt.Printf("Received signal: %v. Initiating graceful shutdown...\n", sig)
            cancel()
            return
        case syscall.SIGUSR1:
            fmt.Println("Status: Application is running normally")
        default:
            fmt.Printf("Received unexpected signal: %v\n", sig)
        }
    }
}
```

Signal handling is essential for building robust services that need to handle graceful shutdowns, configuration reloads, and status queries. The pattern typically involves using channels to communicate signal events to the main application logic.

