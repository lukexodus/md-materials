## Scaled Index Addressing


Scaled index addressing multiplies an index register by a scale factor (1, 2, 4, or 8) before adding it to the base, directly supporting array element access with different element sizes.

### Basic Scaled Index Syntax

The scale factor appears between the index register and a multiplication symbol:

```nasm
mov rax, [rbx + rcx*4]      ; EA = RBX + (RCX × 4)
mov rax, [rbx + rcx*8]      ; EA = RBX + (RCX × 8)
mov byte [rsi + rdi*2], al  ; EA = RSI + (RDI × 2)
```

### Valid Scale Factors

Only four scale factors are architecturally supported: 1, 2, 4, and 8. These correspond to the sizes of:

- Scale 1: byte arrays or when no scaling needed
- Scale 2: word (16-bit) arrays
- Scale 4: dword (32-bit) arrays, common for int and float
- Scale 8: qword (64-bit) arrays, common for pointers and long integers

```nasm
mov al, [rsi + rdi*1]       ; Byte array access
mov ax, [rsi + rdi*2]       ; Word array access
mov eax, [rsi + rdi*4]      ; Dword array access
mov rax, [rsi + rdi*8]      ; Qword array access
```

Using other scale factors requires manual multiplication:

```nasm
; Access array with 12-byte elements
imul rbx, index, 12         ; Multiply index by 12
mov rax, [base + rbx]       ; Access array[index]
```

### Array Access Patterns

**One-Dimensional Array Access**: Direct mapping of array indexing:

```c
// C code
int array[100];
int i = 10;
int value = array[i];
```

```nasm
; Assembly equivalent
lea rax, [array]            ; Load array base address
mov rbx, 10                 ; Index i = 10
mov edx, [rax + rbx*4]      ; Load array[i] (int = 4 bytes)
```

**Pointer Array Access**: Arrays of pointers use scale 8 in 64-bit mode:

```c
// C code
char *string_array[100];
char *str = string_array[i];
```

```nasm
; Assembly equivalent
lea rax, [string_array]     ; Array base address
mov rbx, [index]            ; Load index
mov rcx, [rax + rbx*8]      ; Load string_array[i] (pointer = 8 bytes)
```

**Structure Array Access with Field Offset**: Combining scaled indexing with displacement:

```c
// C code
struct Data {
    int id;         // offset 0
    int value;      // offset 4
    long flags;     // offset 8
};
struct Data array[100];
int v = array[i].value;
```

```nasm
; Assembly equivalent
lea rax, [array]            ; Array base address
mov rbx, [index]            ; Load index i
; sizeof(Data) = 16 bytes (with padding)
shl rbx, 4                  ; RBX = i * 16 (multiply by sizeof)
mov edx, [rax + rbx + 4]    ; Load array[i].value

; Alternative using separate calculation
mov rbx, [index]
imul rbx, rbx, 16           ; Can't use scale for 16
mov edx, [rax + rbx + 4]
```

### Scaled Index with Displacement

Full addressing mode with base, scaled index, and displacement:

```nasm
mov rax, [rbx + rcx*4 + 8]      ; EA = RBX + (RCX × 4) + 8
mov [rsi + rdi*8 - 16], rax     ; EA = RSI + (RDI × 8) - 16
mov edx, [rbp + rax*4 + 100]    ; EA = RBP + (RAX × 4) + 100
```

**Multi-Dimensional Array Access**: Implementing matrix or multi-dimensional array indexing:

```c
// C code
int matrix[10][20];  // 10 rows, 20 columns
int value = matrix[row][col];
```

```nasm
; Assembly equivalent
; EA = base + (row * cols + col) * element_size
lea rax, [matrix]           ; Matrix base address
mov rbx, [row]              ; Load row index
imul rbx, rbx, 20           ; RBX = row * 20 (columns per row)
add rbx, [col]              ; RBX = row * 20 + col
mov edx, [rax + rbx*4]      ; Load matrix[row][col]

; Alternative using LEA for efficiency
mov rbx, [row]
mov rcx, [col]
lea rbx, [rbx + rbx*4]      ; RBX = row * 5
lea rbx, [rbx + rbx*3]      ; RBX = row * 20 (using LEA tricks)
add rbx, rcx                ; RBX = row * 20 + col
mov edx, [rax + rbx*4]
```

### Index-Only Addressing

Using scaled index without a base register accesses absolute addresses with scaling:

```nasm
mov rax, [rcx*4 + 0x1000]       ; EA = (RCX × 4) + 0x1000
mov ebx, [rdi*8 + array_base]   ; EA = (RDI × 8) + array_base
```

This pattern is useful for accessing global arrays by index:

```nasm
; Global array access
.data
global_array: times 100 dq 0    ; 100 qwords

.text
mov rbx, 10                     ; Index 10
mov rax, [global_array + rbx*8] ; Access global_array[10]
```

### LEA with Scaled Addressing

The LEA (Load Effective Address) instruction computes addresses without memory access, making it useful for arithmetic:

```nasm
lea rax, [rbx + rcx*4]          ; RAX = RBX + (RCX × 4)
lea rax, [rbx + rcx*8 + 16]     ; RAX = RBX + (RCX × 8) + 16
```

LEA enables efficient arithmetic computations:

```nasm
; Multiply by 3
lea rax, [rbx + rbx*2]          ; RAX = RBX + RBX*2 = RBX*3

; Multiply by 5
lea rax, [rbx + rbx*4]          ; RAX = RBX + RBX*4 = RBX*5

; Multiply by 9
lea rax, [rbx + rbx*8]          ; RAX = RBX + RBX*8 = RBX*9

; Compute (a * 4) + b + 8
lea rax, [rbx*4 + rcx + 8]      ; RAX = RBX*4 + RCX + 8
```

