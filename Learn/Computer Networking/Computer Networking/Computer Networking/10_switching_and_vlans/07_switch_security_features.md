## Switch Security Features


Modern switches incorporate comprehensive security features to protect against various Layer 2 attacks and unauthorized access while maintaining network integrity and performance.

**Port security:**

- **MAC address limiting**: Restrict number of MAC addresses per port
- **Secure MAC learning**: Control which addresses can be learned
- **Violation actions**: Shutdown, restrict, or protect responses to violations
- **Aging mechanisms**: Automatic cleanup of secure addresses
- **Static configuration**: Manually specify allowed MAC addresses

**Port security violation types:**

- **Shutdown**: Disable port when violation occurs (default action)
- **Restrict**: Drop violating frames but keep port operational
- **Protect**: Silently drop violating frames without notification
- **Recovery mechanisms**: Automatic or manual port reactivation

**Dynamic ARP Inspection (DAI):**

- **ARP validation**: Verify ARP packet legitimacy against DHCP snooping table
- **Spoofing prevention**: Block malicious ARP responses
- **Trusted/untrusted ports**: Classify ports based on security requirements
- **Rate limiting**: Prevent ARP flooding attacks
- **Logging capabilities**: Record ARP inspection events

**DHCP snooping:**

- **DHCP validation**: Inspect DHCP messages for legitimacy
- **Rogue server detection**: Prevent unauthorized DHCP servers
- **Binding table**: Maintain IP-to-MAC address mappings
- **Trusted port designation**: Allow DHCP responses only from trusted ports
- **Option 82 support**: Enhanced DHCP relay agent information

**IP Source Guard:**

- **IP address validation**: Verify source IP addresses in packets
- **DHCP snooping integration**: Use binding table for validation
- **Static binding support**: Manual IP-to-MAC address assignment
- **Port-based filtering**: Per-port IP address restrictions

**Storm control:**

- **Traffic rate limiting**: Prevent broadcast, multicast, or unicast storms
- **Threshold configuration**: Percentage or packet-per-second limits
- **Action options**: Shutdown, drop, or trap when thresholds exceeded
- **Recovery mechanisms**: Automatic restoration after storm subsides

**BPDU guard and filter:**

- **BPDU guard**: Shutdown ports receiving unexpected BPDUs
- **BPDU filter**: Drop BPDU frames without processing
- **Edge port protection**: Prevent spanning tree manipulation
- **Network topology preservation**: Maintain intended spanning tree design

**Root guard:**

- **Root bridge protection**: Prevent inferior bridges from becoming root
- **Port blocking**: Block ports that receive superior BPDUs
- **Network stability**: Maintain predictable spanning tree topology
- **Automatic recovery**: Resume normal operation when threat removed

**Private VLANs:**

- **Traffic isolation**: Restrict communication within same VLAN
- **Primary/secondary VLANs**: Hierarchical VLAN structure
- **Port types**: Promiscuous, isolated, and community ports
- **Security enhancement**: Prevent lateral movement within VLANs

**Access control lists (ACLs):**

- **Traffic filtering**: Permit or deny based on various criteria
- **Layer 2 ACLs**: MAC address, EtherType, and VLAN-based filtering
- **Layer 3/4 ACLs**: IP address, protocol, and port-based filtering
- **Time-based ACLs**: Temporary access restrictions
- **Logging and monitoring**: Record filtered traffic events

**802.1X port-based authentication:**

- **User authentication**: Verify user credentials before network access
- **EAP framework**: Extensible Authentication Protocol support
- **RADIUS integration**: Centralized authentication services
- **Dynamic VLAN assignment**: Automatic VLAN placement based on authentication
- **Guest VLAN**: Limited access for unauthenticated users

