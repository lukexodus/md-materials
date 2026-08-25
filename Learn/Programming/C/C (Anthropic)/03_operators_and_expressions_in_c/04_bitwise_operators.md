## Bitwise Operators


Bitwise operators manipulate individual bits of integer operands:

- `&` (bitwise AND): Sets bit if both corresponding bits are 1
- `|` (bitwise OR): Sets bit if at least one corresponding bit is 1
- `^` (bitwise XOR): Sets bit if corresponding bits are different
- `~` (bitwise NOT): Inverts all bits (one's complement)
- `<<` (left shift): Shifts bits left by specified positions
- `>>` (right shift): Shifts bits right by specified positions

**Key Points:**

- Bitwise operators work only with integer types
- Left shift by n positions multiplies by 2^n (for positive numbers)
- Right shift behavior for negative numbers is implementation-defined
- Shift operations with negative or excessive shift counts result in undefined behavior

**Example:**

```c
unsigned int a = 12;  // Binary: 1100
unsigned int b = 10;  // Binary: 1010

printf("%u\n", a & b);   // Output: 8 (Binary: 1000)
printf("%u\n", a | b);   // Output: 14 (Binary: 1110)
printf("%u\n", a ^ b);   // Output: 6 (Binary: 0110)
printf("%u\n", ~a);      // Output: 4294967283 (inverted bits)
printf("%u\n", a << 2);  // Output: 48 (Binary: 110000)
printf("%u\n", a >> 1);  // Output: 6 (Binary: 110)
```

