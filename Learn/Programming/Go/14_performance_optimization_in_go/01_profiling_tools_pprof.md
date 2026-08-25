## Profiling Tools (pprof)


Go's pprof package provides detailed runtime profiling capabilities for CPU usage, memory allocation, goroutine behavior, and blocking operations.

**Basic Profiling Setup:**

```go
package main

import (
    "log"
    "net/http"
    _ "net/http/pprof" // Automatically registers pprof endpoints
    "runtime"
    "time"
)

func main() {
    // Enable profiling endpoint
    go func() {
        log.Println(http.ListenAndServe("localhost:6060", nil))
    }()
    
    // Optional: Set runtime parameters for better profiling
    runtime.SetMutexProfileFraction(1)
    runtime.SetBlockProfileRate(1)
    
    // Your application code here
    runApplication()
}

func runApplication() {
    for {
        performWork()
        time.Sleep(100 * time.Millisecond)
    }
}
```

**Programmatic Profiling:**

```go
import (
    "os"
    "runtime"
    "runtime/pprof"
    "time"
)

func profileCPU(duration time.Duration) error {
    f, err := os.Create("cpu.prof")
    if err != nil {
        return err
    }
    defer f.Close()
    
    if err := pprof.StartCPUProfile(f); err != nil {
        return err
    }
    defer pprof.StopCPUProfile()
    
    // Run workload
    time.Sleep(duration)
    return nil
}

func profileMemory() error {
    f, err := os.Create("mem.prof")
    if err != nil {
        return err
    }
    defer f.Close()
    
    runtime.GC() // Force garbage collection
    if err := pprof.WriteHeapProfile(f); err != nil {
        return err
    }
    
    return nil
}

func profileGoroutines() error {
    f, err := os.Create("goroutine.prof")
    if err != nil {
        return err
    }
    defer f.Close()
    
    return pprof.Lookup("goroutine").WriteTo(f, 0)
}
```

**Advanced Profiling with Custom Labels:**

```go
import (
    "context"
    "runtime/pprof"
)

func processRequests() {
    for i := 0; i < 1000; i++ {
        // Add labels to profiling data
        labels := pprof.Labels("request_type", "api", "user_id", fmt.Sprintf("%d", i%10))
        pprof.Do(context.Background(), labels, func(ctx context.Context) {
            processRequest(ctx, i)
        })
    }
}

func processRequest(ctx context.Context, requestID int) {
    // This function's CPU/memory usage will be tagged with labels
    heavyComputation(requestID)
}
```

**Continuous Profiling Setup:**

```go
type Profiler struct {
    interval time.Duration
    outputs  map[string]string
    stop     chan struct{}
}

func NewProfiler(interval time.Duration) *Profiler {
    return &Profiler{
        interval: interval,
        outputs: map[string]string{
            "cpu":       "cpu_%d.prof",
            "heap":      "heap_%d.prof",
            "goroutine": "goroutine_%d.prof",
        },
        stop: make(chan struct{}),
    }
}

func (p *Profiler) Start() {
    ticker := time.NewTicker(p.interval)
    go func() {
        defer ticker.Stop()
        counter := 0
        
        for {
            select {
            case <-ticker.C:
                p.captureProfiles(counter)
                counter++
            case <-p.stop:
                return
            }
        }
    }()
}

func (p *Profiler) captureProfiles(counter int) {
    // Capture heap profile
    if f, err := os.Create(fmt.Sprintf(p.outputs["heap"], counter)); err == nil {
        runtime.GC()
        pprof.WriteHeapProfile(f)
        f.Close()
    }
    
    // Capture goroutine profile
    if f, err := os.Create(fmt.Sprintf(p.outputs["goroutine"], counter)); err == nil {
        pprof.Lookup("goroutine").WriteTo(f, 0)
        f.Close()
    }
}
```

