## Structs and Methods


Structs define custom types by grouping related data:

```go
type Person struct {
    Name string
    Age  int
    Email string
}

// Struct initialization
p1 := Person{Name: "Alice", Age: 30, Email: "alice@example.com"}
p2 := Person{"Bob", 25, "bob@example.com"}  // Positional initialization
p3 := Person{Name: "Charlie"}               // Partial initialization
```

### Methods

Go attaches methods to types using receiver syntax:

```go
// Value receiver
func (p Person) GetInfo() string {
    return fmt.Sprintf("Name: %s, Age: %d", p.Name, p.Age)
}

// Pointer receiver
func (p *Person) SetAge(age int) {
    p.Age = age
}
```

**Method receivers:**

- Value receivers work on copies of the struct
- Pointer receivers work on the original struct and can modify it
- Go automatically handles conversion between value and pointer receivers in most cases

**Example:**

```go
type Rectangle struct {
    Width, Height float64
}

func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

func (r *Rectangle) Scale(factor float64) {
    r.Width *= factor
    r.Height *= factor
}
```

**Key points:**

- Structs support composition over inheritance
- Embedded structs provide a form of inheritance
- Methods can be defined on any custom type, not just structs
- Method sets determine interface satisfaction

