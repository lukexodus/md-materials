## Privilege Levels and Rings


### Protection Ring Architecture

x86 processors implement a four-level privilege hierarchy known as protection rings, numbered 0 through 3, where lower numbers indicate higher privilege:

```
Ring 0: Kernel mode (highest privilege)
  - Operating system kernel
  - Device drivers (typically)
  - Full hardware access
  - All instructions available
  - Direct I/O port access

Ring 1: Device drivers (rarely used)
  - Intended for OS services
  - Limited hardware access

Ring 2: Device drivers (rarely used)
  - Intended for OS services
  - More limited access

Ring 3: User mode (lowest privilege)
  - Application programs
  - Restricted instruction set
  - No direct hardware access
  - Memory access controlled by paging
```

[Inference] Modern operating systems typically use only rings 0 (kernel) and 3 (user mode), leaving rings 1 and 2 unused. This simplified two-level model provides sufficient isolation between kernel and user space while avoiding the complexity of managing intermediate privilege levels.

### Current Privilege Level (CPL)

The processor's Current Privilege Level (CPL) is stored in bits 0-1 of the CS (Code Segment) register. The CPL determines which instructions can execute and which memory regions can be accessed.

```
CS register format:
Bits 15-3: Segment Selector Index
Bits 2:    Table Indicator (0=GDT, 1=LDT)
Bits 1-0:  Requested Privilege Level (RPL) / Current Privilege Level (CPL)
```

When executing code, the processor continuously enforces privilege checks based on CPL:

```nasm
; Reading current privilege level
mov ax, cs          ; Get code segment selector
and ax, 3           ; Extract CPL (bits 0-1)
; AL now contains 0 (kernel) or 3 (user)
```

[Inference] The hardware-enforced privilege level in the segment selector prevents software from arbitrarily changing its privilege, as loading a new CS value requires using control transfer instructions (CALL, JMP, INT, SYSENTER, SYSCALL) that enforce privilege transition rules.

### Descriptor Privilege Level (DPL)

Each segment descriptor in the Global Descriptor Table (GDT) or Local Descriptor Table (LDT) contains a Descriptor Privilege Level (DPL) field that specifies the minimum privilege required to access that segment.

```
Segment Descriptor format (simplified):
Bits 45-46: DPL (Descriptor Privilege Level)
  00 = Ring 0 (kernel)
  01 = Ring 1
  10 = Ring 2
  11 = Ring 3 (user)
```

The processor performs privilege checks when loading segment registers:

```
Access allowed if: CPL ≤ DPL (numerically)
  CPL=0 can access any segment (DPL 0-3)
  CPL=3 can access only DPL=3 segments
```

[Inference] This mechanism prevents user-mode code from loading kernel-mode segment selectors, ensuring that applications cannot directly access kernel memory regions even if they know the segment selector values.

### Requested Privilege Level (RPL)

The Requested Privilege Level (RPL) occupies the same bit positions as CPL but applies to segment selectors used as operands rather than the current code segment. The RPL allows kernel code to access memory on behalf of user processes at the user's privilege level.

```
Effective privilege = MAX(CPL, RPL)  ; numerically maximum (least privileged)

Example:
  CPL = 0 (kernel mode)
  Segment selector RPL = 3 (user level)
  Access performed with effective privilege = 3
```

[Inference] The RPL mechanism enables kernel code to safely access user-space memory regions without accidentally using kernel privileges, preventing security vulnerabilities where kernel code might inadvertently access restricted memory when handling user requests.

### Privilege Level Transitions

Transitions between privilege levels must occur through controlled mechanisms that the processor validates:

**Ring 3 → Ring 0 (User to Kernel)**:

- Interrupt gates (INT instruction)
- System call instructions (SYSCALL, SYSENTER)
- Hardware interrupts
- Exceptions and faults

**Ring 0 → Ring 3 (Kernel to User)**:

- IRET/IRETQ (Interrupt Return)
- SYSEXIT, SYSRET (System Call Return)
- Far RETURN through call gates

Arbitrary privilege transitions are impossible. [Inference] This hardware enforcement ensures that user applications cannot execute kernel code except through explicitly defined entry points, maintaining system security and stability.

### Privileged Instructions

Certain instructions execute only at CPL=0, generating general protection faults (#GP) if attempted at lower privilege:

**I/O Port Access**:

- IN, OUT, INS, OUTS (if IOPL < CPL or I/O bitmap denies access)

**System Control**:

- LGDT, LLDT (Load GDT/LDT registers)
- LTR (Load Task Register)
- LIDT (Load Interrupt Descriptor Table)
- MOV to/from control registers (CR0, CR2, CR3, CR4)
- MOV to/from debug registers (DR0-DR7)

**Cache and TLB Management**:

- INVD, WBINVD (Invalidate/Write-back cache)
- INVLPG (Invalidate TLB entry)
- INVPCID (Invalidate PCID entries)

**System Mode Control**:

- HLT (Halt processor)
- RDMSR, WRMSR (Read/Write Model-Specific Registers)
- RDPMC (Read Performance Monitoring Counter, may be allowed in user mode via CR4.PCE)

```nasm
; Privileged instruction example (kernel mode only)
mov eax, cr3        ; Read CR3 (page table base)
; If executed at CPL=3, generates #GP exception

; User mode attempting privileged instruction
user_code:
    mov eax, cr0    ; Causes #GP(0) exception
    ; Processor transfers control to exception handler
```

[Inference] The privileged instruction set prevents user applications from manipulating hardware state, memory mappings, or system configuration, ensuring that only trusted kernel code can perform operations affecting system-wide state.

### IOPL (I/O Privilege Level)

The I/O Privilege Level field in the EFLAGS/RFLAGS register (bits 12-13) controls I/O instruction execution. User-mode code can execute I/O instructions only if CPL ≤ IOPL.

```
IOPL bits in RFLAGS:
Bits 12-13: I/O Privilege Level
  00 = Ring 0 only
  01 = Rings 0-1
  10 = Rings 0-2
  11 = All rings (0-3)
```

Most modern operating systems set IOPL=0, prohibiting direct I/O port access from user mode. [Inference] This forces applications to use kernel services for hardware interaction, maintaining centralized control and preventing applications from interfering with each other's device access.

```nasm
; Checking IOPL
pushfq
pop rax
shr rax, 12
and rax, 3          ; Extract IOPL
; RAX contains current IOPL value
```

### I/O Permission Bitmap

The Task State Segment (TSS) can contain an I/O Permission Bitmap that provides fine-grained control over individual I/O port access. Each bit in the bitmap corresponds to one I/O port address:

```
Bitmap bit = 0: Access allowed
Bitmap bit = 1: Access denied (#GP exception)
```

[Inference] The I/O permission bitmap allows selective port access for user-mode code without granting full IOPL=3 privileges. This mechanism enables specialized applications (device testing, emulation) to access specific ports while maintaining security for other ports.

```nasm
; TSS with I/O bitmap
tss_structure:
    ; ... TSS fields ...
    dw io_bitmap_offset     ; Offset to I/O bitmap within TSS
    
io_bitmap:
    ; Bitmap: 8192 bytes covering ports 0-65535
    ; Each byte represents 8 ports
    db 0xFF, 0xFF, ...      ; All access denied
    db 0x00, ...            ; Byte allowing specific ports
```

### Long Mode (x86-64) Privilege Model

In 64-bit long mode, the protection ring architecture remains fundamentally unchanged, with CPL stored in CS bits 0-1. However, segmentation is largely disabled except for FS and GS registers.

[Inference] The simplified segmentation in long mode reduces complexity while maintaining the essential privilege separation between kernel (ring 0) and user space (ring 3). The paging mechanism becomes the primary memory protection mechanism in 64-bit mode.

**Long Mode Privilege Features**:

- Segment limits ignored (except for FS/GS base address validation)
- Paging provides primary memory protection
- User/Supervisor page bit (U/S) in page tables controls memory access
- Execute Disable (NX/XD) bit prevents code execution from data pages
- SMEP (Supervisor Mode Execution Prevention) prevents kernel from executing user code
- SMAP (Supervisor Mode Access Prevention) prevents kernel from accessing user data without explicit override

