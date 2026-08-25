## Failure Model


### Crash Failures (Fail-Stop)

Process halts permanently, performs no further actions. Other processes eventually detect crash via timeouts, heartbeat absence, or failure detector signals. Simplified reasoning: crashed process never produces conflicting state. Enables straightforward recovery via state replication or checkpointing.

Design assumption: crashed processes do not corrupt shared state before halting. Practical challenge: distinguishing crash from slow response requires timeout tuning (false positives cause unnecessary failover overhead).

Architectural implication: leader-based systems (Raft, Zab) handle crash via leader re-election. Quorum-based systems (Paxos, Cassandra) tolerate _f_ crash failures with 2_f_+1 replicas. State machine replication models crash as stopped replica—remaining replicas continue serving requests.

### Omission Failures

Process omits sending/receiving messages but otherwise executes correctly. Send omission: outbound messages lost. Receive omission: inbound messages ignored or dropped. General omission: both directions. Indistinguishable from network message loss in practice.

Design consequence: protocols must handle message loss via retransmission, acknowledgments, and sequence numbering. TCP masks omission failures via reliable delivery; UDP exposes omission failures to application layer. Distributed consensus assumes fair-loss links (messages lost finitely often) or stubborn links (infinite retries eventually succeed).

Quorum systems tolerate omission by requiring responses from majority—non-responsive replicas excluded from quorum. Epidemic broadcast protocols tolerate omission via redundant message propagation paths.

### Timing Failures

Process or communication channel violates timing specification: message delayed beyond bound, process execution too slow, clock drift exceeds threshold. Specific to synchronous models where timing bounds exist.

Manifestation: leader lease expires prematurely due to clock skew; timeout fires incorrectly causing false failure detection; request latency SLA violation. Solutions: clock synchronization (NTP, PTP), adaptive timeouts, lease renewal with guard intervals.

Operational impact: timing failures under load cause cascading effects—false failure detection triggers unnecessary failover, increasing load on remaining nodes, causing further timing violations. Observability critical: latency percentiles (p50/p99/p999), clock skew monitoring, timeout effectiveness tracking.

### Byzantine Failures (Arbitrary Failures)

Process exhibits arbitrary behavior: sends conflicting messages, corrupts state, colludes with other faulty processes, violates protocol specification. Models malicious adversaries, software bugs causing arbitrary output, hardware faults producing incorrect computation results.

Byzantine agreement requires 3_f_+1 replicas to tolerate _f_ Byzantine processes (vs 2_f_+1 for crash). Algorithms: PBFT (Practical Byzantine Fault Tolerance), HotStuff, Tendermint. Requires authenticated communication (digital signatures, MACs) to prevent message forgery.

Design complexity: significantly higher message complexity (O(n²) vs O(n) for crash-tolerant protocols), cryptographic overhead, replica state verification via Merkle trees or authenticated data structures. Byzantine quorum intersection: any two quorums must overlap in at least _f_+1 correct replicas.

Use cases: blockchain consensus (untrusted participants), critical infrastructure (defense against compromised nodes), multi-party computation. Trade-off: Byzantine fault tolerance requires 50% more replicas and order-of-magnitude higher latency than crash-tolerant equivalents.

Architectural boundary: Byzantine assumptions typically applied at inter-organizational boundaries; within trusted clusters, crash model sufficient.

### Failure Detection

**Perfect failure detector (P)**: Never suspects correct processes (strong completeness), eventually suspects all crashed processes (strong accuracy). Only realizable in synchronous systems with known bounds.

**Eventually perfect failure detector (◇P)**: Eventually stops suspecting correct processes, eventually suspects all crashed processes. Sufficient for consensus in asynchronous systems with crash failures. Implemented via heartbeat + adaptive timeout.

**Strong failure detector (S)**: At least one correct process never suspected by any correct process. Enables leader-based protocols—unsuspected process acts as stable leader.

Implementation approaches: timeout-based (heartbeat intervals, exponential backoff), probabilistic (gossip-based suspicion levels), quality-of-service metrics (latency, jitter monitoring). False positives cause unnecessary state transitions; false negatives delay failure recovery.

Chandra-Toueg result: consensus solvable in asynchronous systems with crash failures and ◇S failure detector. Architectural pattern: decouple failure detection from coordination logic—failure detector module provides suspicion signals, coordination algorithm consumes signals without timing assumptions.

---

