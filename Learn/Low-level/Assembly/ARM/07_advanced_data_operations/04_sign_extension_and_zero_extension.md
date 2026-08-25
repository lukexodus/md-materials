## Sign Extension and Zero Extension


Extension operations convert smaller data types to larger ones while preserving value representation.

### Zero Extension

Zero extension fills the upper bits with zeros, used for unsigned values.

**Manual Zero Extension:**

```assembly
# Zero-extend byte to word
mov r0, #0xFF        @ Byte value
and r0, r0, #0xFF    @ Zero-extend (clear upper 24 bits)

# Zero-extend halfword to word
ldr r0, =0x1234      @ Halfword value
and r0, r0, #0xFFFF  @ Zero-extend (clear upper 16 bits)

# Using bit clear
mov r0, #0xFF
bic r0, r0, #0xFFFFFF00  @ Clear upper 24 bits
```

**UXTB - Unsigned Extend Byte:**

```assembly
# Zero-extend byte (bits 7:0) to word
uxtb r0, r1          @ r0 = zero-extend(r1[7:0])

# With rotation
uxtb r0, r1, ROR #8  @ Extract and extend byte 1
uxtb r0, r1, ROR #16 @ Extract and extend byte 2
uxtb r0, r1, ROR #24 @ Extract and extend byte 3

# Example: Extract individual bytes
mov r1, #0x12345678
uxtb r0, r1          @ r0 = 0x00000078
uxtb r0, r1, ROR #8  @ r0 = 0x00000056
uxtb r0, r1, ROR #16 @ r0 = 0x00000034
uxtb r0, r1, ROR #24 @ r0 = 0x00000012
```

**UXTH - Unsigned Extend Halfword:**

```assembly
# Zero-extend halfword (bits 15:0) to word
uxth r0, r1          @ r0 = zero-extend(r1[15:0])

# With rotation
uxth r0, r1, ROR #16 @ Extract and extend upper halfword

# Example
mov r1, #0x12345678
uxth r0, r1          @ r0 = 0x00005678
uxth r0, r1, ROR #16 @ r0 = 0x00001234
```

**LDRB/LDRH with Zero Extension:**

```assembly
# Load instructions automatically zero-extend
ldrb r0, [r1]        @ Load byte, zero-extend to 32 bits
ldrh r0, [r1]        @ Load halfword, zero-extend to 32 bits

# Example
# Memory at 0x1000: 0xFF
ldr r0, =0x1000
ldrb r1, [r0]        @ r1 = 0x000000FF (zero-extended)
```

### Sign Extension

Sign extension replicates the sign bit to preserve the numeric value of signed integers.

**Manual Sign Extension:**

```assembly
# Sign-extend byte to word (manual)
mov r0, #0x80        @ Negative byte value (-128)
lsl r0, r0, #24      @ Shift to MSB position
asr r0, r0, #24      @ Arithmetic shift right (sign extends)
# r0 = 0xFFFFFF80

# Sign-extend halfword to word (manual)
mov r0, #0x8000      @ Negative halfword value
lsl r0, r0, #16      @ Shift to MSB position
asr r0, r0, #16      @ Arithmetic shift right
# r0 = 0xFFFF8000
```

**SXTB - Signed Extend Byte:**

```assembly
# Sign-extend byte (bits 7:0) to word
sxtb r0, r1          @ r0 = sign-extend(r1[7:0])

# With rotation
sxtb r0, r1, ROR #8  @ Extract and sign-extend byte 1
sxtb r0, r1, ROR #16 @ Extract and sign-extend byte 2
sxtb r0, r1, ROR #24 @ Extract and sign-extend byte 3

# Example: Handle signed bytes
mov r1, #0x12345680  @ Contains negative byte in position 0
sxtb r0, r1          @ r0 = 0xFFFFFF80 (-128)
sxtb r0, r1, ROR #8  @ r0 = 0x00000056 (positive)
```

**SXTH - Signed Extend Halfword:**

```assembly
# Sign-extend halfword (bits 15:0) to word
sxth r0, r1          @ r0 = sign-extend(r1[15:0])

# With rotation
sxth r0, r1, ROR #16 @ Extract and sign-extend upper halfword

# Example
mov r1, #0x12348000  @ Contains negative halfword
sxth r0, r1          @ r0 = 0xFFFF8000 (-32768)
sxth r0, r1, ROR #16 @ r0 = 0x00001234 (positive)
```

**LDRSB/LDRSH with Sign Extension:**

```assembly
# Load instructions with automatic sign extension
ldrsb r0, [r1]       @ Load byte, sign-extend to 32 bits
ldrsh r0, [r1]       @ Load halfword, sign-extend to 32 bits

# Example
# Memory at 0x1000: 0xFF (represents -1 as signed byte)
ldr r0, =0x1000
ldrsb r1, [r0]       @ r1 = 0xFFFFFFFF (sign-extended)
ldrb r2, [r0]        @ r2 = 0x000000FF (zero-extended)
```

### Extension Examples

**Temperature Sensor Reading (8-bit signed):**

```assembly
# Read signed temperature value
# r0 = sensor register address
# Returns temperature in r0 (sign-extended)
read_temperature:
    ldrb r1, [r0]        @ Read raw byte
    sxtb r0, r1          @ Sign-extend to 32-bit
    # Now r0 contains proper signed value
    # 0x80 (128 as unsigned) becomes 0xFFFFFF80 (-128 as signed)
    bx lr
```

**Audio Sample Conversion:**

```assembly
# Convert 16-bit audio sample to 32-bit
# r0 = sample array (16-bit), r1 = count
# r2 = output array (32-bit)
convert_audio_16_to_32:
    push {r4-r5}
    mov r4, #0

convert_loop:
    cmp r4, r1
    bge convert_done
    
    ldrsh r5, [r0, r4, LSL #1]  @ Load and sign-extend
    str r5, [r2, r4, LSL #2]    @ Store as 32-bit
    
    add r4, r4, #1
    b convert_loop

convert_done:
    pop {r4-r5}
    bx lr
```

**Character to Integer Conversion:**

```assembly
# Convert ASCII digit to integer
# r0 = character ('0'-'9')
# Returns integer value (0-9) or -1 if invalid
char_to_digit:
    sub r1, r0, #'0'     @ Subtract '0'
    cmp r1, #9           @ Check if in range 0-9
    movls r0, r1         @ Valid digit
    movhi r0, #-1        @ Invalid
    bx lr

# Convert integer to ASCII digit
# r0 = value (0-9)
# Returns character or -1 if invalid
digit_to_char:
    cmp r0, #9
    movls r0, r0, ADD #'0'  @ Add '0'
    movhi r0, #-1        @ Invalid
    bx lr
```

### Bit Field Extraction and Insertion

**UBFX - Unsigned Bit Field Extract:**

```assembly
# Extract unsigned bit field
# ubfx rd, rn, #lsb, #width
ubfx r0, r1, #8, #8  @ Extract bits [15:8] into r0[7:0]

# Example: Extract RGB components from 32-bit color
# Format: 0xAARRGGBB
extract_color_components:
    # r0 = color value
    ubfx r1, r0, #16, #8 @ Extract red (bits 23:16)
    ubfx r2, r0, #8, #8  @ Extract green (bits 15:8)
    ubfx r3, r0, #0, #8  @ Extract blue (bits 7:0)
    ubfx r4, r0, #24, #8 @ Extract alpha (bits 31:24)
    bx lr
```

**SBFX - Signed Bit Field Extract:**

```assembly
# Extract signed bit field (with sign extension)
# sbfx rd, rn, #lsb, #width
sbfx r0, r1, #8, #8  @ Extract bits [15:8], sign-extend

# Example: Extract signed temperature from packed data
# Bits [15:8] contain signed 8-bit temperature
extract_temperature:
    sbfx r0, r0, #8, #8  @ Extract and sign-extend
    bx lr
```

**BFI - Bit Field Insert:**

```assembly
# Insert bit field
# bfi rd, rn, #lsb, #width
bfi r0, r1, #8, #8   @ Insert r1[7:0] into r0[15:8]

# Example: Pack RGB components into 32-bit color
pack_color_components:
    # r0=red, r1=green, r2=blue, r3=alpha
    mov r4, #0           @ Start with zero
    bfi r4, r3, #24, #8  @ Insert alpha at bits 31:24
    bfi r4, r0, #16, #8  @ Insert red at bits 23:16
    bfi r4, r1, #8, #8   @ Insert green at bits 15:8
    bfi r4, r2, #0, #8   @ Insert blue at bits 7:0
    mov r0, r4           @ Return packed color
    bx lr
```

**BFC - Bit Field Clear:**

```assembly
# Clear bit field
# bfc rd, #lsb, #width
bfc r0, #8, #8       @ Clear bits [15:8]

# Example: Clear specific flags
clear_status_flags:
    bfc r0, #0, #4       @ Clear lower 4 bits
    bx lr
```

### Practical Extension Applications

**Network Byte Order Conversion:**

```assembly
# Convert 16-bit value between host and network byte order (big-endian)
# r0 = value
htons:
    rev16 r0, r0         @ Reverse bytes in each halfword
    uxth r0, r0          @ Zero-extend to 32 bits
    bx lr

# Convert 32-bit value
htonl:
    rev r0, r0           @ Reverse all bytes
    bx lr
```

**Checksum Calculation with Extension:**

```assembly
# Calculate 16-bit checksum (Internet checksum)
# r0 = data pointer, r1 = length (bytes)
# Returns checksum in r0
calculate_checksum:
    push {r4-r5}
    
    mov r2, #0           @ Accumulator
    mov r4, r1           @ Save length

checksum_loop:
    cmp r1, #1
    ble checksum_last_byte
    
    ldrh r3, [r0], #2    @ Load halfword (zero-extended)
    add r2, r2, r3       @ Add to sum
    
    # Handle carry
    mov r5, r2, LSR #16  @ Extract carry
    and r2, r2, #0xFFFF  @ Keep lower 16 bits
    add r2, r2, r5       @ Add carry back
    
    sub r1, r1, #2
    b checksum_loop

checksum_last_byte:
    cmp r1, #0
    beq checksum_done
    
    ldrb r3, [r0]        @ Load last byte (zero-extended)
    add r2, r2, r3, LSL #8  @ Treat as high byte
    
checksum_done:
    # Final carry handling
    mov r5, r2, LSR #16
    and r2, r2, #0xFFFF
    add r2, r2, r5
    
    mvn r0, r2           @ One's complement
    uxth r0, r0          @ Keep lower 16 bits
    
    pop {r4-r5}
    bx lr
```

**Fixed-Point Arithmetic with Sign Extension:**

```assembly
# Multiply 16-bit fixed-point numbers (Q15 format)
# r0, r1 = Q15 values (16-bit signed)
# Returns Q15 result in r0
q15_multiply:
    sxth r0, r0          @ Sign-extend to 32-bit
    sxth r1, r1          @ Sign-extend to 32-bit
    
    smull r2, r3, r0, r1 @ 32x32 -> 64-bit result
    
    # Extract Q15 result (bits 30:15 of 64-bit product)
    lsr r2, r2, #15
    orr r0, r2, r3, LSL #17
    
    # Saturate to 16-bit
    mov r2, #0x7FFF
    cmp r0, r2
    movgt r0, r2         @ Clamp to max
    mvn r2, r2           @ -0x8000
    cmp r0, r2
    movlt r0, r2         @ Clamp to min
    
    sxth r0, r0          @ Final sign-extend
    bx lr
```

**Structure Packing with Bit Fields:**

```assembly
# Pack structure with bit fields
# struct Flags {
#     unsigned int a : 4;  // bits 0-3
#     signed int b : 8;    // bits 4-11 (signed)
#     unsigned int c : 12; // bits 12-23
# };

pack_flags_struct:
    # r0=a, r1=b, r2=c
    mov r3, #0           @ Result
    
    # Insert a (4 bits, unsigned)
    and r0, r0, #0xF
    bfi r3, r0, #0, #4
    
    # Insert b (8 bits, signed)
    sxtb r1, r1          @ Sign-extend
    and r1, r1, #0xFF    @ Mask to 8 bits
    bfi r3, r1, #4, #8
    
    # Insert c (12 bits, unsigned)
    and r2, r2, #0xFFF
    bfi r3, r2, #12, #12
    
    mov r0, r3
    bx lr

unpack_flags_struct:
    # r0 = packed value
    ubfx r1, r0, #0, #4  @ Extract a (unsigned)
    sbfx r2, r0, #4, #8  @ Extract b (signed, extended)
    ubfx r3, r0, #12, #12 @ Extract c (unsigned)
    
    # Return: r0=a, r1=b, r2=c
    mov r0, r1
    mov r1, r2
    mov r2, r3
    bx lr
```

**Saturation Operations:**

```assembly
# Saturate signed value to 8-bit range
# r0 = value, returns saturated value
saturate_s8:
    cmp r0, #127
    movgt r0, #127       @ Clamp to max
    cmn r0, #128
    movlt r0, #-128      @ Clamp to min
    sxtb r0, r0          @ Sign-extend result
    bx lr

# Saturate unsigned value to 8-bit range
saturate_u8:
    cmp r0, #0
    movlt r0, #0         @ Clamp to min
    cmp r0, #255
    movgt r0, #255       @ Clamp to max
    uxtb r0, r0          @ Zero-extend result
    bx lr

# Using SSAT/USAT instructions (if available)
saturate_ssat:
    ssat r0, #8, r0      @ Saturate to signed 8-bit (-128 to 127)
    bx lr

saturate_usat:
    usat r0, #8, r0      @ Saturate to unsigned 8-bit (0 to 255)
    bx lr
```

**Pixel Format Conversion:**

```assembly
# Convert RGBA8888 to RGB565
# r0 = RGBA8888 value (0xRRGGBBAA)
rgba8888_to_rgb565:
    # Extract and scale red (take bits 7:3)
    ubfx r1, r0, #27, #5 @ Extract R[7:3]
    lsl r1, r1, #11      @ Shift to position
    
    # Extract and scale green (take bits 7:2)
    ubfx r2, r0, #18, #6 @ Extract G[7:2]
    lsl r2, r2, #5       @ Shift to position
    orr r1, r1, r2
    
    # Extract and scale blue (take bits 7:3)
    ubfx r2, r0, #11, #5 @ Extract B[7:3]
    orr r0, r1, r2       @ Combine all components
    
    bx lr

# Convert RGB565 to RGBA8888 (with full alpha)
rgb565_to_rgba8888:
    # Extract red and scale to 8-bit
    ubfx r1, r0, #11, #5
    lsl r1, r1, #3       @ Scale: 5-bit -> 8-bit
    orr r1, r1, r1, LSR #5  @ Replicate bits for better accuracy
    lsl r1, r1, #24      @ Position in result
    
    # Extract green and scale to 8-bit
    ubfx r2, r0, #5, #6
    lsl r2, r2, #2       @ Scale: 6-bit -> 8-bit
    orr r2, r2, r2, LSR #6  @ Replicate bits
    lsl r2, r2, #16      @ Position in result
    orr r1, r1, r2
    
    # Extract blue and scale to 8-bit
    ubfx r2, r0, #0, #5
    lsl r2, r2, #3       @ Scale: 5-bit -> 8-bit
    orr r2, r2, r2, LSR #5  @ Replicate bits
    lsl r2, r2, #8       @ Position in result
    orr r1, r1, r2
    
    # Add full alpha
    orr r0, r1, #0xFF    @ Alpha = 255
    
    bx lr
```

**Key Points:**

- LDM/STM instructions transfer multiple registers in a single operation, reducing instruction count and improving performance for bulk data operations
- Register lists are processed in ascending numerical order regardless of specification order, with lower registers accessing lower memory addresses
- Stack operations use specific LDM/STM variants: STMDB/LDMIA for full descending stacks (ARM standard)
- Block transfers enable efficient memory copying, structure operations, and context switching with up to 32 bytes per instruction
- Byte operations (LDRB/STRB) and halfword operations (LDRH/STRH) provide direct access to sub-word data types
- Zero extension (UXTB/UXTH) preserves unsigned values by filling upper bits with zeros; sign extension (SXTB/SXTH) preserves signed values by replicating the sign bit
- Bit field operations (UBFX/SBFX/BFI/BFC) enable efficient extraction and insertion of arbitrary bit ranges without masking and shifting sequences
- Proper extension is critical for correct arithmetic on mixed-size signed/unsigned values and prevents incorrect value interpretation

---

