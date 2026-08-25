## Causal Ordering


Causal ordering preserves the happens-before relationship between events in distributed systems, ensuring that if event A causally precedes event B, all processes observe A before B. This ordering constraint is weaker than total ordering but stronger than eventual consistency, providing sufficient coordination for many distributed applications while avoiding the performance penalties of global synchronization.

### Happens-Before Relation

The happens-before relation (→) defines partial ordering over events in a distributed system based on three rules:

**Intra-Process Ordering:** If events a and b occur in the same process and a occurs before b in program order, then a → b. Local sequential consistency within a single thread of execution establishes causal dependencies.

**Message Send-Receive:** If event a is the sending of a message m and event b is the receipt of m, then a → b. Communication establishes causality across process boundaries.

**Transitivity:** If a → b and b → c, then a → c. Causality propagates through chains of dependencies.

**Concurrent Events:** Events a and b are concurrent (a || b) if neither a → b nor b → a. Concurrent events have no causal relationship and may be observed in different orders by different processes without violating causality.

### Vector Clocks

Vector clocks provide a mechanism to track causality in distributed systems through timestamp vectors where each process maintains a counter for every process in the system.

**Clock Structure:** Process Pi maintains vector clock VCi = [c1, c2, ..., cn] where n is the number of processes. Entry VCi[j] represents Pi's knowledge of the logical time at process Pj.

**Clock Update Rules:**

- Local event: VCi[i]++ before executing the event
- Send message: VCi[i]++, attach VCi to message m as timestamp m.VC
- Receive message m: VCi[j] = max(VCi[j], m.VC[j]) for all j, then VCi[i]++

**Causality Detection:**

- Event a → event b iff VC(a) < VC(b), meaning VC(a)[i] ≤ VC(b)[i] for all i and VC(a)[j] < VC(b)[j] for some j
- Events a and b are concurrent iff neither VC(a) < VC(b) nor VC(b) < VC(a)

**Space Complexity:** Vector clocks require O(n) space per event or message, making them impractical for systems with thousands of processes. Dynamic membership exacerbates this problem as the vector size must accommodate all historical participants.

**Optimization Techniques:**

- Sparse vector representation storing only non-zero entries
- Pruning vector entries for processes known to be inactive
- Interval tree clocks (ITC) for fork-join concurrency patterns
- Bounded vector clocks with approximation for large-scale systems

### Version Vectors

Version vectors apply vector clock principles to replicated data items, tracking the version history per replica to detect conflicts and determine which updates can be safely applied.

**Replica State:** Each replica Ri maintains version vector VVi[r1, r2, ..., rn] where VVi[j] records the number of updates Ri has seen from replica Rj.

**Update Propagation:**

- Local write at Ri: VVi[i]++
- Replicate update from Rj: merge received version vector, updating VVi[j]
- Version vector accompanies each data value to track its causal history

**Conflict Detection:** Two versions v1 and v2 conflict if neither VV(v1) ≤ VV(v2) nor VV(v2) ≤ VV(v1). Concurrent updates create siblings that require application-level conflict resolution.

**Dominance Relation:** Version v1 dominates v2 if VV(v1) > VV(v2), meaning v1 causally succeeds v2. Dominated versions can be safely discarded during reconciliation.

**Implementation Examples:**

- Dynamo-style systems use version vectors for multi-master replication
- Riak employs version vectors (formerly vector clocks) for sibling detection
- CRDTs leverage version vectors for causal consistency without coordination

### Dotted Version Vectors

Dotted version vectors (DVV) extend version vectors to handle delete-update anomalies and provide more accurate causality tracking in systems with concurrent writes and deletes.

**Dot Representation:** Each update is assigned a unique dot (replica_id, counter) that identifies the specific write event. The dot serves as a precise causal marker for the update.

**DVV Structure:** Combines a version vector (capturing causal history) with a set of dots (identifying concurrent versions). DVV = (VV, {(r1, c1), (r2, c2), ...}).

**Update Semantics:**

- Write at replica Ri creates new dot (i, VVi[i] + 1)
- Existing value retains its dot set
- Merge operation unions dot sets for concurrent values

**Advantages Over Version Vectors:**

- Correctly handles concurrent delete and update operations
- Prevents false conflicts from deleted values reappearing
- More precise sibling tracking for conflict resolution
- Bounded growth through garbage collection of obsolete dots

### Causal Broadcast

Causal broadcast ensures messages are delivered to all processes in an order consistent with causality. If message m1 causally precedes m2, all processes deliver m1 before m2.

**Delivery Guarantees:**

- If send(m1) → send(m2), then deliver(m1) → deliver(m2) at all processes
- Messages from the same sender delivered in send order
- Concurrent messages may be delivered in any order

**Implementation Approaches:**

**Vector Clock-Based:**

- Attach vector clock to each message
- Buffer messages until causal dependencies satisfied
- Deliver message m when VC(m)[j] = expected[j] + 1 for sender j and VC(m)[k] ≤ expected[k] for all k ≠ j

**Dependency Tracking:**

- Explicitly encode message dependencies in metadata
- Maintain delivery queue ordered by dependencies
- Deliver message when all dependencies have been delivered

**Timestamp-Based (Lamport Clocks):**

- Insufficient for causal broadcast alone as logical timestamps provide only partial ordering
- Requires additional mechanisms to distinguish concurrent events

**Scalability Constraints:**

- Buffering overhead grows with concurrent message rate
- Delivery latency increases with causal chain length
- Vector clock size limits participant count

### Causal Consistency in Distributed Stores

Causal consistency provides a consistency model for distributed data stores where reads reflect a causally-consistent view of writes. Reads observe all writes that causally precede them and no writes that follow them causally.

**Consistency Guarantees:**

- **Writes Follow Reads:** If process reads x then writes y, any process reading y will also observe the earlier write to x
- **Reads Follow Writes:** A process always observes its own writes
- **Monotonic Reads:** Successive reads by a process return increasingly recent values
- **Monotonic Writes:** Writes by a process are applied in issue order

**Implementation Strategies:**

**Explicitly Track Dependencies:**

- Client maintains causal context (version vector or vector clock)
- Write operations carry causal context indicating dependencies
- Replicas delay writes until dependencies satisfied

**Snapshot Isolation with Causality:**

- Assign timestamps to transactions using hybrid logical clocks
- Snapshot reads observe causally-consistent state
- Write-write conflicts detected through version vectors

**Causal+ Consistency (Eiger):**

- Extends causal consistency with conflict detection
- Two-round protocol: first round establishes dependencies, second round commits
- Handles both intra-datacenter and cross-datacenter replication

**COPS (Clusters of Order-Preserving Servers):**

- Causally-consistent replication across datacenters
- Get transactions provide causal consistency without coordination
- Put transactions use two-phase commit within datacenter, asynchronous replication across datacenters

**Operational Characteristics:**

- Lower latency than strong consistency (no cross-datacenter coordination)
- Higher complexity than eventual consistency (dependency tracking required)
- Metadata overhead from version vectors or dependency sets
- Garbage collection of old versions based on causal stability

### Causal Memory

Causal memory provides shared memory abstraction with causal consistency guarantees across distributed processes. Read and write operations appear to execute in an order consistent with causality.

**Memory Model:**

- Write operations become visible to all processes in causal order
- Read operations return values consistent with causal dependencies
- Concurrent writes may be observed in different orders by different processes

**Implementation Requirements:**

- Vector clocks or timestamps track causality of memory operations
- Write buffering until causal predecessors visible
- Read operations may need to wait for causally-required writes

**Use Cases:**

- Distributed shared memory systems
- Collaborative editing applications
- Replicated state machines with causal ordering requirements

### Session Guarantees

Session guarantees provide causal consistency within client sessions while allowing weaker guarantees across sessions. These guarantees bridge application-level causality with system-level ordering.

**Read Your Writes:** Client always observes its own previous writes. Implementation attaches write identifiers to session context and ensures subsequent reads reflect those writes.

**Monotonic Reads:** Client's successive reads return non-decreasing versions. Session tracks maximum observed version; reads must satisfy this bound.

**Writes Follow Reads:** Client's writes are ordered after any writes observed by previous reads. Write operations carry dependencies from reads.

**Monotonic Writes:** Client's writes applied in issue order. Session serializes writes through explicit dependencies or single-writer coordination.

**Implementation Mechanisms:**

- Session tokens carry version vectors or timestamps
- Sticky routing to replica that satisfies session guarantees
- Fallback to coordination when preferred replica unavailable
- Session state migration when client reconnects to different replica

### Causal Ordering in Event Streaming

Event streaming platforms require causal ordering to ensure downstream consumers process events in causally-consistent order, particularly for stateful stream processing.

**Partition-Level Ordering:** Events within a single partition maintain total order, providing causal consistency for causally-related events routed to the same partition.

**Cross-Partition Causality:**

- Application-level dependency tracking through event metadata
- Consumer buffers events until dependencies satisfied
- Out-of-order processing for provably independent events

**Stream Joins and Causality:**

- Watermarks indicate completeness boundaries for event arrival
- Join windows must account for causal dependencies across streams
- Late-arriving events may violate causal assumptions

**Event Sourcing Considerations:**

- Aggregate boundaries define causality domains
- Inter-aggregate causality requires explicit coordination or eventual consistency
- Event replay must preserve causal order within aggregate

### Hybrid Logical Clocks

Hybrid logical clocks (HLC) combine physical and logical time to provide causality tracking with bounded divergence from physical time. Each clock value consists of physical timestamp and logical counter.

**Clock Structure:** HLC = (pt, lc) where pt is physical time and lc is logical counter for events with same physical time.

**Update Rules:**

- Local event: pt' = max(pt, physical_time), lc' = lc + 1 if pt' = pt else 0
- Send message: update HLC, attach to message
- Receive message: pt' = max(pt, msg.pt, physical_time), lc' computed based on pt comparison

**Advantages:**

- Preserves happens-before relation like logical clocks
- Timestamps remain close to physical time for human interpretability
- Enables time-based queries and garbage collection policies
- Bounded clock skew prevents unbounded divergence

**Operational Benefits:**

- Log timestamps usable for debugging and correlation
- TTL and retention policies based on physical time semantics
- Ordering based on timestamp provides causal consistency
- Clock synchronization reduces logical counter increments

### Causality in Conflict-Free Replicated Data Types

CRDTs leverage causal ordering to achieve strong eventual consistency without coordination. Causal context determines safe concurrent update application.

**State-Based CRDTs:**

- Each replica maintains version vector or causal context
- Merge function combines concurrent states preserving causality
- Delivery order irrelevant due to commutativity and idempotence

**Operation-Based CRDTs:**

- Operations tagged with causal dependencies
- Downstream delivery respects causal order
- Concurrent operations commute by design

**Causal Context Propagation:**

- Updates carry causal context indicating dependencies
- Merge respects causal relationships to avoid lost updates
- Garbage collection removes obsolete causal information

### Causal Ordering Protocols

**CBCast (Causal Broadcast):** Immediate delivery protocol where sender attaches vector clock to messages. Recipients buffer messages until causal predecessors delivered.

**Lazy Replication:** Asynchronous causal broadcast for replicated data. Primary accepts writes immediately, propagates with causal dependencies to secondaries.

**Chain Replication with Causal Consistency:** Linearizes operations within chain while allowing concurrent operations across chains. Causal dependencies enforced through dependency vectors.

**Cure Protocol:** Provides causal consistency for geo-replicated stores with explicit dependency tracking and dependency metadata attached to transactions.

### Garbage Collection and Causality

**Stable Causal Context:** Portion of causal context that all replicas have processed. Safe to discard from version vectors and dependency sets.

**Garbage Collection Protocol:**

- Replicas periodically exchange vector clocks
- Compute minimum version vector across all replicas
- Prune metadata for events dominated by stable context

**Causal Stability:** Event is causally stable when all causally-dependent events have been processed by all replicas. Enables safe garbage collection of obsolete versions.

**Retention Policies:**

- Time-based retention combined with causal stability
- Space bounds require aggressive pruning with possible causality violations
- Application-level tombstones for deleted data require causal tracking

### Causality Violation Detection

**Anti-Entropy Mechanisms:**

- Merkle trees detect missing events without full replication
- Gossip protocols propagate causal context to identify gaps
- Read repair corrects violations during query processing

**Violation Symptoms:**

- Reads observe effects without causes
- Monotonicity violations in read sequences
- Lost updates from concurrent write operations

**Repair Strategies:**

- Fetch missing causal predecessors from other replicas
- Rollback and reapply operations in causal order
- Expose conflicts to application for resolution

### Performance Trade-offs

**Latency Overhead:**

- Buffering delays for causal dependencies increase delivery latency
- Vector clock computation adds CPU overhead to message processing
- Dependency resolution requires additional round trips

**Metadata Growth:**

- Vector clock size scales with process count
- Version vectors accumulate siblings during concurrent updates
- Dependency sets grow with concurrent operation rate

**Throughput Impact:**

- Causal ordering limits parallelism to independent operations
- Synchronization points for dependency resolution reduce throughput
- Network bandwidth consumed by causal metadata

**Trade-off Spectrum:**

- Eventual consistency: minimal overhead, no causal guarantees
- Causal consistency: moderate overhead, causality preserved
- Sequential consistency: high overhead, total ordering

### Related Topics

- Vector Clocks
- Version Vectors
- Logical Clocks (Lamport)
- Conflict-Free Replicated Data Types (CRDTs)
- Eventual Consistency
- Sequential Consistency
- Session Guarantees
- Hybrid Logical Clocks
- Gossip Protocols
- Merkle Trees
- Anti-Entropy
- Causal Broadcast Protocols
- Snapshot Isolation

---

