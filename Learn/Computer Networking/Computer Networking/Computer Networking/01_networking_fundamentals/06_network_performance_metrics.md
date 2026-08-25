## Network Performance Metrics


### Bandwidth

The maximum theoretical data transfer capacity of a network connection, measured in bits per second (bps).

**Key points:**

- Represents the "width" of the data pipeline
- Common units: Kbps, Mbps, Gbps
- Theoretical maximum, not actual throughput
- Shared among all users on the connection
- Higher bandwidth allows more simultaneous data transmission

### Latency

The time delay between sending and receiving data, measured in milliseconds (ms).

**Components of latency:**

- Propagation delay: Time for signal to travel physical distance
	- Propagation delay is the time required for a signal to physically travel from the sender to the receiver through the transmission medium, such as fiber optics, copper cables, or wireless channels. This delay depends on the distance between the two endpoints and the propagation speed of the medium, typically close to the speed of light in fiber optics. For example, even though fiber optic communication is extremely fast, signals traveling across continents still experience noticeable propagation delays due to vast distances.
- Transmission delay: Time to push all bits onto the link
	- Transmission delay, on the other hand, refers to the time taken to push all bits of a data packet onto the transmission link. It depends on the size of the packet and the bandwidth of the link. For instance, transmitting a large file on a low-bandwidth connection results in higher transmission delay compared to a high-speed connection. This delay reflects the data rate limitations of the communication medium.
	- $\text{Transmission Delay} = \frac{\text{Packet Size (bits)}}{\text{Link Bandwidth (bits/sec)}}$
- Processing delay: Time for routers/switches to process packets
	- Processing delay is introduced at network devices such as routers and switches, where the packet headers are examined, forwarding decisions are made, and sometimes additional functions like error checking or encryption are performed. Although these delays are usually small in modern high-speed devices, they can accumulate in complex network topologies with many intermediate nodes.
- Queuing delay: Time packets wait in router queues
	- Queuing delay occurs when packets wait in the buffer of a router or switch before being transmitted. This typically happens during periods of congestion, where multiple packets compete for the same output link. Queuing delay is variable and can range from negligible to significant depending on the current network load.

**Factors affecting latency:**

- Physical distance
- Network congestion
- Processing overhead
- Number of intermediate devices

### Throughput

The actual amount of data successfully transmitted over a network connection in a given time period.

**Key characteristics:**

- Real-world performance metric
- Always less than or equal to bandwidth
- Affected by network conditions, protocol overhead, and errors
- Varies based on network utilization and conditions
- Measured in actual data transferred per unit time

### Jitter

The variation in latency over time, representing the inconsistency in packet arrival times.

**Characteristics:**

- Measured as standard deviation of latency
- Critical for real-time applications (voice, video)
- Caused by network congestion, routing changes, queuing delays
- Can be mitigated through buffering and Quality of Service (QoS)

**Impact on applications:**

- Voice calls: Causes audio quality degradation
- Video streaming: Results in stuttering or pixelation
- Gaming: Creates inconsistent response times
- Real-time data: Affects synchronization

**Performance relationship:** While high bandwidth and low latency are generally desirable, the relationship between these metrics is complex. A connection can have high bandwidth but high latency (satellite internet) or low bandwidth but low latency (local dial-up connection). Optimal network performance requires balancing all these metrics based on application requirements.

**Important subtopics for deeper understanding:**

- OSI and TCP/IP protocol models
- Network addressing and subnetting
- Routing protocols and algorithms
- Network security fundamentals
- Quality of Service (QoS) mechanisms
- Network monitoring and troubleshooting techniques

---

