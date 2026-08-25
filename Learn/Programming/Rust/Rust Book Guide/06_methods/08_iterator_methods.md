## **Iterator Methods**


Iterators in Rust allow you to work with sequences of values.

- **`take(n)`**: Takes the first `n` elements from an iterator.

    ```rust
    let v = vec![1, 2, 3, 4, 5];
    let taken: Vec<_> = v.iter().take(3).collect();
    println!("{:?}", taken);
    ```

- **`skip(n)`**: Skips the first `n` elements and continues iteration.

    ```rust
    let v = vec![1, 2, 3, 4, 5];
    let skipped: Vec<_> = v.iter().skip(2).collect();
    println!("{:?}", skipped);
    ```

- **`map(f)`**: Transforms each element using a function `f`.

    ```rust
    let v = vec![1, 2, 3, 4];
    let mapped: Vec<_> = v.iter().map(|x| x * 2).collect();
    println!("{:?}", mapped); // [2, 4, 6, 8]
    ```

- **`filter(f)`**: Filters elements based on a predicate `f`.

    ```rust
    let v = vec![1, 2, 3, 4, 5];
    let filtered: Vec<_> = v.into_iter().filter(|&x| x % 2 == 0).collect();
    println!("{:?}", filtered); // [2, 4]
    ```

- **`fold(init, f)`**: Accumulates values by applying a function `f` to each element and an accumulator.

    ```rust
    let v = vec![1, 2, 3, 4];
    let sum = v.iter().fold(0, |acc, &x| acc + x);
    println!("Sum: {}", sum); // 10
    ```

- **`enumerate()`**: Yields a tuple containing the index and the value for each element.

    ```rust
    let v = vec!["a", "b", "c"];
    for (i, val) in v.iter().enumerate() {
        println!("Index: {}, Value: {}", i, val);
    }
    ```

- **`any(f)`**: Returns `true` if any element satisfies the predicate `f`.

    ```rust
    let v = vec![1, 2, 3, 4];
    let has_even = v.iter().any(|&x| x % 2 == 0);
    println!("Has even? {}", has_even); // true
    ```

- **`all(f)`**: Returns `true` if all elements satisfy the predicate `f`.

    ```rust
    let v = vec![2, 4, 6];
    let all_even = v.iter().all(|&x| x % 2 == 0);
    println!("All even? {}", all_even); // true
    ```

- **`find(f)`**: Returns the first element that satisfies the predicate `f`.

    ```rust
    let v = vec![1, 2, 3, 4];
    let result = v.into_iter().find(|&x| x == 3);
    println!("{:?}", result); // Some(3)
    ```

- **`collect()`**: Consumes the iterator and collects the results into a collection (e.g., `Vec`).

    ```rust
    let v = vec![1, 2, 3, 4];
    let doubled: Vec<_> = v.into_iter().map(|x| x * 2).collect();
    println!("{:?}", doubled); // [2, 4, 6, 8]
    ```

- **`for_each`**: Executes a function for each element of the iterator.

    ```rust
    let v = vec![1, 2, 3];
    v.iter().for_each(|&x| println!("{}", x));
    ```

- **`count`**: Consumes the iterator and returns the number of elements.

    ```rust
    let v = vec![1, 2, 3];
    let count = v.iter().count(); // 3
    ```

- **`position`**: Returns the index of the first element that matches a predicate.

    ```rust
    let v = vec![1, 2, 3, 4];
    let pos = v.iter().position(|&x| x == 3); // Some(2)
    ```

- **`rposition`**: Searches for an element from the right, returning the index of the first match.

    ```rust
    let a = [1, 2, 3, 4, 5];
    let pos = a.iter().rposition(|&x| x == 3); // Some(2)
    ```

- **`last`**: Returns the last element of the iterator, or `None` if the iterator is empty.

    ```rust
    let v = vec![1, 2, 3];
    let last = v.iter().last(); // Some(&3)
    ```

- **`max`**: Returns the maximum element, or `None` if the iterator is empty. Elements must implement `Ord`.

    ```rust
    let v = vec![1, 2, 3];
    let max = v.iter().max(); // Some(&3)
    ```

- **`min`**: Returns the minimum element, or `None` if the iterator is empty. Elements must implement `Ord`.

    ```rust
    let v = vec![1, 2, 3];
    let min = v.iter().min(); // Some(&1)
    ```

- **`max_by_key`**: Returns the element that yields the maximum value for a specified key.

    ```rust
    let v = vec![("a", 1), ("b", 3), ("c", 2)];
    let max = v.iter().max_by_key(|&(_, val)| val); // Some(&("b", 3))
    ```

- **`min_by_key`**: Returns the element that yields the minimum value for a specified key.

    ```rust
    let v = vec![("a", 1), ("b", 3), ("c", 2)];
    let min = v.iter().min_by_key(|&(_, val)| val); // Some(&("a", 1))
    ```

- **`zip`**: Combines two iterators into a single iterator of pairs.

    ```rust
    let a = vec![1, 2, 3];
    let b = vec![4, 5, 6];
    let zipped: Vec<_> = a.iter().zip(b.iter()).collect(); // [(1, 4), (2, 5), (3, 6)]
    ```

- **`chain`**: Combines two iterators into a single iterator.

    ```rust
    let a = vec![1, 2, 3];
    let b = vec![4, 5, 6];
    let chained: Vec<_> = a.iter().chain(b.iter()).collect(); // [1, 2, 3, 4, 5, 6]
    ```

- **`inspect`**: Allows you to inspect each element of an iterator by applying a function without consuming it.

    ```rust
    let v = vec![1, 2, 3];
    let _ = v.iter().inspect(|&x| println!("Value: {}", x)).count();
    ```

---

**`for_each` vs `inspect`**

- **`for_each`**:
  - The `for_each` method is used to apply a closure to each item in the iterator.
  - It consumes the iterator, which means you can’t use the iterator after calling `for_each`.
  - It’s usually used for side effects, like printing values or performing some operation without returning any results.

    ```rust
    let v = vec![1, 2, 3];
    v.iter().for_each(|x| println!("{}", x)); // Prints each element
    ```

- **`inspect`**:
  - The `inspect` method allows you to peek at each item in an iterator chain without consuming the iterator or changing its output.
  - It’s often used for debugging or logging because it lets you see values as they pass through an iterator pipeline.
  - `inspect` returns a new iterator that is still usable after the inspection.

    ```rust
    let v = vec![1, 2, 3];
    let squared: Vec<_> = v.iter()
        .inspect(|x| println!("Original: {}", x))
        .map(|x| x * x)
        .inspect(|x| println!("Squared: {}", x))
        .collect();
    ```

- *Summary*:
  - Use `for_each` when you only want to perform an action on each element and don’t need the iterator anymore.
  - Use `inspect` if you want to peek into the iterator pipeline while keeping the iterator chain intact.

---

- **`nth`**: Returns the nth element of the iterator (zero-based index) or `None` if it is out of bounds.

    ```rust
    let v = vec![1, 2, 3, 4];
    let third = v.iter().nth(2); // Some(&3)
    ```

- **`flatten`**: Flattens an iterator of iterators into a single iterator.

    ```rust
    let v = vec![vec![1, 2], vec![3, 4]];
    let flattened: Vec<_> = v.into_iter().flatten().collect(); // [1, 2, 3, 4]
    ```

- **`partition`**: Splits an iterator into two collections based on a predicate.

    ```rust
    let v = vec![1, 2, 3, 4];
    let (even, odd): (Vec<_>, Vec<_>) = v.into_iter().partition(|&x| x % 2 == 0); // ([2, 4], [1, 3])
    ```

- **`take_while`**: Takes elements from the iterator while a predicate is true.

    ```rust
    let v = vec![1, 2, 3, 4];
    let taken: Vec<_> = v.iter().take_while(|&&x| x < 3).collect(); // [1, 2]
    ```

- **`skip_while`**: Skips elements from the iterator while a predicate is true, then yields the rest.

    ```rust
    let v = vec![1, 2, 3, 4];
    let skipped: Vec<_> = v.iter().skip_while(|&&x| x < 3).collect(); // [3, 4]
    ```

---

**Why Double Ampersands (`&&`) in `take_while` or `skip_while`**

The double ampersands (`&&`) are required due to the way the Rust compiler infers the types in closures and iterator adapters. Let's break this down.

Consider this example:

```rust
let v = vec![1, 2, 3, 4, 5];
let result: Vec<_> = v.iter().take_while(|&&x| x < 4).collect();
```

Here's what's happening:

- `v.iter()` produces an iterator over references to the elements in `v`, so each item yielded by `v.iter()` is `&i32` (a reference to an `i32`).
- `take_while` provides each item (of type `&i32`) to the closure.
- If we want to compare the integer value (not the reference) within the closure, we need to dereference `&i32` to get `i32`.

The double ampersands (`&&`) in `|&&x| x < 4` mean:
- The first `&` is because the iterator is iterating over references (`&i32`).
- The second `&` is because `take_while` passes a reference to each item to the closure (which is `&&i32` in this case).

You can think of it like this:

- `&&x` unpacks `&&i32` to `i32`, allowing us to use `x` as an `i32` inside the closure.

Without `&&`, you would get a type mismatch error because you’d be comparing `&i32` (a reference) directly to `4` (an integer), which isn't allowed without dereferencing.

If you want to avoid the double ampersands, you could write it like this, explicitly dereferencing:

```rust
let result: Vec<_> = v.iter().take_while(|&x| *x < 4).collect();
```

Or use a reference comparison if you want to avoid dereferencing:

```rust
let result: Vec<_> = v.iter().take_while(|&&x| x < 4).collect();
```

---

- **`peekable`**: Converts an iterator into a "peekable" iterator that allows you to peek at the next element.

    ```rust
    let mut iter = vec![1, 2, 3].into_iter().peekable();
    println!("{:?}", iter.peek()); // Some(&1)
    ```

- **`fuse`**: Makes an iterator that stops returning elements after it has returned `None` once.

    ```rust
    let v = vec![1, 2, 3];
    let mut iter = v.iter().fuse();
    println!("{:?}", iter.next()); // Some(&1)
    println!("{:?}", iter.next()); // Some(&2)
    println!("{:?}", iter.next()); // Some(&3)
    println!("{:?}", iter.next()); // None
    println!("{:?}", iter.next()); // None (fused)
    ```

- **`by_ref`**: Borrows the iterator instead of consuming it.

    ```rust
    let v = vec![1, 2, 3];
    let mut iter = v.iter();
    let first: Vec<_> = iter.by_ref().take(2).collect(); // [1, 2]
    let second: Vec<_> = iter.collect(); // [3]
    ```

- **`copied`**: Converts an iterator of references to an iterator of copied values (only for types that implement `Copy`).

    ```rust
    let v = vec![1, 2, 3];
    let copied: Vec<_> = v.iter().copied().collect(); // [1, 2, 3]
    ```

- **`cloned`**: Converts an iterator of references to an iterator of cloned values.

    ```rust
    let v = vec!["a", "b", "c"];
    let cloned: Vec<_> = v.iter().cloned().collect(); // ["a", "b", "c"]
    ```

- **`cycle`**: Repeats the iterator indefinitely (useful for infinite loops).

    ```rust
    let v = vec![1, 2];
    let mut iter = v.iter().cycle();
    println!("{:?}", iter.next()); // Some(&1)
    println!("{:?}", iter.next()); // Some(&2)
    println!("{:?}", iter.next()); // Some(&1)
    ```

- **`unzip`**: Converts an iterator of pairs into a pair of collections (like splitting keys and values).

    ```rust
    let pairs = vec![(1, "a"), (2, "b")];
    let (nums, chars): (Vec<_>, Vec<_>) = pairs.into_iter().unzip(); // ([1, 2], ["a", "b"])
    ```

- **`product`**: Computes the product of the elements in the iterator.

    ```rust
    let v = vec![1, 2, 3, 4];
    let product: i32 = v.iter().product(); // 24
    ```

- **`sum`**: Computes the sum of the elements in the iterator.

    ```rust
    let v = vec![1, 2, 3, 4];
    let sum: i32 = v.iter().sum(); // 10
    ```

- **`rev`**: Reverses the order of an iterator.

    ```rust
    let v = vec![1, 2, 3];
    let reversed: Vec<_> = v.iter().rev().collect(); // [3, 2, 1]
    ```

- **`step_by`**: Creates an iterator that steps by the given amount, skipping elements in between.

    ```rust
    let v = vec![1, 2, 3, 4, 5];
    let stepped: Vec<_> = v.iter().step_by(2).collect(); // [1, 3, 5]
    ```

- **`flat_map`**: Maps each element to an iterator and then flattens the result.

    ```rust
    let v = vec![1, 2, 3];
    let flat_mapped: Vec<_> = v.iter().flat_map(|&x| vec![x, x * 10]).collect(); // [1, 10, 2, 20, 3, 30]
    ```

- **`scan`**: Similar to `fold`, but returns an iterator of intermediate results.

    ```rust
    let v = vec![1, 2, 3, 4];
    let scanned: Vec<_> = v.iter().scan(0, |state, &x| {
        *state += x;
        Some(*state)
    }).collect(); // [1, 3, 6, 10]
    ```

- **`reduce`**: Reduces the elements to a single value by successively applying a function. Unlike `fold`, it doesn’t need an initial value and returns `None` if the iterator is empty.

    ```rust
    let v = vec![1, 2, 3, 4];
    let result = v.iter().copied().reduce(|a, b| a + b); // Some(10)
    ```

- **`intersperse`** (nightly feature at the time of writing): Inserts a specified value between each pair of elements.

    ```rust
    #![feature(iter_intersperse)] // requires nightly
    let v = vec![1, 2, 3];
    let interspersed: Vec<_> = v.iter().intersperse(&0).collect(); // [1, 0, 2, 0, 3]
    ```

- **`dedup_by_key`**: Removes consecutive duplicate elements based on a key.

    ```rust
    let mut v = vec!["apple", "apricot", "banana", "cherry", "cherry"];
    v.dedup_by_key(|s| s.chars().next());
    // ["apple", "banana", "cherry"]
    ```

- **`dedup_by`**: Removes consecutive duplicates based on a comparison function.

    ```rust
    let mut v = vec![1, 2, 2, 3, 4, 4, 5];
    v.dedup_by(|a, b| a == b);
    // [1, 2, 3, 4, 5]
    ```

- **`partition_in_place`**: Rearranges elements so that those that match a predicate are at the beginning of the collection.

    ```rust
    let mut v = vec![1, 2, 3, 4, 5];
    let mid = v.iter_mut().partition_in_place(|&x| x % 2 == 0);
    // `v` is now ordered with evens at the front and returns the index of the partition point.
    ```

- **`partition_map`**: Partitions the iterator into two collections based on a function.

    ```rust
    let v = vec![1, 2, 3, 4];
    let (even, odd): (Vec<_>, Vec<_>) = v.into_iter().partition_map(|x| {
        if x % 2 == 0 {
            Either::Left(x)
        } else {
            Either::Right(x)
        }
    });
    ```

- **`find_map`**: Searches for an element that matches a predicate, and applies a function to the matched element.

    ```rust
    let v = vec![1, 2, 3, 4];
    let result = v.iter().find_map(|&x| if x % 2 == 0 { Some(x * 10) } else { None });
    // Some(20) - because the first even number is 2, multiplied by 10 gives 20
    ```

- **`try_fold`**: Like `fold`, but can short-circuit if an error occurs.

    ```rust
    let v = vec![1, 2, 3, 4];
    let result: Result<i32, &str> = v.iter().try_fold(0, |acc, &x| {
        if x == 3 { Err("found 3") } else { Ok(acc + x) }
    });
    // Err("found 3")
    ```

- **`try_for_each`**: Like `for_each`, but can short-circuit if an error occurs.

    ```rust
    let v = vec![1, 2, 3, 4];
    let result: Result<(), &str> = v.iter().try_for_each(|&x| {
        if x == 3 { Err("found 3") } else { Ok(()) }
    });
    // Err("found 3")
    ```


---

