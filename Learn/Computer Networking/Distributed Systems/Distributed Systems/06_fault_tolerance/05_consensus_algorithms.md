## Consensus Algorithms


Consensus algorithms enable distributed systems to achieve agreement on a single value or sequence of values despite node failures, network delays, and message loss. Fundamental to replicated state machines, distributed databases, coordination services, and any system requiring fault-tolerant agreement without reliance on a single point of failure.

### Consensus Problem Definition

**Safety Properties:**

- **Agreement:** All non-faulty nodes decide on the same value.
- **Validity:** Decided value must be proposed by some node (no arbitrary values).
- **Integrity:** Each node decides at most once per consensus instance.

**Liveness Property:**

- **Termination:** All non-faulty nodes eventually decide, assuming bounded message delays and sufficient non-faulty nodes.

**FLP Impossibility:**

Fischer-Lynch-Paterson theorem proves no deterministic consensus algorithm can guarantee termination in asynchronous systems with even one faulty node. Practical consensus algorithms circumvent FLP by assuming partial synchrony (eventual bounded message delays) or using randomization.

### Fault Model Assumptions

**Crash-Fault Tolerance:**

Paxos and Raft assume crash-stop failures: nodes fail by halting, do not send corrupted messages, and do not exhibit Byzantine behavior. Failed nodes may recover with persistent state intact. Network may delay, duplicate, or reorder messages but not corrupt them.

**Availability Requirements:**

Consensus requires majority quorum: system tolerates `f` failures among `2f + 1` nodes. Three nodes tolerate one failure, five nodes tolerate two failures. Minority partitions cannot make progress, ensuring split-brain prevention.

### Paxos Algorithm

Paxos solves consensus through phases ensuring only one value can achieve majority acceptance, even across multiple proposers competing concurrently.

**Roles:**

- **Proposers:** Initiate consensus by proposing values.
- **Acceptors:** Vote on proposals, form quorum majority.
- **Learners:** Learn decided value after consensus completes (passive role).

Nodes typically assume multiple roles simultaneously.

**Proposal Numbers:**

Each proposal carries globally unique, totally-ordered proposal number (ballot number). Typically tuple `(sequence, node_id)` where sequence monotonically increases and node_id breaks ties. Proposers must use proposal numbers higher than any previously seen.

**Phase 1: Prepare**

Proposer selects proposal number `n`, sends `Prepare(n)` to acceptor quorum.

Acceptor receiving `Prepare(n)`:

- If `n` is greater than any proposal number previously seen, acceptor promises not to accept proposals numbered less than `n` and responds with highest-numbered proposal it has accepted (if any) along with that proposal's value.
- If `n` is less than or equal to previously seen proposal number, acceptor ignores or rejects.

Proposer waits for majority quorum of responses. If proposer receives rejections indicating higher proposal numbers exist, it abandons current attempt.

**Phase 2: Accept**

After receiving majority `Prepare` responses, proposer determines value to propose:

- If any acceptor responded with previously accepted `(proposal_number, value)` pair, proposer must use the value from the highest-numbered accepted proposal.
- If no acceptor has accepted any value, proposer may choose arbitrary value.

Proposer sends `Accept(n, v)` to acceptor quorum.

Acceptor receiving `Accept(n, v)`:

- If acceptor has not promised to ignore proposals numbered `n` (i.e., has not responded to `Prepare(m)` where `m > n`), acceptor accepts `(n, v)` and responds with acceptance.
- If acceptor has promised to higher-numbered proposal, rejects.

**Decision:**

When proposer receives majority acceptances for `Accept(n, v)`, value `v` is decided. Proposer notifies learners of decision.

**Liveness and Dueling Proposers:**

Multiple proposers may compete, each aborting the other's Phase 1 by issuing higher proposal numbers. Prevents termination. Solutions:

- **Leader Election:** Designate single proposer (leader) through external mechanism or randomized backoff.
- **Exponential Backoff:** Failed proposers delay before retrying with exponentially increasing intervals.
- **Multi-Paxos Optimization:** Elect stable leader that runs multiple consensus instances, amortizing Phase 1 cost.

**Multi-Paxos:**

Extends basic Paxos to agree on sequence of values (log entries) rather than single value. Once leader elected via successful Phase 1, leader skips Phase 1 for subsequent instances, sending only `Accept` messages. Leadership remains valid until preempted by higher-numbered proposal.

Optimizations:

- **No-op entries:** Leader commits no-op entry after election to discover committed entries from previous terms.
- **Log compaction:** Snapshot decided state, discard old log entries.
- **Read optimization:** Leader can serve reads if it has recently received heartbeat responses from majority, confirming leadership.

**Persistent State Requirements:**

Acceptors must persist:

- Highest promised proposal number (to prevent accepting lower-numbered proposals after restart).
- Highest accepted proposal and value (to inform future proposers of constraints).

Failure to persist state risks violating safety by allowing acceptor to break promises made before crash.

**Network Partition Handling:**

Majority partition continues making progress. Minority partition cannot achieve quorum, stalls until partition heals. When partition heals, minority synchronizes with majority through log replication.

### Raft Algorithm

Raft designed as understandable consensus algorithm with explicit leader election and log replication phases. Functionally equivalent to Multi-Paxos but structured differently for clarity.

**Term Numbers:**

Time divided into terms, each identified by monotonically increasing term number. Each term begins with leader election; at most one leader per term. Term numbers enable nodes to detect stale information.

**Node States:**

- **Follower:** Passive, responds to RPCs from leaders and candidates. Begins here on startup.
- **Candidate:** Actively seeking election as leader for current term.
- **Leader:** Handles all client requests, replicates log to followers.

**Leader Election:**

Follower increments term and transitions to candidate if election timeout elapses without receiving heartbeat from current leader.

Candidate sends `RequestVote` RPC to all nodes:

- Includes candidate's term, last log index, and last log term.
- Candidate votes for itself.

Node receiving `RequestVote` grants vote if:

- Candidate's term is at least as current as receiver's term.
- Receiver has not voted for another candidate in this term.
- Candidate's log is at least as up-to-date as receiver's log.

Log up-to-date comparison:

- If logs end with different terms, log with later term is more up-to-date.
- If logs end with same term, longer log is more up-to-date.

Candidate becomes leader upon receiving votes from majority. If election timeout elapses without majority, candidate increments term and starts new election. Randomized election timeouts (e.g., 150-300ms) reduce split votes.

**Log Replication:**

Leader receives client commands, appends to local log as uncommitted entries. Leader sends `AppendEntries` RPC to followers containing new entries.

`AppendEntries` RPC includes:

- Leader's term.
- Index and term of log entry immediately preceding new entries.
- New entries to append.
- Leader's commit index.

Follower receiving `AppendEntries`:

- Rejects if leader's term is less than follower's term.
- Rejects if follower's log does not contain entry at `prevLogIndex` with term matching `prevLogTerm` (consistency check).
- Deletes conflicting entries starting at first new entry, appends new entries.
- Updates commit index to `min(leaderCommit, index of last new entry)`.

**Commitment Rule:**

Leader marks entry committed when replicated on majority. Leader includes commit index in subsequent `AppendEntries` RPCs, allowing followers to commit entries. Leader only commits entries from current term once majority replicated. Entries from previous terms commit indirectly when current-term entry commits.

Prevents scenario where leader commits entry from old term, crashes, new leader elected without that entry, overwriting it.

**Safety - Election Restriction:**

Candidate's log must be at least as up-to-date as any majority of nodes to win election. Ensures elected leader contains all committed entries, preventing committed entry loss.

**Log Inconsistency Repair:**

After leader election, leader's log considered authoritative. Leader identifies highest consistent log index with each follower via `AppendEntries` consistency checks. Leader sends all entries from that point onward, overwriting follower's divergent entries.

Algorithm:

- `AppendEntries` RPC includes `prevLogIndex` and `prevLogTerm`.
- If follower lacks entry or term mismatches, follower rejects.
- Leader decrements `nextIndex` for that follower, retries with earlier entries.
- Continues until consistency check passes, then follower appends entries.

Optimization: follower includes first index of conflicting term and last index in its log for that term in rejection response. Leader skips to end of conflicting term, accelerating convergence.

**Cluster Membership Changes:**

Raft supports dynamic cluster reconfiguration through joint consensus:

- Leader proposes configuration change, both old and new configurations are active simultaneously (joint consensus).
- Decisions require majorities from both old and new configurations.
- Once joint consensus entry committed, leader proposes new configuration exclusively.
- Two-phase approach prevents split-brain during reconfiguration.

Single-server changes (adding or removing one server at a time) simpler but slower for multi-server changes.

**Log Compaction:**

Snapshot committed state up to some index, discard preceding log entries. Snapshot includes:

- State machine state.
- Last included index and term (for consistency checking).
- Latest configuration.

Leader sends `InstallSnapshot` RPC to followers lagging behind snapshot point. Followers receiving snapshot discard older entries, apply snapshot.

**Read Optimization - Lease Reads:**

Leader serves reads without log replication if it has received heartbeat acknowledgments from majority within election timeout. Ensures leader remains active and no new leader elected. Reduces read latency from RTT to zero additional communication for cached data.

Stricter approach: append no-op entry on becoming leader, commit it, then serve reads. Guarantees leader has committed all entries from previous terms.

**Persistent State Requirements:**

All nodes must persist:

- `currentTerm`: Latest term seen.
- `votedFor`: Candidate that received vote in current term.
- `log[]`: All log entries with terms.

Failure to persist enables safety violations (voting twice in same term, losing committed entries).

### Paxos vs. Raft Comparison

**Understandability:**

Raft explicitly separates leader election, log replication, and safety concerns into distinct subproblems. Paxos presents as single algorithm with roles and phases less intuitively aligned with operational behavior.

**Leader Stability:**

Raft enforces strong leadership: only leader appends entries, leader preemption requires new election. Paxos allows multiple proposers competing simultaneously, requiring conflict resolution.

**Log Structure:**

Raft maintains contiguous committed log with no gaps. Simplifies reasoning and implementation. Paxos permits gaps in accepted instances, requiring explicit gap detection and filling.

**Election Constraints:**

Raft restricts election to candidates with most up-to-date log. Paxos allows any node to propose but Phase 1 discovers previously accepted values, constraining proposals.

**Performance Characteristics:**

Raft amortizes leader election cost across many log entries during stable leadership. Paxos requires Phase 1 per instance unless Multi-Paxos optimizations applied.

Both achieve similar throughput and latency in practice when optimized. Raft's batching and pipelining, Paxos's parallel instance execution.

### Multi-Paxos Practical Implementation Details

**Instance Space Management:**

Assign each log index a separate Paxos instance. Leader executes Phase 1 across range of instances (or indefinitely) upon election, caching promises. Subsequent appends execute only Phase 2 for those instances.

**Leadership Lease:**

Leader maintains lease via periodic heartbeats. Followers grant lease if no higher-numbered proposals seen. Lease enables reads without consensus. Requires clock synchronization to bound lease expiration skew.

**Speculative Execution:**

Leader speculatively applies commands to state machine before commit, serving reads from speculative state. Rollback required if leadership lost before commit. Reduces read latency but complicates correctness.

**Pipelining and Batching:**

Leader pipelines multiple Accept messages without waiting for responses, accumulating outstanding proposals. Batch multiple client commands into single Paxos instance. Increases throughput, reduces per-command latency.

**Failure Detection:**

Rely on timeouts to detect leader failure. Tune timeout above typical round-trip time but below acceptable unavailability window. Adaptive timeouts based on observed latency distributions reduce false positives.

### Raft Practical Implementation Details

**Election Timeout Tuning:**

Randomized election timeout range must exceed broadcast time (time for leader to send heartbeats to all followers) to prevent unnecessary elections. Typical: 150-300ms randomization on top of 100ms base.

**Batch Appends:**

Leader accumulates multiple client commands before sending `AppendEntries`, improving throughput. Trade-off: increases per-command latency.

**Pipelining Replication:**

Leader sends next `AppendEntries` without waiting for previous response, tracking multiple outstanding RPCs per follower. Increases throughput and tolerates occasional message loss without stalling.

**Pre-Vote Phase:**

Before transitioning to candidate, node sends `PreVote` RPC checking if it could win election. Prevents disrupting current leader when partitioned node with stale log rejoins cluster. Node only increments term and starts election if majority responds positively.

**Leadership Transfer:**

Leader can explicitly transfer leadership by stopping heartbeats and instructing target follower to start election. Enables graceful leader shutdown or load balancing. Target follower receives log entries to become up-to-date before election.

**Asynchronous Replication to Learners:**

Nodes outside voting quorum (learners/observers) receive replicated log asynchronously without participating in commit decisions. Enables read scaling and geographic distribution without increasing quorum latency.

### Latency Characteristics

**Write Latency:**

Minimum two round-trips:

1. Leader to quorum majority: send `AppendEntries`.
2. Leader to client: acknowledge commit after receiving majority responses.

Optimizations:

- Collocate leader and clients in same datacenter.
- Parallelize replication to all followers simultaneously.
- Batch multiple commands, amortizing round-trip cost.

Typical: 1-5ms in single datacenter, 50-200ms cross-region.

**Read Latency:**

- **Linearizable reads:** Require confirming leadership via majority heartbeat or appending read to log. Full write latency cost.
- **Lease reads:** Zero additional latency if leader holds valid lease. Requires clock synchronization for correctness.
- **Follower reads:** Serve stale reads from followers without leader communication. Bounded staleness based on replication lag.

### Throughput Optimization

**Batching:**

Accumulate commands from multiple clients, propose batch as single log entry. Reduces per-command overhead, increases throughput. Trade-off: adds latency for individual commands waiting for batch to fill or timeout.

**Pipelining:**

Leader maintains multiple outstanding log entries simultaneously, not waiting for prior entries to commit before proposing next. Saturates network and follower processing capacity.

**Parallel Log Application:**

Apply committed log entries to state machine in parallel when operations are independent (different keys). Requires dependency tracking and conflict detection.

**Network Optimizations:**

Use kernel bypass (DPDK, RDMA) for low-latency messaging between nodes. Reduces per-message overhead from microseconds to sub-microsecond.

### Fault Recovery

**Leader Crash:**

Followers detect missing heartbeats via election timeout. New election begins, electing leader with most up-to-date log. New leader replicates missing entries to followers, ensuring convergence.

Recovery time: `election_timeout + election_duration + log_repair_duration`. Typical: 1-10 seconds depending on log size and cluster size.

**Follower Crash:**

Leader retries `AppendEntries` to failed follower indefinitely with exponential backoff. When follower recovers, leader brings it up-to-date by sending missing log entries or snapshot if too far behind.

**Split Brain Prevention:**

Majority quorum requirement ensures at most one partition can make progress. Minority partition stalls when attempting writes. Prevents divergent state across partitions.

**Network Partition Healing:**

When partition heals, nodes synchronize term numbers and log contents. Nodes with stale terms revert to follower state. Followers overwrite divergent log entries with leader's authoritative log.

### Correctness Invariants

**State Machine Safety:**

If any node has applied log entry at index `i` to state machine, no other node will ever apply different log entry for index `i`. Ensures all nodes execute same commands in same order.

**Leader Completeness:**

If entry committed in term `T`, entry will be present in leader's log for all terms `> T`. Ensures committed entries never lost.

**Log Matching:**

If two logs contain entry with same index and term, then logs are identical in all entries up through that index. Enables efficient consistency checking and repair.

### Cluster Size Selection

**Odd vs. Even Cluster Sizes:**

Odd cluster sizes provide same fault tolerance as next-higher even size (3 and 4 both tolerate 1 failure) with lower quorum size, reducing latency. Prefer odd sizes: 3, 5, 7.

**Geographic Distribution:**

Place majority nodes in primary datacenter for low write latency. Minority nodes in secondary datacenters for disaster recovery. Tolerates datacenter failure if primary contains majority.

Alternative: distribute evenly across datacenters, accept cross-datacenter latency for all writes. Survives single datacenter failure if `2f + 1` nodes across `f + 1` datacenters.

**Dynamic Resizing:**

Support adding nodes during scale-out or removing nodes during scale-down through configuration change protocol. Allows adapting cluster size to workload and failure assumptions without downtime.

### Limitations and Extensions

**Scalability Ceiling:**

Single leader bottleneck limits throughput. All writes funnel through leader, constraining to single-node write capacity. Horizontal scaling requires partitioning (sharding) state across multiple independent Raft/Paxos groups.

**Cross-Shard Coordination:**

Multi-shard transactions require coordination protocol atop consensus (two-phase commit, Spanner's TrueTime-based transactions). Each shard runs independent consensus group; coordinator runs consensus for transaction outcome.

**Reconfiguration Complexity:**

Adding or removing nodes, changing replication factor, or migrating data between shards requires careful orchestration to maintain availability and consistency. Joint consensus mitigates some risks but adds complexity.

**Byzantine Fault Tolerance:**

Paxos and Raft assume crash faults, not Byzantine faults (arbitrary, malicious behavior). Byzantine consensus algorithms (PBFT, HotStuff, Tendermint) require `3f + 1` nodes to tolerate `f` Byzantine failures, increasing overhead.

### Production Deployment Patterns

**Embedded Consensus Libraries:**

Applications embed Raft or Paxos library (etcd's Raft implementation, PhxPaxos), managing consensus within application process. Simplifies deployment but increases application complexity.

**Consensus-as-a-Service:**

Centralized coordination services (etcd, ZooKeeper, Consul) provide consensus-based coordination primitives to applications. Applications use as external dependency for leader election, configuration storage, distributed locking.

**Database Replication:**

Distributed databases use consensus for replicated log (CockroachDB Raft, MySQL Group Replication Paxos, YugabyteDB Raft). Consensus layer ensures write ordering and durability across replicas.

**Control Plane vs. Data Plane:**

Use consensus for control plane operations (cluster membership, shard assignment, schema changes) with relaxed latency requirements. Data plane (reads, writes) optimizes for throughput and latency, relying on consensus-established invariants.

### Monitoring and Observability

**Leadership Stability:**

Track leadership changes per second. Frequent leadership changes indicate election timeouts too aggressive, network instability, or resource contention. Stable leadership essential for throughput.

**Replication Lag:**

Monitor log index gap between leader and followers. Large gaps indicate slow followers unable to keep pace, risking quorum loss if leader fails. Alerts trigger follower reprovisioning or leader migration.

**Proposal Success Rate:**

Percentage of proposals achieving commit vs. rejected or timed out. Low success rate indicates leader contention, network issues, or insufficient quorum availability.

**Commit Latency Distribution:**

P50, P99, P99.9 commit latencies. Tail latencies indicate network variance, slow followers, or batching/pipelining inefficiencies.

**Quorum Health:**

Active quorum size vs. required quorum size. Reduced quorum headroom warns of imminent unavailability if additional nodes fail.

### Security Considerations

**Authentication:**

Nodes mutually authenticate using TLS certificates or shared secrets. Prevents malicious nodes from joining cluster and participating in consensus.

**Authorization:**

Control which nodes can propose values (typically all nodes for Raft leader election, designated proposers for Paxos). Prevent unauthorized nodes from injecting commands.

**Message Integrity:**

Cryptographic signatures or MACs on consensus messages prevent tampering during transit. Ensures proposal numbers, terms, and values not altered by network adversaries.

**Replay Attacks:**

Include nonces or timestamps in messages to prevent replay. Stale messages with old terms/proposal numbers already rejected by algorithm, but additional defenses mitigate DoS.

**Denial of Service:**

Rate limit proposal requests, discard messages from non-cluster nodes, enforce resource quotas per node. Prevents malicious nodes from overwhelming cluster with spurious proposals.

### Related Distributed Consensus Topics

- Multi-Paxos and Paxos Made Simple
- Viewstamped Replication
- Zab Protocol (ZooKeeper Atomic Broadcast)
- Byzantine Fault Tolerant Consensus (PBFT, HotStuff, Tendermint)
- Vertical Paxos (Reconfigurable Consensus)
- EPaxos (Egalitarian Paxos)
- Flexible Paxos and Flexible Quorums
- Leader Election Algorithms
- State Machine Replication
- Distributed Locking and Lease Management
- Quorum Systems and Intersection Properties
- Log Compaction and Snapshotting Strategies

---

