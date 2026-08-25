## Pattern Matching in Rust


### Match Expressions and Arms

Pattern matching in Rust centers around the `match` expression, which compares a value against a series of patterns and executes code based on which pattern matches.

**Key Points**

- Match expressions are exhaustive - all possible cases must be handled
- Each pattern-code pair is called a "match arm"
- Arms are evaluated in order - first match wins
- Match expressions return a value, making them powerful for assignments
- Patterns can be simple values, ranges, wildcards, variables, or complex destructured structures

```rust
let number = 13;

match number {
    // Single value patterns
    0 => println!("Zero"),
    1 => println!("One"),
    
    // Range pattern
    2..=9 => println!("Single digit"),
    
    // Catch-all pattern (wildcard)
    _ => println!("More than one digit"),
}

// Match expressions return values
let description = match number {
    0 => "zero",
    1 => "one",
    _ => "something else",
};
```

### Pattern Types and Syntax

Rust supports a rich variety of pattern types for different matching needs.

**Key Points**

- Literal patterns match exact values
- Variable patterns bind matched values to variables
- Wildcards (`_`) ignore values
- Range patterns match values in a range
- Reference patterns match references and can dereference values
- Multiple patterns can be combined with `|` (OR operator)

```rust
// Various pattern types
match value {
    // Literal pattern
    42 => println!("The answer"),
    
    // Range pattern
    0..=100 => println!("Within range"),
    
    // Multiple patterns using OR
    'a' | 'e' | 'i' | 'o' | 'u' => println!("Vowel"),
    
    // Variable pattern (binds the value)
    n => println!("The number is: {}", n),
}

// Reference patterns
let reference = &5;
match reference {
    // Dereference pattern
    &val => println!("Got a value: {}", val),
}

// OR you can dereference in the match expression
match *reference {
    val => println!("Got a value: {}", val),
}
```

### Destructuring Tuples, Structs, and Enums

One of the most powerful aspects of pattern matching is the ability to destructure complex data types.

**Key Points**

- Destructuring extracts inner components of composite types
- Works with tuples, arrays, structs, and enums
- Can be nested to arbitrary depth
- Rest pattern (`..`) ignores remaining parts of a value

#### Tuples

```rust
let tuple = (1, "hello", 3.14);

match tuple {
    (1, s, _) => println!("Found 1, string '{}', and ignored float", s),
    (x, y, z) => println!("Values: {}, {}, {}", x, y, z),
}

// Ignoring parts with ..
let tuple = (1, 2, 3, 4, 5);
match tuple {
    (first, .., last) => println!("First: {}, Last: {}", first, last),
}
```

#### Structs

```rust
struct Point {
    x: i32,
    y: i32,
}

let point = Point { x: 10, y: 20 };

// Destructuring struct
match point {
    Point { x, y } => println!("Point at ({}, {})", x, y),
}

// Destructuring with specific values
match point {
    Point { x: 0, y } => println!("On y-axis at {}", y),
    Point { x, y: 0 } => println!("On x-axis at {}", x),
    Point { x, y } => println!("Point at ({}, {})", x, y),
}

// With rest pattern
let complex_struct = ComplexStruct { a: 1, b: 2, c: 3, d: 4 };
match complex_struct {
    ComplexStruct { a, b, .. } => println!("a = {}, b = {}", a, b),
}
```

#### Enums

```rust
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}

let msg = Message::Move { x: 10, y: 20 };

match msg {
    Message::Quit => println!("Quit"),
    Message::Move { x, y } => println!("Move to ({}, {})", x, y),
    Message::Write(text) => println!("Text: {}", text),
    Message::ChangeColor(r, g, b) => println!("Color: rgb({},{},{})", r, g, b),
}
```

**Example** Deep destructuring of nested data structures:

```rust
enum Color {
    Rgb(i32, i32, i32),
    Hsv(i32, i32, i32),
}

enum Shape {
    Circle(f64, Color),
    Rectangle { width: f64, height: f64, color: Color },
}

let shape = Shape::Rectangle {
    width: 10.0,
    height: 20.0,
    color: Color::Rgb(255, 0, 0),
};

match shape {
    Shape::Circle(radius, Color::Rgb(r, g, b)) => {
        println!("Circle with radius {} and RGB color ({},{},{})", radius, r, g, b);
    }
    Shape::Rectangle { width, height, color: Color::Rgb(r, g, b) } => {
        println!("Rectangle {}×{} with RGB color ({},{},{})", width, height, r, g, b);
    }
    _ => println!("Other shape or color"),
}
```

### Match Guards

Match guards are additional `if` conditions attached to match arms, providing more control over when an arm matches.

**Key Points**

- Allow for more complex conditions beyond pattern matching
- Use the `if` keyword after the pattern
- Can reference variables from the pattern
- Evaluated only if the pattern matches first

```rust
let num = 5;

match num {
    n if n < 0 => println!("Negative number"),
    n if n % 2 == 0 => println!("Even number"),
    n => println!("Odd positive number: {}", n),
}

// With variable bindings
let x = Some(5);
let y = 10;

match x {
    Some(n) if n == y => println!("Matched: x = y"),
    Some(n) if n > y => println!("Greater than y"),
    Some(n) => println!("Different from y: {}", n),
    None => println!("No value"),
}
```

### Binding with @

The `@` operator allows binding a value to a variable while also testing it against a pattern.

**Key Points**

- Forms: `variable @ pattern`
- Lets you test and capture values simultaneously
- Especially useful with ranges and complex patterns
- Allows referring to matched values in match guards

```rust
match age {
    n @ 0..=12 => println!("Child of age {}", n),
    n @ 13..=19 => println!("Teenager of age {}", n),
    n => println!("Adult of age {}", n),
}

// With complex structures and match guards
match point {
    p @ Point { x: 0..=100, y: 0..=100 } if p.x > p.y => {
        println!("Point in upper triangle: {:?}", p);
    }
    p @ Point { x: 0..=100, y: 0..=100 } => {
        println!("Point in lower triangle: {:?}", p);
    }
    p => println!("Point outside square: {:?}", p),
}
```

### if let and while let Constructs

For cases where you only care about a single pattern match, Rust provides shorter alternatives to `match`.

**Key Points**

- `if let` handles a single pattern match case
- `while let` continues looping as long as a pattern matches
- More concise than full match expressions when only one case matters
- Can be combined with `else` for handling non-matching cases

```rust
// Instead of:
match optional {
    Some(value) => {
        println!("Got value: {}", value);
    },
    None => {},
}

// You can write:
if let Some(value) = optional {
    println!("Got value: {}", value);
}

// With else
if let Some(value) = optional {
    println!("Got value: {}", value);
} else {
    println!("No value");
}

// While let example
let mut stack = Vec::new();
stack.push(1);
stack.push(2);
stack.push(3);

// Continue popping while the pattern matches
while let Some(top) = stack.pop() {
    println!("Popped: {}", top);
}
```

### Exhaustiveness Checking

Rust's exhaustiveness checker ensures that all possible cases are handled in pattern matching, preventing runtime errors.

**Key Points**

- Compiler verifies that all possible values are covered
- Non-exhaustive matches cause compilation errors
- The wildcard pattern `_` catches all remaining cases
- Enums are particularly well-suited for exhaustiveness checking
- Helps catch logic errors when new variants are added

```rust
enum Direction {
    Up,
    Down,
    Left,
    Right,
}

let direction = Direction::Up;

// This must cover all cases
match direction {
    Direction::Up => println!("Going up"),
    Direction::Down => println!("Going down"),
    Direction::Left => println!("Going left"),
    Direction::Right => println!("Going right"),
    // If a new variant is added to Direction, this match will cause a compilation error
}

// If you don't care about all cases:
match direction {
    Direction::Up => println!("Going up"),
    Direction::Down => println!("Going down"),
    _ => println!("Going horizontally"),
}
```

**Example** Handling the exhaustiveness when working with the `Option` type:

```rust
fn process_option(opt: Option<i32>) -> String {
    match opt {
        Some(value) if value < 0 => format!("Negative value: {}", value),
        Some(0) => String::from("Zero"),
        Some(value) => format!("Positive value: {}", value),
        None => String::from("No value"),
    }
}
```

**Conclusion** Pattern matching is one of Rust's most expressive features, enabling clean, safe code for complex data handling. The exhaustiveness checking ensures robustness even as code evolves. From simple conditionals with `if let` to complex destructuring of nested data structures, pattern matching provides elegant solutions for data extraction and transformation. The combination of pattern matching with Rust's strong type system creates a powerful foundation for writing correct and maintainable code.

### Related Topics

For more advanced pattern matching, you might want to explore macros (which use pattern matching extensively), custom smart pointers, and advanced enum patterns with associated data structures. Learning about non-exhaustive patterns with the `#[non_exhaustive]` attribute can also be valuable for library authors.

---

