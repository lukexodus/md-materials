## Memory Technologies


Memory technologies differ across a fundamental set of physical and electrical trade-offs: how a bit is stored, how it is read and written, whether it retains state without power, how densely it can be fabricated, and what access latency and bandwidth it delivers. Each technology occupies a distinct position in the memory hierarchy precisely because no single technology optimizes all of these dimensions simultaneously.

---

### Fundamental Storage Mechanisms

Before examining each technology, the underlying physical mechanisms for storing a binary value reduce to three categories:

|Mechanism|How bit is stored|Volatile?|Example|
|---|---|---|---|
|Bistable circuit|Feedback loop holds logic level|Yes|SRAM|
|Charge on capacitor|Presence/absence of charge|Yes|DRAM|
|Charge in floating gate|Trapped electrons in oxide|No|Flash, EEPROM|
|Mask pattern|Physical doping or connection|No|Mask ROM|
|Fuse/antifuse|Physical open or short circuit|No|OTP ROM, PROM|

---

### SRAM — Static Random Access Memory

#### Storage Cell

An SRAM cell stores one bit using a **cross-coupled inverter pair** — two inverters wired so that the output of each drives the input of the other, forming a bistable latch. Two access transistors connect the cell to complementary bitlines (BL and BL̄):

<svg viewBox="0 0 580 300" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="580" height="300" fill="#0d1117"/> <text x="195" y="26" fill="#f0f6fc" font-size="13" font-weight="bold">SRAM 6T Cell</text> <!-- Wordline --> <line x1="60" y1="80" x2="520" y2="80" stroke="#e3b341" stroke-width="2"/> <text x="220" y="70" fill="#e3b341">Wordline (WL)</text> <!-- Left access transistor (M5) --> <rect x="100" y="95" width="60" height="30" fill="#1c2d40" stroke="#79c0ff" stroke-width="1.5" rx="2"/> <text x="108" y="114" fill="#79c0ff">M5 (nMOS)</text> <line x1="130" y1="80" x2="130" y2="95" stroke="#e3b341" stroke-width="1.5"/> <!-- Right access transistor (M6) --> <rect x="420" y="95" width="60" height="30" fill="#1c2d40" stroke="#79c0ff" stroke-width="1.5" rx="2"/> <text x="428" y="114" fill="#79c0ff">M6 (nMOS)</text> <line x1="450" y1="80" x2="450" y2="95" stroke="#e3b341" stroke-width="1.5"/> <!-- Left inverter (M1, M3) --> <rect x="160" y="130" width="100" height="50" fill="#21362d" stroke="#3fb950" stroke-width="1.5" rx="3"/> <text x="175" y="152" fill="#3fb950">INV-L</text> <text x="165" y="170" fill="#8b949e">(M1 pMOS +</text> <text x="165" y="183" fill="#8b949e"> M3 nMOS)</text> <!-- Right inverter (M2, M4) --> <rect x="320" y="130" width="100" height="50" fill="#21362d" stroke="#3fb950" stroke-width="1.5" rx="3"/> <text x="335" y="152" fill="#3fb950">INV-R</text> <text x="325" y="170" fill="#8b949e">(M2 pMOS +</text> <text x="325" y="183" fill="#8b949e"> M4 nMOS)</text> <!-- Q node (left) --> <line x1="160" y1="155" x2="130" y2="155" stroke="#56d364" stroke-width="1.5"/> <line x1="130" y1="125" x2="130" y2="155" stroke="#56d364" stroke-width="1.5"/> <line x1="130" y1="125" x2="100" y2="125" stroke="#56d364" stroke-width="1.5"/> <!-- Q node connects to right inverter input --> <line x1="260" y1="155" x2="290" y2="155" stroke="#56d364" stroke-width="1.5"/> <line x1="290" y1="155" x2="320" y2="155" stroke="#56d364" stroke-width="1.5"/> <circle cx="290" cy="155" r="4" fill="#56d364"/> <text x="268" y="148" fill="#56d364">Q</text> <!-- Q̄ node (right) --> <line x1="320" y1="155" x2="290" y2="155" stroke="#ff7b72" stroke-width="1.5"/> <line x1="420" y1="155" x2="450" y2="155" stroke="#ff7b72" stroke-width="1.5"/> <line x1="450" y1="125" x2="450" y2="155" stroke="#ff7b72" stroke-width="1.5"/> <line x1="450" y1="125" x2="480" y2="125" stroke="#ff7b72" stroke-width="1.5"/> <circle cx="450" cy="155" r="4" fill="#ff7b72"/> <text x="425" y="148" fill="#ff7b72">Q̄</text> <!-- Cross-coupling arrows --> <path d="M 260 140 Q 290 110 320 140" fill="none" stroke="#8b949e" stroke-width="1" stroke-dasharray="4,3" marker-end="url(#ma)"/> <!-- BL and BL̄ --> <line x1="100" y1="95" x2="100" y2="240" stroke="#d2a8ff" stroke-width="1.5"/> <line x1="130" y1="125" x2="130" y2="125" stroke="#d2a8ff" stroke-width="1"/> <text x="78" y="250" fill="#d2a8ff">BL</text> <line x1="480" y1="95" x2="480" y2="240" stroke="#d2a8ff" stroke-width="1.5"/> <text x="475" y="250" fill="#d2a8ff">BL̄</text> <!-- VDD --> <line x1="210" y1="100" x2="210" y2="130" stroke="#f0f6fc" stroke-width="1.5"/> <line x1="370" y1="100" x2="370" y2="130" stroke="#f0f6fc" stroke-width="1.5"/> <text x="196" y="95" fill="#f0f6fc">VDD</text> <text x="356" y="95" fill="#f0f6fc">VDD</text> <!-- GND --> <line x1="210" y1="180" x2="210" y2="220" stroke="#f0f6fc" stroke-width="1.5"/> <line x1="200" y1="220" x2="220" y2="220" stroke="#f0f6fc" stroke-width="1.5"/> <line x1="203" y1="226" x2="217" y2="226" stroke="#f0f6fc" stroke-width="1"/> <line x1="207" y1="232" x2="213" y2="232" stroke="#f0f6fc" stroke-width="0.8"/> <line x1="370" y1="180" x2="370" y2="220" stroke="#f0f6fc" stroke-width="1.5"/> <line x1="360" y1="220" x2="380" y2="220" stroke="#f0f6fc" stroke-width="1.5"/> <line x1="363" y1="226" x2="377" y2="226" stroke="#f0f6fc" stroke-width="1"/> <line x1="367" y1="232" x2="373" y2="232" stroke="#f0f6fc" stroke-width="0.8"/> <!-- Label -->

<text x="30" y="280" fill="#8b949e" font-size="10">6 transistors: 2 access (M5,M6) + 2 pull-up pMOS (M1,M2) + 2 pull-down nMOS (M3,M4)</text>

<defs> <marker id="ma" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#8b949e"/> </marker> </defs> </svg>

The standard cell is called **6T SRAM**: 4 transistors form the two inverters (2 pMOS pull-ups + 2 nMOS pull-downs), and 2 nMOS access transistors gate access to the bitlines.

#### Read Operation

1. Both bitlines are **precharged** to VDD before the read
2. The wordline is asserted (WL → high), turning on M5 and M6
3. The side holding logic 0 (e.g., Q = 0) discharges its bitline slightly
4. A **sense amplifier** detects the small differential voltage (ΔV ≈ 100–200 mV) and amplifies it to full rail in ~1 ns
5. The wordline is deasserted

The cell is designed so that the pull-down transistors (M3/M4) are **stronger** than the access transistors (M5/M6), preventing a read from inadvertently flipping the stored value (read upset stability).

#### Write Operation

1. A write driver forces one bitline to VDD and the other to GND
2. The wordline is asserted
3. The access transistors must **overpower** the feedback inverters, forcing the cell to the new state
4. Access transistors are sized stronger than pull-up transistors to enable write-ability

#### Variants

|Variant|Transistors|Purpose|
|---|---|---|
|6T|6|Standard; balance of area, stability, speed|
|4T|4|Replace pMOS with poly resistors; smaller area, leakier|
|8T|8|Separate read/write ports; eliminates read upset risk|
|10T|10|Ultra-low voltage operation (sub-threshold SRAM)|
|Dual-port|8–12|Two simultaneous independent accesses (register files)|

#### Electrical Characteristics

SRAM speed and stability are characterized by:

- **Cell Ratio (CR)** — ratio of pull-down to access transistor strength; must be >1 for read stability (typically CR = 1.5–2)
- **Pull-up Ratio (PR)** — ratio of pull-up to access transistor strength; must be <1 for write-ability
- **Static Noise Margin (SNM)** — maximum DC noise voltage the cell can tolerate without flipping; measured as the side length of the largest square fitting inside the butterfly curve of the two inverter VTCs

#### SRAM in the Memory Hierarchy

SRAM is used exclusively where speed and unlimited read/write endurance are required and area/cost can be justified:

|Application|Typical capacity|Typical access time|
|---|---|---|
|Register file|128 B – 4 KB|0.2–0.5 ns|
|L1 cache (data)|32–64 KB|1–3 ns|
|L2 cache|256 KB – 2 MB|3–10 ns|
|L3 cache|4–64 MB|10–40 ns|
|TLB|64–2048 entries|<1 ns|

---

### DRAM — Dynamic Random Access Memory

#### Storage Cell

A DRAM cell stores one bit as **charge on a capacitor**, accessed through a single access transistor. The canonical structure is the **1T1C cell**:

```
         Wordline (WL)
              │
         ┌────┴────┐
         │  nMOS   │  ← access transistor
         └────┬────┘
              │
Bitline ──────┤
              │
           ┌──┴──┐
           │  C  │  ← storage capacitor (~10–30 fF)
           └──┬──┘
              │
             GND
```

The capacitor stores charge (Q ≈ CV) to represent logic 1, and absence of charge for logic 0. One transistor + one capacitor per bit gives a **much smaller cell area** than SRAM — approximately 6–8F² vs. 50–150F² (where F is the minimum feature size). This density advantage makes DRAM the technology of choice for main memory.

#### The Refresh Problem

A capacitor is not a perfect storage element — charge leaks through the transistor's subthreshold current and through oxide leakage. The stored charge decays with a time constant on the order of milliseconds. To prevent data loss, every DRAM row must be **refreshed** — read and rewritten — periodically.

Modern DRAM requires refresh every **64 ms** (specified by JEDEC). During a refresh, a row is activated (read), the sense amplifiers restore the charge, and the row is closed. All rows must be refreshed within the 64 ms window:

$$\text{Refresh rate} = \frac{\text{row count}}{\text{refresh interval}} = \frac{65536 \text{ rows}}{64 \text{ ms}} \approx 1024 \text{ rows/ms}$$

Refresh consumes bus bandwidth and power during which the memory cannot serve regular requests.

#### Access Sequence and Timing

DRAM is accessed in a strict sequence involving row and column addresses:

```
1. RAS↓  — Row Address Strobe: selects and opens a row (activates entire row into sense amps)
2. tRCD  — delay: RAS to CAS delay (row to column delay, ~10–15 ns)
3. CAS↓  — Column Address Strobe: selects specific columns from open row
4. CL    — CAS Latency: delay between column select and data appearing (~14–19 ns at DDR4)
5. Data  — burst of data transferred
6. tRP   — Precharge: close row, restore bitlines (~10–15 ns)
7. tRAS  — minimum row active time before precharge
```

Key DRAM timing parameters:

|Parameter|Symbol|Meaning|DDR4-3200 example|
|---|---|---|---|
|RAS to CAS delay|tRCD|Time to open row|15–16 ns|
|CAS latency|CL|Read latency after column select|14–18 ns|
|Row precharge|tRP|Time to close row|15 ns|
|Row active time|tRAS|Minimum open row time|35 ns|
|Row cycle time|tRC|tRAS + tRP|50 ns|
|Refresh cycle|tREFI|Interval between refreshes of same row|7.8 µs|

Total **first-access latency** (row miss) = tRCD + CL ≈ 30–35 ns for DDR4. Subsequent accesses to the same open row (row hits) incur only CL.

#### Destructive Read and Sense Amplifier

Reading a DRAM cell is **destructive**: connecting the capacitor to the bitline shares the charge between the capacitor and the bitline's parasitic capacitance, reducing the stored voltage:

$$V_\text{BL} = V_\text{DD} \times \frac{C_\text{cell}}{C_\text{cell} + C_\text{BL}} \approx 100\text{–}200 \text{ mV}$$

The sense amplifier detects this small perturbation and **regenerates** the full voltage, restoring the cell. This is why every DRAM read also writes back data — the read itself consumes the stored charge.

#### DRAM Organization

```
DIMM
 └── Rank (one side of DIMM)
      └── Chip (×8 organization: 8 chips × 8 bits = 64-bit bus)
           └── Bank (independent row/column matrix, typically 16 per chip)
                └── Row (typically 65536 rows)
                     └── Column (typically 1024–2048 columns)
```

**Banks** allow pipelining: while one bank is being precharged (tRP), another can be activated. A memory controller exploits multiple banks to hide latency.

**Ranks** allow higher capacity — multiple chips share a bus but are selected individually via chip select.

---

### Flash Memory

Flash memory stores charge in the **floating gate** of a specialized MOSFET, isolated from both the gate and channel by silicon dioxide layers. Trapped electrons shift the transistor's threshold voltage, encoding a logic value that persists without power.

#### Cell Structure: Floating Gate vs. Charge Trap

**Floating Gate (FG) MOSFET** — the original flash cell:

```
      Control Gate (CG)  ← externally accessible gate
           │
     ══════╪══════   ← tunnel oxide (top)
           │
      Floating Gate     ← electrically isolated conductor; stores charge
           │
     ══════╪══════   ← tunnel oxide (bottom, ~7–10 nm SiO₂)
           │
     ├─────┴──────┤
     │  n+  ch  n+ │  ← source, channel, drain in p-substrate
     └────────────┘
```

**Charge Trap Flash (CTF)** — used in modern 3D NAND:

Instead of a conductive floating gate, charge is trapped in a **dielectric layer** (silicon nitride, Si₃N₄). CTF allows thinner inter-cell isolation, enabling vertical stacking (3D NAND).

#### Programming and Erasure

|Operation|Mechanism|Voltage|Duration|
|---|---|---|---|
|Program (write 0)|Fowler-Nordheim tunneling or hot-electron injection forces electrons onto floating gate|15–20 V|~100 µs/page|
|Erase (write 1)|Fowler-Nordheim tunneling removes electrons from floating gate|15–20 V|~2 ms/block|
|Read|Sense amplifier detects whether cell conducts at read voltage|0–5 V|~25–100 µs/page|

**Critical asymmetry**: erase operates on an entire **block** (typically 128–512 pages, each 4–16 KB). Individual pages can be programmed but not individually erased. This has profound implications for flash storage systems — a write to one byte requires reading an entire block, erasing it, modifying the target page, and reprogramming the entire block. Flash Translation Layers (FTLs) exist entirely to manage this asymmetry.

#### Bit-per-Cell Encoding

The number of threshold voltage levels determines how many bits are stored per cell:

|Type|Levels|Bits/cell|Density|Endurance|Read speed|
|---|---|---|---|---|---|
|SLC (Single Level Cell)|2|1|Low|~100,000 P/E|Fastest|
|MLC (Multi Level Cell)|4|2|2× SLC|~3,000–10,000 P/E|Fast|
|TLC (Triple Level Cell)|8|3|3× SLC|~300–1,000 P/E|Moderate|
|QLC (Quad Level Cell)|16|4|4× SLC|~100–300 P/E|Slowest|
|PLC (Penta Level Cell)|32|5|5× SLC|<100 P/E|Very slow|

The voltage margin between adjacent threshold levels shrinks as more levels are packed in, increasing susceptibility to noise, retention loss, and read disturb. QLC and PLC require sophisticated error correction (LDPC codes) to maintain data integrity.

#### NAND vs. NOR Flash

|Property|NAND Flash|NOR Flash|
|---|---|---|
|Cell arrangement|Series string (8–32 cells)|Individual cell with own source/drain contacts|
|Array density|Very high|Moderate|
|Read access|Page-sequential; slow random|Random access, byte-addressable|
|Read latency|~25–100 µs (page)|~70–100 ns (random byte)|
|Write latency|~100–200 µs (page)|~5–100 µs (byte/word)|
|Erase unit|Block (128KB–4MB)|Sector (64KB–128KB)|
|Endurance|Lower|Higher|
|Primary use|Mass storage (SSDs, eMMC)|Code execution (MCU firmware, BIOS)|

NOR flash supports **execute-in-place (XIP)**: the CPU can fetch instructions directly from the flash address space without copying to RAM, critical for embedded systems with tight memory budgets.

#### 3D NAND

Planar NAND scaling below ~15 nm becomes unreliable due to inter-cell interference and reduced electron counts. **3D NAND** stacks cell layers vertically rather than shrinking horizontally:

```
Layer N:    ─ ─ ─ ─ ─ ─ ─ ─   (WL plane)
Layer N-1:  ─ ─ ─ ─ ─ ─ ─ ─
   ...
Layer 1:    ─ ─ ─ ─ ─ ─ ─ ─
            │ │ │ │ │ │ │ │   ← vertical channel (poly-Si pillar)
            └─┴─┴─┴─┴─┴─┴─┘  ← source line
```

Each intersection of a wordline plane and a vertical channel pillar forms one CTF cell. Modern 3D NAND reaches 176–238 layers (Micron, Samsung, SK Hynix), achieving densities of 1–4 Tb per die.

---

### ROM — Read-Only Memory

ROM stores data by permanently encoding it during or after fabrication. The "read-only" designation is historical — modern variants allow varying degrees of post-fabrication modification.

#### Mask ROM

The oldest form: bit values are encoded by the **physical presence or absence of a transistor** at each cell location, defined by the photolithographic mask used during fabrication.

```
Wordline selects a row. Column bitline:
  - If transistor present → cell pulls bitline low → reads 0
  - If transistor absent  → bitline stays high   → reads 1
```

Mask ROM has the **smallest cell area** of any memory technology (as small as 4F²) and is fully passive (no capacitor, no floating gate). It is non-volatile, zero-power in standby, and extremely fast for reads. The fatal limitation: the data is fixed at tape-out. Any change requires a new mask set ($500K–$2M+). Mask ROM is used in high-volume, data-immutable applications: bootloader microcode in RISC processors, font tables in printers, game cartridges in legacy consoles.

#### PROM — Programmable ROM

PROM uses **nichrome or polysilicon fuses** (or antifuses) that can be blown once after fabrication:

- **Fuse-based**: All cells start as 1 (intact fuse = conducting). Programming blows selected fuses to 0 (open circuit). Irreversible.
- **Antifuse-based**: All cells start as 0 (intact antifuse = insulating). Programming applies high voltage to create a permanent short (1). Irreversible.

PROM is used in field-programmable logic devices (older FPGAs), security key storage, and device trimming. One-time programmable (OTP) is the modern term.

#### EPROM — Erasable PROM

EPROM introduced the floating gate. Cells are programmed by hot-electron injection. Erasure is accomplished by exposing the chip to **UV light** (typically 254 nm, ~30 minutes) through a quartz window on the package, which provides enough photon energy to excite trapped electrons off the floating gate uniformly across all cells.

EPROM is largely obsolete — EEPROM and flash eliminated the requirement for UV exposure and package windows.

#### EEPROM — Electrically Erasable PROM

EEPROM extends EPROM by adding a thin tunnel oxide layer that allows electrical erasure via Fowler-Nordheim tunneling. **Individual bytes** can be erased and rewritten without UV light:

```
Cell structure: 2T — floating gate transistor + select transistor
Erase: high voltage on control gate drives electrons off floating gate
Write: high voltage on drain injects electrons onto floating gate
```

EEPROM supports byte-level erase/write but at a cost: the 2T cell is twice the area of a NOR flash cell, limiting density. Endurance is typically 100,000–1,000,000 cycles. EEPROM is used for small, critical non-volatile storage: configuration registers, calibration data, serial numbers, smart card state.

---

### Comparative Analysis

#### Technology Scaling and Cell Geometry

<svg viewBox="0 0 680 300" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="300" fill="#0d1117"/> <text x="200" y="26" fill="#f0f6fc" font-size="13" font-weight="bold">Memory Technology Trade-off Space</text> <!-- Axes --> <line x1="80" y1="260" x2="640" y2="260" stroke="#58a6ff" stroke-width="1.5" marker-end="url(#mb)"/> <line x1="80" y1="260" x2="80" y2="40" stroke="#58a6ff" stroke-width="1.5" marker-end="url(#mb)"/> <text x="300" y="288" fill="#8b949e">Access Speed (faster →)</text> <text x="14" y="190" fill="#8b949e" transform="rotate(-90,14,190)">Density (denser →)</text> <!-- Grid --> <line x1="80" y1="210" x2="640" y2="210" stroke="#21262d" stroke-width="1"/> <line x1="80" y1="160" x2="640" y2="160" stroke="#21262d" stroke-width="1"/> <line x1="80" y1="110" x2="640" y2="110" stroke="#21262d" stroke-width="1"/> <line x1="200" y1="40" x2="200" y2="260" stroke="#21262d" stroke-width="1"/> <line x1="340" y1="40" x2="340" y2="260" stroke="#21262d" stroke-width="1"/> <line x1="480" y1="40" x2="480" y2="260" stroke="#21262d" stroke-width="1"/> <line x1="590" y1="40" x2="590" y2="260" stroke="#21262d" stroke-width="1"/> <!-- QLC/TLC NAND Flash --> <ellipse cx="140" cy="80" rx="48" ry="22" fill="#d29922" opacity="0.25" stroke="#e3b341" stroke-width="1.5"/> <text x="108" y="77" fill="#e3b341" font-size="11" font-weight="bold">TLC/QLC</text> <text x="112" y="91" fill="#e3b341" font-size="10">NAND Flash</text> <!-- SLC NAND --> <ellipse cx="200" cy="130" rx="42" ry="20" fill="#d29922" opacity="0.2" stroke="#e3b341" stroke-width="1.2"/> <text x="170" y="127" fill="#e3b341" font-size="10">SLC NAND</text> <text x="170" y="141" fill="#e3b341" font-size="10">Flash</text> <!-- NOR Flash --> <ellipse cx="330" cy="170" rx="50" ry="20" fill="#d29922" opacity="0.15" stroke="#e3b341" stroke-width="1"/> <text x="298" y="167" fill="#e3b341" font-size="10">NOR Flash</text> <text x="292" y="181" fill="#e3b341" font-size="10">(byte random)</text> <!-- DRAM --> <ellipse cx="430" cy="185" rx="50" ry="20" fill="#388bfd" opacity="0.25" stroke="#79c0ff" stroke-width="1.5"/> <text x="400" y="182" fill="#79c0ff" font-size="11" font-weight="bold">DRAM</text> <text x="400" y="196" fill="#79c0ff" font-size="10">1T1C, moderate</text> <!-- SRAM --> <ellipse cx="580" cy="220" rx="50" ry="22" fill="#3fb950" opacity="0.2" stroke="#56d364" stroke-width="1.5"/> <text x="552" y="217" fill="#56d364" font-size="11" font-weight="bold">SRAM</text> <text x="542" y="231" fill="#56d364" font-size="10">6T, fastest, largest</text> <!-- Mask ROM --> <ellipse cx="480" cy="130" rx="42" ry="18" fill="#d2a8ff" opacity="0.2" stroke="#d2a8ff" stroke-width="1"/> <text x="452" y="127" fill="#d2a8ff" font-size="10">Mask ROM</text> <text x="452" y="141" fill="#d2a8ff" font-size="10">4F², read-only</text> <!-- Volatility annotation --> <rect x="82" y="42" width="80" height="16" fill="#2d1a1a" rx="2"/> <text x="90" y="53" fill="#ff7b72" font-size="9">← Non-volatile</text> <rect x="490" y="42" width="64" height="16" fill="#21362d" rx="2"/> <text x="494" y="53" fill="#56d364" font-size="9">Volatile →</text> <defs> <marker id="mb" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#58a6ff"/> </marker> </defs> </svg>

#### Quantitative Comparison

|Property|SRAM|DRAM|NOR Flash|NAND Flash (TLC)|Mask ROM|
|---|---|---|---|---|---|
|Cell size|~50–150 F²|~6–8 F²|~10 F²|~4–5 F² (3D)|~4 F²|
|Bits/cell|1|1|1–2|3–4|1|
|Read latency|0.2–5 ns|30–70 ns (DRAM row miss)|70–100 ns|25–100 µs/page|5–20 ns|
|Write latency|0.2–5 ns|30–70 ns|5–100 µs|100–200 µs/page|N/A|
|Erase latency|N/A|N/A|~1 ms/sector|~2 ms/block|N/A|
|Erase granularity|Bit|Row (with refresh)|Sector (~64 KB)|Block (~256 KB)|N/A|
|Volatile|Yes|Yes|No|No|No|
|Endurance (cycles)|Unlimited|Unlimited|~100,000|~300–10,000|Unlimited (read)|
|Standby power|Low (leakage)|Moderate (refresh)|Near-zero|Near-zero|Zero|
|Typical use|Caches, RF|Main memory|Firmware, XIP|SSDs, eMMC|Microcode, game ROMs|

---

### Emerging Memory Technologies

Several technologies seek to combine DRAM's speed with flash's non-volatility:

|Technology|Mechanism|Status|Latency|Endurance|
|---|---|---|---|---|
|**PCM** (Phase Change Memory)|Crystalline vs. amorphous phase of chalcogenide|Production (Intel Optane)|~100 ns|~10⁷ cycles|
|**STT-MRAM** (Spin-Transfer Torque)|Magnetic tunnel junction resistance state|Production (embedded NVM)|~10 ns|~10¹² cycles|
|**FeRAM** (Ferroelectric RAM)|Polarization direction of ferroelectric material|Production (low-density)|~50 ns|~10¹⁴ cycles|
|**RRAM / ReRAM** (Resistive RAM)|Conductive filament formation in oxide|Research/early production|~10 ns|~10⁶–10⁹ cycles|

Intel's **Optane** (3D XPoint, based on PCM + ovonic switch) was deployed as a DRAM-adjacent persistent memory tier (Optane DIMM) and as NVMe SSDs. It offered byte-addressability and sub-microsecond latency — positioning it between DRAM and NAND in the hierarchy. Intel discontinued Optane in 2022 due to cost and ecosystem challenges, but the technology remains significant as a proof-of-concept for storage-class memory (SCM).

---

### Memory Hierarchy Positioning

```
                        Latency          Bandwidth       Capacity
                        ───────          ─────────       ────────
Register file       │ 0.2–0.5 ns   │  ~10 TB/s       │  KB
─────────────────── │              │                  │
L1 SRAM cache       │ 1–3 ns       │  ~1–4 TB/s      │  32–64 KB
L2 SRAM cache       │ 3–10 ns      │  ~500 GB/s      │  256 KB–2 MB
L3 SRAM cache       │ 10–40 ns     │  ~200–500 GB/s  │  4–64 MB
─────────────────── │              │                  │
DRAM main memory    │ 50–100 ns    │  ~50–100 GB/s   │  GB–TB
─────────────────── │              │                  │
NVMe SSD (NAND)     │ 50–200 µs    │  ~5–15 GB/s     │  TB
SATA SSD            │ 100–500 µs   │  ~500 MB/s      │  TB
─────────────────── │              │                  │
HDD                 │ 5–10 ms      │  ~200 MB/s      │  TB–PB
```

Each tier is 10–1000× slower than the one above it. The memory hierarchy exists precisely because no single technology can simultaneously provide the speed of SRAM, the density of NAND flash, and the non-volatility of ROM at reasonable cost.

---

**Conclusion** SRAM's bistable latch delivers the lowest latency and unlimited endurance at the cost of six transistors per bit, making it viable only for small, speed-critical structures. DRAM's 1T1C cell achieves the density required for gigabyte-scale main memory but demands continuous refresh and tolerates only moderate latency. Flash memory's floating-gate or charge-trap cells deliver non-volatile, dense storage at the cost of high write latency, limited endurance, and coarse erase granularity — properties that have driven entire system software subsystems (FTLs, wear-leveling algorithms, log-structured file systems) into existence to manage them. ROM variants represent the limit of simplicity and permanence, sacrificing writability entirely for density, speed, and zero standby power. The interaction between these technologies — their placement in the hierarchy, the protocols that bridge their latency gaps, and the software abstractions built to hide their differences — constitutes the foundational challenge of memory system design.

**Next Steps** Proceed to **Locality of Reference** to examine the behavioral principle that makes the memory hierarchy effective: why programs exhibit spatial and temporal locality, how caches exploit it, and how to quantify the impact of locality on system performance.

---

