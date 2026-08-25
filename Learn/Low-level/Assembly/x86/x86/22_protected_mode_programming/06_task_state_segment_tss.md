## Task State Segment (TSS)


The Task State Segment is a data structure used by the processor to store and restore the complete state of a task during task switches or privilege level transitions. While hardware task switching via TSS is largely deprecated in modern operating systems, the TSS remains essential for handling privilege level changes and storing stack pointers for different privilege levels.

### TSS Structure in 32-bit Protected Mode

The 32-bit TSS is a 104-byte minimum structure (or larger if I/O permission bitmap is included) with the following layout:

```assembly
; 32-bit TSS structure
struc TSS32
    .prev_task_link  resw 1     ; Offset 0x00: Previous Task Link (selector)
    .reserved0       resw 1     ; Reserved
    .esp0            resd 1     ; Offset 0x04: ESP for privilege level 0
    .ss0             resw 1     ; Offset 0x08: SS for privilege level 0
    .reserved1       resw 1     ; Reserved
    .esp1            resd 1     ; Offset 0x0C: ESP for privilege level 1
    .ss1             resw 1     ; Offset 0x10: SS for privilege level 1
    .reserved2       resw 1     ; Reserved
    .esp2            resd 1     ; Offset 0x14: ESP for privilege level 2
    .ss2             resw 1     ; Offset 0x18: SS for privilege level 2
    .reserved3       resw 1     ; Reserved
    .cr3             resd 1     ; Offset 0x1C: CR3 (page directory base)
    .eip             resd 1     ; Offset 0x20: EIP
    .eflags          resd 1     ; Offset 0x24: EFLAGS
    .eax             resd 1     ; Offset 0x28: EAX
    .ecx             resd 1     ; Offset 0x2C: ECX
    .edx             resd 1     ; Offset 0x30: EDX
    .ebx             resd 1     ; Offset 0x34: EBX
    .esp             resd 1     ; Offset 0x38: ESP
    .ebp             resd 1     ; Offset 0x3C: EBP
    .esi             resd 1     ; Offset 0x40: ESI
    .edi             resd 1     ; Offset 0x44: EDI
    .es              resw 1     ; Offset 0x48: ES selector
    .reserved4       resw 1     ; Reserved
    .cs              resw 1     ; Offset 0x4C: CS selector
    .reserved5       resw 1     ; Reserved
    .ss              resw 1     ; Offset 0x50: SS selector
    .reserved6       resw 1     ; Reserved
    .ds              resw 1     ; Offset 0x54: DS selector
    .reserved7       resw 1     ; Reserved
    .fs              resw 1     ; Offset 0x58: FS selector
    .reserved8       resw 1     ; Reserved
    .gs              resw 1     ; Offset 0x5C: GS selector
    .reserved9       resw 1     ; Reserved
    .ldt             resw 1     ; Offset 0x60: LDT selector
    .reserved10      resw 1     ; Reserved
    .trap_bit        resw 1     ; Offset 0x64: Debug trap flag (bit 0)
    .iomap_base      resw 1     ; Offset 0x66: I/O Map Base Address
endstruc
```

### TSS Usage for Privilege Level Changes

When the processor transitions from a lower privilege level (higher CPL value) to a higher privilege level (lower CPL value), such as when user code triggers an interrupt or system call, the processor automatically loads the stack pointer from the TSS.

**Mechanism:**

1. Interrupt or call gate triggers privilege level change
2. Processor reads SS and ESP from TSS based on target privilege level
3. Current SS:ESP pushed onto new stack
4. Processor switches to new stack from TSS
5. Handler executes with new stack
6. IRET restores original stack

```assembly
; Setting up TSS for kernel operations
setup_tss:
    ; Define TSS structure in memory
    mov dword [tss + TSS32.esp0], kernel_stack_top
    mov word [tss + TSS32.ss0], 0x10      ; Kernel data segment
    mov dword [tss + TSS32.cr3], page_directory
    mov word [tss + TSS32.iomap_base], 104 ; No I/O bitmap
    
    ; Load TSS selector into TR register
    mov ax, 0x28        ; TSS selector (assuming GDT entry 5)
    ltr ax              ; Load Task Register
    ret
```

### TSS Descriptor in GDT

The TSS must be described by a descriptor in the Global Descriptor Table (GDT). Unlike code and data segments, the TSS descriptor has a specific format:

```assembly
; TSS descriptor structure (in GDT)
; Base: Linear address of TSS
; Limit: Size of TSS - 1
; Type: 0x89 (available 32-bit TSS) or 0x8B (busy 32-bit TSS)

tss_descriptor:
    dw tss_limit & 0xFFFF           ; Limit 15:0
    dw tss_base & 0xFFFF            ; Base 15:0
    db (tss_base >> 16) & 0xFF      ; Base 23:16
    db 0x89                          ; P=1, DPL=0, Type=9 (available TSS)
    db ((tss_limit >> 16) & 0x0F) | 0x00  ; Limit 19:16, G=0
    db (tss_base >> 24) & 0xFF      ; Base 31:24
```

**Type Field Values:**

- 0x1: 16-bit TSS (available)
- 0x3: 16-bit TSS (busy)
- 0x9: 32-bit TSS (available)
- 0xB: 32-bit TSS (busy)

### I/O Permission Bitmap

The TSS can include an I/O permission bitmap that controls port access at different privilege levels. This bitmap follows the basic TSS structure and can extend up to 8 KB.

```assembly
; TSS with I/O permission bitmap
tss_with_iomap:
    ; Basic TSS structure (104 bytes)
    times 104 db 0
    
    ; I/O Permission Bitmap
    ; Each bit represents one I/O port (0-65535)
    ; Bit 0 = allow, Bit 1 = deny
    io_bitmap:
        times 8192 db 0xFF  ; Deny all ports by default
    
    ; Bitmap must end with 0xFF byte
    db 0xFF
```

The `iomap_base` field in the TSS points to the offset of the bitmap from the TSS base. If a task attempts to access a port and the corresponding bit is set, a General Protection Fault occurs.

### TSS Structure in 64-bit Long Mode

In 64-bit mode, the TSS structure is different and simpler, as hardware task switching is not supported:

```assembly
; 64-bit TSS structure
struc TSS64
    .reserved0    resd 1     ; Offset 0x00: Reserved
    .rsp0         resq 1     ; Offset 0x04: RSP for privilege level 0
    .rsp1         resq 1     ; Offset 0x0C: RSP for privilege level 1
    .rsp2         resq 1     ; Offset 0x14: RSP for privilege level 2
    .reserved1    resq 1     ; Offset 0x1C: Reserved
    .ist1         resq 1     ; Offset 0x24: Interrupt Stack Table 1
    .ist2         resq 1     ; Offset 0x2C: Interrupt Stack Table 2
    .ist3         resq 1     ; Offset 0x34: Interrupt Stack Table 3
    .ist4         resq 1     ; Offset 0x3C: Interrupt Stack Table 4
    .ist5         resq 1     ; Offset 0x44: Interrupt Stack Table 5
    .ist6         resq 1     ; Offset 0x4C: Interrupt Stack Table 6
    .ist7         resq 1     ; Offset 0x54: Interrupt Stack Table 7
    .reserved2    resq 1     ; Offset 0x5C: Reserved
    .reserved3    resw 1     ; Offset 0x64: Reserved
    .iomap_base   resw 1     ; Offset 0x66: I/O Map Base Address
endstruc
```

The Interrupt Stack Table (IST) mechanism in 64-bit mode provides separate stacks for critical interrupts, improving system reliability.

### Modern TSS Usage

Contemporary operating systems typically use a single TSS per CPU core and do not use hardware task switching. Instead, they:

1. Maintain one TSS per processor/core
2. Update ESP0/RSP0 fields when switching tasks in software
3. Use TSS primarily for privilege level transitions
4. Implement multitasking through software context switching

```assembly
; Software task switch example (updating TSS)
switch_to_task:
    ; Parameters: new_task structure pointer in EAX
    
    ; Update TSS with new kernel stack
    mov ebx, [eax + TASK.kernel_stack]
    mov [tss + TSS32.esp0], ebx
    
    ; Update page directory
    mov ebx, [eax + TASK.page_dir]
    mov cr3, ebx
    
    ; Switch to task's context
    mov esp, [eax + TASK.esp]
    mov ebp, [eax + TASK.ebp]
    ; ... restore other registers ...
    
    ret
```

