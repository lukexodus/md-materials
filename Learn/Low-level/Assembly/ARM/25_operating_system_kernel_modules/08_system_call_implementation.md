## System Call Implementation


Kernel modules can implement custom system calls or ioctl handlers.

**Example:**

```assembly
// Device ioctl handler
// X0 = file structure pointer
// X1 = command code
// X2 = user argument

device_ioctl:
        STP     X29, X30, [SP, #-48]!
        STP     X19, X20, [SP, #16]
        STP     X21, X22, [SP, #32]
        MOV     X29, SP
        
        MOV     X19, X0                     // File structure
        MOV     X20, X1                     // Command
        MOV     X21, X2                     // Argument
        
        // Dispatch based on command
        LDR     W0, =IOCTL_CMD_START
        CMP     W20, W0
        B.EQ    handle_start
        
        LDR     W0, =IOCTL_CMD_STOP
        CMP     W20, W0
        B.EQ    handle_stop
        
        LDR     W0, =IOCTL_CMD_GET_STATUS
        CMP     W20, W0
        B.EQ    handle_get_status
        
        LDR     W0, =IOCTL_CMD_SET_CONFIG
        CMP     W20, W0
        B.EQ    handle_set_config
        
        // Unknown command
        MOV     X0, #-22                    // -EINVAL
        B       ioctl_done

handle_start:
        MOV     X0, X19
        BL      device_start
        B       ioctl_done

handle_stop:
        MOV     X0, X19
        BL      device_stop
        B       ioctl_done

handle_get_status:
        // Allocate kernel buffer for status
        MOV     X0, #64
        MOV     X1, #0x20                   // GFP_KERNEL
        BL      kmalloc
        CBZ     X0, ioctl_nomem
        
        MOV     X22, X0                     // Save buffer
        
        // Get device status
        MOV     X0, X19
        MOV     X1, X22
        BL      get_device_status
        
        // Copy to user space
        MOV     X0, X21                     // User buffer
        MOV     X1, X22                     // Kernel buffer
        MOV     X2, #64                     // Size
        BL      copy_to_user
        CBNZ    X0, copy_failed
        
        // Free kernel buffer
        MOV     X0, X22
        BL      kfree
        
        MOV     X0, #0                      // Success
        B       ioctl_done

handle_set_config:
        // Allocate kernel buffer
        MOV     X0, #128
        MOV     X1, #0x20                   // GFP_KERNEL
        BL      kmalloc
        CBZ     X0, ioctl_nomem
        
        MOV     X22, X0
        
        // Copy from user space
        MOV     X0, X22                     // Kernel buffer
        MOV     X1, X21                     // User buffer
        MOV     X2, #128
        BL      copy_from_user
        CBNZ    X0, copy_failed
        
        // Apply configuration
        MOV     X0, X19
        MOV     X1, X22
        BL      set_device_config
        
        // Free buffer
        MOV     X0, X22
        BL      kfree
        
        MOV     X0, #0
        B       ioctl_done

copy_failed:
        MOV     X0, X22
        BL      kfree
        MOV     X0, #-14                    // -EFAULT
        B       ioctl_done

ioctl_nomem:
        MOV     X0, #-12                    // -ENOMEM
        B       ioctl_done

ioctl_done:
        LDP     X21, X22, [SP, #32]
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #48
        RET
```

