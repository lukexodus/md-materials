## Interrupt Descriptor Table (IDT)


The Interrupt Descriptor Table is the central data structure for interrupt handling. It contains up to 256 entries (vectors 0-255), where each entry is a gate descriptor that specifies how to handle a particular interrupt or exception.

**IDT Structure**: Each IDT entry (8 bytes in 32-bit mode, 16 bytes in 64-bit mode) contains:

- Offset: Address of the ISR
- Segment selector: Code segment where the handler resides
- Gate type: Interrupt gate, trap gate, or task gate
- Descriptor Privilege Level (DPL): Minimum privilege required to invoke this interrupt via INT instruction
- Present bit: Indicates if the descriptor is valid

**IDTR Register**: The CPU uses the IDTR (Interrupt Descriptor Table Register) to locate the IDT. This 48-bit register (80-bit in 64-bit mode) contains:

- Base address: Linear address of the IDT
- Limit: Size of the IDT in bytes

Loading the IDTR:

```assembly
; Define IDT structure
idt_descriptor:
    dw idt_end - idt_start - 1  ; Limit (size - 1)
    dd idt_start                 ; Base address (32-bit)

; Load IDT
lidt [idt_descriptor]
```

**Gate Types**:

- **Interrupt Gate**: Automatically clears the IF (Interrupt Flag) upon entry, disabling maskable interrupts during handler execution. This prevents interrupt nesting for the same or lower priority interrupts.
- **Trap Gate**: Does not affect the IF flag, allowing interrupts to remain enabled during handler execution.
- **Task Gate**: Causes a task switch to a dedicated TSS (Task State Segment) for interrupt handling, rarely used in modern systems.

