## Instruction Cycle and Execution


Understanding how processors execute instructions helps optimize code and reason about performance characteristics.

### Classical Fetch-Decode-Execute Cycle

Processors execute instructions through a repeating cycle:

**Fetch**: The processor reads the instruction from memory at the address stored in the Program Counter (PC). The instruction is transferred from memory to the instruction register.

**Decode**: The control unit interprets the instruction encoding, identifying the operation, operands, and addressing modes. It generates control signals for subsequent stages.

**Execute**: The ALU or relevant functional unit performs the specified operation on the operands.

**Memory Access**: If the instruction requires memory access (load/store), the processor reads from or writes to memory at the calculated address.

**Writeback**: The result is written to the destination register or memory location. The PC is updated to point to the next instruction.

This cycle repeats continuously during program execution. Each cycle processes one instruction in a simple processor implementation.

### Pipelining

Modern ARM processors implement instruction pipelining, where multiple instructions occupy different stages simultaneously. While one instruction executes, the next instruction decodes, and another fetches.

Classical ARM pipeline stages:

**Fetch (F)**: Retrieve instruction from memory
**Decode (D)**: Interpret instruction and read registers
**Execute (E)**: Perform ALU operation or calculate address
**Memory (M)**: Access memory for load/store
**Writeback (W)**: Write result to register

**Example** pipeline execution:
```
Cycle:   1    2    3    4    5    6    7
Inst1:   F    D    E    M    W
Inst2:        F    D    E    M    W
Inst3:             F    D    E    M    W
Inst4:                  F    D    E    M    W
```

[Inference] Pipelining increases throughput—multiple instructions complete per cycle—though individual instruction latency remains multiple cycles. Ideal pipelining achieves one instruction completion per cycle in steady state.

### Pipeline Hazards

Pipelining encounters hazards that prevent the next instruction from executing in the following cycle:

**Data hazards** occur when an instruction depends on the result of a previous instruction still in the pipeline:
```
ADD r0, r1, r2        @ Cycle 1: F
SUB r3, r0, r4        @ Cycle 2: F, but needs r0 from ADD not yet available
```

**Solutions** include:
- **Stalling**: Delay the dependent instruction until the result is ready
- **Forwarding**: Route the result directly from execute/memory stage to the next instruction's execute stage, bypassing writeback
- **Instruction reordering**: Compiler or programmer rearranges independent instructions to separate dependent ones

**Control hazards** occur at branches where the next instruction address is unknown until the branch resolves:
```
CMP r0, #10
BEQ label             @ Branch target unknown until CMP completes
```

**Solutions** include:
- **Branch prediction**: [Inference] Guess the branch outcome and speculatively execute predicted path
- **Delayed branch slots**: Execute instruction(s) following the branch regardless of outcome
- **Pipeline flush**: Discard speculatively executed instructions if prediction was wrong

**Structural hazards** occur when hardware resources are insufficient for simultaneous instruction requirements. [Inference] ARM processors typically avoid structural hazards through resource duplication or scheduling constraints.

### Branch Prediction

Modern processors predict branch outcomes to maintain pipeline flow. [Inference] Predictors use various strategies:

**Static prediction**: Always predict taken or not-taken based on branch type (backward branches often taken in loops, forward branches often not taken).

**Dynamic prediction**: Track branch history and predict based on past behavior. Simple 2-bit saturating counters predict each branch individually. More sophisticated predictors use global history or correlation.

**Example** loop performance with prediction:
```
MOV r0, #0
MOV r1, #100
loop:
    ADD r0, r0, #1
    CMP r0, r1
    BNE loop          @ Predicted taken 99 times, not-taken once
```

[Inference] Correct predictions maintain full pipeline throughput. Mispredictions cause pipeline flushes, losing several cycles. Well-predicted loops execute efficiently; unpredictable branches cause performance problems.

### Conditional Execution and Predication

ARM's conditional execution avoids some branches entirely by making instruction execution dependent on condition flags:

```
CMP r0, r1
MOVGT r2, r0          @ Conditionally executed
MOVLE r2, r1          @ Conditionally executed
```

[Inference] Conditional instructions enter the pipeline and proceed through decode and execute stages, but writeback is suppressed if the condition is false. This avoids branch misprediction penalties for simple conditional operations but consumes pipeline bandwidth even when not executing.

[Inference] Conditional execution is most beneficial for short code sequences where branching overhead exceeds the cost of executing instructions conditionally. For longer sequences or highly predictable branches, conventional branching may be more efficient.

ARMv8 AArch64 removed most conditional execution, retaining only conditional select (CSEL) instructions and conditional branches, relying instead on improved branch prediction.

### Instruction Timing

Instruction execution time varies by operation complexity and pipeline state:

**Simple ALU operations** (ADD, SUB, AND, OR, etc.): [Inference] Typically 1 cycle in the execute stage, completing in 1 cycle throughput when pipelined.

**Shifts and rotates**: [Inference] Usually incorporated into other operations through the barrel shifter without additional cycles, or 1 cycle when standalone.

**Multiply instructions**: [Inference] Historically required multiple cycles (2-4 cycles) depending on operand values. Modern processors may complete multiplication in 1-2 cycles or pipeline multiplies for 1 cycle throughput.

**Division instructions**: [Inference] Significantly slower than multiplication, potentially requiring 10-20+ cycles. Software division may be competitive with hardware division for some processors.

**Memory access** (LDR, STR): [Inference] 1 cycle if data is in L1 cache, potentially 10-100+ cycles for cache misses reaching main memory. Load-use latency (cycles until loaded data is available) affects dependent instructions.

**Branches**: [Inference] 1 cycle when correctly predicted, 3-20+ cycles when mispredicted depending on pipeline depth and branch resolution point.

[Unverified] These timings are general characteristics that vary significantly across ARM processor implementations (Cortex-A, Cortex-R, Cortex-M series) and generations.

### Superscalar Execution

Advanced ARM processors implement superscalar execution, issuing multiple instructions per cycle. [Inference] The processor includes multiple execution units (ALUs, load/store units, branch units) that can operate in parallel.

**Example** dual-issue processor:
```
Cycle:   1    2    3
Inst1:   F    D    E      @ ALU operation
Inst2:   F    D    E      @ ALU operation (parallel with Inst1)
Inst3:        F    D      @ Load operation
```

[Inference] The processor analyzes instruction dependencies and resource requirements to determine which instructions can execute simultaneously. Out-of-order execution allows later independent instructions to execute before earlier dependent instructions complete.

These advanced features are largely invisible to assembly programmers but understanding them helps appreciate why instruction ordering and independence affect performance.

### Memory Ordering and Barriers

ARM processors may reorder memory accesses for performance, executing them out of program order when dependencies allow. [Inference] This optimization is generally safe for single-threaded code but can cause unexpected behavior in multi-threaded or memory-mapped I/O contexts.

Memory barrier instructions enforce ordering:

**DMB (Data Memory Barrier)**: Ensures memory accesses before the barrier are observed before accesses after the barrier.

**DSB (Data Synchronization Barrier)**: Ensures all memory accesses complete before subsequent instructions execute.

**ISB (Instruction Synchronization Barrier)**: Flushes pipeline and ensures subsequent instructions are fetched after the barrier.

```
STR r0, [r1]          @ Write data
DMB                   @ Ensure write completes
STR r2, [r3]          @ Write flag
```

These barriers are essential for synchronization primitives, device driver code, and any situation where memory access order is semantically significant.

### Cache Interaction

Cache organization significantly affects instruction execution performance. [Inference] The processor checks cache levels for both instruction and data accesses:

**Instruction cache (I-cache)**: Stores recently fetched instructions. Cache hits provide fast instruction fetch. Cache misses stall the pipeline while fetching from slower memory levels.

**Data cache (D-cache)**: Stores recently accessed data. Load hits return data quickly. Load misses stall dependent instructions. Store operations may buffer in write buffers.

### Cache Line Fills and Write Policies

Cache operates on cache lines (typically 32, 64, or 128 bytes). When a cache miss occurs, the processor fetches an entire cache line from the next memory level, not just the requested byte or word. [Inference] This exploits spatial locality—nearby addresses are often accessed soon after.

**Write-through cache**: Writes update both cache and main memory simultaneously. [Inference] This ensures memory consistency but increases write latency.

**Write-back cache**: Writes update only cache initially, marking the line as dirty. [Inference] The dirty line is written to main memory only when evicted. This reduces memory traffic but requires cache coherency protocols in multi-core systems.

**Write-combining buffer**: Accumulates multiple writes to adjacent addresses before committing them to memory. [Inference] This is particularly useful for memory-mapped I/O regions where burst writes are more efficient than individual writes.

### Cache Associativity

Cache associativity determines where a memory address can be stored:

**Direct-mapped cache**: Each memory address maps to exactly one cache line location. Simple and fast but suffers from conflicts when multiple frequently-accessed addresses map to the same line.

**N-way set-associative cache**: Each memory address can be stored in any of N cache lines within a specific set. [Inference] 4-way or 8-way associativity balances conflict reduction with lookup complexity.

**Fully associative cache**: Any memory address can be stored in any cache line. [Inference] Eliminates conflict misses but requires complex hardware to search all entries. Typically used only for small caches like TLBs.

[Inference] Understanding cache behavior helps explain why reordering data accesses or padding data structures can significantly impact performance, even when total work remains constant.

### Instruction Prefetching

Modern processors prefetch instructions ahead of current execution to hide memory latency. [Inference] Hardware prefetchers detect sequential access patterns and speculatively fetch upcoming cache lines.

**Sequential prefetch**: Automatically fetches the next sequential cache line when accessing instructions.

**Branch prediction-driven prefetch**: [Inference] Prefetches instructions from predicted branch targets.

Prefetching improves performance for predictable code flow but wastes memory bandwidth for unpredictable control flow. [Inference] Tight loops that fit in cache benefit maximally from prefetching and caching.

### Data Prefetching

ARM provides explicit prefetch instructions for data:

```
PLD [r0]              @ Prefetch data at address in r0
PLDW [r0]             @ Prefetch for write
```

[Inference] These are hints to the memory system—they never cause faults and may be ignored by the processor. Strategic prefetching can hide memory latency:

```
    LDR r1, [r0]          @ Current load
    PLD [r0, #64]         @ Prefetch next cache line
    @ Process r1...
    ADD r0, r0, #64
    LDR r1, [r0]          @ Likely cache hit due to prefetch
```

[Inference] Overusing prefetch can pollute cache with unneeded data or waste memory bandwidth. Effective prefetch requires understanding access patterns and memory latency.

### Load-Store Unit Operation

The load-store unit handles memory access instructions independently from ALU operations in superscalar processors. [Inference] Multiple loads/stores can be in flight simultaneously:

**Store buffer**: Holds pending stores that can complete out of order. [Inference] The processor doesn't wait for store completion before proceeding, hiding store latency.

**Load forwarding**: [Inference] If a load reads from an address with a pending store, the data forwards directly from the store buffer, avoiding a cache access.

**Example** load-store sequence:

```
STR r0, [r2]          @ Store enters store buffer
LDR r1, [r3]          @ Load proceeds independently
LDR r4, [r2]          @ May forward from store buffer if addresses match
```

[Inference] This allows loads and stores to execute out of program order when addresses don't conflict, increasing instruction throughput.

### Memory Access Latency

Memory access latency varies dramatically by location:

**L1 cache**: [Inference] ~1-4 cycles typical latency **L2 cache**: [Inference] ~10-20 cycles typical latency **L3 cache**: [Inference] ~20-40 cycles typical latency (if present) **Main memory (DRAM)**: [Inference] ~100-300 cycles typical latency **Page fault to disk**: [Inference] Millions of cycles

[Inference] The processor continues executing independent instructions during load latency until a dependent instruction requires the loaded value (load-use penalty).

**Example** showing load-use latency:

```
LDR r0, [r1]          @ Load starts, takes N cycles
ADD r2, r2, #1        @ Independent, executes during load
MUL r3, r3, r4        @ Independent, executes during load
ADD r5, r0, r6        @ Dependent on r0, stalls if load incomplete
```

Reordering code to separate loads from dependent instructions reduces stalls.

### Multi-Core Considerations

Modern ARM systems are multi-core, with each core having private L1 caches and shared L2/L3 caches. [Inference] This creates cache coherency challenges when multiple cores access the same memory.

**Cache coherency protocols**: [Inference] Hardware automatically maintains consistency between cores' caches, using protocols like MESI or MOESI. When one core writes to a cache line, other cores with copies are notified to invalidate or update their versions.

**False sharing**: Occurs when different cores access different variables that reside in the same cache line. [Inference] Each write invalidates the line in other cores' caches even though they access different data, causing performance degradation.

**Example** false sharing:

```c
struct {
    int counter1;     // Used by core 0
    int counter2;     // Used by core 1, but same cache line
} data;
```

[Inference] Padding structures to separate frequently-written fields onto different cache lines prevents false sharing.

### Atomic Operations

Multi-threaded code requires atomic operations for synchronization. ARM provides exclusive load/store instructions:

```
LDREX r0, [r1]        @ Exclusive load
@ Modify r0...
STREX r2, r0, [r1]    @ Exclusive store, r2=0 if successful
CMP r2, #0
BNE retry             @ Retry if store failed
```

**LDREX** marks a memory location for exclusive access. **STREX** succeeds only if no other core has accessed that location since the LDREX. [Inference] The processor monitors the address using cache coherency hardware.

This implements **Load-Linked/Store-Conditional** semantics for lock-free algorithms and mutex implementation.

ARMv8.1+ adds **atomic operations** like:

```
LDADD r0, r1, [r2]    @ Atomically: r1 = [r2], [r2] += r0
CAS r0, r1, [r2]      @ Compare-and-swap
```

[Inference] These execute atomically without explicit loops, potentially improving performance for contended synchronization.

### Pipeline Depth and Branch Misprediction Cost

Pipeline depth—the number of stages from fetch to writeback—directly affects branch misprediction penalty. [Inference] Deeper pipelines achieve higher clock frequencies but increase misprediction costs.

**Shallow pipeline** (5-8 stages): [Inference] Lower misprediction penalty (3-8 cycles), lower clock frequency

**Deep pipeline** (12-20+ stages): [Inference] Higher misprediction penalty (12-20+ cycles), higher clock frequency potential

**Example** comparing branches:

```
@ Predictable loop - low misprediction rate
MOV r0, #0
loop:
    ADD r0, r0, #1
    CMP r0, #1000
    BLT loop          @ 999 correct predictions, 1 misprediction

@ Unpredictable branch - 50% misprediction rate
LDR r0, [r1]
TST r0, #1
BEQ label             @ Depends on runtime data
```

[Inference] The predictable loop costs approximately (1000 instructions + 1 misprediction penalty), while unpredictable branches cost (instruction + 50% × misprediction penalty) on average.

### Instruction Fusion and Macro-op Fusion

Advanced processors detect common instruction sequences and fuse them into single operations internally. [Inference] This reduces pressure on pipeline resources.

**Example** commonly fused sequences:

```
CMP r0, #0            @ Compare and branch
BEQ label             @ May fuse into single operation

MOV r0, #value
@ Load immediate sequences may optimize internally
```

[Inference] Fusion is transparent to the programmer but can make certain instruction sequences unexpectedly efficient. Compilers sometimes generate code to exploit known fusion patterns.

### Execution Units and Instruction Dispatch

Superscalar processors contain multiple specialized execution units:

**Integer ALU units**: [Inference] Often 2-4 units for basic arithmetic and logical operations

**Complex integer unit**: [Inference] Handles multiplication, division, potentially at lower throughput

**Load-store units**: [Inference] Typically 1-2 units for memory operations

**Branch unit**: [Inference] Resolves branch conditions and calculates targets

**Floating-point/SIMD units**: [Inference] Dedicated units for FP and vector operations

[Inference] The instruction dispatch logic examines upcoming instructions and routes them to available execution units. Instructions compete for limited resources—having 4 ALU operations that can execute in parallel is beneficial, but 4 multiplies may bottleneck on a single multiply unit.

### Speculative Execution

Modern processors execute instructions speculatively before knowing they're definitely needed:

**Branch speculation**: Execute predicted branch path before confirming branch outcome. Discard results and restart if prediction was wrong.

**Memory disambiguation**: [Inference] Execute loads before knowing whether earlier store addresses conflict. Roll back if conflict detected.

**Example** speculative execution:

```
    CMP r0, #10
    BGE skip
    LDR r1, [r2]      @ Speculatively executes before BGE resolves
    ADD r3, r1, #5
skip:
    @ Continue...
```

[Inference] If BGE is predicted not-taken, the processor executes LDR and ADD before knowing the branch outcome. If prediction is correct, work completes earlier. If incorrect, speculative work is discarded.

[Inference] Speculative execution enables high performance but complicates security (as demonstrated by Spectre/Meltdown vulnerabilities) since speculative instructions can affect micro-architectural state like caches.

### Instruction Retirement and Reorder Buffer

Out-of-order processors use a reorder buffer to track in-flight instructions:

[Inference] Instructions execute out of program order based on operand availability and resource availability. However, instructions **retire** (commit results permanently) in program order to maintain precise architectural state for exceptions.

**Example** out-of-order execution:

```
Program order:
    LDR r0, [r1]      @ 1: Cache miss, long latency
    ADD r2, r3, r4    @ 2: Independent, executes immediately
    MUL r5, r6, r7    @ 3: Independent, executes immediately  
    ADD r8, r0, r9    @ 4: Depends on instruction 1, waits

Execution order: 2, 3, 1, 4
Retirement order: 1, 2, 3, 4 (program order)
```

[Inference] The reorder buffer allows execution flexibility while preserving program semantics and enabling precise exception handling.

### Exception and Interrupt Handling During Execution

Exceptions interrupt normal execution flow, requiring the processor to save state and transfer control to exception handlers:

**Precise exceptions**: The processor ensures all instructions before the exception complete, and no instructions after the exception have modified architectural state. [Inference] This requires flushing speculative work from the pipeline.

**Exception types**:

- **Synchronous exceptions**: Caused by executing instruction (undefined instruction, data abort, alignment fault)
- **Asynchronous exceptions (interrupts)**: Caused by external events (timer, peripheral)

When an exception occurs:

1. [Inference] The processor saves the PC and CPSR to exception-specific registers (LR_exception, SPSR_exception)
2. Switches to appropriate exception mode
3. [Inference] Updates PC to the exception vector address
4. Exception handler executes
5. Handler returns using special instruction (MOVS PC, LR or ERET in ARMv8), restoring saved state

**Example** exception vector table (ARMv7):

```
0x00000000: Reset
0x00000004: Undefined Instruction
0x00000008: Supervisor Call (SVC)
0x0000000C: Prefetch Abort
0x00000010: Data Abort
0x00000014: Reserved
0x00000018: IRQ (Interrupt Request)
0x0000001C: FIQ (Fast Interrupt Request)
```

### Performance Counters

ARM processors include performance monitoring units (PMU) with hardware counters tracking events:

[Unverified] Typical counters include:

- Cycle count
- Instruction count
- Cache hits/misses (I-cache, D-cache, L2, L3)
- Branch predictions/mispredictions
- Pipeline stalls
- Load/store unit events
- TLB hits/misses

These counters help developers measure and optimize performance, identifying bottlenecks like cache misses or branch mispredictions.

[Unverified] Accessing counters typically requires privileged mode, and configuration/read mechanisms are processor-specific.

### Power Management and Execution

Modern ARM processors implement dynamic power management affecting execution:

**Dynamic voltage and frequency scaling (DVFS)**: [Inference] Adjusts clock frequency and voltage based on workload, reducing power when high performance isn't needed but affecting instruction execution rate.

**Clock gating**: [Inference] Disables clock to idle execution units, saving power without affecting active units.

**Power domains**: [Inference] Individual cores or clusters can be powered down completely when unused, with wake latency when work arrives.

**WFI (Wait For Interrupt)** instruction: Puts the processor in low-power state until an interrupt occurs:

```
WFI                   @ Enter idle state
@ Execution resumes here after interrupt
```

[Inference] Understanding power states is important for embedded systems and helps explain why real-time measurements may show performance variations.

### Deterministic Execution Considerations

Some ARM processors (particularly Cortex-R series for real-time systems) emphasize deterministic execution:

[Inference] Features supporting determinism:

- Predictable cache behavior (or no cache)
- Tightly coupled memory (TCM) with guaranteed latency
- Simplified pipelines with predictable timing
- Disabled or controlled speculation

[Inference] Real-time software requires knowing worst-case execution time (WCET), making predictability more valuable than average-case performance.

**Key Points**

Instruction execution involves a sophisticated pipeline processing multiple instructions simultaneously through fetch, decode, execute, memory, and writeback stages. Pipelining increases throughput but introduces hazards requiring solutions like forwarding, stalling, or reordering. Branch prediction maintains pipeline flow for control instructions, with mispredictions causing significant penalties. ARM's conditional execution can avoid branches for simple conditional operations. Memory access interacts with a cache hierarchy where hits complete quickly but misses incur substantial latency. Modern superscalar processors execute multiple instructions per cycle using multiple execution units and out-of-order execution, though instructions retire in program order for correctness. Understanding these execution mechanisms—including cache behavior, speculation, atomic operations for multi-core systems, and performance monitoring—enables writing efficient assembly code and reasoning about performance characteristics. The complexity of modern processors means [Inference] actual behavior varies significantly across implementations, making performance measurement and profiling essential for optimization work.

---

