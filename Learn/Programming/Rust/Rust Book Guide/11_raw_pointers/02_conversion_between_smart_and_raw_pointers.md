## Conversion Between Smart And Raw Pointers


In Rust, `Box`, `Rc`, and `Arc` provide methods for converting to and from raw pointers. These conversions are useful when interfacing with unsafe code (e.g., FFI) but must be handled carefully to avoid memory leaks or double frees.

---

### **1. `Box<T>` Conversions**
`Box<T>` is a heap-allocated value that provides methods for conversion to and from raw pointers.

**To raw pointer**
- **`Box::into_raw(boxed: Box<T>) -> *mut T`**  
  - Consumes the `Box`, returning a raw pointer.
  - The caller is responsible for managing the memory.

```rust
let boxed = Box::new(10);
let raw: *mut i32 = Box::into_raw(boxed);
println!("Raw pointer: {:?}", raw);
```

**From raw pointer**
- **`Box::from_raw(ptr: *mut T) -> Box<T>`** *(unsafe)*
  - Converts a raw pointer back into a `Box`, taking ownership.
  - The pointer **must** have been created by `Box::into_raw`.

```rust
let boxed = Box::new(20);
let raw = Box::into_raw(boxed);

unsafe {
    let boxed_again = Box::from_raw(raw);
    println!("Recovered value: {}", boxed_again);
}
```

---

### **2. `Rc<T>` Conversions**
`Rc<T>` is a reference-counted smart pointer for single-threaded use.

**To raw pointer**
- **`Rc::into_raw(rc: Rc<T>) -> *const T`**  
  - Consumes the `Rc` and returns a raw pointer.
  - The reference count is **not decremented**.

```rust
use std::rc::Rc;

let rc = Rc::new(30);
let raw: *const i32 = Rc::into_raw(rc);
println!("Raw pointer: {:?}", raw);
```

**From raw pointer**
- **`Rc::from_raw(ptr: *const T) -> Rc<T>`** *(unsafe)*
  - Creates an `Rc` from a raw pointer.
  - **Does not** increment the reference count, so the pointer must be valid.

```rust
use std::rc::Rc;

let rc = Rc::new(40);
let raw = Rc::into_raw(Rc::clone(&rc));

unsafe {
    let rc_again = Rc::from_raw(raw);
    println!("Recovered value: {}", rc_again);
}
```

---

### **3. `Arc<T>` Conversions**
`Arc<T>` is an atomic reference-counted smart pointer for multi-threaded use.

**To raw pointer**
- **`Arc::into_raw(arc: Arc<T>) -> *const T`**  
  - Converts an `Arc` into a raw pointer.
  - The reference count is not decremented.

```rust
use std::sync::Arc;

let arc = Arc::new(50);
let raw: *const i32 = Arc::into_raw(arc);
println!("Raw pointer: {:?}", raw);
```

**From raw pointer**
- **`Arc::from_raw(ptr: *const T) -> Arc<T>`** *(unsafe)*
  - Converts a raw pointer back into an `Arc`.
  - Does not increment the reference count.

```rust
use std::sync::Arc;

let arc = Arc::new(60);
let raw = Arc::into_raw(Arc::clone(&arc));

unsafe {
    let arc_again = Arc::from_raw(raw);
    println!("Recovered value: {}", arc_again);
}
```

---

### **4. `NonNull<T>` for Non-Zero Raw Pointers**
`NonNull<T>` is a wrapper around `*mut T` that guarantees the pointer is never null.

- **`Box<T>::into_raw_non_null(Box<T>) -> NonNull<T>`**
- **`Rc<T>::into_raw_non_null(Rc<T>) -> NonNull<T>`**
- **`Arc<T>::into_raw_non_null(Arc<T>) -> NonNull<T>`**

Example:

```rust
use std::ptr::NonNull;

let boxed = Box::new(70);
let non_null = NonNull::new(Box::into_raw(boxed)).unwrap();
println!("Non-null pointer: {:?}", non_null);
```

---

### **Safety Considerations**
- When converting a smart pointer into a raw pointer, **do not deallocate it manually** unless ownership is transferred back using `from_raw`.
- `from_raw` must only be called **once** per raw pointer, or memory will be freed multiple times.
- `Rc` and `Arc` rely on reference counting, so dropping the last strong reference will **deallocate the value**, making the raw pointer **dangling**.

---

**Summary Table**

| Smart Pointer | To Raw Pointer | From Raw Pointer |
|--------------|------------------------|----------------------|
| **`Box<T>`** | `Box::into_raw(Box<T>) -> *mut T` | `Box::from_raw(*mut T) -> Box<T>` |
| **`Rc<T>`**  | `Rc::into_raw(Rc<T>) -> *const T` | `Rc::from_raw(*const T) -> Rc<T>` |
| **`Arc<T>`** | `Arc::into_raw(Arc<T>) -> *const T` | `Arc::from_raw(*const T) -> Arc<T>` |
| **`NonNull<T>`** | `Box::into_raw_non_null(Box<T>) -> NonNull<T>` | `NonNull::new(ptr: *mut T) -> Option<NonNull<T>>` |

These methods allow for safe and efficient interoperability with raw pointers when necessary.

