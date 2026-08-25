## Device Drivers


Device drivers serve as the interface between hardware peripherals and operating system or application software. ARM assembly is used in performance-critical driver sections, hardware initialization routines, and interrupt handlers where precise control and minimal latency are required.

### Memory-Mapped I/O Access

ARM peripherals communicate through memory-mapped registers, where specific memory addresses correspond to hardware control and status registers.

```assembly
// GPIO (General Purpose Input/Output) driver for ARM Cortex-M
// Example: STM32F4 GPIO registers
.equ GPIOA_BASE,    0x40020000
.equ GPIO_MODER,    0x00          // Mode register offset
.equ GPIO_OTYPER,   0x04          // Output type register offset
.equ GPIO_OSPEEDR,  0x08          // Output speed register offset
.equ GPIO_PUPDR,    0x0C          // Pull-up/pull-down register offset
.equ GPIO_IDR,      0x10          // Input data register offset
.equ GPIO_ODR,      0x14          // Output data register offset
.equ GPIO_BSRR,     0x18          // Bit set/reset register offset

// Initialize GPIO pin as output
// x0 = GPIO base address
// w1 = pin number (0-15)
gpio_init_output:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Configure pin mode as output (01 in MODER)
    ldr w2, [x0, #GPIO_MODER]
    mov w3, #0x3                   // Mask for 2 bits
    lsl w3, w3, w1, lsl #1         // Shift to pin position
    bic w2, w2, w3                 // Clear existing bits
    mov w3, #0x1                   // Output mode
    lsl w3, w3, w1, lsl #1
    orr w2, w2, w3                 // Set output mode
    str w2, [x0, #GPIO_MODER]
    
    // Configure as push-pull output (0 in OTYPER)
    ldr w2, [x0, #GPIO_OTYPER]
    mov w3, #1
    lsl w3, w3, w1
    bic w2, w2, w3                 // Clear bit for push-pull
    str w2, [x0, #GPIO_OTYPER]
    
    // Set high speed (10 in OSPEEDR)
    ldr w2, [x0, #GPIO_OSPEEDR]
    mov w3, #0x3
    lsl w3, w3, w1, lsl #1
    bic w2, w2, w3
    mov w3, #0x2                   // High speed
    lsl w3, w3, w1, lsl #1
    orr w2, w2, w3
    str w2, [x0, #GPIO_OSPEEDR]
    
    // No pull-up/pull-down (00 in PUPDR)
    ldr w2, [x0, #GPIO_PUPDR]
    mov w3, #0x3
    lsl w3, w3, w1, lsl #1
    bic w2, w2, w3                 // Clear for no pull-up/down
    str w2, [x0, #GPIO_PUPDR]
    
    ldp x29, x30, [sp], #16
    ret

// Set GPIO pin high
// x0 = GPIO base address
// w1 = pin number
gpio_set_high:
    mov w2, #1
    lsl w2, w2, w1                 // Create bit mask
    str w2, [x0, #GPIO_BSRR]       // Write to set register
    ret

// Set GPIO pin low
// x0 = GPIO base address
// w1 = pin number
gpio_set_low:
    mov w2, #1
    lsl w2, w2, w1
    lsl w2, w2, #16                // Reset bits in upper 16 bits
    str w2, [x0, #GPIO_BSRR]
    ret

// Read GPIO pin state
// x0 = GPIO base address
// w1 = pin number
// Returns: w0 = 0 or 1
gpio_read:
    ldr w2, [x0, #GPIO_IDR]
    lsr w2, w2, w1
    and w0, w2, #1
    ret

// Toggle GPIO pin
// x0 = GPIO base address
// w1 = pin number
gpio_toggle:
    stp x29, x30, [sp, #-16]!
    
    ldr w2, [x0, #GPIO_ODR]
    mov w3, #1
    lsl w3, w3, w1
    eor w2, w2, w3                 // XOR to toggle
    str w2, [x0, #GPIO_ODR]
    
    ldp x29, x30, [sp], #16
    ret
```

### Interrupt Handling

Interrupt handlers require precise timing and minimal overhead. ARM assembly allows direct control over interrupt entry, context saving, and hardware acknowledgment.

```assembly
// UART interrupt handler for ARM Cortex-A
.equ UART0_BASE,    0x10009000
.equ UART_DR,       0x00          // Data register
.equ UART_FR,       0x18          // Flag register
.equ UART_IMSC,     0x38          // Interrupt mask set/clear
.equ UART_RIS,      0x3C          // Raw interrupt status
.equ UART_MIS,      0x40          // Masked interrupt status
.equ UART_ICR,      0x44          // Interrupt clear register

.equ UART_FR_RXFE,  (1 << 4)      // Receive FIFO empty
.equ UART_FR_TXFF,  (1 << 5)      // Transmit FIFO full
.equ UART_INT_RX,   (1 << 4)      // Receive interrupt
.equ UART_INT_TX,   (1 << 5)      // Transmit interrupt

// Circular buffer structure
.equ BUFFER_SIZE,   256
.struct 0
rx_buffer:      .space BUFFER_SIZE
rx_head:        .word 0
rx_tail:        .word 0
rx_count:       .word 0
tx_buffer:      .space BUFFER_SIZE
tx_head:        .word 0
tx_tail:        .word 0
tx_count:       .word 0
.text

// UART interrupt handler
uart_irq_handler:
    // Save context (caller-saved registers)
    stp x0, x1, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x29, x30, [sp, #-16]!
    
    // Read interrupt status
    ldr x0, =UART0_BASE
    ldr w1, [x0, #UART_MIS]
    
    // Check for receive interrupt
    tst w1, #UART_INT_RX
    b.eq check_tx_interrupt
    
    // Handle receive interrupt
    bl uart_rx_handler
    
    // Clear receive interrupt
    mov w1, #UART_INT_RX
    str w1, [x0, #UART_ICR]

check_tx_interrupt:
    ldr x0, =UART0_BASE
    ldr w1, [x0, #UART_MIS]
    tst w1, #UART_INT_TX
    b.eq irq_exit
    
    // Handle transmit interrupt
    bl uart_tx_handler
    
    // Clear transmit interrupt
    mov w1, #UART_INT_TX
    str w1, [x0, #UART_ICR]

irq_exit:
    // Restore context
    ldp x29, x30, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x0, x1, [sp], #16
    eret                          // Exception return

// Receive handler - read data from UART into circular buffer
uart_rx_handler:
    ldr x0, =UART0_BASE
    ldr x1, =rx_buffer
    
rx_loop:
    // Check if FIFO has data
    ldr w2, [x0, #UART_FR]
    tst w2, #UART_FR_RXFE
    b.ne rx_done                  // Exit if FIFO empty
    
    // Check if buffer has space
    ldr w3, [x1, #rx_count]
    cmp w3, #BUFFER_SIZE
    b.ge rx_done                  // Exit if buffer full
    
    // Read byte from UART
    ldrb w4, [x0, #UART_DR]
    
    // Store in circular buffer
    ldr w5, [x1, #rx_head]
    add x6, x1, x5
    strb w4, [x6]
    
    // Update head pointer
    add w5, w5, #1
    and w5, w5, #(BUFFER_SIZE - 1)  // Wrap around
    str w5, [x1, #rx_head]
    
    // Increment count
    add w3, w3, #1
    str w3, [x1, #rx_count]
    
    b rx_loop

rx_done:
    ret

// Transmit handler - send data from circular buffer to UART
uart_tx_handler:
    ldr x0, =UART0_BASE
    ldr x1, =tx_buffer
    
tx_loop:
    // Check if buffer has data
    ldr w2, [x1, #tx_count]
    cbz w2, tx_done               // Exit if buffer empty
    
    // Check if UART FIFO has space
    ldr w3, [x0, #UART_FR]
    tst w3, #UART_FR_TXFF
    b.ne tx_done                  // Exit if FIFO full
    
    // Read byte from circular buffer
    ldr w4, [x1, #tx_tail]
    add x5, x1, x4
    ldrb w6, [x5]
    
    // Write to UART
    strb w6, [x0, #UART_DR]
    
    // Update tail pointer
    add w4, w4, #1
    and w4, w4, #(BUFFER_SIZE - 1)  // Wrap around
    str w4, [x1, #tx_tail]
    
    // Decrement count
    sub w2, w2, #1
    str w2, [x1, #tx_count]
    
    b tx_loop

tx_done:
    // If buffer empty, disable TX interrupt
    ldr w2, [x1, #tx_count]
    cbnz w2, tx_exit
    
    ldr x0, =UART0_BASE
    ldr w3, [x0, #UART_IMSC]
    bic w3, w3, #UART_INT_TX
    str w3, [x0, #UART_IMSC]

tx_exit:
    ret
```

### DMA (Direct Memory Access) Driver

DMA controllers transfer data between memory and peripherals without CPU intervention, improving throughput and reducing processor load.

```assembly
// DMA controller driver (simplified ARM DMA architecture)
.equ DMA_BASE,          0x40020000
.equ DMA_ISR,           0x00      // Interrupt status register
.equ DMA_IFCR,          0x04      // Interrupt flag clear register
.equ DMA_CCR,           0x08      // Channel configuration register
.equ DMA_CNDTR,         0x0C      // Channel number of data register
.equ DMA_CPAR,          0x10      // Channel peripheral address register
.equ DMA_CMAR,          0x14      // Channel memory address register

// DMA_CCR bits
.equ DMA_CCR_EN,        (1 << 0)  // Channel enable
.equ DMA_CCR_TCIE,      (1 << 1)  // Transfer complete interrupt enable
.equ DMA_CCR_HTIE,      (1 << 2)  // Half transfer interrupt enable
.equ DMA_CCR_TEIE,      (1 << 3)  // Transfer error interrupt enable
.equ DMA_CCR_DIR,       (1 << 4)  // Data transfer direction (0=periph->mem)
.equ DMA_CCR_CIRC,      (1 << 5)  // Circular mode
.equ DMA_CCR_PINC,      (1 << 6)  // Peripheral increment mode
.equ DMA_CCR_MINC,      (1 << 7)  // Memory increment mode
.equ DMA_CCR_PSIZE_8,   (0 << 8)  // Peripheral size: 8 bits
.equ DMA_CCR_PSIZE_16,  (1 << 8)  // Peripheral size: 16 bits
.equ DMA_CCR_PSIZE_32,  (2 << 8)  // Peripheral size: 32 bits
.equ DMA_CCR_MSIZE_8,   (0 << 10) // Memory size: 8 bits
.equ DMA_CCR_MSIZE_16,  (1 << 10) // Memory size: 16 bits
.equ DMA_CCR_MSIZE_32,  (2 << 10) // Memory size: 32 bits
.equ DMA_CCR_PL_LOW,    (0 << 12) // Priority level: Low
.equ DMA_CCR_PL_MED,    (1 << 12) // Priority level: Medium
.equ DMA_CCR_PL_HIGH,   (2 << 12) // Priority level: High
.equ DMA_CCR_PL_VHIGH,  (3 << 12) // Priority level: Very high
.equ DMA_CCR_MEM2MEM,   (1 << 14) // Memory to memory mode

// Configure DMA transfer
// x0 = DMA channel base address
// x1 = source address
// x2 = destination address
// w3 = transfer count
// w4 = configuration flags
dma_configure_transfer:
    stp x29, x30, [sp, #-16]!
    
    // Disable channel first
    ldr w5, [x0, #DMA_CCR]
    bic w5, w5, #DMA_CCR_EN
    str w5, [x0, #DMA_CCR]
    
    // Wait for channel to be disabled
1:  ldr w5, [x0, #DMA_CCR]
    tst w5, #DMA_CCR_EN
    b.ne 1b
    
    // Configure peripheral address (source for periph->mem)
    str x1, [x0, #DMA_CPAR]
    
    // Configure memory address (destination)
    str x2, [x0, #DMA_CMAR]
    
    // Set transfer count
    str w3, [x0, #DMA_CNDTR]
    
    // Set configuration
    str w4, [x0, #DMA_CCR]
    
    ldp x29, x30, [sp], #16
    ret

// Start DMA transfer
// x0 = DMA channel base address
dma_start_transfer:
    ldr w1, [x0, #DMA_CCR]
    orr w1, w1, #DMA_CCR_EN
    str w1, [x0, #DMA_CCR]
    ret

// Stop DMA transfer
// x0 = DMA channel base address
dma_stop_transfer:
    ldr w1, [x0, #DMA_CCR]
    bic w1, w1, #DMA_CCR_EN
    str w1, [x0, #DMA_CCR]
    ret

// Example: Configure DMA for UART receive
// Peripheral -> Memory, circular buffer mode
setup_uart_rx_dma:
    stp x29, x30, [sp, #-16]!
    
    ldr x0, =DMA_CHANNEL1_BASE
    ldr x1, =UART0_DR_ADDRESS     // UART data register (source)
    ldr x2, =uart_rx_dma_buffer   // Memory buffer (destination)
    mov w3, #256                   // Transfer 256 bytes
    
    // Configuration: 
    // - Peripheral to memory
    // - Circular mode
    // - Memory increment
    // - 8-bit transfers
    // - High priority
    // - Transfer complete interrupt
    mov w4, #0
    orr w4, w4, #DMA_CCR_CIRC
    orr w4, w4, #DMA_CCR_MINC
    orr w4, w4, #DMA_CCR_PSIZE_8
    orr w4, w4, #DMA_CCR_MSIZE_8
    orr w4, w4, #DMA_CCR_PL_HIGH
    orr w4, w4, #DMA_CCR_TCIE
    
    bl dma_configure_transfer
    bl dma_start_transfer
    
    ldp x29, x30, [sp], #16
    ret
```

### Timer Driver

Timers generate precise delays, measure time intervals, and trigger periodic events. ARM processors include hardware timer peripherals with various operating modes.

```assembly
// General Purpose Timer driver
.equ TIMER_BASE,    0x40000000
.equ TIMER_CR1,     0x00          // Control register 1
.equ TIMER_CR2,     0x04          // Control register 2
.equ TIMER_DIER,    0x0C          // DMA/Interrupt enable register
.equ TIMER_SR,      0x10          // Status register
.equ TIMER_CNT,     0x24          // Counter
.equ TIMER_PSC,     0x28          // Prescaler
.equ TIMER_ARR,     0x2C          // Auto-reload register
.equ TIMER_CCR1,    0x34          // Capture/compare register 1

// TIMER_CR1 bits
.equ TIMER_CR1_CEN, (1 << 0)      // Counter enable
.equ TIMER_CR1_UDIS,(1 << 1)      // Update disable
.equ TIMER_CR1_URS, (1 << 2)      // Update request source
.equ TIMER_CR1_OPM, (1 << 3)      // One-pulse mode
.equ TIMER_CR1_ARPE,(1 << 7)      // Auto-reload preload enable

// TIMER_DIER bits
.equ TIMER_DIER_UIE,(1 << 0)      // Update interrupt enable
.equ TIMER_DIER_CC1IE,(1 << 1)    // Capture/compare 1 interrupt enable

// Initialize timer for microsecond precision
// Assumes 72 MHz system clock
// x0 = timer base address
timer_init_us:
    stp x29, x30, [sp, #-16]!
    
    // Disable timer
    ldr w1, [x0, #TIMER_CR1]
    bic w1, w1, #TIMER_CR1_CEN
    str w1, [x0, #TIMER_CR1]
    
    // Set prescaler for 1 MHz (72 MHz / 72 = 1 MHz)
    mov w1, #71                    // Prescaler = 72 - 1
    str w1, [x0, #TIMER_PSC]
    
    // Set auto-reload for maximum period
    mov w1, #0xFFFF
    str w1, [x0, #TIMER_ARR]
    
    // Enable auto-reload preload
    ldr w1, [x0, #TIMER_CR1]
    orr w1, w1, #TIMER_CR1_ARPE
    str w1, [x0, #TIMER_CR1]
    
    // Generate update event to load prescaler
    ldr w1, [x0, #TIMER_CR2]
    orr w1, w1, #(1 << 0)          // UG bit
    str w1, [x0, #TIMER_CR2]
    
    ldp x29, x30, [sp], #16
    ret

// Delay for specified microseconds
// x0 = timer base address
// w1 = delay in microseconds
timer_delay_us:
    stp x29, x30, [sp, #-16]!
    
    // Reset counter
    str wzr, [x0, #TIMER_CNT]
    
    // Enable timer
    ldr w2, [x0, #TIMER_CR1]
    orr w2, w2, #TIMER_CR1_CEN
    str w2, [x0, #TIMER_CR1]
    
    // Wait until counter reaches delay value
1:  ldr w3, [x0, #TIMER_CNT]
    cmp w3, w1
    b.lt 1b
    
    // Disable timer
    ldr w2, [x0, #TIMER_CR1]
    bic w2, w2, #TIMER_CR1_CEN
    str w2, [x0, #TIMER_CR1]
    
    ldp x29, x30, [sp], #16
    ret

// Configure timer for periodic interrupt
// x0 = timer base address
// w1 = period in microseconds
timer_setup_periodic:
    stp x29, x30, [sp, #-16]!
    
    // Disable timer
    ldr w2, [x0, #TIMER_CR1]
    bic w2, w2, #TIMER_CR1_CEN
    str w2, [x0, #TIMER_CR1]
    
    // Set auto-reload value
    str w1, [x0, #TIMER_ARR]
    
    // Reset counter
    str wzr, [x0, #TIMER_CNT]
    
    // Enable update interrupt
    mov w2, #TIMER_DIER_UIE
    str w2, [x0, #TIMER_DIER]
    
    // Enable timer
    ldr w2, [x0, #TIMER_CR1]
    orr w2, w2, #TIMER_CR1_CEN
    str w2, [x0, #TIMER_CR1]
    
    ldp x29, x30, [sp], #16
    ret

// Timer interrupt handler
timer_irq_handler:
    stp x29, x30, [sp, #-16]!
    
    ldr x0, =TIMER_BASE
    
    // Clear update interrupt flag
    ldr w1, [x0, #TIMER_SR]
    bic w1, w1, #1
    str w1, [x0, #TIMER_SR]
    
    // Call user callback
    bl timer_callback
    
    ldp x29, x30, [sp], #16
    eret

// PWM (Pulse Width Modulation) configuration
// x0 = timer base address
// w1 = period in microseconds
// w2 = duty cycle (0-100 percentage)
timer_pwm_init:
    stp x29, x30, [sp, #-16]!
    
    // Disable timer
    ldr w3, [x0, #TIMER_CR1]
    bic w3, w3, #TIMER_CR1_CEN
    str w3, [x0, #TIMER_CR1]
    
    // Set period (auto-reload)
    str w1, [x0, #TIMER_ARR]
    
    // Calculate duty cycle value
    mul w4, w1, w2
    mov w5, #100
    udiv w4, w4, w5
    str w4, [x0, #TIMER_CCR1]
    
    // Enable timer
    ldr w3, [x0, #TIMER_CR1]
    orr w3, w3, #TIMER_CR1_CEN
    str w3, [x0, #TIMER_CR1]
    
    ldp x29, x30, [sp], #16
    ret
```

### I2C (Inter-Integrated Circuit) Driver

I2C is a synchronous serial communication protocol commonly used for sensor and peripheral interfacing.

```assembly
// I2C driver for ARM processors
.equ I2C_BASE,      0x40005400
.equ I2C_CR1,       0x00          // Control register 1
.equ I2C_CR2,       0x04          // Control register 2
.equ I2C_OAR1,      0x08          // Own address register 1
.equ I2C_DR,        0x10          // Data register
.equ I2C_SR1,       0x14          // Status register 1
.equ I2C_SR2,       0x18          // Status register 2
.equ I2C_CCR,       0x1C          // Clock control register
.equ I2C_TRISE,     0x20          // Rise time register

// I2C_CR1 bits
.equ I2C_CR1_PE,    (1 << 0)      // Peripheral enable
.equ I2C_CR1_START, (1 << 8)      // Start generation
.equ I2C_CR1_STOP,  (1 << 9)      // Stop generation
.equ I2C_CR1_ACK,   (1 << 10)     // Acknowledge enable

// I2C_SR1 bits
.equ I2C_SR1_SB,    (1 << 0)      // Start bit
.equ I2C_SR1_ADDR,  (1 << 1)      // Address sent
.equ I2C_SR1_BTF,   (1 << 2)      // Byte transfer finished
.equ I2C_SR1_TXE,   (1 << 7)      // Data register empty
.equ I2C_SR1_RXNE,  (1 << 6)      // Data register not empty

// Initialize I2C peripheral
// x0 = I2C base address
// w1 = clock speed in Hz (e.g., 100000 for 100 kHz)
i2c_init:
    stp x29, x30, [sp, #-16]!

    // Disable I2C
    ldr w2, [x0, #I2C_CR1]
    bic w2, w2, #I2C_CR1_PE
    str w2, [x0, #I2C_CR1]

    // Configure clock (simplified - assumes 36 MHz peripheral clock)
    mov w2, #36
    str w2, [x0, #I2C_CR2]

    // Calculate CCR value for 100 kHz
    mov w3, #36000000
    lsl w4, w1, #1
    udiv w3, w3, w4
    str w3, [x0, #I2C_CCR]

    // Set rise time (1 µs for standard mode)
    mov w3, #37
    str w3, [x0, #I2C_TRISE]

    // Enable I2C
    ldr w2, [x0, #I2C_CR1]
    orr w2, w2, #I2C_CR1_PE
    str w2, [x0, #I2C_CR1]

    ldp x29, x30, [sp], #16
    ret


// Generate I2C start condition
// x0 = I2C base address
// Returns: w0 = 0 on success, -1 on timeout
i2c_start:
    stp x29, x30, [sp, #-16]!

    // Generate START
    ldr w1, [x0, #I2C_CR1]
    orr w1, w1, #I2C_CR1_START
    str w1, [x0, #I2C_CR1]

    // Wait for SB flag with timeout
    mov w2, #10000
1:
    ldr w3, [x0, #I2C_SR1]
    tst w3, #I2C_SR1_SB
    b.ne 2f
    subs w2, w2, #1
    b.ne 1b

    // Timeout occurred
    mov w0, #-1
    b 3f

2:
    mov w0, #0

3:
    ldp x29, x30, [sp], #16
    ret


// Send I2C address
// x0 = I2C base address
// w1 = 7-bit address
// w2 = direction (0 = write, 1 = read)
// Returns: w0 = 0 on success, -1 on error
i2c_send_address:
    stp x29, x30, [sp, #-16]!

    // Prepare address byte
    lsl w1, w1, #1
    orr w1, w1, w2
    strb w1, [x0, #I2C_DR]

    // Wait for ADDR flag
    mov w3, #10000
1:
    ldr w4, [x0, #I2C_SR1]
    tst w4, #I2C_SR1_ADDR
    b.ne 2f
    subs w3, w3, #1
    b.ne 1b

    // Timeout
    mov w0, #-1
    b 3f

2:
    // Clear ADDR flag by reading SR1 and SR2
    ldr w4, [x0, #I2C_SR1]
    ldr w4, [x0, #I2C_SR2]
    mov w0, #0

3:
    ldp x29, x30, [sp], #16
    ret


// Write byte to I2C
// x0 = I2C base address
// w1 = data byte
// Returns: w0 = 0 on success, -1 on error
i2c_write_byte:
    stp x29, x30, [sp, #-16]!

    // Wait for TXE flag
    mov w2, #10000
1:
    ldr w3, [x0, #I2C_SR1]
    tst w3, #I2C_SR1_TXE
    b.ne 2f
    subs w2, w2, #1
    b.ne 1b

    // Timeout
    mov w0, #-1
    b 3f

2:
    strb w1, [x0, #I2C_DR]
    mov w0, #0

3:
    ldp x29, x30, [sp], #16
    ret


// Read byte from I2C
// x0 = I2C base address
// w1 = send ACK (1) or NACK (0)
// Returns: w0 = data byte, or -1 on error
i2c_read_byte:
    stp x29, x30, [sp, #-16]!

    // Configure ACK/NACK
    ldr w2, [x0, #I2C_CR1]
    cbz w1, 1f
    orr w2, w2, #I2C_CR1_ACK
    b 2f

1:
    bic w2, w2, #I2C_CR1_ACK

2:
    str w2, [x0, #I2C_CR1]

    // Wait for RXNE flag
    mov w3, #10000
3:
    ldr w4, [x0, #I2C_SR1]
    tst w4, #I2C_SR1_RXNE
    b.ne 4f
    subs w3, w3, #1
    b.ne 3b

    // Timeout
    mov w0, #-1
    b 5f

4:
    ldrb w0, [x0, #I2C_DR]

5:
    ldp x29, x30, [sp], #16
    ret


// Generate I2C stop condition
// x0 = I2C base address
i2c_stop:
    ldr w1, [x0, #I2C_CR1]
    orr w1, w1, #I2C_CR1_STOP
    str w1, [x0, #I2C_CR1]
    ret


// Complete I2C write transaction
// x0 = I2C base address
// w1 = device address (7-bit)
// x2 = pointer to data buffer
// w3 = number of bytes to write
// Returns: w0 = 0 on success, negative on error
i2c_write_data:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]

    mov x19, x0
    mov w20, w3
    mov x21, x2
    mov w22, w1

    // Generate START
    mov x0, x19
    bl i2c_start
    cbnz w0, write_error

    // Send address with write bit
    mov x0, x19
    mov w1, w22
    mov w2, #0
    bl i2c_send_address
    cbnz w0, write_error

write_loop:
    cbz w20, write_done
    ldrb w1, [x21], #1
    mov x0, x19
    bl i2c_write_byte
    cbnz w0, write_error
    sub w20, w20, #1
    b write_loop

write_done:
    mov x0, x19
    bl i2c_stop
    mov w0, #0
    b write_exit

write_error:
    mov x0, x19
    bl i2c_stop
    mov w0, #-1

write_exit:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret


// Complete I2C read transaction
// x0 = I2C base address
// w1 = device address (7-bit)
// x2 = pointer to data buffer
// w3 = number of bytes to read
// Returns: w0 = 0 on success, negative on error
i2c_read_data:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]

    mov x19, x0
    mov w20, w3
    mov x21, x2
    mov w22, w1

    // Generate START
    mov x0, x19
    bl i2c_start
    cbnz w0, read_error

    // Send address with read bit
    mov x0, x19
    mov w1, w22
    mov w2, #1
    bl i2c_send_address
    cbnz w0, read_error

    // Enable ACK for multi-byte read
    cmp w20, #1
    b.le read_loop
    ldr w1, [x19, #I2C_CR1]
    orr w1, w1, #I2C_CR1_ACK
    str w1, [x19, #I2C_CR1]

read_loop:
    cbz w20, read_done

    // Send NACK on last byte
    cmp w20, #1
    cset w1, ne

    mov x0, x19
    bl i2c_read_byte
    cmp w0, #-1
    b.eq read_error

    strb w0, [x21], #1
    sub w20, w20, #1
    b read_loop

read_done:
    mov x0, x19
    bl i2c_stop
    mov w0, #0
    b read_exit

read_error:
    mov x0, x19
    bl i2c_stop
    mov w0, #-1

read_exit:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
````

### SPI (Serial Peripheral Interface) Driver

SPI provides full-duplex synchronous communication with higher speeds than I2C, commonly used for flash memory, displays, and high-speed sensors.

```assembly
// SPI driver for ARM processors
.equ SPI_BASE,      0x40013000
.equ SPI_CR1,       0x00          // Control register 1
.equ SPI_CR2,       0x04          // Control register 2
.equ SPI_SR,        0x08          // Status register
.equ SPI_DR,        0x0C          // Data register

// SPI_CR1 bits
.equ SPI_CR1_CPHA,  (1 << 0)      // Clock phase
.equ SPI_CR1_CPOL,  (1 << 1)      // Clock polarity
.equ SPI_CR1_MSTR,  (1 << 2)      // Master selection
.equ SPI_CR1_BR,    (7 << 3)      // Baud rate control (3 bits)
.equ SPI_CR1_SPE,   (1 << 6)      // SPI enable
.equ SPI_CR1_LSBFIRST,(1 << 7)    // Frame format
.equ SPI_CR1_SSI,   (1 << 8)      // Internal slave select
.equ SPI_CR1_SSM,   (1 << 9)      // Software slave management
.equ SPI_CR1_RXONLY,(1 << 10)     // Receive only
.equ SPI_CR1_DFF,   (1 << 11)     // Data frame format (0=8bit, 1=16bit)
.equ SPI_CR1_BIDIOE,(1 << 14)     // Bidirectional mode enable

// SPI_SR bits
.equ SPI_SR_RXNE,   (1 << 0)      // Receive buffer not empty
.equ SPI_SR_TXE,    (1 << 1)      // Transmit buffer empty
.equ SPI_SR_BSY,    (1 << 7)      // Busy flag

// Initialize SPI
// x0 = SPI base address
// w1 = mode (0-3: combinations of CPOL and CPHA)
// w2 = prescaler (0-7 for divide by 2,4,8,16,32,64,128,256)
spi_init:
    stp x29, x30, [sp, #-16]!
    
    // Disable SPI
    ldr w3, [x0, #SPI_CR1]
    bic w3, w3, #SPI_CR1_SPE
    str w3, [x0, #SPI_CR1]
    
    // Configure SPI_CR1
    mov w3, #0
    orr w3, w3, #SPI_CR1_MSTR      // Master mode
    orr w3, w3, #SPI_CR1_SSM       // Software slave management
    orr w3, w3, #SPI_CR1_SSI       // Internal slave select high
    
    // Set clock polarity and phase based on mode
    tst w1, #1
    b.eq 1f
    orr w3, w3, #SPI_CR1_CPHA
1:  tst w1, #2
    b.eq 2f
    orr w3, w3, #SPI_CR1_CPOL
    
    // Set baud rate prescaler
2:  and w2, w2, #7
    lsl w2, w2, #3
    orr w3, w3, w2
    
    str w3, [x0, #SPI_CR1]
    
    // Enable SPI
    ldr w3, [x0, #SPI_CR1]
    orr w3, w3, #SPI_CR1_SPE
    str w3, [x0, #SPI_CR1]
    
    ldp x29, x30, [sp], #16
    ret

// Transfer single byte (full duplex)
// x0 = SPI base address
// w1 = byte to transmit
// Returns: w0 = received byte
spi_transfer_byte:
    stp x29, x30, [sp, #-16]!
    
    // Wait for TXE
    mov w2, #10000
1:  ldr w3, [x0, #SPI_SR]
    tst w3, #SPI_SR_TXE
    b.ne 2f
    subs w2, w2, #1
    b.ne 1b
    mov w0, #-1                    // Timeout
    b 5f
    
    // Write data
2:  strb w1, [x0, #SPI_DR]
    
    // Wait for RXNE
    mov w2, #10000
3:  ldr w3, [x0, #SPI_SR]
    tst w3, #SPI_SR_RXNE
    b.ne 4f
    subs w2, w2, #1
    b.ne 3b
    mov w0, #-1                    // Timeout
    b 5f
    
    // Read received data
4:  ldrb w0, [x0, #SPI_DR]

5:  ldp x29, x30, [sp], #16
    ret

// Transfer multiple bytes
// x0 = SPI base address
// x1 = pointer to transmit buffer (or NULL for dummy bytes)
// x2 = pointer to receive buffer (or NULL to discard)
// w3 = number of bytes
spi_transfer:
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov w22, w3

transfer_loop:
    cbz w22, transfer_done
    
    // Get transmit byte (or 0xFF if NULL buffer)
    cbz x20, 1f
    ldrb w1, [x20], #1
    b 2f
1:  mov w1, #0xFF

2:  // Transfer byte
    mov x0, x19
    bl spi_transfer_byte
    
    // Store received byte if buffer provided
    cbz x21, 3f
    strb w0, [x21], #1
    
3:  sub w22, w22, #1
    b transfer_loop

transfer_done:
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

// Wait for SPI to complete all transfers
// x0 = SPI base address
spi_wait_busy:
    mov w1, #10000
1:  ldr w2, [x0, #SPI_SR]
    tst w2, #SPI_SR_BSY
    b.eq 2f
    subs w1, w1, #1
    b.ne 1b
    mov w0, #-1                    // Timeout
    ret
2:  mov w0, #0
    ret
````

