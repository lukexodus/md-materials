## Strings and String Operations


### String Representation

Strings in x86 assembly are typically represented as:

- **Null-terminated strings (C-style):** Sequence of bytes ending with 0x00
- **Length-prefixed strings (Pascal-style):** First byte/word contains length
- **Bounded strings:** Fixed-size buffer with explicit length parameter

### String Primitives

x86 provides dedicated string instructions that automatically update index registers:

**Direction Flag (DF):**

- `CLD` - Clear Direction Flag (increment - forward)
- `STD` - Set Direction Flag (decrement - backward)

**Register conventions:**

- **ESI/RSI:** Source index (points to source string)
- **EDI/RDI:** Destination index (points to destination string)
- **ECX/RCX:** Count register (number of operations)
- **AL/AX/EAX/RAX:** Accumulator (for scan/compare operations)

### Move String Operations

**MOVSB/MOVSW/MOVSD/MOVSQ** - Move string data:

```nasm
section .data
    source db "Hello, World!", 0
    
section .bss
    dest resb 20

section .text
    ; Copy string byte by byte
    mov esi, offset source
    mov edi, offset dest
    mov ecx, 13                         ; Character count
    cld                                 ; Forward direction
    rep movsb                           ; Repeat ECX times
```

**Each MOVS variant:**

- `MOVSB` - Move byte (ESI/EDI increment/decrement by 1)
- `MOVSW` - Move word (ESI/EDI increment/decrement by 2)
- `MOVSD` - Move dword (ESI/EDI increment/decrement by 4)
- `MOVSQ` - Move qword (ESI/EDI increment/decrement by 8, 64-bit mode only)

### Store String Operations

**STOSB/STOSW/STOSD/STOSQ** - Store AL/AX/EAX/RAX to string:

```nasm
section .bss
    buffer resb 100

section .text
    ; Fill buffer with spaces (0x20)
    mov edi, offset buffer
    mov al, 0x20                        ; Space character
    mov ecx, 100                        ; Count
    cld
    rep stosb                           ; Fill 100 bytes
```

**Use case - Zero initialization:**

```nasm
    mov edi, offset memory_block
    xor eax, eax                        ; Zero value
    mov ecx, 256                        ; 256 dwords = 1KB
    rep stosd                           ; Fast zero fill
```

### Load String Operations

**LODSB/LODSW/LODSD/LODSQ** - Load string into AL/AX/EAX/RAX:

```nasm
    mov esi, offset string
    cld

read_loop:
    lodsb                               ; Load byte from [ESI] into AL, ESI++
    test al, al                         ; Check for null terminator
    jz done
    ; Process character in AL
    jmp read_loop

done:
```

### Scan String Operations

**SCASB/SCASW/SCASD/SCASQ** - Scan string for value in AL/AX/EAX/RAX:

```nasm
    ; Find null terminator (string length)
    mov edi, offset string
    xor al, al                          ; Search for 0x00
    mov ecx, 0xFFFFFFFF                 ; Maximum count
    cld
    repne scasb                         ; Repeat while not equal
    not ecx                             ; Invert count
    dec ecx                             ; ECX now contains string length
```

**Finding a character:**

```nasm
    mov edi, offset string
    mov al, 'e'                         ; Search for 'e'
    mov ecx, string_length
    cld
    repne scasb
    jne not_found
    dec edi                             ; EDI now points to 'e'
```

### Compare String Operations

**CMPSB/CMPSW/CMPSD/CMPSQ** - Compare strings:

```nasm
    ; Compare two strings
    mov esi, offset string1
    mov edi, offset string2
    mov ecx, length
    cld
    repe cmpsb                          ; Repeat while equal
    je strings_equal                    ; If ECX=0 and ZF=1, strings match
    
    ; Flags after CMPS indicate relationship:
    ; JA - string1 > string2 (unsigned)
    ; JB - string1 < string2 (unsigned)
```

### String Operation Prefixes

**REP** - Repeat while ECX > 0:

```nasm
rep movsb    ; Copy ECX bytes
rep stosd    ; Fill ECX dwords
```

**REPE/REPZ** - Repeat while equal/zero (ZF=1) and ECX > 0:

```nasm
repe cmpsb   ; Compare while bytes match
repz scasb   ; Scan while bytes equal AL
```

**REPNE/REPNZ** - Repeat while not equal/not zero (ZF=0) and ECX > 0:

```nasm
repne scasb  ; Scan until byte equals AL
```

### Practical String Functions

**String length (C-style null-terminated):**

```nasm
strlen:
    push edi
    mov edi, [esp + 8]                  ; Get string pointer
    xor al, al
    mov ecx, 0xFFFFFFFF
    cld
    repne scasb
    not ecx
    dec ecx                             ; ECX = length
    mov eax, ecx                        ; Return length in EAX
    pop edi
    ret
```

**String copy:**

```nasm
strcpy:
    push esi
    push edi
    mov edi, [esp + 12]                 ; Destination
    mov esi, [esp + 16]                 ; Source
    cld

copy_loop:
    lodsb                               ; Load byte from source
    stosb                               ; Store to destination
    test al, al                         ; Check for null
    jnz copy_loop
    
    pop edi
    pop esi
    ret
```

**String compare:**

```nasm
strcmp:
    push esi
    push edi
    mov esi, [esp + 12]                 ; String 1
    mov edi, [esp + 16]                 ; String 2
    cld

cmp_loop:
    lodsb                               ; Load from string1
    scasb                               ; Compare with string2
    jne not_equal                       ; If different, exit
    test al, al                         ; Check for null
    jnz cmp_loop
    
    xor eax, eax                        ; Strings equal, return 0
    jmp cmp_done

not_equal:
    sbb eax, eax                        ; EAX = -1 if below, 0 if above
    or eax, 1                           ; EAX = -1 if below, 1 if above

cmp_done:
    pop edi
    pop esi
    ret
```

