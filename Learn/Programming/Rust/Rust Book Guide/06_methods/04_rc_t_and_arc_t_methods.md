## **`Rc<T>` and `Arc<T>` Methods**


### **Cloning and Reference Counting**

#### **`clone()`**  
- Creates a new `Rc<T>` or `Arc<T>` reference to the same value, incrementing the reference count.

```rust
use std::rc::Rc;

let a = Rc::new(5);
let b = Rc::clone(&a); // Equivalent to `let b = a.clone();`
```

For `Arc<T>`:

```rust
use std::sync::Arc;

let a = Arc::new(5);
let b = Arc::clone(&a);
```

---

#### **`strong_count()`**  
- Returns the number of strong references to the value.

```rust
println!("Reference count: {}", Rc::strong_count(&a));
```

For `Arc<T>`:

```rust
println!("Reference count: {}", Arc::strong_count(&a));
```

---

#### **`weak_count()`** *(Only for `Arc<T>`)*
- Returns the number of weak references to the value.

```rust
println!("Weak count: {}", Arc::weak_count(&a));
```

---

### **Downgrading and Upgrading**

#### **`downgrade()`**  
- Converts an `Rc<T>` or `Arc<T>` into a `Weak<T>`, which does not increment the strong count.

```rust
let weak_a = Rc::downgrade(&a);
```

For `Arc<T>`:

```rust
let weak_a = Arc::downgrade(&a);
```

---

#### **`upgrade()`**  
- Converts a `Weak<T>` back into an `Rc<T>` or `Arc<T>` if the value is still alive.

```rust
if let Some(strong_ref) = weak_a.upgrade() {
    println!("Upgraded value: {}", strong_ref);
} else {
    println!("Value no longer exists.");
}
```

---

### **Mutability and Uniqueness**

#### **`get_mut()`**  
- Provides a mutable reference to the inner value **only if no other strong references exist**.

```rust
if let Some(mut a_mut) = Rc::get_mut(&mut a) {
    *a_mut = 10;
}
```

For `Arc<T>` *(requires `Arc::make_mut()` instead of `get_mut()`)*
```rust
let mut a = Arc::new(5);
let mut_ref = Arc::make_mut(&mut a);
*mut_ref = 10;
```

---

#### **`make_mut()`** *(Only for `Arc<T>` and `Rc<T>`)*
- Creates a unique reference if there are multiple owners (clone-on-write behavior).

```rust
let mut a = Rc::new(5);
let unique_ref = Rc::make_mut(&mut a);
*unique_ref = 10;
```

For `Arc<T>`:

```rust
let mut a = Arc::new(5);
let unique_ref = Arc::make_mut(&mut a);
*unique_ref = 10;
```

---

### **Converting to Inner Value (If Unique)**

#### **`try_unwrap()`**
- Consumes `Rc<T>` or `Arc<T>` and returns the inner value **if it is uniquely owned**.

```rust
match Rc::try_unwrap(a) {
    Ok(value) => println!("Unwrapped value: {}", value),
    Err(shared) => println!("Still has multiple references."),
}
```

For `Arc<T>`:

```rust
match Arc::try_unwrap(a) {
    Ok(value) => println!("Unwrapped value: {}", value),
    Err(shared) => println!("Still has multiple references."),
}
```

---

### **Checking Pointer Equality**

#### **`ptr_eq()`**  
- Checks if two `Rc<T>` or `Arc<T>` point to the same allocation.

```rust
let a = Rc::new(5);
let b = Rc::clone(&a);

assert!(Rc::ptr_eq(&a, &b));
```

For `Arc<T>`:

```rust
let a = Arc::new(5);
let b = Arc::clone(&a);

assert!(Arc::ptr_eq(&a, &b));
```

---

**Summary of Methods**

| Method | `Rc<T>` | `Arc<T>` | Description |
|--------|--------|--------|-------------|
| `clone()` | ✅ | ✅ | Creates a new strong reference. |
| `strong_count()` | ✅ | ✅ | Returns the number of strong references. |
| `weak_count()` | ❌ | ✅ | Returns the number of weak references. |
| `downgrade()` | ✅ | ✅ | Creates a weak reference (`Weak<T>`). |
| `upgrade()` | ✅ | ✅ | Converts `Weak<T>` back to `Rc<T>`/`Arc<T>`. |
| `get_mut()` | ✅ | ❌ | Gets a mutable reference if only one strong reference exists. |
| `make_mut()` | ✅ | ✅ | Provides mutable access, cloning if needed. |
| `try_unwrap()` | ✅ | ✅ | Returns inner value if only one strong reference exists. |
| `ptr_eq()` | ✅ | ✅ | Checks if two smart pointers reference the same memory. |

---

- Use `Rc<T>` in **single-threaded** contexts.
- Use `Arc<T>` in **multi-threaded** environments.
- Use `Weak<T>` to **avoid reference cycles**.
- `make_mut()` enables **clone-on-write** behavior.


