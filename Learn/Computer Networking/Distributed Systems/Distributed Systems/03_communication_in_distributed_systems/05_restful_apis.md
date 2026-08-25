## RESTful APIs


### Architectural Constraints

REST (Representational State Transfer) defines six architectural constraints forming a resource-oriented distributed system model:

**Client-Server Separation:** Decouples user interface concerns from data storage and business logic. Enables independent evolution and scaling of client and server components.

**Statelessness:** Server maintains no client session state between requests. Each request contains all information necessary for processing (authentication tokens, context data). Session state resides entirely on client or externalized to distributed cache/database. Enables horizontal scaling without session affinity, simplifies failure recovery, but increases per-request payload size.

**Cacheability:** Responses must explicitly declare cache directives (Cache-Control headers, ETags). Clients and intermediary caches store responses to reduce latency and server load. Requires cache invalidation strategies and conditional request mechanisms (If-None-Match, If-Modified-Since).

**Uniform Interface:** Standardized interaction semantics via resource identification (URIs), resource manipulation through representations (JSON, XML, Protobuf), self-descriptive messages (HTTP headers, media types), and hypermedia controls (HATEOAS links). Simplifies client implementation but may introduce inefficiency compared to optimized RPC protocols.

**Layered System:** Intermediary components (load balancers, CDNs, API gateways, reverse proxies) inserted transparently between client and server. Each layer only aware of immediate neighbors. Enables caching, security enforcement, and load distribution but adds latency.

**Code-on-Demand (Optional):** Server transmits executable code (JavaScript, WebAssembly) to client for dynamic behavior extension. Rarely implemented in pure REST APIs.

### Resource Modeling and URI Design

**Resource Identification:** Every addressable entity modeled as resource with unique URI. Resources represent business domain concepts (users, orders, products), not implementation details (database tables, function calls). Collections represented as plural nouns (`/users`), individual resources via path parameters (`/users/{userId}`).

**URI Hierarchy:** Nested resources express relationships (`/users/{userId}/orders/{orderId}`). Shallow hierarchies preferred; deep nesting indicates potential modeling issues. Alternative: query parameters for filtering collections (`/orders?userId={userId}`).

**Resource Granularity:** Coarse-grained resources reduce request count but increase payload size and cache invalidation complexity. Fine-grained resources enable precise caching and access control but increase request overhead and latency (N+1 query problem).

**Identifier Stability:** Resource URIs must remain stable across system evolution. Opaque identifiers (UUIDs, hash-based IDs) preferred over sequential integers (predictability, enumeration attacks) or natural keys (mutability). Identifier generation strategies: client-generated UUIDs, server-assigned UUIDs, distributed ID generation (Snowflake, ULID).

### HTTP Method Semantics and Idempotency

**GET:** Retrieves resource representation. Safe (no side effects) and idempotent. Cacheable by default. Query parameters for filtering, sorting, pagination. Response codes: 200 (OK), 304 (Not Modified), 404 (Not Found).

**POST:** Creates subordinate resource or triggers processing. Non-idempotent; repeated requests create multiple resources. Response includes Location header with created resource URI. Response codes: 201 (Created), 202 (Accepted for async processing), 400 (Bad Request).

**PUT:** Replaces entire resource representation at specified URI. Idempotent; repeated identical requests produce same result. Requires complete resource representation. Response codes: 200 (OK), 201 (Created if resource didn't exist), 204 (No Content), 409 (Conflict).

**PATCH:** Applies partial modifications to resource. Idempotency depends on patch semantics (JSON Patch, JSON Merge Patch). JSON Patch provides operation-based updates with test conditions. Response codes: 200 (OK), 204 (No Content), 409 (Conflict).

**DELETE:** Removes resource. Idempotent; deleting non-existent resource returns 404, but repeating delete operation is safe. Soft delete vs hard delete implementation choice. Response codes: 200 (OK with content), 204 (No Content), 404 (Not Found).

**HEAD:** Retrieves metadata (headers) without response body. Used for cache validation, resource existence checking, metadata inspection. Same response codes as GET.

**OPTIONS:** Describes communication options for target resource. Returns allowed methods in Allow header. CORS preflight requests use OPTIONS.

### Representation Formats and Content Negotiation

**Media Types:** Content-Type header specifies request payload format, Accept header specifies preferred response formats. Server selects appropriate representation via content negotiation algorithm. Common types: `application/json`, `application/xml`, `application/vnd.api+json`, `application/hal+json`.

**JSON:** Dominant representation format. Human-readable, language-agnostic, widely supported. No schema enforcement by default; requires additional validation (JSON Schema). Lacks built-in type safety and date/time standardization.

**Protocol Buffers (Protobuf):** Binary format with schema definition. Smaller payload size, faster serialization/deserialization, strong typing, backward/forward compatibility via field numbering. Requires schema distribution and code generation. Less human-readable.

**Hypermedia Formats:** HAL (Hypertext Application Language), JSON:API, Siren embed navigational links within representations. Enables dynamic client discovery of available actions and related resources. Increases response size; adoption limited outside hypermedia-driven applications.

**Versioning in Media Types:** Media type versioning (`application/vnd.company.resource.v2+json`) provides explicit version signaling without URI pollution. Alternative: custom headers (`API-Version: 2`), URI versioning (`/v2/resources`), query parameters (`/resources?version=2`).

### State Management and Idempotency

**Stateless Request Processing:** Each request contains authentication token (JWT, OAuth2 access token), conditional headers (ETags for optimistic concurrency), and filter/pagination parameters. Server reconstructs request context without stored session state.

**Idempotency Keys:** Client-generated unique identifiers (UUID) sent via `Idempotency-Key` header. Server stores processed keys with TTL to detect and deduplicate repeated requests. Critical for payment processing, order creation, and other non-idempotent operations. Requires distributed storage (Redis, database) for multi-instance deployments.

**Optimistic Concurrency Control:** ETags represent resource version. Client includes `If-Match` header with known ETag on update requests. Server rejects request with 412 (Precondition Failed) if ETag mismatches, indicating concurrent modification. Requires ETag generation strategy (content hash, version number, last-modified timestamp).

**Pessimistic Locking:** Explicit lock acquisition via POST to lock resource (`/resources/{id}/lock`), modification, then lock release via DELETE. Introduces complexity, deadlock potential, and availability issues if lock holder fails. Timeout-based lock expiration mitigates orphaned locks.

### Pagination and Filtering

**Offset-Based Pagination:** `?offset=0&limit=20` parameters. Simple implementation but inefficient for large offsets (database must scan and discard rows) and inconsistent under concurrent modifications (items may be skipped or duplicated).

**Cursor-Based Pagination:** Opaque cursor token encodes position in result set. Client passes cursor from previous response: `?cursor={token}&limit=20`. Consistent under modifications, efficient for large datasets. Requires cursor encoding strategy (encrypted state, keyset pagination).

**Keyset Pagination:** Uses last seen resource ID and timestamp: `?after_id={id}&after_time={timestamp}&limit=20`. Efficient database queries via indexed columns. Requires stable sort order and indexed fields.

**Filtering and Sorting:** Query parameters express filter criteria: `?status=active&created_after=2024-01-01&sort=-created_at`. Complex filters require query language design (RSQL, OData query syntax) or GraphQL-like field selection. Filter parameter explosion creates URI bloat and cache fragmentation.

**Metadata in Response:** Include pagination metadata in response body or Link headers (RFC 5988): total count, next/previous page URIs, cursor tokens. Link headers enable header-based pagination for hypermedia-driven clients.

### Caching Strategies

**Cache-Control Directives:** `max-age` (freshness lifetime), `no-cache` (revalidation required), `no-store` (no caching), `private` (client-only caching), `public` (shared cache eligible), `must-revalidate` (strict freshness enforcement). Combine directives for precise control: `Cache-Control: private, max-age=3600, must-revalidate`.

**ETag-Based Validation:** Server generates ETag (strong or weak validator) for response. Client stores ETag and includes `If-None-Match` on subsequent requests. Server returns 304 (Not Modified) if ETag matches, avoiding full response transmission. Strong ETags require byte-identical representations; weak ETags permit semantically equivalent representations.

**Last-Modified Validation:** `Last-Modified` header with timestamp. Client sends `If-Modified-Since` on conditional requests. Less precise than ETags (second-level granularity), but simpler generation.

**Cache Invalidation:** Time-based expiration (TTL) simple but may serve stale data. Event-driven invalidation (publish invalidation messages on resource modification) requires cache infrastructure and distributed coordination. Purge-based invalidation (DELETE requests to cache keys) requires cache API access.

**Vary Header:** Specifies response variance based on request headers: `Vary: Accept, Accept-Encoding`. Cache must store separate entries per variant. Excessive Vary headers reduce cache hit rate.

### Authentication and Authorization

**Token-Based Authentication:** JWT (JSON Web Tokens) or opaque access tokens transmitted via `Authorization: Bearer {token}` header. JWTs self-contained with claims and signature verification; opaque tokens require introspection endpoint. Token expiration and refresh token rotation mitigate theft risk.

**OAuth 2.0 Flows:** Authorization Code flow (web apps with backend), PKCE extension (mobile/SPA), Client Credentials (service-to-service), Resource Owner Password (legacy). Access tokens grant API access; refresh tokens obtain new access tokens without re-authentication.

**API Keys:** Simpler than OAuth but less secure (no expiration, no scopes). Transmitted via custom header (`X-API-Key`) or query parameter (discouraged due to logging exposure). Suitable for internal APIs or trusted partners.

**mTLS (Mutual TLS):** Client presents X.509 certificate during TLS handshake. Strong authentication for service-to-service communication. Certificate distribution and rotation complexity. Zero-trust architecture foundation.

**Scope-Based Authorization:** OAuth scopes define permission granularity (`read:users`, `write:orders`). API gateway or application layer enforces scope requirements per endpoint. Attribute-Based Access Control (ABAC) or Role-Based Access Control (RBAC) for fine-grained authorization.

### Rate Limiting and Throttling

**Rate Limit Algorithms:** Token bucket (burst capacity + sustained rate), leaky bucket (smooth rate enforcement), fixed window counters (simple but burst at window boundaries), sliding window log (accurate but memory-intensive), sliding window counters (approximation with lower overhead).

**Rate Limit Headers:** Standardized headers communicate limits to clients: `X-RateLimit-Limit` (total quota), `X-RateLimit-Remaining` (remaining quota), `X-RateLimit-Reset` (quota reset timestamp). Response code 429 (Too Many Requests) with `Retry-After` header.

**Distributed Rate Limiting:** Centralized counter storage in Redis with atomic increment operations. Requires low-latency access and high availability. Alternative: local counters with gossip protocol synchronization (eventual consistency, potential over-limit).

**Tiered Rate Limits:** Different limits per client tier (free, paid, enterprise), per endpoint (expensive operations have lower limits), per authentication method (authenticated vs anonymous). Requires client identification strategy.

**Backpressure and Circuit Breaking:** Server rejects requests when overloaded (503 Service Unavailable with Retry-After). Client-side circuit breakers detect failure patterns and stop sending requests during outage windows. Exponential backoff with jitter prevents thundering herd on recovery.

### Error Handling and Status Codes

**Status Code Selection:** 2xx (success), 4xx (client error), 5xx (server error). Specific codes: 400 (malformed request), 401 (authentication required), 403 (forbidden), 404 (not found), 409 (conflict), 422 (validation failure), 429 (rate limit), 500 (internal error), 502 (bad gateway), 503 (unavailable), 504 (timeout).

**Error Response Body:** Structured error format with machine-readable code, human-readable message, request ID for correlation, validation errors array for field-level feedback. Example format: RFC 7807 Problem Details (`application/problem+json`).

**Partial Failure Handling:** Bulk operations (batch create/update) may partially succeed. Response indicates per-item status with 207 (Multi-Status) containing sub-status codes. Client must handle partial success scenarios.

**Transient vs Permanent Errors:** 5xx errors may be transient (retry eligible); 4xx errors permanent (client must fix request). Idempotent methods safe to retry; non-idempotent require idempotency keys.

### Versioning Strategies

**URI Versioning:** Major version in path (`/v1/resources`, `/v2/resources`). Simple, explicit, cache-friendly. Creates URI proliferation; breaking changes require new version namespace.

**Header Versioning:** Custom header (`API-Version: 2`) or Accept header media type versioning. Preserves URI stability but complicates caching (Vary header), routing, and client implementation.

**Query Parameter Versioning:** `?version=2`. Easy testing and debugging but pollutes query namespace and complicates caching.

**Deprecation Strategy:** Sunset header announces deprecation timeline. Maintain multiple versions concurrently during transition period. Monitor version usage metrics to guide migration. Remove deprecated versions after sufficient adoption of new version.

### Scalability Characteristics

**Stateless Horizontal Scaling:** Load balancers distribute requests across API server instances without session affinity. Elastic scaling based on request rate, CPU, memory metrics. Auto-scaling policies handle traffic bursts.

**Database Contention:** N+1 query problem from nested resource loading. Mitigation: eager loading, GraphQL-style field selection, caching layer, database read replicas, CQRS pattern with optimized read models.

**Connection Pooling:** HTTP/1.1 persistent connections, HTTP/2 multiplexing reduce connection establishment overhead. Connection pool sizing based on concurrency requirements and upstream service limits.

**CDN and Edge Caching:** Geographic distribution of cacheable responses (GET requests for public resources). CDN PoPs serve responses from edge locations, reducing origin load and latency. Dynamic content acceleration via optimized routing.

### Security Considerations

**Input Validation:** Whitelist-based validation for all inputs (path parameters, query parameters, headers, body). Prevent injection attacks (SQL, NoSQL, command, XXE). Length limits prevent DoS. Type validation and format constraints (regex, schema validation).

**Output Encoding:** Context-aware encoding prevents XSS in JSON responses consumed by browsers. Content-Type enforcement (`application/json` with `X-Content-Type-Options: nosniff`).

**CORS (Cross-Origin Resource Sharing):** Controlled cross-domain access via preflight requests and response headers (`Access-Control-Allow-Origin`, `Access-Control-Allow-Methods`, `Access-Control-Allow-Headers`). Avoid wildcard origins (`*`) for authenticated APIs.

**CSRF Protection:** State-changing operations (POST, PUT, PATCH, DELETE) vulnerable to CSRF if cookie-based authentication used. Mitigation: token-based authentication (no cookies), same-site cookie attribute, custom request headers (checked by browsers' same-origin policy).

**TLS/HTTPS:** Mandatory transport encryption. TLS 1.3 preferred. Certificate pinning for high-security scenarios. HTTP Strict Transport Security (HSTS) header enforces HTTPS.

**Rate Limiting and DDoS Protection:** Protect against abuse and resource exhaustion. Per-IP, per-API-key, per-user rate limits. Geographic filtering, CAPTCHA challenges, anomaly detection for sophisticated attacks.

### Observability and Monitoring

**Distributed Tracing:** Trace ID propagated across API calls via headers (`X-Request-ID`, W3C Trace Context). Correlates logs and metrics across services. Spans capture operation duration, errors, metadata. OpenTelemetry standard for instrumentation.

**Metrics Collection:** Request rate, error rate, latency percentiles (p50, p95, p99), payload sizes per endpoint and status code. Dependency latency tracking. Resource utilization (CPU, memory, connection pools).

**Structured Logging:** JSON-formatted logs with correlation IDs, user IDs, error codes, stack traces. Centralized log aggregation (ELK, Splunk, CloudWatch Logs). Log sampling for high-volume endpoints to control costs.

**Health Check Endpoints:** `/health` for liveness (service process running), `/ready` for readiness (dependencies available). Load balancer uses readiness checks for traffic routing. Kubernetes liveness/readiness probe integration.

**API Analytics:** Usage patterns per client, endpoint popularity, error frequency, deprecation tracking. Informs capacity planning, breaking change impact assessment, and deprecation timelines.

### Failure Modes and Resilience

**Upstream Dependency Failure:** Circuit breakers prevent cascading failures when downstream services unavailable. Fallback to cached data or degraded functionality. Timeout policies prevent request queuing.

**Database Unavailability:** Read replicas provide redundancy for read operations. Write failures require retry logic with exponential backoff or queueing for eventual processing. Cache serves stale data during outage.

**Partial Outage:** Regional failures isolated via multi-region deployments. Geographic load balancing routes traffic to healthy regions. Eventual consistency between regions for write operations.

**Thundering Herd:** Synchronized cache expiration or service restart causes request surge. Mitigation: staggered TTLs, cache warming on startup, request coalescing (deduplicate identical in-flight requests), rate limiting.

**Poison Pill Requests:** Requests triggering server errors due to data corruption or edge cases. Request logging enables identification and blocking of problematic patterns. Input sanitization and defensive programming.

### Operational Characteristics

**Deployment Strategies:** Blue-green deployments (instant switchover between versions), canary releases (gradual traffic shifting to new version), rolling updates (incremental instance replacement). Backward-compatible changes enable zero-downtime deployments.

**Contract Testing:** Consumer-driven contracts verify API compatibility. Producer verifies contracts on every change. Prevents breaking changes from reaching production.

**API Gateway Pattern:** Centralized entry point for authentication, rate limiting, request routing, protocol translation, request/response transformation, caching, monitoring. Examples: Kong, Apigee, AWS API Gateway, Envoy.

**Documentation:** OpenAPI (Swagger) specification describes endpoints, schemas, authentication. Auto-generated client SDKs and interactive documentation. Kept in sync with implementation via code-first or spec-first approaches.

### Related Architectural Patterns

GraphQL APIs, gRPC services, WebSocket connections, Server-Sent Events, webhook patterns, API gateway pattern, backends-for-frontends, CQRS, event-driven architecture, microservices communication patterns.

---

