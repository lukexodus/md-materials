## Timer Programming


Hardware timers provide precise time measurement and event generation without CPU intervention. ARM-based systems typically include multiple timer peripherals with varying capabilities.

**ARM Generic Timer (ARMv7-A/ARMv8):**

The ARM Generic Timer provides system-wide timekeeping with both physical and virtual counters.

**Generic Timer Registers:**

- **CNTFRQ:** Counter frequency (Hz)
- **CNTPCT:** Physical count value (64-bit)
- **CNTVCT:** Virtual count value (64-bit)
- **CNTP_CTL:** Physical timer control
- **CNTP_CVAL:** Physical timer compare value
- **CNTP_TVAL:** Physical timer interval value
- **CNTV_CTL:** Virtual timer control
- **CNTV_CVAL:** Virtual timer compare value
- **CNTV_TVAL:** Virtual timer interval value

**Accessing Generic Timer:**

```assembly
; Read counter frequency
MRC     p15, 0, R0, c14, c0, 0       ; Read CNTFRQ

; Read physical counter (64-bit)
MRRC    p15, 0, R0, R1, c14          ; Read CNTPCT (R0=low, R1=high)

; Read virtual counter (64-bit)
MRRC    p15, 1, R0, R1, c14          ; Read CNTVCT

; Set physical timer compare value
MCRR    p15, 2, R0, R1, c14          ; Write CNTP_CVAL

; Set physical timer interval
MCR     p15, 0, R0, c14, c2, 0       ; Write CNTP_TVAL

; Enable physical timer
MRC     p15, 0, R0, c14, c2, 1       ; Read CNTP_CTL
ORR     R0, R0, #1                   ; Set enable bit
MCR     p15, 0, R0, c14, c2, 1       ; Write CNTP_CTL
```

**Timer Interrupt Setup Example:**

```assembly
; Configure physical timer for 1-second interval
setup_timer_1sec:
    PUSH    {R4, R5, LR}
    
    ; Read counter frequency
    MRC     p15, 0, R4, c14, c0, 0   ; CNTFRQ
    
    ; Set timer interval (frequency = ticks per second)
    MCR     p15, 0, R4, c14, c2, 0   ; Write CNTP_TVAL
    
    ; Enable timer and interrupt
    MOV     R0, #3                   ; Enable + interrupt enable
    MCR     p15, 0, R0, c14, c2, 1   ; Write CNTP_CTL
    
    ; Configure GIC for timer interrupt (implementation-specific)
    ; Timer IRQ typically ID 30 for physical timer
    MOV     R0, #30
    BL      gic_enable_interrupt
    
    POP     {R4, R5, PC}

; Timer interrupt handler
timer_irq_handler:
    PUSH    {R0-R3, LR}
    
    ; Read and acknowledge timer status
    MRC     p15, 0, R0, c14, c2, 1   ; Read CNTP_CTL
    ORR     R0, R0, #2               ; Clear ISTATUS
    MCR     p15, 0, R0, c14, c2, 1   ; Write CNTP_CTL
    
    ; Reload timer for next interrupt
    MRC     p15, 0, R1, c14, c0, 0   ; Read CNTFRQ
    MCR     p15, 0, R1, c14, c2, 0   ; Write CNTP_TVAL
    
    ; User timer handler code here
    BL      timer_callback
    
    POP     {R0-R3, PC}
```

**Peripheral Timers (Example: ARM SP804 Dual Timer):**

Many ARM SoCs include peripheral timers with memory-mapped registers.

```assembly
; SP804 Timer register offsets
.equ TIMER_BASE, 0x10011000          ; Example base address
.equ TIMER1_LOAD, 0x00               ; Load register
.equ TIMER1_VALUE, 0x04              ; Current value (read-only)
.equ TIMER1_CONTROL, 0x08            ; Control register
.equ TIMER1_INTCLR, 0x0C             ; Interrupt clear
.equ TIMER1_RIS, 0x10                ; Raw interrupt status
.equ TIMER1_MIS, 0x14                ; Masked interrupt status
.equ TIMER1_BGLOAD, 0x18             ; Background load

; Timer control register bits
.equ TIMER_CTRL_ONESHOT, (0 << 0)    ; One-shot mode
.equ TIMER_CTRL_PERIODIC, (1 << 0)   ; Periodic mode (wrapping)
.equ TIMER_CTRL_32BIT, (1 << 1)      ; 32-bit counter
.equ TIMER_CTRL_PRESCALE_1, (0 << 2) ; No prescale
.equ TIMER_CTRL_PRESCALE_16, (1 << 2)
.equ TIMER_CTRL_PRESCALE_256, (2 << 2)
.equ TIMER_CTRL_INTEN, (1 << 5)      ; Interrupt enable
.equ TIMER_CTRL_ENABLE, (1 << 7)     ; Timer enable

; Initialize timer for periodic interrupts
; R0 = reload value
; R1 = prescaler (0=1, 1=16, 2=256)
timer_init_periodic:
    PUSH    {R4, R5, LR}
    MOV     R4, R0
    MOV     R5, R1
    
    LDR     R0, =TIMER_BASE
    
    ; Disable timer first
    MOV     R1, #0
    STR     R1, [R0, #TIMER1_CONTROL]
    
    ; Set load value
    STR     R4, [R0, #TIMER1_LOAD]
    
    ; Configure control register
    MOV     R1, #TIMER_CTRL_PERIODIC
    ORR     R1, R1, #TIMER_CTRL_32BIT
    ORR     R1, R1, #TIMER_CTRL_INTEN
    ORR     R1, R1, #TIMER_CTRL_ENABLE
    
    ; Add prescaler
    LSL     R5, R5, #2
    ORR     R1, R1, R5
    
    STR     R1, [R0, #TIMER1_CONTROL]
    
    POP     {R4, R5, PC}

; Timer interrupt handler
timer_sp804_handler:
    PUSH    {R0-R1, LR}
    
    ; Clear interrupt
    LDR     R0, =TIMER_BASE
    MOV     R1, #1
    STR     R1, [R0, #TIMER1_INTCLR]
    
    ; User handler
    BL      timer_callback
    
    POP     {R0-R1, PC}

; Read current timer value
; Returns: R0 = current count
timer_read:
    LDR     R0, =TIMER_BASE
    LDR     R0, [R0, #TIMER1_VALUE]
    BX      LR

; Stop timer
timer_stop:
    LDR     R0, =TIMER_BASE
    MOV     R1, #0
    STR     R1, [R0, #TIMER1_CONTROL]
    BX      LR
```

**Watchdog Timer Programming:**

Watchdog timers reset the system if not periodically refreshed, detecting software hangs.

```assembly
; Watchdog register offsets (example)
.equ    WDT_BASE,         0x10010000
.equ    WDT_LOAD,         0x00            ; Load/counter value
.equ    WDT_VALUE,        0x04            ; Current value
.equ    WDT_CONTROL,      0x08            ; Control register
.equ    WDT_INTCLR,       0x0C            ; Interrupt clear
.equ    WDT_LOCK,         0xC00           ; Lock register

.equ    WDT_UNLOCK_VALUE, 0x1ACCE551      ; Unlock value


; Initialize watchdog
; R0 = timeout value
watchdog_init:
    PUSH    {R4, LR}
    MOV     R4, R0

    LDR     R0, =WDT_BASE

    ; Unlock watchdog
    LDR     R1, =WDT_UNLOCK_VALUE
    STR     R1, [R0, #WDT_LOCK]

    ; Set load value
    STR     R4, [R0, #WDT_LOAD]

    ; Enable watchdog with interrupt then reset
    MOV     R1, #3                       ; Interrupt enable + reset enable
    STR     R1, [R0, #WDT_CONTROL]

    ; Lock watchdog
    MOV     R1, #0
    STR     R1, [R0, #WDT_LOCK]

    POP     {R4, PC}


; Refresh/kick watchdog (prevent reset)
watchdog_kick:
    LDR     R0, =WDT_BASE

    ; Unlock
    LDR     R1, =WDT_UNLOCK_VALUE
    STR     R1, [R0, #WDT_LOCK]

    ; Reload counter (write any value to LOAD)
    LDR     R1, [R0, #WDT_LOAD]
    STR     R1, [R0, #WDT_LOAD]

    ; Lock
    MOV     R1, #0
    STR     R1, [R0, #WDT_LOCK]

    BX      LR


; Clear watchdog interrupt
watchdog_clear_interrupt:
    LDR     R0, =WDT_BASE
    MOV     R1, #1
    STR     R1, [R0, #WDT_INTCLR]
    BX      LR

````

**PWM Generation with Timers:**

Pulse Width Modulation can be generated using timer compare/match functionality.

```assembly
; Software PWM using timer interrupt
; Variables in memory
.data
pwm_period:     .word 1000           ; Timer ticks per PWM cycle
pwm_duty:       .word 500            ; Timer ticks for high state
pwm_counter:    .word 0              ; Current position in cycle
pwm_state:      .word 0              ; Current output state
pwm_pin:        .word 12             ; GPIO pin number

.text
; Initialize PWM
; R0 = period (timer ticks)
; R1 = duty cycle (timer ticks)
; R2 = GPIO pin
pwm_init:
    PUSH    {LR}
    
    ; Store parameters
    LDR     R3, =pwm_period
    STR     R0, [R3]
    LDR     R3, =pwm_duty
    STR     R1, [R3]
    LDR     R3, =pwm_pin
    STR     R2, [R3]
    
    ; Configure GPIO as output
    MOV     R0, R2
    BL      gpio_set_output
    
    ; Initialize timer for fast periodic interrupt
    MOV     R0, #100                 ; Timer interval (adjust for resolution)
    BL      timer_init_periodic
    
    POP     {PC}

; PWM timer interrupt handler
pwm_timer_handler:
    PUSH    {R0-R4, LR}
    
    ; Clear timer interrupt
    BL      timer_clear_interrupt
    
    ; Load PWM parameters
    LDR     R0, =pwm_counter
    LDR     R1, [R0]                 ; Current counter
    LDR     R2, =pwm_duty
    LDR     R2, [R2]                 ; Duty cycle value
    LDR     R3, =pwm_period
    LDR     R3, [R3]                 ; Period value
    
    ; Increment counter
    ADD     R1, R1, #1
    CMP     R1, R3
    MOVGE   R1, #0                   ; Wrap at period
    STR     R1, [R0]
    
    ; Determine output state
    CMP     R1, R2
    MOVLT   R4, #1                   ; Counter < duty: output high
    MOVGE   R4, #0                   ; Counter >= duty: output low
    
    ; Update GPIO
    LDR     R0, =pwm_pin
    LDR     R0, [R0]
    CMP     R4, #0
    BEQ     pwm_set_low
    
    BL      gpio_set_high
    B       pwm_done
    
pwm_set_low:
    BL      gpio_set_low
    
pwm_done:
    POP     {R0-R4, PC}

; Update PWM duty cycle
; R0 = new duty cycle
pwm_set_duty:
    LDR     R1, =pwm_duty
    STR     R0, [R1]
    BX      LR
````

**High-Resolution Timing:**

Using counters for precise time measurement:

```assembly
; Measure execution time using Generic Timer
; R0 = pointer to function
; Returns: R0 = elapsed cycles (low 32 bits)
measure_cycles:
    PUSH    {R4, R5, R6, LR}
    MOV     R6, R0                   ; Save function pointer
    
    ; Read start time
    MRRC    p15, 0, R4, R5, c14      ; Read CNTPCT (64-bit)
    
    ; Execute function
    BLX     R6
    
    ; Read end time
    MRRC    p15, 0, R0, R1, c14      ; Read CNTPCT
    
    ; Calculate difference (low 32 bits)
    SUB     R0, R0, R4
    
    POP     {R4, R5, R6, PC}

; Precise delay using counter
; R0 = microseconds to delay
precise_delay_us:
    PUSH    {R4, R5, R6, R7}
    
    ; Read counter frequency
    MRC     p15, 0, R4, c14, c0, 0   ; CNTFRQ
    
    ; Calculate target cycles: (us * freq) / 1000000
    MUL     R5, R0, R4
    LDR     R6, =1000000
    UDIV    R5, R5, R6
    
    ; Read start count
    MRRC    p15, 0, R0, R1, c14      ; CNTPCT
    ADD     R5, R5, R0               ; Target = start + delta
    
delay_loop:
    MRRC    p15, 0, R6, R7, c14      ; Read current count
    CMP     R6, R5
    BLT     delay_loop
    
    POP     {R4, R5, R6, R7}
    BX      LR
```

