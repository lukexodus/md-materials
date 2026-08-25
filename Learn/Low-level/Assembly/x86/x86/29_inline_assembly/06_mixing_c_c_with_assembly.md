## Mixing C/C++ with Assembly


### Variable Access Patterns

**Reading C variables in assembly:**

```c
int src = 42;
int dst;

// GCC
asm (
    "movl %1, %0"
    : "=r" (dst)
    : "r" (src)
);

// MSVC
__asm {
    mov eax, src
    mov dst, eax
}
```

**Modifying C variables:**

```c
int counter = 0;

// GCC
asm (
    "incl %0"
    : "+m" (counter)
    :
    : "cc"
);

// MSVC
__asm {
    inc counter
}
```

### Function Calls from Assembly

**[Inference]** When calling C functions from inline assembly, calling conventions must be manually managed:

```c
extern void my_function(int arg);

// GCC x86-64 (System V ABI)
int arg = 5;
asm volatile (
    "movl %0, %%edi\n\t"     // First argument in EDI
    "call my_function\n\t"
    :
    : "r" (arg)
    : "rdi", "rax", "rcx", "rdx", "rsi", "r8", "r9", "r10", "r11", "cc", "memory"
);
```

### Inline Assembly in Functions

**Complete function in inline assembly (GCC):**

```c
int add_asm(int a, int b) {
    int result;
    asm (
        "addl %2, %1\n\t"
        "movl %1, %0"
        : "=r" (result)
        : "r" (a), "r" (b)
        : "cc"
    );
    return result;
}
```

**MSVC function:**

```c
int add_asm(int a, int b) {
    __asm {
        mov eax, a
        add eax, b
        // Result already in EAX per calling convention
    }
}
```

### Register Preservation

**[Inference]** Inline assembly must preserve callee-saved registers according to the platform ABI:

**x86-32 (cdecl):** EBX, ESI, EDI, EBP, ESP must be preserved

**x86-64 (System V):** RBX, RSP, RBP, R12-R15 must be preserved

**x86-64 (Windows):** RBX, RBP, RDI, RSI, RSP, R12-R15 must be preserved

```c
// Preserving EBX in GCC
asm (
    "push %%ebx\n\t"
    "cpuid\n\t"
    "mov %%ebx, %0\n\t"
    "pop %%ebx"
    : "=r" (ebx_value)
    : "a" (function)
    : "ecx", "edx", "cc"
);
```

### Optimization Barriers

The `volatile` keyword creates optimization barriers:

```c
// Without volatile - may be optimized away
asm ("nop");

// With volatile - always executed
asm volatile ("nop");
```

### Compiler Memory Barriers

```c
// Full memory barrier
asm volatile ("" ::: "memory");

// Prevents reordering across this point
int x = 1;
asm volatile ("" ::: "memory");
int y = 2;
```

### Inline Assembly with Loops

```c
int sum = 0;
int arr[100];

asm volatile (
    "xorl %%eax, %%eax\n\t"
    "movl $0, %%ecx\n\t"
    "1:\n\t"
    "addl (%1,%%ecx,4), %%eax\n\t"
    "incl %%ecx\n\t"
    "cmpl $100, %%ecx\n\t"
    "jl 1b\n\t"
    "movl %%eax, %0"
    : "=r" (sum)
    : "r" (arr)
    : "eax", "ecx", "cc"
);
```

### Macro Wrappers

Creating reusable inline assembly through macros:

```c
#define CPUID(func, a, b, c, d) \
    asm volatile ( \
        "cpuid" \
        : "=a" (a), "=b" (b), "=c" (c), "=d" (d) \
        : "a" (func) \
    )

uint32_t eax, ebx, ecx, edx;
CPUID(0, eax, ebx, ecx, edx);
```

### GCC vs MSVC Compatibility

For cross-compiler code:

```c
#ifdef _MSC_VER
    // MSVC version
    __asm {
        mov eax, value
        shl eax, 2
        mov result, eax
    }
#else
    // GCC version
    asm (
        "shll $2, %0"
        : "=r" (result)
        : "0" (value)
        : "cc"
    );
#endif
```

### Position-Independent Code (PIC)

**[Inference]** When compiling with `-fPIC`, special care is needed for global variable access:

```c
#if defined(__PIC__) || defined(__pic__)
    asm (
        "call __x86.get_pc_thunk.ax\n\t"
        "addl $_GLOBAL_OFFSET_TABLE_, %%eax\n\t"
        "movl global_var@GOT(%%eax), %%eax"
        : "=a" (result)
        :
        : "cc"
    );
#endif
```

### Inline Assembly Best Practices

**Key Points:**

- Use intrinsics instead of inline assembly when possible for better optimization
- Declare all modified registers in clobber list
- Use `volatile` when side effects are required
- Include `memory` clobber for operations affecting memory that compiler doesn't track
- Test across different optimization levels (`-O0`, `-O2`, `-O3`)
- Document the purpose and behavior of complex assembly blocks
- Be aware of calling conventions when interfacing with functions
- Consider portability implications (32-bit vs 64-bit, different compilers)

**Example:** Complete inline assembly implementation:

```c
// Atomic compare-and-swap
static inline int atomic_cas(int *ptr, int old_val, int new_val) {
    int prev;
    asm volatile (
        "lock; cmpxchgl %2, %1"
        : "=a" (prev), "+m" (*ptr)
        : "r" (new_val), "0" (old_val)
        : "memory", "cc"
    );
    return prev;
}
```

**Related topics:** Compiler intrinsics, calling conventions (cdecl, stdcall, fastcall, System V ABI, Microsoft x64), atomic operations, memory ordering, optimization levels, position-independent code (PIC/PIE)

---

