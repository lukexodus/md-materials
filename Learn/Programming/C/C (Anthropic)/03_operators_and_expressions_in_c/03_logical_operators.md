## Logical Operators


Logical operators perform boolean operations and support short-circuit evaluation:

- `&&` (logical AND): Returns 1 if both operands are non-zero
- `||` (logical OR): Returns 1 if at least one operand is non-zero
- `!` (logical NOT): Returns 1 if operand is zero, 0 if operand is non-zero

**Short-Circuit Evaluation:**

- `&&`: If first operand is false, second operand is not evaluated
- `||`: If first operand is true, second operand is not evaluated

**Key Points:**

- Any non-zero value is considered true in logical context
- Logical operators always return either 0 or 1
- Short-circuiting can be used for conditional execution

**Example:**

```c
int a = 5, b = 0, c = 10;
printf("%d\n", a && b);    // Output: 0 (false)
printf("%d\n", a || b);    // Output: 1 (true)
printf("%d\n", !a);        // Output: 0 (false)

// Short-circuit example
if (b != 0 && a/b > 2) {   // Division won't occur if b is 0
    printf("Safe division\n");
}
```

