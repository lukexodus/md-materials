## Method Definitions and Receivers


Go methods are functions with special receiver arguments that appear between the `func` keyword and method name. Methods can have either value receivers or pointer receivers, each serving distinct purposes.

```go
type Rectangle struct {
    width, height float64
}

// Value receiver - operates on a copy
func (r Rectangle) Area() float64 {
    return r.width * r.height
}

// Pointer receiver - operates on the original
func (r *Rectangle) Scale(factor float64) {
    r.width *= factor
    r.height *= factor
}
```

Value receivers are appropriate when methods don't modify the receiver or when the receiver is small and copying is inexpensive. Pointer receivers are necessary when methods need to modify the receiver, when the receiver is large (to avoid copying overhead), or when implementing interfaces that require pointer receivers.

Method sets determine which methods are available to types and their pointers. A value receiver method is available to both the type and its pointer, while pointer receiver methods are only available to pointers of the type.

