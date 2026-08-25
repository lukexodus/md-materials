## Escape Analysis Understanding


Escape analysis determines whether variables can be allocated on the stack (fast) or must be allocated on the heap (slower, subject to GC).

**Understanding Escape Analysis:**

```bash
# Build with escape analysis information
go build -gcflags="-m" main.go

# More detailed escape analysis
go build -gcflags="-m -m" main.go
```

**Stack vs Heap Allocation Examples:**

```go
// Stack allocation - variable doesn't escape
func stackAllocation() {
    x := 42 // Allocated on stack
    fmt.Println(x)
} // x is destroyed when function returns

// Heap allocation - variable escapes via return
func heapAllocation() *int {
    x := 42 // Escapes to heap because returned
    return &x
}

// Heap allocation - variable escapes via interface
func interfaceEscape() {
    x := 42
    fmt.Println(x) // x may escape due to interface{} in Printf
}

// Avoiding escape through careful design
type Point struct {
    X, Y float64
}

// This escapes - returns pointer
func CreatePointBad() *Point {
    return &Point{X: 1.0, Y: 2.0}
}

// This stays on stack - returns value
func CreatePointGood() Point {
    return Point{X: 1.0, Y: 2.0}
}

// Method that doesn't cause escape
func (p Point) Distance(other Point) float64 {
    dx := p.X - other.X
    dy := p.Y - other.Y
    return math.Sqrt(dx*dx + dy*dy)
}

// Method that causes escape due to interface
func (p Point) String() string {
    return fmt.Sprintf("(%f, %f)", p.X, p.Y) // fmt.Sprintf causes escape
}

// Avoiding escape in String method
func (p Point) StringNoEscape() string {
    // Pre-allocate with known size to stay on stack
    var buf [32]byte
    str := strconv.AppendFloat(buf[:0], p.X, 'f', 2, 64)
    str = append(str, ',', ' ')
    str = strconv.AppendFloat(str, p.Y, 'f', 2, 64)
    return string(str)
}
```

**Slice and Map Escape Patterns:**

```go
// Slice that escapes
func createSliceEscape() []int {
    slice := make([]int, 10) // Escapes because returned
    return slice
}

// Slice that may stay on stack
func processSliceNoEscape() {
    slice := make([]int, 10) // May stay on stack if small enough
    for i := range slice {
        slice[i] = i * i
    }
    fmt.Println(len(slice)) // Processing without returning
}

// Avoiding escape with pre-allocated buffers
type Processor struct {
    buffer []int
}

func NewProcessor(capacity int) *Processor {
    return &Processor{
        buffer: make([]int, 0, capacity),
    }
}

func (p *Processor) ProcessNumbers(input []int) []int {
    // Reuse buffer to avoid allocation
    p.buffer = p.buffer[:0]
    
    for _, num := range input {
        if num > 0 {
            p.buffer = append(p.buffer, num*num)
        }
    }
    
    // Return copy to avoid escaping buffer
    result := make([]int, len(p.buffer))
    copy(result, p.buffer)
    return result
}
```

