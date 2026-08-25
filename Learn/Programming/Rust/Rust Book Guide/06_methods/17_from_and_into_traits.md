## **`From` and `Into` Traits**


These traits allow for generic type conversion.

- **`from()`**: Converts one type into another. It is implemented automatically when you implement the `From` trait for your type.

    ```rust
    let s = String::from("hello");
    let i = i32::from(5); // i32::from is implemented for integers
    ```

- **`into()`**: Similar to `from()`, but it allows the destination type to be inferred. You can call `.into()` to convert a value to a different type.

    ```rust
    let s: String = "hello".into();
    let i: i32 = 5.into();
    ```

- **`try_from()` and `try_into()`**: These are fallible versions of `from()` and `into()`. They return a `Result<T, E>` instead of directly converting between types.

    ```rust
    use std::convert::TryFrom;

    let s = "10";
    let num = i32::try_from(s.parse::<i32>().unwrap()).unwrap();
    ```

---

