## Option\<T\>


**is_some**

Returns true if the Option is Some(T).

Example:

```rust
let x: Option<i32> = Some(5);
println!("{}", x.is_some()); // true
```

**is_none**

Returns true if the Option is None.

Example:

```rust
let x: Option<i32> = None;
println!("{}", x.is_none()); // true
```

**unwrap**

Returns the contained value of Some(T). Panics if the Option is None.

Example:

```rust
let x: Option<i32> = Some(5);
let y = x.unwrap(); // 5

let z: Option<i32> = None;
// z.unwrap(); // Panics if uncommented
```


**unwrap_or**

Returns the contained value or a default if the Option is None.

Example:

```rust
let x: Option<i32> = Some(5);
let y = x.unwrap_or(0); // 5

let z: Option<i32> = None;
let w = z.unwrap_or(0); // 0
```

**unwrap_or_else**

Similar to unwrap_or, but takes a closure to lazily evaluate the default value if the Option is None.

Example:

```rust
let x: Option<i32> = Some(5);
let y = x.unwrap_or_else(|| 0); // 5

let z: Option<i32> = None;
let w = z.unwrap_or_else(|| 0); // 0
```


**map**

Transforms the value inside Some(T) using the provided function and returns Some of the new value, or returns None if the Option is None.

Example:

```rust
let x: Option<i32> = Some(5);
let y = x.map(|val| val * 2); // Some(10)

let z: Option<i32> = None;
let w = z.map(|val| val * 2); // None
```


**map_or**

Similar to map, but returns a default value if the Option is None.

Example:

```rust
let x: Option<i32> = Some(5);
let y = x.map_or(0, |val| val * 2); // 10

let z: Option<i32> = None;
let w = z.map_or(0, |val| val * 2); // 0
```


**map_or_else**

Similar to map_or, but takes a closure to lazily evaluate the default value if the Option is None.

Example:

```rust
let x: Option<i32> = Some(5);
let y = x.map_or_else(|| 0, |val| val * 2); // 10

let z: Option<i32> = None;
let w = z.map_or_else(|| 0, |val| val * 2); // 0
```


**and**

Returns None if the original Option is None, otherwise returns optb.

Example:

```rust
let x: Option<i32> = Some(5);
let y: Option<&str> = Some("hello");
let result = x.and(y); // Some("hello")

let x: Option<i32> = None;
let result = x.and(y); // None
```


**and_then**

Similar to and, but allows you to provide a function to produce the new Option.

Example:

```rust
let x: Option<i32> = Some(5);
let result = x.and_then(|val| Some(val * 2)); // Some(10)

let y: Option<i32> = None;
let result = y.and_then(|val| Some(val * 2)); // None
```


**or**

Returns `optb` if the original `Option` is `None`, otherwise returns the original `Option`.

Example:

```rust
let x: Option<i32> = Some(5);
let y: Option<i32> = None;
let result = x.or(y); // Some(5)

let x: Option<i32> = None;
let result = x.or(Some(10)); // Some(10)
```

**or_else**

Similar to `or`, but allows you to provide a closure to produce the new `Option`.

Example:

```rust
let x: Option<i32> = None;
let result = x.or_else(|| Some(10)); // Some(10)
```

**filter**

Returns `None` if the original `Option` is `None` or if the predicate function returns `false`. Otherwise, returns the original `Option`.

Example:

```rust
let x: Option<i32> = Some(5);
let result = x.filter(|&val| val > 3); // Some(5)
let result = x.filter(|&val| val < 3); // None
```


**ok_or**

Converts an `Option<T>` to a `Result<T, E>`, returning an `Ok` value if `Some`, or an `Err` with a provided error value if `None`.

Example:

```rust
let x: Option<i32> = Some(5);
let result: Result<i32, &str> = x.ok_or("Error!"); // Ok(5)

let y: Option<i32> = None;
let result: Result<i32, &str> = y.ok_or("Error!"); // Err("Error!")
```


**ok_or_else**

Similar to ok_or, but lazily evaluates the error value using a closure if the Option is None.

Example:

```rust
let x: Option<i32> = None;
let result: Result<i32, &str> = x.ok_or_else(|| "Error!"); // Err("Error!")
```

**flatten**

Converts an `Option<Option<T>>` to `Option<T>`. If it’s `Some(Some(T))`, it returns `Some(T)`. If it’s `Some(None)` or `None`, it returns `None`.

Example:

```rust
let x: Option<Option<i32>> = Some(Some(5));
let result = x.flatten(); // Some(5)

let y: Option<Option<i32>> = Some(None);
let result = y.flatten(); // None
```

**copied**

Creates a new `Option` by copying the value inside, assuming the value implements the `Copy` trait.

Example:

```rust
let x = Some(42);
let y = x.copied(); // Copies the value, resulting in `Some(42)`
let z: Option<i32> = None;
let w = z.copied(); // Still `None`
```

**expect**

- **Signature**: `fn expect(self, msg: &str) -> T`
- **Purpose**: Unwraps the `Option`, yielding the contained value. Panics with the provided message if the `Option` is `None`.
- **Example**:
    
    ```rust
    let value = Some(42).expect("Value is missing");
    println!("Value: {}", value); // Output: Value: 42
    ```


**expect_none**

- **Signature**: `fn expect_none(self, msg: &str)`
- **Purpose**: Ensures the `Option` is `None`. Panics with the provided message if it contains `Some`.
- **Example**:
    
    ```rust
    let none_value: Option<i32> = None;
    none_value.expect_none("Expected None"); // No panic
    ```


**contains**

- **Signature**: `fn contains<U>(&self, x: &U) -> bool` where `U: PartialEq<T>`
- **Purpose**: Checks if the `Option` contains a value equal to the given value.
- **Example**:
    
    ```rust
    let opt = Some(42);
    println!("{}", opt.contains(&42)); // Output: true
    ```


**as_ref**

- **Signature**: `fn as_ref(&self) -> Option<&T>`
- **Purpose**: Converts the `Option<T>` into `Option<&T>`, borrowing the value.
- **Example**:
    
    ```rust
    let opt = Some(42);
    if let Some(v) = opt.as_ref() {
        println!("Borrowed value: {}", v); // Output: Borrowed value: 42
    }
    ```


**as_mut**

- **Signature**: `fn as_mut(&mut self) -> Option<&mut T>`
- **Purpose**: Converts the `Option<T>` into `Option<&mut T>`, borrowing the value mutably.
- **Example**:
    
    ```rust
    let mut opt = Some(42);
    if let Some(v) = opt.as_mut() {
        *v += 1;
    }
    println!("{:?}", opt); // Output: Some(43)
    ```


**get_or_insert**

- **Signature**: `fn get_or_insert(&mut self, value: T) -> &mut T`
- **Purpose**: Inserts the provided value if the `Option` is `None`, then returns a mutable reference to the contained value.
- **Example**:
    
    ```rust
    let mut opt = None;
    let v = opt.get_or_insert(42);
    println!("{}", v); // Output: 42
    ```


**get_or_insert_with**

- **Signature**: `fn get_or_insert_with<F>(&mut self, f: F) -> &mut T` where `F: FnOnce() -> T`
- **Purpose**: Inserts a value computed by the provided closure if the `Option` is `None`, then returns a mutable reference to the contained value.
- **Example**:
    
    ```rust
    let mut opt = None;
    let v = opt.get_or_insert_with(|| 42);
    println!("{}", v); // Output: 42
    ```


**replace**

- **Signature**: `fn replace(&mut self, value: T) -> Option<T>`
- **Purpose**: Replaces the contained value with the given value, returning the old value.
- **Example**:
    
    ```rust
    let mut opt = Some(10);
    let old = opt.replace(42);
    println!("{:?}, {:?}", opt, old); // Output: Some(42), Some(10)
    ```


**take**

- **Signature**: `fn take(&mut self) -> Option<T>`
- **Purpose**: Takes the value out of the `Option`, leaving it as `None`.
- **Example**:
    
    ```rust
    let mut opt = Some(42);
    let taken = opt.take();
    println!("{:?}, {:?}", opt, taken); // Output: None, Some(42)
    ```


**zip**

- **Signature**: `fn zip<U>(self, other: Option<U>) -> Option<(T, U)>`
- **Purpose**: Combines two `Option`s into a single `Option` containing a tuple of the values, or `None` if either is `None`.
- **Example**:
    
    ```rust
    let a = Some(1);
    let b = Some(2);
    let zipped = a.zip(b);
    println!("{:?}", zipped); // Output: Some((1, 2))
    ```


**zip_with**

- **Signature**: `fn zip_with<U, F>(self, other: Option<U>, f: F) -> Option<R>` where `F: FnOnce(T, U) -> R`
- **Purpose**: Combines two `Option`s using a provided closure to produce a single value.
- **Example**:
    
    ```rust
    let a = Some(2);
    let b = Some(3);
    let result = a.zip_with(b, |x, y| x + y);
    println!("{:?}", result); // Output: Some(5)
    ```


**unzip**

- **Signature**: `fn unzip<A, B>(self) -> (Option<A>, Option<B>)` where `T: Into<(A, B)>`
- **Purpose**: Splits an `Option` containing a tuple into two `Option`s, one for each element of the tuple.
- **Example**:
    
    ```rust
    let opt = Some((1, "Rust"));
    let (a, b) = opt.unzip();
    println!("{:?}, {:?}", a, b); // Output: Some(1), Some("Rust")
    ```


**inspect**

- **Signature**: `fn inspect<F>(self, f: F) -> Self` where `F: FnOnce(&T)`
- **Purpose**: Runs a closure on the contained value if the `Option` is `Some`, and returns the original `Option`.
- **Example**:
    
    ```rust
    let opt = Some(42);
    opt.inspect(|v| println!("Value: {}", v)); // Output: Value: 42
    ```


***

