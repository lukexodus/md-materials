## Network Address Translation (NAT)


NAT modifies IP address information in packet headers while traversing routing devices, enabling private networks to communicate with public networks using fewer public IP addresses.

**NAT types and operations:**

**Static NAT (One-to-One):**

- **Function**: Maps single private address to single public address
- **Configuration**: Manual mapping maintained in NAT table
- **Use cases**: Servers requiring consistent external address
- **Characteristics**: Permanent address relationships

**Dynamic NAT (Many-to-Many):**

- **Function**: Maps private addresses to pool of public addresses
- **Allocation**: First-come, first-served basis from available pool
- **Duration**: Temporary mappings based on usage
- **Limitations**: Requires sufficient public addresses for simultaneous users

**Port Address Translation (PAT/NAT Overload):**

- **Function**: Maps multiple private addresses to single public address using different ports
- **Mechanism**: Combines IP address and port number translation
- **Efficiency**: Supports thousands of internal hosts with one public address
- **Implementation**: Most common NAT variant in residential and small business networks

**NAT translation process:**

1. **Outbound translation**: Replace source private address/port with public address/port
2. **Table maintenance**: Record translation mapping for return traffic
3. **Inbound translation**: Replace destination public address/port with original private address/port
4. **State management**: Maintain connection state and timeout unused mappings

**NAT advantages:**

- **Address conservation**: Reduces public IP address requirements
- **Security enhancement**: Hides internal network structure
- **Cost reduction**: Minimizes IP address acquisition costs
- **Network flexibility**: Enables internal address scheme changes

**NAT limitations and challenges:**

- **End-to-end connectivity**: Breaks some applications requiring direct connections
- **Protocol complications**: Issues with FTP, SIP, H.323, and other protocols
- **Performance impact**: Additional processing overhead for translation
- **Troubleshooting complexity**: Obscures original source addresses
- **Scalability concerns**: Translation table size and processing limitations

**NAT traversal techniques:**

- **Application Layer Gateways (ALG)**: Protocol-specific NAT helpers
- **UPnP**: Automatic port mapping requests
- **STUN**: Session Traversal Utilities for NAT
- **TURN**: Traversal Using Relays around NAT
- **ICE**: Interactive Connectivity Establishment

