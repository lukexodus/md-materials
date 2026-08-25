## Transport Layer Functions


The Transport Layer (Layer 4) ensures reliable, end-to-end data delivery between applications running on different hosts. This layer provides error recovery, flow control, and multiplexing services that are transparent to higher layers.

**Essential services:**

- **Segmentation and reassembly**: Breaking application data into manageable segments
- **End-to-end reliability**: Ensuring data arrives complete and in correct order
- **Flow control**: Preventing fast senders from overwhelming slow receivers
- **Error detection and recovery**: Identifying and correcting transmission errors
- **Multiplexing**: Enabling multiple applications to use network services simultaneously
- **Connection management**: Establishing, maintaining, and terminating connections

**Connection types:**

- **Connection-oriented**: Reliable service with guaranteed delivery (TCP)
- **Connectionless**: Faster service without delivery guarantees (UDP)

**Key protocols:**

- **Transmission Control Protocol (TCP)**: Provides reliable, ordered, error-checked delivery
- **User Datagram Protocol (UDP)**: Offers faster, lightweight communication without reliability guarantees
- **Stream Control Transmission Protocol (SCTP)**: Combines features of TCP and UDP

**Examples** of Transport Layer implementations include TCP connections for web browsing and email, UDP for DNS queries and video streaming, and port numbers for application identification (HTTP uses port 80, HTTPS uses port 443).

