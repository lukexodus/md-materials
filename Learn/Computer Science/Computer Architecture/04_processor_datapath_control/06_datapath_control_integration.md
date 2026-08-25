## Datapath-Control Integration


---

### Conceptual Separation and the Integration Problem

The **datapath** is the collection of functional units and interconnects that perform and route data: the ALU, register file, memory ports, PC, multiplexers, and buses. The **control unit** generates the binary signals that configure those units at each step of instruction execution — selecting ALU operations, enabling register writes, choosing multiplexer inputs, asserting memory read/write.

Integration is the problem of making these two subsystems operate correctly as a unified machine. The datapath presents a set of control points — each multiplexer select line, each register write-enable, each ALU operation selector — and the control unit must drive every one of them to the correct value for every instruction at every moment in time.

The integration question has two dimensions:

- **Spatial:** which control signals govern which datapath elements, and how are they routed
- **Temporal:** when in the instruction's execution cycle must each signal be valid

---

### Control Points in a Canonical Datapath

A control point is any input to a datapath element that alters its behavior rather than its data. For a standard single-cycle RISC datapath the complete set of control points is:

|Control Signal|Width|Governed Element|Effect|
|---|---|---|---|
|`RegWrite`|1|Register file|Enable write to `rd`|
|`RegDst`|1–2|Rd mux|Select destination register field|
|`ALUSrc`|1|ALU input B mux|Select register `rt` or sign-extended immediate|
|`ALUOp`|2|ALU control|Pass to ALU control unit|
|`ALUControl`|3–4|ALU|Select ADD/SUB/AND/OR/SLT/etc.|
|`MemRead`|1|Data memory|Assert read enable|
|`MemWrite`|1|Data memory|Assert write enable|
|`MemToReg`|1–2|WB mux|Select ALU result or memory read data|
|`Branch`|1|PC logic|Enable branch PC computation|
|`Jump`|1|PC mux|Select jump target|
|`PCSrc`|1|PC mux|Select PC+4, branch target, or jump|

`ALUOp` is an intermediate signal — it encodes a coarse instruction class (R-type, load/store, branch) and feeds a secondary **ALU control unit** that decodes `funct` or `funct3` alongside `ALUOp` to produce the fine-grained `ALUControl` lines. This two-level decode avoids routing the full opcode to the ALU.

---

### Two-Level ALU Control Decode

<svg viewBox="0 0 600 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Main control box --> <rect x="0" y="60" width="160" height="60" rx="6" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <text x="80" y="85" text-anchor="middle" fill="#222" font-weight="bold">Main Control</text> <text x="80" y="102" text-anchor="middle" fill="#555">opcode → ALUOp</text> <!-- ALU Control box --> <rect x="280" y="60" width="160" height="60" rx="6" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/> <text x="360" y="85" text-anchor="middle" fill="#222" font-weight="bold">ALU Control</text> <text x="360" y="102" text-anchor="middle" fill="#555">ALUOp + funct → op</text> <!-- ALU box --> <rect x="500" y="60" width="80" height="60" rx="6" fill="#fff5cc" stroke="#336" stroke-width="1.5"/> <text x="540" y="95" text-anchor="middle" fill="#222" font-weight="bold">ALU</text> <!-- opcode input --> <line x1="0" y1="75" x2="-40" y2="75" stroke="#555" stroke-width="1.5" marker-start="url(#arr)"/> <text x="-45" y="79" text-anchor="end" fill="#555">opcode</text> <!-- funct input to ALU control --> <line x1="280" y1="105" x2="240" y2="105" stroke="#555" stroke-width="1.5"/> <line x1="240" y1="105" x2="240" y2="155" stroke="#555" stroke-width="1.5"/> <text x="200" y="170" fill="#555">funct/funct3</text> <!-- ALUOp wire --> <line x1="160" y1="90" x2="280" y2="90" stroke="#336" stroke-width="2"/> <text x="220" y="82" text-anchor="middle" fill="#336">ALUOp</text> <!-- ALUControl wire --> <line x1="440" y1="90" x2="500" y2="90" stroke="#c60" stroke-width="2"/> <text x="470" y="82" text-anchor="middle" fill="#c60" font-size="10">ALUCtrl</text> <!-- Other control outputs --> <line x1="80" y1="120" x2="80" y2="180" stroke="#555" stroke-width="1.5"/> <text x="85" y="175" fill="#555">RegWrite, MemRead, …</text> </svg>

**ALUOp encoding (2-bit, MIPS-style):**

|ALUOp|Instruction class|ALU action determined by|
|---|---|---|
|00|Load / Store|Always ADD (address computation)|
|01|Branch (beq)|Always SUB (comparison)|
|10|R-type|`funct` field|
|11|(reserved / immediate)|Varies|

**ALU control decode for ALUOp = 10:**

|funct (MIPS)|ALUControl|Operation|
|---|---|---|
|100000|0010|ADD|
|100010|0110|SUB|
|100100|0000|AND|
|100101|0001|OR|
|101010|0111|SLT|

---

### Signal Table for Key Instructions

The complete control word — every control signal's value — for each instruction class in a single-cycle MIPS-like datapath:

|Instruction|RegDst|ALUSrc|MemToReg|RegWrite|MemRead|MemWrite|Branch|ALUOp|
|---|---|---|---|---|---|---|---|---|
|R-type|1|0|0|1|0|0|0|10|
|`lw`|0|1|1|1|1|0|0|00|
|`sw`|×|1|×|0|0|1|0|00|
|`beq`|×|0|×|0|0|0|1|01|
|`j`|×|×|×|0|0|0|0|××|

`×` denotes don't-care — the signal's value does not affect correctness for that instruction because the consuming datapath element's output is not used.

---

### Datapath Data Flow with Control Overlay

The following diagram shows the single-cycle datapath with control signals annotated at each control point. Data paths are shown in blue; control signals in orange.

<svg viewBox="0 0 780 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- PC --> <rect x="0" y="170" width="60" height="40" rx="4" fill="#e8d0ff" stroke="#336" stroke-width="1.5"/> <text x="30" y="195" text-anchor="middle" fill="#222">PC</text> <!-- Instruction Memory --> <rect x="80" y="140" width="90" height="80" rx="4" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <text x="125" y="178" text-anchor="middle" fill="#222">Instr</text> <text x="125" y="192" text-anchor="middle" fill="#222">Mem</text> <!-- Register File --> <rect x="230" y="110" width="100" height="140" rx="4" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/> <text x="280" y="175" text-anchor="middle" fill="#222">Register</text> <text x="280" y="190" text-anchor="middle" fill="#222">File</text> <!-- ALU --> <rect x="400" y="150" width="80" height="80" rx="4" fill="#fff5cc" stroke="#336" stroke-width="1.5"/> <text x="440" y="195" text-anchor="middle" fill="#222">ALU</text> <!-- Data Memory --> <rect x="540" y="140" width="90" height="80" rx="4" fill="#ffd6d6" stroke="#336" stroke-width="1.5"/> <text x="585" y="178" text-anchor="middle" fill="#222">Data</text> <text x="585" y="192" text-anchor="middle" fill="#222">Mem</text> <!-- WB MUX --> <rect x="680" y="155" width="50" height="50" rx="4" fill="#ffeedd" stroke="#336" stroke-width="1.5"/> <text x="705" y="183" text-anchor="middle" fill="#222">MUX</text> <text x="705" y="196" text-anchor="middle" fill="#555" font-size="9">MemToReg</text> <!-- ALUSrc MUX --> <rect x="360" y="200" width="36" height="36" rx="4" fill="#ffeedd" stroke="#336" stroke-width="1.5"/> <text x="378" y="220" text-anchor="middle" fill="#222">MUX</text> <text x="378" y="230" text-anchor="middle" fill="#555" font-size="9">ALUSrc</text> <!-- PC+4 adder --> <rect x="80" y="60" width="60" height="34" rx="4" fill="#e0e0e0" stroke="#555" stroke-width="1.2"/> <text x="110" y="82" text-anchor="middle" fill="#333">PC+4</text> <!-- Branch adder --> <rect x="380" y="60" width="60" height="34" rx="4" fill="#e0e0e0" stroke="#555" stroke-width="1.2"/> <text x="410" y="82" text-anchor="middle" fill="#333">Branch</text> <text x="410" y="93" text-anchor="middle" fill="#333">Adder</text> <!-- PC Src MUX --> <rect x="480" y="58" width="40" height="38" rx="4" fill="#ffeedd" stroke="#336" stroke-width="1.5"/> <text x="500" y="78" text-anchor="middle" fill="#222">MUX</text> <text x="500" y="91" text-anchor="middle" fill="#555" font-size="9">PCSrc</text> <!-- Sign extend --> <rect x="230" y="310" width="100" height="30" rx="4" fill="#e0e0e0" stroke="#555" stroke-width="1.2"/> <text x="280" y="330" text-anchor="middle" fill="#333">Sign Extend</text> <!-- Data wires --> <!-- PC to InstrMem --> <line x1="60" y1="190" x2="80" y2="190" stroke="#336" stroke-width="2"/> <!-- InstrMem to RegFile --> <line x1="170" y1="160" x2="230" y2="145" stroke="#336" stroke-width="1.5"/> <line x1="170" y1="175" x2="230" y2="175" stroke="#336" stroke-width="1.5"/> <line x1="170" y1="190" x2="230" y2="205" stroke="#336" stroke-width="1.5"/> <!-- RegFile to ALU --> <line x1="330" y1="165" x2="400" y2="175" stroke="#336" stroke-width="1.5"/> <!-- RegFile to ALUSrc MUX --> <line x1="330" y1="200" x2="360" y2="215" stroke="#336" stroke-width="1.5"/> <!-- ALUSrc MUX to ALU --> <line x1="396" y1="218" x2="400" y2="205" stroke="#336" stroke-width="1.5"/> <!-- Sign extend to ALUSrc MUX --> <line x1="280" y1="310" x2="350" y2="310" stroke="#336" stroke-width="1.5"/> <line x1="350" y1="310" x2="350" y2="230" stroke="#336" stroke-width="1.5"/> <line x1="350" y1="230" x2="360" y2="225" stroke="#336" stroke-width="1.5"/> <!-- ALU to DataMem --> <line x1="480" y1="190" x2="540" y2="190" stroke="#336" stroke-width="2"/> <!-- DataMem to WB MUX --> <line x1="630" y1="175" x2="680" y2="172" stroke="#336" stroke-width="1.5"/> <!-- ALU result to WB MUX --> <line x1="480" y1="180" x2="580" y2="180" stroke="#336" stroke-width="1"/> <line x1="580" y1="180" x2="580" y2="155" stroke="#336" stroke-width="1"/> <line x1="580" y1="155" x2="680" y2="190" stroke="#336" stroke-width="1.5"/> <!-- WB MUX to RegFile --> <line x1="730" y1="180" x2="760" y2="180" stroke="#336" stroke-width="1.5"/> <line x1="760" y1="180" x2="760" y2="130" stroke="#336" stroke-width="1.5"/> <line x1="760" y1="130" x2="330" y2="130" stroke="#336" stroke-width="1.5"/> <text x="680" y="125" fill="#336" font-size="10">WriteData</text> <!-- PC+4 wires --> <line x1="30" y1="170" x2="30" y2="77" stroke="#336" stroke-width="1.2"/> <line x1="30" y1="77" x2="80" y2="77" stroke="#336" stroke-width="1.2"/> <line x1="140" y1="77" x2="480" y2="77" stroke="#336" stroke-width="1.2"/> <!-- Branch adder --> <line x1="280" y1="310" x2="370" y2="310" stroke="#336" stroke-width="1"/> <line x1="370" y1="310" x2="370" y2="77" stroke="#336" stroke-width="1"/> <line x1="370" y1="77" x2="380" y2="77" stroke="#336" stroke-width="1"/> <line x1="440" y1="77" x2="480" y2="77" stroke="#336" stroke-width="1"/> <!-- PCSrc MUX to PC --> <line x1="520" y1="77" x2="560" y2="77" stroke="#336" stroke-width="1.5"/> <line x1="560" y1="77" x2="560" y2="30" stroke="#336" stroke-width="1.5"/> <line x1="560" y1="30" x2="30" y2="30" stroke="#336" stroke-width="1.5"/> <line x1="30" y1="30" x2="30" y2="170" stroke="#336" stroke-width="1.5"/> <!-- Control signals (orange) --> <!-- RegWrite --> <line x1="280" y1="50" x2="280" y2="110" stroke="#c60" stroke-width="1.5" stroke-dasharray="4,2"/> <text x="285" y="65" fill="#c60">RegWrite</text> <!-- ALUSrc --> <line x1="378" y1="240" x2="378" y2="260" stroke="#c60" stroke-width="1.5" stroke-dasharray="4,2"/> <text x="325" y="272" fill="#c60">ALUSrc</text> <!-- ALUControl --> <line x1="440" y1="240" x2="440" y2="265" stroke="#c60" stroke-width="1.5" stroke-dasharray="4,2"/> <text x="390" y="278" fill="#c60">ALUControl</text> <!-- MemRead / MemWrite --> <line x1="585" y1="230" x2="585" y2="260" stroke="#c60" stroke-width="1.5" stroke-dasharray="4,2"/> <text x="530" y="272" fill="#c60">MemRead</text> <text x="530" y="284" fill="#c60">MemWrite</text> <!-- MemToReg --> <line x1="705" y1="210" x2="705" y2="240" stroke="#c60" stroke-width="1.5" stroke-dasharray="4,2"/> <text x="660" y="255" fill="#c60">MemToReg</text> <!-- Branch/PCSrc --> <line x1="500" y1="50" x2="500" y2="58" stroke="#c60" stroke-width="1.5" stroke-dasharray="4,2"/> <text x="508" y="48" fill="#c60">PCSrc</text> <!-- ALU zero to branch AND --> <line x1="480" y1="170" x2="510" y2="170" stroke="#c60" stroke-width="1.2" stroke-dasharray="3,2"/> <text x="510" y="166" fill="#c60" font-size="9">Zero</text> </svg>

---

### The Control Word

In a single-cycle design, the full set of control signals for one instruction can be concatenated into a **control word** — a binary vector read from a lookup table (ROM) indexed by the opcode.

For the MIPS-like datapath with signals as defined above, the control word is 9 bits wide (excluding ALUControl, which is produced by the secondary ALU control unit):

```
CW = { RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp[1], ALUOp[0] }
```

|Instruction|RegDst|ALUSrc|MemToReg|RegWrite|MemRead|MemWrite|Branch|ALUOp|Word (binary)|
|---|---|---|---|---|---|---|---|---|---|
|R-type|1|0|0|1|0|0|0|10|`100110010`|
|`lw`|0|1|1|1|1|0|0|00|`011110000`|
|`sw`|0|1|0|0|0|1|0|00|`010001000`|
|`beq`|0|0|0|0|0|0|1|01|`000000101`|

A ROM or PLA indexed by opcode outputs this word combinationally — this is the ROM-based (microprogrammed-style) control implementation for a single-cycle machine.

---

### Hardwired Control Integration

In hardwired control, the control word is produced by combinational logic — AND/OR gates, decoders — directly from the opcode bits. There is no ROM.

**Implementation steps:**

1. Express each control signal as a Boolean function of the opcode bits
2. Minimize using Karnaugh maps or Boolean algebra
3. Implement with gates

**Example — `RegWrite`:**

`RegWrite` = 1 for R-type, `lw`; = 0 for `sw`, `beq`, `j`.

If opcode bits are `op[5:0]`:

- R-type: `op = 000000`
- lw: `op = 100011`

```
RegWrite = (op == 000000) | (op == 100011)
         = R_type | lw
```

Each such signal becomes a dedicated combinational expression. In a real implementation, the opcode is first decoded into one-hot instruction signals (R_type, lw, sw, beq, j, …) and each control signal is the OR of the instruction signals that require it to be asserted.

<svg viewBox="0 0 600 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Opcode decoder --> <rect x="0" y="60" width="120" height="120" rx="4" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <text x="60" y="95" text-anchor="middle" fill="#222" font-weight="bold">Opcode</text> <text x="60" y="110" text-anchor="middle" fill="#222" font-weight="bold">Decoder</text> <text x="60" y="130" text-anchor="middle" fill="#555" font-size="10">6-to-N</text> <text x="60" y="143" text-anchor="middle" fill="#555" font-size="10">one-hot</text> <!-- opcode input --> <line x1="0" y1="120" x2="-40" y2="120" stroke="#555" stroke-width="1.5"/> <text x="-45" y="124" text-anchor="end" fill="#555">op[5:0]</text> <!-- one-hot outputs --> <line x1="120" y1="80" x2="200" y2="80" stroke="#555" stroke-width="1.2"/> <text x="205" y="84" fill="#555">R_type</text> <line x1="120" y1="100" x2="200" y2="100" stroke="#555" stroke-width="1.2"/> <text x="205" y="104" fill="#555">lw</text> <line x1="120" y1="120" x2="200" y2="120" stroke="#555" stroke-width="1.2"/> <text x="205" y="124" fill="#555">sw</text> <line x1="120" y1="140" x2="200" y2="140" stroke="#555" stroke-width="1.2"/> <text x="205" y="144" fill="#555">beq</text> <line x1="120" y1="160" x2="200" y2="160" stroke="#555" stroke-width="1.2"/> <text x="205" y="164" fill="#555">j</text> <!-- OR gates for signals --> <rect x="360" y="68" width="100" height="28" rx="4" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <text x="410" y="87" text-anchor="middle" fill="#222">RegWrite</text> <line x1="295" y1="80" x2="360" y2="78" stroke="#c60" stroke-width="1.2"/> <line x1="295" y1="100" x2="360" y2="84" stroke="#c60" stroke-width="1.2"/> <text x="325" y="75" fill="#c60" font-size="10">OR</text> <rect x="360" y="110" width="100" height="28" rx="4" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <text x="410" y="129" text-anchor="middle" fill="#222">ALUSrc</text> <line x1="295" y1="100" x2="360" y2="117" stroke="#c60" stroke-width="1.2"/> <line x1="295" y1="120" x2="360" y2="122" stroke="#c60" stroke-width="1.2"/> <text x="325" y="112" fill="#c60" font-size="10">OR</text> <rect x="360" y="152" width="100" height="28" rx="4" fill="#d0ffd6" stroke="#336" stroke-width="1.2"/> <text x="410" y="171" text-anchor="middle" fill="#222">MemWrite</text> <line x1="295" y1="120" x2="360" y2="163" stroke="#c60" stroke-width="1.2"/> <text x="325" y="157" fill="#c60" font-size="10">direct</text> </svg>

---

### Microprogrammed Control Integration

In microprogrammed control, each machine instruction maps to a sequence of **microinstructions** stored in a **control store** (a fast ROM). Each microinstruction is a wide word — one bit per control signal, plus sequencing fields.

**Microinstruction format:**

<svg viewBox="0 0 720 70" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect x="0" y="15" width="280" height="38" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <rect x="280" y="15" width="200" height="38" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/> <rect x="480" y="15" width="80" height="38" fill="#fff5cc" stroke="#336" stroke-width="1.5"/> <rect x="560" y="15" width="160" height="38" fill="#ffeedd" stroke="#336" stroke-width="1.5"/> <text x="140" y="37" text-anchor="middle" fill="#222">Datapath control fields</text> <text x="140" y="50" text-anchor="middle" fill="#555" font-size="10">one bit per control signal</text> <text x="380" y="37" text-anchor="middle" fill="#222">ALU operation</text> <text x="520" y="37" text-anchor="middle" fill="#222">Seq</text> <text x="640" y="37" text-anchor="middle" fill="#222">Next address</text> <text x="640" y="50" text-anchor="middle" fill="#555" font-size="10">or dispatch/branch</text> </svg>

The sequencing field encodes how the microprogram counter (μPC) advances:

|Seq code|Action|
|---|---|
|`INC`|μPC ← μPC + 1 (next microinstruction)|
|`JUMP`|μPC ← next_address field|
|`DISPATCH`|μPC ← mapping_ROM[opcode] (fetch next instruction)|
|`BRANCH`|μPC ← condition ? addr_field : μPC+1|

**Microprogram for `lw` (multi-cycle MIPS):**

|μAddr|Control signals active|Seq|Notes|
|---|---|---|---|
|00|IorD=0, MemRead, IRWrite, ALUSrcA=0, ALUSrcB=01, ALUOp=ADD, PCWrite|INC|IF: fetch, PC←PC+4|
|01|ALUSrcA=0, ALUSrcB=11, ALUOp=ADD|INC|ID: decode, compute base+offset|
|02|ALUSrcA=1, ALUSrcB=10, ALUOp=ADD, IorD=1, MemRead|INC|EX/MEM: address calc, memory read|
|03|RegDst=0, RegWrite, MemToReg=1|DISPATCH|WB: write memory data to register|

---

### Multi-Cycle Datapath Control Integration

In a multi-cycle design, the datapath is partitioned into stages separated by **interstage registers** (IR, A, B, ALUOut, MDR). Control signals now have two additional properties:

- **Which cycle** they must be asserted — a signal valid in cycle 2 must not be generated in cycle 1
- **Which interstage register** captures the result for use in a subsequent cycle

The integration challenge becomes a **state machine problem**: each state corresponds to a pipeline stage of a particular instruction class, and the FSM transitions encode both the control outputs for that state and the next state.

<svg viewBox="0 0 700 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- State 0: IF --> <circle cx="80" cy="60" r="36" fill="#d0e8ff" stroke="#336" stroke-width="2"/> <text x="80" y="56" text-anchor="middle" fill="#222" font-weight="bold">S0</text> <text x="80" y="70" text-anchor="middle" fill="#222">IF</text> <!-- State 1: ID --> <circle cx="280" cy="60" r="36" fill="#d0ffd6" stroke="#336" stroke-width="2"/> <text x="280" y="56" text-anchor="middle" fill="#222" font-weight="bold">S1</text> <text x="280" y="70" text-anchor="middle" fill="#222">ID/RF</text> <!-- State 2a: EX R-type --> <circle cx="160" cy="190" r="36" fill="#fff5cc" stroke="#336" stroke-width="2"/> <text x="160" y="186" text-anchor="middle" fill="#222" font-weight="bold">S2a</text> <text x="160" y="200" text-anchor="middle" fill="#222">EX R-type</text> <!-- State 2b: EX lw/sw --> <circle cx="400" cy="190" r="36" fill="#fff5cc" stroke="#336" stroke-width="2"/> <text x="400" y="186" text-anchor="middle" fill="#222" font-weight="bold">S2b</text> <text x="400" y="200" text-anchor="middle" fill="#222">EX mem</text> <!-- State 2c: Branch --> <circle cx="560" cy="190" r="36" fill="#ffd6d6" stroke="#336" stroke-width="2"/> <text x="560" y="186" text-anchor="middle" fill="#222" font-weight="bold">S2c</text> <text x="560" y="200" text-anchor="middle" fill="#222">BEQ</text> <!-- State 3a: WB R-type --> <circle cx="160" cy="310" r="36" fill="#e8d0ff" stroke="#336" stroke-width="2"/> <text x="160" y="306" text-anchor="middle" fill="#222" font-weight="bold">S3a</text> <text x="160" y="320" text-anchor="middle" fill="#222">WB R</text> <!-- State 3b: MEM read --> <circle cx="340" cy="310" r="36" fill="#ffeedd" stroke="#336" stroke-width="2"/> <text x="340" y="306" text-anchor="middle" fill="#222" font-weight="bold">S3b</text> <text x="340" y="320" text-anchor="middle" fill="#222">MEM rd</text> <!-- State 3c: MEM write --> <circle cx="500" cy="310" r="36" fill="#ffeedd" stroke="#336" stroke-width="2"/> <text x="500" y="306" text-anchor="middle" fill="#222" font-weight="bold">S3c</text> <text x="500" y="320" text-anchor="middle" fill="#222">MEM wr</text> <!-- Transitions --> <!-- S0 → S1 --> <line x1="116" y1="60" x2="244" y2="60" stroke="#555" stroke-width="1.5" marker-end="url(#a)"/> <!-- S1 → S2a (R-type) --> <line x1="254" y1="82" x2="186" y2="168" stroke="#555" stroke-width="1.5" marker-end="url(#a)"/> <text x="196" y="120" fill="#555">R-type</text> <!-- S1 → S2b (lw/sw) --> <line x1="304" y1="82" x2="376" y2="168" stroke="#555" stroke-width="1.5" marker-end="url(#a)"/> <text x="360" y="118" fill="#555">lw/sw</text> <!-- S1 → S2c (beq) --> <line x1="314" y1="72" x2="526" y2="174" stroke="#555" stroke-width="1.5" marker-end="url(#a)"/> <text x="450" y="110" fill="#555">beq</text> <!-- S2a → S3a --> <line x1="160" y1="226" x2="160" y2="274" stroke="#555" stroke-width="1.5" marker-end="url(#a)"/> <!-- S2b → S3b (lw) --> <line x1="376" y1="212" x2="366" y2="276" stroke="#555" stroke-width="1.5" marker-end="url(#a)"/> <text x="322" y="248" fill="#555">lw</text> <!-- S2b → S3c (sw) --> <line x1="424" y1="212" x2="476" y2="276" stroke="#555" stroke-width="1.5" marker-end="url(#a)"/> <text x="465" y="248" fill="#555">sw</text> <!-- S3a → S0 (back) --> <path d="M 130,296 Q 30,250 44,84" stroke="#555" stroke-width="1.2" fill="none" stroke-dasharray="5,3" marker-end="url(#a)"/> <!-- S3b → WB state (implicit, arrow out) --> <line x1="340" y1="346" x2="340" y2="365" stroke="#555" stroke-width="1.2" marker-end="url(#a)"/> <text x="270" y="375" fill="#555">WB lw → S0</text> <!-- S3c → S0 --> <line x1="500" y1="346" x2="500" y2="365" stroke="#555" stroke-width="1.2" marker-end="url(#a)"/> <text x="430" y="375" fill="#555">done → S0</text> <!-- S2c → S0 (branch taken/not) --> <path d="M 592,210 Q 660,280 660,60 Q 660,30 116,50" stroke="#555" stroke-width="1.2" fill="none" stroke-dasharray="5,3" marker-end="url(#a)"/> <text x="665" y="155" fill="#555">→ S0</text> <defs> <marker id="a" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#555"/> </marker> </defs> </svg>

Each FSM state outputs a specific control word. The FSM is the integration mechanism: it maps (current state, instruction type) → (control outputs, next state).

---

### Pipelined Datapath Control Integration

In a pipelined datapath, the integration problem becomes a **propagation problem**: control signals generated during decode must travel with their instruction through the pipeline, reaching the correct stage at the correct cycle.

The mechanism is **control register propagation** — the control word is latched into each pipeline register alongside the data it governs.

<svg viewBox="0 0 760 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- Stages --> <rect x="0" y="40" width="100" height="50" rx="4" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <text x="50" y="70" text-anchor="middle" fill="#222">IF</text> <rect x="140" y="40" width="100" height="50" rx="4" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/> <text x="190" y="70" text-anchor="middle" fill="#222">ID</text> <rect x="280" y="40" width="100" height="50" rx="4" fill="#fff5cc" stroke="#336" stroke-width="1.5"/> <text x="330" y="70" text-anchor="middle" fill="#222">EX</text> <rect x="420" y="40" width="100" height="50" rx="4" fill="#ffd6d6" stroke="#336" stroke-width="1.5"/> <text x="470" y="70" text-anchor="middle" fill="#222">MEM</text> <rect x="560" y="40" width="100" height="50" rx="4" fill="#e8d0ff" stroke="#336" stroke-width="1.5"/> <text x="610" y="70" text-anchor="middle" fill="#222">WB</text> <!-- Pipeline registers --> <rect x="110" y="30" width="20" height="120" rx="2" fill="#ccc" stroke="#555" stroke-width="1.2"/> <text x="120" y="165" text-anchor="middle" fill="#555">IF/ID</text> <rect x="250" y="30" width="20" height="120" rx="2" fill="#ccc" stroke="#555" stroke-width="1.2"/> <text x="260" y="165" text-anchor="middle" fill="#555">ID/EX</text> <rect x="390" y="30" width="20" height="120" rx="2" fill="#ccc" stroke="#555" stroke-width="1.2"/> <text x="400" y="165" text-anchor="middle" fill="#555">EX/MEM</text> <rect x="530" y="30" width="20" height="120" rx="2" fill="#ccc" stroke="#555" stroke-width="1.2"/> <text x="540" y="165" text-anchor="middle" fill="#555">MEM/WB</text> <!-- Control word propagation (orange dashed) --> <rect x="250" y="100" width="20" height="22" rx="2" fill="#ffeedd" stroke="#c60" stroke-width="1.5"/> <text x="260" y="116" text-anchor="middle" fill="#c60" font-size="9">CW</text> <rect x="390" y="100" width="20" height="22" rx="2" fill="#ffeedd" stroke="#c60" stroke-width="1.5"/> <text x="400" y="116" text-anchor="middle" fill="#c60" font-size="9">CW</text> <rect x="530" y="100" width="20" height="22" rx="2" fill="#ffeedd" stroke="#c60" stroke-width="1.5"/> <text x="540" y="116" text-anchor="middle" fill="#c60" font-size="9">CW</text> <!-- Arrows showing control word moving right --> <line x1="270" y1="111" x2="390" y2="111" stroke="#c60" stroke-width="1.5" stroke-dasharray="4,2" marker-end="url(#b)"/> <line x1="410" y1="111" x2="530" y2="111" stroke="#c60" stroke-width="1.5" stroke-dasharray="4,2" marker-end="url(#b)"/> <!-- Decode arrow --> <line x1="190" y1="90" x2="250" y2="108" stroke="#c60" stroke-width="1.5" marker-end="url(#b)"/> <text x="185" y="108" text-anchor="end" fill="#c60">decode</text> <!-- EX signals peel off --> <line x1="390" y1="105" x2="330" y2="90" stroke="#c60" stroke-width="1.2" stroke-dasharray="3,2"/> <text x="330" y="86" text-anchor="middle" fill="#c60" font-size="9">EX signals</text> <!-- MEM signals peel off --> <line x1="530" y1="105" x2="470" y2="90" stroke="#c60" stroke-width="1.2" stroke-dasharray="3,2"/> <text x="470" y="86" text-anchor="middle" fill="#c60" font-size="9">MEM signals</text> <!-- WB signals peel off --> <line x1="550" y1="105" x2="610" y2="90" stroke="#c60" stroke-width="1.2" stroke-dasharray="3,2"/> <text x="640" y="86" fill="#c60" font-size="9">WB signals</text> <defs> <marker id="b" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#c60"/> </marker> </defs> </svg>

**Control word partitioning across pipeline stages:**

|Pipeline register|Control signals it carries|Consumed by|
|---|---|---|
|IF/ID|(none generated yet — instruction bits)|ID stage decode|
|ID/EX|EX group: ALUSrc, ALUOp, RegDst|EX stage|
||MEM group: MemRead, MemWrite|EX/MEM register|
||WB group: RegWrite, MemToReg|EX/MEM → MEM/WB|
|EX/MEM|MEM group: MemRead, MemWrite|MEM stage|
||WB group: RegWrite, MemToReg|MEM/WB register|
|MEM/WB|WB group: RegWrite, MemToReg|WB stage|

Signals are generated once at decode and travel with the instruction — they are consumed at their target stage and discarded. `RegWrite` and `MemToReg` must travel the full distance to WB; `ALUSrc` is consumed at EX and never written further.

---

### Hazard Control Integration

Hazard detection and resolution require the control unit to generate additional signals that override or suppress normal control flow:

**Stall (load-use hazard):**

```
stall = (ID/EX.MemRead)
      & ((ID/EX.rt == IF/ID.rs) | (ID/EX.rt == IF/ID.rt))
```

When `stall` is asserted:

- PC write-enable is deasserted (PC holds its value)
- IF/ID register write-enable is deasserted (instruction register holds)
- ID/EX control word is set to all zeros (NOP bubble inserted)

**Flush (branch misprediction or control hazard):**

When a branch outcome is resolved in MEM:

- IF/ID and ID/EX pipeline registers are cleared (their control words set to zero)
- This squashes the two instructions fetched speculatively after the branch

**Forwarding unit:** does not generate stalls but selects alternate data paths — it controls the forwarding MUX selects at the EX stage inputs. These are additional control signals produced by combinational logic comparing pipeline register destination fields:

```
if (EX/MEM.RegWrite & EX/MEM.rd ≠ 0 & EX/MEM.rd == ID/EX.rs)
    ForwardA = 10   // forward from EX/MEM ALU result

if (MEM/WB.RegWrite & MEM/WB.rd ≠ 0
    & !(EX/MEM.RegWrite & EX/MEM.rd == ID/EX.rs)
    & MEM/WB.rd == ID/EX.rs)
    ForwardA = 01   // forward from MEM/WB
```

These forwarding signals feed 3-to-1 MUXes at ALU input A and input B, selecting among the register file output, the EX/MEM forwarded value, and the MEM/WB forwarded value.

---

### Exception and Interrupt Integration

The control unit must handle exceptional conditions — arithmetic overflow, undefined opcode, memory fault, external interrupt — by:

1. **Detecting** the exception condition (combinational logic on status flags or opcode validity)
2. **Saving state** — writing the faulting PC to EPC (Exception Program Counter register), writing a cause code to the Cause register
3. **Squashing** in-flight instructions — asserting flush signals on all pipeline registers behind the excepting instruction
4. **Redirecting** the PC to the exception handler vector address

This is control integration at the system level: the control unit must generate all normal datapath control signals, monitor for exceptional conditions, and be capable of overriding the normal control flow atomically. In hardware, this is implemented as additional logic feeding into the PC-source MUX and the pipeline register write-enables.

---

### Observability and Debug Interfaces

A practical consideration in datapath-control integration is providing hardware observability — the ability to inspect internal state without disrupting operation:

- **Scan chains:** flip-flops in the pipeline registers and control registers are chained into a serial shift register, allowing their state to be read out via JTAG
- **Performance counters:** dedicated registers count events (instructions retired, cache misses, branch mispredictions) by monitoring control signals that indicate those events
- **Breakpoint registers:** compare PC or data addresses against stored values; assert a trap signal when matched, which the control unit routes through the exception mechanism

These are integrated into the control fabric — they observe control signals and in some cases inject them — without being part of the normal instruction execution path.

---

**Key Points**

- Datapath-control integration is the problem of routing the correct binary signal to every datapath control point at the correct time for every instruction.
- The control word — the complete vector of control signals for one instruction — is the central abstraction: in single-cycle designs it is produced combinationally from the opcode; in multi-cycle designs it is the output of each FSM state; in pipelined designs it is latched and propagated through pipeline registers.
- Two-level ALU control (ALUOp → ALU control unit → ALUControl) decouples the main control unit from fine-grained operation selection, keeping the main control logic width manageable.
- In pipelined designs, control signals must be partitioned by the stage that consumes them and carried in pipeline registers alongside data — failure to propagate a signal the correct number of stages is a correctness bug equivalent to a data hazard.
- Hazard resolution — stall insertion, pipeline flush, forwarding mux selection — is implemented as additional control logic that overrides or augments normal control signal generation; it is integrated into the same control unit, not a separate system.

**Next Steps**

Proceed to **Pipeline Stages and Throughput** to see how the single-cycle and multi-cycle datapaths developed here are restructured into a pipeline, and how the control integration techniques — particularly the control word propagation and hazard control signals — scale to that model. Follow with **Hazard Detection and Resolution** for the full formal treatment of stall and flush logic.

---

