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

