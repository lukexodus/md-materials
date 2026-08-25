## Advanced Control Flow


### Computed Jumps

Jump to an address calculated at runtime:

```asm
section .data
    function_pointers dd func1, func2, func3, func4

section .text
call_by_index:
    ; EAX contains index (0-3)
    cmp eax, 3
    ja invalid_index
    
    call [function_pointers + eax*4]
    ret
    
invalid_index:
    ; Handle error
    ret
    
func1:
    ; Function 1 code
    ret
    
func2:
    ; Function 2 code
    ret
    
func3:
    ; Function 3 code
    ret
    
func4:
    ; Function 4 code
    ret
```

### Function Pointers

Call functions through pointers stored in memory:

```asm
section .data
    callback dd default_callback

section .text
set_callback:
    ; EAX contains function pointer
    mov [callback], eax
    ret
    
invoke_callback:
    call [callback]
    ret
    
default_callback:
    ; Default implementation
    ret
```

### Tail Call Optimization

Replace a call followed by return with a jump:

**Before:**

```asm
function_a:
    ; ... code ...
    call function_b
    ret
```

**After:**

```asm
function_a:
    ; ... code ...
    jmp function_b      ; Tail call - no stack growth
```

This is particularly important for recursive functions to avoid stack overflow.

**Example: Tail-Recursive Factorial:**

```asm
section .text
; factorial(n, accumulator)
; Returns n! * accumulator
factorial:
    ; Parameters: EAX = n, EBX = accumulator
    
    test eax, eax
    jz base_case
    
    ; accumulator *= n
    imul ebx, eax
    
    ; n--
    dec eax
    
    ; Tail call: factorial(n-1, accumulator)
    jmp factorial       ; No stack growth
    
base_case:
    mov eax, ebx        ; Return accumulator
    ret
```

### Exception Handling (Structured Exception Handling)

On Windows, x86 supports structured exception handling through special data structures:

```asm
section .data
    exception_handler dd handler_function

section .text
protected_code:
    ; Install exception handler
    push handler_function
    push dword [fs:0]       ; Previous handler
    mov [fs:0], esp         ; Install new handler
    
    ; Protected code that might fault
    mov eax, [0]            ; This might cause access violation
    
    ; Uninstall handler
    pop dword [fs:0]
    add esp, 4
    ret
    
handler_function:
    ; Exception handler
    ; Parameters passed by OS
    ret
```

[Inference] Exception handling in assembly is complex and platform-specific. Most assembly programmers avoid exceptions and use error codes instead.

### Coroutines and Context Switching

Save and restore execution context to implement cooperative multitasking:

```asm
section .bss
    context1: resb 32       ; Space for saved context
    context2: resb 32

section .text
save_context:
    ; Save registers to context structure in EAX
    mov [eax + 0], ebx
    mov [eax + 4], ecx
    mov [eax + 8], edx
    mov [eax + 12], esi
    mov [eax + 16], edi
    mov [eax + 20], ebp
    mov [eax + 24], esp
    ; Save return address
    mov ebx, [esp]
    mov [eax + 28], ebx
    ret
    
restore_context:
    ; Restore registers from context structure in EAX
    mov ebx, [eax + 0]
    mov ecx, [eax + 4]
    mov edx, [eax + 8]
    mov esi, [eax + 12]
    mov edi, [eax + 16]
    mov ebp, [eax + 20]
    mov esp, [eax + 24]
    ; Jump to saved return address
    jmp [eax + 28]
```

### Self-Modifying Code

Code that modifies its own instructions at runtime (rarely used in modern systems due to security and performance concerns):

```asm
section .text
modify_code:
    ; Change a JMP target
    mov byte [target_instruction + 1], new_offset
    
target_instruction:
    jmp original_target     ; This gets modified
    
original_target:
    ret
```

[Unverified] Self-modifying code may not work on systems with W^X (Write XOR Execute) security policies, which prevent memory from being both writable and executable.

