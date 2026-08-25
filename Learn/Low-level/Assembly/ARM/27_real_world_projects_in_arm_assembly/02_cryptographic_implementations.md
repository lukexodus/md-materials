## Cryptographic Implementations


Cryptographic algorithms require careful implementation to ensure both security and performance. Assembly language provides control over timing and side-channel resistance.

### AES Encryption (ARM Cryptographic Extensions)

ARMv8 Cryptographic Extensions provide dedicated instructions for AES, significantly accelerating encryption/decryption.

**AES Instructions:**

- `AESE`: AES single round encryption
- `AESD`: AES single round decryption
- `AESMC`: AES mix columns
- `AESIMC`: AES inverse mix columns

**Example** - AES-128 encryption round (ARMv8-A, 64-bit):

```assembly
.arch armv8-a+crypto
.text

// AES-128 encrypt single block
// x0 = plaintext pointer (16 bytes)
// x1 = round keys pointer (11 round keys, 176 bytes)
// x2 = ciphertext pointer

.global aes128_encrypt
.type aes128_encrypt, %function

aes128_encrypt:
    // Load plaintext block into vector register
    LD1 {v0.16b}, [x0]
    
    // Load all round keys
    LD1 {v16.16b, v17.16b, v18.16b, v19.16b}, [x1], #64
    LD1 {v20.16b, v21.16b, v22.16b, v23.16b}, [x1], #64
    LD1 {v24.16b, v25.16b, v26.16b}, [x1]
    
    // Initial round: XOR with first round key
    EOR v0.16b, v0.16b, v16.16b
    
    // Rounds 1-9: AESE + AESMC
    AESE v0.16b, v17.16b
    AESMC v0.16b, v0.16b
    
    AESE v0.16b, v18.16b
    AESMC v0.16b, v0.16b
    
    AESE v0.16b, v19.16b
    AESMC v0.16b, v0.16b
    
    AESE v0.16b, v20.16b
    AESMC v0.16b, v0.16b
    
    AESE v0.16b, v21.16b
    AESMC v0.16b, v0.16b
    
    AESE v0.16b, v22.16b
    AESMC v0.16b, v0.16b
    
    AESE v0.16b, v23.16b
    AESMC v0.16b, v0.16b
    
    AESE v0.16b, v24.16b
    AESMC v0.16b, v0.16b
    
    AESE v0.16b, v25.16b
    AESMC v0.16b, v0.16b
    
    // Final round: AESE without AESMC
    AESE v0.16b, v26.16b
    
    // Store ciphertext
    ST1 {v0.16b}, [x2]
    
    RET
    
.size aes128_encrypt, .-aes128_encrypt
```

**Performance:** [Inference] ARMv8 crypto extensions enable AES-128 encryption at approximately 1-2 cycles per byte on modern Cortex-A processors, compared to 20-40 cycles per byte for software-only implementations.

### AES Without Hardware Acceleration (Cortex-M)

When hardware acceleration isn't available, optimized software AES implementation uses lookup tables for performance.

**Example** - AES S-box substitution (table-based):

```assembly
.syntax unified
.cpu cortex-m4
.thumb

@ AES SubBytes operation using S-box lookup
@ r0 = state pointer (16 bytes)

.global aes_sub_bytes
.type aes_sub_bytes, %function

aes_sub_bytes:
    PUSH {r4-r7, lr}
    
    LDR r1, =aes_sbox       @ Load S-box table address
    MOV r2, #16             @ 16 bytes to process
    
sub_bytes_loop:
    @ Load byte from state
    LDRB r3, [r0]
    
    @ Lookup in S-box
    LDRB r4, [r1, r3]
    
    @ Store substituted byte
    STRB r4, [r0], #1
    
    SUBS r2, r2, #1
    BNE sub_bytes_loop
    
    POP {r4-r7, pc}
    
.size aes_sub_bytes, .-aes_sub_bytes

@ AES S-box lookup table (256 bytes)
.section .rodata
.align 4
aes_sbox:
    .byte 0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5
    .byte 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76
    .byte 0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0
    .byte 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0
    .byte 0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc
    .byte 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15
    .byte 0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a
    .byte 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75
    .byte 0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0
    .byte 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84
    .byte 0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b
    .byte 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf
    .byte 0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85
    .byte 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8
    .byte 0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5
    .byte 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2
    .byte 0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17
    .byte 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73
    .byte 0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88
    .byte 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb
    .byte 0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c
    .byte 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79
    .byte 0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9
    .byte 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08
    .byte 0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6
    .byte 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a
    .byte 0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e
    .byte 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e
    .byte 0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94
    .byte 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf
    .byte 0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68
    .byte 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
```

**AES MixColumns Implementation:**

MixColumns uses Galois Field (GF(2⁸)) multiplication. Optimized using precomputed tables or bit manipulation.

**Example** - AES MixColumns with table lookup:

```assembly
.syntax unified
.cpu cortex-m4
.thumb

@ AES MixColumns operation
@ r0 = state pointer (16 bytes arranged as 4x4 column-major)

.global aes_mix_columns
.type aes_mix_columns, %function

aes_mix_columns:
    PUSH {r4-r11, lr}
    
    MOV r1, #4              @ 4 columns to process
    
mix_col_loop:
    @ Load 4 bytes of column
    LDRB r2, [r0, #0]       @ s0
    LDRB r3, [r0, #4]       @ s1
    LDRB r4, [r0, #8]       @ s2
    LDRB r5, [r0, #12]      @ s3
    
    @ MixColumns matrix multiplication in GF(2^8):
    @ [2 3 1 1]   [s0]
    @ [1 2 3 1] * [s1]
    @ [1 1 2 3]   [s2]
    @ [3 1 1 2]   [s3]
    
    @ Compute t = s0 ^ s1 ^ s2 ^ s3
    EOR r6, r2, r3
    EOR r6, r6, r4
    EOR r6, r6, r5          @ r6 = t
    
    @ Compute u = s0 ^ s1, multiply by 2 in GF(2^8)
    EOR r7, r2, r3
    BL gf_mul2
    MOV r8, r7
    
    @ Result[0] = s0 ^ u ^ t
    EOR r9, r2, r8
    EOR r9, r9, r6
    STRB r9, [r0, #0]
    
    @ Compute u = s1 ^ s2, multiply by 2
    EOR r7, r3, r4
    BL gf_mul2
    MOV r8, r7
    
    @ Result[1] = s1 ^ u ^ t
    EOR r9, r3, r8
    EOR r9, r9, r6
    STRB r9, [r0, #4]
    
    @ Compute u = s2 ^ s3, multiply by 2
    EOR r7, r4, r5
    BL gf_mul2
    MOV r8, r7
    
    @ Result[2] = s2 ^ u ^ t
    EOR r9, r4, r8
    EOR r9, r9, r6
    STRB r9, [r0, #8]
    
    @ Compute u = s3 ^ s0, multiply by 2
    EOR r7, r5, r2
    BL gf_mul2
    MOV r8, r7
    
    @ Result[3] = s3 ^ u ^ t
    EOR r9, r5, r8
    EOR r9, r9, r6
    STRB r9, [r0, #12]
    
    @ Next column
    ADD r0, r0, #1
    SUBS r1, r1, #1
    BNE mix_col_loop
    
    POP {r4-r11, pc}

@ Galois Field GF(2^8) multiplication by 2
@ r7 = input/output byte
gf_mul2:
    LSL r10, r7, #1         @ Shift left by 1
    TST r7, #0x80           @ Check if high bit was set
    IT NE
    EORNE r10, r10, #0x1B   @ XOR with 0x1B if overflow
    AND r7, r10, #0xFF
    BX lr
    
.size aes_mix_columns, .-aes_mix_columns
```

### SHA-256 Hash Function

SHA-256 is a cryptographic hash function widely used for data integrity and digital signatures.

**Example** - SHA-256 core compression function (optimized for Cortex-M4):

```assembly
.syntax unified
.cpu cortex-m4
.thumb

@ SHA-256 compression function
@ r0 = message block pointer (64 bytes)
@ r1 = hash state pointer (32 bytes, 8 words)

.global sha256_compress
.type sha256_compress, %function

sha256_compress:
    PUSH {r4-r11, lr}
    SUB sp, sp, #64         @ Allocate W[16] on stack
    
    @ Load initial hash values
    LDM r1, {r2-r9}         @ a-h in r2-r9
    
    @ Process 64 rounds
    MOV r10, #0             @ Round counter
    MOV r11, r0             @ Message pointer
    MOV r12, sp             @ W array pointer
    
sha256_round_loop:
    @ Load/compute W[t]
    CMP r10, #16
    BLT sha256_load_w
    
    @ W[t] = W[t-16] + σ0(W[t-15]) + W[t-7] + σ1(W[t-2])
    @ For simplicity, we'll recalculate from message
    @ Full optimization would maintain sliding window
    
sha256_load_w:
    @ Load message word (big-endian)
    LDR r0, [r11], #4
    REV r0, r0              @ Convert to big-endian
    STR r0, [r12], #4
    
    @ Compute T1 = h + Σ1(e) + Ch(e,f,g) + K[t] + W[t]
    
    @ Σ1(e) = ROTR(e,6) ^ ROTR(e,11) ^ ROTR(e,25)
    ROR r14, r6, #6
    EOR r14, r14, r6, ROR #11
    EOR r14, r14, r6, ROR #25
    
    @ Ch(e,f,g) = (e & f) ^ (~e & g)
    AND r0, r6, r7
    BIC r1, r8, r6
    EOR r0, r0, r1
    
    @ T1 = h + Σ1(e) + Ch(e,f,g)
    ADD r0, r9, r14
    ADD r0, r0, r0          @ + Ch result
    
    @ Add K[t] (load from table)
    LDR r1, =sha256_k
    LDR r1, [r1, r10, LSL #2]
    ADD r0, r0, r1
    
    @ Add W[t]
    LDR r1, [sp, r10, LSL #2]
    ADD r0, r0, r1          @ r0 = T1
    
    @ Compute T2 = Σ0(a) + Maj(a,b,c)
    
    @ Σ0(a) = ROTR(a,2) ^ ROTR(a,13) ^ ROTR(a,22)
    ROR r14, r2, #2
    EOR r14, r14, r2, ROR #13
    EOR r14, r14, r2, ROR #22
    
    @ Maj(a,b,c) = (a & b) ^ (a & c) ^ (b & c)
    AND r1, r2, r3
    AND r14, r2, r4
    EOR r1, r1, r14
    AND r14, r3, r4
    EOR r1, r1, r14         @ r1 = Maj result
    
    @ T2 = Σ0(a) + Maj(a,b,c)
    ROR r14, r2, #2
    EOR r14, r14, r2, ROR #13
    EOR r14, r14, r2, ROR #22
    ADD r1, r1, r14         @ r1 = T2
    
    @ Update working variables
    @ h = g, g = f, f = e, e = d + T1
    MOV r9, r8
    MOV r8, r7
    MOV r7, r6
    ADD r6, r5, r0
    
    @ d = c, c = b, b = a, a = T1 + T2
    MOV r5, r4
    MOV r4, r3
    MOV r3, r2
    ADD r2, r0, r1
    
    @ Next round
    ADD r10, r10, #1
    CMP r10, #16            @ Only process first 16 rounds for example
    BLT sha256_round_loop
    
    @ Add compressed chunk to current hash value
    LDM r1!, {r0}
    ADD r2, r2, r0
    LDM r1!, {r0}
    ADD r3, r3, r0
    LDM r1!, {r0}
    ADD r4, r4, r0
    LDM r1!, {r0}
    ADD r5, r5, r0
    LDM r1!, {r0}
    ADD r6, r6, r0
    LDM r1!, {r0}
    ADD r7, r7, r0
    LDM r1!, {r0}
    ADD r8, r8, r0
    LDM r1!, {r0}
    ADD r9, r9, r0
    
    @ Store updated hash
    SUB r1, r1, #32
    STM r1, {r2-r9}
    
    ADD sp, sp, #64
    POP {r4-r11, pc}

.size sha256_compress, .-sha256_compress

@ SHA-256 round constants (first 16 shown)
.section .rodata
.align 4
sha256_k:
    .word 0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5
    .word 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5
    .word 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3
    .word 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174
    @ ... (remaining 48 constants omitted for brevity)
```

### ChaCha20 Stream Cipher

ChaCha20 is a modern stream cipher designed for high performance in software. It uses only addition, XOR, and rotation operations.

**Example** - ChaCha20 quarter round (ARMv7-A with NEON):

```assembly
.arch armv7-a
.fpu neon
.syntax unified
.text

@ ChaCha20 quarter round on NEON vector registers
@ Operates on 4 parallel quarter rounds simultaneously
@ q0-q3 contain state matrix columns

.global chacha20_quarter_round_neon
.type chacha20_quarter_round_neon, %function

chacha20_quarter_round_neon:
    @ a += b; d ^= a; d <<<= 16
    VADD.I32 q0, q0, q1
    VEOR q3, q3, q0
    VSHL.I32 q4, q3, #16
    VSHR.U32 q3, q3, #16
    VORR q3, q4, q3
    
    @ c += d; b ^= c; b <<<= 12
    VADD.I32 q2, q2, q3
    VEOR q1, q1, q2
    VSHL.I32 q4, q1, #12
    VSHR.U32 q1, q1, #20
    VORR q1, q4, q1
    
    @ a += b; d ^= a; d <<<= 8
    VADD.I32 q0, q0, q1
    VEOR q3, q3, q0
    VSHL.I32 q4, q3, #8
    VSHR.U32 q3, q3, #24
    VORR q3, q4, q3
    
    @ c += d; b ^= c; b <<<= 7
    VADD.I32 q2, q2, q3
    VEOR q1, q1, q2
    VSHL.I32 q4, q1, #7
    VSHR.U32 q1, q1, #25
    VORR q1, q4, q1
    
    BX lr

.size chacha20_quarter_round_neon, .-chacha20_quarter_round_neon
```

**ChaCha20 Block Function (Cortex-M4 optimized):**

```assembly
.syntax unified
.cpu cortex-m4
.thumb

@ ChaCha20 block function
@ r0 = output pointer (64 bytes)
@ r1 = input state pointer (64 bytes, 16 words)
@ Performs 20 rounds (10 double rounds)

.global chacha20_block
.type chacha20_block, %function

chacha20_block:
    PUSH {r4-r11, lr}
    SUB sp, sp, #64         @ Working state on stack
    
    @ Copy input state to working state
    MOV r2, sp
    LDM r1!, {r3-r10}
    STM r2!, {r3-r10}
    LDM r1!, {r3-r10}
    STM r2!, {r3-r10}
    
    @ Perform 10 double rounds (20 rounds total)
    MOV r11, #10
    
chacha20_double_round:
    @ Load state into registers
    MOV r2, sp
    LDM r2, {r0-r7}         @ Load first 8 words
    
    @ Quarter round (0, 4, 8, 12) - column round
    @ a += b; d ^= a; d <<<= 16
    ADD r0, r0, r4
    EOR r12, r8, r0
    ROR r8, r12, #16
    
    @ c += d; b ^= c; b <<<= 12
    ADD r8, r8, r12
    EOR r4, r4, r8
    ROR r4, r4, #20         @ 32-12 = 20 for right rotation
    
    @ a += b; d ^= a; d <<<= 8
    ADD r0, r0, r4
    EOR r12, r8, r0
    ROR r8, r12, #24        @ 32-8 = 24
    
    @ c += d; b ^= c; b <<<= 7
    ADD r8, r8, r12
    EOR r4, r4, r8
    ROR r4, r4, #25         @ 32-7 = 25
    
    @ Store back (simplified - full implementation would do all 4 quarters)
    MOV r2, sp
    STM r2, {r0-r7}
    
    SUBS r11, r11, #1
    BNE chacha20_double_round
    
    @ Add original state to working state
    LDR r1, [sp, #64 + 40]  @ Reload original state pointer
    MOV r2, sp
    MOV r3, #16             @ 16 words
    
chacha20_add_loop:
    LDR r4, [r1], #4
    LDR r5, [r2]
    ADD r5, r5, r4
    STR r5, [r2], #4
    SUBS r3, r3, #1
    BNE chacha20_add_loop
    
    @ Copy result to output
    LDR r0, [sp, #64 + 36]  @ Reload output pointer
    MOV r1, sp
    LDM r1!, {r2-r9}
    STM r0!, {r2-r9}
    LDM r1!, {r2-r9}
    STM r0!, {r2-r9}
    
    ADD sp, sp, #64
    POP {r4-r11, pc}

.size chacha20_block, .-chacha20_block
```

### Constant-Time Operations for Side-Channel Resistance

Cryptographic implementations must avoid timing variations that could leak secret information. Assembly provides precise control over execution time.

**Example** - Constant-time comparison:

```assembly
.syntax unified
.cpu cortex-m4
.thumb

@ Constant-time memory comparison
@ r0 = pointer 1
@ r1 = pointer 2
@ r2 = length in bytes
@ Returns: 0 if equal, non-zero if different

.global ct_memcmp
.type ct_memcmp, %function

ct_memcmp:
    PUSH {r4-r5, lr}
    
    MOV r3, #0              @ Accumulator for differences
    
ct_cmp_loop:
    CBZ r2, ct_cmp_done     @ If length is 0, done
    
    LDRB r4, [r0], #1       @ Load byte from buffer 1
    LDRB r5, [r1], #1       @ Load byte from buffer 2
    
    EOR r4, r4, r5          @ XOR to find differences
    ORR r3, r3, r4          @ Accumulate differences
    
    SUBS r2, r2, #1         @ Decrement length
    BNE ct_cmp_loop         @ Continue (constant time - always branches)
    
ct_cmp_done:
    MOV r0, r3              @ Return accumulated differences
    POP {r4-r5, pc}

.size ct_memcmp, .-ct_memcmp
```

**Key characteristics:**

- No conditional branches based on data values
- Always loads both bytes regardless of differences found
- Accumulates all differences before returning
- Execution time depends only on length, not data content

**Example** - Constant-time conditional select:

```assembly
@ Select between two values in constant time
@ r0 = value if condition true
@ r1 = value if condition false
@ r2 = condition (0 or 1)
@ Returns: selected value in r0

.global ct_select
.type ct_select, %function

ct_select:
    @ Create mask: 0xFFFFFFFF if r2==1, 0x00000000 if r2==0
    NEG r2, r2              @ r2 = -r2 (0 -> 0, 1 -> 0xFFFFFFFF)
    
    @ result = (value_true & mask) | (value_false & ~mask)
    AND r3, r0, r2
    BIC r2, r1, r2
    ORR r0, r3, r2
    
    BX lr

.size ct_select, .-ct_select
```

### RSA Modular Exponentiation

RSA encryption/decryption requires modular exponentiation with large integers (typically 2048-4096 bits).

**Example** - Montgomery multiplication for modular arithmetic (simplified 32-bit version):

```assembly
.syntax unified
.cpu cortex-m4
.thumb

@ Montgomery reduction for modular multiplication
@ Computes (a * b * R^-1) mod m where R = 2^32
@ r0 = a (32-bit)
@ r1 = b (32-bit)
@ r2 = m (modulus, 32-bit)
@ r3 = m' (precomputed: -m^-1 mod 2^32)

.global montgomery_mul_32
.type montgomery_mul_32, %function

montgomery_mul_32:
    PUSH {r4-r7, lr}
    
    @ Compute t = a * b (64-bit result)
    UMULL r4, r5, r0, r1    @ r5:r4 = a * b
    
    @ Compute u = (t * m') mod 2^32
    MUL r6, r4, r3          @ r6 = low(t) * m'
    
    @ Compute t = t + u * m
    UMULL r0, r1, r6, r2    @ r1:r0 = u * m
    ADDS r4, r4, r0         @ Add to low word
    ADC r5, r5, r1          @ Add carry to high word
    
    @ Result = t / 2^32 (high word)
    MOV r0, r5
    
    @ Conditional subtraction if result >= m
    CMP r0, r2
    IT HS
    SUBHS r0, r0, r2
    
    POP {r4-r7, pc}

.size montgomery_mul_32, .-montgomery_mul_32
```

[Unverified] For production RSA implementations, multi-precision arithmetic libraries handle integers hundreds of bits long, using optimized assembly for addition, multiplication, and modular reduction across multiple registers and memory locations.

### Elliptic Curve Cryptography (ECC)

ECC provides equivalent security to RSA with much smaller key sizes. Point multiplication on elliptic curves is the core operation.

**Example** - ECC point doubling (conceptual structure for Curve25519):

```assembly
.syntax unified
.cpu cortex-m4
.thumb

@ Elliptic curve point doubling
@ Simplified structure - real implementation requires multi-precision arithmetic

@ Point structure: (X, Y, Z) in projective coordinates
@ Input: r0 = point pointer (3 field elements)
@ Output: point doubled in place

.global ecc_point_double
.type ecc_point_double, %function

ecc_point_double:
    PUSH {r4-r11, lr}
    SUB sp, sp, #48         @ Temporary field elements
    
    @ Load point coordinates (simplified as single registers)
    LDM r0, {r1-r3}         @ X, Y, Z
    
    @ Compute A = X^2
    @ (Call field multiplication routine)
    MOV r0, r1
    MOV r1, r1
    BL field_mul
    STR r0, [sp, #0]        @ Store A
    
    @ Compute B = Y^2
    MOV r0, r2
    MOV r1, r2
    BL field_mul
    STR r0, [sp, #4]        @ Store B
    
    @ Compute C = Z^2
    MOV r0, r3
    MOV r1, r3
    BL field_mul
    STR r0, [sp, #8]        @ Store C
    
    @ Continue with point doubling formulas...
    @ X3 = (B - A - C)^2
    @ Y3 = (A + B) * (A - C)
    @ Z3 = (2*B) * C
    
    @ (Full implementation would continue with field operations)
    
    ADD sp, sp, #48
    POP {r4-r11, pc}

@ Field multiplication placeholder
field_mul:
    @ Multiply r0 * r1 modulo field prime
    @ Real implementation uses multi-precision arithmetic
    UMULL r2, r3, r0, r1
    @ ... modular reduction ...
    MOV r0, r2
    BX lr

.size ecc_point_double, .-ecc_point_double
```

[Inference] Production ECC implementations require careful optimization of field arithmetic (addition, multiplication, squaring, inversion) and often use techniques like sliding window exponentiation for point multiplication.

### Hardware Crypto Acceleration

Many ARM SoCs include cryptographic accelerators that offload operations from the CPU.

**Example** - STM32 hardware AES peripheral configuration:

```assembly
.syntax unified
.cpu cortex-m4
.thumb

.equ AES_BASE,   0x50060000
.equ AES_CR,     0x00
.equ AES_SR,     0x04
.equ AES_DINR,   0x08
.equ AES_DOUTR,  0x0C
.equ AES_KEYR0,  0x10
.equ AES_KEYR1,  0x14
.equ AES_KEYR2,  0x18
.equ AES_KEYR3,  0x1C
.equ AES_IVR0,   0x20

@ Configure and use hardware AES
@ r0 = plaintext pointer
@ r1 = key pointer (128-bit)
@ r2 = ciphertext pointer

.global hw_aes_encrypt
.type hw_aes_encrypt, %function

hw_aes_encrypt:
    PUSH {r4-r7, lr}
    
    LDR r3, =AES_BASE
    
    @ Disable AES
    MOV r4, #0
    STR r4, [r3, #AES_CR]
    
    @ Load key (4 words)
    LDM r1!, {r4-r7}
    STR r4, [r3, #AES_KEYR3]
    STR r5, [r3, #AES_KEYR2]
    STR r6, [r3, #AES_KEYR1]
    STR r7, [r3, #AES_KEYR0]
    
    @ Configure: ECB mode, encryption, enable
    MOV r4, #0x03           @ MODE=00 (ECB), DATATYPE=00, EN=1
    STR r4, [r3, #AES_CR]
    
    @ Wait for key initialization (CCF flag)
1:  LDR r4, [r3, #AES_SR]
    TST r4, #0x01           @ Check CCF bit
    BEQ 1b
    
    @ Clear CCF
    STR r4, [r3, #AES_SR]
    
    @ Load plaintext (4 words)
    LDM r0!, {r4-r7}
    STR r7, [r3, #AES_DINR]
    STR r6, [r3, #AES_DINR]
    STR r5, [r3, #AES_DINR]
    STR r4, [r3, #AES_DINR]
    
    @ Wait for completion (CCF flag)
2:  LDR r4, [r3, #AES_SR]
    TST r4, #0x01
    BEQ 2b
    
    @ Read ciphertext (4 words)
    LDR r7, [r3, #AES_DOUTR]
    LDR r6, [r3, #AES_DOUTR]
    LDR r5, [r3, #AES_DOUTR]
    LDR r4, [r3, #AES_DOUTR]
    STM r2!, {r4-r7}
    
    @ Disable AES
    MOV r4, #0
    STR r4, [r3, #AES_CR]
    
    POP {r4-r7, pc}

.size hw_aes_encrypt, .-hw_aes_encrypt
```

**Performance Comparison:**

[Inference] Performance estimates for different implementations on Cortex-M4 @ 100MHz:

**AES-128 encryption (single block):**

- Software (table-based): ~3,000-4,000 cycles
- Software (bit-sliced): ~5,000-7,000 cycles
- Hardware accelerator: ~100-200 cycles

**SHA-256 (64-byte block):**

- Software (optimized): ~8,000-12,000 cycles
- Hardware accelerator: ~500-1,000 cycles

[Inference] Hardware acceleration provides 10-40x performance improvement but requires careful management of DMA transfers and peripheral state.

**Key Points:**

- Graphics primitives benefit from assembly optimization through direct memory access, SIMD operations, and careful register allocation
- Bresenham's algorithm uses integer-only arithmetic suitable for non-FPU systems
- Alpha blending on RGB565 uses bit field instructions for efficient color channel manipulation
- DMA controllers enable parallel graphics operations without CPU intervention
- Cryptographic algorithms in assembly provide both performance and timing attack resistance
- AES hardware extensions (ARMv8) dramatically accelerate symmetric encryption
- Constant-time implementations prevent side-channel attacks by eliminating data-dependent branches
- Montgomery multiplication enables efficient modular arithmetic for RSA
- Hardware crypto accelerators offload intensive operations, providing significant speedup
- Modern ARM crypto extensions make software-only implementations less critical but assembly knowledge remains valuable for optimization and hardware interaction

---

