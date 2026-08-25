## Unions


Unions are data structures where all members share the same memory location, allowing different interpretations of the same memory space. Unlike structures where each field has its own offset, union members all start at offset 0.

### Memory Layout

In a union, the size is determined by the largest member. All members overlap in memory, enabling type punning and efficient memory usage when only one member is active at a time.

```nasm
; Union definition concept (pseudo-code representation)
; union MyUnion {
;     int32_t integer;    // 4 bytes
;     float floating;     // 4 bytes
;     char bytes[4];      // 4 bytes
; }
; Total size: 4 bytes (size of largest member)

section .data
    my_union: dd 0x42C80000    ; Can be interpreted as int or float

section .text
    ; Accessing as integer
    mov eax, [my_union]        ; EAX = 0x42C80000
    
    ; Accessing as float
    movss xmm0, [my_union]     ; XMM0 = 100.5 (float interpretation)
    
    ; Accessing as byte array
    mov al, [my_union]         ; AL = 0x00 (first byte)
    mov al, [my_union + 1]     ; AL = 0x80 (second byte)
```

### Practical Applications

Type conversion and reinterpretation without actual conversion instructions:

```nasm
section .data
    value: dd 0x3F800000       ; IEEE 754 for 1.0

section .text
    ; Extract sign, exponent, mantissa from float
    mov eax, [value]           ; Treat float as integer
    mov ebx, eax
    and ebx, 0x80000000        ; Extract sign bit
    shr ebx, 31
    
    mov ecx, eax
    and ecx, 0x7F800000        ; Extract exponent
    shr ecx, 23
    
    and eax, 0x007FFFFF        ; Extract mantissa
```

Network protocol parsing using unions:

```nasm
section .bss
    packet_union: resb 64      ; Union of different packet types

section .text
    ; First byte determines packet type
    mov al, [packet_union]
    cmp al, 1
    je .handle_type1
    cmp al, 2
    je .handle_type2
    
.handle_type1:
    ; Interpret as Type1 packet structure
    mov eax, [packet_union + 4]    ; Field at offset 4 for Type1
    jmp .done
    
.handle_type2:
    ; Interpret as Type2 packet structure
    movzx eax, word [packet_union + 2]  ; Field at offset 2 for Type2
    
.done:
```

### Endianness Handling

Unions facilitate byte order manipulation:

```nasm
section .data
    endian_union: dd 0x12345678

section .text
    ; Read as big-endian bytes
    mov al, [endian_union + 3]     ; AL = 0x12 (most significant)
    mov ah, [endian_union + 2]     ; AH = 0x34
    shl eax, 16
    mov al, [endian_union + 1]     ; AL = 0x56
    mov ah, [endian_union]         ; AH = 0x78 (least significant)
    ; EAX now contains byte-swapped value
```

