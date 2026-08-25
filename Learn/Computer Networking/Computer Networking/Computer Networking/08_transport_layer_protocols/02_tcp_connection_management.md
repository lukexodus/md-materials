## TCP Connection Management


Transmission Control Protocol (TCP) implements sophisticated connection management to establish, maintain, and terminate reliable communication sessions between applications.

### Connection Establishment

The TCP three-way handshake creates a reliable connection between client and server endpoints while synchronizing sequence numbers and negotiating connection parameters.

**Three-Way Handshake Process:**

**Step 1 - SYN Segment:**

- Client sends SYN segment with initial sequence number (ISN)
- SYN flag set to 1 indicates connection request
- Client transitions to SYN-SENT state
- MSS option advertises maximum segment size capability

**Step 2 - SYN-ACK Segment:**

- Server responds with SYN-ACK segment
- ACK field acknowledges client's sequence number (ISN + 1)
- SYN flag indicates server's initial sequence number
- Server transitions to SYN-RECEIVED state
- Window size advertises initial receive buffer capacity

**Step 3 - ACK Segment:**

- Client sends ACK segment confirming server's sequence number
- Both endpoints transition to ESTABLISHED state
- Connection is ready for bidirectional data transfer
- Optional data payload may accompany final ACK

**Parameter Negotiation:**

- Maximum Segment Size (MSS) determines largest data payload
- Window scaling factor enables windows larger than 65,536 bytes
- Timestamp option supports round-trip time measurement
- Selective acknowledgment (SACK) capability negotiation

### Connection States and Transitions

TCP maintains connection state through a finite state machine that tracks the current phase of the connection lifecycle.

**Primary Connection States:**

**LISTEN:** Server waits for incoming connection requests **SYN-SENT:** Client has sent SYN and waits for SYN-ACK **SYN-RECEIVED:** Server has received SYN and sent SYN-ACK **ESTABLISHED:** Connection is active and ready for data transfer **FIN-WAIT-1:** Local application has closed; waiting for remote FIN **FIN-WAIT-2:** Remote ACK received; waiting for remote FIN **CLOSE-WAIT:** Remote has closed; waiting for local application close **CLOSING:** Both sides have sent FIN; waiting for final ACK **LAST-ACK:** Waiting for final ACK after sending FIN **TIME-WAIT:** Connection closed; waiting for network to clear old segments **CLOSED:** No connection exists

### Connection Termination

TCP connection termination uses a four-way handshake to ensure both applications have finished sending data and all segments have been properly acknowledged.

**Graceful Termination Process:**

**Step 1:** Application calls close(), TCP sends FIN segment **Step 2:** Remote TCP acknowledges FIN with ACK segment  
**Step 3:** Remote application closes, TCP sends FIN segment **Step 4:** Original TCP acknowledges final FIN with ACK segment

**TIME-WAIT State Purpose:**

- Ensures final ACK reaches the remote endpoint
- Prevents old segments from interfering with new connections
- Duration is twice the Maximum Segment Lifetime (2MSL)
- Typical values range from 30 seconds to 4 minutes

**Simultaneous Close Scenario:**

- Both applications close simultaneously
- Both endpoints send FIN segments
- Each FIN is acknowledged separately
- Connection transitions through CLOSING state

