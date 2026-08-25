## Memory-Mapped I/O


Memory-mapped I/O maps hardware device registers into the processor's address space, allowing hardware control using standard load and store instructions.

### Memory-Mapped I/O Concepts

**Address Space Organization:**

```
Typical ARM System Memory Map:

0x00000000 - 0x0FFFFFFF: Flash/ROM (code storage)
0x20000000 - 0x2FFFFFFF: SRAM (data, stack)
0x40000000 - 0x5FFFFFFF: Peripherals (memory-mapped I/O)
0x60000000 - 0x9FFFFFFF: External RAM/devices
0xE0000000 - 0xE00FFFFF: System peripherals (Cortex-M)
```

**Memory-Mapped Register Access:**

```assembly
; Define peripheral base addresses
.equ PERIPHERAL_BASE, 0x40000000
.equ GPIO_BASE,       0x40020000
.equ UART_BASE,       0x40011000

; Reading from device register
LDR r0, =GPIO_BASE
LDR r1, [r0]                    ; Read GPIO data register

; Writing to device register
LDR r0, =GPIO_BASE
MOV r1, #0xFF
STR r1, [r0]                    ; Write to GPIO data register
```

### Volatile Access Requirements

Memory-mapped I/O requires special handling to prevent compiler/processor optimizations that might break hardware interaction:

```assembly
; Volatile read - must actually read from hardware
volatile_read:
    LDR r0, =PERIPHERAL_ADDR
    LDR r1, [r0]                ; Hardware read
    ; Compiler cannot optimize away even if value unused
    BX lr

; Non-volatile optimization (wrong for hardware)
; Compiler might:
; - Reorder reads/writes
; - Cache values in registers
; - Eliminate "redundant" accesses
```

**Memory Barriers for Hardware Access:**

```assembly
; Ensure ordering of hardware accesses
    LDR r0, =GPIO_BASE
    MOV r1, #1
    STR r1, [r0]                ; Write to GPIO
    
    DMB                         ; Data Memory Barrier
                                ; Ensures write completes before next access
    
    LDR r2, [r0, #4]            ; Read status register
                                ; Guaranteed to see previous write
```

### Read-Modify-Write Operations

**Safe Bit Manipulation:**

```assembly
; Set specific bit in hardware register
; r0 = register address, r1 = bit position

set_bit_safe:
    LDR r2, [r0]                ; Read current value
    MOV r3, #1
    LSL r3, r3, r1              ; Create bit mask
    ORR r2, r2, r3              ; Set bit
    STR r2, [r0]                ; Write back
    BX lr

; Clear specific bit
clear_bit_safe:
    LDR r2, [r0]                ; Read
    MOV r3, #1
    LSL r3, r3, r1              ; Create mask
    BIC r2, r2, r3              ; Clear bit
    STR r2, [r0]                ; Write back
    BX lr

; Toggle bit
toggle_bit:
    LDR r2, [r0]
    MOV r3, #1
    LSL r3, r3, r1
    EOR r2, r2, r3              ; Toggle bit
    STR r2, [r0]
    BX lr
```

**Atomic Hardware Operations:**

```assembly
; ARM Cortex-M specific: Bit-band aliasing
; Allows atomic bit operations without read-modify-write

; Bit-band regions:
; 0x20000000-0x200FFFFF -> 0x22000000-0x23FFFFFF (SRAM)
; 0x40000000-0x400FFFFF -> 0x42000000-0x43FFFFFF (Peripheral)

; Calculate bit-band alias address
; alias_addr = bit_band_base + (byte_offset * 32) + (bit_number * 4)

set_bit_bitband:
    ; r0 = register address, r1 = bit number
    LDR r2, =0x42000000         ; Peripheral bit-band base
    LDR r3, =0x40000000         ; Peripheral region base
    
    SUB r0, r0, r3              ; Get offset from base
    LSL r0, r0, #5              ; Multiply by 32
    LSL r1, r1, #2              ; Multiply bit number by 4
    ADD r0, r0, r1              ; Add bit offset
    ADD r0, r0, r2              ; Add bit-band base
    
    MOV r1, #1
    STR r1, [r0]                ; Atomic bit set
    BX lr
```

### Direct Memory Access (DMA) Setup

**Configuring DMA Controller:**

```assembly
; Example: STM32 DMA configuration
.equ DMA1_BASE,     0x40020000
.equ DMA1_CH1_BASE, 0x40020008

.equ DMA_CCR_OFFSET,   0x00     ; Configuration register
.equ DMA_CNDTR_OFFSET, 0x04     ; Number of data
.equ DMA_CPAR_OFFSET,  0x08     ; Peripheral address
.equ DMA_CMAR_OFFSET,  0x0C     ; Memory address

; DMA_CCR flags
.equ DMA_CCR_EN,       (1 << 0)  ; Enable
.equ DMA_CCR_TCIE,     (1 << 1)  ; Transfer complete interrupt
.equ DMA_CCR_HTIE,     (1 << 2)  ; Half transfer interrupt
.equ DMA_CCR_TEIE,     (1 << 3)  ; Transfer error interrupt
.equ DMA_CCR_DIR,      (1 << 4)  ; Direction: 0=peripheral to memory
.equ DMA_CCR_CIRC,     (1 << 5)  ; Circular mode
.equ DMA_CCR_PINC,     (1 << 6)  ; Peripheral increment
.equ DMA_CCR_MINC,     (1 << 7)  ; Memory increment
.equ DMA_CCR_PSIZE_8,  (0 << 8)  ; Peripheral size: 8-bit
.equ DMA_CCR_PSIZE_16, (1 << 8)  ; 16-bit
.equ DMA_CCR_PSIZE_32, (2 << 8)  ; 32-bit
.equ DMA_CCR_MSIZE_8,  (0 << 10) ; Memory size: 8-bit
.equ DMA_CCR_MSIZE_16, (1 << 10) ; 16-bit
.equ DMA_CCR_MSIZE_32, (2 << 10) ; 32-bit
.equ DMA_CCR_PL_LOW,   (0 << 12) ; Priority: low
.equ DMA_CCR_PL_MED,   (1 << 12) ; Medium
.equ DMA_CCR_PL_HIGH,  (2 << 12) ; High
.equ DMA_CCR_PL_VHIGH, (3 << 12) ; Very high
.equ DMA_CCR_MEM2MEM,  (1 << 14) ; Memory to memory

dma_setup:
    PUSH {r4, r5, lr}
    
    ; r0 = source address
    ; r1 = destination address
    ; r2 = transfer count
    
    LDR r3, =DMA1_CH1_BASE
    
    ; Disable DMA channel first
    LDR r4, [r3, #DMA_CCR_OFFSET]
    BIC r4, r4, #DMA_CCR_EN
    STR r4, [r3, #DMA_CCR_OFFSET]
    
    ; Set peripheral address (source)
    STR r0, [r3, #DMA_CPAR_OFFSET]
    
    ; Set memory address (destination)
    STR r1, [r3, #DMA_CMAR_OFFSET]
    
    ; Set transfer count
    STR r2, [r3, #DMA_CNDTR_OFFSET]
    
    ; Configure: memory to memory, 32-bit, increment both, high priority
    MOV r4, #(DMA_CCR_MEM2MEM | DMA_CCR_MINC | DMA_CCR_PINC)
    ORR r4, r4, #(DMA_CCR_MSIZE_32 | DMA_CCR_PSIZE_32)
    ORR r4, r4, #DMA_CCR_PL_HIGH
    ORR r4, r4, #DMA_CCR_TCIE           ; Enable transfer complete interrupt
    STR r4, [r3, #DMA_CCR_OFFSET]
    
    ; Enable DMA channel
    LDR r4, [r3, #DMA_CCR_OFFSET]
    ORR r4, r4, #DMA_CCR_EN
    STR r4, [r3, #DMA_CCR_OFFSET]
    
    POP {r4, r5, pc}
```

### Cache Coherency Considerations

**Ensuring Cache Coherency with DMA:**

```assembly
; ARM Cortex-A with caches

; Before DMA read (peripheral -> memory):
; Invalidate data cache to prevent reading stale data

dma_prepare_read:
    ; r0 = buffer address, r1 = size
    PUSH {r4, lr}
    
    ; Clean and invalidate cache lines
    MOV r2, r0                  ; Start address
    ADD r3, r0, r1              ; End address
    
invalidate_loop:
    DC CIVAC, r2                ; Clean and invalidate cache line
    ADD r2, r2, #64             ; Cache line size (typically 64 bytes)
    CMP r2, r3
    BLT invalidate_loop
    
    DSB                         ; Ensure completion
    
    POP {r4, pc}

; After DMA write (memory -> peripheral):
; Clean data cache to ensure data written to memory

dma_prepare_write:
    ; r0 = buffer address, r1 = size
    PUSH {r4, lr}
    
    MOV r2, r0
    ADD r3, r0, r1
    
clean_loop:
    DC CVAC, r2                 ; Clean cache line
    ADD r2, r2, #64
    CMP r2, r3
    BLT clean_loop
    
    DSB                         ; Ensure completion
    
    POP {r4, pc}
```

