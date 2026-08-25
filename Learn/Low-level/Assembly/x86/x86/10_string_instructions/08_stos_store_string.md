## STOS (Store String)


The STOS instruction stores data from the accumulator register (AL/AX/EAX/RAX) into the memory address pointed to by EDI/RDI, then automatically adjusts EDI/RDI.

### Syntax and Variants

```nasm
STOSB    ; Store byte: [EDI] = AL, EDI = EDI ± 1
STOSW    ; Store word: [EDI] = AX, EDI = EDI ± 2
STOSD    ; Store dword: [EDI] = EAX, EDI = EDI ± 4
STOSQ    ; Store qword: [RDI] = RAX, RDI = RDI ± 8 (64-bit mode only)
```

### Basic STOS Usage

**Example (filling buffer with a value):**

```nasm
section .bss
    buffer resb 100
    
section .text
    cld
    lea edi, [buffer]
    mov al, 'A'          ; Value to store
    mov ecx, 100         ; Count
    
fill_loop:
    stosb                ; Store AL at [EDI], EDI++
    loop fill_loop       ; Repeat 100 times
```

### STOS for Memory Initialization

**Example (zero-initializing array):**

```nasm
section .bss
    array resd 1000      ; 1000 dwords
    
section .text
clear_array:
    cld
    lea edi, [array]
    xor eax, eax         ; Value = 0
    mov ecx, 1000
    
clear_loop:
    stosd                ; Store 0 at [EDI], EDI += 4
    loop clear_loop
    ret
```

### STOS with Pattern Writing

**Example (writing alternating pattern):**

```nasm
section .bss
    pattern_buffer resb 256
    
section .text
create_pattern:
    cld
    lea edi, [pattern_buffer]
    mov ecx, 128         ; 128 iterations
    
pattern_loop:
    mov al, 0xFF
    stosb                ; Write 0xFF
    mov al, 0x00
    stosb                ; Write 0x00
    loop pattern_loop
    ret
```

### STOS for Structure Initialization

**Example:**

```nasm
section .bss
    point_x resd 1
    point_y resd 1
    point_z resd 1
    
section .text
init_point:
    cld
    lea edi, [point_x]
    mov eax, 10          ; x = 10
    stosd
    mov eax, 20          ; y = 20
    stosd
    mov eax, 30          ; z = 30
    stosd
    ret
```

