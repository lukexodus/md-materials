## **Error Handling Methods**


Error handling is mainly done through the `Result<T, E>` type.

- **`expect(msg)`**: Like `unwrap()`, but provides a custom error message if the value is `Err`.

    ```rust
    let result: Result<i32, &str> = Err("error");
    let value = result.expect("Failed to get value"); // Panics with "Failed to get value: error"
    ```

- **`unwrap()`**: Unwraps the `Result`, returning the `Ok` value or panicking if it’s an `Err`.

    ```rust
    let result: Result<i32, &str> = Ok(5);
    let value = result.unwrap(); // 5
    ```

- **`unwrap_or_default()`**: Returns the contained `Ok` value or the default for `T` if the value is `Err`.

    ```rust
    let result: Result<i32, &str> = Err("error");
    let value = result.unwrap_or_default(); // 0 (default for i32)
    ```

- **`and_then()`**: Similar to `map()`, but the function returns a `Result` instead of a plain value.

    ```rust
    let result: Result<i32, &str> = Ok(5);
    let doubled = result.and_then(|val| Ok(val * 2)); // Ok(10)
    ```

- **`or_else()`**: Calls a closure if the result is `Err`, allowing you to generate a new `Result`.

    ```rust
    let result: Result<i32, &str> = Err("error");
    let value = result.or_else(|_err| Ok(10)); // Ok(10)
    ```

- **`map_err(f)`**: Applies a function to the `Err` variant of `Result`, allowing you to transform the error type.

    ```rust
    let result: Result<i32, &str> = Err("error");
    let mapped_err = result.map_err(|e| format!("{}!", e));
    println!("{:?}", mapped_err); // Err("error!")
    ```

- **`ok()`**: Converts a `Result` into an `Option`, discarding the error.

    ```rust
    let result: Result<i32, &str> = Ok(5);
    let value = result.ok();
    println!("{:?}", value); // Some(5)
    ```

---

