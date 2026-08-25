## Multi-Tier Model


### Architectural Characteristics

Layered architecture separating concerns into distinct tiers with well-defined responsibilities and interfaces. Typical tiers: presentation (client tier), application logic (middle tier), data storage (data tier). May extend to additional tiers: caching tier, API gateway tier, messaging tier, analytics tier.

### Tier Responsibilities and Boundaries

**Presentation Tier:** User interface rendering, input validation, session management, client-side state. May be thin (browser-based) or thick (native applications). Communicates with application tier via REST, GraphQL, gRPC, or WebSocket APIs.

**Application Tier (Business Logic):** Domain logic enforcement, transaction coordination, workflow orchestration, authorization decisions. Stateless service design enables horizontal scaling. Stateful workflows require distributed session management or workflow engines.

**Data Tier:** Persistent storage, ACID transaction support, query processing, indexing, backup/recovery. Relational databases, NoSQL stores, distributed databases, or polyglot persistence strategies.

**Caching Tier:** In-memory data stores (Redis, Memcached) reducing database load and improving read latency. Requires cache invalidation strategies (TTL-based, event-driven invalidation, write-through patterns). Cache-aside, read-through, write-through, write-behind patterns define interaction semantics.

**Messaging/Event Tier:** Asynchronous communication via message queues (RabbitMQ, SQS), event streaming platforms (Kafka, Pulsar), or service buses. Decouples tiers temporally, enables event-driven architectures, handles backpressure.

### Communication Patterns Between Tiers

**Synchronous Request-Response:** Direct tier-to-tier calls with blocking semantics. Simple programming model but introduces tight temporal coupling and cascading failures. Requires timeout policies, circuit breakers, bulkheads for fault isolation.

**Asynchronous Messaging:** Tier produces messages consumed asynchronously by downstream tier. Decouples tiers, provides buffering and backpressure handling. Requires message delivery guarantees (at-least-once, at-most-once, exactly-once semantics) and idempotency.

**Event-Driven:** Tiers emit domain events consumed by interested subscribers. Enables reactive architectures, polyglot data replication, CQRS patterns. Requires event schema management, ordering guarantees (per-partition ordering in Kafka), and event versioning strategies.

### Data Flow and Ownership

**Vertical Data Flow:** Request flows top-down (presentation → application → data), response flows bottom-up. Application tier owns business logic and data transformation. Data tier owns authoritative persistent state.

**Horizontal Data Flow:** Data replication between tier instances (application tier nodes sharing cache, data tier replication). Introduces consistency challenges requiring coordination protocols or eventual consistency acceptance.

**Read-Write Separation:** Read replicas in data tier serve read-heavy workloads. Application tier routes writes to primary, reads to replicas. Introduces replication lag and eventual consistency for read paths. Requires application-level awareness of consistency requirements.

### Scalability Patterns

**Tier-Independent Scaling:** Each tier scales independently based on resource utilization and workload characteristics. Presentation tier scales with user count, application tier with request complexity, data tier with data volume and query load.

**Stateless Application Tier:** Horizontal scaling via load balancers without session affinity. Session state externalized to caching tier or data tier. Enables elastic scaling, rolling deployments, and instance replacement without service disruption.

**Data Tier Scaling:** Vertical scaling (larger instances), read replicas (horizontal read scaling), sharding/partitioning (horizontal write scaling), distributed databases (native horizontal scalability). Each approach involves consistency, complexity, and operational trade-offs.

**Caching Tier Scaling:** Consistent hashing for distributed cache clusters. Partition data across cache nodes to scale capacity and throughput. Cache cluster topology changes require rebalancing and coordinated invalidation.

### Consistency and Transaction Boundaries

**Single-Tier Transactions:** ACID transactions within data tier provide strong consistency. Database transaction isolation levels (Read Committed, Repeatable Read, Serializable) define consistency guarantees.

**Cross-Tier Transactions:** Distributed transactions via 2PC (Two-Phase Commit) or 3PC (Three-Phase Commit) provide atomicity across tiers but introduce latency, blocking, and availability challenges. Coordinator failure creates uncertainty.

**Saga Pattern:** Long-running business transactions decomposed into sequence of local transactions with compensating transactions for rollback. Provides eventual consistency without distributed locks. Orchestration (centralized coordinator) or choreography (event-driven) variants.

**Eventual Consistency:** Accept temporary inconsistency between tiers (cache staleness, replica lag) in exchange for availability and performance. Requires application-level handling of inconsistency manifestations.

### Failure Modes and Resilience

**Tier Failure:** Load balancer health checks detect failed instances, route traffic to healthy instances. Redundant instances within each tier provide fault tolerance. Stateless tiers recover quickly; stateful tiers require state reconstruction or replication.

**Cascading Failures:** Failure in lower tier (data tier) propagates to application tier, then presentation tier. Circuit breakers, timeouts, and bulkhead isolation patterns limit failure propagation. Degraded mode operation with cached or stale data maintains partial availability.

**Network Partition Between Tiers:** Application tier cannot reach data tier. System chooses availability (serve stale/cached data) or consistency (reject requests). CAP theorem forces trade-off. Retry logic and exponential backoff for transient failures.

**Thundering Herd:** Simultaneous cache expiration or tier restart causes synchronized load spike on downstream tier. Mitigation via cache warming, staggered TTLs, request coalescing, rate limiting, and gradual traffic ramping.

### Security Boundaries and Isolation

**Network Segmentation:** Tiers deployed in separate network zones (DMZ for presentation, private network for application/data tiers). Firewall rules restrict inter-tier communication to authorized protocols and ports.

**Authentication and Authorization:** Authentication at presentation tier (user identity), authorization at application tier (permission enforcement), data tier access restricted to application tier service accounts. Zero-trust architecture validates every inter-tier request.

**Data Protection:** Encryption in transit (TLS between tiers) and at rest (data tier storage encryption). Sensitive data masking in caching tier. Secrets management for credentials and API keys used in inter-tier communication.

**Compliance Boundaries:** Data residency requirements may dictate tier geographic placement. PCI DSS compliance requires network isolation for payment processing tiers. GDPR requires data access controls and audit logging across tiers.

### Operational Characteristics

**Deployment Complexity:** Independent deployment pipelines per tier enable incremental rollouts but require coordination for API contract changes. Blue-green or canary deployments per tier minimize downtime.

**Monitoring and Observability:** Distributed tracing (OpenTelemetry, Jaeger) tracks requests across tier boundaries. Metrics per tier (latency, throughput, error rates) identify bottlenecks. Centralized logging aggregates logs from all tiers.

**Capacity Planning:** Tier-specific capacity models based on workload characteristics. Data tier constrained by IOPS and storage, application tier by CPU/memory, presentation tier by concurrent connections. Horizontal scaling strategies differ per tier.

**Cost Optimization:** Over-provisioning one tier while under-utilizing others creates inefficiency. Auto-scaling policies per tier based on demand. Reserved/spot instances for predictable baseline, on-demand for burst capacity.

### Related Architectural Patterns

Microservices architecture, service-oriented architecture, hexagonal architecture, CQRS, event sourcing, API gateway pattern, backends-for-frontends, strangler fig pattern.

---

