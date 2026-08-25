## Zig Basic Syntax and Structure


### Variable Declarations and Mutability

Zig uses explicit variable declarations with the `var` and `const` keywords. Variables declared with `const` are immutable, while `var` creates mutable variables.

```zig
const pi: f32 = 3.14159; // Immutable constant
var counter: i32 = 0;    // Mutable variable
```

**Type inference** allows omitting explicit types when the compiler can deduce them:

```zig
const message = "Hello, Zig!"; // Type inferred as []const u8
var temperature = 23.5;        // Type inferred as comptime_float
```

**Undefined variables** can be declared without initial values using the `undefined` keyword:

```zig
var data: [100]u8 = undefined; // Uninitialized array
```

**Comptime variables** are evaluated at compile time:

```zig
comptime var build_mode = "debug";
```

### Primitive Data Types

Zig provides a comprehensive set of primitive types with explicit sizing:

**Integer Types:**
- Signed integers: `i8`, `i16`, `i32`, `i64`, `i128`, `isize`
- Unsigned integers: `u8`, `u16`, `u32`, `u64`, `u128`, `usize`
- Arbitrary bit-width integers: `i3`, `u7`, `i23`, etc.

```zig
const small_int: i8 = 127;
const big_uint: u64 = 18446744073709551615;
const custom_width: u3 = 7; // 3-bit unsigned integer (0-7)
```

**Floating Point Types:**
- `f16`, `f32`, `f64`, `f80`, `f128`
- `comptime_float` for compile-time float literals

```zig
const small_float: f32 = 3.14;
const precise_float: f64 = 2.718281828459045;
```

**Boolean Type:**
- `bool` with values `true` and `false`

```zig
const is_valid: bool = true;
const has_error = false; // Type inferred
```

**Character and String Types:**
- `u8` for individual bytes/characters
- `[]const u8` for string slices
- `[N]u8` for fixed-size arrays of characters

```zig
const letter: u8 = 'A';
const greeting: []const u8 = "Hello, World!";
const buffer: [256]u8 = undefined;
```

**Pointer Types:**
- Single-item pointers: `*T`
- Many-item pointers: `[*]T`
- Null-terminated pointers: `[*:0]T`
- Optional pointers: `?*T`

```zig
var value: i32 = 42;
const ptr: *i32 = &value;
const optional_ptr: ?*i32 = null;
```

**Special Types:**
- `void` - represents no value
- `noreturn` - for functions that never return
- `type` - represents a type itself
- `anyerror` - any error type

### Operators and Expressions

**Arithmetic Operators:**
```zig
const a = 10 + 5;   // Addition
const b = 20 - 3;   // Subtraction
const c = 4 * 7;    // Multiplication
const d = 15 / 3;   // Division
const e = 17 % 5;   // Modulo
```

**Bitwise Operators:**
```zig
const x = 0b1010 & 0b1100; // AND: 0b1000
const y = 0b1010 | 0b1100; // OR:  0b1110
const z = 0b1010 ^ 0b1100; // XOR: 0b0110
const w = ~0b1010;         // NOT: complement
const left = 0b1010 << 2;  // Left shift
const right = 0b1010 >> 1; // Right shift
```

**Comparison Operators:**
```zig
const equal = (a == b);
const not_equal = (a != b);
const less = (a < b);
const greater = (a > b);
const less_equal = (a <= b);
const greater_equal = (a >= b);
```

**Logical Operators:**
```zig
const and_result = true and false;
const or_result = true or false;
const not_result = !true;
```

**Assignment Operators:**
```zig
var num = 10;
num += 5;  // num = num + 5
num -= 3;  // num = num - 3
num *= 2;  // num = num * 2
num /= 4;  // num = num / 4
num %= 3;  // num = num % 3
```

**Overflow Operators:**
Zig provides explicit overflow-handling operators:
```zig
const safe_add = a +% b;    // Wrapping addition
const safe_sub = a -% b;    // Wrapping subtraction
const safe_mul = a *% b;    // Wrapping multiplication
const saturating = a +| b;  // Saturating addition
```

**Pointer and Address Operators:**
```zig
var value = 42;
const address = &value;     // Address-of operator
const dereferenced = ptr.*; // Dereference operator
```

### Comments and Documentation

**Single-line comments** use `//`:
```zig
// This is a single-line comment
const value = 42; // Inline comment
```

**Multi-line comments** use `//` on each line (no block comment syntax):
```zig
// This is a multi-line comment
// spanning several lines
// Each line needs the // prefix
```

**Documentation comments** use `///` for generating documentation:
```zig
/// Calculates the factorial of a given number
/// Returns the factorial value or error if input is negative
/// 
/// Parameters:
///   n: The number to calculate factorial for
/// 
/// Returns:
///   The factorial of n as u64
pub fn factorial(n: u32) u64 {
    // Implementation here
}
```

**Container-level documentation** uses `//!` at the beginning of files:
```zig
//! This module provides mathematical utility functions
//! including factorial, fibonacci, and prime number operations
//!
//! Usage example:
//!   const math = @import("math.zig");
//!   const result = math.factorial(5);
```

**Documentation attributes** can be embedded:
```zig
/// Add two integers together
/// 
/// Example:
/// ```zig
/// const result = add(5, 3); // result is 8
/// ```
pub fn add(a: i32, b: i32) i32 {
    return a + b;
}
```

### Code Organization Basics

**File Structure:**
Zig source files use the `.zig` extension and serve as modules. Each file is a struct-like container.

```zig
// main.zig
const std = @import("std");
const math = @import("math.zig");

pub fn main() void {
    // Program entry point
}
```

**Importing and Exporting:**
```zig
// Importing standard library
const std = @import("std");
const print = std.debug.print;

// Importing custom modules
const utils = @import("utils.zig");
const config = @import("config/settings.zig");

// Exporting functions and constants
pub fn publicFunction() void {}
pub const PUBLIC_CONSTANT = 42;

// Private (not exported)
fn privateFunction() void {}
const PRIVATE_CONSTANT = 100;
```

**Module System:**
```zig
// math.zig
pub const PI = 3.14159;

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub fn multiply(a: i32, b: i32) i32 {
    return a * b;
}

// Using in another file
const math = @import("math.zig");
const result = math.add(5, 3);
const pi_value = math.PI;
```

**Namespaces and Containers:**
```zig
const MyNamespace = struct {
    pub const VERSION = "1.0.0";
    
    pub fn doSomething() void {
        // Implementation
    }
    
    const InternalStruct = struct {
        field: i32,
    };
};

// Usage
const version = MyNamespace.VERSION;
MyNamespace.doSomething();
```

**Build Configuration:**
```zig
// build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    const exe = b.addExecutable(.{
        .name = "my-app",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    
    b.installArtifact(exe);
}
```

**Directory Structure:**
```
project/
├── build.zig
├── src/
│   ├── main.zig
│   ├── utils.zig
│   └── modules/
│       ├── parser.zig
│       └── networking.zig
├── tests/
│   └── test_main.zig
└── docs/
    └── README.md
```

**Testing Organization:**
```zig
// In source file
const expect = std.testing.expect;

test "basic addition" {
    try expect(add(2, 3) == 5);
}

test "edge cases" {
    try expect(add(0, 0) == 0);
    try expect(add(-1, 1) == 0);
}

// Separate test file
// tests/test_math.zig
const std = @import("std");
const math = @import("../src/math.zig");
const expect = std.testing.expect;

test "math module tests" {
    try expect(math.add(10, 20) == 30);
}
```

**Key Points:**
- Variable mutability is explicit with `const` and `var` keywords
- Type system includes arbitrary-precision integers and explicit overflow handling
- Documentation uses `///` for functions and `//!` for modules
- Modules are files that can export public symbols using `pub`
- Code organization follows a simple import/export system without complex namespace hierarchies
- Build system uses `build.zig` for configuration and dependency management

---

