## Side-Channel Considerations


Side-channel attacks exploit information leaked through physical implementation rather than algorithmic weaknesses. ARM processors face various side-channel threats that require careful consideration in secure code.

### Timing Attacks

Execution time variations can leak information about secret data:

```assembly
// VULNERABLE: Timing varies based on secret value
vulnerable_compare:
    ldrb w2, [x0], #1              // Load byte from string 1
    ldrb w3, [x1], #1              // Load byte from string 2
    cmp w2, w3
    b.ne not_equal                 // Early exit leaks position of difference
    cbnz w2, vulnerable_compare
    // Strings equal
    mov x0, #1
    ret
not_equal:
    mov x0, #0
    ret

// CONSTANT-TIME: Always takes same time regardless of input
constant_time_compare:
    mov w4, #0                     // Accumulator for differences
compare_loop:
    ldrb w2, [x0], #1
    ldrb w3, [x1], #1
    eor w5, w2, w3                 // XOR difference
    orr w4, w4, w5                 // Accumulate all differences
    cbnz w2, compare_loop          // Continue to end of string
    cmp w4, #0                     // Check if any differences
    cset x0, eq                    // Set result
    ret
```

### Cache Timing Attacks

Cache state differences create timing variations exploitable in attacks like Spectre and Meltdown:

**[Inference]** Cache-based side channels occur when memory access patterns affect cache state, creating measurable timing differences. Attackers can potentially infer accessed addresses by measuring cache hit/miss timing.

```assembly
// Table lookup vulnerable to cache timing
vulnerable_table_lookup:
    ldr x2, =lookup_table
    ldrb w3, [x2, x0]              // Index with secret - cache state leaks info
    ret

// Constant-time alternative using masking
constant_time_lookup:
    ldr x2, =lookup_table
    mov x3, #0                     // Result accumulator
    mov x4, #0                     // Counter
lookup_loop:
    ldrb w5, [x2, x4]              // Load each entry
    cmp x4, x0                     // Compare with target index
    csel x3, x5, x3, eq            // Select if match (constant-time)
    add x4, x4, #1
    cmp x4, #256                   // Iterate through all entries
    b.lt lookup_loop
    mov x0, x3
    ret
```

### Speculative Execution Mitigations

Modern ARM processors implement speculation barriers to prevent speculative side-channel attacks:

```assembly
// Speculation barrier prevents speculative execution past this point
// Use after bounds check to prevent Spectre variant 1
bounds_check:
    cmp x0, x1                     // Check index < bound
    b.hs out_of_bounds             // Branch if out of bounds
    
    csdb                           // Conditional Speculation Barrier (ARMv8.5)
    // or
    dsb sy                         // Data Synchronization Barrier (older)
    isb                            // Instruction Synchronization Barrier
    
    // Safe to access array - speculation prevented
    ldr x2, [x3, x0, lsl #3]
    ret

out_of_bounds:
    mov x0, #-1
    ret
```

**[Inference]** The `csdb` instruction provides hardware-level protection against speculative execution vulnerabilities when placed after conditional branches, though exact implementation details and effectiveness depend on specific processor microarchitecture.

### Power Analysis Considerations

Current consumption variations during cryptographic operations can leak key material through Differential Power Analysis (DPA). **[Inference]** Countermeasures in software include randomizing operation order, adding dummy operations, and using masked implementations, though hardware-level protections are generally more effective.

```assembly
// Random delay insertion to mask timing
add_random_delay:
    // Read hardware random number generator
    mrs x0, RNDR                   // ARMv8.5 random number instruction
    and x0, x0, #0x1F              // Limit to reasonable range
delay_loop:
    nop
    sub x0, x0, #1
    cbnz x0, delay_loop
    ret
```

