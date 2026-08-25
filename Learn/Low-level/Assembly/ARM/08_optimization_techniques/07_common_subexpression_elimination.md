## Common Subexpression Elimination


Common subexpression elimination (CSE) identifies repeated calculations and stores the result for reuse, reducing redundant computation and register pressure.

**Manual CSE in assembly:** When the same calculation appears multiple times, compute once and store in a register:

**Example:**

```asm
; Without CSE - redundant calculations
LDR r0, [r4, #8]
ADD r1, r0, #10
MUL r1, r1, r2
STR r1, [r5]

LDR r0, [r4, #8]        ; Redundant load
ADD r3, r0, #10         ; Redundant calculation
MUL r3, r3, r6
STR r3, [r7]

; With CSE - calculate once, reuse
LDR r0, [r4, #8]
ADD r1, r0, #10         ; Common subexpression computed once
MUL r2, r1, r2          ; Use r1
STR r2, [r5]
MUL r3, r1, r6          ; Reuse r1
STR r3, [r7]
```

**Loop invariant code motion:** Move calculations that don't change between loop iterations outside the loop:

```asm
; Inefficient - calculation inside loop
loop:
    LDR r0, [r4], #4
    LDR r1, =constant
    ADD r1, r1, r5      ; Loop invariant - doesn't change
    MUL r0, r0, r1
    STR r0, [r6], #4
    SUBS r3, r3, #1
    BNE loop

; Optimized - move invariant outside
LDR r1, =constant
ADD r1, r1, r5          ; Computed once before loop
loop:
    LDR r0, [r4], #4
    MUL r0, r0, r1      ; Use precomputed value
    STR r0, [r6], #4
    SUBS r3, r3, #1
    BNE loop
```

**Address calculation reuse:**

```asm
; Calculate base address once
LDR r0, =array_base
ADD r0, r0, r1, LSL #2  ; base + offset

; Reuse for multiple accesses
LDR r2, [r0]            ; array[i]
LDR r3, [r0, #4]        ; array[i+1]
LDR r4, [r0, #8]        ; array[i+2]
```

