## Interrupt Service Routines (ISR)


An Interrupt Service Routine is the code that handles a specific interrupt or exception. ISRs must preserve system state, handle the event efficiently, and return control properly.

### ISR Execution Flow

When an interrupt occurs:

1. **Processor saves state**: Automatically pushes EFLAGS, CS, and EIP (or their 64-bit equivalents) onto the stack
2. **Error code**: Some exceptions push an additional error code
3. **IF flag**: Cleared for interrupt gates (not trap gates)
4. **Control transfer**: Processor loads CS:EIP from the IDT gate descriptor
5. **ISR executes**: Handler processes the interrupt
6. **Return**: IRET/IRETD/IRETQ instruction restores saved state and returns

### Stack Frame After Interrupt

For interrupts without error codes:

```
[SS]          (only if privilege level change)
[ESP]         (only if privilege level change)
EFLAGS
CS
EIP          <- ESP points here when ISR begins
```

For interrupts with error codes (e.g., page fault, general protection fault):

```
[SS]          (only if privilege level change)
[ESP]         (only if privilege level change)
EFLAGS
CS
EIP
Error Code   <- ESP points here when ISR begins
```

### Basic ISR Structure

```assembly
; Simple ISR for hardware interrupt (no error code)
timer_isr:
    ; Save all registers that will be modified
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    push ds
    push es
    push fs
    push gs
    
    ; Load kernel data segment
    mov ax, 0x10        ; Kernel data segment selector
    mov ds, ax
    mov es, ax
    
    ; Perform interrupt-specific processing
    ; ... handler code here ...
    
    ; Send End-Of-Interrupt (EOI) signal to PIC
    mov al, 0x20        ; EOI command
    out 0x20, al        ; Send to master PIC
    
    ; Restore all registers
    pop gs
    pop fs
    pop es
    pop ds
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ; Return from interrupt (restores EFLAGS, CS, EIP)
    iret
```

### ISR for Exceptions with Error Code

```assembly
; Page fault handler (vector 14) - has error code
page_fault_isr:
    ; Error code is already on stack
    ; Save registers
    push eax
    push ebx
    push ecx
    push edx
    
    ; Get error code (skip saved registers)
    mov eax, [esp + 16]  ; Error code is 4 DWORDs above current ESP
    
    ; Get faulting address from CR2
    mov ebx, cr2
    
    ; Decode error code
    ; Bit 0: 0=not present, 1=protection violation
    ; Bit 1: 0=read, 1=write
    ; Bit 2: 0=supervisor, 1=user mode
    ; Bit 3: 0=normal, 1=reserved bit violation
    ; Bit 4: 0=data, 1=instruction fetch
    
    ; ... handle page fault ...
    
    ; Restore registers
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ; Remove error code from stack
    add esp, 4
    
    ; Return from interrupt
    iret
```

### Interrupt Acknowledgment

Hardware interrupts require acknowledgment to the interrupt controller before new interrupts of the same or lower priority can be serviced.

**8259 PIC (Legacy Systems)**

```assembly
; End-Of-Interrupt for IRQ 0-7 (master PIC)
mov al, 0x20        ; EOI command
out 0x20, al        ; Send to master PIC port

; End-Of-Interrupt for IRQ 8-15 (slave PIC)
mov al, 0x20        ; EOI command
out 0xA0, al        ; Send to slave PIC port
out 0x20, al        ; Also send to master PIC port
```

**APIC (Modern Systems)**

```assembly
; End-Of-Interrupt for APIC
mov dword [0xFEE000B0], 0  ; Write to EOI register
; Address 0xFEE000B0 is the memory-mapped APIC EOI register
```

### ISR Design Considerations

**Minimize Execution Time**

ISRs should execute as quickly as possible to minimize system latency. Long operations should be deferred to separate tasks or bottom-half handlers.

```assembly
; Good: Quick ISR that defers work
keyboard_isr:
    push eax
    in al, 0x60         ; Read scan code from keyboard
    mov [key_buffer], al ; Store for later processing
    mov byte [key_pending], 1  ; Set flag for background task
    mov al, 0x20
    out 0x20, al        ; Send EOI
    pop eax
    iret

; Bad: ISR that does too much work (avoid this)
keyboard_isr_bad:
    push eax
    push ebx
    in al, 0x60
    ; Don't do complex processing here
    call translate_scancode
    call update_keyboard_buffer
    call process_keyboard_shortcuts
    call update_screen
    ; ... too much work in ISR context
    mov al, 0x20
    out 0x20, al
    pop ebx
    pop eax
    iret
```

**Reentrancy**

ISRs may be interrupted by higher-priority interrupts unless designed otherwise. Code must be reentrant or use appropriate locking mechanisms.

**Register Preservation**

All registers modified by the ISR must be saved and restored, as the interrupted code expects its register state to remain intact.

**Atomic Operations**

Use atomic instructions or disable interrupts when accessing shared data structures.

```assembly
; Protecting critical section in ISR
cli                     ; Disable interrupts
; ... modify shared data structure ...
sti                     ; Re-enable interrupts
```

### Exception-Specific ISRs

**Divide Error Handler**

```assembly
divide_error_isr:
    push eax
    push ebx
    
    ; Log or display error
    ; Typically terminates the offending process
    
    ; Cannot recover - need to abort task
    call terminate_current_task
    
    pop ebx
    pop eax
    iret
```

**General Protection Fault Handler**

```assembly
gpf_isr:
    ; Error code on stack indicates which segment caused fault
    push eax
    mov eax, [esp + 8]   ; Get error code
    
    ; Bit 0: 0=external event, 1=IDT/GDT/LDT reference
    ; Bits 1-2: Descriptor table (00=GDT, 01=IDT, 10=LDT, 11=IDT)
    ; Bits 3-15: Segment selector index
    
    ; ... analyze and handle fault ...
    
    pop eax
    add esp, 4           ; Remove error code
    iret
```

**Page Fault Handler**

```assembly
page_fault_isr:
    push eax
    push ebx
    push ecx
    
    ; Get faulting address
    mov eax, cr2         ; CR2 contains faulting linear address
    
    ; Get error code
    mov ebx, [esp + 16]  ; Error code position
    
    ; Check error code bits
    test ebx, 1          ; Test present bit
    jz page_not_present
    
    ; Handle protection violation
    jmp handle_protection_violation
    
page_not_present:
    ; Handle page not present (demand paging, swap, etc.)
    call allocate_physical_page
    call map_page
    
    pop ecx
    pop ebx
    pop eax
    add esp, 4           ; Remove error code
    iret
    
handle_protection_violation:
    ; Handle write to read-only page, etc.
    call handle_protection_error
    pop ecx
    pop ebx
    pop eax
    add esp, 4
    iret
```

### Interrupt Vector Assignments

**Exceptions (Vectors 0-31)**

- 0: Divide Error
- 1: Debug Exception
- 2: NMI Interrupt
- 3: Breakpoint
- 4: Overflow
- 5: BOUND Range Exceeded
- 6: Invalid Opcode
- 7: Device Not Available
- 8: Double Fault (error code: always 0)
- 9: Coprocessor Segment Overrun (legacy)
- 10: Invalid TSS (error code)
- 11: Segment Not Present (error code)
- 12: Stack-Segment Fault (error code)
- 13: General Protection Fault (error code)
- 14: Page Fault (error code)
- 15: Reserved
- 16: x87 FPU Error
- 17: Alignment Check (error code: always 0)
- 18: Machine Check
- 19: SIMD Floating-Point Exception
- 20: Virtualization Exception
- 21-31: Reserved by Intel

**Hardware Interrupts (Vectors 32-255)**

In typical PC configurations with 8259 PIC:

- 32-39: IRQ 0-7 (Master PIC)
- 40-47: IRQ 8-15 (Slave PIC)
- 48-255: Available for software use (system calls, custom handlers)

### 64-bit Mode Considerations

In 64-bit long mode:

- Gate descriptors are 16 bytes
- Use IRETQ instead of IRET
- RSP used instead of ESP
- Full 64-bit addresses supported
- Interrupt Stack Table (IST) mechanism provides separate stacks for critical interrupts

```assembly
; 64-bit ISR structure
timer_isr_64:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    
    ; Handler code
    ; ...
    
    ; Send EOI
    mov qword [0xFEE000B0], 0
    
    ; Restore registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    
    iretq
```

**Key Points:**

- Interrupt handling temporarily suspends normal execution to respond to hardware events, software requests, or exceptional conditions
- The IDT maps 256 possible interrupt vectors to their handler routines through gate descriptors
- Hardware interrupts are asynchronous and triggered by external devices, while software interrupts are synchronous and instruction-invoked
- Exceptions are processor-detected error conditions, categorized as faults (recoverable), traps (debugging), or aborts (critical errors)
- ISRs must preserve processor state, execute quickly, acknowledge interrupts to the controller, and use IRET to return properly
- Different gate types (interrupt gates vs trap gates) control whether interrupts remain enabled during handler execution
- Error codes are automatically pushed for certain exceptions to provide diagnostic information about the fault
- The x86 interrupt mechanism provides privilege level checking through DPL fields to enforce security boundaries

---

