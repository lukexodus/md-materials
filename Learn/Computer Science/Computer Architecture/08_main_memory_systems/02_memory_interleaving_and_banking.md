## Memory Interleaving and Banking


Main memory systems must supply data at a rate sufficient to keep the processor and cache hierarchy occupied. A single monolithic memory array cannot meet this demand — its internal cycle time (the minimum time between successive accesses to the same array) is longer than its access latency, and it can only service one request at a time. Memory interleaving and banking decompose the address space across multiple independent memory modules so that multiple accesses can be in progress simultaneously, increasing effective bandwidth without reducing the latency of any individual access.

---

### The Bandwidth Problem

A processor issuing one memory request per cycle at 3 GHz requires 3 billion transfers per second. A single DDR5 DRAM module delivers roughly 50 GB/s of peak bandwidth, but its internal row cycle time (tRC) is approximately 45–50 ns — meaning the same row cannot be accessed again for ~135–150 cycles at 3 GHz. Sequential accesses to the same DRAM array serialize and cannot be pipelined within that array.

The solution is parallelism across multiple independent arrays, each with its own address decoder, sense amplifiers, and data path.

---

### Banks vs. Modules: Terminology

These terms are used at different levels of the memory hierarchy and are sometimes conflated:

|Term|Scope|Independence|
|---|---|---|
|**Bank**|Within a single DRAM chip or cache|Independent row/column access circuits|
|**Rank**|A set of DRAM chips sharing a chip-select signal|Operate together as one wide word|
|**Module (DIMM)**|A PCB carrying one or two ranks|Plugged into a memory channel|
|**Channel**|A complete independent memory bus|Fully independent; highest-level parallelism|

At every level, the principle is the same: distribute addresses across independent units so multiple requests can proceed simultaneously.

---

### Memory Interleaving

Interleaving distributes **consecutive addresses** across multiple memory modules (or banks) in a round-robin fashion. The goal is to ensure that sequential or stride-1 accesses — the most common pattern in cache line fills and DMA transfers — hit different modules and can be serviced in parallel.

#### High-Order Interleaving (Bank Selection by High Address Bits)

The high-order bits of the address select the module; the remaining bits address within that module.

```
Address: [ Module Select | Row | Column ]
```

Consecutive addresses within a region map to the **same module**. Large contiguous regions go entirely to one bank before filling the next.

<svg viewBox="0 0 580 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="arr" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#888"/> </marker> </defs> <!-- Address space bar --> <text x="20" y="30" fill="#aaa">Address space (high-order, 4 modules):</text> <rect x="20" y="40" width="120" height="30" rx="2" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="80" y="60" text-anchor="middle" fill="#7af">Module 0</text> <text x="80" y="76" text-anchor="middle" fill="#7af" font-size="9">0x0000–0x3FFF</text> <rect x="140" y="40" width="120" height="30" rx="2" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="200" y="60" text-anchor="middle" fill="#fa7">Module 1</text> <text x="200" y="76" text-anchor="middle" fill="#fa7" font-size="9">0x4000–0x7FFF</text> <rect x="260" y="40" width="120" height="30" rx="2" fill="none" stroke="#8f8" stroke-width="1.5"/> <text x="320" y="60" text-anchor="middle" fill="#8f8">Module 2</text> <text x="320" y="76" text-anchor="middle" fill="#8f8" font-size="9">0x8000–0xBFFF</text> <rect x="380" y="40" width="120" height="30" rx="2" fill="none" stroke="#f88" stroke-width="1.5"/> <text x="440" y="60" text-anchor="middle" fill="#f88">Module 3</text> <text x="440" y="76" text-anchor="middle" fill="#f88" font-size="9">0xC000–0xFFFF</text> <!-- Sequential access pattern -->

<text x="20" y="115" fill="#aaa">Sequential access 0,1,2,3,4,5,6,7 → all hit Module 0 first:</text> <rect x="20" y="125" width="30" height="22" rx="2" fill="none" stroke="#7af" stroke-width="1.2"/> <text x="35" y="141" text-anchor="middle" fill="#7af">0</text> <rect x="55" y="125" width="30" height="22" rx="2" fill="none" stroke="#7af" stroke-width="1.2"/> <text x="70" y="141" text-anchor="middle" fill="#7af">1</text> <rect x="90" y="125" width="30" height="22" rx="2" fill="none" stroke="#7af" stroke-width="1.2"/> <text x="105" y="141" text-anchor="middle" fill="#7af">2</text> <rect x="125" y="125" width="30" height="22" rx="2" fill="none" stroke="#7af" stroke-width="1.2"/> <text x="140" y="141" text-anchor="middle" fill="#7af">3</text> <rect x="160" y="125" width="30" height="22" rx="2" fill="none" stroke="#7af" stroke-width="1.2"/> <text x="175" y="141" text-anchor="middle" fill="#7af">4</text> <text x="210" y="141" fill="#f88">← no parallelism</text> </svg>

High-order interleaving provides no bandwidth benefit for sequential access. Its primary value is **modularity** — modules can be added independently, and memory regions are contiguous within a module, simplifying physical addressing.

#### Low-Order Interleaving (True Interleaving)

The low-order bits select the module; higher bits address within the module. Consecutive addresses cycle through all modules before returning to module 0.

```
Address: [ Row | Column | Module Select ]

With 4 modules and byte addressing:
Address 0 → Module 0
Address 1 → Module 1
Address 2 → Module 2
Address 3 → Module 3
Address 4 → Module 0
Address 5 → Module 1
...
```

<svg viewBox="0 0 600 210" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- Module columns --> <text x="75" y="25" text-anchor="middle" fill="#7af">Module 0</text> <text x="215" y="25" text-anchor="middle" fill="#fa7">Module 1</text> <text x="355" y="25" text-anchor="middle" fill="#8f8">Module 2</text> <text x="495" y="25" text-anchor="middle" fill="#f88">Module 3</text> <!-- Module boxes --> <rect x="30" y="35" width="90" height="140" rx="3" fill="none" stroke="#7af" stroke-width="1.5"/> <rect x="170" y="35" width="90" height="140" rx="3" fill="none" stroke="#fa7" stroke-width="1.5"/> <rect x="310" y="35" width="90" height="140" rx="3" fill="none" stroke="#8f8" stroke-width="1.5"/> <rect x="450" y="35" width="90" height="140" rx="3" fill="none" stroke="#f88" stroke-width="1.5"/> <!-- Word entries -->

<text x="75" y="58" text-anchor="middle" fill="#7af">Addr 0</text> <text x="215" y="58" text-anchor="middle" fill="#fa7">Addr 1</text> <text x="355" y="58" text-anchor="middle" fill="#8f8">Addr 2</text> <text x="495" y="58" text-anchor="middle" fill="#f88">Addr 3</text>

<text x="75" y="82" text-anchor="middle" fill="#7af">Addr 4</text> <text x="215" y="82" text-anchor="middle" fill="#fa7">Addr 5</text> <text x="355" y="82" text-anchor="middle" fill="#8f8">Addr 6</text> <text x="495" y="82" text-anchor="middle" fill="#f88">Addr 7</text>

<text x="75" y="106" text-anchor="middle" fill="#7af">Addr 8</text> <text x="215" y="106" text-anchor="middle" fill="#fa7">Addr 9</text> <text x="355" y="106" text-anchor="middle" fill="#8f8">Addr 10</text> <text x="495" y="106" text-anchor="middle" fill="#f88">Addr 11</text>

<text x="75" y="130" text-anchor="middle" fill="#555">...</text> <text x="215" y="130" text-anchor="middle" fill="#555">...</text> <text x="355" y="130" text-anchor="middle" fill="#555">...</text> <text x="495" y="130" text-anchor="middle" fill="#555">...</text>

<text x="300" y="195" text-anchor="middle" fill="#aaa">Consecutive addresses stripe across all modules</text> </svg>

A cache line fill requiring 8 consecutive words (with 4-wide interleaving) sends requests to all 4 modules simultaneously. Assuming module cycle time T_m, the 8 words complete in 2 × T_m rather than 8 × T_m.

---

### Interleaving Timing Model

Let:

- _k_ = number of interleaved modules
- _T_m_ = module cycle time (time before same module can be accessed again)
- _T_a_ = module access latency (time to return first word)
- _n_ = number of words requested (e.g., cache line / word size)

**Without interleaving:**

```
Total time = T_a + (n − 1) × T_m
```

Each word waits for the previous one to complete.

**With k-way low-order interleaving:**

```
Total time = T_a + ⌈n/k⌉ × T_m      (if n > k)
Total time = T_a                      (if n ≤ k, all words in flight simultaneously)
```

**Effective bandwidth ratio** (interleaved vs. non-interleaved):

```
Speedup = [T_a + (n−1)×T_m] / [T_a + ⌈n/k⌉×T_m]
```

For large _n_ and _k_ = _n_:

```
Speedup → (n × T_m) / T_m = n        (ideal: k-fold improvement)
```

**Example:** T_a = 50 ns, T_m = 100 ns, n = 8 words, k = 4 modules

```
Without interleaving: 50 + 7×100 = 750 ns
With interleaving:    50 + 2×100 = 250 ns    (3× faster)
Ideal (k=8):          50 + 0×100 =  50 ns    (15× faster — latency only)
```

---

### Bank Conflicts

Low-order interleaving provides bandwidth improvement only when consecutive accesses map to different modules. A **bank conflict** occurs when two or more accesses within a short time window target the same module, forcing serialization.

#### Sources of Bank Conflicts

**Stride access patterns:** A program accessing memory with stride _k_ (where _k_ equals the number of modules) always hits the same module:

```
4 modules, addresses: 0, 4, 8, 12, 16, ...
All map to Module 0 → zero parallelism
```

This is a significant and well-known problem. The standard mitigation is to choose the number of modules to be a number that is **not a power of 2**, or to use a **non-power-of-2 stride** in software. Alternatively, XOR-based address hashing remaps addresses to reduce systematic conflicts.

**Multiple outstanding misses:** In a non-blocking cache with several outstanding misses, two misses may target lines that map to the same module.

**DMA and prefetch conflicts:** Background memory transfers initiated by a prefetcher or DMA engine compete with demand accesses and may cause bank conflicts.

---

### XOR-Based Address Hashing

To mitigate stride conflicts, some systems use an XOR of multiple address bit groups to select the bank:

```
Standard:  Bank = Address[low bits]
XOR hash:  Bank = Address[low bits] XOR Address[mid bits]
```

**Example with 4 banks (2 select bits):**

```
Stride-4 access with standard mapping:
  0x00: bank = 00  → Bank 0
  0x04: bank = 00  → Bank 0  (conflict)
  0x08: bank = 00  → Bank 0  (conflict)

Stride-4 access with XOR(bits[1:0], bits[3:2]):
  0x00: 00 XOR 00 = 00 → Bank 0
  0x04: 00 XOR 01 = 01 → Bank 1
  0x08: 00 XOR 10 = 10 → Bank 2
  0x0C: 00 XOR 11 = 11 → Bank 3
```

XOR hashing distributes stride-4 accesses evenly across banks. This technique is used in GPU memory controllers, cache set indexing, and DRAM controllers.

---

### DRAM Internal Banking

Within a single DRAM chip, the array is divided into internal banks (typically 8–16 banks in modern DDR devices). Each bank has its own row address decoder, row buffer (sense amplifiers), and column access path. Multiple banks can have their rows open simultaneously, enabling overlapped access.

<svg viewBox="0 0 620 280" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="arr2" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#888"/> </marker> </defs> <!-- DRAM chip outline --> <rect x="20" y="20" width="580" height="240" rx="5" fill="none" stroke="#555" stroke-width="1.5" stroke-dasharray="6,3"/> <text x="310" y="14" text-anchor="middle" fill="#555">DRAM Chip</text> <!-- Bank 0 --> <rect x="40" y="40" width="110" height="180" rx="4" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="95" y="60" text-anchor="middle" fill="#7af">Bank 0</text> <rect x="50" y="70" width="90" height="80" rx="2" fill="none" stroke="#555" stroke-width="1"/> <text x="95" y="114" text-anchor="middle" fill="#aaa">Array</text> <rect x="50" y="160" width="90" height="22" rx="2" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="95" y="175" text-anchor="middle" fill="#fa7">Row Buffer</text> <text x="95" y="205" text-anchor="middle" fill="#aaa" font-size="10">Row open: R42</text> <!-- Bank 1 --> <rect x="165" y="40" width="110" height="180" rx="4" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="220" y="60" text-anchor="middle" fill="#7af">Bank 1</text> <rect x="175" y="70" width="90" height="80" rx="2" fill="none" stroke="#555" stroke-width="1"/> <text x="220" y="114" text-anchor="middle" fill="#aaa">Array</text> <rect x="175" y="160" width="90" height="22" rx="2" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="220" y="175" text-anchor="middle" fill="#fa7">Row Buffer</text> <text x="220" y="205" text-anchor="middle" fill="#aaa" font-size="10">Row open: R17</text> <!-- Bank 2 --> <rect x="290" y="40" width="110" height="180" rx="4" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="345" y="60" text-anchor="middle" fill="#7af">Bank 2</text> <rect x="300" y="70" width="90" height="80" rx="2" fill="none" stroke="#555" stroke-width="1"/> <text x="345" y="114" text-anchor="middle" fill="#aaa">Array</text> <rect x="300" y="160" width="90" height="22" rx="2" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="345" y="175" text-anchor="middle" fill="#fa7">Row Buffer</text> <text x="345" y="205" text-anchor="middle" fill="#aaa" font-size="10">Row open: R08</text> <!-- Bank 3 --> <rect x="415" y="40" width="110" height="180" rx="4" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="470" y="60" text-anchor="middle" fill="#7af">Bank 3</text> <rect x="425" y="70" width="90" height="80" rx="2" fill="none" stroke="#555" stroke-width="1"/> <text x="470" y="114" text-anchor="middle" fill="#aaa">Array</text> <rect x="425" y="160" width="90" height="22" rx="2" fill="none" stroke="#fa7" stroke-width="1.2"/> <text x="470" y="175" text-anchor="middle" fill="#fa7">Row Buffer</text> <text x="470" y="205" text-anchor="middle" fill="#aaa" font-size="10">Row open: R91</text>

<text x="310" y="248" text-anchor="middle" fill="#aaa">Each bank maintains its own open row — parallel row activations possible</text> </svg>

Key DRAM timing parameters relevant to banking:

|Parameter|Symbol|Meaning|
|---|---|---|
|Row-to-Column Delay|tRCD|Time after ACT before CAS can be issued|
|Column Access Strobe|CL / tCL|Latency from CAS to first data|
|Row Precharge Time|tRP|Time to close a row before opening another|
|Row Active Time|tRAS|Minimum time row must stay active|
|Row Cycle Time|tRC|tRAS + tRP — minimum time between ACT to same bank|
|Bank-to-Bank Switch|tRRD|Minimum time between ACT commands to different banks|

Because tRRD (bank-to-bank activation delay) is much shorter than tRC (same-bank cycle time), issuing activations to multiple banks in rapid succession allows access latency to be overlapped.

---

### Bank Interleaving at the DRAM Level

A DRAM memory controller exploits internal banks by issuing commands to different banks in an interleaved sequence, overlapping the tRCD and tCL latencies of one bank with the precharge of another.

**Example — 4-bank interleaving schedule:**

```
Cycle:    1     2     3     4     5     6     7     8
Bank 0: [ACT]        [CAS]       [DATA]       [PRE]
Bank 1:       [ACT]        [CAS]       [DATA]       [PRE]
Bank 2:             [ACT]        [CAS]       [DATA]
Bank 3:                   [ACT]        [CAS]       [DATA]
```

[Inference: the exact cycle counts depend on the specific tRCD, CL, and tRRD values of the DRAM; the diagram illustrates the overlap principle, not specific DDR timing.]

The data bus (the channel) receives a steady stream of data from successive banks rather than experiencing gaps caused by DRAM latency.

---

### Memory Channels

A **memory channel** is a complete, independent bus between the memory controller and a set of DRAM modules. Each channel has its own address/command bus, data bus, and clock lines. Multiple channels operate fully independently — there is no shared resource between channels.

Adding channels scales **bandwidth linearly** with the number of channels. Dual-channel (common in consumer systems), quad-channel (workstations and servers), and 8- or 12-channel (high-end servers) configurations are deployed.

**Dual-channel operation:** The memory controller interleaves requests across two channels, effectively doubling bandwidth for streaming access patterns. This requires matching DIMMs to be installed in specific slots to activate the dual-channel mode.

---

### Ranks and Chip-Select Interleaving

Within a channel, multiple **ranks** can be present. A rank is a set of DRAM chips that are activated together (sharing a chip-select signal) to produce one full bus-width word (64 bits in consumer DDR).

Rank interleaving allows the memory controller to issue a command to rank 1 while rank 0's tCCD (column-to-column delay) or tRP is still in progress. This is a finer-grained form of the same overlap principle used at the bank level.

```
Rank 0: [ACT][CAS]────[DATA]──[PRE]
Rank 1:         [ACT][CAS]────[DATA]──[PRE]
```

---

### Interleaving Granularity

The granularity at which addresses are striped across banks/modules determines which access patterns benefit:

|Granularity|Typical Value|Benefits|
|---|---|---|
|Word-level|4–8 bytes|Fine-grained sequential access|
|Cache-line-level|64 bytes|One cache line per module — good for random access|
|Page-level|4 KB|OS-level allocation across modules|

**Cache-line granularity interleaving** is common in multiprocessor systems: one entire cache line is allocated from one bank, the next from the next bank, and so on. This reduces bank conflicts from independent accesses by different cores, since two cores are unlikely to request the same cache line simultaneously.

---

### Non-Uniform Memory Access (NUMA) and Banking

In multi-socket systems, each processor socket has local DRAM banks attached directly to its memory controller. Accesses to local banks are faster than accesses to banks on a remote socket (accessed via the inter-socket interconnect).

This creates a **non-uniform** latency profile — the identity of which bank holds a datum determines the access latency. NUMA-aware software and OS page placement policies direct frequently accessed data to the local bank of the socket that accesses it. This is an architectural consequence of the physical distribution of banks across sockets.

---

### Summary of Parallelism Levels

<svg viewBox="0 0 620 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="arr3" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#888"/> </marker> </defs> <!-- Level bars --> <!-- Channels --> <rect x="20" y="20" width="580" height="36" rx="4" fill="none" stroke="#fa7" stroke-width="1.5"/> <text x="30" y="35" fill="#fa7">Channels (1–12):</text> <text x="220" y="35" fill="#aaa">Fully independent bus, address, data — linear BW scaling</text> <text x="30" y="50" fill="#aaa" font-size="10">Granularity: cache-line or page striping across channels</text> <!-- Ranks --> <rect x="20" y="68" width="580" height="36" rx="4" fill="none" stroke="#7af" stroke-width="1.5"/> <text x="30" y="83" fill="#7af">Ranks (1–4 per channel):</text> <text x="220" y="83" fill="#aaa">Share data bus; interleaved via chip-select</text> <text x="30" y="98" fill="#aaa" font-size="10">Overlap tRP and tRCD of one rank with CAS of another</text> <!-- Banks --> <rect x="20" y="116" width="580" height="36" rx="4" fill="none" stroke="#8f8" stroke-width="1.5"/> <text x="30" y="131" fill="#8f8">Banks (8–32 per rank):</text> <text x="220" y="131" fill="#aaa">Within a DRAM chip; independent row buffers</text> <text x="30" y="146" fill="#aaa" font-size="10">Overlap ACT/CAS/PRE of different banks on same channel</text> <!-- Subarrays --> <rect x="20" y="164" width="580" height="36" rx="4" fill="none" stroke="#f88" stroke-width="1.5"/> <text x="30" y="179" fill="#f88">Subarrays (within bank):</text> <text x="220" y="179" fill="#aaa">Further division; partial row activation</text> <text x="30" y="194" fill="#aaa" font-size="10">Reduces energy per access; limited parallelism within bank</text> <!-- Annotation -->

<text x="310" y="245" text-anchor="middle" fill="#555">↑ increasing independence and BW scaling potential ↑</text> </svg>

---

### Bandwidth Calculation

**Peak theoretical bandwidth** for a memory system:

```
BW = Channels × Bus_width × Transfer_rate

DDR5-4800, dual-channel, 64-bit bus:
BW = 2 × 64 bits × 4800 MT/s
   = 2 × 8 bytes × 4800 × 10⁶
   = 76.8 GB/s
```

[Unverified: DDR5-4800 specifications are based on JEDEC standards as of mid-2025; shipping implementations and actual sustained bandwidth vary.]

**Sustained bandwidth** is lower than peak due to:

- Row activation overhead (tRCD, tRP gaps in the data stream)
- Refresh operations (DRAM rows must be refreshed every ~64 ms)
- Read-to-write bus turnaround delays
- Bank conflicts reducing effective parallelism
- Command bus saturation before data bus saturation

Typical sustained efficiency is 60–80% of peak for sequential streaming workloads and lower for random access.

---

### Interaction with Cache Line Fills

When a cache miss occurs, the memory controller must fetch one cache line (64 bytes = 8 × 64-bit words). The controller maps this fill request onto the available banks:

**Without interleaving:** All 8 words come from one bank. Time ≈ tRCD + 8 × tCCD.

**With 8-bank interleaving (one word per bank):** All 8 words are fetched from 8 different banks simultaneously. After the row activation latency, data arrives in rapid succession. Time ≈ tRCD + tCL + 7 × tCCD_S (short column-column delay).

This is the dominant use case that motivates memory interleaving in practice — reducing cache miss penalty by filling cache lines faster.

---

### Critical Stride and Working Set Considerations

Programs with working sets larger than the row buffer size benefit from bank interleaving by reducing row conflicts. Programs with tight, repeated access to the same rows benefit from **row buffer locality** — keeping rows open (open-page policy) rather than precharging after every access.

Memory controllers implement **adaptive page policies**:

- **Open-page policy:** Row stays open after access; subsequent accesses to the same row are row buffer hits (tCL only — no tRCD).
- **Closed-page policy:** Row is precharged immediately after access; no row buffer hit possible but no precharge stall on next access to a different row.
- **Adaptive policy:** Controller predicts future access patterns per bank and selects open or closed policy dynamically.

[Inference: the effectiveness of adaptive policies depends on the memory controller's ability to predict access patterns; behavior varies by workload and is not guaranteed to improve latency in all cases.]

---

**Key Points**

- Memory interleaving distributes consecutive addresses across independent modules so that sequential accesses can proceed in parallel, increasing effective bandwidth without reducing per-access latency.
- Low-order interleaving (module selected by low address bits) maximizes bandwidth for sequential access; high-order interleaving provides modularity but no bandwidth benefit for sequential patterns.
- Bank conflicts arise when multiple accesses target the same module within its cycle time; stride-_k_ access with _k_ modules is the pathological case.
- XOR-based address hashing mitigates systematic bank conflicts from power-of-2 strides by remapping the bank select bits.
- DRAM internal banking allows multiple rows to be open simultaneously across banks, enabling ACT/CAS/PRE operations to be overlapped by the memory controller.
- Memory channels provide the highest level of parallelism — each channel is fully independent, and bandwidth scales linearly with channel count.
- Peak bandwidth is limited by bus width × transfer rate × channel count; sustained bandwidth is 60–80% of peak for sequential access due to DRAM protocol overhead.
- Cache line fill latency is the primary beneficiary of interleaving in a cached system — fetching 8 words from 8 banks in parallel reduces miss penalty compared to sequential fetching from one bank.

**Conclusion** Memory interleaving and banking address the fundamental mismatch between processor bandwidth demand and single-array DRAM throughput. By distributing addresses across independent memory units at multiple levels — subarrays, banks, ranks, and channels — the memory system sustains a data rate that individual arrays cannot. The design is governed by the trade-off between access pattern regularity (which interleaving exploits), bank conflict probability (which grows with contention and adversarial strides), and row buffer locality (which favors concentrated rather than distributed access). Every level of this hierarchy directly affects cache miss penalty and sustained memory bandwidth — the two quantities that dominate memory-bound application performance.

**Next Steps**

- DRAM Internals and Timing — tRCD, tCL, tRP, tRAS, tFAW and how they bound the scheduling decisions the memory controller makes
- Memory Controller Design — command scheduling algorithms (FR-FCFS, open/closed page policy, bank parallelism exploitation)
- DDR Standards — how DDR4/DDR5 encode these timing constraints and what changes across generations
- NUMA — non-uniform latency as a consequence of physically distributed banks across sockets

---

