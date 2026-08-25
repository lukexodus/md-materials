## Recovery Strategies


Recovery strategies restore failed processes to consistent states enabling continued execution after crashes. Checkpointing and message logging form the foundational mechanisms for fault tolerance in distributed systems, trading off recovery time, performance overhead during failure-free execution, and storage requirements.

### Checkpointing Fundamentals

Checkpointing captures process state snapshots to stable storage at intervals. Process state includes memory contents, register values, open file descriptors, network connection state, and application-specific data structures. Upon failure, processes restart from the most recent checkpoint rather than initial state, limiting lost computation to work performed since the checkpoint.

**Independent checkpointing**: Each process checkpoints autonomously without coordination. Simplest implementation with minimal runtime overhead, but creates recovery complications. After failure, restored checkpoint may reflect a state that never existed in any consistent global system execution due to inter-process dependencies.

**Coordinated checkpointing**: All processes synchronize to create a globally consistent checkpoint—a distributed snapshot where no messages are in-transit between checkpointed states. Coordination eliminates domino effects but introduces synchronization overhead and reduces checkpoint frequency. Blocking coordination suspends all processes during checkpoint coordination; non-blocking variants use background checkpoint protocols.

**Communication-induced checkpointing**: Processes take forced checkpoints based on message patterns to maintain recovery line properties without explicit global coordination. Piggybacks control information on application messages to detect potential inconsistencies and trigger checkpoints prophylactically.

### Consistent Global States

A consistent global state satisfies causality constraints: if state includes an event, it includes all causally preceding events. For message-based systems, consistency requires that if a process's checkpoint reflects message receipt, some checkpoint must reflect that message's send. Orphan messages (received but sender's checkpoint predates send) violate consistency.

Recovery lines represent consistent global states from which recovery can proceed. The checkpoint interval between consistent recovery lines determines maximum rollback distance. Systems must identify recovery lines efficiently during recovery to avoid cascading rollbacks (domino effect) where one process's rollback forces other processes to roll back, potentially cascading to system initialization.

### Message Logging Protocols

Message logging records non-deterministic events (primarily message receives and their delivery order) to enable deterministic replay during recovery. Combines with periodic checkpointing: recover to checkpoint then replay logged messages to reconstruct lost computation.

**Pessimistic logging**: Logs each message to stable storage before allowing dependent computation. Guarantees each message logged before any causally dependent output becomes visible externally. Synchronous writes to stable storage create performance bottlenecks but provide strongest consistency: failed processes can always recover to immediately before failure.

**Optimistic logging**: Logs messages asynchronously to stable storage while allowing immediate computation. Assumes failures are rare; sacrifices some committed work if failure occurs before logging completes. Orphan processes (have dependencies on logged but not yet stable-stored messages) must roll back to consistent states, potentially creating cascading rollbacks.

**Causal logging**: Logs message dependencies rather than message contents when possible. Tracks causal relationships between messages using vector clocks or dependency matrices. During recovery, reconstructs message delivery order from causal constraints and locally available information, reducing stable storage overhead.

### Deterministic Replay

Recovery executes deterministic replay: restores checkpoint then reprocesses logged messages in recorded order. Replay must reconstruct identical execution paths including:

**Message delivery order**: Replays messages in precisely recorded sequence to recreate original execution interleaving. Message content and sender identity must match original delivery.

**Non-deterministic system calls**: System call return values (timestamps, random values, I/O results) must be logged if they affect control flow or state. Replay substitutes logged values for actual system call execution.

**Threading and concurrency**: Thread scheduling decisions, lock acquisition orders, and race condition outcomes must be logged or execution must be deterministically controlled during replay.

### Checkpoint Consistency Models

**Strongly consistent checkpoints**: Reflect a valid global state where all inter-process dependencies are satisfied. Channel states (messages in-transit) are either empty or explicitly captured. Chandy-Lamport distributed snapshot algorithm produces strongly consistent checkpoints without halting computation.

**Weakly consistent checkpoints**: May contain orphan messages or missing messages. Require message logging to restore consistency during recovery. Simpler checkpoint protocols at the cost of increased logging complexity.

**Application-level checkpoints**: Applications define checkpointable state and consistency requirements explicitly. Reduces checkpoint size by excluding reconstructible state. Requires application awareness of checkpointing semantics.

### Storage and Overhead Management

**Checkpoint size**: Full process memory dumps create large checkpoints. Incremental checkpointing stores only modified pages since previous checkpoint using copy-on-write or dirty page tracking. Compression reduces storage requirements at CPU cost.

**Checkpoint frequency**: More frequent checkpoints reduce rollback distance and logged message volume but increase overhead. Optimal frequency balances checkpoint cost against expected failure rate and recovery cost.

**Garbage collection**: Old checkpoints and message logs can be reclaimed once newer recovery lines supersede them. Output commit protocols identify when external outputs are irrevocable, allowing dependent checkpoint/log data to be garbage collected.

### Failure-Free Performance Overhead

**Checkpointing overhead**: CPU time for state serialization, memory bandwidth for copying, disk I/O for storage, and potential cache pollution. Incremental and copy-on-write techniques reduce but don't eliminate costs.

**Logging overhead**: Message copying, log record formatting, stable storage writes. Pessimistic logging incurs synchronous I/O latency on critical path. Optimistic and causal logging reduce immediate overhead but complicate recovery.

**Coordination overhead**: Coordinated checkpointing requires synchronization messages and potential process blocking. Communication-induced checkpointing piggybacks control data on messages, adding bandwidth overhead.

### Recovery Time Objectives

Recovery time depends on:

**Checkpoint retrieval latency**: Time to load checkpoint from stable storage (disk, distributed file system, remote backup).

**Replay duration**: Number of logged messages multiplied by message processing time. Long checkpoint intervals increase replay cost.

**Dependency resolution**: For optimistic or causal logging, computing consistent recovery states may require complex dependency analysis.

Fast recovery requires frequent checkpoints (reducing replay) balanced against checkpoint overhead during normal execution. Incremental checkpointing and efficient message logging reduce both storage costs and recovery time.

### Output Commit Problem

External outputs (messages to outside world, database commits visible externally, I/O operations) cannot be undone. Output commit protocols ensure outputs are only released after all causally dependent state is checkpointed or logged to stable storage.

**Pessimistic output commit**: Delays external output until dependent state is on stable storage. Guarantees exactly-once semantics but introduces output latency.

**Optimistic output commit**: Releases outputs immediately; if failure occurs before logging, system cannot recover to consistent state including that output. Acceptable when external systems can tolerate duplicates or lost outputs.

### Recovery Protocols

Upon failure detection:

1. **Checkpoint restoration**: Load most recent valid checkpoint for failed process
2. **Log retrieval**: Obtain message logs from stable storage
3. **Dependency analysis**: Identify which logged messages must be replayed
4. **Rollback propagation**: Determine if other processes must roll back to maintain consistency
5. **Replay execution**: Process logged messages in recorded order
6. **State reconstruction**: Rebuild in-memory data structures and resume normal operation

For coordinated checkpointing, recovery is straightforward: restore latest coordinated checkpoint and replay subsequent logged messages. For independent checkpointing, recovery line computation identifies the latest consistent global state, potentially requiring multiple processes to roll back to earlier checkpoints.

### Partitioned System Considerations

Network partitions complicate checkpoint consistency. Processes in different partitions may checkpoint independently, creating potential inconsistencies when partitions merge.

**Partition-aware checkpointing**: Tracks partition membership in checkpoints. Merge protocols reconcile states from diverged partitions, potentially requiring application-specific conflict resolution.

**Primary partition models**: Only designated primary partition checkpoints authoritatively. Minority partitions discard state upon merge. Sacrifices availability in non-primary partitions.

### Distributed Snapshot Algorithms

**Chandy-Lamport algorithm**: Initiator process checkpoints local state and sends marker messages on all outgoing channels. Recipients checkpoint upon first marker receipt and record messages received on each channel between local checkpoint and marker receipt for that channel. Produces consistent global snapshot including in-flight messages without halting system.

**Lai-Yang algorithm**: Piggybacks coloring scheme on application messages. Processes transition from white to red, checkpointing when transitioning. Messages capture sender's color, enabling consistent snapshot construction without explicit marker messages.

**Snapshot isolation**: In database systems, transaction snapshots provide point-in-time consistent views. Multiversion concurrency control (MVCC) maintains multiple data versions, allowing snapshot reads without blocking writes.

### Message Logging Implementation Patterns

**Sender-based logging**: Senders log messages they send. Requires failed process to retrieve logs from all potential senders during recovery. Distributes logging load but complicates recovery.

**Receiver-based logging**: Receivers log messages they receive. Centralizes recovery (failed process retrieves own log) but concentrates logging overhead on receivers.

**Logger-based logging**: Dedicated logging service receives message copies. Decouples logging from process execution but introduces logging service as potential bottleneck and single point of failure. Replication of logger provides fault tolerance.

### Transactional Systems Integration

Checkpoint-based recovery integrates with transaction processing systems:

**Transaction-consistent checkpoints**: Checkpoint boundaries align with transaction commit points. Checkpoints capture only committed transaction state, simplifying recovery semantics.

**ARIES recovery protocol**: Uses write-ahead logging (WAL) where log records reach stable storage before corresponding data pages. Recovery has three phases: analysis (determine recovery scope), redo (reapply committed transactions), undo (roll back incomplete transactions). Checkpoints in ARIES are fuzzy (taken without halting transactions), recording active transactions and dirty pages.

**Savepoints**: Intra-transaction checkpoints allowing partial rollback without aborting entire transaction. Useful for long-running transactions with potential for partial failures.

### Checkpoint Compression and Deduplication

**Content-addressable storage**: Stores checkpoint blocks by hash of contents. Duplicate blocks across checkpoints or processes stored once, reducing storage requirements.

**Delta compression**: Encodes differences between successive checkpoints rather than full state. Effective when state changes incrementally but requires chain of deltas to reconstruct arbitrary checkpoint.

**Application-guided checkpointing**: Applications identify hot and cold data, checkpointing frequently-modified state more often while amortizing cold state checkpoint costs.

### Failure Models and Recovery Guarantees

**Fail-stop failures**: Process halts detectably. Checkpointing and logging restore process to pre-failure state with deterministic replay guaranteeing equivalent execution.

**Byzantine failures**: Malicious behavior may corrupt checkpoints or logs. Requires authenticated checkpoints, voting-based recovery, and Byzantine fault-tolerant logging protocols.

**Correlated failures**: Multiple simultaneous failures (power outage, rack failure) may compromise checkpoint availability. Geographic replication of checkpoints and logs provides resilience against site failures.

### Performance Optimization Techniques

**Asynchronous checkpointing**: Checkpoint process state in background while process continues execution. Copy-on-write or shadow paging captures consistent snapshot without blocking foreground computation.

**Hardware-assisted checkpointing**: Memory protection mechanisms and page table manipulation accelerate incremental checkpointing. NVM (non-volatile memory) reduces checkpoint latency by eliminating mechanical storage delays.

**Adaptive checkpointing**: Dynamically adjusts checkpoint frequency based on workload characteristics, failure rates, and resource availability. Machine learning models predict optimal checkpointing schedules.

### [Inference] Operational Failure Modes

**Checkpoint corruption**: Bit errors in stable storage corrupt checkpoint data. Checksums and redundant storage detect and correct corruption.

**Log overflow**: Insufficient stable storage capacity causes log truncation. May force premature garbage collection, reducing recoverable history.

**Recovery storms**: Multiple simultaneous failures overwhelm recovery infrastructure. Rate limiting and prioritization prevent cascading system-wide failure.

**Incomplete recovery**: Partial state reconstruction due to missing logs or dependency cycles. May require manual intervention or fallback to earlier recovery line.

### Related Topics

- Chandy-Lamport Distributed Snapshot Algorithm
- ARIES Recovery Protocol
- Write-Ahead Logging (WAL)
- Rollback Recovery
- State Machine Replication
- Causal Ordering and Vector Clocks
- Non-Volatile Memory (NVM) Systems
- Transaction Processing Systems
- Fault Tolerance Mechanisms
- Process Migration and Live Migration

---

