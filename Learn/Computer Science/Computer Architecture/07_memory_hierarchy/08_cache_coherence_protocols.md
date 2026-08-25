## Cache Coherence Protocols


In a multiprocessor system, each core maintains its own private cache. When multiple caches hold copies of the same memory block, they must agree on its value at all times. Cache coherence protocols enforce this agreement by tracking the state of every cached block and governing how cores acquire, share, and invalidate copies.

---

### The Coherence Problem

<svg viewBox="0 0 680 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="200" fill="#1e1e2e"/> <!-- Core 0 cache --> <rect x="30" y="30" width="140" height="70" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/> <text x="100" y="50" fill="#89b4fa" text-anchor="middle">Core 0 Cache</text> <text x="100" y="68" fill="#cdd6f4" text-anchor="middle">addr X → val 5</text> <text x="100" y="84" fill="#585b70" text-anchor="middle" font-size="10">written locally</text> <!-- Core 1 cache --> <rect x="270" y="30" width="140" height="70" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/> <text x="340" y="50" fill="#89b4fa" text-anchor="middle">Core 1 Cache</text> <text x="340" y="68" fill="#f38ba8" text-anchor="middle">addr X → val 3</text> <text x="340" y="84" fill="#585b70" text-anchor="middle" font-size="10">stale copy</text> <!-- Core 2 cache --> <rect x="510" y="30" width="140" height="70" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/> <text x="580" y="50" fill="#89b4fa" text-anchor="middle">Core 2 Cache</text> <text x="580" y="68" fill="#f38ba8" text-anchor="middle">addr X → val 3</text> <text x="580" y="84" fill="#585b70" text-anchor="middle" font-size="10">stale copy</text> <!-- Shared memory --> <rect x="240" y="148" width="200" height="36" rx="4" fill="#1a2a3a" stroke="#cba6f7" stroke-width="1.5"/> <text x="340" y="164" fill="#cba6f7" text-anchor="middle">Main Memory</text> <text x="340" y="178" fill="#cdd6f4" text-anchor="middle">addr X → val 3</text> <!-- Interconnect line --> <line x1="30" y1="148" x2="650" y2="148" stroke="#585b70" stroke-width="1.5" stroke-dasharray="4,2"/> <text x="340" y="143" fill="#585b70" text-anchor="middle" font-size="10">shared interconnect</text> <!-- Drop lines --> <line x1="100" y1="100" x2="100" y2="148" stroke="#585b70" stroke-width="1"/> <line x1="340" y1="100" x2="340" y2="148" stroke="#585b70" stroke-width="1"/> <line x1="580" y1="100" x2="580" y2="148" stroke="#585b70" stroke-width="1"/> <!-- Problem annotation -->

<text x="340" y="16" fill="#f38ba8" text-anchor="middle" font-size="12">Core 0 wrote X=5; Cores 1 and 2 still see X=3 — incoherent</text> </svg>

A coherence protocol must satisfy two invariants:

**Write propagation** — a write by any core must eventually become visible to all other cores.

**Write serialization** — all cores must observe all writes to the same address in the same order.

---

### Coherence Mechanisms

#### Snooping

Each cache controller monitors (snoops) every transaction on the shared bus. When it detects a relevant address, it reacts accordingly — invalidating, supplying data, or updating its own copy. Snooping is simple and fast but does not scale beyond ~16–32 cores because every cache must observe every transaction.

#### Directory-Based

A central directory tracks which caches hold each block. Coherence messages are sent only to relevant caches — no broadcast required. This scales to hundreds of cores at the cost of directory storage and additional message latency.

All protocols below are presented in the snooping model for clarity. The same state machines apply in directory implementations with point-to-point messages substituted for broadcasts.

---

### State Representation

Each cache line carries a coherence state tag stored alongside the tag and data arrays. The protocol state machine governs transitions between these states in response to local processor requests and observed bus transactions.

---

### MSI Protocol

The simplest invalidation-based protocol. Three states:

|State|Meaning|Can Read?|Can Write?|Memory Up to Date?|
|---|---|---|---|---|
|**M** odified|Exclusive dirty copy|Yes|Yes|No — cache has the only valid copy|
|**S** hared|Clean shared copy (≥1 holders)|Yes|No|Yes|
|**I** nvalid|Not present or invalid|No|No|Yes|

#### MSI State Diagram

<svg viewBox="0 0 680 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="340" fill="#1e1e2e"/> <!-- State circles --> <!-- I --> <circle cx="120" cy="200" r="44" fill="#2a2a2a" stroke="#585b70" stroke-width="2"/> <text x="120" y="196" fill="#585b70" text-anchor="middle" font-size="15" font-weight="bold">I</text> <text x="120" y="212" fill="#585b70" text-anchor="middle" font-size="9">Invalid</text> <!-- S --> <circle cx="340" cy="80" r="44" fill="#1e3a5f" stroke="#89b4fa" stroke-width="2"/> <text x="340" y="76" fill="#89b4fa" text-anchor="middle" font-size="15" font-weight="bold">S</text> <text x="340" y="92" fill="#89b4fa" text-anchor="middle" font-size="9">Shared</text> <!-- M --> <circle cx="560" cy="200" r="44" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="2"/> <text x="560" y="196" fill="#a6e3a1" text-anchor="middle" font-size="15" font-weight="bold">M</text> <text x="560" y="212" fill="#a6e3a1" text-anchor="middle" font-size="9">Modified</text> <!-- I → S: PrRd / BusRd --> <path d="M155,175 Q240,100 298,95" fill="none" stroke="#89b4fa" stroke-width="1.5" marker-end="url(#ams1)"/> <text x="195" y="122" fill="#89b4fa" font-size="10">PrRd / BusRd</text> <!-- S → I: BusRdX (observed) --> <path d="M302,108 Q220,130 158,180" fill="none" stroke="#f38ba8" stroke-width="1.5" marker-end="url(#ams2)"/> <text x="190" y="162" fill="#f38ba8" font-size="10">BusRdX (snoop)</text> <text x="190" y="174" fill="#f38ba8" font-size="10">→ Invalidate</text> <!-- I → M: PrWr / BusRdX --> <path d="M160,215 Q340,280 518,220" fill="none" stroke="#a6e3a1" stroke-width="1.5" marker-end="url(#ams3)"/> <text x="340" y="278" fill="#a6e3a1" font-size="10">PrWr / BusRdX (fetch+invalidate)</text> <!-- M → I: BusRd (snoop) — writeback --> <path d="M524,178 Q400,110 380,92" fill="none" stroke="#fab387" stroke-width="1.5" marker-end="url(#ams4)"/> <text x="470" y="128" fill="#fab387" font-size="10">BusRd (snoop)</text> <text x="470" y="140" fill="#fab387" font-size="10">→ Writeback+S</text> <!-- S → M: PrWr / BusRdX (upgrade) --> <path d="M382,90 Q500,80 518,175" fill="none" stroke="#a6e3a1" stroke-width="1.5" marker-end="url(#ams5)"/> <text x="490" y="110" fill="#a6e3a1" font-size="10">PrWr / BusUpgr</text> <!-- M → M self loop (PrRd, PrWr) --> <path d="M590,165 Q640,130 600,168" fill="none" stroke="#585b70" stroke-width="1.2" marker-end="url(#ams6)"/> <text x="630" y="148" fill="#585b70" font-size="9">PrRd/PrWr</text> <!-- S → S self loop --> <path d="M340,36 Q310,10 370,36" fill="none" stroke="#585b70" stroke-width="1.2" marker-end="url(#ams7)"/> <text x="340" y="14" fill="#585b70" font-size="9">PrRd / —</text> <!-- Key -->

<text x="30" y="295" fill="#585b70" font-size="10">PrRd = processor read request BusRd = bus read broadcast</text> <text x="30" y="312" fill="#585b70" font-size="10">PrWr = processor write request BusRdX = bus read-exclusive (intent to write)</text> <text x="30" y="329" fill="#585b70" font-size="10">BusUpgr = upgrade (already have data, just need invalidation)</text>

<defs> <marker id="ams1" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#89b4fa"/></marker> <marker id="ams2" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#f38ba8"/></marker> <marker id="ams3" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#a6e3a1"/></marker> <marker id="ams4" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#fab387"/></marker> <marker id="ams5" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#a6e3a1"/></marker> <marker id="ams6" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#585b70"/></marker> <marker id="ams7" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#585b70"/></marker> </defs> </svg>

#### MSI Worked Example

Three cores — C0, C1, C2 — access block X. Initial state: all I.

|Event|C0|C1|C2|Bus Transaction|Notes|
|---|---|---|---|---|---|
|C0 reads X|**S**|I|I|BusRd → memory supplies X||
|C1 reads X|S|**S**|I|BusRd → memory supplies X|Both share clean copy|
|C0 writes X|**M**|**I**|I|BusRdX → C1 invalidates|C0 gets exclusive ownership|
|C2 reads X|**S**|I|**S**|BusRd → C0 writebacks, transitions to S|C0 forced to relinquish M|

#### MSI Weakness

Every write requires a BusRdX even when only one cache holds the block (I→M), because the protocol has no way to know the block is not shared. This causes unnecessary bus traffic. MESI solves this.

---

### MESI Protocol

MESI adds the **Exclusive** state: a clean, exclusive copy held by exactly one cache. This allows a cache to upgrade from E→M on a write with no bus transaction — the cache already knows it is the sole holder.

|State|Meaning|Can Read?|Can Write?|Memory Up to Date?|Sole Holder?|
|---|---|---|---|---|---|
|**M** odified|Exclusive dirty|Yes|Yes|No|Yes|
|**E** xclusive|Exclusive clean|Yes|Yes (silent, no bus)|Yes|Yes|
|**S** hared|Shared clean|Yes|No|Yes|No|
|**I** nvalid|Not present|No|No|Yes|—|

#### MESI State Diagram

<svg viewBox="0 0 680 380" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="380" fill="#1e1e2e"/> <!-- State circles --> <circle cx="120" cy="220" r="42" fill="#2a2a2a" stroke="#585b70" stroke-width="2"/> <text x="120" y="216" fill="#585b70" text-anchor="middle" font-size="15" font-weight="bold">I</text> <text x="120" y="230" fill="#585b70" text-anchor="middle" font-size="9">Invalid</text> <circle cx="340" cy="60" r="42" fill="#1e3a5f" stroke="#89b4fa" stroke-width="2"/> <text x="340" y="56" fill="#89b4fa" text-anchor="middle" font-size="15" font-weight="bold">S</text> <text x="340" y="70" fill="#89b4fa" text-anchor="middle" font-size="9">Shared</text> <circle cx="560" cy="220" r="42" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="2"/> <text x="560" y="216" fill="#a6e3a1" text-anchor="middle" font-size="15" font-weight="bold">M</text> <text x="560" y="230" fill="#a6e3a1" text-anchor="middle" font-size="9">Modified</text> <circle cx="340" cy="300" r="42" fill="#2a1a3a" stroke="#cba6f7" stroke-width="2"/> <text x="340" y="296" fill="#cba6f7" text-anchor="middle" font-size="15" font-weight="bold">E</text> <text x="340" y="310" fill="#cba6f7" text-anchor="middle" font-size="9">Exclusive</text> <!-- I → S: PrRd, others have copy --> <path d="M152,200 Q230,110 300,76" fill="none" stroke="#89b4fa" stroke-width="1.5" marker-end="url(#me1)"/> <text x="175" y="148" fill="#89b4fa" font-size="9">PrRd / BusRd</text> <text x="175" y="160" fill="#89b4fa" font-size="9">(shared line asserted)</text> <!-- I → E: PrRd, no other copy --> <path d="M155,240 Q230,280 300,295" fill="none" stroke="#cba6f7" stroke-width="1.5" marker-end="url(#me2)"/> <text x="165" y="284" fill="#cba6f7" font-size="9">PrRd / BusRd</text> <text x="165" y="296" fill="#cba6f7" font-size="9">(no sharers)</text> <!-- E → M: PrWr / silent (no bus) --> <path d="M370,276 Q490,260 520,240" fill="none" stroke="#a6e3a1" stroke-width="1.5" marker-end="url(#me3)"/> <text x="460" y="268" fill="#a6e3a1" font-size="9">PrWr / —</text> <text x="460" y="280" fill="#a6e3a1" font-size="9">(silent upgrade)</text> <!-- E → S: BusRd (snoop) --> <path d="M340,258 Q340,190 340,102" fill="none" stroke="#89b4fa" stroke-width="1.5" marker-end="url(#me4)"/> <text x="350" y="186" fill="#89b4fa" font-size="9">BusRd (snoop)</text> <!-- E → I: BusRdX (snoop) --> <path d="M302,272 Q200,260 155,238" fill="none" stroke="#f38ba8" stroke-width="1.5" marker-end="url(#me5)"/> <text x="205" y="256" fill="#f38ba8" font-size="9">BusRdX (snoop)</text> <!-- S → I: BusRdX --> <path d="M302,82 Q210,130 155,205" fill="none" stroke="#f38ba8" stroke-width="1.5" marker-end="url(#me6)"/> <text x="186" y="168" fill="#f38ba8" font-size="9">BusRdX (snoop)</text> <!-- S → M: PrWr / BusRdX (upgrade) --> <path d="M380,74 Q500,100 522,195" fill="none" stroke="#a6e3a1" stroke-width="1.5" marker-end="url(#me7)"/> <text x="490" y="120" fill="#a6e3a1" font-size="9">PrWr / BusUpgr</text> <!-- I → M: PrWr / BusRdX --> <path d="M158,232 Q340,310 520,232" fill="none" stroke="#a6e3a1" stroke-width="1.5" stroke-dasharray="4,2" marker-end="url(#me8)"/> <text x="340" y="352" fill="#a6e3a1" font-size="9">PrWr / BusRdX (I→M direct)</text> <!-- M → S: BusRd (writeback) --> <path d="M524,196 Q430,100 380,76" fill="none" stroke="#fab387" stroke-width="1.5" marker-end="url(#me9)"/> <text x="480" y="136" fill="#fab387" font-size="9">BusRd → writeback</text> <!-- M self --> <path d="M592,186 Q638,160 596,188" fill="none" stroke="#585b70" stroke-width="1.2" marker-end="url(#me10)"/> <text x="626" y="166" fill="#585b70" font-size="8">PrRd/PrWr</text> <defs> <marker id="me1" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#89b4fa"/></marker> <marker id="me2" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#cba6f7"/></marker> <marker id="me3" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#a6e3a1"/></marker> <marker id="me4" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#89b4fa"/></marker> <marker id="me5" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#f38ba8"/></marker> <marker id="me6" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#f38ba8"/></marker> <marker id="me7" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#a6e3a1"/></marker> <marker id="me8" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#a6e3a1"/></marker> <marker id="me9" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#fab387"/></marker> <marker id="me10" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#585b70"/></marker> </defs> </svg>

#### The Shared Line

The transition from I to E versus I to S depends on whether any other cache currently holds the block. Hardware implements this with a **shared (S) line** — an open-collector wire on the bus that any snooping cache asserts during a BusRd if it holds the block. The requester observes whether the line is asserted:

- S line asserted → other sharers exist → go to **S**
- S line not asserted → no other holders → go to **E**

#### MESI Worked Example

|Event|C0|C1|C2|Bus|Notes|
|---|---|---|---|---|---|
|C0 reads X|**E**|I|I|BusRd, S line not asserted|Sole reader → Exclusive|
|C0 writes X|**M**|I|I|— (no bus)|Silent E→M upgrade|
|C1 reads X|**S**|**S**|I|BusRd → C0 writebacks|M→S; data from C0 not memory|
|C1 writes X|I|**M**|I|BusUpgr → C0 invalidates|Upgrade, no data transfer needed|

The E state eliminates the BusRdX that MSI would have required at "C0 writes X" — a significant saving in write-heavy single-owner workloads.

---

### MOESI Protocol

MOESI adds the **Owned** state. In MESI, when a Modified cache must share its block (due to a BusRd snoop), it must write back to memory first, then transition to Shared — this writeback costs time and memory bandwidth. The Owned state allows the cache to supply the data directly to the requester and retain responsibility for the block without writing back to memory.

|State|Meaning|Can Read?|Can Write?|Memory Up to Date?|Sole Holder?|
|---|---|---|---|---|---|
|**M** odified|Exclusive dirty|Yes|Yes|No|Yes|
|**O** wned|Dirty, shared — supplier|Yes|No|No|No (sharers exist)|
|**E** xclusive|Exclusive clean|Yes|Yes (silent)|Yes|Yes|
|**S** hared|Clean shared|Yes|No|Yes|No|
|**I** nvalid|Not present|No|No|Yes|—|

The critical property of **O**: memory is stale, but the Owned cache takes responsibility for supplying data to other caches on demand and for writing back when the block is evicted.

#### The M → O Transition

This is the transition MOESI adds that MESI lacks. When a core in M receives a BusRd snoop:

- **MESI**: M → writeback to memory → S (memory traffic required)
- **MOESI**: M → O (no writeback; data supplied directly cache-to-cache; requester goes to S)

<svg viewBox="0 0 680 160" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="160" fill="#1e1e2e"/> <!-- MESI path -->

<text x="10" y="22" fill="#89b4fa" font-size="12">MESI:</text>

<rect x="10" y="32" width="80" height="30" rx="3" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="1.5"/> <text x="50" y="52" fill="#a6e3a1" text-anchor="middle">M (C0)</text> <line x1="90" y1="47" x2="140" y2="47" stroke="#f38ba8" stroke-width="1.5" marker-end="url(#mo1)"/> <text x="115" y="42" fill="#f38ba8" font-size="9">BusRd</text> <rect x="140" y="32" width="110" height="30" rx="3" fill="#1a2a3a" stroke="#cba6f7" stroke-width="1.5"/> <text x="195" y="52" fill="#cba6f7" text-anchor="middle">Writeback→Mem</text> <line x1="250" y1="47" x2="300" y2="47" stroke="#585b70" stroke-width="1.5" marker-end="url(#mo2)"/> <rect x="300" y="32" width="80" height="30" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.5"/> <text x="340" y="52" fill="#89b4fa" text-anchor="middle">S (C0)</text> <line x1="380" y1="47" x2="430" y2="47" stroke="#585b70" stroke-width="1.5" marker-end="url(#mo3)"/> <text x="405" y="42" fill="#585b70" font-size="9">supply</text> <rect x="430" y="32" width="80" height="30" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.5"/> <text x="470" y="52" fill="#89b4fa" text-anchor="middle">S (C1)</text>

<text x="540" y="52" fill="#f38ba8" font-size="10">← memory write required</text>

<!-- MOESI path -->

<text x="10" y="95" fill="#a6e3a1" font-size="12">MOESI:</text>

<rect x="10" y="105" width="80" height="30" rx="3" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="1.5"/> <text x="50" y="125" fill="#a6e3a1" text-anchor="middle">M (C0)</text> <line x1="90" y1="120" x2="140" y2="120" stroke="#f38ba8" stroke-width="1.5" marker-end="url(#mo4)"/> <text x="115" y="115" fill="#f38ba8" font-size="9">BusRd</text> <rect x="140" y="105" width="80" height="30" rx="3" fill="#3a2a1a" stroke="#fab387" stroke-width="1.5"/> <text x="180" y="125" fill="#fab387" text-anchor="middle">O (C0)</text> <line x1="220" y1="120" x2="270" y2="120" stroke="#585b70" stroke-width="1.5" marker-end="url(#mo5)"/> <text x="245" y="115" fill="#585b70" font-size="9">supply</text> <rect x="270" y="105" width="80" height="30" rx="3" fill="#1e3a5f" stroke="#89b4fa" stroke-width="1.5"/> <text x="310" y="125" fill="#89b4fa" text-anchor="middle">S (C1)</text>

<text x="380" y="125" fill="#a6e3a1" font-size="10">← no memory write; C0 remains responsible</text>

<defs> <marker id="mo1" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#f38ba8"/></marker> <marker id="mo2" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#585b70"/></marker> <marker id="mo3" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#585b70"/></marker> <marker id="mo4" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#f38ba8"/></marker> <marker id="mo5" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6 Z" fill="#585b70"/></marker> </defs> </svg>

#### MOESI State Transitions (Key Additions)

|Transition|Trigger|Action|
|---|---|---|
|M → O|Snoop BusRd from another core|Supply data to requester; retain dirty responsibility; no writeback|
|O → M|All sharers invalidate; this cache writes|Reclaim exclusive dirty ownership|
|O → I|Eviction|Must writeback to memory before eviction|
|O → S|Another BusRdX observed|Downgrade; but requester takes M state|
|S → O|Not directly reachable — O is entered from M only||

#### MOESI Worked Example

|Event|C0|C1|C2|Bus|Notes|
|---|---|---|---|---|---|
|C0 reads X|E|I|I|BusRd|Sole reader|
|C0 writes X|M|I|I|—|Silent E→M|
|C1 reads X|**O**|**S**|I|BusRd → C0 supplies|No writeback to memory|
|C2 reads X|O|S|**S**|BusRd → C0 supplies|C0 still Owned|
|C1 writes X|**I**|**M**|**I**|BusRdX → C0 writebacks O; C2 invalidates|O→I requires writeback|

---

### Protocol Comparison

|Property|MSI|MESI|MOESI|
|---|---|---|---|
|States|3|4|5|
|Silent write upgrade|No|Yes (E→M)|Yes (E→M)|
|Cache-to-cache transfer on read|No|No|Yes (O state)|
|Memory writeback on M-shared transition|Yes|Yes|No|
|Complexity|Low|Medium|High|
|Memory bandwidth usage|High|Medium|Low|
|Used in|Academic baseline|Intel (P6 onward)|AMD (Opteron+), ARM|

---

### False Sharing

A correctness-transparent but performance-critical pathology in all protocols. Two cores write to different variables that happen to reside in the same cache line. The coherence protocol treats the entire line as the unit of transfer — so each write invalidates the other core's copy of the entire line, causing repeated M→I transitions even though the cores are accessing logically independent data.

```
// Core 0 writes x; Core 1 writes y
// If x and y share a 64-byte cache line:
struct { int x; int y; } data;   // false sharing likely
struct { int x; char pad[60]; int y; } data;  // padding separates lines
```

False sharing does not violate coherence — values are always correct — but generates the same bus traffic pattern as true sharing, severely degrading throughput. [Inference] The performance impact varies by access pattern and hardware; behavior is not guaranteed to match any specific processor.

---

### Coherence Granularity

All protocols operate at **cache line granularity** (typically 64 bytes), not word granularity. This is a deliberate design choice: tracking per-word state would require enormous tag storage and complex state machines. The tradeoff is false sharing susceptibility.

---

### Directory-Based Extension

For NUMA systems with many cores where snooping does not scale, the same MSI/MESI/MOESI state machines are retained per cache line, but transitions are mediated by a directory:

```
Core requests block → message to directory
Directory looks up sharers → sends targeted invalidations / fetch
Directory updates sharer list → sends acknowledgment
Core receives data + ack → transitions state
```

The directory stores, per block: the coherence state and a sharer bitmap (or pointer list for sparse sharing). This replaces broadcast with point-to-point messages at the cost of added latency per coherence transaction.

---

**Conclusion:** MSI establishes the invalidation-based coherence foundation. MESI adds the Exclusive state to eliminate unnecessary bus transactions on private writes. MOESI further adds the Owned state to eliminate memory writebacks on dirty-to-shared transitions, replacing them with direct cache-to-cache transfers. Each protocol extension trades increased state machine complexity for reduced bus and memory bandwidth consumption — the dominant concern as core counts and memory latency grow.

**Next Steps:** Proceed to Memory Consistency Models to understand the ordering guarantees that coherence alone does not provide, or to NUMA Architecture to see how directory-based coherence extends these protocols to multi-socket systems.

---

