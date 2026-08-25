## Socket Programming Interfaces


Socket programming provides application programming interfaces (APIs) that enable developers to create network applications using transport layer services.

### Socket Types and Creation

**TCP Sockets (SOCK_STREAM):**

- Reliable, connection-oriented communication
- Byte stream interface without message boundaries
- Automatic error detection and retransmission
- Flow control and congestion management included

**UDP Sockets (SOCK_DGRAM):**

- Unreliable, connectionless communication
- Message-oriented interface with datagram boundaries
- No automatic error recovery or flow control
- Lower overhead and latency characteristics

**Socket Creation Process:**

```
socket() - Create new socket descriptor
bind() - Associate socket with local address/port
listen() - Mark socket as passive (servers only)
accept() - Accept incoming connections (servers)
connect() - Establish connection (clients)
```

### TCP Socket Programming Model

**Server Implementation Pattern:**

1. Create socket with socket() system call
2. Bind socket to specific address and port
3. Listen for incoming connections with specified backlog
4. Accept connections in loop, typically creating child processes
5. Read/write data using established connection
6. Close connection and socket when finished

**Client Implementation Pattern:**

1. Create socket using socket() system call
2. Connect to server using destination address and port
3. Send and receive data using read/write operations
4. Close socket to terminate connection

**Blocking vs Non-Blocking Operations:**

- Blocking calls wait until operation completes
- Non-blocking calls return immediately with status indication
- Select() and poll() enable monitoring multiple sockets
- Asynchronous I/O models support high-concurrency servers

### UDP Socket Programming Model

**Datagram Communication:**

- sendto() specifies destination address for each message
- recvfrom() returns sender address with received data
- No connection establishment required
- Each datagram handled independently

**Broadcast and Multicast Support:**

- SO_BROADCAST socket option enables broadcast transmission
- Multicast group membership managed through socket options
- Time-to-live (TTL) controls multicast propagation scope
- Platform-specific interfaces for advanced multicast features

### Socket Options and Configuration

**Common Socket Options:**

- SO_REUSEADDR allows rapid server restart
- SO_KEEPALIVE enables TCP keepalive probes
- SO_RCVBUF and SO_SNDBUF control buffer sizes
- TCP_NODELAY disables Nagle algorithm

**Advanced Configuration:**

- Socket timeouts for blocking operations
- Buffer size optimization for performance
- Quality of service (QoS) marking options
- Platform-specific performance tuning parameters

