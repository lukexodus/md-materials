## Attributes (`#[...]`)


Attributes in Rust (`#[...]`) are **compiler directives** used to modify code behavior. They can apply to functions, structs, modules, crates, and more.

---

### **Types of Attributes**

Rust attributes fall into these main categories:

|Category|Purpose|
|---|---|
|**Crate-Level**|Configure the entire crate (`#![crate_type]`, `#![no_std]`)|
|**Code Behavior**|Control compiler behavior (`#[inline]`, `#[must_use]`, `#[deprecated]`)|
|**Conditional Compilation**|Enable or disable code (`#[cfg(...)]`, `#[cfg_attr(...)]`)|
|**Lint Controls**|Adjust warnings and lints (`#[allow(...)]`, `#[deny(...)]`)|
|**FFI & Linking**|Work with external code (`#[no_mangle]`, `#[link]`)|
|**Procedural Macros**|Define custom attributes (`#[derive(...)]`, `#[proc_macro]`)|

---

### **Crate-Level Attributes**

These apply to the **entire crate** and start with `#![...]`.

#### **`#![crate_name]` and `#![crate_type]`**

Define the crate's name and type.

```rust
#![crate_name = "my_library"]
#![crate_type = "lib"] // Generates a Rust library instead of an executable
```

#### **`#![no_std]` (Disables Standard Library)**

Used for embedded and OS development.

```rust
#![no_std]  // Removes std; only core and alloc are available
```

---

### **Code Behavior Attributes**

#### **`#[inline]` (Suggests Inlining)**

```rust
#[inline]
fn fast_function() {
    println!("This function may be inlined");
}
```

#### **`#[must_use]` (Warns on Ignored Return Values)**

```rust
#[must_use]
fn important_calculation() -> i32 {
    42
}
```

If the result is ignored, the compiler will issue a warning.

#### **`#[deprecated]` (Marks Code as Deprecated)**

```rust
#[deprecated(since = "1.5.0", note = "Use `new_function` instead")]
fn old_function() {
    println!("This is deprecated");
}
```

---

### **Conditional Compilation Attributes**

Used to **enable or disable code** based on conditions.

#### **`#[cfg(...)]` (Compile-Time Condition)**

```rust
#[cfg(target_os = "linux")]
fn linux_only_function() {
    println!("Linux-specific function");
}
```

#### **`#[cfg_attr(...)]` (Apply Attributes Conditionally)**

```rust
#[cfg_attr(debug_assertions, allow(dead_code))]
fn debug_only_function() {}
```

This applies `#[allow(dead_code)]` only in debug builds.

---

### **Lint Control Attributes**

Rust allows **controlling compiler warnings and lints**.

#### **`#[allow(...)]`, `#[warn(...)]`, `#[deny(...)]`**

```rust
#[allow(dead_code)]
fn unused_function() {}

#[warn(unused_variables)]
fn test() {
    let x = 42; // Warning: unused variable
}

#[deny(unused_imports)]
use std::fs::File; // Error: unused import
```

---

### **FFI & Linking Attributes**

#### **`#[no_mangle]` (Preserve Function Name for C)**

```rust
#[no_mangle]
pub extern "C" fn c_function() {
    println!("Accessible from C");
}
```

#### **`#[repr(...)]` (Control Memory Layout)**

```rust
#[repr(C)] // Make struct compatible with C
struct MyStruct {
    x: i32,
    y: f64,
}
```

#### **`#[link(name = "...")]` (Link with External Libraries)**

```rust
#[link(name = "mylib")]
extern "C" {
    fn my_c_function();
}
```

---

### **Deriving Traits with `#[derive(...)]`**

```rust
#[derive(Debug, Clone, PartialEq)]
struct MyStruct {
    x: i32,
}
```

Automatically implements the **Debug**, **Clone**, and **PartialEq** traits.

---

### **Procedural Macros (`#[proc_macro]`)**

Used for custom Rust macros.

#### **Defining a Custom Macro**

```rust
use proc_macro::TokenStream;

#[proc_macro]
pub fn my_macro(input: TokenStream) -> TokenStream {
    input // Simple macro that does nothing
}
```

#### **Using a Custom Macro**

```rust
#[my_macro]
fn test() {
    println!("Custom macro applied!");
}
```


