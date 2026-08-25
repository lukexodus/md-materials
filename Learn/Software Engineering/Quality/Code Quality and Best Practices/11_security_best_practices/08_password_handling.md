## Password Handling


### Cryptographic Storage Standards

The storage of user credentials requires robust resistance against rainbow table attacks, brute-force attempts, and side-channel analysis. Simple hashing (SHA-256) is insufficient due to GPU/ASIC acceleration capabilities.

- **Algorithm Selection:**
    
    - **Argon2id:** The current industry standard (winner of PHC). It creates a hybrid of Argon2i (side-channel resistance) and Argon2d (GPU resistance).
        
        - _Configuration:_ Must be tuned to the specific hardware constraints of the auth server. Standard recommendation: Minimum 64 MiB memory cost, 1 iteration, 4 parallelism lanes.
            
    - **bcrypt:** Acceptable fallback for legacy systems. Ensure a work factor (cost) of at least 12 (preferably 14+), recalibrated annually to match hardware evolution.
        
    - **scrypt:** Strong memory-hardness properties but potentially vulnerable to side-channel attacks compared to Argon2id. Use only if hardware acceleration resistance is the primary threat vector and Argon2id is unavailable.
        
- **Salting Strategy:**
    
    - Generate a unique, random salt for _every_ password using a Cryptographically Secure Pseudo-Random Number Generator (CSPRNG).
        
    - **Length:** Minimum 16 bytes (128 bits).
        
    - **Storage:** Store the salt alongside the hash in the database. It is not a secret but a uniqueness constraint to defeat pre-computed tables.
        
- **Peppering (Secret Salt):**
    
    - Implement a server-side secret (pepper) typically stored in a Hardware Security Module (HSM) or a Key Management Service (KMS), distinct from the database.
        
    - Combine the pepper with the password before hashing. If the database is compromised (SQLi), the hashes remain resistant to offline cracking without the pepper.
        

### In-Memory Management and Lifecycle

Handling passwords in volatile memory presents significant risks regarding swap files, core dumps, and garbage collection (GC) behavior.

- **Immutable Strings vs. Mutable Arrays:**
    
    - **Avoid String Types:** In managed languages (Java, C#, Python), Strings are immutable. Once created, they reside in the heap until GC. They cannot be explicitly zeroed out.
        
    - **Use Char/Byte Arrays:** Store passwords in `char[]` or `byte[]`. Immediately overwrite the array with zeros (`0x00`) using a `finally` block or a specific destructor pattern (e.g., `SecureString` in .NET, though deprecated in Core, manual wiping is preferred) once the hashing operation is complete.
        
- **Memory Locking:**
    
    - Prevent the operating system from swapping the password memory page to disk. Use `mlock` (POSIX) or `VirtualLock` (Windows) for the duration of the authentication process.
        
- **Core Dumps:**
    
    - Configure the deployment environment to disable core dumps (`ulimit -c 0`) to prevent credential leakage during application crashes.
        

### Timing Attack Mitigation

Verification logic often introduces side-channel vulnerabilities where the time taken to reject a password correlates with the number of correct characters or the hashing duration.

- **Constant-Time Comparison:**
    
    - Never use standard string equality operators (`==`, `.equals()`, `strcmp`) for comparing the computed hash with the stored hash. These fail fast upon the first character mismatch.
        
    - Use cryptographic constant-time comparison functions (e.g., `MessageDigest.isEqual` in Java, `crypto.timingSafeEqual` in Node.js).
        
- **User Enumeration:**
    
    - Authentication endpoints must return generic error messages (e.g., "Invalid username or password") regardless of whether the user exists or the password was incorrect.
        
    - **Execution Time Normalization:** If a user is not found, the system must simulate the time cost of a password hash verification (perform a dummy hash) to prevent attackers from distinguishing valid users based on response latency.
        

### NIST 800-63B Compliance and Validation

Modern best practices adhere to NIST Special Publication 800-63B, shifting focus from complexity rules to length and blocklists.

- **Composition Rules:**
    
    - **Abolish Arbitrary Complexity:** Remove requirements for mixed case, special characters, and numbers. These lead to predictable patterns (e.g., `Password1!`).
        
    - **Length Priority:** Enforce a minimum length of 8 characters, with a recommendation of 12+ for users and 15+ for privileged accounts. Allow extensive maximum lengths (e.g., 64 or 128 characters) to support passphrases.
        
- **Compromised Credential Checking:**
    
    - Integrate checks against known breached password databases (e.g., Have I Been Pwned API) via k-Anonymity models during registration and password changes.
        
- **Truncation:**
    
    - Silent truncation is an anti-pattern. If the hashing algorithm limits input length (e.g., bcrypt's 72-byte limit), hash the password with SHA-256 before passing it to bcrypt to preserve entropy without exceeding length limits.
        

### Reset and Recovery Workflows

Password reset mechanisms are high-value targets for account takeover.

- **Token Generation:** Use a high-entropy, cryptographically secure random string (minimum 128-bit). Do not use predictable identifiers (UUIDv1) or user-specific data (timestamp + ID).
    
- **Hashing Tokens:** Store the _hash_ of the reset token in the database, not the plain token. Verification involves hashing the token provided by the user and comparing it to the stored hash. This mitigates the risk if the reset token table is dumped.
    
- **Expiration:** Set short expiration windows (e.g., 15-20 minutes).
    
- **Session Termination:** Upon a successful password change, invalidate all active sessions and refresh tokens for that user immediately.
    

### Logging and Monitoring

- **Redaction:** Implement strict filters in the logging pipeline to identify and redact fields named `password`, `secret`, `token`, or `auth`.
    
- **Audit Trails:** Log _events_ related to authentication (success, failure, reset request) but never the _content_ of the credentials.
    
- **Rate Limiting:** Implement exponential backoff or IP-based throttling on login endpoints to prevent online brute-force attacks.
    

**Related Topics:**

- Multi-Factor Authentication (MFA) Implementation
    
- OAuth 2.0 and OIDC Flows
    
- Session Management Security
    
- Secrets Management in CI/CD

---

