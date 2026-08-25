## Alternative Keywords and Attributes


Different compilers and standards provide variations on inline assembly syntax and control.

### __asm vs asm

**`asm`**: Standard keyword in C (since C23) and C++ (since C++98).

**`__asm`**: Compiler-specific extension supported by GCC, Clang, and MSVC for compatibility with older standards.

**`__asm__`**: GCC/Clang alternative that avoids conflicts when `asm` is used as an identifier.

```c
// All equivalent in GCC/Clang
asm ("nop");
__asm ("nop");
__asm__ ("nop");
```

### goto Attribute

GCC extended asm supports a `goto` qualifier for assembly that includes jump targets:

```c
asm goto (
    "jmp %l[label]"
    :
    :
    :
    : label
);
// other code
label:
// jump target
```

This allows assembly code to transfer control to C labels. The compiler understands the control flow and adjusts optimization accordingly.

**Key Points:**

- No output operands allowed with `goto`
- All possible jump targets must be listed after the fourth colon
- Useful for implementing fast paths or error handling

### inline Attribute

**[Inference]** Some compilers may support an `inline` attribute for asm blocks to hint that the assembly should be inlined when the containing function is inlined, though specific behavior varies by compiler implementation.

### Section Attributes

Assembly can be placed in specific code sections:

```c
__attribute__((section(".text.hot")))
void critical_function(void) {
    asm ("fast_path_code");
}
```

### Naked Functions

The `naked` attribute creates functions with no prologue or epilogue, often used with inline assembly:

```c
__attribute__((naked))
void bare_function(void) {
    asm ("movl $42, %eax\n\t"
         "ret");
}
```

**Key Points:**

- Function consists entirely of assembly
- No automatic register saving or stack frame setup
- Complete control over function entry and exit

### always_inline and noinline

These attributes interact with inline assembly:

```c
__attribute__((always_inline))
inline void must_inline(void) {
    asm volatile ("specialized_instruction");
}

__attribute__((noinline))
void no_inline(void) {
    asm ("code_that_must_be_called");
}
```

### Intel Syntax vs AT&T Syntax

GCC and Clang support dialect specification:

```c
// AT&T syntax (default)
asm ("movl $5, %eax");

// Intel syntax
asm (".intel_syntax noprefix\n\t"
     "mov eax, 5\n\t"
     ".att_syntax prefix");
```

Or using the dialect attribute **[Inference]** in some compiler versions:

```c
asm volatile (
    "mov eax, 5"
    : "=a"(result)
    :
    :
    :
    : "intel"  // [Inference] - dialect specification support varies
);
```

### MSVC-Specific Keywords

**`__declspec(naked)`**: Similar to GCC's naked attribute.

**`__forceinline`**: Aggressive inlining hint.

**`__fastcall`, `__stdcall`, `__cdecl`**: Calling conventions that affect register usage around inline assembly.

### Constraint Modifiers

Extended asm uses constraint strings with modifiers:

**`=`**: Write-only output operand

**`+`**: Read-write operand

**`&`**: Early clobber (written before all inputs are consumed)

**`%`**: Operand is commutative with the next

**Example:**

```c
asm ("addl %2, %0"
     : "=r"(result)    // Write-only output
     : "0"(value1),    // Same location as output 0
       "r"(value2));   // Input register
```

### Machine Constraints

Architecture-specific constraint letters:

**`a`, `b`, `c`, `d`**: Specific x86 registers (EAX, EBX, ECX, EDX)

**`r`**: Any general-purpose register

**`m`**: Memory operand

**`i`**: Immediate integer operand

**`g`**: General operand (register, memory, or immediate)

**Example:**

```c
unsigned long long timestamp;
asm volatile ("rdtsc"
    : "=a"(low), "=d"(high)  // Require EAX and EDX
);
timestamp = ((unsigned long long)high << 32) | low;
```

### Size Suffixes in Constraints

Some constraints support size specifications:

**`q`**: 64-bit register (R_x in x86-64)

**`Q`**: Registers accessible as 8-bit (A, B, C, D)

**`f`**: Floating-point register

**Example:**

```c
asm ("movq %1, %0"
     : "=q"(result64)
     : "q"(input64));
```

**Key Points:**

- `volatile` prevents elimination and reordering of assembly blocks
- Memory clobbers indicate potential reads/writes to any memory location
- Inline assembly creates optimization barriers that limit compiler transformations
- Different compilers support varying syntax and attributes for inline assembly
- Constraint strings precisely specify operand requirements and register allocation
- The `goto` qualifier enables assembly code to jump to C labels for control flow

**Important subtopics**: Memory barriers and ordering guarantees, clobber list specifications for different architectures, mixing inline assembly with LTO (Link-Time Optimization), debugging inline assembly code with source-level debuggers.

---

