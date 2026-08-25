## Clobbers


Clobbers inform the compiler which registers or resources are modified by the assembly code beyond the declared outputs.

### Register Clobbers

```c
asm (
    "cpuid"
    : "=a" (eax), "=b" (ebx)
    : "a" (input)
    : "ecx", "edx"    // ECX and EDX are modified
);
```

### Special Clobbers

**`cc` - Condition codes clobber:**

Indicates that flags register is modified:

```c
asm (
    "addl %1, %0"
    : "+r" (result)
    : "r" (value)
    : "cc"            // Flags are modified
);
```

**`memory` - Memory clobber:**

Tells the compiler that assembly may read or write arbitrary memory locations, preventing optimization reordering:

```c
asm volatile (
    "lock; xaddl %0, %1"
    : "+r" (val), "+m" (*ptr)
    :
    : "memory", "cc"
);
```

The `memory` clobber is critical for:

- Atomic operations
- Memory barriers
- Direct memory manipulation that the compiler cannot track

### Clobber List Syntax

```c
asm (
    "assembly"
    : outputs
    : inputs
    : "rax", "rbx", "rcx", "memory", "cc"
);
```

