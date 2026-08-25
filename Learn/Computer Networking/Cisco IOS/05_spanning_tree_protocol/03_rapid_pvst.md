## Rapid PVST+


Rapid PVST+ combines Rapid Spanning Tree Protocol (RSTP / 802.1w) improvements with Cisco's per-VLAN approach. The primary enhancement is dramatically faster convergence—RSTP converges in 1-3 seconds compared to traditional STP's 30-50 seconds.

**Key RSTP Improvements**

**Enhanced Port Roles**

RSTP defines port roles more explicitly:

- **Root Port**: Best path to root bridge (same as 802.1D)
- **Designated Port**: Best path to root on a segment (same as 802.1D)
- **Alternate Port**: Backup path to root bridge (previously blocking)
- **Backup Port**: Backup path to same segment (previously blocking)
- **Disabled Port**: Administratively shut down

Alternate and backup ports remain in discarding state but can transition to forwarding much faster than 802.1D blocking ports.

**Port States**

RSTP simplifies port states:

- **Discarding**: Combines 802.1D blocking, listening, and disabled states; does not learn MAC addresses or forward frames
- **Learning**: Learns MAC addresses but does not forward frames
- **Forwarding**: Learns MAC addresses and forwards frames

This reduction from five states to three eliminates unnecessary transition delays.

**Proposal/Agreement Mechanism**

RSTP introduces rapid convergence through active negotiation between switches:

1. When a switch connects to a segment, it sends a proposal BPDU suggesting it become the designated switch
2. The receiving switch, if inferior, immediately blocks all non-edge designated ports
3. The receiving switch sends an agreement BPDU
4. The proposing switch immediately transitions its port to forwarding state

This synchronization happens in 1-2 seconds rather than waiting 30 seconds through listening and learning states.

**Edge Ports (PortFast)**

RSTP recognizes edge ports (ports connected to end devices, not switches). Edge ports immediately transition to forwarding state without waiting or sending proposals. If a BPDU is received on an edge port, it immediately loses edge port status and enters normal STP operation.

**Link Types**

RSTP recognizes three link types:

- **Point-to-point**: Full-duplex connections between switches (proposal/agreement works)
- **Shared**: Half-duplex or hub connections (falls back to 802.1D behavior)
- **Edge**: Connections to end devices

**BPDU Handling**

RSTP treats BPDUs differently:

- All switches generate and send BPDUs every hello time (2 seconds default), not just the root bridge
- If a switch misses three consecutive BPDUs (6 seconds), it considers the neighbor lost and immediately recalculates
- BPDUs act as keepalives; faster failure detection enables faster convergence

**Backward Compatibility**

Rapid PVST+ switches detect legacy 802.1D BPDUs and automatically fall back to classic STP behavior on those ports. The port operates in 802.1D mode until no legacy BPDUs are received for the migration delay period (typically 3 seconds).

**Configuration**

Rapid PVST+ is the default spanning-tree mode on modern Cisco switches:

```
! Verify or set spanning-tree mode
spanning-tree mode rapid-pvst

! Configure root bridge for VLAN 10
spanning-tree vlan 10 root primary

! Alternative: manual priority configuration
spanning-tree vlan 10 priority 24576

! Configure secondary root bridge
spanning-tree vlan 10 root secondary
```

The `root primary` command sets priority to 24576 or 4096 less than the current root, ensuring this switch becomes root. The `root secondary` command sets priority to 28672, making it the backup root.

**Verification**

```
show spanning-tree vlan 10

VLAN0010
  Spanning tree enabled protocol rstp
  Root ID    Priority    24586
             Address     0023.04ee.be01
             Cost        4
             Port        23 (GigabitEthernet1/0/23)
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32778  (priority 32768 sys-id-ext 10)
             Address     f8b7.e203.5b00
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  300 sec

Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
Gi1/0/23            Root FWD 4         128.23   P2p
Gi1/0/24            Altn BLK 4         128.24   P2p
```

The output shows "protocol rstp" confirming Rapid PVST+ operation, port roles (Root, Altn for Alternate), and port states (FWD for Forwarding, BLK for Blocking/Discarding).

