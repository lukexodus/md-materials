## **`Clone` and `Copy` Traits Methods**


- **`clone()`**: Performs a deep copy of the value.

    ```rust
    let vec = vec![1, 2, 3];
    let vec_clone = vec.clone();
    ```

- **`copy()`**: Unlike `clone`, `Copy` types are duplicated automatically when assigned. This is done for types that implement the `Copy` trait (e.g., integers).

    ```rust
    let x = 5;
    let y = x; // Copy happens here; both x and y are valid
    ```

- **`copy_from_slice()`**: Copies elements from one slice into another.

    ```rust
    let mut dst = [0, 0, 0];
    let src = [1, 2, 3];
    dst.copy_from_slice(&src);
    ```

- **`try_clone()`**: A method used in IO types that implement `Clone`, and it returns a `Result` instead of a plain clone.

    ```rust
    use std::fs::File;
    let file = File::open("example.txt").unwrap();
    let clone = file.try_clone().unwrap();
    ```

---

