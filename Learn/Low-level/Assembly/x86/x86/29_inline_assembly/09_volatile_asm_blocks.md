## Volatile asm Blocks


The `volatile` keyword in inline assembly prevents the compiler from optimizing away or moving the assembly code.

### Purpose of Volatile

**Preventing elimination**: Ensures the assembly executes even if outputs appear unused.

**Preserving execution order**: Guarantees the assembly executes at the specified point in the program flow.

**Side effects**: Indicates the code has effects beyond its visible inputs and outputs (I/O operations, memory-mapped hardware, timing).

### Syntax

```c
asm volatile (
    "assembly code"
    : outputs
    : inputs
    : clobbers
);
```

### When to Use Volatile

**Memory-mapped I/O**:

```c
asm volatile (
    "movl %0, %%fs:0x40"
    :
    : "r"(value)
    : "memory"
);
```

This writes to a specific memory location that might be hardware-mapped. Without `volatile`, the compiler might eliminate this if `value` appears unused.

**Timing-sensitive code**:

```c
asm volatile ("rdtsc" : "=a"(low), "=d"(high));
```

Reading the timestamp counter must happen at the exact point in execution where it appears.

**CPU instructions with side effects**:

```c
asm volatile ("cli");  // Disable interrupts
// Critical section
asm volatile ("sti");  // Enable interrupts
```

These instructions must execute in order and cannot be eliminated or reordered.

**Synchronization primitives**:

```c
asm volatile ("mfence" ::: "memory");
```

Memory fences must execute at specific points and cannot be removed or reordered.

### Volatile vs Memory Clobber

These serve different purposes:

`volatile`: Prevents the compiler from eliminating or moving the asm block.

`"memory"` clobber: Tells the compiler that the assembly may read or write any memory location, preventing memory operation reordering around the asm block.

**Example:**

```c
// Both volatile and memory clobber
asm volatile ("" ::: "memory");
```

This creates a full compiler memory barrier that prevents both elimination and memory operation reordering.

### Non-Volatile Assembly

Without `volatile`, the compiler may:

- Remove the assembly if outputs are unused
- Move the assembly to different locations
- Execute it fewer times than specified in the source (e.g., hoisting out of loops)

```c
int result;
asm ("addl $5, %0" : "=r"(result) : "0"(10));
// Compiler may eliminate this if result is never used
```

