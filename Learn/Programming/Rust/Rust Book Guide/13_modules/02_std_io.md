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

