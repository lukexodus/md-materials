## Concurrency


### Shared-Nothing Architecture

**Process Isolation Models**

Actor-based concurrency (Erlang OTP, Akka) eliminates shared mutable state through message passing. Each actor maintains private state, communicating via asynchronous mailboxes. Supervision hierarchies provide fault isolation—supervisor actors restart failed children without affecting siblings. Message delivery guarantees range from at-most-once (fire-and-forget) to at-least-once (with acknowledgments). Actor location transparency enables transparent distribution across nodes.

**Partitioned State Stores**

Horizontal partitioning assigns disjoint key ranges to separate processing nodes. Consistent hashing distributes load while minimizing rebalancing during topology changes. Each partition operates independently, eliminating cross-partition coordination for single-key operations. Range queries spanning multiple partitions require scatter-gather execution. Partition rebalancing during scale operations causes temporary unavailability windows.

**Share-Nothing OLAP Systems**

MPP databases (Redshift, Snowflake compute layer) assign table partitions to isolated compute nodes. Each node processes its partition shard independently during parallel scans. Hash-distributed tables enable co-located joins without data movement. Broadcast joins replicate small dimension tables to all nodes. Query coordinators aggregate partial results without touching data plane traffic.

### Optimistic Concurrency Control

**Multi-Version Concurrency Control (MVCC)**

Read transactions observe consistent snapshots without blocking writers. Writers create new tuple versions tagged with transaction IDs. Garbage collection prunes obsolete versions based on minimum active transaction ID. Snapshot isolation permits write skew anomalies unless serializable snapshot isolation (SSI) detects read-write conflicts. PostgreSQL's xmin/xmax tuple headers track version visibility.

**Timestamp Ordering**

Transactions receive monotonically increasing timestamps from centralized or hybrid logical clock sources. Read/write operations check timestamp ranges on accessed data items. Conflicting transactions abort based on timestamp precedence. Thomas Write Rule allows committing transactions that arrive out-of-timestamp-order if no readers observed intermediate state. HLC (Hybrid Logical Clocks) combine physical time with logical counters to preserve causality across nodes.

**Optimistic Locking with Version Vectors**

Each data item carries version identifier (integer counter, UUID, hash). Read operations capture current version. Write operations include expected version in update request. Backend performs compare-and-swap—reject if current version differs. Client retries with fresh version after reading latest state. Vector clocks detect concurrent modifications in multi-master scenarios.

### Pessimistic Concurrency Control

**Two-Phase Locking (2PL)**

Growing phase acquires shared (read) and exclusive (write) locks. Shrinking phase releases all locks atomically at commit. Strict 2PL delays all lock releases until transaction completion, preventing cascading aborts. Shared locks permit concurrent readers, exclusive locks block all others. Lock escalation converts multiple row locks to table locks to conserve memory.

**Deadlock Detection and Prevention**

Wait-for graphs track lock dependencies between transactions. Cycle detection algorithms (depth-first search) identify deadlocks. Victim selection heuristics minimize aborted work (youngest transaction, least work completed). Deadlock prevention assigns total ordering to lock acquisition (ordered by resource ID). Lock timeout-based detection trades false positives for detection simplicity.

**Intent Locks and Lock Hierarchies**

Intent locks (IS, IX, SIX) signal lock intention at coarse granularity. Reduce lock manager overhead by checking compatibility at table level before row-level acquisition. Shared-intent-exclusive (SIX) lock supports table scan with selective row updates. Lock compatibility matrix determines blocking relationships. Hierarchical locking enables efficient range scans without locking individual keys.

### Distributed Coordination Primitives

**Distributed Locks**

Lease-based locks with TTL expiration prevent indefinite holds during network partitions. Fencing tokens (monotonic counters) prevent stale lock holders from corrupting state. Redlock algorithm across Redis instances provides fault-tolerant distributed locks (though contended in academic literature). Chubby (Google) and ZooKeeper provide strongly consistent lock services atop Paxos/ZAB. Ephemeral nodes automatically release locks when client sessions disconnect.

**Barriers and Phasers**

Distributed barriers synchronize multiple processes at rendezvous points. Phaser-style coordination supports dynamic participant registration. Two-phase coordination: arrival phase (participants signal readiness), departure phase (leader releases all). ZooKeeper watchers implement arrival notification. Leader election determines barrier release authority. Timeout mechanisms handle stragglers or failures.

**Semaphores and Quota Management**

Distributed semaphores limit concurrent access to shared resources (connection pools, API rate limits). Centralized quota servers track resource consumption. Hierarchical quota allocation assigns budgets to sub-partitions. Lease-based reservations prevent quota hoarding. Eventual consistency quota systems (AWS service quotas) trade accuracy for availability. Sticky routing directs related requests to same quota tracker.

### Concurrency in Event-Driven Architectures

**Event Sourcing Concurrency**

Aggregate roots serialize command processing. Optimistic concurrency checks aggregate version on command handling. Event stream append operations use compare-and-swap on version. Concurrent commands to same aggregate fail with version conflict. Retries reload current state and re-execute command logic. Snapshot versioning tracks aggregate state checkpoints.

**Stream Processing Parallelism**

Kafka partition assignment distributes load across consumer group members. Each partition maintains strict ordering, cross-partition ordering relaxed. Stateful stream processors (Kafka Streams, Flink) partition state by key. Watermarking handles out-of-order events in windowed aggregations. Checkpointing coordinates distributed snapshots for exactly-once processing.

**Saga Pattern Coordination**

Choreography-based sagas use event subscriptions for step coordination. Each service publishes domain events after local transaction commits. Compensating transactions undo partial saga execution. Orchestration-based sagas centralize coordination logic in orchestrator service. Orchestrator tracks saga state and issues commands to participants. State persistence in orchestrator prevents lost coordination during failures.

### Concurrency Control in Distributed Databases

**Percolator Transactions**

Bigtable-based distributed transactions using two-phase commit over arbitrary keys. Write intents mark rows undergoing modification. Primary lock coordinates transaction commit. Lazy cleanup removes committed write intents. Transaction manager assigns monotonic start timestamps. Conflict resolution uses first-writer-wins policy.

**Calvin Deterministic Concurrency**

Pre-ordering layer sequences all transactions before execution. Deterministic locking avoids distributed deadlock detection. Replica groups execute transactions in identical order. Cross-partition transactions acquire locks in global order. Sequencer layer provides total ordering guarantees. Replication lag affects read freshness but not consistency.

**Spanner External Consistency**

TrueTime API provides bounded clock uncertainty (epsilon). Commit wait delays transaction commits by epsilon to ensure external consistency. Paxos groups provide synchronous replication within replica set. Two-phase commit coordinates cross-Paxos-group transactions. Read-only transactions use snapshot reads at safe timestamps. Strongly consistent reads block until replica applies all preceding writes.

### Backpressure and Flow Control

**Reactive Streams Backpressure**

Subscribers signal demand to publishers. Publishers respect demand limits, buffering excess. Bounded buffers drop or reject messages exceeding capacity. Strategies: drop-oldest, drop-newest, fail-fast, block-caller. Asynchronous demand signaling prevents blocking publisher threads. Watermark thresholds trigger demand replenishment.

**TCP Flow Control in RPC**

Receive window advertisements limit sender transmission rate. Zero-window probing detects receiver readiness. Nagle's algorithm batches small writes, trading latency for efficiency. Delayed ACK timer reduces ACK packet count. GRPC HTTP/2 flow control applies at both stream and connection level. Window update frames signal available buffer space.

**Service Mesh Circuit Breaking**

Connection pool limits prevent resource exhaustion. Concurrent request limits shed load beyond service capacity. Pending request timeouts fail fast. Consecutive error thresholds trigger open circuit state. Half-open state tests service recovery with limited traffic. Bulkhead isolation prevents cascading failures across service boundaries.

### Concurrency Testing and Verification

**Jepsen-Style Fault Injection**

Network partition injection isolates nodes mid-transaction. Clock skew injection tests timestamp-based protocols. Crash-recovery cycles verify durability claims. Linearizability checkers validate operation histories. Nemesis component induces faults during workload execution. Model checking confirms correctness under adversarial scheduling.

**Concurrency Fuzzing**

Randomized thread scheduling exposes race conditions. Memory fence injection tests relaxed memory models. Atomic operation interleaving explores edge cases. Property-based testing generates concurrent operation sequences. Record-replay debugging captures nondeterministic failures.

**Static Analysis for Concurrency**

Happens-before analysis detects data races. Lock order verification prevents deadlocks. Escape analysis identifies shared mutable state. Thread-safety annotations (e.g., Rust's Send/Sync traits) enforce compile-time guarantees. Model checkers (TLA+, Alloy) verify protocol correctness.

**Related Topics**

Consensus protocols (Paxos, Raft), distributed transactions (2PC, 3PC), CRDTs, causal consistency, distributed snapshot algorithms, quorum-based replication

---

