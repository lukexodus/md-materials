## Logical Instructions


Logical instructions perform bitwise boolean operations on register values. These operations manipulate individual bits for masking, testing, combining, and inverting data.

### AND - Bitwise AND

AND performs bitwise conjunction of two operands, setting result bits to 1 only where both input bits are 1. This operation is used for masking, clearing bits, and testing bit patterns.

**Bit Masking**

AND with a mask immediate or register isolates specific bits by clearing all others. For example, `AND r0, r1, #0xFF` extracts the lower 8 bits of r1, zeroing the upper 24 bits. Complex masks can be applied using register operands.

**Testing Bits**

TST (test) performs AND without storing the result, only updating flags. `TST r0, #0x10` sets the Z flag if bit 4 of r0 is clear, enabling conditional branches based on bit values. TST is equivalent to ANDS with a discarded result.

**Example:**

```assembly
AND r0, r1, r2           @ r0 = r1 & r2
AND r3, r3, #0x0F        @ r3 = r3 & 0x0F (mask lower 4 bits)
ANDS r4, r5, r6          @ r4 = r5 & r6, update flags
TST r7, #0x80            @ Test bit 7, set flags
AND r8, r9, r10, LSL #2  @ r8 = r9 & (r10 << 2)
```

### ORR - Bitwise OR

ORR (or OR) performs bitwise disjunction, setting result bits to 1 where either input bit is 1. This operation combines bit patterns and sets specific bits without affecting others.

**Setting Bits**

ORR with a mask sets specific bits in a register while preserving others. `ORR r0, r0, #0x80` sets bit 7 without changing bits 0-6 or 8-31. Multiple bits can be set in a single operation using appropriate masks.

**Combining Values**

ORR combines separate bit fields into a single value. After isolating different fields in separate registers, ORR merges them: upper bits from one register OR'd with lower bits from another produce a combined result.

**Example:**

```assembly
ORR r0, r1, r2           @ r0 = r1 | r2
ORR r3, r3, #0x100       @ r3 = r3 | 0x100 (set bit 8)
ORRS r4, r5, r6          @ r4 = r5 | r6, update flags
ORR r7, r8, r9, LSR #4   @ r7 = r8 | (r9 >> 4)
```

### EOR - Bitwise Exclusive OR

EOR (exclusive OR or XOR) sets result bits to 1 where input bits differ. This operation toggles bits, detects differences, and performs bit swapping.

**Toggling Bits**

EOR with a mask flips specific bits: `EOR r0, r0, #0x40` toggles bit 6, changing 0 to 1 or 1 to 0. Repeated EOR with the same mask returns the original value, providing reversible bit manipulation.

**Zeroing Registers**

EOR of a register with itself produces zero: `EOR r0, r0, r0` clears r0. This may be more efficient than `MOV r0, #0` on some microarchitectures, though both achieve the same result.

**Comparison Detection**

EOR detects differences between values. After `EOR r0, r1, r2`, bits set in r0 indicate positions where r1 and r2 differ. Testing if the result is zero (using flags) determines if two values are identical.

**Example:**

```assembly
EOR r0, r1, r2           @ r0 = r1 ^ r2
EOR r3, r3, #0x01        @ r3 = r3 ^ 0x01 (toggle bit 0)
EORS r4, r5, r6          @ r4 = r5 ^ r6, update flags
EOR r7, r7, r7           @ r7 = 0 (register cleared)
```

### BIC - Bit Clear

BIC (bit clear) clears bits in the first operand where corresponding bits in the second operand are 1. It performs AND with the complement of the second operand: rd = rn AND NOT(operand2).

**Clearing Specific Bits**

BIC selectively clears bits indicated by a mask. `BIC r0, r0, #0x0F` clears the lower 4 bits while preserving all others. Unlike AND with an inverted mask, BIC simplifies bit clearing with direct mask specification.

**Alignment Operations**

BIC is commonly used for address alignment. `BIC r0, r0, #3` clears the lower 2 bits, aligning r0 to a 4-byte boundary by rounding down to the nearest multiple of 4.

**Example:**

```assembly
BIC r0, r1, r2           @ r0 = r1 & ~r2
BIC r3, r3, #0x07        @ r3 = r3 & ~0x07 (clear lower 3 bits)
BICS r4, r5, r6          @ r4 = r5 & ~r6, update flags
BIC sp, sp, #7           @ Align stack pointer to 8 bytes
```

### MVN - Move NOT

MVN moves the bitwise complement of the source operand to the destination. It performs NOT operation, inverting all bits: 0 becomes 1 and 1 becomes 0.

**Bitwise Negation**

MVN provides efficient bit inversion. `MVN r0, r1` stores the inverted value of r1 in r0. This is particularly useful for generating inverted constants when the positive value is not encodable but the negative is.

**Generating Constants**

MVN enables loading immediates that cannot be encoded directly in MOV. For example, if 0xFFFFFFFE is not encodable but 1 is, `MVN r0, #1` loads 0xFFFFFFFE. The assembler may automatically substitute MVN when MOV with a particular immediate is requested but not encodable.

**Example:**

```assembly
MVN r0, r1               @ r0 = ~r1
MVN r2, #0               @ r2 = 0xFFFFFFFF (all bits set)
MVNS r3, r4              @ r3 = ~r4, update flags
MVN r5, r6, LSL #2       @ r5 = ~(r6 << 2)
```

**Key Points:**

- MOV copies values between registers or loads immediates with encoding restrictions requiring MOVW/MOVT for arbitrary 32-bit values
- LDR and STR support multiple addressing modes (offset, pre-indexed, post-indexed) with size variants for bytes, halfwords, and words
- Immediate values in ARM32 instructions are limited to rotated 8-bit patterns; larger constants require literal pools or multiple instructions
- Arithmetic instructions include ADD/SUB for basic operations, ADC/SBC for multi-precision, and MUL variants for different multiplication types
- Division instructions (SDIV/UDIV) are only available on ARMv7-R, ARMv7-M with divide extensions, and ARMv8-A architectures [Inference: requiring software emulation on earlier cores]
- Logical operations (AND, ORR, EOR, BIC, MVN) manipulate individual bits for masking, combining, toggling, and clearing
- Instructions with 'S' suffix update condition flags based on operation results, enabling conditional execution and overflow detection
- Shifted register operands (LSL, LSR, ASR, ROR) extend instruction capabilities by preprocessing values before arithmetic or logical operations

**Important related topics:** Condition flags and conditional execution, barrel shifter operation details, multi-precision arithmetic implementation, memory alignment requirements and unaligned access handling, literal pool management and placement strategies, Thumb and Thumb-2 instruction encoding differences.

---

