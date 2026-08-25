## Functions and Multiple Return Values


Go functions support multiple return values natively, eliminating the need for complex parameter passing or struct returns for multiple outputs.

**Basic function syntax:**

```go
func functionName(parameter1 type1, parameter2 type2) (returnType1, returnType2) {
    return value1, value2
}
```

**Key points:**

- Functions are first-class values and can be assigned to variables
- Named return values can be declared in the function signature
- The blank identifier `_` can ignore unwanted return values
- Variadic functions accept variable numbers of arguments using `...`

**Example:**

```go
func divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, fmt.Errorf("division by zero")
    }
    return a / b, nil
}

// Usage with error handling
result, err := divide(10, 3)
if err != nil {
    log.Fatal(err)
}
```

Functions can be passed as arguments, returned from other functions, and stored in data structures. Anonymous functions and closures provide powerful functional programming capabilities.

