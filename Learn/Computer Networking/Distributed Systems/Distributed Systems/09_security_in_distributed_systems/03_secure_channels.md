## Secure Channels


### Cryptographic Primitives Foundation

**Symmetric Encryption:**

- AES-GCM (Galois/Counter Mode): authenticated encryption with associated data (AEAD), 128/256-bit keys
- ChaCha20-Poly1305: AEAD cipher optimized for software implementations, constant-time execution
- Block cipher modes: CBC deprecated (padding oracle vulnerabilities), CTR requires unique nonce per message
- Key derivation: HKDF (HMAC-based KDF) derives session keys from master secret

**Asymmetric Encryption:**

- RSA: 2048-bit minimum, 4096-bit recommended, OAEP padding for encryption
- Elliptic Curve Cryptography: P-256, P-384 curves (NIST), Curve25519 (EdDSA signatures, X25519 key exchange)
- Post-quantum considerations: NIST standardization of lattice-based and hash-based algorithms (ML-KEM, ML-DSA)

**Message Authentication Codes (MAC):**

- HMAC-SHA256/SHA384: keyed hash for message integrity
- Poly1305: MAC paired with ChaCha20 for AEAD construction
- Encrypt-then-MAC composition prevents padding oracle and other attacks

**Digital Signatures:**

- RSA-PSS: probabilistic signature scheme with 2048-bit minimum key size
- ECDSA: elliptic curve signatures with domain parameter validation
- EdDSA (Ed25519): deterministic signatures, constant-time, 128-bit security level
- Signature verification before processing prevents certain denial-of-service attacks

**Key Exchange Protocols:**

- Diffie-Hellman (DH): discrete logarithm problem, 2048-bit modulus minimum
- Elliptic Curve Diffie-Hellman (ECDH): smaller keys, equivalent security
- Ephemeral variants (DHE, ECDHE): forward secrecy through per-session key pairs
- Pre-shared keys (PSK): symmetric credential distribution, no public key operations

---

### TLS/SSL Protocol Stack

**TLS 1.3 Architecture:**

- Handshake protocol: authentication and key establishment
- Record protocol: confidentiality and integrity for application data
- Alert protocol: error signaling and connection termination
- Removed: RSA key transport, static DH, CBC mode ciphers, renegotiation, compression

**Handshake Flow (1-RTT):**

1. ClientHello: supported cipher suites, key share (ECDHE public key), extensions
2. ServerHello: selected cipher suite, key share, certificate, signature
3. Key derivation: HKDF generates handshake traffic keys from ECDHE shared secret
4. Encrypted handshake messages: certificate verification, Finished MAC
5. Application data encrypted with derived traffic keys

**0-RTT Resumption:**

- Client sends encrypted early data using PSK from previous session
- Reduces latency for repeat connections
- Replay protection: application-layer idempotency required, no guarantee of ordering
- Forward secrecy weaker than 1-RTT (relies on PSK secrecy)

**Cipher Suite Selection:**

- Modern suite: TLS_AES_256_GCM_SHA384 (AES-256-GCM with SHA-384 PRF)
- Alternative: TLS_CHACHA20_POLY1305_SHA256 (software-optimized)
- Negotiation: client preference vs server preference configuration trade-offs
- Deprecated: RC4, 3DES, export-grade ciphers, anonymous DH

**Certificate Validation:**

- X.509 certificate chain verification to trusted root CA
- Certificate Transparency logs for public CA issuance auditing
- OCSP stapling: server provides revocation status, reduces client latency
- CRL distribution points: fallback revocation checking mechanism
- Certificate pinning: application hardcodes expected certificate or public key hash

**Extensions:**

- SNI (Server Name Indication): virtual hosting, encrypted SNI (ESNI) for privacy
- ALPN (Application-Layer Protocol Negotiation): HTTP/2, gRPC selection
- Signed Certificate Timestamps: Certificate Transparency proof
- Supported groups: curve negotiation (X25519, secp256r1)
- Session tickets: stateless resumption via encrypted ticket from server

---

### Mutual TLS (mTLS)

Both client and server authenticate via certificates. Establishes bidirectional trust.

**Authentication Flow:**

1. Server requests client certificate during TLS handshake
2. Client sends certificate chain signed by trusted CA
3. Server validates client certificate against allowed CA roots
4. Client identity extracted from certificate subject or SAN (Subject Alternative Name)

**Certificate Management:**

- Short-lived certificates (hours to days) reduce revocation complexity
- Automated issuance and rotation via ACME protocol or internal PKI
- SPIFFE (Secure Production Identity Framework For Everyone): workload identity standard
- X.509 SVID (SPIFFE Verifiable Identity Document): certificate-based workload identity

**Service Mesh Integration:**

- Sidecar proxies (Envoy, Linkerd) terminate mTLS transparently
- Control plane (Istio, Consul) distributes certificates to workloads
- Automatic certificate rotation without application restarts
- Policy enforcement at proxy layer (authorization after authentication)

**Client Certificate Storage:**

- Hardware security modules (HSM) for high-value keys
- TPM (Trusted Platform Module) for device-bound certificates
- Keychain/credential managers for user certificates
- Kubernetes secrets or external secret stores (Vault) for service certificates

**Authorization Models:**

- Certificate subject DN matching against access control lists
- SAN-based identity mapping to roles or permissions
- SPIFFE ID authorization policies (regex matching on workload identifiers)
- Attribute-based access control (ABAC) from certificate extensions

---

### Noise Protocol Framework

Modern cryptographic protocol framework for building secure channels. Underlying foundation for WireGuard, Lightning Network.

**Core Patterns:**

- Handshake patterns define message flow and authentication properties
- Notation: `XX`, `IK`, `KK` patterns specify key transmission and authentication timing
- One-way patterns for unidirectional authentication
- Interactive patterns for mutual authentication with various forward secrecy properties

**Handshake Pattern Examples:**

**NN (No authentication):**

- Anonymous key exchange only
- Forward secrecy but no identity verification
- Vulnerable to active man-in-the-middle

**XX (Mutual authentication, ephemeral keys):**

- Both parties transmit static public keys during handshake
- Full forward secrecy and mutual authentication
- 1.5 RTT handshake

**IK (Initiator known to responder):**

- Responder has initiator's static public key pre-configured
- 1-RTT handshake (responder authenticates initiator immediately)
- Initiator authenticates responder after first response

**KK (Both parties known):**

- Both static public keys pre-shared
- 0-RTT possible (initiator sends encrypted data immediately)
- No identity hiding, full authentication

**Protocol Composition:**

- Handshake phase establishes shared secrets
- Transport phase: symmetric encryption with derived keys
- Rekeying: periodic key rotation via additional DH exchange

**Security Properties:**

- Forward secrecy: compromise of long-term keys doesn't decrypt past sessions
- Identity hiding: patterns like `XX` encrypt identity transmission
- Resistance to replay: handshake hash includes all prior messages
- Key confirmation: implicit via successful decryption, explicit via MAC

**Implementation Considerations:**

- Minimal specification: ~5000 words vs TLS 1.3 ~100 pages
- Fewer cipher suite combinations (single mandatory: Curve25519, ChaCha20-Poly1305, SHA256)
- No algorithm negotiation: fixed primitives reduce attack surface
- Stateless responder patterns for denial-of-service resistance

---

### WireGuard VPN Protocol

Noise-based secure tunnel protocol for VPN and secure channel construction.

**Architecture:**

- Cryptokey routing: IP addresses bound to public keys
- Stateless after handshake: minimal memory per peer
- Silent when idle: no keepalive traffic by default

**Handshake (Noise IK variant):**

1. Initiator sends ephemeral public key encrypted to responder's static key
2. Responder replies with own ephemeral key and session keys
3. 1-RTT handshake, responder authenticates initiator immediately
4. Transport data encrypted with derived session keys

**Key Rotation:**

- Rekey every 2 minutes or 2^64 packets (whichever first)
- Prevents nonce reuse and limits cryptanalysis exposure
- Seamless rotation: new handshake parallel to existing session

**DoS Mitigation:**

- Cookie reply mechanism for handshake initiation floods
- Responder stateless until handshake validation
- Source IP validation via cookie prevents amplification
- Under load reply mechanism activates dynamically

**Performance Characteristics:**

- In-kernel implementation achieves line-rate throughput (10+ Gbps)
- Minimal per-packet overhead (32 bytes)
- Constant-time operations prevent timing side channels
- Lower CPU usage than OpenVPN (kernel vs userspace)

---

### Channel Bindings

Cryptographic binding between application-layer authentication and secure channel prevents certain man-in-the-middle attacks.

**Attack Scenario Without Binding:**

1. Client establishes TLS to attacker proxy
2. Proxy establishes separate TLS to legitimate server
3. Client authenticates to proxy (e.g., via HTTP Digest)
4. Proxy forwards authentication to server
5. Server associates authentication with proxy's TLS session

**RFC 5929 Channel Bindings:**

- `tls-unique`: Finished message from TLS handshake
- `tls-server-end-point`: hash of server certificate
- `tls-exporter`: exported keying material via TLS exporter

**Application Integration:**

- Kerberos GSS-API: channel binding to TLS prevents credential forwarding attacks
- SCRAM (Salted Challenge Response Authentication Mechanism): binds to TLS channel
- OAuth token binding: cryptographically binds token to TLS session
- HTTP authentication: include channel binding in signature or MAC

**Token Binding Protocol:**

- Client proves possession of private key bound to TLS connection
- Token Binding ID derived from public key
- Server associates tokens/cookies with Token Binding ID
- Token theft useless without corresponding private key

---

### Forward Secrecy and Key Rotation

**Forward Secrecy (Perfect Forward Secrecy):**

- Compromise of long-term keys doesn't compromise past session keys
- Requires ephemeral key exchange per session (DHE, ECDHE)
- Static RSA key transport lacks forward secrecy (removed in TLS 1.3)
- Long-term keys only used for authentication, not encryption

**Key Rotation Strategies:**

- Time-based: rekey every N minutes (e.g., WireGuard 2 minutes)
- Volume-based: rekey after N GB transferred prevents nonce exhaustion
- Event-based: rekey on suspected compromise or configuration change
- Proactive: rekey before cryptanalytic exposure limits

**Rekeying Mechanisms:**

- Full handshake: expensive but re-establishes all security properties
- Session resumption: cheaper but may not provide forward secrecy
- Key update messages: derive new keys from current key material (TLS 1.3 KeyUpdate)
- Background rekeying: establish new session parallel to active session, cutover atomically

**Nonce Management:**

- Counter-based nonces: must never repeat under same key
- Random nonces: birthday bound limits (~2^32 messages for 96-bit nonce)
- Implicit nonces: derived from sequence numbers, requires synchronization
- Rotation before exhaustion: GCM nonce reuse catastrophic (reveals authentication key)

---

### Side Channel Resistance

**Timing Attacks:**

- Constant-time implementations for cryptographic operations
- MAC verification: constant-time comparison prevents MAC forgery timing oracle
- RSA: CRT implementation timing leaks factor information
- Blinding techniques for RSA and other operations

**Cache Timing:**

- AES T-table implementations leak key bits via cache access patterns
- AES-NI hardware instructions eliminate cache timing
- ChaCha20 uses only addition, rotation, XOR (no table lookups)

**Padding Oracle Attacks:**

- CBC mode with PKCS#7 padding vulnerable (BEAST, Lucky 13)
- TLS 1.3 removes CBC mode entirely
- AEAD ciphers (GCM, Poly1305) have no padding
- Authenticated encryption prevents ciphertext manipulation

**Implementation Guidelines:**

- Use well-audited cryptographic libraries (libsodium, BoringSSL, OpenSSL 3.x)
- Enable compiler mitigations (stack canaries, ASLR, DEP)
- Validate inputs before cryptographic processing
- Zeroize sensitive memory after use

---

### Denial-of-Service Resistance

**Handshake Floods:**

- Client puzzles: computational proof-of-work before server processes handshake
- Cookie mechanisms: stateless responder verifies client IP before state allocation
- SYN cookies at TCP layer: stateless connection establishment
- Rate limiting per source IP or network prefix

**Amplification Attacks:**

- Response size < request size prevents reflection amplification
- WireGuard cookie reply: 60 bytes response to 148 bytes request
- DTLS: cookie exchange prevents UDP amplification

**Computational Asymmetry:**

- RSA signature verification faster than generation (public key operation cheap)
- ECDSA verification ~10x faster than signing
- Symmetric operations orders of magnitude faster than asymmetric
- Offload verification to clients where possible

**Resource Exhaustion:**

- Connection limits per client IP
- Handshake rate limiting (e.g., 100 handshakes/second per IP)
- State timeout: aggressively discard stale handshake state
- Proof-of-work dynamically adjusted based on load

---

### Hardware Acceleration and Offload

**AES-NI (Advanced Encryption Standard New Instructions):**

- x86 CPU instructions for AES operations
- 4-10x throughput improvement over software implementation
- Constant-time execution eliminates cache timing side channels
- Available in Intel since 2010, AMD since 2011

**Crypto Coprocessors:**

- Dedicated hardware for cryptographic operations (smart cards, HSMs)
- Offloads CPU for high-throughput workloads
- Key material never leaves secure boundary
- FIPS 140-2/3 certified modules for regulatory compliance

**SSL/TLS Offload:**

- Network interface cards (NICs) with crypto engines
- Offloads handshake and record encryption from CPU
- DPDK (Data Plane Development Kit) integration for kernel bypass
- Achieves 100+ Gbps encrypted throughput

**Hardware Security Modules (HSMs):**

- Tamper-resistant device for key generation and storage
- Private key operations performed within HSM
- Network-attached HSMs for centralized key management
- PKCS#11 interface for application integration

**Trusted Platform Module (TPM):**

- Discrete chip on motherboard for cryptographic operations
- Measured boot: cryptographic attestation of boot process
- Sealed storage: keys accessible only to specific software configurations
- Device identity and attestation for zero-trust architectures

---

### Protocol-Specific Secure Channel Designs

**QUIC (Quick UDP Internet Connections):**

- UDP-based transport with integrated TLS 1.3
- 0-RTT connection establishment with replay protection
- Stream multiplexing without head-of-line blocking
- Connection migration survives IP address changes (connection ID)

**SSH (Secure Shell):**

- Key exchange: DH, ECDH with various hash functions
- Host key verification: trust-on-first-use (TOFU) model
- Authentication: password, public key, Kerberos, certificate
- Channel multiplexing: multiple sessions over single connection

**IPsec (Internet Protocol Security):**

- ESP (Encapsulating Security Payload): confidentiality and integrity
- AH (Authentication Header): integrity only, rarely used
- IKEv2 (Internet Key Exchange): automated key exchange and SA establishment
- Transport mode (end-to-end) vs tunnel mode (gateway-to-gateway)

**DTLS (Datagram TLS):**

- TLS adapted for unreliable datagram transport (UDP)
- Explicit sequence numbers and epoch for replay protection
- Retransmission and fragmentation for handshake messages
- Cookie exchange prevents amplification attacks

**SRTP (Secure Real-time Transport Protocol):**

- Encryption and authentication for RTP media streams
- Key derivation from master key via PRF
- Low overhead (10 bytes authentication tag)
- DTLS-SRTP for key establishment

---

### Service Mesh and Sidecar Proxy Architectures

**Envoy Proxy:**

- L7 proxy with TLS termination and origination
- Downstream client TLS and upstream backend TLS independent
- Certificate validation via SDS (Secret Discovery Service)
- Authorization via external authz service (Open Policy Agent)

**Istio Control Plane:**

- Pilot: service discovery and traffic routing
- Citadel: certificate authority for workload identities
- Galley: configuration validation and distribution
- Telemetry: distributed tracing and metrics collection

**Certificate Provisioning:**

- CSR (Certificate Signing Request) from workload to CA
- Short-lived certificates (1-24 hours) reduce revocation overhead
- Automated rotation: proxy requests new certificate before expiration
- Transparent to application: no code changes required

**Policy Enforcement:**

- Authentication: verify client certificate against trust domain
- Authorization: evaluate JWT claims or certificate attributes against policy
- Rate limiting: per-client or per-operation limits
- Audit logging: all access decisions logged for compliance

**Failure Modes:**

- Fail-open vs fail-closed during control plane unavailability
- Certificate expiration: fallback to permissive mode or deny all traffic
- Control plane partitioned from data plane: stale certificates and policies
- Observability: metrics on certificate expiration, handshake failures, authorization denials

---

### Quantum-Resistant Cryptography

**NIST Post-Quantum Standardization:**

- ML-KEM (Module-Lattice-Based Key Encapsulation Mechanism): Kyber selected for key exchange
- ML-DSA (Module-Lattice-Based Digital Signature Algorithm): Dilithium for signatures
- SLH-DSA (Stateless Hash-Based Digital Signature Algorithm): SPHINCS+ for stateless signatures
- Standardization finalized 2024, implementation deployment ongoing

**Hybrid Key Exchange:**

- Combine classical (ECDH) with post-quantum (Kyber) key exchange
- Security if either classical or PQ remains unbroken
- Deployed in Chrome, Firefox for TLS connections
- Increased handshake size (1-2 KB overhead)

**Migration Challenges:**

- Larger key sizes (Kyber public key ~1 KB, Dilithium signature ~2.5 KB)
- Increased computational cost (2-10x slower than ECC)
- Certificate size growth impacts handshake latency
- Algorithm agility required for future standardization changes

**Harvest Now, Decrypt Later:**

- Adversary records encrypted traffic for future decryption
- Quantum computer breaks classical crypto retroactively
- Forward secrecy with PQ algorithms mitigates risk
- High-value secrets require immediate PQ protection

---

### Observability and Monitoring

**TLS Metrics:**

- Handshake success/failure rates by cipher suite
- Certificate expiration monitoring (alert N days before expiration)
- Protocol version distribution (TLS 1.2 vs 1.3)
- Handshake latency (0-RTT vs 1-RTT)
- Certificate validation failures by reason (expired, revocation, untrusted CA)

**Distributed Tracing:**

- Trace context propagation across secure channels
- Handshake duration breakdown (DNS, TCP, TLS negotiation, certificate validation)
- Certificate chain traversal visualization
- mTLS authentication and authorization decision tracking

**Security Monitoring:**

- Downgrade attack detection (unexpected TLS 1.0/1.1 connections)
- Weak cipher suite alerts (CBC mode, export ciphers)
- Certificate pinning violations
- Anomalous connection patterns (sudden geography changes)

**Logging:**

- Connection establishment with selected cipher suite and protocol version
- Certificate subject and issuer for mTLS connections
- Handshake failures with specific error codes
- Rekeying events and certificate rotation

---

### Compliance and Regulatory Requirements

**PCI DSS (Payment Card Industry Data Security Standard):**

- TLS 1.2 minimum for cardholder data transmission
- Strong cryptography: 128-bit symmetric keys minimum
- Certificate validation required for external connections
- Key rotation policies and documentation

**FIPS 140-2/3 (Federal Information Processing Standards):**

- Validated cryptographic modules for US government
- Approved algorithms only (AES, SHA-2, RSA 2048+, ECDSA P-256+)
- Physical security requirements for HSMs (tamper detection, zeroization)
- Operational environment controls

**GDPR (General Data Protection Regulation):**

- Encryption of personal data in transit required
- Key management controls and access auditing
- Data breach notification within 72 hours
- Privacy-enhancing technologies (TLS 1.3 encrypted SNI)

**HIPAA (Health Insurance Portability and Accountability Act):**

- Encryption of electronic protected health information (ePHI)
- Access controls and authentication for data access
- Audit logs for all ePHI access
- Business associate agreements for third-party processors

---

### Attack Surface and Threat Modeling

**Man-in-the-Middle (MitM):**

- Certificate validation bypass vulnerabilities
- Rogue CA certificate installation on client
- DNS spoofing to redirect to attacker-controlled server
- Mitigations: certificate pinning, Certificate Transparency, DNSSEC

**Certificate Authority Compromise:**

- Fraudulent certificate issuance for legitimate domains
- Certificate Transparency: public append-only log of all CA issuances
- HPKP (HTTP Public Key Pinning): deprecated due to operational risk
- CAA (Certificate Authority Authorization) DNS records restrict issuance

**Protocol Downgrade:**

- Attacker forces client and server to negotiate weaker protocol version
- TLS_FALLBACK_SCSV: signals client's highest supported version
- ALPN: application-layer protocol negotiation resistant to downgrade
- Strict TLS version enforcement in configuration

**Session Hijacking:**

- Session ticket encryption key compromise allows decrypting all tickets
- Session resumption without re-authentication inherits original session security
- Token binding cryptographically binds session to TLS connection
- Short ticket lifetimes limit exposure window

**Replay Attacks:**

- 0-RTT data in TLS 1.3 replayable across connections
- Application must ensure idempotency for 0-RTT requests
- Anti-replay mechanisms: single-use tokens, timestamps with narrow acceptance window
- DTLS explicit sequence numbers prevent replays

---

### Performance Optimization Strategies

**Connection Reuse:**

- HTTP/2 multiplexing: multiple streams over single TLS connection
- Connection pooling: amortize handshake cost across requests
- Long-lived connections for high-frequency communication
- Graceful connection draining during rotation

**Handshake Optimization:**

- 0-RTT resumption: eliminate round trip for repeat connections
- Session ticket caching: avoid full handshake on reconnection
- OCSP stapling: server provides revocation status, reduces client latency
- TLS False Start: client sends application data before handshake completion (deprecated)

**Cipher Suite Selection:**

- AES-NI hardware acceleration: prefer AES-GCM on x86
- ChaCha20-Poly1305: better software performance on ARM and mobile
- Avoid RSA key transport: slower and no forward secrecy
- Prioritize ECDHE over DHE: smaller keys, faster computation

**Certificate Optimization:**

- Short certificate chains (2-3 certificates total)
- ECDSA certificates: smaller and faster verification than RSA
- Certificate compression: reduces handshake size
- Remove unused certificate extensions and policies

**Kernel Bypass and Userspace Networking:**

- DPDK: direct NIC access, reduces kernel overhead
- eBPF: programmable packet processing in kernel
- TLS offload to NIC: hardware accelerates encryption/decryption
- Kernel TLS (kTLS): symmetric operations in kernel, handshake in userspace

---

### Related Topics

- Public Key Infrastructure (PKI)
- Certificate authorities
- X.509 certificates
- Key management systems
- Cryptographic protocols
- Authentication mechanisms
- Authorization systems
- Network security
- VPN architectures
- Zero-trust networking
- Service mesh architectures
- Identity and access management
- Hardware security modules
- Trusted execution environments
- Side-channel attack mitigation
- Quantum-resistant cryptography
- Transport layer security
- Datagram transport layer security
- IPsec
- SSH protocol
- QUIC protocol
- Network encryption
- End-to-end encryption
- Perfect forward secrecy

---

