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

