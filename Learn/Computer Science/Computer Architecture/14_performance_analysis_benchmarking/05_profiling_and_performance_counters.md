## Profiling and Performance Counters


Performance analysis requires moving beyond wall-clock time to understand _why_ a program executes at a given speed. Profiling is the discipline of measuring program behavior during execution. Performance counters are the hardware mechanism that makes cycle-accurate, low-overhead profiling possible. Together they form the primary feedback loop for architectural optimization, compiler tuning, and application development.

---

### Hardware Performance Monitoring Units

Every modern processor contains a **Performance Monitoring Unit (PMU)** — a set of hardware registers that count microarchitectural events occurring during program execution.

#### PMU Components

**Performance Monitoring Counters (PMCs)** Fixed-width hardware counters (typically 48 bits on x86) that increment each time a specified event occurs. Most PMUs provide 4–8 general-purpose programmable counters per logical core, plus a small number of fixed-function counters.

**Event Select Registers (IA32_PERFEVTSELx on x86)** Control registers that configure what each counter measures. Each register encodes:

|Field|Bits|Purpose|
|---|---|---|
|Event Select|7:0|Identifies the event category|
|Unit Mask (UMASK)|15:8|Qualifies the event within the category|
|USR|16|Count in user mode (ring 3)|
|OS|17|Count in kernel mode (ring 0)|
|Edge detect|18|Count transitions rather than cycles in state|
|PIN control|19|Drive external pin on overflow|
|APIC interrupt|20|Generate interrupt on counter overflow|
|EN|22|Enable counter|
|INV|23|Invert CMASK comparison|
|CMASK|31:24|Count only when event rate ≥ CMASK per cycle|

**Fixed-Function Counters** Three counters on Intel that always measure the same events regardless of configuration:

- `FIXED_CTR0`: Instructions Retired
- `FIXED_CTR1`: Unhalted Core Cycles
- `FIXED_CTR2`: Unhalted Reference Cycles (at base frequency, not accounting for turbo)

**PERF_GLOBAL_CTRL / PERF_GLOBAL_STATUS** Master enable and overflow status registers. Overflow status is used by the PMI (Performance Monitoring Interrupt) handler to identify which counter fired.

---

### Event Taxonomy

PMU events fall into well-defined categories. The precise event codes are microarchitecture-specific (documented in Intel's Perfmon event tables and AMD's PPR).

#### Front-End Events

|Event|Meaning|
|---|---|
|`INST_RETIRED.ANY`|Instructions retired (completed, not speculative)|
|`CPU_CLK_UNHALTED.THREAD`|Cycles when the thread is not halted|
|`IDQ_UOPS_NOT_DELIVERED`|Cycles where the front-end delivered fewer µops than the back-end could accept|
|`FRONTEND_RETIRED.LATENCY_GE_x`|Instructions delayed ≥ x cycles in the front-end|
|`ICACHE_16B.IFDATA_STALL`|Cycles stalled on instruction cache miss|
|`DECODE.LCP`|Length-Changing Prefix decode stalls (x86 legacy)|

#### Execution / Back-End Events

|Event|Meaning|
|---|---|
|`UOPS_ISSUED.ANY`|µops dispatched to the back-end|
|`UOPS_EXECUTED.THREAD`|µops that actually executed on an execution port|
|`RESOURCE_STALLS.ANY`|Cycles where the ROB or RS is full and front-end is stalled|
|`CYCLE_ACTIVITY.STALLS_MEM_ANY`|Cycles stalled waiting for any memory operation|
|`EXE_ACTIVITY.BOUND_ON_STORES`|Cycles where execution is bound by store buffer full|

#### Memory Hierarchy Events

|Event|Meaning|
|---|---|
|`MEM_LOAD_RETIRED.L1_HIT`|Loads that hit L1 data cache|
|`MEM_LOAD_RETIRED.L2_MISS`|Loads that missed L2|
|`MEM_LOAD_RETIRED.LLC_MISS`|Loads that missed the LLC (went to DRAM)|
|`L2_RQSTS.MISS`|All L2 misses (loads + stores + prefetches)|
|`OFFCORE_REQUESTS.ALL_DATA_RD`|Requests sent off-core for data|
|`MEMORY_ACTIVITY.STALLS_L1D_MISS`|Cycles stalled due to L1-D miss|
|`DTLB_LOAD_MISSES.WALK_COMPLETED`|Completed TLB walks (page table walks)|

#### Branch Events

|Event|Meaning|
|---|---|
|`BR_INST_RETIRED.ALL_BRANCHES`|All retired branch instructions|
|`BR_MISP_RETIRED.ALL_BRANCHES`|Mispredicted branches|
|`BR_MISP_RETIRED.COND_TAKEN`|Mispredicted taken conditional branches|
|`MACHINE_CLEARS.COUNT`|Pipeline nuke events (misprediction + memory ordering + SMC)|

---

### Derived Metrics

Raw counter values are combined into normalized metrics that are architecture-independent and interpretable.

#### Core Metrics

$$\text{IPC} = \frac{\texttt{INST_RETIRED.ANY}}{\texttt{CPU_CLK_UNHALTED.THREAD}}$$

$$\text{CPI} = \frac{1}{\text{IPC}}$$

$$\text{Branch Misprediction Rate} = \frac{\texttt{BR_MISP_RETIRED.ALL_BRANCHES}}{\texttt{BR_INST_RETIRED.ALL_BRANCHES}}$$

$$\text{LLC Miss Rate} = \frac{\texttt{MEM_LOAD_RETIRED.LLC_MISS}}{\texttt{INST_RETIRED.ANY}}$$

$$\text{MPKI (Misses Per Kilo-Instruction)} = \frac{\text{Cache Misses}}{\texttt{INST_RETIRED.ANY}} \times 1000$$

MPKI is preferred over miss rate because it normalizes across workloads with different instruction mixes.

#### Retirement Efficiency

$$\text{Retirement Efficiency} = \frac{\texttt{UOPS_RETIRED.ANY}}{\texttt{UOPS_ISSUED.ANY}}$$

Values below 1.0 indicate speculative work that was squashed (mispredictions, memory order violations).

---

### Top-Down Microarchitecture Analysis (TMA)

TMA, formalized by Intel engineer Ahmad Yasin, provides a hierarchical framework for attributing pipeline slots to four mutually exclusive, collectively exhaustive categories. A **pipeline slot** is the opportunity to process one µop in one cycle — with a 4-wide pipeline, there are 4 slots per cycle.

```svg
<svg viewBox="0 0 540 310" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <!-- Root -->
  <rect x="170" y="10" width="200" height="36" rx="5" fill="#3a3a5c" stroke="#7070aa" stroke-width="1.5"/>
  <text x="270" y="33" text-anchor="middle" fill="white" font-size="12">Pipeline Slots</text>
  <!-- Level 1 boxes -->
  <rect x="10" y="80" width="110" height="36" rx="5" fill="#2a6090" stroke="#4a90c0" stroke-width="1.5"/>
  <text x="65" y="103" text-anchor="middle" fill="white">Front-End Bound</text>
  <rect x="140" y="80" width="110" height="36" rx="5" fill="#2a6090" stroke="#4a90c0" stroke-width="1.5"/>
  <text x="195" y="103" text-anchor="middle" fill="white">Back-End Bound</text>
  <rect x="270" y="80" width="110" height="36" rx="5" fill="#2a6090" stroke="#4a90c0" stroke-width="1.5"/>
  <text x="325" y="103" text-anchor="middle" fill="white">Bad Speculation</text>
  <rect x="400" y="80" width="110" height="36" rx="5" fill="#2a6090" stroke="#4a90c0" stroke-width="1.5"/>
  <text x="455" y="103" text-anchor="middle" fill="white">Retiring</text>
  <!-- Connectors root to L1 -->
  <line x1="270" y1="46" x2="65" y2="80" stroke="#666" stroke-width="1"/>
  <line x1="270" y1="46" x2="195" y2="80" stroke="#666" stroke-width="1"/>
  <line x1="270" y1="46" x2="325" y2="80" stroke="#666" stroke-width="1"/>
  <line x1="270" y1="46" x2="455" y2="80" stroke="#666" stroke-width="1"/>
  <!-- Level 2 — Front-End -->
  <rect x="10" y="160" width="50" height="30" rx="4" fill="#1a4060" stroke="#4a90c0" stroke-width="1"/>
  <text x="35" y="179" text-anchor="middle" fill="#a0d0ff" font-size="9">ICache</text>
  <rect x="70" y="160" width="50" height="30" rx="4" fill="#1a4060" stroke="#4a90c0" stroke-width="1"/>
  <text x="95" y="179" text-anchor="middle" fill="#a0d0ff" font-size="9">Branch</text>
  <line x1="65" y1="116" x2="35" y2="160" stroke="#555" stroke-width="1"/>
  <line x1="65" y1="116" x2="95" y2="160" stroke="#555" stroke-width="1"/>
  <!-- Level 2 — Back-End -->
  <rect x="130" y="160" width="55" height="30" rx="4" fill="#1a4060" stroke="#4a90c0" stroke-width="1"/>
  <text x="157" y="172" text-anchor="middle" fill="#a0d0ff" font-size="9">Memory</text>
  <text x="157" y="184" text-anchor="middle" fill="#a0d0ff" font-size="9">Bound</text>
  <rect x="195" y="160" width="55" height="30" rx="4" fill="#1a4060" stroke="#4a90c0" stroke-width="1"/>
  <text x="222" y="172" text-anchor="middle" fill="#a0d0ff" font-size="9">Core</text>
  <text x="222" y="184" text-anchor="middle" fill="#a0d0ff" font-size="9">Bound</text>
  <line x1="195" y1="116" x2="157" y2="160" stroke="#555" stroke-width="1"/>
  <line x1="195" y1="116" x2="222" y2="160" stroke="#555" stroke-width="1"/>
  <!-- Level 2 — Bad Spec -->
  <rect x="262" y="160" width="55" height="30" rx="4" fill="#1a4060" stroke="#4a90c0" stroke-width="1"/>
  <text x="289" y="172" text-anchor="middle" fill="#a0d0ff" font-size="9">Branch</text>
  <text x="289" y="184" text-anchor="middle" fill="#a0d0ff" font-size="9">Mispredict</text>
  <rect x="327" y="160" width="55" height="30" rx="4" fill="#1a4060" stroke="#4a90c0" stroke-width="1"/>
  <text x="354" y="172" text-anchor="middle" fill="#a0d0ff" font-size="9">Machine</text>
  <text x="354" y="184" text-anchor="middle" fill="#a0d0ff" font-size="9">Clears</text>
  <line x1="325" y1="116" x2="289" y2="160" stroke="#555" stroke-width="1"/>
  <line x1="325" y1="116" x2="354" y2="160" stroke="#555" stroke-width="1"/>
  <!-- Level 2 — Retiring -->
  <rect x="395" y="160" width="55" height="30" rx="4" fill="#1a5a30" stroke="#40a060" stroke-width="1"/>
  <text x="422" y="172" text-anchor="middle" fill="#a0e0b0" font-size="9">Base</text>
  <text x="422" y="184" text-anchor="middle" fill="#a0e0b0" font-size="9">Scalar</text>
  <rect x="460" y="160" width="55" height="30" rx="4" fill="#1a5a30" stroke="#40a060" stroke-width="1"/>
  <text x="487" y="172" text-anchor="middle" fill="#a0e0b0" font-size="9">Micro</text>
  <text x="487" y="184" text-anchor="middle" fill="#a0e0b0" font-size="9">Sequencer</text>
  <line x1="455" y1="116" x2="422" y2="160" stroke="#555" stroke-width="1"/>
  <line x1="455" y1="116" x2="487" y2="160" stroke="#555" stroke-width="1"/>
  <!-- Legend -->
  <text x="10" y="225" fill="#aaa" font-size="10">Retiring = useful work. All other categories = wasted or idle slots.</text>
  <text x="10" y="242" fill="#aaa" font-size="10">Goal: maximize Retiring. Diagnose the dominant non-Retiring category first.</text>
</svg>
```

#### TMA Level-1 Formulas (Intel)

Let $\text{Slots} = 4 \times \texttt{CPU_CLK_UNHALTED.THREAD}$ (for a 4-wide pipeline).

$$\text{Front-End Bound} = \frac{\texttt{IDQ_UOPS_NOT_DELIVERED.CORE}}{\text{Slots}}$$

$$\text{Bad Speculation} = \frac{\texttt{UOPS_ISSUED.ANY} - \texttt{UOPS_RETIRED.RETIRE_SLOTS} + 4 \times \texttt{INT_MISC.RECOVERY_CYCLES}}{\text{Slots}}$$

$$\text{Retiring} = \frac{\texttt{UOPS_RETIRED.RETIRE_SLOTS}}{\text{Slots}}$$

$$\text{Back-End Bound} = 1 - \text{Front-End Bound} - \text{Bad Speculation} - \text{Retiring}$$

By design the four categories sum to 1.0. The dominant non-Retiring category identifies the optimization target. Level-2 and Level-3 sub-nodes narrow further (e.g., Back-End Bound → Memory Bound → L3 Bound → Contested Accesses).

---

### Sampling vs. Counting

PMUs operate in two distinct modes.

#### Counting Mode

Counters are read at the start and end of a code region. The delta gives the total event count for that region. Overhead is minimal — two `RDPMC` instructions per measurement point. Suitable for whole-program or function-level metrics.

```
rdpmc  ; read counter before region
; ... code under measurement ...
rdpmc  ; read counter after region
; delta = after - before
```

#### Sampling Mode (Interrupt-Based, IBRS)

The counter is programmed with a **sample period** N. After N events, the counter overflows and generates a **PMI (Performance Monitoring Interrupt)**. The interrupt handler records the instruction pointer (RIP) at the moment of overflow. Repeating this across execution builds a statistical histogram of where events occur — an **event-weighted profile**.

The sample period trades off overhead against resolution. A period of 100,000 events per sample is common for LLC misses; 1,000,000 is common for cycles.

**Skid** is the primary accuracy limitation of interrupt-based sampling: by the time the PMI handler records the RIP, the processor has retired additional instructions. The recorded RIP may be several instructions past the instruction that caused the event. Modern processors mitigate this with **Precise Event-Based Sampling (PEBS)**.

#### PEBS (Precise Event-Based Sampling — Intel)

PEBS eliminates skid. When a PEBS-eligible event reaches the threshold, the hardware itself stores a PEBS record into a pre-allocated memory buffer at the cycle the event occurs — before the processor has advanced. The PEBS record contains:

- The exact RIP of the instruction that caused the event
- The full register state (RAX–R15, RFLAGS, RSP)
- For load/store events: the effective memory address (`Data Linear Address`)
- For load events: the latency from issue to data-ready (`Load Latency`)
- TSC timestamp

PEBS records are written to a ring buffer in memory. The OS is interrupted only when the buffer is near-full, dramatically reducing interrupt overhead.

**AMD equivalent:** Instruction-Based Sampling (IBS), which samples at the instruction dispatch or execute stage and records the full context of that instruction, including memory address and latency.

---

### Last Branch Record (LBR)

The LBR is a circular buffer of hardware registers (32 entries on recent Intel, 16 on older) that automatically records the source and destination of the last N taken branches — unconditional branches, calls, returns, and (optionally) conditional branches.

Each LBR entry stores:

- Source address (FROM)
- Destination address (TO)
- Misprediction flag
- Cycle count elapsed since the previous branch (elapsed cycles between branches)

LBR is read at PMI time. Combined with PEBS, it provides the **call path** leading to the sampled instruction, enabling profilers to attribute costs to their true caller without the overhead of software call-graph instrumentation.

**Use cases:**

- Reconstruct execution paths to a hotspot
- Identify mispredicted branches (non-zero misprediction flag)
- Compute per-branch cycle costs from elapsed-cycle fields

---

### Memory Access Profiling

#### PEBS with Memory Address and Latency

When sampling `MEM_LOAD_RETIRED.LLC_MISS` with PEBS, the record includes the virtual address of the load and its latency. This identifies:

- Which data structures have high cache-miss rates (address → symbol lookup)
- Whether misses are truly latency-bound or bandwidth-bound
- NUMA topology effects (address → physical page → NUMA node)

#### Intel PEBS with Data Source Encoding

PEBS records for memory events include a **Data Source** field encoding where the data was served from:

|Code|Source|
|---|---|
|0x01|L1 hit|
|0x02|LFB (Line Fill Buffer) hit|
|0x03|L2 hit|
|0x04|L3 hit, no snoop required|
|0x05|L3 hit, snoop not needed|
|0x06|L3 hit, snoop miss|
|0x07|L3 hit, snoop hit (remote cache)|
|0x08|Local DRAM|
|0x09|Remote DRAM|

This distinguishes L3 misses that go to local DRAM from those that require a remote NUMA hop — a distinction invisible from LLC miss counts alone.

---

### Profiling Software Stack

The profiling infrastructure layers hardware PMU access into userspace tools.

```
┌─────────────────────────────────────────┐
│          User-space tools               │
│  perf · VTune · AMD uprof · LIKWID      │
│  Valgrind/Callgrind · gprofng           │
└────────────────┬────────────────────────┘
                 │ syscall / ioctl
┌────────────────▼────────────────────────┐
│         Kernel subsystem                │
│   Linux: perf_events (perf_event_open)  │
│   Windows: ETW + PDH                    │
└────────────────┬────────────────────────┘
                 │ MSR read/write
┌────────────────▼────────────────────────┐
│       PMU Hardware                      │
│   IA32_PERFEVTSELx · IA32_PMCx         │
│   PEBS buffer · LBR stack · DS Area     │
└─────────────────────────────────────────┘
```

#### `perf` (Linux)

The primary Linux performance analysis tool. Interfaces with the kernel `perf_events` subsystem through `perf_event_open(2)`.

Key subcommands:

|Command|Function|
|---|---|
|`perf stat`|Counting mode — reports aggregate event counts and derived metrics|
|`perf record`|Sampling mode — records PEBS/LBR samples to `perf.data`|
|`perf report`|Annotated symbol-level hotspot view of `perf.data`|
|`perf annotate`|Source/disassembly view with per-instruction sample attribution|
|`perf mem`|Memory access profiling using PEBS data source and latency|
|`perf c2c`|Cache-to-cache (false sharing) detection|
|`perf top`|Live sampling view, analogous to `top`|
|`perf sched`|Scheduler tracing and latency analysis|

**Example — counting IPC for a workload:**

```bash
perf stat -e instructions,cycles,cache-misses,branch-misses ./workload
```

**Example — sampling LLC misses with PEBS and LBR:**

```bash
perf record -e mem_load_retired.l3_miss:pp \
            --call-graph lbr \
            -c 100000 \
            ./workload
perf report --stdio
```

The `:pp` suffix requests precise (PEBS) sampling. `--call-graph lbr` uses LBR entries to reconstruct call stacks without frame pointer overhead.

#### Intel VTune Profiler

A full-featured GUI profiler implementing TMA as a first-class workflow. Key analysis types:

|Analysis|Primary counters used|
|---|---|
|Hotspot|PEBS cycle sampling|
|Microarchitecture Exploration|Full TMA Level 1–4|
|Memory Access|PEBS mem latency, data source|
|Threading|Context switch tracing, lock contention|
|GPU Offload|GPU PMU + CPU correlation|

VTune's **Flame Graph** view shows call-stack-weighted cycle attribution. Its **Bottom-Up** view shows hotspot functions. Its **Platform** view correlates CPU, GPU, and I/O activity on a timeline.

#### LIKWID

A command-line toolkit for HPC. Provides topology-aware pinning, per-core / per-socket counter reading, and pre-defined **performance groups** (sets of events combined into meaningful metrics).

```bash
likwid-perfctr -C 0-7 -g MEM_DP ./workload
```

The `MEM_DP` group measures double-precision FLOP rates and memory bandwidth simultaneously, enabling direct placement on the Roofline model.

---

### Software Profiling Methods

Hardware PMCs are not the only profiling mechanism. Software approaches complement them, particularly where hardware precision is unavailable.

#### Instrumentation-Based Profiling

The binary or source is modified to insert measurement code at function entry/exit or basic block boundaries.

**Compiler-inserted instrumentation (`-pg`, gprof):** GCC's `-pg` flag inserts a call to `mcount()` at every function entry. `mcount()` records the caller/callee pair and increments a call count. At exit, `gprof` produces a flat profile (time per function) and a call graph. Limitation: `mcount()` overhead is proportional to call frequency; functions called millions of times per second incur measurable perturbation.

**Binary instrumentation (Pin, DynamoRIO, Valgrind):** A dynamic binary instrumentation framework interposes on the program's execution at the basic-block or instruction level. Every instruction passes through the instrumenter's JIT. This allows:

- Counting every instruction executed (Callgrind's `INST_IR`)
- Simulating a cache hierarchy and counting hits/misses per instruction (Callgrind cache simulation)
- Detecting memory errors (Memcheck), races (Helgrind), and heap usage (Massif)

The overhead of full instrumentation is typically 10–100× slowdown. This makes PMU-based sampling preferable for production profiling, but instrumentation tools provide information unavailable from PMUs — such as precise per-instruction memory access traces.

#### Statistical Sampling (Software)

A timer signal (SIGPROF, SIGALRM) is delivered at a fixed interval. The signal handler records the current PC. This is the technique used by `gprof`'s timing mode and many legacy profilers. Resolution is limited by the timer interval (typically 10 ms, or 100 Hz), which is too coarse for fine-grained analysis of optimized code. PMU overflow interrupts at rates of 1,000–100,000 Hz are strictly superior.

---

### Roofline Model and Counter Integration

The Roofline model characterizes performance relative to two hardware limits: peak compute throughput (FLOP/s) and peak memory bandwidth (Bytes/s). A workload's **arithmetic intensity** (FLOP per Byte of memory traffic) determines which limit applies.

$$\text{Arithmetic Intensity} = \frac{\text{FLOP}}{\text{Bytes transferred from/to DRAM}}$$

PMCs supply both quantities:

- FLOP count: sum of retired SIMD and scalar FP µops weighted by their width (`FP_ARITH_INST_RETIRED.*`)
- DRAM bytes: `OFFCORE_RESPONSE` events or uncore memory controller counters (`UNC_M_CAS_COUNT.RD` + `UNC_M_CAS_COUNT.WR`, each CAS = 64 bytes)

Plotting the measured point against the Roofline ceiling identifies whether the workload is **compute-bound** (above the memory bandwidth ridge) or **memory-bound** (below it), and by how much headroom remains before hitting hardware limits.

---

### Uncore and System-Level Counters

Beyond per-core PMUs, modern processors expose **uncore PMUs** for system-level components:

|Component|What it measures|
|---|---|
|IMC (Integrated Memory Controller)|DRAM read/write bandwidth, CAS counts, DRAM latency|
|CHA / CBo (Cache + Home Agent)|LLC lookup counts, snoop traffic, directory state transitions|
|PCIe|Transaction counts, bandwidth|
|QPI / UPI|Socket-to-socket traffic (in multi-socket systems)|
|Power / thermal|Package power (RAPL — Running Average Power Limit registers)|

Uncore PMUs are accessed through a separate set of MSRs and are typically socket-scoped rather than core-scoped. `perf` exposes them as `uncore_imc/cas_count_read/` and similar events. They are essential for diagnosing NUMA imbalance, memory bandwidth saturation, and interconnect congestion.

#### RAPL (Running Average Power Limit)

RAPL provides energy consumption counters (in microjoules) for:

- Package domain (entire socket)
- PP0 domain (cores)
- PP1 domain (uncore / GT on client)
- DRAM domain

```bash
perf stat -e power/energy-pkg/,power/energy-ram/ ./workload
```

Energy divided by execution time yields average power. Combined with performance counters, this enables **energy-per-operation** metrics — relevant for efficiency-oriented analysis and DVFS tuning.

---

### Pitfalls and Validity Concerns

|Pitfall|Description|
|---|---|
|**Multiplex skew**|When more events are requested than available counters, the kernel time-multiplexes counters across the measurement interval. Events not simultaneously active are extrapolated by the ratio of active time, introducing error for non-uniform workloads.|
|**Counter overflow wraparound**|A 48-bit counter at 4 GHz overflows in ~3.3 days. A 32-bit counter overflows in under a second at high event rates. Software must handle overflow correctly.|
|**Hypervisor interference**|In virtualized environments, the hypervisor may not expose full PMU access, may trap PMU MSR accesses, or may cause counter discontinuities on VM migration.|
|**SMT sharing**|Two logical threads share one physical core and its PMU. Counters may reflect the aggregate of both threads depending on the event and implementation.|
|**Speculative event counting**|Some events count speculative operations (issued µops) not retired ones. Comparing speculative and retired counts reveals squash rates, but care is needed to not conflate them.|
|**Non-determinism**|Cache behavior, TLB state, DRAM timing, and OS scheduling introduce run-to-run variation. Multiple runs and median/percentile reporting are required for statistically valid conclusions.|
|**Observer effect**|PEBS buffer writes, PMI handlers, and tool overhead consume cache lines and bandwidth, perturbing the measurement. Overhead is typically < 1% for coarse sampling periods but can be significant at high sampling rates.|

---

**Key Points**

- The PMU provides fixed-width hardware counters configured via event select registers; modern processors expose 4–8 programmable counters plus fixed counters for instructions, core cycles, and reference cycles per logical core.
- PEBS eliminates instruction skid by having hardware record event context directly, including data address, data source encoding, and load latency — information unavailable from interrupt-based sampling.
- LBR provides hardware call-stack reconstruction without software instrumentation overhead, enabling attribution of costs to their full call path.
- TMA partitions pipeline slots into Front-End Bound, Back-End Bound, Bad Speculation, and Retiring — a hierarchical framework that directs optimization effort to the dominant bottleneck.
- Uncore PMUs (IMC, CHA, UPI) and RAPL extend visibility to memory bandwidth, coherence traffic, and energy, which per-core counters cannot measure.
- Multiplexing, SMT sharing, hypervisor interference, and observer effects are systematic sources of measurement error that must be accounted for in any quantitative analysis.

**Next Steps**

The direct continuations are the **Roofline Model** (also in Module 14) for translating PMC measurements into a performance bound framework, **CPI and IPC analysis** for interpreting TMA output in terms of pipeline efficiency, and **Branch Prediction** (Module 5) for understanding the hardware behavior behind `BR_MISP_RETIRED` events.

---

