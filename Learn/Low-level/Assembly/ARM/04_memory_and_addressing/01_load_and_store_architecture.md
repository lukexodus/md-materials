## Load and Store Architecture


### Architecture Principles

Load/store architecture enforces a clear separation between computation and memory access. All data processing instructions operate only on register operands, while dedicated load and store instructions handle memory transfers.

**Architecture Characteristics:**

- Memory access only through load (LDR) and store (STR) instructions
- All arithmetic/logical operations use register operands exclusively
- Predictable instruction timing and pipeline efficiency
- Simplified instruction decoding and execution
- Reduced instruction complexity enables higher clock frequencies

**Comparison with CISC:**

```assembly
# ARM (Load/Store Architecture)
ldr r0, [r1]          @ Load from memory to register
add r0, r0, #5        @ Arithmetic on registers
str r0, [r1]          @ Store back to memory

# x86 (CISC - direct memory operations)
add [ebx], 5          @ Arithmetic directly on memory
```

### Load Instructions

Load instructions transfer data from memory into registers.

**Basic Load Syntax:**

```assembly
ldr r0, [r1]          @ Load word (32-bit) from address in r1
ldrb r0, [r1]         @ Load byte (8-bit), zero-extend to 32-bit
ldrh r0, [r1]         @ Load halfword (16-bit), zero-extend
ldrsb r0, [r1]        @ Load signed byte, sign-extend to 32-bit
ldrsh r0, [r1]        @ Load signed halfword, sign-extend
```

**Data Size Suffixes:**

- No suffix or `W`: Word (32-bit)
- `B`: Byte (8-bit)
- `H`: Halfword (16-bit)
- `SB`: Signed byte
- `SH`: Signed halfword
- `D`: Doubleword (64-bit, loads two consecutive registers)

**Sign Extension Example:**

```assembly
# Memory at 0x20000000 contains: 0xFF
ldrb r0, [r1]         @ r0 = 0x000000FF (zero-extended)
ldrsb r0, [r1]        @ r0 = 0xFFFFFFFF (sign-extended)

# Memory at 0x20000000 contains: 0x8000
ldrh r0, [r1]         @ r0 = 0x00008000 (zero-extended)
ldrsh r0, [r1]        @ r0 = 0xFFFF8000 (sign-extended)
```

**Multiple Register Loads:**

```assembly
ldm r0, {r1-r5}       @ Load multiple: r1, r2, r3, r4, r5 from [r0]
ldmia r0, {r1-r5}     @ Increment After (same as ldm)
ldmib r0, {r1-r5}     @ Increment Before
ldmda r0, {r1-r5}     @ Decrement After
ldmdb r0, {r1-r5}     @ Decrement Before

# Stack operations (aliases)
pop {r0-r3}           @ Same as ldmia sp!, {r0-r3}
```

**Doubleword Load:**

```assembly
# Load 64-bit value into r0 and r1
ldrd r0, r1, [r2]     @ r0 = [r2], r1 = [r2+4]
                      @ r0 must be even-numbered register
```

### Store Instructions

Store instructions transfer data from registers into memory.

**Basic Store Syntax:**

```assembly
str r0, [r1]          @ Store word (32-bit) to address in r1
strb r0, [r1]         @ Store byte (lower 8 bits of r0)
strh r0, [r1]         @ Store halfword (lower 16 bits of r0)
```

**Partial Register Storage:**

```assembly
# r0 contains 0x12345678
strb r0, [r1]         @ Memory at [r1] = 0x78 (lower byte only)
strh r0, [r1]         @ Memory at [r1] = 0x5678 (lower halfword)
str r0, [r1]          @ Memory at [r1] = 0x12345678 (full word)
```

**Multiple Register Stores:**

```assembly
stm r0, {r1-r5}       @ Store multiple: r1, r2, r3, r4, r5 to [r0]
stmia r0, {r1-r5}     @ Increment After
stmib r0, {r1-r5}     @ Increment Before
stmda r0, {r1-r5}     @ Decrement After
stmdb r0, {r1-r5}     @ Decrement Before

# Stack operations (aliases)
push {r0-r3}          @ Same as stmdb sp!, {r0-r3}
```

**Doubleword Store:**

```assembly
# Store r0 and r1 as 64-bit value
strd r0, r1, [r2]     @ [r2] = r0, [r2+4] = r1
                      @ r0 must be even-numbered register
```

### Memory Alignment

ARM processors have alignment requirements for efficient memory access.

**Alignment Rules:**

- Word (32-bit) accesses must be 4-byte aligned
- Halfword (16-bit) accesses must be 2-byte aligned
- Byte (8-bit) accesses can be unaligned
- Doubleword (64-bit) accesses must be 8-byte aligned

**Unaligned Access Behavior:**

```assembly
# Address 0x20000001 (not word-aligned)
ldr r0, [r1]          @ ARMv6 and later: supports unaligned access
                      @ ARMv5 and earlier: undefined or fault
                      @ Cortex-M0/M0+: fault (no unaligned support)
                      @ Cortex-M3/M4/M7: allowed but slower
```

**Alignment Configuration:**

```assembly
# Cortex-M: CCR.UNALIGN_TRP bit controls unaligned access
ldr r0, =0xE000ED14   @ Configuration Control Register
ldr r1, [r0]
orr r1, r1, #8        @ Set UNALIGN_TRP bit
str r1, [r0]          @ Unaligned access will fault
```

### Endianness

ARM supports both little-endian and big-endian byte ordering.

**Little-Endian (default and most common):**

```assembly
# Store 0x12345678 at address 0x1000
str r0, [r1]

# Memory layout:
# 0x1000: 0x78  (LSB)
# 0x1001: 0x56
# 0x1002: 0x34
# 0x1003: 0x12  (MSB)
```

**Big-Endian:**

```assembly
# Same value stored big-endian
# 0x1000: 0x12  (MSB)
# 0x1001: 0x34
# 0x1002: 0x56
# 0x1003: 0x78  (LSB)
```

**Byte Reversal:**

```assembly
# Convert between endianness
rev r0, r1            @ Reverse byte order in word
rev16 r0, r1          @ Reverse bytes in each halfword
revsh r0, r1          @ Reverse bytes in bottom halfword, sign-extend
```

