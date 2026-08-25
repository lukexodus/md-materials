## Basic Syntax


The most common inline assembly syntax is GCC's extended asm format:

```c
asm [volatile] (
    "assembly code"
    : output operands
    : input operands
    : clobbered registers
);
```

Microsoft Visual C++ uses a different syntax:

```c
__asm {
    assembly instructions
}
```

Or single-line format:

```c
__asm assembly_instruction
```

