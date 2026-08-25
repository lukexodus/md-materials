## Security


### Authentication and Authorization

**Mutual TLS (mTLS)**

Client and server authenticate via X.509 certificates. Certificate authority hierarchy establishes trust. Certificate revocation lists (CRL) or OCSP for invalidation. Short-lived certificates reduce revocation latency. Certificate rotation strategies (blue-green, rolling). Private key storage in HSMs or TPMs. Service mesh sidecars automate mTLS negotiation.

**Token-Based Authentication**

JSON Web Tokens (JWT) carry signed claims. Signature verification without central authentication server. Stateless tokens enable horizontal scaling. Token expiration limits compromise window. Refresh tokens enable long-lived sessions with short access token TTL. Token revocation requires distributed cache or database lookup. Audience restriction prevents token misuse across services.

**Identity Federation**

SAML 2.0 for web SSO across organizational boundaries. OAuth 2.0 delegation enables third-party access. OpenID Connect adds identity layer atop OAuth. Trust relationships via metadata exchange. Assertion mapping translates external identities to internal principals. Attribute-based access control (ABAC) uses federated attributes.

**Service Mesh Authorization**

Workload identity derived from Kubernetes service accounts or AWS IAM roles. Policy enforcement at sidecar proxy. SPIFFE (Secure Production Identity Framework for Everyone) provides verifiable identity. Fine-grained authz policies (method, path, header-based). Centralized policy distribution via control plane. Audit logging of authorization decisions.

### Secure Communication

**TLS Termination Strategies**

Edge termination: TLS ends at load balancer, plaintext to backends. Passthrough: TLS end-to-end, load balancer routes encrypted streams. Re-encryption: terminate at load balancer, re-encrypt to backends. Tradeoffs: performance vs. security vs. observability. Certificate management complexity with end-to-end encryption. SNI-based routing for multi-tenant TLS termination.

**Encrypted Data Plane**

IPsec tunnels for network-layer encryption. WireGuard for lightweight VPN mesh. MACsec for layer 2 encryption within data centers. Encryption overhead: latency, throughput, CPU utilization. Hardware acceleration (AES-NI, TLS offload) mitigates overhead. Cipher suite negotiation balances security and performance.

**Secure Multi-Party Communication**

Group key management for multicast encryption. Centralized vs. decentralized key distribution. Key rotation on membership changes. Forward secrecy via ephemeral keys. Message integrity via HMAC or authenticated encryption (AES-GCM). Replay protection via sequence numbers or timestamps.

### Data Protection

**Encryption at Rest**

Full-disk encryption (dm-crypt, BitLocker) protects against physical theft. Per-file or per-object encryption enables key rotation. Key hierarchy: data keys encrypted by key-encryption keys. Key management service (KMS) centralizes key storage and access control. Envelope encryption reduces KMS load. Transparent data encryption (TDE) in databases.

**Data Anonymization**

Pseudonymization replaces identifiers with tokens. Tokenization vault stores mapping, enables reversibility. k-anonymity ensures each record indistinguishable from k-1 others. Differential privacy adds calibrated noise to query results. Data masking for non-production environments. Field-level encryption for sensitive attributes.

**Secure Deletion**

Cryptographic erasure: delete encryption keys to render data unrecoverable. Challenge with replicated data—synchronize key deletion. Log-structured storage complicates overwrite-based deletion. Garbage collection timing affects data retention. Compliance requirements (GDPR right to erasure) require verifiable deletion. Secure erase commands (ATA, NVMe) for physical media.

### Secrets Management

**Secret Distribution**

Centralized secret stores (HashiCorp Vault, AWS Secrets Manager). Pull model: applications retrieve secrets on startup. Push model: sidecar injects secrets into environment. Dynamic secrets generated on-demand with TTL. Encryption in transit and at rest. Access auditing for compliance.

**Secret Rotation**

Automated rotation reduces credential lifetime. Versioned secrets enable graceful cutover. Application restart or hot-reload on rotation. Database credential rotation with connection pool draining. Certificate rotation with overlapping validity periods. Breaking glass procedures for emergency rotation.

**Least Privilege Access**

Service accounts with minimal permission scopes. IAM policies restrict secrets access by identity and resource. Temporal access with session tokens. Approval workflows for elevated privileges. Break-glass access with audit trail. Namespace or tenant isolation in multi-tenant systems.

### Network Security

**Firewall and Network Policies**

Stateful firewalls track connection state. Network policies (Kubernetes NetworkPolicy, AWS Security Groups). Default deny with explicit allow rules. Microsegmentation isolates workloads. Egress filtering prevents data exfiltration. Intrusion detection/prevention systems (IDS/IPS).

**DDoS Mitigation**

Rate limiting at edge (per-IP, per-API-key). SYN cookies mitigate SYN flood attacks. Traffic scrubbing redirects suspicious traffic to mitigation infrastructure. Anycast routing distributes volumetric attacks. Challenge-response (CAPTCHA) for application-layer attacks. Cloud-based DDoS protection services (Cloudflare, AWS Shield).

**Service Mesh Security Policies**

Zero-trust networking—verify every connection. Deny-by-default authorization. Fine-grained policies (service-to-service, method-level). Policy as code stored in version control. Automated policy testing in CI/CD. Policy violation alerting and blocking.

### Compliance and Audit

**Audit Logging**

Immutable audit logs for forensic analysis. Structured logging (JSON) for machine parsing. Centralized log aggregation (ELK, Splunk). Log retention policies per regulatory requirements. Tamper-evident logs via cryptographic hashing or blockchain. Access logs for authentication, authorization, data access.

**Compliance Frameworks**

SOC 2 Type II controls for service organizations. PCI DSS for payment card data handling. HIPAA for healthcare data protection. GDPR for EU resident data privacy. FIPS 140-2 for cryptographic module validation. Automated compliance checks in CI/CD pipelines.

**Data Residency**

Geographic restrictions on data storage and processing. Data sovereignty regulations (GDPR, China Cybersecurity Law). Regional replicas and routing for compliance. Encryption key residency separate from data. Cross-border transfer mechanisms (Standard Contractual Clauses). Compliance as code via policy engines (OPA).

### Secure Software Supply Chain

**Dependency Scanning**

Vulnerability databases (CVE, NVD). Automated scanning in CI/CD (Snyk, Dependabot). Software Bill of Materials (SBOM) for transparency. Dependency pinning and lock files. Private artifact repositories with scanning. License compliance checks.

**Image Signing and Verification**

Cryptographic signing of container images (Notary, Sigstore). Admission controllers verify signatures (Kubernetes). Image provenance tracking via SLSA framework. Minimal base images reduce attack surface. Distroless images eliminate package managers. Runtime vulnerability scanning.

**Build Provenance**

Reproducible builds enable verification. Hermetic builds isolate from external state. SLSA (Supply-chain Levels for Software Artifacts) attestations. CI/CD pipeline security (protected branches, approval gates). Signed commits and tags. Artifact integrity checks (checksums, signatures).

### Runtime Security

**Sandboxing and Isolation**

Containers with restricted capabilities (AppArmor, SELinux). gVisor provides additional isolation via user-space kernel. Firecracker MicroVMs for strong isolation. WebAssembly sandboxing for untrusted code. Seccomp-bpf restricts system calls. Namespaces and cgroups for resource isolation.

**Runtime Threat Detection**

Anomaly detection via behavioral analysis. System call monitoring (Falco). Network traffic analysis for C2 communication. File integrity monitoring (AIDE, Tripwire). Process activity monitoring. Security Information and Event Management (SIEM) integration.

**Immutable Infrastructure**

Read-only root filesystems prevent tampering. Ephemeral compute—terminate and replace on suspicion. Configuration drift detection. Image-based deployments vs. in-place updates. Rollback via image version change. Secrets injected at runtime, not baked into images.

### Cryptographic Protocols

**Key Exchange**

Diffie-Hellman ephemeral (DHE) for forward secrecy. Elliptic Curve Diffie-Hellman Ephemeral (ECDHE) reduces key sizes. Pre-shared keys (PSK) for IoT devices. Quantum-resistant key exchange (NIST post-quantum candidates). Session key derivation from master secret. Key confirmation via authenticated key exchange (AKE).

**Digital Signatures**

RSA signatures for legacy compatibility. ECDSA for compact signatures. EdDSA (Ed25519) for high performance. Signature aggregation in blockchain systems. Threshold signatures for distributed signing. Blind signatures for privacy-preserving protocols.

**Hash Functions and MACs**

SHA-256, SHA-3 for collision resistance. HMAC for authenticated message integrity. Hash chains for one-time passwords (HOTP, TOTP). Merkle trees for efficient proof of inclusion. Content-addressable storage using cryptographic hashes.

### Side-Channel Attack Mitigation

**Timing Attacks**

Constant-time implementations for cryptographic operations. Blinding techniques for RSA. Cache-oblivious algorithms. Disable timing-based optimizations in security-critical code. Noise injection to mask timing variations. Hardware countermeasures (AES-NI constant-time).

**Power and EM Analysis**

Masking and hiding countermeasures in smartcards. Randomized execution ordering. Power analysis resistant designs. Faraday cages for sensitive computation. Trusted execution environments (TEE) with side-channel resistance.

**Speculative Execution Attacks**

Spectre/Meltdown mitigations (KPTI, retpoline). Speculation barriers in JIT compilers. Microarchitectural data sampling defenses. Process isolation and sandboxing. Firmware updates for hardware mitigations.

**Related Topics**

Public key infrastructure (PKI), zero-trust architecture, homomorphic encryption, secure enclaves (SGX, TrustZone), access control models (RBAC, ABAC), security protocols (Kerberos, OAuth 2.0)

---

