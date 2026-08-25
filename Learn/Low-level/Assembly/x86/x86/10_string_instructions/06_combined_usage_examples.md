## Combined Usage Examples


**Example - Memory Search and Replace:**

```assembly
; Replace all occurrences of old_char with new_char in buffer
search_replace:
    push ebp
    mov ebp, esp
    push edi
    push ecx
    
    mov edi, [ebp+8]        ; Buffer pointer
    mov ecx, [ebp+12]       ; Buffer length
    mov al, [ebp+16]        ; Old character
    mov dl, [ebp+20]        ; New character
    cld
    
.search_loop:
    test ecx, ecx
    jz .done
    
    repne scasb            ; Find next occurrence
    jne .done               ; Not found, exit
    
    mov [edi-1], dl         ; Replace (EDI already advanced)
    jmp .search_loop
    
.done:
    pop ecx
    pop edi
    pop ebp
    ret
```

**Example - String Copy with Length Limit (strncpy):**

```assembly
; char *strncpy(char *dest, const char *src, size_t n)
strncpy:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ecx
    
    mov edi, [ebp+8]        ; Destination
    mov esi, [ebp+12]       ; Source
    mov ecx, [ebp+16]       ; Maximum length
    cld
    
    test ecx, ecx
    jz .done
    
.copy_loop:
    lodsb                   ; Load byte from [ESI] to AL, inc ESI
    stosb                   ; Store AL to [EDI], inc EDI
    test al, al             ; Check for null terminator
    jz .pad_rest            ; If null, pad remaining with zeros
    loop .copy_loop
    jmp .done
    
.pad_rest:
    ; Pad remaining bytes with zeros
    xor al, al
    rep stosb
    
.done:
    mov eax, [ebp+8]        ; Return dest pointer
    pop ecx
    pop edi
    pop esi
    pop ebp
    ret
```

**Example - Pattern Matching:**

```assembly
; Find substring in string (simplified strstr)
strstr:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    
    mov ebx, [ebp+8]        ; Haystack (string to search in)
    mov esi, [ebp+12]       ; Needle (pattern to find)
    
    ; Get needle length
    push esi
    call strlen
    add esp, 4
    mov ecx, eax            ; Needle length
    test ecx, ecx
    jz .found_empty         ; Empty needle always matches
    
.try_position:
    ; Check if we have enough characters left
    mov al, [ebx]
    test al, al
    jz .not_found
    
    ; Compare at current position
    mov esi, [ebp+12]       ; Reset needle pointer
    mov edi, ebx            ; Current haystack position
    push ecx                ; Save needle length
    cld
    repe cmpsb             ; Compare strings
    pop ecx
    
    je .found               ; Match found
    
    inc ebx                 ; Try next position
    jmp .try_position
    
.found:
    mov eax, ebx            ; Return pointer to match
    jmp .done
    
.found_empty:
    mov eax, ebx            ; Empty needle matches at start
    jmp .done
    
.not_found:
    xor eax, eax            ; Return NULL
    
.done:
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret
```

**Example - Reverse String:**

```assembly
; Reverse string in place
str_reverse:
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov esi, [ebp+8]        ; String pointer
    
    ; Find string end
    mov edi, esi
    mov ecx, -1
    xor al, al
    cld
    repne scasb            ; Find null
    sub edi, 2              ; Point to last character
    
    ; Swap characters from both ends
.swap_loop:
    cmp esi, edi
    jge .done               ; Pointers met or crossed
    
    mov al, [esi]           ; Get left character
    mov dl, [edi]           ; Get right character
    mov [esi], dl           ; Swap
    mov [edi], al
    
    inc esi
    dec edi
    jmp .swap_loop
    
.done:
    pop edi
    pop esi
    pop ebp
    ret
```

**Key Points:**

- String instructions use ESI (source), EDI (destination), and ECX (count) registers implicitly
- Direction flag (DF) controls auto-increment (CLD) or auto-decrement (STD) behavior
- REP prefix repeats operation ECX times; REPE/REPNE add equality condition checking
- MOVS transfers data between memory locations, efficient for block copying with REP MOVSD
- CMPS compares memory regions, useful with REPE for string equality or finding first difference
- SCAS searches memory for specific value in accumulator, essential for strlen, strchr operations
- Use largest data size possible (MOVSD vs MOVSB) for better performance
- [Inference] After string operations with repeat prefixes, ECX contains remaining count (0 if completed)
- EDI/ESI point one position past last processed element after operation
- Overlapping memory copies require careful direction selection to prevent data corruption

**Important subtopics:** LODS and STOS instructions for loading/storing with auto-increment, String instruction performance optimization techniques, Using string instructions with SSE/AVX for parallel processing, Alignment considerations for optimal performance

---
