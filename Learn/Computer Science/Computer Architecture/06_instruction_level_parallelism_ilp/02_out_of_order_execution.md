## Out-of-Order Execution


Out-of-order execution (OOO) is a microarchitectural technique that allows a processor to execute instructions in an order determined by data availability rather than program order, while presenting the illusion to software that instructions completed in program order. It is the primary mechanism by which modern superscalar processors extract instruction-level parallelism (ILP) from sequential instruction streams.

---

### The Problem OOO Solves

A strictly in-order pipeline stalls the entire fetch-decode-execute pipeline whenever an instruction cannot proceed — most commonly due to a data dependency on a result not yet produced, a cache miss, or a structural hazard. Every stall cycle wastes issue slots across all subsequent instructions, regardless of whether those instructions have any dependency on the stalling instruction.

**Example — in-order stall cascade:**

```
LOAD  R1, [R2]        ; cache miss — 200-cycle stall
ADD   R3, R1, R4      ; depends on R1 — must wait
MUL   R5, R6, R7      ; no dependency on R1 — stalls anyway in-order
XOR   R8, R9, R10     ; no dependency on R1 — stalls anyway in-order
```

An out-of-order processor identifies that `MUL` and `XOR` have no dependency on `R1` and executes them during the cache miss latency, recovering 200 cycles of otherwise wasted execution bandwidth.

---

### Dependency Classes

Before examining the OOO machinery, the dependency types that constrain scheduling must be characterized precisely.

**True dependency (RAW — Read After Write):** Instruction $j$ reads a value that instruction $i$ must write. This is a genuine data dependency — $j$ cannot execute before $i$ produces its result. RAW hazards cannot be eliminated; they are inherent in the computation.

$$i: \text{R1} \leftarrow \text{R2} + \text{R3}$$ $$j: \text{R4} \leftarrow \text{R1} + \text{R5} \quad \text{(must wait for } i \text{)}$$

**Anti-dependency (WAR — Write After Read):** Instruction $j$ writes a register that instruction $i$ must read first. If $j$ executes before $i$ reads, $i$ gets the wrong value. This is a false dependency — it arises from register name reuse, not from genuine data flow. WAR hazards are eliminable through register renaming.

$$i: \text{R4} \leftarrow \text{R1} + \text{R2}$$ $$j: \text{R1} \leftarrow \text{R6} + \text{R7} \quad \text{(must not overwrite R1 before } i \text{ reads it)}$$

**Output dependency (WAW — Write After Write):** Two instructions write the same register. The later write (in program order) must be the one visible after both complete. Also a false dependency, also eliminable by renaming.

$$i: \text{R1} \leftarrow \text{R2} + \text{R3}$$ $$j: \text{R1} \leftarrow \text{R4} + \text{R5} \quad \text{(R1 must hold } j\text{'s result)}$$

The critical insight: WAR and WAW hazards exist only because the ISA has a limited number of architectural registers. With unlimited physical registers, every instruction writes a fresh register, and false dependencies vanish entirely.

---

### Register Renaming

Register renaming maps the ISA's architectural register names (the small set visible to software) onto a larger pool of physical registers. Every instruction that writes a register is assigned a new, unused physical register. Instructions that read the register receive the physical register tag of the most recent write to that architectural register.

**Rename table (Register Alias Table — RAT):** A mapping from each architectural register to the physical register currently holding its value.

**Example with 8 architectural registers (R0–R7) and 64 physical registers (P0–P63):**

Initial state: R1→P1, R2→P2, R3→P3, R4→P4 (previous assignments)

```
Instruction           Renames to         RAT after rename
──────────────────────────────────────────────────────────
ADD  R1, R2, R3   →  ADD  P10, P2, P3   R1→P10
ADD  R4, R1, R5   →  ADD  P11, P10, P5  R4→P11
ADD  R1, R6, R7   →  ADD  P12, P6, P7   R1→P12  (new writer)
ADD  R4, R1, R4   →  ADD  P13, P12, P11 R4→P13
```

After renaming: the WAW hazard between the two R1 writes is gone — they now write distinct physical registers P10 and P12. The WAR hazard is also gone. Only RAW dependencies remain, represented by physical register tags flowing between instructions.

**The RAT is updated at rename time** (in-order). Reads of the RAT capture the current producer of each architectural register. The RAT entry for a destination register is updated to point to the newly allocated physical register.

When an instruction completes and is retired (committed in program order), the old physical register mapping it replaced is freed back to the free list.

---

### The Reorder Buffer

The Reorder Buffer (ROB) is the central data structure of an OOO processor. It maintains program order even when instructions execute out of order, enabling precise exceptions and in-order retirement.

**ROB structure:** A circular buffer with head and tail pointers. Instructions enter the ROB at the tail in program order (at rename/dispatch time) and leave from the head in program order (at retirement/commit time).

Each ROB entry holds:

|Field|Contents|
|---|---|
|PC|Address of the instruction|
|Destination physical register|Physical register assigned by renaming|
|Destination architectural register|For updating the architectural RAT at commit|
|Value|Result (written here when execution completes)|
|Completed bit|Set when execution finishes|
|Exception info|Any exception detected during execution|
|Store address/data|For store instructions|

**Lifecycle of an instruction through the ROB:**

1. **Dispatch** — instruction enters the ROB tail; completed bit is 0
2. **Issue** — instruction leaves a reservation station for an execution unit (out of order)
3. **Execute** — result computed; written to the physical register file and ROB entry; completed bit set to 1
4. **Retire/Commit** — ROB head instruction retires if its completed bit is 1; result made architectural; old physical register freed

**Precise exceptions:** Because retirement is in-order, any exception detected during execution is held in the ROB entry. The processor retires all prior instructions normally; when the faulting instruction reaches the head of the ROB, execution is squashed, the exception handler is invoked, and the architectural state reflects all instructions before the fault and none after. This is not guaranteed by simple forward reasoning alone — it is an invariant enforced by the ROB structure.

---

### Reservation Stations

A reservation station (RS) is a buffer that holds an issued instruction and its operands (or tags indicating where operands will come from) until all operands are available and an execution unit is free.

**RS entry fields:**

|Field|Contents|
|---|---|
|Op|Operation to perform|
|Vj, Vk|Values of ready operands|
|Qj, Qk|Physical register tags of not-yet-ready operands (0 if ready)|
|Dest|ROB entry (or physical register) to write result to|
|A|Immediate or memory address|
|Busy|Entry in use|

An instruction with Qj = Qk = 0 (both operands ready) can issue to an execution unit immediately. An instruction waiting on a result monitors the **common data bus (CDB)** — the broadcast bus on which execution units announce completed results. When a result for tag $Q$ is broadcast on the CDB, all RS entries with $Qj = Q$ or $Qk = Q$ capture the value and clear the tag.

**Distributed vs. centralized reservation stations:**

- **Per-unit (distributed) RS:** Each execution unit has its own dedicated reservation station queue. Instructions are dispatched to the RS of their target unit. Simpler control but may leave one unit's RS full while another unit's is empty.
- **Unified RS (issue queue):** A single shared pool of RS entries for all execution units. Instructions issue to whichever compatible unit is free. Better utilization, more complex wakeup and select logic.

Modern processors (Intel P6 descendants, AMD Zen) use a unified scheduler (issue queue) with 60–100+ entries, feeding multiple execution ports.

---

### Tomasulo's Algorithm

Tomasulo's algorithm, developed at IBM for the System/360 Model 91 floating-point unit (1967), is the foundational out-of-order execution scheme. Modern OOO processors are refinements of this algorithm, not departures from it.

**Key mechanisms:**

1. **Register renaming via reservation station tags** — in the original formulation, RS entries themselves serve as physical registers; in modern implementations, a separate physical register file is used with the RS holding tags.
2. **Common Data Bus (CDB) broadcast** — completed results are broadcast to all RS entries simultaneously; any waiting entry that matches the tag captures the value.
3. **Distributed control** — no central arbiter; each RS monitors the CDB independently.

**Execution trace example:**

Instructions: `FLD F6, [A]` (load), `FADD F8, F6, F2`, `FMUL F10, F6, F4`

- After `FLD F6` issues: FADD's Qj and FMUL's Qj are set to the tag of the load RS entry; both instructions are dispatched to RS but cannot issue yet.
- When `FLD F6` completes: result is broadcast on CDB with tag. FADD and FMUL both capture F6's value; their Qj fields clear to 0.
- Both FADD and FMUL are now ready. If two floating-point units are available, both issue simultaneously — this is the out-of-order, parallel execution that Tomasulo enables.

**Tomasulo without ROB** (original) provides out-of-order execution but cannot support precise exceptions, because results are written directly to the register file when computed. Adding the ROB (Tomasulo + ROB = the modern superscalar baseline) restores in-order commitment and precise exceptions.

---

### The Complete OOO Pipeline

The OOO execution pipeline has more stages than a simple in-order pipeline, with distinct phases for instruction management:

**Fetch** — instructions retrieved from the instruction cache (or decoded µop cache in x86); branch prediction determines the fetch address.

**Decode** — instructions decoded into micro-operations (µops) in CISC architectures; RISC instructions typically map 1:1.

**Rename/Dispatch** — architectural register names replaced with physical register tags; instruction allocated an ROB entry and dispatched to the appropriate reservation station. This stage executes in program order. Typically 4–8 instructions per cycle in a wide superscalar.

**Issue (Schedule)** — reservation stations monitor the CDB; when an instruction's operands are ready and a functional unit is free, it is issued. This stage is out of order. The scheduler selects among all ready instructions each cycle.

**Execute** — instruction runs in the functional unit. Latency varies: integer ALU is 1 cycle, integer multiply 3–5 cycles, FP add 3–5 cycles, FP multiply 5–7 cycles, load (L1 hit) 4–5 cycles, load (L2 hit) 12+ cycles.

**Writeback** — result broadcast on CDB; written to physical register file and ROB entry; completed bit set; waiting RS entries wake up.

**Retire/Commit** — ROB head instruction retires if complete; architectural state updated; physical register freed if it is the old mapping for that architectural register. Typically 4–8 retirements per cycle.

---

### Wakeup and Select

The issue logic must solve two sub-problems each cycle:

**Wakeup:** When a result is produced, which RS entries now have all operands ready? The wakeup logic compares the produced tag against all Qj and Qk fields in the RS simultaneously — an associative comparison across all entries. For a 64-entry RS with 64-bit tags, this is a 64×64-bit comparator array, a significant hardware cost.

**Select:** Among all ready instructions, which ones issue this cycle? The number of instructions that can issue per cycle equals the number of execution ports. Select logic must choose among ready instructions, typically prioritizing older instructions (oldest-first scheduling) to prevent starvation and to maintain forward progress. The select logic is a priority encoder over the ready bits, with age tracking.

Wakeup and select must complete within one cycle for back-to-back dependent instructions to issue with minimal latency. In practice, speculative wakeup is used: an instruction whose producer has a known, fixed latency (e.g., an ALU instruction taking exactly 1 cycle) wakes up its dependents one cycle before the result is confirmed. If the producer's latency is violated (e.g., a cache miss), the speculatively issued dependent must be squashed and reissued — this is called a **replay**.

---

### Memory Ordering in OOO

Loads and stores to memory cannot be freely reordered without additional machinery, because memory is shared and the correct value at an address depends on the order of writes.

**Load-store queue (LSQ):** Holds all in-flight loads and stores in program order. Each entry records the virtual address, data, size, and completion status.

**Store-to-load forwarding:** If a load's address matches a prior (in program order) store's address that has not yet committed, the load receives the store's data directly from the LSQ rather than from cache. This is correct because the store will eventually write that value to memory.

**Memory disambiguation:** A load may execute before a prior store if the addresses are confirmed to be different. If addresses cannot be confirmed different (e.g., the store address is not yet known), the processor must either stall the load (conservative) or execute speculatively and verify later (aggressive, with replay on mismatch).

**Memory consistency:** The memory ordering model (TSO for x86, weakly ordered for ARM and RISC-V with explicit fences) determines which reorderings are architecturally visible. The OOO engine must enforce at minimum the guarantees of the ISA's memory model; additional reorderings are permitted only if they are invisible to software.

---

### Speculative Execution

OOO execution is inseparably linked to speculation. The two primary sources of speculation are:

**Branch prediction:** Fetching and executing instructions past an unresolved branch requires predicting the branch outcome. If the prediction is wrong, all instructions fetched along the wrong path must be squashed — their ROB entries, RS entries, and physical register allocations are rolled back, and the RAT is restored to the state at the mispredicted branch. The cost of a misprediction is the branch resolution latency (typically 15–20 cycles in a deep pipeline).

**Memory dependence speculation:** Executing a load before prior stores whose addresses are unknown, on the assumption that they do not alias.

**Exception deferral:** An instruction that generates an exception during OOO execution does not immediately take the exception. The exception is recorded in the ROB entry and deferred until the instruction reaches the head of the ROB and retires — ensuring that only instructions that should have been executed (in program order) generate exceptions.

The ROB is the mechanism that makes all speculation safe: as long as instructions have not retired, any speculative work can be discarded by flushing the ROB and restoring the rename state. Retired instructions, by definition, are correct — they have passed all hazard checks and been committed to architectural state.

---

### Performance Limits of OOO

OOO execution widens the window of instructions visible to the scheduler, but several factors bound its effectiveness:

**ROB size** determines the instruction window. An instruction stalled waiting for a cache miss occupies an ROB entry; instructions past it can execute only if they fit within the remaining ROB capacity. With a 200-cycle L2 miss and a 200-entry ROB, the processor can find at most 200 instructions of independent work. Beyond that, the ROB fills and fetch stalls.

**True data dependencies** (RAW hazards) create irreducible latency chains. The longest chain of dependent instructions — the critical path — sets a lower bound on execution time that no amount of OOO width or window size can reduce.

**Instruction fetch bandwidth** limits how quickly the instruction window fills. A branch misprediction drains the window; until the correct-path instructions fill the ROB and RS, execution resources sit idle.

**Memory latency** dominates modern workloads. Cache misses that go to DRAM (100–300 cycles) are far longer than the deepest pipeline, and the working set of many real programs exceeds L3 cache capacity.

**ILP wall:** Empirical studies (Wall 1991, Austin & Sohi 1992) found that real programs contain limited ILP — typically 2–4 instructions of independent work per cycle in general-purpose code, even with an ideal infinite-window OOO machine. This fundamental property of sequential programs, not microarchitectural limitations, sets the ceiling.

---

The diagram below shows the structural relationship between the key OOO components — the rename stage, physical register file, ROB, reservation stations, execution units, and the CDB — and the data flow between them.---

### ROB Sizing and Window Effects

The relationship between ROB size and the number of independent instructions that can be found is not linear. Consider a workload with a cache miss every $M$ instructions, each miss taking $L$ cycles. For the processor to fully hide the miss latency, the ROB must hold at least $L$ instructions beyond the miss:

$$\text{ROB}_{\min} = L \times \text{IPC}_{\text{sustainable}}$$

For an L3 miss at 150 cycles and a sustained IPC of 3: the ROB needs at least 450 entries to keep all execution units busy during the miss. This motivates the trend toward larger ROBs in server-class processors — Intel Sapphire Rapids has a 512-entry ROB; AMD Zen 4 has 320 entries.

Beyond a critical size, ROB enlargement yields diminishing returns because the limiting factor shifts from window size to the ILP available in the instruction stream itself.

---

### Physical Register File Management

The free list is a hardware FIFO of available physical registers. At rename, the destination register draws from the free list. At retirement, the physical register that previously mapped to the same architectural register (the "old" mapping, saved in the ROB entry) is returned to the free list.

The minimum physical register count required:

$$P \geq R_{arch} + \text{ROB size}$$

where $R_{arch}$ is the number of architectural registers. With 32 architectural registers and a 256-entry ROB, at least 288 physical registers are needed — in practice, processors provision more to avoid stalls when the free list empties. Intel's Skylake has 180 integer physical registers; Zen 4 has 224.

**Retirement RAT vs. frontend RAT:** Two RAT copies are maintained. The frontend RAT tracks the in-flight speculative mapping used during rename. The retirement RAT (or architectural RAT) tracks only committed mappings — it is updated at retirement and represents the ground truth architectural state. On a misprediction flush, the frontend RAT is restored from the retirement RAT (or walked back using the ROB's saved old-mapping entries).

---

### **Key Points**

- OOO execution reorders instruction execution by data availability while preserving the program-order illusion through in-order rename (front-end) and in-order retirement (back-end).
- Register renaming eliminates WAR and WAW false dependencies by mapping architectural registers to a larger physical register file; only true RAW dependencies remain as scheduling constraints.
- The Reorder Buffer enforces in-order retirement and enables precise exceptions by holding instructions until they are the oldest incomplete instruction.
- Reservation stations implement distributed or centralized scheduling: each entry monitors the CDB for its missing operands and issues to an execution unit when all operands arrive.
- Tomasulo's algorithm (1967) is the foundational scheme; modern OOO processors extend it with a separate physical register file, ROB for precise exceptions, and speculative execution past branches.
- The performance ceiling of OOO is set by RAW critical-path latency, ROB capacity relative to memory latency, and the fundamental ILP of the instruction stream — not by microarchitectural window size alone.

---

**Next Steps**

Out-of-order execution is inseparable from **branch prediction** — without accurate prediction, the instruction window fills with wrong-path instructions that must be squashed, collapsing the effective ILP. The next natural topic is **Tomasulo's algorithm** examined in full operational detail (timing tables, reservation station states across cycles), followed by **speculative execution and its security implications** (Spectre/Meltdown), which arise directly from the combination of OOO, speculation past branches, and cache-timing side channels.

---

