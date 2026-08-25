## Power Management


Power management is critical in battery-operated embedded systems. ARM processors offer multiple power-saving modes and techniques to extend battery life while maintaining responsiveness.

### Sleep Modes

ARM Cortex-M processors provide several sleep modes with varying wake-up latencies and power savings:

**Sleep mode:** CPU clock stopped, peripherals and RAM active. Wake on any interrupt.

**Deep sleep:** CPU and high-speed clocks stopped, low-power oscillator active. Longer wake-up time.

**Standby/Shutdown:** Maximum power savings, only backup domain active. Requires reset to wake.

```assembly
// Enter sleep mode (Wait for Interrupt)
    WFI                             // Halt until interrupt
    // Execution continues here after interrupt
    
// Enter sleep mode (Wait for Event)
    WFE                             // Halt until event
    
// Configuring deep sleep
    LDR     R0, =SCB_SCR            // System Control Register
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<2)         // Set SLEEPDEEP bit
    STR     R1, [R0]
    WFI                             // Enter deep sleep
```

### Clock Gating

Selectively disabling clocks to unused peripherals reduces dynamic power consumption:

```assembly
// Enable peripheral clocks only when needed (STM32 example)
    LDR     R0, =RCC_AHB1ENR        // AHB1 peripheral clock enable
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<0)         // Enable GPIOA clock
    STR     R1, [R0]
    
    // Use GPIOA...
    
    // Disable when done
    LDR     R1, [R0]
    BIC     R1, R1, #(1<<0)         // Disable GPIOA clock
    STR     R1, [R0]
```

### Dynamic Voltage and Frequency Scaling (DVFS)

Adjusting processor frequency and voltage based on workload reduces power consumption:

```assembly
// Switch to lower clock frequency (example sequence)
    // First reduce voltage regulator scale
    LDR     R0, =PWR_CR              // Power control register
    LDR     R1, [R0]
    BIC     R1, R1, #(3<<14)        // Clear VOS bits
    ORR     R1, R1, #(2<<14)        // Set scale 2
    STR     R1, [R0]
    
    // Wait for voltage ready
wait_vos:
    LDR     R1, =PWR_CSR
    LDR     R1, [R1]
    TST     R1, #(1<<14)            // Check VOSRDY
    BEQ     wait_vos
    
    // Now switch PLL to lower frequency
    LDR     R0, =RCC_CFGR
    LDR     R1, [R0]
    BIC     R1, R1, #(3<<0)         // Clear SW bits
    ORR     R1, R1, #(1<<0)         // Use PLL as system clock
    STR     R1, [R0]
```

### Peripheral Power Control

Individual peripherals can be powered down independently:

```assembly
// ADC power control
    LDR     R0, =ADC1_CR2           // ADC control register 2
    
    // Power on ADC
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<0)         // Set ADON bit
    STR     R1, [R0]
    
    // Wait for stabilization (typically 10 µs)
    MOV     R2, #1000               // Delay count
adc_delay:
    SUBS    R2, R2, #1
    BNE     adc_delay
    
    // Use ADC...
    
    // Power off ADC when done
    LDR     R1, [R0]
    BIC     R1, R1, #(1<<0)         // Clear ADON bit
    STR     R1, [R0]
```

### Efficient Code Patterns

Power-efficient assembly code minimizes memory accesses and computational overhead:

```assembly
// Power-efficient loop: minimize memory traffic
    LDR     R0, =data_array         // Load address once
    MOV     R1, #0                  // Initialize sum
    MOV     R2, #ARRAY_SIZE
    
process_loop:
    LDR     R3, [R0], #4            // Load and post-increment
    ADD     R1, R1, R3              // Accumulate in register
    SUBS    R2, R2, #1
    BNE     process_loop
    
    // Write result once
    LDR     R0, =result
    STR     R1, [R0]
```

