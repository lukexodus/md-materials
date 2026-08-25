## Return Values


Return values communicate results from procedures back to callers. The method depends on the calling convention and data type.

### Integer Return Values

Single integer or pointer values are returned in the accumulator register:

- 8-bit: AL
- 16-bit: AX
- 32-bit: EAX
- 64-bit: RAX (or EAX:EDX in 32-bit systems for 64-bit values)

**Example:**

```nasm
add_numbers:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]     ; First parameter
    add eax, [ebp+12]    ; Add second parameter
    ; eax contains return value
    pop ebp
    ret
```

### Large Integer Return Values (32-bit systems)

For 64-bit values on 32-bit systems, the upper 32 bits are returned in EDX and lower 32 bits in EAX.

**Example:**

```nasm
; Returns 64-bit result in EDX:EAX
multiply_64bit:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]     ; Low 32 bits of first operand
    mov edx, [ebp+12]    ; High 32 bits of first operand
    ; Simplified - actual 64-bit multiplication more complex
    ; Result: high 32 bits in EDX, low 32 bits in EAX
    pop ebp
    ret
```

### Floating-Point Return Values

Floating-point values are returned in floating-point registers:

- x87 FPU: ST(0) (top of FPU stack)
- SSE: XMM0

**Example (x87):**

```nasm
calculate_average:
    push ebp
    mov ebp, esp
    fild dword [ebp+8]   ; Load first integer as float
    fild dword [ebp+12]  ; Load second integer as float
    faddp                ; Add, store in ST(0)
    fld dword [two]      ; Load 2.0
    fdivp                ; Divide by 2, result in ST(0)
    pop ebp
    ret

two: dd 2.0
```

**Example (SSE):**

```nasm
calculate_average:
    push rbp
    mov rbp, rsp
    cvtsi2ss xmm0, edi   ; Convert first param to float
    cvtsi2ss xmm1, esi   ; Convert second param to float
    addss xmm0, xmm1     ; Add
    divss xmm0, [two]    ; Divide by 2, result in xmm0
    pop rbp
    ret

two: dd 2.0
```

### Structure Return Values

Small structures (typically ≤8 bytes on 32-bit, ≤16 bytes on 64-bit) may be returned in registers. Larger structures are typically returned via a hidden pointer parameter.

**Example (small structure in 64-bit):**

```nasm
; Structure with two 32-bit integers returned in RAX
get_point:
    push rbp
    mov rbp, rsp
    mov eax, 100         ; x coordinate (lower 32 bits)
    shl rax, 32
    mov eax, 200         ; y coordinate (upper 32 bits replaced)
    ; RAX = 0x00000064000000C8 (x=100, y=200)
    pop rbp
    ret
```

**Example (large structure via pointer):**

```nasm
; Caller passes pointer to structure in first parameter
; Function fills the structure and returns the pointer

; C equivalent: struct Point* get_point(struct Point* p);

get_point:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]         ; Get pointer to structure
    mov dword [eax], 100     ; Set x field
    mov dword [eax+4], 200   ; Set y field
    ; Return the same pointer in eax
    pop ebp
    ret
```

### Boolean Return Values

Boolean values are typically returned as integers (0 for false, non-zero for true) in AL, AX, EAX, or RAX.

**Example:**

```nasm
is_even:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]     ; Get parameter
    and eax, 1           ; Check lowest bit
    xor eax, 1           ; Invert (even returns 1, odd returns 0)
    pop ebp
    ret
```

