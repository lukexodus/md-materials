## Memory Bandwidth and Latency


Bandwidth and latency are the two fundamental axes of memory system performance. They are distinct, often in tension, and impose different constraints on different workload classes. Understanding both — and the microarchitectural mechanisms that address each — is prerequisite to reasoning about any memory-bound system.

---

### Definitions

**Latency** is the time elapsed from when a memory request is issued to when the requested data is available to the processor. It is measured in nanoseconds or clock cycles.

**Bandwidth** is the rate at which data can be transferred between the memory system and the processor. It is measured in bytes per second (GB/s).

These are related but independent:

```
Bandwidth = Transfer_size / Latency    (only for a single sequential transfer)
```

For concurrent requests, bandwidth and latency decouple entirely. A system can sustain high bandwidth through request pipelining while individual latency remains high.

---

### Latency Anatomy

A DRAM access decomposes into a sequence of timed operations. Each is a mandatory delay imposed by DRAM physics.

<svg viewBox="0 0 680 210" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="210" fill="#1e1e2e"/> <!-- Timeline bar --> <line x1="30" y1="80" x2="660" y2="80" stroke="#585b70" stroke-width="1.5"/> <!-- Segments --> <!-- tRCD --> <rect x="30" y="58" width="110" height="28" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.5"/> <text x="85" y="76" fill="#89b4fa" text-anchor="middle">tRCD = 14ns</text> <!-- tCL --> <rect x="140" y="58" width="110" height="28" rx="3" fill="#2a1a3a" stroke="#cba6f7" stroke-width="1.5"/> <text x="195" y="76" fill="#cba6f7" text-anchor="middle">tCL = 14ns</text> <!-- Bus transfer --> <rect x="250" y="58" width="110" height="28" rx="3" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="1.5"/> <text x="305" y="76" fill="#a6e3a1" text-anchor="middle">Bus = 8ns</text> <!-- Controller overhead --> <rect x="360" y="58" width="140" height="28" rx="3" fill="#3a2a1a" stroke="#fab387" stroke-width="1.5"/> <text x="430" y="76" fill="#fab387" text-anchor="middle">Controller = 20ns</text> <!-- tRP (precharge, if row miss) --> <rect x="500" y="58" width="110" height="28" rx="3" fill="#3a1e1e" stroke="#f38ba8" stroke-width="1.5" stroke-dasharray="4,2"/> <text x="555" y="70" fill="#f38ba8" text-anchor="middle">tRP = 14ns</text> <text x="555" y="82" fill="#f38ba8" text-anchor="middle" font-size="9">(row miss only)</text> <!-- Total annotation --> <line x1="30" y1="100" x2="500" y2="100" stroke="#cdd6f4" stroke-width="1" stroke-dasharray="3,2"/> <line x1="30" y1="96" x2="30" y2="104" stroke="#cdd6f4" stroke-width="1.5"/> <line x1="500" y1="96" x2="500" y2="104" stroke="#cdd6f4" stroke-width="1.5"/> <text x="265" y="116" fill="#cdd6f4" text-anchor="middle" font-size="11">~56ns row hit total</text> <line x1="30" y1="130" x2="660" y2="130" stroke="#f38ba8" stroke-width="1" stroke-dasharray="3,2"/> <line x1="660" y1="126" x2="660" y2="134" stroke="#f38ba8" stroke-width="1.5"/> <text x="420" y="146" fill="#f38ba8" text-anchor="middle" font-size="11">~70ns row miss total</text> <!-- Labels below -->

<text x="85" y="165" fill="#89b4fa" text-anchor="middle" font-size="10">Row Activate</text> <text x="85" y="177" fill="#585b70" text-anchor="middle" font-size="9">RAS → sense amps</text>

<text x="195" y="165" fill="#cba6f7" text-anchor="middle" font-size="10">Column Latch</text> <text x="195" y="177" fill="#585b70" text-anchor="middle" font-size="9">CAS → data out</text>

<text x="305" y="165" fill="#a6e3a1" text-anchor="middle" font-size="10">Data Transfer</text> <text x="305" y="177" fill="#585b70" text-anchor="middle" font-size="9">DRAM → controller</text>

<text x="430" y="165" fill="#fab387" text-anchor="middle" font-size="10">Memory Controller</text> <text x="430" y="177" fill="#585b70" text-anchor="middle" font-size="9">Queue + arbitration</text>

<text x="555" y="165" fill="#f38ba8" text-anchor="middle" font-size="10">Precharge</text> <text x="555" y="177" fill="#585b70" text-anchor="middle" font-size="9">Close open row</text>

<text x="340" y="198" fill="#585b70" text-anchor="middle" font-size="10">Values representative of DDR4-3200 at CL22; actual timings vary by device and configuration</text> </svg>

#### DRAM Timing Parameters

|Parameter|Symbol|Description|
|---|---|---|
|RAS-to-CAS delay|tRCD|Time from row activation to column access|
|CAS latency|CL / tCL|Time from column command to first data bit|
|Row precharge|tRP|Time to close an open row before opening another|
|Active-to-active|tRAS|Minimum time a row must remain open|
|Row cycle time|tRC|tRAS + tRP — full open/close cycle|
|Refresh interval|tREFI|Time between required DRAM refresh cycles|
|Write recovery|tWR|Time after write before precharge can begin|

**Timing notation** such as 22-22-22-52 denotes CL-tRCD-tRP-tRAS in clock cycles at a given data rate.

#### Row Buffer and Its Effect on Latency

The DRAM row buffer holds the last activated row (~8KB typically). Subsequent accesses to the same row hit the row buffer without requiring a new activate command:

|Access Type|Latency|Condition|
|---|---|---|
|Row buffer hit|tCL only|Access to currently open row|
|Row buffer miss|tRP + tRCD + tCL|Different row in same bank|
|Row buffer empty|tRCD + tCL|No row currently open|

Row buffer hit rate is heavily workload-dependent. Sequential access patterns exploit row buffer locality; random access patterns largely do not.

---

### Bandwidth: Sources and Limits

Peak theoretical bandwidth is determined by the memory interface:

```
Peak_BW = Data_rate × Bus_width × Channels
        = (Clock × 2) × (64 bits / 8) × N_channels
```

**Example — DDR4-3200, dual channel:**

```
Peak_BW = 3200 MT/s × 8 bytes × 2 = 51.2 GB/s
```

**Example — DDR5-6400, dual channel:**

```
Peak_BW = 6400 MT/s × 8 bytes × 2 = 102.4 GB/s
```

[Inference] Sustained real-world bandwidth is substantially lower than peak due to protocol overhead, refresh pauses, timing gaps between bursts, and address mapping inefficiencies. Actual achievable bandwidth depends on workload and system configuration.

#### Bandwidth Efficiency Losses

|Loss Source|Mechanism|Typical Impact|
|---|---|---|
|DRAM refresh|All banks in a rank pause for tRFC (~350ns for 16Gb)|~3–5% overhead|
|Burst overhead|Command/address cycles interspersed with data|Reduces efficiency at short burst lengths|
|Row misses|Precharge + activate added before data|Highly access-pattern dependent|
|Rank switching|tRTT and tWTR penalties on rank change|Depends on access interleaving|
|Write-to-read turnaround|tWTR delay when switching bus direction|Bidirectional bus contention|
|Bank conflicts|Two requests to same bank stall behind each other|Depends on address distribution|

---

### Bandwidth vs. Latency: The Fundamental Tension

Techniques that improve bandwidth generally worsen or leave unaffected single-access latency, and vice versa.

<svg viewBox="0 0 680 220" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="220" fill="#1e1e2e"/> <!-- Axes --> <line x1="60" y1="170" x2="640" y2="170" stroke="#585b70" stroke-width="1.5" marker-end="url(#bax)"/> <line x1="60" y1="170" x2="60" y2="20" stroke="#585b70" stroke-width="1.5" marker-end="url(#bay)"/> <text x="650" y="174" fill="#585b70" font-size="11">BW</text> <text x="40" y="16" fill="#585b70" font-size="11">Lat</text> <!-- Curve: as outstanding requests increase, BW rises, latency rises --> <!-- Points: (low BW, low lat) to (high BW, high lat) -->

<polyline points="80,155 140,140 200,122 280,105 370,92 460,84 540,80 610,78" fill="none" stroke="#89b4fa" stroke-width="2"/>

<!-- Annotations --> <!-- Single request --> <circle cx="80" cy="155" r="5" fill="#a6e3a1"/> <text x="85" y="145" fill="#a6e3a1" font-size="10">1 request</text> <text x="85" y="157" fill="#585b70" font-size="9">low BW, low latency</text> <!-- Many concurrent --> <circle cx="540" cy="80" r="5" fill="#fab387"/> <text x="510" y="68" fill="#fab387" font-size="10">many concurrent</text> <text x="510" y="80" fill="#585b70" font-size="9">high BW, high latency</text> <!-- Knee --> <circle cx="280" cy="105" r="5" fill="#cba6f7"/> <line x1="280" y1="105" x2="280" y2="145" stroke="#cba6f7" stroke-width="1" stroke-dasharray="3,2"/> <text x="255" y="158" fill="#cba6f7" font-size="10">knee of curve</text> <!-- Label -->

<text x="350" y="195" fill="#585b70" text-anchor="middle" font-size="10">Memory latency under load — queuing increases observed latency as BW utilization rises</text>

<defs> <marker id="bax" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#585b70"/></marker> <marker id="bay" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#585b70"/></marker> </defs> </svg>

This curve arises from **queuing theory** (M/D/1 model): as memory controller utilization increases toward saturation, queue depth grows and average wait time increases superlinearly. Even before saturation, latency under load is meaningfully higher than unloaded latency.

---

### Memory Interleaving and Banking

#### Bank-Level Interleaving

A DRAM module is divided into independent **banks** (typically 8–16 per rank). Banks have independent row buffers and can service requests in parallel, as long as requests map to different banks.

Address interleaving distributes consecutive cache lines across banks:

```
Address bits:  [ Row | Bank | Column | Byte_offset ]
```

With 8 banks, 8 consecutive cache lines land in 8 different banks — all can be serviced concurrently, hiding the activation latency of each.

#### Channel Interleaving

Multiple independent memory channels each have their own bus, controller, and DIMM set. The memory controller interleaves requests across channels to multiply available bandwidth:

```
Effective_BW = N_channels × Per_channel_BW
```

Typical desktop: 2 channels. Server (AMD EPYC, Intel Xeon Scalable): 6–12 channels.

<svg viewBox="0 0 680 190" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="190" fill="#1e1e2e"/> <!-- CPU --> <rect x="270" y="10" width="140" height="40" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="2"/> <text x="340" y="35" fill="#89b4fa" text-anchor="middle">Memory Controller</text> <!-- Channel 0 --> <rect x="60" y="110" width="120" height="50" rx="4" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="1.5"/> <text x="120" y="130" fill="#a6e3a1" text-anchor="middle">Channel 0</text> <text x="120" y="148" fill="#585b70" text-anchor="middle">DIMM A</text> <!-- Channel 1 --> <rect x="220" y="110" width="120" height="50" rx="4" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="1.5"/> <text x="280" y="130" fill="#a6e3a1" text-anchor="middle">Channel 1</text> <text x="280" y="148" fill="#585b70" text-anchor="middle">DIMM B</text> <!-- Channel 2 --> <rect x="380" y="110" width="120" height="50" rx="4" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="1.5"/> <text x="440" y="130" fill="#a6e3a1" text-anchor="middle">Channel 2</text> <text x="440" y="148" fill="#585b70" text-anchor="middle">DIMM C</text> <!-- Channel 3 --> <rect x="500" y="110" width="120" height="50" rx="4" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="1.5"/> <text x="560" y="130" fill="#a6e3a1" text-anchor="middle">Channel 3</text> <text x="560" y="148" fill="#585b70" text-anchor="middle">DIMM D</text> <!-- Wires from controller --> <line x1="300" y1="50" x2="120" y2="110" stroke="#a6e3a1" stroke-width="1.5" marker-end="url(#bch)"/> <line x1="320" y1="50" x2="280" y2="110" stroke="#a6e3a1" stroke-width="1.5" marker-end="url(#bch)"/> <line x1="360" y1="50" x2="440" y2="110" stroke="#a6e3a1" stroke-width="1.5" marker-end="url(#bch)"/> <line x1="380" y1="50" x2="560" y2="110" stroke="#a6e3a1" stroke-width="1.5" marker-end="url(#bch)"/> <!-- Interleave annotation -->

<text x="340" y="175" fill="#585b70" text-anchor="middle">Consecutive cache lines interleaved: line 0→Ch0, line 1→Ch1, line 2→Ch2, line 3→Ch3</text>

<defs> <marker id="bch" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#a6e3a1"/></marker> </defs> </svg>

#### Rank Interleaving

Within a channel, multiple ranks (each a full set of DRAM chips) can be accessed in a pipelined fashion. While one rank is processing a command, the controller issues a command to another rank — hiding per-rank latency behind concurrent activity.

---

### Latency Hiding Techniques

Because DRAM latency is far higher than cache latency, modern processors employ several mechanisms to tolerate it rather than reduce it.

#### Out-of-Order Memory Access

An out-of-order processor can have multiple load/store operations in flight simultaneously. The memory controller aggregates these into a queue and reorders or coalesces them for efficiency. The processor continues executing independent instructions while waiting for outstanding loads.

**Memory-level parallelism (MLP)** is the number of cache misses that overlap in time. High MLP allows the memory system to pipeline requests, improving effective bandwidth utilization.

#### Hardware Prefetching

The prefetch unit predicts future memory accesses and issues requests before the processor explicitly demands the data. Common prefetcher types:

|Prefetcher|Detection Method|Effective For|
|---|---|---|
|Sequential / stream|Detects stride-1 access pattern|Linear array traversal|
|Stride prefetcher|Detects constant stride N|Strided array access|
|GHB (Global History Buffer)|Tracks irregular patterns in history table|Linked list traversal|
|SMS (Spatial Memory Streaming)|Learns per-region access footprints|Object and struct access|

Prefetching converts latency-bound access into bandwidth-bound access: data arrives before the demand miss occurs, so the CPU does not stall. However, incorrect prefetches consume bandwidth and pollute caches.

#### Non-Temporal Stores

For streaming write workloads where data will not be reread, **non-temporal (NT) stores** bypass the cache entirely and write directly to memory. This avoids the read-for-ownership penalty (loading a cache line into M state before writing) and does not pollute caches with write-once data.

```asm
; x86 non-temporal store
movntps [rdi], xmm0   ; write 16 bytes directly to memory, bypassing cache
; must be followed by sfence before other threads read the data
```

#### Write Combining Buffers

The processor maintains a small set of **write combining (WC) buffers** — typically 4–12 entries. Writes to the same cache line are accumulated in a WC buffer and flushed to memory as a full burst transaction when the buffer is full or explicitly flushed. This converts multiple partial writes into a single full-line transfer, improving bus efficiency.

---

### DDR Standards: Bandwidth and Latency Progression

|Standard|Data Rate (MT/s)|Peak BW/channel|Typical CL|Unloaded Latency|
|---|---|---|---|---|
|DDR3-1600|1600|12.8 GB/s|11|~13.75 ns|
|DDR4-2400|2400|19.2 GB/s|17|~14.17 ns|
|DDR4-3200|3200|25.6 GB/s|22|~13.75 ns|
|DDR5-4800|4800|38.4 GB/s|40|~16.67 ns|
|DDR5-6400|6400|51.2 GB/s|46|~14.37 ns|
|LPDDR5X-8533|8533|68.3 GB/s|~46|~10.8 ns|

[Unverified] Exact latency values depend on specific module binning, XMP/EXPO profiles, and motherboard implementation. Values above are representative estimates derived from published timing specifications and are not guaranteed to match any specific product.

An important observation: as DDR generations increase data rate, CAS latency in cycles also increases, keeping absolute latency in nanoseconds roughly constant or slightly higher. Bandwidth scales; latency does not.

---

### The Roofline Model and Memory Boundedness

The Roofline model characterizes whether a kernel is **compute-bound** or **memory-bandwidth-bound** using **arithmetic intensity** (AI):

```
Arithmetic Intensity = FLOPs executed / Bytes transferred from memory
```

<svg viewBox="0 0 680 240" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="240" fill="#1e1e2e"/> <!-- Axes --> <line x1="60" y1="190" x2="640" y2="190" stroke="#585b70" stroke-width="1.5" marker-end="url(#rlx)"/> <line x1="60" y1="190" x2="60" y2="20" stroke="#585b70" stroke-width="1.5" marker-end="url(#rly)"/> <text x="350" y="210" fill="#585b70" text-anchor="middle">Arithmetic Intensity (FLOP/byte) →</text> <text x="20" y="110" fill="#585b70" text-anchor="middle" font-size="10" transform="rotate(-90,20,110)">Performance (GFLOP/s) →</text> <!-- Roofline: bandwidth slope then flat peak --> <!-- Slope: from (60,190) to (280,60) — memory bound region --> <line x1="60" y1="190" x2="300" y2="50" stroke="#89b4fa" stroke-width="2.5"/> <!-- Flat: from (300,50) to (630,50) — compute bound --> <line x1="300" y1="50" x2="630" y2="50" stroke="#a6e3a1" stroke-width="2.5"/> <!-- Ridge point --> <circle cx="300" cy="50" r="5" fill="#fab387"/> <line x1="300" y1="50" x2="300" y2="190" stroke="#fab387" stroke-width="1" stroke-dasharray="3,2"/> <text x="300" y="205" fill="#fab387" text-anchor="middle" font-size="10">ridge point</text> <!-- Region labels -->

<text x="150" y="145" fill="#89b4fa" text-anchor="middle">Memory</text> <text x="150" y="158" fill="#89b4fa" text-anchor="middle">Bandwidth</text> <text x="150" y="171" fill="#89b4fa" text-anchor="middle">Bound</text>

<text x="470" y="42" fill="#a6e3a1" text-anchor="middle">Compute Bound</text>

<!-- Kernel dots --> <circle cx="130" cy="145" r="5" fill="#f38ba8"/> <text x="132" y="135" fill="#f38ba8" font-size="10">STREAM</text> <circle cx="200" cy="110" r="5" fill="#cba6f7"/> <text x="202" y="100" fill="#cba6f7" font-size="10">SpMV</text> <circle cx="480" cy="50" r="5" fill="#fab387"/> <text x="482" y="40" fill="#fab387" font-size="10">DGEMM</text> <!-- BW ceiling label -->

<text x="100" y="55" fill="#89b4fa" font-size="10">slope = peak BW</text>

<!-- Compute ceiling label -->

<text x="560" y="44" fill="#a6e3a1" font-size="10">peak FLOP/s</text>

<defs> <marker id="rlx" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#585b70"/></marker> <marker id="rly" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#585b70"/></marker> </defs> </svg>

A kernel below the bandwidth roof is memory-bandwidth-bound: increasing compute throughput does not improve performance. Only increasing bandwidth, improving data reuse (raising AI), or reducing working set size helps.

---

### NUMA Latency Effects

In multi-socket systems, memory is physically attached to specific sockets. A core accessing memory on its local socket (**local NUMA access**) incurs lower latency than accessing memory on a remote socket (**remote NUMA access**), which must traverse the inter-socket interconnect (e.g., AMD Infinity Fabric, Intel UPI).

|Access Type|Typical Latency|Typical Bandwidth|
|---|---|---|
|Local DRAM|~70–80 ns|Full channel BW|
|Remote DRAM (1 hop)|~120–160 ns|Reduced by interconnect BW|
|Remote DRAM (2 hops)|~200–250 ns|Further reduced|

[Unverified] Values are representative of recent server platforms; actual measurements depend on specific hardware and configuration.

NUMA-aware allocation policies (first-touch, interleaved, preferred-node) are essential for memory-bound workloads on multi-socket systems. Misplaced allocations in NUMA systems can cause remote accesses that halve effective memory bandwidth.

---

### ECC and Bandwidth Overhead

ECC (Error-Correcting Code) memory adds check bits — typically 8 bits per 64-bit data word — requiring wider DRAM bus configurations (72-bit instead of 64-bit per channel). The overhead is:

- **Storage**: ~12.5% additional DRAM capacity used for check bits
- **Bandwidth**: Minimal — the wider bus carries check bits alongside data in the same transfer
- **Latency**: Small additional pipeline stages for syndrome computation on read; scrubbing operations add background memory traffic

---

### Bandwidth Measurement: STREAM Benchmark

The STREAM benchmark is the standard for measuring sustained memory bandwidth. It defines four kernels:

|Kernel|Operation|Arithmetic Intensity|
|---|---|---|
|Copy|a[i] = b[i]|0 FLOP/byte (pure BW)|
|Scale|a[i] = s × b[i]|1 FLOP / 16 bytes|
|Add|a[i] = b[i] + c[i]|1 FLOP / 24 bytes|
|Triad|a[i] = b[i] + s × c[i]|2 FLOPs / 24 bytes|

Triad is the canonical reported figure. STREAM arrays are sized to exceed all cache levels, so results reflect true DRAM bandwidth, not cache bandwidth. [Inference] STREAM Triad results reported in benchmarks represent an upper bound on sustained bandwidth for streaming workloads; application-level bandwidth is typically lower.

---

**Conclusion:** Memory latency is constrained by DRAM physics — the sequence of row activation, column selection, and data transfer — and has remained roughly constant in absolute nanoseconds across DDR generations even as clock rates have increased. Memory bandwidth scales with data rate, channel count, and bank/rank parallelism, and is the primary resource contended by throughput-oriented workloads. The two metrics impose fundamentally different demands on the memory system and require different optimization strategies: latency reduction through prefetching and MLP; bandwidth improvement through interleaving, wide buses, and access pattern optimization.

**Next Steps:** Proceed to Storage Systems to see how latency and bandwidth characteristics change across the full memory hierarchy, or to the Roofline Model in Module 14 for a formal treatment of compute versus bandwidth boundedness and its implications for performance analysis.

---

