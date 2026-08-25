## `std::slice`


The `std::slice` module in Rust provides functions and types for working with slices. A **slice** is a dynamically sized view into a contiguous sequence of elements. It allows for borrowing a part of an array or a vector without taking ownership of the entire collection.

---

**Key Features of Slices**

- **Borrowed Views:** Slices allow you to work with sections of an array or vector without copying data.
- **Dynamically Sized:** Unlike arrays, slices do not have a fixed size at compile time.
- **Memory Efficient:** Slices reference existing data rather than creating a new collection.
- **Useful for Function Parameters:** They allow functions to operate on different data structures (arrays, vectors, etc.) without taking ownership.

---

**Basic Slice Example**

```rust
fn main() {
    let array = [1, 2, 3, 4, 5];
    let slice: &[i32] = &array[1..4]; // Slice from index 1 to 3

    println!("{:?}", slice); // Output: [2, 3, 4]
}
```

#### **Mutable Slices**

```rust
fn main() {
    let mut data = [1, 2, 3, 4, 5];
    let slice: &mut [i32] = &mut data[2..];

    slice[0] = 10; // Modifying slice modifies the original array
    println!("{:?}", data); // Output: [1, 2, 10, 4, 5]
}
```

---

### **Methods**

- **`len()`** – Returns the number of elements in the slice.
- **`is_empty()`** – Checks if the slice is empty.
- **`first()` / `last()`** – Returns a reference to the first or last element (if present).

---

**Working with Methods**

```rust
fn main() {
    let mut numbers = [10, 20, 30, 40, 50];

    println!("Length: {}", numbers.len());
    println!("First element: {:?}", numbers.first());
    println!("Last element: {:?}", numbers.last());
}
```

#### **For Splitting Slices**

- **`split_at<T>(&self, mid: usize) -> (&[T], &[T])`**
    
    - Splits the slice at the given index.
    - **Example:**
        
        ```rust
        let numbers = [1, 2, 3, 4, 5];
        let (left, right) = numbers.split_at(2);
        println!("{:?}, {:?}", left, right); // Output: [1, 2], [3, 4, 5]
        ```
        
- **`split_at_mut<T>(&mut self, mid: usize) -> (&mut [T], &mut [T])`**
    
    - Same as `split_at` but for mutable slices.

---

#### **For Iterating Over Slices**

- **`iter<T>(&self) -> Iter<T>`**
    
    - Returns an iterator over the elements of the slice.
    - **Example:**
        
        ```rust
        let numbers = [1, 2, 3];
        for num in numbers.iter() {
            println!("{}", num);
        }
        ```
        
- **`iter_mut<T>(&mut self) -> IterMut<T>`**
    
    - Returns a mutable iterator over the slice.
    - **Example:**
        
        ```rust
        let mut numbers = [1, 2, 3];
        for num in numbers.iter_mut() {
            *num *= 2;
        }
        println!("{:?}", numbers); // Output: [2, 4, 6]
        ```
        

---

#### **For Chunking Slices**

- **`chunks<T>(&self, size: usize) -> Chunks<T>`**
    
    - Returns non-overlapping chunks of the slice.
    - **Example:**
        
        ```rust
        let numbers = [1, 2, 3, 4, 5, 6];
        for chunk in numbers.chunks(2) {
            println!("{:?}", chunk);
        }
        ```
        
- **`chunks_mut<T>(&mut self, size: usize) -> ChunksMut<T>`**
    
    - Same as `chunks`, but returns mutable chunks.
- **`windows<T>(&self, size: usize) -> Windows<T>`**
    
    - Returns overlapping windows of `size`.
    - **Example:**
        
        ```rust
        let numbers = [1, 2, 3, 4, 5];
        for window in numbers.windows(3) {
            println!("{:?}", window);
        }
        ```
        

---

#### **For Searching Slices**

- **`binary_search<T: Ord>(&self, x: &T) -> Result<usize, usize>`**
    
    - Performs a binary search (slice must be sorted).
    - **Example:**
        
        ```rust
        let numbers = [1, 3, 5, 7, 9];
        match numbers.binary_search(&5) {
            Ok(index) => println!("Found at index {}", index),
            Err(_) => println!("Not found"),
        }
        ```
        
- **`contains<T: PartialEq>(&self, x: &T) -> bool`**
    
    - Checks if the slice contains an element.
    - **Example:**
        
        ```rust
        let numbers = [1, 2, 3, 4, 5];
        println!("{}", numbers.contains(&3)); // Output: true
        ```
        

---

#### For Sorting Slices**

- **`sort<T: Ord>(&mut self)`**
    
    - Sorts the slice in ascending order.
    - **Example:**
        
        ```rust
        let mut numbers = [4, 2, 5, 1, 3];
        numbers.sort();
        println!("{:?}", numbers); // Output: [1, 2, 3, 4, 5]
        ```
        
- **`sort_unstable<T: Ord>(&mut self)`**
    
    - Like `sort`, but does not guarantee a stable sort order (faster in some cases).

---

#### **For Swapping and Rotating**

- **`swap<T>(&mut self, a: usize, b: usize)`**
    
    - Swaps two elements in the slice.
    - **Example:**
        
        ```rust
        let mut numbers = [1, 2, 3];
        numbers.swap(0, 2);
        println!("{:?}", numbers); // Output: [3, 2, 1]
        ```
        
- **`rotate_left<T>(&mut self, n: usize)`**
    
    - Rotates the slice left by `n` positions.
    - **Example:**
        
        ```rust
        let mut numbers = [1, 2, 3, 4, 5];
        numbers.rotate_left(2);
        println!("{:?}", numbers); // Output: [3, 4, 5, 1, 2]
        ```
        
- **`rotate_right<T>(&mut self, n: usize)`**
    
    - Rotates the slice right by `n` positions.

---

#### **Utility Functions**

- **`fill<T: Clone>(&mut self, value: T)`**
    
    - Fills the slice with a given value.
    - **Example:**
        
        ```rust
        let mut numbers = [0; 5];
        numbers.fill(3);
        println!("{:?}", numbers); // Output: [3, 3, 3, 3, 3]
        ```
        
- **`reverse<T>(&mut self)`**
    
    - Reverses the slice in place.
    - **Example:**
        
        ```rust
        let mut numbers = [1, 2, 3];
        numbers.reverse();
        println!("{:?}", numbers); // Output: [3, 2, 1]
        ```


---

### Functions

#### **For Creating Slices**

- **`from_ref<T>(t: &T) -> &[T]`**
    
    - Converts a single reference into a single-element slice.
    - **Example:**
        
        ```rust
        let num = 42;
        let slice = std::slice::from_ref(&num);
        println!("{:?}", slice); // Output: [42]
        ```
        
- **`from_mut<T>(t: &mut T) -> &mut [T]`**
    
    - Converts a mutable reference into a single-element mutable slice.
    - **Example:**
        
        ```rust
        let mut num = 42;
        let slice = std::slice::from_mut(&mut num);
        slice[0] += 1;
        println!("{:?}", slice); // Output: [43]
        ```
        
- **`from_raw_parts<T>(data: *const T, len: usize) -> &[T]`** _(unsafe)_
    
    - Creates a slice from a raw pointer and a length.
    - **Example:**
        
        ```rust
        let array = [1, 2, 3, 4, 5];
        let ptr = array.as_ptr();
        let slice = unsafe { std::slice::from_raw_parts(ptr, 3) };
        println!("{:?}", slice); // Output: [1, 2, 3]
        ```
        
- **`from_raw_parts_mut<T>(data: *mut T, len: usize) -> &mut [T]`** _(unsafe)_
    
    - Creates a mutable slice from a raw pointer and a length.
    - **Example:**
        
        ```rust
        let mut array = [1, 2, 3, 4, 5];
        let ptr = array.as_mut_ptr();
        let slice = unsafe { std::slice::from_raw_parts_mut(ptr, 3) };
        slice[0] = 10;
        println!("{:?}", array); // Output: [10, 2, 3, 4, 5]
        ```
        

#### Chunks vs Windows

Both `chunks(n)` and `windows(n)` are methods on slices that help iterate over sub-sections of the slice, but they behave differently in terms of overlap and mutability.

---

**`chunks(n)`**

- Divides the slice into **non-overlapping** chunks of size `n`.
- If the slice length is not a multiple of `n`, the last chunk will be smaller.
- Works for both immutable (`chunks()`) and mutable (`chunks_mut()`) slices.

**Example:**

```rust
fn main() {
    let numbers = [1, 2, 3, 4, 5, 6, 7];

    for chunk in numbers.chunks(3) {
        println!("{:?}", chunk);
    }
}
```

**Output:**

```
[1, 2, 3]
[4, 5, 6]
[7]
```

🔹 **Key property:** No overlap between chunks.

---

**`windows(n)`**

- Returns **overlapping** windows of size `n`.
- Each window contains `n` consecutive elements, shifting by one element per step.
- Works only on immutable slices (`windows()` does not have a mutable equivalent).

**Example:**

```rust
fn main() {
    let numbers = [1, 2, 3, 4, 5];

    for window in numbers.windows(3) {
        println!("{:?}", window);
    }
}
```

**Output:**

```
[1, 2, 3]
[2, 3, 4]
[3, 4, 5]
```

🔹 **Key property:** Each window overlaps with the previous window, moving forward by one element.

---

**Key Differences**

|Feature|`chunks(n)`|`windows(n)`|
|---|---|---|
|Overlapping|❌ No|✅ Yes|
|Sub-slice size|At most `n`|Exactly `n`|
|Moves by|`n` elements|1 element|
|Last slice|May be smaller|Always `n` (if possible)|
|Mutability|✅ `chunks_mut()` available|❌ Immutable only|

---

**Use Cases**

✔ Use **`chunks(n)`** when you need to process non-overlapping groups of elements, like batch processing.  
✔ Use **`windows(n)`** when you need to analyze a continuous sequence of `n` elements, like rolling averages or pattern matching.

