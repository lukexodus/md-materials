## Instruction Encoding and Formats


ARM instructions are encoded as fixed-width binary patterns that the processor decodes and executes. Understanding encoding helps optimize code and explains instruction limitations.

### Fixed-Width Instruction Encoding

ARMv7 uses 32-bit fixed-width instruction encoding in ARM mode. Every instruction occupies exactly 4 bytes in memory, simplifying instruction fetch and pipeline design. [Inference] Fixed-width encoding allows the processor to predict instruction locations and fetch multiple instructions efficiently.

ARMv7 also supports Thumb mode with 16-bit instructions (and Thumb-2 with mixed 16/32-bit instructions), providing better code density at some cost to functionality per instruction.

ARMv8 AArch64 uses 32-bit fixed-width encoding uniformly, abandoning variable-width encoding.

### Instruction Format Components

ARM instructions encode several fields within the 32-bit word:

**Condition field** (bits 31-28): 4-bit field specifying execution condition. 0b1110 (14) represents "always" (AL), the unconditional default.

**Opcode field**: Specifies the operation type (ADD, SUB, LDR, etc.). Location and size vary by instruction type.

**Register fields**: Specify source and destination registers. Each register field is typically 4 bits (allowing selection of 16 registers R0-R15).

**Operand fields**: Encode immediate values, shift amounts, or addressing mode parameters. Size and interpretation depend on instruction type.

**Modifier bits**: Control flag updates (S bit), addressing modes, data sizes, etc.

### Data Processing Format

Data processing instructions (arithmetic, logical, comparison) follow a common encoding structure:

```
[Cond][00][I][Opcode][S][Rn][Rd][Operand2]
```

- **Cond** (4 bits): Condition code
- **I** (1 bit): Immediate operand flag (0=register, 1=immediate)
- **Opcode** (4 bits): Operation (ADD=0100, SUB=0010, etc.)
- **S** (1 bit): Set condition flags
- **Rn** (4 bits): First source register
- **Rd** (4 bits): Destination register
- **Operand2** (12 bits): Second operand encoding

**Example** encoding of `ADD r0, r1, r2`:
```
Cond=1110 (AL), I=0 (register), Opcode=0100 (ADD), S=0
Rn=0001 (r1), Rd=0000 (r0), Rm=0010 (r2), Shift=00000000
Result: 0xE0810002
```

### Immediate Value Encoding

Immediate values face encoding constraints within the 12-bit Operand2 field. ARM uses a special encoding scheme with 8-bit value and 4-bit rotation.

An immediate is encoded as: 8-bit value rotated right by (2 × 4-bit rotate field) positions.

This allows representing various useful constants efficiently:
- 0-255: directly encodable
- 0xFF00, 0xFF0000, 0xFF000000: rotations of 0xFF
- Powers of 2 and nearby values

**Example** valid immediates:
- #100: 0x64, directly encodable
- #0x300: 0x03 rotated right by 24 (rotate=12)
- #0xFF000000: 0xFF rotated right by 8 (rotate=4)

**Example** invalid immediates:
- #0x101: Cannot be represented as rotated 8-bit value
- #0xFFFF: Cannot be represented in the encoding scheme

[Inference] For invalid immediates, the assembler may use alternate approaches like loading from a literal pool, or decomposing into multiple operations.

### Load/Store Format

Load and store instructions encode memory addressing modes:

```
[Cond][01][I][P][U][B][W][L][Rn][Rd][Offset]
```

- **Cond** (4 bits): Condition code
- **I** (1 bit): Immediate offset (0) or register offset (1)
- **P** (1 bit): Pre-indexed (1) or post-indexed (0)
- **U** (1 bit): Add offset (1) or subtract offset (0)
- **B** (1 bit): Byte transfer (1) or word transfer (0)
- **W** (1 bit): Write-back (update base register)
- **L** (1 bit): Load (1) or store (0)
- **Rn** (4 bits): Base address register
- **Rd** (4 bits): Source/destination register
- **Offset** (12 bits): Offset encoding

**Example** `LDR r0, [r1, #8]`:
```
Cond=1110 (AL), I=0, P=1 (pre-indexed), U=1 (add), B=0 (word)
W=0 (no writeback), L=1 (load), Rn=0001 (r1), Rd=0000 (r0)
Offset=8
```

### Branch Format

Branch instructions encode target addresses as PC-relative offsets:

```
[Cond][101][L][Offset]
```

- **Cond** (4 bits): Condition code
- **L** (1 bit): Link bit (save return address for BL)
- **Offset** (24 bits): Signed offset in words (×4 for byte offset)

The 24-bit offset allows branching ±32MB from the current instruction. Offsets are multiplied by 4 because instructions are word-aligned.

**Example** branch calculation:
```
Current PC = 0x8000
Offset = 0x000010 (16 decimal)
Target = PC + (Offset << 2) + 8
       = 0x8000 + (16 × 4) + 8
       = 0x8048
```

The "+8" accounts for ARM's pipeline where PC points two instructions ahead during execution.

### Thumb Encoding

Thumb mode uses 16-bit instruction encoding for improved code density. Thumb instructions have limited functionality compared to ARM instructions:

- Access to only lower 8 registers (R0-R7) in most instructions
- Limited immediate ranges
- Fewer addressing modes
- Most instructions unconditional

Thumb-2 extends Thumb with 32-bit instructions (encoded as two 16-bit halfwords) that provide functionality approaching ARM mode while maintaining code density benefits.

**Example** Thumb instruction `ADDS r0, r1, r2` (16-bit):
```
Format: [000110][0][Rm][Rn][Rd]
Opcode=000110 (ADD), S=0, Rm=010 (r2), Rn=001 (r1), Rd=000 (r0)
```

Thumb-2 allows mixed 16-bit and 32-bit instructions in the same code, with [Inference] the processor detecting instruction width from specific bit patterns in the first halfword.

### Literal Pool

When immediate values cannot be encoded directly, assemblers place them in a literal pool—a region of constant data near the code. Instructions load these values using PC-relative addressing.

```
LDR r0, =0x12345678   @ Assembler directive
@ Becomes:
LDR r0, [PC, #offset] @ Load from literal pool

@ Later in code:
.ltorg                @ Literal pool location
.word 0x12345678      @ Constant value
```

The assembler automatically manages literal pool placement and generates appropriate load instructions. Programmers can explicitly place pools using `.ltorg` directives to ensure they remain within the ±4KB offset range of referring instructions.

### Instruction Alignment

Instructions must be aligned according to their size:
- ARM mode: 4-byte alignment (addresses divisible by 4)
- Thumb mode: 2-byte alignment (addresses divisible by 2)

[Unverified] Executing an instruction from a misaligned address typically triggers an alignment fault. The processor may use the lowest bits of the PC to determine instruction set mode, so proper alignment is critical.

