## Exception Handling


Exception handling is the mechanism by which the processor responds to exceptional conditions including interrupts, software interrupts, and errors.

**Exception Vector Table:**

The exception vector table contains branch instructions to exception handlers:

```asm
.section .vectors
.org 0x00000000         ; or 0xFFFF0000 with high vectors

vector_table:
    LDR PC, reset_addr      ; 0x00: Reset
    LDR PC, undef_addr      ; 0x04: Undefined instruction
    LDR PC, svc_addr        ; 0x08: Software interrupt (SVC)
    LDR PC, pabt_addr       ; 0x0C: Prefetch abort
    LDR PC, dabt_addr       ; 0x10: Data abort
    NOP                     ; 0x14: Reserved
    LDR PC, irq_addr        ; 0x18: IRQ
    LDR PC, fiq_addr        ; 0x1C: FIQ

; Handler addresses
reset_addr:     .word reset_handler
undef_addr:     .word undef_handler
svc_addr:       .word svc_handler
pabt_addr:      .word pabt_handler
dabt_addr:      .word dabt_handler
irq_addr:       .word irq_handler
fiq_addr:       .word fiq_handler

; Alternative: Direct branches (if handlers within 32MB)
vector_table_direct:
    B reset_handler         ; 0x00
    B undef_handler         ; 0x04
    B svc_handler           ; 0x08
    B pabt_handler          ; 0x0C
    B dabt_handler          ; 0x10
    B .                     ; 0x14: Infinite loop for reserved
    B irq_handler           ; 0x18
    B fiq_handler           ; 0x1C
```

**Setting vector base address:**

```asm
; Configure VBAR (Vector Base Address Register)
; ARMv7 Security Extensions or later

set_vector_base:
    LDR R0, =vector_table
    MCR p15, 0, R0, c12, c0, 0  ; Write VBAR
    ISB                          ; Instruction Synchronization Barrier
    BX LR

; Check if high vectors enabled
check_high_vectors:
    MRC p15, 0, R0, c1, c0, 0   ; Read SCTLR
    TST R0, #0x2000              ; Test V bit (bit 13)
    BX LR                        ; Z flag set if low vectors
```

**Reset Exception Handler:**

```asm
reset_handler:
    ; Disable interrupts
    CPSID if                    ; Disable IRQ and FIQ
    
    ; Setup vector table
    LDR R0, =vector_table
    MCR p15, 0, R0, c12, c0, 0  ; Set VBAR
    
    ; Setup stacks for all modes
    BL setup_stacks
    
    ; Initialize MMU, caches (if needed)
    ; BL mmu_init
    ; BL cache_init
    
    ; Copy data section from ROM to RAM
    LDR R0, =_data_load
    LDR R1, =_data_start
    LDR R2, =_data_end
copy_data:
    CMP R1, R2
    LDRLT R3, [R0], #4
    STRLT R3, [R1], #4
    BLT copy_data
    
    ; Zero BSS section
    LDR R0, =_bss_start
    LDR R1, =_bss_end
    MOV R2, #0
zero_bss:
    CMP R0, R1
    STRLT R2, [R0], #4
    BLT zero_bss
    
    ; Switch to System mode for main execution
    CPS #0x1F               ; System mode
    
    ; Enable interrupts
    CPSIE if
    
    ; Branch to main program
    BL main
    
    ; If main returns, infinite loop
halt:
    B halt
```

**Undefined Instruction Handler:**

```asm
undef_handler:
    ; Save context
    STMFD SP!, {R0-R12, LR}
    
    ; Get undefined instruction address
    SUB R0, LR, #4          ; LR points to next instruction
    
    ; Get the undefined instruction
    LDR R1, [R0]
    
    ; Check if this is a coprocessor instruction we can emulate
    ; Or if it's an intentional undefined instruction for software
    
    ; Example: Emulate a custom instruction
    LDR R2, =0xE7F000F0     ; Undefined instruction pattern
    BIC R3, R1, #0x0F       ; Mask off immediate
    CMP R3, R2
    BEQ emulate_custom
    
    ; Real undefined instruction - report error
    MOV R0, R1              ; Pass instruction to error handler
    BL undefined_instruction_error
    
    ; Restore context and return
restore_und:
    LDMFD SP!, {R0-R12, PC}^ ; ^ restores CPSR from SPSR
    
emulate_custom:
    ; Emulate the instruction
    ; ...
    B restore_und
```

**Prefetch Abort Handler:**

```asm
pabt_handler:
    ; Save context
    SUB LR, LR, #4          ; Adjust return address
    STMFD SP!, {R0-R12, LR}
    
    ; Get abort address
    MRS R0, SPSR
    PUSH {R0}               ; Save SPSR
    
    ; Read IFSR (Instruction Fault Status Register)
    MRC p15, 0, R1, c5, c0, 1
    
    ; Read IFAR (Instruction Fault Address Register)
    MRC p15, 0, R2, c6, c0, 2
    
    ; Determine fault type
    AND R3, R1, #0x0F       ; Extract fault status
    
    ; Handle different fault types
    CMP R3, #0x05           ; Translation fault?
    BEQ handle_translation_fault
    
    CMP R3, #0x07           ; Permission fault?
    BEQ handle_permission_fault
    
    ; Unknown fault
    B abort_error
    
handle_translation_fault:
    ; Page fault handling
    MOV R0, R2              ; Fault address
    BL page_fault_handler
    B pabt_return
    
handle_permission_fault:
    ; Permission violation
    MOV R0, R2
    BL permission_fault_handler
    B pabt_return
    
pabt_return:
    ; Restore context
    POP {R0}
    MSR SPSR_cxsf, R0
    LDMFD SP!, {R0-R12, PC}^

abort_error:
    ; Fatal error
    B .
```

**Data Abort Handler:**

```asm
dabt_handler:
    ; Save context
    SUB LR, LR, #8          ; Adjust return address (data abort)
    STMFD SP!, {R0-R12, LR}
    
    MRS R0, SPSR
    PUSH {R0}
    
    ; Read DFSR (Data Fault Status Register)
    MRC p15, 0, R1, c5, c0, 0
    
    ; Read DFAR (Data Fault Address Register)
    MRC p15, 0, R2, c6, c0, 0
    
    ; Determine if read or write
    TST R1, #0x800          ; WnR bit
    BNE write_abort
    
read_abort:
    ; Handle read abort
    MOV R0, R2              ; Fault address
    MOV R1, #0              ; Read flag
    BL data_abort_handler
    B dabt_return
    
write_abort:
    ; Handle write abort
    MOV R0, R2
    MOV R1, #1              ; Write flag
    BL data_abort_handler
    
dabt_return:
    POP {R0}
    MSR SPSR_cxsf, R0
    LDMFD SP!, {R0-R12, PC}^
```

**Software Interrupt (SVC) Handler:**

```asm
svc_handler:
    ; Save context
    STMFD SP!, {R0-R12, LR}
    
    ; Get SVC number
    MRS R2, SPSR            ; Get caller's CPSR
    TST R2, #0x20           ; Check Thumb bit
    LDRNEH R0, [LR, #-2]    ; Thumb: 8-bit immediate
    BICNE R0, R0, #0xFF00   ; Extract lower byte
    LDREQ R0, [LR, #-4]     ; ARM: 24-bit immediate
    BICEQ R0, R0, #0xFF000000
    
    ; R0 now contains SVC number
    ; R1-R7 contain parameters from user
    
    ; Dispatch to system call handler
    CMP R0, #MAX_SYSCALL
    BXGE invalid_syscall
    
    LDR R12, =syscall_table
    LDR PC, [R12, R0, LSL #2]  ; Jump to handler
    
svc_return:
    ; R0 contains return value
    LDMFD SP!, {R0-R12, PC}^   ; Return to user mode

invalid_syscall:
    MOV R0, #-1             ; Error code
    B svc_return

; System call table
syscall_table:
    .word sys_read          ; 0
    .word sys_write         ; 1
    .word sys_open          ; 2
    .word sys_close         ; 3
    ; ...
```

