## Memory Hierarchy and Addressing


The memory hierarchy organizes storage by speed, size, and cost, creating a pyramid where faster memory is smaller and more expensive.

**Registers** occupy the top level with access times under 1 nanosecond and typical capacity of hundreds of bytes. Assembly instructions directly reference registers by name (RAX, RBX, etc.). Register access requires no memory bus transactions.

**Cache levels** form the next tier. L1 cache provides 1-3 nanosecond access times with 32-64 KB capacity per core. L2 cache offers 3-10 nanosecond access with 256 KB to 1 MB per core. L3 cache delivers 10-20 nanosecond access with 2-32 MB shared across cores. The CPU automatically manages cache contents using replacement policies, though programmers can optimize for cache behavior.

**Main Memory (RAM)** sits below cache with 50-100 nanosecond access times and gigabytes of capacity. Assembly programs use memory addresses to access RAM. The processor loads data from RAM into registers before manipulation and stores results back to RAM.

**Secondary Storage** includes SSDs with microsecond access times and hard drives with millisecond access times. These devices provide terabytes of persistent storage but require operating system involvement for access from assembly programs.

**Memory Addressing Modes** in x86 assembly determine how instructions specify memory locations:

Immediate addressing embeds constant values directly in instructions: `mov rax, 42`

Register addressing uses register contents as operands: `mov rax, rbx`

Direct memory addressing specifies absolute memory addresses: `mov rax, [0x601040]`

Register indirect addressing uses register contents as memory addresses: `mov rax, [rbx]`

Indexed addressing combines base register and offset: `mov rax, [rbx + 8]`

Base-index addressing uses two registers: `mov rax, [rbx + rcx]`

Base-index-displacement combines base, index, scale factor, and displacement: `mov rax, [rbx + rcx*4 + 8]`

**Virtual Memory** creates an abstraction where each process sees a continuous address space regardless of physical RAM layout. The MMU translates virtual addresses to physical addresses using page tables. Pages are fixed-size blocks (typically 4 KB) that map virtual to physical memory. When programs access unmapped virtual addresses, page faults occur, allowing the operating system to load data from disk or handle errors.

**Segmentation** in x86 architecture divides memory into segments with different purposes. Code segment (CS) contains executable instructions. Data segment (DS) holds global and static variables. Stack segment (SS) stores the call stack. Extra segments (ES, FS, GS) provide additional data access. Modern 64-bit operating systems use flat memory models where segmentation plays a minimal role, with virtual memory providing protection and isolation.

**Key Points:**
- Von Neumann architecture combines instruction and data in shared memory, creating the bottleneck between CPU and memory
- CPU organization separates functions into ALU, control unit, registers, FPU, and cache hierarchy
- Memory hierarchy trades speed for capacity, from sub-nanosecond registers to millisecond disk storage
- x86 addressing modes provide flexible ways to specify operands using immediates, registers, and complex memory calculations
- Virtual memory and paging allow processes to use more address space than physical RAM while providing isolation

---

