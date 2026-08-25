## Calling Conventions


Calling conventions define standardized rules for how functions receive parameters, return values, and manage the stack. Different conventions optimize for different goals: code size, speed, or compatibility.

### cdecl (C Declaration)

The C calling convention, default for C programs and most flexible for variable argument functions.

**Rules:**

- Parameters pushed right-to-left onto stack
- Caller cleans up stack after return
- Return value in EAX (integers), ST(0) (floats), or EAX:EDX (64-bit values on 32-bit)
- EAX, ECX, EDX are caller-saved (volatile)
- EBX, ESI, EDI, EBP are callee-saved (non-volatile)

**Example:**

```assembly
; C prototype: int add(int a, int b, int c);

; Caller side:
push 30         ; Third parameter (c)
push 20         ; Second parameter (b)
push 10         ; First parameter (a)
call add        ; Call function
add esp, 12     ; Caller cleans up 3 parameters × 4 bytes

; Callee side (function implementation):
add:
    push ebp              ; Save base pointer
    mov ebp, esp          ; Set up stack frame
    
    mov eax, [ebp+8]      ; First parameter (a)
    add eax, [ebp+12]     ; Second parameter (b)
    add eax, [ebp+16]     ; Third parameter (c)
    
    pop ebp               ; Restore base pointer
    ret                   ; Return (caller cleans stack)
```

**Stack Layout in cdecl:**

```
High addresses
    [parameter 3]     <- EBP + 16
    [parameter 2]     <- EBP + 12
    [parameter 1]     <- EBP + 8
    [return address]  <- EBP + 4
    [saved EBP]       <- EBP (current frame)
    [local variable]  <- EBP - 4
Low addresses         <- ESP
```

### stdcall (Standard Call)

Used extensively in Windows API functions, optimizes code size by having callee clean the stack.

**Rules:**

- Parameters pushed right-to-left onto stack
- Callee cleans up stack before return (using `ret n`)
- Return value in EAX/ST(0)/EAX:EDX (same as cdecl)
- Same register preservation as cdecl
- Function names decorated with @n suffix (n = bytes of parameters)

**Example:**

```assembly
; Windows API style: int __stdcall Add(int a, int b);

; Caller side:
push 20         ; Second parameter
push 10         ; First parameter
call _Add@8     ; Decorated name: _Add@8
; No stack cleanup needed - callee handles it

; Callee side:
_Add@8:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]      ; First parameter
    add eax, [ebp+12]     ; Second parameter
    
    pop ebp
    ret 8                 ; Return and clean 8 bytes
```

**Key Difference from cdecl:**

```assembly
; cdecl - caller cleans:
call func
add esp, 8        ; Cleanup after each call

; stdcall - callee cleans:
call func         ; Function does cleanup internally
                  ; No cleanup needed here
```

### fastcall

Optimizes for speed by passing parameters in registers instead of stack, reducing memory access.

**Rules (Microsoft x86 fastcall):**

- First two integer/pointer parameters in ECX and EDX
- Remaining parameters pushed right-to-left onto stack
- Callee cleans up stack
- Return value in EAX/ST(0)/EAX:EDX
- Function names decorated with @n prefix

**Example:**

```assembly
; int __fastcall Multiply(int a, int b, int c);

; Caller side:
push 30         ; Third parameter on stack
mov edx, 20     ; Second parameter in EDX
mov ecx, 10     ; First parameter in ECX
call @Multiply@12
; No cleanup needed

; Callee side:
@Multiply@12:
    push ebp
    mov ebp, esp
    
    mov eax, ecx          ; First param from ECX
    imul eax, edx         ; Multiply by second param (EDX)
    imul eax, [ebp+8]     ; Multiply by third param (stack)
    
    pop ebp
    ret 4                 ; Clean up stack parameter
```

**Register Usage:**

```
Parameter 1: ECX
Parameter 2: EDX
Parameter 3+: Stack (right-to-left)
```

### x64 Calling Conventions

64-bit architectures use different conventions that maximize register usage.

**Microsoft x64 Convention (Windows):**

- First 4 integer/pointer params: RCX, RDX, R8, R9
- First 4 floating-point params: XMM0, XMM1, XMM2, XMM3
- Additional parameters on stack (right-to-left)
- Caller allocates 32-byte "shadow space" on stack for register params
- Caller cleans up stack
- Return value in RAX (integer) or XMM0 (float)
- RBX, RBP, RDI, RSI, RSP, R12-R15 are callee-saved
- RAX, RCX, RDX, R8-R11 are caller-saved

**Example:**

```assembly
; int64_t Add4(int64_t a, int64_t b, int64_t c, int64_t d);

; Caller side (Windows x64):
sub rsp, 32           ; Allocate shadow space
mov r9, 40            ; Fourth parameter
mov r8, 30            ; Third parameter
mov rdx, 20           ; Second parameter
mov rcx, 10           ; First parameter
call Add4
add rsp, 32           ; Clean up shadow space

; Callee side:
Add4:
    mov rax, rcx          ; First param
    add rax, rdx          ; Second param
    add rax, r8           ; Third param
    add rax, r9           ; Fourth param
    ret
```

**System V AMD64 ABI (Linux, macOS):**

- First 6 integer/pointer params: RDI, RSI, RDX, RCX, R8, R9
- First 8 floating-point params: XMM0-XMM7
- Additional parameters on stack (right-to-left)
- No shadow space required
- Caller cleans up stack
- Red zone: 128 bytes below RSP for leaf functions

**Example:**

```assembly
; System V AMD64 calling convention

; Caller side (Linux):
mov r9, 60            ; Sixth parameter
mov r8, 50            ; Fifth parameter
mov rcx, 40           ; Fourth parameter
mov rdx, 30           ; Third parameter
mov rsi, 20           ; Second parameter
mov rdi, 10           ; First parameter
call Add6
; No shadow space needed

; Callee side:
Add6:
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    add rax, rcx
    add rax, r8
    add rax, r9
    ret
```

### Other Calling Conventions

**thiscall (C++ Member Functions):**

- Used for non-static C++ member functions
- `this` pointer passed in ECX (Microsoft) or as first parameter (GCC)
- Otherwise similar to cdecl or stdcall

**vectorcall (Microsoft):**

- Optimized for vector operations
- Up to 6 vector parameters in XMM/YMM registers
- Used with SSE/AVX code

**regparm(n) (GCC):**

- Up to 3 parameters in EAX, EDX, ECX
- Remaining on stack
- Custom optimization attribute

