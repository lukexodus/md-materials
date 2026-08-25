## TCP Reliability Mechanisms


TCP ensures reliable data delivery through comprehensive error detection, retransmission, and ordering mechanisms that guarantee complete and correct data transfer.

### Error Detection and Correction

**Checksum Verification:**

- 16-bit checksum covers TCP header and data
- Computed using one's complement arithmetic
- Includes pseudo-header with IP addresses
- Detects corruption during transmission

**Sequence Number System:**

- Each byte assigned unique sequence number
- Initial sequence numbers chosen randomly
- Enables detection of missing or duplicate data
- Supports proper data ordering at receiver

**Acknowledgment Mechanisms:**

- Cumulative acknowledgments confirm received data
- ACK number indicates next expected sequence number
- Selective acknowledgments identify specific missing segments
- Duplicate ACKs signal potential segment loss

### Retransmission Strategies

**Timeout-Based Retransmission:**

- Retransmission Timer Optimization (RTO) calculation
- Smoothed round-trip time (SRTT) estimation
- Round-trip time variation (RTTVAR) measurement
- Exponential backoff for successive timeouts

**Fast Retransmit Mechanism:**

- Three duplicate ACKs trigger immediate retransmission
- Avoids waiting for retransmission timeout
- Significantly reduces recovery time for single losses
- Works with fast recovery for continued transmission

**Selective Acknowledgment (SACK):**

- Receiver reports multiple missing segments
- Sender retransmits only missing data
- Reduces unnecessary retransmissions
- Improves performance with multiple losses

### Data Ordering and Duplication Handling

**Segment Reordering:**

- Receiver buffers out-of-order segments
- Sequence numbers enable proper reconstruction
- Duplicate segments discarded automatically
- In-order delivery guaranteed to application

**Buffer Management:**

- Receive buffer stores out-of-order segments
- Send buffer retains unacknowledged segments
- Buffer overflow triggers flow control mechanisms
- Memory management prevents resource exhaustion

