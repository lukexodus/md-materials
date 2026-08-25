## Transaction Models


### Flat Transactions

Single-level atomic unit executing sequence of operations as indivisible block. All operations commit together or abort together. No internal structure or subtransaction hierarchy.

**ACID Properties**: Atomicity guarantees all-or-nothing execution. Consistency maintains invariants across transaction boundary. Isolation prevents interference from concurrent transactions. Durability ensures committed results survive failures.

**Two-Phase Commit (2PC)**: Coordinator sends PREPARE to all participants. Participants vote YES (with local locks held and undo/redo logs forced to stable storage) or NO. Coordinator decides COMMIT if unanimous YES, otherwise ABORT. Decision logged to stable storage before sending final message to participants.

**Blocking Nature**: Participants blocked during coordinator failure between PREPARE and final decision. Cannot unilaterally release locks without risking inconsistency. Requires timeout-based failure detection and recovery protocol. Coordinator failure during commit phase leaves participants uncertain, holding locks indefinitely until coordinator recovery or manual intervention.

**Three-Phase Commit (3PC)**: Adds PRE-COMMIT phase between PREPARE and COMMIT. Coordinator sends PRE-COMMIT after unanimous YES votes, participants acknowledge. Only then does coordinator send COMMIT. Eliminates blocking under single failure but requires synchronous network assumptions and bounded message delays. Network partitions still cause unavailability or safety violations.

**Write-Ahead Logging (WAL)**: All modifications recorded to sequential log before applying to primary data structures. Log records contain before-images (undo) and after-images (redo). Transaction commit requires forcing commit record to stable storage. Crash recovery replays log: undo incomplete transactions, redo committed transactions.

**Lock-Based Concurrency**: Two-phase locking (2PL) ensures serializability. Growing phase acquires locks, shrinking phase releases locks. Strict 2PL holds all locks until commit/abort to prevent cascading aborts. Deadlock detection via wait-for graph analysis or deadlock prevention via timeout-based abort.

**Limitations**: Long-running transactions hold locks for extended duration, blocking concurrent access. No partial commit or partial rollback within transaction. Single failure point aborts entire transaction. Cannot express complex workflows requiring selective retry or compensation.

### Nested Transactions

Hierarchical transaction structure where parent transaction spawns child subtransactions. Each subtransaction executes independently with own ACID properties relative to parent.

**Tree Structure**: Root transaction at top level. Internal nodes represent subtransactions. Leaf nodes perform actual data operations. Parent transaction commits only if all children commit. Child abort does not force parent abort (depends on model variant).

**Commit Semantics**: Child commit is provisional, contingent on parent commit. Committed child results visible only to parent and descendants until parent commits. Child abort can be handled by parent through alternative execution paths or compensation. Top-level commit makes entire tree permanent. Top-level abort recursively aborts all descendants.

**Isolation Levels**: Child sees parent's updates. Siblings isolated from each other (closed nested transactions) or can share state (open nested transactions). Descendants inherit locks from ancestors but can acquire additional locks. Lock inheritance creates hierarchical locking protocol.

**Recovery**: Partial rollback to savepoint within transaction hierarchy. Parent can abort specific child and retry without aborting entire tree. Crash recovery reconstructs transaction tree from log, aborting incomplete subtransactions while preserving committed siblings.

**Advantages**: Modularity and composition. Subsystems expose transactional interfaces composable into larger transactions. Selective retry of failed subtransactions without full transaction restart. Parallelism through concurrent sibling execution with serializability guarantees.

**Disadvantages**: Implementation complexity. Hierarchical locking overhead. Cascading aborts still possible if parent aborts. Deadlock detection requires analysis across transaction tree. Log management for nested commit records increases storage overhead.

### Closed Nested Transactions

Strict isolation between sibling subtransactions. Siblings cannot observe each other's uncommitted state. Committed child state visible only to parent, not other children.

**Lock Retention**: Child releases locks to parent upon commit, not to global lock manager. Parent inherits child's locks. Siblings cannot acquire conflicting locks on items modified by committed siblings until parent commits or explicitly transfers locks.

**Serializability**: Ensures conflict-serializable execution across entire transaction tree. Eliminates anomalies from concurrent sibling access to shared data. Simplifies correctness reasoning but reduces concurrency opportunities.

**Use Cases**: Workflow systems where stages must execute in isolation. Multi-phase operations requiring rollback to intermediate consistent states. Subsystem integration where components should not observe partial states of other components.

### Open Nested Transactions

Relaxed isolation allowing sibling communication and state sharing. Child commit releases locks to global lock manager, making results visible to concurrent transactions outside parent scope.

**Early Lock Release**: Committed child immediately releases locks rather than transferring to parent. Increases concurrency by allowing other transactions to access modified data before parent commits. Violates strict serializability but maintains semantic correctness through compensation.

**Compensation-Based Recovery**: Parent abort requires explicit compensation of committed children. Compensation logic undoes semantic effects of committed child through application-specific inverse operations. Example: child transaction debits account, compensation credits account.

**Multilevel Transactions**: Variant of open nesting where operations at different abstraction levels form nested structure. High-level operations decompose into lower-level operations. Lower-level commits release physical locks while maintaining semantic locks at higher level.

**Use Cases**: Long-running sagas requiring partial commitment. Systems where strict isolation overhead outweighs benefits. Operations with well-defined semantic inverses allowing reliable compensation.

### Saga Pattern

Sequence of local transactions coordinated without distributed locking. Each local transaction commits immediately, releasing locks. Rollback achieved through compensating transactions executing inverse operations.

**Forward Recovery**: Execute transactions T1, T2, ..., Tn sequentially. Each Ti commits upon completion. If Ti fails, execute compensating transactions C(i-1), C(i-2), ..., C1 in reverse order. Final state either all transactions committed or all compensated.

**Orchestration**: Central coordinator invokes each transaction step and tracks completion state. Coordinator stores compensation log for recovery. Failure of coordinator requires durable state and recovery protocol. Coordinator becomes bottleneck and single point of failure.

**Choreography**: Distributed coordination through event-driven architecture. Each service listens for completion events from predecessor, executes local transaction, publishes event for successor. No central coordinator. Compensation triggered by publishing rollback events. Requires event delivery guarantees and idempotency.

**Compensating Transaction Constraints**: Compensation may not be perfect inverse. Example: cannot uncompose shipped order or unrefund payment. Semantic compensation approximates inverse while maintaining business invariants. Compensation must be idempotent to handle retry after failure.

**Isolation Violations**: Dirty reads possible as intermediate states visible to concurrent transactions. Lost updates possible if concurrent transaction modifies data between saga step and compensation. Requires application-level conflict detection or semantic locking.

**Use Cases**: Microservices architectures where distributed transactions undesirable. Long-running business processes spanning multiple services. Cross-organizational workflows where distributed locking infeasible.

### Split Transactions

Decomposes transaction into multiple independent transactions with application-managed consistency. Each split executes and commits separately. Application logic ensures cross-split invariants through explicit synchronization or compensation.

**Semantic Atomicity**: Atomicity enforced at application semantic level rather than transaction system level. Application defines consistency requirements and implements enforcement logic. Allows trading strict atomicity for availability and performance.

**Explicit Checkpointing**: Application periodically commits intermediate state as savepoints. Failure triggers restart from last checkpoint rather than complete restart. Reduces wasted work at cost of application-managed recovery complexity.

**Eventual Consistency**: Splits may temporarily violate invariants, converging to consistent state through background reconciliation. Requires idempotent operations and conflict resolution logic. Trades immediate consistency for reduced coordination overhead.

**Use Cases**: Batch processing systems with periodic checkpoints. Workflows tolerating temporary inconsistency. Systems prioritizing availability over strong consistency (AP in CAP).

### Concurrency Control in Nested Transactions

**Hierarchical 2PL**: Locks organized in tree structure mirroring transaction tree. Child inherits read locks from parent as read locks. Child converts parent's read lock to write lock when writing. Parent cannot release locks held by active children.

**Timestamp Ordering**: Each subtransaction assigned timestamp from parent's range. Parent timestamp interval subdivided among children. Ensures child operations ordered after parent's previous operations and before parent's future operations. Deadlock-free but may cause aborts from timestamp conflicts.

**Optimistic Concurrency**: Each subtransaction maintains read/write sets. Validation at commit checks for conflicts with concurrent transactions and siblings. Forward validation checks descendants, backward validation checks ancestors. Abort on conflict. Reduces locking overhead but increases abort rate under contention.

**MVCC (Multi-Version Concurrency Control)**: Each transaction reads snapshot from specific version. Child reads parent's version. Child writes create new versions visible only to parent and descendants. Version garbage collection deferred until top-level commit. Eliminates read-write conflicts but increases storage overhead.

### Distributed Nested Transactions

**Distributed Commit**: Two-phase commit extended across subtransaction tree. Root coordinator initiates PREPARE propagation down tree. Leaf-to-root voting phase. Root decides commit/abort, propagates decision down tree. Subtransaction coordinators act as participants to parent and coordinators to children.

**Partial Replication**: Subtransactions may execute on different nodes. Parent must coordinate children across network partitions. Child failure or network partition may abort individual child while allowing parent to continue with alternative children.

**Cascading Failures**: Parent node failure orphans entire subtree. Orphaned subtransactions must detect parent failure and self-abort. Requires parent heartbeat monitoring or timeout-based orphan detection. Presume-abort recovery assumes orphaned transactions aborted unless explicit commit record found.

**Coordinator Placement**: Root coordinator placement impacts latency and availability. Centralized placement creates bottleneck. Distributed coordinator migration based on child locality reduces coordination overhead but complicates failure recovery.

### Transaction Chopping

Decomposes transaction into smaller pieces to reduce lock holding time while preserving serializability. Each piece executes as separate transaction with explicit dependencies.

**Chopping Algorithm**: Constructs conflict graph of transaction operations. Partitions graph into pieces such that concurrent execution remains serializable. Introduces explicit dependencies (ordering constraints) between pieces to prevent cycles in global serialization order.

**Lock Holding Time**: Smaller pieces release locks earlier, increasing concurrency. Reduces probability of deadlock. May increase total execution time due to coordination overhead between pieces.

**Serializability Preservation**: Must ensure chopped execution equivalent to some serial execution of original transactions. Static analysis determines valid choppings. Dynamic enforcement uses dependency tracking or version ordering.

**Use Cases**: OLTP workloads with hot spots. Long transactions monopolizing shared resources. Systems where reducing lock contention outweighs coordination overhead.

### Implementation Considerations

**Log Management**: Nested transactions generate hierarchical log records. Each subtransaction has own begin/commit/abort records. Parent commit requires forcing all descendant commit records. Log replay during recovery reconstructs transaction tree and applies/undoes operations accordingly.

**Lock Management**: Hierarchical lock tables or lock inheritance mechanisms. Parent transaction id used as lock owner. Child locks annotated with full ancestry path. Lock manager must traverse tree during conflict detection and deadlock analysis.

**Deadlock Detection**: Wait-for graph extended to transaction tree. Edge from transaction T1 to T2 if T1 waits for lock held by T2 or T2's ancestor. Cycle detection algorithm must consider transitive ancestor relationships. Victim selection prefers aborting younger or smaller transactions.

**Performance Overhead**: Nested transaction management increases CPU, memory, and I/O overhead. Log record volume grows with tree depth. Lock table size scales with active transaction count times average tree depth. Practical systems limit nesting depth or use lightweight subtransaction variants for common cases.

**Language Support**: Transactional memory abstractions (atomic blocks in programming languages). Checkpoint/restore APIs for split transactions. Saga frameworks with declarative compensation specification. Transaction context propagation through remote procedure call (RPC) frameworks.

### Related Topics

- Two-phase commit and three-phase commit protocols
- Distributed deadlock detection and resolution
- Optimistic concurrency control and validation schemes
- Multi-version concurrency control (MVCC)
- Savepoints and partial rollback mechanisms
- Compensation-based recovery and saga orchestration
- Transactional memory and software transactional memory (STM)
- Isolation levels (Read Uncommitted, Read Committed, Repeatable Read, Serializable)
- Distributed consensus for transaction commit coordination
- Event sourcing and command query responsibility segregation (CQRS)

---

