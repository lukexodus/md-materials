## Flow Control Mechanisms


Flow control prevents fast senders from overwhelming slower receivers, ensuring reliable data delivery without buffer overflow.

### Stop-and-Wait Flow Control

**Operation:** Sender transmits one frame and waits for receiver acknowledgment before sending the next frame **Advantages:** Simple implementation, prevents receiver overflow **Disadvantages:** Inefficient bandwidth utilization, especially on high-latency links

### Sliding Window Flow Control

**Mechanism:** Receiver advertises available buffer space, sender maintains transmission window of allowable outstanding frames

**Window Management:**

- Window size determines number of unacknowledged frames allowed
- Dynamic window adjustment based on receiver capabilities
- Efficient bandwidth utilization on high-latency connections

**Credit-Based Flow Control:** Receiver explicitly grants transmission credits to sender, providing precise buffer management and preventing overflow conditions.

