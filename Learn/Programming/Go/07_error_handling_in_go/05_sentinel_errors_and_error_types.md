## Sentinel Errors and Error Types


Sentinel errors are predefined error values that can be checked using `==` or `errors.Is()`:

```go
package user

import "errors"

// Sentinel errors
var (
    ErrUserNotFound    = errors.New("user not found")
    ErrInvalidInput    = errors.New("invalid input")
    ErrPermissionDenied = errors.New("permission denied")
)

// Error types for structured errors
type ValidationError struct {
    Field string
    Tag   string
    Value interface{}
}

func (e ValidationError) Error() string {
    return fmt.Sprintf("validation failed on field '%s' with tag '%s'", e.Field, e.Tag)
}

type AuthenticationError struct {
    UserID string
    Reason string
}

func (e AuthenticationError) Error() string {
    return fmt.Sprintf("authentication failed for user %s: %s", e.UserID, e.Reason)
}

// Usage in client code
func handleUserError(err error) {
    switch {
    case errors.Is(err, user.ErrUserNotFound):
        // Handle not found
    case errors.Is(err, user.ErrPermissionDenied):
        // Handle permission error
    default:
        var validationErr user.ValidationError
        if errors.As(err, &validationErr) {
            // Handle validation error
        }
        
        var authErr user.AuthenticationError
        if errors.As(err, &authErr) {
            // Handle authentication error
        }
    }
}
```

**Key Points:**

- Sentinel errors enable specific error checking
- Error types provide structured error information
- Use `errors.Is()` for sentinel error comparisons
- Use `errors.As()` for error type extraction

