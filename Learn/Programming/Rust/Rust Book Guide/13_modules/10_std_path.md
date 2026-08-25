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


