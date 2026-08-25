## Error Wrapping and Unwrapping


Go 1.13 introduced error wrapping capabilities through `fmt.Errorf` with the `%w` verb and the `errors` package functions:

```go
package main

import (
    "errors"
    "fmt"
    "os"
)

func readConfig() error {
    _, err := os.Open("config.yaml")
    if err != nil {
        return fmt.Errorf("failed to load configuration: %w", err)
    }
    return nil
}

func main() {
    err := readConfig()
    if err != nil {
        // Check if it's a specific error type
        if errors.Is(err, os.ErrNotExist) {
            fmt.Println("Config file doesn't exist")
        }
        
        // Unwrap to get the original error
        originalErr := errors.Unwrap(err)
        fmt.Printf("Original error: %v\n", originalErr)
        
        // Extract specific error types
        var pathErr *os.PathError
        if errors.As(err, &pathErr) {
            fmt.Printf("Path error on: %s\n", pathErr.Path)
        }
    }
}
```

**Key Points:**

- `%w` verb creates wrapped errors maintaining the error chain
- `errors.Is()` checks for specific errors in the chain
- `errors.As()` extracts specific error types from the chain
- `errors.Unwrap()` returns the underlying error

