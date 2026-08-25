## Synchronous vs Buffered Channels


The distinction between synchronous (unbuffered) and buffered channels fundamentally changes how goroutines interact and synchronize.

**Synchronous Channels:**

- Created with `make(chan Type)`
- Send and receive operations are synchronous - they block until both sender and receiver are ready
- Provide strong synchronization guarantees
- Each send corresponds to exactly one receive operation

**Buffered Channels:**

- Created with `make(chan Type, capacity)`
- Send operations only block when the buffer is full
- Receive operations only block when the buffer is empty
- Decouple sender and receiver timing

**Example:**

```go
func main() {
    // Synchronous channel
    syncCh := make(chan int)
    
    // Buffered channel
    buffCh := make(chan int, 3)
    
    // This would deadlock with syncCh
    buffCh <- 1
    buffCh <- 2
    buffCh <- 3
    
    fmt.Println(<-buffCh) // Prints: 1
}
```

Buffered channels are useful for scenarios like rate limiting, batching operations, or when you want to decouple producer and consumer goroutines. However, they should be sized carefully to avoid unbounded growth or resource exhaustion.

