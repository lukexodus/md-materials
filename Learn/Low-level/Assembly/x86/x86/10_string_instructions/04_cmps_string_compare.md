## CMPS (String Compare)


CMPS compares data at ESI with data at EDI by performing a subtraction (without storing result) and setting flags accordingly, then adjusts both pointers.

**Variants:**

- **CMPSB:** Compare bytes
- **CMPSW:** Compare words
- **CMPSD:** Compare doublewords
- **CMPSQ:** Compare quadwords (64-bit mode)

**Operation:**

```assembly
; CMPSB equivalent:
mov al, [esi]       ; Load from source
cmp al, [edi]       ; Compare with destination (sets flags)
inc esi             ; Adjust source pointer
inc edi             ; Adjust destination pointer

; Flags set based on: [ESI] - [EDI]
; ZF = 1 if equal, 0 if not equal
; CF, SF, OF set according to signed/unsigned comparison
```

**Basic Usage:**

```assembly
section .data
    str1 db 'Hello', 0
    str2 db 'Hello', 0
    str3 db 'World', 0

section .text
; Compare single byte
    mov esi, str1
    mov edi, str2
    cld
    cmpsb               ; Compare first bytes
    je equal_bytes      ; Jump if equal
```

**Block Compare with REPE:**

```assembly
section .data
    string1 db 'Testing', 0
    string2 db 'Testing', 0
    str_len equ 7

section .text
; Compare two strings
    mov esi, string1
    mov edi, string2
    mov ecx, str_len
    cld
    repe cmpsb          ; Repeat while equal and ECX > 0
    je strings_equal    ; If ZF=1 after loop, all bytes matched
    
strings_equal:
    ; Strings are identical
    jmp done
    
strings_different:
    ; Strings differ
    ; ESI and EDI point one past the first differing byte
    
done:
```

**Example - String Compare Function (strcmp):**

```assembly
; int strcmp(const char *s1, const char *s2)
; Returns: 0 if equal, <0 if s1<s2, >0 if s1>s2

strcmp:
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov esi, [ebp+8]        ; First string
    mov edi, [ebp+12]       ; Second string
    cld
    
.compare_loop:
    cmpsb                   ; Compare one byte
    jne .not_equal          ; Strings differ
    
    ; Check if we reached null terminator
    cmp byte [esi-1], 0
    jne .compare_loop       ; Continue if not null
    
    ; Strings are equal
    xor eax, eax            ; Return 0
    jmp .done
    
.not_equal:
    ; Calculate difference for return value
    movzx eax, byte [esi-1] ; Get source byte
    movzx edx, byte [edi-1] ; Get dest byte
    sub eax, edx            ; Return difference
    
.done:
    pop edi
    pop esi
    pop ebp
    ret
```

**Example - Case-Insensitive Compare:**

```assembly
; Case-insensitive string comparison
stricmp:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    
    mov esi, [ebp+8]
    mov edi, [ebp+12]
    cld
    
.loop:
    mov al, [esi]           ; Get source character
    mov bl, [edi]           ; Get dest character
    
    ; Convert both to lowercase
    cmp al, 'A'
    jb .check_bl
    cmp al, 'Z'
    ja .check_bl
    add al, 32              ; Convert to lowercase
    
.check_bl:
    cmp bl, 'A'
    jb .compare
    cmp bl, 'Z'
    ja .compare
    add bl, 32              ; Convert to lowercase
    
.compare:
    cmp al, bl
    jne .not_equal
    
    ; Check for null terminator
    test al, al
    jz .equal
    
    inc esi
    inc edi
    jmp .loop
    
.equal:
    xor eax, eax
    jmp .done
    
.not_equal:
    movzx eax, al
    movzx ebx, bl
    sub eax, ebx
    
.done:
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret
```

**Finding First Difference:**

```assembly
section .data
    buffer1 db 'ABCDEFGH'
    buffer2 db 'ABCDXFGH'
    buf_len equ 8

section .text
; Find position of first difference
    mov esi, buffer1
    mov edi, buffer2
    mov ecx, buf_len
    cld
    repe cmpsb              ; Compare until difference or ECX=0
    
    je all_equal            ; ZF=1 means no difference found
    
    ; Calculate position of difference
    mov eax, buf_len
    sub eax, ecx            ; Position = original_length - remaining_count
    dec eax                 ; Adjust (ECX decremented before mismatch detected)
    ; EAX now contains index of first difference (4 in this case)
```

**Comparing with Different Data Types:**

```assembly
section .data
    array1 dd 100, 200, 300, 400
    array2 dd 100, 200, 350, 400
    arr_len equ 4

section .text
; Compare dword arrays
    mov esi, array1
    mov edi, array2
    mov ecx, arr_len
    cld
    repe cmpsd              ; Compare dwords
    
    je arrays_equal
    
    ; Find which dword differed
    mov eax, arr_len
    sub eax, ecx
    dec eax
    shl eax, 2              ; Multiply by 4 to get byte offset
    ; EAX = 8 (third dword at offset 8)
```

