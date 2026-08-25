## Composition Over Inheritance


Go eliminates traditional inheritance hierarchies in favor of composition through struct embedding and interface satisfaction. This pattern promotes code reuse through assembly rather than extension.

```go
type Engine struct {
    horsepower int
    fuel       string
}

func (e Engine) Start() {
    fmt.Println("Engine starting...")
}

type Car struct {
    Engine  // Embedded struct
    make    string
    model   string
}

func (c Car) Drive() {
    c.Start() // Method promoted from embedded Engine
    fmt.Println("Car is driving...")
}
```

Composition patterns in Go include:

- **Struct embedding**: Promotes fields and methods from embedded types
- **Interface composition**: Combines multiple interfaces into larger contracts
- **Dependency injection**: Passes behavior through interface parameters

This approach avoids the fragile base class problem common in inheritance-based systems and makes code relationships explicit and easier to understand.

