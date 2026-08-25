## Interrupt Processing


Interrupt processing handles asynchronous external events (IRQ) and fast interrupts (FIQ).

**Interrupt Controller (GIC - Generic Interrupt Controller):**

ARM systems use an interrupt controller to manage multiple interrupt sources:

```asm
; GIC registers (example addresses - platform specific)
.equ GICD_BASE,     0x08000000  ; Distributor base
.equ GICC_BASE,     0x08010000  ; CPU interface base

; Distributor registers
.equ GICD_CTLR,     0x000       ; Control
.equ GICD_ISENABLER, 0x100      ; Interrupt Set-Enable
.equ GICD_ICENABLER, 0x180      ; Interrupt Clear-Enable
.equ GICD_IPRIORITYR, 0x400     ; Interrupt Priority
.equ GICD_ITARGETSR, 0x800      ; Interrupt Processor Targets

; CPU interface registers
.equ GICC_CTLR,     0x000       ; CPU Interface Control
.equ GICC_PMR,      0x004       ; Priority Mask
.equ GICC_IAR,      0x00C       ; Interrupt Acknowledge
.equ GICC_EOIR,     0x010       ; End of Interrupt
```

**GIC Initialization:**

```asm
gic_init:
    PUSH {LR}
    
    ; Disable GIC distributor
    LDR R0, =GICD_BASE
    MOV R1, #0
    STR R1, [R0, #GICD_CTLR]
    
    ; Disable all interrupts
    LDR R0, =GICD_BASE
    ADD R0, R0, #GICD_ICENABLER
    MOV R1, #0xFFFFFFFF
    MOV R2, #0
disable_loop:
    STR R1, [R0, R2, LSL #2]
    ADD R2, R2, #1
    CMP R2, #32                 ; 32 registers for 1020 interrupts
    BLT disable_loop
    
    ; Set all priorities to lowest
    LDR R0, =GICD_BASE
    ADD R0, R0, #GICD_IPRIORITYR
    LDR R1, =0xA0A0A0A0         ; Priority 0xA0 for all
    MOV R2, #0
priority_loop:
    STR R1, [R0, R2, LSL #2]
    ADD R2, R2, #1
    CMP R2, #255                ; 255 registers for 1020 interrupts
    BLT priority_loop
    
    ; Set all interrupts to target CPU0
    LDR R0, =GICD_BASE
    ADD R0, R0, #GICD_ITARGETSR
    MOV R1, #0x01010101         ; CPU0
    MOV R2, #0
target_loop:
    STR R1, [R0, R2, LSL #2]
    ADD R2, R2, #1
    CMP R2, #255
    BLT target_loop
    
    ; Enable GIC distributor
    LDR R0, =GICD_BASE
    MOV R1, #1
    STR R1, [R0, #GICD_CTLR]
    
    ; Configure CPU interface
    LDR R0, =GICC_BASE
    
    ; Set priority mask to lowest (allow all)
    MOV R1, #0xFF
    STR R1, [R0, #GICC_PMR]
    
    ; Enable CPU interface
    MOV R1, #1
    STR R1, [R0, #GICC_CTLR]
    
    POP {PC}
```

**Enable specific interrupt:**

```asm
; Enable interrupt number in R0
enable_interrupt:
    PUSH {R4, LR}
    
    ; Calculate register and bit position
    MOV R1, R0, LSR #5          ; Register index = IRQ / 32
    AND R2, R0, #0x1F           ; Bit position = IRQ % 32
    MOV R3, #1
    LSL R3, R3, R2              ; Create bit mask
    
    ; Set enable bit
    LDR R4, =GICD_BASE
    ADD R4, R4, #GICD_ISENABLER
    STR R3, [R4, R1, LSL #2]
    
    POP {R4, PC}

; Disable interrupt
disable_interrupt:
    PUSH {R4, LR}
    
    MOV R1, R0, LSR #5
    AND R2, R0, #0x1F
    MOV R3, #1
    LSL R3, R3, R2
    
    LDR R4, =GICD_BASE
    ADD R4, R4, #GICD_ICENABLER
    STR R3, [R4, R1, LSL #2]
    
    POP {R4, PC}
```

**IRQ Handler:**

```asm
irq_handler:
    ; Save context on IRQ stack
    SUB LR, LR, #4              ; Adjust return address
    STMFD SP!, {R0-R3, R12, LR} ; Save working registers
    
    ; Read interrupt ID from GIC
    LDR R0, =GICC_BASE
    LDR R1, [R0, #GICC_IAR]     ; Read IAR (acknowledges interrupt)
    
    ; Save interrupt ID
    MOV R2, R1
    
    ; Check for spurious interrupt
    LDR R3, =1023
    CMP R2, R3
    BEQ irq_spurious
    
    ; Save remaining context if needed for nested interrupts
    MRS R3, SPSR
    STMFD SP!, {R3, R4-R11}     ; Save SPSR and remaining registers
    
    ; Enable IRQ for nested interrupts (optional)
    ; CPSIE i
    
    ; Call C handler with interrupt ID
    MOV R0, R2                  ; Interrupt ID parameter
    BL irq_dispatch             ; Call C function
    
    ; Disable IRQ again if was enabled
    ; CPSID i
    
    ; Restore remaining context
    LDMFD SP!, {R3, R4-R11}
    MSR SPSR_cxsf, R3
    
    ; Signal end of interrupt to GIC
    LDR R0, =GICC_BASE
    STR R2, [R0, #GICC_EOIR]    ; Write interrupt ID to EOIR
    
irq_spurious:
    ; Restore working registers and return
    LDMFD SP!, {R0-R3, R12, PC}^  ; ^ restores CPSR from SPSR

; C-callable interrupt dispatcher
irq_dispatch:
    PUSH {LR}
    
    ; Look up handler in table
    LDR R1, =irq_handler_table
    LDR R2, [R1, R0, LSL #2]    ; Get handler address
    
    ; Check if handler is valid
    CMP R2, #0
    BEQ no_handler
    
    ; Call handler
    BLX R2
    
no_handler:
    POP {PC}
```

**FIQ Handler:**

FIQ is optimized for single, time-critical interrupt source:

```asm
fiq_handler:
    ; No need to save R8-R12 - they're banked in FIQ mode
    ; Only save R0-R7 if needed
    
    SUB LR, LR, #4              ; Adjust return address
    
    ; Minimal context save
    STMFD SP!, {R0-R3, LR}
    
    ; FIQ-specific code - usually handles single device
    ; Direct device register access for minimum latency
    
    ; Example: Service UART FIQ
    LDR R0, =UART_BASE
    LDR R1, [R0, #UART_STATUS]
    TST R1, #RX_READY
    LDRNE R2, [R0, #UART_DATA]
    
    ; Store received data
    LDR R3, =uart_rx_buffer
    STRB R2, [R3], #1
    
    ; Acknowledge FIQ at device level
    MOV R1, #FIQ_CLEAR
    STR R1, [R0, #UART_CLEAR]
    
    ; Restore and return
    LDMFD SP!, {R0-R3, PC}^     ; Return and restore CPSR
```

**Interrupt service routine registration:**

```asm
; Register IRQ handler
; R0 = interrupt number, R1 = handler address
register_irq_handler:
    PUSH {R4, LR}
    
    ; Store handler in table
    LDR R2, =irq_handler_table
    STR R1, [R2, R0, LSL #2]
    
    ; Enable the interrupt
    BL enable_interrupt
    
    POP {R4, PC}

; Unregister handler
unregister_irq_handler:
    PUSH {R4, LR}
    
    ; Disable interrupt
    BL disable_interrupt
    
    ; Clear handler
    LDR R2, =irq_handler_table
    MOV R1, #0
    STR R1, [R2, R0, LSL #2]
    
    POP {R4, PC}

.section .bss
irq_handler_table:
    .space 4 * 1020             ; Table for 1020 interrupts
```

**Critical sections and interrupt masking:**

```asm
; Disable interrupts and save state
disable_interrupts:
    MRS R0, CPSR
    CPSID if                    ; Disable IRQ and FIQ
    BX LR

; Restore interrupt state
restore_interrupts:
    MSR CPSR_c, R0
    BX LR

; Critical section wrapper
critical_section_enter:
    MRS R0, CPSR
    PUSH {R0}                   ; Save CPSR to stack
    CPSID if                    ; Disable IRQ and FIQ
    BX LR

critical_section_exit:
    POP {R0}                    ; Restore saved CPSR
    MSR CPSR_c, R0
    BX LR

; Example usage in C-callable function
atomic_increment:
    ; R0 = pointer to variable
    PUSH {R4, LR}
    
    BL critical_section_enter
    
    ; Critical section - no interrupts
    LDR R1, [R0]
    ADD R1, R1, #1
    STR R1, [R0]
    
    BL critical_section_exit
    
    POP {R4, PC}

; Disable only IRQ (leave FIQ enabled)
disable_irq:
    MRS R0, CPSR
    CPSID i
    BX LR

; Disable only FIQ (leave IRQ enabled)
disable_fiq:
    MRS R0, CPSR
    CPSID f
    BX LR

; Enable interrupts
enable_interrupts:
    CPSIE if
    BX LR
```

**Nested interrupt handling:**

```asm
; IRQ handler with nested interrupt support
irq_handler_nested:
    ; Save minimal context
    SUB LR, LR, #4
    STMFD SP!, {R0-R3, R12, LR}
    
    ; Acknowledge interrupt and get ID
    LDR R0, =GICC_BASE
    LDR R1, [R0, #GICC_IAR]
    MOV R2, R1                  ; Save interrupt ID
    
    ; Check for spurious
    LDR R3, =1023
    CMP R2, R3
    BEQ nested_spurious
    
    ; Save full context for nesting
    MRS R3, SPSR
    STMFD SP!, {R3, R4-R11}
    
    ; Switch to System mode to use user stack
    MRS R3, CPSR
    BIC R4, R3, #0x1F
    ORR R4, R4, #0x1F           ; System mode
    MSR CPSR_c, R4
    
    ; Now on system/user stack - safe to enable interrupts
    CPSIE i                     ; Enable IRQ for nesting
    
    ; Call handler (may be interrupted)
    MOV R0, R2
    BL irq_dispatch
    
    ; Disable interrupts before returning
    CPSID i
    
    ; Switch back to IRQ mode
    MSR CPSR_c, R3
    
    ; Signal EOI
    LDR R0, =GICC_BASE
    STR R2, [R0, #GICC_EOIR]
    
    ; Restore context
    LDMFD SP!, {R3, R4-R11}
    MSR SPSR_cxsf, R3
    
nested_spurious:
    LDMFD SP!, {R0-R3, R12, PC}^
```

**Interrupt latency optimization:**

```asm
; Fast interrupt acknowledge for minimal latency
fast_irq_entry:
    ; Use fastest possible instruction sequence
    SUB LR, LR, #4
    STMFD SP!, {R0-R1}          ; Save only what's needed
    
    ; Inline GIC access (no function call overhead)
    LDR R0, =(GICC_BASE + GICC_IAR)
    LDR R1, [R0]                ; Read and acknowledge
    
    ; Quick spurious check
    CMP R1, #1023
    BEQ fast_spurious
    
    ; Inline handler for critical interrupt
    CMP R1, #CRITICAL_IRQ_ID
    BEQ critical_handler_inline
    
    ; For other interrupts, use normal path
    STMFD SP!, {R2-R3, R12, LR}
    B normal_irq_path
    
critical_handler_inline:
    ; Handle critical interrupt with minimal overhead
    LDR R0, =CRITICAL_DEVICE_BASE
    LDR R2, [R0, #STATUS_REG]
    ; ... handle interrupt directly ...
    STR R2, [R0, #CLEAR_REG]
    
    ; Signal EOI inline
    LDR R0, =(GICC_BASE + GICC_EOIR)
    STR R1, [R0]
    
fast_spurious:
    LDMFD SP!, {R0-R1}
    MOVS PC, LR                 ; Fast return

normal_irq_path:
    ; Continue with normal interrupt processing
    ; ...
```

**Software-triggered interrupts (SGI):**

```asm
; Generate Software Generated Interrupt
; R0 = target CPU mask (bits 0-7 for CPUs 0-7)
; R1 = SGI number (0-15)
trigger_sgi:
    PUSH {R4, LR}
    
    ; Build GICD_SGIR value
    ; [31:26] reserved
    ; [25:24] target list filter (00 = use CPU list)
    ; [23:16] CPU target list
    ; [15] NSATT (Non-Secure)
    ; [3:0] SGI number
    
    LSL R2, R0, #16             ; CPU mask to bits [23:16]
    AND R3, R1, #0x0F           ; SGI number to bits [3:0]
    ORR R2, R2, R3
    
    ; Write to GICD_SGIR
    LDR R4, =GICD_BASE
    STR R2, [R4, #0xF00]        ; GICD_SGIR offset
    
    ; Memory barrier to ensure write completes
    DSB
    
    POP {R4, PC}

; Send SGI to specific CPU
; R0 = CPU number, R1 = SGI number
send_sgi_to_cpu:
    MOV R2, #1
    LSL R0, R2, R0              ; Convert CPU number to mask
    B trigger_sgi

; Send SGI to all CPUs except self
send_sgi_to_others:
    PUSH {LR}
    MOV R0, #0x01000000         ; Target list filter = 01 (all except self)
    AND R1, R1, #0x0F
    ORR R2, R0, R1
    
    LDR R3, =GICD_BASE
    STR R2, [R3, #0xF00]
    DSB
    
    POP {PC}
```

**Interrupt priorities and preemption:**

```asm
; Set interrupt priority
; R0 = interrupt number
; R1 = priority (0 = highest, 255 = lowest)
set_interrupt_priority:
    PUSH {R4-R5, LR}
    
    ; Calculate register offset
    ; Each register holds 4 priorities (8 bits each)
    LSR R2, R0, #2              ; Register index = IRQ / 4
    AND R3, R0, #0x03           ; Byte position = IRQ % 4
    LSL R3, R3, #3              ; Bit position = byte * 8
    
    ; Read current register value
    LDR R4, =GICD_BASE
    ADD R4, R4, #GICD_IPRIORITYR
    LDR R5, [R4, R2, LSL #2]
    
    ; Clear old priority
    MOV R0, #0xFF
    LSL R0, R0, R3
    BIC R5, R5, R0
    
    ; Set new priority
    LSL R1, R1, R3
    ORR R5, R5, R1
    
    ; Write back
    STR R5, [R4, R2, LSL #2]
    
    POP {R4-R5, PC}

; Set CPU priority mask
; R0 = priority mask (interrupts below this priority are masked)
set_priority_mask:
    LDR R1, =GICC_BASE
    STR R0, [R1, #GICC_PMR]
    BX LR

; Get current priority mask
get_priority_mask:
    LDR R1, =GICC_BASE
    LDR R0, [R1, #GICC_PMR]
    BX LR

; Temporarily raise priority to mask lower-priority interrupts
raise_priority:
    PUSH {R4, LR}
    
    ; Save current mask
    BL get_priority_mask
    MOV R4, R0
    
    ; Set new higher priority mask (lower value)
    MOV R0, #0x40               ; Example: priority 0x40
    BL set_priority_mask
    
    ; Return old mask in R0
    MOV R0, R4
    POP {R4, PC}

; Restore previous priority mask
restore_priority:
    ; R0 = saved priority mask
    B set_priority_mask
```

**Interrupt statistics and debugging:**

```asm
.section .data
irq_count:
    .space 4 * 1020             ; Counter for each interrupt

.section .text

; IRQ handler with statistics
irq_handler_stats:
    SUB LR, LR, #4
    STMFD SP!, {R0-R3, R12, LR}
    
    ; Get interrupt ID
    LDR R0, =GICC_BASE
    LDR R1, [R0, #GICC_IAR]
    MOV R2, R1
    
    ; Check for spurious
    LDR R3, =1023
    CMP R2, R3
    BEQ stats_spurious
    
    ; Increment counter for this interrupt
    LDR R3, =irq_count
    LDR R0, [R3, R2, LSL #2]
    ADD R0, R0, #1
    STR R0, [R3, R2, LSL #2]
    
    ; Save remaining context
    MRS R3, SPSR
    STMFD SP!, {R3, R4-R11}
    
    ; Call dispatcher
    MOV R0, R2
    BL irq_dispatch
    
    ; Signal EOI
    LDR R0, =GICC_BASE
    STR R2, [R0, #GICC_EOIR]
    
    ; Restore context
    LDMFD SP!, {R3, R4-R11}
    MSR SPSR_cxsf, R3
    
stats_spurious:
    LDMFD SP!, {R0-R3, R12, PC}^

; Get interrupt count
; R0 = interrupt number
; Returns: R0 = count
get_irq_count:
    LDR R1, =irq_count
    LDR R0, [R1, R0, LSL #2]
    BX LR

; Clear interrupt statistics
clear_irq_stats:
    PUSH {R4-R5, LR}
    
    LDR R4, =irq_count
    MOV R5, #0
    MOV R1, #0
clear_loop:
    STR R5, [R4, R1, LSL #2]
    ADD R1, R1, #1
    CMP R1, #1020
    BLT clear_loop
    
    POP {R4-R5, PC}
```

**Timer interrupts (common use case):**

```asm
; ARM Generic Timer setup
.equ CNTFRQ,    0               ; Counter Frequency
.equ CNTPCT,    0               ; Physical Count
.equ CNTP_TVAL, 0               ; Timer Value
.equ CNTP_CTL,  1               ; Timer Control

; Initialize system timer
timer_init:
    PUSH {LR}
    
    ; Read timer frequency
    MRC p15, 0, R0, c14, c0, 0  ; Read CNTFRQ
    LDR R1, =timer_frequency
    STR R0, [R1]
    
    ; Setup timer for 1ms tick
    LDR R2, =1000
    UDIV R0, R0, R2             ; Ticks per millisecond
    LDR R1, =timer_tick_value
    STR R0, [R1]
    
    ; Set timer value
    MCR p15, 0, R0, c14, c2, 0  ; Write CNTP_TVAL
    
    ; Enable timer
    MOV R0, #1
    MCR p15, 0, R0, c14, c2, 1  ; Write CNTP_CTL (enable)
    
    ; Enable timer interrupt in GIC
    MOV R0, #30                 ; Physical timer IRQ (platform specific)
    BL enable_interrupt
    
    ; Register handler
    LDR R1, =timer_irq_handler
    BL register_irq_handler
    
    POP {PC}

; Timer interrupt handler
timer_irq_handler:
    PUSH {R4, LR}
    
    ; Increment system tick count
    LDR R4, =system_ticks
    LDR R0, [R4]
    ADD R0, R0, #1
    STR R0, [R4]
    
    ; Reload timer for next tick
    LDR R0, =timer_tick_value
    LDR R0, [R0]
    MCR p15, 0, R0, c14, c2, 0  ; Write CNTP_TVAL
    
    ; Call scheduler or other tick handlers
    BL os_tick_handler
    
    POP {R4, PC}

.section .bss
timer_frequency:
    .word 0
timer_tick_value:
    .word 0
system_ticks:
    .word 0
```

**Interrupt controller setup for multicore:**

```asm
; Initialize GIC for specific CPU
; R0 = CPU number
gic_cpu_init:
    PUSH {R4-R5, LR}
    MOV R4, R0
    
    ; Configure CPU interface
    LDR R5, =GICC_BASE
    
    ; Set priority mask to lowest (allow all interrupts)
    MOV R0, #0xFF
    STR R0, [R5, #GICC_PMR]
    
    ; Set binary point (controls priority grouping)
    MOV R0, #0x03               ; Example: 4 bits for group, 4 for subpriority
    STR R0, [R5, #0x08]         ; GICC_BPR
    
    ; Enable CPU interface
    MOV R0, #1
    STR R0, [R5, #GICC_CTLR]
    
    ; Enable private peripheral interrupts (PPIs)
    LDR R0, =GICD_BASE
    ADD R0, R0, #GICD_ISENABLER
    LDR R1, =0xFFFF0000         ; Enable PPIs (16-31)
    STR R1, [R0]
    
    POP {R4-R5, PC}

; Secondary CPU startup with interrupt initialization
secondary_cpu_start:
    ; Disable interrupts
    CPSID if
    
    ; Setup vector table
    LDR R0, =vector_table
    MCR p15, 0, R0, c12, c0, 0
    
    ; Setup stack for this CPU
    MRC p15, 0, R0, c0, c0, 5   ; Read MPIDR
    AND R0, R0, #0x03           ; Extract CPU ID
    
    ; Setup stacks based on CPU ID
    ; ... (similar to setup_stacks but CPU-specific)
    
    ; Initialize GIC for this CPU
    BL gic_cpu_init
    
    ; Enable interrupts
    CPSIE if
    
    ; Enter secondary CPU main loop
    B secondary_cpu_main
```

**Deferred interrupt processing (bottom half):**

```asm
; Deferred work queue structure
.struct 0
work_next:      .word 0
work_handler:   .word 0
work_data:      .word 0
work_size = .

.section .bss
.align 4
work_queue_head:
    .word 0
work_queue_tail:
    .word 0
work_queue_lock:
    .word 0

.section .text

; Quick interrupt handler that defers work
quick_irq_handler:
    PUSH {R4, LR}
    
    ; Minimal processing - just queue work
    LDR R0, =work_item_1
    BL queue_work
    
    POP {R4, PC}

; Queue work for deferred processing
; R0 = work item address
queue_work:
    PUSH {R4-R6, LR}
    MOV R4, R0
    
    ; Disable interrupts for queue manipulation
    BL disable_interrupts
    MOV R5, R0                  ; Save interrupt state
    
    ; Add to tail of queue
    LDR R6, =work_queue_tail
    LDR R1, [R6]
    
    CMP R1, #0
    BEQ queue_empty
    
    ; Queue not empty - link to tail
    STR R4, [R1, #work_next]
    STR R4, [R6]                ; Update tail
    B queue_done
    
queue_empty:
    ; Queue empty - set both head and tail
    LDR R2, =work_queue_head
    STR R4, [R2]
    STR R4, [R6]
    
queue_done:
    ; Clear next pointer
    MOV R0, #0
    STR R0, [R4, #work_next]
    
    ; Restore interrupts
    MOV R0, R5
    BL restore_interrupts
    
    POP {R4-R6, PC}

; Process deferred work (called from main loop or worker thread)
process_deferred_work:
    PUSH {R4-R6, LR}
    
process_loop:
    ; Disable interrupts
    BL disable_interrupts
    MOV R5, R0
    
    ; Get head of queue
    LDR R6, =work_queue_head
    LDR R4, [R6]
    
    CMP R4, #0
    BEQ no_work
    
    ; Remove from queue
    LDR R0, [R4, #work_next]
    STR R0, [R6]
    
    ; Check if queue is now empty
    CMP R0, #0
    LDREQ R1, =work_queue_tail
    STREQ R0, [R1]
    
    ; Restore interrupts before calling handler
    MOV R0, R5
    BL restore_interrupts
    
    ; Call work handler
    LDR R0, [R4, #work_data]
    LDR R1, [R4, #work_handler]
    BLX R1
    
    ; Process next item
    B process_loop
    
no_work:
    MOV R0, R5
    BL restore_interrupts
    POP {R4-R6, PC}
```

**Key Points:**

- ARM processors support seven processor modes with different privilege levels and banked registers for isolation
- Mode switching occurs automatically during exceptions or explicitly via privileged instructions
- Exception handling uses a vector table with specific handlers for reset, interrupts, aborts, and software interrupts
- Interrupt processing involves GIC configuration, interrupt acknowledgment, handler dispatch, and EOI signaling
- FIQ provides lower latency through additional banked registers for time-critical interrupts
- Nested interrupts require careful context management and stack switching
- Critical sections use interrupt masking to protect shared data structures
- Deferred work queues separate fast interrupt acknowledgment from slower processing

[Inference] Specific GIC register addresses and interrupt numbers are platform-dependent and vary across ARM SoC implementations. The examples use typical values but actual systems require consulting platform documentation.

[Inference] Interrupt latency and handler performance characteristics depend on processor implementation, cache configuration, and memory system design - actual measurements on target hardware are necessary for real-time system design.

---

