## `Box<T>`


* A **smart pointer** that stores data on the **heap** instead of the stack.
* Owns its contents — when the `Box` is dropped, the heap memory is freed.
* Zero runtime overhead: it’s just a pointer (like `*T`), but safe and with ownership semantics.

---

### Why use `Box<T>`?

1. **Move big values off the stack**

   ```rust
   let b = Box::new([0u8; 1_000_000]); // big array on the heap
   ```

   Keeps your stack small.

2. **Recursive types**
   Rust needs to know the size of every type at compile time. Recursive enums (like linked lists or trees) don’t have a known size unless you put recursive parts in a `Box`.

   ```rust
   enum List {
       Cons(i32, Box<List>),
       Nil,
   }
   ```

3. **Trait objects**
   To do dynamic dispatch with `dyn Trait`, you usually need heap allocation via `Box<dyn Trait>`.

---

### Memory layout

When you write:

```rust
let x = Box::new(42);
```

* On the **heap**: the value `42` is stored.
* On the **stack**: the `Box` itself (a pointer to the heap allocation).

```
Stack              Heap
 -----             -----
| ptr |   ----->  | 42 |
 -----             -----
```

When `x` goes out of scope, Rust:

1. Drops the value on the heap.
2. Frees the heap memory.

---

**Example**

```rust
fn main() {
    let x = Box::new(10);
    println!("x = {}", x); // behaves like &i32
} // x is dropped → 10 on heap is freed
```

Output:

```
x = 10
```

---

### Key traits

* `Deref` → lets you use `*x` or call methods on the inner value directly.
* `Drop` → automatically frees memory.
* `Send` / `Sync` → if `T` is thread-safe, `Box<T>` is too.

---

**Analogy**

Think of `Box<T>` like renting a **storage unit**:

* Your house (stack) has limited space.
* If something is too big, you rent a storage unit (heap).
* You keep the **key (pointer)** in your pocket.
* When you’re done, you return the unit (free memory).

---

✅ So in short:

* `Box<T>` = heap allocate a single value.
* Useful for big values, recursive types, and trait objects.
* Cheap and simple — just one heap allocation and one pointer on the stack.

---

