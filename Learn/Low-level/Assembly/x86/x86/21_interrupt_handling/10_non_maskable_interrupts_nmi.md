## Non-Maskable Interrupts (NMI)


Non-Maskable Interrupts represent the highest priority external interrupt that cannot be disabled through software, making them critical for handling urgent hardware conditions.

**NMI Characteristics**:

**Vector Assignment**: NMI always uses interrupt vector 2, hardwired in the processor.

**Non-Maskable Nature**: Unlike maskable interrupts controlled by the IF (Interrupt Enable Flag), NMIs cannot be disabled by CLI instruction or clearing the IF flag. This ensures critical hardware signals always receive immediate attention.

**NMI Sources**: Common triggers include:

- Parity errors in RAM (memory corruption detection)
- I/O channel check errors (critical hardware failures)
- Watchdog timer expirations (system hang detection)
- System management interrupts in some configurations
- Hardware debugging and profiling tools
- Critical hardware failure notifications (power supply issues, overheating)

**NMI Blocking**: While NMIs cannot be masked, the processor implements NMI blocking to prevent NMI nesting:

- After NMI delivery, the processor blocks further NMIs
- The block is released only after IRET execution from the NMI handler
- This prevents an NMI handler from being interrupted by another NMI

**Example**: Basic NMI handler structure

```assembly
nmi_handler:
    ; NMIs are automatically blocked at this point
    ; No need to disable interrupts - already atomic
    
    ; Save all registers (critical since we don't know what was interrupted)
    pushad
    push ds
    push es
    push fs
    push gs
    
    ; Set up kernel segments
    mov ax, 0x10            ; Kernel data segment
    mov ds, ax
    mov es, ax
    
    ; Read NMI status from hardware (platform-specific)
    in al, 0x61             ; PC/AT compatible systems
    mov bl, al
    
    ; Check NMI source bits
    test al, 0x80           ; Test bit 7 (parity error)
    jz .check_io_error
    
    ; Handle memory parity error
    call handle_parity_error
    jmp .acknowledge
    
.check_io_error:
    test bl, 0x40           ; Test bit 6 (I/O channel check)
    jz .unknown_nmi
    
    ; Handle I/O error
    call handle_io_error
    jmp .acknowledge
    
.unknown_nmi:
    ; Log unknown NMI for diagnostics
    call log_unknown_nmi
    
.acknowledge:
    ; Clear NMI condition (platform-specific)
    or al, 0x80             ; Set bit to acknowledge
    out 0x61, al            ; Write back
    
    ; Restore registers
    pop gs
    pop fs
    pop es
    pop ds
    popad
    
    ; IRET re-enables NMIs
    iret
```

**NMI Enable/Disable Port (Port 0x70)**: [Inference: On IBM PC-compatible systems, port 0x70 is commonly used to control NMI]

- Bit 7 controls NMI enable/disable at the hardware level
- Setting bit 7 = 1 disables NMI at the chipset level
- Clearing bit 7 = 0 re-enables NMI
- This is the ONLY way to prevent NMIs (hardware-level disable)

```assembly
; Disable NMI at hardware level
disable_nmi:
    in al, 0x70
    or al, 0x80             ; Set bit 7
    out 0x70, al
    ret

; Enable NMI at hardware level  
enable_nmi:
    in al, 0x70
    and al, 0x7F            ; Clear bit 7
    out 0x70, al
    ret
```

**NMI vs SMI (System Management Interrupt)**: [Inference: Based on x86 architecture specifications]

- **NMI**: Visible to operating system, uses IDT vector 2, handler runs in current privilege level
- **SMI**: Completely transparent to OS, enters System Management Mode (SMM), highest priority, uses dedicated SMRAM

**NMI Handler Requirements**:

**Register Preservation**: NMI handlers must save and restore ALL registers, including segment registers, since the NMI can interrupt any code at any point:

```assembly
    pushad                  ; Save general purpose registers
    push ds                 ; Save segment registers
    push es
    push fs
    push gs
```

**Minimal Execution Time**: NMI handlers should execute as quickly as possible since they block subsequent NMIs. Long-running handlers can cause NMI loss.

**Safe Stack Usage**: [Inference: The handler must verify stack validity since NMI can interrupt during stack operations]

```assembly
    ; Check if stack is valid before using
    mov eax, esp
    and eax, 0xFFF         ; Check if near page boundary
    cmp eax, 16            ; Need at least space for handler
    jl .use_emergency_stack
```

**No Nested NMIs**: Handler design must account for the fact that no NMIs will be serviced during execution until IRET.

**Critical Section Protection**: [Inference: Since NMIs interrupt even CLI-protected code]

```assembly
    ; Critical sections cannot rely on CLI alone
    ; NMIs can still interrupt
    cli                     ; Disable maskable interrupts
    call disable_nmi        ; Must also disable NMI for true atomicity
    
    ; Critical code
    ; ...
    
    call enable_nmi
    sti
```

**NMI Watchdog**: [Inference: Common usage in operating systems] Modern operating systems use NMI for watchdog timers to detect system hangs:

- Timer generates periodic NMIs
- Handler verifies system is making progress
- If handler doesn't run (system hung), hardware reset triggered
- Each CPU core can have independent NMI watchdog

**NMI Performance Monitoring**: [Inference: Usage in profiling tools] Performance monitoring tools use NMI for interrupt-based sampling:

- Configure performance counter to overflow
- Overflow triggers NMI
- NMI handler records instruction pointer for profiling
- Provides accurate sampling even in kernel mode

**Key Points**:

- NMIs always use vector 2, cannot be changed
- IF flag and CLI instruction have no effect on NMIs
- Only hardware-level disable (port 0x70) can prevent NMIs
- NMIs are automatically blocked during NMI handler execution until IRET
- Handler must preserve ALL registers as interruption point is unpredictable
- NMIs should not be blocked for extended periods as subsequent NMIs will be lost
- Double NMI can occur if NMI arrives while previous NMI is being delivered but before blocking activates [Unverified]
- NMI handlers cannot use some debugging techniques like breakpoints since NMI can interrupt debugger code
- Modern systems may route different NMI sources through different mechanisms (APIC vs legacy)

**Debugging NMI Issues**:

NMI-related bugs are notoriously difficult to debug:

- Can interrupt at any instruction, making timing-dependent bugs
- Cannot be masked for debugging
- May indicate critical hardware failures
- Spurious NMIs can occur due to hardware glitches

```assembly
; NMI counter for diagnostics
nmi_counter: dd 0

nmi_handler:
    pushad
    
    ; Increment counter atomically
    lock inc dword [nmi_counter]
    
    ; Log NMI occurrence with timestamp
    call get_tsc            ; Read time-stamp counter
    mov [nmi_timestamp], eax
    
    ; Continue with normal NMI handling
    ; ...
    
    popad
    iret
```

**Related Topics for Further Study**: Interrupt controller programming (8259 PIC and APIC), Task State Segment (TSS) configuration, Protected mode privilege levels and transitions, System Management Mode (SMM) and System Management Interrupts (SMI), Hardware debugging facilities (debug registers DR0-DR7), x86-64 long mode interrupt handling differences

---

