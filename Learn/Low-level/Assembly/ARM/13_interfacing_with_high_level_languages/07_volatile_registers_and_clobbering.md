## Volatile Registers and Clobbering


Volatile (caller-saved) registers can be modified by called functions; callee-saved registers must be preserved.

**Register classification:**

```asm
; Volatile (caller-saved) registers
; X0-X18: Can be clobbered by function calls
; V0-V7, V16-V31: Can be clobbered by function calls

; Non-volatile (callee-saved) registers
; X19-X28: Must be preserved by called functions
; X29 (FP): Frame pointer (must be preserved)
; X30 (LR): Link register (must be preserved)
; V8-V15: Must be preserved by called functions
; SP: Stack pointer (must be preserved and aligned)

; Example: Caller must save volatile registers if needed
caller_function:
    MOV X9, #100                ; X9 = volatile
    MOV X19, #200               ; X19 = non-volatile
    
    ; Before calling, save volatile registers we need later
    STP X9, X10, [SP, #-16]!    ; Save X9, X10
    
    BL some_function            ; May clobber X0-X18
    
    LDP X9, X10, [SP], #16      ; Restore X9, X10
    
    ; X19 still has value 200 (callee must preserve)
    ADD X0, X9, X19
    RET

; Example: Callee must save non-volatile registers if used
callee_function:
    STP X29, X30, [SP, #-32]!
    MOV X29, SP
    STP X19, X20, [SP, #16]     ; Must save if we use X19, X20
    
    ; Use X19, X20 for local state
    MOV X19, #42
    MOV X20, #84
    
    ; Can freely use X0-X15 without saving
    MOV X9, #100
    
    ; Must restore non-volatile registers
    LDP X19, X20, [SP, #16]
    LDP X29, X30, [SP], #32
    RET
```

**Inline assembly with clobbers (C/C++):**

```c
// GCC/Clang inline assembly syntax
void use_inline_asm(int a, int b) {
    int result;
    
    // Simple inline assembly
    asm("add %w0, %w1, %w2"
        : "=r" (result)         // Output: result in register
        : "r" (a), "r" (b)      // Inputs: a and b in registers
    );
    
    // With clobbers
    asm("mov x9, %1\n"
        "mul x9, x9, x9\n"
        "add %0, x9, %2\n"
        : "=r" (result)         // Output
        : "r" (a), "r" (b)      // Inputs
        : "x9", "cc"            // Clobbers: x9 modified, condition codes changed
    );
    
    // Memory clobber (indicates memory changes)
    asm volatile("str %1, [%0]\n"
        :                       // No outputs
        : "r" (ptr), "r" (value)
        : "memory"              // Memory clobber
    );
}
```

```asm
; Corresponding assembly showing register usage
use_inline_asm:
    ; Compiler allocates registers for variables
    ; W0 = a, W1 = b
    
    ; First asm block: add
    ADD W2, W0, W1              ; result = a + b
    
    ; Second asm block with clobbers
    MOV X9, X0                  ; Use X9 (volatile, OK to clobber)
    MUL X9, X9, X9              ; x9 = a * a
    ADD X2, X9, X1              ; result = (a * a) + b
    ; Compiler knows X9 is clobbered, won't rely on its value
    
    ; Memory operations
    ; Compiler ensures memory is coherent due to "memory" clobber
    
    RET
```

**Handling function calls with volatile preservation:**

```asm
; Function using many temporaries
complex_calculation:
    STP X29, X30, [SP, #-80]!
    MOV X29, SP
    
    ; Load initial values into volatile registers
    MOV X9, #10
    MOV X10, #20
    MOV X11, #30
    MOV X12, #40
    MOV X13, #50
    
    ; Need to call helper function
    ; Save volatile registers we still need
    STP X9, X10, [SP, #16]
    STP X11, X12, [SP, #32]
    STR X13, [SP, #48]
    
    ; Call function (may clobber X0-X15)
    MOV X0, X9
    BL helper_function
    MOV X14, X0                 ; Save return value
    
    ; Restore volatile registers
    LDP X9, X10, [SP, #16]
    LDP X11, X12, [SP, #32]
    LDR X13, [SP, #48]
    
    ; Continue with restored values
    ADD X0, X9, X10
    ADD X0, X0, X11
    ADD X0, X0, X12
    ADD X0, X0, X13
    ADD X0, X0, X14
    
    LDP X29, X30, [SP], #80
    RET

; Alternative: Use callee-saved registers (no saving needed)
complex_calculation_opt:
    STP X29, X30, [SP, #-48]!
    MOV X29, SP
    STP X19, X20, [SP, #16]     ; Must save callee-saved
    STP X21, X22, [SP, #32]
    
    ; Use callee-saved registers for persistent state
    MOV X19, #10
    MOV X20, #20
    MOV X21, #30
    MOV X22, #40
    
    ; Call function - X19-X22 automatically preserved by callee
    MOV X0, X19
    BL helper_function
    
    ; X19-X22 still have original values
    ADD X0, X0, X19
    ADD X0, X0, X20
    ADD X0, X0, X21
    ADD X0, X0, X22
    
    LDP X21, X22, [SP, #32]
    LDP X19, X20, [SP, #16]
    LDP X29, X30, [SP], #48
    RET
```

**SIMD register preservation:**

```asm
; V0-V7: Volatile (arguments and return)
; V8-V15: Non-volatile (must preserve lower 64 bits)
; V16-V31: Volatile

simd_function:
    STP X29, X30, [SP, #-96]!
    MOV X29, SP
    
    ; Save V8-V15 if used (only lower 64 bits required)
    STP D8, D9, [SP, #16]
    STP D10, D11, [SP, #32]
    STP D12, D13, [SP, #48]
    STP D14, D15, [SP, #64]
    
    ; Or save full 128 bits if needed
    ; STP Q8, Q9, [SP, #16]     ; Requires more stack space
    
    ; Use SIMD registers
    FADD V8.4S, V0.4S, V1.4S
    FMUL V9.4S, V8.4S, V2.4S
    
    ; V0-V7 can be used freely (volatile)
    FADD V0.4S, V3.4S, V4.4S
    
    ; Restore V8-V15
    LDP D8, D9, [SP, #16]
    LDP D10, D11, [SP, #32]
    LDP D12, D13, [SP, #48]
    LDP D14, D15, [SP, #64]
    
    LDP X29, X30, [SP], #96
    RET
```

