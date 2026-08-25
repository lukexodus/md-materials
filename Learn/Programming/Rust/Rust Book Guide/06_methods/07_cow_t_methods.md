## **`Cow<T>` Methods**


`Cow` is a clone-on-write type that allows you to borrow or own data in a way that minimizes unnecessary cloning.

- **`into_owned()`**: Converts a `Cow` into an owned value.

    ```rust
    use std::borrow::Cow;

    let cow: Cow<str> = Cow::Borrowed("hello");
    let owned = cow.into_owned();
    println!("Owned: {}", owned);
    ```

- **`borrow()`**: Returns a reference to the borrowed data.

    ```rust
    let cow: Cow<str> = Cow::Borrowed("hello");
    let borrowed = cow.borrow();
    println!("Borrowed: {}", borrowed);
    ```

- **`to_mut()`**: Returns a mutable reference, cloning the data if it was borrowed.

    ```rust
    let mut cow: Cow<str> = Cow::Borrowed("hello");
    let mut_ref = cow.to_mut();
    mut_ref.push_str(" world");
    println!("Mutated: {}", cow);
    ```

