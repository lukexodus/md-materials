## Multiple Spanning Tree (MST)


Multiple Spanning Tree Protocol (MST / IEEE 802.1s) addresses scalability limitations of PVST+ by mapping multiple VLANs to spanning tree instances. While PVST+ requires a separate STP instance per VLAN (100 VLANs = 100 instances), MST groups VLANs into instances, drastically reducing CPU and memory consumption.

**MST Fundamentals**

MST divides the network into MST regions. Within each region:

- Multiple VLANs map to a limited number of instances (typically 1-16)
- Internal Spanning Tree (IST) coordinates between instances
- Common Spanning Tree (CST) connects different regions

All switches in an MST region must have:

- Same MST configuration name
- Same MST configuration revision number
- Same VLAN-to-instance mapping

Switches with matching configurations belong to the same region; different configurations create separate regions.

**MST Instances**

MST supports up to 65 instances (0-4094), though practical deployments use far fewer:

- **Instance 0 (IST)**: Internal Spanning Tree, mandatory, includes all VLANs not explicitly mapped
- **Instances 1-4094**: User-defined mappings

**Example MST Design:**

- Instance 0: Management VLANs (1, 99)
- Instance 1: User VLANs (10-50)
- Instance 2: Voice VLANs (100-150)
- Instance 3: Guest VLANs (200-250)

This reduces 241 PVST+ instances to 4 MST instances, decreasing resource consumption by approximately 98%.

**MST Configuration**

```
! Enter MST configuration mode
spanning-tree mode mst

! Configure MST region parameters
spanning-tree mst configuration
 name REGION_WEST
 revision 1
 instance 1 vlan 10-50
 instance 2 vlan 100-150
 instance 3 vlan 200-250
 exit

! Configure root bridge for instances
spanning-tree mst 0 priority 24576
spanning-tree mst 1 priority 24576
spanning-tree mst 2 priority 28672
spanning-tree mst 3 priority 28672

! Verify configuration before applying
show spanning-tree mst configuration
```

**Critical MST Configuration Rules:**

All switches in a region must have **identical** configuration:

- Region name must match exactly (case-sensitive)
- Revision number must match
- VLAN-to-instance mappings must be identical

A single mismatch causes switches to operate in different regions, creating a CST boundary with suboptimal convergence.

**MST Region Boundaries**

When MST regions connect to each other or to PVST+ domains:

- CST provides inter-region connectivity
- IST Instance 0 represents the entire region to external networks
- Region appears as a single virtual switch to external topology

**MST Port Roles**

MST uses RSTP port roles with enhancements:

- **Root Port**: Best path to CIST (Combined IST) root
- **Designated Port**: Best path for segment
- **Alternate Port**: Backup path to root
- **Backup Port**: Backup to same segment
- **Master Port**: Connects MST region to CIST root (at region boundary)
- **Boundary Port**: Connects to different MST region or PVST+ domain

**MST and PVST+ Interoperability**

MST can coexist with PVST+ through boundary ports. Boundary port behavior:

- MST switch generates PVST+ BPDUs on boundary ports for all VLANs
- IST Instance 0 interacts with all PVST+ VLANs
- If PVST+ topology is inconsistent (different root per VLAN), MST may detect inconsistency

**[Inference] This interoperability adds complexity** and is typically avoided in production by standardizing on one protocol per network domain.

**MST Convergence**

MST inherits RSTP's rapid convergence mechanisms:

- Proposal/agreement handshake on point-to-point links
- Edge ports transition immediately to forwarding
- Convergence typically completes in 1-3 seconds
- Independent convergence per instance within region

**MST Load Balancing**

Configure different root bridges per instance for load distribution:

```
! Core Switch 1 - root for instances 0 and 1
spanning-tree mst 0 priority 24576
spanning-tree mst 1 priority 24576
spanning-tree mst 2 priority 28672
spanning-tree mst 3 priority 28672

! Core Switch 2 - root for instances 2 and 3
spanning-tree mst 0 priority 28672
spanning-tree mst 1 priority 28672
spanning-tree mst 2 priority 24576
spanning-tree mst 3 priority 24576
```

VLANs in instances 0-1 use paths through Core Switch 1, while VLANs in instances 2-3 use paths through Core Switch 2, achieving load distribution across redundant links.

**MST Verification**

```
! Verify MST configuration
show spanning-tree mst configuration

Name      [REGION_WEST]
Revision  1     Instances configured 4

Instance  Vlans mapped
--------  ---------------------------------------------------------------------
0         1,51-99,151-199,251-4094
1         10-50
2         100-150
3         200-250

! View MST instance details
show spanning-tree mst 1

###### MST1    vlans mapped:   10-50
Bridge        address 0023.04ee.be01  priority  24577 (24576 sysid 1)
Root          this switch for MST1

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- --------------------------------
Gi1/0/23         Desg FWD 20000     128.23   P2p Bound(PVST)
Gi1/0/24         Desg FWD 20000     128.24   P2p Bound(PVST)

! View MST region and boundary information
show spanning-tree mst detail
```

**MST Design Considerations**

**Advantages:**

- Dramatically reduced resource utilization (CPU, memory)
- Supports networks with hundreds of VLANs efficiently
- Maintains RSTP rapid convergence
- Provides load balancing through instance-based root bridge variation
- Industry standard (IEEE 802.1s)

**Disadvantages:**

- More complex configuration requiring exact match across region
- Configuration errors create region boundaries with unexpected behavior
- Troubleshooting requires understanding IST, CST, and instance relationships
- Limited per-VLAN granularity within instances
- Interoperability with PVST+ adds complexity

**When to Use MST:**

- Large networks with 50+ VLANs
- Data center environments with VLAN proliferation
- Networks requiring resource optimization
- Standardized environments with strict change control

**When to Use PVST+/Rapid PVST+:**

- Networks with fewer than 50 VLANs
- Environments requiring maximum per-VLAN control
- Organizations without MST expertise
- Networks prioritizing simplicity over optimization

**MST Migration Strategy**

Migrating from PVST+ to MST requires careful planning:

1. **Document existing topology**: Map current root bridges, blocked ports, and traffic paths for all VLANs
2. **Design MST instances**: Group VLANs logically (by function, location, or security zone)
3. **Establish maintenance window**: Complete migration during low-traffic period
4. **Configure MST on all switches simultaneously**: Prepare configurations offline, apply rapidly to minimize inconsistency
5. **Verify instance 0 root**: Ensure IST root bridge is correct before enabling
6. **Monitor convergence**: Watch for topology changes and verify expected paths
7. **Validate traffic flows**: Confirm no VLANs lost connectivity
8. **Document final configuration**: Update network diagrams and configuration standards

**MST Configuration Template**

```
! Standard MST configuration for region
spanning-tree mode mst

spanning-tree mst configuration
 name CORPORATE_NETWORK
 revision 2
 ! Instance 1: User data VLANs
 instance 1 vlan 10,20,30,40,50
 ! Instance 2: Voice VLANs
 instance 2 vlan 110,120,130
 ! Instance 3: Server VLANs
 instance 3 vlan 200,210,220
 ! Instance 0: Remaining VLANs (default mapping)
 exit

! Root bridge configuration
spanning-tree mst 0 root primary
spanning-tree mst 1 root primary
spanning-tree mst 2 root secondary
spanning-tree mst 3 root secondary

! PortFast and BPDU Guard on access ports
spanning-tree portfast default
spanning-tree portfast bpduguard default

! Hello time adjustment (optional)
spanning-tree mst hello-time 2
spanning-tree mst max-age 20
spanning-tree mst forward-time 15
```

**MST Troubleshooting**

**Common Issues:**

**Region Mismatch:** Switches with different names, revisions, or mappings operate in separate regions. Symptom: unexpected topology, additional hops, or suboptimal paths.

Solution: Verify configuration match with `show spanning-tree mst configuration` on all switches.

**Inconsistent Root Bridge:** If MST boundaries connect to PVST+ with different roots per VLAN, MST may detect inconsistency.

Solution: Standardize PVST+ root bridges or complete MST migration.

**Unexpected Blocking:** Load balancing may not work as intended if instance mappings don't align with traffic patterns.

Solution: Review VLAN-to-instance mappings and adjust root bridge priorities.

**Rapid Convergence Failure:** If convergence takes longer than expected, check for non-point-to-point links or shared media.

Solution: Verify link types with `show spanning-tree mst interface detail`.

**Monitoring and Maintenance**

```
! Regular verification commands
show spanning-tree mst
show spanning-tree mst configuration
show spanning-tree mst 1 detail
show spanning-tree inconsistentports

! Log analysis for topology changes
show logging | include TOPOLOGY|STP

! Interface-specific debugging
debug spanning-tree mst events
```

**Related Topics for Advanced STP Understanding**

To build comprehensive spanning-tree expertise, explore: STP protection mechanisms (Root Guard, Loop Guard, UDLD), STP in virtual environments (vPC, VSS, StackWise), Layer 3 design alternatives to STP (routed access layer), troubleshooting STP loops and convergence issues, STP interaction with EtherChannel/LACP, STP security considerations and attack vectors, optimizing STP for VoIP and real-time traffic, STP behavior during switch stack operations, integrating STP with SDN controllers, and comparing STP alternatives like TRILL and SPB.

---

