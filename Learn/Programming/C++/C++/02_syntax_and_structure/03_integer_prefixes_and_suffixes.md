## Integer Prefixes and Suffixes


In C++, when dealing with integers, certain suffixes and prefixes like `L`, `u`, `0`, and `0x` can be used to define the type and base of an integer literal. Here's how each of these works:

### 1. **Suffixes: `L`, `u`, `UL`, etc.**

Suffixes are used to specify the type of an integer literal.

- **`L`**: Indicates that the literal is of type `long`.
  - Example: `42L` is a `long` integer with a value of 42.
- **`u`**: Indicates that the literal is of type `unsigned int`.
  - Example: `42u` is an `unsigned int` with a value of 42.
- **`UL`** or **`LU`**: Indicates that the literal is of type `unsigned long`.
  - Example: `42UL` or `42LU` is an `unsigned long` with a value of 42.
- **`LL`**: Indicates that the literal is of type `long long`.
  - Example: `42LL` is a `long long` integer with a value of 42.
- **`ULL`** or **`LLU`**: Indicates that the literal is of type `unsigned long long`.
  - Example: `42ULL` or `42LLU` is an `unsigned long long` with a value of 42.

### 2. **Prefixes: `0` and `0x`**

Prefixes define the base of the integer literal.

- **`0`**: Indicates that the literal is in **octal** (base 8).
  - Example: `042` represents the octal number `42`, which is equal to `34` in decimal.
- **`0x`**: Indicates that the literal is in **hexadecimal** (base 16).
  - Example: `0x2A` represents the hexadecimal number `2A`, which is equal to `42` in decimal.

### Combining Prefixes and Suffixes

You can combine these prefixes and suffixes to create literals of specific types and bases.

- **Hexadecimal Long**:
  - Example: `0x2AL` is a `long` integer in hexadecimal with a decimal value of `42`.
- **Unsigned Octal**:
  - Example: `042u` is an `unsigned int` with an octal value of `42`, which equals `34` in decimal.
- **Unsigned Long Long Hexadecimal**:
  - Example: `0xFFULL` is an `unsigned long long` with a hexadecimal value of `FF`, which equals `255` in decimal.

### Practical Examples

#### Example 1: Octal Literal
```cpp
int octal = 042; // 042 in octal is 34 in decimal
```

#### Example 2: Hexadecimal Unsigned Long
```cpp
unsigned long hex = 0x2AUL; // 0x2A in hexadecimal is 42 in decimal
```

#### Example 3: Unsigned Integer
```cpp
unsigned int number = 42u; // 42 as an unsigned integer
```

---

