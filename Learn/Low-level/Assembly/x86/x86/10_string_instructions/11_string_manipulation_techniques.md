## String Manipulation Techniques


### Memory Copying with MOVS

MOVS copies data from [ESI] to [EDI], adjusting both pointers.

**Example (basic memory copy):**

```nasm
section .data
    source db 'Data to copy', 0
    src_len equ $ - source
    
section .bss
    destination resb 100
    
section .text
copy_memory:
    cld
    lea esi, [source]
    lea edi, [destination]
    mov ecx, src_len
    rep movsb            ; Efficient byte-by-byte copy
    ret
```

**Example (optimized copy using MOVSD):**

```nasm
section .data
    source times 1000 dd 0
    
section .bss
    dest times 1000 dd 0
    
section .text
copy_dwords:
    cld
    lea esi, [source]
    lea edi, [dest]
    mov ecx, 1000
    rep movsd            ; Copy 1000 dwords (4000 bytes)
    ret
```

**Example (mixed-size copy for optimization):**

```nasm
; Copy 4097 bytes optimally
section .text
optimized_copy:
    cld
    lea esi, [source]
    lea edi, [dest]
    
    ; Copy 1024 dwords (4096 bytes)
    mov ecx, 1024
    rep movsd
    
    ; Copy remaining 1 byte
    movsb
    ret
```

### String Length Calculation

**Example (strlen implementation):**

```nasm
section .text
; int strlen(char* str)
; Returns length of null-terminated string
strlen:
    push edi
    mov edi, [esp+8]     ; Get string pointer
    cld
    xor al, al           ; Search for 0
    mov ecx, 0xFFFFFFFF  ; Maximum length
    repne scasb          ; Scan until AL found or ECX=0
    
    not ecx              ; Invert ECX
    dec ecx              ; Adjust for null terminator
    mov eax, ecx         ; Return length
    pop edi
    ret
```

### String Comparison

**Example (strcmp implementation):**

```nasm
section .text
; int strcmp(char* str1, char* str2)
; Returns: 0 if equal, <0 if str1<str2, >0 if str1>str2
strcmp:
    push esi
    push edi
    mov esi, [esp+12]    ; str1
    mov edi, [esp+16]    ; str2
    cld
    
compare_loop:
    lodsb                ; AL = *str1++
    scasb                ; Compare AL with *str2++
    jne not_equal        ; Characters differ
    test al, al          ; Check for null terminator
    jnz compare_loop     ; Continue if not end of string
    
    xor eax, eax         ; Strings equal
    jmp done
    
not_equal:
    ; AL contains last char from str1
    ; [EDI-1] contains last char from str2
    movzx eax, al
    movzx ecx, byte [edi-1]
    sub eax, ecx         ; Return difference
    
done:
    pop edi
    pop esi
    ret
```

### Memory Search (Finding Byte in Buffer)

**Example (memchr implementation):**

```nasm
section .text
; void* memchr(void* ptr, int value, size_t num)
; Searches for byte value in buffer
memchr:
    push edi
    mov edi, [esp+8]     ; Buffer pointer
    mov al, [esp+12]     ; Byte to find
    mov ecx, [esp+16]    ; Buffer size
    cld
    
    repne scasb          ; Search for AL
    jne not_found        ; Not found if ZF=0
    
    lea eax, [edi-1]     ; Return pointer to found byte
    jmp done
    
not_found:
    xor eax, eax         ; Return NULL
    
done:
    pop edi
    ret
```

### Memory Set (Filling Buffer)

**Example (memset implementation):**

```nasm
section .text
; void* memset(void* ptr, int value, size_t num)
; Fills buffer with byte value
memset:
    push edi
    mov edi, [esp+8]     ; Destination pointer
    mov al, [esp+12]     ; Fill byte
    mov ecx, [esp+16]    ; Count
    
    push edi             ; Save original pointer
    cld
    rep stosb            ; Fill ECX bytes
    pop eax              ; Return original pointer
    
    pop edi
    ret
```

**Example (optimized memset using STOSD):**

```nasm
section .text
optimized_memset:
    push edi
    mov edi, [esp+8]     ; Destination
    movzx eax, byte [esp+12]  ; Fill byte
    mov ecx, [esp+16]    ; Count
    
    ; Replicate byte across EAX (0x42 → 0x42424242)
    mov ah, al
    mov edx, eax
    shl eax, 16
    mov ax, dx
    
    push edi             ; Save original pointer
    cld
    
    ; Fill dwords
    mov edx, ecx
    shr ecx, 2           ; Count / 4
    rep stosd
    
    ; Fill remaining bytes
    mov ecx, edx
    and ecx, 3           ; Count % 4
    rep stosb
    
    pop eax              ; Return original pointer
    pop edi
    ret
```

### Case Conversion

**Example (converting string to uppercase in place):**

```nasm
section .text
; void strupr(char* str)
strupr:
    push esi
    push edi
    mov esi, [esp+12]    ; Source = destination
    mov edi, esi
    cld
    
convert_loop:
    lodsb                ; Load character
    test al, al          ; Check for null
    jz done
    
    cmp al, 'a'
    jb store
    cmp al, 'z'
    ja store
    sub al, 32           ; Convert to uppercase
    
store:
    stosb
    jmp convert_loop
    
done:
    stosb                ; Store null terminator
    pop edi
    pop esi
    ret
```

### String Copying with Null Termination

**Example (strcpy implementation):**

```nasm
section .text
; char* strcpy(char* dest, char* src)
strcpy:
    push esi
    push edi
    mov edi, [esp+12]    ; Destination
    mov esi, [esp+16]    ; Source
    push edi             ; Save original destination
    cld
    
copy_loop:
    lodsb                ; Load from source
    stosb                ; Store to destination
    test al, al          ; Check for null terminator
    jnz copy_loop        ; Continue if not null
    
    pop eax              ; Return original destination
    pop edi
    pop esi
    ret
```

### String Concatenation

**Example (strcat implementation):**

```nasm
section .text
; char* strcat(char* dest, char* src)
strcat:
    push esi
    push edi
    mov edi, [esp+12]    ; Destination
    mov esi, [esp+16]    ; Source
    push edi             ; Save original destination
    cld
    
    ; Find end of destination string
    xor al, al
    mov ecx, 0xFFFFFFFF
    repne scasb          ; Scan for null
    dec edi              ; Back up to null position
    
    ; Copy source to end of destination
concat_loop:
    lodsb
    stosb
    test al, al
    jnz concat_loop
    
    pop eax              ; Return original destination
    pop edi
    pop esi
    ret
```

### Token Searching

**Example (finding substring):**

```nasm
section .text
; char* strstr(char* haystack, char* needle)
strstr:
    push ebx
    push esi
    push edi
    mov esi, [esp+16]    ; Haystack
    mov ebx, [esp+20]    ; Needle
    
    ; Get needle length
    push ebx
    call strlen
    add esp, 4
    mov edx, eax         ; EDX = needle length
    test edx, edx
    jz found_at_start    ; Empty needle found at start
    
search_loop:
    mov al, [esi]
    test al, al          ; End of haystack?
    jz not_found
    
    ; Compare needle at current position
    push esi
    mov edi, esi
    mov ecx, edx
    mov esi, ebx
    repe cmpsb
    pop esi
    
    je found             ; Match found
    inc esi              ; Try next position
    jmp search_loop
    
found:
    mov eax, esi
    jmp done
    
found_at_start:
    mov eax, esi
    jmp done
    
not_found:
    xor eax, eax
    
done:
    pop edi
    pop esi
    pop ebx
    ret
```

### Reversing Strings

**Example (reverse string in place):**

```nasm
section .text
; void strrev(char* str)
strrev:
    push esi
    push edi
    push ebx
    mov esi, [esp+16]    ; String pointer
    
    ; Get string length
    push esi
    call strlen
    add esp, 4
    
    test eax, eax
    jz done              ; Empty string
    
    ; Set up pointers
    mov edi, esi
    add edi, eax
    dec edi              ; EDI = end of string
    
    ; Swap characters from both ends
swap_loop:
    cmp esi, edi
    jge done
    
    mov al, [esi]        ; Get left character
    mov bl, [edi]        ; Get right character
    mov [esi], bl        ; Swap
    mov [edi], al
    
    inc esi
    dec edi
    jmp swap_loop
    
done:
    pop ebx
    pop edi
    pop esi
    ret
```

### Buffer Comparison with Size Limit

**Example (memcmp implementation):**

```nasm
section .text
; int memcmp(void* ptr1, void* ptr2, size_t num)
memcmp:
    push esi
    push edi
    mov esi, [esp+12]    ; ptr1
    mov edi, [esp+16]    ; ptr2
    mov ecx, [esp+20]    ; num
    cld
    
    repe cmpsb           ; Compare while equal
    je buffers_equal
    
    ; Get last compared bytes
    movzx eax, byte [esi-1]
    movzx edx, byte [edi-1]
    sub eax, edx         ; Return difference
    jmp done
    
buffers_equal:
    xor eax, eax
    
done:
    pop edi
    pop esi
    ret
```

### Character Set Searching

**Example (finding any character from a set):**

```nasm
section .text
; char* strpbrk(char* str, char* charset)
; Finds first occurrence of any character from charset
strpbrk:
    push esi
    push edi
    push ebx
    mov esi, [esp+16]    ; String
    mov ebx, [esp+20]    ; Character set
    
scan_string:
    mov al, [esi]
    test al, al
    jz not_found         ; End of string
    
    ; Check if current char is in charset
    mov edi, ebx
check_charset:
    mov cl, [edi]
    test cl, cl
    jz next_char         ; End of charset
    
    cmp al, cl
    je found

    inc edi
    jmp check_charset
    
next_char:
    inc esi
    jmp scan_string
    
found:
    mov eax, esi         ; Return pointer to found character
    jmp done
    
not_found:
    xor eax, eax         ; Return NULL
    
done:
    pop ebx
    pop edi
    pop esi
    ret
```

### Span Calculation

**Example (strspn - length of initial segment matching charset):**

```nasm
section .text
; size_t strspn(char* str, char* charset)
; Returns length of initial segment containing only charset characters
strspn:
    push esi
    push edi
    push ebx
    mov esi, [esp+16]    ; String
    mov ebx, [esp+20]    ; Character set
    xor edx, edx         ; Counter
    
scan_loop:
    mov al, [esi]
    test al, al
    jz done              ; End of string
    
    ; Check if character is in charset
    mov edi, ebx
    xor cl, cl           ; Found flag
    
check_set:
    mov ch, [edi]
    test ch, ch
    jz check_result
    
    cmp al, ch
    je char_found
    
    inc edi
    jmp check_set
    
char_found:
    mov cl, 1            ; Mark as found
    
check_result:
    test cl, cl
    jz done              ; Character not in set, stop
    
    inc esi
    inc edx
    jmp scan_loop
    
done:
    mov eax, edx         ; Return count
    pop ebx
    pop edi
    pop esi
    ret
```

**Example (strcspn - length until any charset character):**

```nasm
section .text
; size_t strcspn(char* str, char* charset)
; Returns length of initial segment containing NO charset characters
strcspn:
    push esi
    push edi
    push ebx
    mov esi, [esp+16]    ; String
    mov ebx, [esp+20]    ; Character set
    xor edx, edx         ; Counter
    
scan_loop:
    mov al, [esi]
    test al, al
    jz done              ; End of string
    
    ; Check if character is in charset
    mov edi, ebx
    
check_set:
    mov cl, [edi]
    test cl, cl
    jz char_not_found    ; End of charset, char not found
    
    cmp al, cl
    je done              ; Character found in set, stop
    
    inc edi
    jmp check_set
    
char_not_found:
    inc esi
    inc edx
    jmp scan_loop
    
done:
    mov eax, edx         ; Return count
    pop ebx
    pop edi
    pop esi
    ret
```

### Whitespace Trimming

**Example (trim leading whitespace):**

```nasm
section .text
; char* ltrim(char* str)
; Returns pointer to first non-whitespace character
ltrim:
    push esi
    mov esi, [esp+8]     ; String pointer
    
skip_whitespace:
    mov al, [esi]
    test al, al
    jz done              ; End of string
    
    cmp al, ' '
    je skip
    cmp al, 9            ; Tab
    je skip
    cmp al, 10           ; Newline
    je skip
    cmp al, 13           ; Carriage return
    je skip
    
    jmp done             ; Non-whitespace found
    
skip:
    inc esi
    jmp skip_whitespace
    
done:
    mov eax, esi         ; Return pointer
    pop esi
    ret
```

**Example (trim trailing whitespace in place):**

```nasm
section .text
; void rtrim(char* str)
rtrim:
    push esi
    push edi
    mov esi, [esp+12]    ; String pointer
    
    ; Find end of string
    mov edi, esi
    cld
    xor al, al
    mov ecx, 0xFFFFFFFF
    repne scasb          ; Find null terminator
    sub edi, 2           ; Point to last actual character
    
    ; Back up over whitespace
trim_loop:
    cmp edi, esi
    jb done              ; Reached beginning
    
    mov al, [edi]
    cmp al, ' '
    je trim_char
    cmp al, 9            ; Tab
    je trim_char
    cmp al, 10           ; Newline
    je trim_char
    cmp al, 13           ; Carriage return
    je trim_char
    
    jmp done             ; Non-whitespace found
    
trim_char:
    dec edi
    jmp trim_loop
    
done:
    mov byte [edi+1], 0  ; Place null terminator after last non-whitespace
    pop edi
    pop esi
    ret
```

### String Tokenization

**Example (simple strtok-like implementation):**

```nasm
section .bss
    save_ptr resd 1      ; Static pointer for next token
    
section .text
; char* strtok(char* str, char* delimiters)
strtok:
    push esi
    push edi
    push ebx
    mov esi, [esp+16]    ; String (NULL for continuation)
    mov ebx, [esp+20]    ; Delimiters
    
    ; Use saved pointer if str is NULL
    test esi, esi
    jnz have_string
    mov esi, [save_ptr]
    test esi, esi
    jz return_null       ; No more tokens
    
have_string:
    ; Skip leading delimiters
skip_delims:
    mov al, [esi]
    test al, al
    jz return_null       ; End of string
    
    ; Check if character is delimiter
    mov edi, ebx
check_delim:
    mov cl, [edi]
    test cl, cl
    jz found_token_start
    
    cmp al, cl
    je next_char
    
    inc edi
    jmp check_delim
    
next_char:
    inc esi
    jmp skip_delims
    
found_token_start:
    mov edx, esi         ; Save token start
    
    ; Find end of token
find_end:
    inc esi
    mov al, [esi]
    test al, al
    jz end_of_string
    
    ; Check if character is delimiter
    mov edi, ebx
check_end_delim:
    mov cl, [edi]
    test cl, cl
    jz find_end          ; Not a delimiter, continue
    
    cmp al, cl
    je found_delimiter
    
    inc edi
    jmp check_end_delim
    
found_delimiter:
    mov byte [esi], 0    ; Replace delimiter with null
    inc esi
    mov [save_ptr], esi  ; Save position for next call
    mov eax, edx         ; Return token start
    jmp done
    
end_of_string:
    mov dword [save_ptr], 0  ; No more tokens
    mov eax, edx         ; Return last token
    jmp done
    
return_null:
    xor eax, eax
    
done:
    pop ebx
    pop edi
    pop esi
    ret
```

### String Formatting

**Example (integer to string conversion):**

```nasm
section .text
; void itoa(int value, char* str, int base)
itoa:
    push esi
    push edi
    push ebx
    mov eax, [esp+16]    ; Value
    mov edi, [esp+20]    ; String buffer
    mov ebx, [esp+24]    ; Base (2-36)
    
    ; Handle negative numbers (base 10 only)
    xor edx, edx         ; Sign flag
    cmp ebx, 10
    jne convert
    
    test eax, eax
    jns convert
    
    mov edx, 1           ; Mark as negative
    neg eax              ; Make positive
    
convert:
    mov esi, edi         ; Save buffer start
    
    ; Convert digits in reverse
convert_loop:
    xor edx, edx
    div ebx              ; EDX:EAX / EBX -> quotient in EAX, remainder in EDX
    
    ; Convert remainder to ASCII
    cmp edx, 10
    jb decimal_digit
    
    add edx, 'A' - 10    ; A-Z for bases > 10
    jmp store_digit
    
decimal_digit:
    add edx, '0'         ; 0-9
    
store_digit:
    mov [edi], dl
    inc edi
    
    test eax, eax
    jnz convert_loop
    
    ; Add negative sign if needed
    mov edx, [esp+16]
    test edx, edx
    jns reverse_string
    
    cmp dword [esp+24], 10
    jne reverse_string
    
    mov byte [edi], '-'
    inc edi
    
reverse_string:
    mov byte [edi], 0    ; Null terminator
    dec edi
    
    ; Reverse the string
reverse_loop:
    cmp esi, edi
    jge done
    
    mov al, [esi]
    mov bl, [edi]
    mov [esi], bl
    mov [edi], al
    
    inc esi
    dec edi
    jmp reverse_loop
    
done:
    pop ebx
    pop edi
    pop esi
    ret
```

### Memory Block Operations

**Example (memory move with overlap handling - memmove):**

```nasm
section .text
; void* memmove(void* dest, void* src, size_t n)
; Safe for overlapping regions
memmove:
    push esi
    push edi
    mov edi, [esp+12]    ; Destination
    mov esi, [esp+16]    ; Source
    mov ecx, [esp+20]    ; Count
    
    test ecx, ecx
    jz done              ; Nothing to copy
    
    ; Check for overlap
    cmp edi, esi
    je done              ; Same location
    ja copy_backward     ; dest > src, copy backward
    
copy_forward:
    cld
    push edi             ; Save destination for return
    
    ; Optimize with dword copies
    mov edx, ecx
    shr ecx, 2           ; Count / 4
    rep movsd
    
    mov ecx, edx
    and ecx, 3           ; Remaining bytes
    rep movsb
    
    pop eax              ; Return destination
    jmp exit
    
copy_backward:
    std
    push edi             ; Save destination for return
    
    ; Point to last bytes
    add esi, ecx
    add edi, ecx
    dec esi
    dec edi
    
    rep movsb            ; Copy backward
    
    cld                  ; Restore direction flag
    pop eax              ; Return destination
    jmp exit
    
done:
    mov eax, edi         ; Return destination
    
exit:
    pop edi
    pop esi
    ret
```

### Pattern Matching

**Example (simple wildcard matching with * and ?):**

```nasm
section .text
; int wildcard_match(char* str, char* pattern)
; * matches any sequence, ? matches single character
; Returns 1 if match, 0 otherwise
wildcard_match:
    push esi
    push edi
    push ebx
    mov esi, [esp+16]    ; String
    mov edi, [esp+20]    ; Pattern
    
match_loop:
    mov al, [edi]        ; Pattern character
    mov bl, [esi]        ; String character
    
    cmp al, 0
    je check_end         ; End of pattern
    
    cmp al, '*'
    je match_star
    
    cmp al, '?'
    je match_question
    
    ; Exact character match required
    cmp al, bl
    jne no_match
    
    inc esi
    inc edi
    jmp match_loop
    
match_question:
    test bl, bl
    jz no_match          ; Can't match end of string
    inc esi
    inc edi
    jmp match_loop
    
match_star:
    inc edi
    mov al, [edi]
    test al, al
    jz match_found       ; * at end matches everything
    
try_star_match:
    mov bl, [esi]
    test bl, bl
    jz no_match          ; End of string but pattern remains
    
    ; Try matching rest of pattern from current position
    push esi
    push edi
    call wildcard_match
    add esp, 8
    
    test eax, eax
    jnz match_found      ; Found match
    
    inc esi              ; Try next position
    jmp try_star_match
    
check_end:
    test bl, bl
    jz match_found       ; Both at end
    
no_match:
    xor eax, eax
    jmp done
    
match_found:
    mov eax, 1
    
done:
    pop ebx
    pop edi
    pop esi
    ret
```

### Efficient Buffer Zeroing

**Example (optimized zero-fill using REP STOSQ in 64-bit):**

```nasm
section .text
; void bzero_64(void* ptr, size_t size)
bzero_64:
    push rdi
    mov rdi, [rsp+16]    ; Buffer pointer
    mov rcx, [rsp+24]    ; Size in bytes
    
    test rcx, rcx
    jz done
    
    xor rax, rax         ; Zero value
    cld
    
    ; Fill with qwords (8 bytes)
    mov rdx, rcx
    shr rcx, 3           ; Count / 8
    rep stosq
    
    ; Fill remaining bytes
    mov rcx, rdx
    and rcx, 7           ; Remaining bytes
    rep stosb
    
done:
    pop rdi
    ret
```

### String Interpolation with Buffer

**Example (simple sprintf-like for strings and integers):**

```nasm
section .text
; int simple_sprintf(char* buffer, char* format, ...)
; Very simplified: %s for string, %d for integer
simple_sprintf:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    
    mov edi, [ebp+8]     ; Destination buffer
    mov esi, [ebp+12]    ; Format string
    lea ebx, [ebp+16]    ; Variable arguments
    
format_loop:
    lodsb                ; Get format character
    test al, al
    jz format_done
    
    cmp al, '%'
    je format_spec
    
    stosb                ; Copy literal character
    jmp format_loop
    
format_spec:
    lodsb                ; Get specifier
    test al, al
    jz format_done
    
    cmp al, 's'
    je format_string
    
    cmp al, 'd'
    je format_decimal
    
    cmp al, '%'
    je format_percent
    
    ; Unknown specifier, skip
    jmp format_loop
    
format_string:
    mov ecx, [ebx]       ; Get string pointer argument
    add ebx, 4
    
copy_string:
    mov al, [ecx]
    test al, al
    jz format_loop
    
    stosb
    inc ecx
    jmp copy_string
    
format_decimal:
    mov eax, [ebx]       ; Get integer argument
    add ebx, 4
    
    ; Convert integer to string
    push edi
    push esi
    push ebx
    
    push 10              ; Base 10
    push edi             ; Buffer
    push eax             ; Value
    call itoa
    add esp, 12
    
    pop ebx
    pop esi
    pop edi
    
    ; Find end of converted number
skip_number:
    mov al, [edi]
    test al, al
    jz format_loop
    inc edi
    jmp skip_number
    
format_percent:
    mov al, '%'
    stosb
    jmp format_loop
    
format_done:
    mov byte [edi], 0    ; Null terminator
    
    ; Return number of characters written
    sub edi, [ebp+8]
    mov eax, edi
    
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret
```

### Case-Insensitive Comparison

**Example (stricmp implementation):**

```nasm
section .text
; int stricmp(char* str1, char* str2)
; Case-insensitive string comparison
stricmp:
    push esi
    push edi
    mov esi, [esp+12]    ; str1
    mov edi, [esp+16]    ; str2
    
compare_loop:
    mov al, [esi]        ; Get char from str1
    mov bl, [edi]        ; Get char from str2
    
    ; Convert both to lowercase for comparison
    call to_lower_al
    mov cl, al
    
    mov al, bl
    call to_lower_al
    mov bl, al
    
    cmp cl, bl
    jne not_equal
    
    test cl, cl          ; Check for null terminator
    jz strings_equal
    
    inc esi
    inc edi
    jmp compare_loop
    
not_equal:
    movzx eax, cl
    movzx edx, bl
    sub eax, edx
    jmp done
    
strings_equal:
    xor eax, eax
    
done:
    pop edi
    pop esi
    ret

; Helper: convert AL to lowercase
to_lower_al:
    cmp al, 'A'
    jb not_upper
    cmp al, 'Z'
    ja not_upper
    add al, 32
not_upper:
    ret
```

### Buffer Overlap Detection

**Example (checking if memory regions overlap):**

```nasm
section .text
; int buffers_overlap(void* buf1, size_t len1, void* buf2, size_t len2)
; Returns 1 if overlap, 0 otherwise
buffers_overlap:
    mov eax, [esp+4]     ; buf1
    mov ecx, [esp+8]     ; len1
    mov edx, [esp+12]    ; buf2
    mov esi, [esp+16]    ; len2
    
    ; Calculate end addresses
    lea edi, [eax+ecx]   ; buf1_end = buf1 + len1
    lea ebx, [edx+esi]   ; buf2_end = buf2 + len2
    
    ; Check if buf1_start >= buf2_end
    cmp eax, ebx
    jae no_overlap
    
    ; Check if buf2_start >= buf1_end
    cmp edx, edi
    jae no_overlap
    
    ; Overlap detected
    mov eax, 1
    ret
    
no_overlap:
    xor eax, eax
    ret
```

### Multi-byte Character Handling (UTF-8)

**Example (counting UTF-8 characters, not bytes):**

```nasm
section .text
; size_t utf8_strlen(char* str)
; Counts UTF-8 characters (code points), not bytes
utf8_strlen:
    push esi
    mov esi, [esp+8]     ; String pointer
    xor eax, eax         ; Character count
    
count_loop:
    mov cl, [esi]
    test cl, cl
    jz done              ; End of string
    
    ; Check if this is a continuation byte (10xxxxxx)
    mov dl, cl
    and dl, 0xC0
    cmp dl, 0x80
    je skip_byte         ; Continuation byte, don't count
    
    inc eax              ; Count this character
    
skip_byte:
    inc esi
    jmp count_loop
    
done:
    pop esi
    ret
```

### Aligned Memory Operations

**Example (copying with alignment optimization):**

```nasm
section .text
; void aligned_copy(void* dest, void* src, size_t n)
; Optimizes copy by aligning destination to 16-byte boundary
aligned_copy:
    push esi
    push edi
    mov edi, [esp+12]    ; Destination
    mov esi, [esp+16]    ; Source
    mov ecx, [esp+20]    ; Count
    
    test ecx, ecx
    jz done
    
    cld
    
    ; Copy bytes until destination is 16-byte aligned
align_loop:
    test edi, 15         ; Check alignment
    jz aligned
    
    movsb
    dec ecx
    jz done
    jmp align_loop
    
aligned:
    ; Now copy 16 bytes at a time using SSE (if available)
    ; For demonstration, using regular movsd
    mov edx, ecx
    shr ecx, 2           ; Count / 4
    rep movsd
    
    mov ecx, edx
    and ecx, 3           ; Remaining bytes
    rep movsb
    
done:
    pop edi
    pop esi
    ret
```

**Important subtopics:**

**SIMD string operations** - Using SSE/AVX instructions (MOVDQA, MOVDQU, PCMPEQB) for parallel string processing and pattern matching.

**Cache-aware algorithms** - Optimizing string operations for cache line sizes and memory hierarchy to improve performance on large buffers.

**Unicode normalization** - Handling different Unicode encoding schemes (UTF-8, UTF-16, UTF-32) and normalization forms in assembly.

**String hashing** - Implementing fast hash functions (CRC32, MurmurHash, xxHash) using string instructions and SIMD for hash tables and checksums.

---

