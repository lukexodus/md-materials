## Encryption and Decryption


Cryptography transforms readable information into unintelligible format, protecting data confidentiality during transmission and storage.

### Symmetric Encryption

**Shared Secret:** Same key used for both encryption and decryption operations **Performance:** Generally faster than asymmetric encryption for large data volumes **Key Distribution Challenge:** Securely sharing keys between communicating parties

#### Block Ciphers

**Fixed Block Processing:** Encrypt data in fixed-size blocks (typically 64 or 128 bits) **Cipher Modes:** Different methods for processing multiple blocks

**Electronic Code Book (ECB):**

- Each block encrypted independently
- Identical plaintext blocks produce identical ciphertext
- Vulnerable to pattern analysis attacks
- Generally not recommended for most applications

**Cipher Block Chaining (CBC):**

- Each block XORed with previous ciphertext block before encryption
- Initialization Vector (IV) randomizes first block
- Sequential processing prevents parallel encryption
- Popular mode for many applications

**Counter Mode (CTR):**

- Encrypts sequential counter values to create keystream
- XOR keystream with plaintext to produce ciphertext
- Supports parallel processing and random access
- Must never reuse counter values with same key

#### Stream Ciphers

**Continuous Processing:** Generate keystream to encrypt data bit-by-bit or byte-by-byte **Real-Time Applications:** Suitable for continuous data streams like voice or video **Synchronization Requirement:** Sender and receiver must maintain keystream synchronization

**Common Algorithms:**

- **RC4:** Widely used but now considered insecure due to known vulnerabilities
- **ChaCha20:** Modern stream cipher designed for high performance and security
- **Salsa20:** Related to ChaCha20 with similar security properties

### Asymmetric Encryption

**Key Pairs:** Mathematical relationship between public and private keys **Public Key Distribution:** Public keys can be freely shared without compromising security **Computational Overhead:** Significantly slower than symmetric encryption

#### RSA (Rivest-Shamir-Adleman)

**Mathematical Foundation:** Based on difficulty of factoring large composite numbers **Key Sizes:** Typically 2048 or 4096 bits for adequate security **Applications:** Digital signatures, key exchange, small data encryption **Performance:** Slow for bulk data encryption

#### Elliptic Curve Cryptography (ECC)

**Mathematical Basis:** Discrete logarithm problem on elliptic curves **Key Size Advantage:** Smaller keys provide equivalent security to RSA **Mobile Applications:** Lower computational requirements benefit resource-constrained devices **Government Adoption:** NSA Suite B cryptography includes ECC algorithms

### Hybrid Encryption Systems

**Combination Approach:** Asymmetric encryption for key exchange, symmetric encryption for data **Performance Optimization:** Leverages speed of symmetric encryption with security of asymmetric **Common Implementation:** RSA key exchange with AES data encryption

### Key Management

**Key Generation:** Creating cryptographically strong random keys **Key Distribution:** Securely sharing keys between authorized parties **Key Storage:** Protecting keys from unauthorized access or disclosure **Key Rotation:** Regularly changing keys to limit exposure from compromise **Key Escrow:** Securely storing backup copies for recovery purposes

#### Hardware Security Modules (HSMs)

**Tamper-Resistant Hardware:** Physical protection against key extraction **High Performance:** Dedicated cryptographic processing capabilities **Compliance Support:** Meeting regulatory requirements for key protection **Applications:** Root certificate authorities, payment processing, database encryption

