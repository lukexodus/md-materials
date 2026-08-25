## Basic Stack Operations


### PUSH Instruction

PUSH adds data to the stack, decrementing RSP and writing the value:

```nasm
push rax                    ; Decrement RSP by 8, store RAX at [RSP]
push rbx                    ; Decrement RSP by 8, store RBX at [RSP]
push qword [memory]         ; Decrement RSP by 8, store memory value
push 0x42                   ; Decrement RSP by 8, store immediate value
```

The PUSH operation performs these steps atomically:

1. RSP = RSP - operand_size
2. [RSP] = operand

Operand sizes:

- 64-bit mode: Can push 16-bit (word) or 64-bit (qword) values
- 32-bit mode: Can push 16-bit or 32-bit values
- 16-bit mode: Can push 16-bit values

In 64-bit mode, pushing 32-bit values is not directly supported; 32-bit immediates are sign-extended to 64 bits.

```nasm
push rax                    ; Valid: push 64-bit register
push ax                     ; Valid: push 16-bit register (RSP decrements by 2)
push eax                    ; Invalid in 64-bit mode
push 0x12345678             ; Valid: immediate sign-extended to 64 bits
```

### POP Instruction

POP removes data from the stack, reading the value and incrementing RSP:

```nasm
pop rax                     ; Load [RSP] into RAX, increment RSP by 8
pop rbx                     ; Load [RSP] into RBX, increment RSP by 8
pop qword [memory]          ; Load [RSP] into memory, increment RSP by 8
```

The POP operation performs these steps atomically:

1. operand = [RSP]
2. RSP = RSP + operand_size

The data remains in memory after popping; POP only moves the stack pointer, making the space available for reuse.

### Multiple PUSH/POP Operations

Saving and restoring multiple registers:

```nasm
; Function prologue - save registers
push rbx
push rcx
push rdx
push rsi
push rdi

; Function body
; ... use registers freely ...

; Function epilogue - restore registers (reverse order)
pop rdi
pop rsi
pop rdx
pop rcx
pop rbx
```

Registers must be popped in reverse order to restore them correctly due to the LIFO nature of the stack.

### PUSHA/POPA and PUSHAD/POPAD

These instructions push/pop multiple registers at once but are **not available in 64-bit mode**:

```nasm
; 16-bit mode: PUSHA/POPA
pusha                       ; Push AX, CX, DX, BX, SP, BP, SI, DI

; 32-bit mode: PUSHAD/POPAD
pushad                      ; Push EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI
```

In 64-bit mode, registers must be saved individually or using SIMD instructions for multiple registers.

### Stack Manipulation Without PUSH/POP

Direct RSP manipulation provides alternatives to PUSH/POP:

```nasm
; Equivalent to: push rax
sub rsp, 8
mov [rsp], rax

; Equivalent to: pop rax
mov rax, [rsp]
add rsp, 8

; Allocate 32 bytes on stack
sub rsp, 32

; Deallocate 32 bytes from stack
add rsp, 32
```

Direct manipulation is useful for:

- Allocating space for multiple local variables at once
- Deallocating without loading values
- Accessing stack data without modifying RSP

