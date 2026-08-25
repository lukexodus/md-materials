## GPIO Programming


General Purpose Input/Output (GPIO) allows software control of digital pins for interfacing with external hardware.

### GPIO Configuration

**GPIO Register Structure:**

```assembly
; Typical GPIO register layout
.equ GPIO_MODER,   0x00         ; Mode register (input/output/alternate/analog)
.equ GPIO_OTYPER,  0x04         ; Output type (push-pull/open-drain)
.equ GPIO_OSPEEDR, 0x08         ; Output speed
.equ GPIO_PUPDR,   0x0C         ; Pull-up/pull-down
.equ GPIO_IDR,     0x10         ; Input data register
.equ GPIO_ODR,     0x14         ; Output data register
.equ GPIO_BSRR,    0x18         ; Bit set/reset register
.equ GPIO_LCKR,    0x1C         ; Lock register
.equ GPIO_AFRL,    0x20         ; Alternate function low
.equ GPIO_AFRH,    0x24         ; Alternate function high

; Mode values (2 bits per pin)
.equ GPIO_MODE_INPUT,  0b00
.equ GPIO_MODE_OUTPUT, 0b01
.equ GPIO_MODE_AF,     0b10      ; Alternate function
.equ GPIO_MODE_ANALOG, 0b11

; Output type
.equ GPIO_OTYPE_PP,    0         ; Push-pull
.equ GPIO_OTYPE_OD,    1         ; Open-drain

; Speed values (2 bits per pin)
.equ GPIO_SPEED_LOW,    0b00
.equ GPIO_SPEED_MED,    0b01
.equ GPIO_SPEED_HIGH,   0b10
.equ GPIO_SPEED_VHIGH,  0b11

; Pull-up/pull-down (2 bits per pin)
.equ GPIO_PUPD_NONE, 0b00
.equ GPIO_PUPD_UP,   0b01
.equ GPIO_PUPD_DOWN, 0b10
```

**Configuring GPIO Pin:**

```assembly
; Configure pin as output
; r0 = GPIO base address, r1 = pin number (0-15)

gpio_config_output:
    PUSH {r4, r5, lr}
    
    ; Set mode to output (2 bits per pin)
    LDR r2, [r0, #GPIO_MODER]
    MOV r3, #0b11               ; Mask for 2 bits
    LSL r4, r1, #1              ; Bit position = pin * 2
    LSL r3, r3, r4              ; Position mask
    BIC r2, r2, r3              ; Clear bits
    MOV r3, #GPIO_MODE_OUTPUT
    LSL r3, r3, r4              ; Position value
    ORR r2, r2, r3              ; Set bits
    STR r2, [r0, #GPIO_MODER]
    
    ; Set output type to push-pull
    LDR r2, [r0, #GPIO_OTYPER]
    MOV r3, #1
    LSL r3, r3, r1              ; Bit mask
    BIC r2, r2, r3              ; Clear = push-pull
    STR r2, [r0, #GPIO_OTYPER]
    
    ; Set speed to high
    LDR r2, [r0, #GPIO_OSPEEDR]
    MOV r3, #0b11
    LSL r4, r1, #1
    LSL r3, r3, r4
    BIC r2, r2, r3              ; Clear bits
    MOV r3, #GPIO_SPEED_HIGH
    LSL r3, r3, r4
    ORR r2, r2, r3              ; Set high speed
    STR r2, [r0, #GPIO_OSPEEDR]
    
    ; No pull-up/pull-down
    LDR r2, [r0, #GPIO_PUPDR]
    MOV r3, #0b11
    LSL r4, r1, #1
    LSL r3, r3, r4
    BIC r2, r2, r3              ; Clear = no pull
    STR r2, [r0, #GPIO_PUPDR]
    
    POP {r4, r5, pc}

; Configure pin as input with pull-up
gpio_config_input_pullup:
    PUSH {r4, r5, lr}
    
    ; Set mode to input
    LDR r2, [r0, #GPIO_MODER]
    MOV r3, #0b11
    LSL r4, r1, #1
    LSL r3, r3, r4
    BIC r2, r2, r3              ; Clear = input mode
    STR r2, [r0, #GPIO_MODER]
    
    ; Set pull-up
    LDR r2, [r0, #GPIO_PUPDR]
    MOV r3, #0b11
    LSL r4, r1, #1
    LSL r3, r3, r4
    BIC r2, r2, r3
    MOV r3, #GPIO_PUPD_UP
    LSL r3, r3, r4
    ORR r2, r2, r3
    STR r2, [r0, #GPIO_PUPDR]
    
    POP {r4, r5, pc}
```

### GPIO Read/Write Operations

**Writing to GPIO:**

```assembly
; Set pin high
; r0 = GPIO base, r1 = pin number

gpio_set:
    MOV r2, #1
    LSL r2, r2, r1              ; Create bit mask
    STR r2, [r0, #GPIO_BSRR]    ; BSRR lower 16 bits = set
    BX lr

; Set pin low
gpio_clear:
    MOV r2, #1
    LSL r2, r2, r1
    LSL r2, r2, #16             ; BSRR upper 16 bits = reset
    STR r2, [r0, #GPIO_BSRR]
    BX lr

; Toggle pin
gpio_toggle:
    PUSH {r4, lr}
    
    LDR r2, [r0, #GPIO_ODR]     ; Read current state
    MOV r3, #1
    LSL r3, r3, r1              ; Create mask
    EOR r2, r2, r3              ; Toggle bit
    STR r2, [r0, #GPIO_ODR]     ; Write back
    
    POP {r4, pc}

; Write multiple pins atomically
; r0 = GPIO base, r1 = value, r2 = mask
gpio_write_masked:
    LDR r3, [r0, #GPIO_ODR]     ; Read current
    BIC r3, r3, r2              ; Clear masked bits
    AND r1, r1, r2              ; Mask new value
    ORR r3, r3, r1              ; Combine
    STR r3, [r0, #GPIO_ODR]     ; Write
    BX lr
```

**Reading from GPIO:**

```assembly
; Read pin state
; r0 = GPIO base, r1 = pin number
; Returns: r0 = 0 or 1

gpio_read:
    LDR r2, [r0, #GPIO_IDR]     ; Read input data register
    LSR r2, r2, r1              ; Shift bit to position 0
    AND r0, r2, #1              ; Mask to single bit
    BX lr

; Read entire port
gpio_read_port:
    LDR r0, [r0, #GPIO_IDR]
    BX lr

; Wait for pin to go high
; r0 = GPIO base, r1 = pin number
gpio_wait_high:
    PUSH {r4, lr}
    
    MOV r4, #1
    LSL r4, r4, r1              ; Create mask
    
wait_loop:
    LDR r2, [r0, #GPIO_IDR]
    TST r2, r4                  ; Test bit
    BEQ wait_loop               ; Loop if still low
    
    POP {r4, pc}
```

### GPIO Interrupts

**Configuring External Interrupts:**

```assembly
; Example: STM32 EXTI configuration
.equ EXTI_BASE,    0x40010400
.equ SYSCFG_BASE,  0x40010000

.equ EXTI_IMR,     0x00         ; Interrupt mask register
.equ EXTI_EMR,     0x04         ; Event mask register
.equ EXTI_RTSR,    0x08         ; Rising trigger selection
.equ EXTI_FTSR,    0x0C         ; Falling trigger selection
.equ EXTI_SWIER,   0x10         ; Software interrupt event
.equ EXTI_PR,      0x14         ; Pending register

.equ SYSCFG_EXTICR1, 0x08       ; External interrupt configuration

; Configure pin for interrupt on rising edge
; r0 = GPIO port (A=0, B=1, etc.), r1 = pin number

gpio_config_interrupt:
    PUSH {r4, r5, r6, lr}
    
    ; Configure SYSCFG to route pin to EXTI line
    LDR r2, =SYSCFG_BASE
    MOV r3, r1
    LSR r3, r3, #2              ; Register index = pin / 4
    LSL r3, r3, #2              ; Multiply by 4 for offset
    ADD r2, r2, #SYSCFG_EXTICR1
    ADD r2, r2, r3              ; Point to correct EXTICR register
    
    AND r4, r1, #0x3            ; Position within register = pin % 4
    LSL r4, r4, #2              ; Each field is 4 bits
    MOV r5, #0xF
    LSL r5, r5, r4              ; Create mask
    
    LDR r6, [r2]
    BIC r6, r6, r5              ; Clear field
    LSL r0, r0, r4              ; Position port number
    ORR r6, r6, r0              ; Set port
    STR r6, [r2]
    
    ; Enable interrupt mask for this line
    LDR r2, =EXTI_BASE
    LDR r3, [r2, #EXTI_IMR]
    MOV r4, #1
    LSL r4, r4, r1              ; Bit for this pin
    ORR r3, r3, r4
    STR r3, [r2, #EXTI_IMR]
    
    ; Configure rising edge trigger
    LDR r3, [r2, #EXTI_RTSR]
    ORR r3, r3, r4
    STR r3, [r2, #EXTI_RTSR]
    
    ; Clear any pending interrupt
    STR r4, [r2, #EXTI_PR]
    
    POP {r4, r5, r6, pc}

; EXTI interrupt handler
exti_irq_handler:
    PUSH {r4, lr}
    
    LDR r0, =EXTI_BASE
    LDR r1, [r0, #EXTI_PR]      ; Read pending register
    
    ; Check which line triggered
    MOV r2, #0                  ; Pin counter
    
check_loop:
    CMP r2, #16
    BGE irq_done
    
    MOV r3, #1
    LSL r3, r3, r2
    TST r1, r3                  ; Test if this pin pending
    BEQ next_pin
    
    ; Clear pending bit
    STR r3, [r0, #EXTI_PR]
    
    ; Handle interrupt for pin r2
    PUSH {r0-r3}
    MOV r0, r2
    BL gpio_interrupt_callback  ; User callback
    POP {r0-r3}
    
next_pin:
    ADD r2, r2, #1
    B check_loop
    
irq_done:
    POP {r4, pc}
```

### Practical GPIO Examples

**Example** - LED Blink:

```assembly
; Blink LED on pin
; r0 = GPIO base, r1 = pin number, r2 = delay count

led_blink:
    PUSH {r4, r5, r6, lr}
    
    MOV r4, r0                  ; Save GPIO base
    MOV r5, r1                  ; Save pin
    MOV r6, r2                  ; Save delay
    
blink_loop:
    ; Turn LED on
    MOV r0, r4
    MOV r1, r5
    BL gpio_set
    
    ; Delay
    MOV r0, r6
    BL delay_ms
    
    ; Turn LED off
    MOV r0, r4
    MOV r1, r5
    BL gpio_clear
    
    ; Delay
    MOV r0, r6
    BL delay_ms
    
    B blink_loop                ; Infinite loop
```

**Example** - Button debouncing:

```assembly
; Read button with debouncing
; r0 = GPIO base, r1 = pin number
; Returns: r0 = 1 if button pressed (stable)

button_read_debounced:
    PUSH {r4, r5, r6, lr}
    
    MOV r4, r0                  ; Save GPIO base
    MOV r5, r1                  ; Save pin
    MOV r6, #0                  ; Stable count
    
    ; Read initial state
    MOV r0, r4
    MOV r1, r5
    BL gpio_read
    MOV r2, r0                  ; Previous state
    
debounce_loop:
    ; Small delay
    MOV r0, #1
    BL delay_ms
    
    ; Read current state
    MOV r0, r4
    MOV r1, r5
    BL gpio_read
    
    ; Compare with previous
    CMP r0, r2
    BNE state_changed
    
    ; State stable, increment counter
    ADD r6, r6, #1
    CMP r6, #10                 ; 10ms stable = valid
    BGE debounce_done
    B debounce_loop
    
state_changed:
    MOV r2, r0                  ; Update previous state
    MOV r6, #0                  ; Reset counter
    B debounce_loop
    
debounce_done:
    MOV r0, r2                  ; Return stable state
    POP {r4, r5, r6, pc}
```

**Example** - Shift register (74HC595) control:

```assembly
; Send data to 74HC595 shift register
; r0 = GPIO base
; r1 = data pin, r2 = clock pin, r3 = latch pin
; r4 = data byte

shift_out_595:
    PUSH {r5, r6, r7, lr}
    
    MOV r5, r0                  ; Save GPIO base
    MOV r6, #8                  ; Bit counter
    
    ; Latch low
    MOV r0, r5
    MOV r1, r3
    BL gpio_clear
    
shift_loop:
    ; Extract MSB
    MOV r7, r4
    LSR r7, r7, #7              ; Get bit 7
    AND r7, r7, #1
    
    ; Set data pin
    MOV r0, r5
    MOV r1, r1                  ; Data pin (from parameter)
    CMP r7, #0
    ITE EQ
    BLEQ gpio_clear
    BLNE gpio_set
    
    ; Clock high
    MOV r0, r5
    MOV r1, r2                  ; Clock pin
    BL gpio_set
    
    ; Small delay
    MOV r0, #1
    BL delay_us
    
    ; Clock low
    MOV r0, r5
    MOV r1, r2
    BL gpio_clear
    
    ; Shift data left
    LSL r4, r4, #1
    
    ; Decrement counter
    SUBS r6, r6, #1
    BNE shift_loop
    
    ; Latch high to output data
    MOV r0, r5
    MOV r1, r3
    BL gpio_set
    
    POP {r5, r6, r7, pc}
```

**Example** - Reading rotary encoder:

```assembly
; Read quadrature rotary encoder
; r0 = GPIO base, r1 = pin A, r2 = pin B
; Returns: r0 = -1 (CCW), 0 (no change), 1 (CW)

.data
encoder_state: .byte 0          ; Previous state

.text
read_encoder:
    PUSH {r4, r5, r6, lr}
    
    MOV r4, r0                  ; Save GPIO base
    MOV r5, r1                  ; Save pin A
    MOV r6, r2                  ; Save pin B
    
    ; Read pin A
    MOV r0, r4
    MOV r1, r5
    BL gpio_read
    LSL r0, r0, #1              ; Shift to bit 1
    MOV r3, r0                  ; Current state
    
    ; Read pin B
    MOV r0, r4
    MOV r1, r6
    BL gpio_read
    ORR r3, r3, r0              ; Combine: [A:B]
    
    ; Load previous state
    LDR r0, =encoder_state
    LDRB r1, [r0]
    
    ; Save current state
    STRB r3, [r0]
    
    ; Determine direction
    ; State transition table:
    ; 00->01 = CW,  01->00 = CCW
    ; 01->11 = CW,  11->01 = CCW
    ; 11->10 = CW,  10->11 = CCW
    ; 10->00 = CW,  00->10 = CCW
    
    EOR r2, r1, r3              ; XOR old and new
    CMP r2, #0
    IT EQ
    MOVEQ r0, #0                ; No change
    BEQ encoder_done
    
    ; Check which bit changed
    TST r2, #0x02               ; Did bit 1 (A) change?
    ITE NE
    ANDNE r0, r3, #0x01         ; If A changed, direction = B
    ANDEQ r0, r3, #0x02         ; If B changed, direction = A
    LSR r0, r0, #0              ; Normalize to 0 or 1
    
    ; Convert to -1 or 1
    CMP r0, #0
    ITE EQ
    MOVEQ r0, #-1               ; CCW
    MOVNE r0, #1                ; CW
    
encoder_done:
    POP {r4, r5, r6, pc}
```

