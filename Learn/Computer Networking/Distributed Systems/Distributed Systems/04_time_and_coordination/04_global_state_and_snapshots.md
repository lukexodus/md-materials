## Global State and Snapshots


### Global State

#### State Space Definition

Distributed system state comprises local states of all processes and communication channel states (messages in transit). Global state _S = (s₁, s₂, ..., sₙ, c₁₂, c₁₃, ..., cᵢⱼ)_ where _sᵢ_ represents process _i_ state and _cᵢⱼ_ represents messages sent by _i_ to _j_ but not yet received. State space exponentially large—impractical to enumerate all reachable states.

**Consistent global state (consistent cut)**: No message recorded as received without corresponding send recorded. Formally, if event _e_ receiving message _m_ included in cut, then event _e'_ sending _m_ must also be included. Equivalently, no "message from future" exists in snapshot.

**Inconsistent cut**: Violates causality—contains receive event without corresponding send. Example: process _P_ recorded after receiving message _m_, process _Q_ recorded before sending _m_. Such states never occur during actual execution—artifacts of incorrect snapshot algorithms.

Architectural significance: consistent snapshots enable reasoning about reachable states, debugging distributed invariants, global predicate detection. Inconsistent snapshots produce meaningless results when evaluating distributed predicates (e.g., deadlock detection with phantom dependencies).

#### Happened-Before Relation (Lamport's →)

Partial ordering on events capturing potential causality:

- **Local ordering**: If events _e_ and _f_ occur on same process and _e_ occurs before _f_ in local execution order, then _e → f_.
- **Message ordering**: If _e_ is send event and _f_ is corresponding receive event, then _e → f_.
- **Transitive closure**: If _e → f_ and _f → g_, then _e → g_.

Concurrent events _e ∥ f_: neither _e → f_ nor _f → e_. Concurrent events do not causally affect each other—can occur in any order across different observations.

Consistent cut property reformulated: Cut _C_ consistent if and only if for all events _e ∈ C_ and _f → e_, _f ∈ C_. Cut forms downward-closed set under happened-before relation—includes all causal predecessors.

Implementation: Lamport logical clocks approximate happened-before via scalar timestamps. If _e → f_, then _LC(e) < LC(f)_. Converse not true—_LC(e) < LC(f)_ does not imply _e → f_ (clocks cannot distinguish causally related from merely ordered events).

#### Reachability and Lattice Structure

System execution forms lattice of consistent global states under ≤ ordering (_S ≤ S'_ if _S_ reachable before _S'_). Initial state (all processes at start, no messages) is lattice bottom; final state (all processes terminated, all messages delivered) is lattice top if execution finite.

**Possible states**: States traversed during some execution. **Reachable states**: Possible states not containing messages from future. Snapshot algorithms capture reachable states.

Concurrency exposes multiple valid execution interleavings—different thread schedules, message delivery orders. Lattice structure represents all possible execution paths satisfying happened-before constraints. Model checking explores lattice to verify safety/liveness properties.

Architectural constraint: distributed algorithms must maintain correctness across all valid interleavings. Race conditions emerge when algorithm incorrectly assumes specific ordering of concurrent events.

#### Global Predicates and Detection

**Stable predicate**: Once becomes true, remains true (e.g., deadlock, termination, object unreachability). Single snapshot sufficient—if predicate true in snapshot and predicate stable, predicate true in actual execution. Detection latency acceptable for stable predicates.

**Unstable predicate**: Can transition true/false/true (e.g., buffer full, token holder in distributed mutual exclusion). Snapshot showing predicate false does not prove predicate never true—may have been true between snapshot events. Continuous monitoring or multiple snapshots required.

**Definitely predicate**: Predicate true in all possible consistent global states at observation time. Example: all processes have variable _x > 10_—holds regardless of concurrent event ordering.

**Possibly predicate**: Predicate true in at least one consistent global state. Weaker guarantee—useful for detecting potential violations (race conditions, assertion failures). Runtime verification uses possibly predicates for debugging.

Detection complexity: Evaluating global predicate over snapshot requires accessing multiple process states—introduces coordination overhead. Read-only snapshots avoid pausing application execution but increase staleness.

---

### Chandy-Lamport Snapshot Algorithm

#### Algorithm Mechanics

Assumes FIFO channels (messages delivered in send order per sender-receiver pair), reliable delivery, strongly connected graph. Any process initiates snapshot by:

1. **Record own state**: Initiator records local state, sends marker on all outgoing channels.
2. **Marker propagation**: Upon receiving first marker on channel _c_:
    - Record local state before processing any further messages.
    - Record channel _c_ state as empty (marker itself defines channel boundary).
    - Send marker on all outgoing channels except _c_.
3. **Channel recording**: For each channel _c_, record messages arriving on _c_ after local state recorded but before marker received on _c_.
4. **Termination**: Process completes snapshot when markers received on all incoming channels. Global snapshot complete when all processes complete local snapshots.

FIFO property critical: ensures marker arrives after all messages sent before marker creation. Non-FIFO channels require message piggybacking or sequence numbers to identify pre-marker messages.

#### Correctness Properties

**Consistency**: Captured state forms consistent cut. Proof: If receive event _e_ (message _m_) in snapshot, then send event _e'_ (sending _m_) also in snapshot. Marker propagation ensures sender records state before receiver includes _m_ in channel state—no messages from future.

**Non-intrusiveness**: Algorithm does not pause application execution or block message delivery. Markers interleaved with application messages. Overhead: O(E) markers where E = number of edges in communication graph.

**Progress**: Algorithm terminates if all markers eventually delivered. Assumes fair-loss links or reliable delivery. Termination detection via control message aggregation or gossip protocol.

Limitation: Snapshot represents possible global state, not necessarily actual state at any single instant. Due to lack of global clock, no algorithm can capture true simultaneous state in asynchronous systems. Chandy-Lamport captures causally consistent state—sufficient for many applications (deadlock detection, checkpointing).

#### Channel State Recording

Messages in transit during snapshot appear in channel state portion of global snapshot. If message _m_ sent before sender records local state but received after receiver records local state, _m_ included in channel _cᵢⱼ_ state.

Implementation: Each process maintains buffer per incoming channel to accumulate messages between local state recording and marker arrival. Upon marker arrival on channel _c_, buffer contents constitute _c_'s state in snapshot. Buffer cleared after marker—subsequent messages belong to post-snapshot state.

Storage requirement: Proportional to maximum messages in flight on any channel. High-throughput systems with delayed marker delivery accumulate large channel states. Optimization: truncate channel recording after timeout (produces incomplete snapshot but bounds memory).

#### Distributed Termination Detection

Centralized collection: Designated coordinator aggregates local snapshots from all processes. Processes send local snapshot + channel states to coordinator. Coordinator detects termination when all process snapshots received. Single point of failure—coordinator crash loses snapshot.

Decentralized aggregation: Tree-based collection structure. Each internal node waits for subtree snapshots, merges with own snapshot, forwards to parent. Reduces coordinator bottleneck, distributes load. Requires tree maintenance protocol.

Gossip-based termination: Processes exchange snapshot completion status via epidemic protocol. Eventually all processes learn global snapshot complete. Higher message overhead but robust to failures.

---

### Lai-Yang Snapshot Algorithm

#### Relaxed Channel Assumptions

Eliminates FIFO channel requirement—messages may be delivered out of order. Trades FIFO assumption for message piggybacking overhead. Each application message carries color (red or white).

Algorithm:

1. **Initiator colors red**: Records local state, begins sending red messages (marker-equivalent).
2. **Color propagation**: Process receiving first red message:
    - Records local state before processing any further messages.
    - Switches to sending red messages.
3. **Channel recording**: Each channel _cᵢⱼ_ state includes white messages received by _j_ from _i_ after _j_ recorded local state. Red messages excluded from channel state.
4. **Termination**: Snapshot complete when all processes red and no white messages in transit.

#### Comparison with Chandy-Lamport

**Advantage**: Supports non-FIFO channels—applicable to UDP-based protocols, unordered multicast, network reordering.

**Disadvantage**: Every application message carries color bit, increasing message size. Marker message (control plane) in Chandy-Lamport separated from application messages; Lai-Yang intertwines control in data plane.

Performance: Lai-Yang incurs per-message overhead; Chandy-Lamport sends O(E) separate markers. Trade-off depends on message rate vs channel count. High-message-rate systems favor Chandy-Lamport; low-rate systems with many channels favor Lai-Yang.

Both algorithms non-blocking—no synchronization pauses. Both capture consistent cuts. Choice driven by channel ordering guarantees in underlying network.

---

### Consistent Cuts and Causal Consistency

#### Cut Definition and Properties

Cut _C_ partitions events into past (included in cut) and future (excluded). Frontier of cut crosses each process timeline exactly once—represents moment-in-time snapshot for each process.

**Consistent cut**: ∀ events _e_, if _e ∈ C_ and _f → e_, then _f ∈ C_. Downward-closed under causality. Inconsistent cut violates causality—includes effect without cause.

**Zigzag path**: Alternating sequence of local process edges (forward in time) and message edges (backward in time) crossing cut. Inconsistent cut contains zigzag path with net forward direction crossing cut from past to future—impossible in real execution.

Snapshot algorithms (Chandy-Lamport, Lai-Yang) guarantee consistent cuts by ensuring causal predecessors recorded before successors. Marker propagation respects happened-before relation.

#### Causal Delivery and Consistent Snapshots

Causal delivery: If send(_m₁_) → send(_m₂_), then deliver(_m₁_) happens before deliver(_m₂_) at all receivers. Ensures messages delivered respecting causality—prevents receiving reply before request, update before invalidation.

Implementation: Vector clocks track causal dependencies. Process _i_ increments _VC[i]_ on send. Message carries sender's vector clock. Receiver buffers message until all causally prior messages delivered (detected via vector clock comparison).

Relationship to snapshots: Causal delivery simplifies channel state recording. If channels guarantee causal delivery, channel state in snapshot contains exactly messages sent before sender's snapshot but not yet causally ready for delivery at receiver. Reduces implementation complexity—no need to filter messages by global cut membership.

#### Vector Clocks and Consistent Cuts

Vector clock _VC = [c₁, c₂, ..., cₙ]_ where _cᵢ_ counts events at process _i_ observed causally. _VC(e)_ represents consistent cut including event _e_ and all causal predecessors.

Consistent cut represented by vector timestamp: each component indicates local snapshot point at corresponding process. Snapshot collection becomes vector clock synchronization problem.

Algorithm: Initiating process sets snapshot vector _SV_, piggybacks on markers. Each process records state when local clock first reaches _SV[i]_. Guarantees consistent cut—all causally prior events included by vector clock monotonicity.

Optimization: Matrix clocks (each process maintains vector of all other processes' vectors) enable local reasoning about global causality—process predicts remote state without communication. Overhead: O(n²) clock size, not practical beyond dozens of processes.

---

### Snapshot Applications

#### Distributed Debugging

Capture global state to evaluate distributed invariants: mutual exclusion (at most one process in critical section), resource allocation (no deadlock cycles), data consistency (replicas converge). Snapshot reveals invariant violations invisible in local process logs.

Predicate evaluation: Stable predicates evaluated on single snapshot (deadlock detection—if deadlock exists in snapshot, exists in execution). Unstable predicates require continuous monitoring or temporal logic (CTL, LTL) model checking over sequence of snapshots.

Replay debugging: Log snapshots and non-deterministic events (message arrivals, thread schedules). Deterministic replay reconstructs execution for debugging. Overhead: frequent snapshots increase logging cost; infrequent snapshots lose bug locality.

#### Distributed Checkpointing

Coordinated checkpoint: All processes checkpoint simultaneously (global barrier). Simple but requires synchronization pause—unacceptable in latency-sensitive systems. Provides atomic recovery point.

Uncoordinated checkpoint: Processes checkpoint independently without coordination. Enables low-latency checkpointing but risks domino effect—failure may cascade rollback to initial state if no consistent recovery line exists. Requires checkpoint dependency tracking.

Communication-induced checkpointing: Processes take checkpoints triggered by message patterns ensuring consistent recovery line exists. Hybrid approach—avoids global synchronization while preventing domino effect. Examples: Juang-Venkatesan (forced checkpoints on causal dependency), Helary (index-based checkpointing).

Chandy-Lamport as checkpoint mechanism: Snapshot produces consistent checkpoint including channel states. Recovery restores local states and replays channel messages. Requires stable storage for snapshot persistence—failure during snapshot collection loses checkpoint.

#### Global State Monitoring

Continuous monitoring: Periodic snapshots track system evolution—resource utilization trends, load distribution, replica synchronization lag. Enables adaptive algorithms reacting to global conditions (load balancing, replica placement).

Threshold detection: Trigger actions when global predicate becomes true (aggregate queue length exceeds capacity, total memory usage critical). Snapshot-based detection introduces latency—predicate may become false before detection completes. Acceptable for stable predicates or coarse-grained control decisions.

Distributed garbage collection: Snapshot identifies unreachable objects spanning multiple processes. Object reachable if reachable from any process in global snapshot. Collector runs on snapshot, reclaims objects absent in reachability graph. Concurrent mutations during snapshot handled via write barriers or incremental collection.

#### Rollback Recovery

**Independent checkpointing + message logging**: Each process periodically checkpoints local state. All messages logged (sender or receiver logging). Recovery: processes independently rollback to checkpoints, replay messages from log. Avoids checkpoint coordination overhead. Log storage requirement high—every message persisted.

**Coordinated checkpointing**: Global snapshot forms consistent recovery line. Failure triggers rollback to last complete global snapshot. No message logging required—consistent cut ensures replayable state. Overhead: checkpoint coordination latency, checkpoint frequency vs. lost work trade-off.

**Log-based rollback**: Pessimistic logging (log before send), optimistic logging (log asynchronously, may lose recent messages), causal logging (log causal dependencies, reconstruct message order on recovery). Trade-off: synchronous logging increases message latency; asynchronous logging risks data loss.

Recovery protocol: Detect failure, identify consistent recovery line (last complete global snapshot or stable storage root), restore local states, replay messages (if message logging used), resume execution. Cascading rollback possible if recovery line forces multiple processes backward.

---

### Snapshot Performance and Optimization

#### Overhead Analysis

**Message overhead**: Chandy-Lamport sends O(E) markers where E = communication graph edges. Fully connected graph with _n_ processes: O(n²) markers. Lai-Yang piggybacks color on application messages—no additional messages but increases message size.

**Storage overhead**: Each process stores local state snapshot plus channel states for all incoming channels. Channel state size proportional to messages in flight—high-throughput systems accumulate large buffers. Compression (delta encoding, deduplication) reduces storage.

**Computation overhead**: Recording local state may require pausing local processing (stop-the-world) or incremental copying (copy-on-write). Stop-the-world introduces latency spikes; incremental copying increases memory pressure. Trade-off: consistency vs. availability.

**Coordination latency**: Snapshot completion time equals maximum marker propagation delay across communication graph. Diameter _d_ graph: O(d) message delays. Long-distance geo-distributed systems experience high snapshot latency—tens to hundreds of milliseconds.

#### Incremental Snapshots

Full snapshot captures entire state—expensive for large state spaces. Incremental snapshot records only changes since last snapshot (delta). Reduces overhead but complicates recovery—must apply deltas sequentially from base snapshot.

Copy-on-write: Processes maintain shadow copy of mutable state. Snapshot references shadow copy; mutations redirected to new storage. Leverages OS page-level COW or application-level versioning. Overhead: page faults (OS-level), pointer indirection (application-level).

Log-structured state: State represented as sequence of updates (append-only log). Snapshot captures log prefix. Recovery replays log from snapshot point. Advantages: incremental checkpointing natural, write-optimized. Disadvantages: read amplification (must replay log), periodic compaction required.

#### Partial Snapshots

Capture subset of processes/channels relevant to specific property. Example: Detect deadlock only among resource-holding processes—exclude unrelated processes from snapshot. Reduces coordination overhead proportional to subset size.

Challenge: Ensuring subset forms consistent cut. If process _P_ excluded but sends message to included process _Q_, message must be accounted in channel state or _P_'s state inferred. Requires dependency analysis—identify minimum set of processes causally affecting predicate.

Hierarchical snapshots: Group processes into clusters. Capture intra-cluster snapshot (frequent, low overhead), inter-cluster snapshot (infrequent, high overhead). Suitable for hierarchical architectures (microservices within data center, data centers within region).

#### Asynchronous Snapshot Collection

Centralized collection introduces bottleneck—coordinator receives all local snapshots simultaneously. Asynchronous collection: processes send snapshots at different times, coordinator assembles incrementally. Reduces network congestion, smooths load.

Challenge: Snapshot versions may span multiple global states if collection non-atomic. Solution: Tag snapshots with vector clocks or snapshot epoch identifiers. Coordinator verifies all local snapshots belong to same consistent cut.

Streaming snapshots: Processes stream state updates to collector instead of bulk transfer. Enables low-latency availability of recent state. Collector reconstructs consistent cut from stream, discarding inconsistent fragments. Suitable for high-frequency monitoring.

---

### Snapshot Algorithms for Specific Models

#### Snapshots in Transactional Systems

Transaction-consistent snapshot: Snapshot includes all committed transactions and no uncommitted transactions. Multiversion Concurrency Control (MVCC) provides natural snapshots—each transaction sees database snapshot at start timestamp.

Implementation: Read transactions acquire snapshot timestamp, read consistent version per key (version ≤ snapshot timestamp). Write transactions acquire commit timestamp > all previous snapshots. Snapshot isolation level—transactions see consistent snapshot but may have write-write conflicts.

Distributed transactions: Snapshot spans multiple shards/databases. Two-phase commit (2PC) ensures atomic commit/abort—snapshot includes transaction iff all participants committed. Snapshot timestamp chosen after 2PC prepare phase completes, before commit.

Spanner-style snapshots: Globally synchronized TrueTime clocks enable externally consistent snapshots. Transaction commit timestamp chosen such that commit precedes any transaction observing effects (wait for clock uncertainty to elapse). Snapshot reads use any timestamp ≤ current time.

#### Snapshots in Replicated Systems

Primary-backup replication: Snapshot captures primary state and backup state. Consistency requires snapshot taken when backups synchronized with primary—all updates propagated and acknowledged. Async replication risks snapshot capturing primary ahead of backups (inconsistent).

Quorum replication: Snapshot reads query majority quorum to retrieve latest value per key. Read quorum overlaps with all write quorums—guarantees reading latest committed write. Inconsistency possible if concurrent writes span snapshot—version resolution (last-write-wins, vector clocks) required.

State machine replication: Replicas execute deterministic state machine. Snapshot captured by recording command log position (log sequence number). All replicas at same LSN have identical state. Snapshot restoration replays log from snapshot LSN.

Chain replication: Snapshot reads query tail (last replica in chain). Tail reflects all committed updates propagated through chain—linearizable snapshot. Head failures require reconfiguration before snapshot meaningful.

#### Snapshots in Gossip-Based Systems

Epidemic protocols lack global synchronization—processes converge to consistent state via randomized message exchange. Snapshot captures partially converged state.

Anti-entropy snapshots: Periodically exchange Merkle tree roots (hash digests of state). Detect divergence via root comparison, synchronize differing subtrees. Snapshot includes Merkle tree representing current view—not globally consistent but eventually converges.

Version vectors: Each process maintains version vector tracking updates observed from all peers. Snapshot includes state + version vector. Reconciliation merges snapshots using vector clocks—causally ordered updates applied, concurrent updates conflict-resolved.

Bounded staleness: Snapshot guarantees all updates older than _t_ time units included. Implemented via logical or physical clocks. Trade-off: larger _t_ increases staleness but reduces synchronization overhead.

---

### Related Topics

- Logical clocks (Lamport clocks, vector clocks, matrix clocks, hybrid logical clocks)
- Causal ordering and causal broadcast protocols
- Distributed termination detection algorithms
- Rollback recovery mechanisms (checkpoint-based, log-based, hybrid)
- Distributed garbage collection
- Global predicate detection (stable and unstable predicates)
- Distributed debugging and replay systems
- State machine replication and deterministic execution
- Eventual consistency and conflict-free replicated data types (CRDTs)

---

