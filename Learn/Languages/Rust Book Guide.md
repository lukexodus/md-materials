# Packages

## `cargo`

### 1. Creating a New Project

To create a new Rust project with Cargo, you can run the following command:

```bash
cargo new my_project
```

This creates a new directory called `my_project` with the following structure:

```
my_project/
├── Cargo.toml
└── src/
    └── main.rs
```

- `Cargo.toml`: The manifest file where you define metadata, dependencies, and other configuration.
- `src/main.rs`: The main entry point of your Rust program.

For a **library** instead of a binary, use:

```bash
cargo new my_library --lib
```

This creates a library package with a similar structure, but the main file will be `lib.rs` instead of `main.rs`.

---

### 2. Basic Commands

Here are some of the most commonly used Cargo commands:

- **`cargo build`**: Compiles the project. It creates a `target/` directory with the compiled binaries.
- **`cargo run`**: Builds and then runs the project.
- **`cargo test`**: Runs the tests in the project.
- **`cargo clean`**: Removes the `target/` directory and any build artifacts.
- **`cargo doc`**: Generates documentation for the project and its dependencies.
- **`cargo check`**: Quickly checks your code for errors without producing a binary.

Example:

```bash
cargo run
```

---

### 3. Managing Dependencies

Cargo uses the `Cargo.toml` file to manage dependencies. To add a dependency, you simply add it under the `[dependencies]` section in your `Cargo.toml` file.

Example `Cargo.toml`:

```toml
[dependencies]
rand = "0.8.3"
serde = { version = "1.0", features = ["derive"] }
```

To install a dependency directly from the command line, you can use:

```bash
cargo add rand
```

You can also specify dependencies from other sources like Git repositories or local paths:

```toml
[dependencies]
some_crate = { git = "https://github.com/user/some_crate.git" }
local_crate = { path = "../local_crate" }
```

---

### 4. Building and Running a Project

To **build** the project:

```bash
cargo build
```

The compiled binary will be in the `target/debug/` directory by default. If you want to build in release mode (optimized for performance):

```bash
cargo build --release
```

This will place the binary in the `target/release/` directory.

To **run** the project:

```bash
cargo run
```

You can pass command-line arguments to your binary:

```bash
cargo run -- arg1 arg2
```

---

### 5. Testing

Cargo makes it easy to test your Rust code. By convention, you can write unit tests directly in the `src/` files, or create integration tests in the `tests/` directory.

To run all tests in your project, use:

```bash
cargo test
```

You can filter tests by name:

```bash
cargo test test_name
```

For documentation tests (which test code snippets in your comments), run:

```bash
cargo test --doc
```

In Rust, when you run tests using `cargo test`, you can specify additional arguments to control how tests are executed. The `--` separator is used to distinguish between arguments intended for Cargo and arguments meant for the test binary itself. 

Here’s how it works:

- **Before `--`**: Any arguments before the `--` are passed to Cargo. These arguments control how Cargo runs, such as building the project or running tests in parallel.
  
- **After `--`**: Any arguments after the `--` are passed to the test binary (the executable produced by Cargo that runs the tests). These are used to control specific behaviors of the test execution, such as filtering test names or setting output formats.

**Example**:
```bash
cargo test -- --nocapture
```

- `cargo test`: Runs the test suite using Cargo.
- `--`: The separator indicating that subsequent arguments are for the test binary.
- `--nocapture`: Passed to the test binary, telling it not to capture (i.e., hide) the output of tests (useful for printing debug messages).

**When to Use It**:
1. **Without the `--` separator**, any arguments you pass are treated as instructions for Cargo itself.
   - Example: `cargo test --release` tells Cargo to build and run the tests in release mode.

2. **With the `--` separator**, arguments after the `--` are passed to the test binary.
   - Example: `cargo test -- --test-threads=1` runs the tests in a single thread (which can be useful for debugging).

**Some Common Test Binary Options After `--**`:
- `--nocapture`: Shows test output, such as `println!` statements, during the test execution.
- `--test-threads=N`: Runs tests in `N` threads.
- `--exact`: Ensures that only a test with the exact name is run.
- `--ignored`: Runs tests marked as `#[ignore]`.

---

### 6. Building Documentation

Cargo can generate documentation for your code and its dependencies using the following command:

```bash
cargo doc
```

This generates documentation in the `target/doc/` directory. To open the documentation in a web browser:

```bash
cargo doc --open
```

---

### 7. Workspaces

Workspaces allow you to manage multiple packages (crates) in a single Cargo project. This is useful for larger projects that consist of several related crates.

To create a workspace, you need a `Cargo.toml` file in the root of the workspace with the following structure:

```toml
[workspace]
members = [
    "crate1",
    "crate2"
]
```

The workspace structure looks like this:

```
workspace/
├── Cargo.toml
├── crate1/
│   └── Cargo.toml
└── crate2/
    └── Cargo.toml
```

With a workspace, you can build all packages at once using:

```bash
cargo build
```

---

### 8. Publishing Crates

To publish your crate to [crates.io](https://crates.io), the Rust package registry:

1. Create an account on [crates.io](https://crates.io).
2. Login to crates.io via Cargo:

   ```bash
   cargo login
   ```

3. Ensure your crate is ready for publishing by running:

   ```bash
   cargo publish --dry-run
   ```

4. Finally, publish your crate:

   ```bash
   cargo publish
   ```

---

### 9. Profiles

Cargo has two default profiles: `dev` and `release`. You can customize these profiles in the `Cargo.toml` file under the `[profile]` section.

Example of customizing the release profile:

```toml
[profile.release]
opt-level = 3
debug = false
lto = true
```

You can configure different optimization levels, debug info, and more depending on your use case.

---

### 10. Cargo.toml Deep Dive

The `Cargo.toml` file is the manifest for your project. Here's a typical `Cargo.toml` structure:

```toml
[package]
name = "my_project"
version = "0.1.0"
authors = ["Your Name <your_email@example.com>"]
edition = "2021"

[dependencies]
serde = "1.0"
```

Key sections:
- `[package]`: Information about your package, including its name, version, and authors.
- `[dependencies]`: Lists external crates your project depends on.
- `[dev-dependencies]`: Dependencies only needed for tests.
- `[build-dependencies]`: Dependencies needed for build scripts.

---

### 11. Advanced Features

Cargo also supports advanced features, such as:

- **Features**: Allows you to conditionally compile parts of your crate based on flags in your `Cargo.toml`.

   ```toml
   [features]
   default = ["serde"]
   serde = ["serde"]
   ```

- **Build Scripts**: Custom scripts that are executed during the build process. These are useful for tasks like generating code or compiling native dependencies.

   Create a `build.rs` file in your project, and Cargo will run it automatically.

- **Custom Commands**: You can define custom subcommands that are specific to your project. These can be written as separate binaries in your project and invoked via `cargo my_command`.

## Workspaces

In Rust, **workspaces** are a feature that allows you to manage multiple related packages (crates) together in a single project. This is particularly useful for organizing code, sharing dependencies, and managing builds efficiently across multiple crates. 

A workspace consists of the following:

**Key Features of Workspaces**:
1. **Shared `Cargo.lock`**: All crates in the workspace share a single `Cargo.lock` file. This ensures that dependencies remain consistent across all the crates in the workspace.
   
2. **Centralized Dependency Management**: Dependencies for all crates in the workspace can be managed centrally in the workspace's root `Cargo.toml` file.

3. **Efficient Builds**: Since dependencies are shared and cached, workspaces reduce build time and disk usage compared to managing crates individually.

4. **Cross-Crate Collaboration**: Workspaces make it easier to develop libraries and binaries that depend on each other, allowing for smooth integration and testing.

---

**Structure of a Workspace**
A workspace is defined by a **root directory** that contains a `Cargo.toml` file with a `[workspace]` section. The individual crates are subdirectories or paths listed under the `[workspace.members]`.

Example Structure:
```
my_workspace/
├── Cargo.toml
├── crate1/
│   ├── Cargo.toml
│   └── src/
│       └── lib.rs
├── crate2/
│   ├── Cargo.toml
│   └── src/
│       └── main.rs
└── crate3/
    ├── Cargo.toml
    └── src/
        └── lib.rs
```

#### Root `Cargo.toml` File:
```toml
[workspace]
members = [
    "crate1",
    "crate2",
    "crate3"
]
```

Each crate (`crate1`, `crate2`, etc.) will have its own `Cargo.toml` file, and they can be libraries or binaries.

---

**Benefits of Using Workspaces**
- **Modularity**: Break large projects into smaller, reusable crates.
- **Consistency**: Unified dependency versions across crates.
- **Ease of Maintenance**: Manage related crates from a single project root.
- **Faster Builds**: Share intermediate build artifacts.

---

### Commands in a Workspace
- Build all members: `cargo build`
- Run a specific crate: `cargo run -p crate2`
- Test all crates: `cargo test`
- Add a dependency to all crates: Add it to the workspace root's `Cargo.toml`.

Workspaces are an excellent way to manage complex Rust projects with multiple components while keeping everything organized and efficient.


# Concepts

## Binary Crate vs Library Crate

In Rust, projects can be structured as either **binary crates** or **library crates**. Both serve different purposes depending on the nature of the project. Let’s break down the differences:

### 1. **Binary Crate**:
A **binary crate** is a crate that produces an executable program (a binary). It contains a `main` function, which acts as the entry point for execution.

- **Purpose**: To create applications or command-line tools that can be executed directly.
- **File**: The main file is `src/main.rs`.
- **Output**: Produces an executable binary.
- **Structure**: Every binary crate must have a `main` function, which serves as the entry point of the program.
  
**Example**:
```rust
// src/main.rs
fn main() {
    println!("Hello from the binary crate!");
}
```

- Running `cargo run` will execute the binary created from `main.rs`.
  
### 2. **Library Crate**:
A **library crate** does not produce a binary but provides functionality that can be shared and reused by other crates, either binary or other libraries.

- **Purpose**: To define shared functionality like functions, structs, or modules that other crates can use.
- **File**: The main file is `src/lib.rs`.
- **Output**: Does not produce an executable binary; instead, it produces a library that other crates can depend on.
- **Structure**: A library crate does not require a `main` function. Instead, it contains reusable code like functions, structs, enums, etc.
  
**Example**:
```rust
// src/lib.rs
pub fn greet() {
    println!("Hello from the library crate!");
}
```

- This crate can be used in other projects by adding a dependency in their `Cargo.toml` file, like:
  ```toml
  [dependencies]
  my_library = { path = "../my_library" }
  ```

**Key Differences**:

| **Aspect**              | **Binary Crate**                                   | **Library Crate**                            |
|-------------------------|---------------------------------------------------|---------------------------------------------|
| **Purpose**             | Produces an executable program.                   | Provides reusable code and functionality.   |
| **File Location**       | The main file is `src/main.rs`.                    | The main file is `src/lib.rs`.              |
| **Requires `main`**     | Yes, a binary crate requires a `main` function.    | No, a library crate does not have a `main`. |
| **Output**              | Produces an executable binary.                    | Produces a library that other crates can use.|
| **Use Case**            | Command-line tools, applications, programs.       | Shared functionality, reusable code.        |

### Combining Binary and Library Crates:

A single project can have **both a binary crate and a library crate**. This is useful when you want to write reusable code in a library crate and use it in your binary crate.

- The binary crate (in `src/main.rs`) can use functions or modules from the library crate (in `src/lib.rs`).
  
**Example**:

```rust
// src/lib.rs (Library Crate)
pub fn greet() {
    println!("Hello from the library crate!");
}

// src/main.rs (Binary Crate)
use my_project::greet; // Use the function from the library crate

fn main() {
    greet(); // Call the library crate function
}
```

**Summary**:

- **Binary Crate**: Produces an executable with a `main` function.
- **Library Crate**: Provides reusable code without a `main` function, often used in multiple projects.
- **Combined**: A project can have both a library and a binary, where the library provides reusable functionality and the binary uses it.

In general, if you’re writing an application that you want to run, use a **binary crate**. If you’re writing reusable logic to share with other projects, use a **library crate**.

## Borrowing and Ownership

### Moving Values to a Function vs Passing References to It

#### 1. Moving Values to a Function

When you move a value into a function, ownership of that value is transferred to the function. The original variable in the caller is no longer valid after the move, and attempting to use it will result in a compile-time error.

**Example:**

```rust
fn take_ownership(s: String) {
    println!("{}", s);
}

fn main() {
    let my_string = String::from("Hello");
    take_ownership(my_string); // Ownership moved to the function
    // my_string can no longer be used here.
}
```

After calling take_ownership, the ownership of my_string is transferred to the function, so it can’t be used in the main function anymore.

#### 2. Passing References to a Function

When you pass a reference (&T) to a function, you allow the function to borrow the value without taking ownership. This means that the original value can still be used after the function call.

Example:

```rust
fn borrow_string(s: &String) {
    println!("{}", s);
}

fn main() {
    let my_string = String::from("Hello");
    borrow_string(&my_string); // Pass a reference (borrow)
    // my_string can still be used here because ownership is not moved.
    println!("{}", my_string);
}
```

In this case, my_string is borrowed by borrow_string, and after the function call, my_string can still be used in the main function.


### Moving Values to a Struct vs Passing References to It

#### 1. Moving Values to a Struct

When you move a value into a struct, the struct becomes the new owner of that value, and the original variable loses ownership. This means the original variable cannot be used anymore after the move.

**Example:**

```rust
struct Person {
    name: String,
}

fn main() {
    let my_name = String::from("Alice");
    let person = Person { name: my_name }; // my_name is moved to the struct
    // my_name can no longer be used here.
}
```

Here, my_name is moved into the Person struct, so it can’t be accessed anymore in the main function after the move.


#### 2. Passing References to a Struct

When you pass references to a struct, the struct does not take ownership of the values, but instead, it borrows them. The original variables can still be used while the struct holds the references.

**Example:**

```rust
struct Person<'a> {
    name: &'a String,
}

fn main() {
    let my_name = String::from("Alice");
    let person = Person { name: &my_name }; // Borrowing my_name
    // my_name can still be used here because ownership is not moved.
    println!("{}", my_name);
}
```

In this example, the struct Person borrows the my_name using a reference, so my_name can still be used after creating the person struct.


**When to Use Each**

1. **Move (Ownership Transfer):**

Use when you want the function/struct to take ownership of the value.

This makes sense when the function or struct needs to modify, consume, or store the value long-term (e.g., storing in a struct or collection).

Be mindful that after the move, the original variable is no longer accessible.


2. **References (Borrowing):**

Use when you don’t want to transfer ownership but still want to allow the function/struct to access the value.

Ideal for cases where the value is large or expensive to clone, but you only need to read (or occasionally mutate) it temporarily.

Remember that references require careful management of lifetimes and borrowing rules.

## Closures and Lazy Evaluation

### What is "Lazy" Evaluation?

In programming, **lazy evaluation** refers to deferring the computation of a value until it is absolutely necessary. It helps optimize performance by avoiding unnecessary calculations.

In Rust, methods like `unwrap_or_else`, `map_or_else`, or `ok_or_else` use lazy evaluation. These methods take closures (we'll discuss closures in a moment), and the provided closures will only be executed if they are needed.

For example:
```rust
let x: Option<i32> = None;
let result = x.unwrap_or_else(|| {
    println!("Calculating default value...");
    42  // this closure only runs when `x` is `None`
});
```
Here, the closure `|| { 42 }` will only run if `x` is `None`. If `x` is `Some`, the closure will be ignored and never evaluated.

### Closures in Rust

A **closure** in Rust is a function-like construct that can capture variables from its environment and is defined **inline** in your code. They are similar to **anonymous functions** (functions without a name) in other languages, but they are more powerful because they can "close over" (i.e., capture) variables in their surrounding scope.

**Syntax of Closures**:
Closures in Rust have the following basic form:
```rust
|parameters| -> return_type {
    // body
}
```
You can omit the parameter types and return types, and Rust will infer them for you.

Example of a simple closure:
```rust
let add_one = |x| x + 1;
let result = add_one(5); // result = 6
```

Here, `add_one` is a closure that takes a single parameter `x` and returns `x + 1`.

### Closures vs Functions

Closures are similar to regular functions, but there are important differences:

1. **Anonymous**: Closures do not need a name. You can define them inline where they're used.
   - Example: `|x| x + 1` is a closure.

2. **Capturing Environment**: Closures can capture variables from their surrounding scope.
   - Example:
     ```rust
     let num = 5;
     let add_num = |x| x + num;  // captures `num` from the environment
     let result = add_num(10);   // result = 15
     ```

3. **Types Can Be Inferred**: Rust can infer the parameter and return types of closures, whereas for regular functions you must always specify the types.
   - Example:
     ```rust
     let add = |x, y| x + y;
     println!("{}", add(5, 10));  // 15
     ```

4. **Trait Boundaries**: Closures implement one or more of the following traits based on how they capture variables:
   - **`FnOnce`**: The closure can be called **once** (it consumes the variables it captures).
   - **`FnMut`**: The closure can modify the variables it captures (mutable access).
   - **`Fn`**: The closure borrows the variables it captures immutably (read-only).

**Example**: Using Closures with Captured Variables
```rust
fn main() {
    let mut counter = 0;

    let mut increment = || {
        counter += 1;  // the closure captures `counter` mutably
        println!("Counter: {}", counter);
    };

    increment();  // Counter: 1
    increment();  // Counter: 2
}
```
In this example, the closure `increment` captures and modifies the `counter` variable from its surrounding environment.

### Differences Between Closures and Functions

| Feature                  | Closures                                        | Functions                               |
|--------------------------|------------------------------------------------|-----------------------------------------|
| **Anonymous**             | Yes                                            | No (always named)                       |
| **Can capture environment** | Yes (can capture local variables)              | No (can't capture variables)            |
| **Type inference**        | Type of parameters and return type can be inferred | Type must be explicitly stated         |
| **Call traits**           | Implements `Fn`, `FnMut`, or `FnOnce`          | Regular function traits only            |

### Practical Uses of Closures in Rust

- **Callbacks**: Closures are often used for callbacks, where you pass a function or closure to another function to be called later.
  - Example: Sorting with closures:
    ```rust
    let mut numbers = vec![3, 1, 4, 1, 5, 9];
    numbers.sort_by(|a, b| a.cmp(b));  // closure used for custom sorting
    ```

- **Functional Programming**: Closures are used in functional programming constructs like `map`, `filter`, `reduce`, etc.
  - Example: Mapping over a vector:
    ```rust
    let numbers = vec![1, 2, 3];
    let doubled: Vec<i32> = numbers.iter().map(|x| x * 2).collect();
    println!("{:?}", doubled);  // [2, 4, 6]
    ```

## Dereferencing

In Rust, the `*` operator is known as the **dereference operator**. It is used to access the value that a reference or pointer is pointing to. Here's an overview of when and in what circumstances the dereference operator (`*`) is commonly used:

### 1. **Dereferencing References**
References in Rust, like `&T` or `&mut T`, point to a value without owning it. The dereference operator `*` allows you to access the value that the reference is pointing to.

**Example**:
```rust
let x = 5;
let y = &x;  // `y` is a reference to `x`

// Dereference `y` to get the value of `x`
assert_eq!(5, *y);
```

In this example, `y` is a reference to `x`, and `*y` dereferences the reference to access the value `5`.

**When** to Use:
- When you have a reference to a value and you want to access or modify the value it points to.
- When working with borrowed references (`&T` and `&mut T`).

### 2. **Dereferencing Raw Pointers**
Rust also supports raw pointers (`*const T` and `*mut T`), which are used for low-level programming and have fewer safety guarantees than references. Dereferencing raw pointers is an unsafe operation and requires an `unsafe` block.

 **Example**:
```rust
let x = 5;
let y = &x as *const i32;  // raw pointer to `x`

unsafe {
    // Dereference the raw pointer inside an `unsafe` block
    println!("Value of y: {}", *y);
}
```

**When to Use**:
- When dealing with raw pointers, which is typically needed for low-level system programming or when interfacing with C code.
- **Caution**: Raw pointers and dereferencing them are unsafe because Rust’s borrow checker doesn’t guarantee memory safety in this case.

### 3. **Dereferencing Boxed Values**
`Box<T>` is a smart pointer in Rust that allocates its value on the heap. Dereferencing a `Box<T>` gives you access to the value stored on the heap.

**Example**:
```rust
let boxed = Box::new(10);  // Boxed heap value
println!("Value in box: {}", *boxed);  // Dereference the box to access the value
```

**When to Use**:
- When you have a `Box<T>` and need to access the underlying heap-allocated value.

### 4. **Dereferencing Smart Pointers (`Deref` Trait)**
Rust's standard library provides several smart pointers, like `Box<T>`, `Rc<T>`, and `Arc<T>`, which implement the `Deref` trait. This trait allows you to use the `*` operator to dereference the smart pointer and access the value it points to.

The `Deref` trait also enables **automatic dereferencing**, which allows Rust to automatically dereference smart pointers in many cases where it’s appropriate (e.g., accessing methods or fields).

**Example**:
```rust
use std::ops::Deref;

struct MyBox<T>(T);

impl<T> Deref for MyBox<T> {
    type Target = T;

    fn deref(&self) -> &T {
        &self.0
    }
}

let my_box = MyBox(5);
println!("Value in MyBox: {}", *my_box);  // Uses the deref method to access the value
```

**When to Use**:
- When working with custom smart pointers that implement the `Deref` trait.
- Rust will usually apply automatic dereferencing for you, so the need to explicitly use `*` is less frequent in everyday use.

### 5. **Modifying Through a Mutable Reference**
If you have a mutable reference (`&mut T`), you can use `*` to modify the underlying value.

**Example**:
```rust
let mut x = 10;
let y = &mut x;  // mutable reference

*y += 5;  // dereference `y` to modify the underlying value
println!("x: {}", x);  // x is now 15
```

**When to Use**:
- When you have a mutable reference to a value and want to modify the value it points to.

### 6. **Destructuring in Pattern Matching**
In pattern matching, the `*` operator can also be used to destructure a reference and get access to the value.

**Example**:
```rust
fn print_value(value: &i32) {
    match value {
        &v => println!("Value is: {}", v),  // Destructure the reference
    }
}

let num = 10;
print_value(&num);
```

**When to Use**:
- When pattern matching references or pointers to extract their values.

**Key Points**:
- The `*` operator is used for **dereferencing** references, pointers, or smart pointers to access the underlying value.
- In most cases, Rust will **automatically dereference** smart pointers (like `Box<T>`, `Rc<T>`, etc.) when needed.
- When dereferencing raw pointers, the operation is considered **unsafe** and must be done inside an `unsafe` block.
- For **mutable references**, `*` can be used to modify the underlying value.

**Summary**:
The `*` (dereference) operator is mainly used when you need to access or modify the value that a reference or pointer is pointing to. It's commonly used with borrowed references (`&T` and `&mut T`), smart pointers (like `Box<T>`), and raw pointers in unsafe code. Rust’s ownership and borrowing system encourages minimal direct use of `*`, as automatic dereferencing and pattern matching can handle many scenarios for you.

## Cloning vs Copying

In Rust, **cloning** and **copying** refer to two different ways of duplicating data, and they are represented by two separate traits: `Clone` and `Copy`.

1. **`Clone`**:
   - `Clone` is a trait that represents **explicit, deep copying** of data. When you call `.clone()` on an object, it creates a new, separate instance of the data.
   - Cloning can be expensive because it involves duplicating the data, potentially even performing a deep copy (where all underlying data structures are also copied).
   - `Clone` is implemented for types that need custom logic to create a new instance, such as `String`, `Vec`, and many other types that hold data on the heap.
   - **Usage**: You need to call the `.clone()` method explicitly.

   ```rust
   let s1 = String::from("Hello");
   let s2 = s1.clone(); // Creates a separate copy of `s1`
   println!("s1: {}, s2: {}", s1, s2);
   ```

2. **`Copy`**:
   - `Copy` is a trait that represents **implicit, shallow copying** of data. Types that implement `Copy` are automatically duplicated when assigned to another variable or passed to a function.
   - Copying is cheap and only applies to types that can be safely duplicated without any additional resources, typically stack-allocated, fixed-size types like integers, floats, and `bool`.
   - `Copy` is a "marker trait," meaning it has no methods. When a type implements `Copy`, you don’t need to call any methods to copy it; the compiler will handle it automatically.
   - **Usage**: Copying is implicit. Just assigning a `Copy` type to a new variable or passing it to a function will copy it.

   ```rust
   let x = 5;
   let y = x; // `x` is copied into `y` (no need to call `.clone()`)
   println!("x: {}, y: {}", x, y);
   ```

---

**KEY DIFFERENCES**

- **Explicit vs. Implicit**:
  - `Clone` requires an explicit call to `.clone()`, while `Copy` happens implicitly when assigning or passing values.

- **Cost**:
  - `Clone` can be more expensive as it may involve deep copying data structures.
  - `Copy` is generally very cheap because it applies only to types that can be trivially duplicated (like integers and floats).

- **Ownership Transfer**:
  - For types that implement `Clone` but not `Copy` (like `String` or `Vec`), assigning a value to a new variable **moves** ownership unless you explicitly call `.clone()`.
  - For types that implement `Copy` (like `i32` or `bool`), assignment simply creates a copy, so both variables can be used after the assignment without any ownership transfer.

---

**When to Use `Clone` and `Copy**`

- **Use `Copy`** when your type is small, fixed-size, and can be duplicated trivially. This is mostly for stack-allocated, primitive types like integers, floats, and `bool`. If your type consists only of `Copy` types, you can usually implement `Copy` for it as well.
  
- **Use `Clone`** when your type is more complex, holds data on the heap, or requires additional logic to duplicate. Most user-defined types that involve heap allocation (like `String` or `Vec`) implement `Clone` instead of `Copy`.

---

**Example: Custom Struct with `Copy` and `Clone**`

To illustrate the usage of both `Copy` and `Clone`, let’s define a couple of structs:

```rust
#[derive(Copy, Clone)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p1 = Point { x: 5, y: 10 };
    let p2 = p1; // `p1` is copied to `p2` because `Point` implements `Copy`
    println!("p1: ({}, {}), p2: ({}, {})", p1.x, p1.y, p2.x, p2.y);
}
```

In the above example:
- The `Point` struct implements both `Copy` and `Clone`, so it can be copied implicitly and cloned explicitly.
- Since `Point` only contains `i32` values (which are `Copy`), it can also be `Copy`.
- Assigning `p1` to `p2` does not move `p1`; instead, it copies `p1` to `p2`.

For a type that holds heap data (like `String`), only `Clone` is implemented, as duplicating it is more complex and involves allocation.

---

**Summary Table**

| Trait  | Purpose                         | Cost         | Requires Explicit Call? | Example Types                      |
|--------|---------------------------------|--------------|-------------------------|------------------------------------|
| `Clone`| Explicit, potentially deep copy | Higher       | Yes, `.clone()`         | `String`, `Vec<T>`, custom structs |
| `Copy` | Implicit, shallow copy          | Low (cheap)  | No                      | `i32`, `bool`, `f32`, custom `Copy` structs |

In short:
- **Use `Copy` for simple, small types** where an implicit copy is inexpensive.
- **Use `Clone` for types requiring more complex duplication** where you want explicit control over when the copy occurs.

## RAII Principle

**RAII Principle**

RAII stands for **Resource Acquisition Is Initialization**, which is a programming principle that ensures resource management (like memory, files, or locks) is tied to the lifetime of an object. In RAII, resources are acquired during an object's initialization and automatically released when the object goes out of scope, ensuring proper cleanup.

**Key Idea**

RAII relies on **constructors** to acquire resources and **destructors** to release them. In Rust, this is achieved using constructors like `new()` and the `Drop` trait for cleanup.

---

**Benefits of RAII**

1. **Automatic Resource Management**: Resources are automatically freed, reducing the risk of memory leaks.
2. **Exception Safety**: Cleanup happens regardless of whether the code finishes normally or due to an error.
3. **Thread Safety**: Resources like locks are released properly, avoiding deadlocks.
4. **Simplicity**: Developers don't need to explicitly manage cleanup, leading to simpler, more maintainable code.

---

**RAII in Rust**

Rust enforces RAII by combining **ownership** and the **Drop** trait. When a variable goes out of scope, Rust automatically runs the `drop` method, cleaning up resources tied to that variable.

**Example: File Handling with RAII**

```rust
use std::fs::File;

fn main() {
    let file = File::open("example.txt").expect("Failed to open file");
    // When `file` goes out of scope, its `Drop` implementation closes the file automatically.
}
```

---

**RAII for Mutex Locks**

Rust's synchronization primitives like `Mutex` also leverage RAII to ensure locks are automatically released.

```rust
use std::sync::Mutex;

fn main() {
    let mutex = Mutex::new(10);

    {
        let mut data = mutex.lock().unwrap();
        *data += 5; // Work with the data
    } // The lock is automatically released here

    println!("Updated value: {:?}", mutex.lock().unwrap());
}
```

---

**RAII in Other Languages**

RAII is not unique to Rust. Languages like C++ also use RAII for resource management through constructors and destructors.

**C++ Example:**

```cpp
#include <iostream>
#include <fstream>

int main() {
    std::ofstream file("example.txt");
    file << "Hello, RAII!";
    // File is automatically closed when `file` goes out of scope.
    return 0;
}
```

---

**Conclusion**

RAII is a powerful principle that promotes **safe and automatic resource management**. Rust enforces RAII at its core, ensuring that resources are tied to the ownership of variables and are cleaned up safely when those variables go out of scope. This minimizes manual management and reduces bugs like memory leaks or dangling resources.

## ABI (Application Binary Interface)

The **Application Binary Interface (ABI)** defines how functions, data structures, and system calls are represented in binary, allowing different components (like Rust code, C libraries, or OS kernels) to interact at the machine level.

---

**Key Aspects of Rust's ABI**

1. **Function Calling Conventions**
    
    - Determines how function arguments and return values are passed (registers vs. stack).
    - Rust defaults to its own **unspecified ABI**, meaning calling conventions may change across compiler versions.
2. **Foreign Function Interface (FFI)**
    
    - Rust uses **extern "C"** to ensure compatibility with C-style ABIs.
    - Example:
        
        ```rust
        extern "C" {
            fn printf(format: *const i8, ...);
        }
        ```
        
    - This tells Rust to use the **C ABI** for calling `printf`.
3. **ABI Stability in Rust**
    
    - **Rust does not guarantee a stable ABI** across different compiler versions.
    - This means Rust libraries should expose a C-compatible ABI when interacting with external code.

---

### **Common ABI Types in Rust**

Rust supports multiple ABI specifications using the `extern` keyword:

|ABI|Description|
|---|---|
|`"Rust"`|Default ABI (unstable across versions).|
|`"C"`|Standard C ABI (used for FFI).|
|`"cdecl"`|C-style calling convention (x86).|
|`"stdcall"`|Windows API calling convention.|
|`"fastcall"`|Passes some arguments in registers for speed.|
|`"system"`|Uses platform's default calling convention.|
|`"thiscall"`|Used for C++ instance methods.|

**Example using `extern "C"` for ABI compatibility:**

```rust
#[no_mangle] // Prevents name mangling for C compatibility
extern "C" fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

---

### **Interfacing with C Libraries (FFI)**

Rust can call C functions using `extern "C"`:

```rust
extern "C" {
    fn abs(input: i32) -> i32;
}

fn main() {
    unsafe {
        println!("{}", abs(-10)); // Calls C's abs() function
    }
}
```

Likewise, Rust functions can be exposed to C:

```c
// C code
#include <stdio.h>

extern int add(int a, int b);

int main() {
    printf("%d\n", add(2, 3));
    return 0;
}
```

---

**ABI Mismatch Issues**

- If the Rust ABI is **not explicitly specified**, function calls may fail when interacting with C/C++ or other languages.
- Mismatched calling conventions can cause **stack corruption**, **crashes**, or **undefined behavior**.

---

**Key Takeaways**

✔ **Rust does not guarantee a stable ABI** (except for `extern "C"`).  
✔ **Use `extern "C"` for FFI** to interact with other languages.  
✔ **ABI mismatches** can lead to crashes or memory corruption.  
✔ **Avoid exposing Rust functions with Rust ABI** across compilation units or libraries.

## Endianness

Endianness refers to the order in which bytes are stored in memory for multi-byte values (e.g., 16-bit, 32-bit, or 64-bit integers). It primarily affects how numbers are represented at the binary level in different computer architectures.

---

**Types of Endianness**

1. **Big-Endian (BE)**
    - Stores the **most significant byte (MSB) first** at the lowest memory address.
    - Example: The number `0x12345678` in a **big-endian** system would be stored as:
        
        ```
        Address  |  Value  
        ---------|--------
        0x00     |  12  
        0x01     |  34  
        0x02     |  56  
        0x03     |  78  
        ```
        
2. **Little-Endian (LE)**
    
    - Stores the **least significant byte (LSB) first** at the lowest memory address.
    - Example: The number `0x12345678` in a **little-endian** system would be stored as:
        
        ```
        Address  |  Value  
        ---------|--------
        0x00     |  78  
        0x01     |  56  
        0x02     |  34  
        0x03     |  12  
        ```


---

**Why Does Endianness Matter?**

- **Cross-Platform Compatibility:** Different CPU architectures use different endianness. Intel (x86, x86-64) uses **little-endian**, while some older architectures (e.g., Motorola 68k, PowerPC) use **big-endian**.
- **Networking:** The Internet Protocol (IP) uses **big-endian** (also called "network byte order"), meaning that data transmitted between computers must be converted properly.
- **File Formats:** Some file formats define a specific endianness (e.g., PNG uses big-endian, while BMP uses little-endian).
- **Embedded Systems:** Microcontrollers and specialized hardware may use either format, requiring careful handling.

---

**Detecting Endianness in Rust**

Rust provides built-in methods to check and convert endianness:

```rust
use std::mem;

fn main() {
    if cfg!(target_endian = "little") {
        println!("This system is little-endian");
    } else {
        println!("This system is big-endian");
    }

    let num: u32 = 0x12345678;
    let bytes = num.to_le_bytes(); // Convert to little-endian
    println!("Little-endian representation: {:?}", bytes);
}
```

---

### **Converting Between Endianness**

Rust provides conversion methods in integer types:

- **`to_le_bytes()`** → Convert to little-endian
- **`to_be_bytes()`** → Convert to big-endian
- **`from_le_bytes()`** → Read from little-endian bytes
- **`from_be_bytes()`** → Read from big-endian bytes

Example:

```rust
let num: u32 = 0x12345678;
let le = num.to_le_bytes(); // [0x78, 0x56, 0x34, 0x12]
let be = num.to_be_bytes(); // [0x12, 0x34, 0x56, 0x78]
```

---

**Analogy**

Think of endianness like **writing a date**:

- **Big-endian:** `2024-01-30` (Year first, most significant part first)
- **Little-endian:** `30-01-2024` (Day first, least significant part first)

Both represent the same information, but the order changes based on convention.

---

**Key Takeaways**

- **Big-endian** stores the **most significant byte first**.
- **Little-endian** stores the **least significant byte first**.
- **Rust provides built-in functions** for handling endianness conversions.
- **Endianness matters in networking, cross-platform development, and file formats**.



# Operations

## Iterating Over A Collection

In Rust, when you iterate over a collection like a vector using a for loop, using or not using the & impacts ownership and borrowing. Here’s the difference between the two approaches:

### 1. Iterating without & (Taking Ownership)

When you iterate over a vector without &, each element is moved out of the vector. This means after the loop, the original vector can no longer be used because the values inside it have been transferred elsewhere.

**Example**:

```rust
let v = vec![1, 2, 3, 4, 5];

for val in v {
    println!("{}", val);  // The elements are moved here
}

// `v` cannot be used anymore here, because its values were moved
// println!("{:?}", v); // This would cause a compile-time error
```

**Explanation**:

Each element in the vector v is moved into the for loop, and the ownership is transferred to the loop body.

After the iteration is done, you no longer own the vector v, so you cannot access or reuse v later in your code. The vector is invalid after the loop.


### 2. Iterating with & (Borrowing)

When you iterate over a vector with &, you are borrowing each element, rather than taking ownership of it. This allows you to read the elements without moving them, so you can still use the original vector after the loop.

**Example**:

```rust
let v = vec![1, 2, 3, 4, 5];

for &val in &v {  // Borrowing each element
    println!("{}", val);  // The elements are only borrowed here
}

println!("{:?}", v);  // `v` can still be used after the loop
```

**Explanation**:

The &v in the for loop means you're iterating over references to the elements of the vector, not the elements themselves.

The elements are borrowed, not moved, so ownership of the vector is not transferred. This allows you to still use v after the loop.

Since you only borrowed the elements, the original vector remains intact and can be accessed after the loop.


### Why Use &?

To Avoid Moving Ownership: If you don’t want to transfer ownership of the elements, you should borrow them using &. This way, the vector remains valid after the loop.

To Preserve the Collection: Often, you need to reuse or keep the original collection intact after iterating over it, so borrowing allows you to safely read its contents without invalidating it.

## Mutating the Values of a Collection

You can mutate the values of a vector in Rust, but you need to borrow the vector mutably to do so. This means that the vector itself must be declared as mut, and when iterating or accessing its elements, you need to use a mutable reference (&mut).

Here are the two main ways to mutate the elements of a vector:

### 1. Mutating Elements Directly via Indexing

You can directly mutate the elements of a vector using indexing with [].

**Example**:

```rust
fn main() {
    let mut v = vec![1, 2, 3, 4, 5];  // Declare the vector as mutable

    v[0] = 10;  // Change the first element

    println!("{:?}", v);  // Output: [10, 2, 3, 4, 5]
}
```

### 2. Mutating Elements by Iterating Mutably

You can also iterate mutably over the vector using a for loop with &mut to mutate the values in place.

**Example**:

```rust
fn main() {
    let mut v = vec![1, 2, 3, 4, 5];  // Declare the vector as mutable

    // Mutably iterate over the vector
    for elem in &mut v {
        *elem *= 2;  // Double each element
    }

    println!("{:?}", v);  // Output: [2, 4, 6, 8, 10]
}
```

**Explanation**:

- `&mut v` is a mutable borrow of the vector.
- The `for elem in &mut v` loop iterates over mutable references to the elements of the vector.
- `*elem` dereferences the mutable reference to access the value, which can then be modified.

**Important Notes**:

You need to declare the vector as mut to allow mutation.

When mutably borrowing (&mut) elements, Rust ensures that no other mutable or immutable references are being used simultaneously (ensuring borrow-checking rules are followed).

You can’t mutate elements of a vector without borrowing it mutably.


# Cases

## Using `String` as `HashMap` Keys Vs Using String Literals

When using `String` or string literals (`&str`) as keys in a `HashMap` in Rust, the key difference between the two revolves around **ownership** and **memory management**. Each choice has implications for memory usage, borrowing rules, and performance. Here's an overview of the differences between using `String` and `&str` as keys in a `HashMap`.

**Ownership**
- **`String`:** 
  - A `String` is an owned, heap-allocated string in Rust. When you use `String` as a key, the `HashMap` takes ownership of the key. 
  - This means the `HashMap` will own the string and manage its memory for you. If the key string is no longer needed elsewhere, this is usually the more straightforward option.
  
  **Example:**
  ```rust
  use std::collections::HashMap;

  let mut map = HashMap::new();
  let key = String::from("Blue");
  map.insert(key, 10); // `key` is moved into the HashMap
  ```

- **`&str`:** 
  - A string literal (`&str`) is an immutable reference to a string slice. If you use `&str` as a key, you're using a borrowed value.
  - The lifetime of the `&str` needs to be valid for as long as the `HashMap` uses it, which can be tricky since `HashMap` will not own the `&str`.
  
  **Example:**
  ```rust
  use std::collections::HashMap;

  let mut map = HashMap::new();
  let key = "Blue";  // string literal
  map.insert(key, 10);  // inserting the reference as the key
  ```

**Memory Allocation**
- **`String`:**
  - A `String` allocates memory on the heap, making it flexible and able to grow dynamically. Each key in the `HashMap` is a distinct owned value, allowing multiple unique strings, even with the same content, to exist.
  
  **Implication:**
  - Using `String` results in more heap allocations but gives you more flexibility, especially if you need to create or modify strings dynamically.

- **`&str`:**
  - String literals (`&str`) are stored in the program's binary and don't require heap allocation. They are static and immutable.
  - If you use string slices from a larger string (e.g., substrings or parts of other strings), they are borrowed references and do not require additional allocation.
  
  **Implication:**
  - Using `&str` is more memory-efficient when the key can remain borrowed and static, but it requires more careful lifetime management.

**Performance**
- **`String`:**
  - Since `String` involves heap allocation and ownership transfer, using it may have a slight performance overhead due to heap operations (e.g., copying, moving the string).
  - However, in practice, this overhead is usually negligible unless you’re working with a massive number of key insertions or very large strings.

- **`&str`:**
  - Using `&str` as keys is generally faster because you avoid heap allocation and simply work with references.
  - However, Rust's borrowing rules mean you’ll need to manage lifetimes carefully, which can add complexity.

**Flexibility**
- **`String`:**
  - A `String` is mutable and can be changed, resized, and manipulated dynamically. It is suitable when you need to build keys programmatically (e.g., concatenating strings).
  
- **`&str`:**
  - String literals (`&str`) are immutable and cannot be modified. They are best for static data or when you can safely borrow the key from another source (like from a `String` or another data structure).

**When to Use `String`**
- Use `String` when:
  - You need to store dynamically created or modified strings.
  - You want the `HashMap` to take ownership of the key, and managing lifetimes of references is not ideal.
  - You prefer not to manage lifetimes manually and need to deal with data that won't always be static.

**When to Use `&str`**
- Use `&str` when:
  - The keys are static, known at compile time, and won't change (e.g., for config options, command names).
  - You want to avoid heap allocations and don’t mind managing the lifetime of the borrowed references.
  - You want to perform lookups where you don't want to pass ownership of the key.

**Examples for Both**:

1. **Using `String` as HashMap Keys:**
   ```rust
   use std::collections::HashMap;

   let mut map = HashMap::new();
   let key = String::from("Blue");
   map.insert(key, 10);  // HashMap takes ownership of the String
   ```

2. **Using `&str` as HashMap Keys:**
   ```rust
   use std::collections::HashMap;

   let mut map = HashMap::new();
   let key = "Blue";  // string literal (&'static str)
   map.insert(key, 10);  // HashMap borrows the reference
   ```

3. **Comparing Lookup:**
   - **With `String`:**
     ```rust
     let key = String::from("Blue");
     let score = map.get(&key);  // `String` needs to be referenced to perform the lookup
     ```

   - **With `&str`:**
     ```rust
     let score = map.get("Blue");  // No referencing needed for lookup, as it's already a reference
     ```

**Conclusion**:
- **`String`** provides more flexibility, but with a slight performance and memory allocation cost.
- **`&str`** is more memory efficient, faster, but requires you to manage the borrowing and lifetimes.

# Core

## `usize` Datatype

`usize` is a primitive data type in Rust that represents an **unsigned** integer, and its size depends on the architecture of the system (either 32-bit or 64-bit). It's used primarily for indexing and size-related operations, such as indexing arrays, slices, or vectors, and dealing with memory sizes.

**Key Characteristics of `usize`:**
1. **Architecture-dependent size**:
   - On a **32-bit system**, `usize` is **32 bits** (4 bytes) wide.
   - On a **64-bit system**, `usize` is **64 bits** (8 bytes) wide.
   - This makes it appropriate for addressing memory, as its size matches the size of the system's memory address space.

2. **Unsigned**:
   - `usize` can only store non-negative values (no negative numbers).
   - The range of values for `usize` depends on the architecture:
     - On a 32-bit system: $0$ to $2^{32} - 1$ (4,294,967,295)
     - On a 64-bit system: $0$ to $2^{64} - 1$ (18,446,744,073,709,551,615)

3. **Common Uses**:
   - **Array indexing**: When accessing elements of an array, slice, or vector, the index must be of type `usize`.
     ```rust
     let arr = [10, 20, 30, 40];
     let index: usize = 2;
     println!("{}", arr[index]); // prints 30
     ```
   - **Memory sizes**: `usize` is also commonly used when dealing with memory sizes, such as the length of a slice or the capacity of a vector.
     ```rust
     let vec = vec![1, 2, 3];
     let size: usize = vec.len(); // len() returns usize
     ```

### Conversion with Other Types:
Rust provides methods to convert other numeric types to `usize` or convert `usize` to other types, like `u32`, `u64`, etc.

- **From integer to `usize`**:
  ```rust
  let x: i32 = 10;
  let y: usize = x as usize; // Explicit casting
  ```

- **From `usize` to integer**:
  ```rust
  let x: usize = 20;
  let y: u32 = x as u32;
  ```

### Methods Related to `usize`:
Since `usize` is an unsigned integer type, it inherits methods from Rust's integer primitives. Common methods include:

- **max_value()**: Returns the largest value that can be represented by `usize`.
  ```rust
  let max = usize::MAX;
  ```

- **min_value()**: Returns the smallest value, which is always 0.
  ```rust
  let min = usize::MIN;
  ```

- **checked_add(), checked_sub(), checked_mul()**: Performs arithmetic operations that return `None` if an overflow occurs.
  ```rust
  let a: usize = usize::MAX;
  let b = a.checked_add(1); // None, since this overflows
  ```

**Examples**:

- **Array/Slice indexing**:
  ```rust
  let arr = [1, 2, 3, 4];
  let idx: usize = 2;
  println!("{}", arr[idx]); // prints 3
  ```

- **Memory sizes**:
  ```rust
  let vec = vec![10, 20, 30];
  let size: usize = vec.len(); // len() returns usize
  println!("Size of vec: {}", size);
  ```

**Summary**:
- `usize` is a platform-dependent unsigned integer, useful for representing sizes and indexing collections.
- Its size is 32 bits on 32-bit systems and 64 bits on 64-bit systems, matching the addressable memory space.
- It's commonly used for array indexing, working with memory sizes, and interacting with low-level operations in Rust.

## **Associated Types**  

In Rust, **associated types** are a way to define a placeholder type within a trait. These types act as part of the trait’s interface, allowing implementors of the trait to specify what type they will use. This can make traits more ergonomic and easier to use compared to having to specify generic parameters everywhere.

---

**Definition**  
An associated type is declared in a trait using the `type` keyword. When implementing the trait, the implementor must define the concrete type for the associated type.

---

**Example**  

**Trait with an Associated Type:**
```rust
trait Iterator {
    type Item; // Associated type
    fn next(&mut self) -> Option<Self::Item>;
}
```

**Implementing the Trait:**
```rust
struct Counter;

impl Iterator for Counter {
    type Item = u32; // Define the associated type

    fn next(&mut self) -> Option<Self::Item> {
        Some(1) // Example implementation
    }
}
```

**Usage:**
```rust
let mut counter = Counter;
println!("{:?}", counter.next()); // Prints: Some(1)
```

---

### **Benefits of Associated Types**  
1. **Simplifies Syntax:**  
   Instead of specifying generic parameters repeatedly, associated types simplify the trait interface.
   ```rust
   // Without associated types:
   trait Example<T> {
       fn example(&self, value: T);
   }

   // With associated types:
   trait Example {
       type Item;
       fn example(&self, value: Self::Item);
   }
   ```

2. **Improves Readability:**  
   Traits with associated types often look cleaner and are easier to understand compared to using many generic parameters.

3. **Flexibility for Implementors:**  
   Each implementor can define its own concrete type for the associated type, allowing for more tailored implementations.

---

**More Advanced Example**

**Associated Types in a Custom Trait:**
```rust
trait KeyValueStore {
    type Key;
    type Value;

    fn set(&mut self, key: Self::Key, value: Self::Value);
    fn get(&self, key: &Self::Key) -> Option<&Self::Value>;
}
```

**Implementing the Trait for a HashMap:**
```rust
use std::collections::HashMap;

struct MyStore {
    store: HashMap<String, String>,
}

impl KeyValueStore for MyStore {
    type Key = String;
    type Value = String;

    fn set(&mut self, key: Self::Key, value: Self::Value) {
        self.store.insert(key, value);
    }

    fn get(&self, key: &Self::Key) -> Option<&Self::Value> {
        self.store.get(key)
    }
}
```

**Usage:**
```rust
let mut store = MyStore {
    store: HashMap::new(),
};

store.set("username".to_string(), "alice".to_string());
println!("{:?}", store.get(&"username".to_string())); // Prints: Some("alice")
```

---

### **Associated Types vs Generics**

Both **generics** and **associated types** enable Rust traits to work with multiple types, but they serve different purposes and have different trade-offs.

---

#### **Generics (`<T>` in Traits)**

Generics allow a trait to take a type parameter, making it flexible and reusable.

**Example: Generic Trait**

```rust
trait Container<T> {
    fn contains(&self, item: T) -> bool;
}
```

Here, `Container<T>` is generic, meaning the trait can be implemented for any type `T`.

**Implementation Example**

```rust
struct VecContainer<T> {
    elements: Vec<T>,
}

impl<T: PartialEq> Container<T> for VecContainer<T> {
    fn contains(&self, item: T) -> bool {
        self.elements.contains(&item)
    }
}
```

**Advantages of Generics**

✔ **More flexible:** Can implement the same trait for different types (`Container<i32>`, `Container<String>`, etc.).  
✔ **Easier to use with multiple type parameters.**

**Disadvantages of Generics**

❌ **Increased compile-time complexity** (each new type creates a separate monomorphized version).  
❌ **Can make type inference harder** when multiple types are involved.

---

#### **Associated Types (`type` in Traits)**

Associated types define an output type within a trait itself, rather than requiring the user to specify a generic type when implementing the trait.

**Example: Associated Type Trait**

```rust
trait Container {
    type Item;  // Defines an associated type

    fn contains(&self, item: Self::Item) -> bool;
}
```

Here, `Self::Item` is an associated type, meaning each implementation of `Container` **must specify what `Item` is**.

**Implementation Example**

```rust
struct StringContainer {
    elements: Vec<String>,
}

impl Container for StringContainer {
    type Item = String; // Defining the associated type

    fn contains(&self, item: Self::Item) -> bool {
        self.elements.contains(&item)
    }
}
```

**Advantages of Associated Types**

✔ **More concise and readable** when the type is fixed for an implementation.  
✔ **Better for defining complex relationships between types** (e.g., `Iterator::Item`).

**Disadvantages of Associated Types**

❌ **Less flexible** (the type is locked for each implementation).  
❌ **Cannot be used with multiple type parameters as easily as generics.**

---

**Key Differences & When to Use**

|Feature|Generics (`<T>`)|Associated Types (`type`)|
|---|---|---|
|**Flexibility**|Can implement for multiple types|Fixed type per implementation|
|**Readability**|Can get verbose with multiple parameters|More concise in some cases|
|**Use Case**|When the same trait can work with many types|When a trait always has a fixed output type|
|**Performance**|More monomorphization (potential code bloat)|More compact binary size|

---

**Analogy**

- **Generics (`<T>`)** → Like a **recipe book** where you specify different ingredients (`T`) each time you cook.
- **Associated Types (`type`)** → Like a **specific dish** where the ingredients are **predefined** in the recipe.

---

## **Type Equality**  

Rust does **not** support loose equality. Comparisons in Rust are always **strict**, and types must be compatible. Rust provides the `PartialEq` and `Eq` traits for equality comparisons.  

**Examples in Rust**  
```rust
let x = 5;
let y = "5";

// This won't compile because Rust enforces strict type equality:
println!("{}", x == y); // Error: mismatched types
```

Rust requires values to have the same type for equality comparisons. If you need to compare values of different types, you must explicitly convert them yourself:  
```rust
let x = 5;
let y = "5";

if x.to_string() == y {
    println!("They are equal");
}
```

---

**Key Takeaways**
- Rust does not perform **loose equality**; all comparisons are **strict** and type-safe.
- In Rust, equality is implemented through the `PartialEq` and `Eq` traits, which must be derived or implemented for custom types to enable comparisons.
- Strict equality avoids bugs caused by implicit type conversions, ensuring clearer and safer code.  

By enforcing strict type equality, Rust ensures type safety, reducing potential runtime errors often seen in languages with loose equality semantics.


---

## **`String` vs `OsString`**  

In Rust, both `String` and `OsString` are used to represent strings, but they have distinct purposes and characteristics:

---

### **String**
- **Definition:** A UTF-8 encoded, growable string type owned by the program.
- **Use Case:** Used when you need to work with standard Unicode text, such as processing or storing human-readable strings.
- **Platform-Independent:** Works the same across all operating systems because it only supports valid UTF-8.

**Example:**
```rust
let string = String::from("Hello, world!");
println!("{}", string);
```

**Key Features:**
- Supports Unicode (UTF-8) encoding.
- Can be converted to `&str` (string slices).
- Provides methods like `.push_str()` and `.to_uppercase()` for manipulation.

**Limitations:**
- Cannot represent OS-specific non-UTF-8 paths or strings.
  
---

### **OsString**
- **Definition:** A string type that can hold platform-specific strings (which may or may not be valid UTF-8).
- **Use Case:** Used for system-level tasks, such as dealing with file paths or environment variables, which may include non-Unicode data.
- **Platform-Dependent Encoding:**
  - On Unix, `OsString` is encoded as bytes.
  - On Windows, `OsString` is encoded as wide Unicode (UTF-16).

**Example:**
```rust
use std::ffi::OsString;

let os_string = OsString::from("C:\\Program Files");
println!("{:?}", os_string);
```

**Key Features:**
- Suitable for low-level OS interactions.
- Can store non-UTF-8 data.
- Often used in conjunction with `Path` and `PathBuf` for working with file paths.

**Limitations:**
- Harder to manipulate directly compared to `String`.
- Requires conversion for operations like string manipulation (e.g., `.to_string_lossy()`).

---

**Differences**

| **Feature**          | **String**                        | **OsString**                  |
|-----------------------|------------------------------------|--------------------------------|
| **Encoding**          | UTF-8                            | Platform-dependent            |
| **Use Case**          | Human-readable text              | OS-specific strings (e.g., file paths, env vars) |
| **Platform-Independent?** | Yes                            | No                             |
| **Conversion**        | Easily converted to `&str`       | Requires `.to_string_lossy()` or `.to_string()` (may lose data) |
| **Performance**       | Generally faster due to UTF-8    | More overhead for conversions |

---

**When to Use**

- Use **`String`**:
  - When working with general-purpose text.
  - When you know the data will always be valid UTF-8.

- Use **`OsString`**:
  - When working with OS-specific strings, like file paths or environment variables.
  - When handling potentially non-UTF-8-compatible data.

By understanding the differences between `String` and `OsString`, you can choose the right type for the specific requirements of your application.

## String Capacity

In Rust, when dealing with `String` metadata, two important properties often come up: **capacity** and **size** (or length). These are related to how `String` works internally and are critical for understanding memory usage and performance.

---

**Size (or Length)**

The **size** of a string refers to the number of bytes currently stored in the `String`.

- It represents the length of the string in bytes, not necessarily the number of characters (since some characters in UTF-8 can take multiple bytes).
- The size is dynamic and changes as you modify the string (e.g., by adding or removing characters).

**Method**:
- Use `.len()` to get the size of the string.

**Example**:
```rust
let s = String::from("Hello");
println!("Size: {}", s.len()); // Size: 5
```

---

**Capacity**

The **capacity** of a string refers to the amount of memory (in bytes) that the string has reserved to store its data.

- Capacity is typically greater than or equal to the size of the string.
- It determines how many bytes the string can hold before requiring a reallocation.
- Rust’s `String` optimizes performance by allocating extra memory upfront to reduce the need for frequent reallocations when appending data.

**Method**:
- Use `.capacity()` to get the capacity of the string.

**Example**:
```rust
let mut s = String::with_capacity(10); // Pre-allocate 10 bytes
println!("Capacity: {}", s.capacity()); // Capacity: 10
s.push_str("Hello");
println!("Size: {}", s.len());      // Size: 5
println!("Capacity: {}", s.capacity()); // Capacity: 10 (still the same)
s.push_str(" World!");
println!("Size: {}", s.len());      // Size: 12
println!("Capacity: {}", s.capacity()); // Capacity increases automatically
```

---

**Key Differences**

| **Property**  | **Size (`len`)**                             | **Capacity (`capacity`)**                     |
|---------------|---------------------------------------------|-----------------------------------------------|
| **Definition**| Number of bytes currently used by the string.| Number of bytes allocated for potential growth.|
| **Dynamic?**  | Changes as you add or remove characters.     | Grows automatically when the string exceeds it.|
| **Purpose**   | Tracks how much data the string holds.       | Prevents frequent reallocations during growth. |
| **Units**     | Measured in bytes.                          | Measured in bytes.                            |

---

**Behavior**
1. If the **size** exceeds the **capacity**, the `String` will automatically allocate more memory and increase its capacity.
2. The capacity does not shrink when you reduce the size of the string. If you want to reduce the capacity, you can use the `.shrink_to_fit()` method.

**Example**:
```rust
let mut s = String::from("Rust");
println!("Size: {}", s.len());      // Size: 4
println!("Capacity: {}", s.capacity()); // Capacity: 4 (default allocation)

s.push_str(" programming"); // Appending increases size
println!("Size: {}", s.len());      // Size: 15
println!("Capacity: {}", s.capacity()); // Capacity grows automatically

s.clear(); // Clear the string
println!("Size after clear: {}", s.len()); // Size: 0
println!("Capacity after clear: {}", s.capacity()); // Capacity remains unchanged

s.shrink_to_fit(); // Reduce capacity to match size
println!("Capacity after shrink: {}", s.capacity()); // Capacity: 0
```

---

**Use Cases**
- **Size** is useful when:
  - You need to know the current amount of data stored.
  - You're validating or processing string content.
  
- **Capacity** is useful when:
  - Pre-allocating memory for performance optimization.
  - Reducing memory overhead by shrinking the capacity.

Understanding these properties helps you write more efficient Rust programs, especially when working with dynamic strings.

## Type Placeholder (`_`)

In Rust, `_` can be used in various contexts, including as a **type placeholder**. When `_` is used as a type, it essentially tells the Rust compiler to **infer the type** based on the context.

Here are some examples and explanations of how `_` is used as a type placeholder in Rust:

### 1. Type Inference in Variable Declaration

You can use `_` when you want the compiler to infer the type of a variable based on how it’s used later in the code.

```rust
let x: _ = 42; // The compiler infers that `x` is of type `i32`
```

In this example, `_` is used as a placeholder, and the Rust compiler infers `x`'s type as `i32` because `42` is an integer literal of type `i32` by default.

### 2. Type Placeholder in Function Signatures

You can also use `_` in function signatures, which allows the compiler to infer the types for some arguments. This is useful if you don’t want to specify the exact type but still want Rust to deduce it.

However, in Rust, you can’t directly write function signatures with `_` in parameters or return types (like `fn foo(x: _)`), as Rust requires explicit type annotations in public interfaces. The `_` placeholder is mostly used in the function body or generic contexts where the type can be inferred.

```rust
fn example() {
    let value: Option<_> = Some(10); // The compiler infers the type as Option<i32>
}
```

In this example, `Option<_>` allows the compiler to deduce that `value` should be `Option<i32>` based on the `Some(10)` assignment.

### 3. Type Placeholder in Generics

When using generic types, you can use `_` as a type placeholder. This is particularly useful when dealing with collections or types that use generics, such as `Vec`, `Option`, `Result`, and `HashMap`.

```rust
let numbers: Vec<_> = vec![1, 2, 3]; // The compiler infers Vec<i32>
let result: Result<_, &str> = Ok(42); // The compiler infers Result<i32, &str>
```

Here, `_` allows the compiler to deduce the inner type of `Vec` as `i32` and the `Result` type as `Result<i32, &str>` based on the context.

### 4. Using `_` with `impl Trait`

In some cases, you may see `_` in combination with `impl Trait`, especially with closures where the exact type can be complex or not explicitly specified. For example, in iterators:

```rust
fn get_iterator() -> impl Iterator<Item = _> {
    vec![1, 2, 3].into_iter()
}
```

In this example, `_` allows Rust to infer the `Item` type for the iterator as `i32`, based on the type of the vector elements.

### 5. Ignoring Parts of a Type in Pattern Matching

In Rust, `_` is often used as a **wildcard pattern** in match statements to ignore parts of a pattern. However, in the context of types, `_` is used differently, but it's essential to distinguish between the two.

```rust
let some_option: Option<_> = Some(42);
if let Some(_) = some_option {
    println!("There was a value, but we don’t care what it was.");
}
```

In this case, `_` is not used as a type placeholder but as a way to ignore the value within `Some`.

**Summary**

- **`_` as a Type Placeholder**: Allows the Rust compiler to infer the type.
  - **Variables**: `let x: _ = 42;` — infers `i32`.
  - **Generics**: `let result: Result<_, &str> = Ok(42);` — infers `Result<i32, &str>`.
  - **Collections**: `let numbers: Vec<_> = vec![1, 2, 3];` — infers `Vec<i32>`.
- **Pattern Matching**: `_` is also used as a wildcard in pattern matching but does not imply type inference in this context.

Using `_` as a type placeholder is a convenient way to let the compiler infer types without manually specifying them, which can make the code cleaner and more flexible. However, in cases where the type can't be inferred unambiguously, Rust will throw an error, prompting you to specify the type explicitly.

### `union`

A **union** in Rust is a data structure similar to a `struct`, but with a key difference: **all fields share the same memory location**. This means that a `union` can only store one of its fields at a time, making it useful for low-level programming, such as interacting with hardware or working with C-style memory layouts.

---

### **Declaring a Union**

A `union` is defined similarly to a `struct`, but it uses the `union` keyword instead:

```rust
#[repr(C)]
union MyUnion {
    int_val: u32,
    float_val: f32,
}
```

Here, `MyUnion` can store **either** an `int_val` (a `u32`) or a `float_val` (an `f32`), but **not both at the same time**.

---

### **Accessing Union Fields (Unsafe Required)**

Because Rust enforces strict memory safety, accessing a union field requires **unsafe code** to ensure that you're interpreting the memory correctly.

```rust
fn main() {
    let my_data = MyUnion { int_val: 42 }; // Store an integer

    unsafe {
        println!("Integer value: {}", my_data.int_val);
        // println!("Float value: {}", my_data.float_val); // Undefined behavior if accessed incorrectly
    }
}
```

Rust does **not** track which field was last written, so reading a field that was not explicitly set can lead to **undefined behavior**.

---

### **Why Use a Union?**

- **Memory Efficiency:** Since all fields share the same memory, unions can save space in memory-constrained environments.
- **Interfacing with C Code:** Rust's `union` can represent C-style unions when working with FFI (Foreign Function Interface).
- **Low-Level Programming:** Used in system programming, such as working with raw bits or hardware registers.

---

### **Unions vs Structs**

|Feature|Struct|Union|
|---|---|---|
|Memory|Allocates separate space for each field|Shares memory between fields|
|Safety|Safe to use|Requires `unsafe` to access fields|
|Use Case|General-purpose data organization|Low-level, memory-efficient data manipulation|

---

**Example: Using a Union for Type Conversion**

```rust
#[repr(C)]
union IntFloat {
    int: u32,
    float: f32,
}

fn main() {
    let data = IntFloat { int: 1065353216 }; // 1065353216 is 1.0 in IEEE 754 floating-point representation

    unsafe {
        println!("Interpreted as integer: {}", data.int);
        println!("Interpreted as float: {}", data.float); // Prints 1.0
    }
}
```

Here, the same memory is interpreted as both an integer and a float, demonstrating how unions can be used for bit-level operations.

---

**Key Takeaways**

- A `union` allows multiple fields to share the **same** memory.
- Only **one** field should be used at a time.
- Accessing fields requires **unsafe** code.
- Useful for **FFI, low-level programming, and memory efficiency**.
- **Rust does not track which field is active**, so using the wrong field can lead to **undefined behavior**.


## Question Mark Operator

The **question mark (`?`) operator** in Rust is a shorthand for handling errors when working with types that implement the `Result` or `Option` type. It allows you to easily propagate errors or early exits without needing to manually write error-handling boilerplate code.

**How It Works**

When you use `?` on a `Result` or `Option`:

1. If the result is `Ok(T)` (or `Some(T)` for `Option`), it extracts the `T` value and continues execution.
2. If the result is `Err(E)` (or `None` for `Option`), it immediately returns the error (or `None`) from the function that called it, effectively short-circuiting the execution.

**Example with `Result**`

Let’s break it down with an example:

```rust
use std::fs::File;
use std::io::{self, Read};

fn read_file_content() -> Result<String, io::Error> {
    let mut file = File::open("hello.txt")?; // If this fails, the error is returned immediately
    let mut content = String::new();
    file.read_to_string(&mut content)?; // If this fails, the error is returned immediately
    Ok(content) // If everything works, the content is returned
}
```

- `File::open("hello.txt")?`: 
  - If the file opens successfully (`Ok(File)`), the file handle is assigned to `file`.
  - If the file can't be opened (e.g., it doesn't exist), the `?` operator automatically returns the `Err(io::Error)` to the caller.

- `file.read_to_string(&mut content)?`:
  - If the reading of the file into the string works (`Ok(usize)`), it continues.
  - If the reading fails, `?` returns the `Err(io::Error)` to the caller.

Without the `?` operator, the same code would require more manual error handling like this:

```rust
fn read_file_content() -> Result<String, io::Error> {
    let mut file = match File::open("hello.txt") {
        Ok(f) => f,
        Err(e) => return Err(e),
    };

    let mut content = String::new();
    match file.read_to_string(&mut content) {
        Ok(_) => Ok(content),
        Err(e) => return Err(e),
    }
}
```

### How `?` Works Internally

- When `?` is used on a `Result<T, E>`, it expands to something like this:

  ```rust
  match result {
      Ok(value) => value,
      Err(err) => return Err(err),
  }
  ```

- When used on `Option<T>`, it expands to:

  ```rust
  match option {
      Some(value) => value,
      None => return None,
  }
  ```

### Requirements

- The `?` operator can only be used in functions that return a `Result` or an `Option` because it needs a context to propagate the error or `None`.
  
- In the case of `Result`, the error type of the function and the error type you’re working with must be the same or convertible through `From`.

**Example with `Option`**

```rust
fn get_element(vec: &Vec<i32>, index: usize) -> Option<i32> {
    let value = vec.get(index)?; // Propagates None if index is out of bounds
    Some(*value)
}

fn main() {
    let numbers = vec![1, 2, 3];
    println!("{:?}", get_element(&numbers, 1)); // Some(2)
    println!("{:?}", get_element(&numbers, 5)); // None
}
```

**`?` with `Option` and Early Exit**

When used with `Option`, `?` will propagate `None` if an operation fails:

```rust
fn divide_by_three(num: Option<i32>) -> Option<i32> {
    let n = num?; // Returns None if num is None
    Some(n / 3)
}

fn main() {
    let result = divide_by_three(Some(9)); // Some(3)
    let result_none = divide_by_three(None); // None
}
```

**Summary**

- The `?` operator in Rust is a convenient way to propagate errors or handle `None` values without verbose match statements.
- It can only be used in functions that return `Result` or `Option` (or other types implementing `Try`).
- It simplifies code by reducing the need for manual error checking and short-circuits when errors or `None` are encountered.

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

## `if let`

The `if let` construct in Rust is a shorthand way to match specific patterns within a `match` expression, but with less boilerplate. It is commonly used when you only care about one particular pattern and want to ignore the rest.

**Syntax and Usage**

The syntax of `if let` is:

```rust
if let pattern = expression {
    // code to execute if the pattern matches
}
```

In this construct:
- `pattern` is the pattern you want to match.
- `expression` is the expression you want to evaluate and match against the pattern.

If the pattern matches, the code inside the `if let` block runs. If it doesn’t match, the `if let` block is skipped (you can add an `else` block to handle the non-matching case).

### Example 1: Using `if let` with `Option<T>`

```rust
let some_option = Some(5);

if let Some(value) = some_option {
    println!("The value is: {}", value);
} else {
    println!("No value found");
}
```

- In this example, `if let Some(value) = some_option` checks if `some_option` contains `Some` and, if so, binds the inner value to `value`. 
- If `some_option` is `None`, it would skip the `if` block and go to the `else` block.

### Example 2: Using `if let` with `Result<T, E>`

```rust
let some_result: Result<i32, &str> = Ok(10);

if let Ok(value) = some_result {
    println!("Success with value: {}", value);
} else {
    println!("Operation failed");
}
```

- Here, `if let Ok(value) = some_result` checks if `some_result` contains `Ok` and binds the inner value to `value`.
- If `some_result` is `Err`, it skips to the `else` block.

### Example 3: Ignoring Other Patterns with `if let`

The main benefit of `if let` is that it allows you to handle one specific case without needing to write a full `match` statement for all cases. For example:

```rust
let favorite_color: Option<&str> = None;

if let Some(color) = favorite_color {
    println!("Your favorite color is: {}", color);
}
```

- In this case, we only care about the `Some` variant, so we use `if let` to check if `favorite_color` has a value and ignore the `None` case.

### Example 4: `if let` with an `else` Block

If you want to handle the case where the pattern doesn’t match, you can add an `else` block:

```rust
let age: Option<u32> = Some(25);

if let Some(age) = age {
    println!("The age is: {}", age);
} else {
    println!("No age provided");
}
```

- Here, if `age` is `Some`, it prints the age; otherwise, it goes to the `else` block.

### Why Use `if let`?

`if let` is particularly useful when:
- You only care about one specific pattern and want to ignore others.
- You want a more concise syntax than a full `match` statement.

### Comparison with `match`

Using `match` for the same purpose as `if let` would look like this:

```rust
let some_option = Some(5);

match some_option {
    Some(value) => println!("The value is: {}", value),
    None => println!("No value found"),
}
```

While `match` is more powerful and allows you to handle multiple patterns, `if let` provides a concise way to handle just one specific pattern.

**Summary**

- **`if let`** is a shorthand for matching a specific pattern, useful when you only care about one case.
- It’s commonly used with **`Option`** and **`Result`** types.
- Can be combined with an **`else`** block to handle non-matching cases.

## `while let`

The `while let` construct in Rust is used to run a loop as long as a pattern matches a value. It’s similar to `if let`, but instead of just checking once, it keeps running the loop body as long as the pattern continues to match.

This is useful for iterating over `Option` or `Result` types (or any pattern) until a certain condition is no longer met. It allows you to avoid writing a potentially complex `loop` with `match` statements inside.

**Syntax**

```rust
while let PATTERN = EXPRESSION {
    // loop body
}
```

### Example: Unwrapping an Option

Here's an example where we keep unwrapping an `Option` until it becomes `None`:

```rust
fn main() {
    let mut values = Some(10);

    while let Some(x) = values {
        println!("Current value: {}", x);

        // Modify `values` to eventually break the loop
        values = if x > 0 { Some(x - 1) } else { None };
    }

    println!("Loop ended");
}
```

Output:
```
Current value: 10
Current value: 9
Current value: 8
...
Current value: 1
Current value: 0
Loop ended
```

Explanation:
- `while let Some(x) = values` runs the loop as long as `values` is `Some(x)`.
- Each time through the loop, `x` is decreased until `values` becomes `None`, at which point the loop stops.

### Example: Iterating over a Vector with `pop`

Here’s another example where `while let` is used to pop elements from a vector until it’s empty:

```rust
fn main() {
    let mut stack = vec![1, 2, 3, 4, 5];

    while let Some(top) = stack.pop() {
        println!("Popped value: {}", top);
    }

    println!("Stack is empty");
}
```

Output:
```
Popped value: 5
Popped value: 4
Popped value: 3
Popped value: 2
Popped value: 1
Stack is empty
```

Explanation:
- `stack.pop()` returns an `Option` with `Some(value)` if there’s an element to pop, or `None` if the vector is empty.
- `while let Some(top) = stack.pop()` keeps popping and printing values until `stack.pop()` returns `None`.

### Example: Reading from an Iterator

You can also use `while let` to read items from an iterator until there are no more items:

```rust
fn main() {
    let mut iter = vec![10, 20, 30].into_iter();

    while let Some(value) = iter.next() {
        println!("Next value: {}", value);
    }

    println!("No more values in iterator");
}
```

Output:
```
Next value: 10
Next value: 20
Next value: 30
No more values in iterator
```

Explanation:
- `iter.next()` returns `Some(value)` until there are no more items, at which point it returns `None`.
- `while let` will keep looping until there are no more values left in the iterator.

### Example: Working with `Result`

You can also use `while let` with `Result` types to keep processing until an error occurs:

```rust
fn main() {
    let mut results = vec![Ok(1), Ok(2), Err("error"), Ok(3)];

    while let Some(Ok(value)) = results.pop() {
        println!("Got value: {}", value);
    }

    println!("Finished processing results");
}
```

Output:
```
Got value: 3
Got value: 2
Got value: 1
Finished processing results
```

Explanation:
- We use `while let Some(Ok(value))` to only process the `Ok` values in the `results` vector.
- The loop stops once it encounters the `Err("error")` or when the vector is empty.

### Example: Working With Custom Enums

If you have a custom enum, you can match any variant with `while let`, not just `Some`. Here’s an example:

```rust
enum MyEnum {
    VariantA(i32),
    VariantB(String),
}

fn main() {
    let mut items = vec![
        MyEnum::VariantA(42),
        MyEnum::VariantB(String::from("Hello")),
        MyEnum::VariantA(7),
    ];

    while let Some(MyEnum::VariantA(value)) = items.pop() {
        println!("Got VariantA with value: {}", value);
    }

    println!("No more VariantA items");
}
```

In this example, we're only processing `VariantA` items and ignoring `VariantB`.

### Example: Working With Other Patterns

You can use `while let` with any pattern, such as tuple patterns, array destructuring, or even references. Here are a few examples:

#### Tuple Patterns

```rust
fn main() {
    let mut pairs = vec![(1, "one"), (2, "two"), (3, "three")];

    while let Some((number, word)) = pairs.pop() {
        println!("Number: {}, Word: {}", number, word);
    }
}
```

#### Array Destructuring

```rust
fn main() {
    let mut arrays = vec![[1, 2, 3], [4, 5, 6], [7, 8, 9]];

    while let Some([a, b, c]) = arrays.pop() {
        println!("Array elements: {}, {}, {}", a, b, c);
    }
}
```

#### Using References

```rust
fn main() {
    let words = vec!["apple", "banana", "cherry"];
    let mut iter = words.iter();

    while let Some(&word) = iter.next() {
        println!("Word: {}", word);
    }
}
```

In this example, `Some(&word)` is used to match a reference to each word in the iterator.

**Summary**

- `while let` is useful for repeatedly matching a pattern until it no longer matches.
- It’s commonly used with `Option`, `Result`, or any iterable structure.
- It provides a more concise alternative to a `loop` with a `match` inside it.

## `'static` Lifetime

In Rust, the `'static` lifetime is a **special lifetime** that represents data that **lives for the entire duration of the program**. Data with the `'static` lifetime is stored in the program's binary or in a part of memory that persists as long as the program runs.

Here are some common scenarios where the `'static` lifetime is used:

1. **String Literals**

String literals, like `"hello"`, have a `'static` lifetime because they are hardcoded into the binary of the program and therefore live for the entire duration of the program.

```rust
let s: &'static str = "I have a static lifetime";
```

In this example, `s` is a `&'static str`. The string `"I have a static lifetime"` is stored in the binary and will remain accessible as long as the program runs.

2. **Static Variables**

Variables defined with the `static` keyword also have a `'static` lifetime, since they are meant to persist for the whole program.

```rust
static HELLO: &str = "Hello, world!";

fn main() {
    println!("{}", HELLO);
}
```

`HELLO` has a `'static` lifetime, and its value can be accessed anywhere within the program without any restrictions on lifetimes.

> **Note**: While `static` variables are `'static`, it’s often recommended to avoid mutable `static` variables (`static mut`) due to thread safety issues.

3. **`'static` Bound in Generics**

When working with generic types or trait bounds, the `'static` lifetime can be used as a constraint to ensure that the data being referenced will live for the entire duration of the program.

For instance, if you’re working with a generic type `T` that must have a `'static` lifetime, you can specify this with `T: 'static`.

```rust
fn takes_static<T: 'static>(value: T) {
    // value has a 'static lifetime
}
```

This function `takes_static` only accepts types `T` that do not have any non-`'static` references within them, effectively requiring that `T` can "live" for the entire duration of the program.

4. **`'static` in Closures and Threads**

When using threads, `'static` is often required for data because threads can outlive the scope in which they were created. For example, when passing data to a thread, Rust requires that the data has a `'static` lifetime to avoid potential dangling references.

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        println!("Running in a thread!");
    });
    
    handle.join().unwrap();
}
```

In this example, the closure `|| { println!("Running in a thread!"); }` does not capture any variables with non-`'static` references, so it’s safe to spawn a thread. If you were to capture variables from an outer scope, Rust would require that they have a `'static` lifetime to ensure they don’t get dropped while the thread is still running.

5. **Owned Types (e.g., `String`, `Vec<T>`) are `'static**`

Owned types like `String`, `Vec<T>`, `Box<T>`, etc., are `'static` because they own their data and don’t borrow it from somewhere else. This means you can often use owned types in contexts that require `'static` data since they don’t have any lifetimes tied to an outer scope.

```rust
let s: String = String::from("Hello");
```

In this example, `s` is a `String`, which is an owned type and can theoretically live as long as you want it to, though it’s dropped when it goes out of scope. You can pass `s` to a function that requires a `'static` value by moving it into that function.

**Summary**

- `'static` means that the data lives for the entire duration of the program.
- Common examples of `'static` data include **string literals** and **`static` variables**.
- The `'static` lifetime is often used as a **bound in generics** or **threaded code** to ensure data is valid for the required duration.
- **Owned types** (like `String` and `Vec`) can be treated as `'static` because they don’t depend on references from other scopes.

**Practical Example**

Here’s a practical example of using `'static` in a threaded context:

```rust
use std::thread;

fn main() {
    let greeting: &'static str = "Hello, world!";
    
    let handle = thread::spawn(move || {
        println!("{}", greeting);
    });
    
    handle.join().unwrap();
}
```

In this example, `greeting` has a `'static` lifetime, so it’s safe to use in the thread. Since `"Hello, world!"` is a string literal, it lives for the entire program duration, which meets the requirements for spawning the thread without lifetime issues.

## Static Variables

Rust allows defining **static variables** using the `static` keyword. Unlike regular variables (`let`), **static variables have a fixed memory location and exist for the entire program's lifetime**.

---

**Declaring a Static Variable**

```rust
static GREETING: &str = "Hello, world!";
fn main() {
    println!("{}", GREETING);
}
```

✅ **Key points:**

- `static` variables are stored in a **fixed memory location**.
- The value **must be a constant expression** (no runtime initialization).
- They live **for the entire program** (`'static` lifetime).

---

### **`mut` and `unsafe` with Static Variables**

Mutable static variables require **`unsafe`** because **Rust does not enforce thread safety**.

```rust
static mut COUNTER: i32 = 0;

fn increment() {
    unsafe {
        COUNTER += 1;
    }
}

fn main() {
    unsafe {
        println!("Counter: {}", COUNTER);
        increment();
        println!("Counter: {}", COUNTER);
    }
}
```

✅ **Why `unsafe`?**

- Multiple threads could modify `COUNTER`, leading to **data races**.
- Rust forces you to acknowledge **potential unsafety** explicitly.

---

### **Difference Between `static` and `const`**

|Feature|`static`|`const`|
|---|---|---|
|**Memory Location**|Fixed address in memory|Inlined at usage points|
|**Mutability**|Can be `mut` (requires `unsafe`)|Always immutable|
|**Thread Safety**|Needs `unsafe` for `mut`|Always thread-safe|
|**Use Case**|Long-lived values (e.g., global settings)|Compile-time constants|

**Example:**

```rust
static MESSAGE: &str = "Static lives forever!";
const PI: f64 = 3.1415;
```

---

### **Static References and `'static` Lifetime**

Since static variables exist **for the whole program**, references to them have a `'static` lifetime.

```rust
fn get_message() -> &'static str {
    static MESSAGE: &str = "Hello, world!";
    MESSAGE
}
```

✅ The returned reference **never becomes invalid**.

---

### **Using `Atomic` Types for Thread Safety**

For **safe mutable static variables**, use **atomic types** from `std::sync::atomic`.

```rust
use std::sync::atomic::{AtomicUsize, Ordering};

static COUNTER: AtomicUsize = AtomicUsize::new(0);

fn increment() {
    COUNTER.fetch_add(1, Ordering::SeqCst);
}

fn main() {
    increment();
    println!("Counter: {}", COUNTER.load(Ordering::SeqCst));
}
```

✅ `AtomicUsize` ensures **safe concurrent access** without `unsafe`.

---

**Key Takeaways**

✔ **`static` variables have a fixed memory location and exist for the whole program.**  
✔ **`mut static` requires `unsafe` due to potential data races.**  
✔ **Use `Atomic*` types for thread-safe mutable statics.**  
✔ **`const` differs from `static`—it’s inlined, immutable, and safer.**

## Lifetimes in Struct Members

In Rust, lifetimes ensure that references in your structs remain valid for the duration of their usage. When you include references as struct members, you must specify lifetimes explicitly to guarantee memory safety.

**Key Points**  
- A struct that contains references must use lifetime parameters to ensure the referenced data outlives the struct.
- The lifetime tells the compiler how long the references inside the struct are valid.
- If the struct does not contain references, it doesn't require lifetimes.

**Syntax**  
```rust
struct StructName<'a> {
    reference_field: &'a Type,
}
```
Here, `'a` is the lifetime parameter, which ensures that the `reference_field` does not outlive its data.

**Example: A Struct with a Single Lifetime**  
```rust
struct Book<'a> {
    title: &'a str,
}

fn main() {
    let title = String::from("Rust Programming");
    let book = Book { title: &title };

    println!("Book title: {}", book.title);
}
```
In this example:
- The `Book` struct has a reference (`&str`) with the lifetime `'a`.
- The lifetime ensures that the `title` field does not outlive the `title` variable in `main`.

**Example: Struct with Multiple Lifetimes**  
If a struct has multiple references, each may need its own lifetime parameter:  
```rust
struct Pair<'a, 'b> {
    first: &'a str,
    second: &'b str,
}

fn main() {
    let str1 = String::from("Hello");
    let str2 = String::from("World");
    let pair = Pair {
        first: &str1,
        second: &str2,
    };

    println!("Pair: {} and {}", pair.first, pair.second);
}
```
Here:
- `'a` and `'b` represent the lifetimes of the two references.
- Each lifetime ensures that the associated field's reference does not outlive its source.

**Structs Without Lifetimes**  
If a struct does not contain references (e.g., only owns data like `String` or `i32`), it does not need lifetimes.  
```rust
struct OwnedData {
    name: String,
    value: i32,
}
```

**Lifetime Elision**  
In some cases, Rust can infer lifetimes without requiring explicit annotation. However, structs with references always need lifetimes explicitly defined.

**Important Notes**  
- Lifetimes in structs can make the struct harder to use because it ties the struct's validity to the referenced data.
- To avoid lifetimes, you can use owned types like `String` instead of `&str` or `Vec<T>` instead of `&[T]`.
- Using smart pointers like `Rc<T>` or `Arc<T>` may also help avoid lifetime annotations but come with trade-offs in performance and mutability.

By managing lifetimes correctly, you ensure your program is memory-safe and free of dangling references.

## **Fully Qualified Syntax for Method Invocation**

In Rust, methods are typically called using **dot syntax** (e.g., `object.method()`), but sometimes **fully qualified syntax** is required to resolve ambiguity, especially when dealing with:

1. **Trait methods with the same name**
2. **Methods from different traits with the same name**
3. **Calling a trait method directly without an instance**

---

**Syntax Format**

```rust
<TraitName as TraitPath>::method(receiver, args...)
```

- `<TraitName>` – The trait that defines the method.
- `as TraitPath` – The full path of the trait (if necessary).
- `method(receiver, args...)` – The method call, with `self` explicitly passed.

---

**Example: Disambiguating Trait Methods**

### **Case: Two Traits with the Same Method Name**

```rust
trait A {
    fn foo(&self);
}

trait B {
    fn foo(&self);
}

struct MyType;

impl A for MyType {
    fn foo(&self) {
        println!("A's foo()");
    }
}

impl B for MyType {
    fn foo(&self) {
        println!("B's foo()");
    }
}

fn main() {
    let obj = MyType;

    // Normal method call (Ambiguous)
    // obj.foo(); // ❌ ERROR: multiple `foo` implementations

    // Fully Qualified Syntax to disambiguate
    <MyType as A>::foo(&obj); // Output: A's foo()
    <MyType as B>::foo(&obj); // Output: B's foo()
}
```

🔹 Without **fully qualified syntax**, Rust doesn’t know which `foo()` method to call.

---

### **Calling a Trait Method Without an Instance**

Some trait methods **don’t require `self`**, and can be called directly on the type:

```rust
trait Math {
    fn double(n: i32) -> i32;
}

struct Number;

impl Math for Number {
    fn double(n: i32) -> i32 {
        n * 2
    }
}

fn main() {
    let result = <Number as Math>::double(10); // Fully qualified syntax
    println!("{}", result); // Output: 20
}
```

🔹 `Math::double` doesn’t require `self`, so it can be called **directly on the type**.

---

**Example: Overriding Default Trait Methods**

```rust
trait Greet {
    fn hello(&self) {
        println!("Hello from trait!");
    }
}

struct Person;

impl Greet for Person {
    fn hello(&self) {
        println!("Hello from Person!");
    }
}

fn main() {
    let p = Person;
    
    p.hello(); // Calls overridden method: "Hello from Person!"
    
    <Person as Greet>::hello(&p); // Explicitly calls trait method: "Hello from trait!"
}
```

---

**When to Use Fully Qualified Syntax?**

✅ When a type implements **multiple traits** with the **same method name**.  
✅ When calling a **trait method without `self`** (i.e., an **associated function**).  
✅ When you **override a trait method** but still want to call the default implementation.

---

**Key Takeaways**

- **Use `<Type as Trait>::method()` to explicitly call a trait method.**
- **Necessary when multiple traits define the same method name.**
- **Used for calling associated functions (static methods) in traits.**
- **Helps avoid ambiguity and makes the code explicit.**

## Operator Overloading

Operator overloading in Rust allows you to define custom behavior for standard operators (e.g., `+`, `-`, `*`, `==`) when used with your custom types. Rust achieves this using **traits** from the `std::ops` module.

---

**Defining Operator Overloading**

To overload an operator, you implement the corresponding trait for your type. Each trait provides an associated method that you must define.

---

**Example: Overloading `+` (Addition)**

The `+` operator corresponds to the `std::ops::Add` trait.

**Step 1: Implementing `Add` for a Custom Struct**

```rust
use std::ops::Add;

#[derive(Debug, Copy, Clone)]
struct Point {
    x: i32,
    y: i32,
}

// Implement addition for `Point`
impl Add for Point {
    type Output = Point; // Specifies the result type of `+`

    fn add(self, other: Point) -> Point {
        Point {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

fn main() {
    let p1 = Point { x: 2, y: 3 };
    let p2 = Point { x: 4, y: 5 };

    let p3 = p1 + p2; // Uses overloaded `+`
    println!("{:?}", p3); // Output: Point { x: 6, y: 8 }
}
```

🔹 **`type Output`** defines the result type of `+`.  
🔹 **`fn add(self, other: Self) -> Self::Output`** implements the behavior.

---

### **Common Operator Overload Traits**

Rust provides several traits for overloading operators:

|Operator|Trait (`std::ops::`)|Example Signature|
|---|---|---|
|`+` (Addition)|`Add<T>`|`fn add(self, rhs: T) -> Self::Output`|
|`-` (Subtraction)|`Sub<T>`|`fn sub(self, rhs: T) -> Self::Output`|
|`*` (Multiplication)|`Mul<T>`|`fn mul(self, rhs: T) -> Self::Output`|
|`/` (Division)|`Div<T>`|`fn div(self, rhs: T) -> Self::Output`|
|`%` (Remainder)|`Rem<T>`|`fn rem(self, rhs: T) -> Self::Output`|
|`==` (Equality)|`PartialEq`|`fn eq(&self, other: &Self) -> bool`|
|`!=` (Inequality)|`PartialEq`|Uses `eq` but negated|
|`<`, `<=`, `>`, `>=`|`PartialOrd`|`fn partial_cmp(&self, other: &Self) -> Option<Ordering>`|
|`&` (Bitwise AND)|`BitAnd<T>`|`fn bitand(self, rhs: T) -> Self::Output`|
|`|` (Bitwise OR)|`BitOr<T>`|
|`^` (Bitwise XOR)|`BitXor<T>`|`fn bitxor(self, rhs: T) -> Self::Output`|
|`<<` (Left Shift)|`Shl<T>`|`fn shl(self, rhs: T) -> Self::Output`|
|`>>` (Right Shift)|`Shr<T>`|`fn shr(self, rhs: T) -> Self::Output`|
|`!` (Logical NOT)|`Not`|`fn not(self) -> Self::Output`|
|`&` (Borrowing)|`Deref`|`fn deref(&self) -> &T`|
|`&mut` (Mutable Borrowing)|`DerefMut`|`fn deref_mut(&mut self) -> &mut T`|

---

**Example: Overloading `*` (Multiplication)**

```rust
use std::ops::Mul;

struct Scalar(i32);

impl Mul for Scalar {
    type Output = Scalar;

    fn mul(self, rhs: Scalar) -> Scalar {
        Scalar(self.0 * rhs.0)
    }
}

fn main() {
    let a = Scalar(3);
    let b = Scalar(4);
    let c = a * b; // Uses overloaded `*`
    println!("{}", c.0); // Output: 12
}
```

---

### **Handling Different Types (`T`) in Overloading**

You can overload operators for **different types** instead of only `Self`:

```rust
use std::ops::Add;

struct Point {
    x: i32,
    y: i32,
}

// Implement addition with `i32`
impl Add<i32> for Point {
    type Output = Point;

    fn add(self, scalar: i32) -> Point {
        Point {
            x: self.x + scalar,
            y: self.y + scalar,
        }
    }
}

fn main() {
    let p = Point { x: 2, y: 3 };
    let p_new = p + 5; // Add 5 to both x and y
    println!("({}, {})", p_new.x, p_new.y); // Output: (7, 8)
}
```

🔹 `Add<i32>` allows adding an integer to a `Point` instead of another `Point`.

---

**Key Takeaways**

- **Rust uses traits to overload operators.**
- **Each operator has a corresponding `std::ops` trait.**
- **You must implement the trait for your type and define `type Output`.**
- **Overloading allows operations between custom types and even different types.**
- **Rust enforces strong type safety, preventing unexpected operator misuse.**

## `extern`

The `extern` keyword in Rust is used for **interoperability** with other languages (FFI - Foreign Function Interface) and to declare **external functions, variables, or libraries** that exist outside Rust’s compilation unit.

---

### **`extern "C"` for Calling C Functions**

Rust can call C functions by specifying the `"C"` ABI.

**Example: Calling a C function from Rust**

```c
// C Code (my_c_lib.c)
#include <stdio.h>

void hello_from_c() {
    printf("Hello from C!\n");
}
```

```rust
// Rust Code (main.rs)
extern "C" {
    fn hello_from_c();
}

fn main() {
    unsafe {
        hello_from_c();
    }
}
```

✅ **Key points:**

- `extern "C"` tells Rust to use the C calling convention.
- `unsafe` is required because Rust cannot guarantee safety.

---

### **`extern "C"` for Exposing Rust Functions to C**

Rust functions can be made accessible to C using `#[no_mangle]` to prevent name mangling.

**Example: Exposing a Rust function to C**

```rust
#[no_mangle]
extern "C" fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

Then, in C:

```c
// C Code
#include <stdio.h>

extern int add(int a, int b);

int main() {
    printf("Sum: %d\n", add(3, 4));
    return 0;
}
```

✅ **Key points:**

- `#[no_mangle]` keeps the function name unchanged in the binary.
- `extern "C"` ensures C compatibility.

---

### **`extern crate` for Importing External Rust Crates** _(Deprecated in 2018 Edition)_

In Rust 2015, `extern crate` was required to import external crates:

```rust
extern crate serde; // Import serde crate
```

In Rust 2018+, it's unnecessary—`use` is preferred:

```rust
use serde::Serialize;
```

---

### **`extern` with Other ABIs**

Rust supports multiple ABIs, such as `"stdcall"` (Windows), `"fastcall"`, `"system"`, etc.

|ABI|Description|
|---|---|
|`"C"`|Standard C ABI (most common)|
|`"stdcall"`|Used by Windows API functions|
|`"fastcall"`|Passes some arguments via registers|
|`"system"`|Uses the platform’s default ABI|

Example using `stdcall` (Windows API):

```rust
#[cfg(target_os = "windows")]
extern "stdcall" {
    fn MessageBoxA(hwnd: *mut u8, text: *const u8, caption: *const u8, utype: u32) -> i32;
}
```

---

### **`extern` Blocks for Static Variables**

Rust can access C global variables via `extern`.

**Example: Accessing a C global variable**

```c
// C Code (global.c)
int GLOBAL_VALUE = 42;
```

```rust
// Rust Code
extern "C" {
    static GLOBAL_VALUE: i32;
}

fn main() {
    unsafe {
        println!("Global value: {}", GLOBAL_VALUE);
    }
}
```

---

**Key Takeaways**

✔ **`extern "C"` ensures compatibility with C functions.**  
✔ **Use `#[no_mangle]` to prevent Rust from renaming functions.**  
✔ **Rust does not guarantee ABI stability—use `extern` for cross-language compatibility.**  
✔ **Other ABIs (`stdcall`, `system`, etc.) exist for platform-specific needs.**

## Attributes (`#[...]`)

Attributes in Rust (`#[...]`) are **compiler directives** used to modify code behavior. They can apply to functions, structs, modules, crates, and more.

---

### **Types of Attributes**

Rust attributes fall into these main categories:

|Category|Purpose|
|---|---|
|**Crate-Level**|Configure the entire crate (`#![crate_type]`, `#![no_std]`)|
|**Code Behavior**|Control compiler behavior (`#[inline]`, `#[must_use]`, `#[deprecated]`)|
|**Conditional Compilation**|Enable or disable code (`#[cfg(...)]`, `#[cfg_attr(...)]`)|
|**Lint Controls**|Adjust warnings and lints (`#[allow(...)]`, `#[deny(...)]`)|
|**FFI & Linking**|Work with external code (`#[no_mangle]`, `#[link]`)|
|**Procedural Macros**|Define custom attributes (`#[derive(...)]`, `#[proc_macro]`)|

---

### **Crate-Level Attributes**

These apply to the **entire crate** and start with `#![...]`.

#### **`#![crate_name]` and `#![crate_type]`**

Define the crate's name and type.

```rust
#![crate_name = "my_library"]
#![crate_type = "lib"] // Generates a Rust library instead of an executable
```

#### **`#![no_std]` (Disables Standard Library)**

Used for embedded and OS development.

```rust
#![no_std]  // Removes std; only core and alloc are available
```

---

### **Code Behavior Attributes**

#### **`#[inline]` (Suggests Inlining)**

```rust
#[inline]
fn fast_function() {
    println!("This function may be inlined");
}
```

#### **`#[must_use]` (Warns on Ignored Return Values)**

```rust
#[must_use]
fn important_calculation() -> i32 {
    42
}
```

If the result is ignored, the compiler will issue a warning.

#### **`#[deprecated]` (Marks Code as Deprecated)**

```rust
#[deprecated(since = "1.5.0", note = "Use `new_function` instead")]
fn old_function() {
    println!("This is deprecated");
}
```

---

### **Conditional Compilation Attributes**

Used to **enable or disable code** based on conditions.

#### **`#[cfg(...)]` (Compile-Time Condition)**

```rust
#[cfg(target_os = "linux")]
fn linux_only_function() {
    println!("Linux-specific function");
}
```

#### **`#[cfg_attr(...)]` (Apply Attributes Conditionally)**

```rust
#[cfg_attr(debug_assertions, allow(dead_code))]
fn debug_only_function() {}
```

This applies `#[allow(dead_code)]` only in debug builds.

---

### **Lint Control Attributes**

Rust allows **controlling compiler warnings and lints**.

#### **`#[allow(...)]`, `#[warn(...)]`, `#[deny(...)]`**

```rust
#[allow(dead_code)]
fn unused_function() {}

#[warn(unused_variables)]
fn test() {
    let x = 42; // Warning: unused variable
}

#[deny(unused_imports)]
use std::fs::File; // Error: unused import
```

---

### **FFI & Linking Attributes**

#### **`#[no_mangle]` (Preserve Function Name for C)**

```rust
#[no_mangle]
pub extern "C" fn c_function() {
    println!("Accessible from C");
}
```

#### **`#[repr(...)]` (Control Memory Layout)**

```rust
#[repr(C)] // Make struct compatible with C
struct MyStruct {
    x: i32,
    y: f64,
}
```

#### **`#[link(name = "...")]` (Link with External Libraries)**

```rust
#[link(name = "mylib")]
extern "C" {
    fn my_c_function();
}
```

---

### **Deriving Traits with `#[derive(...)]`**

```rust
#[derive(Debug, Clone, PartialEq)]
struct MyStruct {
    x: i32,
}
```

Automatically implements the **Debug**, **Clone**, and **PartialEq** traits.

---

### **Procedural Macros (`#[proc_macro]`)**

Used for custom Rust macros.

#### **Defining a Custom Macro**

```rust
use proc_macro::TokenStream;

#[proc_macro]
pub fn my_macro(input: TokenStream) -> TokenStream {
    input // Simple macro that does nothing
}
```

#### **Using a Custom Macro**

```rust
#[my_macro]
fn test() {
    println!("Custom macro applied!");
}
```


## Conditional Compilation (`#[cfg(...)]`)

The `#[cfg(...)]` attribute is used for **conditional compilation** in Rust. It allows compiling or including code based on **features, target platforms, environment variables, or other conditions**.

---

### **Checking the Target OS**

You can compile different code for different operating systems using `#[cfg(target_os = "...")]`.

```rust
fn main() {
    #[cfg(target_os = "windows")]
    println!("Running on Windows!");

    #[cfg(target_os = "linux")]
    println!("Running on Linux!");

    #[cfg(target_os = "macos")]
    println!("Running on macOS!");
}
```

✅ **Key points:**

- The Rust compiler includes only the matching `#[cfg]` block for the detected OS.
- `target_os` values include `"windows"`, `"linux"`, `"macos"`, `"android"`, etc.

---

### **Checking the Compiler Version**

```rust
#[cfg(rustc_version = "1.75.0")]
fn use_new_feature() {
    println!("Using Rust 1.75.0+ features!");
}
```

✅ This ensures a function is compiled only for a specific Rust version.

---

### **Feature Flags (`--features`)**

You can enable/disable code using Cargo features.

**In `Cargo.toml`:**

```toml
[features]
fast_math = []
```

**In Rust code:**

```rust
#[cfg(feature = "fast_math")]
fn fast_math() {
    println!("Fast math enabled!");
}

fn main() {
    #[cfg(feature = "fast_math")]
    fast_math();
}
```

Run with:

```sh
cargo run --features fast_math
```

✅ **Use case:** Enabling optional functionality in a crate.

---

### **Checking the Compiler Target (Architecture)**

```rust
#[cfg(target_arch = "x86_64")]
fn optimized_for_x86_64() {
    println!("Running on x86_64 architecture!");
}
```

✅ `target_arch` values include `"x86"`, `"x86_64"`, `"arm"`, `"aarch64"`, etc.

---

### **Checking the Endianness**

```rust
#[cfg(target_endian = "little")]
fn little_endian_code() {
    println!("Running on a little-endian system!");
}
```

✅ Useful for writing cross-platform, byte-order-aware code.

---

### **Checking Debug vs. Release Mode**

```rust
#[cfg(debug_assertions)]
fn debug_mode() {
    println!("Debug mode active!");
}
```

✅ In **release mode**, `debug_assertions` is **not enabled**, making this function **not compile**.

---

### **Using `cfg!()` Inside Code**

Instead of `#[cfg(...)]`, `cfg!()` is a runtime check.

```rust
fn main() {
    if cfg!(target_os = "windows") {
        println!("This is Windows!");
    } else {
        println!("Not Windows!");
    }
}
```

✅ Unlike `#[cfg(...)]`, `cfg!()` **does not remove code at compile time**—it evaluates at runtime.

---

### **Combining Multiple Conditions (`any`, `all`, `not`)**

- **`any(...)`**: If **any** condition is met
- **`all(...)`**: If **all** conditions are met
- **`not(...)`**: If **a condition is not met**

```rust
#[cfg(any(target_os = "linux", target_os = "macos"))]
fn unix_function() {
    println!("Running on Linux or macOS!");
}

#[cfg(all(feature = "experimental", target_os = "linux"))]
fn experimental_linux_feature() {
    println!("Experimental feature for Linux enabled!");
}

#[cfg(not(target_os = "windows"))]
fn not_windows() {
    println!("This is not Windows!");
}
```

---

### **Conditional Modules**

```rust
#[cfg(target_os = "windows")]
mod windows_only {
    pub fn run() {
        println!("Windows-specific function!");
    }
}

fn main() {
    #[cfg(target_os = "windows")]
    windows_only::run();
}
```

✅ The whole `mod windows_only` block is **ignored** if not on Windows.

---

### **Conditionally Including External Crates**

```rust
#[cfg(feature = "serde")]
extern crate serde;
```

✅ This prevents unused dependencies when a feature is disabled.

---

**Key Takeaways**

✔ **`#[cfg(...)]` removes code at compile-time** based on conditions.  
✔ **`cfg!(...)` evaluates conditions at runtime.**  
✔ **Use `any(...)`, `all(...)`, and `not(...)` for complex conditions.**  
✔ **Common use cases:** OS-specific code, feature flags, debug/release checks, and architecture checks.



# Methods

## **`HashMap<K, V>` Methods**

`HashMap` is used for storing key-value pairs in an unordered collection.

- **`insert(key, value)`**: Inserts a key-value pair.

    ```rust
    use std::collections::HashMap;

    let mut map = HashMap::new();
    map.insert("blue", 10);
    map.insert("yellow", 50);
    ```

- **`get(&key)`**: Returns an `Option<&V>`.

    ```rust
    if let Some(score) = map.get("blue") {
        println!("Blue team's score is: {}", score);
    }
    ```

- **`remove(&key)`**: Removes a key-value pair by key.

    ```rust
    map.remove("blue");
    ```

- **`contains_key(&key)`**: Checks if the map contains a specific key.

    ```rust
    println!("Contains 'yellow': {}", map.contains_key("yellow"));
    ```

- **`len()`**: Returns the number of elements.

    ```rust
    println!("Map length: {}", map.len());
    ```

- **`is_empty()`**: Checks if the map is empty.

    ```rust
    println!("Is the map empty? {}", map.is_empty());
    ```

- **`clear()`**: Removes all key-value pairs.

    ```rust
    map.clear();
    ```

- **`entry(key)`**: Allows inserting or modifying the value in place.

    ```rust
    let entry = map.entry("green").or_insert(0);
    *entry += 10;
    ```

- **`keys()`**: Returns an iterator over the keys.

    ```rust
    for key in map.keys() {
        println!("{}", key);
    }
    ```

- **`values()`**: Returns an iterator over the values.

    ```rust
    for value in map.values() {
        println!("{}", value);
    }
    ```

- **`get_mut()`**: Returns a mutable reference to the value corresponding to the key.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert("key", 10);
    
    if let Some(val) = map.get_mut("key") {
        *val += 5;
    }
    
    println!("{:?}", map); // {"key": 15}
    ```

- **`retain()`**: Retains only the elements specified by the predicate.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert(1, 10);
    map.insert(2, 20);
    map.insert(3, 30);
    
    map.retain(|&k, &mut v| k > 1 && v >= 20);
    
    println!("{:?}", map); // {2: 20, 3: 30}
    ```

- **`drain()`**: Creates an iterator that removes all key-value pairs from the map.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert("a", 1);
    map.insert("b", 2);
    
    for (key, value) in map.drain() {
        println!("{}: {}", key, value);
    }
    
    println!("{:?}", map); // {}
    ```

- **`extend()`**: Extends the `HashMap` with elements from another iterable collection.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert(1, "one");
    
    let new_items = vec![(2, "two"), (3, "three")];
    map.extend(new_items);
    
    println!("{:?}", map); // {1: "one", 2: "two", 3: "three"}
    ```

- **`shrink_to_fit()`**: Shrinks the capacity of the `HashMap` to match the current number of elements.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert("a", 1);
    map.insert("b", 2);
    
    map.shrink_to_fit();
    ```

- **`iter()`**: Returns an iterator over the key-value pairs in the `HashMap`.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert("a", 1);
    map.insert("b", 2);
    
    for (key, value) in map.iter() {
        println!("{}: {}", key, value);
    }
    ```

- **`iter_mut()`**: Returns a mutable iterator over the key-value pairs in the `HashMap`.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert("a", 1);
    map.insert("b", 2);
    
    for (_, value) in map.iter_mut() {
        *value *= 2;
    }
    
    println!("{:?}", map); // {"a": 2, "b": 4}
    ```

- **`entry_mut()`**: Retrieves a mutable reference to an entry corresponding to the key.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert("key", 10);
    
    let entry = map.entry("key").or_insert(0);
    *entry += 5;
    
    println!("{:?}", map); // {"key": 15}
    ```

- **`append()`**: Moves all elements from one `HashMap` to another, overwriting existing keys if they are the same.

    ```rust
    use std::collections::HashMap;
    
    let mut map1 = HashMap::new();
    map1.insert(1, "one");
    
    let mut map2 = HashMap::new();
    map2.insert(2, "two");
    map2.insert(3, "three");
    
    map1.append(&mut map2);
    
    println!("{:?}", map1); // {1: "one", 2: "two", 3: "three"}
    println!("{:?}", map2); // {}
    ```

- **`reserve()`**: Reserves capacity for additional elements in the `HashMap`.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert(1, "one");
    
    map.reserve(10); // Reserve capacity for 10 more elements
    ```

- **`capacity()`**: Returns the number of elements the `HashMap` can hold without reallocating.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert(1, "one");
    
    println!("Capacity: {}", map.capacity());
    ```

- **`retain_mut()`**: Similar to `retain()`, but allows mutating the value if the key meets the condition.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert(1, 10);
    map.insert(2, 20);
    
    map.retain_mut(|&k, v| {
        if k == 1 {
            *v += 5;
        }
        *v > 15
    });
    
    println!("{:?}", map); // {1: 15, 2: 20}
    ```

## **`BTreeMap<K, V>` Methods**

`BTreeMap` is a key-value store where the keys are kept sorted.

- **`range(range)`**: Returns an iterator over a range of keys.

    ```rust
    use std::collections::BTreeMap;

    let mut map = BTreeMap::new();
    map.insert("apple", 3);
    map.insert("banana", 2);
    map.insert("pear", 5);

    for (key, value) in map.range("banana".."pear") {
        println!("{}: {}", key, value);
    }
    ```

- **`insert(key, value)`**: Inserts a key-value pair.

    ```rust
    map.insert("orange", 4);
    ```

- **`get(&key)`**: Returns a reference to the value for the key if it exists.

    ```rust
    if let Some(count) = map.get("banana") {
        println!("Banana count: {}", count);
    }
    ```

- **`remove(&key)`**: Removes a key-value pair by key.

    ```rust
    map.remove("apple");
    ```

- **`first_key_value()`**: Returns the first key-value pair.

    ```rust
    if let Some((first_key, first_val)) = map.first_key_value() {
        println!("First key: {}, First value: {}", first_key, first_val);
    }
    ```

- **`last_key_value()`**: Returns the last key-value pair.

    ```rust
    if let Some((last_key, last_val)) = map.last_key_value() {
        println!("Last key: {}, Last value: {}", last_key, last_val);
    }
    ```

## **`RefCell<T>` Methods**


The `RefCell<T>` type in Rust provides interior mutability, allowing you to mutate values even when you have an immutable reference. Below are additional methods for `RefCell<T>`:

---

### **Replacing and Swapping Values**  

#### **`replace()`**  
- Replaces the current value with a new one and returns the old value.

```rust
use std::cell::RefCell;

let data = RefCell::new(5);
let old_value = data.replace(10);
println!("Old value: {}", old_value); // 5
println!("New value: {}", data.borrow()); // 10
```

---

#### **`replace_with(f: FnOnce(&mut T) -> T)`**  
- Replaces the value based on a function.

```rust
let cell = RefCell::new(5);
cell.replace_with(|&mut old| old + 10);
println!("Updated value: {}", cell.borrow()); // 15
```

---

#### **`swap(other: &RefCell<T>)`**  
- Swaps the values of two `RefCell<T>` instances.

```rust
let a = RefCell::new(1);
let b = RefCell::new(2);

a.swap(&b);

println!("a: {}", a.borrow()); // 2
println!("b: {}", b.borrow()); // 1
```

---

### **Taking and Borrowing Values**  

#### **`take()`**  
- Takes the value out, replacing it with the default value of `T`.

```rust
let cell = RefCell::new(String::from("Hello"));
let taken_value = cell.take();
println!("Taken value: {}", taken_value); // "Hello"
println!("New value in cell: {:?}", cell.borrow()); // ""
```
*Note: `T` must implement `Default` for `take()` to work.*

---

### **Checking Borrow Status**  

#### **`borrow_state()`** *(Nightly Only)*
- Returns an enum indicating whether the value is currently borrowed mutably or immutably.

```rust
// Only available on Nightly Rust
let cell = RefCell::new(42);
let _borrow = cell.borrow();

assert!(cell.borrow_state().is_borrowed());
```

---

**Summary of `RefCell<T>` Methods**  

| Method | Description |
|--------|-------------|
| `borrow()` | Borrow an immutable reference (`Ref<T>`). |
| `borrow_mut()` | Borrow a mutable reference (`RefMut<T>`). |
| `try_borrow()` | Try to borrow immutably without panicking. |
| `try_borrow_mut()` | Try to borrow mutably without panicking. |
| `replace(new_value)` | Replace current value with `new_value`, returning the old one. |
| `replace_with(f)` | Replace value using a function. |
| `swap(&other)` | Swap values with another `RefCell<T>`. |
| `take()` | Take the value, leaving a default value in its place. |


## **`Rc<T>` and `Arc<T>` Methods**

### **Cloning and Reference Counting**

#### **`clone()`**  
- Creates a new `Rc<T>` or `Arc<T>` reference to the same value, incrementing the reference count.

```rust
use std::rc::Rc;

let a = Rc::new(5);
let b = Rc::clone(&a); // Equivalent to `let b = a.clone();`
```

For `Arc<T>`:

```rust
use std::sync::Arc;

let a = Arc::new(5);
let b = Arc::clone(&a);
```

---

#### **`strong_count()`**  
- Returns the number of strong references to the value.

```rust
println!("Reference count: {}", Rc::strong_count(&a));
```

For `Arc<T>`:

```rust
println!("Reference count: {}", Arc::strong_count(&a));
```

---

#### **`weak_count()`** *(Only for `Arc<T>`)*
- Returns the number of weak references to the value.

```rust
println!("Weak count: {}", Arc::weak_count(&a));
```

---

### **Downgrading and Upgrading**

#### **`downgrade()`**  
- Converts an `Rc<T>` or `Arc<T>` into a `Weak<T>`, which does not increment the strong count.

```rust
let weak_a = Rc::downgrade(&a);
```

For `Arc<T>`:

```rust
let weak_a = Arc::downgrade(&a);
```

---

#### **`upgrade()`**  
- Converts a `Weak<T>` back into an `Rc<T>` or `Arc<T>` if the value is still alive.

```rust
if let Some(strong_ref) = weak_a.upgrade() {
    println!("Upgraded value: {}", strong_ref);
} else {
    println!("Value no longer exists.");
}
```

---

### **Mutability and Uniqueness**

#### **`get_mut()`**  
- Provides a mutable reference to the inner value **only if no other strong references exist**.

```rust
if let Some(mut a_mut) = Rc::get_mut(&mut a) {
    *a_mut = 10;
}
```

For `Arc<T>` *(requires `Arc::make_mut()` instead of `get_mut()`)*
```rust
let mut a = Arc::new(5);
let mut_ref = Arc::make_mut(&mut a);
*mut_ref = 10;
```

---

#### **`make_mut()`** *(Only for `Arc<T>` and `Rc<T>`)*
- Creates a unique reference if there are multiple owners (clone-on-write behavior).

```rust
let mut a = Rc::new(5);
let unique_ref = Rc::make_mut(&mut a);
*unique_ref = 10;
```

For `Arc<T>`:

```rust
let mut a = Arc::new(5);
let unique_ref = Arc::make_mut(&mut a);
*unique_ref = 10;
```

---

### **Converting to Inner Value (If Unique)**

#### **`try_unwrap()`**
- Consumes `Rc<T>` or `Arc<T>` and returns the inner value **if it is uniquely owned**.

```rust
match Rc::try_unwrap(a) {
    Ok(value) => println!("Unwrapped value: {}", value),
    Err(shared) => println!("Still has multiple references."),
}
```

For `Arc<T>`:

```rust
match Arc::try_unwrap(a) {
    Ok(value) => println!("Unwrapped value: {}", value),
    Err(shared) => println!("Still has multiple references."),
}
```

---

### **Checking Pointer Equality**

#### **`ptr_eq()`**  
- Checks if two `Rc<T>` or `Arc<T>` point to the same allocation.

```rust
let a = Rc::new(5);
let b = Rc::clone(&a);

assert!(Rc::ptr_eq(&a, &b));
```

For `Arc<T>`:

```rust
let a = Arc::new(5);
let b = Arc::clone(&a);

assert!(Arc::ptr_eq(&a, &b));
```

---

**Summary of Methods**

| Method | `Rc<T>` | `Arc<T>` | Description |
|--------|--------|--------|-------------|
| `clone()` | ✅ | ✅ | Creates a new strong reference. |
| `strong_count()` | ✅ | ✅ | Returns the number of strong references. |
| `weak_count()` | ❌ | ✅ | Returns the number of weak references. |
| `downgrade()` | ✅ | ✅ | Creates a weak reference (`Weak<T>`). |
| `upgrade()` | ✅ | ✅ | Converts `Weak<T>` back to `Rc<T>`/`Arc<T>`. |
| `get_mut()` | ✅ | ❌ | Gets a mutable reference if only one strong reference exists. |
| `make_mut()` | ✅ | ✅ | Provides mutable access, cloning if needed. |
| `try_unwrap()` | ✅ | ✅ | Returns inner value if only one strong reference exists. |
| `ptr_eq()` | ✅ | ✅ | Checks if two smart pointers reference the same memory. |

---

- Use `Rc<T>` in **single-threaded** contexts.
- Use `Arc<T>` in **multi-threaded** environments.
- Use `Weak<T>` to **avoid reference cycles**.
- `make_mut()` enables **clone-on-write** behavior.


## **`Cell<T>` Methods**

`Cell` allows for copying in and out of the contained value without borrowing.

- **`set(value)`**: Sets the value.

    ```rust
    use std::cell::Cell;

    let cell = Cell::new(5);
    cell.set(10);
    println!("Cell value: {}", cell.get());
    ```

- **`get()`**: Returns the current value.

    ```rust
    let value = cell.get();
    println!("Value: {}", value);
    ```

- **`replace(new_value)`**: Replaces the current value and returns the old value.

    ```rust
    let old_value = cell.replace(20);
    println!("Old value: {}", old_value);
    ```

## **`Box<T>` Methods**

`Box` is a smart pointer for heap-allocated memory.

- **`new(value)`**: Creates a new `Box`.

    ```rust
    let boxed = Box::new(5);
    println!("Boxed value: {}", boxed);
    ```

- **`into_inner()`**: Consumes the `Box` and returns the contained value.

    ```rust
    let value = *boxed;
    println!("Unboxed value: {}", value);
    ```

- **`deref()`**: Dereferences the `Box` to access the value (automatically dereferenced in most cases).

    ```rust
    let boxed = Box::new(10);
    let deref_val = *boxed;
    println!("Dereferenced value: {}", deref_val);
    ```

- **`as_ref()`**: Converts a `Box<T>` into a reference `&T`.

    ```rust
    let boxed = Box::new(5);
    let ref_val = boxed.as_ref();
    println!("Box as reference: {}", ref_val);
    ```

- **`as_mut()`**: Converts a `Box<T>` into a mutable reference `&mut T`.

    ```rust
    let mut boxed = Box::new(5);
    let mut_ref = boxed.as_mut();
    *mut_ref += 1;
    println!("Box as mutable reference: {}", mut_ref);
    ```

- **`leak()`**: Consumes the `Box` and returns a mutable reference to the contained value with a `'static` lifetime. The value will no longer be automatically dropped when the program ends.

    ```rust
    let boxed = Box::new(42);
    let leaked = Box::leak(boxed);
    *leaked += 1;
    println!("Leaked value: {}", leaked);
    ```

- **`from_raw(ptr)`**: Converts a raw pointer into a `Box`. This method is unsafe because it assumes the raw pointer is valid and was previously allocated with `Box`.

    ```rust
    use std::ptr;

    let boxed = Box::new(100);
    let raw = Box::into_raw(boxed);

    unsafe {
        let boxed_again = Box::from_raw(raw);
        println!("Recovered from raw pointer: {}", boxed_again);
    }
    ```

- **`into_raw(box)`**: Consumes the `Box` and returns a raw pointer to the contained value. You are responsible for managing the memory.

    ```rust
    let boxed = Box::new(20);
    let raw = Box::into_raw(boxed);
    println!("Raw pointer: {:?}", raw);
    ```

- **`try_new(value)`** *(nightly only)*: Attempts to create a new `Box` with the given value and returns a `Result`. This is useful if the allocation might fail.

    ```rust
    #![feature(try_reserve)]

    let result: Result<Box<i32>, _> = Box::try_new(99);
    match result {
        Ok(boxed) => println!("Successfully created: {}", boxed),
        Err(e) => println!("Failed to allocate: {}", e),
    }
    ```
    

## **`Cow<T>` Methods**

`Cow` is a clone-on-write type that allows you to borrow or own data in a way that minimizes unnecessary cloning.

- **`into_owned()`**: Converts a `Cow` into an owned value.

    ```rust
    use std::borrow::Cow;

    let cow: Cow<str> = Cow::Borrowed("hello");
    let owned = cow.into_owned();
    println!("Owned: {}", owned);
    ```

- **`borrow()`**: Returns a reference to the borrowed data.

    ```rust
    let cow: Cow<str> = Cow::Borrowed("hello");
    let borrowed = cow.borrow();
    println!("Borrowed: {}", borrowed);
    ```

- **`to_mut()`**: Returns a mutable reference, cloning the data if it was borrowed.

    ```rust
    let mut cow: Cow<str> = Cow::Borrowed("hello");
    let mut_ref = cow.to_mut();
    mut_ref.push_str(" world");
    println!("Mutated: {}", cow);
    ```

## **Iterator Methods**

Iterators in Rust allow you to work with sequences of values.

- **`take(n)`**: Takes the first `n` elements from an iterator.

    ```rust
    let v = vec![1, 2, 3, 4, 5];
    let taken: Vec<_> = v.iter().take(3).collect();
    println!("{:?}", taken);
    ```

- **`skip(n)`**: Skips the first `n` elements and continues iteration.

    ```rust
    let v = vec![1, 2, 3, 4, 5];
    let skipped: Vec<_> = v.iter().skip(2).collect();
    println!("{:?}", skipped);
    ```

- **`map(f)`**: Transforms each element using a function `f`.

    ```rust
    let v = vec![1, 2, 3, 4];
    let mapped: Vec<_> = v.iter().map(|x| x * 2).collect();
    println!("{:?}", mapped); // [2, 4, 6, 8]
    ```

- **`filter(f)`**: Filters elements based on a predicate `f`.

    ```rust
    let v = vec![1, 2, 3, 4, 5];
    let filtered: Vec<_> = v.into_iter().filter(|&x| x % 2 == 0).collect();
    println!("{:?}", filtered); // [2, 4]
    ```

- **`fold(init, f)`**: Accumulates values by applying a function `f` to each element and an accumulator.

    ```rust
    let v = vec![1, 2, 3, 4];
    let sum = v.iter().fold(0, |acc, &x| acc + x);
    println!("Sum: {}", sum); // 10
    ```

- **`enumerate()`**: Yields a tuple containing the index and the value for each element.

    ```rust
    let v = vec!["a", "b", "c"];
    for (i, val) in v.iter().enumerate() {
        println!("Index: {}, Value: {}", i, val);
    }
    ```

- **`any(f)`**: Returns `true` if any element satisfies the predicate `f`.

    ```rust
    let v = vec![1, 2, 3, 4];
    let has_even = v.iter().any(|&x| x % 2 == 0);
    println!("Has even? {}", has_even); // true
    ```

- **`all(f)`**: Returns `true` if all elements satisfy the predicate `f`.

    ```rust
    let v = vec![2, 4, 6];
    let all_even = v.iter().all(|&x| x % 2 == 0);
    println!("All even? {}", all_even); // true
    ```

- **`find(f)`**: Returns the first element that satisfies the predicate `f`.

    ```rust
    let v = vec![1, 2, 3, 4];
    let result = v.into_iter().find(|&x| x == 3);
    println!("{:?}", result); // Some(3)
    ```

- **`collect()`**: Consumes the iterator and collects the results into a collection (e.g., `Vec`).

    ```rust
    let v = vec![1, 2, 3, 4];
    let doubled: Vec<_> = v.into_iter().map(|x| x * 2).collect();
    println!("{:?}", doubled); // [2, 4, 6, 8]
    ```

- **`for_each`**: Executes a function for each element of the iterator.

    ```rust
    let v = vec![1, 2, 3];
    v.iter().for_each(|&x| println!("{}", x));
    ```

- **`count`**: Consumes the iterator and returns the number of elements.

    ```rust
    let v = vec![1, 2, 3];
    let count = v.iter().count(); // 3
    ```

- **`position`**: Returns the index of the first element that matches a predicate.

    ```rust
    let v = vec![1, 2, 3, 4];
    let pos = v.iter().position(|&x| x == 3); // Some(2)
    ```

- **`rposition`**: Searches for an element from the right, returning the index of the first match.

    ```rust
    let a = [1, 2, 3, 4, 5];
    let pos = a.iter().rposition(|&x| x == 3); // Some(2)
    ```

- **`last`**: Returns the last element of the iterator, or `None` if the iterator is empty.

    ```rust
    let v = vec![1, 2, 3];
    let last = v.iter().last(); // Some(&3)
    ```

- **`max`**: Returns the maximum element, or `None` if the iterator is empty. Elements must implement `Ord`.

    ```rust
    let v = vec![1, 2, 3];
    let max = v.iter().max(); // Some(&3)
    ```

- **`min`**: Returns the minimum element, or `None` if the iterator is empty. Elements must implement `Ord`.

    ```rust
    let v = vec![1, 2, 3];
    let min = v.iter().min(); // Some(&1)
    ```

- **`max_by_key`**: Returns the element that yields the maximum value for a specified key.

    ```rust
    let v = vec![("a", 1), ("b", 3), ("c", 2)];
    let max = v.iter().max_by_key(|&(_, val)| val); // Some(&("b", 3))
    ```

- **`min_by_key`**: Returns the element that yields the minimum value for a specified key.

    ```rust
    let v = vec![("a", 1), ("b", 3), ("c", 2)];
    let min = v.iter().min_by_key(|&(_, val)| val); // Some(&("a", 1))
    ```

- **`zip`**: Combines two iterators into a single iterator of pairs.

    ```rust
    let a = vec![1, 2, 3];
    let b = vec![4, 5, 6];
    let zipped: Vec<_> = a.iter().zip(b.iter()).collect(); // [(1, 4), (2, 5), (3, 6)]
    ```

- **`chain`**: Combines two iterators into a single iterator.

    ```rust
    let a = vec![1, 2, 3];
    let b = vec![4, 5, 6];
    let chained: Vec<_> = a.iter().chain(b.iter()).collect(); // [1, 2, 3, 4, 5, 6]
    ```

- **`inspect`**: Allows you to inspect each element of an iterator by applying a function without consuming it.

    ```rust
    let v = vec![1, 2, 3];
    let _ = v.iter().inspect(|&x| println!("Value: {}", x)).count();
    ```

---

**`for_each` vs `inspect`**

- **`for_each`**:
  - The `for_each` method is used to apply a closure to each item in the iterator.
  - It consumes the iterator, which means you can’t use the iterator after calling `for_each`.
  - It’s usually used for side effects, like printing values or performing some operation without returning any results.

    ```rust
    let v = vec![1, 2, 3];
    v.iter().for_each(|x| println!("{}", x)); // Prints each element
    ```

- **`inspect`**:
  - The `inspect` method allows you to peek at each item in an iterator chain without consuming the iterator or changing its output.
  - It’s often used for debugging or logging because it lets you see values as they pass through an iterator pipeline.
  - `inspect` returns a new iterator that is still usable after the inspection.

    ```rust
    let v = vec![1, 2, 3];
    let squared: Vec<_> = v.iter()
        .inspect(|x| println!("Original: {}", x))
        .map(|x| x * x)
        .inspect(|x| println!("Squared: {}", x))
        .collect();
    ```

- *Summary*:
  - Use `for_each` when you only want to perform an action on each element and don’t need the iterator anymore.
  - Use `inspect` if you want to peek into the iterator pipeline while keeping the iterator chain intact.

---

- **`nth`**: Returns the nth element of the iterator (zero-based index) or `None` if it is out of bounds.

    ```rust
    let v = vec![1, 2, 3, 4];
    let third = v.iter().nth(2); // Some(&3)
    ```

- **`flatten`**: Flattens an iterator of iterators into a single iterator.

    ```rust
    let v = vec![vec![1, 2], vec![3, 4]];
    let flattened: Vec<_> = v.into_iter().flatten().collect(); // [1, 2, 3, 4]
    ```

- **`partition`**: Splits an iterator into two collections based on a predicate.

    ```rust
    let v = vec![1, 2, 3, 4];
    let (even, odd): (Vec<_>, Vec<_>) = v.into_iter().partition(|&x| x % 2 == 0); // ([2, 4], [1, 3])
    ```

- **`take_while`**: Takes elements from the iterator while a predicate is true.

    ```rust
    let v = vec![1, 2, 3, 4];
    let taken: Vec<_> = v.iter().take_while(|&&x| x < 3).collect(); // [1, 2]
    ```

- **`skip_while`**: Skips elements from the iterator while a predicate is true, then yields the rest.

    ```rust
    let v = vec![1, 2, 3, 4];
    let skipped: Vec<_> = v.iter().skip_while(|&&x| x < 3).collect(); // [3, 4]
    ```

---

**Why Double Ampersands (`&&`) in `take_while` or `skip_while`**

The double ampersands (`&&`) are required due to the way the Rust compiler infers the types in closures and iterator adapters. Let's break this down.

Consider this example:

```rust
let v = vec![1, 2, 3, 4, 5];
let result: Vec<_> = v.iter().take_while(|&&x| x < 4).collect();
```

Here's what's happening:

- `v.iter()` produces an iterator over references to the elements in `v`, so each item yielded by `v.iter()` is `&i32` (a reference to an `i32`).
- `take_while` provides each item (of type `&i32`) to the closure.
- If we want to compare the integer value (not the reference) within the closure, we need to dereference `&i32` to get `i32`.

The double ampersands (`&&`) in `|&&x| x < 4` mean:
- The first `&` is because the iterator is iterating over references (`&i32`).
- The second `&` is because `take_while` passes a reference to each item to the closure (which is `&&i32` in this case).

You can think of it like this:

- `&&x` unpacks `&&i32` to `i32`, allowing us to use `x` as an `i32` inside the closure.

Without `&&`, you would get a type mismatch error because you’d be comparing `&i32` (a reference) directly to `4` (an integer), which isn't allowed without dereferencing.

If you want to avoid the double ampersands, you could write it like this, explicitly dereferencing:

```rust
let result: Vec<_> = v.iter().take_while(|&x| *x < 4).collect();
```

Or use a reference comparison if you want to avoid dereferencing:

```rust
let result: Vec<_> = v.iter().take_while(|&&x| x < 4).collect();
```

---

- **`peekable`**: Converts an iterator into a "peekable" iterator that allows you to peek at the next element.

    ```rust
    let mut iter = vec![1, 2, 3].into_iter().peekable();
    println!("{:?}", iter.peek()); // Some(&1)
    ```

- **`fuse`**: Makes an iterator that stops returning elements after it has returned `None` once.

    ```rust
    let v = vec![1, 2, 3];
    let mut iter = v.iter().fuse();
    println!("{:?}", iter.next()); // Some(&1)
    println!("{:?}", iter.next()); // Some(&2)
    println!("{:?}", iter.next()); // Some(&3)
    println!("{:?}", iter.next()); // None
    println!("{:?}", iter.next()); // None (fused)
    ```

- **`by_ref`**: Borrows the iterator instead of consuming it.

    ```rust
    let v = vec![1, 2, 3];
    let mut iter = v.iter();
    let first: Vec<_> = iter.by_ref().take(2).collect(); // [1, 2]
    let second: Vec<_> = iter.collect(); // [3]
    ```

- **`copied`**: Converts an iterator of references to an iterator of copied values (only for types that implement `Copy`).

    ```rust
    let v = vec![1, 2, 3];
    let copied: Vec<_> = v.iter().copied().collect(); // [1, 2, 3]
    ```

- **`cloned`**: Converts an iterator of references to an iterator of cloned values.

    ```rust
    let v = vec!["a", "b", "c"];
    let cloned: Vec<_> = v.iter().cloned().collect(); // ["a", "b", "c"]
    ```

- **`cycle`**: Repeats the iterator indefinitely (useful for infinite loops).

    ```rust
    let v = vec![1, 2];
    let mut iter = v.iter().cycle();
    println!("{:?}", iter.next()); // Some(&1)
    println!("{:?}", iter.next()); // Some(&2)
    println!("{:?}", iter.next()); // Some(&1)
    ```

- **`unzip`**: Converts an iterator of pairs into a pair of collections (like splitting keys and values).

    ```rust
    let pairs = vec![(1, "a"), (2, "b")];
    let (nums, chars): (Vec<_>, Vec<_>) = pairs.into_iter().unzip(); // ([1, 2], ["a", "b"])
    ```

- **`product`**: Computes the product of the elements in the iterator.

    ```rust
    let v = vec![1, 2, 3, 4];
    let product: i32 = v.iter().product(); // 24
    ```

- **`sum`**: Computes the sum of the elements in the iterator.

    ```rust
    let v = vec![1, 2, 3, 4];
    let sum: i32 = v.iter().sum(); // 10
    ```

- **`rev`**: Reverses the order of an iterator.

    ```rust
    let v = vec![1, 2, 3];
    let reversed: Vec<_> = v.iter().rev().collect(); // [3, 2, 1]
    ```

- **`step_by`**: Creates an iterator that steps by the given amount, skipping elements in between.

    ```rust
    let v = vec![1, 2, 3, 4, 5];
    let stepped: Vec<_> = v.iter().step_by(2).collect(); // [1, 3, 5]
    ```

- **`flat_map`**: Maps each element to an iterator and then flattens the result.

    ```rust
    let v = vec![1, 2, 3];
    let flat_mapped: Vec<_> = v.iter().flat_map(|&x| vec![x, x * 10]).collect(); // [1, 10, 2, 20, 3, 30]
    ```

- **`scan`**: Similar to `fold`, but returns an iterator of intermediate results.

    ```rust
    let v = vec![1, 2, 3, 4];
    let scanned: Vec<_> = v.iter().scan(0, |state, &x| {
        *state += x;
        Some(*state)
    }).collect(); // [1, 3, 6, 10]
    ```

- **`reduce`**: Reduces the elements to a single value by successively applying a function. Unlike `fold`, it doesn’t need an initial value and returns `None` if the iterator is empty.

    ```rust
    let v = vec![1, 2, 3, 4];
    let result = v.iter().copied().reduce(|a, b| a + b); // Some(10)
    ```

- **`intersperse`** (nightly feature at the time of writing): Inserts a specified value between each pair of elements.

    ```rust
    #![feature(iter_intersperse)] // requires nightly
    let v = vec![1, 2, 3];
    let interspersed: Vec<_> = v.iter().intersperse(&0).collect(); // [1, 0, 2, 0, 3]
    ```

- **`dedup_by_key`**: Removes consecutive duplicate elements based on a key.

    ```rust
    let mut v = vec!["apple", "apricot", "banana", "cherry", "cherry"];
    v.dedup_by_key(|s| s.chars().next());
    // ["apple", "banana", "cherry"]
    ```

- **`dedup_by`**: Removes consecutive duplicates based on a comparison function.

    ```rust
    let mut v = vec![1, 2, 2, 3, 4, 4, 5];
    v.dedup_by(|a, b| a == b);
    // [1, 2, 3, 4, 5]
    ```

- **`partition_in_place`**: Rearranges elements so that those that match a predicate are at the beginning of the collection.

    ```rust
    let mut v = vec![1, 2, 3, 4, 5];
    let mid = v.iter_mut().partition_in_place(|&x| x % 2 == 0);
    // `v` is now ordered with evens at the front and returns the index of the partition point.
    ```

- **`partition_map`**: Partitions the iterator into two collections based on a function.

    ```rust
    let v = vec![1, 2, 3, 4];
    let (even, odd): (Vec<_>, Vec<_>) = v.into_iter().partition_map(|x| {
        if x % 2 == 0 {
            Either::Left(x)
        } else {
            Either::Right(x)
        }
    });
    ```

- **`find_map`**: Searches for an element that matches a predicate, and applies a function to the matched element.

    ```rust
    let v = vec![1, 2, 3, 4];
    let result = v.iter().find_map(|&x| if x % 2 == 0 { Some(x * 10) } else { None });
    // Some(20) - because the first even number is 2, multiplied by 10 gives 20
    ```

- **`try_fold`**: Like `fold`, but can short-circuit if an error occurs.

    ```rust
    let v = vec![1, 2, 3, 4];
    let result: Result<i32, &str> = v.iter().try_fold(0, |acc, &x| {
        if x == 3 { Err("found 3") } else { Ok(acc + x) }
    });
    // Err("found 3")
    ```

- **`try_for_each`**: Like `for_each`, but can short-circuit if an error occurs.

    ```rust
    let v = vec![1, 2, 3, 4];
    let result: Result<(), &str> = v.iter().try_for_each(|&x| {
        if x == 3 { Err("found 3") } else { Ok(()) }
    });
    // Err("found 3")
    ```


---

## Option\<T\>

**is_some**

Returns true if the Option is Some(T).

Example:

```rust
let x: Option<i32> = Some(5);
println!("{}", x.is_some()); // true
```

**is_none**

Returns true if the Option is None.

Example:

```rust
let x: Option<i32> = None;
println!("{}", x.is_none()); // true
```

**unwrap**

Returns the contained value of Some(T). Panics if the Option is None.

Example:

```rust
let x: Option<i32> = Some(5);
let y = x.unwrap(); // 5

let z: Option<i32> = None;
// z.unwrap(); // Panics if uncommented
```


**unwrap_or**

Returns the contained value or a default if the Option is None.

Example:

```rust
let x: Option<i32> = Some(5);
let y = x.unwrap_or(0); // 5

let z: Option<i32> = None;
let w = z.unwrap_or(0); // 0
```

**unwrap_or_else**

Similar to unwrap_or, but takes a closure to lazily evaluate the default value if the Option is None.

Example:

```rust
let x: Option<i32> = Some(5);
let y = x.unwrap_or_else(|| 0); // 5

let z: Option<i32> = None;
let w = z.unwrap_or_else(|| 0); // 0
```


**map**

Transforms the value inside Some(T) using the provided function and returns Some of the new value, or returns None if the Option is None.

Example:

```rust
let x: Option<i32> = Some(5);
let y = x.map(|val| val * 2); // Some(10)

let z: Option<i32> = None;
let w = z.map(|val| val * 2); // None
```


**map_or**

Similar to map, but returns a default value if the Option is None.

Example:

```rust
let x: Option<i32> = Some(5);
let y = x.map_or(0, |val| val * 2); // 10

let z: Option<i32> = None;
let w = z.map_or(0, |val| val * 2); // 0
```


**map_or_else**

Similar to map_or, but takes a closure to lazily evaluate the default value if the Option is None.

Example:

```rust
let x: Option<i32> = Some(5);
let y = x.map_or_else(|| 0, |val| val * 2); // 10

let z: Option<i32> = None;
let w = z.map_or_else(|| 0, |val| val * 2); // 0
```


**and**

Returns None if the original Option is None, otherwise returns optb.

Example:

```rust
let x: Option<i32> = Some(5);
let y: Option<&str> = Some("hello");
let result = x.and(y); // Some("hello")

let x: Option<i32> = None;
let result = x.and(y); // None
```


**and_then**

Similar to and, but allows you to provide a function to produce the new Option.

Example:

```rust
let x: Option<i32> = Some(5);
let result = x.and_then(|val| Some(val * 2)); // Some(10)

let y: Option<i32> = None;
let result = y.and_then(|val| Some(val * 2)); // None
```


**or**

Returns `optb` if the original `Option` is `None`, otherwise returns the original `Option`.

Example:

```rust
let x: Option<i32> = Some(5);
let y: Option<i32> = None;
let result = x.or(y); // Some(5)

let x: Option<i32> = None;
let result = x.or(Some(10)); // Some(10)
```

**or_else**

Similar to `or`, but allows you to provide a closure to produce the new `Option`.

Example:

```rust
let x: Option<i32> = None;
let result = x.or_else(|| Some(10)); // Some(10)
```

**filter**

Returns `None` if the original `Option` is `None` or if the predicate function returns `false`. Otherwise, returns the original `Option`.

Example:

```rust
let x: Option<i32> = Some(5);
let result = x.filter(|&val| val > 3); // Some(5)
let result = x.filter(|&val| val < 3); // None
```


**ok_or**

Converts an `Option<T>` to a `Result<T, E>`, returning an `Ok` value if `Some`, or an `Err` with a provided error value if `None`.

Example:

```rust
let x: Option<i32> = Some(5);
let result: Result<i32, &str> = x.ok_or("Error!"); // Ok(5)

let y: Option<i32> = None;
let result: Result<i32, &str> = y.ok_or("Error!"); // Err("Error!")
```


**ok_or_else**

Similar to ok_or, but lazily evaluates the error value using a closure if the Option is None.

Example:

```rust
let x: Option<i32> = None;
let result: Result<i32, &str> = x.ok_or_else(|| "Error!"); // Err("Error!")
```

**flatten**

Converts an `Option<Option<T>>` to `Option<T>`. If it’s `Some(Some(T))`, it returns `Some(T)`. If it’s `Some(None)` or `None`, it returns `None`.

Example:

```rust
let x: Option<Option<i32>> = Some(Some(5));
let result = x.flatten(); // Some(5)

let y: Option<Option<i32>> = Some(None);
let result = y.flatten(); // None
```

**copied**

Creates a new `Option` by copying the value inside, assuming the value implements the `Copy` trait.

Example:

```rust
let x = Some(42);
let y = x.copied(); // Copies the value, resulting in `Some(42)`
let z: Option<i32> = None;
let w = z.copied(); // Still `None`
```

**expect**

- **Signature**: `fn expect(self, msg: &str) -> T`
- **Purpose**: Unwraps the `Option`, yielding the contained value. Panics with the provided message if the `Option` is `None`.
- **Example**:
    
    ```rust
    let value = Some(42).expect("Value is missing");
    println!("Value: {}", value); // Output: Value: 42
    ```


**expect_none**

- **Signature**: `fn expect_none(self, msg: &str)`
- **Purpose**: Ensures the `Option` is `None`. Panics with the provided message if it contains `Some`.
- **Example**:
    
    ```rust
    let none_value: Option<i32> = None;
    none_value.expect_none("Expected None"); // No panic
    ```


**contains**

- **Signature**: `fn contains<U>(&self, x: &U) -> bool` where `U: PartialEq<T>`
- **Purpose**: Checks if the `Option` contains a value equal to the given value.
- **Example**:
    
    ```rust
    let opt = Some(42);
    println!("{}", opt.contains(&42)); // Output: true
    ```


**as_ref**

- **Signature**: `fn as_ref(&self) -> Option<&T>`
- **Purpose**: Converts the `Option<T>` into `Option<&T>`, borrowing the value.
- **Example**:
    
    ```rust
    let opt = Some(42);
    if let Some(v) = opt.as_ref() {
        println!("Borrowed value: {}", v); // Output: Borrowed value: 42
    }
    ```


**as_mut**

- **Signature**: `fn as_mut(&mut self) -> Option<&mut T>`
- **Purpose**: Converts the `Option<T>` into `Option<&mut T>`, borrowing the value mutably.
- **Example**:
    
    ```rust
    let mut opt = Some(42);
    if let Some(v) = opt.as_mut() {
        *v += 1;
    }
    println!("{:?}", opt); // Output: Some(43)
    ```


**get_or_insert**

- **Signature**: `fn get_or_insert(&mut self, value: T) -> &mut T`
- **Purpose**: Inserts the provided value if the `Option` is `None`, then returns a mutable reference to the contained value.
- **Example**:
    
    ```rust
    let mut opt = None;
    let v = opt.get_or_insert(42);
    println!("{}", v); // Output: 42
    ```


**get_or_insert_with**

- **Signature**: `fn get_or_insert_with<F>(&mut self, f: F) -> &mut T` where `F: FnOnce() -> T`
- **Purpose**: Inserts a value computed by the provided closure if the `Option` is `None`, then returns a mutable reference to the contained value.
- **Example**:
    
    ```rust
    let mut opt = None;
    let v = opt.get_or_insert_with(|| 42);
    println!("{}", v); // Output: 42
    ```


**replace**

- **Signature**: `fn replace(&mut self, value: T) -> Option<T>`
- **Purpose**: Replaces the contained value with the given value, returning the old value.
- **Example**:
    
    ```rust
    let mut opt = Some(10);
    let old = opt.replace(42);
    println!("{:?}, {:?}", opt, old); // Output: Some(42), Some(10)
    ```


**take**

- **Signature**: `fn take(&mut self) -> Option<T>`
- **Purpose**: Takes the value out of the `Option`, leaving it as `None`.
- **Example**:
    
    ```rust
    let mut opt = Some(42);
    let taken = opt.take();
    println!("{:?}, {:?}", opt, taken); // Output: None, Some(42)
    ```


**zip**

- **Signature**: `fn zip<U>(self, other: Option<U>) -> Option<(T, U)>`
- **Purpose**: Combines two `Option`s into a single `Option` containing a tuple of the values, or `None` if either is `None`.
- **Example**:
    
    ```rust
    let a = Some(1);
    let b = Some(2);
    let zipped = a.zip(b);
    println!("{:?}", zipped); // Output: Some((1, 2))
    ```


**zip_with**

- **Signature**: `fn zip_with<U, F>(self, other: Option<U>, f: F) -> Option<R>` where `F: FnOnce(T, U) -> R`
- **Purpose**: Combines two `Option`s using a provided closure to produce a single value.
- **Example**:
    
    ```rust
    let a = Some(2);
    let b = Some(3);
    let result = a.zip_with(b, |x, y| x + y);
    println!("{:?}", result); // Output: Some(5)
    ```


**unzip**

- **Signature**: `fn unzip<A, B>(self) -> (Option<A>, Option<B>)` where `T: Into<(A, B)>`
- **Purpose**: Splits an `Option` containing a tuple into two `Option`s, one for each element of the tuple.
- **Example**:
    
    ```rust
    let opt = Some((1, "Rust"));
    let (a, b) = opt.unzip();
    println!("{:?}, {:?}", a, b); // Output: Some(1), Some("Rust")
    ```


**inspect**

- **Signature**: `fn inspect<F>(self, f: F) -> Self` where `F: FnOnce(&T)`
- **Purpose**: Runs a closure on the contained value if the `Option` is `Some`, and returns the original `Option`.
- **Example**:
    
    ```rust
    let opt = Some(42);
    opt.inspect(|v| println!("Value: {}", v)); // Output: Value: 42
    ```


***

## `Result<T, E>`

The Result<T, E> type is used for returning and propagating errors. A Result can either be:

Ok(T) – indicating success and containing a value of type T.

Err(E) – indicating failure and containing an error of type E.

**is_ok**

Returns true if the Result is Ok.

```rust
let x: Result<i32, &str> = Ok(10);
assert_eq!(x.is_ok(), true);
```

**is_err**

Returns true if the Result is Err.

```rust
let x: Result<i32, &str> = Err("Error!");
assert_eq!(x.is_err(), true);
```

**ok**

Converts a Result\<T, E> to an Option\<T>. If it's Ok, returns Some(T). If it's Err, returns None.

```rust
let x: Result<i32, &str> = Ok(10);
assert_eq!(x.ok(), Some(10));

let y: Result<i32, &str> = Err("Error!");
assert_eq!(y.ok(), None);
```

**err**

Converts a `Result<T, E>` to an `Option\<E>`. If it's `Err`, returns `Some(E)`. If it's `Ok`, returns `None`.

```rust
let x: Result<i32, &str> = Err("Error!");
assert_eq!(x.err(), Some("Error!"));

let y: Result<i32, &str> = Ok(10);
assert_eq!(y.err(), None);
```

**unwrap**

Returns the value T if the `Result` is `Ok`. If it's `Err`, the program will panic.

```rust
let x: Result<i32, &str> = Ok(10);
let val = x.unwrap(); // 10

// This would panic:
// let y: Result<i32, &str> = Err("Error!");
// y.unwrap();
```

**unwrap_or**

Returns the value T if the Result is Ok, otherwise returns a default value.

```rust
let x: Result<i32, &str> = Ok(10);
let val = x.unwrap_or(0); // 10

let y: Result<i32, &str> = Err("Error!");
let val = y.unwrap_or(0); // 0
```

**unwrap_or_else**

Similar to `unwrap_or`, but takes a closure to lazily evaluate the default value if the `Result` is `Err`.

```rust
let x: Result<i32, &str> = Ok(10);
let val = x.unwrap_or_else(|_| 0); // 10

let y: Result<i32, &str> = Err("Error!");
let val = y.unwrap_or_else(|e| {
    println!("Encountered error: {}", e);
    0
}); // 0
```

**map**

Transforms the Ok(T) value using the provided function, leaving the Err(E) value unchanged.

```rust
let x: Result<i32, &str> = Ok(10);
let result = x.map(|v| v * 2); // Ok(20)

let y: Result<i32, &str> = Err("Error!");
let result = y.map(|v| v * 2); // Err("Error!")
```

**map_err**

Transforms the `Err(E)` value using the provided function, leaving the `Ok(T)` value unchanged.

```rust
let x: Result<i32, &str> = Ok(10);
let result = x.map_err(|e| format!("Error: {}", e)); // Ok(10)

let y: Result<i32, &str> = Err("Error!");
let result = y.map_err(|e| format!("Error: {}", e)); // Err("Error: Error!")
```

**and**

If self is `Ok`, returns res. Otherwise, returns `Err(E)`.

```rust
let x: Result<i32, &str> = Ok(10);
let y: Result<i32, &str> = Ok(20);
assert_eq!(x.and(y), Ok(20));

let z: Result<i32, &str> = Err("Error!");
assert_eq!(x.and(z), Err("Error!"));
```

**and_then**

If self is `Ok`, calls the provided function f and returns the result. Otherwise, returns `Err(E)`.

```rust
let x: Result<i32, &str> = Ok(10);
let result = x.and_then(|v| Ok(v * 2)); // Ok(20)

let y: Result<i32, &str> = Err("Error!");
let result = y.and_then(|v| Ok(v * 2)); // Err("Error!")
```

**or**

If self is `Ok`, returns self. Otherwise, returns `res`.

```rust
let x: Result<i32, &str> = Err("Error!");
let y: Result<i32, &str> = Ok(20);
assert_eq!(x.or(y), Ok(20));

let z: Result<i32, &str> = Ok(10);
assert_eq!(z.or(y), Ok(10));
```

**or_else**

If self is `Err`, calls the provided function f and returns the result. Otherwise, returns `Ok(T)`.

```rust
let x: Result<i32, &str> = Err("Error!");
let result = x.or_else(|e| Ok(20)); // Ok(20)

let y: Result<i32, &str> = Ok(10);
let result = y.or_else(|e| Ok(20)); // Ok(10)
```

**unwrap_err**

Returns the contained error E if the `Result` is `Err`. Panics if the `Result` is `Ok`.

```rust
let x: Result<i32, &str> = Err("Error!");
let err = x.unwrap_err(); // "Error!"

// This would panic:
// let y: Result<i32, &str> = Ok(10);
// y.unwrap_err();
```

**flatten**

Converts a `Result<Result<T, E>, E>` to `Result<T, E>`. If it's `Ok(Ok(T))`, returns `Ok(T)`. If it's `Ok(Err(E))` or `Err(E)`, returns `Err(E)`.

```rust
let x: Result<Result<i32, &str>, &str> = Ok(Ok(10));
assert_eq!(x.flatten(), Ok(10));

let y: Result<Result<i32, &str>, &str> = Ok(Err("Error!"));
assert_eq!(y.flatten(), Err("Error!"));
```


**expect**

- **Signature**: `fn expect(self, msg: &str) -> T`
- **Purpose**: Unwraps the `Result`, yielding the value `T`. If the result is `Err`, it panics with a provided custom message.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Ok(42);
    let value = result.expect("Unexpected error");
    println!("Value: {}", value); // Output: Value: 42
    ```
    

**expect_err**

- **Signature**: `fn expect_err(self, msg: &str) -> E`
- **Purpose**: Unwraps the `Result`, yielding the error value `E`. If the result is `Ok`, it panics with a provided custom message.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Err("error occurred");
    let error = result.expect_err("Expected an error");
    println!("Error: {}", error); // Output: Error: error occurred
    ```


**as_ref**

- **Signature**: `fn as_ref(&self) -> Result<&T, &E>`
- **Purpose**: Converts from `Result<T, E>` to `Result<&T, &E>`, borrowing the contained value.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Ok(42);
    let borrowed = result.as_ref();
    println!("{:?}", borrowed); // Output: Ok(42)
    ```


**as_mut**

- **Signature**: `fn as_mut(&mut self) -> Result<&mut T, &mut E>`
- **Purpose**: Converts from `Result<T, E>` to `Result<&mut T, &mut E>`, mutably borrowing the contained value.
- **Example**:
    
    ```rust
    let mut result: Result<i32, &str> = Ok(42);
    if let Ok(v) = result.as_mut() {
        *v += 1;
    }
    println!("{:?}", result); // Output: Ok(43)
    ```


**transpose**

- **Signature**: `fn transpose(self) -> Option<Result<T, F>>`  
    Available when `E` implements `Into<Option<F>>`.
- **Purpose**: Converts a `Result<Option<T>, E>` into an `Option<Result<T, F>>`.
- **Example**:
    
    ```rust
    let result: Result<Option<i32>, &str> = Ok(Some(42));
    let option = result.transpose();
    println!("{:?}", option); // Output: Some(Ok(42))
    ```


**contains**

- **Signature**: `fn contains<U>(&self, x: &U) -> bool`  
    where `U: PartialEq<T>`
- **Purpose**: Checks if the contained value equals a given value.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Ok(42);
    println!("{}", result.contains(&42)); // Output: true
    ```


**contains_err**

- **Signature**: `fn contains_err<F>(&self, f: &F) -> bool`  
    where `F: PartialEq<E>`
- **Purpose**: Checks if the contained error equals a given value.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Err("error");
    println!("{}", result.contains_err(&"error")); // Output: true
    ```


**is_ok_and**

- **Signature**: `fn is_ok_and<F>(&self, f: F) -> bool`  
    where `F: FnOnce(&T) -> bool`
- **Purpose**: Returns `true` if the `Result` is `Ok` and the contained value satisfies the predicate.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Ok(42);
    println!("{}", result.is_ok_and(|&v| v > 40)); // Output: true
    ```


**is_err_and**

- **Signature**: `fn is_err_and<F>(&self, f: F) -> bool`  
    where `F: FnOnce(&E) -> bool`
- **Purpose**: Returns `true` if the `Result` is `Err` and the contained error satisfies the predicate.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Err("error");
    println!("{}", result.is_err_and(|&e| e == "error")); // Output: true
    ```


**inspect**

- **Signature**: `fn inspect<F>(self, f: F) -> Self`  
    where `F: FnOnce(&T)`
- **Purpose**: Executes a closure on the contained value if the result is `Ok`, and returns the original result.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Ok(42);
    result.inspect(|v| println!("Value: {}", v)); // Output: Value: 42
    ```


**inspect_err**

- **Signature**: `fn inspect_err<F>(self, f: F) -> Self`  
    where `F: FnOnce(&E)`
- **Purpose**: Executes a closure on the contained error if the result is `Err`, and returns the original result.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Err("error");
    result.inspect_err(|e| println!("Error: {}", e)); // Output: Error: error
    ```


## **`File` Methods**

- **`open(path)`**: Opens an existing file in read-only mode.

    ```rust
    use std::fs::File;
    use std::io::prelude::*;

    let mut file = File::open("example.txt").expect("Cannot open file");
    let mut content = String::new();
    file.read_to_string(&mut content).expect("Cannot read file");
    println!("{}", content);
    ```

- **`create(path)`**: Creates a new file for writing (truncating if the file already exists).

    ```rust
    use std::fs::File;
    use std::io::prelude::*;

    let mut file = File::create("output.txt").expect("Cannot create file");
    file.write_all(b"Hello, world!").expect("Cannot write to file");
    ```

- **`write_all(data)`**: Writes a buffer of bytes to the file.

    ```rust
    let mut file = File::create("output.txt").expect("Cannot create file");
    file.write_all(b"Hello, Rust!").expect("Cannot write data");
    ```

- **`read_to_string()`**: Reads the contents of a file into a string.

    ```rust
    let mut file = File::open("example.txt").expect("Cannot open file");
    let mut content = String::new();
    file.read_to_string(&mut content).expect("Cannot read file");
    println!("{}", content);
    ```


---

## **Ownership and Borrowing Methods**

Rust’s ownership and borrowing system uses methods to transfer or reference data in a safe way.

- **`to_owned()`**: Converts a borrowed type to an owned version. For instance, `&str` can be converted to `String`.

    ```rust
    let s: &str = "hello";
    let owned: String = s.to_owned();
    ```

- **`clone()`**: Creates a deep copy of the value. Used to duplicate data that implements the `Clone` trait.

    ```rust
    let vec = vec![1, 2, 3];
    let vec_clone = vec.clone();
    ```

- **`borrow()` and `borrow_mut()`**: Used with smart pointers like `RefCell` to borrow references to the inner data. These provide safe borrowing for both mutable and immutable references.

    ```rust
    use std::cell::RefCell;

    let data = RefCell::new(5);
    let borrowed = data.borrow(); // Immutable borrow
    let mut borrowed_mut = data.borrow_mut(); // Mutable borrow
    *borrowed_mut += 1;
    ```

- **`as_ref()`**: Converts an `Option<T>` into an `Option<&T>`. Often used to borrow data in an `Option` without taking ownership.

    ```rust
    let x: Option<String> = Some(String::from("hello"));
    let y: Option<&String> = x.as_ref();
    ```

- **`as_mut()`**: Similar to `as_ref()`, but returns a mutable reference to the data inside `Option<T>`.

    ```rust
    let mut x: Option<String> = Some(String::from("hello"));
    let y: Option<&mut String> = x.as_mut();
    ```

- **`into_boxed_slice()`**: Converts a `Vec` into a `Box<[T]>`, transferring ownership of the vector data into the heap.

    ```rust
    let vec = vec![1, 2, 3];
    let boxed_slice: Box<[i32]> = vec.into_boxed_slice();
    ```

- **`split_at_mut()`**: Mutably borrows a slice and splits it into two at a given index.

    ```rust
    let mut numbers = [1, 2, 3, 4, 5];
    let (first, second) = numbers.split_at_mut(2);
    first[0] = 10;
    ```


---

## **Traits (`Eq`, `Ord`, `PartialEq`, `PartialOrd`) Methods**

These traits provide basic functionality for comparing values.

- **`eq()`**: Checks if two values are equal (`==` in Rust).

    ```rust
    let a = 5;
    let b = 5;
    println!("{}", a.eq(&b)); // true
    ```

- **`ne()`**: Checks if two values are not equal (`!=` in Rust).

    ```rust
    let a = 5;
    let b = 6;
    println!("{}", a.ne(&b)); // true
    ```

- **`cmp()`**: Compares two values and returns an ordering (`Ord` trait). The result can be `Ordering::Less`, `Ordering::Equal`, or `Ordering::Greater`.

    ```rust
    use std::cmp::Ordering;

    let a = 5;
    let b = 6;
    println!("{:?}", a.cmp(&b)); // Ordering::Less
    ```

- **`partial_cmp()`**: Similar to `cmp()`, but works for types that may not have total ordering (like floats).

    ```rust
    let a = 5.0;
    let b = 6.0;
    println!("{:?}", a.partial_cmp(&b)); // Some(Ordering::Less)
    ```

- **`ge()`**: Checks if a value is greater than or equal to another.

    ```rust
    let a = 3;
    let b = 5;
    println!("{}", a.ge(&b)); // false
    ```

- **`le()`**: Checks if a value is less than or equal to another.

    ```rust
    let a = 3;
    let b = 5;
    println!("{}", a.le(&b)); // true
    ```

- **`max_by()`**: Compares two values using a custom comparator and returns the maximum value.

    ```rust
    let a = 3;
    let b = 5;
    println!("{}", a.max_by(|x, y| x.cmp(y))); // 5
    ```

- **`min_by_key()`**: Finds the minimum based on a key extracted by a closure.

    ```rust
    let a = (3, 'a');
    let b = (5, 'b');
    println!("{:?}", a.min_by_key(|t| t.0)); // (3, 'a')
    ```


---

## **Error Handling Methods**

Error handling is mainly done through the `Result<T, E>` type.

- **`expect(msg)`**: Like `unwrap()`, but provides a custom error message if the value is `Err`.

    ```rust
    let result: Result<i32, &str> = Err("error");
    let value = result.expect("Failed to get value"); // Panics with "Failed to get value: error"
    ```

- **`unwrap()`**: Unwraps the `Result`, returning the `Ok` value or panicking if it’s an `Err`.

    ```rust
    let result: Result<i32, &str> = Ok(5);
    let value = result.unwrap(); // 5
    ```

- **`unwrap_or_default()`**: Returns the contained `Ok` value or the default for `T` if the value is `Err`.

    ```rust
    let result: Result<i32, &str> = Err("error");
    let value = result.unwrap_or_default(); // 0 (default for i32)
    ```

- **`and_then()`**: Similar to `map()`, but the function returns a `Result` instead of a plain value.

    ```rust
    let result: Result<i32, &str> = Ok(5);
    let doubled = result.and_then(|val| Ok(val * 2)); // Ok(10)
    ```

- **`or_else()`**: Calls a closure if the result is `Err`, allowing you to generate a new `Result`.

    ```rust
    let result: Result<i32, &str> = Err("error");
    let value = result.or_else(|_err| Ok(10)); // Ok(10)
    ```

- **`map_err(f)`**: Applies a function to the `Err` variant of `Result`, allowing you to transform the error type.

    ```rust
    let result: Result<i32, &str> = Err("error");
    let mapped_err = result.map_err(|e| format!("{}!", e));
    println!("{:?}", mapped_err); // Err("error!")
    ```

- **`ok()`**: Converts a `Result` into an `Option`, discarding the error.

    ```rust
    let result: Result<i32, &str> = Ok(5);
    let value = result.ok();
    println!("{:?}", value); // Some(5)
    ```

---

## **`Debug` and `Display` Traits Methods**

These traits control how values are printed.

- **`fmt()` (for `Display`)**: Used to format the value for user-facing output. This is often used with the `{}` formatting string in `println!()`.

    ```rust
    struct Point {
        x: i32,
        y: i32,
    }

    impl std::fmt::Display for Point {
        fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
            write!(f, "({}, {})", self.x, self.y)
        }
    }

    let p = Point { x: 5, y: 10 };
    println!("{}", p); // (5, 10)
    ```

- **`fmt()` (for `Debug`)**: Used to format the value for debugging output. This is often used with `{:?}`.

    ```rust
    #[derive(Debug)]
    struct Point {
        x: i32,
        y: i32,
    }

    let p = Point { x: 5, y: 10 };
    println!("{:?}", p); // Point { x: 5, y: 10 }
    ```

- **`dbg!()`**: A macro that prints the value and location in the code (file, line number) to help with debugging.

    ```rust
    let x = 5;
    dbg!(x); // [src/main.rs:2] x = 5
    ```

- **`to_string()`**: Converts any value that implements the `Display` trait to a `String`.

    ```rust
    let x = 5;
    let s = x.to_string(); // "5"
    ```

- **`debug_struct()`**: Creates a formatted `Debug` representation of a struct (usually used in custom implementations).

    ```rust
    use std::fmt;

    struct MyStruct { x: i32, y: i32 }

    impl fmt::Debug for MyStruct {
        fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
            f.debug_struct("MyStruct")
             .field("x", &self.x)
             .field("y", &self.y)
             .finish()
        }
    }

    let my_struct = MyStruct { x: 5, y: 10 };
    println!("{:?}", my_struct); // MyStruct { x: 5, y: 10 }
    ```

---

## **`Clone` and `Copy` Traits Methods**

- **`clone()`**: Performs a deep copy of the value.

    ```rust
    let vec = vec![1, 2, 3];
    let vec_clone = vec.clone();
    ```

- **`copy()`**: Unlike `clone`, `Copy` types are duplicated automatically when assigned. This is done for types that implement the `Copy` trait (e.g., integers).

    ```rust
    let x = 5;
    let y = x; // Copy happens here; both x and y are valid
    ```

- **`copy_from_slice()`**: Copies elements from one slice into another.

    ```rust
    let mut dst = [0, 0, 0];
    let src = [1, 2, 3];
    dst.copy_from_slice(&src);
    ```

- **`try_clone()`**: A method used in IO types that implement `Clone`, and it returns a `Result` instead of a plain clone.

    ```rust
    use std::fs::File;
    let file = File::open("example.txt").unwrap();
    let clone = file.try_clone().unwrap();
    ```

---

## **`From` and `Into` Traits**

These traits allow for generic type conversion.

- **`from()`**: Converts one type into another. It is implemented automatically when you implement the `From` trait for your type.

    ```rust
    let s = String::from("hello");
    let i = i32::from(5); // i32::from is implemented for integers
    ```

- **`into()`**: Similar to `from()`, but it allows the destination type to be inferred. You can call `.into()` to convert a value to a different type.

    ```rust
    let s: String = "hello".into();
    let i: i32 = 5.into();
    ```

- **`try_from()` and `try_into()`**: These are fallible versions of `from()` and `into()`. They return a `Result<T, E>` instead of directly converting between types.

    ```rust
    use std::convert::TryFrom;

    let s = "10";
    let num = i32::try_from(s.parse::<i32>().unwrap()).unwrap();
    ```

---

## **Numeric Methods**

- **`abs()`**: Returns the absolute value of a number.

    ```rust
    let x = -5;
    println!("{}", x.abs()); // 5
    ```

- **`pow()`**: Raises the number to a power.

    ```rust
    let x = 2;
    println!("{}", x.pow(3)); // 8
    ```

- **`min()` and `max()`**: Returns the minimum or maximum of two numbers.

    ```rust
    let x = 5;
    let y = 10;
    println!("{}", x.min(y)); // 5
    println!("{}", x.max(y)); // 10
    ```

- **`to_string()`**: Converts a number to a string.

    ```rust
    let x = 5;
    let s = x.to_string();
    println!("{}", s); // "5"
    ```

### Handling Overflows/Underflows

#### 1. **`wrapping_*` Methods:**
   These methods perform arithmetic operations and wrap around on overflow. For example, if you exceed the maximum value of an integer type, it "wraps" around to the minimum value and continues from there.

   - **Example:**
     - In an 8-bit integer (range 0-255), `255 + 1` would wrap around to `0`.
     - Rust: `let result = 255u8.wrapping_add(1); // result is 0`

   - **Analogy:** Think of this as a car odometer: once it reaches its maximum value, it rolls over back to zero.

- **`wrapping_add()`**: Adds two numbers, wrapping around on overflow.

    ```rust
    let a: i32 = 2147483647;
    println!("{}", a.wrapping_add(1)); // -2147483648
    ```


#### 2. **`checked_*` Methods:**
   These methods perform arithmetic and return `None` if an overflow occurs. They are useful when you want to explicitly check for overflow.

   - **Example:**
     - Rust: `let result = 255u8.checked_add(1); // result is None`
   
   - **Analogy:** This is like a safe where you try to open it, and it gives you a warning or fails silently when you enter a wrong code.

- **`checked_add()`**: Adds two numbers, returning `None` if there’s an overflow.

    ```rust
    let a: i32 = 2147483647;
    println!("{:?}", a.checked_add(1)); // None
    ```

- **`checked_div()`**: Divides two numbers, returning `None` if division would result in overflow or divide by zero.

    ```rust
    let a: i32 = 10;
    println!("{:?}", a.checked_div(0)); // None
    ```

#### 3. **`overflowing_*` Methods:**
   These methods perform arithmetic operations and return a tuple containing the result and a boolean that indicates whether an overflow occurred.

   - **Example:**
     - Rust: `let (result, overflowed) = 255u8.overflowing_add(1); // result is 0, overflowed is true`
   
   - **Analogy:** This is like having an indicator light on a machine that shows whether a process overflowed or exceeded its limits while continuing to give you a result.

#### 4. **`saturating_*` Methods:**
   These methods perform arithmetic and "saturate" at the numeric bounds instead of wrapping around. When an overflow would occur, the result is clamped to the maximum or minimum value of the integer type.

   - **Example:**
     - Rust: `let result = 255u8.saturating_add(1); // result is 255`
   
   - **Analogy:** Imagine you're pouring water into a cup. Once it's full, no more water can enter—it just stops at the top.

- **`saturating_add()`**: Adds two numbers, saturating at the numeric bounds instead of overflowing.

    ```rust
    let a: i32 = 2147483647;
    println!("{}", a.saturating_add(1)); // 2147483647
    ```

## Vector Methods

In Rust, the `Vec<T>` type is one of the most commonly used collections. It represents a dynamically-sized array and provides many methods to manipulate its contents. Below is a comprehensive list of useful methods for working with vectors in Rust, categorized for better understanding.

### 1. **Creation and Initialization**

- **`new()`**  
  Creates an empty vector.

  ```rust
  let v: Vec<i32> = Vec::new();
  ```

- **`with_capacity(capacity: usize)`**  
  Creates a new vector with a specified capacity.

  ```rust
  let mut v = Vec::with_capacity(10);
  ```

- **`vec![]`**  
  A macro to create a vector with initial values.

  ```rust
  let v = vec![1, 2, 3, 4, 5];
  ```

---

### 2. **Adding and Removing Elements**

- **`push(value: T)`**  
  Appends an element to the back of the vector.

  ```rust
  let mut v = Vec::new();
  v.push(10);
  ```

- **`pop()`**  
  Removes and returns the last element of the vector (if any). Returns `None` if the vector is empty.

  ```rust
  let mut v = vec![1, 2, 3];
  let last = v.pop();  // Some(3)
  ```

- **`insert(index: usize, element: T)`**  
  Inserts an element at the specified position, shifting elements to the right.

  ```rust
  let mut v = vec![1, 2, 4];
  v.insert(2, 3);  // [1, 2, 3, 4]
  ```

- **`remove(index: usize)`**  
  Removes and returns the element at the specified position, shifting elements to the left.

  ```rust
  let mut v = vec![1, 2, 3];
  v.remove(1);  // Returns 2, vector becomes [1, 3]
  ```

---

### 3. **Accessing Elements**

- **`get(index: usize)`**  
  Returns an `Option<&T>` for the element at the specified position.

  ```rust
  let v = vec![1, 2, 3];
  let value = v.get(1);  // Some(&2)
  ```

- **`[index]` (Indexing)**  
  Directly access an element using indexing. Panics if out of bounds.

  ```rust
  let v = vec![1, 2, 3];
  let value = v[1];  // 2
  ```

- **`first()`**  
  Returns an `Option<&T>` for the first element of the vector.

  ```rust
  let v = vec![1, 2, 3];
  let first = v.first();  // Some(&1)
  ```

- **`last()`**  
  Returns an `Option<&T>` for the last element of the vector.

  ```rust
  let v = vec![1, 2, 3];
  let last = v.last();  // Some(&3)
  ```

---

### 4. **Capacity and Size**

- **`len()`**  
  Returns the number of elements in the vector.

  ```rust
  let v = vec![1, 2, 3];
  println!("{}", v.len());  // 3
  ```

- **`capacity()`**  
  Returns the number of elements the vector can hold without reallocating.

  ```rust
  let v = Vec::with_capacity(10);
  println!("{}", v.capacity());  // 10
  ```

- **`is_empty()`**  
  Returns `true` if the vector contains no elements.

  ```rust
  let v: Vec<i32> = Vec::new();
  println!("{}", v.is_empty());  // true
  ```

- **`reserve(additional: usize)`**  
  Reserves capacity for at least `additional` more elements.

  ```rust
  let mut v = Vec::new();
  v.reserve(10);
  ```

- **`shrink_to_fit()`**  
  Shrinks the capacity of the vector to match its length.

  ```rust
  let mut v = Vec::with_capacity(10);
  v.push(1);
  v.shrink_to_fit();  // Capacity becomes 1
  ```

---

### 5. **Slicing and Iterating**

- **`as_slice()`**  
  Returns a slice that references the entire vector.

  ```rust
  let v = vec![1, 2, 3];
  let slice = v.as_slice();  // &[1, 2, 3]
  ```

- **`iter()`**  
  Returns an iterator over references to the elements of the vector.

  ```rust
  let v = vec![1, 2, 3];
  for val in v.iter() {
      println!("{}", val);
  }
  ```

- **`iter_mut()`**  
  Returns a mutable iterator over the elements of the vector.

  ```rust
  let mut v = vec![1, 2, 3];
  for val in v.iter_mut() {
      *val += 10;
  }
  ```

- **`into_iter()`**  
  Consumes the vector and returns an iterator that yields the elements by value.

  ```rust
  let v = vec![1, 2, 3];
  for val in v.into_iter() {
      println!("{}", val);
  }
  ```

---

### 6. **Manipulation and Modification**

- **`retain(predicate: F)`**  
  Retains only the elements specified by the predicate function.

  ```rust
  let mut v = vec![1, 2, 3, 4];
  v.retain(|&x| x % 2 == 0);  // Retains only even numbers: [2, 4]
  ```

- **`clear()`**  
  Clears the vector, removing all elements.

  ```rust
  let mut v = vec![1, 2, 3];
  v.clear();  // Now the vector is empty: []
  ```

- **`split_off(at: usize)`**  
  Splits the vector into two at the given index. Returns the tail portion.

  ```rust
  let mut v = vec![1, 2, 3, 4];
  let tail = v.split_off(2);  // v = [1, 2], tail = [3, 4]
  ```

---

### 7. **Combining Vectors**

- **`extend<I: IntoIterator<Item=T>>(iter: I)`**  
  Extends the vector with the contents of an iterator.

  ```rust
  let mut v = vec![1, 2];
  v.extend([3, 4, 5].iter().cloned());
  // v is now [1, 2, 3, 4, 5]
  ```

- **`append(&mut other: Vec<T>)`**  
  Moves all elements from `other` into the vector, leaving `other` empty.

  ```rust
  let mut v1 = vec![1, 2];
  let mut v2 = vec![3, 4];
  v1.append(&mut v2);  // v1 = [1, 2, 3, 4], v2 is empty
  ```

- **`concat()`**  
  Concatenates all slices in the vector into a single vector.

  ```rust
  let v = vec![vec![1, 2], vec![3, 4]].concat();  // [1, 2, 3, 4]
  ```

- **`join(separator: T)`**  
  Joins all elements of the vector with the given separator.

  ```rust
  let v = vec![vec![1], vec![2], vec![3]];
  let joined = v.join(&0);  // [1, 0, 2, 0, 3]
  ```

---

### 8. **Sorting and Reversing**

- **`sort()`**  
  Sorts the vector in place using the natural order of the elements.

  ```rust
  let mut v = vec![3, 1, 2];
  v.sort();  // v becomes [1, 2, 3]
  ```

- **`sort_by(|a, b| ordering)`**  
  Sorts the vector in place using a comparator function.

  ```rust
  let mut v = vec![3, 1, 2];
  v.sort_by(|a, b| a.cmp(b));  // Same as sort(), v becomes [1, 2, 3]
  ```

- **`reverse()`**  
  Reverses the order of the elements in the vector.

  ```rust
  let mut v = vec![1, 2, 3];
  v.reverse();  // v becomes [3, 2, 1]
  ```

## String Methods

In Rust, the `String` type provides several useful methods for creating, modifying, querying, and manipulating string data. Here are some of the common methods available for `String`:

`new`
Creates a new empty `String`.

```rust
let s = String::new();
```

---

`from`
Creates a `String` from a string literal.

```rust
let s = String::from("Hello");
```

---

`push`
Appends a single character to the end of a `String`.

```rust
let mut s = String::from("Hello");
s.push('!');
println!("{}", s);  // "Hello!"
```

---

`push_str`
Appends a string slice (`&str`) to the end of a `String`.

```rust
let mut s = String::from("Hello");
s.push_str(", world!");
println!("{}", s);  // "Hello, world!"
```

---

`len`
Returns the length of the `String`, in bytes.

```rust
let s = String::from("Hello");
println!("{}", s.len());  // 5
```

---

`is_empty`
Returns `true` if the `String` is empty.

```rust
let s = String::new();
println!("{}", s.is_empty());  // true
```

---

`clear`
Clears the `String`, removing all contents but keeping the allocated memory.

```rust
let mut s = String::from("Hello");
s.clear();
println!("{}", s.is_empty());  // true
```

---
 `insert`
Inserts a character at a specific index in the `String`.

```rust
let mut s = String::from("Hello");
s.insert(5, ',');
println!("{}", s);  // "Hello,"
```

---

`insert_str`
Inserts a string slice at a specific index in the `String`.

```rust
let mut s = String::from("Hello");
s.insert_str(5, ", world!");
println!("{}", s);  // "Hello, world!"
```

---

`remove`
Removes and returns the character at a specified index. Shifts all characters after the removed one to the left.

```rust
let mut s = String::from("Hello, world!");
let ch = s.remove(5);
println!("{}", s);  // "Hello world!"
println!("{}", ch); // ','
```

---

`replace`
Replaces all matches of a pattern (string slice) with another string slice.

```rust
let s = String::from("I like apples");
let new_s = s.replace("apples", "oranges");
println!("{}", new_s);  // "I like oranges"
```

---

`find`
Returns the byte index of the first occurrence of a substring. Returns `None` if not found.

```rust
let s = String::from("I like apples");
let idx = s.find("apples");
println!("{:?}", idx);  // Some(7)
```

---

`split_whitespace`
Splits the string by whitespace and returns an iterator.

```rust
let s = String::from("I like apples");
for word in s.split_whitespace() {
    println!("{}", word);
}
// Output:
// I
// like
// apples
```

---

`trim`
Removes leading and trailing whitespace from a string.

```rust
let s = String::from("   Hello, world!   ");
println!("{}", s.trim());  // "Hello, world!"
```

---

`chars`
Returns an iterator over the characters of the `String`.

```rust
let s = String::from("Hello");
for ch in s.chars() {
    println!("{}", ch);
}
// Output:
// H
// e
// l
// l
// o
```

---

`to_uppercase`
Returns a new `String` where all the characters are converted to uppercase.

```rust
let s = String::from("Hello");
let upper = s.to_uppercase();
println!("{}", upper);  // "HELLO"
```

---

`to_lowercase`
Returns a new `String` where all the characters are converted to lowercase.

```rust
let s = String::from("HELLO");
let lower = s.to_lowercase();
println!("{}", lower);  // "hello"
```

---

`pop`
Removes the last character from the `String` and returns it. Returns `None` if the `String` is empty.

```rust
let mut s = String::from("Hello!");
let ch = s.pop();
println!("{}", s);  // "Hello"
println!("{:?}", ch);  // Some('!')
```

---

`concat`
Concatenates two or more `String`s or `&str` slices.

```rust
let s1 = String::from("Hello, ");
let s2 = String::from("world!");
let s3 = s1 + &s2;  // Note: s1 is moved here and can no longer be used
println!("{}", s3);  // "Hello, world!"
```

---

`capacity`
Returns the total allocated capacity of the `String` in bytes.

```rust
let s = String::with_capacity(10);
println!("{}", s.capacity());  // 10
```

---

 `reserve`
Reserves at least the specified number of bytes of capacity.

```rust
let mut s = String::new();
s.reserve(10);  // Allocates at least 10 bytes for the string
```

---

`as_str`
Returns a string slice (`&str`) of the `String`.

```rust
let s = String::from("Hello");
let slice = s.as_str();
println!("{}", slice);  // "Hello"
```

---

`split_off`
Splits the string at the given index and returns the second half as a new `String`. The original string is truncated.

```rust
let mut s = String::from("Hello, world!");
let second_half = s.split_off(7);
println!("{}", s);         // "Hello, "
println!("{}", second_half);  // "world!"
```

## `File` Methods

In Rust, the `File` type (part of the `std::fs` module) is used to handle file operations such as opening, reading, writing, and creating files. The `File` struct offers various methods to manage file operations safely and efficiently. Below are some commonly used methods for the `File` type:

1. **`open`**  
   Opens an existing file in read-only mode. It returns a `Result<File>` where the `File` is the file handle if successful.
   
   ```rust
   use std::fs::File;
   use std::io::Error;

   fn main() -> Result<(), Error> {
       let file = File::open("hello.txt")?;
       Ok(())
   }
   ```

2. **`create`**  
   Opens a file in write-only mode, creating the file if it doesn't exist or truncating it (clearing it) if it does. Returns a `Result<File>`.
   
   ```rust
   use std::fs::File;
   use std::io::Error;

   fn main() -> Result<(), Error> {
       let file = File::create("new_file.txt")?;
       Ok(())
   }
   ```

3. **`read_to_string`**  
   Reads the contents of a file into a `String`. Requires importing `std::io::Read` because this method is part of the `Read` trait.
   
   ```rust
   use std::fs::File;
   use std::io::{self, Read};

   fn main() -> io::Result<()> {
       let mut file = File::open("hello.txt")?;
       let mut contents = String::new();
       file.read_to_string(&mut contents)?;
       println!("File contents: {}", contents);
       Ok(())
   }
   ```

4. **`write`**  
   Writes data to a file. This method requires importing `std::io::Write`, as it is part of the `Write` trait.
   
   ```rust
   use std::fs::File;
   use std::io::{self, Write};

   fn main() -> io::Result<()> {
       let mut file = File::create("output.txt")?;
       file.write_all(b"Hello, world!")?;
       Ok(())
   }
   ```

5. **`sync_all`**  
   Flushes all in-memory file contents to disk and ensures that they are written. Returns a `Result<()>` indicating success or failure.
   
   ```rust
   use std::fs::File;
   use std::io;

   fn main() -> io::Result<()> {
       let mut file = File::create("output.txt")?;
       file.write_all(b"Hello, world!")?;
       file.sync_all()?;  // Ensures data is written to disk.
       Ok(())
   }
   ```

6. **`sync_data`**  
   Similar to `sync_all`, but only flushes the file’s data to disk, not metadata like timestamps.

   ```rust
   use std::fs::File;
   use std::io;

   fn main() -> io::Result<()> {
       let mut file = File::create("output.txt")?;
       file.write_all(b"Hello, world!")?;
       file.sync_data()?;  // Flushes file data only.
       Ok(())
   }
   ```

7. **`set_len`**  
   Truncates or extends the file to a specified size.
   
   ```rust
   use std::fs::File;
   use std::io;

   fn main() -> io::Result<()> {
       let mut file = File::create("output.txt")?;
       file.set_len(100)?;  // Sets the file length to 100 bytes.
       Ok(())
   }
   ```

8. **`metadata`**  
   Returns metadata information about the file (like its size, permissions, etc.).
   
   ```rust
   use std::fs::File;
   use std::io;

   fn main() -> io::Result<()> {
       let file = File::open("hello.txt")?;
       let metadata = file.metadata()?;
       println!("File size: {}", metadata.len());
       Ok(())
   }
   ```

9. **`try_clone`**  
   Creates a new handle to the same file. Cloning a file handle allows you to share the file between different parts of the program.
   
   ```rust
   use std::fs::File;
   use std::io;

   fn main() -> io::Result<()> {
       let file = File::open("hello.txt")?;
       let file_clone = file.try_clone()?;
       Ok(())
   }
   ```

### Read and Write Trait Methods:

- **`read_to_end`**  
  Reads the entire contents of a file into a `Vec<u8>`.

  ```rust
  use std::fs::File;
  use std::io::{self, Read};

  fn main() -> io::Result<()> {
      let mut file = File::open("hello.txt")?;
      let mut buffer = Vec::new();
      file.read_to_end(&mut buffer)?;
      Ok(())
  }
  ```

- **`write_all`**  
  Writes all bytes from a buffer to the file.

  ```rust
  use std::fs::File;
  use std::io::{self, Write};

  fn main() -> io::Result<()> {
      let mut file = File::create("output.txt")?;
      file.write_all(b"Rust is awesome!")?;
      Ok(())
  }
  ```

## `Entry` 

In Rust, the Entry API is used to handle situations where you want to check if a key exists in a collection (like a HashMap), and then either modify the existing entry or insert a new one if it doesn’t exist. This is commonly done with the HashMap collection.

### Common Entry Methods

#### 1. or_insert

If the entry is vacant (doesn’t exist), inserts the provided value and returns a mutable reference to the value. If it exists, returns a mutable reference to the existing value.

Example:

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();
scores.insert("Blue", 10);

let entry = scores.entry("Blue").or_insert(50);
println!("The score is: {}", entry); // The score is: 10

let entry = scores.entry("Yellow").or_insert(50);
println!("The score is: {}", entry); // The score is: 50
```


#### 2. or_insert_with

Similar to or_insert, but instead of inserting a provided value, it inserts the result of a function or closure if the key is vacant.

Example:

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.entry("Blue").or_insert_with(|| 50);
println!("{:?}", scores); // {"Blue": 50}

scores.entry("Yellow").or_insert_with(|| 30);
println!("{:?}", scores); // {"Blue": 50, "Yellow": 30}
```

#### 3. and_modify

Modifies the value of an existing entry if it exists, but does nothing if the entry is vacant.

Example:

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();
scores.insert("Blue", 10);

scores.entry("Blue").and_modify(|v| *v += 10);
scores.entry("Yellow").and_modify(|v| *v += 10); // Does nothing

println!("{:?}", scores); // {"Blue": 20}
```


#### 4. key

Returns a reference to the key for this entry.

Example:

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();
scores.insert("Blue", 10);

let entry = scores.entry("Blue");
println!("Key: {}", entry.key()); // Key: Blue
```


### Entry Enum Variants

The Entry type can either be a Vacant or Occupied entry. These represent whether the key exists in the map or not:

#### 1. Occupied

Represents an entry that exists in the map.

Example:

```rust
use std::collections::HashMap;

let mut map = HashMap::new();
map.insert("Blue", 10);

if let std::collections::hash_map::Entry::Occupied(entry) = map.entry("Blue") {
    println!("Found: {}", entry.get()); // Found: 10
}
```


#### 2. Vacant

Represents an entry that does not exist in the map, allowing you to insert a new value.

Example:

```rust
use std::collections::HashMap;

let mut map = HashMap::new();

if let std::collections::hash_map::Entry::Vacant(entry) = map.entry("Blue") {
    entry.insert(10);
}

println!("{:?}", map); // {"Blue": 10}
```

# Functions

## `assert_eq!` & `assert_ne!`

The `assert_eq!` macro in Rust is used to check if two expressions are equal. It compares the two provided values, and if they are not equal, it will cause a panic at runtime with a message that includes the values of both expressions for easier debugging.

Syntax:

```rust
assert_eq!(left, right);
```
If the left expression and the right expression are equal, the program continues running normally. If they are not equal, the program will panic and print an error message showing both values.

**Example 1: When the values are equal (no panic)**

```rust
fn main() {
    let a = 5;
    let b = 5;

    assert_eq!(a, b);  // This will pass as a == b.
    println!("Test passed!");
}
```

Output:

```
Test passed!
```

**Example 2: When the values are not equal (panic)**

```rust
fn main() {
    let a = 5;
    let b = 6;

    assert_eq!(a, b);  // This will panic as a != b.
}
```

Output (with a panic message):

```
thread 'main' panicked at 'assertion failed: (left == right)
  left: `5`,
 right: `6`', src/main.rs:5:5
```

**Additional Notes:**

1. **Custom Error Message**: You can also provide an additional custom error message as an argument if you'd like:

```rust
fn main() {
    let a = 5;
    let b = 6;

    assert_eq!(a, b, "Values are not equal! a: {}, b: {}", a, b);
}
```

Output:

```
thread 'main' panicked at 'Values are not equal! a: 5, b: 6', src/main.rs:5:5
```


2. **assert_ne!**: Rust also provides assert_ne!, which checks if two values are not equal. This is the inverse of assert_eq!.

```rust
fn main() {
    let a = 5;
    let b = 6;

    assert_ne!(a, b);  // This will pass because a != b.
    println!("Test passed!");
}
```


3. **Equality Requirements**: The types of the values compared with assert_eq! must implement the `PartialEq` trait (which most primitive types do). The values must also be of the same type, or else the code will not compile.

```rust
let a = 5;
let b = 5.0;  // Different types: `i32` vs `f64`.

assert_eq!(a, b);  // Compile-time error because of type mismatch.
```


**Usage in Tests**:

`assert_eq!` is frequently used in unit tests to ensure that function outputs match expected results.

```
#[cfg(test)]
mod tests {
    #[test]
    fn test_sum() {
        let result = 2 + 2;
        assert_eq!(result, 4);  // The test will pass.
    }
}
```

## `format!`, `println!`, `eprintln!`

In Rust, `format!`, `println!`, and `eprintln!` are macros used for creating and printing formatted strings. They each serve slightly different purposes:

---

### 1. **`format!`**

The `format!` macro creates a formatted `String` without printing it. It works similarly to `println!` but instead returns the string rather than outputting it to the console.

- **Use case**: When you need to create a formatted string to store or use later without immediately printing it.

**Example**:

```rust
let name = "Alice";
let age = 30;
let message = format!("My name is {} and I am {} years old.", name, age);
println!("{}", message); // Prints: My name is Alice and I am 30 years old.
```

### 2. **`println!`**

The `println!` macro prints a formatted string to the standard output (usually the terminal) followed by a newline (`\n`).

- **Use case**: When you want to print information to the user in a formatted way.

**Example**:

```rust
let name = "Bob";
let age = 25;
println!("My name is {} and I am {} years old.", name, age);
// Prints: My name is Bob and I am 25 years old.
```

### 3. **`eprintln!`**

The `eprintln!` macro is similar to `println!`, but it prints to the standard error output (`stderr`) instead of the standard output (`stdout`). This is useful for logging errors or debugging information separately from regular program output.

- **Use case**: When you need to print error messages or debugging information to `stderr`, which can be useful in error handling and debugging.

**Example**:

```rust
let error_message = "An unexpected error occurred.";
eprintln!("Error: {}", error_message);
// Prints to stderr: Error: An unexpected error occurred.
```

---

**Differences**

- **Output**:
  - `println!` outputs to standard output (`stdout`).
  - `eprintln!` outputs to standard error (`stderr`).
  - `format!` does not print anything; it returns a `String`.

- **Return Value**:
  - `println!` and `eprintln!` return `()`, the unit type.
  - `format!` returns a `String`.

## Format Specifers

In Rust, formatting specifiers are used with the `format!`, `println!`, `eprintln!`, and similar macros to format strings. Each specifier modifies how the value is represented in the output. Below are some of the common and useful formatting specifiers:

---

### Basic Formatting Specifiers

1. **`{}`**: Default formatting. For types implementing the `Display` trait, this formats the value for user-facing output.

    ```rust
    let name = "Alice";
    println!("Hello, {}!", name); // Hello, Alice!
    ```

2. **`{:?}`**: Debug formatting. For types implementing the `Debug` trait, this formats the value for developer-facing output. Useful for inspecting internal representations.

    ```rust
    let v = vec![1, 2, 3];
    println!("{:?}", v); // [1, 2, 3]
    ```

3. **`{:#?}`**: Pretty Debug formatting. Like `{:?}`, but prints in a multi-line, indented format for better readability of complex structures.

    ```rust
    let v = vec![1, 2, 3];
    println!("{:#?}", v);
    // [
    //     1,
    //     2,
    //     3,
    // ]
    ```

---

### Number Formatting Specifiers

4. **`{:b}`**: Binary formatting.

    ```rust
    let num = 42;
    println!("{:b}", num); // 101010
    ```

5. **`{:o}`**: Octal formatting.

    ```rust
    let num = 42;
    println!("{:o}", num); // 52
    ```

6. **`{:x}`**: Lowercase hexadecimal formatting.

    ```rust
    let num = 42;
    println!("{:x}", num); // 2a
    ```

7. **`{:X}`**: Uppercase hexadecimal formatting.

    ```rust
    let num = 42;
    println!("{:X}", num); // 2A
    ```

8. **`{:e}`**: Scientific notation (lowercase "e").

    ```rust
    let num = 12345.6789;
    println!("{:e}", num); // 1.23456789e4
    ```

9. **`{:E}`**: Scientific notation (uppercase "E").

    ```rust
    let num = 12345.6789;
    println!("{:E}", num); // 1.23456789E4
    ```

---

### Alignment and Padding

10. **`{:width$}`**: Specifies a minimum width. Right-aligns by default.

    ```rust
    let num = 42;
    println!("{:5}", num); // "   42"
    ```

11. **`{:<width$}`**: Left-align within the specified width.

    ```rust
    let num = 42;
    println!("{:<5}", num); // "42   "
    ```

12. **`{:>width$}`**: Right-align within the specified width (same as default).

    ```rust
    let num = 42;
    println!("{:>5}", num); // "   42"
    ```

13. **`{:^width$}`**: Center-align within the specified width.

    ```rust
    let num = 42;
    println!("{:^5}", num); // " 42 "
    ```

14. **`{:0width$}`**: Zero padding. Pads numbers with leading zeros instead of spaces.

    ```rust
    let num = 42;
    println!("{:05}", num); // "00042"
    ```

---

### Precision for Floating-Point Numbers

15. **`{:.precision$}`**: Specifies the number of digits after the decimal point.

    ```rust
    let num = 3.141592;
    println!("{:.2}", num); // "3.14"
    ```

16. **`{:width$.precision$}`**: Combines width and precision for floating-point numbers.

    ```rust
    let num = 3.141592;
    println!("{:8.2}", num); // "    3.14"
    ```

---

### Sign Formatting

17. **`{:+}`**: Always show the sign for numbers.

    ```rust
    let num = 42;
    let neg_num = -42;
    println!("{:+}", num);     // "+42"
    println!("{:+}", neg_num); // "-42"
    ```

18. **`{: }`**: Space for positive numbers, minus for negative. Leaves a leading space for positive values.

    ```rust
    let num = 42;
    let neg_num = -42;
    println!("{: }", num);     // " 42"
    println!("{: }", neg_num); // "-42"
    ```

---

### Other Specifiers

19. **`{:p}`**: Pointer formatting. Prints a memory address.

    ```rust
    let s = "hello";
    println!("{:p}", s as *const str); // Prints the address of `s`
    ```

20. **Escaping Braces**: Use `{{` or `}}` to print a literal `{` or `}`.

    ```rust
    println!("{{Hello}}"); // "{Hello}"
    ```

---

**Example of Combining Specifiers**

You can combine different specifiers to achieve complex formatting:

```rust
let num = 42;
println!("{:+08}", num); // "+00000042"
```

In this example:
- `+` shows the sign.
- `0` pads with zeros.
- `8` sets the width to 8 characters.

# Traits

### **`Clone`**

The **`Clone`** trait in Rust allows for creating a **deep copy** of a value. Unlike the **`Copy`** trait, which provides a simple, implicit copy of types that are cheap to duplicate (like integers), `Clone` requires an explicit call to its `clone()` method and is used for types that manage heap-allocated memory or other resources.

---

**Simple Definition**

`Clone` is a trait for creating a copy of an object, often involving heap allocation. It is explicitly invoked using `.clone()`.

---

**Example**

```rust
#[derive(Clone)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p1 = Point { x: 5, y: 10 };
    let p2 = p1.clone(); // Creates a deep copy of `p1`

    println!("p1: ({}, {}), p2: ({}, {})", p1.x, p1.y, p2.x, p2.y);
}
```

---

**Key Characteristics**

1. **Explicit Call**: You must call `.clone()` explicitly; cloning is not implicit like copying.
2. **Heap Allocation**: Often used when types involve heap memory, such as `String` or `Vec<T>`.
3. **Custom Implementation**: You can manually implement the `Clone` trait for custom behavior.
4. **Requires `Clone` Derivation**: For simple types, you can derive the `Clone` trait automatically.

---

**Common Use Case: Cloning Heap Data**

```rust
fn main() {
    let s1 = String::from("Hello");
    let s2 = s1.clone(); // Creates a deep copy of the string

    println!("s1: {}, s2: {}", s1, s2);
}
```

---

**Manual Implementation of `Clone`**

```rust
struct MyStruct {
    data: Vec<i32>,
}

impl Clone for MyStruct {
    fn clone(&self) -> Self {
        MyStruct {
            data: self.data.clone(), // Deep copy of the vector
        }
    }
}

fn main() {
    let original = MyStruct {
        data: vec![1, 2, 3],
    };
    let cloned = original.clone();

    println!("Original: {:?}, Cloned: {:?}", original.data, cloned.data);
}
```

---

**Difference Between `Clone` and `Copy`**

|**Feature**|**Clone**|**Copy**|
|---|---|---|
|**Explicit Call**|Yes, with `.clone()`|No, implicit on assignment|
|**Complex Types**|Used for heap-allocated or non-trivial data|Used for simple types (e.g., integers, floats)|
|**Performance**|Can be more expensive due to deep copying|Very cheap (stack-only copy)|

Example of **`Copy`**:

```rust
fn main() {
    let a = 5;      // i32 implements Copy
    let b = a;      // Implicit copy
    println!("{}", a); // `a` is still usable
}
```

---

**Cloning in Iterators**

The `clone()` method is often used when working with iterators where data needs to be reused:

```rust
fn main() {
    let nums = vec![1, 2, 3];
    let cloned_nums = nums.clone();

    for num in cloned_nums {
        println!("{}", num);
    }
    // The original `nums` is still available
    for num in nums {
        println!("{}", num);
    }
}
```

---

**Common Types Implementing `Clone`**

- **Primitives**: `bool`, `char`, etc.
- **Collections**: `String`, `Vec<T>`, `HashMap<K, V>`, etc.
- **Custom Structs/Enums**: If the trait is derived or implemented.

---

**Conclusion**

The `Clone` trait is essential in Rust for making deep copies of values, particularly when working with heap-allocated resources. It offers flexibility and safety while requiring explicit cloning to avoid unintentional resource duplication. For simpler types, the `Copy` trait may suffice, but `Clone` provides greater control for complex data structures.

### **`Copy`**

The **`Copy`** trait in Rust allows for **bitwise copying** of types, meaning the data is duplicated without needing a manual call to `.clone()`. It is used for simple, fixed-size types stored on the stack and is meant for types where deep cloning is unnecessary.

---

**Simple Definition**

`Copy` is a marker trait that enables types to be **implicitly duplicated** without moving ownership.

---

**Example**

```rust
fn main() {
    let x = 42;   // i32 implements Copy
    let y = x;    // `x` is copied to `y`, not moved
    println!("{}", x); // `x` is still accessible
}
```

---

**Key Characteristics**

1. **Implicit Copying**: No need to call `.clone()`; values are copied automatically on assignment or passing.
2. **Fixed-Size and Stack-Only**: Only types with a fixed, stack-allocated size can implement `Copy`.
3. **No Drop**: Types implementing `Drop` cannot also implement `Copy`.
4. **Derivable**: You can derive the `Copy` trait for eligible types.

---

**Copyable Types**

- Primitive types: `i32`, `f64`, `bool`, `char`, etc.
- Arrays (if the elements implement `Copy`): `[i32; 3]`
- Tuples (if all elements implement `Copy`): `(i32, f64)`

---

**Non-Copyable Types**

Heap-allocated or dynamically sized types like `String`, `Vec<T>`, and `HashMap<K, V>` cannot implement `Copy`. This is because duplicating these types requires managing the heap memory they point to, which is beyond the capabilities of `Copy`.

```rust
fn main() {
    let s1 = String::from("hello");
    let s2 = s1;  // Ownership is moved, not copied
    // println!("{}", s1); // Error: `s1` is no longer valid
}
```

---

**Difference Between `Copy` and `Clone`**

|**Feature**|**Copy**|**Clone**|
|---|---|---|
|**Explicit Call**|No, implicit copy on assignment|Yes, must call `.clone()`|
|**Use Case**|Simple, stack-only types|Complex, heap-allocated types|
|**Cost**|Cheap, no heap interaction|Potentially expensive (deep copy)|
|**Ownership**|Ownership is preserved|Ownership is preserved|

---

**Example: Deriving `Copy`**

```rust
#[derive(Copy, Clone)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p1 = Point { x: 1, y: 2 };
    let p2 = p1;  // p1 is copied, not moved
    println!("p1: ({}, {}), p2: ({}, {})", p1.x, p1.y, p2.x, p2.y);
}
```

---

**When to Use `Copy`**

- For simple data that is cheap to duplicate.
- When you want implicit copying instead of manually calling `.clone()`.
- Examples: Numeric types, small structs, or tuples without heap data.

---

**Custom Implementation**

The `Copy` trait cannot be implemented manually; it must be derived or automatically implemented by Rust if the type meets the requirements.

```rust
struct MyStruct(i32); // This struct does not implement Copy
fn main() {
    let a = MyStruct(10);
    let b = a;  // Ownership of `a` is moved to `b`
    // println!("{}", a.0); // Error: `a` is no longer valid
}
```

If you want `Copy`, you need to derive it:

```rust
#[derive(Copy, Clone)]
struct MyStruct(i32);
fn main() {
    let a = MyStruct(10);
    let b = a;  // `a` is copied to `b`
    println!("{}", a.0); // `a` is still accessible
}
```

---

**Copy with Functions**

When passing `Copy` types to functions, the value is **copied** instead of moved:

```rust
fn print_num(n: i32) {
    println!("{}", n);
}

fn main() {
    let x = 42;
    print_num(x); // `x` is copied into the function
    println!("{}", x); // `x` is still accessible
}
```

---

**Conclusion**

The `Copy` trait is a lightweight way to enable implicit duplication of stack-only data, ideal for simple types where deep cloning is unnecessary. For more complex types or heap-allocated data, use the `Clone` trait instead.

### **`Display`**

The `Display` trait in Rust is used to format a type into a user-facing string. It is part of the `std::fmt` module and allows custom types to be represented as readable text, typically for printing.

**Usage**

To implement the `Display` trait, you must define the `fmt` method, which takes a mutable reference to a `Formatter` and writes the formatted string to it.

**Syntax**

```rust
use std::fmt;

impl fmt::Display for MyType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "formatted string")
    }
}
```

**Example**

```rust
use std::fmt;

struct Point {
    x: i32,
    y: i32,
}

impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

fn main() {
    let p = Point { x: 1, y: 2 };
    println!("{}", p); // Output: (1, 2)
}
```

**Formatter Options**

The `Formatter` provides options to customize the output:

- `f.width()`: Returns the minimum width for formatting.
- `f.precision()`: Returns the precision for floating-point formatting.
- `f.alternate()`: Returns `true` if alternate formatting is requested (e.g., `{:#}`).

**Example with Formatter Options**

```rust
use std::fmt;

struct Rectangle {
    width: u32,
    height: u32,
}

impl fmt::Display for Rectangle {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if f.alternate() {
            write!(f, "Rectangle {{ width: {}, height: {} }}", self.width, self.height)
        } else {
            write!(f, "{}x{}", self.width, self.height)
        }
    }
}

fn main() {
    let rect = Rectangle { width: 30, height: 50 };
    println!("{}", rect);          // Output: 30x50
    println!("{:#}", rect);        // Output: Rectangle { width: 30, height: 50 }
}
```

**Key Points**

- The `Display` trait is often implemented alongside the `Debug` trait, but `Display` focuses on user-friendly output.
- Use `write!` for writing formatted strings in the `fmt` method.
- The `to_string()` method is automatically available for types implementing `Display`.

Would you like examples of implementing `Display` for enums or other advanced scenarios?

### **`Debug`**

The **`Debug`** trait in Rust enables a type to be formatted using the `{:?}` or `{:#?}` format specifiers, primarily for debugging purposes. It provides a readable, developer-friendly textual representation of values, often used for inspecting the state of a program during development.

---

**Simple Definition**

The **`Debug`** trait allows you to print a type's internal structure for debugging purposes.

---

**Example**

```rust
#[derive(Debug)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let point = Point { x: 10, y: 20 };
    println!("{:?}", point); // Debug output
}
```

Output:

```
Point { x: 10, y: 20 }
```

---

**Features of `Debug`**

1. **Human-Readable Output**: Displays the structure and fields of a type in a readable format.
2. **For Debugging Only**: The output is not optimized for end-user display; it is for developer inspection.
3. **Derivable**: Most structs and enums can derive `Debug` automatically.
4. **Pretty Printing**: Use `{:#?}` for a multi-line, indented representation of nested structures.

---

**Pretty Printing Example**

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect = Rectangle {
        width: 30,
        height: 50,
    };
    println!("{:#?}", rect); // Pretty-print
}
```

Output:

```
Rectangle {
    width: 30,
    height: 50,
}
```

---

**Custom Implementation of `Debug`**

You can manually implement the `Debug` trait for a type to customize the output:

```rust
use std::fmt;

struct Point {
    x: i32,
    y: i32,
}

impl fmt::Debug for Point {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Point({}, {})", self.x, self.y)
    }
}

fn main() {
    let point = Point { x: 5, y: 10 };
    println!("{:?}", point); // Custom debug output
}
```

Output:

```
Point(5, 10)
```

---

**Difference Between `Debug` and `Display`**

|**Feature**|**Debug**|**Display**|
|---|---|---|
|**Purpose**|Developer-facing output|User-facing output|
|**Specifier**|`{:?}`, `{:#?}`|`{}`|
|**Default Output**|Structural details of a type|Simplified, user-friendly text|

---

**Debugging Nested Structs**

When a struct contains other structs, all nested structs must also implement `Debug` to derive `Debug` for the parent struct.

```rust
#[derive(Debug)]
struct Circle {
    radius: f64,
}

#[derive(Debug)]
struct Shape {
    name: String,
    circle: Circle,
}

fn main() {
    let shape = Shape {
        name: String::from("Circle"),
        circle: Circle { radius: 10.0 },
    };
    println!("{:?}", shape);
}
```

Output:

```
Shape { name: "Circle", circle: Circle { radius: 10.0 } }
```

---

**When to Use `Debug`**

- Debugging and inspecting the state of your program.
- Printing internal representations of structs, enums, or other types.
- Working with tools like `println!`, `format!`, and logging libraries for developer-facing output.

---

**Conclusion**

The `Debug` trait is indispensable when debugging Rust programs. It provides an easy way to inspect the internal structure of types, and deriving it is sufficient in most cases. For custom debug formatting, implement the `Debug` trait manually.

### **`PartialEq`**

The **`PartialEq`** trait in Rust allows for partial equality comparisons between two values. It defines the `==` and `!=` operators and is used to compare if two values are "equal" or "not equal." It is often derived automatically but can also be implemented manually when custom equality logic is required.

---

**Simple Definition**

The **`PartialEq`** trait allows you to compare two values of the same type (or compatible types) for equality (`==`) or inequality (`!=`).

---

**Example**

```rust
#[derive(PartialEq)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p1 = Point { x: 10, y: 20 };
    let p2 = Point { x: 10, y: 20 };
    let p3 = Point { x: 5, y: 10 };

    println!("{}", p1 == p2); // true
    println!("{}", p1 == p3); // false
    println!("{}", p1 != p3); // true
}
```

---

**Features of `PartialEq`**

1. **Equality and Inequality**: Provides `==` and `!=` operators.
2. **Derivable**: Most structs and enums can derive `PartialEq` for default behavior.
3. **Custom Implementations**: Useful for cases where equality isn't based solely on field values.
4. **Reflexive Equality**: For any value `x`, `x == x` should always hold true.

---

**Custom Implementation of `PartialEq`**

When a custom comparison is needed, you can manually implement the `PartialEq` trait:

```rust
struct Circle {
    radius: f64,
}

impl PartialEq for Circle {
    fn eq(&self, other: &Self) -> bool {
        self.radius == other.radius
    }
}

fn main() {
    let c1 = Circle { radius: 10.0 };
    let c2 = Circle { radius: 10.0 };
    let c3 = Circle { radius: 5.0 };

    println!("{}", c1 == c2); // true
    println!("{}", c1 == c3); // false
}
```

---

**Equality for Enums**

Enums can also derive `PartialEq` to allow equality comparisons:

```rust
#[derive(PartialEq)]
enum Color {
    Red,
    Green,
    Blue,
}

fn main() {
    let c1 = Color::Red;
    let c2 = Color::Green;

    println!("{}", c1 == c2); // false
    println!("{}", c1 != c2); // true
}
```

---

**Partial Equality**

The `PartialEq` trait does not guarantee a total ordering of values (unlike `Ord`). For example, `f32` and `f64` implement `PartialEq` but cannot implement `Eq` because of the special `NaN` value:

```rust
fn main() {
    let a = 0.0 / 0.0; // NaN
    println!("{}", a == a); // false (NaN is not equal to itself)
}
```

---

**PartialEq with References**

`PartialEq` works seamlessly with references:

```rust
fn main() {
    let s1 = String::from("hello");
    let s2 = String::from("hello");

    // Compare owned values
    println!("{}", s1 == s2); // true

    // Compare references
    println!("{}", &s1 == &s2); // true
}
```

---

**Usage with Generics**

`PartialEq` can be used in generic functions and structs:

```rust
fn are_equal<T: PartialEq>(a: T, b: T) -> bool {
    a == b
}

fn main() {
    let x = 5;
    let y = 5;
    println!("{}", are_equal(x, y)); // true
}
```

---

**PartialEq with Different Types**

Sometimes, `PartialEq` can be implemented to compare different types:

```rust
struct Inches(u32);
struct Centimeters(u32);

impl PartialEq<Centimeters> for Inches {
    fn eq(&self, other: &Centimeters) -> bool {
        self.0 * 2.54 as u32 == other.0
    }
}

fn main() {
    let inches = Inches(10);
    let cm = Centimeters(25);

    println!("{}", inches == cm); // true
}
```

---

**When to Use `PartialEq`**

- To compare values for equality (`==`) or inequality (`!=`).
- To implement custom logic for equality comparisons.
- To make types compatible with Rust's equality-based APIs like `assert_eq!`.

---

**Conclusion**

The `PartialEq` trait is a fundamental trait in Rust that provides equality and inequality comparison functionality. It is versatile, supports derivation, and can be customized for specific comparison needs.

---


### **`Eq`**

The **`Eq`** trait in Rust is a marker trait that signifies a type provides _reflexive equality_. It is a stricter version of the `PartialEq` trait, ensuring that all values of a type are equal to themselves (i.e., `x == x` is always true). This trait is only implemented for types where equality is well-defined and consistent.

---

**Simple Definition**

The **`Eq`** trait is a marker trait for types that have full equivalence, where all comparisons follow the reflexive property (`x == x` is always true).

---

**Example**

```rust
#[derive(PartialEq, Eq)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p1 = Point { x: 1, y: 2 };
    let p2 = Point { x: 1, y: 2 };
    let p3 = Point { x: 3, y: 4 };

    println!("{}", p1 == p2); // true
    println!("{}", p1 == p3); // false
}
```

---

**Key Features of `Eq`**

1. **Reflexive Equality**: All values of the type must be equal to themselves (`x == x` is true for all `x`).
2. **Marker Trait**: It has no additional methods and only ensures strict equality.
3. **Derivable**: The `Eq` trait can be derived for most types automatically, provided they also implement `PartialEq`.

---

**Deriving `Eq` for Enums**

Enums can also implement `Eq` when their variants are strictly comparable:

```rust
#[derive(PartialEq, Eq)]
enum Color {
    Red,
    Green,
    Blue,
}

fn main() {
    let c1 = Color::Red;
    let c2 = Color::Green;

    println!("{}", c1 == c2); // false
}
```

---

**Custom Implementation of `Eq`**

While `Eq` itself does not require any methods to be implemented, you must implement `PartialEq` alongside it. Here's a custom example:

```rust
struct Circle {
    radius: f64,
}

impl PartialEq for Circle {
    fn eq(&self, other: &Self) -> bool {
        self.radius == other.radius
    }
}

impl Eq for Circle {}

fn main() {
    let c1 = Circle { radius: 10.0 };
    let c2 = Circle { radius: 10.0 };

    println!("{}", c1 == c2); // true
}
```

---

**Relationship Between `PartialEq` and `Eq`**

- `Eq` is a subtrait of `PartialEq`, meaning any type that implements `Eq` must also implement `PartialEq`.
- While `PartialEq` allows for partial equality (e.g., `NaN` in floating-point numbers), `Eq` enforces full equality, making it more restrictive.
- Types like `f32` and `f64` implement `PartialEq` but not `Eq` because `NaN` is not equal to itself.

---

**Reflexive Equality Example**

To meet the requirements of `Eq`, the type must satisfy reflexive equality:

```rust
#[derive(PartialEq, Eq)]
struct User {
    id: u32,
    name: String,
}

fn main() {
    let user = User { id: 1, name: String::from("Alice") };

    // Reflexive property
    println!("{}", user == user); // true
}
```

---

**Common Uses of `Eq`**

- Types that are used as keys in collections like `HashMap` or `HashSet` must implement `Eq` (in addition to `Hash`).
- Strictly comparable types, where equality always holds consistently.

---

**When `Eq` is Not Applicable**

Types that do not have strict equivalence cannot implement `Eq`. For example:

```rust
fn main() {
    let a = 0.0 / 0.0; // NaN
    println!("{}", a == a); // false, so f64 cannot implement `Eq`
}
```

---

**Trait Bound Example**

You can use `Eq` in generic contexts when strict equality is required:

```rust
fn are_equal<T: Eq>(a: T, b: T) -> bool {
    a == b
}

fn main() {
    let x = 5;
    let y = 5;

    println!("{}", are_equal(x, y)); // true
}
```

---

**Conclusion**

The `Eq` trait ensures types have strict equality, where `x == x` always holds true. It is often used alongside `PartialEq`, derived automatically for most types, and is a prerequisite for certain data structures like `HashMap` and `HashSet`.

### **`PartialOrd`**

The **`PartialOrd`** trait in Rust allows you to compare values of a type in an ordered way. It is used for types that support partial ordering, meaning not all values can be compared (e.g., `NaN` in floating-point numbers). It is often used for types where the relationship `<`, `<=`, `>`, or `>=` makes sense but may not apply to all values.

---

**Simple Definition**

The **`PartialOrd`** trait allows you to perform comparisons (like `<`, `>`, `<=`, `>=`) on types with a partial order.

---

**Example**

```rust
#[derive(PartialEq, PartialOrd)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p1 = Point { x: 1, y: 2 };
    let p2 = Point { x: 3, y: 4 };

    println!("{}", p1 < p2);  // true
    println!("{}", p1 <= p2); // true
}
```

---

**Key Features of `PartialOrd`**

1. **Partial Ordering**: Comparisons like `<`, `>`, `<=`, and `>=` are allowed but may not always be valid for all values (e.g., `NaN` in `f32` or `f64`).
2. **Requires `PartialEq`**: Types implementing `PartialOrd` must also implement `PartialEq` since equality is fundamental to comparisons.
3. **Derivable**: The `PartialOrd` trait can be derived automatically for types that already implement `PartialEq`.

---

**Methods Provided by `PartialOrd`**

- **`partial_cmp(&self, other: &Self) -> Option<Ordering>`**: Returns the ordering between two values as `Some(Ordering)` or `None` if the values cannot be compared.

Example:

```rust
use std::cmp::Ordering;

fn compare_points(p1: &Point, p2: &Point) -> Option<Ordering> {
    p1.partial_cmp(p2)
}

#[derive(PartialEq, PartialOrd)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p1 = Point { x: 1, y: 2 };
    let p2 = Point { x: 3, y: 4 };

    if let Some(order) = compare_points(&p1, &p2) {
        println!("{:?}", order); // Less
    }
}
```

---

**Custom Implementation of `PartialOrd`**

You can implement `PartialOrd` for your own types. For example:

```rust
use std::cmp::Ordering;

struct Rectangle {
    width: u32,
    height: u32,
}

impl PartialEq for Rectangle {
    fn eq(&self, other: &Self) -> bool {
        self.width * self.height == other.width * other.height
    }
}

impl PartialOrd for Rectangle {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        (self.width * self.height).partial_cmp(&(other.width * other.height))
    }
}

fn main() {
    let r1 = Rectangle { width: 3, height: 4 }; // Area = 12
    let r2 = Rectangle { width: 2, height: 6 }; // Area = 12
    let r3 = Rectangle { width: 5, height: 5 }; // Area = 25

    println!("{}", r1 == r2); // true
    println!("{}", r1 < r3);  // true
    println!("{}", r3 > r1);  // true
}
```

---

**Relationship Between `Ord` and `PartialOrd`**

- `PartialOrd` is for types with partial ordering, meaning some comparisons may not be valid.
- `Ord` is for types with total ordering, where all values can be compared.

For example:

- `f64` implements `PartialOrd` because `NaN` is not comparable.
- Integer types (e.g., `i32`) implement `Ord` because all values can be compared.

---

**Trait Bound Example**

You can use `PartialOrd` in generic functions to compare values:

```rust
fn max<T: PartialOrd>(a: T, b: T) -> T {
    if a > b {
        a
    } else {
        b
    }
}

fn main() {
    let x = 10;
    let y = 20;

    println!("Max: {}", max(x, y)); // Max: 20
}
```

---

**Floating-Point Limitations**

Due to the nature of floating-point numbers, `f32` and `f64` implement `PartialOrd` but not `Ord`:

```rust
fn main() {
    let a = 0.0 / 0.0; // NaN
    let b = 1.0;

    println!("{}", a < b);  // false
    println!("{}", a > b);  // false
    println!("{}", a == a); // false
}
```

---

**Common Use Cases**

- Comparing custom types like structs or enums where ordering is meaningful.
- Using floating-point numbers (`f32`, `f64`) that may contain `NaN` values.
- Sorting algorithms or conditional logic involving types with partial ordering.

---

**Conclusion**

The `PartialOrd` trait allows types to be partially compared using `<`, `>`, `<=`, and `>=`. It is ideal for types where some values cannot be compared (e.g., `NaN`). For total ordering, use the stricter `Ord` trait instead.

---

### **`Ord`**

The **`Ord`** trait in Rust allows you to define a **total ordering** for a type. Unlike **`PartialOrd`**, which supports partial ordering, the **`Ord`** trait ensures that every pair of values can be compared, and all comparisons (`<`, `>`, `<=`, `>=`) always return a valid result.

**Simple Definition**

The **`Ord`** trait is used to define a type that can be totally ordered, meaning all values of the type can be compared.

**Example**

```rust
use std::cmp::Ordering;

#[derive(Eq, PartialEq, Ord, PartialOrd)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p1 = Point { x: 1, y: 2 };
    let p2 = Point { x: 3, y: 4 };

    println!("{}", p1 < p2);  // true
    println!("{}", p1 <= p2); // true
}
```

**Key Features of `Ord`**

1. **Total Ordering**: Every value can be compared with every other value of the same type.
2. **Requires `PartialOrd`**: Types implementing `Ord` must also implement `PartialOrd` and `PartialEq`.
3. **Derivable**: The `Ord` trait can often be derived automatically for simple types.

**Methods Provided by `Ord`**

- **`cmp(&self, other: &Self) -> Ordering`**: Compares two values and returns one of `Ordering::Less`, `Ordering::Equal`, or `Ordering::Greater`.

**Custom Implementation of `Ord`**

You can implement `Ord` manually for custom types by defining the `cmp` method. For example:

```rust
use std::cmp::Ordering;

#[derive(Eq, PartialEq)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Ord for Rectangle {
    fn cmp(&self, other: &Self) -> Ordering {
        (self.width * self.height).cmp(&(other.width * other.height))
    }
}

impl PartialOrd for Rectangle {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

fn main() {
    let r1 = Rectangle { width: 3, height: 4 }; // Area = 12
    let r2 = Rectangle { width: 5, height: 5 }; // Area = 25

    println!("{}", r1 < r2);  // true
    println!("{}", r1 > r2);  // false
}
```

**Relationship Between `Ord` and `PartialOrd`**

- **`Ord`** is for total ordering, meaning **all** values can be compared.
- **`PartialOrd`** is for partial ordering, where some values might not be comparable (e.g., `NaN`).

For example:

- Integers like `i32` implement `Ord` because all integers are comparable.
- Floating-point types like `f32` implement `PartialOrd` but not `Ord`, because `NaN` is not comparable.

**Deriving `Ord`**

If your type derives `Ord`, Rust will compare values lexicographically (like comparing strings alphabetically), using the order in which the fields are defined.

```rust
#[derive(Eq, PartialEq, Ord, PartialOrd)]
struct Person {
    age: u32,
    name: String,
}

fn main() {
    let p1 = Person { age: 30, name: String::from("Alice") };
    let p2 = Person { age: 25, name: String::from("Bob") };

    println!("{}", p1 > p2); // true, because age is compared first
}
```

**Trait Bound Example**

The `Ord` trait is often used in generic functions or data structures like `BTreeMap` or `BTreeSet`, which require total ordering.

```rust
fn max<T: Ord>(a: T, b: T) -> T {
    if a > b {
        a
    } else {
        b
    }
}

fn main() {
    let x = 10;
    let y = 20;

    println!("Max: {}", max(x, y)); // Max: 20
}
```

**Common Use Cases**

1. Sorting data using **`sort`** or **`sort_by`**:
    
    ```rust
    let mut numbers = vec![3, 1, 4, 1, 5];
    numbers.sort(); // Automatically uses `Ord`
    println!("{:?}", numbers); // [1, 1, 3, 4, 5]
    ```
    
2. Using data structures like **`BTreeMap`** or **`BTreeSet`**:
    
    ```rust
    use std::collections::BTreeSet;
    
    let mut set = BTreeSet::new();
    set.insert(3);
    set.insert(1);
    set.insert(4);
    
    for val in set {
        println!("{}", val);
    }
    // Output: 1, 3, 4 (sorted order)
    ```
    

**Conclusion**

The `Ord` trait is essential for types requiring total ordering, where all values can be compared. It works seamlessly with sorting functions and ordered collections like `BTreeMap`. When total ordering isn't guaranteed (e.g., with floating-point numbers), use `PartialOrd` instead.

---

### **`Default`**

The **Default** trait in Rust provides a way to create default values for types. This is particularly useful when you want to initialize a struct or other type with sensible defaults while still allowing custom initialization.

**Definition**  
The **Default** trait is defined in the standard library as follows:

```rust
pub trait Default {
    fn default() -> Self;
}
```

**Purpose**  
The **Default** trait is used to create default values for types. It is commonly implemented for types where a reasonable "zero" or "empty" state exists.

**Usage**  
To use the **Default** trait, a type must implement it. For example:

```rust
#[derive(Default)]
struct MyStruct {
    a: i32,
    b: String,
}

fn main() {
    let default_value = MyStruct::default();
    println!("a: {}, b: {}", default_value.a, default_value.b);
}
```

In this example:

- The `a` field defaults to `0`.
- The `b` field defaults to an empty string (`""`).

**Custom Implementation**  
You can provide a custom implementation of **Default** for your types:

```rust
struct MyStruct {
    a: i32,
    b: String,
}

impl Default for MyStruct {
    fn default() -> Self {
        MyStruct {
            a: 42,
            b: "Hello".to_string(),
        }
    }
}

fn main() {
    let custom_default = MyStruct::default();
    println!("a: {}, b: {}", custom_default.a, custom_default.b);
}
```

**Common Types with Default Implementations**

- Primitive types like integers and booleans.
- Collections like `Vec` and `HashMap`.
- Option types like `Option` and `Result`.

**Benefits**

- Simplifies initialization of types with sensible defaults.
- Enables the use of macros like `#[derive(Default)]` for automatic implementation.

### **`Hash`**

The **`Hash`** trait in Rust is used for hashing a value. It enables a type to be hashed, which is essential for storing and retrieving values in hash-based collections like **`HashMap`** and **`HashSet`**.

---

**Simple Definition**

The **`Hash`** trait allows you to provide a hashing implementation for a type, enabling it to be used in collections requiring hashing.

---

**Example**

```rust
use std::collections::HashSet;

#[derive(Hash, Eq, PartialEq, Debug)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let mut points = HashSet::new();
    points.insert(Point { x: 1, y: 2 });
    points.insert(Point { x: 3, y: 4 });

    for point in &points {
        println!("{:?}", point);
    }
}
```

---

**Key Features of `Hash`**

1. **Used in Hash-Based Collections**: The **`Hash`** trait is required for types stored in **`HashMap`** or **`HashSet`**.
2. **Requires `Eq`**: Types implementing **`Hash`** must also implement **`Eq`** to ensure consistent behavior in hash-based collections.
3. **Derivable**: You can derive the **`Hash`** trait for many simple types, as long as their fields also implement **`Hash`**.

---

**How `Hash` Works**

The **`Hash`** trait defines the **`hash`** method, which takes a mutable reference to a `Hasher`. The implementation adds the value to the hash by writing bytes to the `Hasher`.

```rust
use std::hash::{Hash, Hasher};

struct Person {
    name: String,
    age: u8,
}

impl Hash for Person {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.name.hash(state); // Hash the name
        self.age.hash(state);  // Hash the age
    }
}
```

---

**Custom Hash Implementation Example**

You can manually implement the `Hash` trait to define custom hashing logic:

```rust
use std::hash::{Hash, Hasher};

struct Book {
    title: String,
    pages: u32,
}

impl Hash for Book {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.title.hash(state); // Only hash the title
    }
}

impl PartialEq for Book {
    fn eq(&self, other: &Self) -> bool {
        self.title == other.title // Equality based on title
    }
}

impl Eq for Book {}

fn main() {
    use std::collections::HashSet;

    let mut books = HashSet::new();
    books.insert(Book { title: String::from("The Rust Book"), pages: 500 });
    books.insert(Book { title: String::from("The Rust Book"), pages: 600 }); // Duplicate based on title

    println!("Number of unique books: {}", books.len()); // Output: 1
}
```

---

**Hashing with `HashMap`**

You can use any type that implements **`Hash`** as a key in a `HashMap`:

```rust
use std::collections::HashMap;

#[derive(Hash, Eq, PartialEq)]
struct Employee {
    id: u32,
    name: String,
}

fn main() {
    let mut employee_salaries = HashMap::new();

    employee_salaries.insert(
        Employee { id: 1, name: String::from("Alice") },
        5000,
    );
    employee_salaries.insert(
        Employee { id: 2, name: String::from("Bob") },
        6000,
    );

    for (employee, salary) in &employee_salaries {
        println!("{} earns {}", employee.name, salary);
    }
}
```

---

**Trait Bound Example**

The `Hash` trait is often used in generic functions requiring hashing:

```rust
use std::collections::HashSet;
use std::hash::Hash;

fn print_unique_elements<T: Eq + Hash>(elements: Vec<T>) {
    let unique: HashSet<_> = elements.into_iter().collect();
    for element in &unique {
        println!("{:?}", element);
    }
}

fn main() {
    let nums = vec![1, 2, 2, 3, 4, 4];
    print_unique_elements(nums); // Prints: 1, 2, 3, 4
}
```

---

**Hash Collisions**

Even though two different values might hash to the same value (a **collision**), the **`Eq`** trait ensures correctness by comparing the values for equality when a collision occurs.

---

**Common Use Cases**

1. **HashMap Keys**: Storing data in a `HashMap` where efficient lookup is needed.
    
    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert("key1", "value1");
    map.insert("key2", "value2");
    println!("{:?}", map.get("key1")); // Some("value1")
    ```
    
2. **HashSet Values**: Storing unique values in a `HashSet`.
    
    ```rust
    use std::collections::HashSet;
    
    let mut set = HashSet::new();
    set.insert(1);
    set.insert(2);
    set.insert(2); // Duplicate, will not be added
    println!("{:?}", set); // {1, 2}
    ```
    
3. **Custom Types**: Making your custom types compatible with hash-based collections.
    

---

**Conclusion**

The `Hash` trait is crucial for hashing values in Rust, enabling their use in collections like `HashMap` and `HashSet`. It works alongside the `Eq` trait to ensure consistent behavior, and its functionality can be customized or derived for specific use cases. Always ensure that types implementing `Hash` also implement `Eq` for proper functionality.

**Examples of Combining Derived Traits**

You can derive multiple traits for a struct or enum at once:

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let point1 = Point { x: 5, y: 10 };
    let point2 = point1.clone();

    println!("{:?}", point1);  // Debug output
    println!("{}", point1 == point2);  // PartialEq and Eq usage
}
```

### **`Serialize`**

The **Serialize** trait in Rust is provided by the `serde` crate, a popular framework for serializing and deserializing data. Serialization is the process of converting data structures into a format that can be stored or transmitted, such as JSON, YAML, or binary formats.

**Definition**  
The **Serialize** trait is defined as part of the `serde::ser` module:

```rust
pub trait Serialize {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer;
}
```

**Purpose**  
The **Serialize** trait is implemented for types that you want to convert into serialized data formats. This is typically paired with the **Deserialize** trait for bidirectional data handling.

**Usage**  
To enable serialization for your custom types, you can use the `#[derive(Serialize)]` macro provided by `serde`:

```rust
use serde::Serialize;

#[derive(Serialize)]
struct MyStruct {
    id: u32,
    name: String,
}

fn main() {
    let my_struct = MyStruct {
        id: 1,
        name: "Example".to_string(),
    };
    
    let json = serde_json::to_string(&my_struct).unwrap();
    println!("{}", json); // Output: {"id":1,"name":"Example"}
}
```

**Custom Implementation**  
In cases where the default implementation provided by `#[derive(Serialize)]` is insufficient, you can manually implement the **Serialize** trait:

```rust
use serde::ser::{Serialize, Serializer, SerializeStruct};

struct MyStruct {
    id: u32,
    name: String,
}

impl Serialize for MyStruct {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        let mut state = serializer.serialize_struct("MyStruct", 2)?;
        state.serialize_field("id", &self.id)?;
        state.serialize_field("name", &self.name)?;
        state.end()
    }
}

fn main() {
    let my_struct = MyStruct {
        id: 42,
        name: "Custom".to_string(),
    };
    let json = serde_json::to_string(&my_struct).unwrap();
    println!("{}", json); // Output: {"id":42,"name":"Custom"}
}
```

**Common Use Cases**

1. **JSON Serialization**: Using `serde_json` to serialize data into JSON.
2. **Binary Formats**: Serializing data into compact binary formats.
3. **Configuration Files**: Storing structured data in formats like TOML, YAML, or JSON.

**Features of `serde`**

- **Performance**: Efficient serialization and deserialization.
- **Flexibility**: Support for multiple data formats.
- **Integration**: Works with custom types using macros or manual implementations.

### **`Deserialize`**

The **Deserialize** trait in Rust is part of the `serde` crate and facilitates converting serialized data back into Rust data structures. This process is known as deserialization.

---

**Definition**  
The **Deserialize** trait is defined in the `serde::de` module:

```rust
pub trait Deserialize<'de>: Sized {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>;
}
```

---

**Purpose**  
The **Deserialize** trait allows types to be constructed from serialized data. It complements the **Serialize** trait, enabling bidirectional data transformation between Rust types and external formats.

---

**Usage**  
To deserialize a type, you can use the `#[derive(Deserialize)]` macro provided by `serde`:

```rust
use serde::Deserialize;

#[derive(Deserialize)]
struct MyStruct {
    id: u32,
    name: String,
}

fn main() {
    let json_data = r#"{"id":1,"name":"Example"}"#;
    let my_struct: MyStruct = serde_json::from_str(json_data).unwrap();
    println!("id: {}, name: {}", my_struct.id, my_struct.name);
}
```

---

**Custom Implementation**  
In some cases, you may need to manually implement the **Deserialize** trait for more control over how data is deserialized:

```rust
use serde::de::{self, Deserializer, Visitor, MapAccess};
use std::fmt;

struct MyStruct {
    id: u32,
    name: String,
}

impl<'de> Deserialize<'de> for MyStruct {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        struct MyStructVisitor;

        impl<'de> Visitor<'de> for MyStructVisitor {
            type Value = MyStruct;

            fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
                formatter.write_str("a struct with fields 'id' and 'name'")
            }

            fn visit_map<V>(self, mut map: V) -> Result<Self::Value, V::Error>
            where
                V: MapAccess<'de>,
            {
                let mut id = None;
                let mut name = None;

                while let Some(key) = map.next_key::<String>()? {
                    match key.as_str() {
                        "id" => id = Some(map.next_value()?),
                        "name" => name = Some(map.next_value()?),
                        _ => return Err(de::Error::unknown_field(&key, &["id", "name"])),
                    }
                }

                let id = id.ok_or_else(|| de::Error::missing_field("id"))?;
                let name = name.ok_or_else(|| de::Error::missing_field("name"))?;
                Ok(MyStruct { id, name })
            }
        }

        deserializer.deserialize_struct("MyStruct", &["id", "name"], MyStructVisitor)
    }
}

fn main() {
    let json_data = r#"{"id":42,"name":"Custom"}"#;
    let my_struct: MyStruct = serde_json::from_str(json_data).unwrap();
    println!("id: {}, name: {}", my_struct.id, my_struct.name);
}
```

---

**Common Use Cases**

1. **Parsing JSON**: Convert JSON strings into Rust types using `serde_json`.
2. **Configuration Parsing**: Load structured configuration data from YAML, TOML, or other formats.
3. **Network Protocols**: Deserialize data received over the network.

---

**Features of `serde`**

- **Derive Macros**: Simplifies implementing **Deserialize** for most types.
- **Custom Implementations**: Allows fine-grained control over deserialization.
- **Error Handling**: Provides detailed error messages when deserialization fails.

Would you like an example with another format, such as YAML or TOML?

### **`Iterator`**

The **`Iterator`** trait in Rust provides a way to iterate over a sequence of elements. It is central to Rust's iterator system and defines the behavior of iterators.

---

**Simple Definition**

The **`Iterator`** trait allows types to yield a series of values, one at a time, through its **`next`** method.

---

**Key Methods in the `Iterator` Trait**

1. **`next()`**: Advances the iterator and returns the next element (or `None` when the iteration ends).
    
    ```rust
    let vec = vec![1, 2, 3];
    let mut iter = vec.iter();
    
    assert_eq!(iter.next(), Some(&1));
    assert_eq!(iter.next(), Some(&2));
    assert_eq!(iter.next(), Some(&3));
    assert_eq!(iter.next(), None);
    ```
    
2. **`size_hint()`**: Returns an estimate of the number of elements remaining in the iterator.
    
    ```rust
    let vec = vec![1, 2, 3];
    let iter = vec.iter();
    
    assert_eq!(iter.size_hint(), (3, Some(3)));
    ```
    
3. **`count()`**: Consumes the iterator and returns the number of elements.
    
    ```rust
    let vec = vec![1, 2, 3];
    let iter = vec.iter();
    
    assert_eq!(iter.count(), 3);
    ```
    
4. **`last()`**: Consumes the iterator and returns the last element.
    
    ```rust
    let vec = vec![1, 2, 3];
    let iter = vec.iter();
    
    assert_eq!(iter.last(), Some(&3));
    ```
    
5. **`nth(n)`**: Returns the nth element (0-based index) from the iterator.
    
    ```rust
    let vec = vec![1, 2, 3];
    let mut iter = vec.iter();
    
    assert_eq!(iter.nth(1), Some(&2)); // Skips the first element
    ```
    
6. **`chain()`**: Combines two iterators into a single iterator.
    
    ```rust
    let a = vec![1, 2];
    let b = vec![3, 4];
    let iter = a.iter().chain(b.iter());
    
    for val in iter {
        println!("{}", val); // Prints 1, 2, 3, 4
    }
    ```
    
7. **`zip()`**: Combines two iterators into pairs.
    
    ```rust
    let a = vec![1, 2];
    let b = vec![3, 4];
    let iter = a.iter().zip(b.iter());
    
    for (x, y) in iter {
        println!("({}, {})", x, y); // Prints (1, 3), (2, 4)
    }
    ```
    
8. **`rev()`**: Reverses the direction of the iterator.
    
    ```rust
    let vec = vec![1, 2, 3];
    let iter = vec.iter().rev();
    
    for val in iter {
        println!("{}", val); // Prints 3, 2, 1
    }
    ```
    

---

**Implementing the `Iterator` Trait**

You can create custom iterators by implementing the **`Iterator`** trait. Here's an example:

```rust
struct Counter {
    count: u32,
}

impl Counter {
    fn new() -> Counter {
        Counter { count: 0 }
    }
}

impl Iterator for Counter {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        self.count += 1;
        if self.count <= 5 {
            Some(self.count)
        } else {
            None
        }
    }
}

fn main() {
    let mut counter = Counter::new();

    while let Some(num) = counter.next() {
        println!("{}", num); // Prints 1, 2, 3, 4, 5
    }
}
```

---

**Traits Often Used with Iterators**

- **`IntoIterator`**: Automatically converts a collection into an iterator.
    
    ```rust
    let vec = vec![1, 2, 3];
    for val in vec {
        println!("{}", val); // Prints 1, 2, 3
    }
    ```
    
- **`DoubleEndedIterator`**: Allows iterating from both ends.
    
    ```rust
    let vec = vec![1, 2, 3];
    let mut iter = vec.iter();
    
    assert_eq!(iter.next(), Some(&1));
    assert_eq!(iter.next_back(), Some(&3));
    ```
    

---

**Common Use Cases**

1. **Chaining Iterators**
    
    ```rust
    let vec = vec![1, 2, 3];
    let result: Vec<_> = vec.iter().map(|x| x * 2).collect();
    assert_eq!(result, vec![2, 4, 6]);
    ```
    
2. **Filtering Values**
    
    ```rust
    let vec = vec![1, 2, 3, 4];
    let result: Vec<_> = vec.into_iter().filter(|&x| x % 2 == 0).collect();
    assert_eq!(result, vec![2, 4]);
    ```
    
3. **Combining Iterators**
    
    ```rust
    let a = vec![1, 2];
    let b = vec![3, 4];
    let result: Vec<_> = a.into_iter().chain(b.into_iter()).collect();
    assert_eq!(result, vec![1, 2, 3, 4]);
    ```
    

---

**Conclusion**

The **`Iterator`** trait is fundamental in Rust for processing sequences of elements. It provides powerful methods for iteration, transformation, and collection, making it an essential tool for functional programming and working with collections. You can also implement it for custom types, tailoring its behavior to specific needs.

### **`FusedIterator`**

The **`FusedIterator`** trait is used to optimize iterators by ensuring that calling **`next()`** repeatedly after the iterator has returned `None` will always return `None`. This is useful for iterators that are guaranteed to behave predictably after completion.

---

**Simple Definition**

A **`FusedIterator`** is an iterator that, once it has returned `None`, will continue to return `None` on subsequent calls to **`next()`**.

---

**Key Points**

1. **Purpose**: Helps optimize iterator chains by preventing redundant checks for `None`.
2. **Use Case**: Particularly useful when working with combinator methods like `chain` or `zip`, which rely on predictable behavior of their underlying iterators.
3. **Optional Implementation**: You don't typically need to implement this trait manually, as most standard library iterators already implement it when appropriate.

---

**Example of a Fused Iterator**

Most iterators in the standard library automatically implement **`FusedIterator`**, including those for slices and ranges. Here's an example:

```rust
use std::iter::FusedIterator;

let mut iter = vec![1, 2, 3].into_iter();

// Iterate until the end.
assert_eq!(iter.next(), Some(1));
assert_eq!(iter.next(), Some(2));
assert_eq!(iter.next(), Some(3));
assert_eq!(iter.next(), None);

// After returning `None`, it will continue to return `None`:
assert_eq!(iter.next(), None);
assert_eq!(iter.next(), None);
```

---

**Manual Implementation of FusedIterator**

While it's uncommon to implement **`FusedIterator`** manually, you might do so for custom iterator types. Here's an example:

```rust
use std::iter::FusedIterator;

struct Counter {
    count: usize,
    max: usize,
}

impl Counter {
    fn new(max: usize) -> Counter {
        Counter { count: 0, max }
    }
}

impl Iterator for Counter {
    type Item = usize;

    fn next(&mut self) -> Option<Self::Item> {
        if self.count < self.max {
            self.count += 1;
            Some(self.count)
        } else {
            None
        }
    }
}

impl FusedIterator for Counter {}

fn main() {
    let mut counter = Counter::new(3);

    assert_eq!(counter.next(), Some(1));
    assert_eq!(counter.next(), Some(2));
    assert_eq!(counter.next(), Some(3));
    assert_eq!(counter.next(), None);
    assert_eq!(counter.next(), None); // Will keep returning `None`
}
```

---

**Practical Use in Iterator Chains**

When combinator methods are applied to iterators, the **`FusedIterator`** trait can help streamline behavior. For example:

```rust
use std::iter::FusedIterator;

fn is_fused<I: FusedIterator>(_: I) {}

let iter = vec![1, 2, 3].into_iter();

// Most standard iterators implement `FusedIterator`.
is_fused(iter);
```

---

**Conclusion**

The **`FusedIterator`** trait ensures that an iterator behaves predictably after completion. While it is not frequently used directly, it plays a critical role in ensuring efficient and consistent behavior for complex iterator chains in Rust. Most standard iterators in Rust already implement this trait, so it is generally handled automatically.

### **`Drop`**

The `Drop` trait in Rust provides a way to run custom code when a value goes out of scope. It's typically used for releasing resources like memory, file handles, or network connections. Every type in Rust can implement the `Drop` trait to define cleanup logic.

**Simple definition**

The `Drop` trait allows you to specify what happens when an object is dropped (i.e., goes out of scope).

**Example: Cleaning up a resource**

```rust
struct Resource {
    name: String,
}

impl Drop for Resource {
    fn drop(&mut self) {
        println!("Dropping resource: {}", self.name);
    }
}

fn main() {
    let resource = Resource {
        name: String::from("MyResource"),
    };
    // The `drop` method is automatically called here when `resource` goes out of scope.
    println!("Resource created.");
}
```

**Output**

```
Resource created.
Dropping resource: MyResource
```

**Example: Manually calling drop**

```rust
use std::mem;

struct Resource;

impl Drop for Resource {
    fn drop(&mut self) {
        println!("Resource dropped!");
    }
}

fn main() {
    let resource = Resource;
    println!("About to manually drop the resource.");
    mem::drop(resource); // Manually calls the drop method
    println!("Resource manually dropped.");
}
```

**Output**

```
About to manually drop the resource.
Resource dropped!
Resource manually dropped.
```

**Important Notes**

1. **Automatic Drop**: The `drop` method is automatically called when the value goes out of scope. You don't usually need to call it manually.
2. **Ownership Rules**: The `Drop` trait prevents values from being copied accidentally because types implementing `Drop` are not `Copy`.
3. **Double Drop Not Allowed**: Rust prevents you from accidentally calling `drop` twice on the same value to avoid undefined behavior.
4. **RAII Principle**: The `Drop` trait in Rust aligns with the RAII (Resource Acquisition Is Initialization) pattern, ensuring resources are cleaned up automatically when they are no longer needed.

### **`From`**

The `From` trait is used for value-to-value conversions. It provides a simple and consistent mechanism to convert one type into another.

**Simple definition**

The `From` trait allows for straightforward conversions between types. If `T: From<U>`, then you can convert a `U` into a `T` using `T::from(u)`.

**Example with integers**

```rust
let num: i32 = i32::from(10u8); // Convert u8 to i32
println!("{}", num); // 10
```

**Example with String and &str**

```rust
let s: String = String::from("hello"); // Convert &str to String
println!("{}", s); // hello
```

**Using From with custom types**

```rust
struct Point {
    x: i32,
    y: i32,
}

impl From<(i32, i32)> for Point {
    fn from(coords: (i32, i32)) -> Self {
        Point { x: coords.0, y: coords.1 }
    }
}

let point: Point = Point::from((10, 20));
println!("({}, {})", point.x, point.y); // (10, 20)
```

### **`Into`**

The `Into` trait is used for value-to-value conversions, similar to the `From` trait. If a type implements `From<T>`, it automatically implements `Into<T>` as well. The `Into` trait allows for consuming a value and converting it into another type.

**Simple definition**

The `Into` trait is used to convert a value of one type into another type by calling `.into()`.

**Example with integers**

```rust
let num: i32 = 10u8.into(); // Convert u8 to i32
println!("{}", num); // 10
```

**Example with String and &str**

```rust
let s: String = "hello".into(); // Convert &str to String
println!("{}", s); // hello
```

**Using Into with custom types**

```rust
struct Point {
    x: i32,
    y: i32,
}

impl From<(i32, i32)> for Point {
    fn from(coords: (i32, i32)) -> Self {
        Point { x: coords.0, y: coords.1 }
    }
}

let point: Point = (10, 20).into(); // Automatically uses From implementation
println!("({}, {})", point.x, point.y); // (10, 20)
```

**Key Difference Between From and Into**

- `From` is implemented to define the conversion logic.
- `Into` is automatically implemented for types that implement `From`. Therefore, `Into` is primarily used for convenience when you already have a `From` implementation.

### **`AsRef`**

The **AsRef** trait in Rust is a standard library trait that provides a way to convert a type into a reference of another type. It's a lightweight and efficient way to allow types to act as references to another type without consuming ownership.

---

**Definition**  
The **AsRef** trait is defined in the Rust standard library as follows:

```rust
pub trait AsRef<T: ?Sized> {
    fn as_ref(&self) -> &T;
}
```

---

**Purpose**  
The **AsRef** trait is used to borrow data as a reference to another type. It is often implemented for converting between types with similar representations or for borrowing data from owned types.

---

**Usage**  
The **AsRef** trait is commonly used in generic programming and in standard library functions. Here's a basic example:

```rust
fn print_length<T: AsRef<str>>(s: T) {
    let string_ref: &str = s.as_ref();
    println!("Length: {}", string_ref.len());
}

fn main() {
    let s1 = String::from("Hello");
    let s2 = "World";

    print_length(s1); // Works with String
    print_length(s2); // Works with &str
}
```

In this example:

- `print_length` is generic over any type that implements `AsRef<str>`.
- Both `String` and `&str` implement `AsRef<str>`, so they can be passed to the function.

---

**Custom Implementation**  
You can implement **AsRef** for your own types to enable similar conversions:

```rust
struct MyStruct {
    data: String,
}

impl AsRef<str> for MyStruct {
    fn as_ref(&self) -> &str {
        &self.data
    }
}

fn main() {
    let my_struct = MyStruct {
        data: "Hello, Rust!".to_string(),
    };

    let string_ref: &str = my_struct.as_ref();
    println!("{}", string_ref); // Output: Hello, Rust!
}
```

---

**Common Implementations**  
The Rust standard library provides many implementations of **AsRef**, such as:

- `AsRef<str>` for `String` and `&str`
- `AsRef<Path>` for `PathBuf` and `Path`
- `AsRef<[u8]>` for `Vec<u8>` and `[u8]`

---

**Benefits**

1. **Generic Code**: Simplifies writing functions that work with multiple types of references.
2. **Zero-Cost Abstraction**: Provides efficient conversion with no runtime overhead.
3. **Flexibility**: Allows seamless interoperation between owned and borrowed types.

---

**Comparison with Borrow**  
While **AsRef** and **Borrow** are similar, **AsRef** is more general and is used for type conversion, whereas **Borrow** is used for retrieving a canonical reference, often for hash maps or sets.

### **`AsMut`**

The **AsMut** trait in Rust is a standard library trait that provides a way to convert a type into a mutable reference of another type. It is analogous to the **AsRef** trait but is used when mutability is required.

---

**Definition**  
The **AsMut** trait is defined in the Rust standard library as follows:

```rust
pub trait AsMut<T: ?Sized> {
    fn as_mut(&mut self) -> &mut T;
}
```

---

**Purpose**  
The **AsMut** trait is used to borrow a mutable reference to another type. This is particularly useful for enabling in-place modifications of data while retaining ownership of the original type.

---

**Usage**  
The **AsMut** trait is commonly used in generic programming and in functions that need to modify borrowed data. Here's an example:

```rust
fn increment<T: AsMut<i32>>(mut value: T) {
    *value.as_mut() += 1;
}

fn main() {
    let mut x = 10;
    increment(&mut x); // Borrowing mutable reference
    println!("{}", x); // Output: 11
}
```

In this example:

- The `increment` function is generic over any type that implements `AsMut<i32>`.
- A mutable reference (`&mut x`) is passed to the function, allowing it to modify `x`.

---

**Custom Implementation**  
You can implement **AsMut** for your own types to enable similar functionality:

```rust
struct MyStruct {
    data: i32,
}

impl AsMut<i32> for MyStruct {
    fn as_mut(&mut self) -> &mut i32 {
        &mut self.data
    }
}

fn main() {
    let mut my_struct = MyStruct { data: 42 };
    *my_struct.as_mut() += 1;
    println!("{}", my_struct.data); // Output: 43
}
```

---

**Common Implementations**  
The Rust standard library provides several **AsMut** implementations, including:

- `AsMut<[T]>` for `Vec<T>` and slices (`&mut [T]`)
- `AsMut<str>` for `String` and mutable string slices (`&mut str`)

---

**Benefits**

1. **Generic Mutability**: Simplifies writing functions that work with multiple types supporting mutable references.
2. **Zero-Cost Abstraction**: Provides efficient conversions with no runtime overhead.
3. **Flexibility**: Allows types to expose mutable access to their inner data.

---

**Comparison with AsRef**

- **AsMut** works with mutable references (`&mut`), enabling modification.
- **AsRef** works with immutable references (`&`), used only for reading.

---

**Example: Generic Mutability**  
Here's an example of a function that modifies different types using **AsMut**:

```rust
fn double_value<T: AsMut<i32>>(mut value: T) {
    *value.as_mut() *= 2;
}

fn main() {
    let mut x = 10;
    double_value(&mut x);
    println!("{}", x); // Output: 20

    let mut y = Box::new(15);
    double_value(&mut y);
    println!("{}", y); // Output: 30
}
```

### **`Borrow`**

The **Borrow** trait in Rust is a standard library trait that provides a way to get a reference to an underlying value, typically in a canonical form. It is primarily used in collections like `HashMap` and `BTreeMap` to allow for more flexible key types during lookups.

---

**Definition**  
The **Borrow** trait is defined in the Rust standard library as follows:

```rust
pub trait Borrow<Borrowed: ?Sized> {
    fn borrow(&self) -> &Borrowed;
}
```

---

**Purpose**  
The **Borrow** trait is used to abstract over borrowing a value in a canonical form. This allows efficient lookups in collections without requiring the exact same key type as the one used for storage.

---

**Usage**  
The **Borrow** trait is often used in generic collections to allow lookups by different but equivalent types. Here's an example:

```rust
use std::collections::HashMap;
use std::borrow::Borrow;

fn main() {
    let mut map: HashMap<String, i32> = HashMap::new();
    map.insert("key".to_string(), 42);

    let value = map.get("key"); // Using &str to lookup instead of String
    println!("{:?}", value); // Output: Some(42)
}
```

In this example:

- The key type in the `HashMap` is `String`.
- The `Borrow<str>` implementation allows lookups with a `&str` instead of requiring a `String`.

---

**Custom Implementation**  
You can implement **Borrow** for custom types to define how they borrow a canonical representation:

```rust
use std::borrow::Borrow;

struct MyKey {
    key: String,
}

impl Borrow<str> for MyKey {
    fn borrow(&self) -> &str {
        &self.key
    }
}

fn main() {
    let mut map: HashMap<MyKey, i32> = HashMap::new();
    map.insert(MyKey { key: "key".to_string() }, 42);

    let value = map.get("key"); // Using &str for lookup
    println!("{:?}", value); // Output: Some(42)
}
```

---

**Common Implementations**  
The Rust standard library provides several **Borrow** implementations, including:

- `Borrow<str>` for `String` and `&str`
- `Borrow<[T]>` for `Vec<T>` and slices (`&[T]`)
- `Borrow` for custom types that can be referenced in a canonical way.

---

**Comparison with AsRef**

- **Borrow** is typically used for collections to allow flexible lookups using equivalent types (e.g., `String` vs `&str`).
- **AsRef** is a more general trait for converting to a reference, often used for type conversions.

---

**Benefits**

1. **Flexible Lookups**: Enables collections like `HashMap` and `BTreeMap` to support key types different from the stored type but equivalent in value.
2. **Canonical Borrowing**: Provides a standard way to reference a type's canonical representation.
3. **Efficiency**: Avoids unnecessary allocations by allowing lookups with borrowed data.

---

**Example: Flexible Lookup**

```rust
use std::collections::HashMap;

fn main() {
    let mut map: HashMap<String, i32> = HashMap::new();
    map.insert("apple".to_string(), 10);
    map.insert("banana".to_string(), 20);

    // Lookup with &str, even though keys are stored as String
    let key = "apple";
    if let Some(value) = map.get(key) {
        println!("The value for '{}' is {}", key, value);
    } else {
        println!("Key not found");
    }
}
```

### **`BorrowMut`**

The **BorrowMut** trait in Rust is a standard library trait that extends the functionality of **Borrow** by allowing mutable access to the borrowed value. It is useful when you need to modify the canonical representation of a value.

---

**Definition**  
The **BorrowMut** trait is defined in the Rust standard library as follows:

```rust
pub trait BorrowMut<Borrowed: ?Sized> {
    fn borrow_mut(&mut self) -> &mut Borrowed;
}
```

---

**Purpose**  
The **BorrowMut** trait provides a way to borrow a mutable reference to the canonical representation of a type. It is particularly useful for mutating data within collections or types while maintaining ownership.

---

**Usage**  
Here’s a simple example demonstrating how **BorrowMut** works:

```rust
use std::borrow::BorrowMut;

struct MyStruct {
    value: i32,
}

impl BorrowMut<i32> for MyStruct {
    fn borrow_mut(&mut self) -> &mut i32 {
        &mut self.value
    }
}

fn main() {
    let mut my_struct = MyStruct { value: 42 };
    let borrowed_value: &mut i32 = my_struct.borrow_mut();
    *borrowed_value += 1;
    println!("Updated value: {}", my_struct.value); // Output: 43
}
```

In this example:

- `MyStruct` implements **BorrowMut**, allowing its `value` field to be accessed and modified through a mutable reference.

---

**Comparison with Borrow**

- **Borrow** provides immutable access to a canonical representation.
- **BorrowMut** provides mutable access, allowing the borrowed value to be changed.

---

**Common Implementations**  
The Rust standard library provides **BorrowMut** implementations for types such as:

- `Vec<T>` as `BorrowMut<[T]>`: Allows mutable borrowing of the slice within a vector.
- `String` as `BorrowMut<str>`: Allows mutable borrowing of the inner string slice.

---

**Benefits**

1. **Mutable Canonical Borrowing**: Enables modifying a type's canonical representation directly.
2. **Efficiency**: Avoids unnecessary copying or reallocation by working on mutable references.
3. **Compatibility**: Works seamlessly with Rust’s borrowing system for safe concurrent programming.

---

**Example: Using BorrowMut in a Collection**

```rust
use std::collections::HashMap;
use std::borrow::BorrowMut;

fn increment_value<K, V>(map: &mut HashMap<K, V>, key: &K)
where
    K: std::hash::Hash + Eq,
    V: BorrowMut<i32>,
{
    if let Some(value) = map.get_mut(key) {
        *value.borrow_mut() += 1;
    }
}

fn main() {
    let mut map: HashMap<String, Box<i32>> = HashMap::new();
    map.insert("key".to_string(), Box::new(42));

    increment_value(&mut map, &"key".to_string());
    println!("Updated value: {}", map["key"]); // Output: 43
}
```

---

**Key Points**

- **BorrowMut** allows mutable access to a canonical representation, complementing **Borrow**.
- Useful for scenarios involving mutation, particularly in collections or custom types.

### **`Deref`**

The **Deref** trait in Rust is a standard library trait that allows a type to behave like a reference to another type. It is primarily used to enable dereferencing operations (`*`) on custom types, making them act like pointers or references.

---

**Definition**  
The **Deref** trait is defined in the Rust standard library as follows:

```rust
pub trait Deref {
    type Target: ?Sized;

    fn deref(&self) -> &Self::Target;
}
```

- `Self::Target`: The type the custom type dereferences to.
- `deref()`: Returns a reference to the inner value.

---

**Purpose**  
The **Deref** trait is used to implement dereference behavior for smart pointers and other custom types. It allows seamless interaction with underlying data without explicit method calls.

---

**Usage**

Example 1: Basic Deref Implementation

```rust
use std::ops::Deref;

struct MyBox<T>(T);

impl<T> Deref for MyBox<T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

fn main() {
    let x = MyBox(42);
    println!("Value: {}", *x); // Deref allows us to use *x
}
```

In this example:

- `MyBox` is a custom smart pointer.
- Implementing **Deref** allows us to use `*x` to access the inner value (`42`).

---

Example 2: Deref Coercion

**Deref coercion** is a feature of Rust that automatically converts a type implementing **Deref** into its target type in certain contexts, like function calls or method resolution.

```rust
struct MyString(String);

impl Deref for MyString {
    type Target = String;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

fn takes_str(s: &str) {
    println!("String: {}", s);
}

fn main() {
    let my_string = MyString(String::from("Hello, Rust!"));
    takes_str(&my_string); // Deref coercion converts &MyString to &String, then to &str
}
```

In this example:

- **Deref coercion** allows `MyString` to be passed to a function expecting a `&str`.

---

**Custom Implementation**  
You can implement **Deref** for custom types to define their dereferencing behavior:

```rust
use std::ops::Deref;

struct CustomPointer<T> {
    value: T,
}

impl<T> Deref for CustomPointer<T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        &self.value
    }
}

fn main() {
    let p = CustomPointer { value: 100 };
    println!("Value through deref: {}", *p);
}
```

---

**Common Implementations**  
The **Deref** trait is implemented for standard library types like:

- `Box<T>`: Dereferences to `T`.
- `Rc<T>` and `Arc<T>`: Dereference to `T` for reference-counted types.
- `Vec<T>`: Dereferences to `[T]`.

---

**Comparison with Borrow**

- **Deref** is used for dereferencing a custom type into a target type, often in smart pointers.
- **Borrow** is used for providing a canonical reference for use in collections like `HashMap`.

---

**Benefits**

1. **Operator Overloading**: Enables using the `*` operator on custom types.
2. **Convenience**: Simplifies working with smart pointers and custom types by providing seamless access to the inner data.
3. **Deref Coercion**: Reduces boilerplate by allowing automatic conversion in certain contexts.

---

### **`DerefMut`**

The **DerefMut** trait in Rust is the mutable counterpart to the **Deref** trait. It allows a custom type to behave like a mutable reference to another type, enabling dereferencing with `*` for mutable operations.

---

**Definition**  
The **DerefMut** trait is defined in the Rust standard library as follows:

```rust
pub trait DerefMut: Deref {
    fn deref_mut(&mut self) -> &mut Self::Target;
}
```

- **`deref_mut`**: Returns a mutable reference to the inner value.

---

**Purpose**  
The **DerefMut** trait provides mutable dereferencing for custom types. It enables direct modification of the underlying data when accessed through the `*` operator.

---

**Usage**

**Example 1: Implementing DerefMut**

Here is a simple example of a custom smart pointer with **DerefMut**:

```rust
use std::ops::{Deref, DerefMut};

struct MyBox<T>(T);

impl<T> Deref for MyBox<T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl<T> DerefMut for MyBox<T> {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.0
    }
}

fn main() {
    let mut x = MyBox(42);

    // Read access through Deref
    println!("Value: {}", *x);

    // Modify value through DerefMut
    *x += 1;
    println!("Modified Value: {}", *x);
}
```

In this example:

- **Deref** allows immutable access to the inner value.
- **DerefMut** enables mutable access and modification of the inner value using `*`.

---

**Example 2: Using DerefMut in a Function**

```rust
fn increment(value: &mut i32) {
    *value += 1;
}

fn main() {
    let mut x = MyBox(10);

    increment(&mut *x); // DerefMut provides a mutable reference
    println!("Updated Value: {}", *x); // Output: 11
}
```

---

**Interaction with Deref Coercion**

**DerefMut** also participates in **Deref coercion**, allowing types to be automatically converted to mutable references of their target types in specific contexts:

```rust
struct MyString(String);

impl std::ops::Deref for MyString {
    type Target = String;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl std::ops::DerefMut for MyString {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.0
    }
}

fn main() {
    let mut my_string = MyString(String::from("Hello"));
    my_string.push_str(", Rust!"); // DerefMut allows mutable access
    println!("{}", *my_string);    // Output: Hello, Rust!
}
```

---

**Common Implementations**  
The Rust standard library implements **DerefMut** for:

- `Box<T>`: Dereferences to a mutable reference of `T`.
- `Vec<T>`: Dereferences to a mutable slice (`&mut [T]`).
- `String`: Dereferences to a mutable string slice (`&mut str`).

---

**Comparison with Deref**

- **Deref** is used for immutable access (`&T`).
- **DerefMut** is used for mutable access (`&mut T`).

Both traits work together to provide seamless and ergonomic access to data, depending on whether mutability is required.

---

**Benefits**

1. **Mutable Access**: Enables modifying the inner value of custom types.
2. **Operator Overloading**: Allows using the `*` operator for mutable dereferencing.
3. **Deref Coercion**: Automatically converts to `&mut` in compatible contexts, reducing boilerplate.

### **`FromResidual`**

The `FromResidual` trait is used to define how to convert a "residual" value (like the `Err` variant of a `Result` or the `None` variant of an `Option`) into another type. It works in conjunction with the `Try` trait, which powers the `?` operator in Rust.

Residual values are the parts of types like `Result` or `Option` that represent failure or absence (e.g., `Err(E)` or `None`).

**Associated Type**

- **`Residual`**: The type of the residual (e.g., `Err` or `None`) to be converted.

**Required Method**

- **`from_residual(residual: R::Residual) -> Self`**  
    Converts the given residual value into the type implementing `FromResidual`.

**Example**

The `FromResidual` trait is automatically implemented for types like `Result` and `Option`. Here's an example of its use:

```rust
use std::ops::{FromResidual, Try};

fn convert_result() -> Result<u32, String> {
    let value: Result<u32, &str> = Err("error occurred");
    // The `?` operator converts the `Err` residual into a `Result<u32, String>` using `FromResidual`
    value.map_err(String::from)?
}
```

In this example:

1. The `?` operator invokes the `Try` trait on the `value`.
2. The `FromResidual` implementation for `Result` is used to convert the `Err` value (`&str`) into a `String`.

**Real-Life Usage**

You don't usually need to implement `FromResidual` yourself unless you're creating custom types that work with the `?` operator. It's most commonly used with Rust's standard types like `Result` and `Option`.

For instance, when using `?` with a `Result` that has a different error type, `FromResidual` ensures the error is converted into the expected type.

### **`Try`**

**`Try` Trait**

The **`Try`** trait is a core trait in Rust that provides the functionality behind the **`?`** operator. It allows types like `Result` and `Option` to be used for early returns in error handling or short-circuiting when encountering failures or absence of values.

**Associated Types**

- **`Output`**: The successful output of the operation (e.g., the `Ok` or `Some` variant).
- **`Residual`**: The residual or failure output of the operation (e.g., the `Err` or `None` variant).

**Required Methods**

- **`from_output(output: Self::Output) -> Self`**  
    Converts a successful value into the implementing type.
    
    Example:
    
    ```rust
    impl Try for Result<T, E> {
        type Output = T;
        type Residual = Result<Infallible, E>;
    
        fn from_output(output: T) -> Self {
            Ok(output)
        }
    }
    ```
    
- **`from_residual(residual: Self::Residual) -> Self`**  
    Converts a failure residual into the implementing type.
    
    Example:
    
    ```rust
    impl Try for Result<T, E> {
        fn from_residual(residual: Result<Infallible, E>) -> Self {
            match residual {
                Err(e) => Err(e),
                _ => unreachable!(),
            }
        }
    }
    ```


**Example**

Here's an example of how the `Try` trait powers the `?` operator:

```rust
fn parse_number(input: &str) -> Result<i32, String> {
    let num: i32 = input.parse().map_err(|_| "Failed to parse".to_string())?;
    Ok(num)
}
```

In this example:

- The `?` operator invokes the `Try` trait on the `Result` returned by `input.parse()`.
- If the `Result` is `Ok`, the `Output` (the parsed number) is returned.
- If the `Result` is `Err`, the `Residual` (`String`) is propagated out of the function.

**Use Cases**

1. **Error Handling with `Result`**: Short-circuiting on `Err` values to simplify error propagation.
2. **Handling Absence with `Option`**: Exiting early on `None` to handle missing values cleanly.

**Key Notes**

- The `Try` trait is used implicitly by the **`?`** operator.
- Implementing `Try` manually is rare; it’s generally used with standard library types like `Result` and `Option`.
- Custom implementations of `Try` can allow user-defined types to work with the `?` operator.
### `Fn`, `FnMut`, `FnOnce`

In Rust, **`Fn`**, **`FnMut`**, and **`FnOnce`** are traits used to represent **callable types** (such as closures, function pointers, or anything that implements these traits). They define how closures or callable objects consume their captured environment and are primarily distinguished by **how they capture variables**.

**`Fn`**

The **`Fn`** trait is used for closures that **only borrow** values from their environment immutably. It is suitable for read-only operations.

- **Key Characteristics**:
    - Borrow captured variables immutably (`&T`).
    - Can be called multiple times.
- **Example**:
    
    ```rust
    fn call_fn<F: Fn()>(f: F) {
        f();
    }
    
    fn main() {
        let x = 42;
        let closure = || println!("x is {}", x); // Closure borrows `x` immutably
        call_fn(closure); // Can call multiple times
        call_fn(closure);
    }
    ```


**`FnMut`**

The **`FnMut`** trait is used for closures that **mutably borrow** values from their environment. It is suitable for modifying or updating captured variables.

- **Key Characteristics**:
    - Borrow captured variables mutably (`&mut T`).
    - Can be called multiple times, but requires mutable access.
- **Example**:
    
    ```rust
    fn call_fn_mut<F: FnMut()>(mut f: F) {
        f();
    }
    
    fn main() {
        let mut count = 0;
        let mut closure = || {
            count += 1; // Mutably borrows `count`
            println!("count is now {}", count);
        };
        call_fn_mut(&mut closure); // Mutates `count`
        call_fn_mut(&mut closure);
    }
    ```

 **`FnOnce`**

The **`FnOnce`** trait is used for closures that **consume** their captured environment, taking ownership of the values. This is commonly used when a closure moves values from its environment.

- **Key Characteristics**:
    - Takes ownership of captured variables (`T`).
    - Can be called **only once** since ownership is moved.
- **Example**:
    
    ```rust
    fn call_fn_once<F: FnOnce()>(f: F) {
        f();
    }
    
    fn main() {
        let x = String::from("hello");
        let closure = || println!("x is {}", x); // Moves `x` into closure
        call_fn_once(closure); // Can only call once
        // call_fn_once(closure); // Error: `closure` was already moved
    }
    ```


**Relationship Between `Fn`, `FnMut`, and `FnOnce`**

- **`Fn`** is the most restrictive; it requires immutable borrowing.
- **`FnMut`** is less restrictive; it requires mutable borrowing.
- **`FnOnce`** is the least restrictive; it requires ownership and consumes the variables.

Every **`Fn`** closure is also an **`FnMut`** and **`FnOnce`** closure (because immutable borrowing is stricter). Similarly, every **`FnMut`** closure is also an **`FnOnce`** closure.

**Summary of Differences**

|Trait|Captures Environment|Callable Multiple Times?|Example Usage|
|---|---|---|---|
|**`Fn`**|By immutable reference (`&T`)|Yes|Read-only operations|
|**`FnMut`**|By mutable reference (`&mut T`)|Yes (with `&mut`)|Modifying variables|
|**`FnOnce`**|By value (`T`)|No|Consumes variables|
**Choosing the Right Trait**

1. **Use `Fn`** if you do not need to modify or consume any variables in the closure.
2. **Use `FnMut`** if you need to modify variables within the closure.
3. **Use `FnOnce`** if the closure needs to take ownership of the variables.

---

### **`Add`, `Sub`, `Mul`, `Div`, `Rem`, and `Neg`**

In Rust, these traits are part of the **`std::ops`** module and define how operator overloading works for custom types. They allow you to define custom behavior for arithmetic operators like `+`, `-`, `*`, `/`, `%`, and unary `-`.

#### **`Add`**

Defines the behavior of the **`+`** operator.

- **Associated Method**: `add`
- **Example**:
    
    ```rust
    use std::ops::Add;
    
    #[derive(Debug)]
    struct Point {
        x: i32,
        y: i32,
    }
    
    impl Add for Point {
        type Output = Point;
    
        fn add(self, other: Point) -> Point {
            Point {
                x: self.x + other.x,
                y: self.y + other.y,
            }
        }
    }
    
    fn main() {
        let p1 = Point { x: 1, y: 2 };
        let p2 = Point { x: 3, y: 4 };
        let result = p1 + p2; // Calls the `add` method
        println!("{:?}", result); // Output: Point { x: 4, y: 6 }
    }
    ```
    

---

#### **`Sub`**

Defines the behavior of the **`-`** operator.

- **Associated Method**: `sub`
- **Example**:
    
    ```rust
    use std::ops::Sub;
    
    #[derive(Debug)]
    struct Point {
        x: i32,
        y: i32,
    }
    
    impl Sub for Point {
        type Output = Point;
    
        fn sub(self, other: Point) -> Point {
            Point {
                x: self.x - other.x,
                y: self.y - other.y,
            }
        }
    }
    
    fn main() {
        let p1 = Point { x: 5, y: 7 };
        let p2 = Point { x: 2, y: 3 };
        let result = p1 - p2; // Calls the `sub` method
        println!("{:?}", result); // Output: Point { x: 3, y: 4 }
    }
    ```
    

---

#### **`Mul`**

Defines the behavior of the **`*`** operator.

- **Associated Method**: `mul`
- **Example**:
    
    ```rust
    use std::ops::Mul;
    
    #[derive(Debug)]
    struct Scalar {
        value: i32,
    }
    
    impl Mul for Scalar {
        type Output = Scalar;
    
        fn mul(self, other: Scalar) -> Scalar {
            Scalar {
                value: self.value * other.value,
            }
        }
    }
    
    fn main() {
        let s1 = Scalar { value: 4 };
        let s2 = Scalar { value: 3 };
        let result = s1 * s2; // Calls the `mul` method
        println!("{:?}", result); // Output: Scalar { value: 12 }
    }
    ```
    

---

#### **`Div`**

Defines the behavior of the **`/`** operator.

- **Associated Method**: `div`
- **Example**:
    
    ```rust
    use std::ops::Div;
    
    #[derive(Debug)]
    struct Scalar {
        value: i32,
    }
    
    impl Div for Scalar {
        type Output = Scalar;
    
        fn div(self, other: Scalar) -> Scalar {
            Scalar {
                value: self.value / other.value,
            }
        }
    }
    
    fn main() {
        let s1 = Scalar { value: 12 };
        let s2 = Scalar { value: 3 };
        let result = s1 / s2; // Calls the `div` method
        println!("{:?}", result); // Output: Scalar { value: 4 }
    }
    ```
    

---

#### **`Rem`**

Defines the behavior of the **`%`** operator (remainder/modulus).

- **Associated Method**: `rem`
- **Example**:
    
    ```rust
    use std::ops::Rem;
    
    #[derive(Debug)]
    struct Scalar {
        value: i32,
    }
    
    impl Rem for Scalar {
        type Output = Scalar;
    
        fn rem(self, other: Scalar) -> Scalar {
            Scalar {
                value: self.value % other.value,
            }
        }
    }
    
    fn main() {
        let s1 = Scalar { value: 13 };
        let s2 = Scalar { value: 5 };
        let result = s1 % s2; // Calls the `rem` method
        println!("{:?}", result); // Output: Scalar { value: 3 }
    }
    ```
    

---

#### **`Neg`**

Defines the behavior of the **unary `-`** operator (negation).

- **Associated Method**: `neg`
- **Example**:
    
    ```rust
    use std::ops::Neg;
    
    #[derive(Debug)]
    struct Scalar {
        value: i32,
    }
    
    impl Neg for Scalar {
        type Output = Scalar;
    
        fn neg(self) -> Scalar {
            Scalar {
                value: -self.value,
            }
        }
    }
    
    fn main() {
        let s = Scalar { value: 5 };
        let result = -s; // Calls the `neg` method
        println!("{:?}", result); // Output: Scalar { value: -5 }
    }
    ```
    

**Key Notes**

- These traits allow **operator overloading**, letting you define custom behavior for basic arithmetic and negation.
- Each operator corresponds to a method (e.g., `add`, `sub`, `mul`, etc.).
- You can use these traits with custom types like structs or enums.
- Ensure that your implementation respects the mathematical meaning of the operation for clarity and maintainability.

### **`Shl` and `Shr`**

In Rust, **`Shl`** and **`Shr`** are traits from the **`std::ops`** module that define the behavior of the **left shift (`<<`)** and **right shift (`>>`)** operators, respectively. These traits allow you to overload these operators for custom types.

---

#### **`Shl`**

Defines the behavior of the **left shift (`<<`)** operator.

- **Associated Method**: `shl`
- **Purpose**: Shifts the bits of the left operand to the left by the specified number of places, filling the vacated bits with zeros.
- **Example**:
    
    ```rust
    use std::ops::Shl;
    
    #[derive(Debug)]
    struct Bits(u32);
    
    impl Shl<u32> for Bits {
        type Output = Bits;
    
        fn shl(self, rhs: u32) -> Bits {
            Bits(self.0 << rhs) // Perform left shift
        }
    }
    
    fn main() {
        let bits = Bits(0b0001); // Binary: 0001
        let shifted = bits << 2; // Shift left by 2 places
        println!("{:?}", shifted); // Output: Bits(4), Binary: 0100
    }
    ```
    

---

#### **`Shr`**

Defines the behavior of the **right shift (`>>`)** operator.

- **Associated Method**: `shr`
- **Purpose**: Shifts the bits of the left operand to the right by the specified number of places, filling the vacated bits with zeros (for unsigned types) or sign-extending the value (for signed types).
- **Example**:
    
    ```rust
    use std::ops::Shr;
    
    #[derive(Debug)]
    struct Bits(u32);
    
    impl Shr<u32> for Bits {
        type Output = Bits;
    
        fn shr(self, rhs: u32) -> Bits {
            Bits(self.0 >> rhs) // Perform right shift
        }
    }
    
    fn main() {
        let bits = Bits(0b1000); // Binary: 1000
        let shifted = bits >> 2; // Shift right by 2 places
        println!("{:?}", shifted); // Output: Bits(2), Binary: 0010
    }
    ```
    

---

**Key Notes**

- **Generic Implementation**: You can implement these traits for custom types, and the right-hand operand (`rhs`) can also have different types (e.g., `u8`, `u32`, etc.).
- **Bitwise Operation**: Both traits operate on the binary representation of the value, making them useful for low-level programming, custom numeric types, and bit manipulation.
- **Usage for Unsigned Types**: For unsigned types (e.g., `u8`, `u32`), the vacated bits are filled with zeros.
- **Usage for Signed Types**: For signed types (e.g., `i8`, `i32`), the behavior depends on whether the type implements **arithmetic right shift** (sign extension) or **logical right shift** (zero-fill).

---

**Custom Combined Example**

You can implement both **`Shl`** and **`Shr`** for the same type:

```rust
use std::ops::{Shl, Shr};

#[derive(Debug)]
struct Bits(u32);

impl Shl<u32> for Bits {
    type Output = Bits;

    fn shl(self, rhs: u32) -> Bits {
        Bits(self.0 << rhs)
    }
}

impl Shr<u32> for Bits {
    type Output = Bits;

    fn shr(self, rhs: u32) -> Bits {
        Bits(self.0 >> rhs)
    }
}

fn main() {
    let bits = Bits(0b0101); // Binary: 0101
    let left_shifted = bits << 1; // Shift left by 1 place
    let right_shifted = bits >> 2; // Shift right by 2 places

    println!("Left shifted: {:?}", left_shifted);  // Output: Bits(10), Binary: 1010
    println!("Right shifted: {:?}", right_shifted); // Output: Bits(1), Binary: 0001
}
```


----

### `BitAnd`, `BitOr`, `BitXor`

#### **`BitAnd`**  

The `BitAnd` trait in Rust is used to overload the bitwise AND operator (`&`) for custom types. When implemented, it allows types to define their behavior for the `&` operator.

**Associated Types**

- `type Output`: Specifies the resulting type of the operation.

**Required Method**

- `fn bitand(self, rhs: RHS) -> Self::Output`: Performs the bitwise AND operation.

**Example**

```rust
use std::ops::BitAnd;

#[derive(Debug)]
struct Flags(u8);

impl BitAnd for Flags {
    type Output = Flags;

    fn bitand(self, rhs: Self) -> Self::Output {
        Flags(self.0 & rhs.0)
    }
}

fn main() {
    let flags1 = Flags(0b1010);
    let flags2 = Flags(0b1100);
    let result = flags1 & flags2;
    println!("{:?}", result); // Output: Flags(8)
}
```

---

#### **`BitOr`**  

The `BitOr` trait is used to overload the bitwise OR operator (`|`) for custom types. It allows types to define their behavior for the `|` operator.

**Associated Types**

- `type Output`: Specifies the resulting type of the operation.

**Required Method**

- `fn bitor(self, rhs: RHS) -> Self::Output`: Performs the bitwise OR operation.

**Example**

```rust
use std::ops::BitOr;

#[derive(Debug)]
struct Flags(u8);

impl BitOr for Flags {
    type Output = Flags;

    fn bitor(self, rhs: Self) -> Self::Output {
        Flags(self.0 | rhs.0)
    }
}

fn main() {
    let flags1 = Flags(0b1010);
    let flags2 = Flags(0b1100);
    let result = flags1 | flags2;
    println!("{:?}", result); // Output: Flags(14)
}
```

---

#### **`BitXor`**  

The `BitXor` trait is used to overload the bitwise XOR operator (`^`) for custom types. It allows types to define their behavior for the `^` operator.

**Associated Types**

- `type Output`: Specifies the resulting type of the operation.

**Required Method**

- `fn bitxor(self, rhs: RHS) -> Self::Output`: Performs the bitwise XOR operation.

**Example**

```rust
use std::ops::BitXor;

#[derive(Debug)]
struct Flags(u8);

impl BitXor for Flags {
    type Output = Flags;

    fn bitxor(self, rhs: Self) -> Self::Output {
        Flags(self.0 ^ rhs.0)
    }
}

fn main() {
    let flags1 = Flags(0b1010);
    let flags2 = Flags(0b1100);
    let result = flags1 ^ flags2;
    println!("{:?}", result); // Output: Flags(6)
}
```

---

**Key Points**

- The `BitAnd`, `BitOr`, and `BitXor` traits are part of the `std::ops` module and enable operator overloading for `&`, `|`, and `^`.
- These traits are useful for types that represent bitmasks, flags, or other binary data structures.
- The `rhs` parameter in the methods can use different types by specifying `RHS` in the implementation.

---

### `Not`

The **`Not`** trait, found in the **`std::ops`** module, defines the behavior of the unary logical **NOT (`!`)** operator. It is commonly used to invert boolean values, but you can implement it for custom types to define your own logic for the **`!`** operator.

**Associated Method**

- **`not(self) -> Self::Output`**
    - Takes `self` and returns the result of applying the **NOT** operation.

**Default Behavior**

For built-in types, the `Not` trait is implemented as follows:

- For **boolean values** (`bool`), it flips the value:
    - `!true` becomes `false`
    - `!false` becomes `true`
- For **integer types**, it performs a **bitwise NOT**:
    - Flips all bits (1 becomes 0, and 0 becomes 1).

**Example: Logical NOT on `bool`**

```rust
fn main() {
    let value = true;
    let inverted = !value; // Logical NOT
    println!("{}", inverted); // Output: false
}
```

**Example: Bitwise NOT on Integers**

```rust
fn main() {
    let value: u8 = 0b1010_1010; // Binary: 1010_1010
    let inverted = !value; // Bitwise NOT
    println!("{:08b}", inverted); // Output: 0101_0101
}
```

**Custom Implementation for `Not`**

You can implement the **`Not`** trait for your own types to define custom behavior for the **`!`** operator.

**Custom Example:**

```rust
use std::ops::Not;

#[derive(Debug)]
struct Light {
    is_on: bool,
}

impl Not for Light {
    type Output = Light;

    fn not(self) -> Light {
        Light {
            is_on: !self.is_on, // Toggle the state
        }
    }
}

fn main() {
    let light = Light { is_on: true };
    let toggled_light = !light;
    println!("{:?}", toggled_light); // Output: Light { is_on: false }
}
```

**Key Notes**

1. **Generic Use**: The `Not` trait can be applied to any custom type where a logical inversion makes sense.
2. **Boolean vs Bitwise**:
    - **Boolean**: Inverts `true`/`false`.
    - **Bitwise**: Flips the bits of integer types.
3. **Custom Logic**: By implementing `Not` for your type, you can define domain-specific inversion operations (e.g., toggling states).


**Practical Use Cases**

1. **Boolean Expressions**: Negating conditions in logical expressions.
    
    ```rust
    if !condition {
        println!("Condition is false.");
    }
    ```
    
2. **Bitwise Operations**: Low-level manipulation of binary data.
    
    ```rust
    let flags: u8 = 0b1100_0011;
    let inverted_flags = !flags;
    println!("{:08b}", inverted_flags); // Output: 0011_1100
    ```
    
3. **Custom Types**: Toggle or invert state in custom domain-specific objects (e.g., lights, switches, or other boolean-like states).

### `FromStr`

The `FromStr` trait in Rust is used to convert a string slice (`&str`) into another type. It is particularly useful for parsing strings into custom data types. This trait is part of the `std::str` module.

**Associated Types**

- `type Err`: Defines the type of error returned if the parsing fails.

**Required Method**

- `fn from_str(s: &str) -> Result<Self, Self::Err>`: Attempts to parse the input string `s` into the implementing type. Returns `Ok(Self)` on success and `Err(Self::Err)` on failure.

**Example**

Here’s how to implement the `FromStr` trait for a custom type:

```rust
use std::str::FromStr;

#[derive(Debug)]
struct Point {
    x: i32,
    y: i32,
}

#[derive(Debug)]
enum ParsePointError {
    InvalidFormat,
    ParseError,
}

impl FromStr for Point {
    type Err = ParsePointError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let parts: Vec<&str> = s.split(',').collect();
        if parts.len() != 2 {
            return Err(ParsePointError::InvalidFormat);
        }
        let x = parts[0].trim().parse::<i32>().map_err(|_| ParsePointError::ParseError)?;
        let y = parts[1].trim().parse::<i32>().map_err(|_| ParsePointError::ParseError)?;
        Ok(Point { x, y })
    }
}

fn main() {
    let input = "10,20";
    match input.parse::<Point>() {
        Ok(point) => println!("Parsed point: {:?}", point), // Output: Parsed point: Point { x: 10, y: 20 }
        Err(err) => println!("Error: {:?}", err),
    }
}
```

**Key Points**

1. **Error Handling**
    
    - Define a meaningful `Err` type to represent parsing errors.
    - Use `Result` to return either the parsed value (`Ok`) or an error (`Err`).
2. **Integration with `str.parse`**
    
    - Types implementing `FromStr` can be parsed directly using the `parse` method of the `str` type:
        
        ```rust
        let num: i32 = "42".parse().unwrap();
        ```
        
3. **Default Implementations**
    
    - Many standard types already implement `FromStr`, such as `i32`, `f64`, `bool`, and `String`.

---

**Built-in Implementations**

- Parsing integers:
    
    ```rust
    let number: i32 = "123".parse().unwrap();
    println!("{}", number); // Output: 123
    ```
    
- Parsing floats:
    
    ```rust
    let pi: f64 = "3.14".parse().unwrap();
    println!("{}", pi); // Output: 3.14
    ```
    
- Parsing booleans:
    
    ```rust
    let flag: bool = "true".parse().unwrap();
    println!("{}", flag); // Output: true
    ```


**Custom Error Types**

It’s common to define a custom error type for complex parsing scenarios:

```rust
#[derive(Debug)]
enum ParseError {
    EmptyInput,
    InvalidFormat,
}

impl FromStr for MyType {
    type Err = ParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        if s.is_empty() {
            return Err(ParseError::EmptyInput);
        }
        // Parsing logic here
        Ok(MyType {})
    }
}
```

**Advantages**

- Provides a standard way to parse strings into types.
- Integrates seamlessly with the `str.parse` method.
- Encourages robust error handling with custom error types.

---

### `Sized`

The **`Sized`** trait is a special trait in Rust that is automatically implemented for types whose size is known at compile time. Most types in Rust are `Sized`, but dynamically-sized types (DSTs) like slices (`[T]`) and trait objects (`dyn Trait`) are not.

**Key Points**

- **Implicit by Default**: By default, all generic type parameters are constrained by `Sized`. To accept unsized types, you can explicitly relax this constraint using `?Sized`.
- **Zero-Sized Types (ZST)**: Types with no data, like `()` or empty structs, are also `Sized`.

**When to Use `?Sized`**

The **`?Sized`** syntax allows a generic type to accept both sized and unsized types. For example, it is often used in type parameters for references or pointers.

Example:

```rust
fn print_name<T: ?Sized>(name: &T) {
    println!("Name received.");
}
```

**Examples**

Default Behavior: Sized Types

```rust
fn display_value<T: Sized>(value: T) {
    println!("The value is owned and has a known size.");
}

fn main() {
    display_value(42); // Works because `i32` is Sized
}
```

Using `?Sized` for Unsized Types

```rust
fn print_slice<T: ?Sized>(slice: &T) {
    println!("Printing a dynamically-sized type.");
}

fn main() {
    let arr = [1, 2, 3];
    print_slice(&arr[..]); // Works because `?Sized` allows slices
}
```

**Practical Use Cases**

1. **Dynamic Types**: Allowing functions to work with trait objects (`dyn Trait`) or slices (`[T]`).
2. **Generic Implementations**: Supporting both sized and unsized types in generic structures or functions.
3. **Pointers and References**: Since pointers and references to unsized types (`&[T]`, `Box<dyn Trait>`) have known sizes, they are often combined with `?Sized`.

**Key Notes**

- `Sized` is a **marker trait**: It does not have any associated methods.
- Types like arrays (`[T; N]`), tuples, and structs are `Sized` if all their elements are `Sized`.
- Dynamically-sized types must always be used behind a pointer, like `&[T]`, `Box<dyn Trait>`, or `Rc<dyn Trait>`.


---

### `Unsize`

The `Unsize` trait in Rust is used to enable the conversion of types to dynamically sized types. It is part of the `std::ptr` module and is used in conjunction with pointer types to allow the "unsizing" of a value, typically to convert a type like `[T; N]` to `[T]`, or `T` to `dyn Trait`.

**Purpose**

- The primary purpose of `Unsize` is to allow unsizing of a value, i.e., to convert a fixed-size type into a dynamically sized type (DST).
- This trait is generally used behind the scenes, and you usually don't need to implement it yourself. It comes into play when performing operations like creating trait objects or working with slices.

**Key Concepts**

- **Dynamically Sized Types (DSTs):** Types like `str`, `dyn Trait`, and slices (`[T]`) are dynamically sized and do not have a known size at compile time.
- **Pointer Conversion:** The trait enables the conversion of a reference or pointer to a dynamically sized type. This is often used with types like `Box`, `Rc`, or raw pointers.

**Common Use Case:**

- Converting from an array to a slice: `[T; N]` can be unsized to `[T]` via the `Unsize` trait when it's used with `Box`, `Rc`, or other types that can handle DSTs.

**Example**

```rust
use std::ptr::Unsize;

struct MyStruct {
    data: [u8; 4],
}

fn main() {
    let arr: [u8; 4] = [1, 2, 3, 4];
    let slice: &[u8] = &arr[..]; // Converting array to slice, utilizing `Unsize`
    println!("{:?}", slice);
}
```

In this example, the fixed-size array `[u8; 4]` is "unsized" to a dynamically sized slice `&[u8]` for the purpose of passing it around as a trait object or dynamically sized reference.

**How it Works with Trait Objects**

You can use `Unsize` to create trait objects like `dyn Trait`:

```rust
use std::ptr::Unsize;

trait Speak {
    fn speak(&self);
}

struct Dog;

impl Speak for Dog {
    fn speak(&self) {
        println!("Woof!");
    }
}

fn main() {
    let dog: Box<dyn Speak> = Box::new(Dog);
    dog.speak(); // Output: Woof!
}
```

In this case, the `Dog` struct is unsized to a `dyn Speak` trait object, allowing it to be stored inside a `Box` and passed around dynamically.

**Key Points**

- The `Unsize` trait is primarily used internally for pointer and reference conversions.
- It facilitates the use of dynamically sized types like slices or trait objects.
- While you typically don't implement `Unsize` yourself, it plays a crucial role in working with DSTs.

---

### `Send`

The `Send` trait in Rust is used to indicate that ownership of a type can be safely transferred between threads. Types that implement `Send` can be moved across thread boundaries, which is essential for concurrent programming in Rust.

**Key Concepts**

- **Thread Safety:** `Send` is a marker trait that tells the Rust compiler that it is safe to send a type's value between threads. If a type does not implement `Send`, it cannot be transferred across threads.
- **Automatic Implementation:** Rust automatically implements `Send` for types where it can prove that all components are thread-safe, such as primitive types (`i32`, `f64`), standard library types like `Vec<T>`, and `Box<T>` (where `T` is `Send`).

**Common Use Case**

- You can use `Send` when spawning threads or using channels to pass data across threads. If a type implements `Send`, it can be moved into a thread.

**Example**

```rust
use std::thread;

fn main() {
    let data = vec![1, 2, 3, 4]; // `Vec<i32>` implements `Send`

    let handle = thread::spawn(move || {
        println!("{:?}", data); // Data is moved into the thread
    });

    handle.join().unwrap(); // Wait for the thread to finish
}
```

In this example, `data`, which is a `Vec<i32>`, implements `Send`, so it can be moved into the spawned thread safely.

**Types That Do Not Implement Send**

- **Non-Send Types:** Some types, like `Rc<T>` and `RefCell<T>`, do not implement `Send` because they allow shared, mutable access to their inner data, which isn't safe in a concurrent context.

Example of a non-Send type:

```rust
use std::thread;

fn main() {
    let data = std::rc::Rc::new(5); // `Rc<T>` does not implement `Send`

    // This will result in a compile-time error:
    // thread::spawn(move || {
    //     println!("{}", data);
    // });
}
```

**Key Points**

- **Send is Auto-Implemented:** Types like `i32`, `f64`, `Box<T>`, `Vec<T>`, etc., implement `Send` automatically if `T` is `Send`.
- **Safety Considerations:** `Send` is a fundamental trait for Rust's ownership and borrowing system, ensuring that data isn't accessed by multiple threads simultaneously in an unsafe manner.
- **Concurrency:** Types that implement `Send` can be moved between threads using concurrency tools like `thread::spawn`, `mpsc::channel`, etc.

---

### `Sync`

The `Sync` trait in Rust is used to indicate that a type can be safely shared between multiple threads. Types that implement the `Sync` trait are safe to reference from multiple threads simultaneously. It is used to ensure that data can be shared between threads without data races.

**Key Concepts**

- **Thread Safety for Shared References:** If a type implements `Sync`, it means that it is safe for multiple threads to have references to it at the same time. For example, a type that can be safely referenced from multiple threads without causing data races or mutable aliasing.
- **Immutability:** Types that implement `Sync` are generally types that either are immutable or manage their own internal synchronization (e.g., using locks) to prevent data races.

**Automatic Implementation**

- Rust automatically implements `Sync` for types where it can guarantee that shared references are safe. For example, types like `i32`, `f64`, `String`, `Vec<T>`, etc., implement `Sync` because they are either immutable or internally safe for concurrent access.
- However, types that involve mutable state, like `RefCell<T>` or `Rc<T>`, do not implement `Sync` because they can lead to data races when accessed by multiple threads simultaneously.

**Common Use Case**

- `Sync` is commonly used when you need to share data between threads via immutable references. For instance, when using shared state across threads or in concurrent data structures.

**Example**

```rust
use std::sync::{Arc, Mutex};
use std::thread;

struct Data {
    value: i32,
}

impl Data {
    fn new(value: i32) -> Self {
        Data { value }
    }
}

fn main() {
    let data = Arc::new(Mutex::new(Data::new(42))); // `Arc<Mutex<T>>` implements `Sync`

    let threads: Vec<_> = (0..5).map(|i| {
        let data_clone = Arc::clone(&data);
        thread::spawn(move || {
            let mut data = data_clone.lock().unwrap();
            data.value += i;
            println!("Thread {}: {}", i, data.value);
        })
    }).collect();

    for t in threads {
        t.join().unwrap();
    }
}
```

In this example:

- `Arc<Mutex<T>>` is used to share data between threads. `Arc` (atomic reference-counted pointer) enables safe sharing of the data, and `Mutex` ensures exclusive mutable access to the data.
- The type `Mutex<T>` implements `Sync` because it uses locks to ensure that only one thread can access the data at a time.

**Types That Do Not Implement Sync**

- Types like `RefCell<T>`, `Rc<T>`, and `Cell<T>` do not implement `Sync` because they allow mutable access to their inner data, which can lead to data races if shared between threads.

Example of a non-Sync type:

```rust
use std::thread;

fn main() {
    let data = std::rc::Rc::new(5); // `Rc<T>` does not implement `Sync`

    // This will result in a compile-time error:
    // let handle = thread::spawn(move || {
    //     println!("{}", data);
    // });
}
```

**Key Points**

- **Sync is Auto-Implemented:** Types like `i32`, `f64`, and `String` implement `Sync` automatically because they are either immutable or use internal synchronization mechanisms.
- **Immutable Shared Data:** `Sync` allows shared, immutable references to be safely used across multiple threads.
- **Safety:** `Sync` ensures that the Rust compiler can prevent data races in concurrent environments by enforcing safe sharing of references.


---

### `UnwindSafe`

**`UnwindSafe` Trait**  
The **`UnwindSafe`** trait is used in Rust to indicate whether a type can be safely used across an _unwind_ caused by a panic. It is part of Rust's runtime safety system and is used in conjunction with the `catch_unwind` function from the `std::panic` module.

**Key Points**

- **Panic Safety**: Types that implement `UnwindSafe` are considered safe to use after a panic occurs during an unwinding process.
- **Automatic Implementation**: Most types implement `UnwindSafe` automatically unless they contain interior mutability (like `RefCell` or `UnsafeCell`) or other unsafe constructs.
- **Marker Trait**: It is a marker trait, meaning it has no methods or behavior of its own but is used for compile-time checks.

**Practical Usage**  
The **`UnwindSafe`** trait is mainly used when working with panic recovery using `catch_unwind`. For instance, closures passed to `catch_unwind` must be `UnwindSafe`.

Example:

```rust
use std::panic;

fn main() {
    let result = panic::catch_unwind(|| {
        println!("This is safe to unwind!");
    });

    match result {
        Ok(_) => println!("Unwind completed successfully."),
        Err(_) => println!("A panic occurred during the unwind."),
    }
}
```

In this example, the closure passed to `catch_unwind` must implement `UnwindSafe`.

---

### `RefUnwindSafe`

**`RefUnwindSafe` Trait**  
The **`RefUnwindSafe`** trait is a marker trait in Rust that signifies whether a type is safe to use in the context of a panic recovery scenario when using references. Specifically, it is used for types that contain references to other data, ensuring that those references are not invalidated during the unwinding process caused by a panic.

**Key Points**

- **For Types with References**: It extends `UnwindSafe` for types that contain references, ensuring they can be safely used during panic recovery.
- **Refinement of `UnwindSafe`**: It is a more specific marker trait than `UnwindSafe` and is primarily concerned with references that are not invalidated by the panic unwind process.
- **Automatic Implementation**: Like `UnwindSafe`, `RefUnwindSafe` is automatically implemented for most types, but types that involve interior mutability (like `RefCell`, `UnsafeCell`, or `Cell`) might not implement it.

**Practical Usage**  
This trait is generally used with types that include references, ensuring that the references do not become dangling or invalidated during the panic unwinding process.

Example:

```rust
use std::panic;

struct Data<'a> {
    value: &'a str,
}

fn main() {
    let data = "Hello, World!";
    let ref_data = Data { value: data };

    let result = panic::catch_unwind(|| {
        println!("{}", ref_data.value);
    });

    match result {
        Ok(_) => println!("Unwind completed successfully."),
        Err(_) => println!("A panic occurred during the unwind."),
    }
}
```

In this example, the `Data` struct contains a reference (`&'a str`), and `RefUnwindSafe` ensures that it is safe to use during the panic unwind process.

---

### `Write`

The **`Write`** trait in Rust provides methods for writing data to a destination, typically output streams like files, buffers, or even the standard output. It defines functionality to write bytes of data to a type that implements this trait.

**Key Points**

- **Basic Writing Operations**: It includes methods like `write()`, which writes a slice of bytes, and `flush()`, which ensures that any buffered data is written out.
- **Common Implementations**: Types such as `File`, `TcpStream`, and `BufWriter` implement the `Write` trait to allow efficient writing operations.
- **Error Handling**: The `write()` method returns a `Result<usize, std::io::Error>`, allowing you to handle possible I/O errors when writing data.

**Methods**

- **`write(&mut self, buf: &[u8]) -> Result<usize>`**: Writes the contents of the buffer `buf` to the destination and returns the number of bytes written.
- **`flush(&mut self) -> Result<()>`**: Forces all buffered data to be written out.

**Practical Usage**  
The `Write` trait is used to handle low-level I/O operations, and it's typically seen in more performance-sensitive or direct output tasks.

Example:

```rust
use std::io::{self, Write};

fn main() -> io::Result<()> {
    let mut stdout = io::stdout();
    
    // Write a string to standard output
    stdout.write_all(b"Hello, world!\n")?;
    
    // Flush to ensure it gets printed immediately
    stdout.flush()?;
    
    Ok(())
}
```

In this example, we use the `Write` trait to write a byte slice (`b"Hello, world!"`) to the standard output and then call `flush()` to ensure the data is immediately printed to the terminal.

---

### `Read`

**`Read` Trait**  
The **`Read`** trait in Rust is used for reading bytes from a source, such as a file, a network stream, or an in-memory buffer. It provides methods to pull data from a source and is fundamental for working with input in Rust.

**Key Points**

- **Basic Reading Operations**: The trait provides the `read()` method for reading bytes and the `read_to_string()` method for reading data into a string.
- **Common Implementations**: Types like `File`, `TcpStream`, and `Stdin` implement the `Read` trait for handling byte-level reading.
- **Error Handling**: The `read()` method returns a `Result<usize, std::io::Error>`, where `usize` is the number of bytes read, or an error if something goes wrong.

**Methods**

- **`read(&mut self, buf: &mut [u8]) -> Result<usize>`**: Reads data into the provided buffer `buf`, returning the number of bytes read.
- **`read_to_string(&mut self, buf: &mut String) -> Result<usize>`**: Reads all bytes until EOF and appends them as a string to `buf`.

**Practical Usage**  
The `Read` trait is useful when you need to handle byte-based input, like reading from files, network sockets, or standard input.

Example:

```rust
use std::io::{self, Read};

fn main() -> io::Result<()> {
    let mut file = std::fs::File::open("example.txt")?;
    let mut buffer = String::new();
    
    // Read the file's content into the string buffer
    file.read_to_string(&mut buffer)?;
    
    println!("File contents: {}", buffer);
    
    Ok(())
}
```

In this example, the `Read` trait is used to read the contents of a file into a `String`. The `read_to_string()` method is called to handle reading all the bytes from the file and convert them into a string that can be printed.

---

### `Seek`

The `Seek` trait in Rust is used for types that allow seeking within a stream of data, which means moving the "cursor" or position within a data source, like a file, buffer, or network stream. It is part of the `std::io` module and is typically used in conjunction with types that implement the `Read` and `Write` traits.

**Associated Types**

- The `Seek` trait does not have any associated types.

**Required Methods**

- `fn seek(&mut self, pos: SeekFrom) -> io::Result<u64>`: Moves the cursor within the stream. The `SeekFrom` enum defines the position to seek from (e.g., from the start, current position, or end).

**SeekFrom Enum** The `SeekFrom` enum is used to specify the relative position for seeking:

- `Start(u64)`: Seek from the beginning (start) of the stream.
- `Current(i64)`: Seek from the current position.
- `End(i64)`: Seek from the end of the stream.

**Example**

Here’s how to use the `Seek` trait with a file in Rust:

```rust
use std::fs::File;
use std::io::{self, Seek, SeekFrom, Read};

fn main() -> io::Result<()> {
    let mut file = File::open("example.txt")?;
    
    // Seek to the beginning of the file
    file.seek(SeekFrom::Start(0))?;
    
    let mut buffer = vec![0; 10];
    file.read(&mut buffer)?;
    println!("Data: {:?}", buffer);
    
    // Seek 5 bytes from the start
    file.seek(SeekFrom::Start(5))?;
    file.read(&mut buffer)?;
    println!("Data after seeking 5 bytes from start: {:?}", buffer);
    
    Ok(())
}
```

In this example:

- `seek(SeekFrom::Start(0))` moves the cursor to the beginning of the file.
- `seek(SeekFrom::Start(5))` moves the cursor to the 5th byte from the start of the file.

**Key Points**

- **Seeking:** The `Seek` trait allows types to move within data streams to a specific position, enabling random access.
- **Usage:** It is commonly used with types like files (`File`), buffers, or network streams that support both reading and seeking.
- **Error Handling:** The `seek` method returns a `Result`, which is important for handling I/O errors when seeking within a stream.

**Common Implementations**

- **File**: Rust's standard library provides `Seek` for `File`, enabling seeking within files.
- **BufReader**: The `BufReader` type implements `Seek` as long as it wraps a type that also implements `Seek`, like `File`.

**Why Use Seek?**

- **Random Access:** Seek allows random access to data, which can be crucial when working with large files or streams where you need to jump to specific positions in the data.
- **Efficient File Handling:** It provides a way to optimize file handling by seeking to a position rather than reading everything sequentially.

---

### `Future`

The **`Future`** trait in Rust is a foundational component for asynchronous programming. It represents a value that may not be immediately available but will become available at some point in the future. This is similar to a "promise" in JavaScript or a "task" in Python.

**Key Characteristics:**

- **Asynchronous Execution:** A `Future` allows you to work with asynchronous operations without blocking the current thread.
- **Polling Mechanism:** Futures in Rust don't execute themselves automatically. Instead, they rely on a runtime or executor to poll them until they are "ready" (i.e., their value is computed or the operation is complete).

**Methods in the Future Trait:**

- **poll:** This is the main method of the `Future` trait. It checks whether the future is ready to produce a value.
    - Signature:
        
        ```rust
        fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>;
        ```
        
    - **Parameters:**
        - `Pin<&mut Self>`: Ensures the future's memory location doesn't change while it is being polled.
        - `Context`: Provides a way to register a "waker," which will notify the executor when the future is ready.
    - **Returns:**
        - `Poll<Self::Output>`: Indicates whether the future is ready (`Poll::Ready`) or not (`Poll::Pending`).

**Common Traits for Futures:**

- **`Send` and `Sync`:** If a future is safe to send or share between threads, it implements these traits.
- **`Unpin`:** If a future can be safely moved in memory, it implements `Unpin`. Otherwise, it needs to be "pinned."

**Future vs. Task:**

- A **Future** is a computation that produces a value in the future.
- A **Task** is a unit of execution managed by an executor, often built around a `Future`.

**Analogy:** Think of a `Future` as a ticket for a movie you plan to watch later. The ticket guarantees that you'll eventually see the movie, but you have to wait until the showtime (executor) for it to happen. The ticket doesn't automatically play the movie; it just holds the promise of it happening later.

---

### `Stream`

The **`Stream`** trait in Rust is a counterpart to the `Future` trait, but instead of producing a single value in the future, a `Stream` produces a sequence of values over time. It is a key abstraction for asynchronous programming when working with data that arrives incrementally.

**Key Characteristics:**

- **Asynchronous Sequences:** A `Stream` allows processing of data that is produced or received incrementally, like reading lines from a file or receiving messages over a network.
- **Polling Mechanism:** Similar to `Future`, `Stream` is also polled to retrieve values one at a time as they become available.

**Methods in the Stream Trait:**

- **poll_next:** This is the main method of the `Stream` trait, used to fetch the next value from the stream.
    - Signature:
        
        ```rust
        fn poll_next(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Option<Self::Item>>;
        ```
        
    - **Parameters:**
        - `Pin<&mut Self>`: Ensures the stream's memory location doesn't change while it is being polled.
        - `Context`: Allows the registration of a "waker" to notify the executor when the stream is ready to produce more data.
    - **Returns:**
        - `Poll<Option<Self::Item>>`: Indicates whether the stream has produced a new value (`Poll::Ready(Some(item))`), has ended (`Poll::Ready(None)`), or is not ready yet (`Poll::Pending`).

**Associated Types:**

- **`Item`:** The type of value produced by the stream.

**Common Utilities for Streams:**

Rust's `Stream` trait comes with many utility functions provided by extensions in the `futures` crate. These functions are similar to those available for iterators, such as:

- **`map`**: Transform each item in the stream.
- **`filter`**: Filter items based on a condition.
- **`collect`**: Consume the stream and collect all its items into a collection.

**Differences Between Stream and Future:**

- A **`Future`** resolves to a single value or an error once.
- A **`Stream`** yields a series of values over time, and its completion signifies the end of the stream.

**Analogy:** Think of a `Stream` as a conveyor belt that delivers packages (data) one by one. You wait for each package to arrive, process it, and then wait for the next. If the belt stops delivering, it signals that the stream is complete.

**Example:**

Using `Stream` in Rust:

```rust
use futures::stream::{self, StreamExt};

#[tokio::main]
async fn main() {
    let stream = stream::iter(vec![1, 2, 3, 4, 5]); // Create a stream of integers.
    let sum: i32 = stream.fold(0, |acc, x| async move { acc + x }).await;
    println!("Sum: {}", sum); // Output: Sum: 15
}
```

This example demonstrates creating a stream, processing each item, and summing the values.

---

### `Any`

The **`Any`** trait in Rust is a way to achieve runtime type checking and type-safe downcasting. It allows working with values of any type by erasing their concrete type, enabling dynamic dispatch.

**Key Characteristics:**

- **Type Erasure:** `Any` allows you to store and manipulate values without knowing their exact type at compile time.
- **Downcasting:** Using `Any`, you can attempt to recover the original type of a value at runtime. This is called downcasting.
- **Type Information:** `Any` is implemented for all types that have a `'static` lifetime, meaning the type must not contain references with lifetimes tied to the stack.

**Methods in the Any Trait:**

1. **`is<T>()`**
    
    - Checks if the stored value is of type `T`.
    - **Example:**
        
        ```rust
        use std::any::Any;
        
        let value: &dyn Any = &42;
        assert!(value.is::<i32>());
        assert!(!value.is::<f64>());
        ```
        
2. **`downcast_ref<T>()`**
    
    - Attempts to get a reference to the value as type `T`. Returns `Some` if the cast succeeds, otherwise `None`.
    - **Example:**
        
        ```rust
        let value: &dyn Any = &42;
        if let Some(v) = value.downcast_ref::<i32>() {
            println!("Value is i32: {}", v);
        }
        ```
        
3. **`downcast_mut<T>()`**
    
    - Attempts to get a mutable reference to the value as type `T`. Returns `Some` if the cast succeeds, otherwise `None`.
    - **Example:**
        
        ```rust
        let mut value: Box<dyn Any> = Box::new(42);
        if let Some(v) = value.downcast_mut::<i32>() {
            *v += 1;
        }
        ```
        
4. **`type_id()`**
    
    - Returns a `TypeId` that uniquely identifies the type of the value at runtime.

**Use Cases:**

- **Dynamic Typing:** When you need to handle multiple types but can't know them all at compile time (e.g., plugin systems or heterogeneous collections).
- **Type Checking:** To determine if a stored value matches a specific type at runtime.

**Limitations:**

- Only works for types with a `'static` lifetime.
- Requires manual downcasting, which introduces some runtime overhead and potential complexity.

**Analogy:** Think of `Any` as a box labeled "Miscellaneous." You can store any item in it, but to retrieve the item, you must know what you're looking for and check the type before taking it out.

**Example:**

Using `Any` for type erasure and downcasting:

```rust
use std::any::Any;

fn print_if_string(value: &dyn Any) {
    if let Some(string) = value.downcast_ref::<String>() {
        println!("Found a string: {}", string);
    } else {
        println!("Not a string");
    }
}

fn main() {
    let value: &dyn Any = &"Hello, world!".to_string();
    print_if_string(value); // Output: Found a string: Hello, world!
}
```

Here, the `Any` trait allows storing and checking the type of the value dynamically at runtime.

---

### `Termination`

**`std::process::Termination` Trait**

The **`Termination`** trait in Rust is used to define the return type of the `main` function. By implementing this trait, you can control how your program exits, including what status code it returns to the operating system.

**Key Characteristics:**

- **Custom Exit Codes:** Allows you to return more meaningful exit codes from your program, beyond the default `0` for success.
- **Trait Implementations:** Rust provides default implementations for common types like `()`, `Result<(), E>`, and `Result<T, E>` where `E` implements `Debug`.

**Associated Function:**

- **`fn report(self) -> i32`**
    - This method is called by the Rust runtime at the end of the `main` function to determine the program's exit status.
    - **Returns:** An `i32` that represents the process's exit code.
        - `0` typically indicates success.
        - Non-zero values indicate failure or specific error codes.

**Default Implementations:**

1. **For `()`**
    
    - The default return type for `main`.
    - Always returns `0` (success).
    - **Example:**
        
        ```rust
        fn main() {} // Implicitly returns ()
        ```
        
2. **For `Result<T, E>`**
    
    - When `T` is `()` and `E` implements `Debug`:
        - `Ok(())` returns `0`.
        - `Err(e)` prints the debug representation of `e` and returns `1`.
    - **Example:**
        
        ```rust
        fn main() -> Result<(), &'static str> {
            Err("An error occurred") // Program exits with code 1
        }
        ```
        
3. **Custom Implementations**
    
    - You can define custom types to implement the `Termination` trait to control exit behavior.

**Example of Custom Implementation:**

```rust
use std::process::Termination;

struct MyExitCode(i32);

impl Termination for MyExitCode {
    fn report(self) -> i32 {
        self.0 // Use the stored value as the exit code
    }
}

fn main() -> MyExitCode {
    MyExitCode(42) // Program exits with code 42
}
```

**Use Cases:**

- **Custom Exit Codes:** Useful in CLI applications to provide meaningful error codes to the operating system.
- **Enhanced Debugging:** Return structured results that include error messages or context during program termination.

**Analogy:**

Think of the `Termination` trait as a way to send a "status report" when leaving a meeting (your program). If everything went well, you give a thumbs up (`0`). If there were issues, you can specify the exact problem with a detailed note (custom exit code).

**Advantages:**

- Cleaner code for custom error handling.
- Improved interoperability with external systems or scripts that depend on specific exit codes.

In summary, `std::process::Termination` makes the program's exit behavior customizable, allowing you to go beyond the default `main` function conventions.

---

| Trait           | Purpose                                                                         |
| --------------- | ------------------------------------------------------------------------------- |
| `Serialize`     | Enables serialization of data structures (with `serde`).                        |
| `Deserialize`   | Enables deserialization of data structures (with `serde`).                      |
| `Iterator`      | Implements the `Iterator` trait for a struct or enum.                           |
| `FusedIterator` | Indicates an iterator that does not yield `Some` after `None`.                  |
| `Drop`          | Allows specification of actions when a value goes out of scope.                 |
| `From`          | Enables conversion from one type to another (often used with `Into`).           |
| `Into`          | Allows conversion from one type to another in the opposite direction of `From`. |
| `Clone`         | Allows copying of the data (deep copy).                                         |
| `Copy`          | Enables bitwise copy for types that implement `Clone`.                          |
| `Debug`         | Allows debug formatting with `{:?}`.                                            |
| `PartialEq`     | Enables equality comparison (`==` and `!=`).                                    |
| `Eq`            | Indicates total equality (often paired with `PartialEq`).                       |
| `PartialOrd`    | Allows partial ordering (`<`, `>`, `<=`, `>=`).                                 |
| `Ord`           | Enables total ordering (often paired with `PartialOrd`).                        |
| `Default`       | Provides a default value.                                                       |
| `Hash`          | Allows the type to be used as a key in hash maps.                               |
| `AsRef`         | Allows conversion into an immutable reference.                                  |
| `AsMut`         | Allows conversion into a mutable reference.                                     |
# Trait Objects

**Trait objects** in Rust provide a way to enable runtime polymorphism. They allow you to work with values of different types that implement the same trait through dynamic dispatch, enabling flexibility in your code. Trait objects are typically used in situations where the exact type of the value isn’t known at compile time but must adhere to a specific behavior defined by a trait.

---

**Syntax**

To create a trait object, use the `dyn` keyword followed by the trait name:

```rust
dyn TraitName
```

Example:

```rust
let object: &dyn MyTrait;
```

---

**Key Features of Trait Objects**

1. **Trait Object**
    - A trait object is a pointer (e.g., `&dyn Trait`, `Box<dyn Trait>`) to a value of a type that implements the specified trait.
    - It stores both the data and a "vtable" (a table of function pointers) for dynamic dispatch.
2. **Dynamic Dispatch**
    - Trait objects use a **vtable** (virtual method table) to resolve method calls at runtime.
    - This differs from static dispatch, where method calls are resolved at compile time.
    - With `dyn`, method calls are resolved at runtime using the vtable instead of compile time. This allows for flexibility but incurs a small runtime cost compared to static dispatch.
3. **Unsized Types**
    - Trait objects are **unsized**, meaning you cannot use them directly as variables. They must be used behind pointer types such as `&`, `Box`, `Rc`, or `Arc`.
4. **Object Safety**
    - Only **object-safe traits** can be used as trait objects.
    - A trait is object-safe if:
        - All methods use `self` as the receiver (`&self`, `&mut self`, or `self`).
        - The trait does not have any generic methods.
5.  **Static vs. Dynamic Dispatch**
    - Static dispatch: The method implementations are determined at compile time. (`impl Trait`)
    - Dynamic dispatch: The method implementations are determined at runtime. (`dyn Trait`)

---

**Examples**

Using Trait Objects with `Box`

```rust
trait Speak {
    fn speak(&self);
}

struct Dog;
impl Speak for Dog {
    fn speak(&self) {
        println!("Woof!");
    }
}

struct Cat;
impl Speak for Cat {
    fn speak(&self) {
        println!("Meow!");
    }
}

fn main() {
    let animals: Vec<Box<dyn Speak>> = vec![
        Box::new(Dog),
        Box::new(Cat),
    ];

    for animal in animals {
        animal.speak();
    }
}
```

**Output**:

```
Woof!
Meow!
```

---

**Using Trait Objects with `&` References**

```rust
trait Greet {
    fn greet(&self);
}

struct Person;
impl Greet for Person {
    fn greet(&self) {
        println!("Hello!");
    }
}

struct Robot;
impl Greet for Robot {
    fn greet(&self) {
        println!("Beep boop!");
    }
}

fn greet_all(greeters: Vec<&dyn Greet>) {
    for greeter in greeters {
        greeter.greet();
    }
}

fn main() {
    let person = Person;
    let robot = Robot;

    greet_all(vec![&person, &robot]);
}
```

**Output**:

```
Hello!
Beep boop!
```


---

### **Object Safety**

Traits must meet specific criteria to be used as trait objects:

1. **Self Type Constraints**
    - Methods must take `self` as a receiver (`&self`, `&mut self`, or `self`).
    - Methods like `fn do_something(self: Box<Self>)` are valid, but not those with generic `self`.
2. **No Generic Methods**
    - Traits with methods like `fn foo<T>(&self)` are not object-safe.
    
    Example of a non-object-safe trait:
    ```rust
    trait NonObjectSafe {
        fn do_something<T>(&self);
    }
    ```
    
3. **No Associated Constants or Generic Types**
    - Traits with associated constants or generic types are not object-safe.

---

### **Trait Objects vs. Static Dispatch**

|Feature|**Trait Objects** (`dyn Trait`)|**Static Dispatch** (`impl Trait`)|
|---|---|---|
|**Dispatch**|Dynamic (runtime)|Static (compile-time)|
|**Performance**|Slightly slower (vtable)|Faster|
|**Size**|Unsized, requires pointers|Sized|
|**Flexibility**|Multiple types possible|Single concrete type|

---

### **When to Use Trait Objects**

1. **Heterogeneous Collections**  
    Use trait objects when you need a collection with elements of different types implementing the same trait:
    
    ```rust
    let items: Vec<Box<dyn std::fmt::Debug>> = vec![
        Box::new(42),
        Box::new("Hello"),
    ];
    ```
    
2. **Runtime Behavior**  
    Use trait objects when the exact type is not known until runtime, such as plugin systems or dependency injection.
    
3. **Abstract Interfaces**  
    Pass trait objects to functions when you need flexibility in accepting multiple implementations.
    

---

**Common Pitfalls**

1. **Missing `dyn`**  
    Omitting the `dyn` keyword will result in a compile-time error in newer versions of Rust.
    
2. **Performance Cost**  
    Trait objects incur a slight runtime cost due to dynamic dispatch, so avoid them in performance-critical paths.
    
3. **Limited Functionality**  
    Since trait objects cannot use methods with generics, their functionality can sometimes feel restricted.


# Smart Pointers

## Strong vs Weak Reference

The terms **"downgrade"** and **"upgrade"** in Rust's `std::sync::Arc` (or `Rc`) types are metaphors that describe the relationship between strong and weak references and their intended roles.

---

**Strong vs. Weak References**
1. **Strong Reference (`Arc` or `Rc`)**:
   - Keeps the data it points to alive.
   - Increments the strong reference count.
   - Ownership is shared, meaning the data won’t be deallocated until the last strong reference is dropped.

2. **Weak Reference (`Weak`)**:
   - Does *not* keep the data alive.
   - Does not increment the strong reference count.
   - Can be used to avoid circular references and check if the data is still valid.

---

### **Why "Downgrade"?**
The method `.downgrade()` converts a **strong reference** (`Arc` or `Rc`) into a **weak reference** (`Weak`).

This is called "downgrade" because:
1. **Less Control**: A `Weak` reference is less powerful than a strong reference since it doesn’t contribute to the ownership or prevent the data from being dropped.
2. **Reduced Responsibility**: By downgrading, you're signaling that this reference will not take part in managing the lifetime of the data.

Think of it as "stepping down" from a role that ensures the data's existence to one that merely observes its state.

---

### **Why "Upgrade"?**
The method `.upgrade()` converts a **weak reference** (`Weak`) back into a **strong reference** (`Option<Arc>` or `Option<Rc>`), but only if the data is still alive.

This is called "upgrade" because:
1. **More Control**: Upgrading makes the reference contribute to keeping the data alive again, which is a stronger role.
2. **Increased Responsibility**: By upgrading, you're taking on the task of managing the data's lifetime.

If the underlying data has already been dropped (because all strong references were dropped), the upgrade fails and returns `None`.

---

**Analogy**
Imagine managing a shared resource (like a document):
- A **strong reference** is like being a co-owner of the document. As long as at least one co-owner exists, the document remains in circulation.
- A **weak reference** is like having a view-only link to the document. You can see if the document still exists, but you don’t affect whether it’s kept alive or not.

When you "downgrade," you stop being an owner and only keep a view-only link. When you "upgrade," you request ownership again, but this is only possible if the document hasn’t been destroyed.

---

**Example**
Here’s how the downgrade/upgrade relationship works in Rust:

```rust
use std::sync::{Arc, Weak};

let strong = Arc::new(42); // Create a strong reference
let weak: Weak<i32> = Arc::downgrade(&strong); // Downgrade to weak

println!("Strong count: {}", Arc::strong_count(&strong)); // Strong count: 1
println!("Weak count: {}", Arc::weak_count(&strong));    // Weak count: 1

if let Some(upgraded) = weak.upgrade() { // Try upgrading the weak reference
    println!("Upgraded value: {}", *upgraded); // Upgraded value: 42
} else {
    println!("The data has been dropped!");
}

drop(strong); // Drop the strong reference
if weak.upgrade().is_none() {
    println!("The data has been dropped, weak reference cannot upgrade.");
}
```

---

**Summary**
- **Downgrade** reflects the **weaker role** and **reduced responsibility** of a `Weak` reference.
- **Upgrade** reflects the **stronger role** and **increased responsibility** of a `Strong` reference.

These terms capture the hierarchy of responsibility and ownership in Rust's memory management system.

## `Weak`

In Rust, `Weak` is a smart pointer type provided by the `std::sync` or `std::rc` modules. It represents a **weak reference** to data managed by `Arc` (for thread-safe shared ownership) or `Rc` (for single-threaded shared ownership). 

Unlike `Arc` or `Rc`, `Weak` does **not contribute to the strong reference count** and does not keep the underlying data alive. It's primarily used to avoid **reference cycles**, which can lead to memory leaks.

---

**Key Features of `Weak`**
1. **No Ownership**:
   - A `Weak` reference doesn’t own the data, so it doesn’t prevent the data from being dropped.

2. **Upgrade**:
   - A `Weak` reference can be upgraded to a strong reference (`Arc` or `Rc`) if the data is still valid. If the data has already been dropped, upgrading returns `None`.

3. **Use Case**:
   - Avoiding **cyclic references** in data structures like graphs or trees.

---

**How `Weak` Works Internally**
- When you create a `Weak` reference using `.downgrade()`, the `weak_count` is incremented.
- When the last `Arc` or `Rc` (strong reference) is dropped, the data is deallocated, but the control block (containing the `weak_count`) remains until all `Weak` references are dropped.

---

**Common Methods**
Here are some key methods provided by `Weak`:

1. **`Arc::downgrade` or `Rc::downgrade`**:
   Converts a strong reference into a `Weak` reference.
   ```rust
   let arc = Arc::new(42);
   let weak = Arc::downgrade(&arc);
   ```

2. **`Weak::upgrade`**:
   Attempts to upgrade a `Weak` reference back into a strong reference. Returns `Some(Arc)` if the data is still alive, or `None` if it has been dropped.
   ```rust
   if let Some(strong) = weak.upgrade() {
       println!("Data is still alive: {}", *strong);
   } else {
       println!("Data has been dropped.");
   }
   ```

3. **`Weak::strong_count`**:
   Returns the number of strong references (`Arc` or `Rc`) currently holding the data.

4. **`Weak::weak_count`**:
   Returns the number of `Weak` references currently pointing to the data.

---

**Example: Avoiding Cyclic References**
Consider a scenario where two nodes in a tree structure point to each other, creating a reference cycle:

Without `Weak` (Memory Leak):
```rust
use std::rc::Rc;

struct Node {
    value: i32,
    next: Option<Rc<Node>>,
}

let node1 = Rc::new(Node { value: 1, next: None });
let node2 = Rc::new(Node { value: 2, next: Some(node1.clone()) });

// Creating a cycle
if let Some(next) = &node2.next {
    let _cycle = Rc::new(Node { value: 3, next: Some(node2.clone()) });
}
```

This code causes a **memory leak** because `Rc` creates a cycle, and neither reference will ever drop to `0`.

With `Weak`:
```rust
use std::rc::{Rc, Weak};

struct Node {
    value: i32,
    next: Option<Rc<Node>>,
    prev: Option<Weak<Node>>,
}

let node1 = Rc::new(Node { value: 1, next: None, prev: None });
let node2 = Rc::new(Node { 
    value: 2, 
    next: Some(node1.clone()), 
    prev: None,
});

// Break the cycle with `Weak`
if let Some(next) = &node2.next {
    let node1_weak = Rc::downgrade(&node2);
    let _cycle = Rc::new(Node { value: 3, next: Some(node2.clone()), prev: Some(node1_weak) });
}
```

Here, `Weak` prevents a reference cycle by not contributing to the `strong_count`, allowing memory to be freed.

---

**Important Notes**
- You **must upgrade** a `Weak` reference before you can use the underlying data. Always check if the upgrade was successful.
- `Weak` references are useful in scenarios where you need a **non-owning pointer** (e.g., in parent-child relationships in data structures).

---

**Thread-Safe Example with `Arc`**
```rust
use std::sync::{Arc, Weak};
use std::thread;

let arc = Arc::new(42);
let weak = Arc::downgrade(&arc);

let handle = thread::spawn(move || {
    if let Some(strong) = weak.upgrade() {
        println!("Value: {}", *strong); // Access value
    } else {
        println!("Value has been dropped.");
    }
});

drop(arc); // Drop the strong reference
handle.join().unwrap(); // Ensure the thread finishes
```

In this example, the `Weak` reference allows the thread to safely check whether the value is still alive.

---

`Weak` is a powerful tool for managing shared memory in Rust without creating unintended ownership cycles or memory leaks.


---

Alright, let’s dive into **`Box<T>`** — one of Rust’s simplest but most fundamental smart pointers.

---

## `Box<T>`

* A **smart pointer** that stores data on the **heap** instead of the stack.
* Owns its contents — when the `Box` is dropped, the heap memory is freed.
* Zero runtime overhead: it’s just a pointer (like `*T`), but safe and with ownership semantics.

---

### Why use `Box<T>`?

1. **Move big values off the stack**

   ```rust
   let b = Box::new([0u8; 1_000_000]); // big array on the heap
   ```

   Keeps your stack small.

2. **Recursive types**
   Rust needs to know the size of every type at compile time. Recursive enums (like linked lists or trees) don’t have a known size unless you put recursive parts in a `Box`.

   ```rust
   enum List {
       Cons(i32, Box<List>),
       Nil,
   }
   ```

3. **Trait objects**
   To do dynamic dispatch with `dyn Trait`, you usually need heap allocation via `Box<dyn Trait>`.

---

### Memory layout

When you write:

```rust
let x = Box::new(42);
```

* On the **heap**: the value `42` is stored.
* On the **stack**: the `Box` itself (a pointer to the heap allocation).

```
Stack              Heap
 -----             -----
| ptr |   ----->  | 42 |
 -----             -----
```

When `x` goes out of scope, Rust:

1. Drops the value on the heap.
2. Frees the heap memory.

---

**Example**

```rust
fn main() {
    let x = Box::new(10);
    println!("x = {}", x); // behaves like &i32
} // x is dropped → 10 on heap is freed
```

Output:

```
x = 10
```

---

### Key traits

* `Deref` → lets you use `*x` or call methods on the inner value directly.
* `Drop` → automatically frees memory.
* `Send` / `Sync` → if `T` is thread-safe, `Box<T>` is too.

---

**Analogy**

Think of `Box<T>` like renting a **storage unit**:

* Your house (stack) has limited space.
* If something is too big, you rent a storage unit (heap).
* You keep the **key (pointer)** in your pocket.
* When you’re done, you return the unit (free memory).

---

✅ So in short:

* `Box<T>` = heap allocate a single value.
* Useful for big values, recursive types, and trait objects.
* Cheap and simple — just one heap allocation and one pointer on the stack.

---

# Raw Pointers

## Conversion Into Raw Pointers

In Rust, various smart pointers provide methods to obtain mutable raw pointers. These methods are useful when working with FFI or performing manual memory manipulation while ensuring safe access. Below is a breakdown of **`as_mut_ptr`** and other similar methods.

---

### **`as_mut_ptr()` Methods**
These methods allow you to obtain a **mutable raw pointer** to the underlying value of a smart pointer or collection.

`**Box<T>::as_mut_ptr()**`
- Returns a mutable raw pointer to the contained value.
- Unlike `Box::into_raw`, this does **not** consume the `Box`, so it remains valid.

Example:
```rust
let mut boxed = Box::new(42);
let ptr: *mut i32 = boxed.as_mut_ptr();

// Mutate value via pointer
unsafe {
    *ptr = 100;
}

println!("Updated Boxed value: {}", boxed); // 100
```

---

**`Vec<T>::as_mut_ptr()`**
- Returns a raw mutable pointer to the start of the vector's buffer.
- The pointer is valid as long as the `Vec` is not reallocated (e.g., by `push` past capacity).

Example:
```rust
let mut vec = vec![1, 2, 3];
let ptr: *mut i32 = vec.as_mut_ptr();

// Modify first element via pointer
unsafe {
    *ptr = 99;
}

println!("Updated vector: {:?}", vec); // [99, 2, 3]
```

---

**`String::as_mut_ptr()`**
- Returns a mutable pointer to the start of the `String`'s buffer.

Example:
```rust
let mut s = String::from("Hello");
let ptr: *mut u8 = s.as_mut_ptr();

// Modify first character (requires `set_len` to avoid bounds checks)
unsafe {
    *ptr = b'J';
    s.as_mut_vec().set_len(5); // Ensure length remains valid
}

println!("Modified string: {}", s); // "Jello"
```

---

### **`as_ptr()` Methods**

- **`as_ptr()`** – Gets a read-only pointer to the data.
  - `Box<T>::as_ptr() -> *const T`
  - `Vec<T>::as_ptr() -> *const T`
  - `String::as_ptr() -> *const u8`
  
  Example:
  ```rust
  let vec = vec![10, 20, 30];
  let ptr = vec.as_ptr();

  unsafe {
      println!("First element: {}", *ptr); // 10
  }
  ```


## Conversion Between Smart And Raw Pointers

In Rust, `Box`, `Rc`, and `Arc` provide methods for converting to and from raw pointers. These conversions are useful when interfacing with unsafe code (e.g., FFI) but must be handled carefully to avoid memory leaks or double frees.

---

### **1. `Box<T>` Conversions**
`Box<T>` is a heap-allocated value that provides methods for conversion to and from raw pointers.

**To raw pointer**
- **`Box::into_raw(boxed: Box<T>) -> *mut T`**  
  - Consumes the `Box`, returning a raw pointer.
  - The caller is responsible for managing the memory.

```rust
let boxed = Box::new(10);
let raw: *mut i32 = Box::into_raw(boxed);
println!("Raw pointer: {:?}", raw);
```

**From raw pointer**
- **`Box::from_raw(ptr: *mut T) -> Box<T>`** *(unsafe)*
  - Converts a raw pointer back into a `Box`, taking ownership.
  - The pointer **must** have been created by `Box::into_raw`.

```rust
let boxed = Box::new(20);
let raw = Box::into_raw(boxed);

unsafe {
    let boxed_again = Box::from_raw(raw);
    println!("Recovered value: {}", boxed_again);
}
```

---

### **2. `Rc<T>` Conversions**
`Rc<T>` is a reference-counted smart pointer for single-threaded use.

**To raw pointer**
- **`Rc::into_raw(rc: Rc<T>) -> *const T`**  
  - Consumes the `Rc` and returns a raw pointer.
  - The reference count is **not decremented**.

```rust
use std::rc::Rc;

let rc = Rc::new(30);
let raw: *const i32 = Rc::into_raw(rc);
println!("Raw pointer: {:?}", raw);
```

**From raw pointer**
- **`Rc::from_raw(ptr: *const T) -> Rc<T>`** *(unsafe)*
  - Creates an `Rc` from a raw pointer.
  - **Does not** increment the reference count, so the pointer must be valid.

```rust
use std::rc::Rc;

let rc = Rc::new(40);
let raw = Rc::into_raw(Rc::clone(&rc));

unsafe {
    let rc_again = Rc::from_raw(raw);
    println!("Recovered value: {}", rc_again);
}
```

---

### **3. `Arc<T>` Conversions**
`Arc<T>` is an atomic reference-counted smart pointer for multi-threaded use.

**To raw pointer**
- **`Arc::into_raw(arc: Arc<T>) -> *const T`**  
  - Converts an `Arc` into a raw pointer.
  - The reference count is not decremented.

```rust
use std::sync::Arc;

let arc = Arc::new(50);
let raw: *const i32 = Arc::into_raw(arc);
println!("Raw pointer: {:?}", raw);
```

**From raw pointer**
- **`Arc::from_raw(ptr: *const T) -> Arc<T>`** *(unsafe)*
  - Converts a raw pointer back into an `Arc`.
  - Does not increment the reference count.

```rust
use std::sync::Arc;

let arc = Arc::new(60);
let raw = Arc::into_raw(Arc::clone(&arc));

unsafe {
    let arc_again = Arc::from_raw(raw);
    println!("Recovered value: {}", arc_again);
}
```

---

### **4. `NonNull<T>` for Non-Zero Raw Pointers**
`NonNull<T>` is a wrapper around `*mut T` that guarantees the pointer is never null.

- **`Box<T>::into_raw_non_null(Box<T>) -> NonNull<T>`**
- **`Rc<T>::into_raw_non_null(Rc<T>) -> NonNull<T>`**
- **`Arc<T>::into_raw_non_null(Arc<T>) -> NonNull<T>`**

Example:

```rust
use std::ptr::NonNull;

let boxed = Box::new(70);
let non_null = NonNull::new(Box::into_raw(boxed)).unwrap();
println!("Non-null pointer: {:?}", non_null);
```

---

### **Safety Considerations**
- When converting a smart pointer into a raw pointer, **do not deallocate it manually** unless ownership is transferred back using `from_raw`.
- `from_raw` must only be called **once** per raw pointer, or memory will be freed multiple times.
- `Rc` and `Arc` rely on reference counting, so dropping the last strong reference will **deallocate the value**, making the raw pointer **dangling**.

---

**Summary Table**

| Smart Pointer | To Raw Pointer | From Raw Pointer |
|--------------|------------------------|----------------------|
| **`Box<T>`** | `Box::into_raw(Box<T>) -> *mut T` | `Box::from_raw(*mut T) -> Box<T>` |
| **`Rc<T>`**  | `Rc::into_raw(Rc<T>) -> *const T` | `Rc::from_raw(*const T) -> Rc<T>` |
| **`Arc<T>`** | `Arc::into_raw(Arc<T>) -> *const T` | `Arc::from_raw(*const T) -> Arc<T>` |
| **`NonNull<T>`** | `Box::into_raw_non_null(Box<T>) -> NonNull<T>` | `NonNull::new(ptr: *mut T) -> Option<NonNull<T>>` |

These methods allow for safe and efficient interoperability with raw pointers when necessary.

## `NonNull`

`NonNull<T>` is a wrapper around `*mut T` (a raw pointer) that **guarantees** the pointer is **never null**. It is useful for working with raw pointers in a safe way while avoiding `Option<T>`-wrapped pointers (which require extra space for the `None` case).

---

### **Creating a `NonNull<T>`**
You can create a `NonNull<T>` from an existing reference, `Box<T>`, or raw pointer.

**Using `NonNull::new()`**
`NonNull::new(ptr: *mut T) -> Option<NonNull<T>>`
- If the pointer is `null`, returns `None`.
- Otherwise, returns `Some(NonNull<T>)`.

Example:
```rust
use std::ptr::NonNull;

let mut value = 42;
let ptr: *mut i32 = &mut value;
let non_null = NonNull::new(ptr).unwrap();

println!("NonNull pointer: {:?}", non_null);
```

---

**Using `NonNull::from()`**
`NonNull::from(reference: &mut T) -> NonNull<T>`
- Converts a reference into a `NonNull<T>`, ensuring it is never null.

#### Example:
```rust
use std::ptr::NonNull;

let mut value = 100;
let non_null = NonNull::from(&mut value);

println!("NonNull pointer: {:?}", non_null);
```

---

### **Using `NonNull<T>`**
Since `NonNull<T>` ensures the pointer is non-null, it is useful for handling raw pointers safely.

**Dereferencing a `NonNull<T>`**
Since `NonNull<T>` does not implement `Deref`, you must **explicitly dereference** it using `as_ptr()`.

Example:
```rust
use std::ptr::NonNull;

let mut value = 7;
let non_null = NonNull::from(&mut value);

unsafe {
    *non_null.as_ptr() = 42; // Modifying value via NonNull
}

println!("Updated value: {}", value); // 42
```

---

### **`NonNull<T>` vs. Raw Pointers**
| Feature        | `*mut T` / `*const T` | `NonNull<T>` |
|---------------|----------------|-------------|
| Can be null?  | Yes            | No          |
| Safe to use?  | No (unsafe)     | Yes (ensures non-null) |
| Size overhead | No extra space  | No extra space |
| Dereferencing | `unsafe`        | `unsafe`    |

---

### **Use Cases for `NonNull<T>`**
- **Intrusive data structures** (e.g., linked lists).
- **Custom smart pointers** where null pointers are invalid.
- **FFI (Foreign Function Interface)** where nullable pointers should be avoided.

---

**Example: Using `NonNull<T>` in a Custom Smart Pointer**

Here’s how `NonNull<T>` can be used in a custom **reference-counted** smart pointer.

```rust
use std::ptr::NonNull;
use std::alloc::{alloc, dealloc, Layout};
use std::mem;

struct MyBox<T> {
    ptr: NonNull<T>,
}

impl<T> MyBox<T> {
    fn new(value: T) -> Self {
        let layout = Layout::new::<T>();
        unsafe {
            let raw_ptr = alloc(layout) as *mut T;
            if raw_ptr.is_null() {
                panic!("Allocation failed");
            }
            raw_ptr.write(value);
            MyBox { ptr: NonNull::new(raw_ptr).unwrap() }
        }
    }

    fn get(&self) -> &T {
        unsafe { self.ptr.as_ref() }
    }
}

impl<T> Drop for MyBox<T> {
    fn drop(&mut self) {
        let layout = Layout::new::<T>();
        unsafe {
            dealloc(self.ptr.as_ptr() as *mut u8, layout);
        }
    }
}

fn main() {
    let my_box = MyBox::new(123);
    println!("MyBox contains: {}", my_box.get());
}
```
This example manually manages memory while ensuring `ptr` is always valid.

---

**Conclusion**
- `NonNull<T>` is a safer alternative to raw pointers, ensuring they are never null.
- It is useful for FFI, custom smart pointers, and intrusive data structures.
- Unlike `*mut T`, `NonNull<T>` prevents accidental null dereferences, reducing unsafe errors.

## Raw Pointer Methods

| Method                     | Description |
|----------------------------|-------------|
| **`is_null()`**            | Checks if the pointer is null. |
| **`as_ref()`**             | Converts `*const T` into `Option<&T>`. |
| **`as_mut()`**             | Converts `*mut T` into `Option<&mut T>`. |
| **`add(offset)`**          | Offsets a pointer by `offset` elements (like array indexing). |
| **`offset(count)`**        | Similar to `add()`, but allows negative offsets. |
| **`read()`**               | Reads the value at the pointer location. |
| **`write(val)`**           | Writes a value to the pointer location. |
| **`copy_to(dest, count)`** | Copies `count` elements from one pointer to another. |
| **`copy_nonoverlapping(dest, count)`** | Like `copy_to()`, but for non-overlapping memory. |

---


### **Checking for Null (`is_null()`)**

```rust
let ptr: *const i32 = std::ptr::null();
if ptr.is_null() {
    println!("Pointer is null");
}
```

### **Converting to References (`as_ref()`, `as_mut()`)**

- **`as_ref()`**: Converts `*const T` to `Option<&T>` (safe to use).
- **`as_mut()`**: Converts `*mut T` to `Option<&mut T>`.

```rust
let value = 50;
let ptr: *const i32 = &value;

if let Some(reference) = unsafe { ptr.as_ref() } {
    println!("Dereferenced value: {}", reference);
}
```

---

### **Pointer Arithmetic (`add()`, `offset()`)**

These methods are useful for iterating over memory blocks.

```rust
let array = [10, 20, 30];
let ptr: *const i32 = array.as_ptr();

unsafe {
    println!("First: {}", *ptr);
    println!("Second: {}", *ptr.add(1));
    println!("Third: {}", *ptr.offset(2));
}
```

> **Note:** `offset()` allows negative indices, while `add()` does not.

---

### **Reading and Writing Values (`read()`, `write()`)**
- **`read()`**: Reads a value without consuming the original ownership.
- **`write()`**: Writes to a memory location.

```rust
let mut value = 99;
let ptr: *mut i32 = &mut value;

unsafe {
    ptr.write(42);
    println!("Updated value: {}", ptr.read());
}
```

---

### **Copying Memory (`copy_to()`, `copy_nonoverlapping()`)**
- `copy_to()` allows overlapping memory (like `memmove` in C).
- `copy_nonoverlapping()` assumes non-overlapping regions (like `memcpy`).

```rust
use std::ptr;

let mut src = [1, 2, 3];
let mut dst = [0; 3];

unsafe {
    ptr::copy_nonoverlapping(src.as_ptr(), dst.as_mut_ptr(), 3);
}

println!("Copied array: {:?}", dst); // [1, 2, 3]
```

---

**Example: Using Raw Pointers in a Custom Struct**

```rust
use std::ptr;
use std::alloc::{alloc, dealloc, Layout};

struct RawBox {
    ptr: *mut i32,
}

impl RawBox {
    fn new(value: i32) -> Self {
        let layout = Layout::new::<i32>();
        unsafe {
            let ptr = alloc(layout) as *mut i32;
            if ptr.is_null() {
                panic!("Allocation failed");
            }
            ptr.write(value);
            RawBox { ptr }
        }
    }

    fn get(&self) -> i32 {
        unsafe { self.ptr.read() }
    }
}

impl Drop for RawBox {
    fn drop(&mut self) {
        let layout = Layout::new::<i32>();
        unsafe {
            dealloc(self.ptr as *mut u8, layout);
        }
    }
}

fn main() {
    let raw_box = RawBox::new(123);
    println!("Stored value: {}", raw_box.get());
}
```
Here, `RawBox` manually allocates and deallocates memory using raw pointers.

---

### **Pointer Validation and Conversion**
These methods help with checking and converting raw pointers.

#### **`is_aligned()`** *(Nightly-only)*
- Checks if a pointer is properly aligned for its type.
- Similar to `ptr.align_offset(align) == 0`.

```rust
#![feature(ptr_is_aligned)] // Nightly feature

let x = 10;
let ptr = &x as *const i32;

assert!(ptr.is_aligned());
```

---

#### **`align_offset(align: usize) -> usize`**
- Returns how many bytes the pointer is misaligned by.
- Useful for working with SIMD or manually allocated memory.

```rust
let x = 10;
let ptr = &x as *const i32;

let alignment = ptr.align_offset(4);
println!("Alignment offset: {}", alignment); // Should be 0
```

---

#### **`guaranteed_eq(ptr2) -> bool`** *(Nightly-only)*
- Checks if two pointers **definitely** point to the same address.
- More strict than `ptr1 == ptr2`.

```rust
#![feature(ptr_guaranteed_eq)] // Nightly feature

let x = 42;
let ptr1 = &x as *const i32;
let ptr2 = &x as *const i32;

assert!(ptr1.guaranteed_eq(ptr2));
```

---

### **Pointer Arithmetic and Address Manipulation**
These methods allow moving, checking, and modifying pointer addresses.

#### **`wrapping_add(n) -> *const T / *mut T`**
- Moves the pointer forward by `n` elements.
- Unlike `add()`, **it does not panic on overflow**.

```rust
let arr = [1, 2, 3];
let ptr = arr.as_ptr();

unsafe {
    let new_ptr = ptr.wrapping_add(1);
    println!("Second element: {}", *new_ptr); // 2
}
```

---

#### **`wrapping_offset(n) -> *const T / *mut T`**
- Moves the pointer forward/backward by `n` elements.
- Unlike `offset()`, it does **not** cause UB (Undefined Behavior) on out-of-bounds moves.

```rust
let arr = [10, 20, 30];
let ptr = arr.as_ptr();

unsafe {
    let new_ptr = ptr.wrapping_offset(2);
    println!("Third element: {}", *new_ptr); // 30
}
```

---

#### **`cast<U>() -> *const U / *mut U`**
- Casts a pointer to another type.
- Useful when working with raw bytes (`u8`) or FFI.

```rust
let x: i32 = 123;
let ptr = &x as *const i32;
let byte_ptr = ptr.cast::<u8>(); // Now it's a pointer to a byte
```

---

### **Memory Operations**
These methods are useful for working with **manual memory management**.

#### **`swap(ptr2)`**
- Swaps the values at two valid pointers.

```rust
use std::ptr;

let mut a = 10;
let mut b = 20;

unsafe {
    ptr::swap(&mut a, &mut b);
}

println!("a: {}, b: {}", a, b); // a: 20, b: 10
```

---

#### **`replace(val) -> T`**
- Replaces the value at the pointer and returns the old value.
- Works like `std::mem::replace()` but for raw pointers.

```rust
use std::ptr;

let mut x = 100;
let ptr = &mut x as *mut i32;

unsafe {
    let old = ptr.replace(200);
    println!("Old: {}, New: {}", old, *ptr); // Old: 100, New: 200
}
```

---

#### **`drop_in_place()`**
- Drops the value at a pointer **without deallocating**.
- Used for manual memory management.

```rust
use std::ptr;

let mut x = String::from("Hello");
let ptr = &mut x as *mut String;

unsafe {
    ptr::drop_in_place(ptr);
}

// x is no longer valid after drop_in_place
```

---

### **Unsafe Dereferencing**
### **`read_volatile()` and `write_volatile()`**
- Used to **read/write** memory that can be changed by **hardware** or **concurrent processes**.
- Common in embedded systems and low-level FFI.

```rust
use std::ptr;

let mut value = 42;
let ptr = &mut value as *mut i32;

unsafe {
    let v = ptr::read_volatile(ptr);
    println!("Read volatile: {}", v);

    ptr::write_volatile(ptr, 99);
    println!("Updated volatile: {}", value);
}
```

---

**Summary of Raw Pointer Methods**

| Method                                                     | Description                                  |
| ---------------------------------------------------------- | -------------------------------------------- |
| **Pointer Checks**                                         |                                              |
| `is_null()`                                                | Returns `true` if pointer is null.           |
| `is_aligned()` *(Nightly)*                                 | Checks if pointer is properly aligned.       |
| `align_offset(n)`                                          | Checks memory alignment offset.              |
| `guaranteed_eq(ptr2)` *(Nightly)*                          | Ensures two pointers are equal.              |
| **Pointer Arithmetic**                                     |                                              |
| `add(n)`, `offset(n)`                                      | Moves pointer by `n` elements (unsafe).      |
| `wrapping_add(n)`, `wrapping_offset(n)`                    | Moves pointer by `n` safely (no UB).         |
| **Dereferencing & Memory Operations**                      |                                              |
| `read()`, `write(val)`                                     | Reads/writes a value at the pointer.         |
| `read_volatile()`, `write_volatile()`                      | Read/write for volatile memory.              |
| `swap(ptr2)`                                               | Swaps values at two pointers.                |
| `replace(val) -> T`                                        | Replaces value at pointer, returns old.      |
| `drop_in_place()`                                          | Drops the value without deallocating.        |
| **Copying and Moving**                                     |                                              |
| `copy_to(dest, count)`, `copy_nonoverlapping(dest, count)` | Copies memory safely.                        |
| `copy_to_nonoverlapping(dest, count)`                      | Faster but requires non-overlapping regions. |
| **Conversions**                                            |                                              |
| `cast<U>()`                                                | Converts `*mut T` to `*mut U`.               |


# Concurrency

## `std::sync::atomic`

The `std::sync::atomic` module in Rust provides **atomic types and operations**, which allow you to perform thread-safe, low-level operations on shared data without the need for locks. These atomic operations are fundamental building blocks for concurrency and are supported directly by hardware instructions, making them highly efficient.

---

**Key Concepts**
1. **Atomic Operations**:
   - Operations like load, store, and compare-and-swap are guaranteed to be performed atomically, meaning no other thread can interrupt or observe them in an inconsistent state.

2. **Lock-Free**:
   - Unlike mutexes, atomic operations don’t require locking, so they avoid thread contention but have limited functionality compared to locks.

3. **Memory Ordering**:
   - You can specify how memory accesses are ordered relative to atomic operations using memory orderings like `Relaxed`, `Acquire`, and `Release`.

4. **Use Case**:
   - Atomics are often used in scenarios where low-level, fine-grained control over shared state is required, such as implementing custom synchronization primitives, counters, or flags.

---

### **Atomic Types**
The atomic types in `std::sync::atomic` include:

1. **Atomic Integer Types**:
   - `AtomicI8`, `AtomicI16`, `AtomicI32`, `AtomicI64`, `AtomicI128`
   - `AtomicU8`, `AtomicU16`, `AtomicU32`, `AtomicU64`, `AtomicU128`

2. **Atomic Pointer**:
   - `AtomicPtr<T>`: A type for atomic operations on raw pointers.

3. **Atomic Boolean**:
   - `AtomicBool`: Used for atomic boolean operations.

4. **Generic Atomic Type**:
   - `AtomicIsize` and `AtomicUsize`: Architecture-dependent integer sizes for atomic operations.

---

### **Key Methods**
Most atomic types share the following methods:

1. **Load**:
   Reads the value atomically.

   ```rust
   let atomic = std::sync::atomic::AtomicU32::new(5);
   let value = atomic.load(std::sync::atomic::Ordering::SeqCst);
   ```

2. **Store**:
   Writes a value atomically.

   ```rust
   atomic.store(10, std::sync::atomic::Ordering::SeqCst);
   ```

3. **Compare and Swap (Deprecated)**:
   Compares the current value with a given value and swaps it if they’re equal. Use `compare_exchange` instead.

4. **Compare Exchange**:
   Atomically compares the value and updates it if the comparison succeeds.
   - `compare_exchange`: Fails with a specified ordering on failure.
   - `compare_exchange_weak`: May spuriously fail, useful in loops for optimization.

   ```rust
   if atomic.compare_exchange(5, 15, Ordering::SeqCst, Ordering::SeqCst).is_ok() {
       println!("Value updated successfully!");
   }
   ```

5. **Fetch Operations**:
   These modify the value and return the old value:
   - `fetch_add`: Adds a value.
   - `fetch_sub`: Subtracts a value.
   - `fetch_or`: Performs a bitwise OR.
   - `fetch_and`: Performs a bitwise AND.
   - `fetch_xor`: Performs a bitwise XOR.

   ```rust
   let old_value = atomic.fetch_add(1, std::sync::atomic::Ordering::SeqCst);
   println!("Old value: {}", old_value);
   ```

---

### **Memory Ordering**
Atomic operations can be ordered using memory orderings:
1. **`Relaxed`**:
   - No guarantees about memory ordering.
   - Only ensures atomicity of the operation itself.

2. **`Acquire`**:
   - Ensures that subsequent reads and writes cannot be reordered before this load.

3. **`Release`**:
   - Ensures that previous reads and writes cannot be reordered after this store.

4. **`AcqRel`** (Acquire-Release):
   - Combines the properties of `Acquire` and `Release`.

5. **`SeqCst`** (Sequentially Consistent):
   - Strongest guarantee; ensures a single global order of all atomic operations.

---

**Examples**

Incrementing a Counter Across Threads
```rust
use std::sync::atomic::{AtomicUsize, Ordering};
use std::thread;

fn main() {
    let counter = AtomicUsize::new(0);
    let handles: Vec<_> = (0..10).map(|_| {
        let counter_ref = &counter;
        thread::spawn(move || {
            for _ in 0..1000 {
                counter_ref.fetch_add(1, Ordering::SeqCst);
            }
        })
    }).collect();

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Final count: {}", counter.load(Ordering::SeqCst));
}
```

Implementing a Spinlock with `AtomicBool`
```rust
use std::sync::atomic::{AtomicBool, Ordering};

pub struct Spinlock {
    lock: AtomicBool,
}

impl Spinlock {
    pub fn new() -> Self {
        Self { lock: AtomicBool::new(false) }
    }

    pub fn lock(&self) {
        while self
            .lock
            .compare_exchange(false, true, Ordering::Acquire, Ordering::Relaxed)
            .is_err()
        {}
    }

    pub fn unlock(&self) {
        self.lock.store(false, Ordering::Release);
    }
}

fn main() {
    let spinlock = Spinlock::new();
    spinlock.lock();
    println!("Critical section");
    spinlock.unlock();
}
```

---

**Best Practices**
- Use `SeqCst` unless you’re confident about other orderings.
- Be cautious when using `Relaxed`; it’s tricky to use correctly.
- Only use atomic operations when necessary. Mutexes or higher-level concurrency primitives are often easier to use and less error-prone.

---

Atomics provide powerful, low-level building blocks for concurrency in Rust, enabling fine-grained control over shared data while avoiding the complexity of locking mechanisms.

## `Mutex`

In Rust, a **`Mutex`** (short for mutual exclusion) is a thread-safe mechanism for ensuring that only one thread can access a shared resource at a time. It’s provided by the `std::sync` module and is commonly used in concurrent programming to protect shared data from race conditions.

---

**Key Concepts of Mutex**

1. **Exclusive Access**:
   - Only one thread can hold the lock at any given time, ensuring exclusive access to the shared resource.

2. **Thread Safety**:
   - `Mutex` ensures that operations on the shared resource are safe even when accessed by multiple threads.

3. **Blocking**:
   - If a thread attempts to acquire a lock that is already held by another thread, it will block (wait) until the lock becomes available.

4. **Interior Mutability**:
   - `Mutex` allows you to mutate data even if the `Mutex` itself is immutable because it provides safe, controlled access to the inner data.

---

**Creating a Mutex**

To use a `Mutex`, you wrap the data you want to protect. For example:

```rust
use std::sync::Mutex;

fn main() {
    let m = Mutex::new(5); // Create a Mutex protecting the value 5

    {
        let mut data = m.lock().unwrap(); // Lock the Mutex to access the value
        *data = 10; // Modify the protected value
    } // The lock is automatically released here

    println!("Mutex value: {:?}", m.lock().unwrap());
}
```

---

### **Key Methods**

1. **`Mutex::new`**:
   - Creates a new `Mutex` wrapping the given data.

   ```rust
   let mutex = Mutex::new(42);
   ```

2. **`lock`**:
   - Acquires the lock, blocking the current thread if necessary. Returns a `MutexGuard`, which provides access to the protected data.
   - If another thread panics while holding the lock, `lock` will return an `Err`.

   ```rust
   let guard = mutex.lock().unwrap(); // Acquire lock and access data
   ```

3. **`try_lock`**:
   - Tries to acquire the lock without blocking. Returns a `Result` that indicates success or failure.

   ```rust
   if let Ok(guard) = mutex.try_lock() {
       println!("Lock acquired!");
   } else {
       println!("Could not acquire lock.");
   }
   ```

4. **`into_inner`**:
   - Consumes the `Mutex` and returns the underlying data. This is useful when you no longer need the `Mutex`.

   ```rust
   let data = mutex.into_inner().unwrap();
   ```

---

### **Sharing a Mutex Across Threads**

To use a `Mutex` in a multi-threaded context, you need to wrap it in an `Arc` (atomic reference-counted pointer) so it can be safely shared between threads.

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter); // Clone the Arc to share ownership
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap(); // Acquire the lock
            *num += 1; // Increment the counter
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap(); // Wait for all threads to finish
    }

    println!("Final counter: {}", *counter.lock().unwrap());
}
```

---

### **MutexGuard**
- When you call `lock`, it returns a `MutexGuard`. This is a special wrapper that:
  - Provides access to the data inside the `Mutex`.
  - Automatically releases the lock when it goes out of scope, ensuring that you don’t forget to unlock the `Mutex`.

---

### **Poisoning**
If a thread panics while holding the lock, the `Mutex` is **poisoned** to indicate that the data may be in an invalid state. Future calls to `lock` will return an error unless handled explicitly.

```rust
use std::sync::Mutex;

let m = Mutex::new(42);

// Simulate a panic while holding the lock
{
    let _guard = m.lock().unwrap();
    panic!("Thread panicked!");
}

// Accessing the Mutex again
match m.lock() {
    Ok(guard) => println!("Mutex value: {}", *guard),
    Err(_) => println!("Mutex is poisoned!"),
}
```

---

### **Comparison to `RwLock`**
A `Mutex` is best suited when only one thread needs to access the data at a time. If you have more readers than writers, consider using `RwLock`, which allows multiple readers but only one writer.

---

**Best Practices**
1. Minimize the scope of the lock to avoid blocking other threads unnecessarily.
2. Handle poisoned locks if your program must continue running after a panic.
3. Use `Arc` for sharing `Mutex` across threads.
4. Avoid deadlocks by ensuring locks are always acquired in the same order if you’re locking multiple `Mutex`es.

---

**When to Use a Mutex**
- When you need **mutual exclusion** to protect shared data.
- When thread contention for shared data is low.
- When you can’t use lock-free primitives or atomic types due to complex logic.

## `RwLock`

In Rust, an **`RwLock`** (read-write lock) is a synchronization primitive that allows multiple readers or one writer to access a shared resource. It's part of the `std::sync` module and is useful when you have more read operations than write operations, as it provides better concurrency than a `Mutex` in such cases.

---

**Key Concepts of `RwLock`**

1. **Multiple Readers, Single Writer**:
   - Multiple threads can acquire a **read lock** (`read`) simultaneously.
   - Only one thread can acquire a **write lock** (`write`) at a time, and it blocks all readers and writers until released.

2. **Thread Safety**:
   - Like `Mutex`, `RwLock` ensures safe access to shared resources in multi-threaded programs.

3. **Interior Mutability**:
   - Allows mutation of the inner data even if the `RwLock` itself is immutable, providing controlled access to the data.

---

**Creating and Using `RwLock`**

Here’s an example of using `RwLock`:

```rust
use std::sync::RwLock;

fn main() {
    let lock = RwLock::new(5); // Create an RwLock protecting the value 5

    // Multiple readers can access the lock at the same time
    {
        let r1 = lock.read().unwrap(); // Acquire a read lock
        let r2 = lock.read().unwrap(); // Acquire another read lock
        println!("Read values: {}, {}", *r1, *r2);
    } // Read locks are released here

    // Only one writer can access the lock at a time
    {
        let mut w = lock.write().unwrap(); // Acquire a write lock
        *w += 1; // Modify the protected value
        println!("Updated value: {}", *w);
    } // Write lock is released here
}
```

---

### **Key Methods**

1. **`RwLock::new`**:
   - Creates a new `RwLock` wrapping the given data.

   ```rust
   let lock = RwLock::new(42);
   ```

2. **`read`**:
   - Acquires a read lock, allowing shared access to the data.
   - Blocks if a write lock is held.

   ```rust
   let read_guard = lock.read().unwrap();
   println!("Read value: {}", *read_guard);
   ```

3. **`write`**:
   - Acquires a write lock, allowing exclusive access to the data.
   - Blocks if any read or write lock is held.

   ```rust
   let mut write_guard = lock.write().unwrap();
   *write_guard += 1;
   ```

4. **`try_read`** and **`try_write`**:
   - Non-blocking versions of `read` and `write` that return a `Result`.
   - Useful if you want to avoid blocking.

   ```rust
   if let Ok(read_guard) = lock.try_read() {
       println!("Read value: {}", *read_guard);
   }
   ```

5. **`into_inner`**:
   - Consumes the `RwLock` and returns the underlying data.

   ```rust
   let data = lock.into_inner().unwrap();
   println!("Unlocked data: {}", data);
   ```

---

### **Sharing an `RwLock` Across Threads**

Like `Mutex`, an `RwLock` needs to be wrapped in an `Arc` to share it between threads.

```rust
use std::sync::{Arc, RwLock};
use std::thread;

fn main() {
    let lock = Arc::new(RwLock::new(0));
    let mut handles = vec![];

    // Spawn multiple readers
    for _ in 0..5 {
        let lock_clone = Arc::clone(&lock);
        let handle = thread::spawn(move || {
            let read_guard = lock_clone.read().unwrap();
            println!("Read: {}", *read_guard);
        });
        handles.push(handle);
    }

    // Spawn a writer
    {
        let lock_clone = Arc::clone(&lock);
        let handle = thread::spawn(move || {
            let mut write_guard = lock_clone.write().unwrap();
            *write_guard += 1;
            println!("Written: {}", *write_guard);
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }
}
```

---

### **`RwLockReadGuard` and `RwLockWriteGuard`**

When you acquire a read or write lock, it returns a guard object:
- **`RwLockReadGuard`**: Provides immutable access to the data.
- **`RwLockWriteGuard`**: Provides mutable access to the data.

These guards automatically release the lock when they go out of scope, ensuring proper resource management.

---

### **Poisoning**

Like `Mutex`, an `RwLock` can be poisoned if a thread panics while holding a lock. Subsequent attempts to acquire the lock will return an error unless handled explicitly.

```rust
use std::sync::RwLock;

let lock = RwLock::new(42);

{
    let _write_guard = lock.write().unwrap();
    panic!("Thread panicked while holding the lock!");
}

match lock.read() {
    Ok(guard) => println!("Read value: {}", *guard),
    Err(_) => println!("Lock is poisoned!"),
}
```

---

### **Comparison with `Mutex`**

| Feature           | `RwLock`               | `Mutex`                |
|--------------------|------------------------|------------------------|
| **Readers**        | Multiple simultaneously| Only one at a time     |
| **Writers**        | Only one at a time     | Only one at a time     |
| **Best Use Case**  | More readers than writers | Simple shared state  |
| **Poisoning**      | Yes                   | Yes                   |

If you have frequent writes, prefer `Mutex`. If reads dominate, use `RwLock` for better concurrency.

---

**Best Practices**
1. Minimize the time a lock is held to reduce contention.
2. Use `Arc` for sharing `RwLock` across threads.
3. Handle poisoned locks to recover from panics.
4. Use `RwLock` when read-heavy workloads dominate over writes.

---

**Example: Read-Heavy Scenario**

```rust
use std::sync::{Arc, RwLock};
use std::thread;

fn main() {
    let data = Arc::new(RwLock::new(vec![]));
    let mut handles = vec![];

    // Spawn writers
    for i in 0..2 {
        let data = Arc::clone(&data);
        let handle = thread::spawn(move || {
            let mut write_guard = data.write().unwrap();
            write_guard.push(i);
        });
        handles.push(handle);
    }

    // Spawn readers
    for _ in 0..5 {
        let data = Arc::clone(&data);
        let handle = thread::spawn(move || {
            let read_guard = data.read().unwrap();
            println!("Read data: {:?}", *read_guard);
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }
}
```

---

The `RwLock` is a powerful synchronization primitive in Rust, ideal for scenarios with more readers than writers. It balances thread-safety with performance by allowing concurrent reads while ensuring exclusive access for writes.

# Modules

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

## `std::io`

`std::io` provides **input and output (I/O) functionality**, including:

- **Reading from stdin (keyboard input)**
- **Writing to stdout (console output)**
- **Reading/writing files**
- **Buffered I/O for efficiency**
- **Error handling in I/O operations**

---

### **Basic Standard Input (`stdin`)**

Rust reads user input using `std::io::stdin()` and stores it in a mutable variable.

**Example: Read a String from User Input**

```rust
use std::io;

fn main() {
    let mut input = String::new();

    println!("Enter your name:");
    io::stdin().read_line(&mut input).expect("Failed to read input");

    println!("Hello, {}!", input.trim()); // `.trim()` removes newline
}
```

🔹 **`read_line(&mut input)`** reads user input into `input`.  
🔹 **`.expect("Failed to read input")`** handles errors safely.  
🔹 **`.trim()`** removes the trailing newline (`\n`).

---

### **Basic Standard Output (`stdout`)**

Rust uses `print!`, `println!`, and `eprintln!` for writing output.

|Macro|Description|
|---|---|
|`print!`|Prints without a newline|
|`println!`|Prints with a newline|
|`eprintln!`|Prints to **stderr** (useful for errors)|

 **Example: Printing Output**

```rust
fn main() {
    print!("Hello ");    // No newline
    println!("world!");  // Newline added
    eprintln!("Error: Something went wrong!"); // Prints to stderr
}
```

---

### **Reading Numbers from User Input**

Since `read_line()` reads text, we must **parse** numbers manually.

**Example: Read an Integer**

```rust
use std::io;

fn main() {
    let mut input = String::new();
    println!("Enter a number:");

    io::stdin().read_line(&mut input).expect("Failed to read input");

    let num: i32 = input.trim().parse().expect("Invalid number!");
    println!("You entered: {}", num);
}
```

🔹 **`.parse::<i32>()`** converts the string to an integer.  
🔹 **`.expect("Invalid number!")`** ensures error handling.

---

### **Reading and Writing Files (`std::fs`)**

I/O with files is handled through `std::fs::File` and `std::io::Read`/`Write` traits.

**Example: Reading a File**

```rust
use std::fs::File;
use std::io::{self, Read};

fn main() -> io::Result<()> {
    let mut file = File::open("example.txt")?;  // Open file
    let mut contents = String::new();
    
    file.read_to_string(&mut contents)?;  // Read file contents
    println!("File Contents:\n{}", contents);

    Ok(())
}
```

🔹 **`File::open("example.txt")?`** opens a file, returning `Result<File, Error>`.  
🔹 **`read_to_string(&mut contents)`** reads the whole file into a `String`.

---

### **Writing to a File**

```rust
use std::fs::File;
use std::io::{self, Write};

fn main() -> io::Result<()> {
    let mut file = File::create("output.txt")?; // Create or overwrite file
    file.write_all(b"Hello, Rust!")?; // Write bytes
    Ok(())
}
```

🔹 **`File::create("output.txt")`** creates (or truncates) a file.  
🔹 **`write_all(b"Hello, Rust!")`** writes raw bytes (`b""` denotes a byte string).

---

### **Buffered I/O (`BufReader` and `BufWriter`)**

Buffered I/O improves efficiency when handling large files or streams.

**Example: Buffered File Reading**

```rust
use std::fs::File;
use std::io::{self, BufRead, BufReader};

fn main() -> io::Result<()> {
    let file = File::open("example.txt")?;
    let reader = BufReader::new(file);

    for line in reader.lines() {
        println!("{}", line?);
    }

    Ok(())
}
```

🔹 **`BufReader::new(file)`** wraps `File` for efficient reading.  
🔹 **`for line in reader.lines()`** reads line by line.

**Example: Buffered File Writing**

```rust
use std::fs::File;
use std::io::{self, BufWriter, Write};

fn main() -> io::Result<()> {
    let file = File::create("output.txt")?;
    let mut writer = BufWriter::new(file);

    writeln!(writer, "Hello, Rust!")?; // Writes with a newline
    Ok(())
}
```

🔹 **`BufWriter::new(file)`** wraps `File` for efficient writing.  
🔹 **`writeln!()`** writes a formatted line.

---

### **Handling Errors in I/O**

I/O operations **return `Result<T, io::Error>`**, so proper error handling is important.

**Example: Propagating Errors (`?` Operator)**

```rust
use std::fs::File;
use std::io::{self, Read};

fn read_file() -> io::Result<String> {
    let mut file = File::open("example.txt")?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}

fn main() {
    match read_file() {
        Ok(contents) => println!("{}", contents),
        Err(e) => eprintln!("Error reading file: {}", e),
    }
}
```

🔹 **`?` propagates errors** (returns early if an error occurs).  
🔹 **Using `match`** ensures error messages are displayed.

---

## `std::fs`

The `std::fs` module provides functions for **file system operations**, including:

- **Reading and writing files**
- **Creating and removing files**
- **Creating and managing directories**
- **Copying, renaming, and checking file metadata**

---

### **Reading Files (`fs::read_to_string`)**

To read an entire file into a `String`, use `fs::read_to_string()`.

**Example: Read a File**

```rust
use std::fs;

fn main() -> std::io::Result<()> {
    let contents = fs::read_to_string("example.txt")?;
    println!("File Contents:\n{}", contents);
    Ok(())
}
```

🔹 **`fs::read_to_string("example.txt")?`** reads the entire file as a `String`.  
🔹 **Returns `Result<String, io::Error>`** (use `?` for error handling).

---

### **Writing to a File (`fs::write`)**

To write a string to a file, use `fs::write()`.

**Example: Write to a File**

```rust
use std::fs;

fn main() -> std::io::Result<()> {
    fs::write("output.txt", "Hello, Rust!")?;
    Ok(())
}
```

🔹 **`fs::write("output.txt", "Hello, Rust!")`** writes the string to a file.  
🔹 **Overwrites existing content** (use `OpenOptions` for appending).

---

### **Appending to a File (`OpenOptions`)**

To **append** instead of overwriting, use `std::fs::OpenOptions`.

**Example: Append to a File**

```rust
use std::fs::OpenOptions;
use std::io::Write;

fn main() -> std::io::Result<()> {
    let mut file = OpenOptions::new().append(true).open("output.txt")?;
    writeln!(file, "New line added!")?;
    Ok(())
}
```

🔹 **`OpenOptions::new().append(true).open("output.txt")`** opens the file in append mode.  
🔹 **`writeln!(file, "New line added!")`** writes to the file with a newline.

---

### **Creating and Removing Files (`fs::File`)**

To create an **empty** file, use `fs::File::create()`.

**Example: Create an Empty File**

```rust
use std::fs::File;

fn main() -> std::io::Result<()> {
    File::create("newfile.txt")?;
    Ok(())
}
```

🔹 **Creates a new empty file** (or overwrites an existing file).

To **delete a file**, use `fs::remove_file()`.

**Example: Delete a File**

```rust
use std::fs;

fn main() -> std::io::Result<()> {
    fs::remove_file("newfile.txt")?;
    Ok(())
}
```

🔹 **`fs::remove_file("newfile.txt")?`** deletes the file.

---

### **Working with Directories (`fs::create_dir`, `fs::remove_dir`)**

To **create** a directory, use `fs::create_dir()`.

**Example: Create a Directory**

```rust
use std::fs;

fn main() -> std::io::Result<()> {
    fs::create_dir("my_folder")?;
    Ok(())
}
```

🔹 **Fails if the directory already exists** (use `create_dir_all()` to avoid this).

To **delete** an empty directory, use `fs::remove_dir()`.

**Example: Delete a Directory**

```rust
use std::fs;

fn main() -> std::io::Result<()> {
    fs::remove_dir("my_folder")?;
    Ok(())
}
```

🔹 **Fails if the directory is not empty** (use `remove_dir_all()` to delete non-empty directories).

To **create nested directories**, use `fs::create_dir_all()`.

```rust
fs::create_dir_all("parent/child/grandchild")?;
```

To **delete a non-empty directory**, use `fs::remove_dir_all()`.

```rust
fs::remove_dir_all("parent")?;
```

---

### **Copying, Moving, and Renaming Files**

#### **Copy a File (`fs::copy`)**

```rust
use std::fs;

fn main() -> std::io::Result<()> {
    fs::copy("source.txt", "destination.txt")?;
    Ok(())
}
```

🔹 **Copies** `source.txt` → `destination.txt`.

#### **Rename/Move a File (`fs::rename`)**

```rust
use std::fs;

fn main() -> std::io::Result<()> {
    fs::rename("old_name.txt", "new_name.txt")?;
    Ok(())
}
```

🔹 **Moves or renames a file** (works across directories too).

---

### **Listing Directory Contents (`fs::read_dir`)**

To list files in a directory, use `fs::read_dir()`.

**Example: List Files in a Directory**

```rust
use std::fs;

fn main() -> std::io::Result<()> {
    for entry in fs::read_dir(".")? {
        let entry = entry?;
        println!("{}", entry.file_name().to_string_lossy());
    }
    Ok(())
}
```

🔹 **`fs::read_dir(".")`** lists entries in the current directory.  
🔹 **`entry.file_name().to_string_lossy()`** gets the file name as a `String`.

---

### **Getting File Metadata (`fs::metadata`)**

To check **file size, type, or permissions**, use `fs::metadata()`.

**Example: Get File Metadata**

```rust
use std::fs;

fn main() -> std::io::Result<()> {
    let metadata = fs::metadata("example.txt")?;
    println!("Size: {} bytes", metadata.len());
    println!("Is file? {}", metadata.is_file());
    println!("Is directory? {}", metadata.is_dir());
    Ok(())
}
```

🔹 **`metadata.len()`** → file size in bytes.  
🔹 **`metadata.is_file()`** → `true` if it's a file.  
🔹 **`metadata.is_dir()`** → `true` if it's a directory.

## `std::env`

In Rust, the `std::env` module provides functions for interacting with the environment of the running program. This includes accessing environment variables, arguments, and other process-related information.

### **Command-Line Arguments**

- `std::env::args()` – Returns an iterator over the arguments passed to the program.
- `std::env::args_os()` – Like `args()`, but returns arguments as `OsString`, which is useful for handling non-UTF-8 arguments.

```rust
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    println!("Arguments: {:?}", args);
}
```

**Example Output:**

```
Arguments: ["./my_program", "arg1", "arg2"]
```

### **Environment Variables**

- `std::env::var("KEY")` – Fetches the value of an environment variable.
- `std::env::set_var("KEY", "VALUE")` – Sets an environment variable.
- `std::env::vars()` – Returns an iterator over all environment variables.

```rust
use std::env;

fn main() {
    env::set_var("MY_VAR", "Hello, Rust!");
    match env::var("MY_VAR") {
        Ok(value) => println!("MY_VAR: {}", value),
        Err(e) => println!("Couldn't read MY_VAR: {}", e),
    }
}
```

**Example Output:**

```
MY_VAR: Hello, Rust!
```

####  `std::env::remove_var("KEY")`

- Removes an environment variable.

```rust
use std::env;

fn main() {
    env::set_var("TEST_VAR", "Rust");
    println!("Before removing: {:?}", env::var("TEST_VAR"));

    env::remove_var("TEST_VAR");
    println!("After removing: {:?}", env::var("TEST_VAR"));
}
```

**Output:**

```
Before removing: Ok("Rust")
After removing: Err(NotPresent)
```

####  `std::env::vars_os()`

- Like `vars()`, but returns an iterator of `OsString`, which helps handle non-UTF-8 variables.

```rust
use std::env;

fn main() {
    for (key, value) in env::vars_os() {
        println!("{:?}: {:?}", key, value);
    }
}
```

### **Working with Paths**

#### `std::env::home_dir()` (Deprecated)

- Used to get the current user's home directory.
- **Deprecated**: Instead, use `dirs::home_dir()` from the [`dirs`](https://crates.io/crates/dirs) crate.

```rust
use dirs;

fn main() {
    if let Some(path) = dirs::home_dir() {
        println!("Home directory: {:?}", path);
    } else {
        println!("Could not determine home directory.");
    }
}
```

####  `std::env::temp_dir()`

- Returns the path to the temporary directory for the system.

```rust
use std::env;

fn main() {
    let temp_dir = env::temp_dir();
    println!("Temporary directory: {:?}", temp_dir);
}
```

**Example Output:**

```
Temporary directory: "/tmp"
```

---

### **Current Directory**

- `std::env::current_dir()` – Gets the current working directory.
- `std::env::set_current_dir("/new/path")` – Changes the current working directory.

```rust
use std::env;

fn main() {
    match env::current_dir() {
        Ok(path) => println!("Current directory: {:?}", path),
        Err(e) => println!("Error getting current directory: {}", e),
    }
}
```

### **Other Path-Related Functions**

#### `std::env::split_paths()`

- Splits a colon-separated (`:`) or semicolon-separated (`;`) path variable into separate paths.

```rust
use std::env;

fn main() {
    let path = "/usr/bin:/bin:/usr/local/bin";
    let paths = env::split_paths(path);

    for p in paths {
        println!("{:?}", p);
    }
}
```

**Output:**

```
"/usr/bin"
"/bin"
"/usr/local/bin"
```

####  `std::env::join_paths()`

- Opposite of `split_paths()`: Joins multiple paths into a single string.

```rust
use std::env;
use std::path::PathBuf;

fn main() {
    let paths = vec![PathBuf::from("/usr/bin"), PathBuf::from("/bin")];
    match env::join_paths(paths) {
        Ok(joined) => println!("Joined path: {:?}", joined),
        Err(e) => println!("Error joining paths: {}", e),
    }
}
```

---

### **Executable Path**

- `std::env::current_exe()` – Gets the full path of the running executable.

```rust
use std::env;

fn main() {
    match env::current_exe() {
        Ok(path) => println!("Executable path: {:?}", path),
        Err(e) => println!("Error getting executable path: {}", e),
    }
}
```
### **System-Specific Information**

####  `std::env::consts`

- Contains constants for the OS, architecture, and executable file extension.

```rust
use std::env;

fn main() {
    println!("OS Family: {}", env::consts::OS);
    println!("Architecture: {}", env::consts::ARCH);
    println!("EXE Extension: {}", env::consts::EXE_EXTENSION);
}
```

**Possible Output on Linux:**

```
OS Family: linux
Architecture: x86_64
EXE Extension: 
```

**Possible Output on Windows:**

```
OS Family: windows
Architecture: x86_64
EXE Extension: .exe
```

---

## `std::thread`

The `std::thread` module in Rust provides functionality for creating and managing threads, enabling concurrent execution of code. Rust threads are lightweight and safe due to Rust’s ownership and borrowing rules, which prevent data races at compile time.

### **Creating a New Thread**

Use `std::thread::spawn` to create a new thread.

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        println!("Hello from a new thread!");
    });

    handle.join().unwrap(); // Wait for the thread to finish
}
```

### **Moving Ownership into a Thread**

Use `move` to transfer ownership of variables into a thread.

```rust
use std::thread;

fn main() {
    let message = String::from("Hello, Rust!");

    let handle = thread::spawn(move || {
        println!("{}", message);
    });

    handle.join().unwrap();
}
```

---

### **Thread Management**

#### **Waiting for a Thread (Joining)**

The `.join()` method blocks execution until the thread completes.

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..5 {
            println!("Thread: {}", i);
        }
    });

    handle.join().unwrap();
    println!("Main thread continues...");
}
```

#### **Detaching a Thread**

If you don't want to wait for a thread to finish, you can let it run independently.

```rust
use std::thread;
use std::time::Duration;

fn main() {
    thread::spawn(|| {
        thread::sleep(Duration::from_secs(2));
        println!("This thread runs independently.");
    });

    println!("Main thread does not wait.");
    thread::sleep(Duration::from_secs(3));
}
```

---

### **Concurrency with Multiple Threads**

#### **Spawning Multiple Threads**

You can create multiple threads using a loop.

```rust
use std::thread;

fn main() {
    let mut handles = vec![];

    for i in 0..5 {
        let handle = thread::spawn(move || {
            println!("Thread {} is running", i);
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }
}
```

---

### **Thread Communication**

#### **Sharing Data Between Threads (Arc)**

Since Rust enforces ownership rules, you cannot share non-thread-safe types like `Rc<T>` between threads. Instead, use `Arc<T>` (Atomic Reference Counted).

```rust
use std::sync::Arc;
use std::thread;

fn main() {
    let data = Arc::new(vec![1, 2, 3, 4, 5]);

    let mut handles = vec![];

    for i in 0..3 {
        let data = Arc::clone(&data);
        let handle = thread::spawn(move || {
            println!("Thread {}: {:?}", i, data);
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }
}
```

---

### **Thread Sleeping and Yielding**

#### **Sleeping a Thread**

Use `thread::sleep` to pause execution.

```rust
use std::thread;
use std::time::Duration;

fn main() {
    println!("Sleeping...");
    thread::sleep(Duration::from_secs(2));
    println!("Awake!");
}
```

#### **Yielding Execution**

`thread::yield_now()` allows the scheduler to run another thread before continuing.

```rust
use std::thread;

fn main() {
    println!("Yielding execution...");
    thread::yield_now();
    println!("Back to execution.");
}
```

#### **Getting Thread Information**

#### **`std::thread::current()` – Get the Current Thread Handle**

Retrieves a handle to the currently executing thread.

```rust
use std::thread;

fn main() {
    let handle = thread::current();
    println!("Current thread: {:?}", handle.name());
}
```

#### **`std::thread::Thread::id()` – Get Thread ID**

Each thread has a unique ID that can be retrieved using `.id()`.

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        let id = thread::current().id();
        println!("Thread ID: {:?}", id);
    });

    handle.join().unwrap();
}
```

---

### **Naming Threads**

Threads can be named using `Builder`.

```rust
use std::thread;

fn main() {
    let handle = thread::Builder::new()
        .name("WorkerThread".to_string())
        .spawn(|| {
            println!("Thread name: {:?}", thread::current().name());
        })
        .unwrap();

    handle.join().unwrap();
}
```

---

### **Custom Stack Size**

You can create a thread with a custom stack size using `Builder`.

```rust
use std::thread;

fn main() {
    let handle = thread::Builder::new()
        .stack_size(4 * 1024 * 1024) // 4MB stack
        .spawn(|| {
            println!("Running with a custom stack size");
        })
        .unwrap();

    handle.join().unwrap();
}
```

---

### **Thread Parking and Unparking**

Threads can be paused and resumed using `thread::park()` and `thread::unpark()`.

#### **Pausing (`park()`) and Resuming (`unpark()`) a Thread**

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let parked_thread = thread::spawn(|| {
        println!("Thread is parking...");
        thread::park(); // This pauses the thread
        println!("Thread resumed!");
    });

    thread::sleep(Duration::from_secs(2));
    parked_thread.thread().unpark(); // Resumes the parked thread

    parked_thread.join().unwrap();
}
```

---

### **Thread Panic Handling**

Threads that panic will not crash the entire program unless `join().unwrap()` is used. You can catch panics using `Result`.

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        panic!("Something went wrong!");
    });

    match handle.join() {
        Ok(_) => println!("Thread completed successfully."),
        Err(e) => println!("Thread panicked: {:?}", e),
    }
}
```

---

## `std::sync`

- **`Arc`** – A thread-safe reference-counting pointer.
- **`Weak`** – A non-owning reference to an `Arc`.
- **`Mutex`** – A mutual exclusion primitive for protecting shared data.
- **`MutexGuard`** – A RAII implementation for `Mutex`, ensuring it is unlocked when dropped.
- **`RwLock`** – A reader-writer lock that allows multiple readers or one writer at a time.
- **`RwLockReadGuard`** – A RAII implementation for the read lock of an `RwLock`.
- **`RwLockWriteGuard`** – A RAII implementation for the write lock of an `RwLock`.
- **`Condvar`** – A condition variable used for thread synchronization.
- **`Once`** – Ensures a piece of code runs only once in a thread-safe manner.
- **`OnceLock`** – A thread-safe, one-time initialization value (more flexible than `Once`).
- **`OnceCell`** – A lazily-initialized, thread-safe storage that can be written once.
- **`Barrier`** – A synchronization primitive that blocks threads until a certain number have reached the barrier.
- [[#`std::sync::atomic`]] – Provides atomic types such as `AtomicBool`, `AtomicUsize`, etc., for lock-free concurrency.

## `std::collections`

`std::collections` is Rust’s standard library module that provides various collection types, including vectors, hash maps, and linked lists. These collections help manage and manipulate groups of data efficiently.

---

### **Common Collections in `std::collections`**

#### **1. `VecDeque<T>` (Double-ended queue)**

A queue that allows efficient addition and removal from both ends.

```rust
use std::collections::VecDeque;

let mut deque: VecDeque<i32> = VecDeque::new();
deque.push_back(1);
deque.push_front(2);
println!("{:?}", deque); // Output: [2, 1]
```

---

#### **2. `LinkedList<T>` (Doubly linked list)**

A doubly linked list allowing efficient insertions and removals anywhere.

```rust
use std::collections::LinkedList;

let mut list = LinkedList::new();
list.push_back(1);
list.push_front(2);
println!("{:?}", list); // Output: [2, 1]
```

---

#### **3. `HashMap<K, V>` (Key-value store with hashing)**

A collection of key-value pairs using a hash table.

```rust
use std::collections::HashMap;

let mut map = HashMap::new();
map.insert("apple", 3);
map.insert("banana", 5);
println!("{:?}", map.get("apple")); // Output: Some(3)
```

---

#### **4. `BTreeMap<K, V>` (Ordered key-value store)**

A key-value store that maintains sorted order.

```rust
use std::collections::BTreeMap;

let mut map = BTreeMap::new();
map.insert(2, "two");
map.insert(1, "one");
println!("{:?}", map); // Output: {1: "one", 2: "two"}
```

---

#### **5. `HashSet<T>` (Unordered collection of unique values)**

A set that stores unique values using hashing.

```rust
use std::collections::HashSet;

let mut set = HashSet::new();
set.insert(10);
set.insert(20);
set.insert(10); // Duplicate ignored
println!("{:?}", set); // Output: {10, 20}
```

---

#### **6. `BTreeSet<T>` (Ordered set of unique values)**

A set that stores unique values in a sorted order.

```rust
use std::collections::BTreeSet;

let mut set = BTreeSet::new();
set.insert(5);
set.insert(1);
set.insert(3);
println!("{:?}", set); // Output: {1, 3, 5}
```

---

#### **7. `BinaryHeap<T>` (Max-heap or min-heap)**

A priority queue implemented as a binary heap.

```rust
use std::collections::BinaryHeap;

let mut heap = BinaryHeap::new();
heap.push(3);
heap.push(5);
heap.push(1);
println!("{:?}", heap.pop()); // Output: Some(5) (largest value)
```

#### **8. `TryReserveError`**

An error type returned when memory allocation fails in collections like `Vec`, `HashMap`, etc.

```rust
use std::collections::TryReserveError;

fn allocate_large_vector() -> Result<(), TryReserveError> {
    let mut v = Vec::new();
    v.try_reserve(usize::MAX)?; // This will likely fail due to memory limits
    Ok(())
}

println!("{:?}", allocate_large_vector()); // Output: Err(TryReserveError { .. })
```

---

#### **9. `Bound<T>` (Range Bound)**

Used with `BTreeMap` and `BTreeSet` for range queries.

```rust
use std::collections::{BTreeMap, Bound};

let mut map = BTreeMap::new();
map.insert(1, "one");
map.insert(3, "three");
map.insert(5, "five");

let range = map.range((Bound::Included(2), Bound::Excluded(5)));
for (key, value) in range {
    println!("{}: {}", key, value); // Output: 3: three
}
```

---

#### **Other Traits and Helpers**

- **`range()` (for `BTreeMap` and `BTreeSet`)** – Enables efficient range queries.
- **`Default` implementation for collections** – Most collections implement `Default` for easy instantiation.

---

## `std::process`

`std::process` provides functionality to interact with system processes, including spawning new processes, handling input/output, and managing exit statuses. Below are key components of `std::process`:

---

### **`Command` - Running External Processes**

Used to spawn and interact with system processes.

```rust
use std::process::Command;

let output = Command::new("echo")
    .arg("Hello, world!")
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

---

### **`Child` - Managing Running Processes**

Represents a child process spawned from `Command`.

```rust
use std::process::{Command, Child};

let mut child: Child = Command::new("sleep")
    .arg("2")
    .spawn()
    .expect("Failed to start process");

let _ = child.wait().expect("Failed to wait on child");
println!("Process finished.");
```

---

### **`Output` - Capturing Process Output**

Contains the `stdout`, `stderr`, and exit status of a completed process.

```rust
use std::process::Command;

let output = Command::new("ls")
    .output()
    .expect("Failed to execute command");

println!("Status: {:?}", output.status);
println!("Stdout: {}", String::from_utf8_lossy(&output.stdout));
println!("Stderr: {}", String::from_utf8_lossy(&output.stderr));
```

---

### **`ExitStatus` - Handling Process Exit Codes**

Represents the status of a finished process.

```rust
use std::process::Command;

let status = Command::new("ls")
    .status()
    .expect("Failed to execute command");

if status.success() {
    println!("Command executed successfully.");
} else {
    println!("Command failed with status: {:?}", status);
}
```

---

### **`exit()` - Terminating the Current Process**

Exits the program with a specified exit code.

```rust
use std::process;

fn main() {
    println!("Exiting with code 1");
    process::exit(1);
}
```

---

### **`abort()` - Immediate Termination**

Unlike `exit()`, `abort()` terminates the process immediately without running destructors.

```rust
use std::process;

fn main() {
    println!("Process aborting...");
    process::abort();
}
```

---

### **`Command::stdin()`, `stdout()`, `stderr()` - Redirecting Streams**

These methods allow you to set up pipes for the child process’s standard input, output, and error streams.

```rust
use std::process::{Command, Stdio};

let mut child = Command::new("grep")
    .arg("hello")
    .stdin(Stdio::piped())   // Redirect input
    .stdout(Stdio::piped())  // Capture output
    .spawn()
    .expect("Failed to start process");

// You can write to `child.stdin` if needed
```

---

### **`Command::env()` - Setting Environment Variables**

Modifies the environment variables for the spawned process.

```rust
use std::process::Command;

let output = Command::new("printenv")
    .env("MY_VAR", "Hello, Rust!")
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

---

### **`Command::env_remove()` - Removing Environment Variables**

Removes a specific environment variable for the new process.

```rust
use std::process::Command;

let output = Command::new("printenv")
    .env_remove("MY_VAR")
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

---

### **`Command::current_dir()` - Setting Working Directory**

Runs the command in a specific directory.

```rust
use std::process::Command;

let output = Command::new("ls")
    .current_dir("/tmp")
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

---

### **`Command::spawn()` vs. `Command::output()` vs. `Command::status()`**

- **`spawn()`**: Runs the command asynchronously, returning a `Child` process.
- **`output()`**: Runs the command synchronously, capturing `stdout` and `stderr`.
- **`status()`**: Runs the command synchronously, returning only the exit status.

Example:

```rust
use std::process::Command;

let child = Command::new("sleep").arg("5").spawn();
println!("Process spawned!");

let output = Command::new("echo").arg("Hello").output();
println!("Captured output!");

let status = Command::new("ls").status();
println!("Exit status checked!");
```

---

### **`Command::kill()` - Terminating a Process**

Terminates a running child process.

```rust
use std::process::{Command, Stdio};
use std::thread;
use std::time::Duration;

let mut child = Command::new("sleep")
    .arg("10")
    .stdout(Stdio::null())
    .spawn()
    .expect("Failed to start process");

thread::sleep(Duration::from_secs(2)); // Let it run for a while
child.kill().expect("Failed to kill process");
```

---

### **`Command::wait()` - Waiting for a Process**

Blocks execution until the child process exits.

```rust
use std::process::Command;

let mut child = Command::new("sleep")
    .arg("3")
    .spawn()
    .expect("Failed to start process");

child.wait().expect("Failed to wait for process");
println!("Process finished.");
```

---

### **`Command::wait_with_output()` - Capturing Output & Waiting**

Waits for the process to finish while collecting its output.

```rust
use std::process::Command;

let output = Command::new("echo")
    .arg("Rust!")
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

---

### **`CommandExt` (Unix-specific) - Process Group Management**

For Unix-specific functionality, Rust provides `std::os::unix::process::CommandExt`.

```rust
use std::process::Command;
use std::os::unix::process::CommandExt;

Command::new("ls")
    .uid(1000)  // Set user ID
    .gid(1000)  // Set group ID
    .exec();    // Replace current process
```

### **`Command::arg()` and `args()` - Passing Command-line Arguments**

- **`arg()`**: Adds a single argument.
- **`args()`**: Adds multiple arguments at once.

```rust
use std::process::Command;

let output = Command::new("echo")
    .arg("Hello,")
    .arg("Rust!")
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

```rust
use std::process::Command;

let output = Command::new("echo")
    .args(&["Hello,", "Rust!"])
    .output()
    .expect("Failed to execute command");

println!("{}", String::from_utf8_lossy(&output.stdout));
```

---

### **`Command::output()` - Running a Process and Capturing Output**

Captures both **stdout** and **stderr**.

```rust
use std::process::Command;

let output = Command::new("echo")
    .arg("Captured Output")
    .output()
    .expect("Failed to execute command");

println!("Output: {}", String::from_utf8_lossy(&output.stdout));
```


---

### **`std::process::id()` - Get Process ID**

Retrieves the current process ID.

```rust
use std::process;

fn main() {
    println!("Process ID: {}", process::id());
}
```

---

### **`std::process::Child` - Managing Child Processes**

Handles a spawned process.

```rust
use std::process::{Command, Child};

let mut child: Child = Command::new("sleep")
    .arg("5")
    .spawn()
    .expect("Failed to start process");

println!("Process started...");
child.wait().expect("Failed to wait for process");
println!("Process finished.");
```

---

### **`Child::try_wait()` - Non-blocking Check for Completion**

Checks if a child process has finished without blocking execution.

```rust
use std::process::Command;
use std::thread;
use std::time::Duration;

let mut child = Command::new("sleep")
    .arg("5")
    .spawn()
    .expect("Failed to start process");

thread::sleep(Duration::from_secs(1));

match child.try_wait() {
    Ok(Some(status)) => println!("Process exited: {:?}", status),
    Ok(None) => println!("Process is still running"),
    Err(e) => eprintln!("Error checking process status: {}", e),
}
```

---

### **`Child::kill()` - Force Terminate a Process**

Stops a running child process.

```rust
use std::process::{Command, Stdio};
use std::thread;
use std::time::Duration;

let mut child = Command::new("sleep")
    .arg("10")
    .stdout(Stdio::null())
    .spawn()
    .expect("Failed to start process");

thread::sleep(Duration::from_secs(2));
child.kill().expect("Failed to kill process");
println!("Process killed.");
```


## `std::time`

The `std::time` module in Rust provides functionality for working with time, including durations, timestamps, and system time. It is essential for measuring elapsed time, scheduling operations, and handling time-related logic.

---

**Key Components in `std::time`**

The module contains two main types:

1. **`Duration`** – Represents a span of time.
2. **`SystemTime`** – Represents the system clock time.

---

### **1. `Duration` – Measuring Time Intervals**

#### **Creating a Duration**

A `Duration` represents a length of time in seconds and nanoseconds.

```rust
use std::time::Duration;

fn main() {
    let five_seconds = Duration::new(5, 0);
    let two_millis = Duration::from_millis(2);
    let one_micro = Duration::from_micros(1);
    
    println!("5 seconds: {:?}", five_seconds);
    println!("2 milliseconds: {:?}", two_millis);
    println!("1 microsecond: {:?}", one_micro);
}
```

---

#### **Common Duration Methods**

|Method|Description|
|---|---|
|`Duration::new(secs, nanos)`|Creates a duration from seconds and nanoseconds|
|`Duration::from_secs(secs)`|Creates a duration from seconds|
|`Duration::from_millis(ms)`|Creates a duration from milliseconds|
|`Duration::from_micros(μs)`|Creates a duration from microseconds|
|`Duration::from_nanos(ns)`|Creates a duration from nanoseconds|
|`duration.as_secs()`|Returns the duration in whole seconds|
|`duration.as_millis()`|Returns the duration in milliseconds|
|`duration.as_micros()`|Returns the duration in microseconds|
|`duration.as_nanos()`|Returns the duration in nanoseconds|

---

#### **Adding and Subtracting Durations**

`Duration` supports arithmetic operations like addition and subtraction.

```rust
use std::time::Duration;

fn main() {
    let duration1 = Duration::from_secs(5);
    let duration2 = Duration::from_millis(500);
    
    let total = duration1 + duration2;
    println!("Total duration: {:?}", total);
}
```

---

### **2. `SystemTime` – Getting the Current Time**

`SystemTime` represents an absolute point in time.

#### **Getting the Current Time**

```rust
use std::time::SystemTime;

fn main() {
    let now = SystemTime::now();
    println!("Current system time: {:?}", now);
}
```

---

#### **Calculating Time Elapsed Since an Event**

You can measure elapsed time using `SystemTime::elapsed()`.

```rust
use std::time::{Duration, SystemTime};

fn main() {
    let start = SystemTime::now();
    
    // Simulate some work
    std::thread::sleep(Duration::from_secs(2));
    
    match start.elapsed() {
        Ok(elapsed) => println!("Elapsed time: {:?}", elapsed),
        Err(e) => println!("Error: {:?}", e),
    }
}
```

---

#### **Comparing `SystemTime` Values**

Use `duration_since()` to compute the difference between two times.

```rust
use std::time::{Duration, SystemTime};

fn main() {
    let now = SystemTime::now();
    let earlier = now - Duration::from_secs(30);

    match now.duration_since(earlier) {
        Ok(duration) => println!("Time difference: {:?}", duration),
        Err(e) => println!("Error: {:?}", e),
    }
}
```

**Handling Errors:**  
`duration_since()` will return an error if the given time is in the future. To avoid errors, use `elapsed()` on `SystemTime::now()`.

---

### **3. `Instant` – High-Precision Timers**

Unlike `SystemTime`, which can be adjusted (e.g., by the OS), `Instant` is a monotonic clock and is used for measuring time intervals accurately.

#### **Measuring Execution Time**

```rust
use std::time::Instant;

fn main() {
    let start = Instant::now();

    // Simulate some work
    std::thread::sleep(std::time::Duration::from_secs(2));

    let elapsed = start.elapsed();
    println!("Elapsed time: {:?}", elapsed);
}
```

---

### **4. `UNIX_EPOCH` – Getting Timestamps**

Rust provides `UNIX_EPOCH` as a reference point for timestamps.

```rust
use std::time::{SystemTime, UNIX_EPOCH};

fn main() {
    let since_epoch = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards");

    println!("Seconds since UNIX epoch: {}", since_epoch.as_secs());
}

```

**Less Common Methods in `std::time`**

There are additional useful but less commonly used methods:

|Method|Type|Description|
|---|---|---|
|`Duration::saturating_add(other)`|`Duration`|Adds two durations, preventing overflow|
|`Duration::saturating_sub(other)`|`Duration`|Subtracts two durations, preventing negative values|
|`SystemTime::checked_add(duration)`|`SystemTime`|Adds a duration to `SystemTime`, returning `None` on overflow|
|`SystemTime::checked_sub(duration)`|`SystemTime`|Subtracts a duration from `SystemTime`, returning `None` on overflow|
|`Instant::saturating_duration_since(other)`|`Instant`|Returns duration since another instant, preventing negative values|

---

## `std::path`

### **`Path::new()` - Creating a Path**

Creates a new `Path` from a string slice.

```rust
use std::path::Path;

let path = Path::new("/home/user/file.txt");
println!("Path: {:?}", path);
```

---

### **`Path::join()` - Joining Paths**

Joins a path with a given component.

```rust
use std::path::Path;

let base = Path::new("/home/user");
let full_path = base.join("file.txt");

println!("Full Path: {:?}", full_path);
```

---

### **`Path::parent()` - Getting Parent Directory**

Retrieves the parent directory of a path.

```rust
use std::path::Path;

let path = Path::new("/home/user/file.txt");
if let Some(parent) = path.parent() {
    println!("Parent: {:?}", parent);
}
```

---

### **`Path::file_name()` - Extracting File Name**

Gets the file name portion of a path.

```rust
use std::path::Path;

let path = Path::new("/home/user/file.txt");
if let Some(file_name) = path.file_name() {
    println!("File Name: {:?}", file_name);
}
```

---

### **`Path::extension()` - Extracting File Extension**

Gets the file extension, if present.

```rust
use std::path::Path;

let path = Path::new("/home/user/file.txt");
if let Some(ext) = path.extension() {
    println!("Extension: {:?}", ext);
}
```

---

### **`Path::starts_with()` - Checking Prefix**

Checks if a path starts with a certain prefix.

```rust
use std::path::Path;

let path = Path::new("/home/user/file.txt");
assert!(path.starts_with("/home"));
```

---

### **`Path::ends_with()` - Checking Suffix**

Checks if a path ends with a given component.

```rust
use std::path::Path;

let path = Path::new("/home/user/file.txt");
assert!(path.ends_with("file.txt"));
```

---

### **`Path::canonicalize()` - Getting Absolute Path**

Converts a relative path to an absolute path.

```rust
use std::path::Path;

let path = Path::new("./file.txt");
if let Ok(absolute_path) = path.canonicalize() {
    println!("Absolute Path: {:?}", absolute_path);
}
```

---

### **`Path::is_absolute()` and `Path::is_relative()`**

Checks if a path is absolute or relative.

```rust
use std::path::Path;

let absolute_path = Path::new("/home/user/file.txt");
let relative_path = Path::new("file.txt");

assert!(absolute_path.is_absolute());
assert!(relative_path.is_relative());
```

---

### **`Path::components()` - Iterating Over Components**

Iterates through the components of a path.

```rust
use std::path::Path;

let path = Path::new("/home/user/file.txt");
for component in path.components() {
    println!("{:?}", component);
}
```

---

### **`Path::display()` - Displaying Paths**

Formats a path for printing.

```rust
use std::path::Path;

let path = Path::new("/home/user/file.txt");
println!("Path: {}", path.display());
```

---

### **`PathBuf` - Owned Version of `Path`**

`PathBuf` is a growable, mutable version of `Path`.

```rust
use std::path::PathBuf;

let mut path = PathBuf::from("/home/user");
path.push("file.txt");

println!("PathBuf: {:?}", path);
```

---

### **`PathBuf::pop()` - Removing Last Component**

Removes the last component of a path.

```rust
use std::path::PathBuf;

let mut path = PathBuf::from("/home/user/file.txt");
path.pop();

println!("After pop: {:?}", path);
```

---

### **`Path::to_str()` - Converting to String**

Converts a `Path` to a `str`, if possible.

```rust
use std::path::Path;

let path = Path::new("/home/user/file.txt");
if let Some(path_str) = path.to_str() {
    println!("Path as str: {}", path_str);
}
```

---

### **`Path::exists()` - Checking if a Path Exists**

Checks if a file or directory exists.

```rust
use std::path::Path;

let path = Path::new("file.txt");
println!("Exists: {}", path.exists());
```

---

### **`Path::is_dir()` - Checking if Path is a Directory**

Checks whether a path is a directory.

```rust
use std::path::Path;

let path = Path::new("/home/user");
println!("Is directory: {}", path.is_dir());
```

---

### **`Path::is_file()` - Checking if Path is a File**

Checks whether a path is a file.

```rust
use std::path::Path;

let path = Path::new("file.txt");
println!("Is file: {}", path.is_file());
```


## `std::cmp`

- **`Eq`** – Trait for equality comparisons (`==` and `!=`).
- **`PartialEq`** – Trait for partial equality comparisons (allows types that may not have total equality).
- **`Ord`** – Trait for total ordering (`<`, `>`, `<=`, `>=`).
- **`PartialOrd`** – Trait for partial ordering (allows types that may not have total order).
- **`Ordering`** – Enum with variants `Less`, `Equal`, and `Greater` used for ordering comparisons.
- **`max`** – Returns the maximum of two values.
- **`min`** – Returns the minimum of two values.
- **`reverse`** – Reverses the ordering of a comparator.

## `std::error`

The `std::error` module in Rust provides traits for error handling. It mainly contains the `Error` trait, which is used for defining and working with custom errors.

---

**Key Features of `std::error`**

The module primarily provides:

1. **`Error` Trait** – A standard trait for custom errors.
2. **Compatibility with `Result<T, E>`** – Works with Rust's error-handling system.
3. **Downcasting Errors** – Allows checking the underlying error type.

---

### **The `Error` Trait**

The `std::error::Error` trait is implemented for errors that can provide additional information.

#### **Minimal Example**

```rust
use std::error::Error;
use std::fmt;

#[derive(Debug)]
struct MyError;

impl fmt::Display for MyError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Something went wrong!")
    }
}

impl Error for MyError {}

fn main() -> Result<(), Box<dyn Error>> {
    let result: Result<(), MyError> = Err(MyError);
    result?;
    Ok(())
}
```

#### **Methods in `Error`**

|Method|Description|
|---|---|
|`description()` _(Deprecated)_|Returns a description of the error|
|`source()`|Returns the underlying cause of the error (if any)|
|`downcast_ref<T>()`|Checks if the error is of a specific type|
|`downcast_mut<T>()`|Checks if the error is of a specific type (mutable reference)|

---

### **`source()` – Chaining Errors**

If an error is caused by another error, `source()` provides access to the underlying cause.

```rust
use std::error::Error;
use std::fmt;

#[derive(Debug)]
struct OuterError {
    source: InnerError,
}

#[derive(Debug)]
struct InnerError;

impl fmt::Display for OuterError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Outer error occurred!")
    }
}

impl fmt::Display for InnerError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Inner error occurred!")
    }
}

impl Error for InnerError {}

impl Error for OuterError {
    fn source(&self) -> Option<&(dyn Error + 'static)> {
        Some(&self.source)
    }
}

fn main() {
    let err = OuterError { source: InnerError };
    println!("Error: {}", err);
    if let Some(source) = err.source() {
        println!("Caused by: {}", source);
    }
}
```

---

### **Downcasting Errors**

Errors can be downcast to check their exact type.

```rust
use std::error::Error;
use std::fmt;

#[derive(Debug)]
struct MyError;

impl fmt::Display for MyError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Custom error occurred!")
    }
}

impl Error for MyError {}

fn main() {
    let err: Box<dyn Error> = Box::new(MyError);

    if let Some(my_err) = err.downcast_ref::<MyError>() {
        println!("This is a MyError: {}", my_err);
    }
}
```

---

### **Using `Box<dyn Error>` in Functions**

Functions that return errors can use `Box<dyn Error>` to support multiple error types.

```rust
use std::error::Error;
use std::fs::File;

fn read_file() -> Result<(), Box<dyn Error>> {
    let _file = File::open("non_existent_file.txt")?;
    Ok(())
}

fn main() {
    match read_file() {
        Ok(_) => println!("File read successfully"),
        Err(e) => println!("Error occurred: {}", e),
    }
}
```

(continue)

## `std::slice`

The `std::slice` module in Rust provides functions and types for working with slices. A **slice** is a dynamically sized view into a contiguous sequence of elements. It allows for borrowing a part of an array or a vector without taking ownership of the entire collection.

---

**Key Features of Slices**

- **Borrowed Views:** Slices allow you to work with sections of an array or vector without copying data.
- **Dynamically Sized:** Unlike arrays, slices do not have a fixed size at compile time.
- **Memory Efficient:** Slices reference existing data rather than creating a new collection.
- **Useful for Function Parameters:** They allow functions to operate on different data structures (arrays, vectors, etc.) without taking ownership.

---

**Basic Slice Example**

```rust
fn main() {
    let array = [1, 2, 3, 4, 5];
    let slice: &[i32] = &array[1..4]; // Slice from index 1 to 3

    println!("{:?}", slice); // Output: [2, 3, 4]
}
```

#### **Mutable Slices**

```rust
fn main() {
    let mut data = [1, 2, 3, 4, 5];
    let slice: &mut [i32] = &mut data[2..];

    slice[0] = 10; // Modifying slice modifies the original array
    println!("{:?}", data); // Output: [1, 2, 10, 4, 5]
}
```

---

### **Methods**

- **`len()`** – Returns the number of elements in the slice.
- **`is_empty()`** – Checks if the slice is empty.
- **`first()` / `last()`** – Returns a reference to the first or last element (if present).

---

**Working with Methods**

```rust
fn main() {
    let mut numbers = [10, 20, 30, 40, 50];

    println!("Length: {}", numbers.len());
    println!("First element: {:?}", numbers.first());
    println!("Last element: {:?}", numbers.last());
}
```

#### **For Splitting Slices**

- **`split_at<T>(&self, mid: usize) -> (&[T], &[T])`**
    
    - Splits the slice at the given index.
    - **Example:**
        
        ```rust
        let numbers = [1, 2, 3, 4, 5];
        let (left, right) = numbers.split_at(2);
        println!("{:?}, {:?}", left, right); // Output: [1, 2], [3, 4, 5]
        ```
        
- **`split_at_mut<T>(&mut self, mid: usize) -> (&mut [T], &mut [T])`**
    
    - Same as `split_at` but for mutable slices.

---

#### **For Iterating Over Slices**

- **`iter<T>(&self) -> Iter<T>`**
    
    - Returns an iterator over the elements of the slice.
    - **Example:**
        
        ```rust
        let numbers = [1, 2, 3];
        for num in numbers.iter() {
            println!("{}", num);
        }
        ```
        
- **`iter_mut<T>(&mut self) -> IterMut<T>`**
    
    - Returns a mutable iterator over the slice.
    - **Example:**
        
        ```rust
        let mut numbers = [1, 2, 3];
        for num in numbers.iter_mut() {
            *num *= 2;
        }
        println!("{:?}", numbers); // Output: [2, 4, 6]
        ```
        

---

#### **For Chunking Slices**

- **`chunks<T>(&self, size: usize) -> Chunks<T>`**
    
    - Returns non-overlapping chunks of the slice.
    - **Example:**
        
        ```rust
        let numbers = [1, 2, 3, 4, 5, 6];
        for chunk in numbers.chunks(2) {
            println!("{:?}", chunk);
        }
        ```
        
- **`chunks_mut<T>(&mut self, size: usize) -> ChunksMut<T>`**
    
    - Same as `chunks`, but returns mutable chunks.
- **`windows<T>(&self, size: usize) -> Windows<T>`**
    
    - Returns overlapping windows of `size`.
    - **Example:**
        
        ```rust
        let numbers = [1, 2, 3, 4, 5];
        for window in numbers.windows(3) {
            println!("{:?}", window);
        }
        ```
        

---

#### **For Searching Slices**

- **`binary_search<T: Ord>(&self, x: &T) -> Result<usize, usize>`**
    
    - Performs a binary search (slice must be sorted).
    - **Example:**
        
        ```rust
        let numbers = [1, 3, 5, 7, 9];
        match numbers.binary_search(&5) {
            Ok(index) => println!("Found at index {}", index),
            Err(_) => println!("Not found"),
        }
        ```
        
- **`contains<T: PartialEq>(&self, x: &T) -> bool`**
    
    - Checks if the slice contains an element.
    - **Example:**
        
        ```rust
        let numbers = [1, 2, 3, 4, 5];
        println!("{}", numbers.contains(&3)); // Output: true
        ```
        

---

#### For Sorting Slices**

- **`sort<T: Ord>(&mut self)`**
    
    - Sorts the slice in ascending order.
    - **Example:**
        
        ```rust
        let mut numbers = [4, 2, 5, 1, 3];
        numbers.sort();
        println!("{:?}", numbers); // Output: [1, 2, 3, 4, 5]
        ```
        
- **`sort_unstable<T: Ord>(&mut self)`**
    
    - Like `sort`, but does not guarantee a stable sort order (faster in some cases).

---

#### **For Swapping and Rotating**

- **`swap<T>(&mut self, a: usize, b: usize)`**
    
    - Swaps two elements in the slice.
    - **Example:**
        
        ```rust
        let mut numbers = [1, 2, 3];
        numbers.swap(0, 2);
        println!("{:?}", numbers); // Output: [3, 2, 1]
        ```
        
- **`rotate_left<T>(&mut self, n: usize)`**
    
    - Rotates the slice left by `n` positions.
    - **Example:**
        
        ```rust
        let mut numbers = [1, 2, 3, 4, 5];
        numbers.rotate_left(2);
        println!("{:?}", numbers); // Output: [3, 4, 5, 1, 2]
        ```
        
- **`rotate_right<T>(&mut self, n: usize)`**
    
    - Rotates the slice right by `n` positions.

---

#### **Utility Functions**

- **`fill<T: Clone>(&mut self, value: T)`**
    
    - Fills the slice with a given value.
    - **Example:**
        
        ```rust
        let mut numbers = [0; 5];
        numbers.fill(3);
        println!("{:?}", numbers); // Output: [3, 3, 3, 3, 3]
        ```
        
- **`reverse<T>(&mut self)`**
    
    - Reverses the slice in place.
    - **Example:**
        
        ```rust
        let mut numbers = [1, 2, 3];
        numbers.reverse();
        println!("{:?}", numbers); // Output: [3, 2, 1]
        ```


---

### Functions

#### **For Creating Slices**

- **`from_ref<T>(t: &T) -> &[T]`**
    
    - Converts a single reference into a single-element slice.
    - **Example:**
        
        ```rust
        let num = 42;
        let slice = std::slice::from_ref(&num);
        println!("{:?}", slice); // Output: [42]
        ```
        
- **`from_mut<T>(t: &mut T) -> &mut [T]`**
    
    - Converts a mutable reference into a single-element mutable slice.
    - **Example:**
        
        ```rust
        let mut num = 42;
        let slice = std::slice::from_mut(&mut num);
        slice[0] += 1;
        println!("{:?}", slice); // Output: [43]
        ```
        
- **`from_raw_parts<T>(data: *const T, len: usize) -> &[T]`** _(unsafe)_
    
    - Creates a slice from a raw pointer and a length.
    - **Example:**
        
        ```rust
        let array = [1, 2, 3, 4, 5];
        let ptr = array.as_ptr();
        let slice = unsafe { std::slice::from_raw_parts(ptr, 3) };
        println!("{:?}", slice); // Output: [1, 2, 3]
        ```
        
- **`from_raw_parts_mut<T>(data: *mut T, len: usize) -> &mut [T]`** _(unsafe)_
    
    - Creates a mutable slice from a raw pointer and a length.
    - **Example:**
        
        ```rust
        let mut array = [1, 2, 3, 4, 5];
        let ptr = array.as_mut_ptr();
        let slice = unsafe { std::slice::from_raw_parts_mut(ptr, 3) };
        slice[0] = 10;
        println!("{:?}", array); // Output: [10, 2, 3, 4, 5]
        ```
        

#### Chunks vs Windows

Both `chunks(n)` and `windows(n)` are methods on slices that help iterate over sub-sections of the slice, but they behave differently in terms of overlap and mutability.

---

**`chunks(n)`**

- Divides the slice into **non-overlapping** chunks of size `n`.
- If the slice length is not a multiple of `n`, the last chunk will be smaller.
- Works for both immutable (`chunks()`) and mutable (`chunks_mut()`) slices.

**Example:**

```rust
fn main() {
    let numbers = [1, 2, 3, 4, 5, 6, 7];

    for chunk in numbers.chunks(3) {
        println!("{:?}", chunk);
    }
}
```

**Output:**

```
[1, 2, 3]
[4, 5, 6]
[7]
```

🔹 **Key property:** No overlap between chunks.

---

**`windows(n)`**

- Returns **overlapping** windows of size `n`.
- Each window contains `n` consecutive elements, shifting by one element per step.
- Works only on immutable slices (`windows()` does not have a mutable equivalent).

**Example:**

```rust
fn main() {
    let numbers = [1, 2, 3, 4, 5];

    for window in numbers.windows(3) {
        println!("{:?}", window);
    }
}
```

**Output:**

```
[1, 2, 3]
[2, 3, 4]
[3, 4, 5]
```

🔹 **Key property:** Each window overlaps with the previous window, moving forward by one element.

---

**Key Differences**

|Feature|`chunks(n)`|`windows(n)`|
|---|---|---|
|Overlapping|❌ No|✅ Yes|
|Sub-slice size|At most `n`|Exactly `n`|
|Moves by|`n` elements|1 element|
|Last slice|May be smaller|Always `n` (if possible)|
|Mutability|✅ `chunks_mut()` available|❌ Immutable only|

---

**Use Cases**

✔ Use **`chunks(n)`** when you need to process non-overlapping groups of elements, like batch processing.  
✔ Use **`windows(n)`** when you need to analyze a continuous sequence of `n` elements, like rolling averages or pattern matching.

