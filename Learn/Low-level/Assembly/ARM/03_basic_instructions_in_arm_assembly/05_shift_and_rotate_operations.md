## Shift and Rotate Operations


Shift and rotate operations manipulate bit patterns within registers, enabling efficient multiplication/division by powers of 2, bit field extraction, and data packing operations.

### Logical Shift Left (LSL)

Logical Shift Left shifts bits toward the most significant bit position, filling vacated least significant bits with zeros. Bits shifted out from the MSB are discarded (or captured in the carry flag).

```
LSL r0, r1, #3        @ r0 = r1 << 3
```

**Example**
```
Initial:  r1 = 0b00010110 (22 decimal)
LSL #2:   r0 = 0b01011000 (88 decimal)
```

Each left shift by one position multiplies the value by 2. Shifting left by n positions multiplies by 2^n, providing efficient multiplication when the multiplier is a power of 2.

Overflow occurs when significant bits are shifted out. For unsigned values, this means the result exceeds the register size. For signed values, the sign bit may be lost, changing the number's sign unexpectedly.

### Logical Shift Right (LSR)

Logical Shift Right shifts bits toward the least significant bit position, filling vacated most significant bits with zeros. This operation is appropriate for unsigned values.

```
LSR r0, r1, #2        @ r0 = r1 >> 2 (logical)
```

**Example**
```
Initial:  r1 = 0b10110100 (180 decimal unsigned)
LSR #2:   r0 = 0b00101101 (45 decimal)
```

Each right shift by one position divides unsigned values by 2 (rounding toward zero). Shifting right by n positions divides by 2^n.

For signed negative values, LSR produces incorrect results because it fills with zeros rather than preserving the sign bit.

### Arithmetic Shift Right (ASR)

Arithmetic Shift Right shifts bits rightward while replicating the sign bit into vacated positions. This operation correctly divides signed two's complement values by powers of 2.

```
ASR r0, r1, #2        @ r0 = r1 >> 2 (arithmetic)
```

**Example** with negative value:
```
Initial:  r1 = 0b11110100 (-12 decimal in 8-bit)
ASR #2:   r0 = 0b11111101 (-3 decimal)
```

**Example** with positive value:
```
Initial:  r1 = 0b00110100 (52 decimal)
ASR #2:   r0 = 0b00001101 (13 decimal)
```

Sign extension during the shift maintains the correct sign of the result. ASR rounds toward negative infinity for negative numbers, which differs slightly from C language division that rounds toward zero.

### Rotate Right (ROR)

Rotate Right shifts bits rightward with bits shifted out from the LSB position re-entering at the MSB position. No information is lost—the operation is reversible.

```
ROR r0, r1, #4        @ r0 = r1 rotated right by 4
```

**Example**
```
Initial:     r1 = 0b10110011
ROR #3:      r0 = 0b01110110
                        ^^^--- these bits wrapped around
```

Rotation has no direct arithmetic interpretation but is useful for:
- Circular bit manipulation
- Cryptographic operations
- Extracting bit fields that wrap around word boundaries

### Rotate Right Extended (RRX)

Rotate Right Extended performs a 33-bit rotation through the carry flag. The carry flag becomes the new MSB, and the LSB shifts into the carry flag. This always rotates by exactly one bit position.

```
RRX r0, r1           @ r0 = (C:r1) >> 1, C = r1[0]
```

**Example** with carry = 1:
```
Carry: 1
Initial:     r1 = 0b10110011
RRX:         r0 = 0b11011001
             Carry = 1 (from LSB of r1)
```

RRX is useful for multi-word shifts where the carry propagates between words, and for implementing efficient division algorithms.

### Flexible Second Operand

ARM instructions often incorporate shifts into operand processing without requiring separate shift instructions. The second operand can include an inline shift operation.

```
ADD r0, r1, r2, LSL #2    @ r0 = r1 + (r2 << 2)
SUB r0, r1, r2, ASR #4    @ r0 = r1 - (r2 >> 4)
MOV r0, r1, ROR #8        @ r0 = r1 rotated right by 8
```

The shift amount can be specified as:
- Immediate constant (0-31 for 32-bit, 0-63 for 64-bit)
- Register value (bottom byte only)

```
ADD r0, r1, r2, LSL r3    @ r0 = r1 + (r2 << r3[7:0])
```

This flexible operand mechanism reduces instruction count by combining operations. [Inference] It exploits the barrel shifter hardware in ARM processors that can perform shifts in the same cycle as ALU operations.

### Barrel Shifter Integration

ARM's barrel shifter is hardware that performs shift operations in parallel with other operations. When a shift is specified as part of another instruction's operand, [Inference] the shift occurs without consuming additional execution time in most cases.

This architectural feature makes shifted operands essentially free, encouraging their use for:
- Array indexing: `LDR r0, [r1, r2, LSL #2]` loads from r1 + r2×4
- Efficient multiplication by constants: `ADD r0, r1, r1, LSL #2` computes r1×5
- Bit field manipulation

### Practical Applications

**Multiplication by constants**: Multiplying by 10 can be decomposed as (x × 8) + (x × 2):
```
ADD r0, r1, r1, LSL #3    @ r0 = r1 + (r1 × 8) = r1 × 9
```

Or more efficiently:
```
ADD r0, r1, r1, LSL #2    @ r0 = r1 + (r1 × 4) = r1 × 5
LSL r0, r0, #1            @ r0 = (r1 × 5) × 2 = r1 × 10
```

**Array indexing**: Accessing element i in a 4-byte word array at base address in r1:
```
LDR r0, [r1, r2, LSL #2]  @ Load array[r2] where each element is 4 bytes
```

**Bit field extraction**: Extracting bits [7:4] from a register:
```
LSR r0, r1, #4            @ Shift right to position bit 4 at bit 0
AND r0, r0, #0xF          @ Mask to keep only lower 4 bits
```

**Flag packing**: Combining multiple boolean flags into a single byte:
```
ORR r0, r0, r1, LSL #0    @ Pack flag1 (r1) at bit 0
ORR r0, r0, r2, LSL #1    @ Pack flag2 (r2) at bit 1
ORR r0, r0, r3, LSL #2    @ Pack flag3 (r3) at bit 2
```

