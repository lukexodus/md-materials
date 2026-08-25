## **`Debug` and `Display` Traits Methods**


These traits control how values are printed.

- **`fmt()` (for `Display`)**: Used to format the value for user-facing output. This is often used with the `{}` formatting string in `println!()`.

    ```rust
    struct Point {
        x: i32,
        y: i32,
    }

    impl std::fmt::Display for Point {
        fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
            write!(f, "({}, {})", self.x, self.y)
        }
    }

    let p = Point { x: 5, y: 10 };
    println!("{}", p); // (5, 10)
    ```

- **`fmt()` (for `Debug`)**: Used to format the value for debugging output. This is often used with `{:?}`.

    ```rust
    #[derive(Debug)]
    struct Point {
        x: i32,
        y: i32,
    }

    let p = Point { x: 5, y: 10 };
    println!("{:?}", p); // Point { x: 5, y: 10 }
    ```

- **`dbg!()`**: A macro that prints the value and location in the code (file, line number) to help with debugging.

    ```rust
    let x = 5;
    dbg!(x); // [src/main.rs:2] x = 5
    ```

- **`to_string()`**: Converts any value that implements the `Display` trait to a `String`.

    ```rust
    let x = 5;
    let s = x.to_string(); // "5"
    ```

- **`debug_struct()`**: Creates a formatted `Debug` representation of a struct (usually used in custom implementations).

    ```rust
    use std::fmt;

    struct MyStruct { x: i32, y: i32 }

    impl fmt::Debug for MyStruct {
        fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
            f.debug_struct("MyStruct")
             .field("x", &self.x)
             .field("y", &self.y)
             .finish()
        }
    }

    let my_struct = MyStruct { x: 5, y: 10 };
    println!("{:?}", my_struct); // MyStruct { x: 5, y: 10 }
    ```

---

