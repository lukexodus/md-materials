## Prologue and Epilogue Sequences


The prologue and epilogue are standardized sequences of instructions at the beginning and end of procedures that manage the stack frame and register preservation.

### Standard Prologue (32-bit)

The prologue sets up the stack frame for the procedure.

```nasm
procedure:
    push ebp             ; Save old base pointer
    mov ebp, esp         ; Set new base pointer to current stack top
    sub esp, N           ; Allocate N bytes for local variables (optional)
    push ebx             ; Save callee-saved registers if used
    push esi
    push edi
```

**Key Points:**

- Saves the old base pointer
- Establishes a new base pointer for the current frame
- Allocates space for local variables
- Preserves callee-saved registers

**Example:**

```nasm
calculate:
    push ebp
    mov ebp, esp
    sub esp, 8           ; Allocate 8 bytes for local variables
    push ebx             ; Save EBX
    
    ; Local variables accessible via EBP:
    ; [ebp-4] = first local variable
    ; [ebp-8] = second local variable
    ; Parameters accessible via EBP:
    ; [ebp+8] = first parameter
    ; [ebp+12] = second parameter
```

### Standard Epilogue (32-bit)

The epilogue tears down the stack frame and restores saved registers.

```nasm
    pop edi              ; Restore callee-saved registers (reverse order)
    pop esi
    pop ebx
    mov esp, ebp         ; Deallocate local variables
    pop ebp              ; Restore old base pointer
    ret                  ; Return to caller
```

Alternatively, the `LEAVE` instruction combines `mov esp, ebp` and `pop ebp`:

```nasm
    pop edi
    pop esi
    pop ebx
    leave                ; Equivalent to: mov esp, ebp; pop ebp
    ret
```

**Example:**

```nasm
calculate:
    push ebp
    mov ebp, esp
    sub esp, 8
    push ebx
    
    ; ... function code ...
    
    pop ebx              ; Restore in reverse order
    leave                ; Clean up stack frame
    ret
```

### x64 Prologue (Windows)

The 64-bit Windows prologue follows stricter requirements for stack alignment and exception handling.

```nasm
procedure:
    push rbp             ; Save old base pointer
    sub rsp, N           ; Allocate stack space (N must make RSP 16-byte aligned)
    lea rbp, [rsp+K]     ; Set base pointer (K is offset within allocated space)
    ; Save non-volatile registers if used
    mov [rbp+offset], rbx
    mov [rbp+offset], rsi
```

The stack must be 16-byte aligned before any `CALL` instruction. The prologue must maintain this alignment.

**Example:**

```nasm
my_function:
    push rbp
    sub rsp, 48          ; Allocate 48 bytes (maintains 16-byte alignment)
    lea rbp, [rsp+48]
    
    ; Save non-volatile registers
    mov [rbp-8], rbx
    mov [rbp-16], rsi
    
    ; Local variables at [rbp-24], [rbp-32], etc.
```

### x64 Epilogue (Windows)

```nasm
    ; Restore non-volatile registers
    mov rbx, [rbp-8]
    mov rsi, [rbp-16]
    
    lea rsp, [rbp]       ; Restore stack pointer
    pop rbp
    ret
```

### Minimal Prologue/Epilogue

For leaf functions (functions that don't call other functions and don't need local variables), a minimal or no prologue/epilogue may be used.

**Example:**

```nasm
; Leaf function that just adds two parameters
add_two:
    mov eax, edi         ; First parameter (System V x64)
    add eax, esi         ; Second parameter
    ret                  ; No prologue or epilogue needed
```

### Stack Frame Layout

After the prologue executes, a typical stack frame looks like this (32-bit, growing downward):

```
Higher addresses
+------------------+
| Parameter N      |  [ebp+4N+8]
+------------------+
| Parameter 2      |  [ebp+12]
+------------------+
| Parameter 1      |  [ebp+8]
+------------------+
| Return Address   |  [ebp+4]
+------------------+
| Saved EBP        |  [ebp]      <-- EBP points here
+------------------+
| Local Variable 1 |  [ebp-4]
+------------------+
| Local Variable 2 |  [ebp-8]
+------------------+
| Saved EBX        |  [ebp-12]
+------------------+
| Saved ESI        |  [ebp-16]
+------------------+
| Saved EDI        |  [ebp-20]   <-- ESP points here
+------------------+
Lower addresses
```

