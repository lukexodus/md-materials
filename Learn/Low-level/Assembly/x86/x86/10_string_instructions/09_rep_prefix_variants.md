## REP Prefix Variants


The REP prefix automates string instruction repetition, eliminating the need for explicit loops. The prefix uses ECX/RCX as a counter.

### REP (Repeat While ECX Not Zero)

REP repeats the string instruction ECX times. Used with MOVS, STOS, and LODS.

**Syntax:**

```nasm
REP MOVSB    ; Repeat MOVSB while ECX != 0
REP STOSW    ; Repeat STOSW while ECX != 0
REP LODSD    ; Repeat LODSD while ECX != 0
```

**Operation:**

1. If ECX = 0, terminate
2. Execute the string instruction
3. Decrement ECX
4. Repeat from step 1

**Example (memory copy with REP MOVSB):**

```nasm
section .data
    source db 'Copy this string', 0
    source_len equ $ - source
    
section .bss
    dest resb 100
    
section .text
copy_string:
    cld
    lea esi, [source]
    lea edi, [dest]
    mov ecx, source_len
    rep movsb            ; Copy ECX bytes from ESI to EDI
    ret
```

**Example (filling memory with REP STOSD):**

```nasm
section .bss
    buffer resd 10000
    
section .text
fill_buffer:
    cld
    lea edi, [buffer]
    mov eax, 0xDEADBEEF  ; Pattern to fill
    mov ecx, 10000       ; Number of dwords
    rep stosd            ; Fill 10000 dwords with 0xDEADBEEF
    ret
```

### REPE/REPZ (Repeat While Equal/Zero)

REPE (REPeat while Equal) and REPZ (REPeat while Zero) are synonyms. They repeat the instruction while ECX ≠ 0 AND the Zero Flag (ZF) = 1. Used with CMPS and SCAS.

**Syntax:**

```nasm
REPE CMPSB   ; Repeat while ECX != 0 and ZF = 1
REPZ SCASB   ; Repeat while ECX != 0 and ZF = 1
```

**Operation:**

1. If ECX = 0, terminate
2. Execute the string instruction
3. Decrement ECX
4. If ZF = 0, terminate
5. Repeat from step 1

**Example (comparing strings):**

```nasm
section .data
    str1 db 'hello', 0
    str2 db 'hello', 0
    str3 db 'world', 0
    len equ 5
    
section .text
compare_strings:
    cld
    lea esi, [str1]
    lea edi, [str2]
    mov ecx, len
    repe cmpsb           ; Compare while equal
    je strings_equal     ; If ZF=1, strings are equal
    
strings_not_equal:
    ; Strings differ
    mov eax, 0
    ret
    
strings_equal:
    ; Strings are identical
    mov eax, 1
    ret
```

**Example (finding string length with REPNE SCASB):**

```nasm
section .data
    mystring db 'Calculate my length', 0
    
section .text
string_length:
    cld
    lea edi, [mystring]
    mov al, 0            ; Search for null terminator
    mov ecx, 0xFFFFFFFF  ; Maximum possible length
    repne scasb          ; Scan while not equal to 0
    
    ; ECX now contains (0xFFFFFFFF - length - 1)
    not ecx              ; Invert bits
    dec ecx              ; Adjust for null terminator
    mov eax, ecx         ; Return length
    ret
```

### REPNE/REPNZ (Repeat While Not Equal/Not Zero)

REPNE (REPeat while Not Equal) and REPNZ (REPeat while Not Zero) are synonyms. They repeat the instruction while ECX ≠ 0 AND the Zero Flag (ZF) = 0. Used with CMPS and SCAS.

**Syntax:**

```nasm
REPNE CMPSB  ; Repeat while ECX != 0 and ZF = 0
REPNZ SCASB  ; Repeat while ECX != 0 and ZF = 0
```

**Operation:**

1. If ECX = 0, terminate
2. Execute the string instruction
3. Decrement ECX
4. If ZF = 1, terminate
5. Repeat from step 1

**Example (searching for character in string):**

```nasm
section .data
    haystack db 'Search in this string', 0
    needle db 'i'
    len equ 21
    
section .text
find_character:
    cld
    lea edi, [haystack]
    mov al, [needle]     ; Character to find
    mov ecx, len
    repne scasb          ; Scan while not equal
    
    jne not_found        ; If ZF=0, character not found
    
found:
    ; EDI points one byte past the found character
    sub edi, haystack
    dec edi              ; Adjust to point at character
    mov eax, edi         ; Return position
    ret
    
not_found:
    mov eax, -1          ; Return -1
    ret
```

**Example (finding first difference between buffers):**

```nasm
section .data
    buffer1 db 'abcdefgh'
    buffer2 db 'abcdxfgh'
    buflen equ 8
    
section .text
find_difference:
    cld
    lea esi, [buffer1]
    lea edi, [buffer2]
    mov ecx, buflen
    repe cmpsb           ; Compare while equal
    
    je no_difference     ; If ECX=0 and ZF=1, buffers identical
    
difference_found:
    ; ESI and EDI point one byte past the difference
    sub esi, buffer1
    dec esi              ; Position of first difference
    mov eax, esi
    ret
    
no_difference:
    mov eax, -1
    ret
```

### Performance Considerations

REP-prefixed instructions are highly optimized in modern processors. [Inference: They typically perform better than equivalent loops for large data blocks.]

**Example (comparing REP vs manual loop):**

```nasm
; Manual loop approach
manual_copy:
    cld
    lea esi, [source]
    lea edi, [dest]
    mov ecx, 1000
copy_loop:
    movsb
    loop copy_loop
    ret

; REP-optimized approach (typically faster)
rep_copy:
    cld
    lea esi, [source]
    lea edi, [dest]
    mov ecx, 1000
    rep movsb            ; Single instruction
    ret
```

