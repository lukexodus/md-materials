## Instruction Scheduling


Instruction scheduling reorders instructions to minimize pipeline stalls and maximize instruction-level parallelism without changing program semantics.

### Pipeline Hazards and Dependencies

ARM processors use multi-stage pipelines (fetch, decode, execute, memory, writeback). Hazards occur when consecutive instructions create dependencies:

**Data Hazards**: RAW (Read After Write), WAR (Write After Read), WAW (Write After Write)

**Example** - Poor scheduling with RAW hazard:

```assembly
ADD r0, r1, r2    ; r0 = r1 + r2
SUB r3, r0, r4    ; Stalls waiting for r0
```

**Example** - Optimized scheduling:

```assembly
ADD r0, r1, r2    ; r0 = r1 + r2
LDR r5, [r6]      ; Independent instruction (fills bubble)
MUL r7, r8, r9    ; Independent instruction
SUB r3, r0, r4    ; r0 now ready
```

### Load/Store Latency Management

Memory operations have higher latency than register operations. Schedule independent instructions between load and use:

```assembly
; Unoptimized
LDR r0, [r1]
ADD r2, r0, r3    ; Stalls 2-3 cycles

; Optimized
LDR r0, [r1]
ADD r4, r5, r6    ; Independent work
MUL r7, r8, r9    ; More independent work
ADD r2, r0, r3    ; Load completed
```

### Branch Delay Considerations

ARM uses branch prediction, but mispredictions cost cycles. On older ARM architectures without branch prediction, filling branch delay slots was critical:

```assembly
CMP r0, #10
BNE loop
ADD r1, r1, #1    ; May execute before branch completes
```

Modern ARM processors benefit from keeping branches predictable and minimizing branch-dependent chains.

### Dual-Issue and Superscalar Scheduling

Modern ARM cores (Cortex-A series) can issue multiple instructions per cycle. Scheduling should enable parallel execution:

```assembly
; Can dual-issue on some ARM cores
ADD r0, r1, r2    ; ALU operation
LDR r3, [r4]      ; Load operation (different execution unit)
```

