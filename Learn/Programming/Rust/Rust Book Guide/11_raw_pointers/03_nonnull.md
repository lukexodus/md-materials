## `NonNull`


`NonNull<T>` is a wrapper around `*mut T` (a raw pointer) that **guarantees** the pointer is **never null**. It is useful for working with raw pointers in a safe way while avoiding `Option<T>`-wrapped pointers (which require extra space for the `None` case).

---

### **Creating a `NonNull<T>`**
You can create a `NonNull<T>` from an existing reference, `Box<T>`, or raw pointer.

**Using `NonNull::new()`**
`NonNull::new(ptr: *mut T) -> Option<NonNull<T>>`
- If the pointer is `null`, returns `None`.
- Otherwise, returns `Some(NonNull<T>)`.

Example:
```rust
use std::ptr::NonNull;

let mut value = 42;
let ptr: *mut i32 = &mut value;
let non_null = NonNull::new(ptr).unwrap();

println!("NonNull pointer: {:?}", non_null);
```

---

**Using `NonNull::from()`**
`NonNull::from(reference: &mut T) -> NonNull<T>`
- Converts a reference into a `NonNull<T>`, ensuring it is never null.

#### Example:
```rust
use std::ptr::NonNull;

let mut value = 100;
let non_null = NonNull::from(&mut value);

println!("NonNull pointer: {:?}", non_null);
```

---

### **Using `NonNull<T>`**
Since `NonNull<T>` ensures the pointer is non-null, it is useful for handling raw pointers safely.

**Dereferencing a `NonNull<T>`**
Since `NonNull<T>` does not implement `Deref`, you must **explicitly dereference** it using `as_ptr()`.

Example:
```rust
use std::ptr::NonNull;

let mut value = 7;
let non_null = NonNull::from(&mut value);

unsafe {
    *non_null.as_ptr() = 42; // Modifying value via NonNull
}

println!("Updated value: {}", value); // 42
```

---

### **`NonNull<T>` vs. Raw Pointers**
| Feature        | `*mut T` / `*const T` | `NonNull<T>` |
|---------------|----------------|-------------|
| Can be null?  | Yes            | No          |
| Safe to use?  | No (unsafe)     | Yes (ensures non-null) |
| Size overhead | No extra space  | No extra space |
| Dereferencing | `unsafe`        | `unsafe`    |

---

### **Use Cases for `NonNull<T>`**
- **Intrusive data structures** (e.g., linked lists).
- **Custom smart pointers** where null pointers are invalid.
- **FFI (Foreign Function Interface)** where nullable pointers should be avoided.

---

**Example: Using `NonNull<T>` in a Custom Smart Pointer**

Here’s how `NonNull<T>` can be used in a custom **reference-counted** smart pointer.

```rust
use std::ptr::NonNull;
use std::alloc::{alloc, dealloc, Layout};
use std::mem;

struct MyBox<T> {
    ptr: NonNull<T>,
}

impl<T> MyBox<T> {
    fn new(value: T) -> Self {
        let layout = Layout::new::<T>();
        unsafe {
            let raw_ptr = alloc(layout) as *mut T;
            if raw_ptr.is_null() {
                panic!("Allocation failed");
            }
            raw_ptr.write(value);
            MyBox { ptr: NonNull::new(raw_ptr).unwrap() }
        }
    }

    fn get(&self) -> &T {
        unsafe { self.ptr.as_ref() }
    }
}

impl<T> Drop for MyBox<T> {
    fn drop(&mut self) {
        let layout = Layout::new::<T>();
        unsafe {
            dealloc(self.ptr.as_ptr() as *mut u8, layout);
        }
    }
}

fn main() {
    let my_box = MyBox::new(123);
    println!("MyBox contains: {}", my_box.get());
}
```
This example manually manages memory while ensuring `ptr` is always valid.

---

**Conclusion**
- `NonNull<T>` is a safer alternative to raw pointers, ensuring they are never null.
- It is useful for FFI, custom smart pointers, and intrusive data structures.
- Unlike `*mut T`, `NonNull<T>` prevents accidental null dereferences, reducing unsafe errors.

