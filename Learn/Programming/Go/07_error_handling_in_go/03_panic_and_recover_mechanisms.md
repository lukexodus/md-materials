## Panic and Recover Mechanisms


Panic represents unrecoverable errors that should terminate program execution. Recover allows catching panics within deferred functions:

```go
func safeDivision(a, b float64) (result float64, err error) {
    defer func() {
        if r := recover(); r != nil {
            err = fmt.Errorf("panic occurred: %v", r)
        }
    }()
    
    if b == 0 {
        panic("division by zero")
    }
    
    return a / b, nil
}

func processItems(items []string) error {
    defer func() {
        if r := recover(); r != nil {
            fmt.Printf("Recovered from panic: %v\n", r)
        }
    }()
    
    for i, item := range items {
        if item == "" {
            panic(fmt.Sprintf("empty item at index %d", i))
        }
        // Process item
    }
    return nil
}
```

**Key Points:**

- Panic should be used for truly exceptional conditions
- Recover only works within deferred functions
- Libraries should generally return errors, not panic
- Recover enables graceful shutdown or error conversion

