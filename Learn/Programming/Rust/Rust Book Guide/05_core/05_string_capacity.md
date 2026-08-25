## String Capacity


In Rust, when dealing with `String` metadata, two important properties often come up: **capacity** and **size** (or length). These are related to how `String` works internally and are critical for understanding memory usage and performance.

---

**Size (or Length)**

The **size** of a string refers to the number of bytes currently stored in the `String`.

- It represents the length of the string in bytes, not necessarily the number of characters (since some characters in UTF-8 can take multiple bytes).
- The size is dynamic and changes as you modify the string (e.g., by adding or removing characters).

**Method**:
- Use `.len()` to get the size of the string.

**Example**:
```rust
let s = String::from("Hello");
println!("Size: {}", s.len()); // Size: 5
```

---

**Capacity**

The **capacity** of a string refers to the amount of memory (in bytes) that the string has reserved to store its data.

- Capacity is typically greater than or equal to the size of the string.
- It determines how many bytes the string can hold before requiring a reallocation.
- Rust’s `String` optimizes performance by allocating extra memory upfront to reduce the need for frequent reallocations when appending data.

**Method**:
- Use `.capacity()` to get the capacity of the string.

**Example**:
```rust
let mut s = String::with_capacity(10); // Pre-allocate 10 bytes
println!("Capacity: {}", s.capacity()); // Capacity: 10
s.push_str("Hello");
println!("Size: {}", s.len());      // Size: 5
println!("Capacity: {}", s.capacity()); // Capacity: 10 (still the same)
s.push_str(" World!");
println!("Size: {}", s.len());      // Size: 12
println!("Capacity: {}", s.capacity()); // Capacity increases automatically
```

---

**Key Differences**

| **Property**  | **Size (`len`)**                             | **Capacity (`capacity`)**                     |
|---------------|---------------------------------------------|-----------------------------------------------|
| **Definition**| Number of bytes currently used by the string.| Number of bytes allocated for potential growth.|
| **Dynamic?**  | Changes as you add or remove characters.     | Grows automatically when the string exceeds it.|
| **Purpose**   | Tracks how much data the string holds.       | Prevents frequent reallocations during growth. |
| **Units**     | Measured in bytes.                          | Measured in bytes.                            |

---

**Behavior**
1. If the **size** exceeds the **capacity**, the `String` will automatically allocate more memory and increase its capacity.
2. The capacity does not shrink when you reduce the size of the string. If you want to reduce the capacity, you can use the `.shrink_to_fit()` method.

**Example**:
```rust
let mut s = String::from("Rust");
println!("Size: {}", s.len());      // Size: 4
println!("Capacity: {}", s.capacity()); // Capacity: 4 (default allocation)

s.push_str(" programming"); // Appending increases size
println!("Size: {}", s.len());      // Size: 15
println!("Capacity: {}", s.capacity()); // Capacity grows automatically

s.clear(); // Clear the string
println!("Size after clear: {}", s.len()); // Size: 0
println!("Capacity after clear: {}", s.capacity()); // Capacity remains unchanged

s.shrink_to_fit(); // Reduce capacity to match size
println!("Capacity after shrink: {}", s.capacity()); // Capacity: 0
```

---

**Use Cases**
- **Size** is useful when:
  - You need to know the current amount of data stored.
  - You're validating or processing string content.
  
- **Capacity** is useful when:
  - Pre-allocating memory for performance optimization.
  - Reducing memory overhead by shrinking the capacity.

Understanding these properties helps you write more efficient Rust programs, especially when working with dynamic strings.

