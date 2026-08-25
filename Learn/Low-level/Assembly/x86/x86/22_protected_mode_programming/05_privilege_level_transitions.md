## Privilege Level Transitions


x86 protected mode implements four privilege levels (rings 0-3) to enforce protection between system code and user code. Privilege level transitions are strictly controlled by the processor.

### Privilege Levels

- **Ring 0**: Highest privilege (kernel, device drivers)
- **Ring 1**: Device drivers (rarely used in modern systems)
- **Ring 2**: Device drivers (rarely used in modern systems)
- **Ring 3**: Lowest privilege (user applications)

Modern operating systems typically use only Ring 0 (kernel) and Ring 3 (user mode).

### Privilege Level Indicators

**CPL (Current Privilege Level)**:

- Stored in bits 0-1 of the CS selector
- Indicates the privilege level of currently executing code
- Changes only during control transfers

**DPL (Descriptor Privilege Level)**:

- Stored in the segment descriptor
- Indicates the privilege level required to access the segment

**RPL (Requested Privilege Level)**:

- Stored in bits 0-1 of a selector
- Used in privilege checks for data segments
- Allows less privileged code to request access on behalf of caller

### Privilege Checking Rules

**For Data Segments:**

```
Access granted if: MAX(CPL, RPL) ≤ DPL
```

The effective privilege level is the lower of CPL and RPL. Access is granted only if this is numerically less than or equal to DPL (higher or equal privilege).

**For Code Segments (Non-conforming):**

```
Access granted if: CPL = DPL and RPL ≤ DPL
```

Non-conforming code segments can only be accessed by code at exactly the same privilege level.

**For Code Segments (Conforming):**

```
Access granted if: CPL ≥ DPL
```

Conforming code segments can be accessed by equal or lower privilege levels (numerically higher CPL). When executed, CPL doesn't change.

### Control Transfer Mechanisms

#### Direct Jump/Call (JMP/CALL)

**Same Privilege Level:**

```nasm
jmp 0x08:offset     ; Jump to code segment selector 0x08
call 0x08:offset    ; Call code segment selector 0x08
```

Requirements:

- Target segment DPL must equal CPL
- For non-conforming segments: CPL = DPL = RPL
- For conforming segments: CPL ≥ DPL

**Different Privilege Level:** Direct JMP/CALL to a different privilege level is not allowed through far pointers. The processor generates a general protection fault. Privilege transitions require call gates.

#### Call Gates

Call gates are special system descriptors that enable controlled privilege level transitions. They provide the only mechanism for user code to invoke kernel code.

**Call Gate Descriptor Format:**

```
63        48 47    40 39    32 31        16 15         0
+----------+--------+--------+------------+-------------+
| Offset   | Access | Param  |  Selector  | Offset      |
| 16-31    | Byte   | Count  |            | 0-15        |
+----------+--------+--------+------------+-------------+
```

- **Offset**: Entry point offset in target segment
- **Selector**: Target code segment selector
- **Param Count (bits 32-36)**: Number of parameters to copy from caller's stack (0-31)
- **Access Byte**: P=1, DPL=privilege required to call gate, Type=0xC (32-bit call gate)

**Call Gate Access Byte:**

```
db 10001100b        ; P=1, DPL=0, S=0, Type=1100 (32-bit call gate)
db 11101100b        ; P=1, DPL=3, S=0, Type=1100 (call gate callable from ring 3)
```

**Call Gate Example:**

```nasm
; Call gate descriptor in GDT
call_gate:
    dw kernel_function          ; Offset 0-15
    dw 0x08                     ; Code segment selector (ring 0)
    db 0x00                     ; Parameter count (bits 0-4)
    db 11101100b                ; P=1, DPL=3, Type=1100 (callable from ring 3)
    dw kernel_function >> 16    ; Offset 16-31

; User code (ring 3)
call 0x28:0         ; Call through gate selector 0x28
                    ; Offset ignored, gate specifies actual offset
```

**Call Gate Operation:**

1. Processor checks: CPL ≤ call gate DPL (caller has privilege to use gate)
2. Processor checks: Call gate DPL ≥ target segment DPL (gate allows access to target)
3. If target is more privileged (target DPL < CPL):
    - Switch to target segment's stack (from TSS)
    - Push caller's SS:ESP
    - Copy parameters from caller's stack
    - Push caller's CS:EIP
    - Load new CS:EIP from gate
    - CPL becomes target segment's DPL
4. Execute target code
5. Return with RETF, which reverses the process

#### Interrupt/Trap Gates

Similar to call gates but used for interrupt and exception handling. They automatically clear IF (interrupt flag) for interrupt gates but not for trap gates.

**Interrupt/Trap Gate Descriptor:**

```
63        48 47    40 39    32 31        16 15         0
+----------+--------+--------+------------+-------------+
| Offset   | Access |Reserved|  Selector  | Offset      |
| 16-31    | Byte   |  (0)   |            | 0-15        |
+----------+--------+--------+------------+-------------+
```

- **Type**: 0xE = 32-bit interrupt gate, 0xF = 32-bit trap gate
- **DPL**: Minimum privilege required to invoke via INT instruction
- Hardware interrupts ignore DPL

```nasm
; Interrupt gate descriptor in IDT
int_gate:
    dw isr_handler              ; Offset 0-15
    dw 0x08                     ; Code segment selector (ring 0)
    db 0x00                     ; Reserved (always 0)
    db 10001110b                ; P=1, DPL=0, Type=1110 (interrupt gate)
    dw isr_handler >> 16        ; Offset 16-31

; Trap gate descriptor (for system calls)
trap_gate:
    dw syscall_handler          ; Offset 0-15
    dw 0x08                     ; Code segment selector (ring 0)
    db 0x00                     ; Reserved
    db 11101111b                ; P=1, DPL=3, Type=1111 (trap gate, ring 3 callable)
    dw syscall_handler >> 16    ; Offset 16-31
```

#### Task Gates

Task gates trigger a complete task switch through the Task State Segment (TSS) mechanism. They provide the most complete privilege transition, saving and restoring all processor state.

### Stack Switching During Privilege Transitions

When transitioning to a more privileged level (e.g., ring 3 to ring 0), the processor automatically switches stacks using information from the TSS.

**Task State Segment (TSS) Stack Fields:**

```nasm
tss:
    dd 0                ; Previous task link
    dd stack0_top       ; ESP0 (ring 0 stack pointer)
    dd 0x10             ; SS0 (ring 0 stack segment)
    dd stack1_top       ; ESP1 (ring 1 stack pointer)
    dd 0x18             ; SS1 (ring 1 stack segment)
    dd stack2_top       ; ESP2 (ring 2 stack pointer)
    dd 0x20             ; SS2 (ring 2 stack segment)
    ; ... rest of TSS
```

**Stack Switch Sequence:**

1. Save current SS:ESP internally
2. Load new SS:ESP from TSS (based on target CPL)
3. Push old SS:ESP onto new stack
4. Copy parameters (if call gate specifies count)
5. Push old CS:EIP onto new stack
6. Load new CS:EIP from gate

**Stack Layout After Privilege Transition:**

```
Higher addresses
+------------------+
| Old SS           | Pushed by CPU
+------------------+
| Old ESP          | Pushed by CPU
+------------------+
| Parameter N      | Copied by CPU (if param count > 0)
+------------------+
| ...              |
+------------------+
| Parameter 1      |
+------------------+
| Old CS           | Pushed by CPU
+------------------+
| Old EIP          | Pushed by CPU
+------------------+
| (Error code)     | Pushed by CPU (for some exceptions)
+------------------+ <- ESP after transition
Lower addresses
```

### Return from Privilege Transition

**RETF with Stack Adjustment:**

```nasm
retf 8              ; Return and pop 8 bytes of parameters
```

The processor:

1. Pops EIP from stack
2. Pops CS from stack (with CPL check)
3. If returning to less privileged level:
    - Adds stack adjustment to ESP
    - Pops ESP from stack
    - Pops SS from stack
    - Validates new SS and ESP
4. Resumes execution at old privilege level

**IRET (Interrupt Return):**

```nasm
iret                ; Return from interrupt
```

Similar to RETF but also pops EFLAGS from the stack:

1. Pops EIP
2. Pops CS
3. Pops EFLAGS
4. If privilege change, pops ESP and SS
5. Resumes execution

### Privilege Transition Example

**Complete Ring 3 to Ring 0 Transition:**

```nasm
; GDT entries
gdt_start:
    dq 0                        ; Null descriptor
    
    ; Ring 0 code segment (selector 0x08)
    dw 0xFFFF, 0x0000
    db 0x00, 10011010b, 11001111b, 0x00
    
    ; Ring 0 data segment (selector 0x10)
    dw 0xFFFF, 0x0000
    db 0x00, 10010010b, 11001111b, 0x00
    
    ; Ring 3 code segment (selector 0x1B = index 3, RPL 3)
    dw 0xFFFF, 0x0000
    db 0x00, 11111010b, 11001111b, 0x00
    
    ; Ring 3 data segment (selector 0x23 = index 4, RPL 3)
    dw 0xFFFF, 0x0000
    db 0x00, 11110010b, 11001111b, 0x00
    
    ; Call gate (selector 0x28, callable from ring 3)
    dw kernel_syscall           ; Offset 0-15
    dw 0x08                     ; Target: ring 0 code segment
    db 0x01                     ; Copy 1 parameter
    db 11101100b                ; P=1, DPL=3, call gate
    dw kernel_syscall >> 16     ; Offset 16-31
    
    ; TSS descriptor (selector 0x30)
    dw 0x68                     ; Limit (104 bytes)
    dw tss                      ; Base 0-15
    db tss >> 16                ; Base 16-23
    db 10001001b                ; P=1, DPL=0, Type=1001 (available TSS)
    db 00000000b                ; Flags
    db tss >> 24                ; Base 24-31

; TSS structure
align 8
tss:
    dd 0                        ; Previous task link
    dd kernel_stack_top         ; ESP0
    dd 0x10                     ; SS0 (ring 0 data segment)
    times 23 dd 0               ; Other TSS fields
    dw 0, 0                     ; I/O map base

; Kernel syscall handler (ring 0)
kernel_syscall:
    ; EAX contains syscall parameter (copied from user stack)
    push eax
    ; Perform privileged operation
    call do_privileged_work
    pop eax
    retf 4                      ; Return, popping 1 parameter

; User code (ring 3)
user_code:
    push 0x1234                 ; Syscall parameter
    call 0x28:0                 ; Call through gate
    add esp, 4                  ; Clean up (if needed)
```

**Execution Flow:**

1. User code (CPL=3) executes `call 0x28:0`
2. Processor checks: CPL (3) ≤ gate DPL (3) ✓
3. Processor checks: gate DPL (3) ≥ target DPL (0) ✓
4. Privilege transition needed (target DPL=0 < CPL=3):
    - Load SS0:ESP0 from TSS → SS=0x10, ESP=kernel_stack_top
    - Push old SS (0x23) and ESP onto kernel stack
    - Copy 1 parameter (0x1234) from user stack to kernel stack
    - Push old CS (0x1B) and EIP onto kernel stack
    - Load CS:EIP from gate → CS=0x08, EIP=kernel_syscall
    - CPL becomes 0
5. Kernel handler executes at ring 0
6. `retf 4` returns:
    - Pops EIP and CS from kernel stack
    - Adjusts ESP by 4 (parameter cleanup)
    - Pops ESP and SS from kernel stack
    - CPL becomes 3
7. Execution continues in user code

### Security Considerations

**Protection Mechanisms:**

- **Segment-level protection**: DPL in descriptors restricts access
- **Page-level protection**: U/S bit in page tables (in paging mode)
- **Gate-controlled transfers**: Only gates allow privilege elevation
- **Stack switching**: Prevents stack corruption during transitions
- **IOPL (I/O Privilege Level)**: Restricts I/O instructions

**Common Protection Violations:**

- **General Protection Fault (#GP)**:
    - Invalid privilege level access
    - Loading null selector into CS
    - Exceeding segment limit
- **Stack Fault (#SS)**:
    - Stack segment limit exceeded
    - Loading invalid SS selector
- **Segment Not Present (#NP)**:
    - Accessing segment with P=0

**Key Points:**

- Protected mode replaces direct segment addressing with descriptor tables and privilege levels
- The GDT is mandatory and system-wide; LDTs are optional and task-specific
- Segment descriptors are 8-byte structures defining segment base, limit, type, and privilege level
- Selectors are 16-bit values indexing descriptor tables with TI and RPL fields
- Four privilege levels (0-3) enforce protection, with Ring 0 (kernel) and Ring 3 (user) most commonly used
- Privilege transitions require call gates, interrupt/trap gates, or task gates—direct far jumps to different privilege levels are prohibited
- Stack switching occurs automatically during privilege elevation using TSS-defined stacks
- Access control follows strict rules: for data segments, MAX(CPL, RPL) ≤ DPL; for non-conforming code, CPL = DPL
- The processor enforces protection through privilege checks, generating exceptions for violations

---

