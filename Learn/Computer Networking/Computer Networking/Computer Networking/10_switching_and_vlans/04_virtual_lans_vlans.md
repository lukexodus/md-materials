## Virtual LANs (VLANs)


Virtual LANs segment a physical network into multiple logical networks, providing broadcast domain separation, security enhancement, and administrative flexibility without requiring separate physical infrastructure.

**VLAN fundamental concepts:**

- **Logical segmentation**: Create separate broadcast domains within single physical switch
- **Port-based assignment**: Assign switch ports to specific VLANs
- **Traffic isolation**: Prevent direct communication between different VLANs
- **Broadcast containment**: Limit broadcast traffic to VLAN boundaries
- **Administrative flexibility**: Reconfigure network topology through software

**VLAN identification methods:**

- **Port-based VLANs**: Static assignment of switch ports to VLANs
- **MAC-based VLANs**: Dynamic assignment based on device MAC addresses
- **Protocol-based VLANs**: Assignment based on network protocol type
- **Authentication-based VLANs**: Dynamic assignment following user authentication
- **Time-based VLANs**: Temporary VLAN assignments with expiration

**IEEE 802.1Q standard:**

- **Frame tagging**: Insert 4-byte VLAN tag into Ethernet header
- **VLAN ID**: 12-bit field supporting 4,094 unique VLANs (0 and 4095 reserved)
- **Priority field**: 3-bit Class of Service (CoS) for traffic prioritization
- **Canonical Format Indicator (CFI)**: Token Ring compatibility bit
- **EtherType modification**: Change from 0x0800 to 0x8100 for tagged frames

**VLAN tag structure:**

- **Tag Protocol Identifier (TPID)**: 0x8100 indicating 802.1Q tag
- **Priority Code Point (PCP)**: 3 bits for traffic priority
- **Drop Eligible Indicator (DEI)**: 1 bit for congestion management
- **VLAN Identifier (VID)**: 12 bits for VLAN number

**VLAN types and purposes:**

- **Data VLANs**: User traffic separation and security
- **Voice VLANs**: Quality of Service for IP telephony
- **Management VLANs**: Administrative access and control traffic
- **Native VLANs**: Untagged traffic on trunk ports
- **Default VLANs**: Initial VLAN assignment for unconfigured ports

**VLAN implementation considerations:**

- **VLAN planning**: Logical design matching organizational structure
- **Numbering schemes**: Consistent VLAN ID allocation across network
- **Security policies**: Inter-VLAN communication restrictions
- **Performance impact**: [Inference] Additional processing overhead for VLAN tagging and switching
- **Scalability limits**: Switch hardware limitations on concurrent VLANs

**Benefits of VLAN deployment:**

- **Security enhancement**: Traffic isolation between user groups
- **Broadcast control**: Reduced broadcast domains improve performance
- **Flexibility**: Logical moves without physical recabling
- **Cost reduction**: Efficient utilization of existing infrastructure
- **Administrative simplification**: Centralized policy management

