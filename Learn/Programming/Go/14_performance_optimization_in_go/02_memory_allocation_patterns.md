## Memory Allocation Patterns


Understanding memory allocation patterns is crucial for optimizing Go applications, particularly regarding heap vs stack allocation and garbage collection pressure.

**Memory-Efficient Data Structures:**

```go
// Inefficient: Creates many small allocations
type BadUser struct {
    Name    *string  // Pointer causes heap allocation
    Email   *string  // Pointer causes heap allocation
    Age     *int     // Pointer causes heap allocation
    Active  *bool    // Pointer causes heap allocation
}

// Efficient: Uses value types when possible
type GoodUser struct {
    Name   string   // Value type, may stay on stack
    Email  string   // Value type, may stay on stack
    Age    int      // Value type, may stay on stack
    Active bool     // Value type, may stay on stack
}

// Memory pool for reducing allocations
type UserPool struct {
    pool sync.Pool
}

func NewUserPool() *UserPool {
    return &UserPool{
        pool: sync.Pool{
            New: func() interface{} {
                return &GoodUser{}
            },
        },
    }
}

func (p *UserPool) Get() *GoodUser {
    return p.pool.Get().(*GoodUser)
}

func (p *UserPool) Put(user *GoodUser) {
    // Clear user data before returning to pool
    *user = GoodUser{}
    p.pool.Put(user)
}
```

**Slice and Map Optimization:**

```go
// Pre-allocate slices with known capacity
func efficientSliceUsage(expectedSize int) []string {
    // Avoid multiple reallocations
    result := make([]string, 0, expectedSize)
    
    for i := 0; i < expectedSize; i++ {
        result = append(result, fmt.Sprintf("item_%d", i))
    }
    
    return result
}

// Reuse slice backing arrays
type SlicePool struct {
    pool sync.Pool
}

func NewSlicePool(capacity int) *SlicePool {
    return &SlicePool{
        pool: sync.Pool{
            New: func() interface{} {
                return make([]byte, 0, capacity)
            },
        },
    }
}

func (p *SlicePool) Get() []byte {
    return p.pool.Get().([]byte)[:0] // Reset length but keep capacity
}

func (p *SlicePool) Put(slice []byte) {
    if cap(slice) == 0 {
        return
    }
    p.pool.Put(slice)
}

// Efficient map usage
func optimizedMapUsage() {
    // Pre-allocate map with expected size hint
    m := make(map[string]int, 1000)
    
    // Use string builder for dynamic keys
    var keyBuilder strings.Builder
    keyBuilder.Grow(50) // Pre-allocate buffer
    
    for i := 0; i < 1000; i++ {
        keyBuilder.Reset()
        keyBuilder.WriteString("key_")
        keyBuilder.WriteString(strconv.Itoa(i))
        
        m[keyBuilder.String()] = i
    }
}
```

**Buffer Management:**

```go
type BufferManager struct {
    smallPool sync.Pool  // For buffers <= 1KB
    mediumPool sync.Pool // For buffers <= 16KB
    largePool sync.Pool  // For buffers <= 256KB
}

func NewBufferManager() *BufferManager {
    return &BufferManager{
        smallPool: sync.Pool{
            New: func() interface{} {
                return make([]byte, 0, 1024)
            },
        },
        mediumPool: sync.Pool{
            New: func() interface{} {
                return make([]byte, 0, 16*1024)
            },
        },
        largePool: sync.Pool{
            New: func() interface{} {
                return make([]byte, 0, 256*1024)
            },
        },
    }
}

func (bm *BufferManager) GetBuffer(size int) []byte {
    switch {
    case size <= 1024:
        return bm.smallPool.Get().([]byte)[:0]
    case size <= 16*1024:
        return bm.mediumPool.Get().([]byte)[:0]
    case size <= 256*1024:
        return bm.largePool.Get().([]byte)[:0]
    default:
        return make([]byte, 0, size)
    }
}

func (bm *BufferManager) PutBuffer(buf []byte) {
    capacity := cap(buf)
    switch {
    case capacity == 1024:
        bm.smallPool.Put(buf)
    case capacity == 16*1024:
        bm.mediumPool.Put(buf)
    case capacity == 256*1024:
        bm.largePool.Put(buf)
    }
    // Large buffers are not pooled to avoid memory waste
}
```

