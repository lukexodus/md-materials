## Vector Tables


Vector tables are arrays of function pointers that the processor uses to handle exceptions and interrupts. The table layout is architecture-defined and must match processor expectations.

**Cortex-M Vector Table Structure:**

The vector table contains:

1. **Initial stack pointer** (entry 0)
2. **Exception handlers** (entries 1-15, processor exceptions)
3. **IRQ handlers** (entries 16+, device-specific interrupts)

**Standard Exception Vectors (Cortex-M):**

- **0**: Initial SP value
- **1**: Reset handler
- **2**: NMI (Non-Maskable Interrupt)
- **3**: HardFault
- **4**: MemManage fault (if MPU exists)
- **5**: BusFault
- **6**: UsageFault
- **7-10**: Reserved
- **11**: SVCall (Supervisor Call)
- **12**: Debug Monitor
- **13**: Reserved
- **14**: PendSV (Pendable Service)
- **15**: SysTick timer

Entries 16+ are device-specific IRQs (UART, SPI, timers, etc.).

**Example** - Vector table definition:

```assembly
.syntax unified
.cpu cortex-m4
.thumb

.section .isr_vector,"a",%progbits
.type vector_table, %object
.size vector_table, .-vector_table

vector_table:
    .word _estack              @ 0: Initial stack pointer
    .word Reset_Handler        @ 1: Reset handler
    .word NMI_Handler          @ 2: NMI
    .word HardFault_Handler    @ 3: Hard fault
    .word MemManage_Handler    @ 4: MPU fault
    .word BusFault_Handler     @ 5: Bus fault
    .word UsageFault_Handler   @ 6: Usage fault
    .word 0                    @ 7: Reserved
    .word 0                    @ 8: Reserved
    .word 0                    @ 9: Reserved
    .word 0                    @ 10: Reserved
    .word SVC_Handler          @ 11: SVCall
    .word DebugMon_Handler     @ 12: Debug monitor
    .word 0                    @ 13: Reserved
    .word PendSV_Handler       @ 14: PendSV
    .word SysTick_Handler      @ 15: SysTick
    
    @ External interrupts (device-specific)
    .word WWDG_IRQHandler           @ 16: Window watchdog
    .word PVD_IRQHandler            @ 17: PVD through EXTI
    .word TAMP_STAMP_IRQHandler     @ 18: Tamper/timestamp
    .word RTC_WKUP_IRQHandler       @ 19: RTC wakeup
    .word FLASH_IRQHandler          @ 20: Flash global
    .word RCC_IRQHandler            @ 21: RCC global
    .word EXTI0_IRQHandler          @ 22: EXTI line 0
    .word EXTI1_IRQHandler          @ 23: EXTI line 1
    @ ... more device-specific interrupts
```

**Default Handler Implementation:**

Unimplemented interrupt handlers typically point to a default handler that loops forever, making debugging easier:

```assembly
.section .text

@ Weak definitions allow user to override
.weak NMI_Handler
.weak HardFault_Handler
.weak MemManage_Handler
.weak BusFault_Handler
.weak UsageFault_Handler
.weak SVC_Handler
.weak DebugMon_Handler
.weak PendSV_Handler
.weak SysTick_Handler

@ All default to Default_Handler
.thumb_set NMI_Handler, Default_Handler
.thumb_set HardFault_Handler, Default_Handler
.thumb_set MemManage_Handler, Default_Handler
.thumb_set BusFault_Handler, Default_Handler
.thumb_set UsageFault_Handler, Default_Handler
.thumb_set SVC_Handler, Default_Handler
.thumb_set DebugMon_Handler, Default_Handler
.thumb_set PendSV_Handler, Default_Handler
.thumb_set SysTick_Handler, Default_Handler

.type Default_Handler, %function
Default_Handler:
    B .                    @ Infinite loop
.size Default_Handler, .-Default_Handler
```

**Vector Table Relocation:**

The VTOR (Vector Table Offset Register) allows relocating the vector table to SRAM for dynamic modification:

```assembly
.equ SCB_VTOR, 0xE000ED08    @ VTOR address

relocate_vector_table:
    @ Copy vector table to SRAM
    LDR r0, =vector_table_ram    @ Destination (must be 128-byte aligned)
    LDR r1, =vector_table        @ Source in flash
    LDR r2, =vector_table_size
    
copy_vectors:
    LDM r1!, {r3-r10}           @ Load 8 words
    STM r0!, {r3-r10}           @ Store 8 words
    SUBS r2, r2, #32
    BGT copy_vectors
    
    @ Set VTOR to new location
    LDR r0, =SCB_VTOR
    LDR r1, =vector_table_ram
    STR r1, [r0]
    
    DSB                         @ Data synchronization barrier
    ISB                         @ Instruction synchronization barrier
    BX lr
```

**Interrupt Handler Example:**

```assembly
.global EXTI0_IRQHandler
.type EXTI0_IRQHandler, %function

EXTI0_IRQHandler:
    @ Context automatically saved by hardware:
    @ R0-R3, R12, LR, PC, xPSR
    
    PUSH {r4-r7, lr}           @ Save additional registers
    
    @ Clear EXTI pending bit
    LDR r0, =EXTI_PR           @ Pending register
    LDR r1, =0x01              @ Clear bit 0
    STR r1, [r0]
    
    @ Handle interrupt (call C function)
    BL handle_button_press
    
    POP {r4-r7, pc}            @ Restore and return
    @ Hardware restores R0-R3, R12, PC, xPSR
    
.size EXTI0_IRQHandler, .-EXTI0_IRQHandler
```

**Cortex-A Vector Table:**

Cortex-A processors use exception vectors at fixed addresses (typically 0x00000000 or 0xFFFF0000):

```assembly
.section .vectors,"ax"
.align 5

vector_table_a:
    B Reset_Handler        @ 0x00: Reset
    B Undefined_Handler    @ 0x04: Undefined instruction
    B SVC_Handler          @ 0x08: Supervisor call
    B Prefetch_Handler     @ 0x0C: Prefetch abort
    B Data_Handler         @ 0x10: Data abort
    NOP                    @ 0x14: Reserved
    B IRQ_Handler          @ 0x18: IRQ
    B FIQ_Handler          @ 0x1C: FIQ
```

Each entry is a branch instruction (4 bytes). The processor jumps to these fixed addresses on exceptions.

**Key Points:**

- Vector tables define processor behavior on reset, faults, and interrupts
- Table layout is architecture-defined and must be at specific memory locations
- Cortex-M uses word-sized function pointers; Cortex-A uses branch instructions
- Weak symbols allow default handlers to be overridden
- VTOR allows runtime relocation on Cortex-M
- Proper interrupt acknowledgment (clearing pending flags) is critical to prevent repeated triggers

---

