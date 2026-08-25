## **`Box<T>` Methods**


`Box` is a smart pointer for heap-allocated memory.

- **`new(value)`**: Creates a new `Box`.

    ```rust
    let boxed = Box::new(5);
    println!("Boxed value: {}", boxed);
    ```

- **`into_inner()`**: Consumes the `Box` and returns the contained value.

    ```rust
    let value = *boxed;
    println!("Unboxed value: {}", value);
    ```

- **`deref()`**: Dereferences the `Box` to access the value (automatically dereferenced in most cases).

    ```rust
    let boxed = Box::new(10);
    let deref_val = *boxed;
    println!("Dereferenced value: {}", deref_val);
    ```

- **`as_ref()`**: Converts a `Box<T>` into a reference `&T`.

    ```rust
    let boxed = Box::new(5);
    let ref_val = boxed.as_ref();
    println!("Box as reference: {}", ref_val);
    ```

- **`as_mut()`**: Converts a `Box<T>` into a mutable reference `&mut T`.

    ```rust
    let mut boxed = Box::new(5);
    let mut_ref = boxed.as_mut();
    *mut_ref += 1;
    println!("Box as mutable reference: {}", mut_ref);
    ```

- **`leak()`**: Consumes the `Box` and returns a mutable reference to the contained value with a `'static` lifetime. The value will no longer be automatically dropped when the program ends.

    ```rust
    let boxed = Box::new(42);
    let leaked = Box::leak(boxed);
    *leaked += 1;
    println!("Leaked value: {}", leaked);
    ```

- **`from_raw(ptr)`**: Converts a raw pointer into a `Box`. This method is unsafe because it assumes the raw pointer is valid and was previously allocated with `Box`.

    ```rust
    use std::ptr;

    let boxed = Box::new(100);
    let raw = Box::into_raw(boxed);

    unsafe {
        let boxed_again = Box::from_raw(raw);
        println!("Recovered from raw pointer: {}", boxed_again);
    }
    ```

- **`into_raw(box)`**: Consumes the `Box` and returns a raw pointer to the contained value. You are responsible for managing the memory.

    ```rust
    let boxed = Box::new(20);
    let raw = Box::into_raw(boxed);
    println!("Raw pointer: {:?}", raw);
    ```

- **`try_new(value)`** *(nightly only)*: Attempts to create a new `Box` with the given value and returns a `Result`. This is useful if the allocation might fail.

    ```rust
    #![feature(try_reserve)]

    let result: Result<Box<i32>, _> = Box::try_new(99);
    match result {
        Ok(boxed) => println!("Successfully created: {}", boxed),
        Err(e) => println!("Failed to allocate: {}", e),
    }
    ```
    

