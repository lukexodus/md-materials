## Inter-VLAN Routing


Inter-VLAN routing enables communication between different VLANs by providing Layer 3 routing services, typically implemented through dedicated routers, Layer 3 switches, or router-on-a-stick configurations.

**Inter-VLAN routing necessity:**

- **Broadcast domain separation**: VLANs inherently prevent direct communication
- **Layer 3 services**: Routing required for different IP subnets
- **Security control**: Centralized policy enforcement for inter-VLAN traffic
- **Service access**: Shared resources accessible from multiple VLANs

**Implementation methods:**

**External router with multiple interfaces:**

- **Dedicated interfaces**: Separate physical connection per VLAN
- **Configuration simplicity**: Each VLAN maps to router interface
- **Scalability limitations**: Physical port constraints
- **Performance characteristics**: Router processing capacity determines throughput
- **Cost considerations**: Additional hardware and cabling requirements

**Router-on-a-stick:**

- **Single trunk connection**: Router connects via single trunk link to switch
- **Subinterfaces**: Logical interfaces for each VLAN on physical interface
- **802.1Q encapsulation**: Router processes VLAN tags on trunk link
- **Configuration complexity**: Subinterface creation and IP addressing
- **Bandwidth limitations**: Single physical link carries all inter-VLAN traffic

**Layer 3 switch (multilayer switch):**

- **Integrated routing**: Combining switching and routing in single device
- **Switched Virtual Interfaces (SVIs)**: Virtual interfaces for each VLAN
- **Hardware acceleration**: ASIC-based routing for wire-speed performance
- **Port flexibility**: Any port can be Layer 2 switched or Layer 3 routed
- **Management consolidation**: Single device for switching and routing functions

**Switched Virtual Interface configuration:**

- **VLAN interface creation**: Logical interface representing entire VLAN
- **IP address assignment**: Default gateway for VLAN subnet
- **Routing table entries**: Automatic route installation for connected VLANs
- **Administrative control**: Enable/disable routing per VLAN

**Inter-VLAN routing process:**

1. **Frame reception**: Host sends frame to default gateway MAC address
2. **VLAN identification**: Switch identifies source VLAN
3. **Routing decision**: Layer 3 lookup determines destination VLAN
4. **Frame modification**: Change source/destination MAC addresses
5. **VLAN tagging**: Apply appropriate VLAN tag for destination
6. **Frame forwarding**: Send frame on appropriate port/VLAN

**Routing considerations:**

- **Subnet design**: Each VLAN typically corresponds to IP subnet
- **Default gateway**: Router interface serves as VLAN default gateway
- **Routing protocols**: Dynamic routing for complex topologies
- **Access control**: Firewall rules and access lists between VLANs
- **Quality of Service**: Traffic prioritization across VLAN boundaries

**Performance factors:**

- **Processing capacity**: Router/switch CPU and memory resources
- **Interface bandwidth**: Trunk link capacity for router-on-a-stick
- **Switching fabric**: Internal capacity of multilayer switches
- **Buffer management**: Temporary storage during congestion

**Security implications:**

- **Policy enforcement**: Centralized control over inter-VLAN communication
- **Traffic inspection**: Monitoring and filtering between VLANs
- **Access control lists**: Granular permission management
- **Audit capabilities**: Logging inter-VLAN traffic flows

