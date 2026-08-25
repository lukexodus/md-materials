## Bit-banging Protocols


Bit-banging implements communication protocols through direct GPIO (General Purpose Input/Output) manipulation in software, without dedicated hardware peripherals. This technique provides maximum flexibility for custom or non-standard protocols at the cost of CPU cycles and timing precision requirements.

**GPIO Memory-Mapped Registers:**

GPIO pins are controlled through memory-mapped registers. Typical register layout (implementation-specific):

```
Base Address: 0x20200000 (example for Broadcom BCM2835)

Offset   Register              Function
0x00     GPFSEL0-5            Function select (input/output/alternate)
0x1C     GPSET0-1             Set pins high
0x28     GPCLR0-1             Clear pins low
0x34     GPLEV0-1             Read pin levels
0x40     GPEDS0-1             Event detect status
0x4C     GPREN0-1             Rising edge detect enable
0x58     GPFEN0-1             Falling edge detect enable
0x94     GPPUD                Pull-up/down control
0x98     GPPUDCLK0-1          Pull-up/down clock
```

**Basic GPIO Operations:**

```assembly
; GPIO base address
.equ GPIO_BASE, 0x20200000

; Configure GPIO pin as output
; R0 = pin number (0-53)
gpio_set_output:
    LDR     R1, =GPIO_BASE
    
    ; Calculate GPFSEL register offset (pin/10)
    MOV     R2, R0
    MOV     R3, #10
    UDIV    R4, R2, R3           ; R4 = register index
    MLS     R2, R4, R3, R2       ; R2 = pin % 10 (bit position)
    
    ; Read current GPFSEL register
    LDR     R5, [R1, R4, LSL #2]
    
    ; Clear 3 bits for this pin
    MOV     R3, #7
    LSL     R3, R3, R2
    BIC     R5, R5, R3
    
    ; Set to output (001)
    MOV     R3, #1
    LSL     R3, R3, R2
    ORR     R5, R5, R3
    
    ; Write back
    STR     R5, [R1, R4, LSL #2]
    BX      LR

; Set GPIO pin high
; R0 = pin number
gpio_set_high:
    LDR     R1, =GPIO_BASE
    ADD     R1, R1, #0x1C        ; GPSET0 offset
    
    CMP     R0, #32
    ADDGE   R1, R1, #4           ; Use GPSET1 if pin >= 32
    SUBGE   R0, R0, #32
    
    MOV     R2, #1
    LSL     R2, R2, R0           ; Create bit mask
    STR     R2, [R1]             ; Write to set register
    BX      LR

; Set GPIO pin low
; R0 = pin number
gpio_set_low:
    LDR     R1, =GPIO_BASE
    ADD     R1, R1, #0x28        ; GPCLR0 offset
    
    CMP     R0, #32
    ADDGE   R1, R1, #4           ; Use GPCLR1 if pin >= 32
    SUBGE   R0, R0, #32
    
    MOV     R2, #1
    LSL     R2, R2, R0
    STR     R2, [R1]
    BX      LR

; Read GPIO pin state
; R0 = pin number
; Returns: R0 = 0 or 1
gpio_read:
    LDR     R1, =GPIO_BASE
    ADD     R1, R1, #0x34        ; GPLEV0 offset
    
    CMP     R0, #32
    ADDGE   R1, R1, #4           ; Use GPLEV1 if pin >= 32
    SUBGE   R0, R0, #32
    
    LDR     R2, [R1]
    LSR     R2, R2, R0           ; Shift to LSB
    AND     R0, R2, #1           ; Mask bit
    BX      LR
```

**Software Delay Implementation:**

Accurate timing requires calibrated delays. Simple loop-based delays depend on CPU frequency:

```assembly
; Delay in microseconds
; R0 = microseconds to delay
; Assumes CPU frequency known (e.g., 1GHz = 1000 cycles/μs)
; [Inference] Actual cycle count varies by implementation
delay_us:
    PUSH    {R1, R2}
    LDR     R1, =CYCLES_PER_US   ; Implementation-specific constant
    MUL     R2, R0, R1           ; Total cycles
delay_loop:
    SUBS    R2, R2, #3           ; ~3 cycles per iteration (approximate)
    BGT     delay_loop
    POP     {R1, R2}
    BX      LR

.equ CYCLES_PER_US, 1000         ; Adjust based on actual CPU frequency
```

**I²C Bit-bang Implementation:**

I²C uses two wires: SDA (data) and SCL (clock). Both are open-drain with pull-up resistors.

```assembly
.equ I2C_SDA_PIN, 2
.equ I2C_SCL_PIN, 3
.equ I2C_DELAY, 5                ; Microseconds (for 100kHz bus)

; Initialize I²C pins as inputs (high impedance = high with pull-ups)
i2c_init:
    MOV     R0, #I2C_SDA_PIN
    BL      gpio_set_input
    MOV     R0, #I2C_SCL_PIN
    BL      gpio_set_input
    BX      LR

; I²C start condition: SDA high→low while SCL high
i2c_start:
    PUSH    {LR}
    
    ; Ensure both lines high
    MOV     R0, #I2C_SDA_PIN
    BL      gpio_set_input       ; Release SDA (goes high)
    MOV     R0, #I2C_SCL_PIN
    BL      gpio_set_input       ; Release SCL (goes high)
    MOV     R0, #I2C_DELAY
    BL      delay_us
    
    ; Pull SDA low while SCL high (START condition)
    MOV     R0, #I2C_SDA_PIN
    BL      gpio_set_output
    BL      gpio_set_low
    MOV     R0, #I2C_DELAY
    BL      delay_us
    
    ; Pull SCL low
    MOV     R0, #I2C_SCL_PIN
    BL      gpio_set_output
    BL      gpio_set_low
    MOV     R0, #I2C_DELAY
    BL      delay_us
    
    POP     {PC}

; I²C stop condition: SDA low→high while SCL high
i2c_stop:
    PUSH    {LR}
    
    ; Ensure SDA is low
    MOV     R0, #I2C_SDA_PIN
    BL      gpio_set_output
    BL      gpio_set_low
    MOV     R0, #I2C_DELAY
    BL      delay_us
    
    ; Release SCL (goes high)
    MOV     R0, #I2C_SCL_PIN
    BL      gpio_set_input
    MOV     R0, #I2C_DELAY
    BL      delay_us
    
    ; Release SDA while SCL high (STOP condition)
    MOV     R0, #I2C_SDA_PIN
    BL      gpio_set_input
    MOV     R0, #I2C_DELAY
    BL      delay_us
    
    POP     {PC}

; Write one bit to I²C bus
; R0 = bit value (0 or 1)
i2c_write_bit:
    PUSH    {R4, LR}
    MOV     R4, R0               ; Save bit value
    
    ; Set SDA according to bit value
    MOV     R0, #I2C_SDA_PIN
    CMP     R4, #0
    BEQ     write_bit_low
    
write_bit_high:
    BL      gpio_set_input       ; Release SDA (high)
    B       write_bit_clock
    
write_bit_low:
    BL      gpio_set_output
    BL      gpio_set_low
    
write_bit_clock:
    ; Clock pulse
    MOV     R0, #I2C_DELAY
    BL      delay_us
    
    MOV     R0, #I2C_SCL_PIN
    BL      gpio_set_input       ; Release SCL (clock high)
    MOV     R0, #I2C_DELAY
    BL      delay_us
    
    MOV     R0, #I2C_SCL_PIN
    BL      gpio_set_output
    BL      gpio_set_low         ; Pull SCL low
    MOV     R0, #I2C_DELAY
    BL      delay_us
    
    POP     {R4, PC}

; Read one bit from I²C bus
; Returns: R0 = bit value
i2c_read_bit:
    PUSH    {R4, LR}
    
    ; Release SDA (allow slave to drive)
    MOV     R0, #I2C_SDA_PIN
    BL      gpio_set_input
    MOV     R0, #I2C_DELAY
    BL      delay_us
    
    ; Clock high
    MOV     R0, #I2C_SCL_PIN
    BL      gpio_set_input
    MOV     R0, #I2C_DELAY
    BL      delay_us
    
    ; Read SDA
    MOV     R0, #I2C_SDA_PIN
    BL      gpio_read
    MOV     R4, R0               ; Save bit value
    
    ; Clock low
    MOV     R0, #I2C_DELAY
    BL      delay_us
    MOV     R0, #I2C_SCL_PIN
    BL      gpio_set_output
    BL      gpio_set_low
    
    MOV     R0, R4               ; Return bit value
    POP     {R4, PC}

; Write one byte to I²C bus
; R0 = byte to write
; Returns: R0 = ACK bit (0=ACK, 1=NACK)
i2c_write_byte:
    PUSH    {R4, R5, LR}
    MOV     R4, R0               ; Save byte
    MOV     R5, #8               ; Bit counter
    
write_byte_loop:
    ; Extract MSB
    MOV     R0, R4, LSR #7
    AND     R0, R0, #1
    BL      i2c_write_bit
    
    LSL     R4, R4, #1           ; Shift to next bit
    SUBS    R5, R5, #1
    BNE     write_byte_loop
    
    ; Read ACK bit
    BL      i2c_read_bit
    
    POP     {R4, R5, PC}

; Read one byte from I²C bus
; R0 = send ACK (0) or NACK (1)
; Returns: R0 = byte read
i2c_read_byte:
    PUSH    {R4, R5, R6, LR}
    MOV     R6, R0               ; Save ACK/NACK flag
    MOV     R4, #0               ; Accumulator
    MOV     R5, #8               ; Bit counter
    
read_byte_loop:
    BL      i2c_read_bit
    LSL     R4, R4, #1           ; Shift left
    ORR     R4, R4, R0           ; Add new bit
    SUBS    R5, R5, #1
    BNE     read_byte_loop
    
    ; Send ACK/NACK
    MOV     R0, R6
    BL      i2c_write_bit
    
    MOV     R0, R4               ; Return byte
    POP     {R4, R5, R6, PC}

; Complete I²C transaction example: write to device
; R0 = device address (7-bit)
; R1 = register address
; R2 = data byte
i2c_write_register:
    PUSH    {R4, R5, R6, LR}
    MOV     R4, R0
    MOV     R5, R1
    MOV     R6, R2
    
    ; Start condition
    BL      i2c_start
    
    ; Send device address with write bit (0)
    LSL     R0, R4, #1           ; Address << 1
    BIC     R0, R0, #1           ; Clear bit 0 (write)
    BL      i2c_write_byte
    CMP     R0, #0               ; Check ACK
    BNE     i2c_error
    
    ; Send register address
    MOV     R0, R5
    BL      i2c_write_byte
    CMP     R0, #0
    BNE     i2c_error
    
    ; Send data byte
    MOV     R0, R6
    BL      i2c_write_byte
    CMP     R0, #0
    BNE     i2c_error
    
    ; Stop condition
    BL      i2c_stop
    
    MOV     R0, #0               ; Success
    POP     {R4, R5, R6, PC}
    
i2c_error:
    BL      i2c_stop
    MOV     R0, #-1              ; Error
    POP     {R4, R5, R6, PC}
```

**SPI Bit-bang Implementation:**

SPI uses four signals: MOSI (Master Out Slave In), MISO (Master In Slave Out), SCK (clock), and CS (chip select).

```assembly
.equ SPI_MOSI_PIN, 10
.equ SPI_MISO_PIN, 9
.equ SPI_SCK_PIN, 11
.equ SPI_CS_PIN, 8
.equ SPI_DELAY, 1                ; Microseconds

; Initialize SPI pins
spi_init:
    PUSH    {LR}
    
    MOV     R0, #SPI_MOSI_PIN
    BL      gpio_set_output
    MOV     R0, #SPI_SCK_PIN
    BL      gpio_set_output
    MOV     R0, #SPI_CS_PIN
    BL      gpio_set_output
    MOV     R0, #SPI_MISO_PIN
    BL      gpio_set_input
    
    ; CS high (inactive), SCK low
    MOV     R0, #SPI_CS_PIN
    BL      gpio_set_high
    MOV     R0, #SPI_SCK_PIN
    BL      gpio_set_low
    
    POP     {PC}

; SPI transfer byte (full duplex)
; R0 = byte to send
; Returns: R0 = byte received
spi_transfer:
    PUSH    {R4, R5, R6, LR}
    MOV     R4, R0               ; Byte to send
    MOV     R5, #0               ; Byte received
    MOV     R6, #8               ; Bit counter
    
spi_transfer_loop:
    ; Write MOSI bit (MSB first)
    MOV     R0, R4, LSR #7
    AND     R0, R0, #1
    
    CMP     R0, #0
    MOV     R0, #SPI_MOSI_PIN
    BEQ     spi_mosi_low
    BL      gpio_set_high
    B       spi_clock_pulse
    
spi_mosi_low:
    BL      gpio_set_low
    
spi_clock_pulse:
    ; Small delay
    MOV     R0, #SPI_DELAY
    BL      delay_us
    
    ; Clock high
    MOV     R0, #SPI_SCK_PIN
    BL      gpio_set_high
    MOV     R0, #SPI_DELAY
    BL      delay_us
    
    ; Read MISO bit
    MOV     R0, #SPI_MISO_PIN
    BL      gpio_read
    LSL     R5, R5, #1           ; Shift received byte
    ORR     R5, R5, R0           ; Add new bit
    
    ; Clock low
    MOV     R0, #SPI_SCK_PIN
    BL      gpio_set_low
    
    ; Next bit
    LSL     R4, R4, #1
    SUBS    R6, R6, #1
    BNE     spi_transfer_loop
    
    MOV     R0, R5               ; Return received byte
    POP     {R4, R5, R6, PC}

; SPI transaction with CS control
; R0 = pointer to TX buffer
; R1 = pointer to RX buffer
; R2 = length
spi_transaction:
    PUSH    {R4, R5, R6, R7, LR}
    MOV     R4, R0               ; TX buffer
    MOV     R5, R1               ; RX buffer
    MOV     R6, R2               ; Length
    
    ; Assert CS (low)
    MOV     R0, #SPI_CS_PIN
    BL      gpio_set_low
    MOV     R0, #SPI_DELAY
    BL      delay_us
    
spi_trans_loop:
    ; Load byte to send
    LDRB    R0, [R4], #1
    BL      spi_transfer
    
    ; Store received byte
    STRB    R0, [R5], #1
    
    SUBS    R6, R6, #1
    BNE     spi_trans_loop
    
    ; Deassert CS (high)
    MOV     R0, #SPI_DELAY
    BL      delay_us
    MOV     R0, #SPI_CS_PIN
    BL      gpio_set_high
    
    POP     {R4, R5, R6, R7, PC}
```

**1-Wire Bit-bang Implementation:**

1-Wire protocol uses a single bidirectional data line with specific timing requirements.

```assembly
.equ ONEWIRE_PIN, 4

; 1-Wire reset pulse
; Returns: R0 = 0 if device present, 1 if no device
onewire_reset:
    PUSH    {R4, LR}
    
    ; Pull line low for 480μs
    MOV     R0, #ONEWIRE_PIN
    BL      gpio_set_output
    BL      gpio_set_low
    MOV     R0, #480
    BL      delay_us
    
    ; Release line and wait 70μs
    MOV     R0, #ONEWIRE_PIN
    BL      gpio_set_input
    MOV     R0, #70
    BL      delay_us
    
    ; Read presence pulse
    MOV     R0, #ONEWIRE_PIN
    BL      gpio_read
    MOV     R4, R0
    
    ; Wait for line to go high
    MOV     R0, #410
    BL      delay_us
    
    MOV     R0, R4
    EOR     R0, R0, #1           ; Invert (0=present, 1=not present)
    POP     {R4, PC}

; Write 1-Wire bit
; R0 = bit value
onewire_write_bit:
    PUSH    {R4, LR}
    MOV     R4, R0
    
    ; Pull line low
    MOV     R0, #ONEWIRE_PIN
    BL      gpio_set_output
    BL      gpio_set_low
    
    CMP     R4, #0
    BEQ     onewire_write_0
    
    ; Write 1: release after 6μs
    MOV     R0, #6
    BL      delay_us
    MOV     R0, #ONEWIRE_PIN
    BL      gpio_set_input
    MOV     R0, #64
    BL      delay_us
    B       onewire_write_done
    
onewire_write_0:
    ; Write 0: keep low for 60μs
    MOV     R0, #60
    BL      delay_us
    MOV     R0, #ONEWIRE_PIN
    BL      gpio_set_input
    MOV     R0, #10
    BL      delay_us
    
onewire_write_done:
    POP     {R4, PC}

; Read 1-Wire bit
; Returns: R0 = bit value
onewire_read_bit:
    PUSH    {R4, LR}
    
    ; Pull line low for 3μs
    MOV     R0, #ONEWIRE_PIN
    BL      gpio_set_output
    BL      gpio_set_low
    MOV     R0, #3
    BL      delay_us
    
    ; Release and wait 10μs
    MOV     R0, #ONEWIRE_PIN
    BL      gpio_set_input
    MOV     R0, #10
    BL      delay_us
    
    ; Read bit
    MOV     R0, #ONEWIRE_PIN
    BL      gpio_read
    MOV     R4, R0
    
    ; Wait for slot end
    MOV     R0, #53
    BL      delay_us
    
    MOV     R0, R4
    POP     {R4, PC}
```

**Timing Accuracy Considerations:**

Bit-banging requires precise timing. [Inference] Factors affecting accuracy include:

- CPU frequency variation
- Interrupt latency (interrupts must be disabled during critical timing)
- Cache misses and memory access timing
- Pipeline stalls

**Example** with interrupt protection:

```assembly
i2c_write_byte_protected:
    PUSH    {R4, LR}
    MOV     R4, R0
    
    ; Disable interrupts
    CPSID   i                    ; Disable IRQ and FIQ
    
    ; Perform timing-critical operation
    MOV     R0, R4
    BL      i2c_write_byte_internal
    
    ; Re-enable interrupts
    CPSIE   i
    
    POP     {R4, PC}
```

