## GCC Inline Assembly Syntax


GCC uses extended asm syntax with a specific structure for integrating assembly with C/C++ code.

### Basic Asm Statement

```c
asm ("assembly code");
```

This basic form executes assembly instructions but provides no interface with C/C++ variables.

### Extended Asm Syntax

```c
asm volatile (
    "assembly template"
    : output operands        /* optional */
    : input operands         /* optional */
    : clobbers              /* optional */
);
```

The `volatile` keyword prevents the compiler from optimizing away the assembly block.

### Assembly Template

The assembly template contains the actual instructions with placeholders for operands:

```c
int a = 10, b = 20, result;
asm (
    "addl %1, %0"
    : "=r" (result)
    : "r" (a), "0" (b)
);
```

Operand references use `%0`, `%1`, `%2`, etc., corresponding to their position in the combined output and input operand lists (outputs numbered first).

### Operand Syntax Variants

GCC supports symbolic names for improved readability:

```c
asm (
    "addl %[input], %[output]"
    : [output] "=r" (result)
    : [input] "r" (value), "0" (result)
);
```

### AT&T vs Intel Syntax in GCC

GCC defaults to AT&T syntax but can use Intel syntax with the `.intel_syntax` directive:

```c
asm (
    ".intel_syntax noprefix\n\t"
    "add eax, ebx\n\t"
    ".att_syntax prefix"
    : output
    : input
    : clobbers
);
```

Or globally with compiler flags: `-masm=intel`

