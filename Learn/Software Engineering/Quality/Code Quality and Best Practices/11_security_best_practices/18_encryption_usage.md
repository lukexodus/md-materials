## Encryption Usage


Effective encryption implementation requires adherence to modern cryptographic standards, rigorous key management lifecycles, and the exclusive use of Authenticated Encryption (AE) modes to guarantee both confidentiality and integrity.

### Symmetric Encryption Standards

Symmetric encryption is the standard for bulk data encryption (data at rest).1

- **Algorithm Selection:**
    
    - **Standard:** AES-256 (Advanced Encryption Standard).2
        
    - **Performance Alternative:** ChaCha20-Poly1305. Preferred on mobile or architecture without hardware AES acceleration (AES-NI).3
        
- **Modes of Operation:**
    
    - **Mandatory:** Use Authenticated Encryption with Associated Data (AEAD) modes. **AES-GCM** (Galois/Counter Mode) is the industry standard. It provides confidentiality and data integrity simultaneously, preventing bit-flipping attacks that are possible with unauthenticated modes.4
        
    - **Forbidden:** **AES-ECB** (Electronic Codebook) must never be used; it leaks pattern information (identical plaintext blocks produce identical ciphertext blocks).5 **AES-CBC** (Cipher Block Chaining) should be avoided due to susceptibility to padding oracle attacks unless strictly managed with Encrypt-then-MAC constructions.
        
- **Initialization Vectors (IV) / Nonces:**
    
    - Must be unique for every encryption operation under the same key.
        
    - For GCM, a 96-bit (12-byte) IV is standard.6 Reusing a nonce with the same key in GCM destroys security completely (reveals the authentication key).
        

### Asymmetric Encryption and Digital Signatures

Asymmetric cryptography is primarily used for key exchange, digital signatures, and identity verification.7

- **Elliptic Curve Cryptography (ECC):**
    
    - Preferred over RSA due to smaller key sizes and better performance for equivalent security levels.8
        
    - **Curves:** Use **Curve25519** (X25519 for key exchange, Ed25519 for signatures) or NIST P-256/P-384.
        
- **RSA Configuration:**
    
    - If legacy support necessitates RSA, minimum key size is **2048-bit** (3072-bit or 4096-bit recommended for long-term retention).
        
    - **Padding:** Must use **OAEP** (Optimal Asymmetric Encryption Padding) for encryption and **PSS** (Probabilistic Signature Scheme) for signatures. Deprecate PKCS#1 v1.5 padding immediately due to Bleichenbacher vulnerabilities.
        

### Data in Transit (Transport Layer Security)

Encryption in transit prevents eavesdropping and Man-in-the-Middle (MitM) attacks.9

- **Protocol Versions:** Enforce **TLS 1.3**. Support TLS 1.2 only if legacy client compatibility is strictly required. Disable SSLv3, TLS 1.0, and TLS 1.1.
    
- **Cipher Suites:** Restrict suites to those supporting Forward Secrecy (FS). This ensures that compromise of the server's long-term private key does not compromise past session traffic.
    
    - _Example (TLS 1.3):_ `TLS_AES_256_GCM_SHA384`, `TLS_CHACHA20_POLY1305_SHA256`.10
        
- **HSTS (HTTP Strict Transport Security):** Implement HSTS with `includeSubDomains` and `preload` to force client-side strictly secure connections, neutralizing SSL stripping attacks.11
    

### Key Management and Envelope Encryption

The security of encrypted data depends entirely on the protection of the decryption keys.

- **Envelope Encryption:**
    
    - Do not use the master key to encrypt data directly.
        
    - **Method:**
        
        1. Generate a unique **Data Encryption Key (DEK)** for the specific data payload.
            
        2. Encrypt the data with the DEK.
            
        3. Encrypt the DEK with a **Key Encryption Key (KEK)** (Master Key) stored in a Hardware Security Module (HSM) or Key Management Service (KMS).12
            
        4. Store the _encrypted_ DEK alongside the ciphertext.
            
- **Key Rotation:**
    
    - Implement automated rotation policies for KEKs. Re-encryption of old data (re-wrapping DEKs) should occur periodically or upon suspected compromise.
        
- **Hardcoding:**
    
    - **Strict Prohibition:** Never hardcode cryptographic keys in source code, configuration files, or version control systems.13 Use environment variables injected at runtime via secure vaults (e.g., HashiCorp Vault, AWS Secrets Manager).
        

### Randomness and Entropy

Cryptographic strength relies on high-entropy random number generation.14

- **CSPRNG:** Always use a Cryptographically Secure Pseudo-Random Number Generator.
    
    - _Java:_ `java.security.SecureRandom` (avoid `java.util.Random`).15
        
    - _Python:_ `secrets` module or `os.urandom` (avoid `random` module).16
        
    - _JavaScript (Node):_ `crypto.randomBytes` (avoid `Math.random`).17
        
- **Seeding:** Ensure the entropy pool is sufficient, particularly in containerized or embedded environments where entropy starvation can lead to predictable key generation.18
    

Related Topics: PKI Infrastructure, Hardware Security Modules (HSM), Secret Management, Cryptographic Agility.

---

