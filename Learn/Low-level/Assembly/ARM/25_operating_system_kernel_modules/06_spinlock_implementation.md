## Spinlock Implementation


Modules use spinlocks for protecting critical sections in interrupt context.

**Example:**

```assembly
// Acquire spinlock with interrupts disabled
// X0 = spinlock address
// Returns previous interrupt state in X0

spin_lock_irqsave:
        STP     X29, X30, [SP, #-32]!
        STP     X19, X20, [SP, #16]
        MOV     X29, SP
        
        MOV     X19, X0                     // Save lock address
        
        // Save and disable interrupts
        MRS     X20, DAIF
        MSR     DAIFSet, #0x3               // Disable IRQ and FIQ
        
        // Try to acquire lock
spin_wait:
        // Load-exclusive
        LDAXR   W1, [X19]
        CBNZ    W1, spin_wait               // Lock held, retry
        
        // Try to set lock
        MOV     W2, #1
        STXR    W3, W2, [X19]
        CBNZ    W3, spin_wait               // Store failed, retry
        
        // Memory barrier
        DMB     ISH
        
        // Return saved interrupt state
        MOV     X0, X20
        
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #32
        RET

// Release spinlock and restore interrupts
// X0 = spinlock address
// X1 = saved interrupt state

spin_unlock_irqrestore:
        // Memory barrier
        DMB     ISH
        
        // Release lock
        STR     WZR, [X0]
        
        // Restore interrupt state
        MSR     DAIF, X1
        
        RET
```

