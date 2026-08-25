## **`Cell<T>` Methods**


`Cell` allows for copying in and out of the contained value without borrowing.

- **`set(value)`**: Sets the value.

    ```rust
    use std::cell::Cell;

    let cell = Cell::new(5);
    cell.set(10);
    println!("Cell value: {}", cell.get());
    ```

- **`get()`**: Returns the current value.

    ```rust
    let value = cell.get();
    println!("Value: {}", value);
    ```

- **`replace(new_value)`**: Replaces the current value and returns the old value.

    ```rust
    let old_value = cell.replace(20);
    println!("Old value: {}", old_value);
    ```

