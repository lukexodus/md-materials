## Primitive Types


### Integer Types and Sizes

#### Signed Integer Types

Zig provides signed integer types with explicit bit widths using the `i` prefix followed by the bit count:

- `i8`: 8-bit signed integer (-128 to 127)
- `i16`: 16-bit signed integer (-32,768 to 32,767)
- `i32`: 32-bit signed integer (-2,147,483,648 to 2,147,483,647)
- `i64`: 64-bit signed integer (-9,223,372,036,854,775,808 to 9,223,372,036,854,775,807)
- `i128`: 128-bit signed integer
- `isize`: Pointer-sized signed integer (matches platform pointer width)

#### Unsigned Integer Types

Unsigned integer types use the `u` prefix:

- `u8`: 8-bit unsigned integer (0 to 255)
- `u16`: 16-bit unsigned integer (0 to 65,535)
- `u32`: 32-bit unsigned integer (0 to 4,294,967,295)
- `u64`: 64-bit unsigned integer (0 to 18,446,744,073,709,551,615)
- `u128`: 128-bit unsigned integer
- `usize`: Pointer-sized unsigned integer (commonly used for array indices)

#### Arbitrary-Width Integer Types

Zig supports arbitrary-width integers for any bit width from 1 to 65535:

- `u1` to `u65535`: Unsigned integers of any bit width
- `i1` to `i65535`: Signed integers of any bit width
- Useful for bit manipulation, packed structures, and hardware interfaces

**Example Usage:**

```zig
const narrow_int: u3 = 7;     // 3-bit unsigned (0-7)
const custom_int: i13 = -1024; // 13-bit signed
```

#### Integer Literals and Representation

**Decimal Literals:** Standard decimal notation **Hexadecimal Literals:** Prefix with `0x` (e.g., `0xFF`) **Octal Literals:** Prefix with `0o` (e.g., `0o755`) **Binary Literals:** Prefix with `0b` (e.g., `0b1010`) **Underscore Separators:** Improve readability (e.g., `1_000_000`)

### Floating-Point Types

#### Standard Floating-Point Types

Zig provides IEEE 754-compliant floating-point types:

- `f16`: 16-bit half-precision floating-point
- `f32`: 32-bit single-precision floating-point
- `f64`: 64-bit double-precision floating-point
- `f80`: 80-bit extended-precision floating-point (x86-specific)
- `f128`: 128-bit quadruple-precision floating-point

#### Floating-Point Literals

**Standard Notation:** `3.14159`, `2.0`, `0.5` **Scientific Notation:** `1.5e10`, `2.3E-5` **Hexadecimal Float Notation:** `0x1.0p0` (represents 1.0)

#### Special Floating-Point Values

Zig provides standard IEEE 754 special values:

- Positive and negative infinity
- NaN (Not a Number) representations
- Signed zeros (+0.0 and -0.0)

### Boolean Type

#### Boolean Type Definition

The `bool` type represents logical true/false values:

- `true`: Boolean true value
- `false`: Boolean false value
- Size: 1 byte in memory
- Only accepts explicit `true` or `false` values

#### Boolean Operations

**Logical Operators:**

- `and`: Logical AND operation
- `or`: Logical OR operation
- `!`: Logical NOT operation

**Comparison Results:** All comparison operations (`==`, `!=`, `<`, `>`, `<=`, `>=`) return `bool` values.

**Example Usage:**

```zig
const is_valid: bool = true;
const result = (x > 0) and (y < 10);
const inverted = !is_valid;
```

### Character and String Handling

#### Character Representation

Zig does not have a dedicated character type. Instead:

- Single characters are represented as `u8` values (ASCII)
- Unicode code points use `u21` (can hold any Unicode code point)
- Character literals use single quotes: `'A'` (equivalent to `u8` value 65)

#### String Types and Literals

**String Literals:** String literals are arrays of `u8` bytes terminated with a null byte:

- `"hello"` has type `*const [5:0]u8` (null-terminated)
- Raw strings use `\\` prefix for literal content without escaping

**String Slices:**

- `[]const u8`: Most common string type (slice of bytes)
- `[:0]const u8`: Null-terminated string slice (C-compatible)
- No automatic string type - explicit slice types required

#### String Operations and Handling

**String Comparison:** Zig requires explicit comparison functions:

- No built-in `==` operator for string comparison
- Use `std.mem.eql(u8, str1, str2)` for equality
- Use `std.mem.compare(u8, str1, str2)` for ordering

**String Manipulation:** Standard library provides string utilities in `std.mem`:

- `std.mem.copy()`: Copy string data
- `std.mem.concat()`: Concatenate strings
- `std.mem.split()`: Split strings by delimiter
- `std.mem.replace()`: Replace substring occurrences

#### Unicode Support

**UTF-8 Encoding:** Strings in Zig are UTF-8 encoded by default:

- `[]const u8` can contain valid UTF-8 sequences
- Standard library provides UTF-8 validation and manipulation
- `std.unicode` module for Unicode operations

**Unicode Iteration:**

```zig
// Iterate over Unicode code points
var iter = std.unicode.Utf8Iterator{ .bytes = utf8_string };
while (iter.nextCodepoint()) |codepoint| {
    // Process each Unicode code point
}
```

### Type Coercion Rules

#### Implicit Coercion (Widening)

**Integer Widening:** Smaller integer types coerce to larger ones of the same signedness:

- `u8` → `u16` → `u32` → `u64` → `u128`
- `i8` → `i16` → `i32` → `i64` → `i128`
- No automatic coercion between signed and unsigned types

**Floating-Point Widening:** Smaller floating-point types coerce to larger precision:

- `f16` → `f32` → `f64` → `f128`

#### Explicit Type Conversion

**Integer Casting:** Use built-in functions for explicit conversion:

- `@intCast()`: Convert between integer types with runtime safety checks
- `@truncate()`: Truncate to smaller integer type (potential data loss)
- `@bitCast()`: Reinterpret bits as different type (same size required)

**Floating-Point Conversion:**

- `@floatCast()`: Convert between floating-point types
- `@floatFromInt()`: Convert integer to floating-point
- `@intFromFloat()`: Convert floating-point to integer (truncates)

#### Coercion to Optional Types

Any type `T` can be implicitly coerced to its optional variant `?T`:

- `null` coerces to any optional type
- Non-null values coerce to optional automatically
- Useful for function parameters and error handling

#### Array and Slice Coercion

**Array to Slice Coercion:** Arrays automatically coerce to slices:

- `[N]T` coerces to `[]T`
- `[N:S]T` (sentinel-terminated array) coerces to `[:S]T`

**Pointer Coercion:**

- Single-item pointers coerce to many-item pointers
- Mutable pointers coerce to const pointers
- Aligned pointers coerce to less-aligned variants

#### Compile-Time Known Values

**Comptime Integer Coercion:** Compile-time known integers coerce to any integer type that can represent the value:

- Literal `0` can coerce to any integer type
- Literal `255` can coerce to `u8` or larger unsigned types
- Literal `-1` can coerce to any signed integer type

**Example:**

```zig
const a: u8 = 42;    // Literal 42 coerces to u8
const b: i32 = -100; // Literal -100 coerces to i32
// const c: u8 = 256; // Compile error - 256 doesn't fit in u8
```

#### Error Union Coercion

Values automatically coerce to error unions:

- `T` coerces to `anyerror!T`
- Specific error sets coerce to broader error sets
- `anyerror` is the universal error set

**Key Points**

- Integer types have explicit bit widths with no implicit size assumptions
- Floating-point types follow IEEE 754 standards with multiple precision levels
- Strings are UTF-8 encoded byte slices with explicit null-termination when needed
- Type coercion is conservative, favoring explicit conversions over implicit ones
- Compile-time known values have more flexible coercion rules than runtime values

**Related Topics**: Memory layout and alignment of primitive types, overflow behavior in debug vs release builds, comptime evaluation of type conversions, and interoperability with C primitive types would provide deeper understanding of Zig's type system design.

---

