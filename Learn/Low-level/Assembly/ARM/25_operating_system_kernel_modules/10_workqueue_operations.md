## Workqueue Operations


Workqueues allow deferring work to kernel threads.

**Example:**

```assembly
// Schedule work on system workqueue
// X0 = work structure pointer

schedule_work_item:
        STP     X29, X30, [SP, #-16]!
        MOV     X29, SP
        
        // Initialize work structure if needed
        LDR     X1, [X0, #WORK_FLAGS]
        TBNZ    X1, #WORK_INITIALIZED_BIT, work_ready
        
        // Initialize work
        BL      init_work
        
work_ready:
        // Schedule on system workqueue
        BL      schedule_work
        
        LDP     X29, X30, [SP], #16
        RET

// Work handler function
.global work_handler
.type work_handler, %function

work_handler:
        STP     X29, X30, [SP, #-32]!
        STP     X19, X20, [SP, #16]
        MOV     X29, SP
        
        MOV     X19, X0                     // Work structure
        
        // Get containing device structure
        LDR     X20, [X19, #WORK_DEVICE_OFFSET]
        
        // Acquire device lock
        LDR     X0, [X20, #DEVICE_LOCK_OFFSET]
        BL      mutex_lock
        
        // Perform deferred work
        MOV     X0, X20
        BL      do_deferred_work
        
        // Release lock
        LDR     X0, [X20, #DEVICE_LOCK_OFFSET]
        BL      mutex_unlock
        
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #32
        RET
```

