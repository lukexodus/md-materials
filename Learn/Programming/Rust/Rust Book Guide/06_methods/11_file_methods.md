## **`File` Methods**


- **`open(path)`**: Opens an existing file in read-only mode.

    ```rust
    use std::fs::File;
    use std::io::prelude::*;

    let mut file = File::open("example.txt").expect("Cannot open file");
    let mut content = String::new();
    file.read_to_string(&mut content).expect("Cannot read file");
    println!("{}", content);
    ```

- **`create(path)`**: Creates a new file for writing (truncating if the file already exists).

    ```rust
    use std::fs::File;
    use std::io::prelude::*;

    let mut file = File::create("output.txt").expect("Cannot create file");
    file.write_all(b"Hello, world!").expect("Cannot write to file");
    ```

- **`write_all(data)`**: Writes a buffer of bytes to the file.

    ```rust
    let mut file = File::create("output.txt").expect("Cannot create file");
    file.write_all(b"Hello, Rust!").expect("Cannot write data");
    ```

- **`read_to_string()`**: Reads the contents of a file into a string.

    ```rust
    let mut file = File::open("example.txt").expect("Cannot open file");
    let mut content = String::new();
    file.read_to_string(&mut content).expect("Cannot read file");
    println!("{}", content);
    ```


---

