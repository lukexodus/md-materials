## Security Model


### Threat Model Specification

Defines adversary capabilities: passive (eavesdropping) vs active (message injection, modification, replay), internal (compromised nodes) vs external (network attackers), computationally bounded vs unbounded. Byzantine security model assumes arbitrary adversary behavior within computational limits.

Architectural design starts with explicit threat model: which components trusted, which untrusted; network boundaries (public internet vs private network); adversary goals (confidentiality breach, integrity violation, availability disruption). Threat model drives authentication, authorization, encryption, and audit mechanisms.

Example boundaries: mutual TLS between microservices (authenticate both parties), API gateway authorization (external clients untrusted), storage encryption (disk/backup compromise), audit logging (insider threat detection).

### Authentication

Verifies claimed identity. Mechanisms:

- **Symmetric key (shared secret)**: HMAC-based message authentication. Key distribution problem—requires pre-shared keys or key exchange protocol (Diffie-Hellman). Scales poorly: O(n²) keys for n-node mutual authentication.
- **Asymmetric key (public-key cryptography)**: Digital signatures (RSA, ECDSA, Ed25519) enable non-repudiation and scalable identity verification. Certificate authorities (CA) or web-of-trust for public key distribution. Certificate revocation (CRL, OCSP) for compromised key invalidation.
- **Kerberos**: Ticket-based authentication with trusted third-party (KDC). Single sign-on within administrative domain. Requires synchronized clocks (timing attack surface).
- **Mutual TLS (mTLS)**: Both client and server authenticate via X.509 certificates. Service mesh architectures (Istio, Linkerd) automate certificate provisioning and rotation via SPIFFE/SPIRE.

Distributed challenge: authenticating transitive communication chains—service A calls B calls C. Solution: token propagation (JWT, OAuth2), per-hop re-authentication, or cryptographic attestation chains.

### Authorization

Determines permitted actions for authenticated principal. Models:

- **Discretionary Access Control (DAC)**: Resource owner grants access. File permissions, ACLs. Vulnerable to Trojan horses (confused deputy problem).
- **Mandatory Access Control (MAC)**: System-wide policy independent of owner preferences. Labels (security classifications), lattice-based policies. Used in high-security environments.
- **Role-Based Access Control (RBAC)**: Permissions assigned to roles; principals assigned roles. Reduces permission management complexity. Challenge: role explosion, coarse-grained permissions.
- **Attribute-Based Access Control (ABAC)**: Policy evaluation based on attributes (subject, resource, environment). Fine-grained, context-aware authorization. Higher computational cost, complex policy debugging.

Distributed authorization patterns:

- **Centralized policy enforcement**: Policy decision point (PDP) separate from enforcement point (PEP). Reduces inconsistency but single point of failure/bottleneck.
- **Distributed policy enforcement**: Each service enforces local policy. Requires policy synchronization or hierarchical policy propagation.
- **Capability-based**: Unforgeable tokens granting specific permissions. Bearer tokens (OAuth2 access tokens) or cryptographic capabilities (Macaroons—attenuatable, contextual authorization).

Architectural tension: centralized authorization simplifies policy consistency but limits scalability/availability; distributed authorization scales but risks policy divergence.

### Confidentiality

Prevents unauthorized information disclosure. Mechanisms:

- **Transport encryption**: TLS/SSL for in-transit protection. Protects against passive eavesdropping and active MITM if certificate validation enforced.
- **End-to-end encryption**: Data encrypted at source, decrypted only at destination. Intermediaries cannot access plaintext. Signal protocol, PGP. Requires key management at endpoints.
- **At-rest encryption**: Storage encryption (disk encryption, database-level encryption, column-level encryption). Protects against physical media theft or backup compromise. Key management critical—key compromise exposes all data.

Key management: Hardware Security Modules (HSM), cloud Key Management Services (AWS KMS, GCP Cloud KMS), distributed key management (Hashicorp Vault). Key rotation policies, key escrow for recovery, separation of duties (split knowledge).

Distributed concern: maintaining confidentiality across organizational boundaries—federated systems require trust anchors, cross-domain encryption, data residency compliance.

### Integrity

Prevents unauthorized modification or ensures detection. Mechanisms:

- **Cryptographic hashing**: SHA-256, SHA-3 for data fingerprinting. Merkle trees for efficient subset verification (blockchain, certificate transparency logs).
- **Message Authentication Codes (MAC)**: HMAC ensures message integrity and authenticity with shared key.
- **Digital signatures**: Public-key signatures provide integrity and non-repudiation. Heavier computational cost than MAC.
- **Write-ahead logging (WAL)**: Append-only log with checksums enables integrity verification and crash recovery.

Distributed integrity: Byzantine agreement protocols (PBFT, BFT-SMaRt) maintain state machine integrity despite malicious replicas. Blockchain consensus (PoW, PoS) ensures ledger integrity via cryptographic chaining and incentive alignment.

Auditability: tamper-evident logs (append-only, hash-chained) enable forensic analysis. Certificate Transparency, Trillian (Google) provide verifiable log infrastructure.

### Availability

Ensures system remains operational under attack. Threats:

- **Denial of Service (DoS)**: Resource exhaustion (CPU, memory, bandwidth, connection limits). Distributed DoS (DDoS) amplifies attack via botnet.
- **Byzantine behavior**: Faulty nodes send conflicting messages, trigger expensive state transitions, exhaust replica resources.

Defenses:

- **Rate limiting**: Token bucket, leaky bucket, sliding window counters. Granularity: per-IP, per-account, per-API-key. Distributed rate limiting requires coordination (Redis, Consul).
- **Admission control**: Reject requests under overload (load shedding). Graceful degradation—shed low-priority traffic first.
- **Redundancy**: Over-provisioning capacity, replica distribution across failure domains. Geographic distribution defends against regional attacks.
- **Proof-of-work**: Computational puzzle (hashcash, captcha) rate-limits requests. Bitcoin mining as spam deterrent.
- **Byzantine quorum systems**: Require 3_f_+1 replicas—tolerate _f_ Byzantine nodes attempting availability disruption.

Architectural pattern: defense in depth—multiple layers (edge rate limiting, application-layer validation, resource quotas). Monitoring/alerting for anomalous traffic patterns.

---

### Related Topics

- Consistency models (linearizability, sequential consistency, causal consistency, eventual consistency)
- Consensus protocols (Paxos, Raft, Viewstamped Replication, Byzantine consensus)
- Replication strategies (primary-backup, chain replication, quorum replication, state machine replication)
- CAP theorem and PACELC extensions
- Time and ordering (logical clocks, vector clocks, hybrid logical clocks)
- Distributed transactions (2PC, 3PC, Saga pattern)
- Failure detectors (implementation and properties)
- Network partitioning and split-brain scenarios

---

