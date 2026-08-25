## Architectural Models


Architectural models define the structural organization of distributed system components, their communication patterns, placement strategies, and the fundamental abstractions that govern interactions between computational entities. These models establish the foundational design space for partitioning functionality, managing state, orchestrating communication, and reasoning about system-wide properties including failure modes, performance characteristics, and operational complexity.

### Client-Server Model

Centralizes service provisioning where servers expose well-defined interfaces and clients initiate requests. Server processes maintain authoritative state and business logic while clients remain stateless or maintain minimal local state for UI concerns. Communication follows request-response semantics with servers acting as synchronization points.

**Architectural Characteristics:**

- Single administrative domain for service logic deployment
- Asymmetric roles with servers as resource providers and coordination points
- Vertical scaling pressure on server infrastructure
- Request routing complexity grows with server fleet size
- Session affinity requirements for stateful interactions
- Load balancing operates at connection or request granularity

**Failure Modes:**

- Server unavailability creates total service outage within affected partition
- Cascading failures when server capacity exhaustion causes request timeouts
- Split-brain scenarios require external coordination for leader election
- Client request amplification during retry storms
- State loss on server failure without replication mechanisms

**Scalability Constraints:**

- Server becomes bottleneck for CPU-bound operations
- Network bandwidth saturation at server ingress points
- Connection pooling limits with stateful protocols
- Database connection exhaustion under load
- Geographic distribution requires multi-datacenter server deployment

**Coordination Boundaries:**

- Servers coordinate through shared databases or distributed locks
- Transactional boundaries typically confined to single server process
- Cross-server consistency requires distributed transaction protocols
- Cache invalidation coordination necessary for read-heavy workloads

### Multi-Tier Architecture

Decomposes system functionality into horizontal layers with dedicated responsibilities, typically presentation tier, application/business logic tier, and data tier. Each tier represents independent scaling and deployment boundaries with well-defined interfaces between layers.

**Tier Separation Strategies:**

- Physical separation with network boundaries between tiers
- Process-level isolation with inter-process communication
- Container-based deployment with orchestration platforms
- Serverless function decomposition for application tier

**Data Flow Patterns:**

- Synchronous request propagation through tier hierarchy
- Response aggregation at application tier from multiple data sources
- Caching at intermediate tiers to reduce backend pressure
- Connection pooling between tiers to manage resource utilization

**Consistency Considerations:**

- Cache coherence protocols between presentation and application tiers
- Transactional boundaries spanning application and data tiers
- Eventual consistency for replicated read caches
- Session state synchronization across application tier instances

**Operational Characteristics:**

- Independent scaling of each tier based on resource consumption patterns
- Deployment complexity increases with tier count
- Network latency accumulates across tier boundaries
- Failure in any tier propagates to dependent upper tiers
- Monitoring requires distributed tracing across tier boundaries

### Peer-to-Peer Architecture

Eliminates centralized coordination by distributing responsibilities uniformly across participating nodes. Each peer functions simultaneously as client and server, contributing resources and consuming services from other peers. Overlay network topology determines routing efficiency and fault tolerance characteristics.

**Overlay Topologies:**

- Unstructured overlays with random graph connectivity (Gnutella-style)
- Structured overlays with deterministic routing (DHT-based: Chord, Kademlia, Pastry)
- Hybrid approaches with super-peer hierarchies for indexing
- Hierarchical DHTs for improved lookup latency

**Routing and Discovery:**

- Flooding-based discovery in unstructured networks with TTL constraints
- O(log N) hop routing in structured DHTs through finger tables
- Proximity-aware routing to minimize physical network distance
- Replication-based availability through key-space partitioning

**Consistency and Consensus:**

- Leaderless replication with quorum-based reads and writes
- Eventual consistency as default consistency model
- Vector clocks or version vectors for conflict detection
- Application-level conflict resolution strategies
- Gossip protocols for membership and metadata propagation

**Churn Management:**

- Continuous membership protocol execution for join/leave/failure detection
- Proactive replication to maintain redundancy levels
- Routing table stabilization protocols
- Data migration during node departures

**Failure Isolation:**

- No single point of failure by design
- Network partitions create temporary inconsistent views
- Sybil attack vulnerabilities without admission control
- Eclipse attacks through routing table poisoning

**Scalability Properties:**

- Horizontal scalability through resource contribution
- Logarithmic routing complexity in structured overlays
- Maintenance overhead grows with churn rate
- Load imbalance from non-uniform key distribution

### Service-Oriented Architecture

Organizes system capabilities as independently deployable services exposing standardized interfaces, typically through synchronous RPC or message-based communication. Services encapsulate business capabilities with clear ownership boundaries and technology stack independence.

**Service Granularity:**

- Coarse-grained services aligned with business domains
- Single responsibility per service with minimal cross-service dependencies
- Bounded contexts define service boundaries and data ownership
- Anti-corruption layers between services with incompatible models

**Communication Patterns:**

- Synchronous request-response via REST, gRPC, or GraphQL
- Asynchronous messaging through enterprise service bus (ESB)
- Event-driven integration with event brokers
- Choreography vs orchestration for multi-service workflows

**Service Discovery:**

- Registry-based discovery (Consul, etcd, ZooKeeper)
- DNS-based service resolution
- Client-side vs server-side load balancing
- Health check integration for availability determination

**Transactional Boundaries:**

- Service-local transactions with ACID guarantees
- Distributed transactions via two-phase commit (rare)
- Saga pattern for long-running cross-service transactions
- Compensating transactions for failure recovery

**Failure Handling:**

- Circuit breakers to prevent cascade failures
- Retry policies with exponential backoff and jitter
- Bulkheads for resource isolation between service dependencies
- Fallback mechanisms and graceful degradation

**Operational Complexity:**

- Distributed tracing for request flow visibility
- Centralized logging aggregation
- Service mesh for cross-cutting concerns (mTLS, observability, traffic management)
- API gateway for external access control and protocol translation

### Microservices Architecture

Extends service-oriented principles with fine-grained service decomposition, independent deployment pipelines, decentralized data management, and organizational alignment around service ownership. Emphasizes automation, polyglot persistence, and evolutionary design.

**Service Decomposition:**

- Domain-driven design for service boundary identification
- Subdomain mapping to microservice boundaries
- Database-per-service pattern for data isolation
- Shared-nothing architecture to minimize coupling

**Data Management:**

- Polyglot persistence with service-specific database choices
- Event sourcing for state change audit trails
- CQRS to separate read and write models
- Materialized views for query optimization across services
- Data replication through change data capture (CDC)

**Deployment Architecture:**

- Container-based packaging (Docker) with orchestration (Kubernetes)
- Immutable infrastructure with declarative configuration
- Blue-green or canary deployment strategies
- Feature flags for progressive rollout

**Inter-Service Communication:**

- Synchronous APIs for low-latency request-response
- Asynchronous messaging for event notification and data synchronization
- Service mesh (Istio, Linkerd) for traffic management and security
- API composition patterns (BFF, GraphQL federation)

**Consistency Models:**

- Eventual consistency as primary model
- Saga orchestration or choreography for distributed transactions
- Idempotency requirements for at-least-once delivery
- Conflict resolution strategies for concurrent updates

**Observability Requirements:**

- Distributed tracing across service call chains
- Metrics aggregation for service-level objectives (SLOs)
- Log correlation through trace IDs
- Dependency mapping and service topology visualization

**Scalability Patterns:**

- Independent scaling per service based on load profiles
- Autoscaling based on custom metrics (queue depth, latency)
- Resource quotas and limits for multi-tenancy
- Service throttling and rate limiting

**Failure Domains:**

- Service-level isolation prevents full system failure
- Cascading failure risk from synchronous dependencies
- Timeout and retry tuning critical for stability
- Chaos engineering to validate resilience assumptions

### Event-Driven Architecture

Organizes system behavior around production, detection, and reaction to events representing state changes. Components interact through event notification rather than direct invocation, enabling loose coupling and asynchronous processing.

**Event Backbone:**

- Event broker as central infrastructure (Kafka, Pulsar, EventBridge)
- Topic-based or stream-based event organization
- Partitioning strategy for event ordering and parallelism
- Retention policies for event replay and temporal queries

**Event Flow Patterns:**

- Event notification for triggering downstream actions
- Event-carried state transfer to eliminate query dependencies
- Event sourcing as system of record for state changes
- CQRS with separate event streams for commands and queries

**Consistency Guarantees:**

- At-least-once delivery semantics with idempotent consumers
- Exactly-once processing through transactional outbox or dual writes
- Causal ordering preservation within partition
- Global ordering impossibility across partitions

**Event Schema Evolution:**

- Forward and backward compatibility requirements
- Schema registry for centralized schema management (Confluent, Apicurio)
- Versioning strategies (additive changes, separate topics)
- Consumer contract testing

**Consumer Patterns:**

- Competing consumers for load distribution
- Consumer groups with partition assignment
- Stream processing for stateful aggregations (Kafka Streams, Flink)
- Complex event processing for pattern detection

**Failure Handling:**

- Dead letter queues for poisoned messages
- Retry policies with exponential backoff
- Circuit breakers for downstream dependencies
- Event replay for recovery from processing failures

**Scalability Characteristics:**

- Producer throughput limited by broker capacity and partitioning
- Consumer parallelism determined by partition count
- Broker replication for durability and availability
- Geographic distribution through multi-datacenter replication

### Layered Architecture

Organizes components into hierarchical layers where each layer provides services to the layer above and consumes services from the layer below. Enforces unidirectional dependencies and encapsulates complexity at each abstraction level.

**Layer Responsibilities:**

- Infrastructure layer: hardware abstraction, OS services, runtime
- Persistence layer: data access, caching, transaction management
- Domain layer: business logic, domain models, invariant enforcement
- Application layer: use case orchestration, workflow coordination
- Presentation layer: protocol adaptation, serialization, authentication

**Dependency Management:**

- Strict upward dependencies prevent circular references
- Dependency inversion for testability and layer substitution
- Interface segregation at layer boundaries
- Pluggable implementations through adapter patterns

**Cross-Cutting Concerns:**

- Logging, monitoring, security enforcement at multiple layers
- Aspect-oriented programming or middleware for orthogonal concerns
- Context propagation through layer boundaries

**Distribution Considerations:**

- Physical layer separation introduces network partitioning
- Transaction boundaries complicate distributed layer coordination
- Latency accumulation across remote layer invocations
- Caching strategies at multiple layers create consistency challenges

### Microkernel Architecture

Centralizes minimal core functionality in a stable kernel with extensibility through plug-in components. Plugins register with kernel and receive events or requests based on routing rules. Common in platform systems and applications requiring customization.

**Kernel Responsibilities:**

- Plugin lifecycle management (discovery, loading, initialization, shutdown)
- Event routing and dispatch to registered plugins
- Resource management and isolation between plugins
- API stability and backward compatibility guarantees

**Plugin Architecture:**

- Well-defined extension points and interfaces
- Dependency injection for plugin registration
- Plugin isolation through separate class loaders or processes
- Versioning and compatibility checking

**Communication Patterns:**

- Synchronous plugin invocation through kernel APIs
- Event-driven plugin activation
- Inter-plugin communication mediated by kernel
- Shared memory or message passing between plugins

**Distribution Challenges:**

- Plugin deployment coordination across multiple nodes
- Configuration synchronization for plugin activation
- Version skew between kernel and plugins
- Remote plugin invocation overhead

### Space-Based Architecture

Eliminates database as synchronization bottleneck by maintaining application state in distributed in-memory data grids. Processing units operate on replicated data partitions with eventual synchronization to persistent storage.

**Core Components:**

- Processing units: stateless compute with in-memory data access
- Virtualized middleware: transparent data replication and routing
- Data pumps: asynchronous persistence to backing databases
- Messaging grid: inter-unit communication and coordination

**Data Distribution:**

- Partitioned replication across processing units
- Consistent hashing for partition assignment
- Partition migration for load balancing
- Near-cache for frequently accessed data

**Consistency Model:**

- Primary-backup replication within partition
- Eventual consistency across partitions
- Write-behind caching to database
- Conflict-free replicated data types (CRDTs) for convergence

**Scalability Properties:**

- Linear horizontal scaling through processing unit addition
- Memory capacity as primary constraint
- Network bandwidth for replication and synchronization
- Database becomes archival store rather than bottleneck

**Failure Recovery:**

- Partition replicas provide high availability
- Processing unit failure triggers partition reassignment
- Data loss window determined by write-behind interval
- Recovery from persistent storage during full partition loss

### Related Topics

- Consensus Protocols (Raft, Paxos, ZAB)
- Replication Topologies
- Partitioning Strategies
- Service Mesh Architecture
- Event Sourcing and CQRS
- Saga Pattern
- API Gateway Pattern
- Backend for Frontend (BFF)
- Bulkhead Pattern
- Circuit Breaker Pattern
- Sidecar Pattern
- Ambassador Pattern
- Anti-Corruption Layer

---

