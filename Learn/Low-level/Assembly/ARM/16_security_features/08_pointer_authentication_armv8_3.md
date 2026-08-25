## Pointer Authentication (ARMv8.3+)


Pointer Authentication Codes (PAC) protect against return-oriented programming (ROP) and jump-oriented programming (JOP) attacks by cryptographically signing pointers before use.

### PAC Mechanism

PAC uses cryptographic algorithms to generate authentication codes embedded in unused upper bits of 64-bit pointers. ARMv8.3-A introduces five 128-bit keys:

- **APIAKey/APIBKey**: Instruction address keys (A and B variants)
- **APDAKey/APDBKey**: Data address keys (A and B variants)
- **APGAKey**: Generic authentication key

```assembly
// Sign return address before storing
function_with_pac:
    paciasp                        // Sign LR with SP and APIAKey
    stp x29, x30, [sp, #-16]!      // Store frame pointer and signed LR
    mov x29, sp
    
    // Function body
    bl  some_other_function
    
    // Restore and authenticate return address
    ldp x29, x30, [sp], #16
    autiasp                        // Authenticate LR with SP and APIAKey
    ret                            // Return using authenticated address

// If authentication fails, top bits are corrupted
// causing a fault when used as address
```

### PAC Instructions

**Signing Instructions**:

```assembly
// Sign instruction pointer with context and key A
pacia x0, x1                   // Sign x0 using x1 as context, APIAKey

// Sign instruction pointer with SP as context
paciasp                        // Sign LR using SP as context

// Sign instruction pointer with zero context
paciaz                         // Sign LR using zero as context

// Sign data pointer
pacda x0, x1                   // Sign x0 using x1 as context, APDAKey

// Generic authentication
pacga x0, x1, x2               // Sign x1 with x2 context using APGAKey
```

**Authentication Instructions**:

```assembly
// Authenticate instruction pointer
autia x0, x1                   // Authenticate x0 using x1 as context

// Authenticate with SP
autiasp                        // Authenticate LR using SP

// Authenticate with zero
autiaz                         // Authenticate LR using zero

// Authenticate data pointer
autda x0, x1                   // Authenticate x0 using x1 as context
```

**Strip Instructions**:

```assembly
// Remove PAC without authentication (for debugging/logging)
xpaci x0                       // Strip PAC from instruction pointer in x0
xpacd x0                       // Strip PAC from data pointer in x0
```

### PAC in Practice

**Function Call Protection**:

```assembly
// Caller
call_protected_function:
    // Return address automatically protected if PAC enabled
    bl  protected_function        // LR contains signed return address
    // Execution continues here after return

// Callee
protected_function:
    paciasp                       // Sign LR with SP
    stp x29, x30, [sp, #-32]!
    stp x19, x20, [sp, #16]
    mov x29, sp
    
    // If attacker overwrites LR on stack, authentication will fail
    // Function body...
    
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    autiasp                       // Authenticate before using
    ret                           // Fault if authentication failed
```

**Data Pointer Protection**:

```assembly
// Protect function pointers in structures
struct_with_callback:
    .quad data_field1
    .quad data_field2
    .quad callback_ptr            // Function pointer to protect

protect_callback:
    ldr x0, =struct_with_callback
    ldr x1, [x0, #16]             // Load callback pointer
    mov x2, x0                    // Use struct address as context
    pacia x1, x2                  // Sign callback with struct address
    str x1, [x0, #16]             // Store signed pointer
    ret

call_callback:
    ldr x0, =struct_with_callback
    ldr x1, [x0, #16]             // Load signed callback
    mov x2, x0                    // Context
    autia x1, x2                  // Authenticate
    blr x1                        // Call authenticated pointer
    ret
```

**Virtual Function Tables**:

```assembly
// C++ vtable with PAC protection
// vtable layout: [method1_ptr, method2_ptr, method3_ptr]

// Signing vtable entries at initialization
sign_vtable:
    ldr x0, =object_vtable
    mov x1, x0                    // Use vtable address as context
    
    ldr x2, [x0, #0]              // Load method1 pointer
    pacia x2, x1                  // Sign with vtable address
    str x2, [x0, #0]
    
    ldr x2, [x0, #8]              // Load method2 pointer
    pacia x2, x1
    str x2, [x0, #8]
    
    ldr x2, [x0, #16]             // Load method3 pointer
    pacia x2, x1
    str x2, [x0, #16]
    ret

// Calling virtual method
call_virtual_method:
    ldr x0, [x8, #0]              // Load object pointer (x8 = this)
    ldr x1, [x0, #0]              // Load vtable pointer
    ldr x2, [x1, #8]              // Load signed method pointer
    autia x2, x1                  // Authenticate with vtable address
    blr x2                        // Call method
    ret
```

### PAC Configuration

System registers control PAC behavior:

```assembly
// Enable PAC in SCTLR_EL1
enable_pac:
    mrs x0, SCTLR_EL1
    orr x0, x0, #(1 << 30)        // EnIA - Enable PAC for instruction addresses
    orr x0, x0, #(1 << 27)        // EnDA - Enable PAC for data addresses
    msr SCTLR_EL1, x0
    isb
    ret

// Configure PAC keys (EL1 or higher)
set_pac_keys:
    // Load keys from secure storage
    ldr x0, =apiakeylo
    ldr x1, =apiakeyhi
    msr APIAKeyLo_EL1, x0
    msr APIAKeyHi_EL1, x1
    
    // Set other keys similarly
    ldr x0, =apibkeylo
    ldr x1, =apibkeyhi
    msr APIBKeyLo_EL1, x0
    msr APIBKeyHi_EL1, x1
    isb
    ret
```

### PAC Security Properties

**[Inference]** PAC provides probabilistic protection against pointer corruption. The authentication code uses unused upper bits (typically bits 55-63 on current implementations), providing roughly 2^8 = 256 possible values per context. An attacker attempting to forge a valid PAC has approximately 1/256 chance of success per attempt, though triggering a fault on failure limits practical exploitation.

**Limitations**:

- **[Unverified]** PAC does not protect against all control-flow attacks; attackers may use valid signed pointers from elsewhere in memory
- Context selection is critical: weak or predictable contexts reduce security
- **[Inference]** PAC effectiveness depends on key management; compromised keys eliminate protection
- Performance overhead exists from additional sign/authenticate instructions
- Limited to 64-bit architectures with available upper address bits

**Key Points:**

- ARM privilege levels (EL0-EL3) create hierarchical isolation between applications, OS, hypervisor, and secure monitor with hardware-enforced access controls
- Secure boot establishes cryptographic chain of trust from immutable ROM through each boot stage using digital signatures and anti-rollback counters
- Side-channel attacks exploit timing, cache state, power consumption, and speculative execution requiring constant-time algorithms and hardware barriers
- Pointer Authentication (ARMv8.3+) cryptographically signs pointers using dedicated keys to detect and prevent ROP/JOP attacks with probabilistic protection

**Important related topics:** TrustZone architecture and secure world isolation, Memory Tagging Extension (MTE) for spatial and temporal memory safety, Branch Target Identification (BTI) for forward-edge control flow integrity, Secure EL2 virtualization features in ARMv8.4+

---

