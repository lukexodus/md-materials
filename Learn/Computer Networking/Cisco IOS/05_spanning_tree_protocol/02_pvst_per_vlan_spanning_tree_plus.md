## PVST+ (Per-VLAN Spanning Tree Plus)


PVST+ is a Cisco proprietary enhancement to STP that runs a separate spanning tree instance for each VLAN. Standard 802.1D runs a single spanning tree for all VLANs, which cannot load-balance traffic across redundant links—all VLANs use the same blocked/forwarding ports.

**PVST+ Operation**

Each VLAN maintains its own:

- Root bridge election
- Port roles and states
- BPDU exchange (using VLAN-specific BPDUs)
- Convergence timers

This independence allows different root bridges per VLAN, enabling load balancing across redundant links. VLAN 10 traffic might forward through Switch A while VLAN 20 traffic forwards through Switch B, utilizing multiple physical paths simultaneously.

**PVST+ BPDUs**

PVST+ uses:

- **PVST+ BPDUs**: Sent on native VLAN (untagged) for trunk ports, encapsulated in SNAP format with destination MAC 01:00:0C:CC:CC:CD
- **Standard 802.1D BPDUs**: Also sent on native VLAN for backward compatibility

On 802.1Q trunks, PVST+ sends separate BPDUs for each VLAN, tagged with appropriate VLAN IDs.

**Configuration Example**

```
! Configure Switch A as root for VLANs 10, 30
spanning-tree vlan 10,30 priority 24576
spanning-tree vlan 20,40 priority 28672

! Configure Switch B as root for VLANs 20, 40
spanning-tree vlan 10,30 priority 28672
spanning-tree vlan 20,40 priority 24576
```

This configuration creates active/active load balancing where each switch is primary root for half the VLANs.

**Verification Commands**

- `show spanning-tree`: Displays spanning tree status for all VLANs
- `show spanning-tree vlan 10`: Shows VLAN-specific spanning tree details
- `show spanning-tree summary`: Overview of spanning tree mode and VLAN instances
- `show spanning-tree root`: Shows root bridge information for each VLAN
- `show spanning-tree bridge`: Displays local bridge information

**PVST+ Advantages**

- Load balancing across redundant links by using different paths for different VLANs
- Flexibility in root bridge placement per VLAN
- Optimization for VLAN topology and traffic patterns

**PVST+ Disadvantages**

- High CPU and memory utilization with many VLANs (100+ VLANs = 100+ STP instances)
- Increased BPDU traffic on trunk links
- Complexity in large environments
- Cisco proprietary (interoperability limitations with non-Cisco equipment)

