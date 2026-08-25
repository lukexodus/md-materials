## Fundamental syntax


### Variables and Mutability

In Rust, variables are immutable by default, which means once a value is bound to a name, you cannot change that value. This immutability helps prevent bugs and makes code more predictable.

**Key points**:

- Variables declared with `let` are immutable by default
- Use `let mut` to create mutable variables
- Immutability is a core concept in Rust's safety guarantees
- Variable shadowing allows reusing variable names

**Example - Immutable Variables**:

```rust
let x = 5;
// x = 10; // This would cause a compilation error
println!("The value of x is: {}", x);

// Shadowing is allowed (creating a new variable with the same name)
let x = x + 1; // This creates a new immutable binding
println!("The value of x is now: {}", x);
```

**Example - Mutable Variables**:

```rust
let mut y = 5;
println!("The value of y is: {}", y);

y = 10; // This works because y is mutable
println!("The value of y is now: {}", y);
```

**Example - Shadowing vs Mutation**:

```rust
// Shadowing allows changing type
let spaces = "   ";
let spaces = spaces.len(); // Now spaces is a number

// With mutation, you can't change types
let mut word = "hello";
// word = word.len(); // This would cause a compilation error
word = "world"; // This works because the type stays the same
```

### Primitive Types: Integers

Rust provides several integer types with explicit sizes.

**Key points**:

- Signed integers: `i8`, `i16`, `i32`, `i64`, `i128`, `isize`
- Unsigned integers: `u8`, `u16`, `u32`, `u64`, `u128`, `usize`
- Default integer type is `i32`
- `isize` and `usize` depend on the architecture (32 bits on 32-bit platforms, 64 bits on 64-bit platforms)
- Integer literals can include type suffix and visual separators

**Example - Integer Types**:

```rust
let a: i32 = -42;
let b: u32 = 42;
let c = 100_000; // Visual separator for readability, same as 100000
let d = 0xff; // Hexadecimal
let e = 0o77; // Octal
let f = 0b1111_0000; // Binary with separator
let g: u8 = b'A'; // Byte literal (ASCII character)

// Architecture-dependent types
let arch_dependent: isize = -30;
let size: usize = 40; // Often used for indexing
```

**Example - Integer Overflow Handling**:

```rust
// In debug builds, overflow causes panic
// In release builds, it wraps around

// Explicit handling
let h: u8 = 255;
let i = h.wrapping_add(1); // Wraps to 0
let j = h.checked_add(1); // Returns None when overflow occurs
let k = h.overflowing_add(1); // Returns tuple (value, bool) indicating overflow
let l = h.saturating_add(1); // Saturates at the maximum value (stays 255)
```

### Primitive Types: Floating-Point

Rust has two floating-point types that represent IEEE-754 floating-point numbers.

**Key points**:

- `f32`: 32-bit floating point (single precision)
- `f64`: 64-bit floating point (double precision, default)
- IEEE-754 compliance means they include special values like infinity and NaN
- Default floating-point type is `f64`

**Example - Floating-Point Types**:

```rust
let x = 2.0; // f64 by default
let y: f32 = 3.0; // f32 with explicit type annotation

// Basic operations
let sum = 5.0 + 10.0;
let difference = 95.6 - 4.3;
let product = 4.0 * 30.0;
let quotient = 56.7 / 32.2;
let remainder = 43.5 % 5.0;

// Special values
let infinity = f32::INFINITY;
let neg_infinity = f32::NEG_INFINITY;
let nan = f32::NAN;

// Constants
let pi = std::f64::consts::PI;
let e = std::f64::consts::E;
```

### Primitive Types: Boolean

The boolean type in Rust has two possible values: `true` and `false`.

**Key points**:

- Size is one byte
- Used in conditional expressions
- Common in control flow structures
- Logical operations: `&&` (AND), `||` (OR), `!` (NOT)

**Example - Boolean Types**:

```rust
let t = true;
let f: bool = false; // With explicit type annotation

// Boolean operations
let conjunction = true && false; // false
let disjunction = true || false; // true
let negation = !true; // false

// In conditionals
if t {
    println!("This will print");
}

// As return values
let is_greater = 5 > 3; // true
```

### Primitive Types: Characters

The `char` type represents a Unicode Scalar Value, which means it can represent a lot more than just ASCII.

**Key points**:

- Size is 4 bytes (can represent any Unicode character)
- Represented with single quotes (as opposed to string literals with double quotes)
- Can represent emoji, accented letters, Chinese/Japanese/Korean characters, etc.
- Valid range: from `U+0000` to `U+D7FF` and `U+E000` to `U+10FFFF`

**Example - Character Type**:

```rust
let c = 'z';
let z: char = 'ℤ'; // Type annotation
let heart_eyed_cat = '😻';
let chinese = '中';

// Character methods
println!("Is alphabetic: {}", c.is_alphabetic());
println!("Is numeric: {}", c.is_numeric());
println!("As digit: {:?}", c.to_digit(10)); // Converts to decimal digit if possible
```

### Compound Types: Tuples

Tuples group together values of different types into one compound type with a fixed length.

**Key points**:

- Fixed size at compile time
- Can mix different types
- Individual elements accessed via period (.) followed by index
- Can be destructured
- Empty tuple `()` is called the "unit type" and represents an empty value

**Example - Tuples**:

```rust
// Tuple with multiple types
let tup: (i32, f64, u8) = (500, 6.4, 1);

// Destructuring
let (x, y, z) = tup;
println!("y is: {}", y);

// Accessing by index
let five_hundred = tup.0;
let six_point_four = tup.1;
let one = tup.2;

// Unit type
let empty = ();
fn just_returns() -> () {
    // Function that returns nothing (unit type)
    // Can also be written as `fn just_returns() {`
}
```

### Compound Types: Arrays

Arrays are collections of multiple values of the same type with a fixed length.

**Key points**:

- Fixed size at compile time
- Elements must be of the same type
- Allocated on the stack
- Useful when you want a fixed collection
- Bounds checking prevents buffer overflows
- More common in Rust than in other languages, as vectors are used for growable arrays

**Example - Arrays**:

```rust
// Array with explicit type and size
let a: [i32; 5] = [1, 2, 3, 4, 5];

// Array initialization shorthand: [value; count]
let b = [3; 5]; // Equivalent to [3, 3, 3, 3, 3]

// Accessing elements (zero-indexed)
let first = a[0];
let second = a[1];

// Array methods
let len = a.len();
let slice = &a[1..3]; // Creates a slice of [2, 3]

// Bounds checking
let index = 10;
// let element = a[index]; // This would panic at runtime if uncommented
```

**Example - Safe Array Access**:

```rust
let a = [1, 2, 3, 4, 5];
let index = 10;

// Safe access with get method
match a.get(index) {
    Some(value) => println!("Value at index {}: {}", index, value),
    None => println!("Index {} out of bounds", index),
}
```

### String Types: String vs &str

Rust has two main string types: `String` and `&str`.

**Key points**:

- `String` is a growable, heap-allocated data structure
- `&str` is an immutable reference to a string slice, often used in function parameters
- `String` can be mutated if declared mutable
- `&str` is more lightweight and commonly used for string literals
- Conversion between the two is straightforward but explicit

**Example - String Types**:

```rust
// String literal - &str type
let string_literal = "Hello, world!";

// String type - heap allocated
let mut string = String::from("Hello");
string.push_str(", world!"); // Modify the String

// Converting &str to String
let s1 = "slice".to_string();
let s2 = String::from("slice");

// Converting String to &str
let s3: &str = &string;

// String concatenation
let s4 = s1 + &s2; // Note: s1 is moved here and can't be used again

// Format macro for complex concatenation
let s5 = format!("{} {} {}", s2, s3, "concatenated");
```

**Example - String Operations**:

```rust
let mut s = String::from("hello world");

// Length
let len = s.len();

// Character count (differs from len for non-ASCII strings)
let char_count = s.chars().count();

// Slicing (be careful, must slice at character boundaries)
let hello = &s[0..5];
let world = &s[6..11];

// Iteration
for c in s.chars() {
    println!("{}", c);
}

// Modification
s.push_str(" and universe");
s.replace("world", "earth");
s = s.to_uppercase();
```

### Type Annotations and Type Inference

Rust has a strong, static type system with type inference.

**Key points**:

- Type annotations use a colon after the variable name
- Type inference allows Rust to determine types automatically in many cases
- Type inference helps reduce verbosity while maintaining type safety
- More complex or ambiguous cases require explicit annotations
- Function parameters always require type annotations

**Example - Type Annotations and Inference**:

```rust
// Type inference
let x = 5; // Rust infers i32
let y = 10.5; // Rust infers f64

// Explicit type annotations
let explicit_int: u32 = 42;
let explicit_float: f32 = 3.14;

// Required annotations in certain contexts
let guess: u32 = "42".parse().expect("Not a number!");

// Function parameters and return types
fn add(a: i32, b: i32) -> i32 {
    a + b
}

// Type annotations with generics
let v: Vec<i32> = Vec::new();
let v2 = vec![1, 2, 3]; // Type inference works with vec! macro
```

**Example - Type Inference in Complex Contexts**:

```rust
// Sometimes the compiler needs help
let numbers: Vec<u32> = vec![1, 2, 3];
let doubled: Vec<_> = numbers.iter().map(|&x| x * 2).collect();

// Without the type annotation, the compiler wouldn't know what 
// type to collect into
```

### Constants and Statics

Rust provides two ways to define values that exist for the entire run of a program: constants and statics.

**Key points**:

- `const` values are inlined at compile time
- `static` values have a fixed address in memory
- Both require explicit type annotations
- Constants are evaluated at compile time, they can't be the result of function calls or anything computed at runtime
- `static mut` values are unsafe to access and modify

**Example - Constants**:

```rust
// Constants use SCREAMING_SNAKE_CASE by convention
const MAX_POINTS: u32 = 100_000;
const PI: f64 = 3.14159;

fn use_constant() {
    println!("The maximum points are {}", MAX_POINTS);
    
    // Constants are inlined wherever they're used
    let circumference = 2.0 * PI * 5.0;
}
```

**Example - Static Variables**:

```rust
// Static variables also use SCREAMING_SNAKE_CASE
static HELLO_WORLD: &str = "Hello, world!";

// Mutable static variables are unsafe
static mut COUNTER: u32 = 0;

fn use_static() {
    println!("Message: {}", HELLO_WORLD);
    
    // Modifying static mut is unsafe
    unsafe {
        COUNTER += 1;
        println!("COUNTER: {}", COUNTER);
    }
}
```

**Example - When to Use Each**:

```rust
// Use const for values that never change
const SECONDS_IN_DAY: u32 = 24 * 60 * 60;

// Use static for global state or large data that shouldn't be copied
static GLOBAL_DATA: [u8; 1024] = [0; 1024];

// Constants can use other constants in their definition
const MINUTES_IN_DAY: u32 = SECONDS_IN_DAY / 60;
```

### Type Conversion and Casting

Rust has strict rules about type conversion, requiring explicit casts in most cases.

**Key points**:

- Explicit casting uses the `as` keyword
- Numeric types can be explicitly cast to other numeric types
- `From` and `Into` traits provide more controlled conversions
- The `TryFrom` and `TryInto` traits handle fallible conversions
- Converting between numeric types may truncate or wrap values

**Example - Explicit Casting**:

```rust
// Basic casting with as
let a = 5;
let b = 5.0;

let a_float = a as f64;
let b_int = b as i32;

// Character conversion
let c = 'A';
let c_code = c as u8; // ASCII code (65)

// Careful with potential truncation
let large_number = 1000;
let small_number = large_number as u8; // Truncates to 232 (1000 % 256)
```

**Example - From and Into Traits**:

```rust
// From trait
let string_from_int = String::from(42);
let int_from_str = u32::from(b'A'); // 65

// Into trait (reverse of From)
let s: String = 42.into();

// Custom conversions for your types
struct Number {
    value: i32,
}

impl From<i32> for Number {
    fn from(item: i32) -> Self {
        Number { value: item }
    }
}

let num = Number::from(30);
let num2: Number = 40.into(); // Into works automatically when From is implemented
```

**Example - TryFrom and TryInto for Fallible Conversions**:

```rust
use std::convert::{TryFrom, TryInto};

// TryFrom/TryInto return a Result
let try_int: Result<i32, _> = "42".try_into();
match try_int {
    Ok(num) => println!("Converted to {}", num),
    Err(_) => println!("Conversion failed"),
}

// Custom TryFrom implementation
struct EvenNumber(i32);

impl TryFrom<i32> for EvenNumber {
    type Error = &'static str;
    
    fn try_from(value: i32) -> Result<Self, Self::Error> {
        if value % 2 == 0 {
            Ok(EvenNumber(value))
        } else {
            Err("Value must be even")
        }
    }
}

// Using TryFrom
let even = EvenNumber::try_from(2);
let odd = EvenNumber::try_from(3);

match odd {
    Ok(even_number) => println!("Got even number: {}", even_number.0),
    Err(e) => println!("Error: {}", e),
}
```

**Example - Parse Method for String Conversion**:

```rust
let parsed_number: i32 = "42".parse().expect("Not a number!");

// With error handling
let parse_result = "42".parse::<u32>();
match parse_result {
    Ok(num) => println!("Parsed number: {}", num),
    Err(e) => println!("Failed to parse: {}", e),
}

// Multiple conversions
let turbo_parsed = "42"
    .parse::<i32>()
    .unwrap()
    .to_string()
    .parse::<f64>()
    .unwrap();
```

### Type Aliases

Type aliases create a new name for an existing type, improving readability and reducing redundancy.

**Key points**:

- Created with the `type` keyword
- No new type is created, just an alias
- Useful for complex types that are used repeatedly
- Improves code readability
- Common in error handling and domain-specific code

**Example - Type Aliases**:

```rust
// Simple type alias
type Kilometers = i32;

let distance: Kilometers = 5;
// Kilometers is treated exactly as i32
let meters: i32 = distance * 1000;

// More complex examples
type Thunk = Box<dyn Fn() + Send + 'static>;

// In error handling
type Result<T> = std::result::Result<T, std::io::Error>;

// For readability in domain-specific code
type CustomerID = u64;
type ProductCode = String;

fn process_order(customer: CustomerID, product: ProductCode) {
    // Implementation
}
```

**Conclusion**: Understanding Rust's basic syntax, variables, and data types is the foundation for writing effective Rust code. Rust's type system enforces memory safety and prevents many common bugs through features like immutability by default, strong static typing, and explicit conversions. The distinction between concepts like `String` and `&str`, or the different numeric types, is crucial for writing efficient and correct Rust programs. As you progress in Rust, these fundamentals will serve as building blocks for more advanced features.

### Related Topics

- Ownership and borrowing
- Enums and pattern matching
- Structs and custom types
- Collections and data structures
- Error handling with Result and Option

---

