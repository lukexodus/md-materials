## Device Registers


Device registers are memory-mapped locations that control hardware behavior and status.

### Register Types

**Control Registers:**

```assembly
; Configure device behavior
; Example: Timer control register

.equ TIM_CR1_CEN,  (1 << 0)     ; Counter enable
.equ TIM_CR1_UDIS, (1 << 1)     ; Update disable
.equ TIM_CR1_DIR,  (1 << 4)     ; Direction (0=up, 1=down)

timer_configure:
    LDR r0, =TIM2_BASE
    
    ; Set control bits
    MOV r1, #(TIM_CR1_CEN | TIM_CR1_DIR)
    STR r1, [r0, #TIM_CR1]
    
    BX lr
```

**Status Registers:**

```assembly
; Read device status
; Example: UART status

check_uart_status:
    LDR r0, =USART1_BASE
    LDR r1, [r0, #USART_SR]
    
    ; Check specific flags
    TST r1, #USART_SR_TXE       ; Transmit empty?
    BNE tx_ready
    
    TST r1, #USART_SR_ORE       ; Overrun error?
    BNE handle_overrun
    
    BX lr
```

**Data Registers:**

```assembly
; Read/write data
; Example: ADC data register

read_adc:
    LDR r0, =ADC1_BASE
    
    ; Start conversion
    LDR r1, [r0, #ADC_CR2]
    ORR r1, r1, #ADC_CR2_SWSTART
    STR r1, [r0, #ADC_CR2]
    
    ; Wait for conversion complete
wait_adc:
    LDR r1, [r0, #ADC_SR]
    TST r1, #ADC_SR_EOC
    BEQ wait_adc
    
    ; Read data
    LDR r0, [r0, #ADC_DR]
    
    BX lr
```

**Configuration Registers:**

```assembly
; Set device parameters
; Example: ADC configuration

.equ ADC_SMPR2,    0x10         ; Sample time register
.equ ADC_SQR3,     0x34         ; Regular sequence register

adc_configure_channel:
    ; r0 = channel number (0-17)
    PUSH {r4, lr}
    
    LDR r4, =ADC1_BASE
    
    ; Set sample time (55.5 cycles for channel 0)
    LDR r1, [r4, #ADC_SMPR2]
    MOV r2, #0x07               ; Sample time value
    LSL r2, r2, r0              ; Shift to channel position
    ORR r1, r1, r2
    STR r1, [r4, #ADC_SMPR2]
    
    ; Set sequence (channel 0 as first conversion)
    LDR r1, [r4, #ADC_SQR3]
    BIC r1, r1, #0x1F           ; Clear first position
    ORR r1, r1, r0              ; Set channel
    STR r1, [r4, #ADC_SQR3]
    
    POP {r4, pc}
```

### Register Access Patterns

**Read-Modify-Write Pattern:**

```assembly
; Safe modification of register bits
; r0 = register address, r1 = bits to set, r2 = bits to clear

register_modify:
    LDR r3, [r0]                ; Read current value
    BIC r3, r3, r2              ; Clear specified bits
    ORR r3, r3, r1              ; Set specified bits
    STR r3, [r0]                ; Write back
    BX lr
```

**Polling Pattern:**

```assembly
; Wait for flag with timeout
; r0 = register address, r1 = flag mask, r2 = timeout (iterations)
; Returns: r0 = 1 if flag set, 0 if timeout

poll_register:
    PUSH {r4, r5, lr}
    
    MOV r4, #0                  ; Counter
    
poll_loop:
    LDR r5, [r0]                ; Read register
    TST r5, r1                  ; Test flag
    BNE poll_success
    
    ADD r4, r4, #1              ; Increment counter
    CMP r4, r2                  ; Check timeout
    BLT poll_loop
    
    ; Timeout
    MOV r0, #0
    POP {r4, r5, pc}
    
poll_success:
    MOV r0, #1
    POP {r4, r5, pc}
```

**Atomic Bit Set/Clear:**

```assembly
; Using bit-set/bit-reset registers (if available)
; Example: GPIO BSRR register

; Set bit atomically
gpio_atomic_set:
    ; r0 = GPIO base, r1 = pin number
    MOV r2, #1
    LSL r2, r2, r1              ; Create mask
    STR r2, [r0, #GPIO_BSRR]    ; Write to BSRR (lower 16 bits set)
    BX lr

; Clear bit atomically
gpio_atomic_clear:
    MOV r2, #1
    LSL r2, r2, r1
    LSL r2, r2, #16             ; Upper 16 bits reset
    STR r2, [r0, #GPIO_BSRR]
    BX lr
```

### Interrupt-Driven I/O

**Interrupt Service Routine Template:**

```assembly
; Generic ISR pattern
device_ISR:
    PUSH {r4, r5, lr}
    
    ; Read status register
    LDR r4, =DEVICE_BASE
    LDR r5, [r4, #DEVICE_SR]
    
    ; Check interrupt source
    TST r5, #DEVICE_FLAG1
    BNE handle_interrupt1
    
    TST r5, #DEVICE_FLAG2
    BNE handle_interrupt2
    
    B isr_done
    
handle_interrupt1:
    ; Clear flag
    MOV r0, #DEVICE_FLAG1
    STR r0, [r4, #DEVICE_SR]
    
    ; Handle interrupt
    ; ... processing ...
    
    B isr_done
    
handle_interrupt2:
    ; Clear flag
    MOV r0, #DEVICE_FLAG2
    STR r0, [r4, #DEVICE_SR]
    
    ; Handle interrupt
    ; ... processing ...
    
isr_done:
    POP {r4, r5, pc}
```

**Important related topics:** ADC and DAC programming, PWM for motor control, watchdog timer configuration, real-time clock (RTC) interfacing, flash memory programming, power management and low-power modes, interrupt priority and nesting, DMA chaining and scatter-gather, bus protocols (CAN, USB, Ethernet)

---

