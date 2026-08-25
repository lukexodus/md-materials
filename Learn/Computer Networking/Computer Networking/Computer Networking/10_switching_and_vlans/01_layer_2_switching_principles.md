## Layer 2 Switching Principles


Layer 2 switching operates at the Data Link Layer of the OSI model, making forwarding decisions based on MAC addresses contained in Ethernet frames. Unlike hubs that simply repeat signals, switches create separate collision domains for each port while maintaining a single broadcast domain.

**Fundamental switching concepts:**

- **Frame switching**: Examines destination MAC address to determine output port
- **Collision domain separation**: Each switch port represents an independent collision domain
- **Full-duplex operation**: Simultaneous transmission and reception on each port
- **Hardware-based forwarding**: Application-Specific Integrated Circuits (ASICs) enable wire-speed processing
- **Buffer management**: Temporary frame storage during congestion or speed mismatches

**Switching methods:**

- **Store-and-forward**: Complete frame reception and error checking before forwarding
- **Cut-through**: Forward frame immediately after reading destination MAC address
- **Fragment-free**: Forward after receiving first 64 bytes to avoid collision fragments

**Switch architecture components:**

- **Switching fabric**: Internal mechanism connecting all ports
- **Port processors**: Individual port control and buffer management
- **Control plane**: CPU managing protocols, configuration, and management
- **Data plane**: Hardware-based frame forwarding mechanisms
- **Management plane**: Administrative access and monitoring capabilities

**Performance characteristics:**

- **Switching capacity**: Total throughput across all ports simultaneously
- **Forwarding rate**: Packets per second processing capability
- **Latency**: Delay introduced by switching process
- **Buffer depth**: Frame storage capacity during congestion

**Key advantages over shared media:**

- **Dedicated bandwidth**: Each port receives full link capacity
- **Collision elimination**: Full-duplex operation prevents collisions
- **Scalability**: Additional ports without performance degradation
- **Security enhancement**: Traffic isolation between ports
- **Quality of Service**: Traffic prioritization and flow control capabilities

