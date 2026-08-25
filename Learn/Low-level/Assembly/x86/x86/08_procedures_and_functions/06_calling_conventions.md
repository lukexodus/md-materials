## Calling Conventions


Calling conventions define how parameters are passed to procedures, how return values are communicated, and which registers must be preserved. Different conventions exist across platforms and compilers.

### cdecl Convention (C Declaration)

Used primarily in 32-bit C programs on Unix-like systems and Windows.

- Parameters pushed onto stack from right to left
- Caller cleans up the stack after the call
- Return values in EAX (32-bit integers) or EAX:EDX (64-bit integers)
- EAX, ECX, EDX are caller-saved (can be modified by callee)
- EBX, ESI, EDI, EBP must be preserved by callee

**Example:**

```nasm
; Calling function(5, 10, 15)
push 15          ; Third parameter
push 10          ; Second parameter
push 5           ; First parameter
call function
add esp, 12      ; Caller cleans up stack (3 params × 4 bytes)

function:
    push ebp
    mov ebp, esp
    ; [ebp+8] = first param (5)
    ; [ebp+12] = second param (10)
    ; [ebp+16] = third param (15)
    mov eax, [ebp+8]
    add eax, [ebp+12]
    add eax, [ebp+16]    ; eax = 30 (return value)
    pop ebp
    ret
```

### stdcall Convention

Used by Windows API functions.

- Parameters pushed onto stack from right to left
- Callee cleans up the stack before returning
- Return values in EAX
- Same register preservation rules as cdecl

**Example:**

```nasm
; Calling function(5, 10)
push 10
push 5
call function
; No stack cleanup needed - callee does it

function:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]
    add eax, [ebp+12]
    pop ebp
    ret 8            ; Return and clean 8 bytes from stack
```

### fastcall Convention

Optimizes parameter passing by using registers for the first few arguments.

- First two parameters in ECX and EDX (32-bit) or RCX, RDX, R8, R9 (64-bit Windows)
- Remaining parameters on stack
- Callee cleans the stack
- Return values in EAX/RAX

**Example (32-bit):**

```nasm
; Calling function(5, 10, 15)
push 15          ; Third parameter on stack
mov edx, 10      ; Second parameter in EDX
mov ecx, 5       ; First parameter in ECX
call function

function:
    push ebp
    mov ebp, esp
    ; ecx = first param (5)
    ; edx = second param (10)
    ; [ebp+8] = third param (15)
    add ecx, edx
    add ecx, [ebp+8]
    mov eax, ecx     ; eax = return value
    pop ebp
    ret 4
```

### x64 Calling Convention (Windows)

The Microsoft x64 calling convention uses registers extensively.

- First four integer/pointer parameters: RCX, RDX, R8, R9
- First four floating-point parameters: XMM0, XMM1, XMM2, XMM3
- Additional parameters on stack (right to left)
- Caller must allocate 32 bytes of shadow space on stack for the four register parameters
- Caller cleans up the stack
- Return values in RAX (integers) or XMM0 (floating-point)
- RAX, RCX, RDX, R8-R11, XMM0-XMM5 are volatile (caller-saved)
- RBX, RBP, RDI, RSI, RSP, R12-R15, XMM6-XMM15 must be preserved by callee

**Example:**

```nasm
; Calling function(1, 2, 3, 4, 5, 6)
sub rsp, 40      ; Allocate shadow space (32) + 2 params (16), aligned
mov qword [rsp+40], 6    ; Sixth parameter
mov qword [rsp+32], 5    ; Fifth parameter
mov r9, 4        ; Fourth parameter
mov r8, 3        ; Third parameter
mov rdx, 2       ; Second parameter
mov rcx, 1       ; First parameter
call function
add rsp, 40      ; Clean up stack

function:
    push rbp
    mov rbp, rsp
    sub rsp, 32      ; Allocate space if needed
    ; rcx = 1, rdx = 2, r8 = 3, r9 = 4
    ; [rbp+16] = 5, [rbp+24] = 6
    add rcx, rdx
    add rcx, r8
    add rcx, r9
    add rcx, [rbp+16]
    add rcx, [rbp+24]
    mov rax, rcx     ; rax = 21
    add rsp, 32
    pop rbp
    ret
```

### System V AMD64 ABI (Linux/Unix x64)

Different from Windows x64 convention.

- First six integer/pointer parameters: RDI, RSI, RDX, RCX, R8, R9
- First eight floating-point parameters: XMM0-XMM7
- Additional parameters on stack
- No shadow space required
- Return values in RAX (integers) or XMM0 (floating-point)
- RAX, RCX, RDX, RSI, RDI, R8-R11 are caller-saved
- RBX, RBP, R12-R15 must be preserved by callee

**Example:**

```nasm
; Calling function(1, 2, 3, 4, 5, 6, 7)
push 7           ; Seventh parameter
mov r9, 6        ; Sixth parameter
mov r8, 5        ; Fifth parameter
mov rcx, 4       ; Fourth parameter
mov rdx, 3       ; Third parameter
mov rsi, 2       ; Second parameter
mov rdi, 1       ; First parameter
call function
add rsp, 8       ; Clean up stack

function:
    push rbp
    mov rbp, rsp
    ; rdi = 1, rsi = 2, rdx = 3, rcx = 4, r8 = 5, r9 = 6
    ; [rbp+16] = 7
    add rdi, rsi
    add rdi, rdx
    add rdi, rcx
    add rdi, r8
    add rdi, r9
    add rdi, [rbp+16]
    mov rax, rdi     ; rax = 28
    pop rbp
    ret
```

