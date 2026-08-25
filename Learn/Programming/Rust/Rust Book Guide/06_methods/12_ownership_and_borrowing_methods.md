## **Ownership and Borrowing Methods**


Rust’s ownership and borrowing system uses methods to transfer or reference data in a safe way.

- **`to_owned()`**: Converts a borrowed type to an owned version. For instance, `&str` can be converted to `String`.

    ```rust
    let s: &str = "hello";
    let owned: String = s.to_owned();
    ```

- **`clone()`**: Creates a deep copy of the value. Used to duplicate data that implements the `Clone` trait.

    ```rust
    let vec = vec![1, 2, 3];
    let vec_clone = vec.clone();
    ```

- **`borrow()` and `borrow_mut()`**: Used with smart pointers like `RefCell` to borrow references to the inner data. These provide safe borrowing for both mutable and immutable references.

    ```rust
    use std::cell::RefCell;

    let data = RefCell::new(5);
    let borrowed = data.borrow(); // Immutable borrow
    let mut borrowed_mut = data.borrow_mut(); // Mutable borrow
    *borrowed_mut += 1;
    ```

- **`as_ref()`**: Converts an `Option<T>` into an `Option<&T>`. Often used to borrow data in an `Option` without taking ownership.

    ```rust
    let x: Option<String> = Some(String::from("hello"));
    let y: Option<&String> = x.as_ref();
    ```

- **`as_mut()`**: Similar to `as_ref()`, but returns a mutable reference to the data inside `Option<T>`.

    ```rust
    let mut x: Option<String> = Some(String::from("hello"));
    let y: Option<&mut String> = x.as_mut();
    ```

- **`into_boxed_slice()`**: Converts a `Vec` into a `Box<[T]>`, transferring ownership of the vector data into the heap.

    ```rust
    let vec = vec![1, 2, 3];
    let boxed_slice: Box<[i32]> = vec.into_boxed_slice();
    ```

- **`split_at_mut()`**: Mutably borrows a slice and splits it into two at a given index.

    ```rust
    let mut numbers = [1, 2, 3, 4, 5];
    let (first, second) = numbers.split_at_mut(2);
    first[0] = 10;
    ```


---

