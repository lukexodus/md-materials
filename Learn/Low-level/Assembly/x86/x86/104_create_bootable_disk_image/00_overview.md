## Overview

dd if=/dev/zero of=disk.img bs=512 count=2880  # 1.44MB floppy
dd if=bootsect.bin of=disk.img conv=notrunc
qemu-system-i386 -fda disk.img
```

**Key Points:**

- Always test in emulator before real hardware
- QEMU allows debugging with GDB
- VirtualBox and VMware also useful for testing
- Real hardware testing may show different behavior
- [Unverified: Behavior varies by hardware] Some BIOSes have quirks not present in emulators

**Common Boot Sector Bugs:**

```nasm
; BUG: Not initializing stack
; RESULT: Stack operations may corrupt code/data
; FIX:
xor ax, ax
mov ss, ax
mov sp, 0x7C00

; BUG: Assuming segment registers
mov si, message
lodsb                ; If DS != expected, wrong data
; FIX: Always initialize DS
xor ax, ax
mov ds, ax

; BUG: Not preserving boot drive
; RESULT: Cannot read additional sectors
; FIX: Save DL immediately
mov [boot_drive], dl

; BUG: Incorrect sector calculation
mov cl, 1             ; Sector 1 is boot sector!
; FIX: Start from sector 2
mov cl, 2

; BUG: Buffer overflow in small boot sector
; 512 bytes fills quickly
; FIX: Aggressively optimize, use second stage

; BUG: Not checking carry flag after INT 13h
int 0x13
; Continues even if error
; FIX:
int 0x13
jc error_handler

; BUG: Forgetting boot signature
; RESULT: BIOS won't recognize as bootable
; FIX:
times 510-($-$$) db 0
dw 0xAA55
```

**Conclusion:**

Bootloader development requires deep understanding of x86 architecture, firmware interfaces, and hardware constraints. BIOS systems provide simple interrupt-based services in 16-bit real mode with severe size limitations, while UEFI offers modern protected-mode environment with comprehensive APIs but increased complexity. The boot process progresses through multiple stages, each with expanded capabilities. The Master Boot Record serves as the first-stage bootloader for BIOS systems with integrated partition table, while GPT provides modern partitioning for UEFI. Boot sector programming demands careful attention to size optimization, real-mode addressing quirks, disk I/O methods, and error handling within the 512-byte constraint. Success requires thorough testing in emulators and real hardware, understanding of common pitfalls, and knowledge of historical x86 compatibility requirements.

---

## Real Mode Initialization

### BIOS POST and Boot Process

When an x86 system powers on, the BIOS performs a Power-On Self-Test (POST) and initializes basic hardware. The BIOS then searches for bootable devices according to the boot order configuration. For each device, it reads the first 512-byte sector (sector 0, the Master Boot Record or MBR) into memory at address `0x7C00` and checks for the boot signature `0xAA55` at bytes 510-511.

If the signature is present, the BIOS transfers control to `0x7C00` in real mode, where the bootloader begins execution.

### Real Mode Memory Layout

Real mode uses 20-bit addressing (1 MB address space) with segment:offset pairs. The bootloader must understand this memory layout:

```
0x00000000 - 0x000003FF: Interrupt Vector Table (IVT)
0x00000400 - 0x000004FF: BIOS Data Area (BDA)
0x00000500 - 0x00007BFF: Free conventional memory
0x00007C00 - 0x00007DFF: Bootloader (MBR loaded here)
0x00007E00 - 0x0007FFFF: Free conventional memory
0x00080000 - 0x0009FFFF: Extended BIOS Data Area (EBDA)
0x000A0000 - 0x000FFFFF: Video memory, ROM BIOS
```

### Setting Up Segments

The bootloader must establish proper segment registers. Since the BIOS loads code at `0x7C00`, you can set up segments in multiple ways:

```nasm
; Option 1: Zero all segments, use offset 0x7C00
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00      ; Stack grows downward from bootloader

; Option 2: Set CS to 0x07C0, use offset 0
mov ax, 0x07C0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x0000
```

Both approaches map to physical address `0x7C00`, but affect how you calculate addresses in code.

### Disabling Interrupts and Configuring Stack

```nasm
cli                 ; Clear interrupts during setup
cld                 ; Clear direction flag (string ops increment)

; Set up stack
xor ax, ax
mov ss, ax
mov sp, 0x7C00      ; Stack from 0x7C00 downward
mov bp, sp

sti                 ; Re-enable interrupts
```

### BIOS Interrupt Services

Real mode bootloaders rely on BIOS interrupts for I/O operations:

**INT 0x10 - Video Services**

```nasm
; Print character
mov ah, 0x0E        ; Teletype output
mov al, 'A'         ; Character to print
mov bh, 0x00        ; Page number
mov bl, 0x07        ; Text attribute
int 0x10
```

**INT 0x13 - Disk Services**

```nasm
; Read sectors using CHS addressing
mov ah, 0x02        ; Read function
mov al, 1           ; Number of sectors
mov ch, 0           ; Cylinder
mov cl, 2           ; Sector (1-based)
mov dh, 0           ; Head
mov dl, 0x80        ; Drive (0x00=floppy, 0x80=HDD)
mov bx, 0x7E00      ; ES:BX = destination buffer
int 0x13
jc disk_error       ; CF set on error
```

**INT 0x13 Extensions (LBA)**

```nasm
; Disk Address Packet (DAP) structure
dap:
    db 0x10         ; Size of DAP
    db 0            ; Reserved
    dw 1            ; Number of sectors
    dw 0x7E00       ; Offset
    dw 0            ; Segment
    dq 1            ; Starting LBA

; Read using LBA
mov ah, 0x42        ; Extended read
mov dl, 0x80        ; Drive
mov si, dap         ; DS:SI = DAP
int 0x13
```

### Detecting Memory

Before loading the kernel, query available memory using BIOS services:

```nasm
; E820 memory map (preferred method)
xor ebx, ebx
mov di, 0x8000      ; Buffer for memory map
.e820_loop:
    mov eax, 0xE820
    mov ecx, 24     ; Buffer size
    mov edx, 0x534D4150  ; 'SMAP' signature
    int 0x15
    jc .e820_done
    
    ; Process entry at ES:DI
    add di, 24
    test ebx, ebx
    jnz .e820_loop
.e820_done:
```

### A20 Line Enablement

The A20 line must be enabled to access memory beyond 1 MB. This is a hardware legacy feature that wraps addresses at 1 MB when disabled:

```nasm
; Check if A20 is already enabled
call check_a20
cmp ax, 1
je a20_enabled

; Method 1: Fast A20 (not always supported)
in al, 0x92
or al, 2
out 0x92, al

; Method 2: Keyboard controller
call wait_input
mov al, 0xAD
out 0x64, al        ; Disable keyboard

call wait_input
mov al, 0xD0
out 0x64, al        ; Read output port

call wait_output
in al, 0x60
push ax

call wait_input
mov al, 0xD1
out 0x64, al        ; Write output port

call wait_input
pop ax
or al, 2            ; Set A20 bit
out 0x60, al

call wait_input
mov al, 0xAE
out 0x64, al        ; Enable keyboard

a20_enabled:

wait_input:
    in al, 0x64
    test al, 2
    jnz wait_input
    ret

wait_output:
    in al, 0x64
    test al, 1
    jz wait_output
    ret

check_a20:
    pushf
    push ds
    push es
    push di
    push si
    
    cli
    xor ax, ax
    mov es, ax
    mov di, 0x0500
    
    not ax
    mov ds, ax
    mov si, 0x0510
    
    mov al, byte [es:di]
    push ax
    mov al, byte [ds:si]
    push ax
    
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
    
    cmp byte [es:di], 0xFF
    
    pop ax
    mov byte [ds:si], al
    pop ax
    mov byte [es:di], al
    
    mov ax, 0
    je check_a20_exit
    mov ax, 1
    
check_a20_exit:
    pop si
    pop di
    pop es
    pop ds
    popf
    ret
```

## Loading Kernels

### Multi-Stage Loading

A 512-byte MBR is insufficient for complex bootloaders. Multi-stage loading divides the bootloader into stages:

**Stage 1 (MBR, 446 bytes)**: Loads Stage 2 **Stage 2 (several sectors)**: Loads kernel, sets up environment **Stage 3 (optional)**: Advanced features, filesystem drivers

### Loading from Disk

**CHS vs LBA Addressing**

Older systems use Cylinder-Head-Sector (CHS) addressing:

- Cylinder: 10 bits (0-1023)
- Head: 8 bits (0-255)
- Sector: 6 bits (1-63, 1-based indexing)

Modern systems use Logical Block Addressing (LBA):

- 48-bit or 64-bit linear sector number
- LBA 0 = first sector (MBR)

**LBA to CHS Conversion**

```nasm
; LBA = (C × HPC + H) × SPT + (S − 1)
; Where HPC = heads per cylinder, SPT = sectors per track

lba_to_chs:
    ; Input: EAX = LBA, outputs in CX (cylinder/sector), DH (head)
    xor edx, edx
    mov ebx, [sectors_per_track]
    div ebx             ; EAX = LBA / SPT, EDX = sector - 1
    inc dl              ; DL = sector (1-based)
    mov cl, dl          ; CL = sector
    
    xor edx, edx
    mov ebx, [heads_per_cylinder]
    div ebx             ; EAX = cylinder, EDX = head
    mov dh, dl          ; DH = head
    mov ch, al          ; CH = cylinder low 8 bits
    shl ah, 6
    or cl, ah           ; CL high 2 bits = cylinder high 2 bits
    ret
```

### Loading Kernel Image

**Single-Segment Load (kernels < 64 KB)**

```nasm
; Load kernel at 0x10000 (64 KB boundary)
mov ax, 0x1000
mov es, ax
xor bx, bx          ; ES:BX = 0x1000:0x0000

mov ah, 0x02        ; Read sectors
mov al, 32          ; Load 32 sectors (16 KB)
mov ch, 0           ; Cylinder 0
mov cl, 2           ; Start from sector 2
mov dh, 0           ; Head 0
mov dl, [boot_drive]
int 0x13
jc disk_error
```

**Multi-Segment Load (larger kernels)**

```nasm
load_kernel:
    mov word [kernel_sectors], 128  ; 64 KB kernel
    mov word [current_sector], 2
    mov ax, 0x1000
    mov es, ax
    xor bx, bx

.load_loop:
    mov ah, 0x02
    mov al, 1           ; Load 1 sector at a time
    
    ; Convert LBA to CHS
    mov ax, [current_sector]
    call lba_to_chs
    
    mov dl, [boot_drive]
    int 0x13
    jc disk_error
    
    add bx, 512         ; Next 512 bytes
    jnc .no_segment_wrap
    
    ; Segment overflow, move to next 64 KB
    mov ax, es
    add ax, 0x1000
    mov es, ax
    xor bx, bx
    
.no_segment_wrap:
    inc word [current_sector]
    dec word [kernel_sectors]
    jnz .load_loop
    ret
```

### ELF Kernel Loading

Many kernels use the ELF (Executable and Linkable Format) format. The bootloader must parse ELF headers and load program segments:

```nasm
; ELF header structure (simplified)
struc ELF_Header
    .e_ident:       resb 16     ; Magic number and other info
    .e_type:        resw 1      ; Object file type
    .e_machine:     resw 1      ; Architecture
    .e_version:     resd 1      ; Object file version
    .e_entry:       resd 1      ; Entry point address
    .e_phoff:       resd 1      ; Program header offset
    .e_shoff:       resd 1      ; Section header offset
    .e_flags:       resd 1      ; Processor-specific flags
    .e_ehsize:      resw 1      ; ELF header size
    .e_phentsize:   resw 1      ; Program header entry size
    .e_phnum:       resw 1      ; Program header entry count
endstruc

; Program header structure
struc ELF_ProgramHeader
    .p_type:        resd 1      ; Segment type
    .p_offset:      resd 1      ; Offset in file
    .p_vaddr:       resd 1      ; Virtual address
    .p_paddr:       resd 1      ; Physical address
    .p_filesz:      resd 1      ; Segment size in file
    .p_memsz:       resd 1      ; Segment size in memory
    .p_flags:       resd 1      ; Segment flags
    .p_align:       resd 1      ; Alignment
endstruc

load_elf:
    ; Load ELF file into buffer at 0x10000
    mov ax, 0x1000
    mov es, ax
    xor di, di
    
    ; Verify ELF magic (0x7F 'E' 'L' 'F')
    cmp byte [es:di], 0x7F
    jne .not_elf
    cmp dword [es:di], 0x464C457F
    jne .not_elf
    
    ; Get program header offset and count
    mov eax, [es:di + ELF_Header.e_phoff]
    mov cx, [es:di + ELF_Header.e_phnum]
    mov bx, ax          ; BX = program header offset
    
.load_segments:
    ; Check if PT_LOAD segment (type = 1)
    cmp dword [es:bx + ELF_ProgramHeader.p_type], 1
    jne .next_segment
    
    ; Load segment
    mov eax, [es:bx + ELF_ProgramHeader.p_offset]
    mov esi, eax        ; Source offset in file
    mov eax, [es:bx + ELF_ProgramHeader.p_paddr]
    mov edi, eax        ; Destination physical address
    mov ecx, [es:bx + ELF_ProgramHeader.p_filesz]
    
    ; Copy segment (requires protected mode for 32-bit addresses)
    ; This is simplified; actual implementation needs mode switching
    
.next_segment:
    add bx, [es:di + ELF_Header.e_phentsize]
    loop .load_segments
    
    ; Get entry point
    mov eax, [es:di + ELF_Header.e_entry]
    mov [kernel_entry], eax
    ret

.not_elf:
    ; Handle error
    ret
```

### Protected Mode Transition

Before jumping to a 32-bit kernel, the bootloader must switch to protected mode:

```nasm
; Global Descriptor Table
gdt_start:
    ; Null descriptor
    dq 0

    ; Code segment descriptor
    dw 0xFFFF       ; Limit low
    dw 0x0000       ; Base low
    db 0x00         ; Base middle
    db 10011010b    ; Access: present, ring 0, code, executable, readable
    db 11001111b    ; Flags: granularity, 32-bit
    db 0x00         ; Base high

    ; Data segment descriptor
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b    ; Access: present, ring 0, data, writable
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size
    dd gdt_start                 ; Offset

CODE_SEG equ 0x08
DATA_SEG equ 0x10

switch_to_pm:
    cli                 ; Disable interrupts
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 1           ; Set PE (Protection Enable) bit
    mov cr0, eax
    
    jmp CODE_SEG:init_pm  ; Far jump to set CS

[bits 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x90000    ; Set up stack in protected mode
    mov esp, ebp
    
    ; Jump to kernel
    jmp [kernel_entry]
```

### Long Mode Transition (64-bit)

For 64-bit kernels, the bootloader must enable long mode:

```nasm
; Check for long mode support
check_long_mode:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_long_mode
    
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29   ; Check LM bit
    jz .no_long_mode
    ret

.no_long_mode:
    ; Handle error
    hlt

; Set up paging for long mode
setup_page_tables:
    ; Identity map first 2 MB
    mov edi, 0x1000     ; PML4 at 0x1000
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096
    rep stosd           ; Clear page tables
    mov edi, cr3
    
    ; PML4[0] -> PDP
    mov dword [edi], 0x2003     ; Present, writable
    add edi, 0x1000
    
    ; PDP[0] -> PD
    mov dword [edi], 0x3003
    add edi, 0x1000
    
    ; PD[0] -> 2 MB page
    mov dword [edi], 0x00000083 ; Present, writable, huge page
    
    ; Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax
    
    ; Set long mode bit in EFER MSR
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr
    
    ; Enable paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax
    
    ret

; GDT for long mode
gdt64:
    dq 0                        ; Null descriptor
    dq 0x00209A0000000000      ; 64-bit code segment
    dq 0x0000920000000000      ; 64-bit data segment

gdt64_descriptor:
    dw gdt64_descriptor - gdt64 - 1
    dd gdt64

switch_to_long_mode:
    call check_long_mode
    call setup_page_tables
    
    lgdt [gdt64_descriptor]
    jmp 0x08:long_mode_entry

[bits 64]
long_mode_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Jump to 64-bit kernel
    mov rax, [kernel_entry]
    jmp rax
```

## Bootloader Protocols

### Multiboot Specification

The Multiboot specification (by GNU GRUB) defines a standardized interface between bootloaders and kernels. It consists of a header in the kernel and information passed from bootloader to kernel.

**Multiboot Header**

The kernel must have a Multiboot header in the first 8 KB:

```nasm
MULTIBOOT_MAGIC         equ 0x1BADB002
MULTIBOOT_PAGE_ALIGN    equ 1 << 0
MULTIBOOT_MEMORY_INFO   equ 1 << 1
MULTIBOOT_FLAGS         equ MULTIBOOT_PAGE_ALIGN | MULTIBOOT_MEMORY_INFO
MULTIBOOT_CHECKSUM      equ -(MULTIBOOT_MAGIC + MULTIBOOT_FLAGS)

section .multiboot
align 4
    dd MULTIBOOT_MAGIC
    dd MULTIBOOT_FLAGS
    dd MULTIBOOT_CHECKSUM
```

**Multiboot Information Structure**

The bootloader passes information to the kernel via a structure pointer in EBX:

```nasm
struc MultibootInfo
    .flags:             resd 1      ; Required flags
    .mem_lower:         resd 1      ; Available lower memory
    .mem_upper:         resd 1      ; Available upper memory
    .boot_device:       resd 1      ; Boot device identifier
    .cmdline:           resd 1      ; Kernel command line
    .mods_count:        resd 1      ; Number of modules
    .mods_addr:         resd 1      ; Modules list address
    .syms:              resd 4      ; Symbol table info
    .mmap_length:       resd 1      ; Memory map length
    .mmap_addr:         resd 1      ; Memory map address
    .drives_length:     resd 1      ; Drives info length
    .drives_addr:       resd 1      ; Drives info address
    .config_table:      resd 1      ; ROM configuration table
    .boot_loader_name:  resd 1      ; Bootloader name
    .apm_table:         resd 1      ; APM table
    .vbe_control_info:  resd 1      ; VBE control info
    .vbe_mode_info:     resd 1      ; VBE mode info
    .vbe_mode:          resw 1      ; VBE mode
    .vbe_interface_seg: resw 1      ; VBE interface segment
    .vbe_interface_off: resw 1      ; VBE interface offset
    .vbe_interface_len: resw 1      ; VBE interface length
endstruc
```

**Bootloader Implementation**

```nasm
; Check for Multiboot header
find_multiboot_header:
    mov edi, 0x10000        ; Kernel loaded here
    mov ecx, 2048           ; Search first 8 KB
    
.search_loop:
    cmp dword [edi], 0x1BADB002
    je .found
    add edi, 4
    loop .search_loop
    jmp .not_found
    
.found:
    ; Verify checksum
    mov eax, [edi]          ; Magic
    add eax, [edi + 4]      ; Flags
    add eax, [edi + 8]      ; Checksum
    test eax, eax
    jnz .not_found
    
    ; Valid Multiboot kernel
    mov [multiboot_flags], dword [edi + 4]
    ret

.not_found:
    ; Not a Multiboot kernel
    ret

; Prepare Multiboot info structure
prepare_multiboot_info:
    mov edi, 0x9000         ; Info structure at 0x9000
    
    ; Set flags
    mov dword [edi + MultibootInfo.flags], 0x0000004F
    
    ; Memory info
    mov dword [edi + MultibootInfo.mem_lower], 640
    mov eax, [extended_memory_kb]
    mov [edi + MultibootInfo.mem_upper], eax
    
    ; Boot device
    mov al, [boot_drive]
    mov [edi + MultibootInfo.boot_device], al
    
    ; Command line
    mov dword [edi + MultibootInfo.cmdline], kernel_cmdline
    
    ; Memory map
    mov eax, [memory_map_entries]
    mov [edi + MultibootInfo.mmap_length], eax
    mov dword [edi + MultibootInfo.mmap_addr], 0x8000
    
    ; Bootloader name
    mov dword [edi + MultibootInfo.boot_loader_name], bootloader_name
    
    ret

; Jump to Multiboot kernel
jump_to_multiboot_kernel:
    mov eax, 0x2BADB002     ; Multiboot magic
    mov ebx, 0x9000         ; Info structure
    jmp [kernel_entry]
```

### Multiboot2 Protocol

Multiboot2 is an improved version with better extensibility and 64-bit support.

**Multiboot2 Header**

```nasm
MULTIBOOT2_MAGIC            equ 0xE85250D6
MULTIBOOT2_ARCHITECTURE     equ 0           ; 0 = i386 protected mode

section .multiboot2
align 8
multiboot2_header_start:
    dd MULTIBOOT2_MAGIC
    dd MULTIBOOT2_ARCHITECTURE
    dd multiboot2_header_end - multiboot2_header_start
    dd -(MULTIBOOT2_MAGIC + MULTIBOOT2_ARCHITECTURE + (multiboot2_header_end - multiboot2_header_start))

    ; Information request tag
    align 8
    dw 1                    ; Type: information request
    dw 0                    ; Flags
    dd 20                   ; Size
    dd 4                    ; Request memory map
    dd 6                    ; Request bootloader name

    ; End tag
    align 8
    dw 0                    ; Type: end
    dw 0                    ; Flags
    dd 8                    ; Size

multiboot2_header_end:
```

**Multiboot2 Information Tags**

The bootloader passes a series of tagged structures:

```nasm
; Parse Multiboot2 info
parse_multiboot2_info:
    mov esi, ebx            ; ESI = info structure pointer
    mov ecx, [esi]          ; Total size
    add esi, 8              ; Skip size and reserved
    
.parse_loop:
    mov eax, [esi]          ; Tag type
    test eax, eax
    jz .done                ; Type 0 = end
    
    cmp eax, 4
    je .memory_map_tag
    
    cmp eax, 6
    je .bootloader_name_tag
    
    jmp .next_tag

.memory_map_tag:
    ; Process memory map
    mov edi, [esi + 8]      ; Entry size
    mov ecx, [esi + 12]     ; Entry version
    lea ebx, [esi + 16]     ; First entry
    ; Process entries...
    jmp .next_tag

.bootloader_name_tag:
    lea eax, [esi + 8]      ; String pointer
    ; Process bootloader name...
    
.next_tag:
    mov eax, [esi + 4]      ; Tag size
    add esi, eax
    ; Align to 8 bytes
    add esi, 7
    and esi, ~7
    jmp .parse_loop
    
.done:
    ret
```

### Linux Boot Protocol

The Linux kernel has its own boot protocol, defined in the kernel source's `Documentation/x86/boot.txt`.

**Linux Kernel Header**

Located at offset 0x1F1 in the kernel image:

```nasm
struc LinuxHeader
    .setup_sects:       resb 1      ; Size of setup in 512-byte sectors
    .root_flags:        resw 1      ; Root flags
    .syssize:           resd 1      ; Size of protected-mode code
    .ram_size:          resw 1      ; RAM disk size
    .vid_mode:          resw 1      ; Video mode
    .root_dev:          resw 1      ; Root device number
    .boot_flag:         resw 1      ; Boot signature (0xAA55)
    .jump:              resw 1      ; Jump instruction
    .header:            resd 1      ; Header signature ('HdrS')
    .version:           resw 1      ; Protocol version
    .realmode_swtch:    resd 1      ; Real mode switch routine
    .start_sys_seg:     resw 1      ; Start segment of loaded system
    .kernel_version:    resw 1      ; Kernel version string pointer
    .type_of_loader:    resb 1      ; Bootloader ID
    .loadflags:         resb 1      ; Boot protocol flags
    .setup_move_size:   resw 1      ; Size to move setup code
    .code32_start:      resd 1      ; 32-bit entry point
    .ramdisk_image:     resd 1      ; RAM disk image address
    .ramdisk_size:      resd 1      ; RAM disk size
    .bootsect_kludge:   resd 1      ; Obsolete
    .heap_end_ptr:      resw 1      ; Heap end pointer
    .ext_loader_ver:    resb 1      ; Extended bootloader version
    .ext_loader_type:   resb 1      ; Extended bootloader type
    .cmd_line_ptr:      resd 1      ; Command line pointer
    .initrd_addr_max:   resd 1      ; Highest address for initrd
    .kernel_alignment:  resd 1      ; Kernel alignment
    .relocatable_kernel:resb 1      ; Whether kernel is relocatable
    .min_alignment:     resb 1      ; Minimum alignment
    .xloadflags:        resw 1      ; Extended load flags
    .cmdline_size:      resd 1      ; Maximum command line size
    .hardware_subarch:  resd 1      ; Hardware subarchitecture
    .hardware_subarch_data: resq 1  ; Subarch-specific data
    .payload_offset:    resd 1      ; Offset of kernel payload
    .payload_length:    resd 1      ; Length of kernel payload
    .setup_data:        resq 1      ; Setup data pointer
    .pref_address:      resq 1      ; Preferred loading address
    .init_size:         resd 1      ; Linear memory required
    .handover_offset:   resd 1      ; Handover protocol offset
endstruc
```

**Loading Linux Kernel**

```nasm
load_linux_kernel:
    ; Load first sector (boot sector + partial setup)
    mov ax, 0x9000
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 1
    mov dh, 0
    mov dl, [boot_drive]
    int 0x13
    
    ; Check boot signature
    cmp word [es:0x1FE], 0xAA55
    jne .invalid
    
    ; Check header signature 'HdrS'
    cmp dword [es:0x202], 0x53726448
    jne .invalid
    
    ; Get setup size
    movzx ax, byte [es:0x1F1]
    test ax, ax
    jnz .has_setup_sects
    mov ax, 4               ; Default 4 sectors
.has_setup_sects:
    inc ax                  ; Include boot sector
    mov [setup_sectors], ax
    
    ; Load setup code
    mov ah, 0x02
    mov al, [setup_sectors]
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [boot_drive]
    int 0x13
    
    ; Set up boot parameters
    mov byte [es:0x210], 0xFF       ; Bootloader type (0xFF = undefined)
    mov byte [es:0x211], 0x80       ; Loadflags (CAN_USE_HEAP, LOADED_HIGH)
    mov word [es:0x224], 0xDE00     ; Heap end pointer
    mov dword [es:0x228], kernel_cmdline  ; Command line pointer
    
    ; Load protected-mode kernel
    mov eax, [es:0x1F4]     ; syssize in 16-byte paragraphs
    shl eax, 4              ; Convert to bytes
    add eax, 15
    shr eax, 9              ; Convert to sectors
    mov [kernel_sectors], eax
    
    mov ax, 0x1000
    mov es, ax
    xor bx, bx

    mov cx, [setup_sectors]
    inc cx                  ; Start after setup code
    
.load_kernel_loop:
    mov ah, 0x02
    mov al, 64              ; Load 64 sectors at a time (32 KB)
    cmp [kernel_sectors], dword 64
    jae .load_chunk
    mov al, [kernel_sectors]
    
.load_chunk:
    push ax
    mov ch, 0
    mov cl, [current_sector]
    mov dh, 0
    mov dl, [boot_drive]
    int 0x13
    jc .disk_error
    
    pop ax
    movzx eax, al
    sub [kernel_sectors], eax
    add [current_sector], al
    
    ; Advance buffer
    shl ax, 9               ; Sectors to bytes
    add bx, ax
    jnc .no_segment_overflow
    mov ax, es
    add ax, 0x1000
    mov es, ax
    
.no_segment_overflow:
    cmp [kernel_sectors], dword 0
    ja .load_kernel_loop
    
    ; Jump to setup code
    mov ax, 0x9020          ; Setup starts at 0x90200
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0xE000
    
    jmp 0x9020:0            ; Jump to setup entry point

.invalid:
    ; Not a valid Linux kernel
    ret

.disk_error:
    ; Handle disk error
    ret
```

**Linux Boot Handover Protocol**

Modern Linux kernels support a handover protocol for 64-bit EFI bootloaders:

```nasm
; 64-bit handover
linux_handover_64:
    ; Kernel must be loaded with EFI stub
    mov rax, [kernel_base]
    add rax, [handover_offset]  ; From header offset 0x264
    
    ; RAX = handover entry point
    ; RDI = boot_params pointer
    ; RSI = EFI system table pointer (or 0 for legacy)
    
    xor rsi, rsi            ; No EFI system table in legacy mode
    mov rdi, 0x9000         ; boot_params structure
    call rax
```

## UEFI Boot Protocol

UEFI replaces the traditional BIOS boot process with a more advanced firmware interface.

**UEFI Application Structure**

UEFI bootloaders are PE/COFF executables:

```nasm
; PE header for UEFI application
section .text

DOS_HEADER:
    dw 0x5A4D               ; 'MZ' signature
    times 58 db 0
    dd PE_HEADER            ; Offset to PE header

PE_HEADER:
    dd 0x00004550           ; 'PE\0\0' signature
    dw 0x8664               ; Machine (x86-64)
    dw 1                    ; Number of sections
    dd 0                    ; Timestamp
    dd 0                    ; Symbol table offset
    dd 0                    ; Number of symbols
    dw OPTIONAL_HEADER_SIZE ; Optional header size
    dw 0x206                ; Characteristics

OPTIONAL_HEADER:
    dw 0x020B               ; Magic (PE32+)
    db 0                    ; Linker major version
    db 0                    ; Linker minor version
    dd _text_end - _text_start  ; Size of code
    dd 0                    ; Size of initialized data
    dd 0                    ; Size of uninitialized data
    dd efi_main - DOS_HEADER    ; Entry point
    dd _text_start - DOS_HEADER ; Base of code
    dq 0x400000             ; Image base
    dd 0x1000               ; Section alignment
    dd 0x200                ; File alignment
    dw 0                    ; OS major version
    dw 0                    ; OS minor version
    dw 0                    ; Image major version
    dw 0                    ; Image minor version
    dw 0                    ; Subsystem major version
    dw 0                    ; Subsystem minor version
    dd 0                    ; Reserved
    dd _image_end - DOS_HEADER  ; Size of image
    dd _headers_end - DOS_HEADER ; Size of headers
    dd 0                    ; Checksum
    dw 10                   ; Subsystem (EFI application)
    dw 0                    ; DLL characteristics
    dq 0x100000             ; Stack reserve size
    dq 0x1000               ; Stack commit size
    dq 0x100000             ; Heap reserve size
    dq 0x1000               ; Heap commit size
    dd 0                    ; Loader flags
    dd 16                   ; Number of data directories
    
    ; Data directories
    times 16 dd 0, 0        ; RVA, Size pairs

OPTIONAL_HEADER_SIZE equ $ - OPTIONAL_HEADER

; Section header
SECTION_HEADER:
    db '.text', 0, 0, 0     ; Name
    dd _text_end - _text_start  ; Virtual size
    dd _text_start - DOS_HEADER ; Virtual address
    dd _text_end - _text_start  ; Size of raw data
    dd _text_start - DOS_HEADER ; Pointer to raw data
    dd 0                    ; Relocations pointer
    dd 0                    ; Line numbers pointer
    dw 0                    ; Number of relocations
    dw 0                    ; Number of line numbers
    dd 0x60000020           ; Characteristics (code, execute, read)

_headers_end:

_text_start:
```

**UEFI System Table and Boot Services**

```nasm
; UEFI system table structures
struc EFI_TABLE_HEADER
    .Signature:         resq 1
    .Revision:          resd 1
    .HeaderSize:        resd 1
    .CRC32:             resd 1
    .Reserved:          resd 1
endstruc

struc EFI_SYSTEM_TABLE
    .Hdr:               resb EFI_TABLE_HEADER_size
    .FirmwareVendor:    resq 1
    .FirmwareRevision:  resd 1
    .ConsoleInHandle:   resq 1
    .ConIn:             resq 1
    .ConsoleOutHandle:  resq 1
    .ConOut:            resq 1
    .StandardErrorHandle: resq 1
    .StdErr:            resq 1
    .RuntimeServices:   resq 1
    .BootServices:      resq 1
    .NumberOfTableEntries: resq 1
    .ConfigurationTable: resq 1
endstruc

struc EFI_BOOT_SERVICES
    .Hdr:               resb EFI_TABLE_HEADER_size
    .RaiseTPL:          resq 1
    .RestoreTPL:        resq 1
    .AllocatePages:     resq 1
    .FreePages:         resq 1
    .GetMemoryMap:      resq 1
    .AllocatePool:      resq 1
    .FreePool:          resq 1
    ; ... many more function pointers
    .LoadImage:         resq 1
    .StartImage:        resq 1
    .Exit:              resq 1
    ; ... additional functions
endstruc

; UEFI entry point
efi_main:
    ; RCX = ImageHandle
    ; RDX = SystemTable pointer
    
    mov [ImageHandle], rcx
    mov [SystemTable], rdx
    
    ; Get console output protocol
    mov rax, [rdx + EFI_SYSTEM_TABLE.ConOut]
    mov [ConOut], rax
    
    ; Clear screen
    mov rcx, [ConOut]
    mov rax, [rcx + 48]     ; ClearScreen function
    call rax
    
    ; Print message
    lea rdx, [bootloader_msg]
    mov rcx, [ConOut]
    mov rax, [rcx + 8]      ; OutputString function
    call rax
    
    ; Get boot services
    mov rax, [SystemTable]
    mov rax, [rax + EFI_SYSTEM_TABLE.BootServices]
    mov [BootServices], rax
    
    ; Get memory map
    call get_memory_map
    
    ; Load kernel image
    call load_uefi_kernel
    
    ; Exit boot services
    call exit_boot_services
    
    ; Jump to kernel
    jmp [KernelEntry]

; Get UEFI memory map
get_memory_map:
    sub rsp, 40             ; Shadow space + alignment
    
    ; Get memory map size
    lea rcx, [MemoryMapSize]
    lea rdx, [MemoryMap]
    lea r8, [MapKey]
    lea r9, [DescriptorSize]
    lea rax, [DescriptorVersion]
    mov [rsp + 32], rax
    
    mov rax, [BootServices]
    mov rax, [rax + EFI_BOOT_SERVICES.GetMemoryMap]
    call rax
    
    test rax, rax
    jnz .allocate_buffer
    
    add rsp, 40
    ret

.allocate_buffer:
    ; Allocate buffer for memory map
    mov rcx, [MemoryMapSize]
    add rcx, 2048           ; Extra space for allocations
    mov [MemoryMapSize], rcx
    
    ; AllocatePool
    mov rdx, rcx
    xor rcx, rcx            ; EfiLoaderData
    lea r8, [MemoryMap]
    mov rax, [BootServices]
    mov rax, [rax + EFI_BOOT_SERVICES.AllocatePool]
    call rax
    
    ; Get memory map again
    lea rcx, [MemoryMapSize]
    mov rdx, [MemoryMap]
    lea r8, [MapKey]
    lea r9, [DescriptorSize]
    lea rax, [DescriptorVersion]
    mov [rsp + 32], rax
    
    mov rax, [BootServices]
    mov rax, [rax + EFI_BOOT_SERVICES.GetMemoryMap]
    call rax
    
    add rsp, 40
    ret

; Load kernel from disk
load_uefi_kernel:
    sub rsp, 40
    
    ; Open volume (simplified - real implementation needs more)
    ; This assumes kernel is on the same volume as bootloader
    
    ; Read kernel file
    lea rdx, [kernel_filename]
    mov rcx, [RootDirectory]
    lea r8, [FileHandle]
    mov r9, 1               ; EFI_FILE_MODE_READ
    mov rax, [rcx]
    mov rax, [rax + 8]      ; Open function
    call rax
    
    test rax, rax
    jnz .error
    
    ; Get file size
    mov rcx, [FileHandle]
    lea rdx, [FileInfo]
    lea r8, [FileInfoSize]
    lea r9, [FileInfoGuid]
    mov rax, [rcx]
    mov rax, [rax + 64]     ; GetInfo function
    call rax
    
    ; Allocate memory for kernel
    mov rcx, 2              ; EfiLoaderCode
    mov rdx, [FileInfo + 8] ; File size
    shr rdx, 12             ; Convert to pages
    inc rdx
    lea r8, [KernelBuffer]
    mov rax, [BootServices]
    mov rax, [rax + EFI_BOOT_SERVICES.AllocatePages]
    call rax
    
    ; Read file
    lea rdx, [FileSize]
    mov rcx, [FileHandle]
    mov r8, [KernelBuffer]
    mov rax, [rcx]
    mov rax, [rax + 32]     ; Read function
    call rax
    
    ; Close file
    mov rcx, [FileHandle]
    mov rax, [rcx]
    mov rax, [rax + 16]     ; Close function
    call rax
    
    ; Parse kernel and set entry point
    mov rax, [KernelBuffer]
    ; Parse PE/COFF or ELF header
    mov rax, [rax + 40]     ; Simplified - get entry point from PE
    mov [KernelEntry], rax
    
.error:
    add rsp, 40
    ret

; Exit boot services
exit_boot_services:
    sub rsp, 40
    
    mov rcx, [ImageHandle]
    mov rdx, [MapKey]
    mov rax, [BootServices]
    mov rax, [rax + EFI_BOOT_SERVICES.ExitBootServices]
    call rax
    
    test rax, rax
    jz .success
    
    ; Map key changed, get memory map again
    call get_memory_map
    jmp exit_boot_services
    
.success:
    add rsp, 40
    ret

; Data section
section .data
bootloader_msg: dw 'U', 0, 'E', 0, 'F', 0, 'I', 0, ' ', 0
                dw 'B', 0, 'o', 0, 'o', 0, 't', 0, 'l', 0, 'o', 0, 'a', 0, 'd', 0, 'e', 0, 'r', 0
                dw 0x0D, 0, 0x0A, 0, 0

kernel_filename: dw 'k', 0, 'e', 0, 'r', 0, 'n', 0, 'e', 0, 'l', 0, '.', 0, 'e', 0, 'l', 0, 'f', 0, 0

section .bss
ImageHandle:        resq 1
SystemTable:        resq 1
BootServices:       resq 1
ConOut:             resq 1
MemoryMapSize:      resq 1
MemoryMap:          resq 1
MapKey:             resq 1
DescriptorSize:     resq 1
DescriptorVersion:  resd 1
FileHandle:         resq 1
FileInfoSize:       resq 1
FileInfo:           resb 512
KernelBuffer:       resq 1
KernelEntry:        resq 1
FileSize:           resq 1
RootDirectory:      resq 1

_text_end:
_image_end:
```

## Custom Boot Protocol

For specialized systems, you may define a custom protocol:

```nasm
; Custom boot protocol structure
struc BootInfo
    .magic:             resd 1      ; 0xB007CAFE
    .version:           resd 1      ; Protocol version
    .mem_lower:         resd 1      ; Lower memory (KB)
    .mem_upper:         resd 1      ; Upper memory (KB)
    .mem_map_addr:      resd 1      ; Memory map address
    .mem_map_length:    resd 1      ; Memory map length
    .cmdline:           resd 1      ; Command line pointer
    .kernel_start:      resd 1      ; Kernel start address
    .kernel_size:       resd 1      ; Kernel size
    .initrd_start:      resd 1      ; Initial RAM disk start
    .initrd_size:       resd 1      ; Initial RAM disk size
    .framebuffer_addr:  resq 1      ; Framebuffer address
    .framebuffer_width: resd 1      ; Width in pixels
    .framebuffer_height: resd 1     ; Height in pixels
    .framebuffer_pitch: resd 1      ; Bytes per line
    .framebuffer_bpp:   resb 1      ; Bits per pixel
    .framebuffer_type:  resb 1      ; Color type
    .acpi_rsdp:         resq 1      ; ACPI RSDP pointer
    .reserved:          resb 32     ; Reserved for future use
endstruc

BOOT_MAGIC equ 0xB007CAFE
BOOT_VERSION equ 1

prepare_boot_info:
    mov edi, 0xA000         ; Boot info at 0xA000
    
    ; Magic and version
    mov dword [edi + BootInfo.magic], BOOT_MAGIC
    mov dword [edi + BootInfo.version], BOOT_VERSION
    
    ; Memory information
    mov dword [edi + BootInfo.mem_lower], 640
    mov eax, [extended_memory_kb]
    mov [edi + BootInfo.mem_upper], eax
    mov dword [edi + BootInfo.mem_map_addr], 0x8000
    mov eax, [memory_map_size]
    mov [edi + BootInfo.mem_map_addr], eax
    
    ; Command line
    mov dword [edi + BootInfo.cmdline], kernel_cmdline
    
    ; Kernel location
    mov dword [edi + BootInfo.kernel_start], 0x100000
    mov eax, [kernel_size]
    mov [edi + BootInfo.kernel_size], eax
    
    ; Initrd (if present)
    cmp byte [has_initrd], 0
    je .no_initrd
    mov dword [edi + BootInfo.initrd_start], 0x200000
    mov eax, [initrd_size]
    mov [edi + BootInfo.initrd_size], eax
    jmp .check_framebuffer
    
.no_initrd:
    mov dword [edi + BootInfo.initrd_start], 0
    mov dword [edi + BootInfo.initrd_size], 0
    
.check_framebuffer:
    ; Set up framebuffer if available
    cmp byte [has_vbe], 0
    je .no_framebuffer
    
    mov eax, [vbe_framebuffer]
    mov [edi + BootInfo.framebuffer_addr], eax
    mov eax, [vbe_width]
    mov [edi + BootInfo.framebuffer_width], eax
    mov eax, [vbe_height]
    mov [edi + BootInfo.framebuffer_height], eax
    mov eax, [vbe_pitch]
    mov [edi + BootInfo.framebuffer_pitch], eax
    mov al, [vbe_bpp]
    mov [edi + BootInfo.framebuffer_bpp], al
    
.no_framebuffer:
    ; Find ACPI RSDP
    call find_rsdp
    mov [edi + BootInfo.acpi_rsdp], eax
    
    ret

; Find ACPI Root System Description Pointer
find_rsdp:
    ; Search EBDA
    mov ax, [0x40E]
    shl eax, 4
    call search_rsdp_region
    test eax, eax
    jnz .found
    
    ; Search main BIOS area (0xE0000-0xFFFFF)
    mov eax, 0xE0000
    call search_rsdp_region
    
.found:
    ret

search_rsdp_region:
    ; EAX = start address
    mov ecx, 0x20000        ; Search 128 KB
    
.search_loop:
    cmp qword [eax], 0x2052545020445352  ; 'RSD PTR '
    je .verify_checksum
    
    add eax, 16             ; RSDP aligned on 16-byte boundary
    sub ecx, 16
    jnz .search_loop
    
    xor eax, eax
    ret

.verify_checksum:
    push eax
    push ecx
    
    mov ecx, 20             ; RSDP 1.0 size
    xor edx, edx
    
.checksum_loop:
    add dl, [eax]
    inc eax
    loop .checksum_loop
    
    test dl, dl
    pop ecx
    pop eax
    jz .valid
    
    add eax, 16
    sub ecx, 16
    jmp .search_loop
    
.valid:
    ret

; Kernel entry with custom protocol
jump_to_custom_kernel:
    call prepare_boot_info
    
    ; EDI = boot info structure pointer
    mov edi, 0xA000
    
    ; Jump to kernel
    jmp [kernel_entry]
```

## Chainloading

Bootloaders can chainload other bootloaders or operating systems:

```nasm
; Chainload another bootloader
chainload:
    ; Load target boot sector
    mov ax, 0x7C0
    mov es, ax
    xor bx, bx
    
    mov ah, 0x02
    mov al, 1               ; Read 1 sector
    mov ch, 0               ; Cylinder 0
    mov cl, 1               ; Sector 1
    mov dh, 0               ; Head 0
    mov dl, [target_drive]  ; Target drive
    int 0x13
    jc .error
    
    ; Verify boot signature
    cmp word [es:0x1FE], 0xAA55
    jne .error
    
    ; Set DL to boot drive
    mov dl, [target_drive]
    
    ; Jump to loaded boot sector
    jmp 0x0000:0x7C00

.error:
    ret

; Chainload Windows bootloader (simplified)
chainload_windows:
    ; Load Windows boot sector from active partition
    ; Find active partition in MBR partition table
    mov si, 0x7DBE          ; Partition table at 0x7DBE
    mov cx, 4               ; 4 partition entries
    
.find_active:
    test byte [si], 0x80    ; Check bootable flag
    jnz .found_active
    add si, 16              ; Next entry
    loop .find_active
    jmp .error
    
.found_active:
    ; Get partition start LBA
    mov eax, [si + 8]
    mov [partition_lba], eax
    
    ; Load partition boot sector
    mov ax, 0x7C0
    mov es, ax
    xor bx, bx
    
    ; Use LBA read
    mov ah, 0x42
    mov dl, 0x80
    mov si, dap_packet
    int 0x13
    jc .error
    
    ; Jump to Windows bootloader
    mov dl, 0x80
    jmp 0x0000:0x7C00

.error:
    ret

dap_packet:
    db 0x10                 ; Size
    db 0                    ; Reserved
    dw 1                    ; Sectors to read
    dw 0x7C00               ; Offset
    dw 0                    ; Segment
    dq 0                    ; LBA (filled at runtime)
```

**Key Points:**

- Bootloaders execute in real mode starting at physical address 0x7C00 with only 512 bytes in the MBR
- Real mode initialization requires setting up segment registers, stack, enabling A20 line, and querying memory maps via BIOS interrupts
- Multi-stage loading allows bootloaders to overcome the 512-byte limit by loading additional stages from disk using INT 0x13 services
- Before executing 32-bit or 64-bit kernels, bootloaders must transition from real mode to protected mode or long mode, which involves setting up GDT, page tables (for long mode), and switching CPU modes
- Modern boot protocols like Multiboot, Multiboot2, Linux Boot Protocol, and UEFI provide standardized interfaces between bootloaders and kernels, specifying how to pass memory maps, command lines, and system information
- Chainloading enables bootloaders to load and execute other bootloaders or operating systems by loading their boot sector and transferring control

---

# Bare-Metal Programming

Bare-metal programming refers to writing code that runs directly on hardware without an operating system layer. In x86 assembly, this involves complete control over the processor, memory, and peripheral devices from the moment the system powers on.

## Hardware Initialization

Hardware initialization is the foundational process that occurs when a system boots. The CPU begins execution at a predefined address (0xFFFFFFF0 in real mode for x86), which contains the BIOS or UEFI firmware code.

**BIOS Boot Process:** The Basic Input/Output System performs Power-On Self-Test (POST), initializes essential hardware components, and loads the bootloader from the Master Boot Record (MBR) located in the first sector (512 bytes) of the boot device.

**Initial CPU State:** At power-on, the x86 CPU starts in 16-bit real mode with specific register values:

- CS:IP = 0xF000:0xFFF0 (pointing to BIOS ROM)
- All segment registers initialized
- Interrupts disabled
- A20 line disabled (limiting addressable memory to 1MB)

**Critical Initialization Steps:**

Setting up the Global Descriptor Table (GDT) for protected mode operation:

```asm
lgdt [gdt_descriptor]    ; Load GDT register
mov eax, cr0
or eax, 1                ; Set PE (Protection Enable) bit
mov cr0, eax             ; Enter protected mode
jmp CODE_SEG:protected_mode
```

Configuring the Interrupt Descriptor Table (IDT):

```asm
lidt [idt_descriptor]    ; Load IDT register
sti                      ; Enable interrupts
```

Stack initialization:

```asm
mov esp, STACK_TOP       ; Set stack pointer to designated memory region
mov ebp, esp             ; Initialize base pointer
```

Enabling the A20 line to access memory beyond 1MB:

```asm
in al, 0x92              ; Read from System Control Port A
or al, 2                 ; Set bit 1
out 0x92, al             ; Enable A20 through fast gate
```

## Direct Hardware Access

Direct hardware access allows programs to communicate with devices by reading and writing to specific memory locations or I/O ports without OS mediation.

**Privilege Levels:** x86 processors enforce privilege rings (0-3), where ring 0 has full hardware access. Bare-metal code typically runs in ring 0, allowing unrestricted device manipulation.

**Memory Segments and Addressing:** In real mode, physical addresses are calculated using segment:offset notation: Physical Address = (Segment × 16) + Offset

**Example:** Accessing video memory at 0xB8000 (VGA text mode buffer):

```asm
mov ax, 0xB800
mov es, ax               ; ES segment points to video memory
mov di, 0                ; Offset within segment
mov byte [es:di], 'A'    ; Write character
mov byte [es:di+1], 0x0F ; Write attribute (white on black)
```

**Protected Mode Segmentation:** In 32-bit protected mode, segmentation uses descriptors rather than simple segment values:

```asm
mov ax, DATA_SEG         ; Load data segment selector
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
```

**Control Registers Access:** Control registers (CR0, CR3, CR4) manage CPU operating modes and paging:

```asm
mov eax, cr0             ; Read control register
or eax, 0x80000001       ; Enable paging (PG) and protection (PE)
mov cr0, eax             ; Write back modified value
```

## Port I/O Instructions

Port I/O provides a separate address space for device communication distinct from memory addressing. X86 processors support 65,536 port addresses (0x0000-0xFFFF).

**IN Instruction - Reading from Ports:**

Byte input:

```asm
in al, 0x60              ; Read byte from keyboard data port into AL
```

Word input:

```asm
in ax, 0x3D4             ; Read word from VGA index port into AX
```

Indirect port addressing using DX:

```asm
mov dx, 0x1F0            ; Port address for IDE primary data register
in al, dx                ; Read byte from port specified in DX
```

**OUT Instruction - Writing to Ports:**

Byte output:

```asm
mov al, 0x20             ; End-of-interrupt command
out 0x20, al             ; Send to PIC command port
```

Word output:

```asm
mov ax, 0x3456
out 0x3C0, ax            ; Write word to VGA attribute controller
```

Indirect port addressing:

```asm
mov dx, 0x3F8            ; COM1 serial port base address
mov al, 'H'
out dx, al               ; Transmit character
```

**INS/OUTS Instructions - Block I/O:**

Input string of bytes:

```asm
mov dx, 0x1F0            ; IDE data port
mov edi, buffer          ; Destination memory address
mov ecx, 256             ; Count (256 words = 512 bytes per sector)
rep insw                 ; Read multiple words from port
```

Output string:

```asm
mov dx, 0x3F8            ; Serial port
mov esi, data_buffer     ; Source memory address
mov ecx, 128
rep outsb                ; Write multiple bytes to port
```

**Common Port Addresses:**

Programmable Interrupt Controller (PIC):

```asm
PIC1_COMMAND equ 0x20
PIC1_DATA    equ 0x21
PIC2_COMMAND equ 0xA0
PIC2_DATA    equ 0xA1

; Remap PIC interrupts
mov al, 0x11             ; ICW1: Initialize command
out PIC1_COMMAND, al
out PIC2_COMMAND, al

mov al, 0x20             ; ICW2: Master PIC vector offset
out PIC1_DATA, al
mov al, 0x28             ; ICW2: Slave PIC vector offset
out PIC2_DATA, al
```

Programmable Interval Timer (PIT):

```asm
PIT_CHANNEL0 equ 0x40
PIT_COMMAND  equ 0x43

mov al, 0x36             ; Channel 0, lobyte/hibyte, rate generator
out PIT_COMMAND, al
mov ax, 11931            ; Divisor for ~100Hz (1193182 / 100)
out PIT_CHANNEL0, al     ; Low byte
mov al, ah
out PIT_CHANNEL0, al     ; High byte
```

## Memory-Mapped I/O

Memory-mapped I/O treats device registers as memory locations within the processor's address space. Devices respond to standard memory read/write operations instead of specialized port I/O instructions.

**Address Space Allocation:** The x86 architecture reserves portions of physical memory for device mapping. Common ranges include:

- 0xA0000-0xBFFFF: VGA graphics memory
- 0xB8000-0xBFFFF: VGA text mode buffer
- 0xF0000-0xFFFFF: System BIOS ROM
- 0xFEC00000-0xFEE00000: APIC registers (in modern systems)

**VGA Text Mode Buffer:**

The VGA text buffer at 0xB8000 provides 80×25 character display. Each character occupies 2 bytes: ASCII value and attribute byte.

```asm
section .text
bits 32

write_string:
    mov esi, message         ; Source string
    mov edi, 0xB8000         ; VGA buffer start
    mov ah, 0x0F             ; Attribute: white on black
    
.loop:
    lodsb                    ; Load byte from [ESI] into AL, increment ESI
    test al, al              ; Check for null terminator
    jz .done
    
    stosw                    ; Store AX (char + attribute) at [EDI], increment by 2
    jmp .loop
    
.done:
    ret

message: db 'Bare-Metal Programming', 0
```

**VGA Graphics Mode (Mode 13h - 320×200×256):**

Direct pixel manipulation at 0xA0000:

```asm
; Set VGA mode 13h
mov ax, 0x13
int 0x10                 ; BIOS video interrupt (if available)

; Draw pixel at coordinates (x, y)
draw_pixel:
    mov ax, 0xA000
    mov es, ax
    
    ; Calculate offset: y * 320 + x
    mov ax, [y_coord]
    mov bx, 320
    mul bx
    add ax, [x_coord]
    mov di, ax
    
    mov al, [color]          ; Color index (0-255)
    mov [es:di], al
    ret

x_coord: dw 100
y_coord: dw 50
color: db 0x0F               ; Bright white
```

**Framebuffer Access (Linear Framebuffer):**

Modern graphics systems use linear framebuffers where pixel data is contiguous:

```asm
; 32-bit color framebuffer (ARGB format)
; Assuming framebuffer at 0xFD000000 (example address)

set_pixel_32bit:
    mov eax, [y_coord]
    mov ebx, [screen_width]
    mul ebx                  ; EAX = y * width
    add eax, [x_coord]       ; EAX = y * width + x
    shl eax, 2               ; Multiply by 4 (bytes per pixel)
    
    mov edi, FRAMEBUFFER_BASE
    add edi, eax
    
    mov eax, [pixel_color]   ; 0xAARRGGBB format
    mov [edi], eax
    ret

FRAMEBUFFER_BASE equ 0xFD000000
screen_width: dd 1024
pixel_color: dd 0xFF00FF00  ; Green
```

**Memory-Mapped Device Registers:**

Serial UART through memory-mapped registers (example for embedded systems):

```asm
UART_BASE    equ 0x10000000
UART_DATA    equ UART_BASE + 0x00
UART_STATUS  equ UART_BASE + 0x04
UART_CONTROL equ UART_BASE + 0x08

uart_init:
    ; Configure UART control register
    mov dword [UART_CONTROL], 0x03  ; 8N1, enable TX/RX
    ret

uart_send_byte:
    ; Wait until transmit buffer is empty
.wait:
    mov eax, [UART_STATUS]
    test eax, 0x20               ; Check TX empty bit
    jz .wait
    
    ; Send byte
    mov al, [byte_to_send]
    mov [UART_DATA], al
    ret

byte_to_send: db 0
```

**PCI Configuration Space:**

PCI devices are accessed through memory-mapped configuration space:

```asm
PCI_CONFIG_ADDRESS equ 0xCF8
PCI_CONFIG_DATA    equ 0xCFC

; Read PCI configuration register
; Bus in BH, Device in BL[7:3], Function in BL[2:0], Register in CL
read_pci_config:
    mov eax, 0x80000000      ; Enable bit
    shl ebx, 8               ; Position bus/dev/func
    or eax, ebx
    and cl, 0xFC             ; Align register to dword
    or al, cl
    
    out PCI_CONFIG_ADDRESS, eax  ; Select configuration register
    in eax, PCI_CONFIG_DATA      ; Read value
    ret
```

**Cache Coherency Considerations:**

Memory-mapped I/O regions often require cache control to ensure data consistency:

```asm
; Disable caching for MMIO region using MTRRs (simplified)
mov ecx, 0x200           ; IA32_MTRR_PHYSBASE0
rdmsr                    ; Read MTRR
and eax, 0xFFFFF000      ; Clear lower bits
or eax, 0x00             ; Set to uncacheable (UC)
wrmsr                    ; Write back

; Or use page table attributes (PAT) in paging structures
; Set PCD (Page-level Cache Disable) bit in page table entry
or dword [page_table_entry], 0x10
```

**Example:** Complete bare-metal keyboard driver using memory-mapped and port I/O:

```asm
bits 32

KEYBOARD_DATA    equ 0x60
KEYBOARD_STATUS  equ 0x64
VIDEO_MEMORY     equ 0xB8000

keyboard_handler:
    pushad
    
    ; Read keyboard status
    in al, KEYBOARD_STATUS
    test al, 1               ; Check output buffer status
    jz .done
    
    ; Read scan code
    in al, KEYBOARD_DATA
    
    ; Convert to ASCII (simplified)
    cmp al, 0x80             ; Check if key release
    jae .done
    
    ; Display on screen using memory-mapped video
    mov edi, VIDEO_MEMORY
    mov ah, 0x0F             ; Attribute
    mov [edi], ax
    
    ; Send EOI to PIC
    mov al, 0x20
    out 0x20, al
    
.done:
    popad
    iret
```

**Key Points:**

Memory-mapped I/O integrates device access into the normal memory address space, allowing standard MOV instructions instead of IN/OUT operations. This approach simplifies programming but requires careful consideration of cache behavior, memory ordering, and access synchronization.

The choice between port I/O and memory-mapped I/O depends on the hardware architecture. Legacy x86 devices (keyboard, serial ports, PIC) typically use port I/O, while modern devices (PCI/PCIe, graphics cards, network controllers) primarily use memory-mapped registers.

[Inference]: Specific device memory addresses vary by system configuration and should be determined through hardware documentation or firmware tables (ACPI, PCI enumeration).

**Related Topics:** Protected mode transition, interrupt handling, DMA programming, APIC/IOAPIC configuration, UEFI boot process, page table management for MMIO regions.

----

## Hardware Abstraction and Direct Access

Bare-metal code communicates with hardware through memory-mapped I/O (MMIO) and port-mapped I/O. In x86 systems, devices expose registers at specific memory addresses or I/O port numbers. The programmer must understand the hardware documentation to know which addresses control which functions.

Memory-mapped devices appear as normal memory locations. Writing to these addresses sends commands to hardware, while reading retrieves status information. Port-mapped I/O uses special `IN` and `OUT` instructions in x86 assembly to access device ports.

**Example** of port I/O in x86 assembly:

```nasm
; Read from port 0x60 (keyboard data port)
in al, 0x60          ; Read byte into AL register

; Write to port 0x3F8 (COM1 serial port)
mov al, 'A'
out 0x3F8, al        ; Send byte from AL to port
```

**Example** of memory-mapped I/O:

```nasm
; Assuming VGA text buffer at 0xB8000
mov edi, 0xB8000     ; Point to video memory
mov byte [edi], 'H'  ; Character
mov byte [edi+1], 0x0F ; Attribute (white on black)
```

Hardware registers typically fall into categories: control registers (configure device behavior), status registers (report device state), and data registers (transfer information). Reading documentation sheets (datasheets) is critical for understanding bit layouts and access restrictions.

## Device Drivers Basics

A device driver is bare-metal code that manages hardware devices by providing initialization routines, I/O operations, and error handling. Drivers abstract hardware complexity, presenting a consistent interface to higher-level code.

### Driver Architecture

Device drivers typically contain several components: initialization code that configures the hardware at startup, read/write functions for data transfer, interrupt handlers for asynchronous events, and control functions for device-specific operations.

The initialization sequence generally follows this pattern: reset the device, configure operational parameters, enable necessary interrupts, and verify the device is ready. Each hardware device has specific initialization requirements documented in its technical manual.

**Example** initialization for a serial UART (16550):

```nasm
; Initialize COM1 (base port 0x3F8)
init_serial:
    ; Disable interrupts
    mov dx, 0x3F9        ; Interrupt Enable Register
    xor al, al
    out dx, al
    
    ; Set baud rate divisor (115200 baud)
    mov dx, 0x3FB        ; Line Control Register
    mov al, 0x80         ; Enable DLAB (Divisor Latch Access)
    out dx, al
    
    mov dx, 0x3F8        ; Divisor Latch Low
    mov al, 0x01         ; Divisor = 1 (115200 baud)
    out dx, al
    
    mov dx, 0x3F9        ; Divisor Latch High
    xor al, al
    out dx, al
    
    ; Configure: 8 bits, no parity, 1 stop bit
    mov dx, 0x3FB        ; Line Control Register
    mov al, 0x03         ; 8-N-1
    out dx, al
    
    ; Enable FIFO, clear buffers
    mov dx, 0x3FA        ; FIFO Control Register
    mov al, 0xC7         ; Enable FIFO, clear, 14-byte threshold
    out dx, al
    
    ret
```

### Polling vs Interrupt-Driven I/O

Drivers can use polling or interrupt-driven approaches for I/O operations. Polling continuously checks device status registers until an operation completes. This is simple but wastes CPU cycles and introduces unpredictable latency.

**Example** polling for serial transmission ready:

```nasm
serial_write_byte:
    ; Input: AL = byte to send
    push dx
    mov dx, 0x3FD        ; Line Status Register
.wait:
    in al, dx
    test al, 0x20        ; Check Transmit Holding Register Empty
    jz .wait             ; Loop until ready
    
    mov dx, 0x3F8        ; Transmitter Holding Buffer
    pop dx
    out dx, al           ; Send byte
    ret
```

Interrupt-driven I/O allows the CPU to perform other work while waiting for device operations. The device signals completion through hardware interrupts, triggering an interrupt handler that processes the event.

### Device State Management

Drivers must maintain device state information including operational mode, pending operations, error conditions, and buffer management. This state is typically stored in memory structures that the driver accesses during operations.

Critical sections of driver code that access shared device registers or state must be protected from concurrent access, especially in interrupt handlers. Disabling interrupts temporarily or using atomic operations prevents race conditions.

**Example** of critical section protection:

```nasm
device_operation:
    pushf                ; Save flags
    cli                  ; Disable interrupts
    
    ; Critical section - access device registers
    mov dx, 0x3F8
    in al, dx
    ; ... process data ...
    
    popf                 ; Restore interrupts state
    ret
```

## Interrupt Controllers

Interrupt controllers manage hardware interrupt signals, routing them to the CPU and providing mechanisms for priority handling, masking, and acknowledgment. In x86 systems, the Programmable Interrupt Controller (PIC) or Advanced Programmable Interrupt Controller (APIC) handles this functionality.

### 8259 PIC Architecture

The legacy 8259 PIC was the standard interrupt controller for x86 systems. Modern systems use it in compatibility mode or emulation. A typical PC configuration uses two 8259 chips in cascade: a master handling IRQs 0-7 and a slave handling IRQs 8-15, with the slave connected to IRQ2 of the master.

Each PIC has command and data ports. The master PIC uses ports 0x20 (command) and 0x21 (data), while the slave uses 0xA0 (command) and 0xA1 (data).

**Example** PIC initialization (ICW sequence):

```nasm
init_pic:
    ; Start initialization sequence (ICW1)
    mov al, 0x11         ; ICW1: Initialize + ICW4 needed
    out 0x20, al         ; Master PIC command
    out 0xA0, al         ; Slave PIC command
    
    ; ICW2: Set interrupt vector offsets
    mov al, 0x20         ; Master PIC: IRQs 0-7 → INT 0x20-0x27
    out 0x21, al
    mov al, 0x28         ; Slave PIC: IRQs 8-15 → INT 0x28-0x2F
    out 0xA1, al
    
    ; ICW3: Set cascade configuration
    mov al, 0x04         ; Master: slave on IRQ2
    out 0x21, al
    mov al, 0x02         ; Slave: cascade identity
    out 0xA1, al
    
    ; ICW4: Set mode
    mov al, 0x01         ; 8086 mode
    out 0x21, al
    out 0xA1, al
    
    ; Mask all interrupts initially
    mov al, 0xFF
    out 0x21, al         ; Master mask
    out 0xA1, al         ; Slave mask
    ret
```

### Interrupt Masking and Priority

The PIC allows selective enabling/disabling of interrupt lines through mask registers. Setting a bit in the mask register disables the corresponding IRQ. Priority is fixed: IRQ0 has highest priority, descending to IRQ15.

**Example** enabling specific IRQ:

```nasm
enable_irq:
    ; Input: AL = IRQ number (0-15)
    cmp al, 8
    jae .slave           ; IRQ 8-15 use slave PIC
    
.master:
    mov cl, al
    mov ah, 1
    shl ah, cl           ; Create mask bit
    not ah               ; Invert for clearing
    
    in al, 0x21          ; Read current mask
    and al, ah           ; Clear bit to enable
    out 0x21, al
    ret
    
.slave:
    sub al, 8
    mov cl, al
    mov ah, 1
    shl ah, cl
    not ah
    
    in al, 0xA1
    and al, ah
    out 0xA1, al
    
    ; Also enable IRQ2 on master (cascade)
    in al, 0x21
    and al, 0xFB         ; Clear bit 2
    out 0x21, al
    ret
```

### End-of-Interrupt (EOI) Signaling

After servicing an interrupt, the handler must send an End-of-Interrupt signal to the PIC, informing it that processing is complete. This allows the PIC to process additional interrupts. For slave PIC interrupts (IRQ 8-15), EOI must be sent to both slave and master.

**Example** EOI handling:

```nasm
send_eoi:
    ; Input: AL = IRQ number
    cmp al, 8
    jae .slave
    
.master:
    mov al, 0x20         ; EOI command
    out 0x20, al         ; Send to master
    ret
    
.slave:
    mov al, 0x20
    out 0xA0, al         ; Send to slave
    out 0x20, al         ; Send to master
    ret
```

### APIC Architecture

Modern x86 systems use the Advanced Programmable Interrupt Controller, which provides more interrupt lines, better priority handling, and multiprocessor support. The Local APIC (LAPIC) is integrated into each CPU core, while the I/O APIC handles external device interrupts.

APIC uses memory-mapped registers instead of I/O ports. The default LAPIC base address is 0xFEE00000. APIC configuration requires more complex setup than PIC but offers features like inter-processor interrupts (IPIs), per-CPU timers, and sophisticated routing.

**Example** LAPIC EOI (simpler than PIC):

```nasm
; LAPIC EOI register at offset 0xB0
lapic_eoi:
    mov dword [0xFEE000B0], 0  ; Write any value to EOI register
    ret
```

### Interrupt Descriptor Table (IDT)

The IDT is a data structure that maps interrupt vectors to handler addresses. Each entry is 8 bytes (32-bit mode) or 16 bytes (64-bit mode) and contains the handler segment selector, offset, and flags.

**Example** IDT entry structure and setup (32-bit):

```nasm
struc IDT_Entry
    .offset_low  resw 1   ; Handler offset bits 0-15
    .selector    resw 1   ; Code segment selector
    .zero        resb 1   ; Reserved
    .type_attr   resb 1   ; Type and attributes
    .offset_high resw 1   ; Handler offset bits 16-31
endstruc

set_idt_entry:
    ; Input: EBX = IDT entry address, EDX = handler address
    ; ECX = selector, AL = type/attributes
    
    mov word [ebx + IDT_Entry.offset_low], dx
    shr edx, 16
    mov word [ebx + IDT_Entry.offset_high], dx
    
    mov word [ebx + IDT_Entry.selector], cx
    mov byte [ebx + IDT_Entry.zero], 0
    mov byte [ebx + IDT_Entry.type_attr], al
    ret

load_idt:
    ; IDT descriptor structure
    idt_descriptor:
        dw idt_end - idt_start - 1  ; Limit
        dd idt_start                 ; Base address
    
    lidt [idt_descriptor]            ; Load IDT
    ret
```

### Interrupt Handler Implementation

Interrupt handlers must preserve CPU state, process the interrupt quickly, send EOI, and restore state before returning. Handlers use the `IRET` instruction instead of `RET` to restore flags and switch privilege levels if necessary.

**Example** complete interrupt handler:

```nasm
global keyboard_handler
keyboard_handler:
    ; Save all registers
    pushad
    push ds
    push es
    push fs
    push gs
    
    ; Load kernel data segment
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    
    ; Read scan code from keyboard port
    in al, 0x60
    
    ; Process scan code (store in buffer, etc.)
    call process_scancode
    
    ; Send EOI to PIC
    mov al, 0x20
    out 0x20, al
    
    ; Restore registers
    pop gs
    pop fs
    pop es
    pop ds
    popad
    
    iret                 ; Return from interrupt
```

## DMA Operations

Direct Memory Access allows devices to transfer data to/from memory without CPU involvement, freeing the processor for other tasks. The DMA controller manages these transfers, handling address generation and byte counting.

### DMA Controller Architecture

The classic PC DMA controller (8237) provides 8 DMA channels, though modern systems use more sophisticated controllers. Channels 0-3 are 8-bit transfers, and channels 4-7 are 16-bit transfers. Channel 4 is typically unavailable as it cascades the two controller chips.

Each DMA channel has associated registers for memory address, transfer count, and mode. The controller operates in different modes including single transfer, block transfer, and demand transfer.

### DMA Transfer Setup

Setting up a DMA transfer involves several steps: disable the channel, set the mode, write the address and count, enable the channel, and configure the device to request DMA. The transfer then proceeds autonomously.

**Example** DMA channel setup:

```nasm
setup_dma_channel:
    ; Setup DMA channel 2 for floppy disk read
    ; Transfer 512 bytes to memory at 0x10000
    
    ; Disable DMA channel 2
    mov al, 0x06         ; Mask channel 2 (set bit 2 + 0x04)
    out 0x0A, al         ; Single mask register
    
    ; Reset flip-flop
    xor al, al
    out 0x0C, al         ; Flip-flop reset
    
    ; Set mode: read, single transfer, channel 2
    mov al, 0x46         ; 01000110b
    out 0x0B, al         ; Mode register
    
    ; Write address (0x10000)
    ; DMA addresses are in page:offset format
    ; Address 0x10000 = page 0x01, offset 0x0000
    
    xor al, al           ; Low byte of offset
    out 0x04, al         ; Channel 2 address register
    xor al, al           ; High byte of offset
    out 0x04, al
    
    mov al, 0x01         ; Page number
    out 0x81, al         ; Channel 2 page register
    
    ; Write count (512 bytes = 511 in count register)
    mov al, 0xFF         ; Low byte (511 & 0xFF)
    out 0x05, al         ; Channel 2 count register
    mov al, 0x01         ; High byte (511 >> 8)
    out 0x05, al
    
    ; Enable DMA channel 2
    mov al, 0x02         ; Unmask channel 2
    out 0x0A, al
    ret
```

### DMA Modes and Transfer Types

The DMA controller supports multiple transfer modes:

**Single Transfer Mode:** Transfers one byte/word per DMA request, releasing the bus after each transfer. This allows CPU access between transfers.

**Block Transfer Mode:** Transfers the entire block continuously until the count reaches zero. The CPU is locked out during the transfer, but it's faster.

**Demand Transfer Mode:** Continues transferring while the device asserts the DMA request signal. Stops when the device deasserts the signal or the count expires.

**Cascade Mode:** Used to connect additional DMA controllers, extending the number of available channels.

### Memory Constraints and Page Boundaries

Classic DMA has a critical limitation: transfers cannot cross 64KB boundaries for 8-bit channels or 128KB boundaries for 16-bit channels. This is due to the separate page and offset registers. Buffer addresses must be carefully chosen to avoid boundary crossing.

**Example** checking for DMA boundary issues:

```nasm
check_dma_boundary:
    ; Input: ESI = buffer address, ECX = transfer size
    ; Output: Zero flag set if safe, clear if crosses boundary
    
    mov eax, esi
    add eax, ecx         ; End address
    xor esi, eax
    test esi, 0x10000    ; Check if 64KB boundary crossed
    ret
```

### Bus Mastering DMA

Modern devices often use bus mastering DMA, where the device itself acts as a bus master and performs transfers without the system DMA controller. This provides better performance, removes boundary restrictions, and supports scatter-gather operations.

Bus master devices access memory directly using physical addresses provided by the driver. The driver allocates DMA-capable memory buffers and programs the device registers with buffer addresses, sizes, and control flags.

**Example** programming a bus master device (conceptual):

```nasm
setup_bus_master:
    ; Assuming device registers are memory-mapped at EDI
    
    ; Write physical buffer address
    mov eax, dword [buffer_phys_addr]
    mov [edi + BM_BUFFER_ADDR], eax
    
    ; Write transfer size
    mov eax, dword [transfer_size]
    mov [edi + BM_COUNT], eax
    
    ; Set direction and start
    mov al, BM_READ | BM_START
    mov [edi + BM_COMMAND], al
    
    ; Enable interrupts for completion
    mov al, BM_IRQ_ENABLE
    mov [edi + BM_STATUS], al
    ret
```

### Scatter-Gather DMA

Scatter-gather DMA allows transferring data to/from multiple non-contiguous memory regions in a single operation. The driver prepares a Physical Region Descriptor (PRD) table containing address-length pairs, and the device walks this table during the transfer.

**Example** PRD table structure:

```nasm
struc PRD_Entry
    .address  resd 1     ; Physical address
    .size     resw 1     ; Transfer size in bytes
    .reserved resw 1     ; Reserved/flags (EOT bit)
endstruc

prd_table:
    istruc PRD_Entry
        at PRD_Entry.address, dd 0x100000
        at PRD_Entry.size, dw 4096
        at PRD_Entry.reserved, dw 0
    iend
    istruc PRD_Entry
        at PRD_Entry.address, dd 0x200000
        at PRD_Entry.size, dw 4096
        at PRD_Entry.reserved, dw 0x8000  ; EOT bit set
    iend
```

### DMA Synchronization and Cache Coherency

[Inference] On systems with data caches, DMA operations may create coherency issues since DMA bypasses the CPU cache. Before starting a DMA write (device to memory), the driver should invalidate relevant cache lines. After a DMA read (memory to device), cached data should be flushed to memory.

**Example** cache management for DMA:

```nasm
prepare_dma_buffer:
    ; Input: ESI = buffer address, ECX = size
    
    ; Flush cache lines (x86 WBINVD instruction)
    ; Note: WBINVD affects entire cache - use CLFLUSH for specific lines
    
    mov edi, esi
    mov eax, ecx
    add eax, 63          ; Round up to cache line
    shr eax, 6           ; Divide by 64 (typical cache line size)
    
.flush_loop:
    clflush [edi]        ; Flush one cache line
    add edi, 64
    dec eax
    jnz .flush_loop
    
    mfence               ; Memory fence - ensure ordering
    ret
```

**Key Points:**

- Bare-metal programming provides direct hardware control without OS abstraction, requiring thorough understanding of hardware specifications and memory-mapped/port-based I/O mechanisms
- Device drivers encapsulate hardware complexity through initialization, I/O operations, and interrupt handling, with polling and interrupt-driven approaches offering different trade-offs between simplicity and efficiency
- Interrupt controllers (PIC/APIC) manage hardware interrupt routing, priority, and acknowledgment, requiring proper initialization sequences and EOI signaling to function correctly
- DMA enables autonomous data transfers between devices and memory, but programmers must handle addressing constraints, boundary limitations, and cache coherency to ensure reliable operation

**Important subtopics to explore:** Protected mode memory management and paging (critical for bare-metal systems managing memory), x86 boot process and bootloader development (essential foundation for bare-metal code), real-time scheduling and timing mechanisms, hardware-specific topics like PCI/PCIe configuration space access, and UEFI firmware interfaces for modern systems.

---

# Embedded Systems

Embedded systems represent specialized computing platforms designed to perform dedicated functions within larger mechanical or electrical systems. Programming these systems in x86 assembly provides direct hardware control, minimal resource overhead, and deterministic execution timing.

## Microcontroller Programming

### Architecture Fundamentals

X86-based microcontrollers contain a processor core, memory (RAM and ROM/Flash), and integrated peripherals on a single chip. The programming model includes general-purpose registers (EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP), segment registers (CS, DS, ES, FS, GS, SS), and the flags register (EFLAGS).

**[Inference]** Modern x86 embedded processors often operate in protected mode or real mode depending on the application requirements, though some newer systems use long mode for 64-bit capabilities.

### Memory Architecture

Embedded x86 systems typically implement a Von Neumann or Harvard architecture variant. The memory map includes:

- **Reset vector**: Starting address after power-on or reset (typically 0xFFFFFFF0 in real mode)
- **Interrupt vector table**: Located at 0x00000000 in real mode, contains pointers to interrupt service routines
- **Program memory**: Flash or ROM containing executable code
- **Data memory**: RAM for variables, stack, and heap
- **Memory-mapped I/O**: Peripheral registers accessible through memory addresses

```nasm
; Setting up memory segments in real mode
mov ax, 0x1000
mov ds, ax          ; Data segment at 0x10000
mov es, ax          ; Extra segment
mov ax, 0x2000
mov ss, ax          ; Stack segment at 0x20000
mov sp, 0xFFFE      ; Stack pointer at top
```

### Initialization Sequence

Boot code must initialize the processor and peripherals before main application code executes:

```nasm
; Typical startup sequence
_start:
    cli                 ; Disable interrupts during init
    
    ; Initialize segment registers
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00      ; Set stack pointer
    
    ; Clear BSS section (uninitialized data)
    mov di, bss_start
    mov cx, bss_end
    sub cx, di
    xor al, al
    rep stosb
    
    ; Initialize hardware peripherals
    call init_timer
    call init_uart
    call init_gpio
    
    sti                 ; Enable interrupts
    jmp main            ; Jump to main application
```

### Direct Hardware Access

Assembly provides direct manipulation of I/O ports and memory-mapped registers:

```nasm
; Port I/O operations
mov dx, 0x3F8       ; COM1 UART base address
mov al, 'A'
out dx, al          ; Write character to UART

; Memory-mapped I/O
mov ebx, 0xE0000000 ; GPIO base address (example)
mov byte [ebx], 0xFF ; Set all pins high

; Read-modify-write operation
in al, dx           ; Read current port value
or al, 0x01         ; Set bit 0
out dx, al          ; Write back
```

## Resource Constraints

### Memory Optimization

Embedded systems operate with limited RAM (often kilobytes rather than megabytes). Assembly programming must minimize memory footprint:

**Code Size Reduction**

```nasm
; Inefficient - uses more bytes
mov eax, 0
mov ebx, 0
mov ecx, 0

; Efficient - smaller instruction encoding
xor eax, eax        ; 2 bytes vs 5 bytes for mov eax, 0
xor ebx, ebx
xor ecx, ecx

; Using shared code
call clear_regs     ; Call common routine instead of inline code
```

**Stack Management**

```nasm
; Minimal stack frame
function_start:
    push ebp
    mov ebp, esp
    sub esp, 8          ; Allocate only needed locals (2 DWORDs)
    
    ; Function body
    mov dword [ebp-4], eax   ; Local variable 1
    mov dword [ebp-8], ebx   ; Local variable 2
    
    mov esp, ebp
    pop ebp
    ret

; Stack reuse pattern
    push eax            ; Use stack for temporary storage
    call subroutine
    pop eax             ; Immediately reclaim
```

**Data Packing**

```nasm
; Bit-field packing
; Instead of using separate bytes, pack into bits
status_byte:        ; 8 bits holding multiple flags
    ; bit 0: power_on
    ; bit 1: error_flag
    ; bit 2: ready
    ; bits 3-7: unused

; Setting individual flags
mov al, [status_byte]
or al, 0x01         ; Set power_on flag
and al, 0xFD        ; Clear error_flag (AND with ~0x02)
mov [status_byte], al

; Extract multiple values from packed word
packed_data dw 0    ; bits 0-4: sensor1, bits 5-9: sensor2, bits 10-15: sensor3

mov ax, [packed_data]
mov bx, ax
and ax, 0x001F      ; Extract sensor1 (mask 5 bits)
shr bx, 5
mov cx, bx
and bx, 0x001F      ; Extract sensor2
shr cx, 10          ; Extract sensor3
```

### Register Allocation

With limited registers, efficient allocation is critical:

```nasm
; Register usage convention for embedded code
; EAX - accumulator, function return value
; EBX - base register for data structures
; ECX - counter for loops
; EDX - data/extended accumulator
; ESI - source pointer
; EDI - destination pointer
; EBP - frame pointer (preserve)
; ESP - stack pointer (preserve)

data_processing:
    ; Careful register management
    push ebx            ; Preserve if needed by caller
    push esi
    
    mov esi, input_buffer
    mov edi, output_buffer
    mov ecx, buffer_len
    xor ebx, ebx        ; Running sum
    
process_loop:
    lodsb               ; AL = [ESI++]
    add bl, al          ; Accumulate in BL
    stosb               ; [EDI++] = AL
    loop process_loop
    
    mov eax, ebx        ; Return sum in EAX
    pop esi
    pop ebx
    ret
```

### Power Management

Assembly code can directly control processor power states:

```nasm
; Halt processor until interrupt
idle_loop:
    hlt                 ; Enter low-power state
    jmp idle_loop       ; Resume here after interrupt

; Selective peripheral power-down
power_save_mode:
    ; Disable unused peripherals via control registers
    mov dx, 0x40        ; Timer control port
    in al, dx
    and al, 0xFE        ; Disable timer
    out dx, al
    
    mov dx, 0x3F8+4     ; UART control register
    xor al, al          ; Disable UART interrupts
    out dx, al
    
    hlt
    ret
```

## Real-Time Considerations

### Deterministic Execution

Real-time systems require predictable timing. Assembly provides cycle-accurate control:

**Instruction Timing**

**[Inference]** Execution time varies by processor model, but relative timing relationships remain consistent within a processor family.

```nasm
; Fixed-delay loop (timing depends on clock frequency)
; For 1MHz clock, approximate microsecond delays
delay_us:           ; CX = microseconds to delay
    push cx
delay_loop:
    nop             ; 1 cycle
    nop             ; 1 cycle
    nop             ; 1 cycle
    loop delay_loop ; ~4 cycles
    pop cx
    ret

; Critical timing sequence
time_critical:
    cli             ; Disable interrupts - predictable timing starts here
    
    ; Exactly timed pulse generation
    mov dx, 0x378   ; Parallel port
    mov al, 0x01
    out dx, al      ; Set bit (1-4 cycles)
    
    nop             ; Precise delay
    nop
    nop
    
    mov al, 0x00
    out dx, al      ; Clear bit
    
    sti             ; Re-enable interrupts
    ret
```

### Interrupt Service Routines

ISRs must execute quickly and predictably:

```nasm
; Timer interrupt handler
timer_isr:
    push eax
    push edx
    pushf           ; Preserve processor state
    
    ; Minimal processing in ISR
    inc dword [tick_count]
    
    ; Check if deferred work needed
    cmp dword [pending_tasks], 0
    je .done
    mov byte [task_flag], 1  ; Signal main loop
    
.done:
    ; Acknowledge interrupt to controller
    mov al, 0x20
    out 0x20, al    ; Send EOI to PIC
    
    popf
    pop edx
    pop eax
    iret            ; Return from interrupt
```

**Interrupt Latency**

The time from interrupt signal to ISR execution:

```nasm
; Minimizing interrupt latency
; 1. Keep critical sections short
critical_section:
    cli             ; Interrupts disabled
    mov al, [shared_var]
    inc al
    mov [shared_var], al
    sti             ; Re-enable ASAP
    
; 2. Use atomic operations when possible
    lock inc byte [shared_var]  ; No cli/sti needed

; 3. Nested interrupt support (careful!)
reentrant_isr:
    pusha
    mov al, 0x20
    out 0x20, al    ; EOI first
    sti             ; Allow higher-priority interrupts
    
    ; ISR processing
    
    cli
    popa
    iret
```

### Task Scheduling

Simple cooperative or preemptive scheduling in assembly:

```nasm
; Cooperative multitasking - tasks voluntarily yield
task_yield:
    pushf
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
    
    ; Save current task context
    mov ebx, [current_task]
    mov [ebx], esp      ; Save stack pointer
    
    ; Select next task
    mov ebx, [ebx+4]    ; Next pointer in task list
    cmp ebx, 0
    jne .have_next
    mov ebx, [task_list_head]  ; Wrap to first task
    
.have_next:
    mov [current_task], ebx
    mov esp, [ebx]      ; Load next task's stack
    
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    popf
    ret                 ; "Return" to next task

; Preemptive scheduling from timer ISR
timer_task_switch:
    ; Called from timer interrupt
    dec dword [time_slice]
    jnz .no_switch
    
    ; Time slice expired
    mov dword [time_slice], DEFAULT_SLICE
    
    ; Save interrupt context
    pusha
    push ds
    push es
    
    ; Save current task state
    mov ebx, [current_task]
    mov [ebx], esp
    
    ; Round-robin selection
    mov ebx, [ebx+4]
    test ebx, ebx
    jnz .restore
    mov ebx, [task_list_head]
    
.restore:
    mov [current_task], ebx
    mov esp, [ebx]
    
    pop es
    pop ds
    popa
    
.no_switch:
    iret
```

### Priority Inversion Prevention

**[Inference]** Assembly implementations can use priority inheritance or priority ceiling protocols, though these require careful state management.

```nasm
; Simple priority-based ready queue
; Higher priority values = higher priority
schedule_next_task:
    mov ecx, MAX_TASKS
    mov ebx, task_array
    xor edx, edx        ; Best priority found
    xor esi, esi        ; Best task pointer
    
.scan_loop:
    cmp byte [ebx+TASK_STATE], READY
    jne .next_task
    
    mov al, [ebx+TASK_PRIORITY]
    cmp al, dl
    jbe .next_task      ; Not better priority
    
    mov dl, al          ; New best priority
    mov esi, ebx        ; New best task
    
.next_task:
    add ebx, TASK_SIZE
    loop .scan_loop
    
    ; ESI now points to highest priority ready task
    ret
```

## Peripheral Interfaces

### Serial Communication (UART)

Universal Asynchronous Receiver/Transmitter interface:

```nasm
; UART initialization
UART_BASE equ 0x3F8     ; COM1 base address
UART_DATA equ UART_BASE+0
UART_IER  equ UART_BASE+1   ; Interrupt enable
UART_LCR  equ UART_BASE+3   ; Line control
UART_MCR  equ UART_BASE+4   ; Modem control
UART_LSR  equ UART_BASE+5   ; Line status

init_uart:
    ; Set baud rate to 9600 (divisor = 115200/9600 = 12)
    mov dx, UART_LCR
    mov al, 0x80        ; Enable DLAB (Divisor Latch Access)
    out dx, al
    
    mov dx, UART_DATA
    mov al, 12          ; Divisor low byte
    out dx, al
    mov dx, UART_DATA+1
    mov al, 0           ; Divisor high byte
    out dx, al
    
    ; Configure: 8 data bits, 1 stop bit, no parity
    mov dx, UART_LCR
    mov al, 0x03
    out dx, al
    
    ; Enable FIFO
    mov dx, UART_BASE+2
    mov al, 0xC7
    out dx, al
    
    ; Enable interrupts (RX only)
    mov dx, UART_IER
    mov al, 0x01
    out dx, al
    
    ret

; Transmit byte
uart_send_byte:         ; AL = byte to send
    push dx
    mov dx, UART_LSR
    
.wait_empty:
    in al, dx
    test al, 0x20       ; Check THRE (Transmit Holding Register Empty)
    jz .wait_empty
    
    mov dx, UART_DATA
    pop ax              ; Recover byte to send
    out dx, al
    
    ret

; Receive byte
uart_recv_byte:         ; Returns byte in AL
    mov dx, UART_LSR
    
.wait_data:
    in al, dx
    test al, 0x01       ; Check Data Ready
    jz .wait_data
    
    mov dx, UART_DATA
    in al, dx
    ret

; Interrupt-driven receive
uart_rx_isr:
    push eax
    push edx
    push edi
    
    mov dx, UART_DATA
    in al, dx           ; Read received byte
    
    ; Store in circular buffer
    mov edi, [rx_buffer_write]
    mov [edi], al
    inc edi
    
    ; Wrap pointer
    cmp edi, rx_buffer_end
    jb .no_wrap
    mov edi, rx_buffer_start
    
.no_wrap:
    mov [rx_buffer_write], edi
    
    ; Check for overflow
    cmp edi, [rx_buffer_read]
    jne .done
    inc byte [rx_buffer_overflow]
    
.done:
    mov al, 0x20
    out 0x20, al        ; EOI
    
    pop edi
    pop edx
    pop eax
    iret
```

### GPIO (General Purpose I/O)

Digital input/output control:

```nasm
; x86 parallel port as GPIO example
GPIO_DATA equ 0x378     ; Data port (8 output pins)
GPIO_STATUS equ 0x379   ; Status port (5 input pins)
GPIO_CONTROL equ 0x37A  ; Control port (4 I/O pins)

; Set GPIO pins
gpio_write:             ; AL = bit pattern
    mov dx, GPIO_DATA
    out dx, al
    ret

; Read GPIO pins
gpio_read:              ; Returns status in AL
    mov dx, GPIO_STATUS
    in al, dx
    ret

; Bit manipulation
gpio_set_bit:           ; CL = bit number (0-7)
    mov dx, GPIO_DATA
    in al, dx           ; Read current value
    mov bl, 1
    shl bl, cl          ; Create bit mask
    or al, bl           ; Set bit
    out dx, al
    ret

gpio_clear_bit:         ; CL = bit number
    mov dx, GPIO_DATA
    in al, dx
    mov bl, 1
    shl bl, cl
    not bl              ; Invert mask
    and al, bl          ; Clear bit
    out dx, al
    ret

; Debounced button read
read_button:            ; CL = bit position, returns ZF set if pressed
    call gpio_read
    mov bl, 1
    shl bl, cl
    test al, bl
    jz .not_pressed
    
    ; Debounce delay
    push cx
    mov cx, 1000
    call delay_us
    pop cx
    
    call gpio_read
    test al, bl         ; Check again
    
.not_pressed:
    ret

; Edge detection
gpio_wait_rising_edge:  ; CL = bit position
    mov bl, 1
    shl bl, cl          ; Create mask
    
.wait_low:
    call gpio_read
    test al, bl
    jnz .wait_low       ; Wait for pin to be low
    
.wait_high:
    call gpio_read
    test al, bl
    jz .wait_high       ; Wait for pin to go high
    
    ret
```

### Timer/Counter Programming

Hardware timers for timing and event generation:

```nasm
; 8254 Programmable Interval Timer
PIT_CH0 equ 0x40        ; Channel 0 data port
PIT_CH1 equ 0x41        ; Channel 1 data port
PIT_CH2 equ 0x42        ; Channel 2 data port
PIT_CMD equ 0x43        ; Command register

; Configure channel 0 for periodic interrupt at ~1000 Hz
init_timer:
    ; Input frequency = 1.193182 MHz
    ; For 1000 Hz: divisor = 1193182 / 1000 ≈ 1193
    
    mov al, 0x36        ; Channel 0, LSB/MSB, Mode 3 (square wave)
    out PIT_CMD, al
    
    mov ax, 1193        ; Divisor
    out PIT_CH0, al     ; Send low byte
    mov al, ah
    out PIT_CH0, al     ; Send high byte
    
    ; Enable IRQ0 in PIC
    in al, 0x21         ; Read PIC mask
    and al, 0xFE        ; Clear bit 0 (IRQ0)
    out 0x21, al        ; Write back
    
    ret

; One-shot timer
timer_oneshot:          ; AX = delay count
    mov cx, ax
    
    mov al, 0x30        ; Channel 0, LSB/MSB, Mode 0 (interrupt on terminal count)
    out PIT_CMD, al
    
    mov al, cl
    out PIT_CH0, al     ; Low byte
    mov al, ch
    out PIT_CH0, al     ; High byte
    
    ret

; Read current timer count
timer_read_count:       ; Returns count in AX
    mov al, 0x00        ; Latch counter 0
    out PIT_CMD, al
    
    in al, PIT_CH0      ; Read low byte
    mov ah, al
    in al, PIT_CH0      ; Read high byte
    xchg ah, al
    ret
```

### SPI (Serial Peripheral Interface)

**[Unverified]** The following represents a typical bit-banged SPI implementation pattern using GPIO; actual port addresses depend on the specific hardware platform.

```nasm
; Bit-banged SPI using GPIO pins
SPI_SCK  equ 0          ; Clock pin
SPI_MOSI equ 1          ; Master Out Slave In
SPI_MISO equ 2          ; Master In Slave Out  
SPI_CS   equ 3          ; Chip Select

spi_transfer_byte:      ; AL = byte to send, returns received byte in AL
    push cx
    push dx
    mov cl, 8           ; 8 bits
    xor dl, dl          ; Received byte accumulator
    
.bit_loop:
    ; Send bit (MSB first)
    rol al, 1           ; Rotate left, MSB to CF
    push ax
    mov ah, 1
    jnc .send_zero
    mov ah, SPI_MOSI
    
.send_zero:
    call gpio_write_bits
    
    ; Clock high
    call spi_clock_pulse
    
    ; Read MISO
    call gpio_read
    mov dh, al
    and dh, (1 << SPI_MISO)
    shr dh, SPI_MISO    ; Extract MISO bit
    rol dl, 1           ; Shift received data
    or dl, dh           ; Insert new bit
    
    pop ax
    loop .bit_loop
    
    mov al, dl          ; Return received byte
    pop dx
    pop cx
    ret

spi_clock_pulse:
    ; SCK high
    push ax
    mov al, (1 << SPI_SCK)
    call gpio_set_bits
    nop                 ; Brief delay
    nop
    
    ; SCK low
    mov al, (1 << SPI_SCK)
    call gpio_clear_bits
    pop ax
    ret

spi_select_device:
    mov al, (1 << SPI_CS)
    call gpio_clear_bits ; CS active low
    ret

spi_deselect_device:
    mov al, (1 << SPI_CS)
    call gpio_set_bits
    ret
```

### I2C (Inter-Integrated Circuit)

**[Unverified]** Bit-banged I2C implementation; timing requirements are critical and vary by device speed (100kHz, 400kHz, etc.).

```nasm
; Bit-banged I2C using GPIO
I2C_SDA equ 0           ; Data line
I2C_SCL equ 1           ; Clock line

i2c_start:
    ; SDA high, SCL high initially
    call i2c_sda_high
    call i2c_scl_high
    call i2c_delay
    
    ; Start condition: SDA goes low while SCL is high
    call i2c_sda_low
    call i2c_delay
    call i2c_scl_low
    ret

i2c_stop:
    ; SDA low, SCL low initially
    call i2c_sda_low
    call i2c_scl_low
    call i2c_delay
    
    ; Stop condition: SCL goes high, then SDA goes high
    call i2c_scl_high
    call i2c_delay
    call i2c_sda_high
    call i2c_delay
    ret

i2c_write_byte:         ; AL = byte to write, returns ACK in CF
    push cx
    mov cl, 8
    
.bit_loop:
    rol al, 1           ; MSB first
    push ax
    
    jc .send_one
    call i2c_sda_low
    jmp .clock_pulse
    
.send_one:
    call i2c_sda_high
    
.clock_pulse:
    call i2c_scl_high
    call i2c_delay
    call i2c_scl_low
    
    pop ax
    loop .bit_loop
    
    ; Read ACK bit
    call i2c_sda_high   ; Release SDA for ACK
    call i2c_scl_high
    call i2c_delay
    
    call gpio_read
    test al, (1 << I2C_SDA)
    setnz cl            ; CL = 1 if NACK, 0 if ACK
    
    call i2c_scl_low
    shr cl, 1           ; NACK into CF
    
    pop cx
    ret

i2c_read_byte:          ; CL = ACK flag (0=ACK, 1=NACK), returns byte in AL
    push cx
    push dx
    xor dl, dl          ; Accumulator
    mov cl, 8
    
.bit_loop:
    call i2c_sda_high   ; Release SDA for slave
    call i2c_scl_high
    call i2c_delay
    
    ; Read bit
    call gpio_read
    and al, (1 << I2C_SDA)
    shr al, I2C_SDA
    
    rol dl, 1
    or dl, al
    
    call i2c_scl_low
    call i2c_delay
    
    loop .bit_loop
    
    ; Send ACK/NACK
    pop cx
    test cl, cl
    jnz .send_nack
    
    call i2c_sda_low    ; ACK
    jmp .clock_ack
    
.send_nack:
    call i2c_sda_high   ; NACK
    
.clock_ack:
    call i2c_scl_high
    call i2c_delay
    call i2c_scl_low
    
    mov al, dl          ; Return received byte
    pop dx
    ret

i2c_delay:
    push cx
    mov cx, 10          ; Adjust for desired I2C clock speed
.delay_loop:
    nop
    loop .delay_loop
    pop cx
    ret

; Helper functions
i2c_sda_high:
    mov al, (1 << I2C_SDA)
    jmp gpio_set_bits

i2c_sda_low:
    mov al, (1 << I2C_SDA)
    jmp gpio_clear_bits

i2c_scl_high:
    mov al, (1 << I2C_SCL)
    jmp gpio_set_bits

i2c_scl_low:
    mov al, (1 << I2C_SCL)
    jmp gpio_clear_bits
```

### ADC (Analog-to-Digital Converter)

Reading analog sensors:

```nasm
; Example: 8-bit ADC with memory-mapped registers
ADC_CTRL equ 0xF000     ; Control register
ADC_DATA equ 0xF001     ; Data register
ADC_STATUS equ 0xF002   ; Status register

adc_read_channel:       ; CL = channel number (0-7), returns value in AX
    push dx
    
    ; Select channel and start conversion
    mov al, cl
    or al, 0x80         ; Set start bit
    mov dx, ADC_CTRL
    out dx, al
    
.wait_conversion:
    mov dx, ADC_STATUS
    in al, dx
    test al, 0x01       ; Check conversion complete flag
    jz .wait_conversion
    
    ; Read result
    mov dx, ADC_DATA
    in al, dx           ; Read low byte
    xor ah, ah          ; Clear high byte (8-bit ADC)
    
    pop dx
    ret

; Multiple channel sampling
adc_sample_all:         ; Fills sample_buffer with all 8 channels
    push ebx
    push ecx
    
    mov ebx, sample_buffer
    xor cl, cl          ; Start with channel 0
    
.channel_loop:
    call adc_read_channel
    mov [ebx], ax
    add ebx, 2
    
    inc cl
    cmp cl, 8
    jb .channel_loop
    
    pop ecx
    pop ebx
    ret

; Moving average filter
adc_filtered_read:      ; CL = channel, returns filtered value in AX
    push ebx
    push ecx
    push edx
    
    ; Calculate buffer index
    movzx ebx, cl
    shl ebx, 4          ; channel * 16 (assuming 16-sample buffer per channel)
    add ebx, adc_filter_buffer
    
    ; Read new sample
    call adc_read_channel
    
    ; Store in circular buffer
    mov edx, [ebx+12]   ; Get write index
    mov [ebx+edx*2], ax ; Store sample
    inc edx
    and edx, 0x0F       ; Wrap at 16
    mov [ebx+12], edx
    
    ; Calculate average
    xor edx, edx
    mov ecx, 16
    
.sum_loop:
    add dx, [ebx]
    add ebx, 2
    loop .sum_loop
    
    mov ax, dx
    shr ax, 4           ; Divide by 16
    
    pop edx
    pop ecx
    pop ebx
    ret
```

### PWM (Pulse Width Modulation)

Generating variable-duty-cycle signals:

```nasm
; Software PWM using timer interrupt
PWM_CHANNELS equ 4
pwm_duty_cycles: times PWM_CHANNELS db 0  ; 0-255 duty cycle values
pwm_counters: times PWM_CHANNELS db 0     ; Current counter for each channel
pwm_pin_mask: db 0x0F                     ; Pins 0-3 for PWM

; Called from timer ISR at high frequency (e.g., 20kHz)
pwm_update:
    push eax
    push ebx
    push ecx
    
    mov ecx, PWM_CHANNELS
    mov ebx, 0
    xor al, al          ; Build output mask
    
.channel_loop:
    ; Increment counter
    inc byte [pwm_counters+ebx]
    
    ; Compare with duty cycle
    mov ah, [pwm_duty_cycles+ebx]
    cmp [pwm_counters+ebx], ah
    jae .pin_low
    
    ; Pin should be high
    mov ah, 1
    shl ah, bl
    or al, ah
    jmp .next_channel
    
.pin_low:
    ; Pin is low (already 0 in AL)
    
.next_channel:
    inc ebx
    loop .channel_loop
    
    ; Update GPIO with computed mask
    and al, [pwm_pin_mask]
    call gpio_write
    
    pop ecx
    pop ebx
    pop eax
    ret

; Set PWM duty cycle
pwm_set_duty:           ; CL = channel, AL = duty cycle (0-255)
    push ebx
    movzx ebx, cl
    mov [pwm_duty_cycles+ebx], al
    pop ebx
    ret

; Hardware PWM (platform-specific example)
hw_pwm_init:
    ; Configure timer for PWM mode
    mov dx, 0x500       ; PWM control register
    mov al, 0x42        ; PWM mode, 8-bit resolution
    out dx, al
    
    ; Set frequency (period register)
    mov dx, 0x502
    mov ax, 255         ; Period value
    out dx, al
    
    ret

hw_pwm_set_duty:        ; CL = channel, AL = duty
    push dx
    
    ; Select channel register
    mov dx, 0x504
    add dl, cl          ; Channel duty registers at 0x504+
    out dx, al
    
    pop dx
    ret
```

**Key Points:**

- X86 assembly provides direct hardware control essential for embedded systems with minimal overhead and deterministic behavior
- Register allocation and memory optimization are critical due to resource constraints in microcontrollers
- Real-time systems require predictable interrupt latency, deterministic execution timing, and careful task scheduling
- Peripheral interfaces (UART, GPIO, timers, SPI, I2C, ADC, PWM) are programmed through port I/O or memory-mapped registers
- Interrupt service routines must be kept minimal, with deferred processing in main loop when possible
- Power management can be implemented through HLT instructions and selective peripheral shutdown
- Bit manipulation techniques allow efficient packing of data into minimal memory space

### DMA (Direct Memory Access)

DMA controllers enable peripheral-to-memory transfers without CPU intervention:

```nasm
; 8237 DMA Controller programming
DMA_CH0_ADDR equ 0x00   ; Channel 0 address register
DMA_CH0_COUNT equ 0x01  ; Channel 0 count register
DMA_STATUS equ 0x08     ; Status register
DMA_COMMAND equ 0x08    ; Command register
DMA_REQUEST equ 0x09    ; Request register
DMA_MASK equ 0x0A       ; Mask register
DMA_MODE equ 0x0B       ; Mode register
DMA_CLEAR_FF equ 0x0C   ; Clear flip-flop register
DMA_PAGE_CH0 equ 0x87   ; Page register for channel 0

dma_setup_transfer:     ; ESI = source, EDI = destination, ECX = count, CL = channel
    push eax
    push edx
    
    ; Disable DMA channel
    mov al, cl
    or al, 0x04         ; Set mask bit
    mov dx, DMA_MASK
    out dx, al
    
    ; Clear byte pointer flip-flop
    mov dx, DMA_CLEAR_FF
    xor al, al
    out dx, al
    
    ; Set mode (single transfer, address increment, autoinit off)
    mov al, cl
    or al, 0x48         ; Read transfer, single mode
    mov dx, DMA_MODE
    out dx, al
    
    ; Program address (low 16 bits)
    mov eax, esi
    mov dx, DMA_CH0_ADDR
    out dx, al          ; Low byte
    mov al, ah
    out dx, al          ; High byte
    
    ; Program page (high 8 bits of address)
    shr eax, 16
    mov dx, DMA_PAGE_CH0
    out dx, al
    
    ; Program count (length - 1)
    dec ecx
    mov ax, cx
    mov dx, DMA_CH0_COUNT
    out dx, al          ; Low byte
    mov al, ah
    out dx, al          ; High byte
    
    ; Enable DMA channel
    mov al, cl
    mov dx, DMA_MASK
    out dx, al
    
    pop edx
    pop eax
    ret

; Wait for DMA completion
dma_wait_complete:      ; CL = channel number
    push ax
    push dx
    
    mov bl, 1
    shl bl, cl          ; Create channel mask
    
    mov dx, DMA_STATUS
.wait_loop:
    in al, dx
    test al, bl         ; Check terminal count flag
    jz .wait_loop
    
    pop dx
    pop ax
    ret

; DMA interrupt handler
dma_isr:
    pusha
    
    ; Determine which channel completed
    mov dx, DMA_STATUS
    in al, dx
    
    test al, 0x01
    jz .check_ch1
    call dma_ch0_complete
    
.check_ch1:
    test al, 0x02
    jz .done
    call dma_ch1_complete
    
.done:
    mov al, 0x20
    out 0x20, al        ; Send EOI
    popa
    iret
```

### Watchdog Timer

Hardware watchdog ensures system recovery from crashes:

```nasm
; Watchdog timer control
WDT_CONTROL equ 0x600   ; Control register
WDT_RELOAD equ 0x601    ; Reload value register

watchdog_init:
    ; Set timeout period (platform-specific calculation)
    mov dx, WDT_RELOAD
    mov ax, 32768       ; Example: ~1 second timeout at 32kHz
    out dx, al
    mov al, ah
    out dx, al
    
    ; Enable watchdog
    mov dx, WDT_CONTROL
    mov al, 0x01        ; Enable bit
    out dx, al
    
    ret

watchdog_kick:
    ; Reset watchdog counter (must be called periodically)
    mov dx, WDT_CONTROL
    mov al, 0x80        ; Reset/kick bit
    out dx, al
    ret

; Main loop with watchdog
main_loop:
    call watchdog_kick
    
    ; Critical system tasks
    call check_sensors
    call update_actuators
    call process_communications
    
    ; Non-critical tasks
    call update_display
    call log_data
    
    jmp main_loop       ; Loop continues indefinitely
```

### Flash Memory Programming

Self-programming capability for firmware updates:

**[Unverified]** Flash programming sequences are highly device-specific and require exact timing and command sequences per manufacturer specifications.

```nasm
; Generic flash programming sequence
FLASH_BASE equ 0xFF000000
FLASH_CMD_ADDR1 equ FLASH_BASE + 0x5555
FLASH_CMD_ADDR2 equ FLASH_BASE + 0x2AAA

flash_unlock_sequence:
    ; Standard AMD/Spansion unlock sequence
    mov ebx, FLASH_CMD_ADDR1
    mov byte [ebx], 0xAA
    
    mov ebx, FLASH_CMD_ADDR2
    mov byte [ebx], 0x55
    ret

flash_erase_sector:     ; EBX = sector address
    push eax
    push ebx
    
    call flash_unlock_sequence
    
    ; Erase command
    mov ebx, FLASH_CMD_ADDR1
    mov byte [ebx], 0x80
    
    call flash_unlock_sequence
    
    ; Sector erase
    mov byte [ebx], 0x30    ; EBX already points to sector
    
    ; Wait for completion (poll data toggle bit)
    call flash_wait_ready
    
    pop ebx
    pop eax
    ret

flash_program_byte:     ; EBX = address, AL = data
    push eax
    push ebx
    push ecx
    
    mov cl, al          ; Save data byte
    
    call flash_unlock_sequence
    
    ; Program command
    mov ebx, FLASH_CMD_ADDR1
    mov byte [ebx], 0xA0
    
    ; Write data
    pop ebx
    push ebx
    mov [ebx], cl
    
    ; Wait for programming complete
    call flash_wait_ready
    
    pop ecx
    pop ebx
    pop eax
    ret

flash_wait_ready:
    push eax
    push ebx
    
.poll_loop:
    mov al, [ebx]       ; Read once
    mov ah, [ebx]       ; Read twice
    
    ; Check DQ6 toggle bit
    xor al, ah
    test al, 0x40
    jnz .poll_loop      ; Still toggling = not ready
    
    pop ebx
    pop eax
    ret

; Firmware update routine
firmware_update:        ; ESI = new firmware data, ECX = size
    push eax
    push ebx
    push ecx
    push esi
    
    ; Calculate sectors to erase
    mov ebx, FLASH_BASE
    mov eax, ecx
    add eax, 0xFFFF
    shr eax, 16         ; Divide by 64KB sector size
    
.erase_loop:
    push eax
    call flash_erase_sector
    add ebx, 0x10000    ; Next sector
    pop eax
    dec eax
    jnz .erase_loop
    
    ; Program new firmware
    mov ebx, FLASH_BASE
    
.program_loop:
    lodsb               ; Load byte from [ESI++]
    call flash_program_byte
    inc ebx
    loop .program_loop
    
    ; Verify programmed data
    mov esi, [esp]      ; Restore original data pointer
    mov ebx, FLASH_BASE
    mov ecx, [esp+4]    ; Restore size
    
.verify_loop:
    lodsb
    cmp al, [ebx]
    jne .verify_error
    inc ebx
    loop .verify_loop
    
    ; Update complete
    clc                 ; Clear carry = success
    jmp .done
    
.verify_error:
    stc                 ; Set carry = error
    
.done:
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret
```

### Memory Protection

Implementing basic memory protection for embedded systems:

```nasm
; Simple MPU (Memory Protection Unit) configuration
MPU_BASE equ 0xE000ED90
MPU_TYPE equ MPU_BASE + 0x00
MPU_CTRL equ MPU_BASE + 0x04
MPU_RNR equ MPU_BASE + 0x08     ; Region number
MPU_RBAR equ MPU_BASE + 0x0C    ; Region base address
MPU_RASR equ MPU_BASE + 0x10    ; Region attribute and size

mpu_init:
    push eax
    push ebx
    
    ; Disable MPU during configuration
    mov ebx, MPU_CTRL
    mov dword [ebx], 0x00
    
    ; Configure region 0: Flash (execute, read-only)
    mov ebx, MPU_RNR
    mov dword [ebx], 0          ; Select region 0
    
    mov ebx, MPU_RBAR
    mov dword [ebx], 0x08000000 ; Flash base address
    
    mov ebx, MPU_RASR
    mov eax, (1 << 0)           ; Enable region
    or eax, (0x13 << 1)         ; Size = 1MB (2^(13+1))
    or eax, (0x06 << 24)        ; Read-only, execute
    mov [ebx], eax
    
    ; Configure region 1: RAM (read-write, no execute)
    mov ebx, MPU_RNR
    mov dword [ebx], 1
    
    mov ebx, MPU_RBAR
    mov dword [ebx], 0x20000000 ; RAM base address
    
    mov ebx, MPU_RASR
    mov eax, (1 << 0)
    or eax, (0x10 << 1)         ; Size = 128KB
    or eax, (0x03 << 24)        ; Read-write, no execute
    mov [ebx], eax
    
    ; Configure region 2: Peripherals (read-write, no execute, device memory)
    mov ebx, MPU_RNR
    mov dword [ebx], 2
    
    mov ebx, MPU_RBAR
    mov dword [ebx], 0x40000000
    
    mov ebx, MPU_RASR
    mov eax, (1 << 0)
    or eax, (0x13 << 1)
    or eax, (0x13 << 24)        ; Device memory type
    mov [ebx], eax
    
    ; Enable MPU with default memory map
    mov ebx, MPU_CTRL
    mov dword [ebx], 0x05       ; Enable MPU + background region
    
    pop ebx
    pop eax
    ret

; Memory protection fault handler
mpu_fault_handler:
    ; This is a serious error - log and reset
    pusha
    
    ; Read fault address and status
    mov ebx, 0xE000ED28 ; CFSR (Configurable Fault Status Register)
    mov eax, [ebx]
    
    mov ebx, 0xE000ED34 ; MMFAR (MemManage Fault Address Register)
    mov ecx, [ebx]
    
    ; Log fault information
    push ecx            ; Fault address
    push eax            ; Fault status
    call log_critical_error
    add esp, 8
    
    ; Reset system
    call system_reset
    
    popa
    iret
```

### Low-Level Boot Loader

Minimal boot loader for embedded system initialization:

```nasm
; Boot loader at reset vector
RESET_VECTOR equ 0xFFFFFFF0

section .reset
    org RESET_VECTOR
    jmp boot_start

section .boot
boot_start:
    ; Disable interrupts
    cli
    
    ; Initialize processor state
    xor eax, eax
    mov cr0, eax        ; Disable paging, caching
    
    ; Set up temporary stack
    mov esp, 0x7C00
    
    ; Copy program from flash to RAM
    mov esi, FLASH_START
    mov edi, RAM_START
    mov ecx, PROGRAM_SIZE
    rep movsb
    
    ; Clear BSS section
    mov edi, BSS_START
    mov ecx, BSS_END
    sub ecx, edi
    xor al, al
    rep stosb
    
    ; Initialize .data section
    mov esi, DATA_LOAD_ADDR
    mov edi, DATA_START
    mov ecx, DATA_SIZE
    rep movsb
    
    ; Setup interrupt vector table
    call setup_ivt
    
    ; Initialize hardware
    call init_clock
    call init_memory_controller
    call init_peripherals
    
    ; Enable interrupts
    sti
    
    ; Jump to main application
    jmp RAM_START

setup_ivt:
    ; Install interrupt vectors
    mov edi, 0x00000000
    mov eax, default_isr
    mov ecx, 256        ; 256 interrupt vectors
    
.fill_vectors:
    stosd               ; Store vector address
    loop .fill_vectors
    
    ; Install specific handlers
    mov dword [0x00], divide_error_handler
    mov dword [0x04], overflow_handler
    mov dword [0x08], double_fault_handler
    mov dword [0x20], timer_isr
    mov dword [0x24], keyboard_isr
    mov dword [0x2C], uart_rx_isr
    
    ret

default_isr:
    ; Generic handler for unimplemented interrupts
    pusha
    call log_unexpected_interrupt
    popa
    iret
```

### Power State Management

Advanced power management for battery-operated devices:

```nasm
; Power states
POWER_STATE_RUN equ 0
POWER_STATE_SLEEP equ 1
POWER_STATE_DEEP_SLEEP equ 2
POWER_STATE_STANDBY equ 3

current_power_state db POWER_STATE_RUN

; Enter sleep mode
enter_sleep_mode:
    push eax
    push ebx
    
    ; Save current state
    mov byte [current_power_state], POWER_STATE_SLEEP
    
    ; Disable non-essential peripherals
    call disable_display
    call disable_adc
    call reduce_clock_speed
    
    ; Configure wake sources
    mov ebx, WAKEUP_CONTROL_REG
    mov al, 0x03        ; Enable UART and timer wakeup
    mov [ebx], al
    
    ; Enter sleep mode
    hlt
    
    ; Resume here after wakeup
    call restore_clock_speed
    call enable_peripherals
    
    mov byte [current_power_state], POWER_STATE_RUN
    
    pop ebx
    pop eax
    ret

; Deep sleep mode (longer wake latency, lower power)
enter_deep_sleep:
    push eax
    push ebx
    
    mov byte [current_power_state], POWER_STATE_DEEP_SLEEP
    
    ; Save critical state to non-volatile memory
    call save_context_to_flash
    
    ; Power down RAM banks
    mov ebx, RAM_POWER_CTRL
    mov al, 0xFE        ; Keep only first bank powered
    mov [ebx], al
    
    ; Disable all peripherals except RTC
    call shutdown_all_peripherals
    
    ; Stop main oscillator, use low-power oscillator
    mov ebx, CLOCK_CTRL
    mov al, 0x02        ; Switch to 32kHz oscillator
    mov [ebx], al
    
    ; Enter stop mode
    mov ebx, POWER_MODE_REG
    mov al, 0x03        ; Deep stop mode
    mov [ebx], al
    
    hlt
    
    ; System will reset on wake - boot code restores context
    
    pop ebx
    pop eax
    ret

; Dynamic voltage and frequency scaling
dvfs_adjust:            ; AL = performance level (0-3)
    push ebx
    push ecx
    
    ; Look up voltage/frequency settings
    movzx ebx, al
    shl ebx, 1          ; Index into table (2 bytes per entry)
    
    mov cx, [dvfs_table + ebx]
    
    ; Adjust voltage first when scaling up
    cmp al, [current_perf_level]
    jbe .scale_down
    
    ; Scaling up: voltage first, then frequency
    mov ebx, VOLTAGE_CTRL
    mov al, ch
    mov [ebx], al
    
    call voltage_stabilize_delay
    
    mov ebx, CLOCK_DIV
    mov al, cl
    mov [ebx], al
    jmp .done
    
.scale_down:
    ; Scaling down: frequency first, then voltage
    mov ebx, CLOCK_DIV
    mov al, cl
    mov [ebx], al
    
    mov ebx, VOLTAGE_CTRL
    mov al, ch
    mov [ebx], al
    
.done:
    pop ecx
    pop ebx
    ret

dvfs_table:
    ; Format: frequency_divider | voltage_level
    dw 0x0810       ; Level 0: div=16, 1.0V
    dw 0x0408       ; Level 1: div=8, 1.2V
    dw 0x0206       ; Level 2: div=4, 1.4V
    dw 0x0104       ; Level 3: div=2, 1.6V

voltage_stabilize_delay:
    push cx
    mov cx, 1000
.delay:
    nop
    loop .delay
    pop cx
    ret
```

### Circular Buffer Implementation

Essential data structure for embedded systems:

```nasm
; Circular buffer structure
struc circular_buffer
    .buffer_start: resd 1   ; Pointer to buffer memory
    .buffer_end: resd 1     ; Pointer to end of buffer
    .read_ptr: resd 1       ; Current read position
    .write_ptr: resd 1      ; Current write position
    .count: resd 1          ; Number of elements in buffer
    .capacity: resd 1       ; Maximum capacity
endstruc

; Initialize circular buffer
cbuf_init:              ; EBX = buffer struct, ESI = memory, ECX = capacity
    mov [ebx + circular_buffer.buffer_start], esi
    mov [ebx + circular_buffer.read_ptr], esi
    mov [ebx + circular_buffer.write_ptr], esi
    mov [ebx + circular_buffer.capacity], ecx
    mov dword [ebx + circular_buffer.count], 0
    
    ; Calculate buffer end
    lea eax, [esi + ecx]
    mov [ebx + circular_buffer.buffer_end], eax
    
    ret

; Write byte to buffer
cbuf_write:             ; EBX = buffer struct, AL = byte, returns CF=1 if full
    push edi
    
    ; Check if full
    mov edi, [ebx + circular_buffer.count]
    cmp edi, [ebx + circular_buffer.capacity]
    jae .buffer_full
    
    ; Write byte
    mov edi, [ebx + circular_buffer.write_ptr]
    mov [edi], al
    inc edi
    
    ; Wrap if necessary
    cmp edi, [ebx + circular_buffer.buffer_end]
    jb .no_wrap_write
    mov edi, [ebx + circular_buffer.buffer_start]
    
.no_wrap_write:
    mov [ebx + circular_buffer.write_ptr], edi
    inc dword [ebx + circular_buffer.count]
    
    clc                 ; Success
    pop edi
    ret
    
.buffer_full:
    stc                 ; Error - buffer full
    pop edi
    ret

; Read byte from buffer
cbuf_read:              ; EBX = buffer struct, returns byte in AL, CF=1 if empty
    push esi
    
    ; Check if empty
    cmp dword [ebx + circular_buffer.count], 0
    je .buffer_empty
    
    ; Read byte
    mov esi, [ebx + circular_buffer.read_ptr]
    mov al, [esi]
    inc esi
    
    ; Wrap if necessary
    cmp esi, [ebx + circular_buffer.buffer_end]
    jb .no_wrap_read
    mov esi, [ebx + circular_buffer.buffer_start]
    
.no_wrap_read:
    mov [ebx + circular_buffer.read_ptr], esi
    dec dword [ebx + circular_buffer.count]
    
    clc                 ; Success
    pop esi
    ret
    
.buffer_empty:
    stc                 ; Error - buffer empty
    pop esi
    ret

; Peek at next byte without removing
cbuf_peek:              ; EBX = buffer struct, returns byte in AL, CF=1 if empty
    push esi
    
    cmp dword [ebx + circular_buffer.count], 0
    je .buffer_empty
    
    mov esi, [ebx + circular_buffer.read_ptr]
    mov al, [esi]
    
    clc
    pop esi
    ret
    
.buffer_empty:
    stc
    pop esi
    ret

; Get available space
cbuf_space_avail:       ; EBX = buffer struct, returns space in EAX
    mov eax, [ebx + circular_buffer.capacity]
    sub eax, [ebx + circular_buffer.count]
    ret

; Flush buffer
cbuf_flush:             ; EBX = buffer struct
    push esi
    
    mov esi, [ebx + circular_buffer.buffer_start]
    mov [ebx + circular_buffer.read_ptr], esi
    mov [ebx + circular_buffer.write_ptr], esi
    mov dword [ebx + circular_buffer.count], 0
    
    pop esi
    ret
```

### State Machine Implementation

Common pattern for embedded control systems:

```nasm
; State machine for motor control example
STATE_IDLE equ 0
STATE_STARTING equ 1
STATE_RUNNING equ 2
STATE_STOPPING equ 3
STATE_ERROR equ 4

motor_state db STATE_IDLE
motor_speed dw 0
target_speed dw 0
error_code db 0

; State machine dispatcher
motor_state_machine:
    movzx ebx, byte [motor_state]
    shl ebx, 2          ; Multiply by 4 for address table
    jmp [state_table + ebx]

state_table:
    dd state_idle
    dd state_starting
    dd state_running
    dd state_stopping
    dd state_error

state_idle:
    ; Check for start command
    test byte [motor_cmd_flags], 0x01
    jz .stay_idle
    
    ; Transition to starting
    mov byte [motor_state], STATE_STARTING
    call motor_enable
    ret
    
.stay_idle:
    ; Ensure motor is off
    call motor_disable
    ret

state_starting:
    ; Ramp up speed gradually
    mov ax, [motor_speed]
    add ax, 10          ; Acceleration rate
    mov [motor_speed], ax
    
    call motor_set_speed
    
    ; Check if target reached
    mov ax, [target_speed]
    cmp [motor_speed], ax
    jb .still_starting
    
    ; Transition to running
    mov byte [motor_state], STATE_RUNNING
    ret
    
.still_starting:
    ; Check for timeout or error
    call check_motor_current
    jc .motor_error
    ret
    
.motor_error:
    mov byte [motor_state], STATE_ERROR
    mov byte [error_code], 0x01 ; Overcurrent
    ret

state_running:
    ; Maintain speed, monitor conditions
    call motor_set_speed
    call check_motor_current
    jc .error
    
    ; Check for stop command
    test byte [motor_cmd_flags], 0x02
    jz .keep_running
    
    ; Transition to stopping
    mov byte [motor_state], STATE_STOPPING
    ret
    
.keep_running:
    ret
    
.error:
    mov byte [motor_state], STATE_ERROR
    mov byte [error_code], 0x02
    ret

state_stopping:
    ; Ramp down speed
    mov ax, [motor_speed]
    sub ax, 20          ; Deceleration rate (faster than accel)
    jc .stopped         ; Underflow = stopped
    mov [motor_speed], ax
    
    call motor_set_speed
    ret
    
.stopped:
    mov word [motor_speed], 0
    call motor_disable
    mov byte [motor_state], STATE_IDLE
    ret

state_error:
    ; Immediate shutdown
    call motor_emergency_stop
    
    ; Wait for error acknowledgment
    test byte [motor_cmd_flags], 0x04
    jz .stay_error
    
    ; Clear error and return to idle
    mov byte [error_code], 0
    mov byte [motor_state], STATE_IDLE
    ret
    
.stay_error:
    ret
```

### CRC Calculation

Data integrity checking for communications:

```nasm
; CRC-16-CCITT (polynomial 0x1021)
crc16_table: times 256 dw 0

; Generate CRC table at initialization
crc16_init_table:
    push eax
    push ebx
    push ecx
    push edx
    
    xor ebx, ebx        ; Table index
    
.outer_loop:
    mov ax, bx
    shl ax, 8           ; Value = index << 8
    mov cx, 8           ; 8 bits
    
.inner_loop:
    shl ax, 1
    jnc .no_xor
    xor ax, 0x1021      ; Polynomial
    
.no_xor:
    loop .inner_loop
    
    mov [crc16_table + ebx*2], ax
    inc ebx
    cmp ebx, 256
    jb .outer_loop
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Calculate CRC-16
crc16_calc:             ; ESI = data pointer, ECX = length, returns CRC in AX
    push ebx
    push ecx
    push esi
    
    xor ax, ax          ; Initial CRC = 0
    
.loop:
    mov bl, ah
    xor bl, [esi]       ; Mix in next byte
    inc esi
    
    movzx ebx, bl
    mov dx, [crc16_table + ebx*2]
    
    shl ax, 8
    xor ax, dx
    
    loop .loop
    
    pop esi
    pop ecx
    pop ebx
    ret

; CRC-8 (simpler, faster)
crc8_calc:              ; ESI = data, ECX = length, returns CRC in AL
    push ebx
    push ecx
    push esi
    
    xor al, al          ; Initial CRC = 0
    
.loop:
    xor al, [esi]
    inc esi
    
    mov bl, 8
.bit_loop:
    shl al, 1
    jnc .no_xor
    xor al, 0x07        ; Polynomial for CRC-8
    
.no_xor:
    dec bl
    jnz .bit_loop
    
    loop .loop
    
    pop esi
    pop ecx
    pop ebx
    ret
```

### Protocol Packet Handling

Structured communication packet processing:

```nasm
; Packet structure
struc packet
    .sync: resb 2       ; Sync bytes (0xAA55)
    .length: resb 1     ; Payload length
    .type: resb 1       ; Message type
    .payload: resb 64   ; Data
    .crc: resw 1        ; CRC-16
endstruc

; Parse received packet
packet_parse:           ; ESI = raw data, EBX = packet struct
    push ecx
    push edi
    
    ; Check sync bytes
    cmp word [esi], 0x55AA
    jne .invalid_sync
    
    ; Copy packet to structure
    mov edi, ebx
    mov ecx, packet_size
    rep movsb
    
    ; Verify CRC
    lea esi, [ebx + packet.length]
    movzx ecx, byte [ebx + packet.length]
    add ecx, 2          ; Include length and type
    call crc16_calc
    
    cmp ax, [ebx + packet.crc]
    jne .crc_error
    
    ; Process based on type
    movzx eax, byte [ebx + packet.type]
    shl eax, 2
    jmp [packet_handlers + eax]
    
.invalid_sync:
    mov al, 0x01        ; Error code
    stc
    jmp .done
    
.crc_error:
    mov al, 0x02
    stc
    jmp .done
    
.done:
    pop edi
    pop ecx
    ret

; Build outgoing packet
packet_build:           ; EBX = packet struct, AL = type, ESI = data, CL = length
    push edi
    push ecx
    
    ; Set sync bytes
    mov word [ebx + packet.sync], 0x55AA
    
    ; Set type and length
    mov [ebx + packet.type], al
    mov [ebx + packet.length], cl
    
    ; Copy payload
    lea edi, [ebx + packet.payload]
    movzx ecx, cl
    rep movsb
    
    ; Calculate and store CRC
    pop ecx
    lea esi, [ebx + packet.length]
    movzx ecx, cl
    add ecx, 2
    push ecx
    call crc16_calc
    mov [ebx + packet.crc], ax
    
    ; Return total packet size in CX
    pop ecx
    add cx, 6           ; Sync(2) + length(1) + type(1) + CRC(2)
    
    pop edi
    ret

packet_handlers:
    dd handle_data_packet
    dd handle_command_packet
    dd handle_ack_packet
    dd handle_status_request
```

**Important subtopics to explore further:**

- **RTOS integration** - Real-time operating system concepts and assembly interfaces
- **Bootloader design** - Advanced boot sequences, secure boot, firmware updates
- **Debugging techniques** - JTAG, SWD, on-chip debugging in assembly
- **Safety-critical systems** - Redundancy, self-checking code, fault tolerance
- **Low-power wireless protocols** - Bluetooth LE, Zigbee, LoRa assembly implementations
- **Motor control algorithms** - FOC, BLDC, stepper motor control in assembly
- **Sensor fusion** - Combining multiple sensor inputs for accurate measurements
- **Hardware abstraction layers** - Creating portable embedded code structures

### RTOS Integration

Integrating assembly code with real-time operating systems:

```nasm
; Task context structure for RTOS
struc task_context
    .r0: resd 1
    .r1: resd 1
    .r2: resd 1
    .r3: resd 1
    .r4: resd 1
    .r5: resd 1
    .r6: resd 1
    .r7: resd 1
    .r8: resd 1
    .r9: resd 1
    .r10: resd 1
    .r11: resd 1
    .r12: resd 1
    .sp: resd 1         ; Stack pointer
    .lr: resd 1         ; Link register
    .pc: resd 1         ; Program counter
    .cpsr: resd 1       ; Status register
endstruc

; Context switch implementation
context_switch:         ; EAX = current task context, EBX = next task context
    ; Save current task context
    mov [eax + task_context.r0], ecx
    mov [eax + task_context.r1], edx
    mov [eax + task_context.r2], esi
    mov [eax + task_context.r3], edi
    mov [eax + task_context.r4], ebp
    
    ; Save stack pointer
    mov [eax + task_context.sp], esp
    
    ; Save return address
    pop dword [eax + task_context.pc]
    
    ; Save flags
    pushf
    pop dword [eax + task_context.cpsr]
    
    ; Load next task context
    push dword [ebx + task_context.cpsr]
    popf
    
    ; Restore stack pointer
    mov esp, [ebx + task_context.sp]
    
    ; Restore registers
    mov ecx, [ebx + task_context.r0]
    mov edx, [ebx + task_context.r1]
    mov esi, [ebx + task_context.r2]
    mov edi, [ebx + task_context.r3]
    mov ebp, [ebx + task_context.r4]
    
    ; Jump to task
    jmp [ebx + task_context.pc]

; Semaphore implementation
struc semaphore
    .count: resd 1
    .wait_queue: resd 1
endstruc

semaphore_wait:         ; EBX = semaphore pointer
    cli                 ; Critical section
    
    dec dword [ebx + semaphore.count]
    jns .acquired       ; If count >= 0, acquired
    
    ; Need to block
    call get_current_task
    push eax
    lea eax, [ebx + semaphore.wait_queue]
    call queue_add_task
    pop eax
    
    ; Mark task as blocked
    mov byte [eax + TASK_STATE], TASK_BLOCKED
    
    sti
    call scheduler_yield ; Give up CPU
    cli
    
.acquired:
    sti
    ret

semaphore_signal:       ; EBX = semaphore pointer
    cli
    
    inc dword [ebx + semaphore.count]
    
    ; Check if tasks waiting
    lea eax, [ebx + semaphore.wait_queue]
    call queue_is_empty
    jnz .no_waiting
    
    ; Wake up one waiting task
    call queue_remove_task
    mov byte [eax + TASK_STATE], TASK_READY
    call scheduler_add_ready_task
    
.no_waiting:
    sti
    ret

; Mutex with priority inheritance
struc mutex
    .locked: resb 1
    .owner: resd 1
    .original_priority: resb 1
    .wait_queue: resd 1
endstruc

mutex_lock:             ; EBX = mutex pointer
    cli
    
    cmp byte [ebx + mutex.locked], 0
    je .acquire
    
    ; Mutex is locked - check priority inheritance
    call get_current_task
    mov al, [eax + TASK_PRIORITY]
    
    mov ecx, [ebx + mutex.owner]
    cmp al, [ecx + TASK_PRIORITY]
    jbe .no_inheritance
    
    ; Current task has higher priority - boost owner
    mov dl, [ecx + TASK_PRIORITY]
    mov [ebx + mutex.original_priority], dl
    mov [ecx + TASK_PRIORITY], al
    
.no_inheritance:
    ; Add to wait queue and block
    push eax
    lea eax, [ebx + mutex.wait_queue]
    call queue_add_task_priority_order
    pop eax
    
    mov byte [eax + TASK_STATE], TASK_BLOCKED
    sti
    call scheduler_yield
    cli
    jmp mutex_lock      ; Retry after waking
    
.acquire:
    mov byte [ebx + mutex.locked], 1
    call get_current_task
    mov [ebx + mutex.owner], eax
    
    sti
    ret

mutex_unlock:           ; EBX = mutex pointer
    cli
    
    ; Verify owner
    call get_current_task
    cmp [ebx + mutex.owner], eax
    jne .not_owner
    
    ; Restore original priority if inherited
    cmp byte [ebx + mutex.original_priority], 0xFF
    je .no_restore
    
    mov al, [ebx + mutex.original_priority]
    mov [eax + TASK_PRIORITY], al
    mov byte [ebx + mutex.original_priority], 0xFF
    
.no_restore:
    ; Wake highest priority waiting task
    lea eax, [ebx + mutex.wait_queue]
    call queue_remove_task
    test eax, eax
    jz .no_waiting
    
    mov byte [eax + TASK_STATE], TASK_READY
    call scheduler_add_ready_task
    
.no_waiting:
    mov byte [ebx + mutex.locked], 0
    mov dword [ebx + mutex.owner], 0
    
    sti
    ret
    
.not_owner:
    sti
    ; Error - task doesn't own mutex
    ret

; Message queue implementation
struc message_queue
    .buffer: resd 1
    .msg_size: resd 1
    .capacity: resd 1
    .count: resd 1
    .read_idx: resd 1
    .write_idx: resd 1
    .wait_send: resd 1
    .wait_recv: resd 1
endstruc

msg_queue_send:         ; EBX = queue, ESI = message, ECX = timeout
    push edi
    
    cli
    
.check_space:
    mov eax, [ebx + message_queue.count]
    cmp eax, [ebx + message_queue.capacity]
    jb .has_space
    
    ; Queue full - check timeout
    test ecx, ecx
    jz .would_block
    
    ; Block with timeout
    sti
    call get_current_task
    mov byte [eax + TASK_STATE], TASK_BLOCKED
    
    push ecx
    lea eax, [ebx + message_queue.wait_send]
    call queue_add_task
    call scheduler_yield_timeout
    pop ecx
    
    cli
    jmp .check_space
    
.has_space:
    ; Copy message to queue
    mov edi, [ebx + message_queue.buffer]
    mov eax, [ebx + message_queue.write_idx]
    imul eax, [ebx + message_queue.msg_size]
    add edi, eax
    
    push ecx
    mov ecx, [ebx + message_queue.msg_size]
    rep movsb
    pop ecx
    
    ; Update write index
    inc dword [ebx + message_queue.write_idx]
    mov eax, [ebx + message_queue.write_idx]
    cmp eax, [ebx + message_queue.capacity]
    jb .no_wrap_send
    mov dword [ebx + message_queue.write_idx], 0
    
.no_wrap_send:
    inc dword [ebx + message_queue.count]
    
    ; Wake waiting receiver
    lea eax, [ebx + message_queue.wait_recv]
    call queue_remove_task
    test eax, eax
    jz .no_receiver
    
    mov byte [eax + TASK_STATE], TASK_READY
    call scheduler_add_ready_task
    
.no_receiver:
    sti
    clc
    pop edi
    ret
    
.would_block:
    sti
    stc
    pop edi
    ret

msg_queue_receive:      ; EBX = queue, EDI = buffer, ECX = timeout
    push esi
    
    cli
    
.check_messages:
    cmp dword [ebx + message_queue.count], 0
    ja .has_message
    
    ; Queue empty - check timeout
    test ecx, ecx
    jz .would_block
    
    ; Block with timeout
    sti
    call get_current_task
    mov byte [eax + TASK_STATE], TASK_BLOCKED
    
    push ecx
    lea eax, [ebx + message_queue.wait_recv]
    call queue_add_task
    call scheduler_yield_timeout
    pop ecx
    
    cli
    jmp .check_messages
    
.has_message:
    ; Copy message from queue
    mov esi, [ebx + message_queue.buffer]
    mov eax, [ebx + message_queue.read_idx]
    imul eax, [ebx + message_queue.msg_size]
    add esi, eax
    
    push ecx
    mov ecx, [ebx + message_queue.msg_size]
    rep movsb
    pop ecx
    
    ; Update read index
    inc dword [ebx + message_queue.read_idx]
    mov eax, [ebx + message_queue.read_idx]
    cmp eax, [ebx + message_queue.capacity]
    jb .no_wrap_recv
    mov dword [ebx + message_queue.read_idx], 0
    
.no_wrap_recv:
    dec dword [ebx + message_queue.count]
    
    ; Wake waiting sender
    lea eax, [ebx + message_queue.wait_send]
    call queue_remove_task
    test eax, eax
    jz .no_sender
    
    mov byte [eax + TASK_STATE], TASK_READY
    call scheduler_add_ready_task
    
.no_sender:
    sti
    clc
    pop esi
    ret
    
.would_block:
    sti
    stc
    pop esi
    ret
```

### Bootloader Design

Secure and robust bootloader implementation:

```nasm
; Bootloader header
BOOTLOADER_MAGIC equ 0x424F4F54    ; "BOOT"
BOOTLOADER_VERSION equ 0x0100

boot_header:
    dd BOOTLOADER_MAGIC
    dd BOOTLOADER_VERSION
    dd app_start_address
    dd app_size
    dd app_crc32
    dd boot_flags

; Secure boot with signature verification
SIGNATURE_SIZE equ 256

secure_boot_verify:
    ; Load application header
    mov esi, APP_FLASH_BASE
    mov edi, app_header_buffer
    mov ecx, 512
    rep movsb
    
    ; Extract signature
    mov esi, app_header_buffer + 256
    mov edi, signature_buffer
    mov ecx, SIGNATURE_SIZE
    rep movsb
    
    ; Calculate hash of application
    mov esi, APP_FLASH_BASE + 512  ; After header
    mov ecx, [app_size]
    call sha256_hash                ; Result in hash_buffer
    
    ; Verify signature using public key
    mov esi, hash_buffer
    mov edi, signature_buffer
    mov ebx, public_key_buffer
    call rsa_verify                 ; Returns ZF=1 if valid
    jnz .verification_failed
    
    ; Signature valid
    clc
    ret
    
.verification_failed:
    ; Erase application or enter recovery mode
    call enter_recovery_mode
    stc
    ret

; Dual-bank firmware update
; Bank 0: Current running firmware
; Bank 1: New firmware being written

firmware_update_init:
    ; Mark bank 1 as invalid during update
    mov ebx, BANK1_STATUS_ADDR
    mov byte [ebx], 0x00
    
    ; Erase bank 1
    mov ebx, BANK1_BASE
    mov ecx, BANK_SIZE / SECTOR_SIZE
    
.erase_loop:
    push ecx
    call flash_erase_sector
    add ebx, SECTOR_SIZE
    pop ecx
    loop .erase_loop
    
    ; Initialize update context
    mov dword [update_bytes_written], 0
    mov dword [update_crc], 0xFFFFFFFF
    
    ret

firmware_update_write_chunk: ; ESI = data, ECX = length
    push edi
    
    ; Calculate destination address
    mov edi, BANK1_BASE
    add edi, [update_bytes_written]
    
    ; Update running CRC
    push esi
    push ecx
    mov ebx, [update_crc]
    call crc32_update
    mov [update_crc], eax
    pop ecx
    pop esi
    
    ; Write data to flash
.write_loop:
    lodsb
    mov ebx, edi
    call flash_program_byte
    inc edi
    loop .write_loop
    
    ; Update byte counter
    pop ecx
    add [update_bytes_written], ecx
    
    pop edi
    ret

firmware_update_finalize:
    ; Verify CRC
    mov eax, [update_crc]
    not eax
    cmp eax, [expected_crc]
    jne .crc_mismatch
    
    ; Verify size
    mov eax, [update_bytes_written]
    cmp eax, [expected_size]
    jne .size_mismatch
    
    ; Mark bank 1 as valid
    mov ebx, BANK1_STATUS_ADDR
    mov byte [ebx], 0xFF
    
    ; Mark bank 0 for switch on next boot
    mov ebx, BOOT_CONTROL_ADDR
    mov byte [ebx], 0x01    ; Boot from bank 1
    
    ; Verify write
    cmp byte [ebx], 0x01
    jne .write_failed
    
    clc
    ret
    
.crc_mismatch:
.size_mismatch:
.write_failed:
    ; Invalidate bank 1
    mov ebx, BANK1_STATUS_ADDR
    mov byte [ebx], 0x00
    stc
    ret

; Bank switching at boot
boot_bank_select:
    ; Read boot control
    mov ebx, BOOT_CONTROL_ADDR
    mov al, [ebx]
    
    test al, 0x01
    jz .use_bank0
    
    ; Requested bank 1 - verify it's valid
    mov ebx, BANK1_STATUS_ADDR
    cmp byte [ebx], 0xFF
    jne .use_bank0
    
    ; Verify bank 1 integrity
    mov esi, BANK1_BASE
    mov ecx, [app_size]
    call crc32_calc
    cmp eax, [expected_crc]
    jne .use_bank0
    
    ; Bank 1 is valid - use it
    mov eax, BANK1_BASE
    jmp .boot_selected
    
.use_bank0:
    ; Clear boot control if set
    mov ebx, BOOT_CONTROL_ADDR
    mov byte [ebx], 0x00
    
    ; Verify bank 0
    mov esi, BANK0_BASE
    mov ecx, [app_size]
    call crc32_calc
    cmp eax, [expected_crc]
    jne .no_valid_firmware
    
    mov eax, BANK0_BASE
    
.boot_selected:
    ; EAX contains boot address
    ret
    
.no_valid_firmware:
    call enter_recovery_mode
    ; Does not return
    hlt

; Recovery mode via USB DFU
enter_recovery_mode:
    ; Initialize USB peripheral
    call usb_init
    call usb_dfu_init
    
    ; Signal recovery mode (LED pattern, etc.)
    call signal_recovery_mode
    
.recovery_loop:
    call usb_poll
    
    ; Check for valid firmware upload
    cmp byte [dfu_complete], 1
    jne .recovery_loop
    
    ; Verify uploaded firmware
    call firmware_verify_signature
    jc .recovery_loop       ; Invalid, stay in recovery
    
    ; Valid firmware - reset to boot it
    call system_reset
    
    jmp .recovery_loop      ; Should not reach here
```

### Debugging Techniques

On-chip debugging support in assembly:

```nasm
; Breakpoint implementation using debug registers
set_hardware_breakpoint: ; EAX = address, CL = breakpoint number (0-3)
    push ebx
    push eax
    
    ; Set debug address register (DR0-DR3)
    cmp cl, 0
    je .set_dr0
    cmp cl, 1
    je .set_dr1
    cmp cl, 2
    je .set_dr2
    cmp cl, 3
    je .set_dr3
    jmp .invalid
    
.set_dr0:
    mov dr0, eax
    jmp .set_control
.set_dr1:
    mov dr1, eax
    jmp .set_control
.set_dr2:
    mov dr2, eax
    jmp .set_control
.set_dr3:
    mov dr3, eax
    
.set_control:
    ; Configure DR7 (debug control register)
    ; Bit layout: [LEN3][RW3][LEN2][RW2][LEN1][RW1][LEN0][RW0]...[L3][G3]...[L0][G0]
    pop eax
    
    mov ebx, cl
    shl ebx, 1          ; Multiply by 2 for enable bits
    mov eax, 1
    shl eax, bl         ; Local enable bit
    
    mov ebx, dr7
    or ebx, eax         ; Set enable bit
    
    ; Set condition: execution breakpoint (RW = 00, LEN = 00)
    mov eax, cl
    shl eax, 2
    add eax, 16         ; Offset to RW/LEN fields
    ; Fields already 0 for execution breakpoint
    
    mov dr7, ebx
    
    pop ebx
    ret
    
.invalid:
    pop eax
    pop ebx
    stc
    ret

clear_hardware_breakpoint: ; CL = breakpoint number
    push eax
    push ebx
    
    mov eax, dr7
    mov ebx, 1
    mov dl, cl
    shl dl, 1           ; Multiply by 2
    shl ebx, dl
    not ebx
    and eax, ebx        ; Clear enable bit
    mov dr7, eax
    
    pop ebx
    pop eax
    ret

; Watchpoint (data breakpoint)
set_watchpoint:         ; EAX = address, CL = number, DL = type (1=write, 3=read/write)
    push ebx
    push eax
    
    ; Set address in DR0-DR3
    cmp cl, 0
    je .set_wp_dr0
    cmp cl, 1
    je .set_wp_dr1
    cmp cl, 2
    je .set_wp_dr2
    cmp cl, 3
    je .set_wp_dr3
    jmp .invalid_wp
    
.set_wp_dr0:
    mov dr0, eax
    jmp .set_wp_control
.set_wp_dr1:
    mov dr1, eax
    jmp .set_wp_control
.set_wp_dr2:
    mov dr2, eax
    jmp .set_wp_control
.set_wp_dr3:
    mov dr3, eax
    
.set_wp_control:
    pop eax
    
    ; Enable local breakpoint
    mov ebx, 1
    mov al, cl
    shl al, 1
    shl ebx, al
    
    mov eax, dr7
    or eax, ebx
    
    ; Set R/W field
    and edx, 0x03
    mov bl, cl
    shl bl, 2
    add bl, 16
    shl edx, bl
    or eax, edx
    
    ; Set LEN field (4 bytes)
    mov edx, 0x03       ; 4-byte size
    mov bl, cl
    shl bl, 2
    add bl, 18
    shl edx, bl
    or eax, edx
    
    mov dr7, eax
    
    pop ebx
    ret
    
.invalid_wp:
    pop eax
    pop ebx
    stc
    ret

; Debug exception handler
debug_exception_handler:
    pusha
    
    ; Read DR6 to determine cause
    mov eax, dr6
    
    test al, 0x01
    jnz .breakpoint_0
    test al, 0x02
    jnz .breakpoint_1
    test al, 0x04
    jnz .breakpoint_2
    test al, 0x08
    jnz .breakpoint_3
    
    jmp .done
    
.breakpoint_0:
    mov cl, 0
    jmp .handle_breakpoint
.breakpoint_1:
    mov cl, 1
    jmp .handle_breakpoint
.breakpoint_2:
    mov cl, 2
    jmp .handle_breakpoint
.breakpoint_3:
    mov cl, 3
    
.handle_breakpoint:
    ; Log breakpoint hit
    call debug_log_breakpoint
    
    ; Enter debug monitor or halt
    call debug_monitor_entry
    
.done:
    ; Clear DR6
    xor eax, eax
    mov dr6, eax
    
    popa
    iret

; Debug monitor - minimal debugger
debug_monitor_entry:
    ; Save all registers
    pushad
    
    ; Send debug event to host
    mov al, DEBUG_EVENT_BREAK
    call debug_send_event
    
.command_loop:
    ; Wait for debugger command
    call debug_receive_command
    
    cmp al, DEBUG_CMD_CONTINUE
    je .continue
    cmp al, DEBUG_CMD_STEP
    je .single_step
    cmp al, DEBUG_CMD_READ_MEM
    je .read_memory
    cmp al, DEBUG_CMD_WRITE_MEM
    je .write_memory
    cmp al, DEBUG_CMD_READ_REGS
    je .read_registers
    
    jmp .command_loop
    
.continue:
    popad
    ret
    
.single_step:
    ; Set trap flag
    pushf
    pop ax
    or ax, 0x0100       ; Set TF
    push ax
    popf
    
    popad
    ret
    
.read_memory:
    call debug_receive_address
    mov esi, eax
    call debug_receive_length
    mov ecx, eax
    
.read_loop:
    lodsb
    call debug_send_byte
    loop .read_loop
    
    jmp .command_loop
    
.write_memory:
    call debug_receive_address
    mov edi, eax
    call debug_receive_length
    mov ecx, eax
    
.write_loop:
    call debug_receive_byte
    stosb
    loop .write_loop
    
    jmp .command_loop
    
.read_registers:
    ; Send saved register values
    mov esi, esp
    mov ecx, 8          ; 8 registers
    
.reg_loop:
    lodsd
    call debug_send_dword
    loop .reg_loop
    
    jmp .command_loop

; Trace buffer for runtime debugging
TRACE_BUFFER_SIZE equ 256

trace_buffer: times TRACE_BUFFER_SIZE * 8 db 0
trace_write_idx: dd 0

trace_log:              ; EAX = PC, EBX = data
    push edi
    push ecx
    
    ; Get write position
    mov edi, [trace_write_idx]
    imul edi, 8
    add edi, trace_buffer
    
    ; Store entry
    stosd               ; PC
    mov eax, ebx
    stosd               ; Data
    
    ; Update index
    inc dword [trace_write_idx]
    mov eax, [trace_write_idx]
    and eax, (TRACE_BUFFER_SIZE - 1)
    mov [trace_write_idx], eax
    
    pop ecx
    pop edi
    ret

; Assert macro implementation
%macro ASSERT 2
    cmp %1, %2
    je %%assert_ok
    
    ; Assertion failed
    push eax
    push ebx
    mov eax, __LINE__
    mov ebx, %%assert_str
    call assert_failed
    pop ebx
    pop eax
    
    hlt
    
%%assert_ok:
%%assert_str: db "Assertion failed: %1 == %2", 0
%endmacro

assert_failed:          ; EAX = line number, EBX = string
    ; Log assertion failure
    push eax
    push ebx
    
    ; Send over debug interface
    mov cl, DEBUG_EVENT_ASSERT
    call debug_send_event
    
    call debug_send_dword   ; Line number
    
    ; Send string
.send_str:
    mov al, [ebx]
    test al, al
    jz .done
    call debug_send_byte
    inc ebx
    jmp .send_str
    
.done:
    pop ebx
    pop eax
    ret
```

### Safety-Critical Systems

Fault-tolerant code patterns for embedded safety:

```nasm
; Redundant computation with voting
redundant_compute_3x:   ; ESI = input, EDI = output
    push eax
    push ebx
    push ecx
    
    ; Compute three independent copies
    call compute_function   ; Result 1 in EAX
    mov ebx, eax
    
    call compute_function   ; Result 2 in EAX
    mov ecx, eax
    
    call compute_function   ; Result 3 in EAX
    
    ; Vote: majority of 3
    cmp eax, ebx
    je .vote_ab
    cmp eax, ecx
    je .vote_ac
    cmp ebx, ecx
    je .vote_bc
    
    ; All three different - critical error
    call safety_critical_error
    jmp .done
    
.vote_ab:
.vote_ac:
    ; EAX is correct value
    jmp .store_result
    
.vote_bc:
    ; EBX is correct value
    mov eax, ebx
    
.store_result:
    mov [edi], eax
    
.done:
    pop ecx
    pop ebx
    pop eax
    ret

; Memory test - March algorithm
memory_test_march:      ; ESI = start address, ECX = length
    push eax
    push edi
    push ecx
    
    mov edi, esi
    
    ; March element M0: write 0 to all
    xor al, al
    rep stosb
    
    ; March element M1: read 0, write 1, ascending
    pop ecx
    push ecx
    mov edi, esi
    
.m1_loop:
    cmp byte [edi], 0
    jne .memory_error
    mov byte [edi], 0xFF
    inc edi
    loop .m1_loop
    
    ; March element M2: read 1, write 0, ascending
    pop ecx
    push ecx
    mov edi, esi
    
.m2_loop:
    cmp byte [edi], 0xFF
    jne .memory_error
    mov byte [edi], 0
    inc edi
    loop .m2_loop
    
    ; March element M3: read 0, descending
    pop ecx
    mov edi, esi
    add edi, ecx
    dec edi
    
.m3_loop:
    cmp byte [edi], 0
    jne .memory_error
    dec edi
    loop .m3_loop
    
    ; Test passed
    clc
    pop edi
    pop eax
    ret
    
.memory_error:
    ; Log failed address
    push edi
    call log_memory_fault
    pop edi
    
    pop ecx
    pop edi
    pop eax
    stc
    ret

; Watchdog with window monitoring
; Window: must kick between min and max time
wdt_window_init:
    ; Set minimum time
    mov dx, WDT_MIN_TIME
    mov ax, 1000        ; 1000ms minimum
    out dx, ax
    
    ; Set maximum time
    mov dx, WDT_MAX_TIME
    mov ax, 5000        ; 5000ms maximum
    out dx, ax
    
    ; Enable window watchdog
    mov dx, WDT_CONTROL
    mov al, 0x03        ; Enable + window mode
    out dx, al
    
    ; Initialize last kick time
    call get_system_time_ms
    mov [last_wdt_kick], eax
    
    ret

wdt_window_kick:
    ; Check if we're in valid window
    call get_system_time_ms
    sub eax, [last_wdt_kick]
    
    cmp eax, 1000
    jb .too_early
    cmp eax, 5000
    ja .too_late
    
    ; Valid timing - kick watchdog
    mov dx, WDT_KICK
    mov al, 0xAA
    out dx, al
    
    call get_system_time_ms
    mov [last_wdt_kick], eax
    
    clc
    ret
    
.too_early:
.too_late:
    ; Timing violation - log error but don't kick
    call log_watchdog_timing_error
    stc
    ret

; Stack monitoring
STACK_CANARY equ 0xDEADBEEF

stack_canary_init:
    ; Place canary at bottom of stack
    mov eax, STACK_CANARY
    mov ebx, [stack_bottom]
    mov [ebx], eax
    ret

stack_canary_check:
    mov ebx, [stack_bottom]
    cmp dword [ebx], STACK_CANARY
    jne .stack_overflow
    
    clc
    ret
    
.stack_overflow:
    ; Critical error - stack corruption detected
    call safety_critical_error
    stc
    ret

; Function frame validation
function_entry_check:
    ; Save return address for validation
    pop eax                  ; Return address
    mov [function_return_addr], eax

    ; Check stack canary
    call stack_canary_check
    jc .stack_error

    ; Validate return address is in code region
    cmp eax, CODE_START
    jb .invalid_return
    cmp eax, CODE_END
    ja .invalid_return

    ; Restore return address and continue
    push eax
    clc
    ret

.stack_error:
.invalid_return:
    call safety_critical_error
    stc
    ret


function_exit_check:
    ; Verify return address unchanged
    pop eax
    cmp eax, [function_return_addr]
    jne .return_corrupted

    push eax
    clc
    ret

.return_corrupted:
    call safety_critical_error
    stc
    ret


; Code integrity check using CRC
code_integrity_check:
    push esi
    push ecx

    mov esi, CODE_START
    mov ecx, CODE_SIZE
    call crc32_calc

    cmp eax, [code_expected_crc]
    jne .code_corrupted

    pop ecx
    pop esi
    clc
    ret

.code_corrupted:
    ; Code has been modified - critical error
    call safety_critical_error
    pop ecx
    pop esi
    stc
    ret


; Periodic self-test
system_self_test:
    push eax
    push ebx

    ; Test 1: Code integrity
    call code_integrity_check
    jc .test_failed

    ; Test 2: RAM test (partial)
    mov esi, RAM_TEST_REGION
    mov ecx, 1024
    call memory_test_march
    jc .test_failed

    ; Test 3: Peripheral loopback
    call test_uart_loopback
    jc .test_failed

    ; Test 4: Timer accuracy
    call test_timer_accuracy
    jc .test_failed

    ; Test 5: ADC reference check
    call test_adc_reference
    jc .test_failed

    ; All tests passed
    mov byte [self_test_status], 0xFF
    clc
    jmp .done

.test_failed:
    mov byte [self_test_status], 0x00
    call enter_safe_state
    stc

.done:
    pop ebx
    pop eax
    ret


; Safe state entry
enter_safe_state:
    cli

    ; Disable all actuators
    call disable_all_outputs

    ; Set error indicators
    call set_error_led

    ; Log error state
    call log_safe_state_entry

.safe_loop:
    ; Continuous self-check loop
    call system_self_test
    jnc .recovery_possible

    ; Kick watchdog to prevent reset during diagnosis
    call wdt_window_kick

    ; Wait and retry
    call delay_1s
    jmp .safe_loop

.recovery_possible:
    ; Tests now passing - attempt recovery
    call log_recovery_attempt

    ; Gradual system restart
    sti
    call initialize_peripherals
    call resume_normal_operation
    ret


; Dual-channel input validation
read_dual_channel_input:
    ; CL = channel, returns value in AX, CF=1 if mismatch
    push ebx

    ; Read channel A
    call adc_read_channel
    mov bx, ax

    ; Small delay
    push cx
    mov cx, 100
    call delay_us
    pop cx

    ; Read channel B (redundant sensor)
    or cl, 0x80              ; Set bit to select redundant channel
    call adc_read_channel
    and cl, 0x7F             ; Clear redundant bit

    ; Compare readings (allow small tolerance)
    sub ax, bx
    jns .positive_diff
    neg ax

.positive_diff:
    cmp ax, SENSOR_TOLERANCE
    ja .mismatch

    ; Readings agree - return average
    add ax, bx
    shr ax, 1
    clc
    pop ebx
    ret

.mismatch:
    ; Readings disagree - sensor fault
    call log_sensor_mismatch
    stc
    pop ebx
    ret
````

### Sensor Fusion

Combining multiple sensor inputs for accurate state estimation:

```nasm
; Complementary filter for IMU (accelerometer + gyroscope)
; Combines low-pass filtered accelerometer with integrated gyroscope

struc imu_state
    .pitch: resd 1      ; Pitch angle (float representation)
    .roll: resd 1       ; Roll angle
    .yaw: resd 1        ; Yaw angle
    .gyro_x: resw 1     ; Gyroscope readings
    .gyro_y: resw 1
    .gyro_z: resw 1
    .accel_x: resw 1    ; Accelerometer readings
    .accel_y: resw 1
    .accel_z: resw 1
endstruc

FILTER_ALPHA equ 98     ; 98% gyro, 2% accel (scaled by 100)

complementary_filter_update: ; EBX = imu_state, ECX = dt_ms
    push eax
    push edx
    push esi
    push edi
    
    ; Read sensors
    call read_gyroscope     ; Returns gyro_x, gyro_y, gyro_z in AX, DX, SI
    mov [ebx + imu_state.gyro_x], ax
    mov [ebx + imu_state.gyro_y], dx
    mov [ebx + imu_state.gyro_z], si
    
    call read_accelerometer ; Returns accel_x, accel_y, accel_z
    mov [ebx + imu_state.accel_x], ax
    mov [ebx + imu_state.accel_y], dx
    mov [ebx + imu_state.accel_z], si
    
    ; Calculate pitch from accelerometer
    ; pitch_accel = atan2(accel_y, sqrt(accel_x^2 + accel_z^2))
    movsx eax, word [ebx + imu_state.accel_x]
    imul eax, eax       ; accel_x^2
    movsx edx, word [ebx + imu_state.accel_z]
    imul edx, edx       ; accel_z^2
    add eax, edx
    
    call fast_sqrt      ; Result in AX
    movsx edx, word [ebx + imu_state.accel_y]
    call fast_atan2     ; Result in AX (scaled)
    
    mov edi, eax        ; Save pitch_accel
    
    ; Integrate gyroscope for pitch
    movsx eax, word [ebx + imu_state.gyro_x]
    imul eax, ecx       ; gyro * dt
    mov edx, 1000
    idiv edx            ; Divide by 1000 (ms to s)
    add eax, [ebx + imu_state.pitch] ; Add to current pitch
    
    ; Complementary filter: pitch = alpha*pitch_gyro + (1-alpha)*pitch_accel
    mov esi, eax        ; pitch_gyro
    
    imul esi, FILTER_ALPHA
    imul edi, (100 - FILTER_ALPHA)
    add esi, edi
    mov eax, 100
    xor edx, edx
    idiv eax
    
    mov [ebx + imu_state.pitch], esi
    
    ; Similar calculation for roll
    ; roll_accel = atan2(-accel_x, sqrt(accel_y^2 + accel_z^2))
    movsx eax, word [ebx + imu_state.accel_y]
    imul eax, eax
    movsx edx, word [ebx + imu_state.accel_z]
    imul edx, edx
    add eax, edx
    
    call fast_sqrt
    movsx edx, word [ebx + imu_state.accel_x]
    neg edx
    call fast_atan2
    
    mov edi, eax
    
    movsx eax, word [ebx + imu_state.gyro_y]
    imul eax, ecx
    mov edx, 1000
    idiv edx
    add eax, [ebx + imu_state.roll]
    
    mov esi, eax
    imul esi, FILTER_ALPHA
    imul edi, (100 - FILTER_ALPHA)
    add esi, edi
    mov eax, 100
    xor edx, edx
    idiv eax
    
    mov [ebx + imu_state.roll], esi
    
    ; Yaw only from gyroscope (no magnetometer)
    movsx eax, word [ebx + imu_state.gyro_z]
    imul eax, ecx
    mov edx, 1000
    idiv edx
    add [ebx + imu_state.yaw], eax
    
    pop edi
    pop esi
    pop edx
    pop eax
    ret

; Fast square root using Newton-Raphson
fast_sqrt:              ; EAX = input, returns sqrt in AX
    push ebx
    push ecx
    
    test eax, eax
    jz .zero
    
    ; Initial guess: x0 = input / 2
    mov ebx, eax
    shr ebx, 1
    
    ; Newton iteration: x1 = (x0 + n/x0) / 2
    mov ecx, 4          ; 4 iterations
    
.iterate:
    mov eax, ebx
    xor edx, edx
    div ebx             ; n / x0
    add eax, ebx        ; x0 + n/x0
    shr eax, 1          ; / 2
    mov ebx, eax
    loop .iterate
    
    mov ax, bx
    pop ecx
    pop ebx
    ret
    
.zero:
    xor ax, ax
    pop ecx
    pop ebx
    ret

; Fast atan2 approximation
fast_atan2:             ; EAX = y, EDX = x, returns angle in AX (degrees * 10)
    push ebx
    push ecx
    
    ; Handle special cases
    test edx, edx
    jz .x_zero
    
    ; Calculate abs(y/x)
    mov ebx, eax
    xor ecx, ecx        ; Sign tracking
    
    test ebx, ebx
    jns .y_positive
    neg ebx
    inc ecx
    
.y_positive:
    test edx, edx
    jns .x_positive
    neg edx
    inc ecx
    
.x_positive:
    ; ratio = y/x (scaled)
    shl ebx, 8          ; Scale for precision
    mov eax, ebx
    xor edx, edx
    div edx             ; ratio in AX
    
    ; Polynomial approximation: atan(z) ≈ z * (0.9817 - 0.1963*z^2)
    mov ebx, eax        ; Save z
    imul eax, eax       ; z^2
    shr eax, 8          ; Unscale
    
    imul eax, 1963      ; 0.1963 * 10000
    mov edx, 10000
    idiv edx
    
    mov edx, 9817
    sub edx, eax        ; 0.9817 - 0.1963*z^2
    
    mov eax, ebx
    imul edx
    shr eax, 8
    
    ; Adjust for quadrant based on sign tracking
    test cl, 1
    jz .done
    neg eax
    
.done:
    pop ecx
    pop ebx
    ret
    
.x_zero:
    ; Return +/- 90 degrees
    mov ax, 900
    test eax, eax
    jns .x_zero_done
    neg ax
    
.x_zero_done:
    pop ecx
    pop ebx
    ret

; Kalman filter for sensor fusion
struc kalman_state
    .x: resd 1          ; State estimate
    .P: resd 1          ; Estimate covariance
    .Q: resd 1          ; Process noise covariance
    .R: resd 1          ; Measurement noise covariance
endstruc

kalman_predict:         ; EBX = kalman_state, EAX = process_model
    push edx
    
    ; x_pred = F * x (F = process model = 1 for simple case)
    ; Already in [ebx + kalman_state.x]
    
    ; P_pred = F * P * F + Q
    mov eax, [ebx + kalman_state.P]
    add eax, [ebx + kalman_state.Q]
    mov [ebx + kalman_state.P], eax
    
    pop edx
    ret

kalman_update:          ; EBX = kalman_state, EAX = measurement
    push ecx
    push edx
    
    ; Innovation: y = z - H*x (H = 1 for direct measurement)
    mov ecx, eax
    sub ecx, [ebx + kalman_state.x]
    
    ; Innovation covariance: S = H*P*H + R
    mov eax, [ebx + kalman_state.P]
    add eax, [ebx + kalman_state.R]
    
    ; Kalman gain: K = P*H / S
    mov edx, [ebx + kalman_state.P]
    push eax
    xor edx, edx
    div eax             ; K in EAX (scaled)
    pop eax
    
    ; Update estimate: x = x + K*y
    mov edx, ecx
    imul edx, eax       ; K * y
    shr edx, 16         ; Unscale
    add [ebx + kalman_state.x], edx
    
    ; Update covariance: P = (1 - K*H) * P = (1-K)*P
    mov edx, 0x10000
    sub edx, eax        ; 1 - K (scaled)
    mov eax, [ebx + kalman_state.P]
    imul edx
    shr eax, 16
    mov [ebx + kalman_state.P], eax
    
    pop edx
    pop ecx
    ret

; Multi-sensor temperature fusion
temperature_fusion:     ; Returns fused temperature in AX (0.1°C units)
    push ebx
    push ecx
    push edx
    
    ; Read multiple temperature sensors
    mov cl, 0
    call read_temperature_sensor
    mov bx, ax          ; Sensor 0
    
    mov cl, 1
    call read_temperature_sensor
    mov dx, ax          ; Sensor 1
    
    mov cl, 2
    call read_temperature_sensor  ; Sensor 2 in AX
    
    ; Check for outliers (> 5°C difference from others)
    mov cx, bx
    sub cx, dx
    jns .check_01
    neg cx
    
.check_01:
    cmp cx, 50          ; 5.0°C * 10
    ja .outlier_01
    
    ; Check sensor 0 vs 2
    mov cx, bx
    sub cx, ax
    jns .check_02
    neg cx
    
.check_02:
    cmp cx, 50
    ja .outlier_02
    
    ; Check sensor 1 vs 2
    mov cx, dx
    sub cx, ax
    jns .check_12
    neg cx
    
.check_12:
    cmp cx, 50
    ja .outlier_12
    
    ; All sensors agree - simple average
    add ax, bx
    add ax, dx
    mov cx, 3
    xor dx, dx
    div cx
    jmp .done
    
.outlier_01:
    ; Sensor 2 is likely correct
    jmp .done
    
.outlier_02:
    ; Sensor 1 is likely correct
    mov ax, dx
    jmp .done
    
.outlier_12:
    ; Sensor 0 is likely correct
    mov ax, bx
    
.done:
    pop edx
    pop ecx
    pop ebx
    ret
````

### Hardware Abstraction Layer

Creating portable embedded code structure:

```nasm
; HAL structure for GPIO
struc gpio_hal
    .init: resd 1       ; Function pointer: init()
    .set_mode: resd 1   ; Function pointer: set_mode(pin, mode)
    .write: resd 1      ; Function pointer: write(pin, value)
    .read: resd 1       ; Function pointer: read(pin)
    .toggle: resd 1     ; Function pointer: toggle(pin)
endstruc

; HAL structure for UART
struc uart_hal
    .init: resd 1
    .send_byte: resd 1
    .recv_byte: resd 1
    .send_buffer: resd 1
    .recv_buffer: resd 1
    .get_status: resd 1
endstruc

; Platform-specific implementation 1 (e.g., x86 PC)
platform_pc_gpio_init:
    mov dx, 0x378       ; Parallel port base
    mov [gpio_base], dx
    ret

platform_pc_gpio_write: ; CL = pin, AL = value
    push dx
    
    mov dx, [gpio_base]
    test al, al
    jz .write_low
    
    ; Set bit
    in al, dx
    mov bl, 1
    shl bl, cl
    or al, bl
    out dx, al
    jmp .done
    
.write_low:
    in al, dx
    mov bl, 1
    shl bl, cl
    not bl
    and al, bl
    out dx, al
    
.done:
    pop dx
    ret

platform_pc_gpio_read:  ; CL = pin, returns value in AL
    push dx
    
    mov dx, [gpio_base]
    inc dx              ; Status port
    in al, dx
    
    shr al, cl
    and al, 1
    
    pop dx
    ret

; Platform-specific implementation 2 (e.g., ARM Cortex-M)
platform_arm_gpio_init:
    ; Enable GPIO clock
    mov ebx, RCC_AHB1ENR
    or dword [ebx], (1 << GPIOA_EN_BIT)
    ret

platform_arm_gpio_write: ; CL = pin, AL = value
    mov ebx, GPIOA_BSRR  ; Bit set/reset register
    
    mov edx, 1
    movzx ecx, cl
    shl edx, cl
    
    test al, al
    jnz .set_bit
    
    shl edx, 16         ; Reset bits in upper 16 bits
    
.set_bit:
    mov [ebx], edx
    ret

platform_arm_gpio_read: ; CL = pin, returns value in AL
    mov ebx, GPIOA_IDR
    mov eax, [ebx]
    
    shr eax, cl
    and al, 1
    ret

; HAL initialization based on platform
hal_init:
    ; Detect platform (various methods)
    call detect_platform
    
    cmp al, PLATFORM_PC
    je .init_pc
    cmp al, PLATFORM_ARM
    je .init_arm
    jmp .unknown_platform
    
.init_pc:
    ; Initialize PC HAL
    mov dword [gpio_hal + gpio_hal.init], platform_pc_gpio_init
    mov dword [gpio_hal + gpio_hal.write], platform_pc_gpio_write
    mov dword [gpio_hal + gpio_hal.read], platform_pc_gpio_read
    jmp .done
    
.init_arm:
    ; Initialize ARM HAL
    mov dword [gpio_hal + gpio_hal.init], platform_arm_gpio_init
    mov dword [gpio_hal + gpio_hal.write], platform_arm_gpio_write
    mov dword [gpio_hal + gpio_hal.read], platform_arm_gpio_read
    jmp .done
    
.unknown_platform:
    stc
    ret
    
.done:
    ; Call platform-specific init
    call [gpio_hal + gpio_hal.init]
    clc
    ret

; Application code using HAL (platform-independent)
application_blink_led:
    ; Initialize GPIO through HAL
    call [gpio_hal + gpio_hal.init]
    
    ; Configure LED pin as output
    mov cl, LED_PIN
    mov al, GPIO_MODE_OUTPUT
    call [gpio_hal + gpio_hal.set_mode]
    
.blink_loop:
    ; Turn LED on
    mov cl, LED_PIN
    mov al, 1
    call [gpio_hal + gpio_hal.write]
    
    call delay_500ms
    
    ; Turn LED off
    mov cl, LED_PIN
    mov al, 0
    call [gpio_hal + gpio_hal.write]
    
    call delay_500ms
    
    jmp .blink_loop

; Device driver structure
struc device_driver
    .name: resb 32
    .init: resd 1
    .open: resd 1
    .close: resd 1
    .read: resd 1
    .write: resd 1
    .ioctl: resd 1
    .private_data: resd 1
endstruc

; Driver registration
driver_register:        ; EBX = device_driver structure
    push eax
    push esi
    push edi
    
    ; Find empty slot in driver table
    mov esi, driver_table
    mov ecx, MAX_DRIVERS
    
.find_slot:
    cmp dword [esi + device_driver.init], 0
    je .found_slot
    
    add esi, device_driver_size
    loop .find_slot
    
    ; No free slot
    stc
    jmp .done
    
.found_slot:
    ; Copy driver structure
    mov edi, esi
    mov esi, ebx
    mov ecx, device_driver_size
    rep movsb
    
    ; Call driver init
    call [edi + device_driver.init]
    
    clc
    
.done:
    pop edi
    pop esi
    pop eax
    ret

; Generic device interface
device_open:            ; EAX = device name, returns handle in EAX
    push ebx
    push esi
    push edi
    
    mov esi, driver_table
    mov ecx, MAX_DRIVERS
    
.search:
    ; Compare name
    mov edi, eax
    lea ebx, [esi + device_driver.name]
    push ecx
    mov ecx, 32
    
.compare_name:
    mov al, [edi]
    cmp al, [ebx]
    jne .name_mismatch
    
    test al, al
    jz .name_match
    
    inc edi
    inc ebx
    loop .compare_name
    
.name_match:
    pop ecx
    
    ; Found device - call open function
    push esi
    call [esi + device_driver.open]
    pop eax             ; Return handle (driver structure pointer)
    
    jmp .found
    
.name_mismatch:
    pop ecx
    add esi, device_driver_size
    loop .search
    
    ; Device not found
    xor eax, eax
    stc
    
.found:
    pop edi
    pop esi
    pop ebx
    ret

device_read:            ; EAX = handle, ESI = buffer, ECX = length
    push ebx
    
    mov ebx, eax
    call [ebx + device_driver.read]
    
    pop ebx
    ret

device_write:           ; EAX = handle, ESI = buffer, ECX = length
    push ebx
    
    mov ebx, eax
    call [ebx + device_driver.write]
    
    pop ebx
    ret

device_close:           ; EAX = handle
    push ebx
    
    mov ebx, eax
    call [ebx + device_driver.close]
    
    pop ebx
    ret
```

**Conclusion:** Embedded systems programming in x86 assembly requires mastery of hardware interfaces, resource management, real-time constraints, and safety considerations. The techniques covered include direct peripheral control, interrupt handling, state machines, sensor fusion, fault tolerance, and hardware abstraction for portability. Assembly provides the deterministic execution and minimal overhead essential for embedded applications where timing, memory, and power consumption are critical constraints.

**Next Steps:**

- Study specific microcontroller datasheets for register-level programming details
- Practice implementing communication protocols (CAN, Modbus, etc.)
- Explore RTOS internals and task scheduling algorithms
- Investigate power optimization techniques for battery-operated devices
- Learn formal verification methods for safety-critical code

---

## Power Management

Power management in x86 embedded systems involves controlling CPU states, peripheral power, and system-wide energy consumption through assembly-level instructions and hardware interfaces.

### CPU Power States (C-States)

x86 processors implement ACPI-defined C-states for power management:

- **C0**: Active state, CPU fully operational
- **C1**: Halt state, clock gating active
- **C2**: Stop-clock state, processor caches maintained
- **C3**: Deep sleep, cache flushing may occur
- **C6**: Deep power down, core voltage reduced

**Example** - Entering C1 state:

```asm
; Simple halt instruction for C1
halt_cpu:
    cli                 ; Disable interrupts
    hlt                 ; Enter C1 state
    sti                 ; Re-enable interrupts after wake
    ret

; Halt with interrupt handling
power_save_loop:
    hlt                 ; CPU enters low power until interrupt
    jmp power_save_loop ; Continue loop after handling interrupt
```

### MWAIT/MONITOR Instructions

Modern x86 CPUs provide MWAIT/MONITOR for efficient idle states without polling:

```asm
; Check if MWAIT is supported
check_mwait:
    mov eax, 1
    cpuid
    test ecx, (1 << 3)  ; Check MONITOR/MWAIT bit
    jz no_mwait_support
    ret

; Use MONITOR/MWAIT for power-efficient waiting
wait_for_memory_change:
    lea rax, [memory_location]
    xor ecx, ecx        ; Extensions (0)
    xor edx, edx        ; Hints (0)
    monitor             ; Set up monitoring
    
    ; Check condition before sleeping
    cmp dword [memory_location], 0
    jne condition_met
    
    xor eax, eax        ; C1 state
    xor ecx, ecx        ; Sub C-state hints
    mwait               ; Enter power-efficient wait
    
condition_met:
    ret
```

### MSR Programming for Power Control

Model-Specific Registers (MSRs) control deep power features:

```asm
; Read MSR (requires CPL 0)
read_msr:
    mov ecx, 0x199      ; IA32_PERF_CTL MSR
    rdmsr               ; EDX:EAX = MSR value
    ret

; Write MSR to control P-states
set_pstate:
    mov ecx, 0x199      ; IA32_PERF_CTL
    xor edx, edx
    mov eax, 0x0A00     ; Set P-state (example value)
    wrmsr
    ret

; Enable Enhanced SpeedStep
enable_speedstep:
    mov ecx, 0x1A0      ; IA32_MISC_ENABLE
    rdmsr
    or eax, (1 << 16)   ; Enable EIST bit
    wrmsr
    ret
```

### Clock Gating and Frequency Scaling

```asm
; Request frequency change via ACPI
; This typically involves writing to I/O ports
set_cpu_frequency:
    push ebp
    mov ebp, esp
    
    ; Write to ACPI P_CNT register (example address)
    mov dx, 0x4010      ; P_CNT I/O port (system-specific)
    mov al, [ebp+8]     ; Frequency code parameter
    out dx, al
    
    ; Wait for frequency transition
    mov ecx, 1000
.wait_loop:
    pause
    loop .wait_loop
    
    pop ebp
    ret
```

### Peripheral Power Control

```asm
; Disable unused PCI devices
disable_pci_device:
    ; Read PCI configuration space
    mov eax, 0x80000000 ; Enable bit
    or eax, (bus << 16)
    or eax, (dev << 11)
    or eax, (func << 8)
    or eax, 0x04        ; Command register offset
    mov dx, 0xCF8       ; PCI config address port
    out dx, eax
    
    ; Read current command register
    mov dx, 0xCFC       ; PCI config data port
    in ax, dx
    
    ; Disable I/O and Memory space
    and ax, ~0x03
    out dx, ax
    ret

; Control GPIO for peripheral power
gpio_power_off:
    mov dx, 0x500       ; GPIO base (system-specific)
    in al, dx
    and al, ~(1 << 3)   ; Clear power enable bit
    out dx, al
    ret
```

### Timer and Interrupt Optimization

```asm
; Configure HPET for low-power periodic interrupts
setup_hpet_oneshot:
    mov rsi, [hpet_base]
    
    ; Disable timer
    mov rax, [rsi + 0x100]  ; Timer 0 config
    and rax, ~(1 << 2)      ; Clear enable bit
    mov [rsi + 0x100], rax
    
    ; Set one-shot mode
    and rax, ~(1 << 3)      ; Clear periodic bit
    or rax, (1 << 1)        ; Enable interrupt
    mov [rsi + 0x100], rax
    
    ; Set comparator value
    mov rax, [rsi + 0xF0]   ; Read main counter
    add rax, 1000000        ; Trigger in 1ms (example)
    mov [rsi + 0x108], rax  ; Set comparator
    
    ; Enable timer
    mov rax, [rsi + 0x100]
    or rax, (1 << 2)
    mov [rsi + 0x100], rax
    ret
```

## Firmware Development

Firmware for x86 embedded systems operates in real mode, protected mode, and long mode, often without an operating system.

### Boot Sequence and Initialization

**Example** - Basic bootloader in real mode:

```asm
[BITS 16]
[ORG 0x7C00]

boot_start:
    ; Initialize segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    ; Enable A20 line
    call enable_a20
    
    ; Load firmware from disk
    mov ah, 0x02        ; Read sectors
    mov al, 10          ; Number of sectors
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Sector 2
    mov dh, 0           ; Head 0
    mov bx, 0x1000      ; Load to 0x1000
    int 0x13
    jc disk_error
    
    ; Switch to protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:protected_mode_entry

enable_a20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

disk_error:
    mov si, error_msg
    call print_string
    hlt

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

error_msg: db "Disk error!", 0

gdt_start:
    dq 0                ; Null descriptor
    dq 0x00CF9A000000FFFF ; Code segment
    dq 0x00CF92000000FFFF ; Data segment
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

times 510-($-$$) db 0
dw 0xAA55
```

### Protected Mode Initialization

```asm
[BITS 32]
protected_mode_entry:
    ; Set up segment registers
    mov ax, 0x10        ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000    ; Stack at 640KB mark
    
    ; Initialize IDT for interrupts
    call setup_idt
    
    ; Enable paging if needed
    call setup_paging
    
    ; Initialize hardware
    call init_hardware
    
    ; Jump to main firmware
    jmp firmware_main

setup_idt:
    lidt [idt_descriptor]
    ret

idt_descriptor:
    dw (256 * 8) - 1    ; Limit
    dd idt_table        ; Base address
```

### Interrupt Service Routines

```asm
; Timer ISR
timer_isr:
    push eax
    push ebx
    
    ; Increment tick counter
    inc dword [system_ticks]
    
    ; Send EOI to PIC
    mov al, 0x20
    out 0x20, al
    
    pop ebx
    pop eax
    iret

; Install ISR
install_timer_isr:
    ; Calculate IDT entry address
    mov eax, idt_table
    add eax, (0x20 * 8) ; IRQ0 = INT 0x20
    
    ; Set offset low
    mov ebx, timer_isr
    mov [eax], bx
    
    ; Set selector (code segment)
    mov word [eax + 2], 0x08
    
    ; Set flags (present, DPL=0, 32-bit interrupt gate)
    mov byte [eax + 5], 0x8E
    
    ; Set offset high
    shr ebx, 16
    mov [eax + 6], bx
    
    ret
```

### Hardware Initialization

```asm
init_hardware:
    ; Initialize PIC (8259)
    ; ICW1
    mov al, 0x11
    out 0x20, al        ; Master PIC
    out 0xA0, al        ; Slave PIC
    
    ; ICW2 (interrupt vector offset)
    mov al, 0x20
    out 0x21, al        ; Master starts at 0x20
    mov al, 0x28
    out 0xA1, al        ; Slave starts at 0x28
    
    ; ICW3 (cascade)
    mov al, 0x04
    out 0x21, al        ; Master has slave on IRQ2
    mov al, 0x02
    out 0xA1, al        ; Slave cascade identity
    
    ; ICW4 (mode)
    mov al, 0x01
    out 0x21, al        ; 8086 mode
    out 0xA1, al
    
    ; Unmask interrupts
    mov al, 0xFE        ; Enable timer only
    out 0x21, al
    mov al, 0xFF        ; Mask all on slave
    out 0xA1, al
    
    ; Initialize PIT (8254) for 1ms ticks
    mov al, 0x36        ; Channel 0, rate generator
    out 0x43, al
    mov ax, 1193        ; Divisor for 1ms (1193182 Hz / 1193 ≈ 1000 Hz)
    out 0x40, al        ; Low byte
    mov al, ah
    out 0x40, al        ; High byte
    
    ; Initialize serial port
    call init_serial
    
    ret

init_serial:
    mov dx, 0x3F8       ; COM1 base
    
    ; Disable interrupts
    add dx, 1
    xor al, al
    out dx, al
    
    ; Enable DLAB
    add dx, 2
    mov al, 0x80
    out dx, al
    
    ; Set baud rate to 115200 (divisor = 1)
    sub dx, 3
    mov al, 1
    out dx, al
    inc dx
    xor al, al
    out dx, al
    
    ; 8N1, disable DLAB
    add dx, 2
    mov al, 0x03
    out dx, al
    
    ; Enable FIFO
    inc dx
    mov al, 0xC7
    out dx, al
    
    ret
```

### Flash Memory Programming

```asm
; Write to flash memory (NOR flash example)
flash_write_byte:
    push ebp
    mov ebp, esp
    push ebx
    
    mov ebx, [ebp + 8]  ; Flash address
    mov al, [ebp + 12]  ; Data byte
    
    ; Unlock sequence
    mov byte [ebx + 0x5555], 0xAA
    mov byte [ebx + 0x2AAA], 0x55
    mov byte [ebx + 0x5555], 0xA0
    
    ; Program byte
    mov [ebx], al
    
    ; Wait for completion (poll DQ7)
.wait:
    mov cl, [ebx]
    xor cl, al
    test cl, 0x80
    jnz .wait
    
    pop ebx
    pop ebp
    ret

; Erase flash sector
flash_erase_sector:
    push ebp
    mov ebp, esp
    push ebx
    
    mov ebx, [ebp + 8]  ; Sector address
    
    ; Unlock sequence
    mov byte [ebx + 0x5555], 0xAA
    mov byte [ebx + 0x2AAA], 0x55
    mov byte [ebx + 0x5555], 0x80
    mov byte [ebx + 0x5555], 0xAA
    mov byte [ebx + 0x2AAA], 0x55
    mov byte [ebx], 0x30
    
    ; Wait for completion
.wait:
    mov al, [ebx]
    test al, 0x80
    jz .wait
    
    pop ebx
    pop ebp
    ret
```

### Watchdog Timer Implementation

```asm
; Software watchdog using PIT
init_watchdog:
    mov dword [watchdog_counter], 5000  ; 5 second timeout
    mov byte [watchdog_enabled], 1
    ret

; Call in timer ISR
watchdog_tick:
    cmp byte [watchdog_enabled], 0
    je .disabled
    
    dec dword [watchdog_counter]
    jz system_reset
.disabled:
    ret

watchdog_feed:
    mov dword [watchdog_counter], 5000
    ret

system_reset:
    ; Reset via keyboard controller
    mov al, 0xFE
    out 0x64, al
    hlt
```

## Cross-Compilation

Cross-compilation involves building x86 assembly code on one platform to run on an embedded x86 target.

### Toolchain Setup

**Example** - Assembler selection and flags:

```bash
