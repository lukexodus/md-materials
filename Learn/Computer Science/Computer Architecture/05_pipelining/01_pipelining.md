## Pipelining


Pipelining is a microarchitectural technique that overlaps the execution of multiple instructions by decomposing instruction processing into discrete, sequential stages — each handled by dedicated hardware operating in parallel on different instructions simultaneously. It is the foundational throughput mechanism in virtually all modern processors.

---

### The Core Principle

Without pipelining, each instruction occupies the entire datapath from fetch through writeback before the next instruction begins. With pipelining, the datapath is partitioned into stages separated by **pipeline registers**; as one instruction advances from stage $i$ to stage $i+1$, the next instruction enters stage $i$.

<svg viewBox="0 0 620 230" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- Title labels --> <text x="10" y="20" fill="#aaa" font-size="10">Unpipelined</text> <text x="10" y="115" fill="#aaa" font-size="10">Pipelined</text> <!-- Unpipelined: I1 occupies all 5 stages then I2 --> <!-- Time axis ticks --> <line x1="60" y1="95" x2="600" y2="95" stroke="#444" stroke-width="0.8"/> <line x1="60" y1="190" x2="600" y2="190" stroke="#444" stroke-width="0.8"/> <!-- Unpipelined I1: cycles 1-5 --> <rect x="60" y="28" width="265" height="28" rx="2" fill="#1a3a5c" stroke="#7af" stroke-width="1"/> <text x="192" y="47" text-anchor="middle" fill="#7af">I1 (5 cycles)</text> <!-- Unpipelined I2: cycles 6-10 --> <rect x="325" y="28" width="265" height="28" rx="2" fill="#1a3a5c" stroke="#7af" stroke-width="1"/> <text x="458" y="47" text-anchor="middle" fill="#7af">I2 (5 cycles)</text> <!-- Cycle markers unpipelined -->

<text x="60" y="90" text-anchor="middle" fill="#555" font-size="9">0</text> <text x="113" y="90" text-anchor="middle" fill="#555" font-size="9">1</text> <text x="166" y="90" text-anchor="middle" fill="#555" font-size="9">2</text> <text x="219" y="90" text-anchor="middle" fill="#555" font-size="9">3</text> <text x="272" y="90" text-anchor="middle" fill="#555" font-size="9">4</text> <text x="325" y="90" text-anchor="middle" fill="#555" font-size="9">5</text> <text x="378" y="90" text-anchor="middle" fill="#555" font-size="9">6</text> <text x="431" y="90" text-anchor="middle" fill="#555" font-size="9">7</text> <text x="484" y="90" text-anchor="middle" fill="#555" font-size="9">8</text> <text x="537" y="90" text-anchor="middle" fill="#555" font-size="9">9</text> <text x="590" y="90" text-anchor="middle" fill="#555" font-size="9">10</text>

<!-- Pipelined: 5 instructions, each 1 cycle wide per stage, staggered --> <!-- I1 --> <rect x="60" y="122" width="53" height="22" rx="2" fill="#1a3a5c" stroke="#7af" stroke-width="1"/> <text x="86" y="137" text-anchor="middle" fill="#7af" font-size="9">I1 IF</text> <rect x="113" y="122" width="53" height="22" rx="2" fill="#1a3a5c" stroke="#7af" stroke-width="1"/> <text x="139" y="137" text-anchor="middle" fill="#7af" font-size="9">I1 ID</text> <rect x="166" y="122" width="53" height="22" rx="2" fill="#1a3a5c" stroke="#7af" stroke-width="1"/> <text x="192" y="137" text-anchor="middle" fill="#7af" font-size="9">I1 EX</text> <rect x="219" y="122" width="53" height="22" rx="2" fill="#1a3a5c" stroke="#7af" stroke-width="1"/> <text x="245" y="137" text-anchor="middle" fill="#7af" font-size="9">I1 MA</text> <rect x="272" y="122" width="53" height="22" rx="2" fill="#1a3a5c" stroke="#7af" stroke-width="1"/> <text x="298" y="137" text-anchor="middle" fill="#7af" font-size="9">I1 WB</text> <!-- I2 --> <rect x="113" y="148" width="53" height="22" rx="2" fill="#1a3a5c" stroke="#5cf" stroke-width="1"/> <text x="139" y="163" text-anchor="middle" fill="#5cf" font-size="9">I2 IF</text> <rect x="166" y="148" width="53" height="22" rx="2" fill="#1a3a5c" stroke="#5cf" stroke-width="1"/> <text x="192" y="163" text-anchor="middle" fill="#5cf" font-size="9">I2 ID</text> <rect x="219" y="148" width="53" height="22" rx="2" fill="#1a3a5c" stroke="#5cf" stroke-width="1"/> <text x="245" y="163" text-anchor="middle" fill="#5cf" font-size="9">I2 EX</text> <rect x="272" y="148" width="53" height="22" rx="2" fill="#1a3a5c" stroke="#5cf" stroke-width="1"/> <text x="298" y="163" text-anchor="middle" fill="#5cf" font-size="9">I2 MA</text> <rect x="325" y="148" width="53" height="22" rx="2" fill="#1a3a5c" stroke="#5cf" stroke-width="1"/> <text x="351" y="163" text-anchor="middle" fill="#5cf" font-size="9">I2 WB</text> <!-- I3 --> <rect x="166" y="148" width="53" height="22" rx="2" fill="none" stroke="none"/> <rect x="166" y="170" width="53" height="18" rx="2" fill="#1a3a5c" stroke="#fa7" stroke-width="1"/> <text x="192" y="182" text-anchor="middle" fill="#fa7" font-size="9">I3 IF</text> <rect x="219" y="170" width="53" height="18" rx="2" fill="#1a3a5c" stroke="#fa7" stroke-width="1"/> <text x="245" y="182" text-anchor="middle" fill="#fa7" font-size="9">I3 ID</text> <rect x="272" y="170" width="53" height="18" rx="2" fill="#1a3a5c" stroke="#fa7" stroke-width="1"/> <text x="298" y="182" text-anchor="middle" fill="#fa7" font-size="9">I3 EX</text> <rect x="325" y="170" width="53" height="18" rx="2" fill="#1a3a5c" stroke="#fa7" stroke-width="1"/> <text x="351" y="182" text-anchor="middle" fill="#fa7" font-size="9">I3 MA</text> <rect x="378" y="170" width="53" height="18" rx="2" fill="#1a3a5c" stroke="#fa7" stroke-width="1"/> <text x="404" y="182" text-anchor="middle" fill="#fa7" font-size="9">I3 WB</text> <!-- Cycle markers pipelined -->

<text x="60" y="200" text-anchor="middle" fill="#555" font-size="9">0</text> <text x="113" y="200" text-anchor="middle" fill="#555" font-size="9">1</text> <text x="166" y="200" text-anchor="middle" fill="#555" font-size="9">2</text> <text x="219" y="200" text-anchor="middle" fill="#555" font-size="9">3</text> <text x="272" y="200" text-anchor="middle" fill="#555" font-size="9">4</text> <text x="325" y="200" text-anchor="middle" fill="#555" font-size="9">5</text> <text x="378" y="200" text-anchor="middle" fill="#555" font-size="9">6</text> <text x="431" y="200" text-anchor="middle" fill="#555" font-size="9">7</text> </svg>

In the pipelined case, after the pipeline fills, **one instruction completes per clock cycle** in the ideal case — regardless of how many stages exist.

---

### The Classic 5-Stage RISC Pipeline

The canonical pipeline, derived from the MIPS R2000 design, partitions execution into five stages:

<svg viewBox="0 0 640 130" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- Stages --> <rect x="10" y="30" width="100" height="60" rx="4" fill="none" stroke="#7af" stroke-width="1.8"/> <text x="60" y="56" text-anchor="middle" fill="#7af">IF</text> <text x="60" y="72" text-anchor="middle" fill="#aaa" font-size="9">Instruction</text> <text x="60" y="83" text-anchor="middle" fill="#aaa" font-size="9">Fetch</text> <rect x="138" y="30" width="100" height="60" rx="4" fill="none" stroke="#7af" stroke-width="1.8"/> <text x="188" y="56" text-anchor="middle" fill="#7af">ID</text> <text x="188" y="72" text-anchor="middle" fill="#aaa" font-size="9">Instruction</text> <text x="188" y="83" text-anchor="middle" fill="#aaa" font-size="9">Decode</text> <rect x="266" y="30" width="100" height="60" rx="4" fill="none" stroke="#7af" stroke-width="1.8"/> <text x="316" y="56" text-anchor="middle" fill="#7af">EX</text> <text x="316" y="72" text-anchor="middle" fill="#aaa" font-size="9">Execute /</text> <text x="316" y="83" text-anchor="middle" fill="#aaa" font-size="9">Addr Calc</text> <rect x="394" y="30" width="100" height="60" rx="4" fill="none" stroke="#7af" stroke-width="1.8"/> <text x="444" y="56" text-anchor="middle" fill="#7af">MEM</text> <text x="444" y="72" text-anchor="middle" fill="#aaa" font-size="9">Memory</text> <text x="444" y="83" text-anchor="middle" fill="#aaa" font-size="9">Access</text> <rect x="522" y="30" width="100" height="60" rx="4" fill="none" stroke="#7af" stroke-width="1.8"/> <text x="572" y="56" text-anchor="middle" fill="#7af">WB</text> <text x="572" y="72" text-anchor="middle" fill="#aaa" font-size="9">Write</text> <text x="572" y="83" text-anchor="middle" fill="#aaa" font-size="9">Back</text> <!-- Pipeline registers between stages --> <rect x="110" y="38" width="28" height="44" rx="2" fill="#222" stroke="#555" stroke-width="1"/> <text x="124" y="64" text-anchor="middle" fill="#555" font-size="9">IF/ID</text> <rect x="238" y="38" width="28" height="44" rx="2" fill="#222" stroke="#555" stroke-width="1"/> <text x="252" y="64" text-anchor="middle" fill="#555" font-size="9">ID/EX</text> <rect x="366" y="38" width="28" height="44" rx="2" fill="#222" stroke="#555" stroke-width="1"/> <text x="380" y="64" text-anchor="middle" fill="#555" font-size="9">EX/MA</text> <rect x="494" y="38" width="28" height="44" rx="2" fill="#222" stroke="#555" stroke-width="1"/> <text x="508" y="64" text-anchor="middle" fill="#555" font-size="9">MA/WB</text> </svg>

#### Stage Responsibilities

|Stage|Operations|
|---|---|
|**IF**|Fetch instruction from I-cache using PC; increment PC|
|**ID**|Decode opcode; read register file; sign-extend immediate; detect hazards|
|**EX**|ALU operation; effective address computation; branch condition evaluation|
|**MEM**|Read or write D-cache; pass-through for non-memory instructions|
|**WB**|Write result to register file from ALU or memory|

---

### Pipeline Registers

Between each pair of adjacent stages sits a **pipeline register** (latch) clocked on each cycle edge. It holds all values that the downstream stage will need:

|Register|Holds|
|---|---|
|IF/ID|IR (32-bit instruction), PC+4|
|ID/EX|Control signals, RS1 value, RS2 value, immediate, PC+4, destination register|
|EX/MEM|Control signals, ALU result, RS2 value (for stores), branch target, destination register|
|MEM/WB|Control signals, memory read data, ALU result (pass-through), destination register|

The pipeline register ensures each stage sees a stable snapshot of its inputs for the full clock cycle — preventing corruption from upstream changes mid-cycle.

---

### Throughput, Latency, and Speedup

#### Definitions

|Metric|Definition|
|---|---|
|**Latency**|Time to complete a single instruction end-to-end|
|**Throughput**|Instructions completed per unit time|
|**CPI**|Cycles Per Instruction|
|**IPC**|Instructions Per Cycle = 1/CPI|

#### Ideal Pipeline Performance

For a $k$-stage pipeline with clock period $\tau$:

$$\text{Latency}_\text{pipelined} = k \cdot \tau \quad \geq \quad \text{Latency}_\text{unpipelined}$$

$$\text{Throughput}_\text{ideal} = \frac{1}{\tau}$$

Pipelining **increases latency** for any individual instruction (it must traverse all $k$ stages) while **dramatically increasing throughput** by overlapping $k$ instructions simultaneously.

#### Speedup Over Unpipelined

For $n$ instructions through a $k$-stage pipeline, each stage taking $\tau$:

$$T_\text{unpipelined} = n \cdot k \cdot \tau$$

$$T_\text{pipelined} = (k + n - 1) \cdot \tau$$

$$\text{Speedup} = \frac{n \cdot k}{k + n - 1}$$

As $n \to \infty$:

$$\text{Speedup} \to k$$

A $k$-stage pipeline asymptotically approaches $k\times$ speedup. In practice, hazards and stalls prevent achieving this ideal.

#### CPI Decomposition

$$\text{CPI}_\text{actual} = \text{CPI}_\text{ideal} + \text{Stall cycles per instruction}$$

$$\text{CPI}_\text{ideal} = 1 \quad \text{(for a scalar pipeline)}$$

$$\text{CPI}_\text{actual} = 1 + \text{stalls}_\text{data} + \text{stalls}_\text{control} + \text{stalls}_\text{structural}$$

---

### Clock Period and the Critical Path

The clock period is set by the **slowest stage** — the critical path through any single stage's combinational logic plus the pipeline register setup time:

$$\tau = \max_i(t_{\text{stage}_i}) + t_{\text{reg}}$$

Deeper pipelines subdivide stages further, reducing $\tau$ and raising $f_{clk}$ — but diminishing returns arise because:

- Pipeline register overhead $t_{\text{reg}}$ becomes a larger fraction of $\tau$
- Hazard stalls become more expensive (more stages to flush on a branch mispredict)

This is the fundamental **pipeline depth trade-off**.

<svg viewBox="0 0 580 160" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- Axes --> <line x1="60" y1="20" x2="60" y2="130" stroke="#ccc" stroke-width="1.2"/> <line x1="60" y1="130" x2="540" y2="130" stroke="#ccc" stroke-width="1.2"/> <text x="300" y="150" text-anchor="middle" fill="#aaa" font-size="10">Pipeline Depth (stages)</text> <text x="18" y="75" fill="#aaa" font-size="10" transform="rotate(-90,18,75)">Throughput</text> <!-- Curve: rises then flattens/drops -->

<polyline points="60,125 110,90 160,65 220,50 290,42 370,42 450,46 540,55" fill="none" stroke="#7af" stroke-width="2"/>

<!-- Ideal line (dashed) --> <line x1="60" y1="125" x2="540" y2="25" stroke="#444" stroke-width="1.2" stroke-dasharray="5,4"/> <text x="500" y="20" fill="#555" font-size="9">Ideal (∝ depth)</text> <!-- Annotations -->

<text x="300" y="36" fill="#7af" font-size="9">Practical peak</text> <text x="300" y="47" fill="#aaa" font-size="9">(hazard stalls dominate deeper)</text>

<!-- Stage markers -->

<text x="60" y="143" text-anchor="middle" fill="#555" font-size="9">1</text> <text x="160" y="143" text-anchor="middle" fill="#555" font-size="9">5</text> <text x="260" y="143" text-anchor="middle" fill="#555" font-size="9">10</text> <text x="360" y="143" text-anchor="middle" fill="#555" font-size="9">15</text> <text x="460" y="143" text-anchor="middle" fill="#555" font-size="9">20</text> <text x="540" y="143" text-anchor="middle" fill="#555" font-size="9">25</text> </svg>

---

### Pipeline Stages in Real Processors

Modern processors use substantially deeper pipelines than the 5-stage model:

|Processor|Pipeline Depth|Notes|
|---|---|---|
|MIPS R2000|5|The textbook reference design|
|ARM Cortex-A8|13|In-order; dual-issue|
|Intel Pentium 4 (Prescott)|31|Deep pipeline for high clock frequency|
|Intel Core (Skylake)|~14–19|Out-of-order; variable effective depth|
|Apple M-series|~9–16|[Inference] Estimated from public microarchitecture analyses; exact depth not publicly disclosed|

[Inference] Deeper pipelines on Pentium 4 targeted GHz scaling; the Netburst microarchitecture demonstrated that branch misprediction penalties scale with depth, ultimately limiting the approach.

---

### Filling and Draining: Pipeline Latency in Practice

A pipeline of depth $k$ requires $k-1$ cycles to **fill** before the first instruction completes. It requires $k-1$ cycles to **drain** after the last instruction is issued. This is the **pipeline fill penalty**:

```
Cycle:      1    2    3    4    5    6    7    8    9
I1:        IF   ID   EX  MEM   WB
I2:             IF   ID   EX  MEM   WB
I3:                  IF   ID   EX  MEM   WB
I4:                       IF   ID   EX  MEM   WB
I5:                            IF   ID   EX  MEM   WB
                                              ↑
                                    Steady state reached at cycle 5
```

For short code sequences (tight inner loops, interrupt handlers), the fill/drain penalty is significant. For large instruction streams it is amortized to negligible.

---

### Stage-by-Stage Data Flow

The flow of values through pipeline registers for a `LOAD R3, 8(R1)` instruction illustrates what each register must carry:

```
IF stage:
  IR ← MEM[PC]
  PC ← PC + 4
  → IF/ID latches: IR, PC+4

ID stage:
  Decode IR: opcode=LOAD, rs1=R1, rd=R3, imm=8
  ReadReg: A ← RF[R1]
  SignExt: Imm ← sign_extend(8)
  → ID/EX latches: A, Imm, rd=R3, control={MemRead, RegWrite, ...}

EX stage:
  ALUresult ← A + Imm  (= R1 + 8 = effective address)
  → EX/MEM latches: ALUresult, rd=R3, control

MEM stage:
  MDR ← MEM[ALUresult]
  → MEM/WB latches: MDR, rd=R3, control

WB stage:
  RF[R3] ← MDR
```

---

### Throughput Limiting Factors

The ideal CPI of 1 is degraded by three classes of hazard — each imposing stall cycles:

<svg viewBox="0 0 560 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect x="10" y="10" width="540" height="50" rx="4" fill="none" stroke="#ccc" stroke-width="1.2"/> <text x="280" y="40" text-anchor="middle" fill="#ccc" font-size="13">Pipeline Hazards</text> <!-- Three boxes --> <rect x="20" y="80" width="155" height="70" rx="4" fill="none" stroke="#f77" stroke-width="1.5"/> <text x="97" y="103" text-anchor="middle" fill="#f77">Structural</text> <text x="97" y="120" text-anchor="middle" fill="#aaa" font-size="9">Resource conflict</text> <text x="97" y="133" text-anchor="middle" fill="#aaa" font-size="9">(e.g. single memory port)</text> <rect x="200" y="80" width="155" height="70" rx="4" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="277" y="103" text-anchor="middle" fill="#fa7">Data</text> <text x="277" y="120" text-anchor="middle" fill="#aaa" font-size="9">RAW / WAR / WAW</text> <text x="277" y="133" text-anchor="middle" fill="#aaa" font-size="9">dependences</text> <rect x="380" y="80" width="155" height="70" rx="4" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="457" y="103" text-anchor="middle" fill="#7af">Control</text> <text x="457" y="120" text-anchor="middle" fill="#aaa" font-size="9">Branch / jump</text> <text x="457" y="133" text-anchor="middle" fill="#aaa" font-size="9">outcome unknown</text> <!-- Arrows from title box --> <line x1="280" y1="60" x2="97" y2="80" stroke="#555" stroke-width="1" marker-end="url(#ah)"/> <line x1="280" y1="60" x2="277" y2="80" stroke="#555" stroke-width="1" marker-end="url(#ah)"/> <line x1="280" y1="60" x2="457" y2="80" stroke="#555" stroke-width="1" marker-end="url(#ah)"/> <defs> <marker id="ah" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#555"/> </marker> </defs> </svg>

These hazards and their resolution mechanisms — stalling, forwarding, branch prediction — are the primary subject of the subsequent pipeline topics. Their effect on the throughput equation is:

$$\text{Throughput} = \frac{f_{clk}}{\text{CPI}_\text{actual}} = \frac{f_{clk}}{1 + \bar{s}_\text{data} + \bar{s}_\text{control} + \bar{s}_\text{structural}}$$

where $\bar{s}$ denotes the average stall cycles per instruction contributed by each hazard class.

---

### Pipeline Performance Example

**Given:**

- 5-stage pipeline, $f_{clk} = 2,\text{GHz}$ ($\tau = 0.5,\text{ns}$)
- Instruction mix: 25% loads, 15% branches
- Load-use stall: 1 cycle per load (assume 40% of loads followed immediately by a dependent instruction)
- Branch stall: 1 cycle per branch (assume no prediction, always stall)

**CPI calculation:**

$$\text{Load stall cycles/instr} = 0.25 \times 0.40 \times 1 = 0.10$$

$$\text{Branch stall cycles/instr} = 0.15 \times 1 = 0.15$$

$$\text{CPI}_\text{actual} = 1 + 0.10 + 0.15 = 1.25$$

$$\text{Throughput} = \frac{2 \times 10^9}{1.25} = 1.6 \times 10^9 \text{ instructions/sec} = 1.6,\text{GIPS}$$

---

### The Ideal vs. Real Pipeline

|Property|Ideal Pipeline|Real Pipeline|
|---|---|---|
|CPI|1|> 1 (hazard stalls)|
|Stage balance|All stages equal latency|Critical stage bottlenecks clock|
|Instruction latency|$k \cdot \tau$|$k \cdot \tau + $ stall cycles|
|Throughput|$1/\tau$|$< 1/\tau$|
|Speedup vs. unpipelined|$k$|$< k$|

---

### **Key Points**

- Pipelining improves throughput, not single-instruction latency — a pipelined instruction takes longer (more stages) than an unpipelined one.
- The clock period is set by the slowest stage; unbalanced stage latencies waste pipeline potential.
- Ideal CPI of 1 means one instruction completes per cycle once the pipeline is full; hazards push actual CPI above 1.
- Pipeline registers between stages hold all values required by downstream stages, latched on every clock edge.
- Speedup asymptotically approaches the number of stages $k$ for large instruction counts; fill/drain penalties matter only for short sequences.
- Deeper pipelines raise $f_{clk}$ by shortening stage logic, but increase the cost of each stall event and branch misprediction in absolute cycles.
- The three hazard classes — structural, data, control — each contribute additive stall cycles to the CPI equation.

---

### **Example**

**Problem:** Compare unpipelined and 5-stage pipelined execution of 100 instructions. Each stage takes 200 ps; pipeline register overhead is 20 ps.

**Unpipelined:** $$T = 100 \times 5 \times 200,\text{ps} = 100{,}000,\text{ps} = 100,\text{ns}$$

**Pipelined:** $$\tau = 200 + 20 = 220,\text{ps}$$ $$T = (5 + 100 - 1) \times 220,\text{ps} = 104 \times 220 = 22{,}880,\text{ps} \approx 22.9,\text{ns}$$

$$\text{Speedup} = \frac{100{,}000}{22{,}880} \approx 4.37\times$$

The pipeline overhead (20 ps per stage) reduces the theoretical $5\times$ speedup to approximately $4.37\times$. For $n = 10{,}000$ instructions, speedup would approach $4.77\times$ — asymptotically closer to the stage-overhead-limited ceiling of $\frac{200}{220} \times 5 \approx 4.55\times$.

---

### **Conclusion**

Pipelining is the foundational throughput mechanism of processor design. By overlapping instruction execution across $k$ dedicated stages, it converts a serial $k \cdot \tau$ latency per instruction into an asymptotic throughput of one instruction per $\tau$. The 5-stage RISC pipeline — IF, ID, EX, MEM, WB — remains the conceptual baseline from which all modern deeper and wider pipelines are derived. Throughput in practice is bounded by the critical-path stage, the pipeline register overhead, and the stall cycles imposed by structural, data, and control hazards — each of which represents a deviation from the ideal CPI of 1.

---

### **Next Steps**

- **Structural, Data, and Control Hazards** — detailed treatment of each hazard class, detection mechanisms, and the stall logic inserted between stages
- **Data Forwarding / Bypassing** — how result values are routed directly between pipeline stage outputs and inputs to eliminate RAW stall cycles
- **Branch Prediction** — static and dynamic techniques that reduce or eliminate control hazard stalls, the dominant throughput limiter in deep pipelines

---

