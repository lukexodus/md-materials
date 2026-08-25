## Byte and Halfword Operations


ARM provides specific instructions for efficient manipulation of sub-word data types.

### Byte Operations

**Basic Byte Load/Store:**

```assembly
# Load byte (zero-extended)
ldrb r0, [r1]        @ r0 = 8-bit value from [r1], zero-extended to 32-bit

# Load byte (sign-extended)
ldrsb r0, [r1]       @ r0 = 8-bit value from [r1], sign-extended to 32-bit

# Store byte
strb r0, [r1]        @ Store lower 8 bits of r0 to [r1]
```

**Example: Character Handling:**

```assembly
# Check if character is uppercase
# r0 = character, returns 1 if uppercase, 0 otherwise
is_uppercase:
    sub r1, r0, #'A'
    cmp r1, #25
    movls r0, #1
    movhi r0, #0
    bx lr

# Convert to uppercase
# r0 = character
to_uppercase:
    sub r1, r0, #'a'
    cmp r1, #25
    subls r0, r0, #32    @ Convert if lowercase
    bx lr

# Convert to lowercase
# r0 = character
to_lowercase:
    sub r1, r0, #'A'
    cmp r1, #25
    addls r0, r0, #32    @ Convert if uppercase
    bx lr
```

**String Length:**

```assembly
# strlen implementation
# r0 = string pointer, returns length in r0
strlen:
    mov r1, r0           @ Save start
    
strlen_loop:
    ldrb r2, [r0], #1    @ Load byte, advance
    cmp r2, #0           @ Check for null
    bne strlen_loop
    
    sub r0, r0, r1       @ Calculate length
    sub r0, r0, #1       @ Adjust for extra increment
    bx lr
```

**String Copy:**

```assembly
# strcpy implementation
# r0 = dest, r1 = src
strcpy:
    push {r4}
    mov r4, r0           @ Save dest for return

strcpy_loop:
    ldrb r2, [r1], #1    @ Load from src
    strb r2, [r0], #1    @ Store to dest
    cmp r2, #0           @ Check for null
    bne strcpy_loop
    
    mov r0, r4           @ Return original dest
    pop {r4}
    bx lr
```

**String Compare:**

```assembly
# strcmp implementation
# r0 = s1, r1 = s2, returns <0, 0, >0
strcmp:
strcmp_loop:
    ldrb r2, [r0], #1    @ Load from s1
    ldrb r3, [r1], #1    @ Load from s2
    cmp r2, r3           @ Compare bytes
    bne strcmp_diff
    cmp r2, #0           @ Check for end
    bne strcmp_loop
    
    mov r0, #0           @ Equal
    bx lr

strcmp_diff:
    sub r0, r2, r3       @ Return difference
    bx lr
```

**Byte Array Operations:**

```assembly
# Find byte in array
# r0 = array, r1 = byte to find, r2 = size
# Returns index in r0, or -1 if not found
find_byte:
    mov r3, #0           @ Index

find_loop:
    cmp r3, r2
    bge not_found
    
    ldrb r4, [r0, r3]    @ Load byte
    cmp r4, r1           @ Compare
    beq found
    
    add r3, r3, #1
    b find_loop

found:
    mov r0, r3           @ Return index
    bx lr

not_found:
    mov r0, #-1
    bx lr
```

### Halfword Operations

**Basic Halfword Load/Store:**

```assembly
# Load halfword (zero-extended)
ldrh r0, [r1]        @ r0 = 16-bit value from [r1], zero-extended

# Load halfword (sign-extended)
ldrsh r0, [r1]       @ r0 = 16-bit value from [r1], sign-extended

# Store halfword
strh r0, [r1]        @ Store lower 16 bits of r0 to [r1]
```

**Alignment Note:** Halfword accesses must be 2-byte aligned. Accessing unaligned halfwords may fault or produce unpredictable results depending on the processor.

```assembly
# Safe halfword access with alignment check
load_halfword_safe:
    tst r0, #1           @ Check if address is odd
    movne r0, #-1        @ Return error if unaligned
    bxne lr
    
    ldrh r0, [r0]        @ Load halfword
    bx lr
```

**Audio Sample Processing:**

```assembly
# Process 16-bit audio samples
# r0 = sample array, r1 = count, r2 = gain (fixed-point)
process_audio_samples:
    push {r4-r6}
    
    mov r4, #0           @ Index

sample_loop:
    cmp r4, r1
    bge sample_done
    
    ldrsh r5, [r0, r4, LSL #1]  @ Load signed 16-bit sample
    
    # Apply gain (fixed-point multiplication)
    smull r5, r6, r5, r2     @ 32x32 -> 64-bit result
    asr r5, r5, #16          @ Shift to get 16-bit result
    
    # Clamp to 16-bit range
    mov r6, #32767
    cmp r5, r6
    movgt r5, r6
    mvn r6, #32767           @ -32768
    cmp r5, r6
    movlt r5, r6
    
    strh r5, [r0, r4, LSL #1]  @ Store processed sample
    
    add r4, r4, #1
    b sample_loop

sample_done:
    pop {r4-r6}
    bx lr
```

**UTF-16 String Operations:**

```assembly
# UTF-16 string length
# r0 = string pointer (16-bit characters)
strlen_utf16:
    mov r1, r0
    
strlen_utf16_loop:
    ldrh r2, [r0], #2    @ Load 16-bit character
    cmp r2, #0
    bne strlen_utf16_loop
    
    sub r0, r0, r1       @ Calculate byte length
    lsr r0, r0, #1       @ Convert to character count
    sub r0, r0, #1       @ Adjust for null terminator
    bx lr
```

**Pixel Operations (RGB565):**

```assembly
# Extract RGB components from RGB565 format
# r0 = RGB565 value
# Returns: r0=R, r1=G, r2=B (8-bit values)
rgb565_to_rgb888:
    # Extract red (bits 15-11)
    lsr r1, r0, #11
    and r1, r1, #0x1F
    lsl r1, r1, #3       @ Scale to 8-bit
    
    # Extract green (bits 10-5)
    lsr r2, r0, #5
    and r2, r2, #0x3F
    lsl r2, r2, #2       @ Scale to 8-bit
    
    # Extract blue (bits 4-0)
    and r3, r0, #0x1F
    lsl r3, r3, #3       @ Scale to 8-bit
    
    # Return values
    mov r0, r1           @ R
    mov r1, r2           @ G
    mov r2, r3           @ B
    bx lr

# Pack RGB888 to RGB565
# r0=R, r1=G, r2=B (8-bit values)
# Returns RGB565 in r0
rgb888_to_rgb565:
    # Red: take top 5 bits, shift to position
    lsr r0, r0, #3
    lsl r0, r0, #11
    
    # Green: take top 6 bits, shift to position
    lsr r1, r1, #2
    lsl r1, r1, #5
    orr r0, r0, r1
    
    # Blue: take top 5 bits
    lsr r2, r2, #3
    orr r0, r0, r2
    
    bx lr
```

### Mixed-Size Operations

**Pack bytes into word:**

```assembly
# Pack 4 bytes into a word
# r0-r3 = byte values, returns packed word in r0
pack_bytes:
    and r0, r0, #0xFF    @ Ensure single byte
    and r1, r1, #0xFF
    and r2, r2, #0xFF
    and r3, r3, #0xFF
    
    orr r0, r0, r1, LSL #8
    orr r0, r0, r2, LSL #16
    orr r0, r0, r3, LSL #24
    
    bx lr
```

**Unpack word into bytes:**

```assembly
# Unpack word into 4 bytes
# r0 = packed word
# Returns: r0=byte0, r1=byte1, r2=byte2, r3=byte3
unpack_bytes:
    mov r4, r0           @ Save original
    
    and r0, r4, #0xFF             @ Byte 0
    lsr r1, r4, #8
    and r1, r1, #0xFF             @ Byte 1
    lsr r2, r4, #16
    and r2, r2, #0xFF             @ Byte 2
    lsr r3, r4, #24               @ Byte 3
    
    bx lr
```


**Pack halfwords into word:**

```assembly
# Pack 2 halfwords into a word
# r0 = low halfword, r1 = high halfword
# Returns packed word in r0
pack_halfwords:
    and r0, r0, #0xFFFF  @ Ensure lower 16 bits
    bfi r0, r1, #16, #16 @ Insert r1 into upper 16 bits
    # Alternative without BFI:
    # and r0, r0, #0xFFFF
    # orr r0, r0, r1, LSL #16
    bx lr
````

**Unpack word into halfwords:**

```assembly
# Unpack word into 2 halfwords
# r0 = packed word
# Returns: r0=low halfword, r1=high halfword
unpack_halfwords:
    mov r1, r0, LSR #16  @ High halfword
    and r0, r0, #0xFFFF  @ Low halfword
    # Alternative using UXTH:
    # uxth r0, r0          @ Zero-extend low halfword
    # lsr r1, r0, #16      @ Shift high halfword
    bx lr
```

