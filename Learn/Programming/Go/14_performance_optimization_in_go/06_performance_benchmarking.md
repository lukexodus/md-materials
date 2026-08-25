## Performance Benchmarking


Go's testing package provides comprehensive benchmarking tools for measuring and comparing performance characteristics.

**Basic Benchmarking:**

```go
func BenchmarkStringConcat(b *testing.B) {
    items := make([]string, 100)
    for i := range items {
        items[i] = fmt.Sprintf("item_%d", i)
    }
    
    b.ResetTimer() // Reset timer after setup
    
    for i := 0; i < b.N; i++ {
        _ = efficientStringConcat(items)
    }
}

func BenchmarkStringConcatBuilder(b *testing.B) {
    items := make([]string, 100)
    for i := range items {
        items[i] = fmt.Sprintf("item_%d", i)
    }
    
    b.ResetTimer()
    
    for i := 0; i < b.N; i++ {
        var builder strings.Builder
        builder.Grow(1000) // Pre-allocate
        for j, item := range items {
            if j > 0 {
                builder.WriteByte(' ')
            }
            builder.WriteString(item)
        }
        _ = builder.String()
    }
}

// Memory allocation benchmarking
func BenchmarkSliceAllocation(b *testing.B) {
    b.ReportAllocs() // Report allocation statistics
    
    for i := 0; i < b.N; i++ {
        slice := make([]int, 1000)
        for j := range slice {
            slice[j] = j
        }
    }
}
```

**Advanced Benchmarking Patterns:**

```go
func BenchmarkMapOperations(b *testing.B) {
    sizes := []int{10, 100, 1000, 10000}
    
    for _, size := range sizes {
        b.Run(fmt.Sprintf("Size-%d", size), func(b *testing.B) {
            keys := make([]string, size)
            for i := range keys {
                keys[i] = fmt.Sprintf("key_%d", i)
            }
            
            b.ResetTimer()
            
            for i := 0; i < b.N; i++ {
                m := make(map[string]int, size) // Pre-allocate
                for j, key := range keys {
                    m[key] = j
                }
            }
        })
    }
}

// Parallel benchmarking
func BenchmarkParallelProcessing(b *testing.B) {
    data := generateTestData(10000)
    
    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            processDataConcurrently(data)
        }
    })
}

// Custom benchmark metrics
func BenchmarkCustomMetrics(b *testing.B) {
    processed := int64(0)
    
    b.ResetTimer()
    
    for i := 0; i < b.N; i++ {
        result := processLargeDataset()
        processed += int64(len(result))
    }
    
    // Report custom metrics
    b.ReportMetric(float64(processed)/float64(b.N), "items/op")
    b.ReportMetric(float64(processed)*8/float64(b.Elapsed().Nanoseconds()), "bytes/ns")
}
```

**Benchmark Utilities:**

```go
type BenchmarkSuite struct {
    name    string
    setup   func() interface{}
    cleanup func(interface{})
}

func (bs *BenchmarkSuite) Run(b *testing.B, benchFunc func(*testing.B, interface{})) {
    b.Helper()
    
    if bs.setup != nil {
        data := bs.setup()
        defer func() {
            if bs.cleanup != nil {
                bs.cleanup(data)
            }
        }()
        
        b.ResetTimer()
        benchFunc(b, data)
    } else {
        benchFunc(b, nil)
    }
}

// Comparative benchmarking
func runComparativeBenchmarks(b *testing.B) {
    algorithms := map[string]func([]int) []int{
        "BubbleSort":    bubbleSort,
        "QuickSort":     quickSort,
        "MergeSort":     mergeSort,
        "HeapSort":      heapSort,
    }
    
    dataSizes := []int{100, 1000, 10000}
    
    for algoName, algoFunc := range algorithms {
        for _, size := range dataSizes {
            b.Run(fmt.Sprintf("%s-Size%d", algoName, size), func(b *testing.B) {
                data := generateRandomData(size)
                
                b.ResetTimer()
                b.ReportAllocs()
                
                for i := 0; i < b.N; i++ {
                    // Create copy for each iteration
                    testData := make([]int, len(data))
                    copy(testData, data)
                    
                    _ = algoFunc(testData)
                }
            })
        }
    }
}
```

**Benchmark Analysis Tools:**

```bash
# Run benchmarks
go test -bench=. -benchmem -count=5

# Compare benchmarks
go test -bench=. -count=10 > old.txt
# Make changes
go test -bench=. -count=10 > new.txt
benchcmp old.txt new.txt

# Profile benchmarks
go test -bench=BenchmarkCPUIntensive -cpuprofile=cpu.prof
go test -bench=BenchmarkMemoryIntensive -memprofile=mem.prof

# Benchmark with different GOMAXPROCS
go test -bench=. -cpu=1,2,4,8
```

**Key Points:**

- pprof provides comprehensive runtime profiling for CPU, memory, goroutines, and blocking operations
- Memory allocation patterns significantly impact performance through garbage collection pressure and cache locality
- CPU optimization focuses on algorithm efficiency, hot path identification, and computational complexity reduction
- Garbage collector tuning balances memory usage with latency requirements through GOGC and memory limit settings [Inference]
- Escape analysis determines stack vs heap allocation, directly affecting GC pressure and allocation performance
- Performance benchmarking provides quantitative measurement and comparison of optimization efforts

**Best Practices:**

- Profile before optimizing to identify actual bottlenecks rather than assumed problems
- Use object pooling judiciously for frequently allocated objects in hot paths
- Design APIs to minimize escape analysis issues by returning values instead of pointers when possible
- Benchmark with realistic data sizes and access patterns that match production workloads
- Monitor GC metrics in production to validate optimization effectiveness
- Consider the trade-offs between memory usage, CPU consumption, and latency for each optimization

Related advanced topics include distributed system performance optimization, cache-aware algorithms, and NUMA-aware programming techniques.

---

