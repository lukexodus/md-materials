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

