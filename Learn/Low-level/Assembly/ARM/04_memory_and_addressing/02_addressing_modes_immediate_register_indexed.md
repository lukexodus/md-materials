## Addressing Modes (Immediate, Register, Indexed)


Addressing modes specify how to calculate the effective memory address for load/store operations.

### Immediate Offset

The effective address is the base register plus or minus an immediate constant.

**Syntax:**

```assembly
ldr r0, [r1, #offset]     @ Address = r1 + offset
ldr r0, [r1, #-offset]    @ Address = r1 - offset
```

**Examples:**

```assembly
# Access structure members
# struct Point { int x; int y; int z; };
# r0 points to Point structure
ldr r1, [r0, #0]      @ r1 = point.x (offset 0)
ldr r2, [r0, #4]      @ r2 = point.y (offset 4)
ldr r3, [r0, #8]      @ r3 = point.z (offset 8)

# Array access with known index
# int array[10]; r0 points to array
ldr r1, [r0, #0]      @ array[0]
ldr r2, [r0, #12]     @ array[3] (3 * 4 bytes)
ldr r3, [r0, #36]     @ array[9] (9 * 4 bytes)

# Negative offset
ldr r1, [r0, #-4]     @ Access data before base address
```

**Offset Range:**

- Word/Halfword/Byte: -4095 to +4095 (12-bit offset)
- Thumb-2 encoding: -255 to +4095
- Thumb 16-bit encoding: 0 to 31 (limited range)

**Assembler Pseudo-Instruction:**

```assembly
# Large offsets use pseudo-instruction
ldr r0, [r1, #8192]   @ Assembler generates:
                      @ add r_temp, r1, #8192
                      @ ldr r0, [r_temp]
```

### Register Offset

The effective address is the base register plus or minus another register.

**Syntax:**

```assembly
ldr r0, [r1, r2]      @ Address = r1 + r2
ldr r0, [r1, -r2]     @ Address = r1 - r2
```

**Examples:**

```assembly
# Array access with variable index
# r0 = array base, r1 = index
lsl r2, r1, #2        @ r2 = index * 4 (word size)
ldr r3, [r0, r2]      @ Load array[index]

# Pointer arithmetic
# r0 = base address, r1 = byte offset
ldr r2, [r0, r1]      @ Load from base + offset

# Negative offset
sub r2, r0, r1        @ Calculate offset
ldr r3, [r4, -r2]     @ Load using negative offset
```

### Scaled Register Offset (Indexed Addressing)

The offset register can be scaled using a shift operation before being added to the base.

**Syntax:**

```assembly
ldr r0, [r1, r2, LSL #shift]   @ Address = r1 + (r2 << shift)
ldr r0, [r1, r2, LSR #shift]   @ Address = r1 + (r2 >> shift)
ldr r0, [r1, r2, ASR #shift]   @ Address = r1 + (r2 arithmetic >> shift)
ldr r0, [r1, r2, ROR #shift]   @ Address = r1 + (r2 rotated shift)
```

**Shift Operations:**

- `LSL` (Logical Shift Left): Multiply by power of 2
- `LSR` (Logical Shift Right): Unsigned divide by power of 2
- `ASR` (Arithmetic Shift Right): Signed divide by power of 2
- `ROR` (Rotate Right): Circular bit rotation

**Array Indexing Examples:**

```assembly
# Word array access (4 bytes per element)
# r0 = array base, r1 = index
ldr r2, [r0, r1, LSL #2]   @ Load array[index], shift index by 2

# Halfword array (2 bytes per element)
ldr r2, [r0, r1, LSL #1]   @ Load array[index], shift index by 1

# Doubleword array (8 bytes per element)
ldr r2, [r0, r1, LSL #3]   @ Load array[index], shift index by 3

# Structure array access
# struct { int a; int b; int c; } array[]; (12 bytes per struct)
# r0 = array base, r1 = index, access member 'b' (offset 4)
add r2, r1, r1, LSL #1     @ r2 = index * 3
ldr r3, [r0, r2, LSL #2]   @ Base + (index * 12)
ldr r4, [r3, #4]           @ Load member 'b'
```

**Matrix Access:**

```assembly
# 2D array: matrix[rows][cols], element size = 4 bytes
# r0 = matrix base
# r1 = row index
# r2 = column index
# r3 = number of columns
# Calculate: address = base + (row * cols + col) * 4

mul r4, r1, r3        @ r4 = row * cols
add r4, r4, r2        @ r4 = row * cols + col
ldr r5, [r0, r4, LSL #2]   @ Load matrix[row][col]
```

**Extended Register Offset (ARMv8-A 64-bit):**

```assembly
# AArch64 addressing modes
ldr x0, [x1, x2]           @ Base + offset
ldr x0, [x1, x2, SXTW #3]  @ Base + sign-extend(w2) << 3
ldr x0, [x1, w2, UXTW #2]  @ Base + zero-extend(w2) << 2
```

### PC-Relative Addressing

Load data relative to the Program Counter for position-independent code.

**Syntax:**

```assembly
ldr r0, [pc, #offset]     @ Address = PC + offset + 8 (ARM)
                          @ Address = PC + offset + 4 (Thumb)
ldr r0, label             @ Assembler calculates offset
```

**Examples:**

```assembly
# Load constant from literal pool
ldr r0, =0x12345678   @ Pseudo-instruction, assembler generates:
                      @ ldr r0, [pc, #offset]
                      @ ...
                      @ .word 0x12345678

# Access data near code
.text
function:
    ldr r0, constant_value   @ PC-relative load
    bx lr

constant_value:
    .word 0xDEADBEEF

# Position-independent data access
    adr r0, data_table       @ Load address of data_table into r0
    ldr r1, [r0]             @ Access data

data_table:
    .word 100, 200, 300
```

**ADR Pseudo-Instruction:**

```assembly
# ADR generates address relative to PC
adr r0, label         @ r0 = address of label
                      @ Assembler generates: add r0, pc, #offset

# ADRL for larger offsets (pseudo-instruction)
adrl r0, far_label    @ May generate two instructions
```

### Literal Pool

The literal pool stores constants that can be loaded with PC-relative addressing.

**Automatic Literal Pool:**

```assembly
# Assembler creates literal pool automatically
ldr r0, =0x12345678   @ Load immediate value
ldr r1, =0x20000000   @ Load address

# Assembler generates:
# ldr r0, [pc, #offset1]
# ldr r1, [pc, #offset2]
# ...
# .ltorg               @ Literal pool placement
# .word 0x12345678
# .word 0x20000000
```

**Manual Literal Pool Placement:**

```assembly
.text
function:
    ldr r0, =value1
    ldr r1, =value2
    # ... more code ...
    
    b skip_literals   @ Branch over literal pool
    .ltorg            @ Explicit literal pool placement
skip_literals:
    # ... continue execution ...

# Without .ltorg, assembler places pool automatically
# at end of section or when out of range
```

