## **Traits (`Eq`, `Ord`, `PartialEq`, `PartialOrd`) Methods**


These traits provide basic functionality for comparing values.

- **`eq()`**: Checks if two values are equal (`==` in Rust).

    ```rust
    let a = 5;
    let b = 5;
    println!("{}", a.eq(&b)); // true
    ```

- **`ne()`**: Checks if two values are not equal (`!=` in Rust).

    ```rust
    let a = 5;
    let b = 6;
    println!("{}", a.ne(&b)); // true
    ```

- **`cmp()`**: Compares two values and returns an ordering (`Ord` trait). The result can be `Ordering::Less`, `Ordering::Equal`, or `Ordering::Greater`.

    ```rust
    use std::cmp::Ordering;

    let a = 5;
    let b = 6;
    println!("{:?}", a.cmp(&b)); // Ordering::Less
    ```

- **`partial_cmp()`**: Similar to `cmp()`, but works for types that may not have total ordering (like floats).

    ```rust
    let a = 5.0;
    let b = 6.0;
    println!("{:?}", a.partial_cmp(&b)); // Some(Ordering::Less)
    ```

- **`ge()`**: Checks if a value is greater than or equal to another.

    ```rust
    let a = 3;
    let b = 5;
    println!("{}", a.ge(&b)); // false
    ```

- **`le()`**: Checks if a value is less than or equal to another.

    ```rust
    let a = 3;
    let b = 5;
    println!("{}", a.le(&b)); // true
    ```

- **`max_by()`**: Compares two values using a custom comparator and returns the maximum value.

    ```rust
    let a = 3;
    let b = 5;
    println!("{}", a.max_by(|x, y| x.cmp(y))); // 5
    ```

- **`min_by_key()`**: Finds the minimum based on a key extracted by a closure.

    ```rust
    let a = (3, 'a');
    let b = (5, 'b');
    println!("{:?}", a.min_by_key(|t| t.0)); // (3, 'a')
    ```


---

