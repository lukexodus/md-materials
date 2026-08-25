## Calling Conventions and Register Usage


ARM defines standard calling conventions that govern how functions communicate through registers, how the stack is managed, and which registers must be preserved. These conventions enable interoperability between separately compiled code and provide predictable behavior across toolchains.

### AAPCS - ARM Architecture Procedure Call Standard

The ARM Architecture Procedure Call Standard (AAPCS) specifies register allocation, parameter passing, return value handling, and stack management rules. Different variants exist for different environments: AAPCS for bare-metal and Linux, AAPCS64 for AArch64, and specialized versions for specific operating systems.

**Register Roles**

The AAPCS assigns specific roles to registers. r0-r3 pass the first four integer arguments and return values, r4-r11 are callee-saved general purpose registers, r12 (IP) is the intra-procedure-call scratch register, r13 (SP) is the stack pointer, r14 (LR) holds the return address, and r15 (PC) is the program counter. Floating-point and SIMD registers have separate allocation rules.

**Stack Alignment**

The stack pointer must maintain 8-byte alignment at public interfaces (function calls). Internal to a function, 4-byte alignment is sufficient, but calling other functions requires restoring 8-byte alignment. This alignment requirement affects how many registers are pushed in function prologues.

**Example:**

```assembly
@ Function with proper AAPCS compliance
my_function:
    @ Prologue: save callee-saved registers
    PUSH {r4-r7, lr}        @ Save r4-r7 and return address
                             @ SP now 8-byte aligned (pushed 5 words = 20 bytes)
    SUB sp, sp, #4          @ Adjust for 8-byte alignment (total 24 bytes)
    
    @ Function body uses r0-r3 freely (caller-saved)
    @ Must preserve r4-r7 if used
    MOV r4, r0              @ Save argument in callee-saved register
    BL other_function       @ Call preserves r4-r7
    ADD r0, r4, r0          @ Combine saved and returned values
    
    @ Epilogue: restore registers and return
    ADD sp, sp, #4          @ Remove alignment padding
    POP {r4-r7, pc}         @ Restore registers and return
```

