## Addressing Modes


Addressing modes define how an instruction identifies the location of its operands — whether in a register, embedded in the instruction itself, in memory, or computed at runtime. They sit at the intersection of ISA design and hardware implementation, directly affecting instruction encoding width, memory traffic, and pipeline complexity.

---

### Role in Instruction Encoding

Every instruction has at minimum an opcode. The remaining bits specify operands. An addressing mode determines how those bits are interpreted to resolve an **effective address (EA)** or an immediate value.

<svg viewBox="0 0 580 80" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect x="10" y="20" width="100" height="40" rx="4" fill="none" stroke="#ccc" stroke-width="1.5"/> <text x="60" y="45" text-anchor="middle" fill="#ccc">Opcode</text> <rect x="115" y="20" width="110" height="40" rx="4" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="170" y="38" text-anchor="middle" fill="#7af">Mode</text> <text x="170" y="54" text-anchor="middle" fill="#aaa" font-size="10">specifier</text> <rect x="230" y="20" width="160" height="40" rx="4" fill="none" stroke="#aaa" stroke-width="1.5"/> <text x="310" y="38" text-anchor="middle" fill="#ccc">Operand field</text> <text x="310" y="54" text-anchor="middle" fill="#aaa" font-size="10">reg / imm / offset / address</text> <rect x="395" y="20" width="170" height="40" rx="4" fill="none" stroke="#aaa" stroke-width="1.5"/> <text x="480" y="38" text-anchor="middle" fill="#ccc">Second operand</text> <text x="480" y="54" text-anchor="middle" fill="#aaa" font-size="10">(if 3-address ISA)</text> </svg>

In RISC architectures the mode is often implicit in the opcode itself. In CISC (e.g., x86) a ModRM byte explicitly encodes the mode.

---

### Taxonomy of Addressing Modes

---

#### 1. Immediate Addressing

The operand value is **encoded directly in the instruction**.

$$EA = \text{none} \quad;\quad \text{Operand} = \text{imm}$$

```
MOV R0, #42        ; R0 ← 42
ADDI R1, R1, 5     ; R1 ← R1 + 5
```

- No memory access required for the operand
- Operand range limited by bit-width of immediate field
- Used for constants, loop bounds, small offsets

<svg viewBox="0 0 420 90" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect x="10" y="25" width="90" height="36" rx="3" fill="none" stroke="#ccc" stroke-width="1.5"/> <text x="55" y="48" text-anchor="middle" fill="#ccc">Opcode</text> <rect x="105" y="25" width="90" height="36" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="150" y="44" text-anchor="middle" fill="#7af">42</text> <text x="150" y="58" text-anchor="middle" fill="#aaa" font-size="10">immediate</text> <line x1="200" y1="43" x2="280" y2="43" stroke="#7af" stroke-width="1.5" marker-end="url(#a)"/> <rect x="285" y="25" width="90" height="36" rx="3" fill="none" stroke="#aaa" stroke-width="1.5"/> <text x="330" y="48" text-anchor="middle" fill="#ccc">R0 = 42</text> <defs> <marker id="a" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#7af"/> </marker> </defs> </svg>

---

#### 2. Register Addressing

The operand is held in a **named register**. No memory access.

$$EA = \text{none} \quad;\quad \text{Operand} = R_n$$

```
ADD R0, R1, R2     ; R0 ← R1 + R2
MOV R3, R4         ; R3 ← R4
```

- Fastest access — registers are on-chip, single-cycle read
- Operand field encodes only a register number (e.g., 5 bits for 32 registers)
- Dominant mode in RISC load-store architectures

---

#### 3. Direct (Absolute) Addressing

The instruction contains the **full memory address** of the operand.

$$EA = \text{addr field}$$

```
LOAD R0, 0x1000    ; R0 ← MEM[0x1000]
```

- One memory access for the operand
- Address field must be wide enough for the full address space — costly in encoding
- Rare in modern RISC; present in some CISC and microcontroller ISAs

<svg viewBox="0 0 480 110" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect x="10" y="15" width="80" height="36" rx="3" fill="none" stroke="#ccc" stroke-width="1.5"/> <text x="50" y="38" text-anchor="middle" fill="#ccc">Opcode</text> <rect x="95" y="15" width="110" height="36" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="150" y="34" text-anchor="middle" fill="#7af">0x1000</text> <text x="150" y="48" text-anchor="middle" fill="#aaa" font-size="10">address field</text> <line x1="150" y1="51" x2="150" y2="70" stroke="#7af" stroke-width="1.5" marker-end="url(#a2)"/> <rect x="100" y="74" width="100" height="28" rx="3" fill="none" stroke="#aaa" stroke-width="1.5"/> <text x="150" y="93" text-anchor="middle" fill="#ccc">MEM[0x1000]</text> <line x1="200" y1="88" x2="310" y2="88" stroke="#aaa" stroke-width="1.5" marker-end="url(#a2)"/> <rect x="315" y="74" width="70" height="28" rx="3" fill="none" stroke="#aaa" stroke-width="1.5"/> <text x="350" y="93" text-anchor="middle" fill="#ccc">R0</text> <defs> <marker id="a2" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#aaa"/> </marker> </defs> </svg>

---

#### 4. Register Indirect Addressing

The register holds the **memory address** of the operand.

$$EA = R_n$$

```
LOAD R0, [R1]      ; R0 ← MEM[R1]
```

- One memory access
- The register acts as a pointer — flexible, supports runtime-computed addresses
- Core mode for pointer dereferencing in compiled languages

---

#### 5. Base + Offset (Displacement) Addressing

The effective address is computed as a **base register plus a signed constant offset**.

$$EA = R_{base} + \text{offset}$$

```
LOAD R0, 8(R1)     ; R0 ← MEM[R1 + 8]   ; MIPS syntax
LDR  R0, [R1, #8]  ; ARM syntax
MOV  R0, [RBX+8]   ; x86 syntax
```

- One memory access
- Dominant mode in RISC (MIPS, ARM, RISC-V all use this as the primary memory access mode)
- Naturally expresses struct field access: base = pointer to struct, offset = field offset
- Also expresses stack-relative access: base = SP or FP, offset = local variable position

<svg viewBox="0 0 540 120" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Instruction --> <rect x="10" y="10" width="70" height="32" rx="3" fill="none" stroke="#ccc" stroke-width="1.5"/> <text x="45" y="31" text-anchor="middle" fill="#ccc">Opcode</text> <rect x="85" y="10" width="55" height="32" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="112" y="31" text-anchor="middle" fill="#7af">R1</text> <rect x="145" y="10" width="60" height="32" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="175" y="31" text-anchor="middle" fill="#7af">+8</text> <!-- Register file --> <rect x="90" y="65" width="90" height="30" rx="3" fill="none" stroke="#aaa" stroke-width="1.5"/> <text x="135" y="85" text-anchor="middle" fill="#ccc">R1 = 0x200</text> <line x1="112" y1="42" x2="112" y2="65" stroke="#7af" stroke-width="1.2" stroke-dasharray="4,3"/> <!-- Adder --> <rect x="240" y="58" width="70" height="32" rx="3" fill="none" stroke="#aaa" stroke-width="1.5"/> <text x="275" y="79" text-anchor="middle" fill="#ccc">0x200+8</text> <line x1="180" y1="80" x2="240" y2="74" stroke="#aaa" stroke-width="1.2" marker-end="url(#a3)"/> <line x1="175" y1="26" x2="260" y2="58" stroke="#7af" stroke-width="1.2" stroke-dasharray="4,3"/> <!-- Memory --> <rect x="360" y="58" width="120" height="32" rx="3" fill="none" stroke="#aaa" stroke-width="1.5"/> <text x="420" y="79" text-anchor="middle" fill="#ccc">MEM[0x208]</text> <line x1="310" y1="74" x2="360" y2="74" stroke="#aaa" stroke-width="1.5" marker-end="url(#a3)"/> <defs> <marker id="a3" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#aaa"/> </marker> </defs> </svg>

---

#### 6. Base + Index Addressing

The effective address is the sum of **two registers**.

$$EA = R_{base} + R_{index}$$

```
LOAD R0, [R1 + R2]     ; EA = R1 + R2
```

- Common for array access where both base and index are variable
- x86 extends this to: $EA = R_{base} + R_{index} \times \text{scale} + \text{disp}$

---

#### 7. Indexed Addressing (Base + Index × Scale + Displacement)

x86-64's full memory addressing model:

$$EA = R_{base} + R_{index} \times S + \text{disp}$$

where $S \in {1, 2, 4, 8}$ (matches byte widths of common data types).

```nasm
MOV EAX, [RBX + RCX*4 + 16]
; EA = RBX + RCX×4 + 16
; Accesses the RCX-th int32 in an array starting at RBX+16
```

This single mode subsumes array indexing, struct-within-array access, and pointer arithmetic in one instruction — a hallmark of CISC expressiveness.

---

#### 8. PC-Relative Addressing

The effective address is computed relative to the **program counter**.

$$EA = PC + \text{offset}$$

```
BEQ R0, R1, +12    ; branch to PC+12 if R0 == R1
LDR R0, [PC, #20]  ; load from address PC+20 (ARM literal pool)
```

- Essential for **position-independent code (PIC)** — the binary works regardless of load address
- Used for branches, jumps, and literal pool loads in ARM
- Offset is sign-extended and added to the PC value (typically PC of the next instruction)

---

#### 9. Stack Addressing (Implicit)

Some instructions implicitly use the **stack pointer (SP)** as base.

$$EA = SP \quad;\quad SP \leftarrow SP \pm \text{word size}$$

```
PUSH R0    ; MEM[SP] ← R0;  SP ← SP - 4
POP  R1    ; R1 ← MEM[SP];  SP ← SP + 4
```

- SP update and memory access are atomic in a single instruction
- No explicit address field needed — the mode is baked into the opcode
- Used heavily in CISC (x86 `CALL`/`RET`, `PUSH`/`POP`); RISC architectures usually simulate this with explicit base+offset stores

---

#### 10. Indirect Addressing

The instruction specifies an address (or register) that holds the **address of the address** of the operand.

$$EA = MEM[R_n] \quad \text{or} \quad EA = MEM[\text{addr field}]$$

```
LOAD R0, [[R1]]    ; EA = MEM[R1]; Operand = MEM[EA]
```

- Two memory accesses
- Common in older architectures and virtual machine designs
- Supports pointer-to-pointer and handle-based indirection
- Absent from most modern RISC ISAs as a single instruction mode; achieved by sequencing two instructions

---

#### 11. Auto-Increment / Auto-Decrement Addressing

Register indirect with the register **automatically updated** after (post) or before (pre) the access.

$$\text{Post-increment:} \quad EA = R_n;\quad R_n \leftarrow R_n + \text{size}$$ $$\text{Pre-decrement:} \quad R_n \leftarrow R_n - \text{size};\quad EA = R_n$$

```
LOAD R0, (R1)+     ; R0 ← MEM[R1]; R1 ← R1 + 4   (post-increment)
LOAD R0, -(R1)     ; R1 ← R1 - 4; R0 ← MEM[R1]   (pre-decrement)
```

- PDP-11 and VAX used these extensively; ARM supports post-index and pre-index variants
- Efficient for array traversal, stack operations, and `memcpy`-style loops
- Creates a hazard: the register is both an input operand and modified — pipelining must detect and stall or forward

ARM syntax:

```
LDR R0, [R1], #4    ; post-index: EA = R1, then R1 += 4
LDR R0, [R1, #4]!   ; pre-index:  R1 += 4, then EA = R1
```

---

### Summary Table

|Mode|EA Formula|Memory Accesses|Key Use|
|---|---|---|---|
|Immediate|— (value is imm)|0|Constants|
|Register|— (value is Rn)|0|General computation|
|Direct|addr field|1|Fixed locations|
|Register Indirect|Rn|1|Pointer dereference|
|Base + Offset|Rn + disp|1|Struct fields, stack locals|
|Base + Index|Rn + Rm|1|Variable array index|
|Scaled Index + Disp|Rb + Ri×S + d|1|Typed array access (x86)|
|PC-Relative|PC + offset|0 or 1|Branches, PIC|
|Stack (implicit)|SP ± size|1|Call/return, push/pop|
|Indirect|MEM[Rn]|2|Pointer-to-pointer|
|Auto-increment|Rn (then Rn += k)|1|Array traversal, copying|

---

### Addressing Modes Across ISAs

|ISA|Memory Access Mode|Notes|
|---|---|---|
|MIPS|Base + 16-bit signed offset only|Strictly one memory mode|
|RISC-V|Base + 12-bit signed offset only|Follows same load-store discipline|
|ARM (A32)|Base ± offset/reg/shifted-reg, pre/post-index|Rich set; shifted register is distinctive|
|x86-64|Base + Index×Scale + Disp32|Full scaled indexed; single instruction|
|AVR (8-bit)|Register indirect, Z+offset, auto-inc/dec|Targets minimal hardware|

---

### Hardware Cost of Each Mode

Addressing mode complexity maps directly to datapath requirements:

<svg viewBox="0 0 560 230" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- Y axis --> <line x1="80" y1="20" x2="80" y2="190" stroke="#ccc" stroke-width="1.2"/> <text x="20" y="110" fill="#aaa" font-size="10" transform="rotate(-90,20,110)">HW Cost</text> <!-- X axis --> <line x1="80" y1="190" x2="540" y2="190" stroke="#ccc" stroke-width="1.2"/> <!-- Bars --> <!-- Immediate --> <rect x="90" y="175" width="36" height="15" fill="#7af" opacity="0.7"/> <text x="108" y="205" text-anchor="middle" fill="#aaa" font-size="9">Imm</text> <!-- Register --> <rect x="138" y="170" width="36" height="20" fill="#7af" opacity="0.7"/> <text x="156" y="205" text-anchor="middle" fill="#aaa" font-size="9">Reg</text> <!-- Reg Indirect --> <rect x="186" y="145" width="36" height="45" fill="#5cf" opacity="0.7"/> <text x="204" y="205" text-anchor="middle" fill="#aaa" font-size="9">R-Ind</text> <!-- Base+Offset --> <rect x="234" y="125" width="36" height="65" fill="#5cf" opacity="0.7"/> <text x="252" y="205" text-anchor="middle" fill="#aaa" font-size="9">B+Off</text> <!-- PC-Rel --> <rect x="282" y="120" width="36" height="70" fill="#5cf" opacity="0.7"/> <text x="300" y="205" text-anchor="middle" fill="#aaa" font-size="9">PC-Rel</text> <!-- Auto-inc --> <rect x="330" y="100" width="36" height="90" fill="#fa7" opacity="0.7"/> <text x="348" y="205" text-anchor="middle" fill="#aaa" font-size="9">AutoInc</text> <!-- Base+Idx --> <rect x="378" y="85" width="36" height="105" fill="#fa7" opacity="0.7"/> <text x="396" y="205" text-anchor="middle" fill="#aaa" font-size="9">B+Idx</text> <!-- Indirect --> <rect x="426" y="65" width="36" height="125" fill="#f77" opacity="0.7"/> <text x="444" y="205" text-anchor="middle" fill="#aaa" font-size="9">Indirect</text> <!-- x86 Scaled --> <rect x="474" y="35" width="36" height="155" fill="#f55" opacity="0.7"/> <text x="492" y="205" text-anchor="middle" fill="#aaa" font-size="9">x86 SIB</text> <!-- Legend --> <rect x="85" y="215" width="10" height="8" fill="#7af" opacity="0.7"/> <text x="100" y="223" fill="#aaa" font-size="9">Trivial</text> <rect x="145" y="215" width="10" height="8" fill="#fa7" opacity="0.7"/> <text x="160" y="223" fill="#aaa" font-size="9">Moderate</text> <rect x="225" y="215" width="10" height="8" fill="#f55" opacity="0.7"/> <text x="240" y="223" fill="#aaa" font-size="9">Complex</text> </svg>

- **Immediate / Register**: No adder, no memory port for operand — purely from instruction decode
- **Base + Offset**: Requires an adder in the address generation unit (AGU)
- **Auto-increment**: Requires write-back path to the register file in addition to AGU
- **x86 SIB**: Requires a multiplier (shift), two additions, and a wide displacement — multi-cycle AGU in some microarchitectures

---

### Effective Address Computation in the Pipeline

In a pipelined processor, EA computation occurs in the **Execute** or **Address Generation** stage:

<svg viewBox="0 0 580 70" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect x="10" y="15" width="90" height="36" rx="3" fill="none" stroke="#aaa" stroke-width="1.5"/> <text x="55" y="38" text-anchor="middle" fill="#ccc">IF</text> <rect x="115" y="15" width="90" height="36" rx="3" fill="none" stroke="#aaa" stroke-width="1.5"/> <text x="160" y="38" text-anchor="middle" fill="#ccc">ID/Decode</text> <rect x="220" y="15" width="110" height="36" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="275" y="33" text-anchor="middle" fill="#7af">EX / AGU</text> <text x="275" y="46" text-anchor="middle" fill="#aaa" font-size="9">EA = Rb+Ri×S+d</text> <rect x="345" y="15" width="90" height="36" rx="3" fill="none" stroke="#aaa" stroke-width="1.5"/> <text x="390" y="38" text-anchor="middle" fill="#ccc">MEM</text> <rect x="450" y="15" width="90" height="36" rx="3" fill="none" stroke="#aaa" stroke-width="1.5"/> <text x="495" y="38" text-anchor="middle" fill="#ccc">WB</text> <line x1="100" y1="33" x2="115" y2="33" stroke="#aaa" stroke-width="1.2" marker-end="url(#ap)"/> <line x1="205" y1="33" x2="220" y2="33" stroke="#aaa" stroke-width="1.2" marker-end="url(#ap)"/> <line x1="330" y1="33" x2="345" y2="33" stroke="#aaa" stroke-width="1.2" marker-end="url(#ap)"/> <line x1="435" y1="33" x2="450" y2="33" stroke="#aaa" stroke-width="1.2" marker-end="url(#ap)"/> <defs> <marker id="ap" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#aaa"/> </marker> </defs> </svg>

Complex addressing modes (x86 SIB) may require a dedicated AGU separate from the ALU, or multiple pipeline cycles, to resolve the effective address before the MEM stage proceeds.

---

### Addressing Modes and Code Density

Richer addressing modes allow more work per instruction, reducing instruction count (and therefore code size), at the cost of instruction complexity.

|Scenario|RISC (base+offset only)|CISC (scaled index)|
|---|---|---|
|Access `A[i]` (int array)|`SLLI R2,Ri,2` then `ADD R3,Ra,R2` then `LOAD R0,[R3]` — 3 instructions|`MOV EAX, [Ra + Ri*4]` — 1 instruction|
|Overhead|More instructions, larger I-cache footprint|Single instruction, complex decode|

RISC's position: the compiler handles the address arithmetic; hardware stays simple and fast. CISC's position: the hardware absorbs the complexity, reducing decode-fetch overhead.

---

### **Key Points**

- Addressing modes define the mapping from instruction fields to operand locations — they are the bridge between ISA and hardware memory access.
- Register and immediate modes require no memory access and dominate the hot path in RISC execution.
- Base + offset is the universal RISC memory access mode — it subsumes stack, struct, and array access given compiler cooperation.
- PC-relative addressing is mandatory for position-independent code and branch encoding.
- Indirect addressing incurs two memory accesses and is absent as a single-instruction mode in modern RISC ISAs.
- Auto-increment/decrement modes require write-back to the register file — a structural dependency that pipelines must handle.
- x86's scaled-index-base-displacement mode is maximally expressive but requires dedicated AGU hardware and complicates decode.
- RISC ISAs deliberately restrict addressing mode variety to simplify hardware; CISC ISAs maximize mode variety to reduce instruction count.

---

### **Example**

Accessing element `A[i]` where `A` is an `int32` array (4 bytes per element), base address in `R1`, index in `R2`:

**RISC-V (base + offset only):**

```asm
slli  t0, x2, 2        # t0 = i * 4
add   t1, x1, t0       # t1 = &A[i]
lw    x3, 0(t1)        # x3 = A[i]
```

Three instructions; address computation is explicit and visible to the scheduler.

**x86-64 (scaled index):**

```nasm
mov   eax, [rbx + rcx*4]   ; eax = A[i] directly
```

One instruction; the AGU computes `RBX + RCX×4` internally in the Execute stage.

Both achieve the same memory access; the difference is whether the address arithmetic is amortized into explicit instructions (RISC) or absorbed into a single complex instruction (CISC).

---

### **Conclusion**

Addressing modes constitute a core design axis of any ISA, trading hardware complexity against instruction density and programmer expressiveness. RISC architectures converge on a minimal set — register, immediate, and base+offset — keeping the hardware fast and the pipeline simple. CISC architectures expose richer modes that compress code and reduce loop overhead, at the cost of more complex decode and execution logic. Understanding the effective address computation for each mode, its memory access count, and its hardware implications is prerequisite to analyzing both ISA design decisions and microarchitectural implementation choices.

---

### **Next Steps**

- **Instruction Formats and Encoding** — how addressing mode bits are packed alongside opcode and register fields within fixed or variable-length encodings
- **ALU Design** — the address generation unit is an ALU specialization; understanding ALU structure clarifies how EA computation is implemented
- **Single-Cycle Datapath Design** — trace how each addressing mode is resolved across the datapath stages from fetch through memory access

---

