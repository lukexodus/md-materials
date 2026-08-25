## Constraints


Constraints specify how operands interact with registers and memory. They define the requirements and restrictions for each operand.

### Output Constraints

**Output constraint modifiers:**

- `=` - Write-only operand (operand is overwritten)
- `+` - Read-write operand (operand is both read and written)
- `&` - Early clobber (operand is modified before all inputs are consumed)

```c
int result;
asm (
    "movl $42, %0"
    : "=r" (result)  // Write-only, any register
);
```

### Input Constraints

Input constraints specify how input values should be provided:

```c
int a = 5;
asm (
    "addl %1, %0"
    : "+r" (result)
    : "r" (a)        // Input in any register
);
```

### Common Constraint Letters

**Register constraints:**

- `r` - Any general-purpose register
- `a` - EAX/RAX register
- `b` - EBX/RBX register
- `c` - ECX/RCX register
- `d` - EDX/RDX register
- `S` - ESI/RSI register
- `D` - EDI/RDI register
- `q` - Any of EAX, EBX, ECX, EDX (32-bit)
- `x` - Any SSE register
- `y` - Any MMX register
- `f` - Floating-point register

**Memory constraints:**

- `m` - Memory operand
- `o` - Memory operand with offsettable address
- `V` - Memory operand that is not offsettable
- `g` - General operand (register, memory, or immediate)

**Immediate constraints:**

- `i` - Immediate integer operand
- `n` - Immediate integer with known value
- `I`, `J`, `K`, `L`, `M`, `N`, `O`, `P` - Architecture-specific immediate ranges

**Special constraints:**

- `0`, `1`, `2`, ... - Match specific operand number
- `X` - Any operand type

### Constraint Examples

```c
// Use EAX specifically for input
asm (
    "cpuid"
    : "=a" (eax_out), "=b" (ebx_out), "=c" (ecx_out), "=d" (edx_out)
    : "a" (function)
);

// Memory operand
int array[10];
asm (
    "movl $5, %0"
    : "=m" (array[3])
);

// Matching constraint (same location as operand 0)
int x = 10;
asm (
    "incl %0"
    : "+r" (x)    // or: "=r" (x) : "0" (x)
);
```

### Size Modifiers

Some architectures support size specification:

```c
asm (
    "movb %1, %0"     // Byte operation
    : "=r" (result)
    : "r" (value)
);
```

