## Error Propagation in Rust


### The ? Operator

The `?` operator is a concise way to propagate errors in Rust, eliminating much of the boilerplate code associated with error handling. When applied to a `Result`, it either unwraps the `Ok` value or returns early with the `Err` value.

#### Basic Usage

```rust
fn read_username_from_file() -> Result<String, std::io::Error> {
    let mut username_file = std::fs::File::open("username.txt")?;
    let mut username = String::new();
    username_file.read_to_string(&mut username)?;
    Ok(username)
}
```

Without the `?` operator, the same function would be more verbose:

```rust
fn read_username_from_file_verbose() -> Result<String, std::io::Error> {
    let mut username_file = match std::fs::File::open("username.txt") {
        Ok(file) => file,
        Err(e) => return Err(e),
    };
    
    let mut username = String::new();
    match username_file.read_to_string(&mut username) {
        Ok(_) => Ok(username),
        Err(e) => Err(e),
    }
}
```

#### Error Type Conversion

The `?` operator automatically converts error types using the `From` trait. This means if a function returns `Result<T, E>`, you can use `?` on a `Result<T, F>` as long as `F` can be converted into `E`.

#### Working with Option

The `?` operator also works with `Option<T>`:

```rust
fn first_char_of_first_line(text: &str) -> Option<char> {
    text.lines().next()?.chars().next()
}
```

When used with `Option`, it returns `None` early if the value is `None`.

#### Requirements for Using ?

The `?` operator can only be used in functions that return:

- `Result<T, E>` (when used on a `Result`)
- `Option<T>` (when used on an `Option`)
- Types that implement `Try` trait (experimental)

It cannot be used in `main()` without returning a compatible type:

```rust
// This works
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let content = std::fs::read_to_string("config.toml")?;
    println!("Config: {}", content);
    Ok(())
}
```

### Multiple Error Types Handling

Real-world applications often deal with multiple error types. Rust provides several approaches to handle this complexity.

#### Box\<dyn Error>

The simplest approach is to use a trait object `Box<dyn Error>`, which can hold any error type that implements the `Error` trait:

```rust
use std::error::Error;

fn read_and_parse() -> Result<i32, Box<dyn Error>> {
    let content = std::fs::read_to_string("number.txt")?;
    let number: i32 = content.trim().parse()?;
    Ok(number)
}
```

This approach is convenient but loses type information and has a small runtime cost.

#### Custom Error Types

For more control, you can define a custom error enum that encompasses all possible error types:

```rust
#[derive(Debug)]
enum AppError {
    IoError(std::io::Error),
    ParseError(std::num::ParseIntError),
    Custom(String),
}

impl std::fmt::Display for AppError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AppError::IoError(e) => write!(f, "I/O error: {}", e),
            AppError::ParseError(e) => write!(f, "Parse error: {}", e),
            AppError::Custom(msg) => write!(f, "{}", msg),
        }
    }
}

impl std::error::Error for AppError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            AppError::IoError(e) => Some(e),
            AppError::ParseError(e) => Some(e),
            AppError::Custom(_) => None,
        }
    }
}
```

#### Using Error Libraries

Several crates simplify error handling in Rust:

- `thiserror`: For creating custom error types with minimal boilerplate
- `anyhow`: For applications where detailed error information is less important
- `eyre`: A fork of `anyhow` with additional features

Example with `thiserror`:

```rust
use thiserror::Error;

#[derive(Error, Debug)]
enum DataError {
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),
    
    #[error("Parse error: {0}")]
    Parse(#[from] std::num::ParseIntError),
    
    #[error("Data validation failed: {0}")]
    Validation(String),
}

fn process_data() -> Result<(), DataError> {
    let content = std::fs::read_to_string("data.txt")?;
    let value: i32 = content.trim().parse()?;
    
    if value < 0 {
        return Err(DataError::Validation("Value must be positive".to_string()));
    }
    
    Ok(())
}
```

Example with `anyhow`:

```rust
use anyhow::{Context, Result};

fn read_config() -> Result<Config> {
    let content = std::fs::read_to_string("config.toml")
        .context("Failed to read config file")?;
        
    let config: Config = toml::from_str(&content)
        .context("Failed to parse TOML")?;
        
    Ok(config)
}
```

### From Trait for Error Conversion

The `From` trait is central to Rust's error handling system. It enables automatic conversion between error types, which is what powers the `?` operator's conversion capabilities.

#### Implementing From for Custom Errors

```rust
use std::io;
use std::num::ParseIntError;

#[derive(Debug)]
enum ConfigError {
    IoError(io::Error),
    ParseError(ParseIntError),
    MissingField(String),
}

impl From<io::Error> for ConfigError {
    fn from(error: io::Error) -> Self {
        ConfigError::IoError(error)
    }
}

impl From<ParseIntError> for ConfigError {
    fn from(error: ParseIntError) -> Self {
        ConfigError::ParseError(error)
    }
}

// Now we can use ? with io::Error and ParseIntError
fn read_max_connections() -> Result<u32, ConfigError> {
    let content = std::fs::read_to_string("config.txt")?; // io::Error converts to ConfigError
    let max = content.trim().parse::<u32>()?; // ParseIntError converts to ConfigError
    
    if max == 0 {
        return Err(ConfigError::MissingField("max_connections cannot be zero".to_string()));
    }
    
    Ok(max)
}
```

#### Automatic Derivation with `thiserror`

The `thiserror` crate simplifies this process with its `#[from]` attribute:

```rust
use thiserror::Error;

#[derive(Error, Debug)]
enum ConfigError {
    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),
    
    #[error("Parse error: {0}")]
    ParseError(#[from] std::num::ParseIntError),
    
    #[error("Validation error: {0}")]
    ValidationError(String),
}
```

### Error Context and Chaining

Error context provides additional information about where and why an error occurred, making debugging easier.

#### Error Chaining with std

The standard library's `Error` trait includes a `source()` method that enables error chaining:

```rust
use std::error::Error;
use std::fmt;
use std::io;

#[derive(Debug)]
struct ReadUserError {
    path: String,
    source: io::Error,
}

impl fmt::Display for ReadUserError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Failed to read user data from '{}'", self.path)
    }
}

impl Error for ReadUserError {
    fn source(&self) -> Option<&(dyn Error + 'static)> {
        Some(&self.source)
    }
}

fn read_user_data(path: &str) -> Result<String, ReadUserError> {
    std::fs::read_to_string(path).map_err(|e| ReadUserError {
        path: path.to_string(),
        source: e,
    })
}
```

#### Context with Libraries

Error handling libraries provide more ergonomic ways to add context:

##### With `anyhow`:

```rust
use anyhow::{Context, Result};

fn get_user_by_id(id: u64) -> Result<User> {
    let path = format!("users/{}.json", id);
    
    let content = std::fs::read_to_string(&path)
        .with_context(|| format!("Failed to read user {} data", id))?;
        
    let user = serde_json::from_str(&content)
        .with_context(|| format!("Failed to parse user {} JSON data", id))?;
        
    Ok(user)
}
```

##### With `eyre`:

```rust
use eyre::{eyre, WrapErr, Result};

fn authenticate_user(username: &str, password: &str) -> Result<AuthToken> {
    let user = find_user(username)
        .wrap_err_with(|| format!("Failed to find user '{}'", username))?;
        
    if !user.verify_password(password) {
        return Err(eyre!("Invalid password for user '{}'", username));
    }
    
    generate_token(&user)
        .wrap_err("Failed to generate authentication token")
}
```

#### Displaying Error Chains

When using error chaining, you can display the full chain to get complete diagnostic information:

```rust
fn run() -> Result<(), Box<dyn std::error::Error>> {
    // ... application code ...
}

fn main() {
    if let Err(e) = run() {
        eprintln!("Error: {}", e);
        
        let mut source = e.source();
        while let Some(err) = source {
            eprintln!("Caused by: {}", err);
            source = err.source();
        }
        
        std::process::exit(1);
    }
}
```

Libraries like `anyhow` and `eyre` provide built-in pretty error formatting:

```rust
fn main() {
    if let Err(e) = run() {
        eprintln!("{:?}", e); // Shows the full error chain with context
        std::process::exit(1);
    }
}
```

**Key Points**:

- The `?` operator simplifies error propagation and automatically converts error types
- Multiple error types can be handled through trait objects, custom error enums, or libraries
- The `From` trait enables automatic conversion between error types
- Error context provides additional information about where and why errors occurred
- Error chaining creates a trail of errors that helps with debugging

**Example**:

```rust
use std::fs::File;
use std::io::{self, Read};
use std::path::Path;
use std::num::ParseIntError;

// Custom error type that combines multiple error sources
#[derive(Debug)]
enum ConfigError {
    Io(io::Error),
    Parse(ParseIntError),
    Missing(String),
    Invalid(String),
}

// Implement From for automatic conversions with ?
impl From<io::Error> for ConfigError {
    fn from(err: io::Error) -> Self {
        ConfigError::Io(err)
    }
}

impl From<ParseIntError> for ConfigError {
    fn from(err: ParseIntError) -> Self {
        ConfigError::Parse(err)
    }
}

// Implement Display for user-friendly error messages
impl std::fmt::Display for ConfigError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ConfigError::Io(err) => write!(f, "I/O error: {}", err),
            ConfigError::Parse(err) => write!(f, "Parse error: {}", err),
            ConfigError::Missing(field) => write!(f, "Missing field: {}", field),
            ConfigError::Invalid(msg) => write!(f, "Invalid configuration: {}", msg),
        }
    }
}

// Implement Error for error chaining
impl std::error::Error for ConfigError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            ConfigError::Io(err) => Some(err),
            ConfigError::Parse(err) => Some(err),
            _ => None,
        }
    }
}

// A configuration structure
struct Config {
    host: String,
    port: u16,
    max_connections: usize,
}

// Function to read and parse configuration
fn read_config<P: AsRef<Path>>(path: P) -> Result<Config, ConfigError> {
    // Open file - ? converts io::Error to ConfigError
    let mut file = File::open(path)?;
    
    // Read to string
    let mut content = String::new();
    file.read_to_string(&mut content)?;
    
    // Parse each setting
    let mut host = None;
    let mut port = None;
    let mut max_connections = None;
    
    for line in content.lines() {
        if line.trim().is_empty() || line.starts_with('#') {
            continue;
        }
        
        let parts: Vec<&str> = line.splitn(2, '=').collect();
        if parts.len() != 2 {
            return Err(ConfigError::Invalid(format!("Invalid line: {}", line)));
        }
        
        let key = parts[0].trim();
        let value = parts[1].trim();
        
        match key {
            "host" => host = Some(value.to_string()),
            "port" => {
                // ? converts ParseIntError to ConfigError
                port = Some(value.parse::<u16>()?);
                if port.unwrap() == 0 {
                    return Err(ConfigError::Invalid("Port cannot be zero".to_string()));
                }
            },
            "max_connections" => {
                max_connections = Some(value.parse::<usize>()?);
            },
            _ => {
                // Ignoring unknown keys
            }
        }
    }
    
    // Validate required fields
    let host = host.ok_or_else(|| ConfigError::Missing("host".to_string()))?;
    let port = port.ok_or_else(|| ConfigError::Missing("port".to_string()))?;
    let max_connections = max_connections.ok_or_else(|| 
        ConfigError::Missing("max_connections".to_string())
    )?;
    
    Ok(Config {
        host,
        port,
        max_connections,
    })
}

// Usage example
fn main() -> Result<(), Box<dyn std::error::Error>> {
    match read_config("config.txt") {
        Ok(config) => {
            println!("Configuration loaded:");
            println!("Host: {}", config.host);
            println!("Port: {}", config.port);
            println!("Max connections: {}", config.max_connections);
        },
        Err(e) => {
            eprintln!("Failed to load configuration: {}", e);
            
            // Print the error chain
            let mut source = e.source();
            while let Some(err) = source {
                eprintln!("Caused by: {}", err);
                source = err.source();
            }
            
            std::process::exit(1);
        }
    }
    
    Ok(())
}
```

**Conclusion**: Rust's error handling ecosystem provides powerful tools for propagating, converting, and contextualizing errors. The `?` operator simplifies error propagation, while the `From` trait enables seamless error type conversion. Custom error types with proper implementations of `Display` and `Error` traits create informative error chains. Third-party libraries like `thiserror`, `anyhow`, and `eyre` further reduce boilerplate and improve the developer experience. By embracing these patterns, Rust developers can create robust applications with clear error handling that balances ergonomics with Rust's commitment to explicitness and reliability.

---

