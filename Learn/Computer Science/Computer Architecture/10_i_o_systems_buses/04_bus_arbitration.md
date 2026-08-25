## Bus Arbitration


Bus arbitration is the mechanism by which a shared bus determines which of several competing requesters — called **bus masters** — is granted control of the bus at any given time. Since only one master may drive the bus simultaneously, arbitration is a prerequisite for correct operation in any multi-master system.

---

### The Arbitration Problem

A shared bus connects multiple devices: CPUs, DMA controllers, I/O processors, and memory controllers. Any of these may need to initiate a transfer. Without coordination, simultaneous attempts to drive the bus result in signal contention and data corruption.

Arbitration must satisfy:

- **Mutual exclusion** — only one master holds the bus at a time
- **Fairness** — no master is indefinitely denied access (freedom from starvation)
- **Low latency** — arbitration overhead must not dominate transfer time
- **Priority enforcement** — higher-priority masters may be served preferentially

---

### Centralized vs. Distributed Arbitration

#### Centralized Arbitration

A single dedicated component — the **bus arbiter** — receives all requests and issues grants. All logic is localized, simplifying design.

#### Distributed Arbitration

Masters collectively determine bus ownership without a central authority. Each master observes the bus and applies a local algorithm. More fault-tolerant but more complex to implement.

---

### Centralized Arbitration Schemes

#### Daisy-Chain (Serial) Arbitration

A single **Bus Request (BR)** line is shared. A single **Bus Grant (BG)** line propagates serially from the highest-priority device down the chain.

**Operation:**

1. Any device asserting BR pulls the shared line low.
2. The arbiter asserts BG.
3. BG propagates through the chain; the first device that requested the bus captures it and does not pass BG further.
4. The device asserts **Bus Busy (BB)** while it holds the bus.

<svg viewBox="0 0 640 180" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <!-- Arbiter --> <rect x="20" y="60" width="80" height="60" rx="6" fill="#1e293b" stroke="#94a3b8" stroke-width="1.5"/> <text x="60" y="94" text-anchor="middle" fill="#e2e8f0">Arbiter</text> <!-- Devices --> <rect x="160" y="60" width="70" height="60" rx="6" fill="#1e3a5f" stroke="#60a5fa" stroke-width="1.5"/> <text x="195" y="88" text-anchor="middle" fill="#bfdbfe">Dev 0</text> <text x="195" y="106" text-anchor="middle" fill="#93c5fd" font-size="11">(highest)</text> <rect x="290" y="60" width="70" height="60" rx="6" fill="#1e3a5f" stroke="#60a5fa" stroke-width="1.5"/> <text x="325" y="88" text-anchor="middle" fill="#bfdbfe">Dev 1</text> <rect x="420" y="60" width="70" height="60" rx="6" fill="#1e3a5f" stroke="#60a5fa" stroke-width="1.5"/> <text x="455" y="88" text-anchor="middle" fill="#bfdbfe">Dev 2</text> <text x="455" y="106" text-anchor="middle" fill="#93c5fd" font-size="11">(lowest)</text> <!-- BR line (shared, bottom) --> <line x1="100" y1="150" x2="570" y2="150" stroke="#f97316" stroke-width="2"/> <text x="580" y="154" fill="#f97316" font-size="11">BR</text> <line x1="195" y1="120" x2="195" y2="150" stroke="#f97316" stroke-width="1.5" stroke-dasharray="4,2"/> <line x1="325" y1="120" x2="325" y2="150" stroke="#f97316" stroke-width="1.5" stroke-dasharray="4,2"/> <line x1="455" y1="120" x2="455" y2="150" stroke="#f97316" stroke-width="1.5" stroke-dasharray="4,2"/> <line x1="100" y1="150" x2="100" y2="130" stroke="#f97316" stroke-width="1.5"/> <!-- BG chain (top) --> <line x1="100" y1="50" x2="160" y2="50" stroke="#4ade80" stroke-width="2"/> <polygon points="155,45 165,50 155,55" fill="#4ade80"/> <line x1="230" y1="50" x2="290" y2="50" stroke="#4ade80" stroke-width="2"/> <polygon points="285,45 295,50 285,55" fill="#4ade80"/> <line x1="360" y1="50" x2="420" y2="50" stroke="#4ade80" stroke-width="2"/> <polygon points="415,45 425,50 415,55" fill="#4ade80"/> <text x="490" y="54" fill="#4ade80" font-size="11">BG chain</text> <!-- Connect BG from arbiter --> <line x1="100" y1="70" x2="100" y2="50" stroke="#4ade80" stroke-width="1.5"/> </svg>

**Key Points:**

- Priority is entirely positional — devices nearer the arbiter have higher priority.
- Simple and cheap; requires only three wires (BR, BG, BB).
- A failed high-priority device can block the entire chain.
- High-priority devices can starve low-priority ones under heavy load.

---

#### Parallel (Independent-Request) Arbitration

Each device has its own dedicated request line **BR_i** to the arbiter, and the arbiter has a dedicated grant line **BG_i** to each device.

**Operation:**

1. Devices assert their individual BR_i lines simultaneously.
2. The arbiter evaluates all pending requests against a fixed or programmable priority table.
3. The arbiter asserts exactly one BG_i.

<svg viewBox="0 0 500 220" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13"> <!-- Arbiter --> <rect x="190" y="80" width="90" height="70" rx="6" fill="#1e293b" stroke="#94a3b8" stroke-width="1.5"/> <text x="235" y="119" text-anchor="middle" fill="#e2e8f0">Arbiter</text> <!-- Device 0 --> <rect x="30" y="30" width="80" height="45" rx="4" fill="#1e3a5f" stroke="#60a5fa" stroke-width="1.5"/> <text x="70" y="57" text-anchor="middle" fill="#bfdbfe">Dev 0</text> <!-- BR0 --> <line x1="110" y1="48" x2="190" y2="100" stroke="#f97316" stroke-width="1.5"/> <text x="140" y="62" fill="#f97316" font-size="11">BR₀</text> <!-- BG0 --> <line x1="190" y1="92" x2="110" y2="40" stroke="#4ade80" stroke-width="1.5" stroke-dasharray="5,3"/> <text x="130" y="80" fill="#4ade80" font-size="11">BG₀</text> <!-- Device 1 --> <rect x="30" y="145" width="80" height="45" rx="4" fill="#1e3a5f" stroke="#60a5fa" stroke-width="1.5"/> <text x="70" y="172" text-anchor="middle" fill="#bfdbfe">Dev 1</text> <!-- BR1 --> <line x1="110" y1="160" x2="190" y2="120" stroke="#f97316" stroke-width="1.5"/> <text x="135" y="155" fill="#f97316" font-size="11">BR₁</text> <!-- BG1 --> <line x1="190" y1="128" x2="110" y2="168" stroke="#4ade80" stroke-width="1.5" stroke-dasharray="5,3"/> <text x="130" y="150" fill="#4ade80" font-size="11">BG₁</text> <!-- Device 2 --> <rect x="370" y="30" width="80" height="45" rx="4" fill="#1e3a5f" stroke="#60a5fa" stroke-width="1.5"/> <text x="410" y="57" text-anchor="middle" fill="#bfdbfe">Dev 2</text> <line x1="370" y1="48" x2="280" y2="100" stroke="#f97316" stroke-width="1.5"/> <text x="320" y="62" fill="#f97316" font-size="11">BR₂</text> <line x1="280" y1="92" x2="370" y2="40" stroke="#4ade80" stroke-width="1.5" stroke-dasharray="5,3"/> <text x="300" y="80" fill="#4ade80" font-size="11">BG₂</text> <!-- Device 3 --> <rect x="370" y="145" width="80" height="45" rx="4" fill="#1e3a5f" stroke="#60a5fa" stroke-width="1.5"/> <text x="410" y="172" text-anchor="middle" fill="#bfdbfe">Dev 3</text> <line x1="370" y1="160" x2="280" y2="120" stroke="#f97316" stroke-width="1.5"/> <text x="315" y="155" fill="#f97316" font-size="11">BR₃</text> <line x1="280" y1="128" x2="370" y2="168" stroke="#4ade80" stroke-width="1.5" stroke-dasharray="5,3"/> <text x="295" y="150" fill="#4ade80" font-size="11">BG₃</text> <!-- Legend --> <line x1="30" y1="210" x2="60" y2="210" stroke="#f97316" stroke-width="1.5"/> <text x="65" y="214" fill="#f97316" font-size="11">Request</text> <line x1="150" y1="210" x2="180" y2="210" stroke="#4ade80" stroke-width="1.5" stroke-dasharray="5,3"/> <text x="185" y="214" fill="#4ade80" font-size="11">Grant</text> </svg>

**Key Points:**

- Fast arbitration; the arbiter resolves all requests in one cycle.
- Requires 2N signal lines for N devices — does not scale well.
- Priority can be static (fixed) or dynamic (round-robin, least-recently-used).

---

#### Polling (Software or Counter-Based Arbitration)

The arbiter cycles through addresses on a **bus address line**, asking each device whether it wants the bus.

- **Fixed polling**: addresses always cycle in the same order — equivalent to fixed priority.
- **Rolling polling**: cycle starts after the last granted address — approximates fairness.

**Key Points:**

- Low pin count.
- Latency grows with the number of devices; unsuitable for time-critical systems.
- Rarely used in modern hardware but appears in legacy and embedded contexts.

---

### Distributed Arbitration Schemes

#### Self-Selection (e.g., NuBus)

Each master broadcasts its own ID on the arbitration lines. After all masters have driven the bus simultaneously, each master reads back the combined signal (via wired-OR or wired-AND logic) and compares it to its own ID. The master whose ID survives the combination wins.

**Key Points:**

- No central point of failure.
- Arbitration time is fixed and independent of the number of masters.
- Requires as many arbitration lines as there are ID bits.

#### Collision Detection (e.g., CAN Bus)

Masters begin transmitting; if a collision is detected, lower-priority masters back off. CAN uses **bitwise arbitration**: each master monitors the bus while transmitting. A recessive bit (logic 1) driven while a dominant bit (logic 0) is detected causes the master to immediately relinquish.

**Key Points:**

- Non-destructive; the highest-priority message always completes.
- Used heavily in automotive and industrial control systems.

---

### Priority Schemes

|Scheme|Starvation Risk|Fairness|Complexity|
|---|---|---|---|
|Fixed priority|Yes (low-priority)|Low|Low|
|Round-robin|No|High|Medium|
|Least Recently Used (LRU)|No|High|Medium–High|
|Weighted round-robin|Bounded|Tunable|Medium|
|First-come, first-served|No|High|Medium|

**Round-robin** cycling is the most common dynamic scheme. After each grant, the priority pointer advances to the next device, wrapping around. This distributes bus bandwidth equitably under symmetric load.

---

### Arbitration Timing

Arbitration may occur **synchronously** (locked to the bus clock) or **asynchronously** (signal-driven, independent of clock). Synchronous arbitration is simpler to implement and analyze; asynchronous arbitration can respond faster but requires careful design to avoid metastability.

A typical synchronous arbitration cycle:

```
Cycle N:     Master asserts BR
Cycle N+1:   Arbiter evaluates requests
Cycle N+2:   Arbiter asserts BG
Cycle N+3:   Master captures bus, asserts BB, begins transfer
```

The arbitration latency (cycles N through N+2) is **bus overhead** — it reduces effective bandwidth.

---

### Split-Transaction Buses

Traditional buses hold the bus for the duration of a transaction, including memory latency. **Split-transaction** buses separate the request phase from the response phase:

1. Master requests the bus, sends address and command, then releases the bus.
2. The bus is free while memory or the target prepares data.
3. The target later requests the bus to deliver the response.

Arbitration must occur twice per transaction. This increases arbitration complexity but dramatically improves bus utilization under memory-latency-bound workloads, as in systems with DRAM.

---

### Modern Context

Dedicated point-to-point interconnects (PCIe, HyperTransport, QPI/UPI) have replaced shared buses in high-performance systems, eliminating the arbitration bottleneck entirely by giving each device a private link. Arbitration remains relevant in:

- **On-chip buses** — AMBA AXI, AHB, and APB arbiters in SoCs
- **Embedded and automotive buses** — CAN, I²C, SPI
- **Memory buses** — the memory controller arbitrates between multiple CPU cores and DMA engines competing for DRAM channels
- **Legacy systems** — PCI, ISA

On AMBA AXI fabrics, the interconnect contains a built-in arbiter that independently arbitrates read-address, write-address, write-data, read-data, and write-response channels, each with configurable priority.

---

**Conclusion**

Bus arbitration resolves contention on shared interconnects through a well-defined protocol governing who may transmit and when. The design space spans centralized versus distributed control, static versus dynamic priority, and synchronous versus asynchronous timing. Each trade-off — between pin count, latency, fairness, and fault tolerance — determines the scheme's suitability for a given system class. As shared buses gave way to switched fabrics in high-performance computing, arbitration logic migrated inward to memory controllers and on-chip network switches, where the same fundamental principles continue to apply.

**Next Steps**

- Study **AMBA AXI arbitration** as a concrete modern implementation
- Examine **memory controller arbitration** in the context of DRAM scheduling policies (Module 8)
- Connect bus arbitration latency to **bus performance models** (Module 14)
- Review **PCIe transaction ordering rules** as an example of arbitration in a switched fabric (Module 10)

---

