## Network Layer Functions


The Network Layer (Layer 3) manages the routing of data packets across multiple networks, providing path determination and logical addressing. This layer enables communication between devices on different network segments and handles the complexities of internetworking.

**Primary responsibilities:**

- **Logical addressing**: Assigning and managing IP addresses for global identification
- **Routing**: Determining optimal paths for data packets across networks
- **Packet forwarding**: Moving packets from source to destination through intermediate nodes
- **Fragmentation and reassembly**: Breaking large packets into smaller units when necessary
- **Congestion control**: Managing network traffic to prevent overload
- **Quality of Service (QoS)**: Prioritizing different types of network traffic

**Routing mechanisms:**

- **Static routing**: Manually configured routes that don't change automatically
- **Dynamic routing**: Protocols that automatically adapt to network changes (RIP, OSPF, BGP)
- **Distance vector algorithms**: Routing decisions based on hop count or distance metrics
- **Link-state algorithms**: Routing based on complete network topology information

**Examples** of Network Layer protocols include Internet Protocol version 4 (IPv4), Internet Protocol version 6 (IPv6), Internet Control Message Protocol (ICMP), and various routing protocols. Routers operate at this layer, maintaining routing tables and making forwarding decisions based on destination IP addresses.

