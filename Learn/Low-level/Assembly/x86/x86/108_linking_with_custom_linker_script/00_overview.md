## Overview

ld -m elf_i386 -T linker.ld -o firmware.elf startup.o main.o
```

### Linker Scripts for Embedded Targets

```ld
/* linker.ld - Custom memory layout */
OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(_start)

MEMORY
{
    ROM (rx)  : ORIGIN = 0xFFFE0000, LENGTH = 128K
    RAM (rwx) : ORIGIN = 0x00100000, LENGTH = 1M
}

SECTIONS
{
    .text : {
        *(.text.boot)
        *(.text*)
        *(.rodata*)
    } > ROM

    .data : AT(ADDR(.text) + SIZEOF(.text)) {
        _data_start = .;
        *(.data*)
        _data_end = .;
    } > RAM

    .bss : {
        _bss_start = .;
        *(.bss*)
        *(COMMON)
        _bss_end = .;
    } > RAM

    .stack : {
        . = ALIGN(16);
        _stack_bottom = .;
        . += 0x10000;  /* 64KB stack */
        _stack_top = .;
    } > RAM
}
```

### Position-Independent Code

```asm
; PIC for relocatable firmware
get_eip:
    call .next
.next:
    pop eax
    ret

; Access data relative to EIP
access_data_pic:
    call get_eip
    sub eax, ($ - data_table)
    mov ebx, [eax]      ; Access data_table via calculated address
    ret

data_table:
    dd 0x12345678
```

### Multi-Stage Build Process

**Example** - Stage 1 bootloader assembly:

```asm
; stage1.asm - Fits in 512 bytes
[BITS 16]
[ORG 0x7C00]

stage1:
    ; Minimal initialization
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    ; Load stage2 from disk
    mov ah, 0x02
    mov al, 32          ; 32 sectors (16KB)
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov bx, 0x1000
    int 0x13
    
    ; Jump to stage2
    jmp 0x0000:0x1000

times 510-($-$$) db 0
dw 0xAA55
```

**Example** - Stage 2 loader:

```asm
; stage2.asm - Full firmware loader
[BITS 16]
[ORG 0x1000]

stage2:
    ; Enable A20, setup GDT, switch to protected mode
    call enable_a20_fast
    
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    
    jmp 0x08:protected_start

[BITS 32]
protected_start:
    ; Load main firmware from flash/disk to RAM
    ; Relocate and execute
    jmp 0x100000
```

### Build Automation

```makefile
