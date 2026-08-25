## Iterating Over A Collection


In Rust, when you iterate over a collection like a vector using a for loop, using or not using the & impacts ownership and borrowing. Here’s the difference between the two approaches:

### 1. Iterating without & (Taking Ownership)

When you iterate over a vector without &, each element is moved out of the vector. This means after the loop, the original vector can no longer be used because the values inside it have been transferred elsewhere.

**Example**:

```rust
let v = vec![1, 2, 3, 4, 5];

for val in v {
    println!("{}", val);  // The elements are moved here
}

// `v` cannot be used anymore here, because its values were moved
// println!("{:?}", v); // This would cause a compile-time error
```

**Explanation**:

Each element in the vector v is moved into the for loop, and the ownership is transferred to the loop body.

After the iteration is done, you no longer own the vector v, so you cannot access or reuse v later in your code. The vector is invalid after the loop.


### 2. Iterating with & (Borrowing)

When you iterate over a vector with &, you are borrowing each element, rather than taking ownership of it. This allows you to read the elements without moving them, so you can still use the original vector after the loop.

**Example**:

```rust
let v = vec![1, 2, 3, 4, 5];

for &val in &v {  // Borrowing each element
    println!("{}", val);  // The elements are only borrowed here
}

println!("{:?}", v);  // `v` can still be used after the loop
```

**Explanation**:

The &v in the for loop means you're iterating over references to the elements of the vector, not the elements themselves.

The elements are borrowed, not moved, so ownership of the vector is not transferred. This allows you to still use v after the loop.

Since you only borrowed the elements, the original vector remains intact and can be accessed after the loop.


### Why Use &?

To Avoid Moving Ownership: If you don’t want to transfer ownership of the elements, you should borrow them using &. This way, the vector remains valid after the loop.

To Preserve the Collection: Often, you need to reuse or keep the original collection intact after iterating over it, so borrowing allows you to safely read its contents without invalidating it.

