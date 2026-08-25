## Closures and Lazy Evaluation


### What is "Lazy" Evaluation?

In programming, **lazy evaluation** refers to deferring the computation of a value until it is absolutely necessary. It helps optimize performance by avoiding unnecessary calculations.

In Rust, methods like `unwrap_or_else`, `map_or_else`, or `ok_or_else` use lazy evaluation. These methods take closures (we'll discuss closures in a moment), and the provided closures will only be executed if they are needed.

For example:
```rust
let x: Option<i32> = None;
let result = x.unwrap_or_else(|| {
    println!("Calculating default value...");
    42  // this closure only runs when `x` is `None`
});
```
Here, the closure `|| { 42 }` will only run if `x` is `None`. If `x` is `Some`, the closure will be ignored and never evaluated.

### Closures in Rust

A **closure** in Rust is a function-like construct that can capture variables from its environment and is defined **inline** in your code. They are similar to **anonymous functions** (functions without a name) in other languages, but they are more powerful because they can "close over" (i.e., capture) variables in their surrounding scope.

**Syntax of Closures**:
Closures in Rust have the following basic form:
```rust
|parameters| -> return_type {
    // body
}
```
You can omit the parameter types and return types, and Rust will infer them for you.

Example of a simple closure:
```rust
let add_one = |x| x + 1;
let result = add_one(5); // result = 6
```

Here, `add_one` is a closure that takes a single parameter `x` and returns `x + 1`.

### Closures vs Functions

Closures are similar to regular functions, but there are important differences:

1. **Anonymous**: Closures do not need a name. You can define them inline where they're used.
   - Example: `|x| x + 1` is a closure.

2. **Capturing Environment**: Closures can capture variables from their surrounding scope.
   - Example:
     ```rust
     let num = 5;
     let add_num = |x| x + num;  // captures `num` from the environment
     let result = add_num(10);   // result = 15
     ```

3. **Types Can Be Inferred**: Rust can infer the parameter and return types of closures, whereas for regular functions you must always specify the types.
   - Example:
     ```rust
     let add = |x, y| x + y;
     println!("{}", add(5, 10));  // 15
     ```

4. **Trait Boundaries**: Closures implement one or more of the following traits based on how they capture variables:
   - **`FnOnce`**: The closure can be called **once** (it consumes the variables it captures).
   - **`FnMut`**: The closure can modify the variables it captures (mutable access).
   - **`Fn`**: The closure borrows the variables it captures immutably (read-only).

**Example**: Using Closures with Captured Variables
```rust
fn main() {
    let mut counter = 0;

    let mut increment = || {
        counter += 1;  // the closure captures `counter` mutably
        println!("Counter: {}", counter);
    };

    increment();  // Counter: 1
    increment();  // Counter: 2
}
```
In this example, the closure `increment` captures and modifies the `counter` variable from its surrounding environment.

### Differences Between Closures and Functions

| Feature                  | Closures                                        | Functions                               |
|--------------------------|------------------------------------------------|-----------------------------------------|
| **Anonymous**             | Yes                                            | No (always named)                       |
| **Can capture environment** | Yes (can capture local variables)              | No (can't capture variables)            |
| **Type inference**        | Type of parameters and return type can be inferred | Type must be explicitly stated         |
| **Call traits**           | Implements `Fn`, `FnMut`, or `FnOnce`          | Regular function traits only            |

### Practical Uses of Closures in Rust

- **Callbacks**: Closures are often used for callbacks, where you pass a function or closure to another function to be called later.
  - Example: Sorting with closures:
    ```rust
    let mut numbers = vec![3, 1, 4, 1, 5, 9];
    numbers.sort_by(|a, b| a.cmp(b));  // closure used for custom sorting
    ```

- **Functional Programming**: Closures are used in functional programming constructs like `map`, `filter`, `reduce`, etc.
  - Example: Mapping over a vector:
    ```rust
    let numbers = vec![1, 2, 3];
    let doubled: Vec<i32> = numbers.iter().map(|x| x * 2).collect();
    println!("{:?}", doubled);  // [2, 4, 6]
    ```

