## ABI Compatibility


The Application Binary Interface (ABI) defines calling conventions, data layout, and system interfaces for compatibility between compilation units.

**AAPCS64 (ARM Architecture Procedure Call Standard):**

**Register usage:**

```asm
; Argument registers (caller-saved)
; X0-X7 (W0-W7): Integer/pointer arguments and return values
; V0-V7: Floating-point/SIMD arguments and return values
; X8: Indirect result location (for large return values)

; Temporary registers (caller-saved)
; X9-X15: Temporary registers, caller must save if needed
; X16-X17: Intra-procedure-call temporary (IP0, IP1)

; Callee-saved registers
; X19-X28: Must be preserved across function calls
; X29: Frame pointer (FP)
; X30: Link register (LR)

; Special registers
; SP: Stack pointer (must be 16-byte aligned)
; X18: Platform register (OS-specific, usually reserved)

; Example: ABI-compliant function
; int complex_func(int a, long b, float c, double d, 
;                  int e, int f, int g, int h, int overflow)
complex_func:
    ; W0 = a (int)
    ; X1 = b (long)
    ; S2 = c (float)
    ; D3 = d (double)
    ; W4 = e (int)
    ; W5 = f (int)
    ; W6 = g (int)
    ; W7 = h (int)
    ; [SP] = overflow (on stack)
    
    STP X29, X30, [SP, #-64]!   ; Save FP, LR
    MOV X29, SP                  ; Setup frame pointer
    STP X19, X20, [SP, #16]     ; Save callee-saved if used
    
    ; Access stack parameter
    LDR W19, [SP, #64]          ; Load overflow from caller's stack
    
    ; Function body
    ; Use W0, X1, S2, D3, W4-W7, W19
    ADD W0, W0, W4
    ADD W0, W0, W5
    ; ...
    
    LDP X19, X20, [SP, #16]     ; Restore callee-saved
    LDP X29, X30, [SP], #64     ; Restore FP, LR
    RET
```

**Return value conventions:**

```asm
; Integer/pointer return in X0 (or W0)
return_int:
    MOV W0, #42
    RET

; 64-bit return in X0
return_long:
    MOV X0, #0x123456789ABCDEF
    RET

; Pointer return in X0
return_pointer:
    ADRP X0, data_buffer
    ADD X0, X0, :lo12:data_buffer
    RET

; Float return in S0
return_float:
    FMOV S0, #1.0
    RET

; Double return in D0
return_double:
    FMOV D0, #3.14159
    RET

; 128-bit integer return in X0, X1
return_int128:
    MOV X0, #0x123456789ABCDEF  ; Low 64 bits
    MOV X1, #0xFEDCBA987654321  ; High 64 bits
    RET

; Small struct return (≤ 16 bytes) in X0, X1
; struct Point { long x, y; };
return_point:
    MOV X0, #10                 ; x
    MOV X1, #20                 ; y
    RET

; Large struct return (> 16 bytes) via memory
; X8 points to caller-allocated space
; struct LargeData { long a, b, c, d; };
return_large_struct:
    ; X8 = pointer to result location
    MOV X0, #1
    STR X0, [X8, #0]            ; a
    MOV X0, #2
    STR X0, [X8, #8]            ; b
    MOV X0, #3
    STR X0, [X8, #16]           ; c
    MOV X0, #4
    STR X0, [X8, #24]           ; d
    MOV X0, X8                  ; Return pointer in X0
    RET
```

**Variable argument functions (varargs):**

```c
// C varargs function
int sum_varargs(int count, ...) {
    va_list args;
    va_start(args, count);
    int sum = 0;
    for (int i = 0; i < count; i++) {
        sum += va_arg(args, int);
    }
    va_end(args);
    return sum;
}
```

```asm
; Assembly implementation of varargs
; AArch64: First 8 args in X0-X7, rest on stack
.global sum_varargs
sum_varargs:
    ; W0 = count
    STP X29, X30, [SP, #-96]!   ; Save FP, LR
    MOV X29, SP
    
    ; Save register arguments to stack (va_list)
    ; This allows va_arg to access them uniformly
    STP X1, X2, [SP, #16]       ; Save X1-X7
    STP X3, X4, [SP, #32]
    STP X5, X6, [SP, #48]
    STR X7, [SP, #64]
    
    MOV W9, W0                  ; Save count
    MOV W10, #0                 ; sum = 0
    MOV W11, #0                 ; index = 0
    
    CMP W9, #0
    B.LE done
    
    ; Setup va_list pointer
    ADD X12, SP, #16            ; Point to saved args
    
sum_loop:
    ; Load next argument
    CMP W11, #7
    B.GT from_stack
    
    ; From register save area
    LDR W13, [X12], #8
    B add_value
    
from_stack:
    ; From caller's stack
    ; Arguments beyond X7 are at [X29, #96]
    SUB W14, W11, #7
    ADD X15, X29, #96
    LDR W13, [X15, W14, UXTW #2]
    
add_value:
    ADD W10, W10, W13           ; sum += arg
    ADD W11, W11, #1            ; index++
    CMP W11, W9
    B.LT sum_loop
    
done:
    MOV W0, W10                 ; Return sum
    LDP X29, X30, [SP], #96
    RET

; Calling varargs function
call_sum:
    MOV W0, #5                  ; count = 5
    MOV W1, #1                  ; arg1
    MOV W2, #2                  ; arg2
    MOV W3, #3                  ; arg3
    MOV W4, #4                  ; arg4
    MOV W5, #5                  ; arg5
    BL sum_varargs
    ; Result in W0
    RET
```

**ABI-compliant stack frame:**

```asm
; Standard function prologue/epilogue
function_with_frame:
    ; Prologue
    STP X29, X30, [SP, #-48]!   ; Save FP, LR (16 bytes)
    MOV X29, SP                  ; FP = SP
    STP X19, X20, [SP, #16]     ; Save callee-saved (16 bytes)
    STP X21, X22, [SP, #32]     ; Save more callee-saved (16 bytes)
    
    ; Stack layout at this point:
    ; [SP + 0]  = saved X29 (FP)
    ; [SP + 8]  = saved X30 (LR)
    ; [SP + 16] = saved X19
    ; [SP + 24] = saved X20
    ; [SP + 32] = saved X21
    ; [SP + 40] = saved X22
    
    ; Allocate local variables
    SUB SP, SP, #32             ; 32 bytes for locals (maintain alignment)
    
    ; Function body
    ; Access locals at [SP + offset]
    ; Access saved regs via FP: [X29, #offset]
    
    ; Epilogue
    ADD SP, SP, #32             ; Deallocate locals
    LDP X21, X22, [SP, #32]     ; Restore callee-saved
    LDP X19, X20, [SP, #16]
    LDP X29, X30, [SP], #48     ; Restore FP, LR
    RET

; Leaf function (no calls, no frame pointer needed)
leaf_function:
    ; No prologue needed if no calls and uses only X0-X15
    ADD W0, W0, W1
    MUL W0, W0, W2
    RET

; Non-leaf requiring only LR save
simple_function:
    STP X29, X30, [SP, #-16]!
    
    BL other_function
    
    LDP X29, X30, [SP], #16
    RET
```

