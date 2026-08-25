## Garbage Collector Tuning


Go's garbage collector can be tuned through environment variables and runtime settings to optimize for different workload characteristics.

**GC Environment Variables:**

```bash
# Set target heap size
export GOGC=100  # Default: GC when heap doubles

# Reduce GC frequency (larger heaps, less frequent GC)
export GOGC=200

# Increase GC frequency (smaller heaps, more frequent GC)
export GOGC=50

# Disable GC entirely (not recommended for production)
export GOGC=off

# Set soft memory limit (Go 1.19+)
export GOMEMLIMIT=4GiB
```

**Runtime GC Control:**

```go
import (
    "runtime"
    "runtime/debug"
    "time"
)

func optimizeGCSettings() {
    // Set GOGC programmatically
    debug.SetGCPercent(100)
    
    // Set memory limit (Go 1.19+)
    debug.SetMemoryLimit(4 << 30) // 4GB
    
    // Force garbage collection
    runtime.GC()
    
    // Get GC statistics
    var stats runtime.MemStats
    runtime.ReadMemStats(&stats)
    
    log.Printf("Heap size: %d bytes", stats.HeapInuse)
    log.Printf("GC cycles: %d", stats.NumGC)
    log.Printf("GC pause total: %v", time.Duration(stats.PauseTotalNs))
}

// GC pressure monitoring
type GCMonitor struct {
    lastStats runtime.MemStats
    interval  time.Duration
}

func NewGCMonitor(interval time.Duration) *GCMonitor {
    return &GCMonitor{interval: interval}
}

func (m *GCMonitor) Start(ctx context.Context) {
    ticker := time.NewTicker(m.interval)
    defer ticker.Stop()
    
    for {
        select {
        case <-ticker.C:
            m.logGCStats()
        case <-ctx.Done():
            return
        }
    }
}

func (m *GCMonitor) logGCStats() {
    var stats runtime.MemStats
    runtime.ReadMemStats(&stats)
    
    if m.lastStats.NumGC > 0 {
        gcCycles := stats.NumGC - m.lastStats.NumGC
        if gcCycles > 0 {
            avgPause := time.Duration(stats.PauseTotalNs-m.lastStats.PauseTotalNs) / time.Duration(gcCycles)
            log.Printf("GC: %d cycles, avg pause: %v, heap: %d MB",
                gcCycles, avgPause, stats.HeapInuse/1024/1024)
        }
    }
    
    m.lastStats = stats
}
```

**Reducing GC Pressure:**

```go
// Object pooling to reduce allocations
type RequestProcessor struct {
    requestPool  sync.Pool
    responsePool sync.Pool
}

func NewRequestProcessor() *RequestProcessor {
    return &RequestProcessor{
        requestPool: sync.Pool{
            New: func() interface{} {
                return &Request{Data: make([]byte, 0, 1024)}
            },
        },
        responsePool: sync.Pool{
            New: func() interface{} {
                return &Response{Buffer: make([]byte, 0, 2048)}
            },
        },
    }
}

func (rp *RequestProcessor) ProcessRequest(data []byte) *Response {
    // Get pooled objects
    req := rp.requestPool.Get().(*Request)
    resp := rp.responsePool.Get().(*Response)
    
    defer func() {
        // Reset and return to pools
        req.Reset()
        resp.Reset()
        rp.requestPool.Put(req)
        rp.responsePool.Put(resp)
    }()
    
    // Process request
    req.Data = append(req.Data[:0], data...)
    resp.Buffer = append(resp.Buffer[:0], processData(req.Data)...)
    
    // Return copy to avoid reference to pooled object
    result := &Response{Buffer: make([]byte, len(resp.Buffer))}
    copy(result.Buffer, resp.Buffer)
    return result
}

// Minimize interface{} usage to avoid boxing
type TypedCache struct {
    stringCache map[string]string
    intCache    map[string]int
    mu          sync.RWMutex
}

func (tc *TypedCache) GetString(key string) (string, bool) {
    tc.mu.RLock()
    value, exists := tc.stringCache[key]
    tc.mu.RUnlock()
    return value, exists
}

func (tc *TypedCache) SetString(key, value string) {
    tc.mu.Lock()
    tc.stringCache[key] = value
    tc.mu.Unlock()
}
```

