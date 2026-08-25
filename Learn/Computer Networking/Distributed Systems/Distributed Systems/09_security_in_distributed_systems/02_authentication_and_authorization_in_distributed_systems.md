## Authentication and Authorization in Distributed Systems


### Architectural Boundaries and Trust Domains

**Trust Boundaries:**

Distributed systems partition into trust domains separated by authentication and authorization enforcement points. Trust boundaries exist at:

- **Perimeter:** External clients to entry services (API gateways, load balancers)
- **Service-to-Service:** Between internal microservices or system components
- **Data Layer:** Between services and storage systems (databases, object stores, caches)
- **Cross-Region/Cross-Datacenter:** Between geographically distributed components
- **Administrative:** Between control plane and data plane operations

**Zero Trust Architecture:**

Every request authenticated and authorized regardless of origin. No implicit trust based on network location. Mutual TLS between all components. Identity verified at each hop. Minimizes blast radius of compromised credentials or components.

**Network Segmentation vs. Application-Level Security:**

Traditional perimeter security insufficient for distributed systems. Network segmentation provides defense-in-depth but cannot replace application-level authentication/authorization. Compromise of single service should not grant access to entire system. Application-level enforcement prevents lateral movement.

### Identity Representation and Propagation

**Identity Types:**

**Human Identity:** End users with credentials (passwords, biometrics, hardware tokens). Associated with accounts, roles, permissions. Requires session management and credential lifecycle.

**Service Identity:** Automated systems, microservices, batch jobs. Machine credentials (certificates, API keys, service accounts). No interactive login. Credentials often long-lived or automatically rotated.

**Device Identity:** IoT devices, mobile clients, edge nodes. Device-specific certificates or attestation. May bind to user identity or operate independently.

**Identity Formats:**

**Opaque Tokens:** Random identifiers with no embedded information. Require lookup in identity service to retrieve principal and attributes. Revocation immediate (invalidate in identity service). High lookup latency; mitigated by caching with TTL.

**Self-Contained Tokens (JWT):** JSON Web Tokens embed identity claims, expiration, signature. Stateless validation using public key cryptography. No identity service lookup required for verification. Revocation complex (requires denylist or short expiration). Token size increases with embedded claims (network overhead).

**SAML Assertions:** XML-based tokens for federated identity. Common in enterprise SSO. Larger payload than JWT. Support complex attribute statements and encryption.

**Macaroons:** Token format supporting delegation and attenuation (capability reduction). Bearer presents token with added contextual constraints (caveats). Verifier checks all caveats in chain. Enables decentralized authorization without central policy service.

**Identity Propagation Patterns:**

**Token Forwarding:** Original token propagated through entire request chain. All services validate same token. Simple but couples all services to same token format and identity provider. Token may contain excessive permissions for downstream services (violates least privilege).

**Token Exchange:** Service exchanges incoming token for new token with reduced scope when calling downstream service. OAuth token exchange or custom exchange protocol. Each hop obtains token appropriate for specific service interaction. Higher latency (token exchange roundtrip) but better isolation.

**Contextual Identity:** Original identity plus accumulated context (caller chain, tenant ID, trace ID) propagated in headers or metadata. Each service validates identity and makes authorization decision based on full context. Common in service mesh implementations.

**Impersonation/Delegation:** Service acts on behalf of original caller using delegation token. Downstream services see both service identity and delegated user identity. Audit trail preserves original caller. Requires explicit delegation grants.

### Authentication Mechanisms

**Password-Based Authentication:**

Weakest mechanism but most common for human users. Distributed systems challenges:

- **Credential Storage:** Passwords hashed with salt using slow hash function (bcrypt, scrypt, Argon2). Hash verification performed at authentication service, never at application services. Centralized credential store replicates across regions for availability. Replication lag may allow recently-changed password to fail authentication at some replicas.
    
- **Credential Transmission:** Always over TLS. Never logged or included in URLs. POST body or Authorization header. Rate limiting on authentication endpoints prevents brute force.
    
- **Multi-Factor Authentication (MFA):** Second factor (TOTP, SMS, push notification) required after password validation. MFA state (pending verification, challenge issued) stored in session or short-lived token. MFA device registration requires secure enrollment flow.
    

**Certificate-Based Authentication (mTLS):**

Client presents X.509 certificate during TLS handshake. Server validates certificate chain against trusted CA. Extracts identity from certificate subject or SAN field.

**Certificate Distribution:** Service identities receive certificates from internal CA (Vault, cert-manager, SPIFFE/SPIRE). Certificates short-lived (hours to days) and automatically rotated. Human identities use longer-lived certificates stored in hardware tokens or OS keystores.

**Certificate Revocation:** CRL (Certificate Revocation List) or OCSP (Online Certificate Status Protocol). CRL distribution has latency; revoked certificate may be accepted until CRL refreshed. OCSP requires real-time check during authentication (latency, availability dependency). Short certificate lifetimes reduce need for revocation infrastructure.

**Private Key Protection:** Private keys never leave issuing system. For services, keys stored in memory or hardware security modules (HSMs). For humans, keys stored in TPM, secure enclave, or hardware token.

**CA Hierarchy:** Root CA offline and air-gapped. Intermediate CAs issue service certificates. Compromise of intermediate CA requires revocation and reissuance but root CA remains secure. Cross-signing between CAs enables trust across organizational boundaries.

**API Keys and Secrets:**

Static credentials for service-to-service or client-to-service authentication. API key transmitted in HTTP header or query parameter (header preferred; query parameters logged).

**Key Management:** Keys stored encrypted at rest. Rotation requires generating new key, updating all consumers, deprecating old key after grace period. Key compromise requires emergency rotation across entire system.

**Scoping:** Each API key bound to specific permissions or resources. Separate keys per environment (production, staging). Key revocation immediate (checked against active key list on each request).

**Secret Distribution:** Secrets injected into services via environment variables, mounted volumes, or secret management APIs (AWS Secrets Manager, HashiCorp Vault). Never checked into source control. Secret injection at deployment time from secure store.

**OAuth 2.0 and OIDC:**

**Authorization Code Flow:** User redirects to authorization server. User authenticates and grants consent. Authorization server redirects back with authorization code. Client exchanges code for access token. Access token used to call resource servers. Code single-use, short-lived. Access token refresh via refresh token.

**Client Credentials Flow:** Service obtains token directly from authorization server using client ID and secret. No user interaction. Used for service-to-service authentication.

**Token Validation:** Resource server validates token signature (JWT) or calls introspection endpoint (opaque token). JWT validation requires obtaining public keys from authorization server's JWKS endpoint. Keys cached with periodic refresh. Introspection adds latency but provides real-time revocation.

**Token Scope:** Access token includes scope claims limiting permissions. Resource server enforces scope requirements. Principle of least privilege: request minimal scope necessary.

**Refresh Tokens:** Long-lived token used to obtain new access tokens without re-authentication. Stored securely, never transmitted to resource servers. Rotation on each use (refresh token replacement) limits compromise window.

**PKCE (Proof Key for Code Exchange):** Extension for public clients (mobile apps, SPAs). Prevents authorization code interception attacks. Client generates code verifier and challenge. Authorization server validates verifier on token exchange.

**Federated Identity (SAML, OIDC):**

Users authenticate with external identity provider (IdP). IdP issues assertion/token consumed by service provider (SP). User credentials never shared with SP.

**SAML Flow:** User accesses SP. SP redirects to IdP with SAML authentication request. User authenticates at IdP. IdP returns signed SAML assertion to SP. SP validates assertion and establishes session.

**OIDC Flow:** Similar to OAuth authorization code flow with additional ID token. ID token contains user identity claims. Used for authentication (OAuth designed for authorization).

**Trust Establishment:** SP trusts IdP by verifying assertion signature against IdP public key. IdP public key distributed via metadata URL or manual configuration. Trust relationships established administratively.

**Attribute Mapping:** IdP assertions contain user attributes. SP maps attributes to local identity and authorization model. Attribute differences across IdPs require normalization layer.

**Kerberos:**

Ticket-based authentication protocol. User obtains ticket-granting ticket (TGT) from Key Distribution Center (KDC) using password. TGT used to request service tickets for specific services. Service validates ticket using shared secret with KDC.

**Distributed KDC:** Master KDC replicates to slave KDCs for availability. Slave KDCs serve authentication requests but cannot modify principal database. Master failure prevents password changes but authentication continues.

**Cross-Realm Authentication:** Multiple Kerberos realms with trust relationships. User in realm A obtains ticket for service in realm B via cross-realm TGT. Requires transitive trust path or direct trust between realms.

**Ticket Caching:** Clients cache TGT and service tickets. Ticket lifetime (hours to days) balances security and usability. Expired tickets transparently renewed using cached TGT.

**SPIFFE/SPIRE:**

**SPIFFE (Secure Production Identity Framework For Everyone):** Standard for service identity in heterogeneous environments. Identities represented as SPIFFE IDs (URIs like `spiffe://trust-domain/workload-identifier`).

**SPIRE (SPIFFE Runtime Environment):** Implementation providing automatic identity issuance and rotation. Workloads attest identity to SPIRE agent using platform-specific mechanisms (Kubernetes service account, AWS IAM, Unix UID). Agent issues short-lived X.509 certificate (SVID - SPIFFE Verifiable Identity Document) for workload. Certificate automatically rotated before expiration.

**Attestation:** Process proving workload identity to SPIRE. Node attestation proves node identity to SPIRE server. Workload attestation proves workload identity to SPIRE agent on node. Attestation plugins vary by platform (cloud provider APIs, Kubernetes API, process metadata).

**Federation:** Multiple SPIRE deployments with cross-trust enable authentication across trust domains. SPIRE servers exchange trust bundles (CA certificates). Workloads in domain A authenticate to services in domain B using SVIDs.

### Authorization Models

**Role-Based Access Control (RBAC):**

Permissions assigned to roles. Users assigned to roles. User's effective permissions are union of all role permissions.

**Role Hierarchy:** Roles inherit permissions from parent roles. Reduces redundant permission assignments. Simplifies management but increases complexity of permission calculation.

**Role Explosion:** Fine-grained permissions require many roles. Large organizations may have hundreds to thousands of roles. Role assignment and review becomes operational burden.

**Distributed RBAC:** Centralized role definitions replicated to enforcement points. Services cache role-permission mappings. Cache invalidation on role changes may have propagation delay. Inconsistency window where different services enforce different role definitions.

**Attribute-Based Access Control (ABAC):**

Access decisions based on attributes of subject (user), resource, action, and environment. Policies expressed as rules evaluating attribute combinations.

**Subject Attributes:** User ID, department, clearance level, group memberships, authentication method.

**Resource Attributes:** Ownership, classification, location, creation time, tags.

**Environmental Attributes:** Time of day, originating IP, request path, geo-location.

**Policy Evaluation:** Centralized policy decision point (PDP) evaluates policies against attributes. Policy enforcement point (PEP) intercepts requests, collects attributes, queries PDP, enforces decision. Distributed evaluation caches policies at enforcement points but requires policy synchronization.

**Policy Distribution:** Policies stored in centralized repository. Enforcement points fetch policies on startup and periodically refresh. Push-based updates for critical policy changes. Policy versioning tracks which version enforced at each service.

**Attribute Sources:** Attributes from multiple systems (identity provider, resource metadata service, environmental context). Attribute retrieval latency impacts authorization latency. Caching with TTL trades freshness for performance.

**Relationship-Based Access Control (ReBAC):**

Authorization based on relationships between subjects and resources. Example: user can edit document if user is owner or document is shared with user.

**Graph Representation:** Resources and subjects as nodes. Relationships as edges. Authorization queries traverse graph. Example: "Can user U access resource R?" becomes graph reachability query.

**Implementation:** Graph database or specialized authorization service (Zanzibar-inspired systems like SpiceDB, Ory Keto). Relationship tuples stored as `(subject, relation, resource)`. Queries evaluate whether tuple exists or can be derived via transitive relationships.

**Namespace Isolation:** Relationships scoped to namespaces or tenants. Prevents cross-tenant relationship traversal. Each tenant's relationship graph isolated.

**Consistency:** Relationship updates must be consistent with resource operations. Adding "shared_with" relationship without corresponding sharing action creates inconsistency. Requires transactional update or eventual consistency with reconciliation.

**Google Zanzibar Architecture:**

Globally distributed authorization system. Relationship tuples (ACL entries) stored in replicated storage. Queries served from local replicas with consistency token (zookie) ensuring read-after-write consistency. Tuple writes replicated across all regions. Snapshot reads at specific timestamp enable consistent multi-object authorization checks.

**Capability-Based Security:**

Unforgeable tokens (capabilities) grant specific permissions. Possessing capability sufficient for access (bearer token). No central authorization check required.

**Token Structure:** Capability specifies resource, permitted operations, constraints (time bounds, usage limits), cryptographic signature or MAC.

**Delegation:** Capability holder creates derived capability with reduced permissions. Original capability signature validated, new signature added. Chain of delegation preserved in token.

**Revocation:** Difficult with bearer capabilities. Approaches include:

- Short expiration requiring frequent renewal
- Revocation list checked during enforcement
- Indirection through revocable handle

**Attenuation:** Process of creating capability with subset of original permissions. Macaroons support contextual attenuation by adding caveats. Verifier evaluates all caveats; access granted only if all satisfied.

**Policy as Code:**

Authorization policies expressed as code in dedicated language (Rego in Open Policy Agent, Cedar). Policies version-controlled, tested, deployed through CI/CD pipeline.

**OPA (Open Policy Agent):** General-purpose policy engine. Policies written in Rego. Services query OPA with input document (subject, resource, action, context). OPA evaluates policies and returns decision. Policies and data loaded into OPA instance via bundles or APIs. OPA runs as sidecar or centralized service.

**Cedar:** Amazon's authorization policy language. Strongly typed with schema for entities and actions. Supports policy validation and analysis. Policies evaluated locally or via centralized service.

**Policy Testing:** Unit tests verify individual policy rules. Integration tests verify policy interaction. Property-based testing generates random inputs to find edge cases. Policy simulation tests changes against historical access logs.

### Distributed Authorization Architecture

**Centralized Policy Decision Point (PDP):**

Single service evaluates all authorization decisions. Services send authorization requests to PDP with full context. PDP evaluates policies and returns permit/deny.

**Advantages:** Consistent policy enforcement. Simplified policy management. Audit trail centralized.

**Disadvantages:** Latency (network round trip per authorization check). Single point of failure (requires high availability). Scalability bottleneck under high query load. Network partition between service and PDP blocks all access.

**Mitigation:** PDP replicates across regions. Load balanced for horizontal scaling. Caching of common decisions at enforcement points with TTL. Fail-open vs fail-closed configuration balances security and availability.

**Distributed Policy Enforcement Points (PEP):**

Authorization logic embedded in each service or sidecar. Policies cached locally. Decision made without external service call.

**Policy Synchronization:** Services fetch policies from central repository on startup and periodically. Push notifications trigger immediate policy refresh. Policy version tracked; inconsistency detected if services enforce different versions.

**Data Freshness:** Authorization decisions use locally cached attribute data. User permission changes may not be immediately reflected at all services. Eventual consistency acceptable for many use cases; critical changes pushed immediately.

**Local Evaluation Advantages:** No network latency. No availability dependency on central authorization service. Higher throughput.

**Local Evaluation Disadvantages:** Inconsistent policy enforcement during synchronization lag. Increased memory footprint (policy and attribute caching). Complex cache invalidation logic.

**Hybrid Architecture:**

Critical or complex authorization decisions delegated to centralized PDP. Simple or latency-sensitive decisions evaluated locally. Local decision cache populated by PDP responses. Cache miss triggers PDP query; result cached for subsequent requests.

**Service Mesh Integration:**

Authorization policies enforced at service mesh proxy (Envoy, Linkerd). External authorization service (OPA, custom authz service) invoked by proxy via gRPC. Service receives request only if authorized. Service code simplified (no embedded authorization logic).

**Advantages:** Centralized enforcement regardless of service language. Policies updated without service redeployment. Consistent enforcement across heterogeneous services.

**Disadvantages:** Limited context available to proxy (HTTP headers, connection metadata). Complex authorization requiring business logic not possible at proxy layer. Latency overhead of external authorization call.

### Token Management and Lifecycle

**Token Issuance:**

Authentication service validates credentials and issues token. Token contains identity claims, expiration, permissions/scope. Signed with private key. Token format (JWT, opaque) determined by system requirements.

**Token Expiration:**

Short-lived access tokens (minutes to hours) limit compromise window. Long-lived refresh tokens (days to months) enable re-issuance without re-authentication. Sliding window expiration extends token lifetime on active use.

**Token Refresh:**

Client detects access token expiration (explicit expiration field or 401 response). Client presents refresh token to obtain new access token. Refresh token may be single-use (rotated on each refresh) or multi-use. Single-use rotation requires atomic replace operation.

**Token Revocation:**

**Revocation List:** Centralized list of revoked tokens. Enforcement points check list before accepting token. List distributed via push or pull. Propagation latency creates window where revoked token still accepted.

**Token Introspection:** Enforcement point queries authorization server to validate token. Server checks revocation status in real-time. Higher latency than local validation but immediate revocation.

**Short Expiration:** Reduce revocation need by minimizing token lifetime. Revoked token expires quickly naturally. Requires more frequent token refresh.

**Token Storage:**

**Client-Side:** Tokens stored in secure storage (OS keychain, secure enclave) for native apps. HttpOnly cookies for web apps (prevents XSS access). Local storage vulnerable to XSS. Session storage cleared on browser close.

**Server-Side Sessions:** Server maintains session state; issues opaque session ID to client. Session ID transmitted as cookie. Authorization state stored server-side, indexed by session ID. Session store replicated or shared (Redis, database) across servers for stateless load balancing.

**Token Binding:** Bind token to specific client (device, IP, browser fingerprint). Theft of token from one client unusable from different client. Requires client to prove possession of binding key during token presentation. Complicates legitimate multi-device scenarios.

### Session Management in Distributed Systems

**Session Storage:**

**Sticky Sessions:** Load balancer routes user requests to same server. Server maintains session state in local memory. Server failure loses sessions. Complicates rolling deployments and scaling.

**Shared Session Store:** Centralized session storage (Redis, Memcached) shared across servers. Any server can handle any request. Session store replicates for availability. Session data serialized/deserialized on each request (latency, serialization overhead).

**Client-Side Sessions:** Session state encoded in signed cookie (JWT-based session). Server stateless; validates cookie signature. Large session state increases cookie size (network overhead). Cookie tampering prevented by signature but client can read content (encrypt if sensitive).

**Session Replication:** Active sessions replicated across multiple servers. Gossip protocol or dedicated replication channel synchronizes state. Replication lag may cause session inconsistency if user requests routed to different servers. Complex implementation; often avoided in favor of shared session store.

**Session Expiration:**

**Idle Timeout:** Session expires after period of inactivity. Requires tracking last access time. Background process or lazy evaluation on access expires stale sessions.

**Absolute Timeout:** Session expires after fixed duration regardless of activity. Balances security (limits compromised session lifetime) and usability (requires re-authentication).

**Sliding Window:** Session expiration extended on each access. Effectively idle timeout that resets on activity. Requires updating expiration timestamp on each request (write overhead in shared session store).

**Session Invalidation:**

**Logout:** Explicit session termination. Server removes session from store. Client discards token/session ID. Distributed session stores require invalidation to propagate to all nodes.

**Forced Invalidation:** Administrator or security system terminates sessions. Invalidate all sessions for user on password change or account compromise. Requires enumerating all sessions for user (session store indexed by user ID).

**Concurrent Session Limits:** Enforce maximum concurrent sessions per user. New session creation invalidates oldest session. Prevents credential sharing but may frustrate legitimate multi-device usage.

### Credential Rotation and Key Management

**Automated Rotation:**

Credentials and cryptographic keys rotated periodically. Services obtain new credentials before expiration. Overlapping validity period allows gradual transition. Old credentials deprecated after all consumers updated.

**Rotation Triggers:**

- **Time-Based:** Fixed rotation schedule (daily, weekly). Balances security and operational overhead.
- **Event-Based:** Rotation triggered by suspicious activity, potential compromise, or employee departure.
- **Usage-Based:** Rotate after number of uses or data processed (less common for authentication credentials).

**Rotation Coordination:**

**Centralized Rotation:** Secret management service rotates credentials and notifies consumers. Consumers fetch new credentials from service. Service ensures all consumers updated before deprecating old credentials.

**Decentralized Rotation:** Each service independently rotates own credentials. Publishes new public keys to discovery service. Consumers fetch updated keys on demand or periodic refresh.

**Zero-Downtime Rotation:** Service accepts both old and new credentials during transition period. Consumers gradually migrate to new credentials. Old credentials deprecated after grace period. Requires tracking multiple active credential versions.

**Key Distribution:**

**Key Management Service (KMS):** Centralized service stores and distributes cryptographic keys. Keys encrypted at rest with master key. Services authenticate to KMS and retrieve keys. KMS replicates across regions for availability.

**Envelope Encryption:** Data encrypted with data encryption key (DEK). DEK encrypted with key encryption key (KEK) stored in KMS. Encrypted DEK stored with data. Decryption requires fetching KEK from KMS, decrypting DEK, decrypting data. Reduces KMS load (only KEK operations) and enables key rotation without re-encrypting all data.

**Hardware Security Modules (HSMs):** Tamper-resistant devices for key storage and cryptographic operations. Private keys never leave HSM. Services send data to HSM for signing/decryption. HSM clusters provide high availability. High latency compared to software cryptography; used for critical keys (CA signing keys, root keys).

### Multi-Tenancy and Isolation

**Tenant Identification:**

**Subdomain-Based:** Each tenant assigned subdomain (`tenant1.example.com`). Tenant ID extracted from request hostname. Simple but requires wildcard certificates and DNS management.

**Path-Based:** Tenant ID in URL path (`example.com/tenant1/resource`). Single domain but complicates routing and URL structure.

**Header-Based:** Tenant ID in custom HTTP header or claim in authentication token. Transparent to URL structure but requires consistent header propagation.

**Data Isolation:**

**Physical Isolation:** Separate database or storage instance per tenant. Strongest isolation but highest overhead. Simplifies compliance and data residency requirements.

**Logical Isolation:** Shared database with tenant ID column in all tables. Row-level security or application-enforced filtering. Lower overhead but risk of cross-tenant data leakage via bugs.

**Hybrid Isolation:** Separate schemas or databases for large tenants. Shared database for small tenants. Balances isolation and efficiency.

**Authorization Isolation:**

All authorization policies scoped to tenant. User from tenant A cannot access resources in tenant B regardless of permissions. Tenant boundary enforced before permission checks. Tenant context propagated through all internal service calls.

**Administrative Boundaries:**

Separate administrative domains per tenant. Tenant administrators manage users, roles, policies within tenant. Platform administrators manage tenancy infrastructure and cross-tenant concerns. Privilege escalation mitigated by tenant boundary enforcement.

### Cross-Service Authorization Patterns

**Service-to-Service Authentication:**

Each service has unique identity (certificate, API key, service account). Calling service includes identity in request. Called service validates identity before processing.

**Mutual TLS (mTLS):** Both client and server present certificates. Identity established during TLS handshake. No additional authentication mechanism required. Service mesh (Istio, Linkerd) automates mTLS between services.

**Service Mesh Authorization:**

Policies specify which services can call which other services. Service mesh proxy enforces policies at network layer. Example: frontend service allowed to call backend service, but backend cannot call frontend (unidirectional trust).

**Caller Identity Propagation:**

Original user identity propagated through service call chain. Each service receives both immediate caller identity (service) and original user identity. Authorization decisions consider both (e.g., service X allowed to call service Y only when acting on behalf of user with permission P).

**Implementation:** User identity in JWT or custom header. Each service validates caller service identity separately. Authorization policy evaluates combination of service and user identity.

**Delegation Tokens:**

Service obtains delegation token granting limited permissions on behalf of user. Delegation token presented to downstream service. Downstream service validates delegation token and enforces delegated permissions. Prevents service from exceeding delegated permissions even if service identity has broader permissions.

**Token Exchange Protocol:** Service exchanges incoming user token for delegation token scoped to downstream service and reduced permissions. OAuth token exchange standard (RFC 8693) or custom protocol.

### Access Control for Data at Rest

**Database-Level Authorization:**

Database enforces access control via user accounts and grants. Each service connects with dedicated database user. Database grants limit tables and operations accessible to each user. Row-level security policies filter data based on user attributes.

**Challenges in Distributed Systems:** Services share database or access multiple databases. Database users do not map cleanly to end users. Requires propagating user context to database (connection pooling per user infeasible; application sets session context variable).

**Application-Level Authorization:**

Application code enforces access control before database queries. Database permissions allow application service user broad access. Application filters queries based on user permissions. Requires consistent enforcement across all code paths. Vulnerable to authorization bypass bugs.

**Encryption-Based Access Control:**

Data encrypted with keys accessible only to authorized principals. Encryption key management service enforces access control. Principal requests decryption key; KMS evaluates authorization policy before returning key. Decrypted data protected by application-level access control.

**Advantages:** Strong isolation; unauthorized access returns ciphertext. Decouples data storage from authorization (storage system untrusted).

**Disadvantages:** Cannot perform queries on encrypted data (unless using specialized encryption like searchable encryption, homomorphic encryption). Key management complexity. Key compromise exposes all data encrypted with key.

### Audit Logging and Compliance

**Audit Event Structure:**

- **Who:** Subject identity (user ID, service account)
- **What:** Action performed (operation, API endpoint)
- **Where:** Resource accessed (resource ID, resource type)
- **When:** Timestamp (UTC, high precision)
- **How:** Authentication method, source IP, geo-location
- **Outcome:** Success, failure, error code
- **Context:** Request trace ID, session ID, tenant ID

**Distributed Logging:**

Each service generates audit logs locally. Logs shipped to centralized aggregation system (Elasticsearch, Splunk, BigQuery). Structured logging format (JSON) enables parsing and querying. Correlation via trace ID links audit events across services.

**Tamper-Evident Logging:**

Append-only logs prevent retroactive modification. Cryptographic hashing links log entries (Merkle tree). Periodic signing of log root hash by trusted timestamping authority. Detects unauthorized log modification or deletion.

**Log Retention:**

Regulatory requirements dictate retention period (years). Separate hot storage (recent logs, fast query) and cold storage (archival, infrequent access). Automated retention policy archives or deletes expired logs.

**Audit Log Protection:**

Logs contain sensitive information (user identities, accessed resources). Access control on logs stricter than operational logs. Encryption at rest. Separate auditor role with read-only log access.

**Compliance Reporting:**

Automated queries extract compliance-relevant events. Failed authentication attempts, privilege escalation, data access by admins, policy changes. Alerts on anomalous patterns (unusual access volume, off-hours activity, geographic anomalies).

### Privilege Escalation and Break-Glass Mechanisms

**Least Privilege:**

Principals granted minimal permissions necessary for function. Default deny; explicit grants required. Regular permission review identifies over-privileged accounts. Temporary privilege elevation for specific tasks.

**Just-In-Time (JIT) Access:**

Elevated privileges granted on-demand for limited duration. User requests access with justification. Approval workflow (manual or automated). Temporary permission expires automatically. Audit log records elevation and usage.

**Break-Glass Access:**

Emergency access mechanism for critical situations. High-privilege account protected by strong authentication and monitoring. Usage triggers alerts and immediate audit. Requires post-incident justification and review.

**Implementation:** Separate emergency credentials stored securely (physical safe, cryptographic split). Multi-person authorization (requires N of M administrators). Time-limited with automatic revocation.

**Privilege Elevation Workflows:**

User submits request for elevated permissions. Approval by manager or security team based on policy. Elevated permissions provisioned automatically upon approval. Permissions revoked at expiration or explicit termination. Audit trail records approval chain and usage.

### Rate Limiting and Abuse Prevention

**Authentication Rate Limiting:**

Limit failed authentication attempts per user account or source IP. Prevents brute force password guessing. Progressive delays or CAPTCHA after threshold. Account lockout after repeated failures (requires unlock mechanism).

**Authorization Rate Limiting:**

Limit authorization queries per identity or API key. Prevents authorization service overload. Distributed rate limiting using shared state (Redis) or approximate algorithms (token bucket per node).

**DDoS Mitigation:**

Authentication and authorization endpoints vulnerable to denial-of-service. Rate limiting at edge (CDN, API gateway) before requests reach authentication service. CAPTCHA challenges for suspicious traffic. Geoblocking for regions with no legitimate traffic.

**Credential Stuffing Defense:**

Attackers use leaked credentials from other services. Detect via unusual login patterns (geolocation, user agent, velocity). Multi-factor authentication prevents credential stuffing success. Compromised credential detection service compares against known breached credentials.

### Security Considerations and Attack Vectors

**Token Theft:**

**XSS (Cross-Site Scripting):** Attacker injects JavaScript to steal tokens from browser storage. Mitigation: HttpOnly cookies (inaccessible to JavaScript), Content Security Policy (CSP), input sanitization.

**Man-in-the-Middle:** Attacker intercepts token during transmission. Mitigation: TLS everywhere, certificate pinning for mobile apps, HSTS headers.

**Token Replay:** Stolen token reused by attacker. Mitigation: Short expiration, token binding to client identity, anomaly detection (geolocation, device fingerprint).

**Session Fixation:**

Attacker tricks user into using attacker-controlled session ID. User authenticates with fixed session ID. Attacker uses same session ID to impersonate user. Mitigation: Regenerate session ID on authentication, strict session ID validation.

**Privilege Escalation:**

**Vertical Escalation:** Lower-privileged user gains higher privileges. Caused by authorization bypass bugs, improper permission checks, parameter tampering. Mitigation: Defense-in-depth authorization checks, principle of least privilege, regular security audits.

**Horizontal Escalation:** User accesses resources belonging to different user at same privilege level. Caused by missing resource ownership checks, insecure direct object references. Mitigation: Authorization checks validate both permission and ownership.

**Confused Deputy:**

Service with elevated privileges tricked into performing action on behalf of attacker. Service validates user identity but not whether user authorized to request service to perform action. Mitigation: Delegation tokens with explicit grants, ambient authority avoidance.

**Time-of-Check-Time-of-Use (TOCTOU):**

Authorization check passes but state changes before operation executes. Attacker exploits race condition. More severe in distributed systems with eventual consistency. Mitigation: Atomic check-and-execute operations, optimistic concurrency control, distributed locks.

**Cryptographic Attacks:**

**Weak Algorithms:** MD5, SHA-1 for signatures considered broken. Mitigation: Use SHA-256 or stronger, regularly update cryptographic standards.

**Key Exposure:** Private keys stored insecurely or logged. Mitigation: HSMs, encrypted key storage, key access auditing, never log sensitive material.

**Timing Attacks:** Variable response time leaks information about credentials. Mitigation: Constant-time comparison for secrets, rate limiting masks timing differences.

### Operational Characteristics

**Authentication Latency:**

**Password-Based:** Hash verification (bcrypt) 50-200ms per attempt. Parallelizable across multiple CPU cores. Rate limiting acceptable given slow hashing.

**Certificate-Based:** TLS handshake 1-2 RTTs. Certificate chain validation includes signature verification and revocation check (OCSP adds latency). Caching of intermediate certificates and OCSP responses reduces overhead.

**Token-Based:** JWT signature verification <1ms (local public key). Opaque token introspection 10-50ms (network round trip to authorization server). Caching of introspection results amortizes cost.

**Authorization Latency:**

**Local Policy Evaluation:** <1ms for simple RBAC. 1-10ms for complex ABAC with many rules. OPA policy evaluation typically single-digit milliseconds.

**Remote Policy Decision:** 10-100ms depending on network latency and PDP load. Caching reduces to local evaluation latency for cache hits.

**Relationship Traversal:** Graph queries (ReBAC) 10-100ms depending on graph size and traversal depth. Indexed efficiently in specialized databases (Zanzibar-style systems).

**High Availability Requirements:**

Authentication and authorization failures block all access. Requires higher availability than typical application services. Multi-region deployment with automatic failover. Degraded mode allows cached or cached-and-limited authorization decisions during outage.

**Scalability Bottlenecks:**

Centralized authentication service scales horizontally (stateless validation). Centralized authorization service requires distributed caching or regional deployment. Token introspection service load proportional to request rate; JWT self-validation avoids bottleneck. Session stores (Redis) require sharding or replication for high throughput.

### Related Architectural Patterns and Systems

- OAuth 2.0 and OpenID Connect (OIDC)
- SAML and federated identity protocols
- Kerberos and ticket-based authentication
- Public Key Infrastructure (PKI) and certificate management
- JSON Web Tokens (JWT) and token-based authentication
- Multi-factor authentication (MFA) systems
- Role-Based Access Control (RBAC) implementations
- Attribute-Based Access Control (ABAC) frameworks
- Policy as Code (Open Policy Agent, Cedar)
- Google Zanzibar and relationship-based authorization
- SPIFFE/SPIRE workload identity framework
- Service mesh security (Istio, Linkerd)
- Zero Trust Architecture principles
- Secret management systems (Vault, AWS Secrets Manager)
- Hardware Security Modules (HSMs)
- Identity and Access Management (IAM) systems
- Single Sign-On (SSO) protocols
- API gateway authentication patterns
- Macaroons and capability-based security

---

