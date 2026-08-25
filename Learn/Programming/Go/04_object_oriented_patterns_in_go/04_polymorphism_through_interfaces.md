## Polymorphism Through Interfaces


Go achieves polymorphism through interface satisfaction rather than inheritance. Any type that implements all methods of an interface automatically satisfies that interface, enabling runtime polymorphism without explicit declarations.

```go
type Shape interface {
    Area() float64
    Perimeter() float64
}

type Circle struct {
    radius float64
}

func (c Circle) Area() float64 {
    return math.Pi * c.radius * c.radius
}

func (c Circle) Perimeter() float64 {
    return 2 * math.Pi * c.radius
}

// Triangle automatically satisfies Shape if it implements both methods
type Triangle struct {
    base, height, side1, side2 float64
}

func (t Triangle) Area() float64 {
    return 0.5 * t.base * t.height
}

func (t Triangle) Perimeter() float64 {
    return t.base + t.side1 + t.side2
}

func PrintShapeInfo(s Shape) {
    fmt.Printf("Area: %.2f, Perimeter: %.2f\n", s.Area(), s.Perimeter())
}
```

This polymorphic system enables:

- **Duck typing**: If it walks like a duck and quacks like a duck, it's a duck
- **Flexible APIs**: Functions can accept any type implementing required behavior
- **Testing**: Easy to create mock implementations for interfaces
- **Plugin architectures**: Runtime behavior switching through interface implementations

