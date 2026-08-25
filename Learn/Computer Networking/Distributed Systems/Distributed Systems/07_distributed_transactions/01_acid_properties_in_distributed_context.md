## ACID Properties in Distributed Context


### Atomicity Across Participants

**Distributed Transaction Coordinators**

Two-phase commit (2PC) protocol establishes a coordinator node that orchestrates transaction commit across multiple participant nodes. Phase 1 (prepare) solicits votes from all participants; each participant writes a prepare record to durable storage before voting. Phase 2 (commit/abort) broadcasts the decision based on unanimous agreement. All participants must vote commit for the transaction to commit; any abort vote or timeout forces global abort.

Coordinator failure during phase 2 creates an indeterminate state where participants holding prepare locks await the decision. Participants cannot unilaterally commit or abort—they must block until coordinator recovery or timeout-based presumed abort policies take effect. This blocking window creates availability vulnerabilities where locks remain held indefinitely.

Three-phase commit (3PC) introduces a pre-commit phase to eliminate blocking under bounded network delays and fail-stop failures. The additional phase allows non-coordinator nodes to safely make progress during coordinator failure. However, 3PC cannot handle network partitions correctly and may violate safety under asynchronous network conditions, limiting practical adoption.

**Coordinator Recovery and Durability**

Transaction outcome must survive coordinator crashes to maintain atomicity guarantees. The coordinator logs the transaction decision (commit/abort) to persistent storage before phase 2 completion. Recovery replays the log to retransmit outcomes to participants that may have missed the original broadcast.

Participant uncertainty logs track prepared transactions awaiting coordinator decisions. During recovery, participants query the coordinator for outcome resolution. Heuristic completion allows administrators to manually abort long-blocked transactions, accepting potential inconsistency when coordinator recovery proves impossible.

**Distributed Commit Optimization**

Presumed abort eliminates the need to log abort decisions persistently. If a participant inquires about an unknown transaction, the coordinator presumes abort. This optimization reduces coordinator logging overhead for read-only transactions and aborted transactions, which statistically dominate in many workloads.

Presumed commit inverts the optimization by presuming commit for unknown transactions. This benefits commit-heavy workloads but requires durably logging all abort decisions and increases complexity during coordinator recovery.

Read-only participant optimization allows nodes that performed no writes to skip phase 2 entirely. The participant votes read-only during phase 1, releasing locks immediately after prepare without awaiting commit confirmation.

**Failure Domain Isolation**

Transaction abort propagation must reach all participants to prevent partial commits. Timeout-based abort detection assumes participants will eventually abort prepared transactions after threshold duration. This assumption breaks under network partitions where participants remain isolated from abort notifications.

Fencing tokens attached to transaction IDs enable participants to reject stale commit requests from partitioned coordinators. Monotonically increasing epoch numbers or generation IDs invalidate operations from previous epochs.

### Consistency Guarantees

**Linearizability Implementation**

Distributed linearizability requires that operations appear atomic across the entire system with real-time ordering preservation. Consensus protocols (Raft, Multi-Paxos, Zab) replicate operations through totally-ordered logs, ensuring all replicas apply operations in identical sequence.

Read linearizability without consensus requires quorum reads with read repair or anti-entropy. Each read queries a majority quorum; concurrent writes that achieved quorum acceptance become visible. Version numbers or vector clocks disambiguate concurrent values.

Linearizable read optimization via leader leases allows the leader to serve reads from local state without quorum coordination. The lease mechanism ensures no other node can become leader during the lease period, guaranteeing the local state reflects all committed writes. Lease duration bounds the unavailability window during leader failure.

**Sequential Consistency Trade-offs**

[Inference] Sequential consistency relaxes linearizability by removing real-time ordering constraints across clients, potentially enabling lower-latency implementations without global synchronization. However, practical distributed databases rarely implement pure sequential consistency due to limited benefit over causal consistency for most application semantics.

**Causal Consistency**

Causally related operations maintain ordering while concurrent operations may execute in arbitrary order across replicas. Vector clocks or version vectors track causality by maintaining per-replica logical timestamps. Operation metadata includes the causal dependency frontier—the vector clock at operation submission time.

Causal delivery ensures replicas apply operations only after all causal dependencies have been applied. This requires buffering operations and checking dependencies before execution. Dependency tracking overhead grows with operation rate and system scale.

Client-centric causal consistency simplifies implementation by tracking causality per session rather than globally. Read-your-writes, monotonic reads, monotonic writes, and writes-follow-reads guarantees emerge as special cases.

**Snapshot Isolation in Distributed Systems**

Distributed snapshot isolation (DSI) assigns globally unique, monotonically increasing transaction timestamps. Reads observe a consistent snapshot as-of the transaction's start timestamp across all partitions. Writes buffer locally until commit, when write-write conflict detection occurs.

Write-write conflict detection requires comparing write sets of concurrent transactions (overlapping timestamp ranges). First-committer-wins aborts later transactions with conflicting writes. This differs from serializability by permitting write skew anomalies where transactions read overlapping data but write disjoint sets.

Global timestamp assignment via centralized timestamp oracle (Google Percolator) creates a coordination bottleneck. Timestamp sharding across multiple oracles increases throughput but complicates monotonicity guarantees. Hybrid logical clocks (HLC) combine physical time with logical counters, avoiding centralized timestamp allocation while maintaining causal ordering.

**Serializability**

Strict serializability combines serializability (transaction equivalence to some serial execution) with linearizability (real-time ordering). This strongest consistency model requires both snapshot isolation's multi-version concurrency control and serialization graph testing or pessimistic locking to prevent anomalies.

Serializable snapshot isolation (SSI) detects dangerous structures in the serialization graph to prevent anomalies while maintaining snapshot isolation's concurrency benefits. Predicate locks or materialized conflicts track anti-dependencies between transactions. Two anti-dependency edges forming a cycle indicate potential anomaly, triggering abort.

Two-phase locking (2PL) acquires locks during transaction execution (growing phase) and releases all locks at commit (shrinking phase). Strict 2PL delays lock release until after commit completes, simplifying recovery. Distributed 2PL requires deadlock detection across participants—either timeout-based or distributed cycle detection via wait-for graphs.

### Isolation Level Implementation

**Read Uncommitted**

[Inference] Distributed read uncommitted allows transactions to observe uncommitted writes from other transactions across partitions, creating dirty read possibilities. Implementation requires no read locking and permits reading from any replica regardless of replication lag. This model provides minimal isolation guarantees but maximum read throughput.

**Read Committed**

Each statement observes only committed data, but different statements within the same transaction may observe different snapshots. Implementation uses short-duration read locks released immediately after each read operation, or MVCC with per-statement snapshot timestamps.

Distributed read committed requires coordinating snapshot selection across partitions per statement. Global snapshot timestamp assignment ensures consistent reads across partitions, but adds coordination overhead compared to per-partition snapshot selection.

Predicate locking prevents phantom reads by acquiring locks on search predicates rather than individual tuples. Implementation complexity and performance overhead limit practical deployment.

**Repeatable Read**

All reads within a transaction observe a consistent snapshot established at transaction start. MVCC implementations assign a transaction start timestamp and read the latest committed version before that timestamp at each replica.

Distributed repeatable read requires consistent snapshot timestamps across all participants. Clock skew between nodes can cause violations if local wall-clock timestamps are used directly. TrueTime (Google Spanner) bounds clock uncertainty using GPS and atomic clocks, enabling globally consistent snapshots with bounded staleness.

Phantom protection remains optional under repeatable read in many systems. Some implementations prevent phantoms through predicate locking while others permit them, creating subtle semantic differences across systems.

**Serializable**

[Inference] Full serializability in distributed systems typically employs either distributed strict 2PL with distributed deadlock detection, or serializable snapshot isolation with predicate lock tracking across partitions. Both approaches require significant coordination overhead and may substantially reduce transaction throughput compared to weaker isolation levels.

### Durability Mechanisms

**Distributed Commit Log**

Write-ahead logging (WAL) persists transaction operations before acknowledging commits. Distributed WAL replication across multiple nodes provides fault tolerance. Quorum-based log replication requires W nodes to acknowledge log writes; log entries become durable once W replicas confirm persistence.

Log sequence numbers (LSN) or log offsets provide total ordering of committed operations. Transaction commit returns the LSN to clients, enabling them to verify that subsequent reads observe at least that LSN's effects.

Raft and Multi-Paxos replicate logs through consensus, ensuring all non-faulty replicas eventually contain identical log prefixes. Leader election integrates with log replication—only replicas with sufficiently up-to-date logs can become leader, preventing committed data loss.

**Synchronous Replication for Durability**

Synchronous replication to N replicas tolerates N-1 failures without data loss. The coordinator blocks transaction commit until receiving acknowledgment from all synchronous replicas. This provides maximum durability at the cost of increased commit latency and reduced availability when replicas become unreachable.

Quorum-based durability relaxes full synchronous replication by requiring acknowledgment from W out of N replicas. Setting W = N provides full durability; W < N trades potential data loss (when fewer than W replicas survive) for improved availability and latency.

**Group Commit and Batching**

Group commit amortizes fsync costs by batching multiple transactions' log writes into single I/O operations. The coordinator accumulates transactions during a window, then flushes all logs in a single operation. This increases throughput at the cost of slightly increased per-transaction latency.

Pipeline commit overlaps transaction processing with log replication. The coordinator begins executing subsequent transactions while previous transactions' log entries replicate asynchronously. This hides replication latency but requires careful handling of dependencies between pipelined transactions.

**Durability vs. Availability Trade-offs (PACELC)**

PACELC extends CAP by considering latency during normal operation: if Partitioned, choose Availability or Consistency; Else (no partition), choose Latency or Consistency. Durability requirements interact with this framework—synchronous replication provides strong durability and consistency but increases latency and reduces availability.

Asynchronous replication reduces commit latency by acknowledging transactions before replica confirmation. The replication lag window represents the maximum data loss exposure during coordinator failure. Systems must explicitly document durability guarantees and acceptable loss windows.

### Cross-Shard Transactions

**Distributed Deadlock Detection**

Wait-for graphs spanning multiple nodes require global cycle detection. Centralized deadlock detection aggregates local wait-for graphs at a designated node, which searches for cycles periodically. This introduces detection latency and coordinator failure vulnerability.

Distributed deadlock detection algorithms (edge-chasing, path-pushing) propagate wait-for information between nodes without centralized coordination. Each node maintains local graph fragments; probe messages traverse wait-for edges to detect cycles. False positives may occur due to message delays, requiring confirmation before aborting transactions.

Timeout-based deadlock prevention treats long-waiting transactions as deadlocked and aborts them. This trades false positives (aborting transactions that would eventually complete) against simpler implementation and predictable maximum wait times.

**Transaction Routing**

Partition-aware routing directs single-partition transactions to the owning node, avoiding distributed coordination overhead. Multi-partition transactions require coordinator selection—typically the client's connected node or the partition containing the most accessed data.

Coordinator selection affects performance due to network topology. Choosing a coordinator collocated with the majority of accessed partitions reduces cross-datacenter latency for geographically distributed systems.

**Optimistic Concurrency Control (OCC)**

Transactions execute speculatively without acquiring locks, buffering writes locally. Validation phase at commit detects conflicts by checking whether any read or written data changed during transaction execution. This works well for low-contention workloads but experiences high abort rates under contention.

Distributed OCC requires coordinating validation across all participating nodes. Validation messages carry transaction read/write sets; participants check for conflicts with committed transactions. Any participant detecting conflict forces global abort.

Timestamp-based validation assigns begin and commit timestamps to transactions, checking that read data versions fall within the transaction's timestamp range. This requires globally synchronized clocks or logical clock protocols.

**Deterministic Transaction Execution**

Pre-declared read/write sets enable lock acquisition in predetermined order, eliminating distributed deadlocks. Calvin-style systems sequence transactions through consensus before execution, enabling single-replica execution without additional coordination.

Stored procedures with deterministic logic execute identically across replicas when applied in the same order. This enables active replication where all replicas execute transactions independently, eliminating replication lag. Non-deterministic operations (random numbers, timestamps) require coordinator provision.

### Consistency-Availability Trade-offs

**Highly Available Transactions (HAT)**

[Inference] HAT systems provide ACID semantics without requiring coordination between replicas during normal operation, typically through either commutative operations (CRDT-based) or deferred constraint checking. However, these systems cannot provide all traditional ACID guarantees—they typically sacrifice some aspect of isolation or consistency to achieve coordination-free availability.

**Compensating Transactions (Sagas)**

Long-running transactions decompose into sequences of shorter subtransactions with compensating actions for rollback. Each subtransaction commits independently, relaxing atomicity across the full transaction. Failure triggers execution of compensation actions for completed subtransactions in reverse order.

Forward recovery continues executing remaining subtransactions despite failures, using retries or alternative actions. Backward recovery aborts and compensates. Hybrid approaches attempt forward recovery with fallback to compensation.

Saga coordination via choreography distributes coordination across participants using event-driven communication. Each service subscribes to relevant events and publishes completion/failure events. Orchestration centralizes coordination in a saga coordinator that explicitly invokes services and handles compensation.

### Consensus-Based ACID

**Replicated State Machines**

Consensus protocols ensure all non-faulty replicas apply operations in identical order. Raft, Multi-Paxos, and Zab provide fault-tolerant log replication; state machine semantics emerge by applying logged operations deterministically.

Each operation becomes a log entry proposed to the consensus group. Leader election ensures at most one leader per term/epoch. The leader serializes operations into log positions; followers replicate and acknowledge entries. Entries become committed once replicated to a majority quorum.

Linearizable reads require either reading from committed log entries (consensus-based reads) or using leader leases that guarantee no concurrent leader exists. Read-only operations may bypass log replication through lease-based optimizations, reducing read latency.

**Atomic Broadcast**

Totally ordered, reliable broadcast ensures all replicas deliver messages in identical order. Atomic broadcast is equivalent to consensus—protocols solving one can implement the other. Practical systems often build transactions atop atomic broadcast primitives.

Virtual synchrony provides atomic broadcast with membership changes, allowing replicas to join/leave while maintaining message ordering guarantees. View changes demarcate membership transitions; messages delivered within a view maintain total order.

### Clock Synchronization and Timestamps

**Physical Clock Challenges**

Clock skew between nodes causes timestamps from different nodes to disagree about operation ordering. NTP synchronization provides millisecond-level accuracy under normal conditions but can experience seconds of drift during network disruptions.

TrueTime (Google Spanner) uses GPS and atomic clocks to bound clock uncertainty. Each timestamp is an interval [earliest, latest] rather than single value. Transactions wait out the uncertainty bound before commit, ensuring commit timestamps reflect real-time ordering.

**Logical and Hybrid Clocks**

Lamport logical clocks provide happened-before partial ordering without physical time synchronization. Each process maintains a counter incremented for each operation; messages carry sender's counter value. Receiver updates its counter to max(local, received) + 1.

Vector clocks extend Lamport clocks with per-process counters, enabling causality detection. Vector [3,2,5] indicates process 0 at logical time 3, process 1 at time 2, process 2 at time 5. Comparing vectors determines whether events are causally ordered or concurrent.

Hybrid logical clocks (HLC) combine physical time with logical counters, providing causality tracking while maintaining approximate wall-clock correlation. This enables both causality detection and time-based queries/GC without centralized timestamp services.

**Timestamp Allocation Strategies**

Centralized timestamp oracle assigns globally unique, monotonically increasing timestamps from a single authority. This creates a scalability bottleneck but simplifies correctness. Batching reduces RPC overhead—clients request timestamp ranges, allocating locally until exhausted.

Decentralized timestamp allocation partitions the timestamp space across multiple oracles. Each oracle allocates from its designated range. This requires either low-order bits encoding oracle ID (breaking monotonicity across oracles) or coordination for range reallocation.

Clock-SI uses loosely synchronized physical clocks directly as timestamps without centralized allocation. Commit protocols include uncertainty intervals to handle clock skew, with wait periods ensuring real-time ordering preservation within bounded error.

### Partition Handling

**CP Systems (Consistency and Partition Tolerance)**

Systems sacrificing availability during partitions maintain consistency by refusing operations in minority partitions. Quorum-based systems require majority partition membership; minority partitions block writes (and possibly reads depending on quorum configuration).

Split-brain prevention ensures at most one partition accepts writes. Fencing mechanisms include epoch numbers invalidating stale leaders, coordination service leases that expire, or storage-level fencing preventing I/O from deposed primaries.

**AP Systems (Availability and Partition Tolerance)**

Systems sacrificing consistency during partitions accept operations in all partitions, deferring conflict resolution until partition healing. Version vectors track causality across divergent replicas; conflicts require application-level resolution or automated policies (last-write-wins, merge functions).

Eventual consistency bounds specify maximum divergence windows (time or operation count) before convergence. Bounded staleness provides tunable consistency where applications specify acceptable staleness thresholds.

**Consistency During Partition Healing**

Anti-entropy protocols reconcile divergent state after partition recovery. Merkle tree comparison identifies divergent key ranges requiring detailed reconciliation. Read repair opportunistically fixes divergence during read operations by comparing responses from multiple replicas.

Hinted handoff queues operations destined for unreachable replicas on substitute nodes. When partitions heal, queued operations replay to intended replicas. Hints have bounded lifetime to prevent unbounded queue growth.

### Transaction Isolation Anomalies

**Dirty Reads**

Transaction observes uncommitted data from concurrent transaction. Distributed dirty reads occur when reading from replicas with uncommitted or rolled-back data. MVCC prevents dirty reads by restricting visibility to committed versions.

**Non-Repeatable Reads**

Transaction observes different values for the same data item across multiple reads. Distributed systems experience this when reading from replicas with varying replication lag. Snapshot isolation prevents non-repeatable reads by fixing snapshot at transaction start.

**Phantom Reads**

Transaction's predicate queries return different result sets across multiple executions due to concurrent inserts/deletes. Distributed phantoms arise from concurrent modifications across partitions. Predicate locking or serializable snapshot isolation prevents phantoms.

**Write Skew**

Two transactions read overlapping data and write disjoint data, with each write depending on read values. The resulting state violates application invariants that would be maintained under serial execution. Snapshot isolation permits write skew; serializability prevents it through conflict detection.

**Lost Updates**

Two transactions read a value, compute new values based on the read, and write back. One transaction's update overwrites the other without incorporating its changes. Compare-and-swap or version-based optimistic locking prevents lost updates.

### Atomic Commitment Alternatives

**Paxos Commit**

Replaces 2PC coordinator with replicated state machine implementing commit protocol. Coordinator failure does not block transaction completion—the replicated coordinator continues after leader election. Each participant replicates prepare votes through Paxos, ensuring fault-tolerant participant state.

This increases message complexity (Paxos rounds at each participant) but eliminates single point of failure. Practical only for high-value transactions where blocking costs exceed protocol overhead.

**Consensus-Free Transactions**

Invariant confluence identifies operations that commute and can execute without coordination. CRDT-based systems implement commutative operations (counters, sets, graphs) that converge without coordination. Applications must express logic using invariant-confluent operations.

Coordination avoidance techniques analyze transaction semantics to identify coordination requirements. Read-only transactions avoid coordination; single-partition transactions coordinate locally. Only multi-partition transactions modifying related data require distributed coordination.

### ACID with Geo-Distribution

**Cross-Region Latency Impact**

Round-trip times between regions (50-300ms) dominate transaction commit latency for synchronous replication. Multi-region ACID transactions may exceed second-level latencies when coordination spans continents.

Regional commit optimization acknowledges transactions after regional quorum achievement, asynchronously replicating to remote regions. This provides regional durability with cross-region eventual consistency.

**Affinity-Based Partitioning**

Co-locating related data in the same region reduces cross-region coordination. User data partitioned by geographic residence enables most transactions to execute within single region. Foreign-key relationships and access patterns inform partitioning strategies.

**Quorum Placement**

Asymmetric quorums optimize for local writes—primary region requires only local replicas for write quorum, with asynchronous replication to remote regions. Regional failures require failover to remote region with eventual consistency window for recent writes.

Symmetric quorums distribute replicas across regions with majority quorum requirements. Write latency increases to slowest replica in quorum, but regional failures maintain immediate consistency.

### Related Topics

- Two-phase commit (2PC) and three-phase commit (3PC)
- Consensus protocols (Paxos, Raft, Zab)
- Multi-version concurrency control (MVCC)
- Timestamp ordering and logical clocks
- Quorum systems and voting protocols
- CAP theorem and PACELC framework
- Saga pattern and compensating transactions
- Serializable snapshot isolation (SSI)
- Distributed deadlock detection
- Optimistic concurrency control (OCC)
- Replicated state machines
- Vector clocks and version vectors
- Hybrid logical clocks (HLC)
- TrueTime and clock synchronization
- Conflict-free replicated data types (CRDTs)
- Write-ahead logging (WAL)
- Eventual consistency and strong eventual consistency
- Partition tolerance and split-brain prevention
- Transaction isolation levels
- Atomic broadcast and total order

---

