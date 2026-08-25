## Peripheral Access


Peripherals are specialized hardware blocks that provide specific functionality like timers, communication interfaces, and analog conversion.

### Clock Configuration

**Enabling Peripheral Clocks:**

```assembly
; Example: STM32 RCC (Reset and Clock Control)
.equ RCC_BASE,      0x40021000
.equ RCC_CR,        0x00            ; Clock control register
.equ RCC_CFGR,      0x04            ; Clock configuration
.equ RCC_APB1ENR,   0x1C            ; APB1 peripheral clock enable
.equ RCC_APB2ENR,   0x18            ; APB2 peripheral clock enable
.equ RCC_AHBENR,    0x14            ; AHB peripheral clock enable

; Enable GPIOA clock
.equ RCC_AHBENR_GPIOAEN, (1 << 17)

enable_gpioa_clock:
    LDR r0, =RCC_BASE
    LDR r1, [r0, #RCC_AHBENR]
    ORR r1, r1, #RCC_AHBENR_GPIOAEN
    STR r1, [r0, #RCC_AHBENR]
    
    ; Small delay for clock to stabilize
    MOV r0, #10
    BL delay_us
    
    BX lr

; Configure system clock
; Example: Set to 72MHz using PLL
configure_system_clock:
    PUSH {r4, lr}

    LDR r4, =RCC_BASE

    ; Enable HSE (High Speed External oscillator)
    LDR r0, [r4, #RCC_CR]
    ORR r0, r0, #(1 << 16)          ; HSEON
    STR r0, [r4, #RCC_CR]

wait_hse_ready:
    LDR r0, [r4, #RCC_CR]
    TST r0, #(1 << 17)              ; HSERDY
    BEQ wait_hse_ready

    ; Configure PLL: HSE * 9 = 72MHz (8MHz * 9)
    LDR r0, [r4, #RCC_CFGR]
    BIC r0, r0, #0x003C0000         ; Clear PLL multiplier bits
    ORR r0, r0, #0x001C0000         ; PLLMUL = 9
    ORR r0, r0, #(1 << 16)          ; PLLSRC = HSE
    STR r0, [r4, #RCC_CFGR]

    ; Enable PLL
    LDR r0, [r4, #RCC_CR]
    ORR r0, r0, #(1 << 24)          ; PLLON
    STR r0, [r4, #RCC_CR]

wait_pll_ready:
    LDR r0, [r4, #RCC_CR]
    TST r0, #(1 << 25)              ; PLLRDY
    BEQ wait_pll_ready

    ; Set PLL as system clock
    LDR r0, [r4, #RCC_CFGR]
    BIC r0, r0, #0x03               ; Clear SW bits
    ORR r0, r0, #0x02               ; SW = PLL
    STR r0, [r4, #RCC_CFGR]

wait_clock_switch:
    LDR r0, [r4, #RCC_CFGR]
    AND r0, r0, #0x0C               ; SWS bits
    CMP r0, #0x08                   ; Check if PLL is system clock
    BNE wait_clock_switch

    POP {r4, pc}
````

### Timer/Counter Programming

**Basic Timer Configuration:**
```assembly
; Example: STM32 TIM2 configuration
.equ TIM2_BASE,    0x40000000
.equ TIM_CR1,      0x00         ; Control register 1
.equ TIM_CR2,      0x04         ; Control register 2
.equ TIM_DIER,     0x0C         ; DMA/Interrupt enable
.equ TIM_SR,       0x10         ; Status register
.equ TIM_CNT,      0x24         ; Counter
.equ TIM_PSC,      0x28         ; Prescaler
.equ TIM_ARR,      0x2C         ; Auto-reload register
.equ TIM_CCR1,     0x34         ; Capture/Compare 1

; TIM_CR1 bits
.equ TIM_CR1_CEN,  (1 << 0)     ; Counter enable
.equ TIM_CR1_UDIS, (1 << 1)     ; Update disable
.equ TIM_CR1_URS,  (1 << 2)     ; Update request source
.equ TIM_CR1_OPM,  (1 << 3)     ; One-pulse mode
.equ TIM_CR1_ARPE, (1 << 7)     ; Auto-reload preload enable

; TIM_DIER bits
.equ TIM_DIER_UIE, (1 << 0)     ; Update interrupt enable

; TIM_SR bits
.equ TIM_SR_UIF,   (1 << 0)     ; Update interrupt flag

; Initialize timer for 1ms interrupts
; Assumes 72MHz system clock, APB1 = 36MHz, timer clock = 72MHz
timer_init_1ms:
    PUSH {r4, lr}
    
    ; Enable TIM2 clock
    LDR r0, =RCC_BASE
    LDR r1, [r0, #RCC_APB1ENR]
    ORR r1, r1, #(1 << 0)       ; TIM2EN
    STR r1, [r0, #RCC_APB1ENR]
    
    LDR r4, =TIM2_BASE
    
    ; Set prescaler: 72MHz / 72 = 1MHz (1µs per tick)
    MOV r0, #71                 ; Prescaler = 72 - 1
    STR r0, [r4, #TIM_PSC]
    
    ; Set auto-reload: 1MHz / 1000 = 1ms
    MOV r0, #999                ; ARR = 1000 - 1
    STR r0, [r4, #TIM_ARR]
    
    ; Enable update interrupt
    MOV r0, #TIM_DIER_UIE
    STR r0, [r4, #TIM_DIER]
    
    ; Enable timer
    MOV r0, #TIM_CR1_CEN
    STR r0, [r4, #TIM_CR1]
    
    ; Enable TIM2 interrupt in NVIC
    LDR r0, =0xE000E100         ; NVIC_ISER0
    MOV r1, #(1 << 28)          ; TIM2 is IRQ 28
    STR r1, [r0]
    
    POP {r4, pc}

; Timer interrupt handler
TIM2_IRQHandler:
    PUSH {r4, lr}
    
    LDR r4, =TIM2_BASE
    
    ; Check if update interrupt
    LDR r0, [r4, #TIM_SR]
    TST r0, #TIM_SR_UIF
    BEQ timer_irq_done
    
    ; Clear interrupt flag
    LDR r0, [r4, #TIM_SR]
    BIC r0, r0, #TIM_SR_UIF
    STR r0, [r4, #TIM_SR]
    
    ; Handle 1ms tick
    BL system_tick_handler      ; User callback
    
timer_irq_done:
    POP {r4, pc}
````

**PWM Generation:**

```assembly
; Configure timer for PWM output
; r0 = frequency (Hz), r1 = duty cycle (0-100)

timer_pwm_init:
    PUSH {r4, r5, r6, lr}
    
    MOV r4, r0                  ; Save frequency
    MOV r5, r1                  ; Save duty cycle
    
    ; Enable TIM2 clock
    LDR r0, =RCC_BASE
    LDR r1, [r0, #RCC_APB1ENR]
    ORR r1, r1, #(1 << 0)
    STR r1, [r0, #RCC_APB1ENR]
    
    LDR r6, =TIM2_BASE
    
    ; Calculate prescaler and ARR
    ; Timer clock = 72MHz
    ; ARR = 72000000 / (prescaler * frequency) - 1
    
    ; Use prescaler = 72 for frequencies < 1MHz
    MOV r0, #71
    STR r0, [r6, #TIM_PSC]
    
    ; ARR = 1000000 / frequency - 1
    LDR r0, =1000000
    UDIV r0, r0, r4
    SUB r0, r0, #1
    STR r0, [r6, #TIM_ARR]
    
    ; Calculate CCR1 for duty cycle
    ; CCR1 = ARR * duty_cycle / 100
    ADD r0, r0, #1              ; ARR + 1
    MUL r0, r0, r5              ; * duty_cycle
    MOV r1, #100
    UDIV r0, r0, r1             ; / 100
    STR r0, [r6, #TIM_CCR1]
    
    ; Configure channel 1 as PWM mode 1
    ; CCMR1: OC1M = 110 (PWM mode 1), OC1PE = 1 (preload enable)
    LDR r0, [r6, #0x18]         ; TIM_CCMR1
    BIC r0, r0, #0x73           ; Clear OC1M and OC1PE
    ORR r0, r0, #0x68           ; Set PWM mode 1 and preload
    STR r0, [r6, #0x18]
    
    ; Enable channel 1 output
    LDR r0, [r6, #0x20]         ; TIM_CCER
    ORR r0, r0, #0x01           ; CC1E
    STR r0, [r6, #0x20]
    
    ; Enable auto-reload preload
    LDR r0, [r6, #TIM_CR1]
    ORR r0, r0, #TIM_CR1_ARPE
    STR r0, [r6, #TIM_CR1]
    
    ; Enable counter
    LDR r0, [r6, #TIM_CR1]
    ORR r0, r0, #TIM_CR1_CEN
    STR r0, [r6, #TIM_CR1]
    
    POP {r4, r5, r6, pc}

; Set PWM duty cycle
; r0 = duty cycle (0-100)
timer_pwm_set_duty:
    PUSH {r4, lr}
    
    LDR r4, =TIM2_BASE
    
    ; Read ARR
    LDR r1, [r4, #TIM_ARR]
    ADD r1, r1, #1
    
    ; Calculate new CCR1
    MUL r0, r0, r1
    MOV r1, #100
    UDIV r0, r0, r1
    
    ; Update CCR1
    STR r0, [r4, #TIM_CCR1]
    
    POP {r4, pc}
```

**Input Capture:**

```assembly
; Configure timer for input capture
; Measure pulse width or frequency

timer_input_capture_init:
    PUSH {r4, lr}
    
    ; Enable TIM2 clock
    LDR r0, =RCC_BASE
    LDR r1, [r0, #RCC_APB1ENR]
    ORR r1, r1, #(1 << 0)
    STR r1, [r0, #RCC_APB1ENR]
    
    LDR r4, =TIM2_BASE
    
    ; Set prescaler for desired resolution
    MOV r0, #71                 ; 1MHz (1µs resolution)
    STR r0, [r4, #TIM_PSC]
    
    ; Set ARR to maximum
    LDR r0, =0xFFFF
    STR r0, [r4, #TIM_ARR]
    
    ; Configure channel 1 as input capture
    ; CCMR1: CC1S = 01 (input, IC1 mapped to TI1)
    LDR r0, [r6, #0x18]         ; TIM_CCMR1
    BIC r0, r0, #0x03
    ORR r0, r0, #0x01           ; CC1S = 01
    STR r0, [r6, #0x18]
    
    ; Enable capture on rising edge
    LDR r0, [r4, #0x20]         ; TIM_CCER
    ORR r0, r0, #0x01           ; CC1E
    BIC r0, r0, #0x02           ; CC1P = 0 (rising edge)
    STR r0, [r4, #0x20]
    
    ; Enable capture interrupt
    LDR r0, [r4, #TIM_DIER]
    ORR r0, r0, #(1 << 1)       ; CC1IE
    STR r0, [r4, #TIM_DIER]
    
    ; Enable timer
    LDR r0, [r4, #TIM_CR1]
    ORR r0, r0, #TIM_CR1_CEN
    STR r0, [r4, #TIM_CR1]
    
    POP {r4, pc}

.data
capture_start: .word 0
pulse_width:   .word 0

.text
; Capture interrupt handler
TIM2_Capture_IRQHandler:
    PUSH {r4, lr}
    
    LDR r4, =TIM2_BASE
    
    ; Check CC1 interrupt
    LDR r0, [r4, #TIM_SR]
    TST r0, #(1 << 1)           ; CC1IF
    BEQ capture_done
    
    ; Clear flag
    LDR r0, [r4, #TIM_SR]
    BIC r0, r0, #(1 << 1)
    STR r0, [r4, #TIM_SR]
    
    ; Read captured value
    LDR r0, [r4, #TIM_CCR1]
    
    ; Check if this is start or end of pulse
    LDR r1, =capture_start
    LDR r2, [r1]
    CMP r2, #0
    BEQ capture_rising
    
    ; Falling edge - calculate pulse width
    SUB r3, r0, r2              ; End - start
    LDR r1, =pulse_width
    STR r3, [r1]
    
    ; Reset for next capture
    LDR r1, =capture_start
    MOV r2, #0
    STR r2, [r1]
    
    ; Change to rising edge
    LDR r0, [r4, #0x20]
    BIC r0, r0, #0x02           ; CC1P = 0
    STR r0, [r4, #0x20]
    
    B capture_done
    
capture_rising:
    ; Rising edge - save start time
    LDR r1, =capture_start
    STR r0, [r1]
    
    ; Change to falling edge
    LDR r0, [r4, #0x20]
    ORR r0, r0, #0x02           ; CC1P = 1
    STR r0, [r4, #0x20]
    
capture_done:
    POP {r4, pc}
```

### UART/USART Communication

**UART Initialization:**

```assembly
; Example: STM32 USART1 configuration
.equ USART1_BASE,  0x40013800
.equ USART_SR,     0x00         ; Status register
.equ USART_DR,     0x04         ; Data register
.equ USART_BRR,    0x08         ; Baud rate register
.equ USART_CR1,    0x0C         ; Control register 1
.equ USART_CR2,    0x10         ; Control register 2
.equ USART_CR3,    0x14         ; Control register 3

; USART_SR bits
.equ USART_SR_TXE,  (1 << 7)    ; Transmit data register empty
.equ USART_SR_TC,   (1 << 6)    ; Transmission complete
.equ USART_SR_RXNE, (1 << 5)    ; Read data register not empty
.equ USART_SR_ORE,  (1 << 3)    ; Overrun error
.equ USART_SR_FE,   (1 << 1)    ; Framing error
.equ USART_SR_PE,   (1 << 0)    ; Parity error

; USART_CR1 bits
.equ USART_CR1_UE,     (1 << 13) ; USART enable
.equ USART_CR1_M,      (1 << 12) ; Word length (0=8bit, 1=9bit)
.equ USART_CR1_PCE,    (1 << 10) ; Parity control enable
.equ USART_CR1_PS,     (1 << 9)  ; Parity selection
.equ USART_CR1_TXEIE,  (1 << 7)  ; TXE interrupt enable
.equ USART_CR1_TCIE,   (1 << 6)  ; TC interrupt enable
.equ USART_CR1_RXNEIE, (1 << 5)  ; RXNE interrupt enable
.equ USART_CR1_TE,     (1 << 3)  ; Transmitter enable
.equ USART_CR1_RE,     (1 << 2)  ; Receiver enable

; Initialize UART at 115200 baud, 8N1
; Assumes 72MHz system clock, USART1 on APB2 (72MHz)
uart_init:
    PUSH {r4, lr}
    
    ; Enable USART1 clock
    LDR r0, =RCC_BASE
    LDR r1, [r0, #RCC_APB2ENR]
    ORR r1, r1, #(1 << 14)      ; USART1EN
    STR r1, [r0, #RCC_APB2ENR]
    
    ; Enable GPIOA clock (for TX/RX pins)
    LDR r1, [r0, #RCC_AHBENR]
    ORR r1, r1, #(1 << 17)      ; GPIOAEN
    STR r1, [r0, #RCC_AHBENR]
    
    ; Configure PA9 (TX) and PA10 (RX) as alternate function
    LDR r0, =0x40020000         ; GPIOA_BASE
    
    ; PA9: Alternate function, push-pull, high speed
    LDR r1, [r0, #GPIO_MODER]
    BIC r1, r1, #(0x3 << 18)
    ORR r1, r1, #(0x2 << 18)    ; Alternate function
    STR r1, [r0, #GPIO_MODER]
    
    ; PA10: Alternate function
    LDR r1, [r0, #GPIO_MODER]
    BIC r1, r1, #(0x3 << 20)
    ORR r1, r1, #(0x2 << 20)
    STR r1, [r0, #GPIO_MODER]
    
    ; Set alternate function AF7 (USART1) for PA9 and PA10
    LDR r1, [r0, #GPIO_AFRH]
    BIC r1, r1, #0x00000FF0     ; Clear AF9 and AF10
    ORR r1, r1, #0x00000770     ; Set AF7
    STR r1, [r0, #GPIO_AFRH]
    
    LDR r4, =USART1_BASE
    
    ; Calculate and set baud rate
    ; BRR = fCK / (16 * baud_rate)
    ; BRR = 72000000 / (16 * 115200) = 39.0625
    ; Mantissa = 39, Fraction = 0.0625 * 16 = 1
    ; BRR = (39 << 4) | 1 = 625
    LDR r0, =625
    STR r0, [r4, #USART_BRR]
    
    ; Configure: 8 data bits, 1 stop bit, no parity
    MOV r0, #0
    STR r0, [r4, #USART_CR2]    ; 1 stop bit (default)
    
    ; Enable USART, transmitter, and receiver
    MOV r0, #(USART_CR1_UE | USART_CR1_TE | USART_CR1_RE)
    STR r0, [r4, #USART_CR1]
    
    POP {r4, pc}

; Transmit single byte
; r0 = byte to transmit
uart_putc:
    PUSH {r4, lr}
    
    LDR r4, =USART1_BASE
    MOV r1, r0                  ; Save byte
    
    ; Wait for TXE (transmit data register empty)
wait_txe:
    LDR r0, [r4, #USART_SR]
    TST r0, #USART_SR_TXE
    BEQ wait_txe
    
    ; Write data
    STRB r1, [r4, #USART_DR]
    
    POP {r4, pc}

; Receive single byte
; Returns: r0 = received byte
uart_getc:
    PUSH {r4, lr}
    
    LDR r4, =USART1_BASE
    
    ; Wait for RXNE (receive data register not empty)
wait_rxne:
    LDR r0, [r4, #USART_SR]
    TST r0, #USART_SR_RXNE
    BEQ wait_rxne
    
    ; Read data
    LDRB r0, [r4, #USART_DR]
    
    POP {r4, pc}

; Transmit string
; r0 = pointer to null-terminated string
uart_puts:
    PUSH {r4, r5, lr}
    
    MOV r4, r0                  ; Save string pointer
    
puts_loop:
    LDRB r5, [r4], #1           ; Load byte, increment pointer
    CMP r5, #0                  ; Check for null terminator
    BEQ puts_done
    
    MOV r0, r5
    BL uart_putc
    
    B puts_loop
    
puts_done:
    POP {r4, r5, pc}

; Receive string (until newline or max length)
; r0 = buffer pointer, r1 = max length
; Returns: r0 = actual length
uart_gets:
    PUSH {r4, r5, r6, lr}
    
    MOV r4, r0                  ; Save buffer pointer
    MOV r5, r1                  ; Save max length
    MOV r6, #0                  ; Current length
    
gets_loop:
    CMP r6, r5                  ; Check max length
    BGE gets_done
    
    BL uart_getc                ; Receive byte
    
    CMP r0, #'\r'               ; Check for carriage return
    BEQ gets_done
    CMP r0, #'\n'               ; Check for newline
    BEQ gets_done
    
    STRB r0, [r4], #1           ; Store byte
    ADD r6, r6, #1              ; Increment length
    
    B gets_loop
    
gets_done:
    MOV r0, #0
    STRB r0, [r4]               ; Null terminate
    MOV r0, r6                  ; Return length
    
    POP {r4, r5, r6, pc}
```

**UART with Interrupts and Ring Buffer:**

```assembly
.equ UART_BUFFER_SIZE, 128

.data
.align 2
uart_rx_buffer: .space UART_BUFFER_SIZE
uart_rx_head:   .word 0
uart_rx_tail:   .word 0
uart_rx_count:  .word 0

.text
; Initialize UART with RX interrupt
uart_init_interrupt:
    PUSH {r4, lr}
    
    ; Call basic init
    BL uart_init
    
    ; Enable RXNE interrupt
    LDR r4, =USART1_BASE
    LDR r0, [r4, #USART_CR1]
    ORR r0, r0, #USART_CR1_RXNEIE
    STR r0, [r4, #USART_CR1]
    
    ; Enable USART1 interrupt in NVIC
    LDR r0, =0xE000E100         ; NVIC_ISER1
    MOV r1, #(1 << 5)           ; USART1 is IRQ 37 (bit 5 in ISER1)
    STR r1, [r0, #4]            ; ISER1
    
    ; Initialize buffer pointers
    LDR r0, =uart_rx_head
    MOV r1, #0
    STR r1, [r0]
    LDR r0, =uart_rx_tail
    STR r1, [r0]
    LDR r0, =uart_rx_count
    STR r1, [r0]
    
    POP {r4, pc}

; USART1 interrupt handler
USART1_IRQHandler:
    PUSH {r4, r5, r6, lr}
    
    LDR r4, =USART1_BASE
    
    ; Check RXNE
    LDR r0, [r4, #USART_SR]
    TST r0, #USART_SR_RXNE
    BEQ uart_irq_done
    
    ; Read data (clears RXNE flag)
    LDRB r5, [r4, #USART_DR]
    
    ; Check if buffer is full
    LDR r0, =uart_rx_count
    LDR r1, [r0]
    CMP r1, #UART_BUFFER_SIZE
    BGE uart_irq_done           ; Buffer full, discard byte
    
    ; Store byte in buffer
    LDR r2, =uart_rx_buffer
    LDR r3, =uart_rx_head
    LDR r6, [r3]
    STRB r5, [r2, r6]           ; buffer[head] = byte
    
    ; Increment head (circular)
    ADD r6, r6, #1
    CMP r6, #UART_BUFFER_SIZE
    IT EQ
    MOVEQ r6, #0                ; Wrap around
    STR r6, [r3]
    
    ; Increment count
    ADD r1, r1, #1
    STR r1, [r0]
    
uart_irq_done:
    POP {r4, r5, r6, pc}

; Check if data available in buffer
; Returns: r0 = 1 if data available, 0 otherwise
uart_available:
    LDR r0, =uart_rx_count
    LDR r1, [r0]
    CMP r1, #0
    ITE GT
    MOVGT r0, #1
    MOVLE r0, #0
    BX lr

; Read byte from buffer (non-blocking)
; Returns: r0 = byte, or -1 if no data
uart_read_nonblocking:
    PUSH {r4, r5, lr}
    
    LDR r0, =uart_rx_count
    LDR r1, [r0]
    CMP r1, #0
    BEQ no_data
    
    ; Read from buffer
    LDR r2, =uart_rx_buffer
    LDR r3, =uart_rx_tail
    LDR r4, [r3]
    LDRB r5, [r2, r4]           ; byte = buffer[tail]
    
    ; Increment tail (circular)
    ADD r4, r4, #1
    CMP r4, #UART_BUFFER_SIZE
    IT EQ
    MOVEQ r4, #0
    STR r4, [r3]
    
    ; Decrement count
    SUB r1, r1, #1
    STR r1, [r0]
    
    MOV r0, r5                  ; Return byte
    POP {r4, r5, pc}
    
no_data:
    MOV r0, #-1
    POP {r4, r5, pc}
```

### SPI Communication

**SPI Master Configuration:**

```assembly
; Example: STM32 SPI1 configuration
.equ SPI1_BASE,    0x40013000
.equ SPI_CR1,      0x00         ; Control register 1
.equ SPI_CR2,      0x04         ; Control register 2
.equ SPI_SR,       0x08         ; Status register
.equ SPI_DR,       0x0C         ; Data register

; SPI_CR1 bits
.equ SPI_CR1_BIDIMODE, (1 << 15) ; Bidirectional data mode
.equ SPI_CR1_BIDIOE,   (1 << 14) ; Output enable in bidir mode
.equ SPI_CR1_CRCEN,    (1 << 13) ; CRC enable
.equ SPI_CR1_CRCNEXT,  (1 << 12) ; CRC next
.equ SPI_CR1_DFF,      (1 << 11) ; Data frame format (0=8bit, 1=16bit)
.equ SPI_CR1_RXONLY,   (1 << 10) ; Receive only
.equ SPI_CR1_SSM,      (1 << 9)  ; Software slave management
.equ SPI_CR1_SSI,      (1 << 8)  ; Internal slave select
.equ SPI_CR1_LSBFIRST, (1 << 7)  ; Frame format
.equ SPI_CR1_SPE,      (1 << 6)  ; SPI enable
.equ SPI_CR1_BR,       (7 << 3)  ; Baud rate control (3 bits)
.equ SPI_CR1_MSTR,     (1 << 2)  ; Master selection
.equ SPI_CR1_CPOL,     (1 << 1)  ; Clock polarity
.equ SPI_CR1_CPHA,     (1 << 0)  ; Clock phase

; SPI_SR bits
.equ SPI_SR_BSY,   (1 << 7)     ; Busy flag
.equ SPI_SR_TXE,   (1 << 1)     ; Transmit buffer empty
.equ SPI_SR_RXNE,  (1 << 0)     ; Receive buffer not empty

; Initialize SPI1 as master, mode 0, 1MHz
spi_init:
    PUSH {r4, lr}
    
    ; Enable SPI1 clock
    LDR r0, =RCC_BASE
    LDR r1, [r0, #RCC_APB2ENR]
    ORR r1, r1, #(1 << 12)          ; SPI1EN
    STR r1, [r0, #RCC_APB2ENR]
    
    ; Enable GPIOA clock (for SCK, MISO, MOSI)
    LDR r1, [r0, #RCC_AHBENR]
    ORR r1, r1, #(1 << 17)          ; GPIOAEN
    STR r1, [r0, #RCC_AHBENR]

    ; Configure GPIO pins: PA5=SCK, PA6=MISO, PA7=MOSI
    LDR r0, =0x40020000             ; GPIOA_BASE

    ; Set PA5, PA7 as alternate function, PA6 as input
    LDR r1, [r0, #GPIO_MODER]
    BIC r1, r1, #0x0000FC00         ; Clear bits for PA5-PA7
    ORR r1, r1, #0x0000A800         ; PA5=AF, PA6=AF, PA7=AF
    STR r1, [r0, #GPIO_MODER]

    ; Set alternate function AF5 (SPI1) for PA5-PA7
    LDR r1, [r0, #GPIO_AFRL]
    BIC r1, r1, #0xFFF00000         ; Clear AF5-AF7
    ORR r1, r1, #0x55500000         ; Set AF5
    STR r1, [r0, #GPIO_AFRL]

    ; Set high speed for SPI pins
    LDR r1, [r0, #GPIO_OSPEEDR]
    ORR r1, r1, #0x0000FC00         ; High speed for PA5-PA7
    STR r1, [r0, #GPIO_OSPEEDR]

    LDR r4, =SPI1_BASE

    ; Configure SPI1
    ; Master, software slave management, 8-bit, MSB first
    ; Baud rate = fPCLK/32 (72MHz/32 = 2.25MHz)
    ; Mode 0: CPOL=0, CPHA=0
    MOV r0, #(SPI_CR1_MSTR | SPI_CR1_SSM | SPI_CR1_SSI)
    ORR r0, r0, #(0x04 << 3)        ; BR = 100 (divide by 32)
    STR r0, [r4, #SPI_CR1]

    ; Enable SPI
    LDR r0, [r4, #SPI_CR1]
    ORR r0, r0, #SPI_CR1_SPE
    STR r0, [r4, #SPI_CR1]

    POP {r4, pc}

; Transfer single byte (full duplex)
; r0 = byte to send
; Returns: r0 = byte received
spi_transfer:
    PUSH {r4, lr}

    LDR r4, =SPI1_BASE
    MOV r1, r0                      ; Save byte to send

wait_spi_txe:
    LDR r0, [r4, #SPI_SR]
    TST r0, #SPI_SR_TXE
    BEQ wait_spi_txe

    ; Send byte
    STRB r1, [r4, #SPI_DR]

wait_spi_rxne:
    LDR r0, [r4, #SPI_SR]
    TST r0, #SPI_SR_RXNE
    BEQ wait_spi_rxne

    ; Read received byte
    LDRB r0, [r4, #SPI_DR]

wait_spi_busy:
    LDR r1, [r4, #SPI_SR]
    TST r1, #SPI_SR_BSY
    BNE wait_spi_busy

    POP {r4, pc}

; Send multiple bytes
; r0 = buffer pointer, r1 = count
spi_send_buffer:
    PUSH {r4, r5, r6, lr}

    MOV r4, r0                      ; Save buffer pointer
    MOV r5, r1                      ; Save count
    MOV r6, #0                      ; Index

send_loop:
    CMP r6, r5
    BGE send_done

    LDRB r0, [r4, r6]               ; Load byte
    BL spi_transfer                 ; Send (ignore received data)

    ADD r6, r6, #1
    B send_loop

send_done:
    POP {r4, r5, r6, pc}

; Receive multiple bytes
; r0 = buffer pointer, r1 = count
spi_receive_buffer:
    PUSH {r4, r5, r6, lr}

    MOV r4, r0                      ; Save buffer pointer
    MOV r5, r1                      ; Save count
    MOV r6, #0                      ; Index

receive_loop:
    CMP r6, r5
    BGE receive_done

    MOV r0, #0xFF                   ; Send dummy byte
    BL spi_transfer
    STRB r0, [r4, r6]               ; Store received byte

    ADD r6, r6, #1
    B receive_loop

receive_done:
    POP {r4, r5, r6, pc}

; Example: Read from SPI device with chip select
; r0 = register address, r1 = chip select GPIO base, r2 = CS pin
spi_read_register:
    PUSH {r4, r5, r6, lr}

    MOV r4, r0                      ; Save register address
    MOV r5, r1                      ; Save CS GPIO base
    MOV r6, r2                      ; Save CS pin

; CS low
MOV r0, r5
MOV r1, r6
BL gpio_clear

; Small delay
MOV r0, #1
BL delay_us

; Send read command (address with read bit set)
ORR r0, r4, #0x80           ; Set MSB for read
BL spi_transfer

; Read data
MOV r0, #0xFF               ; Dummy byte
BL spi_transfer
MOV r4, r0                  ; Save received data

; CS high
MOV r0, r5
MOV r1, r6
BL gpio_set

MOV r0, r4                  ; Return data
POP {r4, r5, r6, pc}

; Write to SPI device ; r0 = register address, r1 = data, r2 = CS GPIO base, r3 = CS pin spi_write_register: PUSH {r4, r5, r6, r7, lr}

MOV r4, r0                  ; Save register
MOV r5, r1                  ; Save data
MOV r6, r2                  ; Save CS GPIO
MOV r7, r3                  ; Save CS pin

; CS low
MOV r0, r6
MOV r1, r7
BL gpio_clear

; Small delay
MOV r0, #1
BL delay_us

; Send write command (address without read bit)
MOV r0, r4
BL spi_transfer

; Send data
MOV r0, r5
BL spi_transfer

; CS high
MOV r0, r6
MOV r1, r7
BL gpio_set

POP {r4, r5, r6, r7, pc}
````

### I2C Communication

**I2C Master Configuration:**
```assembly
; Example: STM32 I2C1 configuration
.equ I2C1_BASE,    0x40005400
.equ I2C_CR1,      0x00         ; Control register 1
.equ I2C_CR2,      0x04         ; Control register 2
.equ I2C_OAR1,     0x08         ; Own address register 1
.equ I2C_OAR2,     0x0C         ; Own address register 2
.equ I2C_DR,       0x10         ; Data register
.equ I2C_SR1,      0x14         ; Status register 1
.equ I2C_SR2,      0x18         ; Status register 2
.equ I2C_CCR,      0x1C         ; Clock control register
.equ I2C_TRISE,    0x20         ; Rise time register

; I2C_CR1 bits
.equ I2C_CR1_PE,     (1 << 0)   ; Peripheral enable
.equ I2C_CR1_START,  (1 << 8)   ; Start generation
.equ I2C_CR1_STOP,   (1 << 9)   ; Stop generation
.equ I2C_CR1_ACK,    (1 << 10)  ; Acknowledge enable
.equ I2C_CR1_POS,    (1 << 11)  ; Position
.equ I2C_CR1_SWRST,  (1 << 15)  ; Software reset

; I2C_SR1 bits
.equ I2C_SR1_SB,     (1 << 0)   ; Start bit
.equ I2C_SR1_ADDR,   (1 << 1)   ; Address sent/matched
.equ I2C_SR1_BTF,    (1 << 2)   ; Byte transfer finished
.equ I2C_SR1_TXE,    (1 << 7)   ; Data register empty (transmit)
.equ I2C_SR1_RXNE,   (1 << 6)   ; Data register not empty (receive)

; Initialize I2C1 at 100kHz (standard mode)
i2c_init:
    PUSH {r4, lr}
    
    ; Enable I2C1 clock
    LDR r0, =RCC_BASE
    LDR r1, [r0, #RCC_APB1ENR]
    ORR r1, r1, #(1 << 21)      ; I2C1EN
    STR r1, [r0, #RCC_APB1ENR]
    
    ; Enable GPIOB clock (for SCL, SDA)
    LDR r1, [r0, #RCC_AHBENR]
    ORR r1, r1, #(1 << 18)      ; GPIOBEN
    STR r1, [r0, #RCC_AHBENR]
    
    ; Configure PB6=SCL, PB7=SDA as alternate function, open-drain
    LDR r0, =0x40020400         ; GPIOB_BASE
    
    ; Set as alternate function
    LDR r1, [r0, #GPIO_MODER]
    BIC r1, r1, #0x0000F000     ; Clear PB6-PB7
    ORR r1, r1, #0x0000A000     ; Set alternate function
    STR r1, [r0, #GPIO_MODER]
    
    ; Set alternate function AF4 (I2C1)
    LDR r1, [r0, #GPIO_AFRL]
    BIC r1, r1, #0xFF000000
    ORR r1, r1, #0x44000000     ; AF4
    STR r1, [r0, #GPIO_AFRL]
    
    ; Set as open-drain
    LDR r1, [r0, #GPIO_OTYPER]
    ORR r1, r1, #0x000000C0     ; Open-drain for PB6-PB7
    STR r1, [r0, #GPIO_OTYPER]
    
    ; Set speed to high
    LDR r1, [r0, #GPIO_OSPEEDR]
    ORR r1, r1, #0x0000F000
    STR r1, [r0, #GPIO_OSPEEDR]
    
    ; Pull-up
    LDR r1, [r0, #GPIO_PUPDR]
    BIC r1, r1, #0x0000F000
    ORR r1, r1, #0x00005000     ; Pull-up
    STR r1, [r0, #GPIO_PUPDR]
    
    LDR r4, =I2C1_BASE
    
    ; Reset I2C
    LDR r0, [r4, #I2C_CR1]
    ORR r0, r0, #I2C_CR1_SWRST
    STR r0, [r4, #I2C_CR1]
    BIC r0, r0, #I2C_CR1_SWRST
    STR r0, [r4, #I2C_CR1]
    
    ; Set peripheral clock frequency (36MHz for APB1)
    MOV r0, #36
    STR r0, [r4, #I2C_CR2]
    
    ; Configure clock control for 100kHz
    ; CCR = fPCLK / (2 * fSCL) = 36000000 / (2 * 100000) = 180
    MOV r0, #180
    STR r0, [r4, #I2C_CCR]
    
    ; Configure rise time (max 1000ns for 100kHz)
    ; TRISE = (max_rise_time / tPCLK) + 1 = (1000ns / 27.7ns) + 1 = 37
    MOV r0, #37
    STR r0, [r4, #I2C_TRISE]
    
    ; Enable I2C
    LDR r0, [r4, #I2C_CR1]
    ORR r0, r0, #I2C_CR1_PE
    STR r0, [r4, #I2C_CR1]
    
    POP {r4, pc}

; Generate START condition
i2c_start:
    PUSH {r4, lr}
    
    LDR r4, =I2C1_BASE
    
    ; Generate START
    LDR r0, [r4, #I2C_CR1]
    ORR r0, r0, #I2C_CR1_START
    STR r0, [r4, #I2C_CR1]
    
    ; Wait for SB flag
wait_sb:
    LDR r0, [r4, #I2C_SR1]
    TST r0, #I2C_SR1_SB
    BEQ wait_sb
    
    POP {r4, pc}

; Generate STOP condition
i2c_stop:
    PUSH {r4, lr}
    
    LDR r4, =I2C1_BASE
    
    ; Generate STOP
    LDR r0, [r4, #I2C_CR1]
    ORR r0, r0, #I2C_CR1_STOP
    STR r0, [r4, #I2C_CR1]
    
    POP {r4, pc}

; Send address
; r0 = 7-bit address, r1 = direction (0=write, 1=read)
i2c_send_address:
    PUSH {r4, r5, lr}
    
    LDR r4, =I2C1_BASE
    
    ; Shift address and add direction bit
    LSL r0, r0, #1
    ORR r0, r0, r1
    
    ; Write address to DR
    STRB r0, [r4, #I2C_DR]
    
    ; Wait for ADDR flag
wait_addr:
    LDR r0, [r4, #I2C_SR1]
    TST r0, #I2C_SR1_ADDR
    BEQ wait_addr
    
    ; Clear ADDR by reading SR1 and SR2
    LDR r0, [r4, #I2C_SR1]
    LDR r0, [r4, #I2C_SR2]
    
    POP {r4, r5, pc}

; Write single byte
; r0 = data byte
i2c_write_byte:
    PUSH {r4, lr}
    
    LDR r4, =I2C1_BASE
    MOV r1, r0
    
    ; Wait for TXE
wait_txe:
    LDR r0, [r4, #I2C_SR1]
    TST r0, #I2C_SR1_TXE
    BEQ wait_txe
    
    ; Write data
    STRB r1, [r4, #I2C_DR]
    
    ; Wait for BTF (byte transfer finished)
wait_btf:
    LDR r0, [r4, #I2C_SR1]
    TST r0, #I2C_SR1_BTF
    BEQ wait_btf
    
    POP {r4, pc}

; Read single byte
; Returns: r0 = data byte
i2c_read_byte:
    PUSH {r4, lr}
    
    LDR r4, =I2C1_BASE
    
    ; Enable ACK
    LDR r0, [r4, #I2C_CR1]
    ORR r0, r0, #I2C_CR1_ACK
    STR r0, [r4, #I2C_CR1]
    
    ; Wait for RXNE
wait_rxne:
    LDR r0, [r4, #I2C_SR1]
    TST r0, #I2C_SR1_RXNE
    BEQ wait_rxne
    
    ; Read data
    LDRB r0, [r4, #I2C_DR]
    
    POP {r4, pc}

; Write to I2C device
; r0 = device address (7-bit), r1 = register, r2 = data
i2c_write_register:
    PUSH {r4, r5, r6, lr}
    
    MOV r4, r0                  ; Save address
    MOV r5, r1                  ; Save register
    MOV r6, r2                  ; Save data
    
    ; START
    BL i2c_start
    
    ; Send device address (write)
    MOV r0, r4
    MOV r1, #0                  ; Write direction
    BL i2c_send_address
    
    ; Send register address
    MOV r0, r5
    BL i2c_write_byte
    
    ; Send data
    MOV r0, r6
    BL i2c_write_byte
    
    ; STOP
    BL i2c_stop
    
    POP {r4, r5, r6, pc}

; Read from I2C device
; r0 = device address (7-bit), r1 = register
; Returns: r0 = data
i2c_read_register:
    PUSH {r4, r5, lr}
    
    MOV r4, r0                  ; Save address
    MOV r5, r1                  ; Save register
    
    ; START
    BL i2c_start
    
    ; Send device address (write)
    MOV r0, r4
    MOV r1, #0
    BL i2c_send_address
    
    ; Send register address
    MOV r0, r5
    BL i2c_write_byte
    
    ; Repeated START
    BL i2c_start
    
    ; Send device address (read)
    MOV r0, r4
    MOV r1, #1                  ; Read direction
    BL i2c_send_address
    
    ; Disable ACK before reading last byte
    LDR r1, =I2C1_BASE
    LDR r2, [r1, #I2C_CR1]
    BIC r2, r2, #I2C_CR1_ACK
    STR r2, [r1, #I2C_CR1]
    
    ; Read data
    BL i2c_read_byte
    MOV r4, r0                  ; Save data
    
    ; STOP
    BL i2c_stop
    
    MOV r0, r4                  ; Return data
    POP {r4, r5, pc}
````

