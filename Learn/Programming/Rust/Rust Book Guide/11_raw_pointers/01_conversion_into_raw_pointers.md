## Conversion Into Raw Pointers


In Rust, various smart pointers provide methods to obtain mutable raw pointers. These methods are useful when working with FFI or performing manual memory manipulation while ensuring safe access. Below is a breakdown of **`as_mut_ptr`** and other similar methods.

---

### **`as_mut_ptr()` Methods**
These methods allow you to obtain a **mutable raw pointer** to the underlying value of a smart pointer or collection.

`**Box<T>::as_mut_ptr()**`
- Returns a mutable raw pointer to the contained value.
- Unlike `Box::into_raw`, this does **not** consume the `Box`, so it remains valid.

Example:
```rust
let mut boxed = Box::new(42);
let ptr: *mut i32 = boxed.as_mut_ptr();

// Mutate value via pointer
unsafe {
    *ptr = 100;
}

println!("Updated Boxed value: {}", boxed); // 100
```

---

**`Vec<T>::as_mut_ptr()`**
- Returns a raw mutable pointer to the start of the vector's buffer.
- The pointer is valid as long as the `Vec` is not reallocated (e.g., by `push` past capacity).

Example:
```rust
let mut vec = vec![1, 2, 3];
let ptr: *mut i32 = vec.as_mut_ptr();

// Modify first element via pointer
unsafe {
    *ptr = 99;
}

println!("Updated vector: {:?}", vec); // [99, 2, 3]
```

---

**`String::as_mut_ptr()`**
- Returns a mutable pointer to the start of the `String`'s buffer.

Example:
```rust
let mut s = String::from("Hello");
let ptr: *mut u8 = s.as_mut_ptr();

// Modify first character (requires `set_len` to avoid bounds checks)
unsafe {
    *ptr = b'J';
    s.as_mut_vec().set_len(5); // Ensure length remains valid
}

println!("Modified string: {}", s); // "Jello"
```

---

### **`as_ptr()` Methods**

- **`as_ptr()`** – Gets a read-only pointer to the data.
  - `Box<T>::as_ptr() -> *const T`
  - `Vec<T>::as_ptr() -> *const T`
  - `String::as_ptr() -> *const u8`
  
  Example:
  ```rust
  let vec = vec![10, 20, 30];
  let ptr = vec.as_ptr();

  unsafe {
      println!("First element: {}", *ptr); // 10
  }
  ```


