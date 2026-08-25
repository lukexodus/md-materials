## Comparison Instructions


Comparison instructions evaluate conditions by performing operations and updating status flags without storing results. These flags control conditional execution and branching.

### Status Flags (CPSR/APSR)

The Current Program Status Register (CPSR) in ARMv7, or Application Program Status Register (APSR) in ARMv8, contains condition flags in the upper bits:

**N (Negative)**: Set when the result's most significant bit is 1, indicating a negative value in two's complement representation.

**Z (Zero)**: Set when the result equals zero, with all bits zero.

**C (Carry)**: Set when an unsigned operation produces a carry out or requires a borrow. For addition, set when the result exceeds the register size. For subtraction, set when no borrow is required (first operand ≥ second operand).

**V (Overflow)**: Set when a signed operation produces a result outside the representable range. Occurs when adding two positive numbers yields a negative result, or adding two negative numbers yields a positive result.

These flags enable conditional operations without explicit branching, supporting efficient condition evaluation.

### CMP - Compare

CMP performs subtraction (first operand minus second operand) and updates flags without storing the result. It is equivalent to SUBS but discards the result, keeping only the flag updates.

```
CMP r0, r1            @ Set flags based on (r0 - r1)
CMP r0, #100          @ Set flags based on (r0 - 100)
```

**Example**: Comparing r0 = 5 and r1 = 3:
```
CMP r0, r1            @ Computes 5 - 3 = 2
```
Result flags: N=0 (positive), Z=0 (non-zero), C=1 (no borrow needed), V=0 (no overflow)

**Example**: Comparing r0 = 3 and r1 = 5:
```
CMP r0, r1            @ Computes 3 - 5 = -2
```
Result flags: N=1 (negative), Z=0 (non-zero), C=0 (borrow needed), V=0 (no overflow)

**Example**: Comparing r0 = 7 and r1 = 7:
```
CMP r0, r1            @ Computes 7 - 7 = 0
```
Result flags: N=0, Z=1 (zero), C=1 (no borrow), V=0

### CMN - Compare Negative

CMN performs addition (first operand plus second operand) and updates flags without storing the result. It is equivalent to ADDS but discards the result. CMN is useful for comparing against negative values without explicitly negating.

```
CMN r0, r1            @ Set flags based on (r0 + r1)
CMN r0, #-10          @ Effectively compares r0 with 10
```

Comparing r0 with -5 can be done as `CMN r0, #5` instead of `CMP r0, #-5`, which may be more efficient depending on immediate value encoding.

### TST - Test Bits

TST performs bitwise AND and updates flags without storing the result. It is equivalent to ANDS but discards the result. TST checks whether specific bits are set.

```
TST r0, r1            @ Set flags based on (r0 AND r1)
TST r0, #0x80         @ Test if bit 7 is set
```

Common uses:
- Testing if a specific bit is set: `TST r0, #(1<<5)` tests bit 5
- Checking if value is zero: `TST r0, r0`
- Testing multiple bits: `TST r0, #0x0F` checks if any of lower 4 bits are set

**Example**: r0 = 0b10110100, testing bit 7:
```
TST r0, #0x80         @ AND with 0b10000000
```
Result flags: N=1 (bit 31 of result in 32-bit), Z=0 (non-zero result)

**Example**: r0 = 0b01110100, testing bit 7:
```
TST r0, #0x80         @ AND with 0b10000000
```
Result flags: N=0, Z=1 (zero result, bit 7 not set)

### TEQ - Test Equivalence

TEQ performs bitwise XOR and updates flags without storing the result. It is equivalent to EORS but discards the result. TEQ checks whether values are equal or identifies differing bits.

```
TEQ r0, r1            @ Set flags based on (r0 XOR r1)
```

If r0 equals r1, the XOR result is zero and the Z flag sets. If they differ, the Z flag clears and the result shows which bits differ.

**Example**: Comparing r0 = 0b10110100 and r1 = 0b10110100:
```
TEQ r0, r1            @ XOR produces 0b00000000
```
Result flags: Z=1 (values are equal)

**Example**: Comparing r0 = 0b10110100 and r1 = 0b10010110:
```
TEQ r0, r1            @ XOR produces 0b00100010
```
Result flags: Z=0 (values differ), with differing bits shown in result

TEQ can efficiently check equality without affecting the carry flag, unlike CMP.

### Conditional Execution Suffixes

ARM supports conditional execution where instructions execute only when specified conditions are true based on current flags. Each instruction can include a two-letter condition suffix.

Condition codes:
- **EQ** (Equal): Z=1
- **NE** (Not Equal): Z=0
- **CS/HS** (Carry Set/Unsigned Higher or Same): C=1
- **CC/LO** (Carry Clear/Unsigned Lower): C=0
- **MI** (Minus/Negative): N=1
- **PL** (Plus/Positive or Zero): N=0
- **VS** (Overflow Set): V=1
- **VC** (Overflow Clear): V=0
- **HI** (Unsigned Higher): C=1 and Z=0
- **LS** (Unsigned Lower or Same): C=0 or Z=1
- **GE** (Signed Greater or Equal): N=V
- **LT** (Signed Less Than): N≠V
- **GT** (Signed Greater Than): Z=0 and N=V
- **LE** (Signed Less or Equal): Z=1 or N≠V
- **AL** (Always): unconditional (default)

**Example** conditional execution:
```
CMP r0, #10
ADDGT r1, r1, #1      @ Execute only if r0 > 10 (signed)
MOVLE r1, #0          @ Execute only if r0 <= 10 (signed)
```

**Example** avoiding branches:
```
CMP r0, r1
MOVGT r2, r0          @ r2 = r0 if r0 > r1
MOVLE r2, r1          @ r2 = r1 if r0 <= r1
@ r2 now contains max(r0, r1)
```

[Inference] Conditional execution reduces branch instructions, improving performance on pipelined processors by avoiding pipeline flushes. However, ARMv8 AArch64 mode removed most conditional execution, retaining only conditional branches and select operations.

### Signed vs Unsigned Comparisons

Signed and unsigned comparisons require different condition codes because the flag interpretations differ.

**Unsigned comparison** uses carry flag:
```
CMP r0, r1
BHI label             @ Branch if r0 > r1 (unsigned)
BLS label             @ Branch if r0 <= r1 (unsigned)
```

**Signed comparison** uses negative and overflow flags:
```
CMP r0, r1
BGT label             @ Branch if r0 > r1 (signed)
BLE label             @ Branch if r0 <= r1 (signed)
```

**Example** where signed/unsigned matters: r0 = 0xFFFFFFFF, r1 = 0x00000001
- Unsigned: r0 (4,294,967,295) > r1 (1), so HI condition is true
- Signed: r0 (-1) < r1 (1), so LT condition is true

Using the wrong condition code for the data type produces incorrect comparisons.

### Flag-Setting Variants

Most ALU instructions have two forms: one that updates flags (with 'S' suffix) and one that does not.

```
ADD r0, r1, r2        @ r0 = r1 + r2, flags unchanged
ADDS r0, r1, r2       @ r0 = r1 + r2, update N,Z,C,V flags

SUB r0, r1, r2        @ r0 = r1 - r2, flags unchanged
SUBS r0, r1, r2       @ r0 = r1 - r2, update flags
```

CMP, CMN, TST, and TEQ implicitly set flags, as they exist specifically for condition evaluation. In ARMv8 AArch64, the 'S' suffix is explicit in the mnemonic (ADDS, SUBS) rather than optional.

