## Single-Cycle Datapath Design


A single-cycle datapath executes every instruction in exactly one clock cycle. The clock period must be long enough to accommodate the slowest possible instruction — the critical path. All combinational logic settles within one cycle; no state is carried between stages mid-instruction.

---

### Design Premises

```
1. One instruction completes per clock cycle
2. State elements (PC, register file, memory) are read/written once per cycle
3. No instruction reuses a functional unit within the same cycle
4. Separate instruction memory and data memory (Harvard-style for simplicity)
5. The clock period = worst-case propagation delay across all instruction types
```

---

### Canonical Instruction Subset (MIPS-like RV32I)

The datapath is designed around three fundamental instruction classes:

|Class|Example|Operations Required|
|---|---|---|
|R-type (register)|`add rd, rs1, rs2`|Fetch, decode, register read, ALU, register write|
|I-type (immediate load)|`lw rd, imm(rs1)`|Fetch, decode, register read, ALU (addr), memory read, register write|
|S-type (store)|`sw rs2, imm(rs1)`|Fetch, decode, register read, ALU (addr), memory write|
|B-type (branch)|`beq rs1, rs2, offset`|Fetch, decode, register read, ALU (compare), PC update|

The datapath must satisfy all four classes simultaneously using multiplexers to route data appropriately.

---

### The Five Functional Stages

Although execution is not pipelined, the logical stages remain a useful decomposition:

<svg viewBox="0 0 720 130" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect width="720" height="130" fill="#0d1117" rx="8"/> <!-- Stage boxes --> <rect x="10" y="35" width="110" height="60" rx="6" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.5"/> <text x="65" y="61" text-anchor="middle" fill="#58a6ff" font-size="11" font-weight="bold">IF</text> <text x="65" y="76" text-anchor="middle" fill="#8b949e" font-size="10">Instruction</text> <text x="65" y="89" text-anchor="middle" fill="#8b949e" font-size="10">Fetch</text> <rect x="148" y="35" width="110" height="60" rx="6" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.5"/> <text x="203" y="61" text-anchor="middle" fill="#58a6ff" font-size="11" font-weight="bold">ID</text> <text x="203" y="76" text-anchor="middle" fill="#8b949e" font-size="10">Instruction</text> <text x="203" y="89" text-anchor="middle" fill="#8b949e" font-size="10">Decode</text> <rect x="286" y="35" width="110" height="60" rx="6" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.5"/> <text x="341" y="61" text-anchor="middle" fill="#58a6ff" font-size="11" font-weight="bold">EX</text> <text x="341" y="76" text-anchor="middle" fill="#8b949e" font-size="10">Execute /</text> <text x="341" y="89" text-anchor="middle" fill="#8b949e" font-size="10">ALU</text> <rect x="424" y="35" width="110" height="60" rx="6" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.5"/> <text x="479" y="61" text-anchor="middle" fill="#58a6ff" font-size="11" font-weight="bold">MEM</text> <text x="479" y="76" text-anchor="middle" fill="#8b949e" font-size="10">Memory</text> <text x="479" y="89" text-anchor="middle" fill="#8b949e" font-size="10">Access</text> <rect x="562" y="35" width="110" height="60" rx="6" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.5"/> <text x="617" y="61" text-anchor="middle" fill="#58a6ff" font-size="11" font-weight="bold">WB</text> <text x="617" y="76" text-anchor="middle" fill="#8b949e" font-size="10">Write</text> <text x="617" y="89" text-anchor="middle" fill="#8b949e" font-size="10">Back</text> <!-- Arrows --> <line x1="120" y1="65" x2="146" y2="65" stroke="#4a9eff" stroke-width="1.5" marker-end="url(#a)"/> <line x1="258" y1="65" x2="284" y2="65" stroke="#4a9eff" stroke-width="1.5" marker-end="url(#a)"/> <line x1="396" y1="65" x2="422" y2="65" stroke="#4a9eff" stroke-width="1.5" marker-end="url(#a)"/> <line x1="534" y1="65" x2="560" y2="65" stroke="#4a9eff" stroke-width="1.5" marker-end="url(#a)"/> <!-- Single cycle bracket --> <line x1="10" y1="115" x2="672" y2="115" stroke="#3fb950" stroke-width="1.2"/> <line x1="10" y1="108" x2="10" y2="122" stroke="#3fb950" stroke-width="1.2"/> <line x1="672" y1="108" x2="672" y2="122" stroke="#3fb950" stroke-width="1.2"/> <text x="341" y="128" text-anchor="middle" fill="#3fb950" font-size="10">All stages complete within one clock cycle — no interstage registers</text> <defs> <marker id="a" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#4a9eff"/> </marker> </defs> </svg>

---

### Core Datapath Components

#### 1. Program Counter (PC)

A 32-bit register holding the address of the current instruction.

```
On every clock edge:
    PC ← PC + 4          (sequential execution)
    PC ← branch target   (taken branch)
```

The PC is the only register updated on every cycle regardless of instruction type.

#### 2. Instruction Memory

Read-only in a single-cycle design. Addressed by the PC, outputs the 32-bit instruction word combinationally.

```
Instruction [31:0] = InstrMem[PC]
```

#### 3. Register File

Contains 32 general-purpose registers (x0–x31 in RISC-V; x0 hardwired to 0).

```
Ports:
    Read port 1:   addr = rs1  → data = RD1
    Read port 2:   addr = rs2  → data = RD2
    Write port:    addr = rd,  data = WD, enable = RegWrite
```

Reads are combinational (asynchronous). The write occurs on the clock edge at the end of the cycle.

#### 4. Immediate Generator (Sign-Extender)

Extracts and sign-extends the immediate field from the instruction encoding. Output varies by instruction format:

|Format|Immediate bits in instruction|Extended to|
|---|---|---|
|I-type|[31:20]|32-bit sign-extended|
|S-type|[31:25] + [11:7]|32-bit sign-extended|
|B-type|[31],[7],[30:25],[11:8],0|32-bit sign-extended|
|U-type|[31:12]|32-bit (lower 12 bits = 0)|
|J-type|[31],[19:12],[20],[30:21],0|32-bit sign-extended|

#### 5. ALU

Performs arithmetic and logical operations. Takes two 32-bit operands, outputs a 32-bit result and a Zero flag.

```
Inputs:   A (from RD1),  B (RD2 or sign-extended immediate)
Output:   Result, Zero
Control:  ALUOp [3:0] — selects operation

Operations: ADD, SUB, AND, OR, XOR, SLT, SLL, SRL, SRA
```

The Zero flag is used specifically by branch instructions to determine whether a branch is taken.

#### 6. Data Memory

Separate from instruction memory. Supports both read and write:

```
Read:  MemRead=1  → RD = DataMem[ALUResult]
Write: MemWrite=1 → DataMem[ALUResult] = RD2
```

Only `lw` asserts MemRead. Only `sw` asserts MemWrite. For all other instructions, neither signal is asserted.

---

### Multiplexers and Data Routing

Multiplexers are the decision points in the datapath. The control unit drives their select signals.

|Mux|Select Signal|Input 0|Input 1|Purpose|
|---|---|---|---|---|
|ALUSrc|ALUSrc|RD2 (register)|Imm (immediate)|ALU second operand|
|MemToReg|MemToReg|ALUResult|MemReadData|Write-back source|
|PCSrc|PCSrc (= Branch AND Zero)|PC+4|Branch target|Next PC|

---

### Full Datapath — Signal Flow

<svg viewBox="0 0 760 460" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="760" height="460" fill="#0d1117" rx="8"/> <!-- ── PC ── --> <rect x="20" y="180" width="54" height="40" rx="5" fill="#1a2332" stroke="#58a6ff" stroke-width="1.5"/> <text x="47" y="204" text-anchor="middle" fill="#58a6ff" font-size="11" font-weight="bold">PC</text> <!-- ── Instr Mem ── --> <rect x="100" y="155" width="80" height="70" rx="5" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.5"/> <text x="140" y="185" text-anchor="middle" fill="#8b949e" font-size="10">Instr</text> <text x="140" y="199" text-anchor="middle" fill="#8b949e" font-size="10">Mem</text> <text x="140" y="213" text-anchor="middle" fill="#58a6ff" font-size="9">[PC]→IR</text> <!-- PC → InstrMem --> <line x1="74" y1="200" x2="99" y2="200" stroke="#4a9eff" stroke-width="1.2" marker-end="url(#arr)"/> <text x="76" y="195" fill="#8b949e" font-size="9">addr</text> <!-- ── Reg File ── --> <rect x="220" y="130" width="90" height="120" rx="5" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.5"/> <text x="265" y="155" text-anchor="middle" fill="#8b949e" font-size="10">Register</text> <text x="265" y="168" text-anchor="middle" fill="#8b949e" font-size="10">File</text> <text x="225" y="192" fill="#6e7681" font-size="9">rs1→</text> <text x="225" y="208" fill="#6e7681" font-size="9">rs2→</text> <text x="225" y="224" fill="#6e7681" font-size="9">rd →</text> <text x="265" y="192" fill="#3fb950" font-size="9">RD1</text> <text x="265" y="208" fill="#3fb950" font-size="9">RD2</text> <!-- InstrMem → RegFile (rs1, rs2, rd) --> <line x1="180" y1="185" x2="218" y2="185" stroke="#4a9eff" stroke-width="1.0" marker-end="url(#arr)"/> <line x1="180" y1="200" x2="218" y2="200" stroke="#4a9eff" stroke-width="1.0" marker-end="url(#arr)"/> <line x1="180" y1="215" x2="218" y2="215" stroke="#4a9eff" stroke-width="1.0" marker-end="url(#arr)"/> <!-- ── Imm Gen ── --> <rect x="220" y="290" width="90" height="45" rx="5" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.5"/> <text x="265" y="310" text-anchor="middle" fill="#8b949e" font-size="10">Imm</text> <text x="265" y="323" text-anchor="middle" fill="#8b949e" font-size="10">Generator</text> <!-- InstrMem → ImmGen --> <line x1="180" y1="230" x2="210" y2="230" stroke="#4a9eff" stroke-width="1.0"/> <line x1="210" y1="230" x2="210" y2="312" stroke="#4a9eff" stroke-width="1.0"/> <line x1="210" y1="312" x2="218" y2="312" stroke="#4a9eff" stroke-width="1.0" marker-end="url(#arr)"/> <!-- ── ALUSrc Mux ── --> <polygon points="370,175 370,265 388,255 388,185" fill="#1e2d3d" stroke="#e6c07b" stroke-width="1.5"/> <text x="374" y="218" fill="#e6c07b" font-size="9">M</text> <text x="374" y="229" fill="#e6c07b" font-size="9">U</text> <text x="374" y="240" fill="#e6c07b" font-size="9">X</text> <!-- RD2 → MUX top --> <line x1="310" y1="195" x2="369" y2="200" stroke="#3fb950" stroke-width="1.0" marker-end="url(#arr)"/> <!-- Imm → MUX bottom --> <line x1="310" y1="312" x2="350" y2="312" stroke="#3fb950" stroke-width="1.0"/> <line x1="350" y1="312" x2="350" y2="248" stroke="#3fb950" stroke-width="1.0"/> <line x1="350" y1="248" x2="369" y2="248" stroke="#3fb950" stroke-width="1.0" marker-end="url(#arr)"/> <text x="346" y="170" fill="#e6c07b" font-size="9">ALUSrc</text> <line x1="379" y1="173" x2="379" y2="176" stroke="#e6c07b" stroke-width="1.0" marker-end="url(#arr)"/> <!-- ── ALU ── --> <polygon points="415,170 415,270 445,255 445,185" fill="#1a2332" stroke="#f78166" stroke-width="1.5"/> <text x="425" y="215" fill="#f78166" font-size="10" font-weight="bold">ALU</text> <text x="418" y="230" fill="#8b949e" font-size="9">Zero</text> <!-- RD1 → ALU A --> <line x1="310" y1="178" x2="390" y2="178" stroke="#3fb950" stroke-width="1.0"/> <line x1="390" y1="178" x2="414" y2="193" stroke="#3fb950" stroke-width="1.0" marker-end="url(#arr)"/> <!-- MUX → ALU B --> <line x1="388" y1="220" x2="413" y2="230" stroke="#e6c07b" stroke-width="1.0" marker-end="url(#arr)"/> <!-- ── Data Memory ── --> <rect x="490" y="175" width="80" height="80" rx="5" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.5"/> <text x="530" y="205" text-anchor="middle" fill="#8b949e" font-size="10">Data</text> <text x="530" y="218" text-anchor="middle" fill="#8b949e" font-size="10">Mem</text> <text x="493" y="234" fill="#6e7681" font-size="9">addr</text> <text x="493" y="247" fill="#6e7681" font-size="9">WD</text> <!-- ALU Result → DataMem addr --> <line x1="445" y1="210" x2="489" y2="210" stroke="#f78166" stroke-width="1.2" marker-end="url(#arr)"/> <!-- RD2 → DataMem write data --> <line x1="310" y1="195" x2="330" y2="195" stroke="#3fb950" stroke-width="1.0"/> <line x1="330" y1="195" x2="330" y2="370" stroke="#3fb950" stroke-width="1.0"/> <line x1="330" y1="370" x2="510" y2="370" stroke="#3fb950" stroke-width="1.0"/> <line x1="510" y1="370" x2="510" y2="256" stroke="#3fb950" stroke-width="1.0" marker-end="url(#arr)"/> <!-- ── MemToReg Mux ── --> <polygon points="610,185 610,265 628,255 628,195" fill="#1e2d3d" stroke="#e6c07b" stroke-width="1.5"/> <text x="614" y="222" fill="#e6c07b" font-size="9">M</text> <text x="614" y="233" fill="#e6c07b" font-size="9">U</text> <text x="614" y="244" fill="#e6c07b" font-size="9">X</text> <!-- ALU Result → MemToReg MUX (top = 0) --> <line x1="455" y1="210" x2="470" y2="210" stroke="#f78166" stroke-width="1.0"/> <line x1="470" y1="210" x2="470" y2="400" stroke="#f78166" stroke-width="1.0"/> <line x1="470" y1="400" x2="620" y2="400" stroke="#f78166" stroke-width="1.0"/> <line x1="620" y1="400" x2="620" y2="266" stroke="#f78166" stroke-width="1.0" marker-end="url(#arr)"/> <!-- DataMem RD → MemToReg MUX (top = 1) --> <line x1="570" y1="215" x2="609" y2="215" stroke="#4a9eff" stroke-width="1.2" marker-end="url(#arr)"/>

<text x="608" y="183" fill="#e6c07b" font-size="9">MemToReg</text> <line x1="619" y1="183" x2="619" y2="186" stroke="#e6c07b" stroke-width="1.0" marker-end="url(#arr)"/>

<!-- ── WB → RegFile ── --> <line x1="628" y1="225" x2="700" y2="225" stroke="#3fb950" stroke-width="1.2"/> <line x1="700" y1="225" x2="700" y2="100" stroke="#3fb950" stroke-width="1.2"/> <line x1="700" y1="100" x2="265" y2="100" stroke="#3fb950" stroke-width="1.2"/> <line x1="265" y1="100" x2="265" y2="129" stroke="#3fb950" stroke-width="1.2" marker-end="url(#arr)"/> <text x="680" y="95" fill="#3fb950" font-size="9">WB data</text> <text x="222" y="126" fill="#3fb950" font-size="9">WD</text> <!-- ── PC+4 Adder ── --> <rect x="100" y="60" width="60" height="36" rx="5" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.3"/> <text x="130" y="83" text-anchor="middle" fill="#8b949e" font-size="10">PC+4</text> <!-- PC → PC+4 adder --> <line x1="47" y1="180" x2="47" y2="78" stroke="#4a9eff" stroke-width="1.0"/> <line x1="47" y1="78" x2="99" y2="78" stroke="#4a9eff" stroke-width="1.0" marker-end="url(#arr)"/> <!-- ── Branch Target Adder ── --> <rect x="100" y="340" width="80" height="36" rx="5" fill="#1a2332" stroke="#3b6ea5" stroke-width="1.3"/> <text x="140" y="358" text-anchor="middle" fill="#8b949e" font-size="10">Branch</text> <text x="140" y="370" text-anchor="middle" fill="#8b949e" font-size="10">Adder</text> <!-- PC → branch adder --> <line x1="30" y1="180" x2="30" y2="358" stroke="#4a9eff" stroke-width="1.0"/> <line x1="30" y1="358" x2="99" y2="358" stroke="#4a9eff" stroke-width="1.0" marker-end="url(#arr)"/> <!-- Imm → branch adder --> <line x1="265" y1="335" x2="265" y2="420" stroke="#3fb950" stroke-width="1.0"/> <line x1="265" y1="420" x2="130" y2="420" stroke="#3fb950" stroke-width="1.0"/> <line x1="130" y1="420" x2="130" y2="377" stroke="#3fb950" stroke-width="1.0" marker-end="url(#arr)"/> <!-- ── PCSrc Mux ── --> <polygon points="30,20 30,70 48,62 48,28" fill="#1e2d3d" stroke="#e6c07b" stroke-width="1.5"/> <text x="34" y="43" fill="#e6c07b" font-size="8">M</text> <text x="34" y="53" fill="#e6c07b" font-size="8">X</text> <!-- PC+4 → PCSrc mux --> <line x1="160" y1="78" x2="180" y2="78" stroke="#4a9eff" stroke-width="1.0"/> <line x1="180" y1="78" x2="180" y2="35" stroke="#4a9eff" stroke-width="1.0"/> <line x1="180" y1="35" x2="49" y2="35" stroke="#4a9eff" stroke-width="1.0" marker-end="url(#arr)"/> <!-- Branch target → PCSrc mux --> <line x1="140" y1="340" x2="140" y2="430" stroke="#f78166" stroke-width="1.0"/> <line x1="140" y1="430" x2="20" y2="430" stroke="#f78166" stroke-width="1.0"/> <line x1="20" y1="430" x2="20" y2="55" stroke="#f78166" stroke-width="1.0"/> <line x1="20" y1="55" x2="29" y2="55" stroke="#f78166" stroke-width="1.0" marker-end="url(#arr)"/> <!-- PCSrc mux → PC --> <line x1="48" y1="44" x2="60" y2="44" stroke="#3fb950" stroke-width="1.2"/> <line x1="60" y1="44" x2="60" y2="200" stroke="#3fb950" stroke-width="1.2"/> <line x1="60" y1="200" x2="19" y2="200" stroke="#3fb950" stroke-width="1.2" marker-end="url(#arr)"/> <!-- Zero flag from ALU → PCSrc AND gate label -->

<text x="430" y="250" fill="#f78166" font-size="9">Zero</text> <line x1="430" y1="240" x2="430" y2="255" stroke="#f78166" stroke-width="1.0"/> <text x="408" y="272" fill="#8b949e" font-size="9">AND Branch</text> <text x="408" y="283" fill="#8b949e" font-size="9">→ PCSrc</text>

<!-- Labels -->

<text x="130" y="150" fill="#58a6ff" font-size="9">IR[19:15]</text> <text x="130" y="163" fill="#58a6ff" font-size="9">IR[24:20]</text> <text x="130" y="176" fill="#58a6ff" font-size="9">IR[11:7]</text>

<defs> <marker id="arr" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#4a9eff"/> </marker> </defs> </svg>

---

### Control Unit

The control unit is a purely combinational block. It decodes the instruction opcode (and sometimes funct3/funct7) and asserts the appropriate control signals.

#### Control Signals Summary

|Signal|Width|Function|
|---|---|---|
|`RegWrite`|1|Enable write to register file|
|`ALUSrc`|1|0 = register operand, 1 = immediate operand|
|`MemRead`|1|Enable data memory read|
|`MemWrite`|1|Enable data memory write|
|`MemToReg`|1|0 = ALU result to reg, 1 = memory data to reg|
|`Branch`|1|Instruction is a branch|
|`ALUOp`|2|Guides ALU control unit|

#### Control Signal Truth Table (RISC-V subset)

|Instruction|RegWrite|ALUSrc|MemRead|MemWrite|MemToReg|Branch|ALUOp|
|---|---|---|---|---|---|---|---|
|R-type|1|0|0|0|0|0|10|
|`lw`|1|1|1|0|1|0|00|
|`sw`|0|1|0|1|X|0|00|
|`beq`|0|0|0|0|X|1|01|

#### ALU Control Sub-Unit

ALUOp from the main control unit feeds a secondary ALU control decoder along with funct3 and funct7[5]:

```
ALUOp = 00  →  ADD          (load/store: address calculation)
ALUOp = 01  →  SUB          (branch: comparison)
ALUOp = 10  →  decode funct3/funct7
               000 / 0  →  ADD
               000 / 1  →  SUB
               111      →  AND
               110      →  OR
               100      →  XOR
               010      →  SLT
```

---

### Instruction Execution Traces

#### R-type: `add x5, x6, x7`

```
1. PC → InstrMem     → IR = 32-bit instruction
2. IR[19:15]=x6, IR[24:20]=x7, IR[11:7]=x5 → Register File
3. RD1=reg[x6], RD2=reg[x7]
4. ALUSrc=0   → ALU input B = RD2
5. ALUOp=10, funct3=000, funct7[5]=0 → ALU: ADD
6. ALUResult = RD1 + RD2
7. MemRead=0, MemWrite=0
8. MemToReg=0 → WB data = ALUResult
9. RegWrite=1  → reg[x5] ← ALUResult
10. PCSrc=0   → PC ← PC+4
```

#### I-type Load: `lw x5, 8(x6)`

```
1. PC → InstrMem     → IR
2. IR[19:15]=x6 → RD1 = reg[x6]
3. IR[31:20] = 0x008 → ImmGen → 32'd8
4. ALUSrc=1   → ALU input B = 8
5. ALUOp=00   → ALU: ADD
6. ALUResult = reg[x6] + 8    (effective address)
7. MemRead=1  → MemData = DataMem[ALUResult]
8. MemToReg=1 → WB data = MemData
9. RegWrite=1  → reg[x5] ← MemData
10. PCSrc=0   → PC ← PC+4
```

#### B-type Branch: `beq x5, x6, label`

```
1. PC → InstrMem     → IR
2. RD1 = reg[x5], RD2 = reg[x6]
3. Branch offset → ImmGen → sign-extended imm
4. Branch Adder: BranchTarget = PC + (imm << 1)
5. ALUSrc=0   → ALU input B = RD2
6. ALUOp=01   → ALU: SUB
7. ALUResult = RD1 - RD2
8. Zero = (ALUResult == 0)
9. PCSrc = Branch AND Zero
   If equal:  PC ← BranchTarget
   If not:    PC ← PC+4
10. RegWrite=0, MemRead=0, MemWrite=0
```

---

### Critical Path Analysis

The clock period is determined by the longest combinational path through the datapath. For the canonical MIPS/RISC-V subset:

```
Instruction    Path
──────────────────────────────────────────────────────────────────
R-type         PC → InstrMem → RegFile(read) → ALU → RegFile(write)
lw             PC → InstrMem → RegFile(read) → ALU → DataMem → Mux → RegFile(write)
sw             PC → InstrMem → RegFile(read) → ALU → DataMem(write)
beq            PC → InstrMem → RegFile(read) → ALU → AND → PCSrc mux → PC
```

The `lw` instruction traverses: PC read → instruction memory → register file read → ALU → data memory → mux → register write — the longest path. It defines the minimum clock period.

#### Typical Component Delays (relative units)

|Component|Delay|
|---|---|
|PC read|~30 ps|
|Instruction memory|~200 ps|
|Register file read|~150 ps|
|ALU|~200 ps|
|Data memory|~250 ps|
|Register file write setup|~20 ps|
|Mux|~25 ps|

```
Critical path (lw):
  30 + 200 + 150 + 200 + 250 + 25 + 20 = 875 ps
  → minimum clock period = 875 ps
  → maximum clock frequency ≈ 1.14 GHz (under these assumptions)

R-type path:
  30 + 200 + 150 + 200 + 25 + 20 = 625 ps
  → 250 ps wasted every cycle waiting for lw's clock period
```

This wasted time motivates pipelining.

---

### Datapath Limitations

|Limitation|Consequence|
|---|---|
|Clock period fixed to worst-case path|Faster instructions are artificially slowed|
|No instruction overlap|CPI = 1 by definition, but throughput limited by cycle time|
|Separate instruction and data memory|Unrealistic; real caches use unified memory with separate ports|
|No exception or interrupt handling|Control flow requires additional hardware|
|No support for multi-cycle or variable-latency operations|Division, floating-point require either stalling or separate units|

---

### Single-Cycle vs. Multi-Cycle Trade-off

|Property|Single-Cycle|Multi-Cycle|
|---|---|---|
|CPI|Always 1|Variable (1–5)|
|Clock period|Worst-case instruction|Shortest functional unit delay|
|Hardware reuse|No (each unit used once)|Yes (ALU reused across cycles)|
|Control complexity|Simple combinational|FSM required|
|Real-world use|Education, FPGAs, simple MCUs|Historical; basis for pipelining|

---

**Key Points**

- Every instruction completes in exactly one clock cycle; the clock period equals the critical path delay of the slowest instruction.
- The datapath consists of five functional units: PC, instruction memory, register file, ALU, and data memory, connected through multiplexers.
- The control unit is purely combinational: it maps opcode bits to a vector of control signals each cycle.
- `lw` defines the critical path; R-type and branch instructions complete faster but must wait for the same clock edge.
- PCSrc is computed as the logical AND of the Branch control signal and the ALU Zero flag.
- The write-back path loops from data memory or ALU result back to the register file input.

**Conclusion** The single-cycle datapath is the foundational model of processor execution. Its structure — fetch, decode, execute, memory access, write-back — maps directly onto the pipeline stages introduced in the next topic. Its principal deficiency, that every cycle must accommodate the worst-case instruction, is precisely what pipelining resolves.

**Next Steps** Proceed to _Multi-Cycle Datapath Design_ to see how functional units are decoupled into separate clock cycles, or advance to _Pipelining_ to see how instruction-level overlap recovers the throughput lost to the critical path constraint.

---


