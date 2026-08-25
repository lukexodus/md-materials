## Secure Password Storage


### Cryptographic Primitive Selection

Modern password storage mandates the use of specialized key derivation functions (KDFs) or password hashing schemes specifically designed to be computationally expensive and memory-hard. General-purpose cryptographic hash functions (e.g., SHA-256, SHA-512, SHA-3) are strictly prohibited for password storage due to their speed, which renders them vulnerable to massive parallelization via GPUs and ASICs.

**Recommended Algorithms (in order of preference):**

1. **Argon2id:** The current OWASP and IETF recommendation. It serves as a hybrid of Argon2i (resistant to side-channel cache timing attacks) and Argon2d (resistant to GPU cracking).
    
    - **Configuration:** Requires tuning three parameters: memory cost ($m$), time cost ($t$), and parallelism ($p$).
        
    - **Implementation Note:** Verify the implementation uses AVX2/AVX-512 optimizations where available on the host CPU.
        
2. **scrypt:** A memory-hard function designed to make hardware implementation expensive.
    
    - **Constraint:** While effective against GPUs, it is theoretically more susceptible to side-channel attacks than Argon2id.
        
    - **Parameters:** CPU/Memory cost ($N$), block size ($r$), parallelization ($p$).
        
3. **bcrypt:** Based on the Blowfish cipher. It is strictly CPU-bound.
    
    - **Limitation:** Vulnerable to FPGA/ASIC acceleration compared to memory-hard functions.
        
    - **Truncation Warning:** Native bcrypt implementations often truncate passwords at 72 bytes. Input must be pre-hashed (e.g., SHA-256) before passing to bcrypt to support long passphrases.
        
4. **PBKDF2:** Recommended **only** if FIPS-140 compliance is a hard requirement.
    
    - **Weakness:** Significantly lower GPU resistance compared to Argon2 or scrypt.
        
    - **Configuration:** Must use HMAC-SHA-256 or higher with iteration counts exceeding 600,000 (as of 2024 standards).
        

### Salt Management

Salts are critical to prevent rainbow table attacks and ensure that identical passwords result in different hashes.

- **Generation:** Use a Cryptographically Secure Pseudo-Random Number Generator (CSPRNG). `Math.random()` or `rand()` are completely insufficient.
    
- **Uniqueness:** A unique salt must be generated for every user credential. Global salts (or reuse of salts) defeat the purpose.
    
- **Length:** Minimum of 128 bits (16 bytes) to prevent collision and pre-computation.
    
- **Storage:** Salts can be stored in plaintext alongside the hash in the database, typically formatted as `{algorithm}${parameters}${salt}${hash}`.
    

### Work Factor Tuning and DoS Protection

The security of a password hash is defined by its "work factor" or "cost"—the computational resources required to verify it.

- **Tuning Strategy:** The work factor should be tuned such that verification takes approximately 500ms to 1000ms on the production authentication server. This creates a significant bottleneck for brute-force attackers while remaining acceptable for legitimate user logins.
    
- **Denial of Service (DoS) Vector:** Setting the work factor too high exposes the authentication endpoint to CPU exhaustion attacks. An attacker can flood the login route with requests, forcing the server to expend maximum CPU on hashing.
    
    - **Mitigation:** Implement strict rate-limiting (leaky bucket algorithm) and CAPTCHA challenges specifically on the login endpoint.
        
    - **Compute Isolation:** Offload password verification to a separate microservice or serverless function to prevent CPU saturation from impacting the main application thread.
        

### Peppering and Secret Management

A "pepper" is a secret key combined with the password (typically via HMAC or concatenation) prior to hashing. Unlike the salt, the pepper is **not** stored in the database.

- **Architecture:** The pepper should be stored in a Hardware Security Module (HSM) or a secure Key Management Service (KMS) (e.g., AWS KMS, Azure Key Vault, HashiCorp Vault).
    
- **Security Benefit:** If the database is compromised via SQL Injection, the hashes remain unbreakable without the separate pepper key.
    
- **Rotation:** Peppering complicates key rotation. If the pepper is compromised, all passwords must be reset or re-hashed. Re-hashing requires waiting for users to log in (see "Hash Upgrades").
    

### Constant-Time Verification

When comparing a user-supplied password against the stored hash, standard string comparison functions (`==`, `strcmp`) must be avoided. These functions return early upon finding the first mismatched byte, exposing the system to **timing attacks**.

- **Requirement:** Use constant-time comparison algorithms (e.g., `crypto.timingSafeEqual` in Node.js, `sodium_memcmp` in PHP/C) which take the same amount of time to execute regardless of whether the strings match or where the mismatch occurs.
    

### Hash Upgrades and Legacy Migration

Security standards evolve. Algorithms effectively weaken over time as hardware improves (Moore's Law).

- **Lazy Migration (Verify-and-Rehash):**
    
    1. Upon login, retrieve the user's stored record.
        
    2. Check the metadata identifying the algorithm and cost factor.
        
    3. If the stored hash uses a legacy algorithm (e.g., MD5) or insufficient work factor:
        
        - Verify the input password against the _legacy_ hash.
            
        - If valid, immediately re-hash the plaintext password using the _current_ standard (e.g., Argon2id).
            
        - Update the database record with the new hash.
            
    4. This allows transparent upgrades without forcing a system-wide password reset.
        

### Memory Handling and Sanitization

Password handling code must minimize the time plaintext passwords reside in memory.

- **Zeroization:** Explicitly overwrite memory buffers containing passwords with zeros immediately after use. In managed languages (Java, C#, Python, JavaScript), this is difficult due to Garbage Collection (GC) and String immutability.
    
    - **Mitigation:** Use `char[]` or `byte[]` arrays instead of Strings where possible, allowing mutable overwrites.
        
    - **Swap Prevention:** Ensure memory pages containing sensitive data are locked in RAM (`mlock`) to prevent them from being written to swap/disk during memory pressure.
        

### Anti-Patterns

- **Client-Side Hashing:** Hashing the password on the client side before transmission is functionally equivalent to sending the password in plaintext. If the hash is intercepted, it can be used to authenticate directly. (Exception: SRP - Secure Remote Password protocol).
    
- **Maximum Length Restrictions:** Arbitrary limits (e.g., 20 characters) prevent the use of passphrases. Code should support long inputs (up to 128+ bytes), utilizing pre-hashing (SHA-256) if the underlying algorithm (like bcrypt) has length limits.
    
- **Rolling Your Own Crypto:** Never implement the hashing algorithm logic manually. Use audited standard libraries (e.g., `libsodium`).
    

### Related Topics

- Multi-Factor Authentication (MFA) Implementation
    
- Rate Limiting and Throttling Strategies
    
- Hardware Security Module (HSM) Integration
    
- Input Validation and Sanitization
    
- Session Management Best Practices

---

