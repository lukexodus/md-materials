## Advanced Addressing Considerations


### Encoding Efficiency

Different addressing modes produce different instruction sizes:

**Register-to-Register**: Typically 2-3 bytes

```nasm
mov rax, rbx                    ; 3 bytes
```

**Register Indirect**: Typically 3-4 bytes

```nasm
mov rax, [rbx]                  ; 3 bytes
```

**Register Indirect with Displacement**: Size depends on displacement magnitude

```nasm
mov rax, [rbx + 8]              ; 4 bytes (8-bit displacement)
mov rax, [rbx + 1000]           ; 7 bytes (32-bit displacement)
```

**Scaled Index with Displacement**: Typically 4-8 bytes

```nasm
mov rax, [rbx + rcx*8]          ; 4 bytes
mov rax, [rbx + rcx*8 + 100]    ; 8 bytes
```

**RIP-Relative**: Typically 7 bytes

```nasm
mov rax, [rip + offset]         ; 7 bytes
```

Smaller instructions improve code density and instruction cache utilization [Inference].

### SIB Byte (Scale-Index-Base)

Complex addressing modes use the SIB (Scale-Index-Base) byte in instruction encoding:

- **Scale**: 2 bits encoding the scale factor (00=1, 01=2, 10=4, 11=8)
- **Index**: 3 bits specifying the index register
- **Base**: 3 bits specifying the base register

The SIB byte appears when:

- Using scaled index addressing
- Using base-plus-index addressing
- Using RSP or R12 as base register (even without index) [Inference about encoding requirements]

Understanding SIB byte encoding helps explain certain encoding peculiarities and size differences.

### REX Prefix in x86-64

x86-64 extended registers (R8-R15) and 64-bit operands require the REX prefix byte:

```nasm
mov rax, [rbx]                  ; No REX needed for 64-bit operation
mov rax, [r15]                  ; REX prefix needed for R15
mov r8, [rbx]                   ; REX prefix needed for R8
mov r15, [r14]                  ; REX prefix needed for both
```

REX prefix adds one byte to instruction size.

### Address Size Override Prefix

In 64-bit mode, address calculations default to 64-bit. The address size override prefix forces 32-bit addressing:

```nasm
mov rax, [eax]                  ; 32-bit address (requires override prefix)
mov rax, [rax]                  ; 64-bit address (default)
```

32-bit addressing is rarely useful in 64-bit mode and typically avoided.

### Alignment Considerations

Memory access performance benefits from proper alignment [Inference based on general architectural principles]:

**Natural Alignment**: Data should be aligned to its size

- 2-byte (word): aligned to 2-byte boundary
- 4-byte (dword): aligned to 4-byte boundary
- 8-byte (qword): aligned to 8-byte boundary
- 16-byte (xmmword): aligned to 16-byte boundary

```nasm
; Example: ensuring 16-byte alignment
and rsp, -16                    ; Align RSP to 16-byte boundary
```

Unaligned access may incur performance penalties or exceptions on certain architectures [Unverified: behavior varies by processor model and configuration].

### Cache Line Considerations

Modern processors use cache lines (typically 64 bytes). Addressing patterns affecting cache usage:

**Spatial Locality**: Accessing nearby memory locations benefits from cache line prefetching [Inference].

```nasm
; Good: sequential access (cache-friendly)
xor rcx, rcx
loop_start:
    mov rax, [rbx + rcx*8]      ; Access array sequentially
    ; Process rax
    inc rcx
    cmp rcx, array_size
    jl loop_start
```

**Cache Line Splits**: Accesses spanning cache line boundaries may cause performance penalties [Inference].

### Segment Register Usage

While segment registers are largely vestigial in flat memory models, FS and GS serve specific purposes:

**Thread-Local Storage** (FS on Windows, GS on Linux):

```nasm
; Windows: accessing thread environment block (TEB)
mov rax, [fs:0x30]              ; Load PEB pointer from TEB

; Linux: accessing thread-local variable
mov rax, [fs:tls_offset]        ; Access thread-local storage
```

**Kernel Data Structures** (typically GS):

```nasm
; Accessing per-CPU data in kernel mode
mov rax, [gs:cpu_offset]        ; Access per-CPU variable
```

### Null Pointer Dereference Detection

The first page of memory (typically 4KB) is unmapped on most operating systems. Accessing memory at low addresses triggers a page fault:

```nasm
mov rax, 0
mov rbx, [rax]                  ; Dereference null pointer - triggers segfault
mov rbx, [rax + 4]              ; Still in unmapped page - triggers segfault
```

This mechanism catches null pointer dereferences, though accessing structure members at high offsets might not trigger faults if the offset exceeds the guard page size [Inference about protection mechanism behavior].

**Key Points**

Register indirect addressing uses a register containing a pointer to access memory, with optional displacement for structure member access and stack frame operations. Base-plus-index addressing combines two registers for dynamic address calculation, supporting two-dimensional arrays and complex data structures, with RSP prohibited as the index register. Scaled index addressing multiplies an index register by 1, 2, 4, or 8 before adding to the base, directly mapping to array element sizes and eliminating manual multiplication for common data types. RIP-relative addressing calculates addresses relative to the instruction pointer using 32-bit signed displacement (±2GB range), enabling position-independent code, ASLR support, and efficient static data access in x86-64. The general address formula EA = Base + (Index × Scale) + Displacement allows combinations of these modes, though RIP-relative cannot be combined with base or index registers. Instruction encoding size varies by addressing mode complexity, with simple register operations being smallest and complex scaled addressing with large displacements being largest. LEA (Load Effective Address) instruction computes addresses without memory access, enabling efficient arithmetic operations using addressing mode hardware. Modern x86-64 systems primarily use flat memory models with segment bases of zero, except FS and GS segments which provide thread-local storage and kernel data structure access.

**Important related topics**: Instruction encoding and ModR/M byte structure, LEA instruction for non-memory computations, segment registers and descriptor tables in protected mode, memory alignment and cache optimization, position-independent executables (PIE) and dynamic linking, calling conventions and parameter passing mechanisms, SIMD memory operations and alignment requirements, hardware prefetching and memory access patterns

---

