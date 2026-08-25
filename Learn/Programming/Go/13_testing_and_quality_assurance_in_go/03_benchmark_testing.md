## Benchmark Testing


Benchmark testing in Go measures performance characteristics of code, helping identify bottlenecks and track performance regressions over time.

**Key Points:**

- Benchmark functions start with `Benchmark` and accept `*testing.B` parameter
- Use `b.N` to control iteration count - the testing framework adjusts this automatically
- Call `b.ResetTimer()` to exclude setup time from measurements
- Use `b.StopTimer()` and `b.StartTimer()` to pause timing during setup/cleanup
- Run benchmarks with `go test -bench=.` or specific patterns

**Example:**

```go
// benchmark_test.go
package mathutils

import (
    "crypto/rand"
    "fmt"
    "math/big"
    "strings"
    "testing"
)

func BenchmarkAdd(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Add(123, 456)
    }
}

func BenchmarkStringConcatenation(b *testing.B) {
    tests := []struct {
        name   string
        method func([]string) string
    }{
        {"Plus", concatenateWithPlus},
        {"Builder", concatenateWithBuilder},
        {"Join", concatenateWithJoin},
    }

    words := []string{"hello", "world", "this", "is", "a", "test", "string"}

    for _, tt := range tests {
        b.Run(tt.name, func(b *testing.B) {
            for i := 0; i < b.N; i++ {
                tt.method(words)
            }
        })
    }
}

func concatenateWithPlus(words []string) string {
    result := ""
    for _, word := range words {
        result += word + " "
    }
    return result
}

func concatenateWithBuilder(words []string) string {
    var builder strings.Builder
    for _, word := range words {
        builder.WriteString(word)
        builder.WriteString(" ")
    }
    return builder.String()
}

func concatenateWithJoin(words []string) string {
    return strings.Join(words, " ")
}

// Memory allocation benchmarks
func BenchmarkSliceAppend(b *testing.B) {
    benchmarks := []struct {
        name     string
        capacity int
    }{
        {"NoPrealloc", 0},
        {"Prealloc100", 100},
        {"Prealloc1000", 1000},
    }

    for _, bm := range benchmarks {
        b.Run(bm.name, func(b *testing.B) {
            b.ReportAllocs()
            for i := 0; i < b.N; i++ {
                slice := make([]int, 0, bm.capacity)
                for j := 0; j < 100; j++ {
                    slice = append(slice, j)
                }
            }
        })
    }
}

// Benchmark with setup
func BenchmarkMapLookup(b *testing.B) {
    // Setup - excluded from timing
    data := make(map[string]int, 10000)
    for i := 0; i < 10000; i++ {
        data[fmt.Sprintf("key%d", i)] = i
    }
    keys := make([]string, 100)
    for i := range keys {
        keys[i] = fmt.Sprintf("key%d", i)
    }

    b.ResetTimer() // Start timing from here

    for i := 0; i < b.N; i++ {
        for _, key := range keys {
            _ = data[key]
        }
    }
}

// Parallel benchmarks
func BenchmarkParallelWork(b *testing.B) {
    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            // Simulate CPU-intensive work
            n, _ := rand.Int(rand.Reader, big.NewInt(1000))
            _ = n.String()
        }
    })
}
```

**Benchmark Output Analysis:**

- `BenchmarkAdd-8`: Function name and GOMAXPROCS value
- `1000000000`: Number of iterations (b.N)
- `0.5 ns/op`: Nanoseconds per operation
- `0 B/op`: Bytes allocated per operation
- `0 allocs/op`: Number of allocations per operation

**Advanced Benchmarking:**

```go
func BenchmarkComplexFunction(b *testing.B) {
    sizes := []int{100, 1000, 10000, 100000}
    
    for _, size := range sizes {
        b.Run(fmt.Sprintf("Size%d", size), func(b *testing.B) {
            data := generateTestData(size)
            b.ResetTimer()
            b.ReportAllocs()
            
            for i := 0; i < b.N; i++ {
                b.StopTimer()
                input := copyData(data) // Don't time the copy
                b.StartTimer()
                
                ProcessData(input)
            }
        })
    }
}
```

