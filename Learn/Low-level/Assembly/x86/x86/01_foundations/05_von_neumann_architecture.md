## Von Neumann Architecture


Von Neumann architecture is the fundamental computer design model where programs and data share the same memory space. This architecture forms the basis for most modern computers and directly influences how x86 assembly programs interact with hardware.

The architecture consists of four primary components that work together through a shared bus system. The Central Processing Unit (CPU) contains the control unit and arithmetic logic unit. Memory stores both instructions and data in a single address space. Input/Output devices handle communication with external systems. The bus system connects all components and transfers data, addresses, and control signals.

The stored-program concept is central to this architecture. Programs exist as data in memory, with instructions fetched sequentially from memory addresses. The program counter tracks the next instruction location, and instructions execute in the fetch-decode-execute cycle. This design allows programs to modify themselves during execution, though modern systems restrict this capability for security reasons.

The Von Neumann bottleneck describes the limitation where the single bus between CPU and memory creates a performance constraint. Only one memory access occurs at a time, whether fetching instructions or accessing data. Modern processors use caches, pipelining, and parallel execution units to mitigate this bottleneck, but the fundamental architectural limitation remains.

