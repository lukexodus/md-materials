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

