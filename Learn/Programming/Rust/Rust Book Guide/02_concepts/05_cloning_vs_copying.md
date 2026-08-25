## Cloning vs Copying


In Rust, **cloning** and **copying** refer to two different ways of duplicating data, and they are represented by two separate traits: `Clone` and `Copy`.

1. **`Clone`**:
   - `Clone` is a trait that represents **explicit, deep copying** of data. When you call `.clone()` on an object, it creates a new, separate instance of the data.
   - Cloning can be expensive because it involves duplicating the data, potentially even performing a deep copy (where all underlying data structures are also copied).
   - `Clone` is implemented for types that need custom logic to create a new instance, such as `String`, `Vec`, and many other types that hold data on the heap.
   - **Usage**: You need to call the `.clone()` method explicitly.

   ```rust
   let s1 = String::from("Hello");
   let s2 = s1.clone(); // Creates a separate copy of `s1`
   println!("s1: {}, s2: {}", s1, s2);
   ```

2. **`Copy`**:
   - `Copy` is a trait that represents **implicit, shallow copying** of data. Types that implement `Copy` are automatically duplicated when assigned to another variable or passed to a function.
   - Copying is cheap and only applies to types that can be safely duplicated without any additional resources, typically stack-allocated, fixed-size types like integers, floats, and `bool`.
   - `Copy` is a "marker trait," meaning it has no methods. When a type implements `Copy`, you don’t need to call any methods to copy it; the compiler will handle it automatically.
   - **Usage**: Copying is implicit. Just assigning a `Copy` type to a new variable or passing it to a function will copy it.

   ```rust
   let x = 5;
   let y = x; // `x` is copied into `y` (no need to call `.clone()`)
   println!("x: {}, y: {}", x, y);
   ```

---

**KEY DIFFERENCES**

- **Explicit vs. Implicit**:
  - `Clone` requires an explicit call to `.clone()`, while `Copy` happens implicitly when assigning or passing values.

- **Cost**:
  - `Clone` can be more expensive as it may involve deep copying data structures.
  - `Copy` is generally very cheap because it applies only to types that can be trivially duplicated (like integers and floats).

- **Ownership Transfer**:
  - For types that implement `Clone` but not `Copy` (like `String` or `Vec`), assigning a value to a new variable **moves** ownership unless you explicitly call `.clone()`.
  - For types that implement `Copy` (like `i32` or `bool`), assignment simply creates a copy, so both variables can be used after the assignment without any ownership transfer.

---

**When to Use `Clone` and `Copy**`

- **Use `Copy`** when your type is small, fixed-size, and can be duplicated trivially. This is mostly for stack-allocated, primitive types like integers, floats, and `bool`. If your type consists only of `Copy` types, you can usually implement `Copy` for it as well.
  
- **Use `Clone`** when your type is more complex, holds data on the heap, or requires additional logic to duplicate. Most user-defined types that involve heap allocation (like `String` or `Vec`) implement `Clone` instead of `Copy`.

---

**Example: Custom Struct with `Copy` and `Clone**`

To illustrate the usage of both `Copy` and `Clone`, let’s define a couple of structs:

```rust
#[derive(Copy, Clone)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p1 = Point { x: 5, y: 10 };
    let p2 = p1; // `p1` is copied to `p2` because `Point` implements `Copy`
    println!("p1: ({}, {}), p2: ({}, {})", p1.x, p1.y, p2.x, p2.y);
}
```

In the above example:
- The `Point` struct implements both `Copy` and `Clone`, so it can be copied implicitly and cloned explicitly.
- Since `Point` only contains `i32` values (which are `Copy`), it can also be `Copy`.
- Assigning `p1` to `p2` does not move `p1`; instead, it copies `p1` to `p2`.

For a type that holds heap data (like `String`), only `Clone` is implemented, as duplicating it is more complex and involves allocation.

---

**Summary Table**

| Trait  | Purpose                         | Cost         | Requires Explicit Call? | Example Types                      |
|--------|---------------------------------|--------------|-------------------------|------------------------------------|
| `Clone`| Explicit, potentially deep copy | Higher       | Yes, `.clone()`         | `String`, `Vec<T>`, custom structs |
| `Copy` | Implicit, shallow copy          | Low (cheap)  | No                      | `i32`, `bool`, `f32`, custom `Copy` structs |

In short:
- **Use `Copy` for simple, small types** where an implicit copy is inexpensive.
- **Use `Clone` for types requiring more complex duplication** where you want explicit control over when the copy occurs.

