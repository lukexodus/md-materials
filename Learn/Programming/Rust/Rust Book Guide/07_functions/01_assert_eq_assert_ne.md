## `assert_eq!` & `assert_ne!`


The `assert_eq!` macro in Rust is used to check if two expressions are equal. It compares the two provided values, and if they are not equal, it will cause a panic at runtime with a message that includes the values of both expressions for easier debugging.

Syntax:

```rust
assert_eq!(left, right);
```
If the left expression and the right expression are equal, the program continues running normally. If they are not equal, the program will panic and print an error message showing both values.

**Example 1: When the values are equal (no panic)**

```rust
fn main() {
    let a = 5;
    let b = 5;

    assert_eq!(a, b);  // This will pass as a == b.
    println!("Test passed!");
}
```

Output:

```
Test passed!
```

**Example 2: When the values are not equal (panic)**

```rust
fn main() {
    let a = 5;
    let b = 6;

    assert_eq!(a, b);  // This will panic as a != b.
}
```

Output (with a panic message):

```
thread 'main' panicked at 'assertion failed: (left == right)
  left: `5`,
 right: `6`', src/main.rs:5:5
```

**Additional Notes:**

1. **Custom Error Message**: You can also provide an additional custom error message as an argument if you'd like:

```rust
fn main() {
    let a = 5;
    let b = 6;

    assert_eq!(a, b, "Values are not equal! a: {}, b: {}", a, b);
}
```

Output:

```
thread 'main' panicked at 'Values are not equal! a: 5, b: 6', src/main.rs:5:5
```


2. **assert_ne!**: Rust also provides assert_ne!, which checks if two values are not equal. This is the inverse of assert_eq!.

```rust
fn main() {
    let a = 5;
    let b = 6;

    assert_ne!(a, b);  // This will pass because a != b.
    println!("Test passed!");
}
```


3. **Equality Requirements**: The types of the values compared with assert_eq! must implement the `PartialEq` trait (which most primitive types do). The values must also be of the same type, or else the code will not compile.

```rust
let a = 5;
let b = 5.0;  // Different types: `i32` vs `f64`.

assert_eq!(a, b);  // Compile-time error because of type mismatch.
```


**Usage in Tests**:

`assert_eq!` is frequently used in unit tests to ensure that function outputs match expected results.

```
#[cfg(test)]
mod tests {
    #[test]
    fn test_sum() {
        let result = 2 + 2;
        assert_eq!(result, 4);  // The test will pass.
    }
}
```

