## Maps and Operations


Maps provide key-value storage with hash table implementation:

```go
// Map declaration and initialization
var m map[string]int                    // nil map
m = make(map[string]int)               // Empty map
m = map[string]int{"key1": 1, "key2": 2} // Map literal
```

**Map operations:**

```go
// Setting values
m["key"] = 42

// Getting values with existence check
value, exists := m["key"]
if !exists {
    fmt.Println("Key not found")
}

// Deleting keys
delete(m, "key")

// Iterating over maps
for key, value := range m {
    fmt.Printf("%s: %d\n", key, value)
}
```

**Key points:**

- Maps are reference types
- Zero value is `nil`
- Key types must be comparable (strings, numbers, booleans, arrays, structs with comparable fields)
- Map iteration order is random for security reasons
- Not safe for concurrent access without synchronization

