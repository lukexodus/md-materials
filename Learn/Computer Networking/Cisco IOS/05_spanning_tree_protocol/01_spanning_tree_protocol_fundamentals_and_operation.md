## Spanning Tree Protocol Fundamentals and Operation


Spanning Tree Protocol (STP) is a Layer 2 network protocol designed to prevent loops in switched Ethernet networks. Network loops occur when multiple physical paths exist between switches, causing broadcast storms, MAC address table instability, and frame duplication. Without loop prevention, a single broadcast frame would circulate indefinitely, consuming all available bandwidth within seconds.

**The Loop Problem**

In a redundant switched network, broadcast frames are flooded out all ports except the incoming port. If multiple paths exist between switches, these frames return to their origin, get flooded again, and multiply exponentially. Simultaneously, switches receive the same frame on different ports with identical source MAC addresses, causing MAC address table thrashing as the switch constantly updates which port leads to that MAC address.

**STP Solution**

STP creates a loop-free logical topology by strategically blocking redundant paths while maintaining physical redundancy. When a link fails, STP recalculates and unblocks alternate paths, restoring connectivity. The protocol operates by having switches exchange Bridge Protocol Data Units (BPDUs) containing information about bridge IDs, path costs, and port roles.

**IEEE Standards**

The original STP is defined in IEEE 802.1D (1990). This standard has evolved through several iterations:

- **802.1D (original)**: Convergence time of 30-50 seconds
- **802.1D-2004**: Incorporated Rapid Spanning Tree Protocol improvements
- **802.1w**: Rapid Spanning Tree Protocol (RSTP) - convergence in 1-3 seconds
- **802.1s**: Multiple Spanning Tree Protocol (MST) - maps multiple VLANs to spanning tree instances

**BPDU Structure**

BPDUs carry STP information between switches. Configuration BPDUs (sent every 2 seconds by default) contain:

- Root Bridge ID (priority + MAC address)
- Root Path Cost (cumulative cost to reach root bridge)
- Sender Bridge ID
- Sender Port ID
- Message Age, Max Age, Hello Time, Forward Delay timers

Topology Change Notification (TCN) BPDUs signal network topology changes to the root bridge.

**STP Algorithm Operation**

STP follows a four-step process:

1. **Elect one root bridge**: All switches in the broadcast domain participate in selecting a single root bridge based on lowest bridge ID.
    
2. **Select root ports**: Each non-root switch selects one root port—the port with the lowest path cost to reach the root bridge.
    
3. **Select designated ports**: For each network segment, one designated port is chosen—the port with the lowest cost path to the root bridge for that segment.
    
4. **Block non-designated ports**: All remaining ports are placed in blocking state to prevent loops.
    

**Bridge ID Components**

The Bridge ID is an 8-byte value combining:

- **Bridge Priority** (2 bytes): Default 32768, configurable in increments of 4096 (values 0-61440)
- **MAC Address** (6 bytes): Lowest MAC address on the switch

In modern implementations (PVST+), the priority field is subdivided:

- 4 bits for priority (0-15, representing 0-61440 in 4096 increments)
- 12 bits for VLAN ID (extended system ID)

The effective priority becomes: (configured priority) + (VLAN ID). For VLAN 10 with priority 32768: 32768 + 10 = 32778.

**Path Cost Calculation**

STP uses cumulative path cost to determine best paths. Port costs are based on bandwidth:

**Original 802.1D Costs:**

- 10 Mbps: 100
- 100 Mbps: 19
- 1 Gbps: 4
- 10 Gbps: 2

**Revised 802.1D-1998 Costs:**

- 10 Mbps: 2,000,000
- 100 Mbps: 200,000
- 1 Gbps: 20,000
- 10 Gbps: 2,000
- 100 Gbps: 200

Cisco switches default to the revised (long) cost method. Path cost accumulates as BPDUs traverse switches—each switch adds its ingress port cost to the received root path cost.

**Tie-Breaking Rules**

When multiple paths have equal cost, STP uses tie-breakers in order:

1. Lowest root bridge ID
2. Lowest root path cost
3. Lowest sender bridge ID
4. Lowest sender port ID
5. Lowest receiver port ID

