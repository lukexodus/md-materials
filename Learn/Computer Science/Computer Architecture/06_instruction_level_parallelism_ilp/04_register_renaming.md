## Register Renaming


---

### The Problem: False Dependencies

Out-of-order processors exploit instruction-level parallelism by executing instructions as their true data dependencies allow, not in program order. The limiting factor is not always true dependencies — it is often **false dependencies** introduced by the ISA's limited architectural register namespace.

There are three dependency types:

|Dependency|Also called|Nature|
|---|---|---|
|RAW — Read After Write|True dependency|Instruction B reads a value that A must produce first — a genuine constraint|
|WAR — Write After Read|Anti-dependency|Instruction B writes a register that A must read first — a name conflict, not a data constraint|
|WAW — Write After Write|Output dependency|Instructions A and B both write the same register — a name conflict, not a data constraint|

WAR and WAW are **false dependencies** — they exist because two independent operations happen to use the same architectural register name, not because one operation needs the other's result. They impose ordering constraints that limit out-of-order scheduling unnecessarily.

**Example:**

```asm
I1: MUL  r1, r2, r3     ; r1 ← r2 × r3
I2: ADD  r4, r1, r5     ; r4 ← r1 + r5   (RAW on r1: true dependency on I1)
I3: SUB  r1, r6, r7     ; r1 ← r6 - r7   (WAW with I1, WAR with I2: false)
I4: MOV  r8, r1         ; r8 ← r1        (RAW on r1: true dependency on I3)
```

I3 cannot be scheduled before I2 completes (WAR: I2 reads r1, I3 writes r1). But I3's computation is completely independent of I1 and I2 — the only conflict is the name `r1`. Register renaming eliminates this.

---

### The Principle

Register renaming maps each **architectural register** (the register name visible in the ISA — r0–r31 in RISC-V, EAX–R15 in x86-64) to a **physical register** drawn from a larger pool. Every instruction that writes an architectural register is assigned a fresh physical register. Consumers of that write are directed to the specific physical register assigned to the write they depend on.

The result: WAR and WAW hazards disappear structurally. Two instructions writing `r1` at different times write to two different physical registers — there is no conflict.

The rename state is maintained in a mapping table. After each write, the table is updated to record the new physical register for that architectural name. Reads consult the table to find which physical register currently holds the value for a given architectural name.

---

### Physical Register File and Free List

The physical register file (PRF) contains P registers, where P >> N (N = number of architectural registers). Typical values:

|Architecture|Architectural registers|Physical registers (approx.)|
|---|---|---|
|MIPS R10000|32 integer|64 integer|
|Alpha 21264|31 integer (r31=0)|80 integer|
|Intel P6 (Pentium Pro)|8 integer|40 integer|
|Modern x86-64 (Zen 4, Golden Cove)|16 integer|192–280 integer|

A **free list** tracks physical registers not currently mapped to any in-use architectural register write. When an instruction is renamed, it claims a register from the free list. When an instruction retires and its destination physical register is superseded by a later write to the same architectural register, the old physical register is returned to the free list.

<svg viewBox="0 0 680 260" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Architectural registers --> <rect x="0" y="30" width="130" height="200" rx="4" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <text x="65" y="20" text-anchor="middle" fill="#222" font-weight="bold">Architectural</text> <text x="65" y="10" text-anchor="middle" fill="#222" font-weight="bold"></text> <text x="65" y="50" text-anchor="middle" fill="#555">r0</text> <text x="65" y="68" text-anchor="middle" fill="#555">r1</text> <text x="65" y="86" text-anchor="middle" fill="#555">r2</text> <text x="65" y="104" text-anchor="middle" fill="#555">r3</text> <text x="65" y="122" text-anchor="middle" fill="#555">r4</text> <text x="65" y="140" text-anchor="middle" fill="#555">…</text> <text x="65" y="158" text-anchor="middle" fill="#555">r31</text> <text x="65" y="222" text-anchor="middle" fill="#336" font-size="10">N = 32 names</text> <!-- Rename map --> <rect x="200" y="30" width="150" height="200" rx="4" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/> <text x="275" y="20" text-anchor="middle" fill="#222" font-weight="bold">Rename Map</text> <text x="275" y="50" text-anchor="middle" fill="#555">r0 → p0</text> <text x="275" y="68" text-anchor="middle" fill="#c60" font-weight="bold">r1 → p47</text> <text x="275" y="86" text-anchor="middle" fill="#555">r2 → p12</text> <text x="275" y="104" text-anchor="middle" fill="#555">r3 → p23</text> <text x="275" y="122" text-anchor="middle" fill="#555">r4 → p8</text> <text x="275" y="140" text-anchor="middle" fill="#555">…</text> <text x="275" y="158" text-anchor="middle" fill="#555">r31 → p31</text> <text x="275" y="222" text-anchor="middle" fill="#336" font-size="10">maps name → physical</text> <!-- Physical register file --> <rect x="430" y="30" width="130" height="200" rx="4" fill="#fff5cc" stroke="#336" stroke-width="1.5"/> <text x="495" y="20" text-anchor="middle" fill="#222" font-weight="bold">Physical RF</text> <text x="495" y="50" text-anchor="middle" fill="#555">p0: 0x0000</text> <text x="495" y="68" text-anchor="middle" fill="#555">p1: —</text> <text x="495" y="86" text-anchor="middle" fill="#555">…</text> <text x="495" y="104" text-anchor="middle" fill="#555">p8: 0x00FF</text> <text x="495" y="122" text-anchor="middle" fill="#555">…</text> <text x="495" y="140" text-anchor="middle" fill="#c60" font-weight="bold">p47: (exec)</text> <text x="495" y="158" text-anchor="middle" fill="#555">…</text> <text x="495" y="176" text-anchor="middle" fill="#555">p63: —</text> <text x="495" y="222" text-anchor="middle" fill="#336" font-size="10">P = 64 registers</text> <!-- Free list --> <rect x="430" y="240" width="130" height="30" rx="4" fill="#ffd6d6" stroke="#c60" stroke-width="1.5"/> <text x="495" y="260" text-anchor="middle" fill="#c60">Free: p2,p5,p9,p41…</text> <!-- Arrows --> <line x1="130" y1="68" x2="200" y2="68" stroke="#c60" stroke-width="1.5" marker-end="url(#ra)"/> <line x1="350" y1="68" x2="430" y2="140" stroke="#c60" stroke-width="1.5" stroke-dasharray="4,2" marker-end="url(#ra)"/> <defs> <marker id="ra" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#c60"/> </marker> </defs> </svg>

---

### Rename Map Implementations

Two principal structures implement the rename map. They differ in how they store and recover mapping state.

---

#### Register Alias Table (RAT)

The RAT is a direct-mapped table indexed by architectural register number. Each entry holds the physical register tag currently mapped to that architectural register.

**Front-end RAT (speculative state):** Updated as instructions are renamed in program order. Reflects the most recent rename assignment, which may be speculative (the instruction has not yet committed).

**Retirement RAT (committed state):** Updated only when instructions commit in order. Reflects the mapping of the last committed instruction to write each architectural register. Used to restore the RAT on branch misprediction — the retirement RAT represents the last known-good state.

```
On rename of instruction writing arch reg rA:
  old_phys = RAT[rA]           // save old mapping (for free list on commit)
  new_phys = FreeList.allocate()
  RAT[rA]  = new_phys          // update speculative map
  ROB_entry.old_phys = old_phys
  ROB_entry.new_phys = new_phys

On instruction commit:
  RetirementRAT[rA] = new_phys
  FreeList.release(old_phys)   // old mapping no longer reachable

On misprediction flush:
  RAT ← RetirementRAT          // restore committed state
  FreeList ← reclaim all speculative allocations
```

The P6 microarchitecture (Pentium Pro, Pentium II/III) used this scheme with the retirement RAT called the **Register Alias File (RAF)**.

---

#### Rename Using the ROB Directly (Unified PRF + ROB)

An alternative used in some designs maps architectural registers to **ROB entries** directly — the ROB entry for the writing instruction holds the result until commit, at which point the value is written to a committed architectural register file. The rename map entries point to either an ROB slot (instruction in flight) or an architectural register (committed value).

This is sometimes called a **future file / architectural file** split:

- **Future file (speculative):** holds the most recent value for each architectural register, including uncommitted speculative writes — fast read path for dependent instructions
- **Architectural file:** holds only committed values — used for recovery

The trade-off versus a unified PRF: the future file must be checkpointed or rebuilt on misspeculation, which is more costly than simply restoring the RAT and reclaiming physical registers.

---

### Renaming Algorithm: Step by Step

For each instruction in program order, during the rename stage:

**Step 1 — Rename source operands (reads):** For each source register `rs`:

```
phys_rs = RAT[rs]   // look up current physical register for this architectural name
```

The renamed instruction carries `phys_rs` as its source tag — it will wait for the physical register holding the value produced by the most recent writer of `rs` before it.

**Step 2 — Rename destination operand (write):**

```
old_phys_rd = RAT[rd]          // save for later freeing
new_phys_rd = FreeList.pop()   // allocate fresh physical register
RAT[rd] = new_phys_rd          // future reads of rd see this new mapping
```

**Step 3 — Insert into ROB and issue queue:** The instruction is placed in the ROB with its physical source and destination tags. It enters the issue queue (reservation station) and waits until all its physical source registers are marked ready.

**Example — applying renaming to the earlier sequence:**

```
Architectural:                    After renaming (p0–p5 initially mapped):
I1: MUL  r1, r2, r3              MUL  p6,  p2, p3     RAT[r1] ← p6
I2: ADD  r4, r1, r5              ADD  p7,  p6, p5     RAT[r4] ← p7   (reads p6: waits for I1)
I3: SUB  r1, r6, r7              SUB  p8,  p4, p1     RAT[r1] ← p8   (no dep on p6 or p7)
I4: MOV  r8, r1                  MOV  p9,  p8         RAT[r8] ← p9   (reads p8: waits for I3)
```

I3 now writes `p8`, not `p6`. The WAW between I1 and I3 is gone — they write different physical registers. The WAR between I2 and I3 is gone — I2 reads `p6`, I3 writes `p8`. I3 can execute as soon as `p4` and `p1` are ready, in parallel with I2 executing.

---

### Interaction with the ROB and Tomasulo's Algorithm

Register renaming in a modern out-of-order processor is the rename stage of the Tomasulo-derived pipeline. The full in-order/out-of-order boundary:

<svg viewBox="0 0 760 130" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <!-- Fetch --> <rect x="0" y="30" width="80" height="50" rx="4" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <text x="40" y="58" text-anchor="middle" fill="#222">Fetch</text> <!-- Decode --> <rect x="100" y="30" width="80" height="50" rx="4" fill="#d0e8ff" stroke="#336" stroke-width="1.5"/> <text x="140" y="58" text-anchor="middle" fill="#222">Decode</text> <!-- Rename/Dispatch --> <rect x="200" y="20" width="110" height="70" rx="4" fill="#d0ffd6" stroke="#336" stroke-width="2"/> <text x="255" y="52" text-anchor="middle" fill="#222" font-weight="bold">Rename /</text> <text x="255" y="66" text-anchor="middle" fill="#222" font-weight="bold">Dispatch</text> <text x="255" y="80" text-anchor="middle" fill="#555" font-size="9">RAT lookup + alloc</text> <!-- Issue queue --> <rect x="330" y="30" width="100" height="50" rx="4" fill="#fff5cc" stroke="#336" stroke-width="1.5"/> <text x="380" y="52" text-anchor="middle" fill="#222">Issue</text> <text x="380" y="64" text-anchor="middle" fill="#222">Queue</text> <!-- Execute --> <rect x="450" y="30" width="80" height="50" rx="4" fill="#fff5cc" stroke="#336" stroke-width="1.5"/> <text x="490" y="58" text-anchor="middle" fill="#222">Execute</text> <!-- ROB --> <rect x="550" y="30" width="80" height="50" rx="4" fill="#ffd6d6" stroke="#336" stroke-width="1.5"/> <text x="590" y="58" text-anchor="middle" fill="#222">ROB</text> <!-- Commit --> <rect x="650" y="30" width="80" height="50" rx="4" fill="#e8d0ff" stroke="#336" stroke-width="1.5"/> <text x="690" y="58" text-anchor="middle" fill="#222">Commit</text> <!-- Arrows --> <line x1="80" y1="55" x2="100" y2="55" stroke="#555" stroke-width="1.5" marker-end="url(#rb)"/> <line x1="180" y1="55" x2="200" y2="55" stroke="#555" stroke-width="1.5" marker-end="url(#rb)"/> <line x1="310" y1="55" x2="330" y2="55" stroke="#555" stroke-width="1.5" marker-end="url(#rb)"/> <line x1="430" y1="55" x2="450" y2="55" stroke="#555" stroke-width="1.5" marker-end="url(#rb)"/> <line x1="530" y1="55" x2="550" y2="55" stroke="#555" stroke-width="1.5" marker-end="url(#rb)"/> <line x1="630" y1="55" x2="650" y2="55" stroke="#555" stroke-width="1.5" marker-end="url(#rb)"/> <!-- In-order / OoO boundary --> <line x1="315" y1="10" x2="315" y2="120" stroke="#c60" stroke-width="1.5" stroke-dasharray="5,3"/> <text x="200" y="115" fill="#c60" font-size="10">← in-order front-end</text> <text x="330" y="115" fill="#c60" font-size="10">out-of-order back-end →</text> <defs> <marker id="rb" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#555"/> </marker> </defs> </svg>

Rename/dispatch is the last in-order stage. It:

- Reads the RAT to resolve source physical registers
- Allocates a new physical register from the free list for each destination
- Updates the RAT
- Allocates an ROB entry (in order)
- Places the renamed instruction into the issue queue (reservation station)

From the issue queue onward, instructions proceed out of order.

---

### Wakeup and Select with Physical Register Tags

Once renamed instructions are in the issue queue, they wait for their source physical registers to become ready. This is the **wakeup** mechanism:

When an execution unit completes and writes a result to physical register `pX`, it broadcasts `pX` on the **common data bus (CDB)**. Every entry in the issue queue that has `pX` as a pending source tag marks that source as ready. When all sources of an instruction are marked ready, the instruction is eligible for issue.

**Select** logic (typically a priority encoder or age-based scheduler) picks among all ready instructions and dispatches them to available execution units.

The physical register tag is the token that connects the producer to all its consumers without requiring them to have a fixed scheduling order — the tag-based wakeup mechanism is what makes true out-of-order execution functional.

---

### Checkpointing for Recovery

On a branch misprediction, the processor must:

1. Flush all instructions after the mispredicted branch from the ROB, issue queue, and execution units
2. Restore the rename map to the state it had at the branch point
3. Return allocated physical registers to the free list
4. Redirect the fetch unit to the correct path

**RAT recovery strategies:**

**Walk-back using ROB:** Walk the ROB from tail to the mispredicted branch in reverse order. For each instruction encountered, restore `RAT[rd] = old_phys_rd` (the old mapping saved at rename time) and return `new_phys_rd` to the free list. Cost: proportional to the number of instructions in the ROB after the branch.

**Checkpoint RAT:** At each branch, save a full copy of the RAT (N entries, one per architectural register). On misprediction, restore the checkpoint directly. Cost: O(1) recovery, O(N) storage per checkpoint. Used when the branch resolution latency is long and the ROB is deep — maintaining several checkpoints (one per in-flight branch) is feasible because N is small (32–64 entries).

**Retirement RAT restore:** Restore from the retirement RAT (always valid committed state). Faster than walk-back for large ROBs but discards all speculative progress — even correctly-predicted instructions between the branch and the misprediction point must be re-fetched.

---

### Renaming in x86-64: The Complexity of Partial Registers

x86-64 has architectural registers that are aliased at different widths: RAX (64-bit) contains EAX (32-bit) contains AX (16-bit) contains AL/AH (8-bit). A write to EAX must zero-extend into RAX (by x86-64 convention); a write to AX must merge into the lower 16 bits of RAX without affecting the upper 48 bits; a write to AH modifies bits [15:8] of RAX.

This creates a **partial register write** problem: renaming a write to AX requires:

- Allocating a new physical register for the full 64-bit RAX
- Merging the new AX value with the existing upper bits of the old RAX physical register
- The merge itself is a dependent operation — it reads the old physical register for RAX and writes the new one

Modern x86-64 implementations handle this through a combination of:

- **Merge microops:** a synthesized operation that performs the merge explicitly, inserted by the decode/rename stage
- **Penalty on partial writes:** some implementations stall or insert a dependency when a partial-width write is followed by a full-width read, rather than tracking sub-register granularity in the rename map
- **Zero-extension rule:** 32-bit writes to EAX implicitly zero the upper 32 bits — the rename is clean (no merge needed), which is why compilers targeting x86-64 prefer 32-bit operations when 64-bit precision is not needed

---

### Rename Throughput and Bandwidth

The rename stage must sustain the same instruction throughput as the fetch and decode stages — typically 4–8 instructions per cycle in a modern wide out-of-order core. This imposes constraints:

**Simultaneous RAT updates:** When N instructions are renamed in a single cycle and multiple instructions in that group write the same architectural register, the RAT updates must be applied in program order within the cycle. The last write to a given architectural register in the group is the one that becomes visible to subsequent instructions.

**Within-group dependency resolution:** If instruction I2 in the same rename group reads a register written by I1 in the same group, the rename of I2's source must use the new physical register assigned to I1, not the old RAT entry. This requires a **bypass network** within the rename stage itself — N×N comparators checking whether any earlier instruction in the group writes the register being read.

**Free list bandwidth:** N physical registers must be allocated per cycle (one per instruction that has a destination). The free list must support N parallel pops; this is typically implemented as a circular buffer with a head pointer advanced by N each cycle, or as a banked structure.

---

### False Dependency Elimination: Summary

<svg viewBox="0 0 680 240" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Before renaming -->

<text x="0" y="18" fill="#222" font-weight="bold">Before Renaming</text> <rect x="0" y="28" width="300" height="190" rx="4" fill="#ffeedd" stroke="#c60" stroke-width="1.5"/>

<text x="15" y="55" fill="#333">I1: MUL r1, r2, r3</text> <text x="15" y="78" fill="#333">I2: ADD r4, r1, r5</text> <text x="15" y="101" fill="#333">I3: SUB r1, r6, r7</text> <text x="15" y="124" fill="#333">I4: MOV r8, r1</text>

<!-- Dependency arrows before --> <line x1="60" y1="78" x2="60" y2="62" stroke="#336" stroke-width="2" marker-end="url(#rc)"/> <text x="65" y="72" fill="#336" font-size="10">RAW r1</text> <line x1="80" y1="101" x2="80" y2="85" stroke="#c60" stroke-width="1.5" stroke-dasharray="3,2" marker-end="url(#rd)"/> <text x="85" y="96" fill="#c60" font-size="10">WAR r1</text> <line x1="60" y1="101" x2="55" y2="62" stroke="#900" stroke-width="1.5" stroke-dasharray="3,2" marker-end="url(#rd)"/> <text x="10" y="88" fill="#900" font-size="10">WAW r1</text> <line x1="60" y1="124" x2="60" y2="108" stroke="#336" stroke-width="2" marker-end="url(#rc)"/> <text x="65" y="118" fill="#336" font-size="10">RAW r1</text>

<text x="15" y="175" fill="#c60" font-size="11">WAR and WAW constrain</text> <text x="15" y="190" fill="#c60" font-size="11">I3 from running early</text>

<!-- After renaming -->

<text x="360" y="18" fill="#222" font-weight="bold">After Renaming</text> <rect x="360" y="28" width="300" height="190" rx="4" fill="#d0ffd6" stroke="#336" stroke-width="1.5"/>

<text x="375" y="55" fill="#333">I1: MUL p6, p2, p3</text> <text x="375" y="78" fill="#333">I2: ADD p7, p6, p5</text> <text x="375" y="101" fill="#333">I3: SUB p8, p4, p1</text> <text x="375" y="124" fill="#333">I4: MOV p9, p8</text>

<!-- Only true deps after --> <line x1="420" y1="78" x2="420" y2="62" stroke="#336" stroke-width="2" marker-end="url(#rc)"/> <text x="425" y="72" fill="#336" font-size="10">RAW p6</text> <line x1="420" y1="124" x2="420" y2="108" stroke="#336" stroke-width="2" marker-end="url(#rc)"/> <text x="425" y="118" fill="#336" font-size="10">RAW p8</text>

<text x="375" y="168" fill="#336" font-size="11">I3 has no dependency on</text> <text x="375" y="183" fill="#336" font-size="11">I1 or I2 — runs freely</text> <text x="375" y="198" fill="#336" font-size="11">I1 ∥ I3, I2 ∥ I4 possible</text>

<defs> <marker id="rc" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#336"/> </marker> <marker id="rd" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#c60"/> </marker> </defs> </svg>

---

### Physical Register Lifetime

A physical register's lifetime spans from its allocation at rename to its freeing at commit:

```
Allocated:  when instruction is renamed (new_phys assigned)
Written:    when instruction executes and result is produced
Read:       by all dependent instructions via issue queue wakeup / bypass
Freed:      when the instruction that superseded this mapping commits
            (i.e., a later instruction writing the same arch reg retires)
```

A physical register cannot be freed when the instruction that wrote it commits — it may still be the current mapping for that architectural register and be read by later instructions. It is freed only when a _later_ instruction writing the same architectural register commits and the retirement RAT is updated to point to the newer physical register. Only then is the old physical register guaranteed to have no future readers.

This lifetime analysis determines the minimum physical register file size: a processor needs enough physical registers to cover all in-flight instructions simultaneously, plus the N registers needed to represent the committed architectural state.

---

**Key Points**

- Register renaming eliminates WAR and WAW false dependencies by mapping each architectural register write to a unique physical register, converting name conflicts into distinct storage locations.
- The rename map (RAT) records the current physical register for each architectural register name; it exists in two forms — a speculative front-end RAT updated at rename, and a retirement RAT updated only at commit, used for recovery.
- Every destination write allocates a fresh physical register from the free list; the old physical register for that architectural name is freed only when a later writer to the same architectural register commits.
- Physical register tags replace architectural names in the issue queue, enabling tag-based wakeup — the mechanism by which dependent instructions are notified when their source values become available without a fixed schedule.
- Partial register writes (AX, AH in x86-64) complicate renaming by requiring merge operations; the x86-64 convention of zero-extending 32-bit writes to 64-bit registers is an ISA design choice that eliminates this complication for the common case.
- Recovery on branch misprediction requires restoring the RAT to the state at the branch point; strategies include ROB walk-back, checkpointed RAT snapshots, and retirement RAT restore, trading recovery latency against storage cost.

**Next Steps**

Proceed to **Reorder Buffer (ROB)**, which is the structure that enforces in-order commit while allowing out-of-order execution — it holds the physical register mappings needed for recovery, tracks instruction completion status, and manages the boundary between speculative and committed architectural state. Follow with **Speculative Execution** to see how renaming and the ROB together enable execution past unresolved branches.

---

