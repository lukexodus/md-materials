## Error Interface and Custom Errors


Go's built-in `error` interface is defined as:

```go
type error interface {
    Error() string
}
```

Any type implementing this method satisfies the error interface. The standard library provides `errors.New()` and `fmt.Errorf()` for creating simple errors:

```go
import (
    "errors"
    "fmt"
)

// Simple error creation
var ErrNotFound = errors.New("item not found")

// Formatted error
err := fmt.Errorf("user %d not found", userID)
```

Custom error types provide additional context and functionality:

```go
type ValidationError struct {
    Field   string
    Value   interface{}
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed for field '%s': %s", e.Field, e.Message)
}

// Usage
func validateAge(age int) error {
    if age < 0 {
        return &ValidationError{
            Field:   "age",
            Value:   age,
            Message: "must be non-negative",
        }
    }
    return nil
}
```

**Key Points:**

- Custom errors enable structured error information
- Pointer receivers for error methods allow mutability
- Rich error types support error inspection and handling logic

