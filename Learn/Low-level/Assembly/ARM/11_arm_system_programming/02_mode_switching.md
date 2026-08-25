## Mode Switching


Mode switching occurs through exceptions or explicit privileged instructions.

**Automatic mode switching (exceptions):**

When an exception occurs:

1. Current CPSR saved to SPSR of exception mode
2. Mode bits in CPSR changed to exception mode
3. PC saved to LR of exception mode (adjusted for exception type)
4. Interrupt disable bits set (I and/or F)
5. PC loaded with exception vector address

**Software-initiated mode switching:**

**From User mode to privileged mode:**

```asm
; User mode cannot directly change to privileged mode
; Must use SVC instruction to trap to Supervisor mode

user_code:
    ; Running in User mode
    MOV R0, #syscall_number
    SVC #0              ; Generate supervisor call exception
    ; Returns here after SVC handler completes

; In exception vector table
svc_handler:
    ; Now in Supervisor mode
    ; Process system call
    ; Return to User mode with MOVS PC, LR
```

**Privileged mode switching (explicit):**

```asm
; Save current mode and switch to different privileged mode
; Must be in privileged mode to execute this

switch_to_irq_mode:
    MRS R0, CPSR        ; Read current CPSR
    BIC R1, R0, #0x1F   ; Clear mode bits
    ORR R1, R1, #0x12   ; Set IRQ mode bits
    MSR CPSR_c, R1      ; Write CPSR (control field)
    
    ; Now in IRQ mode
    ; Can access IRQ mode banked registers
    MOV R13, #irq_stack_top  ; Setup IRQ stack
    
    ; Restore original mode
    MSR CPSR_c, R0      ; Restore saved CPSR
    BX LR

; Switch to FIQ mode
switch_to_fiq:
    MRS R0, CPSR
    BIC R1, R0, #0x1F
    ORR R1, R1, #0x11   ; FIQ mode
    MSR CPSR_c, R1
    ; Setup FIQ stack and registers
    MSR CPSR_c, R0
    BX LR
```

**Setting up mode stacks:**

```asm
; Initialize stack pointers for all modes
; Must be called in privileged mode (typically Supervisor)

setup_stacks:
    ; Save return address
    MOV R2, LR
    
    ; Setup IRQ stack
    MRS R0, CPSR
    BIC R1, R0, #0x1F
    ORR R1, R1, #0x12   ; IRQ mode
    MSR CPSR_c, R1
    LDR SP, =irq_stack_top
    
    ; Setup FIQ stack
    BIC R1, R0, #0x1F
    ORR R1, R1, #0x11   ; FIQ mode
    MSR CPSR_c, R1
    LDR SP, =fiq_stack_top
    
    ; Setup Abort stack
    BIC R1, R0, #0x1F
    ORR R1, R1, #0x17   ; Abort mode
    MSR CPSR_c, R1
    LDR SP, =abt_stack_top
    
    ; Setup Undefined stack
    BIC R1, R0, #0x1F
    ORR R1, R1, #0x1B   ; Undefined mode
    MSR CPSR_c, R1
    LDR SP, =und_stack_top
    
    ; Setup System/User stack
    BIC R1, R0, #0x1F
    ORR R1, R1, #0x1F   ; System mode (shares User SP)
    MSR CPSR_c, R1
    LDR SP, =user_stack_top
    
    ; Return to Supervisor mode
    MSR CPSR_c, R0
    MOV PC, R2
```

**Returning from exception:**

```asm
; Return from exception to previous mode
; Restores CPSR from SPSR and adjusts PC

irq_handler:
    ; Exception handler code
    ; ...
    
    ; Return using special instruction
    SUBS PC, LR, #4     ; Adjust LR and restore CPSR from SPSR
    ; The 'S' suffix causes CPSR := SPSR

; Alternative explicit method
return_from_exception:
    MSR CPSR_c, SPSR    ; Restore CPSR from SPSR
    MOV PC, LR          ; Return to saved PC
    
; For nested exceptions, must preserve SPSR
nested_exception_return:
    ; Save SPSR before it gets overwritten
    MRS R0, SPSR
    PUSH {R0}
    
    ; Process exception...
    
    ; Restore and return
    POP {R0}
    MSR SPSR_cxsf, R0
    SUBS PC, LR, #4
```

**LR adjustment values for different exceptions:**

```asm
; Different exceptions require different LR adjustments
; on return due to pipeline effects

; SVC (Software Interrupt): no adjustment
MOVS PC, LR             ; or SUBS PC, LR, #0

; Undefined instruction: no adjustment
MOVS PC, LR

; Prefetch abort: adjust by 4
SUBS PC, LR, #4

; Data abort: adjust by 8
SUBS PC, LR, #8

; IRQ: adjust by 4
SUBS PC, LR, #4

; FIQ: adjust by 4
SUBS PC, LR, #4
```

