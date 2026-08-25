## Computer Architecture Fundamentals


Computer architecture defines the structural and functional organization of computer systems. ARM architecture follows a specific design philosophy that influences how programs execute at the hardware level.

### Processor Components

The processor contains several critical components that work together to execute instructions. The **Arithmetic Logic Unit (ALU)** performs mathematical and logical operations on data. The **Control Unit** decodes instructions and generates control signals to coordinate other components. **Registers** provide fast storage locations directly accessible by the processor, holding operands, addresses, and intermediate results.

### ARM Architecture Philosophy

ARM processors use a **Reduced Instruction Set Computer (RISC)** design philosophy. This approach emphasizes a smaller number of simple instructions that execute in a single cycle, contrasting with **Complex Instruction Set Computer (CISC)** designs that offer more complex instructions requiring multiple cycles.

The ARM architecture features a **load-store architecture**, meaning arithmetic operations only work on register operands. Data must be explicitly loaded from memory into registers before processing, and results must be stored back to memory through dedicated instructions.

### Instruction Execution Cycle

The processor executes instructions through a repeating cycle. During **fetch**, the processor retrieves the instruction from memory at the address stored in the Program Counter (PC). In the **decode** phase, the control unit interprets the instruction and identifies required operands. The **execute** phase performs the actual operation using the ALU or other functional units. Finally, **writeback** stores the result in the destination register or memory location.

Modern ARM processors implement **pipelining**, where multiple instructions occupy different stages simultaneously, increasing throughput. [Inference] This allows the processor to begin fetching the next instruction while still executing the current one.

### Register-Based Computation

ARM processors expose a set of general-purpose registers directly to the programmer. In ARMv7 (32-bit), there are 16 general-purpose registers (R0-R15), with R13 serving as the Stack Pointer (SP), R14 as the Link Register (LR), and R15 as the Program Counter (PC). In ARMv8 (64-bit), there are 31 general-purpose registers (X0-X30) plus a zero register and stack pointer.

Operations occur primarily in registers because register access is significantly faster than memory access. The limited number of registers makes efficient register allocation critical for performance.

### Memory Hierarchy

Computer systems organize memory in a hierarchy based on speed and capacity tradeoffs. Registers sit at the top, offering the fastest access but smallest capacity. **Cache memory** (L1, L2, L3) provides faster access than main memory by storing frequently accessed data. **Main memory (RAM)** offers larger capacity with slower access times. **Secondary storage** (disks, SSDs) provides persistent storage with the highest capacity and slowest access.

The processor automatically manages cache, but understanding memory hierarchy helps optimize code by improving **locality of reference**—accessing nearby memory locations in time (temporal locality) or space (spatial locality).

### Endianness

ARM processors support both **little-endian** and **big-endian** byte ordering, though little-endian is more common. In little-endian format, the least significant byte occupies the lowest memory address. For a 32-bit value 0x12345678 at address 0x1000:

Little-endian stores: 0x1000: 0x78, 0x1001: 0x56, 0x1002: 0x34, 0x1003: 0x12

Big-endian stores: 0x1000: 0x12, 0x1001: 0x34, 0x1002: 0x56, 0x1003: 0x78

