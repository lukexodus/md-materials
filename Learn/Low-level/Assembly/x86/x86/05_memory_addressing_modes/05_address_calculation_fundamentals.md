## Address Calculation Fundamentals


Before examining specific addressing modes, understanding the general address calculation formula is essential. In x86 architecture, the effective address (EA) for memory operands follows this pattern:

EA = Base + (Index × Scale) + Displacement

Where:

- **Base**: A general-purpose register containing a base address
- **Index**: A general-purpose register containing an index value
- **Scale**: A multiplier that can be 1, 2, 4, or 8
- **Displacement**: A signed constant offset encoded in the instruction

Not all components are required for every addressing mode. Various combinations create different addressing modes, from simple register indirect to complex scaled indexed addressing.

### Segment Base Addition

In protected mode and long mode with flat memory models, segment bases are typically zero, making them transparent to programmers. However, the complete address calculation includes:

Linear Address = Segment Base + Effective Address

The FS and GS segments retain functionality in x86-64 and are commonly used for thread-local storage and operating system data structures, requiring explicit segment override prefixes.

### Operand Size and Address Size

Two distinct sizes affect memory operations:

**Operand Size**: Determines how many bytes are accessed from memory (8, 16, 32, 64 bits). This is specified by the register size or explicit size qualifiers (byte, word, dword, qword).

**Address Size**: Determines the width of the effective address calculation (16, 32, or 64 bits). In 64-bit long mode, addresses are calculated as 64-bit values (though typically only 48 or 57 bits are actually used).

```nasm
mov al, [rax]               ; 8-bit operand, 64-bit address
mov eax, [rax]              ; 32-bit operand, 64-bit address
mov rax, [eax]              ; 64-bit operand, 32-bit address (unusual, requires prefix)
```

