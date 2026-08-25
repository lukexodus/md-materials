## Spanning Tree Protocol (STP)


Spanning Tree Protocol prevents broadcast storms and switching loops in redundant Layer 2 topologies by creating a loop-free logical topology while maintaining physical redundancy for fault tolerance.

**STP operational principles:**

- **Loop detection**: Identify potential switching loops in network topology
- **Root bridge selection**: Elect single reference point for spanning tree calculation
- **Path cost calculation**: Determine optimal paths to root bridge
- **Port state management**: Block redundant paths while maintaining backup routes
- **Topology change handling**: Rapid convergence when network changes occur

**Bridge Protocol Data Units (BPDU):**

- **Configuration BPDUs**: Carry spanning tree information between switches
- **Topology Change BPDUs**: Signal network topology modifications
- **BPDU contents**: Bridge ID, root bridge ID, path cost, port ID, timers
- **BPDU transmission**: Sent every 2 seconds on all active ports

**Root bridge election process:**

1. **Bridge priority comparison**: Lower priority value wins (default 32768)
2. **MAC address tiebreaker**: Lower MAC address wins if priorities equal
3. **Root bridge announcement**: All switches converge on single root
4. **Path advertisement**: Root bridge advertises zero-cost path to itself

**Port roles and states:**

- **Root port**: Best path toward root bridge on non-root switches
- **Designated port**: Best path toward root bridge on specific network segment
- **Blocked port**: Redundant path blocked to prevent loops
- **Disabled port**: Administratively shut down or failed port

**STP port states:**

- **Disabled**: Port not participating in spanning tree
- **Blocking**: Receiving BPDUs but not forwarding data
- **Listening**: Participating in topology calculation, not learning or forwarding
- **Learning**: Building MAC address table, not forwarding data
- **Forwarding**: Full operation with learning and forwarding enabled

**STP timers:**

- **Hello time**: BPDU transmission interval (default 2 seconds)
- **Forward delay**: Time spent in listening and learning states (default 15 seconds each)
- **Max age**: Maximum BPDU age before considering information stale (default 20 seconds)
- **Convergence time**: Total time for topology change (30-50 seconds)

**Rapid Spanning Tree Protocol (RSTP - 802.1w):**

- **Fast convergence**: Subsecond convergence in most scenarios
- **Enhanced port roles**: Root, designated, alternate, and backup ports
- **Proposal/agreement mechanism**: Rapid synchronization between switches
- **Edge port designation**: Immediate forwarding for end-device connections
- **Backward compatibility**: Interoperates with classic STP

**Multiple Spanning Tree Protocol (MSTP - 802.1s):**

- **VLAN load balancing**: Different spanning trees for different VLANs
- **Region concept**: Groups of switches sharing identical VLAN-to-instance mappings
- **Scalability improvement**: Reduces BPDU overhead in large networks
- **Common Spanning Tree (CST)**: Inter-region connectivity

**STP optimization techniques:**

- **Root bridge placement**: Position root bridge centrally with high-capacity links
- **Path cost manipulation**: Influence spanning tree topology through cost adjustment
- **Port priorities**: Control port selection when multiple paths have equal cost
- **BPDU guard**: Protect against unauthorized device connections
- **Root guard**: Prevent inferior bridges from becoming root

