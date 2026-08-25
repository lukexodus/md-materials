## Interrupt Handling Mechanism


When an interrupt occurs, the processor executes the following sequence:

**Interrupt Recognition**: The CPU checks for pending interrupts between instruction boundaries. For maskable interrupts, the IF flag must be set. For NMIs and exceptions, this check is bypassed.

**Privilege Level Transition**: If the interrupt handler runs at a higher privilege level than the interrupted code:

- Save SS and ESP (stack registers) of the interrupted context
- Load new SS and ESP from the TSS corresponding to the target privilege level
- Push the saved SS and ESP onto the new stack

**State Preservation**: The processor automatically pushes the following onto the stack:

```
[Higher addresses]
SS          (if privilege level changed)
ESP         (if privilege level changed)
EFLAGS
CS
EIP
Error Code (for certain exceptions only)
[Lower addresses] <- New ESP
```

In 64-bit mode (long mode), the saved values are 64-bit (RIP, RSP) and the layout differs slightly.

**Vector Lookup**: The processor multiplies the interrupt vector number by the gate descriptor size and adds it to the IDT base address to locate the appropriate gate descriptor.

**Handler Invocation**:

- Load CS:EIP (or CS:RIP) from the gate descriptor
- If it's an interrupt gate, clear IF flag
- Begin execution at the handler address

**Returning from Interrupt**: The handler concludes with IRET (Interrupt Return) instruction:

```assembly
interrupt_handler:
    ; Save registers
    push eax
    push ebx
    push ecx
    push edx
    
    ; Handler code
    ; ... handle the interrupt ...
    
    ; Restore registers
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ; Return from interrupt
    iret
```

IRET pops EIP, CS, and EFLAGS from the stack. If a privilege level change occurred, it also pops ESP and SS.

