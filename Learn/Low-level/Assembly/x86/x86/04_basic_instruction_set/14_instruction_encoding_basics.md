## Instruction Encoding Basics


x86 instruction encoding is variable-length and complex, reflecting the architecture's evolution over decades. Instructions range from 1 to 15 bytes, with multiple optional prefixes and addressing modes.

### Instruction Format Structure

An x86 instruction consists of several optional and required components in this order:

1. **Legacy Prefixes** (0-4 bytes): Optional prefixes that modify instruction behavior
2. **REX Prefix** (0-1 bytes): Required for 64-bit operands and extended registers (64-bit mode only)
3. **Opcode** (1-3 bytes): The operation code identifying the instruction
4. **ModR/M Byte** (0-1 bytes): Specifies addressing mode and operands
5. **SIB Byte** (0-1 bytes): Scale-Index-Base byte for complex addressing
6. **Displacement** (0, 1, 2, or 4 bytes): Memory address displacement
7. **Immediate** (0, 1, 2, 4, or 8 bytes): Immediate operand value

Not all components appear in every instruction. Simple instructions like `NOP` consist of a single opcode byte, while complex memory operations with large immediates can use many bytes.

### Legacy Prefixes

Legacy prefixes are optional single-byte codes that modify instruction behavior. Multiple prefixes can appear, though certain combinations are meaningless or cause undefined behavior. Prefixes include:

**Operand-size override prefix (0x66)**: Changes the default operand size. In 32-bit mode, it switches from 32-bit to 16-bit operands. In 64-bit mode, it switches from 32-bit to 16-bit (64-bit requires REX prefix). Some instructions repurpose this prefix for encoding SSE variants.

**Address-size override prefix (0x67)**: Changes the default address size. In 32-bit mode, it switches to 16-bit addressing. In 64-bit mode, it switches from 64-bit to 32-bit addressing.

**Segment override prefixes**: CS (0x2E), SS (0x36), DS (0x3E), ES (0x26), FS (0x64), GS (0x65) override the default segment for memory operations. In 64-bit mode, most segment overrides are ignored except FS and GS.

**Lock prefix (0xF0)**: Makes certain memory-access instructions atomic. Only valid with specific instructions that read-modify-write memory.

**Repeat prefixes**: REP (0xF3), REPE/REPZ (0xF3), REPNE/REPNZ (0xF2) repeat string instructions. These prefixes are repurposed for encoding SSE and other instruction variants.

**Branch prediction hints**: 0x2E (branch not taken) and 0x3E (branch taken) provide hints for conditional branches. [Inference] Modern processors largely ignore these hints, relying on hardware branch prediction instead.

Prefix ordering matters when multiple prefixes are present. [Unverified] Certain prefix orders may cause different behavior or be invalid, though processors generally tolerate various orderings for backward compatibility.

### REX Prefix

The REX (Register Extension) prefix enables 64-bit operand size and access to extended registers (R8-R15) in 64-bit mode. The REX prefix is a single byte: 0100WRXB (binary), where the high nibble is always 0100 (0x4X).

REX prefix bit fields:

- **W (bit 3)**: When set, specifies 64-bit operand size; when clear, uses default size (usually 32-bit)
- **R (bit 2)**: Extends the ModR/M reg field (adds bit 3 to register encodings)
- **X (bit 1)**: Extends the SIB index field
- **B (bit 0)**: Extends the ModR/M r/m field or SIB base field

REX values range from 0x40 to 0x4F. `REX.W` (0x48-0x4F) specifies 64-bit operations. `REX.R` (0x44-0x47, 0x4C-0x4F) accesses registers R8-R15 as the destination or reg operand. `REX.B` (0x41-0x43, 0x45-0x47, 0x49-0x4B, 0x4D-0x4F) accesses R8-R15 as the source or base register.

Example: `MOV RAX, R8` encodes as:

- REX.W + REX.B (0x49): 64-bit operation, extended source register
- Opcode (0x89 or 0x8B): MOV instruction
- ModR/M byte: Specifies register-to-register mode with register encodings

The REX prefix must immediately precede the opcode. Legacy prefixes must come before REX. In 64-bit mode, instructions accessing extended registers or using 64-bit operands require appropriate REX prefix bytes.

### Opcode

The opcode identifies the instruction operation. Opcodes are 1-3 bytes:

**Single-byte opcodes** (0x00-0xFF): Most common instructions use single-byte opcodes. `MOV`, `ADD`, `SUB`, `PUSH`, `POP`, and many others encode in one byte. The opcode often indicates the instruction and sometimes part of the operand specification.

**Two-byte opcodes** (0x0F XX): Extended instructions use escape prefix 0x0F followed by a second opcode byte. Many newer instructions, SSE operations, and privileged instructions use two-byte opcodes. For example, `MOVZX` uses 0x0F 0xB6 or 0x0F 0xB7.

**Three-byte opcodes** (0x0F 0x38 XX or 0x0F 0x3A XX): Modern instruction extensions (SSE4, AVX, etc.) use three-byte opcodes with escape sequences 0x0F 0x38 or 0x0F 0x3A followed by a third opcode byte.

Some opcodes encode specific registers. For example, `PUSH RAX` encodes as 0x50, `PUSH RCX` as 0x51, through `PUSH RDI` as 0x57. The register is encoded in the low 3 bits of the opcode. Similar encodings exist for other instructions with register-specific variants.

Opcode bytes may contain:

- Direction bit (d): Indicates whether reg field is source or destination
- Size bit (w): Indicates 8-bit vs full-size operand
- Condition codes: For conditional jumps and sets, the condition is encoded in opcode bits
- Register encoding: Low bits may encode a specific register

### ModR/M Byte

The ModR/M (Mode-Register-Memory) byte specifies addressing modes and operands for most instructions. Its format is: MMRRRMMM (binary), interpreted as three fields:

- **Mod (bits 7-6)**: Addressing mode
- **Reg/Opcode (bits 5-3)**: Register operand or additional opcode bits
- **R/M (bits 2-0)**: Register or memory operand

**Mod field values**:

- **00**: Register indirect addressing [reg] with special cases
- **01**: Register indirect + 8-bit displacement [reg + disp8]
- **10**: Register indirect + 32-bit displacement [reg + disp32]
- **11**: Register direct (operands are both registers)

**Reg field**: Encodes one register operand (combined with REX.R for extended registers):

- 000/1000: RAX/R8
- 001/1001: RCX/R9
- 010/1010: RDX/R10
- 011/1011: RBX/R11
- 100/1100: RSP/R12
- 101/1101: RBP/R13
- 110/1110: RSI/R14
- 111/1111: RDI/R15

For some instructions, the Reg field contains opcode extension bits instead of a register encoding.

**R/M field**: Encodes the second operand, either a register (when Mod=11) or base register for memory addressing (when Mod≠11). Values 000-111 encode RAX-RDI (extended to R8-R15 with REX.B).

Special cases:

- R/M=100 (RSP) with Mod≠11 indicates SIB byte follows
- R/M=101 with Mod=00 indicates RIP-relative addressing (64-bit mode) or 32-bit displacement-only (32-bit mode)

### SIB Byte

The SIB (Scale-Index-Base) byte provides complex addressing modes with scaled index registers. Its format is: SSIIIBBB (binary):

- **Scale (bits 7-6)**: Scaling factor (00=×1, 01=×2, 10=×4, 11=×8)
- **Index (bits 5-3)**: Index register (extended by REX.X)
- **Base (bits 2-0)**: Base register (extended by REX.B)

The SIB byte appears when ModR/M specifies R/M=100 (RSP) with Mod≠11. The effective address is calculated as: Base + (Index × Scale) + Displacement.

Index values 000-111 encode RAX-RDI / R8-R15. Index=100 (RSP) is special - it indicates no index register (scaling doesn't apply).

Base values 000-111 encode RAX-RDI / R8-R15. Base=101 (RBP) with Mod=00 indicates no base register (displacement-only mode).

Example addressing modes:

- `[RAX + RCX*4]`: Base=RAX, Index=RCX, Scale=4
- `[RBX + RSI*8 + 0x100]`: Base=RBX, Index=RSI, Scale=8, Displacement=0x100
- `[R12 + R13*2]`: Base=R12, Index=R13, Scale=2 (requires REX.X and REX.B)

The SIB byte enables array indexing and complex data structure access with a single instruction.

### Displacement and Immediate

**Displacement** is an offset added to a memory address calculation. Displacement size depends on the Mod field:

- Mod=00 with special cases: 32-bit displacement (or none with SIB)
- Mod=01: 8-bit signed displacement
- Mod=10: 32-bit signed displacement

Displacements are sign-extended to address size. In 64-bit mode, 32-bit displacements sign-extend to 64 bits.

**Immediate** values are constant operands encoded directly in the instruction. Immediate size depends on the instruction and operand size:

- 8-bit immediate: Used for small constants and byte operations
- 16-bit immediate: Used with 16-bit operands
- 32-bit immediate: Common for 32-bit operands; sign-extends in 64-bit mode
- 64-bit immediate: Only available with MOV to 64-bit registers

Most instructions with immediate operands in 64-bit mode use 32-bit immediates that sign-extend to 64 bits. The `MOV` instruction has a special encoding that accepts full 64-bit immediates: `MOV RAX, 0x123456789ABCDEF0` encodes the full 64-bit value.

Sign extension allows 32-bit immediates to efficiently encode negative 64-bit values. `ADD RAX, -1` uses a 32-bit immediate 0xFFFFFFFF, which sign-extends to 0xFFFFFFFFFFFFFFFF.

### Encoding Examples

**Simple register-to-register MOV**: `MOV RAX, RBX`

- REX.W: 0x48 (64-bit operand)
- Opcode: 0x89 (MOV r/m64, r64)
- ModR/M: 0xD8 (Mod=11 register direct, Reg=011 RBX, R/M=000 RAX)
- Total: 48 89 D8

**MOV with immediate**: `MOV EAX, 42`

- Opcode: 0xB8 (MOV EAX, imm32 - register encoded in opcode)
- Immediate: 0x0000002A (32-bit value 42)
- Total: B8 2A 00 00 00

**MOV with memory operand**: `MOV RAX, [RBX + 8]`

- REX.W: 0x48 (64-bit operand)
- Opcode: 0x8B (MOV r64, r/m64)
- ModR/M: 0x43 (Mod=01 8-bit displacement, Reg=000 RAX, R/M=011 RBX)
- Displacement: 0x08 (8-bit value)
- Total: 48 8B 43 08

**ADD with SIB**: `ADD RAX, [RBX + RCX*4 + 0x100]`

- REX.W: 0x48 (64-bit operand)
- Opcode: 0x03 (ADD r64, r/m64)
- ModR/M: 0x84 (Mod=10 32-bit displacement, Reg=000 RAX, R/M=100 SIB follows)
- SIB: 0x8B (Scale=10 ×4, Index=001 RCX, Base=011 RBX)
- Displacement: 0x00000100 (32-bit value)
- Total: 48 03 84 8B 00 01 00 00

**ADD using extended registers**: `ADD R8, R9`

- REX.W + REX.R + REX.B: 0x4D (64-bit, both extended registers)
- Opcode: 0x01 (ADD r/m64, r64)
- ModR/M: 0xC8 (Mod=11 register direct, Reg=001 R9, R/M=000 R8)
- Total: 4D 01 C8

### VEX and EVEX Prefixes

Modern instruction extensions (AVX, AVX2, AVX-512) use VEX and EVEX encoding schemes instead of legacy prefixes and REX.

**VEX (Vector Extension)** prefixes are 2 or 3 bytes and replace REX, operand-size prefix, and opcode escape bytes. VEX encoding provides:

- Encoding for 3-operand instructions (destination, source1, source2)
- Access to extended registers
- Vector length specification (128-bit XMM vs 256-bit YMM)
- Opcode map selection

Two-byte VEX (0xC5 + byte): Used for most common AVX instructions when extended registers or features aren't needed.

Three-byte VEX (0xC4 + two bytes): Used for AVX instructions requiring extended registers, opcode maps, or additional encoding bits.

**EVEX (Enhanced VEX)** prefixes are 4 bytes (0x62 + three bytes) and support AVX-512 features:

- 512-bit ZMM registers
- Opmask registers (K0-K7) for predication
- Additional registers (16 extra vector registers, total 32)
- Embedded broadcast, rounding, and suppress-all-exceptions modes

VEX and EVEX encodings are complex and not backward compatible with processors lacking AVX support. [Inference] Attempting to execute VEX/EVEX encoded instructions on non-supporting processors generates invalid opcode exceptions.

### Instruction Length Limits

x86 instructions have a maximum length of 15 bytes. Instructions exceeding this length cause a general protection fault. The 15-byte limit includes all prefixes, opcodes, ModR/M, SIB, displacement, and immediate bytes.

[Inference] The length limit can be reached with:

- Multiple legacy prefixes (up to 4 bytes)
- REX prefix (1 byte)
- Three-byte opcode (3 bytes)
- ModR/M byte (1 byte)
- SIB byte (1 byte)
- 32-bit displacement (4 bytes)
- 32-bit immediate (4 bytes)
- Total: 4 + 1 + 3 + 1 + 1 + 4 + 4 = 18 bytes potential

However, not all prefix combinations are valid, and not all instructions use all components, making 15 bytes a sufficient practical limit.

Assemblers and compilers must ensure generated instructions don't exceed the length limit. Hand-coded assembly with excessive prefix usage could theoretically violate this constraint.

### Encoding Efficiency

x86 encoding supports variable-length instructions to balance code density and functionality. Common instructions encode compactly:

- `NOP`: 1 byte (0x90)
- `PUSH RAX`: 1 byte (0x50)
- `RET`: 1 byte (0xC3)
- `MOV EAX, EBX`: 2 bytes (0x89 0xD8)
- `ADD EAX, 5`: 3 bytes (0x83 0xC0 0x05)

Complex operations require more bytes:

- `MOV RAX, [RBX + RCX*8 + 0x12345678]`: 8 bytes
- `IMUL RAX, [RSI + RDI*4], 0x7FFFFFFF`: 10+ bytes

The encoding scheme prioritizes common operations with short encodings while supporting complex addressing modes when needed. [Inference] This variable-length approach improves code density compared to fixed-length RISC architectures but complicates instruction decode logic.

Modern x86 processors include sophisticated decoders that break complex variable-length x86 instructions into fixed-length internal micro-operations (μops) for efficient pipelined execution. The instruction encoding complexity is largely hidden from the execution core by the decode stage.

**Key Points:**

- CMP subtracts operands and sets flags without storing results; TEST performs AND and sets flags without storing results; both are essential for conditional branching
- NOP performs no operation and is used for alignment, timing, and code patching; PAUSE improves spin-wait loop efficiency; CPUID returns processor identification and feature information
- x86 instructions use variable-length encoding (1-15 bytes) with optional legacy prefixes, REX prefix (64-bit mode), opcode (1-3 bytes), ModR/M byte for addressing, SIB byte for complex addressing, displacement, and immediate values
- The ModR/M byte encodes addressing modes (Mod field), register operands (Reg field), and register/memory operands (R/M field); the SIB byte enables scaled index addressing with Base + (Index × Scale) + Displacement

---

