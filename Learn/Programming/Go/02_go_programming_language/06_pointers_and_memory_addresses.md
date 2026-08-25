## Pointers and Memory Addresses


Go supports pointers but eliminates pointer arithmetic for safety:

```go
var x int = 42
var p *int = &x    // p points to x
fmt.Println(*p)    // Dereference: prints 42
*p = 21           // Modify value through pointer
```

**Pointer operations:**

- `&` operator gets the memory address
- `*` operator dereferences (gets the value at the address)
- `new()` function allocates memory and returns a pointer

**Example:**

```go
func increment(x *int) {
    *x++  // Modifies the value at the address
}

func main() {
    num := 5
    increment(&num)  // Pass address of num
    fmt.Println(num) // Prints 6
}
```

**Key points:**

- No pointer arithmetic (no `p++` operations)
- Automatic memory management through garbage collection
- Zero value of a pointer is `nil`
- Go can take the address of any variable, even literals in some contexts

