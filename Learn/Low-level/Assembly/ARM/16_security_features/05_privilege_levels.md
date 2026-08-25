## Privilege Levels


ARM processors implement hierarchical execution levels that control access to system resources and instructions.

### Exception Levels (ARMv8/AArch64)

ARM defines four Exception Levels (EL0-EL3) with increasing privilege:

**EL0 (User Mode)**: Unprivileged execution level where application code runs. Applications at EL0 cannot directly access system registers, perform privileged operations, or access memory outside their permitted regions. Any attempt to execute privileged instructions triggers an exception to a higher level.

**EL1 (Operating System Kernel)**: Privileged level where OS kernel code executes. The kernel manages virtual memory through page tables, handles system calls from EL0, configures interrupt controllers, and manages device access. Most operating systems run at this level with full control over application execution.

**EL2 (Hypervisor)**: Provides virtualization support allowing multiple operating systems to run on the same hardware. The hypervisor at EL2 manages virtual machines, traps and emulates privileged operations from guest OSes at EL1, controls stage-2 address translation for VM memory isolation, and manages virtual CPU scheduling.

**EL3 (Secure Monitor)**: Highest privilege level managing transitions between Normal World and Secure World in TrustZone implementations. The Secure Monitor handles secure boot verification, manages cryptographic keys in secure storage, mediates communication between secure and non-secure states, and controls access to secure peripherals.

### ARM Cortex-A Exception Level Transitions

Exception level changes occur through specific mechanisms:

```assembly
// Taking an exception from EL0 to EL1
// Hardware automatically:
// 1. Saves processor state to ELR_EL1 (Exception Link Register)
// 2. Saves PSTATE to SPSR_EL1 (Saved Program Status Register)
// 3. Updates current EL to EL1
// 4. Branches to exception vector

exception_entry:
    stp x29, x30, [sp, #-16]!    // Save frame pointer and link register
    stp x27, x28, [sp, #-16]!
    // ... save other registers
    
    // Handle exception at EL1
    bl  handle_syscall
    
    // Return to EL0
    ldp x27, x28, [sp], #16
    ldp x29, x30, [sp], #16
    eret                          // Exception Return - restores EL0
```

### Privilege Level Registers

Each exception level has dedicated system registers:

```assembly
// Reading current exception level
mrs x0, CurrentEL          // Read current EL into x0
lsr x0, x0, #2             // EL is in bits [3:2]
// x0 now contains 0, 1, 2, or 3

// Accessing EL-specific registers
mrs x1, SCTLR_EL1          // System Control Register for EL1
mrs x2, VBAR_EL1           // Vector Base Address Register for EL1
mrs x3, TCR_EL1            // Translation Control Register for EL1

// Attempting to access higher-EL register from lower EL causes exception
// This instruction at EL0 would trap to EL1:
mrs x4, SCTLR_EL1          // UNDEFINED at EL0
```

### ARMv7 Privilege Modes

Legacy 32-bit ARM uses processor modes instead of exception levels:

- **User mode**: Unprivileged application execution
- **FIQ mode**: Fast Interrupt Request handling
- **IRQ mode**: Standard Interrupt Request handling
- **Supervisor mode**: OS kernel execution after reset or SVC instruction
- **Abort mode**: Memory access violation handling
- **Undefined mode**: Undefined instruction handling
- **System mode**: Privileged mode with user-mode register bank

```assembly
// ARMv7 mode switching via CPSR manipulation
mrs r0, CPSR               // Read Current Program Status Register
bic r0, r0, #0x1F          // Clear mode bits
orr r0, r0, #0x13          // Set Supervisor mode (10011)
msr CPSR_c, r0             // Write back to CPSR
```

