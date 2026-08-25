## Arrays and Indexing


### Array Fundamentals

Arrays in x86 assembly are contiguous blocks of memory accessed through base address and offset calculations. There is no bounds checking at the hardware level.

**Array element address calculation:**

```
Element Address = Base Address + (Index × Element Size)
```

### Direct Indexing

Direct indexing uses a register to hold the array index or offset:

```nasm
section .data
    byte_array db 10, 20, 30, 40, 50    ; Byte array
    word_array dw 100, 200, 300, 400    ; Word array
    dword_array dd 1000, 2000, 3000     ; Dword array

section .text
    ; Byte array access
    mov esi, offset byte_array
    mov ecx, 2                          ; Index 2
    mov al, byte ptr [esi + ecx]        ; AL = 30

    ; Word array access (index × 2)
    mov esi, offset word_array
    mov ecx, 1                          ; Index 1
    mov ax, word ptr [esi + ecx*2]      ; AX = 200

    ; Dword array access (index × 4)
    mov esi, offset dword_array
    mov ecx, 2                          ; Index 2
    mov eax, dword ptr [esi + ecx*4]    ; EAX = 3000
```

### Scaled Indexed Addressing

x86 provides powerful scaled indexed addressing modes that automatically calculate array offsets:

**Addressing format:** `[base + index*scale + displacement]`

Where scale can be 1, 2, 4, or 8 (matching byte, word, dword, qword sizes).

```nasm
section .data
    int_array dd 5, 10, 15, 20, 25, 30

section .text
    mov esi, offset int_array           ; Base address
    mov ecx, 3                          ; Index 3
    mov eax, [esi + ecx*4]              ; EAX = 20 (automatic scaling)
    
    ; With displacement
    mov eax, [esi + ecx*4 + 8]          ; Access index 3 + 2 dwords offset
```

### Array Traversal Patterns

**Forward iteration:**

```nasm
    mov esi, offset array               ; Start address
    mov ecx, array_length               ; Element count
    xor ebx, ebx                        ; Accumulator

loop_start:
    add ebx, dword ptr [esi]            ; Process element
    add esi, 4                          ; Move to next dword
    loop loop_start                     ; ECX decrements automatically
```

**Using index register:**

```nasm
    mov esi, offset array
    xor ecx, ecx                        ; Index = 0
    mov edx, array_length

loop_start:
    mov eax, [esi + ecx*4]              ; Access array[ecx]
    ; Process EAX
    inc ecx
    cmp ecx, edx
    jl loop_start
```

### Multi-dimensional Arrays

**Row-major order (C-style):** For a 2D array `arr[rows][cols]`, element `[i][j]` is at:

```
Address = base + (i × cols + j) × element_size
```

```nasm
section .data
    ; 3x4 matrix of dwords
    matrix dd 1, 2, 3, 4
           dd 5, 6, 7, 8
           dd 9, 10, 11, 12
    rows equ 3
    cols equ 4

section .text
    ; Access matrix[1][2] (element = 7)
    mov esi, offset matrix
    mov eax, 1                          ; Row index
    mov ebx, cols
    imul eax, ebx                       ; EAX = 1 × 4 = 4
    add eax, 2                          ; Add column index
    mov edx, [esi + eax*4]              ; EDX = 7
```

**Column-major order (Fortran-style):**

```
Address = base + (j × rows + i) × element_size
```

### Bounds Checking Pattern

Assembly doesn't automatically check bounds, but you can implement it:

```nasm
    mov ecx, index                      ; Get index
    cmp ecx, array_length               ; Compare with length
    jae out_of_bounds                   ; Jump if above or equal
    mov eax, [array + ecx*4]            ; Safe access
    jmp continue

out_of_bounds:
    ; Handle error
    xor eax, eax                        ; Return 0 or error code

continue:
    ; Continue execution
```

