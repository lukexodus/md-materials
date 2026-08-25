## Atomic Operations


Kernel modules use atomic operations for lock-free synchronization.

**Example:**

```assembly
// Atomic increment
// X0 = pointer to atomic variable
// Returns old value in X0

atomic_inc:
        MOV     X1, X0                      // Save address

inc_retry:
        LDAXR   W2, [X1]                    // Load-exclusive with acquire
        ADD     W3, W2, #1                  // Increment
        STLXR   W4, W3, [X1]                // Store-exclusive with release
        CBNZ    W4, inc_retry               // Retry if store failed
        
        MOV     W0, W2                      // Return old value
        RET

// Atomic compare-and-swap
// X0 = pointer to atomic variable
// X1 = old value (expected)
// X2 = new value
// Returns 1 if successful, 0 if failed

atomic_cmpxchg:
        MOV     X3, X0                      // Save address

cmpxchg_retry:
        LDAXR   W4, [X3]                    // Load-exclusive
        CMP     W4, W1                      // Compare with expected
        B.NE    cmpxchg_failed              // Mismatch, fail
        
        STLXR   W5, W2, [X3]                // Try to store new value
        CBNZ    W5, cmpxchg_retry           // Retry if exclusive failed
        
        MOV     X0, #1                      // Success
        RET

cmpxchg_failed:
        CLREX                               // Clear exclusive monitor
        MOV     X0, #0                      // Failure
        RET

// Atomic bit operations
// X0 = pointer to word
// X1 = bit number

atomic_set_bit:
        MOV     X2, X0
        MOV     X3, #1
        LSL     X3, X3, X1                  // Create bit mask

setbit_retry:
        LDAXR   X4, [X2]
        ORR     X4, X4, X3                  // Set bit
        STLXR   W5, X4, [X2]
        CBNZ    W5, setbit_retry
        
        RET

atomic_clear_bit:
        MOV     X2, X0
        MOV     X3, #1
        LSL     X3, X3, X1
        MVN     X3, X3                      // Invert mask

clrbit_retry:
        LDAXR   X4, [X2]
        AND     X4, X4, X3                  // Clear bit
        STLXR   W5, X4, [X2]
        CBNZ    W5, clrbit_retry
        
        RET

atomic_test_bit:
        LDR     X2, [X0]
        LSR     X2, X2, X1
        AND     X0, X2, #1
        RET
```

