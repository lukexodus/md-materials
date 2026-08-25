## Memory Controller Design


The memory controller (MC) is the logic block that arbitrates access to DRAM, translates processor-side requests into DRAM command sequences, enforces all DRAM timing constraints, manages refresh, and optimizes throughput by scheduling commands across multiple outstanding requests. It sits on the critical path between the last-level cache and main memory, and its scheduling decisions directly determine effective memory bandwidth and latency.

---

### Position in the Memory Hierarchy

In pre-2003 systems the MC resided on a discrete northbridge chip, introducing additional bus latency. Contemporary processors integrate the MC on-die — Intel since Nehalem (2008), AMD since K8 (2003). On-die integration eliminates the front-side bus, reducing round-trip latency from ~100 ns to ~50–70 ns (at the controller; DRAM access time is unchanged).

The MC interfaces to:

- **Upstream**: the last-level cache (LLC) and interconnect fabric (ring bus, mesh, or coherence directory) via load/store queues and the memory request queue
- **Downstream**: one or more DRAM channels, each consisting of a command/address bus, data bus, and one or more ranks of DIMMs

---

### DRAM Structural Review

The MC's design is dictated entirely by DRAM's internal structure. A DRAM rank is organized as:

**Bank → Row (wordline) → Column (bitline)**

Each bank has one **row buffer** — a sense-amplifier array that holds the currently open row. Accessing a row requires three commands in sequence:

|Command|Abbr.|Function|
|---|---|---|
|Activate|ACT|Opens a row: drives wordline, sense amplifiers latch the row into the row buffer|
|Read/Write|RD/WR|Transfers a column burst from/to the row buffer|
|Precharge|PRE|Closes the row: returns bitlines to equilibrium, prepares for next ACT|

The timing constraints between these commands are expressed as **tRCD** (ACT→RD/WR minimum), **tCL** (RD command to data, CAS latency), **tRP** (PRE→ACT minimum), **tRAS** (ACT→PRE minimum), and many others. The MC must track these per-bank timing constraints and issue commands only when all relevant timers have expired.

---

### MC Internal Structure---

### Address Mapping

The first decision the MC makes on receiving a request is how to decompose the physical address into DRAM coordinates: **channel, rank, bank, row, column**.

The mapping is not fixed by hardware — the MC implements a programmable mapping scheme selected during initialization. The choice has significant impact on parallelism and conflict rates.

#### Mapping Schemes

**Row-interleaved (coarse):** consecutive physical addresses map to consecutive rows within one bank. Sequential accesses hit the same open row (row buffer hits) but serialize on one bank — no bank-level parallelism.

**Cache-line interleaved (fine):** consecutive cache lines map to consecutive banks (or ranks). A sequential access stream spreads across banks, enabling bank-level parallelism. This is the standard mapping on DDR systems. The mapping typically looks like:

```
[tag | row | bank | rank | channel | col | offset]
```

With the column and offset at the low bits, bank in the middle, and row at the high bits — so sequential cache-line accesses advance the bank index before the row index.

**XOR-based mapping:** row address bits are XOR'd with bank address bits. Reduces bank conflict probability for strided access patterns (e.g., matrix accesses with stride = number of banks × cache line size, which would otherwise hash to the same bank). Used in some modern MCs.

**Sub-rank interleaving (channel striping):** on multi-channel systems, the channel bit is placed low (at the cache-line granularity) so consecutive cache lines alternate channels. Both channels can serve data simultaneously, doubling effective bandwidth for sequential streams.

---

### Row Buffer Management Policy

The row buffer state at each bank is the central resource the scheduler manages. Two fundamental policies:

#### Open-Page Policy

After a RD/WR, the row remains open (no PRE issued). Subsequent accesses to the same row are **row buffer hits** — served with only tCL latency (no ACT or PRE required). Optimal for workloads with high row buffer locality: sequential streams, large working sets with spatial locality.

Cost: if the next access to that bank hits a different row, a **row buffer conflict** occurs — PRE + ACT must precede the RD/WR, adding tRP + tRCD to the latency. Under random-address workloads, open-page policy increases average latency relative to closed-page.

#### Closed-Page Policy

After every RD/WR, an immediate PRE is issued. Every subsequent access incurs a row miss (PRE already done → only ACT + RD needed, saving tRP but not tRCD). Eliminates conflict penalty at the cost of never capturing row buffer hits. Optimal for workloads with no row buffer locality: random access, small working sets.

#### Adaptive Policy

Contemporary MCs implement adaptive row buffer management: monitor hit/miss rates per bank, and switch between open and closed policy per bank dynamically. Intel IMC and AMD UMC use variants of this.

---

### Command Scheduling

The scheduler selects which command from the command queue to issue on the next available command bus slot, subject to timing constraints. This is a constrained optimization: maximize throughput or minimize latency given tRCD, tCL, tRP, tRAS, tFAW, tRRD, tWTR, and other inter-command timing rules.

#### FR-FCFS (First-Ready, First-Come-First-Served)

The dominant scheduling algorithm. Priority ordering:

1. **Ready commands** (all timing constraints satisfied) over not-ready commands
2. Among ready commands: **row buffer hits** first (RD/WR to open row)
3. Among same row-buffer status: **older requests first** (FCFS)

FR-FCFS maximizes row buffer hit rate and thereby throughput. For sequential or spatially local workloads it approaches the bandwidth limit of the DRAM channel.

**Fairness problem:** FR-FCFS is unfair — row-buffer-hit-generating threads (sequential, bandwidth-intensive) can starve row-buffer-miss-generating threads (random, latency-sensitive) indefinitely. In a multicore system with shared memory controller, this becomes a QoS problem.

#### Starvation Prevention

Several mechanisms bound starvation under FR-FCFS:

- **Age-based promotion**: once a request has waited longer than a threshold, it is promoted to highest priority regardless of row buffer status
- **Request cap per row**: limit the number of consecutive hits served from one open row before forcing a precharge
- **PAR-BS (Parallelism-Aware Batch Scheduling)**: group requests into batches; within a batch, serve all requests before admitting new ones. Provides inter-thread fairness while preserving within-batch hit-rate optimization

#### ATLAS, TCM, and QoS-Oriented Schedulers

Research schedulers (ATLAS, TCM) prioritize threads that are memory-bandwidth-sensitive (low memory intensity, high LLC miss rate) to minimize overall slowdown. These are not yet standard in commercial MCs but influence QoS mechanisms in server-class designs.

---

### Timing Constraint Enforcement

The timing engine maintains a set of countdown timers per bank (and some global across banks/ranks). A command may only be issued when all applicable timers have expired. Key constraints:

|Parameter|Meaning|Typical DDR4 value|
|---|---|---|
|tRCD|ACT → RD/WR minimum|14–16 ns|
|tCL|RD command → first data|14–16 ns|
|tRP|PRE → ACT minimum|14–16 ns|
|tRAS|ACT → PRE minimum|32–35 ns|
|tRC|ACT → ACT same bank (= tRAS + tRP)|46–51 ns|
|tRRD|ACT → ACT different bank, same rank|5–6 ns|
|tFAW|Four-activation window: max 4 ACTs per rank in tFAW|25–35 ns|
|tWTR|WR → RD minimum (write data must clear before read turnaround)|7.5–10 ns|
|tRTW|RD → WR minimum (bus turnaround)|~2–4 ns|
|tWR|WR → PRE minimum|15 ns|

tFAW (four-activation window) is a power constraint: each row activation draws a current spike; the DRAM power delivery network limits how many can occur in a given window.

The MC implements these as a set of down-counters, each loaded on command issue and checked before the next command of the relevant type may be issued. On heavily banked systems (8–16 banks per rank, 2–4 ranks) the number of active timers is large; the critical path through the timing-check logic is a design bottleneck.

---

### Refresh Management

DRAM cells leak charge and must be refreshed every **tREFI** (refresh interval) — typically 7.8 µs at normal temperature (3.9 µs above 85°C for extended temperature operation). A REF command refreshes all rows in all banks of a rank simultaneously, requiring the rank to be quiescent for **tRFC** (refresh cycle time) — 260–550 ns depending on DIMM density.

During tRFC, no other command may be issued to that rank. This imposes a bandwidth tax:

$$
\text{Refresh overhead} = \frac{t_{RFC}}{t_{REFI}} \approx \frac{350,\text{ns}}{7800,\text{ns}} \approx 4.5%
$$

Strategies to mitigate refresh impact:

**Refresh postponement:** the MC may delay a REF command by up to 8 tREFI intervals (per JEDEC) if the rank is busy, then issue up to 8 consecutive REFs when idle. Useful for latency-sensitive requests; must not exceed the 8-interval debt limit.

**Fine-grained refresh (per-bank refresh):** DDR5 and LPDDR4/5 support per-bank refresh (PBR), where individual banks can be refreshed independently. Other banks remain accessible during one bank's refresh. Reduces worst-case stall from tRFC to roughly tRFC/banks.

**Distributed refresh (REFpb on DDR5):** DDR5 mandates per-bank refresh, distributing the refresh overhead across 8 banks and allowing finer-grained scheduling around it.

---

### Write Queue and Read/Write Switching

Reads and writes share the data bus (bidirectional in DDR). Bus direction switching incurs a **turnaround penalty** (tRTW, tWTR) of several nanoseconds, consuming bus time.

To minimize turnarounds, MCs maintain a separate write queue and batch writes: accumulate writes until the write queue reaches a high-watermark threshold, then drain writes in a burst before switching back to reads. The policy has two thresholds:

- **High watermark**: force a write-drain when write queue occupancy reaches this level
- **Low watermark**: stop draining and return to reads when occupancy falls here

Tuning these thresholds is workload-dependent. Write-dominated workloads benefit from aggressive write batching; read-latency-critical workloads favor frequent switching to avoid read starvation.

---

### Power Management

The MC manages DRAM power states to reduce idle power:

**Precharge power-down (PPD):** when a rank is idle with all banks precharged, the MC may issue a power-down entry command. Exit latency is tXP (~6 ns DDR4) — low enough that PPD is frequently entered during short idle gaps.

**Active power-down:** rank is idle with a row open. Higher exit latency (tXPDLL) than PPD; used for longer idle periods.

**Self-refresh:** the DRAM internally refreshes itself; the MC releases the clock and command bus. Exit latency is hundreds of nanoseconds. Used during system-level idle states (ACPI C-states). On mobile LPDDR systems, self-refresh entry/exit is managed aggressively for battery life.

**DVFS on the MC:** the MC's logic domain can run at reduced voltage/frequency during low-utilization periods. The DRAM interface frequency is independent and constrained by the DDR standard; only MC internal logic clocking changes.

---

### Multi-Channel and Multi-Rank Coordination

Modern desktop and server MCs operate 2–8 channels simultaneously. Each channel is independent; the MC instantiates one scheduler and command queue per channel. The address mapping (channel bit placement) determines how traffic distributes across channels.

Within a channel, multiple ranks share the command/address bus but have independent data buses (in some configurations) or share a data bus with rank-select signals. Commands to different ranks may overlap in flight; timing rules (tRRD_L, tRRD_S for same/different bank groups in DDR4) govern the minimum spacing.

**Bank groups (DDR4/DDR5):** DDR4 introduced bank groups (BG), partitioning the 16 banks into 4 groups of 4. tCCD_S (same-rank, different bank group) is shorter than tCCD_L (same bank group), allowing higher command rate by spreading accesses across groups. The MC address mapper places sequential cache lines in different bank groups where possible.

---

### On-Die ECC and Error Handling

Server MCs support ECC DRAM (SECDED over a 72-bit-wide channel: 64 data + 8 check bits). The MC scrubber periodically reads and rewrites memory to correct single-bit errors before they accumulate into uncorrectable double-bit errors. On a correctable error, the MC logs it; on an uncorrectable error, it raises a machine-check exception (MCE). SDDC (Single Device Data Correction) — also called Chipkill — corrects failures of an entire DRAM device using wider codes (e.g., x4 DRAM with extended ECC across multiple devices).

---

**Next Steps:** DDR4/DDR5 signal-level protocol · DRAM internal timing and bank architecture · Memory interleaving and banking for bandwidth · NUMA topology and inter-socket MC coordination · Persistent memory (CXL-attached, NVDIMM) controller differences.

---

