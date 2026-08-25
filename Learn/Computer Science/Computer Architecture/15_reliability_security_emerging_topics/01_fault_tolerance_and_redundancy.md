## Fault Tolerance and Redundancy


Fault tolerance is the property of a system that allows it to continue operating correctly in the presence of hardware or software faults. Redundancy — the provision of duplicate components beyond the minimum required for function — is the primary mechanism by which fault tolerance is achieved. The two concepts are inseparable: redundancy without fault detection is waste; fault detection without redundancy is merely alarming.

---

### Fault Taxonomy

Before examining mechanisms, it is useful to distinguish the types of faults a system must handle.

**Transient faults** occur once and do not recur. Cosmic ray–induced soft errors in SRAM (single-event upsets), power glitches, and thermal noise spikes are transient. They are the most common fault class and the primary target of error-correcting codes and retry logic.

**Intermittent faults** recur sporadically, often under specific conditions (temperature, voltage, load). Loose connectors, marginal timing, and aging semiconductor junctions produce intermittent faults. They are the most difficult to diagnose because they are absent when observed.

**Permanent faults** persist until the component is replaced. Broken wires, burned transistors, and catastrophic chip failures are permanent. Permanent faults require isolation and replacement or reconfiguration.

Fault models are also classified by behavior: a _fail-stop_ component halts and signals failure cleanly; a _fail-silent_ component stops producing output without signaling; a _Byzantine_ (arbitrary) fault produces incorrect, inconsistent, or malicious output. Most hardware mechanisms assume fail-stop or fail-silent behavior. Byzantine fault tolerance requires substantially more redundancy (at minimum 3f+1 components to tolerate f Byzantine faults).

---

### Reliability Metrics

**MTTF (Mean Time To Failure):** The expected time until a component fails for the first time. Used for non-repairable or single-use components.

**MTTR (Mean Time To Repair):** The expected time from failure detection to restoration of service.

**MTBF (Mean Time Between Failures):** MTTF + MTTR. Used for repairable components.

**Availability:** The fraction of time a system is operational.

$$A = \frac{\text{MTTF}}{\text{MTTF} + \text{MTTR}}$$

A system with MTTF = 10,000 hours and MTTR = 1 hour has availability 10,000/10,001 ≈ 99.99% ("four nines"). Reducing MTTR — by automating failover — is often more effective than increasing MTTF.

**Failure rate λ:** For components following an exponential failure distribution, λ = 1/MTTF. Redundant configurations modify the effective failure rate of the system.

For N independent components each with failure rate λ, connected in series (all must work), the system failure rate is Nλ. Connected in parallel (any one suffices), the system MTTF extends dramatically — for two parallel components, system MTTF = 3/(2λ).

---

### Redundancy Strategies

#### Hardware Redundancy

**Triple Modular Redundancy (TMR)** replicates a component three times and uses a majority voter on the outputs. If one of the three copies produces an incorrect result, the voter selects the majority value — the correct output — and the system proceeds without interruption. A single fault is masked entirely. TMR requires no detection logic: disagreement is resolved by voting.

The cost is twofold: three times the hardware, and a voter whose own reliability must be analyzed. In practice, voters are simple combinational circuits with very high MTTF. TMR is used in spacecraft, flight control computers, and safety-critical industrial controllers where any single fault must not produce incorrect output.**Dual Modular Redundancy (DMR)** runs two copies and compares outputs. Agreement means correctness (assuming independent faults); disagreement triggers an error signal. DMR detects faults but cannot correct them — the system must halt, roll back, or invoke a spare. It is cheaper than TMR but requires a separate recovery mechanism.

**Standby redundancy** maintains a spare component that is activated only upon primary failure. In _hot standby_, the spare runs synchronously with the primary (powered and executing); failover is near-instantaneous. In _warm standby_, the spare is powered but not synchronously executing; failover requires seconds of re-synchronization. In _cold standby_, the spare is powered off; failover requires minutes of boot and synchronization. The cost-availability trade-off follows this ordering: hot standby maximizes availability at maximum cost; cold standby minimizes cost at maximum failover latency.

#### Information Redundancy

Information redundancy appends extra bits to data to detect or correct bit errors, without replicating the entire component.

**Parity:** A single parity bit appended to a word. Even parity: the parity bit is chosen so the total number of 1-bits is even. Detects any single-bit error (the parity of the word changes). Cannot correct errors, and cannot detect an even number of simultaneous bit flips. Used in simple DRAM modules and legacy serial links.

**Hamming codes:** Richard Hamming's (1950) construction places parity bits at power-of-two positions within the codeword. Each parity bit covers a specific subset of data bits. On a read, all parity checks are re-evaluated; the pattern of passing and failing checks (the _syndrome_) directly identifies the position of a single-bit error, which the hardware corrects by flipping that bit. SECDED (Single Error Correction, Double Error Detection) Hamming codes add one additional parity bit over the entire codeword, enabling detection of two-bit errors that would otherwise be miscorrected.

For a data word of k bits, the number of parity bits r required satisfies 2^r ≥ k + r + 1. For a 64-bit data word, r = 7 suffices (2^7 = 128 ≥ 72). ECC DRAM implements SECDED with 8 check bits over 64 data bits, using a (72,64) Hamming code.

**CRC (Cyclic Redundancy Check):** A polynomial remainder computed over a data block, appended as a checksum. CRC-32 detects all single-bit errors, all burst errors of length ≤ 32 bits, and most longer burst errors. Used in Ethernet frames, PCIe transaction layer packets, storage sector checksums. CRC does not correct; on detection, the block is retransmitted or discarded.

**Reed-Solomon codes:** A class of block error-correcting codes operating on symbols (typically bytes) rather than bits. An RS(n, k) code takes k data symbols and produces n − k check symbols; it can correct up to ⌊(n − k)/2⌋ symbol errors regardless of bit pattern within the symbol. Used in SSDs (flash storage is susceptible to multi-bit errors), optical discs, and deep-space communication. NAND flash controllers typically apply multi-bit BCH or LDPC codes internally, which are [Inference] more efficient for the specific error patterns flash exhibits (programmatic disturb, retention loss), though specific design choices vary by manufacturer.

The diagram below shows the SECDED Hamming syndrome at work.#### Temporal Redundancy

Temporal redundancy re-executes an operation and compares results. If a fault is transient, the second execution will succeed. If results disagree, a third execution can break the tie (or the operation is retried until agreement). Temporal redundancy costs time, not space, and is effective for transient faults but not permanent ones. It is used in retry logic for memory accesses, PCIe link training, and network retransmission.

#### Software Redundancy

Assertions, watchdog timers, and N-version programming are software-level redundancy mechanisms. N-version programming independently develops N implementations of the same specification; their outputs are voted on at runtime. The assumption is that independently written software has independent bugs — an assumption that is difficult to verify and does not hold when developers share common misconceptions about the specification. [Inference] N-version programming is used in some safety-critical avionics systems, though its effectiveness relative to cost remains a subject of engineering debate.

---

### RAID: Redundancy in Storage

RAID (Redundant Array of Independent Disks) applies redundancy principles to block storage. The key levels:

**RAID 0 (striping):** Data is striped across N disks in blocks. Reads and writes parallelize across all N disks, giving near-N× throughput. No redundancy: failure of any single disk loses all data. MTTF of the array = MTTF_disk / N — worse than a single disk.

**RAID 1 (mirroring):** Each disk has an identical mirror. Reads can be served from either copy (throughput improvement possible); writes must go to both. Survives failure of any one disk from each mirrored pair. Storage efficiency is 50%.

**RAID 5 (distributed parity):** Data and parity are striped across N disks. For each stripe, one disk holds the XOR parity of the other N−1 data blocks. No single disk is designated the parity disk — parity is distributed, eliminating the write bottleneck of dedicated parity disks. Survives any single disk failure; the missing data is reconstructed by XORing the surviving blocks. Write penalty: each write requires reading the old data and old parity, computing the new parity, and writing both new data and new parity (read-modify-write). Minimum 3 disks. Vulnerable during rebuild: a second disk failure during the potentially long rebuild window (hours for large disks) causes data loss.

**RAID 6 (dual distributed parity):** Extends RAID 5 with two independent parity blocks per stripe (using Reed-Solomon or similar), surviving any two simultaneous disk failures. Requires minimum 4 disks. Higher write penalty than RAID 5.

**RAID 10 (1+0):** Mirrors first, then stripes the mirrors. Combines RAID 1 redundancy with RAID 0 throughput. Survives multiple failures as long as both members of any mirrored pair do not fail simultaneously. 50% storage efficiency. Preferred for databases where write performance and rebuild speed matter.

```
RAID 0:  [A1][A2][A3][A4]       — striped, no parity
         D0   D1   D2   D3

RAID 1:  [A ][A ]               — mirrored
         D0  D1(mirror)

RAID 5:  [A1][A2][A3][Pp]       — stripe with distributed parity
         [B1][B2][Pb][B3]       Pp = A1 XOR A2 XOR A3
         [C1][Pc][C2][C3]
         D0   D1   D2   D3

RAID 6:  [A1][A2][Pp][Qq]       — two independent parities per stripe
         D0   D1   D2   D3
```

---

### Checkpoint and Rollback

Hardware redundancy prevents errors from producing wrong outputs. Checkpoint-based recovery tolerates faults that do cause transient incorrect state by periodically saving a consistent system snapshot and rolling back to it on fault detection.

A **checkpoint** captures the complete state needed to resume execution: CPU registers, memory contents, I/O state, and network connection state. On fault detection (watchdog timeout, assertion failure, uncorrectable memory error), the system restores the last checkpoint and replays or re-executes from that point.

**Coordinated checkpointing** in distributed systems requires all processes to synchronize before writing their checkpoints, so the collective snapshot is globally consistent (no message that was sent in the snapshot but not yet received). The _Chandy-Lamport_ algorithm captures a consistent global snapshot without halting the system, using marker messages to separate pre-snapshot from post-snapshot messages.

**Logging** (write-ahead log) is the database analog: before any page is modified in place, the modification is written to a log on stable storage. On crash, the log is replayed to restore consistency. The combination of checkpointing and logging — _log-structured recovery_ — bounds recovery time to the checkpoint interval plus log replay time.

---

### System-Level Fault Tolerance: ECC Memory, Watchdogs, and RAID Controller BBU

**ECC DRAM** implements SECDED in hardware on every 64-byte cache line access. The memory controller reads 72 bits (64 data + 8 check bits), computes the syndrome, corrects single-bit errors transparently, and raises a machine check exception (MCE) for uncorrectable double-bit errors. The OS MCE handler logs the physical address; persistent single-bit corrections on the same address indicate a failing DIMM and trigger preemptive replacement.

**Scrubbing** is a background process that reads all memory periodically (typically every few hours) to detect and correct accumulated single-bit errors before a second error occurs in the same word (which would be uncorrectable). Without scrubbing, a DIMM with elevated error rate may accumulate two errors in the same word between accesses, producing a silent data corruption.

**Watchdog timers** require periodic software heartbeats. A hardware counter decrements continuously; the OS or application must reset it before it reaches zero. If the software fails (deadlock, infinite loop, panic), the counter expires and the watchdog asserts a hardware reset. Used pervasively in embedded systems, RAID controllers, and network equipment.

**RAID controller battery-backed unit (BBU):** RAID controllers cache writes in volatile DRAM to absorb burst writes and coalesce small writes into full-stripe writes. If power is lost while the cache holds unwritten data, the data is lost — unless the cache is battery- or capacitor-backed. The BBU preserves the write cache through a power outage long enough for a controlled shutdown or for power restoration. Without a BBU, write-back caching is unsafe and the controller must use write-through (lower performance).

---

### Hot-Plug and Non-Disruptive Replacement

Fault tolerance requires not just surviving a failure but recovering without taking the system offline. **Hot-plug** allows a failed component to be removed and replaced while the system continues operating:

- **Hot-plug DIMM** replacement requires the OS to offline the memory range, migrate pages away, and notify the memory controller before physical removal.
- **Hot-plug PCI Express** devices can be removed and re-inserted with no power cycle; the OS re-enumerates the device on re-insertion.
- **Hot-plug disk** (in RAID) triggers immediate rebuild to the spare drive once the replacement disk is inserted.
- **Hot-plug power supply** in redundant PSU configurations allows replacement of a failed supply under full load without interrupting power to the system.

---

**Key Points**

- Faults are transient, intermittent, or permanent; effective fault tolerance must address all three classes, though mechanisms differ — temporal redundancy addresses transient faults, hardware redundancy addresses permanent ones.
- TMR masks a single fault silently via majority voting; DMR detects faults but requires a separate recovery mechanism; standby redundancy recovers via failover with latency dependent on whether the spare is hot, warm, or cold.
- SECDED Hamming codes correct single-bit errors and detect double-bit errors using a syndrome whose binary value directly encodes the error position; ECC DRAM applies this on every memory access.
- RAID 5 provides N−1 disk capacity from N disks and survives any single disk failure using distributed XOR parity; RAID 6 extends this to two simultaneous failures using two independent parity symbols per stripe.
- Availability is dominated by MTTR in high-MTTF systems; automated failover, hot-plug replacement, and fast rebuild reduce MTTR and are often more cost-effective than increasing component MTTF.
- Checkpoint-rollback tolerates faults that produce transient incorrect state; the Chandy-Lamport algorithm extends this to distributed systems without global synchronization.
- Memory scrubbing prevents the accumulation of uncorrected single-bit errors that could later combine into an uncorrectable double-bit error, which would otherwise cause silent data corruption.

**Conclusion**

Fault tolerance is an engineering discipline of anticipating failure modes and pre-positioning mechanisms — redundant hardware, redundant information, temporal re-execution, and consistent recovery state — to contain their consequences. The core trade-off at every level is cost (hardware, bandwidth, latency, complexity) against the probability and consequence of failure. Systems with the highest reliability requirements — spacecraft, flight controllers, financial transaction processors — combine multiple layers: ECC at the bit level, RAID at the storage level, TMR or hot-standby at the component level, and checkpoint-rollback at the system level.

**Next Steps**

From the syllabus: **Hardware security (Spectre/Meltdown class, side-channel attacks)** represents a different failure mode — not physical faults but information leakage through shared hardware state — where fault-tolerance intuitions do not apply and novel mitigation mechanisms are required. **ECC memory** connects directly to Module 8 (Main Memory Systems) and the DRAM internals that make SECDED necessary.

---

