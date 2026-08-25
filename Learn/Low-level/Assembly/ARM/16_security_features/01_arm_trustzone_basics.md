## ARM TrustZone Basics


ARM TrustZone is a hardware-based security technology that creates an isolated secure execution environment within a processor. It divides the system into two parallel worlds: the Secure world and the Normal (Non-secure) world, enabling the processor to handle sensitive operations separately from general-purpose computing tasks.

TrustZone operates at the hardware level, implemented across the processor, memory, and peripherals. The architecture uses a single physical processor core that can switch between security states, rather than requiring separate processors. This approach provides strong isolation while maintaining efficiency.

The security model relies on the NS (Non-secure) bit, which propagates through the entire system including bus transactions, memory accesses, and peripheral communications. Hardware enforcement ensures that Non-secure software cannot access Secure resources, while Secure software can access both worlds.

**Key Points:**

- TrustZone provides hardware-enforced isolation without requiring a separate security processor
- The architecture supports both AArch32 (32-bit) and AArch64 (64-bit) execution states
- Security state transitions occur through controlled entry points called Secure Monitor Calls (SMC)
- The technology is designed to protect sensitive assets like cryptographic keys, biometric data, and payment credentials
- TrustZone can coexist with virtualization extensions, creating multiple security domains

