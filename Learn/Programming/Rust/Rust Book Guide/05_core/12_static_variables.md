## Static Variables


Rust allows defining **static variables** using the `static` keyword. Unlike regular variables (`let`), **static variables have a fixed memory location and exist for the entire program's lifetime**.

---

**Declaring a Static Variable**

```rust
static GREETING: &str = "Hello, world!";
fn main() {
    println!("{}", GREETING);
}
```

✅ **Key points:**

- `static` variables are stored in a **fixed memory location**.
- The value **must be a constant expression** (no runtime initialization).
- They live **for the entire program** (`'static` lifetime).

---

### **`mut` and `unsafe` with Static Variables**

Mutable static variables require **`unsafe`** because **Rust does not enforce thread safety**.

```rust
static mut COUNTER: i32 = 0;

fn increment() {
    unsafe {
        COUNTER += 1;
    }
}

fn main() {
    unsafe {
        println!("Counter: {}", COUNTER);
        increment();
        println!("Counter: {}", COUNTER);
    }
}
```

✅ **Why `unsafe`?**

- Multiple threads could modify `COUNTER`, leading to **data races**.
- Rust forces you to acknowledge **potential unsafety** explicitly.

---

### **Difference Between `static` and `const`**

|Feature|`static`|`const`|
|---|---|---|
|**Memory Location**|Fixed address in memory|Inlined at usage points|
|**Mutability**|Can be `mut` (requires `unsafe`)|Always immutable|
|**Thread Safety**|Needs `unsafe` for `mut`|Always thread-safe|
|**Use Case**|Long-lived values (e.g., global settings)|Compile-time constants|

**Example:**

```rust
static MESSAGE: &str = "Static lives forever!";
const PI: f64 = 3.1415;
```

---

### **Static References and `'static` Lifetime**

Since static variables exist **for the whole program**, references to them have a `'static` lifetime.

```rust
fn get_message() -> &'static str {
    static MESSAGE: &str = "Hello, world!";
    MESSAGE
}
```

✅ The returned reference **never becomes invalid**.

---

### **Using `Atomic` Types for Thread Safety**

For **safe mutable static variables**, use **atomic types** from `std::sync::atomic`.

```rust
use std::sync::atomic::{AtomicUsize, Ordering};

static COUNTER: AtomicUsize = AtomicUsize::new(0);

fn increment() {
    COUNTER.fetch_add(1, Ordering::SeqCst);
}

fn main() {
    increment();
    println!("Counter: {}", COUNTER.load(Ordering::SeqCst));
}
```

✅ `AtomicUsize` ensures **safe concurrent access** without `unsafe`.

---

**Key Takeaways**

✔ **`static` variables have a fixed memory location and exist for the whole program.**  
✔ **`mut static` requires `unsafe` due to potential data races.**  
✔ **Use `Atomic*` types for thread-safe mutable statics.**  
✔ **`const` differs from `static`—it’s inlined, immutable, and safer.**

