## Character Device Operations


Implementing file operations for character devices.

**Example:**

```assembly
// Character device read operation
// X0 = file structure
// X1 = user buffer
// X2 = count
// X3 = offset pointer

device_read:
        STP     X29, X30, [SP, #-64]!
        STP     X19, X20, [SP, #16]
        STP     X21, X22, [SP, #32]
        STP     X23, X24, [SP, #48]
        MOV     X29, SP
        
        MOV     X19, X0                     // File
        MOV     X20, X1                     // User buffer
        MOV     X21, X2                     // Count
        MOV     X22, X3                     // Offset
        
        // Get device structure from file private data
        LDR     X23, [X19, #FILE_PRIVATE_DATA]
        
        // Acquire read lock
        LDR     X0, [X23, #DEV_READ_LOCK]
        BL      mutex_lock
        
        // Check if data available
        LDR     X0, [X23, #DEV_BUFFER_HEAD]
        LDR     X1, [X23, #DEV_BUFFER_TAIL]
        CMP     X0, X1
        B.EQ    no_data_available
        
        // Calculate available data
        SUB     X24, X1, X0
        CMP     X24, X21
        CSEL    X24, X24, X21, LT           // min(available, count)
        
        // Copy to user space
        MOV     X0, X20                     // Destination (user)
        ADD     X1, X23, #DEV_BUFFER_DATA   // Source (kernel)
        LDR     X2, [X23, #DEV_BUFFER_HEAD]
        ADD     X1, X1, X2
        MOV     X2, X24                     // Size
        BL      copy_to_user
        CBNZ    X0, read_fault
        
        // Update buffer head
        LDR     X0, [X23, #DEV_BUFFER_HEAD]
        ADD     X0, X0, X24
        STR     X0, [X23, #DEV_BUFFER_HEAD]
        
        // Release lock
        LDR     X0, [X23, #DEV_READ_LOCK]
        BL      mutex_unlock
        
        // Return bytes read
        MOV     X0, X24
        LDP     X23, X24, [SP, #48]
        LDP     X21, X22, [SP, #32]
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #64
        RET

no_data_available:
        // Check if non-blocking
        LDR     W0, [X19, #FILE_FLAGS]
        TST     W0, #O_NONBLOCK
        B.NE    return_eagain
        
        // Wait for data
        LDR     X0, [X23, #DEV_READ_LOCK]
        BL      mutex_unlock
        
        LDR     X0, [X23, #DEV_WAIT_QUEUE]
        BL      wait_event_interruptible
        
        // Check for signal
        CBNZ    X0, interrupted
        
        // Retry read
        B       device_read

return_eagain:
        LDR     X0, [X23, #DEV_READ_LOCK]
        BL      mutex_unlock
        MOV     X0, #-11                    // -EAGAIN
        B       read_done

read_fault:
        LDR     X0, [X23, #DEV_READ_LOCK]
        BL      mutex_unlock
        MOV     X0, #-14                    // -EFAULT
        B       read_done

interrupted:
        MOV     X0, #-4                     // -EINTR
        B       read_done

read_done:
        LDP     X23, X24, [SP, #48]
        LDP     X21, X22, [SP, #32]
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #64
        RET
```

