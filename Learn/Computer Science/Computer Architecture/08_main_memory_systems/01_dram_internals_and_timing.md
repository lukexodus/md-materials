## DRAM Internals and Timing


Dynamic Random Access Memory is the dominant technology for main memory in general-purpose computing systems. The word _dynamic_ distinguishes it from static RAM (SRAM): each bit is stored as a charge on a capacitor rather than in a stable flip-flop, and that charge leaks over time and must be periodically refreshed. This storage mechanism enables extremely high bit density — a single transistor and capacitor per bit versus six transistors per bit in SRAM — at the cost of access complexity, latency, and the overhead of refresh.

---

### The DRAM Cell

The fundamental storage element is a **1T1C cell**: one access transistor and one storage capacitor.

<svg viewBox="0 0 500 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <defs> <marker id="d1" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#78909c"/> </marker> </defs> <!-- Wordline --> <line x1="50" y1="80" x2="420" y2="80" stroke="#fff59d" stroke-width="1.5"/> <text x="430" y="84" fill="#fff59d" font-size="11">Wordline (WL)</text> <!-- Bitline --> <line x1="200" y1="20" x2="200" y2="240" stroke="#4fc3f7" stroke-width="1.5"/> <text x="206" y="18" fill="#4fc3f7" font-size="11">Bitline (BL)</text> <!-- Transistor body --> <rect x="170" y="90" width="60" height="30" rx="3" fill="#263238" stroke="#546e7a" stroke-width="1.2"/> <text x="200" y="110" text-anchor="middle" fill="#90a4ae" font-size="11">NMOS</text> <!-- Gate connection from WL --> <line x1="170" y1="105" x2="50" y2="105" stroke="#fff59d" stroke-width="1"/> <line x1="50" y1="80" x2="50" y2="105" stroke="#fff59d" stroke-width="1"/> <!-- Source → BL (up) --> <line x1="200" y1="90" x2="200" y2="60" stroke="#4fc3f7" stroke-width="1.2"/> <!-- Drain → capacitor (down) --> <line x1="200" y1="120" x2="200" y2="150" stroke="#90a4ae" stroke-width="1.2"/> <!-- Capacitor plates --> <line x1="160" y1="150" x2="240" y2="150" stroke="#a5d6a7" stroke-width="2.5"/> <line x1="160" y1="165" x2="240" y2="165" stroke="#a5d6a7" stroke-width="2.5"/> <!-- Capacitor label --> <text x="255" y="162" fill="#a5d6a7" font-size="11">C (storage)</text> <!-- Bottom of capacitor → GND --> <line x1="200" y1="165" x2="200" y2="200" stroke="#90a4ae" stroke-width="1.2"/> <line x1="175" y1="200" x2="225" y2="200" stroke="#90a4ae" stroke-width="1.5"/> <line x1="183" y1="207" x2="217" y2="207" stroke="#90a4ae" stroke-width="1"/> <line x1="191" y1="214" x2="209" y2="214" stroke="#90a4ae" stroke-width="0.7"/> <text x="235" y="208" fill="#78909c" font-size="11">GND</text> <!-- Charge annotation -->

<text x="290" y="155" fill="#ce93d8" font-size="11">Charged → logic 1</text> <text x="290" y="170" fill="#78909c" font-size="11">Discharged → logic 0</text>

<!-- Leakage arrow --> <line x1="245" y1="157" x2="280" y2="190" stroke="#ef9a9a" stroke-width="1" stroke-dasharray="3,2" marker-end="url(#d1)"/> <text x="282" y="200" fill="#ef9a9a" font-size="10">charge leaks</text> <text x="282" y="212" fill="#ef9a9a" font-size="10">→ must refresh</text> </svg>

**Read operation** is **destructive**: asserting the wordline connects the capacitor to the bitline. The capacitor shares its charge with the bitline's parasitic capacitance, causing a small voltage deviation. A **sense amplifier** detects and amplifies this deviation, restoring the bitline to a full rail voltage. The capacitor is simultaneously recharged to restore the original value — read-modify-write is inherent.

**Write operation**: drive the bitline to the desired voltage, assert the wordline. The driven bitline charges or discharges the capacitor to the target value.

---

### Internal Organization

DRAM is organized as a hierarchy of arrays designed to maximize density while enabling selective access.

<svg viewBox="0 0 640 320" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="do" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#78909c"/> </marker> </defs> <!-- DIMM outline --> <rect x="10" y="10" width="620" height="300" rx="5" fill="#121212" stroke="#37474f" stroke-width="1.5"/> <text x="320" y="28" text-anchor="middle" fill="#546e7a" font-size="11">DIMM (e.g. 16 GB)</text> <!-- Rank outline --> <rect x="20" y="35" width="595" height="260" rx="4" fill="#1a1a2e" stroke="#3949ab" stroke-width="1"/> <text x="318" y="50" text-anchor="middle" fill="#7986cb" font-size="11">Rank (8 chips operating in parallel → 64-bit wide bus)</text> <!-- 4 DRAM chips shown --> <!-- Chip 1 --> <rect x="30" y="58" width="130" height="220" rx="3" fill="#1b2a1b" stroke="#388e3c" stroke-width="1"/> <text x="95" y="74" text-anchor="middle" fill="#66bb6a" font-size="10">DRAM Chip</text> <!-- Bank inside chip 1 --> <rect x="38" y="80" width="114" height="44" rx="2" fill="#1b5e20" stroke="#43a047" stroke-width="0.8"/> <text x="95" y="97" text-anchor="middle" fill="#a5d6a7" font-size="10">Bank 0</text> <text x="95" y="110" text-anchor="middle" fill="#81c784" font-size="9">Row buffer</text> <rect x="38" y="128" width="114" height="44" rx="2" fill="#1b5e20" stroke="#43a047" stroke-width="0.8"/> <text x="95" y="145" text-anchor="middle" fill="#a5d6a7" font-size="10">Bank 1</text> <text x="95" y="158" text-anchor="middle" fill="#81c784" font-size="9">Row buffer</text> <rect x="38" y="176" width="114" height="44" rx="2" fill="#1b5e20" stroke="#43a047" stroke-width="0.8"/> <text x="95" y="193" text-anchor="middle" fill="#a5d6a7" font-size="10">Bank 2</text> <text x="95" y="206" text-anchor="middle" fill="#81c784" font-size="9">Row buffer</text> <rect x="38" y="224" width="114" height="44" rx="2" fill="#1b5e20" stroke="#43a047" stroke-width="0.8"/> <text x="95" y="241" text-anchor="middle" fill="#a5d6a7" font-size="10">Bank 3</text> <text x="95" y="254" text-anchor="middle" fill="#81c784" font-size="9">Row buffer</text> <!-- Chip 2 --> <rect x="172" y="58" width="130" height="220" rx="3" fill="#1b2a1b" stroke="#388e3c" stroke-width="1"/> <text x="237" y="74" text-anchor="middle" fill="#66bb6a" font-size="10">DRAM Chip</text> <rect x="180" y="80" width="114" height="44" rx="2" fill="#1b5e20" stroke="#43a047" stroke-width="0.8"/> <text x="237" y="100" text-anchor="middle" fill="#a5d6a7" font-size="10">Bank 0 …</text> <text x="237" y="150" text-anchor="middle" fill="#546e7a" font-size="10">Banks 1–3</text> <!-- Ellipsis chips -->

<text x="360" y="175" text-anchor="middle" fill="#546e7a" font-size="20">···</text>

<!-- Chip 8 --> <rect x="456" y="58" width="148" height="220" rx="3" fill="#1b2a1b" stroke="#388e3c" stroke-width="1"/> <text x="530" y="74" text-anchor="middle" fill="#66bb6a" font-size="10">DRAM Chip ×8</text> <text x="530" y="100" text-anchor="middle" fill="#546e7a" font-size="10">Each chip contributes</text> <text x="530" y="115" text-anchor="middle" fill="#546e7a" font-size="10">8 bits per transfer</text> <text x="530" y="148" text-anchor="middle" fill="#78909c" font-size="10">8 chips × 8 bits</text> <text x="530" y="162" text-anchor="middle" fill="#78909c" font-size="10">= 64-bit data bus</text> <!-- Data bus at bottom --> <line x1="30" y1="288" x2="600" y2="288" stroke="#ffa726" stroke-width="1.5"/> <text x="320" y="300" text-anchor="middle" fill="#ffa726" font-size="10">64-bit data bus to memory controller</text> </svg>

#### Hierarchy Levels

**Cell array → Subarray → Bank → Rank → DIMM → Channel**

|Level|Description|
|---|---|
|Cell array|2D grid of 1T1C cells; rows are wordlines, columns are bitlines|
|Subarray|A partition of the cell array with its own set of sense amplifiers (row buffer)|
|Bank|A collection of subarrays sharing an address decoder; has one active row buffer|
|Rank|All chips on a DIMM that respond simultaneously to a single command — presents a full data bus width|
|Channel|An independent memory bus connecting the CPU's memory controller to one or more DIMMs|

A modern DDR5 DIMM may have 2 ranks × 8 banks per rank × 4 bank groups per chip, with 16–32 subarrays per bank — the hierarchy is deep and the timing rules at each level are distinct.

---

### The Row Buffer

The row buffer is the most important performance-determining structure in DRAM. It holds the contents of the currently open (activated) row — typically 8 KiB per bank. All column accesses within an open row are served from the row buffer at low latency without further array access.

Three access scenarios:

|Scenario|Condition|Latency|
|---|---|---|
|**Row hit**|Requested column is in the currently open row|Low (CAS latency only)|
|**Row miss**|A different row is open; must precharge then activate|High (PRE + RAS + CAS)|
|**Row empty**|No row is open (precharged state); must activate|Medium (RAS + CAS)|

The **open-row policy** leaves a row active after access, hoping future accesses hit the same row. The **closed-row policy** precharges after every access, ensuring row-empty state for the next access. Modern memory controllers use adaptive policies based on observed access patterns.

---

### Fundamental DRAM Operations

#### ACT (Activate / RAS)

Asserts a wordline, connecting an entire row of cells to their bitlines. Sense amplifiers latch the row into the row buffer. Requires time **tRCD** (RAS-to-CAS delay) before column access can begin.

#### READ / WRITE (CAS)

Issues a column address to select specific columns from the open row buffer. Data appears on the bus after **CL** (CAS latency) cycles for a read, or is written immediately for a write.

#### PRE (Precharge)

Restores the bitlines to $V_{DD}/2$ (equilibrium), preparing the bank for the next activation. Requires time **tRP** before ACT can be issued. During precharge, the row buffer is invalidated.

#### REF (Refresh)

Each row must be refreshed within a window **tREFW** (typically 64 ms at standard temperature, 32 ms at elevated temperature). The memory controller issues refresh commands that activate and restore every row. **tRFC** (refresh cycle time) is the time the rank is unavailable during a refresh operation — a significant overhead for high-density DIMMs.

---

### DRAM Timing Parameters

Timing parameters are specified in clock cycles at the operating frequency. They define the minimum intervals that must elapse between command pairs.

|Parameter|Full Name|Definition|
|---|---|---|
|**CL**|CAS Latency|Cycles from READ command to first data on bus|
|**tRCD**|RAS-to-CAS Delay|Cycles from ACT to READ/WRITE|
|**tRP**|Row Precharge time|Cycles from PRE to next ACT (same bank)|
|**tRAS**|Row Active time|Minimum cycles a row must remain active after ACT|
|**tRC**|Row Cycle time|Minimum cycles between successive ACT to same bank; tRC = tRAS + tRP|
|**tRFC**|Refresh Cycle time|Duration of a refresh operation; scales with DRAM density|
|**tRTP**|Read-to-Precharge|Minimum cycles from READ to PRE in same bank|
|**tWR**|Write Recovery time|Minimum cycles from WRITE completion to PRE (allows write data to settle)|
|**tWTR**|Write-to-Read|Minimum cycles from WRITE to READ in same bank|
|**tCCD**|CAS-to-CAS Delay|Minimum cycles between consecutive READ or WRITE commands|
|**tFAW**|Four Activate Window|Constraint: no more than 4 ACT commands may be issued within tFAW cycles (across banks, same rank)|
|**tRRD**|RAS-to-RAS Delay|Minimum cycles between ACT commands to different banks|

#### DRAM Timing Notation

Retail memory is specified as a timing tuple: **CL-tRCD-tRP-tRAS**

```
Example: DDR4-3200  CL16-18-18-38
  CL   = 16 cycles
  tRCD = 18 cycles
  tRP  = 18 cycles
  tRAS = 38 cycles
  Cycle time at 3200 MT/s = 1/1600 MHz ≈ 0.625 ns
  CL in time = 16 × 0.625 = 10 ns
```

Lower CL numbers indicate lower latency. When comparing memory kits at different frequencies, the absolute latency in nanoseconds matters more than the cycle count: a CL16 kit at 3200 MT/s and a CL18 kit at 3600 MT/s have nearly identical absolute latencies.

---

### Access Timing Diagram

A full open-row access sequence from precharged state:

<svg viewBox="0 0 660 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="dt" markerWidth="5" markerHeight="5" refX="2.5" refY="2.5" orient="auto"> <path d="M0,0 L5,2.5 L0,5 Z" fill="#90a4ae"/> </marker> <marker id="dtl" markerWidth="5" markerHeight="5" refX="2.5" refY="2.5" orient="auto"> <path d="M0,0 L5,2.5 L0,5 Z" fill="#fff59d"/> </marker> <marker id="dtr" markerWidth="5" markerHeight="5" refX="2.5" refY="2.5" orient="180"> <path d="M0,0 L5,2.5 L0,5 Z" fill="#fff59d"/> </marker> </defs> <!-- Row labels -->

<text x="5" y="52" fill="#90a4ae">CMD</text> <text x="5" y="112" fill="#4fc3f7">Row buf</text> <text x="5" y="172" fill="#ffa726">Data</text>

<!-- Timeline baseline --> <line x1="70" y1="220" x2="640" y2="220" stroke="#37474f" stroke-width="0.8"/> <!-- Cycle ticks --> <!-- ticks at x: 70,100,130,160,190,220,250,280,310,340,370,400,430,460,490,520,550,580,610,640 (step 30) --> <!-- Label cycles 0–19 --> <!-- Draw ticks --> <line x1="70" y1="218" x2="70" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="100" y1="218" x2="100" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="130" y1="218" x2="130" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="160" y1="218" x2="160" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="190" y1="218" x2="190" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="220" y1="218" x2="220" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="250" y1="218" x2="250" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="280" y1="218" x2="280" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="310" y1="218" x2="310" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="340" y1="218" x2="340" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="370" y1="218" x2="370" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="400" y1="218" x2="400" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="430" y1="218" x2="430" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="460" y1="218" x2="460" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="490" y1="218" x2="490" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="520" y1="218" x2="520" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="550" y1="218" x2="550" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="580" y1="218" x2="580" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="610" y1="218" x2="610" y2="224" stroke="#37474f" stroke-width="0.7"/> <line x1="640" y1="218" x2="640" y2="224" stroke="#37474f" stroke-width="0.7"/> <!-- Cycle numbers (0 to 19) -->

<text x="70" y="235" text-anchor="middle" fill="#546e7a" font-size="9">0</text> <text x="100" y="235" text-anchor="middle" fill="#546e7a" font-size="9">1</text> <text x="130" y="235" text-anchor="middle" fill="#546e7a" font-size="9">2</text> <text x="160" y="235" text-anchor="middle" fill="#546e7a" font-size="9">3</text> <text x="190" y="235" text-anchor="middle" fill="#546e7a" font-size="9">4</text> <text x="220" y="235" text-anchor="middle" fill="#546e7a" font-size="9">5</text> <text x="250" y="235" text-anchor="middle" fill="#546e7a" font-size="9">6</text> <text x="280" y="235" text-anchor="middle" fill="#546e7a" font-size="9">7</text> <text x="310" y="235" text-anchor="middle" fill="#546e7a" font-size="9">8</text> <text x="340" y="235" text-anchor="middle" fill="#546e7a" font-size="9">9</text> <text x="370" y="235" text-anchor="middle" fill="#546e7a" font-size="9">10</text> <text x="400" y="235" text-anchor="middle" fill="#546e7a" font-size="9">11</text> <text x="430" y="235" text-anchor="middle" fill="#546e7a" font-size="9">12</text> <text x="460" y="235" text-anchor="middle" fill="#546e7a" font-size="9">13</text> <text x="490" y="235" text-anchor="middle" fill="#546e7a" font-size="9">14</text> <text x="520" y="235" text-anchor="middle" fill="#546e7a" font-size="9">15</text> <text x="550" y="235" text-anchor="middle" fill="#546e7a" font-size="9">16</text> <text x="580" y="235" text-anchor="middle" fill="#546e7a" font-size="9">17</text> <text x="610" y="235" text-anchor="middle" fill="#546e7a" font-size="9">18</text> <text x="640" y="235" text-anchor="middle" fill="#546e7a" font-size="9">19</text>

<!-- CMD row: ACT at cycle 0 --> <rect x="70" y="38" width="42" height="22" rx="2" fill="#1b5e20" stroke="#66bb6a" stroke-width="1"/> <text x="91" y="53" text-anchor="middle" fill="#a5d6a7">ACT</text> <!-- CMD: READ at cycle 4 (tRCD=4 → x=70+4×30=190) --> <rect x="190" y="38" width="42" height="22" rx="2" fill="#1a237e" stroke="#5c6bc0" stroke-width="1"/> <text x="211" y="53" text-anchor="middle" fill="#9fa8da">READ</text> <!-- CMD: PRE at cycle 14 (after tRAS=14 minimum) --> <rect x="490" y="38" width="42" height="22" rx="2" fill="#b71c1c" stroke="#ef5350" stroke-width="1"/> <text x="511" y="53" text-anchor="middle" fill="#ffcdd2">PRE</text> <!-- Row buffer active from cycle 0 → 14 (190 → 490) ... after sense amp delay show as active at 2 → 14 --> <rect x="130" y="98" width="360" height="22" rx="2" fill="#2e3b2e" stroke="#4caf50" stroke-width="1" stroke-dasharray="3,2"/> <text x="310" y="113" text-anchor="middle" fill="#66bb6a">Row buffer active (sense amplifiers latched)</text> <!-- Data valid: from cycle 4+CL (CL=4 → cycle 8, x=310) for burst --> <rect x="310" y="158" width="120" height="22" rx="2" fill="#e65100" stroke="#ffa726" stroke-width="1"/> <text x="370" y="173" text-anchor="middle" fill="#ffe0b2">Data valid (burst)</text> <!-- tRCD bracket --> <line x1="70" y1="20" x2="190" y2="20" stroke="#fff59d" stroke-width="1" marker-end="url(#dtl)" marker-start="url(#dtr)"/> <text x="130" y="15" text-anchor="middle" fill="#fff59d" font-size="10">tRCD = 4</text> <!-- CL bracket --> <line x1="190" y1="82" x2="310" y2="82" stroke="#4fc3f7" stroke-width="1" marker-end="url(#dtl)" marker-start="url(#dtr)"/> <text x="250" y="77" text-anchor="middle" fill="#4fc3f7" font-size="10">CL = 4</text> <!-- tRAS bracket --> <line x1="70" y1="140" x2="490" y2="140" stroke="#ef9a9a" stroke-width="1" marker-end="url(#dtl)" marker-start="url(#dtr)"/> <text x="280" y="135" text-anchor="middle" fill="#ef9a9a" font-size="10">tRAS = 14 (min active time)</text> <!-- tRP bracket --> <line x1="490" y1="20" x2="610" y2="20" stroke="#ce93d8" stroke-width="1" marker-end="url(#dtl)" marker-start="url(#dtr)"/> <text x="550" y="15" text-anchor="middle" fill="#ce93d8" font-size="10">tRP = 4</text> <!-- Vertical markers --> <line x1="70" y1="35" x2="70" y2="220" stroke="#1b5e20" stroke-width="0.6" stroke-dasharray="3,3"/> <line x1="190" y1="35" x2="190" y2="220" stroke="#1a237e" stroke-width="0.6" stroke-dasharray="3,3"/> <line x1="310" y1="155" x2="310" y2="220" stroke="#e65100" stroke-width="0.6" stroke-dasharray="3,3"/> <line x1="490" y1="35" x2="490" y2="220" stroke="#b71c1c" stroke-width="0.6" stroke-dasharray="3,3"/> <line x1="610" y1="35" x2="610" y2="220" stroke="#ce93d8" stroke-width="0.6" stroke-dasharray="3,3"/> </svg>

**Total latency from precharged state to first data (row miss):**

$$t_{access} = t_{RCD} + CL$$

**Minimum row cycle time (same bank, sequential accesses to different rows):**

$$t_{RC} = t_{RAS} + t_{RP}$$

---

### Bank Groups and Command Interleaving

DDR4 and DDR5 introduce **bank groups**: banks are partitioned into groups with shorter inter-bank timing constraints within a group versus across groups. The distinction matters because:

- **Same bank group**: tCCD_S (short) applies between consecutive column commands — slower.
- **Different bank groups**: tCCD_L (long)... [Inference: naming varies; the key point is that different bank groups allow commands to be issued with less delay between them, enabling higher effective bandwidth.]

By interleaving commands across bank groups, the memory controller can issue a new column command every 2 cycles (at DDR4 data rates) rather than waiting the full same-bank CAS-to-CAS gap. This is a primary mechanism by which modern DRAM achieves high sustained bandwidth despite high per-access latency.

---

### Refresh Mechanics

Every DRAM row must be refreshed within **tREFW = 64 ms** (32 ms at temperatures above 85°C, per JEDEC spec). For a DRAM with 65,536 rows, the controller must issue a refresh command every:

$$t_{REFI} = \frac{t_{REFW}}{\text{rows}} = \frac{64,\text{ms}}{65536} \approx 976,\text{ns}$$

Each refresh command (REF) activates and restores 8 rows simultaneously (in modern DRAM) and occupies the rank for **tRFC** — which scales with die density:

|Density per die|tRFC (typ.)|
|---|---|
|4 Gb|~110 ns|
|8 Gb|~350 ns|
|16 Gb|~550 ns|
|32 Gb (DDR5)|~650 ns|

During tRFC, no normal commands can be issued. At tREFI ≈ 976 ns and tRFC ≈ 350 ns, refresh overhead is approximately 350/976 ≈ **35% of available bandwidth** for an 8 Gb die — a severe and growing penalty as DRAM density increases.

**Refresh mitigation strategies:**

- **Deferred refresh**: the controller can postpone up to 8 consecutive REF commands if a critical access is in progress, then issue them back-to-back.
- **Fine granularity refresh (FGR)**: DDR4 supports a 2× or 4× finer refresh rate (halved tREFI), reducing per-refresh tRFC — useful at elevated temperatures.
- **Per-bank refresh (DDR5)**: instead of refreshing the entire rank simultaneously, DDR5 allows per-bank refresh, so other banks remain accessible during a bank's refresh. This reduces effective latency impact substantially.
- **LPDDR refresh ABR / DSM**: low-power DRAM uses distributed self-refresh and temperature-aware refresh to minimize overhead.

---

### DDR Signaling and Data Rate

**DDR (Double Data Rate)** transfers data on both the rising and falling edges of the clock, doubling bandwidth for a given clock frequency.

|Generation|I/O Clock|Data rate (MT/s)|Prefetch|Bus width|Peak BW (×64-bit)|
|---|---|---|---|---|---|
|DDR3|400–1066 MHz|800–2133|8n|64-bit|~17 GB/s|
|DDR4|1066–1600 MHz|2133–3200|8n|64-bit|~25 GB/s|
|DDR5|2400–3200 MHz|4800–6400|16n|2×32-bit|~51 GB/s|

**Prefetch** is the number of bits transferred from the DRAM array per I/O pin per command. DDR4's 8n prefetch means the column access internally reads 8× the bus width from the array, serializing it out over 4 clock cycles (8 transfers at DDR). DDR5's 16n prefetch with a split 32-bit bus maintains compatibility with burst lengths.

The consequence of large prefetch: DRAM has very high burst bandwidth but cannot efficiently serve random accesses smaller than the prefetch width. A single 8-byte read from DDR4 still internally activates 64 bytes from the array.

---

### Memory Controller Scheduling

The memory controller is the arbiter between the CPU's cache hierarchy and the DRAM. Its principal functions are:

**Command scheduling**: reorder incoming read/write requests to maximize row hits and minimize row misses. A request to an already-open row is issued immediately (row hit); requests to closed rows are batched with ACT commands. The **FR-FCFS (First Ready, First Come First Served)** policy prioritizes row hits over FIFO order.

**Timing enforcement**: the controller tracks per-bank state machines (precharged / active / refreshing) and enforces all timing constraints (tRCD, tRP, tRAS, tRC, tFAW, tRRD) before issuing each command.

**Refresh scheduling**: the controller issues REF commands at tREFI intervals, either interrupting ongoing transactions (closed-page policy) or completing an open-row burst first (within JEDEC's 8-command deferral limit).

**Write buffering and coalescing**: writes are buffered and coalesced to minimize write-to-read bus turnaround overhead (tWTR). The controller manages write drain — flushing write buffers before they overflow — without unnecessarily interrupting read traffic.

---

### Latency vs. Bandwidth: The Fundamental Tension

DRAM design involves an irreducible trade-off:

- **Latency** is dominated by the physics of the 1T1C cell, the sense amplifier settling time, and the parasitic capacitance of bitlines. It has not improved proportionally with technology scaling — DDR4 absolute CAS latency (~13–15 ns) is similar to DDR2 absolute latency, even though clock frequencies doubled.
- **Bandwidth** scales with bus width, clock frequency, and prefetch depth. It has improved substantially across DDR generations.

This asymmetry — bandwidth growing faster than latency — means that DRAM is efficient for streaming access patterns (where prefetch is exploited) and increasingly inefficient for random-access patterns (where each access pays the full tRCD + CL penalty regardless of burst size). This is the primary architectural motivation for large on-chip caches, hardware prefetchers, and near-memory processing proposals.

---

**Conclusion**

DRAM's internals are defined by the physics of capacitive storage: the need to sense, amplify, and restore charge on every read; the need to periodically refresh every row; and the organization of cells into arrays, banks, and ranks to enable parallel access and command pipelining. The timing parameters — CL, tRCD, tRP, tRAS, and others — are not arbitrary; each reflects a physical constraint on how quickly the underlying array can respond. The memory controller's role is to schedule commands such that these constraints are satisfied with minimum idle time, maximizing the bandwidth delivered to the processor while managing the growing overhead of refresh in high-density devices.

**Next Steps**

- Memory interleaving and banking — how multiple channels, ranks, and banks are interleaved by the memory controller to hide latency and increase effective bandwidth for sequential and strided access patterns.
- DDR standards — detailed treatment of DDR4 vs DDR5 architectural changes: on-die ECC, decision feedback equalization, per-bank refresh, and the split-channel design.
- ECC memory — how error detection and correction are implemented in the DRAM subsystem, including SECDED codes, chipkill, and the interaction between ECC and memory controller design.

---

