## Computer Architecture Fundamentals


### Von Neumann Architecture

The Von Neumann architecture is the foundational model for most modern computers. It consists of:

**Central Processing Unit (CPU):** Executes instructions and performs computations.

**Memory:** Stores both program instructions and data in the same address space.

**Input/Output (I/O):** Interfaces for communication with external devices.

**Bus System:** Pathways for transferring data between components.

**Key Characteristic:** Instructions and data share the same memory and bus system. This creates the "Von Neumann bottleneck" where the CPU must wait for memory access.

### Harvard Architecture

An alternative to Von Neumann architecture where instruction memory and data memory are physically separated with independent buses. This allows simultaneous access to instructions and data.

Modern CPUs often use a modified Harvard architecture internally (separate L1 instruction and data caches) while presenting a Von Neumann interface externally.

### CPU Components

**Control Unit (CU):** Directs operation of the processor. It fetches instructions from memory, decodes them, and coordinates execution by sending control signals to other components.

**Arithmetic Logic Unit (ALU):** Performs arithmetic operations (addition, subtraction) and logical operations (AND, OR, NOT, XOR). The ALU operates on data from registers and sets flags based on results.

**Registers:** High-speed storage locations within the CPU for temporary data storage. Registers are the fastest memory available to the processor.

**Cache Memory:** Small, fast memory between the CPU and main memory. Modern processors typically have multiple cache levels (L1, L2, L3) with increasing size and latency.

### x86 Register Architecture

**General Purpose Registers (32-bit):**

- EAX: Accumulator for arithmetic operations
- EBX: Base register for memory addressing
- ECX: Counter for loops and string operations
- EDX: Data register for I/O and arithmetic extensions
- ESI: Source index for string operations
- EDI: Destination index for string operations
- EBP: Base pointer for stack frame addressing
- ESP: Stack pointer for stack top

**64-bit Extensions:** In x86-64 (also called AMD64 or x64), these registers are extended to 64 bits:

- RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP
- Additional registers: R8-R15

**Segment Registers:**

- CS: Code Segment
- DS: Data Segment
- SS: Stack Segment
- ES, FS, GS: Extra Segments

**Instruction Pointer:**

- EIP (32-bit) or RIP (64-bit): Points to the next instruction to execute

**Flags Register (EFLAGS/RFLAGS):** Contains status flags and control flags:

- CF: Carry Flag (set on unsigned overflow)
- PF: Parity Flag (set if result has even number of 1 bits)
- AF: Auxiliary Carry Flag (used for BCD arithmetic)
- ZF: Zero Flag (set if result is zero)
- SF: Sign Flag (set if result is negative)
- OF: Overflow Flag (set on signed overflow)
- DF: Direction Flag (controls string operation direction)
- IF: Interrupt Enable Flag

### Memory Hierarchy

Memory systems are organized in a hierarchy based on speed, size, and cost:

**Registers:** Fastest, smallest capacity (dozens of bytes), located in CPU core. Access time: less than 1 nanosecond.

**L1 Cache:** Very fast, small capacity (typically 32-64 KB per core), split into instruction and data caches. Access time: approximately 1-4 cycles.

**L2 Cache:** Fast, medium capacity (typically 256 KB to 1 MB per core). Access time: approximately 10-20 cycles.

**L3 Cache:** Moderately fast, larger capacity (typically 8-32 MB shared across cores). Access time: approximately 40-75 cycles.

**Main Memory (RAM):** Slower, large capacity (gigabytes). Access time: approximately 200-300 cycles (60-100 nanoseconds).

**Secondary Storage (SSD/HDD):** Much slower, very large capacity (terabytes). Access time: microseconds (SSD) to milliseconds (HDD).

**Principle of Locality:** Programs tend to access a relatively small portion of their address space at any given time. This principle makes caching effective:

- Temporal locality: Recently accessed items likely to be accessed again soon
- Spatial locality: Items near recently accessed items likely to be accessed soon

### Instruction Execution Cycle (Fetch-Decode-Execute)

The basic cycle that CPUs follow to execute instructions:

**Fetch:** The Control Unit retrieves the instruction from memory at the address stored in the instruction pointer. The instruction pointer is then incremented to point to the next instruction.

**Decode:** The Control Unit interprets the instruction, determining what operation to perform and what operands are needed. This involves identifying the opcode and extracting operand specifiers.

**Execute:** The ALU or other functional units perform the operation specified by the instruction. This may involve:

- Reading data from registers or memory
- Performing computation
- Writing results to registers or memory
- Updating flags

**Memory Access (if needed):** Load or store data from/to memory.

**Write Back:** Store the result in the destination register or memory location.

Modern processors use pipelining to overlap these stages for multiple instructions, improving throughput.

### Memory Addressing

**Physical Address:** The actual address in hardware memory chips.

**Logical Address:** The address generated by the CPU (also called virtual address in systems with virtual memory).

**Segmentation:** Memory divided into segments (code, data, stack). A logical address consists of a segment selector and an offset. The segment base address is added to the offset to form a linear address.

**Paging:** Memory divided into fixed-size pages (typically 4 KB). The Memory Management Unit (MMU) translates linear addresses to physical addresses using page tables. This enables virtual memory, allowing programs to use more memory than physically available.

### Instruction Set Architecture (ISA)

The ISA defines the interface between software and hardware, specifying:

- Available instructions and their encoding
- Register set and organization
- Memory addressing modes
- Data types and sizes
- Interrupt and exception handling

**x86 ISA Characteristics:**

- Complex Instruction Set Computer (CISC) architecture
- Variable-length instructions (1 to 15 bytes)
- Rich instruction set with specialized instructions
- Multiple addressing modes
- Backward compatibility (16-bit → 32-bit → 64-bit)

### Endianness

Endianness refers to the byte order in which multi-byte values are stored in memory.

**Little-Endian (x86):** Least significant byte stored at the lowest memory address.

**Example:** Value: 0x12345678 stored at address 0x1000

```
Address: 0x1000  0x1001  0x1002  0x1003
Value:     78      56      34      12
```

**Big-Endian:** Most significant byte stored at the lowest memory address.

**Example:** Value: 0x12345678 stored at address 0x1000

```
Address: 0x1000  0x1001  0x1002  0x1003
Value:     12      34      56      78
```

Little-endian is natural for little-endian architectures like x86 because the least significant byte is at the "smallest" (lowest) address.

### Stack Architecture

The stack is a Last-In-First-Out (LIFO) data structure used for:

- Temporary storage of data
- Function call management (return addresses, parameters)
- Local variable storage
- Saving and restoring register state

**Stack Growth:** On x86, the stack grows downward (toward lower memory addresses). The stack pointer (ESP/RSP) points to the top of the stack.

**Push Operation:** Decrements stack pointer, then stores value at the new stack pointer location.

**Pop Operation:** Retrieves value at stack pointer location, then increments stack pointer.

**Stack Frame:** A portion of the stack allocated for a single function call, containing:

- Return address
- Saved base pointer
- Function parameters
- Local variables

The base pointer (EBP/RBP) points to a fixed location within the stack frame, allowing consistent access to parameters and local variables.

### Interrupts and Exceptions

**Interrupts:** Signals that cause the CPU to temporarily suspend current execution and transfer control to an interrupt handler.

**Hardware Interrupts:** Generated by external devices (keyboard, timer, disk controller). These are asynchronous to program execution.

**Software Interrupts:** Triggered by executing specific instructions (INT instruction in x86). Used for system calls and OS services.

**Exceptions:** Synchronous events generated by the CPU during instruction execution:

- Faults: Correctable errors (page fault, divide by zero)
- Traps: Intentional exceptions for debugging (breakpoints)
- Aborts: Severe errors indicating hardware failure or corruption

**Interrupt Handling:**

1. CPU saves current state (flags, instruction pointer)
2. CPU looks up handler address in Interrupt Descriptor Table (IDT)
3. CPU transfers control to handler
4. Handler executes
5. Handler returns, restoring saved state

