## Direction Flag (DF)


The Direction Flag (DF) in the EFLAGS/RFLAGS register controls whether string instructions increment (DF=0) or decrement (DF=1) the ESI/EDI/RSI/RDI registers.

### Direction Flag Control

**CLD** (Clear Direction Flag) - Sets DF = 0, causing forward processing (incrementing) **STD** (Set Direction Flag) - Sets DF = 1, causing backward processing (decrementing)

**Example:**

```nasm
cld                  ; DF = 0, forward direction
; ESI/EDI will increment after string operations

std                  ; DF = 1, backward direction
; ESI/EDI will decrement after string operations
```

### Forward Processing (DF = 0)

Forward processing increments pointers, processing data from lower to higher addresses.

**Example:**

```nasm
section .data
    source db 'ABCDE'
    
section .bss
    dest resb 5
    
section .text
forward_copy:
    cld                  ; Forward direction
    lea esi, [source]    ; ESI points to 'A'
    lea edi, [dest]
    mov ecx, 5
    rep movsb            ; Copy A→B→C→D→E
    ret
```

### Backward Processing (DF = 1)

Backward processing decrements pointers, processing data from higher to lower addresses.

**Example:**

```nasm
section .data
    source db 'ABCDE'
    
section .bss
    dest resb 5
    
section .text
backward_copy:
    std                      ; Backward direction
    lea esi, [source + 4]    ; ESI points to 'E' (last byte)
    lea edi, [dest + 4]      ; EDI points to last byte of dest
    mov ecx, 5
    rep movsb                ; Copy E→D→C→B→A
    cld                      ; Restore forward direction
    ret
```

### Overlapping Memory Regions

The Direction Flag is critical when copying overlapping memory regions to avoid data corruption.

**Example (safe overlapping copy):**

```nasm
section .bss
    buffer resb 1000
    
section .text
; Copy 100 bytes from buffer+10 to buffer+5 (overlapping)
; Source: [buffer+10] to [buffer+109]
; Dest: [buffer+5] to [buffer+104]

safe_overlap_copy:
    ; Determine copy direction based on overlap
    lea esi, [buffer + 10]   ; Source start
    lea edi, [buffer + 5]    ; Dest start
    
    cmp esi, edi
    jbe copy_backward        ; If source <= dest, copy backward
    
copy_forward:
    ; Source > dest, safe to copy forward
    cld
    mov ecx, 100
    rep movsb
    ret
    
copy_backward:
    ; Source <= dest, must copy backward
    std
    add esi, 99              ; Point to last byte of source
    add edi, 99              ; Point to last byte of dest
    mov ecx, 100
    rep movsb
    cld                      ; Restore forward direction
    ret
```

### Direction Flag in String Comparison

**Example (comparing strings backward):**

```nasm
section .data
    str1 db 'filename.txt'
    str2 db 'document.txt'
    len equ 12
    
section .text
compare_extensions:
    std                      ; Backward direction
    lea esi, [str1 + len - 1]
    lea edi, [str2 + len - 1]
    mov ecx, 4               ; Compare last 4 chars (.txt)
    repe cmpsb
    cld                      ; Restore forward direction
    
    je extensions_match
    mov eax, 0
    ret
    
extensions_match:
    mov eax, 1
    ret
```

### Direction Flag Preservation

[Inference: Most calling conventions expect DF=0 on function entry and return.] Functions that modify DF should restore it before returning.

**Example:**

```nasm
my_function:
    push ebp
    mov ebp, esp
    
    ; Save direction flag state
    pushfd               ; Save EFLAGS
    
    std                  ; Use backward direction
    ; ... operations using backward direction ...
    
    popfd                ; Restore EFLAGS (including DF)
    pop ebp
    ret
```

### Common Direction Flag Pitfalls

**Example (incorrect - forgetting to restore DF):**

```nasm
bad_function:
    std
    ; ... backward operations ...
    ret                  ; BUG: DF still set to 1!
    
; Next string operation will be backward unexpectedly
caller:
    call bad_function
    lea esi, [data]
    lodsb                ; Will decrement ESI instead of increment!
```

**Example (correct - always restore DF):**

```nasm
good_function:
    std
    ; ... backward operations ...
    cld                  ; Always restore forward direction
    ret
```

