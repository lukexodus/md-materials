## Local Descriptor Table (LDT)


The LDT is a task-specific descriptor table that provides additional segment descriptors private to a particular task. Unlike the GDT, LDTs are optional, and systems can have multiple LDTs (one per task that needs one).

### LDT vs GDT

**GDT characteristics:**

- System-wide, single instance
- Contains global segments accessible to all tasks
- Typically contains system code/data, task state segments
- Always present in protected mode

**LDT characteristics:**

- Task-specific, multiple instances possible
- Contains private segments for individual tasks
- Provides additional isolation between tasks
- Optional, not all tasks need an LDT

### LDT Location and Access

The LDT itself is defined by a **segment descriptor in the GDT** (LDT descriptor type = 0x02). The **LDTR (LDT Register)** is a 16-bit register that holds a selector pointing to the LDT's descriptor in the GDT.

```nasm
lldt ax             ; Load LDT register with selector in AX
sldt ax             ; Store LDT selector to AX
```

### LDT Descriptor in GDT

```nasm
; LDT descriptor in GDT
dw ldt_limit        ; Limit of LDT
dw ldt_base_low     ; Base address bits 0-15
db ldt_base_mid     ; Base address bits 16-23
db 10000010b        ; Access: present, DPL=0, system, LDT descriptor
db 00000000b        ; Flags: byte granularity
db ldt_base_high    ; Base address bits 24-31
```

### Using LDT Selectors

To access a segment defined in an LDT, set the TI bit (bit 2) of the selector to 1:

```nasm
mov ax, 0x0C        ; Index 1, TI=1 (LDT), RPL=0
mov ds, ax          ; Load LDT-based segment into DS
```

