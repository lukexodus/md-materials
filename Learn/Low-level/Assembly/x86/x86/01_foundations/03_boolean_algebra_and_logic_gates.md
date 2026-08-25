## Boolean Algebra and Logic Gates


### Boolean Operations

Boolean algebra operates on binary values (0 = false, 1 = true) using logical operations.

**AND Operation:** Output is 1 only when both inputs are 1.

Truth table:

```
A | B | A AND B
0 | 0 |    0
0 | 1 |    0
1 | 0 |    0
1 | 1 |    1
```

**OR Operation:** Output is 1 when at least one input is 1.

Truth table:

```
A | B | A OR B
0 | 0 |   0
0 | 1 |   1
1 | 0 |   1
1 | 1 |   1
```

**NOT Operation:** Output is the inverse of the input.

Truth table:

```
A | NOT A
0 |   1
1 |   0
```

**XOR (Exclusive OR):** Output is 1 when inputs are different.

Truth table:

```
A | B | A XOR B
0 | 0 |    0
0 | 1 |    1
1 | 0 |    1
1 | 1 |    0
```

**NAND (NOT AND):** Output is 0 only when both inputs are 1.

Truth table:

```
A | B | A NAND B
0 | 0 |     1
0 | 1 |     1
1 | 0 |     1
1 | 1 |     0
```

**NOR (NOT OR):** Output is 1 only when both inputs are 0.

Truth table:

```
A | B | A NOR B
0 | 0 |    1
0 | 1 |    0
1 | 0 |    0
1 | 1 |    0
```

### Boolean Algebra Laws

**Identity Laws:**

- A AND 1 = A
- A OR 0 = A

**Null Laws:**

- A AND 0 = 0
- A OR 1 = 1

**Idempotent Laws:**

- A AND A = A
- A OR A = A

**Complement Laws:**

- A AND NOT A = 0
- A OR NOT A = 1
- NOT (NOT A) = A

**Commutative Laws:**

- A AND B = B AND A
- A OR B = B OR A

**Associative Laws:**

- (A AND B) AND C = A AND (B AND C)
- (A OR B) OR C = A OR (B OR C)



**Distributive Laws:**

- A AND (B OR C) = (A AND B) OR (A AND C)
- A OR (B AND C) = (A OR B) AND (A OR C)

**De Morgan's Laws:**

- NOT (A AND B) = NOT A OR NOT B
- NOT (A OR B) = NOT A AND NOT B

### Bitwise Operations in x86

x86 assembly provides instructions for bitwise operations on integer data:

**AND:** Used for masking bits (clearing specific bits while preserving others).

**Example:**

```
10110101 AND 00001111 = 00000101
```

This masks the upper 4 bits, keeping only the lower 4 bits.

**OR:** Used for setting specific bits to 1.

**Example:**

```
10110101 OR 00001111 = 10111111
```

This sets the lower 4 bits to 1.

**XOR:** Used for toggling bits or comparing values. XORing a value with itself produces 0.

**Example:**

```
10110101 XOR 11110000 = 01000101
```

**NOT:** Inverts all bits.

**Example:**

```
NOT 10110101 = 01001010
```

### Logic Gates

Logic gates are physical implementations of Boolean operations in digital circuits.

**AND Gate:** Implements AND operation. Both inputs must be high for output to be high.

**OR Gate:** Implements OR operation. At least one input must be high for output to be high.

**NOT Gate (Inverter):** Implements NOT operation. Inverts the input signal.

**XOR Gate:** Implements XOR operation. Output is high when inputs differ.

**NAND Gate:** Universal gate that can implement any Boolean function. Output is low only when both inputs are high.

**NOR Gate:** Universal gate. Output is high only when both inputs are low.

### Applications in Computing

**Bit Manipulation:** Boolean operations are fundamental for:

- Setting specific bits (OR with mask)
- Clearing specific bits (AND with inverted mask)
- Toggling bits (XOR with mask)
- Testing bits (AND with mask, check result)

**Example:** To set bit 3 (counting from 0) in a byte:

```
Original: 10100101
Mask:     00001000
OR:       10101101
```

To clear bit 5:

```
Original: 10100101
Mask:     11011111 (inverted from 00100000)
AND:      10000101
```

