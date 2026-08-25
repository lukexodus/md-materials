## Mutating the Values of a Collection


You can mutate the values of a vector in Rust, but you need to borrow the vector mutably to do so. This means that the vector itself must be declared as mut, and when iterating or accessing its elements, you need to use a mutable reference (&mut).

Here are the two main ways to mutate the elements of a vector:

### 1. Mutating Elements Directly via Indexing

You can directly mutate the elements of a vector using indexing with [].

**Example**:

```rust
fn main() {
    let mut v = vec![1, 2, 3, 4, 5];  // Declare the vector as mutable

    v[0] = 10;  // Change the first element

    println!("{:?}", v);  // Output: [10, 2, 3, 4, 5]
}
```

### 2. Mutating Elements by Iterating Mutably

You can also iterate mutably over the vector using a for loop with &mut to mutate the values in place.

**Example**:

```rust
fn main() {
    let mut v = vec![1, 2, 3, 4, 5];  // Declare the vector as mutable

    // Mutably iterate over the vector
    for elem in &mut v {
        *elem *= 2;  // Double each element
    }

    println!("{:?}", v);  // Output: [2, 4, 6, 8, 10]
}
```

**Explanation**:

- `&mut v` is a mutable borrow of the vector.
- The `for elem in &mut v` loop iterates over mutable references to the elements of the vector.
- `*elem` dereferences the mutable reference to access the value, which can then be modified.

**Important Notes**:

You need to declare the vector as mut to allow mutation.

When mutably borrowing (&mut) elements, Rust ensures that no other mutable or immutable references are being used simultaneously (ensuring borrow-checking rules are followed).

You can’t mutate elements of a vector without borrowing it mutably.


