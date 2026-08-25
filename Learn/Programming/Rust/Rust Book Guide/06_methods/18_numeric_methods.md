## **Numeric Methods**


- **`abs()`**: Returns the absolute value of a number.

    ```rust
    let x = -5;
    println!("{}", x.abs()); // 5
    ```

- **`pow()`**: Raises the number to a power.

    ```rust
    let x = 2;
    println!("{}", x.pow(3)); // 8
    ```

- **`min()` and `max()`**: Returns the minimum or maximum of two numbers.

    ```rust
    let x = 5;
    let y = 10;
    println!("{}", x.min(y)); // 5
    println!("{}", x.max(y)); // 10
    ```

- **`to_string()`**: Converts a number to a string.

    ```rust
    let x = 5;
    let s = x.to_string();
    println!("{}", s); // "5"
    ```

### Handling Overflows/Underflows

#### 1. **`wrapping_*` Methods:**
   These methods perform arithmetic operations and wrap around on overflow. For example, if you exceed the maximum value of an integer type, it "wraps" around to the minimum value and continues from there.

   - **Example:**
     - In an 8-bit integer (range 0-255), `255 + 1` would wrap around to `0`.
     - Rust: `let result = 255u8.wrapping_add(1); // result is 0`

   - **Analogy:** Think of this as a car odometer: once it reaches its maximum value, it rolls over back to zero.

- **`wrapping_add()`**: Adds two numbers, wrapping around on overflow.

    ```rust
    let a: i32 = 2147483647;
    println!("{}", a.wrapping_add(1)); // -2147483648
    ```


#### 2. **`checked_*` Methods:**
   These methods perform arithmetic and return `None` if an overflow occurs. They are useful when you want to explicitly check for overflow.

   - **Example:**
     - Rust: `let result = 255u8.checked_add(1); // result is None`
   
   - **Analogy:** This is like a safe where you try to open it, and it gives you a warning or fails silently when you enter a wrong code.

- **`checked_add()`**: Adds two numbers, returning `None` if there’s an overflow.

    ```rust
    let a: i32 = 2147483647;
    println!("{:?}", a.checked_add(1)); // None
    ```

- **`checked_div()`**: Divides two numbers, returning `None` if division would result in overflow or divide by zero.

    ```rust
    let a: i32 = 10;
    println!("{:?}", a.checked_div(0)); // None
    ```

#### 3. **`overflowing_*` Methods:**
   These methods perform arithmetic operations and return a tuple containing the result and a boolean that indicates whether an overflow occurred.

   - **Example:**
     - Rust: `let (result, overflowed) = 255u8.overflowing_add(1); // result is 0, overflowed is true`
   
   - **Analogy:** This is like having an indicator light on a machine that shows whether a process overflowed or exceeded its limits while continuing to give you a result.

#### 4. **`saturating_*` Methods:**
   These methods perform arithmetic and "saturate" at the numeric bounds instead of wrapping around. When an overflow would occur, the result is clamped to the maximum or minimum value of the integer type.

   - **Example:**
     - Rust: `let result = 255u8.saturating_add(1); // result is 255`
   
   - **Analogy:** Imagine you're pouring water into a cup. Once it's full, no more water can enter—it just stops at the top.

- **`saturating_add()`**: Adds two numbers, saturating at the numeric bounds instead of overflowing.

    ```rust
    let a: i32 = 2147483647;
    println!("{}", a.saturating_add(1)); // 2147483647
    ```

