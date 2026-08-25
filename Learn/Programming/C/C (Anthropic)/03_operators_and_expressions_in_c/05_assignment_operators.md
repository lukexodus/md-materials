## Assignment Operators


Assignment operators store values in variables and can be combined with other operations:

**Basic Assignment:**

- `=`: Assigns right operand to left operand

**Compound Assignment Operators:**

- `+=`: Add and assign
- `-=`: Subtract and assign
- `*=`: Multiply and assign
- `/=`: Divide and assign
- `%=`: Modulo and assign
- `&=`: Bitwise AND and assign
- `|=`: Bitwise OR and assign
- `^=`: Bitwise XOR and assign
- `<<=`: Left shift and assign
- `>>=`: Right shift and assign

**Key Points:**

- Assignment is right-associative and returns the assigned value
- Compound operators are more concise and potentially more efficient
- Multiple assignments can be chained: `a = b = c = 5;`

**Example:**

```c
int x = 10;
x += 5;    // Equivalent to x = x + 5; (x becomes 15)
x *= 2;    // Equivalent to x = x * 2; (x becomes 30)
x >>= 1;   // Equivalent to x = x >> 1; (x becomes 15)

int a, b, c;
a = b = c = 100;  // All variables assigned 100
```

