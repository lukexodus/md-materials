## Password Hashing


### Algorithm Selection and Configuration

Modern password hashing requires memory-hard and CPU-intensive algorithms to resist GPU-based brute-force and ASIC-optimized attacks. General-purpose cryptographic hash functions (e.g., SHA-256, SHA-3, MD5) are designed for speed and are fundamentally unsuitable for password storage.

#### Recommended Algorithms (NIST/OWASP Standards)

1. **Argon2id:** The current state-of-the-art, winner of the Password Hashing Competition (PHC). It is a hybrid of Argon2d (resistant to GPU cracking) and Argon2i (resistant to side-channel attacks).
    
    - **Configuration:**
        
        - **Memory Cost ($m$):** Maximize based on server constraints (e.g., 64MB+).
            
        - **Time Cost ($t$):** Linear execution time iterations. Adjust to satisfy latency requirements (typically < 500ms for login).
            
        - **Parallelism ($p$):** Set to match the number of available threads/cores per instance.
            
2. **scrypt:** Strong alternative if Argon2 is unavailable. Heavily memory-hard, making custom hardware attacks expensive.
    
    - **Parameters:** $N$ (CPU/memory cost), $r$ (block size), $p$ (parallelization).
        
    - **Constraint:** Vulnerable to side-channel attacks in high-contention environments compared to Argon2id.
        
3. **bcrypt:** Acceptable for legacy compatibility but less resistant to FPGA/ASIC attacks due to low memory footprint.
    
    - **Work Factor:** Logarithmic cost ($2^{\text{cost}}$). Minimum recommended cost is 12 (as of 2024 standards).
        
4. **PBKDF2-HMAC-SHA256:** FIPS-140 compliance fallback. Requires significantly high iteration counts (NIST recommends 600,000+) to compensate for lack of memory hardness.
    

### Salt Management and Entropy

Proper salting is non-negotiable to prevent rainbow table attacks and ensure that identical passwords result in distinct hashes.

- **Generation:** Use a Cryptographically Secure Pseudo-Random Number Generator (CSPRNG). `java.security.SecureRandom`, `os.urandom`, or `crypto.rand`.
    
- **Length:** Minimum 128 bits (16 bytes). 160 bits (20 bytes) recommended for margin.
    
- **Uniqueness:** Unique per user credential. Never reuse salts globally or across environments.
    
- **Storage:** The salt is public data relative to the database and should be stored alongside the hash (often encoded in the PHC string format).
    

### Architecture and Schema Design

Store hashes using the Password Hashing Competition (PHC) string format to ensure portability and facilitate algorithm upgrades.

**Format:** `$<algorithm>$v=<version>$m=<memory>,t=<iterations>,p=<parallelism>$<b64_salt>$<b64_hash>`

**Example (Argon2id):**

Plaintext

```
$argon2id$v=19$m=65536,t=2,p=1$gZiV/M1g3q2CAPmBAUhkDg$J/hJ8/7F+7Jg4Qk2qjV8Nq
```

#### Database Schema

Avoid separating salt and hash into distinct columns unless strictly required by legacy constraints.

- **Column Type:** `VARCHAR(255)` or `TEXT` to accommodate variable-length algorithm parameters and base64 encoding.
    
- **Do Not Truncate:** Ensure the column width handles the maximum output length of future algorithms.
    

### Advanced Security Controls

#### Peppering (Secret Key)

A pepper is a secret key added to the password before hashing (e.g., `HMAC-SHA256(password, pepper)` -> `Argon2(result)`). Unlike the salt, the pepper is **not** stored in the database.

- **Storage:** Store in a Hardware Security Module (HSM), Key Management Service (KMS), or secure environment variables.
    
- **Rotation:** Implementing rotation is complex. Use a versioning strategy where the key ID is stored with the hash to allow phased rotation.
    
- **Benefit:** Compromise of the SQL database does not yield crackable hashes without the separate pepper key.
    

#### Timing Attack Mitigation

Password verification must occur in constant time to prevent user enumeration or hash deduction via timing analysis.

- **Implementation:** Use `crypto.timingSafeEqual` (Node.js), `MessageDigest.isEqual` (Java), or equivalent constant-time comparison functions when validating the computed hash against the stored hash.
    

### Migration and Upgradability

Systems must support seamless transitions to stronger algorithms or higher work factors as hardware improves ("Ratchet" mechanism).

1. **Read-Time Upgrade:**
    
    - On user login, retrieve the stored hash.
        
    - Identify if the algorithm or work factor is outdated (e.g., `stored_cost < current_policy_cost`).
        
    - Verify the password using the _old_ parameters.
        
    - If valid, immediately re-hash the plaintext password with _new_ parameters/algorithm and update the database record.
        
2. **Versioning:** Enforce a schema that inherently supports multiple algorithms active simultaneously.
    

### Anti-Patterns and Vulnerabilities

- **Fast Hashes:** Usage of MD5, SHA-1, SHA-256, or SHA-512 without key derivation. These allow billions of guesses per second on consumer hardware.
    
- **Static/Global Salts:** Using a single salt for all users defeats the purpose of salting.
    
- **Double Hashing without Understanding:** `SHA256(Argon2(pass))` destroys the memory-hard properties of Argon2. Never post-process the output of a specialized password hash.
    
- **Maximum Length Constraints:** Failing to handle long passwords (e.g., bcrypt has a 72-byte limit).
    
    - _Mitigation:_ Pre-hash long passwords using SHA-256 before passing to bcrypt to normalize length.
        
- **Client-Side Hashing:** Hashing passwords on the client (frontend) transmits the "hash" as the equivalent of a plaintext credential. If intercepted, the attacker can replay the hash. If client-side hashing is required (e.g., for zero-knowledge privacy), the server must re-hash the received value.
    

**Related Topics:**

- Multi-Factor Authentication (MFA) Implementation
    
- Rate Limiting and Brute Force Protection
    
- Key Management Systems (KMS)
    
- Secure Session Management
    
- Credential Stuffing Defense

---

