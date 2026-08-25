## Operator Precedence and Associativity


Operator precedence determines the order of evaluation in complex expressions. Higher precedence operators are evaluated first.

**Precedence Levels (highest to lowest):**

1. Postfix operators: `()`, `[]`, `->`, `.`, `++`, `--`
2. Unary operators: `++`, `--`, `+`, `-`, `!`, `~`, `(type)`, `*`, `&`, `sizeof`
3. Multiplicative: `*`, `/`, `%`
4. Additive: `+`, `-`
5. Shift: `<<`, `>>`
6. Relational: `<`, `<=`, `>`, `>=`
7. Equality: `==`, `!=`
8. Bitwise AND: `&`
9. Bitwise XOR: `^`
10. Bitwise OR: `|`
11. Logical AND: `&&`
12. Logical OR: `||`
13. Conditional: `?:`
14. Assignment: `=`, `+=`, `-=`, etc.
15. Comma: `,`

**Associativity Rules:**

- Left-to-right: Most operators (arithmetic, relational, logical)
- Right-to-left: Unary operators, assignment operators, conditional operator

**Key Points:**

- Parentheses can override default precedence
- When operators have equal precedence, associativity determines evaluation order
- Understanding precedence prevents bugs in complex expressions

**Example:**

```c
int result = 2 + 3 * 4;        // Result: 14 (not 20)
int x = 1, y = 2, z = 3;
int a = x = y + z;             // a and x both become 5
int b = ++x * 2;               // x incremented first, then multiplied
```

