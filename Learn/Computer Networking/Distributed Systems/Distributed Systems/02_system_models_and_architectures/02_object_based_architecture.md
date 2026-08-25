## Object-Based Architecture


Object-based architecture organizes distributed systems around encapsulated computational entities (objects) that expose well-defined interfaces and maintain internal state. Objects interact through method invocations, which may be local or remote, with location transparency as a primary design goal. This architecture emerged from object-oriented programming paradigms extended to distributed environments.

### Core Architectural Elements

**Object Identity and References** Objects possess globally unique identifiers that remain invariant across migrations, replications, or lifecycle changes. Object references serve as capabilities—unforgeable tokens that grant invocation rights. Reference types include:

- Direct references containing network endpoints (IP:port)
- Indirect references requiring name service resolution
- Persistent references surviving object restarts
- Transient references bound to specific activation instances

**Interface Definition and Contracts** Interfaces define operation signatures, parameter types, exception semantics, and behavioral contracts. Interface Definition Languages (IDLs) provide language-neutral specifications supporting:

- Synchronous request-response invocations
- Asynchronous one-way operations
- Streaming operations with flow control
- Typed exceptions and error propagation

**Object Lifecycle Management** Objects transition through states: uninstantiated, active, passive (swapped), and terminated. Lifecycle management includes:

- Activation: Loading persistent state and binding to execution context
- Passivation: Serializing state and releasing computational resources
- Migration: Relocating active objects across nodes
- Garbage collection: Distributed reference counting or tracing

### Distribution Mechanisms

**Remote Method Invocation (RMI)** RMI abstracts network communication as method calls. Implementation layers:

- Stub (client proxy): Marshals arguments, transmits requests, unmarshals results
- Skeleton (server proxy): Unmarshals requests, invokes implementation, marshals results
- Transport layer: Manages connections, retries, timeouts

Invocation semantics:

- At-most-once: Idempotent operations with duplicate suppression
- At-least-once: Non-idempotent operations with potential retries
- Exactly-once: Requires distributed transactions (expensive)

**Parameter Passing Semantics**

- Pass-by-value: Deep copy of object graphs (default for non-remote objects)
- Pass-by-reference: Remote references enabling callback mechanisms
- Pass-by-move: Ownership transfer eliminating network hops
- Copy-on-write: Lazy replication with invalidation protocols

**Location Transparency and Binding** Clients invoke methods without knowledge of object physical location. Binding strategies:

- Static binding: Compile-time resolution (fastest, inflexible)
- Dynamic binding: Runtime name service lookup (flexible, latency overhead)
- Late binding: On-demand resolution with caching
- Callback binding: Bidirectional reference establishment

### State Management and Consistency

**Object State Distribution**

- Centralized state: Single authoritative copy (strong consistency, single point of failure)
- Replicated state: Multiple copies with synchronization (availability, consistency challenges)
- Partitioned state: Sharded across objects (scalability, cross-partition operations expensive)

**Consistency Models**

- Sequential consistency: Operations appear in program order
- Causal consistency: Causally related operations ordered globally
- Eventual consistency: Replicas converge without ordering guarantees
- Strong consistency: Linearizability through distributed locks or transactions

**Concurrency Control**

- Pessimistic locking: Two-phase locking (2PL), deadlock detection required
- Optimistic concurrency: Timestamp ordering, conflict detection on commit
- Transactional memory: Software transactional memory (STM) for object state
- Lock-free algorithms: Compare-and-swap (CAS) on distributed registers

### Scalability and Performance

**Partitioning Strategies**

- Functional decomposition: Objects partitioned by business capability
- Domain-based sharding: Partitioning by data affinity (e.g., customer ID)
- Hash-based distribution: Consistent hashing for uniform load distribution
- Range-based partitioning: Ordered key ranges enabling range queries

**Replication Topologies**

- Primary-backup: Single writable primary, read-only replicas
- Multi-primary: Concurrent writes with conflict resolution
- Quorum-based: Read/write quorums satisfying R + W > N
- Chain replication: Linearizable operations with tail reads

**Caching and Memoization**

- Client-side caching: Cached remote references and results
- Server-side caching: Memoized computation results
- Distributed caching: Coherent caches with invalidation protocols
- Cache consistency: Lease-based expiration or callback invalidation

### Failure Handling and Resilience

**Failure Detection**

- Heartbeat mechanisms: Periodic liveness probes
- Timeout-based detection: Configurable RPC timeouts
- Failure detector oracles: Eventually perfect failure detectors (◇P)
- Gossip protocols: Epidemic failure dissemination

**Failure Semantics**

- Object crashes: State lost unless checkpointed
- Network partitions: Split-brain scenarios requiring quorum protocols
- Byzantine failures: Malicious or corrupted object behavior
- Cascading failures: Dependency chains amplifying faults

**Recovery Mechanisms**

- Checkpointing: Periodic state snapshots to persistent storage
- Logging: Write-ahead logs (WAL) for replay
- Replication: Failover to secondary replicas
- Exception propagation: Remote exceptions marshaled to callers

**Degradation Strategies**

- Circuit breakers: Preventing cascading failures through fail-fast
- Bulkheads: Isolating failure domains via resource partitioning
- Timeouts and retries: Exponential backoff with jitter
- Graceful degradation: Fallback to reduced functionality

### Coordination and Synchronization

**Distributed Locking**

- Centralized lock managers: Single lock server (bottleneck, SPOF)
- Distributed lock services: Chubby, ZooKeeper, etcd (consensus-based)
- Lock-free coordination: Compare-and-swap on shared registers
- Fencing tokens: Monotonic tokens preventing zombie locks

**Consensus Protocols**

- Paxos: Multi-phase consensus with leader election
- Raft: Understandable consensus with log replication
- Multi-Paxos: Steady-state optimization eliminating prepare phase
- Fast Paxos: Single-round-trip consensus under contention-free scenarios

**Barriers and Synchronization Primitives**

- Distributed barriers: Coordinating object groups at synchronization points
- Semaphores: Limiting concurrent access to shared resources
- Condition variables: Blocking objects pending state predicates
- Monitors: Mutual exclusion with condition synchronization

### Communication Patterns

**Synchronous Invocation**

- Blocking RPC: Client blocks pending response
- Futures/Promises: Asynchronous result handles
- Request-reply queues: Decoupled invocation through messaging

**Asynchronous Messaging**

- One-way invocations: Fire-and-forget semantics
- Callbacks: Bidirectional asynchronous communication
- Event notifications: Publish-subscribe for state changes

**Streaming**

- Server streaming: Object pushes multiple responses
- Client streaming: Client sends multiple requests
- Bidirectional streaming: Full-duplex communication

### Naming and Discovery

**Naming Services**

- Hierarchical namespaces: Directory-structured name resolution
- Flat namespaces: DHT-based key-value stores (Chord, Kademlia)
- Attribute-based naming: Querying objects by properties

**Service Discovery**

- Static configuration: Pre-configured object registries
- Dynamic registration: Objects register endpoints on startup
- Heartbeat-based liveness: Periodic registration renewal
- DNS-based discovery: SRV records for service endpoints

**Name Resolution**

- Iterative resolution: Client performs multi-hop lookups
- Recursive resolution: Name service performs lookups on behalf
- Caching: TTL-based cached name resolutions
- Replication: Replicated name services for availability

### Security and Isolation

**Authentication**

- Mutual authentication: Bidirectional identity verification
- Certificate-based: X.509 certificates with PKI
- Token-based: JWT or opaque tokens for session management
- Kerberos: Ticket-granting for distributed authentication

**Authorization**

- Capability-based: Object references as unforgeable capabilities
- Access control lists (ACLs): Per-object permission matrices
- Role-based access control (RBAC): Permission assignment via roles
- Attribute-based access control (ABAC): Policy-driven authorization

**Confidentiality and Integrity**

- Transport encryption: TLS/mTLS for channel security
- Object-level encryption: End-to-end encrypted state
- Message authentication codes (MACs): Integrity verification
- Digital signatures: Non-repudiation of invocations

**Isolation**

- Process isolation: Separate address spaces per object
- Sandboxing: Restricted execution environments (seccomp, capabilities)
- Resource quotas: CPU, memory, I/O limits per object
- Tenant isolation: Multi-tenancy with noisy neighbor mitigation

### Observability

**Distributed Tracing**

- Request correlation: Trace IDs propagated across invocations
- Span hierarchies: Parent-child relationships modeling call graphs
- Sampling strategies: Head-based or tail-based sampling
- Context propagation: Baggage for cross-cutting concerns

**Metrics**

- Invocation latency: Percentiles (p50, p95, p99) per method
- Throughput: Requests per second per object
- Error rates: Failure ratio by exception type
- Resource utilization: CPU, memory, network per object

**Logging**

- Structured logging: JSON or key-value formatted logs
- Log aggregation: Centralized log collection and indexing
- Correlation IDs: Linking logs across distributed invocations
- Log levels: Dynamic verbosity adjustment

### Operational Characteristics

**Deployment Models**

- Static deployment: Pre-provisioned object placements
- Dynamic placement: Load-based object migration
- Co-location: Affinity-based placement reducing network hops
- Edge deployment: Object placement near clients (CDN-like)

**Versioning and Evolution**

- Interface versioning: Semantic versioning with backward compatibility
- Rolling upgrades: Gradual object replacement
- Canary deployments: Incremental rollout with monitoring
- Blue-green deployments: Parallel environments with traffic switching

**Resource Management**

- Thread pools: Bounded concurrency per object
- Connection pools: Reused network connections
- Object pools: Recycled inactive objects
- Memory management: Heap limits, GC tuning

### Trade-offs and Limitations

**CAP and PACELC**

- Strong consistency: Reduced availability under partitions (CA or CP)
- Eventual consistency: High availability, complex conflict resolution (AP)
- PACELC: Latency-consistency trade-off even without partitions

**Performance Bottlenecks**

- Serialization overhead: Marshaling/unmarshaling latency
- Network round trips: Chatty interfaces amplifying latency
- Lock contention: Coarse-grained locking limiting concurrency
- Garbage collection: Stop-the-world pauses impacting latency

**Operational Complexity**

- Distributed debugging: Lack of global visibility
- Configuration management: Coordination across many objects
- Capacity planning: Unpredictable load patterns
- Upgrade coordination: Maintaining compatibility during rollouts

### Related Architectures and Patterns

- Component-Based Architecture
- Service-Oriented Architecture (SOA)
- Microservices Architecture
- Actor Model
- CORBA (Common Object Request Broker Architecture)
- DCOM (Distributed Component Object Model)
- Java RMI
- REST over HTTP (resource-oriented)
- gRPC (method-oriented RPC)
- Distributed Shared Memory (DSM)

---

