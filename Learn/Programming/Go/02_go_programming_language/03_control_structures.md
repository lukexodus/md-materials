## Control Structures


Go provides three primary control structures with clean, consistent syntax.

### If Statements

```go
if condition {
    // code block
} else if anotherCondition {
    // code block
} else {
    // code block
}

// If with initialization
if err := someFunction(); err != nil {
    return err
}
```

### For Loops

Go has only one looping construct - the `for` loop, but it serves multiple purposes:

```go
// Traditional for loop
for i := 0; i < 10; i++ {
    fmt.Println(i)
}

// While-style loop
for condition {
    // code
}

// Infinite loop
for {
    // code
}

// Range-based iteration
for index, value := range slice {
    fmt.Printf("Index: %d, Value: %v\n", index, value)
}
```

### Switch Statements

```go
switch variable {
case value1:
    // code
case value2, value3:
    // code for multiple values
default:
    // default case
}

// Type switch
switch v := interface{}(x).(type) {
case int:
    // v is an int
case string:
    // v is a string
}
```

**Key points:**

- No automatic fallthrough in switch cases (use `fallthrough` keyword explicitly)
- Switch cases don't require constants
- Empty switch statement `switch {}` blocks forever

