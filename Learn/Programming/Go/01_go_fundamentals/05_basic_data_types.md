## Basic Data Types


Go's type system includes fundamental types with specific sizes and characteristics.

**Integer Types:**

- **Signed**: `int8`, `int16`, `int32`, `int64`
- **Unsigned**: `uint8`, `uint16`, `uint32`, `uint64`
- **Architecture-dependent**: `int`, `uint` (32 or 64 bits)
- **Aliases**: `byte` (uint8), `rune` (int32)

Integer overflow wraps around according to two's complement arithmetic. The `int` type is most commonly used for general integer values.

**Floating-Point Types:**

- `float32`: IEEE 754 32-bit floating-point
- `float64`: IEEE 754 64-bit floating-point

Floating-point operations follow IEEE 754 standards for precision, rounding, and special values (infinity, NaN).

**String Type:** Strings are immutable sequences of bytes, typically UTF-8 encoded text. String literals use double quotes or backticks (raw strings).

**Key points:**

- Immutable once created
- Can contain arbitrary bytes
- Length measured in bytes, not characters
- Indexing and slicing operations return bytes

**Boolean Type:** The `bool` type has two values: `true` and `false`. Boolean values result from comparison operations and logical expressions.

**Complex Types:**

- `complex64`: Complex numbers with float32 real and imaginary parts
- `complex128`: Complex numbers with float64 real and imaginary parts

Complex numbers support arithmetic operations and have built-in functions for component access.

