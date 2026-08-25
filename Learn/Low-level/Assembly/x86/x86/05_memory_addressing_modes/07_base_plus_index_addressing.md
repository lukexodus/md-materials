## Base-Plus-Index Addressing


Base-plus-index addressing combines two registers to calculate the effective address, enabling two-dimensional array access and more complex data structure manipulation.

### Basic Base-Plus-Index

Two registers contribute to the address calculation:

```nasm
mov rax, [rbx + rcx]        ; EA = RBX + RCX
mov [rsi + rdi], rax        ; EA = RSI + RDI
mov byte [r8 + r9], 0x42    ; EA = R8 + R9 (extended registers)
```

### Valid Register Combinations

In base-plus-index addressing, certain restrictions apply:

**Base Register**: Any general-purpose register can serve as the base.

**Index Register**: Any general-purpose register except RSP can serve as the index. RSP cannot be used as an index register in this addressing mode.

```nasm
mov rax, [rbx + rcx]        ; Valid
mov rax, [rbx + rsp]        ; Invalid: RSP cannot be index register
mov rax, [rsp + rcx]        ; Valid: RSP as base, RCX as index
```

### Use Cases and Patterns

**Two-Dimensional Array Access**: Base-plus-index naturally implements array[base_index + offset]:

```c
// C code
int array[100];
int i = 10;
int value = array[i + 5];
```

```nasm
; Assembly equivalent
lea rax, [array]            ; Load array base address
mov rbx, 10                 ; i = 10
mov rcx, 5                  ; offset = 5
mov edx, [rax + rbx*4 + rcx*4]  ; Actually uses scaled addressing
; Simpler base-plus-index approach:
lea rdx, [rbx + rcx]        ; Compute total index
mov edx, [rax + rdx*4]      ; Access array[i + offset]
```

**Matrix Operations**: Accessing matrix elements using row and column indices:

```nasm
; Matrix[row][col] where each row is 'width' elements
; EA = base + (row * width + col) * element_size
mov rax, [matrix_base]      ; Matrix base address
imul rbx, row_index, width  ; RBX = row * width
add rbx, col_index          ; RBX = row * width + col
lea rcx, [rax + rbx*4]      ; Address of Matrix[row][col] (4-byte elements)
mov edx, [rcx]              ; Load the element
```

**String Operations**: Pointer arithmetic for string or buffer manipulation:

```nasm
; Copy buffer with offsets
mov rsi, [src_buffer]       ; Source base
mov rdi, [dst_buffer]       ; Destination base
xor rcx, rcx                ; Offset counter
copy_loop:
    mov al, [rsi + rcx]     ; Load byte from source + offset
    mov [rdi + rcx], al     ; Store to destination + offset
    inc rcx
    cmp rcx, buffer_size
    jl copy_loop
```

**Data Structure Traversal**: Navigating linked structures with computed offsets:

```nasm
; Linked list node with dynamic offset
mov rax, [current_node]     ; Current node pointer
mov rbx, [offset_value]     ; Computed offset to next node
mov rax, [rax + rbx]        ; Follow link: current = current + offset
```

### Base-Plus-Index with Displacement

Combining base, index, and displacement provides maximum flexibility:

```nasm
mov rax, [rbx + rcx + 8]    ; EA = RBX + RCX + 8
mov [rsi + rdi - 16], rax   ; EA = RSI + RDI - 16
mov edx, [rbp + rax + 100]  ; EA = RBP + RAX + 100
```

**Structure Array Access**: Accessing a specific field in an array element:

```c
// C code
struct Point { int x; int y; };
struct Point points[10];
int i = 5;
int x_coord = points[i].x;
```

```nasm
; Assembly equivalent (assuming Point size = 8 bytes)
lea rax, [points]           ; Array base address
mov rbx, 5                  ; Index i = 5
imul rbx, rbx, 8            ; RBX = i * sizeof(Point)
mov edx, [rax + rbx + 0]    ; Access points[i].x (field offset 0)
mov ecx, [rax + rbx + 4]    ; Access points[i].y (field offset 4)
```

