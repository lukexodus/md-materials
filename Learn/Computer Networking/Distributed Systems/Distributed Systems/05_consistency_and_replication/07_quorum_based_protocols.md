## Quorum-based Protocols


### Core Mechanism

Quorum-based protocols coordinate replicated state across distributed nodes by requiring overlapping subsets of replicas to participate in read and write operations. A quorum system defines a collection of replica subsets (quorums) such that any two quorums intersect, guaranteeing that reads observe previous writes. Operations complete when a threshold number of replicas respond, trading consistency guarantees against availability and latency.

**[Inference]** The intersection property ensures at least one replica in a read quorum witnessed the most recent write quorum, though specific consistency semantics depend on protocol variant and configuration.

### Quorum Configuration

**Read Quorum (R):** Minimum replicas that must respond to a read request.

**Write Quorum (W):** Minimum replicas that must acknowledge a write request.

**Replication Factor (N):** Total replica count for the data item.

**Constraint for strong consistency:** R + W > N (ensures read-write overlap)

**Constraint for availability:** R + W ≤ N (permits operations during partial failures, sacrifices strong consistency)

Common configurations:

- **Majority quorum:** R = W = ⌊N/2⌋ + 1 (symmetric, survives ⌊N/2⌋ failures)
- **Read-optimized:** W = N, R = 1 (write-all, read-any)
- **Write-optimized:** W = 1, R = N (write-any, read-all)
- **Asymmetric:** R = 1, W = N or R = 2, W = N-1 for read-heavy workloads

### Consistency Models

**Linearizability:** Requires R + W > N plus coordination mechanism (Paxos, Raft, or consensus-based leader election). Quorum intersection alone insufficient; requires version vectors, timestamps, or consensus to order concurrent operations.

**Sequential Consistency:** Achievable with R + W > N when combined with logical clocks or total order broadcast for write serialization.

**Eventual Consistency:** Permits R + W ≤ N. Replicas converge asynchronously via gossip, anti-entropy, or read-repair. Conflicts resolved via last-write-wins, vector clocks, or application-specific merge functions.

**Causal Consistency:** Requires tracking causal dependencies using version vectors or dotted version vectors. Read quorums must include all causally-dependent writes.

### Version Resolution and Conflict Handling

**Last-Write-Wins (LWW):** Uses wall-clock or logical timestamps. Vulnerable to clock skew and data loss on concurrent writes. Appropriate only for commutative operations or when loss is acceptable.

**Vector Clocks:** Each replica maintains vector of logical timestamps. Enables partial ordering detection. Read operations return all concurrent versions (siblings). Client performs semantic reconciliation. Storage overhead grows with replica churn; requires pruning mechanisms.

**Dotted Version Vectors (DVV):** Optimized vector clocks that track only causally-relevant updates. Reduces metadata size and false concurrency detection.

**Version Vectors with Server-Side Merge:** Replicas apply deterministic merge functions (CRDTs, operational transforms) to resolve conflicts automatically without client involvement.

### Read and Write Paths

**Write Path:**

1. Coordinator node receives write request
2. Determines replica set via consistent hashing or partition map
3. Sends write to N replicas with version metadata
4. Waits for W acknowledgments
5. Returns success to client
6. Asynchronous hinted handoff or read-repair handles unavailable replicas

**Read Path:**

1. Coordinator requests data from R replicas
2. Replicas return versioned values
3. Coordinator applies conflict resolution (timestamp comparison, vector clock merge)
4. Returns resolved value(s) to client
5. Optionally triggers read-repair to propagate latest version to stale replicas

**Sloppy Quorums:** When primary replicas unavailable, coordinator uses fallback replicas outside normal preference list. Hinted handoff queues writes for original replicas when they recover. Degrades consistency guarantees but maintains availability.

### Failure Modes and Availability

**Replica Failures:** System tolerates up to N - W write failures and N - R read failures while maintaining configured consistency.

**Coordinator Failures:** Any node can act as coordinator; client retries with different coordinator.

**Network Partitions:** Majority partition remains available for majority quorum configurations. Minority partition cannot satisfy quorums, rejecting operations. Sloppy quorums allow minority partition writes with delayed consistency.

**Split-Brain Prevention:** Majority quorums inherently prevent split-brain; only one partition can form quorum. Non-majority configurations require external coordination (ZooKeeper, etcd) or fencing mechanisms.

**Partial Replica Failures:** Degraded replicas may respond slowly or return errors. Coordinator timeouts and speculative execution (sending redundant requests to backup replicas after timeout threshold) mitigate tail latency.

### CAP and PACELC Trade-offs

**AP Configuration (R + W ≤ N):** Prioritizes availability and partition tolerance. Sacrifices strong consistency for eventual consistency. Example: R=1, W=1, N=3 permits continued operation during partitions with conflict reconciliation required.

**CP Configuration (R + W > N, strict quorums enforced):** Prioritizes consistency and partition tolerance. Minority partitions reject operations. Example: R=2, W=2, N=3 ensures strong consistency but fails operations when two replicas unavailable.

**PACELC:** When partitioned (PA/PC), choose availability or consistency. Else, even without partitions (E), trade latency (L) for consistency (C). Lower quorum thresholds reduce latency but weaken consistency guarantees during normal operation.

### Optimization Techniques

**Speculative Execution:** Send read requests to R+k replicas simultaneously; use first R responses. Reduces tail latency at cost of increased network traffic and load.

**Hedged Requests:** Send duplicate request to backup replica after percentile-based timeout (e.g., P95 latency). First response wins. Improves tail latency without always doubling traffic.

**Quorum Repair:** Asynchronously propagate latest version to stale replicas detected during read operations. Reduces future conflict reconciliation overhead.

**Anti-Entropy:** Background process compares replica versions using Merkle trees or hash trees. Identifies divergent replicas and synchronizes state. Essential for eventual consistency models.

**Tunable Consistency (Per-Operation):** Allow clients to specify R/W values per operation. Critical reads use R=majority; non-critical reads use R=1. Balances latency and consistency based on operation semantics.

**Local Quorums:** Multi-datacenter deployments use datacenter-local quorums for reduced latency. Cross-datacenter replication handled asynchronously. Increases risk of data loss on datacenter failure.

### Partitioning Integration

**Consistent Hashing:** Maps data items to token ring; each partition owns token range. Replicas placed on N successive nodes clockwise on ring. Rebalancing requires minimal data movement but uneven load distribution without virtual nodes.

**Virtual Nodes (vnodes):** Each physical node owns multiple token ranges. Improves load distribution and failure recovery (replacement node receives data from multiple sources in parallel). Increases metadata overhead and coordination complexity.

**Range Partitioning:** Orders data by partition key; assigns contiguous ranges to nodes. Supports efficient range queries but vulnerable to hotspots. Requires manual or automatic range splitting/merging.

**Replication Factor per Partition:** Independently configure N for each partition based on importance, access patterns, or durability requirements.

### Coordination Patterns

**Coordinator Selection:** Request routers use consistent hashing to determine partition owners; any partition owner can coordinate. Client-side drivers may route directly to replica set.

**Multi-Key Operations:** Require distributed transactions or two-phase commit across multiple quorums. Alternatives include denormalization or entity groups that co-locate related data.

**Conditional Writes (Compare-and-Set):** Require version checking across quorum. Write succeeds only if all replicas have expected version. Serializes conflicting updates but increases latency due to multi-round-trip coordination.

**Lightweight Transactions:** Use Paxos or Raft for specific operations requiring linearizability (e.g., unique constraints, conditional updates) while using quorum replication for bulk data. Example: Cassandra's lightweight transactions.

### Latency Characteristics

**Write Latency:** Determined by slowest replica in write quorum. Typically involves:

- Network RTT to W replicas
- Commit log append (sequential write)
- Memtable update (in-memory structure)
- Acknowledgment response

Majority quorum (W=2, N=3) adds one additional RTT compared to single-replica write.

**Read Latency:** Determined by slowest replica in read quorum plus conflict resolution overhead. Strategies:

- Read from closest replica first; query additional replicas only if version mismatch detected
- Always read from R replicas in parallel; merge results
- Speculative execution to mitigate tail latency

**Cross-Datacenter Latency:** Replication across geographic regions incurs WAN latency (tens to hundreds of milliseconds). Local quorums reduce impact for reads; writes still bound by furthest replica in quorum.

### Durability and Data Loss Scenarios

**Write Durability:** Data becomes durable when W replicas acknowledge. Loss of N-W+1 replicas before asynchronous replication completes results in data loss.

**Hinted Handoff Durability:** Writes to fallback replicas remain vulnerable until transferred to primary replicas. Extended outages may exceed hint storage capacity, requiring full replica rebuild.

**Disk Failures:** Commit logs and SSTables (or equivalent persistent structures) require redundant storage (RAID, erasure coding) at node level for durability within replica.

**Correlated Failures:** Rack, power, or switch failures can simultaneously lose multiple replicas. Rack-aware replica placement distributes replicas across failure domains.

### Observability and Monitoring

**Quorum Health Metrics:**

- Read/write operation success rate by consistency level
- Quorum timeout rate and timeout distribution
- Replica response time distribution (P50, P95, P99)
- Hinted handoff queue depth and age
- Read-repair frequency and data divergence rate

**Version Skew Metrics:**

- Number of siblings returned per read operation
- Version reconciliation latency
- Anti-entropy repair data volume

**Replica Availability:**

- Replica up/down status per partition
- Replica lag (write timestamp delta between replicas)
- Network partition detection and duration

### Security Considerations

**Authentication and Authorization:** Each replica independently validates credentials; compromised coordinator cannot bypass authorization. Requires consistent identity propagation across quorum.

**Encryption:** TLS for inter-replica communication. Encryption-at-rest for stored data. Key rotation complexity increases with replica count.

**Access Auditing:** Coordinator logs operations but may not reflect which replicas served data. Audit trails require aggregation across replicas.

**Denial of Service:** Write amplification (W > 1) and read amplification (R > 1) multiply resource consumption per operation. Rate limiting and admission control necessary at coordinator and replica levels.

**Byzantine Fault Tolerance:** Standard quorum protocols assume crash-fail model. Byzantine quorum systems require 3f+1 replicas to tolerate f malicious nodes and use cryptographic signatures for validation. Substantially higher overhead.

### Implementation Considerations

**Replica Synchronization State:**

- Commit log: Append-only write-ahead log for durability
- Memtable: In-memory write buffer for recent updates
- SSTable/LSM-tree: Immutable sorted files for persistent storage
- Bloom filters and indexes for read path optimization

**Compaction:** Merge and consolidate versioned data over time. Tombstones (deletion markers) must propagate across all replicas before safe removal. Impacts read performance and storage overhead.

**Membership and Topology Changes:** Adding/removing replicas requires:

- Bootstrap: New replica streams existing data from existing replicas
- Decommission: Existing replicas hand off data to remaining replicas
- Topology metadata propagation (gossip protocol, external coordination service)

**Incremental Repair:** Instead of full anti-entropy, use Merkle tree comparison to identify divergent data ranges and synchronize only affected segments.

**Coordinator Overload Protection:** Circuit breakers reject requests when replica availability drops below threshold. Prevents cascading failures due to excessive timeout accumulation.

### Related Architectural Patterns and Protocols

- Paxos and Multi-Paxos
- Raft consensus
- Two-phase commit (2PC) and three-phase commit (3PC)
- Chain replication
- Viewstamped replication
- Primary-backup replication
- Gossip protocols and epidemic algorithms
- Vector clocks and version vectors
- CRDTs (Conflict-free Replicated Data Types)
- Consistent hashing and distributed hash tables
- Anti-entropy and Merkle trees
- Hinted handoff and read-repair mechanisms
- Sloppy quorums and eventual consistency


---

