## Register Allocation Strategies


Register allocation assigns variables to limited physical registers to minimize memory accesses and maximize performance.

### ARM Register File

ARM provides 16 general-purpose registers (r0-r15):

- r0-r3: Argument passing and return values (caller-saved)
- r4-r11: Local variables (callee-saved)
- r12 (IP): Intra-procedure call scratch register
- r13 (SP): Stack pointer
- r14 (LR): Link register
- r15 (PC): Program counter

Effective registers for allocation: r0-r11 (12 registers)

### Local vs Global Allocation

**Local Allocation**: Within a basic block (straight-line code)

```assembly
; Simple assignment r0-r3 for temporaries
ADD r0, r1, r2
MUL r0, r0, r3
SUB r0, r0, r4
```

**Global Allocation**: Across basic blocks and function boundaries

```assembly
function:
    PUSH {r4-r7, lr}    ; Save callee-saved registers
    ; Use r4-r7 for important variables across calls
    BL other_function   ; r0-r3 may be clobbered
    ; r4-r7 still valid
    POP {r4-r7, pc}
```

### Live Range Analysis

A variable's live range spans from definition to last use. Overlapping live ranges require different registers:

**Example**:

```assembly
; Live ranges
ADD r0, r1, r2    ; r0 live starts
MUL r3, r4, r5    ; r3 live starts (r0 still live)
ADD r6, r0, r3    ; r0 last use (dies), r3 last use (dies), r6 live starts
SUB r7, r6, r8    ; r6 last use (dies)

; r0 and r3 need different registers (live ranges overlap)
; r0/r3 can reuse same registers as r6/r7 (ranges don't overlap)
```

### Graph Coloring Allocation

Register allocation modeled as graph coloring:

1. Build interference graph (nodes = variables, edges = overlapping live ranges)
2. Color graph with K colors (K = available registers)
3. Spill variables if graph not K-colorable

**Example** - Interference graph:

```
Variables: a, b, c, d
Interferences: a-b, b-c, c-d, a-c

Graph coloring with 3 registers (r0, r1, r2):
a -> r0
b -> r1  
c -> r2
d -> r0 (doesn't interfere with a)
```

### Spilling Strategies

When insufficient registers, spill variables to memory:

```assembly
; Register pressure - need 5 values, only 4 registers available
; Spill least-frequently-used variable (d)

    LDR r0, =a
    LDR r1, =b  
    LDR r2, =c
    ; d spilled to stack
    
    ADD r3, r0, r1
    MUL r3, r3, r2
    
    ; Reload d when needed
    LDR r4, [sp, #offset_d]
    SUB r3, r3, r4
```

**Spill Cost Metrics:**

- Usage frequency (spill infrequently-used variables)
- Loop nesting depth (avoid spilling in inner loops)
- Live range length (prefer spilling short-lived variables)

### Caller-Saved vs Callee-Saved Strategy

**Caller-Saved (r0-r3):**

- Fast for leaf functions (no preservation needed)
- Use for temporary values
- Assumed clobbered across function calls

**Callee-Saved (r4-r11):**

- Preserved across function calls
- Use for important variables in calling functions
- Require PUSH/POP overhead

**Example** - Register usage pattern:

```assembly
outer_function:
    PUSH {r4-r6, lr}
    MOV r4, r0        ; Save important arg in r4 (survives calls)
    MOV r5, #0        ; Counter in r5
    
loop:
    MOV r0, r4        ; Pass arg in r0 (caller-saved)
    BL inner_function ; r0-r3 clobbered
    ADD r5, r5, r0    ; r4-r5 still valid
    CMP r5, #100
    BLT loop
    
    MOV r0, r5        ; Return in r0
    POP {r4-r6, pc}
```

### Register Pressure Reduction

Techniques to reduce register demand:

**Value Recomputation:**

```assembly
; High pressure
LDR r0, =base
ADD r1, r0, #offset1
ADD r2, r0, #offset2
ADD r3, r0, #offset3

; Reduced pressure - recompute base
LDR r0, =base
ADD r1, r0, #offset1
; ... use r1 ...
LDR r0, =base      ; Recompute instead of keeping in register
ADD r2, r0, #offset2
```

**Memory Access Scheduling:**

```assembly
; Load values just-in-time rather than all upfront
LDR r0, [r1]
ADD r0, r0, #1
STR r0, [r1]       ; Store immediately to free r0

LDR r0, [r2]       ; Reuse r0 for next value
ADD r0, r0, #2
STR r0, [r2]
```

### Function-Specific Allocation

**Leaf Functions:** Can use caller-saved registers freely (no calls to preserve)

```assembly
leaf_function:
    ; Use r0-r3 aggressively, no PUSH/POP needed
    ADD r0, r0, r1
    MUL r0, r0, r2
    BX lr
```

**Non-Leaf Functions:** Strategically use callee-saved for persistence

```assembly
non_leaf:
    PUSH {r4-r7, lr}
    ; r4-r7 for values that survive multiple calls
    MOV r4, r0
    BL func1
    ADD r4, r4, r0
    BL func2  
    ADD r0, r4, r0
    POP {r4-r7, pc}
```

