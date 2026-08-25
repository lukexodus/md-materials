## Arithmetic Instructions


Arithmetic instructions perform mathematical operations on integer values. Results are stored in destination registers, and optional status flags indicate properties like overflow, carry, and sign.

### ADD - Addition

ADD sums two operands and stores the result in a destination register. The instruction supports register, immediate, and shifted register operands as the second source.

**Basic Addition**

The basic form adds two registers or a register and immediate value: `ADD rd, rn, operand2` computes rd = rn + operand2. The destination can be the same as one of the sources for accumulation operations.

**Flag Updates**

The 'S' suffix (ADDS) updates condition flags based on the result. The N (negative) flag is set if the result is negative (bit 31 = 1), Z (zero) if result is zero, C (carry) if unsigned overflow occurred, and V (overflow) if signed overflow occurred. These flags enable conditional execution and overflow detection.

**Add with Carry**

ADC (add with carry) includes the carry flag in the addition, useful for multi-precision arithmetic. When adding two 64-bit numbers stored in register pairs, ADD handles the lower 32 bits and ADC adds the upper 32 bits plus any carry from the lower addition.

**Example:**

```assembly
ADD r0, r1, r2           @ r0 = r1 + r2
ADD r3, r3, #1           @ r3 = r3 + 1 (increment)
ADDS r4, r5, r6          @ r4 = r5 + r6, update flags
ADD r7, r8, r9, LSL #3   @ r7 = r8 + (r9 * 8)
ADC r10, r11, r12        @ r10 = r11 + r12 + carry
```

### SUB - Subtraction

SUB subtracts the second operand from the first and stores the result. It provides the complement to ADD and supports the same operand types.

**Basic Subtraction**

The syntax `SUB rd, rn, operand2` computes rd = rn - operand2. Like ADD, the destination can alias a source register for in-place modification.

**Reverse Subtraction**

RSB (reverse subtract) computes rd = operand2 - rn, swapping the operand order. This is useful when the minuend is an immediate or shifted register rather than the base register. RSB enables negation: `RSB r0, r0, #0` computes r0 = 0 - r0 = -r0.

**Subtract with Carry**

SBC (subtract with carry) performs rd = rn - operand2 - NOT(carry), implementing borrow for multi-precision subtraction. The inverted carry flag represents borrow: if carry is clear (0), one is subtracted; if carry is set (1), nothing extra is subtracted.

**Example:**

```assembly
SUB r0, r1, r2           @ r0 = r1 - r2
SUB r3, r3, #5           @ r3 = r3 - 5 (decrement)
SUBS r4, r5, r6          @ r4 = r5 - r6, update flags
RSB r7, r8, #100         @ r7 = 100 - r8
SBC r9, r10, r11         @ r9 = r10 - r11 - borrow
RSB r12, r12, #0         @ r12 = -r12 (negation)
```

### MUL - Multiplication

Multiplication instructions compute the product of two registers. ARM provides several multiplication variants for different result sizes and accumulation patterns.

**Basic Multiplication**

MUL multiplies two 32-bit registers and stores the lower 32 bits of the 64-bit product. The syntax `MUL rd, rn, rm` computes rd = rn * rm, discarding the upper 32 bits. This is sufficient when the product fits in 32 bits or only the lower bits are needed.

**Multiply-Accumulate**

MLA (multiply-accumulate) adds a third operand to the product: `MLA rd, rn, rm, ra` computes rd = (rn * rm) + ra. This single instruction replaces separate multiply and add operations, commonly used in digital signal processing and matrix operations.

**Long Multiplication**

UMULL (unsigned multiply long) and SMULL (signed multiply long) produce full 64-bit results from 32-bit operands. The syntax `UMULL rdlo, rdhi, rn, rm` stores the lower 32 bits in rdlo and upper 32 bits in rdhi, with rdlo and rdhi being consecutive or separate registers.

**Long Multiply-Accumulate**

UMLAL and SMLAL accumulate into a 64-bit destination: `UMLAL rdlo, rdhi, rn, rm` computes {rdhi, rdlo} = {rdhi, rdlo} + (rn * rm), useful for accumulating multiple products without overflow.

**Example:**

```assembly
MUL r0, r1, r2           @ r0 = r1 * r2 (lower 32 bits)
MLA r3, r4, r5, r6       @ r3 = (r4 * r5) + r6
UMULL r7, r8, r9, r10    @ {r8, r7} = r9 * r10 (unsigned 64-bit)
SMULL r11, r12, r13, r14 @ {r12, r11} = r13 * r14 (signed 64-bit)
```

### Division

Integer division support varies by ARM architecture. Earlier ARM cores lack hardware division, requiring software implementation. ARMv7-R and ARMv7-M with divide extensions, and all ARMv8-A cores include SDIV (signed divide) and UDIV (unsigned divide) instructions.

**Hardware Division Instructions**

Where available, SDIV and UDIV divide two registers and store the quotient. The syntax `SDIV rd, rn, rm` computes rd = rn / rm using signed division, truncating toward zero. UDIV performs unsigned division. Division by zero behavior is [Inference: likely sets the result to zero or an unpredictable value, though specific behavior may be implementation-defined].

**Remainder Calculation**

ARM division instructions only produce quotients, not remainders. The remainder must be calculated separately: `MLS rd, quotient, divisor, dividend` computes rd = dividend - (quotient * divisor), providing the modulo result.

**Software Division**

On cores without hardware division, software routines implement division using shifts, subtracts, and comparisons. These routines are typically provided by compiler runtime libraries and are significantly slower than hardware division.

**Example:**

```assembly
@ [Inference: Assuming hardware divide available]
SDIV r0, r1, r2          @ r0 = r1 / r2 (signed quotient)
UDIV r3, r4, r5          @ r3 = r4 / r5 (unsigned quotient)
MLS r6, r0, r2, r1       @ r6 = r1 - (r0 * r2) = remainder
```

