## `Result<T, E>`


The Result<T, E> type is used for returning and propagating errors. A Result can either be:

Ok(T) – indicating success and containing a value of type T.

Err(E) – indicating failure and containing an error of type E.

**is_ok**

Returns true if the Result is Ok.

```rust
let x: Result<i32, &str> = Ok(10);
assert_eq!(x.is_ok(), true);
```

**is_err**

Returns true if the Result is Err.

```rust
let x: Result<i32, &str> = Err("Error!");
assert_eq!(x.is_err(), true);
```

**ok**

Converts a Result\<T, E> to an Option\<T>. If it's Ok, returns Some(T). If it's Err, returns None.

```rust
let x: Result<i32, &str> = Ok(10);
assert_eq!(x.ok(), Some(10));

let y: Result<i32, &str> = Err("Error!");
assert_eq!(y.ok(), None);
```

**err**

Converts a `Result<T, E>` to an `Option\<E>`. If it's `Err`, returns `Some(E)`. If it's `Ok`, returns `None`.

```rust
let x: Result<i32, &str> = Err("Error!");
assert_eq!(x.err(), Some("Error!"));

let y: Result<i32, &str> = Ok(10);
assert_eq!(y.err(), None);
```

**unwrap**

Returns the value T if the `Result` is `Ok`. If it's `Err`, the program will panic.

```rust
let x: Result<i32, &str> = Ok(10);
let val = x.unwrap(); // 10

// This would panic:
// let y: Result<i32, &str> = Err("Error!");
// y.unwrap();
```

**unwrap_or**

Returns the value T if the Result is Ok, otherwise returns a default value.

```rust
let x: Result<i32, &str> = Ok(10);
let val = x.unwrap_or(0); // 10

let y: Result<i32, &str> = Err("Error!");
let val = y.unwrap_or(0); // 0
```

**unwrap_or_else**

Similar to `unwrap_or`, but takes a closure to lazily evaluate the default value if the `Result` is `Err`.

```rust
let x: Result<i32, &str> = Ok(10);
let val = x.unwrap_or_else(|_| 0); // 10

let y: Result<i32, &str> = Err("Error!");
let val = y.unwrap_or_else(|e| {
    println!("Encountered error: {}", e);
    0
}); // 0
```

**map**

Transforms the Ok(T) value using the provided function, leaving the Err(E) value unchanged.

```rust
let x: Result<i32, &str> = Ok(10);
let result = x.map(|v| v * 2); // Ok(20)

let y: Result<i32, &str> = Err("Error!");
let result = y.map(|v| v * 2); // Err("Error!")
```

**map_err**

Transforms the `Err(E)` value using the provided function, leaving the `Ok(T)` value unchanged.

```rust
let x: Result<i32, &str> = Ok(10);
let result = x.map_err(|e| format!("Error: {}", e)); // Ok(10)

let y: Result<i32, &str> = Err("Error!");
let result = y.map_err(|e| format!("Error: {}", e)); // Err("Error: Error!")
```

**and**

If self is `Ok`, returns res. Otherwise, returns `Err(E)`.

```rust
let x: Result<i32, &str> = Ok(10);
let y: Result<i32, &str> = Ok(20);
assert_eq!(x.and(y), Ok(20));

let z: Result<i32, &str> = Err("Error!");
assert_eq!(x.and(z), Err("Error!"));
```

**and_then**

If self is `Ok`, calls the provided function f and returns the result. Otherwise, returns `Err(E)`.

```rust
let x: Result<i32, &str> = Ok(10);
let result = x.and_then(|v| Ok(v * 2)); // Ok(20)

let y: Result<i32, &str> = Err("Error!");
let result = y.and_then(|v| Ok(v * 2)); // Err("Error!")
```

**or**

If self is `Ok`, returns self. Otherwise, returns `res`.

```rust
let x: Result<i32, &str> = Err("Error!");
let y: Result<i32, &str> = Ok(20);
assert_eq!(x.or(y), Ok(20));

let z: Result<i32, &str> = Ok(10);
assert_eq!(z.or(y), Ok(10));
```

**or_else**

If self is `Err`, calls the provided function f and returns the result. Otherwise, returns `Ok(T)`.

```rust
let x: Result<i32, &str> = Err("Error!");
let result = x.or_else(|e| Ok(20)); // Ok(20)

let y: Result<i32, &str> = Ok(10);
let result = y.or_else(|e| Ok(20)); // Ok(10)
```

**unwrap_err**

Returns the contained error E if the `Result` is `Err`. Panics if the `Result` is `Ok`.

```rust
let x: Result<i32, &str> = Err("Error!");
let err = x.unwrap_err(); // "Error!"

// This would panic:
// let y: Result<i32, &str> = Ok(10);
// y.unwrap_err();
```

**flatten**

Converts a `Result<Result<T, E>, E>` to `Result<T, E>`. If it's `Ok(Ok(T))`, returns `Ok(T)`. If it's `Ok(Err(E))` or `Err(E)`, returns `Err(E)`.

```rust
let x: Result<Result<i32, &str>, &str> = Ok(Ok(10));
assert_eq!(x.flatten(), Ok(10));

let y: Result<Result<i32, &str>, &str> = Ok(Err("Error!"));
assert_eq!(y.flatten(), Err("Error!"));
```


**expect**

- **Signature**: `fn expect(self, msg: &str) -> T`
- **Purpose**: Unwraps the `Result`, yielding the value `T`. If the result is `Err`, it panics with a provided custom message.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Ok(42);
    let value = result.expect("Unexpected error");
    println!("Value: {}", value); // Output: Value: 42
    ```
    

**expect_err**

- **Signature**: `fn expect_err(self, msg: &str) -> E`
- **Purpose**: Unwraps the `Result`, yielding the error value `E`. If the result is `Ok`, it panics with a provided custom message.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Err("error occurred");
    let error = result.expect_err("Expected an error");
    println!("Error: {}", error); // Output: Error: error occurred
    ```


**as_ref**

- **Signature**: `fn as_ref(&self) -> Result<&T, &E>`
- **Purpose**: Converts from `Result<T, E>` to `Result<&T, &E>`, borrowing the contained value.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Ok(42);
    let borrowed = result.as_ref();
    println!("{:?}", borrowed); // Output: Ok(42)
    ```


**as_mut**

- **Signature**: `fn as_mut(&mut self) -> Result<&mut T, &mut E>`
- **Purpose**: Converts from `Result<T, E>` to `Result<&mut T, &mut E>`, mutably borrowing the contained value.
- **Example**:
    
    ```rust
    let mut result: Result<i32, &str> = Ok(42);
    if let Ok(v) = result.as_mut() {
        *v += 1;
    }
    println!("{:?}", result); // Output: Ok(43)
    ```


**transpose**

- **Signature**: `fn transpose(self) -> Option<Result<T, F>>`  
    Available when `E` implements `Into<Option<F>>`.
- **Purpose**: Converts a `Result<Option<T>, E>` into an `Option<Result<T, F>>`.
- **Example**:
    
    ```rust
    let result: Result<Option<i32>, &str> = Ok(Some(42));
    let option = result.transpose();
    println!("{:?}", option); // Output: Some(Ok(42))
    ```


**contains**

- **Signature**: `fn contains<U>(&self, x: &U) -> bool`  
    where `U: PartialEq<T>`
- **Purpose**: Checks if the contained value equals a given value.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Ok(42);
    println!("{}", result.contains(&42)); // Output: true
    ```


**contains_err**

- **Signature**: `fn contains_err<F>(&self, f: &F) -> bool`  
    where `F: PartialEq<E>`
- **Purpose**: Checks if the contained error equals a given value.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Err("error");
    println!("{}", result.contains_err(&"error")); // Output: true
    ```


**is_ok_and**

- **Signature**: `fn is_ok_and<F>(&self, f: F) -> bool`  
    where `F: FnOnce(&T) -> bool`
- **Purpose**: Returns `true` if the `Result` is `Ok` and the contained value satisfies the predicate.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Ok(42);
    println!("{}", result.is_ok_and(|&v| v > 40)); // Output: true
    ```


**is_err_and**

- **Signature**: `fn is_err_and<F>(&self, f: F) -> bool`  
    where `F: FnOnce(&E) -> bool`
- **Purpose**: Returns `true` if the `Result` is `Err` and the contained error satisfies the predicate.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Err("error");
    println!("{}", result.is_err_and(|&e| e == "error")); // Output: true
    ```


**inspect**

- **Signature**: `fn inspect<F>(self, f: F) -> Self`  
    where `F: FnOnce(&T)`
- **Purpose**: Executes a closure on the contained value if the result is `Ok`, and returns the original result.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Ok(42);
    result.inspect(|v| println!("Value: {}", v)); // Output: Value: 42
    ```


**inspect_err**

- **Signature**: `fn inspect_err<F>(self, f: F) -> Self`  
    where `F: FnOnce(&E)`
- **Purpose**: Executes a closure on the contained error if the result is `Err`, and returns the original result.
- **Example**:
    
    ```rust
    let result: Result<i32, &str> = Err("error");
    result.inspect_err(|e| println!("Error: {}", e)); // Output: Error: error
    ```


