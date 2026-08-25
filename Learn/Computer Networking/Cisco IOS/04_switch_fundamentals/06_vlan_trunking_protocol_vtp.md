## VLAN Trunking Protocol (VTP)


VTP is a Cisco proprietary protocol that propagates VLAN configuration changes across a switched network, reducing administrative overhead in large environments. VTP operates over trunk links and can automatically add, delete, or rename VLANs across multiple switches.

**VTP Modes:**

- **Server**: Can create, modify, and delete VLANs. Advertises VLAN information and synchronizes with other switches. Default mode on Cisco switches. VLAN configuration stored in vlan.dat.
- **Client**: Cannot create, modify, or delete VLANs locally. Receives and forwards VTP advertisements. Synchronizes VLAN database with servers. VLAN configuration not stored locally after reload.
- **Transparent**: Can create, modify, and delete VLANs locally, but changes are not propagated. Forwards VTP advertisements from other switches without processing them. VLAN configuration stored in running config.
- **Off** (VTPv3 only): Disables VTP entirely. Does not process or forward VTP advertisements.

**VTP Configuration:**

```
Switch(config)# vtp domain COMPANY
Switch(config)# vtp mode {server | client | transparent}
Switch(config)# vtp password SecurePass123
Switch(config)# vtp version {1 | 2 | 3}
Switch(config)# vtp pruning
```

**VTP Domain:** All switches in a VTP domain must share the same domain name (case-sensitive). Switches only accept VTP advertisements from switches in the same domain. A switch with a null domain name accepts the first VTP advertisement it receives.

**VTP Revision Number:** VTP uses configuration revision numbers to determine which switch has the most recent VLAN information. Each time a VLAN change is made on a server, the revision number increments by one. When a switch receives an advertisement with a higher revision number, it overwrites its local VLAN database.

**VTP Pruning:** VTP pruning increases available bandwidth by restricting flooded traffic to trunk links that actually need it. If a VLAN has no active ports on a switch, pruning prevents broadcasts and unknown unicast traffic for that VLAN from traversing the trunk.

```
Switch(config)# vtp pruning
Switch(config)# interface gigabitethernet 0/24
Switch(config-if)# switchport trunk pruning vlan 10,20,30
```

**VTP Version Differences:**

- **VTP v1**: Basic VLAN propagation, supports normal range VLANs (1-1005)
- **VTP v2**: Adds support for Token Ring VLANs and unrecognized Type-Length-Value (TLV) forwarding
- **VTP v3**: Supports extended range VLANs, requires primary server election, enhanced authentication, private VLAN support

**VTP Security Considerations:** VTP can cause network-wide VLAN deletion if a switch with a higher revision number and incorrect VLAN database is connected. Best practices include:

- Always configure VTP passwords for domain authentication
- Reset revision number to zero before adding switches (change to transparent mode, then back)
- Use VTP transparent mode in smaller networks or when centralized management isn't needed
- Consider disabling VTP entirely in modern networks with configuration management tools

**Resetting VTP Revision Number:**

```
Switch(config)# vtp mode transparent
Switch(config)# vtp mode server
! Or delete vlan.dat and reload
Switch# delete flash:vlan.dat
Switch# reload
```

**Verification Commands:**

```
Switch# show vtp status
Switch# show vtp password
Switch# show vtp counters
```

