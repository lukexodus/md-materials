## Literal Patterns


Literal patterns match specific constant values directly, including numbers, strings, booleans, and other primitive literals. They provide the foundation for value-based discrimination and are often combined with other pattern types to create comprehensive matching logic.

When a literal pattern is used, the scrutinee is compared for equality with the literal value. The match succeeds only when the values are equal according to the language's equality semantics. This makes literal patterns particularly useful for implementing finite state machines, command parsing, and enumeration handling.

**Key Points:**

- Match exact values using equality comparison
- Support numeric literals (integers, floats)
- Support string and character literals
- Support boolean literals (true/false)
- Can be combined with OR patterns for multiple literal matches
- Some languages support range patterns as extensions of literal matching

Numeric literal patterns are commonly used for discriminating between specific numeric values, such as handling special cases in mathematical functions:

**Example:**

```scala
def factorial(n: Int): Int = n match {
  case 0 => 1
  case 1 => 1
  case n => n * factorial(n - 1)
}
```

String literal patterns enable pattern matching on text values, useful for parsing commands, processing protocols, or handling enumerated string constants:

**Example:**

```rust
fn handle_command(cmd: &str) -> String {
    match cmd {
        "start" => "Starting process".to_string(),
        "stop" => "Stopping process".to_string(),
        "restart" => "Restarting process".to_string(),
        _ => "Unknown command".to_string(),
    }
}
```

Boolean literal patterns are essential for control flow based on truth values, though they're often implicit in conditional expressions:

**Example:**

```fsharp
let describe b =
    match b with
    | true -> "affirmative"
    | false -> "negative"
```

Some languages extend literal patterns to support range matching, allowing you to specify inclusive or exclusive ranges of values:

**Example:**

```python
def classify_grade(score):
    match score:
        case 90 | 91 | 92 | 93 | 94 | 95 | 96 | 97 | 98 | 99 | 100:
            return "A"
        case n if 80 <= n < 90:
            return "B"
        case n if 70 <= n < 80:
            return "C"
        case n if 60 <= n < 70:
            return "D"
        case _:
            return "F"
```

Literal patterns can be combined with constructor patterns to match specific cases within algebraic data types:

**Example:**

```haskell
data Status = Active Int | Inactive | Pending Int

processStatus :: Status -> String
processStatus status = case status of
    Active 0     -> "Active but zero"
    Active n     -> "Active: " ++ show n
    Inactive     -> "Not active"
    Pending 0    -> "Pending start"
    Pending n    -> "Pending: " ++ show n
```

The precision of literal patterns makes them valuable for ensuring correct handling of boundary conditions and special values. Combined with exhaustiveness checking, they help prevent bugs from unhandled cases.

**Conclusion:** Literal patterns provide exact value matching that forms the foundation of value-based control flow, enabling precise handling of constants and special cases while maintaining type safety and exhaustiveness guarantees.

