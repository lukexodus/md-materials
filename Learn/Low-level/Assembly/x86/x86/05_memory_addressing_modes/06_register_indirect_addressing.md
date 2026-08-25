## Register Indirect Addressing


Register indirect addressing uses a register's contents as a memory address, dereferencing the pointer stored in the register.

### Basic Register Indirect

The simplest memory addressing mode places a register containing an address in square brackets:

```nasm
mov rax, [rbx]              ; Load 64-bit value from address in RBX
mov [rcx], rax              ; Store RAX to address in RCX
mov byte [rdx], 0x42        ; Store immediate byte to address in RDX
```

This mode is fundamental for:

- Pointer dereferencing in high-level language implementations
- Dynamic memory access where the address is computed at runtime
- Linked list traversal and tree navigation
- Accessing heap-allocated data structures

### Valid Base Registers

In 64-bit mode, any general-purpose register except RSP can serve as a base register in simple indirect addressing. While RSP is technically usable, using it without a displacement often requires special encoding and is typically avoided [Inference based on encoding complexities].

```nasm
mov rax, [rbx]              ; Valid
mov rax, [rcx]              ; Valid
mov rax, [r15]              ; Valid (extended register)
mov rax, [rsp]              ; Valid but may require special encoding
```

### Use Cases and Patterns

**Pointer Dereferencing**: Accessing data through pointers matches C/C++ pointer operations:

```c
// C code
int *ptr = &value;
int x = *ptr;
```

```nasm
; Assembly equivalent
mov rax, [ptr_address]      ; Load pointer into RAX
mov ebx, [rax]              ; Dereference: load value pointed to by RAX
```

**Dynamic Memory Access**: When memory locations are determined at runtime:

```nasm
; Allocate memory, address returned in RAX
call malloc
mov [rax], rbx              ; Store data to allocated memory
mov rcx, rax                ; Save pointer for later use
```

**Structure Member Access**: Combined with displacement for structure fields:

```nasm
; struct Point { int x; int y; }
; Point *p;
mov rax, [p_address]        ; Load structure pointer
mov ebx, [rax]              ; Access p->x (offset 0)
mov ecx, [rax + 4]          ; Access p->y (offset 4)
```

### Register Indirect with Displacement

Adding a constant displacement to the base register enables offset access:

```nasm
mov rax, [rbx + 8]          ; Load from address RBX + 8
mov rax, [rbx - 16]         ; Load from address RBX - 16
mov byte [rcx + 100], 0xFF  ; Store byte at RCX + 100
```

Displacements can be:

- **8-bit signed**: -128 to +127, encoded in one byte
- **32-bit signed**: -2,147,483,648 to +2,147,483,647, encoded in four bytes

The assembler automatically selects the smallest encoding. Using smaller displacements produces more compact code [Inference about code size optimization].

**Structure and Array Access**: Displacement-based addressing naturally maps to structure members and fixed array indices:

```nasm
; struct Data {
;     int field1;      // offset 0
;     int field2;      // offset 4
;     char field3;     // offset 8
; }
mov rax, [struct_ptr]       ; Load structure pointer
mov ebx, [rax + 0]          ; Access field1
mov ecx, [rax + 4]          ; Access field2
mov dl, [rax + 8]           ; Access field3
```

**Stack Frame Access**: Function local variables and parameters accessed relative to RBP:

```nasm
; Function prologue
push rbp
mov rbp, rsp
sub rsp, 32                 ; Allocate 32 bytes for locals

; Access local variables
mov dword [rbp - 4], 100    ; Local variable at RBP - 4
mov dword [rbp - 8], 200    ; Local variable at RBP - 8

; Access function parameters (assuming standard calling convention)
mov rax, [rbp + 16]         ; First parameter (after return address and saved RBP)
mov rbx, [rbp + 24]         ; Second parameter
```

