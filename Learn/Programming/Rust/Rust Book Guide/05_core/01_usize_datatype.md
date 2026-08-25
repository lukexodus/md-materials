## `usize` Datatype


`usize` is a primitive data type in Rust that represents an **unsigned** integer, and its size depends on the architecture of the system (either 32-bit or 64-bit). It's used primarily for indexing and size-related operations, such as indexing arrays, slices, or vectors, and dealing with memory sizes.

**Key Characteristics of `usize`:**
1. **Architecture-dependent size**:
   - On a **32-bit system**, `usize` is **32 bits** (4 bytes) wide.
   - On a **64-bit system**, `usize` is **64 bits** (8 bytes) wide.
   - This makes it appropriate for addressing memory, as its size matches the size of the system's memory address space.

2. **Unsigned**:
   - `usize` can only store non-negative values (no negative numbers).
   - The range of values for `usize` depends on the architecture:
     - On a 32-bit system: $0$ to $2^{32} - 1$ (4,294,967,295)
     - On a 64-bit system: $0$ to $2^{64} - 1$ (18,446,744,073,709,551,615)

3. **Common Uses**:
   - **Array indexing**: When accessing elements of an array, slice, or vector, the index must be of type `usize`.
     ```rust
     let arr = [10, 20, 30, 40];
     let index: usize = 2;
     println!("{}", arr[index]); // prints 30
     ```
   - **Memory sizes**: `usize` is also commonly used when dealing with memory sizes, such as the length of a slice or the capacity of a vector.
     ```rust
     let vec = vec![1, 2, 3];
     let size: usize = vec.len(); // len() returns usize
     ```

### Conversion with Other Types:
Rust provides methods to convert other numeric types to `usize` or convert `usize` to other types, like `u32`, `u64`, etc.

- **From integer to `usize`**:
  ```rust
  let x: i32 = 10;
  let y: usize = x as usize; // Explicit casting
  ```

- **From `usize` to integer**:
  ```rust
  let x: usize = 20;
  let y: u32 = x as u32;
  ```

### Methods Related to `usize`:
Since `usize` is an unsigned integer type, it inherits methods from Rust's integer primitives. Common methods include:

- **max_value()**: Returns the largest value that can be represented by `usize`.
  ```rust
  let max = usize::MAX;
  ```

- **min_value()**: Returns the smallest value, which is always 0.
  ```rust
  let min = usize::MIN;
  ```

- **checked_add(), checked_sub(), checked_mul()**: Performs arithmetic operations that return `None` if an overflow occurs.
  ```rust
  let a: usize = usize::MAX;
  let b = a.checked_add(1); // None, since this overflows
  ```

**Examples**:

- **Array/Slice indexing**:
  ```rust
  let arr = [1, 2, 3, 4];
  let idx: usize = 2;
  println!("{}", arr[idx]); // prints 3
  ```

- **Memory sizes**:
  ```rust
  let vec = vec![10, 20, 30];
  let size: usize = vec.len(); // len() returns usize
  println!("Size of vec: {}", size);
  ```

**Summary**:
- `usize` is a platform-dependent unsigned integer, useful for representing sizes and indexing collections.
- Its size is 32 bits on 32-bit systems and 64 bits on 64-bit systems, matching the addressable memory space.
- It's commonly used for array indexing, working with memory sizes, and interacting with low-level operations in Rust.

