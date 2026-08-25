## Port Roles and States


STP assigns roles and states to switch ports based on their position in the spanning tree topology. Understanding these roles and states is critical for troubleshooting and optimization.

**Port Roles (802.1D and RSTP)**

**Root Port**

- One root port per non-root switch
- Port with best path (lowest cost) to root bridge
- Always in forwarding state [Inference: in a stable topology]
- Selection criteria: lowest root path cost, then tie-breakers (sender bridge ID, sender port ID, receiver port ID)
- If root port fails, the switch recalculates and promotes alternate port to root port

**Designated Port**

- One designated port per network segment
- Port with best path to root on that segment
- Always in forwarding state [Inference: in a stable topology]
- On root bridge, all ports are designated ports
- Designated port "represents" that segment's connection toward the root

**Alternate Port (RSTP)**

- Backup path to root bridge
- Receives BPDUs from another switch that has a better path to root
- In discarding state but ready for rapid transition
- If root port fails, alternate port can immediately transition to root port (within 1-3 seconds in RSTP)

**Backup Port (RSTP)**

- Backup connection to the same segment
- Receives BPDUs from the same switch (typically hub scenario or loopback)
- In discarding state
- Less common in modern switched networks

**Disabled Port**

- Administratively shut down
- Does not participate in spanning tree

**Port States (802.1D Classic STP)**

**Blocking**

- Does not forward frames
- Does not learn MAC addresses
- Receives BPDUs only
- Prevents loops while maintaining topology awareness
- Transition to listening: 20 seconds (max age timer)

**Listening**

- Does not forward frames
- Does not learn MAC addresses
- Sends and receives BPDUs
- Builds active topology knowledge
- Duration: 15 seconds (forward delay timer)

**Learning**

- Does not forward frames
- Learns MAC addresses and populates MAC address table
- Sends and receives BPDUs
- Prepares for forwarding by building MAC table
- Duration: 15 seconds (forward delay timer)

**Forwarding**

- Forwards frames
- Learns MAC addresses
- Sends and receives BPDUs
- Normal operational state for root and designated ports

**Disabled**

- Administratively down
- Does not participate in STP

**Transition Timeline (802.1D)**

When a blocked port transitions to forwarding:

- Blocking → Listening: 20 seconds (max age)
- Listening → Learning: 15 seconds (forward delay)
- Learning → Forwarding: 15 seconds (forward delay)
- Total: 50 seconds (20 + 15 + 15)

In practice, convergence typically takes 30-50 seconds depending on when topology change occurs relative to timers.

**Port States (RSTP/Rapid PVST+)**

**Discarding**

- Combines 802.1D blocking, listening, and disabled states
- Does not forward frames or learn MAC addresses
- Receives BPDUs
- Alternate and backup ports remain in discarding state

**Learning**

- Does not forward frames
- Learns MAC addresses
- Rapid transition possible with proposal/agreement

**Forwarding**

- Forwards frames
- Learns MAC addresses
- Normal operational state

**RSTP State Transitions**

RSTP achieves faster convergence through:

- Edge ports: Immediate transition to forwarding (0 seconds)
- Point-to-point links with proposal/agreement: 1-3 seconds
- Loss of BPDU (3 missed hellos): Immediate alternate port promotion (≈6 seconds detection + 1-3 seconds transition)

**Port Role and State Verification**

```
show spanning-tree vlan 10

Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
Gi1/0/1             Desg FWD 4         128.1    P2p Edge
Gi1/0/23            Root FWD 4         128.23   P2p
Gi1/0/24            Altn BLK 4         128.24   P2p
```

- **Role**: Root, Desg (Designated), Altn (Alternate), Back (Backup)
- **Sts**: FWD (Forwarding), BLK (Blocking/Discarding), LRN (Learning), LIS (Listening)
- **Type**: P2p (point-to-point), Shr (shared), Edge (PortFast enabled)

**Detailed Port Information**

```
show spanning-tree interface gigabitethernet1/0/23 detail

Port 23 (GigabitEthernet1/0/23) of VLAN0010 is designated forwarding
  Port path cost 4, Port priority 128, Port Identifier 128.23
  Designated root has priority 24586, address 0023.04ee.be01
  Designated bridge has priority 24586, address 0023.04ee.be01
  Designated port id is 128.23, designated path cost 0
  Timers: message age 0, forward delay 0, hold 0
  Number of transitions to forwarding state: 1
  Link type is point-to-point by default
  BPDU: sent 3524, received 0
```

This output shows BPDU statistics, path costs, transition counts, and detailed role information useful for troubleshooting convergence issues or suboptimal paths.

