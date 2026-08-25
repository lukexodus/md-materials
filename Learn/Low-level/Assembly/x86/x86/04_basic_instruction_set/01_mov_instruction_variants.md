## MOV Instruction Variants


The MOV instruction transfers data between registers, memory locations, and immediate values. Despite its apparent simplicity, MOV encompasses numerous variants based on operand types, sizes, and addressing modes.

### Basic MOV Syntax

The general syntax follows the pattern: MOV destination, source

The destination receives a copy of the source value while the source remains unchanged. MOV does not affect any flags in the FLAGS/EFLAGS/RFLAGS register, distinguishing it from most other instructions.

### Register-to-Register MOV

Moving data between registers represents the fastest MOV operation, typically executing in a single cycle on modern processors [Inference based on typical processor behavior, actual timing varies by microarchitecture].

```nasm
mov rax, rbx        ; 64-bit register move
mov eax, ebx        ; 32-bit register move (zeros upper 32 bits of RAX)
mov ax, bx          ; 16-bit register move (preserves upper 48 bits of RAX)
mov al, bl          ; 8-bit register move (preserves upper 56 bits of RAX)
```

An important characteristic of 32-bit operations on 64-bit registers: writing to a 32-bit register (like EAX) automatically zeros the upper 32 bits of the corresponding 64-bit register (RAX). This behavior does not apply to 16-bit or 8-bit operations, which preserve the upper bits.

### Immediate-to-Register MOV

Loading immediate (constant) values into registers is fundamental for initialization and constant operations.

```nasm
mov rax, 0x1234567890ABCDEF  ; 64-bit immediate
mov eax, 0x12345678          ; 32-bit immediate
mov ax, 0x1234               ; 16-bit immediate
mov al, 0x12                 ; 8-bit immediate
```

In x86-64, the MOV instruction with 64-bit register destinations can accept full 64-bit immediates. However, many other instructions are limited to 32-bit immediates that are sign-extended to 64 bits.

### Memory-to-Register and Register-to-Memory MOV

Memory operands introduce addressing modes and require size specifications.

```nasm
mov rax, [rbx]              ; Load 64-bit value from memory address in RBX
mov eax, [rbx]              ; Load 32-bit value from memory address in RBX
mov ax, [rbx]               ; Load 16-bit value from memory address in RBX
mov al, [rbx]               ; Load 8-bit value from memory address in RBX

mov [rbx], rax              ; Store 64-bit value to memory address in RBX
mov [rbx], eax              ; Store 32-bit value to memory address in RBX
mov [rbx], ax               ; Store 16-bit value to memory address in RBX
mov [rbx], al               ; Store 8-bit value to memory address in RBX
```

Square brackets denote memory dereference. The size of the operation is determined by the register operand size. When ambiguity exists (such as immediate-to-memory moves), size specifiers are required:

```nasm
mov qword [rbx], 0x123      ; 64-bit store
mov dword [rbx], 0x123      ; 32-bit store
mov word [rbx], 0x123       ; 16-bit store
mov byte [rbx], 0x12        ; 8-bit store
```

### Complex Addressing Modes

x86 supports sophisticated addressing modes allowing computation of memory addresses using multiple components:

```nasm
mov rax, [rbx + 8]                    ; Base + displacement
mov rax, [rbx + rcx]                  ; Base + index
mov rax, [rbx + rcx * 4]              ; Base + index * scale
mov rax, [rbx + rcx * 8 + 16]         ; Base + index * scale + displacement
mov rax, [rcx * 4 + 0x1000]           ; Index * scale + displacement
```

The scale factor can only be 1, 2, 4, or 8, corresponding to the sizes of byte, word, dword, and qword elements in arrays.

### Segment Override Prefixes

While rarely used in flat memory models, segment override prefixes can specify alternative segment registers:

```nasm
mov rax, fs:[rbx]           ; Load from FS segment base + RBX
mov rax, gs:[0x28]          ; Load from GS segment base + 0x28
```

These are particularly relevant for accessing thread-local storage (TLS) and kernel data structures in modern operating systems.

### Special MOV Variants

**MOVSX (Move with Sign Extension)**: Copies a smaller value to a larger destination, extending the sign bit.

```nasm
movsx rax, byte [rbx]       ; Load signed byte, extend to 64 bits
movsx eax, word [rbx]       ; Load signed word, extend to 32 bits
movsx rax, dword [rbx]      ; Load signed dword, extend to 64 bits (x86-64 only)
```

**MOVZX (Move with Zero Extension)**: Copies a smaller value to a larger destination, filling upper bits with zeros.

```nasm
movzx rax, byte [rbx]       ; Load byte, zero-extend to 64 bits
movzx eax, word [rbx]       ; Load word, zero-extend to 32 bits
```

Note that MOVZX to 64-bit destinations actually zero-extends to 32 bits (using EAX instead of RAX), and the 32-bit operation automatically zeros the upper 32 bits of RAX.

**MOVSXD**: In x86-64, this instruction specifically sign-extends a 32-bit value to 64 bits.

```nasm
movsxd rax, dword [rbx]     ; Load signed dword, sign-extend to 64 bits
movsxd rax, ebx             ; Sign-extend EBX to RAX
```

### MOV Restrictions

Certain MOV operations are not permitted:

- Memory-to-memory moves (must use register as intermediate)
- Segment register to segment register moves (must use general-purpose register)
- Moving immediate values to segment registers (must use register intermediary)
- MOV cannot modify the instruction pointer directly

```nasm
; Invalid:
mov [rax], [rbx]            ; Cannot move memory to memory

; Valid alternatives:
mov rcx, [rbx]
mov [rax], rcx
```

### Conditional MOV (CMOVcc)

Conditional move instructions perform the move operation only if a specified condition is met, based on flag states:

```nasm
cmp rax, rbx
cmove rcx, rdx              ; Move RDX to RCX if equal (ZF=1)
cmovne rcx, rdx             ; Move RDX to RCX if not equal (ZF=0)
cmovg rcx, rdx              ; Move RDX to RCX if greater (signed)
cmova rcx, rdx              ; Move RDX to RCX if above (unsigned)
```

Conditional moves eliminate branch prediction penalties by avoiding conditional jumps [Inference about performance characteristics], though they always compute both paths.

