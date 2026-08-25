## Calling C from Assembly


Calling C functions from assembly requires adherence to the Application Binary Interface (ABI) and Procedure Call Standard (PCS). The ARM Architecture Procedure Call Standard (AAPCS) defines how registers are used, how parameters are passed, and how the stack is managed across function calls.

**ARM Procedure Call Standard (AAPCS):**

The AAPCS defines register usage conventions that enable interoperability between separately compiled code modules:

**Register Usage:**

- **R0-R3 (a1-a4):** Argument registers, also scratch registers (caller-saved)
- **R4-R11 (v1-v8):** Variable registers (callee-saved, must be preserved)
- **R12 (IP):** Intra-procedure-call scratch register (caller-saved)
- **R13 (SP):** Stack pointer (callee-saved)
- **R14 (LR):** Link register (return address)
- **R15 (PC):** Program counter

**Floating-Point/NEON Registers:**

- **S0-S15 (D0-D7, Q0-Q3):** Argument/return values, scratch (caller-saved)
- **S16-S31 (D8-D15, Q4-Q7):** Callee-saved (must be preserved)
- **D16-D31 (Q8-Q15):** Scratch (caller-saved, if available)

**Parameter Passing Rules:**

**Integer/Pointer Arguments:**

- First four arguments: R0, R1, R2, R3
- Fifth and subsequent arguments: Stack (pushed right-to-left)
- 64-bit arguments: Use two consecutive registers (even-odd pairs like R0-R1, R2-R3)

**Floating-Point Arguments:**

- Single-precision: S0-S15
- Double-precision: D0-D7
- If floating-point registers exhausted, use integer registers or stack

**Return Values:**

- 32-bit or smaller: R0
- 64-bit: R0-R1
- Structures ≤32 bits: R0
- Structures ≤64 bits: R0-R1
- Larger structures: Caller allocates space, passes pointer in R0

**Stack Alignment:** AAPCS requires 8-byte (doubleword) stack alignment at public interfaces. Some systems require 16-byte alignment.

**Example** - Calling C function with integer arguments:

C function prototype:

```c
int add_three(int a, int b, int c);
```

Assembly calling code:

```assembly
.global _start
.text

_start:
    ; Call add_three(10, 20, 30)
    MOV     R0, #10              ; First argument
    MOV     R1, #20              ; Second argument
    MOV     R2, #30              ; Third argument
    BL      add_three            ; Call function
    ; R0 now contains return value (60)
    
    ; Exit program
    MOV     R7, #1               ; sys_exit
    SVC     #0
```

**Example** - Calling C function with stack arguments:

C function:

```c
int sum_six(int a, int b, int c, int d, int e, int f) {
    return a + b + c + d + e + f;
}
```

Assembly calling code:

```assembly
    ; Call sum_six(1, 2, 3, 4, 5, 6)
    ; Arguments 1-4 in registers, 5-6 on stack
    
    ; Prepare stack (must be 8-byte aligned)
    SUB     SP, SP, #8           ; Allocate 8 bytes
    MOV     R0, #6
    STR     R0, [SP, #4]         ; Sixth argument at SP+4
    MOV     R0, #5
    STR     R0, [SP, #0]         ; Fifth argument at SP+0
    
    ; Load register arguments
    MOV     R0, #1               ; First argument
    MOV     R1, #2               ; Second argument
    MOV     R2, #3               ; Third argument
    MOV     R3, #4               ; Fourth argument
    
    BL      sum_six              ; Call function
    ; R0 contains return value (21)
    
    ADD     SP, SP, #8           ; Clean up stack
```

**Example** - Calling C function with 64-bit argument:

C function:

```c
long long multiply(int a, long long b);
```

Assembly calling code:

```assembly
    ; Call multiply(5, 0x123456789ABCDEF0)
    MOV     R0, #5                   ; First argument (32-bit)
    LDR     R2, =0x9ABCDEF0          ; b low word (R2)
    LDR     R3, =0x12345678          ; b high word (R3)
    BL      multiply
    ; R0-R1 contains 64-bit return value
```

**Example** - Calling printf from assembly:

```assembly
.global main
.data
format: .asciz "Value: %d, String: %s\n"
msg:    .asciz "Hello"

.text
main:
    PUSH    {LR}                 ; Save return address
    
    ; printf(format, 42, "Hello")
    LDR     R0, =format          ; Format string (first argument)
    MOV     R1, #42              ; Integer value (second argument)
    LDR     R2, =msg             ; String pointer (third argument)
    BL      printf               ; Call printf
    
    MOV     R0, #0               ; Return 0
    POP     {PC}                 ; Return to caller
```

**Structure Return Example:**

C function:

```c
typedef struct {
    int x, y, z, w;
} Point4D;

Point4D make_point(int x, int y);
```

Assembly calling code:

```assembly
    ; Caller allocates space for return value
    SUB     SP, SP, #16          ; 16 bytes for structure
    MOV     R0, SP               ; Pass pointer to return space
    MOV     R1, #10              ; x argument (shifts to R1)
    MOV     R2, #20              ; y argument (shifts to R2)
    BL      make_point
    
    ; Structure now at [SP]
    LDR     R0, [SP, #0]         ; Load x
    LDR     R1, [SP, #4]         ; Load y
    LDR     R2, [SP, #8]         ; Load z
    LDR     R3, [SP, #12]        ; Load w
    ADD     SP, SP, #16          ; Clean up
```

**Preserving Callee-Saved Registers:**

When calling C functions that may use R4-R11, preserve them if your assembly code needs their values:

```assembly
my_function:
    PUSH    {R4-R11, LR}         ; Save callee-saved registers and LR
    
    ; Use R4-R11 freely
    MOV     R4, #100
    
    ; Call C function
    MOV     R0, #42
    BL      some_c_function
    
    ; R4-R11 preserved across call
    ADD     R0, R0, R4           ; Use preserved R4
    
    POP     {R4-R11, PC}         ; Restore and return
```

**Variable Argument Functions (varargs):**

Calling varargs functions like `printf` follows the same rules—fixed arguments in registers, variable arguments on stack:

```assembly
    ; printf("x=%d y=%d z=%d\n", x, y, z)
    LDR     R0, =format          ; Format string always first
    LDR     R1, =x_value         ; First vararg
    LDR     R1, [R1]
    LDR     R2, =y_value         ; Second vararg
    LDR     R2, [R2]
    LDR     R3, =z_value         ; Third vararg
    LDR     R3, [R3]
    BL      printf
```

**Soft Float vs Hard Float ABI:**

**Soft Float (EABI):** Floating-point arguments passed in integer registers (R0-R3). Software floating-point emulation or VFP instructions used for computation.

**Hard Float (EABIHF):** Floating-point arguments passed in VFP registers (S0-S15, D0-D7). More efficient for floating-point intensive code.

Hard float example:

```assembly
    ; Call float add(float a, float b)
    VMOV.F32 S0, #1.5            ; First argument
    VMOV.F32 S1, #2.5            ; Second argument
    BL       add_float
    ; S0 contains return value (4.0)
    VMOV     R0, S0              ; Move to R0 if needed
```

