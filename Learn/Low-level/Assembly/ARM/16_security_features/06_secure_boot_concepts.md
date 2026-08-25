## Secure Boot Concepts


Secure boot establishes a chain of trust from initial power-on through operating system loading, ensuring only authenticated code executes.

### Root of Trust

The secure boot process begins with immutable code in ROM (Boot ROM) that cannot be modified after chip manufacturing. This code contains cryptographic public keys or key hashes used to verify the next stage.

**Boot Sequence**:

1. **Boot ROM (BL1)**: Executes immediately after reset from internal ROM. Verifies digital signature of next bootloader stage using embedded public key. Only proceeds if signature verification succeeds.
    
2. **Trusted Boot Firmware (BL2)**: Second stage bootloader verified by BL1. Initializes additional hardware, verifies and loads subsequent stages, and establishes secure execution environment.
    
3. **Secure Monitor (BL31)**: Establishes EL3 secure world environment. Provides runtime services for secure and non-secure worlds.
    
4. **Bootloader (BL33)**: OS bootloader (U-Boot, UEFI) verified by previous stage. Loads and verifies OS kernel before execution.
    

### Digital Signature Verification

Each boot stage verifies the next using cryptographic signatures:

```assembly
// Simplified signature verification flow (conceptual)
secure_boot_verify:
    // Load next stage image header
    ldr x0, =next_stage_addr
    ldr x1, [x0, #IMAGE_SIGNATURE_OFFSET]
    ldr x2, [x0, #IMAGE_HASH_OFFSET]
    
    // Calculate hash of image
    ldr x3, [x0, #IMAGE_SIZE]
    bl  sha256_hash              // Calculate SHA-256 of image
    
    // Verify signature using public key in ROM
    ldr x4, =public_key_rom
    mov x5, x1                   // Signature
    mov x6, x2                   // Hash
    bl  rsa_verify               // RSA signature verification
    
    cbz x0, boot_failure         // If verification fails, halt
    
    // Verification succeeded, jump to next stage
    ldr x0, =next_stage_addr
    br  x0

boot_failure:
    // Secure failure - cannot proceed
    wfi                          // Wait for interrupt (halt)
    b   boot_failure             // Infinite loop
```

### TrustZone Integration

Secure boot leverages ARM TrustZone to partition system into Normal World and Secure World:

```assembly
// Transitioning to Secure World via SMC (Secure Monitor Call)
// From EL1 (Normal World)
mov x0, #SECURE_BOOT_VERIFY_FID    // Function ID
ldr x1, =image_address             // Image to verify
ldr x2, =image_size
smc #0                             // Triggers exception to EL3

// In EL3 Secure Monitor
secure_monitor_handler:
    // Check FID in x0
    cmp x0, #SECURE_BOOT_VERIFY_FID
    b.ne unknown_smc
    
    // Execute secure verification
    mov x0, x1                     // Image address
    mov x1, x2                     // Image size
    bl  secure_verify_image
    
    // Return to Normal World with result in x0
    eret
```

### Anti-Rollback Protection

Secure boot systems include version tracking to prevent downgrade attacks:

```assembly
// Check image version against secure storage
check_version:
    // Read current minimum version from secure OTP/eFuses
    ldr x0, =OTP_VERSION_ADDR
    ldr w1, [x0]                   // Minimum allowed version
    
    // Read image version from header
    ldr x2, =image_header
    ldr w3, [x2, #VERSION_OFFSET]
    
    // Compare versions
    cmp w3, w1
    b.lt version_too_old           // Reject if image version < minimum
    
    // Update secure counter if newer version
    cmp w3, w1
    b.le version_ok
    str w3, [x0]                   // Write new minimum version
    
version_ok:
    ret

version_too_old:
    mov x0, #-1                    // Return error
    ret
```

