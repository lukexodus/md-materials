## Secure and Non-secure States


The processor operates in one of two security states at any time: Secure state or Non-secure state. Each state has its own set of resources, exception levels, and memory regions.

### Security State Architecture

In AArch64, the security states interact with Exception Levels (EL0-EL3):

- **EL3**: Secure Monitor - Always executes in Secure state, handles transitions between security states
- **EL2**: Hypervisor - Can exist in both Secure and Non-secure states (implementation dependent)
- **EL1**: Operating System kernel level
- **EL0**: Application level

Non-secure state typically runs the Rich OS (like Linux or Android) and applications, while Secure state runs a Trusted OS and trusted applications. EL3 serves as the gatekeeper between these worlds.

### State Transition Mechanisms

Transitions from Non-secure to Secure state occur through:

- **SMC (Secure Monitor Call)**: Explicit instruction to request Secure services
- **Hardware exceptions**: Certain interrupts configured as Secure can trigger transitions
- **Reset**: System reset always enters Secure state

Transitions from Secure to Non-secure state occur through:

- **ERET (Exception Return)**: Returns from EL3 to lower exception level in Non-secure state
- **Secure interrupts completing**: After handling Secure interrupt, control returns to Non-secure world

### Resource Partitioning

**Secure State Resources:**

- Dedicated register banks (some registers are banked by security state)
- Secure memory regions (marked in translation tables)
- Secure peripherals (configured via hardware signals)
- Secure interrupts (FIQ typically configured as Secure)
- Private cache ways (optional, implementation dependent)

**Non-secure State Resources:**

- Normal world register banks
- Non-secure memory regions
- Non-secure peripherals
- Non-secure interrupts (IRQ typically configured as Non-secure)

### Memory Access Rules

The fundamental security rule: Non-secure accesses cannot read or write Secure memory, but Secure accesses can access Non-secure memory. This is enforced by the memory system using the NS bit on all transactions.

Memory controllers and peripherals check the NS bit to determine whether to permit or deny access. Attempting to access Secure memory from Non-secure state results in an abort or returns dummy data, depending on configuration.

**Example:**

```assembly
// Non-secure world calling Secure service
// Running at EL0 or EL1 in Non-secure state

        MOV     X0, #0x1000         // Function ID for Secure service
        MOV     X1, #0x42           // Parameter 1
        MOV     X2, buffer_addr     // Parameter 2 (Non-secure buffer)
        SMC     #0                  // Trigger Secure Monitor Call

        // Execution switches to EL3 Secure Monitor
        // Monitor validates request and dispatches to Secure OS
        // After service completion, ERET returns here
        
        CMP     X0, #0              // Check return status
        B.NE    error_handler
```

**Example:**

```assembly
// Secure Monitor at EL3 handling SMC
// This code runs in Secure state

secure_monitor_handler:
        // Save Non-secure context
        STP     X0, X1, [SP, #-16]!
        STP     X2, X3, [SP, #-16]!
        
        // Read exception syndrome to identify SMC
        MRS     X0, ESR_EL3
        
        // Check if call is from Non-secure state
        MRS     X1, SCR_EL3         // Secure Configuration Register
        TBNZ    X1, #0, handle_ns_call  // NS bit = 1 means Non-secure
        
        // Handle Secure world SMC differently
        B       handle_secure_call

handle_ns_call:
        // Switch to Secure EL1 to service the request
        // Set up return to Non-secure state
        MOV     X0, secure_service_addr
        MSR     ELR_EL3, X0         // Set return address
        
        // Configure return to Non-secure EL1
        MOV     X0, #0b01001        // EL1h, Secure state
        MSR     SPSR_EL3, X0
        
        ERET                        // Enter Secure EL1
```

### System Control Registers

**SCR_EL3 (Secure Configuration Register)**: Controls security state behavior

- NS bit (bit 0): Current security state (0=Secure, 1=Non-secure)
- IRQ, FIQ bits: Route interrupts to EL3
- EA bit: Route external aborts to EL3
- SMD bit: Disable SMC instruction in Non-secure state

**Key Points:**

- Security state is orthogonal to Exception Level - you can be at EL1 in either Secure or Non-secure state
- The processor always boots into Secure state at EL3
- SMC instruction is undefined in Secure EL0 and Non-secure EL0 (generates exception)
- Context switching between states must save/restore all necessary architectural state
- FIQ is typically dedicated to Secure world, IRQ to Non-secure world

