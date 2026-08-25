## Variables, Constants, and Type Declarations


Go provides multiple declaration syntaxes for different use cases and supports both explicit and implicit typing.

**Variable Declarations:**

**var statement:**

```go
var name string
var age int = 25
var height, weight float64
```

**Short declaration:**

```go
name := "John"
age := 25
height, weight := 5.9, 160.5
```

Short declarations are only available inside functions and create new variables or assign to existing ones in the same scope.

**Zero Values:** Variables declared without explicit initialization receive zero values:

- Numeric types: 0
- Boolean: false
- Strings: ""
- Pointers, slices, maps, channels, functions, interfaces: nil

**Constants:** Constants are immutable values determined at compile time. They can be typed or untyped, with untyped constants having high precision and flexible usage.

```go
const pi = 3.14159
const (
    StatusOK = 200
    StatusNotFound = 404
)
```

**iota:** The `iota` identifier generates sequential numeric constants within constant declarations, resetting to 0 at each `const` keyword.

**Type Declarations:** Go supports creating new types based on existing types, enabling method attachment and type safety.

```go
type Temperature float64
type UserID int
type Handler func(http.ResponseWriter, *http.Request)
```

