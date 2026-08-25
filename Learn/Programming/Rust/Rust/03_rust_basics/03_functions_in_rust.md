## Functions in Rust


### Function Definitions and Signatures

Functions in Rust are defined using the `fn` keyword followed by a name, parameter list, optional return type, and a body enclosed in curly braces.

```rust
fn function_name(parameter1: Type1, parameter2: Type2) -> ReturnType {
    // Function body
}
```

**Key Points:**

- Function names use snake_case by convention
- Return types are specified after an arrow (`->`)
- The return type can be omitted if the function returns unit type `()`
- Functions can be nested inside other functions
- Function signatures are part of a crate's public API

**Example:**

```rust
fn calculate_area(width: f64, height: f64) -> f64 {
    width * height
}

fn main() {
    let area = calculate_area(5.0, 10.0);
    println!("Area: {}", area); // Output: Area: 50
}
```

### Parameters and Return Values

#### Parameters

Function parameters are specified as name-type pairs in the function signature.

```rust
fn greet(name: &str, age: u32) {
    println!("Hello, {}! You are {} years old.", name, age);
}
```

Parameters must always have explicit type annotations. Multiple parameters are separated by commas.

#### Default Parameters

Rust doesn't have default parameters like some languages, but similar functionality can be achieved using:

1. Method chaining:

```rust
struct Builder {
    field1: i32,
    field2: String,
}

impl Builder {
    fn new() -> Self {
        Builder {
            field1: 0,
            field2: String::from("default"),
        }
    }
    
    fn field1(mut self, value: i32) -> Self {
        self.field1 = value;
        self
    }
    
    fn field2(mut self, value: String) -> Self {
        self.field2 = value;
        self
    }
}

// Usage:
let b = Builder::new().field1(42);
```

2. Option parameters:

```rust
fn greet(name: &str, title: Option<&str>) {
    match title {
        Some(t) => println!("Hello, {} {}!", t, name),
        None => println!("Hello, {}!", name),
    }
}

// Usage:
greet("Smith", Some("Mr."));
greet("Alice", None);
```

#### Return Values

Return values are specified after the `->` symbol in the function signature.

```rust
fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

Multiple values can be returned using tuples:

```rust
fn stats(numbers: &[i32]) -> (i32, i32) {
    let sum: i32 = numbers.iter().sum();
    let count = numbers.len() as i32;
    (sum, count)
}

fn main() {
    let numbers = [1, 2, 3, 4, 5];
    let (sum, count) = stats(&numbers);
    println!("Sum: {}, Count: {}", sum, count);
}
```

### Expression-Based Returns

Rust is an expression-based language, which means most constructs return a value. Functions implicitly return the value of their final expression (without a semicolon).

```rust
fn square(x: i32) -> i32 {
    x * x  // No semicolon - this is the return value
}

fn absolute(x: i32) -> i32 {
    if x >= 0 {
        x  // Return value from this branch
    } else {
        -x  // Return value from this branch
    }
}
```

The `return` keyword can be used for early returns:

```rust
fn first_positive(numbers: &[i32]) -> Option<i32> {
    for &num in numbers {
        if num > 0 {
            return Some(num);  // Early return
        }
    }
    None  // Implicit return if no positive numbers found
}
```

**Key Points:**

- The last expression in a function body becomes the return value
- Adding a semicolon to the last expression converts it to a statement, returning `()`
- Early returns are possible with the `return` keyword

### Functions as First-Class Values

In Rust, functions are first-class values, meaning they can be:

- Assigned to variables
- Passed as arguments to other functions
- Returned from other functions
- Stored in data structures

#### Function Types

A function's type is written using the `fn` keyword:

```rust
fn add(a: i32, b: i32) -> i32 {
    a + b
}

let operation: fn(i32, i32) -> i32 = add;
println!("Result: {}", operation(5, 3));  // Output: Result: 8
```

#### Functions as Arguments

Functions can be passed as arguments to other functions:

```rust
fn apply_twice(f: fn(i32) -> i32, x: i32) -> i32 {
    f(f(x))
}

fn double(x: i32) -> i32 {
    x * 2
}

fn main() {
    let result = apply_twice(double, 5);
    println!("Result: {}", result);  // Output: Result: 20 (5 → 10 → 20)
}
```

#### Higher-Order Functions

Rust's standard library contains many higher-order functions, like `map`, `filter`, and `fold`:

```rust
fn main() {
    let numbers = vec![1, 2, 3, 4, 5];
    
    // Using map with a function pointer
    let doubled: Vec<i32> = numbers.iter().map(|x| x * 2).collect();
    println!("{:?}", doubled);  // Output: [2, 4, 6, 8, 10]
    
    // Using filter
    let even: Vec<i32> = numbers.iter().filter(|x| *x % 2 == 0).cloned().collect();
    println!("{:?}", even);  // Output: [2, 4]
}
```

### Methods and Associated Functions

#### Methods

Methods are functions associated with a type, similar to methods in other languages. They take `self` (or a variant like `&self` or `&mut self`) as their first parameter.

```rust
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    // Method with immutable reference to self
    fn area(&self) -> u32 {
        self.width * self.height
    }
    
    // Method with mutable reference to self
    fn resize(&mut self, width: u32, height: u32) {
        self.width = width;
        self.height = height;
    }
    
    // Method that consumes self
    fn split(self) -> (Rectangle, Rectangle) {
        let half_width = self.width / 2;
        (
            Rectangle { width: half_width, height: self.height },
            Rectangle { width: self.width - half_width, height: self.height }
        )
    }
}
```

**Usage:**

```rust
fn main() {
    let mut rect = Rectangle { width: 10, height: 5 };
    
    println!("Area: {}", rect.area());  // Output: Area: 50
    
    rect.resize(20, 10);
    println!("New area: {}", rect.area());  // Output: New area: 200
    
    let (rect1, rect2) = rect.split();
    println!("Split areas: {} and {}", rect1.area(), rect2.area());
}
```

#### Self Parameter Variants

- `&self`: Borrows the instance immutably (most common)
- `&mut self`: Borrows the instance mutably
- `self`: Takes ownership of the instance (consumes it)
- `self: Box<Self>`: Takes a boxed instance

#### Associated Functions

Associated functions are functions that belong to a type but don't take a `self` parameter. They're often used as constructors or utility functions.

```rust
impl Rectangle {
    // Associated function (no self parameter)
    fn new(width: u32, height: u32) -> Rectangle {
        Rectangle { width, height }
    }
    
    // Another associated function
    fn square(size: u32) -> Rectangle {
        Rectangle { width: size, height: size }
    }
}

// Usage:
let rect = Rectangle::new(10, 5);
let square = Rectangle::square(8);
```

**Key Points:**

- Associated functions are called with the syntax `TypeName::function_name`
- The `new` function is a convention for constructors, not a language feature
- Multiple `impl` blocks can be used for the same type

### Function Pointers vs Closures

#### Function Pointers

Function pointers (`fn`) are pointers to functions. They:

- Have a known size at compile time
- Do not capture their environment
- Implement all three closure traits (`Fn`, `FnMut`, and `FnOnce`)

```rust
fn add_one(x: i32) -> i32 {
    x + 1
}

fn apply(f: fn(i32) -> i32, x: i32) -> i32 {
    f(x)
}

fn main() {
    let result = apply(add_one, 5);
    println!("Result: {}", result);  // Output: Result: 6
}
```

#### Closures

Closures are anonymous functions that can capture values from their environment. They are defined with a more compact syntax:

```rust
let add_one = |x: i32| -> i32 { x + 1 };
let add_two = |x| x + 2;  // Type inference works for closures
```

Closures can capture their environment in three ways:

1. By reference (`&T`)
2. By mutable reference (`&mut T`)
3. By value (`T`)

```rust
fn main() {
    let x = 10;
    
    // Captures x by reference
    let print_x = || println!("x: {}", x);
    
    // Captures y by mutable reference
    let mut y = 20;
    let mut increment_y = || {
        y += 1;
        println!("y: {}", y);
    };
    
    // Captures z by value with move keyword
    let z = String::from("hello");
    let print_z = move || println!("z: {}", z);
    
    print_x();        // Output: x: 10
    increment_y();    // Output: y: 21
    print_z();        // Output: z: hello
    
    // z is moved and can't be used here
    // println!("z: {}", z); // This would cause an error
}
```

#### Closure Traits

Closures are represented by three traits, depending on how they capture their environment:

1. `FnOnce` - Can be called once because it might consume captured values
2. `FnMut` - Can be called multiple times and can mutate captured values
3. `Fn` - Can be called multiple times without mutating captured values

```rust
fn call_once<F>(f: F) where F: FnOnce() -> i32 {
    println!("Result: {}", f());
}

fn call_mut<F>(mut f: F) where F: FnMut() -> i32 {
    println!("Result 1: {}", f());
    println!("Result 2: {}", f());
}

fn call_immut<F>(f: F) where F: Fn() -> i32 {
    println!("Result 1: {}", f());
    println!("Result 2: {}", f());
}

fn main() {
    let x = 10;
    
    // All closures implement FnOnce
    call_once(|| x * 2);
    
    let mut y = 1;
    
    // Closures that mutate captured variables implement FnMut
    call_mut(|| {
        y *= 2;
        y
    });
    
    // Closures that don't mutate anything implement Fn
    call_immut(|| x * 2);
}
```

#### Comparing Function Pointers and Closures

|Feature|Function Pointers|Closures|
|---|---|---|
|Syntax|`fn(T) -> U`|`\|x: T\| -> U { ... }`|
|Environment|Cannot capture|Can capture variables|
|Size|Fixed|Depends on captured environment|
|Storage|Can be stored in static variables|Cannot be stored in static variables (without `Fn` bounds)|
|Traits|Implements all closure traits|Implements subset based on capture|
|Use cases|Simple callbacks, FFI|Most internal callbacks, iterators|

**Example:**

```rust
// Function that accepts either function pointers or closures
fn transform<F>(values: Vec<i32>, f: F) -> Vec<i32> 
where
    F: Fn(i32) -> i32,
{
    values.into_iter().map(f).collect()
}

fn main() {
    let values = vec![1, 2, 3, 4];
    
    // Using a function pointer
    fn double(x: i32) -> i32 { x * 2 }
    let doubled = transform(values.clone(), double);
    
    // Using a closure
    let factor = 3;
    let tripled = transform(values, |x| x * factor);
    
    println!("Doubled: {:?}", doubled);  // Output: Doubled: [2, 4, 6, 8]
    println!("Tripled: {:?}", tripled);  // Output: Tripled: [3, 6, 9, 12]
}
```

**Conclusion:** Rust's function system offers a powerful blend of safety and flexibility. From basic function definitions to advanced concepts like closures and trait objects, Rust provides the tools needed for functional programming patterns while maintaining its core principles of memory safety and zero-cost abstractions. Understanding how functions work in Rust is fundamental to writing idiomatic and efficient code, especially when working with higher-order functions and callbacks that are common in modern programming.

Related topics include generic functions, trait objects for dynamic dispatch, and async functions for asynchronous programming.

---


