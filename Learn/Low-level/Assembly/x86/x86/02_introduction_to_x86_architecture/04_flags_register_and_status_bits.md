## Flags Register and Status Bits


The flags register (RFLAGS in 64-bit mode, EFLAGS in 32-bit mode, FLAGS in 16-bit mode) contains various status flags, control flags, and system flags that reflect processor state and control its operation.

### Status Flags

Status flags reflect the results of arithmetic, logical, and comparison operations. They are automatically set by most arithmetic and logical instructions.

**CF (Carry Flag, bit 0)**: Set when an arithmetic operation generates a carry out of or borrow into the most significant bit. For unsigned arithmetic, CF indicates overflow (result too large or small). Used extensively in multi-precision arithmetic where operations span multiple registers. Instructions like ADD, SUB, INC, DEC, shifts, and rotates affect CF.

**PF (Parity Flag, bit 2)**: Set if the least significant byte of the result contains an even number of 1 bits. Originally used for error detection in data transmission, PF sees limited use in modern code. Primarily affected by arithmetic and logical instructions.

**AF (Auxiliary Carry Flag, bit 4)**: Set when an arithmetic operation generates a carry from bit 3 to bit 4 (from the low nibble to the high nibble). Used primarily for BCD (Binary-Coded Decimal) arithmetic with DAA and DAS instructions. Most modern code ignores this flag.

**ZF (Zero Flag, bit 6)**: Set when an arithmetic or logical operation produces a zero result. Critical for conditional branching and comparisons. Instructions like CMP, TEST, and most arithmetic operations set ZF. Conditional jumps like JZ (jump if zero) and JNZ (jump if not zero) test this flag.

**SF (Sign Flag, bit 7)**: Set equal to the most significant bit of the result, indicating the sign in signed integer arithmetic (0 = positive, 1 = negative). Used with signed conditional jumps. For example, after a comparison, JL (jump if less) checks SF ≠ OF.

**OF (Overflow Flag, bit 11)**: Set when signed arithmetic produces a result too large or too small to fit in the destination. For example, adding two large positive numbers producing a negative result sets OF. Used with signed conditional jumps like JO (jump if overflow) and JNO (jump if not overflow). Unsigned operations should check CF instead of OF.

### Control Flags

**DF (Direction Flag, bit 10)**: Controls the direction of string operations. When DF=0, string operations (MOVS, CMPS, SCAS, LODS, STOS) increment the index registers (RSI, RDI) after each operation. When DF=1, they decrement. Set with STD instruction, cleared with CLD. Most code keeps DF=0 and sets it explicitly when needed.

### System Flags

System flags control operating mode and debugging features. Most are privileged and only modifiable in ring 0.

**TF (Trap Flag, bit 8)**: When set, the processor generates a debug exception (INT 1) after each instruction, enabling single-stepping through code. Debuggers set TF to implement step-by-step execution. Can be set by application code but immediately triggers an exception.

**IF (Interrupt Enable Flag, bit 9)**: Controls whether maskable hardware interrupts are recognized. When IF=1, maskable interrupts are enabled; when IF=0, they are masked. Set with STI instruction, cleared with CLI. In ring 0 only in protected mode and long mode. Non-maskable interrupts (NMI) always trigger regardless of IF. Critical sections often disable interrupts temporarily.

**IOPL (I/O Privilege Level, bits 12-13)**: Contains a 2-bit privilege level that controls access to I/O instructions and IF flag modification in protected mode. Code running at CPL ≤ IOPL can execute I/O instructions (IN, OUT, INS, OUTS) and modify IF. Code running at CPL > IOPL generates a general protection fault. Typically set to 0 to restrict I/O to the kernel.

**NT (Nested Task Flag, bit 14)**: Indicates whether the current task is nested in the execution of another task through a CALL or interrupt. Used by hardware task switching in protected mode. When set, IRET will perform a task switch. Rarely used in modern operating systems, which implement software task switching.

**RF (Resume Flag, bit 16)**: Controls instruction breakpoint behavior. When set, it temporarily disables instruction breakpoints, allowing the processor to resume execution after a breakpoint without immediately triggering again. Set automatically by the processor in certain cases and cleared after successfully executing one instruction.

**VM (Virtual-8086 Mode Flag, bit 17)**: When set in protected mode, the processor operates in virtual-8086 mode, allowing 8086 real-mode programs to run within a protected mode multitasking environment. Each virtual-8086 task has its own 1 MB address space and runs at privilege level 3. Used by operating systems to run DOS applications. Only modifiable in ring 0.

**AC (Alignment Check Flag, bit 18)**: When set along with the AM bit in CR0, the processor generates an alignment check exception (INT 17) on unaligned memory references. Used to enforce strict alignment requirements or detect unaligned accesses. Requires ring 3 to trigger, preventing kernel code from accidentally faulting.

**VIF (Virtual Interrupt Flag, bit 19)**: Virtual image of IF used in virtual-8086 mode extensions and protected-mode virtual interrupts. Allows virtualization of interrupt control without affecting actual interrupt delivery. Set and cleared with VMXE/PVI features enabled.

**VIP (Virtual Interrupt Pending Flag, bit 20)**: Indicates a virtual interrupt is pending. Used with VIF for virtualized interrupt handling. When VIP is set, it signals that an external interrupt is waiting to be delivered when virtual interrupts are enabled.

**ID (Identification Flag, bit 21)**: Software can attempt to modify this flag to determine whether the processor supports the CPUID instruction. If software can modify ID, CPUID is supported. All modern processors since the Pentium support CPUID and allow ID modification. Used primarily for CPU feature detection in older compatibility code.

### Accessing and Manipulating Flags

The flags register cannot be directly loaded or stored like general-purpose registers in most circumstances. Instead, specific instructions manipulate individual flags or transfer flags to/from other locations:

- **LAHF/SAHF**: Load/Store AH with flags (SF, ZF, AF, PF, CF) - legacy 8086 instructions
- **PUSHF/POPF**: Push/Pop FLAGS register (16-bit)
- **PUSHFD/POPFD**: Push/Pop EFLAGS register (32-bit)
- **PUSHFQ/POPFQ**: Push/Pop RFLAGS register (64-bit)
- **STI/CLI**: Set/Clear IF
- **STD/CLD**: Set/Clear DF
- **STC/CLC/CMC**: Set/Clear/Complement CF
- **Conditional instructions**: JCC (conditional jumps), SETCC (conditional set), CMOVCC (conditional move) test various flag combinations

Flag manipulation in protected and long modes is privilege-sensitive. Application code cannot directly modify system flags like IF or IOPL without generating exceptions, ensuring operating system control over critical system state.

Understanding flags is essential for conditional logic, arithmetic operations, and system programming. Conditional branches rely entirely on flag states to implement control flow, and arithmetic operations produce meaningful flag combinations that indicate result properties (zero, negative, overflow, carry).

**Key Points:**

- x86 architecture evolved from the 16-bit 8086 (1978) through 32-bit protected mode (80386, 1985) to 64-bit long mode (x86-64, 2003)
- Real mode provides 1 MB addressing with no protection; protected mode adds memory protection, virtual memory, and privilege levels; long mode extends to 64-bit with 16 general-purpose registers
- Registers include general-purpose (RAX-RDX, R8-R15), segment (CS, DS, SS, ES, FS, GS), control (CR0-CR4), debug (DR0-DR7), floating-point (ST(0)-ST(7)), and SIMD (XMM/YMM/ZMM)
- The RFLAGS register contains status flags (CF, ZF, SF, OF, PF, AF), control flags (DF), and system flags (IF, TF, IOPL, VM) that control processor operation and reflect computation results

x86 architecture represents a family of instruction set architectures originally developed by Intel, based on the Intel 8086 microprocessor. This architecture has evolved through multiple generations while maintaining backward compatibility, making it one of the most prevalent computing architectures in desktop, laptop, and server systems.

