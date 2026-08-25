## Active Replication


Active replication executes each operation on all replicas simultaneously, maintaining identical state across all nodes through deterministic execution of the same sequence of operations. Each replica processes incoming requests independently, applying state transitions in a coordinated order to achieve consistency without requiring primary-secondary delegation.

### Execution Model

All replicas execute every operation rather than replicating state deltas or logs. Client requests are multicast to all replicas, which process them concurrently. Deterministic execution guarantees that given identical initial state and identical input sequence, all replicas produce identical outputs and reach identical final states. Non-deterministic operations (timestamps, random number generation, thread scheduling) must be eliminated or coordinated to maintain replica equivalence.

### Request Ordering and Atomic Broadcast

Total order broadcast ensures all replicas receive and process operations in identical sequence. Atomic broadcast protocols (consensus-based multicast, view-synchronous group communication) deliver messages with ordering guarantees. Paxos-based or Raft-based total order multicast layers provide safety properties: if any replica delivers message m before message n, all replicas deliver m before n.

Virtual synchrony models provide process group membership views synchronized with message delivery. View changes (reflecting replica failures or additions) are totally ordered with respect to application messages, ensuring all operational replicas transition through identical membership configurations while processing identical operation sequences.

### Determinism Requirements

Replica determinism is critical. Sources of non-determinism must be controlled:

**Temporal non-determinism**: System clock reads, timeout expirations, and time-based computations produce divergent results across replicas. Coordination requires timestamps to be part of the totally ordered input, not sampled locally.

**Concurrency non-determinism**: Thread scheduling, lock acquisition order, and race conditions create execution path divergence. Single-threaded execution or deterministic concurrency models (deterministic locking schedules, lock-step parallel execution) enforce identical execution traces.

**External input non-determinism**: Random number generation, hardware counters, and environmental inputs must be generated once and replicated as part of the coordinated input stream.

**Implementation-specific non-determinism**: Floating-point arithmetic variations, hash table iteration order, memory allocation addresses, and compiler optimizations that affect observable behavior require standardization across replicas.

### State Machine Replication

Active replication implements replicated state machines where each replica is a deterministic automaton. State transitions are functions of current state and input operation: `state' = δ(state, operation)`. Total order delivery ensures all replicas apply operations in identical sequence, maintaining state equivalence through deterministic transition functions.

Commands (state-modifying operations) and queries (read-only operations) are both processed through the total order layer in strict active replication. Optimizations may allow local query execution on any replica if linearizability is not required, trading consistency for read latency.

### Fault Tolerance Properties

Active replication tolerates **f** crash failures with **f+1** replicas under fail-stop assumptions. Any surviving replica holds complete system state and can continue servicing requests. Byzantine fault tolerance requires **3f+1** replicas to mask **f** Byzantine failures, as malicious replicas may produce arbitrary outputs requiring majority voting.

Replica recovery requires state transfer from operational replicas. Recovering replicas obtain current state snapshot and join the totally ordered message stream at a known position. State transfer protocols must handle concurrent operation application during transfer, typically through snapshot isolation or checkpoint-based resumption.

### Coordination Overhead

All replicas participate in request processing, multiplying computational cost by replica count. Network overhead scales with multicast fanout. Coordination latency includes atomic broadcast latency (typically 1-2 RTTs for Paxos/Raft-based ordering) plus execution time.

For read-heavy workloads, active replication amplifies unnecessary computation as all replicas execute queries. For write-heavy workloads with low contention, parallel execution across replicas provides no throughput benefit while consuming proportionally more resources.

### Consistency Semantics

Active replication provides **linearizability** by default when clients observe responses from any replica: operations appear to execute atomically at some point between invocation and response, with total order matching real-time ordering. All replicas process operations in identical order, producing externally consistent views.

Sequential consistency is guaranteed as program order is preserved per client and all replicas observe identical total operation order. Causal consistency follows from sequential consistency. Serializability is achieved for transactional systems if transaction operations are totally ordered.

### Failure Detection and View Changes

Group membership protocols integrate with atomic broadcast to coordinate replica addition, removal, and suspected failure handling. View changes represent membership reconfiguration points where the set of active replicas transitions atomically.

Failure detectors (heartbeat-based, timeout-based) identify suspected crashed replicas. Suspected replicas are excluded from subsequent views through coordinated view change protocols. False suspicions (network partitions misidentified as failures) require careful handling to prevent premature replica exclusion.

Partitionable group communication models allow multiple partitions to operate independently during network splits, requiring partition merge protocols and conflict resolution when connectivity is restored. Primary partition models designate one partition as authoritative, sacrificing availability in minority partitions.

### Performance Characteristics

**Throughput**: Limited by slowest replica (stragglers), as all replicas must process all operations. Heterogeneous replica performance creates bottlenecks. Throughput does not scale with replica count.

**Latency**: Write latency includes atomic broadcast coordination plus maximum replica execution time. Read latency matches write latency unless optimizations permit local reads. Cross-datacenter deployments face geographic coordination penalties.

**Resource utilization**: CPU and memory consumption scales linearly with replica count for identical workload processing. Active replication trades resource efficiency for availability and fault tolerance.

### Byzantine Fault Tolerance Extensions

Byzantine active replication requires quorum-based output agreement. Clients collect responses from multiple replicas and accept values agreed upon by **2f+1** replicas (assuming **3f+1** total replicas). Byzantine agreement protocols (PBFT, HotStuff) provide atomic broadcast with Byzantine fault tolerance through multi-phase voting.

Replicas authenticate messages cryptographically to prevent forgery. Clients verify replica signatures and enforce quorum agreement rules. Computational overhead increases significantly due to cryptographic operations and multi-round agreement protocols.

### Optimizations and Variants

**Speculative execution**: Replicas execute operations optimistically before total order confirmation, rolling back on ordering conflicts. Reduces latency when operation commutativity or low contention makes conflicts rare.

**Batching**: Atomic broadcast batches multiple operations into single coordination round, amortizing ordering overhead across operations. Increases throughput at the cost of increased latency for individual operations.

**Read-only optimizations**: Queries bypass atomic broadcast when relaxed consistency is acceptable. Leases or quorum reads provide bounded staleness guarantees without full coordination.

**Semi-active replication**: Primary replica executes operations and multicasts execution results (state deltas, return values) rather than inputs. Reduces computational overhead on backups while maintaining availability properties. Requires careful handling of primary failures and non-deterministic execution state.

### Comparison with Passive Replication

Passive (primary-backup) replication designates one primary that executes operations and replicates state changes to backups. Active replication distributes execution across all replicas. Passive replication offers better resource efficiency (only primary executes) and simpler determinism requirements (primary's execution defines state). Active replication provides faster failover (no leader election required) and load distribution for read-heavy workloads when local reads are permitted.

### Operational Failure Modes

**Divergence from non-determinism**: Uncaught non-deterministic behavior causes replicas to diverge silently. Detection requires state checksumming or periodic comparison. Remediation involves replica reset and state transfer.

**Coordination failures**: Atomic broadcast service failures halt progress. Split-brain scenarios in partitionable systems cause divergent state evolution across partitions.

**Straggler amplification**: Slowest replica determines overall system performance. Tail latencies are amplified as clients must wait for all replicas.

**State transfer failures**: Large state sizes create recovery bottlenecks. Partial state transfer with concurrent operation application introduces complexity and potential for transfer corruption.

### Related Topics

- Passive Replication (Primary-Backup)
- Chain Replication
- Quorum-Based Replication
- State Machine Replication (RSM)
- Total Order Broadcast
- Virtual Synchrony
- Byzantine Fault Tolerance (BFT)
- Paxos and Raft Consensus Protocols
- Deterministic Execution Systems
- Group Communication Systems

---

