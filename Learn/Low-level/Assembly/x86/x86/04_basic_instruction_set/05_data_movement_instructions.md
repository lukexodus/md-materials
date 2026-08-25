## Data Movement Instructions


Data movement instructions transfer data between registers, memory, and immediate values without performing arithmetic or logical operations. These are among the most frequently used instructions in any program.

### MOV Instruction

The MOV instruction copies data from a source operand to a destination operand. The source remains unchanged, and the destination is overwritten. MOV does not affect any flags in the RFLAGS register.

The syntax follows Intel convention (destination, source) or AT&T convention (source, destination). Intel syntax: `MOV destination, source`. The instruction supports multiple operand combinations with specific restrictions.

MOV can transfer data between two registers of the same size: `MOV RAX, RBX` copies RBX into RAX. It can load immediate values into registers: `MOV ECX, 42` loads the value 42 into ECX. Memory-to-register transfers are possible: `MOV EAX, [RBX]` loads the 32-bit value at the address contained in RBX into EAX. Register-to-memory transfers work similarly: `MOV [RDI], ESI` stores ESI into the memory location pointed to by RDI.

Critical restrictions apply to MOV operations. Direct memory-to-memory moves are not permitted - data must pass through a register. Immediate values cannot be moved directly to memory addresses without specifying operand size. Segment register operations have limitations: CS cannot be loaded with MOV, and not all combinations of segment registers and general-purpose registers are allowed.

Operand sizes must match or follow specific rules. In 64-bit mode, moving a 32-bit value into a 64-bit register zero-extends the result to 64 bits: `MOV EAX, 5` clears the upper 32 bits of RAX. Moving smaller values (8-bit or 16-bit) does not affect the remaining bits of the register.

MOV variants include MOVZX (move with zero extension) and MOVSX/MOVSXD (move with sign extension). MOVZX copies a smaller value into a larger register and fills the upper bits with zeros: `MOVZX EAX, BL` copies the byte in BL into EAX and zeros the upper 24 bits. MOVSX performs sign extension, copying the sign bit into the upper bits: `MOVSX RAX, AX` copies AX into RAX and fills bits 16-63 with copies of bit 15.

### XCHG Instruction

XCHG atomically exchanges the contents of two operands. Unlike MOV, both operands are modified. The instruction is atomic when one operand is memory, making it useful for synchronization primitives.

`XCHG RAX, RBX` swaps the contents of RAX and RBX. `XCHG [RSI], EDI` atomically exchanges EDI with the 32-bit value at the memory address in RSI. XCHG with the accumulator (EAX/RAX) has a short encoding: `XCHG EAX, ECX` is encoded in only 1 byte.

The atomic nature of memory XCHG makes it valuable for implementing locks and synchronization primitives. However, the implicit LOCK prefix on memory operations makes XCHG slower than separate MOV instructions when atomicity is not required.

### LEA Instruction

LEA (Load Effective Address) computes the address of the source operand and loads it into the destination register without accessing memory. Despite its name suggesting an addressing operation, LEA is frequently used for arithmetic.

`LEA RAX, [RBX + RCX*4 + 8]` calculates the address RBX + RCX*4 + 8 and stores the result in RAX. No memory access occurs - this is pure arithmetic. LEA can perform multiplication by 2, 3, 4, 5, 8, or 9 and addition in a single instruction: `LEA EAX, [EDX + EDX*2]` efficiently computes EDX * 3.

LEA does not affect any flags, making it useful when arithmetic is needed without disturbing condition codes. It operates on address-sized values (64-bit addresses in 64-bit mode, 32-bit in 32-bit mode). LEA is faster than equivalent MUL and ADD instruction sequences for many simple calculations.

Modern compilers extensively use LEA for address calculation and as an arithmetic optimization. `LEA RDI, [RSI + 1]` increments RSI without affecting flags, unlike `INC` or `ADD`.

### MOVS Family

The MOVS family of instructions (MOVSB, MOVSW, MOVSD, MOVSQ) performs block memory copies from source to destination using RSI and RDI registers. These are string instructions that can be repeated with the REP prefix.

MOVSB copies one byte from [RSI] to [RDI], then increments or decrements both RSI and RDI based on the DF flag. MOVSW, MOVSD, and MOVSQ operate on 2, 4, and 8 bytes respectively. The REP prefix repeats the operation RCX times: `REP MOVSB` copies RCX bytes from RSI to RDI.

When DF=0 (cleared with CLD), the instruction increments the index registers, copying forward through memory. When DF=1 (set with STD), it decrements, copying backward. Backward copying is useful when source and destination regions overlap and the destination address is higher than the source.

Modern processors implement these instructions with optimized microcode or internal implementations that can perform bulk transfers efficiently. However, for very large copies, standard library functions using SSE/AVX instructions may perform better.

### Stack Operations

Stack operations manage the call stack, which grows downward in memory (from high addresses to low addresses) on x86. RSP (or ESP in 32-bit mode) points to the top of the stack.

PUSH decrements the stack pointer and writes a value to the stack. In 64-bit mode, `PUSH RAX` subtracts 8 from RSP, then writes RAX to [RSP]. In 32-bit mode, PUSH operates on 4 bytes. PUSH can accept register operands, memory operands, or immediate values. 16-bit PUSH operations are possible with the operand size override prefix.

POP reads a value from the stack and increments the stack pointer. `POP RBX` reads 8 bytes from [RSP] into RBX, then adds 8 to RSP. POP cannot use immediate operands.

Stack alignment is critical in modern calling conventions. The System V AMD64 ABI requires RSP to be 16-byte aligned before a CALL instruction. Windows x64 requires 16-byte alignment as well. Function prologues often subtract from RSP to allocate stack space while maintaining alignment.

PUSHA/POPA (16-bit) and PUSHAD/POPAD (32-bit) push or pop all general-purpose registers at once. These instructions are not available in 64-bit mode. PUSHF/POPF push or pop the flags register.

### Conditional Move

CMOVcc (conditional move) instructions move data only if specified condition flags are met. These instructions avoid branch misprediction penalties by using predicated execution.

`CMOVZ RAX, RBX` moves RBX to RAX only if ZF=1 (result was zero). If ZF=0, the instruction does nothing. Available conditions match the conditional jump conditions: CMOVZ/CMOVE (zero/equal), CMOVNZ/CMOVNE (not zero/not equal), CMOVA/CMOVNBE (above/not below or equal, unsigned), CMOVAE/CMOVNB (above or equal/not below), CMOVB/CMOVNAE (below/not above or equal), CMOVBE/CMOVNA (below or equal/not above), CMOVG/CMOVNLE (greater/not less or equal, signed), CMOVGE/CMOVNL (greater or equal/not less), CMOVL/CMOVNGE (less/not greater or equal), CMOVLE/CMOVNG (less or equal/not greater), CMOVO/CMOVNO (overflow/not overflow), CMOVS/CMOVNS (sign/not sign), CMOVP/CMOVNP (parity/not parity).

CMOVcc always reads the source operand, which can cause cache effects or exceptions if the source is memory. Modern processors execute CMOVcc efficiently, but for unpredictable branches, conditional moves may be slower than branch prediction. Compilers use CMOVcc when branches are unpredictable or when the moved values are already in registers.

