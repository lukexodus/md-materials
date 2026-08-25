## QoS Fundamentals and Metrics


Quality of Service encompasses several key network performance characteristics that directly impact user experience and application functionality.

**Key Points**

- **Bandwidth**: The maximum rate of data transfer across a given path, typically measured in bits per second (bps)
- **Latency/Delay**: The time required for a packet to travel from source to destination
- **Jitter**: The variation in packet delay, which can cause irregular delivery of data
- **Packet Loss**: The percentage of packets that fail to reach their destination
- **Availability**: The percentage of time a network service remains operational

**Primary QoS Metrics**

_End-to-End Delay_ consists of several components: processing delay (time to examine packet headers), queuing delay (time spent waiting in router buffers), transmission delay (time to push packet bits onto the link), and propagation delay (time for signals to travel across the medium).

_Jitter_ becomes particularly problematic for real-time applications like voice and video, where consistent packet arrival timing is crucial for maintaining quality. Network devices typically implement jitter buffers to smooth out variations in packet arrival times.

_Throughput_ differs from bandwidth in that it represents the actual achieved data transfer rate under real network conditions, accounting for protocol overhead, retransmissions, and congestion.

