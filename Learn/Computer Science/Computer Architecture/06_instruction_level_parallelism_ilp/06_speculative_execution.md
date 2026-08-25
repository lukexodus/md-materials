## Speculative Execution


Speculative execution is the practice of performing work before it is known whether that work will be needed. A processor executes instructions whose results may be discarded if the speculation proves incorrect, trading potential wasted work for reduced stall cycles and higher throughput.

---

### Motivation

Two fundamental sources of uncertainty stall an in-order pipeline:

**Control uncertainty** — the outcome and target of a branch are not known until late in the pipeline. Waiting wastes fetch bandwidth.

**Data uncertainty** — in out-of-order processors, whether a load will alias with a prior store may not be known at issue time.

Speculative execution converts these stalls into conditional work: execute speculatively, verify the speculation, commit if correct, and roll back if incorrect.

---

### The Speculation Contract

Speculation is safe only if three properties hold:

|Property|Requirement|
|---|---|
|Recoverability|All speculative state can be discarded without affecting committed architectural state|
|Verification|The correctness of the speculation can be definitively checked|
|Commit gating|Speculative results are not made visible to software or external state until verified|

Violating any of these produces incorrect program behavior or security vulnerabilities.

---

### Architectural vs. Speculative State

The distinction between committed and speculative state is central to all speculation mechanisms:

<svg viewBox="0 0 680 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <rect width="680" height="200" fill="#1e1e2e"/> <!-- Committed state box --> <rect x="30" y="40" width="180" height="120" rx="6" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="2"/> <text x="120" y="62" fill="#a6e3a1" text-anchor="middle" font-size="13">Committed</text> <text x="120" y="80" fill="#a6e3a1" text-anchor="middle" font-size="11">Architectural State</text> <text x="120" y="102" fill="#cdd6f4" text-anchor="middle" font-size="11">Register file</text> <text x="120" y="118" fill="#cdd6f4" text-anchor="middle" font-size="11">Memory</text> <text x="120" y="134" fill="#cdd6f4" text-anchor="middle" font-size="11">PC</text> <text x="120" y="150" fill="#585b70" text-anchor="middle" font-size="10">visible to software</text> <!-- Arrow: speculative → commit --> <line x1="340" y1="100" x2="218" y2="100" stroke="#a6e3a1" stroke-width="2" marker-end="url(#acom)"/> <text x="280" y="90" fill="#a6e3a1" text-anchor="middle" font-size="11">commit</text> <text x="280" y="104" fill="#585b70" text-anchor="middle" font-size="10">(correct)</text> <!-- Speculative state box --> <rect x="340" y="40" width="200" height="120" rx="6" fill="#3a2a1a" stroke="#fab387" stroke-width="2"/> <text x="440" y="62" fill="#fab387" text-anchor="middle" font-size="13">Speculative</text> <text x="440" y="80" fill="#fab387" text-anchor="middle" font-size="11">In-flight State</text> <text x="440" y="102" fill="#cdd6f4" text-anchor="middle" font-size="11">Reorder Buffer</text> <text x="440" y="118" fill="#cdd6f4" text-anchor="middle" font-size="11">Physical registers</text> <text x="440" y="134" fill="#cdd6f4" text-anchor="middle" font-size="11">Store buffer</text> <text x="440" y="150" fill="#585b70" text-anchor="middle" font-size="10">not yet visible</text> <!-- Arrow: discard on misspeculation --> <path d="M440,160 Q440,185 280,185 Q200,185 200,160" fill="none" stroke="#f38ba8" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#afl)"/> <text x="320" y="180" fill="#f38ba8" text-anchor="middle" font-size="10">flush (incorrect) → restore committed state</text> <defs> <marker id="acom" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#a6e3a1"/> </marker> <marker id="afl" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#f38ba8"/> </marker> </defs> </svg>

---

### Branch Speculation

The most common and well-understood form of speculation. The processor predicts branch direction and target, then fetches and executes along the predicted path before the branch resolves.

#### Mechanism

```
1. Fetch branch instruction
2. Predict: taken to TARGET / not-taken (sequential)
3. Fetch and execute instructions along predicted path
4. Branch resolves in EX stage
5a. Prediction correct → no action; instructions already in pipeline
5b. Prediction wrong  → flush pipeline; restore PC to correct path
                        (branch misprediction penalty)
```

#### Misprediction Penalty

The penalty equals the number of pipeline stages between fetch and branch resolution. In a 5-stage pipeline it is 2 cycles. In a modern out-of-order processor with deep pipelines it can be 15–20 cycles.

```
Performance impact = branch_frequency × misprediction_rate × penalty_cycles
```

**Example:** 20% branches, 5% misprediction rate, 15-cycle penalty:

```
IPC loss = 0.20 × 0.05 × 15 = 0.15 cycles wasted per instruction
```

[Inference] This is an illustrative calculation; actual processor behavior depends on workload characteristics and microarchitectural details and is not guaranteed.

#### Branch Prediction Mechanisms

|Mechanism|Basis|Accuracy|
|---|---|---|
|Static (predict not taken)|Always assume sequential|~60–70% for typical code|
|2-bit saturating counter|Recent branch history|~85–90%|
|Correlating predictor|Global branch history|~90–95%|
|Tournament (hybrid)|Selects best of local/global|~95–98%|
|TAGE predictor|Tagged geometric history lengths|~99%+ on SPEC benchmarks|

---

### The Reorder Buffer (ROB)

The ROB is the hardware structure that makes speculative out-of-order execution safe. It maintains program order for commit while allowing execution to proceed out of order.

#### ROB Structure

Each ROB entry tracks one in-flight instruction:

|Field|Content|
|---|---|
|Instruction type|Load, store, ALU, branch, etc.|
|Destination register|Architectural register to be written on commit|
|Value|Result (valid once execution completes)|
|Ready bit|Set when execution finishes|
|Exception / fault|Any exception raised during execution|
|Speculative bit|Whether this instruction is on a speculative path|

#### ROB Operation

<svg viewBox="0 0 680 280" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="280" fill="#1e1e2e"/> <!-- ROB table -->

<text x="200" y="22" fill="#cba6f7" text-anchor="middle" font-size="13">Reorder Buffer</text>

<!-- Header --> <rect x="30" y="30" width="40" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="50" y="45" fill="#585b70" text-anchor="middle">Entry</text> <rect x="70" y="30" width="80" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="110" y="45" fill="#585b70" text-anchor="middle">Instr</text> <rect x="150" y="30" width="60" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="180" y="45" fill="#585b70" text-anchor="middle">Dest</text> <rect x="210" y="30" width="80" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="250" y="45" fill="#585b70" text-anchor="middle">Value</text> <rect x="290" y="30" width="50" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="315" y="45" fill="#585b70" text-anchor="middle">Ready</text> <!-- ROB entries --> <!-- Entry 0: head — ready to commit --> <rect x="30" y="52" width="40" height="22" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="1.5"/> <text x="50" y="67" fill="#a6e3a1" text-anchor="middle">0 ←H</text> <rect x="70" y="52" width="80" height="22" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="1"/> <text x="110" y="67" fill="#cdd6f4" text-anchor="middle">ADD R1,R2</text> <rect x="150" y="52" width="60" height="22" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="1"/> <text x="180" y="67" fill="#cdd6f4" text-anchor="middle">R1</text> <rect x="210" y="52" width="80" height="22" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="1"/> <text x="250" y="67" fill="#cdd6f4" text-anchor="middle">42</text> <rect x="290" y="52" width="50" height="22" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="1"/> <text x="315" y="67" fill="#a6e3a1" text-anchor="middle">✓</text> <!-- Entry 1: ready --> <rect x="30" y="74" width="40" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="50" y="89" fill="#cdd6f4" text-anchor="middle">1</text> <rect x="70" y="74" width="80" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="110" y="89" fill="#cdd6f4" text-anchor="middle">LW R3,0(R4)</text> <rect x="150" y="74" width="60" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="180" y="89" fill="#cdd6f4" text-anchor="middle">R3</text> <rect x="210" y="74" width="80" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="250" y="89" fill="#cdd6f4" text-anchor="middle">17</text> <rect x="290" y="74" width="50" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="315" y="89" fill="#a6e3a1" text-anchor="middle">✓</text> <!-- Entry 2: executing --> <rect x="30" y="96" width="40" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="50" y="111" fill="#cdd6f4" text-anchor="middle">2</text> <rect x="70" y="96" width="80" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="110" y="111" fill="#cdd6f4" text-anchor="middle">MUL R5,R6</text> <rect x="150" y="96" width="60" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="180" y="111" fill="#cdd6f4" text-anchor="middle">R5</text> <rect x="210" y="96" width="80" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="250" y="111" fill="#585b70" text-anchor="middle">—</text> <rect x="290" y="96" width="50" height="22" fill="#313244" stroke="#585b70" stroke-width="1"/> <text x="315" y="111" fill="#f38ba8" text-anchor="middle">✗</text> <!-- Entry 3: speculative (after branch) --> <rect x="30" y="118" width="40" height="22" fill="#3a2a1a" stroke="#fab387" stroke-width="1.5" stroke-dasharray="4,2"/> <text x="50" y="133" fill="#fab387" text-anchor="middle">3 T</text> <rect x="70" y="118" width="80" height="22" fill="#3a2a1a" stroke="#fab387" stroke-width="1"/> <text x="110" y="133" fill="#fab387" text-anchor="middle">SUB R7,R8</text> <rect x="150" y="118" width="60" height="22" fill="#3a2a1a" stroke="#fab387" stroke-width="1"/> <text x="180" y="133" fill="#fab387" text-anchor="middle">R7</text> <rect x="210" y="118" width="80" height="22" fill="#3a2a1a" stroke="#fab387" stroke-width="1"/> <text x="250" y="133" fill="#585b70" text-anchor="middle">—</text> <rect x="290" y="118" width="50" height="22" fill="#3a2a1a" stroke="#fab387" stroke-width="1"/> <text x="315" y="133" fill="#f38ba8" text-anchor="middle">✗</text> <!-- Entry 4: tail --> <rect x="30" y="140" width="40" height="22" fill="#3a2a1a" stroke="#fab387" stroke-width="1.5" stroke-dasharray="4,2"/> <text x="50" y="155" fill="#fab387" text-anchor="middle">4 ←T</text> <rect x="70" y="140" width="80" height="22" fill="#3a2a1a" stroke="#fab387" stroke-width="1"/> <text x="110" y="155" fill="#fab387" text-anchor="middle">AND R9,R10</text> <rect x="150" y="140" width="60" height="22" fill="#3a2a1a" stroke="#fab387" stroke-width="1"/> <text x="180" y="155" fill="#fab387" text-anchor="middle">R9</text> <rect x="210" y="140" width="80" height="22" fill="#3a2a1a" stroke="#fab387" stroke-width="1"/> <text x="250" y="155" fill="#585b70" text-anchor="middle">—</text> <rect x="290" y="140" width="50" height="22" fill="#3a2a1a" stroke="#fab387" stroke-width="1"/> <text x="315" y="155" fill="#f38ba8" text-anchor="middle">✗</text> <!-- Legend --> <rect x="30" y="180" width="12" height="12" fill="#1a3a1a" stroke="#a6e3a1" stroke-width="1"/> <text x="48" y="191" fill="#a6e3a1" font-size="10">H = head (commit pointer) — writes to architectural state on commit</text> <rect x="30" y="198" width="12" height="12" fill="#3a2a1a" stroke="#fab387" stroke-width="1" stroke-dasharray="3,2"/> <text x="48" y="209" fill="#fab387" font-size="10">T = tail (issue pointer) — speculative; flushed on misspeculation</text> <!-- Commit arrow -->

<text x="500" y="80" fill="#a6e3a1" font-size="11">Commit (in-order):</text> <text x="500" y="96" fill="#cdd6f4" font-size="10">Head entry ready → write</text> <text x="500" y="110" fill="#cdd6f4" font-size="10">result to arch. reg file</text> <text x="500" y="124" fill="#cdd6f4" font-size="10">→ advance head pointer</text>

<!-- Flush arrow -->

<text x="500" y="155" fill="#f38ba8" font-size="11">Flush (misspeculation):</text> <text x="500" y="171" fill="#cdd6f4" font-size="10">Squash entries 3..tail</text> <text x="500" y="185" fill="#cdd6f4" font-size="10">Restore rename map</text> <text x="500" y="199" fill="#cdd6f4" font-size="10">Redirect fetch to correct PC</text> </svg>

---

### Register Renaming and Speculation

Register renaming is a prerequisite for safe speculative out-of-order execution. Architectural registers (e.g., x86's 16 general-purpose registers) are mapped to a larger set of physical registers. This removes false dependencies (WAR, WAW) and allows speculative results to live in physical registers without contaminating the committed register file.

#### Rename Map Table (RAT)

The RAT maps each architectural register to the physical register holding its most recent in-flight value.

```
Architectural:  R1 → P23  (speculative, in ROB entry 3)
                R2 → P11  (committed)
                R3 → P07  (committed)
```

On a flush, the RAT is restored to the state captured at the most recent correctly-predicted branch checkpoint — or reconstructed by walking the ROB from head to the flush point.

---

### Store-to-Load Speculation

In out-of-order processors, loads and stores to memory may execute out of program order. The processor speculates that a load does not alias with any preceding in-flight store.

#### Load Speculation Mechanism

```
1. Load issues before preceding stores have computed their addresses
2. Processor assumes no address conflict → load reads from cache
3. When store address resolves: check for aliasing with younger loads
4a. No alias → speculation correct, no action
4b. Alias found → memory order violation: flush and re-execute
       from the offending load
```

This is enforced by a **memory order buffer (MOB)** or **load queue** that records speculative loads and validates them as store addresses become known.

---

### Exception Handling Under Speculation

Speculative instructions may raise exceptions (page faults, divide-by-zero, illegal instruction). These exceptions must not be reported to software until the faulting instruction reaches the head of the ROB — i.e., until it is known to be on the correct execution path.

|Scenario|Handling|
|---|---|
|Exception in speculative instruction, path later flushed|Exception discarded silently|
|Exception in speculative instruction, path committed|Exception signaled when instruction reaches ROB head|
|Imprecise exception (older style)|Exception reported without exact architectural state — no longer standard|

Modern processors maintain **precise exceptions**: when an exception is signaled, all instructions before the faulting instruction are committed, and all after are squashed.

---

### Speculative Execution and Security

Speculation creates a timing side channel: even if a speculative result is discarded at the architectural level, its effects on microarchitectural state (cache lines loaded, TLB entries populated, branch predictor state updated) may persist and be measurable.

#### Spectre (CVE-2017-5753, CVE-2017-5715)

Exploits branch prediction speculation to transiently execute code that reads memory the attacker should not be able to access.

```
; Victim code (C equivalent):
if (index < array_size) {          // branch speculatively taken
    y = array2[array1[index] * 256]; // secret-dependent cache load
}
// Even if index >= array_size, the load executes speculatively
// Cache timing reveals array1[index] — a secret value
```

The architectural result is discarded (branch mispredicted), but the cache line loaded by the speculative access persists. An attacker measures cache access time to infer the secret byte.

**Variants:**

|Variant|Speculation Type|Exploit Mechanism|
|---|---|---|
|Spectre v1|Bounds check bypass|Conditional branch prediction|
|Spectre v2|Branch target injection|Indirect branch target poisoning|
|Spectre v3 (Meltdown)|Rogue data cache load|Exception-deferred speculative load|
|Spectre-RSB|Return stack buffer|Corrupting return address predictor|

#### Meltdown (CVE-2017-5754)

Exploits the window between a faulting load and the delivery of the exception. A kernel memory read that would fault is executed speculatively; its result is used to index a cache before the fault is handled.

```
; Attacker speculatively reads kernel address
mov rax, [kernel_address]    ; will fault — but executes speculatively
mov rbx, [user_array + rax * 4096]  ; cache side-channel encode
; fault delivered — architectural result discarded
; cache state reveals kernel byte
```

Meltdown was largely mitigated by **Kernel Page Table Isolation (KPTI)**: removing kernel mappings from user-space page tables eliminates the kernel address from the speculative access window.

#### Spectre Mitigations

|Mitigation|Mechanism|Cost|
|---|---|---|
|Retpoline|Replaces indirect branches with a return-based trampoline that does not speculate|Moderate IPC loss on indirect-heavy code|
|IBRS / IBPB|Microcode fences that flush branch predictor state on privilege transitions|Significant overhead on syscall-heavy workloads|
|LFENCE serialization|Prevents speculative execution past the fence|High: serializes instruction stream|
|Site isolation (browsers)|Separates cross-origin processes so shared memory timer is unavailable|Architectural; breaks some web APIs|
|eIBRS (Enhanced IBRS)|Always-on IBRS with reduced per-transition cost|Lower overhead than IBRS|

[Inference] Mitigation effectiveness varies by workload and microarchitecture. No mitigation has been demonstrated to eliminate all speculative side-channel risks for all attack models. Processor behavior is not guaranteed.

---

### Speculation in the Full Out-of-Order Pipeline

<svg viewBox="0 0 680 310" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <rect width="680" height="310" fill="#1e1e2e"/> <!-- Stage boxes --> <!-- Fetch --> <rect x="10" y="50" width="90" height="40" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/> <text x="55" y="66" fill="#89b4fa" text-anchor="middle">Fetch</text> <text x="55" y="80" fill="#585b70" text-anchor="middle" font-size="9">+ BP predict</text> <!-- Decode --> <rect x="120" y="50" width="90" height="40" rx="4" fill="#313244" stroke="#89b4fa" stroke-width="1.5"/> <text x="165" y="66" fill="#89b4fa" text-anchor="middle">Decode</text> <text x="165" y="80" fill="#585b70" text-anchor="middle" font-size="9">+ Rename</text> <!-- Dispatch / Issue --> <rect x="230" y="50" width="90" height="40" rx="4" fill="#313244" stroke="#cba6f7" stroke-width="1.5"/> <text x="275" y="66" fill="#cba6f7" text-anchor="middle">Issue</text> <text x="275" y="80" fill="#585b70" text-anchor="middle" font-size="9">Reservation Stn</text> <!-- Execute --> <rect x="340" y="50" width="90" height="40" rx="4" fill="#313244" stroke="#fab387" stroke-width="1.5"/> <text x="385" y="66" fill="#fab387" text-anchor="middle">Execute</text> <text x="385" y="80" fill="#585b70" text-anchor="middle" font-size="9">OoO, speculative</text> <!-- Writeback --> <rect x="450" y="50" width="90" height="40" rx="4" fill="#313244" stroke="#fab387" stroke-width="1.5"/> <text x="495" y="66" fill="#fab387" text-anchor="middle">Writeback</text> <text x="495" y="80" fill="#585b70" text-anchor="middle" font-size="9">→ ROB + phys reg</text> <!-- Commit --> <rect x="560" y="50" width="90" height="40" rx="4" fill="#313244" stroke="#a6e3a1" stroke-width="2"/> <text x="605" y="66" fill="#a6e3a1" text-anchor="middle">Commit</text> <text x="605" y="80" fill="#585b70" text-anchor="middle" font-size="9">in-order, arch. state</text> <!-- Flow arrows --> <line x1="100" y1="70" x2="120" y2="70" stroke="#585b70" stroke-width="1.5" marker-end="url(#aflow)"/> <line x1="210" y1="70" x2="230" y2="70" stroke="#585b70" stroke-width="1.5" marker-end="url(#aflow)"/> <line x1="320" y1="70" x2="340" y2="70" stroke="#585b70" stroke-width="1.5" marker-end="url(#aflow)"/> <line x1="430" y1="70" x2="450" y2="70" stroke="#585b70" stroke-width="1.5" marker-end="url(#aflow)"/> <line x1="540" y1="70" x2="560" y2="70" stroke="#585b70" stroke-width="1.5" marker-end="url(#aflow)"/> <!-- ROB spans execute → commit --> <rect x="340" y="110" width="310" height="28" rx="4" fill="#1a2a3a" stroke="#cba6f7" stroke-width="1.5"/> <text x="495" y="129" fill="#cba6f7" text-anchor="middle">Reorder Buffer — maintains program order; gates commit</text> <!-- BP feedback --> <path d="M605,90 Q605,160 55,160 Q55,130 55,90" fill="none" stroke="#89b4fa" stroke-width="1.5" stroke-dasharray="5,3" marker-end="url(#abp)"/> <text x="330" y="178" fill="#89b4fa" text-anchor="middle" font-size="10">branch resolved at Execute → update BP; flush if mispredicted</text> <!-- Rename map feedback on flush --> <path d="M605,50 Q630,30 165,30 Q165,50 165,50" fill="none" stroke="#f38ba8" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#afls)"/> <text x="390" y="24" fill="#f38ba8" text-anchor="middle" font-size="10">flush: restore RAT checkpoint → redirect fetch</text> <!-- Speculative zone bracket --> <line x1="230" y1="100" x2="550" y2="100" stroke="#fab387" stroke-width="1" stroke-dasharray="3,2"/> <line x1="230" y1="100" x2="230" y2="108" stroke="#fab387" stroke-width="1"/> <line x1="550" y1="100" x2="550" y2="108" stroke="#fab387" stroke-width="1"/> <text x="390" y="108" fill="#fab387" text-anchor="middle" font-size="10">speculative zone — results not yet committed</text> <!-- Notes -->

<text x="340" y="220" fill="#585b70" text-anchor="middle" font-size="11">Speculative state lives in the ROB and physical register file.</text> <text x="340" y="238" fill="#585b70" text-anchor="middle" font-size="11">Architectural state is updated only at Commit, in program order.</text> <text x="340" y="256" fill="#585b70" text-anchor="middle" font-size="11">On flush: ROB entries after the faulting point are squashed,</text> <text x="340" y="274" fill="#585b70" text-anchor="middle" font-size="11">physical registers are freed, and the RAT is restored.</text>

<defs> <marker id="aflow" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#585b70"/> </marker> <marker id="abp" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#89b4fa"/> </marker> <marker id="afls" markerWidth="6" markerHeight="6" refX="6" refY="3" orient="auto"> <path d="M0,0 L6,3 L0,6 Z" fill="#f38ba8"/> </marker> </defs> </svg>

---

### Costs and Limits of Speculation

|Cost|Description|
|---|---|
|Misprediction penalty|All work on the wrong path is discarded; pipeline must be refilled|
|Energy waste|Speculative instructions consume power even when squashed|
|ROB pressure|Deep speculation requires large ROBs; wider windows have diminishing returns|
|Security surface|Every speculated memory access is a potential side-channel leak|
|Complexity|Flush, recovery, and checkpoint logic is among the most complex hardware in a modern core|

The fundamental limit on speculative benefit is the **independence of future instructions from the uncertain event**: if the work that can be overlapped with the uncertain computation is limited, speculation cannot improve throughput beyond that bound.

---

**Conclusion:** Speculative execution is the mechanism by which modern processors extract instruction-level parallelism in the presence of control and data uncertainty. Its correctness depends on the ROB enforcing in-order commit, precise exceptions, and atomic rollback of all speculative state on misspeculation. Its security implications stem from the gap between architectural correctness (speculative results discarded) and microarchitectural observability (cache and predictor state not rolled back), a gap that Spectre-class attacks exploit directly.

**Next Steps:** Proceed to Tomasulo's Algorithm for the full out-of-order issue and forwarding mechanism that speculative execution builds upon, or to Hardware Security (Spectre/Meltdown class) in Module 15 for a deeper treatment of the attack taxonomy and mitigation landscape.

---

