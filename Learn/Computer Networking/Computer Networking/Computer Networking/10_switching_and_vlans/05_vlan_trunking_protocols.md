## VLAN Trunking Protocols


VLAN trunking enables multiple VLANs to traverse single physical links between switches, maximizing infrastructure utilization while maintaining VLAN separation and integrity.

**Trunking fundamentals:**

- **Trunk links**: Carry traffic for multiple VLANs simultaneously
- **Frame tagging**: Identify VLAN membership as frames traverse trunk
- **Native VLAN**: Untagged traffic handling on trunk ports
- **Administrative modes**: Control trunk establishment and operation
- **Load balancing**: Distribute VLANs across multiple trunk links

**IEEE 802.1Q trunking:**

- **Industry standard**: Vendor-neutral VLAN trunking protocol
- **Frame modification**: Insert/remove VLAN tags as frames traverse trunk
- **Native VLAN concept**: Untagged frames belong to native VLAN
- **Maximum transmission unit**: 4 additional bytes may cause MTU issues
- **Interoperability**: Works between different vendor equipment

**Dynamic Trunking Protocol (DTP):**

- **Cisco proprietary**: Automatic trunk negotiation between Cisco switches
- **Trunk modes**: Dynamic auto, dynamic desirable, trunk, access, nonegotiate
- **Negotiation process**: Exchange DTP frames to establish trunk status
- **Security considerations**: Potential vulnerability to trunk manipulation attacks
- **Best practices**: Manual trunk configuration preferred over DTP automation

**Trunk configuration modes:**

- **Access mode**: Port belongs to single VLAN, no trunking
- **Trunk mode**: Port configured as trunk, carries multiple VLANs
- **Dynamic auto**: Becomes trunk only if neighbor actively negotiates
- **Dynamic desirable**: Actively attempts to establish trunk
- **Nonegotiate**: Static configuration without DTP negotiation

**VLAN Trunking Protocol (VTP):**

- **Cisco proprietary**: Synchronizes VLAN configuration across switches
- **VTP modes**: Server, client, transparent, off
- **Configuration revision**: Version control for VLAN database changes
- **Domain concept**: Switches must share same VTP domain name
- **Pruning**: Removes unnecessary VLAN traffic from trunk links

**VTP operational modes:**

- **Server mode**: Create, modify, delete VLANs; synchronize with other switches
- **Client mode**: Receive VLAN configuration from servers; cannot modify
- **Transparent mode**: Forward VTP advertisements without processing
- **Off mode**: No VTP processing or advertisement forwarding

**VTP security risks:**

- **Configuration overwrite**: Higher revision number can overwrite VLAN database
- **Accidental synchronization**: New switch introduction can disrupt network
- **Domain hijacking**: Unauthorized access to VTP domain
- **Mitigation strategies**: VTP passwords, careful switch introduction procedures

**Trunk security considerations:**

- **VLAN hopping**: Attacks exploiting trunk configuration vulnerabilities
- **Double tagging**: Malicious use of native VLAN and 802.1Q tagging
- **DTP manipulation**: Unauthorized trunk establishment
- **Access control**: Restrict trunk ports to authorized network devices

**Examples** of trunk implementations:

- **Switch-to-switch**: Inter-switch connectivity carrying all VLANs
- **Switch-to-router**: Router-on-a-stick configuration for inter-VLAN routing
- **Switch-to-server**: Server access to multiple VLANs simultaneously
- **Wireless access points**: VLAN distribution to wireless networks

