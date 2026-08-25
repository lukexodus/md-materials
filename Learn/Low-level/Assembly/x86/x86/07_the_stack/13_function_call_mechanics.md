## Function Call Mechanics


### CALL Instruction

CALL transfers control to a subroutine, pushing the return address onto the stack:

```nasm
call function_name          ; Push return address, jump to function_name
call rax                    ; Push return address, jump to address in RAX
call [memory]               ; Push return address, jump to address at memory
```

CALL operation steps:

1. Push the address of the instruction following CALL (return address)
2. Set RIP to the target address

After CALL, the stack contains:

```
┌─────────────────┐
│ Return address  │ ← RSP (top of stack)
├─────────────────┤
│  Previous data  │
```

### RET Instruction

RET returns from a subroutine by popping the return address:

```nasm
ret                         ; Pop return address into RIP
ret 0x10                    ; Pop return address, then add 0x10 to RSP
```

RET operation steps:

1. Pop the value at [RSP] into RIP
2. If operand present, add it to RSP (for cleaning up parameters)

The RET with operand form is rarely used in modern 64-bit calling conventions, as parameters are typically passed in registers rather than on the stack.

### Stack Frame Structure

A typical function stack frame:

```
High Memory
┌─────────────────────────┐
│  Function parameters    │  (if stack-passed)
│  (parameter N)          │
│  ...                    │
│  (parameter 1)          │
├─────────────────────────┤
│  Return address         │  ← Pushed by CALL
├─────────────────────────┤
│  Saved RBP              │  ← Pushed by function prologue
├─────────────────────────┤ ← RBP (frame pointer)
│  Local variable 1       │
│  Local variable 2       │
│  ...                    │
│  Saved registers        │
│  Temporary data         │
├─────────────────────────┤ ← RSP (stack pointer)
│  Available space        │
Low Memory
```

### Function Prologue and Epilogue

**Standard prologue** establishes the stack frame:

```nasm
function_name:
    push rbp                ; Save caller's frame pointer
    mov rbp, rsp            ; Establish new frame pointer
    sub rsp, N              ; Allocate N bytes for local variables
```

After the prologue:

- RBP points to the saved previous frame pointer
- Local variables are accessed as [rbp - offset]
- Parameters (if stack-passed) are accessed as [rbp + offset]
- RSP points to the current top of stack

**Standard epilogue** tears down the stack frame:

```nasm
    mov rsp, rbp            ; Restore stack pointer (deallocate locals)
    pop rbp                 ; Restore caller's frame pointer
    ret                     ; Return to caller
```

Alternative epilogue using LEAVE instruction:

```nasm
    leave                   ; Equivalent to: mov rsp, rbp; pop rbp
    ret
```

The LEAVE instruction combines stack cleanup operations into a single instruction.

### Frame Pointer vs. No Frame Pointer

**With frame pointer (RBP)**:

- Fixed reference point for accessing locals and parameters
- Simplifies debugging and stack unwinding
- Slightly reduces available registers
- Enables easier variable access with consistent offsets

```nasm
; Accessing locals with frame pointer
mov eax, [rbp - 4]          ; Local variable at fixed offset
mov ebx, [rbp - 8]          ; Another local variable
mov ecx, [rbp + 16]         ; Parameter at fixed offset
```

**Without frame pointer** (optimization flag `-fomit-frame-pointer`):

- RSP used for accessing both locals and parameters
- Frees RBP for general use
- More efficient register usage
- Offsets from RSP change as stack is used

```nasm
; Accessing locals without frame pointer
mov eax, [rsp + 0]          ; Local variable (offset changes if RSP changes)
mov ebx, [rsp + 4]          ; Another local variable
```

Omitting the frame pointer is common in optimized code but complicates debugging.

