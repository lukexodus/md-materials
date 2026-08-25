## UART Communication


Universal Asynchronous Receiver/Transmitter provides serial communication. UART implementations vary, but the PrimeCell UART (PL011) is common in ARM systems.

**PL011 UART Registers:**

```assembly
; UART register offsets from base address
.equ UART_BASE, 0x10009000           ; Example base address

.equ UART_DR, 0x00                   ; Data register
.equ UART_RSR_ECR, 0x04              ; Receive status/error clear
.equ UART_FR, 0x18                   ; Flag register
.equ UART_ILPR, 0x20                 ; IrDA low-power counter
.equ UART_IBRD, 0x24                 ; Integer baud rate divisor
.equ UART_FBRD, 0x28                 ; Fractional baud rate divisor
.equ UART_LCRH, 0x2C                 ; Line control register
.equ UART_CR, 0x30                   ; Control register
.equ UART_IFLS, 0x34                 ; Interrupt FIFO level select
.equ UART_IMSC, 0x38                 ; Interrupt mask set/clear
.equ UART_RIS, 0x3C                  ; Raw interrupt status
.equ UART_MIS, 0x40                  ; Masked interrupt status
.equ UART_ICR, 0x44                  ; Interrupt clear
.equ UART_DMACR, 0x48                ; DMA control

; Flag register bits
.equ UART_FR_TXFF, (1 << 5)          ; Transmit FIFO full
.equ UART_FR_RXFE, (1 << 4)          ; Receive FIFO empty
.equ UART_FR_BUSY, (1 << 3)          ; UART busy
.equ UART_FR_TXFE, (1 << 7)          ; Transmit FIFO empty

; Control register bits
.equ UART_CR_UARTEN, (1 << 0)        ; UART enable
.equ UART_CR_TXE, (1 << 8)           ; Transmit enable
.equ UART_CR_RXE, (1 << 9)           ; Receive enable

; Line control register bits
.equ UART_LCRH_WLEN_8, (3 << 5)      ; 8-bit word length
.equ UART_LCRH_WLEN_7, (2 << 5)      ; 7-bit word length
.equ UART_LCRH_FEN, (1 << 4)         ; FIFO enable
.equ UART_LCRH_STP2, (1 << 3)        ; 2 stop bits
.equ UART_LCRH_EPS, (1 << 2)         ; Even parity select
.equ UART_LCRH_PEN, (1 << 1)         ; Parity enable

; Interrupt bits
.equ UART_INT_OE, (1 << 10)          ; Overrun error
.equ UART_INT_BE, (1 << 9)           ; Break error
.equ UART_INT_PE, (1 << 8)           ; Parity error
.equ UART_INT_FE, (1 << 7)           ; Framing error
.equ UART_INT_RT, (1 << 6)           ; Receive timeout
.equ UART_INT_TX, (1 << 5)           ; Transmit
.equ UART_INT_RX, (1 << 4)           ; Receive
```

**UART Initialization:**

Baud rate calculation: `BAUDDIV = (UARTCLK) / (16 × Baud rate)`

Integer part: `IBRD = integer(BAUDDIV)`

Fractional part: `FBRD = integer((BAUDDIV - IBRD) × 64 + 0.5)`

```assembly
; Initialize UART
; R0 = baud rate (e.g., 115200)
uart_init:
    PUSH    {R4, R5, R6, LR}
    MOV     R6, R0                   ; Save baud rate
    
    LDR     R4, =UART_BASE
    
    ; Disable UART
    MOV     R0, #0
    STR     R0, [R4, #UART_CR]
    
    ; Wait for current transmission to complete
    LDR     R0, [R4, #UART_FR]
    TST     R0, #UART_FR_BUSY
    BNE     .-8
    
    ; Flush FIFO
    LDR     R0, [R4, #UART_LCRH]
    BIC     R0, R0, #UART_LCRH_FEN
    STR     R0, [R4, #UART_LCRH]
    
    ; Calculate baud rate divisor
    ; UART clock frequency (example: 24 MHz)
    LDR     R0, =24000000
    LSL     R1, R6, #4               ; Baud × 16
    UDIV    R2, R0, R1               ; Integer part
    MUL     R3, R2, R1
    SUB     R3, R0, R3               ; Remainder
    MOV     R0, #64
    MUL     R3, R3, R0
    UDIV    R3, R3, R1               ; Fractional part
    
    ; Write baud rate divisors
    STR     R2, [R4, #UART_IBRD]
    STR     R3, [R4, #UART_FBRD]
    
    ; Configure line control: 8N1 (8 data, no parity, 1 stop)
    MOV     R0, #UART_LCRH_WLEN_8
    ORR     R0, R0, #UART_LCRH_FEN   ; Enable FIFO
    STR     R0, [R4, #UART_LCRH]
    
    ; Disable all interrupts (polling mode)
    MOV     R0, #0
    STR     R0, [R4, #UART_IMSC]
    
    ; Enable UART, TX, and RX
    MOV     R0, #UART_CR_UARTEN
    ORR     R0, R0, #UART_CR_TXE
    ORR     R0, R0, #UART_CR_RXE
    STR     R0, [R4, #UART_CR]
    
    POP     {R4, R5, R6, PC}

; Send one character (blocking)
; R0 = character to send
uart_putc:
    PUSH    {R4, R5}
    MOV     R5, R0                   ; Save character
    LDR     R4, =UART_BASE
    
    ; Wait until TX FIFO not full
wait_tx:
    LDR     R0, [R4, #UART_FR]
    TST     R0, #UART_FR_TXFF
    BNE     wait_tx
    
    ; Write character to data register
    STR     R5, [R4, #UART_DR]
    
    POP     {R4, R5}
    BX      LR

; Receive one character (blocking)
; Returns: R0 = received character
uart_getc:
    PUSH    {R4}
    LDR     R4, =UART_BASE
    
    ; Wait until RX FIFO not empty
wait_rx:
    LDR     R0, [R4, #UART_FR]
    TST     R0, #UART_FR_RXFE
    BNE     wait_rx
    
    ; Read character from data register
    LDR     R0, [R4, #UART_DR]
    AND     R0, R0, #0xFF            ; Mask to 8 bits
    
    POP     {R4}
    BX      LR

; Send string (null-terminated)
; R0 = pointer to string
uart_puts:
    PUSH    {R4, R5, LR}
    MOV     R4, R0                   ; Save string pointer
    
puts_loop:
    LDRB    R5, [R4], #1             ; Load character, increment
    CMP     R5, #0                   ; Check for null terminator
    BEQ     puts_done
    
    MOV     R0, R5
    BL      uart_putc                ; Send character
    B       puts_loop
    
puts_done:
    POP     {R4, R5, PC}

; Check if character available (non-blocking)
; Returns: R0 = 1 if character available, 0 otherwise
uart_available:
    LDR     R0, =UART_BASE
    LDR     R0, [R0, #UART_FR]
    TST     R0, #UART_FR_RXFE
    MOVEQ   R0, #1                   ; Not empty = available
    MOVNE   R0, #0                   ; Empty = not available
    BX      LR

; Read with timeout
; R0 = timeout in microseconds
; Returns: R0 = character (0-255), or -1 if timeout
uart_getc_timeout:
    PUSH    {R4, R5, R6, LR}
    MOV     R6, R0                   ; Save timeout
    
    ; Read start time
    MRRC    p15, 0, R4, R5, c14      ; CNTPCT
    
    ; Calculate timeout cycles
    MRC     p15, 0, R0, c14, c0, 0   ; CNTFRQ
    MUL     R1, R6, R0
    LDR     R2, =1000000
    UDIV    R1, R1, R2
    ADD     R5, R4, R1               ; End time = start + timeout
    
getc_timeout_loop:
    ; Check if character available
    BL      uart_available
    CMP     R0, #1
    BEQ     getc_timeout_read
    
    ; Check timeout
    MRRC    p15, 0, R0, R1, c14      ; Current time
    CMP     R0, R5
    BGE     getc_timeout_expired
    
    B       getc_timeout_loop
    
getc_timeout_read:
    BL      uart_getc
    B       getc_timeout_done
    
getc_timeout_expired:
    MVN     R0, #0                   ; Return -1
    
getc_timeout_done:
    POP     {R4, R5, R6, PC}
```

**UART with Interrupts:**

```assembly
; Enable UART interrupts
; R0 = interrupt mask (UART_INT_* flags)
uart_enable_interrupts:
    LDR     R1, =UART_BASE
    STR     R0, [R1, #UART_IMSC]
    BX      LR

; UART interrupt handler
uart_irq_handler:
    PUSH    {R0-R4, LR}
    LDR     R4, =UART_BASE
    
    ; Read interrupt status
    LDR     R0, [R4, #UART_MIS]      ; Masked interrupt status
    
    ; Check RX interrupt
    TST     R0, #UART_INT_RX
    BEQ     check_tx
    
    ; Handle received data
    LDR     R1, [R4, #UART_DR]
    AND     R1, R1, #0xFF
    BL      uart_rx_handler          ; User handler
    
    ; Clear RX interrupt
    MOV     R2, #UART_INT_RX
    STR     R2, [R4, #UART_ICR]
    
check_tx:
    ; Check TX interrupt
    TST     R0, #UART_INT_TX
    BEQ     check_errors
    
    ; Handle transmit ready
    BL      uart_tx_handler          ; User handler
    
    ; Clear TX interrupt
    MOV     R2, #UART_INT_TX
    STR     R2, [R4, #UART_ICR]
    
check_errors:
    ; Check for errors
    TST     R0, #(UART_INT_OE | UART_INT_BE | UART_INT_PE | UART_INT_FE)
    BEQ     uart_irq_done
    
    ; Handle errors
    BL      uart_error_handler
    
    ; Clear error interrupts
    MOV     R2, #(UART_INT_OE | UART_INT_BE | UART_INT_PE | UART_INT_FE)
    STR     R2, [R4, #UART_ICR]
    
uart_irq_done:
    POP     {R0-R4, PC}
```

**Circular Buffer for UART:**

```assembly
.data
.align 2
rx_buffer:      .space 256           ; Receive buffer
rx_head:        .word 0              ; Write pointer
rx_tail:        .word 0              ; Read pointer
rx_buffer_size: .word 256

tx_buffer:      .space 256           ; Transmit buffer
tx_head:        .word 0
tx_tail:        .word 0
tx_buffer_size: .word 256

.text
; UART RX interrupt handler (called from uart_irq_handler)
; R1 = received character
uart_rx_handler:
    PUSH    {R4-R6}
    
    ; Load buffer pointers
    LDR     R4, =rx_head
    LDR     R5, [R4]                 ; Head index
    LDR     R6, =rx_buffer_size
    LDR     R6, [R6]
    
    ; Store character in buffer
    LDR     R2, =rx_buffer
    STRB    R1, [R2, R5]
    
    ; Increment head with wrap
    ADD     R5, R5, #1
    CMP     R5, R6
    MOVGE   R5, #0
    STR     R5, [R4]
    
    ; Check for buffer overflow (head == tail after increment)
    LDR     R4, =rx_tail
    LDR     R2, [R4]
    CMP     R5, R2
    BEQ     rx_overflow
    
    POP     {R4-R6}
    BX      LR
    
rx_overflow:
    ; Handle overflow (discard oldest data)
    ADD     R2, R2, #1
    CMP     R2, R6
    MOVGE   R2, #0
    STR     R2, [R4]
    POP     {R4-R6}
    BX      LR

; Read character from RX buffer
; Returns: R0 = character, or -1 if buffer empty
uart_buffer_getc:
    PUSH    {R4-R6}
    
    ; Load pointers
    LDR     R4, =rx_head
    LDR     R5, =rx_tail
    LDR     R0, [R4]                 ; Head
    LDR     R1, [R5]                 ; Tail
    
    ; Check if buffer empty
    CMP     R0, R1
    BEQ     buffer_empty
    
    ; Read character
    LDR     R2, =rx_buffer
    LDRB    R0, [R2, R1]
    
    ; Increment tail with wrap
    LDR     R6, =rx_buffer_size
    LDR     R6, [R6]
    ADD     R1, R1, #1
    CMP     R1, R6
    MOVGE   R1, #0
    STR     R1, [R5]
    
    POP     {R4-R6}
    BX      LR
    
buffer_empty:
    MVN     R0, #0                   ; Return -1
    POP     {R4-R6}
    BX      LR

; UART TX interrupt handler
uart_tx_handler:
    PUSH    {R4-R6, LR}
    
    ; Load pointers
    LDR     R4, =tx_head
    LDR     R5, =tx_tail
    LDR     R0, [R4]                 ; Head
    LDR     R1, [R5]                 ; Tail
    
    ; Check if buffer empty
    CMP     R0, R1
    BEQ     tx_buffer_empty
    
    ; Read character from buffer
    LDR     R2, =tx_buffer
    LDRB    R3, [R2, R1]
    
    ; Send character
    LDR     R6, =UART_BASE
    STR     R3, [R6, #UART_DR]
    
    ; Increment tail with wrap
    LDR     R6, =tx_buffer_size
    LDR     R6, [R6]
    ADD     R1, R1, #1
    CMP     R1, R6
    MOVGE   R1, #0
    STR     R1, [R5]
    
    POP     {R4-R6, PC}
    
tx_buffer_empty:
    ; Disable TX interrupt when buffer empty
    LDR     R0, =UART_BASE
    LDR     R1, [R0, #UART_IMSC]
    BIC     R1, R1, #UART_INT_TX
    STR     R1, [R0, #UART_IMSC]
    
    POP     {R4-R6, PC}

; Write character to TX buffer
; R0 = character
uart_buffer_putc:
    PUSH    {R4-R6}
    MOV     R6, R0                   ; Save character
    
    ; Load pointers
    LDR     R4, =tx_head
    LDR     R5, [R4]                 ; Head
    LDR     R3, =tx_buffer_size
    LDR     R3, [R3]
    
    ; Calculate next head position
    ADD     R0, R5, #1
    CMP     R0, R3
    MOVGE   R0, #0
    
    ; Wait if buffer full (head+1 == tail)
    LDR     R1, =tx_tail
wait_tx_space:
    LDR     R2, [R1]
    CMP     R0, R2
    BEQ     wait_tx_space
    
    ; Store character
    LDR     R2, =tx_buffer
    STRB    R6, [R2, R5]
    STR     R0, [R4]                 ; Update head
    
    ; Enable TX interrupt
    LDR     R0, =UART_BASE
    LDR     R1, [R0, #UART_IMSC]
    ORR     R1, R1, #UART_INT_TX
    STR     R1, [R0, #UART_IMSC]
    
    POP     {R4-R6}
    BX      LR
```

**DMA-based UART Transfer:**

```assembly
; Configure UART for DMA transfer
; R0 = source buffer address
; R1 = length
uart_dma_transmit:
    PUSH    {R4-R6, LR}
    MOV     R4, R0                   ; Source address
    MOV     R5, R1                   ; Length
    
    ; Enable UART DMA
    LDR     R6, =UART_BASE
    MOV     R0, #1                   ; TX DMA enable
    STR     R0, [R6, #UART_DMACR]
    
    ; Configure DMA controller (implementation-specific)
    ; Example: PL080 DMA
    LDR     R0, =DMA_BASE
    MOV     R1, R4                   ; Source address
    LDR     R2, =UART_BASE
    ADD     R2, R2, #UART_DR         ; Destination (UART DR)
    MOV     R3, R5                   ; Transfer size
    
    ; DMA configuration (simplified)
    STR     R1, [R0, #DMA_SRC]
    STR     R2, [R0, #DMA_DST]
    STR     R3, [R0, #DMA_LEN]
    
    ; Set DMA control: memory-to-peripheral, increment source
    LDR     R1, =DMA_CTRL_M2P | DMA_CTRL_SRC_INC
    STR     R1, [R0, #DMA_CTRL]
    
    ; Enable DMA channel
    MOV     R1, #1
    STR     R1, [R0, #DMA_ENABLE]
    
    POP     {R4-R6, PC}
```

