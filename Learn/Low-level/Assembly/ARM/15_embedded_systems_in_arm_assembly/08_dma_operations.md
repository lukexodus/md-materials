## DMA Operations


Direct Memory Access (DMA) allows peripherals to transfer data to/from memory without CPU intervention, freeing the processor for other tasks and reducing power consumption.

### DMA Architecture

ARM-based microcontrollers typically include DMA controllers with multiple channels/streams, each configurable for different transfer types:

**Memory-to-memory:** Copy data between memory locations **Peripheral-to-memory:** ADC readings, UART reception **Memory-to-peripheral:** DAC output, UART transmission **Peripheral-to-peripheral:** [Inference: Less common, hardware-dependent]

DMA transfers can be:

- Single transfer: One data element per trigger
- Burst transfer: Multiple elements per trigger
- Circular mode: Automatic restart after completion

### DMA Configuration

```assembly
// Configure DMA stream for ADC to memory transfer
    // Enable DMA clock
    LDR     R0, =RCC_AHB1ENR
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<22)        // DMA2EN
    STR     R1, [R0]
    
    // Disable stream before configuration
    LDR     R0, =DMA2_Stream0_CR
    LDR     R1, [R0]
    BIC     R1, R1, #(1<<0)         // Clear EN bit
    STR     R1, [R0]
    
    // Wait until disabled
wait_disable:
    LDR     R1, [R0]
    TST     R1, #(1<<0)
    BNE     wait_disable
    
    // Configure peripheral address
    LDR     R0, =DMA2_Stream0_PAR
    LDR     R1, =ADC1_DR            // ADC data register
    STR     R1, [R0]
    
    // Configure memory address
    LDR     R0, =DMA2_Stream0_M0AR
    LDR     R1, =adc_buffer         // Destination buffer
    STR     R1, [R0]
    
    // Configure number of data items
    LDR     R0, =DMA2_Stream0_NDTR
    MOV     R1, #BUFFER_SIZE
    STR     R1, [R0]
    
    // Configure stream control
    LDR     R0, =DMA2_Stream0_CR
    LDR     R1, =(0<<25)            // Channel 0
    ORR     R1, R1, #(1<<10)        // Memory increment mode
    ORR     R1, R1, #(1<<8)         // Circular mode
    ORR     R1, R1, #(1<<4)         // Transfer complete interrupt
    ORR     R1, R1, #(1<<1)         // Direct mode error interrupt
    STR     R1, [R0]
```

### Starting DMA Transfer

```assembly
// Start DMA transfer
start_dma:
    LDR     R0, =DMA2_Stream0_CR
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<0)         // Set EN bit
    STR     R1, [R0]
    BX      LR
```

### DMA Interrupt Handling

```assembly
// DMA transfer complete interrupt handler
DMA2_Stream0_IRQHandler:
    PUSH    {LR}
    
    // Check transfer complete flag
    LDR     R0, =DMA2_LISR          // Low interrupt status register
    LDR     R1, [R0]
    TST     R1, #(1<<5)             // TCIF0 - Transfer complete
    BEQ     dma_error_check
    
    // Clear flag
    LDR     R0, =DMA2_LIFCR         // Low interrupt flag clear
    MOV     R1, #(1<<5)
    STR     R1, [R0]
    
    // Process received data
    BL      process_adc_buffer
    
    POP     {PC}
    
dma_error_check:
    // Check for errors
    LDR     R0, =DMA2_LISR
    LDR     R1, [R0]
    TST     R1, #(1<<3)             // TEIF0 - Transfer error
    BNE     dma_transfer_error
    
    POP     {PC}
```

### Memory-to-Memory DMA

```assembly
// Fast memory copy using DMA
dma_memcpy:
    // R0 = source, R1 = destination, R2 = size in words
    PUSH    {R4-R6, LR}
    MOV     R4, R0
    MOV     R5, R1
    MOV     R6, R2
    
    // Disable DMA stream
    LDR     R0, =DMA2_Stream1_CR
    LDR     R1, [R0]
    BIC     R1, R1, #(1<<0)
    STR     R1, [R0]
    
wait_dma_disable:
    LDR     R1, [R0]
    TST     R1, #(1<<0)
    BNE     wait_dma_disable
    
    // Configure source address (memory 0)
    LDR     R0, =DMA2_Stream1_M0AR
    STR     R4, [R0]
    
    // Configure destination (peripheral address used as memory)
    LDR     R0, =DMA2_Stream1_PAR
    STR     R5, [R0]
    
    // Configure transfer size
    LDR     R0, =DMA2_Stream1_NDTR
    STR     R6, [R0]
    
    // Configure for memory-to-memory
    LDR     R0, =DMA2_Stream1_CR
    LDR     R1, =(2<<16)            // Memory-to-memory mode
    ORR     R1, R1, #(2<<13)        // Memory size: 32-bit
    ORR     R1, R1, #(2<<11)        // Peripheral size: 32-bit
    ORR     R1, R1, #(1<<10)        // Memory increment
    ORR     R1, R1, #(1<<9)         // Peripheral increment
    ORR     R1, R1, #(1<<4)         // Transfer complete interrupt
    STR     R1, [R0]
    
    // Enable stream
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<0)
    STR     R1, [R0]
    
    // Wait for completion (polling version)
wait_dma_complete:
    LDR     R0, =DMA2_LISR
    LDR     R1, [R0]
    TST     R1, #(1<<11)            // TCIF1
    BEQ     wait_dma_complete
    
    // Clear flag
    LDR     R0, =DMA2_LIFCR
    MOV     R1, #(1<<11)
    STR     R1, [R0]
    
    POP     {R4-R6, PC}
```

### Double Buffering

Double buffering allows continuous data acquisition while processing previous data:

```assembly
// Configure DMA with double buffering
    LDR     R0, =DMA2_Stream0_CR
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<18)        // Enable double buffer mode
    STR     R1, [R0]
    
    // Set memory 0 address
    LDR     R0, =DMA2_Stream0_M0AR
    LDR     R1, =buffer0
    STR     R1, [R0]
    
    // Set memory 1 address
    LDR     R0, =DMA2_Stream0_M1AR
    LDR     R1, =buffer1
    STR     R1, [R0]

// In interrupt handler, determine active buffer
DMA_double_buffer_handler:
    PUSH    {LR}
    
    // Check which buffer was filled
    LDR     R0, =DMA2_Stream0_CR
    LDR     R1, [R0]
    TST     R1, #(1<<19)            // CT bit indicates current target
    BNE     buffer1_filled
    
    // Buffer 0 was filled, process it while DMA fills buffer 1
    LDR     R0, =buffer0
    BL      process_buffer
    B       clear_flag
    
buffer1_filled:
    // Buffer 1 was filled, process it while DMA fills buffer 0
    LDR     R0, =buffer1
    BL      process_buffer
    
clear_flag:
    LDR     R0, =DMA2_LIFCR
    MOV     R1, #(1<<5)
    STR     R1, [R0]
    
    POP     {PC}
```

### DMA with Peripheral Control

```assembly
// UART transmission with DMA
uart_dma_transmit:
    // R0 = buffer address, R1 = length
    PUSH    {R4, R5, LR}
    MOV     R4, R0
    MOV     R5, R1
    
    // Disable DMA stream
    LDR     R0, =DMA1_Stream6_CR
    LDR     R1, [R0]
    BIC     R1, R1, #(1<<0)
    STR     R1, [R0]
    
wait_uart_dma_disable:
    LDR     R1, [R0]
    TST     R1, #(1<<0)
    BNE     wait_uart_dma_disable
    
    // Set memory address
    LDR     R0, =DMA1_Stream6_M0AR
    STR     R4, [R0]
    
    // Set peripheral address (USART2 data register)
    LDR     R0, =DMA1_Stream6_PAR
    LDR     R1, =USART2_DR
    STR     R1, [R0]
    
    // Set transfer count
    LDR     R0, =DMA1_Stream6_NDTR
    STR     R5, [R0]
    
    // Configure stream: channel 4, memory increment, memory->peripheral
    LDR     R0, =DMA1_Stream6_CR
    LDR     R1, =(4<<25)            // Channel 4 (USART2_TX)
    ORR     R1, R1, #(1<<10)        // Memory increment
    ORR     R1, R1, #(1<<6)         // Memory to peripheral direction
    ORR     R1, R1, #(1<<4)         // Transfer complete interrupt
    STR     R1, [R0]
    
    // Enable USART2 DMA transmit
    LDR     R0, =USART2_CR3
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<7)         // DMAT - DMA enable transmitter
    STR     R1, [R0]
    
    // Enable DMA stream
    LDR     R0, =DMA1_Stream6_CR
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<0)
    STR     R1, [R0]
    
    POP     {R4, R5, PC}
```

### DMA Priority and Arbitration

Multiple DMA streams may compete for bus access. Priority levels prevent starvation:

```assembly
// Set DMA stream priority
    LDR     R0, =DMA2_Stream0_CR
    LDR     R1, [R0]
    BIC     R1, R1, #(3<<16)        // Clear priority bits
    ORR     R1, R1, #(3<<16)        // Very high priority
    STR     R1, [R0]
    
    // Priority levels:
    // 00: Low
    // 01: Medium
    // 10: High
    // 11: Very high
```

### DMA Scatter-Gather [Inference]

Some ARM implementations support scatter-gather DMA using linked list descriptors, allowing complex multi-buffer transfers without CPU intervention. However, this is hardware-specific and not universally available across all ARM Cortex-M microcontrollers.

**Key Points**

- Real-time systems require deterministic timing, managed through interrupt priorities, context switching, and careful cycle counting
- Power management involves multiple sleep modes, clock gating, DVFS, and efficient code patterns to extend battery life
- Watchdog timers provide system reliability by detecting hangs and triggering resets, with periodic refresh required
- DMA offloads data transfers from CPU, supporting peripheral-to-memory, memory-to-peripheral, and memory-to-memory operations with interrupt-driven or circular modes

**Important related topics:** Exception handling and nested vectored interrupt controller (NVIC), memory protection units (MPU), cache management in Cortex-A/R series, peripheral bus architectures (AHB/APB), bootloader design for embedded systems.

---

