## Client-Server Model


### Architectural Characteristics

Asymmetric computational model where clients initiate requests and servers provide responses. Servers maintain authoritative state and enforce business logic; clients consume services through well-defined interfaces. Communication follows request-response semantics over network protocols (HTTP, gRPC, Thrift, custom TCP/binary protocols).

### Scalability Dimensions

**Vertical Scaling:** Single server instance capacity bound by CPU, memory, I/O throughput, and network interface limits. Provides strong consistency guarantees but creates single point of failure and hard capacity ceiling.

**Horizontal Scaling (Stateless Servers):** Multiple identical server instances behind load balancers. Requires externalized session state (distributed cache, database, sticky sessions). Load distribution strategies include round-robin, least-connections, weighted algorithms, consistent hashing for session affinity. Scales read and compute workloads effectively.

**Horizontal Scaling (Stateful Servers):** Requires client-side routing awareness, session affinity mechanisms, or state partitioning schemes. Introduces complexity in maintaining distributed state consistency and handling node failures with in-flight state.

### Consistency and Coordination

Servers act as coordination points enforcing linearizability or sequential consistency for operations within their authority boundary. Multi-server deployments require distributed coordination mechanisms (distributed locks, leader election via Raft/Paxos, consensus protocols) for operations spanning authority boundaries.

Database-backed servers inherit consistency model from underlying storage layer. Caching layers introduce eventual consistency windows and cache invalidation challenges (write-through, write-behind, cache-aside patterns).

### Failure Modes and Isolation

**Server Failure:** Client retries, timeouts, circuit breakers. Requires idempotency guarantees for safe retry semantics. Load balancer health checks and automatic failover for redundant deployments.

**Client Failure:** Server-side resource cleanup, connection timeouts, orphaned transaction handling. Long-running operations require timeout policies and compensation logic.

**Network Partition:** Clients isolated from servers experience total unavailability unless degraded mode with cached data supported. No split-brain risk in pure client-server (servers remain authoritative), but partition between server and backing data store creates availability vs consistency trade-off.

### Security Boundaries

Clear trust boundary between client (untrusted) and server (trusted). Server-side validation, authentication (token-based, certificate-based, session-based), authorization enforcement. Transport security via TLS/mTLS. API gateway patterns for centralized policy enforcement, rate limiting, threat detection.

### Operational Characteristics

**Deployment:** Centralized server deployment simplifies versioning, rolling updates, canary deployments. Client upgrades may be decentralized and asynchronous, requiring backward compatibility maintenance.

**Observability:** Centralized logging, metrics, distributed tracing from server perspective. Client-side telemetry requires aggregation infrastructure.

**Cost Profile:** Server infrastructure costs scale with active user base and request volume. Client-side computation offloading can reduce server load but increases client resource requirements and attack surface.

### Variations

**Thin Client:** Minimal client logic, maximum server authority. Examples: web applications, terminal clients, VDI.

**Thick Client:** Substantial client-side logic, caching, offline capability. Increases complexity in state synchronization and consistency maintenance.

**Connection-Oriented:** Persistent connections (WebSockets, gRPC streaming) for bidirectional communication. Enables server-initiated push, reduces latency, but increases server connection state overhead and complicates horizontal scaling.

---

