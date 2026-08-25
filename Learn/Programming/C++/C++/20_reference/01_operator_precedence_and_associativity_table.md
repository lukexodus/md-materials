## Operator Precedence and Associativity Table


| Operator                | Precedence | Associativity | Arity | Example      | Description                                            |
|-------------------------|------------|---------------|-------|--------------|--------------------------------------------------------|
| Scope resolution (`::`) | 1          | N/A           | 1     | `std::cout`   | Resolves the namespace scope                          |
| Member access (`.`)     | 2          | Left-to-Right | 2     | `obj.member`  | Accesses a member of an object                         |
| Member access (`->`)    | 2          | Left-to-Right | 2     | `ptr->member` | Accesses a member through a pointer                    |
| Function call (`()`)    | 2          | Left-to-Right | 1     | `func()`     | Calls a function                                      |
| Array subscript (`[]`)  | 2          | Left-to-Right | 2     | `arr[0]`     | Accesses an element of an array                        |
| Postfix increment (`++`)| 3          | Left-to-Right | 1     | `i++`        | Increments the value after its use                     |
| Postfix decrement (`--`)| 3          | Left-to-Right | 1     | `i--`        | Decrements the value after its use                     |
| Unary plus (`+`)        | 4          | Right-to-Left | 1     | `+x`         | Unary plus, has no effect on the value                 |
| Unary minus (`-`)       | 4          | Right-to-Left | 1     | `-x`         | Unary negation                                        |
| Logical NOT (`!`)       | 4          | Right-to-Left | 1     | `!x`         | Logical negation                                      |
| Bitwise NOT (`~`)       | 4          | Right-to-Left | 1     | `~x`         | Bitwise negation                                      |
| Prefix increment (`++`) | 4          | Right-to-Left | 1     | `++i`        | Increments the value before its use                    |
| Prefix decrement (`--`) | 4          | Right-to-Left | 1     | `--i`        | Decrements the value before its use                    |
| Type cast (`(type)`)    | 4          | Right-to-Left | 1     | `(int)x`     | Casts to a specific type                               |
| Pointer to member (`.*`) | 5         | Left-to-Right | 2     | `obj.*ptr`   | Accesses a member through a pointer to a member        |
| Pointer to member (`->*`) | 5        | Left-to-Right | 2     | `ptr->*mem`  | Accesses a member through a pointer to a member        |
| Multiplication (`*`)    | 6          | Left-to-Right | 2     | `a * b`      | Multiplies two values                                 |
| Division (`/`)          | 6          | Left-to-Right | 2     | `a / b`      | Divides two values                                   |
| Modulus (`%`)           | 6          | Left-to-Right | 2     | `a % b`      | Modulus operation                                    |
| Addition (`+`)          | 7          | Left-to-Right | 2     | `a + b`      | Adds two values                                      |
| Subtraction (`-`)       | 7          | Left-to-Right | 2     | `a - b`      | Subtracts two values                                 |
| Bitwise shift left (`<<`)| 8         | Left-to-Right | 2     | `a << b`     | Shifts bits to the left                              |
| Bitwise shift right (`>>`)| 8        | Left-to-Right | 2     | `a >> b`     | Shifts bits to the right                             |
| Relational less than (`<`)| 9        | Left-to-Right | 2     | `a < b`      | Checks if left is less than right                    |
| Relational greater than (`>`)| 9      | Left-to-Right | 2     | `a > b`      | Checks if left is greater than right                 |
| Relational less than or equal (`<=`)| 9 | Left-to-Right | 2     | `a <= b`     | Checks if left is less than or equal to right         |
| Relational greater than or equal (`>=`)| 9 | Left-to-Right | 2     | `a >= b`     | Checks if left is greater than or equal to right      |
| Equality (`==`)         | 10         | Left-to-Right | 2     | `a == b`     | Checks if two values are equal                       |
| Inequality (`!=`)       | 10         | Left-to-Right | 2     | `a != b`     | Checks if two values are not equal                   |
| Bitwise AND (`&`)       | 11         | Left-to-Right | 2     | `a & b`      | Bitwise AND operation                                |
| Bitwise XOR (`^`)       | 12         | Left-to-Right | 2     | `a ^ b`      | Bitwise XOR operation                                |
| Bitwise OR (`|`)        | 13         | Left-to-Right | 2     | `a | b`      | Bitwise OR operation                                 |
| Logical AND (`&&`)      | 14         | Left-to-Right | 2     | `a && b`     | Logical AND operation                                |
| Logical OR (`||`)       | 15         | Left-to-Right | 2     | `a || b`     | Logical OR operation                                 |
| Conditional (`?:`)      | 16         | Right-to-Left | 3     | `condition ? a : b` | Conditional expression                            |
| Assignment (`=`)        | 17         | Right-to-Left | 2     | `a = b`      | Assigns value of right to left                       |
| Compound assignment (`+=`, `-=`, etc.)| 17 | Right-to-Left | 2     | `a += b`     | Shorthand for assignment with operation              |
| Comma (`,`)             | 18         | Left-to-Right | 2     | `a, b`      | Separates expressions or function arguments          

### Key Concepts:

- **Precedence**: Determines the order in which operators are evaluated in an expression. Higher precedence operators are evaluated before lower precedence operators.
- **Associativity**: Determines the order in which operators of the same precedence level are evaluated. Most operators are left-to-right, but some (e.g., assignment) are right-to-left.
- **Arity**: Refers to the number of operands an operator takes. Operators can be unary (1 operand), binary (2 operands), or ternary (3 operands, e.g., the conditional operator `?:`).

### Overlap and Ambiguities

- **Overlapping Precedence**: Operators with the same precedence level are evaluated based on their associativity. For example, both `*` and `/` have the same precedence and are evaluated left-to-right.
- **Complex Expressions**: Parentheses `()` can be used to explicitly define the order of evaluation and avoid ambiguities in complex expressions.

### Example:

```cpp
int a = 5;
int b = 3;
int c = 2;
int result = a + b * c;  // Multiplication (*) has higher precedence than addition (+)
```

Here, `b * c` is evaluated first, then the result is added to `a`.

