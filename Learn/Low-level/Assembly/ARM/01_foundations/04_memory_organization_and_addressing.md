## Memory Organization and Addressing


Understanding memory organization is essential for effective assembly programming, as the programmer directly controls memory access.

### Memory Address Space

Memory is organized as a linear array of bytes, each with a unique address. In 32-bit ARM, addresses range from 0x00000000 to 0xFFFFFFFF (4GB). In 64-bit ARM, the address space is theoretically much larger, though practical implementations use fewer address bits.

Addresses are typically expressed in hexadecimal for readability. Memory access uses byte addressing—each address refers to one byte—but ARM can access larger units (halfwords, words) from aligned addresses.

### Memory Layout Segments

Programs organize memory into distinct segments with different purposes:

**Text Segment (Code Segment)**: Contains executable instructions. Typically marked read-only to prevent accidental modification. Located at lower addresses in many systems.

**Data Segment**: Contains initialized global and static variables. Includes:

- **.data**: Initialized writable data
- **.rodata**: Read-only initialized data (constants)

**BSS Segment**: Contains uninitialized global and static variables, automatically zeroed at program startup. Name derives from "Block Started by Symbol."

**Heap**: Dynamic memory region that grows upward (toward higher addresses). Managed through allocation functions. Programmer controls allocation and deallocation.

**Stack**: Automatic memory region that grows downward (toward lower addresses). Stores local variables, function parameters, return addresses, and saved registers. Managed automatically by function call/return mechanisms.

The heap and stack grow toward each other, and exhausting the space between them causes stack overflow or heap exhaustion.

### Stack Organization

The stack operates as a Last-In-First-Out (LIFO) data structure. The **Stack Pointer (SP)** register points to the current top of the stack.

In ARM, the stack typically uses a **full descending** model:

- Full: SP points to the last occupied location
- Descending: Stack grows toward lower addresses

Pushing a value: decrement SP, then store value at SP Popping a value: load value from SP, then increment SP

ARM provides PUSH and POP instructions that handle multiple registers efficiently:

```
PUSH {r4-r7, lr}  @ Save registers on stack
POP {r4-r7, pc}   @ Restore registers from stack
```

### Stack Frames

Function calls create **stack frames** (activation records) containing:

- Function parameters beyond those passed in registers
- Return address (link register value)
- Saved register values
- Local variables

The **Frame Pointer (FP)**, often R11 in ARM, optionally points to a fixed location within the frame, simplifying access to local variables and parameters when stack size varies.

### Addressing Modes

ARM provides several addressing modes for memory access, specifying how to calculate the effective address:

**Immediate Offset**: Address = base register ± immediate constant

```
LDR r0, [r1, #4]    @ Load from address (r1 + 4)
```

**Register Offset**: Address = base register ± offset register

```
LDR r0, [r1, r2]    @ Load from address (r1 + r2)
```

**Scaled Register Offset**: Address = base register ± (offset register × scale)

```
LDR r0, [r1, r2, LSL #2]  @ Load from address (r1 + r2×4)
```

**Pre-indexed**: Calculate address, access memory, update base register

```
LDR r0, [r1, #4]!   @ Load from (r1+4), then r1 = r1+4
```

**Post-indexed**: Access memory at base register, then update base register

```
LDR r0, [r1], #4    @ Load from r1, then r1 = r1+4
```

Pre-indexed and post-indexed modes are efficient for array traversal and stack operations.

### Cache Considerations

Modern ARM processors include cache hierarchies that automatically store copies of frequently accessed memory. Understanding cache behavior helps optimize code:

**Spatial Locality**: Accessing nearby memory locations benefits from cache lines (typically 32-64 bytes) that load multiple adjacent bytes together. Sequential memory access patterns are cache-friendly.

**Temporal Locality**: Reusing recently accessed data finds it in cache. Organizing code to reuse data while still cached improves performance.

[Inference] Pointer chasing (following pointers through memory) often exhibits poor cache performance because each access depends on the previous one, and addresses may be scattered unpredictably.

### Memory-Mapped I/O

Peripheral devices often appear as memory locations in the address space. Reading or writing specific addresses interacts with hardware rather than actual memory.

**Example** accessing a memory-mapped register at 0x40000000:

```
LDR r1, =0x40000000  @ Load peripheral base address
LDR r0, [r1]         @ Read from peripheral
ORR r0, r0, #0x01    @ Modify value
STR r0, [r1]         @ Write back to peripheral
```

Memory-mapped I/O addresses may require special considerations like volatile access semantics and memory barriers to ensure correct ordering of operations.

### Memory Protection

Modern ARM processors include Memory Management Units (MMUs) that provide:

**Virtual Memory**: Programs use virtual addresses translated by the MMU to physical addresses. This allows memory isolation between processes and enables features like demand paging.

**Access Permissions**: Memory regions can be marked read-only, read-write, or execute-only. Attempts to violate permissions trigger exceptions.

**Memory Attributes**: Regions can be marked as cacheable, bufferable, or requiring specific ordering guarantees, critical for device memory.

These features are typically managed by operating systems, but understanding them helps debug issues and optimize performance-critical code.

**Key Points**

Understanding computer architecture fundamentals, number systems, data types, and memory organization forms the foundation for effective ARM assembly programming. The RISC philosophy of ARM emphasizes simple instructions operating on registers, with explicit load-store operations for memory access. Binary representation using two's complement enables efficient arithmetic with unified hardware. Data types range from 8-bit bytes to 64-bit doublewords, each with specific alignment requirements. Memory organizes into segments including code, data, heap, and stack, with various addressing modes providing flexible access patterns. These concepts interconnect—for instance, understanding two's complement explains why the same addition hardware works for both positive and negative numbers, and recognizing alignment requirements prevents performance penalties or faults when accessing memory.

---

