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

