## Watchdog Timers


Watchdog timers are hardware safety mechanisms that reset the system if software fails to respond within a specified timeout period. They detect software hangs, infinite loops, and system crashes.

### Watchdog Operation

A watchdog timer counts down from a preset value. Software must periodically "kick" or "refresh" the watchdog before it reaches zero. If the counter expires, the watchdog triggers a system reset.

**Independent Watchdog (IWDG):** Runs from independent low-speed oscillator, continues in sleep modes. Used for detecting complete system failure.

**Window Watchdog (WWDG):** Requires refresh within a specific time window. Detects early refresh (runaway code) and late refresh (hang). Stops in debug/sleep modes.

### IWDG Configuration and Usage

```assembly
// Initialize Independent Watchdog (STM32 example)
    LDR     R0, =IWDG_KR            // Key register
    
    // Unlock IWDG registers
    LDR     R1, =0x5555
    STR     R1, [R0]
    
    // Set prescaler (divide LSI clock)
    LDR     R0, =IWDG_PR
    MOV     R1, #4                  // Divide by 64 (LSI=32kHz -> 500Hz)
    STR     R1, [R0]
    
    // Set reload value (timeout period)
    LDR     R0, =IWDG_RLR
    LDR     R1, =2000               // 2000/500Hz = 4 second timeout
    STR     R1, [R0]
    
    // Start watchdog
    LDR     R0, =IWDG_KR
    LDR     R1, =0xCCCC
    STR     R1, [R0]

// Watchdog refresh routine (call periodically)
watchdog_refresh:
    LDR     R0, =IWDG_KR
    LDR     R1, =0xAAAA             // Reload key
    STR     R1, [R0]
    BX      LR
```

### WWDG Configuration

```assembly
// Initialize Window Watchdog
    // Enable WWDG clock
    LDR     R0, =RCC_APB1ENR
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<11)        // WWDGEN bit
    STR     R1, [R0]
    
    // Configure prescaler
    LDR     R0, =WWDG_CFR
    LDR     R1, =0x0000007F         // Max window value, prescaler /8
    STR     R1, [R0]
    
    // Set counter and enable
    LDR     R0, =WWDG_CR
    LDR     R1, =0x000000FF         // Counter=0x7F, enable bit
    STR     R1, [R0]

// Window watchdog refresh (must be within window)
wwdg_refresh:
    LDR     R0, =WWDG_CR
    LDR     R1, =0x0000007F         // Reset counter value
    STR     R1, [R0]
    BX      LR
```

### Watchdog in Main Loop

Typical embedded main loop with watchdog:

```assembly
main:
    BL      system_init
    BL      watchdog_init
    BL      peripheral_init
    
main_loop:
    // Critical task 1
    BL      read_sensors
    
    // Critical task 2
    BL      process_data
    
    // Refresh watchdog before timeout
    BL      watchdog_refresh
    
    // Critical task 3
    BL      update_outputs
    
    // Check for events
    BL      handle_communications
    
    B       main_loop               // Loop forever
```

### Watchdog Reset Detection

Detecting watchdog resets allows error logging and recovery:

```assembly
// Check reset source on startup
startup_check:
    LDR     R0, =RCC_CSR            // Clock control & status register
    LDR     R1, [R0]
    
    // Check IWDG reset flag
    TST     R1, #(1<<29)            // IWDGRSTF bit
    BNE     iwdg_reset_occurred
    
    // Check WWDG reset flag
    TST     R1, #(1<<30)            // WWDGRSTF bit
    BNE     wwdg_reset_occurred
    
    // Normal startup
    B       normal_init
    
iwdg_reset_occurred:
    // Log error, increment counter, recovery action
    BL      log_watchdog_error
    // Clear flag
    LDR     R1, [R0]
    ORR     R1, R1, #(1<<24)        // RMVF - clear reset flags
    STR     R1, [R0]
    B       recovery_init
```

### Safe Watchdog Patterns

```assembly
// Task with watchdog protection
protected_task:
    PUSH    {R4, LR}
    
    // Set timeout flag
    LDR     R4, =task_timeout_flag
    MOV     R1, #0
    STR     R1, [R4]
    
    // Enable timeout timer interrupt
    BL      start_timeout_timer
    
    // Execute task
    BL      potentially_slow_operation
    
    // Check if we exceeded soft timeout
    LDR     R1, [R4]
    CMP     R1, #0
    BNE     task_timeout_error
    
    // Success - refresh watchdog
    BL      watchdog_refresh
    
    POP     {R4, PC}
    
task_timeout_error:
    // Handle timeout without letting watchdog expire
    BL      emergency_shutdown
    BL      watchdog_refresh        // Still refresh to allow clean shutdown
    B       error_handler
```

