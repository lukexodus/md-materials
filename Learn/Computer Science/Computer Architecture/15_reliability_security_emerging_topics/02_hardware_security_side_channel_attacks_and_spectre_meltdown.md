## Hardware Security: Side-Channel Attacks and Spectre/Meltdown


---

### Side-Channel Attacks: Conceptual Foundation

A side-channel attack extracts secret information not by breaking the cryptographic or logical structure of a system, but by observing physically observable byproducts of computation — timing, power consumption, electromagnetic emissions, acoustic noise, or cache state. The secret never leaves the system through an intended channel; it leaks through an unintended physical or microarchitectural one.

The attack surface is the gap between the abstract model of computation (instructions execute sequentially, memory accesses are uniform, processes are isolated) and the physical implementation (caches, pipelines, branch predictors, power rails, and speculative execution units that violate every one of those abstractions).

---

### Taxonomy of Side Channels

**Timing attacks**: The most broadly applicable class. If a computation's execution time varies as a function of a secret value, an observer who can measure time with sufficient precision can recover the secret. Kocher (1996) demonstrated this against RSA private key operations — conditional branches and data-dependent memory accesses in the modular exponentiation routine caused measurable timing variation.

The requirement for exploitability: the attacker must be able to (a) trigger the target computation, (b) measure elapsed time with adequate resolution, and (c) distinguish timing differences that correlate with secret bits. On modern hardware, `rdtsc` / `rdtscp` (x86) and `clock_gettime` provide sub-nanosecond resolution, which is more than sufficient.

**Cache side-channels**: The most practically exploited class on modern processors, because cache state is shared between processes (even across privilege levels in some configurations) and is directly observable via timing.

The cache creates a covert channel: if a secret-dependent access loads address $A$ into cache, and an attacker can probe whether $A$ is cached, the attacker learns whether the access occurred. Since cached access is ~4 cycles and uncached access is ~200+ cycles, the signal is strong.

**Power analysis**: Simple Power Analysis (SPA) reads power traces directly; Differential Power Analysis (DPA, Kocher et al. 1999) applies statistical methods to recover keys from many traces. Primarily relevant to embedded systems and smart cards where physical access to the power rail exists. Not directly applicable to remote attacks, but relevant to side-channels on shared cloud hardware.

**Electromagnetic (EM) analysis**: Similar to power analysis; measures EM emissions from the chip. TEMPEST is the classified NSA program (now partially declassified) covering EM side-channels from display signals, keyboards, and computational hardware.

**Acoustic attacks**: Demonstrated by Genkin, Shamir, and Tromer (2014) — recovering RSA keys from the acoustic noise produced by capacitors and inductors in a laptop's voltage regulation circuitry during decryption operations.

**Rowhammer**: A DRAM-level attack, not a cache side-channel. Repeated reads to the same DRAM row cause capacitive coupling to adjacent rows, flipping bits in neighboring rows. Not a passive observation — it actively corrupts memory. Demonstrated to escalate privilege by flipping page table entry bits.

---

### Cache Timing Attacks: Mechanics

**FLUSH+RELOAD**: The foundational technique for Spectre/Meltdown exploitation.

1. **Flush**: Attacker evicts a target cache line using `clflush` (x86) or by accessing enough memory to displace it from the LLC.
2. **Victim executes**: A computation that may or may not access the target address, depending on a secret value.
3. **Reload**: Attacker times access to the target address. Fast access (~4 cycles) → victim accessed it (cache hit). Slow access (~200 cycles) → victim did not access it (cache miss).

This requires the attacker and victim to share a physical page (e.g., a shared library, or co-location in a VM with memory deduplication). When shared memory is unavailable, **PRIME+PROBE** is used instead:

1. **Prime**: Attacker fills specific cache sets with its own data.
2. **Victim executes**: Evicts attacker's lines if it accesses the same cache set.
3. **Probe**: Attacker re-accesses its own lines. Slow access → victim evicted them (victim accessed that set).

PRIME+PROBE does not require shared memory and works across VM boundaries in cloud environments.

**Eviction set construction**: The attacker must identify which virtual addresses map to the target cache set. In a direct-mapped or set-associative cache with known geometry (set count $S$, associativity $W$), addresses that differ by $S \times \text{cache_line_size}$ alias to the same set. Constructing an eviction set of size $W$ for the target set suffices to evict any line in that set.

---

### Spectre and Meltdown: Speculative Execution Vulnerabilities

Spectre (Kocher et al., 2018) and Meltdown (Lipp et al., 2018) are a class of vulnerabilities that exploit CPU speculative execution to transiently access memory that is architecturally forbidden, then exfiltrate the result through a cache side-channel.

The key insight: the CPU's security model is defined architecturally (what the ISA commits to), but speculative execution operates microarchitecturally (before the ISA commitment). Instructions executed speculatively can read memory they are not architecturally permitted to read; although their results are squashed before being committed to architectural state, the cache effects of those speculative accesses persist.

The general attack model:

```
1. Attacker prepares a covert channel (FLUSH+RELOAD array).
2. Attacker induces the CPU to speculatively execute a sequence
   that reads secret data into a register.
3. Speculative code uses the secret as an index into the FLUSH+RELOAD
   array, causing a cache-side-effect proportional to the secret value.
4. Speculation is squashed — no architectural state changes.
5. Attacker probes the FLUSH+RELOAD array. The cache pattern reveals
   the secret value.
```

The two diagrams below show the speculative access window and the covert channel encoding side by side.---

### Meltdown (CVE-2017-5754)

Meltdown exploits a specific microarchitectural property: on affected Intel CPUs (pre-2019 and some others), the permission check for a memory access (kernel vs. user page) was not enforced before the load result was forwarded to dependent speculative instructions.

**Attack sequence (variant: rogue data cache load)**:

```c
// Attacker code running in user space
raise_exception:
    rbx = probe_array[kernel_memory[target_addr] * 4096];
    // ↑ This load of kernel_memory[target_addr] is:
    //   - architecturally illegal (kernel page, user mode)
    //   - but speculatively executed before the fault is raised
    //   - result forwarded to the index computation
    //   - probe_array[secret * 4096] is speculatively loaded
    //   - fault fires → instruction retired → architectural state clean
    //   - but probe_array[secret * 4096] is NOW IN CACHE
```

After the exception is caught (via signal handler or exception handler), the attacker performs FLUSH+RELOAD on `probe_array`. The cached slot reveals `secret`.

**Why it worked**: Transient execution — the window between a load's data becoming available and the associated permission check completing — allowed the secret to propagate to dependent speculative instructions. The L1 data cache does not gate forwarding on the TLB permission bits in these implementations.

**Why it does not work on some CPUs**: AMD CPUs were found not to speculatively forward the result of an access that would raise a page fault — the permission check was on the critical path for data forwarding. ARM Cortex-A75 was vulnerable; most ARM cores were not.

**Mitigation — KPTI (Kernel Page Table Isolation)**: Removes kernel mappings from the user-space page table entirely. Two separate page table hierarchies are maintained: one for user mode (containing only user mappings and a minimal trampoline for syscall entry), one for kernel mode (containing all mappings). On every user↔kernel transition, `CR3` is reloaded with the appropriate root page table. This eliminates the speculative kernel-memory access because the kernel pages are simply not mapped in user mode.

KPTI cost: each system call requires two `CR3` writes (flush TLB), adding ~100–400 cycles of overhead per syscall on early implementations. PCID (Process Context Identifiers) was used to avoid full TLB flushes — different ASIDs for user and kernel tables allow TLB entries to be tagged and selectively retained.

---

### Spectre (CVE-2017-5753, CVE-2017-5715)

Spectre is harder to mitigate than Meltdown because it exploits the CPU's branch prediction and speculative execution in a way that is fundamentally entangled with performance. Unlike Meltdown (a specific implementation bug), Spectre is closer to a design property of any sufficiently aggressive out-of-order, speculative CPU.

**Variant 1 — Bounds Check Bypass (BCB)**:

The attacker trains the branch predictor to predict a bounds check as "branch not taken" (i.e., index is in range), then supplies an out-of-bounds index. The CPU speculatively executes the array access with the poisoned index before the branch is resolved:

```c
// Victim code (e.g., OS kernel, hypervisor, JIT sandbox)
if (untrusted_index < array1_size) {          // bounds check
    uint8_t val = array1[untrusted_index];    // speculatively executed OOB
    temp = array2[val * 4096];                // cache side-effect
}
```

With `untrusted_index` chosen such that `array1[untrusted_index]` aliases a secret (e.g., a password in kernel memory or another process's heap), the speculative load reads the secret, and `array2[secret * 4096]` is cached. After the branch is resolved as mispredicted and the pipeline is flushed, the attacker probes `array2`.

**Branch predictor training**: The predictor is trained by repeatedly executing the bounds check with a valid in-bounds index until the predictor strongly predicts "not taken" (i.e., branch falls through to the array access). Then the out-of-bounds index is supplied. The predictor, trained on previous executions, predicts the branch will not be taken and speculatively executes the body.

**Variant 2 — Branch Target Injection (BTI)**:

Rather than exploiting a conditional branch predictor, Variant 2 targets the indirect branch predictor (IBP) — the predictor for indirect calls and jumps (e.g., function pointers, vtable dispatch, `ret` predictions via the Return Stack Buffer).

The attacker poisones the branch target buffer (BTB) to redirect speculative execution of an indirect branch in the victim to an attacker-chosen gadget — a sequence of victim code that performs the secret-encoding memory access. The victim's indirect branch speculatively jumps to the gadget, performs the load, leaves the cache side-effect, then the CPU discovers the misprediction and squashes.

This variant can cross privilege boundaries: a user-space process can poison the BTB to influence speculative execution inside the kernel.

**Variant 3a/4 — Rogue System Register Read / Speculative Store Bypass**: Additional variants involving speculative reads of system registers and speculative bypassing of store-to-load forwarding disambiguation.

---

### Spectre Mitigations

Spectre mitigations form a layered response because no single mechanism addresses all variants.

**Retpoline (Return Trampoline)**: Replaces indirect branches with a construct that causes the CPU to speculatively execute an infinite `ret`-to-itself loop (consuming the RSB) rather than the attacker-poisoned target. The CPU's RSB (Return Stack Buffer) predicts the return target as the loop top, but `LFENCE` prevents the loop from making observable progress. The actual target is placed on the stack via a `call` immediately before the `ret`, so the architectural execution goes to the correct target while the speculative execution spins harmlessly.

```asm
; retpoline indirect call to *rax
    call    set_up_target
capture_spec:
    pause                   ; prevent port pressure
    lfence                  ; serialize (stop speculation past here)
    jmp     capture_spec    ; speculative loop
set_up_target:
    mov     [rsp], rax      ; overwrite return address with real target
    ret                     ; architectural: jump to rax
                            ; speculative: RSB predicts back to capture_spec
```

Retpoline requires recompiling all code — it is a compiler transformation, not a hardware patch. The Linux kernel, GCC, LLVM, and MSVC all implement retpoline (`-mindirect-branch=thunk` in GCC).

**IBRS (Indirect Branch Restricted Speculation)**: A microcode-added MSR that, when set, prevents indirect branch predictions trained in a lower-privilege mode from influencing speculative execution in a higher-privilege mode. Original IBRS required setting the MSR on every kernel entry — prohibitively expensive. Enhanced IBRS (eIBRS, available on post-2019 Intel CPUs) is a "set once" mode that permanently enables the restriction without per-context-switch overhead.

**STIBP (Single Thread Indirect Branch Predictors)**: Prevents sibling hyperthreads (SMT pairs) from influencing each other's indirect branch predictors. Required when two mutually distrusting contexts share a physical core via SMT.

**IBPB (Indirect Branch Predictor Barrier)**: A microcode instruction that flushes the BTB. Issued on context switches between mutually distrusting processes. Expensive (~4000 cycles on some implementations) [Inference — latency is microarchitecture-specific].

**Spectre V1 (bounds check bypass) mitigations**: No hardware fix. Mitigations are software-level:

- `array_index_nospec` (Linux kernel): forces the index to 0 if the bounds check fails, using a bitmask derived without a conditional branch. This makes the speculative access benign (accessing `array[0]` reveals no secret).
- `LFENCE` serialization: placing `LFENCE` after the bounds check prevents speculative execution of the array access until the branch is resolved. Intel specifies `LFENCE` as a speculative barrier in this context. Expensive if placed on every bounds check.

**Compiler-level**: `-fno-speculative-load-hardening` / SLH (Speculative Load Hardening, Clang) instruments loads to mask addresses with a value derived from speculation-state tracking.

---

### Microarchitectural Data Sampling (MDS) Variants

Post-Spectre, a family of related vulnerabilities was disclosed targeting CPU internal buffers rather than the cache:

|CVE|Name|Leaks from|
|---|---|---|
|CVE-2018-12126|MSBDS (Fallout)|Store buffer|
|CVE-2018-12127|MLPDS|Load port|
|CVE-2018-12130|MFBDS (ZombieLoad)|Fill buffer|
|CVE-2019-11091|MDSUM|Uncacheable memory sampling|
|CVE-2020-0549|CacheOut / L1DES|L1D cache (cross-privilege)|

**Common mechanism**: When a load encounters a fault or an assist (e.g., accessing a non-present page, a page undergoing A/D bit update, or a non-canonical address), the CPU may transiently forward stale data from internal buffers (store buffer, fill buffer, load port) to dependent speculative instructions — even if that stale data was placed there by a different security context (another hyperthread, a previous process, the kernel).

**Mitigation**: `VERW` instruction (normally used to verify segment write permission) was repurposed in microcode as a mechanism to flush the fill buffers on certain Intel microarchitectures. The OS issues `VERW` on every kernel-to-user or hypervisor-to-guest transition. Disabling SMT entirely eliminates the cross-hyperthread variant of these attacks at the cost of ~30–50% throughput reduction.

---

### Transient Execution: Unified Framework

Subsequent research (Canella et al. 2019, "A Systematic Evaluation of Transient Execution Attacks") formalized the attack class:

A transient execution attack requires three components:

1. **Trigger**: A condition that causes the CPU to execute instructions transiently — mispredicted branch, page fault, microcode assist, exception suppression.
2. **Disclosure gadget**: A sequence of transient instructions that reads a secret and encodes it into a microarchitectural covert channel (cache, TLB, port contention).
3. **Receive gadget**: Attacker code that decodes the covert channel (FLUSH+RELOAD, PRIME+PROBE, port timing).

The security model violated in all cases: the CPU's architectural isolation guarantee (memory protection, privilege levels) does not extend to microarchitectural state, which is shared across privilege boundaries within a physical core.

---

### Trusted Execution Environments and Side-Channels

TEEs (SGX, TrustZone, SEV) are specifically targeted by side-channel attacks because they are designed to protect code from a potentially malicious host OS — an unusually powerful adversary.

**SGX (Software Guard Extensions)**: Intel's enclave mechanism. The host OS controls scheduling, memory mapping, and I/O. A malicious OS can:

- Page the enclave (controlled-channel attack): selectively present/absent enclave pages, observing which pages fault on each step of the computation, reconstructing control flow with page granularity.
- Interrupt the enclave at precise points (Asynchronous Enclave Exit, AEX) and observe register state at each interrupt point.
- Monitor cache occupancy via PRIME+PROBE without shared memory.

SGX side-channel attacks have been demonstrated to recover AES keys, RSA keys, and neural network architectures from enclaves. Intel's response (SGX2) includes additional hardware mitigations, but the fundamental tension — that a TEE running on hardware controlled by an adversary faces an extremely high-capability attacker — remains unresolved.

**AMD SEV (Secure Encrypted Virtualization)**: Encrypts VM memory with per-VM keys managed by the AMD PSP (Platform Security Processor). The hypervisor cannot read VM memory contents but can still observe cache access patterns (PRIME+PROBE without decryption). SEV-SNP adds integrity protection (prevents hypervisor from mapping/swapping pages to induce controlled-channel attacks) but does not close cache timing channels.

---

### Defense Taxonomy

|Defense|Threat addressed|Level|Cost|
|---|---|---|---|
|KPTI|Meltdown (kernel memory)|OS|~5–30% syscall throughput|
|Retpoline|Spectre V2 (BTI)|Compiler|~1–5% (workload-dependent)|
|eIBRS|Spectre V2 (cross-privilege)|Microcode + OS|Minimal (post-2019 Intel)|
|STIBP|Spectre V2 (cross-SMT)|Microcode + OS|~2–10%|
|IBPB|Spectre V2 (cross-process)|Microcode + OS|~1–10% (per context switch)|
|`array_index_nospec`|Spectre V1|Source code|Per-site, minimal|
|`LFENCE` barriers|Spectre V1|Compiler/source|~1–5% if pervasive|
|`VERW` flush|MDS / ZombieLoad|Microcode + OS|~1–3% per kernel exit|
|SMT disable|MDS, Spectre V2 cross-HT|OS config|~30–50% throughput|
|Time resolution reduction|All timing attacks|OS / browser|Coarse — reduces but does not eliminate|

**Key Points**:

- Spectre V1 has no general hardware fix — it requires source-level or compiler-level intervention at every exploitable bounds check. The kernel has thousands of such sites; systematic auditing is ongoing.
- The fundamental mitigations for Spectre V2 (retpoline, eIBRS) operate by restricting which speculative paths the CPU can take, not by preventing cache side-channels from being observed. If a new gadget type is found that retpoline does not cover (e.g., RSB underflow, as in ret2spec), new mitigations must be layered.
- Post-2019 Intel microarchitectures (Ice Lake, Tiger Lake, and later) include eIBRS and TAA (TSX Asynchronous Abort) mitigations in hardware, substantially reducing the software overhead of Spectre V2 mitigations.
- The covert channel underlying nearly all transient execution attacks is the shared LLC. Proposals for partitioned caches (cache coloring, way-partitioning via Intel CAT — Cache Allocation Technology) can reduce the channel bandwidth but do not eliminate it because other microarchitectural state (TLB, port contention, ROB occupancy) provides alternative channels.
- Browser mitigations (reduced `performance.now()` resolution, disabled `SharedArrayBuffer` post-Spectre, then re-enabled with cross-origin isolation headers) represent an attempt to raise the measurement cost of FLUSH+RELOAD by degrading timer precision. An attacker with access to a `SharedArrayBuffer` can implement a high-resolution counter by having one thread count in a loop while another measures — timer precision reduction is not a robust defense.

**Conclusion**: Spectre/Meltdown represent a class break in the assumed security model of modern CPUs. The core assumption — that hardware enforces isolation between security domains — was shown to be violated at the microarchitectural level by the very mechanisms (speculation, caching, branch prediction) that deliver performance. Mitigations have been layered at microcode, OS, compiler, and application levels, but the fundamental tension between speculative execution and isolation is not resolved by any current production CPU. The research frontier (Spectre variants, MDS, LVI — Load Value Injection, SGX side-channels) continues to find new expressions of the same underlying gap.

---

