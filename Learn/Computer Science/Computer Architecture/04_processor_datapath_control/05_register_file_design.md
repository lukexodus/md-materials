## Register File Design


The register file is the primary high-speed storage structure within the processor datapath, sitting between the instruction decode stage and the execution units. Its design directly constrains instruction throughput, cycle time, and power budget.

---

### Logical Structure

A register file is an array of N registers, each W bits wide, with M read ports and K write ports. For a basic 5-stage RISC pipeline (IF, ID, EX, MEM, WB):

- **2 read ports** — to supply both source operands (rs1, rs2) to the ALU in the same cycle
- **1 write port** — to commit the result from WB

Superscalar processors require proportionally more ports: an N-wide superscalar issuing N instructions per cycle needs up to 2N read ports and N write ports simultaneously.

<svg viewBox="0 0 500 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- Register array --> <rect x="180" y="20" width="140" height="220" rx="4" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.5"/> <text x="250" y="42" text-anchor="middle" fill="#89b4fa" font-size="12" font-weight="bold">Register File</text> <!-- Register rows --> <rect x="190" y="50" width="120" height="18" fill="#313244" stroke="#6c7086" stroke-width="0.8"/> <text x="250" y="63" text-anchor="middle" fill="#cdd6f4">x0 (zero)</text> <rect x="190" y="70" width="120" height="18" fill="#313244" stroke="#6c7086" stroke-width="0.8"/> <text x="250" y="83" text-anchor="middle" fill="#cdd6f4">x1</text> <rect x="190" y="90" width="120" height="18" fill="#313244" stroke="#6c7086" stroke-width="0.8"/> <text x="250" y="103" text-anchor="middle" fill="#cdd6f4">x2</text> <rect x="190" y="110" width="120" height="18" fill="#313244" stroke="#6c7086" stroke-width="0.8"/> <text x="250" y="123" text-anchor="middle" fill="#cdd6f4">x3</text> <text x="250" y="148" text-anchor="middle" fill="#6c7086">⋮</text> <rect x="190" y="155" width="120" height="18" fill="#313244" stroke="#6c7086" stroke-width="0.8"/> <text x="250" y="168" text-anchor="middle" fill="#cdd6f4">x30</text> <rect x="190" y="175" width="120" height="18" fill="#313244" stroke="#6c7086" stroke-width="0.8"/> <text x="250" y="188" text-anchor="middle" fill="#cdd6f4">x31</text> <!-- Read port 1 -->

<text x="60" y="90" text-anchor="middle" fill="#a6e3a1" font-size="10">Read Addr 1</text> <text x="60" y="102" text-anchor="middle" fill="#a6e3a1" font-size="10">(rs1)</text> <line x1="100" y1="95" x2="180" y2="95" stroke="#a6e3a1" stroke-width="1.4"/> <polygon points="175,91 180,95 175,99" fill="#a6e3a1"/>

<!-- Read port 2 -->

<text x="60" y="128" text-anchor="middle" fill="#cba6f7" font-size="10">Read Addr 2</text> <text x="60" y="140" text-anchor="middle" fill="#cba6f7" font-size="10">(rs2)</text> <line x1="100" y1="133" x2="180" y2="133" stroke="#cba6f7" stroke-width="1.4"/> <polygon points="175,129 180,133 175,137" fill="#cba6f7"/>

<!-- Write port -->

<text x="60" y="175" text-anchor="middle" fill="#f38ba8" font-size="10">Write Addr</text> <text x="60" y="187" text-anchor="middle" fill="#f38ba8" font-size="10">(rd) + Data</text> <line x1="100" y1="180" x2="180" y2="180" stroke="#f38ba8" stroke-width="1.4"/> <polygon points="175,176 180,180 175,184" fill="#f38ba8"/>

<!-- Read data outputs --> <line x1="320" y1="95" x2="400" y2="95" stroke="#a6e3a1" stroke-width="1.4"/> <polygon points="395,91 400,95 395,99" fill="#a6e3a1"/> <text x="410" y="99" fill="#a6e3a1" font-size="10">RD1</text> <line x1="320" y1="133" x2="400" y2="133" stroke="#cba6f7" stroke-width="1.4"/> <polygon points="395,129 400,133 395,137" fill="#cba6f7"/> <text x="410" y="137" fill="#cba6f7" font-size="10">RD2</text> <!-- Write enable -->

<text x="250" y="220" text-anchor="middle" fill="#fab387" font-size="10">WE (Write Enable)</text> <line x1="250" y1="240" x2="250" y2="225" stroke="#fab387" stroke-width="1.4"/> <polygon points="246,228 250,223 254,228" fill="#fab387"/> </svg>

---

### Physical Implementation

Register files are implemented as **multi-ported SRAM arrays**. Each additional port requires additional bitline pairs and access transistors per cell.

A standard 6T SRAM cell supports one read/write port. A register file cell with M read ports and K write ports requires:

```
cell transistor count ≈ 4 + 2K + 2M   (approximate)
```

A 2R1W cell requires roughly 8 transistors per bit. A 4R2W cell (for a 2-wide superscalar) requires roughly 12–14 transistors per bit. This scaling has direct consequences for area and leakage power.

**Read operation:** The read address is decoded to assert a wordline. The bitlines for that row are sensed by sense amplifiers and driven to the output.

**Write operation:** The write address decoder asserts the target wordline. Write drivers force the bitlines to the new value, overwriting the stored state.

Both can occur simultaneously as long as they target different rows; same-cycle read-write to the same register requires a forwarding or priority policy (covered below).

---

### Port Scaling Problem

Port count is the central design constraint of register files. Adding ports increases:

- **Area** — quadratically in the naive case, since each port adds wiring to every cell
- **Capacitance** — more bitlines increase load, slowing access
- **Power** — more wordlines and bitlines toggled per access
- **Cycle time** — larger capacitive load on bitlines increases sense amplifier delay

For an aggressive out-of-order processor needing 6–8 read ports and 4 write ports, a monolithic multi-ported register file becomes the timing critical path.

**Mitigations:**

|Technique|Mechanism|Trade-off|
|---|---|---|
|Banking|Split register file into independent banks; route each execution unit to one bank|Bank conflicts stall if two ports need same bank|
|Replication|Maintain multiple identical copies; reads broadcast, writes update all copies|Write bandwidth multiplied; area cost|
|Latch-based cells|Faster than SRAM for small arrays; less dense|Leakage, not suitable for large files|
|Hierarchical files|Small fast file at execution units; larger backing store|Added latency for spills|

Modern out-of-order processors typically use a combination of banking and replication rather than a single monolithic structure.

---

### Architectural vs. Physical Register File

The **architectural register file (ARF)** contains the registers visible to the ISA — 32 registers in RISC-V and MIPS, 16 in ARM32, 16 in x86-64 (with additional hidden state like FLAGS, segment registers).

In an out-of-order processor, the ARF is not what instructions actually read and write. Instead:

- A **physical register file (PRF)** is maintained with more entries than the ARF (e.g., 192 physical registers backing 32 architectural registers in some Intel designs)
- **Register renaming** maps each architectural register name to a physical register at dispatch
- The ARF is reconstructed at commit from the PRF using the retirement register alias table (RAT)

This separation is what enables out-of-order execution without WAR and WAW hazards.

---

### Register Alias Table (RAT)

The RAT (also called the register map table) tracks the mapping from architectural register numbers to physical register numbers.

Two RATs are typically maintained:

**Frontend RAT (speculative):** Updated speculatively at dispatch as each instruction is renamed. Reflects the most recent mapping including instructions still in-flight.

**Retirement RAT (committed):** Updated only when instructions commit in order. Used to restore correct state on branch misprediction or exception.

<svg viewBox="0 0 560 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- Instruction --> <rect x="10" y="80" width="100" height="40" rx="3" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.2"/> <text x="60" y="97" text-anchor="middle" fill="#cdd6f4">ADD x1,</text> <text x="60" y="111" text-anchor="middle" fill="#cdd6f4">x2, x3</text> <!-- Arrow to RAT --> <line x1="110" y1="100" x2="160" y2="100" stroke="#89b4fa" stroke-width="1.2"/> <polygon points="156,96 161,100 156,104" fill="#89b4fa"/> <!-- Frontend RAT --> <rect x="160" y="20" width="120" height="160" rx="3" fill="#1e1e2e" stroke="#fab387" stroke-width="1.2"/> <text x="220" y="38" text-anchor="middle" fill="#fab387" font-weight="bold">Frontend RAT</text> <text x="220" y="55" text-anchor="middle" fill="#6c7086">(speculative)</text> <text x="185" y="75" fill="#a6e3a1">x1 → p47</text> <text x="185" y="92" fill="#cdd6f4">x2 → p31</text> <text x="185" y="109" fill="#cdd6f4">x3 → p28</text> <text x="185" y="126" fill="#cdd6f4">x4 → p12</text> <text x="185" y="143" fill="#6c7086">⋮</text> <text x="185" y="160" fill="#6c7086">x1 renamed → p52</text> <!-- Arrow to PRF --> <line x1="280" y1="100" x2="340" y2="100" stroke="#a6e3a1" stroke-width="1.2"/> <polygon points="336,96 341,100 336,104" fill="#a6e3a1"/> <!-- PRF --> <rect x="340" y="20" width="120" height="160" rx="3" fill="#1e1e2e" stroke="#a6e3a1" stroke-width="1.2"/> <text x="400" y="38" text-anchor="middle" fill="#a6e3a1" font-weight="bold">Phys Reg File</text> <text x="400" y="55" text-anchor="middle" fill="#6c7086">(192 entries)</text> <text x="360" y="75" fill="#cdd6f4">p28: 0x0040</text> <text x="360" y="92" fill="#cdd6f4">p31: 0x0010</text> <text x="360" y="109" fill="#a6e3a1">p47: 0x0050</text> <text x="360" y="126" fill="#cba6f7">p52: (pending)</text> <text x="360" y="143" fill="#6c7086">⋮</text> </svg>

---

### Same-Cycle Read-Write Hazard

When an instruction in the WB stage writes a register that an instruction in the ID stage is reading — within the same cycle — the register file must handle this correctly.

Two approaches:

**Write-first (internal forwarding):** The write data is forwarded directly to the read output within the same cycle if the read and write addresses match. The register file itself detects the conflict and muxes the write data onto the read port output. Transparent to the pipeline.

**Read-old-value:** The register file completes the read before the write takes effect. The pipeline handles forwarding externally via the hazard unit.

Most implementations use write-first since it simplifies the forwarding network.

---

### Hardwired Zero Register

RISC architectures commonly dedicate one register as a hardwired constant zero (x0 in RISC-V, r0 in MIPS, xzr/wzr in AArch64).

Implementation: the zero register cell has its output tied to ground — no actual storage. Write operations targeting x0 are silently discarded (write enable for that row is never asserted). This simplifies instruction encoding by eliminating the need for a separate "load immediate zero" instruction and enables idioms like:

```
mv  x5, x0      ; copy zero → x5 (pseudoinstruction for ADDI x5, x0, 0)
beq x3, x0, L   ; branch if x3 == 0
```

---

### Reset and Initialization

Register files do not require power-on reset for functional correctness in most architectures — the ISA does not guarantee initial register values. However:

- Some embedded and safety-critical architectures require defined reset state (all zeros) to prevent information leakage between security contexts
- On context switch, registers are saved to memory and restored — the register file is treated as caller/callee state per ABI, not as persistent storage

---

### Multiported vs. Banked Trade-off in Superscalar

For an N-wide out-of-order processor, the naive monolithic register file with 2N read ports and N write ports becomes impractical beyond N=4 due to area and timing costs. The common alternative:

**Distributed/banked register file:**

Each functional unit (integer ALU, FP ALU, load/store unit) has a small local register file containing only the registers it needs. Values are broadcast from a central file or copied at dispatch. Results are written locally and broadcast back.

This trades **bandwidth** for **locality** — acceptable because most instructions only use values produced recently (covered by forwarding), and long-lived values can be fetched once and held locally.

Intel's P6 microarchitecture and its descendants use a unified physical register file. AMD's earlier designs used separate integer and FP register files to reduce porting requirements on each.

---

### Floating-Point and SIMD Register Files

Most ISAs maintain separate register files for different data types:

|File|ISA Examples|Width|
|---|---|---|
|Integer GPR|x0–x31 (RISC-V)|32 or 64 bits|
|Float|f0–f31 (RISC-V F/D ext.)|32 or 64 bits|
|SIMD/Vector|v0–v31 (AArch64 NEON)|128 bits|
|AVX-512 (x86)|zmm0–zmm31|512 bits|

AVX-512's 32 × 512-bit register file is 2048 bytes of storage per logical core — a non-trivial area and power commitment. Activating AVX-512 instructions on some Intel cores historically caused frequency throttling due to the associated power spike in the register file and execution units.

---

### Timing and Critical Path

Register file access typically occupies the **ID stage** (read) and **WB stage** (write) in a simple 5-stage pipeline. The read path — address decode → wordline assert → bitline discharge → sense amplify → output — must complete within one clock period.

For high-frequency designs, the register file access time is a significant contributor to the minimum achievable clock period, often second only to the ALU or cache access in the critical path. Design techniques to reduce access time:

- **Sense amplifier optimization** — low-swing differential sensing reduces bitline swing requirements
- **Predecoding** — part of the address decode is done in the previous cycle, reducing in-cycle decode delay
- **Small physical array** — keeping the register file small (fewer rows, fewer columns) reduces wordline and bitline RC delay

---

**Key Points**

- Port count is the dominant cost driver in register file design — area, power, and cycle time all scale super-linearly with port count
- The architectural register file and the physical register file are distinct in any out-of-order processor; the RAT mediates the mapping and is the mechanism that enables register renaming
- Hardwired zero registers cost nothing in storage — the cell output is grounded and writes are suppressed
- Write-first (internal forwarding) within the register file resolves same-cycle read-write conflicts transparently to the pipeline
- Banked and replicated register file organizations are practical mitigations for the port scaling problem in wide superscalar designs
- SIMD register file width (up to 512 bits per register in AVX-512) creates measurable power and frequency implications that pure logical design does not capture

---

