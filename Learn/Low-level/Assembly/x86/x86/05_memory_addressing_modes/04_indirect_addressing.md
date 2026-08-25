## Indirect Addressing


Indirect addressing uses a register's contents as a memory address, allowing dynamic address calculation at runtime. This addressing mode enables array access, pointer dereferencing, and data structure traversal.

**Register Indirect Addressing** places a memory address in a register and uses brackets to indicate dereferencing:

```nasm
mov rax, [rbx]             ; Load value from address in RBX
mov [rcx], rdx             ; Store RDX to address in RCX
add rax, [rsi]             ; Add value at address in RSI to RAX
```

The register contains a pointer to the actual data location. The CPU reads the register to obtain the address, then accesses memory at that address. This two-step process enables flexible memory access patterns.

**Displacement Addressing** adds a constant offset to a base register:

```nasm
mov rax, [rbx + 8]         ; Load from address (RBX + 8)
mov rax, [rbx - 16]        ; Load from address (RBX - 16)
mov [rcx + 0x20], rdx      ; Store to address (RCX + 0x20)
```

The displacement allows accessing structure fields, array elements, or stack frame locations relative to a base pointer. Compilers use this mode extensively for accessing local variables (base pointer minus displacement) and structure members (base pointer plus field offset).

**Indexed Addressing** combines a base register and an index register:

```nasm
mov rax, [rbx + rcx]       ; Load from address (RBX + RCX)
mov [rsi + rdi], rax       ; Store to address (RSI + RDI)
```

One register typically holds a base address while the other contains an index or offset. This addressing mode supports array iteration where the base register points to the array start and the index register tracks the current position.

**Scaled Index Addressing** multiplies the index register by a scale factor (1, 2, 4, or 8) before adding:

```nasm
mov rax, [rbx + rcx*4]     ; Load from address (RBX + RCX*4)
mov rax, [rbx + rcx*8]     ; Load from address (RBX + RCX*8)
```

The scale factor matches common data sizes: 1 for bytes, 2 for words, 4 for doublewords, 8 for quadwords. This mode enables efficient array indexing without separate multiplication instructions. Arrays of integers, pointers, or structures benefit from scaled indexing.

**Complete Addressing Form** combines base, index, scale, and displacement:

```nasm
mov rax, [rbx + rcx*8 + 16]    ; Address = RBX + (RCX * 8) + 16
mov [rsi + rdi*4 - 8], rax     ; Address = RSI + (RDI * 4) - 8
```

The general form calculates: address = base + (index * scale) + displacement. This addressing mode accesses elements in arrays of structures: base points to the array start, index selects which element, scale accounts for element size, and displacement selects a field within the element.

**Array Access Examples** demonstrate common usage patterns:

```nasm
; int array[10]; access array[i] where array base is in RBX, i is in RCX
mov eax, [rbx + rcx*4]         ; Load array[i] (4-byte integers)

; long array[10]; access array[i]
mov rax, [rbx + rcx*8]         ; Load array[i] (8-byte longs)

; struct { int a; int b; } array[10]; access array[i].b
mov eax, [rbx + rcx*8 + 4]     ; Load array[i].b (offset 4 within struct)
```

**Pointer Dereferencing** implements operations common in C and C++:

```nasm
; int *ptr; Load value pointed to by ptr (ptr address in RBX)
mov eax, [rbx]                 ; Equivalent to *ptr

; ptr++; Advance pointer to next integer
add rbx, 4                     ; Move pointer by sizeof(int)

; *ptr = value; Store value through pointer
mov [rbx], eax                 ; Dereference and store
```

**Stack Frame Access** uses displacement addressing for local variables and parameters:

```nasm
; Function prologue establishes frame pointer
push rbp
mov rbp, rsp

; Access local variables (negative offsets from RBP)
mov rax, [rbp - 8]             ; Load first local variable
mov rbx, [rbp - 16]            ; Load second local variable

; Access parameters (positive offsets from RBP on stack)
mov rcx, [rbp + 16]            ; Load first parameter (after saved RBP and return address)
```

**Performance Implications** of indirect addressing depend on several factors. Register indirect adds minimal overhead beyond direct addressing, typically one additional cycle for address calculation. Indexed and scaled indexed addressing may add 1-2 cycles for the calculation but modern CPUs often hide this latency through pipelining. Cache performance dominates total access time regardless of addressing mode. Memory access patterns matter more than addressing complexity—sequential access performs better than random access even with complex addressing modes.

**Address Generation Interlock** can occur when an instruction uses a register that was just computed by a previous instruction. Modern processors have dedicated address generation units (AGUs) that calculate addresses in parallel with ALU operations, reducing or eliminating this penalty in most cases.

**Optimization Techniques** for indirect addressing include keeping frequently used pointers in registers to avoid reloading them, using LEA (load effective address) to perform address calculations without memory access, unrolling loops to reduce index register updates, and aligning frequently accessed data structures to cache line boundaries.

**LEA Instruction** calculates addresses without accessing memory:

```nasm
lea rax, [rbx + rcx*4 + 16]    ; RAX = RBX + (RCX * 4) + 16 (no memory access)
lea rsi, [rsi + 1]             ; Increment RSI (alternative to ADD)
lea rax, [rbx + rbx*2]         ; RAX = RBX * 3 (multiply by 3)
```

LEA performs the address calculation but stores the calculated address rather than accessing memory at that address. This instruction serves as a powerful arithmetic operation for certain calculations, especially multiplication by small constants through scale factors.

**Key Points:**
- Immediate addressing embeds constant values in instructions, providing fastest operand access with no additional memory reads
- Register addressing operates entirely within CPU registers, enabling sub-nanosecond access times and optimal performance
- Direct memory addressing specifies absolute or labeled memory locations, with RIP-relative variants supporting position-independent code
- Indirect addressing uses register contents as memory addresses, enabling dynamic access patterns for arrays, pointers, and structures
- Complete addressing form combining base, scaled index, and displacement supports efficient multi-dimensional array and structure member access
- LEA instruction calculates effective addresses without memory access, serving both address computation and arithmetic purposes
- Cache performance dominates memory access time regardless of addressing mode complexity

---

