## Instruction Set Architecture Concepts


ARM's instruction set architecture embodies RISC principles while incorporating pragmatic extensions for code density, performance, and specialized workloads. Understanding the ISA's fundamental concepts enables effective assembly programming and comprehension of compiler-generated code.

### Load/Store Architecture

ARM implements a pure load/store architecture where arithmetic and logical operations execute only on registers. Memory access occurs exclusively through dedicated load and store instructions. This separation simplifies pipeline design and enables aggressive instruction reordering for performance.

Load instructions transfer data from memory to registers (LDR, LDRB, LDRH, LDRSB, LDRSH). Store instructions transfer from registers to memory (STR, STRB, STRH). Multiple-register variants (LDP, STP, LDM, STM) transfer multiple registers in single operations, improving efficiency for stack operations and structure copying.

Addressing modes determine how memory addresses calculate. AArch64 supports base register addressing, base plus offset (immediate or register), pre-indexed (update base before access), and post-indexed (update base after access). PC-relative addressing enables position-independent code.

### Instruction Encoding and Formats

AArch64 instructions uniformly encode as 32-bit values, simplifying instruction fetch and decode. This fixed width contrasts with variable-length instruction sets like x86. The 32-bit encoding partitions into fields specifying opcode, operands, condition codes, and modifiers.

Most instructions follow a three-operand format: destination register, first source register, second source (register or immediate). For example, `ADD X0, X1, X2` computes X0 = X1 + X2. Some instructions use two-operand format where destination overwrites a source: `ADDS X0, X0, #1` increments X0.

Immediate values embed directly in instructions with encoding constraints. Logical immediates (AND, ORR, EOR) support specific patterns derived from rotating and replicating small bit patterns. Arithmetic immediates (ADD, SUB) support 12-bit values with optional 12-bit left shift, enabling constants 0-4095 or multiples of 4096. Large constants require loading from literal pools or constructing through multiple instructions (MOVZ, MOVK sequences).

### Conditional Execution

AArch64 eliminated the pervasive conditional execution present in AArch32 where almost every instruction could execute conditionally based on flags. Instead, AArch64 provides conditional select instructions (CSEL, CSINC, CSINV, CSNEG) and conditional compare instructions (CCMP, CCMN) for branchless conditional logic.

Condition codes derive from the NZCV flags in the processor status:
- **N (Negative)**: Result's most significant bit is 1 (signed negative)
- **Z (Zero)**: Result is zero
- **C (Carry)**: Unsigned overflow occurred (or borrow didn't occur for subtraction)
- **V (oVerflow)**: Signed overflow occurred

Common condition codes include EQ (equal, Z=1), NE (not equal, Z=0), LT (signed less than, N≠V), LE (signed less than or equal, Z=1 or N≠V), GT (signed greater than, Z=0 and N=V), GE (signed greater than or equal, N=V), LO/CC (unsigned lower/carry clear, C=0), HS/CS (unsigned higher or same/carry set, C=1), HI (unsigned higher, C=1 and Z=0), LS (unsigned lower or same, C=0 or Z=1).

Conditional branches (B.cond) test condition codes and branch if true. Compare and branch instructions (CBZ, CBNZ) compare register with zero and branch atomically without affecting flags. Test and branch instructions (TBZ, TBNZ) test individual bits and branch.

### Shift and Extend Operations

Many data-processing instructions accept shifted or extended operands as the second source, eliminating separate shift instructions. Available shifts include LSL (logical shift left), LSR (logical shift right), ASR (arithmetic shift right preserving sign), and ROR (rotate right).

For example, `ADD X0, X1, X2, LSL #2` computes X0 = X1 + (X2 << 2), useful for array indexing with element size 4. The shift amount can be immediate (0-31 for W registers, 0-63 for X registers) or register-specified in some instruction forms.

Extension operations sign-extend or zero-extend smaller values when mixing 32-bit and 64-bit operands. SXTB/SXTH/SXTW extend signed bytes/halfwords/words to register width. UXTB/UXTH extend unsigned values. Instructions like `ADD X0, X1, W2, SXTW` add sign-extended W2 to X1.

### Memory Ordering and Barriers

ARM implements a weakly-ordered memory model where memory accesses may complete out of program order unless explicitly constrained. This flexibility enables performance optimizations in hardware but requires careful synchronization in concurrent code.

Memory barrier instructions enforce ordering constraints. DMB (Data Memory Barrier) ensures memory accesses before the barrier complete before accesses after it. DSB (Data Synchronization Barrier) additionally waits for barriers to complete before proceeding. ISB (Instruction Synchronization Barrier) flushes pipelines and ensures subsequent instructions fetch with new context.

Load-acquire and store-release instructions (LDAR, STLR) provide acquire/release semantics matching C11/C++11 atomic operations. LDAR prevents subsequent memory accesses from being observed before the load. STLR prevents prior memory accesses from being observed after the store. These enable efficient lock-free programming patterns.

Exclusive access instructions (LDXR/LDAXR, STXR/STLXR) implement atomic read-modify-write sequences for synchronization primitives. The load-exclusive marks a memory address for exclusive access. The subsequent store-exclusive succeeds only if the exclusive state persists, returning status in a register. Pairing these implements compare-and-swap and other atomic operations.

### SIMD and Vector Processing

Advanced SIMD (NEON) instructions operate on vector registers performing multiple operations simultaneously. Operations support 8-bit, 16-bit, 32-bit, and 64-bit element sizes, with vector lengths of 64 bits (8 bytes) or 128 bits (16 bytes, quad-word).

Vector instructions commonly append shape specifiers indicating element size and count: .8B (8 bytes), .16B (16 bytes), .4H (4 halfwords), .8H (8 halfwords), .2S (2 single-precision floats), .4S (4 single-precision floats), .2D (2 double-precision floats).

NEON provides arithmetic (ADD, SUB, MUL, MLA, MLS), logical (AND, ORR, EOR, BIC), comparison (CMEQ, CMGT, CMGE), and specialized operations (absolute difference, saturating arithmetic, polynomial multiply). Vector load/store instructions transfer multiple elements between memory and vector registers (LD1, LD2, LD3, LD4, ST1, ST2, ST3, ST4) supporting various interleaving patterns for structure-of-arrays and array-of-structures access.

Scalable Vector Extension (SVE) introduces vector-length-agnostic programming where code operates on vectors of implementation-defined length (128 to 2048 bits in 128-bit increments). Programs query vector length at runtime and process data in vector-length-sized chunks, automatically utilizing wider vectors on processors that provide them. Predicate registers enable per-element masking for handling partial vectors and conditional operations. [Unverified: SVE availability and vector length vary by specific processor implementation.]

### Floating-Point Architecture

ARM floating-point follows IEEE 754 standards supporting single-precision (32-bit, S registers), double-precision (64-bit, D registers), and half-precision (16-bit, H registers) formats. Floating-point instructions include arithmetic (FADD, FSUB, FMUL, FDIV), multiply-accumulate (FMADD, FMSUB, FNMADD, FNMSUB), square root (FSQRT), conversion (FCVT), and comparison (FCMP, FCCMP).

The FPCR controls rounding modes (round to nearest, round toward positive/negative infinity, round toward zero), flush-to-zero behavior for denormals, and exception trapping. The FPSR reports exceptional conditions (invalid operation, division by zero, overflow, underflow, inexact result).

Fused multiply-add instructions compute (a × b) + c with single rounding, providing better accuracy and performance than separate multiply and add. These instructions are fundamental to matrix operations, signal processing, and numerical computation.

### Exception and Interrupt Handling

ARM defines four exception levels (EL0-EL3) representing increasing privilege. EL0 runs unprivileged application code. EL1 runs operating system kernels. EL2 runs hypervisors. EL3 runs secure monitors. Transitions between levels occur through synchronous exceptions (system calls, instruction faults) or asynchronous exceptions (interrupts).

Exception vectors organize into a table pointed to by VBAR_EL registers. Each exception level has vectors for synchronous exceptions, IRQ (normal interrupts), FIQ (fast interrupts), and SError (system errors), with separate vectors for different exception sources (same EL, lower EL with same execution state, lower EL with different execution state).

When exceptions occur, the processor saves PC to ELR_EL, saves processor state to SPSR_EL, updates PC to the appropriate vector address, and switches to the target exception level. Exception handlers examine syndrome registers (ESR_EL) to determine exception causes and address registers (FAR_EL) to identify faulting addresses for data/instruction aborts.

Exception return instructions (ERET) restore processor state from SPSR_EL and return address from ELR_EL, switching back to the exception origin.

### Position-Independent and Thread-Local Storage

Position-independent code (PIC) executes correctly regardless of absolute memory addresses, essential for shared libraries and ASLR security. ARM supports PIC through PC-relative addressing for instruction and data references. ADRP/ADD instruction pairs compute addresses relative to page boundaries. GOT (Global Offset Table) and PLT (Procedure Linkage Table) enable dynamic symbol resolution.

Thread-local storage (TLS) provides per-thread variables in multi-threaded programs. ARM implements TLS through special registers or reserved registers pointing to thread control blocks. Access models (Local Exec, Initial Exec, General Dynamic, Local Dynamic) balance performance and flexibility depending on whether code is executable, shared library, or requires runtime symbol resolution.

**Key Points:**
- ARM employs load/store architecture restricting memory access to dedicated instructions while computation occurs solely in registers
- AArch64 uses uniform 32-bit instruction encoding with three-operand format, contrasting with AArch32's variable-width instructions and two-operand bias
- Condition codes (NZCV flags) control conditional execution through conditional select and conditional branch instructions
- Weakly-ordered memory model requires explicit barriers (DMB, DSB, ISB) or acquire/release instructions (LDAR, STLR) for correct concurrent behavior
- SIMD/NEON processes multiple data elements simultaneously with support for 8/16/32/64-bit element sizes in 64-bit or 128-bit vectors
- Four exception levels (EL0-EL3) provide hierarchical privilege separation for applications, OS, hypervisor, and secure monitor

**Important related topics**: ARM assembly syntax and directives, instruction reference with detailed encodings, optimization techniques for ARM processors, exception vector table configuration, memory management unit (MMU) programming, TrustZone security architecture, cache maintenance operations, atomic operations and lock-free algorithms.

---

