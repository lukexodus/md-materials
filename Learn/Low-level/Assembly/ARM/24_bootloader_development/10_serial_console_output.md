## Serial Console Output


Debug output is critical during bootloader development.

**Example:**

```assembly
// Simple UART output function
// X0 = null-terminated string address

uart_puts:
        STP     X29, X30, [SP, #-32]!
        STP     X19, X20, [SP, #16]
        
        LDR     X19, =UART_BASE
        MOV     X20, X0
        
puts_loop:
        LDRB    W0, [X20], #1
        CBZ     W0, puts_done
        
        // Wait for UART ready
wait_ready:
        LDR     W1, [X19, #UART_STATUS]
        TST     W1, #UART_TX_FULL
        B.NE    wait_ready
        
        // Send character
        STR     W0, [X19, #UART_DATA]
        
        B       puts_loop

puts_done:
        LDP     X19, X20, [SP, #16]
        LDP     X29, X30, [SP], #32
        RET
```

**Key Points:**

- Bootloaders execute from reset vector in Secure EL3
- Processor initialization must occur before any other operations
- External DRAM initialization is SoC-specific and requires careful timing configuration
- Translation tables should be set up before enabling MMU
- Cache maintenance is critical when transitioning between boot stages
- Secure boot verification should occur before executing any loaded code
- Exception level transitions require careful register configuration
- Device tree provides hardware information to the kernel in a standardized format
- **[Inference]** Production bootloaders typically implement fallback mechanisms for recovery from failures

