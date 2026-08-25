## System Calls (INT 80h, SYSCALL, SYSENTER)


System calls provide the controlled interface through which user-mode applications request kernel services. Different mechanisms have evolved across x86 architecture generations, each with varying performance characteristics.

### INT 80h (Legacy System Call Mechanism)

The INT 80h instruction was the traditional Linux system call mechanism on 32-bit x86. INT is a software interrupt instruction that triggers a privilege level transition through the Interrupt Descriptor Table (IDT).

#### INT Instruction Operation

```nasm
; System call using INT 80h (32-bit Linux)
mov eax, 4          ; syscall number (sys_write)
mov ebx, 1          ; file descriptor (stdout)
mov ecx, msg        ; buffer pointer
mov edx, msg_len    ; buffer length
int 0x80            ; Trigger system call
; Return value in EAX
```

**INT instruction execution sequence**:

1. Processor reads IDT entry for vector 80h
2. Validates privilege transition (DPL check)
3. Switches to kernel stack (from TSS)
4. Pushes EFLAGS, CS, EIP onto kernel stack
5. Clears interrupt flag (IF) if interrupt gate
6. Loads CS:EIP from IDT gate descriptor
7. Execution continues in kernel interrupt handler

**Interrupt gate descriptor format**:

```
Bits 0-15:   Offset low 16 bits
Bits 16-31:  Segment selector (kernel code segment)
Bits 32-39:  Reserved (0)
Bits 40-43:  Gate type (0xE = interrupt gate, 0xF = trap gate)
Bit  44:     Storage segment (0 for gates)
Bits 45-46:  DPL (Descriptor Privilege Level, 3 for user-accessible)
Bit  47:     Present bit (1 = valid)
Bits 48-63:  Offset high 16 bits (32-bit mode)
```

[Inference] The INT instruction provides reliable privilege transition with complete state preservation, but the extensive steps (multiple memory accesses, privilege checks, stack switching) result in relatively high overhead compared to newer mechanisms.

#### Return from System Call (IRET)

The kernel returns to user mode using IRET (Interrupt Return):

```nasm
; Kernel system call handler epilogue
; ... system call implementation ...
iret            ; Return to user mode (32-bit)
iretq           ; Return to user mode (64-bit)
```

**IRET operation**:

1. Pops EIP, CS, EFLAGS from kernel stack
2. If privilege change (Ring 0 → Ring 3):
    - Pops user ESP, SS from kernel stack
    - Switches to user stack
3. Resumes execution at user-mode address

[Unverified] The INT/IRET mechanism typically requires 100-300 cycles depending on processor generation and cache state, making it the slowest system call method but providing maximum compatibility and state preservation.

### SYSENTER/SYSEXIT (Fast System Call - Intel)

Intel introduced SYSENTER and SYSEXIT instructions with Pentium II to provide faster system call mechanisms by eliminating IDT lookups and reducing state preservation overhead.

#### SYSENTER Instruction

SYSENTER performs a fast, low-overhead transition to ring 0:

```nasm
; Preparing SYSENTER (user mode)
mov eax, syscall_number     ; System call number
; Arguments in other registers (ABI-specific)
sysenter                    ; Fast transition to kernel
; Return via SYSEXIT, execution continues here
```

**SYSENTER operation**:

1. Loads CS from IA32_SYSENTER_CS MSR
2. Loads EIP from IA32_SYSENTER_EIP MSR
3. Loads SS from IA32_SYSENTER_CS + 8
4. Loads ESP from IA32_SYSENTER_ESP MSR
5. Sets CPL to 0
6. Clears EFLAGS.VM and EFLAGS.IF
7. Begins execution at kernel entry point

[Inference] SYSENTER avoids IDT access and minimizes memory operations by loading control values from Model-Specific Registers (MSRs), significantly reducing system call entry overhead compared to INT.

#### SYSENTER MSR Configuration

The kernel must initialize SYSENTER MSRs during boot:

```nasm
; Kernel initialization of SYSENTER (32-bit example)
mov ecx, 0x174          ; IA32_SYSENTER_CS
mov eax, KERNEL_CS      ; Kernel code segment selector
mov edx, 0
wrmsr                   ; Write MSR

mov ecx, 0x175          ; IA32_SYSENTER_ESP
mov eax, kernel_stack   ; Kernel stack pointer
mov edx, 0
wrmsr

mov ecx, 0x176          ; IA32_SYSENTER_EIP
mov eax, sysenter_handler  ; Kernel entry point
mov edx, 0
wrmsr
```

**SYSENTER MSRs**:

```
IA32_SYSENTER_CS  (0x174): Kernel CS selector
IA32_SYSENTER_ESP (0x175): Kernel stack pointer
IA32_SYSENTER_EIP (0x176): Kernel entry point address
```

#### SYSEXIT Instruction

SYSEXIT returns from kernel to user mode:

```nasm
; Kernel handler epilogue
; ECX contains user return EIP
; EDX contains user return ESP
sysexit         ; Fast return to user mode (32-bit)
```

**SYSEXIT operation**:

1. Loads CS from IA32_SYSENTER_CS + 16
2. Loads EIP from ECX
3. Loads SS from IA32_SYSENTER_CS + 24
4. Loads ESP from EDX
5. Sets CPL to 3
6. Resumes execution at user address

[Inference] SYSENTER/SYSEXIT significantly reduces system call overhead but requires careful state management since minimal automatic state preservation occurs. The kernel must explicitly save and restore user context.

**Limitations**:

- SYSENTER does not save user ESP, EIP, EFLAGS automatically
- Kernel must manually preserve and restore user state
- No direct support for returning error conditions via EFLAGS
- Not suitable for nested interrupts without additional mechanism

[Unverified] SYSENTER/SYSEXIT typically requires 30-70 cycles, approximately 2-3× faster than INT/IRET mechanism.

### SYSCALL/SYSRET (Fast System Call - AMD/x86-64)

AMD designed SYSCALL and SYSRET for the x86-64 architecture, providing optimized system call mechanisms for 64-bit mode. Intel adopted these instructions in their 64-bit implementations.

#### SYSCALL Instruction

SYSCALL provides fast kernel entry in 64-bit mode:

```nasm
; User mode system call (64-bit Linux)
mov rax, 1          ; syscall number (sys_write)
mov rdi, 1          ; file descriptor (stdout)
mov rsi, msg        ; buffer pointer
mov rdx, msg_len    ; buffer length
syscall             ; Fast transition to kernel
; Return value in RAX
```

**SYSCALL operation**:

1. Saves RFLAGS to R11
2. Saves RIP to RCX
3. Loads RIP from IA32_LSTAR MSR (64-bit) or IA32_CSTAR (compatibility mode)
4. Loads CS from IA32_STAR MSR [47:32] + 0
5. Loads SS from IA32_STAR MSR [47:32] + 8
6. Masks RFLAGS using IA32_FMASK MSR
7. Sets CPL to 0
8. Begins execution at kernel entry point

[Inference] SYSCALL preserves minimal state (RIP in RCX, RFLAGS in R11) and relies on the kernel to save additional context, optimizing the common case where most registers are used for parameter passing and don't require preservation.

#### SYSCALL MSR Configuration

The kernel initializes SYSCALL MSRs during boot:

```nasm
; Kernel initialization of SYSCALL (64-bit)
mov ecx, 0xC0000081         ; IA32_STAR
mov eax, USER_CS32_SEL << 16 | KERNEL_CS_SEL
mov edx, USER_CS64_SEL << 16
wrmsr

mov ecx, 0xC0000082         ; IA32_LSTAR (64-bit entry point)
mov rax, syscall_entry_64
mov rdx, rax
shr rdx, 32
wrmsr

mov ecx, 0xC0000084         ; IA32_FMASK
mov eax, RFLAGS_IF | RFLAGS_DF | ...  ; Flags to mask
xor edx, edx
wrmsr
```

**SYSCALL MSRs**:

```
IA32_STAR   (0xC0000081): Segment selectors for CS/SS
  Bits 31-0:  Reserved
  Bits 47-32: Kernel CS/SS base selector
  Bits 63-48: User CS/SS base selector (compatibility mode)

IA32_LSTAR  (0xC0000082): 64-bit mode kernel entry point (RIP)

IA32_CSTAR  (0xC0000083): Compatibility mode kernel entry point

IA32_FMASK  (0xC0000084): RFLAGS mask (bits to clear on entry)
```

#### Kernel Entry Handler

The kernel entry point receives control with minimal state change:

```nasm
; Kernel SYSCALL entry point
syscall_entry_64:
    swapgs              ; Switch GS base to kernel data
    mov [gs:user_rsp], rsp  ; Save user stack pointer
    mov rsp, [gs:kernel_rsp] ; Load kernel stack pointer
    
    ; RCX contains user RIP, R11 contains user RFLAGS
    push rcx            ; Save user RIP
    push r11            ; Save user RFLAGS
    
    ; Save registers that need preservation
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    
    ; System call dispatch based on RAX
    cmp rax, NR_syscalls
    jae invalid_syscall
    
    call [syscall_table + rax*8]
    
    ; Restore registers
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx
    
    pop r11             ; Restore user RFLAGS
    pop rcx             ; Restore user RIP
    
    mov rsp, [gs:user_rsp]  ; Restore user stack
    swapgs              ; Restore user GS base
    sysretq             ; Return to user mode
```

#### SYSRET Instruction

SYSRET returns from kernel to user mode:

```nasm
; Kernel return (RCX contains user RIP, R11 contains user RFLAGS)
sysretq         ; 64-bit return
```

**SYSRET operation** (64-bit mode):

1. Loads RIP from RCX
2. Loads RFLAGS from R11 (with restrictions)
3. Loads CS from IA32_STAR [63:48] + 16
4. Loads SS from IA32_STAR [63:48] + 8
5. Sets CPL to 3
6. Resumes execution at user address

[Inference] The SYSCALL/SYSRET pair optimizes for the 64-bit calling convention where parameters are passed in registers, eliminating the need to preserve registers not used for parameters. The automatic save of RIP to RCX and RFLAGS to R11 provides minimal necessary state preservation.

**Security Considerations**:

- SYSRET sets RIP from RCX without validation
- Non-canonical addresses in RCX cause #GP in user mode after return
- Kernel must validate return addresses carefully
- Intel processors before Ivy Bridge had SYSRET security vulnerabilities requiring workarounds

[Unverified] SYSCALL/SYSRET typically requires 30-50 cycles in 64-bit mode, providing the fastest system call mechanism for x86-64 architecture.

### System Call Comparison

|**Mechanism**|**Architecture**|**Overhead**|**State Preservation**|**Usage**|
|---|---|---|---|---|
|**INT 80h**|32-bit|High (~100-300 cycles)|Automatic (EFLAGS, CS, EIP, SS, ESP)|Legacy Linux 32-bit|
|**SYSENTER/SYSEXIT**|32-bit|Medium (~30-70 cycles)|Minimal (kernel manages)|Windows, some 32-bit systems|
|**SYSCALL/SYSRET**|64-bit|Low (~30-50 cycles)|Minimal (RIP→RCX, RFLAGS→R11)|Modern Linux/BSD 64-bit|

[Inference] The evolution from INT to SYSCALL reflects the trade-off between automatic state management and performance. Modern fast system calls place more responsibility on the kernel for state management but achieve significantly lower overhead.

### Virtual Dynamic Shared Object (vDSO)

Modern Linux systems employ vDSO (Virtual Dynamic Shared Object) to further optimize system calls. The kernel maps a memory page containing frequently-used system call implementations directly into user process address space.

**vDSO benefits**:

- Certain system calls (gettimeofday, clock_gettime, getcpu) execute entirely in user space
- No privilege transition overhead
- Kernel updates vDSO page when necessary (time updates, CPU frequency changes)

```nasm
; vDSO system call (no kernel transition)
; The vDSO provides __vdso_gettimeofday function
call __vdso_gettimeofday
; Executes in user mode, reads kernel-maintained time data
```

[Inference] The vDSO mechanism eliminates system call overhead entirely for frequently-used, read-only kernel data access, providing microsecond-level performance for time queries compared to millisecond-level overhead for traditional system calls.

