## Interrupt Handling


Kernel modules can register interrupt handlers that execute when hardware interrupts occur.

**Example:**

```assembly
// Interrupt handler for device
// X0 = IRQ number
// X1 = device structure pointer
// Returns IRQ_HANDLED (1) or IRQ_NONE (0)

.global device_irq_handler
.type device_irq_handler, %function

device_irq_handler:
        STP     X29, X30, [SP, #-48]!
        STP     X19, X20, [SP, #16]
        STP     X21, X22, [SP, #32]
        MOV     X29, SP
        
        MOV     X19, X1                     // Save device structure
        
        // Get device base address from structure
        LDR     X20, [X19, #DEV_BASE_OFFSET]
        
        // Read interrupt status register
        LDR     W21, [X20, #IRQ_STATUS_REG]
        
        // Check if this device generated the interrupt
        CBZ     W21, not_our_irq
        
        // Handle different interrupt types
        TBNZ    W21, #RX_IRQ_BIT, handle_rx_irq
        TBNZ    W21, #TX_IRQ_BIT, handle_tx_irq
        TBNZ    W21, #ERR_IRQ_BIT, handle_err_irq
        
        B       clear_irq

handle_rx_irq:
        // Process received data
        MOV     X0, X19
        BL      process_rx_data
        B       clear_irq

handle_tx_irq:
        // Handle transmit completion
        MOV     X0, X19
        BL      process_tx_complete
        B       clear_irq

handle_err_irq:
        // Handle error condition
        MOV     X0, X19
        BL      process_error
        B       clear_irq

clear_irq:
        // Clear interrupt status
        STR     W21, [X20, #IRQ_STATUS_REG]
        DSB     SY
        
        // Schedule tasklet for deferred processing
        MOV     X0, X19
        BL      schedule_tasklet
        
        MOV     X0, #1                      // IRQ_HANDLED
        LDP     X21, X22, [SP, #32]
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #48
        RET

not_our_irq:
        MOV     X0, #0                      // IRQ_NONE
        LDP     X21, X22, [SP, #32]
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #48
        RET

// Tasklet handler for bottom-half processing
.global device_tasklet
.type device_tasklet, %function

device_tasklet:
        STP     X29, X30, [SP, #-32]!
        STP     X19, X20, [SP, #16]
        MOV     X29, SP
        
        MOV     X19, X0                     // Device structure
        
        // Process data from ring buffer
        LDR     X20, [X19, #RING_BUFFER_OFFSET]
        
process_loop:
        // Check if ring buffer has data
        LDR     W0, [X20, #RING_HEAD]
        LDR     W1, [X20, #RING_TAIL]
        CMP     W0, W1
        B.EQ    processing_done
        
        // Get next item from ring
        MOV     X0, X20
        BL      ring_buffer_get
        CBZ     X0, processing_done
        
        // Process item
        MOV     X1, X19
        BL      process_item
        
        // Free item
        BL      kfree
        
        B       process_loop

processing_done:
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #32
        RET
```

