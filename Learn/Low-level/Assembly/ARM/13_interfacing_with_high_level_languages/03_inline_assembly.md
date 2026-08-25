## Inline Assembly


Inline assembly allows embedding assembly instructions directly within C/C++ code. GCC uses extended asm syntax providing tight integration between C and assembly with compiler-managed register allocation.

**GCC Inline Assembly Syntax:**

```c
asm [volatile] (
    "assembly code"
    : output operands          /* optional */
    : input operands           /* optional */
    : clobbered registers      /* optional */
);
```

**Basic Example - No operands:**

```c
void enable_interrupts(void) {
    asm volatile ("CPSIE i");  // Clear PRIMASK (enable interrupts)
}

void disable_interrupts(void) {
    asm volatile ("CPSID i");  // Set PRIMASK (disable interrupts)
}
```

The `volatile` keyword prevents compiler optimization from removing or reordering the assembly.

**Example - Single input operand:**

```c
void delay(int count) {
    asm volatile (
        "1: SUBS %0, %0, #1\n"
        "   BNE 1b\n"
        : "+r" (count)         // +r means read-write register
    );
}
```

**Example - Input and output operands:**

```c
int add_asm(int a, int b) {
    int result;
    asm (
        "ADD %[res], %[x], %[y]"
        : [res] "=r" (result)  // Output: =r means write-only register
        : [x] "r" (a),         // Input: r means read-only register
          [y] "r" (b)
    );
    return result;
}
```

**Constraint Codes:**

**Register Constraints:**

- `r` - General-purpose register (R0-R15)
- `l` - Low register (R0-R7)
- `h` - High register (R8-R15)
- `w` - VFP/NEON register
- `t` - VFP single-precision register (S0-S31)

**Memory Constraints:**

- `m` - Memory operand
- `Q` - Memory with offset addressing
- `o` - Offsetable memory

**Immediate Constraints:**

- `I` - Immediate constant (0-255)
- `J` - Immediate constant (-4095 to 4095)
- `K` - Immediate constant (~I)
- `L` - Immediate constant (~J)
- `M` - Power of 2 or power of 2 minus 1

**Modifiers:**

- `=` - Write-only operand
- `+` - Read-write operand
- `&` - Early clobber (output modified before all inputs consumed)

**Example - Multiple instructions:**

```c
uint32_t read_cpsr(void) {
    uint32_t cpsr;
    asm volatile (
        "MRS %0, CPSR"
        : "=r" (cpsr)
    );
    return cpsr;
}

void write_cpsr(uint32_t cpsr) {
    asm volatile (
        "MSR CPSR_c, %0"
        :
        : "r" (cpsr)
    );
}
```

**Example - Clobber list:**

```c
int multiply_add(int a, int b, int c) {
    int result;
    asm (
        "MUL R12, %1, %2\n"    // Use R12 as temporary
        "ADD %0, R12, %3"
        : "=r" (result)
        : "r" (a), "r" (b), "r" (c)
        : "r12"                // R12 is clobbered
    );
    return result;
}
```

**Example - Memory operand:**

```c
void atomic_increment(int *ptr) {
    asm volatile (
        "LDREX R0, [%0]\n"     // Load exclusive
        "ADD R0, R0, #1\n"
        "STREX R1, R0, [%0]\n" // Store exclusive
        "CMP R1, #0\n"
        "BNE .-12"             // Retry if failed
        :
        : "r" (ptr)
        : "r0", "r1", "memory" // Memory clobber important
    );
}
```

The `"memory"` clobber tells the compiler that memory has been modified, preventing reordering of memory accesses across the asm block.

**Example - NEON inline assembly:**

```c
#include <arm_neon.h>

void vector_add_asm(float *a, float *b, float *result, int n) {
    for (int i = 0; i < n; i += 4) {
        asm (
            "VLD1.32 {D0, D1}, [%1]!\n"    // Load a
            "VLD1.32 {D2, D3}, [%2]!\n"    // Load b
            "VADD.F32 Q2, Q0, Q1\n"        // Add
            "VST1.32 {D4, D5}, [%0]!\n"    // Store result
            : "+r" (result), "+r" (a), "+r" (b)
            :
            : "q0", "q1", "q2", "memory"
        );
    }
}
```

**Example - Conditional execution:**

```c
int conditional_add(int a, int b, int condition) {
    int result = a;
    asm (
        "CMP %2, #0\n"
        "ADDNE %0, %0, %1"
        : "+r" (result)
        : "r" (b), "r" (condition)
        : "cc"                 // Condition codes clobbered
    );
    return result;
}
```

**Example - Barrier instructions:**

```c
void memory_barrier(void) {
    asm volatile ("DMB" ::: "memory");
}

void data_sync_barrier(void) {
    asm volatile ("DSB" ::: "memory");
}

void instruction_sync_barrier(void) {
    asm volatile ("ISB" ::: "memory");
}
```

**Example - Coprocessor access:**

```c
uint32_t get_control_register(void) {
    uint32_t value;
    asm volatile (
        "MRC p15, 0, %0, c1, c0, 0"
        : "=r" (value)
    );
    return value;
}

void set_control_register(uint32_t value) {
    asm volatile (
        "MCR p15, 0, %0, c1, c0, 0"
        :
        : "r" (value)
    );
}
```

**Example - Named register variables:**

```c
// Force specific register allocation
register int r4_val asm("r4");

void use_specific_register(void) {
    r4_val = 42;
    asm volatile (
        "ADD R5, R4, #10"  // R4 contains r4_val
        :
        :
        : "r5"
    );
}
```

**Example - Complex computation with temporary:**

```c
uint64_t multiply_64(uint32_t a, uint32_t b) {
    uint32_t low, high;
    asm (
        "UMULL %0, %1, %2, %3"
        : "=r" (low), "=r" (high)
        : "r" (a), "r" (b)
    );
    return ((uint64_t)high << 32) | low;
}
```

**Best Practices for Inline Assembly:**

[Inference based on compiler behavior and optimization considerations]

**Minimize usage:** Inline assembly prevents many compiler optimizations. Use only when necessary for hardware access or performance-critical sections.

**Use volatile judiciously:** Only mark as volatile if side effects matter (I/O, synchronization). Omit volatile for pure computations allowing compiler optimization.

**Specify clobbers accurately:** Tell compiler about all modified registers and memory. Missing clobbers cause subtle bugs.

**Prefer intrinsics:** For NEON/VFP, intrinsics often generate better code than inline assembly while remaining readable.

**Keep it simple:** Complex inline assembly is difficult to debug and maintain. Consider separate assembly functions for complex code.

