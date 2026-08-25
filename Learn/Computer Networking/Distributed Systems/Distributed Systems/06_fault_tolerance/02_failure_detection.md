## Failure Detection


### Heartbeat-Based Detection

Periodic liveness signals transmitted from monitored processes to failure detectors. Heartbeat interval directly impacts detection latency and network overhead. Missing _k_ consecutive heartbeats triggers suspected failure. Adaptive heartbeat intervals adjust based on observed network conditions and historical failure patterns.

**Push Model**: Monitored process actively sends heartbeats to detectors. Failure to send indicates process crash, network partition, or resource exhaustion. Lower detection latency but higher network load under scale.

**Pull Model**: Detector actively queries monitored processes. Timeout on query response indicates failure. Centralizes polling logic but introduces detector as single point of failure and bottleneck.

**Hybrid Model**: Combines push heartbeats with occasional pull verification. Reduces false positives from transient network issues while maintaining reasonable detection latency.

### Timeout-Based Detection

Failure suspicion triggered when expected message or heartbeat not received within timeout period _T_. Timeout value selection represents fundamental trade-off between detection speed and false positive rate.

**Fixed Timeouts**: Static threshold. Simple but brittle under variable network conditions. Cannot adapt to changing latency distributions or system load patterns.

**Adaptive Timeouts**: Dynamically adjust based on observed message round-trip times and network jitter. Algorithms include exponential moving averages, statistical percentile-based bounds (e.g., p99 + safety margin), or machine learning models predicting expected response times.

Timeout misconfiguration causes cascading failures. Overly aggressive timeouts generate false positives leading to unnecessary failovers, state transfers, and cluster instability. Conservative timeouts delay legitimate failure detection, extending unavailability windows.

### Phi Accrual Failure Detector

Probabilistic detector outputting continuous suspicion level φ(t) rather than binary alive/dead state. φ value represents likelihood of failure based on heartbeat arrival distribution.

**φ Calculation**: Uses sliding window of recent heartbeat inter-arrival times to estimate probability distribution (typically normal or exponential). For each missed heartbeat, φ increases based on deviation from expected arrival time. φ = -log₁₀(P(arrival_time > now)).

**Threshold-Based Actions**: Different system actions triggered at different φ levels. Low φ: no action. Medium φ: mark as suspected, begin connection migration. High φ: declare failure, initiate recovery.

Decouples failure detection from failure response policy. Same detector infrastructure supports varied requirements across system components. Avoids premature commitment to binary state under uncertainty.

### Gossip-Based Detection

Distributed failure detection without centralized coordinator. Nodes periodically exchange heartbeat information and failure suspicions via anti-entropy gossip protocol.

**Gossip Rounds**: Each node randomly selects _k_ peers and exchanges full or incremental membership state including last-seen timestamps for all known nodes. Failure suspicion propagates logarithmically: O(log N) rounds to reach all nodes in cluster of size N.

**Suspicion Accumulation**: Node declared failed when sufficient fraction of cluster members suspect failure. Implements distributed voting mechanism. Configurable thresholds balance detection speed against false positive resilience.

**Network Partition Tolerance**: Majority-based suspicion prevents split-brain in symmetric partitions. Asymmetric partitions (minority can reach majority, but not reverse) still cause minority node eviction.

Scales horizontally with cluster size. No single failure detector bottleneck. Increased gossip overhead: O(N) messages per node per round in naive implementation. Optimizations include membership subsampling, incremental state transfer, and gossip fanout limits.

### SWIM (Scalable Weakly-consistent Infection-style Process Group Membership)

Gossip-based membership protocol combining direct probing, indirect probing, and dissemination phases.

**Direct Probe**: Node _i_ sends ping to randomly selected target _j_. Expects ack within timeout _T_.

**Indirect Probe**: On direct probe timeout, _i_ requests _k_ other nodes to probe _j_. If any indirect probe succeeds, _j_ is alive (network partition between _i_ and _j_). If all indirect probes timeout, suspect _j_ failed.

**Dissemination**: Failure suspicions and membership changes piggybacked on all protocol messages. Infection-style propagation achieves O(log N) dissemination time with bounded message size.

**Suspicion Mechanism**: Suspected nodes remain in membership with suspected state, allowing refutation if alive. Confirmed dead after suspicion timeout without refutation. Reduces false positives from transient failures or network glitches.

Expected constant detection time independent of cluster size. Message load per node independent of cluster size. Protocol complexity increases with multi-datacenter deployments requiring topology-aware probe selection.

### Fencing and Split-Brain Prevention

Failure detection accuracy directly impacts split-brain risk. False positives cause concurrent primaries, risking data corruption or consistency violation.

**Fencing Tokens**: Monotonically increasing epoch/generation numbers accompany all write operations. Storage layer rejects writes with stale tokens. Requires total ordering of failover events and persistent token storage.

**Distributed Lock Services**: Consensus-based coordinators (ZooKeeper, etcd, Consul) provide fencing through exclusive lock acquisition with session timeouts. Lock holder automatically fenced when session expires due to heartbeat failure.

**STONITH (Shoot The Other Node In The Head)**: Physical node isolation through power cycling, BMC commands, or network switch reconfiguration. Guarantees failed node cannot perform I/O before replacement takes over. Requires out-of-band management infrastructure.

**Lease-Based Fencing**: Time-bounded exclusive ownership. Primary loses authority after lease expiration, must renew before performing operations. Requires synchronized clocks with bounded drift or clock-synchronized storage layer.

### Quality of Service Guarantees

Failure detectors characterized by probabilistic guarantees rather than deterministic correctness.

**Completeness**: Eventually suspects every crashed process. Strong completeness: every non-faulty process eventually suspects crashed process. Weak completeness: at least one non-faulty process suspects crashed process.

**Accuracy**: Minimizes false suspicions of correct processes. Strong accuracy: no correct process ever suspected. Weak accuracy: some correct process never suspected. Eventual weak accuracy: after stabilization period, some correct process never suspected.

No failure detector achieves strong completeness and strong accuracy in asynchronous systems (FLP impossibility). Practical detectors target eventual weak accuracy with tunable false positive rates.

**Detection Latency**: Time from actual failure to suspicion. Depends on heartbeat interval, timeout configuration, and gossip propagation speed.

**Mistake Recurrence**: Rate at which previously corrected false positives recur. High recurrence indicates systemic issues (network instability, GC pauses, resource contention).

### Network Partition Considerations

Asymmetric reachability patterns complicate failure detection. Node _A_ may successfully communicate with _B_, while _B_ cannot reach _A_.

**Partition Detection**: Requires consensus-based quorum mechanisms or external coordination service. Nodes in minority partition typically self-fence to prevent split-brain.

**Gray Failures**: Partial failures where node remains reachable but exhibits degraded performance (high latency, packet loss, CPU saturation). Traditional heartbeat-based detection may not trigger. Requires application-level health checks and performance monitoring.

**Coordinated Omission**: Failed node's requests queue behind alive but slow nodes, masking failure. Load balancer or client-side timeout detection required in addition to server-side heartbeat monitoring.

### Implementation Considerations

**Clock Synchronization**: Timeout-based detection sensitive to clock drift and skew. NTP synchronization typically sufficient for coarse-grained detection (second-scale timeouts). Precision timing requires PTP, GPS, or atomic clocks.

**GC Pauses**: Stop-the-world garbage collection pauses trigger false positives in heartbeat detection. JVM tuning (G1GC, ZGC, Shenandoah), GC-aware timeout extensions, or alternative runtime environments (Go, Rust) mitigate issue.

**Thread Starvation**: Heartbeat sender thread starvation due to thread pool exhaustion, lock contention, or CPU saturation causes false positives. Dedicated high-priority heartbeat threads, separate thread pools, and resource isolation necessary.

**Network Congestion**: Congestion-induced packet loss and latency spikes cause cascading false positives. TCP backpressure, explicit congestion notification (ECN), or UDP-based heartbeats with application-level reliability reduce sensitivity.

**Operational Metrics**: Monitor heartbeat inter-arrival time distributions, timeout expiry rates, false positive rates, detection latency histograms, and recovery success rates. Alert on anomalous patterns indicating configuration drift or systemic degradation.

### Related Topics

- Consensus protocols (Paxos, Raft, Multi-Paxos)
- Distributed coordination services (ZooKeeper, etcd, Consul)
- Split-brain scenarios and quorum systems
- Membership protocols and group communication
- Lease mechanisms and time-bounded coordination
- Byzantine failure detection
- Health checking and liveness probes in orchestration systems
- Circuit breakers and adaptive retry policies

---

