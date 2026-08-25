## Interaction Model


### Synchronous Model

Assumes bounded message transmission delay _d_, bounded clock drift rate _ρ_, and bounded process execution step time. Each process step completes within known bounds. Enables timeout-based failure detection with guaranteed accuracy. Fischer-Lynch-Paterson impossibility does not apply. Practical systems approximate synchrony through assumptions on network RTT bounds, CPU scheduling guarantees, and clock synchronization protocols (NTP, PTP). Trade-off: overly conservative bounds reduce system utilization; aggressive bounds cause false failure detection during transient load spikes or network congestion.

Design constraint: timeout values must account for worst-case message delay, queueing delay, processing delay, and clock skew. Synchronous assumptions break under network partitions, cascading failures, or resource exhaustion.

### Asynchronous Model

No bounds on message delay, process execution speed, or clock drift. Messages eventually delivered but arrival order and timing unpredictable. FLP impossibility theorem applies: no deterministic consensus algorithm can guarantee termination in asynchronous systems with even one crash failure. Requires failure detectors (unreliable in pure asynchrony) or randomization (Ben-Or, probabilistic termination) or partial synchrony assumptions.

Design implication: timeouts cannot reliably distinguish slow processes from crashed processes. Systems must handle arbitrary message reordering, duplicate delivery, and indefinite blocking. Liveness properties cannot be guaranteed deterministically; safety properties still achievable. Coordination protocols must be designed for progress under arbitrarily delayed responses.

Architectural consequence: leader election, consensus, and atomic commitment require either weakening guarantees (eventual consistency, probabilistic termination) or hybrid timing models.

### Partially Synchronous Model

Assumes system eventually becomes synchronous after unknown Global Stabilization Time (GST). Before GST, behaves asynchronously; after GST, message delays and process speeds bounded. Practical Raft, Multi-Paxos, Viewstamped Replication, PBFT operate under partial synchrony. Enables deterministic consensus with guaranteed termination post-GST while remaining safe during asynchronous periods.

Design pattern: algorithms make progress after GST, remain safe (but potentially blocked) before GST. Leader-based protocols use increasing timeouts or exponential backoff to adapt to unknown bounds. Typical GST triggers: network partition healing, load reduction, resource availability recovery.

Operational reality: real systems exhibit periods of approximate synchrony interrupted by asynchronous behavior (tail latencies, network jitter, GC pauses). Partial synchrony models real-world networks better than pure synchronous or asynchronous extremes.

### Communication Patterns

**Point-to-point vs multicast**: Direct messaging between processes vs broadcast to process groups. Multicast requires ordering guarantees (FIFO, causal, total order) and failure atomicity (all-or-none delivery). Atomic broadcast equivalent to consensus. IP multicast unreliable; application-layer multicast (gossip, overlay trees) trades latency for reliability.

**Request-response vs asynchronous messaging**: Synchronous RPC couples sender/receiver lifetimes; asynchronous message queues decouple via intermediary buffers. Request-response enables back-pressure and flow control; async messaging enables temporal decoupling but requires dead-letter handling and message expiration policies.

**At-most-once vs at-least-once vs exactly-once**: At-most-once requires idempotent operations or request deduplication (sequence numbers, request IDs). At-least-once achieves higher availability via retries but demands idempotent processing. Exactly-once requires distributed transactions or idempotent processing with deduplication—operational complexity high, performance cost significant.

Network partitioning constraint: all communication patterns vulnerable to partition-induced message loss, duplication, or reordering. Interaction model determines detection/recovery mechanisms.

---

