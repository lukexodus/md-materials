## Consistency Protocols


### Primary-Based Consistency Protocols

Primary-based protocols designate a single replica as the authoritative coordinator for write operations within a partition or replica set. All write requests route through or are serialized by the primary, which orders operations and propagates state changes to secondary replicas according to protocol-specific guarantees.

**Remote-Write Protocol**

Client writes are directed exclusively to the primary. The primary applies the write to its local state, then asynchronously or synchronously propagates updates to secondary replicas. Read operations may be served by any replica depending on consistency requirements. The primary acts as the single source of truth for ordering and conflict resolution.

Strong consistency variants block client acknowledgment until a quorum of replicas confirm the write (e.g., majority quorum in Raft or MongoDB replica sets). Asynchronous variants acknowledge immediately after primary commit, trading consistency for lower latency. Read-your-writes consistency requires session affinity or monotonic read tokens to ensure clients observe their own writes when reading from secondaries.

Failure of the primary triggers an election or failover protocol. During election, the system is unavailable for writes. Consensus-based elections (Raft, Multi-Paxos, ZAB) guarantee safety by requiring quorum agreement on the new primary. Non-consensus approaches (e.g., static configuration with external coordination) risk split-brain if network partitions occur.

Network partitions isolate the primary in a minority partition result in write unavailability until the partition heals or a new primary is elected in the majority partition. Secondaries in the minority partition cannot be promoted without violating safety. Lease-based primary ownership with time-bounded validity prevents dual primaries across partitions.

Read scaling is achieved by distributing read load across secondaries. Staleness bounds depend on replication lag, which is influenced by network latency, replica processing capacity, and write throughput. Bounded-staleness reads require replicas to track commit indices or hybrid logical clocks and reject reads that would violate freshness constraints.

**Local-Write Protocol**

Writes are initially committed to the nearest replica (which may be a secondary), then forwarded to the primary for global ordering. The primary sequences the operation, assigns a global timestamp or log position, and replicates to all replicas including the initial write target. The initial replica acknowledges the client after receiving confirmation from the primary.

This protocol reduces client-perceived latency for geographically distributed clients by avoiding full round-trip to a distant primary before acknowledgment. However, it introduces additional coordination overhead and potential for conflicts if multiple clients concurrently write to different replicas.

Conflict resolution occurs at the primary. Optimistic variants allow tentative local commits that are later aborted if the primary rejects the operation due to conflicts. Pessimistic variants acquire locks at the primary before local commit. The protocol trades complexity and potential rollback scenarios for lower write latency.

Primary-backup replication with local-write often employs log sequence numbers (LSNs) to maintain ordering. The primary assigns LSNs, and replicas apply operations in LSN order. Gaps in LSN sequences indicate missing operations that must be fetched before advancing the replica state.

**Primary-Per-Object Protocol**

Each data object or key is assigned a designated primary replica, distributing primary responsibilities across the replica set. Object-to-primary mappings are maintained in a partition map or consistent hash ring. Clients consult the mapping to route writes to the correct primary for each object.

This protocol enables higher write throughput by parallelizing primary responsibilities and eliminating single-primary bottlenecks. It also localizes failure domains—primary failure only affects objects assigned to that replica.

Coordination costs increase due to distributed ownership. Multi-object transactions spanning multiple primaries require distributed coordination protocols (2PC, Paxos Commit, or deterministic ordering). Atomic commitment across primaries introduces latency and availability trade-offs.

Replica migration and rebalancing require transferring primary ownership, which involves coordination to prevent split-brain and ensure continuity of operation sequencing. Protocols typically use epoch numbers or versioned partition maps to fence stale primaries.

Read scaling is object-specific. Secondaries can serve reads for objects they replicate with consistency semantics similar to remote-write protocol. Locality-aware routing directs reads to nearby replicas.

### Replicated-Write Consistency Protocols

Replicated-write protocols distribute write coordination across multiple replicas, eliminating single-primary bottlenecks but requiring consensus or conflict resolution mechanisms to maintain consistency.

**Active Replication (State Machine Replication)**

All replicas receive and execute operations in the same deterministic order. Clients broadcast operations to all replicas or to a sequencer that orders and distributes operations. Each replica independently applies operations to its state, producing identical results due to deterministic execution.

Total order broadcast (atomic broadcast) is the fundamental primitive. Implementations typically use consensus protocols (Paxos, Raft) or virtual synchrony models (ISIS, Totem). Operations are assigned sequence numbers, and replicas apply operations in sequence number order.

Determinism requirements restrict operation semantics. Non-deterministic operations (e.g., timestamp generation, random number generation) must be executed by a leader or included as operation parameters. Non-deterministic side effects (external I/O, system clock reads) violate safety unless externalized through deterministic interfaces.

Fault tolerance requires `2f + 1` replicas to tolerate `f` crash failures (or `3f + 1` for Byzantine failures). Quorum-based variants (e.g., Fast Paxos, Generalized Paxos) reduce message complexity by allowing operations to commit without full replica agreement when no conflicts occur.

Performance characteristics: Write latency equals consensus latency (typically 1-2 RTTs for quorum-based protocols). Throughput is limited by the sequencer or consensus bottleneck. Batching amortizes consensus overhead by ordering multiple operations per consensus round.

**Quorum-Based Replication (Voting Protocols)**

Write operations are considered committed after acknowledgment from a write quorum of `W` replicas. Read operations query a read quorum of `R` replicas and resolve conflicts using timestamps or version vectors. Overlap between read and write quorums (`R + W > N` for `N` replicas) guarantees that reads observe the latest committed write.

Dynamo-style quorum systems use `N=3, R=2, W=2` for balanced latency and availability. Tunable quorum parameters adjust consistency-availability trade-offs: higher `W` reduces write availability but strengthens consistency; higher `R` reduces read availability but increases read freshness.

Sloppy quorums relax strict replica requirements during failures. Hinted handoff stores writes temporarily on available replicas outside the primary preference list, later transferring them to target replicas after recovery. This increases write availability but introduces additional inconsistency windows.

Last-write-wins (LWW) conflict resolution uses timestamps to select the "winning" version. LWW is non-deterministic if timestamps are not globally synchronized and can lose updates if concurrent writes have identical timestamps. Lamport timestamps or hybrid logical clocks provide causal ordering but do not resolve true conflicts.

Version vectors (vector clocks) track per-replica version numbers, enabling detection of causally concurrent writes. Concurrent versions are preserved as siblings, requiring application-level merge functions or CRDTs for automatic resolution. Sibling explosion can occur with high write concurrency.

Anti-entropy and read repair continuously reconcile divergent replicas. Merkle trees enable efficient comparison of replica state. Full reconciliation requires scanning all data, imposing background load.

**Multi-Master (Multi-Primary) Replication**

Multiple replicas accept writes concurrently without coordination. Each replica independently assigns operation identifiers or timestamps and asynchronously propagates changes to peer replicas. Conflict resolution occurs during merge operations.

Asynchronous replication provides high availability and low latency but guarantees only eventual consistency. Conflicts arise when concurrent writes to the same object occur at different masters. Detection requires version tracking (version vectors, logical clocks).

Conflict resolution strategies include:

- **Last-write-wins**: Timestamp-based, loses concurrent updates
- **Application merge functions**: Custom business logic for merging conflicting states (e.g., shopping cart union, counter summation)
- **CRDT-based resolution**: Conflict-free replicated data types with commutative merge operations (G-Counter, PN-Counter, OR-Set, LWW-Register)
- **Operational transformation**: Character-level or operation-level transformations for collaborative editing

Causal consistency can be provided using dependency tracking. Operations carry causal dependencies (vector clocks, dotted version vectors), and replicas defer applying operations until dependencies are satisfied. This prevents anomalies such as reading replies before corresponding messages.

Topology considerations: full-mesh topologies provide low propagation latency but scale poorly (O(N²) connections). Hub-and-spoke or hierarchical topologies reduce connection overhead but increase propagation latency and introduce single points of coordination.

Write-write conflict rates increase with geographic distribution, replica count, and write frequency to overlapping keyspaces. Partitioning data by access patterns or geographic boundaries reduces conflicts. Conflict-free data structures (CRDTs) eliminate coordination at the cost of weaker semantics or unbounded metadata growth.

**Chain Replication**

Writes propagate sequentially through a chain of replicas: head → R2 → ... → tail. The head receives writes, the tail acknowledges commits, and intermediate replicas forward updates. Reads are served exclusively by the tail, which reflects all committed writes.

Strong consistency is achieved with lower coordination overhead than quorum protocols. Read latency is constant (one replica) and reads never observe uncommitted writes. Write latency is linear in chain length (one RTT per hop).

Failure recovery reconfigures the chain. Head failure promotes R2 to head. Tail failure promotes the previous replica to tail. Mid-chain failures remove the failed replica and reconnect predecessors to successors. Reconfiguration requires coordination (typically via ZooKeeper or etcd) to maintain consistency invariants.

Chain replication variants include CRAQ (Chain Replication with Apportioned Queries), which allows reads from intermediate replicas by tracking per-object version metadata. Clean versions (replicas agree) are served immediately; dirty versions (propagation in progress) are redirected to the tail or blocked until clean.

Scalability is limited by head write throughput and tail read throughput. Multiple chains (partitioned data) parallelize load. Dynamic chain reconfiguration balances load but introduces complexity in maintaining consistent partition mappings.

**Paxos-Based Replication (Multi-Paxos, Raft)**

Consensus is used to agree on a totally ordered log of operations. A stable leader proposes log entries, and followers accept entries after verifying ordering constraints. Once a quorum commits an entry, it is durably replicated and can be applied to the state machine.

Multi-Paxos optimizes repeated consensus by electing a stable leader that proposes entries without repeated prepare phases. Leader leases or heartbeats prevent dueling leaders. Raft explicitly models leader election and log replication with well-defined state transitions.

Log-based replication decouples consensus (ordering) from state machine application. Replicas independently apply committed log entries, enabling heterogeneous state machine implementations (e.g., different storage engines) as long as operations are deterministic.

Failure handling: Leader failure triggers an election. Candidates collect votes from a quorum. The candidate with the most up-to-date log (highest term and longest log) wins. Write availability requires a majority quorum; minority partitions cannot elect leaders or commit writes.

Configuration changes (adding/removing replicas) use special log entries that are jointly committed by old and new configurations (joint consensus). This prevents split-brain during reconfiguration. Single-server changes (one replica added or removed at a time) simplify implementation at the cost of slower scaling operations.

Batching and pipelining improve throughput. Leaders propose multiple log entries concurrently, and followers apply committed entries in parallel. Out-of-order application is safe for independent operations but requires dependency tracking for dependent operations.

**Leaderless Quorum Protocols (Cassandra-Style)**

Clients coordinate reads and writes directly with replicas without a designated leader. Writes and reads contact `W` and `R` replicas respectively, with `R + W > N` ensuring overlap. Coordination is purely client-driven or mediated by stateless proxy nodes.

Writes include timestamps (typically microsecond-precision wall-clock or client-generated). Replicas accept writes immediately and merge based on timestamps. Concurrent writes are resolved using last-write-wins or other conflict resolution policies.

Reads query multiple replicas and perform read repair if inconsistencies are detected. Digest-based optimization compares hashes instead of full data. Blocking read repair delays response until consistency is restored; background read repair occurs asynchronously.

Tunable consistency: `QUORUM` (`R = W = ⌈N/2⌉`), `ONE` (lowest latency, weakest consistency), `ALL` (strongest consistency, lowest availability). `LOCAL_QUORUM` restricts operations to a single datacenter, improving latency for multi-datacenter deployments.

Write availability during partitions depends on quorum configuration. `W = 1` tolerates all but total datacenter failure but provides minimal consistency. `W = QUORUM` balances availability and consistency.

Hinted handoff and anti-entropy (Merkle tree-based) reconcile replicas after failures or partitions. Repair operations scan data to detect and fix inconsistencies, imposing significant I/O and network load.

### Consistency and Coordination Boundaries

Primary-based protocols centralize coordination, simplifying conflict resolution and providing strong consistency at the cost of single-point-of-failure and write scalability limits. Replicated-write protocols distribute coordination, improving availability and throughput but requiring complex conflict resolution and relaxing consistency guarantees.

Hybrid approaches partition data or operations: strong consistency for critical data via primary-based protocols, eventual consistency for less critical data via replicated-write protocols. Application-aware partitioning aligns consistency models with business requirements.

Cross-datacenter replication introduces latency and partition challenges. Primary-based protocols with distant primaries incur high write latency. Replicated-write protocols with conflict resolution absorb latency but increase eventual consistency windows. Regional primaries with asynchronous cross-region replication balance latency and consistency.

Operational trade-offs: Primary-based protocols simplify operational reasoning (single write path) but require robust failover automation. Replicated-write protocols distribute load and tolerate partitions but complicate debugging and conflict analysis.

### Related Topics

- Consensus algorithms (Paxos, Raft, ZAB, Viewstamped Replication)
- Byzantine fault tolerance (PBFT, HotStuff, Tendermint)
- Conflict-free replicated data types (CRDTs)
- Causal consistency and dependency tracking
- Log-structured merge trees and replication
- Cross-datacenter replication topologies
- Session guarantees and client-centric consistency
- Lease-based coordination and failure detection
- Total order broadcast and atomic broadcast
- Replication lag monitoring and alerting
- Split-brain prevention and fencing mechanisms
- Operational transformation for collaborative editing

---

