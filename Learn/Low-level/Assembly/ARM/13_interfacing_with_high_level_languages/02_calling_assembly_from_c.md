## Calling Assembly from C


Calling assembly functions from C requires the assembly function to follow AAPCS conventions. The assembly function must properly save/restore callee-saved registers and manage the stack.

**Basic Assembly Function Template:**

```assembly
.global my_asm_function
.type my_asm_function, %function

my_asm_function:
    ; Function prologue
    PUSH    {R4-R11, LR}         ; Save callee-saved regs and return address
    
    ; Function body
    ; R0-R3 contain arguments
    ; Use R4-R11 for local variables
    
    ; Prepare return value in R0
    
    ; Function epilogue
    POP     {R4-R11, PC}         ; Restore registers and return
    
.size my_asm_function, .-my_asm_function
```

**Example** - Simple integer function:

C declaration:

```c
int add(int a, int b);
```

Assembly implementation:

```assembly
.global add
.type add, %function

add:
    ADD     R0, R0, R1           ; R0 = R0 + R1
    BX      LR                   ; Return (no registers to save)
    
.size add, .-add
```

**Example** - Function using local variables:

C declaration:

```c
int compute(int a, int b, int c);
```

Assembly implementation:

```assembly
.global compute
.type compute, %function

compute:
    PUSH    {R4, LR}             ; Save R4 (callee-saved) and LR
    
    ; Use R4 for intermediate result
    MUL     R4, R0, R1           ; R4 = a * b
    ADD     R4, R4, R2           ; R4 += c
    LSL     R4, R4, #2           ; R4 <<= 2
    
    MOV     R0, R4               ; Return value in R0
    POP     {R4, PC}             ; Restore R4 and return
    
.size compute, .-compute
```

**Example** - Function with stack frame:

C declaration:

```c
int array_sum(int *array, int length);
```

Assembly implementation:

```assembly
.global array_sum
.type array_sum, %function

array_sum:
    PUSH    {R4, R5, LR}         ; Save callee-saved registers
    SUB     SP, SP, #4           ; Allocate local variable (maintain 8-byte alignment)
    
    ; R0 = array pointer, R1 = length
    MOV     R2, #0               ; sum = 0
    MOV     R3, #0               ; i = 0
    
loop:
    CMP     R3, R1               ; i < length?
    BGE     done
    
    LDR     R4, [R0, R3, LSL #2] ; Load array[i]
    ADD     R2, R2, R4           ; sum += array[i]
    ADD     R3, R3, #1           ; i++
    B       loop
    
done:
    MOV     R0, R2               ; Return sum
    ADD     SP, SP, #4           ; Deallocate local variable
    POP     {R4, R5, PC}         ; Restore and return
    
.size array_sum, .-array_sum
```

**Example** - Floating-point function (hard float):

C declaration:

```c
float vector_dot_product(float *a, float *b, int n);
```

Assembly implementation:

```assembly
.global vector_dot_product
.type vector_dot_product, %function

vector_dot_product:
    VPUSH   {D8}                 ; Save callee-saved D8 (overlaps S16-S17)
    
    VMOV.F32 S0, #0.0            ; sum = 0.0
    MOV      R3, #0              ; i = 0
    
loop:
    CMP      R3, R2              ; i < n?
    BGE      done
    
    VLDR.F32 S1, [R0, R3, LSL #2] ; Load a[i]
    VLDR.F32 S2, [R1, R3, LSL #2] ; Load b[i]
    VMLA.F32 S0, S1, S2          ; sum += a[i] * b[i]
    ADD      R3, R3, #1          ; i++
    B        loop
    
done:
    ; Return value already in S0
    VPOP     {D8}                ; Restore D8
    BX       LR
    
.size vector_dot_product, .-vector_dot_product
```

**Example** - Structure parameter and return:

C declarations:

```c
typedef struct {
    int x, y;
} Point;

Point translate_point(Point p, int dx, int dy);
```

Assembly implementation (structure ≤64 bits passed in registers):

```assembly
.global translate_point
.type translate_point, %function

translate_point:
    ; R0 = p.x, R1 = p.y, R2 = dx, R3 = dy
    ADD     R0, R0, R2           ; p.x += dx
    ADD     R1, R1, R3           ; p.y += dy
    ; Return in R0 (x) and R1 (y)
    BX      LR
    
.size translate_point, .-translate_point
```

**Example** - Large structure return:

C declarations:

```c
typedef struct {
    int data[10];
} LargeStruct;

LargeStruct make_struct(int value);
```

Assembly implementation:

```assembly
.global make_struct
.type make_struct, %function

make_struct:
    PUSH    {R4, R5, LR}
    
    ; R0 = pointer to return structure (passed by caller)
    ; R1 = value argument (original R0 shifted to R1)
    MOV     R2, R0               ; Save return pointer
    MOV     R3, #0               ; Counter
    
fill_loop:
    CMP     R3, #10
    BGE     done
    STR     R1, [R2, R3, LSL #2] ; Store value to data[i]
    ADD     R3, R3, #1
    B       fill_loop
    
done:
    ; Return value is pointer in R0 (already set)
    POP     {R4, R5, PC}
    
.size make_struct, .-make_struct
```

**Calling from C:**

```c
// C code calling assembly functions
#include <stdio.h>

// Declarations
int add(int a, int b);
int compute(int a, int b, int c);
int array_sum(int *array, int length);
float vector_dot_product(float *a, float *b, int n);

int main() {
    // Call simple function
    int result = add(10, 20);
    printf("add(10, 20) = %d\n", result);
    
    // Call complex function
    result = compute(2, 3, 4);
    printf("compute(2, 3, 4) = %d\n", result);
    
    // Call array function
    int arr[] = {1, 2, 3, 4, 5};
    result = array_sum(arr, 5);
    printf("array_sum = %d\n", result);
    
    // Call floating-point function
    float a[] = {1.0, 2.0, 3.0};
    float b[] = {4.0, 5.0, 6.0};
    float dot = vector_dot_product(a, b, 3);
    printf("dot product = %f\n", dot);
    
    return 0;
}
```

