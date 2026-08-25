## Distributed Deadlock Detection


### Deadlock Conditions in Distributed Systems

Four necessary conditions for deadlock existence (Coffman conditions adapted to distributed context):

**Mutual Exclusion:** Resources held exclusively by processes, preventing concurrent access. In distributed systems: distributed locks, database row locks, file locks, semaphores across nodes.

**Hold and Wait:** Processes hold resources while waiting for additional resources. Distributed manifestation: transaction holding locks on node A while requesting locks on node B.

**No Preemption:** Resources cannot be forcibly revoked from holding processes. Distributed systems typically maintain this property for consistency guarantees.

**Circular Wait:** Cycle exists in resource-wait graph where P1 waits for resource held by P2, P2 waits for resource held by P3, ..., Pn waits for resource held by P1.

**Distributed-Specific Complications:**

- Wait-for graph (WFG) fragments distributed across nodes
- Message delays create inconsistent global snapshots
- Node failures during detection complicate protocol correctness
- Network partitions may create false deadlock detection or missed deadlocks
- Clock synchronization affects timestamp-based ordering schemes

---

### Centralized Detection Algorithms

Single coordinator node constructs global wait-for graph from local reports.

**Basic Protocol:**

- Each site maintains local wait-for graph (LWFG) for resources at that site
- Sites periodically send LWFG updates to central coordinator
- Coordinator merges updates into global wait-for graph (GWFG)
- Cycle detection algorithm (DFS, Tarjan's strongly connected components) identifies deadlocks
- Coordinator selects victim transaction and broadcasts abort decision

**Message Complexity:**

- O(n) messages per detection cycle where n = number of sites
- Update frequency trades detection latency vs network overhead
- Incremental updates reduce message size but complicate merge logic

**Advantages:**

- Simple implementation and reasoning model
- Efficient cycle detection on centralized graph
- Deterministic victim selection policies (youngest transaction, minimal cost)

**Disadvantages:**

- Single point of failure at coordinator
- Scalability bottleneck for high transaction rates
- Detection latency from aggregation delays
- False positives from stale LWFG data during message transit
- Network partition isolates coordinator from subset of sites

**Optimizations:**

- Incremental graph updates instead of full snapshots
- Hierarchical coordination with regional coordinators
- Backup coordinator with leader election on failure
- Piggybacking LWFG updates on transaction messages

---

### Distributed Detection Algorithms

No single coordinator; detection responsibility distributed across sites.

#### Edge-Chasing Algorithms

Probe messages propagate along wait-for edges to detect cycles.

**Chandy-Misra-Haas Algorithm:**

- Process initiating wait sends probe message (i, j, k) where i=initiator, j=sender, k=receiver
- Receiver holding resource updates probe to (i, k, next) and forwards along outgoing wait edges
- If probe returns to initiator i, deadlock detected
- Probe contains sequence of PIDs forming potential cycle

**Message Complexity:**

- O(n²) worst case where n = processes in system
- Probe propagation follows transitive wait chains
- Dead-end probes (no outgoing edges) terminate without response

**Correctness Considerations:**

- Message delays may cause false positives (phantom deadlocks)
- Process must still be blocked when probe returns to confirm deadlock
- Timestamp or sequence numbers distinguish probe generations
- Process unblocking during detection invalidates probes in flight

**Optimizations:**

- Probe suppression when multiple blocked on same resource
- Priority-based probe forwarding (only forward for higher priority transactions)
- Timeout-based probe expiration to limit message proliferation

#### Diffusing Computation Algorithms

Distributed termination detection adapted for deadlock cycles.

**Dijkstra-Scholten Approach:**

- Deficit tracking: each process maintains count of outstanding requests
- Request messages increment deficit, acknowledgment decrements
- Deadlock exists when no process has non-zero deficit but transactions remain blocked
- Requires distributed snapshot consistency

**Challenges:**

- Distinguishes deadlock from slow progress
- Message reordering complicates deficit accounting
- Requires causal ordering or vector clocks for consistency

#### Path-Pushing Algorithms

Processes maintain and propagate wait-for path information.

**Obermarck's Algorithm:**

- Each process maintains set of transactions waiting for it
- Periodically propagates wait-for sets to processes it waits on
- Receiving process merges incoming sets with local data
- Cycle detected when process finds itself in received wait-for set

**Message Complexity:**

- O(n²) messages per detection round
- Path information grows with transaction wait depth
- Compression techniques reduce path data size

**Advantages:**

- No false positives (paths represent actual wait relationships)
- Distributed detection without central coordinator
- Deadlock localization to participating transactions

**Disadvantages:**

- High message overhead with large path data
- Propagation delays increase detection latency
- Memory overhead for path storage at each node

---

### Wait-For Graph (WFG) Maintenance

**Local WFG Structure:**

- Vertices: transactions at site
- Edges: T1 → T2 if T1 waits for resource held by T2
- Edge annotations: resource identifiers, timestamps, transaction metadata

**Global WFG Construction:**

- Union of local WFGs across all sites
- External edges span sites (T1 at site A waits for T2 at site B)
- Consistency challenge: local graphs updated at different logical times

**Update Propagation Strategies:**

- Push-based: sites send updates on graph changes
- Pull-based: coordinator polls sites periodically
- Hybrid: push critical updates (new waits), pull for verification
- Lazy propagation tolerates temporary inconsistency for performance

**Timestamp-Based Consistency:**

- Lamport timestamps or vector clocks order graph updates
- Coordinator applies updates in causal order
- Out-of-order updates buffered until dependencies satisfied
- Prevents phantom deadlocks from inconsistent snapshots

---

### Phantom Deadlocks

False deadlock detection from inconsistent global state observation.

**Scenario:**

1. Site S1: T1 waits for T2 (holds resource R1)
2. S1 sends LWFG update to coordinator: T1 → T2
3. T2 releases R1 before update arrives
4. Site S2: T2 now waits for T3
5. S2 sends update: T2 → T3
6. Coordinator receives both updates, sees cycle T1 → T2 → T3 → T1 (if T3 waits for T1)
7. Cycle never actually existed simultaneously

**Root Cause:**

- Non-atomic global snapshot collection
- Message delays create temporal inconsistency
- No happens-before relationship between resource release and wait initiation

**Mitigation Techniques:**

**Chandy-Lamport Snapshot Algorithm:**

- Consistent global snapshot through marker propagation
- Channels record in-flight messages during snapshot
- Guarantees snapshot represents reachable global state
- High message overhead for frequent deadlock detection

**Two-Phase Detection:**

- Phase 1: Tentative deadlock identification from potentially stale data
- Phase 2: Verification phase confirms blocked transactions still waiting
- Aborts only if verification succeeds (transactions remain blocked)

**Timeout-Based Filtering:**

- Only report deadlock if cycle persists across multiple detection rounds
- Trades detection latency for false positive reduction
- Timeout duration balances responsiveness vs accuracy

**Happens-Before Ordering:**

- Vector clocks track causality between updates
- Coordinator only detects cycles with consistent causal ordering
- Higher implementation complexity and message overhead

---

### Deadlock Resolution Strategies

**Victim Selection Criteria:**

- Youngest transaction (easiest rollback, less work wasted)
- Lowest priority transaction
- Transaction involved in fewest deadlocks (break most cycles efficiently)
- Minimal cost (least computation done, fewest resources held)
- Transaction holding fewest locks (reduces cascading aborts)

**Abort Propagation:**

- Cascading aborts if victim has dependent transactions (read uncommitted data)
- Distributed commit protocol (2PC/3PC) to ensure atomically visible abort
- Compensating transactions in sagas or long-lived transactions
- Retry policies and backoff to prevent immediate re-deadlock

**Partial Rollback:**

- Roll back victim transaction to savepoint before deadlock participation
- Requires checkpointing within transaction execution
- Reduces wasted work but increases system complexity
- Applicable in nested transaction models

**Resource Preemption:**

- Forcibly revoke resources from victim
- Requires resource state preservation for restoration
- Applicable to idempotent or stateless resources
- Rare in distributed databases due to consistency requirements

---

### Deadlock Prevention Approaches

Avoid deadlock formation by violating one of four necessary conditions.

**Total Ordering of Resources:**

- Globally unique resource identifiers with total order
- Transactions acquire locks in ascending identifier order
- Prevents circular wait by construction
- Challenges: discovering all required resources upfront, static locking reduces concurrency

**Wait-Die and Wound-Wait Schemes:**

**Wait-Die (Non-Preemptive):**

- Older transaction (lower timestamp) waits for younger
- Younger transaction requesting resource held by older dies (aborts)
- Prevents cycles: age decreases along wait edges

**Wound-Wait (Preemptive):**

- Older transaction wounds (preempts) younger holding desired resource
- Younger transaction waits if requesting resource held by older
- Older transactions have priority, younger may be repeatedly aborted

**Timestamp Ordering:**

- Each transaction assigned unique timestamp at start
- Timestamp determines serialization order
- Conflicting operations ordered by timestamp
- No explicit locks, no wait cycles possible
- May cause transaction restarts under conflicts (optimistic approach)

**Timeout-Based Abortion:**

- Abort transactions exceeding wait timeout threshold
- Simple implementation but aborts non-deadlocked slow transactions
- Tuning timeout value trades false aborts vs deadlock resolution latency
- Not true prevention, hybrid detection/prevention approach

---

### Distributed Database-Specific Considerations

**Two-Phase Locking (2PL) and Distributed Deadlock:**

- Strict 2PL holds locks until commit/abort
- Growing phase across multiple sites creates cross-site wait dependencies
- Distributed deadlock detection required for correctness
- Detection frequency impacts transaction abort rate and latency

**Distributed Transactions and 2PC:**

- Coordinator and participants may hold locks during prepare phase
- Deadlock during 2PC stalls commit protocol
- Detection must handle transactions in prepared state
- Timeouts risk inconsistency if participant unilaterally aborts

**Multi-Version Concurrency Control (MVCC):**

- Read-only transactions never block, reducing deadlock probability
- Write-write conflicts still create wait dependencies
- Snapshot isolation reduces deadlock surface compared to serializable isolation
- First-committer-wins prevents some deadlocks but requires abort on conflict

**Optimistic Concurrency Control (OCC):**

- No locks during read/compute phases
- Validation phase detects conflicts
- Deadlock-free by design (no waiting)
- High abort rates under contention reduce effective throughput

---

### Graph Algorithms for Cycle Detection

**Depth-First Search (DFS):**

- O(V + E) complexity for vertices V and edges E
- Maintains visited set and recursion stack
- Cycle exists if back edge encountered (edge to ancestor in DFS tree)
- Single-pass detection in directed graph

**Tarjan's Strongly Connected Components:**

- O(V + E) complexity
- Identifies all cycles simultaneously
- Low-link values track earliest reachable ancestor
- On-stack marker distinguishes current path from previously explored

**Union-Find with Cycle Detection:**

- O(α(n)) amortized per operation (inverse Ackermann function)
- Efficient for incremental edge addition
- Detects cycle when uniting vertices already in same component
- Applicable when WFG updated edge-by-edge

**Distributed Graph Algorithms:**

- MapReduce-style parallel cycle detection for massive graphs
- Graph partitioning across nodes with edge-cut minimization
- Iterative refinement propagates reachability information
- Pregel/GraphX model for distributed graph computation

---

### Hierarchical Detection Architectures

**Multi-Level Coordination:**

- Local coordinators per datacenter/rack/zone
- Regional coordinators aggregate local deadlock information
- Global coordinator handles cross-region deadlocks
- Reduces message latency and single-point-of-failure risk

**Detection Scope Partitioning:**

- Intra-datacenter deadlocks detected locally (low latency)
- Inter-datacenter deadlocks escalate to global coordinator
- Partitioning reduces false positives from cross-region message delays
- Failure of regional coordinator impacts only subset of sites

**Hierarchical Wait-For Graph:**

- Summary graphs at higher levels abstract lower-level details
- Transaction waits external to region represented as single external dependency
- Reduced graph size improves detection efficiency
- Drill-down on cycle detection to identify specific transactions

---

### Practical System Implementations

**PostgreSQL:**

- Local deadlock detection per database instance
- Lock manager maintains wait-for graph in shared memory
- Deadlock detector runs periodically (configurable interval)
- Selects youngest transaction as victim

**Oracle RAC (Real Application Clusters):**

- Distributed lock manager across RAC nodes
- Global enqueue service tracks cross-instance lock waits
- Integrated deadlock detection across instances
- Optimized for shared-storage architecture

**Google Spanner:**

- TrueTime-based serializable isolation reduces deadlock probability
- Wound-wait scheme with transaction priorities
- Deadlock detection across globally distributed replicas
- Leader replica coordinates lock acquisition for transaction's shard

**Distributed Locking Services (Chubby, etcd, ZooKeeper):**

- Centralized lock server model reduces distributed deadlock scope
- Client-side timeouts prevent indefinite blocking
- Lock acquisition ordering enforced by client libraries
- No cross-server deadlock possible (centralized coordination)

---

### Performance and Scalability Implications

**Detection Overhead:**

- CPU cost of graph construction and cycle detection
- Network bandwidth for WFG update propagation
- Memory for storing wait-for graphs at each site
- Latency added to transaction execution from detection delays

**Detection Frequency Trade-offs:**

- High frequency: lower deadlock resolution latency, higher overhead
- Low frequency: higher transaction blocking time, lower overhead
- Adaptive detection: trigger on blocked transaction accumulation threshold

**Scalability Bottlenecks:**

- Centralized coordinator limits throughput (100k-1M transactions/sec typical ceiling)
- O(n²) message complexity in some distributed algorithms scales poorly
- Global WFG size grows with transaction concurrency
- Network partitions increase detection latency and false positive rate

**Throughput vs Consistency:**

- Deadlock prevention (timestamp ordering, wait-die) may reduce concurrency
- Detection allows maximal concurrency but adds abort overhead
- MVCC and OCC trade increased aborts for lock-free reads

---

### Failure Handling in Deadlock Detection

**Coordinator Failure:**

- Backup coordinator promoted via leader election (Raft, ZAB)
- In-progress detection state lost, restart detection cycle
- Transactions blocked during coordinator failover continue waiting
- Timeout-based unblocking prevents indefinite stalls

**Site Failure:**

- Failed site's transactions automatically aborted (resource release)
- Removes site's edges from global WFG
- Phantom deadlock detection if failure notification delayed
- Recovery requires rebuilding local WFG from persistent state

**Network Partition:**

- Majority partition continues deadlock detection
- Minority partition may detect phantom deadlocks (can't verify with majority)
- Conservative approach: halt detection during partition, rely on timeouts
- Quorum-based detection requires majority sites reachable

**Message Loss:**

- Retransmission with timeout for critical WFG updates
- Sequence numbers detect missing updates
- Periodic full graph retransmission for synchronization
- Idempotent update processing handles duplicates

---

### Observability and Debugging

**Metrics:**

- Deadlock detection rate (deadlocks per second/minute)
- False positive rate (phantom deadlock percentage)
- Detection latency (time from deadlock formation to resolution)
- Victim abort rate and retry success rate
- WFG size and update frequency per site

**Distributed Tracing:**

- Trace transaction lock acquisition sequence across sites
- Correlate lock waits with resource holders
- Visualize wait-for graph snapshots at deadlock detection time
- Track victim selection and abort propagation

**Logging:**

- Record detected cycles with participating transactions and resources
- Log WFG updates for post-mortem analysis
- Capture coordinator decision rationale for victim selection
- Persistent audit trail for transactional correctness verification

**Alerting:**

- High deadlock rate indicates contention hotspots or application anti-patterns
- Coordinator failover events impact detection availability
- Detection latency SLO violations signal scalability limits

---

### Related Topics

- Wait-for graphs
- Cycle detection algorithms
- Two-phase locking
- Timestamp ordering
- Distributed transactions
- Two-phase commit
- Consensus protocols
- Distributed snapshot algorithms
- Lamport timestamps
- Vector clocks
- Lock managers
- Concurrency control mechanisms
- MVCC
- Optimistic concurrency control
- Distributed resource allocation
- Banker's algorithm
- Resource ordering protocols
- Transaction isolation levels
- Distributed system failures
- Network partitions

---

