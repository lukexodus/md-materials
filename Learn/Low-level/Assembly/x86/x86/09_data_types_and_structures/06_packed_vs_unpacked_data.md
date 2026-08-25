## Packed vs Unpacked Data


### Unpacked Data

Unpacked data stores each logical unit in a naturally sized container, often wasting space for clarity and ease of access.

**ASCII Decimal (Unpacked BCD):**

```nasm
section .data
    ; Unpacked BCD: one digit per byte
    unpacked_num: db 0x05, 0x09, 0x03    ; Represents 593
    
section .text
    ; Addition of unpacked BCD digits
    mov al, [unpacked_num + 2]     ; AL = 0x03
    add al, 0x07                    ; AL = 0x0A
    aaa                             ; ASCII Adjust After Addition
    ; AL = 0x00, AH incremented (carry)
```

**Character Arrays:**

```nasm
section .data
    ; Each character uses full byte, inefficient for limited charset
    flags: db 'Y', 'N', 'Y', 'Y', 'N'    ; 5 bytes for 5 boolean values
```

### Packed Data

Packed data maximizes space efficiency by storing multiple logical units within a single storage unit.

**Packed BCD (Binary Coded Decimal):**

```nasm
section .data
    ; Packed BCD: two digits per byte
    packed_num: db 0x59, 0x30    ; Represents 5930
    
section .text
    ; Addition of packed BCD
    mov al, [packed_num]         ; AL = 0x59
    add al, 0x27                 ; AL = 0x80 (invalid BCD)
    daa                          ; Decimal Adjust After Addition
    ; AL = 0x86 (corrected BCD)
```

**Bit Fields:**

```nasm
section .data
    ; Pack 8 boolean flags into 1 byte
    status_flags: db 0b10110010    ; 8 flags in 1 byte
    
section .text
    ; Test bit 5
    mov al, [status_flags]
    test al, 0b00100000           ; Test bit 5
    jnz .bit5_is_set
    
    ; Set bit 3
    or byte [status_flags], 0b00001000
    
    ; Clear bit 7
    and byte [status_flags], 0b01111111
    
    ; Toggle bit 2
    xor byte [status_flags], 0b00000100
```

**Packed Pixel Data:**

```nasm
section .data
    ; RGB565: 16-bit packed pixel (5 bits red, 6 bits green, 5 bits blue)
    pixel: dw 0b1111100000000000    ; Red=31, Green=0, Blue=0
    
section .text
    ; Extract RGB components
    mov ax, [pixel]
    mov bx, ax
    mov cx, ax
    
    ; Extract red (bits 15-11)
    shr ax, 11
    and ax, 0x1F               ; Red component (0-31)
    
    ; Extract green (bits 10-5)
    shr bx, 5
    and bx, 0x3F               ; Green component (0-63)
    
    ; Extract blue (bits 4-0)
    and cx, 0x1F               ; Blue component (0-31)
```

**Nibble Packing:**

```nasm
section .data
    ; Two 4-bit values in one byte
    packed_nibbles: db 0xA5    ; High nibble = 0xA, Low nibble = 0x5

section .text
    mov al, [packed_nibbles]
    
    ; Extract high nibble
    mov bl, al
    shr bl, 4                  ; BL = 0x0A
    
    ; Extract low nibble
    mov cl, al
    and cl, 0x0F               ; CL = 0x05
    
    ; Pack two nibbles
    mov al, 0x03               ; Low nibble
    mov ah, 0x07               ; High nibble
    shl ah, 4                  ; AH = 0x70
    or al, ah                  ; AL = 0x73
```

### Performance Considerations

**Unpacked advantages:**

- Direct access without bit manipulation
- Faster for frequently accessed individual elements
- Simpler code, fewer CPU cycles per access

**Packed advantages:**

- Better cache utilization (more data per cache line)
- Reduced memory bandwidth usage
- Bulk operations can be more efficient with SIMD

```nasm
; SIMD packed operations example
section .data
    align 16
    packed_bytes: times 16 db 0x01    ; 16 bytes packed together

section .text
    ; Process 16 bytes simultaneously
    movdqa xmm0, [packed_bytes]
    paddb xmm0, xmm0               ; Add each byte to itself
    movdqa [packed_bytes], xmm0    ; Store back 16 results
```

