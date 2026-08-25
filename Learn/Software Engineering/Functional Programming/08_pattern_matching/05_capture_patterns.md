## Capture Patterns


Capture patterns bind values to names during pattern matching, allowing you to extract and work with specific parts of data structures. They form the foundation of destructuring operations in functional languages.

**Key Points:**

- Binds matched values to variable names for immediate use
- Can be combined with other pattern types for complex matching
- Variables capture the entire matched value or specific subcomponents
- Enables simultaneous matching and extraction in a single operation

The simplest form involves direct assignment during matching. When a pattern successfully matches, the value becomes available under the specified name within the match scope.

**Example:**

```python
# Python 3.10+ structural pattern matching
match point:
    case (x, y):  # x and y are capture patterns
        print(f"Point at {x}, {y}")

# Scala
val person = ("Alice", 30, "Engineer")
person match {
    case (name, age, title) =>  // All three are capture patterns
        println(s"$name is $age years old")
}

# Haskell
processUser :: (String, Int) -> String
processUser (username, score) = username ++ " scored " ++ show score
```

Nested captures allow extraction from deeply structured data:

**Example:**

```haskell
-- Haskell nested capture
case tree of
    Node value (Leaf left) (Leaf right) -> 
        -- 'value', 'left', and 'right' are all captured
        value + left + right
    _ -> 0

-- F#
match request with
| { Method = method; Path = path; Headers = headers } ->
    // method, path, and headers are captured from record
    processRequest method path headers
```

Captures can include type constraints or guards to refine matching conditions while still binding values:

**Example:**

```scala
// Scala with type patterns and capture
expr match {
    case num: Int if num > 0 =>  // 'num' captured with constraint
        s"Positive: $num"
    case str: String =>  // 'str' captured as String type
        s"Text: $str"
}
```

**[Inference]** In languages with immutable-by-default semantics, captured values are typically immutable bindings unless explicitly marked otherwise, promoting functional purity.

