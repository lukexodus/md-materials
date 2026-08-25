## Structures and Records


### Structure Definition

Structures group related data items under a single name. In assembly, structures are defined using directives that calculate member offsets.

**NASM structure syntax:**

```nasm
struc Person
    .name:      resb 32                 ; 32 bytes for name
    .age:       resd 1                  ; 4 bytes for age
    .height:    resd 1                  ; 4 bytes for height
    .weight:    resd 1                  ; 4 bytes for weight
    .size:                              ; Total structure size
endstruc
```

**MASM structure syntax:**

```nasm
Person struct
    name    db 32 dup(?)                ; 32 bytes
    age     dd ?                        ; 4 bytes
    height  dd ?                        ; 4 bytes  
    weight  dd ?                        ; 4 bytes
Person ends
```

### Structure Member Access

**Declaring structure instances:**

```nasm
section .data
    person1:
        istruc Person
            at Person.name, db "John Doe", 0
            at Person.age, dd 30
            at Person.height, dd 175
            at Person.weight, dd 70
        iend

section .bss
    person2: resb Person.size           ; Uninitialized structure
```

**Accessing members:**

```nasm
    ; Load structure base address
    mov esi, person1
    
    ; Access members using offset
    mov eax, [esi + Person.age]         ; EAX = 30
    mov ebx, [esi + Person.height]      ; EBX = 175
    
    ; Modify members
    mov dword [esi + Person.weight], 72
    
    ; Copy name field
    lea edi, [esi + Person.name]
    mov byte [edi], 'J'
```

### Structure Offset Calculation

The assembler calculates member offsets automatically based on data type sizes and alignment:

```nasm
; Assuming no padding:
; Person.name = 0      (offset 0, size 32)
; Person.age = 32      (offset 32, size 4)
; Person.height = 36   (offset 36, size 4)
; Person.weight = 40   (offset 40, size 4)
; Person.size = 44     (total size)
```

### Structure Alignment and Padding

Processors often require or prefer data to be aligned on natural boundaries. Compilers may insert padding bytes to ensure proper alignment.

**Unaligned structure:**

```nasm
struc Unaligned
    .byte1:     resb 1                  ; Offset 0
    .dword1:    resd 1                  ; Offset 1 (misaligned!)
    .byte2:     resb 1                  ; Offset 5
    .word1:     resw 1                  ; Offset 6 (misaligned!)
    .size:
endstruc
; Total size: 8 bytes
```

**Aligned structure with explicit padding:**

```nasm
struc Aligned
    .byte1:     resb 1                  ; Offset 0
    .pad1:      resb 3                  ; Padding to align next member
    .dword1:    resd 1                  ; Offset 4 (aligned)
    .byte2:     resb 1                  ; Offset 8
    .pad2:      resb 1                  ; Padding
    .word1:     resw 1                  ; Offset 10 (aligned)
    .size:
endstruc
; Total size: 12 bytes
```

**Using ALIGN directive:**

```nasm
struc AlignedAuto
    .byte1:     resb 1
    align 4
    .dword1:    resd 1
    .byte2:     resb 1
    align 2
    .word1:     resw 1
    .size:
endstruc
```

### Nested Structures

Structures can contain other structures as members:

```nasm
struc Point
    .x: resd 1
    .y: resd 1
    .size:
endstruc

struc Rectangle
    .top_left:      resb Point.size     ; Nested structure
    .bottom_right:  resb Point.size     ; Nested structure
    .color:         resd 1
    .size:
endstruc

section .bss
    rect: resb Rectangle.size

section .text
    ; Access nested members
    mov esi, rect
    mov dword [esi + Rectangle.top_left + Point.x], 10
    mov dword [esi + Rectangle.top_left + Point.y], 20
    mov dword [esi + Rectangle.bottom_right + Point.x], 100
    mov dword [esi + Rectangle.bottom_right + Point.y], 150
```

### Array of Structures

```nasm
struc Student
    .id:        resd 1
    .name:      resb 20
    .grade:     resd 1
    .size:
endstruc

section .bss
    students: resb Student.size * 10    ; Array of 10 students

section .text
    ; Access student[3].grade
    mov esi, students
    mov eax, 3                          ; Index
    mov ebx, Student.size
    imul eax, ebx                       ; Calculate offset
    mov ecx, [esi + eax + Student.grade]
    
    ; Alternative with LEA
    lea esi, [students + eax + Student.grade]
    mov ecx, [esi]
```

### Structure Manipulation Functions

**Structure copy:**

```nasm
copy_person:
    push esi
    push edi
    push ecx
    
    mov esi, [esp + 16]                 ; Source structure
    mov edi, [esp + 20]                 ; Dest structure
    mov ecx, Person.size / 4            ; Size in dwords
    cld
    rep movsd                           ; Copy structure
    
    pop ecx
    pop edi
    pop esi
    ret
```

**Structure initialization:**

```nasm
init_person:
    push edi
    mov edi, [esp + 8]                  ; Structure pointer
    
    ; Zero the entire structure
    xor eax, eax
    mov ecx, Person.size / 4
    cld
    rep stosd
    
    ; Set default values
    mov edi, [esp + 8]
    mov dword [edi + Person.age], 0
    mov dword [edi + Person.height], 0
    mov dword [edi + Person.weight], 0
    
    pop edi
    ret
```

### Bitfields and Records

Records (bitfields) pack multiple boolean or small integer values into a single register or memory location.

**Manual bitfield manipulation:**

```nasm
; Define bit positions for flags
FLAG_ACTIVE     equ 0x01                ; Bit 0
FLAG_VISIBLE    equ 0x02                ; Bit 1
FLAG_ENABLED    equ 0x04                ; Bit 2
FLAG_SELECTED   equ 0x08                ; Bit 3

section .bss
    object_flags: resb 1

section .text
    ; Set flag
    mov al, [object_flags]
    or al, FLAG_ACTIVE
    mov [object_flags], al
    
    ; Clear flag
    mov al, [object_flags]
    and al, ~FLAG_VISIBLE
    mov [object_flags], al
    
    ; Toggle flag
    mov al, [object_flags]
    xor al, FLAG_ENABLED
    mov [object_flags], al
    
    ; Test flag
    mov al, [object_flags]
    test al, FLAG_SELECTED
    jnz is_selected
```

**Multi-bit field extraction:**

```nasm
; Packed fields: [reserved:16][type:4][priority:4][flags:8]
; in a 32-bit dword

section .data
    packed_data dd 0x00001234           ; type=1, priority=2, flags=0x34

section .text
    mov eax, [packed_data]
    
    ; Extract flags (bits 0-7)
    mov ebx, eax
    and ebx, 0xFF                       ; EBX = 0x34
    
    ; Extract priority (bits 8-11)
    mov ecx, eax
    shr ecx, 8
    and ecx, 0x0F                       ; ECX = 2
    
    ; Extract type (bits 12-15)
    mov edx, eax
    shr edx, 12
    and edx, 0x0F                       ; EDX = 1
```

**Bitfield insertion:**

```nasm
; Set priority field to 5
    mov eax, [packed_data]
    and eax, 0xFFFFF0FF                 ; Clear priority bits
    or eax, (5 << 8)                    ; Set new priority
    mov [packed_data], eax
```

### Structure Packing Pragmas

Different assemblers and calling conventions may require specific packing:

```nasm
; MASM - align members on 1-byte boundaries
Person struct 1
    name    db 32 dup(?)
    age     dd ?
    active  db ?
Person ends

; NASM - use explicit alignment
%pragma pack 1
struc Person
    .name:      resb 32
    .age:       resd 1
    .active:    resb 1
    .size:
endstruc
%pragma pack 0
```

### Union-like Structures

Unions allow multiple interpretations of the same memory location:

```nasm
section .bss
    value: resd 1                       ; 4-byte storage

section .text
    ; Can be accessed as:
    ; - dword at offset 0
    ; - word at offset 0 and offset 2
    ; - bytes at offset 0, 1, 2, 3
    
    mov dword [value], 0x12345678
    mov ax, word [value]                ; AX = 0x5678 (little-endian)
    mov al, byte [value]                ; AL = 0x78
    mov ah, byte [value + 1]            ; AH = 0x56
```

**Example: IP address union:**

```nasm
section .bss
    ip_address:
        .dword: resd 1                  ; 32-bit representation
    
section .text
    ; Set IP 192.168.1.1
    mov dword [ip_address], 0xC0A80101
    
    ; Access individual octets
    mov al, byte [ip_address]           ; AL = 1
    mov al, byte [ip_address + 1]       ; AL = 1
    mov al, byte [ip_address + 2]       ; AL = 168
    mov al, byte [ip_address + 3]       ; AL = 192
```

**Key Points:**

- Data types in x86 range from 8-bit bytes to 64-bit qwords, each with specific register and memory access patterns
- Array access uses base-plus-scaled-index addressing with automatic multiplication by element size (scale factors: 1, 2, 4, 8)
- String operations use specialized instructions (MOVS, STOS, LODS, SCAS, CMPS) with automatic index register updates controlled by the Direction Flag
- Structures group related data with compiler-calculated member offsets, requiring attention to alignment for optimal performance
- Records/bitfields pack multiple values into single memory locations using bitwise operations for manipulation
- Little-endian byte ordering affects multi-byte value storage and access patterns
- x86 string primitives provide hardware-accelerated bulk memory operations when combined with REP prefixes

