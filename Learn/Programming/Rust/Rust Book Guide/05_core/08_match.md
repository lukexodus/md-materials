## `match`


The `match` expression in Rust is a powerful control flow construct that allows you to branch based on pattern matching. It’s similar to `switch` statements in other languages but much more versatile because it can deconstruct complex data types and match on various patterns.

**Syntax and Usage**

The basic syntax of `match` is:

```rust
match value {
    pattern1 => {
        // code to execute if value matches pattern1
    }
    pattern2 => {
        // code to execute if value matches pattern2
    }
    _ => {
        // code to execute if no other pattern matches
    }
}
```

- `value` is the expression you want to match against.
- Each `pattern =>` arm is evaluated in order until a pattern matches.
- The `_` pattern acts as a "catch-all" and matches anything that hasn’t been matched by previous patterns.

### Example 1: Matching on `Option<T>`

The `Option<T>` type is commonly used with `match` statements.

```rust
let some_value = Some(5);

match some_value {
    Some(x) => println!("The value is: {}", x),
    None => println!("No value found"),
}
```

- Here, `Some(x)` matches if `some_value` contains a value, binding the inner value to `x`.
- `None` matches if `some_value` is `None`.

### Example 2: Matching on `Result<T, E>`

The `Result<T, E>` type is another type commonly used with `match`.

```rust
let result: Result<i32, &str> = Ok(10);

match result {
    Ok(value) => println!("Success with value: {}", value),
    Err(error) => println!("Error occurred: {}", error),
}
```

- `Ok(value)` matches if `result` is an `Ok` variant, binding the inner value to `value`.
- `Err(error)` matches if `result` is an `Err` variant, binding the error to `error`.

### Example 3: Matching on Enums

Matching works well with custom enums, allowing you to branch based on each variant.

```rust
enum Direction {
    Up,
    Down,
    Left,
    Right,
}

let direction = Direction::Up;

match direction {
    Direction::Up => println!("Going up!"),
    Direction::Down => println!("Going down!"),
    Direction::Left => println!("Going left!"),
    Direction::Right => println!("Going right!"),
}
```

### Example 4: Using `_` as a Catch-All Pattern

If you only care about some cases, you can use `_` to ignore the rest:

```rust
let num = 3;

match num {
    1 => println!("One"),
    2 => println!("Two"),
    _ => println!("Something else"),
}
```

Here, `_` matches any value that is not `1` or `2`.

### Example 5: Matching with Ranges

You can use ranges in match patterns:

```rust
let num = 7;

match num {
    1..=5 => println!("Between 1 and 5"),
    6..=10 => println!("Between 6 and 10"),
    _ => println!("Something else"),
}
```

- `1..=5` matches values from 1 to 5 (inclusive).
- `6..=10` matches values from 6 to 10 (inclusive).

### Example 6: Destructuring Structs and Tuples

You can also use `match` to destructure complex types like structs and tuples.

```rust
struct Point {
    x: i32,
    y: i32,
}

let point = Point { x: 10, y: 20 };

match point {
    Point { x, y: 20 } => println!("Point with x: {}, y: 20", x),
    Point { x: 0, y } => println!("Point on the y-axis at {}", y),
    Point { x, y } => println!("Point at ({}, {})", x, y),
}
```

- Here, `Point { x, y: 20 }` matches if `y` is 20 and binds `x`.
- `Point { x: 0, y }` matches if `x` is 0 and binds `y`.
- `Point { x, y }` acts as a fallback that matches any `Point` and binds both `x` and `y`.

### Example 7: Multiple Patterns

The `|` operator is used to match **multiple patterns** in a single match arm. It functions like a logical OR, allowing you to specify alternative patterns for the same block of code.

**Example: Matching Multiple Patterns**

```rust
fn main() {
    let num = 3;

    match num {
        1 | 2 | 3 => println!("One, two, or three"),
        4 => println!("Four"),
        _ => println!("Something else"),
    }
}
```

In this example:
- `1 | 2 | 3` matches if `num` is either 1, 2, or 3, allowing for compact, readable pattern matching without needing separate cases.

**Example: Multiple Patterns with Ranges**

The `|` operator can also be used with ranges:

```rust
fn main() {
    let num = 10;

    match num {
        1..=5 | 10..=15 => println!("In range 1 to 5 or 10 to 15"),
        _ => println!("Out of range"),
    }
}
```

In this example:
- `1..=5 | 10..=15` matches if `num` is in the range 1 to 5 or in the range 10 to 15.

### Example 8: Binding with `@`

The `@` operator allows you to **bind** a matched value to a variable while still applying additional pattern matching to it. This is especially useful when you want to retain the original value after matching a specific part of it.

Here's an example of `@` in different `match` contexts:

```rust
fn main() {
    let value = Some(10);

    match value {
        // Match if the value is Some and between 5 and 15, binding it to `n`.
        Some(n @ 5..=15) => println!("Matched a number in range: {}", n),
        Some(n) => println!("Matched some other number: {}", n),
        None => println!("No number found"),
    }
}
```

In this example:
- `Some(n @ 5..=15)` binds the inner value of `Some` to `n` **only if it’s between 5 and 15**. This allows you to use the value `n` directly within the expression.

**Example: Matching on Struct Fields with `@**`

You can also use `@` when matching on struct fields:

```rust
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let point = Point { x: 10, y: 20 };

    match point {
        // Match points where y is 20 and bind x to `x_value`.
        Point { x: x_value @ 5..=15, y: 20 } => println!("Point with x in range: {}", x_value),
        Point { x, y } => println!("Point at ({}, {})", x, y),
    }
}
```

In this example:
- `x: x_value @ 5..=15` matches `x` values that are between 5 and 15, and binds the matched value to `x_value` for further use.

**Example: Binding to Complex Data**

The `@` operator can be particularly useful when working with enums that contain nested data:

```rust
enum Message {
    Hello { id: i32 },
}

fn main() {
    let msg = Message::Hello { id: 5 };

    match msg {
        // Bind the entire struct to `m` while also destructuring to match `id`.
        m @ Message::Hello { id: 3..=7 } => println!("Found a hello message in range: {:?}", m),
        Message::Hello { id: 10..=12 } => println!("Hello message with id in 10 to 12"),
        Message::Hello { id } => println!("Hello message with id: {}", id),
    }
}
```

In this example:
- `m @ Message::Hello { id: 3..=7 }` binds the entire `Message::Hello` struct to `m` if the `id` is between 3 and 7, which allows you to access the entire `Message` value.

**Example: Combining `@` and `|`**

You can combine `@` and `|` in the same match arm:

```rust
fn main() {
    let num = Some(8);

    match num {
        Some(n @ 1..=5) | Some(n @ 8..=10) => println!("Matched number in specific range: {}", n),
        Some(n) => println!("Matched number: {}", n),
        None => println!("No number"),
    }
}
```

In this example:
- `Some(n @ 1..=5) | Some(n @ 8..=10)` matches if `num` is in either of the specified ranges, and binds the value to `n` in both cases.

**Can `@` Be Used Outside of `match`?**

The `@` operator is **only used within pattern matching contexts** in Rust. You can use it in `match`, `if let`, `while let`, and function parameter patterns, but it’s not something you’d use outside of pattern matching.

For example, it works in `if let`:

```rust
let value = Some(12);

if let Some(n @ 10..=15) = value {
    println!("Value in range: {}", n);
}
```

**Benefits of `match`**

- **Exhaustiveness**: The compiler checks that all possible patterns are covered, making your code safer.
- **Pattern Matching**: `match` can match on complex patterns, destructure values, and bind variables in a single construct.
- **Conciseness**: Instead of writing multiple `if` statements, you can handle all cases in one place.

**Summary**

The `match` expression is one of Rust's most powerful tools for control flow, enabling you to handle different cases, patterns, and complex data structures in a readable and safe way. The compiler-enforced exhaustiveness check and pattern matching make it invaluable in Rust programs.

