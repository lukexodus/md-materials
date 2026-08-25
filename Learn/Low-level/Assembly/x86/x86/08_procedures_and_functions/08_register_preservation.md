## Register Preservation


Register preservation ensures that callee procedures don't corrupt registers that the caller depends on. Registers are categorized as caller-saved (volatile) or callee-saved (non-volatile).

### Caller-Saved Registers (Volatile)

These registers can be freely modified by the callee. The caller must save them before a call if their values are needed afterward.

**32-bit (cdecl/stdcall):** EAX, ECX, EDX **64-bit (Windows):** RAX, RCX, RDX, R8-R11, XMM0-XMM5 **64-bit (System V):** RAX, RCX, RDX, RSI, RDI, R8-R11, XMM0-XMM15

**Example:**

```nasm
caller:
    mov eax, 10
    mov ecx, 20
    push ecx             ; Save ECX if needed after call
    call some_function   ; May modify EAX, ECX, EDX
    pop ecx              ; Restore ECX
    ; EAX is modified by callee (return value)
    ; ECX is preserved by caller
```

### Callee-Saved Registers (Non-Volatile)

These registers must be preserved by the callee. If a procedure uses them, it must save and restore their values.

**32-bit (cdecl/stdcall):** EBX, ESI, EDI, EBP **64-bit (Windows):** RBX, RBP, RDI, RSI, RSP, R12-R15, XMM6-XMM15 **64-bit (System V):** RBX, RBP, R12-R15

**Example:**

```nasm
my_procedure:
    push ebp             ; Save EBP
    mov ebp, esp
    push ebx             ; Save EBX (will be used)
    push esi             ; Save ESI (will be used)
    
    mov ebx, [ebp+8]     ; Use EBX for computation
    mov esi, [ebp+12]    ; Use ESI for computation
    ; ... procedure code ...
    
    pop esi              ; Restore ESI
    pop ebx              ; Restore EBX
    pop ebp              ; Restore EBP
    ret
```

### Stack Pointer Preservation

The stack pointer (ESP/RSP) must always be preserved. The stack must be in the same state when returning as when the procedure was called (accounting for the return address and any parameters the callee is responsible for removing).

**Example:**

```nasm
procedure:
    push ebp
    mov ebp, esp
    sub esp, 16          ; Allocate local variables
    
    ; ... procedure code ...
    
    mov esp, ebp         ; Restore stack pointer
    pop ebp
    ret                  ; ESP is at the correct position
```

### Flag Register Preservation

The flags register (EFLAGS/RFLAGS) is generally considered volatile. [Inference: Most calling conventions do not require flag preservation, though specific flags like the direction flag may have requirements.]

**Example (saving flags):**

```nasm
procedure:
    pushfd               ; Save EFLAGS (32-bit)
    ; or pushfq           ; Save RFLAGS (64-bit)
    
    ; ... procedure code that modifies flags ...
    
    popfd                ; Restore EFLAGS
    ; or popfq            ; Restore RFLAGS
    ret
```

