## Function Calls and Returns


### ARM Procedure Call Standard (AAPCS)

The AAPCS defines register usage and calling conventions.

**Register Usage:**

- **r0-r3**: Argument registers (first 4 arguments)
- **r0**: Return value
- **r4-r11**: Callee-saved (must preserve)
- **r12 (IP)**: Intra-procedure call scratch register
- **r13 (SP)**: Stack pointer
- **r14 (LR)**: Link register (return address)
- **r15 (PC)**: Program counter

**Stack Alignment:**

- Stack must be 8-byte aligned at public interfaces
- Caller allocates space for arguments beyond r0-r3

### Simple Function Call

**Caller:**

```assembly
# Call function with arguments
    mov r0, #10          @ First argument
    mov r1, #20          @ Second argument
    bl add_numbers       @ Call function
    # r0 contains return value
```

**Callee:**

```assembly
# int add_numbers(int a, int b)
add_numbers:
    add r0, r0, r1       @ result = a + b
    bx lr                @ Return
```

### Leaf Function (No Nested Calls)

A leaf function doesn't call other functions.

**Example:**

```assembly
# int square(int x)
square:
    mul r0, r0, r0       @ x * x
    bx lr
```

### Non-Leaf Function (Saves LR)

Functions that call other functions must preserve LR.

**Example:**

```assembly
# int calculate(int a, int b)
# Returns: (a + b) * 2
calculate:
    push {lr}            @ Save return address
    
    add r0, r0, r1       @ a + b
    bl double_value      @ Call another function
    
    pop {pc}             @ Return (pop into PC)

double_value:
    lsl r0, r0, #1       @ x * 2
    bx lr
```

### Preserving Registers

**Callee-Saved Registers:**

```assembly
# Function using callee-saved registers
process_array:
    push {r4-r7, lr}     @ Save registers we'll use
    
    mov r4, r0           @ Save array pointer
    mov r5, r1           @ Save count
    mov r6, #0           @ Initialize sum
    mov r7, #0           @ Initialize index

loop:
    cmp r7, r5
    bge done
    
    ldr r0, [r4, r7, LSL #2]
    bl process_element   @ Can modify r0-r3, r12
    add r6, r6, r0       @ Accumulate result
    add r7, r7, #1
    b loop

done:
    mov r0, r6           @ Return sum
    pop {r4-r7, pc}      @ Restore and return
```

### Stack Frame

Functions with local variables create a stack frame.

**Stack Frame Layout:**

```
High addresses
+------------------+
| Saved LR         |  <- [FP, #4]
| Saved FP         |  <- FP (r11)
| Local var 1      |  <- [FP, #-4]
| Local var 2      |  <- [FP, #-8]
| Saved r4         |
| Saved r5         |
+------------------+  <- SP
Low addresses
```

**Function with Stack Frame:**

```assembly
# function(int a, int b)
# Local variables: int x, y, z
function_with_locals:
    push {r4-r5, fp, lr} @ Save registers
    mov fp, sp           @ Setup frame pointer
    sub sp, sp, #12      @ Allocate space for 3 local vars
    
    # Access parameters (in r0, r1)
    # Access local variables
    str r0, [fp, #-4]    @ x = a
    str r1, [fp, #-8]    @ y = b
    
    # Calculate z = x + y
    ldr r4, [fp, #-4]    @ Load x
    ldr r5, [fp, #-8]    @ Load y
    add r4, r4, r5       @ x + y
    str r4, [fp, #-12]   @ z = x + y
    
    # Return z
    ldr r0, [fp, #-12]
    
    mov sp, fp           @ Restore stack pointer
    pop {r4-r5, fp, pc}  @ Restore and return
```

### Variadic Functions

Functions with variable number of arguments.

**Example: printf-like function:**

```assembly
# int sum_varargs(int count, ...)
# r0 = count, r1-r3 = first three values, rest on stack
sum_varargs:
    push {r4, r5, lr}
    
    mov r4, #0           @ sum = 0
    mov r5, r0           @ counter = count
    
    # Process r1 if count >= 1
    cmp r5, #0
    ble varargs_done
    add r4, r4, r1
    sub r5, r5, #1
    
    # Process r2 if count >= 2
    cmp r5, #0
    ble varargs_done
    add r4, r4, r2
    sub r5, r5, #1
    
    # Process r3 if count >= 3
    cmp r5, #0
    ble varargs_done
    add r4, r4, r3
    sub r5, r5, #1
    
    # Process stack arguments
    add r0, sp, #12      @ Point to first stack arg
    
varargs_loop:
    cmp r5, #0
    ble varargs_done
    
    ldr r1, [r0], #4     @ Load and advance
    add r4, r4, r1
    sub r5, r5, #1
    b varargs_loop

varargs_done:
    mov r0, r4           @ Return sum
    pop {r4, r5, pc}
```

### Tail Call Optimization

When a function's last action is calling another function, optimize by jumping instead of calling.

**Without Optimization:**

```assembly
function_a:
    push {lr}
    # ... some work ...
    bl function_b        @ Call
    pop {pc}             @ Return
```

**With Tail Call Optimization:**

```assembly
function_a:
    # ... some work ...
    b function_b         @ Jump directly (no push/pop)
                         @ function_b will return to our caller
```

**Tail Recursion Example:**

```assembly
# int factorial_tail(int n, int accumulator)
factorial_tail:
    cmp r0, #1
    bls factorial_base   @ if n <= 1
    
    mul r1, r1, r0       @ accumulator *= n
    sub r0, r0, #1       @ n--
    b factorial_tail     @ Tail call (becomes loop)

factorial_base:
    mov r0, r1           @ Return accumulator
    bx lr
```

### Recursive Functions

**Direct Recursion:**

```assembly
# int factorial(int n)
factorial:
    cmp r0, #1
    bls factorial_base
    
    push {r0, lr}        @ Save n and return address
    sub r0, r0, #1       @ n - 1
    bl factorial         @ Recursive call
    
    pop {r1, lr}         @ Restore n
    mul r0, r0, r1       @ n * factorial(n-1)
    bx lr

factorial_base:
    mov r0, #1
    bx lr
```

**Mutual Recursion:**

```assembly
# int is_even(int n);
# int is_odd(int n);

is_even:
    cmp r0, #0
    moveq r0, #1         @ 0 is even
    bxeq lr
    
    push {lr}
    sub r0, r0, #1
    bl is_odd            @ is_even(n) = is_odd(n-1)
    pop {pc}

is_odd:
    cmp r0, #0
    moveq r0, #0         @ 0 is not odd
    bxeq lr
    
    push {lr}
    sub r0, r0, #1
    bl is_even           @ is_odd(n) = is_even(n-1)
    pop {pc}
```

### Function Pointers

Calling functions through pointers.

**Direct Call Through Register:**

```assembly
# void (*func_ptr)(int, int) = my_function;
# func_ptr(10, 20);

    ldr r0, =my_function @ Load function address
    mov r1, #10          @ First argument
    mov r2, #20          @ Second argument
    
    # Call through register
    push {lr}
    blx r0               @ Branch with link and exchange
    pop {pc}
```

**Function Pointer Array:**

```assembly
# Array of function pointers
    .data
function_table:
    .word func0
    .word func1
    .word func2
    .word func3

    .text
# Call function by index
# r0 = index
call_by_index:
    cmp r0, #3
    movhi r0, #-1
    bxhi lr              @ Return error
    
    ldr r1, =function_table
    ldr r2, [r1, r0, LSL #2]  @ Load function address
    
    push {lr}
    blx r2               @ Call function
    pop {pc}

func0:
    mov r0, #0
    bx lr

func1:
    mov r0, #1
    bx lr

func2:
    mov r0, #2
    bx lr

func3:
    mov r0, #3
    bx lr
```

