## Symmetric Multiprocessing


Symmetric multiprocessing (SMP) is a multiprocessor architecture in which two or more identical processors are connected to a single shared main memory, operate under a single operating system, and have equal access to all I/O devices. No processor is designated master or slave — each has the same capabilities and the same view of the system.

---

### Architecture Overview

In a canonical SMP system, all processors share:

- A **unified physical address space** — any processor can address any memory location using the same address.
- A **single OS instance** — the kernel can schedule any thread on any processor.
- **I/O subsystems** — peripherals, storage controllers, and network interfaces are accessible from all processors equally.

Processors are connected to memory and each other through an **interconnect**, historically a shared bus, now typically a crossbar switch or a ring/mesh on-die network.

<svg viewBox="0 0 720 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <!-- Processors --> <rect x="30" y="30" width="120" height="70" rx="6" fill="#1e3a5f" stroke="#4a9eff" stroke-width="1.5"/> <text x="90" y="58" text-anchor="middle" fill="#e0e8ff">CPU 0</text> <text x="90" y="75" text-anchor="middle" fill="#7ab0ff" font-size="11">Core + Cache</text> <text x="90" y="91" text-anchor="middle" fill="#7ab0ff" font-size="11">L1 / L2</text> <rect x="200" y="30" width="120" height="70" rx="6" fill="#1e3a5f" stroke="#4a9eff" stroke-width="1.5"/> <text x="260" y="58" text-anchor="middle" fill="#e0e8ff">CPU 1</text> <text x="260" y="75" text-anchor="middle" fill="#7ab0ff" font-size="11">Core + Cache</text> <text x="260" y="91" text-anchor="middle" fill="#7ab0ff" font-size="11">L1 / L2</text> <rect x="370" y="30" width="120" height="70" rx="6" fill="#1e3a5f" stroke="#4a9eff" stroke-width="1.5"/> <text x="430" y="58" text-anchor="middle" fill="#e0e8ff">CPU 2</text> <text x="430" y="75" text-anchor="middle" fill="#7ab0ff" font-size="11">Core + Cache</text> <text x="430" y="91" text-anchor="middle" fill="#7ab0ff" font-size="11">L1 / L2</text> <rect x="540" y="30" width="120" height="70" rx="6" fill="#1e3a5f" stroke="#4a9eff" stroke-width="1.5"/> <text x="600" y="58" text-anchor="middle" fill="#e0e8ff">CPU 3</text> <text x="600" y="75" text-anchor="middle" fill="#7ab0ff" font-size="11">Core + Cache</text> <text x="600" y="91" text-anchor="middle" fill="#7ab0ff" font-size="11">L1 / L2</text> <!-- Shared bus --> <rect x="30" y="155" width="630" height="28" rx="4" fill="#2a2a4a" stroke="#8888cc" stroke-width="1.5"/> <text x="345" y="174" text-anchor="middle" fill="#ccccff">Shared Interconnect (Bus / Crossbar)</text> <!-- Vertical connectors CPU → bus --> <line x1="90" y1="100" x2="90" y2="155" stroke="#4a9eff" stroke-width="1.5" stroke-dasharray="4,2"/> <line x1="260" y1="100" x2="260" y2="155" stroke="#4a9eff" stroke-width="1.5" stroke-dasharray="4,2"/> <line x1="430" y1="100" x2="430" y2="155" stroke="#4a9eff" stroke-width="1.5" stroke-dasharray="4,2"/> <line x1="600" y1="100" x2="600" y2="155" stroke="#4a9eff" stroke-width="1.5" stroke-dasharray="4,2"/> <!-- Shared memory --> <rect x="200" y="240" width="300" height="60" rx="6" fill="#1a3a1a" stroke="#44cc66" stroke-width="1.5"/> <text x="350" y="265" text-anchor="middle" fill="#aaffcc">Shared Main Memory</text> <text x="350" y="284" text-anchor="middle" fill="#66cc88" font-size="11">Unified Physical Address Space</text> <!-- Bus → memory --> <line x1="350" y1="183" x2="350" y2="240" stroke="#44cc66" stroke-width="1.5" stroke-dasharray="4,2"/> <!-- I/O --> <rect x="560" y="240" width="120" height="60" rx="6" fill="#3a2a1a" stroke="#cc8844" stroke-width="1.5"/> <text x="620" y="265" text-anchor="middle" fill="#ffcc88">I/O</text> <text x="620" y="284" text-anchor="middle" fill="#cc9966" font-size="11">Devices / DMA</text> <line x1="620" y1="183" x2="620" y2="240" stroke="#cc8844" stroke-width="1.5" stroke-dasharray="4,2"/> </svg>

---

### Uniformity of Memory Access

SMP is synonymous with **UMA — Uniform Memory Access**. Every processor incurs the same latency and bandwidth to reach any memory address. This contrasts with NUMA (Non-Uniform Memory Access), where memory is physically partitioned and local accesses are faster than remote ones.

|Property|SMP / UMA|NUMA|
|---|---|---|
|Memory topology|Single shared pool|Partitioned; each node has local memory|
|Access latency|Uniform for all CPUs|Local < Remote|
|Scalability|Limited (bus saturation)|Better at large core counts|
|Programming model|Simpler|Requires topology-awareness for peak performance|

---

### Interconnect Topologies

#### Shared Bus

The original SMP interconnect. All processors and memory controllers attach to the same set of address, data, and control lines.

- **Arbitration** is required: only one agent may drive the bus at a time.
- **Snooping** is natural: every agent observes every transaction, enabling cache coherence without a directory.
- **Bottleneck**: bandwidth is fixed regardless of processor count. Beyond ~8–16 processors, contention degrades performance severely.

#### Crossbar Switch

An N×M switch fabric connects N processors to M memory banks. Any processor can simultaneously access a different memory bank.

- **Bandwidth scales** with the number of ports.
- **Cost scales** as O(N·M) — expensive at large N.
- Used in mid-range server chipsets and on-die interconnects.

#### Ring and Mesh

Modern multicore SMP systems use on-die ring buses (Intel) or 2D mesh networks (Intel Xeon Scalable, AMD EPYC) to connect cores, last-level cache slices, and memory controllers.

---

### Cache Coherence in SMP

Because each processor has a private cache, multiple copies of a cache line can exist simultaneously. Without coordination, processors would observe stale data. SMP systems enforce **cache coherence** — the invariant that all processors agree on the value of any memory location.

#### Snooping Protocols

Every cache controller monitors (snoops) the shared bus. When a transaction occurs, each controller checks whether the address matches a line it holds and updates its state accordingly.

The **MESI protocol** is the canonical snooping coherence protocol. Each cache line is in one of four states:

|State|Meaning|
|---|---|
|**M**odified|Held exclusively; dirty (differs from memory)|
|**E**xclusive|Held exclusively; clean (matches memory)|
|**S**hared|Held by one or more caches; clean|
|**I**nvalid|Not present or stale|

<svg viewBox="0 0 680 400" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- State nodes --> <!-- M --> <circle cx="160" cy="100" r="42" fill="#3a1a1a" stroke="#ff6655" stroke-width="2"/> <text x="160" y="95" text-anchor="middle" fill="#ffaaaa" font-size="14" font-weight="bold">M</text> <text x="160" y="114" text-anchor="middle" fill="#ff8877" font-size="10">Modified</text> <!-- E --> <circle cx="500" cy="100" r="42" fill="#1a2a3a" stroke="#55aaff" stroke-width="2"/> <text x="500" y="95" text-anchor="middle" fill="#aad4ff" font-size="14" font-weight="bold">E</text> <text x="500" y="114" text-anchor="middle" fill="#88bbff" font-size="10">Exclusive</text> <!-- S --> <circle cx="500" cy="290" r="42" fill="#1a3a1a" stroke="#55cc55" stroke-width="2"/> <text x="500" y="285" text-anchor="middle" fill="#aaffaa" font-size="14" font-weight="bold">S</text> <text x="500" y="304" text-anchor="middle" fill="#88cc88" font-size="10">Shared</text> <!-- I --> <circle cx="160" cy="290" r="42" fill="#2a2a2a" stroke="#888888" stroke-width="2"/> <text x="160" y="285" text-anchor="middle" fill="#cccccc" font-size="14" font-weight="bold">I</text> <text x="160" y="304" text-anchor="middle" fill="#aaaaaa" font-size="10">Invalid</text> <!-- Transitions --> <!-- I → E: processor read, no other copies --> <line x1="202" y1="272" x2="458" y2="118" stroke="#88bbff" stroke-width="1.4" marker-end="url(#arr)"/> <text x="360" y="175" fill="#88bbff" font-size="10">PrRd / no copies</text> <!-- I → S: processor read, others have copy --> <line x1="200" y1="290" x2="458" y2="290" stroke="#88cc88" stroke-width="1.4" marker-end="url(#arr)"/> <text x="290" y="308" fill="#88cc88" font-size="10">PrRd / others share</text> <!-- E → M: processor write --> <line x1="458" y1="88" x2="202" y2="88" stroke="#ff8877" stroke-width="1.4" marker-end="url(#arr)"/> <text x="290" y="80" fill="#ff8877" font-size="10">PrWr</text> <!-- S → I: bus invalidate --> <line x1="458" y1="272" x2="202" y2="118" stroke="#888888" stroke-width="1.4" marker-end="url(#arr)"/> <text x="290" y="220" fill="#aaaaaa" font-size="10">BusInval</text> <!-- M → I: bus read (writeback) --> <line x1="160" y1="142" x2="160" y2="248" stroke="#888888" stroke-width="1.4" marker-end="url(#arr)"/> <text x="60" y="200" fill="#aaaaaa" font-size="10">BusRd (WB)</text> <!-- E → S: another CPU reads --> <line x1="500" y1="142" x2="500" y2="248" stroke="#88cc88" stroke-width="1.4" marker-end="url(#arr)"/> <text x="510" y="200" fill="#88cc88" font-size="10">BusRd</text> <!-- S → M: processor write + invalidate others --> <path d="M 475 270 Q 330 170 185 118" stroke="#ff8877" stroke-width="1.4" fill="none" marker-end="url(#arr)" stroke-dasharray="5,3"/> <text x="280" y="155" fill="#ff8877" font-size="10">PrWr / BusInval</text> <defs> <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#aaaaaa"/> </marker> </defs> </svg>

#### Directory Protocols

When the processor count grows beyond what a shared bus can support, snooping becomes impractical — not every processor can observe every transaction. **Directory-based coherence** replaces broadcast with point-to-point messaging. A central (or distributed) directory tracks which caches hold each line. Requests are routed to the directory, which sends targeted invalidations or fetch commands only to the relevant nodes. This is the dominant approach in NUMA and large-scale systems, but the protocol logic maps onto SMP as well when a ring or mesh interconnect is used.

---

### OS Scheduling on SMP

The OS treats all processors as equal scheduling targets. Key concerns:

#### Load Balancing

The scheduler periodically checks run-queue lengths across all CPUs and migrates threads to idle or underloaded processors. This maintains throughput but can cause cache-cold migrations — a thread moved to a new CPU must repopulate its working set in that CPU's private cache.

#### Affinity and Pinning

**Processor affinity** (soft or hard) allows the OS or application to bind a thread to a specific CPU or set of CPUs. This exploits cache warmth and reduces inter-processor coherence traffic. Linux `taskset`, `sched_setaffinity`, and Windows affinity masks expose this mechanism.

#### Spinlocks and Synchronization

SMP requires hardware-supported atomic operations to protect shared data structures. The canonical primitives are:

- **Test-and-Set (TAS)**: atomically reads and sets a lock word. Simple but generates heavy bus traffic under contention because failed spinners continuously broadcast.
- **Test-and-Test-and-Set (TTAS)**: spin locally on a cached read; attempt TAS only when the value appears free. Dramatically reduces bus traffic.
- **Compare-and-Swap (CAS)**: atomically compares and conditionally writes. Foundation of lock-free data structures.
- **Load-Linked / Store-Conditional (LL/SC)**: RISC equivalent of CAS; avoids the ABA problem.

**Ticket locks** and **MCS locks** provide FIFO ordering and scale better than TAS/TTAS because each waiter spins on its own cache line rather than a shared word.

---

### Scalability Constraints

#### Bus Bandwidth Saturation

Shared-bus SMP bandwidth is fixed. As more processors compete, each processor's effective bandwidth share decreases. Empirically, shared-bus SMP saturates around 8–16 processors.

#### Cache Coherence Traffic

Every write to a shared line generates invalidation or update traffic. With many processors writing to the same data (false sharing or true sharing), coherence overhead becomes dominant. **False sharing** — two unrelated variables occupying the same cache line, written by different processors — is a common performance anti-pattern addressable by cache-line padding.

#### Memory Latency Uniformity

In a strict UMA SMP, all memory is equidistant. As core counts rise and die area grows, uniform access becomes physically harder to maintain. Modern high-core-count processors (e.g., AMD EPYC with multiple chiplets) technically violate strict UMA and exhibit NUMA-like latency non-uniformity even though the programming model may present them as SMP.

---

### SMP vs. Related Architectures

|Architecture|Memory model|OS instances|Notes|
|---|---|---|---|
|**SMP**|Shared, uniform (UMA)|One|Classic multiprocessor model|
|**NUMA**|Shared, non-uniform|One|Physically partitioned memory; same address space|
|**MPP** (Massively Parallel)|Distributed|Many|Nodes communicate via message passing (MPI)|
|**Cluster**|Distributed|Many per node|Commodity nodes + network fabric|
|**Multicore**|Shared (on-die)|One|SMP realized on a single die|

Multicore processors are an implementation of SMP: multiple processor cores on a single die share an LLC and a memory controller, communicating via an on-chip interconnect. The logical model is identical to multi-socket SMP.

---

### Hardware Implementation Considerations

#### Memory Controller Placement

Early SMP systems placed the memory controller on the **northbridge** chipset, external to all CPUs. Modern designs integrate the memory controller **on-die** (Intel since Nehalem, AMD since Opteron K8). This reduces latency and increases bandwidth but means that each processor directly owns a portion of the physical memory — a step toward NUMA even within nominally SMP systems.

#### Inter-Processor Interrupts (IPIs)

SMP requires a mechanism for one processor to interrupt another — for TLB shootdowns, cross-CPU function calls, and scheduler wakeups. The **APIC (Advanced Programmable Interrupt Controller)** provides this on x86. Each core has a Local APIC; an I/O APIC routes external interrupts. IPIs are sent via writes to the Interrupt Command Register (ICR) in the Local APIC.

#### TLB Shootdowns

When a page mapping is removed or modified on one processor, all other processors that may have cached that mapping in their TLBs must invalidate it. The modifying processor issues IPIs to all relevant CPUs, each of which executes a TLB flush (`INVLPG` or full `CR3` reload on x86). This is a synchronous, latency-sensitive operation that scales poorly with core count — a known SMP bottleneck under high `mmap`/`munmap` workloads.

---

**Key Points**

- SMP defines a model: symmetric processors, shared physical address space, single OS, uniform memory latency.
- Cache coherence (typically MESI snooping on smaller systems, directory-based on larger ones) is mandatory whenever private caches exist.
- The shared bus is the classical interconnect but saturates at modest processor counts; crossbars and on-die meshes extend scalability.
- OS concerns include load balancing, cache affinity, and atomic synchronization; hardware must provide atomic primitives and inter-processor interrupt mechanisms.
- Modern multicore processors implement SMP on-die; chiplet-based designs blur the boundary between SMP and NUMA.

**Conclusion** SMP remains the foundational model for shared-memory parallel computing. Its simplicity — a single address space, a single OS, equal processor capability — makes it the default target for general-purpose parallel software. Its scalability ceiling, rooted in bus bandwidth, coherence traffic, and uniform-latency constraints, motivates NUMA and distributed memory architectures at higher core counts.

**Next Steps** Proceed to **NUMA** for non-uniform memory access topology, **Cache Coherence protocols** (MSI, MESI, MOESI, directory) in depth, **Memory Consistency Models** (TSO, release consistency, sequential consistency), and **Synchronization Primitives in Hardware** for the full treatment of atomic operations and memory barriers.

---

