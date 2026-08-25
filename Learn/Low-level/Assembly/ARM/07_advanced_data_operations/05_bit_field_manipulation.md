## Bit Field Manipulation


Bit field manipulation involves extracting, inserting, and modifying contiguous groups of bits within registers. ARM architectures provide specialized instructions and techniques for efficient bit field operations, essential for hardware register access, data packing, and protocol handling.

### Bit Field Extract Instructions

ARMv6T2 and later architectures include dedicated bit field extract instructions that isolate specific bit ranges from registers in a single operation.

**UBFX - Unsigned Bit Field Extract**

UBFX extracts a bit field from a source register, zero-extends it, and stores the result in a destination register. The syntax `UBFX rd, rn, #lsb, #width` extracts `width` bits starting at bit position `lsb` from register `rn`, placing the zero-extended result in `rd`.

The extracted bits shift to the least significant position in the destination register. Upper bits are filled with zeros. This operation efficiently isolates bit fields without requiring separate mask and shift operations.

**Example:**

```assembly
@ Extract bits 8-15 from r0 (8 bits starting at position 8)
UBFX r1, r0, #8, #8         @ r1 = (r0 >> 8) & 0xFF

@ Extract a 4-bit field at position 12
MOV r0, #0x12345678
UBFX r1, r0, #12, #4        @ r1 = 0x4 (extracts bits 12-15)

@ Extracting RGB components from a 16-bit color (RGB565)
@ Format: RRRRRGGGGGGBBBBB
MOV r0, #0xF800             @ Sample color value
UBFX r1, r0, #11, #5        @ r1 = red (5 bits at position 11)
UBFX r2, r0, #5, #6         @ r2 = green (6 bits at position 5)
UBFX r3, r0, #0, #5         @ r3 = blue (5 bits at position 0)
```

**SBFX - Signed Bit Field Extract**

SBFX operates identically to UBFX but sign-extends the extracted bit field instead of zero-extending. If the most significant bit of the extracted field is 1, upper bits are filled with 1s; if 0, upper bits are filled with 0s. This preserves the sign of two's complement values stored in bit fields.

**Example:**

```assembly
@ Extract signed 8-bit value from bits 8-15
MOV r0, #0x0000FF00         @ Bit field = 0xFF (-1 if signed)
SBFX r1, r0, #8, #8         @ r1 = 0xFFFFFFFF (sign-extended -1)

@ Extract signed 4-bit value
MOV r0, #0x00007000         @ Bit field = 0x7 (positive)
SBFX r1, r0, #12, #4        @ r1 = 0x00000007 (sign-extended +7)

MOV r0, #0x00008000         @ Bit field = 0x8 (-8 in 4-bit two's complement)
SBFX r1, r0, #12, #4        @ r1 = 0xFFFFFFF8 (sign-extended -8)
```

### Bit Field Insert Instructions

Bit field insertion modifies specific bit ranges within a register while preserving surrounding bits.

**BFI - Bit Field Insert**

BFI copies the least significant bits from a source register into a specified bit field of a destination register, leaving other destination bits unchanged. The syntax `BFI rd, rn, #lsb, #width` takes the lower `width` bits from `rn` and inserts them into `rd` starting at position `lsb`.

This instruction enables efficient bit field updates without reading, masking, shifting, and writing back separately. It's particularly useful for modifying hardware control registers or packed data structures.

**Example:**

```assembly
@ Insert 4 bits into position 8-11
MOV r0, #0x12345678         @ Destination value
MOV r1, #0x0000000A         @ Source value (lower 4 bits = 0xA)
BFI r0, r1, #8, #4          @ r0 = 0x12345A78 (bits 8-11 replaced)

@ Update status flags in a packed structure
MOV r0, #0x00000000         @ Empty structure
MOV r1, #3                  @ Status code
BFI r0, r1, #16, #3         @ Insert 3-bit status at position 16
MOV r1, #7                  @ Priority level
BFI r0, r1, #20, #3         @ Insert 3-bit priority at position 20
@ r0 now contains both fields without separate masking

@ Construct RGB565 color value from components
MOV r0, #0                  @ Start with zero
MOV r1, #31                 @ Red component (5 bits, max value)
BFI r0, r1, #11, #5         @ Insert red at bits 11-15
MOV r1, #63                 @ Green component (6 bits, max value)
BFI r0, r1, #5, #6          @ Insert green at bits 5-10
MOV r1, #31                 @ Blue component (5 bits, max value)
BFI r0, r1, #0, #5          @ Insert blue at bits 0-4
@ r0 = 0xFFFF (white in RGB565)
```

**BFC - Bit Field Clear**

BFC clears (sets to zero) a specified bit field within a register. The syntax `BFC rd, #lsb, #width` zeros `width` bits starting at position `lsb` in register `rd`, preserving all other bits.

**Example:**

```assembly
@ Clear bits 8-15
MOV r0, #0xFFFFFFFF         @ All bits set
BFC r0, #8, #8              @ r0 = 0xFFFF00FF (bits 8-15 cleared)

@ Clear status field in packed structure
MOV r0, #0x12345678
BFC r0, #16, #8             @ Clear 8-bit status field at position 16
                            @ r0 = 0x12005678
```

### Traditional Bit Manipulation Techniques

On architectures without dedicated bit field instructions (pre-ARMv6T2), bit manipulation uses combinations of logical operations and shifts.

**Extracting Bit Fields**

Extraction requires shifting the desired field to the least significant position, then masking to isolate it. For unsigned extraction, shift right logically (LSR) then AND with a mask. For signed extraction, shift right arithmetically (ASR) to sign-extend.

**Example:**

```assembly
@ Extract bits 8-15 without UBFX (unsigned)
MOV r0, #0x12345678
LSR r1, r0, #8              @ Shift field to LSB: r1 = 0x00123456
AND r1, r1, #0xFF           @ Mask to isolate: r1 = 0x00000056

@ Extract signed field (bits 8-15) without SBFX
MOV r0, #0x0000FF00         @ Field value is 0xFF
LSL r1, r0, #16             @ Shift field to MSB: r1 = 0xFF000000
ASR r1, r1, #24             @ Arithmetic shift back: r1 = 0xFFFFFFFF (sign-extended)
```

**Inserting Bit Fields**

Insertion requires clearing the target bit field in the destination, preparing the source value by shifting it to the correct position, then combining with OR.

**Example:**

```assembly
@ Insert 4 bits at position 8 without BFI
MOV r0, #0x12345678         @ Destination
BIC r0, r0, #0x0F00         @ Clear bits 8-11: r0 = 0x12345078
MOV r1, #0x0000000A         @ Source value
LSL r1, r1, #8              @ Shift to position: r1 = 0x00000A00
ORR r0, r0, r1              @ Combine: r0 = 0x12345A78
```

### Bit Manipulation Patterns

**Setting Bits**

Individual or multiple bits are set using ORR with appropriate masks. Each set bit in the mask sets the corresponding bit in the register.

**Example:**

```assembly
ORR r0, r0, #0x80           @ Set bit 7
ORR r0, r0, #0x0F           @ Set bits 0-3
```

**Clearing Bits**

BIC (bit clear) clears bits indicated by the mask. Each set bit in the mask clears the corresponding bit in the register.

**Example:**

```assembly
BIC r0, r0, #0x10           @ Clear bit 4
BIC r0, r0, #0xF0           @ Clear bits 4-7
```

**Toggling Bits**

EOR (exclusive OR) toggles bits indicated by the mask. Bits corresponding to set mask bits flip between 0 and 1.

**Example:**

```assembly
EOR r0, r0, #0x20           @ Toggle bit 5
EOR r0, r0, #0xFF           @ Toggle bits 0-7
```

**Testing Bits**

TST performs bitwise AND without storing the result, only updating flags. The Z flag indicates whether specified bits are clear (Z=1) or any are set (Z=0).

**Example:**

```assembly
TST r0, #0x01               @ Test bit 0
BEQ bit_clear               @ Branch if bit 0 is clear (Z=1)
BNE bit_set                 @ Branch if bit 0 is set (Z=0)

TST r0, #0x0F               @ Test if any of bits 0-3 are set
```

**Counting Set Bits**

[Inference: ARMv5T and later include the CLZ (count leading zeros) instruction that counts consecutive zeros from bit 31 downward, useful for bit scanning algorithms. Population count (counting total set bits) may require software implementation on architectures without dedicated instructions].

**Example:**

```assembly
@ Count leading zeros
MOV r0, #0x00100000         @ Bit 20 is highest set bit
CLZ r1, r0                  @ r1 = 11 (bits 31-21 are zero)

@ Find highest set bit position
MOV r0, #0x00100000
CLZ r1, r0                  @ r1 = 11 leading zeros
RSB r1, r1, #31             @ r1 = 20 (bit position of highest set bit)
```

