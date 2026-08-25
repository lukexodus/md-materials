## Cryptography Instructions


ARM processors include optional cryptographic extensions that provide hardware-accelerated instructions for common cryptographic algorithms. These instructions significantly improve performance and can provide protection against timing attacks when properly implemented.

### AES (Advanced Encryption Standard) Instructions

The AES instructions operate on 128-bit values in SIMD registers and support encryption, decryption, and key expansion operations.

**AES Encryption/Decryption Instructions:**

- **AESE**: AES single round encryption
- **AESD**: AES single round decryption
- **AESMC**: AES mix columns (encryption)
- **AESIMC**: AES inverse mix columns (decryption)

These instructions work on SIMD&FP registers (V registers) in 128-bit mode.

**Example:**

```assembly
// AES-128 encryption of a single block
// V0 = plaintext block (128 bits)
// V1-V11 = round keys (11 keys for AES-128)

aes_encrypt:
        // Initial round
        EOR     V0.16B, V0.16B, V1.16B      // Add round key 0
        
        // Rounds 1-9
        AESE    V0.16B, V2.16B              // SubBytes + ShiftRows + AddRoundKey
        AESMC   V0.16B, V0.16B              // MixColumns
        
        AESE    V0.16B, V3.16B
        AESMC   V0.16B, V0.16B
        
        AESE    V0.16B, V4.16B
        AESMC   V0.16B, V0.16B
        
        AESE    V0.16B, V5.16B
        AESMC   V0.16B, V0.16B
        
        AESE    V0.16B, V6.16B
        AESMC   V0.16B, V0.16B
        
        AESE    V0.16B, V7.16B
        AESMC   V0.16B, V0.16B
        
        AESE    V0.16B, V8.16B
        AESMC   V0.16B, V0.16B
        
        AESE    V0.16B, V9.16B
        AESMC   V0.16B, V0.16B
        
        AESE    V0.16B, V10.16B
        AESMC   V0.16B, V0.16B
        
        // Final round (no MixColumns)
        AESE    V0.16B, V11.16B
        
        // V0 now contains ciphertext
        RET
```

**Example:**

```assembly
// AES-128 decryption of a single block
// V0 = ciphertext block (128 bits)
// V1-V11 = round keys (applied in reverse order)

aes_decrypt:
        // Initial round (with inverse round key)
        EOR     V0.16B, V0.16B, V11.16B
        
        // Rounds 9-1
        AESD    V0.16B, V10.16B             // InvShiftRows + InvSubBytes + AddRoundKey
        AESIMC  V0.16B, V0.16B              // InvMixColumns
        
        AESD    V0.16B, V9.16B
        AESIMC  V0.16B, V0.16B
        
        AESD    V0.16B, V8.16B
        AESIMC  V0.16B, V0.16B
        
        AESD    V0.16B, V7.16B
        AESIMC  V0.16B, V0.16B
        
        AESD    V0.16B, V6.16B
        AESIMC  V0.16B, V0.16B
        
        AESD    V0.16B, V5.16B
        AESIMC  V0.16B, V0.16B
        
        AESD    V0.16B, V4.16B
        AESIMC  V0.16B, V0.16B
        
        AESD    V0.16B, V3.16B
        AESIMC  V0.16B, V0.16B
        
        AESD    V0.16B, V2.16B
        AESIMC  V0.16B, V0.16B
        
        // Final round (no InvMixColumns)
        AESD    V0.16B, V1.16B
        
        // V0 now contains plaintext
        RET
```

### SHA (Secure Hash Algorithm) Instructions

ARM provides instructions for SHA-1, SHA-256, and SHA-512 (in ARMv8.2 and later) hash computations.

**SHA-1 Instructions:**

- **SHA1C**: SHA-1 hash update (choose function)
- **SHA1P**: SHA-1 hash update (parity function)
- **SHA1M**: SHA-1 hash update (majority function)
- **SHA1H**: SHA-1 fixed rotate
- **SHA1SU0**, **SHA1SU1**: SHA-1 schedule update

**SHA-256 Instructions:**

- **SHA256H**: SHA-256 hash update part 1
- **SHA256H2**: SHA-256 hash update part 2
- **SHA256SU0**, **SHA256SU1**: SHA-256 schedule update

**Example:**

```assembly
// SHA-256 compression function (partial)
// V0 = state words A, B (64 bits each)
// V1 = state words C, D
// V2 = state words E, F
// V3 = state words G, H
// V4-V7 = message schedule

sha256_round:
        // Process 4 rounds
        LD1     {V16.4S}, [X0], #16         // Load 4 round constants
        
        ADD     V4.4S, V4.4S, V16.4S        // Add constants to schedule
        MOV     V17.16B, V2.16B             // Copy E,F,G,H
        
        SHA256H Q2, Q3, V4.4S               // Hash update part 1
        SHA256H2 Q3, Q17, V4.4S             // Hash update part 2
        
        // Update schedule for future rounds
        SHA256SU0 V4.4S, V5.4S
        SHA256SU1 V4.4S, V6.4S, V7.4S
        
        RET
```

### SHA-3/SHA-512 Instructions (ARMv8.2+)

**SHA-512 Instructions:**

- **SHA512H**: SHA-512 hash update part 1
- **SHA512H2**: SHA-512 hash update part 2
- **SHA512SU0**, **SHA512SU1**: SHA-512 schedule update

**SHA-3 Instructions:**

- **EOR3**: Three-way XOR
- **RAX1**: Rotate and XOR
- **XAR**: XOR and rotate
- **BCAX**: Bit clear and XOR

### Polynomial Multiply Instructions

Used for Galois/Counter Mode (GCM) and other cryptographic operations:

- **PMULL**, **PMULL2**: Polynomial multiply long

**Example:**

```assembly
// GCM multiplication (128-bit carry-less multiply)
// V0, V1 = input operands (128 bits each)

gcm_mult:
        PMULL   V2.1Q, V0.1D, V1.1D         // Low × Low
        PMULL2  V3.1Q, V0.2D, V1.2D         // High × High
        
        EXT     V4.16B, V0.16B, V0.16B, #8  // Swap halves of V0
        EOR     V4.16B, V4.16B, V0.16B      // V4 = Low ⊕ High of V0
        
        EXT     V5.16B, V1.16B, V1.16B, #8
        EOR     V5.16B, V5.16B, V1.16B      // V5 = Low ⊕ High of V1
        
        PMULL   V4.1Q, V4.1D, V5.1D         // Middle term
        
        EOR     V4.16B, V4.16B, V2.16B      // Combine with Low
        EOR     V4.16B, V4.16B, V3.16B      // Combine with High
        
        // Continue with reduction modulo GCM polynomial
        // ...
        
        RET
```

**Key Points:**

- Cryptographic instructions are optional; check ID registers (ID_AA64ISAR0_EL1) to detect availability
- Instructions operate on SIMD&FP registers (V registers) in various element sizes
- Hardware implementations provide constant-time execution, helping prevent timing side-channel attacks
- Multiple blocks can be processed in parallel using different register sets
- Round keys must be pre-expanded and stored in registers for optimal performance
- For production use, implementations should consider cache-timing attacks and use constant-time table lookups where applicable

