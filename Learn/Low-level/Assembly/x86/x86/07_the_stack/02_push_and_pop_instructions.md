## PUSH and POP Instructions


PUSH and POP instructions provide the primary interface for stack manipulation. These instructions combine register/memory access with automatic stack pointer adjustment, ensuring proper stack maintenance.

### PUSH Instruction

PUSH decrements the stack pointer by the operand size, then writes the operand value to the new stack pointer location. In 64-bit mode, PUSH works with 64-bit or 16-bit operands (32-bit PUSH is not directly available; 32-bit values are sign-extended to 64 bits when necessary).

The operation sequence for `PUSH RAX` in 64-bit mode:

1. RSP = RSP - 8 (decrement by 8 bytes for 64-bit operand)
2. [RSP] = RAX (write RAX value to memory at new RSP)

PUSH supports multiple operand types:

**Register operands**: `PUSH RAX` pushes the 64-bit value in RAX. All general-purpose registers can be pushed: RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP, R8-R15. Segment registers can also be pushed: PUSH CS, PUSH DS, PUSH ES, PUSH FS, PUSH GS, PUSH SS.

**Memory operands**: `PUSH QWORD [RBX]` reads 8 bytes from the address in RBX and pushes that value. Memory operands must specify size explicitly (QWORD, WORD) to avoid ambiguity.

**Immediate operands**: `PUSH 42` pushes the immediate value 42 onto the stack. Immediate values are sign-extended to the operand size. `PUSH -1` in 64-bit mode pushes 0xFFFFFFFFFFFFFFFF. Immediate operands in 64-bit mode can be 8-bit or 32-bit, sign-extended to 64 bits.

In 64-bit mode:

- `PUSH reg64` or `PUSH r/m64` (default): 8-byte push
- `PUSH reg16` or `PUSH r/m16` (with 0x66 prefix): 2-byte push
- `PUSH imm8` or `PUSH imm32`: Immediate sign-extended to 64 bits, 8-byte push

PUSH operations are not atomic by default. When multiple processors or threads access the same stack (which should be avoided), explicit synchronization is required.

Pushing RSP itself has defined behavior: `PUSH RSP` pushes the value of RSP before the decrement. This means the pushed value is 8 bytes higher than the final RSP value after the PUSH completes.

### POP Instruction

POP reads the value at the current stack pointer location, then increments the stack pointer by the operand size. The operation sequence for `POP RAX` in 64-bit mode:

1. RAX = [RSP] (read 8 bytes from memory at RSP)
2. RSP = RSP + 8 (increment by 8 bytes)

POP supports register and memory operands but not immediate operands (since there's no meaningful interpretation of popping into a constant):

**Register operands**: `POP RBX` pops 8 bytes from the stack into RBX. All general-purpose and segment registers (except CS) can receive popped values.

**Memory operands**: `POP QWORD [RDI]` pops 8 bytes from the stack and writes them to the memory address in RDI. This is less common than register pops.

In 64-bit mode:

- `POP reg64` or `POP r/m64` (default): 8-byte pop
- `POP reg16` or `POP r/m16` (with 0x66 prefix): 2-byte pop

Popping into RSP replaces the stack pointer with the popped value: `POP RSP` sets RSP to the value at [RSP], effectively jumping to a different stack location. This is rarely intentional and usually indicates an error.

CS cannot be loaded via POP in protected mode or long mode, as changing CS requires special far transfer instructions (far CALL, far JMP, far RET, or interrupt returns) that ensure proper privilege level and segment validation.

### PUSHA/POPA and PUSHAD/POPAD

PUSHA (16-bit) and PUSHAD (32-bit) push all general-purpose registers onto the stack in a single instruction. POPA and POPAD restore them. These instructions are not available in 64-bit mode.

PUSHAD pushes registers in this order: EAX, ECX, EDX, EBX, ESP (original value), EBP, ESI, EDI. Total: 32 bytes (8 registers × 4 bytes).

POPAD pops in reverse order: EDI, ESI, EBP, discard (original ESP), EBX, EDX, ECX, EAX.

These instructions provided convenient register preservation but had limited usefulness because they pushed all registers indiscriminately, including those not needing preservation. Modern code explicitly pushes only the registers requiring preservation.

### PUSHF/POPF Instructions

PUSHF, PUSHFD, and PUSHFQ push the flags register onto the stack. POPF, POPFD, and POPFQ restore it.

- **PUSHF**: Pushes 16-bit FLAGS register (16-bit mode or with operand-size override)
- **PUSHFD**: Pushes 32-bit EFLAGS register (32-bit mode default)
- **PUSHFQ**: Pushes 64-bit RFLAGS register (64-bit mode default)

Similarly, POPF variants restore the flags register from the stack. These instructions are useful for saving and restoring processor state, particularly in exception handlers and context switching.

Certain flags cannot be modified via POPF in user mode. System flags like IF, IOPL, VM, VIF, and VIP have restrictions based on privilege level and processor mode. Attempting to modify privileged flags from user mode (ring 3) silently fails - the bits remain unchanged.

### Stack Alignment Considerations

Modern calling conventions require stack alignment at function call boundaries. The System V AMD64 ABI requires RSP to be 16-byte aligned immediately before executing CALL. The CALL instruction pushes the 8-byte return address, so RSP is (16n + 8) aligned when the function begins executing.

Function prologues typically allocate stack space in multiples of 16 bytes to maintain alignment:

```asm
PUSH RBP           ; RSP = 16n (aligned)
MOV RBP, RSP
SUB RSP, 32        ; Allocate 32 bytes, RSP remains 16-byte aligned
```

Failure to maintain stack alignment can cause:

- Performance degradation with misaligned memory accesses
- Exceptions from SSE/AVX instructions requiring aligned operands
- Incorrect behavior in called functions expecting alignment
- Violations detected by runtime checks in debug builds

### Common PUSH/POP Patterns

**Register preservation across function calls**:

```asm
PUSH RBX           ; Save RBX
PUSH R12           ; Save R12
; Function body uses RBX and R12
POP R12            ; Restore R12
POP RBX            ; Restore RBX (reverse order)
RET
```

**Swapping register values**:

```asm
PUSH RAX
PUSH RBX
POP RAX            ; RAX = old RBX
POP RBX            ; RBX = old RAX
```

However, XCHG is more efficient for simple swaps.

**Parameter passing (historical)**:

```asm
PUSH 30            ; Third parameter
PUSH 20            ; Second parameter
PUSH 10            ; First parameter
CALL function
ADD RSP, 24        ; Clean up stack (caller cleanup)
```

Modern 64-bit calling conventions pass most parameters in registers, using the stack only for additional parameters.

**Temporary storage**:

```asm
PUSH RAX           ; Save RAX temporarily
MOV RAX, RCX
IMUL RAX, RAX      ; RAX = RCX * RCX
MOV RDX, RAX       ; Result in RDX
POP RAX            ; Restore original RAX
```

**Quick memory-to-memory transfer**:

```asm
PUSH QWORD [RSI]   ; Push value from memory
POP QWORD [RDI]    ; Pop to different memory
```

This transfers 8 bytes from [RSI] to [RDI] using the stack as an intermediary, though MOV with a register is typically preferred.

