## Concurrency Control in Distributed Systems


### Fundamental Challenges

Distributed concurrency control coordinates concurrent transaction execution across multiple nodes without shared memory or a global clock. Key challenges include:

**Clock Skew:** Physical clocks drift independently across nodes. NTP synchronization provides millisecond-level accuracy but insufficient for ordering concurrent operations. Clock synchronization failures can violate ordering guarantees.

**Network Delays:** Variable, unbounded message latency between nodes. Operations initiated later may arrive earlier. Timeout-based failure detection cannot distinguish slow nodes from failed nodes.

**Partial Failures:** Subset of participants may fail or become unreachable during transaction execution. Coordinator failure during commit protocol requires recovery mechanisms.

**Network Partitions:** Nodes remain operational but cannot communicate. Different partitions may independently accept conflicting updates. Partition healing requires conflict resolution.

**No Global State:** Each node maintains local view of system state. Achieving consistent global snapshots requires coordination protocols with associated overhead.

### Isolation Levels

**Serializability:** Execution outcome equivalent to some serial ordering of transactions. Strongest isolation guarantee. Requires conflict detection or prevention across all participating nodes.

**Snapshot Isolation (SI):** Each transaction reads from consistent snapshot at transaction start time. Writes visible only after commit. Prevents lost updates and dirty reads but permits write skew anomalies. Read-only transactions never block or abort.

**Read Committed:** Transaction reads only committed data. Does not prevent non-repeatable reads or phantom reads. Minimal coordination overhead; commonly implemented with MVCC where reads see latest committed version.

**Read Uncommitted:** Transactions observe uncommitted writes (dirty reads). Rarely implemented in distributed systems due to cascading abort complexity and consistency violations.

**Repeatable Read:** Transaction observes consistent view of data across multiple reads of same item. Does not prevent phantom reads (new rows appearing in range queries between reads).

### Pessimistic Concurrency Control

**Distributed Locking (Two-Phase Locking, 2PL):**

Transaction acquires locks on all accessed data items before operating on them. Growing phase accumulates locks; shrinking phase releases locks after commit/abort.

**Strict 2PL:** Holds all locks until commit/abort completes. Prevents cascading aborts and ensures serializability. Write locks prevent concurrent reads; read locks prevent concurrent writes.

**Implementation:**

- Centralized lock manager (single point of failure, scalability bottleneck)
- Distributed lock managers with consistent hashing (lock requests routed to partition owner)
- Lock coordinator per partition with replicated lock table for fault tolerance

**Deadlock Handling:**

- **Wait-die:** Older transaction waits for younger; younger aborts when conflicting with older. Prevents deadlock but may cause unnecessary aborts.
- **Wound-wait:** Older transaction preempts younger; younger waits for older. Minimizes aborts of older transactions.
- **Timeout-based:** Abort transaction after lock wait timeout expires. Simple but may abort transactions unnecessarily or fail to detect actual deadlocks promptly.
- **Deadlock detection:** Maintain wait-for graph; periodically detect cycles and abort victim transactions. Requires distributed cycle detection algorithm or centralized deadlock detector.

**Ordering Protocols:**

Transactions acquire locks in globally consistent order (e.g., sorted by key). Eliminates deadlocks but requires advance knowledge of access patterns. Difficult with dynamic read/write sets determined during execution.

**Latency Characteristics:** Each lock acquisition involves RTT to lock manager. Multi-partition transactions incur sequential lock acquisition latency. Lock contention causes cascading delays.

**Failure Handling:** Lock manager failure requires lock state recovery from replicas or transaction logs. Holding locks during network partition risks prolonged blocking. Lease-based locks with timeout prevent indefinite blocking but may violate isolation if lease expires during partition.

### Optimistic Concurrency Control (OCC)

Transactions execute without acquiring locks. Validation phase detects conflicts before commit. Abort and retry on conflict detection.

**Phases:**

1. **Read Phase:** Transaction reads data without coordination. Maintains read set and write set locally.
2. **Validation Phase:** Check for conflicts with concurrent transactions. Typically validates that read set remains unchanged and write set does not conflict with concurrent writers.
3. **Write Phase:** Apply writes to persistent storage if validation succeeds; abort otherwise.

**Validation Strategies:**

**Backward Validation:** Compare transaction's read set against write sets of transactions that committed during execution. Conflict if any committed transaction wrote data item in read set.

**Forward Validation:** Compare transaction's write set against read sets of active transactions. Abort active transactions reading data in write set. Requires tracking active transaction read sets.

**Timestamp-Based Validation:** Assign commit timestamp during validation. Ensure read set timestamps precede commit timestamp and write set timestamps do not conflict with concurrent transactions. Requires globally consistent timestamp allocation.

**Implementation in Distributed Context:**

- Centralized validator serializes validation phase (scalability bottleneck)
- Partition-local validators validate partition-local conflicts; global coordinator validates cross-partition conflicts
- Validation combined with distributed commit protocol (e.g., validation during 2PC prepare phase)

**Advantages:** No lock acquisition overhead during read/write phases. High concurrency for read-heavy workloads with low conflict rates. No deadlocks.

**Disadvantages:** High abort rate under contention. Wasted work from aborted transactions. Validation phase serialization bottleneck. Starvation possible for repeatedly aborted transactions (requires backoff or fairness mechanism).

### Multi-Version Concurrency Control (MVCC)

Maintains multiple timestamped versions of each data item. Readers access version valid at transaction start time without blocking writers. Writers create new versions without overwriting existing versions.

**Version Storage:**

**Append-Only:** New versions appended to version chain. Older versions garbage collected when no active transaction requires them. Requires version visibility metadata (creation/expiration timestamps).

**Time-Travel Storage:** Versions organized by timestamp in time-indexed structure (e.g., LSM-tree with timestamp-based compaction). Supports historical queries efficiently but increases storage overhead.

**Delta Storage:** Store deltas between versions rather than full copies. Reduces storage overhead but increases read cost (version reconstruction from deltas).

**Timestamp Assignment:**

**Centralized Timestamp Oracle:** Single node allocates globally increasing timestamps. Guarantees total order but introduces latency and single point of failure. Batching reduces per-transaction overhead.

**Hybrid Logical Clocks (HLC):** Combines physical clock with logical counter. Provides causality tracking with bounded clock skew. Each node maintains local HLC; increments on events; receives and merges HLCs in messages.

**TrueTime (Google Spanner):** GPS and atomic clock infrastructure provides bounded uncertainty interval. Transaction commit waits for uncertainty interval to elapse, ensuring commit timestamp precedes all future events. Requires specialized hardware.

**Decentralized Timestamp Allocation:** Partition-local timestamp allocation with partition identifier encoding. Ordering defined by (partition_id, local_timestamp). Limits cross-partition ordering guarantees.

**Read Protocol:**

Transaction receives start timestamp. Reads return version with largest timestamp ≤ start timestamp and not marked as aborted. Read-only transactions never wait or abort (assuming sufficient version retention).

**Write Protocol:**

Transaction buffers writes locally. During commit, allocate commit timestamp > start timestamp and all read version timestamps. Validate no concurrent transaction committed conflicting writes. Persist new versions with commit timestamp.

**Garbage Collection:**

**Low Watermark Tracking:** Maintain oldest active transaction start timestamp. Versions older than low watermark become unreachable and eligible for deletion. Requires distributed low watermark computation (e.g., periodic gossip or coordination service).

**Vacuum Process:** Background process scans version chains, removes obsolete versions. Coordination required to ensure no transaction holds reference to removed version.

### Distributed Transactions and Commit Protocols

**Two-Phase Commit (2PC):**

**Phase 1 (Prepare):** Coordinator sends prepare request to all participants. Participants write transaction state to durable storage (prepare log record) and respond with vote (commit/abort). Participant that votes commit cannot unilaterally abort.

**Phase 2 (Commit/Abort):** If all participants vote commit, coordinator decides commit; otherwise abort. Coordinator writes commit/abort decision to durable storage. Sends decision to participants. Participants apply decision and acknowledge.

**Failure Scenarios:**

- **Coordinator failure after prepare, before commit decision:** Participants blocked indefinitely (cannot commit or abort safely without decision). Requires coordinator recovery from log or timeout-based presumed abort protocol.
- **Participant failure after voting commit:** Coordinator must retry commit message until participant recovers. Transaction state persisted in coordinator log.
- **Network partition during commit phase:** Coordinator cannot complete protocol. Blocking protocol variant prevents progress; non-blocking variants (3PC) vulnerable to partition + failure scenarios.

**Optimizations:**

- **Read-only optimization:** Participants with no writes skip prepare phase, respond immediately with read-only vote.
- **Presumed abort:** Coordinator does not log abort decisions. Timeout defaults to abort. Reduces log writes for common abort cases.
- **Early prepare:** Piggyback prepare message on last operation to participant. Reduces round trips.

**Three-Phase Commit (3PC):**

Adds pre-commit phase between prepare and commit. Coordinator collects prepare votes, then sends pre-commit to participants. Participants acknowledge pre-commit, then coordinator sends final commit.

**[Inference]** Designed to avoid blocking under single node failures by ensuring all nodes reach agreement before any node commits. However, still vulnerable to network partitions where different partitions may independently decide to commit or abort, violating consistency.

**Consensus-Based Commit (Paxos Commit, Raft):**

Replace 2PC coordinator with replicated state machine (Paxos or Raft group). Transaction outcome becomes consensus value. Participants send votes to consensus group. Consensus group decides commit/abort and replicates decision across multiple nodes. Tolerates minority failure of decision nodes. Higher latency than 2PC but provides fault tolerance without blocking.

### Transaction Coordination Patterns

**Centralized Coordinator:**

Single coordinator node orchestrates transaction across participants. Simplest implementation but single point of failure and scalability bottleneck. Typically combined with coordinator failover or recovery protocol.

**Partition-Based Coordination:**

Transaction coordinator determined by partition of first accessed key or explicit transaction coordinator hint. Distributes coordination load. Requires transaction routing logic to select coordinator consistently.

**Decentralized Coordination:**

Participants coordinate directly without dedicated coordinator. Each participant holds transaction state. Commit protocol uses peer-to-peer communication. Example: Byzantine agreement protocols where participants collectively reach consensus.

**Client-Side Coordination:**

Client acts as transaction coordinator. Sends operations to participants and drives commit protocol. Reduces server-side coordination overhead but vulnerable to client failures (requires server-side recovery or timeout mechanisms).

### Conflict Detection and Resolution

**Conflict Types:**

**Read-Write Conflict (Anti-Dependency):** Transaction T1 reads item X, transaction T2 writes X. Serializability requires T1 precede T2 in serial order. Violates snapshot isolation if T2 commits before T1 completes (T1 reads stale version).

**Write-Read Conflict (Dependency):** Transaction T1 writes item X, transaction T2 reads X. T1 must precede T2. Prevented by read committed and stronger isolation levels.

**Write-Write Conflict (Output Dependency):** Transactions T1 and T2 both write item X. Last writer determines final value. Serializability requires one transaction abort or consistent ordering mechanism.

**Detection Mechanisms:**

**Lock-Based:** Conflicting lock requests detected immediately. Read locks conflict with write locks. Write locks conflict with all locks.

**Timestamp-Based:** Assign transaction timestamps. Detect conflicts by comparing timestamps of conflicting operations. Earlier transaction must see consistent snapshot.

**Version-Based:** Maintain version metadata (read/write timestamps, transaction IDs). Compare version metadata during read/write operations. Conflict detected if version invalidated.

**Validation-Based:** Buffer operations during execution. Compare read/write sets during validation phase. Conflict if read set overlaps write set of concurrent committed transaction or write sets overlap.

**Resolution Strategies:**

**Abort and Retry:** Abort one or more conflicting transactions. Transaction restarts from beginning with fresh snapshot. May require exponential backoff to prevent livelock. Priority-based selection (e.g., abort younger transaction).

**Wait:** Block conflicting operation until conflict resolves (e.g., lock released, conflicting transaction commits/aborts). Risk of deadlock requires detection/prevention mechanism.

**Merge:** Apply both operations if semantically commutative or using CRDTs. Requires application-level merge logic. Not applicable for arbitrary operations.

**Compensation:** Allow operation to proceed with compensating action to restore consistency. Complex application logic. Limited applicability.

### Distributed Deadlock Detection

**Timeout-Based:**

Abort transaction after waiting longer than timeout threshold. Simplest approach but cannot distinguish deadlock from slow execution. May abort transactions unnecessarily or allow deadlocks to persist beyond timeout.

**Wait-For Graph (WFG):**

Directed graph where nodes represent transactions, edges represent waiting relationships. Cycle indicates deadlock. In distributed systems, WFG partitioned across nodes.

**Centralized Detection:** All wait-for information sent to central detector. Detector builds global WFG and detects cycles. Central bottleneck and single point of failure.

**Distributed Detection:** Each node maintains local WFG fragment. Periodically exchange WFG fragments or use distributed cycle detection algorithm (e.g., Chandy-Misra-Haas algorithm with probe messages). Higher overhead and detection latency.

**Edge-Chasing Algorithms:** Send probe messages along wait-for edges. Probe returns to originator indicates cycle. Example: initiator transaction sends probe to waiting transaction; probe forwarded along wait chain; cycle detected if probe returns to initiator.

**Hierarchical Detection:** Organize nodes into hierarchy. Deadlock detection performed at increasing levels of hierarchy. Local deadlocks detected locally; global deadlocks detected at higher levels. Balances detection latency and overhead.

### Timestamp Ordering Protocols

Assign unique timestamp to each transaction. Operations ordered by transaction timestamp. Ensures serializability without locking.

**Basic Timestamp Ordering (TO):**

Each data item maintains read timestamp (largest timestamp of transaction that read item) and write timestamp (largest timestamp of transaction that wrote item).

**Read Rule:** Transaction T reads item X. If T.timestamp < X.write_timestamp, abort T (attempting to read data written by future transaction). Otherwise, proceed with read; update X.read_timestamp = max(X.read_timestamp, T.timestamp).

**Write Rule:** Transaction T writes item X. If T.timestamp < X.read_timestamp, abort T (attempting to write data already read by future transaction). If T.timestamp < X.write_timestamp, ignore write (Thomas Write Rule) or abort T. Otherwise, proceed with write; update X.write_timestamp = T.timestamp.

**[Inference]** Thomas Write Rule allows ignoring obsolete writes where later transaction already wrote the item, reducing aborts but potentially violating recoverability if earlier transaction aborts.

**Advantages:** No deadlocks. No waiting. High concurrency for non-conflicting workloads.

**Disadvantages:** High abort rate under contention. Cascading aborts if dirty reads permitted. Requires globally consistent timestamp allocation (latency and coordination overhead).

**Conservative Timestamp Ordering:**

Block operation until certain it will not violate timestamp ordering. Transactions wait for all earlier transactions to declare their read/write operations. Eliminates aborts but introduces blocking and potential deadlocks.

### Distributed Snapshot Isolation

**Write Snapshot Isolation (WSI):**

Extension of snapshot isolation across distributed partitions. Each partition maintains MVCC versions. Transaction reads from snapshot at start timestamp. Writes validated against concurrent writes across all partitions.

**First-Committer-Wins:** Detect write-write conflicts across partitions during commit. If concurrent transaction already committed conflicting write, abort current transaction. Requires distributed validation or centralized certifier.

**Implementation:**

**Centralized Certifier:** All transactions send write sets to central certifier. Certifier detects conflicts and assigns commit timestamps. Scalability bottleneck but simple conflict detection.

**Decentralized Certification:** Partition-local certifiers validate partition-local conflicts. Cross-partition conflicts detected via distributed coordination (e.g., 2PC with conflict check during prepare phase).

**Timestamp-Based Validation:** Allocate commit timestamp during validation. Ensure no concurrent transaction in range [start_timestamp, commit_timestamp] wrote to write set items. Requires distributed timestamp allocation and conflict checking.

**Write Skew Prevention:**

Snapshot isolation permits write skew anomalies where two transactions read overlapping data, make disjoint writes based on read, and both commit (violating integrity constraints). Prevention requires additional mechanisms:

- **Promotion to serializability:** Detect read-write conflicts (not just write-write). Abort transaction if read set modified by concurrent transaction.
- **Materialization:** Convert phantom reads into concrete reads (e.g., create placeholder rows for range queries). Allows write-write conflict detection.
- **Explicit locks:** Application-level locking for integrity-critical read ranges. Transaction acquires explicit locks before reading.
- **Serializable Snapshot Isolation (SSI):** Track dependencies between transactions. Abort if dangerous structure (potential cycle) detected in dependency graph. Lower abort rate than full serializability while preventing anomalies.

### Serializable Snapshot Isolation (SSI)

Extends snapshot isolation with dynamic conflict detection to prevent all anomalies while maintaining MVCC benefits. Tracks read-write dependencies between transactions.

**Dangerous Structures:**

Two transactions T1 and T2 form dangerous structure if T1 reads version written before T2's snapshot and T2 reads version written before T1's snapshot (potential cycle in serialization graph). If both transactions also have writes, one must abort to prevent anomaly.

**Detection Mechanism:**

**SIREAD Locks:** Lightweight read locks (predicate locks or value locks) track what data each transaction read. Write transaction checks for conflicting SIREAD locks. Detect when transaction writes data read by concurrent transaction (read-write conflict).

**Dependency Tracking:** Maintain in/out edges for each transaction representing dependencies. Detect cycles or dangerous structures in dependency graph. Abort transaction to break cycle.

**Implementation:**

Track SIREAD locks in shared memory structure (hash table or lock table). Write operations check for conflicting SIREAD locks. Commit operation validates no dangerous structure exists. Abort transaction if conflict detected.

**Advantages:** Provides serializability with lower overhead than full 2PL. Read-only transactions never abort or wait. Lower contention than write locking.

**Disadvantages:** False positive conflicts due to conservative predicate lock granularity. Higher memory overhead for SIREAD lock tracking. Requires distributed coordination for cross-partition conflict detection.

### Causality Tracking and Causal Consistency

**Causal Consistency:** Operations causally related must be observed in same order by all nodes. Concurrent operations may be observed in different orders. Weaker than sequential consistency but provides intuitive semantics for many applications.

**Vector Clocks:**

Each node maintains vector of logical clocks (one per node). Operation tagged with vector timestamp. Vector timestamps provide partial ordering:

- Increment local clock on local event
- Send vector clock with messages
- Merge vector clocks on message receipt (element-wise max, then increment local position)

Causality determined by vector clock comparison: V1 < V2 (causally precedes) if V1[i] ≤ V2[i] for all i and V1 ≠ V2. Concurrent if neither V1 < V2 nor V2 < V1.

**Scalability Challenge:** Vector size grows with number of nodes. Problematic for large-scale systems. Optimizations include pruning inactive nodes, sharding vector clocks by partition, or using bounded version vectors with approximation.

**Lamport Timestamps:**

Single logical clock incremented on events. Provides total ordering but loses concurrency information (all events totally ordered even if concurrent). Insufficient for detecting causality violations but useful for consistent ordering.

**Dependency Tracking:**

Explicitly track causal dependencies for operations. Include dependency metadata with operations. Node delays applying operation until all dependencies satisfied. Example: include version vector or transaction ID of read operations in write operation metadata.

### Replication and Consistency

**Primary-Backup Replication:**

Single primary accepts writes. Primary replicates operations to backups. Backups apply operations in order received from primary. Concurrency control performed at primary only.

**Synchronous Replication:** Primary waits for acknowledgment from all (or quorum of) backups before acknowledging write. Strong consistency but higher write latency.

**Asynchronous Replication:** Primary acknowledges write before backups apply. Lower latency but potential data loss on primary failure and consistency anomalies (stale reads from backups).

**Multi-Primary (Multi-Master) Replication:**

Multiple nodes accept writes concurrently. Writes replicated asynchronously to other primaries. Requires distributed concurrency control across primaries.

**Conflict Detection:** Concurrent writes to same item at different primaries detected via version vectors or timestamps. Application or system resolves conflicts (last-write-wins, vector clock merge, CRDT).

**Partitioned Primary:** Each partition has designated primary. Transactions spanning partitions require distributed coordination. Single-partition transactions execute entirely at partition primary (low latency).

**Chain Replication:**

Nodes organized in linear chain. Writes sent to head of chain. Head forwards to next node in chain. Tail responds to client after all nodes applied write. Reads served by tail (see all committed writes). Simpler than quorum protocols but higher write latency (sequential replication).

**Consistency Guarantees:** Strong consistency (linearizability) without quorum coordination. Tail failure detected by predecessor; client retries with updated chain. Head failure handled by promoting second node to head.

### Cross-Datacenter Replication

**Active-Active (Multi-Master):**

All datacenters accept writes concurrently. Writes replicated asynchronously across datacenters. Lowest write latency (local datacenter acknowledgment) but requires conflict resolution for concurrent updates.

**Conflict Resolution:** Last-write-wins with vector clocks, CRDTs for mergeable data types, application-specific reconciliation. Conflicts resolved deterministically at all datacenters to ensure convergence.

**Active-Passive (Primary-Backup):**

Single primary datacenter accepts writes. Backup datacenters serve reads (potentially stale). Failover to backup datacenter on primary failure. Higher write latency (cross-datacenter synchronous replication for durability) but simpler consistency semantics.

**Disaster Recovery:** Backup datacenter becomes primary on catastrophic primary failure. May require manual intervention or consensus-based leader election across datacenters.

**Quorum Across Datacenters:**

Majority quorum spans multiple datacenters. Survives datacenter failures while maintaining strong consistency. Write latency determined by cross-datacenter RTT to achieve quorum.

**Local Quorum:** Within-datacenter quorum for low latency. Cross-datacenter replication asynchronous. Lose strong consistency but gain performance. Potential data loss on datacenter failure before asynchronous replication completes.

### Partitioning and Sharding Interaction

**Single-Partition Transactions:**

Operations confined to single partition. Concurrency control local to partition. No distributed coordination required. Optimal latency and throughput.

**Cross-Partition Transactions:**

Operations span multiple partitions. Require distributed concurrency control and commit protocol (2PC or consensus-based). Higher latency due to cross-partition coordination. Partition design aims to maximize single-partition transaction ratio.

**Partition-Aware Routing:**

Transaction router determines partition set from operation keys. Routes transaction to appropriate coordinator (typically partition primary for first accessed key).

**Co-location:**

Place related data in same partition to minimize cross-partition transactions. Entity groups, secondary indexes colocated with primary data. Schema design influences transaction locality.

### Admission Control and Load Shedding

**Transaction Queuing:**

Limit concurrent transactions at coordinator or participant. Prevents overload from unbounded concurrency. Queue incoming transactions when concurrency limit reached.

**Backpressure:** Reject new transactions when queue depth exceeds threshold. Client retries with backoff. Prevents resource exhaustion and latency inflation.

**Prioritization:** Assign priority to transactions. Execute high-priority transactions preferentially. Abort low-priority transactions under contention to favor high-priority.

**Deadline Scheduling:** Include transaction deadline in metadata. Abort transactions approaching deadline rather than continuing execution that will exceed deadline.

### Observability and Monitoring

**Transaction Latency Metrics:**

- End-to-end latency by isolation level and operation type
- Per-phase latency (read, validation, commit)
- Lock acquisition time distribution
- Deadlock detection and resolution latency

**Contention Metrics:**

- Lock wait time and wait count per key/partition
- Abort rate by conflict type
- Retry count distribution
- Version chain length (MVCC garbage collection effectiveness)

**Resource Utilization:**

- Active transaction count per node/partition
- Lock table memory utilization
- Version storage overhead
- Network bandwidth consumed by distributed coordination protocols

**Correctness Validation:**

- Isolation violation detection (e.g., write skew detection in SI)
- Consistency checks (e.g., referential integrity validation)
- Audit logs for transaction outcomes and conflict resolutions

### Practical Implementation Considerations

**Phantom Prevention:**

Range queries return set of items matching predicate. Concurrent inserts/deletes may violate serializability (phantom reads). Prevention mechanisms:

**Predicate Locks:** Lock range matching query predicate. Subsequent inserts into range block until lock released. High overhead for complex predicates.

**Index Range Locks:** Lock index range covering query. Simpler than general predicate locks but coarser granularity. Standard approach in most databases.

**Next-Key Locking:** Lock queried items plus gaps between items. Prevents inserts into gaps. Used in B-tree index locking.

**Serialization of Index Modifications:** Serialize all modifications to index structure. Prevents phantoms but limits concurrency.

**Transaction Retry Logic:**

Transactions aborted due to conflicts require retry. Application or middleware implements retry with exponential backoff. Persistent conflicts may indicate hot key requiring:

- Partition split
- Application-level sharding
- Caching layer
- Read-only replicas for read-heavy hot keys
- Rate limiting at application level

**Lease-Based Coordination:**

Locks and coordinator roles assigned with time-limited leases. Lease expires if holder fails or becomes partitioned. Prevents indefinite blocking but requires:

- Lease renewal protocol
- Lease timeout sufficient for operation completion
- Handling of operations that exceed lease duration (abort or lease extension)

**Log-Structured Storage Integration:**

MVCC naturally aligns with log-structured storage (LSM-trees). Versions appended to log. Compaction merges versions and removes obsolete data. Timestamp-based compaction removes versions older than low watermark.

### Related Architectural Patterns and Protocols

- Two-phase commit (2PC) and three-phase commit (3PC)
- Paxos and Raft consensus
- Quorum-based replication
- Vector clocks and version vectors
- MVCC and snapshot isolation implementations
- Distributed deadlock detection algorithms
- Serializable snapshot isolation (SSI)
- Optimistic concurrency control (OCC)
- Chain replication
- Primary-backup replication
- CRDTs (Conflict-free Replicated Data Types)
- Causal consistency protocols
- Hybrid logical clocks (HLC)
- Spanner TrueTime architecture
- Calvin deterministic transaction protocol
- Percolator distributed transaction system

---

