## Memory Consistency Models


A memory consistency model is a formal specification that defines the order in which memory operations — loads and stores — performed by one processor become visible to other processors in a shared-memory system. It is the contract between hardware and software: the programmer writes code assuming some ordering guarantee; the hardware may reorder operations freely as long as the observable result remains within what the model permits.

Without a defined consistency model, the behavior of any shared-memory concurrent program is undefined.

---

### Why Ordering Is Not Trivial

Modern processors and memory systems apply multiple transformations that can alter the order in which stores become globally visible:

- **Store buffers** — a processor buffers a write locally before committing it to cache
- **Invalidation queues** — cache coherence invalidation messages are queued, not applied immediately
- **Out-of-order execution** — the processor issues loads and stores in a reordered sequence
- **Compiler reordering** — the compiler moves instructions for optimization
- **Non-uniform memory latency** — in NUMA systems, different processors observe remote writes at different times

Each of these creates a gap between _program order_ (the order instructions appear in source/binary) and _observed order_ (the order other processors see the effects).

---

### Formal Definitions

Let:

- $P_i$ denote processor $i$
- $W(x)v$ denote a write of value $v$ to address $x$
- $R(x)v$ denote a read of address $x$ returning value $v$
- $\rightarrow_p$ denote program order on a single processor
- $\rightarrow_m$ denote memory order (the global serialization of operations)

A consistency model constrains the relationship between $\rightarrow_p$ and $\rightarrow_m$.

---

### Sequential Consistency (SC)

Proposed by Lamport (1979). The strongest widely-studied model.

**Definition:** A multiprocessor system is sequentially consistent if the result of any execution is the same as if the operations of all processors were executed in some sequential order, and the operations of each individual processor appear in that sequence in the order specified by its program.

Two requirements:

1. All processors agree on a single total order of all memory operations
2. Each processor's operations appear in that total order in program order

#### Execution Example

```
P1:  W(x)1       R(y)        → must see y=0 or y=1
P2:  W(y)1       R(x)        → must see x=0 or x=1

Under SC: if P1 reads y=0, then W(y)1 has not yet occurred,
          so P2 must read x=1 (P1's write already globally visible)
          → outcome (R(y)=0, R(x)=0) is FORBIDDEN under SC
```

#### SC Guarantees and Cost

SC forbids all reorderings. To implement it correctly:

|Required restriction|Hardware cost|
|---|---|
|Stores not buffered past subsequent loads|Eliminates store buffer benefit|
|No load–load reordering|Constrains OoO scheduling|
|No store–store reordering|Serializes write queue|
|All stores globally visible before next operation|Requires write completion acknowledgment|

SC is expensive. Most real architectures implement weaker models.

---

### Total Store Order (TSO)

The model implemented by x86/x86-64 (Intel and AMD). A relaxation of SC that permits one specific reordering: **stores may be delayed in a per-processor FIFO store buffer before becoming globally visible**, but loads bypass the store buffer to read the latest globally visible value (plus the local store buffer).

#### Permitted and Forbidden Reorderings

|Reordering|SC|TSO|
|---|---|---|
|Load → Load|Forbidden|Forbidden|
|Load → Store|Forbidden|Forbidden|
|Store → Store|Forbidden|Forbidden|
|**Store → Load**|**Forbidden**|**Permitted**|

The single relaxation (store → load) is the only one TSO adds over SC.

#### TSO Store Buffer Model

<svg viewBox="0 0 680 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- P1 box --> <rect x="40" y="20" width="120" height="40" rx="4" fill="#1a2a3a" stroke="#4fc3f7" stroke-width="1.5"/> <text x="100" y="45" fill="#4fc3f7" text-anchor="middle">Processor 1</text> <!-- P2 box --> <rect x="520" y="20" width="120" height="40" rx="4" fill="#1a2a3a" stroke="#4fc3f7" stroke-width="1.5"/> <text x="580" y="45" fill="#4fc3f7" text-anchor="middle">Processor 2</text> <!-- Store buffers --> <rect x="40" y="90" width="120" height="60" rx="3" fill="#1a2a1a" stroke="#66bb6a" stroke-width="1.5"/> <text x="100" y="110" fill="#66bb6a" text-anchor="middle" font-size="10">Store Buffer</text> <text x="100" y="128" fill="#aaa" text-anchor="middle" font-size="10">(FIFO, local)</text> <text x="100" y="143" fill="#f9a825" text-anchor="middle" font-size="10">W(x)=1 pending</text> <rect x="520" y="90" width="120" height="60" rx="3" fill="#1a2a1a" stroke="#66bb6a" stroke-width="1.5"/> <text x="580" y="110" fill="#66bb6a" text-anchor="middle" font-size="10">Store Buffer</text> <text x="580" y="128" fill="#aaa" text-anchor="middle" font-size="10">(FIFO, local)</text> <text x="580" y="143" fill="#f9a825" text-anchor="middle" font-size="10">W(y)=1 pending</text> <!-- Shared memory --> <rect x="220" y="175" width="240" height="55" rx="4" fill="#2a1a2a" stroke="#ce93d8" stroke-width="1.5"/> <text x="340" y="198" fill="#ce93d8" text-anchor="middle">Shared Memory</text> <text x="290" y="218" fill="#aaa" text-anchor="middle" font-size="10">x = 0</text> <text x="390" y="218" fill="#aaa" text-anchor="middle" font-size="10">y = 0</text> <!-- Arrows: processors to store buffers --> <line x1="100" y1="60" x2="100" y2="90" stroke="#4fc3f7" stroke-width="1.5" marker-end="url(#arr)"/> <line x1="580" y1="60" x2="580" y2="90" stroke="#4fc3f7" stroke-width="1.5" marker-end="url(#arr)"/> <!-- Arrows: store buffers to memory (delayed) --> <line x1="100" y1="150" x2="260" y2="175" stroke="#66bb6a" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#arr2)"/> <line x1="580" y1="150" x2="420" y2="175" stroke="#66bb6a" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#arr2)"/> <!-- Load bypass annotation -->

<text x="340" y="155" fill="#f9a825" text-anchor="middle" font-size="10">Loads read globally visible</text> <text x="340" y="168" fill="#f9a825" text-anchor="middle" font-size="10">value + own store buffer</text>

<defs> <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#4fc3f7"/> </marker> <marker id="arr2" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#66bb6a"/> </marker> </defs> </svg>

Under TSO, both `R(y)=0` and `R(x)=0` simultaneously is a **legal outcome** — each processor's load bypasses the other's still-buffered store. This is the classic **store-buffering** litmus test result, forbidden under SC, permitted under TSO.

#### MFENCE

x86 provides the `MFENCE` instruction to drain the store buffer, preventing store → load reordering at specific points. `SFENCE` orders only stores; `LFENCE` orders only loads.

---

### Relaxed / Weak Consistency Models

Processors such as ARM, POWER, and RISC-V (without extensions) implement substantially weaker models that permit all four reorderings plus additional relaxations:

|Reordering|SC|TSO|Relaxed (ARM/POWER)|
|---|---|---|---|
|Load → Load|✗|✗|✓|
|Load → Store|✗|✗|✓|
|Store → Store|✗|✗|✓|
|Store → Load|✗|✓|✓|
|Store atomicity relaxed|✗|✗|✓ (POWER)|

**Store atomicity relaxation** (POWER): a processor may observe its own store before that store is visible to other processors — meaning two processors can temporarily disagree on the value of a location.

#### Synchronization Primitives on Weak Models

Weak models require explicit **memory barriers** (also called fences) to enforce ordering at synchronization points:

|Barrier type|Meaning|
|---|---|
|`dmb sy` (ARM)|Full system data memory barrier; all accesses before complete before any after|
|`dmb st` (ARM)|Store–store barrier only|
|`dsb` (ARM)|Data synchronization barrier; stronger, also drains pipeline|
|`sync` (POWER)|Full heavyweight barrier|
|`lwsync` (POWER)|Lighter barrier; allows store→load reordering|
|`fence` (RISC-V)|Parameterized: `fence r,r`, `fence w,w`, `fence rw,rw`, etc.|

---

### Release Consistency (RC)

A structured weak model that categorizes synchronization accesses explicitly:

- **Ordinary accesses** — regular loads/stores; no ordering guarantee
- **Acquire** — a load with acquire semantics: no operation after the acquire may be reordered before it
- **Release** — a store with release semantics: no operation before the release may be reordered after it

#### Acquire–Release Ordering

<svg viewBox="0 0 640 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Thread 1 column -->

<text x="120" y="20" fill="#4fc3f7" text-anchor="middle">Thread 1 (producer)</text> <rect x="40" y="35" width="160" height="30" rx="3" fill="#1a2a1a" stroke="#888"/> <text x="120" y="55" fill="#aaa" text-anchor="middle">W(data) = 42</text> <rect x="40" y="75" width="160" height="30" rx="3" fill="#1a2a2a" stroke="#f9a825" stroke-width="2"/> <text x="120" y="95" fill="#f9a825" text-anchor="middle">RELEASE: W(flag)=1</text>

<!-- Thread 2 column -->

<text x="520" y="20" fill="#4fc3f7" text-anchor="middle">Thread 2 (consumer)</text> <rect x="440" y="35" width="160" height="30" rx="3" fill="#1a2a2a" stroke="#66bb6a" stroke-width="2"/> <text x="520" y="55" fill="#66bb6a" text-anchor="middle">ACQUIRE: R(flag)=1</text> <rect x="440" y="75" width="160" height="30" rx="3" fill="#1a2a1a" stroke="#888"/> <text x="520" y="95" fill="#aaa" text-anchor="middle">R(data) → must see 42</text>

<!-- Synchronizes-with arrow --> <line x1="200" y1="90" x2="440" y2="55" stroke="#ce93d8" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#arrrc)"/> <text x="320" y="65" fill="#ce93d8" text-anchor="middle" font-size="10">synchronizes-with</text> <!-- Happens-before annotations --> <line x1="120" y1="65" x2="120" y2="75" stroke="#888" stroke-width="1.5" marker-end="url(#arrrc)"/> <line x1="520" y1="65" x2="520" y2="75" stroke="#888" stroke-width="1.5" marker-end="url(#arrrc)"/>

<text x="320" y="150" fill="#777" text-anchor="middle" font-size="11">If T2 reads flag=1 (the release store), the acquire–release pair</text> <text x="320" y="168" fill="#777" text-anchor="middle" font-size="11">creates a happens-before edge: W(data) is guaranteed visible to T2.</text>

<defs> <marker id="arrrc" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#ce93d8"/> </marker> </defs> </svg>

The **synchronizes-with** relationship created by a matching acquire–release pair establishes a **happens-before** edge. All stores before the release are visible to any thread that subsequently performs the matching acquire.

This is the formal basis of `std::atomic` acquire/release in C++11 and `java.util.concurrent` in the JVM memory model.

---

### Causal Consistency

Weaker than SC, stronger than eventual consistency. Requires that causally related writes be seen in causal order by all processors; concurrent (causally unrelated) writes may be seen in different orders by different processors.

**Causal chain example:**

```
P1: W(x)=1
P2: R(x)=1   →   W(y)=1        (P2's write causally depends on reading x=1)
P3: must see W(x)=1 before W(y)=1
P4: may see W(x)=1 and W(y)=1 in any order (if it missed the causal chain)
```

Causal consistency is relevant in distributed systems and some GPU memory models.

---

### Processor Consistency (PC)

An intermediate model: every processor sees its own stores in order, and all processors agree on the order of stores from any single processor — but stores from different processors may be observed in different orders by different processors.

PC is strictly weaker than SC and strictly stronger than fully relaxed models. It corresponds roughly to the SPARC RMO with partial restrictions.

---

### Consistency Model Hierarchy

<svg viewBox="0 0 500 320" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <defs> <marker id="arrh" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto"> <path d="M0,0 L0,6 L8,3 z" fill="#555"/> </marker> </defs> <!-- SC --> <rect x="175" y="10" width="150" height="36" rx="5" fill="#1a2a3a" stroke="#4fc3f7" stroke-width="2"/> <text x="250" y="33" fill="#4fc3f7" text-anchor="middle">Sequential Consistency</text> <!-- TSO --> <rect x="175" y="80" width="150" height="36" rx="5" fill="#1a2a1a" stroke="#66bb6a" stroke-width="1.5"/> <text x="250" y="103" fill="#66bb6a" text-anchor="middle">TSO (x86)</text> <!-- PC --> <rect x="50" y="155" width="150" height="36" rx="5" fill="#2a2a1a" stroke="#f9a825" stroke-width="1.5"/> <text x="125" y="178" fill="#f9a825" text-anchor="middle">Processor Consistency</text> <!-- RC --> <rect x="300" y="155" width="150" height="36" rx="5" fill="#2a1a2a" stroke="#ce93d8" stroke-width="1.5"/> <text x="375" y="178" fill="#ce93d8" text-anchor="middle">Release Consistency</text> <!-- Weak / Relaxed --> <rect x="175" y="232" width="150" height="36" rx="5" fill="#2a1a1a" stroke="#ef9a9a" stroke-width="1.5"/> <text x="250" y="253" fill="#ef9a9a" text-anchor="middle">Relaxed</text> <text x="250" y="264" fill="#ef9a9a" text-anchor="middle" font-size="9">(ARM, POWER, RISC-V)</text> <!-- Arrows (stronger → weaker) --> <line x1="250" y1="46" x2="250" y2="80" stroke="#555" stroke-width="1.5" marker-end="url(#arrh)"/> <line x1="220" y1="116" x2="160" y2="155" stroke="#555" stroke-width="1.5" marker-end="url(#arrh)"/> <line x1="280" y1="116" x2="340" y2="155" stroke="#555" stroke-width="1.5" marker-end="url(#arrh)"/> <line x1="160" y1="191" x2="220" y2="232" stroke="#555" stroke-width="1.5" marker-end="url(#arrh)"/> <line x1="340" y1="191" x2="280" y2="232" stroke="#555" stroke-width="1.5" marker-end="url(#arrh)"/>

<text x="250" y="310" fill="#555" text-anchor="middle" font-size="10">Arrow direction: strictly stronger → weaker</text> </svg>

---

### Litmus Tests

Litmus tests are minimal concurrent programs used to distinguish consistency models by testing whether a specific outcome is observable.

#### Litmus Test 1 — Store Buffering (SB)

```
Initial: x = 0, y = 0

P1: W(x) = 1 ; R(y) → r1
P2: W(y) = 1 ; R(x) → r2

Forbidden under SC:  r1=0 ∧ r2=0
Permitted under TSO: r1=0 ∧ r2=0  ← both reads bypass buffered stores
```

#### Litmus Test 2 — Message Passing (MP)

```
Initial: data = 0, flag = 0

P1: W(data) = 42 ; W(flag) = 1
P2: loop until R(flag) = 1 ; R(data) → r

Forbidden under SC:  r ≠ 42
Permitted under TSO: r = 0  ← W(data) may still be in store buffer when flag is visible
Fix: MFENCE between W(data) and W(flag) on P1
```

#### Litmus Test 3 — Independent Reads of Independent Writes (IRIW)

```
Initial: x = 0, y = 0

P1: W(x) = 1
P2: W(y) = 1
P3: R(x)→1 ; R(y)→0
P4: R(y)→1 ; R(x)→0

Forbidden under SC and TSO: P3 and P4 disagree on order of writes
Permitted under POWER:       yes, due to relaxed store atomicity
```

IRIW distinguishes TSO from POWER — TSO forbids this outcome; POWER does not.

---

### The C++ and Java Memory Models

Programming language memory models abstract over hardware models, providing a portable specification.

#### C++11 Memory Model

Defines six ordering modes for atomic operations:

|Mode|Ordering guarantee|
|---|---|
|`memory_order_relaxed`|No ordering; only atomicity of the operation itself|
|`memory_order_consume`|Dependency-ordered acquire (deprecated in practice)|
|`memory_order_acquire`|No loads/stores after may move before this load|
|`memory_order_release`|No loads/stores before may move after this store|
|`memory_order_acq_rel`|Acquire + release combined (for RMW operations)|
|`memory_order_seq_cst`|Full sequential consistency; default for `std::atomic`|

`seq_cst` operations form a single total order visible to all threads — the software equivalent of SC. Using `acquire`/`release` reduces to the release consistency model and maps cheaply to hardware barriers.

#### Java Memory Model (JSR-133)

- Defines **happens-before** as the fundamental ordering relation
- `volatile` reads/writes have acquire/release semantics
- `synchronized` blocks create happens-before edges at lock acquire and release
- Final fields of properly constructed objects are visible to all threads without synchronization after construction completes

---

### Data Race and Undefined Behavior

A **data race** occurs when:

1. Two threads access the same memory location concurrently
2. At least one access is a write
3. The accesses are not ordered by happens-before

Under both C++ and Java memory models, a program with a data race has **undefined behavior** (C++) or exhibits **arbitrary values** (Java). The memory model only provides guarantees to **data-race-free** programs — this is the **DRF guarantee**.

> [Inference] Hardware implementations may tolerate data races silently in some cases, but the language-level models provide no guarantee of any specific behavior. This is not confirmed to hold uniformly across architectures or compiler versions.

---

### Hardware Implementation Mechanisms

|Mechanism|Consistency effect|
|---|---|
|Store buffer drain on MFENCE|Enforces store → load ordering (TSO → SC at that point)|
|Load–load fence|Prevents speculative load reordering|
|Invalidation queue flush|Ensures received invalidations are applied before subsequent loads|
|Exclusive cache state (MESI)|Atomic RMW via load-linked/store-conditional or LOCK prefix|
|Point-to-point ordering in interconnect|Maintains store visibility order on the coherence fabric|

---

### NUMA and Consistency

In NUMA systems, a store from one socket must traverse the interconnect before remote sockets see it. This introduces additional visibility latency. NUMA does not inherently relax the consistency model — x86 NUMA remains TSO — but it increases the cost of achieving SC-level synchronization because cross-socket barriers are expensive.

---

**Key Points**

- A memory consistency model defines which orderings of loads and stores are observable by other processors.
- Sequential consistency requires a global total order matching all processors' program orders — correct but expensive.
- TSO (x86) permits store → load reordering via store buffers; all other orderings are preserved.
- ARM and POWER permit all four reorderings and require explicit barriers for correctness.
- Release consistency uses acquire/release annotations to create happens-before edges at synchronization points only.
- Litmus tests — SB, MP, IRIW — are standard tools to empirically and formally distinguish models.
- C++11 memory order modes map directly onto hardware barrier instructions; `seq_cst` is most expensive, `relaxed` is cheapest.
- The DRF guarantee: a memory model only provides meaningful ordering guarantees to programs that are data-race-free.

**Next Steps** Advance to synchronization primitives in hardware (compare-and-swap, load-linked/store-conditional, ticket locks, MCS locks) or to cache coherence protocols (MSI, MESI, MOESI) which are the substrate on which memory consistency is implemented.

---

