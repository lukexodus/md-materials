## Data Movement Instructions


Data movement instructions transfer data between registers, memory, and immediate values without performing arithmetic or logical operations. These instructions form the foundation of all ARM programs by loading operands, storing results, and copying values between locations.

### MOV - Move Register or Immediate

The MOV instruction copies a value from one register to another or loads an immediate value into a register. It provides the simplest form of data transfer within the processor's register file.

**Syntax and Variants**

Basic syntax follows the pattern `MOV destination, source` where destination is always a register and source can be a register or immediate value. The instruction updates the destination register without affecting the source when copying between registers.

**Immediate Value Limitations**

ARM processors have encoding restrictions on immediate values in MOV instructions. The ARM32 instruction set can only encode certain immediate values directly - specifically those that can be represented by rotating an 8-bit value by an even number of positions. Values like 255, 0x100, 0xFF00 are encodable, but arbitrary 32-bit values like 0x12345678 cannot be loaded with a single MOV instruction.

**MOVW and MOVT for Large Immediates**

ARMv7 and later architectures provide MOVW (move wide) and MOVT (move top) instructions to load arbitrary 16-bit values into the lower or upper half of a register. Loading a full 32-bit immediate requires two instructions: MOVW loads the lower 16 bits, then MOVT loads the upper 16 bits without affecting the lower half.

**Example:**

```assembly
MOV r0, r1           @ Copy r1 to r0
MOV r2, #42          @ Load immediate 42 into r2
MOV r3, #0xFF00      @ Valid rotated immediate
MOVW r4, #0x5678     @ Load lower 16 bits
MOVT r4, #0x1234     @ Load upper 16 bits, r4 = 0x12345678
```

### LDR - Load Register from Memory

LDR instructions read data from memory into registers. Memory addresses are calculated using base registers with optional offsets, enabling access to data structures, arrays, and stack variables.

**Addressing Modes**

ARM supports multiple addressing modes for memory access. Offset addressing adds a constant or register to the base address without modifying the base register. Pre-indexed addressing adds the offset to the base and writes the result back to the base register before accessing memory. Post-indexed addressing uses the base address for memory access, then adds the offset to the base register afterward.

**Syntax Variations**

Offset mode: `LDR rd, [rn, #offset]` loads from address rn + offset without changing rn. Pre-indexed mode: `LDR rd, [rn, #offset]!` updates rn to rn + offset before loading. Post-indexed mode: `LDR rd, [rn], #offset` loads from rn then updates rn to rn + offset.

**Data Size Variants**

Different instruction suffixes load different data sizes. LDR loads 32-bit words, LDRH loads 16-bit halfwords, LDRB loads 8-bit bytes. Signed variants LDRSH and LDRSB sign-extend smaller values to 32 bits, while unsigned variants zero-extend.

**PC-Relative Loading**

LDR with PC as the base register enables position-independent code and access to constants stored in literal pools. The assembler pseudo-instruction `LDR rd, =value` loads arbitrary 32-bit constants by either using MOV/MOVW/MOVT or loading from a nearby literal pool.

**Example:**

```assembly
LDR r0, [r1]         @ Load word from address in r1
LDR r2, [r3, #16]    @ Load from r3 + 16
LDR r4, [r5, #4]!    @ Pre-indexed: r5 = r5 + 4, load from new r5
LDR r6, [r7], #8     @ Post-indexed: load from r7, then r7 = r7 + 8
LDRB r8, [r9]        @ Load byte (8-bit)
LDRH r10, [r11]      @ Load halfword (16-bit)
LDRSB r12, [sp, #-4] @ Load signed byte, negative offset
LDR r0, =0x12345678  @ Load 32-bit constant (pseudo-instruction)
```

### STR - Store Register to Memory

STR instructions write register contents to memory locations. Addressing modes and variants mirror those of LDR instructions, maintaining symmetry between load and store operations.

**Basic Store Operations**

Store instructions transfer data from registers to memory addresses calculated using the same addressing modes as loads. The register being stored provides the value, while the addressing expression determines the destination memory location.

**Size Variants**

STR stores 32-bit words, STRH stores 16-bit halfwords (lower 16 bits of register), and STRB stores 8-bit bytes (lower 8 bits of register). Upper bits are ignored when storing smaller data sizes.

**Stack Operations**

STR with pre-indexed or post-indexed addressing modes implements stack operations. Pushing to a full descending stack uses `STR rd, [sp, #-4]!` which decrements sp then stores. Popping uses `LDR rd, [sp], #4` which loads then increments sp.

**Example:**

```assembly
STR r0, [r1]         @ Store word to address in r1
STR r2, [r3, #20]    @ Store to r3 + 20
STR r4, [r5, #-8]!   @ Pre-indexed: r5 = r5 - 8, store to new r5
STR r6, [r7], #12    @ Post-indexed: store to r7, then r7 = r7 + 12
STRB r8, [r9]        @ Store byte (lower 8 bits)
STRH r10, [r11]      @ Store halfword (lower 16 bits)
```

### Multiple Register Transfers

LDM (load multiple) and STM (store multiple) instructions transfer multiple registers in a single instruction, improving code density and potentially performance. These instructions are particularly useful for function prologue/epilogue, context switching, and bulk data transfers.

**Stack Variants**

PUSH and POP are pseudo-instructions that expand to STMDB (store multiple decrement before) and LDMIA (load multiple increment after) operating on the stack pointer. `PUSH {r0-r3, lr}` stores five registers to the stack, `POP {r0-r3, pc}` restores them and returns from a function by loading the return address into PC.

