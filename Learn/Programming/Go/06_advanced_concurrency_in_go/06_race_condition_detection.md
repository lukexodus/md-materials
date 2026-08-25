## Race Condition Detection


Go's race detector identifies concurrent access to shared memory that could cause data races.

**Common Race Conditions:**

1. **Unprotected Shared Variables:**

```go
// Race condition - multiple goroutines accessing counter
var counter int

func increment() {
    counter++ // Race condition
}

// Fixed version
var (
    counter int
    mu      sync.Mutex
)

func increment() {
    mu.Lock()
    counter++
    mu.Unlock()
}
```

2. **Map Access Race:**

```go
// Race condition
var m = make(map[string]int)

func updateMap(key string, value int) {
    m[key] = value // Race condition
}

// Fixed version
var (
    m  = make(map[string]int)
    mu sync.RWMutex
)

func updateMap(key string, value int) {
    mu.Lock()
    m[key] = value
    mu.Unlock()
}
```

3. **Slice Race Condition:**

```go
// Race condition
var slice []int

func appendValue(value int) {
    slice = append(slice, value) // Race condition
}

// Fixed version with channel
func safeAppend(values <-chan int) []int {
    var result []int
    for value := range values {
        result = append(result, value)
    }
    return result
}
```

**Running Race Detection:**

```bash
go run -race main.go
go test -race ./...
go build -race
```

**Race Detection in Tests:**

```go
func TestConcurrentAccess(t *testing.T) {
    var counter int64
    var wg sync.WaitGroup
    
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            atomic.AddInt64(&counter, 1)
        }()
    }
    
    wg.Wait()
    
    if counter != 100 {
        t.Errorf("Expected 100, got %d", counter)
    }
}
```

**Key Points:**

- Worker pools provide controlled concurrency and resource management
- Fan-in/fan-out patterns enable scalable parallel processing architectures
- Context package enables proper cancellation and timeout handling across goroutine boundaries
- Sync primitives (Mutex, WaitGroup, Once, Pool) provide building blocks for safe concurrent access
- Atomic operations enable lock-free programming for high-performance scenarios
- Race detection tools help identify concurrency bugs during development and testing

**Best Practices:**

- Use channels for communication between goroutines when possible
- Apply mutexes for protecting shared state when channels aren't suitable
- Implement proper context propagation for cancellation and timeouts
- Leverage atomic operations for simple concurrent counters and flags
- Always run tests with race detection enabled during development
- Design concurrent systems with clear ownership and communication patterns

Related advanced topics include distributed concurrency patterns, custom synchronization primitives, and performance optimization techniques for concurrent Go applications.

---

