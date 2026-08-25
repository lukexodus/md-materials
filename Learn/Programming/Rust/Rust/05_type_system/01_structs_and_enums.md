## Structs and Enums


### Defining and Instantiating Structs

Structs in Rust are custom data types that let you name and package multiple related values. They're similar to objects in other languages but without the associated methods (though you can add those through implementations).

To define a struct, use the `struct` keyword followed by the name and field declarations:

```rust
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
}
```

Once defined, you can create an instance by specifying concrete values for each field:

```rust
fn main() {
    let user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };
    
    // Access fields using dot notation
    println!("Username: {}", user1.username);
}
```

Structs are often created through functions that return struct instances:

```rust
fn create_user(email: String, username: String) -> User {
    User {
        email,
        username,
        active: true,
        sign_in_count: 1,
    }
}
```

**Key Points**

- Each struct defines a new type in your program
- Fields can be of any type, including other structs
- Fields are accessed using dot notation
- Structs are typically assigned to immutable variables by default
- With a mutable struct instance, all fields become mutable

### Field Initialization Shorthand

When variables and struct fields have the same name, you can use the field initialization shorthand to reduce repetition:

```rust
fn build_user(email: String, username: String) -> User {
    // Instead of writing email: email, username: username
    User {
        email,           // Field init shorthand 
        username,        // Field init shorthand
        active: true,
        sign_in_count: 1,
    }
}
```

This shorthand makes your code more concise when creating structures from variables that match field names.

**Example**

```rust
struct Point {
    x: f64,
    y: f64,
}

fn create_point(x: f64, y: f64) -> Point {
    Point { x, y }  // Both field init shorthand
}

fn main() {
    let point = create_point(10.0, 5.0);
    println!("Point coordinates: ({}, {})", point.x, point.y);
}
```

### Tuple Struct

A **tuple struct** looks like a `struct` version of a tuple:

```rust
struct Color(u8, u8, u8);
struct Point(f64, f64);
```

* The fields have **no names**, only **positions (0, 1, 2, …)**.
* You access them by index:

  ```rust
  let c = Color(255, 127, 0);
  println!("R={}, G={}, B={}", c.0, c.1, c.2);
  ```
* You can also destructure them:

  ```rust
  let Color(r, g, b) = c;
  ```

#### Why use tuple structs?

1. When you want a **distinct type** but the same structure as a primitive or tuple.
2. When field names add no extra clarity.

Example: type safety wrapper

```rust
struct Meters(f64);
struct Seconds(f64);

fn speed(distance: Meters, time: Seconds) -> f64 {
    distance.0 / time.0
}
```

Here, both contain `f64`, but they’re distinct types, so you can’t mix them accidentally.

---

### Unit struct

A **unit struct** has **no fields at all**:

```rust
struct Marker;
```

* It takes **no storage** (size = 0 bytes).
* You can make instances with `Marker` (no parentheses).
* It’s often used as a **marker type** or **singleton**.

Example:

```rust
struct Logger; // unit struct

impl Logger {
    fn log(&self, msg: &str) {
        println!("[LOG] {}", msg);
    }
}

fn main() {
    let logger = Logger;
    logger.log("Hello!");
}
```

Another example: implementing traits without data

```rust
trait Vehicle {
    fn drive(&self);
}

struct Bicycle;
struct Car;

impl Vehicle for Bicycle {
    fn drive(&self) { println!("Pedaling!"); }
}
impl Vehicle for Car {
    fn drive(&self) { println!("Vroom!"); }
}

fn main() {
    Bicycle.drive();
    Car.drive();
}
```

---

**Analogy**

| Kind           | Analogy                               |
| -------------- | ------------------------------------- |
| Regular struct | Named drawers in a cabinet            |
| Tuple struct   | A stack of numbered boxes             |
| Unit struct    | A label — no physical box, just a tag |

---

**Summary**

| Type           | Syntax                          | Has fields?          | Example use               |
| -------------- | ------------------------------- | -------------------- | ------------------------- |
| Regular struct | `struct Foo { a: i32, b: i32 }` | ✅ named              | Most data models          |
| Tuple struct   | `struct Bar(i32, i32);`         | ✅ unnamed (by index) | Lightweight wrappers      |
| Unit struct    | `struct Baz;`                   | ❌ none               | Marker or singleton types |


**Key Points**

- Tuple structs combine the conciseness of tuples with the type distinctiveness of structs
- Unit structs are primarily used for trait implementations without data storage
- Both are useful for type safety and semantic clarity

### Update Syntax for Structs

The struct update syntax allows you to create a new instance from an existing one, copying most fields but updating specific ones:

```rust
fn main() {
    let user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };
    
    // Create user2 with most fields from user1, but different email
    let user2 = User {
        email: String::from("another@example.com"),
        ..user1  // Copy remaining fields from user1
    };
}
```

The `..user1` syntax must come last and specifies that any fields not explicitly set should have the same values as the corresponding fields in `user1`.

Important ownership considerations apply: String fields in `user1` will be moved to `user2`, potentially making those fields in `user1` unusable afterward. Fields implementing the `Copy` trait (like integers, booleans, etc.) will be copied rather than moved.

**Example**

```rust
struct Device {
    name: String,
    model: String,
    year: u32,
    active: bool,
}

fn main() {
    let device1 = Device {
        name: String::from("SmartPhone"),
        model: String::from("Galaxy S21"),
        year: 2021,
        active: true,
    };
    
    // Create a new 2023 model variant
    let device2 = Device {
        model: String::from("Galaxy S23"),
        year: 2023,
        ..device1  // Take name and active status from device1
    };
    
    // Can't use device1.name anymore as it was moved
    // println!("Original name: {}", device1.name);  // ERROR
    
    // But can still access year since it implements Copy
    println!("Original year: {}", device1.year);  // Works fine
}
```

### Enum Variants with Data

Enums (enumerations) allow you to define a type by enumerating its possible variants. Unlike structs which group related fields together, enums express "this OR that" relationships.

Basic enum definition:

```rust
enum IpAddrKind {
    V4,
    V6,
}
```

The real power of Rust's enums comes from attaching data to each variant:

```rust
enum IpAddr {
    V4(String),
    V6(String),
}

fn main() {
    let home = IpAddr::V4(String::from("127.0.0.1"));
    let loopback = IpAddr::V6(String::from("::1"));
}
```

Each variant can have different types and amounts of associated data:

```rust
enum IpAddr {
    V4(u8, u8, u8, u8),         // Four u8 values
    V6(String),                 // A single String
}

fn main() {
    let home = IpAddr::V4(127, 0, 0, 1);
    let loopback = IpAddr::V6(String::from("::1"));
}
```

You can even include structs in enum variants:

```rust
struct Ipv4Addr {
    // fields omitted
}

struct Ipv6Addr {
    // fields omitted
}

enum IpAddr {
    V4(Ipv4Addr),
    V6(Ipv6Addr),
}
```

**Example**

```rust
enum Message {
    Quit,                       // No data
    Move { x: i32, y: i32 },    // Anonymous struct
    Write(String),              // Single String
    ChangeColor(i32, i32, i32), // Three i32 values
}

impl Message {
    fn call(&self) {
        // Method body would define behavior based on the Message variant
        match self {
            Message::Quit => println!("Quitting"),
            Message::Move { x, y } => println!("Moving to ({}, {})", x, y),
            Message::Write(text) => println!("Text message: {}", text),
            Message::ChangeColor(r, g, b) => println!("Changing color to ({}, {}, {})", r, g, b),
        }
    }
}

fn main() {
    let msg = Message::Write(String::from("hello"));
    msg.call();  // Output: Text message: hello
}
```

**Key Points**

- Enums allow expressing "this OR that" relationships clearly
- Each variant can contain different types and amounts of data
- Enum variants are namespaced under the enum identifier
- Pattern matching with `match` is the primary way to work with enum values

### Recursive Enums

Recursive data structures are those that can contain instances of themselves. In Rust, enums can be recursive by including variants that reference the enum type itself, usually through indirection like `Box<T>`.

```rust
enum List {
    Cons(i32, Box<List>),
    Nil,
}

fn main() {
    let list = List::Cons(1, 
        Box::new(List::Cons(2, 
            Box::new(List::Cons(3, 
                Box::new(List::Nil))))));
}
```

The `Box<T>` is a smart pointer that provides heap allocation. It's necessary here because without it, Rust wouldn't be able to determine the size of the `List` type at compile time, as it would contain itself infinitely.

Another common example is representing tree structures:

```rust
enum BinaryTree<T> {
    Leaf(T),
    Node(Box<BinaryTree<T>>, T, Box<BinaryTree<T>>),
}

fn main() {
    // Tree:    2
    //         / \
    //        1   3
    
    let tree = BinaryTree::Node(
        Box::new(BinaryTree::Leaf(1)),
        2,
        Box::new(BinaryTree::Leaf(3))
    );
}
```

**Example**

```rust
// JSON-like structure
enum JsonValue {
    Null,
    Boolean(bool),
    Number(f64),
    String(String),
    Array(Vec<JsonValue>),          // Recursive - contains JsonValues
    Object(HashMap<String, JsonValue>), // Recursive - contains JsonValues
}

use std::collections::HashMap;

fn main() {
    // Create a JSON object: {"name": "John", "age": 30, "is_student": false}
    let mut map = HashMap::new();
    map.insert(String::from("name"), JsonValue::String(String::from("John")));
    map.insert(String::from("age"), JsonValue::Number(30.0));
    map.insert(String::from("is_student"), JsonValue::Boolean(false));
    
    let john = JsonValue::Object(map);
    
    // Using pattern matching to extract values
    if let JsonValue::Object(ref obj) = john {
        if let Some(JsonValue::String(name)) = obj.get("name") {
            println!("Name: {}", name);
        }
    }
}
```

### Memory Layout of Structs and Enums

Understanding the memory layout can be important for optimizing performance:

**Structs**: Fields are laid out in memory in the order they're declared (though the compiler may insert padding for alignment). The size of a struct is at least the sum of its fields' sizes, plus any padding.

```rust
#[repr(C)]  // Forces C-compatible layout
struct Point {
    x: f32,  // 4 bytes
    y: f32,  // 4 bytes
}
// Size: 8 bytes
```

**Enums**: An enum's size is at least the size of its largest variant, plus space to store a discriminant value that identifies which variant is in use.

```rust
enum Message {
    Quit,                       // 0 bytes of data
    Move { x: i32, y: i32 },    // 8 bytes of data
    Write(String),              // 24 bytes on 64-bit systems
    ChangeColor(i32, i32, i32), // 12 bytes of data
}
// Size: Around 32 bytes (24 for largest variant + discriminant + alignment)
```

The `std::mem::size_of` function can be used to check:

```rust
fn main() {
    println!("Size of Point: {} bytes", std::mem::size_of::<Point>());
    println!("Size of Message: {} bytes", std::mem::size_of::<Message>());
}
```

### The Option Enum

Rust doesn't have `null` values. Instead, it has the `Option<T>` enum from the standard library:

```rust
enum Option<T> {
    None,    // No value
    Some(T), // Some value of type T
}
```

`Option<T>` is so common it's included in the prelude; you don't need to bring it into scope explicitly. The variants `Some` and `None` can be used directly without the `Option::` prefix.

```rust
fn main() {
    let some_number = Some(5);
    let some_string = Some("a string");
    
    // To have an Option<T> of type i32, we must be explicit
    let absent_number: Option<i32> = None;
    
    // Using match to handle all cases
    match some_number {
        Some(n) => println!("The number is {}", n),
        None => println!("There is no number"),
    }
}
```

**Key Points**

- `Option<T>` forces you to explicitly handle both the Some and None cases
- This prevents null pointer exceptions common in other languages
- To use the value inside Some, you must first unwrap it using methods like `unwrap()`, `expect()`, or pattern matching

**Conclusion** Structs and enums are fundamental building blocks in Rust that enable expressive, type-safe code. Structs allow you to create custom types by grouping related data, while enums represent values that can be one of several variants. Together with patterns like matching, these constructs let you model complex domains in a way that leverages Rust's type system to prevent errors. The recursive capabilities of enums, combined with smart pointers like `Box<T>`, enable the creation of sophisticated data structures while maintaining Rust's memory safety guarantees.

---

