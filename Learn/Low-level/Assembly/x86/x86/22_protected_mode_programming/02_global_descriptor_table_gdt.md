## Global Descriptor Table (GDT)


The GDT is a system-wide table containing segment descriptors that define memory segments accessible to all tasks. Every protected mode system must have exactly one GDT.

### GDT Structure and Location

The GDT is stored in memory as an array of 8-byte segment descriptors. Its location and size are specified by the **GDTR (GDT Register)**, a 48-bit register containing:

- **Base address (32 bits)**: Linear address of the GDT
- **Limit (16 bits)**: Size of the GDT in bytes minus 1 (maximum 65535 bytes = 8191 descriptors)

### Loading the GDTR

```nasm
lgdt [gdtr_data]    ; Load GDT register

gdtr_data:
    dw gdt_end - gdt_start - 1    ; Limit (size - 1)
    dd gdt_start                   ; Base address
```

### GDT Requirements

- **Null descriptor**: The first entry (index 0) must be a null descriptor (all zeros). Any selector with index 0 causes a general protection fault when used (except in CS during task switches).
- **Minimum descriptors**: A functional system typically needs at minimum: null descriptor, code segment descriptor, data segment descriptor.
- **Alignment**: While not strictly required by the processor, the GDT is typically aligned on an 8-byte boundary for performance.

### GDT Example Structure

```nasm
gdt_start:
    ; Null descriptor (required)
    dq 0x0000000000000000

    ; Code segment descriptor (base=0, limit=0xFFFFF, 4KB granularity)
    dw 0xFFFF           ; Limit 0-15
    dw 0x0000           ; Base 0-15
    db 0x00             ; Base 16-23
    db 10011010b        ; Access byte: present, ring 0, code, executable, readable
    db 11001111b        ; Flags and limit 16-19: 4KB granularity, 32-bit
    db 0x00             ; Base 24-31

    ; Data segment descriptor (base=0, limit=0xFFFFF, 4KB granularity)
    dw 0xFFFF           ; Limit 0-15
    dw 0x0000           ; Base 0-15
    db 0x00             ; Base 16-23
    db 10010010b        ; Access byte: present, ring 0, data, writable
    db 11001111b        ; Flags and limit 16-19: 4KB granularity, 32-bit
    db 0x00             ; Base 24-31

gdt_end:
```

