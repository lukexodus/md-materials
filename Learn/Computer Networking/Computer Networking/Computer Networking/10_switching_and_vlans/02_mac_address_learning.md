## MAC Address Learning


MAC address learning enables switches to build and maintain forwarding tables that map MAC addresses to specific switch ports. This dynamic learning process eliminates the need for manual configuration while optimizing network traffic flow.

**Learning process mechanics:**

1. **Frame arrival**: Switch receives frame on specific port
2. **Source examination**: Extract source MAC address from frame header
3. **Table lookup**: Check if source MAC exists in forwarding table
4. **Entry creation/update**: Add new entry or refresh existing timestamp
5. **Aging management**: Remove stale entries based on configurable timers

**MAC address table structure:**

- **MAC address**: 48-bit unique identifier (6 bytes in hexadecimal)
- **Port number**: Physical switch port where address was learned
- **VLAN ID**: Virtual LAN association for address
- **Timestamp**: Last activity time for aging purposes
- **Entry type**: Dynamic (learned) or static (manually configured)

**Forwarding decision process:**

- **Known unicast**: Forward to specific port based on table lookup
- **Unknown unicast**: Flood to all ports except receiving port
- **Broadcast frames**: Forward to all ports except receiving port
- **Multicast frames**: Forward based on multicast table or flood if unknown

**Aging mechanisms:**

- **Default aging time**: Typically 300 seconds (5 minutes)
- **Activity refresh**: Reset timer when address appears as source
- **Periodic cleanup**: Remove expired entries to prevent table overflow
- **Manual clearing**: Administrative removal of specific or all entries

**Table management considerations:**

- **Table size limits**: Hardware constraints on maximum entries
- **Learning rate limits**: Protection against MAC flooding attacks
- **Port security**: Restrictions on learned addresses per port
- **Sticky learning**: Permanent retention of learned addresses

**Examples** of MAC learning scenarios:

- **Initial network startup**: Empty tables gradually populated through communication
- **Device movement**: Address migration between ports when devices relocate
- **Network topology changes**: Relearning after spanning tree reconfiguration
- **Security events**: Address table manipulation during attacks

**MAC address table optimization:**

- **Static entries**: Manually configured permanent mappings
- **Port-based learning**: Restrict learning to authorized devices
- **VLAN-aware learning**: Separate tables per VLAN for security
- **Multicast filtering**: Efficient multicast traffic handling

