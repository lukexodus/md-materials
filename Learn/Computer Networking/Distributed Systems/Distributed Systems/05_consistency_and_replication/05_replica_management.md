## Replica Management


### Coordination Models

**Primary-Based Replication**

Primary-backup architectures designate one replica as authoritative for write operations. The primary serializes all mutations and propagates state changes to secondaries through replication logs or state transfer mechanisms. Failover involves promoting a secondary to primary status, requiring coordination protocols to prevent split-brain scenarios where multiple replicas simultaneously believe they hold primary status.

Consensus-based primary election (Raft, Multi-Paxos) embeds leader election within the replication protocol itself. The elected leader's term number provides fencing tokens that invalidate operations from deposed primaries. Log sequence numbers (LSNs) or logical timestamps order operations across the replication topology.

Lease-based primary designation uses time-bounded exclusive locks acquired from a coordination service (Chubby, ZooKeeper, etcd). The primary must continuously renew its lease; failure to renew triggers automatic demotion. Lease duration controls the unavailability window during primary failure—shorter leases reduce downtime but increase coordination overhead and false-positive failovers under transient network delays.

**Quorum-Based Replication**

Quorum protocols eliminate single points of coordination by requiring agreement from a subset of replicas for each operation. Read quorum `R` and write quorum `W` must satisfy `R + W > N` where `N` is the replica count, ensuring overlap between any read and write quorum to guarantee read-your-writes consistency.

Sloppy quorums relax the requirement that quorums contain specific designated replicas, allowing any `W` available replicas to acknowledge writes during partial failures. This trades stronger consistency guarantees for higher availability but introduces complexity in anti-entropy and conflict resolution.

Byzantine quorum systems require `3f + 1` replicas to tolerate `f` Byzantine failures, with quorums of size `2f + 1`. The additional replicas and quorum size overhead stem from the need to mask arbitrary failures including data corruption and malicious behavior.

**Leaderless Replication**

Fully symmetric architectures allow any replica to accept writes without coordination. Dynamo-style systems use vector clocks or version vectors to track causality across concurrent updates. Conflicting writes produce sibling values that require application-level reconciliation or last-write-wins semantics based on timestamps.

Hinted handoff temporarily stores writes destined for unavailable replicas on substitute nodes. When the intended replica recovers, hints are replayed to achieve eventual consistency. The hint window duration bounds divergence between replicas during extended failures.

### Replication Protocols

**Synchronous Replication**

The primary blocks write acknowledgment until receiving confirmation from a specified number of secondaries. This provides strong durability guarantees and simplifies failover since promoted secondaries possess all committed state. However, write latency increases to the slowest replica in the synchronous set, and availability degrades when synchronous replicas become unreachable.

Chain replication forms replicas into a linear topology where writes flow through the chain head to tail. Reads can be served from the tail, which always contains all committed state. The chain provides strong consistency with lower communication complexity than quorum systems for certain workloads, but chain reconfiguration during failures requires careful coordination.

**Asynchronous Replication**

The primary acknowledges writes before secondaries confirm receipt, reducing write latency at the cost of potential data loss during primary failure. The replication lag window represents the maximum divergence between primary and secondary state.

Log shipping transmits write-ahead log (WAL) segments to secondaries, which replay log entries to reconstruct state. Logical replication decodes WAL entries into row-level changes, enabling selective replication, schema flexibility, and cross-version replication. Physical replication transmits block-level changes, maintaining byte-identical replicas but requiring version compatibility.

Change data capture (CDC) extracts mutations from the primary's transaction log for consumption by secondaries or downstream systems. CDC preserves operation ordering and transactional boundaries while decoupling replication from the primary's commit path.

**Semi-Synchronous Replication**

Hybrid protocols wait for acknowledgment from a subset of replicas before confirming writes to clients. MySQL semi-sync waits for at least one secondary to acknowledge log receipt before commit completion. PostgreSQL synchronous replication supports configurable sync replica counts via `synchronous_standby_names`.

This approach bounds data loss exposure while avoiding the availability penalties of fully synchronous replication across all replicas. The synchronous subset size determines the failure resilience—requiring acknowledgment from `k` secondaries tolerates `k-1` secondary failures without blocking writes.

### Consistency Models

**Strong Consistency**

Linearizability guarantees that operations appear to occur instantaneously at some point between invocation and completion, with all operations totally ordered consistent with real-time causality. Read-your-writes, monotonic reads, and monotonic writes are provided as consequences.

Implementation requires coordination on every operation. Quorum reads and writes with `R + W > N` provide linearizability when combined with read repair or anti-entropy. Consensus protocols (Raft, Paxos) inherently provide linearizable semantics through log-based state machine replication.

Network partitions force unavailability under linearizability per the CAP theorem. Differentiate between read and write availability—quorum systems can serve reads from majority partitions while blocking writes.

**Sequential Consistency**

Operations from each client appear in program order, but operations from different clients may be interleaved arbitrarily. Unlike linearizability, sequential consistency does not respect real-time ordering across clients.

This relaxation enables lower-latency implementations by avoiding global coordination for operation ordering. Causal consistency further relaxes sequential consistency by only preserving causally related operation ordering.

**Eventual Consistency**

Replicas converge to identical state in the absence of new updates, but may temporarily diverge. Bounded staleness models constrain divergence to a maximum time window or operation count.

Conflict-free replicated data types (CRDTs) provide provable convergence by ensuring that concurrent operations commute. State-based CRDTs (convergent) transmit entire object state; operation-based CRDTs (commutative) transmit operations that must be delivered exactly once. CRDT design requires careful selection of merge functions and operation semantics to preserve application invariants.

### Failure Detection and Recovery

**Failure Detectors**

Heartbeat-based detectors monitor periodic signals from replicas, declaring failure after missing a threshold number of consecutive heartbeats. Adaptive detectors adjust timeout thresholds based on historical heartbeat latency distributions to reduce false positives under variable network conditions.

Phi accrual failure detectors compute a suspicion level rather than binary alive/dead status. The phi value represents the probability of failure; applications select thresholds based on their tolerance for false positives versus detection latency.

Failure detection quality involves two metrics: detection time (latency to identify actual failures) and false positive rate (incorrectly declaring healthy replicas failed). These metrics trade off against each other—aggressive detection reduces latency but increases false positives.

**Failover Mechanisms**

Automatic failover promotes a secondary to primary without operator intervention. The promotion algorithm must ensure at-most-once semantics to prevent split-brain where multiple primaries simultaneously accept writes.

Fencing mechanisms invalidate operations from deposed primaries using generation numbers, epoch tokens, or resource revocation. Storage-level fencing (STONITH: Shoot The Other Node In The Head) forcibly powers down failed primaries to guarantee they cannot issue I/O operations.

Graceful failover validates secondary state completeness before promotion, potentially delaying availability to avoid data loss. Forced failover prioritizes availability over durability, accepting potential data loss from replication lag.

**Split-Brain Prevention**

Quorum-based approaches require majority agreement for primary promotion. A partition without majority membership cannot elect a new primary, ensuring at most one partition remains available for writes.

Witness nodes participate in quorum voting without storing full replica state, enabling majority quorums with fewer full replicas. A three-node cluster with one witness tolerates one failure while maintaining quorum.

Geo-distributed clusters require careful quorum placement to maintain availability during regional failures. Asymmetric quorums (e.g., primary requires majority in its region) can optimize for latency while maintaining correctness.

### Topology Patterns

**Primary-Secondary (Master-Slave)**

Single primary services all writes; secondaries serve read traffic and provide failover capacity. Read scaling occurs by adding secondaries, but write throughput remains bounded by primary capacity.

Replication lag monitoring tracks secondary divergence from primary state. Applications requiring read-your-writes consistency must either read from primary or track replication positions to ensure sufficient secondary freshness.

Cascading replication forms hierarchies where secondaries replicate from other secondaries rather than directly from primary. This reduces primary replication bandwidth but increases propagation latency and complexity during topology changes.

**Primary-Primary (Multi-Master)**

Multiple replicas accept writes concurrently. Conflict detection identifies concurrent modifications to the same data item. Conflict resolution strategies include last-write-wins (using timestamps or version vectors), application callbacks, or operational transformation.

Bidirectional replication between two primaries creates active-active topologies for disaster recovery. Writes to either primary propagate to the peer, maintaining eventual consistency. Conflict rates increase with write concurrency and replication latency.

Multi-master with more than two nodes requires all-to-all replication or hub-and-spoke topologies. Full mesh replication overhead grows quadratically with replica count, limiting practical deployments to small numbers of masters.

**Peer-to-Peer (P2P)**

Fully decentralized topologies without distinguished primary roles. Consistent hashing assigns data partitions to replicas based on key hash values, enabling automatic rebalancing when replicas join or leave.

Gossip protocols disseminate state updates through epidemic-style communication. Each replica periodically exchanges state with randomly selected peers. Convergence time depends on gossip round frequency and fan-out factor.

Merkle trees provide efficient anti-entropy by comparing hash tree roots to identify divergent subtrees, minimizing data transfer during reconciliation. Tree granularity trades off comparison overhead against repair precision.

### State Transfer

**Snapshot Transfer**

Full snapshot replication transmits complete replica state to initialize new secondaries or resync divergent replicas. Snapshot consistency requires point-in-time isolation, either through MVCC snapshots, filesystem snapshots, or application-level consistency points.

Incremental snapshots transmit only changes since the previous snapshot, using copy-on-write mechanisms or change tracking bitmaps. This reduces transfer volume but requires tracking metadata and handling corner cases like schema changes.

**Log-Based Transfer**

Replicas consume the primary's write-ahead log (WAL) or binlog to reconstruct state incrementally. Log position tracking (LSN, GTID) identifies divergence points for recovery after connection loss.

Log retention policies balance storage costs against recovery capabilities. Insufficient log retention forces expensive snapshot transfer when secondaries fall too far behind. Archival systems move aged logs to cheaper storage tiers while maintaining recoverability.

**Streaming Transfer**

Continuous log streaming maintains near-real-time replication with minimal lag. Backpressure mechanisms prevent primary slowdown when secondaries cannot keep pace—either blocking primary writes (synchronous) or buffering/dropping updates (asynchronous).

Compression reduces network bandwidth consumption at the cost of CPU overhead. Adaptive compression algorithms adjust aggressiveness based on available bandwidth and CPU capacity.

### Replication Lag Management

**Lag Metrics**

Byte lag measures the volume of unreplicated data (e.g., bytes behind in log position). Time lag represents the age of the oldest unreplicated operation. These metrics diverge under variable write rates—constant write rate produces proportional relationship, but bursty writes cause byte lag to spike while time lag remains stable.

Transaction lag counts the number of uncommitted transactions on secondaries. This metric better represents application-level staleness for transactional workloads than byte-based measurements.

**Lag Compensation**

Read-your-writes guarantees require routing reads to replicas with sufficient LSN progression. Session-based routing pins client connections to specific secondaries until replication catches up, trading off load distribution for consistency.

Causal consistency tokens encode the causal dependency frontier (vector clock or version vector) that reads must observe. Clients present tokens from previous writes to subsequent reads, allowing any sufficiently up-to-date replica to serve the read.

Bounded staleness policies reject reads from replicas exceeding lag thresholds, either failing the request or redirecting to fresher replicas. SLA-based routing dynamically selects replicas based on current lag measurements and read consistency requirements.

**Lag Reduction**

Parallel apply uses multiple threads to replay replication logs on secondaries. Dependency analysis ensures causally related operations execute in order while independent operations parallelize. Hash-based partitioning assigns operations to threads based on modified keys, preserving per-key ordering.

Write coalescing merges multiple updates to the same key in the replication stream before secondary application. This reduces secondary write amplification but requires buffering and analyzing the replication stream.

Priority replication propagates critical updates preferentially to reduce lag for high-value data. This requires application-level classification and replication protocol support for priority queuing.

### Partial Replication

**Selective Replication**

Table-level or row-level filtering limits replication scope based on predicates. This reduces secondary storage requirements and replication bandwidth but introduces complexity in maintaining filter definitions and handling schema changes.

Column filtering replicates a subset of columns per table, useful for creating read-optimized secondaries for specific query patterns. Requires careful handling of updates to non-replicated columns to maintain consistency.

**Sharded Replication**

Each shard replicates independently with its own primary and secondary set. Cross-shard queries require scatter-gather or distributed transaction protocols. Shard placement strategies balance load distribution, failure domain isolation, and network topology awareness.

Replication factor may vary across shards based on importance or access patterns. Critical shards use higher replication factors for increased durability and read capacity.

### Multi-Datacenter Replication

**Regional Topologies**

Single-region primary with cross-region secondaries provides disaster recovery while serving local reads from regional secondaries. Write latency remains low, but regional failover requires promoting a remote secondary to primary.

Regional primaries with bidirectional replication support active-active geo-distribution. Partition tolerance requires either accepting divergence (eventual consistency) or sacrificing availability (consensus-based).

**WAN-Optimized Protocols**

Batching amortizes per-operation network overhead by grouping multiple operations into single replication round trips. Batch size trades off latency against throughput.

Delta encoding transmits only changed bytes within modified records, reducing bandwidth for workloads with large records and small modifications.

**Conflict Resolution for Multi-Region**

Timestamp-based last-write-wins uses wall-clock or hybrid logical clocks to order conflicting updates. Clock skew bounds the inconsistency window—NTP-synchronized clocks provide millisecond-level accuracy, while atomic clocks enable microsecond precision.

Causal ordering preserves happens-before relationships using version vectors or dotted version vectors. Concurrent modifications without causal relationship produce conflicts requiring application-level resolution.

### Observability

**Replication Monitoring**

Lag dashboards visualize byte lag, time lag, and transaction lag across all secondaries. Alerting thresholds trigger notifications when lag exceeds SLA bounds or grows unexpectedly.

Throughput metrics track replication bytes per second, operations per second, and batch sizes. These indicate replication pipeline saturation and guide capacity planning.

Error rates capture transient failures (network timeouts, retry-able errors) and permanent failures (incompatible schema changes, data corruption). Permanent errors require operator intervention and may indicate configuration drift.

**Replication Diagnostics**

Log position tracking per secondary identifies which replica has the freshest state during failover selection. Divergence detection compares checksums or Merkle tree roots to identify inconsistencies.

Bottleneck analysis profiles replication pipeline stages: log read, network transfer, deserialization, apply, and commit. Per-stage latency percentiles identify optimization opportunities.

### Security and Isolation

**Authentication and Authorization**

Replication user privileges should follow least-privilege principles, granting only permissions required for replication operations. Separate credentials per secondary enable fine-grained revocation.

Certificate-based mutual TLS authentication ensures both primary and secondary identity verification, preventing replica impersonation attacks.

**Encryption**

In-transit encryption protects replication traffic from eavesdropping. Protocol-level TLS wraps replication streams; application-level encryption operates on data before transmission.

At-rest encryption on secondaries prevents unauthorized access to replica storage. Key management complexity increases with replica count—hierarchical key derivation or centralized key services reduce operational overhead.

**Data Isolation**

Logical replication with column filtering or row-level security predicates limits replicated data to authorized subsets. This supports compliance requirements for data residency or multi-tenancy isolation.

### Related Topics

- Consensus protocols (Raft, Paxos, ZAB)
- Distributed transactions (2PC, 3PC, Saga)
- Partitioning and sharding strategies
- CAP theorem and PACELC framework
- Quorum systems and voting protocols
- Vector clocks and causal ordering
- Anti-entropy and gossip protocols
- Chain replication
- State machine replication
- Conflict-free replicated data types (CRDTs)
- Operational transformation
- Write-ahead logging (WAL)
- Multi-version concurrency control (MVCC)
- Geo-replication and active-active topologies
- Backup and disaster recovery

---

