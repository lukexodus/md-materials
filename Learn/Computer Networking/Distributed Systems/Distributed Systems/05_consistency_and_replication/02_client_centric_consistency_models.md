## Client-Centric Consistency Models


Client-centric consistency models define consistency guarantees from the perspective of individual clients interacting with a distributed data store, rather than requiring global ordering or coordination across all replicas. These models relax traditional strong consistency to enable higher availability, lower latency, and better partition tolerance while providing meaningful guarantees to application developers about what a client observes across operations.

### Monotonic Read Consistency

A client that reads value `v` at logical time `t` will never subsequently read a value written before `t` from the same data item, regardless of which replica serves the read. If a client reads version `v_i`, all future reads by that client return `v_i` or a later version `v_j` where `j > i`.

**Implementation Mechanisms:**

- **Session Tokens/Version Vectors:** Client maintains a version vector or logical timestamp representing the latest observed state. Each read request includes this token; replicas must serve data at least as recent as the token indicates.
- **Sticky Sessions:** Route all client requests to the same replica or replica set, leveraging replica-local monotonicity. Requires session affinity at load balancer or client library level.
- **Read-Your-Writes Tracking:** Client tracks write timestamps; read requests specify minimum acceptable version. Replicas reject reads that cannot satisfy the monotonicity constraint, triggering retry against updated replicas or blocking until replication catches up.

**Failure Modes:**

- Session token loss during client failure requires reestablishing baseline, potentially violating monotonicity across client restart.
- Replica lag exceeding timeout thresholds forces reads to fail or violate monotonicity when falling back to stale replicas.
- Network partitions may isolate clients from replicas containing sufficiently recent state, degrading availability.

**Latency-Consistency Trade-offs:**

Enforcing monotonic reads introduces latency overhead when client observes version `v_i` but target replica only has `v_j` where `j < i`. System must either block until replication brings replica to `v_i`, redirect to replica with `v_i`, or fail the read. Blocking increases tail latency; redirection increases cross-datacenter traffic; failure reduces availability.

### Monotonic Write Consistency

A client's write operations complete in the order issued by that client, even if executed against different replicas. If client issues `write(x, v1)` followed by `write(x, v2)`, then `v2` causally depends on `v1` and all replicas eventually apply `v1` before `v2`.

**Implementation Mechanisms:**

- **Client-Side Write Sequencing:** Client library assigns monotonically increasing sequence numbers to writes. Each write includes previous write's sequence number. Replicas enforce causal ordering by deferring writes with gaps in sequence.
- **Primary-Per-Client:** Assign each client session a primary replica that serializes all writes from that client. Primary propagates writes with dependency metadata to other replicas.
- **Logical Clocks:** Client attaches Lamport timestamp or vector clock to each write. Replicas use causal ordering protocol to ensure writes apply in dependency order.

**Replication Protocol Considerations:**

- **Asynchronous Replication:** Primary acknowledges write immediately; background replication propagates to secondaries with dependency metadata. Fast but risks violating monotonicity if primary fails before replication completes.
- **Chain Replication Variant:** Writes flow through chain of replicas in client-specific order, each replica applying and forwarding to next. Head acknowledges to client after all replicas in chain apply.
- **Conflict Resolution:** Concurrent writes from same client must be prevented at source (client serialization) or detected and rejected at replicas (sequence gap detection).

**Coordination Overhead:**

Each write may require predecessor write's acknowledgment before proceeding, introducing sequential bottleneck. Multi-datacenter deployments amplify latency as cross-region write dependency chains accumulate. Write pipelining reduces latency but complicates failure recovery.

### Read Your Writes

A client always observes its own previous writes. After client writes `v` to data item `x`, any subsequent read of `x` by that client returns `v` or a later version, never an earlier version.

**Implementation Mechanisms:**

- **Write Token Propagation:** Write operations return token encoding written version. Client includes token in subsequent read requests. Replicas serve reads only if local state includes the specified version.
- **Session-Local Read-After-Write:** Client library caches written values with TTL. Subsequent reads check local cache before querying replicas, serving from cache if present and unexpired.
- **Master-Redirect Reads:** Writes go to primary/master replica. Reads following writes also route to same primary until replication lag window closes. Requires replication lag estimation or explicit replication acknowledgment.

**Hybrid Approaches:**

- **Conditional Replication Wait:** Client specifies write operation should block until replication reaches N replicas or timeout expires. Subsequent reads can safely query any of the N replicas.
- **Quorum Reads After Writes:** Write to W replicas, read from R replicas where R + W > N ensures overlap. Guarantees read-your-writes if client includes write version in read quorum request.

**Availability Impact:**

Read-your-writes reduces availability because reads must contact replicas that have received specific writes. Network partitions or replica failures may make such replicas unreachable. Fallback strategies include violating consistency (serving stale), blocking (waiting for replication), or failing (returning error).

### Writes Follow Reads

If client reads value `v` from data item `x`, then issues a write `w` to any data item, all replicas apply writes that produced `v` before applying `w`. Ensures writes causally depend on observed state.

**Implementation Mechanisms:**

- **Causal Context Propagation:** Read operations return causal context (vector clock, version vector, dependency set) representing all writes that contributed to returned value. Client includes this context in subsequent writes. Replicas defer applying writes until all dependencies satisfied.
- **Dependency Tracking Metadata:** Each data version carries metadata identifying predecessor versions across all accessed keys. Writes include union of all read dependencies. Replication protocol respects dependency constraints.
- **Session Causality Tokens:** Client maintains session token accumulating causal dependencies from all reads. Write requests carry token; replicas ensure all operations in token's dependency set have been applied locally before applying write.

**Cross-Key Dependency Challenges:**

Writes-follow-reads across multiple keys creates complex dependency graphs. Replica must track dependencies spanning arbitrary key sets, requiring sophisticated metadata storage and dependency resolution. Garbage collection of old dependency metadata requires coordination to ensure all replicas agree on which dependencies are obsolete.

**Partition and Sharding Complications:**

When keys involved in reads and writes reside on different shards/partitions, dependency metadata must traverse partition boundaries. Requires either cross-partition dependency tracking (high coordination cost) or restricting writes-follow-reads to single-partition scope (limits applicability).

**Distributed Deadlock Potential:**

Circular dependencies across client sessions can create distributed deadlock: client A reads X, client B reads Y, client A writes Y (waits for X to propagate), client B writes X (waits for Y to propagate). Detection requires distributed cycle detection or timeout-based deadlock breaking with retry.

### Architectural Integration Points

**Client Library Responsibilities:**

Client-centric consistency requires stateful client libraries maintaining:

- Session identifiers and tokens
- Version vectors or logical timestamps
- Write sequence numbers
- Causal dependency metadata
- Cached write versions for read-your-writes optimization

Client library complexity increases significantly compared to stateless clients. Library must handle token persistence across client restarts, token synchronization for multi-process clients sharing session, and token size growth mitigation.

**Replica-Side State Management:**

Replicas maintain:

- Per-client session state (latest observed version, write sequence)
- Pending write queue with unsatisfied dependencies
- Replication lag metrics for routing decisions
- Dependency graph for causal ordering enforcement

Memory overhead scales with active client session count and dependency graph complexity. Requires session timeout and garbage collection mechanisms.

**Coordination-Free vs. Coordination-Required Operations:**

Client-centric models enable coordination-free reads and writes within consistency constraints. Operations requiring cross-client coordination (strong consistency, linearizability, distributed transactions) still necessitate consensus protocols or locking, layered atop client-centric substrate.

### Hybrid Consistency Architectures

**Mixed Consistency Levels:**

Systems commonly implement multiple consistency levels, allowing applications to select per-operation:

- Strong consistency (linearizable, serializable) for critical operations
- Client-centric consistency for session-bound operations
- Eventual consistency for read-heavy, latency-sensitive operations

Requires consistent model definition to prevent anomalies when operations at different levels interact on same data.

**Consistency Ratcheting:**

Clients may upgrade consistency guarantees mid-session (eventual → client-centric → strong) but downgrading risks violating already-established guarantees. Ratchet-only policies simplify reasoning but reduce flexibility.

**Geographic Consistency Domains:**

Multi-region deployments may implement strong client-centric consistency within regions (low-latency session affinity, synchronous replication) while relaxing to eventual consistency across regions (asynchronous geo-replication). Clients crossing region boundaries must handle consistency level transitions.

### Failure Recovery and Session Continuity

**Client Failover:**

Client library failure loses in-memory session state (tokens, sequence numbers, dependencies). Recovery strategies:

- **Persistent Session Store:** Externalize session state to durable storage (Redis, etcd), restore on client restart. Adds latency and external dependency.
- **Server-Side Session Reconstruction:** Replicas maintain authoritative session state, client requests session state on reconnection. Requires replica session persistence and cross-replica session replication.
- **Conservative Restart:** New client session starts with empty state, sacrificing consistency guarantees until sufficient operations re-establish causal context.

**Replica Failover:**

Primary replica failure during write operation risks lost sequence numbers or dependency metadata. Backup replicas must maintain equivalent state or detect and recover gaps. Chain replication, multi-primary writes, or consensus-backed metadata provide durability at cost of increased write latency.

**Split-Brain Prevention:**

Network partition may allow client to observe state from one partition, then issue write to different partition violating writes-follow-reads. Requires partition-aware routing preventing cross-partition reads followed by writes, or fencing mechanisms ensuring partition membership consensus.

### Performance Optimization Strategies

**Batched Dependency Propagation:**

Accumulate multiple operation dependencies, propagate compressed representation (bitmap, bloom filter, delta-encoded vector clock) reducing metadata overhead. Increases dependency resolution latency but decreases per-operation cost.

**Speculative Execution:**

Replicas speculatively apply writes with unsatisfied dependencies, rolling back if dependencies never materialize. Reduces latency for dependency chains at cost of wasted work and rollback complexity.

**Hierarchical Session Tokens:**

Structure tokens as tree or DAG rather than flat set, enabling partial dependency satisfaction and incremental token updates. Reduces token size growth and comparison overhead.

**Adaptive Consistency:**

Monitor replication lag, network conditions, failure rates. Dynamically relax consistency guarantees (e.g., temporarily skip monotonic read enforcement) during degraded conditions, alerting applications to consistency violations. Improves availability at cost of consistency.

### Security and Isolation Considerations

**Session Hijacking:**

Session tokens enable impersonation if intercepted. Requires token encryption, mutual authentication, and token binding to client identity. Token replay attacks necessitate nonce or timestamp-based freshness checks.

**Cross-Tenant Isolation:**

Multi-tenant systems must prevent session tokens from one tenant influencing consistency of another tenant's operations. Requires tenant-scoped namespacing in dependency metadata and session state partitioning.

**Denial of Service via Dependency Complexity:**

Malicious clients may generate pathological dependency graphs (dense, circular, excessively large) consuming replica memory and CPU during dependency resolution. Requires rate limiting on dependency graph growth, circuit breakers on dependency resolution depth, and per-client resource quotas.

### Observability and Debugging

**Consistency Violation Detection:**

Instrumenting consistency model violations requires capturing:

- Operation timelines with client-assigned sequence numbers
- Observed versions and causal contexts per operation
- Replica state at operation time

Offline analysis correlates timelines across clients and replicas, detecting monotonicity violations, read-your-writes failures, or causality inversions.

**Latency Attribution:**

Decompose operation latency into:

- Client-side token preparation
- Network transmission
- Replica-side dependency waiting
- Local operation execution
- Replication coordination

Identifies consistency enforcement as latency bottleneck vs. other factors.

**Session State Monitoring:**

Track per-session metrics: token size growth rate, dependency graph complexity, pending operation queue depth, consistency violation frequency. Alerts on anomalous sessions indicate application bugs or attacks.

### CAP and PACELC Positioning

Client-centric consistency occupies middle ground:

- **CAP:** Favors availability and partition tolerance over strong consistency. Reads may fail or block during partitions if no replica satisfies client's consistency constraints, but system remains available for writes and eventually-consistent reads.
- **PACELC:** Sacrifices latency for consistency during normal operation (E→C) by requiring replica selection and dependency checking. During partition (P), favors availability (A) over consistency, allowing degraded operations.

Tunable per-model: monotonic reads has lower latency and higher availability than writes-follow-reads due to simpler dependency tracking.

### Related Distributed Consistency Topics

- Causal Consistency
- Session Guarantees in Replicated Systems
- Eventual Consistency Models
- Timeline Consistency
- PRAM Consistency (Pipelined RAM)
- Bayou System Architecture
- Vector Clocks and Version Vectors
- Conflict-Free Replicated Data Types (CRDTs)
- Quorum-Based Consistency Protocols
- Consistent Hashing and Replication Topology

---

