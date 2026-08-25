## CPU Profiling and Optimization


CPU profiling identifies performance bottlenecks and guides optimization efforts by revealing hot paths in code execution.

**CPU-Intensive Function Optimization:**

```go
// Original: Inefficient string concatenation
func inefficientStringConcat(items []string) string {
    result := ""
    for _, item := range items {
        result += item + " " // Creates new string each iteration
    }
    return result
}

// Optimized: Use strings.Builder
func efficientStringConcat(items []string) string {
    var builder strings.Builder
    totalSize := 0
    for _, item := range items {
        totalSize += len(item) + 1 // +1 for space
    }
    builder.Grow(totalSize)
    
    for i, item := range items {
        if i > 0 {
            builder.WriteByte(' ')
        }
        builder.WriteString(item)
    }
    return builder.String()
}

// Further optimized: Pre-calculated size with single allocation
func optimizedStringJoin(items []string) string {
    if len(items) == 0 {
        return ""
    }
    if len(items) == 1 {
        return items[0]
    }
    
    // Calculate exact size needed
    totalLen := len(items) - 1 // spaces between items
    for _, item := range items {
        totalLen += len(item)
    }
    
    // Single allocation
    result := make([]byte, 0, totalLen)
    for i, item := range items {
        if i > 0 {
            result = append(result, ' ')
        }
        result = append(result, item...)
    }
    
    return string(result)
}
```

**Hot Path Optimization:**

```go
// CPU-intensive mathematical operations
type Vector3D struct {
    X, Y, Z float64
}

// Original: Multiple function calls and allocations
func (v Vector3D) LengthSlow() float64 {
    return math.Sqrt(math.Pow(v.X, 2) + math.Pow(v.Y, 2) + math.Pow(v.Z, 2))
}

// Optimized: Avoid expensive function calls
func (v Vector3D) Length() float64 {
    return math.Sqrt(v.X*v.X + v.Y*v.Y + v.Z*v.Z)
}

// Further optimized: Avoid square root for comparisons
func (v Vector3D) LengthSquared() float64 {
    return v.X*v.X + v.Y*v.Y + v.Z*v.Z
}

// Batch operations for better cache locality
func NormalizeVectorsBatch(vectors []Vector3D) {
    for i := range vectors {
        lengthSq := vectors[i].LengthSquared()
        if lengthSq > 0 {
            invLength := 1.0 / math.Sqrt(lengthSq)
            vectors[i].X *= invLength
            vectors[i].Y *= invLength
            vectors[i].Z *= invLength
        }
    }
}
```

**Algorithm Optimization:**

```go
// Inefficient: O(n²) search
func findDuplicatesSlow(items []string) []string {
    var duplicates []string
    for i := 0; i < len(items); i++ {
        for j := i + 1; j < len(items); j++ {
            if items[i] == items[j] {
                duplicates = append(duplicates, items[i])
                break
            }
        }
    }
    return duplicates
}

// Optimized: O(n) with hash map
func findDuplicatesFast(items []string) []string {
    seen := make(map[string]bool, len(items))
    duplicates := make([]string, 0)
    
    for _, item := range items {
        if seen[item] {
            duplicates = append(duplicates, item)
        } else {
            seen[item] = true
        }
    }
    
    return duplicates
}

// Memory-optimized: Use map for counting
func findDuplicatesMemOptimized(items []string) []string {
    counts := make(map[string]int, len(items))
    
    // Count occurrences
    for _, item := range items {
        counts[item]++
    }
    
    // Collect duplicates
    duplicates := make([]string, 0, len(counts)/2)
    for item, count := range counts {
        if count > 1 {
            duplicates = append(duplicates, item)
        }
    }
    
    return duplicates
}
```

