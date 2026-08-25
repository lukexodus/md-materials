## `extern`


The `extern` keyword in Rust is used for **interoperability** with other languages (FFI - Foreign Function Interface) and to declare **external functions, variables, or libraries** that exist outside Rust’s compilation unit.

---

### **`extern "C"` for Calling C Functions**

Rust can call C functions by specifying the `"C"` ABI.

**Example: Calling a C function from Rust**

```c
// C Code (my_c_lib.c)
#include <stdio.h>

void hello_from_c() {
    printf("Hello from C!\n");
}
```

```rust
// Rust Code (main.rs)
extern "C" {
    fn hello_from_c();
}

fn main() {
    unsafe {
        hello_from_c();
    }
}
```

✅ **Key points:**

- `extern "C"` tells Rust to use the C calling convention.
- `unsafe` is required because Rust cannot guarantee safety.

---

### **`extern "C"` for Exposing Rust Functions to C**

Rust functions can be made accessible to C using `#[no_mangle]` to prevent name mangling.

**Example: Exposing a Rust function to C**

```rust
#[no_mangle]
extern "C" fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

Then, in C:

```c
// C Code
#include <stdio.h>

extern int add(int a, int b);

int main() {
    printf("Sum: %d\n", add(3, 4));
    return 0;
}
```

✅ **Key points:**

- `#[no_mangle]` keeps the function name unchanged in the binary.
- `extern "C"` ensures C compatibility.

---

### **`extern crate` for Importing External Rust Crates** _(Deprecated in 2018 Edition)_

In Rust 2015, `extern crate` was required to import external crates:

```rust
extern crate serde; // Import serde crate
```

In Rust 2018+, it's unnecessary—`use` is preferred:

```rust
use serde::Serialize;
```

---

### **`extern` with Other ABIs**

Rust supports multiple ABIs, such as `"stdcall"` (Windows), `"fastcall"`, `"system"`, etc.

|ABI|Description|
|---|---|
|`"C"`|Standard C ABI (most common)|
|`"stdcall"`|Used by Windows API functions|
|`"fastcall"`|Passes some arguments via registers|
|`"system"`|Uses the platform’s default ABI|

Example using `stdcall` (Windows API):

```rust
#[cfg(target_os = "windows")]
extern "stdcall" {
    fn MessageBoxA(hwnd: *mut u8, text: *const u8, caption: *const u8, utype: u32) -> i32;
}
```

---

### **`extern` Blocks for Static Variables**

Rust can access C global variables via `extern`.

**Example: Accessing a C global variable**

```c
// C Code (global.c)
int GLOBAL_VALUE = 42;
```

```rust
// Rust Code
extern "C" {
    static GLOBAL_VALUE: i32;
}

fn main() {
    unsafe {
        println!("Global value: {}", GLOBAL_VALUE);
    }
}
```

---

**Key Takeaways**

✔ **`extern "C"` ensures compatibility with C functions.**  
✔ **Use `#[no_mangle]` to prevent Rust from renaming functions.**  
✔ **Rust does not guarantee ABI stability—use `extern` for cross-language compatibility.**  
✔ **Other ABIs (`stdcall`, `system`, etc.) exist for platform-specific needs.**

