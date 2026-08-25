## Passive Replication


### Architectural Model

Passive replication designates a single primary replica as the authoritative processor of all client requests while maintaining one or more backup replicas in a standby state. The primary executes operations, updates its state, and propagates state changes or operation logs to backups. Backups do not process client requests during normal operation and exist solely to assume the primary role upon failure.

### State Transfer Mechanisms

**Checkpoint-Based Transfer**

Primary periodically captures complete state snapshots and transmits them to backups. Backup replicas discard prior state and apply the checkpoint atomically. Checkpoint frequency determines recovery point objective (RPO) and affects network bandwidth consumption. Large state sizes necessitate incremental or delta-based checkpointing to reduce transfer overhead. Copy-on-write mechanisms at the storage layer enable efficient snapshot generation without blocking primary operations.

**Operation Log Transfer**

Primary maintains a write-ahead log (WAL) of state-mutating operations and streams log entries to backups in commit order. Backups apply operations sequentially to reconstruct primary state. Log-based transfer enables lower RPO than checkpoint-based approaches but requires backups to maintain sufficient log history for replay. Log compaction and snapshotting hybrid approaches balance storage overhead with recovery time.

**Hybrid Checkpoint-Log Protocol**

Combines periodic full checkpoints with continuous log streaming. Backups apply incremental log entries since the last checkpoint, reducing recovery time while bounding log storage requirements. Checkpoint intervals are tuned based on log growth rate, recovery time objectives (RTO), and network capacity.

### Consistency Guarantees

**Linearizability Window**

Acknowledgment of client writes occurs only after the primary durably records the operation and optionally waits for synchronous replication to a quorum of backups. The linearizability point is the moment of primary acknowledgment. Asynchronous replication introduces a consistency window where committed data on the primary has not yet reached backups, creating potential data loss exposure bounded by replication lag.

**Read-Your-Writes Semantics**

All reads execute against the primary to guarantee clients observe their own writes immediately. Backup replicas cannot serve reads during normal operation without violating consistency, as their state lags behind the primary by the replication delay. Read scaling requires alternative architectures or acceptance of eventual consistency for backup reads.

### Failure Detection and Failover

**Heartbeat Protocol**

Backups monitor primary liveness through periodic heartbeat messages. Missed heartbeats within a configured timeout threshold trigger suspicion of primary failure. Timeout values balance false positive rate (premature failover) against detection latency (prolonged unavailability). Network partitions complicate failure detection, requiring additional coordination mechanisms to prevent split-brain scenarios.

**Failover Coordination**

Upon primary failure detection, a coordination protocol selects a new primary from available backups. Coordination mechanisms include:

- **Static failover order**: Pre-configured priority list determines successor
- **Consensus-based election**: Distributed consensus protocol (Paxos, Raft, ZAB) elects new primary
- **External coordinator**: Dedicated coordination service (ZooKeeper, etcd, Consul) manages leader election

Consensus-based approaches provide stronger safety guarantees against split-brain but introduce coordination latency and additional failure dependencies.

**Split-Brain Prevention**

Network partitions may isolate the primary while backups remain mutually connected, leading both partitions to believe they hold the authoritative primary role. Prevention mechanisms:

- **Quorum-based fencing**: Primary requires connectivity to a majority quorum of replicas to remain active
- **Lease-based primary validity**: Primary holds a time-bounded lease requiring periodic renewal; loss of lease forces abdication
- **STONITH (Shoot The Other Node In The Head)**: Forcibly terminate suspected failed primary through power fencing or storage access revocation

### Replication Lag Management

**Synchronous Replication**

Primary blocks client acknowledgment until one or more backups confirm durable persistence of state changes. Guarantees zero data loss upon primary failure but introduces latency proportional to network round-trip time to slowest required backup. Write throughput limited by slowest backup in the synchronous replication set.

**Asynchronous Replication**

Primary acknowledges client writes immediately after local persistence without waiting for backup confirmation. Minimizes write latency and decouples primary performance from backup performance, but creates data loss exposure equal to replication lag duration. Replication lag monitoring and alerting critical for operational visibility.

**Semi-Synchronous Replication**

Primary waits for acknowledgment from at least one backup before client acknowledgment, while additional backups replicate asynchronously. Balances data loss protection with write latency impact. Commonly used in systems like MySQL with semi-sync replication plugins.

**Chain Replication Variant**

Primary propagates writes to a single designated backup, which forwards to subsequent backups in a linear chain. Tail backup acknowledges back through the chain to the primary. Reduces primary fanout overhead but increases end-to-end replication latency and creates cascading failure sensitivity.

### Failure Modes and Degradation

**Primary Failure**

System becomes unavailable for writes during failover detection and promotion latency. Read availability depends on whether reads can be served from backups with acceptable staleness bounds. Data loss exposure equals replication lag at failure time for asynchronous replication configurations.

**Backup Failure**

No immediate impact on system availability if sufficient redundancy exists. Primary continues processing requests. Reduced fault tolerance until failed backup rejoins or is replaced. Synchronous replication may require dynamic adjustment of required backup quorum to maintain write availability.

**Total Failure**

All replicas simultaneously unavailable due to correlated failures (power loss, network partition isolating all replicas, software bug affecting all instances). Recovery requires restoring from external backups or durable storage with potential data loss and extended downtime.

**Cascading Failures**

Failover increases load on promoted backup, potentially causing secondary failure if the new primary lacks capacity to handle full load. Load shedding, request throttling, and capacity planning critical to prevent cascading collapse.

### Performance Characteristics

**Write Throughput**

Determined by primary capacity and synchronous replication overhead. Asynchronous replication decouples backup performance from write path, but synchronous replication limits throughput to slowest required backup. Batch acknowledgment protocols reduce per-operation replication overhead.

**Read Throughput**

All reads execute against single primary, creating inherent read scalability bottleneck. Horizontal read scaling requires architectural changes such as read replicas with eventual consistency or alternative replication topologies.

**Latency Profile**

Write latency includes primary processing time plus synchronous replication delay. Read latency includes network round-trip to primary plus primary processing time. Geographic distribution of primary and backups significantly impacts latency.

### Network Partition Handling

**Majority Quorum Requirement**

Primary requires connectivity to a majority of replicas to remain active, ensuring at most one active primary across partitions. Minority partitions sacrifice write availability to preserve safety.

**Lease Mechanisms**

Primary holds a time-bounded lease requiring periodic renewal with coordination service or backup quorum. Network partition preventing lease renewal forces primary abdication, ensuring eventual consistency restoration after partition healing.

**Linearizable Reads During Partition**

Maintaining linearizable reads during network partitions requires primary to confirm majority quorum connectivity before serving reads, potentially sacrificing read availability in minority partitions.

### Operational Considerations

**Backup Lag Monitoring**

Continuous monitoring of replication lag essential for operational visibility. High lag indicates potential for significant data loss upon primary failure. Alerting thresholds based on RPO requirements and application tolerance.

**Failover Testing**

Periodic controlled failover testing validates failover mechanisms and measures actual RTO. Chaos engineering approaches introduce failures in production to verify recovery procedures.

**Backup Capacity Provisioning**

Backups must be provisioned with sufficient capacity to handle full primary load upon promotion. Undersized backups create availability risk during failover.

**Geographic Placement**

Placing backups in separate failure domains (availability zones, data centers, geographic regions) improves fault tolerance against correlated failures but increases replication latency. Trade-off between RPO, RTO, and geographic disaster resilience.

### Implementation Variants

**State Machine Replication**

Primary and backups implement deterministic state machines processing identical operation sequences. Primary broadcasts operations to backups rather than state snapshots, reducing network transfer volume for small operations with large state changes.

**Virtual Synchrony**

Group communication protocol providing ordered, reliable message delivery to replica group. Primary multicasts operations; all replicas apply operations in identical order. Membership changes handled through view synchrony guarantees.

**Disk-Based Backup**

Backup replicas persist received state to durable storage but do not maintain active in-memory state. Reduces memory footprint for backups but increases promotion time as new primary must load state from disk.

### CAP and PACELC Trade-offs

Passive replication with synchronous replication to a majority quorum provides CP (consistent, partition-tolerant) characteristics, sacrificing availability in minority partitions. Asynchronous replication provides AP (available, partition-tolerant) with eventual consistency, sacrificing linearizability and introducing data loss risk. PACELC: In normal operation with no partition (E), synchronous replication chooses consistency over latency (C), while asynchronous chooses latency over consistency (L).

### Related Patterns and Architectures

- Active (state machine) replication
- Chain replication
- Quorum-based replication
- Multi-Paxos / Raft consensus
- Leader-follower database architectures
- Hot standby vs warm standby vs cold standby configurations
- Read replica architectures
- Geographic replication topologies

---

