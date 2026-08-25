## Distributed Commit Protocols


### Two-Phase Commit (2PC)

Two-phase commit provides atomic commitment across multiple independent resource managers or database partitions. A designated coordinator orchestrates a voting phase followed by a decision phase, ensuring all participants either commit or abort a distributed transaction.

**Protocol Phases**

Phase 1 (Voting/Prepare): The coordinator sends PREPARE messages to all participants. Each participant executes the transaction locally, writes undo and redo logs to durable storage, acquires necessary locks, and responds with VOTE-COMMIT if it can guarantee commitment or VOTE-ABORT if it cannot proceed. Participants enter a prepared state after voting commit, unable to unilaterally abort or release locks.

Phase 2 (Decision/Commit): The coordinator collects votes. If all participants vote commit, the coordinator writes a COMMIT record to its durable log and sends COMMIT messages to all participants. If any participant votes abort or fails to respond within a timeout, the coordinator writes an ABORT record and sends ABORT messages. Participants apply the commit or abort decision, release locks, and acknowledge completion.

The coordinator's commit decision is irrevocable once logged. Participants must honor the coordinator's decision to maintain atomicity. After logging the decision, the coordinator can tolerate failures and retry sending decision messages until all participants acknowledge.

**Blocking Behavior**

Participants block after voting commit until receiving the coordinator's decision. Lock resources remain held during this blocking period, preventing other transactions from accessing affected data. If the coordinator fails after participants vote commit but before sending decisions, participants remain blocked indefinitely (until coordinator recovery or timeout-based presumed abort).

Coordinator failure during phase 1 (before logging a decision) allows participants to safely abort after timeout. Coordinator failure after logging but before distributing the decision requires coordinator recovery to retrieve the decision from durable logs and complete the protocol.

Participant failure during phase 1 is treated as a vote to abort. Participant failure during phase 2 requires recovery: the participant queries the coordinator for the transaction outcome or waits for coordinator retransmission.

**Failure and Recovery Scenarios**

Coordinator crashes before logging decision: Participants timeout and abort unilaterally. No blocking occurs since the coordinator has not made an irrevocable decision.

Coordinator crashes after logging decision: Recovery process reads the decision from durable logs and resends COMMIT or ABORT messages to participants. Participants remain blocked until coordinator recovery completes.

Participant crashes after voting commit: Upon recovery, the participant examines its logs, discovers it voted commit, and blocks waiting for the coordinator's decision. It queries the coordinator or waits for retransmission.

Network partition isolating coordinator: Participants in the non-coordinator partition cannot receive the decision and remain blocked. Manual intervention, coordinator failover, or presumed abort after extended timeout resolves the blockage.

**Coordinator Log and Participant Logs**

Coordinator log entries: BEGIN transaction record, PREPARE record (participants list), COMMIT or ABORT decision record, END transaction record (after all participants acknowledge). Force-writing the decision record before sending phase 2 messages ensures recoverability.

Participant log entries: PREPARE record (transaction details, locks acquired), COMMIT or ABORT record received from coordinator. Force-writing the PREPARE record before voting commit ensures participants can honor commitments after recovery.

Log records must be durable (fsynced) before proceeding to prevent inconsistencies during crash recovery. Log write latency directly impacts transaction commit latency.

**Optimizations**

Presumed abort: If the coordinator crashes without logging a decision, participants presume abort after timeout. Reduces coordinator log overhead for aborted transactions but does not eliminate blocking for committed transactions.

Presumed commit: Inverse optimization where absence of abort record implies commit. Reduces log writes for commits but complicates recovery and is rarely used due to safety concerns.

Read-only optimization: Participants that performed only read operations respond with READ-ONLY during phase 1 and are excluded from phase 2. Reduces message complexity and log writes.

Early prepare: Participants prepare transactions speculatively before explicit PREPARE messages, overlapping computation with network latency. Requires transaction coordinator hints or application-level coordination.

**Performance Characteristics**

Latency: Minimum two inter-datacenter round-trips (RTT) in geographically distributed systems. Phase 1 requires coordinator-to-participants RTT; phase 2 requires another RTT for decision dissemination. Additional RTTs occur during retries or failure recovery.

Throughput: Limited by coordinator bottleneck and lock hold times. High contention workloads amplify blocking, reducing effective throughput. Coordinator must handle message overhead proportional to participant count.

Lock hold time: Locks are acquired before voting and released after committing, spanning both phases plus network delays. Extended lock hold times reduce concurrency and increase deadlock probability.

Resource utilization: Blocked participants consume memory, locks, and connection resources. Large-scale deployments with frequent failures experience resource exhaustion from accumulating blocked transactions.

**Scalability Constraints**

Coordinator is a single point of contention and failure. All transactions serialize through coordinator decision logging. High transaction rates require distributed coordinators or transaction partitioning.

Participant count linearly increases message complexity (O(N) messages per transaction). Wide-area deployments with high participant counts experience significant latency accumulation.

Failure probability increases with participant count. With `N` participants each having independent failure probability `p`, transaction failure probability approaches `1 - (1 - p)^N`, reducing effective commit rates in large deployments.

### Three-Phase Commit (3PC)

Three-phase commit extends 2PC with an additional phase to eliminate blocking in the presence of coordinator failures. By introducing a pre-commit phase, 3PC ensures participants can safely make progress even when the coordinator is unavailable.

**Protocol Phases**

Phase 1 (CanCommit/Prepare): Identical to 2PC phase 1. Coordinator sends PREPARE messages, participants vote commit or abort. Participants enter prepared state after voting commit.

Phase 2 (PreCommit): If all participants vote commit, the coordinator sends PRECOMMIT messages to all participants. Participants acknowledge PRECOMMIT and enter a pre-committed state. This phase establishes that a quorum agrees commitment is possible but does not irrevocably commit.

Phase 3 (DoCommit): After receiving all PRECOMMIT acknowledgments, the coordinator sends DOCOMMIT messages. Participants commit the transaction, release locks, and acknowledge completion. If any phase fails or times out, the coordinator sends ABORT messages.

**Non-Blocking Property**

The key distinction from 2PC is that participants can deduce the transaction outcome through coordinator election or timeout mechanisms. If a participant is in pre-committed state and the coordinator fails, it can safely commit after a timeout or upon election of a new coordinator, provided no participant has aborted.

Recovery protocol: If the coordinator fails during phase 2 or 3, participants elect a new coordinator. The new coordinator polls all participants for their states. If any participant is in pre-committed state and none have aborted, the new coordinator decides commit. If any participant has aborted or all are in prepared state (not pre-committed), the new coordinator decides abort.

Timeout behavior: Participants in pre-committed state timeout waiting for DOCOMMIT and commit unilaterally. Participants in prepared state (having not received PRECOMMIT) timeout and abort.

**Network Partition Handling**

3PC assumes a synchronous or partially synchronous network model with bounded message delays and failure detection. Asynchronous networks can violate safety: a network partition can isolate the coordinator after sending PRECOMMIT to some but not all participants, causing one partition to commit while another aborts.

Partition scenario: Coordinator sends PRECOMMIT to participants P1, P2 but not P3. Network partition isolates {P1, P2} from {coordinator, P3}. P1 and P2 timeout and commit. Coordinator times out waiting for P1, P2 acknowledgments and aborts with P3. Atomicity is violated.

3PC cannot guarantee both safety and liveness under arbitrary network partitions (a consequence of the FLP impossibility result). Synchrony assumptions or failure detectors are required to prevent split-brain scenarios.

**Failure and Recovery Scenarios**

Coordinator crashes during phase 1: Participants timeout and abort, identical to 2PC.

Coordinator crashes during phase 2 (before all participants receive PRECOMMIT): New coordinator polls participants. If no participants are pre-committed, new coordinator aborts. If some participants are pre-committed but not all, protocol blocks until missing participants recover or are determined failed (requires consensus).

Coordinator crashes during phase 3: Participants in pre-committed state detect coordinator failure and commit after timeout. New coordinator inherits commit decision.

Participant crashes during phase 2: Upon recovery, participant queries new coordinator. If transaction is pre-committed, participant commits. If transaction is prepared or aborted, participant follows coordinator decision.

**Performance Characteristics**

Latency: Three inter-datacenter RTTs minimum. Additional RTT compared to 2PC directly increases commit latency. In geographically distributed systems, this overhead is substantial (e.g., 150ms vs. 100ms for cross-continent deployments).

Throughput: Coordinator bottleneck persists. Additional phase increases message complexity and coordinator processing overhead. Lock hold time is longer than 2PC by one RTT.

Message complexity: O(N) messages per phase, totaling O(3N) messages per transaction (vs. O(2N) for 2PC). Higher message volume increases network load and coordinator CPU utilization.

**Operational Trade-offs**

3PC's non-blocking property is conditional on reliable failure detection and synchrony assumptions. In practice, these assumptions are difficult to guarantee in wide-area networks with variable latency and partition behavior.

Deployment considerations: 3PC is rarely used in production distributed databases. The additional latency and complexity costs outweigh the theoretical non-blocking benefits, especially given that 2PC blocking can be mitigated through coordinator replication, fast failover, and timeout-based heuristics.

Consensus-based alternatives (Paxos Commit, Raft-based distributed transactions) provide stronger guarantees without synchrony assumptions, making them more suitable for real-world deployments.

### Coordinator Replication and High Availability

**Replicated Coordinator (Paxos Commit)**

Paxos Commit replaces the single coordinator with a Paxos-replicated coordinator group. The commit decision is agreed upon through Paxos consensus, ensuring coordinator fault tolerance without blocking.

Participant voting (phase 1) remains unchanged. Coordinators collectively decide commit/abort using Paxos. Once a quorum agrees on the decision, it is durable and can be retrieved even if individual coordinators fail.

Latency increases: Paxos consensus introduces additional RTTs. Commit latency includes participant prepare RTT, Paxos agreement RTT, and decision dissemination RTT (three RTTs minimum).

Availability improves: Coordinator group tolerates `f` failures with `2f+1` replicas. As long as a majority quorum is available, transactions can commit without blocking.

**Raft-Based Distributed Transactions**

Coordinator state is managed by a Raft cluster. The Raft leader coordinates 2PC, logging prepare and commit/abort decisions to the Raft log. Followers replicate these decisions, ensuring durability and enabling leader failover.

Leader failure triggers Raft election. New leader scans the log to identify in-progress transactions and resumes 2PC protocol (resends decisions to participants). Participants remain blocked during election but resume once the new leader is established.

This approach combines 2PC atomicity with Raft's fault tolerance, providing practical distributed transaction support in systems like CockroachDB and TiDB.

### Distributed Deadlock Handling

Distributed transactions acquire locks across multiple participants, creating potential for distributed deadlocks that local deadlock detectors cannot identify.

**Timeout-Based Deadlock Resolution**

Transactions abort after exceeding a wait timeout, breaking deadlock cycles. Simple to implement but may abort transactions unnecessarily (false positives) or fail to detect deadlocks within the timeout window.

Timeout configuration trades off deadlock detection latency (shorter timeouts) against false abort rates (longer timeouts). Application workload characteristics determine optimal timeout values.

**Distributed Wait-For Graph**

Participants maintain local wait-for graphs and periodically exchange edge information to construct a global wait-for graph. A central or distributed deadlock detector identifies cycles and selects victim transactions to abort.

Edge information propagation introduces latency. Distributed cycle detection algorithms (e.g., Chandy-Misra-Haas) use probe messages to detect cycles without centralizing the graph. Phantom deadlocks can occur when aborted transactions have not yet released all locks and edge information lags.

**Wound-Wait and Wait-Die Schemes**

Timestamp-based deadlock prevention assigns timestamps to transactions at start. Older transactions (lower timestamps) have priority. Wound-wait: older transaction aborts younger transaction if conflict occurs. Wait-die: younger transaction aborts itself if it would wait for an older transaction.

These schemes prevent deadlocks by eliminating circular wait conditions but may cause unnecessary aborts. Restarted transactions receive new timestamps, potentially causing repeated aborts (livelock) in high-contention scenarios. Timestamp reuse upon restart mitigates this issue.

### Heterogeneous Resource Managers (XA Transactions)

The X/Open XA specification standardizes 2PC interfaces for heterogeneous resource managers (databases, message queues, transactional file systems). Applications coordinate distributed transactions across XA-compliant resources using transaction monitors or application servers.

**XA Interface Functions**

`xa_start`, `xa_end`: Demarcate transaction boundaries for a resource manager. `xa_prepare`: Implements 2PC phase 1, returns vote. `xa_commit`, `xa_rollback`: Implements 2PC phase 2. `xa_recover`: Retrieves in-doubt transactions after crashes.

Transaction manager (coordinator) is typically provided by middleware (e.g., Java EE transaction managers, Tuxedo). Application code invokes transaction manager APIs, which translate to XA calls on participating resource managers.

**Heuristic Decisions**

Resource managers may make heuristic decisions (commit or abort) when the coordinator is unavailable for extended periods. Heuristic commits or aborts violate atomicity but prevent indefinite blocking. Applications must implement compensating actions or manual reconciliation for heuristic outcomes.

Heuristic flags in `xa_recover` indicate which transactions completed heuristically. Transaction managers log heuristics for auditing and reconciliation.

**Operational Challenges**

In-doubt transactions consume resources until resolved. Long coordinator outages result in accumulating blocked transactions and resource exhaustion. Monitoring and alerting on in-doubt transaction counts is critical.

XA implementation quality varies across resource managers. Interoperability issues, performance characteristics, and edge-case behaviors complicate deployment. Thorough testing of failure scenarios is essential.

### Coordinator Failure Detection and Failover

Fast failure detection reduces blocking duration. Coordinator heartbeats, TCP keepalives, and Raft election timeouts determine detection latency. Aggressive timeouts risk false positives (premature failover), conservative timeouts prolong blocking.

**Manual Intervention**

Operators may manually resolve in-doubt transactions by inspecting coordinator and participant logs, determining the correct outcome, and issuing administrative commit or abort commands. Error-prone and slow, reserved for pathological failures.

**Automated Coordinator Failover**

Standby coordinators monitor primary health and assume coordinator role upon failure detection. Standby reads coordinator logs to identify in-progress transactions and resumes 2PC. Requires shared durable storage or coordinator log replication.

Fencing mechanisms prevent split-brain: primary coordinator must acquire a lease or lock from external coordination service (ZooKeeper, etcd). Lease expiration or lock revocation allows standby to safely assume coordinator role.

### Consistency and Coordination Boundaries

Distributed commit protocols enforce atomicity across administrative or failure boundaries (separate databases, geographically distributed partitions). Overhead is justified when cross-partition atomicity is a hard requirement.

Avoiding distributed transactions through application design: Denormalization, eventual consistency, saga patterns, and idempotent operations reduce reliance on 2PC. CAP theorem implications: distributed commit requires coordination that sacrifices availability under partitions.

Partitioning strategies: Transactions within a single partition avoid distributed commit overhead. Colocating frequently co-accessed data minimizes cross-partition transactions. Partition-aware application logic routes transactions to avoid distributed coordination when possible.

### Related Topics

- Paxos Commit and consensus-based distributed transactions
- Saga pattern and compensating transactions
- Distributed deadlock detection algorithms (Chandy-Misra-Haas)
- Escrow transactions and split-batch methods
- Deterministic database systems and Calvin protocol
- Spanner TrueTime and externally consistent transactions
- Distributed snapshot isolation and write snapshot isolation
- Lease-based coordination and failure detection
- Transaction coordinator replication via Raft/Multi-Paxos
- Optimistic concurrency control in distributed systems
- Heuristic commit and operational runbooks
- XA transaction manager implementations and interoperability

---

