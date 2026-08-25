## Failure Types in Distributed Systems


### Crash Failures

Process halts permanently and ceases all execution. No further messages sent or state transitions occur. Represents fail-stop behavior where detection is eventually possible through heartbeat timeouts or failure detectors. Process does not recover or exhibit inconsistent behavior prior to stopping.

**Detection Mechanisms:**

- Heartbeat protocols with configurable timeout intervals
- Failure detector abstractions (perfect, eventually perfect, eventually strong)
- Lease-based mechanisms with bounded clock drift assumptions
- Gossip-based membership protocols (SWIM, Serf)

**Architectural Implications:**

- Requires stateful replication for durability (Raft, Paxos, chain replication)
- Leader election protocols assume crash-recovery or crash-stop models
- Epoch-based coordination to distinguish stale from current leaders
- Quorum-based operations to tolerate minority crash failures
- State machine replication achieves linearizability under crash failures
- Recovery protocols must handle log replay and snapshot restoration

**Consensus Protocol Handling:**

- Raft: Leader crash triggers election timeout, new term election
- Multi-Paxos: Proposer crash requires new proposer to complete partially committed operations
- Viewstamped Replication: View change protocol handles primary crash
- ZAB: Epoch increments on leader crash, recovery phase synchronizes followers

**Recovery Strategies:**

- Write-ahead logging (WAL) for durable state reconstruction
- Checkpointing with log truncation to bound recovery time
- Snapshot-based recovery with incremental log replay
- Anti-entropy protocols for state synchronization post-recovery

---

### Omission Failures

Messages lost in transit between sender and receiver. Process remains operational but specific message transmissions fail. Subdivides into send omissions (sender fails to send), receive omissions (receiver fails to receive), and general omissions (arbitrary message loss).

**Network-Layer Causes:**

- Network congestion and buffer overflow
- Packet corruption triggering checksum failures
- Routing failures and path unavailability
- Firewall or network policy drops
- NIC queue saturation

**Detection Challenges:**

- Indistinguishable from crash failures without additional assumptions
- Timeout-based detection conflates omissions with delays
- Requires application-level acknowledgments for verification
- Network partitions manifest as sustained omission failures

**Protocol Adaptations:**

- Retry mechanisms with exponential backoff
- Idempotency tokens to handle duplicate delivery
- Sliding window protocols for flow control
- Sequence numbers for ordering and gap detection
- Cumulative acknowledgments vs selective acknowledgments

**Consistency Model Impact:**

- Omission failures prevent strong consistency without quorums
- At-least-once delivery semantics under retry-based recovery
- Exactly-once semantics require deduplication with persistent state
- Causal consistency achievable with vector clocks under omissions
- Session guarantees (monotonic reads/writes) require client-side tracking

**Replication Topology Considerations:**

- Synchronous replication vulnerable to tail latency amplification
- Asynchronous replication tolerates omissions with eventual consistency
- Quorum-based systems tolerate minority omission failures
- Chain replication sensitive to omissions on chain links
- Gossip protocols probabilistically overcome omissions

---

### Timing Failures

Process or network violates timing constraints but continues operating. Messages arrive outside expected time bounds. Clock drift exceeds synchronization assumptions. Relevant primarily in synchronous or partially synchronous system models.

**Manifestations:**

- Clock skew between nodes exceeds acceptable delta
- Heartbeat timeouts fire prematurely under load
- Lease expirations occur during valid lease periods (from holder's perspective)
- Coordination delays exceed assumed upper bounds
- Scheduling delays from resource contention (CPU, I/O)

**Clock Synchronization Protocols:**

- NTP for millisecond-level synchronization (bounded drift assumptions fragile)
- PTP for microsecond-level synchronization in controlled networks
- TrueTime (Google Spanner) provides bounded uncertainty intervals
- Hybrid Logical Clocks combine physical and logical time

**Architectural Consequences:**

- Lease-based coordination requires conservative timeout margins
- Distributed locking vulnerable to false expiration under timing failures
- Optimistic concurrency control with timestamp ordering fails under clock skew
- Fencing tokens or epoch counters prevent split-brain from timing violations
- Linearizability requires synchronized clocks or explicit coordination

**CAP/PACELC Trade-offs:**

- Timing failures blur availability boundaries in CP systems
- Extended timeouts sacrifice latency for reliability
- False failure detection triggers unnecessary failover cascades
- Probabilistic quorum systems tolerate timing variability better than deterministic protocols

**Mitigation Strategies:**

- Adaptive timeout algorithms (Phi Accrual failure detector)
- Explicit fencing mechanisms independent of timing
- Logical clock schemes (Lamport timestamps, vector clocks) eliminate physical clock dependency
- Grace periods and hysteresis in lease renewal
- Monitoring clock drift and alerting on threshold violations

**Split-Brain Prevention:**

- Fencing tokens issued by external coordination service (ZooKeeper, etcd)
- Generation numbers or epoch counters invalidate stale leaders
- Quorum-based coordination prevents unilateral action
- STONITH (Shoot The Other Node In The Head) for absolute prevention

---

### Byzantine Failures

Arbitrary, potentially malicious behavior. Process may send conflicting messages, corrupt state, collude with other nodes, or exhibit adversarial behavior. Subsumes all other failure types plus arbitrary deviations from protocol.

**Threat Models:**

- Malicious actors compromising nodes
- Software bugs causing non-deterministic behavior
- Hardware faults (bit flips, memory corruption) causing arbitrary state
- Side-channel attacks or timing attacks
- Sybil attacks in open membership systems

**Byzantine Fault Tolerance (BFT) Requirements:**

- Requires 3f+1 replicas to tolerate f Byzantine failures (quorum intersection property)
- 2f+1 replicas insufficient as Byzantine nodes can equivocate
- Cryptographic authentication to prevent message forgery
- Proof-of-work, proof-of-stake, or identity-based Sybil resistance in permissionless systems

**Consensus Protocols:**

- PBFT (Practical Byzantine Fault Tolerance): Three-phase commit with cryptographic signatures
- Tendermint/Cosmos: BFT consensus with validator rotation and slashing
- HotStuff: Linear message complexity BFT with pipelined phases
- Raft/Paxos: NOT Byzantine fault-tolerant (assume correct process behavior)

**Permissioned vs Permissionless:**

- Permissioned: Known validator set, digital signatures, lower latency (PBFT, Tendermint)
- Permissionless: Open participation, Sybil resistance via economic cost (Nakamoto consensus, PoS)
- Hybrid: Consortium blockchains with restricted membership but untrusted validators

**Performance Characteristics:**

- High message complexity (O(n²) for PBFT, O(n) for HotStuff)
- Cryptographic overhead (signature verification, Merkle proofs)
- View change complexity on primary failure
- Latency typically 10-100x higher than crash fault-tolerant protocols

**State Machine Replication:**

- Application state must be deterministic under BFT
- Non-deterministic operations (timestamps, randomness) require coordination
- State verification through cryptographic commitments or Merkle trees
- Checkpoint and garbage collection protocols to prune history

**Blockchain-Specific Patterns:**

- Longest chain rule or GHOST for fork resolution
- Finality gadgets (Casper FFG) for economic finality
- Light client protocols for state verification without full history
- Cross-chain bridges require Byzantine-resistant verification

**Detection and Recovery:**

- Cryptographic proofs of misbehavior (equivocation proofs, double-spend proofs)
- Slashing mechanisms penalize provably Byzantine behavior
- Reputation systems and bonding in economic security models
- Forensic analysis through audit logs and cryptographic evidence

**Practical Limitations:**

- Liveness vulnerable to >f Byzantine nodes in many BFT protocols
- Network partitions combined with Byzantine failures can stall progress
- Computational cost limits throughput (hundreds to low thousands TPS for permissioned BFT)
- Storage overhead from maintaining cryptographic proofs and history

---

### Failure Type Hierarchy and Relationships

**Containment:**

- Byzantine ⊃ Timing ⊃ Omission ⊃ Crash
- Stronger failure models tolerate weaker failures
- Protocols designed for crash failures fail under Byzantine conditions

**System Model Assumptions:**

- Synchronous: Bounded message delays and processing time (timing failures detectable)
- Asynchronous: No timing bounds (FLP impossibility applies)
- Partially synchronous: Eventually bounded (most practical systems)

**Failure Detector Classes:**

- Perfect (P): Strong completeness and strong accuracy (requires synchrony)
- Eventually Perfect (◊P): Eventually strong accuracy (crash failures in partial synchrony)
- Eventually Strong (◊S): Sufficient for consensus in asynchronous systems
- Byzantine failure detectors require cryptographic verification

---

### Cross-Cutting Architectural Concerns

**Observability:**

- Failure injection testing (Chaos Engineering) to validate failure handling
- Distributed tracing to correlate failures across components
- Metrics on timeout rates, retry counts, failure detector accuracy
- Alerting on failure rate threshold violations

**Failure Domain Isolation:**

- Rack, zone, region anti-affinity for replica placement
- Bulkhead pattern to isolate failure blast radius
- Circuit breakers to prevent cascading failures
- Graceful degradation through feature flags and fallbacks

**Economic Trade-offs:**

- Additional replicas increase cost linearly
- BFT protocols require more resources than crash fault-tolerant systems
- Network bandwidth consumption in gossip and BFT protocols
- Storage overhead for WAL, snapshots, and cryptographic proofs

**Related Topics:**

- Consensus protocols
- Failure detectors
- State machine replication
- Quorum systems
- Replicated state machines
- Partition tolerance
- Network partition handling
- Split-brain scenarios
- Fencing mechanisms
- Lease-based coordination
- Blockchain consensus mechanisms
- Epidemic protocols

---

