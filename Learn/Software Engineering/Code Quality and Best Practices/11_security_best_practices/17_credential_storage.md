## Credential Storage


Secure credential storage demands a cryptographic architecture that renders stolen data computationally infeasible to exploit. The primary objective is to increase the cost of offline attacks (brute-force, rainbow tables) beyond the value of the compromised data, while ensuring strict access controls for reversible secrets.

### Password Hashing Algorithms

Storing passwords in plaintext or using reversible encryption is a catastrophic failure. Fast cryptographic hash functions (MD5, SHA-1, SHA-256, SHA-3) are unsuitable for password storage due to their vulnerability to ASIC-optimized brute-force attacks.

- **Argon2id:** The current industry standard and winner of the Password Hashing Competition (PHC). It is memory-hard and resistance to GPU/ASIC cracking.
    
    - **Configuration:** Must be configured with three parameters: memory cost ($m$), time cost/iterations ($t$), and parallelism ($p$).
        
    - **Selection:** Use `Argon2id` (hybrid) to resist both side-channel (timing) attacks and TMTO (Time-Memory Trade-Off) attacks. Avoid `Argon2i` or `Argon2d` in isolation for general password storage.
        
- **Bcrypt:** A robust alternative for legacy systems. It relies on a work factor (cost) that scales exponentially ($2^{cost}$).
    
    - **Limitation:** Bcrypt truncates passwords at 72 characters. Pre-hashing (e.g., SHA-256) before bcrypting is required to support longer passphrases without null-byte truncation vulnerabilities.
        
- **PBKDF2:** NIST-approved but less resistant to GPU acceleration than Argon2 or Bcrypt. Only use if FIPS compliance mandates it.
    

### Salting and Peppering

- **Salting:** Every password hash must include a unique, cryptographically secure random salt (CSPRNG) of at least 16 bytes. The salt prevents the use of rainbow tables and ensures that identical passwords yield different hashes. The salt is stored alongside the hash.
    
- **Peppering (Secret Key):** A high-entropy secret key (pepper) typically stored in an HSM or a secure configuration separate from the database. The pepper is combined with the password/salt before hashing.
    
    - **Defense:** If the database is compromised via SQL Injection, the hashes remain resilient against offline cracking unless the attacker also compromises the separate keystore.
        

### Work Factor Tuning

Hashing parameters must be tuned to the specific hardware capabilities of the authentication server.

- **Calibration:** The goal is to make the hash function calculation as slow as possible without impacting user experience (UX). A target duration of 500ms to 1000ms per verification is standard for critical systems.
    
- **Adaptive Security:** As hardware performance improves, work factors (iterations/memory) must be increased. The system should support "seamless migration": upon successful login, if the stored hash uses outdated parameters, re-hash the plaintext password with the new configuration and update the record.
    

### Reversible Secrets (API Keys & Tokens)

Unlike passwords, machine-to-machine credentials (API keys, database connection strings) often require reversible encryption or must be retrieved in plaintext by the application.

- **Envelope Encryption:** Encrypt the data with a Data Encryption Key (DEK). Encrypt the DEK with a Key Encryption Key (KEK). Store the encrypted DEK with the data; keep the KEK in a Key Management Service (KMS).
    
- **Hashing API Keys:** If the system only needs to _verify_ an API key (not display it), hash it using SHA-256.
    
    - **Architecture:** Generate the key, display it once to the user, hash it, and store only the hash. This treats API keys identical to passwords, eliminating the risk of plaintext key leakage from the database.
        

### Secrets Management Infrastructure

Hardcoding credentials in source code, configuration files, or environment variables committed to version control is a critical anti-pattern.

- **Centralized Vaults:** Use dedicated secrets management solutions (e.g., HashiCorp Vault, AWS Secrets Manager, Azure Key Vault). These tools provide:
    
    - **Dynamic Secrets:** Generate ephemeral credentials that expire automatically (e.g., "lease" a database user for 1 hour).
        
    - **Audit Logging:** distinct logs for every access attempt to a secret.
        
    - **Rotational Policies:** Automated rotation of long-lived secrets without code changes.
        
- **Injection:** Secrets should be injected into the application runtime process via RAM-only filesystems or environment variables populated _at startup_ by the orchestrator (Kubernetes Secrets), ensuring they never touch disk.
    

### Memory Hygiene

Credential handling extends to RAM usage to prevent leakage via core dumps, swap files, or memory scraping malware.

- **Immutable Strings:** In languages like Java or C#, `String` objects are immutable and linger in the String Pool until garbage collection. Use mutable character arrays (`char[]`) or `byte[]` for passwords.
    
- **Zeroization:** Explicitly overwrite the memory buffer containing the password with zeros immediately after the hashing operation is complete.
    
- **Disable Swap:** For high-security environments, disable swap space on authentication servers or ensure swap partitions are fully encrypted.
    

Related Topics: Key Management Service (KMS) Architecture, Zero-Knowledge Architectures, HSM Integration Patterns, OAuth 2.0 Token Storage.

---

