## Access Control Mechanisms


### Discretionary Access Control (DAC)

Resource owners determine access permissions for their objects. Subjects granted permissions at owner's discretion without centralized enforcement of organizational policy.

**Access Control Lists (ACLs)**: Each object maintains list of subjects and their permitted operations. Entry format: (subject_id, permission_set). Permission checks traverse ACL to verify subject authorization. ACL size grows linearly with number of authorized subjects.

**Capability Lists**: Each subject maintains list of objects and granted permissions. Capability format: (object_id, permission_set, cryptographic_token). Capability itself serves as unforgeable proof of authorization. Requires secure capability storage and transmission to prevent tampering or unauthorized duplication.

**Unix File Permissions**: Three permission classes (owner, group, others) with read/write/execute bits. SetUID/SetGID bits enable privilege elevation. Coarse-grained model insufficient for complex authorization requirements. No support for negative permissions or conditional access.

**ACL Propagation**: New object inherits ACL from parent directory or explicit default ACL. Modifications to parent ACL do not automatically propagate to children. Requires explicit recursive ACL update or dynamic inheritance evaluation at access time.

**Distributed ACL Consistency**: ACLs replicated across storage nodes. Update propagation delays create window where different replicas enforce different policies. Requires causal consistency or stronger guarantees to prevent authorization bypass through stale replica access. Versioned ACLs with monotonic version numbers enable inconsistency detection.

**Limitations**: No centralized policy enforcement. Vulnerable to Trojan horse attacks where malicious program executing under subject's privileges copies sensitive data to publicly accessible location. ACL administration overhead scales poorly in large deployments. No support for separation of duty or Chinese Wall policies.

### Mandatory Access Control (MAC)

System-wide security policy enforced by operating system or security kernel. Subjects and objects assigned security labels. Access decisions based on label relationships independent of subject identity.

**Bell-LaPadula Model**: Confidentiality-focused model preventing information flow from high-security to low-security levels. Simple Security Property: subject at level L cannot read object at level higher than L (no read-up). Star Property: subject at level L cannot write object at level lower than L (no write-down). Prevents covert channels through write-down followed by read-up.

**Biba Model**: Integrity-focused model preventing corruption from low-integrity to high-integrity data. Simple Integrity Axiom: subject at integrity level L cannot read object at level lower than L (no read-down). Star Integrity Axiom: subject at level L cannot write object at level higher than L (no write-up). Dual of Bell-LaPadula, enforces data integrity rather than confidentiality.

**Multi-Level Security (MLS)**: Security labels consist of hierarchical classification level (unclassified, confidential, secret, top secret) and non-hierarchical category set (compartments). Subject dominates object if subject's level ≥ object's level AND subject's categories ⊇ object's categories. Access granted only if dominance relationship satisfied and operation allowed by policy.

**Trusted Computing Base (TCB)**: Security kernel implementing reference monitor mediating all access requests. Must be tamper-proof, always invoked, and small enough for formal verification. Kernel enforces security labels and policy rules. Subjects cannot bypass or manipulate security mechanisms.

**Labeled Networking**: Security labels transmitted with network packets. Receiving system validates sender's label and enforces MLS policy on received data. Prevents unauthorized information flow across network boundaries. Requires trusted network infrastructure or cryptographic binding of labels to packets.

**Distributed MLS Challenges**: Maintaining label consistency across replicated data. Cross-domain information sharing requires trusted guards performing controlled sanitization and downgrading. Covert channels through storage allocation, timing, or resource consumption leak information across security boundaries. Polyinstantiation creates multiple versions of same object at different security levels to prevent inference attacks.

### Role-Based Access Control (RBAC)

Permissions assigned to roles, subjects assigned to roles. Access decisions based on active roles rather than subject identity. Simplifies permission management through indirection.

**Core RBAC**: Three entities: subjects (users), roles, permissions. Many-to-many subject-role assignment and role-permission assignment relations. Subject activates subset of assigned roles within session. Permission check verifies active role possesses required permission.

**Hierarchical RBAC**: Roles organized in partial order. Senior roles inherit permissions from junior roles. Permission inheritance reduces redundant assignment specification. Role hierarchy supports organizational structure modeling. Inheritance depth impacts permission resolution performance.

**Constrained RBAC**: Static Separation of Duty (SSD): user cannot be assigned conflicting roles simultaneously. Dynamic Separation of Duty (DSD): user cannot activate conflicting roles in same session. Cardinality constraints limit maximum users per role or roles per user. Prevents privilege escalation through role combination.

**Role Activation**: Session-based role activation allows subject to temporarily elevate privileges for specific operations. Least privilege principle: activate minimum roles necessary for task. Role activation audit trail enables accountability and forensics.

**Administrative RBAC**: Separates security administration into domains. Administrative roles manage role assignments within jurisdiction. Prevents single administrator controlling all permissions. Administrative scope constraints limit authority boundaries.

**Distributed RBAC**: Role definitions and assignments distributed across authorization servers. Cross-domain role mapping translates roles between administrative domains. Federated role hierarchy requires trust relationships and policy negotiation. Role certificate chaining proves transitive role membership.

**Temporal Constraints**: Time-bounded role assignments or activations. Periodic role membership renewal forces access review. Expiration prevents zombie permissions from former employees or terminated projects. Emergency roles activated only during incident response.

**Implementation**: Centralized policy decision point (PDP) evaluates role-permission associations. Policy enforcement points (PEPs) intercept access requests and query PDP. Policy information points (PIPs) provide subject role memberships and resource attributes. Policy administration point (PAP) manages role definitions and assignments.

### Attribute-Based Access Control (ABAC)

Access decisions based on attributes of subject, resource, environment, and requested action. Policies expressed as boolean functions over attribute values. Enables fine-grained, context-aware authorization.

**Attributes**: Subject attributes: identity, role, department, clearance level, group membership. Resource attributes: owner, classification, creation date, data type. Environment attributes: time, location, security posture, threat level. Action attributes: operation type, data volume, audit trail.

**Policy Language**: XACML (eXtensible Access Control Markup Language): XML-based policy specification. Policies contain target (applicability conditions) and rule set. Rules combine via combining algorithms (deny-overrides, permit-overrides, first-applicable). PolicySets enable hierarchical policy organization and delegation.

**Policy Evaluation**: Attribute retrieval from multiple attribute sources (LDAP, database, context service). Attribute aggregation and normalization. Policy matching identifies applicable policies and rules. Rule evaluation produces permit/deny/not-applicable/indeterminate. Combining algorithm resolves conflicting decisions.

**Attribute Certification**: Cryptographically signed attribute assertions prevent tampering. Attribute authority issues attribute certificates with validity period. Revocation requires certificate status checking (OCSP, CRL). Attribute caching trades freshness for performance, bounded by certificate validity period.

**Distributed Attribute Retrieval**: Attributes sourced from multiple administrative domains. Cross-domain attribute federation requires trust relationships and schema mapping. Attribute push (bundled with request) versus pull (retrieved by PDP). Pull model increases latency, push model increases message size and requires attribute authentication.

**Policy Conflicts**: Multiple policies may produce contradictory decisions. Combining algorithms provide deterministic conflict resolution. Deny-overrides prioritizes security. Permit-overrides prioritizes availability. Policy priority ordering or delegation depth determines precedence. Conflict detection during policy authoring prevents runtime ambiguity.

**Obligations and Advice**: Obligations specify mandatory actions upon permit/deny decision (logging, notification, data sanitization). Advice suggests optional actions. Obligations enforced by PEP before granting access or after denying. Obligation failure causes access denial even with permit decision.

**Performance Optimization**: Policy indexing by attribute values enables efficient policy matching. Attribute caching reduces retrieval latency and external dependency load. Incremental policy evaluation short-circuits on first deny-override. Compiled policy representation avoids XML parsing overhead. Distributed policy evaluation pushes decisions to edge nodes.

**Use Cases**: Cloud multi-tenancy with tenant-specific isolation policies. Healthcare data access based on patient consent, clinician specialty, purpose of use. IoT device authorization based on location, time, firmware version. API gateway authorization based on client quota, rate limit, subscription tier.

### Capability-Based Security

Unforgeable references granting specific permissions to objects. Capability possession proves authorization. No ambient authority—subject cannot access resource without explicit capability.

**Capability Structure**: Object reference plus permission mask. Cryptographic token prevents forgery and tampering. Capability derivation creates restricted capability from parent capability with subset of permissions. Capability revocation through indirection or time-bounded validity.

**Capability Distribution**: Initial capability bootstrapping through secure channel. Capability delegation: holder transfers capability to another subject. Delegation chains enable transitive authority transfer but complicate revocation. Capability amplification: combining multiple capabilities to access composite resource.

**Object Reference Security**: Randomized object identifiers make guessing infeasible. Encrypted object references prevent inspection and manipulation. Sparse identifier space (128-bit or 256-bit) ensures collision resistance and brute-force resistance. Object reference includes version or epoch to invalidate stale capabilities.

**Confinement**: Prevents capability leakage from confined subsystem. Parent process controls capabilities visible to child process. Capability inheritance limited to explicitly transferred capabilities. Prevents Trojan horse exfiltrating capabilities to unauthorized parties.

**Distributed Capabilities**: Network-transferable capabilities enable remote resource access. Capability encoding includes target location (endpoint), object identifier, permissions, authentication token. Requires secure capability transmission (TLS) and replay protection (nonce, timestamp). Server validates capability authenticity and freshness before granting access.

**Revocation Mechanisms**: Indirection through capability manager: revoke by removing entry from manager's table. Capability includes generation number, incremented on revocation, invalidating old capabilities. Time-bounded capabilities expire automatically, require renewal. Revocation list checked before granting access, trades performance for immediate revocation.

**Advantages**: Enables principle of least privilege through fine-grained capability distribution. Eliminates confused deputy problem: programs operate only on explicitly granted resources. Simplifies security analysis through capability propagation tracking. Supports delegation and transfer of authority.

**Disadvantages**: Capability loss causes permanent access denial, requires robust capability storage and backup. Revocation complexity increases with delegation chains. Capability proliferation consumes memory and complicates management. Coarse-grained capabilities limit expressiveness, fine-grained capabilities increase overhead.

### Context-Aware Access Control

Access decisions incorporate runtime context beyond static subject/object attributes. Context includes environmental conditions, risk assessment, usage patterns, compliance requirements.

**Trust Level Adaptation**: Authentication strength influences granted permissions. Strong authentication (multi-factor, hardware token) enables sensitive operations. Weak authentication (password) restricts access to low-sensitivity resources. Step-up authentication required when accessing higher-sensitivity resources.

**Location-Based Control**: Geographic location restricts access to region-specific data. Network location (internal, VPN, public internet) determines allowed operations. Device location (corporate network, approved country) influences trust level. Location spoofing detection through IP geolocation, GPS, cell tower triangulation.

**Device Posture Assessment**: Device health checks before granting access: OS patch level, antivirus status, encryption enabled, approved application list. Non-compliant devices denied or granted restricted access. Continuous posture monitoring revokes access on compliance violation. Mobile device management (MDM) enforces device policies.

**Risk-Based Authentication**: Anomaly detection identifies suspicious access patterns. Unusual login location, time, device, or IP triggers step-up authentication or access denial. Machine learning models predict access legitimacy based on historical behavior. Adaptive authentication balances security and user experience.

**Usage Monitoring**: Access frequency, data volume, operation type tracked per subject. Abnormal usage patterns (bulk downloads, unusual hours) trigger alerts or automatic throttling. Purpose-based access tracks intended use and enforces purpose limitation (GDPR compliance). Break-glass access logs emergency policy overrides for audit.

**Session Context**: Session establishment time, authentication method, authentication age influence permissions. Long-lived sessions periodically re-authenticated or downgraded. Concurrent session limits prevent credential sharing. Session binding to device/browser prevents session hijacking.

**Temporal Context**: Time-of-day restrictions prevent off-hours access. Date-based access for limited-time projects or temporary contractors. Absolute time bounds (contract expiration) versus sliding windows (last 90 days of activity). Scheduled access reviews trigger automated notifications or automatic revocation.

### Hierarchical Access Control

Organizes resources and subjects in hierarchies, propagating permissions through parent-child relationships. Simplifies administration of large-scale systems with structural organization.

**Directory-Based Hierarchy**: Resources organized in tree structure (filesystem, organizational unit). Permissions defined at parent propagate to descendants. Explicit permission at child overrides inherited permission. Permission calculation traverses path from root to target, accumulating grants and denials.

**Group Hierarchy**: Subjects organized in nested groups. Permission granted to parent group inherited by child groups. Enables organizational structure modeling: departments, teams, projects. Group membership expansion at access check time traverses hierarchy to compute effective permissions.

**Inheritance Semantics**: Cumulative inheritance: child receives union of ancestor permissions. Override inheritance: child permission replaces ancestor permission. Blocking inheritance: child explicitly blocks specific inherited permissions. Permission precedence rules resolve conflicts between inherited and explicit permissions.

**Negative Permissions**: Explicit deny overrides inherited allow. Enables exception-based policies: grant broad access, deny specific subsets. Deny propagation prevents re-granting at descendant levels. Increases policy complexity and potential for unintended denials.

**Scalability**: Hierarchy depth impacts permission resolution latency. Caching effective permissions at leaves amortizes traversal cost. Incremental updates propagate permission changes without full recomputation. Lazy inheritance evaluation defers computation until access check.

**Distributed Hierarchies**: Hierarchy partitioned across multiple authorization servers. Cross-partition references require remote queries. Hierarchy consistency during updates: eventual consistency may temporarily violate permissions. Hierarchy replication trades update complexity for read performance.

### Centralized vs Decentralized Enforcement

**Centralized Policy Decision**: Single PDP evaluates all access requests. Simplifies policy management and audit. Bottleneck under high request rate. Single point of failure without replication. Network latency impacts access check performance.

**Distributed Policy Enforcement**: PEPs embedded in resource servers perform local authorization. Policy synchronization distributes decisions to edges. Reduces latency and central load. Complicates policy consistency and update propagation. Stale policies cause authorization errors.

**Hybrid Architecture**: Centralized policy authoring and distribution. Cached policies at PEPs for fast local evaluation. Policy versioning and invalidation ensure consistency. Fallback to centralized PDP on cache miss or policy update.

**Policy Distribution**: Push model: central PAP pushes policy updates to PEPs. Pull model: PEPs periodically retrieve latest policies. Pub-sub model: policy changes published to subscribed PEPs. Eventual consistency trade-off: update latency versus distribution overhead.

### Token-Based Authorization

Bearer tokens carry authorization information, eliminating need for per-request policy evaluation. Tokens issued by trusted authority, validated by resource servers.

**OAuth 2.0 Access Tokens**: Opaque or structured tokens granting limited access to protected resources. Token scope restricts accessible resources and operations. Token expiration bounds compromise window. Refresh tokens enable long-lived access without credential re-presentation. Resource server validates token with authorization server (introspection) or verifies signed token locally.

**JSON Web Tokens (JWT)**: Self-contained tokens encoding claims about subject and granted permissions. Cryptographically signed (JWS) or encrypted (JWE) to prevent tampering. Stateless validation: resource server verifies signature without authorization server interaction. Token size grows with claim count, increasing transmission and storage overhead.

**Security Token Service (STS)**: Issues tokens upon successful authentication and authorization. Token format, signing algorithm, expiration configured per client. Supports token exchange: trade authentication token for access token with different scope or audience. Federation trust enables cross-domain token issuance.

**Token Validation**: Signature verification using issuer's public key. Expiration time check prevents replay of expired tokens. Audience restriction ensures token intended for validating service. Nonce or JTI (JWT ID) prevents token reuse. Revocation list checking for prematurely invalidated tokens.

**Token Revocation**: Immediate revocation requires token blacklist checked by resource servers. Blacklist grows unboundedly, cached with expiration. Short token lifetimes reduce revocation need but increase refresh frequency. Push-based revocation notifications alert resource servers to invalidated tokens.

**Phantom Token Pattern**: Authorization server issues opaque token to client. Resource server exchanges opaque token for JWT with authorization server. Prevents token inspection by client. Enables token revocation without JWT blacklist.

### Cross-Domain Authorization

**Federated Identity**: Trust relationship enables identity assertion across administrative domains. Identity provider (IdP) authenticates user, issues assertion. Service provider (SP) trusts IdP assertions, grants access based on asserted attributes. SAML, OpenID Connect protocols standardize assertion format and exchange.

**Attribute Aggregation**: Combine attributes from multiple authorities to make authorization decision. Virtual organization: project spanning multiple institutions, each contributing user attributes. Attribute transformation maps source attributes to target policy schema. Attribute conflict resolution when sources provide contradictory values.

**Cross-Domain Policy**: Home domain policy governs resource access regardless of accessing domain. Delegation agreements specify which policies apply in multi-domain scenarios. Policy precedence resolution when conflicting policies applicable. Border gateway enforces cross-domain policy at domain boundary.

**Trust Establishment**: Public key infrastructure (PKI) enables trust through certificate chains. Web of trust decentralizes certification through peer vouching. Direct trust agreements between domain pairs. Trust level influences granted privileges: higher trust enables more sensitive operations.

### Zero Trust Architecture

Continuous verification model: never trust, always verify. No implicit trust based on network location or prior authentication. Every access request authenticated, authorized, encrypted.

**Identity-Centric Security**: User identity, device identity, application identity verified for each request. Multi-factor authentication eliminates password-only access. Identity and access management (IAM) system as control plane.

**Micro-Segmentation**: Fine-grained network segmentation isolates resources. Software-defined perimeter restricts network-level access. East-west traffic inspection within internal network, not just north-south at perimeter. Prevents lateral movement after initial compromise.

**Least Privilege Access**: Grant minimum necessary permissions for each operation. Just-in-time access provisioning: temporary elevation for approved duration. Session recording and audit for privileged access. Automated permission revocation upon task completion.

**Continuous Monitoring**: Real-time behavioral analysis detects anomalous access patterns. Device compliance monitoring ensures security posture maintenance. Session risk scoring incorporates multiple signals: location, device, behavior. Adaptive policies adjust permissions based on risk score.

### Performance Considerations

**Policy Evaluation Latency**: Complex policies with extensive attribute retrieval increase authorization latency. Policy compilation transforms human-readable policies into optimized decision trees. Attribute caching trades freshness for speed. Policy short-circuiting returns on first definitive decision.

**Caching Strategies**: Subject-resource-action tuples cached with TTL. Permission cache invalidation on policy update or revocation. Negative cache entries prevent repeated denial queries. Cache consistency protocols ensure distributed caches reflect policy changes.

**Authorization Decision Batching**: Batch multiple authorization queries in single request. Reduces round-trip overhead for bulk operations. Parallel policy evaluation across batch items. Partial failure handling when subset denied.

**Scalability**: Horizontal scaling through PDP replication and load balancing. Partitioning policies by resource namespace distributes load. Hierarchical PDPs: coarse-grained decisions at root, fine-grained at leaves. Policy compilation ahead of time eliminates runtime parsing.

### Related Topics

- Authentication mechanisms and multi-factor authentication
- Identity federation (SAML, OpenID Connect, OAuth)
- Public key infrastructure and certificate management
- Cryptographic access control and encrypted access control lists
- Information flow control and taint tracking
- Covert channel analysis and mitigation
- Security labels and mandatory access control systems
- Policy languages (XACML, Rego, Cedar)
- Authorization protocols (OAuth 2.0, UMA)
- Trusted execution environments and hardware security modules
- Blockchain-based decentralized identity and access control

---

