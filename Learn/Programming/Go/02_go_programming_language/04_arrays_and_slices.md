## Arrays and Slices


Go distinguishes between arrays (fixed-size) and slices (dynamic arrays built on top of arrays).

### Arrays

Arrays have fixed size determined at compile time:

```go
var arr [5]int                    // Array of 5 integers
arr2 := [3]string{"a", "b", "c"}  // Initialized array
arr3 := [...]int{1, 2, 3, 4}      // Size inferred from elements
```

### Slices

Slices provide dynamic arrays with powerful operations:

```go
var slice []int                           // nil slice
slice = make([]int, 5)                   // Slice with length 5
slice = make([]int, 5, 10)               // Length 5, capacity 10
slice = []int{1, 2, 3, 4, 5}             // Slice literal
```

**Slice operations:**

- `append()` adds elements and handles capacity expansion
- Slicing syntax `slice[start:end]` creates sub-slices
- `copy()` function copies elements between slices
- `len()` returns current length, `cap()` returns capacity

**Example:**

```go
numbers := []int{1, 2, 3, 4, 5}
subset := numbers[1:4]        // [2, 3, 4]
numbers = append(numbers, 6)  // [1, 2, 3, 4, 5, 6]
```

**Key points:**

- Slices are reference types that point to underlying arrays
- Modifying a slice affects the underlying array and other slices sharing it
- Zero value of a slice is `nil`

