## Context Switching


Context switching involves saving the current thread's state and restoring another thread's state. Understanding this process is crucial for performance optimization.

### Thread Context Structure

```nasm
; Thread context (x86-64)
struc ThreadContext
    ; General purpose registers
    .rax:       resq 1
    .rbx:       resq 1
    .rcx:       resq 1
    .rdx:       resq 1
    .rsi:       resq 1
    .rdi:       resq 1
    .rbp:       resq 1
    .rsp:       resq 1
    .r8:        resq 1
    .r9:        resq 1
    .r10:       resq 1
    .r11:       resq 1
    .r12:       resq 1
    .r13:       resq 1
    .r14:       resq 1
    .r15:       resq 1
    
    ; Instruction pointer and flags
    .rip:       resq 1
    .rflags:    resq 1
    
    ; Segment registers
    .cs:        resw 1
    .ss:        resw 1
    .ds:        resw 1
    .es:        resw 1
    .fs:        resw 1
    .gs:        resw 1
    
    ; FPU/SSE state pointer
    .fxsave_area: resq 1
    
    ; Thread state
    .state:     resd 1          ; Running, ready, blocked, etc.
    .priority:  resd 1
    .quantum:   resd 1          ; Time slice remaining
    
    ; Scheduling links
    .next:      resq 1
    .prev:      resq 1
endstruc
```

### Manual Context Switch

```nasm
; Switch from current thread to next thread
context_switch:
    ; Input:
    ;   RDI = pointer to current thread context
    ;   RSI = pointer to next thread context
    
    push rbp
    mov rbp, rsp
    
    ; Save current thread state
    mov [rdi + ThreadContext.rax], rax
    mov [rdi + ThreadContext.rbx], rbx
    mov [rdi + ThreadContext.rcx], rcx
    mov [rdi + ThreadContext.rdx], rdx
    mov [rdi + ThreadContext.rsi], rsi
    ; RSI already used as parameter
    
    mov [rdi + ThreadContext.rbp], rbp
    mov [rdi + ThreadContext.rsp], rsp
    
    mov [rdi + ThreadContext.r8], r8
    mov [rdi + ThreadContext.r9], r9
    mov [rdi + ThreadContext.r10], r10
    mov [rdi + ThreadContext.r11], r11
    mov [rdi + ThreadContext.r12], r12
    mov [rdi + ThreadContext.r13], r13
    mov [rdi + ThreadContext.r14], r14
    mov [rdi + ThreadContext.r15], r15
    
    ; Save flags
    pushfq
    pop qword [rdi + ThreadContext.rflags]
    
    ; Save instruction pointer (return address)
    mov rax, [rbp + 8]
    mov [rdi + ThreadContext.rip], rax
    
    ; Save FPU/SSE state
    mov rax, [rdi + ThreadContext.fxsave_area]
    fxsave [rax]
    
    ; Switch to next thread
    ; Restore FPU/SSE state
    mov rax, [rsi + ThreadContext.fxsave_area]
    fxrstor [rax]
    
    ; Restore general registers
    mov rax, [rsi + ThreadContext.rax]
    mov rbx, [rsi + ThreadContext.rbx]
    mov rcx, [rsi + ThreadContext.rcx]
    mov rdx, [rsi + ThreadContext.rdx]
    ; RSI restored later
    
    mov rbp, [rsi + ThreadContext.rbp]
    mov rsp, [rsi + ThreadContext.rsp]
    
    mov r8, [rsi + ThreadContext.r8]
    mov r9, [rsi + ThreadContext.r9]
    mov r10, [rsi + ThreadContext.r10]
    mov r11, [rsi + ThreadContext.r11]
    mov r12, [rsi + ThreadContext.r12]
    mov r13, [rsi + ThreadContext.r13]
    mov r14, [rsi + ThreadContext.r14]
    mov r15, [rsi + ThreadContext.r15]
    
    ; Restore flags
    push qword [rsi + ThreadContext.rflags]
    popfq
    
    ; Restore instruction pointer and RSI
    mov rdi, [rsi + ThreadContext.rip]
    mov rsi, [rsi + ThreadContext.rsi]
    
    ; Jump to restored instruction pointer
    jmp rdi
```

### Lightweight Context Switch (Fiber/Coroutine)

```nasm
; Minimal context switch for cooperative multitasking
; Only saves callee-saved registers

struc FiberContext
    .rbx:       resq 1
    .rbp:       resq 1
    .r12:       resq 1
    .r13:       resq 1
    .r14:       resq 1
    .r15:       resq 1
    .rsp:       resq 1
    .rip:       resq 1
endstruc

; Switch fiber context
fiber_switch:
    ; Input:
    ;   RDI = current fiber context
    ;   RSI = next fiber context
    
    ; Save callee-saved registers only
    mov [rdi + FiberContext.rbx], rbx
    mov [rdi + FiberContext.rbp], rbp
    mov [rdi + FiberContext.r12], r12
    mov [rdi + FiberContext.r13], r13
    mov [rdi + FiberContext.r14], r14
    mov [rdi + FiberContext.r15], r15
    mov [rdi + FiberContext.rsp], rsp
    
    ; Save return address
    mov rax, [rsp]
    mov [rdi + FiberContext.rip], rax
    
    ; Restore next fiber
    mov rbx, [rsi + FiberContext.rbx]
    mov rbp, [rsi + FiberContext.rbp]
    mov r12, [rsi + FiberContext.r12]
    mov r13, [rsi + FiberContext.r13]
    mov r14, [rsi + FiberContext.r14]
    mov r15, [rsi + FiberContext.r15]
    mov rsp, [rsi + FiberContext.rsp]
    
    ; Jump to saved instruction pointer
    jmp [rsi + FiberContext.rip]
```

### Context Switch Performance Measurement

```nasm
; Measure context switch overhead
measure_context_switch_cost:
    ; Create two fiber contexts
    lea rdi, [fiber1]
    lea rsi, [fiber2]
    
    ; Initialize fiber2 to switch back to fiber1
    mov qword [fiber2 + FiberContext.rip], .return_point
    
    ; Measure round-trip time
    rdtscp
    mov [start_cycles], eax
    mov [start_cycles + 4], edx
    
    ; Perform context switches
    mov ecx, 10000
.switch_loop:
    call fiber_switch
.return_point:
    loop .switch_loop
    
    rdtscp
    sub eax, [start_cycles]
    sbb edx, [start_cycles + 4]
    
    ; Calculate average
    mov ebx, 20000              ; 2 switches per iteration
    xor edx, edx
    div ebx
    ; EAX = average cycles per context switch
    
    ret

section .bss
align 64
    fiber1: resb FiberContext_size
    fiber2: resb FiberContext_size
```

### Minimizing Context Switch Overhead

**Reducing FPU/SSE State Saves:**

```nasm
; Lazy FPU context switching
; Only save/restore FPU state if thread uses it

section .data
    fpu_owner: dq 0             ; Current FPU owner thread ID

; Trap #NM (Device Not Available) exception
fpu_fault_handler:
    push rax
    push rbx
    
    ; Get current thread
    call get_current_thread
    mov rbx, rax
    
    ; Check if FPU state needs saving
    mov rax, [fpu_owner]
    test rax, rax
    jz .restore_only
    
    cmp rax, rbx
    je .already_owner
    
    ; Save previous owner's FPU state
    push rbx
    mov rdi, rax
    call save_fpu_state
    pop rbx
    
.restore_only:
    ; Restore current thread's FPU state
    mov rdi, rbx
    call restore_fpu_state
    
    ; Update FPU owner
    mov [fpu_owner], rbx
    
.already_owner:
    ; Clear TS flag in CR0 to re-enable FPU
    mov rax, cr0
    and rax, ~8                 ; Clear TS bit
    mov cr0, rax
    
    pop rbx
    pop rax
    iretq
```

