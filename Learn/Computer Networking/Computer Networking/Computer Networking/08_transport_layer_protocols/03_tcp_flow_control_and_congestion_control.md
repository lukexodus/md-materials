## TCP Flow Control and Congestion Control


TCP implements sophisticated mechanisms to manage data flow between endpoints and prevent network congestion while maximizing throughput.

### Flow Control Mechanisms

Flow control prevents fast senders from overwhelming slow receivers by regulating the rate of data transmission based on receiver buffer availability.

**Sliding Window Protocol:**

- Receiver advertises available buffer space in window field
- Sender limits outstanding unacknowledged data to window size
- Window size dynamically adjusts based on receiver processing capability
- Zero window advertisements pause transmission until buffer space available

**Window Scaling:**

- Standard TCP window field limited to 65,535 bytes
- Window scaling option enables windows up to 1 GB
- Scaling factor negotiated during connection establishment
- Critical for high-bandwidth, high-delay networks

**Silly Window Syndrome Prevention:**

- Nagle algorithm delays small segment transmission
- Receiver avoids advertising small window updates
- Clark's solution prevents tiny window advertisements
- Delayed ACK algorithm reduces ACK overhead

### Congestion Control Algorithms

TCP congestion control prevents network overload by detecting congestion indicators and adjusting transmission rates accordingly.

**Slow Start Algorithm:**

- Initial congestion window (cwnd) typically 1-4 segments
- cwnd increases by one segment for each ACK received
- Exponential growth continues until threshold reached
- Designed to quickly discover available bandwidth

**Congestion Avoidance:**

- Linear increase phase after slow start threshold
- cwnd increases by 1/cwnd for each ACK received
- Additive increase provides gradual bandwidth probing
- Continues until congestion detected

**Fast Retransmit and Fast Recovery:**

- Three duplicate ACKs indicate segment loss
- Retransmit missing segment immediately
- cwnd reduced by half (multiplicative decrease)
- Continue in congestion avoidance mode

**Congestion Control Variants:**

**TCP Reno:**

- Classic implementation with fast retransmit/recovery
- Single segment loss recovery per round-trip time
- Timeout reduces cwnd to 1 segment

**TCP NewReno:**

- Improved multiple loss recovery
- Partial acknowledgment detection
- Better performance with multiple losses

**TCP SACK (Selective Acknowledgment):**

- Receiver indicates multiple missing segments
- Sender can recover multiple losses efficiently
- Requires SACK option negotiation during connection setup

**TCP Cubic:**

- Cubic function for window growth
- Better performance on high-speed networks
- Default algorithm in Linux systems
- Window growth independent of round-trip time

