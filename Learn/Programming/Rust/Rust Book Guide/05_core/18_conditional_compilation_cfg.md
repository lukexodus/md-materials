## Conditional Compilation (`#[cfg(...)]`)


The `#[cfg(...)]` attribute is used for **conditional compilation** in Rust. It allows compiling or including code based on **features, target platforms, environment variables, or other conditions**.

---

### **Checking the Target OS**

You can compile different code for different operating systems using `#[cfg(target_os = "...")]`.

```rust
fn main() {
    #[cfg(target_os = "windows")]
    println!("Running on Windows!");

    #[cfg(target_os = "linux")]
    println!("Running on Linux!");

    #[cfg(target_os = "macos")]
    println!("Running on macOS!");
}
```

✅ **Key points:**

- The Rust compiler includes only the matching `#[cfg]` block for the detected OS.
- `target_os` values include `"windows"`, `"linux"`, `"macos"`, `"android"`, etc.

---

### **Checking the Compiler Version**

```rust
#[cfg(rustc_version = "1.75.0")]
fn use_new_feature() {
    println!("Using Rust 1.75.0+ features!");
}
```

✅ This ensures a function is compiled only for a specific Rust version.

---

### **Feature Flags (`--features`)**

You can enable/disable code using Cargo features.

**In `Cargo.toml`:**

```toml
[features]
fast_math = []
```

**In Rust code:**

```rust
#[cfg(feature = "fast_math")]
fn fast_math() {
    println!("Fast math enabled!");
}

fn main() {
    #[cfg(feature = "fast_math")]
    fast_math();
}
```

Run with:

```sh
cargo run --features fast_math
```

✅ **Use case:** Enabling optional functionality in a crate.

---

### **Checking the Compiler Target (Architecture)**

```rust
#[cfg(target_arch = "x86_64")]
fn optimized_for_x86_64() {
    println!("Running on x86_64 architecture!");
}
```

✅ `target_arch` values include `"x86"`, `"x86_64"`, `"arm"`, `"aarch64"`, etc.

---

### **Checking the Endianness**

```rust
#[cfg(target_endian = "little")]
fn little_endian_code() {
    println!("Running on a little-endian system!");
}
```

✅ Useful for writing cross-platform, byte-order-aware code.

---

### **Checking Debug vs. Release Mode**

```rust
#[cfg(debug_assertions)]
fn debug_mode() {
    println!("Debug mode active!");
}
```

✅ In **release mode**, `debug_assertions` is **not enabled**, making this function **not compile**.

---

### **Using `cfg!()` Inside Code**

Instead of `#[cfg(...)]`, `cfg!()` is a runtime check.

```rust
fn main() {
    if cfg!(target_os = "windows") {
        println!("This is Windows!");
    } else {
        println!("Not Windows!");
    }
}
```

✅ Unlike `#[cfg(...)]`, `cfg!()` **does not remove code at compile time**—it evaluates at runtime.

---

### **Combining Multiple Conditions (`any`, `all`, `not`)**

- **`any(...)`**: If **any** condition is met
- **`all(...)`**: If **all** conditions are met
- **`not(...)`**: If **a condition is not met**

```rust
#[cfg(any(target_os = "linux", target_os = "macos"))]
fn unix_function() {
    println!("Running on Linux or macOS!");
}

#[cfg(all(feature = "experimental", target_os = "linux"))]
fn experimental_linux_feature() {
    println!("Experimental feature for Linux enabled!");
}

#[cfg(not(target_os = "windows"))]
fn not_windows() {
    println!("This is not Windows!");
}
```

---

### **Conditional Modules**

```rust
#[cfg(target_os = "windows")]
mod windows_only {
    pub fn run() {
        println!("Windows-specific function!");
    }
}

fn main() {
    #[cfg(target_os = "windows")]
    windows_only::run();
}
```

✅ The whole `mod windows_only` block is **ignored** if not on Windows.

---

### **Conditionally Including External Crates**

```rust
#[cfg(feature = "serde")]
extern crate serde;
```

✅ This prevents unused dependencies when a feature is disabled.

---

**Key Takeaways**

✔ **`#[cfg(...)]` removes code at compile-time** based on conditions.  
✔ **`cfg!(...)` evaluates conditions at runtime.**  
✔ **Use `any(...)`, `all(...)`, and `not(...)` for complex conditions.**  
✔ **Common use cases:** OS-specific code, feature flags, debug/release checks, and architecture checks.



