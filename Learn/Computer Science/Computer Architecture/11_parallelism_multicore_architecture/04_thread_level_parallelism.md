## Thread-Level Parallelism


Thread-level parallelism is the exploitation of concurrency across multiple independent or loosely coupled threads of execution, each with its own program counter, register state, and stack. Where instruction-level parallelism (ILP) extracts parallelism from within a single instruction stream, TLP extracts it across multiple streams — either on separate physical cores, through hardware multithreading on a single core, or across a cluster of processors. TLP is the dominant scalability mechanism in modern computing systems.

---

### Threads as the Unit of Parallelism

A **thread** is the minimal schedulable unit of execution: a program counter, a register file, and a stack pointer operating within a shared address space (for threads within the same process) or an independent address space (for separate processes).

```svg
<svg viewBox="0 0 680 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <!-- Process box -->
  <rect x="20" y="20" width="640" height="160" rx="6" fill="#f3e5f5" stroke="#7b1fa2" stroke-width="1.5"/>
  <text x="340" y="45" text-anchor="middle" font-weight="bold" font-size="13" fill="#4a148c">Process — Shared: Heap, Code, Global Data, File Descriptors</text>

  <!-- Thread A -->
  <rect x="50" y="65" width="160" height="90" rx="4" fill="#ce93d8" stroke="#7b1fa2"/>
  <text x="130" y="85" text-anchor="middle" font-weight="bold">Thread A</text>
  <text x="130" y="103" text-anchor="middle">PC: 0x4010</text>
  <text x="130" y="119" text-anchor="middle">Registers: R0–R31</text>
  <text x="130" y="135" text-anchor="middle">Stack: 0x7ff…</text>

  <!-- Thread B -->
  <rect x="260" y="65" width="160" height="90" rx="4" fill="#ce93d8" stroke="#7b1fa2"/>
  <text x="340" y="85" text-anchor="middle" font-weight="bold">Thread B</text>
  <text x="340" y="103" text-anchor="middle">PC: 0x5320</text>
  <text x="340" y="119" text-anchor="middle">Registers: R0–R31</text>
  <text x="340" y="135" text-anchor="middle">Stack: 0x7fe…</text>

  <!-- Thread C -->
  <rect x="470" y="65" width="160" height="90" rx="4" fill="#ce93d8" stroke="#7b1fa2"/>
  <text x="550" y="85" text-anchor="middle" font-weight="bold">Thread C</text>
  <text x="550" y="103" text-anchor="middle">PC: 0x6180</text>
  <text x="550" y="119" text-anchor="middle">Registers: R0–R31</text>
  <text x="550" y="135" text-anchor="middle">Stack: 0x7fd…</text>
</svg>
```

Threads within a process share the virtual address space, which means shared data is accessible without IPC mechanisms — but also means that unsynchronized concurrent access produces data races.

---

### Sources of TLP

TLP arises from two broad categories of workload:

**Explicit parallelism** — the programmer or compiler decomposes work into threads using threading APIs (POSIX pthreads, C++11 `std::thread`, OpenMP, Java threads). The programmer is responsible for decomposition, synchronization, and load balancing.

**Implicit parallelism** — the runtime or OS creates threads transparently (e.g., a web server spawning a thread per request, a JVM garbage collector running concurrently with application threads).

The degree of exploitable TLP depends on:

- **Independence** — how much of the computation can proceed without waiting for results from another thread
- **Granularity** — the ratio of computation to synchronization; coarse-grained tasks amortize synchronization overhead better
- **Load balance** — whether threads receive roughly equal amounts of work

---

### Hardware Mechanisms for TLP

#### Multicore Processors

The most direct TLP realization is multiple independent processor cores on a single die, each capable of executing a separate thread simultaneously. Each core has its own:

- Program counter and register file
- L1 instruction and data caches
- L1/L2 pipelines (and often a private L2)

Shared resources typically include last-level cache (LLC), memory controllers, and I/O interfaces.

```svg
<svg viewBox="0 0 680 280" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <!-- Die outline -->
  <rect x="20" y="20" width="640" height="250" rx="8" fill="#e8eaf6" stroke="#3949ab" stroke-width="2"/>
  <text x="340" y="42" text-anchor="middle" font-weight="bold" font-size="14" fill="#1a237e">Multicore Die</text>

  <!-- Core 0 -->
  <rect x="50" y="55" width="130" height="100" rx="4" fill="#c5cae9" stroke="#3949ab"/>
  <text x="115" y="75" text-anchor="middle" font-weight="bold">Core 0</text>
  <rect x="65" y="85" width="100" height="22" rx="2" fill="#9fa8da"/>
  <text x="115" y="100" text-anchor="middle">L1-I / L1-D</text>
  <rect x="65" y="112" width="100" height="22" rx="2" fill="#7986cb"/>
  <text x="115" y="127" text-anchor="middle" fill="white">Private L2</text>

  <!-- Core 1 -->
  <rect x="200" y="55" width="130" height="100" rx="4" fill="#c5cae9" stroke="#3949ab"/>
  <text x="265" y="75" text-anchor="middle" font-weight="bold">Core 1</text>
  <rect x="215" y="85" width="100" height="22" rx="2" fill="#9fa8da"/>
  <text x="265" y="100" text-anchor="middle">L1-I / L1-D</text>
  <rect x="215" y="112" width="100" height="22" rx="2" fill="#7986cb"/>
  <text x="265" y="127" text-anchor="middle" fill="white">Private L2</text>

  <!-- Core 2 -->
  <rect x="350" y="55" width="130" height="100" rx="4" fill="#c5cae9" stroke="#3949ab"/>
  <text x="415" y="75" text-anchor="middle" font-weight="bold">Core 2</text>
  <rect x="365" y="85" width="100" height="22" rx="2" fill="#9fa8da"/>
  <text x="415" y="100" text-anchor="middle">L1-I / L1-D</text>
  <rect x="365" y="112" width="100" height="22" rx="2" fill="#7986cb"/>
  <text x="415" y="127" text-anchor="middle" fill="white">Private L2</text>

  <!-- Core 3 -->
  <rect x="500" y="55" width="130" height="100" rx="4" fill="#c5cae9" stroke="#3949ab"/>
  <text x="565" y="75" text-anchor="middle" font-weight="bold">Core 3</text>
  <rect x="515" y="85" width="100" height="22" rx="2" fill="#9fa8da"/>
  <text x="565" y="100" text-anchor="middle">L1-I / L1-D</text>
  <rect x="515" y="112" width="100" height="22" rx="2" fill="#7986cb"/>
  <text x="565" y="127" text-anchor="middle" fill="white">Private L2</text>

  <!-- Shared LLC -->
  <rect x="50" y="175" width="580" height="40" rx="4" fill="#5c6bc0" stroke="#3949ab"/>
  <text x="340" y="200" text-anchor="middle" fill="white" font-weight="bold">Shared Last-Level Cache (LLC)</text>

  <!-- Memory controller -->
  <rect x="50" y="230" width="580" height="30" rx="4" fill="#3949ab" stroke="#1a237e"/>
  <text x="340" y="250" text-anchor="middle" fill="white" font-weight="bold">Memory Controller / Interconnect</text>

  <!-- Vertical lines from cores to LLC -->
  <line x1="115" y1="155" x2="115" y2="175" stroke="#3949ab" stroke-width="1.5"/>
  <line x1="265" y1="155" x2="265" y2="175" stroke="#3949ab" stroke-width="1.5"/>
  <line x1="415" y1="155" x2="415" y2="175" stroke="#3949ab" stroke-width="1.5"/>
  <line x1="565" y1="155" x2="565" y2="175" stroke="#3949ab" stroke-width="1.5"/>
</svg>
```

True multicore TLP is **spatial** — threads execute simultaneously on physically separate execution units. Throughput scales with core count for embarrassingly parallel workloads, bounded by Amdahl's Law for workloads with serial fractions.

---

#### Hardware Multithreading (Single Core)

A single pipeline has stall cycles — from cache misses, branch mispredictions, and long-latency operations. Hardware multithreading hides these stalls by interleaving or simultaneously issuing instructions from multiple thread contexts on one physical core.

There are three hardware multithreading models:

##### Coarse-Grained Multithreading (CGMT)

The core runs one thread until it encounters a **long-latency event** (typically an L2 or LLC miss), then switches to another thread context. The pipeline is flushed or drained on a switch.

```svg
<svg viewBox="0 0 680 130" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <text x="20" y="20" font-weight="bold" font-size="12">Coarse-Grained MT — Time Slots</text>

  <!-- Cycle labels -->
  <text x="80" y="40" text-anchor="middle" fill="#555">C1</text>
  <text x="120" y="40" text-anchor="middle" fill="#555">C2</text>
  <text x="160" y="40" text-anchor="middle" fill="#555">C3</text>
  <text x="200" y="40" text-anchor="middle" fill="#555">C4</text>
  <text x="240" y="40" text-anchor="middle" fill="#555">C5</text>
  <text x="280" y="40" text-anchor="middle" fill="#555">C6</text>
  <text x="320" y="40" text-anchor="middle" fill="#555">C7</text>
  <text x="360" y="40" text-anchor="middle" fill="#555">C8</text>
  <text x="400" y="40" text-anchor="middle" fill="#555">C9</text>
  <text x="440" y="40" text-anchor="middle" fill="#555">C10</text>
  <text x="480" y="40" text-anchor="middle" fill="#555">C11</text>
  <text x="520" y="40" text-anchor="middle" fill="#555">C12</text>

  <!-- Thread A slots -->
  <rect x="60" y="50" width="40" height="25" rx="2" fill="#42a5f5"/>
  <text x="80" y="67" text-anchor="middle" fill="white">T-A</text>
  <rect x="100" y="50" width="40" height="25" rx="2" fill="#42a5f5"/>
  <text x="120" y="67" text-anchor="middle" fill="white">T-A</text>
  <rect x="140" y="50" width="40" height="25" rx="2" fill="#42a5f5"/>
  <text x="160" y="67" text-anchor="middle" fill="white">T-A</text>
  <!-- miss stall switch -->
  <rect x="180" y="50" width="40" height="25" rx="2" fill="#ef9a9a"/>
  <text x="200" y="67" text-anchor="middle" fill="#b71c1c">MISS</text>

  <!-- Thread B takes over -->
  <rect x="220" y="50" width="40" height="25" rx="2" fill="#66bb6a"/>
  <text x="240" y="67" text-anchor="middle" fill="white">T-B</text>
  <rect x="260" y="50" width="40" height="25" rx="2" fill="#66bb6a"/>
  <text x="280" y="67" text-anchor="middle" fill="white">T-B</text>
  <rect x="300" y="50" width="40" height="25" rx="2" fill="#66bb6a"/>
  <text x="320" y="67" text-anchor="middle" fill="white">T-B</text>
  <rect x="340" y="50" width="40" height="25" rx="2" fill="#66bb6a"/>
  <text x="360" y="67" text-anchor="middle" fill="white">T-B</text>
  <rect x="380" y="50" width="40" height="25" rx="2" fill="#66bb6a"/>
  <text x="400" y="67" text-anchor="middle" fill="white">T-B</text>

  <!-- Thread A resumes -->
  <rect x="420" y="50" width="40" height="25" rx="2" fill="#42a5f5"/>
  <text x="440" y="67" text-anchor="middle" fill="white">T-A</text>
  <rect x="460" y="50" width="40" height="25" rx="2" fill="#42a5f5"/>
  <text x="480" y="67" text-anchor="middle" fill="white">T-A</text>
  <rect x="500" y="50" width="40" height="25" rx="2" fill="#42a5f5"/>
  <text x="520" y="67" text-anchor="middle" fill="white">T-A</text>

  <text x="20" y="105" font-size="11" fill="#555">Switch occurs on long-latency event. Pipeline drains before switching.</text>
</svg>
```

CGMT has low switch overhead but leaves the pipeline idle during the drain period and is ineffective against short stalls.

##### Fine-Grained Multithreading (FGMT)

The core switches between threads on **every cycle** in a round-robin fashion, regardless of whether a stall occurs. Each cycle issues instructions from a different thread context.

```svg
<svg viewBox="0 0 680 130" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <text x="20" y="20" font-weight="bold" font-size="12">Fine-Grained MT — Interleaved Cycles</text>

  <text x="80" y="40" text-anchor="middle" fill="#555">C1</text>
  <text x="120" y="40" text-anchor="middle" fill="#555">C2</text>
  <text x="160" y="40" text-anchor="middle" fill="#555">C3</text>
  <text x="200" y="40" text-anchor="middle" fill="#555">C4</text>
  <text x="240" y="40" text-anchor="middle" fill="#555">C5</text>
  <text x="280" y="40" text-anchor="middle" fill="#555">C6</text>
  <text x="320" y="40" text-anchor="middle" fill="#555">C7</text>
  <text x="360" y="40" text-anchor="middle" fill="#555">C8</text>
  <text x="400" y="40" text-anchor="middle" fill="#555">C9</text>
  <text x="440" y="40" text-anchor="middle" fill="#555">C10</text>
  <text x="480" y="40" text-anchor="middle" fill="#555">C11</text>
  <text x="520" y="40" text-anchor="middle" fill="#555">C12</text>

  <rect x="60" y="50" width="40" height="25" rx="2" fill="#42a5f5"/>
  <text x="80" y="67" text-anchor="middle" fill="white">T-A</text>
  <rect x="100" y="50" width="40" height="25" rx="2" fill="#66bb6a"/>
  <text x="120" y="67" text-anchor="middle" fill="white">T-B</text>
  <rect x="140" y="50" width="40" height="25" rx="2" fill="#ffa726"/>
  <text x="160" y="67" text-anchor="middle" fill="white">T-C</text>
  <rect x="180" y="50" width="40" height="25" rx="2" fill="#42a5f5"/>
  <text x="200" y="67" text-anchor="middle" fill="white">T-A</text>
  <rect x="220" y="50" width="40" height="25" rx="2" fill="#66bb6a"/>
  <text x="240" y="67" text-anchor="middle" fill="white">T-B</text>
  <rect x="260" y="50" width="40" height="25" rx="2" fill="#ffa726"/>
  <text x="280" y="67" text-anchor="middle" fill="white">T-C</text>
  <rect x="300" y="50" width="40" height="25" rx="2" fill="#42a5f5"/>
  <text x="320" y="67" text-anchor="middle" fill="white">T-A</text>
  <rect x="340" y="50" width="40" height="25" rx="2" fill="#66bb6a"/>
  <text x="360" y="67" text-anchor="middle" fill="white">T-B</text>
  <rect x="380" y="50" width="40" height="25" rx="2" fill="#ffa726"/>
  <text x="400" y="67" text-anchor="middle" fill="white">T-C</text>
  <rect x="420" y="50" width="40" height="25" rx="2" fill="#42a5f5"/>
  <text x="440" y="67" text-anchor="middle" fill="white">T-A</text>
  <rect x="460" y="50" width="40" height="25" rx="2" fill="#66bb6a"/>
  <text x="480" y="67" text-anchor="middle" fill="white">T-B</text>
  <rect x="500" y="50" width="40" height="25" rx="2" fill="#ffa726"/>
  <text x="520" y="67" text-anchor="middle" fill="white">T-C</text>

  <text x="20" y="105" font-size="11" fill="#555">No data hazards between consecutive instructions — they belong to different threads.</text>
</svg>
```

Because consecutive pipeline stages always contain instructions from different threads, **data hazards between threads are impossible** within the pipeline. The tradeoff is that each individual thread's throughput is divided by the number of active threads — the pipeline is fully utilized but single-thread latency increases.

Sun's UltraSPARC T1 ("Niagara") used FGMT with 4 threads per core, cycling every cycle.

##### Simultaneous Multithreading (SMT)

SMT combines the superscalar pipeline's ability to issue multiple instructions per cycle with multiple thread contexts. In a given cycle, instructions from **multiple threads may be issued simultaneously** to fill the available issue slots.

```svg
<svg viewBox="0 0 680 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <text x="20" y="20" font-weight="bold" font-size="12">SMT — Simultaneous Issue from Multiple Threads</text>

  <!-- Cycle headers -->
  <text x="200" y="42" text-anchor="middle" fill="#555" font-weight="bold">Cycle 1</text>
  <text x="340" y="42" text-anchor="middle" fill="#555" font-weight="bold">Cycle 2</text>
  <text x="480" y="42" text-anchor="middle" fill="#555" font-weight="bold">Cycle 3</text>

  <!-- Issue slots labels -->
  <text x="80" y="70" text-anchor="end" fill="#555">Slot 0</text>
  <text x="80" y="100" text-anchor="end" fill="#555">Slot 1</text>
  <text x="80" y="130" text-anchor="end" fill="#555">Slot 2</text>
  <text x="80" y="160" text-anchor="end" fill="#555">Slot 3</text>

  <!-- Cycle 1 -->
  <rect x="140" y="55" width="120" height="22" rx="2" fill="#42a5f5"/>
  <text x="200" y="70" text-anchor="middle" fill="white">T-A: ADD R1,R2</text>
  <rect x="140" y="85" width="120" height="22" rx="2" fill="#66bb6a"/>
  <text x="200" y="100" text-anchor="middle" fill="white">T-B: MUL R3,R4</text>
  <rect x="140" y="115" width="120" height="22" rx="2" fill="#42a5f5"/>
  <text x="200" y="130" text-anchor="middle" fill="white">T-A: LOAD R5</text>
  <rect x="140" y="145" width="120" height="22" rx="2" fill="#9e9e9e"/>
  <text x="200" y="160" text-anchor="middle" fill="white">idle</text>

  <!-- Cycle 2 -->
  <rect x="280" y="55" width="120" height="22" rx="2" fill="#66bb6a"/>
  <text x="340" y="70" text-anchor="middle" fill="white">T-B: SUB R6,R7</text>
  <rect x="280" y="85" width="120" height="22" rx="2" fill="#66bb6a"/>
  <text x="340" y="100" text-anchor="middle" fill="white">T-B: AND R8,R9</text>
  <rect x="280" y="115" width="120" height="22" rx="2" fill="#ffa726"/>
  <text x="340" y="130" text-anchor="middle" fill="white">T-C: ADD R1,R3</text>
  <rect x="280" y="145" width="120" height="22" rx="2" fill="#ffa726"/>
  <text x="340" y="160" text-anchor="middle" fill="white">T-C: STORE R2</text>

  <!-- Cycle 3 -->
  <rect x="420" y="55" width="120" height="22" rx="2" fill="#42a5f5"/>
  <text x="480" y="70" text-anchor="middle" fill="white">T-A: XOR R3,R5</text>
  <rect x="420" y="85" width="120" height="22" rx="2" fill="#9e9e9e"/>
  <text x="480" y="100" text-anchor="middle" fill="white">idle</text>
  <rect x="420" y="115" width="120" height="22" rx="2" fill="#ffa726"/>
  <text x="480" y="130" text-anchor="middle" fill="white">T-C: MUL R4,R6</text>
  <rect x="420" y="145" width="120" height="22" rx="2" fill="#66bb6a"/>
  <text x="480" y="160" text-anchor="middle" fill="white">T-B: LOAD R10</text>
</svg>
```

Intel's implementation of SMT is marketed as **Hyper-Threading (HT)**. A 2-way SMT core exposes 2 logical processors to the OS. The physical execution resources — ALUs, FPUs, load/store units — are shared. Each logical processor has its own:

- Architectural register file
- Program counter
- Reorder buffer (ROB) partition [Unverified: partitioning strategies differ by microarchitecture]
- Store buffer

**Key Points**

- SMT improves throughput by filling issue slots that a single thread cannot fill alone due to stalls.
- SMT does not double single-thread performance; it improves aggregate throughput.
- Cache, TLB, and execution unit contention between SMT threads can degrade per-thread performance under heavy loads.
- [Inference] SMT is most beneficial when threads are memory-latency-bound; compute-bound threads competing for the same execution units may see less benefit. Behavior is not guaranteed and is workload-dependent.

---

### Comparison of Multithreading Models

|Property|CGMT|FGMT|SMT|Multicore|
|---|---|---|---|---|
|Thread switch trigger|Long-latency event|Every cycle|Implicit / per-issue|N/A (spatial)|
|Pipeline drain on switch|Yes|No|No|N/A|
|Single-thread latency impact|Low|High|Low–moderate|None|
|IPC improvement|Moderate|Moderate|High|Linear (ideal)|
|Hardware cost|Low|Low–moderate|High|Very high|
|Hides memory latency|Partially|Well|Well|No (per core)|
|Independent execution|No|No|No|Yes|

---

### Memory Consistency and TLP

When multiple threads share memory, the order in which memory operations become visible to other threads is governed by the **memory consistency model**.

#### Sequential Consistency (SC)

The result of any execution is the same as if the operations of all threads were executed in some sequential order, and each thread's operations appear in program order within that sequence. SC is intuitive but expensive to implement — it forbids many hardware and compiler optimizations.

#### Total Store Order (TSO)

Used by x86. Stores are buffered in a per-core **store buffer** before being written to the cache. A core may read its own buffered stores before they are visible to other cores, but stores become globally visible in program order. This allows:

- Loads to bypass pending stores to different addresses
- Stores to be delayed without stalling the pipeline

```svg
<svg viewBox="0 0 680 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <text x="20" y="20" font-weight="bold" font-size="12">TSO — Store Buffer Model</text>

  <!-- Core 0 -->
  <rect x="40" y="40" width="120" height="50" rx="4" fill="#bbdefb" stroke="#1976d2"/>
  <text x="100" y="62" text-anchor="middle" font-weight="bold">Core 0</text>
  <text x="100" y="80" text-anchor="middle">STORE x=1</text>

  <!-- Store buffer 0 -->
  <rect x="40" y="105" width="120" height="40" rx="4" fill="#90caf9" stroke="#1976d2"/>
  <text x="100" y="120" text-anchor="middle" font-weight="bold">Store Buffer</text>
  <text x="100" y="136" text-anchor="middle">x=1 (pending)</text>

  <!-- Core 1 -->
  <rect x="520" y="40" width="120" height="50" rx="4" fill="#c8e6c9" stroke="#388e3c"/>
  <text x="580" y="62" text-anchor="middle" font-weight="bold">Core 1</text>
  <text x="580" y="80" text-anchor="middle">LOAD x → ?</text>

  <!-- Shared cache -->
  <rect x="240" y="105" width="200" height="40" rx="4" fill="#fff9c4" stroke="#f9a825"/>
  <text x="340" y="120" text-anchor="middle" font-weight="bold">Shared Cache / Memory</text>
  <text x="340" y="136" text-anchor="middle">x = 0 (old value)</text>

  <!-- Arrows -->
  <line x1="160" y1="125" x2="240" y2="125" stroke="#1976d2" stroke-width="1.5" stroke-dasharray="5,3"/>
  <text x="200" y="118" text-anchor="middle" fill="#1976d2" font-size="10">drains</text>
  <line x1="520" y1="105" x2="440" y2="125" stroke="#388e3c" stroke-width="1.5"/>
  <text x="488" y="110" text-anchor="middle" fill="#388e3c" font-size="10">reads 0</text>
</svg>
```

Core 1 may read `x = 0` while Core 0 has already stored `x = 1` in its store buffer — a visible reordering. This requires **memory fences** (barriers) to enforce ordering across cores where required by the program.

#### Relaxed Consistency Models

ARM and RISC-V implement weaker models where both loads and stores can be reordered unless explicitly fenced. This maximizes hardware optimization freedom but places the burden of correct ordering on the programmer or language memory model.

---

### Synchronization Primitives in Hardware

TLP requires mechanisms to coordinate access to shared data.

#### Atomic Operations

Hardware provides atomic read-modify-write primitives that complete without interruption from other cores' accesses.

|Primitive|Description|
|---|---|
|`test-and-set`|Atomically write 1 and return old value|
|`compare-and-swap` (CAS)|If `[addr] == expected`, write `new`; return old|
|`fetch-and-add`|Atomically add a value and return old|
|`load-linked / store-conditional` (LL/SC)|LL reads; SC succeeds only if no intervening write|

x86 provides `LOCK`-prefixed instructions and `CMPXCHG`. ARM and RISC-V use LL/SC (`LDREX/STREX` on ARM; `LR/SC` on RISC-V).

#### Spin Locks

The simplest synchronization: a thread loops (spins) reading a lock variable until it can atomically acquire it. Efficient for short critical sections on multicore systems; wasteful under contention or long holds.

```
spin_lock:
    LOOP: CAS [lock], 0, 1 → if success: enter critical section
          else: branch LOOP
```

#### Cache Line Contention and False Sharing

When multiple threads write to **different variables that reside on the same cache line**, every write invalidates the line on all other cores — even though no true data sharing is occurring. This is **false sharing**, and it can degrade TLP performance severely.

```svg
<svg viewBox="0 0 680 160" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11">
  <text x="20" y="20" font-weight="bold" font-size="12">False Sharing — Same Cache Line, Different Variables</text>

  <!-- Cache line -->
  <rect x="140" y="50" width="400" height="40" rx="4" fill="#ffe0b2" stroke="#e65100" stroke-width="2"/>
  <text x="150" y="70" font-weight="bold">64-byte Cache Line</text>

  <!-- Variable A -->
  <rect x="145" y="55" width="90" height="30" rx="2" fill="#ef9a9a" stroke="#c62828"/>
  <text x="190" y="74" text-anchor="middle" fill="#b71c1c">counter_A</text>

  <!-- Variable B -->
  <rect x="240" y="55" width="90" height="30" rx="2" fill="#a5d6a7" stroke="#2e7d32"/>
  <text x="285" y="74" text-anchor="middle" fill="#1b5e20">counter_B</text>

  <!-- Other bytes -->
  <rect x="335" y="55" width="200" height="30" rx="2" fill="#e0e0e0"/>
  <text x="435" y="74" text-anchor="middle" fill="#555">padding…</text>

  <!-- Core 0 writes A -->
  <text x="190" y="115" text-anchor="middle" fill="#c62828">Core 0 writes A</text>
  <line x1="190" y1="108" x2="190" y2="85" stroke="#c62828" stroke-width="1.5" marker-end="url(#arr)"/>

  <!-- Core 1 writes B -->
  <text x="285" y="115" text-anchor="middle" fill="#2e7d32">Core 1 writes B</text>
  <line x1="285" y1="108" x2="285" y2="85" stroke="#2e7d32" stroke-width="1.5" marker-end="url(#arr)"/>

  <text x="340" y="145" text-anchor="middle" fill="#b71c1c" font-size="11">→ Each write invalidates the entire line on the other core</text>

  <defs>
    <marker id="arr" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto">
      <path d="M0,0 L6,3 L0,6 Z" fill="#555"/>
    </marker>
  </defs>
</svg>
```

The fix is to pad or align shared variables so that logically independent counters occupy separate cache lines.

---

### OS-Level TLP: Scheduling

The OS scheduler maps software threads to physical hardware contexts (logical processors in SMT, cores in multicore). Key concerns:

- **Affinity** — pinning a thread to a specific core preserves cache warmth and avoids costly migration
- **NUMA-awareness** — scheduling threads on cores close to the memory their data resides in (covered in the NUMA topic)
- **SMT awareness** — OS schedulers must distinguish between physical cores and logical SMT threads; filling all SMT slots on one core before using another physical core is generally less efficient for performance-critical workloads than spreading across physical cores first

**Example**

A parallel matrix multiplication is decomposed into N row-block tasks distributed across T threads, one thread per core. If the matrix rows fit in L2 cache per thread and each thread operates on independent rows, TLP is exploited with minimal synchronization — only a barrier at the end to aggregate results. False sharing is avoided by ensuring row boundaries align with cache line boundaries. On an 8-core machine, an 8-thread decomposition ideally yields ~8× throughput over a single-threaded baseline, bounded by memory bandwidth when the matrix exceeds LLC capacity.

---

**Conclusion**

Thread-level parallelism is realized through two complementary hardware strategies: spatial replication (multicore) and temporal multiplexing (hardware multithreading). Multicore provides true simultaneous execution with full resource independence at the cost of die area. Hardware multithreading — CGMT, FGMT, and SMT — hides latency within a single core by interleaving or simultaneously issuing from multiple thread contexts, at lower area cost but with shared resource contention. Correct TLP requires hardware support for atomic operations, memory consistency enforcement, and cache coherence, each of which imposes its own performance constraints. The interaction of synchronization, false sharing, and memory ordering makes TLP a domain where hardware design, OS policy, and software structure are tightly coupled.

**Next Steps**

- SIMD and vector processing — exploiting data-level parallelism within a single thread as a complement to TLP
- Memory consistency models (in depth) — formal treatment of SC, TSO, and relaxed models with litmus tests
- Cache coherence (MSI, MESI, MOESI) — the protocol layer that makes shared memory between cores correct under TLP
- Synchronization primitives in hardware — lock-free data structures, CAS loops, and the ABA problem

---

