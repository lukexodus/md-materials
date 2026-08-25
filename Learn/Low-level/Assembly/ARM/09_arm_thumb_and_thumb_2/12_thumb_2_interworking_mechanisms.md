## Thumb-2 Interworking Mechanisms


### BX and BLX Instructions

**BX - Branch and Exchange:**

```assembly
; BX Rm
; Branch to address in Rm, switch mode based on Rm[0]
; Rm[0] = 0: Switch to ARM mode
; Rm[0] = 1: Switch to Thumb mode

.thumb
    LDR r0, =arm_function
    BIC r0, r0, #1          ; Clear bit 0 for ARM mode
    BX r0                   ; Branch and switch to ARM

.arm
arm_function:
    ; ARM code executes here
    ; To return to Thumb caller:
    BX lr                   ; lr has bit 0 set by caller
```

**BLX - Branch with Link and Exchange:**

```assembly
; BLX Rm
; Branch with link, exchange modes based on Rm[0]

.thumb
    LDR r0, =arm_helper
    BLX r0                  ; Call and switch to ARM
                            ; lr = PC | 1 (marks return to Thumb)
    ; Returns here in Thumb mode

; BLX label (immediate form)
; Branch to label and exchange modes

.thumb
    BLX arm_function        ; Direct call, automatic mode switch

.arm
arm_function:
    ; ARM code
    BX lr                   ; Return to Thumb
```

**Example** - Complete interworking pattern:

```assembly
.thumb
.global thumb_entry
thumb_entry:
    PUSH {r4-r7, lr}
    
    ; Call ARM function
    BL arm_helper           ; If arm_helper is ARM, assembler generates BLX
    
    ; Process result
    ADD r0, r0, #10
    
    POP {r4-r7, pc}

.arm
.global arm_helper
arm_helper:
    ; ARM mode function
    STMFD sp!, {r4-r7, lr}
    
    ; Can call back to Thumb
    BL thumb_utility
    
    ; Return to Thumb caller
    LDMFD sp!, {r4-r7, lr}
    BX lr                   ; Mode switch on return

.thumb
thumb_utility:
    ; Thumb utility function
    ADD r0, r0, #5
    BX lr
```

### Veneer Generation

When branches exceed Thumb range, linkers generate veneers (trampolines):

**Example** - Automatic veneer insertion:

```assembly
.thumb
far_call:
    ; Target is >16MB away (beyond B.W range)
    B far_target            ; Linker converts to veneer

; Linker generates veneer automatically:
__far_target_veneer:
    LDR pc, =far_target     ; Long-range indirect branch

; ... many sections later ...
far_target:
    ; Actual target code
```

**Manual veneer for cross-mode calls:**

```assembly
.thumb
thumb_function:
    B arm_function_veneer

.section .veneers
arm_function_veneer:
    PUSH {lr}
    LDR r12, =arm_function
    BIC r12, r12, #1        ; Ensure ARM mode (bit 0 = 0)
    BLX r12
    POP {pc}

.arm
.section .text.arm
arm_function:
    ; ARM code here
    BX lr
```

