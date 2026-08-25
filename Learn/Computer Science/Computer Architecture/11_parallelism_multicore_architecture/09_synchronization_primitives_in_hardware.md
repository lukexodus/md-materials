## Synchronization Primitives in Hardware


Synchronization primitives are the hardware mechanisms that enforce ordering, mutual exclusion, and coordination among concurrent agents — cores, threads, or processors — that share state. Software synchronization constructs (mutexes, semaphores, barriers) are ultimately implemented on top of these hardware primitives. Understanding them requires confronting the realities of cache coherence, memory consistency, and the out-of-order behavior of modern pipelines.

---

### The Problem of Shared-State Concurrency

On a uniprocessor, disabling interrupts is sufficient to protect a critical section. On a multiprocessor, this is inadequate: multiple cores execute simultaneously and independently. Three distinct problems must be solved:

- **Atomicity** — a read-modify-write sequence must complete without any other agent observing or modifying the value in between.
- **Visibility** — a write by one core must become visible to other cores in a defined and timely manner.
- **Ordering** — operations must not be reordered by the processor or memory system in ways that violate the intended synchronization contract.

No single mechanism addresses all three in isolation. Hardware provides building blocks; correct synchronization requires composing them properly.

---

### Memory Consistency and Why It Matters

Before examining primitives, the memory consistency model must be understood — it defines which values a load is permitted to return given a history of stores from all cores.

#### Sequential Consistency (SC)

Lamport's definition: the result of any execution is the same as if all operations of all processors were executed in some sequential order, with each processor's operations appearing in program order. Intuitive but expensive to implement — it prohibits nearly all hardware reordering.

#### Total Store Order (TSO)

Used by x86. Stores may be buffered in a per-core **store buffer** before reaching the cache. A core sees its own stores immediately (store-to-load forwarding), but other cores see them only after they drain from the store buffer. Loads are not reordered with respect to other loads; stores are not reordered with respect to other stores. However, a store followed by a load to a different address may be observed out of order by other cores.

#### Relaxed Consistency (ARM, RISC-V, POWER)

Both loads and stores may be reordered freely unless explicitly constrained. Provides maximum pipeline and memory-system flexibility, but requires explicit **memory barrier** instructions to enforce ordering where needed.

<svg viewBox="0 0 620 210" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Header --> <text x="310" y="22" text-anchor="middle" fill="#94a3b8" font-size="13">Reordering Permitted by Model</text> <!-- Column headers -->

<text x="130" y="48" text-anchor="middle" fill="#e2e8f0">SC</text> <text x="280" y="48" text-anchor="middle" fill="#e2e8f0">TSO (x86)</text> <text x="460" y="48" text-anchor="middle" fill="#e2e8f0">Relaxed (ARM/RISC-V)</text>

<!-- Row labels -->

<text x="10" y="80" fill="#94a3b8">Load → Load</text> <text x="10" y="110" fill="#94a3b8">Load → Store</text> <text x="10" y="140" fill="#94a3b8">Store → Store</text> <text x="10" y="170" fill="#94a3b8">Store → Load</text>

<!-- SC column: all No -->

<text x="130" y="80" text-anchor="middle" fill="#4ade80">No</text> <text x="130" y="110" text-anchor="middle" fill="#4ade80">No</text> <text x="130" y="140" text-anchor="middle" fill="#4ade80">No</text> <text x="130" y="170" text-anchor="middle" fill="#4ade80">No</text>

<!-- TSO column -->

<text x="280" y="80" text-anchor="middle" fill="#4ade80">No</text> <text x="280" y="110" text-anchor="middle" fill="#4ade80">No</text> <text x="280" y="140" text-anchor="middle" fill="#4ade80">No</text> <text x="280" y="170" text-anchor="middle" fill="#f87171">Yes</text>

<!-- Relaxed column: all Yes -->

<text x="460" y="80" text-anchor="middle" fill="#f87171">Yes</text> <text x="460" y="110" text-anchor="middle" fill="#f87171">Yes</text> <text x="460" y="140" text-anchor="middle" fill="#f87171">Yes</text> <text x="460" y="170" text-anchor="middle" fill="#f87171">Yes</text>

<!-- Dividers --> <line x1="0" y1="55" x2="620" y2="55" stroke="#334155" stroke-width="1"/> <line x1="0" y1="88" x2="620" y2="88" stroke="#1e293b" stroke-width="1"/> <line x1="0" y1="118" x2="620" y2="118" stroke="#1e293b" stroke-width="1"/> <line x1="0" y1="148" x2="620" y2="148" stroke="#1e293b" stroke-width="1"/> <line x1="195" y1="35" x2="195" y2="185" stroke="#334155" stroke-width="1"/> <line x1="370" y1="35" x2="370" y2="185" stroke="#334155" stroke-width="1"/> </svg>

---

### Atomic Read-Modify-Write Operations

The core hardware primitive for mutual exclusion is an **atomic read-modify-write (RMW)**: a single indivisible operation that reads a memory location, computes a new value, and writes it back, with no other agent able to interleave.

#### Test-and-Set (TAS)

The simplest RMW. Atomically reads a memory word and writes 1 to it, returning the old value.

```
TAS(addr):
    old ← mem[addr]
    mem[addr] ← 1
    return old
```

A lock is acquired if TAS returns 0 (lock was free); the caller spins if it returns 1. Implemented as a single locked bus transaction or cache-line exclusive acquisition.

**Key Points:**

- Only one bit of information is exchanged.
- Simple spin-wait on TAS causes severe **bus/cache thrashing**: every spinning core repeatedly issues exclusive RMW requests, invalidating the cache line on each attempt across all cores.

#### Compare-and-Swap (CAS)

Atomically compares the current value at an address to an expected value; if equal, writes a new value. Returns a success/failure indicator (or the old value).

```
CAS(addr, expected, new):
    old ← mem[addr]
    if old == expected:
        mem[addr] ← new
        return success
    return failure
```

CAS is the foundation of most lock-free data structures. It is universally available on x86 (`CMPXCHG`), ARM (`CASAL`), and RISC-V (`amocas`).

**Key Points:**

- Enables **lock-free** algorithms: progress is guaranteed for at least one thread even if others stall.
- Susceptible to the **ABA problem**: if a value changes A → B → A between the read and the write, CAS succeeds incorrectly. Solved with versioned pointers or double-width CAS.

#### Fetch-and-Add (FAA)

Atomically increments a memory location and returns the old value. Directly maps to hardware counter operations.

```
FAA(addr, increment):
    old ← mem[addr]
    mem[addr] ← old + increment
    return old
```

x86: `LOCK XADD`. ARM: `LDADD`. RISC-V: `amoadd`.

#### Fetch-and-Op (General)

The generalization: atomically apply any operation (AND, OR, XOR, MIN, MAX, swap) and return the old value. RISC-V AMO instructions directly implement this class. GPU architectures provide atomics for this full class as they are critical for parallel reduction operations.

---

### Load-Linked / Store-Conditional (LL/SC)

An alternative to locked RMW instructions, used by ARM (`LDXR`/`STXR`), MIPS (`LL`/`SC`), RISC-V (`LR`/`SC`), and POWER (`LWARX`/`STWCX`).

**Load-Linked (LL/LR):** loads a value and marks the cache line with a hardware **reservation** tag.

**Store-Conditional (SC/SR):** attempts to store to the same address. The store **succeeds** (returns 0 on RISC-V) only if the reservation is still valid — meaning no other agent wrote to that cache line since the LL. If the reservation was invalidated, the store **fails** (returns non-zero) and the caller must retry.

```
retry:
    LR   t0, (a0)        // load-reserved; mark reservation
    ADDI t1, t0, 1       // compute new value
    SC   t2, t1, (a0)    // store-conditional
    BNEZ t2, retry       // retry if store failed
```

<svg viewBox="0 0 600 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <text x="300" y="22" text-anchor="middle" fill="#94a3b8" font-size="13">LL/SC Execution — Success vs. Failure</text> <!-- Core A column -->

<text x="120" y="48" text-anchor="middle" fill="#60a5fa" font-size="12">Core A</text>

<!-- Core B column -->

<text x="380" y="48" text-anchor="middle" fill="#f472b6" font-size="12">Core B</text>

<!-- Time axis --> <line x1="300" y1="40" x2="300" y2="245" stroke="#334155" stroke-width="1.5" stroke-dasharray="4,3"/> <text x="300" y="255" text-anchor="middle" fill="#475569" font-size="11">time ↓</text> <!-- Core A: LR --> <rect x="40" y="58" width="160" height="28" rx="4" fill="#1e3a5f" stroke="#60a5fa" stroke-width="1"/> <text x="120" y="76" text-anchor="middle" fill="#bfdbfe">LR t0, (a0) ✓ reserved</text> <!-- Core B: write --> <rect x="320" y="100" width="160" height="28" rx="4" fill="#4a1942" stroke="#f472b6" stroke-width="1"/> <text x="400" y="118" text-anchor="middle" fill="#fbcfe8">SW (a0) → invalidates</text> <!-- Arrow: B invalidates reservation --> <line x1="320" y1="114" x2="200" y2="114" stroke="#f87171" stroke-width="1.5" stroke-dasharray="4,2"/> <polygon points="204,109 194,114 204,119" fill="#f87171"/> <text x="255" y="108" text-anchor="middle" fill="#f87171" font-size="11">reservation lost</text> <!-- Core A: SC fails --> <rect x="40" y="140" width="160" height="28" rx="4" fill="#3b1f1f" stroke="#f87171" stroke-width="1"/> <text x="120" y="158" text-anchor="middle" fill="#fca5a5">SC t2, t1, (a0) ✗ fail</text> <!-- Core A: retry LR --> <rect x="40" y="186" width="160" height="28" rx="4" fill="#1e3a5f" stroke="#60a5fa" stroke-width="1"/> <text x="120" y="204" text-anchor="middle" fill="#bfdbfe">LR t0, (a0) ✓ reserved</text> <!-- Core A: SC succeeds --> <rect x="40" y="218" width="160" height="28" rx="4" fill="#14532d" stroke="#4ade80" stroke-width="1"/> <text x="120" y="236" text-anchor="middle" fill="#bbf7d0">SC t2, t1, (a0) ✓ ok</text> </svg>

**Key Points:**

- LL/SC is **composable**: any RMW (CAS, FAA, swap) can be synthesized from LL/SC in a retry loop.
- Reservations are invalidated by any write to the monitored cache line, including spurious ones (context switches, cache evictions). This is called a **spurious failure** and is architecturally permitted — implementations must be prepared to retry.
- LL/SC avoids the ABA problem by nature: if the value changed and changed back, the intervening write invalidated the reservation regardless of the final value.

---

### Memory Barriers (Fences)

On relaxed-consistency architectures, a **memory barrier** (fence) constrains the reordering of memory operations around it. Barriers are not synchronization operations in themselves — they enforce ordering so that surrounding synchronization is correctly visible.

#### Barrier Types

|Barrier|Meaning|
|---|---|
|**Full fence**|No memory operation may cross this point in either direction|
|**Store fence**|All prior stores complete before any subsequent store is issued|
|**Load fence**|All prior loads complete before any subsequent load is issued|
|**Acquire**|No subsequent load or store may be reordered before this operation|
|**Release**|No prior load or store may be reordered after this operation|

**Acquire/Release** semantics are the preferred pairing for lock implementations:

- **Lock acquire** uses an acquire barrier: operations inside the critical section cannot float up above the lock.
- **Lock release** uses a release barrier: operations inside the critical section cannot float down below the unlock.

<svg viewBox="0 0 480 230" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <text x="240" y="20" text-anchor="middle" fill="#94a3b8" font-size="13">Acquire / Release Barrier Semantics</text> <!-- Program order arrow --> <line x1="30" y1="35" x2="30" y2="210" stroke="#475569" stroke-width="1.5"/> <polygon points="25,205 30,215 35,205" fill="#475569"/> <text x="22" y="130" fill="#475569" font-size="11" transform="rotate(-90,22,130)">program order</text> <!-- Instructions above acquire --> <rect x="60" y="35" width="360" height="28" rx="4" fill="#1e293b" stroke="#334155" stroke-width="1"/> <text x="240" y="53" text-anchor="middle" fill="#64748b">ops above (may reorder freely)</text> <!-- ACQUIRE --> <rect x="60" y="78" width="360" height="28" rx="4" fill="#1c3a5f" stroke="#60a5fa" stroke-width="1.5"/> <text x="240" y="96" text-anchor="middle" fill="#93c5fd">LOCK ACQUIRE [acquire barrier]</text> <!-- barrier line --> <line x1="60" y1="107" x2="420" y2="107" stroke="#60a5fa" stroke-width="1" stroke-dasharray="3,2"/> <text x="430" y="111" fill="#60a5fa" font-size="10">↓ nothing crosses down</text> <!-- Critical section --> <rect x="60" y="112" width="360" height="40" rx="4" fill="#172032" stroke="#334155" stroke-width="1"/> <text x="240" y="136" text-anchor="middle" fill="#e2e8f0">critical section ops</text> <!-- barrier line --> <line x1="60" y1="153" x2="420" y2="153" stroke="#f472b6" stroke-width="1" stroke-dasharray="3,2"/> <text x="430" y="157" fill="#f472b6" font-size="10">↑ nothing crosses up</text> <!-- RELEASE --> <rect x="60" y="158" width="360" height="28" rx="4" fill="#3b1248" stroke="#f472b6" stroke-width="1.5"/> <text x="240" y="176" text-anchor="middle" fill="#f9a8d4">LOCK RELEASE [release barrier]</text> <!-- Instructions below --> <rect x="60" y="196" width="360" height="28" rx="4" fill="#1e293b" stroke="#334155" stroke-width="1"/> <text x="240" y="214" text-anchor="middle" fill="#64748b">ops below (may reorder freely)</text> </svg>

**ISA Barrier Instructions:**

|Architecture|Full Fence|Acquire|Release|
|---|---|---|---|
|x86|`MFENCE`|implicit on loads|`SFENCE` (or `LOCK` prefix)|
|ARM64|`DMB ISH`|`LDAR`|`STLR`|
|RISC-V|`FENCE`|`FENCE r,rw`|`FENCE rw,w`|
|POWER|`SYNC`|`LWSYNC`|`LWSYNC`|

On x86 TSO, the strong model means that most barriers are implicit — only `MFENCE` (for store-load reordering) and the `LOCK` prefix are commonly required.

---

### Spinlocks

A spinlock is the most direct use of atomic RMW. The lock variable is 0 (free) or 1 (held). Acquisition spins until TAS or CAS succeeds.

#### Naïve TAS Spinlock (Pathological)

```c
while (TAS(&lock) == 1) { }   // spin — acquire
// critical section
lock = 0;                      // release
```

Each spinning core issues an exclusive RMW on every iteration. Every such attempt invalidates the cache line on all other cores, generating O(N²) coherence traffic for N contending cores. This is **cache thrashing**.

#### Test-and-Test-and-Set (TATAS)

A refinement: spin on a plain read first; attempt TAS only when the lock appears free.

```c
while (true) {
    while (lock == 1) { }      // spin read-only (shared state, no invalidation)
    if (TAS(&lock) == 0) break; // attempt acquire only when it looks free
}
```

**Key Points:**

- Cache lines in **Shared** state can be read by all cores without generating coherence traffic.
- TAS is attempted only on a transition from 1 → 0, greatly reducing exclusive requests.
- Still not fair — no ordering on who acquires next.

#### Ticket Lock

Provides **FIFO fairness**. Two counters: `next_ticket` and `now_serving`. Acquisition fetches and increments `next_ticket` (via FAA); the thread waits until `now_serving` equals its ticket. Release increments `now_serving`.

```c
// acquire
my_ticket = FAA(&next_ticket, 1)
while (now_serving != my_ticket) { }

// release
now_serving++
```

**Key Points:**

- Strict FIFO — no starvation.
- On release, all spinning cores observe the write to `now_serving` and re-check — still O(N) coherence traffic per release on large systems.

#### MCS Lock

Solves the O(N) coherence traffic problem. Each waiting thread spins on its **own** queue node, not on a shared variable. The lock is a pointer to the tail of the queue. Release directly signals only the next node.

**Key Points:**

- O(1) coherence traffic per acquisition and release regardless of N.
- Preferred in OS kernels (Linux `qspinlock` is MCS-based).
- Slightly more complex: requires allocating queue nodes and handling the case where no successor exists yet at release time.

---

### Hardware Transactional Memory (HTM)

HTM extends the LL/SC concept to entire **memory regions** rather than single cache lines. A transaction speculatively executes a code region, tracking all reads and writes in a **read set** and **write set** in the cache. On commit, if no conflict occurred (no other core wrote to any address in the read or write set), all writes become visible atomically. On conflict, the transaction **aborts** and rolls back to the start, typically falling back to a conventional lock.

**Key Points:**

- Allows optimistic concurrency: no lock is held while the transaction executes speculatively.
- The cache itself serves as the transactional buffer — transaction size is bounded by cache capacity.
- Aborts may be triggered by cache evictions, interrupts, or context switches, not only conflicts.
- Implementations include Intel TSX (deprecated for reliability issues in some steppings), IBM POWER HTM, and ARM TME.
- HTM does not replace locks; a **fallback path** using conventional locks is required for correctness when transactions repeatedly abort.

---

### Hardware Support for Semaphores and Condition Variables

Semaphores and condition variables are not directly implemented in hardware. They are constructed from atomic RMW primitives and memory barriers, with the OS providing the **blocking** behavior (descheduling the waiting thread) to avoid wasting CPU cycles in spin-wait.

The critical hardware support is:

- An atomic decrement with test (for `sem_wait`): decrement the counter; if the result is negative, the thread must block — this check-and-block must be atomic with respect to `sem_post`.
- On x86, `LOCK XADD` followed by a conditional `FUTEX_WAIT` syscall is the typical implementation pattern in Linux.

---

### MONITOR / MWAIT (x86)

`MONITOR` arms a hardware monitor on a cache line address. `MWAIT` puts the core into a low-power state and wakes it when a write to the monitored address is detected by the cache coherence system. This allows efficient spinning without a full busy-wait loop burning power.

**Key Points:**

- Reduces the power cost of spinning.
- The wakeup is not guaranteed to correspond to a semantically meaningful event — spurious wakeups occur and callers must recheck their condition.
- Used internally in OS scheduler idle loops and in userspace spinlock implementations where power efficiency matters.

---

### Wait-For Dependency Chains and Deadlock

Hardware primitives do not prevent deadlock — they provide the building blocks that software uses, correctly or incorrectly. Hardware does, however, contribute to deadlock **detection** in some interconnect and coherence protocols, where cyclic dependency detection in the coherence state machine can trigger a recovery action.

Livelock is a related hazard: two cores continuously retry CAS or LL/SC operations, each invalidating the other's reservation. Randomized exponential backoff is the standard mitigation.

---

**Conclusion**

Hardware synchronization primitives form a minimal but complete foundation for all higher-level concurrency abstractions. Atomic RMW instructions provide indivisibility; memory barriers enforce ordering under relaxed consistency models; LL/SC enables composable RMW sequences without the ABA hazard. The correct composition of these primitives — respecting the memory consistency model of the target architecture — is necessary and sufficient to construct correct locks, lock-free structures, and synchronization barriers. Performance, however, depends critically on cache coherence behavior: the transition from naïve TAS to TATAS to ticket locks to MCS locks represents successive refinements in coherence traffic, not in correctness.

**Next Steps**

- Study **cache coherence protocols (MESI, MOESI)** to understand what physically happens when atomic operations acquire exclusive cache-line ownership (Module 7)
- Examine **memory consistency models** in depth as a formal treatment of what barriers must enforce
- Connect to **out-of-order execution and the ROB** to understand why stores are buffered and why barriers must drain those buffers (Module 6)
- Review **GPU synchronization primitives** — warp-level atomics and memory scopes — as the multicore model scaled to thousands of threads (Module 11)

---

