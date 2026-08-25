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

