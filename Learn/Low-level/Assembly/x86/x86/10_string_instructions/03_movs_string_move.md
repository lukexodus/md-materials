## MOVS (String Move)


MOVS transfers data from memory location pointed to by ESI to memory location pointed to by EDI, then adjusts both pointers.

**Variants:**

- **MOVSB:** Move byte (8-bit)
- **MOVSW:** Move word (16-bit)
- **MOVSD:** Move doubleword (32-bit)
- **MOVSQ:** Move quadword (64-bit, 64-bit mode only)

**Operation:**

```assembly
; MOVSB equivalent:
mov al, [esi]       ; Load byte from source
mov [edi], al       ; Store byte to destination
inc esi             ; or dec esi if DF=1
inc edi             ; or dec edi if DF=1

; MOVSD equivalent:
mov eax, [esi]      ; Load dword from source
mov [edi], eax      ; Store dword to destination
add esi, 4          ; or sub esi, 4 if DF=1
add edi, 4          ; or sub edi, 4 if DF=1
```

**Basic Usage:**

```assembly
section .data
    source db 'Hello', 0
    
section .bss
    dest resb 6

section .text
; Copy single byte
    mov esi, source
    mov edi, dest
    cld                 ; Forward direction
    movsb              ; Copy one byte from [ESI] to [EDI]
    ; ESI now points to 'e', EDI points to dest+1

; Copy single dword
    mov esi, source
    mov edi, dest
    cld
    movsd              ; Copy 4 bytes at once
    ; Copies 'Hell' in one operation
```

**Block Copy with REP:**

```assembly
section .data
    source_array dd 1, 2, 3, 4, 5, 6, 7, 8
    array_size equ ($ - source_array) / 4  ; 8 dwords

section .bss
    dest_array resd 8

section .text
; Copy entire array
    mov esi, source_array
    mov edi, dest_array
    mov ecx, array_size     ; Number of dwords
    cld                     ; Forward direction
    rep movsd              ; Copy ECX dwords
    ; ECX = 0 after completion
```

**Example - Memory Copy Function:**

```assembly
; void memcpy(void *dest, const void *src, size_t count)
; Copy count bytes from src to dest

memcpy:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ecx
    
    mov edi, [ebp+8]        ; Destination pointer
    mov esi, [ebp+12]       ; Source pointer
    mov ecx, [ebp+16]       ; Byte count
    
    cld                     ; Forward direction
    
    ; Optimize: copy dwords first
    mov eax, ecx
    shr ecx, 2              ; Divide count by 4
    rep movsd              ; Copy dwords
    
    ; Copy remaining bytes (0-3 bytes)
    mov ecx, eax
    and ecx, 3              ; Get remainder (count % 4)
    rep movsb              ; Copy remaining bytes
    
    pop ecx
    pop edi
    pop esi
    pop ebp
    ret
```

**Overlapping Memory Regions:**

When source and destination overlap, direction matters to avoid data corruption.

```assembly
section .data
    buffer db 'ABCDEFGH', 0

section .text
; Shift right (overlapping forward): must copy backward
; Move 'ABCDEF' to positions 2-7, result: 'ABABCDEF'
    mov esi, buffer + 5     ; Point to 'F' (last source byte)
    mov edi, buffer + 7     ; Point to destination for 'F'
    mov ecx, 6              ; Copy 6 bytes
    std                     ; Backward direction (decrement)
    rep movsb
    cld                     ; Restore forward direction

; Shift left (overlapping backward): copy forward
; Move bytes 2-7 to positions 0-5, result: 'CDEFGH'
    mov esi, buffer + 2     ; Point to 'C'
    mov edi, buffer         ; Point to start
    mov ecx, 6              ; Copy 6 bytes
    cld                     ; Forward direction
    rep movsb
```

**Performance Considerations:**

```assembly
; Efficient: Use largest size possible
mov ecx, 1000
cld
rep movsd              ; Moves 4000 bytes in 1000 operations

; Less efficient: Byte-by-byte
mov ecx, 4000
cld
rep movsb              ; Moves 4000 bytes in 4000 operations
```

**Example - String Copy (strcpy equivalent):**

```assembly
; Copy null-terminated string
string_copy:
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov edi, [ebp+8]        ; Destination
    mov esi, [ebp+12]       ; Source
    cld
    
.copy_loop:
    movsb                   ; Copy one byte
    cmp byte [esi-1], 0     ; Check if we copied null terminator
    jne .copy_loop          ; Continue if not null
    
    pop edi
    pop esi
    pop ebp
    ret
```

