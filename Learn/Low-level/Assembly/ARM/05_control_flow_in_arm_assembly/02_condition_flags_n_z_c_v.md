## Condition Flags (N, Z, C, V)


The ARM processor maintains condition flags in the Current Program Status Register (CPSR). These flags reflect properties of the most recent flag-updating operation and control conditional execution.

### Flag Register Organization

The CPSR contains four condition flags in bits 31-28: N (Negative) in bit 31, Z (Zero) in bit 30, C (Carry) in bit 29, and V (Overflow) in bit 28. Instructions with the 'S' suffix or comparison instructions update these flags based on operation results.

### N Flag - Negative

The N flag reflects the sign bit (bit 31) of the result. It is set (1) when the result is negative in two's complement representation, clear (0) when positive or zero. This flag enables signed comparison conditions.

**Setting Conditions**

Any flag-updating instruction sets N if the result's most significant bit is 1. For 32-bit operations, this means bit 31. Arithmetic operations set N based on the actual sign of the mathematical result, while logical operations set N based on the output pattern.

**Usage in Comparisons**

Signed comparison conditions (LT, LE, GT, GE) examine the N flag in combination with V to determine relative magnitude. After a subtraction or comparison, N indicates whether the first operand is less than the second (considering signed values).

### Z Flag - Zero

The Z flag indicates whether the result of an operation is zero. It is set (1) when all result bits are 0, clear (0) otherwise. This flag is fundamental to equality testing and loop termination.

**Equality Testing**

Comparison instructions subtract operands and set flags without storing the result. If the operands are equal, the subtraction yields zero, setting the Z flag. EQ condition tests Z set, NE tests Z clear, enabling equality-based conditional execution.

**Loop Control**

Decrement-and-test patterns use Z flag for loop termination. `SUBS r0, r0, #1` decrements a counter and sets flags; branching with BNE (branch if not equal, Z clear) continues the loop until the counter reaches zero.

**Example:**

```assembly
SUBS r0, r0, #1         @ Decrement and set flags
BNE loop_start          @ Branch if r0 != 0 (Z clear)
```

### C Flag - Carry

The C flag indicates unsigned overflow in arithmetic operations and bit shift outcomes. Its meaning varies by operation type: addition sets C on unsigned overflow, subtraction sets C when no borrow occurs (inverted borrow), and shifts set C to the last bit shifted out.

**Addition Carry**

ADD and ADC set C when the unsigned sum exceeds 32 bits. For example, adding 0xFFFFFFFF and 0x00000001 produces 0x00000000 with C set, indicating the true result is 0x100000000. This enables multi-precision arithmetic by propagating carry between word additions.

**Subtraction Borrow**

SUB and SBC set C when no borrow is needed: C is set (1) when first operand >= second operand unsigned, clear (0) when borrow occurs. This inverted logic matches ARM's subtract-with-carry implementation where SBC subtracts NOT(C) rather than C itself. After SUB, C set means no underflow occurred.

**Shift Operations**

Shift instructions (LSL, LSR, ASR, ROR) set C to the last bit shifted out of the register. Left shift sets C to the bit shifted out of bit 31, right shift sets C to the bit shifted out of bit 0. This allows recovering lost bits and enables extended precision shifts.

**Unsigned Comparisons**

Unsigned comparison conditions (HI, HS/CS, LO/CC, LS) test C and Z flags. After CMP (which performs subtraction), C set means first operand >= second operand unsigned. HI (higher) tests C set AND Z clear, HS (higher or same) tests C set, LO (lower) tests C clear, LS (lower or same) tests C clear OR Z set.

**Example:**

```assembly
@ Multi-precision addition: {r1,r0} = {r1,r0} + {r3,r2}
ADDS r0, r0, r2         @ Add lower words, set C if overflow
ADC r1, r1, r3          @ Add upper words plus carry

@ Unsigned comparison
CMP r4, r5              @ Compare r4 and r5
BHI higher              @ Branch if r4 > r5 (unsigned)
BLO lower               @ Branch if r4 < r5 (unsigned)
```

### V Flag - Overflow

The V flag indicates signed overflow: when an arithmetic operation produces a result that cannot be represented in two's complement format. Overflow occurs when adding two positive numbers yields a negative result, or adding two negative numbers yields a positive result.

**Signed Overflow Detection**

Addition sets V when operands have the same sign but the result has opposite sign. Subtracting a negative from a positive yielding negative, or a positive from a negative yielding positive, also sets V. The flag enables detection of results that exceed the representable range of -2,147,483,648 to 2,147,483,647 for 32-bit signed integers.

**Mathematical Conditions**

V is set in these cases: (positive + positive = negative), (negative + negative = positive), (positive - negative = negative), (negative - positive = positive). In all cases, the mathematical result exceeds the representable range, and the actual stored value wraps around through two's complement arithmetic.

**Signed Comparisons**

Signed comparison conditions (GT, GE, LT, LE) test N and V together. After subtraction, N indicates the sign of the result, but overflow can invert this. The condition N equals V means greater-or-equal (no overflow, or overflow from both directions), N not-equal-to V means less-than.

**Example:**

```assembly
@ Signed overflow example
MOV r0, #0x7FFFFFFF     @ r0 = 2,147,483,647 (max positive)
ADDS r0, r0, #1         @ r0 = 0x80000000 (wraps to -2,147,483,648)
                        @ V flag set: signed overflow occurred
                        @ N flag set: result is negative
                        @ C flag clear: no unsigned overflow

@ Signed comparison using V
CMP r1, r2              @ Compare r1 and r2
BGT signed_greater      @ Branch if r1 > r2 (signed, tests N == V and Z clear)
BLT signed_less         @ Branch if r1 < r2 (signed, tests N != V)
```

### Flag-Setting Instructions

Instructions update flags only when specified. Data processing instructions require 'S' suffix: ADDS, SUBS, ANDS. Comparison and test instructions always set flags: CMP, CMN, TST, TEQ. Memory access instructions (LDR, STR) never affect flags. Multiplication instructions can update flags with 'S' suffix, though flag values for multiplication have [Inference: implementation-defined behavior for some flag bits on certain architectures].

**Explicit Comparisons**

CMP (compare) performs subtraction without storing the result, only updating flags. `CMP rn, operand2` computes rn - operand2, setting flags for conditional branches or predicated instructions. CMN (compare negative) adds operands: rn + operand2, testing equality to negative values.

**Bit Testing**

TST (test) performs bitwise AND without storing results, only setting flags. `TST rn, operand2` computes rn AND operand2, with Z set if result is zero (no common bits set). TEQ (test equivalence) performs XOR similarly, with Z set if operands are equal (XOR yields zero).

**Example:**

```assembly
CMP r0, #100            @ Compare r0 with 100
CMN r1, #5              @ Compare r1 with -5 (test r1 + 5)
TST r2, #0x01           @ Test if bit 0 is set
TEQ r3, r4              @ Test if r3 equals r4
```

