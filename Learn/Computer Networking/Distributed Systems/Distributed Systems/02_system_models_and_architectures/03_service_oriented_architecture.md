## Service-Oriented Architecture


### Core Architectural Principles

Service-oriented architecture structures distributed systems as collections of loosely coupled, independently deployable services exposing well-defined interfaces. Services encapsulate business capabilities, own their data, and communicate through standardized protocols. The architecture enforces separation of concerns through service boundaries, enabling independent evolution, polyglot implementations, and organizational scaling.

**[Inference]** Services typically communicate synchronously via request-response protocols (SOAP, REST, gRPC) or asynchronously via message-oriented middleware, though specific protocol choices depend on implementation context.

### Service Contract and Interface Design

Service contracts define the interface boundary, data schemas, semantics, and operational characteristics. Contracts must be versioned, backward-compatible, and technology-agnostic to enable independent service evolution. Interface Definition Languages (IDLs) such as WSDL, OpenAPI, Protocol Buffers, or Avro enforce contract formalism.

Contract design requires explicit specification of:

- Request/response message schemas and validation rules
- Error semantics and fault codes
- Quality of service attributes (latency SLAs, throughput limits, availability guarantees)
- Semantic versioning and deprecation policies
- Idempotency guarantees for mutation operations
- Consistency guarantees (eventual vs strong)

Breaking changes necessitate versioned endpoints or content negotiation mechanisms to maintain backward compatibility during transition periods.

### Service Granularity and Boundary Definition

Service boundaries align with business capability domains, data ownership, and consistency requirements. Granularity represents a fundamental trade-off between deployment flexibility and operational complexity.

Coarse-grained services reduce inter-service communication overhead, network latency, and distributed transaction complexity but limit independent scalability and increase coordination requirements within service teams. Fine-grained services enable precise scaling, independent deployment velocity, and failure isolation but amplify network communication costs, distributed tracing complexity, and coordination overhead.

Boundary definition follows Domain-Driven Design principles: services own aggregate roots, maintain consistency boundaries within the service, and expose only coarse-grained operations that preserve domain invariants. Cross-service transactions require saga patterns or distributed transaction coordinators.

### Service Registry and Discovery

Service registry maintains authoritative service metadata including network endpoints, health status, capability versions, and routing policies. Discovery mechanisms enable runtime service location without hardcoded dependencies.

**Client-side discovery:** Clients query the registry directly and implement load balancing logic. Reduces registry load, eliminates single point of failure, but couples clients to discovery protocol and increases client complexity.

**Server-side discovery:** Clients invoke services through load balancers or API gateways that perform registry lookups. Centralizes discovery logic, simplifies clients, but introduces additional network hop and potential bottleneck.

Registry implementations require:

- Strongly consistent registration to prevent split-brain routing
- Health checking with configurable probe intervals and failure thresholds
- Metadata filtering for capability-based routing
- Watch mechanisms for push-based updates to reduce lookup latency
- TTL-based expiration with heartbeat renewal to handle ungraceful terminations

Common implementations: Consul, Eureka, etcd, ZooKeeper, Kubernetes Service API.

### Enterprise Service Bus (ESB)

ESB provides centralized mediation layer for service integration, message routing, protocol transformation, and orchestration logic. The bus acts as intermediary for all service interactions, implementing cross-cutting concerns including message transformation, routing rules, protocol adaptation, message enrichment, and orchestration.

**Data-plane responsibilities:**

- Protocol mediation (SOAP ↔ REST ↔ JMS ↔ proprietary formats)
- Message transformation and schema mapping
- Content-based routing using message inspection
- Message enrichment via auxiliary service calls
- Synchronous-asynchronous bridging

**Control-plane responsibilities:**

- Orchestration workflow execution
- Transaction coordination
- Service versioning and routing policies
- Security policy enforcement (authentication, authorization, encryption)
- Rate limiting and quota management

**Architectural consequences:**

- Single point of failure requiring high-availability clustering
- Performance bottleneck for high-throughput scenarios
- Increased latency due to additional hop
- Centralized governance but tight coupling to ESB technology
- Complex operational dependencies

**[Inference]** ESB architectures dominated enterprise integration before microservices patterns emerged; modern implementations trend toward decentralized patterns using service mesh or API gateways.

### Orchestration vs Choreography

**Orchestration:** Centralized coordinator explicitly invokes services in defined sequence. Orchestrator maintains workflow state, handles compensation logic, and implements timeout/retry policies. Provides visibility into end-to-end process state but creates single point of failure and tight coupling to orchestration engine.

Orchestration patterns use workflow engines (Temporal, Camunda, AWS Step Functions) executing long-running sagas with explicit compensation logic. Suitable for complex business processes requiring centralized control, audit trails, and human intervention points.

**Choreography:** Services react to events without central coordinator. Each service observes domain events, performs local operations, and publishes resulting events. Decouples services, eliminates single point of failure, but obscures end-to-end process visibility and complicates distributed debugging.

Choreography requires event sourcing or publish-subscribe infrastructure with durable message delivery. Services must implement idempotent event handlers, handle duplicate events, and maintain local state machines. Process state reconstructed through event log analysis rather than centralized tracking.

Trade-offs:

- Orchestration: Centralized control, explicit failure handling, simplified monitoring, but coordinator becomes bottleneck and coupling point
- Choreography: Loose coupling, no single point of failure, independent scaling, but distributed state management and complex observability

### Data Ownership and Bounded Contexts

Each service maintains exclusive write authority over its data, preventing direct database sharing. Cross-service data access occurs only through service APIs, enforcing encapsulation and enabling independent schema evolution.

Services model data according to bounded context semantics, potentially denormalizing shared concepts. For example, Customer entity exists independently in Order Service, Billing Service, and Support Service with context-specific attributes and lifecycle management.

**Data synchronization patterns:**

- **Event-driven replication:** Source service publishes change events; consuming services update local projections
- **API-based queries:** Services query authoritative source on-demand with caching layer
- **CQRS projections:** Separate read models materialized from event streams for query optimization

**Consistency implications:**

- Strong consistency maintained only within service boundary
- Cross-service operations exhibit eventual consistency
- Compensating transactions required for distributed consistency requirements
- Duplicate data increases storage costs but enables independent service operation during network partitions

### Transaction Management and Saga Patterns

Distributed transactions across service boundaries use saga patterns rather than two-phase commit due to availability and performance constraints.

**Choreographed sagas:** Each service listens for events, performs local transaction, publishes success/failure event. Compensation logic triggered by failure events in reverse dependency order. No central coordinator; saga state distributed across services.

**Orchestrated sagas:** Saga coordinator explicitly invokes service operations, maintains compensation logic, and handles failure recovery. Coordinator persists saga state for crash recovery.

**Implementation requirements:**

- Idempotent operation handlers to safely retry
- Compensation operations for each forward transaction
- Timeout handling with exponential backoff
- Saga log persistence for crash recovery (orchestrated pattern)
- Isolation handling: semantic locks, commutative operations, or optimistic concurrency control

**[Inference]** Sagas provide BASE (Basically Available, Soft state, Eventual consistency) semantics rather than ACID guarantees; applications must tolerate intermediate inconsistent states.

### Communication Patterns

**Synchronous request-response:**

- Direct service invocation with immediate response
- Tight temporal coupling; caller blocks awaiting response
- Amplifies failures through cascading timeouts
- Requires circuit breakers, timeouts, and retry logic
- Protocols: REST/HTTP, gRPC, GraphQL, SOAP

**Asynchronous messaging:**

- Message queues or publish-subscribe topics decouple temporal dependencies
- Enables load leveling, buffering, and independent scaling
- Complicates request-response correlation and error propagation
- Requires durable message storage and delivery guarantees
- Protocols: AMQP, MQTT, Kafka, NATS, cloud-native queues

**Hybrid patterns:**

- Request-response for synchronous queries; events for state changes
- Commands for direct service invocation; events for notification
- Sync for user-facing flows; async for background processing

Message durability and delivery semantics:

- At-most-once: No retries; acceptable for non-critical data
- At-least-once: Retries until acknowledgment; requires idempotent handlers
- Exactly-once: Transactional semantics; complex to implement, typically database-backed

### API Gateway Pattern

API gateway consolidates external client access through single entry point, implementing cross-cutting concerns outside individual services.

**Responsibilities:**

- Request routing and composition (scatter-gather aggregation)
- Protocol translation (REST → gRPC, HTTP → WebSocket)
- Authentication and authorization enforcement
- Rate limiting, quota management, and throttling
- Request/response transformation and filtering
- API versioning and backward compatibility routing
- TLS termination and certificate management
- Caching for read-heavy endpoints
- Request tracing and correlation ID injection

**Architectural trade-offs:**

- Centralized cross-cutting concerns vs single point of failure
- Additional network hop increases latency
- Gateway clustering required for high availability
- Logic duplication risk if services implement redundant concerns
- Potential performance bottleneck under high throughput

**Backend for Frontend (BFF) variant:** Separate gateway per client type (web, mobile, IoT) optimizing response payloads and aggregation logic for specific client needs. Increases operational complexity but reduces over-fetching and improves client performance.

### Scalability and Partitioning Strategies

Services scale independently based on load characteristics. Stateless services scale horizontally through load-balanced replication. Stateful services require partitioning strategies.

**Horizontal scaling approaches:**

- Stateless services: Add instances behind load balancer with round-robin, least-connections, or consistent hashing
- Stateful services with sharding: Partition data across instances using partition key (hash-based, range-based, or directory-based)
- Stateful services with replication: Leader-follower topology with read replicas

**Partition key selection criteria:**

- Uniform distribution to prevent hotspots
- Query pattern alignment to minimize cross-partition operations
- Stable mapping to reduce rebalancing overhead

**Rebalancing considerations:**

- Consistent hashing minimizes key reassignment during topology changes
- Virtual nodes improve distribution uniformity
- Rebalancing requires data migration with coordination protocols
- Incremental rebalancing reduces impact on steady-state operations

**Scalability constraints:**

- Synchronous call chains amplify latency; N-hop chain multiplies p99 latency
- Shared dependencies (databases, caches) become bottlenecks
- Cross-service joins and aggregations limit scaling efficiency
- Distributed tracing and observability overhead scales with request volume

### Failure Modes and Resilience Patterns

Service failures propagate through synchronous dependencies unless actively mitigated. Resilience patterns isolate failures and maintain degraded operation.

**Circuit breaker:** Detects repeated failures, opens circuit to fail fast, periodically attempts recovery. Prevents cascading failures and resource exhaustion. Requires tuning of failure threshold, timeout window, and half-open retry logic.

**Bulkhead:** Isolates thread pools, connection pools, or resource quotas per dependency to prevent single dependency exhaustion from affecting others. Limits blast radius of failures.

**Timeout and retry:** Explicit timeouts prevent indefinite blocking. Retries with exponential backoff and jitter handle transient failures. Idempotent operations required for safe retries. Retry budgets prevent retry storms.

**Fallback and degraded operation:** Secondary code paths provide reduced functionality when dependencies fail. Cached responses, default values, or alternative implementations maintain partial service availability.

**Health checks:** Liveness probes detect crashed processes; readiness probes detect inability to serve traffic. Probes must verify critical dependencies without cascading failures during dependency outages.

**Failure isolation domains:** Services deployed across availability zones, regions, or fault domains. Load balancing with zone-aware routing. Transient partition handling through eventual consistency and anti-entropy.

### Observability and Distributed Tracing

Distributed request flows require correlated telemetry across services. Observability combines metrics, logs, and traces.

**Distributed tracing:** Assigns unique trace ID to request, propagates through service calls. Each service emits spans with parent relationships, timing, and metadata. Reconstructs end-to-end latency breakdown and dependency graphs.

Implementation requirements:

- Trace context propagation via headers (W3C Trace Context, B3)
- Sampling strategies to control overhead (head-based, tail-based, adaptive)
- Span enrichment with service metadata, tags, and baggage
- Trace storage with queryable indexing (Jaeger, Zipkin, Tempo)

**Metrics aggregation:** Service-level metrics (request rate, error rate, latency percentiles) aggregated with dimensional labels. Service mesh or sidecar proxies auto-instrument without application changes.

**Structured logging:** Correlated logs with trace IDs enable drill-down from trace to detailed log events. Centralized log aggregation with full-text search (ELK, Loki, Splunk).

**Synthetic monitoring:** Proactive health checks and end-to-end transaction validation detect issues before user impact.

### Security Boundaries

**Service-to-service authentication:** Mutual TLS (mTLS) with certificate-based identity. Service mesh automates certificate lifecycle. Alternatively, JWT tokens with signature verification.

**Authorization enforcement:** Policy-based access control at API gateway or per-service. Open Policy Agent or similar decouples policy from code. Role-based (RBAC) or attribute-based (ABAC) models.

**Network segmentation:** Services deployed in isolated network segments. Firewall rules restrict communication to explicitly allowed paths. Service mesh enforces network policies.

**Secrets management:** Externalized configuration for credentials, API keys, certificates. Secrets injected at runtime from vault (HashiCorp Vault, AWS Secrets Manager, Kubernetes Secrets). Automatic rotation with graceful reload.

**Data encryption:** TLS in transit. Encryption at rest for sensitive data. Field-level encryption for PII. Key management service for key lifecycle.

**API security:** Input validation, rate limiting, OAuth2/OIDC for user authentication. API gateway enforces authentication before routing. DDoS protection and WAF for public endpoints.

### Versioning and Compatibility

**Interface versioning strategies:**

- **URL versioning:** `/v1/resource`, `/v2/resource` - explicit, simple routing, proliferates endpoints
- **Header versioning:** `Accept: application/vnd.api+json;version=2` - clean URLs, requires header parsing
- **Content negotiation:** Clients specify accepted versions; server responds with compatible format

**Backward compatibility requirements:**

- Additive changes: New optional fields, new endpoints
- Non-breaking changes: Expand enums with unknown value handling, relax validation
- Breaking changes: Remove fields, change semantics, tighten validation - require new version

**Deployment strategies:**

- **Blue-green deployment:** Run both versions, switch traffic atomically
- **Canary deployment:** Gradually shift traffic percentage to new version
- **Feature flags:** Toggle new behavior at runtime without redeployment

**Deprecation process:** Announce deprecation timeline, monitor usage metrics, provide migration guides, maintain grace period before removal.

### Operational Characteristics

**Deployment independence:** Services deploy separately without coordinated releases. Requires robust contract testing and backward compatibility. Eliminates large-scale rollout coordination but increases integration testing complexity.

**Polyglot implementations:** Services implement in different languages/runtimes optimized for specific workloads. Requires standardization of observability, deployment, and operational patterns.

**Organizational alignment:** Services map to team ownership boundaries (Conway's Law). Enables team autonomy but requires clear interface contracts and coordination protocols.

**Change amplification:** Single logical feature may require changes across multiple services. Increases coordination overhead and testing scope.

**Performance overhead:** Service boundaries introduce network latency, serialization costs, and increased resource consumption compared to monolithic process.

**Debugging complexity:** Distributed failures require trace correlation across services. Local development environments require service mocking or containerized dependencies.

### Related Architectural Patterns

- Microservices Architecture
- Event-Driven Architecture
- CQRS (Command Query Responsibility Segregation)
- Event Sourcing
- Service Mesh Architecture
- API Gateway Pattern
- Strangler Fig Pattern
- Saga Pattern
- Backend for Frontend (BFF)

---

