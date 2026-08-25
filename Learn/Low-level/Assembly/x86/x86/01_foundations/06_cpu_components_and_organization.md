## CPU Components and Organization


The x86 CPU contains multiple specialized components organized into functional units that execute assembly instructions.

**Registers** are the fastest storage locations inside the CPU. General-purpose registers in x86-64 include RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP, and R8-R15. These registers hold operands for arithmetic operations, memory addresses, function parameters, and temporary values. Special-purpose registers include the instruction pointer (RIP) which points to the next instruction, and the flags register (RFLAGS) which stores condition codes from operations.

**The Arithmetic Logic Unit (ALU)** performs arithmetic operations like addition, subtraction, multiplication, and division. It also executes logical operations including AND, OR, XOR, and NOT. Bit manipulation operations such as shifts and rotations occur in the ALU. After each operation, the ALU sets flags in RFLAGS to indicate results like zero, negative, overflow, or carry conditions.

**The Control Unit** manages instruction execution by fetching instructions from memory, decoding instruction opcodes to determine required operations, and generating control signals for other CPU components. It manages the instruction pipeline and handles exceptions and interrupts that alter normal program flow.

**The Floating-Point Unit (FPU)** executes floating-point arithmetic operations using separate registers (x87 stack or XMM/YMM/ZMM registers). Modern x86 processors include SIMD extensions like SSE, AVX, and AVX-512 that process multiple data elements simultaneously.

**Cache Memory** exists in multiple levels within or near the CPU. L1 cache is split into separate instruction and data caches with the smallest capacity but fastest access. L2 cache is larger and may be per-core or shared. L3 cache is the largest and typically shared across all cores. The Memory Management Unit (MMU) handles virtual-to-physical address translation using page tables and the Translation Lookaside Buffer (TLB).

