## Data-Centric Consistency Models


### Strict Consistency

Absolute time ordering of all operations across all processes. Any read to a data item returns the value of the most recent write according to a global wall-clock time. Requires instantaneous propagation of writes to all replicas, making it physically unachievable in distributed systems due to speed-of-light constraints and lack of perfect clock synchronization.

No distributed system can implement strict consistency in practice. Even single-node systems with multiple cores face challenges due to cache coherence latencies. This model serves primarily as a theoretical upper bound for consistency guarantees.

### Sequential Consistency

All processes observe operations in the same total order, and operations from each individual process appear in that total order in program order. Does not require operations to respect real-time ordering—only that a single, consistent interleaving exists that all nodes agree upon.

**Coordination Requirements:**

- Global coordination point or distributed consensus protocol required to establish total order
- Lamport timestamps or vector clocks insufficient alone; requires agreement protocol
- Typical implementations use Paxos, Raft, or atomic broadcast primitives
- Every operation must wait for coordination before completing

**Replication Protocol Constraints:**

- Primary-backup with synchronous replication to all replicas before acknowledgment
- State machine replication with total order broadcast
- Chain replication with linearizable ordering guarantees

**Performance Characteristics:**

- Write latency proportional to network diameter and consensus rounds
- Read latency depends on implementation: primary reads fast, but stale; consensus reads slow but current
- Throughput limited by coordination bottleneck—single leader or consensus group becomes saturation point
- Cross-datacenter deployments face RTT-bound latency floors (100-300ms typical)

**Scalability Constraints:**

- Does not partition naturally; sharding breaks sequential ordering guarantees across shards
- Horizontal scaling requires partitioning coordination domain or accepting per-partition sequential consistency
- Coordination cost grows with replica count and geographic distribution

**Failure Modes:**

- Coordination service unavailability blocks all writes, potentially all reads
- Network partition forces choice between availability and consistency (CP in CAP)
- Split-brain scenarios require fencing mechanisms or quorum-based access control

### Causal Consistency

Operations that are causally related (happen-before relationship) are observed in the same order by all processes. Concurrent operations (not causally related) may be observed in different orders by different processes.

**Causal Dependency Tracking:**

- Vector clocks: each process maintains vector of logical timestamps, one per process
- Version vectors: per-key causality tracking, more memory-efficient for key-value stores
- Dotted version vectors: combine version vectors with per-operation dots for precise conflict detection
- Explicit dependency graphs: store causal dependencies as metadata, used in systems like COPS, Eiger

**Implementation Strategies:**

- **Causal broadcast:** deliver messages respecting causal order using vector timestamps
- **Dependency tracking with delayed visibility:** writes include dependencies; reads block until dependencies satisfied
- **Session guarantees with sticky sessions:** client-side vector clocks, read-your-writes through session affinity
- **Causal snapshots:** versioned snapshots preserving causal consistency across keys (COPS-GT, ChainReaction)

**Partitioning and Sharding:**

- Causal consistency naturally supports partitioning since causality is a partial order
- Cross-partition causal dependencies require coordination only for causally-related operations
- Non-overlapping causal chains partition independently without coordination

**Metadata Overhead:**

- Vector clock size: O(N) where N = number of processes or replicas
- Grows with system size; mitigation via pruning, bounded vectors, or hierarchical approaches
- Per-object versioning reduces overhead compared to per-replica versioning in large systems

**Replication Topologies:**

- Multi-master with causal consistency protocols (e.g., Bayou, COPS)
- Geo-replicated systems with causal+ consistency (PSI, SNOW theorem variants)
- Eventual consistency as baseline with causal guarantees layered on top

**Conflict Handling:**

- Concurrent writes to same object require conflict resolution (semantic differs from sequential)
- Application-level merge functions, CRDTs, or last-writer-wins with client-side reconciliation
- Causal consistency does not eliminate conflicts; only orders causally-related operations

**Performance Characteristics:**

- Write latency: local replica acknowledgment sufficient if causal dependencies already satisfied
- Read latency: may require waiting for causal dependencies to arrive; otherwise local reads
- Cross-datacenter: significantly lower latency than sequential consistency; no global coordination for concurrent ops
- Throughput: higher than sequential; coordination only on causal chains, not all operations

**Scalability:**

- Scales better than sequential consistency due to partial ordering
- Metadata overhead and dependency tracking complexity limit scalability
- Systems like COPS demonstrate feasibility at datacenter scale with careful engineering

**Failure Modes:**

- Replica unavailability does not block causally-independent operations
- Network partition: causally-independent partitions continue operating; causally-dependent ops may block
- Split-brain: causal consistency alone does not prevent; requires additional mechanisms (quorum, conflict resolution)

**Notable Implementations:**

- COPS (Clusters of Order-Preserving Servers): get transactions with causal consistency across geo-replicated datacenters
- Eiger: extends COPS with stronger write-only transactions
- ChainReaction: causal consistency with atomic visibility for related updates
- MongoDB causal consistency sessions: client-level causal guarantees

### Eventual Consistency

All replicas converge to the same state eventually, given that updates cease and the network heals. No ordering guarantees during convergence period. Weakest consistency model providing useful guarantees.

**Convergence Mechanisms:**

- **Anti-entropy:** periodic state synchronization via replica comparison (Merkle trees, hash exchanges)
- **Gossip protocols:** epidemic-style state propagation with tunable convergence speed
- **Hinted handoff:** temporary storage of writes destined for unavailable replicas
- **Read repair:** detect and correct inconsistencies during read operations
- **Active anti-entropy with version vectors:** detect conflicts and converge via reconciliation

**Conflict Resolution Strategies:**

- Last-write-wins (LWW): timestamp-based, loses concurrent updates, requires synchronized clocks or Lamport timestamps
- Application-specific merge functions: domain logic determines resolution (e.g., shopping cart merges)
- CRDTs (Conflict-free Replicated Data Types): mathematically provable convergence with commutative, associative, idempotent merge operations
- Sibling/multi-value returns: expose conflicts to client for application-level resolution (Dynamo, Riak)

**Replication Protocols:**

- Leaderless replication with quorum reads/writes (Dynamo-style, tunable N/R/W)
- Multi-master with asynchronous replication
- Lazy replication: writes acknowledged locally, propagated asynchronously
- Optimistic replication: assume conflicts rare, handle reactively

**Consistency Anomalies:**

- Stale reads: reads may return outdated values until convergence
- Lost updates: concurrent writes may overwrite each other if conflict resolution loses data
- Non-monotonic reads: subsequent reads may return older values than prior reads (violates session guarantees)
- Causal violations: causally-related operations may appear out of order

**Session Guarantees (Strengthening Eventual Consistency):**

- **Read-your-writes:** client reads reflect its own prior writes (sticky sessions, client-tracked versions)
- **Monotonic reads:** successive reads return non-decreasing state (sticky replicas or version tracking)
- **Monotonic writes:** writes propagate in order from same client (ordering at origin replica)
- **Writes-follow-reads:** writes propagate causally after reads they depend on (causality tracking)

**Performance and Scalability:**

- Lowest write latency: local acknowledgment, no coordination
- Read latency: local reads, but may return stale data
- Highest availability: tolerates network partitions, replica failures without blocking operations
- Horizontal scalability: scales nearly linearly; partitioning trivial as no cross-partition coordination required

**Failure Modes:**

- Prolonged network partitions delay convergence indefinitely
- Replica failures lose recent writes if replication factor not met
- Merge conflicts escalate with concurrent write load; resolution logic becomes application burden
- Semantic anomalies require application-level compensation or eventual consistency intolerance

**Notable Implementations:**

- Amazon Dynamo: tunable quorum-based eventual consistency with vector clocks and hinted handoff
- Apache Cassandra: Dynamo-inspired, tunable consistency levels, eventual consistency default
- Riak: Dynamo clone with sibling resolution and CRDTs
- DynamoDB: managed Dynamo-style database with eventual consistency option

**Trade-off Justification:**

- Use when availability and partition tolerance prioritized over consistency (AP in CAP)
- Suitable for domains tolerating temporary inconsistency: analytics, caching, shopping carts, social feeds
- Unsuitable for financial transactions, inventory with oversell prevention, distributed counters requiring accuracy

### Consistency Model Comparison Matrix

|Model|Ordering Guarantee|Coordination Required|Partition Tolerance|Write Latency|Read Latency|Scalability|Anomalies|
|---|---|---|---|---|---|---|---|
|Strict|Global real-time order|N/A (unimplementable)|No|N/A|N/A|N/A|None (theoretical)|
|Sequential|Global total order|Yes, all operations|No (CP system)|High (consensus)|Medium-High|Low|None if available|
|Causal|Partial order (causal)|Only causally-related ops|Partial|Low-Medium|Low-Medium|Medium-High|Concurrent conflicts|
|Eventual|None during convergence|No|Yes (AP system)|Low (async)|Low (stale OK)|High|All anomalies possible|

### Network Partition Behavior

**Sequential Consistency:**

- Majority partition: continues operating if quorum available
- Minority partition: unavailable for writes, possibly reads depending on implementation
- Requires network partition detection and quorum enforcement to prevent split-brain

**Causal Consistency:**

- Partitions with causally-independent operations continue unaffected
- Operations depending on state from unreachable partition block until healing
- Partial availability: some clients unaffected, others degraded based on causal dependencies

**Eventual Consistency:**

- All partitions continue accepting reads and writes
- Convergence delayed until partition heals
- Conflict resolution burden deferred to post-partition merge phase

### Ordering Guarantees Under Concurrency

**Sequential Consistency:**

- No concurrent operations exist in the model's view; total order subsumes concurrency
- Concurrent client requests serialized into single order globally

**Causal Consistency:**

- Concurrent operations explicitly recognized; no ordering imposed on them
- Different replicas may deliver concurrent operations in different orders
- Applications must tolerate or resolve conflicts from concurrent operations

**Eventual Consistency:**

- Concurrent operations treated identically to any other operations
- No inherent ordering; convergence mechanisms impose order post-hoc

### Relationship to Transactional Isolation Levels

Sequential consistency analogous to serializability in single-node databases but applied to replicated state across nodes. Causal consistency analogous to snapshot isolation with causal dependencies. Eventual consistency weaker than read-uncommitted; no isolation guarantees.

Transactions can be layered on top of consistency models: sequential consistency supports distributed transactions naturally, causal consistency supports causal transactions (e.g., COPS transactions), eventual consistency requires compensating transactions or coordination protocols (e.g., Sagas).

### Hybrid Models and Extensions

**Causal+ Consistency (PSI - Parallel Snapshot Isolation):**

- Causal consistency plus snapshot reads across multiple keys
- Transactional causal consistency with cross-partition atomicity
- Used in systems like Walter, Eiger for stronger guarantees without sequential coordination

**Bounded Staleness:**

- Eventual consistency with quantitative staleness bounds (time or version distance)
- Systems: Azure Cosmos DB consistency levels, PBS (Probabilistically Bounded Staleness)
- Tunable trade-off between consistency strength and latency

**Timeline Consistency:**

- Per-client causality with global prefix properties
- Used in Spanner-like systems for external consistency within bounded uncertainty

**RedBlue Consistency:**

- Operations classified as red (require coordination) or blue (commutative, coordination-free)
- Application-level consistency model selection per operation type
- Maximizes blue operations for performance while maintaining correctness for red operations

### Related Topics

- Linearizability and linearizable consistency
- Client-centric consistency models (read-your-writes, monotonic reads/writes)
- Consistency in distributed transactions (two-phase commit, Paxos Commit, ACID vs BASE)
- CRDTs (Conflict-free Replicated Data Types) and operational transformation
- Quorum systems and tunable consistency (N/R/W parameters)
- CAP theorem, PACELC framework, consistency-latency trade-offs
- Vector clocks, version vectors, dotted version vectors
- State machine replication and atomic broadcast
- Distributed snapshot algorithms (Chandy-Lamport)
- Session guarantees and sticky consistency

---

