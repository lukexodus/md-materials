## Mode Switching (ARM/Thumb Interworking)


ARM and Thumb interworking refers to the mechanism for transitioning between ARM state (32-bit instructions) and Thumb state (16-bit/mixed instructions). This capability is essential for hybrid systems where some code benefits from ARM's full instruction set while other code prioritizes Thumb's density.

**State Indication:** The processor's current state is determined by the T bit (bit 5) in the Current Program Status Register (CPSR):

- T=0: ARM state (32-bit instructions)
- T=1: Thumb state (16-bit/Thumb-2 instructions)

**Branch and Exchange (BX):** The primary instruction for mode switching. BX transfers control to an address and switches state based on bit 0 of the target address:

```assembly
BX   Rm    ; Branch to address in Rm, switch state based on Rm[0]
```

- If Rm[0] = 1: Switch to Thumb state, branch to Rm & 0xFFFFFFFE
- If Rm[0] = 0: Switch to ARM state, branch to Rm & 0xFFFFFFFC

**Example** of ARM to Thumb transition:

```assembly
; In ARM state
LDR  R0, =thumb_function + 1  ; Load Thumb function address with bit 0 set
BX   R0                         ; Branch and switch to Thumb

; In Thumb state now
thumb_function:
    PUSH {R4-R7, LR}
    ; Thumb code here
    POP  {R4-R7, PC}  ; Return switches back if LR bit 0 indicates ARM
```

**Branch with Link and Exchange (BLX):** Combines function call with state switching:

```assembly
BLX  Rm    ; Call function at Rm, switch state, save return address in LR
```

The return address saved in LR has bit 0 set to indicate the state to return to. When returning via `BX LR` or `POP {PC}`, the processor automatically switches back to the correct state.

**Example** of Thumb to ARM call:

```assembly
; In Thumb state
LDR  R0, =arm_function    ; Load ARM function address (bit 0 = 0)
BLX  R0                   ; Call ARM function, save return address

; In ARM state now
arm_function:
    STMFD SP!, {R4-R11, LR}
    ; ARM code here
    LDMFD SP!, {R4-R11, PC}  ; Return to Thumb (LR bit 0 = 1)
```

**Exception Handling:** When an exception occurs, the processor always enters the exception handler in ARM state (T bit cleared). Exception vectors reside in ARM code. To return to Thumb code after exception handling:

```assembly
; Exception handler (ARM state)
handler:
    ; Save context
    ; Handle exception
    ; Restore context
    SUBS PC, LR, #4   ; Return, automatically restore T bit from SPSR
```

The SUBS instruction with PC as destination restores the CPSR from SPSR, which includes the T bit reflecting the state before the exception.

**Interworking with Function Pointers:** Compilers store function pointers with bit 0 encoding the target state. This allows indirect calls to work correctly:

```assembly
LDR  R0, [R1]    ; Load function pointer
BLX  R0          ; Call function, automatically switch state if needed
```

**ARMv7 and Thumb-2:** In ARMv7 profiles with Thumb-2 support, many implementations deprecate or remove ARM state entirely (particularly Cortex-M series). These processors execute only Thumb/Thumb-2 instructions, eliminating mode switching overhead. The T bit remains set, and BX/BLX ignore bit 0 of the target address.

**Performance Considerations:** [Inference] Mode switching via BX/BLX typically incurs minimal overhead (1-2 cycles for pipeline flush on older cores). However, frequent switching can degrade performance due to instruction cache thrashing if ARM and Thumb code occupy different cache lines. Optimal designs minimize mode transitions by grouping ARM-state code and Thumb-state code into separate compilation units.

**Linker Support:** The linker must generate interworking veneers (small code sequences) when a call crosses state boundaries and the distance requires a long branch. These veneers handle the state switch:

```assembly
; Veneer for ARM to Thumb long call
arm_to_thumb_veneer:
    LDR  PC, =thumb_function + 1

; Veneer for Thumb to ARM long call  
thumb_to_arm_veneer:
    LDR  R12, =arm_function
    BX   R12
```

**Key Points:**

- Thumb provides 16-bit encoding for reduced memory footprint
- Thumb-2 adds 32-bit instructions to Thumb state, combining density with performance
- Mode switching uses BX/BLX instructions with bit 0 of target address indicating state
- Modern ARMv7-M processors execute only Thumb-2, eliminating ARM state entirely
- Interworking requires compiler and linker support for correct state transitions

---

