## Loop Unrolling


Loop unrolling reduces loop overhead by executing multiple iterations' worth of work per loop iteration, decreasing branch instructions and enabling better instruction scheduling.

### Basic Loop Unrolling

**Example** - Original loop:

```assembly
    MOV r0, #0        ; sum = 0
    MOV r1, #0        ; i = 0
    LDR r2, =array
    MOV r3, #100      ; count

loop:
    LDR r4, [r2, r1, LSL #2]
    ADD r0, r0, r4
    ADD r1, r1, #1
    CMP r1, r3
    BLT loop
```

**Example** - 4x unrolled:

```assembly
    MOV r0, #0
    MOV r1, #0
    LDR r2, =array
    MOV r3, #100

loop_unrolled:
    LDR r4, [r2, r1, LSL #2]
    LDR r5, [r2, r1, LSL #2 + 4]
    LDR r6, [r2, r1, LSL #2 + 8]
    LDR r7, [r2, r1, LSL #2 + 12]
    
    ADD r0, r0, r4
    ADD r0, r0, r5
    ADD r0, r0, r6
    ADD r0, r0, r7
    
    ADD r1, r1, #4
    CMP r1, r3
    BLT loop_unrolled
```

### Benefits

- Reduced branch overhead (75% fewer branches in 4x unroll)
- Better instruction-level parallelism (loads can overlap)
- More opportunities for instruction scheduling
- Reduced loop counter updates

### Handling Remainder Iterations

When loop count doesn't divide evenly by unroll factor:

```assembly
    MOV r3, #100
    AND r8, r3, #3      ; remainder = count & 3
    SUB r3, r3, r8      ; adjusted count for main loop

main_loop:
    ; 4x unrolled body
    ADD r1, r1, #4
    CMP r1, r3
    BLT main_loop

cleanup_loop:
    CMP r8, #0
    BEQ done
    LDR r4, [r2, r1, LSL #2]
    ADD r0, r0, r4
    ADD r1, r1, #1
    SUB r8, r8, #1
    B cleanup_loop

done:
```

### Optimal Unroll Factor

[Inference] Unroll factor depends on:

- Available registers (unrolling consumes more registers)
- Code cache size (excessive unrolling increases code size)
- Loop body complexity
- Typical loop iteration counts

Common unroll factors: 2x, 4x, 8x. Beyond 8x often shows diminishing returns due to code size and register pressure.

