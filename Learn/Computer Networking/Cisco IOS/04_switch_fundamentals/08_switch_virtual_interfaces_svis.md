## Switch Virtual Interfaces (SVIs)


Switch Virtual Interfaces are logical Layer 3 interfaces associated with VLANs on a switch. SVIs enable remote management, inter-VLAN routing, and provide default gateway functionality for VLANs.

**SVI Characteristics:**

- Each VLAN can have one SVI assigned with an IP address
- SVIs exist in software; they have no physical interface
- The SVI for a VLAN becomes active when at least one port in that VLAN is up/up and forwarding
- SVIs can be managed, monitored, and configured like physical interfaces
- SVIs reduce the number of physical interfaces required for routing between VLANs

**Creating SVIs:**

```
Switch(config)# interface vlan 10
Switch(config-if)# ip address 192.168.10.1 255.255.255.0
Switch(config-if)# description Sales Department Gateway
Switch(config-if)# no shutdown

Switch(config)# interface vlan 20
Switch(config-if)# ip address 192.168.20.1 255.255.255.0
Switch(config-if)# description Engineering Gateway
Switch(config-if)# no shutdown
```

**Management VLAN SVI:** The management VLAN allows remote access to the switch via Telnet, SSH, or HTTP. Typically configured on a dedicated VLAN separate from user data:

```
Switch(config)# vlan 99
Switch(config-vlan)# name MANAGEMENT
Switch(config-vlan)# exit

Switch(config)# interface vlan 99
Switch(config-if)# ip address 192.168.99.2 255.255.255.0
Switch(config-if)# no shutdown
Switch(config-if)# exit

Switch(config)# ip default-gateway 192.168.99.1
```

The `ip default-gateway` command is required on Layer 2 switches to reach management networks beyond the local subnet. Layer 3 switches use routing tables instead.

**SVI Requirements:** For an SVI to reach the up/up state:

1. The VLAN must exist in the VLAN database
2. The VLAN must have at least one access port or trunk port carrying that VLAN in an up/up state
3. The SVI must not be manually shutdown
4. IP routing must be enabled if used for inter-VLAN routing (`ip routing`)

**SVI Benefits:**

- Eliminates need for separate physical interfaces for each VLAN
- Faster routing performance (hardware-based)
- Simplified cabling and reduced equipment costs
- Provides gateway functionality for hosts in VLANs
- Enables dynamic routing protocol participation

**SVI Limitations:**

- Not all switch models support SVIs (requires Layer 3 capabilities)
- Number of SVIs may be limited by switch platform
- Each SVI consumes memory and processing resources
- SVI state depends on underlying VLAN and port status

**Configuring SVI Helper Features:**

```
! DHCP relay for hosts using external DHCP server
Switch(config)# interface vlan 10
Switch(config-if)# ip helper-address 192.168.100.10

! HSRP for gateway redundancy
Switch(config)# interface vlan 10
Switch(config-if)# standby 1 ip 192.168.10.1
Switch(config-if)# standby 1 priority 110
Switch(config-if)# standby 1 preempt
```

**Verification Commands:**

```
Switch# show ip interface brief
Switch# show interfaces vlan 10
Switch# show ip route
Switch# show vlan brief
Switch# show ip interface vlan 10
```

**Key points:**

- Layer 2 switches forward based on MAC addresses and learn dynamically, maintaining a MAC address table with aging timers.
- Switch ports operate as access (single VLAN, untagged), trunk (multiple VLANs, tagged), or dynamic modes with DTP negotiation.
- Port security restricts MAC addresses per port with protect, restrict, or shutdown violation actions to prevent unauthorized access.
- VLANs segment networks into logical broadcast domains with normal range (1-1005) and extended range (1006-4094) support.
- VTP propagates VLAN configurations across switches in server, client, or transparent modes using revision numbers for synchronization.
- Inter-VLAN routing uses router-on-a-stick with subinterfaces or Layer 3 switches with SVIs for hardware-based routing.
- SVIs provide Layer 3 gateway functionality for VLANs and enable switch management without requiring physical routed interfaces.

---

