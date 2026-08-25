## Raw Pointer Methods


| Method                     | Description |
|----------------------------|-------------|
| **`is_null()`**            | Checks if the pointer is null. |
| **`as_ref()`**             | Converts `*const T` into `Option<&T>`. |
| **`as_mut()`**             | Converts `*mut T` into `Option<&mut T>`. |
| **`add(offset)`**          | Offsets a pointer by `offset` elements (like array indexing). |
| **`offset(count)`**        | Similar to `add()`, but allows negative offsets. |
| **`read()`**               | Reads the value at the pointer location. |
| **`write(val)`**           | Writes a value to the pointer location. |
| **`copy_to(dest, count)`** | Copies `count` elements from one pointer to another. |
| **`copy_nonoverlapping(dest, count)`** | Like `copy_to()`, but for non-overlapping memory. |

---


### **Checking for Null (`is_null()`)**

```rust
let ptr: *const i32 = std::ptr::null();
if ptr.is_null() {
    println!("Pointer is null");
}
```

### **Converting to References (`as_ref()`, `as_mut()`)**

- **`as_ref()`**: Converts `*const T` to `Option<&T>` (safe to use).
- **`as_mut()`**: Converts `*mut T` to `Option<&mut T>`.

```rust
let value = 50;
let ptr: *const i32 = &value;

if let Some(reference) = unsafe { ptr.as_ref() } {
    println!("Dereferenced value: {}", reference);
}
```

---

### **Pointer Arithmetic (`add()`, `offset()`)**

These methods are useful for iterating over memory blocks.

```rust
let array = [10, 20, 30];
let ptr: *const i32 = array.as_ptr();

unsafe {
    println!("First: {}", *ptr);
    println!("Second: {}", *ptr.add(1));
    println!("Third: {}", *ptr.offset(2));
}
```

> **Note:** `offset()` allows negative indices, while `add()` does not.

---

### **Reading and Writing Values (`read()`, `write()`)**
- **`read()`**: Reads a value without consuming the original ownership.
- **`write()`**: Writes to a memory location.

```rust
let mut value = 99;
let ptr: *mut i32 = &mut value;

unsafe {
    ptr.write(42);
    println!("Updated value: {}", ptr.read());
}
```

---

### **Copying Memory (`copy_to()`, `copy_nonoverlapping()`)**
- `copy_to()` allows overlapping memory (like `memmove` in C).
- `copy_nonoverlapping()` assumes non-overlapping regions (like `memcpy`).

```rust
use std::ptr;

let mut src = [1, 2, 3];
let mut dst = [0; 3];

unsafe {
    ptr::copy_nonoverlapping(src.as_ptr(), dst.as_mut_ptr(), 3);
}

println!("Copied array: {:?}", dst); // [1, 2, 3]
```

---

**Example: Using Raw Pointers in a Custom Struct**

```rust
use std::ptr;
use std::alloc::{alloc, dealloc, Layout};

struct RawBox {
    ptr: *mut i32,
}

impl RawBox {
    fn new(value: i32) -> Self {
        let layout = Layout::new::<i32>();
        unsafe {
            let ptr = alloc(layout) as *mut i32;
            if ptr.is_null() {
                panic!("Allocation failed");
            }
            ptr.write(value);
            RawBox { ptr }
        }
    }

    fn get(&self) -> i32 {
        unsafe { self.ptr.read() }
    }
}

impl Drop for RawBox {
    fn drop(&mut self) {
        let layout = Layout::new::<i32>();
        unsafe {
            dealloc(self.ptr as *mut u8, layout);
        }
    }
}

fn main() {
    let raw_box = RawBox::new(123);
    println!("Stored value: {}", raw_box.get());
}
```
Here, `RawBox` manually allocates and deallocates memory using raw pointers.

---

### **Pointer Validation and Conversion**
These methods help with checking and converting raw pointers.

#### **`is_aligned()`** *(Nightly-only)*
- Checks if a pointer is properly aligned for its type.
- Similar to `ptr.align_offset(align) == 0`.

```rust
#![feature(ptr_is_aligned)] // Nightly feature

let x = 10;
let ptr = &x as *const i32;

assert!(ptr.is_aligned());
```

---

#### **`align_offset(align: usize) -> usize`**
- Returns how many bytes the pointer is misaligned by.
- Useful for working with SIMD or manually allocated memory.

```rust
let x = 10;
let ptr = &x as *const i32;

let alignment = ptr.align_offset(4);
println!("Alignment offset: {}", alignment); // Should be 0
```

---

#### **`guaranteed_eq(ptr2) -> bool`** *(Nightly-only)*
- Checks if two pointers **definitely** point to the same address.
- More strict than `ptr1 == ptr2`.

```rust
#![feature(ptr_guaranteed_eq)] // Nightly feature

let x = 42;
let ptr1 = &x as *const i32;
let ptr2 = &x as *const i32;

assert!(ptr1.guaranteed_eq(ptr2));
```

---

### **Pointer Arithmetic and Address Manipulation**
These methods allow moving, checking, and modifying pointer addresses.

#### **`wrapping_add(n) -> *const T / *mut T`**
- Moves the pointer forward by `n` elements.
- Unlike `add()`, **it does not panic on overflow**.

```rust
let arr = [1, 2, 3];
let ptr = arr.as_ptr();

unsafe {
    let new_ptr = ptr.wrapping_add(1);
    println!("Second element: {}", *new_ptr); // 2
}
```

---

#### **`wrapping_offset(n) -> *const T / *mut T`**
- Moves the pointer forward/backward by `n` elements.
- Unlike `offset()`, it does **not** cause UB (Undefined Behavior) on out-of-bounds moves.

```rust
let arr = [10, 20, 30];
let ptr = arr.as_ptr();

unsafe {
    let new_ptr = ptr.wrapping_offset(2);
    println!("Third element: {}", *new_ptr); // 30
}
```

---

#### **`cast<U>() -> *const U / *mut U`**
- Casts a pointer to another type.
- Useful when working with raw bytes (`u8`) or FFI.

```rust
let x: i32 = 123;
let ptr = &x as *const i32;
let byte_ptr = ptr.cast::<u8>(); // Now it's a pointer to a byte
```

---

### **Memory Operations**
These methods are useful for working with **manual memory management**.

#### **`swap(ptr2)`**
- Swaps the values at two valid pointers.

```rust
use std::ptr;

let mut a = 10;
let mut b = 20;

unsafe {
    ptr::swap(&mut a, &mut b);
}

println!("a: {}, b: {}", a, b); // a: 20, b: 10
```

---

#### **`replace(val) -> T`**
- Replaces the value at the pointer and returns the old value.
- Works like `std::mem::replace()` but for raw pointers.

```rust
use std::ptr;

let mut x = 100;
let ptr = &mut x as *mut i32;

unsafe {
    let old = ptr.replace(200);
    println!("Old: {}, New: {}", old, *ptr); // Old: 100, New: 200
}
```

---

#### **`drop_in_place()`**
- Drops the value at a pointer **without deallocating**.
- Used for manual memory management.

```rust
use std::ptr;

let mut x = String::from("Hello");
let ptr = &mut x as *mut String;

unsafe {
    ptr::drop_in_place(ptr);
}

// x is no longer valid after drop_in_place
```

---

### **Unsafe Dereferencing**
### **`read_volatile()` and `write_volatile()`**
- Used to **read/write** memory that can be changed by **hardware** or **concurrent processes**.
- Common in embedded systems and low-level FFI.

```rust
use std::ptr;

let mut value = 42;
let ptr = &mut value as *mut i32;

unsafe {
    let v = ptr::read_volatile(ptr);
    println!("Read volatile: {}", v);

    ptr::write_volatile(ptr, 99);
    println!("Updated volatile: {}", value);
}
```

---

**Summary of Raw Pointer Methods**

| Method                                                     | Description                                  |
| ---------------------------------------------------------- | -------------------------------------------- |
| **Pointer Checks**                                         |                                              |
| `is_null()`                                                | Returns `true` if pointer is null.           |
| `is_aligned()` *(Nightly)*                                 | Checks if pointer is properly aligned.       |
| `align_offset(n)`                                          | Checks memory alignment offset.              |
| `guaranteed_eq(ptr2)` *(Nightly)*                          | Ensures two pointers are equal.              |
| **Pointer Arithmetic**                                     |                                              |
| `add(n)`, `offset(n)`                                      | Moves pointer by `n` elements (unsafe).      |
| `wrapping_add(n)`, `wrapping_offset(n)`                    | Moves pointer by `n` safely (no UB).         |
| **Dereferencing & Memory Operations**                      |                                              |
| `read()`, `write(val)`                                     | Reads/writes a value at the pointer.         |
| `read_volatile()`, `write_volatile()`                      | Read/write for volatile memory.              |
| `swap(ptr2)`                                               | Swaps values at two pointers.                |
| `replace(val) -> T`                                        | Replaces value at pointer, returns old.      |
| `drop_in_place()`                                          | Drops the value without deallocating.        |
| **Copying and Moving**                                     |                                              |
| `copy_to(dest, count)`, `copy_nonoverlapping(dest, count)` | Copies memory safely.                        |
| `copy_to_nonoverlapping(dest, count)`                      | Faster but requires non-overlapping regions. |
| **Conversions**                                            |                                              |
| `cast<U>()`                                                | Converts `*mut T` to `*mut U`.               |


