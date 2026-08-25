## Root Bridge Election


Root bridge election is the foundation of STP operation. All switches in a broadcast domain participate in electing a single root bridge, which becomes the reference point for all path calculations.

**Election Process**

1. **Initial assumption**: When a switch boots, it assumes it is the root bridge and advertises itself with BPDUs containing its own bridge ID as both root bridge ID and sender bridge ID.
    
2. **BPDU comparison**: Switches receive BPDUs from neighbors and compare the advertised root bridge ID with their own belief about the root.
    
3. **Superior BPDU adoption**: If a received BPDU contains a lower root bridge ID, the switch updates its belief and begins forwarding that information. The switch changes its BPDUs to reflect the superior root bridge ID while keeping its own bridge ID as sender.
    
4. **Convergence**: Eventually all switches agree on which bridge has the lowest bridge ID. That bridge becomes the root bridge.
    

**Bridge ID Comparison**

The 8-byte bridge ID is compared as a single value, with priority being most significant:

- Priority is compared first (lower wins)
- If priorities are equal, MAC address determines the winner (lower wins)
- MAC addresses are guaranteed unique, ensuring deterministic election

**Root Bridge Characteristics**

The root bridge:

- All its ports become designated ports (forwarding state)
- Generates configuration BPDUs every hello time (2 seconds default)
- Sets the timing parameters (hello, max age, forward delay) for the entire spanning tree
- Never has a root port (it is the root)

**Strategic Root Placement**

Root bridge placement significantly affects network performance. Best practices include:

**Central placement**: Position the root bridge at the network core where it has high-bandwidth connections to all distribution switches. Placing the root at the network edge forces suboptimal traffic paths.

**Deterministic selection**: Never rely on default elections (lowest MAC address). Explicitly configure root bridges to ensure predictable topology and prevent low-end switches from becoming root.

**Primary and secondary roots**: Configure both a primary root (lowest priority) and secondary root (second-lowest priority) for redundancy. If the primary fails, the secondary automatically assumes the role without random re-election.

**Configuration Methods**

```
! Method 1: Macro command (recommended for simplicity)
spanning-tree vlan 10 root primary
spanning-tree vlan 10 root secondary

! Method 2: Manual priority (recommended for precise control)
spanning-tree vlan 10 priority 24576    ! Primary root
spanning-tree vlan 10 priority 28672    ! Secondary root

! Method 3: Ensure this switch is always root
spanning-tree vlan 10 priority 0        ! Lowest possible priority
```

The `root primary` command examines current root priority and sets local priority to 24576 (or 4096 less than current root if root priority is below 24576). The `root secondary` command sets priority to 28672.

**Priority Guidelines**

Since extended system ID uses 12 bits for VLAN ID, priority must be a multiple of 4096:

- 0, 4096, 8192, 12288, 16384, 20480, 24576, 28672, 32768 (default), 36864, 40960, 45056, 49152, 53248, 57344, 61440

Common practice:

- Primary root: 24576
- Secondary root: 28672
- All other switches: 32768 (default)

**Load Balancing Through Root Manipulation**

In networks with multiple VLANs, configure different root bridges per VLAN group for load distribution:

```
! Core Switch 1 - Root for VLANs 1-50
spanning-tree vlan 1-50 priority 24576
spanning-tree vlan 51-100 priority 28672

! Core Switch 2 - Root for VLANs 51-100
spanning-tree vlan 1-50 priority 28672
spanning-tree vlan 51-100 priority 24576
```

This configuration ensures redundant links carry production traffic rather than remaining completely blocked.

**Verification and Monitoring**

```
! View root bridge information
show spanning-tree root

                                        Root    Hello Max Fwd
Vlan                   Root ID          Cost    Time  Age Dly  Root Port
---------------- -------------------- --------- ----- --- ---  ----------------
VLAN0010         24586 0023.04ee.be01        4     2   20  15  Gi1/0/23
VLAN0020         24596 0023.04ee.be01        4     2   20  15  Gi1/0/23

! View local bridge information  
show spanning-tree bridge

                                                   Hello  Max  Fwd
Vlan                         Bridge ID              Time  Age  Dly  Protocol
---------------- --------------------------------- -----  ---  ---  --------
VLAN0010         32778 (32768, 10) f8b7.e203.5b00    2    20   15  rstp
VLAN0020         32788 (32768, 20) f8b7.e203.5b00    2    20   15  rstp

! Detailed VLAN spanning tree view
show spanning-tree vlan 10
```

