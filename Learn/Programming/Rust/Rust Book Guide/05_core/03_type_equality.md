## **Type Equality**  


Rust does **not** support loose equality. Comparisons in Rust are always **strict**, and types must be compatible. Rust provides the `PartialEq` and `Eq` traits for equality comparisons.  

**Examples in Rust**  
```rust
let x = 5;
let y = "5";

// This won't compile because Rust enforces strict type equality:
println!("{}", x == y); // Error: mismatched types
```

Rust requires values to have the same type for equality comparisons. If you need to compare values of different types, you must explicitly convert them yourself:  
```rust
let x = 5;
let y = "5";

if x.to_string() == y {
    println!("They are equal");
}
```

---

**Key Takeaways**
- Rust does not perform **loose equality**; all comparisons are **strict** and type-safe.
- In Rust, equality is implemented through the `PartialEq` and `Eq` traits, which must be derived or implemented for custom types to enable comparisons.
- Strict equality avoids bugs caused by implicit type conversions, ensuring clearer and safer code.  

By enforcing strict type equality, Rust ensures type safety, reducing potential runtime errors often seen in languages with loose equality semantics.


---

