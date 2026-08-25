## Registers


x86 processors contain various types of registers that store data, addresses, control information, and processor state. The register set has expanded significantly from the original 8086 to modern 64-bit processors.

### General-Purpose Registers

General-purpose registers store operands for arithmetic and logical operations, memory addresses, and temporary data. The original 8086 provided four 16-bit general-purpose registers: AX (accumulator), BX (base), CX (count), and DX (data). Each could be accessed as a 16-bit value or split into two 8-bit halves: AH/AL, BH/BL, CH/CL, DH/DL.

The 80386 extended these to 32 bits, adding an "E" prefix: EAX, EBX, ECX, EDX. The lower 16 bits remained accessible as AX, BX, CX, DX, and the lower 8-bit halves as AH/AL, etc. The 8086 also provided four pointer and index registers: SP (stack pointer), BP (base pointer), SI (source index), and DI (destination index), extended to ESP, EBP, ESI, EDI in 32-bit mode.

x86-64 extends all these registers to 64 bits with an "R" prefix: RAX, RBX, RCX, RDX, RSP, RBP, RSI, RDI. The lower portions remain accessible (EAX is the lower 32 bits of RAX, AX is the lower 16 bits, AL is the lower 8 bits). A new addressing mode allows accessing the low 8 bits of RSI, RDI, RBP, and RSP as SIL, DIL, BPL, SPL when using REX prefixes.

x86-64 also adds eight new general-purpose registers: R8-R15. These are 64-bit registers, with the lower portions accessible as R8D-R15D (32-bit), R8W-R15W (16-bit), and R8B-R15B (8-bit).

While called "general-purpose," certain registers have special roles in specific instructions:
- RAX: Accumulator for arithmetic operations, function return values, syscall numbers
- RBX: Base register for indexed addressing, sometimes preserved across calls
- RCX: Counter for loop and string operations, fourth function argument (Windows x64)
- RDX: Data register, used in multiplication/division, third function argument (Windows x64)
- RSI: Source index for string operations, second function argument (System V AMD64)
- RDI: Destination index for string operations, first function argument (System V AMD64)
- RBP: Base pointer for stack frame access
- RSP: Stack pointer, points to the top of the stack
- R8-R9: Additional function arguments in 64-bit calling conventions
- R10-R11: Temporary registers, may be used by syscalls
- R12-R15: Preserved registers that typically must be saved/restored by called functions

### Segment Registers

Segment registers select memory segments in segmented memory models. The 8086 provided four 16-bit segment registers: CS (Code Segment), DS (Data Segment), SS (Stack Segment), and ES (Extra Segment). The 80386 added FS and GS as additional extra segment registers.

In real mode, segment registers contain the base address divided by 16. The physical address is calculated as (segment × 16) + offset. In protected mode, segment registers contain segment selectors that index into descriptor tables. Each selector contains an index into the GDT or LDT, a table indicator bit, and a requested privilege level.

In 64-bit long mode, segmentation is largely disabled. CS, DS, ES, and SS have their bases forced to zero, effectively creating a flat memory model. However, FS and GS remain functional with configurable base addresses, commonly used for thread-local storage and operating system data structures. The FS and GS bases can be set using special MSRs (Model Specific Registers) or the WRFSBASE/WRGSBASE instructions.

CS is special because it cannot be loaded directly with MOV. Instead, it changes implicitly during far jumps, far calls, interrupt handling, or return instructions. The CS register also contains the Current Privilege Level (CPL) in its lower 2 bits in protected mode.

### Instruction Pointer

The instruction pointer register points to the next instruction to be executed. In 16-bit mode, it's IP; in 32-bit mode, EIP; in 64-bit mode, RIP. Unlike general-purpose registers, the instruction pointer cannot be accessed directly through ordinary instructions. It changes implicitly through control flow instructions (JMP, CALL, RET, INT, IRET) or sequentially as instructions execute.

In 64-bit mode, RIP-relative addressing allows instructions to reference memory relative to the current instruction pointer, enabling position-independent code. The instruction might specify a 32-bit signed displacement that's added to the RIP value pointing to the next instruction.

### Control Registers

Control registers manage processor operation modes and features. They cannot be accessed by application code and require privileged execution (ring 0).

CR0 contains system control flags:
- PE (bit 0): Protection Enable, switches from real mode to protected mode
- MP (bit 1): Monitor Coprocessor, controls WAIT/FWAIT instruction behavior
- EM (bit 2): Emulation, indicates no FPU present
- TS (bit 3): Task Switched, enables lazy FPU context switching
- ET (bit 4): Extension Type (obsolete, hardwired to 1)
- NE (bit 5): Numeric Error, enables native FPU error reporting
- WP (bit 16): Write Protect, enables write protection in ring 0
- AM (bit 18): Alignment Mask, enables alignment checking
- NW (bit 29): Not Write-through, controls cache behavior
- CD (bit 30): Cache Disable, disables internal caches
- PG (bit 31): Paging, enables paging when set

CR1 is reserved and not used.

CR2 stores the page fault linear address. When a page fault occurs, CR2 is loaded with the virtual address that caused the fault, allowing the page fault handler to determine which address was accessed.

CR3 contains the page directory base register (PDBR), pointing to the base of the page directory or PML4 table. The lower 12 bits contain flags controlling cache behavior (PWT, PCD) and must be zero. Loading CR3 with a new value switches the address space, flushing most TLB entries. CR3 is often called the "page table base."

CR4 contains various control flags for extended features:
- VME (bit 0): Virtual-8086 Mode Extensions
- PVI (bit 1): Protected-mode Virtual Interrupts
- TSD (bit 2): Time Stamp Disable, restricts RDTSC instruction to ring 0
- DE (bit 3): Debugging Extensions
- PSE (bit 4): Page Size Extension, enables 4 MB pages
- PAE (bit 5): Physical Address Extension, enables >4GB physical addressing in 32-bit mode
- MCE (bit 6): Machine-Check Enable
- PGE (bit 7): Page Global Enable, enables global TLB entries
- PCE (bit 8): Performance-Monitoring Counter Enable
- OSFXSR (bit 9): Operating System FXSAVE/FXRSTOR Support
- OSXMMEXCPT (bit 10): Operating System Unmasked Exception Support
- UMIP (bit 11): User-Mode Instruction Prevention
- VMXE (bit 13): Virtual Machine Extensions Enable
- SMXE (bit 14): Safer Mode Extensions Enable
- FSGSBASE (bit 16): Enables RDFSBASE/RDGSBASE/WRFSBASE/WRGSBASE instructions
- PCIDE (bit 17): PCID Enable
- OSXSAVE (bit 18): XSAVE and Processor Extended States Enable
- SMEP (bit 20): Supervisor Mode Execution Prevention
- SMAP (bit 21): Supervisor Mode Access Prevention
- PKE (bit 22): Protection Key Enable

CR8 is the Task Priority Register (TPR) available in 64-bit mode, controlling the priority threshold for external interrupts.

### Debug Registers

Debug registers support hardware breakpoints and debugging facilities. They are privileged and accessible only in ring 0.

DR0-DR3 contain linear addresses for up to four hardware breakpoints. Each register can hold one breakpoint address.

DR4 and DR5 are reserved (aliases for DR6 and DR7 when debug extensions are disabled).

DR6 is the Debug Status Register, containing flags that indicate which debug conditions were met:
- B0-B3 (bits 0-3): Breakpoint condition detected for DR0-DR3
- BD (bit 13): Debug register access detected
- BS (bit 14): Single step (trap flag caused break)
- BT (bit 15): Task switch breakpoint

DR7 is the Debug Control Register, controlling the operation of debug registers:
- L0-L3 (bits 0,2,4,6): Local breakpoint enable for DR0-DR3 (current task)
- G0-G3 (bits 1,3,5,7): Global breakpoint enable for DR0-DR3 (all tasks)
- LE, GE (bits 8-9): Local/Global exact breakpoint enable (obsolete)
- GD (bit 13): General Detect enable, causes debug exception on DR access
- R/W0-R/W3 (bits 16-17, 20-21, 24-25, 28-29): Read/Write field for each breakpoint (00=execution, 01=write, 11=read/write)
- LEN0-LEN3 (bits 18-19, 22-23, 26-27, 30-31): Length field for each breakpoint (00=1 byte, 01=2 bytes, 10=8 bytes, 11=4 bytes)

Hardware breakpoints are significantly faster than software breakpoints (INT 3) and don't require code modification, making them valuable for debugging and security applications.

### Model Specific Registers (MSRs)

MSRs are processor-specific registers accessed through RDMSR and WRMSR instructions. Different processor families implement different MSRs. Common MSRs include:

- IA32_EFER (0xC0000080): Extended Feature Enable Register, controls long mode activation, NXE (No-Execute Enable), and other features
- IA32_STAR (0xC0000081): SYSCALL target address and segment selectors
- IA32_LSTAR (0xC0000082): Long mode SYSCALL target address
- IA32_FMASK (0xC0000084): SYSCALL flag mask
- IA32_FS_BASE (0xC0000100): FS segment base address in 64-bit mode
- IA32_GS_BASE (0xC0000101): GS segment base address in 64-bit mode
- IA32_KERNEL_GS_BASE (0xC0000102): Kernel GS base, swapped with GS_BASE by SWAPGS
- IA32_TSC (0x10): Time Stamp Counter
- IA32_APIC_BASE (0x1B): APIC base address and enable bits

MSRs provide access to performance counters, advanced features, processor-specific controls, and virtualization settings. The specific MSRs available depend on the processor model.

### Floating-Point Registers

The x87 FPU provides eight 80-bit floating-point data registers organized as a stack: ST(0) through ST(7), where ST(0) is the stack top. These registers store extended-precision floating-point values (80-bit) with 64-bit mantissa and 15-bit exponent.

The FPU Control Word configures rounding modes, precision control, and exception masking. The FPU Status Word reports stack pointers, condition codes, and exception flags. The FPU Tag Word tracks whether each register contains valid data, zero, special values (infinity, NaN), or empty.

Modern code typically uses SSE/AVX floating-point instructions instead of x87, as they provide better performance and more predictable behavior.

### SIMD Registers

Modern x86 processors include extensive SIMD (Single Instruction, Multiple Data) registers for parallel data processing.

MMX introduced eight 64-bit registers MM0-MM7, which actually alias the x87 FPU registers' mantissa fields. MMX registers operate on packed integer data (8×8-bit, 4×16-bit, 2×32-bit, or 1×64-bit integers). The aliasing with FPU registers means MMX and x87 instructions cannot be freely mixed without explicit state management.

SSE introduced sixteen 128-bit XMM registers (XMM0-XMM15 in 64-bit mode, XMM0-XMM7 in 32-bit mode). These registers operate on packed single-precision or double-precision floating-point values (4×32-bit or 2×64-bit floats) or packed integers. SSE registers are independent of FPU state.

AVX extended XMM registers to 256-bit YMM registers (YMM0-YMM15), with the lower 128 bits corresponding to the XMM registers. YMM registers support operations on 8 single-precision or 4 double-precision floats, or wider integer operations.

AVX-512 further extends these to 512-bit ZMM registers (ZMM0-ZMM31, adding 16 additional registers) and introduces eight mask registers (K0-K7) for predicated operations. ZMM registers can process 16 single-precision floats, 8 double-precision floats, or correspondingly larger integer vectors.

Each SIMD extension maintains compatibility - the lower portions of larger registers remain accessible using smaller instruction sets (XMM registers are the lower 128 bits of YMM, which are the lower 256 bits of ZMM).

