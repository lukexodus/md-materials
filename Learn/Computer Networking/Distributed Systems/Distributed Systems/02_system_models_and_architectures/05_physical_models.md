## Physical Models


### Synchronous System Model

Processes execute in lock-step rounds with known bounded execution time per step. Message delivery occurs within a known fixed bound, and local processing completes within a known bound. Clock drift between processes remains bounded by a known constant. Enables deterministic timeout-based failure detection—if a process fails to respond within the bound, it is definitively crashed. Simplifies consensus protocols (e.g., Paxos variants optimized for synchrony) by allowing fixed-round algorithms with guaranteed termination. Real-world applicability is limited to tightly-coupled systems such as hardware-synchronized clusters, FPGA-based distributed systems, or safety-critical embedded systems with real-time operating systems and dedicated networks. Network variability, OS scheduling non-determinism, and garbage collection pauses violate synchrony assumptions in general-purpose distributed systems.

Trade-offs: Strong guarantees (deterministic failure detection, simpler correctness proofs) versus lack of real-world applicability in internet-scale or cloud environments. Synchronous algorithms cannot tolerate assumption violations—a single deadline miss can cause system-wide incorrectness or liveness failures.

### Asynchronous System Model

No bounds exist on message delivery latency, process execution speed, or clock drift. Messages may be arbitrarily delayed but not lost (unless explicitly modeling lossy networks). Failure detection becomes impossible to distinguish from slow processes or delayed messages—the fundamental result of the FLP impossibility theorem states that deterministic consensus is unachievable in purely asynchronous systems with even one faulty process.

Protocols designed for asynchrony must rely on probabilistic guarantees, randomization (e.g., Ben-Or's randomized consensus), failure detectors with eventual properties (e.g., eventually perfect failure detectors in Chandra-Toueg), or progress only during periods of synchrony. Asynchronous algorithms provide safety under all conditions but sacrifice guaranteed liveness. Examples include Paxos (safe always, live only with eventual synchrony), Raft (similar liveness assumptions), and gossip protocols (eventual consistency with probabilistic convergence).

Real-world systems operate asynchronously most of the time, making this model the foundation for internet-scale distributed systems. Architects must explicitly design for unbounded delays through timeouts with exponential backoff, idempotency, retry logic, and graceful degradation rather than assuming bounded behavior.

Trade-offs: Realistic model matching production environments versus impossibility of certain guarantees (deterministic consensus, bounded-time failure detection). Requires probabilistic or heuristic mechanisms for progress.

### Partially Synchronous System Model

Systems alternate between asynchronous and synchronous periods, or have unknown but existing bounds on message delay and processing time. The Global Stabilization Time (GST) represents the point after which the system behaves synchronously, though GST is unknown to processes. Before GST, the system is fully asynchronous; after GST, timing bounds hold.

This model reconciles theoretical impossibility results with practical system behavior. Most production distributed systems exhibit partial synchrony—networks experience congestion, processes face load spikes, but eventually stabilize. Protocols like Paxos, Raft, and PBFT are designed for partial synchrony: they guarantee safety always (even during asynchronous periods) and guarantee liveness after GST (during synchronous periods).

Failure detectors in partially synchronous systems provide eventual accuracy—they may incorrectly suspect live processes during asynchronous periods but become accurate after GST. This enables consensus protocols to make progress without violating safety during temporary network partitions or slowdowns.

Architectural implications: Systems must tolerate arbitrary delays without compromising safety invariants. Liveness mechanisms (leader election, timeout-based retries) should be tuned for expected-case synchrony while remaining safe under worst-case asynchrony. Monitoring and alerting should distinguish between temporary asynchrony (transient slowdowns) and persistent failures.

Trade-offs: Balances realism with achievability—consensus becomes possible with this model. However, protocols remain complex due to needing correctness under both asynchronous and synchronous conditions. Performance tuning is difficult since GST is unknowable and variable.

### Timing Assumptions and Failure Detection

Timeout-based failure detection relies on timing assumptions. In synchronous models, timeouts deterministically identify failures. In asynchronous models, timeouts cannot distinguish crashes from delays, leading to false positives. In partially synchronous models, timeouts may initially produce false positives but eventually become accurate.

Failure detector classes (from Chandra-Toueg):

- **Perfect (P):** Never suspects correct processes, eventually suspects crashed processes. Requires synchrony.
- **Eventually Perfect (◇P):** May temporarily suspect correct processes but eventually stops doing so; eventually suspects all crashed processes. Achievable in partial synchrony after GST.
- **Strong (S):** Some correct process is never suspected by any correct process.
- **Eventually Strong (◇S):** Eventually, some correct process is never suspected. Sufficient for consensus.

Adaptive timeout mechanisms adjust based on observed latencies—exponential backoff, percentile-based thresholds (e.g., P99 + margin), or phi-accrual failure detectors (used in Akka, Cassandra) compute suspicion levels rather than binary crash/alive states. Phi-accrual allows tuning sensitivity to false positives versus detection speed.

Implementation considerations: Heartbeat intervals must balance detection latency against network overhead. Timeout values should account for OS scheduling, GC pauses, network congestion, and cross-datacenter latencies. Production systems often use multiple concurrent failure detectors with different thresholds to decouple detection from action (e.g., gossip spreading suspicions separately from triggering failover).

### Crash-Stop, Crash-Recovery, and Byzantine Failure Models

**Crash-Stop:** Processes fail by halting permanently. No incorrect behavior before crash; state is lost. Simplest failure model for protocol design. Example: primary-backup replication with lease-based failover assumes crash-stop semantics for the primary.

**Crash-Recovery:** Processes may crash and later restart, potentially losing volatile state but preserving durable state. Requires persistent storage and recovery protocols. Introduces complexities around distinguishing old messages from pre-crash epochs versus current messages. Epoch numbers, incarnation identifiers, or fencing tokens prevent stale processes from interfering after recovery. Paxos, Raft, and most production consensus protocols assume crash-recovery with durable storage for replicated logs.

Recovery protocol concerns:

- **State reconstruction:** Replaying logs, rehydrating in-memory indexes.
- **Membership reintegration:** Rejoining the cluster, catching up on missed state, rebalancing load.
- **Stale message filtering:** Ignoring messages from previous incarnations using monotonic identifiers.

**Byzantine (Arbitrary) Failures:** Processes may deviate arbitrarily from protocol—sending conflicting messages, corrupting data, acting maliciously or due to bugs. Requires Byzantine Fault Tolerant (BFT) protocols like PBFT, HotStuff, or Tendermint. BFT protocols require **3f + 1** replicas to tolerate **f** Byzantine failures (versus **2f + 1** for crash failures). Cryptographic signatures authenticate messages to prevent forgery. Quorum intersection and verification ensure correctness despite arbitrary behavior.

BFT is necessary for adversarial environments (blockchains, multi-organization systems) or systems where software bugs or hardware corruption can cause arbitrary failures. Overhead is significantly higher than crash-tolerant protocols due to additional communication rounds, cryptographic operations, and larger quorums.

Trade-offs: Crash-stop simplifies protocol design but is unrealistic (systems recover). Crash-recovery matches production but complicates correctness reasoning. Byzantine models provide strongest guarantees at highest cost—reserve for high-stakes or adversarial deployments.

### Network Models: Reliable, Fair-Loss, and Arbitrary

**Reliable Links:** Every message sent is eventually delivered exactly once, without duplication, reordering, or loss. Simplifies protocol design—no need for retransmission, deduplication, or sequence numbers at the application layer. Unrealistic for real networks; typically approximated by TCP or reliable messaging middleware. Even TCP can fail if connections break, requiring higher-level retry logic.

**Fair-Loss Links:** Messages may be lost, but if sender repeatedly transmits, the message is eventually delivered. No duplication or corruption. Models UDP-like transports. Protocols must implement retransmission with timeouts and deduplication using message identifiers. Enables reasoning about eventual delivery through unbounded retries. Used in modeling gossip protocols, eventual consistency systems, and failure detector heartbeats.

**Arbitrary (Byzantine) Links:** Messages can be lost, duplicated, reordered, delayed, or corrupted. Adversarial model where the network actively interferes. Requires cryptographic authentication (HMACs, signatures) to detect tampering, sequence numbers to detect duplication/reordering, and checksums or authenticated encryption to detect corruption. Point-to-point authenticated channels prevent message injection but not delays or drops.

Practical network stacks approximate reliable links (TCP) over arbitrary physical networks through retransmission, checksums, and sequencing. Application-layer protocols often assume TCP-like reliability but must handle connection failures, head-of-line blocking, and endpoint crashes. UDP-based systems explicitly manage loss and reordering, using application-layer sequence numbers (e.g., QUIC) or relying on higher-level idempotency and retries.

Network partition handling: Even with reliable links, partitions can isolate subsets of processes. Protocols must remain safe under partition—consensus protocols using quorums ensure no two partitions can commit conflicting decisions. Availability during partitions depends on whether the quorum is reachable (majority-based systems sacrifice availability in minority partitions).

### Synchrony, Timing, and Real-World Systems

Real-world systems exhibit **variable synchrony**—local-area networks within a datacenter approximate synchrony most of the time (sub-millisecond latencies, bounded by switch forwarding delays), while wide-area networks are asynchronous (unbounded internet routing delays, congestion, packet loss). Tail latencies (P99, P99.9) often violate expected bounds due to OS scheduling, garbage collection, network retransmissions, or hardware issues.

Architects must design for asynchrony but exploit periods of synchrony for performance. Techniques:

- **Adaptive timeouts:** Adjust based on observed latencies; avoid premature timeouts during transient slowdowns.
- **Leases:** Time-bounded locks that expire automatically, ensuring safety even if the holder crashes or is partitioned. Lease duration trades off failover speed (shorter leases) versus overhead from renewals (longer leases).
- **Epoch/term numbers:** Logical clocks incremented on leader changes; prevent stale leaders from issuing conflicting operations.
- **Hedged requests:** Send duplicate requests to replicas to reduce tail latency; cancel redundant responses.
- **Graceful degradation:** Systems should remain safe (no data corruption) even if unavailable (cannot make progress) under asynchrony or partitions.

Clocks and time:

- **Physical clocks:** Subject to drift, NTP synchronization is imperfect (milliseconds to tens of milliseconds in WANs). Never rely on exact clock agreement for correctness. Google Spanner uses GPS/atomic clocks with bounded uncertainty (TrueTime API) to enable external consistency, but this is exceptional.
- **Logical clocks:** Lamport clocks, vector clocks, or hybrid logical clocks (HLCs) provide causality tracking without requiring synchronized physical time. Suitable for ordering events in distributed logs, version vectors in conflict detection, or causal consistency.

### Related Topics

- CAP theorem and PACELC framework
- Consensus protocols (Paxos, Raft, Byzantine consensus)
- Failure detectors and group membership protocols
- Consistency models (linearizability, sequential, causal, eventual)
- Replication protocols (primary-backup, chain replication, quorum-based)
- Network partitioning and split-brain prevention
- Distributed coordination services (Chubby, ZooKeeper, etcd)
- Time and causality in distributed systems (vector clocks, TrueTime, hybrid logical clocks)

---

