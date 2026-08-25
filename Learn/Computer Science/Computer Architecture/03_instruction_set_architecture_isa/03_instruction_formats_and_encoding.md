## Instruction Formats and Encoding


---

### Purpose and Design Constraints

An instruction format defines the binary layout of a machine instruction — the exact bit fields, their widths, their positions, and their interpretations. Encoding is the mapping from the abstract instruction (opcode + operands) to a fixed or variable-length binary representation that hardware decodes.

Format design is a direct engineering trade-off among competing constraints:

- **Decode complexity** — irregular formats require more logic and increase cycle time
- **Code density** — narrower instructions reduce instruction cache pressure and memory bandwidth
- **Operand expressiveness** — more bits per field allow more registers, larger immediates, or more addressing modes
- **Extensibility** — reserved opcode space must be sufficient for future ISA versions
- **Alignment** — fixed-length instructions simplify fetch and PC arithmetic; variable-length complicates both

---

### Fixed-Length vs. Variable-Length Encoding

**Fixed-length encoding** assigns every instruction the same bit width (commonly 32 bits). Fetch is trivial — one aligned word per cycle. Decode is a single-stage fan-out from fixed bit positions. The cost is code density: short operations (increment, no-op) waste bits; large immediates require multiple instructions or special formats.

**Variable-length encoding** allows instructions of different widths, typically in byte multiples (1–15 bytes in x86). Code density is high — common short operations have short encodings. The cost is decode complexity: the hardware must first determine instruction length before it can decode fields, creating a sequential dependency that complicates superscalar fetch.

|Property|Fixed-Length|Variable-Length|
|---|---|---|
|Fetch complexity|Simple (aligned word)|Complex (length discovery)|
|Decode|Parallel, field-fixed|Sequential length then decode|
|Code density|Lower|Higher|
|Pipeline regularity|High|Low|
|Examples|MIPS, ARM A32, RISC-V RV32I|x86, x86-64, VAX|

---

### Instruction Fields

Every instruction format partitions its bits into fields. The common fields across architectures:

|Field|Typical Width|Purpose|
|---|---|---|
|Opcode|4–8 bits|Identifies the operation|
|Register specifier (rs, rt, rd)|3–5 bits|Source and destination registers|
|Immediate|8–16 bits|Inline constant value|
|Function code (funct)|4–6 bits|Extends opcode for operation subtype|
|Shamt|5 bits|Shift amount|
|Offset / displacement|12–32 bits|Memory address offset or branch target|

The number of bits allocated to register specifiers directly determines the architectural register count: 5 bits → 32 registers, 4 bits → 16 registers, 3 bits → 8 registers.

---

### MIPS R-Type, I-Type, J-Type

MIPS uses a strict 32-bit fixed-length format with three variants.

**R-Type (Register):** Used for ALU operations with three register operands.

<svg viewBox="0 0 720 90" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <rect x="0" y="20" width="120" height="40" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <rect x="120" y="20" width="100" height="40" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/> <rect x="220" y="20" width="100" height="40" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/> <rect x="320" y="20" width="100" height="40" fill="#ffd6d6" stroke="#336" stroke-width="1.5"/> <rect x="420" y="20" width="100" height="40" fill="#fff5cc" stroke="#336" stroke-width="1.5"/> <rect x="520" y="20" width="200" height="40" fill="#ffe8d0" stroke="#336" stroke-width="1.5"/> <text x="60" y="44" text-anchor="middle" fill="#222">opcode</text> <text x="170" y="44" text-anchor="middle" fill="#222">rs</text> <text x="270" y="44" text-anchor="middle" fill="#222">rt</text> <text x="370" y="44" text-anchor="middle" fill="#222">rd</text> <text x="470" y="44" text-anchor="middle" fill="#222">shamt</text> <text x="620" y="44" text-anchor="middle" fill="#222">funct</text> <text x="60" y="72" text-anchor="middle" fill="#555" font-size="11">[31:26] 6b</text> <text x="170" y="72" text-anchor="middle" fill="#555" font-size="11">[25:21] 5b</text> <text x="270" y="72" text-anchor="middle" fill="#555" font-size="11">[20:16] 5b</text> <text x="370" y="72" text-anchor="middle" fill="#555" font-size="11">[15:11] 5b</text> <text x="470" y="72" text-anchor="middle" fill="#555" font-size="11">[10:6] 5b</text> <text x="620" y="72" text-anchor="middle" fill="#555" font-size="11">[5:0] 6b</text> </svg>

The opcode for all R-type instructions is `000000`. The `funct` field distinguishes operations (ADD, SUB, AND, OR, SLT, etc.). This splits the decode into two stages: opcode identifies R-type, funct identifies the specific ALU operation.

**I-Type (Immediate):** Used for ALU-immediate, load, store, and branch instructions.

<svg viewBox="0 0 720 90" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <rect x="0" y="20" width="120" height="40" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <rect x="120" y="20" width="100" height="40" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/> <rect x="220" y="20" width="100" height="40" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/> <rect x="320" y="20" width="400" height="40" fill="#ffeedd" stroke="#336" stroke-width="1.5"/> <text x="60" y="44" text-anchor="middle" fill="#222">opcode</text> <text x="170" y="44" text-anchor="middle" fill="#222">rs</text> <text x="270" y="44" text-anchor="middle" fill="#222">rt</text> <text x="520" y="44" text-anchor="middle" fill="#222">immediate</text> <text x="60" y="72" text-anchor="middle" fill="#555" font-size="11">[31:26] 6b</text> <text x="170" y="72" text-anchor="middle" fill="#555" font-size="11">[25:21] 5b</text> <text x="270" y="72" text-anchor="middle" fill="#555" font-size="11">[20:16] 5b</text> <text x="520" y="72" text-anchor="middle" fill="#555" font-size="11">[15:0] 16b</text> </svg>

The 16-bit immediate is sign-extended to 32 bits before use. For `lw`/`sw`, the immediate is a byte offset added to `rs`. For branches (`beq`, `bne`), the immediate is a word offset relative to PC+4, giving a ±128 KB branch range.

**J-Type (Jump):** Used for unconditional jumps (`j`, `jal`).

<svg viewBox="0 0 720 90" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <rect x="0" y="20" width="120" height="40" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <rect x="120" y="20" width="600" height="40" fill="#e8d0ff" stroke="#336" stroke-width="1.5"/> <text x="60" y="44" text-anchor="middle" fill="#222">opcode</text> <text x="420" y="44" text-anchor="middle" fill="#222">target address</text> <text x="60" y="72" text-anchor="middle" fill="#555" font-size="11">[31:26] 6b</text> <text x="420" y="72" text-anchor="middle" fill="#555" font-size="11">[25:0] 26b</text> </svg>

The 26-bit target is a word address. The full 32-bit jump target is formed as: `{PC[31:28], target[25:0], 2'b00}` — the top 4 bits are inherited from the current PC, giving a 256 MB jump region.

---

### RISC-V Instruction Formats

RISC-V defines six base formats for RV32I. A deliberate design choice: the `rs1`, `rs2`, and `rd` fields always occupy the **same bit positions** across all formats, allowing the register file to be read before opcode decode completes.

<svg viewBox="0 0 760 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- R-type -->

<text x="0" y="18" fill="#222" font-weight="bold">R-type</text> <rect x="0" y="24" width="140" height="34" fill="#d0e8ff" stroke="#336" stroke-width="1.2"/> <rect x="140" y="24" width="100" height="34" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <rect x="240" y="24" width="100" height="34" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <rect x="340" y="24" width="80" height="34" fill="#fff5cc" stroke="#336" stroke-width="1.2"/> <rect x="420" y="24" width="100" height="34" fill="#ffd6d6" stroke="#336" stroke-width="1.2"/> <rect x="520" y="24" width="140" height="34" fill="#d0e8ff" stroke="#336" stroke-width="1.2"/> <text x="70" y="44" text-anchor="middle" fill="#222">funct7</text> <text x="190" y="44" text-anchor="middle" fill="#222">rs2</text> <text x="290" y="44" text-anchor="middle" fill="#222">rs1</text> <text x="380" y="44" text-anchor="middle" fill="#222">funct3</text> <text x="470" y="44" text-anchor="middle" fill="#222">rd</text> <text x="590" y="44" text-anchor="middle" fill="#222">opcode</text> <text x="70" y="68" text-anchor="middle" fill="#555" font-size="10">[31:25] 7b</text> <text x="190" y="68" text-anchor="middle" fill="#555" font-size="10">[24:20] 5b</text> <text x="290" y="68" text-anchor="middle" fill="#555" font-size="10">[19:15] 5b</text> <text x="380" y="68" text-anchor="middle" fill="#555" font-size="10">[14:12] 3b</text> <text x="470" y="68" text-anchor="middle" fill="#555" font-size="10">[11:7] 5b</text> <text x="590" y="68" text-anchor="middle" fill="#555" font-size="10">[6:0] 7b</text>

<!-- I-type -->

<text x="0" y="95" fill="#222" font-weight="bold">I-type</text> <rect x="0" y="101" width="240" height="34" fill="#ffeedd" stroke="#336" stroke-width="1.2"/> <rect x="240" y="101" width="100" height="34" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <rect x="340" y="101" width="80" height="34" fill="#fff5cc" stroke="#336" stroke-width="1.2"/> <rect x="420" y="101" width="100" height="34" fill="#ffd6d6" stroke="#336" stroke-width="1.2"/> <rect x="520" y="101" width="140" height="34" fill="#d0e8ff" stroke="#336" stroke-width="1.2"/> <text x="120" y="121" text-anchor="middle" fill="#222">imm[11:0]</text> <text x="290" y="121" text-anchor="middle" fill="#222">rs1</text> <text x="380" y="121" text-anchor="middle" fill="#222">funct3</text> <text x="470" y="121" text-anchor="middle" fill="#222">rd</text> <text x="590" y="121" text-anchor="middle" fill="#222">opcode</text> <text x="120" y="145" text-anchor="middle" fill="#555" font-size="10">[31:20] 12b</text> <text x="290" y="145" text-anchor="middle" fill="#555" font-size="10">[19:15]</text> <text x="380" y="145" text-anchor="middle" fill="#555" font-size="10">[14:12]</text> <text x="470" y="145" text-anchor="middle" fill="#555" font-size="10">[11:7]</text> <text x="590" y="145" text-anchor="middle" fill="#555" font-size="10">[6:0]</text>

<!-- S-type -->

<text x="0" y="172" fill="#222" font-weight="bold">S-type</text> <rect x="0" y="178" width="140" height="34" fill="#ffeedd" stroke="#336" stroke-width="1.2"/> <rect x="140" y="178" width="100" height="34" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <rect x="240" y="178" width="100" height="34" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <rect x="340" y="178" width="80" height="34" fill="#fff5cc" stroke="#336" stroke-width="1.2"/> <rect x="420" y="178" width="100" height="34" fill="#ffeedd" stroke="#336" stroke-width="1.2"/> <rect x="520" y="178" width="140" height="34" fill="#d0e8ff" stroke="#336" stroke-width="1.2"/> <text x="70" y="198" text-anchor="middle" fill="#222">imm[11:5]</text> <text x="190" y="198" text-anchor="middle" fill="#222">rs2</text> <text x="290" y="198" text-anchor="middle" fill="#222">rs1</text> <text x="380" y="198" text-anchor="middle" fill="#222">funct3</text> <text x="470" y="198" text-anchor="middle" fill="#222">imm[4:0]</text> <text x="590" y="198" text-anchor="middle" fill="#222">opcode</text> <text x="70" y="222" text-anchor="middle" fill="#555" font-size="10">[31:25] 7b</text> <text x="190" y="222" text-anchor="middle" fill="#555" font-size="10">[24:20]</text> <text x="290" y="222" text-anchor="middle" fill="#555" font-size="10">[19:15]</text> <text x="380" y="222" text-anchor="middle" fill="#555" font-size="10">[14:12]</text> <text x="470" y="222" text-anchor="middle" fill="#555" font-size="10">[11:7]</text> <text x="590" y="222" text-anchor="middle" fill="#555" font-size="10">[6:0]</text>

<!-- B-type -->

<text x="0" y="249" fill="#222" font-weight="bold">B-type</text> <rect x="0" y="255" width="20" height="34" fill="#ffeedd" stroke="#336" stroke-width="1.2"/> <rect x="20" y="255" width="120" height="34" fill="#ffeedd" stroke="#336" stroke-width="1.2"/> <rect x="140" y="255" width="100" height="34" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <rect x="240" y="255" width="100" height="34" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <rect x="340" y="255" width="80" height="34" fill="#fff5cc" stroke="#336" stroke-width="1.2"/> <rect x="420" y="255" width="80" height="34" fill="#ffeedd" stroke="#336" stroke-width="1.2"/> <rect x="500" y="255" width="20" height="34" fill="#ffeedd" stroke="#336" stroke-width="1.2"/> <rect x="520" y="255" width="140" height="34" fill="#d0e8ff" stroke="#336" stroke-width="1.2"/> <text x="10" y="275" text-anchor="middle" fill="#222" font-size="10">12</text> <text x="80" y="275" text-anchor="middle" fill="#222">10:5</text> <text x="190" y="275" text-anchor="middle" fill="#222">rs2</text> <text x="290" y="275" text-anchor="middle" fill="#222">rs1</text> <text x="380" y="275" text-anchor="middle" fill="#222">funct3</text> <text x="460" y="275" text-anchor="middle" fill="#222">4:1</text> <text x="510" y="275" text-anchor="middle" fill="#222" font-size="10">11</text> <text x="590" y="275" text-anchor="middle" fill="#222">opcode</text> <text x="0" y="299" fill="#555" font-size="9">imm bits scrambled to keep rs1/rs2/rd positions stable</text>

<!-- U-type -->

<text x="0" y="322" fill="#222" font-weight="bold">U-type</text> <rect x="0" y="328" width="420" height="34" fill="#e8d0ff" stroke="#336" stroke-width="1.2"/> <rect x="420" y="328" width="100" height="34" fill="#ffd6d6" stroke="#336" stroke-width="1.2"/> <rect x="520" y="328" width="140" height="34" fill="#d0e8ff" stroke="#336" stroke-width="1.2"/> <text x="210" y="348" text-anchor="middle" fill="#222">imm[31:12]</text> <text x="470" y="348" text-anchor="middle" fill="#222">rd</text> <text x="590" y="348" text-anchor="middle" fill="#222">opcode</text> <text x="210" y="372" text-anchor="middle" fill="#555" font-size="10">[31:12] 20b</text> <text x="470" y="372" text-anchor="middle" fill="#555" font-size="10">[11:7]</text> <text x="590" y="372" text-anchor="middle" fill="#555" font-size="10">[6:0]</text>

<!-- J-type -->

<text x="0" y="399" fill="#222" font-weight="bold">J-type</text> <rect x="0" y="405" width="420" height="34" fill="#e8d0ff" stroke="#336" stroke-width="1.2"/> <rect x="420" y="405" width="100" height="34" fill="#ffd6d6" stroke="#336" stroke-width="1.2"/> <rect x="520" y="405" width="140" height="34" fill="#d0e8ff" stroke="#336" stroke-width="1.2"/> <text x="210" y="425" text-anchor="middle" fill="#222">imm[20|10:1|11|19:12]</text> <text x="470" y="425" text-anchor="middle" fill="#222">rd</text> <text x="590" y="425" text-anchor="middle" fill="#222">opcode</text> </svg>

**Key RISC-V encoding decisions:**

- `rs1` is always [19:15], `rs2` always [24:20], `rd` always [11:7] — register file access begins before full decode
- The 7-bit opcode uses the bottom 2 bits as `11` for all 32-bit instructions, reserving other patterns for compressed (16-bit) extensions
- Immediates are deliberately scrambled in B-type and J-type to keep `rd`, `rs1`, `rs2` fixed; hardware reassembles the immediate from its scattered bits
- The immediate sign bit is always bit 31 — a single wire drives sign extension

---

### x86 Variable-Length Encoding

x86-64 instructions range from 1 to 15 bytes. Decoding proceeds left to right through an ordered set of optional prefix fields before reaching the opcode.

<svg viewBox="0 0 760 100" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect x="0" y="20" width="100" height="40" fill="#e0e0e0" stroke="#555" stroke-width="1.2" stroke-dasharray="4,2"/> <rect x="100" y="20" width="80" height="40" fill="#e0e0e0" stroke="#555" stroke-width="1.2" stroke-dasharray="4,2"/> <rect x="180" y="20" width="80" height="40" fill="#e0e0e0" stroke="#555" stroke-width="1.2" stroke-dasharray="4,2"/> <rect x="260" y="20" width="120" height="40" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <rect x="380" y="20" width="60" height="40" fill="#d0ffd6" stroke="#336" stroke-width="1.5" stroke-dasharray="4,2"/> <rect x="440" y="20" width="80" height="40" fill="#fff5cc" stroke="#336" stroke-width="1.5" stroke-dasharray="4,2"/> <rect x="520" y="20" width="80" height="40" fill="#ffd6d6" stroke="#336" stroke-width="1.5" stroke-dasharray="4,2"/> <rect x="600" y="20" width="160" height="40" fill="#ffe8d0" stroke="#336" stroke-width="1.5" stroke-dasharray="4,2"/> <text x="50" y="43" text-anchor="middle" fill="#444">Legacy</text> <text x="50" y="55" text-anchor="middle" fill="#444">Prefixes</text> <text x="140" y="43" text-anchor="middle" fill="#444">REX / VEX</text> <text x="140" y="55" text-anchor="middle" fill="#444">Prefix</text> <text x="220" y="43" text-anchor="middle" fill="#444">Escape</text> <text x="220" y="55" text-anchor="middle" fill="#444">0F / 0F38…</text> <text x="320" y="43" text-anchor="middle" fill="#222">Opcode</text> <text x="320" y="55" text-anchor="middle" fill="#222">1–3 bytes</text> <text x="410" y="43" text-anchor="middle" fill="#444">ModRM</text> <text x="440" y="55" text-anchor="middle" fill="#555" font-size="10">optional</text> <text x="480" y="43" text-anchor="middle" fill="#444">SIB</text> <text x="520" y="55" text-anchor="middle" fill="#555" font-size="10">optional</text> <text x="560" y="43" text-anchor="middle" fill="#444">Disp</text> <text x="600" y="55" text-anchor="middle" fill="#555" font-size="10">0/1/2/4B</text> <text x="680" y="43" text-anchor="middle" fill="#444">Immediate</text> <text x="680" y="55" text-anchor="middle" fill="#555" font-size="10">0/1/2/4/8B</text> <text x="0" y="90" fill="#555" font-size="10">Dashed = optional field</text> </svg>

**ModRM byte** (1 byte, when present):

<svg viewBox="0 0 400 70" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <rect x="0" y="10" width="100" height="34" fill="#d0e8ff" stroke="#336" stroke-width="1.2"/> <rect x="100" y="10" width="150" height="34" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <rect x="250" y="10" width="150" height="34" fill="#ffd6d6" stroke="#336" stroke-width="1.2"/> <text x="50" y="31" text-anchor="middle" fill="#222">mod</text> <text x="175" y="31" text-anchor="middle" fill="#222">reg/opcode</text> <text x="325" y="31" text-anchor="middle" fill="#222">r/m</text> <text x="50" y="55" text-anchor="middle" fill="#555" font-size="11">[7:6] 2b</text> <text x="175" y="55" text-anchor="middle" fill="#555" font-size="11">[5:3] 3b</text> <text x="325" y="55" text-anchor="middle" fill="#555" font-size="11">[2:0] 3b</text> </svg>

- `mod` (2 bits): addressing mode — 00 = indirect, 01 = indirect+disp8, 10 = indirect+disp32, 11 = register direct
- `reg` (3 bits): register operand or opcode extension
- `r/m` (3 bits): register or memory operand (if mod ≠ 11, may trigger SIB)

**SIB byte** (Scale-Index-Base) encodes `[base + index × scale]` addressing:

<svg viewBox="0 0 400 70" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <rect x="0" y="10" width="100" height="34" fill="#e8d0ff" stroke="#336" stroke-width="1.2"/> <rect x="100" y="10" width="150" height="34" fill="#fff5cc" stroke="#336" stroke-width="1.2"/> <rect x="250" y="10" width="150" height="34" fill="#ffd6d6" stroke="#336" stroke-width="1.2"/> <text x="50" y="31" text-anchor="middle" fill="#222">scale</text> <text x="175" y="31" text-anchor="middle" fill="#222">index</text> <text x="325" y="31" text-anchor="middle" fill="#222">base</text> <text x="50" y="55" text-anchor="middle" fill="#555" font-size="11">[7:6] 2b → 1/2/4/8</text> <text x="175" y="55" text-anchor="middle" fill="#555" font-size="11">[5:3] 3b</text> <text x="325" y="55" text-anchor="middle" fill="#555" font-size="11">[2:0] 3b</text> </svg>

**REX prefix** (1 byte, 64-bit mode): extends register fields from 3 to 4 bits, enabling access to R8–R15 and XMM8–XMM15. Format: `0100WRXB` — W sets 64-bit operand size, R extends ModRM.reg, X extends SIB.index, B extends ModRM.r/m or SIB.base.

This layered, historically accumulated structure is why x86 decode is substantially more complex than RISC decode — it requires multi-cycle or heavily parallelized logic in modern implementations.

---

### ARM A32 (32-bit ARM) Format

All A32 instructions are 32 bits. A notable distinguishing feature is the **condition code field** in every instruction — ARM A32 supports predicated execution of every instruction without branching.

<svg viewBox="0 0 760 80" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect x="0" y="15" width="120" height="38" fill="#ffd6d6" stroke="#336" stroke-width="1.2"/> <rect x="120" y="15" width="60" height="38" fill="#d0e8ff" stroke="#336" stroke-width="1.2"/> <rect x="180" y="15" width="40" height="38" fill="#e0e0e0" stroke="#336" stroke-width="1.2"/> <rect x="220" y="15" width="100" height="38" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <rect x="320" y="15" width="100" height="38" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <rect x="420" y="15" width="100" height="38" fill="#ffd6d6" stroke="#336" stroke-width="1.2"/> <rect x="520" y="15" width="240" height="38" fill="#ffeedd" stroke="#336" stroke-width="1.2"/> <text x="60" y="37" text-anchor="middle" fill="#222">cond</text> <text x="150" y="37" text-anchor="middle" fill="#222">optype</text> <text x="200" y="37" text-anchor="middle" fill="#222">S</text> <text x="270" y="37" text-anchor="middle" fill="#222">Rn (base)</text> <text x="370" y="37" text-anchor="middle" fill="#222">Rd (dest)</text> <text x="470" y="37" text-anchor="middle" fill="#222">Rs/shift</text> <text x="640" y="37" text-anchor="middle" fill="#222">Rm / imm</text> <text x="60" y="62" text-anchor="middle" fill="#555" font-size="10">[31:28] 4b</text> <text x="150" y="62" text-anchor="middle" fill="#555" font-size="10">[27:25]</text> <text x="200" y="62" text-anchor="middle" fill="#555" font-size="10">[20]</text> <text x="270" y="62" text-anchor="middle" fill="#555" font-size="10">[19:16]</text> <text x="370" y="62" text-anchor="middle" fill="#555" font-size="10">[15:12]</text> <text x="470" y="62" text-anchor="middle" fill="#555" font-size="10">[11:8]</text> <text x="640" y="62" text-anchor="middle" fill="#555" font-size="10">[7:0] / [11:0]</text> </svg>

The `cond` field encodes 15 conditions (EQ, NE, GT, LT, GE, LE, CS, CC, etc.) plus an unconditional code. Each instruction carries its own predicate — this eliminates short branches at the cost of always fetching and decoding predicated instructions even when they do not execute. AArch64 (ARM64) removes per-instruction predication except for a small set of conditional select and compare instructions.

---

### Opcode Space and Encoding Density

**Opcode space** is the set of all binary patterns in the opcode field. Its size is 2^n for an n-bit opcode field. Not all patterns need to map to valid instructions — reserved encodings allow future ISA extension.

**Encoding density** refers to how efficiently the available opcode space is used. RISC-V's 7-bit opcode field (128 patterns) is sparse by design: many patterns are reserved, and the spec explicitly partitions the opcode space into encoding groups (LOAD, STORE, BRANCH, OP, OP-IMM, LUI, AUIPC, JAL, JALR, SYSTEM, etc.) with future space preserved.

**Huffman-style encoding:** A theoretically optimal encoding assigns shorter bit patterns to more frequent instructions. Variable-length ISAs (x86) approximate this — common instructions (`mov`, `push`, `call`) have 1-byte opcodes; rare instructions use escape prefixes and multi-byte opcodes.

---

### Immediate Encoding and Sign Extension

Immediates embedded in fixed-width instructions are narrow by necessity. Their extension to the full datapath width follows a defined rule:

**Sign extension:** replicate the most significant bit of the immediate field to fill the upper bits. A 12-bit two's complement immediate sign-extended to 32 bits:

```
imm[11] → imm[31:12]    (20 copies of bit 11)
imm[11:0] → imm[11:0]   (unchanged)
```

**Zero extension:** fill upper bits with 0. Used for logical operations where the immediate represents a bitmask, not a signed offset.

The choice of sign vs. zero extension is encoded in the opcode/funct3 field — `ADDI` sign-extends, `ANDI`/`ORI`/`XORI` in RISC-V also sign-extend (a deliberate uniformity decision), while `SLTIU` sign-extends the immediate before treating it as unsigned for comparison.

---

### Encoding Trade-offs: Immediate Width vs. Register Count

Given a fixed instruction width (e.g., 32 bits) and a fixed opcode overhead, the remaining bits must be partitioned between register specifiers and immediate fields. This is a zero-sum constraint:

```
available_bits = total_width − opcode_bits − control_bits
available_bits = (reg_count_bits × num_regs) + immediate_bits
```

- RISC-V RV32I: 5-bit register fields (32 regs) → 12-bit I-type immediate
- MIPS: 5-bit register fields (32 regs) → 16-bit I-type immediate (fewer format variants)
- AArch64: 5-bit register fields (32 regs) + varied immediate schemes per instruction class

Increasing register count from 32 to 64 costs 1 additional bit per register specifier — in a 3-register R-type instruction, that is 3 bits taken from elsewhere.

---

### Instruction Length Encoding in Variable-Length ISAs

For variable-length ISAs, the decoder must determine instruction length before extracting fields. Common techniques:

**Leading opcode byte:** The primary opcode byte (or first few bits) encodes length implicitly. In x86, certain opcode values imply 1-byte instructions; others imply that ModRM and/or additional bytes follow.

**Prefix detection:** x86 decode must scan left to right, identifying each byte as a prefix, escape byte, or opcode. This is inherently serial.

**RISC-V Compressed (RVC):** Instructions with bits [1:0] ≠ `11` are 16-bit compressed instructions; bits [1:0] = `11` and bits [4:2] ≠ `111` are 32-bit; further patterns extend to 48/64-bit. The bottom 2 bits thus encode length without full decode.

<svg viewBox="0 0 600 130" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <text x="0" y="16" fill="#222" font-weight="bold">RISC-V Instruction Length Encoding (bits [4:0])</text> <rect x="0" y="24" width="80" height="28" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <text x="40" y="42" text-anchor="middle" fill="#222">xxxxxxaa</text> <text x="90" y="42" fill="#555">aa ≠ 11 → 16-bit (RVC)</text> <rect x="0" y="58" width="80" height="28" fill="#d0e8ff" stroke="#336" stroke-width="1.2"/> <text x="40" y="76" text-anchor="middle" fill="#222">xxxbbb11</text> <text x="90" y="76" fill="#555">bbb ≠ 111 → 32-bit</text> <rect x="0" y="92" width="80" height="28" fill="#ffeedd" stroke="#336" stroke-width="1.2"/> <text x="40" y="110" text-anchor="middle" fill="#222">xx011111</text> <text x="90" y="110" fill="#555">→ 48-bit</text> <rect x="200" y="92" width="80" height="28" fill="#ffd6d6" stroke="#336" stroke-width="1.2"/> <text x="240" y="110" text-anchor="middle" fill="#222">x0111111</text> <text x="290" y="110" fill="#555">→ 64-bit</text> </svg>

---

### Encoding Example: RISC-V `addi x1, x2, -5`

Instruction: add immediate −5 to register x2, write result to x1.

- Format: I-type
- `opcode` = `0010011` (OP-IMM)
- `funct3` = `000` (ADDI)
- `rd` = x1 = `00001`
- `rs1` = x2 = `00010`
- `imm[11:0]` = −5 in 12-bit two's complement = `111111111011`

```
[31:20]       [19:15] [14:12] [11:7] [6:0]
111111111011  00010   000     00001  0010011
```

Full 32-bit encoding: `0xFFF10093`

Verification:

- Sign extension of `111111111011` → `0xFFFFFFFB` = −5 ✓
- `rd` = 1, `rs1` = 2 ✓
- opcode = `0x13` = `0010011` ✓

---

**Key Points**

- Instruction format design is a direct constraint on ISA capability: opcode width, register count, and immediate range are coupled — improving one costs another.
- Fixed-length encoding (RISC-V, MIPS, ARM A32) enables simple, parallel decode and regular pipeline stages; variable-length encoding (x86) achieves higher code density at significant decode complexity cost.
- RISC-V deliberately fixes `rs1`, `rs2`, and `rd` at identical bit positions across all formats so that register file reads can begin before full opcode decode — a hardware latency optimization embedded in the ISA definition.
- The `mod`/`reg`/`r/m` structure in x86 and the `cond` field in ARM A32 are ISA-level features with direct microarchitectural consequences — x86 decode requires multiple sequential stages; ARM A32 predication requires fetching and decoding instructions that may be squashed.
- Immediate sign extension is not a runtime decision — it is determined by the instruction type and encoded in opcode/funct fields, making it a decode-time operation.

**Next Steps**

Proceed to **Addressing Modes**, which specify how operand addresses are computed from instruction fields — the immediate, register, and displacement fields introduced here are the raw inputs to addressing mode logic. Follow with **Assembly Language Basics** to see how these binary encodings map to human-readable mnemonics and directives.

---

