## Connection-Oriented vs Connectionless Services


Transport layer protocols implement two fundamental service models that differ in their approach to reliability, ordering, and connection state management.

### Connection-Oriented Services

Connection-oriented protocols establish a formal communication session between endpoints before data exchange begins. This approach provides reliable, ordered delivery with comprehensive error detection and recovery mechanisms.

**Session Establishment Process:**

- Three-way handshake initiates connection state
- Sequence number synchronization ensures proper ordering
- Window size negotiation establishes flow control parameters
- Maximum segment size determination optimizes transmission efficiency

**State Management Requirements:**

- Both endpoints maintain connection state information
- Sequence and acknowledgment numbers track data transmission
- Timer management handles retransmission and connection timeouts
- Resource allocation includes buffer space and control blocks

**Reliability Guarantees:**

- All transmitted data arrives at the destination
- Data arrives in the same order as transmitted
- Duplicate data segments are detected and discarded
- Corrupted segments trigger retransmission mechanisms

**Applications Requiring Connection-Oriented Service:**

- File transfer applications requiring complete data integrity
- Email systems where message loss is unacceptable
- Web browsing where page content must arrive completely
- Database applications requiring transaction consistency

### Connectionless Services

Connectionless protocols treat each data unit independently without establishing formal sessions or maintaining connection state between endpoints.

**Operational Characteristics:**

- No connection establishment or teardown overhead
- Each datagram contains complete addressing information
- No guaranteed delivery or ordering between datagrams
- Minimal protocol overhead and processing requirements

**Performance Advantages:**

- Lower latency for single request-response transactions
- Reduced memory requirements due to minimal state maintenance
- Better scalability for servers handling many clients
- Simpler implementation with fewer failure modes

**Trade-offs and Limitations:**

- Applications must implement reliability mechanisms if needed
- No built-in flow control or congestion management
- Potential for packet duplication, loss, or reordering
- Less suitable for bulk data transfer applications

**Suitable Application Types:**

- Domain Name System (DNS) queries requiring fast responses
- Network management protocols with periodic updates
- Real-time applications where retransmission is impractical
- Broadcast and multicast applications serving multiple recipients

