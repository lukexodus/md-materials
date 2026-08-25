## Interrupt Descriptor Table (IDT)


The Interrupt Descriptor Table is a system table that contains descriptors for all interrupt and exception handlers. It maps interrupt/exception vectors to their corresponding service routines.

### IDT Structure

The IDT is an array of 256 descriptors (vectors 0-255), where each descriptor is 8 bytes in 32-bit mode or 16 bytes in 64-bit mode. The processor uses the IDTR (Interrupt Descriptor Table Register) to locate the IDT in memory.

**IDTR Register**

The IDTR is a 48-bit register (80-bit in 64-bit mode) containing:

- Base address: 32-bit linear address (64-bit in long mode) of the IDT
- Limit: 16-bit value specifying the size of the IDT in bytes (limit = size - 1)

```assembly
; Loading the IDT
lidt [idt_descriptor]

; Structure of IDT descriptor
idt_descriptor:
    dw idt_end - idt_start - 1    ; Limit (size - 1)
    dd idt_start                   ; Base address

; Storing the current IDTR
sidt [idt_save_area]
```

### IDT Gate Descriptors (32-bit Protected Mode)

Each entry in the IDT is a gate descriptor that defines how to invoke the interrupt handler. There are three types of gate descriptors:

**Interrupt Gate Descriptor**

Interrupt gates automatically clear the IF flag when transferring control to the handler, preventing nested interrupts.

```
Bits 63-48: Offset 31:16 (high word of handler address)
Bits 47-40: P|DPL|0|Type (Present, Privilege Level, Gate Type = 0xE)
Bits 39-32: Reserved (must be 0)
Bits 31-16: Segment Selector (code segment of handler)
Bits 15-00: Offset 15:0 (low word of handler address)
```

**Trap Gate Descriptor**

Trap gates do not modify the IF flag, allowing interrupts to remain enabled during handler execution.

```
Same structure as Interrupt Gate, but Type = 0xF
```

**Task Gate Descriptor**

Task gates trigger a hardware task switch when invoked. They contain a TSS selector instead of a code address.

```assembly
; Example: Setting up an interrupt gate (vector 0x21)
; Handler at handler_code:keyboard_isr
; Code segment selector = 0x08

idt_entry_33:
    dw keyboard_isr & 0xFFFF       ; Offset low 16 bits
    dw 0x0008                       ; Kernel code segment selector
    db 0                            ; Reserved (must be 0)
    db 0x8E                         ; P=1, DPL=0, Type=0xE (interrupt gate)
    dw (keyboard_isr >> 16) & 0xFFFF ; Offset high 16 bits
```

### IDT Gate Descriptors (64-bit Long Mode)

In 64-bit mode, gate descriptors are 16 bytes to accommodate 64-bit addresses:

```
Bits 127-96: Reserved (must be 0)
Bits 95-64:  Offset 63:32 (upper 32 bits of handler address)
Bits 63-48:  Offset 31:16
Bits 47-40:  P|DPL|0|Type
Bits 39-32:  IST (Interrupt Stack Table index)
Bits 31-16:  Segment Selector
Bits 15-0:   Offset 15:0
```

### Gate Type Values

- 0x5: 32-bit Task Gate
- 0xE: 32-bit Interrupt Gate (IF cleared)
- 0xF: 32-bit Trap Gate (IF unchanged)
- In 64-bit mode: 0xE (Interrupt Gate), 0xF (Trap Gate)

### Descriptor Privilege Level (DPL)

The DPL field (bits 45-46) specifies the minimum privilege level required to invoke the interrupt through software (INT instruction). Hardware interrupts and exceptions ignore this field.

- DPL=0: Only kernel code can invoke via INT
- DPL=3: User-mode code can invoke via INT

**Example**: System call gates often use DPL=3 to allow user programs to request OS services.

