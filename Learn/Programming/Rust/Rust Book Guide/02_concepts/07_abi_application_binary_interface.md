## ABI (Application Binary Interface)


The **Application Binary Interface (ABI)** defines how functions, data structures, and system calls are represented in binary, allowing different components (like Rust code, C libraries, or OS kernels) to interact at the machine level.

---

**Key Aspects of Rust's ABI**

1. **Function Calling Conventions**
    
    - Determines how function arguments and return values are passed (registers vs. stack).
    - Rust defaults to its own **unspecified ABI**, meaning calling conventions may change across compiler versions.
2. **Foreign Function Interface (FFI)**
    
    - Rust uses **extern "C"** to ensure compatibility with C-style ABIs.
    - Example:
        
        ```rust
        extern "C" {
            fn printf(format: *const i8, ...);
        }
        ```
        
    - This tells Rust to use the **C ABI** for calling `printf`.
3. **ABI Stability in Rust**
    
    - **Rust does not guarantee a stable ABI** across different compiler versions.
    - This means Rust libraries should expose a C-compatible ABI when interacting with external code.

---

### **Common ABI Types in Rust**

Rust supports multiple ABI specifications using the `extern` keyword:

|ABI|Description|
|---|---|
|`"Rust"`|Default ABI (unstable across versions).|
|`"C"`|Standard C ABI (used for FFI).|
|`"cdecl"`|C-style calling convention (x86).|
|`"stdcall"`|Windows API calling convention.|
|`"fastcall"`|Passes some arguments in registers for speed.|
|`"system"`|Uses platform's default calling convention.|
|`"thiscall"`|Used for C++ instance methods.|

**Example using `extern "C"` for ABI compatibility:**

```rust
#[no_mangle] // Prevents name mangling for C compatibility
extern "C" fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

---

### **Interfacing with C Libraries (FFI)**

Rust can call C functions using `extern "C"`:

```rust
extern "C" {
    fn abs(input: i32) -> i32;
}

fn main() {
    unsafe {
        println!("{}", abs(-10)); // Calls C's abs() function
    }
}
```

Likewise, Rust functions can be exposed to C:

```c
// C code
#include <stdio.h>

extern int add(int a, int b);

int main() {
    printf("%d\n", add(2, 3));
    return 0;
}
```

---

**ABI Mismatch Issues**

- If the Rust ABI is **not explicitly specified**, function calls may fail when interacting with C/C++ or other languages.
- Mismatched calling conventions can cause **stack corruption**, **crashes**, or **undefined behavior**.

---

**Key Takeaways**

✔ **Rust does not guarantee a stable ABI** (except for `extern "C"`).  
✔ **Use `extern "C"` for FFI** to interact with other languages.  
✔ **ABI mismatches** can lead to crashes or memory corruption.  
✔ **Avoid exposing Rust functions with Rust ABI** across compilation units or libraries.

