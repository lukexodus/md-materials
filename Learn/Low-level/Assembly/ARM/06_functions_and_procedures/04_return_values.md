## Return Values


AAPCS defines conventions for returning results from functions, ensuring consistent handling of various data types across the caller-callee interface.

### Integer and Pointer Return Values

Simple scalar return values use specific registers:

**ARMv7**:
- 32-bit or smaller integers: R0
- 64-bit integers: R0 (lower 32 bits) and R1 (upper 32 bits)
- Pointers: R0

**ARMv8**:
- Up to 32-bit integers: W0 (lower 32 bits of X0)
- 64-bit integers and pointers: X0
- 128-bit integers: X0 (lower 64 bits) and X1 (upper 64 bits)

**Example** ARMv7 function returning int:
```
int add(int a, int b) {
    return a + b;
}

add:
    ADD r0, r0, r1        @ Result in r0
    BX lr                 @ Return
```

**Example** ARMv7 function returning 64-bit value:
```
long long multiply(int a, int b) {
    return (long long)a * b;
}

multiply:
    SMULL r0, r1, r0, r1  @ r0:r1 = r0 * r1 (signed 64-bit result)
    BX lr                 @ Return r0:r1
```

**Example** ARMv8 function returning pointer:
```
char* get_string(void) {
    return "Hello";
}

get_string:
    ADRP x0, string_literal
    ADD x0, x0, :lo12:string_literal
    RET                   @ Return pointer in x0

string_literal:
    .asciz "Hello"
```

### Boolean Return Values

Boolean values conventionally use 0 for false and non-zero (typically 1) for true, returned in R0/W0:

```
int is_positive(int x) {
    return x > 0;
}

is_positive:
    CMP r0, #0            @ Compare x with 0
    MOVGT r0, #1          @ r0 = 1 if x > 0
    MOVLE r0, #0          @ r0 = 0 if x <= 0
    BX lr

@ Or more efficiently in ARMv8:
is_positive:
    CMP w0, #0
    CSET w0, GT           @ Set w0 to 1 if greater, else 0
    RET
```

### Floating-Point Return Values

Floating-point results use the FP/SIMD register file:

**ARMv7 with VFP**:
- `float` (32-bit): S0
- `double` (64-bit): D0
- If no VFP, floats use R0, doubles use R0:R1

**ARMv8**:
- `float`: S0 (32-bit view of V0)
- `double`: D0 (64-bit view of V0)
- 128-bit vectors: Q0 (full V0)

**Example** ARMv8 function returning float:
```
float compute_ratio(float a, float b) {
    return a / b;
}

compute_ratio:
    FDIV s0, s0, s1       @ s0 = s0 / s1
    RET                   @ Return s0
```

**Example** mixed return types:
```c
double complex_calc(int x, float y);
@ ARMv8: x in w0, y in s0, returns double in d0
```

### Small Structure Return Values

Small structures that fit in registers are returned by value:

**ARMv7**:
- Structures ≤ 32 bits: Returned in R0
- Structures 33-64 bits: Returned in R0:R1
- Larger structures: Returned via memory (see below)

**Example** ARMv7 returning small structure:
```c
struct Point {
    short x;
    short y;
};

struct Point make_point(short x, short y) {
    struct Point p;
    p.x = x;
    p.y = y;
    return p;
}

make_point:
    @ x in r0 (lower 16 bits), y in r1 (lower 16 bits)
    ORR r0, r0, r1, LSL #16   @ Pack: r0 = (y << 16) | x
    BX lr                      @ Return packed structure in r0
```

**ARMv8**:
- Structures ≤ 16 bytes: Returned in X0 (and X1 if needed)
- Homogeneous aggregates: Returned in consecutive FP registers

**Example** ARMv8 returning structure in two registers:
```c
struct Pair {
    long first;
    long second;
};

struct Pair make_pair(long a, long b) {
    struct Pair p = {a, b};
    return p;
}

make_pair:
    @ a already in x0, b already in x1
    @ Structure members naturally occupy correct registers
    RET                   @ Return x0:x1
```

**Example** ARMv8 homogeneous aggregate:
```c
struct Vec4 {
    float x, y, z, w;
};

struct Vec4 create_vector(float val) {
    struct Vec4 v = {val, val, val, val};
    return v;
}

create_vector:
    @ val in s0
    FMOV s1, s0           @ Copy to s1
    FMOV s2, s0           @ Copy to s2
    FMOV s3, s0           @ Copy to s3
    RET                   @ Return s0:s1:s2:s3
```

### Large Structure Return Values

Structures too large for register return use indirect return via memory:

**ARMv7**: The caller allocates space for the return value and passes a pointer in R0. The function writes the result to this location and returns the pointer in R0.

**Example** ARMv7 large structure return:
```c
struct Large {
    int data[10];
};

struct Large create_large(void);

@ Caller:
caller:
    SUB sp, sp, #40       @ Allocate 40 bytes for return value
    MOV r0, sp            @ Pass pointer in r0
    BL create_large       @ Call function
    @ r0 points to result at [sp]
    @ Use result...
    ADD sp, sp, #40       @ Deallocate

@ Callee:
create_large:
    @ r0 contains pointer to caller-allocated space
    @ Write result to [r0]...
    @ r0 already contains correct pointer
    BX lr                 @ Return r0 unchanged
```

**ARMv8**: Similar mechanism using X8 as the indirect result location register. The caller passes the result buffer address in X8, and the function writes the result there.

**Example** ARMv8 large structure return:
```c
struct Matrix {
    double elements[4][4];
};

struct Matrix create_identity(void);

@ Caller:
caller:
    SUB sp, sp, #128      @ Allocate 128 bytes (16 doubles)
    MOV x8, sp            @ Pass pointer in x8
    BL create_identity    @ Call function
    @ Result now at [sp]
    @ Use result...
    ADD sp, sp, #128      @ Deallocate

@ Callee:
create_identity:
    @ x8 contains pointer to result buffer
    @ Write identity matrix to [x8]...
    @ No need to modify x8 or return value
    RET
```

The indirect return mechanism allows arbitrarily large structures without copying overhead beyond the initial write.

### Returning Multiple Values

C/C++ functions return a single value, but assembly can simulate multiple returns using conventions:

**Option 1**: Pack multiple values into registers:
```
@ Return two 16-bit values in r0
two_values:
    MOV r0, #10           @ First value (lower 16 bits)
    ORR r0, r0, #20, LSL #16  @ Second value (upper 16 bits)
    BX lr

@ Caller extracts values:
    BL two_values
    UXTH r1, r0           @ Extract lower 16 bits
    LSR r2, r0, #16       @ Extract upper 16 bits
```

**Option 2**: Use structure return (as shown above)

**Option 3**: Return one value normally, pass pointer for second:
```c
int divide_with_remainder(int a, int b, int *remainder);
@ Returns quotient in r0/x0, writes remainder to address in r1/x1
```

**Example** implementation:
```
@ ARMv7
divide_with_remainder:
    @ r0 = a, r1 = b, r2 = pointer to remainder
    SDIV r3, r0, r1       @ r3 = a / b (quotient) - ARMv7 with IDIV extension
    MLS r4, r3, r1, r0    @ r4 = a - (quotient * b) = remainder
    STR r4, [r2]          @ Store remainder
    MOV r0, r3            @ Return quotient
    BX lr
```

### Void Returns

Functions with `void` return type don't set any return value registers:

```
void print_message(void);

print_message:
    @ Function body...
    BX lr                 @ Simply return, no value in r0
```

However, R0-R3 (X0-X7 in ARMv8) are caller-saved, so their contents after a void function call are undefined. The caller must not rely on these registers preserving values across void function calls.

### Returning Status Codes

Many system-level functions return status codes indicating success or error:

```
int file_open(const char *path);
@ Returns file descriptor (>=0) on success, -1 on error

file_open:
    @ Attempt to open file...
    @ On success:
    MOV r0, #3            @ Return file descriptor
    BX lr
    
    @ On error:
error:
    MVN r0, #0            @ r0 = -1 (bitwise NOT of 0)
    BX lr
```

The caller checks the return value to determine success:
```
    LDR r0, =filename
    BL file_open
    CMP r0, #0
    BLT error_handler     @ Branch if r0 < 0 (error)
    @ Success, r0 contains valid file descriptor
```

### Returning Errno-Style Errors

Some conventions return success/failure boolean and set a global error variable:

```
int operation(void);
@ Returns 1 on success, 0 on failure
@ On failure, sets errno to error code

operation:
    @ Attempt operation...
    @ On failure:
fail:
    LDR r1, =errno        @ Load address of errno
    MOV r2, #EINVAL       @ Error code
    STR r2, [r1]          @ Set errno
    MOV r0, #0            @ Return failure
    BX lr
    
    @ On success:
success:
    MOV r0, #1            @ Return success
    BX lr
```

### Optimizing Return Value Handling

Efficient code often arranges computation so results naturally appear in return registers:

**Example** inefficient:
```
compute:
    @ Compute result in r4
    MOV r4, #42
    MOV r0, r4            @ Extra move to return register
    BX lr
```

**Example** efficient:
```
compute:
    @ Compute result directly in r0
    MOV r0, #42
    BX lr
```

Similarly, when calling a function and using its return value, avoid unnecessary moves:

```
    BL get_value          @ Returns in r0
    @ Use r0 directly without moving to another register
    ADD r1, r1, r0        @ Use return value
```

### Tail Call Optimization

When a function's final action is calling another function and returning its result, a tail call optimization replaces the call-return sequence with a direct branch:

**Example** without optimization:
```
wrapper:
    @ Prepare arguments...
    BL inner_func         @ Call inner function
    BX lr                 @ Return inner_func's result
```

**Example** with tail call optimization:
```
wrapper:
    @ Prepare arguments...
    B inner_func          @ Branch directly (not BL)
                          @ inner_func will return directly to our caller
```

This eliminates the extra return, saves stack space, and improves performance. [Inference] The optimization requires that the wrapper doesn't modify the stack frame or rely on saved registers, since control transfers directly to and from inner_func.

**Example** ARMv8 tail call:
```
wrapper:
    @ Set up arguments in x0-x7...
    B inner_func          @ Tail call - inner_func returns to our caller
```

### Return Value Register Preservation

Return value registers (R0-R1 or X0-X1) are caller-saved, meaning:

1. The caller cannot assume they preserve values across calls
2. The callee can freely modify them without saving
3. The callee must place return values in these registers before returning

**Example** caller handling return value:
```
caller:
    PUSH {r4, lr}
    MOV r4, #important_value  @ Save important data in callee-saved register
    
    BL some_function          @ Call - r0-r3 may be destroyed
    @ r0 now contains return value
    @ r4 still contains important_value
    
    ADD r0, r0, r4            @ Use return value with preserved data
    POP {r4, pc}              @ Return
```

### Returning Floating-Point and Integer Simultaneously

Some functions need to return both FP and integer results:

```c
// ARMv8
float process(int *status);
@ Returns float in s0, writes status to *status address passed in x0
```

**Example** implementation:
```
process:
    @ Compute float result...
    FMOV s0, #1.5         @ Float return value
    
    @ Compute status...
    MOV w1, #0            @ Status = success
    STR w1, [x0]          @ Write to caller's status variable
    
    RET                   @ Return s0 and modified *status
```

The caller receives the FP result in S0 and the integer status via the pointer.

### Complex Number Return Values

Complex numbers (with real and imaginary parts) use two FP registers:

**Example** ARMv8:
```c
// Complex float: real in s0, imaginary in s1
// Complex double: real in d0, imaginary in d1

float _Complex complex_sqrt(float _Complex z);
```

**Example** implementation:
```
complex_sqrt:
    @ Input: real in s0, imaginary in s1
    @ Compute result...
    @ Output: real in s0, imaginary in s1
    RET
```

### Returning Nothing vs Returning Undefined

Void functions don't specify a return value, but registers are in defined states:

**Void function**: Returns normally, R0/X0 contains undefined value but is in a valid state (not corrupted).

**No-return function**: Functions declared `noreturn` (like `exit()`) never return control to the caller. They may terminate the program, enter infinite loops, or perform non-local jumps.

```
void exit(int status) __attribute__((noreturn));

@ Implementation doesn't need return instruction:
exit:
    @ Terminate program through system call...
    @ No BX lr or RET - execution never continues
```

The `noreturn` attribute allows compilers to optimize away code after the call, since execution never continues.

### Preserving Return Values Across Cleanup

When returning a computed value, ensure cleanup code doesn't destroy it:

**Example** preserving return value during cleanup:
```
function:
    PUSH {r4-r6, lr}
    @ Allocate and use resources...
    
    @ Compute return value
    MOV r0, #42           @ Result in r0
    
    @ Clean up (don't modify r0)
    @ Deallocate resources, restore registers...
    POP {r4-r6, pc}       @ Return with r0 preserved
```

If cleanup code needs to use R0, save the return value temporarily:

```
function:
    PUSH {r4-r6, lr}
    @ Compute return value
    MOV r4, #42           @ Save return value in callee-saved register
    
    @ Cleanup that uses r0
    BL cleanup_function   @ May destroy r0
    
    MOV r0, r4            @ Restore return value
    POP {r4-r6, pc}       @ Return
```

### Returning From Nested Calls

Functions that call other functions must preserve LR before the call:

```
outer:
    PUSH {lr}             @ Save return address
    BL inner              @ Call inner (destroys LR)
    @ Process inner's return value in r0...
    POP {pc}              @ Return to original caller
```

Alternatively, combine saving and restoring with other registers:

```
outer:
    PUSH {r4, lr}         @ Save callee-saved register and LR
    BL inner
    @ Use r4 and process return value...
    POP {r4, pc}          @ Restore r4 and return
```

### Return Value Guarantees

AAPCS guarantees that return values are placed in designated registers, but doesn't specify:

- **Timing**: When during epilogue the return value is placed in the register
- **Unused bits**: Values in unused portions of registers (e.g., upper 16 bits when returning a 16-bit value)

**Example** 16-bit return value:
```
get_short:
    MOV r0, #0x1234       @ Return 16-bit value
    BX lr
```

The caller should mask or sign-extend as needed:
```
    BL get_short
    UXTH r0, r0           @ Zero-extend to ensure upper bits are clear
```

However, most calling conventions specify that narrow values are appropriately extended (zero or sign extended) to fill the register.

**Key Points**

The ARM Procedure Call Standard (AAPCS) defines comprehensive conventions for function interfaces, specifying register roles, parameter passing mechanisms, return value handling, and stack organization. Register usage divides into caller-saved registers (which callees may freely modify) and callee-saved registers (which must be preserved). Parameters pass through registers when possible (R0-R3 or X0-X7 for integers, S/D registers for floating-point), with excess parameters on the stack. Stack frames organize memory for each function invocation, containing saved registers, local variables, and linkage information, with strict alignment requirements (8-byte for ARMv7, 16-byte for ARMv8). Return values use designated registers (R0/R1 or X0/X1 for integers, S0/D0 for floating-point), with large structures returned indirectly via memory pointers. Following AAPCS precisely ensures assembly code interoperates correctly with compiled code from any conforming compiler, enabling modular development and library reuse. The standard balances performance (preferring register-based communication) with flexibility (supporting arbitrary parameter counts and types), while maintaining clear responsibility boundaries between caller and callee for register preservation and stack management.

---

