## Register Addressing


Register addressing specifies operands that reside in CPU registers. Both source and destination operands can use register addressing, allowing operations entirely within the CPU without memory access.

**Syntax and Register Names** identify specific registers as instruction operands:

```nasm
mov rax, rbx         ; Copy RBX to RAX
add rcx, rdx         ; Add RDX to RCX, store result in RCX
sub r8, r9           ; Subtract R9 from R8
xor rsi, rdi         ; Exclusive OR of RSI and RDI
imul rax, rbx        ; Signed multiply RAX by RBX
```

x86-64 provides sixteen 64-bit general-purpose registers: RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP, and R8 through R15. Each register has 32-bit (EAX, EBX, etc.), 16-bit (AX, BX, etc.), and 8-bit (AL, AH, BL, BH, etc.) subregister variants. Operations on smaller subregisters affect only those portions, though 32-bit operations zero-extend to 64 bits in x86-64.

**Register Subsets** allow accessing portions of 64-bit registers:

```nasm
mov rax, 0x123456789ABCDEF0    ; RAX = full 64 bits
mov eax, 0x12345678            ; EAX = lower 32 bits (zeros upper 32)
mov ax, 0x1234                 ; AX = lower 16 bits (preserves bits 16-63)
mov al, 0x12                   ; AL = lower 8 bits (preserves bits 8-63)
mov ah, 0x34                   ; AH = bits 8-15 (preserves other bits)
```

The interaction between subregisters and their parent registers follows specific rules. Writing to a 32-bit subregister (EAX) zeros the upper 32 bits of the 64-bit register (RAX). Writing to 16-bit or 8-bit subregisters preserves the upper bits unchanged. This behavior affects how programmers manipulate register contents.

**Performance Advantages** make register addressing the fastest addressing mode. Register access completes in less than one nanosecond with no memory bus activity required. Operations using only register operands execute in one or two cycles for most arithmetic and logical instructions. The CPU can execute multiple register-based instructions simultaneously through superscalar execution and out-of-order processing. Register renaming in modern processors eliminates false dependencies between instructions using the same architectural registers.

**Register Allocation** challenges arise because programs have limited registers. Compilers and assembly programmers must decide which values to keep in registers versus spilling to memory. Frequently accessed variables benefit most from register allocation. Loop counters, array indices, and intermediate calculation results typically reside in registers during critical code sections. When registers are exhausted, less frequently used values move to stack memory, introducing performance penalties.

**Calling Convention Constraints** specify which registers serve specific purposes. On x86-64 System V ABI (Linux, macOS), RDI, RSI, RDX, RCX, R8, and R9 pass the first six integer arguments. RAX returns integer values. RBX, RBP, and R12-R15 are callee-saved (functions must preserve them). Other registers are caller-saved (functions can modify them freely). Windows x64 calling convention uses RCX, RDX, R8, R9 for the first four parameters with different preservation rules.

**Special-Purpose Registers** have dedicated functions. RSP points to the top of the stack and instructions like PUSH, POP, CALL, and RET automatically adjust it. RBP traditionally serves as a frame pointer for accessing local variables and parameters. RIP (instruction pointer) cannot be used as a general operand but supports RIP-relative addressing. The FLAGS register stores condition codes but isn't directly accessed as a general-purpose register.

