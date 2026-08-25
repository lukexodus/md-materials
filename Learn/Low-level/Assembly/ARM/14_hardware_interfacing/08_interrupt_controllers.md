## Interrupt Controllers


ARM systems use interrupt controllers to manage multiple interrupt sources. The Generic Interrupt Controller (GIC) is the standard for Cortex-A processors.

**GIC Architecture:**

The GIC consists of two main components:

**Distributor (GICD):** Manages interrupt prioritization, routing to CPU cores, and enabling/disabling interrupts.

**CPU Interface (GICC):** Per-core interface for acknowledging interrupts and signaling end-of-interrupt (EOI).

**Interrupt Types:**

- **SGI (Software Generated Interrupt):** IDs 0-15, used for inter-processor communication
- **PPI (Private Peripheral Interrupt):** IDs 16-31, per-core peripherals (timers, watchdog)
- **SPI (Shared Peripheral Interrupt):** IDs 32-1019, shared peripherals

**GIC Register Offsets:**

```assembly
; Distributor registers
.equ GICD_BASE, 0x10001000           ; Example base address
.equ GICD_CTLR, 0x000                ; Distributor control
.equ GICD_TYPER, 0x004               ; Interrupt controller type
.equ GICD_IIDR, 0x008                ; Distributor implementer ID
.equ GICD_IGROUPR, 0x080             ; Interrupt group registers
.equ GICD_ISENABLER, 0x100           ; Interrupt set-enable
.equ GICD_ICENABLER, 0x180           ; Interrupt clear-enable
.equ GICD_ISPENDR, 0x200             ; Interrupt set-pending
.equ GICD_ICPENDR, 0x280             ; Interrupt clear-pending
.equ GICD_ISACTIVER, 0x300           ; Interrupt set-active
.equ GICD_ICACTIVER, 0x380           ; Interrupt clear-active
.equ GICD_IPRIORITYR, 0x400          ; Interrupt priority
.equ GICD_ITARGETSR, 0x800           ; Interrupt processor targets
.equ GICD_ICFGR, 0xC00               ; Interrupt configuration
.equ GICD_SGIR, 0xF00                ; Software generated interrupt

; CPU Interface registers
.equ GICC_BASE, 0x10002000           ; Example base address
.equ GICC_CTLR, 0x000                ; CPU interface control
.equ GICC_PMR, 0x004                 ; Interrupt priority mask
.equ GICC_BPR, 0x008                 ; Binary point register
.equ GICC_IAR, 0x00C                 ; Interrupt acknowledge
.equ GICC_EOIR, 0x010                ; End of interrupt
.equ GICC_RPR, 0x014                 ; Running priority
.equ GICC_HPPIR, 0x018               ; Highest priority pending interrupt
.equ GICC_ABPR, 0x01C                ; Aliased binary point
.equ GICC_AIAR, 0x020                ; Aliased interrupt acknowledge
.equ GICC_AEOIR, 0x024               ; Aliased end of interrupt
.equ GICC_AHPPIR, 0x028              ; Aliased highest priority pending interrupt
.equ GICC_IIDR, 0x00FC               ; CPU interface implementer ID

; Constants
.equ GIC_DIST_ENABLE, 0x1
.equ GIC_CPU_ENABLE, 0x1
.equ GIC_PRIO_MASK_ALL, 0xFF
```

**GIC Initialization:**

```assembly
; Initialize GIC
gic_init:
    PUSH    {R4-R6, LR}
    
    ; Disable distributor
    LDR     R4, =GICD_BASE
    MOV     R0, #0
    STR     R0, [R4, #GICD_CTLR]
    
    ; Get number of interrupt lines
    LDR     R0, [R4, #GICD_TYPER]
	AND     R0, R0, #0x1F            ; Extract ITLinesNumber
    ADD     R5, R0, #1               ; Number of registers
    LSL     R5, R5, #5               ; × 32 interrupts per register
    
    ; Disable all interrupts
    LDR     R6, =GICD_ICENABLER
    ADD     R6, R4, R6
    MOV     R0, #0
disable_loop:
    MVN     R1, #0                   ; 0xFFFFFFFF (all bits set)
    STR     R1, [R6], #4
    ADD     R0, R0, #32
    CMP     R0, R5
    BLT     disable_loop
    
    ; Clear all pending interrupts
    LDR     R6, =GICD_ICPENDR
    ADD     R6, R4, R6
    MOV     R0, #0
clear_pending_loop:
    MVN     R1, #0
    STR     R1, [R6], #4
    ADD     R0, R0, #32
    CMP     R0, R5
    BLT     clear_pending_loop
    
    ; Set all interrupts to lowest priority (0xFF)
    LDR     R6, =GICD_IPRIORITYR
    ADD     R6, R4, R6
    MOV     R0, #0
    MVN     R2, #0                   ; 0xFFFFFFFF
set_priority_loop:
    STR     R2, [R6], #4
    ADD     R0, R0, #4               ; 4 interrupts per register
    CMP     R0, R5
    BLT     set_priority_loop
    
    ; Route all SPIs to CPU 0
    LDR     R6, =GICD_ITARGETSR
    ADD     R6, R4, R6
    ADD     R6, R6, #32              ; Start at interrupt 32 (first SPI)
    MOV     R0, #32
    MOV     R2, #0x01010101          ; Target CPU 0 for all 4 interrupts
set_target_loop:
    STR     R2, [R6], #4
    ADD     R0, R0, #4
    CMP     R0, R5
    BLT     set_target_loop
    
    ; Configure all interrupts as level-sensitive (default)
    ; ICFGR: 0 = level-sensitive, 1 = edge-triggered
    LDR     R6, =GICD_ICFGR
    ADD     R6, R4, R6
    MOV     R0, #0
    MOV     R2, #0
config_loop:
    STR     R2, [R6], #4
    ADD     R0, R0, #16              ; 16 interrupts per register
    CMP     R0, R5
    BLT     config_loop
    
    ; Enable distributor
    MOV     R0, #GIC_DIST_ENABLE
    STR     R0, [R4, #GICD_CTLR]
    
    ; Initialize CPU interface
    LDR     R4, =GICC_BASE
    
    ; Set priority mask (allow all priorities)
    MOV     R0, #GIC_PRIO_MASK_ALL
    STR     R0, [R4, #GICC_PMR]
    
    ; Set binary point (no priority grouping)
    MOV     R0, #0
    STR     R0, [R4, #GICC_BPR]
    
    ; Enable CPU interface
    MOV     R0, #GIC_CPU_ENABLE
    STR     R0, [R4, #GICC_CTLR]
    
    ; Enable IRQ interrupts in CPSR
    CPSIE   i
    
    POP     {R4-R6, PC}

; Enable specific interrupt
; R0 = interrupt ID
gic_enable_interrupt:
    PUSH    {R4, R5}
    
    LDR     R4, =GICD_BASE
    
    ; Calculate register offset and bit position
    MOV     R5, R0, LSR #5           ; Register index = ID / 32
    AND     R1, R0, #0x1F            ; Bit position = ID % 32
    MOV     R2, #1
    LSL     R2, R2, R1               ; Create bit mask
    
    ; Write to ISENABLER
    LDR     R3, =GICD_ISENABLER
    STR     R2, [R4, R3, LSL #0]     ; Base + offset
    ADD     R4, R4, R3
    STR     R2, [R4, R5, LSL #2]     ; + register index × 4
    
    POP     {R4, R5}
    BX      LR

; Disable specific interrupt
; R0 = interrupt ID
gic_disable_interrupt:
    PUSH    {R4, R5}
    
    LDR     R4, =GICD_BASE
    
    ; Calculate register offset and bit position
    MOV     R5, R0, LSR #5
    AND     R1, R0, #0x1F
    MOV     R2, #1
    LSL     R2, R2, R1
    
    ; Write to ICENABLER
    LDR     R3, =GICD_ICENABLER
    ADD     R4, R4, R3
    STR     R2, [R4, R5, LSL #2]
    
    POP     {R4, R5}
    BX      LR

; Set interrupt priority
; R0 = interrupt ID
; R1 = priority (0-255, lower = higher priority)
gic_set_priority:
    PUSH    {R4, R5}
    
    LDR     R4, =GICD_BASE
    
    ; Calculate register offset and byte position
    MOV     R5, R0, LSR #2           ; Register index = ID / 4
    AND     R2, R0, #0x3             ; Byte position = ID % 4
    LSL     R2, R2, #3               ; × 8 bits per byte
    
    ; Read-modify-write
    LDR     R3, =GICD_IPRIORITYR
    ADD     R4, R4, R3
    LDR     R3, [R4, R5, LSL #2]     ; Read current value
    
    MOV     R0, #0xFF
    LSL     R0, R0, R2               ; Create mask
    BIC     R3, R3, R0               ; Clear old priority
    LSL     R1, R1, R2               ; Position new priority
    ORR     R3, R3, R1               ; Set new priority
    
    STR     R3, [R4, R5, LSL #2]     ; Write back
    
    POP     {R4, R5}
    BX      LR

; Set interrupt target CPU
; R0 = interrupt ID (must be SPI: 32-1019)
; R1 = CPU mask (bit 0 = CPU0, bit 1 = CPU1, etc.)
gic_set_target:
    PUSH    {R4, R5}
    
    ; SPIs only (ID >= 32)
    CMP     R0, #32
    BLT     gic_set_target_done
    
    LDR     R4, =GICD_BASE
    
    ; Calculate register offset and byte position
    MOV     R5, R0, LSR #2           ; Register index = ID / 4
    AND     R2, R0, #0x3             ; Byte position = ID % 4
    LSL     R2, R2, #3               ; × 8 bits
    
    ; Read-modify-write
    LDR     R3, =GICD_ITARGETSR
    ADD     R4, R4, R3
    LDR     R3, [R4, R5, LSL #2]
    
    MOV     R0, #0xFF
    LSL     R0, R0, R2
    BIC     R3, R3, R0               ; Clear old target
    AND     R1, R1, #0xFF
    LSL     R1, R1, R2
    ORR     R3, R3, R1               ; Set new target
    
    STR     R3, [R4, R5, LSL #2]
    
gic_set_target_done:
    POP     {R4, R5}
    BX      LR

; Configure interrupt as edge or level triggered
; R0 = interrupt ID
; R1 = 0 (level-sensitive) or 1 (edge-triggered)
gic_set_config:
    PUSH    {R4, R5}
    
    LDR     R4, =GICD_BASE
    
    ; Calculate register offset and bit position
    MOV     R5, R0, LSR #4           ; Register index = ID / 16
    AND     R2, R0, #0xF             ; Field position = ID % 16
    LSL     R2, R2, #1               ; × 2 bits per interrupt
    
    ; Read-modify-write
    LDR     R3, =GICD_ICFGR
    ADD     R4, R4, R3
    LDR     R3, [R4, R5, LSL #2]
    
    MOV     R0, #0x3
    LSL     R0, R0, R2
    BIC     R3, R3, R0               ; Clear config bits
    
    CMP     R1, #0
    LSLNE   R1, R1, #1               ; Edge = bit 1 set
    LSL     R1, R1, R2
    ORR     R3, R3, R1
    
    STR     R3, [R4, R5, LSL #2]
    
    POP     {R4, R5}
    BX      LR

; Main IRQ handler (called from exception vector)
irq_handler:
    ; Save context
    SUB     LR, LR, #4               ; Adjust return address
    PUSH    {R0-R3, R12, LR}
    
    ; Read interrupt acknowledge register
    LDR     R0, =GICC_BASE
    LDR     R1, [R0, #GICC_IAR]
    
    ; Extract interrupt ID
    MOV     R2, R1
    AND     R2, R2, #0x3FF           ; Mask to 10 bits
    
    ; Check for spurious interrupt (ID 1023)
    LDR     R3, =1023
    CMP     R2, R3
    BEQ     irq_spurious
    
    ; Call interrupt-specific handler
    ; Jump table approach
    LDR     R0, =irq_handler_table
    LDR     R3, [R0, R2, LSL #2]     ; Load handler address
    CMP     R3, #0
    BEQ     irq_no_handler
    
    MOV     R0, R2                   ; Pass interrupt ID
    BLX     R3                       ; Call handler
    
irq_no_handler:
    ; Signal end of interrupt
    LDR     R0, =GICC_BASE
    STR     R1, [R0, #GICC_EOIR]     ; Write original IAR value
    
irq_spurious:
    ; Restore context and return
    POP     {R0-R3, R12, LR}
    MOVS    PC, LR                   ; Return and restore CPSR

; Interrupt handler table (array of function pointers)
.data
.align 2
irq_handler_table:
    .word   0                        ; ID 0 (SGI)
    .word   0                        ; ID 1
    ; ... (fill with handler addresses)
    .skip   1020 * 4                 ; Remaining entries

.text
; Register interrupt handler
; R0 = interrupt ID
; R1 = handler function pointer
gic_register_handler:
    PUSH    {R4}
    
    LDR     R4, =irq_handler_table
    STR     R1, [R4, R0, LSL #2]
    
    POP     {R4}
    BX      LR

; Software Generated Interrupt
; R0 = target CPU mask
; R1 = SGI ID (0-15)
gic_send_sgi:
    PUSH    {R4}
    
    LDR     R4, =GICD_BASE
    
    ; Build SGIR value
    LSL     R0, R0, #16              ; Target list in bits 23:16
    AND     R1, R1, #0xF             ; SGI ID in bits 3:0
    ORR     R0, R0, R1
    
    ; Write to SGIR
    STR     R0, [R4, #GICD_SGIR]
    
    POP     {R4}
    BX      LR

; Broadcast SGI to all other CPUs
; R0 = SGI ID (0-15)
gic_send_sgi_broadcast:
    PUSH    {R4}
    
    LDR     R4, =GICD_BASE
    
    ; Build SGIR value with target filter = 1 (all but self)
    MOV     R1, #1
    LSL     R1, R1, #24              ; Target filter in bits 25:24
    AND     R0, R0, #0xF
    ORR     R0, R0, R1
    
    STR     R0, [R4, #GICD_SGIR]
    
    POP     {R4}
    BX      LR
```

**FIQ (Fast Interrupt) Handling:**

FIQ has higher priority than IRQ and a dedicated register bank (R8-R14_fiq) for faster context switching.

```assembly
; Configure interrupt as FIQ (Group 0)
; R0 = interrupt ID
gic_set_fiq:
    PUSH    {R4, R5}
    
    LDR     R4, =GICD_BASE
    
    ; Calculate register and bit position
    MOV     R5, R0, LSR #5
    AND     R1, R0, #0x1F
    MOV     R2, #1
    LSL     R2, R2, R1
    
    ; Clear bit in IGROUPR (Group 0 = FIQ)
    LDR     R3, =GICD_IGROUPR
    ADD     R4, R4, R3
    LDR     R3, [R4, R5, LSL #2]
    BIC     R3, R3, R2
    STR     R3, [R4, R5, LSL #2]
    
    POP     {R4, R5}
    BX      LR

; FIQ handler (minimal latency)
fiq_handler:
    ; FIQ typically handles single high-priority interrupt
    ; No context save needed if using FIQ register bank only
    
    ; Read IAR
    LDR     R8, =GICC_BASE
    LDR     R9, [R8, #GICC_IAR]
    
    ; Handle interrupt (inline for speed)
    ; ... custom FIQ handling code ...
    
    ; Signal EOI
    STR     R9, [R8, #GICC_EOIR]
    
    ; Return
    SUBS    PC, LR, #4               ; Return and restore CPSR
```

**Nested Interrupt Support:**

```assembly
; IRQ handler with nesting enabled
irq_handler_nested:
    ; Adjust return address
    SUB     LR, LR, #4
    
    ; Save minimal context
    PUSH    {R0-R3, R12, LR}
    
    ; Read and acknowledge interrupt
    LDR     R0, =GICC_BASE
    LDR     R1, [R0, #GICC_IAR]
    MOV     R2, R1
    AND     R2, R2, #0x3FF
    
    ; Check spurious
    LDR     R3, =1023
    CMP     R2, R3
    BEQ     nested_spurious
    
    ; Save SPSR and re-enable interrupts for nesting
    MRS     R3, SPSR
    PUSH    {R1, R3}                 ; Save IAR and SPSR
    
    CPSIE   i                        ; Enable IRQ (allow nesting)
    
    ; Call handler in System mode
    CPS     #0x1F                    ; Switch to System mode
    
    ; Save full context on system stack
    PUSH    {R0-R12, LR}
    
    ; Call interrupt handler
    LDR     R0, =irq_handler_table
    LDR     R3, [R0, R2, LSL #2]
    MOV     R0, R2
    BLX     R3
    
    ; Restore context
    POP     {R0-R12, LR}
    
    ; Return to IRQ mode
    CPS     #0x12                    ; IRQ mode
    CPSID   i                        ; Disable interrupts
    
    ; Restore IAR and SPSR
    POP     {R1, R3}
    MSR     SPSR, R3
    
    ; Signal EOI
    LDR     R0, =GICC_BASE
    STR     R1, [R0, #GICC_EOIR]
    
nested_spurious:
    ; Restore minimal context and return
    POP     {R0-R3, R12, LR}
    MOVS    PC, LR

```

**Complete Interrupt Example:**

```assembly
; Complete example: Timer interrupt via GIC
example_timer_interrupt:
    PUSH    {LR}
    
    ; Initialize GIC
    BL      gic_init
    
    ; Register timer handler
    MOV     R0, #30                  ; Physical timer IRQ ID
    LDR     R1, =timer_interrupt_handler
    BL      gic_register_handler
    
    ; Set timer priority (high)
    MOV     R0, #30
    MOV     R1, #0x20                ; Priority 32
    BL      gic_set_priority
    
    ; Configure as level-sensitive
    MOV     R0, #30
    MOV     R1, #0
    BL      gic_set_config
    
    ; Enable timer interrupt
    MOV     R0, #30
    BL      gic_enable_interrupt
    
    ; Setup physical timer
    BL      setup_timer_1sec
    
    ; Main loop
main_loop:
    WFI                              ; Wait for interrupt
    B       main_loop
    
    POP     {PC}

; Timer interrupt handler
timer_interrupt_handler:
    PUSH    {R0-R3, LR}
    
    ; Clear timer interrupt
    MRC     p15, 0, R0, c14, c2, 1
    ORR     R0, R0, #2
    MCR     p15, 0, R0, c14, c2, 1
    
    ; Reload timer
    MRC     p15, 0, R1, c14, c0, 0
    MCR     p15, 0, R1, c14, c2, 0
    
    ; Process timer event
    LDR     R0, =tick_count
    LDR     R1, [R0]
    ADD     R1, R1, #1
    STR     R1, [R0]
    
    POP     {R0-R3, PC}

.data
tick_count: .word 0
```

**Key Points:**
- Bit-banging implements protocols through direct GPIO manipulation with precise software timing
- Hardware timers provide time measurement and periodic interrupts without CPU overhead
- UART provides serial communication with configurable baud rates, parity, and stop bits
- Circular buffers enable efficient interrupt-driven UART communication
- GIC manages interrupt prioritization, routing, and acknowledgment for multiple interrupt sources
- Interrupt handlers must acknowledge interrupts via IAR/EOIR registers
- Nested interrupts require careful context management and priority configuration
- SGIs enable inter-processor communication in multi-core systems

---

