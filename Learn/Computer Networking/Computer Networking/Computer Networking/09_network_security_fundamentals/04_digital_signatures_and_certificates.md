## Digital Signatures and Certificates


Digital signatures provide authentication, integrity verification, and non-repudiation for digital communications and documents.

### Digital Signature Process

#### Signature Creation

**Hash Generation:** Calculate cryptographic hash of message content **Private Key Encryption:** Encrypt hash using sender's private key **Signature Attachment:** Attach encrypted hash to original message **Transmission:** Send signed message to recipient

#### Signature Verification

**Signature Decryption:** Decrypt signature using sender's public key to obtain original hash **Hash Recalculation:** Calculate fresh hash of received message **Comparison:** Compare decrypted hash with recalculated hash **Verification Result:** Matching hashes confirm signature authenticity and message integrity

### Hash Functions

**One-Way Functions:** Easy to compute forward, computationally infeasible to reverse **Avalanche Effect:** Small input changes produce dramatically different outputs **Collision Resistance:** Extremely difficult to find two inputs producing identical outputs

#### Common Hash Algorithms

**MD5 (128-bit):** Legacy algorithm now considered cryptographically broken **SHA-1 (160-bit):** Deprecated due to successful collision attacks **SHA-2 Family:** SHA-224, SHA-256, SHA-384, SHA-512 providing various output lengths **SHA-3:** Latest NIST standard offering alternative design approach

### Public Key Infrastructure (PKI)

#### Certificate Authorities (CAs)

**Root CAs:** Top-level trusted entities in certificate hierarchy **Intermediate CAs:** Subordinate entities delegated certificate issuance authority **Trust Chain:** Hierarchical trust relationships enabling certificate validation **Cross-Certification:** Mutual trust agreements between different CA hierarchies

#### Certificate Lifecycle Management

**Certificate Request:** Applicant submits identity verification and public key **Identity Verification:** CA validates applicant identity through various methods **Certificate Issuance:** CA creates signed certificate binding identity to public key **Certificate Publication:** Making certificates available through directories or repositories **Certificate Revocation:** Invalidating compromised or no longer valid certificates **Certificate Renewal:** Extending certificate validity before expiration

#### X.509 Certificate Format

**Version:** Certificate format version number **Serial Number:** Unique identifier assigned by issuing CA **Signature Algorithm:** Cryptographic algorithm used for CA signature **Issuer:** Distinguished name of certificate issuing authority **Validity Period:** Not-before and not-after dates defining certificate lifetime **Subject:** Distinguished name identifying certificate holder **Subject Public Key:** Public key and algorithm parameters **Extensions:** Additional certificate attributes and constraints **CA Signature:** Digital signature binding all certificate components

### Certificate Revocation

**Certificate Revocation Lists (CRLs):** Periodically published lists of revoked certificates **Online Certificate Status Protocol (OCSP):** Real-time certificate validity checking **OCSP Stapling:** Web servers provide OCSP responses to reduce client overhead **Short-Lived Certificates:** Certificates with brief validity periods reducing revocation needs

### Trust Models

**Hierarchical Trust:** Tree structure with root CA at apex **Web of Trust:** Decentralized trust through peer recommendations **Bridge CA:** Connecting different PKI domains through cross-certification **Trust Anchors:** Pre-installed root certificates in systems and applications

