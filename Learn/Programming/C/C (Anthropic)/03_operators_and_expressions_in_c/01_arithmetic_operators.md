## Arithmetic Operators


C provides a comprehensive set of arithmetic operators for mathematical calculations:

**Unary Operators:**

- `+` (unary plus): Indicates positive value
- `-` (unary minus): Negates the value
- `++` (increment): Increases value by 1 (pre-increment `++x` or post-increment `x++`)
- `--` (decrement): Decreases value by 1 (pre-decrement `--x` or post-decrement `x--`)

**Binary Operators:**

- `+` (addition): Adds two operands
- `-` (subtraction): Subtracts second operand from first
- `*` (multiplication): Multiplies two operands
- `/` (division): Divides first operand by second
- `%` (modulo): Returns remainder of division (works only with integers)

**Key Points:**

- Division behavior depends on operand types: integer division truncates the result, while floating-point division preserves decimals
- Modulo operator cannot be used with floating-point numbers
- Pre-increment/decrement returns the modified value; post-increment/decrement returns the original value before modification

**Example:**

```c
int a = 10, b = 3;
printf("%d\n", a / b);    // Output: 3 (integer division)
printf("%.2f\n", 10.0 / 3); // Output: 3.33 (floating-point division)
printf("%d\n", a % b);    // Output: 1 (remainder)
```

