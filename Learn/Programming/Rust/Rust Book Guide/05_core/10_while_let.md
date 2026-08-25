## `while let`


The `while let` construct in Rust is used to run a loop as long as a pattern matches a value. It’s similar to `if let`, but instead of just checking once, it keeps running the loop body as long as the pattern continues to match.

This is useful for iterating over `Option` or `Result` types (or any pattern) until a certain condition is no longer met. It allows you to avoid writing a potentially complex `loop` with `match` statements inside.

**Syntax**

```rust
while let PATTERN = EXPRESSION {
    // loop body
}
```

### Example: Unwrapping an Option

Here's an example where we keep unwrapping an `Option` until it becomes `None`:

```rust
fn main() {
    let mut values = Some(10);

    while let Some(x) = values {
        println!("Current value: {}", x);

        // Modify `values` to eventually break the loop
        values = if x > 0 { Some(x - 1) } else { None };
    }

    println!("Loop ended");
}
```

Output:
```
Current value: 10
Current value: 9
Current value: 8
...
Current value: 1
Current value: 0
Loop ended
```

Explanation:
- `while let Some(x) = values` runs the loop as long as `values` is `Some(x)`.
- Each time through the loop, `x` is decreased until `values` becomes `None`, at which point the loop stops.

### Example: Iterating over a Vector with `pop`

Here’s another example where `while let` is used to pop elements from a vector until it’s empty:

```rust
fn main() {
    let mut stack = vec![1, 2, 3, 4, 5];

    while let Some(top) = stack.pop() {
        println!("Popped value: {}", top);
    }

    println!("Stack is empty");
}
```

Output:
```
Popped value: 5
Popped value: 4
Popped value: 3
Popped value: 2
Popped value: 1
Stack is empty
```

Explanation:
- `stack.pop()` returns an `Option` with `Some(value)` if there’s an element to pop, or `None` if the vector is empty.
- `while let Some(top) = stack.pop()` keeps popping and printing values until `stack.pop()` returns `None`.

### Example: Reading from an Iterator

You can also use `while let` to read items from an iterator until there are no more items:

```rust
fn main() {
    let mut iter = vec![10, 20, 30].into_iter();

    while let Some(value) = iter.next() {
        println!("Next value: {}", value);
    }

    println!("No more values in iterator");
}
```

Output:
```
Next value: 10
Next value: 20
Next value: 30
No more values in iterator
```

Explanation:
- `iter.next()` returns `Some(value)` until there are no more items, at which point it returns `None`.
- `while let` will keep looping until there are no more values left in the iterator.

### Example: Working with `Result`

You can also use `while let` with `Result` types to keep processing until an error occurs:

```rust
fn main() {
    let mut results = vec![Ok(1), Ok(2), Err("error"), Ok(3)];

    while let Some(Ok(value)) = results.pop() {
        println!("Got value: {}", value);
    }

    println!("Finished processing results");
}
```

Output:
```
Got value: 3
Got value: 2
Got value: 1
Finished processing results
```

Explanation:
- We use `while let Some(Ok(value))` to only process the `Ok` values in the `results` vector.
- The loop stops once it encounters the `Err("error")` or when the vector is empty.

### Example: Working With Custom Enums

If you have a custom enum, you can match any variant with `while let`, not just `Some`. Here’s an example:

```rust
enum MyEnum {
    VariantA(i32),
    VariantB(String),
}

fn main() {
    let mut items = vec![
        MyEnum::VariantA(42),
        MyEnum::VariantB(String::from("Hello")),
        MyEnum::VariantA(7),
    ];

    while let Some(MyEnum::VariantA(value)) = items.pop() {
        println!("Got VariantA with value: {}", value);
    }

    println!("No more VariantA items");
}
```

In this example, we're only processing `VariantA` items and ignoring `VariantB`.

### Example: Working With Other Patterns

You can use `while let` with any pattern, such as tuple patterns, array destructuring, or even references. Here are a few examples:

#### Tuple Patterns

```rust
fn main() {
    let mut pairs = vec![(1, "one"), (2, "two"), (3, "three")];

    while let Some((number, word)) = pairs.pop() {
        println!("Number: {}, Word: {}", number, word);
    }
}
```

#### Array Destructuring

```rust
fn main() {
    let mut arrays = vec![[1, 2, 3], [4, 5, 6], [7, 8, 9]];

    while let Some([a, b, c]) = arrays.pop() {
        println!("Array elements: {}, {}, {}", a, b, c);
    }
}
```

#### Using References

```rust
fn main() {
    let words = vec!["apple", "banana", "cherry"];
    let mut iter = words.iter();

    while let Some(&word) = iter.next() {
        println!("Word: {}", word);
    }
}
```

In this example, `Some(&word)` is used to match a reference to each word in the iterator.

**Summary**

- `while let` is useful for repeatedly matching a pattern until it no longer matches.
- It’s commonly used with `Option`, `Result`, or any iterable structure.
- It provides a more concise alternative to a `loop` with a `match` inside it.

