## Relational Operators


Relational operators compare two values and return either 1 (true) or 0 (false):

- `<` (less than): Returns 1 if left operand is smaller
- `<=` (less than or equal): Returns 1 if left operand is smaller or equal
- `>` (greater than): Returns 1 if left operand is larger
- `>=` (greater than or equal): Returns 1 if left operand is larger or equal
- `==` (equal to): Returns 1 if both operands are equal
- `!=` (not equal to): Returns 1 if operands are different

**Key Points:**

- All relational operators have lower precedence than arithmetic operators
- Chaining comparisons like `a < b < c` doesn't work as expected in C
- Floating-point comparisons should account for precision issues

**Example:**

```c
int x = 5, y = 10;
printf("%d\n", x < y);     // Output: 1 (true)
printf("%d\n", x == y);    // Output: 0 (false)
printf("%d\n", x != y);    // Output: 1 (true)
```

