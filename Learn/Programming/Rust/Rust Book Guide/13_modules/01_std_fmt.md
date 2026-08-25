## `std::fmt`


`std::fmt` is Rust's **formatting module**, providing tools for **string interpolation**, **custom output formatting**, and **implementing formatting traits** like `Display` and `Debug`.

---

### **Basic Formatting with `format!`, `println!`, and `write!`**

Rust provides macros for formatting:

|Macro|Description|
|---|---|
|`format!`|Returns a formatted `String`|
|`println!`|Prints to standard output with a newline|
|`print!`|Prints to standard output without a newline|
|`eprintln!`|Prints to standard error with a newline|
|`write!`|Writes formatted output to a buffer (`io::Write`)|

**Example Usage**

```rust
fn main() {
    let name = "Alice";
    let age = 30;

    println!("Name: {}, Age: {}", name, age);
    let msg = format!("Hello, {}!", name);
    println!("{}", msg);
}
```

🔹 **Output:**

```
Name: Alice, Age: 30
Hello, Alice!
```

---

### **Formatting Placeholders**

Rust uses `{}` as placeholders inside format strings, with **format specifiers** for advanced control.

|Specifier|Description|Example|
|---|---|---|
|`{}`|Default formatting|`format!("{}", 42)` → `"42"`|
|`{:?}`|`Debug` formatting|`format!("{:?}", vec![1,2,3])` → `"[1, 2, 3]"`|
|`{:#?}`|Pretty-print `Debug`|`format!("{:#?}", vec![1,2,3])` → formatted multi-line output|
|`{:.2}`|Float precision|`format!("{:.2}", 3.14159)` → `"3.14"`|
|`{:05}`|Zero-padding|`format!("{:05}", 42)` → `"00042"`|
|`{:>6}`|Right-align (width 6)|`format!("{:>6}", "hi")` → `" hi"`|
|`{:<6}`|Left-align (width 6)|`format!("{:<6}", "hi")` → `"hi "`|
|`{:^6}`|Center-align (width 6)|`format!("{:^6}", "hi")` → `" hi "`|
|`{:+}`|Display sign|`format!("{:+}", 42)` → `"+42"`|
|`{:#x}`|Hexadecimal with prefix|`format!("{:#x}", 255)` → `"0xff"`|

---

### **Implementing `std::fmt::Display` for Custom Types**

By default, Rust **does not implement `Display` for custom types**. To print custom types with `{}`, you must implement `std::fmt::Display`.

**Example: Implementing `Display`**

```rust
use std::fmt;

struct Point {
    x: i32,
    y: i32,
}

impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

fn main() {
    let p = Point { x: 3, y: 4 };
    println!("{}", p); // Output: (3, 4)
}
```

🔹 **`write!(f, "({}, {})", self.x, self.y)`** writes to the formatter.

---

### **Implementing `std::fmt::Debug` for Debug Output**

Use `Debug` when you want a **developer-friendly** output. The `{}` specifier uses `Display`, but for debugging, you should use `{:?}`.

**Example: Implementing `Debug`**

```rust
#[derive(Debug)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p = Point { x: 3, y: 4 };
    println!("{:?}", p);   // Output: Point { x: 3, y: 4 }
    println!("{:#?}", p);  // Pretty-print format
}
```

🔹 **`#[derive(Debug)]`** automatically implements `Debug` for `Point`.  
🔹 **`{:#?}`** provides a multi-line, indented debug output.

---

### **Custom Formatting with `fmt::Formatter`**

`std::fmt::Formatter` lets you customize formatting behavior using the **format specifier** (`f: &mut fmt::Formatter`).

**Example: Custom Hex Output**

```rust
use std::fmt;

struct Color(u8, u8, u8);

impl fmt::Display for Color {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "#{:02X}{:02X}{:02X}", self.0, self.1, self.2)
    }
}

fn main() {
    let red = Color(255, 0, 0);
    println!("{}", red); // Output: #FF0000
}
```

🔹 **`{:02X}`** ensures each value is two uppercase hex digits (e.g., `0A`, `FF`).

---

### **`std::fmt::Write` Trait (For Writing to Buffers)**

The `std::fmt::Write` trait lets you write formatted output into a `String` buffer.

**Example: Writing to a `String`**

```rust
use std::fmt::Write;

fn main() {
    let mut s = String::new();
    write!(&mut s, "Hello, {}!", "world").unwrap();
    println!("{}", s); // Output: Hello, world!
}
```

🔹 `write!(&mut s, ...)` appends formatted content to the `String`.

