## Shift Operations


### Logical Shift Left (SHL/SAL)

Shifts bits left, filling with zeros from the right. The leftmost bit shifts into the Carry Flag.

```nasm
shl dest, count                         ; dest = dest << count
sal dest, count                         ; Same as SHL
```

**Behavior:**

```
Before: 10110101
SHL 1:  01101010  (CF = 1, bit shifted out)
SHL 2:  10101000  (CF = 0)
```

**Common applications:**

```nasm
; Multiply by powers of 2
mov eax, 10
shl eax, 1                              ; EAX = 20 (× 2)
shl eax, 2                              ; EAX = 80 (× 4)
shl eax, 3                              ; EAX = 640 (× 8)

; Calculate array element offset
mov eax, index                          ; Array index
shl eax, 2                              ; Multiply by 4 (dword size)
mov ebx, [array + eax]                  ; Access array[index]

; Combine bytes into larger value
xor eax, eax
mov al, byte1
shl eax, 8                              ; Make room for next byte
or al, byte2
shl eax, 8
or al, byte3
shl eax, 8
or al, byte4                            ; EAX now contains 4-byte value

; Fast power of 2 calculation
mov eax, 1
mov cl, power                           ; CL = exponent
shl eax, cl                             ; EAX = 2^power

; Align value up to next power of 2
mov eax, size
dec eax
or eax, eax
shl eax, 1
or eax, 1                               ; [Inference] This pattern is incomplete
; More reliable power-of-2 rounding uses different technique

; Extract and position bit fields
mov al, [flags]
and al, 0x0F                            ; Extract lower 4 bits
shl al, 4                               ; Shift to upper position
```

### Logical Shift Right (SHR)

Shifts bits right, filling with zeros from the left. The rightmost bit shifts into the Carry Flag.

```nasm
shr dest, count                         ; dest = dest >> count (unsigned)
```

**Behavior:**

```
Before: 10110101
SHR 1:  01011010  (CF = 1)
SHR 2:  00101101  (CF = 0)
```

**Common applications:**

```nasm
; Unsigned division by powers of 2
mov eax, 100
shr eax, 1                              ; EAX = 50 (÷ 2)
shr eax, 2                              ; EAX = 12 (÷ 4, rounded down)

; Extract high byte from word
mov ax, 0x1234
mov bx, ax
shr bx, 8                               ; BX = 0x0012

; Convert pixel format (RGB565 to separate components)
mov ax, pixel_rgb565                    ; 16-bit: RRRRRGGG GGGBBBBB
mov bx, ax
shr bx, 11                              ; BX = Red (5 bits)
mov cx, ax
shr cx, 5
and cx, 0x3F                            ; CX = Green (6 bits)
and ax, 0x1F                            ; AX = Blue (5 bits)

; Divide coordinates by tile size
mov eax, pixel_x
shr eax, 4                              ; Divide by 16 (tile width)
mov ebx, pixel_y
shr ebx, 4                              ; Divide by 16 (tile height)

; Fast modulo power of 2 (get remainder)
mov eax, value
mov ebx, eax
shr ebx, 5                              ; Divide by 32
shl ebx, 5                              ; Multiply by 32
sub eax, ebx                            ; EAX = value % 32
```

### Arithmetic Shift Right (SAR)

Shifts bits right, preserving the sign bit (fills with copies of the sign bit from the left).

```nasm
sar dest, count                         ; dest = dest >> count (signed)
```

**Behavior:**

```
Positive: 01011010
SAR 1:    00101101  (Sign bit 0 preserved)

Negative: 10110101
SAR 1:    11011010  (Sign bit 1 preserved)
```

**Common applications:**

```nasm
; Signed division by powers of 2
mov eax, -100
sar eax, 1                              ; EAX = -50 (÷ 2)
sar eax, 2                              ; EAX = -13 (÷ 4, rounds toward -∞)

; Sign extension alternative for small shifts
movsx eax, byte_value                   ; Sign extend byte to dword
sar eax, 3                              ; Signed divide by 8

; Average of two values (avoiding overflow)
mov eax, value1
mov ebx, value2
add eax, ebx
sar eax, 1                              ; Average (signed)

; Scale signed fixed-point numbers
mov eax, fixed_point_value              ; 16.16 fixed point
sar eax, 16                             ; Get integer part (signed)
```

### Double Precision Shift (SHLD/SHRD)

Shifts bits between two operands, useful for multi-precision arithmetic and bit field extraction.

```nasm
shld dest, source, count                ; Shift dest left, fill from source
shrd dest, source, count                ; Shift dest right, fill from source
```

**Behavior of SHLD:**

```
Dest:   10110101 ← Source: 11001100
SHLD 3: 10101110  (3 bits from source shifted in)
```

**Common applications:**

```nasm
; Extract bit field spanning byte boundary
mov ax, [data]                          ; Load 16 bits
mov dx, [data + 2]                      ; Load next 16 bits
shrd ax, dx, 5                          ; Extract 11 bits at offset 5

; 64-bit shift using 32-bit registers
; Shift EDX:EAX left by CL bits
shld edx, eax, cl                       ; High part
shl eax, cl                             ; Low part

; Shift EDX:EAX right by CL bits
shrd eax, edx, cl                       ; Low part
shr edx, cl                             ; High part

; Bit field insertion spanning boundary
mov ax, [target]
mov dx, [target + 2]
mov bx, field_value
shld dx, ax, 5                          ; Position for insertion
mov ax, bx
shld dx, ax, 11                         ; Insert 11-bit field
mov [target], ax
mov [target + 2], dx

; Efficient rotate by fixed amount
mov eax, value
mov edx, eax
shrd eax, edx, 5                        ; Rotate right by 5
```

