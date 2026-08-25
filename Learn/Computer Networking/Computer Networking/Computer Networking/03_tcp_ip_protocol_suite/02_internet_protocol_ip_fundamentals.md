## Internet Protocol (IP) Fundamentals


IP operates as the primary network layer protocol, providing connectionless packet delivery across networks. IPv4 uses 32-bit addresses, supporting approximately 4.3 billion unique addresses, while IPv6 extends this to 128-bit addresses for virtually unlimited addressing capacity.

IP packets are the fundamental units of data transmission at the network layer, and each packet contains a **header** and a **payload**. The header holds essential control information, including the **source and destination IP addresses**, which identify where the packet is coming from and where it is going. It also contains the **time-to-live (TTL)** field, which prevents packets from circulating endlessly by decreasing its value each time the packet passes through a router. The **protocol identifier** specifies which higher-layer protocol (such as TCP, UDP, or ICMP) the packet should be delivered to, while the **header checksum** provides a mechanism for detecting errors in the header itself during transmission. Together, these fields ensure that packets can be correctly routed and processed across networks.

Another important aspect of IP packet handling is **fragmentation**. Each network link has a limit on the maximum size of data it can carry, known as the **Maximum Transmission Unit (MTU)**. If a packet is larger than the MTU of a given link, a router will split it into smaller fragments. Each fragment is transmitted independently and includes information in its header that allows the destination host to correctly **reassemble the original packet**. While fragmentation allows large packets to travel across networks with smaller MTUs, it also adds processing overhead and potential inefficiency, which is why techniques like **Path MTU Discovery (PMTUD)** are often used to avoid fragmentation when possible.

**Path MTU Discovery (PMTUD)** is a technique used in computer networking to determine the **maximum transmission unit (MTU)** size that can be sent across a path between two endpoints without requiring fragmentation. Since each network link has its own MTU (the largest packet size it can handle), sending packets larger than the smallest MTU on the path would normally cause routers to fragment them. However, fragmentation introduces extra overhead, increases latency, and can reduce efficiency. PMTUD avoids this by dynamically finding the largest packet size that can traverse the entire path without fragmentation.

The process of PMTUD works by sending packets with the **"Don’t Fragment (DF)" flag** set in the IP header. If a router along the path encounters a packet larger than its link’s MTU, it drops the packet and returns an **ICMP "Fragmentation Needed"** (for IPv4) or **ICMPv6 "Packet Too Big"** message to the sender. The sender then reduces the packet size and retries until it finds the largest size that successfully reaches the destination. This discovered size becomes the effective MTU for communication between the two endpoints.

In **IPv4**, fragmentation can still occur if PMTUD is not used, but in **IPv6**, routers are not allowed to fragment packets at all—only the sending host can perform fragmentation. This makes PMTUD even more important in IPv6 networks, as it ensures efficient packet delivery without loss.

Routing tables determine packet forwarding decisions, using longest prefix matching to select optimal paths. Default gateways handle packets destined for remote networks, while subnet masks define network boundaries for local delivery.

**Key Points:**

- Connectionless service provides no delivery guarantees
- Packet fragmentation enables transmission across diverse network types
- Routing decisions occur at each hop independently
- IPv6 adoption addresses address exhaustion and security concerns

