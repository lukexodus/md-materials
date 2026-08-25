## ISA Design Principles


The Instruction Set Architecture is the contract between software and hardware — it defines every operation a processor must support, how operands are specified, how memory is addressed, and how the machine is programmed. ISA decisions are effectively permanent: they constrain microarchitecture design for decades and must be honored by every future implementation.

---

### What an ISA Specifies

An ISA defines six categories of architectural state and behavior:

**Instruction set** — the complete set of operations the processor can execute, their encoding, and their semantics.

**Data types and sizes** — which primitive types the hardware natively operates on: integer widths (8, 16, 32, 64-bit), floating-point formats (IEEE 754 single, double), and in some ISAs, packed SIMD types.

**Registers** — the number, width, and purpose of programmer-visible registers. This includes general-purpose registers (GPRs), floating-point registers, condition code registers, and special-purpose registers (program counter, stack pointer, status word).

**Memory model** — the address space size, byte ordering (endianness), alignment requirements, and the consistency model governing how memory operations are observed across threads.

**Addressing modes** — the mechanisms by which operand addresses are computed from instruction fields, registers, and immediate values.

**Exception and interrupt model** — how the processor responds to faults, traps, and external interrupts; which architectural state is preserved; and how control transfers to handler code.

---

### Core Design Principles

#### Regularity

Instruction formats, register sets, and operation semantics should be uniform. A regular ISA has:

- Fixed or predictable instruction length
- All registers of the same width and interchangeable for most operations
- Consistent operand ordering across instruction types

Regularity reduces decoder complexity, simplifies compiler register allocation, and makes the ISA learnable. Irregularities — special-purpose registers usable only in certain instructions, variable-length fields with implicit widths — impose hidden costs throughout the implementation and toolchain.

#### Simplicity

Each instruction should perform one well-defined operation. Compound instructions that combine a memory access with an arithmetic operation and a conditional branch pack too much meaning into a single encoding — they complicate decode, hazard detection, and out-of-order scheduling. The principle is sometimes stated as: **the implementation of a simple instruction should be simple.**

This does not mean the ISA must be minimal in count. It means that each instruction, however many there are, should have a straightforward and unambiguous semantics.

#### Orthogonality

Any instruction should be combinable with any addressing mode and any register. A fully orthogonal ISA means that instruction type, addressing mode, and register specifier are independently selectable fields — the Motorola 68000 was a near-textbook example. Non-orthogonal ISAs (x86 in particular) impose implicit constraints: certain operations only apply to specific registers, certain addressing modes are only available with certain instruction types. This forces compilers to work around register constraints and complicates formal specification.

#### Completeness

The ISA must provide all operations necessary to implement any computable function efficiently. In practice this means:

- Arithmetic and logic on all supported data widths
- Load and store for all data widths
- Conditional and unconditional branches
- A mechanism for subroutine call and return
- Instructions for manipulating system state (privilege level, interrupt mask)

Incompleteness forces software emulation of missing operations — a significant performance penalty and a correctness hazard.

#### Efficiency at the target level

ISA design must account for where the architecture will be used. An embedded ISA (Thumb, AVR) optimizes for code density and minimal register pressure. A server ISA (x86-64, AArch64) optimizes for throughput on wide superscalar pipelines. A DSP ISA optimizes for throughput on multiply-accumulate operations. The intended implementation level — single-issue in-order, deeply out-of-order superscalar, vector machine — constrains which tradeoffs are sensible.

#### Compatibility and longevity

Once deployed, an ISA must be extended without breaking existing binaries. This requires:

- Reserved opcode space for future instructions
- Defined behavior for unimplemented opcodes (fault, not undefined behavior)
- Versioning mechanisms (feature flags, capability bits in status registers)
- Strict separation of the architectural interface from microarchitectural implementation

x86 has accumulated extensions (MMX, SSE, AVX, AVX-512, AMX) over four decades without breaking compatibility with 1978-era 8086 binaries — at the cost of enormous decoder complexity. RISC-V addresses this through a modular extension naming scheme (I, M, A, F, D, C, V, …) that allows implementations to declare exactly which subsets they support.

---

### Instruction Format Design

An instruction format partitions a fixed-width bit vector into fields. The critical design decisions are:

**Opcode width** determines how many distinct operations can be encoded. A 6-bit opcode supports 64 operations; a 10-bit opcode supports 1024. Wider opcodes consume bits that could otherwise specify operands.

**Register specifier width** is $\lceil \log_2 R \rceil$ bits for $R$ registers. 32 registers require 5 bits per specifier; with three register operands (source 1, source 2, destination), 15 bits are consumed by register fields alone in a 32-bit instruction.

**Immediate field width** determines the range of constants encodable directly in the instruction. A 12-bit signed immediate covers $[-2048, 2047]$; extending this requires multi-instruction sequences (load upper immediate + add immediate in RISC-V, for example).

The tension is fundamental: wider register files require more bits per specifier, leaving fewer bits for opcodes and immediates. This is why most 32-bit ISAs settle on 32 general-purpose registers (5 bits each) and accept that large immediates require two-instruction sequences.

**Example: RISC-V 32-bit base integer instruction formats**

|Format|Usage|Fields|
|---|---|---|
|R-type|Register-register ops|opcode[7] · rd[5] · funct3[3] · rs1[5] · rs2[5] · funct7[7]|
|I-type|Immediate ops, loads|opcode[7] · rd[5] · funct3[3] · rs1[5] · imm[12]|
|S-type|Stores|opcode[7] · imm[5] · funct3[3] · rs1[5] · rs2[5] · imm[7]|
|B-type|Branches|opcode[7] · imm[12 split] · funct3[3] · rs1[5] · rs2[5]|
|U-type|Upper immediate|opcode[7] · rd[5] · imm[20]|
|J-type|Jump and link|opcode[7] · rd[5] · imm[20 split]|

The split immediates in B and J types are an artifact of keeping the sign bit in position 31 and the low bits aligned for hardware sign-extension efficiency — a deliberate hardware optimization baked into the encoding.

---

### Register File Design Decisions

The number of architectural registers has cascading effects:

|Registers|Bits per specifier|Compiler benefit|Encoding cost (3-operand instr.)|
|---|---|---|---|
|8|3|Low — spills frequent|9 bits|
|16|4|Moderate|12 bits|
|32|5|High — most loops fit|15 bits|
|64|6|Marginal improvement|18 bits|
|128+|7+|Diminishing returns|21+ bits|

x86 originally had 8 GPRs (3 bits), increased to 16 in 64-bit mode (REX prefix adds a 4th bit) — barely sufficient for a C calling convention with 6 argument registers, a frame pointer, a stack pointer, and scratch registers. ARM64 and RISC-V both specify 32 GPRs. SPARC and Itanium experimented with register windows and very large register files respectively, with mixed results.

**Caller-saved vs. callee-saved partitioning** is an ISA-level convention (though enforced by the ABI rather than hardware). Registers designated callee-saved must be preserved across function calls; caller-saved registers may be clobbered. This partitioning interacts with register allocation quality and the cost of function call overhead.

---

### Memory Model and Endianness

**Address space:** Modern 64-bit ISAs provide a 64-bit virtual address space, though implementations typically implement 48 or 52 physical address bits. The virtual space is flat — a single linear range from 0 to $2^{64}-1$, partitioned by convention and the OS into user and kernel halves.

**Endianness** determines byte ordering within multi-byte values:

- **Big-endian:** Most significant byte at the lowest address. Used by SPARC, older MIPS, network protocols.
- **Little-endian:** Least significant byte at the lowest address. Used by x86, ARM (default), RISC-V.
- **Bi-endian:** Configurable at boot or per-process. ARM and MIPS support this; in practice most deployments fix one ordering.

Little-endian has a subtle advantage: a value at address $A$ read as 8-bit, 16-bit, 32-bit, or 64-bit always starts at the same byte, so truncation is free. Big-endian has a human-readability advantage in memory dumps. The difference is architecturally consequential only when sharing binary data across machines or performing sub-word memory accesses.

**Alignment:** Many ISAs require or strongly prefer naturally aligned accesses — a 4-byte load from an address that is a multiple of 4, an 8-byte load from a multiple of 8. Misaligned access may:

- Be handled transparently in hardware (x86) — but with a performance penalty
- Generate an alignment fault (older MIPS, strict ARM mode)
- Produce undefined behavior (some embedded ISAs)

RISC-V explicitly allows misaligned loads and stores but makes hardware support optional; implementations may trap to a software handler.

---

### Exception and Privilege Architecture

A complete ISA defines at least two privilege levels:

**User mode** — restricted. Cannot execute privileged instructions, cannot directly access I/O, cannot modify page tables or interrupt masks.

**Supervisor/kernel mode** — unrestricted. Full access to all instructions and system registers.

Modern ISAs add additional levels: x86 has four rings (0–3, though rings 1–2 are rarely used by OS kernels); ARM defines EL0–EL3 (Exception Levels) supporting nested virtualization and secure enclaves; RISC-V defines Machine, Supervisor, and User modes with optional Hypervisor extension.

**Exception taxonomy:**

|Type|Cause|Synchronous?|Resumable?|
|---|---|---|---|
|Fault|Correctable before instruction commits (page fault)|Yes|Yes — re-executes faulting instruction|
|Trap|Intentional software interrupt (syscall, breakpoint)|Yes|Yes — returns to next instruction|
|Abort|Unrecoverable error (double fault, hardware error)|Yes|No|
|Interrupt|External asynchronous signal (timer, I/O)|No|Yes — returns to interrupted instruction|

The ISA specifies which registers are saved automatically on exception entry (typically the PC and a status word), the location of exception handlers (fixed vectors, vectored table, or a trap handler register), and the instruction used to return from exception (ERET, SRET, IRET depending on ISA and privilege level).

---

### ISA Longevity and the Compatibility Constraint

The most consequential design principle is one that only becomes visible over time: **ISA decisions are nearly irreversible.** A bug in a microarchitecture is fixed in the next tape-out. A mistake in the ISA is carried forward in every subsequent implementation and in every binary ever compiled for it.

This asymmetry has produced visible pathologies in mature ISAs:

- x86 retains the segment register model from the 8086, vestigial in 64-bit mode but architecturally present
- x86 PUSHF/POPF must save and restore all flags including the interrupt enable flag, creating a virtualization hole that required hardware extensions (VT-x) to plug
- Early ARM Thumb encoding lacked a 32-bit immediate load, requiring a `ldr pc, [pc, #offset]` literal pool idiom that became a security concern in ROP attacks

RISC-V's response to these lessons is the most systematic: a minimal frozen base ISA (RV32I, 47 instructions) that will never change, a set of ratified standard extensions (M, A, F, D, C, V) with stable encodings, and a large reserved opcode space for future and vendor-specific extensions. The base ISA is small enough to be formally verified; the extension mechanism is explicit enough that software can query hardware capability bits at runtime.

---

The diagram below maps the principal ISA design decisions and their downstream consequences across the implementation stack.---

### Worked Comparison: RISC-V vs. x86-64 Design Choices

|Design axis|x86-64|RISC-V (RV64GC)|
|---|---|---|
|Instruction width|Variable: 1–15 bytes|Fixed: 32-bit (16-bit compressed optional)|
|GPR count|16 (historically 8)|32|
|Addressing modes|Many: base+index×scale+displacement|Two: base+offset (load/store only)|
|Memory ops|Register-memory ALU ops allowed|Load-store only; ALU is register-register|
|Condition codes|FLAGS register (CF, ZF, SF, OF, PF, AF)|No flags; compare-and-branch instructions|
|Privilege levels|Ring 0–3; VMX root/non-root|M / S / U + H extension|
|Endianness|Little only|Little default; bi-endian optional|
|Base ISA size|Thousands of instructions|47 instructions (RV32I)|
|Extension mechanism|Prefix bytes, REX, VEX, EVEX|Named modules (M, A, F, D, C, V, …)|

The x86-64 design reflects decades of backward-compatible accretion. RISC-V reflects deliberate application of the lessons learned from every preceding ISA. Neither is universally superior — x86-64's rich encodings achieve better code density in some workloads, while RISC-V's regularity enables smaller, lower-power implementations and formally verified cores.

---

### **Key Points**

- The ISA is a permanent contract — every decision is inherited by all future implementations and must not invalidate existing binaries.
- Regularity, simplicity, and orthogonality reduce decoder complexity and compiler burden; violations accumulate as technical debt across the entire software stack.
- Instruction format width determines the fundamental tradeoff between opcode space, register count, and immediate range — all three compete for bits in a fixed word.
- Register file size has nonlinear returns: moving from 8 to 32 registers is transformative; 32 to 128 yields marginal gain at significant encoding cost.
- The exception and privilege architecture is the ISA's interface to the operating system; design flaws here (as with x86 virtualisation) require hardware extensions to correct.
- RISC-V's modular frozen-base approach is the most principled current answer to the compatibility problem, though x86-64's installed base demonstrates that even a deeply irregular ISA can thrive through implementation quality.

---

**Next Steps**

ISA design principles are most concretely realized in the study of **CISC vs. RISC** — the historical divergence in philosophy, its microarchitectural consequences, and how modern implementations have converged (x86 translating to micro-ops internally; ARM and RISC-V adding compressed instruction extensions). The subsequent topic of **instruction formats and encoding** examines the bit-level mechanics of each approach in detail.

---

