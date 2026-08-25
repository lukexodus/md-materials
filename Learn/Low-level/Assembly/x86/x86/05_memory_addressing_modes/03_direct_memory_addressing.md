## Direct Memory Addressing


Direct memory addressing specifies a memory location using an absolute address or label. The instruction contains the complete memory address where the operand resides, and the CPU accesses that specific location.

**Absolute Address Syntax** uses square brackets to indicate memory access:

```nasm
mov rax, [0x601040]        ; Load 8 bytes from address 0x601040 into RAX
mov byte [0x601040], 0x42  ; Store byte value 0x42 at address 0x601040
add rax, [0x601048]        ; Add value at 0x601048 to RAX
```

The brackets distinguish memory operands from immediate values. Without brackets, `mov rax, 0x601040` loads the address itself into RAX. With brackets, `mov rax, [0x601040]` loads the value stored at that address.

**Label-Based Addressing** uses symbolic names instead of numeric addresses:

```nasm
section .data
    counter: dq 0
    message: db "Hello", 0
    array: times 10 dq 0

section .text
    mov rax, [counter]     ; Load value from counter variable
    mov [counter], rbx     ; Store RBX to counter variable
    lea rsi, [message]     ; Load address of message into RSI
```

Assemblers resolve labels to actual memory addresses during assembly. Labels provide readability and maintainability since programmers work with meaningful names rather than numeric addresses. Relocations allow the linker to adjust addresses when combining object files or loading programs at different base addresses.

**Operand Size Specifications** determine how many bytes to access:

```nasm
mov al, [address]          ; Load 1 byte
mov ax, [address]          ; Load 2 bytes
mov eax, [address]         ; Load 4 bytes
mov rax, [address]         ; Load 8 bytes
mov byte [address], 0      ; Store 1 byte
mov word [address], 0      ; Store 2 bytes (16 bits)
mov dword [address], 0     ; Store 4 bytes (32 bits)
mov qword [address], 0     ; Store 8 bytes (64 bits)
```

The register size or explicit size directive determines the access size. Ambiguous cases require size directives like BYTE, WORD, DWORD, or QWORD to clarify the programmer's intent.

**RIP-Relative Addressing** in x86-64 accesses memory relative to the instruction pointer:

```nasm
mov rax, [rel variable]    ; Load using RIP-relative addressing
mov rax, [variable]        ; NASM may use RIP-relative by default in 64-bit
```

Position-independent code uses RIP-relative addressing to access global data without absolute addresses. The CPU calculates the effective address by adding a displacement to the current RIP value. This addressing mode enables shared libraries and address space layout randomization (ASLR) security features.

**Segment Overrides** specify non-default segment registers:

```nasm
mov rax, [fs:0x28]         ; Access FS segment at offset 0x28
mov rbx, [gs:variable]     ; Access GS segment
```

Modern 64-bit operating systems use flat memory models where most segments overlap, but FS and GS segments provide thread-local storage and operating system data structures. Linux uses FS for thread-local variables, while Windows uses GS.

**Performance Considerations** for direct memory addressing involve cache behavior. Memory accesses hit L1 cache in 3-4 cycles, L2 cache in 10-12 cycles, L3 cache in 40-75 cycles, or main memory in 200+ cycles. Sequential memory accesses benefit from hardware prefetching where the CPU predicts and loads upcoming cache lines. Scattered accesses to random addresses suffer cache misses and memory latency. Aligning data to cache line boundaries (typically 64 bytes) can improve performance for frequently accessed structures.

