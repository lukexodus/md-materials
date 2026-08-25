## LODS (Load String)


The LODS instruction loads data from the memory address pointed to by ESI/RSI into the accumulator register (AL/AX/EAX/RAX), then automatically adjusts ESI/RSI.

### Syntax and Variants

```nasm
LODSB    ; Load byte: AL = [ESI], ESI = ESI ± 1
LODSW    ; Load word: AX = [ESI], ESI = ESI ± 2
LODSD    ; Load dword: EAX = [ESI], ESI = ESI ± 4
LODSQ    ; Load qword: RAX = [RSI], RSI = RSI ± 8 (64-bit mode only)
```

The ± operation depends on the Direction Flag (DF):

- DF = 0: Increment (forward processing)
- DF = 1: Decrement (backward processing)

### Basic LODS Usage

**Example:**

```nasm
section .data
    source db 'Hello', 0
    
section .text
    cld              ; Clear direction flag (forward)
    lea esi, [source]
    
    lodsb            ; AL = 'H', ESI points to 'e'
    lodsb            ; AL = 'e', ESI points to 'l'
    lodsb            ; AL = 'l', ESI points to 'l'
    lodsb            ; AL = 'l', ESI points to 'o'
    lodsb            ; AL = 'o', ESI points to null terminator
```

### LODS in String Processing

LODS is commonly used when each character requires individual processing that cannot be automated with REP prefix.

**Example (converting string to uppercase):**

```nasm
section .data
    source db 'hello world', 0
    
section .bss
    dest resb 20
    
section .text
convert_to_upper:
    cld
    lea esi, [source]
    lea edi, [dest]
    
convert_loop:
    lodsb                ; Load character from source
    test al, al          ; Check for null terminator
    jz done
    
    ; Convert to uppercase if lowercase letter
    cmp al, 'a'
    jb store_char
    cmp al, 'z'
    ja store_char
    sub al, 32           ; Convert to uppercase
    
store_char:
    stosb                ; Store character to destination
    jmp convert_loop
    
done:
    stosb                ; Store null terminator
    ret
```

### LODS with Different Data Sizes

**Example (processing 32-bit integers):**

```nasm
section .data
    numbers dd 10, 20, 30, 40, 50
    count equ 5
    
section .text
sum_array:
    cld
    lea esi, [numbers]
    xor eax, eax         ; Sum = 0
    mov ecx, count
    
sum_loop:
    lodsd                ; Load dword into EAX
    add ebx, eax         ; Add to sum (using EBX as accumulator)
    loop sum_loop        ; ECX--, jump if ECX != 0
    
    mov eax, ebx         ; Return sum in EAX
    ret
```

### LODS in 64-bit Mode

**Example:**

```nasm
section .data
    values dq 100, 200, 300, 400
    
section .text
    cld
    lea rsi, [values]
    
    lodsq                ; RAX = 100, RSI += 8
    lodsq                ; RAX = 200, RSI += 8
    lodsq                ; RAX = 300, RSI += 8
    lodsq                ; RAX = 400, RSI += 8
```

