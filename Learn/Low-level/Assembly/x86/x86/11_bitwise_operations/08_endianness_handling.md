## Endianness Handling


Endianness refers to the byte order used to store multibyte values in memory. x86 is little-endian (least significant byte at lowest address).

### Byte Order Conversion

**16-bit swap:**

```nasm
section .text
    ; Method 1: Using XCHG
    mov ax, 0x1234             ; AX = 0x1234
    xchg al, ah                ; AX = 0x3412
    
    ; Method 2: Using ROL/ROR
    mov ax, 0x1234
    rol ax, 8                  ; Rotate left by 8 bits
    ; AX = 0x3412
    
    ; Method 3: Using shifts
    mov ax, 0x1234
    mov bx, ax
    shl ax, 8                  ; AX = 0x3400
    shr bx, 8                  ; BX = 0x0012
    or ax, bx                  ; AX = 0x3412
```

**32-bit swap (BSWAP):**

```nasm
section .text
    ; Hardware instruction (486+)
    mov eax, 0x12345678        ; Little-endian
    bswap eax                  ; EAX = 0x78563412 (big-endian)
    
    ; Manual method for older CPUs
    mov eax, 0x12345678
    mov ebx, eax
    rol eax, 8                 ; EAX = 0x34567812
    ror ebx, 8                 ; EBX = 0x78123456
    mov edx, eax
    and eax, 0x00FF00FF        ; EAX = 0x00560012
    and ebx, 0x00FF00FF        ; EBX = 0x00120078
    shl eax, 8                 ; EAX = 0x56001200
    shl ebx, 8                 ; EBX = 0x12007800
    or eax, ebx                ; EAX = 0x78563412
```

**64-bit swap:**

```nasm
section .text
    ; 64-bit BSWAP
    mov rax, 0x123456789ABCDEF0
    bswap rax                  ; RAX = 0xF0DEBC9A78563412
```

### Network Byte Order Conversion

Network protocols use big-endian (network byte order), while x86 uses little-endian (host byte order).

```nasm
section .text
    ; htons (host to network short) - 16-bit
htons:
    mov ax, di                 ; Parameter in DI (System V x86-64)
    xchg al, ah
    ret
    
    ; htonl (host to network long) - 32-bit
htonl:
    mov eax, edi               ; Parameter in EDI
    bswap eax
    ret
    
    ; htonll (host to network long long) - 64-bit
htonll:
    mov rax, rdi               ; Parameter in RDI
    bswap rax
    ret
    
    ; ntohs, ntohl, ntohll are identical (conversion is symmetric)
```

### Reading Multi-byte Values

**Little-endian read (native x86):**

```nasm
section .data
    bytes: db 0x12, 0x34, 0x56, 0x78

section .text
    ; Direct read (little-endian interpretation)
    mov eax, [bytes]           ; EAX = 0x78563412
    
    ; Byte-by-byte construction
    movzx eax, byte [bytes]    ; EAX = 0x00000012
    movzx ebx, byte [bytes+1]
    shl ebx, 8
    or eax, ebx                ; EAX = 0x00003412
    movzx ebx, byte [bytes+2]
    shl ebx, 16
    or eax, ebx                ; EAX = 0x00563412
    movzx ebx, byte [bytes+3]
    shl ebx, 24
    or eax, ebx                ; EAX = 0x78563412
```

**Big-endian read:**

```nasm
section .data
    be_bytes: db 0x12, 0x34, 0x56, 0x78  ; Big-endian representation

section .text
    ; Read and convert to native (little-endian)
    mov eax, [be_bytes]
    bswap eax                  ; EAX = 0x12345678 (correct value)
    
    ; Byte-by-byte big-endian read
    movzx eax, byte [be_bytes+3]  ; Start from last byte
    movzx ebx, byte [be_bytes+2]
    shl ebx, 8
    or eax, ebx
    movzx ebx, byte [be_bytes+1]
    shl ebx, 16
    or eax, ebx
    movzx ebx, byte [be_bytes]
    shl ebx, 24
    or eax, ebx                ; EAX = 0x12345678
```

### SIMD Byte Shuffling

```nasm
section .data
    align 16
    shuffle_mask: db 3,2,1,0, 7,6,5,4, 11,10,9,8, 15,14,13,12

section .text
    ; Swap endianness of four 32-bit integers simultaneously
    movdqa xmm0, [input_data]      ; Load 16 bytes
    movdqa xmm1, [shuffle_mask]
    pshufb xmm0, xmm1              ; Shuffle bytes
    movdqa [output_data], xmm0     ; Store swapped values
```

### Endian-Independent Bit Fields

```nasm
section .text
    ; Extract bits 12-15 regardless of endianness
    mov eax, [value]
    shr eax, 12                ; Shift right by position
    and eax, 0x0F              ; Mask to get 4 bits
    
    ; Set bits 8-11 regardless of endianness
    mov ebx, [value]
    and ebx, 0xFFFFF0FF        ; Clear bits 8-11
    mov ecx, 0x05              ; New value for bits 8-11
    shl ecx, 8
    or ebx, ecx                ; Set new bits
    mov [value], ebx
```

