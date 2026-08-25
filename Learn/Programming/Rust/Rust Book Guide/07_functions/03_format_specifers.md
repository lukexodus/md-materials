## Format Specifers


In Rust, formatting specifiers are used with the `format!`, `println!`, `eprintln!`, and similar macros to format strings. Each specifier modifies how the value is represented in the output. Below are some of the common and useful formatting specifiers:

---

### Basic Formatting Specifiers

1. **`{}`**: Default formatting. For types implementing the `Display` trait, this formats the value for user-facing output.

    ```rust
    let name = "Alice";
    println!("Hello, {}!", name); // Hello, Alice!
    ```

2. **`{:?}`**: Debug formatting. For types implementing the `Debug` trait, this formats the value for developer-facing output. Useful for inspecting internal representations.

    ```rust
    let v = vec![1, 2, 3];
    println!("{:?}", v); // [1, 2, 3]
    ```

3. **`{:#?}`**: Pretty Debug formatting. Like `{:?}`, but prints in a multi-line, indented format for better readability of complex structures.

    ```rust
    let v = vec![1, 2, 3];
    println!("{:#?}", v);
    // [
    //     1,
    //     2,
    //     3,
    // ]
    ```

---

### Number Formatting Specifiers

4. **`{:b}`**: Binary formatting.

    ```rust
    let num = 42;
    println!("{:b}", num); // 101010
    ```

5. **`{:o}`**: Octal formatting.

    ```rust
    let num = 42;
    println!("{:o}", num); // 52
    ```

6. **`{:x}`**: Lowercase hexadecimal formatting.

    ```rust
    let num = 42;
    println!("{:x}", num); // 2a
    ```

7. **`{:X}`**: Uppercase hexadecimal formatting.

    ```rust
    let num = 42;
    println!("{:X}", num); // 2A
    ```

8. **`{:e}`**: Scientific notation (lowercase "e").

    ```rust
    let num = 12345.6789;
    println!("{:e}", num); // 1.23456789e4
    ```

9. **`{:E}`**: Scientific notation (uppercase "E").

    ```rust
    let num = 12345.6789;
    println!("{:E}", num); // 1.23456789E4
    ```

---

### Alignment and Padding

10. **`{:width$}`**: Specifies a minimum width. Right-aligns by default.

    ```rust
    let num = 42;
    println!("{:5}", num); // "   42"
    ```

11. **`{:<width$}`**: Left-align within the specified width.

    ```rust
    let num = 42;
    println!("{:<5}", num); // "42   "
    ```

12. **`{:>width$}`**: Right-align within the specified width (same as default).

    ```rust
    let num = 42;
    println!("{:>5}", num); // "   42"
    ```

13. **`{:^width$}`**: Center-align within the specified width.

    ```rust
    let num = 42;
    println!("{:^5}", num); // " 42 "
    ```

14. **`{:0width$}`**: Zero padding. Pads numbers with leading zeros instead of spaces.

    ```rust
    let num = 42;
    println!("{:05}", num); // "00042"
    ```

---

### Precision for Floating-Point Numbers

15. **`{:.precision$}`**: Specifies the number of digits after the decimal point.

    ```rust
    let num = 3.141592;
    println!("{:.2}", num); // "3.14"
    ```

16. **`{:width$.precision$}`**: Combines width and precision for floating-point numbers.

    ```rust
    let num = 3.141592;
    println!("{:8.2}", num); // "    3.14"
    ```

---

### Sign Formatting

17. **`{:+}`**: Always show the sign for numbers.

    ```rust
    let num = 42;
    let neg_num = -42;
    println!("{:+}", num);     // "+42"
    println!("{:+}", neg_num); // "-42"
    ```

18. **`{: }`**: Space for positive numbers, minus for negative. Leaves a leading space for positive values.

    ```rust
    let num = 42;
    let neg_num = -42;
    println!("{: }", num);     // " 42"
    println!("{: }", neg_num); // "-42"
    ```

---

### Other Specifiers

19. **`{:p}`**: Pointer formatting. Prints a memory address.

    ```rust
    let s = "hello";
    println!("{:p}", s as *const str); // Prints the address of `s`
    ```

20. **Escaping Braces**: Use `{{` or `}}` to print a literal `{` or `}`.

    ```rust
    println!("{{Hello}}"); // "{Hello}"
    ```

---

**Example of Combining Specifiers**

You can combine different specifiers to achieve complex formatting:

```rust
let num = 42;
println!("{:+08}", num); // "+00000042"
```

In this example:
- `+` shows the sign.
- `0` pads with zeros.
- `8` sets the width to 8 characters.

