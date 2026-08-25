## Stack Frames


Stack frames (also called activation records) are the regions of stack memory allocated for each function invocation. Each frame contains the function's parameters, return address, saved registers, and local variables.

### Stack Frame Structure

A typical stack frame layout in 64-bit System V calling convention:

```
Higher Address
    +---------------------------+
    | Argument 7+ (if any)      | [RBP+16+]
    +---------------------------+
    | Return Address            | [RBP+8]
    +---------------------------+
    | Saved RBP                 | [RBP]  ← RBP points here
    +---------------------------+
    | Local Variable 1          | [RBP-8]
    +---------------------------+
    | Local Variable 2          | [RBP-16]
    +---------------------------+
    | Saved Callee Registers    | [RBP-24], etc.
    +---------------------------+
    | Temporary Storage         |
    +---------------------------+
    | Padding (for alignment)   |
    +---------------------------+
    | Outgoing Args (7+)        | ← RSP points here
    +---------------------------+
Lower Address
```

**Components**:

**Incoming parameters**: In 64-bit calling conventions, the first six integer/pointer arguments arrive in registers (RDI, RSI, RDX, RCX, R8, R9 for System V; RCX, RDX, R8, R9 for Windows x64). Additional arguments are pushed onto the stack by the caller. These appear at positive offsets from RBP (above the saved RBP).

**Return address**: The CALL instruction automatically pushes the return address (the address of the instruction following CALL) onto the stack. This appears at [RBP+8] after the frame pointer is established.

**Saved frame pointer**: The function prologue typically saves the caller's RBP value, allowing restoration in the epilogue. This provides the chain of frame pointers for stack unwinding.

**Local variables**: Variables declared in the function occupy space at negative offsets from RBP (below the saved RBP). The compiler assigns each local variable a specific stack offset.

**Saved registers**: Callee-saved registers (RBX, R12-R15, RBP in System V; RBX, RBP, RDI, RSI, R12-R15 in Windows x64) must be preserved by the called function. These are typically pushed in the prologue and popped in the epilogue.

**Temporary storage**: Space for spilled registers, intermediate computation results, and other temporary data.

**Outgoing arguments**: When the function calls other functions, arguments beyond those passed in registers are placed here. This space is allocated once in the prologue (if the maximum needed size is known) or adjusted before each call.

### Function Prologue and Epilogue

The function prologue establishes the stack frame at function entry. The epilogue tears it down before returning.

**Standard prologue**:

```asm
function_name:
    PUSH RBP           ; Save caller's frame pointer
    MOV RBP, RSP       ; Establish new frame pointer
    SUB RSP, 64        ; Allocate space for locals and temps
    PUSH RBX           ; Save callee-saved registers
    PUSH R12
    PUSH R13
    ; Function body begins
```

After the prologue:

- RBP points to the base of the current frame (saved RBP location)
- RSP points to the top of the stack (lowest address used)
- Saved registers and local variables have known offsets from RBP

**Standard epilogue**:

```asm
    ; Function body ends
    POP R13            ; Restore callee-saved registers
    POP R12
    POP RBX
    MOV RSP, RBP       ; Deallocate local space (or ADD RSP, 64)
    POP RBP            ; Restore caller's frame pointer
    RET                ; Return to caller
```

Alternative epilogue using LEAVE:

```asm
    POP R13
    POP R12
    POP RBX
    LEAVE              ; Equivalent to: MOV RSP, RBP; POP RBP
    RET
```

LEAVE is a single instruction that performs both the stack pointer restoration and frame pointer pop. [Inference] LEAVE may be faster or slower than separate MOV and POP depending on the processor microarchitecture.

**Optimized prologue (frame pointer omitted)**:

```asm
function_name:
    SUB RSP, 64        ; Allocate space
    PUSH RBX           ; Save registers
    PUSH R12
    ; Function body - locals accessed via [RSP+offset]
```

Without a frame pointer, all stack accesses use RSP-relative addressing. The compiler must track RSP changes to correctly compute offsets. This optimization frees RBP for general use but complicates debugging and unwinding.

**Optimized epilogue**:

```asm
    POP R12
    POP RBX
    ADD RSP, 64        ; Deallocate (or adjust for pushed registers)
    RET
```

### Function Calling Conventions

Calling conventions define how functions receive parameters, return values, and manage the stack. Different conventions exist for different platforms and historical reasons.

#### System V AMD64 ABI (Linux, macOS, BSD)

**Parameter passing**:

- Integer/pointer arguments 1-6: RDI, RSI, RDX, RCX, R8, R9
- Floating-point arguments 1-8: XMM0-XMM7
- Additional arguments: pushed onto stack right-to-left
- Return value: RAX (integer/pointer), XMM0 (floating-point)
- Large return values: caller allocates space, pointer passed in RDI

**Register preservation**:

- Caller-saved (volatile): RAX, RCX, RDX, RSI, RDI, R8-R11, XMM0-XMM15
- Callee-saved (non-volatile): RBX, RBP, R12-R15
- Stack must be 16-byte aligned before CALL

**Stack cleanup**: Caller responsible for removing arguments from stack

**Example call**:

```asm
; Call function(10, 20, 30, 40, 50, 60, 70, 80)
MOV RDI, 10        ; Arg 1
MOV RSI, 20        ; Arg 2
MOV RDX, 30        ; Arg 3
MOV RCX, 40        ; Arg 4
MOV R8, 50         ; Arg 5
MOV R9, 60         ; Arg 6
PUSH 80            ; Arg 8 (push right-to-left)
PUSH 70            ; Arg 7
CALL function
ADD RSP, 16        ; Clean up 2 stack arguments
```

#### Windows x64 Calling Convention (Microsoft)

**Parameter passing**:

- Integer/pointer arguments 1-4: RCX, RDX, R8, R9
- Floating-point arguments 1-4: XMM0-XMM3 (in same positions as integer args)
- Additional arguments: pushed onto stack right-to-left
- Return value: RAX (integer/pointer), XMM0 (floating-point)

**Shadow space**: Caller must allocate 32 bytes of shadow space (home space) for the first four register parameters, even if not all are used. The callee may spill register parameters into this space.

**Register preservation**:

- Caller-saved: RAX, RCX, RDX, R8-R11, XMM0-XMM5
- Callee-saved: RBX, RBP, RDI, RSI, R12-R15, XMM6-XMM15
- Stack must be 16-byte aligned before CALL

**Stack cleanup**: Caller responsible

**Example call**:

```asm
; Call function(10, 20, 30, 40, 50, 60)
SUB RSP, 40        ; Allocate shadow space (32) + 2 args (16)
                   ; Total 48, but 40 for 16-byte alignment
MOV RCX, 10        ; Arg 1
MOV RDX, 20        ; Arg 2
MOV R8, 30         ; Arg 3
MOV R9, 40         ; Arg 4
MOV QWORD [RSP+32], 50    ; Arg 5 (above shadow space)
MOV QWORD [RSP+40], 60    ; Arg 6
CALL function
ADD RSP, 40        ; Clean up shadow space and stack args
```

The shadow space allows callees to save register parameters without adjusting RSP:

```asm
function:
    ; Can spill parameters
    MOV [RSP+8], RCX    ; Save first parameter
    MOV [RSP+16], RDX   ; Save second parameter
    ; No prologue needed for simple functions
    ; ... function body ...
    RET
```

#### 32-bit Calling Conventions

**Cdecl** (C declaration, common on Linux/Unix):

- All arguments pushed onto stack right-to-left
- Caller cleans up stack
- Return value in EAX
- Callee-saved: EBX, ESI, EDI, EBP

**Stdcall** (standard call, Windows API):

- All arguments pushed onto stack right-to-left
- Callee cleans up stack
- Return value in EAX
- Callee-saved: EBX, ESI, EDI, EBP

**Fastcall**:

- First two arguments in ECX and EDX
- Additional arguments on stack
- Callee cleans up stack
- Return value in EAX

### Variable-Length Argument Lists

Functions accepting variable numbers of arguments (like printf) require special handling.

In System V AMD64, variadic functions:

- Use registers for the initial arguments as usual
- Place a register save area on the stack containing copies of the register parameters
- Provide the va_list structure pointing to both register save area and stack arguments

In Windows x64:

- Treat all arguments uniformly after the fourth
- Use shadow space and stack for variadic arguments
- The va_list structure simply points into the stack

**Example variadic function prologue (System V)**:

```asm
variadic_function:
    PUSH    RBP
    MOV     RBP, RSP
    SUB     RSP, 176               ; Allocate space for register save area

    ; Save register parameters
    MOV     [RBP-8],   RDI
    MOV     [RBP-16],  RSI
    MOV     [RBP-24],  RDX
    MOV     [RBP-32],  RCX
    MOV     [RBP-40],  R8
    MOV     [RBP-48],  R9

    ; Save floating-point parameters
    MOVAPS  [RBP-64],   XMM0
    MOVAPS  [RBP-80],   XMM1
    MOVAPS  [RBP-96],   XMM2
    MOVAPS  [RBP-112],  XMM3
    MOVAPS  [RBP-128],  XMM4
    MOVAPS  [RBP-144],  XMM5
    MOVAPS  [RBP-160],  XMM6
    MOVAPS  [RBP-176],  XMM7

    ; va_list initialization uses these saved registers

````

The va_list structure contains:
- gp_offset: offset into register save area for next general-purpose register argument
- fp_offset: offset for next floating-point register argument
- overflow_arg_area: pointer to stack arguments beyond registers
- reg_save_area: pointer to saved register arguments

