## **`RefCell<T>` Methods**



The `RefCell<T>` type in Rust provides interior mutability, allowing you to mutate values even when you have an immutable reference. Below are additional methods for `RefCell<T>`:

---

### **Replacing and Swapping Values**  

#### **`replace()`**  
- Replaces the current value with a new one and returns the old value.

```rust
use std::cell::RefCell;

let data = RefCell::new(5);
let old_value = data.replace(10);
println!("Old value: {}", old_value); // 5
println!("New value: {}", data.borrow()); // 10
```

---

#### **`replace_with(f: FnOnce(&mut T) -> T)`**  
- Replaces the value based on a function.

```rust
let cell = RefCell::new(5);
cell.replace_with(|&mut old| old + 10);
println!("Updated value: {}", cell.borrow()); // 15
```

---

#### **`swap(other: &RefCell<T>)`**  
- Swaps the values of two `RefCell<T>` instances.

```rust
let a = RefCell::new(1);
let b = RefCell::new(2);

a.swap(&b);

println!("a: {}", a.borrow()); // 2
println!("b: {}", b.borrow()); // 1
```

---

### **Taking and Borrowing Values**  

#### **`take()`**  
- Takes the value out, replacing it with the default value of `T`.

```rust
let cell = RefCell::new(String::from("Hello"));
let taken_value = cell.take();
println!("Taken value: {}", taken_value); // "Hello"
println!("New value in cell: {:?}", cell.borrow()); // ""
```
*Note: `T` must implement `Default` for `take()` to work.*

---

### **Checking Borrow Status**  

#### **`borrow_state()`** *(Nightly Only)*
- Returns an enum indicating whether the value is currently borrowed mutably or immutably.

```rust
// Only available on Nightly Rust
let cell = RefCell::new(42);
let _borrow = cell.borrow();

assert!(cell.borrow_state().is_borrowed());
```

---

**Summary of `RefCell<T>` Methods**  

| Method | Description |
|--------|-------------|
| `borrow()` | Borrow an immutable reference (`Ref<T>`). |
| `borrow_mut()` | Borrow a mutable reference (`RefMut<T>`). |
| `try_borrow()` | Try to borrow immutably without panicking. |
| `try_borrow_mut()` | Try to borrow mutably without panicking. |
| `replace(new_value)` | Replace current value with `new_value`, returning the old one. |
| `replace_with(f)` | Replace value using a function. |
| `swap(&other)` | Swap values with another `RefCell<T>`. |
| `take()` | Take the value, leaving a default value in its place. |


