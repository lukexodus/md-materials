## Microservices


### Core Architectural Principles

Microservices decompose a system into independently deployable services bounded by business capabilities or domains. Each service owns its data, exposes well-defined APIs, and operates autonomously. Services communicate over the network using synchronous protocols (HTTP/REST, gRPC) or asynchronous messaging (event streams, message queues). The architecture prioritizes organizational scalability, deployment independence, and technology heterogeneity over monolithic simplicity.

### Service Boundaries and Domain Decomposition

Service boundaries align with bounded contexts from Domain-Driven Design. Each microservice encapsulates a cohesive set of business capabilities with minimal coupling to other services. Boundaries follow domain invariants—data that must remain consistent is colocated within a single service. Poor boundary definition leads to distributed monoliths where services exhibit high temporal coupling, require coordinated deployments, and share databases.

Decomposition strategies include:

- **Business capability mapping**: Services organized around business functions (e.g., order management, inventory, pricing)
- **Subdomain isolation**: Core, supporting, and generic subdomains mapped to service granularity
- **Data ownership boundaries**: Services own authoritative data for their domain, no shared databases
- **Team autonomy alignment**: Service boundaries match team structures to minimize coordination overhead

### Data Management and Consistency

Each microservice maintains exclusive ownership of its persistent state. Shared databases violate encapsulation and create hidden coupling through schema dependencies. Services expose data through APIs, not direct database access.

**Data Consistency Models:**

- **Eventual consistency**: Asynchronous propagation of state changes across services via events. Aggregate consistency maintained within service boundaries; cross-service consistency achieved through saga patterns or event sourcing. Requires idempotent handlers and conflict resolution strategies.
- **Strong consistency within service boundaries**: ACID transactions confined to single service databases. Cross-service operations use distributed transaction patterns (saga, orchestration) rather than two-phase commit.
- **CQRS separation**: Command and query responsibilities separated. Write models optimized for transactional integrity; read models denormalized and eventually consistent, populated via event streams.

**Data Distribution Patterns:**

- **Database per service**: Polyglot persistence—each service selects appropriate database technology (relational, document, graph, key-value)
- **Event-carried state transfer**: Services publish state changes as events; consuming services maintain local materialized views
- **API composition**: Real-time queries aggregate data from multiple services via synchronous API calls with fallback strategies for partial failures
- **Data lake/warehouse replication**: Asynchronous replication to centralized analytics stores for reporting and batch processing

### Communication Patterns

**Synchronous Communication:**

- **Request-response over HTTP/REST**: Simple integration, high coupling, cascading failures, latency amplification
- **gRPC with Protocol Buffers**: Efficient binary serialization, strongly-typed contracts, HTTP/2 multiplexing, streaming support
- **GraphQL federation**: Unified query interface over multiple services, client-driven data fetching, resolver-based delegation

Synchronous patterns require:

- Circuit breakers to prevent cascading failures
- Timeout and retry policies with exponential backoff
- Bulkhead isolation to contain resource exhaustion
- Service mesh infrastructure for traffic management, retries, and observability

**Asynchronous Communication:**

- **Event-driven messaging**: Services publish domain events to message brokers (Kafka, RabbitMQ, Pulsar); consumers process events independently
- **Command messages**: Explicit service invocation via message queues with guaranteed delivery
- **Event sourcing**: Append-only event log as source of truth; services reconstruct state from event history
- **Change Data Capture (CDC)**: Database transaction logs (e.g., Debezium) stream state changes as events

Asynchronous patterns provide:

- Temporal decoupling—services operate independently across time
- Buffering and backpressure management
- Replay and reprocessing capabilities
- At-least-once or exactly-once delivery semantics (requires idempotent consumers)

### Service Orchestration vs Choreography

**Orchestration**: Central coordinator (saga orchestrator, workflow engine) explicitly invokes services in sequence. Orchestrator maintains transaction state, handles compensations, and retries. Provides visibility into business process execution but introduces a coordination bottleneck and single point of failure.

**Choreography**: Services react to events without central coordination. Each service knows its role and triggers downstream actions by publishing events. Reduces coupling and eliminates orchestrator bottleneck but complicates observability—business process flow emerges from distributed interactions.

Hybrid approaches use orchestration for complex workflows with strict ordering requirements and choreography for loosely coupled domain event propagation.

### Distributed Transaction Management

**Saga Pattern**: Long-running transactions decomposed into local transactions per service with compensating transactions for rollback. Two implementations:

- **Orchestrated saga**: Coordinator directs transaction steps, tracks state, executes compensations on failure
- **Choreographed saga**: Services listen for events, execute local transactions, publish success/failure events

Sagas provide eventual consistency without distributed locks. Require idempotent operations, compensating logic for each step, and handling of semantic rollback (compensations may not restore identical state).

**Two-Phase Commit (2PC)**: Coordinator prepares all participants, then commits if all agree. Blocks on coordinator failure; unsuitable for high-latency networks or long-running transactions. Avoided in microservices due to availability impact.

**Outbox Pattern**: Ensures atomic update of database and message publication. Service writes domain event to outbox table in same local transaction as business data. Separate process polls outbox and publishes to message broker. Provides exactly-once semantics for event publishing.

### Service Discovery and Load Balancing

**Client-Side Discovery**: Clients query service registry (Consul, etcd, ZooKeeper), cache service locations, and select instances using load balancing algorithms (round-robin, least connections, consistent hashing). Clients must implement retry, failover, and health-check logic.

**Server-Side Discovery**: Load balancer queries registry and routes requests. Clients address load balancer endpoint. Simplifies clients but introduces additional hop and potential bottleneck.

**DNS-Based Discovery**: Services registered as DNS records; clients resolve via DNS. Limited load balancing control; relies on DNS TTL for updates; caching complicates rapid instance changes.

**Service Mesh Discovery**: Sidecar proxies (Envoy, Linkerd) handle service discovery, load balancing, and traffic routing. Control plane manages proxy configuration; data plane intercepts all service communication.

### API Gateway and Edge Routing

API Gateway provides single entry point for external clients. Responsibilities include:

- **Request routing**: Map external API paths to internal services
- **Protocol translation**: HTTP/REST to gRPC, WebSocket to message queue
- **Authentication and authorization**: OAuth2, JWT validation, API key management
- **Rate limiting and throttling**: Per-client quotas, circuit breaking for backend services
- **Request aggregation**: Backend-for-frontend pattern—compose multiple service calls into single client response
- **Response transformation**: Filter, project, or aggregate data before returning to client

Gateway patterns:

- **Single gateway**: Monolithic edge service; risk of bottleneck and large blast radius
- **Gateway per client type**: Mobile, web, partner gateways with tailored APIs (Backend-for-Frontend)
- **Micro-gateway per service**: Each team deploys gateway alongside services; increases operational complexity

### Resilience and Fault Isolation

**Circuit Breaker**: Prevents cascading failures by failing fast when downstream service is unhealthy. States: closed (normal operation), open (reject requests immediately), half-open (limited trial requests). Thresholds based on error rate, latency, or request volume.

**Bulkhead Isolation**: Partition resources (thread pools, connection pools, memory) to prevent one service from exhausting shared resources. Limits blast radius of resource leaks or high load.

**Timeout Policies**: All remote calls must have explicit timeouts. Prevents indefinite blocking on slow or unresponsive services. Timeouts should account for p99 latency and include time for retries.

**Retry Policies**: Transient failures handled with exponential backoff and jitter. Idempotent operations safe to retry; non-idempotent operations require idempotency keys or compensation logic.

**Graceful Degradation**: Services provide reduced functionality when dependencies fail. Static fallback responses, cached data, or default values maintain availability. Critical path operations prioritized over optional features.

**Rate Limiting and Backpressure**: Services enforce request rate limits to prevent overload. Clients implement backpressure mechanisms—slow down request rate when detecting high latency or explicit rate limit signals.

### Service Mesh Infrastructure

Service mesh decouples network concerns from application code. Sidecar proxies intercept all traffic; control plane configures proxies centrally.

**Data Plane Capabilities:**

- Transparent service-to-service encryption (mutual TLS)
- Request-level load balancing (least request, consistent hashing, weighted round-robin)
- Automatic retries, timeouts, and circuit breaking
- Traffic splitting for canary deployments and A/B testing
- Distributed tracing header propagation
- Metrics collection (request rates, latencies, error rates)

**Control Plane Functions:**

- Service discovery integration
- Certificate management and rotation
- Traffic policy enforcement (authorization, rate limiting)
- Configuration distribution to sidecar proxies
- Observability aggregation

Service mesh adds latency (proxy hops) and operational complexity (additional infrastructure layer). Justified in large-scale deployments with many polyglot services requiring uniform traffic management and security policies.

### Observability and Distributed Tracing

Microservices require comprehensive observability due to distributed request flows across multiple services.

**Distributed Tracing**: Requests assigned unique trace ID propagated through all service calls. Each service records span (operation duration, service name, metadata). Tracing systems (Jaeger, Zipkin, Tempo) aggregate spans to reconstruct full request path. Enables:

- Latency attribution to specific services
- Identification of cascading failures
- Dependency graph visualization

**Metrics Collection**: Per-service metrics expose request rates, latencies (p50, p95, p99), error rates, resource utilization. Aggregated to dashboards for real-time monitoring. Key metrics:

- Request throughput (requests/sec)
- Error rates (4xx, 5xx by endpoint)
- Latency distributions (percentiles across services)
- Service dependencies and call graphs
- Resource saturation (CPU, memory, connection pools)

**Structured Logging**: Logs include trace IDs and correlation IDs for request reconstruction. Centralized log aggregation (Elasticsearch, Loki) enables cross-service log queries.

**Health Checks**: Services expose liveness and readiness endpoints. Liveness determines if service should be restarted; readiness determines if service can accept traffic. Health checks include dependency status to prevent cascading traffic to unhealthy backend services.

### Deployment and Release Management

**Independent Deployability**: Services deployed independently without coordinating across teams. Requires backward-compatible API changes, version negotiation, or parallel API versions during transitions.

**Blue-Green Deployment**: Deploy new version alongside current version; switch traffic atomically. Enables instant rollback but doubles infrastructure cost during deployment.

**Canary Deployment**: Gradually route traffic to new version (1%, 5%, 25%, 100%). Monitor error rates and latency; rollback if degradation detected. Requires routing infrastructure to split traffic (service mesh, load balancer).

**Feature Flags**: Control feature activation at runtime without redeployment. Flags enable:

- Gradual rollout to user segments
- A/B testing and experimentation
- Emergency kill switches for problematic features
- Decoupling deployment from release

**Rolling Updates**: Incrementally replace service instances. Orchestrators (Kubernetes) manage rollout rate, health checks, and rollback on failure.

### Security and Isolation

**Service-to-Service Authentication**: Mutual TLS authenticates both client and server services. Service identities tied to certificates issued by internal certificate authority. Alternatively, JWT tokens with service identity claims.

**Authorization Policies**: Fine-grained access control per API endpoint or operation. External authorization services (Open Policy Agent) enforce policies based on service identity, request context, and data attributes.

**Network Segmentation**: Services deployed in isolated network segments. Firewalls or network policies restrict communication to explicitly allowed service pairs. Zero-trust networking—no implicit trust based on network location.

**Secret Management**: Credentials, API keys, and certificates stored in secret managers (Vault, AWS Secrets Manager). Services retrieve secrets at runtime; secrets rotated regularly without redeployment.

**API Rate Limiting**: Per-client or per-service quotas prevent abuse and resource exhaustion. Distributed rate limiting requires shared state (Redis) or coordination service.

### Scalability and Partitioning

**Horizontal Scaling**: Services scaled by adding instances. Stateless services scale linearly; stateful services require data partitioning or replication strategies.

**Data Partitioning**: Service data partitioned by key (customer ID, tenant ID, geography). Each partition handled by dedicated service instances. Partition strategies:

- **Range partitioning**: Consecutive keys assigned to partitions; risk of hotspots
- **Hash partitioning**: Hash function distributes keys uniformly; complicates range queries
- **Consistent hashing**: Minimizes data movement when adding/removing partitions

**Read Replicas and Caching**: Read-heavy services use database replicas or caches (Redis, Memcached) to offload read traffic. Writes directed to primary; reads served from replicas with eventual consistency. Cache invalidation strategies (TTL, write-through, event-driven invalidation) trade staleness for performance.

**Autoscaling**: Services automatically scale based on metrics (CPU, memory, request rate, queue depth). Horizontal Pod Autoscaler (Kubernetes) or equivalent. Autoscaling policies account for startup time—scale up proactively, scale down conservatively.

### Failure Modes and Operational Challenges

**Cascading Failures**: Overloaded or slow service causes upstream services to exhaust resources (threads, connections), propagating failure across system. Mitigated by circuit breakers, timeouts, and bulkheads.

**Distributed Debugging**: Failures span multiple services; debugging requires correlated logs, traces, and metrics. Missing trace propagation or inconsistent logging complicates root cause analysis.

**Configuration Drift**: Services deployed with inconsistent configurations lead to subtle bugs. Centralized configuration management (Consul, etcd, ConfigMaps) and version-controlled configurations reduce drift.

**Deployment Complexity**: Coordinating deployments across dozens of services increases operational burden. Requires mature CI/CD pipelines, automated testing, and deployment orchestration.

**Data Migration**: Schema changes in one service may require migration scripts, dual-write periods, or backward-compatible API changes. Breaking changes require coordinated rollout across dependent services.

**Monitoring Alert Fatigue**: Numerous services generate excessive alerts. Requires tuned thresholds, alert aggregation, and on-call runbooks to reduce noise.

**Network Partition Handling**: Services must handle network partitions gracefully. Idempotent operations, retries, and eventual consistency models reduce impact. Split-brain scenarios prevented by consensus protocols (Raft, Paxos) in coordination services.

### Cost and Operational Overhead

Microservices increase infrastructure and operational costs:

- **Infrastructure overhead**: Each service requires compute, storage, and network resources; container orchestration infrastructure
- **Observability infrastructure**: Tracing, logging, and metrics systems at scale require dedicated resources
- **Service mesh overhead**: Sidecar proxies consume CPU and memory per service instance; control plane adds management overhead
- **Team coordination**: Distributed ownership requires inter-team communication protocols, API contracts, and dependency management
- **Testing complexity**: Integration testing requires service virtualization or test environments with all dependencies

Justification requires organizational scale (multiple teams), high deployment velocity, or need for technology heterogeneity. Small teams or infrequent deployments may not justify microservices overhead.

### Related Architectural Patterns

- Event-Driven Architecture
- Service-Oriented Architecture (SOA)
- CQRS (Command Query Responsibility Segregation)
- Event Sourcing
- Saga Pattern
- API Gateway Pattern
- Backend-for-Frontend (BFF)
- Strangler Fig Pattern
- Sidecar Pattern
- Ambassador Pattern
- Circuit Breaker Pattern
- Bulkhead Pattern

---

