## Sync Package Primitives


### Mutex and RWMutex

Mutexes provide exclusive access to shared resources, while RWMutex allows multiple concurrent readers or a single writer.

**Mutex Usage:**

```go
type Counter struct {
    mu    sync.Mutex
    value int64
}

func (c *Counter) Increment() {
    c.mu.Lock()
    c.value++
    c.mu.Unlock()
}

func (c *Counter) Value() int64 {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.value
}
```

**RWMutex for Read-Heavy Workloads:**

```go
type Cache struct {
    mu   sync.RWMutex
    data map[string]interface{}
}

func (c *Cache) Get(key string) (interface{}, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    value, exists := c.data[key]
    return value, exists
}

func (c *Cache) Set(key string, value interface{}) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.data[key] = value
}
```

### WaitGroup

WaitGroup waits for a collection of goroutines to finish executing.

**Basic WaitGroup:**

```go
func parallelProcessing(items []Item) []Result {
    var wg sync.WaitGroup
    results := make([]Result, len(items))
    
    for i, item := range items {
        wg.Add(1)
        go func(index int, item Item) {
            defer wg.Done()
            results[index] = processItem(item)
        }(i, item)
    }
    
    wg.Wait()
    return results
}
```

**WaitGroup with Error Handling:**

```go
func processWithErrors(items []Item) ([]Result, error) {
    var wg sync.WaitGroup
    var mu sync.Mutex
    var firstError error
    results := make([]Result, len(items))
    
    for i, item := range items {
        wg.Add(1)
        go func(index int, item Item) {
            defer wg.Done()
            
            result, err := processItem(item)
            if err != nil {
                mu.Lock()
                if firstError == nil {
                    firstError = err
                }
                mu.Unlock()
                return
            }
            
            results[index] = result
        }(i, item)
    }
    
    wg.Wait()
    return results, firstError
}
```

### Once

sync.Once ensures a function is executed only once, regardless of how many goroutines call it.

**Singleton Pattern with Once:**

```go
type Database struct {
    connection *sql.DB
}

var (
    dbInstance *Database
    once       sync.Once
)

func GetDatabase() *Database {
    once.Do(func() {
        db, err := sql.Open("postgres", connectionString)
        if err != nil {
            panic(err)
        }
        dbInstance = &Database{connection: db}
    })
    return dbInstance
}
```

### Pool

sync.Pool provides a way to reuse objects and reduce garbage collection pressure.

**Object Pool Implementation:**

```go
var bufferPool = sync.Pool{
    New: func() interface{} {
        return make([]byte, 1024)
    },
}

func processData(data []byte) []byte {
    buf := bufferPool.Get().([]byte)
    defer bufferPool.Put(buf)
    
    // Use buf for processing
    result := append(buf[:0], data...)
    return result
}
```

