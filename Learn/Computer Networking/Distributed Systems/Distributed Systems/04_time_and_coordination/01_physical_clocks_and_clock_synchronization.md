## Physical Clocks and Clock Synchronization


### Clock Drift and Skew

Physical clocks in distributed systems diverge due to hardware imperfections in oscillator crystals. Clock drift refers to the rate at which a clock deviates from real time—typical quartz oscillators drift 10^-6 to 10^-5 seconds per second (1-10 ppm). Clock skew denotes the instantaneous difference between two clocks at a given moment.

Drift accumulates over time. A clock with 10 ppm drift deviates approximately 1 second per day, 6 seconds per week, or 5 minutes per year. Temperature variations, voltage fluctuations, and crystal aging accelerate drift. Enterprise-grade oscillators (TCXO, OCXO) reduce drift to 0.1-1 ppm but increase cost significantly.

Unbounded clock skew violates causality assumptions in distributed protocols. Events ordered by local timestamps may appear out-of-order globally. Transactions relying on timestamp ordering (serializable snapshot isolation, distributed deadlock detection) require bounded skew guarantees.

### Network Time Protocol (NTP)

NTP synchronizes clocks across networks using hierarchical time source architecture. Stratum levels define distance from authoritative time sources:

- **Stratum 0**: Atomic clocks, GPS receivers—reference time sources
- **Stratum 1**: Directly connected to stratum 0 via PPS (pulse-per-second) signals
- **Stratum 2-15**: Synchronized via network to lower stratum servers
- **Stratum 16**: Unsynchronized

NTP clients query multiple stratum servers, measure round-trip delays, estimate offset and jitter, and select best time source using intersection and clustering algorithms.

**Offset Calculation**: Client sends request at local time T1, server receives at T2, responds at T3, client receives at T4. Round-trip delay: δ = (T4 - T1) - (T3 - T2). Clock offset: θ = ((T2 - T1) + (T3 - T4)) / 2. Assumes symmetric network delays—asymmetric paths introduce error.

**Clock Discipline**: NTP adjusts clock gradually using Phase-Locked Loop (PLL) or Frequency-Locked Loop (FLL) algorithms. Avoids stepping clock backward (breaks monotonicity guarantees). Large offsets (>128 ms) trigger panic mode—clock stepped immediately or daemon refuses to synchronize.

**Accuracy**: Internet NTP achieves 1-50 ms accuracy depending on network conditions. Local network NTP (stratum 2-3) achieves 1-10 ms. GPS-disciplined stratum 1 servers achieve sub-millisecond accuracy.

**Limitations**: NTP vulnerable to network asymmetry, congestion, and Byzantine failures (compromised time servers). Does not provide authenticated time—NTP authentication (Autokey) rarely deployed. Precision Time Protocol (PTP) required for microsecond-level synchronization.

### Precision Time Protocol (PTP / IEEE 1588)

PTP achieves sub-microsecond clock synchronization on local networks using hardware timestamping in network interface cards and switches. Eliminates software and kernel latency from timestamp measurement.

**Architecture**: One node elected as grandmaster clock (best clock algorithm based on accuracy class, priority). Boundary clocks in network switches forward timing messages with residence time corrections. Transparent clocks update timing messages with link delays.

**Message Exchange**:

1. Grandmaster sends Sync message with departure timestamp T1
2. Slave records arrival timestamp T2
3. Grandmaster sends Follow_Up message containing T1
4. Slave sends Delay_Req message at T3
5. Grandmaster receives at T4, responds with Delay_Resp containing T4

Slave calculates offset: θ = ((T2 - T1) - (T4 - T3)) / 2. Path delay: δ = ((T2 - T1) + (T4 - T3)) / 2.

**Hardware Timestamping**: NIC timestamps packets at PHY layer, bypassing kernel and software stack. Reduces jitter from 1 ms (software timestamps) to <1 μs (hardware timestamps). Requires PTP-capable NICs and switches.

**Accuracy**: Local network PTP with hardware timestamping achieves 10-100 ns synchronization. Software-only PTP degrades to 1-10 μs. Wide-area PTP (telecom networks) achieves 1 μs with carefully engineered paths.

**Deployment Constraints**: Requires hardware support across network path. Asymmetric routing, layer-3 boundaries, and WAN links degrade accuracy. Best effort PTP (without hardware support) insufficient for high-precision requirements.

### GPS and GNSS Time Synchronization

GPS satellites broadcast atomic clock signals referenced to UTC. GPS receivers compute position and time by trilateration from multiple satellites. Each satellite transmits:

- Precise ephemeris (orbital parameters)
- Satellite clock correction
- Ionospheric propagation model
- Time-of-week and week number

**Timing Accuracy**: GPS receivers with clear sky visibility achieve 10-50 ns accuracy relative to UTC(USNO). Requires fixed antenna position and visibility to 4+ satellites. Indoor or obstructed locations degrade to microsecond accuracy or lose lock entirely.

**GNSS Diversity**: Multiple global navigation satellite systems provide redundancy: GPS (US), GLONASS (Russia), Galileo (EU), BeiDou (China). Multi-GNSS receivers improve availability and accuracy by combining signals.

**Holdover**: GPS receivers maintain clock accuracy during signal loss using disciplined oscillators (OCXO, rubidium). High-quality oscillators provide microsecond-level accuracy for hours to days during holdover. Disciplined oscillators learn long-term drift characteristics to improve holdover performance.

**Spoofing and Interference**: GPS signals vulnerable to jamming and spoofing attacks. Military and critical infrastructure use encrypted military GPS signals (P(Y) code) or authenticated civilian signals (Galileo OS-NMA). Commercial receivers implement anti-spoofing detection (consistency checks, signal strength monitoring).

### TrueTime (Google Spanner)

TrueTime API provides interval-based timestamps with bounded uncertainty: TT.now() returns [earliest, latest] where true time guaranteed within interval. Enables linearizable distributed transactions without centralized coordination.

**Architecture**: Each datacenter contains GPS receivers and atomic clocks (cesium or rubidium). Timemasters synchronize via GPS and cross-check atomic clocks. Armageddon masters provide fallback. Regular servers synchronize to multiple timemasters using modified NTP, track worst-case offset.

**Uncertainty Bound**: ε represents maximum clock offset—typically 1-7 ms. Includes GPS receiver uncertainty, network delay variance, and clock drift between synchronizations. Uncertainty increases linearly between synchronizations until next update resets bound.

**Commit Wait**: Transactions commit only after waiting for uncertainty interval to expire: `commit_timestamp + ε < TT.now().earliest`. Ensures all future reads observe committed data. External consistency (linearizability) guaranteed—if transaction T1 commits before T2 starts, T1's commit timestamp < T2's commit timestamp.

**Read Timestamps**: Snapshot reads use TT.now().latest as timestamp—guaranteed to observe all previously committed transactions. Repeatable reads use same timestamp—consistent snapshot across shards.

**Failure Handling**: Loss of GPS increases uncertainty bound. If bound exceeds threshold (typically 10 ms), datacenter stops serving writes to maintain correctness. Reads continue using safe timestamps. Requires redundant time sources and reliable GPS reception.

**Hardware Requirements**: Expensive infrastructure—GPS antennas, atomic clocks, dedicated timemasters. Feasible for large-scale infrastructure providers; prohibitive for smaller deployments. Public cloud providers do not expose TrueTime-equivalent APIs.

### Hybrid Logical Clocks (HLC)

HLCs combine physical clock timestamps with logical counters to provide causality tracking without unbounded logical clock growth. Each event assigned timestamp: `<physical_time, logical_counter>`.

**Update Rules**:

- Local event: `physical = max(physical, wall_clock); logical = (physical == old_physical) ? logical + 1 : 0`
- Receive event with timestamp (pt, lc): `physical = max(physical, wall_clock, pt); logical = (physical == old_physical) ? logical + 1 : (physical == pt) ? lc + 1 : 0`

**Properties**:

- Physical component tracks wall clock time—timestamps remain close to real time (within clock synchronization bound)
- Logical component captures causality—if event A happens-before event B, timestamp(A) < timestamp(B)
- Bounded logical counter—resets to 0 when physical time advances
- Allows approximate time-based queries—recent events have recent physical timestamps

**Comparison to Logical Clocks**: Lamport clocks provide causality but timestamps diverge arbitrarily from real time. Vector clocks track per-process causality but require O(n) space per timestamp. HLCs provide causality with bounded space and timestamps close to physical time.

**Deployment**: CockroachDB, MongoDB, Cassandra use HLC variants for distributed timestamp ordering. Enables time-travel queries, garbage collection based on timestamp age, and conflict resolution with approximate real-time semantics.

### Clock Synchronization Protocols

**Cristian's Algorithm**: Client requests time from time server, server responds with current time. Client sets clock to server_time + estimated_delay/2. Round-trip time measured; high variance discarded. Achieves accuracy within ±(RTT/2 - min_RTT/2). Single server creates SPOF and no Byzantine fault tolerance.

**Berkeley Algorithm**: Coordinator polls all nodes for their clock values, computes average (excluding outliers), sends adjustment deltas to each node. Eliminates single time server but coordinator remains SPOF. Suitable for closed systems where averaging clocks acceptable.

**Broadcast Synchronization**: Time server broadcasts timestamp periodically. Receivers adjust clocks based on broadcast timestamp plus known transmission delay. Efficient for one-to-many synchronization but assumes symmetric and predictable network delay. Used in datacenter environments with controlled network topology.

### Monotonic Clocks and Clock Corrections

**Monotonic Clock Guarantees**: Monotonic clocks (CLOCK_MONOTONIC) guarantee non-decreasing values—immune to NTP adjustments, leap seconds, or administrator clock changes. Suitable for measuring intervals, timeouts, and relative time. Do not represent wall clock time—cannot compare across reboots or nodes.

**Clock Slewing vs Stepping**: Clock corrections applied via slewing (gradual rate adjustment) or stepping (immediate jump). Slewing preserves monotonicity for small offsets—clock runs faster/slower until synchronized. NTP slews offsets <128 ms at 0.5 ms/s (500 ppm). Large offsets require stepping—breaks monotonicity, may cause duplicate timestamps or negative intervals.

**Leap Second Handling**: UTC includes leap seconds to track Earth rotation. Positive leap second inserts 23:59:60—clock repeats one second. Negative leap second skips 23:59:59—clock jumps forward. Smearing distributes leap second across hours (Google) or days (AWS) to avoid repeated timestamps. Unsmeared leap seconds cause distributed system failures—duplicate timestamps violate uniqueness assumptions in transaction ordering, certificate validation, log sequencing.

### Clock Synchronization Accuracy Requirements

Different distributed system components require varying clock synchronization accuracy:

**Millisecond-level (NTP-class)**:

- Distributed tracing timestamp correlation
- Certificate validity checking
- Kerberos authentication (default 5-minute tolerance)
- Distributed log aggregation and time-series correlation
- Cache expiration and TTL enforcement

**Sub-millisecond (PTP-class or GPS-disciplined)**:

- High-frequency trading timestamp ordering
- Financial transaction ordering and compliance (MiFID II requires 100 μs)
- Serializable distributed transactions without central coordination
- Precisely timestamped sensor data correlation
- Phase-aligned distributed signal processing

**Relaxed (seconds to minutes)**:

- File synchronization timestamps
- Scheduled task execution
- Non-critical monitoring and alerting
- Approximate time-to-live enforcement

Overengineering clock synchronization increases cost and operational complexity. Match synchronization precision to actual system requirements, not theoretical maximum precision.

### Failure Modes and Operational Challenges

**GPS Outages**: Jamming, spoofing, or antenna failure loses GPS signal. Holdover oscillators maintain accuracy temporarily. Prolonged outage degrades accuracy—cesium clocks drift ~10^-12 (1 μs per day), rubidium ~10^-11 (10 μs per day), OCXO ~10^-9 (1 ms per day). Systems must detect GPS loss and increase uncertainty bounds or stop serving writes.

**Network Asymmetry**: Forward and return path delays differ—violates symmetric delay assumption in NTP/PTP offset calculation. Congestion, asymmetric routing, or load balancer hashing causes variable asymmetry. Measurement noise requires filtering (outlier rejection, statistical estimation).

**Byzantine Time Sources**: Compromised or misconfigured time servers provide incorrect time. NTP clients should query multiple independent servers (different networks, geographic locations). TrueTime cross-checks GPS and atomic clocks. PTP best master clock algorithm selects most accurate source based on accuracy class.

**Clock Panic**: NTP detects offset exceeding panic threshold (default 1000s) and refuses synchronization—requires manual intervention. Prevents propagating grossly incorrect time but leaves system unsynchronized. Datacenter commissioning or extended downtime triggers panic—requires pre-synchronized clocks or panic threshold tuning.

**Leap Second Glitches**: Applications using non-monotonic clocks may encounter repeated timestamps during positive leap second. Systems must handle duplicate timestamps gracefully (tie-breaking with sequence numbers, deduplication). Leap second smearing avoids issue but introduces small time offset relative to UTC.

**Cross-Region Synchronization**: Wide-area clock synchronization faces higher network delay variance and asymmetry. TrueTime requires GPS and atomic clocks in each region. PTP over WAN requires carrier-grade infrastructure. NTP over Internet achieves tens of milliseconds—insufficient for tight consistency requirements.

### Related Topics

- Lamport Logical Clocks
- Vector Clocks
- Hybrid Logical Clocks (HLC)
- Linearizability and External Consistency
- Snapshot Isolation and Serializable Snapshot Isolation
- Two-Phase Commit (2PC) and Distributed Transactions
- Consensus Protocols (Paxos, Raft)
- Time-to-Live (TTL) and Lease Mechanisms
- Distributed Deadlock Detection
- Causal Consistency

---

