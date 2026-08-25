## Option and Result Types


### Option\<T> for Possible Absence

The `Option<T>` type represents a value that might be present or absent. It's Rust's way of avoiding null references, which Tony Hoare called his "billion-dollar mistake."

```rust
enum Option<T> {
    None,    // No value present
    Some(T), // Value of type T is present
}
```

**Key Points:**

- `Option<T>` is included in the prelude (no need to import)
- Forces explicit handling of the "no value" case
- Eliminates null pointer exceptions/panics
- Makes code more robust and intentions clearer

#### Creating Option Values

```rust
// Creating Some values
let some_number = Some(42);
let some_string = Some(String::from("hello"));

// Creating None values (type annotation required)
let absent_number: Option<i32> = None;
let absent_string: Option<String> = None;
```

#### Common Use Cases

1. **Return values that might not exist**:

```rust
fn find_user(id: u64) -> Option<User> {
    if let Some(user) = database.get_user(id) {
        Some(user)
    } else {
        None
    }
}
```

2. **Optional function parameters**:

```rust
fn greet(name: &str, title: Option<&str>) {
    match title {
        Some(t) => println!("Hello, {} {}!", t, name),
        None => println!("Hello, {}!", name),
    }
}

// Usage
greet("Smith", Some("Mr."));
greet("Alice", None);
```

3. **Struct fields that might be uninitialized**:

```rust
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
    last_login: Option<DateTime>,
}
```

### Result<T, E> for Possible Failures

The `Result<T, E>` type represents an operation that might succeed with a value of type `T` or fail with an error of type `E`.

```rust
enum Result<T, E> {
    Ok(T),  // Success, containing a value of type T
    Err(E), // Error, containing an error of type E
}
```

**Key Points:**

- `Result<T, E>` is included in the prelude
- Allows functions to return errors without using exceptions
- Makes error handling explicit and visible in function signatures
- Can be composed and chained

#### Creating Result Values

```rust
// Successful result
let success: Result<i32, &str> = Ok(42);

// Error result
let failure: Result<i32, &str> = Err("something went wrong");
```

#### Common Use Cases

1. **I/O operations**:

```rust
use std::fs::File;
use std::io;

fn open_file(path: &str) -> Result<File, io::Error> {
    File::open(path)
}
```

2. **Parsing operations**:

```rust
fn parse_age(input: &str) -> Result<u32, &'static str> {
    match input.parse::<u32>() {
        Ok(age) if age > 0 => Ok(age),
        Ok(_) => Err("age must be positive"),
        Err(_) => Err("could not parse age"),
    }
}
```

3. **Custom error types**:

```rust
enum ServiceError {
    DatabaseError(String),
    ValidationError(String),
    AuthorizationError,
}

fn save_user(user: User) -> Result<(), ServiceError> {
    if !user.is_valid() {
        return Err(ServiceError::ValidationError("Invalid user data".to_string()));
    }
    
    match database.save(user) {
        Ok(_) => Ok(()),
        Err(e) => Err(ServiceError::DatabaseError(e.to_string())),
    }
}
```

### Methods on Option and Result

Both `Option<T>` and `Result<T, E>` provide rich methods for safely manipulating and extracting values.

#### Common Option Methods

##### Querying the Variant

```rust
let x = Some(42);
let y: Option<i32> = None;

// Check if it contains a value
assert!(x.is_some());
assert!(y.is_none());
```

##### Extracting Values

```rust
let x = Some("value");

// or_else: Provides a default value if None
let s = y.or_else(|| Some("default")).unwrap();

// unwrap_or: Returns the contained value or a default
assert_eq!(x.unwrap_or("default"), "value");
assert_eq!(y.unwrap_or("default"), "default");

// unwrap_or_else: Returns the contained value or computes a default
assert_eq!(y.unwrap_or_else(|| "computed default"), "computed default");
```

##### Transforming Options

```rust
let x = Some(5);
let y: Option<i32> = None;

// map: Transforms the contained value if Some
assert_eq!(x.map(|n| n * 2), Some(10));
assert_eq!(y.map(|n| n * 2), None);

// and_then: Chainable transformation that may return None
fn halve(n: i32) -> Option<i32> {
    if n % 2 == 0 {
        Some(n / 2)
    } else {
        None
    }
}

assert_eq!(Some(4).and_then(halve), Some(2));
assert_eq!(Some(5).and_then(halve), None);
assert_eq!(None.and_then(halve), None);
```

##### Combining Options

```rust
let x = Some(2);
let y = Some(3);
let z: Option<i32> = None;

// and: Returns None if either is None, otherwise the second Option
assert_eq!(x.and(y), Some(3));
assert_eq!(x.and(z), None);

// or: Returns the first Option if it's Some, otherwise the second
assert_eq!(x.or(y), Some(2));
assert_eq!(z.or(y), Some(3));

// xor: Returns Some if exactly one of the Options is Some
assert_eq!(x.xor(y), None);  // Both are Some
assert_eq!(x.xor(z), Some(2));  // Only x is Some
```

##### Filtering Options

```rust
let x = Some(3);
let y = Some(6);

// filter: Returns None if the predicate returns false
assert_eq!(x.filter(|n| n % 2 == 0), None);
assert_eq!(y.filter(|n| n % 2 == 0), Some(6));
```

#### Common Result Methods

##### Querying the Variant

```rust
let x: Result<i32, &str> = Ok(5);
let y: Result<i32, &str> = Err("error");

// Check if it's Ok or Err
assert!(x.is_ok());
assert!(y.is_err());
```

##### Extracting Values

```rust
let x: Result<i32, &str> = Ok(5);
let y: Result<i32, &str> = Err("error");

// unwrap_or: Returns the contained value or a default
assert_eq!(x.unwrap_or(0), 5);
assert_eq!(y.unwrap_or(0), 0);

// unwrap_or_else: Returns the contained value or computes a default
assert_eq!(y.unwrap_or_else(|_| 0), 0);

// unwrap_err: Extracts the error value (panics if Ok)
assert_eq!(y.unwrap_err(), "error");
```

##### Transforming Results

```rust
let x: Result<i32, &str> = Ok(5);
let y: Result<i32, &str> = Err("error");

// map: Transforms the contained value if Ok
assert_eq!(x.map(|n| n * 2), Ok(10));
assert_eq!(y.map(|n| n * 2), Err("error"));

// map_err: Transforms the contained error if Err
assert_eq!(x.map_err(|e| format!("Error: {}", e)), Ok(5));
assert_eq!(y.map_err(|e| format!("Error: {}", e)), Err("Error: error".to_string()));

// and_then: Chainable transformation that may return Err
fn halve(n: i32) -> Result<i32, &'static str> {
    if n % 2 == 0 {
        Ok(n / 2)
    } else {
        Err("cannot halve odd number")
    }
}

assert_eq!(Ok(4).and_then(halve), Ok(2));
assert_eq!(Ok(5).and_then(halve), Err("cannot halve odd number"));
assert_eq!(Err("error").and_then(halve), Err("error"));
```

##### Combining Results

```rust
let x: Result<i32, &str> = Ok(5);
let y: Result<i32, &str> = Ok(10);
let z: Result<i32, &str> = Err("error");

// and: Returns the second Result if both are Ok
assert_eq!(x.and(y), Ok(10));
assert_eq!(x.and(z), Err("error"));

// or: Returns the first Result if it's Ok, otherwise the second
assert_eq!(x.or(y), Ok(5));
assert_eq!(z.or(y), Ok(10));
```

##### Converting Between Option and Result

```rust
let x: Option<i32> = Some(5);
let y: Option<i32> = None;

// ok_or: Transforms Option<T> to Result<T, E>
assert_eq!(x.ok_or("error"), Ok(5));
assert_eq!(y.ok_or("error"), Err("error"));

// ok_or_else: Transforms Option<T> to Result<T, E> with a function
assert_eq!(y.ok_or_else(|| "computed error"), Err("computed error"));

let a: Result<i32, &str> = Ok(5);
let b: Result<i32, &str> = Err("error");

// ok: Transforms Result<T, E> to Option<T>
assert_eq!(a.ok(), Some(5));
assert_eq!(b.ok(), None);

// err: Transforms Result<T, E> to Option<E>
assert_eq!(a.err(), None);
assert_eq!(b.err(), Some("error"));
```

### The ? Operator

The `?` operator simplifies error propagation by automatically returning errors from functions.

```rust
use std::fs::File;
use std::io::{self, Read};

fn read_file_contents(path: &str) -> Result<String, io::Error> {
    let mut file = File::open(path)?;  // Returns early if Err
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;  // Returns early if Err
    Ok(contents)
}

// More concise version
fn read_file_contents_short(path: &str) -> Result<String, io::Error> {
    let mut contents = String::new();
    File::open(path)?.read_to_string(&mut contents)?;
    Ok(contents)
}
```

**Key Points About ?:**

- Only works in functions that return `Result` or `Option`
- When used on `Result`, returns early with the `Err` value if the result is an error
- When used on `Option`, returns early with `None` if the option is `None`
- Automatically converts error types using the `From` trait
- More concise than explicit match expressions

The `?` operator can also be used with `Option`:

```rust
fn first_even_number(numbers: &[i32]) -> Option<i32> {
    let first = numbers.get(0)?;  // Returns None if empty slice
    if first % 2 == 0 {
        Some(*first)
    } else {
        None
    }
}
```

### Unwrapping and Expecting

Both `Option` and `Result` provide methods to extract values directly, though these can panic.

#### Unwrapping

The `unwrap()` method extracts the value if present/successful, or panics if not:

```rust
// Option unwrap
let x = Some(5);
let y: Option<i32> = None;

assert_eq!(x.unwrap(), 5);  // Works fine
// y.unwrap();  // This would panic with "called `Option::unwrap()` on a `None` value"

// Result unwrap
let a: Result<i32, &str> = Ok(5);
let b: Result<i32, &str> = Err("error message");

assert_eq!(a.unwrap(), 5);  // Works fine
// b.unwrap();  // This would panic with "called `Result::unwrap()` on an `Err` value: \"error message\""
```

#### Expecting

The `expect()` method is similar to `unwrap()` but allows you to specify a custom panic message:

```rust
// Option expect
let x = Some(5);
let y: Option<i32> = None;

assert_eq!(x.expect("should have a value"), 5);  // Works fine
// y.expect("should have a value");  // This would panic with "should have a value"

// Result expect
let a: Result<i32, &str> = Ok(5);
let b: Result<i32, &str> = Err("error message");

assert_eq!(a.expect("should be ok"), 5);  // Works fine
// b.expect("should be ok");  // This would panic with "should be ok: \"error message\""
```

#### When to Use Unwrap and Expect

Unwrapping and expecting should be used judiciously:

**Appropriate Uses:**

- Prototyping or quick scripts
- When you're absolutely certain the operation cannot fail
- Tests where the panic indicates a failed test
- When failure truly is unrecoverable and the program should terminate

```rust
// In tests
#[test]
fn test_parse_valid_input() {
    let result = parse_input("42");
    assert!(result.is_ok());
    assert_eq!(result.unwrap(), 42);
}

// When you're certain
fn get_config_value(key: &str) -> String {
    let config = CONFIG.lock().unwrap();  // Global config that must exist
    config.get(key).expect("Configuration value must exist")
}
```

**Inappropriate Uses:**

- Regular application code where errors should be handled gracefully
- When there's any chance of failure that should be handled
- Code that's part of a library other people will use

### Patterns for Working with Option and Result

#### Pattern Matching

```rust
fn describe_option(opt: Option<i32>) {
    match opt {
        Some(value) if value > 0 => println!("Some positive: {}", value),
        Some(0) => println!("Some zero"),
        Some(value) => println!("Some negative: {}", value),
        None => println!("None"),
    }
}

fn process_result(res: Result<i32, &str>) {
    match res {
        Ok(value) => println!("Success: {}", value),
        Err(e) => println!("Error: {}", e),
    }
}
```

#### If Let and While Let

`if let` provides a concise way to handle one specific pattern:

```rust
fn process_option(opt: Option<i32>) {
    if let Some(value) = opt {
        println!("Got value: {}", value);
    } else {
        println!("No value");
    }
}

// Especially useful when you don't need to handle all cases
fn handle_positive(opt: Option<i32>) {
    if let Some(value) = opt {
        if value > 0 {
            println!("Positive: {}", value);
        }
        // Silently ignore None and non-positive values
    }
}
```

`while let` continues a loop as long as a pattern matches:

```rust
fn process_all_values<I>(mut iter: I)
where
    I: Iterator<Item = Option<i32>>,
{
    while let Some(Some(value)) = iter.next() {
        println!("Processing: {}", value);
    }
    println!("Done or encountered None");
}

// Example usage:
let values = vec![Some(1), Some(2), None, Some(4)];
process_all_values(values.into_iter());
```

#### Combinators for Cleaner Code

Combinators allow for concise, functional-style code:

```rust
fn process_data(data: Option<String>) -> Option<usize> {
    data.filter(|s| !s.is_empty())
        .map(|s| s.len())
        .and_then(|len| if len > 10 { Some(len) } else { None })
}

fn validate_and_process(input: Result<String, &str>) -> Result<usize, String> {
    input
        .map_err(|e| format!("Input error: {}", e))
        .and_then(|s| {
            if s.is_empty() {
                Err("Empty input".to_string())
            } else {
                Ok(s)
            }
        })
        .map(|s| s.len())
}
```

#### Collecting Results

Working with collections of `Option` or `Result`:

```rust
fn process_strings(strings: Vec<&str>) -> Result<Vec<usize>, &'static str> {
    // Collects into Result<Vec<_>, _>, fails if any element fails
    strings
        .iter()
        .map(|s| {
            if s.is_empty() {
                Err("empty string")
            } else {
                Ok(s.len())
            }
        })
        .collect()
}

// Filter out the None values
fn filter_valid_numbers(strings: Vec<&str>) -> Vec<i32> {
    strings
        .iter()
        .filter_map(|s| s.parse::<i32>().ok())
        .collect()
}

// Partition into successes and failures
fn partition_results<T, E>(results: Vec<Result<T, E>>) -> (Vec<T>, Vec<E>) {
    let (ok_vals, err_vals): (Vec<_>, Vec<_>) = results.into_iter().partition(Result::is_ok);
    
    let ok_vals = ok_vals.into_iter().map(Result::unwrap).collect();
    let err_vals = err_vals.into_iter().map(Result::unwrap_err).collect();
    
    (ok_vals, err_vals)
}
```

#### Custom Error Types and Error Handling

Creating custom error types improves error handling:

```rust
use std::fmt;
use std::io;

#[derive(Debug)]
enum AppError {
    IoError(io::Error),
    ParseError(String),
    ValidationError { field: String, message: String },
}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            AppError::IoError(e) => write!(f, "I/O error: {}", e),
            AppError::ParseError(msg) => write!(f, "Parse error: {}", msg),
            AppError::ValidationError { field, message } => {
                write!(f, "Validation error in {}: {}", field, message)
            }
        }
    }
}

impl From<io::Error> for AppError {
    fn from(error: io::Error) -> Self {
        AppError::IoError(error)
    }
}

// Now io::Errors can be converted automatically with ?
fn read_config(path: &str) -> Result<String, AppError> {
    use std::fs::File;
    use std::io::Read;
    
    let mut file = File::open(path)?;  // io::Error converts to AppError
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;  // io::Error converts to AppError
    
    if contents.is_empty() {
        return Err(AppError::ValidationError {
            field: "config".to_string(),
            message: "Config file is empty".to_string(),
        });
    }
    
    Ok(contents)
}
```

### Advanced Option and Result Patterns

#### Fallible Iteration

```rust
fn fallible_process<I, T, E>(iter: I) -> Result<Vec<T>, E>
where
    I: IntoIterator,
    I::Item: TryInto<T, Error = E>,
{
    iter.into_iter().map(|item| item.try_into()).collect()
}
```

#### Early Return in Functional Chains

```rust
use std::fs;
use std::io;
use std::path::Path;

fn find_executable(name: &str) -> io::Result<Option<String>> {
    let paths = std::env::var_os("PATH").ok_or_else(|| {
        io::Error::new(io::ErrorKind::NotFound, "PATH environment variable not found")
    })?;
    
    for path in std::env::split_paths(&paths) {
        let candidate = path.join(name);
        if candidate.is_file() && fs::metadata(&candidate)?.permissions().mode() & 0o111 != 0 {
            return Ok(Some(candidate.to_string_lossy().into_owned()));
        }
    }
    
    Ok(None)
}
```

#### The `try` Block (Unstable Feature)

In unstable Rust, the `try` block can simplify error handling:

```rust
fn process_data() -> Result<i32, Error> {
    try {
        let file = File::open("data.txt")?;
        let reader = BufReader::new(file);
        let mut sum = 0;
        
        for line in reader.lines() {
            let num = line?.parse::<i32>()?;
            sum += num;
        }
        
        sum
    }
}
```

#### Custom Option/Result-like Types

For specialized domains, custom option types can be useful:

```rust
enum MaybeValid<T> {
    Valid(T),
    Invalid { reason: String, recoverable: bool },
}

impl<T> MaybeValid<T> {
    fn is_valid(&self) -> bool {
        matches!(self, MaybeValid::Valid(_))
    }
    
    fn unwrap(self) -> T {
        match self {
            MaybeValid::Valid(value) => value,
            MaybeValid::Invalid { reason, .. } => panic!("Called unwrap on invalid value: {}", reason),
        }
    }
    
    fn map<U, F>(self, f: F) -> MaybeValid<U>
    where
        F: FnOnce(T) -> U,
    {
        match self {
            MaybeValid::Valid(value) => MaybeValid::Valid(f(value)),
            MaybeValid::Invalid { reason, recoverable } => MaybeValid::Invalid { reason, recoverable },
        }
    }
}
```

**Conclusion:** Rust's `Option<T>` and `Result<T, E>` types form the foundation of its error handling philosophy, encouraging explicit handling of potential absence and failures. These types, combined with pattern matching and the powerful methods they provide, lead to more robust and maintainable code. By understanding and effectively using these types, you can write Rust code that gracefully handles edge cases without sacrificing readability or performance.

Related topics include `thiserror` and `anyhow` crates for simplified error handling, the unstable `Try` trait, and integrating Rust's error handling with asynchronous code.

---

