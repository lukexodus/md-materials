## Packing and Unpacking Data


### Byte Packing

**Pack four bytes into dword:**

```nasm
; Pack bytes B3, B2, B1, B0 into EAX
movzx eax, byte [B0]                    ; Load B0 (bits 7:0)
movzx ebx, byte [B1]
shl ebx, 8                              ; Position B1 (bits 15:8)
or eax, ebx
movzx ebx, byte [B2]
shl ebx, 16                             ; Position B2 (bits 23:16)
or eax, ebx
movzx ebx, byte [B3]
shl ebx, 24                             ; Position B3 (bits 31:24)
or eax, ebx
; EAX = [B3][B2][B1][B0]

; Alternative using direct memory load (if bytes are consecutive)
mov eax, dword [B0]                     ; Load all 4 bytes at once
```

**Unpack dword into four bytes:**

```nasm
; Unpack EAX into bytes B0, B1, B2, B3
mov [B0], al                            ; Store bits 7:0
mov ebx, eax
shr ebx, 8
mov [B1], bl                            ; Store bits 15:8
mov ebx, eax
shr ebx, 16
mov [B2], bl                            ; Store bits 23:16
shr eax, 24
mov [B3], al                            ; Store bits 31:24

; Alternative using byte register access
mov [B0], al                            ; Bits 7:0
mov [B1], ah                            ; Bits 15:8
shr eax, 16
mov [B2], al                            ; Bits 23:16
mov [B3], ah                            ; Bits 31:24
```

### Word Packing

**Pack two words into dword:**

```nasm
; Pack words W1 (high) and W0 (low) into EAX
movzx eax, word [W0]                    ; Load low word
movzx ebx, word [W1]
shl ebx, 16                             ; Position high word
or eax, ebx                             ; Combine
; EAX = [W1:16][W0:16]

; Alternative
mov ax, [W0]                            ; Load low word
mov dx, [W1]                            ; Load high word
shl edx, 16                             ; Position in upper 16 bits
movzx eax, ax                           ; Zero extend low word
or eax, edx                             ; Combine
```

**Unpack dword into two words:**

```nasm
; Unpack EAX into words W0 (low) and W1 (high)
mov [W0], ax                            ; Store low word (bits 15:0)
shr eax, 16
mov [W1], ax                            ; Store high word (bits 31:16)

; Non-destructive unpack
mov ebx, eax
and ebx, 0xFFFF
mov [W0], bx                            ; Low word
shr eax, 16
mov [W1], ax                            ; High word
```

### Nibble Packing

**Pack two nibbles into byte:**

```nasm
; Pack nibbles N1 (high) and N0 (low) into AL
mov al, [N0]
and al, 0x0F                            ; Ensure 4 bits
mov bl, [N1]
and bl, 0x0F                            ; Ensure 4 bits
shl bl, 4                               ; Position in high nibble
or al, bl                               ; Combine
; AL = [N1:4][N0:4]
```

**Unpack byte into two nibbles:**

```nasm
; Unpack AL into nibbles N0 (low) and N1 (high)
mov bl, al
and bl, 0x0F
mov [N0], bl                            ; Low nibble

mov bl, al
shr bl, 4
mov [N1], bl                            ; High nibble
```

### BCD (Binary Coded Decimal) Packing

**Pack two BCD digits into byte:**

```nasm
; Pack decimal digits D1 and D0 (0-9 each) into packed BCD
mov al, [D1]                            ; Tens digit
shl al, 4                               ; Move to high nibble
add al, [D0]                            ; Add ones digit
; AL = packed BCD (e.g., 59 = 0x59)
```

**Unpack packed BCD byte:**

```nasm
; Unpack AL (packed BCD) into two decimal digits
mov bl, al
shr bl, 4                               ; High nibble = tens
mov [D1], bl

mov bl, al
and bl, 0x0F                            ; Low nibble = ones
mov [D0], bl
```

**BCD arithmetic example:**

```nasm
; Add packed BCD numbers (with DAA correction)
mov al, 0x58                            ; 58 in BCD
add al, 0x27                            ; Add 27
daa                                     ; Decimal adjust (AL = 0x85 = 85)

; Subtract packed BCD (with DAS correction)
mov al, 0x58                            ; 58 in BCD
sub al, 0x27                            ; Subtract 27
das                                     ; Decimal adjust (AL = 0x31 = 31)
```

### Boolean Packing

**Pack eight boolean values into byte:**

```nasm
; Pack booleans B7..B0 (each 0 or 1) into AL
xor al, al                              ; Clear result
mov cl, [B7]
and cl, 1
shl cl, 7
or al, cl

mov cl, [B6]
and cl, 1
shl cl, 6
or al, cl

; ... continue for B5..B1

mov cl, [B0]
and cl, 1
or al, cl
; AL now has 8 booleans packed

; Loop-based approach
xor al, al
mov esi, boolean_array
mov ecx, 8
pack_loop:
    shl al, 1                           ; Make room for next bit
    mov bl, [esi]
    and bl, 1                           ; Ensure boolean (0 or 1)
    or al, bl                           ; Pack bit
    inc esi
    dec ecx
    jnz pack_loop
```

**Unpack byte into eight booleans:**

```nasm
; Unpack AL into booleans B7..B0
mov cl, al
shr cl, 7
mov [B7], cl

mov cl, al
shr cl, 6
and cl, 1
mov [B6], cl

; ... continue for B5..B1

mov cl, al
and cl, 1
mov [B0], cl

; Loop-based approach
mov esi, boolean_array
mov ecx, 8
mov bl, al
unpack_loop:
    mov dl, bl
    and dl, 1                           ; Extract bit 0
    mov [esi], dl
    shr bl, 1                           ; Shift to next bit
    inc esi
    dec ecx
    jnz unpack_loop
```

### Bit Array Operations

**Set bit in bit array:**

```nasm
; Set bit N in bit array
mov eax, N                              ; Bit index
mov ecx, eax
shr ecx, 3                              ; Divide by 8 (byte offset)
and eax, 7                              ; Modulo 8 (bit position)
mov bl, 1
shl bl, al                              ; Create bit mask
or [bit_array + ecx], bl                ; Set bit

; Using BTS instruction
mov eax, N
bts [bit_array], eax                    ; Set bit N in array
```

**Clear bit in bit array:**

```nasm
; Clear bit N in bit array
mov eax, N
mov ecx, eax
shr ecx, 3                              ; Byte offset
and eax, 7                              ; Bit position
mov bl, 1
shl bl, al
not bl                                  ; Invert mask
and [bit_array + ecx], bl               ; Clear bit

; Using BTR instruction
mov eax, N
btr [bit_array], eax                    ; Clear bit N
```

**Test bit in bit array:**

```nasm
; Test bit N in bit array
mov eax, N
mov ecx, eax
shr ecx, 3                              ; Byte offset
and eax, 7                              ; Bit position
mov bl, [bit_array + ecx]               ; Load byte
shr bl, al                              ; Shift bit to position 0
and bl, 1                               ; Isolate bit
test bl, bl                             ; Test if set
jnz bit_is_set

; Using BT instruction
mov eax, N
bt [bit_array], eax                     ; Test bit N (result in CF)
jc bit_is_set
```

### Pixel Format Conversion

**Convert RGB888 to RGB565:**

```nasm
; Input: R8, G8, B8 (8 bits each)
; Output: RGB565 in AX

movzx ax, byte [R8]
shr ax, 3                               ; Reduce to 5 bits
shl ax, 11                              ; Position in bits 15:11

movzx bx, byte [G8]
shr bx, 2                               ; Reduce to 6 bits
shl bx, 5                               ; Position in bits 10:5
or ax, bx

movzx bx, byte [B8]
shr bx, 3                               ; Reduce to 5 bits
or ax, bx                               ; Position in bits 4:0

; AX = RGB565 color
```

**Convert RGB565 to RGB888:**

```nasm
; Input: RGB565 in AX
; Output: R8, G8, B8

mov bx, ax
shr bx, 11                              ; Extract red (bits 15:11)
mov cl, bl
shl cl, 3                               ; Scale 5 bits to 8 bits
or cl, cl                               ; [Inference] Better scaling
shr bl, 2
or cl, bl                               ; Add lower bits for better precision
mov [R8], cl

mov bx, ax
shr bx, 5
and bx, 0x3F                            ; Extract green (bits 10:5)
mov cl, bl
shl cl, 2                               ; Scale 6 bits to 8 bits
shr bl, 4
or cl, bl                               ; Add lower bits
mov [G8], cl

mov bx, ax
and bx, 0x1F                            ; Extract blue (bits 4:0)
mov cl, bl
shl cl, 3                               ; Scale 5 bits to 8 bits
shr bl, 2
or cl, bl                               ; Add lower bits
mov [B8], cl
```

**Convert RGBA8888 to ARGB8888:**

```nasm
; Rearrange byte order: RGBA → ARGB
mov eax, [rgba_value]                   ; EAX = RRGGBBAA
rol eax, 8                              ; EAX = GGBBAARR
; Or using byte swaps
mov eax, [rgba_value]
bswap eax                               ; EAX = AABBGGRR
rol eax, 8                              ; EAX = AARRGGBB
```

### Data Compression Techniques

**Run-length encoding (simple bit packing):**

```nasm
; Pack count (5 bits) and value (3 bits) into byte
mov al, count_value
and al, 0x1F                            ; Ensure 5 bits
shl al, 3                               ; Position count in bits 7:3
mov bl, data_value
and bl, 0x07                            ; Ensure 3 bits
or al, bl                               ; Pack: [count:5][value:3]

; Unpack
mov bl, al
shr bl, 3                               ; Extract count (bits 7:3)
mov cl, al
and cl, 0x07                            ; Extract value (bits 2:0)
```

**Delta encoding (pack differences):**

```nasm
; Encode 8-bit value as 4-bit delta from previous
mov al, [current_value]
sub al, [previous_value]                ; Calculate delta
; Assuming delta fits in 4 bits (-8 to +7)
and al, 0x0F                            ; Keep 4 bits
; Pack two deltas into one byte
shl al, 4
or al, [next_delta]
```

### Flag Register Packing

**Pack multiple flags into single register:**

```nasm
section .data
    ; Define flag positions
    FL_INITIALIZED  equ 0x0001          ; Bit 0
    FL_CONNECTED    equ 0x0002          ; Bit 1
    FL_AUTHENTICATED equ 0x0004         ; Bit 2
    FL_ENCRYPTED    equ 0x0008          ; Bit 3
    FL_COMPRESSED   equ 0x0010          ; Bit 4
    FL_BUFFERED     equ 0x0020          ; Bit 5
    FL_ERROR        equ 0x0040          ; Bit 6
    FL_COMPLETE     equ 0x0080          ; Bit 7
    
    system_flags dw 0

section .text
    ; Set multiple flags
    or word [system_flags], FL_INITIALIZED | FL_CONNECTED
    
    ; Clear specific flag
    and word [system_flags], ~FL_ERROR
    
    ; Toggle flag
    xor word [system_flags], FL_BUFFERED
    
    ; Test if all required flags are set
    mov ax, [system_flags]
    and ax, FL_INITIALIZED | FL_CONNECTED | FL_AUTHENTICATED
    cmp ax, FL_INITIALIZED | FL_CONNECTED | FL_AUTHENTICATED
    je all_required_set
    
    ; Test if any error flags are set
    test word [system_flags], FL_ERROR
    jnz error_occurred
```

### Efficient Multi-Field Updates

**Atomic multi-field update:**

```nasm
; Update multiple fields atomically
; Structure: [flags:4][mode:2][priority:2][state:8]

; Prepare new value with multiple fields
xor eax, eax                            ; Clear

mov bl, new_flags
and bl, 0x0F                            ; 4 bits
shl ebx, 12                             ; Position at bits 15:12
or eax, ebx

mov bl, new_mode
and bl, 0x03                            ; 2 bits
shl ebx, 10                             ; Position at bits 11:10
or eax, ebx

mov bl, new_priority
and bl, 0x03                            ; 2 bits
shl ebx, 8                              ; Position at bits 9:8
or eax, ebx

mov bl, new_state                       ; 8 bits
or eax, ebx                             ; Position at bits 7:0

; Atomic update
mov [packed_status], ax                 ; Single write
```

**Selective field update preserving others:**

```nasm
; Update only priority field, preserve others
mov ax, [packed_status]
and ax, 0xFCFF                          ; Clear priority bits (9:8)
mov bx, new_priority
and bx, 0x03
shl bx, 8
or ax, bx
mov [packed_status], ax
```

### Endianness Conversion

**Swap byte order (16-bit):**

```nasm
; Convert between big-endian and little-endian (word)
mov ax, word_value
xchg al, ah                             ; Swap bytes
; Or
rol ax, 8                               ; Rotate bytes
```

**Swap byte order (32-bit):**

```nasm
; Convert between big-endian and little-endian (dword)
mov eax, dword_value
bswap eax                               ; Byte swap instruction
; EAX = byte-swapped value

; Manual method
mov eax, dword_value
mov ebx, eax
shr ebx, 24                             ; Byte 3 → position 0
and ebx, 0xFF
mov ecx, eax
shr ecx, 8
and ecx, 0xFF00                         ; Byte 1 → position 2
or ebx, ecx
mov ecx, eax
shl ecx, 8
and ecx, 0xFF0000                       ; Byte 2 → position 1
or ebx, ecx
shl eax, 24                             ; Byte 0 → position 3
or eax, ebx
```

**Swap byte order (64-bit):**

```nasm
; 64-bit mode
mov rax, qword_value
bswap rax                               ; Swap all 8 bytes

; 32-bit mode (using two registers)
mov eax, dword [value_low]
mov edx, dword [value_high]
bswap eax
bswap edx
; Now swap EAX and EDX
xchg eax, edx
mov dword [result_low], eax
mov dword [result_high], edx
```

### Bit Interleaving (Morton Codes)

**Interleave bits from two values (Z-order curve):**

```nasm
; Interleave 8-bit X and Y coordinates into 16-bit Morton code
; Result: Y7 X7 Y6 X6 Y5 X5 Y4 X4 Y3 X3 Y2 X2 Y1 X1 Y0 X0

movzx eax, byte [x_coord]              ; Load X
movzx ebx, byte [y_coord]              ; Load Y

; Spread bits of X (insert zeros between bits)
mov ecx, eax
and eax, 0x0001                         ; Bit 0
mov edx, ecx
and edx, 0x0002
shl edx, 1
or eax, edx                             ; Bits 0, 2

mov edx, ecx
and edx, 0x0004
shl edx, 2
or eax, edx                             ; Bits 0, 2, 4

; ... continue for all 8 bits
; [Inference] Complete bit spreading requires 8 iterations
; Result in EAX: X bits at even positions

; Spread bits of Y similarly
; Result in EBX: Y bits at even positions

; Interleave
shl ebx, 1                              ; Shift Y to odd positions
or eax, ebx                             ; Combine
; EAX = Morton code
```

**De-interleave Morton code:**

```nasm
; Extract X and Y from Morton code
mov eax, morton_code

; Extract X (even bits)
mov ebx, eax
and ebx, 0x5555                         ; Mask even bits: 0101010101010101
; Compact bits (remove gaps)
; [Inference] Requires bit compaction sequence

; Extract Y (odd bits)
mov ecx, eax
shr ecx, 1                              ; Shift odd bits to even positions
and ecx, 0x5555                         ; Mask
; Compact bits
```

**Key Points:**

- Bitwise operations (AND, OR, XOR, NOT) are fundamental for bit manipulation, with TEST providing non-destructive bit testing
- Shift operations multiply/divide by powers of 2, with SHL/SHR for unsigned and SAR preserving sign for signed values
- Rotate operations (ROL, ROR, RCL, RCR) move bits circularly, with carry variants enabling multi-precision operations
- Bit field extraction requires shifting to position 0 followed by masking; insertion requires clearing target bits then OR-ing positioned value
- x86 provides specialized instructions (BT, BTS, BTR, BTC, BSF, BSR) for efficient single-bit operations
- Packing multiple values reduces memory usage and can improve cache efficiency when accessing related data together
- Little-endian byte ordering requires attention when packing/unpacking multi-byte values across different systems
- Modern x86 extensions provide optimized instructions (POPCNT, LZCNT, TZCNT, BSWAP) for common bit manipulation patterns

---

