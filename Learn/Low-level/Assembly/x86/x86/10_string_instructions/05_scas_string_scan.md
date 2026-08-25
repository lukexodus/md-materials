## SCAS (String Scan)


SCAS compares the accumulator (AL/AX/EAX/RAX) with data at EDI, sets flags, and adjusts EDI. Used for searching memory for specific values.

**Variants:**

- **SCASB:** Scan byte (compares AL with [EDI])
- **SCASW:** Scan word (compares AX with [EDI])
- **SCASD:** Scan doubleword (compares EAX with [EDI])
- **SCASQ:** Scan quadword (compares RAX with [EDI], 64-bit mode)

**Operation:**

```assembly
; SCASB equivalent:
cmp al, [edi]       ; Compare AL with byte at [EDI] (sets flags)
inc edi             ; Adjust pointer (or dec if DF=1)

; Does NOT modify AL or [EDI], only affects flags
```

**Basic Usage:**

```assembly
section .data
    buffer db 'Hello World', 0

section .text
; Scan for character 'W'
    mov edi, buffer
    mov al, 'W'
    mov ecx, 12             ; Buffer length
    cld
    repne scasb            ; Scan while not equal and ECX > 0
    
    je found_char          ; ZF=1 means character was found
    jmp not_found
    
found_char:
    ; EDI points one byte PAST the found character
    dec edi                ; Adjust to point at 'W'
    ; Calculate position
    sub edi, buffer        ; EDI now = 6 (offset of 'W')
```

**Example - String Length (strlen):**

```assembly
; size_t strlen(const char *str)
; Returns length of null-terminated string

strlen:
    push ebp
    mov ebp, esp
    push edi
    
    mov edi, [ebp+8]        ; String pointer
    mov ecx, -1             ; Maximum possible count (0xFFFFFFFF)
    xor al, al              ; Search for null terminator (0)
    cld
    
    repne scasb            ; Scan for null byte
    
    ; Calculate length
    not ecx                 ; Invert ECX
    dec ecx                 ; Subtract 1 (for null terminator)
    mov eax, ecx            ; Return length
    
    pop edi
    pop ebp
    ret
```

**How strlen Works:**

```assembly
; Example: strlen("Hi") = 2
; Initial: EDI -> "Hi\0", ECX = 0xFFFFFFFF, AL = 0

; First iteration:
;   cmp al, [edi]  ; 0 vs 'H' (0x48) -> not equal, ZF=0
;   inc edi        ; EDI -> 'i'
;   dec ecx        ; ECX = 0xFFFFFFFE
;   ZF=0, ECX≠0 -> continue

; Second iteration:
;   cmp al, [edi]  ; 0 vs 'i' (0x69) -> not equal, ZF=0
;   inc edi        ; EDI -> '\0'
;   dec ecx        ; ECX = 0xFFFFFFFD
;   ZF=0, ECX≠0 -> continue

; Third iteration:
;   cmp al, [edi]  ; 0 vs '\0' (0) -> equal, ZF=1
;   inc edi        ; EDI -> past string
;   dec ecx        ; ECX = 0xFFFFFFFC
;   ZF=1 -> stop

; Result calculation:
;   not ecx        ; 0xFFFFFFFC -> 0x00000003
;   dec ecx        ; 0x00000003 -> 0x00000002
;   Return 2
```

**Example - Character Search (strchr):**

```assembly
; char *strchr(const char *str, int c)
; Returns pointer to first occurrence of c in str, or NULL

strchr:
    push ebp
    mov ebp, esp
    push edi
    
    mov edi, [ebp+8]        ; String pointer
    mov al, [ebp+12]        ; Character to find (low byte)
    cld
    
.scan_loop:
    scasb                   ; Compare AL with [EDI], advance EDI
    je .found               ; Character found
    
    cmp byte [edi-1], 0     ; Check if we hit null terminator
    jne .scan_loop          ; Continue if not
    
    ; Not found
    xor eax, eax            ; Return NULL
    jmp .done
    
.found:
    lea eax, [edi-1]        ; Return pointer to found character
    
.done:
    pop edi
    pop ebp
    ret
```

**Example - Count Occurrences:**

```assembly
; Count how many times character appears in string
count_char:
    push ebp
    mov ebp, esp
    push edi
    push ecx
    
    mov edi, [ebp+8]        ; String pointer
    mov al, [ebp+12]        ; Character to count
    xor ebx, ebx            ; Counter = 0
    cld
    
.loop:
    cmp byte [edi], 0       ; Check for null terminator
    je .done
    
    scasb                   ; Compare and advance
    jne .loop               ; Not equal, continue
    
    inc ebx                 ; Found occurrence, increment counter
    jmp .loop
    
.done:
    mov eax, ebx            ; Return count
    pop ecx
    pop edi
    pop ebp
    ret
```

**Scanning Arrays of Different Types:**

```assembly
section .data
    int_array dd 10, 20, 30, 40, 50, 60, 70
    arr_size equ 7

section .text
; Find value 40 in integer array
    mov edi, int_array
    mov eax, 40             ; Value to find
    mov ecx, arr_size
    cld
    repne scasd            ; Scan dwords
    
    je value_found
    
value_found:
    ; EDI points 4 bytes past the found value
    sub edi, 4              ; Adjust to actual location
    sub edi, int_array      ; Calculate offset
    shr edi, 2              ; Divide by 4 to get index (3)
```

**Example - Find Last Occurrence:**

```assembly
; Find last occurrence by scanning backward
find_last:
    push ebp
    mov ebp, esp
    push edi
    push ecx
    
    mov edi, [ebp+8]        ; String pointer
    mov al, [ebp+12]        ; Character to find
    
    ; First, find string length
    push edi
    mov ecx, -1
    xor al, al
    cld
    repne scasb            ; Find null terminator
    not ecx
    dec ecx                 ; ECX = string length
    pop edi
    
    ; Now scan backward
    mov al, [ebp+12]        ; Restore search character
    add edi, ecx            ; Point to end of string
    dec edi                 ; Adjust to last character
    std                     ; Scan backward
    repne scasb
    cld                     ; Restore forward direction
    
    je .found
    xor eax, eax            ; Not found, return NULL
    jmp .done
    
.found:
    lea eax, [edi+1]        ; Adjust pointer (EDI went one past)
    
.done:
    pop ecx
    pop edi
    pop ebp
    ret
```

**Scanning for Non-Matching Character:**

```assembly
; Skip leading spaces
skip_spaces:
    push ebp
    mov ebp, esp
    push edi
    
    mov edi, [ebp+8]        ; String pointer
    cld
    
.loop:
    mov al, [edi]
    cmp al, ' '             ; Is it a space?
    jne .found_non_space
    cmp al, 0               ; End of string?
    je .found_non_space
    inc edi
    jmp .loop
    
.found_non_space:
    mov eax, edi            ; Return pointer to first non-space
    
    pop edi
    pop ebp
    ret
```

**Performance Example - Optimized String Length:**

```assembly
; Ultra-fast strlen using aligned access
strlen_fast:
    push ebp
    mov ebp, esp
    push edi
    push ebx
    
    mov edi, [ebp+8]
    mov ebx, edi            ; Save original pointer
    
    ; Align to 4-byte boundary
    and edi, 0xFFFFFFFC     ; Round down to alignment
    mov eax, [edi]          ; Load first aligned dword
    
    ; Check dword for null byte using bit tricks
.check_dword:
    mov ecx, eax
    sub ecx, 0x01010101     ; Subtract 1 from each byte
    not eax
    and eax, ecx
    and eax, 0x80808080     ; Check high bit of each byte
    jnz .found_null         ; If any high bit set, found null
    
    add edi, 4
    mov eax, [edi]
    jmp .check_dword
    
.found_null:
    ; Scan individual bytes to find exact position
    mov edi, ebx            ; Restore original pointer
    mov ecx, -1
    xor al, al
    cld
    repne scasb
    
    not ecx
    dec ecx
    mov eax, ecx
    
    pop ebx
    pop edi
    pop ebp
    ret
```

