## Software Pipelining


Software pipelining overlaps multiple loop iterations by interleaving instructions from different iterations, maximizing resource utilization in loops with dependencies.

### Concept

Traditional loop execution completes iteration N before starting iteration N+1. Software pipelining starts iteration N+1 before N completes, overlapping independent operations.

### Stages: Prologue, Kernel, Epilogue

**Example** - Loop with load-compute-store pattern:

Original sequential:

```assembly
loop:
    LDR r0, [r1], #4     ; Load iteration N
    ADD r0, r0, #10      ; Compute iteration N
    STR r0, [r2], #4     ; Store iteration N
    SUBS r3, r3, #1
    BGT loop
```

Software pipelined:

```assembly
; Prologue: Prime the pipeline
    LDR r0, [r1], #4     ; Start iteration 0 load
    SUBS r3, r3, #1
    BLE epilogue
    
    LDR r4, [r1], #4     ; Start iteration 1 load
    ADD r0, r0, #10      ; Finish iteration 0 compute
    SUBS r3, r3, #1
    BLE epilogue_1

; Kernel: Steady state (overlapped iterations)
kernel:
    LDR r5, [r1], #4     ; Load iteration N+2
    ADD r4, r4, #10      ; Compute iteration N+1
    STR r0, [r2], #4     ; Store iteration N
    
    MOV r0, r4           ; Rotate registers
    MOV r4, r5
    
    SUBS r3, r3, #1
    BGT kernel

; Epilogue: Drain the pipeline
epilogue_1:
    ADD r4, r4, #10
    STR r0, [r2], #4
    
epilogue:
    STR r4, [r2], #4
```

### Modulo Scheduling

Modulo scheduling is a systematic software pipelining technique that schedules instructions into time slots modulo the initiation interval (II).

**Key Points:**

- Initiation Interval (II): Cycles between starting successive iterations
- Minimum II determined by resource constraints and recurrence cycles
- Instructions from different iterations occupy different time slots within II

**Example** - 3-stage pipeline with II=1:

```assembly
; Each cycle starts new iteration while completing previous ones
cycle_0:
    LDR r0, [r1], #4     ; Iteration N: stage 1
    ADD r4, r4, #10      ; Iteration N-1: stage 2  
    STR r8, [r2], #4     ; Iteration N-2: stage 3
```

### Register Rotation

Software pipelining requires multiple register versions for overlapped iterations:

```assembly
; Without rotation - needs many registers
LDR r0, [r1]    ; iter 0
LDR r1, [r1]    ; iter 1
LDR r2, [r1]    ; iter 2
; ...

; With rotation - reuse register names
; (some ARM cores support register renaming in hardware)
```

### Trade-offs

**Benefits:**

- Hides memory latency
- Increases instruction throughput
- Exploits instruction-level parallelism across iterations

**Costs:**

- Code size increase (prologue + epilogue)
- Register pressure (multiple live values)
- Complexity (difficult to hand-code, usually compiler-generated)

